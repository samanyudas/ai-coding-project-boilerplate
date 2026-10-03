# Progress

The state handoff between sessions; `scripts/restore-state.sh` prints it at session start.
Update it in the same commit as each completed unit of work, so a session that ends or compacts loses nothing.
It holds where things stand; git history holds the full record.

## In progress

TODO(project): The unit of work underway, and how far it got.

## Next steps

TODO(project): The ordered next units, each small enough to finish, verify, and commit in one go.

## Blockers

None.

## Done

Units finished since the current focus began, newest first, each with its commit.
Clear this list when the focus moves on.

- None yet.

## Test status

`scripts/verify.sh` passes at every commit; the pre-commit hook guarantees it.
List here only what that gate does not show:

- **Failing:** None. (Tests outside the gate that fail, with why.)
- **Pending:** None. (Tests skipped or not yet written, and what they wait on.)
