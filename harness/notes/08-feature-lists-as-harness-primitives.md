# 08 - Why feature lists are harness primitives

## Notes

The issue: with no clear definition of "done", the agent decides completion itself.
That leads to partially implemented features, untested functionality, scope creep, and repeated work across sessions.

The fix is a version-controlled `features.json` as the single source of truth, where each feature has:

- Behavior: what it must do, as measurable acceptance criteria.
- Verification: the exact test or command that proves it works.
- State: `not_started` → `active` → `passing` (or `blocked`).
- Evidence: test results and a commit reference.

Workflow: select one incomplete feature → implement → run its verification → on pass, mark it `passing` and record evidence; on failure, fix it or mark it `blocked` → repeat.

Rules:

- One active feature per agent.
- Only the verification harness can mark a feature `passing`.
- Keep features small enough to finish and verify independently.

Revalidate passing features after relevant code changes; a previous pass does not guarantee they still work.

Result: explicit scope, objective completion criteria, less agent drift, easier session recovery, and verifiable progress.

The chapter suggests adding these rules to `AGENTS.md`:

```text
## Feature List Rules
- Feature list file: /docs/features.md
- Only one feature active at a time
- Verification command must pass before marking as passing
- Don't modify feature list states yourself; the verification script updates them automatically
```

## Repo changes

- `docs/features.json`: created, empty in the boilerplate; each feature has `id`, `title`, `behavior`, `verify`, `state`, `blocked_by`, and `evidence`.
- `scripts/feature.sh`: created; `list`, `start` (refuses a second active feature), `verify` (runs the feature's command and, only on a pass, sets `passing` with evidence), and `block` (requires a reason).
- `scripts/verify.sh`: the task check became a feature check (shape, known states, reasons on blocked features, evidence on passing ones, unique ids, WIP = 1, at least one feature once initialized) and re-runs every `passing` feature's `verify` command.
- `AGENTS.md`: a Feature list rules section after Hard constraints; Quick start starts features through the script; the WIP and scope constraints folded into the new section; the repo map, routing table, and Definition of Done point at features.
- `PROGRESS.md`: reduced to notes on how far the active feature got.
- `scripts/restore-state.sh`: prints `scripts/feature.sh list` first.
- `scripts/check-stale-docs.sh`: the reminder accepts a change to either `docs/features.json` or `PROGRESS.md`.
- `scripts/setup.sh` and `scripts/check-ready.sh`: require `jq`.
- `docs/initialization.md`, `docs/testing.md`, `docs/tools.md`, `docs/harness-audit.md`, `README.md`: tasks became features.

## Design choices

Why JSON in `docs/`, when the suggested rules named `/docs/features.md`:
the same rules say the verification script updates states automatically, and a script can rewrite JSON reliably with `jq`, while editing a Markdown list by script is fragile.
The file sits in `docs/` as the rules asked, and the chapter itself names `features.json`.

Why "only the harness marks passing" is enforced by re-verification, not by detecting hand edits:
a hand-set `passing` state is harmless if its verification really passes, and caught if it does not.
`scripts/verify.sh` re-runs every `passing` feature's command, so through the pre-commit hook and CI no commit can hold a `passing` feature whose verification fails.
A `passing` feature without evidence is also refused, which catches the common hand edit.

Why every `passing` feature is re-verified on every run, instead of only after "relevant" changes:
deciding relevance needs a map from features to code that would itself go stale.
Running them all is simple and complete; the cost is kept down by requiring each `verify` to be a focused test, which `docs/testing.md` states.
A project whose feature tests grow slow can add path filtering then, with a measurement to justify it.
Superseded by [09](09-why-agents-declare-victory-too-early.md): re-verification became level 3 of `scripts/verify.sh`, and `scripts/feature.sh verify` now runs levels 0 to 2 before a feature's own flow.

Why `verify` cannot call `scripts/verify.sh`:
re-verification runs inside `scripts/verify.sh`, so that command would recurse forever.

Why the evidence records the commit the change was verified on, with an `uncommitted_changes` flag:
verification runs before the commit that carries the change, so that commit's hash does not exist yet.
The parent commit plus the flag pins it, and the change itself is the next commit in `git log`.

Why `PROGRESS.md` keeps only active feature notes:
scope, order, state, and blocked reasons moved into `docs/features.json`, so a second list would be a second source of truth.
What remains is the one thing the feature list cannot hold: how far the active feature got and what was tried, which is what a compacted session needs.
Test status went too, because failing and pending work is now a feature state.

Why `AGENTS.md` dropped two lines that tools already say:
the restore output tells the agent to resolve uncommitted changes, and `scripts/verify.sh` reports the hard-constraint limit when it is hit, so restating them only cost lines under the 100-line limit.
