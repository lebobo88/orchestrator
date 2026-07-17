---
name: cross-vendor-judging
description: Routes selective local Codex plan, code, verification, and visual judgment with evidence-backed blocking and strict cost caps.
---

# Cross-vendor judging

Read `docs/JUDGE-CONTRACT.md` and `.claude/judge-policy.json`. Codex is a critic, not an implementer or deterministic verifier.

## Checkpoints

- `PLAN_DUCK`: after Scribe's plan and applicable design pass, before approval/engineering.
- `CODE_REVIEW`: after `JOB_DONE`, before Verifier.
- `VERIFICATION_CHALLENGE`: after `VERIFICATION_PASS`, before Browser Validator, only when coverage/evidence risk remains.
- `VISUAL_REVIEW`: after browser evidence and before final acceptance, only for Studio, brand-critical, accessibility-critical, or explicitly high-value UI.

Skip trivial deterministic single-file work without public-contract, security, data-flow, or user-visible impact. T1 normally skips unless a trigger applies. T2 uses Luna/Terra at relevant boundaries. T3/high-consequence work uses Terra. Standard work has at most two calls; high-risk/Studio has at most four. Put adversarial criteria into the one applicable Terra rubric rather than making a duplicate call.

## Model route

- `gpt-5.6-luna`, medium: clear repeatable plan completeness and bounded evidence checks.
- `gpt-5.6-terra`, medium: everyday multi-file, cross-layer, contract, state, and integration review; also all high-risk, adversarial, verification, and brand-critical visual review.

Start at the routed tier. Escalate once only after `ABSTAIN`, insufficient evidence, or a substantiated risk-tier conflict. Never use Claude as a cross-vendor fallback.

## Blocking

The local adapter, not the judge, computes the policy action. Only an unsuppressed major/critical finding with per-finding high confidence, criterion, evidence, and location can require remediation. Minor, advisory, style-only, and lower-confidence findings remain visible. Verifier/Browser failures always dominate a judge pass. One judge-driven remediation loop is permitted.

In shadow mode, all valid results are advisory regardless of policy action. Never claim a skipped or unavailable required high-risk check passed.
