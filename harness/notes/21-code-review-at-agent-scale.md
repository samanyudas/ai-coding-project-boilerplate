# 21 - Code review at agent scale

Source: "How the Claude Code team does code review", a post from the Claude Code team at Anthropic.

## Notes

Claude writes about 90% of the code for Claude Code, so line-by-line human review cannot keep up.
Between June and September, merged pull requests more than doubled while the share that had to be reverted fell by more than 40%.
Anthropic's monorepo went from about 2,500 merged changes a day in May to over 30,000 in September.
The team did not stop reviewing.
It moved most of the reading to automation, tuned it to save human attention, and made reverting a mistake fast and cheap.

### The goal of review

Review has two jobs: catch bugs before they ship, and spread an understanding of the codebase.
"Did someone read the code?" is a weak proxy for the real question: what could go wrong with this change, and which check, automated or human, should catch it?
Review stopped being a gate after the pull request and became a running check while the code is written, like a spellchecker.
Most changes have been reviewed and fixed by Claude at least once before a human sees them.

Human time is a two-sided cost: the time spent reviewing plus the time spent fixing bugs that bad code let through.
Cutting the first while the second grows saves nothing, because it only moves the work.
The target is that most pull requests merge with at most one human in the loop, who may be the author, with no rise in reverts or incidents.
The team tracks median and 95th-percentile human approvals per pull request, human comments, and time a pull request waits on a person.
Revert and incident rates are the guardrail on those numbers.

### Layers, not one gate

Each layer catches some bugs and misses others, so few bugs pass all of them, and rollback handles the rest.

1. Pre-PR verification.
The agent must run something (tests, the build, a screenshot compared with the design) and show the result instead of saying it is done.
Then a subagent with fresh context reviews the diff.
Boris Cherny estimates that a verification process improves Claude's output two to three times, and the process differs by domain: a command, a test suite, or a browser or simulator.
When the reviewer keeps flagging the same issue, fix it at the source: the skill, a lint rule, `CLAUDE.md`, or `REVIEW.md`.
`CLAUDE.md` is loaded into every review, so it stays short and links the rest, and the reviewer flags code that breaks its conventions or makes it stale.
`REVIEW.md` is where code owners tell the reviewer what matters.
A good one defines what counts as failure ("the docs should not lie", "the config should not misroute"), limits nitpicks, lists ignored paths, demands a file and line instead of a guessed filename, and opens with a count of findings or a plain "no issues".
2. AI review on every pull request, before any human.
It checks the diff against the whole codebase and the stated intent: does it fix the issue, does it fit the system, does it break anything else?
For a bug fix it looks for the root cause.
Several agents hunt for bugs in parallel, a vote drops findings without enough support, and style-only findings are filtered out.
Findings arrive as inline comments by severity: Important, Nit, or Pre-existing, so the author is not blamed for old bugs.
Every finding is fixed or resolved with a reason before merge.
3. An automated security review that blocks merge while any finding is open.
A later commit that fixes the problem closes the finding, and a false positive is closed with a short reason.
4. Blocking checks: lint, types, tests on every platform, and the build.
The pull request template asks how the change was tested and how to revert it, and the author owns the answers even when Claude drafts them.
5. Human approval scaled by risk.
A classifier sets the risk tier from the change, never from the author, and another decides when a change needs a second approval anyway.
Paths owners mark sensitive and every CI workflow file always need a second approval.
Only the owning team gets relaxed rules, and everyone else needs a second person.
Agent approvals never count as human approvals.
When an agent authors a pull request, its operator is a required reviewer.
An approval covers one commit, and an untrusted new commit (an agent push, a hand-resolved merge) needs a new approval.
6. A merge queue, feature flags, and staged rollouts.
The queue runs every check on `main` with the change applied, so two green pull requests cannot merge into a broken `main`.
Features ship behind flags to employees first, then to a latest channel, with stable trailing behind.
7. Fast feedback and rollback.
A flag turns a change off without a deploy, and a weekly on-call reviews each incident by asking which layer should have caught it.

### Making the reviewer better

Incidents are the eval set.
The team collected incident-causing pull requests with their reverts and fix-forwards, had engineers confirm where each bug was, and scores the reviewer against the whole set daily and on every reviewer change.
Recall is easy to buy with noise, so noise is measured too.
Each comment is classified by what the author did with it: fixed, rejected, explained as intended, or judged not to matter.
The reviewer also runs on pull requests known to be clean, to count findings that would have caused a harmful change.
The priorities are real bugs first and fewer review cycles second.

A comment costs an agent author more than a human one: a human dismisses a nit in a second, but an agent makes a commit and starts another cycle.
Review must converge.
One pull request cycled more than 50 times overnight between an agent author and an agent reviewer until someone stopped it.
`git blame` showed that about 59% of what the reviewer kept flagging was code present since the first pass: each cycle found a few more old bugs, not new ones.
Running several cycles by default made this worse.
The fix:

- Track cycles-to-pass next to recall.
- After three cycles, ask the author to rethink the approach.
- After the first cycles, review only the new diff.
- Name the class of bug, so the author fixes every instance, not one line.
- Never re-report a finding already raised.
- Hunt historical bugs on the whole codebase overnight, separately from pull requests.

### What humans still do

