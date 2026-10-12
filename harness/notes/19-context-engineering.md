# 19 - Context engineering

Source: chapter 4 of the O'Reilly Early Release book on agentic engineering.

## Notes

The user types under 5% of what the model reads.
The other 95% is the output of the harness: the system prompt, `AGENTS.md`, skills, tool descriptions, the conversation, and tool outputs.
Context engineering decides what goes into the window, when it appears, how often it refreshes, and when it leaves.
Every tool description, MCP server, and rule costs latency and attention on every turn.

The term converged in June 2025 (Walden Yan, Dex Horthy, Tobi Lütke, Andrej Karpathy, Simon Willison).
Horthy: "The contents of your context window are the ONLY lever you have to affect the quality of your output."
The model call is stateless, so everything relevant must be present at input time.

The author's client repos carry the tier rules in context: no unattended merges, and payment and auth paths named as load-bearing.
"The repo should know it's a client repo even when you forget."

### AGENTS.md done right

- A file with `AGENTS.md` cut wall-clock time by about 29% and output tokens by about 17% across 124 PRs (Lulla et al.).
- LLM-generated context files gave no success gain and raised cost over 20%.
Developer-written files raised success by about 4% (Gloaguen et al., ETH Zurich).
- Generated files restate what the model infers from the code.
Human-written files carry what is not in the code: tooling gotchas, non-obvious conventions, and the reason an ugly directory cannot be deleted.
- `AGENTS.md` is now governed by the Agentic AI Foundation under the Linux Foundation.
- Keep it short: the author keeps public files under 60 lines.
Every line rides in every turn, and models miss information in the middle of long prompts.
- Every line traces to a failure, and the line leaves when the problem is fixed for good.
Left alone, the file grows to 400 lines, half stale.
- It is a cockpit checklist, not a style guide: it assumes competence and lists what you would forget under pressure.
- Pink elephant: every mention of a thing raises the chance the model thinks about it.
Prefer what to do over what to avoid, and make a needed warning specific ("never run `migrate:reset` against staging").
- Hierarchy: a small root file plus scoped files next to the code they govern, so one review touches the code and its context.

### The hierarchy of attention

The system prompt, `AGENTS.md`, active skills, and tool descriptions stay stable.
The conversation and tool outputs grow without bound.
By turn 40 the original prompt is noise, so a harness that pins the task brief beats one that lets it scroll away.
Chat fades, and the durable channels are `AGENTS.md`, skills, hooks, and code.
HumanLayer finds most setups over-tooled by a factor of two or three.

### Context rot

As the window fills, instruction-following degrades (Horthy's "dumb zone").
Stay around 40% utilization, and treat 60% as the signal to wrap up.
The tells:

- The same tool call repeats three or more times with no change.
- A rule obeyed earlier is now broken.
- The goal is lost.
- Edits get sloppier.
- Reflexive agreement ("You are absolutely right").

Two tells are enough evidence.
Context cannot be freed once allocated (Huntley), so open a fresh window and carry forward only the state worth keeping.
Equal sizes can carry very different signal: 60K tokens of logs are worse than 60K tokens of relevant edits.

Three techniques fight rot:

- Compaction: summarize the oldest part.
Intentional compaction into a progress file at natural boundaries beats automatic compaction.
- Tool-call offloading: keep the head and tail of a large output, and put a pointer to the full output on disk.
- Resets: write a handoff file, tear down the session, and resume in a fresh one.
"Compaction alone is not sufficient" (Anthropic).

### Memory, retrieval, and MCP

The filesystem is the only durable memory.
For each mistake, ask where on disk the next agent must read about it: the rulebook, a skill, a comment, or a hook.
Maintain the rulebook periodically: prune rules followed without prompting, sharpen rules broken, and add rules for uncovered patterns.
Automated rulebook optimizers (ACE, Arize) can suggest edits, but a human owns the merge.

For code, read-on-demand (grep, glob, file reads) beat embedding retrieval.
Claude Code itself moved from a RAG index to grep.
Retrieve only what the agent cannot reach, such as vendor docs or post-mortems, and evict it after use.

Every MCP server's descriptions are trusted text paid for on every turn.
Five kitchen-sink servers can cost 25,000 tokens before the work starts.
The lethal trifecta (Willison) is private data, untrusted content, and external communication together, and breaking any one leg is enough.
Treat each server as a dependency: read the source, pin the version, and audit it.

### Antipatterns

The kitchen-sink `AGENTS.md`, the AI-generated `AGENTS.md`, premature retrieval, context bloat, the just-one-more-rule reflex, MCP sprawl, a single root file for a polyrepo, and stale context plausible enough to act on.
For the just-one-more-rule reflex, fix the code first, then use hooks and tests, and reach for `AGENTS.md` last.

### The outer loop

Faros AI's telemetry: throughput up, quality down, and many PRs merged with no review.
A polluted context produces confident, quietly wrong work, and a tired reviewer waves it through.
Research-plan-implement failures recur here: the plan-reading illusion, the instruction budget of about 150 to 200 instructions, and research eating about 40% of the window.

In one line: decide deliberately what the model reads, keep the rulebook short and earned, reset before the dumb zone, and put the tier constraint in the repo, not in your head.

## Repo changes

- `AGENTS.md`: cut from 100 to 89 lines without losing a rule.
Removed "read this file at the start" (it is loaded anyway), the `rg` search hint (the model knows it), and the WIP rule that `scripts/feature.sh start` enforces.
Merged related repo map lines and two-line rules.
- `docs/cleanup.md`: a "Context resets" section with the 40% and 60% thresholds, the five tells, and the reset steps through `PROGRESS.md` and `scripts/restore-state.sh`.
- `docs/documentation.md`: add a line only after a real failure, delete it when a check or a newer model makes it redundant, write instruction files by hand, and say what to do rather than what to avoid.
- `docs/loops.md`: the token-blowout guard points to the context resets, and the file drops below the 90% size-pressure threshold.
- `PROGRESS.md`: the agent writes its handoff and starts a fresh session near 60% or when the tells appear.

## Design choices

Why the reset procedure lives in `docs/cleanup.md`:
a reset is a session boundary, and `docs/cleanup.md` already owns how a session leaves clean state for the next one.
`PROGRESS.md` and `scripts/restore-state.sh` already carry the handoff, so a reset needs only the trigger and the order.

Why `AGENTS.md` stays near 90 lines instead of 60:
most of its length is the repo map, which `scripts/verify.sh` requires, and the `TODO(project)` slots a project fills in.
A project deletes the Initialization section and the `harness/` line when it starts.
The cut targeted lines that a script enforces or the model already knows, which is the chapter's own test.

Why no context-utilization meter:
the harness tools show context use already, and the threshold is a judgment that depends on the model.
The tells are observable without tooling, so the rule names them.

Why no retrieval or MCP defaults:
the chapter says to add retrieval only for a measured gap, and each server costs tokens on every turn.
`docs/tools.md` already budgets tools, and the monthly audit removes unused ones.
