# Lizbeth Spanish, Issue #31: Foundations — adopt Field Journal tokens

Status: Drafted, awaiting the orchestrator's routing decision under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the assumption recorded below. Approval of this document authorizes only issue #31's token-layer scope; it does not authorize any of issues #32-#44. **Amended on 2026-08-31 for one narrow, live-session, user-authorized deviation from ordered-work step 1 and Risk R3's Atelier-pipeline-failure handling; see "Amendment" below. This amendment does not close issue #31 against its own Atelier-specific acceptance criteria; see the amendment's binding follow-up requirement.**

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished." Given earlier in this same interactive session, after the user had already been shown and had approved several prior plans in this engagement.
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #31 of `lebobo88/lizbeth-spanish`) to engineering without a further live per-plan checkpoint.
- **Staleness cross-check:** The orchestrator independently fetched the live GitHub issue #31 body (`gh issue view 31 --repo lebobo88/lizbeth-spanish`) and confirmed it matches this plan's grounding documents (`design/field-journal/ADOPTION-PLAN.md`, `judge/issue-map.json`, `extracted tokens.field-journal.json`) with no material contradiction; the plan is not stale.
- **Date:** 2026-08-31.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statement. It is recorded here as an orchestrator-applied inference under standing authorization, not as a Scribe-verified user approval of this specific document.

## Amendment (2026-08-31): live-session, user-authorized deviation from ordered-work step 1 / Risk R3

**Provenance label, matching the Approval basis section above.** This amendment's factual record reached Scribe entirely through the orchestrator's account of the session. Scribe has not independently observed the Atelier MCP tool calls or the user's live chat turn. It is recorded here as the orchestrator's direct, verbatim report of a live-session user instruction, distinguished explicitly from the "Approval basis" section's standing-authorization inference above: this amendment rests on the user's own words in this instance, not on an inferred application of an earlier general statement to new, unrelated scope.

**1. Plan text being deviated from.** Ordered-work step 1 states: "Read `.atelier/tokens/field-workbook.tokens.json` and establish how the Atelier generator is actually invoked. This was never verified by planning or design. If the pipeline cannot be re-run, STOP and return `JOB_BLOCKED` rather than hand-editing the generated file, whose header forbids it." Risk R3 states the same constraint: "The Atelier pipeline for `field-workbook.generated.css` was never inspected by planning or design; if it cannot be re-run, the generated file must NOT be hand-edited (its header forbids it)," with the recorded mitigation "Ordered-work step 1 requires this verification first; return `JOB_BLOCKED` if the pipeline cannot be re-run."

**2. Infrastructure defect discovered.** During execution, the Atelier MCP server was found to have a genuine, verified infrastructure defect in this session: its `projectRoot` resolved to the parent orchestrator directory (`H:\CommandCenter\orchestrator`) instead of the target repository (`lizbeth_spanish`), making the target repository's own `.atelier/tokens/field-workbook.tokens.json` and `atelier.config.json` unreachable to the server. This was confirmed twice via `mcp__atelier__atelier_info` calls, both returning `projectRoot: "H:\\CommandCenter\\orchestrator"` and `configSource: "built-in defaults (no atelier.config.json found)"`. The investigation crossed two distinct failure modes across multiple attempts: first, T1 was blocked entirely from calling any `mcp__atelier__*` tool, for lacking that tool access at all, which the user fixed by editing `t1-engineer.md`'s tools frontmatter and restarting the session; second, even after that access fix and after the user relaunched and reconnected the Atelier MCP server scoped explicitly to the `lizbeth_spanish` folder, `atelier_info` still reported the wrong `projectRoot` both before and after the reconnection. The pipeline was therefore genuinely non-functional against the target repository's token source, not merely unverified.

**3. User's verbatim authorization.** After the orchestrator presented the exact blocker to the user in the live session and asked for direction, the user's verbatim, direct response was:

> "skip atelier for now and proceed forward as planned."

This is the user's own words as directly reported by the orchestrator, not an agent's paraphrase, summary, or inference, and not an application of the unrelated standing authorization recorded in the "Approval basis" section above.

**4. Exact scope of the authorized deviation.** Two things only, both scoped to this session:

- T1 was authorized to hand-transcribe `src/tokens/field-workbook.generated.css` as a one-time, explicitly disclosed exception to ordered-work step 1's hand-edit prohibition. The transcription is a deterministic, faithful, byte-verified rendering of the updated `.atelier/tokens/field-workbook.tokens.json`: verified via `git diff` to preserve every pre-existing declaration byte-for-byte except the one deliberate `--color-focus` correction specified in Interfaces and data above (from `#0284c7` to ink.slate), with all new declarations from the Interfaces and data token table correctly value-mapped, and the file's own header comment rewritten to explicitly flag it as a manual transcription pending real Atelier re-verification rather than left claiming machine generation.
- T1 was authorized to skip running `mcp__atelier__tokens_validate`, `tokens_compile`, `design_review`, `contrast_check`, `tokens_diff`, and `a11y_audit` for this session only, and to report their absence honestly in its evidence rather than fabricating a result for any of them.

