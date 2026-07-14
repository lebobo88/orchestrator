---
name: t1-ui-wiring-verification
description: T1 UI wiring and verification playbook. Use for frontend behavior, forms, flows, state transitions, responsive layouts, or accessibility-sensitive changes.
user-invocable: false
---

# UI wiring and verification

1. Trace the user flow from trigger to state transition, request/action, success result, and recovery path.
2. Cover loading, empty, error, disabled, retry, and permission-denied states that are material to the requested flow.
3. Preserve semantic controls, keyboard operation, focus behavior, labels, accessible names, contrast/design-system conventions, and responsive constraints when applicable.
4. Write an executable behavioral UI test first. Add visual/browser verification only when repository tooling supports it; it supplements rather than replaces the test.
5. Verify the final flow against the stated acceptance check and report any environment/browser limitation rather than claiming visual success.
