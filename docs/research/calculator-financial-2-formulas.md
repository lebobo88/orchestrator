---
title: Financial formulas for "calculator-financial-2" Python/Tkinter hobby app
slug: calculator-financial-2-formulas
profile: standard
mode: technical-documentation
status: ready
created: 2026-07-13
updated: 2026-07-13
---

# Financial formulas for calculator-financial-2

## Executive summary

**What.** Ten standard, timeless personal-finance calculators are specified below with exact formulas, input/output variable definitions, and implementation edge cases, sized for a hobby-grade Python + Tkinter app. **So what.** These are closed-form or well-known iterative formulas (no live market data, no tax/regulatory logic), each independently implementable and unit-testable in plain Python (stdlib), with `numpy-financial` optional for IRR/amortization convenience. **Now what.** `t1-engineer` can implement each calculator as an isolated function with documented inputs/outputs/edge cases; recommended module layout and validation approach are included under Validation measures.

This report uses **technical-documentation** mode (formula reference for implementation) rather than architecture/strategic mode, because the deliverable is a precise, citable formula and edge-case reference, not a system-design or market analysis.

## Scope and exclusions (user-confirmed)

- In scope: 10 personal-finance calculators (list below). Hobby-grade, not a professional/regulated tool.
- Out of scope (excluded by user): tax calculations, personalized investment advice, live/current market data, retirement/annuity planning, inflation adjustment. These may be noted as "not included" only.
- Target stack: plain Python (stdlib preferred), simple Tkinter UI. `numpy-financial` is optional, not required.

## Final list of 10 calculators

