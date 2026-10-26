# Review

What a reviewer of a diff here reports, and how a review ends.
The `reviewer` subagent (`.claude/agents/reviewer.md`) reads this file, and so does any human or hosted reviewer.
When a review misses a bug or raises noise, fix this file in the same commit as the fix.

## Report these

- The change does not do what its feature contract or pull request says.
- The change breaks a caller, another component, or a passing feature.
- A doc, comment, or `AGENTS.md` line no longer matches the code: the docs must not lie.
- Config, routing, or a hook sends work to the wrong place.
- A secret, an unvalidated input, or a credential wider than its job (`docs/security.md`).
- A weaker gate: a check, test, hook, CI step, or passing contract made easier to pass.
- For a bug fix, a fix of the symptom instead of the root cause.
- TODO(project): Failures specific to this project, one per line.

## Skip these

- Anything a formatter, linter, or type checker in `scripts/verify.sh` already covers.
- Preferences with no failure scenario.
- Run evidence under `.harness/`.
- TODO(project): Generated or vendored paths.

## Each finding

1. Cite the file and line from the diff or the code it calls.
Never guess a filename.
2. Give a severity:
   - **Important**: a failure scenario a user, caller, or later change hits.
   - **Nit**: worth fixing, and never blocks a merge.
   - **Pre-existing**: a bug that the change did not introduce.
3. Name the bug class, so the author fixes every instance and not only the cited line.
4. Describe the failure: the input or step, then the wrong result.

## The report

Open with one line of counts per severity, or "No issues found."
Then list the findings, Important first.

## Converging

- The author fixes each Important finding, or answers it with a reason.
- A Nit or Pre-existing finding never blocks.
The author resolves it with a short reason, or records it as a `not_started` feature.
- After the first cycle, review only the changes since the last review, as `.claude/agents/reviewer.md` describes.
- Never report a finding again after the author fixed or answered it.
- Every review run counts as a cycle, including one after an evaluator FAIL.
- When the third cycle still has an Important finding, stop patching and discard the attempt (`AGENTS.md` hard constraint 4).
In a loop, block the feature (`docs/loops.md`).
In an interactive session, rethink the approach or ask a human.
- When reviews raise the same issue twice, add a check for it (`docs/documentation.md`).
