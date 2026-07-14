---
name: research-browser-ui-safety
description: Research browser and webview UI safety, accessibility, and automation constraints, including the mandatory prohibition on native browser dialogs.
user-invocable: false
---

# Browser UI safety research

Use with `researcher-core` whenever the target includes a browser-rendered UI or webview.

1. Inspect the current UI for native `alert`, `confirm`, `prompt`, `window.*` variants, and `beforeunload` prompts. Record every observed use and its user/test impact.
2. Treat app-owned accessible dialogs as the required confirmation pattern. State the required keyboard, focus, Escape/cancel, accessible-name, and automation behavior without selecting an unapproved UI library.
3. In `RESEARCH_EVIDENCE`, include a `browser_ui_dialog_policy` item: observed native-dialog use, modal/inline-validation recommendation, migration risks, and deterministic validation measures.
4. Do not implement the UI or add dependencies. Keep recommendations advisory to the approved scope.
