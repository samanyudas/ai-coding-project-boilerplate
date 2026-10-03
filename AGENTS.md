# AGENTS.md

The entry point for agents in this repository, read at the start of every session.
Task arrives → read this file → open only the docs the repo map links for that task → read the code → make the change → verify.

## Initialization

This repo is not initialized yet.
Given a project idea, follow `docs/initialization.md` before any feature work; its last steps delete this section.
When you are changing the boilerplate itself instead, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Quick start

1. Restore state: `scripts/restore-state.sh` prints the features, progress notes, decision headings, the git checkpoint, and environment readiness (Claude Code runs it for you at session start and after compaction).
2. When it reports the environment not ready, run `scripts/setup.sh`; setup repeats only when the environment changed.
3. Continue the `active` feature, or start the first `not_started` one with `scripts/feature.sh start <id>`, and restate its behavior as a concrete goal (the input, the behaviour, the output, and how you will verify it); ask when any of those is open.
"Add search" is not a goal yet; "case-insensitive title search on `GET /posts?q=`, newest first, covered by an API test" is.
4. Run the project: TODO(project): the command that starts it, and how to reach it (URL, CLI usage).

## Tech stack

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()`, not 1.x `query()`).
- TODO(project): Runtime version, pinned in a file (e.g. `.nvmrc`, `.python-version`).

## Hard constraints

1. The repo is the single source of truth: you know only your task, the files here, and tool output, so anything that matters is written into a file here.
2. Write code against the exact versions in Tech stack.
3. Commit only through the pre-commit hook, with `scripts/verify.sh` passing.
4. Commit each unit of work as soon as it is done and verified, with its code, tests, docs, and updated state (`docs/features.json`, `PROGRESS.md`), so compaction or a crash never loses finished work. Discard a failed attempt with `git restore` or by dropping its branch.
5. WIP = 1 is per agent: parallel agents each take a different, independent feature, on their own branch in their own worktree, and merge only finished, verified work.
6. Keep secrets out of tracked files.
7. Diagnose before retrying: read the failing log (`.harness/runs/latest/`) or runtime signal and name the cause first, so a retry tests a hypothesis instead of guessing.
8. TODO(project): Project-wide hard constraints, one per line, each with its reason.

## Feature list rules

`docs/features.json` is the single source of truth for scope and done: each feature's behavior, its verification command, its state, and the evidence that it passed.

- Only one feature is `active` at a time; `scripts/feature.sh start <id>` refuses a second.
- Only `scripts/feature.sh` changes a state: `verify <id>` marks a feature `passing`, with evidence, and only when its verification passes; on failure, fix it or `block <id> "<reason>"`.
- Edit the file by hand only to add `not_started` features, each small enough to finish and verify alone; anything else you notice becomes one.

## Repo map

`scripts/verify.sh` fails when a listed path is missing, or when a top-level entry, a file in `docs/`, or a module doc is unlisted.
Search with `rg <pattern>` for content and `rg --files | rg <name>` for files.

- `PROGRESS.md` - Notes on how far the active feature got. Update with every commit.
- `DECISIONS.md` - Project-wide decisions with their reasons and rejected alternatives. Open entries that bear on your task.
- `docs/features.json`, `scripts/feature.sh` - Every feature's behavior, verification, state, and evidence; the script (`list`, `start`, `verify`, `block`) is the only way to change a state.
- `docs/initialization.md` - The one-time setup of a new project. Read when given a project idea.
- `docs/conventions.md`, `docs/architecture.json` - Architecture and code rules, and their machine-checked part: components, integration test paths, and dependency rules. Read before writing code.
- `docs/testing.md` - How tests are written and run. Read before writing or changing tests.
- `docs/security.md` - Secrets, credentials, and untrusted input. Read before touching any of them.
- `docs/tools.md`, `docs/documentation.md` - Which tools agents use, and where each rule or piece of knowledge goes and how docs are structured. Read before adding a tool or script, a rule, or any doc.
- `docs/observability.md` - Logs, health checks, run evidence, and the verification report. Read before diagnosing a failure, or adding code that runs.
- `docs/harness-audit.md`, `docs/cleanup.md` - Fixing, auditing, and measuring the harness, and the per-session and weekly cleanup. Read when a task fails, before ending a session, when asked to audit or clean up, or when results get worse.
- `scripts/setup.sh`, `scripts/check-ready.sh` - Build the environment from a fresh clone, and check fast that it still matches. Both safe to re-run.
- `scripts/restore-state.sh`, `scripts/end-session.sh`, `scripts/scan.sh`, `.claude/settings.json` - Restore state at session start (the Claude Code hook runs it, also after compaction), check for a clean handoff at session end, and report weekly drift.
- `scripts/verify.sh`, `scripts/review-change.sh` - The leveled Definition of Done (limits and levels at the top), and the automated review of each change.
- `.githooks/pre-commit`, `.github/workflows/verify.yml`, `.github/workflows/maintenance.yml` - Run both scripts above before every commit and in CI on every push, and open the weekly cleanup and monthly audit issues.
- `AGENTS.md`, `CLAUDE.md`, `README.md`, `assets/` - This file, its import for Claude Code, the human-facing overview, and its icon.
- `harness/` - Notes and reasons behind this boilerplate. Delete when starting a project.

## Adding a rule or knowledge

Search for an existing rule on the subject first, and change it rather than adding one that conflicts.
Then put the new one where the routing table in `docs/documentation.md` sends it (a check, a hard constraint, `DECISIONS.md`, a topic or module doc, the source, a feature, or `PROGRESS.md`), in the same commit as the change it describes.

## Definition of Done

A feature is done when its end-to-end verification passes, not when its code is written.
`scripts/verify.sh` checks in levels and stops at the first that fails; fix what it reports and re-run (`--upto <level>` for a fast loop):

1. Static: TODO(project): the format, lint, and type-check commands.
2. Tests and startup: TODO(project): the unit and integration test commands, and the startup check.
3. End to end: every `passing` feature's flow, re-run.

- [ ] New or changed behaviour has a test, a change across components has an integration or end-to-end test that crosses them, and `scripts/feature.sh verify <id>` (levels 0 to 2, then the feature's end-to-end flow) marked it `passing`.
- [ ] You ran the user flow yourself on the running project (computer use or a browser for a UI; the real CLI or HTTP calls otherwise), and recorded evidence for each requirement in the verification report (`docs/observability.md`).
- [ ] New knowledge is written where `docs/documentation.md` routes it, and the unit is committed with a message that says why.
- [ ] Before the session ends, `scripts/end-session.sh` passes: scratch files gone, nothing uncommitted, state current, every level green.
