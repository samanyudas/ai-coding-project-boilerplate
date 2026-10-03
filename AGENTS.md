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

1. Restore state: `scripts/restore-state.sh` prints progress, decision headings, the git checkpoint, and environment readiness (Claude Code runs it for you at session start and after compaction).
Resolve any uncommitted changes it reports before anything else.
2. When it reports the environment not ready, run `scripts/setup.sh`; setup repeats only when the environment changed.
3. Continue the `active` task in `PROGRESS.md`, or mark the first `not_started` one `active`, and restate it as a concrete goal (the input, the behaviour, the output, and how you will verify it); ask when any of those is open.
"Add search" is not a goal yet; "case-insensitive title search on `GET /posts?q=`, newest first, covered by an API test" is.
4. Run the project: TODO(project): the command that starts it, and how to reach it (URL, CLI usage).

## Tech stack

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()`, not 1.x `query()`).
- TODO(project): Runtime version, pinned in a file (e.g. `.nvmrc`, `.python-version`).

## Hard constraints

Rules for every task. At most 15; `scripts/verify.sh` enforces the limit.

1. The repo is the single source of truth: you know only your task, the files here, and tool output, so anything that matters is written into a file here.
2. Write code against the exact versions in Tech stack.
3. Commit only through the pre-commit hook, with `scripts/verify.sh` passing.
4. Commit each unit of work as soon as it is done and verified, with its code, tests, docs, and updated `PROGRESS.md`, so compaction or a crash never loses finished work. Discard a failed attempt with `git restore` or by dropping its branch.
5. Work on one task at a time: the `active` one in `PROGRESS.md`. Record anything else you notice as a new `not_started` task instead of doing it now.
6. WIP = 1 is per agent: parallel agents each take a different, independent task, on their own branch in their own worktree, and merge only finished, verified work.
7. Keep secrets out of tracked files.
8. TODO(project): Project-wide hard constraints, one per line, each with its reason.

## Repo map

`scripts/verify.sh` fails when a listed path is missing, or when a top-level entry, a file in `docs/`, or a module doc is unlisted.
Search with `rg <pattern>` for content and `rg --files | rg <name>` for files.

- `PROGRESS.md` - Tasks with their status (one `active` at a time), active task notes, and test status. Update with every commit.
- `DECISIONS.md` - Project-wide decisions with their reasons and rejected alternatives. Open entries that bear on your task.
- `docs/initialization.md` - The one-time setup of a new project. Read when given a project idea.
- `docs/conventions.md` - Architecture and code rules. Read before writing code.
- `docs/testing.md` - How tests are written and run. Read before writing or changing tests.
- `docs/security.md` - Secrets, credentials, and untrusted input. Read before touching any of them.
- `docs/tools.md` - Which tools agents use. Read before adding a tool, MCP server, or script.
- `docs/documentation.md` - How docs are structured and sized. Read before writing any doc, this one included.
- `docs/harness-audit.md` - Fixing, auditing, and measuring the harness. Read when a task fails, when asked to audit, or when results get worse.
- `scripts/setup.sh` - Takes a fresh clone to a working environment. Safe to re-run.
- `scripts/check-ready.sh` - Fast check that the environment still matches the last setup.
- `scripts/restore-state.sh` - Prints the saved state and readiness a new or compacted session needs.
- `scripts/verify.sh` - The one verification command. Its limits are set at the top of the file.
- `scripts/check-stale-docs.sh` - Warns when a change leaves `PROGRESS.md` or a module doc behind.
- `.githooks/pre-commit` - Runs `verify.sh` and `check-stale-docs.sh` before every commit.
- `.github/workflows/verify.yml` - Runs the same two scripts in CI on every push and pull request.
- `.github/workflows/harness-audit.yml` - Opens a harness audit issue on the 1st of each month.
- `.claude/settings.json` - Claude Code hook that runs `restore-state.sh` at session start and after compaction.
- `AGENTS.md`, `CLAUDE.md` - This file, and its import for Claude Code.
- `README.md` - Human-facing overview.
- `assets/` - Static assets such as the project icon.
- `harness/` - Notes and reasons behind this boilerplate. Delete when starting a project.

## Adding a rule or knowledge

Search for an existing rule on the same subject first, and change it rather than adding one that conflicts.
Then put it in the first place that fits, in the same commit as the change it describes:

| What it is | Where it goes |
| --- | --- |
| Checkable by a tool | A test, a lint rule, or a check in `scripts/verify.sh` |
| True for every task | Hard constraints above |
| A project-wide decision and its reasons | `DECISIONS.md` |
| About one topic (API, database, security, testing) | `docs/<topic>.md`, linked in the repo map |
| About one module | That module's `ARCHITECTURE.md` or `CONSTRAINTS.md`, linked in the repo map |
| About specific code | Types, interfaces, and comments in the source |
| Where the work stands | `PROGRESS.md` |

## Definition of Done

Check every item before calling a task done:

- [ ] The goal you restated is met, exercised end to end on the real artifact (ran the app, called the endpoint, ran the CLI).
- [ ] New or changed behaviour is covered by a test.
- [ ] `scripts/verify.sh` passes: TODO(project): list the format, lint, type-check, test, and build commands it runs.
- [ ] The task is marked `passing` in `PROGRESS.md`, and new knowledge is written where the table above puts it.
- [ ] The finished unit is committed, with a message that says why.
