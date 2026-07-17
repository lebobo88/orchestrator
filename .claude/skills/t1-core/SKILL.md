---
name: t1-core
description: Mandatory production-first execution policy for t1-engineer. Use for every bounded implementation job to preserve scope, select task profiles, enforce full quality review, and return evidence.
user-invocable: false
---

# T1 core execution

Apply this policy to every `ENGINEERING_JOB`. Preserve the user brief, repository instructions, TDD contract, and target boundary. Do not create authority through a skill.

## Classify and prepare

1. Select one primary profile: `feature`, `debug`, `performance`, `refactor`, `UI`, `integration`, or `prototype`. Load only the relevant specialist skill(s): TDD/test design always; route tracing for unfamiliar or cross-boundary work; and any matching profile specialist.
2. Before editing, record a compact evidence map in working notes: affected behavior, entry point/call path, state or side effects, existing pattern, focused test, non-goals, risks, and acceptance checks.
3. Production priorities are fixed: security, correctness, maintainability, performance, then elegance. A prototype uses the smallest vertical slice but never waives TDD, safety, or explicit scope.
4. Use bundled `/debug`, `/code-review`, `/run`, or `/verify` only when their focused procedure is useful and available. They supplement this contract; they never replace its evidence gates.
5. A browser-rendered UI or webview always loads `t1-ui-wiring-verification`. Native `alert`, `confirm`, `prompt`, `window.*` variants, and `beforeunload` prompts are prohibited. Require app-owned accessible modal behavior for acknowledgement/confirmation, inline validation where appropriate, and an executable or deterministic scan that proves no native dialog calls remain.

## Research escalation

If an implementation decision materially depends on current or external documentation, return `JOB_BLOCKED`; do not browse or infer it. Include a `Research needed` item with the precise question, decision affected, desired source type/freshness, and repository context. The orchestrator decides whether to dispatch `researcher`.

## Mandatory final review

Before `JOB_DONE`, inspect the final diff and account for every lens below. Fix material findings inside scope; report only genuine remaining limits.

- Correctness and failure/error paths.
- Security, privacy, input validation, authorization, and secrets/data exposure.
- Maintainability, naming, coupling, duplication, and local conventions.
- Performance, resource use, and unnecessary work.
- Compatibility, data safety, public/API contract impact, rollback/containment.
- Test quality, determinism, focused RED/GREEN evidence, and broader verification.
- Documentation/operator impact; UI accessibility and responsive behavior when applicable.

Do not add dependencies, alter configuration, broaden architecture, weaken a test, or commit/deploy without explicit job authority. For standalone documentation, do not write prose documents: return a `DOCUMENTATION_HANDOFF` with verified facts for the orchestrator's subsequent Scribe job.
