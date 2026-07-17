---
name: engineering-fleet
description: Native Claude Code routing and handoff policy for the T1/T2/T3 engineering fleet and Engineering Lead. Use for an engineering job after planning, an escalation, or an explicitly authorized extreme advisory team.
user-invocable: false
---

# Engineering fleet

Use this policy with `docs/BUILD-CONTRACT.md`. It adds tiers without changing user authority, plan approval, TDD, or independent verification.

## Default route

- Send a basic or ordinary approved job to `t1-engineer`.
- Use `docs/JUDGE-CONTRACT.md` selectively: `CODE_REVIEW` follows eligible `JOB_DONE`, `VERIFICATION_CHALLENGE` follows a pass only when evidence risk remains, and `VISUAL_REVIEW` follows browser evidence only for eligible high-value UI. Start at Luna/Terra/Sol based on risk; never ladder automatically or substitute Claude.
- Count only a completed T1 implementation/remediation cycle that returns `JOB_DONE` and then receives `VERIFICATION_NEEDS_FIX` or `BROWSER_NEEDS_FIX`.
- Permit one judge-driven remediation loop with stable finding IDs. It is separate from the two deterministic remediation cycles. A standard task has at most two Codex calls; high-risk/Studio has at most four.
- After cycle 2, create `ENGINEERING_ESCALATION_PACKET` and dispatch `t2-engineer`. `JOB_BLOCKED`, `Plan stale`, research, credentials, unsafe commands, and unavailable prerequisites never increment the count.
- T2 has two counted remediation cycles. A third gate failure becomes a user-review/replanning block; do not promote T3 into a writer.

## T2 scope re-dispatch

When T2 returns `RESCOPE_REQUIRED reason: remediation_scope_exceeded`, the Orchestrator verifies that the remaining work is wholly within the current approved plan and preserves the acceptance checks. It may automatically re-dispatch T2 once per approved-plan revision and `scope_fingerprint` using `ENGINEERING_JOB` with `assignment_kind: full-build-continuation`, `writer_ownership: t2`, and complete prior-work evidence. This is a fresh full-build assignment, not a T2 remediation cycle.

Consult Engineering Lead only when the remaining work meets the existing extreme-complexity criteria. Start an extreme advisory team only when the approved plan explicitly authorizes it; otherwise direct T2 continuation is the default. Repeated scope rejection, `Plan stale`, changed acceptance criteria, or a missing prerequisite is `JOB_BLOCKED` for replanning/user review.

## Extreme advisory team

Use only when the user-approved plan explicitly authorizes it and the Engineering Lead classifies the work as extreme. The Orchestrator is the native team lead and starts named Engineering Lead, T1, and T3 teammates. T1 is the only writer.

T3 may recommend a T2 escalation, but it cannot command one. Engineering Lead requests a `WRITER_RELEASED` receipt from T1. The Orchestrator dispatches or adds T2 only after that receipt. If it is missing or T1 may still edit, block the handoff. File ownership is a coordination protocol: teams do not enforce source-file locks, so keep one writer active and record non-overlapping paths for future swarm work.

If team transport/provider support is unavailable, run the same Lead/T3 checkpoints serially with named resumable subagents and report `team_mode: serial-advisory-fallback`.

## Required packets

```text
ENGINEERING_ESCALATION_PACKET
task_id: <shared task id>
from: t1-engineer | t2-engineer
to: t2-engineer
approved_plan: <path or not applicable>
writer_ownership: t1 released | t2 assigned
remediation_cycles: <0 | 1 | 2>
current_status_and_diff: <exact status and changed paths>
tdd_and_test_evidence: <RED/GREEN/focused/broader evidence>
failed_gate_packets: <complete judge/verifier/browser packets>
judge_findings: <stable IDs, evidence, disposition, policy action>
scope_and_non_goals: <approved boundaries>
END_ENGINEERING_ESCALATION_PACKET
```

`ENGINEERING_ADVISORY`, `T2_ESCALATION_RECOMMENDATION`, `WRITER_RELEASED`, and `ENGINEERING_ROUTE` use their agent contracts. None grants permission, changes scope, or replaces Verifier/Browser Validator.

## Future modes

Document, but do not activate, a mode unless it declares eligibility, model/cost policy, agent count, writable paths, dependency order, retry cap, fallback, and terminal gates.

- **Best-of-3:** three read-only diagnosis/solution candidates; Engineering Lead selects one; exactly one writer implements.
- **Swarm:** explicit user opt-in; two to four specialized T1 writers with plan-defined, non-overlapping paths and independent gates. Use worktrees only when isolation is explicitly requested.
