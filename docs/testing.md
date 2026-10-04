# Testing

How tests are written and run.

## Quick start

- TODO(project): Test framework and version, and where tests live.
- TODO(project): The command to run one test file, and the command for the whole suite.
- Run `python3 scripts/test-ste.py` for the writing-check regression tests.
`scripts/verify.sh` runs them at level 2.

## Hard constraints

- Every new or changed behaviour gets a test that fails without the change and passes with it.
- Each feature's `verify` command in `docs/features.json` runs a focused test that checks its behavior end to end, through the interface a user or caller would use.
It runs on every `scripts/verify.sh`, so keep it fast and deterministic.
- A change that crosses components (see `docs/architecture.json`) needs an integration or end-to-end test that crosses them too.
Unit tests cannot see interface, state, resource, permission, and environment failures, which appear only when the parts run together.
- Test behaviour through public interfaces, so a refactor that keeps behaviour keeps the tests green.
- Tests are deterministic: they control time, randomness, network, and ordering.
A flaky test is a bug; fix it when you see it.

## Verification levels

`scripts/verify.sh` runs these in order and stops at the first that fails, so a passing unit test can never hide a broken build or a broken flow.

| Level | Proves | Lives in |
| --- | --- | --- |
| 1 Static | The code is well formed: format, lint, type-check | `run_static` in `scripts/verify.sh` |
| 2 Tests and startup | Units and their integrations behave, and the project actually starts | `run_tests` and `run_startup` |
| 3 End to end | Each `passing` feature's user flow still works through the real interface | Each feature's `verify` in `docs/features.json` |

Drive end-to-end flows through what a user touches: a browser-automation suite (such as Playwright) for a web UI, the built binary for a CLI, real HTTP calls against the running server for an API, and computer use for a desktop or mobile app.
Scripted flows catch regressions on every run; an independent evaluator walking the flow with computer use or a browser catches what scripts do not look at, such as layout, copy, and states a test never reaches.
The walker is never the agent that wrote the code (`docs/loops.md`).
Both are part of the Definition of Done.

## Reference

- TODO(project): Test data: fixtures, factories, and how a test gets a database or other service.
- TODO(project): The end-to-end tool, how a flow test starts the project, and how an agent reaches the running app with computer use or a browser.

## Checklist

- [ ] The new test fails without your change and passes with it.
- [ ] `scripts/verify.sh` passes every level, and the `evaluator` subagent's verdict on the running project is `PASS`.
