# Plan: calculator-financial-tauri-8 — Antikythera Financial & Basic Calculator (Tauri v2)

Status: Approved

Approved: 2026-07-15, by the user (via orchestrator).

task_id: calc-fin-tauri-8
plan_id: calculator-financial-tauri-8

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user has given explicit approval. Once approved, the approved plan path becomes `ENGINEERING_JOB.approved_plan` for the engineering fleet.

This revision remediates 12 advisory shadow findings from a `PLAN_DUCK` cross-vendor judge pass (J-001 through J-012). See Appendix B for the finding-by-finding cross-reference. Remediation did not change the plan's status or the approval gate; both remain as originally set.

## 1. Outcome and audience

Deliver a runnable Rust + Tauri v2 desktop calculator that the user can launch either via `tauri dev` or as a built app. The application is dual-mode:

- **BASIC mode**: a standard calculator using algebraic operator precedence (e.g. `2+3x4=14`).
- **FINANCIAL mode**: an advanced financial calculator covering time-value-of-money, cash-flow analysis, loans, interest conversions, bonds, depreciation, ROI/break-even, and currency conversion.

The application uses an Antikythera-mechanism-themed UI concept, "The Mechanism Computes": concentric interactive rings layered over a linear, form-based DOM, with a gear-train computation animation and a first-class flat-view toggle equivalent to the radial view. The application persists calculation history permanently in SQLite, uses jsonl event streaming where value-justified, and integrates FX/news data as specified in Section 2.1, item 6. The audience is a numerate desktop user who wants a functional, accessible calculator application.

## 2. Scope

### 2.1 In scope

1. A fresh Tauri v2 + Rust project scaffold created entirely inside `calculator-financial-tauri-8` (no other location).
2. **BASIC mode**: numeric keypad, `+ - x /` and `%`, clear/AC, decimal point, equals, memory (`M+`/`M-`/`MR`/`MC`) with a persistent memory indicator, and **algebraic operator precedence** (locked decision — see Section 8 and Section 2.3 for the fully specified semantics).
3. **FINANCIAL mode**, form-based UI, covering:
   - TVM (PV / FV / PMT / N / I%) with begin/end annuity timing and payments-per-year (P/YR) modes.
   - NPV, IRR, MIRR.
   - Loan/mortgage payment calculation with a full amortization schedule table.
   - Compound and simple interest.
   - Nominal ↔ effective rate conversion (APR/EAR).
   - Bond price/yield with an explicit, user-visible day-count basis setting.
   - Depreciation: straight-line (SL), declining-balance (DB), sum-of-years-digits (SYD).
   - ROI, break-even analysis, currency conversion.
4. SQLite-backed, searchable and taggable calculation history (mode, input expression, formula used, inputs/parameters, result, timestamp, tags).
5. jsonl event streaming for flows where it is value-justified only: iterative IRR/YTM solver progress and live what-if NPV/amortization recompute, delivered via a Tauri v2 `Channel`, with the correlation and cancellation contract in Section 6, step 4 (J-005). SQLite remains the source of truth; an append-only event journal plus jsonl export/import provide interoperability under the consistency protocol in Section 6, step 3 (J-004).
6. **FX and financial-news panel — corrected scope (J-011)**: live, keyless integration with Frankfurter (FX) and GDELT (news), with bundled offline demo fixtures as the graceful fallback when the network is unavailable or a fetch fails. No user-configured or paid API keys. This corrects an over-narrowing introduced during initial planning, in which the panel was scoped as fixtures-only with zero network calls; that wording did not match the user's approved Scope A option (a), "keyless by default with bundled offline demo fixtures." See Section 8.3 for the confirm/veto decision this interpretation still requires at approval.
7. The full Antikythera design system as specified in the passed `DESIGN_HANDOFF` (Section 5). The accessibility and interaction invariants in Section 5.1 are unaffected by the data-source-layer correction in item 6 above.
8. End-to-end validation: unit and golden-value tests against the reproducible vectors in Appendix A, a dual-layer browser/E2E validation pass (Section 9.3, J-008), an independent Verifier pass, and a Browser Validator pass on the rendered webview.

### 2.2 Non-goals and exclusions

- No live equities/stock quotes (no keyless, commercial-safe source exists; the user selected FX + news + fixtures only).
- No accounts, authentication, or multi-user support.
- No commit, push, deployment, distribution packaging, or code signing unless the user explicitly requests it later. This phase is local development only.
- No paid or user-configured API keys anywhere. FX/news access is restricted to the two allowlisted keyless hosts named in Section 2.1, item 6 and Section 9.3.
- **Hard no-touch boundary**: this plan and its downstream implementation must not read, reference, reuse, or modify any sibling `calculator-*` folder (including `calculator-financial-tauri-3`, `-5`, `-6`, `-7`) or their associated plans. `calculator-financial-tauri-8` is a fresh, isolated project with no shared state. This boundary was preserved during this remediation revision: no sibling folder was read or referenced.

### 2.3 BASIC-mode arithmetic semantics (locked; fully specified — J-012)

BASIC mode uses algebraic operator precedence, fully specified as follows:

- **Precedence and associativity**: `×` and `÷` bind before `+` and `−`. Operators of equal precedence associate left to right (`2+3×4=14`).
- **Unary minus**: supported for negative literals (e.g. entering `-5`) and for post-operator negation (e.g. `3×-2=-6`).
- **Percent** (consumer convention, relative to the preceding operand): `100+10%=110`; `100−10%=90`; `100×10%=10`; `100÷10%=1000`.
- **Repeated equals**: re-applies the last operator and operand (`2+3=` yields `5`; a further `=` yields `8`).
- **Malformed-expression recovery**: an inline error state is shown; never a dialog; the prior valid state is preserved.
- **Divide by zero**: shows an inline "Error: divide by zero" state; the application must not crash.
- **Decimal and precision**: use `rust_decimal` (preferred) or a documented `f64`-plus-display-rounding approach (see the dependency list in Section 8.3, J-010). A maximum of 15 significant displayed digits is proposed, configurable; overflow beyond that is a defined display state, not a crash.
- **Memory register**: `M+`/`M-`/`MR`/`MC` operate on a single memory register at full engine precision.
- **Keyboard mapping**: digits `0`-`9`, decimal point, `+ - * /`, `Enter` or `=` for equals, `Escape` or `Delete` for clear/AC, `Backspace` for delete-last-entry, `%` for percent. Every physical key has an on-screen button equivalent (WCAG SC 2.1.1).

## 3. Repository findings

