---
name: planner-risk-validation
description: Add proportionate risk, verification, rollout, rollback, security, accessibility, and stale-plan controls to a plan. Use for medium/high-risk, migration, integration, browser UI, or security-sensitive work.
---

# Risk and validation

1. Identify material correctness, security/privacy, compatibility/data, operational, accessibility, and rollback risks.
2. Define the narrowest deterministic verification for each material risk, plus the strongest practical broader check.
3. For migrations or irreversible operations, state backup, rollback, compatibility, and approval boundaries before downstream work begins.
4. For browser-rendered UI or webview work, preserve the Browser UI invariant: no native browser dialogs; accessible app-owned modal or inline validation; keyboard/focus behavior; source-level no-native-dialog scan.
5. Mark the plan stale when current repository state, requirements, dependencies, or research evidence materially invalidates its assumptions. Require replanning or explicit reapproval.
