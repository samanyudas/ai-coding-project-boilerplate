# Decisions

Project-wide decisions and why they were made, newest first.
`scripts/restore-state.sh` lists the headings at session start; open the entries that bear on your task.
A decision about one module goes in that module's `ARCHITECTURE.md` instead.

When a decision changes, add a new entry and add a `Superseded by` line to the old one, so the reasoning survives.
Every entry uses this shape, and `scripts/verify.sh` checks it:

```markdown
## YYYY-MM-DD: Short title

- **Decision:** What was chosen.
- **Why:** The reasoning that settled it.
- **Rejected:** Each alternative considered, and why it lost.
- **Constraints:** What limits this decision, and what would reopen it.
```

<!-- Entries start below, newest first. -->
