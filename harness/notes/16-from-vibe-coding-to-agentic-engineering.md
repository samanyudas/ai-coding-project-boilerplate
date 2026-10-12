# 16 - From vibe coding to agentic engineering

Source: chapter 1 of an O'Reilly Early Release book on agentic engineering.
Chapters 16 onward come from this book, so its chapter numbers differ from the note numbers.

## Notes

Agents can write working code.
The open question is who owns everything that happens after the agent writes it.

Vibe coding, as Andrej Karpathy defined it in February 2025, means you do not read the diff.
He described it for throwaway weekend projects.
It is a legitimate mode when a miss costs little, such as a migration on an unlaunched project with no users.
The danger is a reflex that carries across modes: "green means merge" learned on a migration and then applied to a payment path.
So the constraint must live in the repo config and the gates, not in your memory of which mode you are in.

One word covered two opposite workflows, so other names appeared:

- Vibe engineering (Simon Willison): experts use LLMs as collaborators and keep accountability for quality.
- Augmented coding (Kent Beck): you still own the quality and structure of the code while the agent types.
- Agentic engineering (Karpathy, February 2026): you orchestrate agents and act as oversight, and the work takes expertise.

The book uses five zones of discipline:

1. Pure vibe coding: no spec, review, tests, or owner.
2. Assisted vibe coding: you glance at the diff.
3. Where most professionals sit: a plan in your head, some review, some tests.
4. Full agentic engineering: spec first, every serious diff reviewed, tests gate the merge, clear ownership.
5. The fleet: zone 4 plus agents that review each other.

The most dangerous failure is sitting in zone 3 while you believe you are in zone 4.

The inner loop (write, run, adjust) got cheap.
The cost moved to the outer loop: decide, review, integrate, ship, watch production, and respond.
Dark factories (no human writes or reads the code) reached the top by deleting review and verification.
Their failures arrive late, because the deleted step was the one that would have reported them.
Faros AI telemetry shows volume up and quality down as adoption deepens.
Dex Horthy: "You don't have too many PRs, you have too many bad PRs."
Training signals grade tests, never maintainability.
His alternative is about an hour of upfront alignment, which lets agents implement two to three times faster at near-human quality.

Four pillars carry the discipline, and they fail together:

- Plan: write a short spec before you prompt.
If you cannot write a paragraph about the request, do not prompt yet.
- Direct: scope the task, and review diffs like a senior teammate's pull request.
Watch auth, security, and money closely whatever the spec quality.
- Test: write or review the tests yourself, so the agent cannot game its own scoreboard.
The agent that did the work never decides the work is good.
A verifier caught a "performance is fine" claim that rested on desktop numbers when mobile mattered.
- Own: CI gates the code, and a team answers for it.
Delegate the task, never the judgment: every check was green on changes that should not have shipped at all.

When starting from scratch, build the pillars in reverse: tests and CI, then ownership, then specs and scoped direction, and only then let agents run wide.

Tool generations stack instead of replacing each other: autocomplete, synchronous agents, and autonomous agents that need orchestration.
The differentiating work moved from the model to the harness (harness engineering, a term from Viv Trivedy).

Other points:

- Seniors gain more than juniors, because agents take the reps that used to build taste.
- METR's 2025 trial measured experienced developers 19% slower while they believed they were 20% faster.
The 2026 rerun landed near zero.
Leverage is real but smaller than the marketing, and it depends on the task and the discipline.
- Diverse reviewers beat one good reviewer: across 146 pull requests, 93.4% of issues were caught by exactly one of four tools.
- The load moves to decisions, it does not shrink.
A tired reviewer approves output that looks right, so the defense is structure: tests, gates, and second opinions.
- Agents amplify what a codebase already has, and agent-built codebases calcify into brownfield within months.

Tier discipline: grant an agent the autonomy you can check, per task.
Autonomy tracks who gets hurt when it is wrong, not technical difficulty.
On old code, build the verification first: make it build, make it type-check, and pin behavior with characterization tests.
As agents get more reliable, line-by-line review erodes, but accountability stays: a human answers for the code in production.

In one line: match the practice to the stakes, keep the constraint in the repo instead of in your head, and never delegate the judgment about what ships.

## Repo changes

- `docs/architecture.json`: a new `high_stakes` array of paths, each with a `why` that names who gets hurt.
- `scripts/verify.sh`: level 1 requires the `high_stakes` array, a `path` and `why` per entry, and that each path exists.
- `scripts/review-change.sh`: warns on every change to a `high_stakes` path that a human must read every line and approve the merge, and that the pull request must name the path.
- `docs/conventions.md`, `docs/initialization.md`: describe `high_stakes`, and initialization declares its paths.
- `docs/security.md`: a hard constraint that high-stakes changes get a human read of every line even when checks pass, and a checklist item.
- `docs/loops.md`: a "Match autonomy to stakes" section with three tiers, verification before autonomy on existing code, and "delegate the task, never the judgment".
The goal contract names changed high-stakes paths in its pull request.

## Design choices

Why stakes are declared by path rather than per feature:
the chapter's warning is a reflex that carries across modes, so the rule must fire on what the change touches, not on what the agent believes the task is.
A feature that "only adds a button" can still edit the payment module.
Paths are checkable by `scripts/review-change.sh` on every commit and in CI, with no judgment from the maker.

Why a review warning rather than a blocking gate:
the right response to a high-stakes change is a human reading it, which no script can confirm.
A gate would either block every legitimate change or be bypassed by habit.
The warning appears at commit time and in CI annotations, and the goal contract carries it into the pull request.

Why no `stakes` tier field on each feature:
a field the maker fills in would let the maker pick its own autonomy.
Tiers stay as guidance in `docs/loops.md`, and the only enforced tier is the one paths define.
