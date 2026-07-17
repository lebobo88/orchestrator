---
title: "calculator-financial-tauri-7: Tauri v2 Antikythera-themed financial calculator with SQLite + JSONL + Frankfurter FX"
slug: calculator-financial-tauri-7
plan_id: calculator-financial-tauri-7
status: Draft
route: engineering
created: 2026-07-14
updated: 2026-07-14
downstream_owner: t1-engineer (only after explicit user approval of this plan)
---

# calculator-financial-tauri-7: implementation plan

## Status

**Draft — awaiting explicit user approval before any engineering work begins.** No engineering work may start until the user explicitly approves this plan. If a material repository, requirement, dependency, or vendor-terms change occurs before implementation starts, this plan becomes stale and must be reapproved or replanned before T1 proceeds.

## Outcome and audience

This plan is execution-ready for later T1 `ENGINEERING_JOB`s to build a runnable Rust + Tauri v2 desktop "financial calculator" app in a new folder, `calculator-financial-tauri-7`, with a Basic (handheld) mode and a Financial (advanced-formula) mode, an Antikythera-mechanism visual theme over a genuinely usable/accessible calculator UI, local SQLite persistence of history and calculator state, JSONL calculation-event streaming/logging, and one free/no-key financial market-data API (FX rates).

Audience/user: the project owner, who will personally run the app in Tauri dev mode and have its webview validated in a real browser.

## Scope and non-goals

### In scope

- A greenfield app in `calculator-financial-tauri-7` only.
- Basic and Financial modes with a user-switchable toggle.
- The 8-formula v1 financial set (see Architecture decisions below).
- SQLite (`rusqlite`, bundled feature) as the durable store.
- A JSONL append-only audit/export/replay log, plus an optional live Tauri Channel calculation trace.
- Frankfurter FX integration feeding currency conversion and a small live-rates panel.
- An Antikythera visual theme (circular brass/bronze dial faces, gear-like rotating controls/ornamentation, inscribed-dial typography) applied without harming usability or accessibility.
- Full browser-UI no-native-dialog compliance.
- The `browser_ui_validation` input set defined below.

### Non-goals

- Do not read, modify, reuse, or dispatch any agent regarding `calculator-financial-tauri-3`, `calculator-financial-tauri-5`, `calculator-financial-tauri-6`, or their docs (`docs/plans/calculator-financial-tauri-5.md`, `docs/plans/calculator-financial-tauri-6.md`, `docs/research/calculator-financial-tauri-3-formulas-and-architecture.md`). These are prior unrelated attempts and remain strictly untouched.
- No paid API keys.
- No news/equities/crypto panel in v1 (would add a key and scope; needs separate user approval).
- Deferred formulas: bond price/yield and full multi-date XIRR/XNPV.
- No commit, push, pull request, or deploy unless the user explicitly requests it.

This plan is a draft recommendation and grants no authority on its own. T1 starts only after the user explicitly approves it.

## Evidence references

- Direct `RESEARCH_EVIDENCE` packet consumed by Planner from nested Researcher (task_id `calculator-financial-tauri-7`, verified 2026-07-14). The researcher offered to persist a detailed writeup at `docs/research/calculator-financial-tauri-7-formulas-architecture-api.md`; that file is not required for this plan and was not produced. Key grounded facts are recorded directly in this plan below.
- Repository findings below were confirmed via directory listing only (glob); no sibling source, plan, or research content was read or reused.

## Repository findings

- Confirmed via glob only (contents not read): sibling folders `calculator-financial-tauri-3`, `-5`, `-6` exist and use a `src-tauri/` layout. This only establishes the "-N" naming convention and confirms `-7` is the correct next sibling. No code, plan, or research from siblings is reused.
- Greenfield: no existing source in the target folder; all files are new.
- The project's browser-UI invariant (`CLAUDE.md`) applies: the Tauri webview is a browser-rendered UI, so native dialogs are prohibited and Browser Validator inputs are mandatory in this plan.

## Architecture decisions (from research evidence)

### v1 formula set (8 formulas)