No other deviation from this plan's scope, non-goals, ordered work, or acceptance criteria is authorized by this amendment. Ordered-work steps 2 (RED test authoring), 3 (mechanism-1 `semantic.json` fix), 5 (mechanism-3 `App.css` fix), 6 (deprecation markers), 7 (lint/`tsc`/`npm test`), 9 (Codex `CODE_REVIEW` judge pass), and 10 (Verifier and Browser Validator passes) remain fully in force, unmodified.

**5. Binding follow-up requirement.** Once the Atelier MCP server's `projectRoot` misconfiguration is fixed, the real `tokens_validate` -> `tokens_compile` pipeline MUST be re-run against `.atelier/tokens/field-workbook.tokens.json`, and its output diffed against the then-current `src/tokens/field-workbook.generated.css` to confirm zero drift, before this issue's Atelier-specific acceptance criteria (the "Atelier" line in Acceptance and validation above: `tokens_diff` zero-changed-entries, `design_review` clean, `contrast_check` clean, `a11y_audit` clean) can be considered fully satisfied. Until that re-run and zero-drift confirmation occur, GitHub issue #31 must be tracked as CONDITIONALLY complete, not fully closed against its own stated acceptance criteria, and this status must be carried into any completion report, verification record, or issue-closing comment for #31.

**Non-effect on the rest of this plan, stated explicitly.** This amendment authorizes exactly the two items in section 4 above and nothing else. It does not relax the Judge route, the deterministic gate in ordered-work step 7, the Verifier or Browser Validator passes, or any acceptance criterion other than the Atelier-specific line's timing (deferred to the follow-up, not waived). It does not authorize any deviation on any other issue in the Field Journal DS milestone (#32-#44).

Plan ID: `lizbeth-spanish-issue31-design-system-foundations`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `visual-system-designer`, `motion-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: extend)

## Outcome and audience

GitHub issue #31, "Foundations: adopt Field Journal tokens," is the only currently unblocked issue in the 14-issue, dependency-chained "Field Journal DS" milestone (issues #31-#44). This plan establishes the Field Journal design-token substrate ADDITIVELY across the app's three CSS-custom-property delivery mechanisms so that downstream issues #32-#44 have an unambiguous, correctly-resolving token target.

Audience: the T1/T2 engineer implementing this plan, and the Verifier/Browser Validator gating it.

## Scope

**In scope — token layer only:**

1. `.atelier/tokens/field-workbook.tokens.json` (mechanism-2 generator input) updated to the ratified values; regenerate `src/tokens/field-workbook.generated.css` through the EXISTING Atelier pipeline.
2. `src/App.css` hand-authored `:root` block (lines 17-89) — mechanism 3.
3. `src/tokens/semantic.json` — one required value-only edit (see Interfaces and data).
4. `src/tokens/primitives.json` / `components.json` — values-only reconciliation where a name already overlaps mechanisms 2/3.
5. Three new `.paper-stock--ruled`, `.paper-stock--graph`, `.paper-stock--card` utility classes.
6. New/updated tests under `src/__tests__/`.

**Non-goals (belong to later chained issues; do NOT do them here):**

- Typography tokens, font families, the `@import` font chain — issue #32.
- Component CSS migration across the ~26 files in `src/**/*.css` — issues #33/#35/#36.
- Screen work — issues #37-#44.
- Journal devices, spot illustrations, empty states — issue #34.
- Issue #28 (Modal ground-up redesign, downstream of #35) and issue #29 (token fallback audit, downstream of #33) are explicitly PARKED. Do not close, fix, or comment on them.
- Do NOT retire, delete, or repoint any existing component call site.
- Do NOT introduce a new build tool. There is no PostCSS/Tailwind/style-dictionary in this repo and none is to be added.

## Verified repository findings

Stack: React 18.3 + TypeScript 5.5 + Vite 5.4 + Supabase. Vitest 2.0 (separate `vitest.config.ts`), Playwright 1.61 (`test:e2e`), ESLint 9.39 flat config (`npm run lint` = `eslint src --ext ts,tsx`). No CSS build step exists.

**THREE coexisting CSS-custom-property delivery mechanisms — the central hazard of this issue:**

1. `src/tokens/primitives.json` + `semantic.json` + `components.json` -> `src/tokens/tokenSystem.ts` `generateCSSVariables()` -> injected as a runtime `<style>` tag into `document.head` by `src/main.tsx`.
2. `.atelier/tokens/field-workbook.tokens.json` -> generated `src/tokens/field-workbook.generated.css` (header: "Generated by atelier-mcp — do not edit by hand"), `@import`ed at `src/App.css` line 13.
3. `src/App.css` lines 17-89, a third hand-authored `:root` block with overlapping names.

**Cascade order, verified twice independently: mechanism 1 WINS.** `index.html` has a single `<script type="module" src="/src/main.tsx">` and no hand-authored CSS `<link>`. In production, Vite injects the App.css bundle into `<head>` before script execution; in dev, import hoisting means the side-effect `import './App.css'` at `src/App.tsx` line 33 fully evaluates before `main.tsx`'s top-level `document.head.appendChild(styleSheet)` runs. Both `:root` blocks have equal specificity, so the last-appended (mechanism 1) wins.

Verified current contents of `src/tokens/field-workbook.generated.css`: defines `--radius-square: 0px` (already compliant), `--radius-small: .125rem`, `--radius-medium: .25rem`, `--radius-pill: 999px`, `--shadow-print: .3rem .3rem 0rem 0rem #a07e48`, `--color-focus: #0284c7`, `--motion-duration-short: 200ms`, `--motion-easing-standard: cubic-bezier(0.2, 0, 0, 1)`, `--size-control-height: 2.75rem`, `--border-width-strong: 2px`, plus paper/ink/brass/terracotta colors and space/size/font tokens. It does NOT define `ink.1000`, `paper.300`, `ink.slate`, `ink.moss`, or any hard-offset shadow scale.