- The target directory `calculator-financial-tauri-8` does not yet exist; this is a fresh start.
- Sibling folders `calculator-financial-tauri-3`, `-5`, `-6`, `-7` exist in the repository but were deliberately not read or reused, per the no-touch boundary in Section 2.2. Prior plan documents for those siblings (if any exist under `docs/plans/`) were likewise not consulted or reused, including during this remediation revision.
- `docs/plans/` exists and is the correct persisted location for this plan.
- The host is Windows 11. Tauri v2 requires MSVC C++ Build Tools, `rustup` with the `stable-msvc` toolchain, and the WebView2 runtime. WebView2 is pre-installed on Windows 11, satisfying that requirement. The exact Tauri 2.x Rust MSRV (approximately 1.77.2) should be confirmed at build time against the Tauri version actually pinned. WebView2's installed version also determines the matching `msedgedriver` build required for E2E validation (Section 9.3, J-008).

## 4. Research evidence

The following evidence comes from a nested Researcher pass (task `calc-fin-tauri-8`, first packet verified 2026-07-15; a second nested Researcher packet, same task ID, has since been received covering the algorithm-robustness, convention-precision, and dual-layer-validation topics folded into this revision, J-002/J-003/J-008). It is time-sensitive and the researcher's caveat applies: **professional review is required before shipping financial calculations or making any data-licensing decision.**

### 4.1 Financial formulas (canonical; high confidence)

- **TVM master equation**: `PV(1+i)^N + PMT(1+iS)[((1+i)^N-1)/i] + FV = 0`, where `S=1` for begin-mode annuities and `S=0` for end-mode. Cash-flow sign convention: inflows positive, outflows negative. Solve for the single unknown among PV/FV/PMT/N/I%. I% has no closed-form solution; see Section 4.2 for the required solver contract (J-002).
- **NPV**: `Sum CF_t / (1+r)^t`, with the timing convention in Section 4.3 (J-003): `CF_0` is undiscounted at `t=0`.
- **IRR**: see the guaranteed-outcome solver contract in Section 4.2 (J-002).
- **MIRR**: `(FV_positive(reinvested) / -PV_negative(financed))^(1/n) - 1`, compounding positive cash flows forward to `t=N` at the reinvestment rate and discounting negative cash flows back to `t=0` at the finance rate.
- **Loan payment**: `PMT = P * i / (1 - (1+i)^-n)`. Amortization: `interest_t = balance * i`, `principal_t = PMT - interest_t`, with the final payment adjusted for rounding. See Section 4.3 for the zero-rate branch.
- **Compound interest**: `FV = PV(1+i)^n`. **Simple interest**: `FV = PV(1 + i*n)`.
- **Effective rate**: `EAR = (1 + APR/m)^m - 1`; continuous compounding: `e^APR - 1`; invertible to solve for APR from EAR. Example: nominal 12% compounded monthly → EAR 12.6825% (Appendix A).
- **Bond price/yield**: `Sum c*F/(1+y/k)^t + F/(1+y/k)^N`. Clean vs. dirty price depends on the **day-count basis** (30/360 vs. actual/actual) — the top identified bond-pricing pitfall, addressed with the full contract and authoritative reference vectors in Section 4.3 and Appendix A.
- **Depreciation**: SL = `(Cost - Salvage) / Life`. DB and SYD period formulas are fully specified in Section 4.3, with the salvage floor enforced by construction.
- **ROI**: `(gain - cost) / cost`; annualized as `(1+ROI)^(1/yr) - 1`.
- **Break-even**: `units = FixedCosts / (Price - VariableCost)`.
- **Currency conversion**: `target = source * rate`.

### 4.2 IRR/YTM solver contract (J-002; replaces the prior informal Newton-Raphson description)

The prior specification ("Newton-Raphson, seed ~0.1, bisection fallback on [-0.9,10]") is replaced with a robust, guaranteed-outcome contract:

- **Bracketing**: scan an expanding range starting at `r = -0.9999` and moving upward beyond `[-0.9, 10]` until a sign change in NPV(r) is found, establishing a root bracket.
- **Root-finding**: once bracketed, use Brent's method or a safeguarded Newton-plus-bisection hybrid to converge inside the bracket.
- **Uniqueness**: apply Descartes' rule of signs to the cash-flow series. A single sign change in the cash-flow sequence guarantees a unique IRR. More than one sign change signals possible multiple roots.
- **Typed error contract** (never fabricate or clamp a rate on failure):
  - `Err(NoBracket)` or `Err(NoRealRoot)` when no sign change exists in the scanned range (for example, all cash flows share the same sign).
  - `Err(NonConvergence)` after a bounded maximum iteration count (100-200 iterations).
  - `Ok(rate)` otherwise.
- **Convergence tolerance**: `|NPV(r)| < 1e-7` (currency-scaled) and/or `|Δr| < 1e-9`.
- **Multiple-root handling**: when more than one sign change is detected, the solver still returns a root found within a conventional bracket, but the result is flagged as non-unique, and the caller must surface MIRR as the well-defined alternative alongside the flagged IRR.
- **Bond YTM**: price(y) is monotonically decreasing in yield, so the root is always unique. The same bracket-and-solve approach and the same typed error contract apply.

### 4.3 Precise conventions (J-003)

- **Payments-per-year (P/YR) convention**: periodic rate `i = nominal_annual / P/YR`; `N = years × P/YR`. This is the calculator's nominal-rate convention and is distinct from an EAR-based convention. If the user supplies an EAR instead of a nominal annual rate, convert with `i = (1+EAR)^(1/P/YR) - 1`.
- **Annuity-due (BEGIN mode)**: `due PMT = ordinary PMT / (1+i)`; annuity-due FV and PV equal the ordinary-annuity value multiplied by `(1+i)`.
- **Zero-rate branch** (avoids divide-by-zero): when `|i| < epsilon`, `PMT = -(PV+FV)/N`. For a plain loan with `FV=0`, `PMT = -PV/N`, amortized with equal principal and zero interest each period (linear amortization).
- **Bond full contract**:
  - `dirty price = clean price + accrued interest`.
  - The YTM solver consumes the **clean** price; this must be stated explicitly wherever YTM is computed or displayed.
  - `accrued interest = coupon × (days from last coupon to settlement / days in coupon period)`.
  - Two day-count bases are supported: 30/360 (US NASD convention, basis 0 — this is the basis used by the Microsoft-reference vectors in Appendix A) and actual/actual, which needs its own separate test vector (flagged as an open validation item, not yet supplied).
