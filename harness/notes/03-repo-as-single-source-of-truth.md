# 03 - Why the repository must be the single source of truth

## Notes

An agent has only three inputs: the system prompt and task description, file contents from the repository, and tool output.
Knowledge that lives only in Slack, Jira, Confluence, or someone's head does not exist for the agent.
The repo is the agent's brain.

**Discovery cost.**
Important information hidden deep makes the agent search more, which spends tokens and leaves less context for the task.
Keep important information near the top.
Put architecture docs in the module directory they describe: whoever modifies the code notices the doc, and CI can remind them to check it after a change.

```text
project/
├── AGENTS.md              # Entry: project overview, run commands, hard constraints
├── src/
│   ├── api/
│   │   └── ARCHITECTURE.md  # API layer architecture decisions
│   └── db/
│       └── CONSTRAINTS.md   # Database operation hard constraints
├── PROGRESS.md             # Current progress: done, in progress, blocked
└── Makefile                # Standardized commands: setup, test, lint, check
```

**Fresh session test.**
A fresh agent session should be able to answer from the repo alone:
what is this system, how is it organized, how do I run it, how do I verify it, and what is the current state.

**Knowledge decay.**
Code changes, old docs become wrong, people and agents trust the bad information, and mistakes follow.
The faster docs decay, the faster repo knowledge rots.

**Agent state as ACID.**
The repo never ends up half-broken or forgetful.

- Atomicity: finish it or throw it away. Code, tests, and verification are committed together; a failed attempt is discarded whole.
- Consistency: the repo ends healthy. A change is accepted only when tests, lint, and type-check still pass.
- Isolation: agents do not step on each other. Each works on its own branch or worktree, merged only when finished.
- Durability: important memory survives. Decisions and context go into git-tracked files that future agents can recover.

## Repo changes

- `AGENTS.md`: added Run and Where knowledge goes; isolation joined Session start and atomicity joined the Definition of Done; the start section now deletes itself on fork.
- `scripts/verify.sh`: module docs (`ARCHITECTURE.md`, `CONSTRAINTS.md`) must be in the repo map, and once `harness/` is gone any unfilled `TODO(project):` slot fails.
- `scripts/check-module-docs.sh`: created; warns when a module's files changed but its docs did not.
- `.githooks/pre-commit` and `.github/workflows/verify.yml`: also run `scripts/check-module-docs.sh`.
- `docs/conventions.md`: added the Docs section on keeping decay low.
- `docs/harness-audit.md`: added the fresh session test.

## Design choices

The fresh session test maps to files:

| Question | Answered by |
| --- | --- |
| What is this system? | `AGENTS.md` Project |
| How is it organized? | `AGENTS.md` Repo map, plus module docs |
| How do I run it? | `AGENTS.md` Run (added; nothing answered it before) |
| How do I verify it? | `AGENTS.md` Verification |
| What is the current state? | `PROGRESS.md` |

Why unfilled slots fail only after `harness/` is deleted:
an unfilled slot in a started project is a fresh-session question with no answer.
The boilerplate itself is all slots, so the check keys off the step that marks a project as started.
The marker it looks for is `TODO(project):` with a colon, so prose that mentions the marker does not trip it.

Why module docs must be listed in the repo map:
a module doc no agent knows about costs discovery tokens or is never read.
Listing it in the map puts it one read away from session start.

Why the stale-doc check warns instead of failing:
not every code change invalidates its module doc, so a hard gate would train agents to make empty doc edits to pass it.
A warning at commit time and in CI prompts the check the chapter asks for, and the agent sees it in the hook output.

Why ACID is split across existing sections instead of getting its own:
consistency is already the pre-commit hook, and durability is Where knowledge goes.
Atomicity belongs in the Definition of Done and isolation in Session start, where each one applies.
A separate section would have restated rules that already exist and pushed `AGENTS.md` over its 100-line limit, which happened in the first draft (111 lines) and the check caught it.

Why the start section now deletes itself:
after a fork it never applies again, and a section that never applies is discovery cost on every session.

Not added: a `Makefile`.
`scripts/setup.sh` and `scripts/verify.sh` already standardize the commands, and a second entry point would be a second source of truth.
