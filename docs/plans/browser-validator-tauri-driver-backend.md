# Plan: browser-validator-tauri-driver-backend — Authorize a pinned tauri-driver backend for native Tauri/WebView2 desktop targets

Status: **APPROVED for execution, 2026-07-18, by the project user (explicit interactive approval via the orchestrator). Approved as-is (Revision 2, including the second-round J-02-WRONG-WINDOW correction): the 12-file dispositioned edit surface, the Playwright-mirrored approval-gate pattern, pinned `tauri-driver` 2.0.6, host-resolved `msedgedriver` matching the authoritative WebView2 Runtime version (not the Edge browser version), the mandatory `alwaysMatch` session capability requirement, the strengthened post-session identity verification (specificity floor plus PID/process cross-check), the fresh-run process-provenance lifecycle, and the classification of this work as Scribe-owned (non-code governance/config markdown and test fixtures, not engineering-fleet work). See Section 14 for the full approval record.**

task_id: tauri-driver-backend-authorization
plan_id: browser-validator-tauri-driver-backend

This plan recommends work. It does not grant execution authority. No downstream editor may change any file listed below until the user gives explicit approval. Approval of this plan authorizes only the twelve file edits in Section 6; it does not authorize any commit, push, deployment, pull request, or the actual dispatch of a downstream browser-validation job against a real Tauri target. This plan governs a harness/governance change to the orchestrator's own agent definitions and contracts (`.claude/agents/`, `.claude/skills/`, `docs/`, `tests/`). It does not touch product code in any target repository, including photo-genie.

## 1. Outcome and audience

**Audience**: the orchestrator harness maintainer (the user), who approves this plan and the resulting contract text, and Scribe, who edits the twelve approved files after approval (see Section 13 on why Scribe, not an engineering writer, is the correct downstream editor).

**Observable result**: after the approved edits land, the `browser-validator` role formally recognizes a fourth-total, third-alternative backend — pinned `tauri-driver` — for native Tauri/WebView2 desktop app targets, alongside the existing Claude-in-Chrome and Playwright backends for browser-rendered web UI. Revision 1 of this plan scoped the change to five files. This revision (Revision 2) expands that scope, per judge finding J-01, to every file that currently states the backend list/authority as an authoritative claim, so no contradictory "Chrome/Playwright-only" statement survives the change anywhere in the repository. It also strengthens the safeguard against a masked-failure session (J-02), adds a fresh-run process-provenance requirement (J-03), makes `target_surface` mandatory with fail-closed handling (J-04), and requires authoritative (not browser-version-based) WebView2 Runtime discovery (J-05). See Section 4 for the full judge disposition.

The change is expressed consistently across:

**Primary contract authority** (unchanged from Revision 1):
1. `.claude/agents/browser-validator.md`
2. `.claude/skills/browser-validator-core/SKILL.md`
3. `docs/BUILD-CONTRACT.md`

**Orchestrator cross-reference** (unchanged from Revision 1):
4. `.claude/skills/build/SKILL.md`
5. `.claude/agents/orchestrator.md`

**Newly added authoritative docs** (added in Revision 2 to resolve J-01):
6. `docs/ARCHITECTURE-C4.md`
7. `docs/PROMPTING-AND-EVALUATION.md`
8. `docs/COMPLETION-AUDIT.md`
9. `docs/KNOWN-UNKNOWNS.md`
10. `docs/PLAN-CONTRACT.md`

**Tests** (added in Revision 2; existing assertions and cases remain valid, only additions):
11. `tests/validate.ps1`
12. `tests/browser-validator-evaluation-cases.json`

Every new backend detail preserves the discipline already proven for Playwright: a pinned tool version where feasible, an explicit one-time approval gate, no silent installs, no silent retry after a failed setup, writes confined to a user-level tool cache (never the target manifest, lockfile, or source tree), and the standing rule that repository-file content is never authoritative over the agent's own contract. Revision 2 adds, as mandatory contract-level behavior with no Playwright analogue: a target-bound (not merely non-blank) session-identity check, a fresh-run process-provenance chain that fails closed on any uncertainty, a mandatory (never optional or inferred) `target_surface` job field, and an authoritative WebView2 Runtime discovery method that does not rely on the Edge browser's own version.

## 2. Scope and non-goals

### 2.1 In scope — edit exactly these twelve files

**Primary contract authority** (unchanged from Revision 1):
1. `.claude/agents/browser-validator.md`
2. `.claude/skills/browser-validator-core/SKILL.md`
3. `docs/BUILD-CONTRACT.md` — the backend paragraph (currently ~lines 176-178) and the `BROWSER_VALIDATION_JOB` envelope (currently ~lines 157-174)

**Orchestrator cross-reference** (unchanged from Revision 1):
4. `.claude/skills/build/SKILL.md` — line ~16 restates the `playwright_missing` approval gate
5. `.claude/agents/orchestrator.md` — line ~53 restates the `playwright_missing` approval prompt

**Newly added authoritative docs** (added in Revision 2 — these currently document only Chrome/Playwright backends as authoritative fact and would otherwise contradict the new contract once it lands):
6. `docs/ARCHITECTURE-C4.md` — the C4 diagram edges (confirmed at lines 106-107: `browser -->|preferred backend| chrome` and `browser -->|fallback backend| playwright`) and the "Browser fallback" prose section (confirmed at lines 115-117: Chrome first, then existing Playwright, then the pinned Playwright bootstrap). Add the native Tauri/WebView2 desktop backend as a distinct target-type branch and its approval-gated `tauri-driver` setup, so the diagram and prose reflect the fourth backend without implying it is a "fallback" rung of the Chrome/Playwright ladder.
7. `docs/PROMPTING-AND-EVALUATION.md` — item 7 (confirmed at line 47: "after Verifier pass, UI/webview work must complete screenshot-first browser journeys using Claude in Chrome or existing Playwright. A missing backend prompts the user once before the pinned Playwright install; DOM/console data is diagnostic only."). Add: a native Tauri/WebView2 desktop target uses the approval-gated pinned `tauri-driver` backend instead; a missing `tauri-driver` prompts the user once before the pinned `tauri-driver` setup.
8. `docs/COMPLETION-AUDIT.md` — the "Browser fallback recovery" row (confirmed at line 17, Playwright-only today: "A missing browser backend returns `BROWSER_BLOCKED`; the orchestrator requests explicit approval before Browser Validator downloads Playwright 1.61.0 and Chromium into user caches, then resumes the same validation job."). Extend the row, or add a parallel row, so the recovery description also covers the `tauri_driver_missing` → one-time approval → pinned `tauri-driver` plus host-matching `msedgedriver` setup path, writing only to Cargo bin / tooling cache.
9. `docs/KNOWN-UNKNOWNS.md` — the "Browser Validator" decision row (confirmed at line 19: "Claude in Chrome availability, target launch/reset recipe, and browser-test credentials/fixtures... If no backend exists, the orchestrator asks before downloading pinned Playwright and Chromium into user caches."). Add the `tauri-driver`/`msedgedriver` setup-approval decision and the host WebView2 Runtime version resolution (and its fail-closed path) as known decision points for native-desktop targets.
10. `docs/PLAN-CONTRACT.md` — the native smoke-test bullet 7 (confirmed at line 127: "...the Browser Validator has a Chrome-first/Playwright-fallback path."). Minor addition: acknowledge that a native Tauri/WebView2 desktop target selects the `tauri-driver` backend as one backend per target type, not an added fallback rung of the Chrome/Playwright ladder.

