# Conventions

Rules the code follows.
Prefer executable rules: when the same correction comes up twice, turn it into a lint rule, a check in `scripts/verify.sh`, a hook, or a CI step, then delete the written rule it replaces.
A rule stays in this file only while no tool can check it.

## Architecture

- TODO(project): Layers, module boundaries, and where new code goes.

## Code

- TODO(project): Naming, error handling, and logging patterns.
- TODO(project): Patterns to use, each with its reason (e.g. "Use SQLAlchemy 2.0 `select()`; the codebase has no 1.x queries").

## Docs

Every doc goes stale as the code moves, and a wrong doc is trusted like a right one.
These rules keep the decay rate low.

- Write what the code cannot say: decisions and their reasons, hard constraints, and gotchas.
Anything a reader can learn from the code or a config file stays there, where it cannot drift.
- Put a doc next to what it describes.
Module decisions go in that module's `ARCHITECTURE.md`, and its hard rules in `CONSTRAINTS.md`, so anyone changing the module sees them.
- Lead with what matters most, so an agent finds it without reading the whole file.
- Update a doc in the same commit as the code it describes.
`scripts/check-module-docs.sh` warns when a module changed without its docs.
