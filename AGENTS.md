# AGENTS.md

Read only the docs that the repo map links for your task.
Then read the code, make the change, and verify the result in that order.

## Initialization

This repo is not initialized yet.
Given a project idea, follow `docs/initialization.md` before any feature work.
When you are changing the boilerplate itself instead, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Quick start

1. Run `scripts/restore-state.sh` to print the features, progress notes, decision headings, git checkpoint, and environment readiness.
2. If the environment is not ready, run `scripts/setup.sh`.
3. Continue the `active` feature, or start the first `not_started` feature with `scripts/feature.sh start <id>`.
Before writing code, write its plan as `PROGRESS.md` describes, and ask when any part is unclear.
4. Run the project: TODO(project): the command that starts it, and how to reach it (URL, CLI usage).

## Tech stack

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()`, not 1.x `query()`).
- TODO(project): Runtime version, pinned in a file (e.g. `.nvmrc`, `.python-version`).

## Hard constraints

1. The repo is the single source of truth, because you know only your task, the files here, and tool output.
Write anything that matters into a file here.
2. Write code against the exact versions in Tech stack.
3. Commit only through the pre-commit hook, with `scripts/verify.sh` passing.
4. Commit each finished, verified unit immediately with its code, tests, docs, and updated state (`docs/features.json`, `PROGRESS.md`).
Discard a failed attempt with `git add -A && git restore --staged --worktree .`, which also drops staged and new files, or drop its branch.
5. WIP = 1 applies per agent.
Each parallel agent takes a different, independent feature on its own branch in its own worktree.
Merge only finished, verified work.
6. Keep secrets out of tracked files.
7. Before retrying, read the failing log (`.harness/runs/latest/`) or runtime signal, and name the cause the retry tests.
8. TODO(project): Project-wide hard constraints, one per line, each with its reason.

## Feature list rules

`docs/features.json` is authoritative for feature behavior, verification commands, states, and passing evidence.

- Only `scripts/feature.sh` changes a state.
`verify <id>` marks a feature `passing`, with evidence, only when its verification passes.
On failure, fix the feature or run `scripts/feature.sh block <id> "<reason>"`.
- Edit the file by hand only to add `not_started` features, each small enough to finish and verify alone.

## Repo map

`scripts/verify.sh` rejects missing listed paths and unlisted top-level entries, files in `docs/`, or module docs.

- `PROGRESS.md`, `DECISIONS.md` - Update the active feature's plan and notes with every commit, and read relevant decisions and their reasons before your task.
- `docs/features.json`, `scripts/feature.sh` - Feature behavior, verification, state, and evidence through `list`, `start`, `verify`, `block`, and `remaining`.
- `docs/initialization.md` - Follow the one-time setup when given a project idea.
- `docs/conventions.md`, `docs/architecture.json`, `docs/testing.md` - Before writing code or tests, read the architecture, code rules, high-stakes paths, and how to write and run tests.
- `docs/security.md` - Before touching secrets, credentials, or untrusted input, read their requirements.
- `docs/tools.md`, `docs/documentation.md` - Before adding tools, scripts, rules, or docs, or editing agent instructions, read tool usage, rule placement, and wording.
- `docs/observability.md` - Before diagnosing a failure or adding code that runs, read about logs, health checks, run evidence, and verification reports.
- `docs/loops.md`, `docs/graph.md`, `.claude/agents/evaluator.md` - Before configuring loops, changing the process, or judging features, read routing, shared state, human review, and independent evaluation.
- `REVIEW.md`, `.claude/agents/reviewer.md`, `.github/pull_request_template.md` - Before you review a diff or open a pull request, read what to report, the cycle limit, and the sections.
- `docs/harness-audit.md`, `docs/cleanup.md` - Read about harness repair, audits, cleanup, and context resets after failed tasks, bad merges, worse results, or degraded or ending sessions.
- `scripts/setup.sh`, `scripts/check-ready.sh`, `scripts/restore-state.sh`, `scripts/end-session.sh`, `scripts/scan.sh`, `scripts/check-ste.py` - Repeatable setup from a fresh clone, readiness checks, session restoration, handoff checks, and weekly drift and writing reports.
- `.claude/settings.json`, `scripts/guard-command.sh` - Claude Code hooks that restore state after start and compaction, and block hook skips, forced pushes, and deletes of `/` or home.
- `scripts/verify.sh`, `scripts/review-change.sh`, `scripts/test-ste.py`, `scripts/test-guard-command.sh`, `.githooks/pre-commit`, `.github/workflows/verify.yml` - The leveled Definition of Done, change review, and regression tests, run before each commit and on CI pushes.
- `.github/workflows/maintenance.yml` - Opens the weekly cleanup and monthly audit issues.
- `AGENTS.md`, `CLAUDE.md`, `README.md`, `assets/` - Agent entry point, Claude Code import, human overview, and icon.
- `harness/` - Delete the boilerplate's engineering notes and reasons when starting a project.

## Definition of Done

`scripts/verify.sh` stops at the first failing level, and `--upto <level>` gives a fast verification loop.

1. Static: TODO(project): the format, lint, and type-check commands.
2. Tests and startup: TODO(project): the unit and integration test commands, and the startup check.
3. End to end: every `passing` feature's flow, re-run.

- [ ] New or changed behavior has a test, and a change across components has an integration or end-to-end test that crosses them.
`scripts/feature.sh verify <id>` passed levels 0 to 2 and the feature's end-to-end flow, then marked it `passing`.
- [ ] A fresh-context reviewer read the diff as `REVIEW.md` describes, and the author fixed or answered each Important finding.
- [ ] An independent evaluator received only the feature id and walked the user flow on the running project.
Use the `evaluator` subagent, a fresh session, or another model, never the agent that wrote the code.
Its verification report (`docs/observability.md`) provides evidence for every requirement.
- [ ] New knowledge follows `docs/documentation.md`, and the unit's commit message explains why it changed.
- [ ] Before the session ends, `scripts/end-session.sh` passes with scratch files gone, nothing uncommitted, state current, and every level green.
