# Lizbeth Spanish — Field Journal Design System: Re-validate Issues #31, #32, #33 Against the Corrected Token Pipeline

**Status:** APPROVED. The user explicitly approved this plan in this session; see Section 16 for the full approval record. T1/T2 execution, tracking-issue creation, the test-file edit, and issue closure may now proceed per Section 15's downstream ownership, subject to the ordered-work sequencing (including the required Verifier pass before any issue close) in Section 7.

**Plan ID:** `lizbeth-spanish-fjds-issue31-33-revalidation`

**Backlog position:** Item 2 of the roadmap in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`. Backlog item 1 (issue #61) is complete and closed. Backlog items 3-7 (screen/component visual validation, closing out #34-#44) are out of scope here and each require their own plan and approval.

**Target repository:** `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub remote `lebobo88/lizbeth-spanish`).

---

## 1. Outcome and audience

GitHub issues **#31** (design system foundations), **#32** (typography four hands), and **#33** (token plumbing, fallback audit, and enforcement lint) were previously left "conditionally complete" pending a trustworthy Atelier token pipeline. That pipeline is now genuinely correct (verified during this planning pass and by the prior #61 reconciliation). This plan re-validates each issue's actual acceptance criteria against the corrected pipeline output so all three can be honestly closed, corrects one piece of now-stale test prose and a masking test carve-out, and records two investigated-and-dismissed candidate defects so they are not mistakenly re-raised later.

**Audience:** the T1/T2 engineer who executes this plan, and the Verifier who independently gates it before closure.

---

## 2. Scope

### In scope

1. Correct the now-false stale prose and the stale expected-RED carve-out in `src/__tests__/fieldJournalTokens.test.ts`.
2. Record, in issue #31's closing evidence, that its original `--shadow-print` deprecation-marker criterion is superseded by a later ratified decision (do not restore the marker).
3. Record two candidate defects that were investigated during planning and dismissed with evidence, so a future pass does not re-raise them.
4. Open one GitHub tracking issue for this re-validation work, comment re-validation evidence onto #31, #32, and #33, and close all four issues (the three original plus the new tracking issue) only after an independent Verifier pass.

### Non-goals

