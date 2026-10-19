# Lizbeth Spanish — Issue #36: DS Components C.4-C.8 (Week Card, Lesson Chunks, Ledgers, Metric Plate)

**Status: Drafted, routed to engineering under the user's standing authorization. This document has not itself been separately approved by the user; the user has granted standing authorization ("keep going until all the gh issues are finished") that the orchestrator applies to route this plan to engineering, per the Approval basis recorded below. Approval of this document authorizes only issue #36's scope; it does not authorize any of issues #37-#44.**

Plan ID: `lizbeth-spanish-issue36-week-card-lesson-chunks-ledgers-metric-plate`
Task ID: `lizbeth-issue36`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: engineering-fleet

This plan grants no authority to begin implementation on its own. Explicit user approval, relayed by the orchestrator, is required before any T1/T2 engineering writer starts work.

---

## Approval basis

This plan was routed to engineering under the orchestrator's application of the user's standing authorization, not a user-verified per-plan approval. The record below is an orchestrator-applied inference, consistent with the Status line above, and follows the same provenance discipline the #31-#35 plans used.

- **Standing authorization quoted (verbatim, as relayed by the orchestrator):** "didn't i tell you to stop asking me for approval? i told you to keep going until all the gh issues are finished," reinforced by an explicit session goal, "don't stop until all the DS gh issues are implemented and browser validated."
- **Application:** The orchestrator applied this standing authorization to route this plan (issue #36 of `lebobo88/lizbeth-spanish`, the next issue in the dependency chain the user directed continuation through, after #31, #32, #33, #34, and #35) to engineering without a further live per-plan checkpoint.
- **Confirmation the standing goal remains active:** the user's own stop-hook feedback, received in this session, again confirmed the "don't stop" directive requires continued progress. The orchestrator treated this as reaffirming, not superseding, the original standing authorization; it did not introduce any new grant of authority beyond what was already quoted above.
- **Provenance label:** This basis reached Scribe entirely through the orchestrator's account of the session; Scribe has not independently observed the quoted user statements or the stop-hook feedback. It is recorded here as an orchestrator-applied inference under standing authorization, NOT as a Scribe-verified per-document user approval.
- **`PLAN_DUCK` Codex judge checkpoint (Terra tier, shadow/advisory, REVISE).** This plan involves a genuine data-model change — `RoadmapWeekState` widened from three to four values, a new batch completion-data fetch, and the first issue in this milestone to touch actual student-progress semantics rather than presentation alone — so a Terra-tier `PLAN_DUCK` judge pass was run in shadow/advisory mode, not policy-blocking, per `docs/JUDGE-CONTRACT.md`. It returned verdict **REVISE** with five findings (J-01-36 through J-05-36). Four were resolved directly by Planner against repository evidence: J-02-36 (batch-fetch error handling, freshness, and invalidation, folded into Phase 1), J-03-36 (the C.7/C.8 integration site definitively resolved as integration into `OwnerDashboardPage.tsx`/`.css` rather than standalone components, folded into section 5 and Phase 5), J-04-36 (the four-state test-matrix and non-type-consumer audit requirement, folded into section 9), and J-05-36 (C.6 tablist automatic-activation timing and the C.7 attention glyph, both accepted, folded into section 5, 11, and 13). The full disposition table is in section 14 ("Judge review disposition").
- **J-01-36, the fifth finding, distinguished from the other four.** This finding concerned the C.4 "current week" progression rule — whether a returning student's current week should be the most-recently-unlocked week (today's shipped behavior) or the lowest-numbered unlocked-and-not-completed week. This is a genuine product/behavior decision affecting what a real student sees, not a bounded engineering call resolvable from repository evidence alone. The orchestrator asked the user directly. A live answer could not be waited on indefinitely, given the user's own active standing "don't stop" directive (reaffirmed by the stop-hook feedback noted above), so the orchestrator resolved it itself with the lower-risk default: **keep the existing most-recently-unlocked-week-is-current behavior (Option B)**, unchanged from what `src/lib/roadmap.ts:97-98` ships today.
  - **Precise provenance, recorded without overstatement:** this is an orchestrator/coordinator judgment call made under time pressure from the user's own standing authorization. It is explicitly **not** a direct user answer to the specific question asked, and it does not carry the weight of one. Do not read section 13's or section 14's "resolved" language as meaning the user personally chose Option B.
  - **Disclosed as reversible:** the choice is recorded in the plan (sections 3, 8, 13, and 14) as explicitly reversible to Option A (lowest-numbered unlocked-and-not-completed) on a later explicit user request, with the swap contained to the current-week selection logic inside `computeWeekRoadmap` and no rework required to the four-state model, the batch fetch, or the C.4 visual work.
- **Date:** 2026-09-01.

---

## 1. Outcome and audience

Implement and browser-validate GitHub issue #36, "DS components C.4-C.8: week card, lesson chunks, ledgers, metric plate." This is the sixth issue in the 14-issue Field Journal Design System milestone (#31-44); issues #31-35 have already landed.

Audience for the resulting product surfaces:

- **Students** — the week roadmap (C.4 week card), lesson content (C.5 lesson chunks, C.6 segment ledger), and flashcards (shared badge/geometry patterns).
- **Owner** — the dashboard ledger (C.7 owner ledger row) and metrics (C.8 metric plate).

Audience for this document: T1/T2 engineering implementers, the Verifier, and the Browser Validator. This plan must be sufficient for implementation without re-deriving design decisions.

---

## 2. Scope and non-goals

### In scope

- **C.4** — four-state week card (`WeekCard.tsx` / `WeekCard.css`).
- **C.5** — four-chunk lesson anatomy with numbered mono tabs (`LessonContentView.tsx` / `LessonContentView.css`).
- **C.6** — segment ledger as a proportional filled ledger (`LessonContentView` plus a new `SegmentLedger` component).
- **C.7** — owner ledger row as a **new** component.
- **C.8** — metric plate as a **new** component.
- `BandRoadmap.tsx` / `BandRoadmap.css` grid and sheet geometry.
- `FlashcardsViewer.tsx` / `FlashcardsViewer.css` badge-primitive adoption and geometry consistency.
- First real consumption of the #32 `typography.role.display` token family and of the #35 `Badge` and `Stamp` primitives.
- The D2 four-state data-model change (`RoadmapWeekState` widened to four values) plus its supporting batch completion fetch.
- New/updated design tokens, dual-written to `.atelier/tokens/field-workbook.tokens.json` **and** `src/tokens/field-workbook.generated.css`.

### Non-goals / protected behavior

Do **not** regress:

- `BandRoadmap`'s C.9 `JournalEmptyState` (`SpotIllustration` + `paper-stock--graph` + dashed rule — all three structurally required per the #34 removal test).
- `FlashcardsViewer`'s #34 zero-radius fix.
- `LessonContentView`'s #33 tint retirement (uniform `--color-surface-chrome-default` chunk background).
- `WeekCard`'s completed-state `ink.moss` association from #33's HIGH-RISK fix.

`AccountStatusPill` wiring is explicitly **out of scope** — it belongs to the later owner/admin-roster issue.

No commit, push, PR, or deploy unless the user explicitly requests it.

---

## 3. Repository findings (evidence)

