---
title: "Claude Code Dynamic Workflows: Applicability to the CommandCenter Orchestrator"
slug: claude-code-dynamic-workflows-orchestrator-applicability
profile: deep
mode: architecture (comparison overlay)
status: ready
skills_used: researcher-core, research-architecture, research-comparison, scribe-core, scribe-research-briefing
created: 2026-07-26
updated: 2026-07-26
---

# Claude Code Dynamic Workflows: Applicability to the CommandCenter Orchestrator

## Purpose and scope

This report answers a go/no-go question for `H:\CommandCenter\orchestrator`: should this repository
adopt Claude Code's Dynamic Workflows feature, and if adoption is plausible, what would a migration
look like? It is based entirely on a `RESEARCH_EVIDENCE` packet delivered by Researcher (topic
`claude-code-dynamic-workflows-orchestrator-applicability`, profile `deep`, mode `architecture` with a
comparison overlay). No claim, source, or conclusion in this report goes beyond that packet. Every
claim below carries its original claim ID and citation markers so it can be traced back to source.

**Authority boundary.** This is a report and recommendation only. Researcher performed no write to any
repository artifact while gathering this evidence, and Scribe has made no change to any control-plane
file, code file, test, hook, skill, or setting while producing this report. No file in this repository
has been modified as part of producing this document, and none should be, until the user separately and
explicitly approves specific changes through the normal control-plane change process (see
"USER DECISION REQUIRED" call-outs throughout, and the closing section).

## Executive summary

Claude Code Dynamic Workflows reached General Availability on 2026-05-28 (claim A1). A dynamic workflow
is a JavaScript script, written by Claude from a natural-language description, that orchestrates
subagents at scale while the interactive session stays responsive (A2). This repository's `CLAUDE.md`
and several other control-plane and documentation artifacts currently instruct that a "project
JavaScript Dynamic Workflow runtime" must not be built and that its APIs (`.claude/workflows/*.js`,
`agent`, `pipeline`, `phase`, `log`) are "unsupported" (B1–B6). That premise was accurate when it was
written and is now **factually incorrect** as a general statement: those are the exact save path and
API names of a shipped, first-party GA feature (B4, B7). This is the headline finding of this report.

The prohibition nonetheless survives in a narrower, still-valid form: do not hand-author a bespoke
orchestration engine, and do not make any workflow the implementation of `/build` (B7, E1a). Separately,
and independent of any documentation wording, the runtime forbids mid-run human input (A6), which makes
a full migration of this orchestrator's defining human-gated spine (plan approval, design-direction
selection, judge authorization, driver install) structurally incompatible with a single workflow run
(D6). Three incidental mechanisms currently make workflows inert here regardless of intent: a
project-level background-task disable flag, an agent tool allowlist with no Workflow tool listed, and
the simple absence of a `.claude/workflows/` directory (B8). None of these is a deliberate policy
decision to block workflows.

