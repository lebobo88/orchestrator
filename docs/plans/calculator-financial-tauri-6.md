---
title: "calculator-financial-tauri-6: Rust-only Tauri 2.x Antikythera-themed financial calculator"
slug: calculator-financial-tauri-6
plan_id: calculator-financial-tauri-6
status: Approved
route: engineering
created: 2026-07-14
updated: 2026-07-14
downstream_owner: t1-engineer (only after explicit user approval of this plan)
---

# calculator-financial-tauri-6: implementation plan

## Approval

- **Status:** Approved
- **Approved by:** rob.hasselbach@gmail.com (user, via orchestrator session)
- **Date:** 2026-07-14
- **Scope approved:** the full plan as written, as-is, with no changes requested. Proceeding to a T1 `ENGINEERING_JOB` per the template below.
- **Carried-forward user acknowledgement:** the optional Finnhub/GNews upgrades are US-only/non-commercial and require a key; the app defaults to keyless Frankfurter (FX) and GDELT (news) and needs no key to run or validate.

## Status

**Approved.** This plan was explicitly approved by the user as-is, with no changes requested, on 2026-07-14. T1 may now begin implementation per the `ENGINEERING_JOB` template below. If a material repository, requirement, dependency, or vendor-terms change occurs before implementation starts, this plan becomes stale and must be reapproved or replanned before T1 proceeds.

## Outcome and audience

This plan is execution-ready for a later T1 `ENGINEERING_JOB` to build a working Rust + Tauri 2.x desktop financial calculator, buildable, runnable, and launchable locally on Windows. The finished app has an Antikythera-mechanism-themed webview UI (concentric rings, dials, radial pointers, gear ornament; bronze/verdigris palette), dual basic/financial calculator modes toggled within one UI, permanent SQLite calculation history, a JSONL append-only event stream, and free, no-paid-key external market/FX and news data with an offline/no-key fallback.

Audience: the orchestrator (to present for user approval) and T1 (to implement after approval). The plan ends with concrete build/run/test instructions and a required browser/webview UI validation acceptance gate.

## Scope and non-goals

### In scope

1. A new folder `calculator-financial-tauri-6` at the repository root, created fresh.
2. A Rust-only backend (no Python, no sidecar) owning the calculation engine, persistence, event streaming, and external polling, on Tauri 2.x latest stable. Frontend framework is engineering's choice (lightweight, supports custom SVG/canvas well, simple local build).
3. An Antikythera-machine visual design language (concentric rings, dials, radial pointers, gear ornament; bronze/verdigris).
4. Dual "basic" (standard arithmetic) and "financial" (13 v1 formulas) modes toggled within one UI.
5. Permanent SQLite calculation history plus a JSONL append-only event stream.
6. Free, no-paid-key external market/FX and news data sources with graceful offline/no-key fallback.
7. Automated tests, concrete Windows build/run instructions, and a required browser/webview UI validation gate.

### Non-goals

- Reusing, copying, reading as authoritative, or modifying `calculator-financial-tauri-3`, `calculator-financial-tauri-5`, `docs/plans/calculator-financial-tauri-5.md`, or `docs/research/calculator-financial-tauri-3-formulas-and-architecture.md`. Those are prior unrelated attempts and remain untouched.
- Python or any sidecar-embedded interpreter.
- Multi-user or cloud sync.
- Commercial distribution.
- Paid API tiers.
- Committing, pushing, opening a pull request, or deploying without explicit user request.
- Changing the recommended formula math.
- Re-researching questions already settled by the research evidence cited below.

This plan is a draft recommendation and grants no authority on its own. T1 starts only after the user explicitly approves it.

## Evidence references

- Direct `RESEARCH_EVIDENCE` packet consumed by Planner from nested Researcher (2026-07-14; deep; architecture + comparison + browser-UI overlay). No separate research document was persisted; findings are embedded below by reference to that packet.
- Reference-only prior build (do not reuse, copy, read as authoritative, or modify): `H:\CommandCenter\orchestrator\calculator-financial-tauri-3` — a proven, buildable Rust-only Tauri 2.x module shape and dependency set. `calculator-financial-tauri-6` draws architectural lessons only (module shape, dependency choices, theme vocabulary) from this build; all code is written fresh in its own folder.

