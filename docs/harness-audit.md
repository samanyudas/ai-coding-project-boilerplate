# Harness audit

The harness rots like code does.
Audit it monthly, and whenever agent results get worse, then pay down what you find the same way you pay down technical debt.

## Checklist

1. **Tools.**
List every tool, MCP server, plugin, and hook configured for this project.
Uninstall each one no recent task used, and keep `docs/tools.md` in sync.
2. **Instructions.**
Read `AGENTS.md` and `docs/` against the code.
Fix or delete every line that is stale, that the agent follows without being told, or that a check now enforces.
3. **Executable rules.**
For each written rule agents still break, add a check in `scripts/verify.sh`, a hook, or a CI step.
4. **Environment.**
Run `scripts/setup.sh` in a fresh clone.
It must succeed with no manual steps.
5. **Feedback.**
Break something on purpose and confirm `scripts/verify.sh` fails.
6. **State.**
Confirm `PROGRESS.md` matches reality.
7. **Fresh session test.**
Start a new agent session with no prior context and ask it five questions.
Each answer must come from the repo, and match reality:
   - What is this system?
   - How is it organized?
   - How do I run it?
   - How do I verify it?
   - What is the current state?

   Every wrong or missing answer is a gap in `AGENTS.md`, `PROGRESS.md`, or a module doc; fix it there.

## Ablation test

Use this when unsure whether a part of the harness earns its cost.

1. Pick 5 to 10 representative tasks, each with a clear pass condition.
2. Run them with the full harness and record the success rate.
3. Remove one part (a doc, a tool, a check), re-run, and record the success rate.
4. Restore that part and repeat for the next one.

A large drop means the part matters.
No drop means the part costs context without helping: remove it or rework it.
For example, if removing tests drops success from 85% to 55% and removing lint drops it to 82%, tests carry far more weight.

## Audit log

| Date | Findings | Changes |
| --- | --- | --- |
