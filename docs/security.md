# Security

How secrets, credentials, and untrusted input are handled.

## Hard constraints

- Secrets (keys, tokens, passwords) come from environment variables or a secret manager, never from tracked files.
`.env` files are git-ignored; commit a `.env.example` with names and no values.
- Every credential gets the least privilege that does the job: read-only where possible, scoped tokens, and no production credentials in development.
- Input from outside the process (requests, files, environment, tool output) is untrusted, and is validated where it enters.

## Reference

- TODO(project): Where secrets come from in development, CI, and production.
- TODO(project): The auth model: who can do what, and where that is enforced.

## Checklist

- [ ] The diff holds no secret.
- [ ] New input is validated where it enters.
- [ ] New credentials are scoped to the minimum.