- **SYD depreciation**: `period_k = (remaining life at the start of period k / Σ digits) × (cost − salvage)`; by construction this never falls below salvage.
- **DB depreciation**: `period_k = min(rate × BV_{k-1}, BV_{k-1} − salvage)`, where `rate = factor / life` (200% declining balance ⇒ `rate = 2/life`); the salvage floor caps the final period(s), as shown in Appendix A.
- **NPV/MIRR timing**: `CF_0` at `t=0` is **undiscounted**; `CF_1..CF_N` are period-end cash flows, discounted by `(1+r)^t`. This engine's convention differs from Excel's `NPV()` function, which treats its first argument as occurring at `t=1`; this difference must be documented at any call site or UI label that could be compared to a spreadsheet result. MIRR compounds positive cash flows forward to `t=N` at the reinvestment rate and discounts negative cash flows to `t=0` at the finance rate.
- **Three decisions with proposed defaults, requiring explicit user confirmation at approval** (added to Section 8.3):
  1. Declining-balance switch-to-straight-line behavior: proposed default is **pure DDB with no switch to straight-line**, matching the Appendix A depreciation vector.
  2. Default bond day-count basis: proposed default is **30/360 (basis 0)**, with actual/actual available as a selectable alternative.
  3. NPV/MIRR timing convention: proposed default is **`CF_0`-at-`t=0`, undiscounted**, as specified above.

### 4.4 UX findings

A form-based financial UI is recommended over a pure HP-12C register model because it produces a lower error rate and better accessibility. BASIC mode must commit to exactly one arithmetic model; the user selected algebraic operator precedence, fully specified in Section 2.3.

### 4.5 jsonl and SQLite architecture guidance

- jsonl streaming is value-justified only for iterative-solver progress (IRR/YTM), live what-if recompute, and large simulations. It is not justified for one-shot small evaluations.
- SQLite is the source of truth (WAL mode, ACID) plus an append-only event journal (`event_id` monotonic, timestamp, type, JSON payload). jsonl export/import is offered for interoperability but jsonl must never become the primary source of truth. The full consistency protocol (atomicity, migrations, idempotent import, crash recovery) is specified in Section 6, step 3 (J-004).
- jsonl readers must tolerate a truncated or corrupt trailing line.
- Tauri v2's `Channel<T>` is purpose-built for ordered, per-invoke streaming from Rust to the webview; each channel message maps to one JSON object, i.e. one jsonl line. The correlation and cancellation contract for streaming requests is specified in Section 6, step 4 (J-005). Global `emit`/event broadcast is reserved for non-high-rate, global notifications, not streaming.

### 4.6 External API landscape and FX/news integration (corrected scope, J-011)

IEX Cloud shut down 2024-08-31 (do not use, even in future phases). Alpha Vantage free tier requires a key (25/day, 5/min). Frankfurter is keyless with no quota and ECB-sourced FX data — identified as the best keyless FX source. Finnhub free tier is US-only and key-required. Twelve Data free tier is key-required (8/min, 800/day). exchangerate.host now requires a key. Yahoo's unofficial API carries ToS risk and is excluded. NewsAPI.org's free tier is developer/non-commercial only, has a 24-hour delay, and is restricted to localhost CORS — it cannot be shipped. GDELT is free, keyless, and commercially usable — identified as the best shippable news source. Marketaux free tier is key-required (~100/day).

**Corrected realized choice for this phase (J-011)**: live, keyless integration with Frankfurter (FX) and GDELT (news), restricted by CSP `connect-src` to exactly those two origins, with all other network access denied. Bundled offline demo fixtures shaped like Frankfurter and GDELT responses serve as the graceful fallback whenever the network is unavailable or a live fetch fails. No user-configured or paid API keys at any point. Fallback-path data continues to carry the design system's demo/offline labeling; live-path data carries appropriate source attribution instead. This corrects the prior "fixtures only, zero network calls" wording, which was an over-narrowing introduced during initial planning and did not reflect the user's approved Scope A option (a) as originally worded. The user may confirm or veto this interpretation (restricting the panel to fixtures-only) at final plan approval; see Section 8.3.

### 4.7 Tauri v2 + Rust architecture guidance

- Tauri v2 is stable and mature (2.9.x line at research time).
- SQLite integration options considered: `rusqlite` (bundled, synchronous, backend-only), `sqlx` (async, compile-time-checked queries), and `tauri-plugin-sql` (exposes SQL to the frontend). Recommendation: `rusqlite` with the `bundled` feature, with the connection held in Tauri `State` (a `Mutex<Connection>` or an `r2d2` pool), all SQL confined behind `#[tauri::command]` functions, and heavy queries dispatched via `spawn_blocking`. This keeps SQL out of the webview and avoids a system SQLite dependency on Windows.
- The database file belongs in the OS app-data directory resolved through the Tauri v2 path API (created if missing), not a hardcoded path. This directory's exact location and its implication for rollback are corrected in Section 11 (J-009).
- Async commands should return `Result<T, E: Serialize>` with a custom error enum so failures surface to the webview as rejected promises rather than silent failures.
- Frontend: a lightweight framework (vanilla + Vite, or Svelte + Vite) is preferred over React for a heavy SVG/animation-driven UI. Dev/build via `npm run tauri dev` / `npm run tauri build`.
- Content-Security-Policy guidance: `default-src 'self'`; self-host fonts (`font-src 'self'`, no CDN); `img-src 'self' data:` to allow inline SVG; prefer `style-src 'self'` with hashes/nonces over `unsafe-inline`; avoid `unsafe-eval` entirely; `connect-src` restricted to exactly the Frankfurter and GDELT origins per Section 4.6 (J-011).
- Windows toolchain: MSVC build tools, `rustup` `stable-msvc`, WebView2 (already satisfied on Windows 11); confirm the exact MSRV against the pinned Tauri version.
- **Dependency approval is a single gate**, reconciled and fully stated in Section 8.3 (J-010). No section of this plan implies auto-approval of any crate or package; every dependency listed anywhere in this plan, including in this subsection, is a proposal pending that one gate.

## 5. Design route and handoff

**Design route**: Studio (profile = studio; justified by greenfield scope, brand-critical presentation, and a novel Antikythera concept). Model tier used for synthesis: Fable (Design Director). One guarded, disposable prototype was created under `.design/prototypes/calculator-financial-tauri-8/`. That prototype is disposable design evidence only — it must not be copied into production code without normal engineering implementation and verification.

**Selected direction**: NOVEL — "The Mechanism Computes." The full `DESIGN_HANDOFF` (design brief, UX spec, visual-system spec, both motion/asset spec scopes, engineering invariants, permitted variation, and browser-validation brief) is held in the Planner chain and is unchanged by this remediation revision. Findings J-006 and J-007 only make the passed handoff's invariants concrete as acceptance checks; they do not alter the design itself. This plan carries forward, verbatim in substance, the engineering invariants the implementation must satisfy.

### 5.1 Engineering invariants (must carry into implementation and verification)

