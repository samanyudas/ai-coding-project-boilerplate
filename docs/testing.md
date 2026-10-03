# Testing

How tests are written and run.

## Quick start

- TODO(project): Test framework and version, and where tests live.
- TODO(project): The command to run one test file, and the command for the whole suite.

## Hard constraints

- Every new or changed behaviour gets a test that fails without the change and passes with it.
- Test behaviour through public interfaces, so a refactor that keeps behaviour keeps the tests green.
- Tests are deterministic: they control time, randomness, network, and ordering.
A flaky test is a bug; fix it when you see it.

## Reference

- TODO(project): Test data: fixtures, factories, and how a test gets a database or other service.
- TODO(project): Which kinds of test the project uses (unit, integration, end-to-end), and what each covers.

## Checklist

- [ ] The new test fails without your change and passes with it.
- [ ] The full suite passes through `scripts/verify.sh`.