**Tests** (added in Revision 2; existing assertions and cases must remain valid, only additions):
11. `tests/validate.ps1` — after the existing browser-validator assertions (confirmed at lines 497-504: `BROWSER_PASS`/`BROWSER_NEEDS_FIX`/`BROWSER_BLOCKED`/`BROWSER_NOT_APPLICABLE` headings, `mcp__claude-in-chrome__*` scoping, no write tools, `playwright_setup_authorized`, and the exact substring `playwright@1.61.0 install chromium`), add static checks confirming the browser-validator agent/skill/contract now contain: `pinned-tauri-driver-2.0.6`, `tauri_driver_setup_authorized`, `cargo install tauri-driver --version 2.0.6`, the mandatory `alwaysMatch` requirement, `tauri_session_unverified`, and `target_surface`. Every existing check listed above must remain green and unmodified.
12. `tests/browser-validator-evaluation-cases.json` — confirmed today to hold nine cases in a `{name, expected_verdict, required_evidence}` shape (a Chrome-pass case, a visual-regression case, a native-dialog-regression case, a Chrome-unavailable/existing-Playwright case, a missing-Playwright-requires-approval case, an approved-Playwright-setup-resumes case, a declined-approval-remains-blocked case, an install-failure-remains-blocked case, and a ninth case — not independently re-read in this pass, so its exact name is not restated here). Add ten new cases in the same shape, preserving all nine existing cases unchanged (Section 6, Step 12, enumerates the ten additions).

### 2.2 Left unchanged, with documented reason

The following are confirmed, by this revision's scope analysis, not to encode the browser-validator backend list or its authority — they either reference the role by name only or use "backend" in an unrelated sense — so they remain correct and non-contradictory without any edit:

- `CLAUDE.md`
- `docs/CAPABILITY-MAP.md`
- `docs/DESIGN-CONTRACT.md`
- `.claude/skills/t2-escalation/SKILL.md`
- `tests/terminal-packet-hook-cases.json`
- `tests/agent-topology-cases.json`
- `tests/design-routing-cases.json`
- `.claude/hooks/validate-terminal-packet.ps1` (covers only Planner and design-role packets, not `browser-validator`)
- `.claude/hooks/validate-agent-dispatch.ps1` (only allowlists agent names by role, not by backend)
- every `docs/plans/*.md` artifact (frozen historical records) and all project sources (`lizbeth_spanish`, `calculator-financial-tauri`, photo-genie, `mythic-proportion`)

**Optional item, not required**: `docs/ARCHITECTURE-ADAPTATION.md` describes Browser Validator as checking "rendered UI/webview journeys" without restating the backend enum, so it is not a required edit under this plan. A one-line broadening to acknowledge native WebView2 desktop targets would keep it fully consistent with the change. This remains flagged for the user to accept or decline at approval; it is not edited unless separately approved, and doing so would be an addition to this section's scope.

### 2.3 Non-goals (explicit — do not exceed these boundaries)

- Do **not** re-run or re-validate the photo-genie P2 UI journeys. That is separate downstream work once this authorization lands.
- Do **not** modify any photo-genie application code.
- Do **not** hardcode photo-genie-specific paths into the general contract text.
- Do **not** touch any agent role's authority, tools, or scope beyond the twelve files in Section 2.1; the additions in Revision 2 correct contradictory authoritative statements, they do not change what any other role is authorized to do.
- Do **not** create a new general reference document. The policy lives entirely in the twelve files in Section 2.1.
- Do **not** edit any file listed in Section 2.2 as part of this plan.

## 3. Repository findings and evidence

Line numbers below are current as read during planning and may shift slightly before editing; the downstream editor must re-locate the exact text before editing rather than trusting these numbers as byte-exact anchors.

**Primary contract authority:**
- `.claude/agents/browser-validator.md`: `tools:` (line 4) already includes `Bash` and `mcp__claude-in-chrome__*` — no tools-field addition is needed; only prose must explicitly authorize Bash for native-desktop process management. The current backend fallback ladder is in the second paragraph (line 14): Claude-in-Chrome first → existing Playwright → approval-gated `npx --yes playwright@1.61.0 install chromium`. `BROWSER_PASS.backend` enum (line 33): `claude-in-chrome | existing-playwright | pinned-playwright-1.61.0`. `BROWSER_BLOCKED.reason` enum (line 63): `playwright_missing | playwright_install_failed | browser_unavailable | missing_prerequisite | unsafe_environment`, plus a `playwright_setup_authorized: yes | no | not applicable` field (line 66). The validation procedure is steps 1-5 (lines 18-22).
- `.claude/skills/browser-validator-core/SKILL.md`: a five-point policy; point 2 states the Chrome→Playwright fallback and the sole bootstrap command; point 5 states the blocked/needs-fix/not-applicable mapping.
- `docs/BUILD-CONTRACT.md`: the `BROWSER_VALIDATION_JOB` envelope (lines 157-174) includes fields `launch_and_readiness`, `base_url`, `fixture_and_reset`, `journeys`, `viewport_profiles`, `browser_ui_dialog_policy`, `playwright_setup_authorized: no | yes`, `remediation_cycle`. The backend paragraph (lines 176-178) states the Chrome-first/Playwright-fallback/approval-gated-pinned-install rule.

**Orchestrator cross-reference:**
- `.claude/skills/build/SKILL.md` (line 16): "If `BROWSER_BLOCKED` reports `playwright_missing`, obtain explicit user approval before re-dispatching Browser Validator with the pinned Playwright setup authority."
- `.claude/agents/orchestrator.md` (line 53): the `playwright_missing` approval-prompt paragraph.

**Newly added authoritative docs (confirmed by direct read during this revision):**
- `docs/ARCHITECTURE-C4.md`, lines 106-107: `browser -->|preferred backend| chrome` and `browser -->|fallback backend| playwright`. Lines 115-117, "Browser fallback" section: "Browser Validator uses Claude in Chrome first, then an existing Playwright setup. When neither is available it returns `BROWSER_BLOCKED` with `playwright_missing`; the orchestrator asks the user once before allowing the pinned `npx --yes playwright@1.61.0 install chromium` bootstrap. The fallback uses npm/Playwright user caches and must not change the target repository's dependency manifest, lockfile, or source tree."
- `docs/PROMPTING-AND-EVALUATION.md`, line 47: "Browser validator: after Verifier pass, UI/webview work must complete screenshot-first browser journeys using Claude in Chrome or existing Playwright. A missing backend prompts the user once before the pinned Playwright install; DOM/console data is diagnostic only."
- `docs/COMPLETION-AUDIT.md`, line 17: the "Browser fallback recovery" row reads "A missing browser backend returns `BROWSER_BLOCKED`; the orchestrator requests explicit approval before Browser Validator downloads Playwright 1.61.0 and Chromium into user caches, then resumes the same validation job. Implemented and statically checked; download and live browser execution require user approval and a target fixture."
- `docs/KNOWN-UNKNOWNS.md`, line 19: the "Browser Validator" row reads "Claude in Chrome availability, target launch/reset recipe, and browser-test credentials/fixtures | UI completion is blocked until a rendered browser journey can be validated. If no backend exists, the orchestrator asks before downloading pinned Playwright and Chromium into user caches."
- `docs/PLAN-CONTRACT.md`, line 127 (native smoke test 7): "Complete a browser UI job. Confirm Planner persists Browser Validator inputs, T1 cannot self-approve, verifier passes before browser validation, and the Browser Validator has a Chrome-first/Playwright-fallback path."

**Tests (confirmed by direct read during this revision):**
- `tests/validate.ps1`, lines 497-504, require (among other things): the four `### BROWSER_*` headings, `mcp__claude-in-chrome__\*` tool scoping, no `Write`/`Edit` tools, the substring `playwright_setup_authorized`, and the exact substring `playwright@1\.61\.0 install chromium`. None of these assertions pin the literal backend-enum string itself, so adding a fourth enum value is additive and non-breaking, but every quoted substring above must still match after the edit.
- `tests/browser-validator-evaluation-cases.json`: confirmed to use a flat JSON array of objects shaped `{"name": <string>, "expected_verdict": "BROWSER_PASS" | "BROWSER_NEEDS_FIX" | "BROWSER_BLOCKED", "required_evidence": [<strings>]}`. The first eight entries were directly re-read this pass and match Revision 1's description (a Chrome-pass case, a visual-regression case, a native-dialog-regression case, a Chrome-unavailable/existing-Playwright case, a missing-Playwright-requires-approval case, an approved-Playwright-setup-resumes case, a declined-approval-remains-blocked case, and an install-failure-remains-blocked case); a ninth case exists per Revision 1's count but was not re-confirmed by direct read in this pass. The downstream editor must re-read the full file before adding the ten new cases in Section 6, Step 12, to avoid disturbing any existing entry.

