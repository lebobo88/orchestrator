# Lizbeth Spanish, Issue #39: Screen — Week detail, reading sheet + attachments rail

**Status: Approved for engineering under standing authorization. Dated 2026-09-01.** See "Approval basis" immediately below for the basis and provenance of this approval.

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#38 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** the user's own live-session statements, "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished" and "don't stop until all the DS gh issues are implemented and browser validated." The orchestrator reports these as the standing authorization plus the explicit session goal covering this plan approval, on the same basis already recorded on the #31-#38 plans.
- **Application:** the orchestrator applied this standing authorization to route this plan — issue #39 of `lebobo88/lizbeth-spanish`, the Field Journal DS milestone, the third issue in the screen-redesign batch #37-#44, following #31-#38, all landed, verified, browser-validated, and design-reviewed PASS — to engineering without a further live per-plan checkpoint, because #39 is the next issue in the exact chain the user directed continuation through.
- **Pre-flight staleness check.** The orchestrator independently fetched the live GitHub issue #39 body via `gh issue view` and relayed it directly into Planner's context. This satisfies the pre-flight staleness check that this plan's evidence reflects the issue's current live state, not a stale cached description. (Note recorded separately in this plan's own repository findings: the issue's cited design-source line numbers were themselves found to be stale against the actual `Field Journal DS.dc.html` file and were corrected during planning — see "Repository findings" above.)
- **Notable Planner findings preserved here for the approval record:**
  1. **Existing component, not a new build.** `ResourcesPanel.tsx`/`.css` already exists and works in the codebase, although the issue's file scope implied a new component. This is the same restyle-not-rebuild pattern already established in issue #37's `LoginForm`: the component's existing tests assert only text/role/href/behavior, never colors or spacing, so a full visual restyle is safe.
  2. **A real, blocking CSS-cascade specificity defect was found and fixed at planning time**, not merely a wording nitpick. `.lesson-content-chunk-example-body`'s hardcoded 21px `font-size` is currently outranked by a higher-specificity sibling rule (`.lesson-content-chunk p`) and never actually renders — chunk 02's body currently renders at 18px, not the intended 21px. Left uncaught, the issue's naive literal instruction ("change 21px to 22px") would have shipped as a silent no-op. The plan's D6 resolution corrects the selector's specificity rather than only the value.
  3. **D5 acceptance-criterion narrowing, accepted on direct source evidence.** The orchestrator accepted the plan's D5 resolution narrowing acceptance criterion 7 ("badges as margin annotations, not inline chrome") to a margin-rule visual echo rather than a full structural relocation. This is grounded in the reference mockup source itself, which keeps badges inline (`Field Journal DS.dc.html:815-818`) — the literal acceptance-criterion text does not match its own cited reference, and Planner's narrower reading follows that direct source evidence rather than a convenience shortcut. This narrowing is separately recorded as unresolved decision 1 in "Design-level unresolved decisions" above, requiring issue-owner confirmation before criterion 7 is treated as fully closed.
- **`PLAN_DUCK` Codex judge checkpoint.** Eligible at the orchestrator's discretion before approval per the Judge route section above; not separately run for this document. Deterministic checks and the Verifier/Browser Validator passes in the ordered-work phase remain mandatory regardless.
- **Provenance label:** this basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements, the `gh issue view` fetch, or the Planner findings beyond what is already recorded elsewhere in this document. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **Date:** 2026-09-01.

---

