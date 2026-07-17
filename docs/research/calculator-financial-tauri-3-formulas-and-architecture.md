---
title: "calculator-financial-tauri-3: Rust/Tauri v3 financial calculator — formula carryover, decimal precision, and live market-data/news integration"
slug: calculator-financial-tauri-3-formulas-and-architecture
profile: standard (leaning deep)
mode: architecture (primary) + comparison (market-data/news API selection)
status: ready
created: 2026-07-13
updated: 2026-07-13
supersedes: docs/research/calculator-financial-2-formulas.md; docs/research/calculator-financial-3-formulas-and-architecture.md (stack and live-data sections only)
---

# calculator-financial-tauri-3: formula carryover, decimal precision, and live market-data/news integration

## Executive summary

**What.** This report informs a fresh Tauri v3 build of the financial calculator, in a new folder `calculator-financial-tauri-3`, using a Rust-only backend (Python omitted per user decision), an Antikythera-mechanism-styled UI, SQLite + JSONL persistence/streaming, and live market data and financial news wired into the running app. It confirms that all 18 formulas from the prior Tkinter/Python-era reports carry forward unchanged, verifies Rust's decimal-precision handling for those formulas, selects a free no-paid-key market-data API and a free no-paid-key financial-news API, and confirms the Tauri v2/v3 persistence and async-streaming pattern needed to wire live data into the app without blocking the UI.

**So what.** No formula-level content changes and no material Rust capability gap were found: `rust_decimal`'s `MathematicalOps` trait, combined with its `checked_*` variants, covers every formula in the 18-formula set, including the CAGR/EAR fractional-exponent cases that were only approximately exact in the prior Python `float`-based implementation [S1]. Two vendor Terms of Service (Alpha Vantage, NewsAPI.org) were found to conflict with the "wired into a running app" requirement and are not recommended [S3][S6]; Finnhub (market data) and GNews.io (news) are recommended instead as ToS-compatible, no-card free tiers for a single-user local app [S4][S7]. The prior JSONL-append + SQLite single-writer persistence pattern needs no architectural change for Tauri; it maps directly onto Tauri's async command + background-task pattern, with an added scheduled-poll trigger for live data alongside the existing on-calculation trigger [S8][S9].

**Now what.** `t1-engineer` can proceed with a Rust-only backend implementing all 18 formulas via `rust_decimal` (optionally supplemented by a vetted finance crate, pending a maturity check `t1-engineer` should run before pinning), can implement Finnhub and GNews.io clients behind a thin provider-swap interface, and can reuse the JSONL+SQLite persistence design from the prior report adapted to Tauri's `async fn` commands, `tokio::sync::Mutex`, and `tokio::mpsc`-driven background polling. Several items below are flagged as open unknowns or unresolved contradictions in the supplied evidence and are not resolved by this report; they are listed explicitly under Open items and require engineer-side verification before or during implementation.

This report **supersedes** `docs/research/calculator-financial-2-formulas.md` and `docs/research/calculator-financial-3-formulas-and-architecture.md` **only** on stack selection (Rust/Tauri, not Python/Tkinter) and on live-data scope (this build wires in live market data and news; the prior reports explicitly excluded live data). It **reuses by reference, unchanged**, the 18-formula set specified across those two reports.

---

## Scope and what carries forward unchanged