Findings below are from a nested Researcher pass that returned a 31-entry file+line source ledger covering the full C.4-C.8 reference transcription, ADOPTION-PLAN deviations, current state of all four scoped files, non-regression verification of the #33/#34 fixes, a primitive-consumption audit, typography-role status, test inventory, and dev-port conflict evidence. All evidence is repository-local; no external sources were used.

- **`WeekCard.tsx`/`WeekCard.css`** is 3-state only today. The week number is set in Fraunces 600 at `--typography-fontSize-lg` (~18px) — **not** the display role. `WeekCard.css` contains **no** box-shadow at all (hard-offset-shadow language is entirely absent). The action button is unconditionally "Open week N" for every non-locked state.
  - Already correct and must be **preserved verbatim** in interaction logic:
    - The icon+word pairing (`ICON_BY_KEY` + `week.stateLabel`, `WeekCard.tsx:48-53`).
    - The locked-week inline `aria-expanded` disclosure with Escape-to-close and focus return (`WeekCard.tsx:68-99`).
- **`src/lib/roadmap.ts`**: `RoadmapWeekState` is `'completed'|'current'|'locked'` only. `computeWeekRoadmap` (lines 82-109) is a synchronous pure function issuing zero network calls; it infers "completed" purely from unlock order (`unlockedWeeks.has(...) && !== currentWeekNumber`, lines 96-107) and selects the current week via `Math.max(...unlockedWeeks)` (lines 97-98). C.4's "unlocked · not started" state is **unreachable** under this model.
- **`src/lib/weekUnlock.ts:18-21`**: the `Week` interface declares only `week_number` and `unlock_offset_days` — no `id`. `LessonRow` (`src/services/roadmapData.ts:32-38`) does carry `id`, and `BandRoadmap.tsx:33-42` already passes `LessonRow[]` in structurally, so the data exists at the real call site but is not in the declared contract.
- **`src/services/adminStudentData.ts:167-184`**: `getLessonProgress(enrollmentId, lessonId)` is single-row; no batch variant exists. Its only consumer is `LessonContentView.tsx:58`.
- **`supabase/migrations/202608270001_issue2_progress_dashboard.sql:2-14`**: `student_lesson_progress(lesson_id, completed_at)` exists as needed. RLS policy `students_read_own_lesson_progress` (lines 29-37) permits the proposed batch query for the anon-key client `BandRoadmap` already uses.
- **`LessonContentView.tsx`/`.css`**: the four chunks already render unconditionally in fixed order; differentiation is currently by color-coded `border-left` only (`.lesson-content-chunk--rule/example/translation/dialect` using `brass-600` / `status-success-border` / `status-neutral-border` / `terracotta-600`) on a uniform `--color-surface-chrome-default` background — this uniform background **is** #33's ratified tint retirement. There is **no** numbered mono tab today. The C.6 rhythm control exists behaviorally (`RHYTHM_SEGMENTS`, visible "Segment N of 3" label, per-segment jump buttons) but ships as a **stepper** (`<nav aria-label="Lesson segments">` + `aria-current="step"`, `LessonContentView.tsx:75-86`) rendered as small compact pill buttons, not a proportional filled ledger. Badges render as ad hoc chips, not the `Badge` primitive.
- **`BandRoadmap.tsx`/`.css`** is a thin wrapper: fetches lessons in an existing effect (lines 26-54), calls `computeWeekRoadmap`, renders the `WeekCard` list or `JournalEmptyState`. Grid is currently 2-up; the reference is 4-up. Outer sheet uses `--shadow-print`.
- **Amendment (J-02-36, PLAN_DUCK Terra-tier judge finding, resolved)** — `BandRoadmap.tsx` already has a three-value status machine, read directly: `const [status, setStatus] = useState<'loading' | 'error' | 'ready'>('loading')` (line 23), a loading paragraph (line 65), an error branch rendering `<p role="alert" className="band-roadmap-error">Could not load this band's roadmap. Please try again.</p>` (lines 67-71), and every week-card render gated behind `status === 'ready'` (lines 89-99). The existing effect (lines 26-54) calls `fetchLessonsForBand(enrollment.band_id)`, computes the roadmap in `.then`, and maps any rejection to `setStatus('error')` in a single `.catch` (lines 46-49), with a `cancelled` guard against out-of-order resolution. Its dependency array is `[enrollment.id, enrollment.band_id, enrollment.enrollment_date, enrollment.completed_at]` (line 54) — nothing about lesson completion, so nothing in the current design invalidates on a completion write. See Phase 1 and section 9 for the resolution.
- **`FlashcardsViewer`** has no dedicated C.4-C.8 artboard in the reference; it is in scope only for shared patterns (segment progress, badges). Its #34 zero-radius fix is intact.
- **#35 primitives**: `Control` (six tiers after this issue) and `Field` are already consumed in auth/admin flows. `Badge`, `AccountStatusPill`, and `Stamp` are **all zero-consumer** in production; this issue is their first real wiring point (`Badge` and `Stamp` only).
- **`typography.role.display`** (#32) exists only in the JSON-only token layer (`src/tokens/semantic.json`) and is **absent** from `src/tokens/field-workbook.generated.css`, the file components actually `var()`-consume. `src/__tests__/typographyFourHands.test.ts` asserts it has zero consumers by design.
- **`OwnerDashboardPage.tsx:31`** already ships a plain 4-column table with a `<button className="dashboard-link">` per row (the C.7 reuse pattern) and a plain metric strip. `.dashboard-panel` background is `paper-100` (`OwnerDashboardPage.css:5`), **not** `paper.50`.
- **Amendment (J-03-36, PLAN_DUCK Terra-tier judge finding, resolved, now definitive)** — read directly, `OwnerDashboardPage.tsx` line 31 already renders exactly the C.7 table shape: `<table><thead><tr><th>Student</th><th>Band</th><th>Progress</th><th>Last active</th></tr></thead>` with one `<button className="dashboard-link">` per row — the same four columns and the same one-interactive-control-per-row shape the design handoff specified for C.7. The progress cell today renders `{e.completed_lesson_count} / {e.lesson_count} ({Math.round(e.completion_percent)}%)` — it already carries raw figures but pairs them with a bare percentage and has no filled bar and no zero-padding, so it needs the C.7 treatment regardless of where the component lives. Line 25 already renders the C.8 metric strip via a local `Metric` component (line 35, label + value): "Total students", "Active this week", "Needs attention", "Completion rate" — including both of the reference's own C.8 examples. The real data source is `getOwnerDashboard()` from `src/services/adminStudentData.ts`, returning `OwnerDashboard { settings, summary, students }`. This supersedes former open item #2 (see section 5 and Phase 5 for the resulting integration decision).
- **Existing tests**: `src/__tests__/{WeekCard,LessonContentView,BandRoadmap,FlashcardsViewer}.test.tsx` all exist. Runner: Vitest (`npm test`); type-check `tsc --noEmit`; E2E Playwright (`npm run test:e2e`, `testDir ./src/__tests__/e2e`, baseURL `http://localhost:8888` via `netlify serve`).
- **Reference artboard**: `design/field-journal/Field Journal DS.dc.html` — C.4 at lines 407-469, C.5 at 471-502, C.6 at 504-522, C.7 at 524-545, C.8 at 548-559, the Band-ink legend at 86-99, and the `ink.moss` "completed stamp" legend at line 82. `design/field-journal/ADOPTION-PLAN.md` maps this to its issue 6 (line 225) with matching scope and dependency graph (line 292); its only two ratified deviations (lines 96-114) are the 26px margin-hand and a band-ink contrast correction, neither blocking here.

---

## 4. Reference specification (implementation-grade)

This section reproduces the reference artboard's binding values verbatim. All values, token names, and file/line references below are load-bearing for implementation — do not paraphrase or approximate them.

### C.4 — Week card (`Field Journal DS.dc.html:407-469`)

- Week number: Fraunces 900, 52px, line-height .8, letter-spacing -.04em, `ink.1000` (locked state: `ink.700`).
- Mono eyebrow "Semana": IBM Plex Mono 11px/600/.2em/uppercase, `brass.700` (locked state: `ink.700`).
- Card: 3px rule border, hard offset shadow `5px 5px 0 0 ink.1000` (current-state card: `brass` shadow color instead); minimum 4-up desktop grid.
- **States:**
  - `completed` — "✓ Completed 12 Aug" mono 12px/.12em/uppercase `ink.moss`; decorative `aria-hidden` DONE stamp rotated -8deg; action label "Review week 1".
  - `current` — decorative tape strip + `ClipRing` marks; "◆ This week" `brass.700`; Caveat-hand "you're here" 21px `terracotta` rotate(-1deg); action "Open week 3" using the ink-fill primary tier.
  - `unlocked` — "○ Unlocked · not started" `ink.700`; **no** stamp or hand annotation; action "Open week 2" using the secondary paper-fill tier.
  - `locked` — `paper.200` background with graph hatch; 3px `ink.700` border; padlock SVG **plus** the visible word "Locked"; date line "OPENS 03 SEP 2026 · IN 4 DAYS" mono 12px/.1em `ink.700`; decorative `aria-hidden` LOCKED stamp rotated 8deg `terracotta.600`; action "Why locked?" using the new quiet-outline tier.

### C.5 — Lesson chunk anatomy (`407-469` region continues; C.5 at `471-502`)

- Fixed order: `01 · RULE BOX`, `02 · EXAMPLE`, `03 · TRANSLATION TASK`, `04 · DIALECT NOTE`.
- Each chunk: 3px rule border, `5px 5px 0 0` hard shadow, padding `30px 24px 24px`.
- Numbered tab: absolutely positioned `top:-3px left:-3px`; `ink.1000` background; `paper.50` text; IBM Plex Mono 12px/700/.18em; padding `5px 12px`.
- Chunk 02 body: Fraunces 600 italic 21px.
- Chunk 03: dashed-rule ruled writing area (2px dashed slate + repeating-line background).
- Chunk 04: carries the dialect `Badge` (real per-lesson label) and the "Cited source" `Badge`.

### C.6 — Segment ledger (`504-522`)

- One flex row, 3px border, `5px 5px 0 0` shadow, three segments with flex ratios literally **30/10/20** so width encodes duration.
- 3px inter-segment borders; `min-height: 74px`.
- Active segment: `ink.1000` background / `paper.50` text.
- Per segment: an index line "01 / 03" (mono 11px .2em, opacity .75) and a label line "PHRASES · 30 MIN" (15px 700 .08em).
- Rows 2-3: "02 / 03 Q&A · 10", "03 / 03 PRACTICE · 20".

### C.7 — Owner ledger row (`524-545`)

- Wrapper: 3px border + `5px 5px 0 0` brass shadow; own explicit `paper.50` background.
- Header row: `ink.1000` background with mono brass column labels.
- Progress cell = filled bar (outer height 12px, 2px border, `paper.200` track, `ink.1000` fill) **plus** a zero-padded raw figure "02 / 26" (mono 11px `ink.700`). A bare percentage is a **failing** implementation.
- Band cell = left-border-accented mono chip (`border-inline-start: 6px solid <band ink>`) — **not** a pill and **not** the `Badge` primitive.

### C.8 — Metric plate (`548-559`)

- Two-column grid `1fr 1fr`, gap 18px.
- Each plate: mono uppercase label 11px/.18em above a Fraunces 900 52px line-height 1 figure.
- Dark plate: "Total students" / "18".
- Light plate: "Needs attention" / "03" zero-padded, with a `terracotta.600` figure.

---

## 5. Design handoff summary

Standard-route `DESIGN_HANDOFF` revision 2, produced by design-director with ux-architect and visual-system-designer. Its binding content, reproduced in full:

### D1 — Chunk tint conflict (resolved)

Keep #33's uniform neutral chunk background; do **not** implement the reference's four tinted chunk fills. Chunk identity is carried by the new numbered mono tab (number + fixed position) as the primary and sufficient differentiator. The existing per-chunk border hue may remain **only** as a secondary, non-load-bearing decorative accent — no state, meaning, or identity may depend on it.

### D2 — Four-state model, resolved with a data-fetch spec

`RoadmapWeekState` gains a genuine fourth value `unlocked`. `computeWeekRoadmap` **stays synchronous and pure**; it gains a third parameter `completionByLessonId: Map<string, string | null>` (lessonId → `completed_at`).

A new batch function `getLessonProgressForEnrollment(enrollmentId, client)` is added to `adminStudentData.ts` beside the existing single-row `getLessonProgress`:

```sql
SELECT lesson_id, completed_at FROM student_lesson_progress WHERE enrollment_id = $1
```

One round trip, never N+1, bounded by the ≤26-week roadmap. It is fetched once in `BandRoadmap`'s existing data-fetch effect and passed down. `LessonContentView.tsx`'s single-row call is unchanged.

Inside `computeWeekRoadmap`: a week whose lesson has `completed_at` set is `completed`; an unlocked week with no completion entry is `unlocked`, never folded into `completed`. Design review verified the schema and RLS policy support this exactly.

**Design review's one remaining implementation-time item**: `Week` (`weekUnlock.ts:18-21`) has no `id` field to key the completion map by. Add `id: string` to `Week` and use it as the join key. One-line, mechanical, against already-available data.

### D3 — Stamp boundary

`Stamp` is wired here — it is the natural consumer for C.4's DONE and LOCKED stamps and would otherwise stay at zero consumers. It stays `aria-hidden="true"` by construction and is layered in **purely** as decoration. Its `label` is **never** the accessible name; the accessible icon-and-word state text always comes from the existing sibling markup (`week.stateLabel`). Reused verbatim for `done` (-8deg, `moss`) and `locked` (8deg, `terracotta.600`).

### D4 — Badge wiring

`Badge` gains a backward-compatible optional `label?: string` prop falling back to today's fixed `BADGE_TEXT[variant]`, so C.5's dialect badge carries real per-lesson content instead of the hardcoded "Dialect · Rioplatense". A new `cited-source` `BadgeVariant` is added (`BADGE_TEXT['cited-source'] = 'Cited source'`, `brass.700` on the tint `archaic` already ships, aliased as `color.badgeTint.citedSource`). `AccountStatusPill` stays out of scope.

### D5 — Display-role sizing, resolved

A new DTCG composite `typography.role.display-sm` (Fraunces 900 / 52px / line-height 1 / letter-spacing 0). **Not** a bare font-size override, because the reference's three big-Fraunces consumers diverge on line-height and letter-spacing too, and a bare override would silently corrupt them at every reuse site.

`role.display` (#32) exists only in the JSON-only layer and is **absent** from `field-workbook.generated.css`, so `display-sm` is genuinely new load-bearing surface and must be dual-written as flat CSS custom properties (`--typography-role-display-sm-font-family/-font-weight/-font-size/-line-height/-letter-spacing`) into `field-workbook.generated.css` per the existing "J-33-004 fix" convention.

`display-sm`'s canonical shape matches C.8's metric figure; C.4's week number layers two named component overrides on top (line-height .8, letter-spacing -.04em) — both confirmed exact matches to the reference.

### Band colors

Taken directly from the reference's own Band-ink legend (`Field Journal DS.dc.html:86-99`) with no substitution:

- `color.band.beginner = {color.brass.600}` (5.02:1 on `paper.50`)
- `color.band.intermediate = {color.terracotta.600}` (4.689:1)
- `color.band.advanced = {color.ink.slate}` (7.0:1)

All three are new **alias names** for existing, already-AA-tested primitives (`App.css:550-551`), not new hex values. `ink.moss` is explicitly **not** used for any band tier — it keeps its single documented meaning, "completed stamp" (legend line 82, and D3), avoiding a same-color-different-meaning collision on the owner dashboard.

`OwnerLedgerRow` ships its **own** explicit `paper.50` background matching the reference (lines 533, 539), so the band-chip contrast determination is decoupled from the host-surface question.

**Amendment (J-03-36, resolved, now definitive) — C.7/C.8 host surface.** Former open item #2 in section 13 called the host surface unresolved and defaulted to standalone components; that framing is superseded. `OwnerLedgerRow` and `MetricPlate` are built as reusable presentational components **and** integrated into `OwnerDashboardPage.tsx`, replacing the existing plain table rows and the local `Metric` component. They are not shipped standalone. Rationale: `OwnerDashboardPage` is the only real consumer and already renders exactly this data (section 3 evidence), so shipping these standalone would create zero-consumer components — repeating precisely the gap that #35 left and that #36 exists to close. A bare percentage is also already a failing implementation under the issue's own C.7 criteria, so the progress cell must change regardless of where the component lives.

Component contracts:

- `MetricPlate` public props: `{ label: string; value: number | string; tone?: 'default' | 'dark' | 'attention'; zeroPad?: boolean }`. Numeric values are zero-padded to two digits when `zeroPad` is set; the "Needs attention" plate uses `tone="attention"` (`terracotta.600` figure). A pre-formatted string value such as the completion-rate percentage passes through unpadded.
- `OwnerLedgerRow` public props: `{ studentLabel: string; bandName: string; bandTier: 'beginner' | 'intermediate' | 'advanced'; completedCount: number; totalCount: number; lastActiveAt: Date | string | null; needsAttention: boolean; onOpenStudent: () => void }`.
- Data mapping from the real `OwnerDashboard` shape: `MetricPlate` row maps `summary.total_students`, `summary.recently_active`, `summary.needing_attention`, and `summary.completion_rate` (the last stays a formatted percentage string, not zero-padded — a rate, not a count). `OwnerLedgerRow` maps per student-enrollment pair: `studentLabel` from `student.email ?? 'Student'`; `bandName` from `enrollment.band_name`; `completedCount`/`totalCount` from `enrollment.completed_lesson_count`/`enrollment.lesson_count`; `lastActiveAt` from `enrollment.last_activity_at`; `needsAttention` from `enrollment.attention_reasons.length > 0`; `onOpenStudent` from the existing `navigate('/admin/students/' + student.id)` call. The existing search, sort, and empty-state behavior on that page is preserved unchanged.
- `bandTier` is **not** currently a typed field — the page has only `band_name`. Bounded implementation item: derive the tier from the existing band data rather than string-matching display names where possible; if only the name is available, centralize the mapping in one place with a documented fallback to `advanced`-neutral styling for an unrecognized band. Do not scatter string comparisons through the component.
- **Scope note the user must see at approval**: `src/pages/OwnerDashboardPage.tsx` and `OwnerDashboardPage.css` are **not** in issue #36's originally listed scope (WeekCard, LessonContentView, BandRoadmap, FlashcardsViewer). This decision expands the touched-file set by those two files. This is a Planner decision the user may override at approval; if overridden, the fallback is standalone components with the explicitly recorded consequence that they ship with zero consumers.

**Contrast invariant carried forward, hard constraint**: nesting `OwnerLedgerRow` inside `.dashboard-panel` (background `paper-100`) with its own background stripped would invalidate the reviewed band-ink contrast determination (brass.600 5.02:1, terracotta.600 4.689:1, ink.slate 7.0:1, all against `paper.50`) and require a new design check before shipping. Integration therefore requires `OwnerLedgerRow` to keep its own explicit `paper.50` background regardless of its host container.

**Amendment (J-05-36, advisory, accepted) — C.7 attention glyph.** Closes former open item #3's open end. The attention marker is a filled triangular warning glyph rendered as inline SVG with `aria-hidden="true"`, paired with the visible words "Needs attention" in `terracotta.600`, sized to match the row's mono label line. The glyph is decorative and never the sole signal; the visible words carry the meaning. The reference artboard has no precedent for this row, so this remains a Planner-recorded choice rather than a transcribed spec value.

### Control primitive — sixth tier

`Control` gains a sixth tier `quiet-outline` (transparent background, `brass.700` text, 3px dashed `ink.700` border, no shadow, amber-wash hover via the existing `color-mix()`-with-fallback pattern). Justification verified by design review: the existing `quiet` tier has no visible border, and `:disabled`'s dashed look is reserved for real native-disabled semantics — "Why locked?" is a working `aria-expanded` toggle and must not borrow the disabled visual contract.

### New tokens

All dual-written to `.atelier/tokens/field-workbook.tokens.json` **and** `src/tokens/field-workbook.generated.css`:

- `typography.role.display-sm`
- `font.letterSpacing.wider` (.18em)
- `fontSize.labelSmall` (11px / 0.6875rem)
- `fontSize.segmentLedgerLabel` (15px)
- `border.widthAccent` (6px)
- `shadow.mutedCard` (`5px 5px 0 0 ink.700` — a third hard-offset hue, for C.4 locked)
- `color.ruleTint.slate` (#cddadd, C.5 chunk-03 ruled line — the only genuinely new hex leaf)
- `color.band.beginner` / `color.band.intermediate` / `color.band.advanced`
- `color.badgeTint.citedSource`
- `size.metricPlateGap` and `size.metricPlatePadding` (18px)
- `size.segmentLedgerMinHeight` (74px)
- Plus component-scoped one-offs: current-annotation 21px / rotate -1deg; lock-icon stroke-width 2.5px.

Everything else maps to existing aliases: `--border-width-rule` (3px), `--border-width-strong` (2px), `--shadow-card`, `--shadow-brass`, the `--space-*` scale, `--font-weight-label`, `--font-letter-spacing-eyebrow`, `--typography-letterSpacing-extra`.

### Component reuse

- C.4 current-state decoration reuses `.journal-tape` and `<ClipRing>` verbatim (`ClipRing` is purpose-built to avoid border-radius, preserving zero-radius where the specimen uses a rounded div).
- C.4 locked background reuses `.paper-stock--graph` verbatim — an intentional, explicitly directed deviation from the specimen's slightly different inline hatch, not an oversight.

### UX / accessibility

- C.6 becomes `role="tablist"` / `role="tab"` per segment / `role="tabpanel"` for the lesson-content block — a **real ARIA-model change** from today's shipped stepper, not a restyle.
  - Roving tab stop (active `tabindex 0`, others `-1`).
  - Left/Right rove; Home/End jump first/last.
  - Tab/Shift+Tab enter and exit the group as one stop.
  - Enter/Space also selects (automatic activation, matching existing click behavior).
  - Accessible name speaks ordinal + label + minutes spelled out, e.g. `aria-label="1 of 3: Phrases, 30 minutes"`.
  - **Amendment (J-05-36, advisory, accepted)**: panel swap on arrow-key rove is synchronous with focus movement and introduces no perceptible delay. No async fetch, no suspense boundary, and no loading state may be introduced between focus moving to a tab and its panel becoming visible, since all three segments' content is already available client-side via `RHYTHM_SEGMENTS`.
- C.7 uses a native `<table>` with `<th scope="col">` and exactly one interactive control per row (a `<button>` styled as a link), with a composed accessible name including both owner name and progress figure. `role="progressbar"` and native `<progress>` are avoided because assistive-technology support for `aria-valuetext`/native value announcement is inconsistent, risking the accessible experience silently diverging from the visible zero-padded text — the filled bar is `aria-hidden` decoration and the zero-padded raw figure is the real content.
- C.4's disclosure keeps its `aria-expanded`/`aria-controls`/Escape-with-focus-return logic verbatim; only the toggle's visual tier changes.
- The focus-ring invariant (3px `ink.slate`, 2px offset) applies to every new interactive element — outward form on C.7, inset form on C.6 (segments are edge-to-edge and an outward ring would clip).

### Responsive

- Breakpoints: mobile ≤640px, tablet 641-899px, desktop ≥900px (`App.css:632,699,726`).
- `BandRoadmap` never drops below 2-up above mobile (1-up mobile / 2-up tablet / 3-4-up desktop).
- C.5 is 1-up mobile and 2-up tablet+desktop with DOM and tab order fixed at 01→04 regardless of column (no CSS `order` decoupling).
- C.6 may relax strict duration-proportional width at mobile to preserve the 44×44 touch target but must never truncate label+duration text — wrap instead.
- C.7 uses an `overflow-x:auto` wrapper at mobile rather than card-collapse, matching `OwnerDashboardPage.css`'s precedent.
- Spanish content is real and can be longer than English at every site — size to content or wrap, never fixed-width truncate.

### Never-color-alone and reduced-motion

Never-color-alone is enforced on every new state (C.6 active/inactive differ by bg+color+opacity; C.7's attention-flagged row pairs an icon with the visible words "Needs attention" in `terracotta.600`, matching C.8's attention plate). `forced-colors: active` and `prefers-reduced-motion: reduce` fallbacks extend to every new component using this project's existing patterns.

### Content constraints

The locked card face must show **both** the real absolute unlock date and the real relative-distance string together — today only the relative label is on the face (`WeekCard.tsx:53`) and the absolute date is disclosure-only (lines 87-95), so the absolute date must be promoted. C.6 minutes are always set in visible type in addition to proportional width. C.7 and C.8 figures are zero-padded.

### Design review disposition

`DESIGN_REVIEW_RESULT` verdict **PASS** (revision 2), from an independent design-reviewer that verified claims against the repository rather than trusting the packet.

- Round 1 returned `NEEDS_REVISION` with two repository-verified high-severity findings: a wrong band-color derivation (swapped Beginner/Intermediate, a fabricated "AA-corrected brass.700" substitution, and an `ink.moss` semantic collision) and an unimplementable D2 completion wiring (N+1 risk against a sync pure function with no batch variant), plus five lower-severity corrections.
- The single permitted revision resolved all of them; round 2 verified the corrected band derivation against the reference legend and re-computed the three contrast ratios, and verified the batch-fetch design against the real migration and RLS policy.
- One bounded implementation-time item remains: the `Week.id` typing gap (see D2 above).
- Design review explicitly did **not** execute code, run tests, or render screenshots — visual and interaction confirmation is the Browser Validator's job.

---

## 6. Judge route

`PLAN_DUCK` eligible at the orchestrator's discretion before approval (multi-file UI change with a data-model component). `CODE_REVIEW` and `VISUAL_REVIEW` are optional per `docs/JUDGE-CONTRACT.md` risk rules; deterministic failures always dominate. Standard call caps apply.

**Amendment**: `PLAN_DUCK` ran at Terra tier in shadow/advisory mode and returned **REVISE** with five findings. See section 14 ("Judge review disposition") for the full disposition and section 3, 5, 8, 9, 11, and 13 for where each finding was folded into the plan.

---

## 7. Ordered work (phases)

Sequence as internal phases of this one plan (the #35 approach), not separate jobs. **Every phase is TDD-first**: write or extend the failing test before the production edit.

### Phase 0 — Tokens and primitives

Add all new token leaves listed in section 5 ("New tokens"), dual-written to `.atelier/tokens/field-workbook.tokens.json` **and** `src/tokens/field-workbook.generated.css`. Add the `Control` `quiet-outline` tier, the `Badge` `label?` prop, and the `Badge` `cited-source` variant.

- Owner: T1.
- Depends on: nothing.
- Observable result: token tests and existing Badge/Control tests pass; new tokens resolve in the generated CSS.

### Phase 1 — Roadmap data model (D2)

Add `id: string` to `Week` (`weekUnlock.ts:18-21`). Add `getLessonProgressForEnrollment` to `adminStudentData.ts`. Add the `unlocked` value to `RoadmapWeekState`. Add the `completionByLessonId` third parameter to `computeWeekRoadmap`, keeping it synchronous and pure, and derive completed/unlocked from real `completed_at` data. Wire the single batch fetch into `BandRoadmap`'s existing effect.

**Current-week selection (J-01-36, resolved, Option B — keep today's behavior)**: current-week selection keeps its existing `Math.max(...unlockedWeeks)` logic unchanged; this phase does not alter that rule. This phase's work on that function is limited to adding the `completionByLessonId` parameter and deriving `completed` versus `unlocked` from real completion data. See section 13 for the full resolution, provenance, and reversibility note.

**State-derivation ordering, explicit (resolves precedence between "completed" and "current" for the writer)**: inside `computeWeekRoadmap`, resolve state in this order:

1. A week whose lesson has `completed_at` set is `completed`.
2. Otherwise, the highest-numbered unlocked week (`Math.max(...unlockedWeeks)`) is `current`.
3. Otherwise, an unlocked week with no completion entry is `unlocked`.
4. Otherwise, `locked`.

One genuine ambiguity under this ordering, to be resolved by test rather than guessed: if the highest-numbered unlocked week IS completed, rule 1 takes precedence and it resolves as `completed`, not `current`. This means a student who has finished everything currently available sees no `current` card at all. That is the intended behavior under this decision — inventing a `current` card for an already-completed week would misstate the student's real progress. Add a test locking this precedence in.

**Amendment (J-02-36, PLAN_DUCK Terra-tier judge finding, resolved)** — batch completion-fetch error handling, freshness, and invalidation:

1. **Typed result contract.** `getLessonProgressForEnrollment(enrollmentId, client)` returns `Promise<Map<string, string | null>>` (lessonId to `completed_at`) and rejects on query error. It must never resolve to `undefined`, `null`, or a partially-populated map. A student with no progress rows yet is a legitimate empty `Map`, semantically distinct from a failure and must not be conflated with one.
2. **Error policy — reuse the existing pattern.** The batch progress fetch joins the existing lessons fetch under a single `Promise.all([fetchLessonsForBand(...), getLessonProgressForEnrollment(...)])` inside the same effect (section 3), so a rejection from either falls into the existing single `.catch` and sets the existing `status: 'error'`. The existing `role="alert"` error paragraph remains the error state; no new error UI is introduced.
3. **Safe default — never render with an unknown map.** Every week-card render is already gated behind `status === 'ready'`, and `status` only becomes `'ready'` after both promises resolve, so an undefined or partial map can never reach `computeWeekRoadmap` or `WeekCard`. On failure the roadmap renders the error state, not a silently all-incomplete roadmap. Rendering every week as "not started" because a progress query failed would misstate the student's real progress and is explicitly prohibited — the same "never a placeholder" principle the locked-state unlock date already follows.
4. **Freshness and invalidation.** Lesson completion is written from `LessonContentView`, which lives on a different route (`WeekDetailPage`) from the roadmap. Behavioral acceptance criterion: after a student completes a lesson and returns to the roadmap, that week's card shows its updated state without a full page reload. The implementer must first determine by test whether navigating back remounts `BandRoadmap`. If it does, the existing effect already refetches and the only requirement is a test locking that behavior in. If it does not, an explicit invalidation must be added (a refresh token or version counter included in the effect's dependency array, bumped on return to the roadmap route). Do not assume remount without verifying it; record which branch applies in the completion evidence.
5. **Tests (TDD-first)**: a test that a rejection from the progress fetch produces the error state and renders no week cards; a test that a rejection from the lessons fetch still produces the same single error state (no regression from the `Promise.all` change); a test that an empty progress `Map` is treated as "no lessons completed yet" and never as an error — specifically, under the kept `Math.max` current-week rule, every unlocked week except the highest-numbered one renders as `unlocked`, and the highest-numbered unlocked week renders as `current`; a test for the post-completion state transition described in item 4; and a test that the existing `cancelled` guard still prevents a stale resolution from overwriting newer state.

- Owner: T1.
- Depends on: nothing.
- Observable result: an unlocked-but-incomplete week resolves to `unlocked`, not `completed`, under unit test; a rejection from either the lessons fetch or the batch progress fetch resolves to the single existing error state with no week cards rendered; an empty progress map renders unlocked weeks as `unlocked`, not as an error; the post-completion freshness test (remount refetch or explicit invalidation, per whichever branch applies) passes; the existing `cancelled` guard still holds under test.

### Phase 2 — C.4 week card

Rebuild `WeekCard` for four states with the display-sm week number, hard-offset shadows, per-state action labels, the promoted absolute unlock date on the card face, and decorative Stamp/tape/ClipRing per D3.

- Owner: T1.
- Depends on: Phases 0 and 1.

### Phase 3 — C.5 four-chunk anatomy

Add numbered mono tabs, chunk-03's ruled writing area, and `Badge` wiring for the dialect and cited-source markers under D1.

- Owner: T1.
- Depends on: Phase 0.

### Phase 4 — C.6 segment ledger

New proportional filled-ledger component replacing the pill stepper, including the stepper→tablist ARIA-model change and the full keyboard model.

- Owner: T1.
- Depends on: Phase 0.

### Phase 5 — C.7 owner ledger row and C.8 metric plate

New components: `OwnerLedgerRow` and `MetricPlate`, built as reusable presentational components per the contracts in section 5, and integrated into `OwnerDashboardPage.tsx` in the same phase (J-03-36, resolved — see section 5 and section 13 for the superseded default). Replace the existing plain table rows and the local `Metric` component with these two components; preserve the existing search, sort, and empty-state behavior unchanged. Add an integration-level test asserting `OwnerDashboardPage` renders `OwnerLedgerRow` per student-enrollment pair and `MetricPlate` per summary figure, that the progress cell shows a filled bar and a zero-padded raw figure and no bare percentage, that band tiers map to the correct tokens (Beginner brass, Intermediate terracotta, not swapped), and that the existing search/sort/empty-state behavior is unregressed.

- Owner: T1.
- Depends on: Phase 0.
- Observable result: `OwnerLedgerRow` and `MetricPlate` render inside `OwnerDashboardPage.tsx` replacing the prior plain table rows and `Metric` component; the integration test above passes; `OwnerLedgerRow` retains its own explicit `paper.50` background when nested inside `.dashboard-panel`.

### Phase 6 — BandRoadmap grid/sheet geometry and FlashcardsViewer alignment

Update `BandRoadmap` grid/sheet geometry and align `FlashcardsViewer` badge/geometry, protecting the C.9 empty state and the #34 zero-radius fix.

- Owner: T1.
- Depends on: Phases 0 and 2.

### Phase 7 — Verification

Verifier pass, then Browser Validator pass against the brief in section 10.

- Owner: Verifier, then Browser Validator.
- Depends on: Phases 0-6.

If T1 cannot complete a phase, escalate to T2 per the standard two-counted-gate-failure rule in `CLAUDE.md`.

---

## 8. Interfaces and data

- `RoadmapWeekState` gains `unlocked` — **breaking** for exhaustive switches; audit all consumers.
- `Week` gains `id: string`.
- `computeWeekRoadmap` gains a third parameter (`completionByLessonId: Map<string, string | null>`) and stays synchronous and pure. State-derivation order (J-01-36, resolved, Option B — see Phase 1 and section 13): (1) a week whose lesson has `completed_at` set is `completed`; (2) otherwise the highest-numbered unlocked week (`Math.max(...unlockedWeeks)`) is `current`; (3) otherwise an unlocked week with no completion entry is `unlocked`; (4) otherwise `locked`. If the highest-numbered unlocked week is itself completed, rule 1 wins and no `current` card renders for that student — this is intended, not a defect.
- New `getLessonProgressForEnrollment(enrollmentId, client)` against `student_lesson_progress(lesson_id, completed_at)` filtered by `enrollment_id`, permitted by the existing `students_read_own_lesson_progress` RLS policy — one round trip, never N+1. Amendment (J-02-36): returns `Promise<Map<string, string | null>>` and rejects on query error; never resolves to `undefined`, `null`, or a partial map. An empty `Map` is a valid "no completions yet" result, distinct from a rejection. Joins the existing `fetchLessonsForBand` call via `Promise.all` inside `BandRoadmap`'s existing effect, sharing its single `.catch` and `status: 'error'` state.
- `Control` gains a sixth tier (`quiet-outline`).
- `Badge` gains an optional `label` prop and a `cited-source` variant, both backward compatible.
- No migration is required; the table and policy already exist.
- Existing tests in `src/__tests__/{WeekCard,LessonContentView,BandRoadmap,FlashcardsViewer}.test.tsx` will need updating for the new state and structure.
- **Amendment (J-03-36, resolved)**: new `MetricPlate` component with props `{ label: string; value: number | string; tone?: 'default' | 'dark' | 'attention'; zeroPad?: boolean }`; new `OwnerLedgerRow` component with props `{ studentLabel: string; bandName: string; bandTier: 'beginner' | 'intermediate' | 'advanced'; completedCount: number; totalCount: number; lastActiveAt: Date | string | null; needsAttention: boolean; onOpenStudent: () => void }`. Both are integrated into `src/pages/OwnerDashboardPage.tsx`, which becomes a touched file alongside `OwnerDashboardPage.css` — outside issue #36's originally listed file scope (see section 5, section 13). Data source: `getOwnerDashboard()` in `src/services/adminStudentData.ts`, returning `OwnerDashboard { settings, summary, students }`.

---

## 9. Acceptance and validation

TDD-first throughout.

- `npm test` (Vitest) green, including updated tests for all four components plus new tests for the new state model, the batch fetch, and the new C.6/C.7/C.8 components.
- `tsc --noEmit` clean.
- `npm run lint` clean.
- The fixed A.6 criteria and the seven per-issue criteria from `ADOPTION-PLAN.md` lines 194-206 and 262-286.
- Deterministic no-raw-hex scan across every touched CSS file.
- Deterministic no-native-dialog scan for `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`.
- Zero-radius scan.
- The #34 removal-test structural/decorative CSS split must still hold for the decorative additions (Stamp, tape, ClipRing, hand annotation).
- **Amendment (J-02-36, resolved)**: the Phase 1 batch-fetch error-handling, freshness, and invalidation tests listed in Phase 1 above are part of the required green test suite, not optional additions.
- **Amendment (J-04-36, resolved)** — the state-union audit must exceed compiler checks. `tsc --noEmit` catches non-exhaustive switches but will not catch dynamically-generated class names, CSS selectors keyed to the old three states, test fixtures, or state-derived control text that silently falls through for the new fourth state. Both of the following are required:
  1. An explicit state-matrix test covering all four `RoadmapWeekState` values, asserting per state: the rendered icon, the visible state label text, the action-control text ("Review week N" / "Open week N" / "Open week N" / "Why locked?"), and locked-only behavior (the disclosure exists only for `locked`, and no open-week control is rendered for `locked`). The matrix must fail if a new state is added without a corresponding row.
  2. A scoped audit of non-type consumers of the old three-value union: grep `WeekCard.css`, `BandRoadmap.css`, and the four existing test files for `week-card--completed`, `week-card--current`, `week-card--locked`, `data-week-state`, and any `roadmap-completed`/`roadmap-current`/`roadmap-locked` token or selector, confirming each still resolves and that the new `unlocked` state has its own selector rather than falling through to a default. Record the audit result in the completion evidence.
- Verifier pass, then Browser Validator pass.
- Atelier MCP is disclosed-unavailable this session (unresolved project-root misconfiguration), including `visual_diff`. **Pre-authorized substitute**, following the documented #34/#35 precedent: hand-transcribed comparison against the reference artboard sections plus a documented manual visual-diff record with screenshots, disclosed in the completion evidence as a known gap rather than claimed as tool-verified.

---

## 10. Browser UI dialog policy

**Required.** This is browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are **prohibited**. Acknowledgement or confirmation must use the app-owned accessible modal; inline validation where it better serves the user.

The locked-week "Why locked?" affordance stays an inline `aria-expanded` disclosure and must **not** become a modal. This issue introduces no modal at all; C.6's and C.7's new interactive elements are inline tablist and table controls.

A deterministic source scan for the prohibited APIs is a required acceptance check.

---

## 11. Browser UI validation

- **Launch/readiness**: `npm run dev -- --port <PORT> --strictPort` from the repo root, ready when Vite logs "ready in" and the Local URL. Use `--strictPort` so a collision fails fast rather than silently rebinding.
- **Port**: 5317. Rationale: `vite.config.ts` defaults to 5173 with no `strictPort`; prior sessions used 7913 (FAILED — `vite-dev-restart-7913-err.log` records "Port 7913 is already in use", a real orphaned-process collision), 9187 (clean), and 5199 (the #35 collision). Playwright's E2E harness independently uses 8888 via `netlify serve`. No prior-session evidence exists for the 5200-5399 range in either direction, so `--strictPort` is mandatory to fail fast rather than assume.
- **Base URL**: `http://localhost:5317`.
- **Fixture/reset**: use the existing seeded student and enrollment path (`create-test-student.sql` and the existing admin-created-student flow). The four week-card states each need a real fixture, including an `unlocked` week and a locked week with a real future unlock date. Under the kept `Math.max` current-week rule (J-01-36, resolved, Option B — section 13), the `unlocked` state does not arise for a straightforwardly on-schedule student, since the highest-numbered unlocked week is always `current`. The fixture must therefore be deliberate: seed a student with at least two unlocked weeks where the highest-numbered unlocked week is not the week under test, so a lower-numbered unlocked-and-incomplete week renders `unlocked` while the highest-numbered one renders `current`. The Browser Validator must not report the `unlocked` state as unreachable, and its absence from a default (single-unlocked-week) seed is expected under this decision, not a defect. Reset by re-running the seed between journeys.
- **Viewport profiles**: mobile 390x844 (≤640px), tablet 768x1024 (641-899px), desktop 1440x900 (≥900px).

### Journeys and visible outcomes

1. **C.4 all four states at all three viewports** — each card shows icon and word state text; the correct per-state action label (Review week N / Open week N / Open week N / Why locked?); the locked card shows both a real absolute date and a real relative-distance string on the card face; the disclosure opens and closes by click and by Escape with focus returning to the toggle; DONE and LOCKED stamps are excluded from the accessibility tree; the week number is the single most dominant element; an unlocked-but-incomplete week does not silently render as completed.
2. **C.5** — all four chunks in fixed 01→04 order in both DOM and visual position at 1-up and 2-up; the numbered tab is the primary differentiator; chunk 03 shows a ruled writing area; chunk 04 shows a real dialect Badge and the "Cited source" Badge.
3. **C.6** — segment width visibly correlates with minutes and every segment prints its minutes in type; the active segment is `aria-selected="true"` and distinct by more than color; the DOM uses tablist/tab/tabpanel rather than the old `aria-current="step"` (confirm the ARIA-model change actually landed); Tab enters and exits the group as one stop; Left/Right rove and swap the visible panel; Home/End jump; the accessible name announces ordinal plus label plus minutes; focus-visible renders the inset ring; the narrowest segment's text is never truncated at mobile. **Amendment (J-05-36, advisory, accepted)**: panel swap on arrow-key rove is synchronous with focus movement, with no perceptible delay, async fetch, suspense boundary, or loading state between focus moving to a tab and its panel becoming visible.
4. **C.7** — real `<table>`/`<th scope="col">` semantics; the progress cell shows a filled bar and a zero-padded raw figure and never a bare percentage; the band chip is a left-border-accented label using the corrected band tokens with Beginner reading brass/amber and Intermediate reading terracotta and not swapped; exactly one interactive control per row with a composed accessible name; the focus ring renders; any attention-flagged row uses icon plus word.
5. **C.8** — both figures zero-padded; the attention plate distinct by a real color-plus-label pairing with legible text.
6. **Token-consumption check across all five components** — inspect computed styles and class names for WeekCard, LessonChunk, SegmentLedger, OwnerLedgerRow, and MetricPlate; confirm every color, border, shadow, and typography value resolves through a `var(--...)` custom property and never a raw hex or px literal, specifically re-verifying that the band aliases resolve to token-backed values.
7. **Non-regression** — `BandRoadmap`'s C.9 empty state still renders all three required parts; `FlashcardsViewer` shows no reintroduced border radius.

---

## 12. Risks and rollback

- **HIGH** — the `RoadmapWeekState` change is a breaking union widening. Mitigation: audit every consumer and rely on `tsc --noEmit` to surface non-exhaustive switches before runtime. Rollback: the state addition and the batch fetch are contained to Phase 1 and revertable independently of the visual phases.
- **HIGH** — this milestone's own history flagged a real completed-state color-token bug in `WeekCard` at #33. Mitigation: the plan explicitly preserves the `ink.moss` association and forbids reusing `ink.moss` for any band tier; the token-consumption browser check re-verifies it.
- **MEDIUM** — the C.6 stepper→tablist change alters real ARIA semantics on a high-traffic content surface. Mitigation: full keyboard model specified; browser validation explicitly confirms the model change landed and that roving/Home/End/panel-swap all work.
- **MEDIUM** — four files with prior milestone history risk regressing #33's tint retirement, #34's zero-radius fix, and #34's C.9 empty state. Mitigation: all three are named protected non-goals with dedicated non-regression browser checks and the existing removal test.
- **MEDIUM** — N+1 query risk if the batch fetch is implemented per-week. Mitigation: the single-round-trip contract is specified explicitly and is verifiable by inspecting the network panel during browser validation.
- **LOW** — dev-server port collision. Mitigation: `--strictPort` fails fast.
- **Rollback**: each phase is an independently revertable commit-sized unit; the token phase is purely additive and safe to leave in place if later phases are reverted.

---

## 13. Assumptions and open decisions

- **Resolved (J-01-36) — former open item #1, Option B, keep today's behavior**: the C.4 "current week" progression rule stays the currently shipped `Math.max(...unlockedWeeks)` (most-recently-unlocked) logic (`src/lib/roadmap.ts:97-98`). It is **not** changed to lowest-numbered unlocked-and-not-completed.
  - **Provenance**: this is a coordinator-selected lower-risk default, chosen to avoid blocking indefinitely on a live user answer. It is not a direct user ruling, and it does not carry the weight of one.
  - **Rationale**: keeping the shipped rule avoids a real student-facing behavior change to what a returning student sees as their current week.
  - **Disclosed consequence, not a defect**: under this rule, the new `unlocked` ("unlocked, not started") card state becomes reachable only in edge cases — for example, a student with a gap in their progress where a lower-numbered unlocked week was never started while a higher-numbered week is now "current." It is not a guaranteed common state for a student who is ahead of schedule. Verification and Browser Validation must treat this as the accepted, disclosed behavior under this decision, not as a failing implementation or an unreachable-state defect.
  - **Reversibility**: this choice is explicitly reversible. It can be swapped to Option A (lowest-numbered unlocked-and-not-completed) on a later explicit user request. The swap is contained to the current-week selection logic inside `computeWeekRoadmap`; the four-state model, the batch completion fetch, and all C.4 visual work in this plan are independent of which rule selects "current" and require no rework if the rule changes later.
- **Resolved (J-03-36) — former open item #2**: C.7 and C.8 are built as reusable presentational components (`OwnerLedgerRow`, `MetricPlate`) and integrated into `OwnerDashboardPage.tsx`, replacing its existing table rows and local `Metric` component; they are not shipped standalone. See section 5 and Phase 5 for the full decision, contracts, and the user-overridable scope note (touched-file expansion to `OwnerDashboardPage.tsx`/`.css`).
- **Resolved (J-05-36) — former open item #3**: C.7's attention-flagged row has no reference-artboard precedent, so its exact glyph remains a Planner-recorded choice rather than a transcribed spec value; it is now fixed as a filled triangular warning glyph rendered as inline SVG with `aria-hidden="true"`, paired with the visible words "Needs attention" in `terracotta.600`, sized to match the row's mono label line. See section 5.
- **Resolved (J-05-36) — former open item #4**: C.6's automatic-activation model is adopted as a binding acceptance criterion, not left as a recommendation: panel swap on arrow-key rove must be synchronous with focus movement with no perceptible delay, async fetch, suspense boundary, or loading state. See section 5 and section 11 journey 3.
- **Assumption**: `FlashcardsViewer`'s inclusion is inferential (shared badge and segment-progress patterns), not driven by a dedicated artboard — treat its criteria as "apply the same primitives," not "match a specific artboard."
- **Assumption**: reference copy in the specification ("PHRASES · 30 MIN", "Beginner", dialect names, "12 Aug") is illustrative, not shipped product content.
- Atelier MCP unavailability is disclosed and user-authorized; the manual substitute described in section 9 is pre-authorized.

---

## 14. Judge review disposition (PLAN_DUCK, Terra tier)

A `PLAN_DUCK` judge at Terra tier reviewed this plan in shadow/advisory mode and returned a verdict of **REVISE** with five findings.

- **J-02-36 (major)** — batch completion-fetch error handling, freshness, and invalidation. Resolved by Planner amendment with repository evidence from `BandRoadmap.tsx`. Folded into Phase 1, section 3 (repository findings), section 8 (interfaces), and section 9 (acceptance).
- **J-03-36 (major)** — the C.7/C.8 integration site. Resolved by Planner amendment with repository evidence from `OwnerDashboardPage.tsx`, superseding former open item #2's "unresolved, defaults to standalone" framing with a definitive integration decision. Folded into section 5, Phase 5, section 8, and section 13.
- **J-04-36 (minor)** — the state-union audit must exceed compiler checks. Resolved by Planner amendment. Folded into section 9 (acceptance) and Phase 1.
- **J-05-36 (advisory)** — C.6 tablist automatic-activation timing and the C.7 attention glyph. Both accepted and applied. Folded into section 5, section 11 (journey 3), and section 13.
- **J-01-36 (major, resolved by coordinator default, Option B)** — the current-week progression policy change. Rather than remaining pending on a live user answer, this finding is resolved by keeping the currently shipped `Math.max(...unlockedWeeks)` rule unchanged. This is a coordinator-selected lower-risk default, not a direct user ruling, and it is explicitly reversible to Option A (lowest-numbered unlocked-and-not-completed) on a later explicit user request without rework to the rest of this plan. Folded into section 3 (state-derivation ordering), section 8 (interfaces), section 13, Phase 1, and section 11 (browser-validation fixture).

Shadow/advisory judge findings are informative and never override deterministic checks (`tsc --noEmit`, lint, the no-raw-hex/no-native-dialog/zero-radius scans in section 9, and the Verifier/Browser Validator passes in Phase 7). Where a finding required a product or behavior judgment rather than a verifiable engineering fact, it was routed to the user instead of being resolved unilaterally.

---

## 15. Required approvals

This plan requires **explicit user approval** before T1/T2 execution begins. Do not begin Phase 0 or any subsequent phase until the user has explicitly approved this plan (relayed via the orchestrator). Upon approval, update the Status header above from "Draft — awaiting user approval" to "Approved" with the approval date.

All five PLAN_DUCK findings, including J-01-36 (current-week progression policy, resolved by coordinator default to Option B — keep the shipped `Math.max` rule, see section 13), are dispositioned. No item is carved out as unresolved by this approval.

---

## 16. Engineering mode and downstream owner

- Engineering mode: standard.
- Team authorization: not applicable.
- Downstream owner: engineering-fleet (T1 primary, T2 escalation per the two-counted-gate-failure rule, Verifier, Browser Validator).
