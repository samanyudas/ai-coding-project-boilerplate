# Observability

What an agent can see when the harness and the project run, so a failure is diagnosed from evidence instead of guessed at.
Without it, evaluation turns subjective and retries turn into blind guesses.

## Quick start

- **Harness runs.** Every `scripts/verify.sh` run leaves a log per check and a `summary.json` under `.harness/runs/` (the newest is `.harness/runs/latest`), and `scripts/feature.sh verify` leaves its flow log beside them.
A failure prints the end of the failing log and its path; `scripts/restore-state.sh` shows the last result; CI uploads the same directory as the `harness-runs` artifact when a run fails.
- TODO(project): Where the running project writes its logs (a path an agent can read), and the command to follow them.
- TODO(project): The health check (URL or command), and what it reports for each component and dependency.

## Hard constraints

- Diagnose before retrying: read the failing log or runtime signal and name the cause first. A retry without a new hypothesis is a blind guess.
- The project logs structured events, one JSON object per line with time, level, event, and a request or trace id, so one request can be followed across components.
- Every component exposes a health check, and the startup check (level 2) calls it.
- An error is logged once, where it is handled, with the context to reproduce it (inputs, ids, the failing step), and never swallowed.
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

The evaluator rubric for a feature: check each requirement in its `behavior` against runtime evidence, and write the result into the active feature notes in `PROGRESS.md`:

| Requirement | Evidence (response, log line, screenshot, metric) | Result | Where it failed |
| --- | --- | --- | --- |

A failed row names the expected and the actual result, and where it diverged (file, step, or log line), so the next attempt starts from the cause.
The report is what turns "it seems to work" into a pass anyone can reproduce.

## Checklist

- [ ] Every failure you hit was diagnosed from its log or runtime signal before you retried.
- [ ] New code paths log their key events, and errors with their context.
- [ ] The verification report covers every requirement with evidence.
