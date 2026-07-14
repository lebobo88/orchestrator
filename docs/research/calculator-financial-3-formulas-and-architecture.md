---
title: "calculator-financial-3: advanced financial formulas, SQLite+JSONL streaming architecture, and Antikythera GUI approach"
slug: calculator-financial-3-formulas-and-architecture
profile: standard
mode: technical-documentation + architecture (dual-mode, per user request)
status: ready
created: 2026-07-13
updated: 2026-07-13
---

# calculator-financial-3: formulas, persistence/streaming architecture, and Antikythera GUI approach

## Executive summary

**What.** This report extends `docs/research/calculator-financial-2-formulas.md` [S-PRIOR] with eight additional advanced financial formulas (bond pricing, straight-line and declining-balance depreciation, CAGR, effective annual rate vs. nominal rate, payback period, WACC, and the annuity-due/ordinary-annuity distinction), specifies a decisive SQLite+JSONL persistence/streaming architecture for a single-user local desktop app, and recommends a concrete Python GUI toolkit and technique for an Antikythera-mechanism-themed dial/gear interface.

**So what.** All 18 formulas (10 carried over + 8 new) are closed-form or simply-iterative, need no live market data, and are independently implementable/testable — consistent with the user's confirmed exclusions (no tax, no live data, no personalized advice, no multi-user/networked features). The architecture question ("stream events via JSONL, persist in SQLite") has more than one plausible interpretation; this report picks one decisive pattern — an in-process append-only JSONL audit log paired with a single SQLite writer as the canonical queryable store — and states why the alternatives (JSONL over IPC, JSONL as periodic export) are rejected for this scope. The GUI question is resolved in favor of Tkinter's `Canvas` (stdlib, zero new dependency, sufficient for concentric rings/gear-like rotation) over PySide6/QGraphicsView (materially higher graphics fidelity but a heavier dependency and learning-curve cost not justified for a single bounded implementation pass).

**Now what.** `t1-engineer` can implement all 18 calculator functions, wire calculation results through the recommended dual JSONL+SQLite pipeline, and build the Antikythera-styled UI on Tkinter `Canvas`, using the module/threading/schema guidance under Validation measures and the Assumptions/unknowns section below. No further architectural research should be required before implementation.

This report uses combined **technical-documentation** mode (Part A: formula reference) and **architecture** mode (Part B: persistence/streaming; Part C: GUI toolkit selection), per the user's explicit request for a dual-mode report, rather than forcing everything into one template.

## Scope and exclusions (user-confirmed)

- In scope: basic mode (plain arithmetic: +, −, ×, ÷, no scientific functions); financial mode with the 10 formulas from the prior report **plus** 8 additional advanced formulas specified below; SQLite persistence; JSONL event streaming between UI and persistence layer; Antikythera-mechanism visual theme (dials, gears, concentric rings) in the GUI.
- Out of scope (unchanged from prior report, reconfirmed): tax calculations, live/current market data, personalized investment advice, multi-user/networked features, retirement/annuity planning beyond the savings-goal/annuity formulas already covered, inflation adjustment, full Regulation Z APR computation.
- Target stack: Python; SQLite (stdlib `sqlite3`); JSONL for event logging; GUI toolkit selected in Part C.

---

## Part A — Advanced financial formulas for "financial mode" (technical-documentation mode)

The prior report's 10 formulas (simple interest, compound interest, future value, present value, loan/mortgage payment, amortization schedule, ROI, savings goal, break-even, NPV/IRR) remain valid and are incorporated by reference — see `docs/research/calculator-financial-2-formulas.md` for their full formulas, variable definitions, and edge cases. They are not repeated here to avoid duplication/drift; `t1-engineer` should treat both files as the combined formula spec for calculator-financial-3.

### 11. Bond pricing (present value of a coupon bond)

**Formula:** `Price = Σ [ C / (1+r)^t ]` for `t = 1..N`, plus `F / (1+r)^N`

- `C` = coupon payment per period = `(annual coupon rate × face value) / payments per year`
- `F` = face value (par value) of the bond
- `r` = discount rate per period = `yield to maturity / payments per year`
- `N` = total number of coupon periods = `years to maturity × payments per year`
- `Price` = present value of all future coupons plus the discounted face value [S13][S14]

