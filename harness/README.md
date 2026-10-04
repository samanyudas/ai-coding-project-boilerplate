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
- `PROGRESS.md`, `DECISIONS.md`, and `docs/features.json` stay templates in the boilerplate, so every fork starts clean.
Boilerplate progress is tracked by the chapter index below.

## Chapters

| # | Chapter | Repo changes |
| --- | --- | --- |
| 01 | [Why capable agents still fail](notes/01-why-capable-agents-still-fail.md) | `AGENTS.md`, `CLAUDE.md`, `scripts/verify.sh` |
| 02 | [What a harness actually is](notes/02-what-a-harness-actually-is.md) | `AGENTS.md` split into `docs/`, `PROGRESS.md`, `scripts/setup.sh`, pre-commit hook, CI |
| 03 | [Why the repository must be the single source of truth](notes/03-repo-as-single-source-of-truth.md) | Run and Where knowledge goes in `AGENTS.md`, module docs, `scripts/check-module-docs.sh`, unfilled-slot check, fresh session test |
| 04 | [Split instructions across files](notes/04-split-instructions-across-files.md) | `AGENTS.md` reordered with hard constraints and a routing table, `docs/documentation.md`, `docs/testing.md`, `docs/security.md`, size and constraint limits, monthly audit issue |
| 05 | [Keeping context alive across sessions](notes/05-keeping-context-alive-across-sessions.md) | `PROGRESS.md` reshaped, `DECISIONS.md` with a format check, `scripts/restore-state.sh` and its Claude Code hook, `PROGRESS.md` reminder |
| 06 | [Why initialization needs its own phase](notes/06-initialization-as-its-own-phase.md) | `docs/initialization.md`, `scripts/check-ready.sh` with a setup fingerprint, tasks with acceptance criteria, task-first Quick start |
| 07 | [Why agents overreach and under-finish](notes/07-why-agents-overreach-and-under-finish.md) | One Tasks list with statuses in `PROGRESS.md`, WIP = 1 check, scope and parallel-agent hard constraints, end-to-end acceptance |
| 08 | [Why feature lists are harness primitives](notes/08-feature-lists-as-harness-primitives.md) | `docs/features.json`, `scripts/feature.sh` as the only state changer, evidence on pass, re-verification of passing features in `scripts/verify.sh`, Feature list rules in `AGENTS.md` |
| 09 | [Why agents declare victory too early](notes/09-why-agents-declare-victory-too-early.md) | Gated levels in `scripts/verify.sh` (`--upto`), `scripts/feature.sh verify` gated on levels 0 to 2, leveled Definition of Done with a hands-on end-to-end walk, verification levels in `docs/testing.md` |
| 10 | [Why end-to-end testing changes results](notes/10-why-end-to-end-testing-changes-results.md) | `docs/architecture.json` (components, integration test paths, rules with why and fix), `scripts/review-change.sh` with the cross-component reminder, what-why-fix failure messages |
| 11 | [Why observability belongs inside the harness](notes/11-why-observability-belongs-inside-the-harness.md) | Run evidence under `.harness/runs/` (per-check logs, `summary.json`), last result in `scripts/restore-state.sh`, CI evidence upload, `docs/observability.md`, diagnose-before-retry constraint, verification report |
| 12 | [Why every session must leave a clean state](notes/12-why-every-session-must-leave-a-clean-state.md) | `scripts/end-session.sh`, `.harness/scratch/`, `TEMP(debug)` marker check, `scripts/scan.sh` weekly report, `maintenance.yml` (weekly cleanup and monthly audit), `docs/cleanup.md`, shared `scripts/lib/limits.sh` |
| 13 | [From manual prompting to autonomous loops](notes/13-from-manual-prompting-to-autonomous-loops.md) | `docs/loops.md` (goal contract, loop types, primitives, ratchet, silent costs), `scripts/feature.sh remaining` stop condition, `evaluator` subagent, independent evaluator in the Definition of Done |
| 14 | [From single loops to graph engineering](notes/14-from-single-loops-to-graph-engineering.md) | `docs/graph.md` (nodes, routing, shared state, design questions, anchors), graph-to-code path check, Goodhart guard on passing contracts, fresh-context evaluator, branch-and-pull-request goal contract |
| 15 | [Clear agent instructions](notes/15-clear-agent-instructions.md) | Shorter agent procedures, explicit conditions and verdicts, writing guidance in `docs/documentation.md`, unchanged commands and completion requirements |
