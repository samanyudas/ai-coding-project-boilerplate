# 12 - Why every session must leave a clean state

## Notes

The issue: an agent finishes a session but leaves the repo messy, with a broken build or tests, stale debug files, and unclear progress.
The next session wastes time reconstructing what happened, and technical debt compounds.

The fix makes a clean handoff part of "done":

- The build passes.
- All tests pass.
- Progress and feature state are updated.
- Temporary and debug artifacts are removed.
- The normal startup path still works.

Cleanup has two modes:

- **Immediate cleanup, at the end of every session:** clean up the session's temporary artifacts, update the feature list state, and make sure the build and tests pass. Like reference counting, it frees each thing as soon as you are done with it.
- **Periodic cleanup, weekly:** a full-system scan that handles accumulated structural issues, updates quality documents, and runs benchmark tests to detect drift. Like a tracing collector, it is a comprehensive pass on a regular cadence.
  A skill can help clean up a bloated `AGENTS.md` into reusable skills based on what agents actually do. (The specific skill linked in the notes did not come through.)

In one line: a messy session exit makes the next agent recover context and inherit debt; enforce a clean-state exit checklist before a session counts as complete.

## Repo changes

- `scripts/end-session.sh`: created; deletes `.harness/scratch/`, then fails unless the environment is ready, nothing is uncommitted, the active feature is in the progress notes, and every verification level passes.
- `scripts/verify.sh`: level 0 refuses temporary debug code marked `TEMP(debug)` with a colon; limits moved to `scripts/lib/limits.sh`.
- `scripts/scan.sh`: created; the weekly report covering verification, size pressure (80% of a limit), debt markers, features, a week of review warnings, and a benchmarks slot.
- `.github/workflows/harness-audit.yml` renamed `.github/workflows/maintenance.yml`; it opens a "Weekly cleanup" issue every Monday with the scan as its body, and the monthly audit issue as before.
- `docs/cleanup.md`: created; scratch and debug-marker rules, what the session-end check does, and the weekly checklist, including moving repeated procedures into skills.
- `AGENTS.md`: the Definition of Done ends with the session-end check; the routing table moved to `docs/documentation.md`, leaving a two-line pointer, which took the file from 100 lines to 89.
- `docs/harness-audit.md`: points at the renamed workflow.

## Design choices

Why the session end is a script, and not only a checklist:
"done" is exactly when an agent wants to stop reading rules.
`scripts/end-session.sh` turns each item on the clean-handoff list into a check that names what to fix, and runs all of them, so one command answers "can I stop?".

Why it is not a Claude Code `Stop` or `SessionEnd` hook:
`Stop` fires at the end of every turn, so a full verification there would run constantly; `SessionEnd` cannot block and its output never reaches the agent.
The Definition of Done item is the trigger, and the script makes it cheap to follow.

Why temporary debug code gets a marker instead of language-specific patterns:
the boilerplate has no language, and patterns like `console.log` have legitimate uses.
An explicit marker is unambiguous in any language, and the level 0 check makes forgetting it impossible to commit.
Markdown is excluded so docs can name the marker.

Why `.harness/scratch/`:
throwaway files need a home that git ignores and something deletes, so they never show up as "unrelated untracked files" the next session has to judge.

Why the weekly scan opens an issue with a report instead of fixing things:
structural cleanup needs judgement, but finding the candidates does not.
The scan does the finding on a schedule, so the weekly pass starts from evidence (size pressure, debt markers, review warnings) rather than a blank page.

Why the routing table moved out of `AGENTS.md` now:
`AGENTS.md` had reached exactly its 100-line limit, which the new scan flags as size pressure.
The table is consulted only when adding a rule or knowledge, which is the same moment `docs/documentation.md` is read, so it moved there, applying this chapter's own weekly step.

Why limits moved to `scripts/lib/limits.sh`:
`scripts/verify.sh` enforces them and `scripts/scan.sh` reports pressure against them, so they need a single source.
