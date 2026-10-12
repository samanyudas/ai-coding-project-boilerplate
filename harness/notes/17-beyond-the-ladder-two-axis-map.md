# 17 - Beyond the ladder: a two-axis map

Source: chapter 2 of the same O'Reilly Early Release book on agentic engineering.

## Notes

A ladder tells you to climb.
A map tells you where you stand and which direction is safe.

Steve Yegge's eight levels and Dan Shapiro's five levels (L0 autocomplete to L5 dark factory) stack two different things on one line, so moving up always looks like improvement.
Five of Yegge's eight rungs describe one agent.
Shapiro estimates that about 90% of self-described AI-native developers are stuck near Level 2.

The two hidden variables are independent:

- Autonomy per agent: how far one agent gets before it needs you (Karpathy's autonomy slider: build the Iron Man suit, not the robot).
- Orchestration: how many agents run at once, and who coordinates them.

Skill at one does not transfer to the other.

Five stages sit along the diagonal, each a role you pick per task:

| Stage | You | Agents | Role |
| --- | --- | --- | --- |
| S1 Assist | Drive every step | One agent under permission prompts | Author |
| S2 Pilot | Hand off a scoped task and watch | One agent runs a multi-step task | Co-pilot and reviewer |
| S3 Delegate | Brief, walk away, review the result | One headless agent returns a PR | Spec-writer and reviewer |
| S4 Conduct a few | Coordinate three to five agents by hand | Parallel slices in worktrees | Tech lead |
| S5 Conduct the fleet | Define outcomes, manage by exception | Many agents, coordination partly automated | Factory operator |

Chapter 1's zones measure discipline, and these stages measure organization.
You can run a zone 4 process at S2, or a zone 1 process at S4.

Autonomy primitives: a goal drives one bounded task to a measurable finish line with an independent evaluator, and a loop reruns on an interval.
Each step up the trust gradient costs a stopping condition you can state and a check that does not belong to the maker.

The orchestration axis works when coordination is automated and judgment stays human.
The author's triage loop sorts and closes pull requests that break the guidelines, and it merges nothing.

Verification is not a third axis.
It rides alongside both axes as the constant, and it matters more as you climb, because at S5 a missed bug multiplies across the fleet.
Yegge's level 4 treats "stop reading diffs" as progress, and the map leaves it off on purpose.
Anthropic's data on about 400,000 Claude Code sessions: humans make about 70% of planning decisions while Claude does about 80% of execution.

The factory corner is reached by removing verification, and that failure is quiet and late.
Agent-built codebases calcify into brownfield within three to six months.
Build the verification budget before you spend autonomy.

The stage is a choice per task, set by stakes and verifiability:

- A payments ledger belongs at S1 or S2, even when the ticket says simple.
- Low-stakes chores run at S4, even when the ticket says complex, because failure surfaces fast and rolls back cheap.
- Parking at the highest autonomy you have ever seen is a failure to pick.
- Off-diagonal work is healthy: high autonomy with one agent suits a gnarly bug, and low autonomy with many agents suits sliceable work that matters.

Tooling per stage in Claude Code: S1 and S2 are interactive sessions with permission schemes.
S3 adds headless mode with worktree isolation.
S4 is parallel sessions in separate worktrees.
S5 adds primitives that pass work between agents.
Do not over-invest in scaffolding that the platform will soon ship as a button.

The pillars on the map: plan and direct move together, because the further you walk away, the more the spec must carry.
Test is the constant.
Own does not move: an agent cannot take the page at 3am.
The danger as you climb is accountability thinning ("the orchestrator handles that").

The frontier comes with a caveat.
Boris Cherny manages hundreds of agents and still runs heavy verification on newer, lower-stakes codebases.
Peter Steinberger "ships code he doesn't read" as a solo founder on his own codebase.
Copy those postures onto a revenue-bearing team system and you get disaster at speed.
Developers use AI across about 60% of their work but fully delegate at most about 20% of tasks.

The binding constraint is the number of threads you can hold while still standing behind each merge, about five for the author.
You raise it by building verification you trust, not by adding agents.

To locate yourself, ask how far your agent gets before it needs you, and how many agents run, coordinated by whom.
Then gate the first: how fast will you know you are wrong, how cleanly can you undo it, and what would prove you are right?
"Not fast", "not cleanly", and "by trusting the agent's summary" mean you run unverified, which looks identical to high autonomy until something breaks.

Front-load alignment in small verifiable phases.
Horthy names three failures of research-plan-implement at scale:

- The plan-reading illusion: plans that read well do not always build well.
- Instruction decay: models lose consistency at around 150 to 200 instructions in one prompt.
- Context bloat: keep context utilization under about 40%, and reset near 60%.

Common misreadings of the map:

- Reading stages as status: the right stage is the praiseworthy move.
- Importing the frontier's coordinates: Cherny's position is data, not an instruction.
- Mistaking agent count for stage: ten hand-sequenced agents is still S4.
- Verification theater: the agent's summary becomes the review.
Demand the evidence packet (diff, test output, logs, screenshots, known gaps), then read the code.
- Permission laundering: approval fatigue grants broader access than the task needs.
Use sandbox profiles, scoped writable roots, allowlisted commands, and hooks.
Turning off prompts lowers friction without raising autonomy.

In one line: autonomy and orchestration are separate dials picked per task by stakes, verification rides alongside both and is never skipped, and you earn autonomy by making verification cheaper.

## Repo changes

- `docs/loops.md`: the single maturity ladder is replaced by two dials, autonomy and orchestration, each raised one step at a time after its verification runs without surprises.
The token blowout guard starts a fresh session before the context window is about 60% full.
The checklist asks whether the loop's autonomy matches the stakes.
The "Generator and evaluator" section is removed, because the hard constraints and the silent-costs table already say the same thing.
- `docs/observability.md`, `.claude/agents/evaluator.md`: the verification report lists known gaps, and the agent's summary never replaces the evidence.
- `docs/security.md`: a hard constraint to scope an agent's permissions instead of disabling permission prompts.

## Design choices

Why the map is not added as a doc:
the stage is a per-task choice the human makes, and the repo already enforces what the stages depend on: verification in `scripts/verify.sh`, an independent evaluator, worktrees for parallel agents, and a pull request before merge.
A stage table in `docs/` would be read every session and change no agent's behavior.
The two parts that do change behavior went into existing files: separate dials in `docs/loops.md`, and stakes as paths (chapter 16).

Why known gaps are part of the report:
verification theater happens when the agent's account becomes the review.
A report that must state what it did not test makes the missing evidence visible, instead of letting a confident summary hide it.

Why no permission allowlist in `.claude/settings.json`:
the right allowlist depends on the project's stack, and a boilerplate list would be either too broad or wrong.
`docs/security.md` states the rule, and each project writes its own list.