## Repository findings

- Repository root: `H:\CommandCenter\orchestrator`. Plans persist at `docs/plans/<slug>.md`; Scribe is the sole plan author; approval follows `docs/PLAN-CONTRACT.md` and `docs/plans/README.md`.
- `calculator-financial-tauri-3` (reference only) demonstrated: `Cargo.toml` with `tauri` v2, `rusqlite` (bundled) and/or `sqlx` sqlite, `rust_decimal`, `reqwest`, `tokio` (full), `uuid`, `chrono`, `tracing`, `thiserror`; release profile `lto` + `codegen-units = 1`; source layout `main.rs`, `models.rs`, `commands.rs`, `calculators/{mod,basic,financial}.rs`, `persistence/{mod,event_log}.rs`, `market_data.rs`; `tauri.conf.json` with `devUrl` `http://localhost:5173`, `frontendDist` `../frontend/dist`, a roughly 1400x900 window.
- `calculator-financial-tauri-5` and its plan document (`docs/plans/calculator-financial-tauri-5.md`) and the `-3` formulas/architecture research document are prior unrelated attempts; this plan does not reuse, copy, or read them as authoritative, and does not modify them.

## Architecture decisions (from research evidence)

### Antikythera UI translation (primary new design work)

The historical mechanism's front dial is a set of concentric graduated rings (zodiac and calendar) with radial pointers; the back carries spiral dials (Metonic/Saros cycles). This plan translates that vocabulary into an accessible, functional calculator skin, not a rotate-to-type replica:

- The **primary numeric readout** is a large, high-contrast standard-numeral display meeting WCAG 1.4.3 (contrast ratio ≥ 4.5:1). Dials and rings are reserved for bounded parameters and mode selection only.
- **Mode selector**: an outer ring rendered as an ARIA `tablist` or `radiogroup` (basic vs. financial), with arrow-key rotation, roving `tabindex`, and `aria-selected`/`aria-checked`.
- **Parameter dials** (rate, term, compounding frequency, and similar bounded numeric inputs): an SVG knob with `role="slider"`, `tabindex="0"`, `aria-valuemin`/`aria-valuemax`/`aria-valuenow`, `aria-valuetext`; Arrow keys step, Home/End jump to min/max, Page Up/Down step coarsely.
- **Pointer readouts** (quote, FX, result): a radial pointer backed by `aria-live="polite"` for programmatic announcement.
- **Gears, verdigris texture, and pointer sweep animation**: decorative, marked `aria-hidden`. All continuous animation is gated behind `prefers-reduced-motion` with a static fallback, and/or an in-app motion toggle.
- **Every dial is paired with a standard numeric `<input>`** so keyboard and assistive-technology users are never required to operate the dial directly.
- Verdigris/bronze color choices must be checked for contrast; numerals must remain legible on the themed panel.

### v1 formula set (13 formulas, deterministic, `rust_decimal`)

Each formula ships with a known-value acceptance test. `rust_decimal::powi`/`powu` are exact for integer-exponent cases; `powd` is an approximation used only where noted (acceptable for v1).