- Decide whether to build it at all: vision, taste, and goals.
One team that says it solved the review bottleneck still reviews outside changes for this reason.
- Audit dangerous code: billing, the auto-updater, CI workflows.
- Review architecture, because those choices set the conventions others copy.
- Verify the proofs: test output, commands run, screenshots, reviewer comments.
If you cannot say what the checks would miss, asking for a thumbs-up is not a review.
- Take responsibility: a person answers for every change that ships, whoever typed it.

### Learning the code without reading every diff

Reading a colleague's diff used to be how people learned the codebase.
Nobody on the team holds the whole system in their head, and nobody needs to.
Before changing an area, an engineer asks Claude for an explainer of that slice, sometimes as a small interactive artifact.
It takes minutes and is always current, and it teaches more than a one-line diff does.
Working in open channels lets anyone see work in progress and object early.

### You land it, you own it

Whoever merges a small or medium change fixes it if it breaks.
This stays sane because changes are small, everything can be reverted in minutes, the bar rises with blast radius, telemetry and internal use surface regressions fast, and incident reviews blame the system, not the person.
Starting work with agents is cheap, so closing a pull request is cheap too.
Pivot early in the thread instead of blocking a finished pull request at the end.

### Where it is going

Owners now let some low-risk changes merge automatically when every check passes, and that boundary will move.
Each miss becomes a question: what was missing from the model's context?
The answer becomes a `CLAUDE.md` line, a skill, or a new check.
The goal stays the same: less human effort per change, with the revert rate no higher than it is now.

In one line: layer automated reviews in front of a risk-scaled human approval, make every review converge, score the reviewer against real incidents, and keep every change small and one step from a revert.

## Repo changes

- `REVIEW.md`: what counts as a bug here, what to skip, the finding format (file and line, severity Important, Nit, or Pre-existing, bug class, failure scenario), a report that opens with counts or "No issues found", and convergence rules (re-review only new commits, no repeats, three cycles then rethink).
`scripts/verify.sh` holds it to the topic-doc size limit, so it stays brief.
- `.claude/agents/reviewer.md`: a fresh-context subagent that receives only the feature id and a diff range, reads the diff against the codebase and the feature contract, and reports findings in the `REVIEW.md` format without changing files.
- `.github/pull_request_template.md`: Summary, Testing, Risk (with changed `high_stakes` paths), and How to revert.
- `docs/architecture.json`: the gates themselves ship as `high_stakes` paths (`.github/workflows/`, `.githooks/`, `scripts/`, `.claude/`), so `scripts/review-change.sh` asks for a human read of any change to them.
`docs/conventions.md` and `docs/initialization.md` say to keep those entries.
- `docs/graph.md`: a Code review node between Check and Evaluate, its routing (Important findings retry, three cycles go to Research), and the reviewer under the fresh-context constraint.
- `docs/loops.md`: the goal contract runs the reviewer and caps review cycles, three review cycles count as three failed attempts, and the pull request follows the template.
The comprehension-rot guard adds an explainer before changing an unfamiliar module.
- `docs/security.md`: an agent's approval never satisfies a required human approval, an approval covers one commit, and a Merge settings reference for branch protection and the merge queue.
- `docs/harness-audit.md`: a "When a bad change merges" procedure (revert first, name the layer that should have caught it, add the check), an incident log that doubles as the reviewer's eval set, and revert rate as a guardrail metric.
- `AGENTS.md`: the repo map lists the review files, and the Definition of Done requires a fresh-context review with every Important finding fixed or answered.

## Design choices

Why `REVIEW.md` sits at the root instead of in `docs/`:
it is read by reviewers outside this repo's agents too, such as a hosted pull request reviewer, and the root is where they look, as with `CLAUDE.md`.
It stays a topic doc in every other way: linked from the repo map and held to the same size limit.

Why a separate reviewer subagent instead of a wider evaluator:
they answer different questions with different inputs.
The evaluator walks the running project against the contract and never reads the diff.
The reviewer reads the diff against the codebase and finds what the contract never named, such as a broken caller or a stale doc.
Merging them would hand the evaluator the implementation, which breaks its independence.

Why the review cycle cap lives in prose and in the goal contract, not in a script:
no script sees how many times a subagent was called.
The cap is counted by the caller, and three cycles join the existing three-failed-attempts rule, so a stuck loop still ends in Block.

Why the gates are `high_stakes` by default:
the post names CI workflow files as always needing a human, and every check here can be weakened by editing the script that runs it.
A change to a gate hurts every later change, which is the widest blast radius in the repo.
The entries are only warnings, so editing the boilerplate itself stays possible.

Why no parallel bug-hunting agents, voting, or hosted reviewer workflow:
they need a model account, a secret in CI, and tuning against incidents this boilerplate does not have yet.
`REVIEW.md` and the pull request template are written so a project can point any hosted reviewer at them, and the incident log builds the eval set it would need.

Why branch protection is documented rather than configured:
it is a GitHub repository setting, not a file, so a fork cannot inherit it.
`docs/security.md` lists the settings and a `TODO(project)` slot records where they are set.

Why no circuit breaker that tightens approvals when reverts rise:
the post's team has not built one either.
The monthly audit reads the revert rate and the incident log, which is the manual version.