- Central numeric readout contrast ratio ≥ 7:1. Every ring/segment label sits on a solid, non-textured backing plate with contrast ≥ 4.5:1 (the "backing-plate invariant": decorative texture is an `aria-hidden` layer, the backing plate is opaque and solid, and text is never rendered directly over artwork).
- Focus indicator is a dual-tone rectangular bounding-box keyline: an inner 2px `lacquer.950` stroke, a 2px gap, and an outer 2px `focus.100` stroke. Both strokes render together at all times — never arc-following, never motion-dependent. A verified contrast matrix must guarantee at least one tone clears ≥ 3:1 on every surface (`parchment.100`, `amber.500`, `bronze.900`, `bronze.700`, `lacquer.950`). A single-tone or theme-swappable focus indicator is prohibited unless independently re-verified.
- Tabular-lining figures with a slashed zero are used for all numerics; decimal points are vertically aligned; negative numbers carry a literal minus-sign character (never color or parentheses alone). Numeric results re-render as plain text — never as odometer-style or scrolling digit animation.
- Primary navigation is always a plain linear tablist. The radial pattern is confined to the Calculator tab's ring-dial region only.
- No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` dialogs anywhere in the application. Every confirmation uses an app-owned modal (`role="dialog"`, `aria-modal="true"`, focus trap, Escape and an explicit Cancel control, focus restored to the trigger on close, and an accessible name). The only locked-scope modal trigger in this phase is "Delete a history entry" (naming the specific entry); a future "Clear all" action must reuse this same modal pattern. BASIC mode's Clear/AC action requires no confirmation. All field-level errors, including solver error states such as a non-convergent IRR or a divide-by-zero, are shown inline, never via a dialog (this is now also a dual-layer E2E check; see Section 9.3, J-008).
- Ring segment hit regions are at least 24×24 CSS px at their narrowest point (verified for up to 11 segments at a ~256px dial: hub r0–48, Function band r48–88, Mode band r88–128; the tightest chord at 11 segments is ~27.0px, and any segment count ≤ 11 stays clear of the floor). The what-if crank thumb/track hit area is also at least 24×24 CSS px (WCAG SC 2.5.8); decorative skinning must never shrink the underlying interactive hit region of a native range input.
- BASIC-mode keypad buttons are individually keyboard-focusable and activatable via Enter or Space. Typed physical-keyboard entry is a fully supported parallel input path (WCAG SC 2.1.1), fully specified in Section 2.3.
- The flat view is a first-class, permanent equivalent to the radial view, with an identical control-island structure, identical labels, and identical DOM and tab order — the two views' DOM order must never diverge. The authoritative focus order is: title → flat-view toggle → nav tablist → Mode selector (one tab stop, arrow-key navigation within) → Function-family selector (one tab stop, arrow-key navigation within) → form fields → what-if crank, then its paired numeric field → Calculate → secondary actions → amortization table.
- At 400% zoom/reflow, the radial ring-dial region is auto-replaced by its flat linear equivalent (not merely scaled down); no two-dimensional scrolling is permitted at any zoom level up to 400%, including within the amortization table.
- Every gear-train/ring motion state has a non-motion text or `aria-live` twin. `prefers-reduced-motion: reduce` removes all rotation, looping, and micro-motion with zero information loss. No motion loops indefinitely at full energy (a streaming animation must downgrade after 4 seconds). One shared `aria-live="polite"` region is the authoritative non-motion twin for all motion states. Concrete strings required for this region are enumerated in Section 5.2 (J-006).
- All decorative SVG is `aria-hidden` and `pointer-events: none`; only plain, token-styled interactive-layer shapes carry ARIA roles and keyboard handlers. SVG is viewBox-based for lossless scaling to 400% zoom. Design tokens are implemented as CSS custom properties, aligned to the DTCG 2025.10 token format across primitive, semantic, and component tiers.
- The FX/news panel's live path carries source attribution; its fixture-fallback path retains the persistent panel-level "demo data / offline" banner and per-row "(demo)" tag that survives scrolling, per the corrected scope in Section 4.6 (J-011).

### 5.2 Accessible semantics — concrete acceptance mapping (J-006; grounded in the passed `DESIGN_HANDOFF`, not a design change)

- The amortization schedule is a native `<table>` with a `<caption>`, `<th scope="col">` column headers, and `scope="row"` period headers. Below the reflow breakpoint, it either keeps table semantics with vertical-only scrolling (no two-dimensional scroll) or switches to a stacked per-row group in which every value carries a programmatic label of the form "Period k — Payment/Principal/Interest/Balance".
- ARIA roles by control: primary navigation uses `tablist`/`tab`; the rings and their flat-view equivalent use `radiogroup`/`radio`; confirmation surfaces use `dialog` with `aria-modal`; the flat-view control uses `switch`; the amortization schedule uses `table`.
- Ring/segment selector key bindings: roving `tabindex`; `Left`/`Up` and `Right`/`Down` move and select the adjacent segment; `Home`/`End` jump to the first/last segment; `Space`/`Enter` commits the selection.
- Reading order equals the authoritative focus order stated in Section 5.1.
- Concrete `aria-live` strings that must be asserted in validation: `"Mode: Financial"`, `"Recalculating IRR, iteration N of M"`, `"IRR calculated: X%"`, `"History entry deleted"`.

## 6. Ordered work

Work is sequenced for test-first (TDD) execution. Each step is independently verifiable. Owner: engineering-fleet (T1, with T2/T3 escalation per standard policy) — **only after explicit user approval of this plan.**

1. **Scaffold**: create a fresh Tauri v2 + Rust project inside `calculator-financial-tauri-8` only (frontend: vanilla+Vite or Svelte+Vite; confirm the toolchain — `stable-msvc`, WebView2, MSRV). Verify: `tauri dev` launches an empty shell window.
2. **Calculation engine (test-first)**: (a) a BASIC algebraic-precedence expression evaluator plus a single memory register, per the full semantics in Section 2.3; (b) a financial module implementing every formula and convention in Sections 4.1-4.3, including the guaranteed-outcome IRR/YTM solver contract (Section 4.2). Write golden-value tests first, against the reproducible vectors in Appendix A. Verify: all Appendix A vectors pass within their stated tolerances, including `2+3x4=14`, the IRR typed-error contract on all-same-sign cash flows, the bond day-count basis (30/360) reference vectors, the DB depreciation salvage floor, and begin/end annuity timing.
3. **Persistence, with the consistency protocol below (J-004)**: `rusqlite` (bundled feature) behind `#[tauri::command]`s, connection held in Tauri `State`, database file in the app-data directory (created if missing; exact path and identifier per Section 11, J-009), WAL mode.
   - Single-writer model. Each saved calculation writes its history row and its append-only event-journal record in **one atomic transaction**.
   - The history table is a queryable projection; the event journal (`event_id` monotonic, timestamp, type, JSON payload) is the append-only audit source from which history is derivable.
   - A `schema_version` table plus ordered forward migrations govern schema evolution.
   - jsonl import is idempotent, keyed by `event_id` (`INSERT OR IGNORE` or an equivalent upsert), preserving the monotonic sequence on reimport.
   - Crash/retry: WAL mode plus transactional writes guarantee atomicity; on startup, run `PRAGMA integrity_check` and resume from the last consistent state.
   - Export produces a read-only, consistent snapshot.
   - Verify: ACID/WAL test, export→import round-trip equality test, truncated-trailing-line tolerance test, and an idempotent-reimport test (reimporting the same jsonl file does not duplicate events) all pass.
