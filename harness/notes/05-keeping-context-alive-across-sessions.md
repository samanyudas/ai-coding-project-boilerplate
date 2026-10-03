# 05 - Keeping context alive across sessions

## Notes

Especially needed in Claude Code.
Anthropic expects the 1 million token context window to do most of the heavy lifting, so compaction gets little research priority (Theo).

Without persistent state, context compaction makes the agent forget important things and drift.
It then rereads files, reruns tests, and re-derives reasoning, which burns tokens, time, and money.

The fix is state persistence:

| Artifact | Holds |
| --- | --- |
| `AGENTS.md` | Instructions for restoring and saving state |
| `PROGRESS.md` | Done, in progress, blockers, next steps, and test status (pass, fail, pending) |
| `DECISIONS.md` | Date, decision, reasoning, rejected alternatives, and constraints |
| Git checkpoint | The exact repository state; commit after each completed, verified unit of work |

The workflow: session starts → read state files → verify repo → continue work → run tests → update state files → commit completed work → the next session resumes.

## Repo changes

- `PROGRESS.md`: reshaped into In progress, Next steps, Blockers, Done, and Test status.
  Superseded by [07](07-why-agents-overreach-and-under-finish.md): In progress, Next steps, Blockers, and Done became one Tasks list with a status per task.
- `DECISIONS.md`: created, with a fixed entry shape that `scripts/verify.sh` checks.
- `scripts/restore-state.sh`: created; prints `PROGRESS.md`, the `DECISIONS.md` headings, and the git checkpoint, and flags uncommitted changes.
- `.claude/settings.json`: created; a `SessionStart` hook that runs `scripts/restore-state.sh` on every start, including after compaction.
- `scripts/check-module-docs.sh` renamed to `scripts/check-stale-docs.sh`; it now also warns when a commit in a started project leaves `PROGRESS.md` untouched.
- `AGENTS.md`: Quick start follows the chapter's workflow (restore state, verify the repo, then work); hard constraint 4 now commits each verified unit at once, with `PROGRESS.md`; `DECISIONS.md` joined the routing table; the failure protocol moved to `docs/harness-audit.md` to stay under 100 lines.
  Superseded by [06](06-initialization-as-its-own-phase.md): the session-start `scripts/verify.sh` run became the cheap `scripts/check-ready.sh`, and `scripts/setup.sh` runs only when that check asks for it.

## Design choices

Why a Claude Code hook restores state, and not only an instruction:
compaction happens mid-task without warning, and an instruction to re-read state is exactly what compaction makes the agent forget.
A `SessionStart` hook fires on every start, including the start that follows compaction, and puts the state straight into context.
Other agent tools run the same script by following Quick start step 2.

Why state is saved at every commit, not at session end:
compaction and crashes do not wait for a session to end.
Hard constraint 4 ties the `PROGRESS.md` update to each verified unit, and `scripts/check-stale-docs.sh` reminds when a commit skips it, so the most a session can lose is the unit in progress.

Why the restore script lists only `DECISIONS.md` headings:
the decision log only grows, and loading it whole every session is the discovery cost chapter 3 warns about.
Headings let the agent open the entries that bear on its task.

Why decisions are superseded, not edited:
the rejected alternatives and old constraints are what stop a future session from reopening a settled question.
A new entry plus a `Superseded by` line keeps that reasoning.

Why Test status lists only what the gate does not show:
every commit passes `scripts/verify.sh`, so "pass" is always true at a checkpoint.
The useful state is what sits outside the gate: tests that fail outside it, and tests skipped or still to write.

Why `PROGRESS.md` has a Done list despite git history:
the chapter asks for it, and a short list of what the current focus has finished saves reading the log.
It is cleared when the focus moves on, so it cannot become the sediment chapter 2 warned about.
Superseded by [07](07-why-agents-overreach-and-under-finish.md): finished work is a `passing` task, removed once the focus moves on.

Why the `DECISIONS.md` check spells out `[0-9][0-9][0-9][0-9]` instead of `[0-9]{4}`:
CI runs on Ubuntu, whose default `awk` (mawk) may not support interval expressions.

Why the `PROGRESS.md` reminder applies only once `harness/` is gone:
the boilerplate keeps `PROGRESS.md` as a template, so the reminder would fire on every boilerplate commit.

Not added: a `PreCompact` hook that saves state.
A hook cannot write the agent's understanding into `PROGRESS.md`; only the agent can, which is why saving is tied to each commit instead.
