---
title: "calculator-financial-tauri-5: Python + Rust/Tauri v2 Antikythera-themed financial calculator"
slug: calculator-financial-tauri-5
plan_id: calculator-financial-tauri-5
status: Approved
route: engineering
created: 2026-07-14
updated: 2026-07-14
downstream_owner: t1-engineer (only after explicit user approval of this plan)
---

# calculator-financial-tauri-5: implementation plan

## Status

**Approved.** See the Approval section immediately below for the record of explicit user approval. If a material repository, requirement, dependency, or vendor-terms change occurs before implementation starts, this plan becomes stale and must be reapproved or replanned before T1 proceeds.

## Approval

- **Status:** Approved
- **Approved by:** rob.hasselbach@gmail.com (user, via orchestrator session)
- **Date:** 2026-07-14
- **Scope approved:** Full plan as written, proceeding to T1 implementation (`ENGINEERING_JOB`).
- **Noted user acknowledgements:**
  1. GNews.io's free tier is non-commercial/single-user only; this is acceptable for this personal/local use.
  2. Live market/news data requires the user to supply their own free Finnhub and GNews.io API keys; the app must degrade gracefully without them.

## Outcome and audience

This plan is execution-ready for a later T1 engineering job to implement a working Python + Rust + Tauri v2 desktop financial calculator, buildable, runnable, and launchable offline on Windows. The finished app has an Antikythera-mechanism-themed webview UI (gears, dials, concentric rings; bronze/verdigris palette), dual basic/financial calculator modes toggled within one UI, permanent SQLite calculation history, a JSONL append-only calculation-event stream, and at least one live free market-data source (Finnhub) and one free financial-news source (GNews.io) with graceful offline/no-key fallback.

Audience: the orchestrator (to present for user approval) and T1 (to implement after approval). The plan ends with concrete build/run/test instructions and a required browser/webview UI validation acceptance gate so the app can be launched and its rendered UI checked against design intent.

## Scope and non-goals

### In scope

1. A new folder `calculator-financial-tauri-5` at the repository root, created fresh. The existing `calculator-financial-tauri-3` code is not reused or modified.
2. Python owns the financial/quantitative calculation logic; Rust/Tauri owns the desktop shell, command layer, persistence, event streaming, and external data polling.
3. An Antikythera-machine visual motif (gears, dials, concentric rings; bronze/verdigris aesthetic) as the webview design language.
4. Dual "basic" (standard arithmetic) and "financial" (18 advanced formulas, per the reused prior research) modes toggled within one UI.
5. SQLite permanent calculation history plus a JSONL append-only event stream between the backend and the UI.
6. At least one free, no-paid-key market-data source (Finnhub) and one free financial-news source (GNews.io), wired in with graceful offline/no-key fallback.
7. Automated tests, concrete Windows build/run instructions, and an explicit browser/webview UI validation gate.

### Non-goals