4. **IPC streaming, with the correlation and cancellation contract below (J-005)**: Tauri v2 `Channel<T>` for iterative-solver progress (IRR/YTM) and live what-if NPV/amortization recompute; each message is one JSON object, i.e. one jsonl-framed line. Commands return `Result<T, E: Serialize>`.
   - Every what-if/solver invocation carries a monotonic `request_id` (per stream) and an `input_revision`.
   - The backend records the latest `request_id` and cooperatively cancels or supersedes any in-flight computation; the cancellation flag is checked on each solver iteration.
   - Input is debounced at a tunable interval, proposed at 150-250ms (the design prototype used approximately 260ms).
   - Every `Channel` frame carries its originating `request_id`; the frontend rejects or ignores frames whose `request_id` is older than the latest known request (stale-result rejection). A superseded computation either stops emitting or emits a terminal "superseded" frame.
   - Verify: a channel-ordering test passes; a superseded-request test confirms stale frames are rejected by the frontend contract; command errors surface to the webview as rejected promises.
5. **Frontend design-system implementation** of the `DESIGN_HANDOFF` (Section 5): design tokens as DTCG-aligned CSS custom properties; radial rings over a linear DOM plus the flat-view toggle; gear-train motion with a reduced-motion fallback; the backing-plate invariant; the app-owned modal (covering all error states, including solver errors); inline validation; tabular numerals; the accessible semantics in Section 5.2. Self-host fonts; set the CSP, including the `connect-src` restriction to the two allowlisted FX/news origins. Verify: a deterministic no-native-dialog source scan is clean; keyboard, focus, and modal behavior is correct.
6. **Wire up modes**: connect BASIC and FINANCIAL modes to the calculation engine; build the history save/search/tag UI with delete-via-modal; implement the what-if crank (native range input plus drag plus typed field) driving the streaming recompute and its `aria-live` twin.
7. **FX/news panel (corrected scope, J-011)**: implement live, keyless Frankfurter (FX) and GDELT (news) fetches, restricted by CSP `connect-src` to exactly those two origins; implement bundled offline fixtures (Frankfurter/GDELT-shaped JSON or jsonl in app resources) as the fallback when offline or on fetch failure; persistent demo banner and per-row "(demo)" tags on the fallback path, with source attribution on the live path; inline empty/error states with a Retry control.
8. **Test toolchain setup (J-008)**: add the dual-layer validation toolchain — `tauri-driver`, a version-matched `msedgedriver` (matched to the installed WebView2), and `@wdio/tauri-service` plus `webdriverio` (or Selenium) as dev/test dependencies, pending the single dependency-approval gate in Section 8.3.
9. **Validation and launch**: run the full unit suite against Appendix A; run the deterministic no-native-dialog scan; execute the dual-layer validation pass (Section 9.3); obtain an independent Verifier pass; obtain a Browser Validator pass against the rendered webview executing the reproducible journeys in Section 9.2; provide the user a working `tauri dev` session or built app to launch, view, and test.

## 7. Interfaces and data

- **SQLite schema**: a history/calculations table, an append-only event journal table, and a `schema_version` table (fields and consistency protocol as in Section 6, step 3), running in WAL mode, located as specified in Section 11 (J-009).
- **Tauri commands** (backend-owned): `evaluate_basic`, `compute_financial(function, params)`, `save_history`, `search_history`, `delete_history_entry`, `export_jsonl`, `import_jsonl`, `load_fx_data` (live-with-fixture-fallback per Section 4.6), `load_news_data` (live-with-fixture-fallback per Section 4.6); plus streaming commands using `Channel<T>` for solver/what-if progress, each frame carrying `request_id` and `input_revision` per Section 6, step 4. All commands return `Result<T, AppError: Serialize>`.
- **jsonl**: one JSON object per line; the event journal and channel frames share a common shape; import is idempotent and keyed by `event_id`, and must tolerate a truncated trailing line.
- **Frontend/backend contract**: numeric results are transmitted as strings or decimal-safe types to preserve alignment and precision (not native floating-point JSON numbers where precision loss would matter). Progress events follow the shape `{type, request_id, input_revision, iteration?, of?, value?, status}`.

## 8. Locked decisions and assumptions

### 8.1 User-confirmed decisions (locked; not open for reinterpretation)

- Design direction: NOVEL ("The Mechanism Computes").
- FX/news scope: keyless integration, no user-supplied or paid API keys, per Scope A option (a); this plan's Section 4.6/2.1-item-6 interpretation of that scope as "live-keyless-plus-fixture-fallback" is itself a decision the user must confirm or veto at approval (see Section 8.3, item 5).
- BASIC-mode arithmetic model: algebraic operator precedence (`2+3x4=14`), fully specified in Section 2.3.

### 8.2 Safe planner assumptions (flagged; confirm during engineering, not blocking approval)

- `rusqlite` (bundled feature) and a vanilla+Vite or Svelte+Vite frontend are proposed defaults pending engineering confirmation; either is acceptable within this plan's intent.
- BASIC and FINANCIAL modes retain independent, in-progress input state across mode switches.
- The database file lives in the OS app-data directory, not a hardcoded or repository-relative path, per the exact identifier requirement in Section 11 (J-009).
- The open design decisions listed in Section 5's source `DESIGN_HANDOFF` (function-family ARIA pattern, ROI/Break-even segment grouping, exact responsive breakpoints, auto-flat-view reversal behavior, crank step increments, IRR progress determinacy, keypad ARIA pattern) are safe at either resolution and do not require re-approval of this plan.

### 8.3 Decisions requiring explicit user confirmation at approval (single dependency-approval gate plus all open decisions)

This section is the single, reconciled gate for every dependency and every open decision in this plan. No other section of this plan should be read as pre-authorizing a dependency or a convention default; where another section proposes one, it is a proposal awaiting confirmation here.

