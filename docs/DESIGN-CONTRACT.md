# Design contract

The design fleet is a planning-stage creative system. It runs after local/product research is grounded, before Scribe finalizes an implementation plan, and always before engineering. Design agents do not approve scope or production work. Compact and Standard work is specification-only; Studio may create one disposable selected-direction prototype.

Nesting is intentionally bounded to main Orchestrator → Planner → Design Director → specialist. Only Planner and Design Director receive design-stage delegation authority; specialists and reviewer cannot create deeper descendants. The default design route is synchronous nested subagents with agent teams and background tasks disabled. Safe custom-subagent names are allowed as native continuation handles and do not create a team.

## Runtime registration and failure semantics

All named design roles are project subagents under `.claude/agents/` and must appear in the main Orchestrator's transitive `Agent(...)` runtime allowlist. Git tracked or untracked status has no effect on Claude Code discovery. Runtime visibility is not routing authority: Orchestrator invokes Planner, Planner invokes Generalist or Director plus Reviewer and optional Prototyper, and Director invokes UX, visual, motion, and asset specialists.

Planner and Design Director keep bare `Agent` capability because typed child restrictions apply to a main-thread custom agent, not nested subagent definitions. The single session dispatch hook rejects unknown, explicit-background, unsafe-name, or team-style calls. It accepts a bounded lowercase/hyphen custom name such as `ux-architect-calc8`; this is a normal subagent label/resume handle, not a team. It cannot distinguish the active nested parent because an ancestor's frontmatter hook remains active while descendants run; role ownership therefore remains enforced by agent prompts, leaf tool denial, terminal packets, and static topology validation. `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` makes omitted background fields synchronous and can remove that field from the active Agent schema. Leaf design agents omit `Agent`. A child that stops without its terminal packet is a protocol blocker, not a reason to poll or resume. If a required role returns unknown, unavailable, or unregistered, Planner returns `PLAN_BLOCKED` with `Blocker: design_runtime_unavailable`, the exact role, and the runtime error. Inline design, omitted specialist review, and unreviewed Scribe handoff are prohibited fallbacks.

## Routing

```text
DESIGN_ROUTE
profile: none | compact | standard | studio
reasons: <grounded triggers>
agents_required: <minimum role list>
prototype: forbidden | optional | required-after-direction-selection
model_tier: sonnet | opus | fable
existing_system_mode: preserve | extend | greenfield
END_DESIGN_ROUTE
```

- `none`: no user-visible interface or design-system effect.
- `compact`: bounded brownfield UI; one `design-generalist`; no prototype.
- `standard`: new screen, multi-state component, or user-flow change; director, UX, visual, reviewer; no prototype.
- `studio`: greenfield, brand-critical, novel, or high-value experience; three direction summaries, one selection, conditional prototype.

Use Sonnet 5 by default. Use Opus 4.8/high for complex bounded creative direction or a failed Sonnet review. Use Fable 5/high only for highest-value Studio work, dense visual evidence, long-horizon synthesis, or material multithreaded ambiguity. Make one premium selection, not a model ladder. If Fable is unavailable, record Opus fallback.

## Job and handoffs

```text
DESIGN_JOB
task_id: <shared task id>
route: <DESIGN_ROUTE>
request: <user intent>
target: <repository root>
research_evidence: <source refs or none>
existing_system: <paths and preservation constraints>
success_criteria: <observable outcomes>
content_constraints: <claims, sample data, localization>
browser_ui_dialog_policy: <required or not applicable>
END_DESIGN_JOB
```

`DESIGN_BRIEF` contains audience, problem, desired outcome, success measures, evidence, current system, constraints, creative thesis, anti-goals, and content rules.

`UX_SPEC` contains journeys, IA, responsive behavior, content hierarchy, keyboard/focus behavior, accessibility, and applicable loading/empty/error/success/disabled/interaction states.

`VISUAL_SYSTEM_SPEC` contains selected-direction rationale, typography, color, grid, spacing, density, radius, elevation, imagery, component language, states, and DTCG 2025.10 primitive/semantic/component tokens.

`MOTION_ASSET_SPEC` is conditional and contains motion purpose, timings, orchestration, reduced-motion behavior, asset composition, crop, accessibility, responsive use, and fallback.

## Canonical specialist terminal packets

Specialists return the entire packet in their final response. A header mentioned in prose, an attachment reference, or a claim that a packet appeared in an earlier turn is invalid. The terminal hook permits one in-place correction; a second invalid completion reaches the parent as a protocol blocker.