Money math is done in `f64`, rounding only at display. TVM sign convention: inflows positive, outflows negative. Periodic rate `i` is a decimal.

| # | Formula | Definition / method | Edge cases and guards |
|---|---|---|---|
| A1 | Simple interest | `I = P*r*t`; `A = P*(1+r*t)` | `r` or `t = 0` gives `I = 0` |
| A2 | Compound interest | `A = P*(1+r/n)^(n*t)`; continuous `A = P*e^(r*t)` | Guard `n >= 1`; `r = 0` gives `A = P` |
| A3 | TVM (PV/FV/PMT/N/I unified) | `0 = PV + PMT*(1-(1+i)^(-N))/i + FV*(1+i)^(-N)`; annuity-due multiplies the PMT term by `(1+i)`. Closed-form solves for FV, PV, PMT, N when the others are given. | Must special-case `i = 0`: `PMT = -(PV+FV)/N`; `FV = -(PV+PMT*N)`; `N = -(PV+FV)/PMT`. Solve-for-`I` has no closed form and uses the iterative solver shared with IRR (A6). |
| A4 | Amortization schedule (FV=0 case of A3) | `PMT = P*i/(1-(1+i)^(-N))`; per period `interest_k = balance_{k-1}*i`, `principal_k = PMT - interest_k`, `balance_k = balance_{k-1} - principal_k`; force the final balance to exactly 0. | Edge `i = 0`: `PMT = P/N` |
| A5 | NPV | `NPV = sum_{t=0..M} CF_t/(1+r)^t` | Guard `r > -1` |
| A6 | IRR | Solve `NPV(r) = 0` via Newton-Raphson (seed `r0 = 0.1`, `NPV'(r) = sum -t*CF_t/(1+r)^(t+1)`) with bisection fallback on a sign-change bracket over `[-0.9999, 10]`; max ~100 iterations; tolerance `|NPV| < 1e-7` or `|dr| < 1e-9`; requires at least one sign change. | Return "no unique IRR" rather than a wrong root for non-conventional cash flows. This one Newton+bisection solver is reused for both IRR and TVM solve-for-`I`. |
| A7 | CAGR | `(V_end/V_begin)^(1/years) - 1`, requires `V_begin > 0`, `V_end > 0`, `years > 0`. Optional cheap companions if time permits: ROI `= (gain - cost)/cost`; break-even units `= FixedCosts/(Price - VariableCostPerUnit)`, guard `Price > VariableCost`. | As stated above |
| A8 | Currency conversion | `converted = amount * rate(base -> quote)`; cross rate `= rate(base -> B)/rate(base -> A)`; rates sourced from Frankfurter (see External data API below). | Missing or zero rate surfaces "rate unavailable" — never silently substitutes 0. |

**Deferred from v1** (need separate user approval before implementation): bond price/yield; full multi-date XIRR/XNPV.

### Persistence architecture (SQLite + JSONL)

SQLite is the single source of truth. JSONL is an append-only audit/export/replay log plus an optional live trace, not a store of record. JSONL solves: a human-readable append-only audit/export of every calculation, a crash-safe streaming log, an easy "export my history" file, and a natural payload for a live multi-step trace over a Tauri Channel.

Over-engineering to avoid: JSONL as the primary store, event-sourcing/CQRS, rebuilding SQLite from JSONL on boot, and message brokers.

- **Crates**: `rusqlite` with the `bundled` feature (recommended, see Assumptions and decisions below) for single-user local storage — no system SQLite dependency, synchronous, minimal; `serde` and `serde_json` for JSONL (one JSON object per line, `BufWriter`, flush per event); `tauri::ipc::Channel` for live ordered streaming; `app.emit` (`Emitter` trait) for discrete UI notifications.
- **DB location**: resolved via the Tauri path API, `app.path().app_data_dir()`. Never hardcode a path.
- **Minimal SQLite schema**:
  - `history(id INTEGER PRIMARY KEY, ts TEXT ISO8601, mode TEXT('basic'|'financial'), formula TEXT, inputs_json TEXT, result_json TEXT, result_display TEXT)`
  - `app_state(key TEXT PRIMARY KEY, value_json TEXT)` for last mode/registers/theme/undo cursor
  - optional `fx_rate_cache(base TEXT, quote TEXT, rate REAL, as_of TEXT, fetched_at TEXT, PRIMARY KEY(base, quote))`