1. **Declining-balance switch-to-straight-line behavior** (J-003): proposed default is pure DDB with no switch, matching the Appendix A vector. **Confirmed at approval (2026-07-15)**: locked in as proposed — pure DDB depreciation with no switchover to straight-line.
2. **Default bond day-count basis** (J-003): proposed default is 30/360 (basis 0), with actual/actual available as a selectable alternative. **Confirmed at approval (2026-07-15)**: locked in as proposed — default 30/360, with actual/actual available as a selectable option.
3. **NPV/MIRR timing convention** (J-003): proposed default is `CF_0`-at-`t=0`, undiscounted, distinct from Excel's `NPV()` convention. **Confirmed at approval (2026-07-15)**: locked in as proposed — `CF_0` at `t=0` is undiscounted.
4. **Tauri bundle identifier** (J-009): a unique, locked, reverse-DNS bundle identifier must be set in `tauri.conf.json` so this application's app-data directory cannot collide with any sibling `calculator-*` app's data. Proposed example: `com.rhasselbach.calc-financial-tauri8`. The exact string is a user/planner decision and requires confirmation before scaffolding (Section 6, step 1). **Confirmed at approval (2026-07-15)**: the standard reverse-DNS identifier as specified in this plan is approved with no change requested.
5. **FX/news live-vs-fixtures interpretation** (J-011): this plan interprets the approved Scope A option (a) as live-keyless-plus-fixture-fallback (Section 4.6). The user may confirm this interpretation or veto it in favor of the originally-drafted fixtures-only, zero-network-call scope. **Confirmed at approval (2026-07-15)**: locked in as live, keyless Frankfurter FX plus GDELT news, with bundled offline fixtures as the fallback — not a fixtures-only, zero-network-call scope.
6. **Proposed dependency set** (J-010), pending approval, no dependency is added without it:
   - **Rust**: `tauri` (v2) and `tauri-build`; `serde` and `serde_json`; `rusqlite` (bundled feature; optionally `r2d2` plus `r2d2_sqlite` for pooling); `rust_decimal` for financial precision, or a documented `f64`-plus-rounding approach if declined; `thiserror`; `time` or `chrono` for bond dates and day-count calculations; `reqwest` (with the `rustls-tls` feature) for the live keyless FX/news calls, plus `tokio` if async runtime support is needed.
   - **Dev/test**: `tauri-driver`, `@wdio/tauri-service`, `webdriverio`, and a version-matched `msedgedriver` (Section 9.3, J-008).
   - **Frontend**: `vite`, with `svelte` as an optional addition.
   - **Confirmed at approval (2026-07-15)**: the dependency/crate list above is approved as specified in this plan; no separate sign-off list was requested.
7. This plan in its entirety, including the ordered work in Section 6. **Confirmed at approval (2026-07-15)**: the plan is approved in its entirety.

## 9. Acceptance and validation

### 9.1 Correctness gates

- Every formula and convention in Sections 4.1-4.3 is validated against the reproducible, tolerance-bounded vectors in Appendix A (J-001).
- **Locked**: BASIC operator precedence, `2+3x4=14` (Section 2.3).
- IRR/YTM validated against the typed-error solver contract in Section 4.2, including the all-same-sign no-bracket case and the multiple-sign-change non-uniqueness flag with an MIRR cross-check.
- Bond clean/dirty pricing correct for the selected day-count basis, validated against the authoritative Microsoft PRICE/YIELD reference vectors in Appendix A; DB depreciation respects the salvage floor; TVM respects the sign convention, the P/YR convention, and begin/end annuity timing (Section 4.3).
- SQLite WAL/ACID transaction test; jsonl truncated-trailing-line tolerance test; export/import round-trip equality test; idempotent-reimport test; channel progress-ordering and stale-frame-rejection tests (Section 6, steps 3-4).

### 9.2 Browser journeys (J-007; reproducible test cases, tied to Appendix A)

Each journey below states its initial state, inputs, and expected outputs. All numeric expectations are tied to the Appendix A test-vector tolerances.

- **J1 / J1b — Mode switch, radial and flat parity**: from the default radial Calculator tab, switch Mode from Basic to Financial and back; repeat identically in flat view. Expected: identical control-island structure, labels, and DOM/tab order in both views; no state loss on switching.
- **J2 — Basic calculation and typed entry**: type `2+3*4=` via the on-screen keypad. Expected: display shows `14`. Type `8/0`. Expected: inline "Error: divide by zero" state, no dialog, no crash.
- **J3 — Loan calculation, amortization, and persistence**: starting from an empty Financial form, enter Loan Amount `100000`, Rate `6`, N `360`, P/YR `12`, End mode. Press Calculate. Expected: PMT displays as `599.55`. Open the amortization schedule. Expected: row 1 shows Interest `500.00`, Principal `99.55`, Balance `99900.45`. Save to history. Close and relaunch the app. Expected: the saved entry is present in history.
- **J4 — What-if crank**: drive the what-if crank via drag, via arrow-key input, and via the paired typed numeric field. Expected: each input method produces the same recompute result; streaming progress strings appear in the shared `aria-live` region per Section 5.2, and stale/superseded frames are not displayed (Section 6, step 4).
- **J5 — History search**: with 3 saved history entries, search for "loan". Expected: results panel shows "Showing 1 of 3".
- **J6 — FX/news demo and live states**: with network access available, the panel shows live Frankfurter/GDELT data with source attribution and no "(demo)" tag; with network access blocked or a fetch forced to fail, the panel falls back to bundled fixtures, shows the persistent "demo data / offline" banner, and tags each row "(demo)".
- **J7 — Flat-view toggle preserves state**: enter values into a partially completed Financial form in radial view, toggle to flat view. Expected: every entered field value is preserved and displayed identically in flat view.
- **J8 — Delete-entry modal**: from a history list, trigger "Delete a history entry" on a named entry. Expected: the app-owned modal opens with focus trapped inside it, names the specific entry, Escape closes it as Cancel, and focus restores to the triggering element on close.

### 9.3 Dual-layer validation (J-008; browser-only validation is insufficient for a Tauri app)

- **Layer 1 — Chrome tab against the Vite dev server**: frontend rendering, responsive viewport behavior, accessibility checks (Section 5.2), a deterministic no-native-dialog scan of the built bundle, and app-owned-modal keyboard/focus tests. This layer cannot exercise IPC, persistence, WebView2 behavior, or the packaged binary, and must not be treated as sufficient on its own.
- **Layer 2 — Tauri WebDriver E2E (required)**: `tauri-driver` plus a version-matched Microsoft Edge WebDriver (`msedgedriver`, matched to the installed WebView2 version; `@wdio/tauri-service` auto-detects and downloads a matching driver) plus WebdriverIO (or Selenium), driving the actual Tauri application window and webview. This layer asserts: `invoke`/IPC command results; `Channel` streaming ordering and stale-frame rejection; SQLite persistence across an app close/relaunch cycle against the same app-data directory (Section 11); and that error paths (an all-same-sign IRR input, a divide-by-zero in Basic mode) raise the app-owned modal or inline error state, never a native dialog.
- **Network assertion caveat**: Rust-side `reqwest` calls bypass webview network interception, so the network-assertion portion of the E2E pass must run either fully offline or against a localhost mock / deny-by-default proxy, asserting the graceful fixture fallback described in Section 4.6. Playwright-over-CDP is a viable Windows-only secondary validation path for Layer 1-style checks.
- The dual-layer toolchain (`tauri-driver`, `msedgedriver`, `@wdio/tauri-service`, `webdriverio`) is added to the approval-gated test toolchain in Section 8.3, item 6.
- **Corrected network check (J-011)**: the browser-validation network assertion is updated from "zero outbound network requests" to "outbound requests limited to the two allowlisted keyless hosts (Frankfurter, GDELT), with a tested offline-to-fixture-fallback path" (Section 4.6, Section 9.2 J6).