A working local reference implementation exists at `H:\FABLE-HARNESS`, which already runs an
architecture structurally similar to this orchestrator's own lifecycle using Dynamic Workflows (C1–C4).
Its live-validation record supplies real cost data (roughly 950K tokens for one standard-scope run, 2.5M
across three runs) and real defect data (eight defects across three runs, including a false-completion
bug that is exactly the class of failure this orchestrator's Verifier gate exists to prevent) (C5–C8).

The recommendation (E1–E3) is **partial adoption in three separable decisions**: correct the stale
documentation premise, keep the human-gated Planner→approval→T1→Verifier spine untouched and off the
workflow runtime, and optionally pilot exactly one narrow, read-only, human-input-free workflow inside
an already-approved plan stage, paired with three new guards that do not exist today. Several material
questions about how this runtime interacts with this repository's own hooks and dispatch guards remain
genuinely unknown and are listed as a "before you decide" checklist near the end of this report.

---

## 1. Conceptual overview of Dynamic Workflows (per official documentation)

All claims in this section are GA-only; Researcher deliberately excluded preview, beta, and roadmap
material (see "Research limits" below), with one noted exception.

- **Availability (A1).** Dynamic workflows are Generally Available as of the 2026-05-28 announcement.
  The documentation states they "require Claude Code v2.1.154 or later and are available on all paid
  plans, with Anthropic API access, and on Amazon Bedrock, Google Cloud's Agent Platform, and Microsoft
  Foundry." Supported surfaces are the CLI, Desktop, VS Code extension, `claude -p` headless mode, and
  the Agent SDK. [S1][S2][S7]

- **Definition (A2).** Verbatim from the official documentation: "A dynamic workflow is a JavaScript
  script that orchestrates subagents at scale. Claude writes the script for the task you describe, and a
  runtime executes it in the background while your session stays responsive." [S2]

- **Script shape (A3).** A workflow file exports a `meta` block (`name`, `description`, optional
  `phases`) followed by plain JavaScript with top-level `await`. The observed runtime primitives are
  `agent(prompt, opts)` (spawns one subagent) and `pipeline(list, fn)` (runs one invocation per list
  item). Options seen in official examples and in the local FABLE-HARNESS example include `agentType`,
  `phase`, `label`, and `schema` (a JSON Schema constraining the agent's structured return value). [S2]

- **Save locations and invocation (A4, A5).** Workflows are saved to `.claude/workflows/` (project
  scope, shared through the repository) or `~/.claude/workflows/` (personal scope, honors
  `CLAUDE_CONFIG_DIR`). A saved workflow becomes a slash command, `/<name>`; a plugin-distributed
  workflow is namespaced `/<plugin>:<name>`. A project-scoped workflow wins over a personal one on a name
  collision. Four ways to invoke a workflow are documented: the single bundled workflow `/deep-research`
  (as of v2.1.218, runs only when explicitly invoked); typing the keyword `ultracode` or a natural
  request to "use a workflow"; `/effort ultracode` (v2.1.203+), which pairs maximum reasoning effort with
  automatic workflow planning for every substantive task in the session; and a saved `/<name>` command,
  optionally taking structured `args`. [S2]

- **Runtime constraints, verbatim (A6).** "No mid-run user input"; only agent permission prompts can
  pause a run, and the documented remedy for needing sign-off between stages is to "run each stage as
  its own workflow." "No direct filesystem or shell access from the workflow itself": the script
  coordinates, agents act. Concurrency is capped at "Up to 16 concurrent agents, fewer on machines with
  limited CPU cores," and at "1,000 agents total per run." [S2]

- **Permission model (A7).** The launch prompt follows the session's permission mode, but per the
  documentation, "The subagents the workflow spawns always run in `acceptEdits` mode and inherit your
  tool allowlist, regardless of your session's mode. File edits are auto-approved." A Bash, WebFetch, or
  MCP call not already on the allowlist can still prompt mid-run. [S2]

- **State and resumability (A8).** Intermediate results live in script variables, not in Claude's
  context window. Each run's generated script is written under `~/.claude/projects/<session>/`. A
  stopped run can resume within the same session, with already-completed agents returning cached
  results; exiting Claude Code loses that resumability, and the next session starts fresh. [S2]

- **Off switches (A9).** Workflows can be disabled via `"disableWorkflows": true` in settings (default
  `false`), the environment variable `CLAUDE_CODE_DISABLE_WORKFLOWS=1`, the `/config` Dynamic Workflows
  toggle, or an org-wide managed/admin setting. When disabled, bundled workflow commands disappear,
  `ultracode` stops triggering, and `ultracode` is removed from the `/effort` menu. [S2][S3]

- **Size control (A10, medium confidence).** `workflowSizeGuideline` accepts `unrestricted`, `small`
  (fewer than 5 agents), `medium` (fewer than 15), or `large` (fewer than 50); the documented default is
  `medium` as of v2.1.219, settable via `/config workflowSizeGuideline=small` or a settings key on
  v2.1.219+. This is advisory guidance to Claude, not an enforced runtime cap. A "Large workflow" warning
  fires above 25 scheduled agents or 1.5M projected tokens (v2.1.203+), and is suppressed when `ultracode`
  is active. Confidence on this claim is medium only, because the settings reference page Researcher
  fetched separately surfaced `disableWorkflows` but not `workflowSizeGuideline`, see the contradiction
  noted below. [S2][S3]

- **Anthropic's own stated rationale (A11).** Anthropic frames the feature as harness-shaped, aimed at
  countering "agentic laziness," "self-preferential bias," and "goal drift." The named composition
  patterns are classify-and-act, fan-out-and-synthesize, adversarial verification, generate-and-filter,
  tournament, and loop-until-done. [S6]

- **Official cost caution, verbatim (A12).** "workflows often use more tokens and are best suited for
  complex, high value tasks," with the recommendation to set "explicit token usage budgets," and the
  caveat that "most traditional coding tasks do not need a panel of 5 reviewers." [S6]

- **Positioning against alternatives (A13).** Anthropic's own comparison: a workflow is for when "A
  script holds the plan instead of Claude's turn-by-turn judgment," as opposed to subagents (Claude
  decides turn by turn), skills (instructions Claude follows), or agent teams (a lead supervising peer
  sessions). Workflows are described as scaling to "Dozens to hundreds of agents per run." [S4]

---

## 2. Disambiguation against this repository's existing prohibition (headline finding)

This is the most consequential finding in this report and is presented with full weight, per the
requested ordering.

**The exact wording of the existing prohibition.** `CLAUDE.md` line 47 states: "Use Skills and custom
agent definitions for reusable routing. Do not create a project JavaScript Dynamic Workflow runtime; it
is not the implementation of `/build`." (B1) `docs/CAPABILITY-MAP.md` phrases the same rule twice: line
26, "do not create a project JavaScript workflow runtime," and line 58, "The default build path does not
need the Agent SDK or a project-authored JavaScript workflow engine." (B2) `docs/ARCHITECTURE-ADAPTATION.md`
line 17 lists "project JavaScript workflow runtime" among prohibited structures. (B3)

**The decisive artifact.** `.claude/skills/workflow-author/SKILL.md` line 12 instructs: "Do not create
`.claude/workflows/*.js` or invent unsupported `phase`, `log`, `agent`, or `pipeline` APIs." (B4) Those
are precisely the official save path (A4) and the official runtime API names (A3) of the now-GA feature.
The premise that they are "unsupported" or invented is falsified by the official documentation [S2].

**A stale-premise test, not a failing test.** `tests/validate.ps1` line 642 asserts:
`if ($operations -match 'Dynamic Workflow') { throw 'Operations guidance must not require an unsupported
Dynamic Workflow runtime.' }`. This assertion still passes today, trivially, because the string "Dynamic
Workflow" is simply absent from `.claude/skills/claude-operations/SKILL.md`. The test does not fail, but
its stated justification ("unsupported") is no longer true. (B5)

**Three further artifacts carrying the same premise.** `docs/CUSTOM-WORKFLOWS.md` line 3 ("`build` is an
interactive skill, not a JavaScript workflow runtime"); `.claude/skills/claude-operations/SKILL.md` line
18 ("Do not create a project JavaScript workflow runtime"); and `docs/COMPLETION-AUDIT.md` line 24
("Project JavaScript workflow runtimes are deliberately unsupported"). A fourth, lower-priority artifact,
`docs/research/t1-engineer-enhancement.md` line 37, also lists "Dynamic Workflows" among prohibited
capabilities for T1; this one is a prior research report rather than a control-plane file, so it carries
less operational weight but the same stale premise. (B6, and see "Research limits")

**Two readings, now diverging.** The prohibition has always had two possible readings, and the evidence
now separates them cleanly:

- The **narrow reading**, do not hand-author a bespoke, project-owned JavaScript orchestration engine,
  and do not make it the implementation of `/build`, survives intact, and arguably becomes *more*
  clearly correct, because a first-party runtime removes any remaining reason to hand-roll a substitute.
- The **broad reading**, that `.claude/workflows/*.js` and the `agent`/`pipeline`/`phase`/`log` APIs are
  hallucinated, non-existent features, is factually wrong as of Claude Code v2.1.154. (B7)

This report does not characterize the repository's prior stance as having been mistaken; it was accurate
when written. It is now partially stale, and that staleness is a correctness issue worth fixing
regardless of whether any workflow is ever actually run, because a harness whose stated purpose includes
not fabricating certainty should not itself assert something false about the platform it runs on.

**Why workflows do not run here today anyway, and why that is not the same as a deliberate block.**
Three independent, currently-existing mechanisms make Dynamic Workflows effectively inert in this
repository right now, regardless of the documentation wording: `.claude/settings.json` sets
`CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`; the `orchestrator` agent's `tools:` frontmatter grants only
`Agent(...)`, `SendMessage`, `Skill`, `Read`, `WebFetch`, and `WebSearch`, with no Workflow tool listed;
and no `.claude/workflows/` directory currently exists in this repository. None of this is a deliberate
`disableWorkflows` or `CLAUDE_CODE_DISABLE_WORKFLOWS` setting; the block is incidental to other design
choices, not an intentional decision to exclude the feature. (B8)

---

## 3. Capability-by-capability mapping onto existing roles and gates

**How this repository currently enforces routing and completion discipline.** Routing authority is
enforced at two points: the `orchestrator` agent's `tools:` `Agent(...)` allowlist of 18 named agent
types, and a `PreToolUse` hook on the `Agent` matcher (`validate-agent-dispatch.ps1 -Parent session`)
that denies any non-allowlisted `subagent_type`, any `run_in_background` value other than `false`, any
non-empty `name`, and any `team_name`/`teammate_name`/`isolation` field. (D1) Terminal-packet discipline
is enforced by per-agent frontmatter `Stop` hooks (`validate-terminal-packet.ps1 -Role <role>`) on
`planner` and all eight design roles, each requiring a delimited header/footer packet with named
required fields, with a `stop_hook_active` escape after one correction attempt. (D2)

**The structural blocker.** The runtime forbids mid-run user input (A6). This orchestrator's defining
behavior is human gating at several specific points: `CLAUDE.md` requires explicit user approval of a
plan before T1 may start; the orchestrator is required to ask the user one concise question before
dispatch when a material unknown exists; Studio-tier design work requires the user to select among three
directions mid-flight; Browser Validator's driver-install authorization and the Codex judge's usage
approval are each one-off user prompts. None of these gates can live inside a single workflow run. The
documentation's own remedy, "run each stage as its own workflow" for sign-off between stages, is
exactly the shape of a partial-adoption design, not a way to run the whole spine as one workflow. (D6)

**Capability-by-capability fit.**

Good fit, fan-out work that needs no mid-run human answer and produces independently verifiable output:

- Researcher's multi-source fan-out and cross-checking (the bundled `/deep-research` workflow is
  literally this pattern).
- Planner's repository analysis across many files.
- Adversarial verification of a large diff, file by file.
- Browser Validator's journey-by-viewport matrix.
- A T1 mechanical migration applied consistently across many files.

Poor fit:

- The Planner → user approval → T1 spine (see D6).
- Codex judge routing, which is already capped at two/four calls and where `codex exec` itself is a
  shell call that would trigger a mid-run permission prompt under A7.
- The design fleet's Studio direction-selection step.
- Anything whose entire value is a terminal packet returned to a human for a decision. (D7)

**What adoption would duplicate rather than replace.** Anthropic's own cited motivations for the
feature (adversarial verification, fan-out-and-synthesize, loop-until-done, tournament; A11) are
already implemented in this repository as prose contracts enforced by dedicated agents: an independent
Verifier, an independent Design Reviewer, the Codex Judge Runner, the two-failure T1→T2 escalation
ladder, and Browser Validator. Adopting workflows for these purposes would not add a capability this
repository lacks; it would move an existing capability from prompt-enforced to script-enforced. The
potential gain is determinism and parallelism. The cost is that governance logic would move out of
reviewed, hook-guarded control-plane files into a Claude-generated script that is not itself reviewed
before it runs. (D8)

---

## 4. What adoption would replace, duplicate, or break, including hooks, tests, and settings.json

**A working local precedent already exists.** `H:\FABLE-HARNESS\AGENTS.md` names `.claude/workflows/*.js`
"the REAL reusable-orchestration primitive," explicitly contrasting it with an earlier, fictional
`.claude/teams/*.yaml` idea, and states its subagent fan-out is "used via `.claude/workflows/*.js`
pipeline/parallel calls" with always-typed producer agents. (C1) Its `run.js` (340 lines) implements a
lifecycle structurally close to this orchestrator's own: phases Setup → Generate → Judge → Verify →
Missability → Finalize; a `triage` agent classifying scope as trivial/standard/major against a JSON
schema; typed producer agents per stage; a `judge-router` choosing same-tier versus cross-vendor Codex
judgment; a single Reflexion retry on rejection; an explicitly read-only `verifier`; a separate
write-capable record-only step (kept separate because the verifier must not mutate what it inspects); and
a `run-finalizer` whose returned boolean is trusted over mere dispatch success. (C2) Its `review.js` (91
lines) implements a lighter pattern mapping almost exactly onto this repository's design-review and
verification gates: a forum-to-reviewer-agent map, a `pipeline()` call over reviewers, an independent
verifier pass per reviewer returning a `{verdict: pass|pass-with-notes|reject, notes}` schema, and an
`exitCriteriaMet` flag derived from whether any reviewer rejected. (C3) Both scripts confirm the
branching primitive in practice: because the script itself has no filesystem access, all control flow is
driven by JSON-Schema-validated agent return values, and both carry an identical header comment stating
this constraint explicitly. (C4)

**Cost evidence.** Three live end-to-end FABLE-HARNESS runs consumed roughly 2.5M subagent tokens total.
The first successful standard-scope run took 24 dispatches at roughly 950K tokens; after wiring in the
Reflexion retry loop, the same scope took 45 dispatches, on the order of 40,000 tokens per dispatch on a
standard-scope run. (C5)

**An environment-specific defect worth carrying forward.** On this same Windows host, the Workflow
tool's `args` parameter arrived inside the generated script as a JSON-encoded string rather than a plain
object, even when the tool call itself passed a real object, silently producing `undefined` and leaking
the literal string "undefined" into every downstream prompt and file path. Both FABLE scripts now
normalize defensively and throw loudly on this condition. Any workflow authored in this orchestrator on
the same host should assume the same hazard until it is confirmed fixed in a newer Claude Code version.
(C6)

**Real defects found during live validation.** Live validation of the FABLE-HARNESS workflows found
eight real defects across three runs. At least three are directly instructive here: the script dispatched
a read-only verifier but never dispatched the write-capable retry coach, so the retry loop silently never
fired; a gate agent wrote its evidence file only on the failing path, which meant the finalizer correctly
refused to trust it when it was missing; and the script unconditionally returned `status: 'finalized'`
regardless of what the finalizer had actually decided. The last defect is exactly the class of
false-completion failure that this orchestrator's Verifier gate exists to prevent, and it appeared
*because* the plan moved from prose into executable code. (C7)

**A favorable counterpoint.** Under the malformed-`args` adverse condition described above, every
downstream typed agent independently detected the bad state and failed closed rather than fabricating
success. The governance discipline encoded in the agent definitions themselves survived being driven by
a script rather than by an interactive session. (C8)

**Hooks coexist with workflows in the reference project, but the interaction is not confirmed.**
FABLE-HARNESS runs a `Stop` hook (`stop-verify-gate.ps1`) whose header states a run-state convention that
"must be honored by `.claude/workflows/run.js`." This shows hooks and workflows coexisting in a live
project, but it does not establish that hooks fire *inside* workflow-spawned agents; FABLE's gate reads
state from disk rather than depending on that guarantee. (C9)

**What adoption would replace vs. duplicate vs. break, specifically for this repository:**

- **Would not replace** the human-gated Planner → approval → T1 → Verifier spine, the runtime cannot
  support it (D6), and this report recommends explicitly against attempting that migration.
- **Would duplicate**, not add, capabilities already present in prose-contract form: independent
  verification, adversarial review, escalation ladders, and cross-vendor judgment (D8).
- **Would risk breaking, if adopted carelessly:** `agent()` dispatch calls inside a workflow are made by
  the runtime itself, not by the orchestrator session's `Agent` tool, so `validate-agent-dispatch.ps1`
  almost certainly does not gate them, meaning the 18-agent allowlist and the anti-background,
  anti-named-dispatch guarantees would not apply to workflow-internal dispatch. This is an architectural
  inference at medium confidence, not a documented fact, and is the single most important thing to test
  before any adoption. (D4)
- **Might preserve, unconfirmed:** per-agent frontmatter `Stop` hooks plausibly still fire for a
  workflow-spawned agent of a given `agentType`, since that `agentType` loads the same agent definition
  file that carries the `hooks:` block, and `Stop` is documented to auto-convert to `SubagentStop` for
  subagents generally. This is inference, not confirmation; the official hooks reference never mentions
  workflows at all. (D5)
- **Would need a new guard, today absent:** a project-level `PreToolUse` hook on
  `Write|Edit|NotebookEdit|Bash` (`validate-control-plane-write.ps1`) currently denies writes to 19
  control-plane paths, including `.claude/settings*.json`, `.claude/agents/**`, `.claude/hooks/**`,
  `.claude/skills/**`, `CLAUDE.md`, and every `docs/*CONTRACT*.md`, but `.claude/workflows/**` is **not**
  on that list. A saved workflow would currently be freely writable by any agent with write access. (D3)
- **Would make repository-equivalent state agent-mediated.** Because the runtime has no filesystem
  access of its own (A6), every piece of durable run state that this repository currently treats as a
  control-plane- or Scribe-guarded write (approval records, `docs/plans/<slug>.md`, scope fingerprints,
  judge call counters, T1/T2 failure counters) would, inside a workflow, have to become an agent-mediated
  write performed under instruction, which is precisely the mechanism that produced the three real
  defects cited above (C7, D9).

---

## 5. Phased adoption path, risks, and rollback

This report separates the decision into three independently approvable pieces (E1):

**(a) Correct the stale documentation premise.** Update the six control-plane and documentation
artifacts (B1–B6, plus the lower-priority research report noted in B6) so they no longer assert that a
now-GA feature is "unsupported" or "invented," while preserving the narrow prohibition that remains
correct: no bespoke project-authored orchestration engine, and no workflow implementing `/build`. This
correction is recommended independently of whether any workflow is ever run, purely on truthfulness
grounds. **USER DECISION REQUIRED**: every one of these files is a control-plane path guarded by
`validate-control-plane-write.ps1`, and most are additionally listed in `.claude/settings.json`'s
`permissions.deny`. Scribe and Researcher have made no edit to any of them in producing this report, and
none should be edited without the user's explicit, separate approval through the normal control-plane
change process.

**(b) Keep the serial spine exactly as-is.** Do not attempt to migrate Planner → approval → T1 →
Verifier into a workflow. The mid-run human-input prohibition (D6) makes this structurally, not just
practically, incompatible with the runtime, and FABLE-HARNESS's own defect record (D9) shows what happens
when governed state has to become agent-mediated instead of directly written.

**(c) Optionally pilot exactly one narrow workflow.** If pursued, the strongest first candidate is a
read-only research or audit fan-out: either the bundled `/deep-research` workflow used as-is, or a saved
workflow that fans reviewers across files and returns a schema-validated finding list. It writes nothing,
requires no human answer mid-run, has an existing GA reference implementation, and its worst failure mode
is a wasted run rather than a corrupted artifact. The second-best candidate is Browser Validator's
journey-by-viewport matrix. The worst possible first candidate is any workflow that writes plan state or
records approval. (E2)

**New guards required before any pilot, not after (E3):**

1. Add `.claude/workflows/**` to the control-plane path list in `validate-control-plane-write.ps1` so a
   Claude-generated script cannot silently become policy.
2. Set an explicit `workflowSizeGuideline` (recommended: `small`, fewer than 5 agents) rather than
   relying on the documented default.
3. Deliberately decide whether `disableWorkflows` should be set to `true` as the documented, intentional
   default for this repository, rather than continuing to rely on the incidental block described in B8.

**Rollback.** Because a pilot workflow would be a single new file under `.claude/workflows/`, rollback is
mechanically simple: delete the file, and its slash command disappears. The higher-risk rollback concern
is not the workflow file itself but any control-plane guard added around it (item 1 above); if that guard
is added, it should be reviewed as carefully as any other control-plane change and is subject to the same
approval process as removing it.

**A sequencing conflict to flag explicitly.** `docs/plans/orchestrator-control-plane-immutability-and-maintenance-mode.md`
is in-flight work establishing that this harness must not mutate itself during operation, with no
propose-and-apply cycle inside a single workflow. Dynamic Workflows adoption introduces a new
agent-writable script surface (`.claude/workflows/**`) that is not currently part of that immutability
inventory. These two efforts should be sequenced deliberately rather than run concurrently; whichever is
decided first should account for the other.

---

## 6. Recommendation

**Go/no-go: partial adoption, in the three separable decisions above.**

- For the documentation correction (a): recommended, independent of workflow adoption, as a truthfulness
  fix. Requires explicit user approval to touch control-plane files.
- For the human-gated spine (b): **no**, do not migrate it. The runtime's mid-run input prohibition
  makes this structurally impossible without deleting the gates that define this orchestrator.
- For a bounded pilot (c): **yes-with-conditions**, a single, read-only, human-input-free workflow
  inside an already-approved plan stage, only after the three new guards in E3 are in place and only
  after the "before you decide" validation checklist below has been run.

This is not "gain a capability this repository lacks." Every motivating pattern Anthropic cites for
Dynamic Workflows (adversarial verification, fan-out-and-synthesize, loop-until-done, tournament) is
already implemented here as an enforced prose contract with its own dedicated agent. Adoption is a
determinism-and-parallelism trade against a documented cost (roughly 40,000 tokens per dispatch on a
standard-scope reference run) and a documented defect surface (eight real defects across three reference
runs, several structurally similar to failures this orchestrator's Verifier gate already exists to catch).

---

## Before you decide: unresolved unknowns, one contradiction, and a validation checklist

The following are explicitly preserved as open items, not resolved by this report.

**High-impact unknowns.**

- Whether `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` (set at project scope in `.claude/settings.json`)
  prevents Dynamic Workflows from running at all. Workflows run in the background by design; neither the
  workflows documentation page nor the settings reference states this interaction. This determines
  whether any adoption at all requires touching a setting that currently underpins this orchestrator's
  serial-execution guarantee.
- Whether per-agent frontmatter `Stop` hooks and the `PreToolUse` `Agent` dispatch hook actually fire for
  workflow-spawned subagents. The official hooks reference never mentions workflows. If `Stop` hooks do
  not fire inside a workflow, terminal-packet enforcement silently evaporates there.

**Medium-impact unknowns.**

- The locally installed Claude Code version was not confirmed. Adoption requires at least v2.1.154, and
  several cited behaviors require v2.1.202, v2.1.203, v2.1.208, v2.1.216, v2.1.218, or v2.1.219
  specifically. Researcher could not run `claude --version` due to Bash allowlist restrictions.
- Whether a workflow can be launched at all from the `orchestrator` main agent, whose `tools:`
  frontmatter lists six tools with no Workflow tool. Unclear whether that enumeration gates the workflow
  runtime, or whether `ultracode` / `/deep-research` bypass it.
- Whether the FABLE-HARNESS `args`-as-JSON-string defect is still live on the current Claude Code
  version, or was fixed since it was recorded (dated 2026-07-10, ten days before the researched version
  gate and sixteen days before this evidence was gathered).
- Whether the FABLE-HARNESS example itself was validated against the current Claude Code version or an
  earlier one; its decision record does not state a version.

**One contradiction, low-to-medium impact.** The workflows documentation states `workflowSizeGuideline`
is settable "in any settings file" on v2.1.219+ and takes precedence over `/config`; the settings
reference page, fetched separately, surfaced only `disableWorkflows` and no `workflowSizeGuideline`
entry. This is most likely a documentation lag or an extraction gap rather than a genuine platform
conflict, but it should be resolved by reading the full settings reference directly before any settings
change is proposed.

**A second, low-impact contradiction.** `docs/COMPLETION-AUDIT.md` line 24 records the unsupported-runtime
stance as "Implemented and statically checked," which is true of the check itself and false of the
premise behind it. The distinction between "the test passes" and "the test's justification is still
valid" should be kept explicit in any future correction.

**Validation checklist, before any adoption decision is finalized:**

1. Run `claude --version` in the interactive session and confirm it is at least v2.1.154, noting which of
   v2.1.202/203/208/216/218/219 apply. (User-run; Researcher is Bash-restricted.)
2. Run `/config` and check whether a "Dynamic workflows" row and a "Dynamic workflow size" row are
   present.
3. Run the single highest-value, cheap, read-only test: `/deep-research <a small question>` in a scratch
   session, then `/workflows` to inspect the run. This empirically answers whether
   `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` blocks workflows, whether the orchestrator agent's `tools:`
   list gates workflow launch, and the actual token cost on a narrow question. Do this before writing any
   project workflow.
4. Hook-interaction test: have Claude write a throwaway workflow that dispatches a single
   `agentType: 'design-reviewer'` agent with a deliberately malformed return, and observe whether
   `validate-terminal-packet.ps1 -Role design-reviewer` blocks it. A block confirms Stop hooks fire
   inside workflows; no block means terminal-packet enforcement does not survive inside workflows, and the
   go/no-go should harden toward no.
5. Dispatch-guard test: have a throwaway workflow attempt `agentType: 'general-purpose'`. If it succeeds,
   `validate-agent-dispatch.ps1` does not gate workflow-internal dispatch, confirming the architectural
   inference above, and the new guard work in section 5 becomes mandatory rather than advisory.
6. Confirm `workflowSizeGuideline` as an actual settings key by reading the full settings reference
   directly, resolving the documentation contradiction noted above before any settings recommendation is
   finalized.
7. Before finalizing any adoption decision, re-read the FABLE-HARNESS `run.js` header constraints against
   a fresh reading of the workflows documentation's "Behavior and limits" table, to confirm the
   no-filesystem-access constraint still holds; the entire risk argument in section 4 about agent-mediated
   state depends on it.
8. If a pilot proceeds, set `workflowSizeGuideline=small` (fewer than 5 agents) and compare measured
   token cost against the roughly 40,000-tokens-per-dispatch figure from the FABLE-HARNESS reference data
   before scaling to a larger workflow.

## USER DECISION REQUIRED, consolidated list

- Amending any of: `CLAUDE.md`, `docs/CAPABILITY-MAP.md`, `docs/ARCHITECTURE-ADAPTATION.md`,
  `docs/CUSTOM-WORKFLOWS.md`, `docs/COMPLETION-AUDIT.md`, `docs/BUILD-CONTRACT.md`,
  `.claude/skills/workflow-author/SKILL.md`, `.claude/skills/claude-operations/SKILL.md`, or
  `tests/validate.ps1`. All are control-plane paths guarded by `validate-control-plane-write.ps1`, and
  most are additionally denied by `.claude/settings.json`'s `permissions.deny`.
- Any change to `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`, or the introduction of `disableWorkflows` or
  `workflowSizeGuideline` settings. These would alter the serial-execution guarantee the entire operating
  contract currently rests on.
- Sequencing this work against `docs/plans/orchestrator-control-plane-immutability-and-maintenance-mode.md`,
  since Dynamic Workflows adoption introduces a new agent-writable script surface not currently accounted
  for in that plan's immutability inventory.

No scope has been added, no dependency chosen, and no architecture changed by this report. No repository
file has been modified in producing it, and none should be modified without the user's separate, explicit
approval through the normal control-plane process described above.

## Source ledger

- [S1] "Introducing dynamic workflows in Claude Code", https://claude.com/blog/introducing-dynamic-workflows-in-claude-code, official Anthropic product blog (vendor primary). Authority: highest for GA status and availability. Announced GA 2026-05-28. Accessed 2026-07-26. Supports A1, and provides context for A12. Limitation: marketing framing; defers mechanics to the documentation.
- [S2] "Orchestrate subagents at scale with dynamic workflows", https://code.claude.com/docs/en/workflows, official Claude Code reference documentation. Authority: highest, primary and normative. Accessed 2026-07-26. Supports A1–A10, A13, D6, D7, E3. Limitation: silent on hook interaction with workflow-spawned agents and on `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`.
- [S3] Claude Code settings reference, https://code.claude.com/docs/en/settings, official reference. Accessed 2026-07-26. Supports A9 (`disableWorkflows` default `false`, environment equivalent `CLAUDE_CODE_DISABLE_WORKFLOWS=1`) and settings precedence (managed > CLI args > local > project > user). Limitation: did not surface `workflowSizeGuideline`, contradicting S2; see the contradiction noted above.
- [S4] "Run agents in parallel", https://code.claude.com/docs/en/agents, official reference. Accessed 2026-07-26. Supports A13, D7. Limitation: comparative overview only.
- [S5] Claude Code hooks reference, https://code.claude.com/docs/en/hooks, official reference. Accessed 2026-07-26. Supports D5 (`Stop` auto-converts to `SubagentStop` for subagents) and the negative finding that the hooks reference never mentions workflows. Limitation: this is an argument from absence.
- [S6] "A harness for every task: dynamic workflows in Claude Code", https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code, official Anthropic engineering blog. Accessed 2026-07-26. Supports A11, A12. Limitation: rationale and pattern language, not a normative API reference.
- [S7] anthropics/claude-code release v2.1.154, https://github.com/anthropics/claude-code/releases/tag/v2.1.154, official release notes, independent corroboration of the version gate. Accessed 2026-07-26 via search result summary. Supports A1, D7. Limitation: retrieved via a search summary rather than a direct page read.
- [S8] `H:\FABLE-HARNESS\.claude\workflows\run.js`, local working first-party-runtime workflow, 340 lines. Authority: high as an observed working implementation, none as policy. Read 2026-07-26. Supports C2, C4, D9.
- [S9] `H:\FABLE-HARNESS\.claude\workflows\review.js`, local working workflow, 91 lines. Read 2026-07-26. Supports C3, C4.
- [S10] `H:\FABLE-HARNESS\memory\decisions\2026-07-10-live-validation-findings.md`, local empirical validation record of three live runs. Authority: high for observed runtime behavior on this same Windows host. Dated 2026-07-10, read 2026-07-26. Supports C5, C6, C7, C8, D9. Limitation: single project, single machine, n=3 runs; token figures are self-reported.
- [S11] `H:\FABLE-HARNESS\AGENTS.md`, local cross-tool contract. Read 2026-07-26. Supports C1.
- [S12] `H:\CommandCenter\orchestrator\CLAUDE.md` (line 47 for the prohibition; classification and approval rules throughout), controlling project instruction. Read 2026-07-26. Supports B1, B8, D6, D8.
- [S13] `H:\CommandCenter\orchestrator\.claude\skills\workflow-author\SKILL.md` (line 12), project skill. Read 2026-07-26. Supports B4, the decisive disambiguation evidence.
- [S14] `H:\CommandCenter\orchestrator\docs\CUSTOM-WORKFLOWS.md`, read 2026-07-26. Supports B6.
- [S15] `H:\CommandCenter\orchestrator\docs\CAPABILITY-MAP.md` (lines 26, 58), read 2026-07-26. Supports B2.
- [S16] `H:\CommandCenter\orchestrator\docs\ARCHITECTURE-ADAPTATION.md` (line 17), read 2026-07-26. Supports B3.
- [S17] `H:\CommandCenter\orchestrator\.claude\skills\claude-operations\SKILL.md` (line 18), read 2026-07-26. Supports B6, and is the `$operations` variable asserted against in S18 line 642.
- [S18] `H:\CommandCenter\orchestrator\tests\validate.ps1` (lines 60–160, 625–664), project static validation suite. Read 2026-07-26. Supports B5, B8, and the required-artifact inventory that surfaced S13 and S14.
- [S19] `H:\CommandCenter\orchestrator\.claude\settings.json`, read 2026-07-26. Supports B8, D3.
- [S20] `H:\CommandCenter\orchestrator\.claude\agents\orchestrator.md` (frontmatter lines 1–12), read 2026-07-26. Supports B8, D1.
- [S21] `H:\CommandCenter\orchestrator\.claude\hooks\validate-agent-dispatch.ps1`, read 2026-07-26. Supports D1, D4.
- [S22] `H:\CommandCenter\orchestrator\.claude\hooks\validate-terminal-packet.ps1`, read 2026-07-26. Supports D2, D5.
- [S23] `H:\CommandCenter\orchestrator\.claude\hooks\validate-control-plane-write.ps1`, read 2026-07-26. Supports D3, E3.
- [S24] `H:\CommandCenter\orchestrator\docs\BUILD-CONTRACT.md` (line 193), read 2026-07-26. Supports B6 ("not an undocumented project JavaScript workflow runtime").
- [S25] `H:\CommandCenter\orchestrator\docs\COMPLETION-AUDIT.md` (line 24), read 2026-07-26. Supports B6.
- [S26] `H:\FABLE-HARNESS\.claude\settings.json` and `H:\FABLE-HARNESS\.claude\hooks\stop-verify-gate.ps1` (header comment), read 2026-07-26. Supports C9.

## Research limits

- **Freshness.** All external sources were accessed 2026-07-26. Researcher's knowledge cutoff predates
  the GA date of 2026-05-28, so every claim about this feature in this report is sourced from live
  retrieval rather than model recall.
- **Inaccessible verification.** Researcher could not execute `claude --version`, `/doctor`, `/config`,
  or any workflow, because the Bash allowlist blocks these commands and Researcher does not run
  interactive commands. Every runtime-behavior question listed in "before you decide" is unresolved by
  design, not by omission.
- **Argument from absence.** The claim that hooks and workflows have no documented interaction rests on
  the hooks reference simply never mentioning workflows.
- **Single-example limitation.** FABLE-HARNESS is one project, on one machine, with three validated runs.
  Its cost figures and its `args` defect should be read as indicative of this platform on this host, not
  as general, universally applicable platform characteristics.
- **Prior research.** `docs/research/` contained no prior report on Dynamic Workflows before this one.
- **Not covered.** This report does not cover the Agent SDK's Workflow tool options reference, the
  `/batch` skill, plugin-based workflow distribution mechanics beyond namespacing, or
  Bedrock/Vertex/Foundry-specific behavior.
- **Excluded preview material.** "Agent view," referenced in S4, is labeled "Research preview" in the
  source documentation and was deliberately excluded from every recommendation in this report, consistent
  with the GA-only scope of this research.
