# 09 - Why agents declare victory too early

## Notes

The issue: the agent declares completion prematurely.
Unit tests pass, but integration, runtime, or end-to-end functionality is still broken.

The fix is an independent Definition of Done enforced by the harness, in levels:

1. Lint and type-check.
2. Unit and integration tests, plus startup checks.
3. End-to-end user flow verification using computer use.

- A feature is complete when end-to-end verification passes, not when the code is written.
- Do not proceed to level 2 if level 1 fails.
- Do not proceed to level 3 if level 2 fails.

Workflow: implement → verify → detect failures → give actionable feedback → fix → retest → declare done only when all required checks pass.

## Repo changes

- `scripts/verify.sh`: restructured into gated levels: 0 harness (the repo's own rules), 1 static (`run_static`), 2 tests and startup (`run_tests`, `run_startup`), 3 end to end (every `passing` feature's flow).
It stops at the first failing level, names the failed checks, and says later levels did not run; `--upto <level>` gives a fast inner loop.
- `scripts/feature.sh`: `verify` runs levels 0 to 2 first and only then the feature's end-to-end flow, so `passing` implies every lower level passed.
- `AGENTS.md`: the Definition of Done lists the three levels with a slot for each level's commands, and adds walking the user flow yourself with computer use or a browser; repo map lines were merged to stay under 100 lines.
- `docs/testing.md`: a Verification levels section (what each level proves and where it lives), how to drive flows for each kind of interface, and a slot for the end-to-end tool.
- `docs/initialization.md`: set up an end-to-end tool and computer use or browser access during initialization, and break each level on purpose to see it stop there.
- `docs/harness-audit.md`: the feedback check breaks each level on purpose.

## Design choices

Why a level 0 for the harness's own checks:
the repo map, doc sizes, decisions, and feature list are as cheap as lint and must hold before anything else means anything, so they gate level 1 the way level 1 gates level 2.

Why each project check runs in its own `set -e` subshell:
inside a function called from `if` or `||`, bash ignores `set -e`, so `npm run lint; npm run typecheck` would report only the type-check and silently hide a lint failure.
Running each check as a plain subshell statement keeps `set -e` live, so the first failing command fails the check.

Why a level runs all its checks before stopping, instead of stopping at the first:
the chapter asks for actionable feedback; seeing every failure in a level at once saves a fix-and-rerun round trip, while the gate between levels still holds.

Why `scripts/feature.sh verify` runs levels 0 to 2 itself:
"do not proceed to level 3 if level 2 fails" has to hold when a feature is marked `passing`, not only at commit time.
Otherwise a feature could be marked `passing` on a working flow while lint or unit tests were broken, which is exactly the early victory the chapter describes.

Why the computer-use walk is a Definition of Done item and not a script:
a scripted flow checks only what it asserts.
An agent looking at the running app catches layout, copy, and states no test reaches, which is the gap between "tests pass" and "it works".
No script can prove the walk happened, so it stays a checklist item next to the scripted flows that run on every commit.
Superseded by [13](13-from-manual-prompting-to-autonomous-loops.md): the walk is now done by an independent evaluator (the `evaluator` subagent), not the agent that wrote the code.

Why startup is its own check at level 2:
"the code compiles and the tests pass, but the app does not start" is the most common early victory, and only actually starting it catches that.