### 9.4 `browser_ui_validation` inputs

- Launch/readiness command: `npm run tauri dev` (or `cargo tauri dev`) reaching a ready application window, or the equivalent built app.
- Base URL/window target for Layer 1: the Tauri application window (a Vite dev-server localhost origin rendered behind the webview). Layer 2 targets the actual Tauri window via `tauri-driver`.
- Fixture/reset procedure: delete or reinitialize the app-data directory described in Section 11 to deterministically reset history; FX/news fixtures are static bundled resources used automatically on offline/failed-fetch fallback and require no reset.
- Journeys: J1/J1b through J8, as specified in Section 9.2.
- Viewport profiles: 1024×768 (radial default), ~900px (single-column reflow), <960px (flat-view auto-switch), and 400% zoom.
- Visible outcomes: as enumerated in Sections 9.1-9.3, including the corrected network-request check.

### 9.5 Verification gate order

An independent Verifier pass is required first; a Browser Validator pass executing the dual-layer validation in Section 9.3 is required second. Neither writer output nor judge output alone constitutes a completion claim.

## 10. Browser UI dialog policy

This policy is required and strict for this Tauri webview application. Prohibited without exception: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts. Required: an app-owned accessible modal (`role="dialog"`, `aria-modal="true"`, `aria-labelledby`, focus trap, Escape triggers Cancel, Cancel receives initial focus, focus restores to the trigger on close) for the single locked-scope trigger, "Delete a history entry." All input validation errors, including calculation-engine error states (a non-convergent or non-unique IRR, a divide-by-zero in Basic mode), are shown inline, never via a dialog. The deterministic no-native-dialog source scan and the modal keyboard/focus tests are hard acceptance gates (Section 9), now verified at both validation layers (Section 9.3).

## 11. Risks and rollback

| Risk | Severity | Mitigation |
|---|---|---|
| Financial calculation correctness | High | Golden-value TDD against the reproducible, tolerance-bounded vectors in Appendix A, including authoritative bond PRICE/YIELD reference vectors and a guaranteed-outcome IRR/YTM solver contract (Section 4.2). This plan carries forward the researcher's caveat: professional review is required before shipping financial calculations to real users. |
| Radial-UI discoverability and data entry | Medium | First-class flat-view equivalent with persistent text readouts. The prototype pass confirmed accessibility mechanics but flagged discoverability as a concern for later user testing, not a blocking defect. |
| Accessibility regressions in the novel radial pattern | Medium | The enumerated engineering invariants and concrete accessible-semantics mapping (Sections 5.1-5.2) plus the mandatory dual-layer validation gate (Section 9.3). The ~27px worst-case hit-target chord is tight; the recommendation is to hard-floor the rendered dial diameter in implementation. |
| Toolchain/dependency mismatch | Low–Medium | Confirm MSRV and WebView2 compatibility, and the matching `msedgedriver` build, before scaffolding; every dependency addition requires explicit user approval through the single gate in Section 8.3. |
| Data licensing/ToS exposure | Low | Mitigated by restricting live network access to exactly two keyless, commercially-usable, ToS-compatible hosts (Frankfurter, GDELT) via CSP `connect-src`, with an offline fixture fallback (Section 4.6). |
| Persistence and journal inconsistency between the SQLite history table and the event journal | Low–Medium | Single-writer, single-transaction writes; idempotent, `event_id`-keyed jsonl import; `PRAGMA integrity_check` on startup (Section 6, step 3). |
| IPC race conditions between overlapping what-if/solver requests | Low–Medium | `request_id`/`input_revision` correlation, cooperative cancellation, and stale-frame rejection on the frontend (Section 6, step 4). |

### 11.1 Rollback and containment (corrected, J-009)

The application's SQLite database does **not** live inside the project folder. It lives in the OS app-data directory at `%APPDATA%\<bundle-identifier>\calculator.db`, where `<bundle-identifier>` is the exact reverse-DNS string locked in `tauri.conf.json` (Section 8.3, item 4; proposed example `com.rhasselbach.calc-financial-tauri8`, pending confirmation). Deleting the project folder alone does **not** remove this data.

**Corrected rollback procedure**: delete the project folder `calculator-financial-tauri-8` **and** remove the app-data directory for that project's unique bundle identifier. Locking a unique identifier before scaffolding (Section 6, step 1) also guarantees this application's app-data directory cannot collide with any sibling `calculator-*` app's data, preserving the no-touch boundary in Section 2.2 even at the data-directory level.

**Stale-plan condition**: this plan becomes stale if requirements, the chosen dependency set, the Tauri/Rust MSRV, the bundle identifier, or the research facts in Section 4 or Appendix A materially change. A stale plan requires replanning or explicit reapproval before any further engineering edits continue against it.

## 12. Judge route (selective, advisory only)

Per `docs/JUDGE-CONTRACT.md`, cross-vendor judgment is selective and advisory, never a substitute for deterministic verification. This plan has already received one `PLAN_DUCK` checkpoint pass, whose 12 shadow findings (J-001 through J-012) are remediated in this revision (Appendix B). Recommended remaining checkpoints:

- An optional follow-up `PLAN_DUCK` checkpoint on this revised plan, at the orchestrator's discretion, before requesting user approval. Findings remain advisory shadow findings; deterministic failures (missing sections, unresolved contradictions) always dominate over any judge opinion.
- An optional `VISUAL_REVIEW` checkpoint at the browser-validation stage (Section 9), covering the themed radial/flat UI.

Exact rubric IDs, call caps, and shadow-vs-blocking policy are left to the orchestrator's judgment at dispatch time, respecting the standard call caps in `docs/JUDGE-CONTRACT.md`. Codex judgment is never used as implementation or as a substitute for deterministic validation.

## 13. Engineering mode and downstream ownership

