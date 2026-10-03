# Harness audit

The harness rots like code does.
Fix it when a task fails, audit it monthly and whenever agent results get worse, and pay down what you find the same way you pay down technical debt.

## When a task fails

Look for the harness gap before switching the model or retrying.

1. Name which part of the harness failed: instructions, tools, environment, state, or feedback.
2. Ask why it failed, and fix that part in the repo, as an executable rule where possible: a check in `scripts/verify.sh`, a hook, or a CI step.
3. Re-run the task.

## Monthly checklist

`.github/workflows/harness-audit.yml` opens an issue on the 1st of each month as the reminder.

1. **Tools.**
List every tool, MCP server, plugin, and hook configured for this project.
Uninstall each one no recent task used, and keep `docs/tools.md` in sync.
2. **Instructions.**
Read `AGENTS.md` and every linked doc against the code.
Fix or delete every rule that is stale, duplicated, or in conflict with another, that the agent follows without being told, or that a check now enforces.
Move each hard constraint that is not truly global into its topic or module doc.
Split any doc near its size limit by topic.
3. **Executable rules.**
For each written rule agents still break, and each issue reviews raised more than once, add a check: a rule in `docs/architecture.json`, a check in `scripts/verify.sh`, a hook, or a CI step.
Read the failure messages too: each must say what broke, why, and how to fix it.
Check that a recent failure could be diagnosed from `.harness/runs/` and the project's logs alone.
4. **Environment.**
Run `scripts/setup.sh` in a fresh clone.
It must succeed with no manual steps.
5. **Feedback.**
Break something at each level on purpose and confirm `scripts/verify.sh` stops at that level with a message that says what to fix.
6. **State.**
Confirm `docs/features.json` and `PROGRESS.md` match reality, every `passing` feature's `verify` still tests its behavior, `DECISIONS.md` has no live decision missing, and `scripts/restore-state.sh` prints what a new session needs.
7. **Fresh session test.**
Start a new agent session with no prior context and ask it five questions.
Each answer must come from the repo, and match reality:
   - What is this system?
   - How is it organized?
   - How do I run it?
   - How do I verify it?
   - What is the current state?

   Every wrong or missing answer is a gap in `AGENTS.md`, `PROGRESS.md`, or a module doc; fix it there.
8. **Log.**
Record the findings and changes in the Audit log below, and close the month's issue.

## Measuring a harness change

Measuring costs real agent runs, so do it after a major restructure, when regressions appear, or periodically, not on every change.
Both tests below use the same setup:

- At least 5 representative tasks, each with a clear pass condition.
- Repeated runs of each task, so a real difference stands out from run-to-run variation.

### Ablation test

Use this when unsure whether a part of the harness earns its cost.

1. Run the tasks with the full harness and record the success rate.
2. Remove one part (a doc, a tool, a check), re-run, and record the success rate.
3. Restore that part and repeat for the next one.

A large drop means the part matters.
No drop means the part costs context without helping: remove it or rework it.
For example, if removing tests drops success from 85% to 55% and removing lint drops it to 82%, tests carry far more weight.

### A/B test

Use this to check that a restructure, such as splitting a doc, helped.
Run the tasks on the old version and the new one, and compare:

| Metric | Desired outcome |
| --- | --- |
| Input tokens | Decrease |
| Runtime | Decrease |
| Task success rate | Maintain or improve |
| Constraint compliance | Maintain or improve |
| Instruction signal-to-noise ratio | Increase |

Signal-to-noise ratio is the relevant instructions loaded for a task divided by all instructions loaded for it.
Keep the restructure only if success and compliance hold.

## Audit log

| Date | Findings | Changes |
| --- | --- | --- |