Plan ID: `lizbeth-spanish-issue39-week-detail-reading-sheet-attachments-rail`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: standard (`design-director`, `ux-architect`, `visual-system-designer`, `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome

GitHub issue #39, "Screen: Week detail — reading sheet + attachments rail," is the ninth of the 14-issue Field Journal Design System milestone (#31-#44) and the third of the screen-redesign batch. The audience is the enrolled student viewing one week's lesson.

Observable result: `WeekDetailPage` renders as the Field Journal §D.3 two-column "reading sheet + attachments rail" composition at 1440px, and collapses to a single stacked column at 390px with no horizontal scroll. `.paper-stock--ruled` (shipped in issue #31, previously unconsumed by any component) and the `role.target-line` typography token (shipped in issue #32, previously unconsumed) become their first real consumers in this issue.

## Scope

**In scope — three work areas:**

(a) `src/pages/WeekDetailPage.tsx` / `WeekDetailPage.css` — the two-column grid and reading-sheet chrome.

(b) `src/components/ResourcesPanel.css` (and minimal `.tsx` changes only if the rail card needs a wrapper element) — restyle into the attachments rail. This follows the issue #37 LoginForm precedent: a working, fully tested component gets a visual restyle, not a rebuild.

(c) `src/components/LessonContentView.css` — the D6 target-line token-conformance fix, plus the badge margin-annotation accent treatment.

**Out of scope, each declared explicitly by design with a stated reason — record all four so nobody silently adds them:**

1. The Self-check rail card. No such component exists; self-check items live only inside the Q&A segment at `LessonContentView.tsx:174-181`.
2. The Caveat-script margin-hand annotation seen at `Field Journal DS.dc.html:843`. No backing field exists in the `PhraseGroup` data model, and inventing content is forbidden by the content rules in the design brief.
3. The tape-strip decoration on the rail card. Zero grounding in evidence (no rotation, color, opacity, or size value was ever specified for it).
4. §E.3's distinct mobile chrome (the tri-chip "Lesson/Cards/Files" row and the sticky "Mark complete"/"Next" footer). This is a competing information-architecture paradigm, not a reflow of §D.3, and "Next →" has no destination since no next-week navigation exists anywhere in the app.

**Also not in scope:** rebuilding the C.5 four-chunk anatomy, C.6 SegmentLedger, Stamp, the page-turn animation, or ResourcesPanel's internal logic.

## Repository findings

Verified directly and by the nested Researcher and both design specialists (design-director/ux-architect/visual-system-designer), independently re-confirmed by design review:

- `src/pages/WeekDetailPage.tsx` (377 lines) is today a presentation-free state machine: loading/error/not-available/locked/empty/available branches (96-102, 262-377) render `LessonContentView` (330), `ResourcesPanel` (363-366), and `IpNotice` (370) in one flat column inside the `.week-detail-sheet[--animate]` page-turn wrapper (271-272). `WeekDetailPage.css` currently only sets `.week-detail-page { max-width: 700px; margin: 0 auto; }` (54-57) plus state chrome (59-131) and the page-turn keyframe (39-52). No grid, no paper stock, no rail exists yet.
- `src/__tests__/WeekDetailPage.test.tsx` (552 lines) locks text, roles, real gating behavior, the single `.week-detail-sheet` wrapper containing `.week-detail-page` (445-448), and forward-navigation-only page-turn animation with React Strict-Mode double-invoke safety (460-551). Design review confirmed lines 297-316 and 330 assert only presence/text/role for Resources and IpNotice, with NO DOM-order assertion between them — reparenting `IpNotice` into the rail is test-safe.
- **Shipped, verified, browser-validated, design-reviewed-PASS in issues #31-#38 — must be PRESERVED, not modified:**
  - `LessonContentView`'s C.5 four-chunk anatomy in fixed order: 01 RULE BOX (143-147), 02 EXAMPLE (148-152), 03 TRANSLATION TASK (153-157), 04 DIALECT NOTE (158-168), each with an `aria-hidden` decorative `ChunkTab` (30-36) whose accessible name is the chunk's own `h4`.
  - `SegmentLedger` C.6, wired at `LessonContentView.tsx:112-116`, with `RHYTHM_SEGMENTS` 30/10/20 (`src/content/lessonContent.ts:62-67`) implemented as inline `flexGrow: segment.minutes` (`SegmentLedger.tsx:89`) inside a `role="tablist"` with `role="tabpanel"` children.
  - Stamp's fire-once trigger: `justCompleted` is set ONLY in `saveCompletion`'s success branch (line 101), never on mount-fetch, so a remount of an already-completed lesson never replays the stamp animation (renders only when `completed && justCompleted`, line 217).
- `ResourcesPanel.tsx` (145 lines) and `ResourcesPanel.css` (113 lines) both already exist and work: signed-URL rows via `getSignedResourceUrl`, row states idle/loading/ready/ready-flashcards/error+retry, `FlashcardsViewer`, and an empty state. `src/__tests__/ResourcesPanel.test.tsx` (147 lines) asserts ONLY text/role/href/behavior, never colors or spacing, so a full visual restyle is safe provided classNames, button/link roles, and text content survive. Mounted only at `WeekDetailPage.tsx:363-366`, filtered to exclude the internal `lesson_content` row.
- **Tokens consumed:**
  - `.paper-stock--ruled` at `src/App.css:113-118`:
    ```css
    background-color: #fdfcf9;
    background-image:
      repeating-linear-gradient(to bottom, transparent 0 31px, #e3dbcd 31px 32px),
      linear-gradient(to right, transparent 0 55px, #e0b3a5 55px 57px, transparent 57px);
    ```
    A 32px band with the rule at the band's bottom edge, plus a single non-repeating vertical margin rule at x = 55-57px. No `background-position` is set, so the bands originate at the padding-box top-left.
  - `role.target-line` at `src/tokens/semantic.json:73-80` (Fraunces / 600 / italic / 22px / 1.4 / `{color.brass.700}` → `#7c6136`), emitted at runtime as `--typography-role-target-line-*` custom properties by `generateCSSVariables()` (`src/tokens/tokenSystem.ts`), injected via a `<style>` tag in `src/main.tsx:4-10`.
- **CRITICAL CASCADE DEFECT**, found by design review and independently confirmed: `.lesson-content-chunk-example-body` (`LessonContentView.css:76-80`, specificity 0,1,0) is outranked by `.lesson-content-chunk p` (`LessonContentView.css:120-130`, specificity 0,1,1) targeting the identical `<p>` (`LessonContentView.tsx:151`, a direct child of `.lesson-content-chunk--example` at line 148). The source's hardcoded `21px` therefore NEVER RENDERS today — chunk 02's body actually renders at 18px/31.5px. State this plainly in the implementation: the naive reading of the issue ("change 21px to 22px") would produce a fix that silently does nothing. The design's resolution is the selector `.lesson-content-chunk--example .lesson-content-chunk-example-body` (specificity 0,2,0), with `!important` explicitly forbidden. `src/__tests__/typographyFourHands.test.ts:195-218` documents a near-identical prior cascade-override incident in this codebase.
- **DESIGN-SOURCE LINE NUMBERS IN THE GITHUB ISSUE ARE STALE.** The issue cites approximately lines 99750, 103124, 112774, 183080. The actual file `design/field-journal/Field Journal DS.dc.html` is 1595 lines total: §D.3 week detail is at 762-897 (reading sheet 788-790, segment ledger 799-808, four chunks 820-844, footer 846-854, attachments rail 857-893) and §E.3 at 390px is at 1382-1428. Record this correction prominently so the implementer does not chase nonexistent lines.
- §D.3 grid (mockup line 786): `display:grid; grid-template-columns: minmax(0,1fr) 400px; gap:44px; margin-top:28px;`. Reading sheet (789): 3px solid `#1a1512` border, `box-shadow: 8px 8px 0 0 #1a1512`, `padding: 34px 40px 0 96px`, overflow hidden; the rose margin rule is a separate absolutely-positioned 2px `#e0b3a5` div at `left:68px` (790). Rail (857-893): `<aside>` with heading "Attached to this week", card `background:#f0ebe2; border:3px solid #1a1512; box-shadow:6px 6px 0 0 #a07e48; padding:26px 22px 22px;`, rows in a 14px-gap column. §E.3 (1382-1428) is single-column 390x844 and shows a materially different content model with no rail and no SegmentLedger — it is NOT a literal reflow target, which is why design specified the 390 collapse itself rather than transcribing §E.3.
- **Guard tests that gate this work:**
  - `src/__tests__/designSystemConsistency.test.ts` reads actual component CSS source; fails un-tokenized fonts, unstyled controls, undersized touch targets, and indistinguishable chunk treatments. Its J-002 background-color guard (lines 104-132) structurally guarantees chunk-surface opacity, which is the load-bearing premise of the D1 accepted-drift argument below (see "Reviewed design handoff").
  - `src/__tests__/fieldJournalTokens.test.ts` — its 232-238 assertions confirm hex CONTAINMENT inside the paper-stock class bodies only. It does NOT assert hex ABSENCE elsewhere, so hex discipline in `WeekDetailPage.css`/`LessonContentView.css` is a convention the implementer must follow deliberately, not an automated guarantee.
  - `src/__tests__/typographyFourHands.test.ts` — lines 53-58 confirm the runtime custom-property naming for `role.target-line`; lines 195-218 document the prior cascade incident referenced above.
- No-native-dialog invariant verified currently upheld: zero matches for `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` in `WeekDetailPage.tsx`, `ResourcesPanel.tsx`, and `LessonContentView.tsx`. Both `ResourcesPanel` and `LessonContentView` already use inline `role="status"`/`role="alert"` plus Retry buttons for all error communication.
- **Conventions:** `npm test` runs vitest; a single file via `npx vitest run src/__tests__/<File>.test.tsx`. `npm run lint` runs `eslint src --ext ts,tsx`. `npm run type-check` runs `tsc --noEmit`. `npm run build` runs `tsc && vite build`. `vite.config.ts` hardcodes `server.port: 5173` with `open: true`.

**Research evidence.** A nested Researcher covered local repository and design-source inspection only (no external sources needed). Its source ledger includes `WeekDetailPage.tsx/.css/.test.tsx`, `LessonContentView.tsx/.css`, `lessonContent.ts`, `SegmentLedger.tsx/.css`, `ResourcesPanel.tsx/.css/.test.tsx`, `Stamp.tsx`, `journal-devices.css`, `Badge.tsx`, `App.css`, `fieldJournalTokens.test.ts`, `semantic.json`, `typographyFourHands.test.ts`, `main.tsx`, `designSystemConsistency.test.ts`, `Field Journal DS.dc.html` (762-897, 1382-1501), `package.json`, and `vite.config.ts`. All findings above are drawn from it and were independently re-verified by the design reviewer.

## Reviewed design handoff

```
DESIGN_ROUTE
profile: standard
agents_required: design-director, ux-architect, visual-system-designer, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
reasons: screen-level composition of the densest screen in the app; new two-column layout; multi-state rail restyle; 390 behavior unspecified by the design source; precision baseline/rule-rhythm typography.
END_DESIGN_ROUTE
```

**Design handoff status: PASSED**, persisted from the resumed agent packet. **Design review status: PASSED**, after exactly one evidence-backed `NEEDS_REVISION` cycle. The reviewer independently re-read the mockup and every cited repository file and found no fabricated citation. It closed all five original findings:

1. BLOCKING cascade-specificity defect — fixed via the `(0,2,0)` selector, `!important` forbidden, and `browser_validation_brief` step 4 re-derived against actually-rendering values.
2. The D5 badge reinterpretation was moved to unresolved decisions (see below) rather than silently settled.
3. A `@media (forced-colors: active)` block was added for `.week-detail-reading-sheet`, `.week-detail-rail-card`, and `.lesson-content-badges`, mirroring `SegmentLedger.css:87-103`.
4. The `fieldJournalTokens` citation was softened from "enforced" to "convention" (see guard-test note above).
5. The bare `81px` literal was composed as `calc(57px + var(--space-6, 1.5rem))` so its derivation is self-documenting.

Reviewer's stated remaining limit: it did NOT re-derive the WCAG contrast arithmetic below (12.90:1, 4.88:1, 7.48:1); the design packet itself flags those figures as hand-computed, not sourced from an existing contrast-audit file.

### Selected direction

Field Journal §D.3 "reading sheet + attachments rail," composed strictly from already-shipped tokens/components (issues #31-#38). No new visual language, no new component paradigm. The reading sheet becomes `.paper-stock--ruled`'s first real consumer (issue #31's original intent); the rail becomes a bordered/shadowed "pinned card" reusing the same hard-edge registration-shadow language already shipped elsewhere in the app (`--shadow-sheet`, `--shadow-brass`). `LessonContentView` (C.5), `SegmentLedger` (C.6), `Stamp`, and `ResourcesPanel` are consumed as-is and NOT redesigned. Rationale: every value traces to an existing primitive/semantic/component token or an already-rendered precedent elsewhere in the app, keeping the three guard tests green because nothing token-shaped is invented.

### D1-D6 decision resolutions

**D1 — reading-sheet rhythm registration (CORRECTED after implementation, per T1's `DOCUMENTATION_HANDOFF`).** `.paper-stock--ruled`'s shipped band height is 32px (`repeating-linear-gradient(to bottom, transparent 0 31px, #e3dbcd 31px 32px)`), origin at padding-box top-left. `.week-detail-reading-sheet` gets `padding-top: var(--space-8, 2rem)` = 32px = exactly one band — the container's own top edge registers on-rhythm by construction, a multiple, not an approximation.

This plan originally claimed that every element inside the reading sheet is occluded from the ruled backdrop, so no visible mis-registration could ever occur, and separately gave headings two different, conflicting justifications for that same claim in one sentence ("under the same occlusion rationale" immediately followed by "display type, infrequent, out of scope to retune"). Both defects are corrected below, on evidence gathered during implementation: real Playwright-rendered screenshots at the actual 1440px validation viewport with realistic wrapped multi-line content, plus `getComputedStyle` probes against the actual production CSS, backed by a new regression test, `src/__tests__/d1OcclusionScopeCorrection.test.ts` (5/5 passing). See `src/components/LessonContentView.css`'s "Issue #39 D1 CORRECTION" comment block for the in-code record of this same finding.

**GENUINELY OCCLUDED** (opaque background confirmed via `getComputedStyle`; the ruled lines are never visible behind the text; guarded by the existing `designSystemConsistency.test.ts` J-002 background-color test): the four chunk boxes (`.lesson-content-chunk--rule`/`--example`/`--translation`/`--dialect`), `.lesson-content-group`, and `SegmentLedger`.

**NOT OCCLUDED, but confirmed LOW PRACTICAL VISIBILITY** at real 1440px reading scale: `.lesson-content-view` (the reading-measure wrapper), the lesson `<h2>` title, `.lesson-content-qa`, and `.lesson-content-practice`. Each of these carries a transparent background — confirmed via `getComputedStyle`: `background-color: rgba(0, 0, 0, 0)` — and none of their line-heights is an exact multiple of the 32px ruled band: the global `h2` rule resolves to `line-height: 1.25` at 30px = 37.5px, and `.lesson-content-qa`/`.lesson-content-practice` carry no line-height override of their own, inheriting non-32px-multiple defaults. Real rendered screenshots at 1440px with realistic wrapped multi-line content confirmed that the resulting 1px, low-contrast (`#e3dbcd` on `#fdfcf9`) rule-line drift is NOT visually perceptible at normal reading scale — it is visible only under forensic 3-6x zoom. This is a genuine, evidence-backed finding from real rendered output, not a convenient assumption, and it is the reason this drift is accepted rather than fixed: forcing exact 32px-multiple line-heights onto free-flowing, per-week-variable-length content (lesson titles, Q&A/quiz text, practice summaries) was assessed as disproportionate scope creep beyond this issue's boundary, for a confirmed low-practical-severity cosmetic artifact.

Buttons remain individually ruled DRIFT as solid-background controls, out of scope to retune. Chunk 03's own internal ruled writing area (27/28px repeating gradient, ratified in issue #36) is a separate micro-rhythm, not reconciled against the sheet's 32px rhythm — out of this issue's scope.

The baseline-offset method used to justify occlusion for the genuinely-occluded elements (not to claim pixel-exact placement): `offset ≈ (line-height − font-size)/2 + 0.8 × font-size`, a documented typographic rule of thumb, not a measured Fraunces/Source Sans 3 metrics table (none exists in this repository). Flagged as an assumption below.

**D2 — reading-sheet background source.** Resolved in favor of consuming `.paper-stock--ruled` VERBATIM (`App.css:113-118`) rather than the mockup's bespoke gradient, per "existing values win unless justified" and issue #31's explicit intent that this class be consumed. This bakes in BOTH the horizontal rule rhythm and a vertical margin-rule stripe at x:55-57px as one gradient layer — no separate absolutely-positioned margin-rule div is needed, unlike the mockup.

**D3 — 390px collapse behavior.** §E.3 is NOT a literal reflow target (different content model, no rail, no SegmentLedger). The grid drops the two-column template entirely below the collapse threshold — genuine single-column block flow (`display: block`), not a `1fr` grid-template fallback, because a fixed 400px column would force overflow regardless of the flexible track's width. DOM/visual order is identical to 1440, top to bottom: `h1` → reading sheet (title, SegmentLedger, four-chunk groups, Q&A, Practice, complete button/Stamp) → rail heading + card (Resources rows) → IpNotice. No CSS `order` property is used at either breakpoint — tab order never changes between breakpoints. The reading sheet's 1440-only ornamental left gutter (96px padding, week numeral, absolute margin-rule div) MUST collapse to ordinary small edge padding at 390 — no fixed-width decorative element may persist unscaled.

**D4 — Self-check/IpNotice placement.** No Self-check rail card is added (out of scope, see Scope above — no component exists, no per-item state model). `IpNotice` is reparented into the rail as the LAST item, after the rail heading and the wrapped `ResourcesPanel`. This is test-safe: `WeekDetailPage.test.tsx` asserts only presence/text/role for both components, never DOM order between them.

**D5 — badge margin-annotation treatment.** `.lesson-content-badges` (the GROUP-level `<ul>`, `LessonContentView.tsx:138` — explicitly NOT `.lesson-content-chunk-badges`, the per-chunk dialect tray) gets:

```css
.lesson-content-badges {
  border-left: 2px solid var(--color-accent-margin-rule, #e0b3a5);
  padding-left: var(--space-3, 0.75rem);
}
.lesson-content-badge {
  font-family: var(--typography-role-label-fontFamily, "IBM Plex Mono", monospace);
  letter-spacing: 0.04em;
}
```

`--color-accent-margin-rule` echoes the sheet's own margin-rule color, reading as the same "margin annotation" family without a new grid track or new color. This is a **visual echo, not a structural relocation**, which narrows issue #39's written acceptance criterion 7 (which the issue's own framing implies as a structural margin-column relocation) — recorded as an unresolved decision below requiring issue-owner confirmation, not silently settled. The interpretation is evidence-grounded: the mockup itself keeps group tags inline (`Field Journal DS.dc.html:815-818`). This new border-left also sits near `.lesson-content-group`'s own pre-existing left-border accent (`--color-accent-primary`) — accepted as minor layering (both are legitimate tokens; the badge border is a small nested element, not a competing full-height rule), flagged for a visual-confirmation check in browser validation rather than a CSS change.

**D6 — target-line cascade fix (CORRECTED after independent review).** `.lesson-content-chunk-example-body` (chunk 02's own `<p>`, `LessonContentView.tsx:151`, confirmed the same node as the mockup) is corrected to consume `role.target-line` custom properties verbatim. The naive selector `.lesson-content-chunk-example-body` alone is specificity `(0,1,0)`, strictly LOWER than the already-shipped `.lesson-content-chunk p` rule (`LessonContentView.css:120-130`, specificity `(0,1,1)`), which today actually governs chunk 02's rendered font-size/line-height (18px/31.5px). A same-specificity replacement would reproduce this exact bug. The corrected declaration, scoped to `(0,2,0)` so it strictly outranks `(0,1,1)` regardless of source order:

```css
.lesson-content-chunk--example .lesson-content-chunk-example-body {
  font-family: var(--typography-role-target-line-fontFamily, Fraunces, serif);
  font-weight: var(--typography-role-target-line-fontWeight, 600);
  font-style: var(--typography-role-target-line-fontStyle, italic);
  font-size: var(--typography-role-target-line-fontSize, 22px);
  line-height: var(--typography-role-target-line-lineHeight, 1.4);
  color: var(--typography-role-target-line-color, #7c6136);
}
```

Property names are confirmed against `typographyFourHands.test.ts:53-58` and `main.tsx`'s `generateCSSVariables()`. Do NOT use `!important` as an alternative fix. Line-height `1.4` (the ratified token value, not the mockup's local `1.5`) is deliberate: the token bundle is one composite decision; no justification for `1.5` was supplied beyond the mockup literal, so existing-value precedence settles it. Resulting `22 × 1.4 = 30.8px`; a hypothetical unoccluded placement would miss the nearest rule by roughly 10px, concretely demonstrating why occlusion (chunk 02 sits inside its opaque box, J-002-guarded) makes the mismatch invisible by construction, not coincidental alignment. This reasoning is unaffected by the selector fix — only the selector needed correcting, not the arithmetic.

**Superseding note (added after implementation, per T1's `DOCUMENTATION_HANDOFF`).** The `1.4` value transcribed above from the reviewed design packet was superseded during implementation by a remediation fix, because `22px × 1.4 = 30.8px` is not exactly 32px — a real math bug against the ruled stock's 32px band, distinct from the cascade-specificity defect this section otherwise addresses. The shipped declaration instead sets `line-height: var(--space-8, 2rem)` (32px exactly), scoped ONLY to the `.lesson-content-chunk--example .lesson-content-chunk-example-body` selector — see `LessonContentView.css`'s inline comment citing "Codex CODE_REVIEW remediation cycle 1 (J-39-001, major)" and its accompanying disclosure. The ratified `role.target-line.lineHeight` token itself is UNCHANGED at `1.4` in `src/tokens/semantic.json`, and `generateCSSVariables()` still emits `1.4` at runtime (verified by `typographyFourHands.test.ts`). This is a per-consumer CSS override for this one chunk's fixed-32px-rhythm context, not a token-value change. A future consumer of the `role.target-line` role elsewhere in this codebase must not assume this `2rem` override applies to it, and should use the token's own line-height unless it has the identical fixed-rhythm need. Locked in by `src/__tests__/d1OcclusionScopeCorrection.test.ts` (5/5 passing).

### Layout and CSS specification (transcribed verbatim from the reviewed packet)

**Container width.** `.week-detail-page`'s own hard-coded `max-width:700px` (not the global `.app-main`) is the real page-scoped container-width blocker (`App.css` already widens `.app-main` to `--size-content-max` at ≥900px viewports, so the originally flagged `.app-main` conflict is already moot at desktop). Resolution:

```css
.week-detail-page { max-width: var(--size-content-max, 75rem); margin: 0 auto; }
```

This reuses the exact 1200px token, and is harmless below the collapse threshold since the reading sheet's own `65ch` measure cap already bounds it in single-column mode.

**Grid.**

```css
.week-detail-grid {
  display: grid;
  grid-template-columns: minmax(0,1fr) 400px;
  gap: 44px;
  margin-top: 28px;
}
```

Reused verbatim from the mockup. This wraps ONLY `state.kind === 'available'` content — the `loading`/`error`/`not-available`/`locked`/`empty` branches and every `available` content sub-state (`not-authored`/`retrying`/`fetch-error`) render exactly as today, full-width, single column, entirely OUTSIDE this grid.

**Collapse breakpoint.**

```css
@media (max-width: 56.24rem) {
  .week-detail-grid { display: block; }
}
```

`56.24rem` (900px) reuses the exact breakpoint value/unit `App.css` already uses at lines 699/726 for `.app-header`/`.app-main`, rather than inventing a new number. Both 1440 and 390 sit unambiguously on either side. Derivation of the threshold: 400px rail + 44px gap + roughly 420px minimum reading column + 48px page padding ≈ 912px, expressed as a container-width breakpoint (not a device label).

**Reading sheet.**

```css
.week-detail-reading-sheet {
  position: relative;
  border: var(--border-width-rule, 3px) solid var(--color-ink-1000, #1a1512);
  box-shadow: var(--shadow-sheet, 8px 8px 0 0 #1a1512);
  padding: var(--space-8, 2rem) var(--space-10, 2.5rem) var(--space-8, 2rem) calc(57px + var(--space-6, 1.5rem));
  overflow: hidden;
}
```

Plus the `.paper-stock--ruled` background (see D2 above, `App.css:113-118`), consumed on this element, not reimplemented. `border`/`box-shadow` reuse `--border-width-rule`/`--shadow-sheet` verbatim, matching the mockup exactly. The left padding is `calc(57px + var(--space-6, 1.5rem))` = 81px, self-documenting its own derivation instead of a bare literal: 57px is the shipped rule's own gradient end-position, plus `--space-6` (24px) clearance — intentionally smaller than the mockup's 96px because the shipped rule sits at 55-57px, not the mockup's 68px. Engineering must not collapse this back into an unexplained bare literal (see Permitted variation below).

390 collapse override:

```css
@media (max-width: 56.24rem) {
  .week-detail-reading-sheet {
    padding: var(--space-8, 2rem) var(--space-4, 1rem) var(--space-4, 1rem);
    background-image: repeating-linear-gradient(to bottom, transparent 0 31px, var(--color-paper-300, #e3dbcd) 31px 32px);
  }
  .week-detail-reading-sheet-numeral { display: none; }
}
```

Top padding stays `--space-8` (32px, one band) even at 390 so the D1 rhythm invariant holds at both breakpoints; left/right/bottom shrink to `--space-4` (16px). The vertical margin-rule layer is dropped since its gutter no longer exists.

**Week numeral (1440 only, decorative).**

```css
.week-detail-reading-sheet-numeral {
  position: absolute; top: var(--space-6, 1.5rem); left: var(--space-3, 0.75rem);
  font-family: var(--typography-role-display-sm-font-family, Fraunces, serif);
  font-weight: var(--typography-role-display-sm-font-weight, 900);
  font-size: var(--typography-role-display-sm-font-size, 52px);
  line-height: var(--typography-role-display-sm-line-height, 1);
  color: var(--color-paper-300, #e3dbcd); z-index: 0; pointer-events: none; user-select: none;
}
```

Reuses `--typography-role-display-sm-*` (the WeekCard/MetricPlate precedent). Content is the real zero-padded `weekNumber`. `aria-hidden="true"`, a decorative duplicate of the accessible `<h1>`; WCAG 1.4.3 exempt as non-informational decorative text. `display: none` (not merely scaled) at ≤56.24rem — this is a named engineering invariant, see below.

**Attachments rail.**

```css
.week-detail-rail-card {
  position: relative;
  background-color: var(--color-paper-200, #f0ebe2);
  border: var(--border-width-rule, 3px) solid var(--color-ink-1000, #1a1512);
  box-shadow: var(--shadow-brass, 5px 5px 0 0 #a07e48);
  padding: var(--space-6, 1.5rem);
  width: auto;
}
.week-detail-rail { padding-bottom: var(--space-10, 2.5rem); }
```

Background/border match the mockup's `#f0ebe2`/ink border exactly. Box-shadow reuses the existing `--shadow-brass` (5px, vs the mockup's one-off 6px — existing token wins, the same shadow already used for `.demo-button`/`.app-header-logo`). Padding is 24px uniform, snapped from the mockup's uneven 26/22px. The tape-strip treatment is EXPLICITLY OMITTED — zero grounding in evidence for rotation/color/opacity/size; the card's existing hard-edge border plus brass shadow already carries the "pinned" register.

DOM structure inside the `<aside>`, top to bottom: (1) visible heading "Attached to this week" (verbatim mockup copy, `Field Journal DS.dc.html:859`), with the `<aside>`'s `aria-labelledby` pointing at it; (2) `ResourcesPanel`, unchanged internally, wrapped by `.week-detail-rail-card`; (3) `IpNotice`, moved here as the last item (see D4). No collapse/disclosure behavior at 1440, matching the mockup's own stated behavior. No literal fixed pixel width on `.week-detail-rail`/`.week-detail-rail-card` at any breakpoint — width is entirely a function of the grid track (400px) or normal block flow (100%) once the grid collapses.

**Forced-colors override**, added per independent design review, mirroring `SegmentLedger.css:87-103`:

```css
@media (forced-colors: active) {
  .week-detail-reading-sheet, .week-detail-rail-card { box-shadow: none; border-color: ButtonText; }
  .lesson-content-badges { border-left-color: ButtonText; }
}
```

**Tokens reused (no new token values proposed by this issue):** `color.paper.300` (`#e3dbcd`), `--color-accent-margin-rule` (`#e0b3a5`), `color.paper.200` (`#f0ebe2`), `color.ink.1000` (`#1a1512`), `--border-width-rule` (3px), `--shadow-sheet` (8px 8px 0 0 #1a1512), `--shadow-brass` (5px 5px 0 0 #a07e48), `typography.role.target-line.*`, `typography.role.label.fontFamily` (IBM Plex Mono), `typography.role.display-sm.*`, `--space-3/4/6/8/10`, `--size-content-max` (75rem), and the standard CSS system color keyword `ButtonText` for forced-colors mode. Mockup literals that differ (96px gutter, 6px shadow, 26/22px card padding, 44px rail padding, 68px rule position) are deliberately replaced by the shipped token or derived-arithmetic value; each delta is called out inline above as a minor, justified snap, not open discretion.

### Contrast verification (hand-computed, not from a repository audit file)

Computed by hand from sRGB hex values via the standard WCAG 2.x relative-luminance formula, since no pre-existing contrast-audit file exists in this repository. The design reviewer did NOT independently re-derive these figures; independent re-derivation before final sign-off is recommended.

- `.resources-panel-row-name` (ink.900 `#2a2420`) on the rail's paper.200 `#f0ebe2` = 12.90:1 — passes AA/AAA.
- `.resources-panel-row-type` (ink.700 `#504940`) on `#f0ebe2` = 7.48:1 — passes AA/AAA.
- Rail card border ink.1000 on paper.200: far exceeds the 3:1 non-text floor.
- D6 target line: brass.700 `#7c6136` on paper.200 `#f0ebe2` = 4.88:1 — clears the 4.5:1 AA normal-text floor.
- Badge border-left accent color `#e0b3a5` on paper.50: decorative accent, WCAG 1.4.11 exempt because meaning is carried by unchanged badge text/color, not this border.
- Week numeral (paper.300 on the ruled background): decorative, `aria-hidden`, WCAG 1.4.3 exempt.

### Engineering invariants (transcribed verbatim from the design handoff)

**Preserve, do not modify:** `src/components/LessonContentView.tsx/.css` (C.5 four-chunk anatomy, fixed order, numbered mono tabs; `ChunkTab` `aria-hidden` decorative, accessible name is each chunk's `h4`); `src/components/SegmentLedger.tsx/.css` (C.6, `RHYTHM_SEGMENTS` 30/10/20, existing `@media max-width:640px` behavior reused as-is, and its forced-colors block at lines 87-103 is the direct precedent for the new invariant below); `src/components/journal/Stamp.tsx` (fire-once trigger logic untouched); `src/pages/WeekDetailPage.tsx` (page-turn wrapper, forward-nav-only animation, all state branches locked by the 552-line test suite — the CSS grid/chrome changes are additive around these branches, not edits to the state machine itself); `src/components/ResourcesPanel.tsx/.css` (all row states/classNames/behavior consumed as-is, only visually wrapped, never redesigned internally); `src/components/IpNotice.tsx/.css` (reparented only, no markup or style change). Guard tests `designSystemConsistency.test.ts`, `fieldJournalTokens.test.ts`, `typographyFourHands.test.ts` must stay green. No native browser dialogs anywhere (currently zero matches across all three touched files; must remain zero).

**New invariants from this handoff:**

- **CASCADE INVARIANT:** the D6 corrected rule must be `.lesson-content-chunk--example .lesson-content-chunk-example-body` (0,2,0) or an equal-or-higher, order-independent-specificity selector, because the already-shipped `.lesson-content-chunk p` (0,1,1) would otherwise silently continue to win and the font-size/line-height fix would never render. Never use `!important` to resolve this.
- `.week-detail-reading-sheet-numeral` must be `display: none` (not scaled) at ≤56.24rem.
- No literal fixed pixel width on `.week-detail-rail`/`.week-detail-rail-card`/the reading sheet at any breakpoint.
- No CSS `order` property anywhere in this composition.
- `.lesson-content-chunk-example-body`'s corrected declaration must reference `var(--typography-role-target-line-*, fallback)`, never re-hardcoded literals.
- `.week-detail-grid` collapse at ≤56.24rem must be genuine `display: block`, not a `1fr` fallback.
- `.week-detail-page`'s existing `max-width: 700px` must be widened to `var(--size-content-max, 75rem)`.
- `.week-detail-reading-sheet`, `.week-detail-rail-card`, and `.lesson-content-badges` must each carry the `@media (forced-colors: active)` override shown above, mirroring `SegmentLedger.css:87-103`.
- Raw-hex avoidance in `WeekDetailPage.css`/`LessonContentView.css` is a convention to follow, not a CI-enforced guarantee — `fieldJournalTokens.test.ts:232-238` only asserts hex containment inside `.paper-stock--ruled`/`--graph`/`--card`, not hex absence elsewhere.
- Do not modify `LessonContentView.css`, `SegmentLedger.css`, `ResourcesPanel.css`, `IpNotice.css`, or `Stamp`'s CSS outside the specific declarations named in this plan — every value here composes AROUND these components, never INTO their preserved internals, with the sole exception of the D5 and D6 declarations explicitly specified above (both live in `LessonContentView.css` but are additive, scoped rules, not edits to preserved chunk/ledger internals).
- Do not reintroduce per-chunk background tints on `.lesson-content-chunk--{rule,example,translation,dialect}` (the J-002 guard test forbids it).

### Permitted variation

Engineering may adjust the exact `--space-*` token used for reading-sheet/rail-card padding by one step if a rendered check shows a closer visual match to the mockup's proportions, PROVIDED it remains an existing token and the D1 rhythm invariant (`padding-top: var(--space-8, 2rem)` = one 32px band) is preserved exactly. The tape-strip decoration is explicitly omitted; engineering must NOT invent rotation/color/opacity/size values for it — reintroducing it requires a follow-up design excerpt or explicit product sign-off, treated as new scope. The week-numeral's exact offset may be nudged within existing spacing tokens if it visually collides with the margin-rule stripe (unverified without a browser render — see browser validation step 2 below). The following mockup-to-token snaps are pre-approved as already decided, NOT open engineering discretion: rail shadow 5px vs the mockup's 6px; card padding 24px vs the mockup's uneven 26/22px; rail padding-bottom 40px vs the mockup's 44px. The page-number footer bar remains out of scope; engineering must not add it opportunistically even though the underlying data is available. The reading sheet's left-padding derivation is fixed as `calc(57px + var(--space-6, 1.5rem))` — engineering may reformat as an equivalent tokenized expression but must not collapse it back into an unexplained bare literal.

### Design-level unresolved decisions (non-blocking, routed to validation or product sign-off)

1. **D5's badge narrowing.** The visual-echo border-left treatment (instead of a structural margin-column relocation) narrows issue #39's written acceptance criterion 7. This reading is evidence-grounded and was independently reviewed as sound, but is a genuine scope narrowing of the written criterion — needs issue-owner confirmation that it satisfies product intent before the issue is treated as fully closed against criterion 7.
2. **Week-numeral/margin-rule glyph collision.** Unverifiable without a real render; if a collision is found during browser validation, resolve it within the Permitted variation allowance above (nudge the numeral's offset within existing spacing tokens).
3. **Adjacent dual-accent border proximity.** `.lesson-content-group`'s existing left-border accent (`--color-accent-primary`) and the new `.lesson-content-badges` border-left accent (`--color-accent-margin-rule`) sit close together as two differently-colored edge rules. Accepted as minor layering rather than redesigned; flagged for a visual-confirmation check in browser validation, not a CSS change.
4. **Baseline-offset rule of thumb.** The D1/D6 arithmetic is a documented typographic convention, not measured Fraunces/Source Sans 3 font metrics. This does not block implementation because no text in this composition ends up unoccluded on the ruled backdrop, but would need re-verification if a future issue removes a chunk's opaque background.

## Judge route

`PLAN_DUCK` is eligible at the orchestrator's discretion after this draft is finalized; no `VISUAL_REVIEW` checkpoint is pre-authorized for this issue. Deterministic test failures (lint, `tsc`, vitest, Verifier, Browser Validator) always dominate any judge finding, per `docs/JUDGE-CONTRACT.md`. This plan does not itself commit to a specific `CODE_REVIEW` checkpoint call cap or rubric beyond what the standing judge policy already provides; if the orchestrator elects to run `PLAN_DUCK` or a `CODE_REVIEW` checkpoint, it applies the milestone's existing token-fidelity and no-fabrication rubric used for prior issues in this milestone (see issue #31's plan for the rubric template), scoped here to the D6 cascade-selector correctness and the forced-colors override.

## Ordered work

Owner for every step: T1 first-line, escalate to T2 on two counted gate failures. Strict TDD — tests are written before production edits in every step.

1. **Fix D6 first, in isolation.** Write a failing test asserting chunk 02's body resolves to the target-line token values (Fraunces, 600, italic, 22px, 1.4 line-height, `#7c6136`/`--typography-role-target-line-color`), confirm it fails for the right reason (currently rendering 18px/31.5px due to the cascade defect), then apply the `.lesson-content-chunk--example .lesson-content-chunk-example-body` declaration from the D6 resolution above, consuming `--typography-role-target-line-*` custom properties with fallbacks. This step is first because it is the smallest change, is independently verifiable, and exposes the cascade trap before any layout work obscures it.
2. **`WeekDetailPage` grid + reading-sheet chrome.** Add `.week-detail-grid`, `.week-detail-reading-sheet` (consuming `.paper-stock--ruled`), and `.week-detail-reading-sheet-numeral`, wired only around the `available`-state content per the Layout and CSS specification above. Widen `.week-detail-page`'s `max-width` to `var(--size-content-max, 75rem)`. Include the D1 rhythm registration (`padding-top: var(--space-8, 2rem)`, exactly one 32px band) and the corrected `calc(57px + var(--space-6, 1.5rem))` left padding. Add the 390 collapse media query, including the numeral's `display: none` and the reading sheet's collapsed padding/background-image override.
3. **`ResourcesPanel.css` restyle into the attachments rail card, plus `IpNotice` reparenting.** Add `.week-detail-rail`/`.week-detail-rail-card` styling per the specification above, wrap the existing `ResourcesPanel` markup (add a minimal wrapper element in `WeekDetailPage.tsx` if needed — do not alter `ResourcesPanel.tsx`'s internals), add the `<aside>` landmark with `aria-labelledby` pointing at the visible "Attached to this week" heading, and move `IpNotice`'s render call to the last position inside the rail.
4. **Badge margin-annotation accent treatment and the forced-colors block.** Apply the D5 `.lesson-content-badges`/`.lesson-content-badge` declarations in `LessonContentView.css`, and add the `@media (forced-colors: active)` override covering `.week-detail-reading-sheet`, `.week-detail-rail-card`, and `.lesson-content-badges`.
5. **Full guard-test sweep, then browser validation at both viewports** (see Acceptance and validation, and Browser UI validation, below).

## Interfaces and data

No API, schema, migration, or data-model change. No new `PhraseGroup` field is introduced (the Caveat annotation is out of scope precisely because it would require one). `ResourcesPanel`'s props and the `getSignedResourceUrl` contract are unchanged. `IpNotice` reparenting changes DOM position only, not its props.

## Acceptance and validation

**Issue #39's eight acceptance criteria**, transcribed as a checklist:

1. Matches §D.3 at 1440 and the design's specified single-column behavior at 390 (§E.3 itself is not a literal reflow target — see D3 above).
2. Ruled stock with 32px lead and the `#e0b3a5` margin rule present, with body type ON the rhythm where visible (subject to the D1 accepted-drift recording for occluded chunk text).
3. Four-chunk C.5 anatomy in fixed order with numbered mono tabs — VERIFY/PRESERVE, not rebuilt.
4. Target line is Fraunces 600 italic 22px in brass.700 — the D6 cascade fix must actually take visible effect (see browser validation step 4 below).
5. Segment ledger C.6 shows 30/10/20 with minutes in the visible label type — VERIFY/PRESERVE, not rebuilt.
6. Attachments rail matches §D.3 and collapses correctly at 390.
7. Content badges read as margin annotations, subject to the D5 narrowing recorded as an unresolved decision above (visual echo, not structural relocation).
8. No horizontal scroll anywhere at 390, caused by the ruled stock or any other new chrome.

**Plus the milestone's standard fixed acceptance criteria** (ADOPTION-PLAN.md §A.6, as applied by prior issues in this milestone, e.g. issue #31's plan): no state conveyed by color alone; text contrast ≥ 4.5:1; hit targets ≥ 44px; focus ring per the shipped `:focus-visible` technique; decoration inert and `aria-hidden`; zero border-radius; no raw hex outside the token layer (as a followed convention here, not CI-enforced — see guard-test note above); `prefers-reduced-motion` unaffected (no new motion is introduced by this issue).

**Existing suites must stay green, unchanged:**

```
npx vitest run src/__tests__/WeekDetailPage.test.tsx src/__tests__/ResourcesPanel.test.tsx src/__tests__/SegmentLedger.test.tsx src/__tests__/designSystemConsistency.test.ts src/__tests__/fieldJournalTokens.test.ts src/__tests__/typographyFourHands.test.ts
```

**New tests, written before production edits:**

- The D6 token-conformance test from ordered-work step 1 (chunk 02's body resolves to the target-line token values).
- A layout assertion covering the two-column grid and the reading-sheet/rail DOM structure (grid container present with the expected column template in the `available` state; rail is an `<aside>` with the expected accessible name; `IpNotice` is the last child inside the rail).

**Deterministic gate:** `npm run lint`, `npm run type-check`, `npm run build` all clean.

**No-native-dialog scan:** a deterministic source scan (grep-equivalent) for `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` across `WeekDetailPage.tsx`, `ResourcesPanel.tsx`/`.css`, and `LessonContentView.tsx`/`.css` — must return zero matches, matching the currently-verified baseline.

**Independent gates:** a Verifier pass, then a Browser Validator pass, are both required. Neither T1 nor T2 may self-approve completion.

## Browser UI dialog policy

REQUIRED. No `alert`, `confirm`, `prompt`, any `window.*` variant, or `beforeunload` prompt anywhere. Acknowledgement and confirmation use an app-owned accessible modal; validation is inline. This is currently upheld in all three touched files and must remain so, enforced by the deterministic source scan above. No modal is introduced or touched by this issue, so no additional keyboard/focus modal verification is required beyond the general focus checks in browser validation below.

## Browser UI validation

**Launch/readiness:** `npm run dev -- --port 5443 --strictPort` from `H:\CommandCenter\orchestrator\lizbeth_spanish`. `vite.config.ts` hardcodes port 5173, so the CLI flag override is mandatory rather than editing the committed config. Do NOT use ports 4319, 5199, 5211, 5299, 5317, 5321, or 5331 — all were consumed by earlier work in this session. Ready when Vite prints its local URL and the route renders.

**Base URL:** `http://localhost:5443`, week detail route for an enrolled, unlocked week with published resources.

**Fixture/reset:** the existing enrolled-student fixture path used by the issue #31-#38 validations; reset by reloading the route. A completed-week state is also needed to confirm the Stamp does NOT replay on remount.

**Viewport profiles:** 1440x900 AND 390x844. Both are mandatory and must be reported separately.

**Journeys and visible outcomes**, transcribed from the reviewed design handoff's `browser_validation_brief` in full:

*Scope:* `WeekDetailPage` in `available` state (a week with authored content and at least one resource of each `ResourcesPanel` type), verified at both 1440px and 390px, plus one `fetch-error` sub-state spot check at 1440, plus one forced-colors-mode pass.

*At 1440px:*
1. Two-column grid renders, no horizontal scroll.
2. Ruled-paper background plus 3px border plus hard shadow plus week numeral visible without colliding with the margin-rule stripe or heading text (visual-only claim, confirm by render).
3. Four-chunk anatomy renders in fixed order with numbered mono tabs, unchanged.
4. **TARGET LINE CHECK** — confirm the D6 cascade fix actually took effect. Before the fix, chunk 02's body rendered at 18px/31.5px (governed by `.lesson-content-chunk p`) regardless of the dead 21px source value; after the fix it must render Fraunces italic 600-weight 22px/1.4 in brass-700 — visibly larger and more distinct from the page's other 18px chunk text. If it still renders at 18px, the specificity fix did not apply and this criterion fails.
5. Segment ledger shows 30/10/20-proportioned tabs with minutes in the visible labels.
6. Group-level badges show a left border/accent, still positioned above the four chunks; visually check that the badge accent and the group's own pre-existing left-border accent do not read as a single confusing double-rule (see unresolved decision 3 above).
7. Attachments rail shows heading, bordered/shadowed card with resource rows in correct states, `IpNotice` as the last rail item.
8. Resource-row download interaction (loading → ready/error) with a deterministic no-native-dialog scan.
9. Keyboard Tab order is reading-sheet-then-rail with visible focus rings throughout.
10. `fetch-error` sub-state: the reading column shows retry UI, the rail still renders normally beside it.

*At 390px:*
11. Single column, no horizontal scroll anywhere on the page (acceptance criterion 8).
12. DOM/visual order `h1` → reading sheet → rail heading+card → `IpNotice`, same as 1440.
13. Week numeral NOT visible (`display: none`, not shrunk); the ornamental gutter is collapsed to ordinary edge padding.
14. SegmentLedger tabs remain usable, labels wrap rather than truncate/overflow.
15. Rail card renders full width below the sheet, resource rows remain ≥44px touch targets.
16. Confirm the absence of §E.3 chrome (no tri-chip nav, no sticky footer bar) — their presence would indicate scope creep.
17. No-native-dialog scan repeated for the resource-download journey.
18. Keyboard/focus-visible check repeated.

*General (either viewport):*
19. Forced-colors mode (`forced-colors: active` emulation) — confirm the reading sheet, rail card, and badge border-left accent all render with the system `ButtonText` border color and no box-shadow, matching `SegmentLedger`'s existing forced-colors behavior; nothing in the new chrome should disappear or become indistinguishable.

Also verify: 200% zoom / 320px reflow (no horizontal scroll, no content loss).

**Visible outcomes to record:** full-page screenshots at both viewports (confirming no scroll and capturing the rail/`IpNotice` tail), one annotated close-up of the corrected target line at 1440, one close-up of the 390 collapse boundary, one forced-colors-mode screenshot of the reading sheet plus rail card.

**Atelier MCP compiler gap — disclosed and user-authorized, as for issues #31-#38.** The documented hand-transcription / manual `visual_diff` substitute used in those prior issues is PRE-AUTHORIZED here for BOTH the 1440 and 390 passes. This precedent is recorded explicitly, including that the shared Atelier `projectRoot` misconfiguration binding follow-up documented in issue #31's plan amendment remains open and tracked, and is not resolved by this plan.

## Risks and rollback

| ID | Severity | Risk | Mitigation |
|----|----------|------|------------|
| R1 | Highest | The D1 rule-rhythm alignment is genuine arithmetic work, not a class-name swap. The design declares ACCEPTED DRIFT for `LessonContentView`'s 18px/31.5px running text on the grounds that opaque chunk surfaces occlude the rules beneath. The reviewer confirmed this occlusion premise is CSS-verified by `designSystemConsistency.test.ts`'s J-002 background-color guard, not merely assumed — but the criterion is therefore satisfied only where the ruled stock is actually visible, and this is a recorded interpretation, not a universal guarantee | Browser validation at 1440 is the real gate (step 2 of the brief above); the baseline-offset formula is a rule of thumb, not measured font metrics, and is listed as an open limit in unresolved decision 4 |
| R2 | High | The cascade-specificity trap: a naive `.lesson-content-chunk-example-body` fix would silently not render, because `.lesson-content-chunk p` already wins the cascade | Mitigated by ordered-work step 1's ordering (fixed first, in isolation, with a failing test proving the pre-fix state) and the explicit `!important` prohibition |
| R3 | Medium | 390 horizontal scroll from the 96px/81px left padding and the fixed 400px rail | Mitigated by the design's specified collapse (D3) and browser validation steps 11/17 |
| R4 | Medium | Regression against 552 lines of locked `WeekDetailPage` assertions and the page-turn/Strict-Mode safety | Mitigated by running the existing suite unchanged before and after each ordered-work step |
| R5 | Low | Week-numeral glyph width at 52px Fraunces 900 was not measured in this pass (no browser render performed during planning); may visually collide with the margin-rule position | Flagged as unresolved decision 2; resolvable within Permitted variation's numeral-offset allowance during browser validation |
| R6 | Low | D5's badge-as-margin-annotation narrows acceptance criterion 7 from a structural relocation the issue's own framing implies to a visual-echo treatment | Flagged as unresolved decision 1; needs issue-owner confirmation, does not block implementation |

**Rollback.** All changes are additive CSS plus a bounded JSX restructure (a wrapper element and a reordered render call) across four files, with no data or schema change. A `git revert` of the single commit restores the prior screen with zero migration.

## Assumptions and open decisions

**Safe assumptions:**

- The issues #31-#38 shipped work (tokens, `.paper-stock--ruled`, `role.target-line`, C.5/C.6/Stamp/ResourcesPanel) is ground truth and correct, per their own prior design-review-PASS and browser-validation records.
- The enrolled-student fixture used by prior validations remains available for this issue's browser validation.
- Contrast ratios cited in this plan are hand-computed and explicitly flagged as such, per the design packet's own disclosure.

**Recorded open items from the design handoff's own unresolved decisions**, all non-blocking and routed to validation or product sign-off, not silently resolved:

1. The D5 narrowing of acceptance criterion 7 needs issue-owner confirmation.
2. Possible week-numeral / margin-rule glyph collision, unverifiable without a real render.
3. The adjacent dual-accent border proximity, accepted with a visual-confirmation check.
4. The baseline-offset rule of thumb used for D1/D6.

**Standing user authorization.** The user has set an explicit session goal to implement and browser-validate all Field Journal DS issues without approval checkpoints, and has granted broader standing authorization to proceed, consistent with the precedent recorded in issue #31's plan ("keep going until all the gh issues are finished"). This is recorded here as the orchestrator's account of that standing authorization. See "Approval basis" at the top of this document for how it was applied to this specific plan.

## Required approvals

This plan document's engineering-dispatch approval is recorded in "Approval basis" at the top of this document, under the orchestrator's application of the recorded standing authorization. That record, not this section, is the operative approval statement. If the standing authorization is later withdrawn or found not to cover this issue, this plan reverts to requiring explicit per-document user approval before further T1/T2 work proceeds.