Existing consumption: `--radius-square` has ~11 call sites; `--radius-small`/`--radius-medium`/`--radius-pill` plus ~80 literal `border-radius` values (0.25rem, 0.375rem, 0.5rem, 999px) live across 26 CSS files; `--shadow-print` has 17+ call sites.

Verified already present in `src/tokens/primitives.json` at exactly the ratified values: `brass.300` `#dca250` (line 26), `brass.700` `#7c6136` (line 30), `amber.200` `#ffd699` (line 16).

`src/tokens/semantic.json` lines 32-35 define `color.focus.ring` as `{color.info.600}`, and `primitives.json` line 54 resolves `color.info.600` to `#0284c7` — the wrong focus color reached by a third path.

Existing tests that constrain the work: `src/__tests__/designSystemConsistency.test.ts` (J-001..J-004 CSS regression guards, including a J-003 "@import must be the first rule" constraint, and an assertion against the `.feedback-form-submit` selector); `src/__tests__/tokenSystem.test.ts` (asserts NAME presence only, not exact values — verified, which is what makes a values-only reconciliation safe); `src/__tests__/contrast.test.ts`; `src/__tests__/nativeDialogPolicy.test.ts`.

`src/lib/contrast.ts` implements WCAG 2.x relative luminance only. There is NO APCA implementation anywhere in this repo.

Routing is a custom pushState router at `src/hooks/useRoute.ts` plus `src/App.tsx` lines 72-186 — not react-router.

Native browser dialogs: ZERO call sites in `src/`. A grep for `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` returns only the enforcement test's own assertions and one inert test fixture string.

`vite.config.ts` currently sets `server.port: 5173`, `open: true`; `preview:prod` uses 4173.

## Research evidence and its limits

Verbatim GitHub issue bodies could NOT be fetched: the repo is private and `gh` is not on the Researcher Bash allowlist (`.claude/hooks/validate-researcher-bash.ps1`), while unauthenticated GitHub web/API access returns 404.

Substitute evidence, treated as the specification of record:

- `design/field-journal/ADOPTION-PLAN.md` is the planning document that generated all 14 issues, and `design/field-journal/judge/issue-map.json` explicitly maps plan-issue 1 -> GitHub #31 through plan-issue 14 -> GitHub #44. Issue #31's scope is ADOPTION-PLAN.md Step 3 table row 1 (reference sections A.1, A.3, A.4, A.5).
- `design/field-journal/extracted/tokens.field-journal.json` is the DTCG source of truth for the ratified values used throughout this plan.
- `design/field-journal/judge/verdict.json` records a CLEAN prior Codex plan-judgement on the milestone's completeness and token correctness.
- The seven fixed acceptance criteria carried by EVERY issue in this milestone (ADOPTION-PLAN.md reference §A.6) are reproduced in Acceptance and validation below.

**RESIDUAL LIMIT, recorded prominently.** The exact GitHub issue #31 body text, its checkbox list, and the live open/closed and label state of #28/#29/#32-#44 are UNVERIFIED. Pre-flight step 0 below requires the orchestrator to run `gh issue view 31 --repo lebobo88/lizbeth-spanish` and `gh issue list --repo lebobo88/lizbeth-spanish --state all --limit 60 --json number,title,state,labels` before implementation begins. If the live issue body materially contradicts ADOPTION-PLAN.md, this plan is STALE and must be reworked rather than implemented.

