# Harness notes

This folder holds the harness-engineering notes this boilerplate is built from, and the reason behind each file it contains.
It is for maintaining the boilerplate, not for building projects.
`AGENTS.md` says what to do; this folder says why.

A project started from this boilerplate deletes this folder.
Nothing outside it depends on it.

## Adding a new chapter

1. Save the cleaned-up notes as `notes/NN-slug.md` with three sections: Notes, Repo changes, and Design choices.
2. Turn each lesson into repo changes: add, edit, or delete files.
When a lesson can be enforced by a script or check, enforce it rather than adding prose.
3. When a lesson replaces an earlier decision, change the files, say which decision it replaces in the new chapter, and add a `Superseded by` line under that decision in the old chapter.
4. Add the chapter to the index below.
5. Run `scripts/verify.sh` and commit the chapter as one commit.

## Cross-chapter decisions

- `AGENTS.md` is the entry point for every agent, and it points to every other doc.
Tool-specific files such as `CLAUDE.md` only import it, so every agent tool reads the same rules.
- Rationale lives here, not in `AGENTS.md`.
`AGENTS.md` is loaded every session, so it holds only what changes the agent's behaviour.
- Unfilled project slots are written `TODO(project)` so `rg 'TODO\(project\)'` lists everything a new project must fill in.
- `PROGRESS.md` and `DECISIONS.md` stay templates in the boilerplate, so every fork starts clean.
Boilerplate progress is tracked by the chapter index below.

## Chapters

| # | Chapter | Repo changes |
| --- | --- | --- |
| 01 | [Why capable agents still fail](notes/01-why-capable-agents-still-fail.md) | `AGENTS.md`, `CLAUDE.md`, `scripts/verify.sh` |
| 02 | [What a harness actually is](notes/02-what-a-harness-actually-is.md) | `AGENTS.md` split into `docs/`, `PROGRESS.md`, `scripts/setup.sh`, pre-commit hook, CI |
| 03 | [Why the repository must be the single source of truth](notes/03-repo-as-single-source-of-truth.md) | Run and Where knowledge goes in `AGENTS.md`, module docs, `scripts/check-module-docs.sh`, unfilled-slot check, fresh session test |
| 04 | [Split instructions across files](notes/04-split-instructions-across-files.md) | `AGENTS.md` reordered with hard constraints and a routing table, `docs/documentation.md`, `docs/testing.md`, `docs/security.md`, size and constraint limits, monthly audit issue |
| 05 | [Keeping context alive across sessions](notes/05-keeping-context-alive-across-sessions.md) | `PROGRESS.md` reshaped, `DECISIONS.md` with a format check, `scripts/restore-state.sh` and its Claude Code hook, `PROGRESS.md` reminder |
