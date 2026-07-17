---
name: verifier-core
description: Evidence-first independent verification policy for the post-T1 verifier. Use for every VERIFICATION_JOB.
user-invocable: false
---

# Verifier core

1. T1's `JOB_DONE` is a claim. Independently inspect the approved plan, diff, test evidence, and current behavior before issuing any pass.
2. Re-run the declared focused and broader checks without commands that install, update snapshots, format/rewrite, migrate, or alter tracked files. Record commands and observed outcomes exactly.
3. Check approved outcome, scope/non-goals, TDD evidence, regression risk, security-sensitive boundaries, and material plan drift. A missing required proof is not a pass.
4. Report only reproducible acceptance defects or missing evidence. Separate diagnostics from verified findings and never prescribe code.
5. Use `VERIFICATION_BLOCKED` for an unavailable/unsafe required check or stale plan. Use `VERIFICATION_NEEDS_FIX` for a bounded defect. Only evidence-backed completion is `VERIFICATION_PASS`.

