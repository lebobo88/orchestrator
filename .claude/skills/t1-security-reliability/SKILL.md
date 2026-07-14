---
name: t1-security-reliability
description: T1 security, reliability, and recovery playbook. Use for changes that cross trust, data, auth, secrets, persistence, or critical failure boundaries.
user-invocable: false
---
# Security and reliability

- Identify trust boundaries, attacker/misuse inputs, sensitive data, authorization decisions, secrets/configuration, and least-privilege expectations.
- Validate at the boundary; use safe parsing/encoding and existing parameterized/sanitized patterns. Never expose secrets, internal errors, or sensitive records in logs or responses.
- Define failure containment: retries/timeouts, cleanup, consistency, idempotency, rollback/forward recovery, and safe degradation appropriate to the system.
- Ensure material events/errors can be observed through the repository's existing logging, metrics, tracing, or audit patterns without adding unapproved telemetry.
- Add focused tests for the material security and failure paths. Escalate destructive, regulated, credential-bearing, or externally documented decisions instead of guessing.
