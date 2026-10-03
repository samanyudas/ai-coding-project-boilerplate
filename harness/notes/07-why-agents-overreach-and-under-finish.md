# 07 - Why agents overreach and under-finish

## Notes

The issue: a broad task leads the agent to attempt several features at once (scope creep).
Context and effort spread across unfinished work, which ends in incomplete implementations, failed tests, rework, and wasted tokens.

The fix is WIP = 1 (one task in progress):

- Break large features into small, independently verifiable tasks with clear acceptance criteria.
- Keep one active task at a time: implement → run end-to-end tests → verify → commit → start the next task.
- Track each task's status (`not_started`, `active`, `blocked`, `passing`) in `PROGRESS.md` so it survives across sessions.
- Record unrelated improvements as future tasks rather than implementing them immediately.

WIP = 1 is a useful default per agent, not a universal rule.
Independent agents can work in parallel on isolated tasks when dependencies and integration are managed.

## Repo changes

- `PROGRESS.md`: In progress, Next steps, Blockers, and Done merged into one Tasks list, each task a line with its status; In progress became Active task notes, for how far the active task got.
- `scripts/verify.sh`: each task needs a known status, a bold title, and acceptance criteria; a `blocked` task needs "Blocked by:"; more than one `active` task fails.
- `AGENTS.md`: hard constraint 5 is WIP = 1 with new findings recorded as `not_started` tasks; hard constraint 6 makes WIP = 1 per agent, with parallel agents on separate branches and worktrees; Quick start continues the active task or activates the next; the Definition of Done marks the task `passing` and requires the goal exercised end to end.
- `docs/testing.md`: a task becomes `passing` only when a test checks its acceptance criteria end to end.
- `docs/initialization.md`: initial tasks go in as `not_started`, independently verifiable.

## Design choices

Superseded by [08](08-feature-lists-as-harness-primitives.md): the task list moved out of `PROGRESS.md` into `docs/features.json`, and only `scripts/feature.sh` changes a state. WIP = 1, the statuses, and the parallel-agent rule carried over.

Why one Tasks list instead of separate sections:
with a status on every task, In progress, Next steps, Blockers, and Done were the same list filtered four ways.
One list in priority order keeps a single place to look, and a status change is a one-word edit instead of moving a line between sections.

Why WIP = 1 is a check, not only a rule:
scope creep is the failure, and the agent drifting into a second task is exactly when it will not reread a rule.
`scripts/verify.sh` counts `active` tasks, so a commit with two active tasks is refused by the hook.

Why "record it as a task" is a hard constraint:
noticing something unrelated happens in every kind of task, so it is global.
Writing it down gives the agent a cheap, legitimate place to put the urge, which is what keeps the active task's diff small.

Why WIP = 1 is per agent and per branch:
`PROGRESS.md` lives on each agent's branch, so the check runs per checkout.
Parallel agents each mark a different task `active` in their own copy, and merging finished branches turns those tasks `passing`.

Why `blocked` requires "Blocked by:":
a blocked task without its reason is rediscovered from scratch by the next session, which is the cross-session loss chapter 5 set out to stop.

Why "passing" carries no commit hash:
the task is marked `passing` in the same commit as its work, so the hash does not exist yet; `git log` finds it.

Why the task shape uses a double-backtick span for its example:
the example itself contains backticks, and a double-backtick code span shows them without invisible escape characters.