Also unverified: `lizbeth_spanish` is gitignored inside the orchestrator repo and has no local `.git`, so local file state cannot be reconciled against the GitHub remote HEAD.

## Design route and handoff

```
DESIGN_ROUTE
profile: standard
reasons: System-wide visual foundation (color primitives, zero-radius invariant, hard-offset elevation scale, paper-stock grounds, motion tokens) affecting the rendered substrate of every screen in a live app. Not studio — the creative direction is already ratified and CLOSED upstream, so there were no three directions to select between. Not compact — too system-wide and too multi-state.
agents_required: design-director, visual-system-designer, motion-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: extend
END_DESIGN_ROUTE
```

**Design handoff: PASSED.** The full `DESIGN_HANDOFF` was retained in the planning chain; its load-bearing content is reproduced in Interfaces and data and Acceptance and validation below. Selected direction: not applicable — no new creative direction was generated; the packet converts an already-ratified, closed system into an implementable token specification. The design reviewer verified every primitive, semantic, border, radius, shadow, size, and motion value byte-for-byte against `tokens.field-journal.json`.

**Design review: PASSED.** `DESIGN_REVIEW_RESULT verdict: PASS` after exactly one evidence-backed revision cycle. The first pass returned `NEEDS_REVISION` with one CRITICAL, one MAJOR, and three MINOR findings; all five were remediated by the original Design Director, and the revision passed with no blocking findings and no new defects. The CRITICAL finding was that the original packet corrected the focus-ring color in mechanisms 2 and 3 but missed mechanism 1's `semantic.json` path — which is the mechanism that actually wins the cascade — so the fix would have been silently reverted at runtime.

Reviewer's remaining limits, recorded here:

- (a) The literal-hex `#3d5f6b` in `semantic.json` will not track future changes to ink.slate's canonical value. This is a deliberate trade-off to avoid granting mechanism 1 a new Field Journal token name, to be revisited when mechanism 1 is retired.
- (b) Both review passes were STATIC — no `npm test`, `tsc`, or Atelier validator was executed by the design fleet.
- (c) `.atelier/tokens/field-workbook.tokens.json` contents and the Atelier pipeline re-run mechanics were never inspected by design and are an explicit implementation-time verification step (ordered work step 1 below).

## Judge route

Checkpoint `CODE_REVIEW` is REQUIRED, per issue #31's own Verification section (ADOPTION-PLAN.md Step 4 checkpoint 2: per-issue adoption judgement on the diff).

- Risk: medium.
- Model: gpt-5.6-terra/medium (multi-file, cross-layer semantics across three token-delivery mechanisms).
- Rubric: token fidelity against `design/field-journal/extracted/tokens.field-journal.json`; zero-radius invariant; hard-offset shadow (blur and spread literally 0); focus-ring correctness across all three mechanisms; no raw hex outside the token layer; decorative elements `aria-hidden`; no state conveyed by color alone.
- Call cap: 2 for the standard path, one checkpoint repeatable once after remediation.
- `PLAN_DUCK` is available to the orchestrator after this plan is drafted, per `docs/JUDGE-CONTRACT.md`.
- Deterministic failures (`tsc`, vitest, Atelier validators, Verifier, Browser Validator) ALWAYS dominate the judge.
- `.claude/judge-policy.json` is in shadow mode, so a judge finding is advisory unless blocking has been enabled.

## Ordered work

Owner for every step: T1, escalate to T2 on two counted gate failures. Strict TDD — RED evidence is required before any production edit in every step that has a test.

