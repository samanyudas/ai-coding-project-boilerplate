# Progress

The session handoff for the active feature; `scripts/restore-state.sh` prints it at session start.
Feature scope and states live in `docs/features.json`, and git history holds the full record.
Update it in the same commit as each unit of work, so a session that ends or compacts loses nothing.

## Active feature notes

Before writing code, the agent writes the feature's plan here:

- The acceptance criteria and invariants, restated in its own words.
- The steps in order, with the files each one changes.
- Similar code or earlier attempts to reuse or avoid.
- Assumptions, and open questions with a first move against each.
- The edge of scope: if the work needs other files or a `high_stakes` path, stop and record why here.

In an interactive session, a human approves the plan for a feature that takes 30 minutes or more.
The same applies when it touches three or more files or changes a public interface.
A plan that misreads the feature needs a better reading, and a correct plan for an unwanted result needs a better feature.
The plan is frozen for the run, and a change to it is a new agreement.

Below the plan, the agent records progress, attempts, failures with their causes, and the remaining work.
When the context window nears 60% full, or the signs in `docs/cleanup.md` appear, write that state and start a fresh session.
Clear these notes when the feature passes.

TODO(project): Notes on the active feature, or "No active feature."