**Coupling check (confirms the twelve-file edit surface is complete; carried forward from Revision 1, re-affirmed by this revision's non-goals list in Section 2.2)**: `.claude/hooks/validate-terminal-packet.ps1` validates only Planner and design-role packets — `browser-validator` is not covered, so no hook change is needed for the new enums. `.claude/hooks/validate-agent-dispatch.ps1` only allowlists agent names — no change needed. `.claude/schemas/` contains only `judge-result.schema.json`, unrelated to this change.

**Verified-working reference evidence** (grounded, independently smoke-tested in the session that produced Revision 1; cited as the technical reference, never copied into general contract text as a project-specific path): `photo-genie/test-assets/TAURI-DRIVER-SETUP.md` and `photo-genie/test-assets/smoke-test.py`. The smoke test confirmed that `tauri-driver` 2.0.6 (installed via `cargo install tauri-driver`) plus a WebView2-Runtime-matching `msedgedriver.exe` (v150.0.4078.65 for that host) launched the real `photo-genie.exe` WebView2 window and returned a genuine title ("Mythic Proportion") and URL ("http://localhost:5173/app/") over the standard W3C WebDriver REST protocol (proxy port 9000 → native `msedgedriver` port 9001). `tauri-driver` is a W3C WebDriver REST proxy that rewrites the `tauri:options.application` capability into `ms:edgeOptions.binary` plus `browserName: "webview2"`.

`research_status = not-needed` for the core mechanism (grounded in the verified smoke test above). For finding J-05's registry-based fallback discovery path, nested Researcher was considered but not invoked, because the primary discovery method (the WebView2 loader API) is authoritative and does not depend on the registry GUID; the registry fallback path is flagged in Section 5.9 for edit-time confirmation against current Microsoft documentation rather than asserted as fact.

`design_route: none`. This is textual governance/contract work with no user-facing product design surface.

## 4. Judge disposition (PLAN_DUCK — Luna/medium, shadow/advisory)

The following five findings were returned by a `PLAN_DUCK` review (Luna, medium risk, shadow/advisory mode) against Revision 1 of this plan. Per `docs/PLAN-CONTRACT.md`, this is Planner's single authorized resume incorporating that review; the findings are advisory and this plan's own deterministic acceptance checks (Section 8) still dominate. Finding IDs are preserved verbatim.

- **J-01-BLAST-RADIUS (major)** — Revision 1 scoped the edit to five files, but `docs/ARCHITECTURE-C4.md`, `docs/PROMPTING-AND-EVALUATION.md`, `docs/COMPLETION-AUDIT.md`, `docs/KNOWN-UNKNOWNS.md`, and `docs/PLAN-CONTRACT.md` also make authoritative Chrome/Playwright-only backend statements, and `tests/validate.ps1` / `tests/browser-validator-evaluation-cases.json` would not exercise the new backend at all. Left as-is, these would become contradictory or blind after the primary edit landed. **Resolved by**: Section 2.1 expands the edit surface to twelve files, grouped by category, each with a confirmed current-text citation (Section 3) and a specific required addition (Section 6). Section 2.2 lists every file confirmed NOT to need an edit, with the reason for each. Section 8 adds a mandatory repository-wide consistency grep as a closing acceptance check so no contradictory statement is left behind.
- **J-02-WRONG-WINDOW (major, most important)** — the Revision 1 safeguard (non-blank title, non-`data:,` URL) is necessary but not sufficient: a coincidentally non-blank, unrelated window could satisfy it while the requested Tauri app never launched. **Resolved by**: Section 5.3 replaces the non-blank-only check with a target-bound identity requirement — a primary process/binary-path anchor (the launched app's recorded PID must correspond to the requested `tauri:options.application` path) plus a secondary content anchor (the observed URL and/or title must match a new mandatory job field, `expected_app_identity`). The check fails closed to `BROWSER_BLOCKED tauri_session_unverified` whenever the window cannot be positively and uniquely associated with the requested application; "not obviously blank" is explicitly insufficient.
  **Second-round correction (2026-07-18)**: a second `PLAN_DUCK` re-check found that Section 7's original `expected_app_identity` definition permitted any URL/title pattern with no specificity requirement, so a careless or malformed job packet (a bare wildcard, a bare scheme/host-only pattern, or a very short title fragment) could still let an unrelated, coincidentally non-blank window pass — undermining the safeguard above. Section 5.3 and Section 7 now require `browser-validator` itself to reject, as `BROWSER_BLOCKED tauri_session_unverified`, any `expected_app_identity` that is empty, a bare match-everything wildcard, a bare scheme/host-only pattern with no distinguishing path or port, or a title pattern under 6 meaningful characters, and to corroborate identity with a deterministic process/PID cross-check against the fresh-run PID this run recorded under J-03 (Section 5.4) rather than relying on content-pattern matching alone.
- **J-03-STALE-PROCESS-REUSE (major)** — a prior, orphaned `tauri-driver`/`msedgedriver`/app process left on the default ports (9000/9001) could be reused or attached to instead of freshly launched, producing an unverifiable or stale session. **Resolved by**: Section 5.4 (new) adds a fresh-run process lifecycle: pre-launch port checks that never attach to an unrecorded occupant, PID recording for every process this run launches, command-line/path verification against what was requested, session creation only against this run's own freshly launched `tauri-driver`, cleanup that terminates only recorded and still-matching PIDs, and a fail-closed `BROWSER_BLOCKED tauri_process_provenance_uncertain` on any provenance uncertainty.
- **J-04-TARGET-SURFACE-AMBIGUITY (major)** — Revision 1 treated `target_surface` as an ordinary, effectively optional job field, leaving room for a missing or self-contradictory value to be silently interpreted rather than rejected. **Resolved by**: Section 5.1 makes `target_surface` mandatory with exactly two values (`browser-web-ui | tauri-webview2-desktop`), never inferred. A missing, empty, or unrecognized value returns `BROWSER_BLOCKED target_surface_invalid`. A value that contradicts the job's actual launch/readiness commands returns `BROWSER_BLOCKED target_surface_mismatch` rather than silently picking a backend. Exactly one backend applies per job; trying multiple backends in any order is explicitly prohibited.
- **J-05-RUNTIME-VERSION-DISCOVERY (minor)** — Revision 1's `msedgedriver` version-resolution method read the Edge browser's own version (via `msedge.exe` `FileVersion` or the `BLBeacon` registry key), which identifies the Edge browser, not necessarily the WebView2 Runtime actually hosting the Tauri app. **Resolved by**: Section 5.9 replaces the Edge-browser-version method with the WebView2 loader API (`GetAvailableCoreWebView2BrowserVersionString`) as the primary, authoritative discovery method, with a documented (edit-time-to-be-confirmed) EdgeUpdate registry fallback, and a fail-closed `BROWSER_BLOCKED webview2_runtime_unresolved` path when the runtime version or a matching driver cannot be authoritatively resolved. Both the resolved runtime version and the `msedgedriver` version used are recorded independently in `BROWSER_PASS.runtime`.

## 5. Design decisions binding on the contract text

These decisions were made during planning (Revision 1) and this remediation (Revision 2) and are load-bearing. The downstream editor must implement the contract text to express each of them, not merely gesture at "add tauri-driver support."

### 5.1 Backend selection is a mandatory, fail-closed target-type branch, not a parallel option (J-04)

Replace the current pure fallback-ladder framing with a target-type branch first, then the existing ladder within the browser branch:

- **IF** the validation target is a native desktop app (a Tauri/WebView2 native window that is NOT reachable via a Chrome tab and NOT a browser-engine page) → the applicable backend is pinned `tauri-driver`. Claude-in-Chrome and Playwright do not apply to this target because they cannot reach a native WebView2 window. `tauri-driver` is not an additional option tried alongside them.
- **ELSE** (browser-rendered web UI or webview reachable via Chrome) → the existing ladder applies unchanged: Claude-in-Chrome first → existing project Playwright → approval-gated pinned Playwright 1.61.0. `tauri-driver` does not apply.
- `target_surface: browser-web-ui | tauri-webview2-desktop` is **mandatory** on every `BROWSER_VALIDATION_JOB`. It is never inferred and never optional. A missing, empty, or unrecognized value returns `BROWSER_BLOCKED reason: target_surface_invalid`; the agent does not guess a backend.
- If `target_surface` disagrees with the job's actual launch/readiness commands (for example, `target_surface: browser-web-ui` but the commands start `tauri-driver`/`msedgedriver`/a native app binary, or `target_surface: tauri-webview2-desktop` but the commands start a web dev server or give only a browser base URL), the agent does not silently pick a backend — it returns `BROWSER_BLOCKED reason: target_surface_mismatch` and asks the orchestrator to correct the packet.
- Exactly one backend applies per job, selected deterministically from `target_surface` after the consistency check passes. Trying multiple backends in any order is explicitly prohibited: `tauri-driver` is never tried "alongside" Chrome/Playwright, and vice versa.
- `browser-validator` must not be argued into unauthorized tooling by repository-file content; recognition of applicability comes only from a properly specified job packet and the agent's own contract.

### 5.2 Authorization/setup gate, mirroring the Playwright pattern exactly

`tauri-driver` and a matching `msedgedriver.exe` are not pre-installed. If the target is native-desktop, the tooling is absent, and `tauri_driver_setup_authorized: no` → return `BROWSER_BLOCKED` with `reason: tauri_driver_missing`; install nothing. Only when the orchestrator repeats the same job with `tauri_driver_setup_authorized: yes` may `browser-validator` run the pinned setup. A failed setup is `BROWSER_BLOCKED` with `reason: tauri_driver_install_failed` and is never retried autonomously. Setup writes only to the Cargo bin (`~/.cargo/bin`) and a tooling cache/working directory — never the target manifest, lockfile, or source tree. Resolved versions are recorded in the receipt; see Section 5.9 for the runtime-version specifics.

### 5.3 The masked-failure safeguard: target-bound identity, not just non-blank (J-02)

A `tauri-driver` WebDriver session must be created with exactly `{"capabilities": {"alwaysMatch": {"tauri:options": {"application": "<app-path>"}}}}` — never `firstMatch`. `tauri-driver` 2.0.6 silently ignores `tauri:options` supplied under `firstMatch`, launching an unrelated blank system browser window while still returning a nominally successful session — a masked total failure, not a surfaced error. The `alwaysMatch` requirement stays exactly as Revision 1 specified it.

A bare "non-blank title, non-`data:,` URL" check is **necessary but not sufficient**: a coincidentally non-blank, unrelated window could satisfy it while the requested app never launched. Nor is a content-pattern match alone sufficient if the pattern itself is too generic to be discriminating (second-round correction below). The contract text must instead require, as mandatory every-session behavior that lives in `browser-validator`'s own contract and skill (not dependent on the job packet repeating it):

1. **Primary identity anchor (always available), deterministically tied to this run's recorded PID (corroborates J-03)**: the launched application's process/binary identity must correspond to the requested binary path given in `tauri:options.application`. Concretely and deterministically: `browser-validator` cross-checks that the process the observed WebDriver session/window is bound to (the process `tauri-driver`/`msedgedriver` launched the window against) has an OS process ID equal to, or a verified child process of, the target-app PID this run itself launched and recorded during the fresh-run process lifecycle (Section 5.4), and that the recorded PID's command line/binary path matches the requested `tauri:options.application` path. Identity confirmation is corroborated by this process-provenance cross-check, not inferred from content alone. If the observed session's window cannot be tied to that recorded PID by this deterministic check, fail closed.
2. **Mandatory validator-side specificity check on `expected_app_identity` (second-round correction; performed before the field is trusted for anchor 3)**: `browser-validator` itself validates the job-supplied `expected_app_identity` field before relying on it — this is enforced agent behavior, never merely guidance to job authors. The agent REJECTS as insufficiently specific, and fails closed, any `expected_app_identity` that is empty or absent, a bare match-everything wildcard (`.*`, `*`, or an equivalent unanchored catch-all expression), a bare scheme-only or host-only pattern with no distinguishing path/port/other specific segment (for example, just `http://localhost` or `localhost` alone), or a title pattern shorter than 6 meaningful (non-whitespace) characters. Section 7 states the identical rejection list and the exact matching semantics (anchored substring/prefix match, or a regex that itself still meets this specificity floor).
3. **Secondary content anchor (target-bound, evaluated only once anchor 2 passes)**: the observed window's URL (`GET /session/{id}/url`) must match the validated `expected_app_identity` URL prefix/pattern, and/or the observed title (`GET /session/{id}/title`) must match the validated `expected_app_identity` title pattern, using the matching semantics from Section 7. A bare non-blank/non-`data:,` value, or an `expected_app_identity` that exists but fails the anchor-2 specificity floor, is **not** sufficient by itself.
4. **Fail closed** to `BROWSER_BLOCKED reason: tauri_session_unverified` whenever the observed window cannot be uniquely and positively associated with the requested application — including a blank title, a `data:,` URL, a URL/title that does not match the validated expected identity, an `expected_app_identity` that fails the anchor-2 specificity check, a PID/process relationship that anchor 1 cannot verify, or the absence of the identity anchors needed to make a positive match. "Isn't obviously blank" is explicitly insufficient. An unverified session is never reported as a pass.

For the native-desktop backend, `base_url` is the `tauri-driver` proxy endpoint (e.g. `http://localhost:9000`); the app's own content URL (from `GET /session/{id}/url`) is distinct from `base_url` and is what `expected_app_identity` anchors against. The agent requires all three of a verified PID/process anchor (item 1), a validated non-degenerate `expected_app_identity` (item 2), and a matching content anchor (item 3) to positively confirm identity; if any one is missing or fails, it blocks. This mirrors and generalizes the verified `photo-genie/test-assets/smoke-test.py` pattern; the agent applies it itself and does not depend on any future job packet repeating it correctly.

### 5.4 Fresh-run process lifecycle, fail closed on provenance uncertainty (J-03)

Add a "fresh-run process lifecycle" requirement, applied to the native-desktop backend, to `browser-validator.md`'s validation procedure and to `browser-validator-core`'s SKILL.md:

1. **Pre-launch port check**: verify the `tauri-driver` proxy port (default 9000), the native `msedgedriver` port (default 9001), and any app content port are free. If a required port is occupied, do not attach to or reuse the occupying process — it may be an orphaned or stale driver from a prior failed run. Fail closed to `BROWSER_BLOCKED reason: tauri_process_provenance_uncertain` and require cleanup or a free port. The only exception is a port confirmed to be owned by this run's own recorded PID, which cannot be true pre-launch.
2. Launch `tauri-driver`, `msedgedriver`, and the target app in this run; record each process's PID.
3. Verify each recorded process's command line or application path matches what this run launched: `msedgedriver`'s native-driver path and port, `tauri-driver`'s ports and `--native-driver` argument, and the app binary path equal to the requested `tauri:options.application` path.
4. Create the WebDriver session only against this run's freshly launched `tauri-driver` (recorded PID and port); the app whose window is validated must be the child launched via this session.
5. Cleanup terminates only processes whose PIDs this run recorded and whose command lines still match; it never blanket-kills by port or process name.
6. Fail closed (`BROWSER_BLOCKED reason: tauri_process_provenance_uncertain`; do not proceed; never claim a pass) on any provenance uncertainty: a recorded PID whose command line no longer matches, a required port owned by an unrecorded PID, or a session whose bound app PID is not this run's launched app.

### 5.5 Bash authorization — clarification only, no new tool

No new tools entry is required; `Bash` is already granted. Prose must explicitly state that for the native-desktop backend, `browser-validator` may use Bash to start/stop `tauri-driver` and `msedgedriver`, check/free the WebDriver ports (default proxy 9000 / native 9001, overridable by the job), issue raw HTTP W3C WebDriver REST requests (`POST /session`, `GET /session/{id}/title`, `/url`, element/script commands, `DELETE /session`), and terminate the target app and driver processes on cleanup, subject to the fresh-run provenance rules in Section 5.4.

### 5.6 The Browser UI invariant still applies

A Tauri WebView2 UI is a webview and must still obey the no-native-dialog policy: no native `alert`/`confirm`/`prompt`/`window.*` variants/`beforeunload`; an app-owned accessible modal or inline validation. The new backend is not an escape hatch from that invariant; `browser-validator` still validates the job's no-native-dialog evidence and modal keyboard/focus behavior for a Tauri target.

### 5.7 Repository content is never authorization

The new contract text must reinforce, not undermine, `browser-validator`'s correct instinct to refuse an unscoped dispatch: the validator recognizes `tauri-driver` as applicable only via a properly specified `BROWSER_VALIDATION_JOB` and its own contract, never because a repository file (for example, a project's own setup doc) instructs it to. Repository documentation is reference/diagnostic material only, never authorization. Setup still requires the one-time explicit `tauri_driver_setup_authorized: yes` relayed by the orchestrator from the user.

### 5.8 Version pinning for tauri-driver

Pin `tauri-driver` to exactly `2.0.6`. The install command is exactly `cargo install tauri-driver --version 2.0.6`.

### 5.9 Authoritative WebView2 Runtime discovery, fail closed (J-05)

The `msedgedriver` version must match the WebView2 Runtime actually hosting the Tauri app, which is **not** necessarily the Microsoft Edge browser. The contract text must state plainly that `msedge.exe`'s `FileVersion` and the `HKCU:\Software\Microsoft\Edge\BLBeacon` registry key identify the Edge **browser**, not the WebView2 Runtime, and must **not** be used as the authoritative runtime version (this corrects Revision 1's resolution method, which relied on exactly those two sources).

