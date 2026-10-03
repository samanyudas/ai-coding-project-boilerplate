# AGENTS.md

The map for agents working in this repository.
Read it at the start of every session, then read each doc it points to when that doc's condition applies.
The repo is the single source of truth: you know only your task, the files here, and tool output, so anything that matters lives in a file here.

## Starting a project from this boilerplate

1. Fill every `TODO(project)` slot (`rg 'TODO\(project\)'` lists them) from the idea you were given.
Ask about anything the idea leaves open.
2. Delete `harness/`, its line in the repo map, and this section.
3. Run `scripts/setup.sh`, then `scripts/verify.sh`, and commit.

When `harness/` exists and you are changing the boilerplate itself, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Run

TODO(project): The command that starts the project, and how to reach it (URL, CLI usage).

## Tech stack

Write code against these exact versions, not whichever version is most common.

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()`, not 1.x `query()`).
- TODO(project): Runtime version, pinned in a file (e.g. `.nvmrc`, `.python-version`).

## Session start

1. Run `scripts/setup.sh`; if it fails, fix the setup in the repo before starting the task.
2. Read `PROGRESS.md` to pick up where the last session stopped.
3. Work on your own branch, in your own worktree (`git worktree add`) when other agents share the repo.
Merge only finished, verified work.
4. Restate the task as a concrete goal (the input, the behaviour, the output, and how you will verify it), and ask when any of those is open.
"Add search" is not a goal yet; "case-insensitive title search on `GET /posts?q=`, newest first, covered by an API test" is.

## Repo map

`scripts/verify.sh` fails when a listed path is missing, or when a top-level entry, a file in `docs/`, or a module doc is unlisted.
Search with `rg <pattern>` for content and `rg --files | rg <name>` for files.

- `AGENTS.md` - This map. Stays under 100 lines; detail goes in `docs/` or module docs.
- `CLAUDE.md` - Imports this file for Claude Code.
- `README.md` - Human-facing overview.
- `PROGRESS.md` - Where the work stands. Read at session start; update before you stop.
- `docs/conventions.md` - Code and documentation rules. Read before writing code or docs.
- `docs/tools.md` - Which tools agents use and how to add one. Read before adding a tool, MCP server, or script.
- `docs/harness-audit.md` - How to audit and ablation-test the harness. Read when asked to audit, or when agent results get worse.
- `scripts/setup.sh` - Takes a fresh clone to a working environment. Safe to re-run.
- `scripts/verify.sh` - The one verification command.
- `scripts/check-module-docs.sh` - Warns when a module changed but its docs did not. Run by the hook and CI.
- `.githooks/pre-commit` - Runs both scripts above before every commit. Enabled by `scripts/setup.sh`.
- `.github/workflows/verify.yml` - Runs both scripts above in CI on every push and pull request.
- `assets/` - Static assets such as the project icon.
- `harness/` - Notes and reasons behind this boilerplate. Delete when starting a project.

## Where knowledge goes

Write anything a future session needs, including context from chats, tickets, or outside docs, into one of these files, in the same commit as the change it describes:

- Where the work stands, and what is blocked: `PROGRESS.md`.
- A module's design decisions and their reasons: `ARCHITECTURE.md` in that module's directory.
- A module's hard rules: `CONSTRAINTS.md` in that module's directory.
- Project-wide code rules: `docs/conventions.md`.
- Commands, stack, and structure: this file.

Add each module doc to the repo map, and read it before changing that module.

## Verification

`scripts/verify.sh` runs every check and exits non-zero when one fails.
The pre-commit hook and CI run it too, so a failing check blocks the commit and the merge.
It checks:

- The repo map, the 100-line limit on this file, and unfilled `TODO(project)` slots once `harness/` is gone.
- TODO(project): The format, lint, type-check, test, and build commands, one per line.

Every new check goes into `scripts/verify.sh`, so one command keeps covering everything.

## Definition of Done

- The goal you restated at session start is met, and you have exercised it on the real artifact (ran the app, called the endpoint, ran the CLI).
- New or changed behaviour is covered by a test, and `scripts/verify.sh` passes.
- What a future session needs is written down, as set out under Where knowledge goes.
- Code, tests, and docs land together in one commit whose message says why.
A failed attempt is discarded with `git restore` or by dropping its branch, so the repo never holds half a change.

## When something fails

Look for the harness gap before switching the model or retrying.

1. Name which part of the harness failed: instructions, tools, environment, state, or feedback.
2. Ask why it failed.
3. Fix that part in the repo, as an executable rule where possible: a check in `scripts/verify.sh`, a hook, or a CI step.
4. Re-run the task.
