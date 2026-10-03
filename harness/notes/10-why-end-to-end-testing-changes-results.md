# 10 - Why end-to-end testing changes results

## Notes

The issue: unit tests can pass while real cross-component flows still fail.
Interface, state, resource, permission, and environment problems only appear when the full system runs.

The fix:

- Require integration or end-to-end verification for cross-component changes.
- Encode architectural rules as automated checks.
- Make failures explain what broke, why, and how to fix it.
- Convert repeated review issues into permanent harness checks.

## Repo changes

- `docs/architecture.json`: created, empty in the boilerplate; declares `components` (name and path), `integration_tests` (paths), and `rules` (files, a forbidden pattern, why, and fix).
- `scripts/verify.sh`: level 0 checks the file's shape and that its paths exist; level 1 runs every rule with `git grep` and reports each hit with its why and fix. The harness's own failure messages now say why each problem matters, not only what and how.
- `scripts/check-stale-docs.sh` renamed to `scripts/review-change.sh`, the automated reviewer; it adds a reminder when a change spans two or more components and no integration or end-to-end test changed.
- `.githooks/pre-commit`, `.github/workflows/verify.yml`, `docs/documentation.md`: point at the renamed script.
- `AGENTS.md`: the Definition of Done requires a crossing test for cross-component changes; the routing table sends issues raised twice in review to a check; the repo map lists `docs/architecture.json` with `docs/conventions.md`.
- `docs/conventions.md`: the machine-checked architecture and a rule example, plus a Checks section (what-why-fix messages, review issues raised twice become checks).
- `docs/testing.md`: cross-component changes need a test that crosses them.
- `docs/initialization.md`: declare components, test paths, and boundary rules during initialization.
- `docs/harness-audit.md`: the audit converts repeated review issues and reads failure messages for what, why, and fix.

## Design choices

Why a language-agnostic rule file instead of a dependency linter:
the boilerplate has no language yet, and a forbidden pattern over a set of files expresses the most common boundary ("this layer must not import that one") in any language.
`docs/conventions.md` says to prefer a dedicated tool once the language has one, and to keep these rules for what that tool cannot express.

Why every rule must carry `why` and `fix`:
the chapter asks failures to explain what broke, why, and how to fix it.
Making both fields required means no rule can be added that fails with only "violation found", and the check prints them under each hit.

Why the cross-component check is a reminder, not a gate:
whether a change needs a new crossing test is a judgement: a rename across components may already be covered by an existing feature flow, and a hard gate would push agents to touch a test file just to pass.
The gate that does exist is level 3: every `passing` feature's end-to-end flow re-runs on every commit, so cross-component regressions in covered flows still block it.

Why the reminder script was renamed to `scripts/review-change.sh`:
it now holds review advice of several kinds, not only stale docs.
The split is deliberate: `scripts/verify.sh` holds the gates, `scripts/review-change.sh` the advice, and an issue raised twice in review moves into one of them.

Why components are declared by path:
a path prefix is enough to tell which components a diff touches, works in every language, and is checked to exist so it cannot go stale silently.