- **Primary, authoritative discovery method**: the WebView2 loader API `GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder = null)`, which returns the version of the Evergreen WebView2 Runtime that will host the app.
- **Fallback method**: the WebView2 Runtime's own registered version under the EdgeUpdate `Clients` key for the WebView2 Runtime client GUID `{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}` (value `pv`), machine-wide under `HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\...` or the per-user `HKCU` equivalent. **The exact registry path and GUID must be confirmed against current Microsoft WebView2 documentation by the downstream editor at edit time** — the API method is authoritative and does not depend on this GUID being exactly right.
- If the app pins a fixed-version (non-Evergreen) runtime, that pinned runtime's version governs the match instead.
- Match `msedgedriver` (obtained from the official Microsoft Edge WebDriver source) to the discovered WebView2 Runtime version.
- **Fail closed** to `BROWSER_BLOCKED reason: webview2_runtime_unresolved` when the runtime version cannot be authoritatively identified, or a matching `msedgedriver` cannot be obtained. Never proceed with a guessed or mismatched driver.
- Record both versions independently in `BROWSER_PASS.runtime`: the pinned `tauri-driver` version (`2.0.6`), the resolved WebView2 Runtime version, the `msedgedriver` version used, and confirmation that the driver matches the runtime.

### 5.10 Generality without hardcoding

