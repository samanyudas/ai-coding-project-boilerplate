# 04 - Split instructions across files

## Notes

A large `AGENTS.md` hurts performance through a loop:
the agent makes a mistake, a rule is added, `AGENTS.md` grows, more irrelevant instructions load, context is wasted, the agent misses important rules, and more mistakes follow.

| Issue | Why it happens | Consequence |
| --- | --- | --- |
| Instruction bloat | Every mistake becomes a permanent rule | Higher token use and unnecessary reading |
| Lost in the middle | Critical rules are buried inside long documents | The agent may overlook important constraints |
| Conflicting instructions | New rules contradict older ones | Inconsistent behaviour |
| Knowledge decay | Code changes but instructions do not | The agent follows outdated information |
| Low signal-to-noise ratio | The agent reads instructions unrelated to its task | Less context for reasoning and code |

The fix is progressive disclosure.
`AGENTS.md` stays small and acts as a map and entry point that sends the agent to detailed docs only when needed: API work reads the API doc, database work reads the database doc.
The flow: task arrives → read `AGENTS.md` → identify the relevant docs → load only those → read code → execute → verify.

| Component | What belongs there |
| --- | --- |
| `AGENTS.md` | Overview, commands, up to about 15 global hard constraints, and doc links |
| Topic docs | Detailed instructions, ideally 50 to 150 lines each (API, database, security, testing) |
| Module directories | Documentation specific to each module |
| Source code | Types, interfaces, and implementation-specific comments |
| CI and linters | Automated enforcement of tests, style, and other verifiable requirements |

Long instruction files follow a shape: quick start and hard constraints at the top, an explicit checklist at the bottom.
Agents tend to skip the middle, so nothing critical goes there.

Each new rule goes where it belongs: global rules to `AGENTS.md`, topic rules to docs, module rules to module folders, and enforceable rules to CI or linters.
Links between docs reduce discovery cost without loading every doc.

Audit instructions regularly: remove outdated, duplicate, or conflicting rules, split oversized files, and keep the rest concise.
Implement it with a scheduled audit for cleanup, and CI that flags files over a configurable size limit.

Measure whether a split helped with an A/B test: run the same representative tasks before and after.
Input tokens and runtime should fall, success rate and constraint compliance should hold or improve, and instruction signal-to-noise ratio (relevant instructions ÷ total loaded) should rise.
Use at least five tasks, ideally with repeated runs, to separate real change from variation.
Measuring spends usage, so do it on a major refactor, periodically, or when regressions appear.

## Repo changes

- `AGENTS.md`: reordered into top (Quick start, Hard constraints), middle (Repo map, routing table, failure protocol), and bottom (Definition of Done as a checklist).
Run merged into Quick start, Verification merged into the checklist, and Where knowledge goes became the "Adding a rule or knowledge" table.
- `docs/documentation.md`: created; the doc rules moved out of `docs/conventions.md`, plus placement, size, and the top-and-bottom shape.
- `docs/testing.md`, `docs/security.md`: created as topic docs in that shape.
- `docs/tools.md`: credential rules moved to `docs/security.md`.
- `docs/harness-audit.md`: the instruction audit now covers duplicates, conflicts, and oversized files; the A/B test joins the ablation test.
- `scripts/verify.sh`: limits at the top of the file (100 lines for `AGENTS.md`, 150 for each topic and module doc, 15 hard constraints), and repo map lines may list several paths.
- `.github/workflows/harness-audit.yml`: created; opens a "Harness audit YYYY-MM" issue on the 1st of each month, once.
- `.gitignore`: created; ignores `.env` files, as `docs/security.md` requires.

## Design choices

Why `AGENTS.md` is ordered top, middle, bottom:
Quick start and Hard constraints come first because every task needs them, and the Definition of Done comes last as a checklist because it is the final step.
The middle holds the repo map and routing table, which are looked up, not read in order.
Superseded by [05](05-keeping-context-alive-across-sessions.md): the failure protocol moved to `docs/harness-audit.md` to make room for the state files.

Why the routing table puts "checkable by a tool" first:
the agent picks the first place that fits, so an enforceable rule never lands in prose.

Why the hard constraints are a numbered list:
`scripts/verify.sh` counts numbered items in that section, which makes the limit checkable.

Why only testing and security topic docs:
every project has tests and secrets, but not every project has an API or a database.
`docs/documentation.md` says to add a topic doc when the project gains the topic, so the boilerplate carries no empty API or database files.

Why doc rules moved out of `docs/conventions.md`:
documentation is its own topic, and an agent writing code does not need the rules for writing docs.

Why the limits fail the build instead of warning:
a warning on size gets ignored until the file is already bloated, and the chapter asks for CI to flag it.
The limits are variables at the top of `scripts/verify.sh`, so a project can change them in one place.

Why the scheduled audit is a GitHub issue:
an audit needs judgement, so a scheduled job cannot do it, but it can make sure it is not forgotten.
An issue works in every fork with no extra setup and no API keys, and the workflow skips the month if that month's issue is already open.

Not added: a check that long docs end in a checklist.
The shape is a judgement call per doc, and a heading check would reward an empty Checklist section.
