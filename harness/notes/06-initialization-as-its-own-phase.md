# 06 - Why initialization needs its own phase

## Notes

The two phases have different goals:

- Implementation maximizes the quantity and quality of verified features.
- Initialization maximizes the reliability and efficiency of all later implementation.

The problem: the agent starts coding immediately, discovers environment and test issues midway, wastes context, tokens, and time, accumulates unverified code, and future sessions repeat setup.

The fix is to separate initialization from implementation.

Initialization, ideally once per project:

1. Environment: install dependencies, and verify the application starts.
2. Tests: configure testing and linting, and make sure at least one test passes. The commands can live in one `build.sh` with subcommands such as `install`, `dev`, `test`, and `selftest`.
3. Documentation: `AGENTS.md` (commands and conventions) and `PROGRESS.md` (current state and next steps).
4. Tasks: break the work into small tasks with acceptance criteria.
5. Git checkpoint: commit the verified initialization state.

Every later session: read state → check the environment if needed → select the next task → implement → test → update progress → commit.

Success criterion: a fresh agent can start, test, understand progress, and continue without verbal explanation.

Key principle: initialize once, verify cheaply each session, and repeat setup only when the environment changes.

Dedicated initialization matters most for long-running, multi-session projects; for a small task in an already configured repo, a quick readiness check is usually enough.

For an app you also use daily, keep the stable version for regular use and make a separate development build with a "Developer" suffix, a distinct version, and a unique bundle ID, so the two do not conflict.

## Repo changes

- `docs/initialization.md`: created; the one-time procedure (idea, stack, environment, tests, docs, tasks, checkpoint, fresh session test), deleted at its own checkpoint step.
- `AGENTS.md`: the start section became a three-line Initialization pointer; Quick start is now restore state → readiness → take the next task → run, and no longer runs setup and the full verification every session.
- `scripts/check-ready.sh`: created; a fast offline readiness check (hooks enabled, environment unchanged since the last setup, runtime matches its pin).
- `scripts/setup.sh`: records an environment fingerprint through `scripts/check-ready.sh --record`.
- `scripts/restore-state.sh`: appends the readiness result, so Claude Code sessions see it at start and after compaction.
- `PROGRESS.md`: Next steps holds tasks in a fixed shape with acceptance criteria.
  Superseded by [07](07-why-agents-overreach-and-under-finish.md): tasks moved to a Tasks section and each carries a status.
- `scripts/verify.sh`: fails on a task without acceptance criteria.
- `.github/workflows/verify.yml`: runs `scripts/check-ready.sh` after setup, which proves setup records the fingerprint.
- `README.md`: Start a project now describes initialization.

## Design choices

Why initialization lives in `docs/initialization.md`, not `CONTRIBUTING.md` as first suggested:
`CONTRIBUTING.md` is, by convention, the standing guide for people contributing to an ongoing project, GitHub links it from every issue and pull request, and agents do not look there for instructions.
Initialization runs once and then should vanish, which is the opposite lifecycle.
A doc under `docs/`, linked from the repo map with "read when given a project idea", reaches the agent at exactly that moment, and the procedure's checkpoint step deletes it.

Why "verify cheaply" is a fingerprint, not a re-run of setup or the full suite:
setup can take minutes (dependency installs), and the full suite grows with the project.
Every commit already passed `scripts/verify.sh` through the pre-commit hook, so a clean checkout in an unchanged environment is already verified.
What can silently change between sessions is the environment, and a hash of the files that define it (`ENV_FILES`) detects that in milliseconds.
The fingerprint is stored per checkout under `.git`, so each worktree, with its own installed dependencies, tracks its own state.

Why readiness runs inside `scripts/restore-state.sh`:
the Claude Code hook already runs that script at every session start, so readiness arrives in context without the agent having to remember a step.

Why tasks carry acceptance criteria checked by `scripts/verify.sh`:
"select the next task" and "done" both need a task whose end is observable, and an unchecked format drifts into vague one-liners.
The check only requires the `Acceptance:` field; whether the criteria are good stays a judgement call.

Why no `build.sh` with subcommands:
the chapter offers it as one option.
`scripts/setup.sh`, `scripts/check-ready.sh` (the selftest), `scripts/verify.sh` (the test), and the Run command in Quick start (dev) already give one command per job; a dispatcher would add a layer without removing any.

Why the "Developer" build advice is a conditional step in initialization:
it applies only to apps the user also runs day to day, and it has to be decided when the build identity is first set up, which is during initialization.
