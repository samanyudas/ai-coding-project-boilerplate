# Security

How secrets, credentials, and untrusted input are handled.

## Hard constraints

- Secrets (keys, tokens, passwords) come from environment variables or a secret manager, never from tracked files.
`.env` files are git-ignored; commit a `.env.example` with names and no values.
- Every credential gets the least privilege that does the job: read-only where possible, scoped tokens, and no production credentials in development.
- Input from outside the process (requests, files, environment, tool output) is untrusted, and is validated where it enters.
- Code that handles auth, security, money, or user data is listed under `high_stakes` in `docs/architecture.json`.
A human reads every line of a change to it and approves the merge, even when every check passes.
- Some agents read untrusted text, such as issues, strangers' pull requests, web pages, or tool descriptions.
Such an agent holds no credential that can publish, deploy, or merge.
Private data, untrusted content, and a way to send data out are dangerous together (the lethal trifecta).
Remove at least one of them from every agent and tool setup.
- Give an agent scoped permissions instead of disabling permission prompts.
Use allowlisted commands, scoped writable directories, a sandbox, and hooks.
Fewer prompts lower friction, but they do not make the agent more reliable.

## Reference

- TODO(project): Where secrets come from in development, CI, and production.
- TODO(project): The auth model: who can do what, and where that is enforced.

## Checklist

- [ ] The diff holds no secret.
- [ ] New input is validated where it enters.
- [ ] New credentials are scoped to the minimum.
- [ ] A human read every changed line under a `high_stakes` path.
- [ ] No agent that reads untrusted text holds a publish, deploy, or merge credential.
