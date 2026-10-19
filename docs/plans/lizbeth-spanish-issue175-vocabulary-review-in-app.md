# Lizbeth Spanish: Issue #175 Vocabulary Review Renders In-App and Works in Every Lesson and Class

Status: APPROVED by the user on 2026-10-04. Cleared for engineering per this plan.

Revision 1: PLAN_DUCK remediation. PLAN_DUCK (Codex, shadow/advisory, high risk) returned REVISE with three findings, J-175-PLAN-001 to J-175-PLAN-003. Planner verified and accepted all three. This revision was applied once, in place. It adds bounded reads (Sections 6, 8), the owner preview surface inside #175 with the design addendum in Section 4.12 (reviewed PASS by design-reviewer, fold-ins F-A1 to F-A4 applied), parser limits and resilience CSS, stated defaults in place of D1 to D7 (Section 13), an updated ordered work list, and updated stale-plan conditions and risks. Dispositions are in Section 5.

Plan ID: `lizbeth-spanish-issue175-vocabulary-review-in-app`. Task ID: `lizbeth-spanish-issue175-vocabulary-review-in-app`. Route: engineering. Engineering mode: standard.

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (GitHub `lebobo88/lizbeth-spanish`; issue #175 "Vocabulary review: render in-app and work in every lesson and class"; epic #172). Implementation must start from a fresh worktree and branch off current `origin/main` (local packed-refs show `origin/main` at `233efa8`). The primary checkout is on `release/fjds-course-management-20260915` and is NOT the base.

Evidence base: planning evidence was read from the worktree `H:\CommandCenter\orchestrator\lizbeth_spanish-178` (branch `issue-178-self-paced-practice`, which contains the #173 and #176 work), the closest local copy of `origin/main`. T1 must re-verify every cited path and line number on the fresh base before editing.

Audience: students (all three bands x 26 weeks = 78 documents), the owner (preview), and the engineering fleet (implementer).

Evidence labels: **Observed** means read directly in repository files. **Inference** means a conclusion drawn from observations. **Assumption** means taken as true until a step verifies it. **Unknown** means not established.

---

## 1. Outcome

Students open the weekly vocabulary review for any week of any band from the lesson's resources row and read it in-app: no PDF, no raw `.md` download, no new tab. This works on both student surfaces: the Roadmap week detail (desktop rail and mobile Files tab) and the `/learn` lesson detail (through #174's shared `ResourcesPanel`). The owner can open the same viewer as a preview.

## 2. Scope and non-goals

**In scope:**

1. A dependency-free, safe Markdown-subset renderer producing React elements.
2. An accessible full-viewport reading overlay (`VocabularyReviewViewer`) owned by the `vocabulary_review` row in the shared `ResourcesPanel`.
3. A row state machine (idle, loading, open, error with Retry) with a fresh fetch on every open.
4. A loader seam: a default student loader (signed URL plus fetch) and an owner loader that calls a new owner-only Edge action by resource id.
5. A new owner-only Edge action in `supabase/functions/course-authoring`.
6. Fix `src/lib/storageSigning.ts` `STORAGE_CONFIG.RESOURCE_EXTENSIONS` (`vocabulary_review` `.pdf` to `.md`, `flashcards` `.json` to `.yaml`) and make `generateStoragePath` either match real paths (`<band>/week-NN/weekly-review-recap.md` and so on) or be clearly marked or removed if unused. Update `storageSigning.test.ts` and `securityFindings.test.ts` accordingly. Update row copy for `vocabulary_review`.
7. Tests T1 to T5 (Section 8).
8. Roadmap integration now; `/learn` integration through #174's shared `ResourcesPanel`.
9. The owner preview surface, decided inside #175 (revision 1): the exported row mounted on the Course workspace Content tab (Section 4.12).
10. Bounded reads (256 KiB) on both the student and owner paths, and parser limits (J-175-PLAN-001 and J-175-PLAN-003).

**Non-goals:**

- Changing recap content: no stripping of "Answer" text and no hiding of "Grounding" or author notes (#180 owns answer removal).
- The flashcards path: presentation, `onFlashcardsReady`, `flashcardsTriggerRef`, and the `WeekDetailPage` flashcards sentinel stay byte-for-byte unchanged.
- PDF generation.
- Any new npm dependency.
- Widening storage RLS.
- Authored-course vocabulary review. Authored course versions have no `vocabulary_review` resource data (Observed in the brief; no such type in `course_assets` flows), so the row simply does not appear. Revisit only if authored data exists.
- Building #174 (handout links, `/learn` `ResourcesPanel`), #180, or #179. If #174 later ships a different owner surface, it reuses the same exported row with the owner loader (DD-9).
- Preserving legacy linkage in `save_outline` (follow-up issue, not created by this plan; see F-A1 in Section 4.12).
- Scroll-position memory.
- Owner "Preview" labeling beyond the new "Lesson resources" heading in Section 4.12.
- Localization of `ResourcesPanel` copy.

## 3. Repository findings

All items are **Observed** unless labeled otherwise. Line numbers are approximate and must be re-verified on the fresh base.

- **F1. `src/components/ResourcesPanel.tsx`.** `RESOURCE_LABEL` (~53-58) has `vocabulary_review` = "Weekly vocabulary review". `ResourceRowView` `handleFetch` (~84-128) calls `getSignedResourceUrl`, then for non-flashcards sets state `ready` with the url. The `ready` branch (~156-165) renders `<a target=_blank rel=noopener>` "Download Weekly vocabulary review". The action label is "Get a link for ...". The error branch has an inline Retry (`role=status`). The flashcards inline-versus-overlay presentation contract is at ~9-51 and ~167-193.
- **F2. `src/lib/storageSigning.ts`.** `getSignedResourceUrl` (~190-213) uses `createSignedUrl` through the student's anon-key session (RLS-gated). `STORAGE_CONFIG.RESOURCE_EXTENSIONS` (~226-231) declares flashcards `.json` and `vocabulary_review` `.pdf`; both are wrong against the real `.yaml` and `.md`. `generateStoragePath` (~243-251) is reference-only and produces non-real paths (for example `beginner/week-1/vocabulary_review.pdf`). It is referenced only by `storageSigning.ts`, `src/__tests__/storageSigning.test.ts`, `src/__tests__/securityFindings.test.ts`, and two legacy `.md` docs. The #173 plan flagged this for #174 and #175.
- **F3. Data.** `resources` rows come from `supabase/seeds/full-catalog.sql:98-127` (`vocabulary_review`, name "Week N Weekly Review", path `<band>/week-NN/weekly-review-recap.md`, excluding Beginner weeks 1-4), `supabase/seed.sql:301-324` (Beginner 1-4 local fixtures), and `scripts/provision-lessons.ts` (~520-570, `vocabulary_review` `weekly-review-recap.md` at ~554). Storage seed files: `supabase/storage-seed/lesson-assets/<band>/week-NN/weekly-review-recap.md`, 78 files (54-402 lines). #173 serves `.md` as `text/markdown; charset=utf-8` (`src/lib/storageContentType.ts`), but browsers may still download. The viewer must not depend on Content-Type.
- **F4. Content corpus (verified by Planner and the design reviewer).** Markdown subset only: exactly one `# ` title per file (all start "Weekly Vocabulary Review Recap"), `##` sections, `###` subsections in capstone weeks (for example intermediate and advanced week-26, advanced week-01), paragraphs, `**bold**`, `` `inline code` ``, ordered lists with hard-wrapped continuation lines, `-` bullets, and rare `*italic*` (1 file). No tables, links, images, fences, blockquotes, or HTML. "## Consolidated vocabulary, by theme" is present identically in all 78. "Answer" occurs 293 times across the 78 files (inline "(Answer: ...)" and "**Answer:** ..."). Files are likely CRLF (**Inference**). Files include author-facing notes (`curriculum-architecture.md` references, "Grounding" sections), which are rendered as authored.
- **F5. Surfaces.** `ResourcesPanel` is mounted only by `src/pages/WeekDetailPage.tsx`: the desktop rail (~1306-1319, `attachments(attachableResources)`, rendered only when `!isMobileViewport`) and the mobile Files tab inside `WeekSectionTabs` (~1226-1250, only when `isMobileViewport`). `src/lib/useWeekDetailMobileViewport.ts` (~44-51) flips live at 900px through `matchMedia`. `LearnDetailPage.tsx` and `LearnIndexPage.tsx` render no `ResourcesPanel`; #174 adds it. `/learn` data is `lesson_revision` based through `course-authoring` Edge actions (`src/services/learnData.ts`); mapping a `/learn` lesson to legacy `resources` rows is #174's responsibility.
- **F6. Existing patterns.** `FlashcardsViewer` and `FlashcardsOverlay` (fixed inset 0, z-index 40, `role=dialog aria-modal`, Close focused on open, no animation); `src/hooks/useFocusTrap.ts` (Escape, Tab trap, `inertBoundaryRef`, restore on cleanup); `src/components/Modal.tsx` (`inertBoundaryRef` usage); `WeekDetailPage` history sentinel (~390-460) and `useRoute.ts` popstate (~161-196); `App.css` `[tabindex]:focus` blanket rule (~206-240) and fixed-position override list (~271-275), protected by `src/__tests__/FixedOverlayFocusPosition.test.ts` (list-driven `PROTECTED` array); `Control.css` hover/active `:not(:disabled)` at (0,3,0) (~58-66); forced-colors disabled (~291-294); `src/main.tsx` wraps the app in `React.StrictMode` (~13-15). A native dialog policy test exists: `src/__tests__/nativeDialogPolicy.test.ts`.
- **F7. Storage RLS.** `students_read_unlocked_lesson_assets` (`supabase/migrations/202608070001_force_password_change_rls_enforcement.sql` ~87-113) allows SELECT only for objects referenced by `public.resources` for an active, unlocked enrollment. `owner_select_lesson_assets` (`202608300003_storage_lesson_assets_owner_write_policies.sql` ~154-161) is scoped through `owns_lesson_asset_path` to course-version-uuid first segments, so the owner cannot read legacy `<band>/week-NN` paths. Owner identity is `app_metadata.role === 'owner'` (`src/lib/ownerSettingsAuthorization.ts` `isOwnerUser`), checked server-side in Edge functions.
- **F8. Dependencies.** `package.json` has no Markdown library. `@tiptap/react` plus starter-kit are present (editor; no Markdown parser extension installed) and are not used for rendering: that would need a new `@tiptap/markdown` dependency and an editor instance for read-only text, so it is rejected. No `dangerouslySetInnerHTML` for this content.
- **F9. Test infrastructure.** vitest, `@testing-library/react`, jsdom; Playwright (`playwright.config.ts` `testDir ./src/__tests__/e2e`, baseURL from `E2E_BASE_URL` else `http://localhost:8888`; `webServer` skipped when `E2E_BASE_URL` is set); `@axe-core/playwright` available. `src/__tests__/storageObjectExistence.test.ts` checks recap files exist. Local seed accounts (`supabase/seed.sql`): `fullaccess@test.local` is enrolled active in all three bands with enrollment aged at least 175 days (all 26 weeks unlocked); `student1` to `student6`; `owner@test.local` (role owner); password `password`.
- **F10. Coordination.** Plans exist for #173, #176, #177, and #178 under `docs/plans/`. No #174 plan existed when this plan was drafted (it is being planned in parallel). The #176 plan states that #174 and #175 are shared components rendered on both surfaces. #178 rewrites practice-activity content, not recaps.

Research evidence: none. Planner judged local evidence sufficient (no external or current facts change the decision).

## 4. Reviewed design handoff (binding)

Design route: `DESIGN_ROUTE` profile **standard**. Reasons: new multi-state reading surface on two student surfaces plus owner; accessibility-critical long-form mixed-language reading. Agents: design-director (Sonnet), ux-architect, visual-system-designer, design-reviewer. Prototype: forbidden. Model tier: sonnet. Existing system mode: extend.

Design review: round 1 NEEDS_REVISION (F1 high: row-owned viewer remounts across the 900px breakpoint; F2 scroll-region focus ring off-screen; F3 StrictMode sentinel self-close; F4 aria-disabled specificity; F5 tautological lang test; F6 missing #174 completion gate). The Director revised once (revision 2). Round 2 verdict **PASS**: F1 to F6 resolved. Low notes: R2-1 (reword invariant 4 to "one optional loader prop, no required host props", applied below), R2-2 (DD-7 fallback effect declared after `useFocusTrap`, applied below), R2-3 (the owner Edge contract is a plan dependency, defined in Sections 6 and 7).

Revision 2 follows. It is binding on engineering.

### 4.1 Direction

Direction "Study sheet inside the Field Journal": one flat paper-200 full-viewport reading overlay shared across Roadmap, `/learn`, and owner preview. It extends the `.flashcards-overlay` frame and existing tokens; no new tokens, no motion, no card or ruled chrome. Rejected: inline rail expansion (rail is about 25rem), `Modal.tsx` as the frame (borrow only the `useFocusTrap` `inertBoundaryRef`), and a viewport-split presentation.

### 4.2 Design decisions

- **DD-1. Ownership.** The viewer is owned and rendered by the `vocabulary_review` row inside `ResourcesPanel.tsx`, as a sibling of the row button and status in the same `<li>`. There is no per-page overlay mount. Because `WeekDetailPage` swaps the rail and tabs `ResourcesPanel` at 900px, crossing the breakpoint while open unmounts the row. This is accepted per DD-7. Option (ii), a page-level provider, was rejected: per-host duplication, the trigger still differs, and the case is rare. Inertness comes from `useFocusTrap({inertBoundaryRef})` on the overlay root.
- **DD-2. Trigger.** One trigger button is mounted in every row state (idle, loading, open/closed, error), captured by a callback ref and passed as `triggerElement`. It carries `data-vocab-review-trigger="<resource.id>"`.
- **DD-3. Title.** The dialog title is an `<h2>`, the first element in the scroll region, with an id from `useId()`. Its text is the document's first `# ` line, with fallbacks `resource.name`, then "Weekly vocabulary review". Mapping: `##` to h3, `###` to h4, clamped at h6. The h1 is consumed and never rendered twice.
- **DD-4. History sentinel.** The sentinel is pushed once inside the viewer and is StrictMode-safe. The viewer is ALWAYS mounted in a `vocabulary_review` row with an `isOpen` boolean (it returns null when closed). The effect is keyed on `[isOpen]`. The push is idempotent through a `history.state` instance marker. Cleanup pops via `history.back()` exactly once, only if the current entry carries the marker and the close was not from popstate. Pop and push are serialized through a pending-pop flag (with a timeout fallback). Reproduce the `WeekDetailPage` ~390-460 behavior and its interaction with `useRoute` ~161-175. Do not touch the flashcards sentinel.
- **DD-5. Empty copy.** "This weekly vocabulary review has no content to show."
- **DD-6. Row button.** "Read weekly vocabulary review".
- **DD-7. Breakpoint crossing or row unmount while open or loading.** Close cleanly, discard state, abort the fetch, pop the sentinel exactly once, then move focus from the viewer's unmount cleanup: (1) the visible `[data-vocab-review-trigger="<id>"]` on the new surface (one that has client rects), else (2) the page `<h1>` with `tabindex=-1` set imperatively (or the main landmark if there is no h1). Run only if the viewer was open and its trigger is detached (a no-op under StrictMode simulated cleanup). The fallback effect MUST be declared after the `useFocusTrap` call, because inert must be removed first and inert blocks `focus()`. Within one side of 900px the viewer only reflows.
- **DD-8. Loader seam.** The viewer and the row state machine are loader-agnostic. `ResourcesPanel` gets ONE OPTIONAL loader prop (default student loader = `getSignedResourceUrl` plus `fetch().text()`); there are no required new host props, so Roadmap and student hosts need no change. The owner surface supplies an owner loader that calls the owner-only Edge action by resource id. The viewer receives only resolved text. An owner-loader failure shows the generic error, never the loader reason.

### 4.3 UX states and copy

- **Row states:** idle to loading to open or error; open to idle on close; error to loading on Retry.
- **Loading:** the same button has `aria-disabled="true"` (not `disabled`), and `onClick` returns early. Status text: "Opening weekly vocabulary review…".
- **Error:** the message sits above the button. The button reads "Retry" with `aria-label` "Retry reading weekly vocabulary review".
- **Messages:** a student signing failure shows the existing `getSignedResourceUrl` reason verbatim. A fetch non-ok, network, or abort failure, or an owner failure, shows "Could not load the weekly vocabulary review. Please try again." A missing storage path shows "This resource is not available."
- **Status region:** one persistent `<p role="status" aria-live="polite" class="resources-panel-status">` from first render (`:empty` margin 0).
- **Guards:** stale-response ignore; no setState after unmount (AbortController).
- **Viewer DOM:** root `role=dialog aria-modal=true aria-labelledby=<useId> tabIndex=-1 lang="en"`; a top bar with a plain `<button>` "Close"; a scroll region `role=region aria-label="Document content" tabIndex=0`; inside it the h2 title, then the body.
- **Focus and keys:** focus lands on Close on open. Tab order: Close, region, Close. Escape, Close, and popstate all call a single close callback. Focus returns to the trigger, with inert removed before refocus (the `Modal.tsx` order). The region scrolls to top on each open.
- **Responsive:** at 1440 a centred column with max `--measure` (65ch); at 390 edge-to-edge; at 320 (400% zoom) no horizontal scroll; honor `--text-size-multiplier`.
- **Exact copy (English literals, no site-text keys):** type label "Weekly vocabulary review"; "Read weekly vocabulary review"; "Opening weekly vocabulary review…"; "Could not load the weekly vocabulary review. Please try again."; "Retry"; "Close"; "Document content"; and the empty copy above. Remove for this type: "Get a link for…", "Download…", and the `<a target=_blank>`.

### 4.4 Renderer contract

Hand-written parser to React elements; no `dangerouslySetInnerHTML`, no HTML pass-through, no new package. Subset: h1 (title), h2/h3, paragraphs, `**bold**`, `` `code` ``, `*italic*`, `-` bullets, and ordered lists with wrapped continuation lines joined by a single space. Unknown constructs (tables, links, images, fences, raw HTML) render as literal plain text; link syntax stays text with no anchor. Normalize BOM, CRLF, and CR. Empty means zero non-empty blocks, which shows the empty state. Never strip or hide "Answer" text or Grounding, and never depend on them.

### 4.5 Language rule

Root `lang="en"`. The rule runs after hard-wrapped lines are joined.

- **Scope:** only paragraphs in the `##` section "Consolidated vocabulary, by theme". Paragraph shape `^\*\*(.+?):\*\*\s+(.+)$`. The label is untagged.
- **Guard:** remove parentheticals `\([^)]*\)` from the post-colon text. If the remainder contains any whole-word English marker (the, and, of, to, is, are, with, by, this, that, these, those, for, you, your, all, only, from, null, void, men, hereinafter, heretofore, aforesaid; case-insensitive), tag nothing in that paragraph. Otherwise the outside-parenthesis text goes in `<span lang="es">`.
- **Parentheticals:** each is tagged `es` if and only if it has Spanish evidence (`¿ ¡ á é í ó ú ü ñ`, or a whole word in {el, la, los, las, de, del, y, que, en, un, una, por, para, pero, muy, es, se}) AND no English marker. Adjacent `es` pieces merge.
- **Examples:** the beginner/week-01 greetings paragraph is tagged; intermediate/week-02 "(todos los días llegaba temprano, …)" and "(el imperfecto y el pretérito …)" are tagged; beginner/week-01 "(Muy)" is tagged; "(false cognate)", "(recognition only)", "(modern equivalent)" are unset; "(/ ¡Hola a todes!, recognition only)" is unset (known limit); the advanced/week-05 "Parallel English-side archaic legal register" paragraph is wholly untagged.
- **Known limits:** keyword heuristic; skipped paragraphs are under-tagged; nested parentheses are unhandled; Spanish in the self-test or prose is never tagged; plain "es".
- **Verification:** a checked-in golden `vocabReviewLangGolden.json` (per-file tagged paragraphs, guard-skipped paragraphs, tagged parentheticals, and unset parentheticals for all 78) diffed exactly; named fixture tests per example; a secondary marker-word invariant; and a REQUIRED release gate: a Spanish-literate spot-check (owner or Lizbeth) of at least 5 files including intermediate week-02, beginner week-01, and advanced week-05, recorded.

### 4.6 Visual system (existing tokens only)

- `.vocab-review-overlay`: `position: fixed; inset: 0; z-index: 40; background: var(--color-paper-200); display: flex; flex-direction: column; outline: none`.
- Top bar: padding `var(--space-3) var(--space-5)`, background `var(--color-surface-interactive-default)`, border-bottom `var(--border-width-rule) solid var(--color-ink-1000)`.
- Close: unboxed like `.flashcards-overlay-back-link`: `min-height: var(--hit-target-min, 44px)`, mono label, uppercase, letter-spacing `.12em`, label size times the multiplier, `label-strong` weight, ink-1000. `:focus` outline `var(--focus-ring-width,3px) solid var(--color-focus, var(--color-ink-slate))` with offset `var(--focus-ring-offset,2px)`. Hover underline thin, active underline rule, no transition.
- Body region: `flex: 1; min-height: 0; overflow-y: auto`. Inset focus ring: `.vocab-review-overlay .vocab-review-overlay-body:focus { outline: var(--focus-ring-width,3px) solid var(--color-focus, var(--color-ink-slate)); outline-offset: calc(var(--focus-ring-width,3px) * -1); }` plus a forced-colors Highlight variant.
- Sheet: `max-width: var(--measure); margin: 0 auto; padding: var(--space-8) var(--space-10)`; at 640px and below `max-width: none; margin: 0; padding: var(--space-4) var(--space-5)`.
- Type: title h2 uses the global Fraunces 600 with `overflow-wrap: break-word`; h3 global; h4 `var(--typography-fontSize-lg)` times the multiplier. Body font-size `var(--font-size-body)` times the multiplier, line-height `max(var(--line-height-floor,1.5), var(--line-height,1.5))`.
- Lists: outside markers, margin `0 0 var(--space-4) var(--space-6)`; `li` margin `0 0 var(--space-3) 0`. `strong` 600.
- Code: paper-50 background, hairline ink-700 border, radius-square, padding `.2em .4em`, `.9em`, mono, ink-900, `overflow-wrap: anywhere`, forced-colors ButtonText/Canvas/CanvasText.
- `lang=es` spans: no CSS. "Answer": no special style (do not reuse `.lesson-content-quiz-answer`). `.vocab-review-empty`: ink-700, italic, `role=status`.
- Forced colors: Close ButtonText, focus Highlight. No animation.
- **Row delta, aria-disabled paint** (preferred placement scoped in `ResourcesPanel.css`; design-reviewer F4 notes that the `Control.css`/`Control.tsx` convention reserves the dashed look for native disabled): `.resources-panel-row .control.control[aria-disabled="true"]` plus `:hover` and `:active` forms, with background `var(--color-paper-200)`, color `var(--color-ink-700)`, border `var(--border-width-rule) dashed var(--color-ink-700)`, `box-shadow: none`, `transform: none`, `cursor: not-allowed`, and forced-colors dotted/GrayText. If placed in `Control.css` instead, update the convention comments.
- `.resources-panel-status:empty { margin: 0 }`.
- **Error line for this row:** color `var(--color-ink-900)`, border-left `var(--border-width-rule) solid var(--color-status-error-text)`, padding-left `var(--space-3)`, because `#a85e4a` on paper-200 is 4.05:1 and fails AA text (verified).
- **Measured contrast:** ink-900 on paper-200 12.89; ink-700 on paper-200 7.47; ink-1000 on paper-100 17.07; ink-900 on paper-50 14.92; focus `#3d5f6b` on paper-200 5.80.

### 4.7 Engineering invariants

1. No `<a href>`, `download`, or `target=_blank` for `vocabulary_review`.
2. The loader runs afresh per open; nothing is cached; flashcards reuse is untouched.
3. Hand-written parser, no dependency, no `dangerouslySetInnerHTML`, plain-text fallback, CRLF/BOM/empty handled.
4. Row-owned, loader-agnostic viewer; one optional loader prop, no required host props; flashcards contract unchanged.
5. Trigger mounted in all states, `aria-disabled` plus re-entry guard, focus restored on Close, Escape, and popstate, and DD-7 on unmount.
6. Inert via `inertBoundaryRef`, removed before refocus; no portal unless a clipping, stacking, or containing-block failure is observed (then check `docs/plans/lizbeth-spanish-fjds-e4-mobile-flashcards-full-screen.md` for the prior portal rejection reason first).
7. Add `.vocab-review-overlay` to the `App.css` ~271-275 fixed-position focus override list AND add a `PROTECTED` entry (name, selector, build function) in `FixedOverlayFocusPosition.test.ts`.
8. StrictMode-wrapped sentinel tests: +1 history entry per open; no orphan after Close, Escape, popstate, row unmount, or breakpoint crossing; no self-close under StrictMode; rapid close and reopen leaves exactly one sentinel.
9. Region `tabIndex` 0 with role and static name, scroll to top on open, Close first in DOM, `useId` title.
10. Inset ring and aria-disabled computed-style tests (no shadow or transform on hover or active).
11. No native dialogs or `beforeunload`; deterministic scan.
12. Answer, Grounding, and notes are rendered as authored.
13. Exact lang rule with golden, fixtures, and release gate.
14. `storageSigning` extensions hygiene.
15. The completion gate below.

### 4.8 Completion gate

#175 is NOT complete until journey 10 passes on the #174 `/learn` surface AND the owner surface (owner loader). Roadmap-only validation is a recorded partial result, never completion. Repeat the inert walk, stacking, sentinel (StrictMode plus browser history), and DD-7 fallback checks on those hosts.

Revision 1 amendment: journey 10 is now the #174 `/learn` surface plus the owner journeys J-owner-1 to J-owner-8 on the Course workspace Content tab (Section 4.12). The owner part no longer depends on #174; the `/learn` part still does.

### 4.9 Permitted variation

Class, file, and hook names; per-node classes; a portal only on observed failure; the aria-disabled rule location; parser internals that preserve the subset, fallback, and lang rule; top-bar padding tokens; h5/h6 inheriting h4; the loader prop name and shape.

### 4.10 Design review remaining limits

The accepted breakpoint-close limitation; the lang heuristic limits; the Spanish spot-check as a release gate; the portal-rejection reason in the fjds-e4 plan not verified; the focused-root z-index collapse 40 to 10 (harmless today, covered by the stacking check); `/learn` and owner behaviors unverified until #174; screen-reader verification of the overlay inside `aside/ul/li`; and the page-turn transform window covered by journey 11.

### 4.11 Design unresolved decisions

(1) Apply the error-contrast fix to all `.resources-panel-error` rows or only `vocabulary_review` (design requires at least this row). (2) Assign the Spanish-literate spot-check reviewer. (3) Scroll memory is no. (4) Owner Preview labeling belongs to #174. (5) Shared sentinel hook extraction is out of scope. (6) `RESOURCE_EXTENSIONS` hygiene (resolved in scope item 6). (7) The #180 answer move comes later. (8) Accepted limitation: breakpoint crossing (zoom or rotation) closes the viewer; option (ii) remains the owner's alternative.

### 4.12 Addendum (judge remediation): owner surface, resilience, limits

Reviewed PASS by design-reviewer, with required fold-ins F-A1 to F-A4 applied below. Where this addendum conflicts with DD-7, DD-8, or the earlier completion gate, this addendum governs.

**Decisions**

- **DD-9. Owner surface in #175.** The owner preview surface is delivered in #175. If #174 later ships a different owner surface, it reuses the same exported row with the owner loader.
- **DD-8 amendment.** Parsing runs in the ROW activation path through a pure exported parse function. A limit failure produces a row error and the viewer never opens; the viewer receives only the parsed result. The row is exported standalone (working name `VocabularyReviewRow`; props: display name, stable key, loader). `ResourcesPanel`'s `vocabulary_review` rows render through it. Any host wraps it in `<ul className="resources-panel">` (importing `ResourcesPanel.css`).
- **DD-7 amendments.** Fallback target 2 is the first `h1` inside `#app-main` that is not inside a `<header>` (mirrors the `App.tsx` ~285-298 route-focus logic, so the AdminShell masthead h1 "Owner desk" is excluded), else `#app-main`. `tabindex=-1` is set imperatively. Skip the fallback when `window.location.pathname` changed since open (App route focus owns it).

**Owner mount**

- Location: `src/pages/CourseWorkspacePage.tsx` `Content()`, inside `section.selected-lesson`, AFTER `<LessonEditor>`, for the selected block only, when the loaded block carries `legacy_lesson_id != null`.
- Data (Observed): `getCourse` in `src/services/courseAuthoring.ts` (~115) spreads the revision, so `block.id` equals `lesson_revision_id` and `legacy_lesson_id` is present at runtime. `get_version` selects it at `supabase/functions/course-authoring/index.ts` (~128). Widen the `AnyBlock` and `CourseBlock` types with `legacy_lesson_id?: string | null`.
- Markup: `<section className="lesson-resources" aria-labelledby={useId()}><h3>Lesson resources</h3><ul className="resources-panel" aria-label="Resources"><VocabularyReviewRow key={block.id} .../></ul></section>`.
- F-A2: NO `workspace-panel` class on any ancestor of the resources list (it restyles `ul` padding and grid, the empty status min-height of 1.5rem, and the overlay h2 word-break). Give `.lesson-resources` its own box styling from existing tokens, or put `workspace-panel` only on a wrapper holding the h3 that never contains the list.
- Row name: the selected lesson title in the Content tab's current language with the editor fallback chain `title[language] || title.es || title.en || "Untitled lesson"`. Heading "Lesson resources" is new copy. Other row copy is unchanged. `readOnly` never disables the row. Authored lessons (no legacy id) render neither heading nor row. The row is keyed by `block.id` only.
- Owner loader: calls `get_owner_resource_text {lesson_revision_id: block.id}`. Any failure shows the generic "Could not load the weekly vocabulary review. Please try again." with Retry; the reason is never shown.

**F-A1. Draft linkage (Observed).** `save_outline` (`supabase/migrations/202608300001_issue5_phase2_cadence_sql_core.sql` 429-449) deletes `course_version_lessons` and inserts NEW `lesson_revisions` without `legacy_lesson_id` on each draft save, and `saveDraft` (`CourseWorkspacePage.tsx` ~71-74) does not reload blocks. Therefore:

- The row shows whenever the loaded block carries `legacy_lesson_id`.
- Owner verification (J-owner-1 to J-owner-8) runs on the published legacy version (seeded `course_versions` `version_no=1` per band, `202608280003` ~575-582).
- After a draft save and reload, draft lessons have no row (known limit). In the same session after a save, the stale old revision id still works only because it remains mapped in the published version (known limit).
- Eligibility is strictly `lesson_revisions.legacy_lesson_id` non-null. There is no fallback to the owner-editable `content->>'legacy_lesson_id'`.
- Follow-up issue (out of scope, not created by this plan): preserve legacy linkage in `save_outline`.

**F-A3 (required).** Outline `duplicate()` (`CourseWorkspacePage.tsx` ~136) must set `legacy_lesson_id: null` on the clone. J-owner-7 asserts no row for an unsaved duplicate.

**Breakpoints and stacking**

- The 700px Content breakpoint is reflow only (mobile state only drives `assetPageSize`); the viewer stays open. AdminShell masthead breakpoint remount is unverified; J-owner-6 records it and DD-7 covers it.
- Stacking (verified in CSS): nothing in `AdminShell.css` or `CourseWorkspace.css` reaches z-index 40; the Aa button is 1; modals are 50, 998, and 999; the skip link is 100; the forced-password gate is 1000; there is no transformed ancestor. A portal variation (acceptable for the owner only with identical behavior and visuals) must target `document.body`; check the fjds-e4 plan's earlier portal rejection reason first.

**Invariants 16-22**

16. Owner mount as specified above.
17. Exported shared row and viewer with identical code; the owner supplies only the loader and display name; no owner branches.
18. Pure parse in row activation; limits produce a row error; list nesting depth greater than 1 renders as plain paragraphs (not an error).
19. Resilience CSS (below).
20. DD-7 amendments.
21. REQUIRED: `duplicate()` clears `legacy_lesson_id`.
22. Do not touch the pre-existing dangling `aria-labelledby="selected-lesson-heading"`.

**Limits and resilience (J-175-PLAN-003)**

- Limits: 256 KiB (loader level, before buffering), maximum 5,000 lines, maximum line length 10,000 characters, maximum 2,000 blocks, list nesting depth 1 (deeper or indented list markers render as plain-text paragraphs, not an error). Exceeding bytes, lines, line length, or blocks produces the existing generic error plus Retry, the viewer does not open, and there is no new copy. Rationale: the corpus is far below the caps; this is a defensive guard.
- Resilience CSS: `overflow-wrap: anywhere`; `min-width: 0` on `.vocab-review-overlay-top-bar`, `-body`, `.vocab-review-sheet`, `.vocab-review-body`, title h2, h3, h4, all paragraphs, `ol/ul/li`, `strong/em/code`, and lang spans (this supersedes `break-word`); `hyphens: manual` on `.vocab-review-body` and descendants (overrides global `p { hyphens: auto }`; rationale: partial lang tagging); NO `overflow-x: hidden`.

**Owner Edge action contract** (also in Section 6 step 6 and Section 7)

- Action `get_owner_resource_text`; payload `{lesson_revision_id}` (strict uuid). Also accept `{resource_id}` only if #174 needs it: exactly one of the two, both uuid-validated.
- Authorization: caller `app_metadata.role === 'owner'` (same server-side mechanism as other owner actions) AND the lesson revision is mapped through `course_version_lessons` into a `course_version` whose `courses.owner_id` equals the caller (mirrors the `owns_lesson_asset_path` and `ownedVersion` rule).
- Resolution: `lesson_revisions.legacy_lesson_id` to the `public.resources` row with `resource_type='vocabulary_review'`, `storage_bucket='lesson-assets'`, and `storage_path` ending `.md`.
- Preflight size plus bounded read (Section 6 step 6); return `{data:{text}}`; one generic error body for every failure (no path or existence echo); a malformed id yields a 4xx, not a 500.

**Owner journeys J-owner-1 to J-owner-8** (at 390 and 1440; `owner@test.local`, Course workspace of a legacy band course, Content tab):

1. Open and close via Close, Escape, and back; focus restored; no orphan history.
2. The published version row is present and enabled (a draft only if freshly cloned and unsaved or unreloaded).
3. An authored lesson shows no heading and no row.
4. Owner action failure shows the generic inline error plus Retry, no native dialog, and the reason is not shown.
5. Crossing 700px keeps the viewer open.
6. AdminShell masthead breakpoint crossing is recorded (stays open, or DD-7 clean close with focus on the `#app-main` non-header h1).
7. An unsaved duplicate shows no row.
8. Rewritten per F-A1: on the published version the viewer stays open across `refresh()` with stable ids; for a draft after save and reload the row is absent, and if blocks change while open, DD-7 closes the viewer with fallback focus and no errors.

Owner host checks: stacking including the sticky navigator and the Aa button; inert (Tab never leaves the overlay); named bleed computed-style assertions (resources list padding and display, empty status min-height, overlay h2 word-break) matching the student host; inset ring; StrictMode and sentinel.

**Owner fixture and validation inputs:** `owner@test.local` / `password`; route to the Course workspace Content tab for a legacy band course (T1 fills the exact path from App routing `matchCourseWorkspaceRoute`); a seeded authored lesson if available, else create one in a draft during the test and reset afterward with `db reset`.

## 5. Judge route

Governed by `docs/JUDGE-CONTRACT.md`. Policy is currently shadow; findings are advisory unless blocking is enabled. No judge result is included or promised in this draft.

- **Risk:** high (a new owner Edge action crossing the service-role trust boundary; an untrusted-text renderer XSS surface; accessibility-critical UI). Call cap: 4.
- **PLAN_DUCK:** required after this Scribe draft and before approval. Rubric: scope fidelity to issue #175 and user decisions; #174 dependency and ordering; owner Edge action least privilege; renderer XSS safety; test completeness T1-T5; stale-plan conditions.
- **CODE_REVIEW:** required after T1 `JOB_DONE` and before Verifier. Rubric: no `dangerouslySetInnerHTML` or HTML pass-through; Edge action authorization, `resource_type` and bucket allowlist, no raw path input, size cap, generic errors, no service-role leak to the client; flashcards path unchanged; sentinel StrictMode correctness; DD-7 order.
- **VERIFICATION_CHALLENGE:** conditional, only if coverage risk remains after Verifier PASS (for example T4 or T5 partially skipped).
- **VISUAL_REVIEW:** conditional, on accessibility-critical screenshots at 390 and 1440 against the design handoff. It counts toward the cap of 4.
- One checkpoint may repeat after remediation; extra calls need user approval.
- Finding IDs from any judge pass flow into the engineering job and into Verifier checks.
- Call count: PLAN_DUCK has consumed 1 call of the cap of 4 (verdict REVISE). A repeat PLAN_DUCK after revision 1 is optional and counts toward the cap.

### Judge findings and disposition

PLAN_DUCK (Codex, shadow/advisory, high risk) returned REVISE. Planner verified each finding. These are the only judge results recorded here.

| ID | Disposition | Summary | Where addressed |
| --- | --- | --- | --- |
| J-175-PLAN-001 | accepted | Bound reads before buffering on both the student and owner paths, with a concrete 256 KiB cap. | Section 4.12 (owner contract, limits), Section 6 steps 4 and 6, Section 8 (T1 size assertion, loader and Edge tests, T4 oversized fixture), Section 10 R2 |
| J-175-PLAN-002 | accepted | The owner preview surface is decided inside #175 (D5 removed as a user decision), with course-ownership authorization. | Section 4.12, Section 6 steps 6 and 7, Section 7, Section 8, Section 9, Section 10 R2, R11, R12, Section 11, Section 13 |
| J-175-PLAN-003 | accepted | Parser limits and resilience CSS for pathological content. | Section 4.12 (limits and resilience), Section 8 (unit and browser tests), Section 10 R11 |

**J-175-PLAN-001 detail.**

- Cap: 256 KiB (262,144 bytes) per document. Justification: the largest recap is about 402 lines at about 100-character wrap (Planner estimate of about 40 to 50 KB, **Inference**). T1 measures the exact byte size of all 78 files and records the maximum in the T1 matrix test. The test asserts the maximum is at most 64 KiB (at least 4x headroom). If the measured maximum exceeds 64 KiB, return `JOB_BLOCKED` "Plan stale" for a cap decision.
- Student loader: after `getSignedResourceUrl`, fetch with an `AbortController`. If `Content-Length` is present and above the cap, abort with the generic error. Otherwise read `response.body` through `getReader()`, accumulate bytes, and abort as soon as the total exceeds the cap (generic error). Decode with `TextDecoder('utf-8')`. A cap-triggered abort maps to the row error state, distinct from an unmount or stale abort, which sets no state.
- Owner Edge action: preflight the object size through service-role storage metadata (`info()` or object metadata size, as `provision-lessons` `verifyResourceByteSizes` uses `info()`) and refuse if above the cap before any download. Then read with a bounded stream (a service-role signed URL plus a streamed fetch with a byte cap, or equivalent) and re-check total at most the cap. Never buffer more than the cap plus one chunk. Generic error on exceed.

## 6. Ordered work

Owner: engineering-fleet, standard T1. Each step is test-first.

0. **Preconditions.** Create a fresh worktree and branch from current `origin/main`. Confirm #174 status. Recommended ordering: #174 merges first (it creates the shared `ResourcesPanel` on `/learn`, the owner resources surface, and possibly owner resource access); #175 rebases on it. Steps 1-8 (now including the owner surface in step 7) do not depend on #174 and may proceed in parallel; step 9 and the `/learn` part of step 10 require #174. If #174's merged `ResourcesPanel` or row API differs from F1, the plan is stale for steps 5 and 9 (re-verify; return `JOB_BLOCKED` "Plan stale" if material). Re-verify all cited line numbers on the fresh base.
1. **`storageSigning` hygiene.** Set `RESOURCE_EXTENSIONS` flashcards to `.yaml` and `vocabulary_review` to `.md`. Make `generateStoragePath` produce real paths (`<band>/week-NN/<band>-week-NN-student-handout.pdf`, `<band>-week-NN-instructor.pptx`, `flashcards.yaml`, `weekly-review-recap.md`) or, if T1 shows it is unused outside tests, keep it reference-only with corrected values. Update `storageSigning.test.ts` and `securityFindings.test.ts`. No change to `getSignedResourceUrl` behavior.
2. **Renderer.** A new pure module (for example `src/lib/recapMarkdown.ts`) with `parse(text)` returning a block AST, and a render component (for example `src/components/VocabularyReviewDocument.tsx`) mapping the AST to React elements (title extraction, heading demotion, lists with continuation joins, inline bold/code/italic, plain-text fallback). The lang rule is a separate pure function with exported marker and evidence sets. Test seam for #180: the parser and lang rule are pure and content-agnostic; no assertion depends on "Answer" presence or count; provide fixture variants with answers removed that must render without error and with identical structure minus answer text.
3. **Viewer.** `VocabularyReviewViewer`: always mounted, `isOpen`, `useFocusTrap` with `inertBoundaryRef`, Close focus on open, scroll region, DD-4 sentinel hook, DD-7 fallback effect declared after `useFocusTrap`, `useId` title. CSS per the visual spec. `App.css` override list update and the `FixedOverlayFocusPosition` `PROTECTED` entry.
4. **Loaders.** In `src/services` (for example `vocabularyReviewLoader.ts`): `studentVocabularyReviewLoader(client, resource)` = `getSignedResourceUrl` plus `fetch(url, {cache:'no-store'})` plus `text()` with an `AbortSignal`; `ownerVocabularyReviewLoader(block)` = `functions.invoke('course-authoring', {action:'get_owner_resource_text', payload:{lesson_revision_id: block.id}})`, mapping any failure to the generic error. Both loaders enforce the 256 KiB cap before buffering (J-175-PLAN-001): the student loader aborts on an oversized `Content-Length` or when streamed bytes exceed the cap, and a cap-triggered abort maps to the row error state while an unmount or stale abort sets no state. Parsing and the Section 4.12 limits run in the row activation path through a pure exported parse function.
5. **`ResourcesPanel` integration.** `vocabulary_review` rows use the new state machine and viewer; one optional loader prop (default student loader); `RESOURCE_LABEL` unchanged; remove the Download/link branch for this type; persistent status region; error-line styling; aria-disabled styling in `ResourcesPanel.css`. Flashcards, pdf, and pptx rows unchanged.
6. **Owner Edge action** (`supabase/functions/course-authoring`, owner-authorized branch, mirroring existing owner actions' auth check):
   - Action `get_owner_resource_text`; payload `{lesson_revision_id}` validated with a strict uuid regex. Also accept `{resource_id}` only if #174 needs it: exactly one of the two, both uuid-validated.
   - Authorization: caller `app_metadata.role === 'owner'` (the same server-side mechanism existing owner actions use) AND the lesson revision is mapped through `course_version_lessons` into a `course_version` whose `courses.owner_id` equals the caller (mirrors the `owns_lesson_asset_path` and `ownedVersion` rule).
   - Resolve `lesson_revisions.legacy_lesson_id` to the `public.resources` row; refuse unless `resource_type = 'vocabulary_review'` AND `storage_bucket = 'lesson-assets'` AND `storage_path` ends with `.md`. Authored revisions (no legacy id) are refused.
   - Preflight the object size through service-role storage metadata (`info()`) and refuse above 256 KiB before any download. Then read through a bounded stream with a byte cap, re-check total at most the cap, never buffer more than the cap plus one chunk, decode UTF-8, and return `{data:{text}}`. T1 records the measured maximum file size.
   - A malformed id yields a 4xx, not a 500.
   - All failures return one generic error body without echoing the path or existence (anti-enumeration, as in the `learnData` pattern). No caching headers needed. Never accept a raw storage path.
   - Coordination: if #174 already introduced an owner resource-access action, extend it with the same constraints instead of adding a parallel one (whichever lands first owns it).
   - Rejected alternative: a new storage SELECT policy for the owner on legacy band paths, because it would widen owner signed-URL read to every legacy asset type; the Edge action is narrower.
7. **Owner surface** (independent of #174; Section 4.12): export `VocabularyReviewRow` (props: display name, stable key, loader) and render `ResourcesPanel`'s `vocabulary_review` rows through it. Mount it in `CourseWorkspacePage.tsx` `Content()` inside `section.selected-lesson` after `<LessonEditor>`, for the selected block only, when `legacy_lesson_id != null`, with the `lesson-resources` markup and no `workspace-panel` ancestor of the list. Widen the `AnyBlock` and `CourseBlock` types with `legacy_lesson_id?: string | null`. Fix `duplicate()` (~136) to set `legacy_lesson_id: null` on the clone. Supply the owner loader and the row name (title fallback chain). Do not touch the dangling `aria-labelledby="selected-lesson-heading"`.
8. **Roadmap validation** (desktop rail and mobile Files tab): the T5 Roadmap portion.
9. **`/learn` integration** through #174's shared `ResourcesPanel` (no `/learn`-specific viewer code). Requires #174 merged.
10. **Full browser validation** including journey 10 (the #174 `/learn` surface plus J-owner-1 to J-owner-8 on the Course workspace Content tab); repeat inert, stacking, sentinel, and DD-7 checks per host. Then Verifier and Browser Validator.

## 7. Interfaces and data

- **`ResourcesPanel` props:** add one optional loader prop (name is T1's choice) of type `(resource: ResourceRow, signal?: AbortSignal) => Promise<{ok:true; text:string} | {ok:false; reason?:string}>`, with the student loader as default. Existing props are unchanged.
- **New Edge action contract:** `POST course-authoring {action:'get_owner_resource_text', payload:{lesson_revision_id}}` (or `{resource_id}` only if #174 needs it; exactly one, both strict uuid) returns `200 {data:{text:string}}` or non-2xx `{error:'<generic>'}`. Owner-only and course-ownership-checked (Section 6 step 6, Section 4.12).
- **Exported row:** `VocabularyReviewRow` (working name) with props display name, stable key, and loader; used by `ResourcesPanel` and the owner mount.
- **Type widening:** `AnyBlock` and `CourseBlock` gain `legacy_lesson_id?: string | null`.
- **Limits:** 256 KiB loader cap, 5,000 lines, 10,000-character line, 2,000 blocks, list nesting depth 1.
- **`storageSigning`:** `STORAGE_CONFIG.RESOURCE_EXTENSIONS` values corrected (exported constant; consumers are tests only).
- **Consumes #173:** `src/lib/storageContentType.ts` (`contentTypeForPath`), optionally for the `.md` check; names are stable per the #173 plan.
- No migrations. No RLS changes. No new dependencies. No data changes.

## 8. Acceptance checks

- **T1 Matrix (vitest).** For each band (beginner, intermediate, advanced) and week 1-26 (78): the storage-seed `weekly-review-recap.md` exists and is non-empty, and exactly one `vocabulary_review` resource row is produced for it across `seed.sql` (Beginner 1-4) and the `full-catalog.sql` / `provision-lessons` manifest (others), with path `<band>/week-NN/weekly-review-recap.md`.
- **T2 Unit and a11y (vitest and testing-library).**
  - Parser subset cases; wrapped list continuation; CRLF, BOM, empty, and whitespace input.
  - XSS strings ("`<script>alert(1)</script>`", "`<img src=x onerror=...>`", "`[x](javascript:alert(1))`", raw HTML) render as literal text with no element created.
  - Heading mapping and a single title.
  - Lang golden `vocabReviewLangGolden.json` exact diff, named fixtures, and the secondary marker invariant.
  - Viewer roles and names (dialog name equals title, region "Document content"), focus on Close, Tab cycle, Escape, focus restoration, and inert applied and removed order.
  - StrictMode sentinel tests per invariant 8; DD-7 fallback test.
  - aria-disabled and inset-ring computed-style tests; the `FixedOverlayFocusPosition` `PROTECTED` entry.
  - Answer-stripped fixture variants render.
- **T3 Mocked storage (vitest).** A `ResourcesPanel` `vocabulary_review` row with mocked `client.storage.createSignedUrl` and `fetch`:
  - a fresh signed URL and fetch on every open (two opens yield two calls each);
  - loading is aria-disabled, and the re-entry guard holds (double click yields one fetch);
  - a signing failure shows the reason verbatim;
  - a fetch failure shows the generic message plus Retry;
  - a missing path shows its message; an empty body shows the empty state;
  - abort on unmount with no state-after-unmount warning;
  - an owner-loader failure shows the generic error;
  - flashcards, pdf, and pptx rows unchanged (existing suites stay green, including `weekDetailFullParityInventory` and `weekDetailDesktopNonRegressionConsolidated`, updated only for `vocabulary_review` copy).
- **T4 Local integration (vitest, local Supabase only, exact-match `http://127.0.0.1:54321` guard as in `scripts/provision-lessons.ts`).** After `npx supabase db reset` and container restarts, sign in as `fullaccess@test.local` / `password`. For all 78 `vocabulary_review` resources: student `createSignedUrl` succeeds, fetch returns text, and parse plus render (`renderToStaticMarkup`) yields one h2 title, at least one h3, no unparsed `# ` or `**` artifacts at block starts, and no script or anchor elements. Owner: sign in as `owner@test.local`, call `get_owner_resource_text` for all 78, and confirm the text equals the student-fetched text. Negatives:
  - a student (`fullaccess`) calling the owner action gets a generic denial;
  - the owner action with a pdf, pptx, or flashcards resource id is refused;
  - a random uuid gets a generic error;
  - a malformed id gets a generic 4xx, not a 500;
  - an unentitled student (for example one of `student1` to `student6` without that band) calling `createSignedUrl` for another band's recap is denied.
- **T5 Playwright (`E2E_BASE_URL=http://localhost:5178`).** Weeks {1, 4, 5, 13, 26} per band at 390x844 and 1440x900 on the Roadmap week detail as `fullaccess@test.local`: open the viewer, title visible, close via Close, Escape, and back, focus restored, no dialog events. Plus design journeys 1-11 (including the long document advanced week-26, error and retry through route interception, an empty body stub, breakpoint crossing 9a-9d, and page-arrival timing 11), axe (`@axe-core/playwright`) with the overlay open and no serious or critical findings, forced-colors and reduced-motion emulation, 320x640 with no horizontal scroll, and screenshots per the design brief. After #174: the same weeks on the `/learn` lesson detail and the owner preview journey (journey 10).
- **Revision 1 additions.**
  - **T1 matrix size assertion:** the test records the exact byte size of all 78 recap files and asserts the maximum is at most 64 KiB (cap at least 4x headroom). If the maximum exceeds 64 KiB, return `JOB_BLOCKED` "Plan stale" for a cap decision.
  - **Unit, loader:** oversized `Content-Length` yields no body read and an error; no `Content-Length` with a stream exceeding the cap yields a cancelled or aborted reader at the cap and an error; a named test shows a cap abort sets the row error plus Retry while an unmount abort sets no state.
  - **Unit, Edge:** a preflight refusal test (oversized object refused before any download); the course-ownership predicate unit-tested (including an owner of another course denied if no second owner fixture exists locally).
  - **Unit, parser limits:** each limit (bytes, lines, line length, blocks) yields a row error, no overlay, and focus stays on the button; a nested-marker fixture renders as plain paragraphs; computed `hyphens: manual`.
  - **Unit, owner mount:** `duplicate()` sets `legacy_lesson_id: null`; the row is absent for a block without a legacy id.
  - **T4 owner contract (replaces the `resource_id` negatives above):** owner calls use `lesson_revision_id`. Negatives: a student caller is denied; an owner of another course is denied; an authored revision (no legacy id) is refused; pdf and pptx resolution is impossible by construction (assert the type filter); a random or malformed uuid yields a generic error. For all 78, the owner text equals the student-fetched text.
  - **T4 oversized fixture:** a service-role fixture uploads a temporary oversized `.md` (above 256 KiB) under a test-only `lesson-assets` path, with a temporary `vocabulary_review` `resources` row linked to a temporary legacy lesson and revision mapped into an owner-owned version (or the closest local equivalent T1 finds). It asserts the student path errors without full transfer and the owner action refuses at preflight, then cleans up (exact-match local guard).
  - **Browser, resilience (F-A4: layout overflow cannot be asserted in jsdom):** at 320px with stubbed bodies (a 5,000-character unbroken token, a long URL-like string, long inline code, one very long line), `scrollWidth <= clientWidth` on `.vocab-review-overlay-body` and no page horizontal scrollbar; a normal-document wrap snapshot regression; the same at 390 and 1440 on student and owner hosts.
  - **Browser, owner:** journeys J-owner-1 to J-owner-8 and the owner host checks from Section 4.12.
- **Also:** `npm run lint`, `npm run type-check`, `npx vitest run` (full suite green), `npm run build` and `verify:build`; a deterministic native-dialog scan (`nativeDialogPolicy.test.ts` covers `src`, plus a grep of changed files for `alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, `beforeunload`); and the Spanish-literate spot-check recorded (release gate).
- **Verifier and Browser Validator:** a read-only Verifier pass is required, and a Browser Validator pass is required for the rendered UI. Completion follows the Section 4.8 gate.

## 9. Browser UI dialog policy and browser validation inputs

**Dialog policy (required).** No `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt`, or `beforeunload` anywhere. Use only the app-owned accessible overlay (`role=dialog aria-modal`, focus trap, Escape, focus restoration, inert background) and inline loading, error, Retry, and empty states. A deterministic no-native-dialog source scan, Playwright fail-on-dialog-event, and modal keyboard and focus verification are required.

**`browser_ui_validation`:**

- **Launch and readiness:** from the implementation worktree, `npx vite --port 5178 --strictPort`; ready when `http://localhost:5178` returns the app shell. Local Supabase running.
- **Base URL:** `http://localhost:5178` (Playwright `E2E_BASE_URL=http://localhost:5178`).
- **Fixture and reset:** `npx supabase db reset`, then `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`. Accounts, password `password`: `fullaccess@test.local` (all bands, all weeks), `student1` to `student6@test.local` (unentitled and denied cases), `owner@test.local` (owner preview).
- **Journeys:** design journeys 1-11: 1 desktop open short document with three close paths; 2 mobile Files tab; 3 long document keyboard scroll, inert, inset ring; 4 fresh fetch on reopen; 5 loading aria-disabled; 6 error plus inline Retry; 7 denied access; 8 empty content; 9 breakpoint 9a-9d; 10 `/learn` and owner after #174 (completion gate); 11 page-arrival timing. Plus the T5 week matrix {1, 4, 5, 13, 26} x 3 bands.
- **Owner journeys and fixtures (revision 1):** J-owner-1 to J-owner-8 at 390 and 1440, with the owner fixture and validation inputs, as specified in Section 4.12 (`owner@test.local` / `password`, Course workspace Content tab of a legacy band course, a seeded or in-test draft authored lesson, reset with `db reset`).
- **Fixture documents:** beginner week-01, intermediate week-02, advanced week-05, advanced week-26.
- **Viewport profiles:** 390x844, 1440x900, 320x640; zoom 200% at 1440 for 9b.
- **Visible outcomes:** the overlay covers the viewport; the h2 title begins "Weekly Vocabulary Review Recap"; h3 sections; lists hang; no download, new tab, or navigation; the URL is unchanged and there is no orphan history after close; focus is on the trigger (or the DD-7 fallback); inline error with Retry; empty-state copy; no app chrome over the overlay; axe no serious or critical; forced-colors visible focus and borders; no horizontal scroll at 320.
- **Screenshots:** idle, loading, and error rows; open short document; long document scrolled to the end; focused scroll region; empty state, each at 390 and 1440.

## 10. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | XSS through untrusted Markdown | No innerHTML, React text nodes only, XSS unit tests, CODE_REVIEW rubric. |
| R2 | Owner Edge action over-privilege (service role) or unbounded read | Owner check server-side plus the course-ownership check, id-only input (no raw path), type, bucket, and extension allowlist, preflight size and bounded stream read at 256 KiB, generic errors, T4 negatives. Rollback: remove the action (owner preview reverts to unavailable; students unaffected). |
| R3 | #174 not landed or API differs | Steps 1-7 proceed; `/learn` and owner are gated; the completion gate prevents premature done; stale-plan trigger. |
| R4 | Sentinel and history bugs (StrictMode, rapid reopen, breakpoint) | DD-4 shape, StrictMode tests, journeys 1 and 9. |
| R5 | Overlay clipped or covered (ancestor transform during page-turn animation, AdminShell stacking) | Journey 11, stacking check per host, permitted portal variation. |
| R6 | Inert remnants or lost focus | Inert-before-refocus order, DD-7 ordering (fallback after `useFocusTrap`), tests. |
| R7 | Lang mis-tagging | Conservative rule, golden, release-gate spot-check; worst case equals today's untagged baseline. |
| R8 | Regressions in flashcards, pdf, and pptx rows | No changes to those paths; existing suites stay green. |
| R9 | #180 later edits recap content | Viewer is content-agnostic and tests do not depend on answers; the lang golden needs a reviewed regeneration when #180 changes files (expected and documented). |
| R10 | A signed URL may download rather than display | Irrelevant: the app fetches text programmatically. |
| R11 | CSS bleed on the owner host (for example `workspace-panel` restyling the list, status min-height, or overlay h2 word-break) | No `workspace-panel` ancestor of the list, named computed-style assertions matching the student host, the `document.body` portal fallback. |
| R12 | Draft linkage loss (`save_outline` drops `legacy_lesson_id` on each draft save) | Known limit. Verify on the published legacy version, strict `legacy_lesson_id` eligibility, `duplicate()` clears the id. Follow-up issue to preserve linkage (out of scope, not created by this plan). |

**Rollback:** a single PR revert restores the download-link behavior (no migrations, no data changes, no dependency changes). Edge action removal is independent. No production data is touched.

## 11. Stale-plan conditions

The writer must return `JOB_BLOCKED` "Plan stale" if any of the following holds:

- #174 merges with a `ResourcesPanel` or row API, owner surface, or owner resource action that differs materially from this plan's assumptions.
- `origin/main` changes `ResourcesPanel.tsx`, the `WeekDetailPage` breakpoint or sentinel, `useFocusTrap`, the `App.css` focus override list, or `Control.css` disabled conventions materially.
- #180 lands first and changes recap structure (headings or sections) beyond answer removal.
- Storage RLS or `resources` seed paths change.
- Another change adds a Markdown dependency.
- The user changes the in-app, both-surfaces, or owner-preview decisions.
- The `course-authoring` Edge owner authorization mechanism changes.
- `save_outline` changes legacy linkage behavior.
- The `CourseWorkspacePage` Content tab structure or the `getCourse` block mapping changes.
- #174 introduces an owner resource action with a conflicting contract.
- The measured maximum recap size exceeds 64 KiB.

## 12. Dependencies

- **#174** (handout links, `/learn` `ResourcesPanel`, possible owner resource-access action). Recommended to merge first. Step 9 and the `/learn` part of the completion gate require it; the owner surface no longer does (Section 4.12). If #174 introduces an owner resource action, extend it with the Section 6 step 6 constraints (whichever lands first owns it). No #174 plan existed at draft time (**Unknown**: its final component API).
- **#173** (`src/lib/storageContentType.ts`, `.md` served as `text/markdown; charset=utf-8`). The viewer does not depend on Content-Type.
- **#176**: states that #174 and #175 are shared components rendered on both surfaces.
- **#178 and #180**: #178 does not touch recaps; #180 owns answer removal and may change recap content later (R9).
- Local Supabase stack, Playwright, and `@axe-core/playwright` (already available).

## 13. Assumptions and decisions

**Safe assumptions:**

- `fullaccess@test.local` unlocks all 78 weeks locally (the `seed.sql` comment).
- Local Beginner weeks 1-4 come from `seed.sql` fixtures.
- The viewer is independent of Content-Type.
- Authored courses have no `vocabulary_review` data (out of scope; the row is absent).

**Stated defaults (revision 1).** The former decisions D1 to D7 are now stated defaults. The user may override any of them at approval.

- **D1. Ordering.** #174 first. Steps that do not depend on #174 (now including the owner surface) may proceed in parallel; the `/learn` part of the completion gate requires #174.
- **D2. Error-contrast fix.** `vocabulary_review` rows only in #175; other rows follow up.
- **D3. Breakpoint crossing.** Crossing the 900px breakpoint while reading closes the viewer (accepted limitation; alternative: a page-level provider).
- **D4. Spanish-literate spot-check.** The owner (or Lizbeth) performs it. It remains a pre-release item for the user.
- **D5. Owner surface.** Removed as a user decision: the owner surface is decided as the Course workspace Content tab (Section 4.12).
- **D6. Authored-course vocabulary review.** Out of scope (the user confirmed).
- **D7. Commit, push, and PR authority.** None is granted by this plan; it needs a separate explicit user request.
- **Also confirmed by the user:** in-app rendering (not PDF or raw `.md`).
- **New design defaults:** "Lesson resources" is placed below the editor (the owner may prefer above); the draft-linkage limitation with a follow-up issue to preserve linkage in `save_outline` (out of scope, not created by this plan).

## 14. Engineering mode and downstream owner

- **Engineering mode:** standard. T1 is first line; T2 takes over on two counted gate failures. No extreme advisory team. `team_authorization`: not applicable.
- **Downstream owner:** engineering-fleet.
- **Approval gate:** T1 starts only after the user explicitly approves this plan. Until then the status stays DRAFT.

## Approval record

Approved by the user on 2026-10-04, relayed by the lead. This plan and `lizbeth-spanish-issue174-student-handout-links` were approved together.

- Approved by: the user
- Date: 2026-10-04
- Covered: engineering per this plan, including commits, pushes, new branches, and pull requests per item (user standing instruction: new branches and PRs as needed). This supersedes the D7 statement that the plan itself grants none.
- Decisions: ordering is #174 first. D1 to D7 are accepted as the stated defaults.
- Pre-release user step: the Spanish spot-check by the owner or Lizbeth remains required before release.
- Not covered: production writes (storage re-tag Phase P, hosted migrations, Edge Function deploys, Netlify deploys) each need a separate explicit user go-ahead. The read-only hosted check against `gvobtuhbpqvfhjljjcye` needs its own explicit go-ahead naming that project.