- **Engineering mode**: standard — sequential T1 engineering-fleet work after approval. The work is large but cleanly decomposable (Section 6); no coupling requires an extreme-advisory team.
- **Team authorization**: not applicable to this plan.
- **Downstream owner**: engineering-fleet, and only after explicit user approval of this plan. The approved plan path becomes `ENGINEERING_JOB.approved_plan`.

## 14. Approval gate

This plan's Status line (top of file) reads **Approved**, effective 2026-07-15, approved by the user via the orchestrator. All six items enumerated in Section 8.3 were explicitly confirmed at approval, as recorded inline in that section: declining-balance depreciation is pure DDB with no straight-line switchover; the default bond day-count basis is 30/360 with actual/actual available as a selectable option; NPV/MIRR timing treats `CF_0` as undiscounted at `t=0`; the standard reverse-DNS bundle identifier as specified in this plan is approved with no change; the FX/news scope is live, keyless Frankfurter FX plus GDELT news with offline fixtures as fallback (not fixtures-only); and the proposed dependency/crate list is approved as specified. The approved plan path is `docs/plans/calculator-financial-tauri-8.md`, which becomes `ENGINEERING_JOB.approved_plan` for the engineering fleet.

## Appendix A: Financial test vectors (J-001)

All vectors are reproducible from the formulas and conventions in Sections 4.1-4.3. Rounding defaults: currency figures to 2 decimal places; rates to 6 decimal places, unless a tighter tolerance is stated below.

- **TVM, solve for PMT**: `PV=100000, i=0.06/12=0.005, N=360, FV=0, END` → `PMT = 599.55` (±0.01).
- **TVM, solve for N**: `PV=100000, i=0.005, PMT=700, FV=0` → `N = 251.18` months (±0.01).
- **TVM, solve for I%**: `PV=100000, N=360, PMT=599.55, FV=0` → `i = 0.005` / `6.0000%` annual (±1e-4). Included as an inverse-consistency check against the solve-for-PMT vector above.
- **NPV**: `CF0=-1000, CF1..CF5 = 100, 200, 300, 400, 500, r=10%` → `65.26` (±0.01).
- **IRR** (same cash-flow series as the NPV vector) → `12.01%` (±1e-4). Verify `NPV(12%) = +0.18` and `NPV(13%) = -30.24` as consistency checks.
- **MIRR** (same series; finance rate 10% on outflows, reinvestment rate 12% on inflows, `n=5`) → `12.00%` (±1e-4).
- **Bond PRICE** (authoritative reference: Microsoft `PRICE` function documentation): settlement `2008-02-15`, maturity `2017-11-15`, coupon `5.75%`, yield `6.50%`, redemption `100`, frequency `2` (semiannual), basis `0` (US 30/360) → `94.63` per 100 face, reproducible to 5 decimal places (≈`94.634`) (±0.01).
- **Bond YIELD** (authoritative reference: Microsoft `YIELD` function documentation): settlement `2008-02-15`, maturity `2016-11-15`, coupon `5.75%`, price `95.04287`, redemption `100`, frequency `2`, basis `0` → `0.065` / `6.5%` (±1e-4).
- **Depreciation** (cost `10000`, salvage `1000`, life `5`):
  - SL: `1800/yr`; book value by year-end: `8200 / 6400 / 4600 / 2800 / 1000`.
  - 200% DB with salvage floor: annual depreciation `4000 / 2400 / 1440 / 864 / 296` (year 5 is floored so book value ends at `1000`).
  - SYD: annual depreciation `3000 / 2400 / 1800 / 1200 / 600`; book value by year-end: `7000 / 4600 / 2800 / 1600 / 1000`.
  - All depreciation figures ±0.01.
- **APR/EAR**: nominal `12%` compounded monthly → `EAR = 12.6825%` (±1e-6); verify the inverse conversion recovers nominal `12%`.

**Provenance note**: the bond PRICE and YIELD vectors are drawn from authoritative Microsoft spreadsheet-function reference documentation and are considered high-confidence external references. The TVM, NPV, IRR, MIRR, depreciation, and EAR vectors are computed-and-reproducible from the stated formulas and conventions in Sections 4.1-4.3; they have not been independently cross-checked against page-level HP-12C or TI BA II Plus worked examples. The researcher's caveat applies to this entire appendix: professional review is required before shipping any of these financial calculations to real users. Where actual/actual bond day-count vectors are needed (Section 4.3), no vector is yet supplied; this is an open validation item, not a passing test.

## Appendix B: Judge remediation (`PLAN_DUCK`)

The following 12 advisory shadow findings from a `PLAN_DUCK` checkpoint pass were remediated in this revision. Each finding is addressed by folding its substance into the relevant plan section; this appendix is the cross-reference, not a duplicate specification.

| Finding | Addressed in |
|---|---|
| J-001 — Financial test vectors, cited and reproducible, with tolerances | Appendix A; referenced from Sections 4.1, 6 (step 2), 9.1, 9.2 |
| J-002 — Robust, guaranteed-outcome IRR/YTM solver contract | Section 4.2; referenced from Sections 4.1, 6 (step 2), 9.1 |
| J-003 — Precise conventions (P/YR, annuity-due, zero-rate branch, bond dirty/clean and day-count, SYD/DB period formulas, NPV/MIRR timing) plus three decisions for approval | Section 4.3; decisions carried into Section 8.3, items 1-3 |
| J-004 — SQLite/jsonl journal consistency protocol | Section 6, step 3; referenced from Section 4.5, Section 7 |
| J-005 — Streaming correlation and cancellation contract | Section 6, step 4; referenced from Section 4.5, Section 7 |
| J-006 — Accessible reflow/SR semantics as concrete acceptance checks | Section 5.2; referenced from Section 5.1, Section 9.1 |
| J-007 — Browser journeys J1-J8 rewritten as reproducible test cases | Section 9.2 |
| J-008 — Dual-layer validation approach (Chrome/Vite plus Tauri WebDriver E2E) | Section 9.3; toolchain in Section 6 (step 8) and Section 8.3, item 6 |
| J-009 — Rollback correction: app-data directory location and unique bundle identifier | Section 11.1; decision carried into Section 8.3, item 4 |
| J-010 — Single reconciled dependency-approval gate with a proposed crate list | Section 8.3, item 6; referenced from Section 4.7, Section 6 (step 8) |
| J-011 — FX/news scope correction to live-keyless-plus-fixture-fallback | Section 2.1 item 6, Section 4.6, Section 5.1, Section 9.3, Section 9.2 (J6); decision carried into Section 8.3, item 5 |
| J-012 — Fully specified BASIC-mode arithmetic semantics | Section 2.3; referenced from Section 2.1 item 2, Section 4.4, Section 5.1, Section 6 (step 2), Section 9.1, Section 9.2 (J2) |
