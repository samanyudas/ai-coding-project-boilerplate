# AGENTS.md

The entry point for agents in this repository, read at the start of every session.
Task arrives → read this file → open only the docs the repo map links for that task → read the code → make the change → verify.

## Starting a project from this boilerplate

1. Fill every `TODO(project)` slot (`rg 'TODO\(project\)'` lists them) from the idea you were given.
Ask about anything the idea leaves open.
2. Delete `harness/`, its line in the repo map, and this section.
3. Run `scripts/setup.sh`, then `scripts/verify.sh`, and commit.

When `harness/` exists and you are changing the boilerplate itself, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Quick start

1. Run `scripts/setup.sh`; if it fails, fix the setup in the repo before starting the task.
2. Read `PROGRESS.md` to pick up where the last session stopped.
3. Restate the task as a concrete goal (the input, the behaviour, the output, and how you will verify it), and ask when any of those is open.
"Add search" is not a goal yet; "case-insensitive title search on `GET /posts?q=`, newest first, covered by an API test" is.
4. Run the project: TODO(project): the command that starts it, and how to reach it (URL, CLI usage).
5. Verify with `scripts/verify.sh`.

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
4. One commit holds one whole change: its code, tests, and docs. Discard a failed attempt with `git restore` or by dropping its branch.
5. Work on your own branch, in your own worktree when other agents share the repo, and merge only finished, verified work.
6. Keep secrets out of tracked files.
7. TODO(project): Project-wide hard constraints, one per line, each with its reason.

## Repo map

`scripts/verify.sh` fails when a listed path is missing, or when a top-level entry, a file in `docs/`, or a module doc is unlisted.
Search with `rg <pattern>` for content and `rg --files | rg <name>` for files.

- `PROGRESS.md` - Where the work stands. Read at session start; update before you stop.
- `docs/conventions.md` - Architecture and code rules. Read before writing code.
- `docs/testing.md` - How tests are written and run. Read before writing or changing tests.
- `docs/security.md` - Secrets, credentials, and untrusted input. Read before touching any of them.
- `docs/tools.md` - Which tools agents use. Read before adding a tool, MCP server, or script.
- `docs/documentation.md` - How docs are structured and sized. Read before writing any doc, this one included.
- `docs/harness-audit.md` - Auditing and measuring the harness. Read when asked to audit, or when agent results get worse.
- `scripts/setup.sh` - Takes a fresh clone to a working environment. Safe to re-run.
- `scripts/verify.sh` - The one verification command. Its limits are set at the top of the file.
- `scripts/check-module-docs.sh` - Warns when a module changed but its docs did not.
- `.githooks/pre-commit` - Runs `verify.sh` and `check-module-docs.sh` before every commit.
- `.github/workflows/verify.yml` - Runs the same two scripts in CI on every push and pull request.
- `.github/workflows/harness-audit.yml` - Opens a harness audit issue on the 1st of each month.
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
| About one topic (API, database, security, testing) | `docs/<topic>.md`, linked in the repo map |
| About one module | That module's `ARCHITECTURE.md` or `CONSTRAINTS.md`, linked in the repo map |
| About specific code | Types, interfaces, and comments in the source |
| Where the work stands | `PROGRESS.md` |

## When something fails

1. Name which part of the harness failed: instructions, tools, environment, state, or feedback.
2. Ask why it failed, and fix that part in the repo, as an executable rule where possible.
3. Re-run the task.

## Definition of Done

Check every item before calling a task done:

- [ ] The goal you restated is met, exercised on the real artifact (ran the app, called the endpoint, ran the CLI).
- [ ] New or changed behaviour is covered by a test.
- [ ] `scripts/verify.sh` passes: TODO(project): list the format, lint, type-check, test, and build commands it runs.
- [ ] New knowledge is written where the table above puts it, and `PROGRESS.md` is current.
- [ ] One commit holds the change, with a message that says why.