**Edge cases:**
- If `r = 0`, price simplifies to `Price = Σ C + F` (no discounting) — must not divide by zero; `(1+0)^t = 1` handles this naturally.
- Semiannual coupons are the U.S. market convention; hardcode or expose payments-per-year as a dropdown (1, 2, 4, 12) rather than free text, mirroring the loan calculator's `n` pattern from the prior report.
- If `coupon rate = yield`, `Price = Face Value` exactly (par bond) — a useful built-in sanity check for testing.
- **Not in scope:** accrued interest / clean vs. dirty price distinction, credit-spread modeling, or duration/convexity — these are natural but excluded extensions unless the user requests them later.

### 12. Straight-line depreciation

**Formula:** `Annual Depreciation = (Cost − Salvage Value) / Useful Life (years)`

- `Cost` = original asset cost
- `Salvage Value` = estimated residual value at end of useful life (can be 0)
- `Useful Life` = depreciable life in years (positive integer)
- Output: a constant per-year depreciation amount, optionally expanded into a year-by-year schedule (`Book Value_t = Cost − t × Annual Depreciation`) [S15][S16]

**Edge cases:**
- Reject `Useful Life <= 0`; reject `Salvage Value > Cost` (would produce negative depreciation).
- `Salvage Value = Cost` is valid and yields zero depreciation — not an error.
- Book value must never be displayed below `Salvage Value` due to rounding; clamp the final year's book value to exactly `Salvage Value`.

### 13. Declining-balance depreciation (including double-declining balance)

**Formula (per year `t`):** `Depreciation_t = Book_Value_(t-1) × Rate`, where `Rate = Multiplier / Useful Life` (Multiplier = 2 for "double-declining balance", the most common variant; user-adjustable multiplier is a reasonable "advanced" option) [S15][S17]

- `Book_Value_0 = Cost`
- `Book_Value_t = Book_Value_(t-1) − Depreciation_t`
- Depreciation is **not** applied against salvage value directly each year; instead the schedule stops reducing book value once it reaches `Salvage Value` (a standard implementation rule, since unconstrained declining-balance never reaches exactly zero).

**Edge cases:**
- **Switch-to-straight-line convention:** many real-world schedules switch to straight-line depreciation partway through the asset's life once straight-line would produce a larger deduction than the declining-balance amount for that year, to fully depreciate to salvage value by the end of the useful life [S17]. Document this as an **optional refinement**; the simpler, decisive default for this app is: apply the declining-balance rate each year and **floor** `Book_Value_t` at `Salvage_Value` (stop depreciating once the floor is reached), which is simpler to implement correctly and avoids under/over-depreciation bugs. State this simplification explicitly in the UI/help text.
- Reject `Multiplier <= 0` and `Useful Life <= 0`.
- If `Rate >= 1` (e.g., multiplier too high relative to useful life), the first year's depreciation could exceed `Cost − Salvage Value`; clamp `Depreciation_t` to not reduce `Book_Value_t` below `Salvage Value`.

### 14. Compound Annual Growth Rate (CAGR)

**Formula:** `CAGR = (Ending Value / Beginning Value)^(1/n) − 1`

- `Beginning Value` = starting value (> 0)
- `Ending Value` = ending value (> 0)
- `n` = number of years/periods between the two values (> 0)
- `CAGR` = implied constant annual growth rate [S18][S19]

**Edge cases:**
- Reject `Beginning Value <= 0` (division by zero / undefined for non-positive base); if `Ending Value <= 0`, the formula is mathematically defined only for specific `n` values (fractional powers of negative numbers are undefined in real arithmetic) — reject `Ending Value <= 0` with a validation message rather than raising a `ValueError`/`complex` result.
- `n` must be a positive number (can be fractional, e.g., 2.5 years) — reject `n <= 0`.
- CAGR smooths volatility; note in UI copy that it is not the same as the arithmetic average of period-by-period growth rates (a common user misconception) — an informational label only, not a new calculator.

### 15. Effective Annual Rate (EAR) vs. nominal (stated) rate

**Formula:** `EAR = (1 + i/n)^n − 1`