The authorization is general: available to any future Tauri/native-desktop-app validation job across any project this orchestrator touches, not specific to photo-genie. Per-project specifics — the app binary path, the `tauri-driver` proxy base URL/port, the `msedgedriver` location, the fixture/reset procedure, `expected_app_identity` — come from the `BROWSER_VALIDATION_JOB` packet, not from hardcoded contract text.

## 6. Ordered work per file

No step below may begin before the explicit user approval recorded in Section 14. The downstream editor must re-locate exact line numbers in each file before editing rather than trusting the numbers cited here or in Section 3.

**STEP 1 — `.claude/agents/browser-validator.md` (primary)**

(a) Description/first paragraph: add that a native Tauri/WebView2 desktop app target uses the pinned `tauri-driver` backend, which is approval-gated like Playwright.

(b) Backend-selection logic: write the mandatory, fail-closed target-type branch from Section 5.1, including the `target_surface` mandatory field, `target_surface_invalid`, and `target_surface_mismatch`.

(c) tauri-driver authorization/setup gate: write Section 5.2 verbatim in substance, including the exact pinned command `cargo install tauri-driver --version 2.0.6`.

(d) Mandatory target-bound identity safeguard: write Section 5.3 verbatim in substance into the agent's own contract, independent of any job packet, including the `expected_app_identity` field and the `tauri_session_unverified` fail-closed path.

(e) Fresh-run process lifecycle: write Section 5.4 into the validation procedure.

(f) Bash authorization prose: write Section 5.5.

(g) Browser UI invariant preservation: write Section 5.6.

(h) `BROWSER_PASS.backend` enum: add `pinned-tauri-driver-2.0.6` (line 33 area). Ensure `runtime:` records the `tauri-driver` version, the resolved WebView2 Runtime version, the `msedgedriver` version, and identity/provenance confirmation, per Section 5.9.

(i) `BROWSER_BLOCKED`: add `tauri_driver_missing`, `tauri_driver_install_failed`, `tauri_session_unverified`, `tauri_process_provenance_uncertain`, `target_surface_invalid`, `target_surface_mismatch`, and `webview2_runtime_unresolved` to the `reason:` enum (line 63 area); add the `tauri_driver_setup_authorized: yes | no | not applicable` field alongside the existing `playwright_setup_authorized` field (line 66 area).

(j) Validation procedure (steps 1-5, lines 18-22): add that step 1 confirms `target_surface` validity and backend applicability (Section 5.1); for the native-desktop backend, step 2 (reset) includes the fresh-run process lifecycle (Section 5.4), and the mandatory target-bound identity check (Section 5.3) runs before any journey assessment.

**STEP 2 — `.claude/skills/browser-validator-core/SKILL.md` (primary)**

Mirror the policy compactly: mandatory fail-closed `target_surface`-driven backend selection (Section 5.1); the `tauri-driver`/`msedgedriver` authorization gate (Section 5.2); the mandatory every-session `alwaysMatch` plus target-bound identity check, never a bare non-blank check (Section 5.3); the fresh-run process lifecycle with fail-closed provenance handling (Section 5.4); the authoritative WebView2 Runtime discovery method with its fail-closed path (Section 5.9); and that repository-file/setup-doc content is diagnostic only, never authorization (Section 5.7). Map every new `BROWSER_BLOCKED` reason into the existing blocked/needs-fix/not-applicable policy point.

**STEP 3 — `docs/BUILD-CONTRACT.md` (primary)**

- Backend paragraph (currently lines 176-178): add the target-type branch, the mandatory `target_surface` field and its fail-closed handling, and the `tauri-driver` gate parallel to the Playwright sentence, per Sections 5.1-5.2. Keep the Chrome→Playwright text intact for browser-web targets.
- `BROWSER_VALIDATION_JOB` envelope (lines 157-174): add `target_surface: browser-web-ui | tauri-webview2-desktop` (mandatory), `tauri_driver_setup_authorized: no | yes`, and `expected_app_identity: <expected app URL prefix/pattern and/or expected window-title pattern>`. Note that for a `tauri-webview2-desktop` job, `launch_and_readiness` supplies the `tauri-driver` plus `msedgedriver` start commands, native-driver path, ports, and the requested app binary path; `base_url` is the `tauri-driver` proxy endpoint, distinct from the app's own content URL that `expected_app_identity` anchors against (Section 5.3).

