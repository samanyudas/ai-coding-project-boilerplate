# 02 - What a harness actually is

## Notes

A harness is everything around the model that helps it work reliably.
It has five parts:

| Part | Job | Example |
| --- | --- | --- |
| Instructions | Tell the agent what the project is, its rules, and its constraints. | `AGENTS.md` |
| Tools | Give it the actions the job needs, following least privilege. | Shell, file access, tests |
| Environment | Make dependencies, runtime, and setup reproducible. | `package.json`, `.python-version`, Docker |
| State | Preserve progress so a session does not restart from zero. | `PROGRESS.md` plus git commits |
| Feedback | Commands that objectively say whether the work is correct, listed explicitly in `AGENTS.md`. | `pytest`, lint, type-check, build |

Tools have a budget.
Every tool and MCP description is paid for on every turn, so ten focused tools beat fifty overlapping ones.
Setups are often over-tooled by two to three times: audit monthly and uninstall what is unused.
Tool design matters too: requiring absolute paths sharply cut errors.

The repo is the spec.
All necessary context lives in the repository, delivered through structured instruction files, explicit verification commands, and clear directory organization.

`AGENTS.md` is a map, not a manual.
Past 100 lines, split it into a `docs/` directory and let the agent read on demand.

Executable rules beat long instructions.
A good harness constrains the agent with rules that run, instead of listing instructions one by one.
For an individual, use hooks.
For a team or open-source project, encode it in `AGENTS.md`, tests, or CI that runs on push.

Run ablation tests: remove one part at a time and measure how much worse the harness gets.
If removing tests drops success from 85% to 55% and removing lint drops it to 82%, tests contribute far more.

Harness rots like code.
Audit regularly and pay down harness debt like technical debt.

## Repo changes

- `AGENTS.md`: rewritten as a map under 100 lines. Conventions moved to `docs/conventions.md`; environment commands moved to `scripts/setup.sh`; a Session start section now opens every session.
- `PROGRESS.md`: created; the state handoff between sessions.
- `docs/conventions.md`: created from the old Conventions section, now framed around executable rules.
- `docs/tools.md`: created; least privilege, the tool budget, and script design.
- `docs/harness-audit.md`: created; the monthly audit checklist, the ablation test, and an audit log.
- `scripts/setup.sh`: created; the one setup command. It enables the git hooks.
- `.githooks/pre-commit`: created; runs `scripts/verify.sh` before every commit.
- `.github/workflows/verify.yml`: created; runs `scripts/verify.sh` on every push and pull request.
- `scripts/verify.sh`: now also fails when `AGENTS.md` passes 100 lines or a file in `docs/` is missing from the map.

## Design choices

Each part of the harness has one home:

| Part | Home |
| --- | --- |
| Instructions | `AGENTS.md` as the map, `docs/` for detail read on demand |
| Tools | `docs/tools.md` |
| Environment | `scripts/setup.sh`, plus the pinned runtime file named in Tech stack |
| State | `PROGRESS.md` for where things stand, git commits for what was done |
| Feedback | `scripts/verify.sh`, with every check listed in `AGENTS.md` |

Why the 100-line limit is a check, not a sentence:
this chapter says executable rules beat instructions, and `AGENTS.md` was already 102 lines when the chapter arrived.
A written limit would have been broken the same way.

Why every `docs/` file must be in the map:
the map is how an agent learns a doc exists and when to read it.
A doc missing from the map is never read, so the check refuses it.
Each map entry for a doc says when to read it, because that condition decides whether the agent opens it.

Why both a git hook and CI:
the chapter asks for hooks for individual work and CI for team work.
A git `pre-commit` hook works for every agent tool and for humans, unlike an agent-specific hook, and `scripts/setup.sh` enables it so a fresh clone gets it.
CI catches anything committed without the hook.
Both run the same `scripts/verify.sh`, so they cannot disagree.

Why `scripts/setup.sh` replaces the written setup commands:
a script can be run and tested, and the audit runs it in a fresh clone; a list of commands in prose drifts.

Why `PROGRESS.md` holds the current state, not a log:
git already records what was done, with reasons in commit messages.
A file that only grows becomes sediment that each session must read through.
Superseded by [05](05-keeping-context-alive-across-sessions.md): `PROGRESS.md` gained a Done list, bounded to the current focus, and a Test status section.

Why the failure protocol now names the five parts:
they give a complete list to check, and each part has a single file to fix.

Not added: an agent-specific permission config for least privilege.
Permissions depend on the project's tools, so `docs/tools.md` states the rule and a project adds the config when it adds the tools.