0. **PRE-FLIGHT** (orchestrator, before dispatching T1): run the two `gh` commands listed in Research evidence and its limits above and confirm the live issue #31 body matches this plan's scope. If it materially differs, do not implement — replan.
1. Read `.atelier/tokens/field-workbook.tokens.json` and establish how the Atelier generator is actually invoked. This was never verified by planning or design. If the pipeline cannot be re-run, STOP and return `JOB_BLOCKED` rather than hand-editing the generated file, whose header forbids it.
2. **RED:** extend `src/__tests__/tokenSystem.test.ts` and add a new token-layer test asserting that every new custom property is defined and resolves, that no `shadow.*` token has nonzero blur or spread, that `--radius-none` resolves to 0, and that `--color-focus-ring` resolves to `#3d5f6b` in the mechanism-1 output. Confirm the tests fail for the right reason.
3. **GREEN, mechanism 1 (value-only):** in `src/tokens/semantic.json`, change `color.focus.ring.$value` from `"{color.info.600}"` to the literal `"#3d5f6b"`. This must be a literal hex, NOT a `{color.ink.slate}` reference — adding an `ink.slate` primitive would grant mechanism 1 a new Field Journal token name, which the strategy forbids. Leave `color.state.info` untouched (verified to be a separate semantic slot with no mechanism-2/3 counterpart and no focus-ring consumption). Reconcile the VALUES of any other overlapping name to match mechanisms 2/3; add no new names.
4. **GREEN, mechanism 2:** update `.atelier/tokens/field-workbook.tokens.json` with the full token set in Interfaces and data and regenerate `src/tokens/field-workbook.generated.css` via the existing pipeline. Correct `--color-focus` from `#0284c7` to ink.slate.
5. **GREEN, mechanism 3:** in `src/App.css`'s `:root`, correct `--color-focus-ring` to `var(--color-ink-slate, #3d5f6b)`, add the three `.paper-stock--*` utility classes, and add the `@media (prefers-reduced-motion: reduce)` block collapsing the three motion durations. Preserve the J-003 `@import`-first constraint.
6. **Apply the deprecation markers** (see Interfaces and data). Values must stay byte-for-byte identical.
7. **Run the full gate:** `npm run lint`, `tsc`, `npm test`. All existing tests must stay green, untouched.
8. **Atelier gate:** `mcp__atelier__tokens_validate` -> `tokens_compile` -> `design_review` -> `contrast_check` -> `a11y_audit`.
9. **Codex `CODE_REVIEW` judge pass** per Judge route above.
10. **Verifier pass, then Browser Validator pass** per Browser UI validation below.

## Interfaces and data

**New primitive tokens** (values are ratified and must match `tokens.field-journal.json` exactly):

| Token | Value | CSS variable | Note |
|---|---|---|---|
| `color.ink.1000` | `#1a1512` | `--color-ink-1000` | rule-black: every outline, every hard shadow |
| `color.paper.300` | `#e3dbcd` | `--color-paper-300` | grid/ruled lines only, never a text ground |
| `color.ink.slate` | `#3d5f6b` | `--color-ink-slate` | Advanced band ink AND the focus ring |
| `color.ink.moss` | `#2f5d3f` | `--color-ink-moss` | completed stamp |
| `color.brass.300` | `#dca250` | `--color-brass-300` | new to mechanisms 2/3 only; already present in mechanism 1's `primitives.json` at this value |
| `color.brass.700` | `#7c6136` | `--color-brass-700` | new to mechanisms 2/3 only; already present in mechanism 1's `primitives.json` at this value |
| `color.amber.200` | `#ffd699` | `--color-amber-200` | new to mechanisms 2/3 only; already present in mechanism 1's `primitives.json` at this value |
| `color.accent.margin-rule` | `#e0b3a5` | `--color-accent-margin-rule` | |
| `border.width.thin` | `2px` | `--border-width-thin` | deliberately a distinct name from the pre-existing, numerically identical `--border-width-strong: 2px`, which is neither aliased nor deleted |
| `border.width.rule` | `3px` | `--border-width-rule` | |
| `border.color.default` | `{color.ink.1000}` | `--border-color-default` | |
| `radius.none` | `0px` | `--radius-none` | defined as `var(--radius-square)` to alias the pre-existing compliant `--radius-square: 0px` rather than duplicate a second `0px` declaration. This is the SOLE radius token. |
| `shadow.card` | `5px 5px 0 0 #1a1512` | `--shadow-card` | |
| `shadow.sheet` | `8px 8px 0 0 #1a1512` | `--shadow-sheet` | |
| `shadow.brass` | `5px 5px 0 0 #a07e48` | `--shadow-brass` | |
| `shadow.press` | `7px 7px 0 0 #1a1512` | `--shadow-press` | |
| `shadow.none` | `0 0 0 0 #1a1512` | `--shadow-none` | |
| `size.control-height` | `48px` | `--control-height` | deliberately NOT `--size-control-height`, which already holds an incompatible 44px / 2.75rem value |
| `size.hit-target-min` | `44px` | `--hit-target-min` | |
| `size.focus-ring-width` | `3px` | `--focus-ring-width` | |
| `size.focus-ring-offset` | `2px` | `--focus-ring-offset` | |

Every shadow's third and fourth components — blur and spread — are literally 0. That is the enforceable definition of "hard offset, never a blur."

**Naming decision, recorded deliberately:** the four size tokens above omit the `--size-*` prefix because the existing `--size-*` family (`--size-content-max`, `--size-login-max`, `--size-logo`, `--size-student-column`) is a heterogeneous catch-all of unrelated component dimensions; grouping a semantically tight accessibility contract under it would imply membership in that mixed bucket.

**New semantic tokens:**

