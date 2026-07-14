---
title: T1 engineer capability enhancement synthesis
slug: t1-engineer-enhancement
profile: standard
mode: technical-documentation
status: ready
created: 2026-07-13
updated: 2026-07-13
---

# T1 engineer capability enhancement synthesis

## Goal and scope

Strengthen the bounded `t1-engineer` implementation worker without changing its Haiku model, existing implementation tools, TDD requirement, single-worker role, or researcher-owned external documentation boundary.

## Findings

- **Observation:** The local coding corpus consistently emphasizes explicit reproduction, route/context discovery, test coverage, error paths, security, performance evidence, integration contracts, UI behavior, and review dimensions. [S1][S2][S3][S4]
  - **So what:** These are repeatable implementation procedures, not new authorities or agents.
  - **Now what:** Package them as concise, on-demand T1 skills, keeping the universal execution rules preloaded.
- **Observation:** Claude Code skills are designed for instructions/checklists that would otherwise be repeatedly pasted, and skill bodies load only when used. [S5]
  - **So what:** A small core skill plus task-specific skills preserves context better than one very large always-loaded prompt.
  - **Now what:** Preload only `t1-core`; let T1 load the minimum relevant specialist skill.
- **Observation:** Claude Code recommends executable verification, exploration before implementation for nontrivial work, and a fresh review when useful. [S6]
  - **So what:** Existing mandatory TDD remains the primary completion gate; skills should deepen task-specific evidence rather than replace it.
  - **Now what:** Add task profiles, a full final quality review, and a research escalation when external/current facts are material.

## Recommendation

Use eight internal skills: preloaded core, TDD/test design, route tracing, refactor safety, performance evidence, API/integration contracts, UI wiring/verification, and security/reliability. Reuse Claude Code bundled `/debug`, `/code-review`, `/run`, and `/verify` when appropriate instead of duplicating generic procedures.

## Constraints preserved

- `t1-engineer` remains Haiku with Read, Write, Edit, Glob, Grep, and Bash; `Skill` is the sole addition.
- Research stays orchestrator → researcher → advisory T1 context.
- No plugins, MCP, teams, Dynamic Workflows, background automation, `claude -p`, unapproved dependencies, or automatic commits.

## Assumptions, unknowns, and contradictions

- **Assumption:** Bundled skills are available in the installed Claude Code version; T1 treats them as optional supplements.
- **Contradiction resolved:** Rapid-prototyping guidance favors speed, while quality guidance favors production rigor. Production-first priorities and TDD control; prototype work may only narrow scope.
- **Unknown:** Repository-specific run/verify recipes vary by target repository, so T1 must discover local test/build conventions instead of assuming one.

## Validation measures

- Scenario fixtures must show each task profile loads the correct specialist guidance while retaining TDD.
- Native interactive smoke tests must demonstrate a RED/GREEN job, route tracing, integration/UI/performance/refactor behavior, and external-documentation research escalation.

## Source ledger

| ID | Source | Type | Authority/relevance | Accessed | Supports |
| --- | --- | --- | --- | --- | --- |
| S1 | `C:\DevAppsFolder\AI Agents and Prompts\Coding\agent_Code_Review_and_Quality_Agent.md` | Local prompt | Quality dimensions, severity, review evidence | 2026-07-13 | Review and security/reliability skills |
| S2 | `C:\DevAppsFolder\AI Agents and Prompts\Coding\agent_Full_Stack_Development_Agent.md` | Local prompt | Development phases, contracts, security, validation | 2026-07-13 | Core/API/UI skills |
| S3 | `C:\DevAppsFolder\AI Agents and Prompts\Coding\agent_Rapid_Prototyping_Agent.md` | Local prompt | Vertical slices and scope simplicity | 2026-07-13 | Prototype profile boundaries |
| S4 | `C:\DevAppsFolder\AI Agents and Prompts\Coding\prompt_debugging.md`, `prompt_feature_addition.md`, `prompt_performance_optimization.md`, `prompt_refactoring.md` | Local prompts | Debug, feature, performance, and refactor procedures | 2026-07-13 | Specialist skill taxonomy |
| S5 | [Claude Code skills](https://code.claude.com/docs/en/skills) | Official documentation | Skill lifecycle, focused bodies, bundled skills | 2026-07-13 | Core + on-demand design |
| S6 | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Official documentation | Verification and explore/plan/code guidance | 2026-07-13 | TDD and task-profile evidence |

## Change log

- 2026-07-13: Initial implementation synthesis.
