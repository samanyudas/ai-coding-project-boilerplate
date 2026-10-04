# Clear agent instructions

## Notes

Instructions become harder to follow when one sentence combines actions, conditions, and completion criteria.
Split those sentences without changing the requirements they express.
Place each condition before its dependent action.
Keep command names, feature states, evidence requirements, retry limits, and approval boundaries intact.

ASD-STE100 supplies useful rules for sentence structure and consistent terminology.
These adaptations do not establish full compliance with the standard's approved-word dictionary.
An automated style finding needs review because different actions can legitimately have different names.
For example, a readiness check and feature verification do not mean the same operation.

## Repo changes

- `AGENTS.md` separates feature rules and completion requirements into shorter sentences.
Its repo map preserves the reading conditions and links to writing guidance in `docs/documentation.md`.
- `docs/documentation.md` defines writing rules and preserves the concrete search-goal example.
- `.claude/agents/evaluator.md` separates input rules, interface checks, evidence collection, and verdict conditions.
- `docs/loops.md` separates the goal contract and measurement loop into ordered steps.
- `docs/observability.md` names the agent that records the evaluator's report and separates log requirements.

## Design choices

Keep the existing commands, feature states, retry budget, feature budget, evaluator independence, and human review before merge.
Keep `AGENTS.md` within its existing line limit by removing repeated details and using the existing topic docs.
Keep boilerplate state files as clean templates and record this work in the harness chapter index.

Use the optional skill's linter during review without adding a machine-local dependency to repository checks.
Review its findings rather than treating every warning as a required change.
The repository's existing verification and pre-commit checks remain the commit gates.
Future projects can add a portable style check if repeated writing problems justify it.

Verify the rewrite against the previous instructions, the linter's structural findings, and `scripts/verify.sh`.
A successful check proves the checked properties, not improved agent task success.

The structural scan passed with the optional linter's `synonym-rotation` heuristic disabled after review of its findings.
`scripts/verify.sh` passed levels 0 to 3, and `scripts/review-change.sh` reported no warnings.
An independent reader confirmed that the revised instructions preserve the existing requirements.
That review checked the corrected unconditional rule, "Never swallow an error," and the evaluator's folded YAML description.
