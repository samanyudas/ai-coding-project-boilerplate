# AGENTS.md

The map for agents working in this repository.
Read it at the start of every session, then read each doc it points to when that doc's condition applies.
The repo is the spec: every decision that matters is written into a file here, not left in a conversation.

Lines marked `TODO(project)` are unfilled.
List them with `rg 'TODO\(project\)'`.

## Starting a project from this boilerplate

1. Fill every `TODO(project)` slot from the idea you were given.
Ask about anything the idea leaves open.
2. Delete `harness/` and its line in the repo map.
3. Run `scripts/setup.sh`, then `scripts/verify.sh`, and commit.

When `harness/` exists and you are changing the boilerplate itself, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Tech stack

Write code against these exact versions, not whichever version is most common.

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()`, not 1.x `query()`).
- TODO(project): Runtime version, pinned in a file (e.g. `.nvmrc`, `.python-version`).

## Session start

1. Run `scripts/setup.sh`.
If it fails, fix the setup in the repo before starting the task.
2. Read `PROGRESS.md` to pick up where the last session stopped.
3. Restate the task as a concrete goal: the input, the behaviour, the output, and how you will verify it.
Ask when any of those is open.
"Add search" is not a goal yet; "case-insensitive title search on `GET /posts?q=`, newest first, covered by an API test" is.

## Repo map

`scripts/verify.sh` fails when a listed path is missing, or when a top-level entry or a file in `docs/` is unlisted.
Search with `rg <pattern>` for content and `rg --files | rg <name>` for files.

- `AGENTS.md` - This map. Stays under 100 lines; detail goes in `docs/`.
- `CLAUDE.md` - Imports this file for Claude Code.
- `README.md` - Human-facing overview.
- `PROGRESS.md` - Where the work stands. Read at session start; update before you stop.
- `docs/conventions.md` - Architecture and code rules. Read before writing code.
- `docs/tools.md` - Which tools agents use and how to add one. Read before adding a tool, MCP server, or script.
- `docs/harness-audit.md` - How to audit and ablation-test the harness. Read when asked to audit, or when agent results get worse.
- `scripts/setup.sh` - Takes a fresh clone to a working environment. Safe to re-run.
- `scripts/verify.sh` - The one verification command.
- `.githooks/pre-commit` - Runs `scripts/verify.sh` before every commit. Enabled by `scripts/setup.sh`.
- `.github/workflows/verify.yml` - Runs `scripts/verify.sh` in CI on every push and pull request.
- `assets/` - Static assets such as the project icon.
- `harness/` - Notes and reasons behind this boilerplate. Delete when starting a project.

## Verification

`scripts/verify.sh` runs every check and exits non-zero when one fails.
The pre-commit hook and CI run it too, so a failing check blocks the commit and the merge.
It checks:

- The repo map, and the 100-line limit on this file.
- TODO(project): Format check command.
- TODO(project): Lint command.
- TODO(project): Type-check command.
- TODO(project): Test command.
- TODO(project): Build command.

Run single commands while iterating.
Every new check goes into `scripts/verify.sh`, so one command keeps covering everything.

## Definition of Done

A task is done only when all of these hold:

- The goal you restated at session start is met, and you have exercised it on the real artifact (ran the app, called the endpoint, ran the CLI).
- New or changed behaviour is covered by a test.
- `scripts/verify.sh` passes.
- `PROGRESS.md`, this map, and `docs/` reflect what changed.
- The work is committed with a message that says why.

## When something fails

Look for the harness gap before switching the model or retrying.

1. Name which part of the harness failed: instructions, tools, environment, state, or feedback.
2. Ask why it failed.
3. Fix that part in the repo, as an executable rule where possible: a check in `scripts/verify.sh`, a hook, or a CI step.
4. Re-run the task.