- `color.band.beginner` -> `{color.brass.600}` -> `--color-band-beginner`
- `color.band.intermediate` -> `{color.terracotta.600}` -> `--color-band-intermediate`
- `color.band.advanced` -> `{color.ink.slate}` -> `--color-band-advanced`
- `color.focus.ring` -> `{color.ink.slate}` -> `--color-focus-ring`; EXISTING NAME, VALUE CORRECTED from `#0284c7`. Must be corrected in all THREE mechanisms (ordered work steps 3-5).

**Paper stocks** are delivered ONLY as literal CSS inside three new utility class bodies, NOT as `var()`-consumable composite custom properties. Reason: each ratified `$value` is a multi-declaration blob containing a top-level `;` (for example, ruled = `background-color: #fdfcf9; background-image: repeating-linear-gradient(to bottom, transparent 0 31px, #e3dbcd 31px 32px), linear-gradient(to right, transparent 0 55px, #e0b3a5 55px 57px, transparent 57px);`), and a CSS custom-property value terminates at a top-level `;`, so assigning it verbatim would be invalid or would leak a stray declaration onto `:root`.

- `.paper-stock--ruled` — paper.50 ground, 32px lead paper.300 lines, margin rule `#e0b3a5` at 55-57px. Lesson reading surfaces.
- `.paper-stock--graph` — paper.100 ground, 18px paper.300 grid. Chrome, dashboards, empty states.
- `.paper-stock--card` — flat paper.200. Index cards, locked states, tabs.

All three are additive and UNCONSUMED by any existing component, so they cause zero visible change on merge. Ingredient scalars (`--color-paper-50`/`100`/`200`/`300`, `--color-accent-margin-rule`) remain independently available.

**Motion tokens:**

- `motion.duration.press` `120ms`, `motion.duration.stamp` `260ms`, `motion.duration.page-turn` `320ms`.
- `motion.easing.standard` `cubic-bezier(0.2, 0, 0, 1)` (already present as `--motion-easing-standard`, unchanged).
- `motion.keyframes.page-turn`/`press`/`stamp` are NAME AND MECHANICS RESERVATIONS ONLY, not implementations — no component receives a `@keyframes` rule, transition wiring, or event trigger in this issue.
- `motion.reducedMotion` `instant`.

**Component tier.** The `DESIGN_HANDOFF` also specifies a component-tier naming layer (`component.card.shadow.*`, `component.sheet.shadow.default`, `component.legacyPrint.shadow`, `component.control.*`, `component.focusRing.*`, `component.border.*`, `component.radius.all`, `component.surface.*`, `component.band.*`). Record explicitly that this tier is NOT present in the ratified source, which stops at primitive/semantic — it is director-authored scaffolding by analogy to the repo's existing `components.json` pattern. It is additive and unwired, so it causes zero visible change.

**Migration strategy — keep-untouched-with-deprecation-marker.** `--radius-small`, `--radius-medium`, `--radius-pill`, `--shadow-print`, and `--motion-duration-short` keep their exact current values BYTE-FOR-BYTE and each gains the comment marker:

```
/* DEPRECATED — retired by the Field Journal token spec (issue #31); do not use in new code; migrate call sites via #33/#35/#36/#37-44 */
```

Rejected alternatives, with reasons: alias-to-new-value-now would silently regress ~80 radius and 17+ shadow unreviewed call sites; delete-and-force-migration-now would break all of them immediately and force out-of-scope component edits. `--size-control-height` (2.75rem / 44px) is NOT overwritten to 48px for the same reason; the ratified value ships under the new non-colliding name `--control-height`.

## Acceptance and validation

**Deterministic:** `npm run lint` clean; `tsc` clean; `npm test` fully green with every pre-existing test (J-001..J-004 in `designSystemConsistency.test.ts`, `tokenSystem.test.ts`, `contrast.test.ts`, `nativeDialogPolicy.test.ts`) still passing UNMODIFIED. New RED-first tests per ordered work step 2. The J-003 "@import must be the first rule" constraint in `App.css` must be preserved.

**Atelier:** `tokens_validate`, `tokens_compile`, `design_review`, `contrast_check`, `a11y_audit` all pass.

**The seven fixed acceptance criteria carried by every issue in this milestone** (reference §A.6), scoped to the token layer for issue #31:

1. No state by color alone — every state carries a glyph, outline, stamp shape, or literal word.
2. Text contrast >= 4.5:1; `amber.*` and `terracotta.500` never carry text; only `brass.600`, `brass.700`, `terracotta.600`, and the `ink.*` family may back a text color token.
3. Hit targets >= 44px; controls and fields are 48px tall.
4. Focus = 3px `ink.slate` ring at 2px offset, drawn OUTSIDE the shadow.
5. Decoration is inert and `aria-hidden`; deleting every decorative element must leave the screen fully usable.
6. Zero border-radius on everything in scope; depth is a hard offset, never a blur.
7. No raw hex in CSS — tokens only; `prefers-reduced-motion` collapses every animation to an instant state change with no opacity-only fades.

