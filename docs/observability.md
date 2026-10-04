# Observability

Logs, health checks, and run reports let an agent diagnose failures from evidence.
Without evidence, evaluation becomes subjective and retries test guesses.

## Quick start

- Every `scripts/verify.sh` run writes a log per check and a `summary.json` under `.harness/runs/`.
`.harness/runs/latest` points to the newest run.
`scripts/feature.sh verify` writes its flow log beside those logs.
A failure prints the end of the failing log and its path.
`scripts/restore-state.sh` shows the last result.
When a run fails, CI uploads the same directory as the `harness-runs` artifact.
- TODO(project): Where the running project writes its logs (a path an agent can read), and the command to follow them.
- TODO(project): The health check (URL or command), and what it reports for each component and dependency.

## Hard constraints

- Before retrying, read the failing log or runtime signal.
Name the cause before another attempt.
A retry without a new hypothesis tests a guess.
- The project logs each structured event as one JSON object per line.
Each object includes time, level, event, and a request or trace id.
The id lets an agent follow a request across components.
- Every component exposes a health check, and the startup check (level 2) calls it.
- Log each error once, where the code handles it.
Include the inputs, ids, and failing step needed to reproduce the error.
Never swallow an error.
- Secrets and personal data stay out of logs, as `docs/security.md` requires.

## Signals

| Signal | Answers | How to read it |
| --- | --- | --- |
| Logs | What happened, in order | TODO(project): the log path and follow command |
| Traces or request ids | Which components one request crossed, and where it stopped | Filter the logs by the id |
| Health checks | Is each component and dependency up | TODO(project): the health URL or command |
| Errors | What failed, with which inputs | Logs at error level, with their context |
| Data flow | What entered and left each boundary | Boundary log events (request in, response out, write, publish) |
| Resource usage | Is time, memory, or a connection pool the bottleneck | TODO(project): how to see it, or "not needed yet" with why |

## Verification report

The evaluator checks each requirement in the feature's `behavior` against runtime evidence.
The calling agent records the report in the active feature notes in `PROGRESS.md`.
The report has one row per requirement:

| Requirement | Evidence (response, log line, screenshot, metric) | Result | Where it failed |
| --- | --- | --- | --- |

A failed row states the expected result, actual result, and failure location, such as a file, step, or log line.
This evidence lets the next attempt start from the cause.
The report provides reproducible evidence for a passing result.

## Checklist

- [ ] You diagnosed each failure from its log or runtime signal before another attempt.
- [ ] New code paths log their key events, and errors with their context.
- [ ] The verification report covers every requirement with evidence.