- **Minimal JSONL record**: `{"ts":"...Z","event":"calc","mode":"financial","formula":"IRR","inputs":{...},"result":{...},"engine":"newton","iters":7}`. Event types are kept minimal: `calc`, optionally `state` and `error`. Do not build a large event taxonomy for v1.

### External data API (FX rates)

- **Primary**: Frankfurter (`frankfurter.dev`) — ECB reference FX rates, JSON, no API key, no account, no fixed quota (fair-use only), free for commercial use, roughly 200 currencies, updated each ECB working day around 16:00 CET, history back to 1999. Use the v1 `/latest` endpoint for stability: `GET https://api.frankfurter.dev/v1/latest?base=USD&symbols=EUR,GBP`, returning `{"amount":1.0,"base":"USD","date":"YYYY-MM-DD","rates":{...}}`. Cache daily rates in `fx_rate_cache`; refresh once per session/day (intraday refresh is not useful given ECB cadence). On offline or error, fall back to cached rates and show a "rates as of &lt;date&gt;" indicator.
- **Fallback**: exchangerate.host (no-key basic use, roughly 10 requests/minute, terms volatile and must be re-verified at build time) for the same FX purpose only, if Frankfurter is unreachable.
- **Deferred** (need keys or add scope; require separate user approval): Alpha Vantage (25/day), Finnhub (news/equities, free key), CoinGecko (crypto, demo key plus attribution), FRED (macro, free key), Stooq (no official API).

## Interfaces and data

- **Rust Tauri commands** (proposed; to be finalized by the implementing engineer): `calculate_basic`, `calculate_financial(formula, inputs) -> {result_json, result_display}`, `list_history` / `clear_history`, `get_state` / `set_state`, `export_history_jsonl(path)`, `fetch_fx_rates(base) -> cached+live rates`. A live trace uses a Tauri Channel handed to the financial calculation command for multi-step formulas (amortization schedule rows, IRR iterations).
- **Data**: SQLite file under `app_data_dir`; JSONL log file alongside it (also under `app_data_dir`), appended per calculation event; Frankfurter v1 JSON response shape as documented above.
- **Compatibility**: Tauri v2 latest stable; pin exact versions in `Cargo.toml`/`package.json` at scaffold time.

## Ordered work

Decompose into 5 bounded, sequential T1 `ENGINEERING_JOB`s. Each job is gated by an independent Verifier pass, and the UI-bearing jobs are additionally gated by a Browser Validator pass. Every job carries the browser-UI no-native-dialog constraint and the `browser_ui_validation` inputs below.

**Job 1 — Scaffold + SQLite + Basic mode.**
Create `calculator-financial-tauri-7` with a Tauri v2 + Vite (plain HTML/CSS/TypeScript) scaffold; `rusqlite` (bundled) integration; `app_data_dir` DB path; `history` and `app_state` schema created on first run; a Basic-mode calculator UI (number pad, `+ - * /`, `%`, memory `M+`/`M-`/`MR`/`MC`, `C`/`CE`, decimal, equals) behaving like a handheld calculator; every basic calculation persisted to `history`.
*Acceptance:* `npm run tauri dev` launches; basic arithmetic is correct including chained operations, and divide-by-zero shows an inline error state (not a native dialog); a history row is written and survives an app restart; the DB resolves under `app_data_dir`; unit tests for the arithmetic engine pass.

