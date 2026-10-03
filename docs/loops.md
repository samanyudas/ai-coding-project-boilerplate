# Loops

How to run the agent without you as the trigger: you design the loop, the loop prompts the agent, and you judge what it produces.
Without a loop you type every instruction and check every output, so the agent stops whenever you stop; and an agent that decides on its own when it is done declares victory too early.

## Quick start

Pick the loop by asking whether the work has an end:

| The work | Loop | Example here |
| --- | --- | --- |
| Has an end | A goal run: `/goal` in Claude Code or Codex | Build every feature in `docs/features.json` (contract below) |
| Has no end, keep watching | `/loop`, a scheduled task, cron, or a scheduled GitHub Action | `.github/workflows/maintenance.yml` opens the weekly cleanup and monthly audit |
| Starts on an outside event | An event-driven GitHub Action, or a hook | CI fails or a pull request opens, and an agent run picks it up |

`/loop` and schedules start each run fresh with no memory of the last one, so never use them for goal work.

The goal contract for this repo, ready to paste:

```text
/goal Work through docs/features.json in priority order, one feature at a time.
For each: scripts/feature.sh start <id>; implement it; scripts/feature.sh verify <id>; ask the evaluator subagent to walk it and record its report in PROGRESS.md; fix and repeat until the verdict is PASS; then commit.
If a feature cannot pass, scripts/feature.sh block <id> "<reason>" and move to the next.
Done when `scripts/feature.sh remaining` exits 0 and `scripts/end-session.sh` passes. Stop after 10 features either way, and report what is left.
```

## Hard constraints

- Every loop has a contract before it starts: the goal, the verification method, a machine-checkable stop condition, the state file it reads and writes, and a budget (iterations or time).
- The maker never grades its own work: scripts judge what they can (`scripts/verify.sh`, `scripts/feature.sh verify`), and an independent evaluator (the `evaluator` subagent in `.claude/agents/evaluator.md`, a fresh session, or another model) judges the rest. Someone in the loop must not believe the agent.
- State lives on disk, never only in a session: each iteration reads `docs/features.json` and `PROGRESS.md` and leaves them current, so any run can stop and the next can resume.
- Parallel loops each get their own branch and worktree (hard constraint 5).

## The six primitives here

| Primitive | Job in the loop | In this repo |
| --- | --- | --- |
| Automations | The heartbeat: discovery and triage on a schedule | `.github/workflows/maintenance.yml`, `.github/workflows/verify.yml`, `/loop`, scheduled tasks |
| Worktrees | One isolated checkout per parallel agent | Hard constraint 5; `git worktree add`, or `isolation: worktree` on a subagent |
| Skills | Project knowledge written once, read every run | `docs/`, and `.claude/skills/<name>/SKILL.md` for a procedure agents repeat (`docs/cleanup.md`) |
| Connectors | Access to real tools: issues, databases, chat, pull requests | MCP servers and plugins, listed in `docs/tools.md` |
| Sub-agents | Separate maker and checker | `.claude/agents/evaluator.md` |
| External state | Memory on disk; the spine the other five depend on | `docs/features.json`, `PROGRESS.md`, `DECISIONS.md`, git, `.harness/runs/` |

## Generator and evaluator

The most important split in a loop.
The maker writes code and believes it works; the checker looks for where it does not.
Here the checker is layered: `scripts/verify.sh` gates every commit, `scripts/feature.sh verify` refuses a feature whose flow fails, and the `evaluator` subagent walks what no script asserts, returning `PASS` or `FAIL` with evidence.
A goal loop stops only on the scripts' exit codes, never on the maker saying it is done.

## Ratchet loops

For work measured by a number (speed, accuracy, size), use a ratchet, as in Karpathy's autoresearch:

1. A direction file only you edit (what to try, what to leave alone).
2. A mutable scope only the agent edits (the code under test).
3. A read-only judge: a script that runs on a fixed budget and prints the metric.
4. The loop: change → commit → run the judge → keep the commit if the metric improved, otherwise `git reset --hard HEAD~1` → append a row to a results log → repeat.

The loop itself can be written in English in the direction file; the read-only judge is what keeps it honest.

## Four silent costs

They grow the longer a loop runs.

| Cost | What it is | Guard here |
| --- | --- | --- |
| Verification debt | "Looks fine" is not confirmed | Stop conditions are exit codes: `scripts/feature.sh remaining`, `scripts/end-session.sh` |
| Comprehension rot | Code piles up faster than you understand it | Read each loop's commits and `DECISIONS.md`; the weekly cleanup issue surfaces drift |
| Cognitive surrender | Using the loop to avoid thinking instead of to amplify it | You own the direction: the feature list, its order, and every `behavior` |
| Token blowout | Context grows with each iteration | State on disk, the restore hook after compaction, and a fresh session per run when a loop gets long |

## Starting small

1. Pick one task you do two or more times a week.
2. Write its goal and its machine-checkable stop condition.
3. Split maker and checker.
4. Give it a markdown memory file.
5. Schedule it once a day, and watch it for a week before trusting it.

The maturity ladder: goal runner → scheduled single task → multi-agent loop → self-feeding loop → fleet orchestration.
Most teams sit at levels 2 to 3; climb one rung at a time, and only once the current one runs unattended without surprises.

## Checklist

- [ ] The loop has a contract: goal, verification, machine-checkable stop condition, state file, and budget.
- [ ] Someone other than the maker judges the result.
- [ ] You read what the loop produced before starting the next one.