| # | Formula | Inputs | Expected result |
|---|---|---|---|
| 1 | Simple interest | P=1000, r=0.05, t=3 | interest 150.00, total 1150.00 |
| 2 | Compound interest / future value (annual, `powi`) | P=1000, r=0.05, n=10 | FV 1628.89 |
| 3 | Present value | FV=10000, r=0.08, n=5 | PV 6805.83 |
| 4 | Loan payment (PMT) | P=200000, r_monthly=0.005, n=360 | PMT 1199.10 |
| 5 | Amortization, first row (from #4) | — | interest 1000.00, principal 199.10, balance 199800.90 |
| 6 | ROI | cost=1000, proceeds=1300 | 30.00% |
| 7 | CAGR (fractional exponent, `powd` approximation) | begin=100, end=200, n=5 | 14.87% (test against reference value; assert within tolerance) |
| 8 | Effective annual rate / APY | nominal=12%, monthly compounding | 12.6825% |
| 9 | NPV | rate=10%, flows=[-1000,500,500,500] | 243.43 |
| 10 | IRR (bounded bisection/Newton) | flows=[-1000,500,500,500] | ~23.38% (assert convergence within a stated tolerance) |
| 11 | Break-even units | fixed=10000, price=50, varcost=30 | 500 units |
| 12 | Savings goal / sinking-fund PMT | FV=10000, r_monthly=0.005, n=60 | 143.33 |
| 13 | Currency conversion via live FX | 100 USD, fixture rate 0.92 EUR/USD | 92.00 EUR (use a fixed fixture rate for deterministic tests) |

**Backlog, documented and explicitly deferred from v1** (T1 does not implement these unless separately approved): bond pricing and YTM (iterative solver), XIRR (date-based solver), Black-Scholes/options pricing (needs a normal CDF implementation), straight-line and declining-balance depreciation, WACC, payback period, portfolio return/volatility/Sharpe ratio (time-series inputs), and an annuity-due toggle (planned as a later modifier on formulas #4/#12).

### JSONL streaming architecture (Rust-only, confirmed)

Streaming has real value here: live poll updates reach the UI without blocking, the JSONL append-only stream is a replayable audit/undo trail, and it decouples the Rust producer from the webview consumer.

- JSONL append-only log is the source-of-truth event trail. SQLite (WAL mode, single writer) is a queryable projection/index over it. Startup reconciliation replays/compacts the JSONL tail into SQLite.
- Calculation-history and event tables are permanent. Market/news cache tables are TTL-bound with eviction.
- Tauri 2.x IPC: async `#[tauri::command]` functions (Tauri owns the Tokio runtime); `tokio::sync::Mutex` held across `.await` points as needed; a background poll task spawned in `setup()` communicates over `tokio::mpsc`; each event is pushed to the webview via `AppHandle::emit()`, with one JSON object per JSONL line. No sidecar process of any kind.

### Free external data sources (keyless-first, reverified 2026)

- **Primary market/FX**: Frankfurter (`api.frankfurter.dev`) — no key, no quota, ECB end-of-day rates, historical data back to 1999, JSON. Chosen specifically so the app demos and browser-validates with zero secrets required.
- **Primary news**: GDELT DOC 2.0 API — no key, free, roughly a 3-month rolling global news search window, JSON.
- **Optional key-enabled upgrades**, behind a provider-swap trait, enabled only if the user supplies a key: Finnhub (US-only, non-commercial free tier, 60 calls/minute, no card required) for real-time-ish US quotes; GNews.io (100 requests/day, key required, non-commercial) for curated headlines.
- **Required offline/no-key fallback**: a bundled cached/sample fixture (last-known FX rates plus sample news JSON) served when offline or unconfigured, so the UI fully renders and validation proceeds with no network access and no secret.
- Alpha Vantage was evaluated and is not recommended, on ambiguous commercial-use Terms of Service grounds.
- All tiers permit single-user, local, non-commercial use. Vendor terms and limits are volatile; T1 must reconfirm them at implementation time, not rely solely on this plan's snapshot.

## Ordered work

Each step names its observable result and dependency. All steps execute only after explicit user approval of this plan.

1. **Architecture / Decision Record.** At the start of implementation, record a decision document (in the `calculator-financial-tauri-6` folder or under `docs/`) capturing: Rust-only Tauri 2.x, no sidecar; the JSONL event schema (money encoded as strings); the SQLite schema (permanent history, TTL-bound market/news); the JSONL single-writer/WAL/startup-reconciliation design; and the Antikythera UI design system (palette, ring/dial/pointer/gear components, dual-mode layout, accessibility contract). *Observable result:* a written decision record. *Dependency:* none.

2. **Scaffold and Rust/Tauri backend.** Create `calculator-financial-tauri-6` with `Cargo.toml` (`tauri` v2, `rusqlite` bundled or `sqlx` sqlite, `rust_decimal`, `reqwest`, `tokio` full, `uuid`, `chrono`, `tracing`, `thiserror`; release profile `lto` + `codegen-units = 1`), `tauri.conf.json` (own app identifier, `devUrl`/`frontendDist`, roughly 1400x900 window), `main.rs` with `Builder::setup()` spawning the tokio poll and rx/persist/emit loop, async commands for calc/mode/history/config, and module layout `models.rs`, `commands.rs`, `calculators/{mod,basic,financial}.rs`, `persistence/{mod,event_log}.rs`, `providers/{mod,frankfurter,gdelt,finnhub,gnews}.rs`. *Observable result:* `cargo check`/`cargo build` compiles; the emit loop is wired. *Dependency:* step 1.

3. **Basic-mode calc engine.** Numeric keypad operations (+, -, *, /, %, decimal), clear/all-clear, memory (M+/M-/MR/MC), parentheses, sign toggle, standard order-of-operations evaluation, `rust_decimal`, money encoded as strings. *Observable result:* unit tests for arithmetic correctness and order of operations pass. *Dependency:* step 2.

4. **Financial-mode calc engine.** The 13 v1 formulas on `rust_decimal` with the known-value acceptance tests above (assert #5's amortization split, #7's fractional-exponent precision against 14.87%, and #10's IRR convergence tolerance). *Observable result:* all 13 tests pass. *Dependency:* step 2 (shares the Decimal core with step 3).

5. **SQLite and JSONL streaming wiring.** Rust, as the single writer, appends each calculation event to the JSONL log and inserts it into the permanent `calculation_history` table, and emits events so history/results update live. Startup reconciliation between the JSONL log and SQLite. *Observable result:* history persists across app restart; JSONL events are observable on disk and in the UI stream. *Dependency:* steps 2, 3, 4.

6. **Frontend Antikythera UI (dual mode, accessible).** A webview implementing the bronze/verdigris design system (concentric mode ring, parameter dials, radial pointer readouts, gear ornament), a basic/financial toggle within one UI, dynamic financial input forms with paired numeric inputs, a results panel, a browsable history panel, and market/FX and news panels. All acknowledgement/confirmation surfaces are app-owned accessible modals (`role="dialog"`, `aria-modal`, focus trap, Escape and Cancel handling, restored focus); inline validation for inputs; every dial pairs `role="slider"` with a numeric input; all animation gates behind `prefers-reduced-motion` and a motion toggle; decorative gear/pointer elements are `aria-hidden`. *Observable result:* both modes render and toggle; the theme is visible; the UI is keyboard-operable. *Dependency:* step 2 (command surface).

7. **External data/news integration with fallback.** Rust/`reqwest` clients for Frankfurter (FX, keyless) and GDELT (news, keyless) behind a provider-swap trait; optional Finnhub/GNews clients used only when a key is configured; a background tokio timer poll writing TTL-bound tables and emitting updates; graceful degradation to the bundled offline/no-key fixture when offline or unconfigured, with panels showing a clear "no key / offline / sample data" state, never an error dialog. *Observable result:* keyless real data renders with no secret configured; the offline/no-key fixture renders cleanly. *Dependency:* step 2.

8. **Automated tests.** Rust unit tests for basic arithmetic and the 13 formula reference values; persistence single-writer and startup-reconciliation tests; provider client tests (mocked, for example with `mockito`) including the offline/no-key fallback path; a deterministic no-native-dialog source scan over the frontend asserting zero occurrences of `alert`, `confirm`, `prompt`, `window.alert`/`window.confirm`/`window.prompt`, and `beforeunload`, with captured output. *Observable result:* all tests and the scan pass with captured output. *Dependency:* steps 3, 4, 5, 7.

9. **Build and run instructions.** Concrete Windows steps: install prerequisites (Rust toolchain, Tauri 2.x prerequisites, WebView2, Node if the chosen frontend needs it); the exact readiness command (`npm run tauri dev` or `cargo tauri dev`) with base URL `http://localhost:5173`; and `cargo tauri build` for an installer. Document the SQLite app-data database path and the deterministic reset/fixture procedure. *Observable result:* documented, reproducible commands that actually launch the app. *Dependency:* steps 2–8.

10. **Browser/webview UI validation gate** (required acceptance step, not optional; runs after the verifier passes). Launch the real app and validate the rendered Antikythera UI/UX against design intent and implementation across the journeys and viewports in Browser UI validation below; attach no-native-dialog scan evidence; verify modal keyboard/focus behavior. *Observable result:* a captured validation record (screenshots/notes) confirming a pass. *Dependency:* step 9.

**Sequencing note for the orchestrator:** steps 2–10 are recommended as a single bounded `ENGINEERING_JOB` covering steps 1–9, with step 10 as the separate post-verifier Browser Validator gate. T1 may internally sequence steps 1–9. If T1 reports the job is genuinely too large, the orchestrator may split it at the persistence boundary (steps 1–5) and the UI/data boundary (steps 6–9); such a split is justified only by T1's own size report, not assumed in advance.

## Interfaces and data

- **JSONL event:** one JSON object per line, for example `{event_id, ts, kind, request_id, payload}`. Money/decimal values are encoded as **strings** end-to-end (`Decimal` ↔ string), never as floats.
- **SQLite, permanent:** `calculation_history(id UUID TEXT, ts ISO-8601, mode 'basic'|'financial', calculator/op/formula name TEXT, inputs JSON, outputs JSON)`; an event-log projection table if the implementation uses one.
- **SQLite, TTL-bound:** `fx_rates`/`market_data(id, ts, base, quote/ticker, rate/price as string, ttl_expires)`; `news(id, ts, title, description, url, source, ttl_expires)`.
- **Persistence:** WAL mode, single Rust writer; JSONL append-only audit log alongside SQLite with startup reconciliation. Rust is the sole writer and the sole `emit()` source to the webview.
- **Tauri configuration:** `devUrl` `http://localhost:5173`; `frontendDist` `../frontend/dist`; own app identifier; async commands for calc, mode toggle, history query, and API-key/config. No shell/sidecar capability is needed, since the backend is Rust-only.
- **External providers:** behind a provider-swap trait; keyless Frankfurter and GDELT by default; optional Finnhub/GNews clients used only when a key is present; cached data is TTL-bound and revocable.

## Acceptance and validation

The final implementation must satisfy all of the following, with TDD-first evidence (tests written before or alongside the code they verify):

- **Basic arithmetic correctness**: unit tests covering order of operations, memory, parentheses, sign toggle, and percent.
- **Financial formula correctness**: all 13 known-value tests pass, including the amortization split (#5), the CAGR fractional-exponent precision check (#7), and IRR convergence within a stated tolerance (#10).
- **SQLite persistence correctness**: calculation history survives an app restart.
- **JSONL streaming**: events are observable on disk and/or in the UI event stream; startup reconciliation between JSONL and SQLite is verified.
- **External API integration with offline fallback**: keyless Frankfurter and GDELT render real data with no secret configured; the offline/no-key fixture renders cleanly when offline or unconfigured.
- **Antikythera UI usability/accessibility**: numerals readable at ≥ 4.5:1 contrast; dials operable via keyboard (`role="slider"`, Arrow/Home/End/Page Up/Down); the mode ring is arrow-navigable; every dial is paired with a numeric input; `prefers-reduced-motion` disables animation.
- **Browser UI invariant**: zero native dialogs, proven by a deterministic source scan with captured output; all acknowledgement/confirmation surfaces are app-owned accessible modals (`role="dialog"`, `aria-modal`, focus trap, Escape/Cancel, restored focus) with verified keyboard/focus behavior.

T1 must return changed files, exact verification commands, their results, and any remaining limitation.

## Risks and rollback

| Risk | Mitigation |
|---|---|
| Overall risk to the rest of the repository | Low. All work is confined to a new folder; no other repository paths change except this plan document. |
| Build/toolchain risk (Rust + Tauri 2.x toolchain availability, WebView2 runtime presence, sqlite driver building on Windows, Node availability if the chosen frontend needs it) | Step 9 documents prerequisite checks; verify `cargo check`/`cargo build` early in step 2. |
| Money precision loss | Encode all decimal/money values as strings end-to-end; assert against reference values in tests. |
| IRR / fractional-exponent numeric edge cases | Bounded solver with a stated convergence tolerance; explicit tests for #7 and #10. |
| Vendor Terms-of-Service or rate-limit volatility (Frankfurter, GDELT, Finnhub, GNews) and non-commercial scope | Default to keyless sources; treat cached data as TTL-bound and revocable; reconfirm terms at implementation time; keep scope to single-user, local, non-commercial use. |
| Native-dialog regression risk in the webview | A deterministic no-native-dialog scan is a required gate; app-owned modals only. |
| Scope creep | Work is confined to the new folder; nothing is committed or pushed without explicit user request. |
| Stale-plan triggers | Any material change to requirements, Tauri/Rust tooling, or vendor terms, or discovery that the new folder already exists with conflicting content, makes this plan stale and requires replanning or explicit reapproval before T1 proceeds. |

## Assumptions and decisions

### Safe assumptions carried into implementation

- Target platform is Windows x86_64.
- Scope is single-user, local, non-commercial, and offline-capable.
- Only free and open tooling is used.
- The backend is Rust-only (no Python), per the task's stated constraint.
- Frontend framework, or plain HTML/CSS/JS, is engineering's choice.

### Decisions still requiring explicit user approval before T1 begins

- Approval of this entire plan.
- Acknowledgement that the optional Finnhub/GNews upgrades are US-only/non-commercial and require a key; the app defaults to keyless Frankfurter and GDELT and needs no key to run or validate.

### Bounded T1 implementation decisions (not requiring separate user approval)

- Frontend framework, or plain HTML/CSS/JS.
- Exact SQLite driver (`rusqlite` vs. `sqlx`).
- Provider-trait internals.
- Whether to split into more than one `ENGINEERING_JOB` if the scope is genuinely too large, and only if T1 reports that.

## Browser UI dialog policy

**Required.** The Tauri frontend is a browser-rendered webview, so the project's Browser UI invariant applies in full:

- No native `alert`, `confirm`, or `prompt`, and no `window.alert`, `window.confirm`, or `window.prompt` forms.
- No `beforeunload` prompts.
- All acknowledgement and confirmation surfaces are app-owned accessible modals: `role="dialog"`, `aria-modal="true"`, an accessible name, a focus trap, Escape and Cancel handling, and restored focus on close.
- Inline validation for calculator inputs (`aria-describedby`/`aria-invalid`).
- Keyboard and focus verification of every modal.
- A deterministic no-native-dialog source scan, with captured output, as required test evidence from T1.

## Browser UI validation

- **Launch/readiness command:** `npm run tauri dev` (or `cargo tauri dev`) from `H:\CommandCenter\orchestrator\calculator-financial-tauri-6`; ready when the Tauri window opens and the dev server serves the frontend.
- **Base URL:** `http://localhost:5173` (Tauri `devUrl`; the webview renders this).
- **Fixture/reset procedure:** document the exact SQLite app-data database file path; reset by deleting that database file (and the JSONL log) to return to a clean fixture state, or a documented reset command/environment variable. The offline/no-key data fixture (sample FX rates plus sample news JSON) must render deterministically with the network disabled and no API key set, for repeatable validation.
- **User journeys (all must be validated):**
  (a) basic-calc happy path — a multi-operation expression with order of operations plus memory;
  (b) mode switch basic ↔ financial via the ring selector;
  (c) at least two financial formulas end-to-end (for example Loan PMT #4 and NPV #9, or CAGR #7) entered via dials plus paired inputs, with the correct result shown;
  (d) history view and persistence after restart (compute a result, restart the app, confirm history is still present);
  (e) an error/edge case that triggers the app-owned accessible modal (for example divide-by-zero or an invalid financial input) — a modal, not a native dialog;
  (f) an offline/no-API-key fallback path (network disabled or no key configured) — panels show a clear sample/offline state, no error dialog.
- **Viewport profiles:** at least a default desktop viewport of roughly 1400x900, and one narrower/smaller window to confirm the Antikythera layout and readable numerals hold.
- **Visible expected outcomes per journey:** correct computed values in the readout; a visible mode change on the ring; both financial results matching known values; history rows persisting across restart; the accessible modal appearing, trapping focus, and returning focus on close for the error case; offline/no-key panels showing a clear sample/offline state with no native dialog and no crash.

## Downstream owner

`t1-engineer`, only after explicit user approval of this plan. Step 10 (browser/webview UI validation) is owned by `browser-validator`, after the verifier passes.

## ENGINEERING_JOB template (for the orchestrator to hand to T1 after approval)

```text
ENGINEERING_JOB
target: H:\CommandCenter\orchestrator\calculator-financial-tauri-6 (new folder; do not reuse, copy, read as
  authoritative, or modify calculator-financial-tauri-3, calculator-financial-tauri-5,
  docs/plans/calculator-financial-tauri-5.md, or docs/research/calculator-financial-tauri-3-formulas-and-architecture.md)
approved_plan: docs/plans/calculator-financial-tauri-6.md
scope:
  - Rust-only backend (no Python, no sidecar) on Tauri 2.x latest stable: calc engine, persistence, event
    streaming, external polling. Frontend framework is engineering's choice.
  - Antikythera-themed webview UI (concentric rings, dials, radial pointers, gear ornament; bronze/verdigris),
    dual basic/financial mode toggle in one UI, history panel, market/FX panel (Frankfurter, keyless),
    news panel (GDELT, keyless); optional Finnhub/GNews behind a provider-swap trait when a key is configured.
  - Permanent SQLite calculation history + JSONL append-only event stream, WAL, single writer, startup
    reconciliation.
  - Basic-mode arithmetic (keypad ops, memory, parentheses, sign toggle, order of operations) and the 13 v1
    financial formulas listed in the plan's Architecture decisions section, all on rust_decimal, money as strings.
  - Graceful offline/no-key fallback for external providers (bundled sample fixture).
acceptance_criteria:
  - Basic arithmetic correctness: unit tests for order of operations, memory, parentheses, sign, percent.
  - All 13 v1 financial formula known-value tests pass, including amortization split (#5), CAGR fractional-exponent
    precision vs 14.87% (#7), and IRR convergence within a stated tolerance (#10).
  - SQLite calculation history persists across app restart.
  - JSONL streaming events observable on disk and/or in the UI event stream; startup reconciliation verified.
  - Keyless Frankfurter + GDELT render real data with no secret configured; offline/no-key fixture renders cleanly.
  - Antikythera UI usability/accessibility: numerals >=4.5:1 contrast; dials operable via keyboard (role=slider,
    Arrow/Home/End/PageUp-Down); mode ring arrow-navigable; every dial paired with a numeric input;
    prefers-reduced-motion disables animation.
  - Zero native browser dialogs (alert/confirm/prompt/window.*/beforeunload), proven by a deterministic source scan
    with captured output.
  - cargo tauri build produces an installer; the app launches per the documented Windows build/run instructions.
browser_ui_dialog_policy: required — no native alert/confirm/prompt or window.* forms, no beforeunload prompts;
  app-owned accessible modals only (role=dialog, aria-modal, accessible name, focus trap, Escape/Cancel, restored
  focus); inline validation for inputs (aria-describedby/aria-invalid); keyboard/focus verification of every
  modal; deterministic no-native-dialog source scan with captured output required as test evidence.
tdd_first_ordering: write basic-arithmetic and financial-formula reference-value tests before/alongside the calc
  engine; write persistence single-writer and startup-reconciliation tests before/alongside that wiring; write
  provider-client tests (mocked, including offline/no-key fallback) before/alongside the provider integrations;
  write the no-native-dialog scan before/alongside the frontend.
architecture_decisions:
  - Rust-only, no sidecar, no Python; async #[tauri::command] functions; background tokio poll task spawned in
    setup() over tokio::mpsc; each event pushed to the webview via AppHandle::emit(); one JSON object per JSONL line.
  - JSONL event schema: {event_id, ts, kind, request_id, payload}; money as strings end-to-end.
  - SQLite: permanent calculation_history; TTL-bound fx_rates/market_data and news tables; WAL; single writer;
    startup reconciliation between JSONL and SQLite.
  - Keyless-default providers: Frankfurter (FX) and GDELT (news) primary, no key required; Finnhub and GNews
    optional upgrades behind a provider-swap trait, used only when the user supplies a key; bundled offline/no-key
    fixture required for graceful degradation.
required_return: changed files, exact verification commands, their results, and any remaining limitation.
END_ENGINEERING_JOB
```