**Job 2 — Financial mode + formulas + mode switch + Antikythera theme.**
Implement the 8-formula engine (A1–A8) in Rust with the shared Newton+bisection solver for IRR and TVM solve-for-`I`, covering all edge cases (`i = 0` branches, IRR non-convergence returning "no unique IRR", and the other stated guards); a user-switchable Basic/Financial toggle persisted in `app_state`; per-formula input forms with inline validation; the Antikythera visual theme (circular brass/bronze dials, gear ornamentation/rotating controls, inscribed typography) applied without harming readability, contrast, keyboard operability, or accessibility.
*Acceptance:* TDD unit tests with published test vectors pass (for example, PMT for P=100000, i=0.005, N=360 is approximately 599.55; the `i = 0` branch gives P/N; IRR on `[-1000, 300, 420, 680]` is approximately 0.1225; a sign-change-free flow returns "no unique IRR"); the mode toggle persists across reload; the theme meets WCAG AA contrast and full keyboard operability; financial calculations are persisted to `history`.

**Job 3 — JSONL streaming + history persistence wiring.**
Append every calculation as one JSONL line (`serde_json`, `BufWriter`, flush) to a log file under `app_data_dir`; SQLite remains the source of truth; implement `export_history_jsonl`; wire a Tauri Channel live trace for multi-step formulas (amortization rows, IRR iterations) rendered progressively in the UI; the history view lists persisted entries and reloads after restart.
*Acceptance:* JSONL round-trips one object per line and re-parses; the Channel emits ordered events to a frontend listener and the multi-step trace renders; the history view persists across reload; export produces a valid JSONL file.

**Job 4 — Frankfurter FX integration panel.**
Rust command `fetch_fx_rates(base)` calling `GET https://api.frankfurter.dev/v1/latest` with `fx_rate_cache` read-through caching (refreshed per session/day), offline fallback to cache with a "rates as of &lt;date&gt;" indicator; wire live rates into the A8 currency-conversion formula and a small live-rates panel in Financial mode.
*Acceptance:* with network available, the panel shows current ECB rates and conversion uses the live rate; with network disabled, the panel shows cached rates plus the as-of indicator and never crashes or shows a native dialog; a missing rate surfaces "rate unavailable" inline; no API key is present anywhere.

**Job 5 — Polish, accessibility, no-dialog compliance, clear-history modal.**
Add an app-owned accessible modal for confirmations (for example, "clear history") and inline error states everywhere; run and pass the deterministic no-native-dialog source scan; verify keyboard/focus behavior on the modal (focus trap, Esc/Enter, focus return); confirm responsive layout across the two required viewport profiles; complete a final accessibility pass.
*Acceptance:* the deterministic scan finds zero native `alert`/`confirm`/`prompt`/`window.*` or `beforeunload` usages; clear-history uses the app modal with correct keyboard/focus behavior; the layout works at both viewport profiles; all prior journeys still pass.

## Acceptance and validation

- Engineering is TDD-first; per-formula unit tests use published test vectors (including the `i = 0` and IRR non-convergence branches); arithmetic engine tests; a JSONL round-trip test; an `app_data_dir` resolution test; `npm run tauri dev` runs, and after approval the user runs it to view and interact with the app.
- An independent Verifier pass is required after each T1 job before it counts as complete; a Browser Validator pass is required for the UI-bearing jobs (1, 2, 3, 4, 5) after Verifier.
- The deterministic no-native-dialog source scan (searching for `alert(`, `confirm(`, `prompt(`, `window.alert`/`confirm`/`prompt`, `beforeunload`) must return zero hits.
- Keyboard/focus verification on the app-owned modal is required.

## Risks and rollback

| Risk | Mitigation |
|---|---|
| Free-tier/API-terms volatility (Frankfurter, exchangerate.host) | Re-verify no-key status and terms at build time; offline cache fallback mitigates outage. Risk: low-medium. |
| IRR numerical non-convergence or multiple roots | Mitigated by the bisection fallback plus the "no unique IRR" return and tests. Risk: medium (correctness-sensitive). |
| Antikythera theme harming usability/accessibility | Mitigated by WCAG AA contrast and keyboard operability acceptance gates. Risk: medium. |
| `rusqlite` vs. `sqlx` choice | Recommended: `rusqlite` (bundled). If the user later wants frontend-run SQL/migrations, switch to `sqlx` + `tauri-plugin-sql` (documented here as the alternative, not the v1 default). |
| Repository-wide impact | Rollback/containment: greenfield folder — all work is isolated in `calculator-financial-tauri-7`; no changes touch sibling folders or shared repository files; a failing job is contained to that folder and can be discarded without affecting the rest of the repository. |
| Stale-plan trigger | If Tauri v2 APIs, chosen crate versions, or Frankfurter terms materially change before implementation, this plan is stale and needs replanning or explicit reapproval. |

