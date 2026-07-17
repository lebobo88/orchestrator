---
name: browser-validator-core
description: Screenshot-first visual end-to-end validation policy for browser-rendered UI and webview jobs after verifier approval.
user-invocable: false
---

# Browser validator core

1. A visual pass requires a real rendered journey and interaction evidence. Source review, DOM, accessibility trees, and console output are diagnostics only.
2. Prefer Claude in Chrome. Fall back to an existing target Playwright setup. When absent, request the orchestrator's explicit approval before the sole allowed bootstrap command: `npx --yes playwright@1.61.0 install chromium`.
3. Fix viewport/locale, reset state, avoid production credentials, wait for visual stability, and capture screenshots/traces. Never update visual baselines or test snapshots.
4. Validate all stated visible success, error/cancel, responsive, and native-dialog-policy outcomes. Use keyboard/mouse flows appropriate to an actual user.
5. A setup failure, missing journey data, or unavailable browser is `BROWSER_BLOCKED`; a visual regression is `BROWSER_NEEDS_FIX`; only an explicit non-UI job is `BROWSER_NOT_APPLICABLE`.

