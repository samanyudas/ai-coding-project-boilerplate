# 14 - From single loops to graph engineering

## Notes

The issue: one loop is one agent doing everything in one context window.
As tasks grow, four questions appear that a loop cannot answer cleanly:

- Division of labour: who goes first?
- Parallelism: what can run at the same time?
- Rollback: on failure, go back where?
- Handoff: how do several agents see the same data?

Single loops also fail structurally at scale, because the checker and the producer share one brain, so checkpoints inside the loop cannot fix:

- Goodhart: the metric goes up while the real outcome gets worse (a support bot learns to close tickets instead of fixing them, and churn doubles).
- Blindness upward: a loop never asks whether its goal is the right one.
- Conflict: independent loops fight each other (speed against thoroughness, growth against quality).

The fix is graph engineering: break the monolithic loop into an explicit graph.

- Nodes are units of work: code, a model call, a tool, a full agent with its own loop, or a human approval.
- Edges are handoffs: parallel, conditional, retry, or rollback.
- Shared state is one common workspace (requirements, code, results); each node's context stays private, and only the state is shared.
- Routing rules decide what runs next (verify passes → merge; fails → implement; not enough information → research).

It is a stack, not a replacement: prompt → context → loop → graph, each layer inside the next, with the harness underneath.
A loop defers decisions: cheap, but failures stay hidden, which suits exploration.
A graph makes decisions up front: readable, auditable, and locally repairable, which suits production.
A workflow is the fully deterministic special case of a graph; what is new is that nodes became cheap agents.

The verify node must get a fresh context: it sees only the code in shared state, never the implementer's reasoning.
Anchors pin loops to reality (real business outcomes, ground-truth data, human spot-checks); they are the most skipped part.

Four design questions come before drawing: which loops feed which, who owns the targets, who can veto or roll back, and which metrics may move and which must stay frozen.
Build steps: define the shared state and merge rules → list the nodes, each an agent with its own loop → wire the edges → write the routing rules (most important) → attach checkpoints and a human pause before merge → run with a thread id; then diff `graph.md` against the code, where any mismatch is a visible bug.

A graph is worth it only when at least three of these hold: the work splits into independent units, there are branch or rollback paths, intermediate state is worth saving, each node's result is verifiable, and the coordination benefit exceeds its cost.
Many linear steps are not a graph, only a workflow or a script.

Cold water: the "+18% accuracy, −85% cost" claim is fake, so always ask for the original source.
The shape is not the load-bearing wall; replayability, observability, and recoverability are.
Starting agents is cheap and reviewing their output is expensive: you are the single serial lock, and more nodes do not add judgment.

In one line: a single loop has one brain that does everything and grades itself, so failures stay hidden; use an explicit graph with independent verify nodes and anchors to reality, only where there are real branches, rollbacks, or parallelism, and remember your review bandwidth is still the ceiling.

## Repo changes

- `docs/graph.md`: created; this repo's process as a graph: shared state with merge rules and the branch as thread id, nine nodes with what implements each, routing rules with retry and rollback edges, the four design questions answered, anchors, when a graph is worth it, what carries the weight, and the build steps.
- `scripts/verify.sh`: level 0 checks that every path `docs/graph.md` names exists, skipping git-ignored runtime paths.
- `scripts/review-change.sh`: warns when the `behavior` or `verify` of a feature that was passing changes or the feature is removed.
- `.claude/agents/evaluator.md`: receives only the feature id and disregards any account of what was built.
- `docs/loops.md`: the goal contract runs on its own branch, gives the evaluator only the id, blocks a feature after three failed attempts on one cause, never changes passing contracts, and ends in a pull request rather than a merge; it links `docs/graph.md` and caps parallel loops at your review capacity.
- `AGENTS.md`: the repo map links `docs/graph.md`; the Definition of Done gives the evaluator only the feature id.

## Design choices

Why the graph describes the existing process rather than adding an orchestrator:
by the chapter's own test, this repo's feature work already meets it (independent features, retry and rollback paths, saved state, verifiable nodes), but the graph existed only implicitly across scripts and docs.
Making it explicit gives each of the four questions a written answer and makes mismatches visible; a runtime orchestrator would add the orchestration tax without adding judgment.

Why only paths are checked against the code:
a full comparison of routing prose against scripts is not mechanical, but a node pointing at a script or subagent that no longer exists is, and that is the most common drift.
Git-ignored paths are skipped because they appear only at runtime.

Why the Goodhart guard watches passing contracts:
the cheapest way for a maker to raise "features passing" is to weaken a check that already passes.
A passing feature's `behavior` and `verify` are the frozen metric, owned by a human, so any change to one is surfaced in the hook and as a pull request annotation, where the human pause can catch it.
It warns rather than blocks because refining a contract is sometimes right; the point is that it never happens silently.

Why the evaluator ignores what the caller says:
a fresh context only helps if nothing from the implementer leaks into it; "I fixed the login bug, just check the form" steers the review.
Stating the rule in the evaluator's own brief holds even when the caller forgets it.

Why loops now end in a pull request:
the chapter's build steps put a human pause before merge, and the anchors include a human spot-check.
A loop working on `main` would skip both; a branch per run is also the thread id that makes the run replayable.
This boilerplate itself still commits to `main` directly, because each chapter is reviewed by its owner as it lands.

Why the retry cap is three attempts on one cause:
a loop that retries the same failing approach forever is blind; three attempts on one cause is enough to show the approach, not the details, is wrong, and blocking hands the problem to a human with its reason.