**Engineering invariants** (from the passed `DESIGN_HANDOFF`):

- Focus-ring exact technique, decisively resolved:
  ```css
  :focus-visible {
    outline: var(--focus-ring-width, 3px) solid var(--color-focus-ring);
    outline-offset: var(--focus-ring-offset, 2px);
  }
  ```
  NOT a stacked second box-shadow layer. `outline` is architecturally independent of `box-shadow` and paints after backgrounds, borders, and box-shadow, so it is guaranteed to sit on top of any hard-offset depth shadow with no per-element coordination. Radius is 0 everywhere, so the usual outline corner-clipping motivation for a box-shadow ring does not apply.
- No new shadow token or component shadow declaration may introduce nonzero blur or spread. `--shadow-print`'s legacy geometry is frozen, not extended.
- No new token under Field Journal naming may carry a nonzero radius under any name. Legacy nonzero radius tokens are frozen, not extended.
- Raw hex is permitted in exactly one place: the paper-stock recipes written into the three `.paper-stock--*` class bodies. Nowhere else.
- Reduced motion is hosted in mechanism 3 (`App.css`), chosen because mechanism 2's file is pipeline-generated and its media-query support is unverified. Durations collapse to 0ms, or 1ms where downstream JS depends on an `animationend`/`transitionend` callback firing (relevant to the stamp's fire-once completion signal).

**Accessibility position — record verbatim, do not soften.** WCAG AA (>= 4.5:1) is the SOLE gate, computed with the repo's existing WCAG-only `src/lib/contrast.ts`. No APCA implementation exists in this repo and none is introduced. Measured figures: `brass.600` 5.02:1 on `paper.50`; `terracotta.600` 4.69:1; `ink.slate` 6.72:1 (APCA Lc 82.0); `ink.moss` 7.42:1 (APCA Lc 84.5); `brass.300` 6.80:1 on `ink.900` (APCA Lc -55.0).

**RECORDED ACCEPTED DEVIATION, ratified 2026-08-30:** `brass.600` (Lc 73.7) and `terracotta.600` (Lc 71.3) fall under an APCA Lc 75 body threshold recorded in the Atelier config. Both clear WCAG AA and are ratified for their band-ink text roles. This is NOT a defect. A future `contrast_check` or `a11y_audit` finding against `brass.600`, `terracotta.600`, or `brass.300` must be read against this deviation and must NOT be treated as a new regression, nor as grounds to change any of these values.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Highest | The mechanism-1 cascade override: mechanism 1 wins at runtime, so any token corrected only in mechanisms 2/3 is silently reverted | This exact defect was caught by design review; the step-2 test asserts the corrected value in mechanism 1's generated output specifically; ordered-work step 3 fixes `semantic.json` |
| R2 | Medium-High | Visible regression from the ~80 radius and 17+ shadow call sites | Mitigated by the keep-untouched-with-deprecation-marker strategy; nothing existing changes value |
| R3 | Medium | The Atelier pipeline for `field-workbook.generated.css` was never inspected by planning or design; if it cannot be re-run, the generated file must NOT be hand-edited (its header forbids it) | Ordered-work step 1 requires this verification first; return `JOB_BLOCKED` if the pipeline cannot be re-run |
| R4 | Medium | Plan staleness: `lizbeth_spanish` has no local `.git` and is gitignored by the parent repo, so local state cannot be reconciled with the GitHub remote, and the issue #31 body was never read verbatim | Ordered-work step 0 pre-flight is the mitigation |
| R5 | Low | The literal-hex `#3d5f6b` in `semantic.json` will not track future changes to ink.slate's canonical value | Deliberate trade-off; revisit when mechanism 1 is retired |

**Rollback.** Every change is confined to the token layer plus new tests. Revert is a straight `git revert` of the commit; no data migration, no schema change, no API surface change, and no component file is touched, so there is nothing to unwind beyond the token files themselves.

**Follow-ups, out of scope here:**

- Full retirement of mechanism 1's runtime JS injection.
- A docs-only correction of two internal inconsistencies in the ratified JSON's own `$description` text (`band.advanced` asserts 7.0:1 vs measured 6.72:1; `ink.moss` asserts 6.6:1 vs measured 7.42:1 — no `$value` is affected).
- A decision on whether `--size-control-height` joins the deprecation-marker list.
- A UX pass confirming `:focus-visible` vs bare `:focus` scoping and focus behavior on composite/nested-interactive controls, needed before #33/#35/#36 wire per-component focus.

## Assumptions and decisions

**Assumptions, labeled:**

