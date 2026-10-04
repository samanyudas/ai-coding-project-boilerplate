# Periodic writing review

## Notes

The writing rules from chapter 15 need a repeatable check after later edits.
The existing Monday cleanup report already collects findings for human review.
Add writing findings to that report rather than introducing a separate schedule or duplicate issue.

The check applies selected ASD-STE100 structural rules and does not certify full compliance.
The official approved-word dictionary is not included.
Keep all findings visible because a baseline can hide existing problems.
Review synonym and grammar heuristics against the intended meaning before changing a sentence.

## Repo changes

- `scripts/check-ste.py` discovers maintained Markdown and returns findings separately from operational errors.
- `scripts/lib/ste_lint.py` preserves the MIT linter from skill version 0.4.0 unchanged.
`scripts/lib/ste_lint.LICENSE` preserves its copyright and license.
- `scripts/scan.sh` adds the writing report to the weekly cleanup issue body.
The existing maintenance workflow supplies the schedule and manual trigger.
- `scripts/test-ste.py` tests the real CLI with temporary repositories.
`scripts/verify.sh` runs these tests at level 2, and `scripts/setup.sh` checks for Python 3.
- `AGENTS.md`, `docs/documentation.md`, `docs/tools.md`, `docs/testing.md`, and `docs/cleanup.md` describe discovery, review, and verification.

## Design choices

Two independent design sketches compared a Python CLI with a shell wrapper.
The cross-judge and maintainer selected Python for simpler file discovery, result aggregation, and error handling.
Keep the existing Bash scan as the integration point.
Use Git's NUL-delimited inventory to preserve file names with spaces and include untracked docs.
Keep linter findings and operational errors in separate lists.
Use exit codes `0`, `1`, and `2` for no findings, findings, and operational errors respectively.

The scan remains advisory, including when the writing check cannot complete.
Such failures appear explicitly in the report and do not prevent the remaining cleanup report.
Historical harness notes stay outside the writing scope.
Boilerplate feature, progress, and decision files remain clean templates.

Test file discovery, exclusions, deleted files, locations, advisory-only findings, protected uncertainty, fenced code, and operational failures.
Run the imported linter's self-test to preserve its existing regression coverage.
Verify the full cleanup report through `scripts/scan.sh`.

The 13 CLI tests passed on Python 3.9.6 and 3.14.8, including the imported linter's self-test.
Independent review found unreadable-file aggregation and root-resolution gaps that the regression tests reproduced before correction.
The corrected check reports both as operational errors while preserving available findings.
`scripts/verify.sh` passed levels 0 to 3, and the full weekly report included the writing section.
The GitHub maintenance workflow was active before publication.
