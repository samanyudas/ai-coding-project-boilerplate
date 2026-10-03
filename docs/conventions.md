# Conventions

Rules the code follows.
Prefer executable rules: when the same correction comes up twice, turn it into a lint rule, a check in `scripts/verify.sh`, a hook, or a CI step, then delete the written rule it replaces.
A rule stays in this file only while no tool can check it.

## Architecture

- TODO(project): Layers, module boundaries, and where new code goes.

## Code

- TODO(project): Naming, error handling, and logging patterns.
- TODO(project): Patterns to use, each with its reason (e.g. "Use SQLAlchemy 2.0 `select()`; the codebase has no 1.x queries").