```text
UX_SPEC
journeys: <flows and decision points>
information_architecture: <structure and labels>
responsive_behavior: <viewport/reflow rules>
accessibility: <keyboard, focus, semantics, zoom>
states: <applicable system and interaction states>
evidence: <grounding refs>
assumptions: <labeled>
unresolved_decisions: <none or list>
END_UX_SPEC
```

```text
VISUAL_SYSTEM_SPEC
selected_direction: <approved direction>
direction_rationale: <why it serves the brief>
typography: <families, scale, numeric treatment>
color_and_contrast: <surfaces, text, contrast intent>
layout_and_density: <grid, spacing, responsive density>
tokens: <DTCG primitive, semantic, component groups>
components_and_states: <component language and all relevant states>
accessibility: <focus, forced colors, non-color cues>
engineering_invariants: <must preserve>
evidence: <grounding refs>
assumptions: <labeled>
unresolved_decisions: <none or list>
END_VISUAL_SYSTEM_SPEC
```

`MOTION_ASSET_SPEC` ends with `END_MOTION_ASSET_SPEC` and uses `scope: motion` or `scope: asset`; `DESIGN_REVIEW_RESULT` ends with `END_DESIGN_REVIEW_RESULT`; and prototype results end with `END_PROTOTYPE_DONE` or `END_PROTOTYPE_BLOCKED`. A design failure uses `DESIGN_BLOCKED`, `reason:`, `evidence:`, and `END_DESIGN_BLOCKED`.

```text
DESIGN_HANDOFF
task_id: <shared task id>
profile: compact | standard | studio
selected_direction: <name and rationale>
design_brief: <DESIGN_BRIEF>
ux_spec: <UX_SPEC>
visual_system_spec: <VISUAL_SYSTEM_SPEC>
motion_asset_spec: <packet or not applicable>
engineering_invariants: <must preserve>
permitted_variation: <implementation discretion>
browser_validation_brief: <journeys, states, viewports, visible outcomes>
evidence: <local/research refs>
assumptions: <labeled>
unresolved_decisions: <none or list>
END_DESIGN_HANDOFF
```

```text
DESIGN_REVIEW_RESULT
verdict: PASS | NEEDS_REVISION | BLOCKED
findings: <criterion, severity, evidence, impact, bounded remediation>
reviewed_direction: <selected direction>
remaining_limits: <none or list>
END_DESIGN_REVIEW_RESULT
```

One evidence-backed revision may resume the original Design Director. A second disagreement is a user decision. A malformed specialist response is not a revision event: its own stop hook receives one correction, then its parent returns `DESIGN_BLOCKED` with `reason: design_protocol_invalid`. The Director must never create a fresh or anonymous replacement dispatch for that result.

## Studio selection and prototype

Studio first returns `DESIGN_SELECTION_NEEDED` with exactly `safe`, `refined`, and `novel` direction summaries. No direction is implemented before selection. After selection, the Planner may dispatch `design-prototyper` with one exact `.design/prototypes/<task-slug>/` root. The hook permits HTML, CSS, JavaScript, JSON, SVG, and Markdown only, binds a session to one slug, and rejects every other path. The prototype is validation evidence and must not be copied into production without normal engineering implementation and verification.

## Standards and acceptance

- WCAG 2.2 AA intent, keyboard operation, visible focus, contrast, semantic status, zoom/reflow, touch targets, and reduced motion are required.
- DTCG 2025.10 is identified accurately as a stable Design Tokens Community Group report.
- Existing design-system values win unless replacement is explicitly approved.
- Production claims and research are never fabricated; placeholders are labeled.
- All applicable system, interaction, and responsive states are specified.
- A UI implementation plan is incomplete without a passed design review and browser-validation brief.

## Prompt source basis

Prompts adapt, rather than copy, Anthropic's current prompt-engineering, Sonnet 5, Opus 4.8, Fable 5, prompting-tools, and frontend-aesthetics guidance. Project design evidence comes from `design-systems-research.md`, `Architecting Multi-Agent Design Systems  The Blueprint for AI-Driven Frontend Generation.md`, and the MIT-licensed [Trystan-SA design-system prompt research](https://github.com/Trystan-SA/claude-design-system-prompt). Runtime operation does not depend on Claude Console, the GitHub repository, image generation, or an external design service.
