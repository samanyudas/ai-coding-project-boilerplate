# Cleanup

Every session leaves the repo clean, so the next one starts from working code and clear state instead of reconstructing what happened.
Debt that slips past a session is caught by a weekly scan before it compounds.

## Quick start

- **End of every session:** run `scripts/end-session.sh`. The session is not done until it passes.
- **Weekly:** `.github/workflows/maintenance.yml` opens a "Weekly cleanup" issue every Monday with the report from `scripts/scan.sh`; work through it with the weekly checklist below. Run `scripts/scan.sh` yourself to see the same report.

## Hard constraints

- Throwaway files (debug scripts, sample output, scratch notes) go in `.harness/scratch/`, which git ignores and `scripts/end-session.sh` deletes.
- Temporary debug code carries the marker `TEMP(debug)` followed by a colon, so it cannot be forgotten; `scripts/verify.sh` refuses any commit that still has one.
- A session ends with nothing uncommitted: commit each finished unit, or verified partial progress on the active feature, and discard the rest.

## Immediate cleanup: every session

Clean up each thing as soon as you are done with it, the way reference counting frees memory.
`scripts/end-session.sh` then confirms the handoff:

1. Deletes `.harness/scratch/`.
2. Checks the environment is ready (`scripts/check-ready.sh`).
3. Checks nothing is left uncommitted.
4. Checks the Active feature notes in `PROGRESS.md` mention the active feature, if there is one.
5. Runs every level of `scripts/verify.sh`: the build, the tests, the normal startup path, and every passing feature's flow.

It lists every problem it finds and exits non-zero until all are fixed.

## Context resets

A long session gets worse as its context window fills, and context once loaded cannot be freed.
Keep a session near 40% of its context window, and wrap up before it passes 60%.
These signs show a degraded session:

- The same tool call repeats three or more times with no change in result.
- The agent breaks a rule it followed earlier.
- The agent works on something other than the active feature.
- Edits get sloppier and miss more cases.
- The agent agrees by reflex ("You are absolutely right") instead of reasoning about the task.

When two signs appear, or the window nears 60%, do not push through:

1. Write the handoff in the active feature notes in `PROGRESS.md`: the goal, the approach, the steps done, and the current failure.
2. Commit verified progress, and discard the rest.
3. Start a fresh session, which `scripts/restore-state.sh` restores from disk.

## Periodic cleanup: weekly

A full pass over the whole system, the way a tracing collector finds what reference counting missed:

1. Read the scan report: verification, ASD-STE100 writing findings, size pressure, debt markers, features, review warnings, and benchmarks.
Review writing findings against `docs/documentation.md` before rewriting.
Resolve operational errors before treating the writing check as complete.
2. Fix structural issues: dead code, duplication, oversized files and modules, and each debt marker; record anything too big for now as a `not_started` feature.
3. Update quality docs that drifted: module `ARCHITECTURE.md` and `CONSTRAINTS.md`, topic docs, and `DECISIONS.md` entries that no longer hold.
4. Run the benchmarks and compare them with the baseline; treat drift beyond tolerance as a finding.
5. Slim the instructions: when `AGENTS.md` or a doc is near its limit, move a procedure agents keep repeating out of it into a reusable skill (for Claude Code, `.claude/skills/<name>/SKILL.md`) or a topic doc, and link it.
6. Commit the cleanup through the usual checks, and close the issue with a summary of what changed.

## Checklist

- [ ] `scripts/end-session.sh` passes before you end a session.
- [ ] Every weekly finding is fixed, or recorded as a `not_started` feature.