- `i` = nominal (stated) annual interest rate, decimal
- `n` = number of compounding periods per year
- `EAR` = effective annual rate, decimal — the true annualized rate once compounding is accounted for [S20][S21]
- Continuous-compounding variant (optional, consistent with the compound-interest calculator's optional continuous-compounding note in the prior report): `EAR = e^i − 1`

**Edge cases:**
- `n = 1` returns `EAR = i` (no compounding effect) — a useful built-in sanity check.
- This calculator is a natural companion/cross-check to compound interest (#2) and loan payment (#5) from the prior report — it lets a user compare a "6% compounded monthly" loan or deposit against a "6.1% compounded annually" alternative on a like-for-like basis. Consider surfacing it as a labeled sub-feature next to those calculators rather than only as a standalone entry, though a standalone entry also satisfies the requirement.
- Validate `n` is a positive integer (reuse the same dropdown pattern as compound interest's `n`).

### 16. Payback period

**Formula (even/uniform cash flows):** `Payback Period = Initial Investment / Annual Cash Flow`

**Formula (uneven cash flows, standard interpolated method):** `Payback Period = A + (B / C)`, where `A` = last period with cumulative cash flow still negative, `B` = absolute value of the cumulative cash flow at the end of period `A`, `C` = cash inflow during the period immediately following period `A` [S22][S23]

- Input: `Initial Investment` (positive) and either a single `Annual Cash Flow` (even case) or a cash-flow series (uneven case, sharing the same input schema as NPV/IRR #10 from the prior report)
- Output: payback period in years (can be fractional via the interpolation formula)

**Edge cases:**
- If cash flows never cumulatively recover the initial investment (cumulative sum stays negative through all provided periods), payback period is undefined — return "payback not achieved within the given cash-flow horizon" rather than a misleading extrapolated number.
- This calculator **ignores the time value of money** by design (that is the standard definition of simple payback period) — label it clearly so users do not confuse it with a discounted-payback or NPV-based metric; a discounted-payback variant is a reasonable but out-of-scope extension unless requested.
- Reuse the cash-flow list input UI from NPV/IRR (#10) to avoid a second bespoke input widget, since both consume the same "series of periodic cash flows" schema.

### 17. Weighted Average Cost of Capital (WACC)

**Formula:** `WACC = (E/V) × Ke + (D/V) × Kd × (1 − Tax Rate)`

- `E` = market value of equity (user-entered)
- `D` = market value of debt (user-entered)
- `V = E + D` (total capital)
- `Ke` = cost of equity, decimal (user-entered — this app does not compute CAPM/beta-derived cost of equity, consistent with "no live market data")
- `Kd` = pre-tax cost of debt, decimal (user-entered)
- `Tax Rate` = corporate tax rate, decimal (user-entered; this is a WACC input, not a "tax calculation" feature — distinct from the excluded personal/corporate tax-calculation scope) [S24][S25]

**Edge cases:**
- Reject `E < 0`, `D < 0`, or `E + D = 0` (division by zero — at least one of equity or debt must be positive).
- `Tax Rate` should be validated to a sane range (0–1 as a decimal, i.e., 0%–100%); values outside this range are almost certainly a percent/decimal input mistake (same recurring UI pattern flagged in the prior report for interest-rate fields).
- **Scope boundary (important):** WACC here takes `Ke` and `Kd` as direct user inputs. It explicitly does **not** compute cost of equity via CAPM (which would require a risk-free rate, beta, and market risk premium — arguably "live market data" inputs) or cost of debt from a bond's current market yield. This keeps WACC consistent with the confirmed "no live market data" exclusion; document this boundary in the UI/help text so users do not expect an auto-populated cost of equity.

### 18. Annuity due vs. ordinary annuity (a labeled input option on the savings-goal / annuity family, not a new standalone calculator)

**Formula relationship:** `Value_annuity_due = Value_ordinary_annuity × (1 + r)`, applied to either the present-value or future-value annuity formula [S26][S27]

- Ordinary annuity: payments occur at the **end** of each period (this is the convention already used by the savings-goal calculator, #8, in the prior report).
- Annuity due: payments occur at the **start** of each period (e.g., rent, insurance premiums typically paid in advance); every ordinary-annuity PV or FV result is converted to its annuity-due equivalent by multiplying by `(1 + r)`, where `r` is the periodic rate.

**Recommendation:** rather than adding a fully separate 19th calculator, expose an explicit **"Payment timing: End of period (ordinary) / Start of period (due)"** selector on the existing savings-goal calculator (#8) and apply the `(1+r)` multiplier when "due" is selected. This is the smallest correct implementation of the requested formula without duplicating the underlying annuity math, and it directly resolves the ordinary-vs-annuity-due ambiguity flagged as an unresolved edge case in the prior report (item #8's edge cases).

**Edge cases:**
- `r = 0`: the `(1+r)` multiplier becomes `1`, so ordinary and annuity-due values are identical when the rate is zero — a useful built-in sanity check.
- Default should remain **ordinary annuity** (matches prior report's default and the more common convention for savings-goal tools); "due" is an explicit opt-in, not a silent behavior change.

---

## Part B — SQLite persistence + JSONL streaming architecture (architecture mode)

### The three candidate patterns considered

1. **JSONL as a durable, write-once event log, separately consumed into SQLite by a writer** (event-sourcing style): every calculation produces one JSON object, appended as one line to an on-disk `.jsonl` file; a single writer component also inserts the same event into SQLite for indexed/queryable history. JSONL is the audit trail; SQLite is the query surface. [S28][S29][S30]
2. **JSONL as a transient message format over an IPC channel (socket/pipe/queue) feeding SQLite**, with no durable on-disk JSONL file — JSONL is only ever an in-flight wire format between separate processes.
3. **JSONL as periodic export/snapshot** of the SQLite database's contents (e.g., "Export history to JSONL"), with no role in live streaming — JSONL is a downstream artifact only, not part of the live event path.

### Recommendation (decisive)

**Adopt pattern 1** for calculator-financial-3: an in-process, single-writer producer/consumer pipeline where every calculation event is (a) serialized as one JSON object and appended to an on-disk `history.jsonl` file, and (b) inserted as one row into a SQLite database (`history.db`, WAL mode) by the same writer step, in that order, within one logical operation.

**Concrete shape:**

- **Event schema (JSONL line and SQLite row share the same fields):** `{"ts": <ISO-8601 UTC timestamp>, "mode": "basic"|"financial", "calculator": "<name>", "inputs": {...}, "outputs": {...}, "id": "<uuid4>"}`. A flat, stable top-level schema (timestamp, identifier, calculator name, inputs, outputs) is the pattern found in comparable event-log designs and keeps both the JSONL log and the SQLite table trivially aligned. [S28]
- **UI → persistence direction ("forward" streaming):** when a calculation completes, the UI thread builds the event dict and hands it to a single persistence function/thread. That function appends the JSON line to `history.jsonl` (flush + `os.fsync` optional for durability) and inserts the corresponding row into SQLite in the same call, inside one `try` block; if the SQLite insert fails, the JSONL line has still been durably recorded, and a startup/repair routine can reconcile any SQLite rows missing relative to the JSONL log (JSONL is the source of truth; SQLite is a rebuildable cache/index) [S28][S29].
- **Persistence → UI direction ("backward" streaming, i.e., history/results feed):** the UI's history view reads from **SQLite**, not by re-parsing JSONL, using indexed queries (e.g., `SELECT ... ORDER BY ts DESC LIMIT n`, filter by `calculator` or `mode`). SQLite is the query-optimized read path; JSONL is not re-read for normal UI operation, only for audit/replay/recovery.
- **Concurrency:** because this is a single-user, single-process desktop app, use SQLite's WAL mode (`PRAGMA journal_mode=WAL;` set once, persists in the file header) plus `PRAGMA busy_timeout=5000;` so the one writer and any read queries from the UI thread do not block each other destructively; a single dedicated writer (thread or simple direct call, since there is exactly one process and no external writers) avoids the classic multi-writer SQLite contention problem entirely. [S31][S32]
- **"As needed" streaming, not a message bus:** because the app is single-process, "streaming JSONL between UI and database" is best implemented as an **in-process function call / thread-safe queue**, not a network socket, named pipe, or external message broker. This satisfies the literal request ("stream calculation events using JSONL") using the JSONL *file format* as the durable event representation, without introducing IPC complexity that a single-process desktop app does not need.

### Why the alternatives are rejected here

- **Pattern 2 (JSONL over IPC)** is rejected as unnecessary complexity: there is no multi-process or networked requirement in scope (explicitly excluded: "no multi-user/networked features"), so a socket/pipe layer would add failure modes (connection handling, serialization framing) with no corresponding benefit for a single-process desktop app.
- **Pattern 3 (JSONL as export-only)** is rejected as insufficient: the user asked for events to be "streamed back and forth," implying JSONL is part of the live event path, not merely a batch export format. An export-to-JSONL feature can still be added later as a convenience (e.g., "Export history" button that dumps the SQLite table to JSONL), but that is a distinct, optional feature from the live event log.

**Observation (high confidence):** this recommendation is consistent with an established architectural pattern — durable append-only JSONL/event logs as the source of truth, with a derived, rebuildable SQLite index/cache for queries — documented across event-sourcing and offline-first sync literature [S28][S29][S30]. **Inference (medium-high confidence):** for a single-user local desktop app with no multi-process or networked requirement, the full event-sourcing machinery (idempotency keys, outbox pattern, conflict resolution) referenced in that literature is over-engineering; only the core "durable append log + queryable derived store" idea is adopted, not the multi-process sync machinery, which is unneeded here.

### Risks and tradeoffs `t1-engineer` should know

- **Double-write consistency:** writing to two stores (file + database) in sequence is not atomic across both; if the process crashes between the JSONL append and the SQLite insert, SQLite can lag behind JSONL by at most one event. Mitigate with a lightweight startup reconciliation check (compare last SQLite row's `id`/`ts` against the tail of `history.jsonl`; insert any missing rows) rather than attempting true two-phase commit, which is unnecessary complexity for this scope.
- **File growth:** `history.jsonl` grows unboundedly over the app's lifetime; for a hobby-scope app this is acceptable, but note it as a known limitation rather than silently truncating history (truncation would break the "JSONL is the source of truth" guarantee).
- **WAL mode side files:** WAL mode creates `history.db-wal` and `history.db-shm` alongside `history.db`; these are normal and must not be deleted while the app is running [S32]. Document this so a future cleanup script does not mistakenly delete them.
- **Not a message bus:** if the user later wants multi-machine sync or a networked multi-user mode, this architecture (in-process JSONL+SQLite) would need to be revisited; it is explicitly scoped to the current single-user/local requirement.

---

## Part C — GUI toolkit and technique for the Antikythera dial/gear theme (architecture mode)

### Toolkit options considered

| Option | Feasibility for concentric rings/gears/dials | Dependency cost | Fit for one bounded implementation pass |
|---|---|---|---|
| **Tkinter `Canvas`** (stdlib) | Sufficient: `create_oval`, `create_arc`, `create_line`, `create_polygon` can render concentric rings, tick marks, and rotating needles/gear-like indicators; `itemconfig`/`coords` recompute on redraw for animation-like rotation | None (stdlib) | High — matches the prior app's stack (Tkinter), no new install |
| **PySide6 / `QGraphicsView`** | Strong: scene-graph vector graphics API designed for exactly this kind of interactive 2D graphics, with better performance/visual fidelity for many overlapping shapes [S33][S34] | New dependency (Qt bindings), materially larger API surface and learning curve | Medium — more capable but a heavier lift to learn and wire correctly in one pass |
| **customtkinter** | Theming/styling layer on top of Tkinter widgets; not designed for custom vector/gear rendering — would still fall back to `Canvas` for the dial art itself | New dependency, but thin | Low incremental value for this specific need (dial/gear rendering), since the actual rendering still requires `Canvas` |
| **`tkdial` (third-party Tkinter add-on)** | Provides ready-made circular dial/knob widgets built on `Canvas` [S35][S36] | Small optional dependency | Useful as an accelerator for standard circular controls, not a replacement for custom concentric-ring/gear art |

### Recommendation (decisive)

**Use Tkinter's `Canvas`** as the rendering surface for the Antikythera theme, consistent with the prior app's stack and the project's stdlib-preferred hobby-scope pattern. Concretely:

- Draw **concentric rings** with `create_oval` at increasing radii (representing the Antikythera's dial rings/zodiac and calendar rings).
- Draw **tick marks/graduations** with `create_line` at computed angles (`x = cx + r*cos(theta)`, `y = cy + r*sin(theta)`) for each ring, reusing a small polar-coordinate helper function.
- Represent "gears" decoratively as static or slowly-rotating **polygon/line clusters** (`create_polygon` for gear teeth, redrawn or rotated via `coords` updates) rather than a physically simulated gear train — a decorative mechanical aesthetic satisfies the requested theme without requiring true mechanical/physics simulation, which is out of scope for a calculator app.
- Use a **needle/pointer** (`create_line`) on the primary dial whose angle updates when a calculation result changes, giving the "instrument" a live, functional feel tied to the actual calculator output (e.g., the needle position could represent the currently displayed result scaled to a dial range) — an optional enhancement, not a strict requirement.
- Optionally use the third-party `tkdial` package [S35] for one or two standard circular input controls (e.g., a rate/percentage knob) if a ready-made circular control accelerates implementation, while custom `Canvas` drawing handles the distinctive Antikythera concentric-ring/gear background art that no off-the-shelf widget provides.

**Rationale for choosing `Canvas` over PySide6/QGraphicsView:** PySide6 is materially more capable for complex, many-layered vector graphics and would likely produce a more polished final visual result [S33][S34], but it introduces a new GUI framework, a new dependency, and a steeper API (scenes, items, views, signals/slots) relative to the prior app's plain Tkinter foundation. Since the task must be completed in a single bounded implementation pass and the visual requirement (concentric rings, tick marks, decorative gear shapes, a needle) is well within `Canvas`'s documented capability [S37][S38][S35], `Canvas` is the lower-risk, feasible choice. **This is an advisory recommendation; if a future iteration wants photorealistic mechanical rendering or smooth physically-simulated gear rotation, PySide6/QGraphicsView is the natural upgrade path.**

---

## Source ledger

| # | Title/path | URL | Type | Authority/relevance | Published | Accessed | Supports |
|---|---|---|---|---|---|---|---|
| S-PRIOR | Financial formulas for calculator-financial-2 | docs/research/calculator-financial-2-formulas.md | Prior internal research report | High — direct prior work by this harness | 2026-07-13 | 2026-07-13 | Baseline 10 formulas incorporated by reference |
| S13 | Bond Pricing Formula — WallStreetMojo | https://www.wallstreetmojo.com/bond-pricing-formula/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | Bond price formula (coupon + face value discounting) |
| S14 | Bond Valuation \| Formula, Examples & Calculator — Learnsignal | https://www.learnsignal.com/blog/bond-valuation/ | Finance-education secondary source | Medium-high | Undated | 2026-07-13 | Bond pricing components, YTM discount rate |
| S15 | Depreciation Methods — 4 Types — Corporate Finance Institute | https://corporatefinanceinstitute.com/resources/accounting/types-depreciation-methods/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | Straight-line and declining-balance depreciation formulas |
| S16 | Straight Line Depreciation — Formula, Definition and Examples — CFI | https://corporatefinanceinstitute.com/resources/accounting/straight-line-depreciation/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | Straight-line depreciation formula and example |
| S17 | To calculate Declining Balance with Switch to Straight Line depreciation — Infor documentation | https://docs.infor.com/ln/10.5/en-us/lnolh/help/tf/onlinemanual/000189.html | Vendor/product documentation describing standard accounting method | Medium-high | Undated | 2026-07-13 | Declining-balance-to-straight-line switch convention |
| S18 | CAGR Formula and Calculations — Wall Street Prep | https://www.wallstreetprep.com/knowledge/cagr-compound-annual-growth-rate/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | CAGR formula |
| S19 | CAGR Calculator — Omni Calculator | https://www.omnicalculator.com/finance/cagr | Reputable calculator/reference site | Medium-high | Undated | 2026-07-13 | CAGR formula corroboration and example |
| S20 | Effective Interest Rate \| Formula + Calculator — Wall Street Prep | https://www.wallstreetprep.com/knowledge/effective-interest-rate/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | EAR formula, continuous-compounding variant |
| S21 | Effective interest rate — Wikipedia | https://en.wikipedia.org/wiki/Effective_interest_rate | Encyclopedic secondary source | Medium | Undated (living page) | 2026-07-13 | EAR vs nominal rate distinction |
| S22 | Payback Period \| Reference Library — tutor2u | https://www.tutor2u.net/business/reference/payback-period | Education reference source | Medium-high | Undated | 2026-07-13 | Payback period formula, even cash flows |
| S23 | Payback Period Formula + Calculations — Wall Street Prep | https://www.wallstreetprep.com/knowledge/payback-period/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | Interpolated payback period formula for uneven cash flows |
| S24 | WACC Guide \| Formula + Calculation Example — Wall Street Prep | https://www.wallstreetprep.com/knowledge/wacc/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | WACC formula and components |
| S25 | Weighted average cost of capital — Wikipedia | https://en.wikipedia.org/wiki/Weighted_average_cost_of_capital | Encyclopedic secondary source | Medium | Undated (living page) | 2026-07-13 | WACC formula corroboration |
| S26 | Ordinary Annuity vs Annuity Due: Differences, Formulas & Examples — Wealthvieu | https://wealthvieu.com/retirement/annuities/ordinary-annuity-annuity-due/ | Finance-education secondary source | Medium-high | 2026 (dated page) | 2026-07-13 | Annuity due = ordinary annuity × (1+r) relationship, PV/FV formulas |
| S27 | Ordinary Annuity vs. Annuity Due: What's the Difference? — The Motley Fool | https://www.fool.com/investing/how-to-invest/annuity-due-vs-ordinary-annuity/ | Reputable finance-education secondary source | Medium-high | Undated | 2026-07-13 | Annuity due timing convention corroboration |
| S28 | Event Sourcing with SQLite: Append-Only Design | https://www.sqliteforum.com/p/event-sourcing-with-sqlite | Technical/practitioner article | Medium — corroborates general event-sourcing pattern | Undated | 2026-07-13 | Append-only JSONL event schema, SQLite as derived read-store |
| S29 | Dual-Contract Event Store in SQLite: Append-Only + Mutable — Medium | https://medium.com/@impactarchitecture/persistence-model-for-a-dual-contract-event-store-in-sqlite-53f3505f7d21 | Practitioner engineering write-up | Medium | Undated | 2026-07-13 | Outbox/event pattern, monotonic-id append events, single-transaction dual storage |
| S30 | RFC: Replace Postgres with event-sourced file log + SQLite read cache — GitHub Issue (paperclipai/paperclip #801) | https://github.com/paperclipai/paperclip/issues/801 | Open-source project RFC/issue | Medium — real-world design discussion, not peer-reviewed | Undated | 2026-07-13 | Per-entity JSONL append log + rebuildable SQLite cache pattern |
| S31 | Mastering SQLite Concurrency: File Locking, WAL Mode, and the Busy Error | https://runebook.dev/en/docs/sqlite/lockingv3 | Technical reference | Medium-high | Undated | 2026-07-13 | WAL mode single-writer/multi-reader behavior, busy_timeout |
| S32 | SQLite WAL Mode: 10x Performance for Python Apps — DEV Community | https://dev.to/lumin-playstar/sqlite-wal-mode-10x-performance-for-python-apps-4ic | Practitioner technical article | Medium | Undated | 2026-07-13 | WAL mode setup (`PRAGMA journal_mode=WAL`, persistence in file header), `-wal`/`-shm` side files |
| S33 | PyQt vs Tkinter: Differences, Pros & Cons — pythonGUIs | https://www.pythonguis.com/faq/pyqt-vs-tkinter/ | Python GUI specialist reference site | Medium-high | Undated (site maintained) | 2026-07-13 | Tkinter vs PyQt/PySide capability and complexity tradeoffs |
| S34 | PySide6 QGraphics Framework Tutorial — QGraphicsView 2D Vector Graphics — pythonGUIs | https://www.pythonguis.com/tutorials/pyside6-qgraphics-vector-graphics/ | Python GUI specialist reference site | Medium-high | Undated | 2026-07-13 | QGraphicsView capability for custom vector-graphics dial UIs |
| S35 | TkDial — GitHub (Akascape/TkDial) | https://github.com/Akascape/TkDial | Open-source library repository | Medium — community-maintained widget library | Undated | 2026-07-13 | Ready-made Tkinter circular dial/knob widgets built on Canvas |
| S36 | tkdial — PyPI | https://pypi.org/project/tkdial/ | Package index listing | Medium | Undated | 2026-07-13 | tkdial package availability/installation corroboration |
| S37 | Making a Tkinter Gauge — Arduino and Python docs | https://electronic-python.readthedocs.io/en/latest/gauge/drawing_gauge_tkinter.html | Technical documentation/tutorial | Medium-high | Undated | 2026-07-13 | Canvas-based gauge/dial construction technique (ticks, polar coordinates) |
| S38 | Gauges in a Python Canvas — Fun Tech Projects | https://funprojects.blog/2021/02/19/gauges-in-a-python-canvas/ | Practitioner technical blog | Medium | 2021 | 2026-07-13 | Canvas gauge implementation corroboration, itemconfig-based updates |

## Assumptions, unknowns, and contradictions

- **Assumption (medium-high confidence):** the eight new formulas (bond pricing, straight-line/declining-balance depreciation, CAGR, EAR, payback period, WACC, annuity-due toggle) constitute a reasonable, well-established "advanced" tier appropriate for a hobby-grade advanced calculator, based on their ubiquity across standard finance-education references. If the user has a different specific list in mind, confirm before implementation.
- **Assumption (high confidence):** WACC's `Ke` (cost of equity) and `Kd` (cost of debt) are user-entered decimals, not derived from CAPM/beta or a bond's market yield, to remain consistent with the confirmed "no live market data" exclusion. This is a scope-preserving interpretation, not a scope expansion.
- **Assumption (medium confidence):** the declining-balance depreciation schedule uses a simple "floor at salvage value" rule rather than the more precise "switch to straight-line when it becomes more favorable" convention [S17], because it is simpler to implement correctly within one bounded pass and avoids a class of off-by-one/schedule bugs; this is flagged as a documented simplification, not a silent inaccuracy.
- **Assumption (medium confidence):** annuity due is implemented as a payment-timing toggle on the existing savings-goal calculator (#8) rather than a fully separate 19th calculator, since the underlying formula is a scalar multiplier on an already-specified calculator. If the user wants annuity due exposed as its own distinct menu entry (matching the "one calculator per list entry" pattern used elsewhere), that is a straightforward relabeling with no formula change.
- **Unknown:** whether the JSONL audit log (`history.jsonl`) should ever be user-facing (e.g., viewable/exportable in the UI) or remain a purely internal implementation detail; this is a UI/product decision left to the engineering job, not a formula or architecture question that blocks implementation.
- **Unknown:** exact needle-to-result mapping and gear-rotation animation behavior for the Antikythera theme (e.g., which calculator result drives the primary dial, how many decorative rings/gears to render) — these are visual-design decisions appropriately left to `t1-engineer`'s implementation judgment within the `Canvas`-based approach recommended here, not blocking architectural questions.
- **No material contradictions found** across the financial-formula sources reviewed; all agree on formula structure for bond pricing, depreciation, CAGR, EAR, payback period, WACC, and annuity due/ordinary distinction. For the architecture question, the reviewed event-sourcing/JSONL sources describe patterns aimed at multi-process/distributed sync (outbox, idempotency keys, conflict resolution); this report explicitly does not adopt that full machinery, since it is unneeded for a single-process desktop app — flagged as a deliberate scope-narrowing of the pattern, not a contradiction between sources.
- **No contradiction between prior report and this one:** all 10 prior formulas remain unchanged and are incorporated by reference.

## Validation measures

- Unit-test each of the 8 new calculator functions against known reference examples (e.g., a par bond where coupon rate = yield should price at exactly face value; straight-line depreciation of a $10,000 asset with $1,000 salvage over 5 years = $1,800/year; CAGR of $100 → $200 over 5 years ≈ 14.87%; EAR of 8% nominal compounded monthly ≈ 8.30%) before wiring to the UI, mirroring the prior report's validation approach.
- Specifically test documented edge cases: bond `r=0` branch, depreciation `Salvage Value = Cost` (zero depreciation) and the floor-at-salvage-value rule, CAGR rejection of non-positive `Beginning`/`Ending Value`, WACC rejection of `E+D=0`, payback-period "not achieved" case, and the annuity-due `(1+r)` toggle producing identical results to ordinary annuity when `r=0`.
- For the persistence/streaming architecture: write an integration test that performs N calculations, then asserts (a) `history.jsonl` contains exactly N lines each parseable as JSON with the documented schema, (b) the SQLite `history` table contains exactly N rows with matching `id`/`ts`/`inputs`/`outputs`, and (c) a simulated crash between JSONL append and SQLite insert (e.g., kill the process after step (a) for one event) is detected and reconciled by the startup check.
- For the GUI: a smoke test (consistent with the prior app's `test_gui_launch.py` pattern) that launches the Antikythera-themed window and asserts the Canvas contains the expected ring/gear/needle canvas items without raising an exception, plus a manual visual review since dial aesthetics are not meaningfully unit-testable.
- Confirm with the user, before or during implementation, any of the assumptions flagged above that materially affect acceptance (declining-balance simplification, annuity-due-as-toggle-vs-separate-entry, WACC's user-entered-rates boundary).

## Adjacent research

- Accrued interest / clean vs. dirty bond pricing, and duration/convexity (natural bond-calculator extensions, out of current scope).
- CAPM-based cost of equity and market-yield-based cost of debt for a "fuller" WACC calculator (would reintroduce a live-market-data dependency currently excluded).
- Switch-to-straight-line declining-balance refinement, if the simplified floor-at-salvage-value approach proves insufficient for user needs later.
- Multi-process or networked sync architecture, if the app is ever extended beyond single-user/local scope (would require revisiting the JSONL+SQLite pattern recommended in Part B).
- PySide6/QGraphicsView migration path, if a future iteration wants higher-fidelity mechanical rendering or smooth simulated gear rotation beyond what Tkinter `Canvas` comfortably provides.

## Change log

- 2026-07-13: Initial report created (standard profile, dual technical-documentation + architecture mode). Eight additional formulas specified and cited; SQLite+JSONL streaming architecture decisively recommended with alternatives rejected and rationale stated; Tkinter `Canvas` recommended for the Antikythera GUI theme over PySide6/QGraphicsView, with rationale. Extends and incorporates by reference `docs/research/calculator-financial-2-formulas.md`.