- No token **value** change of any kind. Planning-time verification found **zero value drift** across #31/#32/#33's scope (see Section 4, Finding 3).
- No change to `.atelier/tokens/field-workbook.tokens.json` values.
- No change to `src/tokens/field-workbook.generated.css`.
- No change to any `src/**/*.css` file.
- No re-litigation of already-ratified deviations: the 26px margin-hand type role, and using WCAG AA 4.5:1 (rather than APCA Lc 75) as this project's real contrast gate, under which `brass.600`/`terracotta.600` legitimately carry text because they clear 4.5:1.
- No work on backlog items 3-7 (screen/component visual validation, closing out issues #34-#44). Each needs its own plan and its own approval.
- No Docker or Supabase change.
- No edit to `lizbeth_spanish\atelier.config.json`. Only the root-level `H:\CommandCenter\orchestrator\atelier.config.json` is ever editable.
- No use of `taskkill` at any point in this work (documented history of collateral damage in this environment).

---

## 3. Evidence method and a stated limit

Issue #31/#32/#33 scope was re-derived property-by-property from the corrected pipeline output and its DTCG source, then cross-checked against the actual shipped mechanism-1 (`semantic.json`), mechanism-2 (`field-workbook.generated.css`), and mechanism-3 (`App.css`) files. The prior plan documents' claimed values were **not** trusted as ground truth; they were re-verified directly against current file contents during planning.

**Stated evidence limit:** `gh` (the GitHub CLI) is not on the read-only planning tool surface, so the verbatim current bodies of GitHub issues #31, #32, and #33 were **not** re-fetched during this planning pass. The three existing per-issue plan documents (`docs/plans/lizbeth-spanish-issue31-design-system-foundations.md`, `-issue32-typography-four-hands.md`, `-issue33-token-fallback-audit-enforcement-lint.md`) plus `design/field-journal/ADOPTION-PLAN.md` were used as the specification of record for this plan, exactly as those three plan documents themselves did. **Ordered-work Step 0, below, requires the executing engineer to fetch and re-check the live issue bodies before any edit is made**, specifically to mitigate this limit.

---

## 4. Repository findings

### Finding 1 — Genuine drift (the only remediation item; test layer only, issue #31 scope)

`src/tokens/field-workbook.generated.css` is now real `mcp__atelier__tokens_compile` output. Its header (lines 1-33) records the regeneration, the issue #61 provenance, and the J-002 fontFamily string-vs-array fix.

However, `src/__tests__/fieldJournalTokens.test.ts` still describes the shipped file as a hand transcription and still carries a live escape hatch that is now factually false in four places:

- **Lines 20-25** (file header comment): asserts the mechanism-2 block is "expected to stay RED until the real Atelier tokens_compile pipeline has" run.
- **Lines 150-154**: the `describe('Mechanism 2 generated CSS ... Atelier tokens_compile output')` block repeats the same expected-RED carve-out.
- **Line 330**: refers to "a real future `tokens_compile` run (once Atelier is restored)".
- **Line 356**: the assertion prose still calls the shipped file "the hand-transcribed generated CSS".

Beyond being inaccurate, the expected-RED carve-out is a **live masking risk**: it is an escape hatch that could silently absorb a genuine future mechanism-2 regression instead of failing the test. Remediation is prose correction plus carve-out removal, with confirmation that the corrected block actually passes green against the regenerated file (it is not a case of "make it pass," but of removing a hatch that currently permits an unconditional pass or fail without exercising the escape).

### Finding 2 — Superseded acceptance criterion (documentation only, no code change; issue #31 scope)

Issue #31's plan (`docs/plans/lizbeth-spanish-issue31-design-system-foundations.md`, "Interfaces and data" → "Migration strategy — keep-untouched-with-deprecation-marker", and ordered-work step 6) required `--shadow-print` to carry a `DEPRECATED` comment marker.

The regenerated pipeline output does **not** carry that marker on `--shadow-print` (`field-workbook.generated.css:131`). The markers are present only on `--motion-duration-short` (lines 111-112) and `--radius-medium` / `--radius-pill` / `--radius-small` (lines 116-122).

This is **correct** and must **not** be "fixed." The `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md` plan's ratified carve-outs state explicitly that `shadow.print` is live and not deprecated, with roughly two dozen consumers across 9+ files, and that it must not be deprecated or redirected. Issue #31's original criterion is superseded by that later ratified decision.

This finding must be recorded explicitly, both in this plan and in #31's closing comment, so that a future reader following #31's original plan text does not restore the marker and wrongly deprecate a live token with approximately 24 consumers.

### Finding 3 — Zero value drift across #31/#32/#33's actual scope

Verified individually against the current repository state:

**Issue #31, mechanism 2 (`field-workbook.generated.css`)** — every ratified foundation token is present at its ratified value:
- `--color-ink-1000` `#1a1512`, `--color-paper-300` `#e3dbcd`, `--color-ink-slate` `#3d5f6b`, `--color-ink-moss` `#2f5d3f`, `--color-brass-300` `#dca250`, `--color-brass-700` `#7c6136`, `--color-amber-200` `#ffd699`, `--color-accent-margin-rule` `#e0b3a5`
- `--border-width-thin` `2px`, `--border-width-rule` `3px`, `--border-color-default` `var(--color-ink-1000)`
- `--radius-none` `var(--radius-square)`, `--radius-square` `0px`
- `--shadow-card` / `-sheet` / `-brass` / `-press` / `-none`, all with literally 0 blur and 0 spread
- `--control-height` `48px`, `--hit-target-min` `44px`, `--focus-ring-width` `3px`, `--focus-ring-offset` `2px`
- `--size-control-height` correctly preserved at `2.75rem` (deliberately **not** overwritten to `48px`)
- Band tokens beginner/intermediate/advanced correct

**Issue #31's focus-ring correction** holds independently across all three mechanisms:
- Mechanism 2: `--color-focus: #3d5f6b` (line 55, corrected from `#0284c7`)
- Mechanism 1: `color.focus.ring` resolves to literal `"#3d5f6b"` (`semantic.json:36`)
- Mechanism 3: `--color-focus-ring: var(--color-ink-slate, #3d5f6b)` (`App.css:40`), the documented sole raw-hex exception, still intact

**Issue #32, mechanism 1 (`semantic.json:50-105`)** — all six ratified type roles present at ratified values:
- `display`: `68px` / `900` / `0.95` / `-0.03em`
- `heading`: `34px` / `700` / `1.15` / `-0.015em`
- `body`: `17px` / `400` / `1.6`, deferring `fontFamily` to `var(--font-family-body)`
- `target-line`: `22px` / `600` / italic / `1.4` on `{color.brass.700}`
- `label`: `12px` / `600` / `0.2em` / uppercase, with the binding non-self-referential plain-literal `fontFamily`
- `margin-hand`: `26px` / `700` / `rotate(-1.5deg)` on `{color.terracotta.600}`
- `typography.measure.reading` `62ch` present; the pre-existing `measure.reading` `65ch` correctly **not** repointed

**Issue #32's Google Fonts `@import`** at `App.css:14` is byte-intact, carrying all five required Fraunces tuples (`0,400`; `0,600`; `0,700`; `0,900`; `1,600`) plus IBM Plex Mono and Caveat.

**Critical cross-check, resolved:** the J-002 fontFamily string-vs-array bug fixed in the DTCG source does **not** affect mechanism 1. `semantic.json` still authors these as strings (`"Fraunces, serif"`, `"Caveat, cursive"`, `"\"IBM Plex Mono\", monospace"`), but `tokenSystem.ts`'s `flattenTokens` (`tokenSystem.ts:84-98`) emits the string verbatim into `--name: value;`, producing a valid two-name fallback chain. The array convention matters only to the Atelier compiler, which wraps a raw string in one pair of quotes. **Mechanism 1 is correct as authored and must not be "fixed" to arrays.**

**Issue #33** — all `--color-status-*` and `--color-roadmap-*` component tokens are present in the regenerated output (lines 67-78), built only from ratified primitives, with no new hex values introduced.

### Finding 4 — Two candidate defects investigated and dismissed with evidence

Both must be recorded in this plan and in #33's closing comment so a future pass does not re-raise them as live defects.

**(a) `--font-size-label: 0.75rem`.** This is now emitted by the pipeline (line 101), even though issue #33 step 4 retired that name by remapping `CourseWorkspace.css:1` to `--font-size-caption`. This is **not** drift: the name was legitimately re-introduced at 12px by later issues as the mono label size. `RoadmapPage.css:15`'s own comment documents "mono, `--font-size-label` / 12px, 600 weight," and `0.75rem` equals `12px`. Live consumers were verified across: `BandRoadmap.css:141`, `OwnerSettingsPage.css:253`, `PublicCatalogPage.css:160`, `FeedbackForm.css:90`, `FeedbackLedgerRow.css:169`, `RoadmapPage.css:20`, `LoginForm.css:305`, `WeekCard.css:74,85`, `ui/Field.css:15,68`, `ui/Badge.css:14`, `ui/AccountStatusPill.css:13`. Issue #33's original criterion targeted the *undefined-reference* case, which is now resolved; the current defined-and-consumed state is correct.

**(b) `color.roadmap.current` resolution path (low-severity latent naming hazard, not remediated).** Mechanism 1's `color.roadmap.current` resolves through `{color.accent.primary}` (`semantic.json:32`), and `--color-accent-primary` is owner-overridable at runtime by `BrandingContext.tsx:99`. That is the exact hazard that `color.link.text` was deliberately protected against (`semantic.json:22`). This was investigated and found **not** to be a live defect: `tokenSystem.ts:88-89` calls `resolveReference` at generate time, so mechanism 1 emits a terminal literal (`brass.500`) that the later inline-style override cannot reach. Mechanism 2 independently anchors `--color-roadmap-current` to `var(--color-brass-500)` (line 68). Both agree. This is recorded as a **low-severity latent naming hazard only** — it is not remediated under this plan, because re-anchoring it is a token change and this plan authorizes none.

---

## 5. Research evidence

None. No external or time-sensitive fact was material to this plan. All findings above are local repository file evidence, read in full during planning.

---

## 6. Design route

**Design route: none.**

Rationale, classified from the actual findings rather than by default: zero token-value drift was found, so this plan changes no shipped CSS, no component, and no rendered surface. The entire deliverable is test-prose correction, plan documentation, and GitHub issue tracking. There is no user-visible design effect and therefore no design decision to make or review. Per `docs/DESIGN-CONTRACT.md`, this correctly classifies as `none`, not `compact`.

No `DESIGN_HANDOFF` and no design review apply to this plan.

---

## 7. Ordered work

Owner for every step: **T1**, escalating to **T2** after two counted gate failures on the same step.

**Step 0 — Pre-flight: verify the live issue bodies.**
Run `gh issue view 31`, `gh issue view 32`, and `gh issue view 33 --repo lebobo88/lizbeth-spanish`. Confirm each live body matches the scope recorded in its per-issue plan document (Section 4 findings above). If any live body materially differs from what this plan assumes, **stop** and return `JOB_BLOCKED: Plan stale` rather than implementing. This step exists specifically to mitigate the `gh`-unavailable-at-planning-time limit recorded in Section 3.

**Step 1 — Open the tracking issue.**
Open one GitHub issue in `lebobo88/lizbeth-spanish` against milestone `Field Journal DS`, with a plain descriptive title (no `#N:` prefix), and labels at minimum `area:tokens` and `area:design-system`. The body must reference this plan's path (`docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md`) and state that it re-validates #31/#32/#33 against the corrected pipeline, as backlog item 2 following #61.

**Step 2 — Confirm current RED/GREEN state before touching the test.**
Run the current `src/__tests__/fieldJournalTokens.test.ts` mechanism-2 describe block against the regenerated file and record whether it passes green today, as observed, without assuming the answer. This determines whether Step 3 is prose-only or also needs an assertion correction.

**Step 3 — Correct the test file.**
Remove the stale expected-RED carve-out and correct the now-false prose at `fieldJournalTokens.test.ts` lines 20-25, 150-154, 330, and 356 (see Finding 1). The mechanism-2 block must assert unconditionally against the regenerated file. Do not weaken any assertion to make it pass. If an assertion genuinely fails after the carve-out is removed, that is a real finding: stop and report it rather than relaxing the assertion.

**Step 4 — Confirm no other #31/#32/#33-owned test still asserts hand-written values.**
`statusColorContrast.test.ts`, `typographyFourHands.test.ts`, and `tokenFallbackAuditLint.test.ts` were already re-pointed by the #61 reconciliation plan's ordered-work step 9 — confirm this, do not redo it. Additionally check `tokenSystem.test.ts`, `designSystemConsistency.test.ts`, and `contrast.test.ts` for the same self-confirming pattern (asserting against a hand-authored expectation rather than the pipeline's actual output) and report findings. Correct only what is genuinely self-confirming against the token layer; do not make speculative changes.

**Step 5 — Confirm the pipeline guard is intact.**
Confirm `scripts/verify-token-pipeline.mjs` and `src/__tests__/tokenPipelineOracle.test.ts` still pass.

**Step 6 — Run the full deterministic gate.**
`npm run lint`, `tsc`, `npm test`, plus the deterministic no-native-dialog source scan (`src/__tests__/nativeDialogPolicy.test.ts`).

**Step 7 — Independent Verifier pass.**
Required before any issue is closed.

**Step 8 — Comment and close.**
Comment the re-validation evidence onto #31, #32, and #33. Each comment must state:
- (a) that the issue was re-validated against the regenerated pipeline on this date, with zero token-value drift found, and the specific properties checked;
- (b) for #31 only: the Finding 2 supersession (that `--shadow-print`'s missing deprecation marker is correct and ratified, and #31's original marker criterion is superseded), and the Finding 1 test correction;
- (c) for #33 only: the Finding 4(a) `--font-size-label` dismissal and the Finding 4(b) low-severity latent hazard note.

Then close #31, #32, #33, and the Step 1 tracking issue via `gh issue close`, **only after** the Verifier pass in Step 7 succeeds.

---

## 8. Interfaces and data

No API, schema, data-model, or token-surface change. No custom property is added, removed, renamed, or revalued. The only file edited under this plan is one test file: `src/__tests__/fieldJournalTokens.test.ts`.

---

## 9. Acceptance and validation

- `fieldJournalTokens.test.ts` contains no "expected to stay RED" carve-out and no prose describing the shipped generated CSS as hand-transcribed; its mechanism-2 block asserts unconditionally and passes green.
- No assertion anywhere was weakened or deleted in order to achieve a green result.
- `git diff` confirms **zero** change to: `src/tokens/field-workbook.generated.css`, `.atelier/tokens/field-workbook.tokens.json`, `src/tokens/semantic.json`, `src/tokens/primitives.json`, `src/App.css`, and every `src/**/*.css` file.
- `scripts/verify-token-pipeline.mjs` and `tokenPipelineOracle.test.ts` pass.
- `npm run lint` is clean, `tsc` is clean, full `npm test` is green.
- The deterministic no-native-dialog source scan passes.
- An independent Verifier pass succeeds.
- #31, #32, #33, and the tracking issue each carry the required evidence comment and are closed.

---

## 10. Risks and rollback

**Overall risk: low.** One test file changes; no production code, no rendered surface, no data is touched.

- **Highest risk, explicitly guarded:** Step 3 could tempt an engineer to relax an assertion to make a previously-RED block pass. That would recreate the exact self-confirming-test failure mode this entire backlog exists to eliminate. Section 9's acceptance criteria forbid this and require reporting a genuine failure instead of masking it.
- **Second risk:** an engineer reading issue #31's original plan text in isolation could "restore" the `--shadow-print` deprecation marker, wrongly deprecating a live token with approximately 24 consumers. Mitigated by Finding 2 being recorded both in this plan and in #31's closing comment.
- **Third risk:** closing #31/#32/#33 could imply more validation occurred than actually took place. This plan re-validates the **token layer only**; it does not re-validate rendered pixel fidelity, which is deferred to backlog items 3-5. Each closing comment must state this limitation explicitly rather than implying full visual sign-off.
- **Rollback:** revert the single test-file commit. Nothing here is irreversible; there is no migration, no schema change, and no persisted state. Issue closure is reversible by reopening.

---

## 11. Assumptions and decisions

- **Assumption, verified at Step 0 rather than trusted outright:** `design/field-journal/ADOPTION-PLAN.md` plus the three per-issue plan documents are the specification of record for #31/#32/#33, because the verbatim current issue bodies were not reachable from the planning tool surface (Section 3).
- **Decision:** mechanism 1's string-authored `fontFamily` values are correct and must not be converted to arrays. The J-002 array fix applies only to the Atelier-compiled DTCG source, not to `semantic.json`.
- **Decision:** Finding 4(b) is recorded, not remediated, because re-anchoring `color.roadmap.current` would be a token change, and this plan authorizes none.
- **Decision:** `design_route: none`, justified from the findings in Section 6.
- **Still needs user approval:** this plan itself, and separately, each of backlog items 3-7 when they are planned.

---

## 12. Browser UI dialog policy

The standing repository invariant applies unchanged: no native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts anywhere in this browser-rendered React UI. Acknowledgement and confirmation use the app-owned accessible modal, with inline validation where it better serves the user. This plan introduces no dialog surface and no UI code change, but the deterministic no-native-dialog source scan (`src/__tests__/nativeDialogPolicy.test.ts`) remains a required gate at ordered-work Step 6.

---

## 13. Browser UI validation

**Not applicable**, and this justification is stated explicitly here so it is auditable rather than an omission. This plan changes exactly one test file and no rendered surface, so there is no visible outcome for a Browser Validator to check and no baseline that could move. Rendered-fidelity validation for these surfaces is deliberately sequenced as backlog items 3-5 of `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`, each requiring its own plan and approval.

If Step 2 or Step 3 unexpectedly forces any change to a shipped CSS or component file, that invalidates this justification: the job must return `JOB_BLOCKED: Plan stale` for re-planning with a full browser brief, rather than proceeding without one.

For reference when those later backlog items run: the Vite dev server is **already running** at `http://localhost:5173/` and must be reused; no `taskkill` is authorized; authenticated routes require the claude-in-chrome-backed Browser Validator, because Atelier's `screenshot`/`baseline_update` tools run an isolated, unauthenticated session.

---

## 14. Judge route

**Not required for this plan.** The work is a documentation and test-prose correction with zero token-value drift and no rendered-surface change. Per `docs/JUDGE-CONTRACT.md`, selective Codex checkpoints are reserved for plan/code/evidence/visual review where cross-vendor judgment adds material risk coverage; this plan's risk profile (Section 10: overall low, single test file, fully reversible) does not meet that bar. No judge call budget is allocated or consumed by this plan. If Step 3 or Step 4 surfaces an unexpected genuine assertion failure that implies a real regression, escalate through the standard T1→T2 gate-failure path in `docs/BUILD-CONTRACT.md` rather than invoking a judge checkpoint.

---

## 15. Engineering mode and ownership

- **Engineering mode:** standard.
- **Team authorization:** not applicable (no agent team required).
- **Downstream owner:** `engineering-fleet` (T1 first, T2 on two counted gate failures per step).

---

## 16. Approval gate

This plan required explicit user approval before T1/T2 execution begins. The user's standing session goal to carry approved work to completion without re-approving already-authorized steps does not, on its own, extend to this document. This plan correctly declined to treat the standing `/goal` alone as approval; that gate is now satisfied by a direct statement.

**Approval record.**

- Approved by: the user, rob.hasselbach@gmail.com.
- Verbatim reply: "approve. continue autonomously moving forward".
- Context: the orchestrator presented the compact plan summary (re-validate #31/#32/#33 against the corrected token pipeline; zero token-value drift found; fix one stale test artifact in `fieldJournalTokens.test.ts`; record a superseded criterion and two dismissed candidate defects; open a tracking issue; close all four issues after an independent Verifier pass) and asked, "Do you approve this plan?" The user's reply was sent in direct response to that question, regarding this specific plan document.
- When: this session (2026-09-02).
- Classification: a direct, plan-referencing approval, not an approval inferred from the standing session goal alone.

T1/T2 execution may now proceed per Section 15's downstream ownership, subject to the ordered-work sequencing in Section 7 (including the required Verifier pass before any issue close).

**Additional forward authorization granted by the same reply, scoped beyond this plan.** The same reply also addressed the rest of this backlog sequence: backlog items 3-7 of the roadmap established in `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md` (authenticated-route visual sweep for #38-#42, unauthenticated routes #37/#43, component fidelity #34-#36, #44 derived pages, and final backlog closure). Because those items were already disclosed to the user as the established next steps in that roadmap document, this reply is recorded as forward authorization for the orchestrator to proceed through planning and execution of items 3-7 without requiring a separate individual "approved"-style reply for each one.

This forward authorization is explicitly bounded:

- It does **not** waive presenting each subsequent plan (items 3-7) to the user in summary form before execution begins, so the user retains visibility and the ability to interject or redirect before any T1/T2 work starts on that item.
- It waives only the requirement to wait for a separate affirmative "approved" reply after each such summary is presented; the orchestrator may proceed once the summary has been presented, absent a user objection.
- It does not extend to any item outside backlog items 3-7 of the named roadmap, and it does not authorize skipping any other required gate (Verifier pass, Browser Validator pass where applicable, judge checkpoints per `docs/JUDGE-CONTRACT.md`, or the standing prohibitions on unrequested commit/push/PR/deploy actions).
