# Initialization

Turns this boilerplate into a working project, once, before any feature work.
Initialization makes every later session reliable and cheap; implementation then turns sessions into verified features.
Skip it and environment and test problems surface mid-feature, unverified code piles up, and each session repeats setup.

## Hard constraints

- Write no feature code until every step below is done and committed.
- Each step ends on something you ran and saw pass, not only something you wrote.
- Ask the user about anything the idea leaves open before choosing, and record each choice it settles in `DECISIONS.md`.

## Steps

1. **Idea.**
Write the Project paragraph in `AGENTS.md`: who it is for, what it must do, and what is out of scope for now.
2. **Stack.**
Choose the language, framework, and key libraries, with exact versions, and pin the runtime in a file.
Fill Tech stack in `AGENTS.md`, and record the choice and the rejected alternatives in `DECISIONS.md`.
3. **Environment.**
Put every install step in `scripts/setup.sh`.
In `scripts/check-ready.sh`, add the files that define the environment (lockfiles, runtime pin) to `ENV_FILES`, and fill the runtime check.
Run `scripts/setup.sh` in a fresh clone, then start the project and see it respond; write that command into Quick start in `AGENTS.md`.
If you will also use the app day to day, give the development build a "Developer" name suffix, its own version, and its own bundle ID, so it installs beside the stable build without conflict.
4. **Tests and checks.**
Configure the test runner, linter, formatter, and type-checker, and write one real test that passes.
Add every command to `run_project_checks` in `scripts/verify.sh` and to the Definition of Done in `AGENTS.md`, and fill `docs/testing.md`.
Break something on purpose and confirm `scripts/verify.sh` fails.
5. **Docs.**
Fill every remaining `TODO(project)` slot: conventions, security, tools, and hard constraints.
Where a slot does not apply yet, write that and why.
6. **Features.**
Break the idea into small features in `docs/features.json`, in priority order, all `not_started`, each one finishable and verifiable alone in one session.
Give each an `id` (a lowercase slug), a `title`, a measurable `behavior`, and a `verify` command: the exact focused test that proves it.
`scripts/verify.sh` checks the shape, and `scripts/feature.sh list` shows the result.
7. **Checkpoint.**
Delete `harness/`, this file, the Initialization section of `AGENTS.md`, and their lines in the repo map.
Run `scripts/verify.sh`, which now also fails on any unfilled slot, and commit the result as one "Initialize project" commit.
8. **Fresh session test.**
Run the fresh session test in `docs/harness-audit.md`.
A new session must be able to start, test, understand progress, and continue with no explanation from you; fix each gap it finds and commit.

## Checklist

- [ ] `scripts/setup.sh` works in a fresh clone, `scripts/check-ready.sh` reports ready, and the project starts.
- [ ] At least one real test passes through `scripts/verify.sh`, and breaking the code makes it fail.
- [ ] No `TODO(project)` slot remains.
- [ ] `docs/features.json` lists the first features, each with a measurable behavior and an exact `verify` command.
- [ ] Initialization is committed, and a fresh session passes the test.
