# 01 - Why capable agents still fail

## Notes

A capable model still fails when the harness around it is weak.
The harness is everything the agent works inside: the instructions, the environment, the checks, and what carries over between sessions.

Five failure modes:

| Failure | What goes wrong | Example |
| --- | --- | --- |
| Vague requirements | The goal is unclear, so the agent guesses. | "Add search": search what, how, returning what? |
| Unwritten conventions | A rule nobody wrote down cannot be followed reliably. | The team uses SQLAlchemy 2.0; the agent writes 1.x syntax. |
| Broken environment | Effort goes into setup instead of the task. | Wrong Node version, missing package. |
| No verification | Without a way to test success, the agent cannot know it is done. | No test, lint, or type-check command. |
| Cross-session state loss | Earlier work is forgotten and rediscovered every session. | Each new session re-learns the repo structure. |

The fix when something fails: do not swap the model first.
Find which part of the harness failed, ask why, fix that part, and re-run.

The simplest high-value starting point is an `AGENTS.md` (tech stack, architectural conventions, verification methods), an explicit Definition of Done, and automated verification commands.

## Repo changes

- `AGENTS.md`: created, with one section per failure mode plus the Definition of Done and the failure protocol.
- `CLAUDE.md`: created; imports `AGENTS.md`.
- `scripts/verify.sh`: created; the single verification command.
- `README.md`: explains how to start a project from the boilerplate.

## Design choices

Each failure mode maps to a section of `AGENTS.md`:

| Failure | Section | How it addresses it |
| --- | --- | --- |
| Vague requirements | Requirements | The agent restates the task as input, behaviour, output, and verification, and asks when any is missing. |
| Unwritten conventions | Tech stack, Conventions | Exact versions and API styles are written down; repeated corrections become rules or checks. |
| Broken environment | Environment setup | Fresh-clone setup commands are written down, and a setup failure is fixed in the repo instead of worked around. |
| No verification | Verification, Definition of Done | One command runs every check, and done means it passes and the behaviour was exercised. |
| Cross-session state loss | Repo map | A new session reads the map instead of re-learning the structure. |

Why a single `scripts/verify.sh` instead of listing commands only:
the Definition of Done can name one command, the agent never has to pick which checks apply, and each new check lands in one place.

Why `scripts/verify.sh` checks the repo map:
a stale map misleads more than a missing one, and the chapter's fix is to enforce rather than to remind.
The script fails when a listed path is missing or a top-level entry is unlisted, so the map cannot quietly drift.

Why the failure protocol is in `AGENTS.md` and not only here:
it changes what the agent does when a task goes wrong, so it belongs in the always-loaded file.

Not added yet: a progress log or session handoff file.
This chapter names cross-session state loss but only prescribes `AGENTS.md`; the repo map covers the structure half of it.
Revisit when a later chapter covers session state.
