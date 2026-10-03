# 13 - From manual prompting to autonomous loops

## Notes

The issue: chapters 1 to 12 make single runs reliable, but you are still the trigger.
You type every instruction, check every output, and decide every next step, so you are the bottleneck and the agent stops whenever you stop.
And an agent that decides on its own when it is done declares victory too early.

The prerequisites, as six primitives:

| Primitive | Job in the loop | Codex app | Claude Code |
| --- | --- | --- | --- |
| Automations (heartbeat) | Discovery and triage on a schedule | Automations tab (project, prompt, cadence, environment), results in a Triage inbox; `/goal` to run until done | Scheduled tasks and cron, `/loop`, `/goal`, hooks, GitHub Actions |
| Worktrees | Isolate parallel features | A built-in worktree per thread | `git worktree`, `--worktree`, `isolation: worktree` on a subagent |
| Skills | Codify project knowledge | Agent Skills (`SKILL.md`), invoked with `$name` or implicitly | Agent Skills (`SKILL.md`) |
| Plugins and connectors | Connect your tools | Connectors (MCP), plus plugins for distribution | MCP servers, plus plugins |
| Sub-agents | Ideate and verify | Subagents defined as TOML in `.codex/agents/` | Task subagents in `.claude/agents/`, agent teams |
| State | Track what is done | Markdown, or Linear through a connector | Markdown (`AGENTS.md`, progress files), or Linear through MCP |

The fix is loop engineering: stop prompting the agent and design the system that prompts it.
You move from inside the loop to outside it, and the leverage shifts from writing the right prompt to designing the right loop.

- The simplest loop is `/goal`: a goal, a verification method, and a stopping condition; the agent loops until an independent judge confirms it is done.
- Pick the loop type by asking "does it have an end?":
  - It has an end: `/goal` (implement a payment system with tests).
  - No end, keep watching: `/loop` or a schedule (check CI every 15 minutes).
  - Triggered by outside events: event-driven (a pull request opens, CI fails).
  - Do not use `/loop` for goal work; each run starts fresh and does not remember the last one.
- The six primitives: automations (the heartbeat), worktrees (one isolated checkout per parallel agent), skills (project knowledge written once, read every run), connectors (real tools such as issues, databases, chat, and pull requests), sub-agents (separate maker and checker), and external state (memory on disk, the spine the other five depend on).
- Generator and evaluator separation matters most: a model is too generous grading its own work, so verify with a separate session, model, or script. Someone in the loop must not believe the agent.
- Karpathy's autoresearch as an exemplar: you edit only `program.md` (direction), the agent edits only `train.py` (code), and `prepare.py` is read-only. It runs a ratchet: change → commit → fixed five-minute run → keep if improved, otherwise revert → log → repeat. The loop itself is written in English, not code.

Four silent costs grow the longer a loop runs:

- Verification debt: "looks fine" is not confirmed, so stopping conditions must be machine-checkable.
- Comprehension rot: code piles up faster than you understand it.
- Cognitive surrender: using the loop to avoid thinking instead of to amplify it.
- Token blowout: context grows each iteration, so manage or compact it from day one.

Start small: pick one task you do two or more times a week → write its goal and stop condition → split maker and checker → add a markdown memory file → schedule it once a day → watch it for a week.

The maturity ladder: goal runner → scheduled single task → multi-agent loop → self-feeding loop → fleet orchestration. Most teams are at levels 2 to 3.

In one line: you as the prompter are the bottleneck and the source of premature "done"; design loops (goal, independent verification, stop condition, external state) so the agent keeps working without you, while you keep judging the output.

## Repo changes

- `scripts/feature.sh`: `remaining` lists the features still to do and exits 0 only once every feature is passing or blocked: the machine-checkable stop condition for a goal loop.
- `.claude/agents/evaluator.md`: created; the checker subagent, which walks a feature's flow on the running project, returns the verification report and a `PASS` or `FAIL` verdict, and changes no files.
- `docs/loops.md`: created; choosing a loop type, a ready-to-paste `/goal` contract for this repo, hard constraints for every loop, the six primitives mapped to this repo, generator and evaluator separation, ratchet loops, the four silent costs with their guards here, starting small, and the maturity ladder.
- `AGENTS.md`: the Definition of Done requires an independent evaluator, not the agent that wrote the code, to walk the flow; the repo map links `docs/loops.md` and the evaluator, and lists `remaining`.
- `docs/testing.md`, `docs/initialization.md`: the walker is the evaluator, which gets the same browser or computer-use tools; initialization ends by pointing at the goal contract.

## Design choices

Why the stop condition is a `scripts/feature.sh` subcommand:
a goal loop needs an exit code, not the maker's opinion, and the feature list already is the goal.
`remaining` reads it and says what is next, so the same command steers the loop and stops it; a blocked feature counts as finished for the loop and is reported for a human.

Why the evaluator changes no files:
a checker that can fix things starts believing the maker's framing and grading its own repairs.
Returning a report keeps the roles apart: the maker records the verdict and acts on it.

Why the evaluator is a Claude Code subagent while the rest stays tool-neutral:
subagent definitions differ by tool, and this one is short; `docs/loops.md` lets any tool get the same independence from a fresh session or another model, and the subagent's body is the brief to give it.
Its `tools` line carries a `TODO(project)` slot, because which browser or computer-use tools it needs depends on the project.

Why the goal contract has a budget ("stop after 10 features"):
an unattended loop that never hits its stop condition burns tokens indefinitely, which is the token blowout cost; a budget turns a stuck loop into a report instead.

Why ratchet loops are documented but not scripted:
the judge, the metric, and the scope are all project-specific, and the boilerplate has no metric yet.
The pattern is what transfers; `scripts/scan.sh` already has the benchmarks slot a ratchet's judge would build on.

Not added: an event-driven GitHub Action that runs an agent when CI fails.
It needs an API key stored as a repository secret, which only the repo owner should add; `docs/loops.md` describes the pattern for when one is wanted.
