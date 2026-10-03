# Progress

The state handoff between sessions; `scripts/restore-state.sh` prints it at session start.
Update it in the same commit as each completed unit of work, so a session that ends or compacts loses nothing.
It holds where things stand; git history holds the full record.

## Tasks

WIP = 1: one task is `active` at a time; finish, verify, and commit it before starting the next.
Anything else you notice along the way goes in as a new `not_started` task, not into the active one.
Order is priority, so take the first `not_started` task, and remove `passing` tasks once the focus moves on.
Each task is one line in this shape; `scripts/verify.sh` checks the shape, the status, and that at most one task is `active`:
`` - `status` **Title.** Acceptance: the observable result, and how it is checked. ``
Statuses: `not_started`, `active`, `blocked` (add "Blocked by:" and what it waits on), and `passing`.

TODO(project): The first tasks, written during initialization.

## Active task notes

How far the active task got, what was tried, and what is left. Clear it when the task passes.

TODO(project): Notes on the active task, or "No active task."

## Test status

`scripts/verify.sh` passes at every commit; the pre-commit hook guarantees it.
List here only what that gate does not show:

- **Failing:** None. (Tests outside the gate that fail, with why.)
- **Pending:** None. (Tests skipped or not yet written, and what they wait on.)
