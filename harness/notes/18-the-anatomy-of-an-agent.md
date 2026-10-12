# 18 - The anatomy of an agent: model, harness, loop

Source: chapter 3 of the O'Reilly Early Release book on agentic engineering, plus the author's related article on loop engineering.

## Notes

Agent = model + harness (Viv Trivedy): "If you're not the model, you're the harness."
You rent the model, and everything else is yours: state, tools, environment, control flow, enforcement, persistence, and observability.
The same model scored near thirtieth in one harness and top five in another on Terminal-Bench.
LangChain moved gpt-5.2-codex from the bottom third to the top five of Terminal-Bench 2.0 by changing only the harness.
A decent model with a great harness usually beats a great model with a bad harness.

Most "model problems" are configuration problems (HumanLayer).
Agent failures are usually legible, so ask which harness addition would have prevented the failure.
The harness gap is your work, and the model gap is somebody else's roadmap.

The components, each boring and each load-bearing:

- Filesystem and git: the agent forgets, and the filesystem does not.
Small commits with honest messages let a human stay accountable for code they did not type.
- Bash: the field converged on giving the agent a shell instead of a fixed capability list.
- Sandbox: the sandbox is your blast radius.
In February 2026 a crafted GitHub issue title prompt-injected Cline's triage workflow, and a malicious package shipped under Cline's name.
An agent that reads strangers' issues has no business holding a publish token.
- Browser: an agent that sees its own rendering catches claims based only on desktop measurements.
- Memory and search: learning happens through context injection, so file-based memory is easy to build and debug.
- Tools and MCP: tool descriptions ride in every prompt as trusted text.
Treat an MCP server like an npm package from a stranger: read it and pin it.
"Commit every 20 minutes" is a hook, and "query this internal API" is a tool.
- Skills: loaded only when relevant (progressive disclosure).
A skill that never fires is pure cost, and one that fires without changing behavior only looks like coverage.
- Hooks: the enforcement layer, which separates "told the agent" from "the system enforces".
Block force pushes and dangerous deletes at the hook layer.
Success is silent, and failure is loud.
- Observability: prompts, responses, tool calls, timing, and token cost per turn.
Model routing and reasoning effort are harness choices paid on every run.

Every mistake becomes a rule.
Add a constraint only after a real failure, and remove one only when a stronger model makes it redundant.
You cannot download a good harness, because its shape is the history of your own failures.
Example: an agent kept adding `.retry(3)` to a test with a race condition.
One line ("never add retry decorators to a failing test, fix the cause"), a test-framework hook, and a reviewer agent made it structurally hard to repeat.

The Ralph loop (Geoffrey Huntley, Ryan Carson) is a bash loop: pick the next task from `prd.json`, build a prompt, append results to `progress.txt`, mark the task done or blocked, and repeat.
Each iteration starts fresh and reads state from disk.
The model in iteration 47 is the model from iteration 1, and the filesystem is what learned.
The loop primitives in Claude Code and Codex have since absorbed the pattern.

A plan you have read is not a plan you have verified (Horthy's revision of research-plan-implement).
Split planning into small verifiable phases.

The harness cannot fix one thing: training has no penalty for eroding maintainability.
Hooks can enforce that a test exists, but not that the code is worth keeping.
Stack diverse reviewers, and keep the final gate human.

Harness-as-a-Service: the Claude Agent SDK, Codex SDK, and OpenAI Agents SDK give you the loop, tools, context management, hooks, and sandbox.
The converging architecture splits the brain (the loop and model), the hands (sandboxes and tools), and the session (an append-only event log a crashed agent resumes from).

Harnesses do not shrink, they move.
A stronger model retired the author's context-monitoring scaffolding.
New work then needed new parts, such as a cost circuit breaker so a $4 evaluation cannot become $400.

The weekly habit: pick the slip that bugged you most, describe it in two or three sentences, find the missing component, build it, and push it.

### Loop engineering (the related article)

Loop engineering replaces you as the person who prompts the agent.
You design a system that finds work, hands it out, checks it, records what is done, and picks the next thing.
Steinberger and Cherny both say their job is now to write loops.
The pieces now ship inside Codex and Claude Code: automations, worktrees, skills, connectors (MCP), sub-agents, and state on disk.
Chapter 13 already maps all six onto this repo in `docs/loops.md`.

New points beyond chapter 13:

- An automation should call a skill instead of pasting a wall of instructions into a schedule nobody updates.
- `/goal` runs until a written condition holds, and a separate small model checks completion after every turn.
- Sub-agents burn tokens, so spend them where a second opinion is worth paying for.
- Token use varies widely between people who are token-rich and people who are token-poor, so a loop needs a cost budget.
- Two people can build the same loop with opposite results.
One moves faster on work they understand, and the other uses the loop to avoid understanding the work.
Build the loop like someone who intends to stay the engineer.

## Repo changes

- `scripts/guard-command.sh`: created.
It is a Claude Code `PreToolUse` hook on Bash.
It blocks `--no-verify` and `core.hooksPath` overrides, forced pushes (except `--force-with-lease` to a branch other than main or master), and recursive deletes of `/` or the home directory.
Each block prints what, why, and how to fix it.
- `scripts/test-guard-command.sh`: created, with 31 cases, run at verification level 2.
- `.claude/settings.json`: registers the hook.
- `docs/security.md`: an agent that reads untrusted text holds no publish, deploy, or merge credential, and every setup removes at least one leg of the lethal trifecta.
- `docs/tools.md`: tool descriptions are trusted text, so read, pin, and record each tool's version.
Pick the simplest carrier (hook, script, or tool), and make scripts silent on success and loud on failure.
- `docs/harness-audit.md`: the audit also deletes rules a newer model no longer needs.
- `docs/loops.md`: the loop budget can be a token budget.

## Design choices

Why a hook instead of another written rule:
hard constraint 3 already said "commit only through the pre-commit hook", and `--no-verify` still bypassed it.
The chapter's test is whether the system enforces the rule, and only a hook does.

Why the guard checks simple commands instead of parsing the shell:
the guard is a guardrail against mistakes, not a security boundary.
A full shell parser would be large and still incomplete.
The first version matched the whole command text, and it blocked its own author's heredoc that wrote these notes, because the text mentioned `--no-verify`.
The guard now splits the command on newlines, `;`, `&&`, `||`, and `|`, checks only segments that start with `git` or `rm`, and ignores quoted text in git commands.
Text that only mentions a command, such as `echo`, a heredoc, or a commit message, now passes.

Why `--force-with-lease` stays allowed on feature branches:
agents rebase their own branches, and the lease refuses to overwrite work they have not seen.
Main and master reach people only through a reviewed pull request, so a forced push there is always blocked.

Why the hook covers Claude Code only:
other agent tools have no shared hook format yet.
The pre-commit hook and CI still run `scripts/verify.sh` for every tool, so the guard adds a layer without being the only one.

Why the article gets no repo change of its own:
chapter 13 already built the six primitives into `docs/loops.md`.
Its new point, the token budget, is one phrase in the loop contract.