1. Simple interest
2. Compound interest
3. Future value (of a lump sum, generalized compounding)
4. Present value (of a future lump sum, discounting)
5. Loan/mortgage payment calculator
6. Amortization schedule (paired with #5, listed separately because its output — a period-by-period table — and edge cases differ materially from the payment formula itself)
7. Return on investment (ROI)
8. Savings goal calculator (sinking fund / future value of an ordinary annuity, solved for payment)
9. Break-even point (unit economics: fixed cost / (price − variable cost))
10. Net present value (NPV) and internal rate of return (IRR) as a single combined "cash-flow analysis" calculator (grouped because they share the same input schema — a cash-flow series — and IRR is normally computed by finding the root of the NPV function)

**Naming note (Observation, confidence high):** the user's original list said "loan/mortgage payment + amortization schedule" as one item and "basic NPV/IRR" as one item; this reorganization keeps NPV+IRR combined as originally scoped but splits loan payment and amortization into two list entries to reach a clean count of 10 while preserving the user's approved feature set. **This is a naming/grouping choice within already-approved scope, not a scope change** — no new capability is added beyond what the user confirmed.

---

## 1. Simple interest

**Formula:** `I = P * r * t`; `A = P + I = P * (1 + r * t)`

- `P` = principal (float, dollars, > 0)
- `r` = annual interest rate as a decimal (e.g., 0.05 for 5%)
- `t` = time in years (float, can be fractional, e.g., 0.5 for 6 months)
- `I` = interest earned; `A` = total amount (principal + interest)

**Edge cases:**
- Reject `P <= 0`, `r < 0`, `t < 0` with a UI validation message rather than raising an unhandled exception.
- `r` entered as a whole-number percent (e.g., "5") vs decimal (0.05) is a common UI bug — decide the input convention once (recommend: user types percent, e.g. "5", app divides by 100 internally) and label the field accordingly.
- Simple interest does not compound; do not reuse the compound-interest function with `n=1`. [S1] [S4]

## 2. Compound interest

**Formula:** `A = P * (1 + r/n)^(n*t)`; `I = A - P`

- `P` = principal
- `r` = annual nominal interest rate (decimal)
- `n` = compounding periods per year (1=annual, 2=semiannual, 4=quarterly, 12=monthly, 365=daily)
- `t` = time in years
- `A` = final amount; `I` = interest earned

**Edge cases:**
- `n` must be a positive integer; provide a dropdown (Annually/Semiannually/Quarterly/Monthly/Daily) rather than free text to avoid divide-by-zero or non-integer period bugs.
- Continuous compounding (`A = P * e^(r*t)`) is a distinct, optional formula — do not silently substitute it; if offered, label it explicitly using `math.exp`.
- Floating-point rounding: round only the final displayed currency value (2 decimal places), not intermediate values, to avoid compounding rounding error across periods. [S1] [S3]

## 3. Future value (generalized, supports periodic contributions)

**Two variants are common; implement the lump-sum version as the core "Future Value" calculator, since periodic-contribution FV is effectively the Savings Goal calculator (#8) run in the forward direction.**

**Lump-sum FV formula:** `FV = PV * (1 + r/n)^(n*t)` — identical in form to compound interest (#2); the distinct UI framing is "what will my money be worth" vs "how much interest will I earn." [S3][S4]

- `PV` = present value / initial amount
- `r` = annual rate (decimal), `n` = compounding periods/year, `t` = years
- `FV` = future value

**Edge cases:**
- Because the math is identical to compound interest, consider implementing one shared internal function (`_compound_growth(pv, r, n, t)`) used by both calculator #2 and #3 to avoid drift/duplication — an implementation efficiency, not a scope change.
- `t=0` should return `PV` unchanged (`FV = PV`); verify no divide-by-zero when `t=0`.

## 4. Present value (discounting a single future amount)

**Formula:** `PV = FV / (1 + r/n)^(n*t)`

- `FV` = known future amount
- `r` = annual discount rate (decimal)
- `n` = compounding/discounting periods per year
- `t` = years until `FV` occurs
- `PV` = present value (today's equivalent)

**Edge cases:**
- `r = 0` is valid and should return `PV = FV` (no discounting) — must not divide by zero; `(1+0/n)^(n*t) = 1` handles this naturally in code as long as `n != 0`.
- Very large `t` with high `r` can cause `PV` to underflow toward 0 — acceptable behavior, but ensure output formatting doesn't show negative-zero or scientific notation to the user. [S3]

## 5. Loan / mortgage payment calculator

**Formula (standard amortizing loan payment):**
`M = P * [ i * (1+i)^n ] / [ (1+i)^n - 1 ]`

- `P` = loan principal
- `i` = periodic interest rate = (annual nominal rate) / (payments per year) — e.g., annual rate / 12 for monthly payments
- `n` = total number of payments (years × payments per year)
- `M` = payment amount per period

**Edge cases (high importance — most common source of bugs):**
- **`i = 0` special case is mathematically undefined (division by zero) in the formula above.** When the entered annual rate is 0%, use the simple formula `M = P / n` instead; code must branch on this explicitly. [S2][S5]
- Use the **note rate**, not APR, in the payment formula. APR (as defined by the U.S. Truth in Lending Act / CFPB Regulation Z, 12 CFR §1026.22) can include fees and is meant for cost-of-credit disclosure, not payment calculation — do not attempt to compute or apply APR unless a distinct, explicitly-labeled feature is requested (it is out of scope here). Label the input field "Annual Interest Rate (Note Rate)". [S2]
- The formula assumes **compounding frequency equals payment frequency** (e.g., monthly payments require the monthly rate `i = annual_rate/12`). If the app only supports monthly payments (recommended for hobby scope), hardcode `n = years * 12` and `i = annual_rate/12`, and state this assumption in the UI/help text rather than generalizing prematurely. [S2]
- Validate `P > 0`, `annual_rate >= 0`, `n >= 1` (integer). Reject `n <= 0`.

## 6. Amortization schedule

**Formula (per period `k = 1..n`):**
- `interest_k = balance_(k-1) * i`
- `principal_k = M - interest_k`
- `balance_k = balance_(k-1) - principal_k`
- Uses the same `M`, `i`, `n`, `P` as calculator #5; `balance_0 = P`.

**Output:** a list/table of rows `{period, payment, principal_paid, interest_paid, remaining_balance}`.

**Edge cases:**
- **Final-period rounding drift:** because `M` is rounded to cents each period in real-world display, the last period's `balance_(n-1) - principal_n` may not land exactly on `0.00` due to accumulated floating-point/rounding error. Standard practice: on the final row, set `principal_n = balance_(n-1)` directly (payoff = remaining balance) and adjust that row's total payment (`interest_n + principal_n`) rather than trusting the generic formula to hit exactly zero. [S2][S4]
- Use `decimal.Decimal` (not raw `float`) for currency arithmetic in the schedule to avoid visible penny-level drift across many rows, or round every row to 2 decimals immediately after computing it (not just at final display) so displayed rows sum consistently.
- Large `n` (e.g., 360 monthly payments for a 30-year mortgage) — populate a scrollable Tkinter `Treeview`/`Listbox`, not a fixed-size widget; this is a UI-sizing edge case, not a formula edge case.
- `i = 0` edge case from #5 applies here too: interest_k = 0 for all periods, principal_k = M for all periods except rounding on the last row.

## 7. Return on investment (ROI)

**Formula:** `ROI (%) = ((Gain from investment − Cost of investment) / Cost of investment) * 100`

Equivalently, given a final value and initial cost: `ROI (%) = ((Final_Value − Initial_Cost) / Initial_Cost) * 100`

- `Initial_Cost` = amount invested (> 0)
- `Final_Value` = amount received/current value (can be less than `Initial_Cost`, producing negative ROI — this is valid, not an error)
- `Gain` = `Final_Value − Initial_Cost` (can be negative)

**Edge cases:**
- `Initial_Cost = 0` is undefined (division by zero) — reject with a validation message ("cost must be greater than 0"), do not attempt to special-case it as infinite ROI.
- Negative ROI (a loss) is a normal, expected output — do not clamp to zero or treat as an error state.
- Optional: annualized ROI requires a holding-period input and a different formula (`(1+ROI)^(1/years) - 1`); treat as an out-of-scope stretch feature unless the user requests it, since it was not part of the confirmed 10-item scope. [S6]

## 8. Savings goal calculator (sinking fund / future value of an ordinary annuity, solved for payment)

**Future value of an ordinary annuity (deposits at end of each period):**
`FV = PMT * [ ((1 + r/n)^(n*t) − 1) / (r/n) ]`

Solved for the periodic deposit needed to reach a goal (the "savings goal" use case):
`PMT = FV_goal * (r/n) / [ ((1 + r/n)^(n*t) − 1) ]`

- `FV_goal` = target savings amount
- `r` = annual interest rate (decimal)
- `n` = deposits/compounding periods per year (recommend hardcode monthly, `n=12`, for hobby scope)
- `t` = years until goal
- `PMT` = required periodic deposit (the calculator's primary output)

**Edge cases:**
- **`r = 0` special case:** division by zero in the formula above. When rate is 0%, use `PMT = FV_goal / (n*t)` (simple division, no growth). Must branch explicitly, same pattern as loan payment #5. [S7][S8]
- Ordinary annuity (end-of-period deposits) vs. annuity due (start-of-period deposits) produce slightly different results; pick one convention (ordinary annuity is the more common default for "savings goal" tools) and label it, rather than silently mixing the two. [S8]
- Validate `t > 0` and `n*t` yields a whole number of periods where possible (e.g., `t` in months if `n=12` and `t` is fractional years, verify rounding of period count is intentional, e.g., `round(n*t)` vs `int(n*t)` truncation — recommend `round()` with a UI note that partial months are rounded to the nearest whole period).

## 9. Break-even point

**Formula (unit break-even):** `Break-even (units) = Fixed_Costs / (Price_per_unit − Variable_Cost_per_unit)`

Optional companion: `Break-even (revenue $) = Break-even (units) * Price_per_unit`

- `Fixed_Costs` = total fixed costs (> 0)
- `Price_per_unit` = selling price per unit
- `Variable_Cost_per_unit` = variable cost per unit
- `Contribution_Margin = Price_per_unit − Variable_Cost_per_unit` (must be > 0)

**Edge cases:**
- **If `Price_per_unit <= Variable_Cost_per_unit`, contribution margin is zero or negative — break-even is mathematically undefined/infinite** (the business can never break even at that price). Detect this explicitly (`contribution_margin <= 0`) and show a clear message ("price must exceed variable cost per unit") instead of dividing by zero or a negative number and returning a nonsensical result.
- Break-even in units is typically reported as a whole number rounded up (`math.ceil`), since partial units usually cannot be sold — decide and document this rounding convention. [S9]
- This is the one calculator in the set that is not a time-value-of-money formula; it is simple unit economics. Confirm with UI copy that it is distinct from the discounting-based "break-even" sometimes described in finance texts (present-value break-even of an investment) — the user's confirmed scope is the standard unit-economics break-even, which is more commonly requested in hobby calculators. **Assumption (medium confidence):** interpreted as unit-economics break-even per common usage; flag to user if investment-payback break-even was intended instead.

## 10. Net present value (NPV) and internal rate of return (IRR)

**NPV formula:** `NPV = Σ [ CF_t / (1 + r)^t ]` for `t = 0..N`, where `CF_0` is typically the initial investment (negative) and `CF_1..CF_N` are subsequent net cash flows (positive or negative).

- `CF_t` = net cash flow at period `t` (list/array input from the user, one row per period)
- `r` = discount rate (decimal) supplied by the user for NPV
- `N` = number of periods (length of cash-flow list − 1, since `t` starts at 0)
- `NPV` = single output value; positive NPV conventionally indicates a value-adding investment at that discount rate.

**Sign convention (important, commonly a source of bugs):** cash outflows (investment/expenses) must be entered as **negative** numbers and inflows (returns/savings) as **positive** numbers; `CF_0` is almost always negative (the initial investment). If the UI just asks for "cash flow per period" without labeling sign convention clearly, users will produce wrong results — the input UI must instruct or default the first period to negative. [S10]

**IRR:** the discount rate `r*` that makes `NPV(r*) = 0`. There is no closed-form solution for `N > ~2`; IRR must be found **iteratively**:

- **Recommended approach for a hobby app:** implement a numeric root-finder over the NPV function.
  - **Option A (stdlib-only, recommended default):** bisection or `scipy`-free Newton-Raphson using Python's own loop: `r_new = r_old - NPV(r_old) / NPV'(r_old)`, where `NPV'(r) = Σ [ -t * CF_t / (1+r)^(t+1) ]`. Iterate until `abs(NPV(r_new)) < tolerance` (e.g., 1e-6) or a max iteration count (e.g., 1000) is hit.
  - **Option B (simpler, more robust, slightly slower):** bisection search between a low bound (e.g., -0.99) and a high bound (e.g., 10.0 = 1000%), since NPV is monotonically decreasing in `r` for typical cash-flow patterns — safer for a hobby app because Newton-Raphson can diverge with a poor initial guess or non-standard cash-flow sign patterns.
  - **Option C:** use `numpy_financial.irr(cash_flows)` if the optional dependency is acceptable — implements a robust solver already; recommended if `numpy-financial` is approved as a dependency, otherwise use Option B for a zero-dependency implementation. [S11][S12]

**Edge cases:**
- **No solution / multiple solutions:** if cash flows change sign more than once (e.g., negative, positive, negative), there can be zero, one, or multiple mathematically valid IRRs (Descartes' Rule of Signs). A simple bisection/Newton solver will return only one root or fail to converge — cap iterations and surface "IRR could not be determined for this cash flow pattern" rather than returning a misleading number. [S10][S11]
- If all cash flows are the same sign (all positive or all negative), IRR is undefined — validate before running the solver and show a message rather than iterating to a max-iteration failure silently.
- Newton-Raphson divergence: if using Option A, guard against division by a near-zero derivative and against the iterate leaving a sane rate range (e.g., clamp to [-0.99, 10] each step, or fall back to bisection if Newton fails to converge in N steps).
- NPV's `r=0` case is fine mathematically (`NPV = Σ CF_t`, i.e., simple sum) — no special-case branch needed, unlike the annuity/loan formulas above.
- Distinguish this calculator's discount-rate input (`r` for NPV) from the solved-for rate (IRR is an output, not an input) in the UI to avoid user confusion about which calculator mode is active.

---

## Explicitly not included (per confirmed scope)

- Retirement/annuity planning calculators beyond the basic savings-goal sinking-fund formula in #8.
- Inflation adjustment / real vs. nominal value calculators.
- Tax calculations of any kind.
- Personalized investment advice or recommendations.
- Live/current market data (interest rates, stock prices, etc.) — all rates/prices are user-entered.
- Full APR computation per Regulation Z (fees, points, etc.) — loan calculator (#5) uses the simpler note-rate payment formula only, explicitly not APR.

## Implementation notes for t1-engineer (advisory, not prescriptive)

- **Language/deps:** Python stdlib (`math`, optionally `decimal` for the amortization schedule) is sufficient for all 10 calculators without `numpy-financial`. If `numpy-financial` is added for IRR (Option C above), it is the only calculator that benefits materially from an external dependency; the other nine are pure stdlib arithmetic.
- **Recommended module shape:** one pure function per calculator (no I/O, no Tkinter references) returning either a scalar (interest calculators, ROI, payment, break-even, savings-goal PMT, NPV, IRR) or a list of dict rows (amortization schedule), each independently unit-testable; a thin Tkinter layer calls these functions and formats output.
- **Shared validation helper:** a single input-validation utility (reject negative/zero where inappropriate, coerce percent-vs-decimal input) used across all 10 calculators reduces duplicated edge-case bugs, particularly the recurring "`i=0`/`r=0` division-by-zero" pattern that appears in calculators #5, #6, #8, and implicitly #2/#3.
- **Currency rounding:** round to 2 decimal places only at display time for single-value calculators (#1–4, #7, #9); use per-row rounding with a final-row balance correction for the amortization schedule (#6) as described above.

## Source ledger

| # | Title/path | URL | Type | Authority/relevance | Published | Accessed | Supports |
|---|---|---|---|---|---|---|---|
| S1 | Compound Interest \| Formula + Calculator | https://www.wallstreetprep.com/knowledge/compound-interest/ | Reputable finance-education secondary source | High for standard formula reference | Undated (site evergreen) | 2026-07-13 | Simple/compound interest formulas, rounding note |
| S2 | Regulation Z, 12 CFR §1026.22 — Determination of annual percentage rate | https://www.consumerfinance.gov/rules-policy/regulations/1026/22/ | U.S. federal regulation (CFPB) | Authoritative/primary (regulatory) | Current regulation | 2026-07-13 | Loan payment: APR vs note-rate distinction, scope exclusion of APR |
| S3 | Future Value: Formula Approach — Mathematics of Finance (eCampusOntario open textbook) | https://ecampusontario.pressbooks.pub/financemath/chapter/2-6-future-value-formula-approach/ | Open academic textbook | High — standard finance-math reference | Undated (OER textbook) | 2026-07-13 | FV/PV general compounding formula |
| S4 | Future Value - Definition, Formula, Calculator — Corporate Finance Institute | https://corporatefinanceinstitute.com/resources/valuation/future-value-formula/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | FV formula, simple-interest FV variant |
| S5 | Amortization Calculator — Bankrate | https://www.bankrate.com/mortgages/amortization-calculator/ | Reputable consumer-finance secondary source | Medium-high | Undated | 2026-07-13 | Loan payment formula components |
| S6 | Return on Investment (ROI) \| Formula + Calculator — Wall Street Prep | https://www.wallstreetprep.com/knowledge/roi-return-on-investment/ | Reputable finance-education secondary source | High | Undated | 2026-07-13 | ROI formula |
| S7 | 5.2 Future Value of Annuities and Sinking Funds — Mathematics LibreTexts | https://math.libretexts.org/Courses/University_of_St._Thomas/Math_101:_Finite_Mathematics/05:_Mathematics_of_Finance/5.02:_Future_Value_of_Annuities_and_Sinking_Funds | Open academic textbook (LibreTexts) | High | Undated | 2026-07-13 | Sinking fund / FV annuity formula |
| S8 | 4.6 Sinking Funds — Mathematics of Finance (eCampusOntario open textbook) | https://ecampusontario.pressbooks.pub/mathematicsfinance/chapter/4-6-sinking-funds/ | Open academic textbook | High | Undated | 2026-07-13 | Ordinary annuity vs annuity due, sinking fund solved-for-PMT |
| S9 | Break-Even Calculations — Penn State EME 460 course notes | https://www.e-education.psu.edu/eme460/node/661 | University course material | Medium-high | Undated | 2026-07-13 | Break-even framing (present-value variant noted as distinct from unit break-even) |
| S10 | Calculating Internal Rate of Return (IRR) in Practice using Improved Newton-Raphson Algorithm | https://www.researchgate.net/publication/338749495_Calculating_Internal_Rate_of_Return_IRR_in_Practice_using_Improved_Newton-Raphson_Algorithm | Peer-reviewed/academic paper | High | Published (peer-reviewed) | 2026-07-13 | NPV/IRR relationship, sign convention, Newton-Raphson iteration |
| S11 | Internal Rate of Return Calculation — Rust Implementation (developer blog, engineering write-up) | https://weitzel.dev/post/calculating-internal-interest-rate/ | Practitioner/engineering secondary source | Medium — corroborates academic source on multiple-root and convergence pitfalls | Undated | 2026-07-13 | IRR multiple-roots edge case, iterative solver implementation pitfalls |
| S12 | numpy-financial `irr` function (project documentation, referenced via general knowledge of the package) | https://numpy.org/numpy-financial/ | Open-source library documentation | Medium-high — standard community-vetted implementation | Current | 2026-07-13 | Optional dependency option for IRR solving |

## Assumptions, unknowns, and contradictions

- **Assumption (medium confidence):** break-even calculator (#9) is unit-economics break-even (fixed cost / contribution margin), not investment-payback break-even, based on it being more commonly requested in general hobby finance-calculator sets. If the user intended the investment/payback variant, this should be confirmed before or during implementation.
- **Assumption (high confidence):** loan/mortgage calculator (#5) assumes payment frequency equals compounding frequency (standard monthly amortizing loan) and uses the note rate, not APR — consistent with confirmed exclusion of tax/regulatory features.
- **Unknown:** whether `t1-engineer` should default annuity/savings-goal deposits to monthly (`n=12`) only, or expose a compounding-frequency selector across all calculators; this is an implementation/UI-design decision left to the engineering job, not a formula question.
- **No material contradictions found** across sources; all reviewed sources agree on formula structure. Minor terminology variation exists (e.g., "sinking fund" vs "savings goal" vs "future value of annuity solved for payment") — treated as the same underlying formula per S7/S8.
- **Naming/grouping decision requiring no further approval:** splitting "loan payment" and "amortization schedule" into two list entries (items 5 and 6) to reach exactly 10 items, while combining NPV/IRR into one item (item 10) as originally scoped. This preserves the user-approved feature set; flagged here for transparency per harness requirements, not as an open scope question.

## Validation measures

- Unit-test each calculator function against known textbook/reference examples (e.g., $1000 at 5% simple interest for 2 years = $1100; a $200,000 30-year loan at 6% monthly = a known standard payment figure) before wiring to the UI.
- Specifically test the documented edge cases: `r=0`/`i=0` branches (#2, #5, #6, #8), `Initial_Cost=0` rejection (#7), `Price <= Variable_Cost` rejection (#9), all-same-sign cash flows and multiple-sign-change cash flows for IRR (#10), and final-row rounding correction in the amortization schedule (#6).
- Cross-check loan payment and amortization outputs against a third-party calculator (e.g., Bankrate's amortization calculator [S5]) using the same inputs to confirm agreement to the cent.
- Confirm with the user, before or during implementation, the break-even interpretation assumption noted above if it materially affects acceptance.

## Adjacent research

- Retirement/annuity planning calculator formulas (explicitly excluded from this scope; would be a natural follow-up if the app is extended later).
- Inflation-adjustment (real vs. nominal value) formulas (explicitly excluded).
- Full Regulation Z APR calculation method, if a future iteration needs true APR disclosure rather than note-rate payment calculation.
- UI/UX patterns for Tkinter financial-calculator layouts (not researched here; a design/implementation concern for `t1-engineer`, not a formula question).

## Change log

- 2026-07-13: Initial report created. Standard profile, technical-documentation mode. Ten calculators finalized from user-confirmed list; formulas, variables, and edge cases documented with citations.