- `ADOPTION-PLAN.md` plus `issue-map.json` are treated as the specification of record for issue #31, because the verbatim issue body is unreachable. Verification step: ordered-work step 0 pre-flight.
- `:focus-visible` (not bare `:focus`) is the intended pseudo-class scope. The ratified text does not specify it. Flagged for a UX pass before downstream per-component focus wiring; verification step: ordered-work step 0/browser validation re-check.
- `shadow.brass` is the eventual hard-offset successor to `--shadow-print` (same role, same color `#a07e48`), though their offsets differ slightly (5px vs `.3rem`). Noted, not resolved; does not affect the deprecation-marker decision.
- The component tier is director-authored scaffolding, not ratified.

**Standing authorization.** The user has already granted standing authorization covering both bounded implementation decisions and plan approvals for this milestone ("keep going until all the gh issues are finished"), so no further user checkpoint is expected before engineering. The orchestrator owns that determination. Nothing in this plan is a genuinely irreducible high-stakes decision: there is no security tradeoff, and the one place the reference contradicts itself was already ratified upstream on 2026-08-30 and is explicitly closed to re-litigation.

## Browser UI dialog policy

REQUIRED — this is a browser-rendered React UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are prohibited. Any acknowledgement or confirmation must use an app-owned accessible modal, with inline validation where it serves the user better. The repo currently has ZERO native dialog call sites, enforced by `src/__tests__/nativeDialogPolicy.test.ts`. Issue #31 must introduce none; a deterministic no-native-dialog source scan is a required check even though a token-only change is unlikely to add one.

## Browser UI validation

**Launch/readiness:** `npm run dev` with the dev server bound to port 4319 — NOT the Vite default 5173 and outside the reserved 5173-5195 range. `vite.config.ts` currently sets `server.port: 5173`; override via CLI (`npm run dev -- --port 4319 --strictPort`) rather than editing the committed config, since a config change is outside this issue's token-layer scope. Readiness = the Vite ready line plus a successful load of the base URL.

**Base URL:** `http://localhost:4319`

**Fixture/reset:** use the existing Supabase development data. This is a presentation-layer token change with no data dependency; no seeding or reset is required beyond an authenticated student session and an authenticated owner session to reach the admin routes.

**Journeys (confirmed real routes, verified against `src/App.tsx` and `src/hooks/useRoute.ts`):**

1. `/roadmap` — RoadmapPage. Exercises `--color-roadmap-completed`/`current`/`locked`.
2. `/roadmap/:enrollmentId/week/:weekNumber` (matched via `matchWeekDetailRoute`) — WeekDetailPage reading sheet. Exercises `--color-surface-reading-default`/`text`.
3. `/` unauthenticated — login screen. Primary surface for the focus-ring delta check (input field plus submit button).
4. `/admin/students` and `/admin/dashboard` — AdminStudentsPage / OwnerDashboardPage. Both grep-confirmed to contain live `--shadow-print` usage and `brass.500`.
5. `/feedback` — FeedbackPage rendering FeedbackForm, whose `.feedback-form-submit` selector is exactly what `designSystemConsistency.test.ts` asserts against.

**Viewport profiles:** 1440x900 (desktop reference artboard) and 390x844 (mobile reference artboard).

**Visible outcomes.** The defining characteristic of this job is that the expected result is NO visible regression, plus exactly ONE intentional delta.

- UNCHANGED, operationally defined: for every element on the five journeys, these computed values must be identical before and after: `border-radius`; `box-shadow` (all four components — offset-x, offset-y, blur, spread — plus color); `background-color` and `background-image` on any surface not explicitly using a new `.paper-stock--*` class; `height`/`min-height` on control elements; and any `color`/`border-color` other than the repointed focus tokens. Screenshot tolerance: 0% pixel difference on unfocused element states; a 0.1% global tolerance is permitted only for anti-aliasing noise unrelated to any token in this spec.
- CHANGED, expected: on any element already rendering a visible keyboard focus ring, the ring color changes from `#0284c7` to ink.slate `#3d5f6b` at 3px width and 2px offset. Verify by keyboard Tab navigation (NOT mouse click) on a focused primary button, a focused text input, and a focused nav/tab item, at both viewports. This must be re-verified specifically AFTER the `semantic.json` fix, since mechanism 1 is the one that actually wins the cascade. If `:focus-visible` scoping is implemented as specified, mouse-click focus should NOT show the ring; record any deviation as a finding rather than an automatic fail, since the ratified text does not mandate the scoping.
- Atelier evidence required alongside the Chrome/Playwright run: `mcp__atelier__screenshot`, `mcp__atelier__a11y_audit`, and `mcp__atelier__contrast_check` on the five journeys at both viewports, read against the recorded accepted deviation above.
- Deterministic no-native-dialog source scan.
