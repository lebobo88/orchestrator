# Lizbeth Spanish — Issue #100: Modal Dismiss-Suppression Policy Resolution

## Status

**APPROVED.**

- **Approver:** the user (rob.hasselbach@gmail.com / lebobo88).
- **Approval date:** 2026-09-07.
- **Basis:** the user's own explicit statement, verbatim: **"yes proceed."** This followed the user's review of a compact summary covering: the six-site correction (issue #100 named five and misclassified `HardDeleteStudentModal`); the four-reconcile / two-named-exception split; the finding that the ARIA APG contains no data-loss carve-out, so the "WCAG/ARIA APG data-loss exception" cited in the shipped code comments is a practitioner gloss rather than a spec provision; the newly-found `ariaDescribedBy` defect at exactly the two sites where dismissal is removed entirely; and the design-review correction replacing the unreliable `role="status" aria-live="polite"` announcement with `aria-describedby` on focus entry.

This is a Phase 5 (pattern 5, modal surfaces) resolution under the approved umbrella plan `docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md`. That umbrella plan (line 347) explicitly parked this decision pending a user ruling and named issue #100. This document does not modify, restate as approved, or expand the umbrella plan's scope, no-touch list, or standing authorizations; it cross-references them and does not duplicate them.

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (`lebobo88/lizbeth-spanish`), `main` at `fbe2d21`.

---

## 1. Purpose and the acceptance criterion this plan must satisfy

GitHub issue #100 (labels: `bug`, `severity:S3`, `area:modal-keyboard`, `area:accessibility`) was closed on 2026-09-05 with no comment and no recorded decision — the comment thread was verified empty — and was reopened for exactly that reason. Its acceptance criterion, verbatim:

> "A decision is recorded (plan amendment or code change) for how these five modals reconcile with the 'Escape plus explicit close' pattern, and applied consistently across all five sites."

This plan exists to satisfy that criterion honestly. The prior attempt's failure was not a wrong technical choice; it was a failure to persist any decision at all. Accordingly, this document treats recording the decision as the actual deliverable, not as a preamble to code. Every hedge, negative finding, and unresolved question identified during planning is preserved below exactly as found. Where something is not settled, this plan says so rather than rounding it up to a confident claim.

Issue #100 also undercounted the affected sites (it named five) and misdescribed one of them. Both of those errors are corrected on the record in Section 3.

---

## 2. Scope

### In scope
- The six `suppressDismiss` call sites identified in Section 3.
- The advisement affordance (a single sentence) and its `aria` wiring at those six sites.
- Correcting two fabricated-citation code comments (verbatim replacement text in Section 8).
- One new CSS parity test guarding against silent divergence of duplicated styling.
- Recording this decision durably in this plan and, per the umbrella plan's issue-logging policy, as a comment on GitHub issue #100.

### Explicitly out of scope (no-touch)
- No change to any `suppressDismiss` **value** at any site.
- `Modal.tsx`, `useFocusTrap.ts`, `Modal.css` — byte-unchanged.
- `CourseWorkspacePage.tsx`, `CourseWorkspace.css`, `DisableStudentModal`.
- `.destructive-warning` and `.temp-password-warning` styling blocks.
- The cross-site focus-restoration inconsistency (Section 9) — routed to a separate pass, not bundled here.
- `lizbeth_spanish/atelier.config.json` — standing directive, never edited.
- `taskkill` of any kind — never used, standing process hazard.

### Governing umbrella plan
`docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md` (APPROVED). It is the authority for program-wide scope, the no-touch list, the GitHub issue-logging policy, and the standing commit/push/PR/merge authorization. Those are not restated here; they govern by reference.

---

## 3. The record correction — six sites, not five

Issue #100 named five sites and misdescribed one of them (it claimed `HardDeleteStudentModal` used `suppressDismiss={true}`; it actually uses `suppressDismiss={isLoading}`, a conditional value). All line numbers cited in issue #100 are stale against current `main`. The following table is verified directly against `main` at `fbe2d21` by direct grep, and is the corrected record.

| # | File : line | Modal / phase | `suppressDismiss` value | Kind |
|---|---|---|---|---|
| 1 | `AdminStudentModals.tsx:161` | `HardDeleteStudentModal` (typed-email-confirmation delete) | `{isLoading}` | Conditional |
| 2 | `AdminStudentModals.tsx:444` | `WipeSaveModal` | `{isLoading}` | Conditional |
| 3 | `AdminStudentModals.tsx:677` | `ReissueAccessModal`, confirm phase | `{isLoading}` | Conditional |
| 4 | `AdminStudentModals.tsx:738` | `ReissueAccessModal`, reveal phase (one-time password) | `{true}` | Unconditional |
| 5 | `RegisterStudentModal.tsx:212` | Add-Student, email phase | `{isLoading}` | Conditional |
| 6 | `RegisterStudentModal.tsx:275` | Account-Created, reveal phase (one-time password) | `{true}` | Unconditional |

**Contrast sites, verified still `suppressDismiss={false}` and explicitly out of scope:** `CourseWorkspacePage.tsx:248` ("Apply reconciliation?"), `:439` ("Release this lesson?"), `:454` ("Revoke access?"). Line 453 carries the comment "Escape, backdrop and ✕ all cancel safely." Line 454 is also the codebase's only existing `ariaDescribedBy` precedent, pointing at a bare `<p id="revoke-warning">` with no live-region role.

### What `suppressDismiss` actually does (verified against source)

- Prevents the Escape keydown listener from ever attaching (`useFocusTrap.ts:89`).
- Makes backdrop clicks no-ops (`Modal.tsx:63`).
- Removes the ✕ close button from the DOM entirely (`Modal.tsx:92`: `{!suppressDismiss && (<button aria-label="Close modal">✕</button>)}`).
- Does **not** disable the focus trap or focus restoration — both run unconditionally on `[isOpen]`.
- Is read fresh each render and sits in the Escape effect's dependency array `[isOpen, suppressDismiss, onClose]`, so a mid-lifecycle `isLoading` flip re-subscribes correctly.

### The actionable gap

None of the six `suppressDismiss` sites passes `ariaDescribedBy`. The two dialogs where dismissal is removed entirely (sites 4 and 6) are precisely the ones that never announce why. A screen-reader user at those sites gets only the dialog title on open, with no explanation for why Escape and the close control do nothing (sites 1/2/3/5) or are absent (sites 4/6).

### No coupling to concurrent issue #57 work

PR #136 added a modal-root wrapper and `inertBoundaryRef` to `useFocusTrap`. That inertness effect depends only on `[isOpen]` and is entirely separate from the `suppressDismiss`-gated Escape effect. Both `suppressDismiss` branches are untouched by that work.

### Shared-component risk

`Modal.tsx` and `useFocusTrap.ts` are shared and locked by roughly eleven dedicated test files: `Modal.test.tsx`, `Modal-FocusTrap-ShiftTab.test.tsx`, `Modal-FocusTrap-Boundaries.test.tsx`, `ModalStackingAndInertness.test.ts`, `modal-scroll-overflow.test.ts`, `AdminStudentModals.test.tsx`, `AdminStudentModals-DismissPolicy.test.tsx`, `AdminStudentModals-DismissalRegression.test.tsx`, `AdminStudentModals-CssImport.test.ts`, `RegisterStudentModal.test.tsx`, `RegisterStudentModal-FocusRestore.test.tsx`, `RegisterStudentModal-StaleError.test.tsx`, plus `e2e/issue-57-modal-background-inertness.spec.ts`. This plan deliberately requires no change to `Modal.tsx` or `useFocusTrap.ts`, which is a large part of why it is low-risk.

Note: `e2e/issue-57-modal-background-inertness.spec.ts:195` refers to "the five `suppressDismiss=true` sites named in decision D-5" — that comment is now known to be inaccurate on both count and condition. Correcting it is not required scope; if a T1 job happens to touch that file for another reason, correct it opportunistically.

---

## 4. The recovered provenance — the crux of why #100 was reopened

This section exists because the provenance of the original decision is the actual reason issue #100 could close once with nothing retrievable, and it deserves its own clearly marked place rather than being folded into background prose.

The shipped code comments claim: "The user re-confirmed the batch-1 split explicitly on 2026-09-05 after a read-only investigation surfaced the conflict." A prior audit correctly flagged that claim as unverifiable from any retrievable artifact.

**It is in fact verifiable, and the orchestrator attests to it directly from session history:** the user asked for detail before deciding ("issue #100 you have to give me more info and details so i can make a proper decision"), was walked through the conflict, and then stated verbatim: **"agreed as recommended for issue 100."**

The decision is therefore genuine and user-made, not an agent's unilateral choice. What was missing was **persistence** — it was implemented in code (commit `40a6fbd`) but never written to any plan document or to the issue. That gap is exactly what issue #100's acceptance criterion names.

**This provenance was recovered from interactive session history, not from a durable artifact.** Recording it here is what converts it into a durable one. That is stated plainly, not as a caveat to bury: prior to this document, "the user approved it" rested on conversational memory rather than anything retrievable independently of this session.

### Scope limit of that approval — must be recorded, not glossed over

The user's 2026-09-05 decision authorized the **batch-1 dismissible/suppressed split**. A later refinement — gating suppression on `isLoading` rather than applying it unconditionally — went beyond that approval and **has never been ratified**. This plan's recommendation on that refinement (Decision D-1, Section 7) therefore requires explicit new user approval. It is not treated as already settled.

### Documented vs. undocumented, precisely

- `docs/plans/lizbeth-spanish-qa-sweep-remediation-batch-1.md:144` (at the orchestrator root, not in the target repository) genuinely records the 2026-08-29 flat-`false` decision.
- The later `isLoading`-gating refinement is recorded **nowhere** — not in any plan document, not in the issue — until this plan.

### Prior conflict, as shipped in code comments

A 2026-08-29 batch-1 design handoff flipped these sites to dismissible. Codex `CODE_REVIEW J-35-001` later re-suppressed all of them blanket-style in an uncoordinated commit. The shipped code declares batch-1 binding and adds the `isLoading` gate so that J-35-001's genuine underlying concern — unmounting mid-irreversible-mutation — is honored precisely rather than bluntly.

---

## 5. The headline decision: reconcile vs. named exception

This is the direct answer to issue #100's acceptance criterion and is the single most important content of this plan.

**Sites 1, 2, 3, 5 (conditional, `isLoading`-gated) RECONCILE** with the universal modal pattern — "focus trap, focus return to trigger, Escape plus an explicit close, never backdrop-only dismissal" (umbrella plan, line 226). They are fully conformant while idle and depart from the pattern only during a bounded, self-terminating in-flight window that closes via `finally { setIsLoading(false) }` on both success and failure.

**Sites 4 and 6 (unconditional, one-time-password reveals) DO NOT RECONCILE.** Escape and the ✕ close control are permanently and unconditionally absent. This is a deliberate, permanent, **named exception** to the universal pattern — not a reconciliation with it. Conformance is intentionally not achieved at these two sites. The advisement text described in Section 6 is a **compensating control** that makes the exception honest and navigable to a keyboard or screen-reader user; it does not achieve conformance and must never be described as though it does.

This explicit split — rather than one blended word covering both cases — is what closes the gap that let issue #100 close once with nothing retrievable: the record now states plainly which sites conform to the universal pattern and which are a standing, permanent exception to it.

### Per-site disposition

| # | Site | Disposition | Advisement id | Mechanism |
|---|---|---|---|---|
| 1 | `AdminStudentModals.tsx:161` (HardDelete) | Reconciles | `hard-delete-inflight-notice` | Conditional, live-region |
| 2 | `AdminStudentModals.tsx:444` (WipeSave) | Reconciles | `wipe-save-inflight-notice` | Conditional, live-region |
| 3 | `AdminStudentModals.tsx:677` (Reissue confirm) | Reconciles | `reissue-confirm-inflight-notice` | Conditional, live-region |
| 4 | `AdminStudentModals.tsx:738` (Reissue reveal) | Does not reconcile — named exception | `reissue-reveal-dismiss-notice` | Always present, bare (no role/aria-live) |
| 5 | `RegisterStudentModal.tsx:212` (email phase) | Reconciles | `register-email-inflight-notice` | Conditional, live-region |
| 6 | `RegisterStudentModal.tsx:275` (account-created reveal) | Does not reconcile — named exception | `register-reveal-dismiss-notice` | Always present, bare (no role/aria-live) |

### Assessment on the merits (not merely "it was approved")

The `isLoading`-gated **policy** is judged right on its own terms: it targets exactly the interval where dismissal risks unmounting an irreversible mutation mid-flight, and nowhere else. The **implementation** was incomplete: the ✕ vanishes from the DOM and Escape/backdrop silently do nothing with zero visible or announced indication. That silence — not the suppression policy itself — is the actual defect this plan addresses.

The two permanent reveal-phase suppressions are defensible in rationale once the fabricated citation (Section 8) is corrected: the rotation/creation has already committed server-side, the temporary password lives only in component state and nowhere else, and "Done" is the sole exit with no equivalent outcome Escape could stand in for. But they were not well implemented: no `aria-describedby` and no in-dialog explanation left a keyboard or screen-reader user's only route to understanding "Done is my one exit" as trial-and-error.

---

## 6. The uniform rule and delivery mechanisms

### The uniform rule (mechanical, for the implementing engineer)

> Whenever a `Modal` instance's `suppressDismiss` is `true` — conditional or permanent — it renders exactly one short, calm, non-interactive advisement sentence as the first child of its modal-body, explaining why Escape/backdrop/close are unavailable right now. Whenever `suppressDismiss` is `false`, no advisement renders. The sentence's `id` is passed through `Modal`'s existing `ariaDescribedBy` prop; that prop is never pointed at multi-paragraph or list content. No site is ever suppressed without an accompanying reason rendered in the dialog.

This requires zero changes to `Modal.tsx` or `useFocusTrap.ts`; both already support this mechanically via existing `ariaDescribedBy` and `suppressDismiss` props.

### Two distinct delivery mechanisms — required, not stylistic

- **Sites 1/2/3/5:** the advisement paragraph is inserted as a state-driven update into an already-open, already-established dialog when `isLoading` flips `true`. A live region reliably announces content that changes inside an established region, so these use `<p className="dismiss-advisement" role="status" aria-live="polite" id="...">`. `ariaDescribedBy = isLoading ? '<id>' : undefined`.
- **Sites 4/6:** the advisement paragraph mounts in the same render that creates the entire dialog subtree (`{phase === 'reveal' && (<Modal>…)}` at `AdminStudentModals.tsx:714-739` and `RegisterStudentModal.tsx:254-277`). Content arriving together with a live region's own first insertion is unreliably announced by most screen readers, so `role`/`aria-live` are omitted entirely here: `<p className="dismiss-advisement" id="...">`, exposed solely via `ariaDescribedBy` and read on focus entry when `useFocusTrap` focuses the dialog container on open. This matches the existing `CourseWorkspacePage.tsx:454-456` precedent and avoids double-wiring one element as both a live region and an accessible description.

### Verbatim advisement copy per site

| # | Site | Copy |
|---|---|---|
| 1 | HardDelete | "Deleting this account now. This window can't be closed until it finishes." |
| 2 | WipeSave | "Wiping this save now. This window can't be closed until it finishes." |
| 3 | Reissue confirm | "Re-issuing the password now. This window can't be closed until it finishes." |
| 4 | Reissue reveal | "This password is shown once and won't be shown again, so this window stays open until you select Done." |
| 5 | Register email | "Creating the account now. This window can't be closed until it finishes." |
| 6 | Register reveal | Same sentence as site 4. |

**Placement at every site:** first child of the existing content wrapper div (`.hard-delete-modal-content`, `.wipe-save-modal-content`, `.reissue-access-modal-content`, `.temp-password-reveal-content` — all four verified to carry no CSS today), above the existing student-email line and above the untouched warning boxes.

### Visual spec

```css
.dismiss-advisement {
  margin: 0 0 var(--space-4) 0;
  color: var(--color-ink-700);
  font-size: var(--font-size-caption);
  font-weight: 400;
}
```

All three tokens are pre-existing and independently verified: `--color-ink-700` = `#504940`, `--font-size-caption` = `0.8125rem`, `--space-4` = `1rem`. Contrast of `#504940` on the modal's actual `#faf8f4` background = 8.36:1 (APCA Lc 86.22), an AA pass; the arithmetic was independently re-verified.

This is deliberately **not** the `.destructive-warning` (error-bordered, icon) or `.temp-password-warning` (amber-bordered) treatment — the advisement is status/instructional information, not a warning. Distinctness is structural (no border, no fill, no icon), not color-only. No fixed height, no `nowrap`, no overflow clipping — the text wraps naturally per WCAG SC 1.4.10. The element never receives focus (plain `<p>`, no `tabindex`). No new hex or px literal is introduced anywhere.

### CSS duplication guard

`.dismiss-advisement` is declared bare-scoped and byte-identical in **both** `AdminStudentModals.css` and `RegisterStudentModal.css`, deliberately not centralized into `Modal.css`, matching this codebase's existing per-component-file discipline (the same reasoning that keeps `.destructive-warning` and `.temp-password-warning` un-merged). Because both files co-load on the same admin page, this reproduces the *shape* of this program's documented cascade-collision hazard (umbrella plan lines 235-236) — there is no live bug today since the rules are identical, but nothing currently enforces that they stay identical.

**Required mitigation, in scope, not optional:** a new test file `src/__tests__/DismissAdvisement-CssParity.test.ts` that reads both CSS files from disk, extracts each `.dismiss-advisement { ... }` block by regex, and asserts they are string-identical. This follows the codebase's existing static-source-check convention (`AdminStudentModals-CssImport.test.ts`, `flashcardsOverlayGeometry.test.ts`, `weekDetailFooterGeometryCss.test.ts`) — a source-level `fs`-read check, not a jsdom render check, because jsdom applies no real CSS.

Reviewer's advisory note, carried forward: the extraction regex must be anchored so that a future `@media` block containing `.dismiss-advisement` in either file cannot cause a false parity pass or fail.

### Stacked confirm-discard on Escape — rejected

Rejected at all six sites, on these grounds:
- Idle dismissal at the conditional sites already produces an outcome identical to Cancel, so there is no divergent discard branch to confirm.
- The in-flight window is fully inert by design, so no dismissal event exists to intercept.
- The reveal phases have no discardable content.
- `useFocusTrap` traps Tab against exactly one `containerRef` and does not model nesting.
- Research (Section 9) found no primary-source verdict on stacking either way.
- Sites 1 and 2 do have a typed-confirmation string an idle dismissal would lose, but the settled batch-1 split already authorizes idle dismissal there, and the cost is retyping a short string.

If pursued later, any such mechanism must be an app-owned modal (native `confirm()` is prohibited by the browser UI invariant), must not double-register on the outer dialog's Tab-trap `containerRef`, must restore focus to the original typed input rather than the page trigger, and must share rather than duplicate the outer dialog's inert-boundary ancestor-walk. This is not recommended and not scoped here.

---

## 7. Decision register — resolved by user approval, 2026-09-07

This plan made recommendations. The user's explicit "yes proceed" on 2026-09-07 (see Status, above) resolves all four of the following decisions. Step 2 (code) may now proceed under Section 11's gates.

| ID | Decision | Recommendation | Status |
|---|---|---|---|
| D-1 | Ratify the `isLoading`-gating refinement at sites 1/2/3/5. The user's 2026-09-05 decision authorized the batch-1 split; this refinement went beyond it and had never been ratified until now. | Ratify — the policy targets exactly the mid-flight risk window and nothing else, and the advisement closes the silence that was its only real defect. | **RESOLVED — APPROVED, 2026-09-07.** Grounds: the in-flight window is bounded and self-terminating, and it genuinely protects against unmounting mid-irreversible-mutation, which was Codex `CODE_REVIEW J-35-001`'s real concern. **Accepted cost, recorded honestly rather than glossed over:** the keyboard contract changes mid-dialog with no visible indication to the user at the moment the change occurs — Escape and the close control silently stop working for the duration of the in-flight window. |
| D-2 | Accept sites 4 and 6 as a permanent, named exception to the universal Escape-plus-explicit-close pattern, on the compensating-control basis, with conformance intentionally not achieved. | Accept. | **RESOLVED — APPROVED, 2026-09-07,** as a permanent named exception. The credential is unrecoverable, already committed server-side, and exists only in component state. This is an explicit, named departure from the "Escape plus explicit close" pattern, not a claim of conformance, and must never be described as conformant. |
| D-3 | Confirm the resolution is documentary and code, not documentary alone. | Both, as scoped — the decision record satisfies the criterion's letter, but the missing `aria-describedby` is a real defect the criterion's "applied consistently" clause reaches. | **RESOLVED — APPROVED, 2026-09-07.** Both, as scoped. |
| D-4 | Whether the historical batch-1 handoff quotation, removed from the inline code comments by this plan's Step 5, should be preserved in this plan's background section for audit purposes. | Yes — preserve it (done in Section 4 above), which is precisely the durability this whole exercise is about. | **RESOLVED — APPROVED, 2026-09-07.** Preserved in Section 4 above. |

---

## 8. The two code-comment corrections — verbatim, paste-ready

These replace `AdminStudentModals.tsx:721-729` and `RegisterStudentModal.tsx:261-269`. The already-accurate grounds paragraphs at `AdminStudentModals.tsx:730-737` and `RegisterStudentModal.tsx:270-274` are **kept unchanged** — do not replace them.

### `AdminStudentModals.tsx` replacement

```
DISMISS POLICY: this is a deliberate, permanent, and NAMED EXCEPTION to this codebase's universal modal pattern -- "focus trap, focus return to trigger, Escape plus explicit close, never backdrop-only dismissal" (docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md:226). Escape and the header close (X) are permanently and unconditionally absent at this site; this phase does not conform to that pattern and is not claimed to. The on-screen advisement text (issue #100 resolution) is a compensating control, not a substitute for conformance.

There is no W3C WCAG or ARIA APG exception for data loss -- the APG modal-dialog pattern states Escape closes the dialog with no destructive-action carve-out; an earlier version of this comment cited one and that citation was wrong. The closest available authority is WCAG 2.2 SC 2.1.2's advisement clause, which permits a non-standard exit method PROVIDED the user is told how to use it -- an imperfect analogical fit, not a squarely-on-point rule, since 2.1.2 is a keyboard-trap provision and this is a deliberate one-time-secret exception, not a trap. It is cited as the closest available authority, not as dispositive.

The 2026-08-29 batch-1 design handoff and the later Codex CODE_REVIEW J-35-001 agree on this site -- it is one of the two one-time-secret reveals the batch-1 handoff explicitly exempts. The user re-confirmed that split on 2026-09-05. This comment corrects only the citation and names the exception explicitly; it does not change the decision.
```

### `RegisterStudentModal.tsx` replacement

Same structure, with the second paragraph additionally naming and correcting the copy-paste error, and the closing paragraph adjusted accordingly:

```
DISMISS POLICY: this is a deliberate, permanent, and NAMED EXCEPTION to this codebase's universal modal pattern -- "focus trap, focus return to trigger, Escape plus explicit close, never backdrop-only dismissal" (docs/plans/lizbeth-spanish-fjds-full-app-conformance-closure.md:226). Escape and the header close (X) are permanently and unconditionally absent at this site; this phase does not conform to that pattern and is not claimed to. The on-screen advisement text (issue #100 resolution) is a compensating control, not a substitute for conformance.

There is no W3C WCAG or ARIA APG exception for data loss -- the APG modal-dialog pattern states Escape closes the dialog with no destructive-action carve-out; an earlier version of this comment cited one and that citation was wrong. It also copy-pasted the word "reissuing" from a different modal's justification -- this site is an account CREATION, not a reissue, so both the citation and that wording were wrong here. The closest available authority is WCAG 2.2 SC 2.1.2's advisement clause, which permits a non-standard exit method PROVIDED the user is told how to use it -- an imperfect analogical fit, not a squarely-on-point rule, since 2.1.2 is a keyboard-trap provision and this is a deliberate one-time-secret exception, not a trap. It is cited as the closest available authority, not as dispositive.

The 2026-08-29 batch-1 design handoff and the later Codex CODE_REVIEW J-35-001 agree on this site -- it is one of the two one-time-secret reveals the batch-1 handoff explicitly exempts. The user re-confirmed that split on 2026-09-05. This comment corrects the citation and the copy-paste error, and names the exception explicitly; it does not change the decision.
```

Note for the record: the copy-pasted "reissuing" in a comment justifying account **creation** is itself evidence the original citation was boilerplate rather than site-specific reasoning — a further reason it needed correcting rather than merely footnoting.

---

## 9. Research evidence, standards basis, and what is NOT settled

This section preserves a nested Researcher pass against current W3C sources (accessed 2026-09-07). The full source ledger lives in the Planner chain; the load-bearing findings below must survive into any implementation or future audit unchanged.

**The central negative finding:** the ARIA APG modal-dialog pattern states "Escape: Closes the dialog" with **no exception, carve-out, or conditional language** for destructive actions, unsaved data, or data loss. The alertdialog pattern defers entirely to it and adds no exception. Therefore the "WCAG/ARIA APG data-loss exception" that the shipped code previously cited as its authority **does not exist** as a citable W3C source. It is a practitioner gloss, not a standard. Sources: `https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/` and `.../alertdialog/`, accessed 2026-09-07.

Suppressing Escape is nonetheless a real, widely-implemented practitioner convention — Radix UI documents `onEscapeKeyDown` with `preventDefault` for exactly this. This is a **convention, explicitly not an authority**, and the plan does not treat it as one.

WCAG 2.2 SC 2.1.2 No Keyboard Trap (Level A) is engaged but **not violated**, because an in-dialog exit exists (the "Done" button). Its normative text requires that where escape "requires more than unmodified arrow or tab keys or other standard exit methods, the user is advised of the method for moving focus away." That advisement clause is the strongest genuine authority available here, and it is what the advisement sentence serves — by analogy, not as a rule that squarely governs this exact scenario.

**Unresolved, recorded as unresolved, not adjudicated:**
- Whether WCAG 2.2 SC 3.2.2 On Input (AA) is engaged by a keyboard contract that changes mid-dialog (the `isLoading` gate) is plausible but not textually settled. This plan does not adjudicate it. The advisement fix improves the outcome under either reading, so it does not block on this question.
- Whether Escape opening a nested confirm-discard dialog is acceptable in general has no primary-source verdict; practitioner commentary is mixed. Moot here since no such mechanism is recommended (Section 6).

**Explicitly ruled out as citations, and why:**
- SC 2.4.11 Focus Not Obscured does **not** apply — the control is removed from the DOM, not obscured while focused.
- SC 3.3.6 is AAA, not AA, and is not cited.
- SC 2.4.3 is only marginally engaged and is not relied upon.
- SC 3.3.4 concerns preventing the transaction, not dismissal UI, and the transaction has already committed server-side by the time the reveal phases render.

**On `aria-describedby`:** APG requires `aria-labelledby`/`aria-label` on `role=dialog` and treats `aria-describedby` as optional, with an explicit caveat against using it where the described content has internal structure (lists, multiple paragraphs) requiring separate perception. This caveat is why `aria-describedby` is wired only to the single advisement sentence and never to the multi-paragraph warning blocks.

**No W3C source mandates any specific mechanism for announcing why a dialog cannot be dismissed.** The advisement recommended in Section 6 is good practice grounded in SC 2.1.2's advisement clause, not a quotable mandate. This plan states that distinction rather than overstating the advisement's authority.

**Researcher's own stated limit, carried forward:** APG pages were retrieved via automated fetch and are non-versioned/editable, so exact verbatim APG quotations should be manually re-verified before being published as quotations. WCAG normative SC text is Recommendation-track and lower risk by comparison. Any verbatim APG quotation used in a shipped comment or on the issue must be manually re-verified before publication.

---

## 10. Separable follow-up (explicitly not bundled)

RegisterStudentModal pre-captures `triggerElement` (`originalTriggerRef.current`) on both phases; `ReissueAccessModal` passes none at either phase, falling back to `useFocusTrap`'s `document.activeElement` capture, and additionally redirects focus to `copyButtonRef` on reveal (`AdminStudentModals.tsx:593,628`). This is a real cross-site inconsistency in what element regains focus on close, but it does not affect whether or how a dialog is dismissed, so it is out of scope here. Recommendation: log it as its own GitHub issue under the umbrella plan's issue-logging policy. It is not addressed by this plan and its absence here should not be read as a decision that it is acceptable.

---

## 11. Ordered work

Step 1 is the durable record itself and is the actual acceptance criterion. It is not deferred behind implementation.

**Step 1 — Record the decision (this document plus the issue).** Owner: Scribe for this document; the orchestrator posts to the issue under the umbrella plan's issue-logging policy. This plan is the plan amendment issue #100's criterion asks for. The issue comment must state: the six-vs-five correction; the reconcile/named-exception split; the recovered provenance and its session-history origin; that the `isLoading` refinement was never ratified and is being ratified now by approving this plan; and a link to this plan's path. **Gate:** plan approved by the user, and the issue comment posted.

**Step 2 — Code: advisement markup and aria wiring** at all six sites, per Sections 5-6. Files: `AdminStudentModals.tsx`, `RegisterStudentModal.tsx`. **Gate:** all six ids present and correctly conditional; `ariaDescribedBy` wired per site; the live-region/bare variant split correct; no `suppressDismiss` value changed; full existing suite green with no exclusions.

**Step 3 — Code: the two byte-identical `.dismiss-advisement` CSS rules.** Files: `AdminStudentModals.css`, `RegisterStudentModal.css`. **Gate:** no new hex/px literal; existing token lint and `tokenFallbackAuditLint` still pass.

**Step 4 — Code: the new parity test** `src/__tests__/DismissAdvisement-CssParity.test.ts`, with an anchored regex. **Gate:** passes; and is proven to fail by deliberately diverging one copy in a scratch change, then reverting.

**Step 5 — Code: paste the two verbatim comment corrections** (Section 8), keeping the accurate grounds paragraphs unchanged. **Gate:** no fabricated-citation text remains anywhere; a grep for "WCAG/ARIA APG data-loss exception" returns zero hits in `src/`.

**Step 6 — Independent Verifier pass** over the whole diff against this plan's scope and gates.

**Step 7 — Browser Validator pass** per Section 13. No completion claim before Steps 6 and 7 both pass.

Steps 2-5 are small and may be combined into a single T1 job at the fleet's discretion; they are enumerated separately for gate clarity, not to force four dispatches.

---

## 12. Interfaces and data

No API, schema, migration, or data-model change. No prop-signature change to `Modal` — both `ariaDescribedBy` and `suppressDismiss` already exist and already support this work. Files touched: `AdminStudentModals.tsx`, `AdminStudentModals.css`, `RegisterStudentModal.tsx`, `RegisterStudentModal.css`, and one new test file. Files explicitly not touched: `Modal.tsx`, `useFocusTrap.ts`, `Modal.css`, `CourseWorkspacePage.tsx`, `CourseWorkspace.css`.

---

## 13. Browser UI dialog policy and validation

### Dialog policy (required and binding)

This is browser-rendered UI. Native browser dialogs are prohibited: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`. All acknowledgement and confirmation is app-owned and accessible. This change introduces none; the deterministic no-native-dialog source scan must confirm none regresses in. The app-owned `Modal` component is itself the compliance mechanism, and this plan does not weaken it.

### Validation brief

**Backend:** Playwright. Claude-in-Chrome cannot control viewports in this environment, and jsdom has repeatedly missed this exact bug class in this program.

**Launch/readiness:** `npm run dev` (Vite; `predev` runs `scripts/ensure-lesson-assets-bucket.ts`). Reuse an already-running dev server rather than restarting; never `taskkill`; scoped-PID termination only.

**Base URL:** `http://localhost:5173` (`vite.config.ts` sets port 5173; the root README's 5174 is stale, per the umbrella plan's Finding 8).

**Fixture/reset:** admin/owner surfaces are gated by `AdminShell.tsx:30`'s permission check; the exact credential path is an explicit open item carried from the umbrella plan and must be confirmed before any RLS-dependent result is trusted. The Supabase local stack must be confirmed running. Student surfaces use the dev-only seeded quick-select panel at `LoginForm.tsx:123-138`.

**Viewports:** desktop 1280x800 (or project default); ~768px narrow to observe two-line advisement wrap; 400% browser zoom / ~320px-equivalent reflow per SC 1.4.10.

**Journeys and visible outcomes:**
- Site 1 idle: open, do not type the confirmation, press Escape — dialog closes immediately, unchanged.
- Site 1 in-flight: type the matching email, click Delete, and while the request is in flight press Escape, click the backdrop, and attempt to Tab to a close button — dialog does not close on any of the three; no ✕ exists in the DOM; the sentence is visible as the first line of the body and a real accessibility-tree/screen-reader-emulation check confirms the live region announces it; Cancel is visibly disabled.
- Site 1 failure path: simulate failure — advisement disappears, dialog becomes dismissible again, existing `role=alert` error appears, confirming suppression and advisement lift together.
- Sites 2, 3, 5: same in-flight pattern with their own sentences.
- Sites 4 and 6: reach the reveal screen, then press Escape, click the backdrop, and Tab through — no dismissal; no ✕ exists; Tab cycles only Copy and Done; the advisement is the first line of the body with no `role`/`aria-live` attribute; and a real accessibility-tree check (not a DOM-only assertion) confirms the dialog's accessible description on focus entry, immediately on open and before any interaction, resolves to that sentence and not to the `.temp-password-warning` block, with no redundant or absent double-announcement.
- Regression: `CourseWorkspacePage.tsx:248`, `:439`, `:454` and `DisableStudentModal` all still dismiss via Escape, backdrop, and ✕, with no advisement text present.
- Reflow at 400% zoom on both an in-flight and a permanent reveal state: the sentence wraps to two lines without clipping, horizontal scroll, or truncation.
- Keyboard: the advisement never receives focus at either variant; focus trap and focus restoration unchanged at every site.
- Parity test: run it, then deliberately break one CSS copy in a scratch change to confirm it fails, then revert.

If the required real accessibility-tree/screen-reader-emulation check at sites 4/6 cannot be performed in this environment, that must be reported as a discovery impediment, not passed on source-level or jsdom evidence alone.

---

## 14. Acceptance and validation

1. Issue #100's criterion satisfied: a decision is recorded (this plan, approved) and applied consistently across all six sites, with the five-vs-six miscount corrected on the record.
2. All six sites carry the correct advisement text with the correct delivery mechanism and correct aria wiring.
3. Zero `suppressDismiss` values changed; `Modal.tsx` and `useFocusTrap.ts` byte-unchanged.
4. `npm run lint`, `tsc --noEmit`, and the full vitest suite pass with no exclusions, with the Supabase local stack confirmed running — an exclusion-based pass is a failed gate, per the recorded prior incident in the umbrella plan's Finding 8.
5. The roughly eleven modal/focus-trap test files all still pass unmodified.
6. The new CSS parity test passes and is proven to catch divergence.
7. Deterministic no-native-dialog source scan passes.
8. Zero hits for "WCAG/ARIA APG data-loss exception" in `src/`.
9. Independent Verifier pass recorded.
10. Browser Validator pass recorded per Section 13. No surface accepted on source-level or jsdom evidence alone.

---

## 15. Risks and rollback

- **Risk:** jsdom cannot validate this class of bug — the program has repeatedly been burned here — so a green unit suite is necessary but not sufficient; Playwright evidence is required. **Mitigation:** Step 7 is a hard gate.
- **Risk:** the accessibility claim at sites 4/6 rests on `aria-describedby` being read on focus entry, verified at source level and from documented AT behavior but not in a live screen-reader session. **Mitigation:** the browser brief requires a real accessibility-tree/screen-reader-emulation check at those two sites specifically, not a DOM-presence assertion. If that check cannot be performed, it must be reported as an impediment rather than passed.
- **Risk:** duplicated CSS silently diverging later. **Mitigation:** the parity test, proven to fail on divergence.
- **Risk:** reaching these admin modals requires owner/admin access; the umbrella plan's Finding 8 records that the exact credential path was never confirmed and is an explicit open item. **Mitigation:** treat credential unavailability as a discovery blocker to be reported, not worked around or substituted with source-level evidence.
- **Risk:** APG pages are non-versioned and were fetched via automated tooling. **Mitigation:** manually re-verify any verbatim APG quotation before it is published in a shipped comment or on the issue.
- **Rollback:** every change is additive and confined to four files plus one new test. Revert the commit. No data, schema, or shared-component state is touched, so rollback is clean and carries no migration or compatibility concern.
- **Standing process hazards from the umbrella plan that apply here:** never run a broad `taskkill`; reuse the existing dev server rather than restarting it; use scoped-PID termination only.

---

## 16. Assumptions

Labeled explicitly as assumptions, not findings:
- Operators are trained internal staff, justifying a calm rather than alarming copy register.
- A single shared advisement sentence serves both reveal sites since their reason is identical and surrounding context differentiates them.
- Desktop is the primary but not exclusive viewport.

---

## 17. Judge route

Per `docs/JUDGE-CONTRACT.md`: `PLAN_DUCK` is eligible after this draft at the orchestrator's discretion and remains advisory under shadow mode. A `CODE_REVIEW` checkpoint on the implementing diff is optional and low-value here, given the change is additive markup, two CSS rules, a parity test, and comment text with no logic change. Deterministic failures always dominate any judge finding. Codex output is never treated as implementation or as deterministic validation.

---

## 18. Engineering mode and ownership

Engineering mode: standard. Team authorization: not applicable. Downstream owner: engineering-fleet (T1, escalation to T2 only per the umbrella plan's standard gate policy). Independent Verifier and Browser Validator passes are both required before any completion claim, per Sections 11 and 14.
