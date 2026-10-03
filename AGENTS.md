# AGENTS.md

How to work in this repository.
Read all of it at the start of every session.

Lines marked `TODO(project)` are unfilled.
List them with `rg 'TODO\(project\)'`.

## Starting a project from this boilerplate

1. Fill every `TODO(project)` line from the idea you were given.
Ask about anything the idea leaves open.
2. Delete `harness/` and its line in the repo map.
Nothing outside that folder depends on it.
3. Run `scripts/verify.sh` and commit.

When `harness/` still exists and you are changing the boilerplate itself, read `harness/README.md` first.

## Project

TODO(project): What this project is, who it is for, and what it must do, in one paragraph.

## Requirements

Before writing code, restate the task as a concrete goal: the input, the behaviour, the output, and how you will verify it.
When the request leaves any of those open, ask first.
"Add search" is not a goal yet.
"Add case-insensitive title search to `GET /posts?q=`, returning matching posts newest first, covered by an API test" is.

## Tech stack

Write exact versions.
Code is written against the versions named here, not whatever version is most common.

- TODO(project): Language and version.
- TODO(project): Framework and version.
- TODO(project): Key libraries and versions, with the API style to use (e.g. SQLAlchemy 2.0 `select()` style, not 1.x `query()`).
- TODO(project): Package manager and runtime version, pinned in a file (e.g. `.nvmrc`, `.tool-versions`).

## Environment setup

TODO(project): The exact commands that take a fresh clone to a working dev environment.

When a setup step fails, fix the setup in the repo and update these commands.
The next session must start from a working environment.

## Repo map

Keep this map accurate.
`scripts/verify.sh` fails when a listed path is missing or a top-level entry is unlisted.

- `AGENTS.md` - This file. The single source of rules for agents.
- `CLAUDE.md` - Imports this file for Claude Code.
- `README.md` - Human-facing overview.
- `assets/` - Static assets such as the project icon.
- `scripts/verify.sh` - The one verification command.
- `harness/` - Harness-engineering notes and the reasons behind this boilerplate. Delete when starting a project.

To find something, start from this map, then search with `rg <pattern>` for content and `rg --files | rg <name>` for files.
When you add, move, or remove a top-level area, update this map in the same change.

## Conventions

Rules the code follows that no tool enforces yet.
When the same correction comes up twice, add it here, or better, turn it into a lint rule or a check in `scripts/verify.sh`.

- TODO(project): Architecture: layers, module boundaries, and where new code goes.
- TODO(project): Naming, error handling, and logging patterns.
- TODO(project): Patterns to use, each with the reason (e.g. "Use SQLAlchemy 2.0 `select()`; the codebase has no 1.x queries").

## Verification

`scripts/verify.sh` is the single verification command.
It exits non-zero when any check fails.
It currently checks the repo map and runs:

- TODO(project): Format check command.
- TODO(project): Lint command.
- TODO(project): Type-check command.
- TODO(project): Test command.

Run the individual commands while iterating and `scripts/verify.sh` before calling a task done.
Every new check goes into `scripts/verify.sh` so one command keeps covering everything.

## Definition of Done

A task is done only when all of these hold:

- The goal you restated under Requirements is met, and you have exercised it on the real artifact (ran the app, called the endpoint, ran the CLI).
- New or changed behaviour is covered by a test.
- `scripts/verify.sh` passes.
- This file reflects any change to the stack, setup, map, conventions, or commands.
- The work is committed with a message that says why.

## When something fails

Look for the harness gap before switching the model or retrying.

1. Name which part of the harness failed: requirements, conventions, environment, verification, or memory of earlier sessions.
2. Ask why it failed.
3. Fix that part in the repo (this file, the setup, `scripts/verify.sh`).
4. Re-run the task.
