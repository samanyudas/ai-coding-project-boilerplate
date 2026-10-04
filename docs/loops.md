# Loops

You design the loop, the loop prompts the agent, and you review the result.
Without a loop, the agent stops when you stop supplying instructions.
An agent that decides for itself when work meets the requirements can declare completion too early.

## Quick start

Pick the loop by asking whether the work has an end:

| The work | Loop | Example here |
| --- | --- | --- |
| Has an end | A goal run: `/goal` in Claude Code or Codex | Build every feature in `docs/features.json` (contract below) |
| Has no end, keep watching | `/loop`, a scheduled task, cron, or a scheduled GitHub Action | `.github/workflows/maintenance.yml` opens the weekly cleanup and monthly audit |
| Starts on an outside event | An event-driven GitHub Action, or a hook | CI fails or a pull request opens, and an agent run picks it up |

`/loop` and schedules start each run fresh, without memory of the previous run.
Use a goal run for work with a defined end.

The goal contract for this repo, ready to paste:

```text
/goal Create a new branch named loop/<today's date>.
Process docs/features.json in priority order, one feature at a time.
For each feature:
1. Run scripts/feature.sh start <id>.
2. Implement the feature.
3. Run scripts/feature.sh verify <id>.
4. Give the evaluator subagent only the feature id.
5. Record its report in PROGRESS.md.
6. Fix failures and repeat verification and evaluation until the verdict is PASS.
7. Commit the verified feature.
After three failed attempts with the same cause:
1. Discard the attempt.
2. Run scripts/feature.sh block <id> "<reason>".
3. Continue with the next feature.
Never change the behavior or verify command of a passing feature.
The goal is complete when scripts/feature.sh remaining exits 0 and scripts/end-session.sh passes.
Stop after 10 features even if the goal remains incomplete.
Push the branch.
Open a pull request for review.
Report what remains.
Do not merge the pull request.
```

## Hard constraints

- Before starting a loop, define its contract with all of these fields:
  - The goal.
  - The verification method.
  - A stop condition that a tool can check.
  - The state file that the loop reads and writes.
  - An iteration or time budget.
- The maker never evaluates its own work.
The scripts (`scripts/verify.sh`, `scripts/feature.sh verify`) evaluate what they can test.
An independent evaluator evaluates the remaining requirements.
Use the `evaluator` subagent in `.claude/agents/evaluator.md`, a fresh session, or another model.
- Store state on disk rather than only in a session.
Each iteration reads `docs/features.json` and `PROGRESS.md` and leaves both current.
The next run can then resume a stopped run.
- Parallel loops each get their own branch and worktree (hard constraint 5).

`docs/graph.md` defines execution order, retries, rollbacks, and the human review before merge.
Run no more loops in parallel than you can review.

## The six primitives here

| Primitive | Job in the loop | In this repo |
| --- | --- | --- |
| Automations | Discover and triage work on a schedule | `.github/workflows/maintenance.yml`, `.github/workflows/verify.yml`, `/loop`, scheduled tasks |
| Worktrees | One isolated checkout per parallel agent | Hard constraint 5, `git worktree add`, or `isolation: worktree` on a subagent |
| Skills | Project knowledge written once, read every run | `docs/`, and `.claude/skills/<name>/SKILL.md` for a procedure agents repeat (`docs/cleanup.md`) |
| Connectors | Access to real tools: issues, databases, chat, pull requests | MCP servers and plugins, listed in `docs/tools.md` |
| Sub-agents | Separate maker and checker | `.claude/agents/evaluator.md` |
| External state | Store the state that the other primitives need | `docs/features.json`, `PROGRESS.md`, `DECISIONS.md`, git, `.harness/runs/` |

## Generator and evaluator

The maker writes code, and the evaluator tests whether it works.
`scripts/verify.sh` gates every commit.
`scripts/feature.sh verify` rejects a feature whose flow fails.
The `evaluator` subagent tests requirements that the scripts do not cover and returns `PASS` or `FAIL` with evidence.
A goal loop uses the scripts' exit codes to determine completion, rather than the maker's claim.

## Ratchet loops

For work measured by a number (speed, accuracy, size), use a ratchet, as in Karpathy's autoresearch:

1. Define a direction file that only you edit, with what to try and what to leave unchanged.
2. Define the code under test as the scope that only the agent edits.
3. Provide a read-only evaluator script that runs within a fixed budget and prints the metric.
4. Run the loop in this order:
   1. Change the code.
   2. Commit the change.
   3. Run the evaluator script.
   4. If the metric improved, keep the commit.
   Otherwise, discard the commit with `git reset --hard HEAD~1`.
   5. Append a row to the results log.
   6. Repeat the loop.

The direction file can describe the loop in English.
The read-only evaluator script measures whether each change improves the result.

## Four silent costs

They grow the longer a loop runs.

| Cost | What it is | Guard here |
| --- | --- | --- |
| Verification debt | "Looks fine" is not confirmed | Stop conditions are exit codes: `scripts/feature.sh remaining`, `scripts/end-session.sh` |
| Comprehension rot | Code grows faster than you understand it | Read each loop's commits and `DECISIONS.md`, and use the weekly cleanup issue to find drift |
| Cognitive surrender | Using the loop to avoid thinking instead of to amplify it | You own the direction: the feature list, its order, and every `behavior` |
| Token blowout | Context grows with each iteration | State on disk, the restore hook after compaction, and a fresh session per run when a loop gets long |

## Starting small

1. Pick one task you do two or more times a week.
2. Write its goal and its machine-checkable stop condition.
3. Split maker and checker.
4. Give it a markdown memory file.
5. Schedule it once a day, and watch it for a week before trusting it.

The maturity ladder: goal runner → scheduled single task → multi-agent loop → self-feeding loop → fleet orchestration.
Most teams sit at levels 2 to 3.
Advance one level at a time, only after the current level runs unattended without surprises.

## Checklist

- [ ] The loop has a contract: goal, verification, machine-checkable stop condition, state file, and budget.
- [ ] Someone other than the maker judges the result.
- [ ] You read what the loop produced before starting the next one.