## Assumptions and decisions

### Assumptions (Planner-made per plan authority; flagged for user awareness, not scope- or safety-changing)

- Frontend stack = plain HTML/CSS/TypeScript + Vite (no heavy framework). Rationale: lightweight, matches the "genuinely usable, not decorative" requirement, and keeps the Antikythera theming in hand-authored CSS/SVG.

### Decisions (Planner recommendations; flagged for user awareness)

- Backend DB = `rusqlite` with the `bundled` feature over `sqlx`/`tauri-plugin-sql`, for a single-user local store; `sqlx` + plugin is documented as the alternative if frontend-run SQL/migrations are later wanted.
- FX API = Frankfurter primary (v1 `/latest`), exchangerate.host fallback; the v1 endpoint is chosen over v2 for stability.
- v1 formula set = the 8 formulas listed above; bond price/yield and XIRR/XNPV are deferred.

### Approvals still needed from the user

- Explicit approval of this plan before any engineering work begins.
- Explicit, separate approval if a news/equities/crypto panel (needing an API key and new scope) is later desired.

## Browser UI dialog policy

**Required.** The Tauri v2 webview is a browser-rendered UI. Native dialogs are prohibited everywhere: no `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts, including for calculator errors (divide-by-zero, invalid input) and for confirmations (clear history). Use an app-owned accessible modal for acknowledgement/confirmation and inline validation/error state where it better serves the user. Every UI-bearing `ENGINEERING_JOB` must require a deterministic no-native-dialog source scan and a modal keyboard/focus verification.

## Browser UI validation

- **Launch/readiness command:** `npm run tauri dev` for the full desktop app the user runs. For browser-based validation of the webview, the Vite dev server backing the Tauri frontend is launched with `npm run dev` and is ready when it prints the local URL or responds on the base URL.
- **Base URL:** `http://localhost:1420` (Tauri v2 Vite default; the implementing engineer must confirm/pin the port in `vite.config` and `tauri.conf.json` and record the actual URL in the job-level documentation).
- **Fixture/reset procedure:** a deterministic reset to a known state — provide a dev-only reset/seed path (for example, a documented way to point the SQLite DB and JSONL log at a temp fixture location, or a reset command that clears `history`/`app_state` and seeds a fixed set of history rows plus a cached FX rate), so each validation run starts from an identical known DB state.
- **User journeys to validate** (visible outcomes in parentheses):
  1. Basic-mode arithmetic including chained operations (correct running result shown) and divide-by-zero (inline error state, no native dialog).
  2. Switch to Financial mode (mode toggle changes the UI and persists after reload).
  3. At least two financial formulas end-to-end, for example amortization schedule and IRR (correct computed values plus multi-step trace rows/iterations render).
  4. History view and persistence across reload (entries present, survive app/page reload).
  5. An error case in each mode (basic divide-by-zero inline; financial invalid input or "no unique IRR" inline).
  6. External FX data panel (live ECB rates shown with date; offline shows cached "rates as of &lt;date&gt;").
  7. Clear-history confirmation via the app-owned modal (modal opens, keyboard focus trapped, Esc cancels, confirm clears and history empties).
- **Viewport profiles:** desktop (for example, 1280x800 or larger) and a smaller window size (for example, 800x600); both must remain operable and readable.
- **Observable outcomes:** as listed inline per journey above; Browser Validator captures screenshots per journey and viewport.
- The deterministic no-native-dialog scan and the app-owned-modal keyboard/focus check are prerequisites for the browser validation pass.

## Downstream owner

`t1-engineer` (`engineering-fleet`), only after explicit user approval of this plan. Browser/webview UI validation for jobs 1–5 is owned by `browser-validator`, after the Verifier passes.

## Notes on plan handoff

- `engineering_mode: standard`
- `team_authorization: not applicable`
