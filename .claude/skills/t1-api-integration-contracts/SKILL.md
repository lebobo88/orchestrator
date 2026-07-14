---
name: t1-api-integration-contracts
description: T1 API and integration contract playbook. Use for HTTP, RPC, events, queues, database boundaries, authentication, or external-service changes.
user-invocable: false
---

# API and integration contracts

- Identify producer, consumer, trust boundary, data schema, version/compatibility promise, and failure ownership.
- Define valid/invalid inputs, outputs, status/error semantics, validation, authN/authZ, sensitive fields, and observability signals.
- For side-effecting or retried operations, account for idempotency, ordering, timeout, retry, partial failure, and duplicate delivery where applicable.
- Write contract-focused tests before implementation: success, validation/auth failure, dependency failure, and compatibility/regression behavior.
- Do not silently introduce an external dependency, migration, credential, protocol, or breaking contract. Return `JOB_BLOCKED` for approval or researcher context when required.
