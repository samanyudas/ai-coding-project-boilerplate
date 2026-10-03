# Documentation

How the docs in this repo are placed, structured, and kept true.
Every doc goes stale as the code moves, and a wrong doc is trusted like a right one.

## Hard constraints

- `AGENTS.md` stays a map: overview, quick start, at most 15 global hard constraints, and links.
Everything else lives in the place the table in "Adding a rule or knowledge" names.
- A topic doc stays under 150 lines, ideally 50 to 150.
`scripts/verify.sh` enforces both limits; split a file that reaches one by topic, rather than raising it.
- Every doc in `docs/` and every module doc is linked from the repo map, with the condition for reading it.
An agent reads only what the map tells it exists.
- Update a doc in the same commit as the code it describes.
`scripts/check-module-docs.sh` warns when a module changed without its docs.

## Placing a doc

- **Topic docs** go in `docs/<topic>.md`: one per subject such as API, database, security, or testing.
Add one when the project gains the topic, not before.
- **Module docs** go beside the code: `ARCHITECTURE.md` for a module's decisions and their reasons, `CONSTRAINTS.md` for its hard rules.
Anyone changing the module then sees them.
- **Code-level knowledge** goes in the source: types, interfaces, and comments next to the code they explain.

## Writing a doc

- Write what the code cannot say: decisions and their reasons, hard constraints, and gotchas.
Anything a reader can learn from the code or a config file stays there, where it cannot drift.
- Before adding a rule, search for one on the same subject (`rg`), and change it rather than adding a second that conflicts.
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
