# Graph

This repo's development process as an explicit graph: who goes first, what runs in parallel, where a failure goes back to, and how agents share data.
A single loop defers those decisions and hides its failures; written down, they are readable, auditable, and repairable one node at a time.
`scripts/verify.sh` checks that every path named here exists; any other mismatch between this file and the scripts is a bug, so fix whichever is wrong.

## Hard constraints

- The verify nodes get a fresh context: the evaluator receives only the feature id and judges the code and the running project, never the implementer's reasoning.
- Nodes share data only through the shared state below; each node's own context stays private.
- A passing feature's contract (`behavior` and `verify`) is a frozen target that only a human changes; `scripts/review-change.sh` flags any change to one, so the metric cannot be bent toward the maker.
- A loop's branch reaches `main` only through a human pause: a pull request that a person reviews.

## Shared state

| State | Holds | Written by | Merge rule |
| --- | --- | --- | --- |
| `docs/features.json` | Scope, each feature's contract, state, and evidence | A human writes contracts; `scripts/feature.sh` changes states | Keep every feature from both sides; after a merge, `scripts/verify.sh` re-runs every passing flow |
| `PROGRESS.md` | Notes on the active feature | The implementer | Keep the target branch's notes, adding the merged feature's outcome |
| `DECISIONS.md` | Decisions and their reasons | Any node, with reasons | Append-only: keep both sides' entries |
| Git history | Code and tests | The implementer, through the pre-commit gate | Merge only when `scripts/verify.sh` passes on the merged result |
| `.harness/runs/` | Run evidence | The scripts | Per checkout; never merged |

The thread id of a run is its branch name: one branch per loop run, so its commits and evidence can be replayed and audited together.

## Nodes

| Node | Kind | Does | Implemented by |
| --- | --- | --- | --- |
| Plan | Human | Writes features: behavior, verify command, priority | `docs/features.json` |
| Pick | Code | Says what remains and activates the next feature | `scripts/feature.sh` (`remaining`, `start`) |
| Implement | Agent with its own loop | Writes the code and tests for the active feature | A maker session following `AGENTS.md` |
| Research | Agent | Answers what the implementer cannot decide alone | A fresh session or subagent; findings go to `DECISIONS.md` |
| Check | Code | Levels 0 to 2, then the feature's flow | `scripts/feature.sh` (`verify`), `scripts/verify.sh` |
| Evaluate | Agent, fresh context | Walks the flow on the running project; returns PASS or FAIL with evidence | `.claude/agents/evaluator.md` |
| Commit | Code | Gates and records the unit | `.githooks/pre-commit` |
| Block | Code | Parks a feature that cannot pass, with its reason | `scripts/feature.sh` (`block`) |
| Review | Human | Approves or rejects the branch | A pull request |

## Routing rules

| After | When | Go to | Edge |
| --- | --- | --- | --- |
| Pick | A feature remains | Implement | Sequential |
| Pick | `scripts/feature.sh remaining` exits 0 | Review | Conditional |
| Implement | The behavior is ambiguous, or information is missing | Research, then back to Implement | Conditional |
| Implement | The code and tests are written | Check | Sequential |
| Check | A level or the flow fails | Implement, starting from the failing log | Retry |
| Check | Everything passes | Evaluate | Sequential |
| Evaluate | FAIL | Implement, with the verification report | Retry |
| Evaluate | PASS | Commit, then Pick | Sequential |
| Implement | Three attempts failed on the same cause, or the blocker is outside the code | Discard the attempt (`git restore`), Block, then Pick | Rollback |
| Review | Rejected | Implement, on the same branch | Rollback |
| Review | Approved | Merge into `main` | Sequential |

Pick can hand independent features to parallel Implement nodes, each on its own branch and worktree (hard constraint 5); they meet again only at Review.

## Design questions, answered here

1. **Which loops feed which?** Plan feeds the feature loop; the weekly cleanup (`docs/cleanup.md`) feeds Plan with `not_started` features.
2. **Who owns the targets?** A human: each feature's `behavior` and `verify`, and the limits in `scripts/lib/limits.sh`.
3. **Who can veto or roll back?** The scripts veto every commit, the evaluator vetoes a feature, and the human vetoes the merge; any node rolls back a failed attempt with `git restore`.
4. **Which metrics may move, and which stay frozen?** The code and the count of passing features move. Passing contracts, the verification levels, and the limits stay frozen unless a human changes them, with a `DECISIONS.md` entry.

## Anchors

Pin every loop to reality, or it optimizes the metric instead of the outcome (Goodhart: a support bot that learns to close tickets instead of fixing them).

- Each `behavior` is a user outcome, not a code property.
- The evaluator walks the real interface, not the test suite.
- Test data comes from ground truth (real formats, recorded examples), not from what the implementer assumed.
- A human spot-checks each branch at Review, and owns whether the goal itself is still right, which no loop asks.

## When a graph is worth it

Use one only when at least three of these hold; otherwise a single loop or a script is enough, and many linear steps are just a workflow:

1. The work splits into independent units.
2. There are branch or rollback paths.
3. Intermediate state is worth saving.
4. Each node's result can be verified.
5. The coordination benefit outweighs its cost.

## What carries the weight

The shape is not the load-bearing wall; replayability, observability, and recoverability are.
Here they are the branch and its commits, `.harness/runs/`, and the state on disk with `scripts/restore-state.sh`.
Starting agents is cheap and reviewing their output is not: your review is the single serial lock, so run no more parallel branches than you can review.
Treat headline gains from orchestration as unproven until you have read the original source.

## Building a new graph

1. Define the shared state and its merge rules.
2. List the nodes, each with its own loop.
3. Wire the edges.
4. Write the routing rules; they matter most.
5. Attach checkpoints, and a human pause before merge.
6. Run it with a thread id (a branch), then compare this file with the code and fix every mismatch.

## Checklist

- [ ] Every node in the graph you changed names what implements it, and `scripts/verify.sh` passes.
- [ ] The evaluator was given only the feature id.
- [ ] No passing contract changed without a human's approval.
