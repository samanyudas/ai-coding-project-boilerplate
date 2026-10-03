# Documentation

How the docs in this repo are placed, structured, and kept true.
Every doc goes stale as the code moves, and a wrong doc is trusted like a right one.

## Hard constraints

- `AGENTS.md` stays a map: overview, quick start, at most 15 global hard constraints, and links.
Everything else lives in the place the routing table below names.
- A topic doc stays under 150 lines, ideally 50 to 150.
`scripts/verify.sh` enforces both limits; split a file that reaches one by topic, rather than raising it.
- Every doc in `docs/` and every module doc is linked from the repo map, with the condition for reading it.
An agent reads only what the map tells it exists.
- Update a doc in the same commit as the code it describes.
`scripts/review-change.sh` warns when a module changed without its docs.

## Routing a rule or piece of knowledge

Search for an existing rule on the same subject first, and change it rather than adding one that conflicts.
Then put it in the first place that fits, in the same commit as the change it describes:

| What it is | Where it goes |
| --- | --- |
| Checkable by a tool, or raised twice in review | A test, a lint rule, a rule in `docs/architecture.json`, or a check in `scripts/verify.sh` |
| True for every task | Hard constraints in `AGENTS.md` |
| A project-wide decision and its reasons | `DECISIONS.md` |
| About one topic (API, database, security, testing) | `docs/<topic>.md`, linked in the repo map |
| About one module | That module's `ARCHITECTURE.md` or `CONSTRAINTS.md`, linked in the repo map |
| About specific code | Types, interfaces, and comments in the source |
| A new feature, or an improvement noticed along the way | A `not_started` feature in `docs/features.json` |
| How far the active feature got | `PROGRESS.md` |

## Placing a doc

- **Topic docs** go in `docs/<topic>.md`: one per subject such as API, database, security, or testing.
Add one when the project gains the topic, not before.
- **Module docs** go beside the code: `ARCHITECTURE.md` for a module's decisions and their reasons, `CONSTRAINTS.md` for its hard rules.
Anyone changing the module then sees them.
- **Code-level knowledge** goes in the source: types, interfaces, and comments next to the code they explain.

## Writing a doc

- Write what the code cannot say: decisions and their reasons, hard constraints, and gotchas.
Anything a reader can learn from the code or a config file stays there, where it cannot drift.
- Agents attend to the top and bottom of a long file and skim the middle.
For any doc past about 50 lines:
  - Open with a quick start and the hard constraints.
  - Put reference material in the middle.
  - Close with a checklist the reader runs before finishing.

## Checklist

- [ ] The doc is in the place the routing table names, and linked from the repo map with when to read it.
- [ ] It says nothing the code or config already says.
- [ ] No other doc holds a rule that conflicts with it.
- [ ] `scripts/verify.sh` passes.
