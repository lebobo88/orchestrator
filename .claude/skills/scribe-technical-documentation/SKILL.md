---
name: scribe-technical-documentation
description: Write README, API, architecture, operator, and developer documentation from verified repository and engineering evidence.
user-invocable: false
---

# Technical documentation

Use with `scribe-core` for README, API, architecture, installation, operation, and troubleshooting documents.

1. Trace every behavior, command, path, and example to supplied engineering evidence or current repository files.
2. State prerequisites, supported scope, verification commands, error limits, and operational consequences without implying unverified behavior.
3. Prefer task-oriented headings and short examples with expected outcomes. Preserve compatibility constraints and call out deliberately unsupported workflows.
4. Validate links, paths, command names, and code fences against the target repository before finishing.
5. For browser UI documentation, preserve the no-native-dialog invariant: document app-owned modal or inline-feedback behavior, keyboard/focus expectations, and deterministic verification. Do not document native browser dialogs as supported behavior.