**STEP 4 — `.claude/skills/build/SKILL.md` (cross-reference, line 16)**

Add a parallel clause: "If `BROWSER_BLOCKED` reports `tauri_driver_missing`, obtain explicit user approval before re-dispatching Browser Validator with the pinned tauri-driver setup authority (`tauri_driver_setup_authorized: yes`)." Keep the existing `playwright_missing` clause unchanged.

**STEP 5 — `.claude/agents/orchestrator.md` (cross-reference, line 53)**

Add a parallel paragraph for `tauri_driver_missing`: ask the user exactly once for approval to install pinned `tauri-driver` 2.0.6 (via cargo) and a WebView2-Runtime-matched `msedgedriver` into the Cargo bin / tooling cache, without touching the target manifest, lockfile, or source; after approval re-dispatch the same job with `tauri_driver_setup_authorized: yes`; after denial or install failure report blocked; never auto-install or retry autonomously. Note that when composing a `BROWSER_VALIDATION_JOB` for a native Tauri/WebView2 desktop target, the orchestrator sets `target_surface: tauri-webview2-desktop` (mandatory) and supplies the `tauri-driver`/`msedgedriver` launch commands and `expected_app_identity`.

**STEP 6 — `docs/ARCHITECTURE-C4.md`**

At lines 106-107, add a third edge (or a clearly distinct branch note) showing the native-desktop path selecting `tauri-driver`, worded so it is not read as a third rung of the same Chrome→Playwright fallback ladder. At lines 115-117 ("Browser fallback" section), add a parallel paragraph: for a native Tauri/WebView2 desktop target, `browser-validator` uses the pinned `tauri-driver` backend instead of Chrome/Playwright; when it or a matching `msedgedriver` is absent, `BROWSER_BLOCKED tauri_driver_missing` triggers one orchestrator-owned approval prompt before the pinned `cargo install tauri-driver --version 2.0.6` setup, writing only to the Cargo bin / tooling cache.

**STEP 7 — `docs/PROMPTING-AND-EVALUATION.md`**

At line 47 (item 7, "Browser validator"), append: a native Tauri/WebView2 desktop target uses the approval-gated pinned `tauri-driver` backend instead of Chrome/Playwright; a missing `tauri-driver` (or matching `msedgedriver`) prompts the user once before the pinned `tauri-driver` setup; the mandatory target-bound session-identity check is diagnostic-independent contract-level policy.

**STEP 8 — `docs/COMPLETION-AUDIT.md`**

At line 17 ("Browser fallback recovery" row), extend the row or add a parallel row: a missing native-desktop backend returns `BROWSER_BLOCKED tauri_driver_missing`; the orchestrator requests explicit approval before Browser Validator installs pinned `tauri-driver` 2.0.6 and a WebView2-Runtime-matched `msedgedriver` into Cargo bin / tooling cache, then resumes the same validation job.

**STEP 9 — `docs/KNOWN-UNKNOWNS.md`**

At line 19 ("Browser Validator" row), add: the `tauri-driver`/`msedgedriver` setup-approval decision for native-desktop targets, and the host WebView2 Runtime version resolution (Section 5.9) including its fail-closed `webview2_runtime_unresolved` path, as known decision points alongside the existing Chrome/Playwright-related unknowns.

**STEP 10 — `docs/PLAN-CONTRACT.md`**

At line 127 (native smoke test 7), append an acknowledgment that a native Tauri/WebView2 desktop target selects the `tauri-driver` backend as one backend per target type (Section 5.1), not an added fallback rung of the existing Chrome-first/Playwright-fallback path, which remains stated for browser-web targets.

**STEP 11 — `tests/validate.ps1`**

Preserve every existing assertion at and around lines 497-504 unchanged, in particular `playwright_setup_authorized` and the exact substring `playwright@1\.61\.0 install chromium`. Add assertions (in the same `if ($browserValidator -notmatch '...') { throw '...' }` style used by the surrounding lines) confirming the browser-validator agent and/or its skill and `docs/BUILD-CONTRACT.md` define: `pinned-tauri-driver-2.0.6`, `tauri_driver_setup_authorized`, the exact substring `cargo install tauri-driver --version 2.0.6`, the `alwaysMatch` requirement, `tauri_session_unverified`, and `target_surface`.

**STEP 12 — `tests/browser-validator-evaluation-cases.json`**

Preserve all nine existing entries in the confirmed `{name, expected_verdict, required_evidence}` shape, unchanged. Add ten new entries:

- (a) a native Tauri target with a properly specified job recognizes `tauri-driver` as the applicable backend and reaches `BROWSER_PASS` with `backend: pinned-tauri-driver-2.0.6`;
- (b) `tauri-driver` absent without authorization → `BROWSER_BLOCKED`, `reason: tauri_driver_missing`, `tauri_driver_setup_authorized: no`;
- (c) authorized setup resumes → `BROWSER_PASS`, with `runtime` recording the tauri-driver, WebView2 Runtime, and msedgedriver versions;
- (d) declined approval remains blocked (no auto-install);
- (e) `tauri-driver` install/setup failure remains blocked (`tauri_driver_install_failed`, no auto-retry);
- (f) a masked/unrelated or blank window (`firstMatch` used, or a blank title or `data:` URL, or window identity not positively matched to the requested app) → `BROWSER_BLOCKED tauri_session_unverified` (fail closed, never a pass);
- (g) missing or malformed `target_surface` → `BROWSER_BLOCKED target_surface_invalid`;
- (h) `target_surface` contradicts the launch commands → `BROWSER_BLOCKED target_surface_mismatch`;
- (i) a stale/orphaned process or uncertain PID/port provenance → `BROWSER_BLOCKED tauri_process_provenance_uncertain`;
- (j) the WebView2 Runtime version cannot be authoritatively resolved, or no matching driver exists → `BROWSER_BLOCKED webview2_runtime_unresolved`.

## 7. Interfaces and data — exact contract-text changes

The following enum values, field names, and command strings must appear identically across all twelve edited files. This is the single authoritative list; the downstream editor must not invent alternate spellings.

