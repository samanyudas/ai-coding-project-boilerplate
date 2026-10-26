# Security

How secrets, credentials, and untrusted input are handled.

## Hard constraints

- Secrets (keys, tokens, passwords) come from environment variables or a secret manager, never from tracked files.
`.env` files are git-ignored; commit a `.env.example` with names and no values.
- Every credential gets the least privilege that does the job: read-only where possible, scoped tokens, and no production credentials in development.
- Input from outside the process (requests, files, environment, tool output) is untrusted, and is validated where it enters.
- Code that handles auth, security, money, or user data is listed under `high_stakes` in `docs/architecture.json`.
A human reads every line of a change to it and approves the merge, even when every check passes.
- An agent's approval never satisfies a required human approval.
When an agent authors a pull request, the person who runs that agent is one of its required reviewers.
- An approval covers only the commit that the reviewer approved.
After a new commit from an agent or a hand-resolved merge, a human approves again.
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
- TODO(project): Where you configure the merge settings below, and each setting you leave off, with its reason.

### Merge settings

These are repository settings, not files, so a fork does not inherit them.
Set them on the default branch with branch protection or a ruleset:

1. Require a pull request and the `verify` status check before merge.
2. Require every review conversation to be resolved, so the author fixes or answers each finding.
3. Dismiss stale approvals when someone pushes a new commit.
4. Require a code owner's review, with a `CODEOWNERS` entry for each `high_stakes` path.
5. Give write access only to people, because GitHub counts an approval from any account with write access.
6. Use a merge queue once several branches merge each day, so checks run on `main` with each change applied.

## Checklist

- [ ] The diff holds no secret.
- [ ] New input is validated where it enters.
- [ ] New credentials are scoped to the minimum.
- [ ] A human read every changed line under a `high_stakes` path.
- [ ] Every required approval is from a human, on the latest commit.
- [ ] No agent that reads untrusted text holds a publish, deploy, or merge credential.
