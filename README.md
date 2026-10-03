<img src="assets/icon.svg" width="64" height="64" alt="">

# ai-coding-project-boilerplate

A starting point for projects built with AI coding agents.
It ships the harness an agent needs from the first session: instructions (`AGENTS.md`, `docs/`), state (`PROGRESS.md`, `DECISIONS.md`, restored automatically after compaction), a reproducible setup (`scripts/setup.sh`), and one verification command (`scripts/verify.sh`) that also runs as a pre-commit hook and in CI.

## Start a project

1. Clone or fork this repository, then run `scripts/setup.sh`.
2. Give your agent the idea.
It runs the one-time initialization in `docs/initialization.md`: stack, environment, tests, docs, and a first task list, committed as one checkpoint.
3. Every session after that starts from the saved state and picks up the next task.

## Maintain the boilerplate

`harness/` records the notes this boilerplate is built from and the reason behind each file.
See `harness/README.md` to add a new chapter.

Created in [T3 Code](https://t3.codes).
