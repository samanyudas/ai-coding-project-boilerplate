# Conventions

Rules the code follows.
A rule stays written here only while no tool can check it; Checks below says how it becomes one, and the written rule is then deleted.

## Architecture

- TODO(project): Layers, module boundaries, and where new code goes.

The part a tool can check lives in `docs/architecture.json`, which `scripts/verify.sh` enforces at level 1:

- `components`: each component's `name` and `path`. `scripts/review-change.sh` flags a change that spans two or more of them without touching an integration or end-to-end test.
- `integration_tests`: the paths where tests that cross components live.
- `rules`: each forbids a pattern (an extended regex) in a set of files, such as UI code importing the database layer:

```json
{
  "name": "ui-uses-api-not-db",
  "files": ["src/ui/**"],
  "forbid": "from ['\"].*/db",
  "why": "UI code that reaches the database skips the validation and permissions in src/api.",
  "fix": "Call the matching function in src/api instead."
}
```

When the language has a dedicated tool (dependency-cruiser, import-linter, ArchUnit), use it in `run_static` instead; keep these rules for what it cannot express.

## Checks

- Every failure message says what broke, why it matters, and how to fix it, so the agent can act on the first read.
- An issue a review raises twice becomes a permanent check: a rule in `docs/architecture.json`, a lint rule, a test, or a check in `scripts/verify.sh`.
Advice that should not block a commit goes in `scripts/review-change.sh` instead.

## Code

- TODO(project): Naming, error handling, and logging patterns.
- TODO(project): Patterns to use, each with its reason (e.g. "Use SQLAlchemy 2.0 `select()`; the codebase has no 1.x queries").
