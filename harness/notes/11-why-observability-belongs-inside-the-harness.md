# 11 - Why observability belongs inside the harness

## Notes

The issue: an agent without observability cannot see what actually happened at runtime or why something failed.
Evaluation becomes subjective, and retries become blind guesses that waste time and tokens.

The fix is to build observability into the harness:

- Runtime signals: logs, traces, health checks, errors, data flow, and resource usage.
- Process signals: clear task scope, acceptance criteria (a sprint contract), and an evaluator rubric.
- Verification: check each requirement against runtime evidence, and report exactly what failed and where.

In one line: no observability → the agent guesses → blind retries; expose runtime evidence and clear acceptance criteria so failures are diagnosable and verification is reproducible.

## Repo changes

- `scripts/lib/runs.sh`: created; gives each harness run a directory under `.harness/runs/` and keeps the newest 30.
- `scripts/verify.sh`: each check's output goes to its own log, with its status and duration in `summary.json`; a failure prints the end of each failing log and the run directory; `.harness/runs/latest` points at the newest run.
- `scripts/feature.sh`: the flow log of `verify` is kept in its own run directory, and a failure names it and asks for a diagnosis before a retry.
- `scripts/restore-state.sh`: a Last verification section shows the newest result and, after a failure, the logs to read.
- `.github/workflows/verify.yml`: uploads `.harness/runs/` as the `harness-runs` artifact when a run fails.
- `.gitignore`: ignores `.harness/`.
- `docs/observability.md`: created; run evidence, slots for the project's log path and health check, hard constraints for logs, health, and errors, a signals table, and the verification report.
- `AGENTS.md`: hard constraint 7 is diagnose before retrying; the Definition of Done records evidence per requirement in the verification report; the repo map links `docs/observability.md`.
- `docs/initialization.md`, `docs/harness-audit.md`: set up logs and a health check at initialization, and audit that a recent failure was diagnosable from evidence alone.

## Design choices

Why the harness's own runs are the first signal built:
the boilerplate has no runtime yet, but it already runs checks every commit, and their output vanished once the terminal scrolled.
Per-check logs, a machine-readable summary, and the last result in the restored state mean a session after compaction knows what failed and where to look without re-running anything.

Why a passing check's output is no longer printed:
on success it is noise in the agent's context; on failure the end of the log and its path are what the agent needs.
The full output is still on disk for both.

Why the evidence lives in a git-ignored directory instead of git:
logs are per checkout and per run, often large, and stale by the next run; committing them would bloat history and conflict across worktrees.
`.harness/runs/latest` and CI's uploaded artifact cover the cases where someone needs them later.

Why "diagnose before retrying" is a hard constraint:
the chapter's failure mode, the blind retry, can happen in any task, so the rule is global.
Every failure message now names the log that holds the cause, which makes following the rule cheap.

Why the verification report is a table in `PROGRESS.md`, not a script:
whether a screenshot or a log line proves a requirement is a judgement, which is what the evaluator rubric exists for.
Writing it into the active feature notes makes the evidence survive compaction and gives the next attempt the exact failing requirement.

How the process signals map to what already exists:
scope is the single `active` feature, the sprint contract is that feature's `behavior` and `verify` command, and the evaluator rubric is the verification report.
