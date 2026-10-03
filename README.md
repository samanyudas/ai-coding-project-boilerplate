<img src="assets/icon.svg" width="64" height="64" alt="">

# ai-coding-project-boilerplate

A starting point for projects built with AI coding agents.
It ships the harness an agent needs from the first session: instructions (`AGENTS.md`, `docs/`), state (`PROGRESS.md`), a reproducible setup (`scripts/setup.sh`), and one verification command (`scripts/verify.sh`) that also runs as a pre-commit hook and in CI.

## Start a project

1. Clone or fork this repository, then run `scripts/setup.sh`.
2. Give your agent the idea and ask it to start a project from this boilerplate.
It follows "Starting a project from this boilerplate" in `AGENTS.md`.
3. Run `scripts/verify.sh` to check the result.

## Maintain the boilerplate

`harness/` records the notes this boilerplate is built from and the reason behind each file.
See `harness/README.md` to add a new chapter.

Created in [T3 Code](https://t3.codes).