- **`BROWSER_PASS.backend` enum**, new value: `pinned-tauri-driver-2.0.6`. Full enum: `claude-in-chrome | existing-playwright | pinned-playwright-1.61.0 | pinned-tauri-driver-2.0.6`.
- **`BROWSER_PASS.runtime`**, for the `tauri-driver` backend: records the pinned `tauri-driver` version (`2.0.6`), the resolved WebView2 Runtime version, the `msedgedriver` version used, and confirmation the driver matches the runtime, plus the identity/provenance confirmation from Sections 5.3-5.4.
- **`BROWSER_BLOCKED.reason` enum**, new values: `tauri_driver_missing`, `tauri_driver_install_failed`, `tauri_session_unverified`, `tauri_process_provenance_uncertain`, `target_surface_invalid`, `target_surface_mismatch`, `webview2_runtime_unresolved`. Full enum: `playwright_missing | playwright_install_failed | tauri_driver_missing | tauri_driver_install_failed | tauri_session_unverified | tauri_process_provenance_uncertain | target_surface_invalid | target_surface_mismatch | webview2_runtime_unresolved | browser_unavailable | missing_prerequisite | unsafe_environment`.
- **`BROWSER_BLOCKED`**, new field: `tauri_driver_setup_authorized: yes | no | not applicable`, alongside the existing `playwright_setup_authorized` field.
- **`BROWSER_VALIDATION_JOB`**, new fields: `target_surface: browser-web-ui | tauri-webview2-desktop` (**mandatory**, never inferred); `tauri_driver_setup_authorized: no | yes`; `expected_app_identity: <expected app URL prefix/pattern and/or expected window-title pattern>` (required for the native-desktop backend, used by the target-bound identity check in Section 5.3). **Specificity floor (second-round correction; mandatory, validator-enforced, not merely job-author guidance)**: `expected_app_identity` must be a genuinely target-specific, non-trivial anchor. `browser-validator` REJECTS, and fails closed to `BROWSER_BLOCKED reason: tauri_session_unverified`, any `expected_app_identity` that is empty or absent; a bare match-everything wildcard (`.*`, `*`, or an equivalent unanchored catch-all expression); a bare scheme-only or host-only pattern with no distinguishing path, port, or other specific segment (for example, just `http://localhost` or `localhost` alone, with nothing further); or a title pattern shorter than 6 meaningful (non-whitespace) characters. **Matching semantics (exact)**: the pattern is evaluated as an anchored substring/prefix match — it must match starting at the beginning of the observed URL (for a URL pattern) or be contained verbatim within the observed title (for a title pattern); a full regular expression is also acceptable if supplied, provided it still satisfies the specificity floor above (a permissive regex such as `.*` or `http://localhost.*` with no further path/port constraint is rejected on the same grounds). For a `tauri-webview2-desktop` job, `launch_and_readiness` supplies the `tauri-driver` plus `msedgedriver` start commands, native-driver path, ports, and the requested app binary path; `base_url` is the `tauri-driver` proxy endpoint (e.g. `http://localhost:9000`), distinct from the app's own content URL that `expected_app_identity` anchors against.
- **Pinned setup command** (copy-pasteable, exact): `cargo install tauri-driver --version 2.0.6`.
- **msedgedriver**: resolved to match the discovered WebView2 Runtime (host-dependent, not a fixed pin — a documented, genuine difference from Playwright's fixed Chromium). Discovery method: primary is the WebView2 loader API `GetAvailableCoreWebView2BrowserVersionString(browserExecutableFolder = null)`; fallback is the WebView2 Runtime's registered version under the EdgeUpdate `Clients` key for GUID `{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}` (value `pv`), with the exact registry path to be confirmed against current Microsoft documentation at edit time. The Edge browser's own version (`msedge.exe` `FileVersion` or `BLBeacon`) must **not** be used as the authoritative source (Section 5.9).
- **Mandatory session capability shape** (exact, must appear verbatim in the contract text): `{"capabilities": {"alwaysMatch": {"tauri:options": {"application": "<app-path>"}}}}`. Never `firstMatch`.
- **Mandatory post-session identity verification** (target-bound, not bare non-blank): a primary process/binary-path anchor plus a secondary content anchor (URL and/or title matching the validated, specificity-floor-passing `expected_app_identity`); failure at either anchor, an `expected_app_identity` that fails the specificity floor above, or absence of the anchors needed for a positive match, produces `BROWSER_BLOCKED tauri_session_unverified`, never a pass. **The primary process anchor is a concrete, deterministic cross-check, not a content inference (second-round correction)**: the agent confirms that the process the WebDriver session/window is bound to has an OS process ID equal to, or a verified child of, the target-app PID recorded during this run's fresh-run process lifecycle (Section 5.4); a session bound to any process other than the run's own recorded target-app PID, or a PID relationship the agent cannot verify, produces the same fail-closed `tauri_session_unverified` result. Identity confirmation is corroborated by this process-provenance data from J-03's remediation, never by content-pattern matching alone.
- **Fresh-run process provenance**: recorded PIDs, command-line/path verification, session binding to this run's own launched process, and scoped cleanup; any uncertainty produces `BROWSER_BLOCKED tauri_process_provenance_uncertain`.
- **Default ports**: proxy 9000, native 9001 (job-overridable).
- **Consistency requirement**: the same enum values, field names, and command/version strings must appear identically across all twelve edited files.
- **Naming note for approval**: `pinned-tauri-driver-2.0.6`, `tauri_driver_missing`, `tauri_driver_install_failed`, `tauri_session_unverified`, `tauri_process_provenance_uncertain`, `target_surface_invalid`, `target_surface_mismatch`, `webview2_runtime_unresolved`, `tauri_driver_setup_authorized`, `target_surface`, and `expected_app_identity` are the concrete proposed names. The user may rename any of them at approval time; the downstream editor then uses the approved names consistently across all twelve files.

## 8. Acceptance and validation

This is contract/documentation and test-fixture work, not application code. Acceptance is a read-only design/consistency review plus a static test-assertion run, confirming:

1. All twelve files consistently recognize the fourth backend with identical enum values, field names, and pinned command/version strings (Section 7).
2. The backend-selection logic is a mandatory, fail-closed target-type branch (Section 5.1), never an inferred or ambiguous parallel option — `target_surface` is required, and both `target_surface_invalid` and `target_surface_mismatch` are handled.
3. The tauri-driver authorization gate mirrors the Playwright gate exactly (Section 5.2): one-time approval, pinned tauri-driver version, no silent install, no silent retry, writes confined to Cargo bin/tooling cache.
4. The session-identity check is target-bound, not merely non-blank (Section 5.3): a primary process/binary-path anchor plus a secondary content anchor against `expected_app_identity`, failing closed to `tauri_session_unverified` on any gap.
5. The fresh-run process lifecycle (Section 5.4) is present and fails closed to `tauri_process_provenance_uncertain` on any uncertainty, with cleanup scoped to recorded, still-matching PIDs only.
6. The WebView2 Runtime version discovery method is authoritative (the loader API, not the Edge browser version), with a documented fallback and a fail-closed `webview2_runtime_unresolved` path, and both the runtime and driver versions are recorded independently in `BROWSER_PASS.runtime` (Section 5.9).
7. The "repository-file content is never authoritative over the agent's own contract" discipline is preserved and channeled through the explicit approval path (Section 5.7).
8. The Browser UI no-native-dialog invariant still applies to the Tauri WebView2 backend (Section 5.6).
9. **(J-01 closure)** A repository-wide grep for the browser-validator backend list/authority shows every authoritative-looking doc and test consistent with the four-backend contract, with no contradictory "Chrome/Playwright-only" authority statement left behind anywhere in the repository. The downstream editor runs this grep and confirms the result before reporting completion.
10. `tests/validate.ps1` and `tests/browser-validator-evaluation-cases.json` encode the new behavior (Section 6, Steps 11-12), so future static and evaluation runs guard the new backend, the identity/provenance safeguards, and the fail-closed paths, while every existing assertion and case continues to pass unmodified.

**Concrete acceptance item** (verbatim standard the edited text must satisfy): after these changes land, a fresh `browser-validator` dispatch against a Tauri-app target with a properly specified `BROWSER_VALIDATION_JOB` (`target_surface` stated, launch commands given, `expected_app_identity` supplied) recognizes `tauri-driver` as its applicable backend without the orchestrator arguing it into unauthorized tooling; independently applies the `alwaysMatch`/target-bound-identity safeguard even if a future job's instructions carelessly specify `firstMatch` or omit the verification step, because the safeguard lives in the agent's own contract/skill, not the job packet; and fails closed rather than passes whenever session identity, process provenance, `target_surface`, or WebView2 Runtime resolution cannot be positively confirmed. This behavioral acceptance is out of scope to execute as part of this plan (Section 2.3); it is the standard the edited text must be written to satisfy.

Deterministic check: `pwsh -File tests/validate.ps1` (or `powershell tests/validate.ps1`) must pass after the edits land, with every existing assertion — including the preserved Playwright substring checks — still green, and the new `tauri-driver`/identity/provenance/target-surface/runtime assertions also green.

## 9. Risks and rollback

- **Risk (medium)**: this changes what an independent validation gate is authorized to autonomously do (install/run new tooling). **Mitigation**: mirror the proven Playwright approval gate exactly — explicit one-time approval, pinned `tauri-driver` version, no silent install, no silent retry after failure, writes confined to Cargo bin/tooling cache (never target deps/locks/source).
- **Risk**: a masked failure (a nominally successful but wrong or blank window) could produce a false pass. **Mitigation (strengthened in Revision 2 per J-02/J-03)**: the false-`BROWSER_PASS` masked-window risk is now mitigated by target-bound identity (process/binary anchor plus content anchor against `expected_app_identity`) plus fresh-run process provenance, both of which fail closed — not merely a non-blank title/URL check.
- **Risk**: `msedgedriver`/WebView2 Runtime version mismatch. **Mitigation (strengthened in Revision 2 per J-05)**: authoritative WebView2 Runtime discovery via the loader API (not the Edge browser version), with a fail-closed `webview2_runtime_unresolved` path when resolution or a matching driver is not achievable, and both versions recorded independently in the receipt.
- **Risk**: an orphaned or stale process on the default ports could be attached to instead of a fresh launch. **Mitigation (new in Revision 2 per J-03)**: the fresh-run process lifecycle (Section 5.4) never attaches to an unrecorded occupant and fails closed on any provenance uncertainty.
- **Risk**: ambiguity about which backend applies to a given job. **Mitigation (strengthened in Revision 2 per J-04)**: `target_surface` is mandatory, never inferred; missing/invalid values and launch-command contradictions both fail closed rather than silently selecting a backend.
- **Risk (broadened in Revision 2 per J-01)**: the edit surface is now twelve files instead of five, increasing the chance of contract drift across surfaces. **Mitigation**: a single authoritative enum/field/command identifier list (Section 7) applied identically across all twelve files, plus the mandatory J-01 consistency grep as a closing acceptance gate (Section 8, item 9).
- **Rollback/containment**: every edit in this plan is markdown or JSON governance/test content under Git. Reverting the resulting diff/commit fully restores the prior contract. Until edits land, `browser-validator` correctly refuses unauthorized `tauri-driver` use (status quo is safe) — there is no interim risk. No irreversible or destructive operation is involved.
- **Stale-plan trigger**: if the `browser-validator` agent definition, the `BUILD-CONTRACT.md` backend paragraph, its `tools:` line, any of the other ten files' cited text, or the verified `tauri-driver`/`msedgedriver`/WebView2 mechanism materially changes before edits are applied, this plan is stale and requires replanning or explicit reapproval.

## 10. Assumptions and decisions requiring user confirmation at approval

- **ASSUMPTION for user confirmation**: the existing Playwright approval-gate pattern (ask once, pin a version, no silent retry, writes confined to a user-level cache) is the correct template to mirror for the `tauri-driver` setup gate.
- **DECISION for user to confirm or override**: pin `tauri-driver` to exactly `2.0.6` (recommended, matches Playwright precedent); resolve `msedgedriver` to match the discovered WebView2 Runtime rather than fixed-pinning it, using the loader API as the authoritative method rather than the Edge browser's own version (a documented, genuine correction from Revision 1, per J-05).
- **DECISION (recommended values, user may rename)**: backend enum `pinned-tauri-driver-2.0.6`; blocked reasons `tauri_driver_missing` / `tauri_driver_install_failed` / `tauri_session_unverified` / `tauri_process_provenance_uncertain` / `target_surface_invalid` / `target_surface_mismatch` / `webview2_runtime_unresolved`; job fields `target_surface`, `tauri_driver_setup_authorized`, and `expected_app_identity`.
- **CLASSIFICATION DECISION for user to confirm**: although this effort was originally framed as engineering (harness/governance) work, every deliverable in this plan is non-code governance/contract markdown and test-fixture content (agent definitions, skills, project contract documents, and static test assertions/cases). Per the project rule "do not route non-code writing to T1," the downstream editor after approval is Scribe, not the engineering fleet. Acceptance is a read-only review plus a static test run, consistent with a document route rather than an engineering route.
- **SCOPE-EXPANSION DECISION for user to confirm**: this revision expands the edit surface from five files (Revision 1) to twelve files, per judge finding J-01. The user should confirm this broadened surface is acceptable; Section 2.2 lists every file confirmed not to need an edit, with its reason, so the user can verify the boundary was not overreached.
- The general authorization is project-agnostic (available to any future Tauri/native-desktop validation job across any project); the photo-genie artifacts are cited only as verified reference evidence, and their paths are not hardcoded into the general contract text.
- **OPTIONAL item, not in required scope**: `docs/ARCHITECTURE-ADAPTATION.md`'s one-line broadening (Section 2.2) remains for the user to accept or decline; it is not edited unless separately approved.
- **Unresolved-at-planning-time item flagged for edit time**: the exact EdgeUpdate registry path and client GUID for the WebView2 Runtime fallback discovery method (Section 5.9) should be reconfirmed against current Microsoft WebView2 documentation by the downstream editor before it is written into the contract as fact; the primary loader-API method does not depend on this being exactly right.
- No file is edited until the user explicitly approves this plan. This plan carries no commit authority.

## 11. Judge route

`PLAN_DUCK` was run against Revision 1 in shadow/advisory mode (Luna, medium risk); its five findings (J-01 through J-05) are disposed of in Section 4 and incorporated as binding text requirements in Section 5. Per `docs/PLAN-CONTRACT.md`, this constitutes Planner's single authorized resume; a further `PLAN_DUCK` pass on this revision remains eligible, orchestrator-owned, and advisory unless evidence-backed blocking. No `CODE_REVIEW`, `VERIFICATION_CHALLENGE`, or `VISUAL_REVIEW` checkpoint applies — there is no code and no runtime UI. Call cap: standard (at most two).

## 12. Browser UI dialog policy and browser validation

Not applicable. This plan modifies the validator's own contract, not a browser-rendered product UI. The no-native-dialog invariant nonetheless continues to apply to any Tauri WebView2 UI validated via the new backend once dispatched (Section 5.6).

## 13. Engineering mode and downstream owner

`engineering_mode: standard`. `team_authorization: not applicable`.

**Downstream owner: `scribe`**, not the engineering fleet. Every deliverable in this plan's scope (Section 2.1) is non-code governance/contract markdown or static test-fixture content: agent definitions, skills, project contract documents, and JSON/PowerShell test assertions with no application logic. The project rule "do not route non-code writing to T1" applies directly. Acceptance and validation (Section 8) is a read-only consistency review plus a static test run, not a build/test gate over application behavior, which is consistent with a document route rather than an engineering route. This is unchanged from Revision 1's classification decision (Section 10).

After explicit user approval, Scribe edits the twelve files in Section 2.1 in the order given in Section 6, runs the J-01 consistency grep and `tests/validate.ps1` (Section 8), then updates this plan's Section 14 approval record and status per the standing plan-persistence rule.

## 14. Approval record

**Status: APPROVED for execution.**

**Date**: 2026-07-18

**Approved by**: the project user, via explicit interactive approval relayed by the orchestrator.

**Scope of approval**: Revision 2 of this plan is approved as-is, including the second-round `J-02-WRONG-WINDOW` correction recorded in Section 4. This approval covers, without modification:

- the 12-file dispositioned edit surface (Section 2.1, Section 6);
- the Playwright-mirrored approval-gate pattern for `tauri-driver` setup (Section 5.2);
- pinned `tauri-driver` version `2.0.6` and the exact install command `cargo install tauri-driver --version 2.0.6` (Section 5.8);
- host-resolved `msedgedriver` matched to the authoritative WebView2 Runtime version via the WebView2 loader API, explicitly not the Edge browser version (Section 5.9);
- the mandatory `alwaysMatch` session capability requirement, never `firstMatch` (Section 5.3);
- the strengthened post-session identity verification, comprising the `expected_app_identity` specificity floor and the PID/process cross-check against this run's fresh-run process-provenance record (Section 5.3, second-round correction);
- the fresh-run process-provenance lifecycle with fail-closed handling on any uncertainty (Section 5.4);
- the classification of this work as Scribe-owned non-code governance/configuration markdown and test-fixture content, not engineering-fleet work (Section 13).

**Execution**: this approval authorizes dispatch to Scribe next, to implement the described edits across all twelve dispositioned files exactly as specified in Section 6, in the order given, followed by the J-01 consistency grep and `tests/validate.ps1` per Section 8.

No other section, decision, or judge-disposition entry in this plan is amended by this approval record. This plan may not be used to authorize any file edit beyond the twelve files and steps in Section 2.1 and Section 6.
