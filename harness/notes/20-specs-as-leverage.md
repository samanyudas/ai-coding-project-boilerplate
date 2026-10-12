# 20 - Specs as leverage

Source: chapter 5 of the O'Reilly Early Release book on agentic engineering.

## Notes

Every ambiguity left in a spec is resolved without you, once per agent that reads it.
One paragraph sent to five agents in five worktrees produced five working PRs that solved five different problems.
The author wrote one spec, and the agents filled in the other four.

Vagueness branches: one fuzzy spec against N agents gives N differently mediocre PRs.
Vagueness rarely looks vague.
"Use the usual auth" hides three auth paths.
"Handle errors appropriately" decides nothing, and "make it fast" sets no number, so any number satisfies it.

A headless agent never asks a follow-up question.
It completes the spec as written and fills the gaps with plausible patterns from the codebase.
Cheap generation removed the old limit on ambiguity: 100 implicit decisions are all resolved, plausibly and wrongly, before your coffee cools.
Horthy: a bad line of code is one bad line, a bad line of a plan is hundreds, and a bad line of research is thousands.
Spend attention before the code exists.

### What a spec contains

Seven categories, held under about 800 words for a feature:

1. Goal: what and why in one paragraph, which also breaks ties between implementations.
2. Acceptance criteria: each checkable by looking at the result.
3. Edge cases and invariants: what must stay true however the work is done.
4. Integration boundaries: what is in and out of scope, and what to do at the wall ("stop and say so in the plan").
5. Definition of done: what gets the PR merged, including process.
6. Notes and prior art: what a senior would say over coffee, such as "we tried streaming and dropped it, see PR #2104".
7. Open questions, each with a first move to reduce it.

No tech stack, API design, or file-by-file plan: say what success looks like and what must not break, and let the agent propose the plan.
A smallest version is a well-formed goal: a target number, an invariant, an abort condition, and a turn budget.

Writing a spec is making decisions, not documenting them.
Writing a good spec takes architecture knowledge: invariants, boundaries, and done all come from knowing what could break.

### Three shapes

- One-shot: 100 to 300 words, one agent, one PR.
A spec longer than the expected diff is too long.
- Feature: 500 to 1,000 words, several PRs or agents.
Have the agent critique the spec for ambiguities before any code.
Carve ownership unambiguously, or parallel work collapses into merge conflicts.
- Initiative: a 2,000 to 5,000 word design doc with a named owner and a refresh cadence, and a tree of feature specs beneath it.

### The sprint contract

Agree on a definition of done before generation starts, written to a file and checkable by an outside observer.
The agent writes a plan and stops: it restates the criteria, lists ordered steps with files, states assumptions, and flags open questions.
You read it, push back, and approve it before implementation.
The plan separates two failures: the agent misread a clear spec, or the agent read it correctly toward a result you do not want.
The contract freezes for the run, and changing done mid-flight is a new negotiation.
Skip the contract for work under 30 minutes, under three files, or with no public interface change.

### Antipatterns

The vague spec, the kitchen-sink spec, the spec that hides assumptions ("follow our conventions"), the spec the agent can game ("all tests pass"), the spec that prescribes the implementation, the spec that is a complaint, and the stale spec.
Write for a reader that will never raise its hand.
The spec carries intent, not taste: green checks could not show that the author's competitor-inspired PRs should not exist.

### Where the spec lives

The spec is not `AGENTS.md`.
The rulebook holds durable rules read every session, and a spec briefs one piece of work.
When an agent finishes, ask it to list which acceptance criteria it met and where in the diff.
Training never penalizes eroding maintainability, so the spec is the only place to encode the invariants and architectural intent the model was never trained to protect.

In one line: front-load the decisions in a short, checkable spec with invariants and boundaries, have the agent propose a plan you approve, and verify against the spec rather than your memory.

## Repo changes

- `docs/features.json` contract: an optional `invariants` array joins `behavior` and `verify`.
`scripts/verify.sh` checks that it is an array of non-empty strings.
- `scripts/review-change.sh`: a passing feature's `invariants` are frozen like its `behavior` and `verify`.
A new or changed contract with a vague word ("appropriately", "fast", "clean", "robust", "as needed", and others) gets a warning to replace it with a number, a list, or an example.
- `.claude/agents/evaluator.md`: each invariant is a requirement the evaluator checks.
- `docs/graph.md`: the frozen contract includes `invariants`.
- `docs/initialization.md`: `behavior` is written as checkable acceptance criteria, and invariants are described with examples.
- `PROGRESS.md`: the active feature notes open with the plan: criteria and invariants restated, ordered steps with files, prior art, assumptions and open questions, and the edge of scope.
A human approves the plan in an interactive session for work over the chapter's 30-minute, three-file, or public-interface threshold.
- `AGENTS.md`: Quick start step 3 writes the plan before code, replacing "state its input, behavior, output, and verification method as a concrete goal".

## Design choices

Why invariants join the feature contract instead of a separate spec file:
features here are small enough to finish in one session, which matches the chapter's one-shot shape.
For that shape, `behavior` is the acceptance criteria, `verify` is the definition of done, and `invariants` add the one category the contract lacked.
The other categories (prior art, assumptions, open questions, boundaries) belong to the plan for one run, so they live in `PROGRESS.md`, not in the frozen contract.

Why no `docs/specs/` directory:
an initiative spec is the project paragraph in `AGENTS.md` plus the ordered feature list.
A project that grows feature specs larger than one session can add `docs/specs/`, linked from the repo map as `docs/documentation.md` requires.
Adding an empty directory now would be scaffolding without a user.

Why the vague-word check warns instead of blocking:
a word list cannot tell "fast" in "fast-forward" from "make it fast".
A reviewer sees the warning at commit time and in CI, which is enough for a contract only a human writes.

Why the plan approval applies only in interactive sessions:
a goal loop runs unattended by design, and the human already approved each feature's contract when writing it.
In a loop, the evaluator holds the other side of the contract, and the pull request is where the human reviews the result.
