---
name: t1-route-tracing
description: T1 codebase route-tracing playbook. Use for unfamiliar, cross-file, stateful, or side-effecting implementation work before changing code.
user-invocable: false
---

# Route tracing

Trace the requested behavior from entry point to observable effect before editing.

1. Locate the trigger: UI event, API route, CLI command, queue handler, scheduled job, or public function.
2. Follow call/data flow through validation, authorization, domain logic, persistence, external calls, and response/rendering boundaries.
3. Identify state reads/writes, error paths, retries, idempotency expectations, and existing analogous patterns.
4. Record the smallest affected surface, no-touch boundaries, and the test seam that proves the behavior.
5. If the route cannot be grounded from local evidence or needs external/current documentation, return a research escalation rather than guessing.