- **Formula set (18 formulas, unchanged):** simple interest, compound interest, future value, present value, loan/mortgage payment, amortization schedule, ROI, savings goal/sinking fund, break-even, NPV/IRR (the prior 10, from `calculator-financial-2-formulas.md`), plus bond pricing, straight-line depreciation, declining-balance depreciation, CAGR, effective annual rate (EAR) vs. nominal rate, payback period, WACC, and the annuity-due/ordinary-annuity toggle (the 8 additional, from `calculator-financial-3-formulas-and-architecture.md`). [S-PRIOR-1][S-PRIOR-2] No formula, variable definition, or edge case documented in either prior report is changed by this report; consult those two files for the full formula text, variable definitions, and edge-case handling.
- **New in this report, not covered by the prior two:** Rust decimal-precision verification for the formula set, a Rust-only-versus-Rust+Python capability check, live market-data API selection, live financial-news API selection, and the Tauri-specific mapping of the previously-recommended JSONL+SQLite architecture onto Tauri's async command/runtime model.
- **Explicitly changed from the prior reports:** stack (Rust/Tauri v3 replaces Python/Tkinter; GUI framework itself remains out of scope for this report, per the supplied evidence's `constraints_preserved`), and live-data scope (live market data and financial news are now in scope and required to be wired into the running app, reversing the prior reports' "no live/current market data" exclusion).
- **Out of scope for this report (per supplied evidence):** frontend/web-view framework selection within Tauri; UI/dial rendering technique for the Antikythera theme (a natural companion question to the prior report's Part C, but not answered here).

---

## Part A — Rust decimal precision and formula-set coverage (architecture mode)

### `rust_decimal`'s mathematical operations

The `rust_decimal` crate's `MathematicalOps` trait provides `powi`/`powu` for native integer exponents (exact, no approximation), and `powf(f64)`/`powd(Decimal)` for fractional exponents. The official documentation explicitly states that when the exponent in `powd` is not whole, "the approximation e^(y*ln(x)) is used" [S1]. Checked variants — `checked_powd`, `checked_powf`, `checked_ln`, `checked_exp`, `checked_sqrt`, and others — return `Option<Decimal>` rather than panicking on overflow or invalid input [S1].

**[Inference, medium-high confidence]** Fractional-exponent time-value-of-money formulas (CAGR's `^(1/n)`, EAR's `^n`, and any calculation using a non-integer compounding period) are not rendered perfectly exact in Rust any more than they were in the prior Python implementation's float-based `**` operator, because `powd` itself falls back to a natural-log/exponential approximation for non-whole exponents [S1]. `rust_decimal` still materially improves over raw `f64` for the additive and multiplicative currency arithmetic that dominates the 18-formula set (payment schedules, depreciation book-value tracking, bond coupon summation, NPV/IRR cash-flow accumulation), where exact base-10 rounding matters most and where integer-exponent `powi`/`powu` cover most compounding-period cases exactly.

**[Observation, high confidence]** No formula in the 18-formula set requires an operation `rust_decimal`'s `MathematicalOps` trait cannot perform, whether via exact integer-exponent methods or the documented fractional-exponent approximation. This directly answers the "is Rust alone sufficient" question raised in the report's goal.

### Rust-only versus Rust+Python

**[Inference, high confidence]** No material Rust capability gap was found for any of the 18 formulas; a Rust-only backend fully covers the formula set as currently specified. Python is omitted per the user's stated default, and the evidence surfaced no concrete technical reason to reintroduce it. If a future formula requires arbitrary-precision arithmetic beyond `Decimal`'s range or a numerical method not covered by `rust_decimal` or an available finance crate, that would be a new finding requiring separate research; it is not indicated by anything in the current evidence.

### Available Rust finance crates

At least four Rust finance crates exist in the relevant crates.io category: `rust_finprim`, `finance-solution`, `finance-math`, and `financial` (the last claiming Excel-Financial-Functions compatibility with 180+ test cases) [S2]. This observation comes from a registry-listing synthesis rather than a per-crate deep inspection, and is rated medium confidence for that reason.

**[Unknown, flagged for engineer verification]** Crate maturity — last-publish date, download counts, license, and actual test coverage — for these four crates was not independently verified in this research session; the crates.io pages involved are JS-rendered and were not fully inspectable by the research tooling available [S2]. `t1-engineer` should run `cargo search` or check crates.io directly before pinning any of these crates as a dependency, or default to hand-rolled functions built directly on `rust_decimal`'s primitives if none prove sufficiently maintained.

---

## Part B — Live market-data and financial-news API selection (comparison mode)

### Requirement recap

The app must have live market data and financial news wired into the running application (not stubbed, not a documentation placeholder), using a free tier that requires no paid API key to start, in a way that is compatible with the vendor's Terms of Service for a single-user, local, non-redistributing desktop app.

### Market-data providers evaluated

| Provider | ToS finding | Free-tier limits (secondary source) | Recommendation |
|---|---|---|---|
| **Alpha Vantage** | ToS grants "personal, non-commercial use" only, with ambiguous "commercial use" language that appears to cover "investment analysis, research, testing, monitoring, and any other activities that are individual in nature" [S3] | 5 calls/min + a daily cap [S5] | **Not recommended.** [Inference, medium-high confidence] Carries real licensing risk for this use case because the ToS commercial-use boundary is ambiguous even for individual, non-redistributed use. |
| **Finnhub** | ToS sets a 30 API calls/sec ceiling "on top of all plan's limits"; requires deletion of data when a subscription ends; prohibits redistribution or sharing of data or derived results with third parties without written approval; personal plans are restricted to "strictly personal use," and securities professionals are ineligible [S4] | ~60 calls/min free tier, roughly 15-20 minute delay (secondary source) [S5] | **Recommended as primary quote source.** [Inference, medium-high confidence] Free key obtainable by email, no credit card required, broad coverage, and ToS terms compatible with a single-user local desktop app provided cached data is treated as revocable/TTL-bound rather than permanently archived. |
| Twelve Data | Not independently ToS-checked this session | 800 calls/day, 4-hour delay (secondary source) [S5] | Not evaluated for ToS compatibility; noted only for completeness from the aggregator comparison. |
| FCS API | Not independently ToS-checked this session | 500 calls/month (secondary source) [S5] | Not evaluated for ToS compatibility; noted only for completeness from the aggregator comparison. |

**Open contradiction (not resolved by this report):** the secondary-source aggregator figure of "60 calls/min" for Finnhub's free tier [S5] does not fully reconcile with the primary ToS's stated "30 API calls/sec ceiling ... on top of all plan's limits" [S4]. These may describe compatible things (a per-second ceiling versus a separate per-minute plan quota) but this was not confirmed against Finnhub's own rate-limit documentation, which was not accessible to the research tooling this session (JS-rendered page). `t1-engineer` should reconfirm the exact free-tier rate limit directly against Finnhub's authenticated dashboard/docs before implementing polling or retry/backoff logic.

### Financial-news providers evaluated

| Provider | ToS finding | Free-tier terms | Recommendation |
|---|---|---|---|
| **NewsAPI.org** | The free "Developer" plan explicitly forbids production or staging use, restricting it to development and testing only; 100 requests/day, 24-hour article delay, 1-month search window [S6] | See above | **Disqualified.** [Inference, high confidence] The requirement is to wire news into a running (production) app; NewsAPI.org's free-tier ToS directly forbids that use. |
| **GNews.io** | Free tier: 100 requests/day, up to 10 articles per request, no credit card required, 12-hour delay, 30-day historical window, scoped to "non-commercial projects, development, and testing purposes only" [S7] | See above | **Recommended as primary news source.** [Inference, medium-high confidence] No card required and the terms are usable for a running, non-commercial, single-user local app. Revisit this choice if the app is later sold or distributed commercially, since the free-tier scope is explicitly non-commercial. |

### Caching and persistence versus provider ToS

**[Inference, high confidence]** For a single-user, local, non-redistributing app, caching Finnhub and GNews.io data locally with revocable/TTL-bound eviction — not permanent archival — is ToS-compatible with both providers' stated terms [S4][S7]. This is distinct from the app's own calculation-history persistence (the amortization schedules, NPV results, and similar outputs the user generates), which is the user's own data and is not subject to these providers' ToS at all. This distinction should be reflected structurally: market-data and news tables should carry a TTL/eviction policy, while calculation-history tables remain permanent, matching the prior report's JSONL-as-source-of-truth pattern for the user's own generated data.

### Open item: Alpha Vantage and legal interpretation

**[Unknown, flagged as risk to avoid]** Whether Alpha Vantage's ToS would in practice be enforced against a hobby-scope single-user app is a legal interpretation question that this report does not resolve; it is treated here as a risk to route around by choosing Finnhub instead, not as a settled legal conclusion. This is informational research, not legal advice.

---

## Part C — Persistence and streaming architecture in Tauri v2/v3 (architecture mode)

### Direct Rust-side persistence versus the official SQL plugin

Tauri v2's official `tauri-plugin-sql` (built on `sqlx`, with a `sqlite` feature) supports transactional migrations and exposes SQL to the frontend via IPC [S8]. Direct Rust-side use of `sqlx` or `rusqlite` inside Tauri commands — bypassing the plugin and its frontend-facing IPC surface — is a documented, equally valid alternative for backend-owned persistence [S8].

**[Inference, high confidence]** Because this architecture is Rust-owned rather than frontend-driven (the calculation engine, persistence, and live-data polling all live in Rust, with the web view acting as a display/input layer), direct `sqlx`/`rusqlite` use inside Tauri commands is the better fit here. This mirrors the prior report's JSONL-append + SQLite single-writer pattern with no material change required for the move to Tauri: the JSONL-as-source-of-truth, SQLite-as-queryable-index design, the WAL-mode single-writer concurrency approach, and the startup-reconciliation mitigation for the double-write consistency gap all carry forward unchanged in a Tauri context. Consult `calculator-financial-3-formulas-and-architecture.md` Part B for the full pattern, schema shape, and risk/tradeoff discussion; this report does not restate it.

### Async command and background-streaming pattern

The synthesized Tauri v2 async pattern is: `async fn` commands, since Tauri owns the Tokio runtime; `tokio::sync::Mutex` (not the standard-library `Mutex`) for any state held across an `.await` point; `tokio::task::spawn_blocking` for CPU-heavy work; and background streaming implemented via `tauri::Builder::setup()` spawning a `tokio::spawn` task that communicates over a `tokio::mpsc` channel, pushing updates to the frontend via `handle.emit()` [S9]. This synthesis draws on both official docs.rs material and community write-ups and is rated medium-high confidence rather than high, reflecting the mixed-source basis.

**[Inference, high confidence]** This pattern directly supports periodic Finnhub and GNews.io polling: a background task on a timer writes fetched data to JSONL and SQLite via the existing single-writer pattern, then emits an event so the frontend updates without blocking the UI thread. No architectural change is needed to the JSONL+SQLite design beyond adding a scheduled-poll trigger that runs alongside the existing on-user-calculation trigger; both triggers can share the same single-writer persistence function.

### Recommended interface shape for provider swap

**[Inference, medium confidence — not directly evidenced, a design recommendation drawn from the confirmed constraints]** Implement the Finnhub client (quotes) and GNews.io client (news) behind a thin trait or interface rather than calling each vendor's API directly from call sites throughout the codebase. This is not itself a cited claim from the evidence packet but follows directly from the `implications.now_what` guidance in the supplied evidence, which explicitly recommends this for future provider swap given the ToS risk already identified for Alpha Vantage and NewsAPI.org.

---

## Source ledger

| # | Title/path | URL | Type | Authority/relevance | Published | Accessed | Supports |
|---|---|---|---|---|---|---|---|
| S1 | `rust_decimal` `MathematicalOps` trait documentation | https://docs.rs/rust_decimal/latest/rust_decimal/trait.MathematicalOps.html | Official crate docs (docs.rs) | High | Current | 2026-07-13 | `powd`/`powf`/`checked_*` behavior, fractional-exponent approximation |
| S2 | crates.io finance-category listings synthesis | https://crates.io/categories/finance ; https://crates.io/crates/rust_finprim ; https://crates.io/crates/finance-solution ; https://crates.io/crates/finance-math ; https://crates.io/crates/financial | Registry listings via search-tool summary | Medium | Unknown | 2026-07-13 | Existence/feature coverage of Rust finance crates; maturity unverified |
| S3 | Alpha Vantage Terms of Service | https://www.alphavantage.co/terms_of_service/ | Primary vendor legal terms | High | Undated current | 2026-07-13 | Personal/non-commercial license scope, ambiguous commercial-use trigger |
| S4 | Finnhub Terms of Service | https://finnhub.io/terms-of-service | Primary vendor legal terms | High | Undated current | 2026-07-13 | 30 calls/sec ceiling, delete-on-end, no-redistribution, personal-use restriction |
| S5 | Aggregator comparison articles 2026 (qveris.ai, fcsapi.com, thenextgennexus.com) | https://qveris.ai/guides/stock-api-free-comparison/ ; https://fcsapi.com/blog/best-free-stock-market-data-api-for-developers-2026 ; https://thenextgennexus.com/2026/05/15/10-best-free-stock-market-apis-2026/ | Secondary practitioner blogs | Medium | 2026 | 2026-07-13 | Free-tier rate limits/delay figures |
| S6 | NewsAPI.org Pricing page | https://newsapi.org/pricing | Primary vendor pricing/terms | High | Current | 2026-07-13 | Dev-only production prohibition, 100/day, 24h delay |
| S7 | GNews.io Pricing page | https://gnews.io/#pricing | Primary vendor pricing/terms | High | Current | 2026-07-13 | Free tier terms, no card, non-commercial restriction |
| S8 | Tauri v2 official SQL plugin docs | https://v2.tauri.app/plugin/sql/ | Primary official framework docs | High | Current | 2026-07-13 | `tauri-plugin-sql` vs. direct `sqlx`/`rusqlite` |
| S9 | docs.rs `tauri::async_runtime` + community write-ups | https://docs.rs/tauri/latest/tauri/async_runtime/index.html ; https://rfdonnelly.github.io/posts/tauri-async-rust-process/ ; https://dev.to/hiyoyok/rust-async-in-tauri-v2-what-tripped-me-up-and-how-i-fixed-it-1662 | Mixed official + community | Medium-high | Current | 2026-07-13 | Async command pattern, background streaming via `setup()` + `mpsc` + `emit` |
| S-PRIOR-1 | Financial formulas for calculator-financial-2 | docs/research/calculator-financial-2-formulas.md | Prior internal research report | High | 2026-07-13 | 2026-07-13 | Baseline 10 formulas |
| S-PRIOR-2 | calculator-financial-3: advanced formulas, SQLite+JSONL architecture, Antikythera GUI | docs/research/calculator-financial-3-formulas-and-architecture.md | Prior internal research report | High | 2026-07-13 | 2026-07-13 | 8 additional formulas; JSONL+SQLite pattern reused; GUI recommendation superseded (web frontend now, not Tkinter) |

---

## Open items (unresolved unknowns and contradictions)

These items are carried forward from the supplied evidence as open questions. They are flagged here for `t1-engineer` and the user, not resolved by this report:

- **Finnhub rate-limit contradiction:** aggregator-reported "60 calls/min" [S5] versus the primary ToS's "30 API calls/sec ceiling" [S4] are not fully reconciled. Likely compatible (a per-second ceiling versus a separate per-minute plan quota) but unconfirmed. Reconfirm directly against Finnhub's authenticated docs/dashboard before implementing polling frequency or backoff logic.
- **Rust finance crate maturity:** last-publish date, download counts, license, and test coverage for `rust_finprim`, `finance-solution`, `finance-math`, and `financial` were not independently verified this session [S2]. Run `cargo search` / check crates.io directly, or default to hand-rolled `rust_decimal` functions if none prove sufficiently maintained.
- **Finnhub news-endpoint coverage:** whether Finnhub's free tier includes a usable news endpoint was not confirmed; GNews.io is the higher-confidence news source and is recommended as primary regardless.
- **Alpha Vantage enforcement-in-practice:** whether Alpha Vantage's ambiguous commercial-use ToS language would in practice be enforced against a hobby-scope single-user app is a legal interpretation question, not resolved here — treated as a risk to avoid by choosing Finnhub instead.

## Constraints preserved (confirmed unchanged from user requirements)

- No paid API key required to start; both Finnhub (market data) and GNews.io (news) satisfy this.
- Live market data and financial news are wired into the running app, not stubbed.
- Rust owns the core calculation engine, Tauri commands, and SQLite/JSONL persistence and streaming; Python is omitted.
- All 18 prior formulas are reused unchanged.
- This is a fresh, independent report and folder (`calculator-financial-tauri-3`); GUI/frontend-framework selection within Tauri remains open and out of scope for this report.

## Validation measures

- `t1-engineer` should directly fetch Finnhub's and GNews.io's authenticated docs/dashboard pages to reconfirm exact free-tier limits before implementation, since the JS-rendered vendor pages were not fully accessible to the research tooling this session.
- Run `cargo add --dry-run` or check crates.io directly for finance-crate maturity before pinning any of the four candidate crates; fall back to hand-rolled `rust_decimal` functions if a crate proves unmaintained.
- Unit-test `rust_decimal`'s `powd`/`checked_powd` fractional-exponent precision against the prior report's reference values (for example, CAGR of $100 to $200 over 5 years is approximately 14.87%, per `calculator-financial-3-formulas-and-architecture.md`'s validation section).
- Integration-test the Finnhub and GNews.io clients against their documented rate limits (backoff/retry behavior) and confirm cache TTL/eviction behavior operates correctly and distinctly from the permanent calculation-history tables.
- Perform a non-legal-advice human sanity check of the Finnhub and GNews.io Terms of Service against the app's actual shipped behavior before any distribution wider than the current single-user local scope.

## Research limits

- Several vendor documentation pages (Finnhub's own docs, crates.io crate pages) are JS-rendered single-page applications that were inaccessible to the fetch tooling used in this research session; claims resting on those pages are flagged at reduced confidence above.
- This report is informational on Terms of Service and licensing considerations. It is not legal advice, and no claim in this report should be treated as a legal conclusion.
- All primary sources were accessed 2026-07-13. Third-party API free-tier terms, rate limits, and pricing are volatile; reconfirm directly against each vendor at implementation time.

## Adjacent research (not covered here)

- GUI/frontend-web-view framework selection for the Tauri shell, and the Antikythera dial/gear rendering technique within it (a direct Tauri-era successor question to the prior report's Part C, which recommended Tkinter `Canvas` for a now-superseded stack).
- A deeper, first-party (non-aggregator) confirmation of Finnhub's exact free-tier rate limit, resolving the flagged 30/sec-versus-60/min discrepancy.
- Independent maturity verification of the four candidate Rust finance crates, or a decision to proceed with hand-rolled `rust_decimal` functions only.
- Revisiting GNews.io's non-commercial restriction if the app is ever sold or distributed beyond single-user local use.

## Change log

- 2026-07-13: Initial report created (standard profile, leaning deep; combined architecture + comparison mode), authored from a `RESEARCH_EVIDENCE` packet supplied directly by Researcher. Confirms 18-formula carryover unchanged, verifies Rust-only backend sufficiency via `rust_decimal`, selects Finnhub and GNews.io as ToS-compatible free-tier live-data sources, and maps the prior JSONL+SQLite persistence pattern onto Tauri v2/v3's async command and background-streaming model. Supersedes `calculator-financial-2-formulas.md` and `calculator-financial-3-formulas-and-architecture.md` on stack and live-data scope only; reuses their 18-formula set by reference.
