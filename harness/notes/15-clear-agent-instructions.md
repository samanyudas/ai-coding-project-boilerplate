# Clear agent instructions and periodic writing review

## Notes

Instructions become harder to follow when one sentence combines actions, conditions, and completion criteria.
Split those sentences without changing the requirements they express.
Place each condition before its dependent action.
Keep command names, feature states, evidence requirements, retry limits, and approval boundaries intact.

ASD-STE100 supplies useful rules for sentence structure and consistent terminology.
These adaptations do not establish full compliance with the standard's approved-word dictionary.
An automated style finding needs review because different actions can legitimately have different names.
For example, a readiness check and feature verification do not mean the same operation.

Clear instructions also need a repeatable check after later edits.
The existing Monday cleanup report collects writing findings for human review without a separate schedule or duplicate issue.
Keep all findings visible because a baseline can hide existing problems.

## Repo changes

- `AGENTS.md` separates feature rules and completion requirements into shorter sentences.
Its repo map preserves the reading conditions and links to writing guidance in `docs/documentation.md`.
- `docs/documentation.md` defines writing rules, the periodic check, and its limits, and preserves the concrete search-goal example.
- `.claude/agents/evaluator.md` separates input rules, interface checks, evidence collection, and verdict conditions.
- `docs/loops.md` separates the goal contract and measurement loop into ordered steps.
- `docs/observability.md` names the agent that records the evaluator's report and separates log requirements.
- `scripts/check-ste.py` discovers maintained Markdown and reports findings separately from operational errors.
- `scripts/lib/ste_lint.py` preserves the MIT linter from skill version 0.4.0 unchanged.
`scripts/lib/ste_lint.LICENSE` preserves its copyright and license.
- `scripts/scan.sh` adds the writing report to the weekly cleanup issue body.
The existing maintenance workflow supplies the schedule and manual trigger.
- `scripts/test-ste.py` tests the real CLI with temporary repositories.
`scripts/verify.sh` runs these tests at level 2, and `scripts/setup.sh` checks for Python 3.8 or later.
- `docs/tools.md`, `docs/testing.md`, and `docs/cleanup.md` describe the linter's provenance, regression tests, and review process.

## Design choices

Keep the existing commands, feature states, retry budget, feature budget, evaluator independence, and human review before merge.
Keep `AGENTS.md` within its existing line limit by removing repeated details and using the existing topic docs.
Keep boilerplate state files as clean templates and record this work in the harness chapter index.

Use the repository's imported linter for the recurring check without depending on a locally installed skill.
The optional `asd-ste100` skill can help review and rewrite unclear passages.
Review findings against the intended meaning rather than treating every warning as a required change.
The writing report is advisory, while its regression tests run through the existing verification and pre-commit gates.

Two independent design sketches compared a Python CLI with a shell wrapper.
The cross-judge and maintainer selected Python for simpler file discovery, result aggregation, and error handling.
Keep the existing Bash scan as the integration point.
Use Git's NUL-delimited inventory to preserve file names with spaces and include untracked docs.
Keep linter findings and operational errors in separate lists.
Use exit codes `0`, `1`, and `2` for no findings, findings, and operational errors respectively.

The periodic check keeps every finding visible, including advisory findings, without a baseline or disabled rules.
Operational failures remain visible and do not prevent the remaining cleanup report.
Historical harness notes stay outside the periodic writing scope.
The linter cannot check the official approved-word dictionary or reliably distinguish instructions from explanations.
Its sentence cap is 25 words, and reviewers must still check the 20-word instruction target and preserve meaning.

Verify rewrites against the previous instructions, structural findings, and `scripts/verify.sh`.
A successful check proves the checked properties, not improved agent task success.
An independent reader confirmed that the instruction rewrite preserved the existing requirements.
That review checked the unconditional rule, "Never swallow an error," and the evaluator's folded YAML description.
During the instruction rewrite, the structural scan passed with `synonym-rotation` disabled after review of its findings.
`scripts/review-change.sh` reported no warnings for that rewrite.

The check's 13 CLI tests passed on Python 3.9.6 and 3.14.8, including the imported linter's self-test.
They cover discovery, exclusions, deleted files, locations, advisory findings, protected uncertainty, fenced code, and operational failures.
Independent review found unreadable-file aggregation and root-resolution gaps that the tests reproduced before correction.
The corrected check reports both as operational errors while preserving available findings.
`scripts/verify.sh` passed levels 0 to 3, and the full weekly report included the writing section.