- Reusing or modifying `calculator-financial-tauri-3` code.
- Multi-user sync or cloud backup.
- Commercial distribution (GNews.io's free tier is scoped to non-commercial, single-user use).
- Paid API tiers.
- Committing, pushing, opening a pull request, or deploying without explicit user request.
- Changing the formula math from the established 18-formula set.
- Re-researching the formulas, the streaming-architecture value, or the data/news API selection; those questions are already settled by prior research (see Evidence references below).

This plan is a draft recommendation and grants no authority on its own. T1 starts only after the user explicitly approves it.

## Evidence references

- `docs/research/calculator-financial-tauri-3-formulas-and-architecture.md` — settles, and this plan reuses by reference without duplication: the 18-formula set (simple interest, compound interest, future value, present value, loan/mortgage payment, amortization schedule, ROI, savings goal/sinking fund, break-even, NPV/IRR, bond pricing, straight-line depreciation, declining-balance depreciation, CAGR, effective annual rate vs. nominal, payback period, WACC, annuity-due/ordinary toggle) with input/output contracts and edge cases; decimal-precision guidance; the JSONL-append + SQLite single-writer + WAL + startup-reconciliation persistence pattern; the Tauri async-command + tokio background-poll + `handle.emit()` streaming pattern; and the market-data/news API selection (Finnhub for market data, GNews.io for news; Alpha Vantage and NewsAPI.org rejected on Terms-of-Service grounds).
- New research evidence gathered for this plan (Python↔Rust/Tauri integration boundary; not covered by the prior document) — see the Architecture decision section below for the full findings. Target document for this evidence, if persisted by Researcher: `docs/research/calculator-financial-tauri-5-python-rust-boundary.md`.
- Reference-only prior build (do not reuse or modify code): `H:\CommandCenter\orchestrator\calculator-financial-tauri-3` — a Rust-only Tauri v2 build (Python deliberately omitted in that build) whose `Cargo.toml`, `tauri.conf.json`, `src/` module layout, and README document a proven dependency set and an Antikythera design vocabulary that this plan draws architectural lessons from without copying code.

## Repository findings

- Repository root: `H:\CommandCenter\orchestrator`. Plans are persisted at `docs/plans/<slug>.md`; Scribe is the sole plan author; approval follows `docs/PLAN-CONTRACT.md` and `docs/plans/README.md`.
- `calculator-financial-tauri-3` (reference only): Rust-only, Tauri v2. `Cargo.toml` uses `tauri` v2, `rusqlite` 0.31 (bundled), `sqlx` 0.8 sqlite, `rust_decimal` 1.35, `reqwest` 0.11, `tokio` (full), `uuid`, `chrono`, `dotenv`, `tracing`, `thiserror`; release profile uses `lto` and `codegen-units = 1`. Source layout: `main.rs`, `models.rs`, `commands.rs`, `calculators/{mod,basic,financial}.rs`, `persistence/{mod,event_log}.rs`, `market_data.rs`. `tauri.conf.json`: productName "Financial Calculator", identifier `com.calculator.financial`, `devUrl` `http://localhost:5173`, `frontendDist` `../frontend/dist`, 1400x900 window, `csp` null. Its README documents the 18-formula set, SQLite tables (`calculation_history`, `market_data`, `news` with TTL), the Antikythera bronze/verdigris theme, and a dev-only mock frontend backend.
- `calculator-financial-tauri-5` draws architectural lessons from `-3` (dependency set, module shape, theme vocabulary) but is a fresh Python+Rust build in its own new folder.

## Architecture decision: Python↔Rust/Tauri integration boundary

New research evidence (deep, comparison mode) resolved the one dimension not covered by the prior `-3` research document: how Python calculation logic integrates with the Rust/Tauri shell.

### Options compared

- **(a) PyO3 (embed CPython into the Rust binary).** High Windows build fragility: must ship `pythonXY.dll` plus the stdlib, version-matched to the embedding build; static linking carries documented complications and disables PyO3's auto-initialize path. No process isolation — a Python-side fault crashes the whole Tauri app. The GIL forces `spawn_blocking` around every call. A JSONL line-stream model is awkward to express through this boundary.
- **(b) Tauri v2 sidecar (bundle a self-contained frozen Python executable).** A Python executable frozen with PyInstaller or Nuitka is declared in `tauri.conf.json` under `bundle.externalBin`, with a `-$TARGET_TRIPLE` filename suffix (Windows: `binaries/calc-engine-x86_64-pc-windows-msvc.exe`). Rust spawns it via `app.shell().sidecar("calc-engine")?.spawn()`, which returns `(rx, child)`; `rx` yields `CommandEvent::{Stdout, Stderr, Terminated, Error}`, and `child.write()` pushes bytes to the child's stdin. Requires an explicit least-privilege capability entry in `src-tauri/capabilities/default.json` (`shell:allow-execute` scoped to `{name: "binaries/calc-engine", sidecar: true}`). The sidecar binary is resolved from beside the installed app, not from the system `PATH`.
- **(c) Plain subprocess/stdio.** Functionally similar streaming characteristics to (b) but strictly inferior for a Tauri app: it hand-rolls bundling, resource-path resolution, and permissions that the sidecar mechanism already provides.

### Recommendation

Use the **Tauri v2 sidecar with a frozen Python executable** (option b). It is the only option that gives, together: offline interpreter bundling (no assumed system Python on the target machine), process isolation (a Python-side crash does not take down the Rust/Tauri process), no-`PATH` binary resolution, and a native newline-delimited stdout stream that directly is the JSONL event stream the prior architecture document already specifies. This maps onto the prior document's JSONL-append + SQLite single-writer + tokio background-poll + `emit()` pattern with no structural change: the Python sidecar's stdout becomes a JSONL event source alongside the existing Rust market-data/news poll, and Rust remains the single writer to JSONL and SQLite and the sole `emit()` source to the webview.

### Concrete design for T1 to implement

- Python owns the 18 financial formulas and the basic-mode arithmetic. It reads newline-delimited JSON requests from stdin: `{request_id, op, args}`, where `args` encodes money/decimal values as **strings**, never floats. It writes newline-delimited JSON events to stdout: `{request_id, kind, payload}`, flushing after every line. Run with `PYTHONUTF8=1` and unbuffered output so Windows code pages and buffering cannot corrupt the JSON stream.
- Money crosses the process boundary as strings in both directions: Python `Decimal` → `str` → Rust `rust_decimal::Decimal`.
- Spawn exactly **one long-lived sidecar** inside Tauri's `Builder::setup()`, so any interpreter/extraction startup cost is paid once. A dedicated tokio task owns the `rx` receiver, correlates responses to requests by `request_id`, persists each stdout line through the single-writer persistence function, and then calls `handle.emit()` to push the event to the webview. Tauri async commands write calc-request lines to the sidecar's stdin via `child.write()`.
- Shut the sidecar down with an explicit stdin `"shutdown"` control message, not `process.kill`, because a PyInstaller one-file build hides the real child PID from the parent process, so `kill` targeting that PID does not reliably terminate the frozen interpreter.
- Market-data and news polling stay entirely in Rust via `reqwest`; the calculation path itself is fully offline and requires no network access.

### Packaging tradeoff (T1 decision, intentionally left open)

PyInstaller `--onefile` gives the cleanest single-file mapping onto `bundle.externalBin`, but adds temp-extraction cold-start latency and carries the `process.kill`-does-not-work pitfall described above. PyInstaller `--onedir` or Nuitka `--standalone` launch faster and expose a real, killable PID, but produce a folder rather than a single file. Either choice is mitigated by the persistent-sidecar-plus-stdin-shutdown design above. T1 selects the packaging tool and records the choice and rationale in the ADR from step 2 of the ordered work below.

### Security and reliability notes

- Pass data over stdin as JSON, never as argv, to avoid argument-injection risk.
- The shell capability must list only the `calc-engine` sidecar (least privilege).
- On `CommandEvent::Terminated` or `CommandEvent::Error`, Rust restarts the sidecar with backoff and surfaces the failure through an app-owned accessible modal, never a native dialog.
- The calc sidecar needs no network access, so the app's core calculation path builds, launches, and computes fully offline.

### Source ledger (for the ADR T1 records in step 2)

- S1 — Tauri v2, "Embedding External Binaries," https://v2.tauri.app/develop/sidecar/
- S2 — PyO3, "Building and distribution," https://pyo3.rs/main/building-and-distribution
- S3 — PyO3/maturin release notes and the PyO3 v0.28 guide
- S4 — Practitioner PyInstaller-Tauri sidecar examples (`dieharders/example-tauri-v2-python-server-sidecar`; an "aiechoes" production-desktop guide)
- S5 — Tauri sidecar community discussions
- S-PRIOR — `docs/research/calculator-financial-tauri-3-formulas-and-architecture.md`

Freshness note: all sources were accessed 2026-07-14. Tauri, PyO3, and maturin are living documentation; T1 must reconfirm pinned tool versions and volatile vendor rate limits/terms at implementation time, not rely solely on this plan's snapshot.

## Ordered work

Each step names its observable result and its dependency on the prior step. All steps execute only after explicit user approval of this plan.

1. **Research reuse and evidence baseline** (already complete as of this plan). Reuse the `-3` research document for the formula set, the streaming-architecture value, and the data/news API selection. Use the new boundary evidence above for the Python integration design. No further external research is required for T1 beyond reconfirming volatile vendor rate limits/terms and pinned tool versions at implementation time. *Observable result:* this plan's architecture section cites both evidence sources. *Dependency:* none.

2. **Architecture / Decision Record.** At the start of implementation, T1 records an ADR-style decision document capturing: the Python-as-calc-engine-via-Tauri-sidecar boundary, with the rejected PyO3 and plain-subprocess alternatives and why; the JSONL event schema (`{request_id, op/kind, args/payload}` with money encoded as strings); the SQLite schema (permanent `calculation_history`; TTL-bound `market_data` and `news` tables); the JSONL append-only audit-log file path and the single-writer/WAL/startup-reconciliation design; and the Antikythera UI design system (palette, gear/dial/concentric-ring components, dual-mode layout). *Observable result:* a written decision record in the `calculator-financial-tauri-5` folder or under `docs/`, plus a chosen freezing tool (PyInstaller vs. Nuitka) with stated rationale. *Dependency:* step 1.

3. **Scaffold and Rust/Tauri backend.** Create `calculator-financial-tauri-5` with `Cargo.toml` modeled on `-3`'s proven dependency set (`tauri` v2, `rusqlite` bundled or `sqlx` sqlite, `rust_decimal`, `reqwest`, `tokio` full, `uuid`, `chrono`, `tracing`, `thiserror`, plus the Tauri shell plugin for sidecar support), `tauri.conf.json` (own identifier, `bundle.externalBin` entry for `binaries/calc-engine`, `devUrl`/`frontendDist`), `capabilities/default.json` (least-privilege `shell:allow-execute` scoped only to the `calc-engine` sidecar), and `main.rs` with `Builder::setup()` spawning the persistent sidecar plus the tokio rx/persist/emit loop, and Tauri async commands for calc requests, mode toggle, history query, and API-key configuration. *Observable result:* `cargo check`/`cargo build` compiles; the sidecar spawn path is wired. *Dependency:* step 2.

4. **Python calc engine.** Implement the 18 financial formulas plus basic arithmetic in Python using `decimal.Decimal`; implement the stdin/stdout newline-delimited JSON protocol with `request_id` correlation, `PYTHONUTF8=1`, per-line flush, money-as-strings, and a `"shutdown"` control message. Freeze to a self-contained Windows executable (the tool chosen in step 2) named `calc-engine-x86_64-pc-windows-msvc.exe` into `src-tauri/binaries/`. *Observable result:* the frozen executable runs standalone on a clean profile and round-trips a JSON request; unit tests cover reference values (for example, CAGR from $100 to $200 over 5 years ≈ 14.87%). *Dependency:* step 3 (for the target binary path/naming), step 2 (for schema and tool choice).

5. **Frontend UI (Antikythera theme, dual mode).** Build the webview (HTML/CSS/JS, or a lightweight framework at T1's discretion — no heavyweight dependency without a stated need) implementing a bronze/verdigris Antikythera design system (gears, dials, concentric rings), a basic/financial mode toggle within one UI, dynamic financial-formula input forms, a results panel, a history panel, and market-data/news panels. All acknowledgement, confirmation, and error surfacing uses app-owned accessible modals; input errors use inline validation. *Observable result:* the UI renders both modes; the toggle works; the theme is visible. *Dependency:* step 3 (command surface must exist to wire against).

6. **SQLite and JSONL streaming wiring.** Rust, as the single writer, appends each calculation event to the JSONL log and inserts it into the SQLite `calculation_history` table (permanent), and emits events to the webview so history/results update live. Implement startup reconciliation between the JSONL log and SQLite. *Observable result:* history persists across app restarts; JSONL events are observable on disk and in the UI stream. *Dependency:* steps 3 and 4.

7. **External data/news integration with fallback.** Implement Rust/`reqwest` clients for Finnhub (market data) and GNews.io (news) behind a thin provider-swap interface; background tokio poll on a timer writing to the TTL-bound tables and emitting updates; graceful degradation when no key is configured or the network is offline (panels show a clear "no key / offline" state, never an error dialog). *Observable result:* with keys configured, real data renders; without keys or offline, the graceful fallback state renders. *Dependency:* step 3.

8. **Automated tests.** Python unit tests for the formulas (reference values) and for the stdin/stdout protocol (money survives as strings in both directions). Rust tests for persistence single-writer behavior and startup reconciliation, sidecar event handling (`Terminated`/`Error` triggering backoff restart), and provider clients (mocked, for example with `mockito`) including the offline/no-key fallback path. A deterministic no-native-dialog source scan over the frontend asserting zero occurrences of `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt`, and `beforeunload`. *Observable result:* all tests and the scan pass, with captured output. *Dependency:* steps 4, 6, 7.

9. **Build and run instructions.** Concrete Windows steps: freeze the Python executable into `src-tauri/binaries/` with the correct `-$TARGET_TRIPLE` name; `cargo tauri dev` to run in development; `cargo tauri build` to produce the offline installer with the sidecar embedded; verify launch on a machine/profile with no system Python installed and no network connection. *Observable result:* documented, reproducible commands that actually launch the app. *Dependency:* steps 3–8.

10. **Browser/webview UI validation gate (required acceptance step, not optional).** After build, launch the app and validate the rendered Antikythera UI/UX in the real webview against the research-driven design intent and the implementation: both modes render and toggle; the theme (gears/dials/concentric rings, bronze/verdigris) matches intent; history/market/news panels render real or gracefully-degraded data; modal keyboard/focus behavior is verified; the no-native-dialog scan evidence is attached. *Observable result:* a captured validation record (screenshots and/or notes) confirming a pass. *Dependency:* step 9.

## Interfaces and data

- **Sidecar IPC:** newline-delimited JSON. Request: `{request_id, op, args}` (money as strings). Event: `{request_id, kind, payload}`. Data crosses the boundary over stdin only, never via argv.
- **SQLite (permanent):** `calculation_history` — `id` (UUID TEXT), `ts` (ISO-8601), `mode` (`basic`|`financial`), `calculator` (op/formula name), `inputs` (JSON), `outputs` (JSON).
- **SQLite (TTL-bound):** `market_data` — `id`, `ts`, `ticker`, `price` (as string), `ttl_expires`. `news` — `id`, `ts`, `title`, `description`, `url`, `source`, `ttl_expires`.
- **Persistence mode:** WAL mode, single writer. A JSONL append-only audit log sits alongside SQLite, with startup reconciliation between the two. Rust is the sole writer and the sole `emit()` source to the webview.
- **Tauri configuration:** `bundle.externalBin: ["binaries/calc-engine"]`; capability `shell:allow-execute` scoped only to `{name: "binaries/calc-engine", sidecar: true}`; async commands for calc, mode, history, and config.
- **External providers:** Finnhub and GNews.io behind a provider-swap trait; free tier, no paid key; cached data is TTL-bound/revocable, not permanently archived.

## Acceptance and validation

The final implementation must satisfy all of the following:

- **(a)** The app builds and runs: `cargo tauri build` produces an installer, and the app launches.
- **(b)** SQLite calculation history persists across app restarts.
- **(c)** JSONL streaming calculation events are observable (on disk and/or in the UI event stream).
- **(d)** The dual basic/financial mode toggle works within one UI.
- **(e)** At least one live financial market-data source (Finnhub) and one news source (GNews.io) render real data when configured, or gracefully-degraded data when no key is configured or the network is offline.
- **(f)** The Antikythera-themed UI renders and matches the design intent: gears, dials, concentric rings, bronze/verdigris palette, dual-mode layout.
- **(g)** No native browser dialogs anywhere — `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts — proven by a deterministic source scan with captured output.
- **(h)** Browser/webview UI validation is performed and passing: the real app is launched, the UI/UX is checked against design intent, modal keyboard/focus behavior is verified, and evidence is captured.

TDD-first evidence required alongside (a)–(h): Python formula tests against reference values; protocol round-trip tests proving money survives as strings in both directions; Rust tests for persistence single-writer behavior, startup reconciliation, sidecar-resilience (restart on `Terminated`/`Error`), and provider fallback; and the no-native-dialog scan. T1 must return changed files, exact verification commands, their results, and any remaining limitation.

## Risks and rollback

| Risk | Mitigation |
|---|---|
| Windows build fragility from Python bundling | The sidecar-plus-frozen-executable design was chosen specifically to avoid PyO3's `libpython`/version-matching linking fragility; verify the frozen executable on a clean, no-system-Python profile. |
| PyInstaller one-file `process.kill` pitfall and cold-start latency | One persistent sidecar spawned in `setup()`; shutdown via an explicit stdin `"shutdown"` control message; T1 may choose `--onedir`/Nuitka for a real PID and faster start instead. |
| Money precision loss across the JSON boundary | Encode all decimal/money values as strings in both directions; assert correctness against reference values in tests. |
| Sidecar crash or hang | Watch `CommandEvent::Terminated`/`Error`; back off and restart; surface failure via an app-owned accessible modal, never a native dialog. |
| Vendor Terms-of-Service or rate-limit volatility for Finnhub/GNews.io, and their non-commercial scope | Reconfirm terms and limits at implementation time; treat cached data as TTL-bound/revocable; implement graceful offline/no-key fallback; keep scope to single-user, local, non-commercial use. |
| Security risk from spawning executables/PATH resolution | The sidecar resolves beside the installed app, not via system `PATH`; the capability grants least privilege, listing only `calc-engine`; JSON travels over stdin, never argv. |
| Scope creep or unintended side effects | All work is confined to the new `calculator-financial-tauri-5` folder; no changes to `calculator-financial-tauri-3` or repository-wide configuration; nothing is committed or pushed without explicit user request. A material change to requirements, tooling, or vendor terms makes this plan stale and requires replanning or reapproval before T1 proceeds. |

## Assumptions and decisions

### Safe assumptions carried into implementation

- Python is a required product constraint set by the user; this plan honors it. (The prior research noted the 18 formulas are technically satisfiable in `rust_decimal` alone, but Python-as-calc-engine is the user's stated directive and is preserved here.)
- Target platform is Windows x86_64.
- Scope is single-user, local, non-commercial, and offline-capable.
- Only free and open tooling is used.

### Decisions still requiring explicit user approval before T1 begins

- Approval of this entire plan.
- Acknowledgement that GNews.io's free tier is scoped to non-commercial, single-user use.
- Acceptance that live data requires the user to obtain free Finnhub and GNews.io keys; the app degrades gracefully without them.

### Bounded T1 implementation decisions (not requiring separate user approval)

- Packaging tool choice: PyInstaller vs. Nuitka.
- Frontend framework or plain HTML/CSS/JS choice.

## Browser UI dialog policy

**Required.** The Tauri frontend is a browser-rendered webview, so the project's Browser UI invariant applies in full. This plan and the resulting `ENGINEERING_JOB` require:

- No native `alert`, `confirm`, or `prompt`, and no `window.alert`, `window.confirm`, or `window.prompt` forms.
- No `beforeunload` prompts.
- All acknowledgement and confirmation surfaces are app-owned accessible modals: `role="dialog"`, an accessible name, a focus trap, Escape/cancel handling, and restored focus on close.
- Inline validation for calculator inputs.
- Keyboard and focus verification of every modal.
- A deterministic no-native-dialog source scan, with captured output, as required test evidence from T1.

## Downstream owner

`t1-engineer`, only after explicit user approval of this plan.

## ENGINEERING_JOB template (for the orchestrator to hand to T1 after approval)

```text
ENGINEERING_JOB
target: H:\CommandCenter\orchestrator\calculator-financial-tauri-5 (new folder; do not reuse or modify calculator-financial-tauri-3)
approved_plan: docs/plans/calculator-financial-tauri-5.md
scope:
  - Python calc engine (18 financial formulas + basic arithmetic) running as a Tauri v2 sidecar (frozen executable),
    communicating over newline-delimited JSON on stdin/stdout, money encoded as strings both directions.
  - Rust/Tauri v2 shell: persistent sidecar spawn in Builder::setup(), tokio rx/persist/emit loop, async commands
    for calc/mode/history/config, single-writer SQLite (WAL) + JSONL append-only audit log with startup reconciliation.
  - Antikythera-themed webview UI (gears, dials, concentric rings; bronze/verdigris palette), dual basic/financial
    mode toggle in one UI, history panel, market-data panel (Finnhub), news panel (GNews.io).
  - Graceful offline/no-key fallback for external providers; provider-swap interface.
acceptance_criteria:
  a. cargo tauri build produces an installer; the app launches.
  b. SQLite calculation history persists across app restarts.
  c. JSONL streaming calculation events are observable (on disk and/or in the UI event stream).
  d. Dual basic/financial mode toggle works within one UI.
  e. Finnhub market data and GNews.io news render real data when configured, or graceful fallback when not.
  f. Antikythera-themed UI renders and matches design intent (gears/dials/concentric rings, bronze/verdigris, dual-mode layout).
  g. Zero native browser dialogs (alert/confirm/prompt/window.*/beforeunload), proven by a deterministic source scan.
  h. Browser/webview UI validation performed and passing: real launch, UI/UX checked against design intent,
     modal keyboard/focus verified, evidence captured.
browser_ui_dialog_policy: required — no native alert/confirm/prompt or window.* forms, no beforeunload prompts;
  app-owned accessible modals only (role=dialog, accessible name, focus trap, Escape/cancel, restored focus);
  inline validation for inputs; keyboard/focus verification of every modal; deterministic no-native-dialog
  source scan with captured output required as test evidence.
tdd_first_ordering: write Python formula tests and protocol round-trip tests before/alongside the calc engine;
  write Rust persistence/reconciliation/sidecar-resilience/provider-fallback tests before/alongside their
  respective implementations; write the no-native-dialog scan before/alongside the frontend.
architecture_decisions:
  - Python-as-calc-engine via Tauri v2 sidecar (frozen executable), not PyO3 embedding and not a plain subprocess;
    see this plan's Architecture decision section for the full rationale and rejected alternatives.
  - JSONL event schema: {request_id, op/kind, args/payload}, money as strings.
  - SQLite: permanent calculation_history; TTL-bound market_data and news tables; WAL; single writer.
  - Sidecar shutdown via explicit stdin "shutdown" message, not process.kill.
required_return: changed files, exact verification commands, their results, and any remaining limitation.
END_ENGINEERING_JOB
```
