# Tools

Agents get the tools the job needs, and no more.

## Project tools

- `scripts/setup.sh` and `scripts/verify.sh`, described in `AGENTS.md`.
- TODO(project): Each CLI, MCP server, or agent plugin the project uses, with what it is for and where it is configured.

## Adding a tool

- **Least privilege.**
A tool gets only the access its job needs, such as a read-only mode or a scoped token.
Credentials follow `docs/security.md`.
- **Tool budget.**
Every tool and MCP server description is loaded on every turn, whether or not it is used.
Ten focused tools beat fifty overlapping ones.
Add a tool only when a task needs it, and record it under Project tools.
The harness audit removes the ones nobody uses.
- **One way to do each thing.**
When a command gets repeated, make it a script in `scripts/` and list it here, rather than having each session improvise its own.

## Designing a script

- It runs from any working directory and takes absolute paths, so it never depends on where it was launched.
Requiring absolute paths sharply cuts tool-call errors.
- It exits non-zero on failure and prints what failed and what to do next.
- It is safe to re-run.
