# Plan: Lizbeth Spanish #208 lesson-task copy (bilingual task surfaces)

- Plan id: `lizbeth-spanish-208-lesson-task-copy`
- Task id: `lizbeth-wave6-208-lesson-task-copy`
- Status: **APPROVED 2026-10-15 (Revision 1).** User words, verbatim, 2026-10-15: "Approve all four plans as recommended". Decisions D-208-1 to D-208-11 are adopted at their recommendations. Lizbeth's approval of the Spanish is still required before any merge (D-208-7); it is tracked in `docs/plans/lizbeth-spanish-208-es-review.md`, whose status remains "awaiting Lizbeth's approval". Every hosted action needs its own separate explicit approval.
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team. Agent teams: not applicable.
- Target: `lebobo88/lizbeth-spanish` (private).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013`, detached at `main` `f8a95a3`. Every `file:line` in this plan refers to `f8a95a3`.
- Parent plan: `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md` (APPROVED). This is the Wave 6 deferred sub-plan for #208 (parent sections 4.2 #208, 9 Wave 6, 10, 14 D-21, 17 item 5). Parent section 17 item 5 requires re-plan and approval at sub-plan start; this document is that re-plan.
- Decision of record, D-21 (resolved 2026-10-12), user verbatim: "For 208, as suggested, you draft and she approves, as recommended." Meaning: hybrid scope. Functional strings (buttons, errors, status chips, validation, announcements) get fixed EN/ES translations that are not owner-editable or hideable. Only explanatory and instructional messages become owner-editable registry keys. Engineering and Scribe draft the Spanish and Lizbeth approves it before shipping. This waives the #177 "no machine translation" rule for #208 only.
- Prerequisites: PRs #229 and #232 are merged and present on `f8a95a3`.
- Companion document: `docs/plans/lizbeth-spanish-208-es-review.md` (Lizbeth's review artifact; plain English, no keys or code).
- Design route: compact (see section 5). Judge route: see section 11. Research: not needed (all decisions rest on local repository evidence; Spanish wording is approved by Lizbeth, not by external sources).

**Revision 1 (PLAN_DUCK J-208-001..003, 2026-10-15).** One planner-requested revision, applied in place. Status stays DRAFT. Per-key table rows and all Spanish are unchanged.

- J-208-001 (major, old-Edge skew): a save that mixes an old key and an unknown new key fails atomically on the old Edge, the editor has no inline renderer for key-level errors, and `saveSiteContent` drops server `fieldErrors`. The frontend must therefore degrade safely whichever of Netlify or the Edge deploys first. Adds F15, A11 and R-10; corrects F8, the PR B scope, the hosted order text, RED tests for PR B, J11, risk R-3 and D-208-8; adds the live skew run.
- J-208-002 (major, language switch and live regions): retranslating a live region on a switch is announced, so the earlier "re-render in place, announcement acceptable" statement is superseded. New invariant: a language switch updates visible text and accessible names but produces no announcement and moves no focus. Adds A12 (snapshot rule, announce-once rule); corrects the Design handoff language switch invariant, A4, A6, PR A scope, RED test 4 (plus new RED 4b) and J3. This tightens, and does not loosen, the reviewed design; it adds no visual or UX surface, so no design re-review is needed (same reasoning as the parent plan's Revision 1).
- J-208-003 (minor, lang scoping): a blanket `lang="en"` wrapper on `QuizPanel` would mislabel the Spanish accent-insert button names. Language marking is set on the smallest element whose resolved text differs from its nearest ancestor's language. Corrects R1, A10, RED test 9 and J2.
- Out-of-scope observation added to the D-208-5 follow-up (section 8): two more hard-coded English strings.

Reading guide: sections 1, 2, 3, 13 and 14 are what an approver needs. Sections 4 to 12 hold the evidence and execution detail for the engineering fleet. Evidence is labelled Observed unless marked Inference or Unknown.

### Standing constraint: production is live

Recorded from the parent plan (user words, 2026-10-13): production Supabase holds real student and course tracking data, and nothing may be lost. This plan has no migration and deletes no data. New `site_content` rows are created only by owner edits after PR B and the Edge redeploy. Rollback never deletes rows. Hosted actions still need separate explicit approval.

---

## 1. Outcome and audience

Audience:

- Rob (repository owner): approves the plan, the decisions and every hosted action.
- Lizbeth (teacher and owner): approves the Spanish through the review document.
- The engineering fleet (T1 first-line).

Observable outcome:

- A student who chooses Español sees every lesson-task string in Spanish: task bar, status chips, fields, counters, validation, error summary, submit modal, leave modal, `/learn` cards, standalone task page and completion note.
- The text switches live with the existing site language toggle, with no page reload and no loss of typed answers.
- Eleven explanatory strings become owner-editable in English and Spanish in the existing owner site-copy editor. Validation prevents owner text from introducing `{placeholder}` tokens. Those eleven strings cannot be hidden.
- All functional strings are fixed and cannot be edited or hidden.
- English output stays byte-identical for English users.

## 2. Root cause summary

Observed.

1. The copy layer is a static English map behind a plain function with no language input and no registry wiring (F1). `lessonTaskText(key, vars, override?)` has an `override` argument that no caller passes, and the header comment refers to a `useLessonTaskCopy` seam that exists nowhere in `src`.
2. Rendered, translated text is stored in state (F3). Validation errors carry a rendered `message`, announcements are rendered strings, and counter live text sits in `PartField` state. A language switch would leave these in the old language. `signInCopy.ts:7-10` states the established precedent: display text is derived at render time from a kind plus the active language, with no translated text in state.
3. Some visible words bypass the copy layer (F4). The chip words are duplicated as literals in `lessonTaskStatus.ts`, the chip marker and sr-only text are hard-coded, the course fallback is hard-coded, and the shared Modal hard-codes its close label.
4. Admin pages force English, and the language mechanism already exists and is correct (F6). The work is wiring, not a new mechanism.

## 3. Scope and non-goals

In scope:

- The 88 `lesson_task.*` keys in `src/lib/lessonTaskCopy.ts`.
- Three new fixed keys: `lesson_task.chip.new_marker`, `lesson_task.page.course_fallback`, `lesson_task.modal.close`.
- The 18 `lesson_quiz.*` keys that render on the shared task surfaces (leave guard and completion-note composition), as fixed bilingual and not editable.
- The chip vocabulary duplication.
- Locale of time and number parameters on student surfaces.
- Spanish wrapping at 390 and 320 widths.
- An owner editor group for the 11 editable keys.
- Placeholder and non-hideable validation shared by client and Edge function.
- `lang="en"` marking of remaining English quiz strings while the site language is `es`.

Non-goals:

- All other `lesson_quiz.*` strings (QuizPanel body, quiz announcements, quiz modal copy, quiz link labels, QuizStatusChip) stay English this release. A follow-up issue is filed (D-208-5).
- Admin UI stays English (existing invariant, `PublicContentContext.tsx:59-67`, `:99`).
- Author and lesson content (item titles, part labels, prompts, practice field labels) is not localized.
- Other student-surface registry keys (roadmap, learn, course, feedback groups have no ES defaults today) are untouched.
- No database migration. No change to submit semantics or the unseen-marker call. No new design tokens.

## 4. Repository findings

All Observed unless marked, at `f8a95a3`.

- **F1 Key count.** `src/lib/lessonTaskCopy.ts:10-128` defines exactly 88 `lesson_task.*` keys, all English only. `lessonTaskText` at `:133-136` interpolates `\{(\w+)\}`, leaves unknown tokens literal, and accepts an unused `override`. The header comment (`:4-8`) refers to a nonexistent `useLessonTaskCopy` seam (grep: 0 definitions).
- **F2 Call sites.** 73 product `lessonTaskText(` calls across 12 product files: `LessonTaskBar.tsx` 29, `lessonTaskLogic.ts` 10 plus `overlayNoteKey` key returns, `LearnDetailPage.tsx` 9, `LessonTaskFields.tsx` 5+, `LessonTaskLeaveGuard.tsx` 5, `LearnTaskPage.tsx` 4, `useLessonTask.tsx` 3, `AccentStrip.tsx` 2, `LessonContentView.tsx` 1, `LessonCompletionNote.tsx` 1, `WeekDetailPage.tsx` 1, `lessonQuizLogic.ts` 1. Non-React logic: `lessonTaskLogic.ts` (`counterState` `:47-69`, `validateForSubmit` `:122-136`, `serverFieldErrors` `:139-149`, `overlayNoteKey` `:100-113`) and `lessonQuizLogic.ts` `composeCompletionNote` `:245-259` (uses `lessonTaskText` at `:255`). Tests also import it (`issue179c-lesson-task-logic.test.ts`, `issue179c-source-scan.test.ts`, `issue180d-quiz-logic.test.ts`).
- **F3 Translated text in state.** `SubmitFieldError.message` (`lessonTaskLogic.ts:119`, `:128`, `:131`, `:144-147`) is held in `useLessonTask` state. Announcements are rendered strings (`useLessonTask.tsx:153`, `:634-636`). Counter live text is stored in `PartField` state (`LessonTaskFields.tsx:40-43`, `:110`).
- **F4 Dead and duplicated keys.** The six `lesson_task.practice.scenario/roles/write/format/register/phrases` keys (`lessonTaskCopy.ts:77-82`) have no product reference; practice block labels come from lesson content `f.label` (`LessonTaskFields.tsx:137-141`). Only `lesson_task.practice.checklist` is used (`:145`). The six `lesson_task.chip.*` keys (`lessonTaskCopy.ts:12-17`) are unused: the chip words are duplicated as literals in `src/components/lessonTask/lessonTaskStatus.ts:4-10` (`LESSON_TASK_STATUS_COPY`), consumed by `LessonTaskStatusChip.tsx:23-29` and `SubmissionLedgerRow.tsx:56` (owner aria-label). The chip's visible "▪ New" and sr-only " New feedback" are hard-coded (`LessonTaskStatusChip.tsx:32-35`). `LearnTaskPage.tsx:46` hard-codes the fallback "your course". The shared Modal hard-codes `aria-label="Close modal"` (`Modal.tsx:125`) and renders inline with no portal (`Modal.tsx:98-132`).
- **F5 Chip mounts.** Student: `LessonTaskBar.tsx:213`, `WeekCard.tsx:152`, `LearnDetailPage.tsx:360`/`:364`. Owner and admin: `OwnerSubmissionDetailPage.tsx:243`, `SubmissionLedgerRow.tsx:62`, `StudentTaskSubmissionsList.tsx:45`, `CourseWorkspacePage.tsx:673`. Admin routes resolve `en` (`PublicContentContext.tsx:99`), so a language-aware chip stays English on owner pages.
- **F6 Language mechanism.** `PublicContentContext.tsx` holds `language` (`en` or `es`), persisted under localStorage key `lizbeth.siteLanguage` (`:23`, `:50-57`, `:123-130`), forces `en` on `/admin/*` (`:59-82`, `:99`), sets `document.documentElement.lang` (`:138-140`), and works with no provider mounted (`NO_PROVIDER_VALUE`, language `en`, `:39-45`), so bare component tests resolve English. `useSiteLanguage()` at `:162-165`; `useSiteText(key)` at `:172-177`. `LanguageToggle` renders in the signed-in header (`App.tsx:585`, `:714`) and `MobileNavPanel.tsx:190`. Fixed bilingual precedent: `src/lib/signInCopy.ts` (`Record<SignInLang, SignInCopy>`, missing `es` is a compile error; tú register; "tu profesora"; DRAFT comment convention at `:84-86`).
- **F7 Registry.** `src/lib/siteContentRegistry.ts` entries carry `default: {en, es?}`, `maxLength`, `multiline`, `role`, `toggleGroup?`, `fallbackH1?` (`:26-47`); no placeholder metadata and no non-hideable flag. Groups at `:60-70` (business page: meta, dashboard, roadmap, learn, course, feedback, band). The module is dependency-free and Deno-importable with explicit `.ts` imports (`:10-12`). Resolution: `siteContentResolve.ts:54-73` (ES order: disabled hidden; stored ES; built-in `default.es` when no custom EN; custom EN; `default.en`; `sourceLang` drives `lang="en"` marking in `SiteText.tsx:48-52`). Provenance tags (#232): `siteContentProvenance.ts:48-56`.
- **F8 Validation and Edge.** `siteContentAuthorization.ts:81-129` whitelists keys via the registry (unknown key rejected at `:100-104`, import at `:14`), requires boolean `enabled`, enforces code-point maxLength (`:74-77`) and forbidden characters (`:37-52`, `:70-73`). `supabase/functions/site-content/index.ts` imports it (`:23`); the Edge bundle therefore embeds the registry, so new keys need a hosted `site-content` redeploy. The owner editor sends only dirty keys (`SiteContentFields.tsx:99`, `:170-177`) in one PUT, so an Edge that predates PR B rejects a save that includes any new key as a whole (see F15).
- **F9 Tests pinning the registry.** `src/__tests__/siteContentRegistry.test.ts` pins the key set to `src/__tests__/fixtures/siteTextBaseline.ts` (`:13-19`), pins ES defaults to exactly the six `signin.*` keys (`:27-39`), requires maxLength >= ceil(1.25 x EN length) (`:41-46`), and pins business group titles (`:75-83`). These are intentional, documented updates in PR B, not weakened assertions.
- **F10 Database.** `public.site_content` (migration `202610040001_issue177_site_content.sql:26-32`) has key check `^[a-z][a-z0-9_.]{1,63}$` (the longest new key, `lesson_task.completion.not_started_recorded`, is 43 characters), jsonb value, boolean enabled; written only by `service_role` via the Edge function. No migration is needed for new keys. Inference: no `lesson_task.*` rows can exist in production today because the Edge function has always rejected unknown keys (from `:100-104`; confirm with the optional read-only query in D-208-9). Unknown: whether owner-customized rows exist for other keys. This work does not rename keys, change any existing `default.en`, or apply new validation to legacy keys, so such rows are unaffected.
- **F11 Owner editor (#232).** `SiteContentFields.tsx` groups as `<details>` (`:460-502`), rows with EN/ES inputs and Preview (`:369-430`), "Shown on site" toggle via `withToggle` (`:397`, `:425`), field errors `<span id="{fieldId}-error" role="alert" class="owner-settings-field-error">` (`:305-309`), validate then `surfaceErrors` opens groups and focuses the first invalid field (`:143-168`, `:179-188`).
- **F12 Locale.** `formatTime` uses `toLocaleTimeString(undefined, ...)` (`LessonTaskBar.tsx:32-34`), i.e. browser locale. `lesson_task.save.too_long_draft` hard-codes "20,000" (`lessonTaskCopy.ts:36`). The visible counter `0000 / max` (`lessonTaskLogic.ts:48`) is digits only.
- **F13 Quiz strings on shared surfaces.** `LessonTaskLeaveGuard.tsx:83-98` builds quiz-only and combined variants from `lessonQuizText`. `composeCompletionNote` (`lessonQuizLogic.ts:209-259`) composes `lesson_quiz.completion.*` sentences and task tails. Both are in scope as fixed bilingual. Remaining English quiz text renders in `QuizPanel.tsx` (three return branches: loading `:101-105`, error `:108-115`, fragment `:138-222` including a sibling Modal `:189-222`), `LearnDetailPage.tsx:262-265` (quizLinkLabel), `:361` (QuizStatusChip), `LearnQuizPage` and `WeekDetailPage`.
- **F14 Test ports.** `src/__tests__/helpers/testConfig.ts` resolves `SUPABASE_API_URL` and `SUPABASE_DB_PORT` (loopback-guarded). Mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` exists with `supabase/config.toml` api port 64321. `playwright.config.ts` uses `E2E_BASE_URL`; projects `chromium` and `webkit-mobile`.
- **F15 Old-Edge skew (J-208-001).**
  - Observed: `sanitizeSiteContentPayload` returns no entries when any error exists (`siteContentAuthorization.ts:128`, `entries: errors.length ? [] : entries`), so a save that mixes an old key and an unknown new key fails atomically. The unknown-key error uses the bare key as `field` (`:102-103`). The editor renders errors only for `<key>.en` and `<key>.es` (`SiteContentFields.tsx:281-309`), so a key-level or `<key>.enabled` error has no inline renderer, and `surfaceErrors` opens the group but has no focus target for it (`:143-160`).
  - Observed: `saveSiteContent` throws without `fieldErrors` when `functions.invoke` returns `error` (`siteContentData.ts:83-90`). Inference (to confirm by RED test): supabase-js returns a `FunctionsHttpError` with null data for any non-2xx response, so server 422 `fieldErrors` never reach the form today.
  - Coordinator-reported: the hosted `site-content` Edge was last deployed from commit `8e89737`, and a skew audit showed Netlify can publish the frontend ahead of the Edge. The frontend must therefore degrade safely before the Edge redeploy and must not rely on deploy order.
  - Unknown until Step 0: whether the `8e89737` source has the same GET 405 branch (`index.ts:44-46` at `f8a95a3`) and the same registry key set as `f8a95a3`.

## 5. Design route and Design handoff

Design route: **compact**. Reasons: brownfield copy change on existing student task surfaces with Spanish expansion at 390 and 320, plus a bounded extension of the #232 owner editor (one group, a non-hideable row variant, placeholder errors). Agents: design-generalist (Sonnet), design-reviewer. Prototype forbidden. Existing system mode: preserve. Design review: `DESIGN_REVIEW_RESULT` verdict PASS after the single allowed revision (round one NEEDS_REVISION findings F1 to F8 resolved). Review limits: read-only; no browser, axe or test run; Spanish wording and final English admin wording are unapproved inputs.

### Design handoff

Direction: preserve the paper/ink system. Zero new tokens. One selector per line in CSS.

**Wrap rule.** Root cause: `.control` has `min-height: var(--control-height)`, `padding: 0 var(--space-4)` and no wrapping rule (`Control.css:11-26`). In `LessonTaskForm.css`, scope the following selectors, plus the leave-guard modal actions wrapper if it differs:

- `.lesson-task-bar-actions .control`
- `.lesson-task-conflict-actions .control`
- `.lesson-task-modal-actions .control`
- `.lesson-task-load-error .control`
- `.lesson-task-save-line .control`
- `.lesson-task-updated-note .control`

Declarations: `height: auto`; `padding-block: var(--space-2)` (min-height stays the touch floor); `white-space: normal`; `text-align: center`; `max-width: 100%`; `overflow-wrap: anywhere`. No truncation, `text-overflow`, `overflow: hidden` or fixed widths. Below 56.24rem the existing column stack (`LessonTaskForm.css:284-298`) applies; add the same column stack to `.lesson-task-conflict-actions` (flex-wrap only today, `:238-242`). Inline quiet Retry and Refresh buttons wrap with their sentence. Verify the compact chip at 320.

**Language switch invariant.**

- The switch adds no new status message, moves no focus, and never remounts the form. Answers live in `task.responses`. Do not key the form, fieldset or textarea on language. Keep `ErrorSummary key={submitAttempt}` at `LessonTaskBar.tsx:195` so the focus-on-mount effect (`:40-42`) does not re-run.
- Invariant (J-208-002, replaces the earlier statement): a language switch updates visible text and accessible names but produces no announcement and moves no focus. Observed: the hidden polite region (`LessonTaskBar.tsx:252-254`) renders `live`, derived on every render from `saveState` and `savedAt` (`:151`); the counter live span (`LessonTaskFields.tsx:110`), the `/learn` region (`LearnDetailPage.tsx:628`, set at `:604`), the visible `role="alert"` regions (ErrorSummary `:46`, conflict `:198`, load error `:138`, modal error `:275`) and `role="status"` nodes (`LessonTaskBar.tsx:131` loading, `LessonCompletionControl.tsx:120`) would all be announced if retranslated.
- Snapshot rule: hidden polite live regions (`LessonTaskBar` `:252`, `LessonTaskFields` `:110`, `LearnDetailPage` `:628`) render a snapshot string captured at emission time in the then-current language, never text re-derived from the current language at render. Descriptors stay in state for visible text only. On a language change the hidden polite regions are cleared to an empty string in the same commit and stay empty until the next real event (clearing is not announced).
- Announce-once rule: visible alert and status regions (ErrorSummary, conflict, load error, modal error, and the loading and confirmation status nodes) carry `role="alert"`, `role="status"` or `aria-live` only for the emission window: from when their content first appears (or its event key changes) until about 1500 ms later. Afterwards the live attribute is removed and the visible content stays, so a later language switch mutates non-live content. ErrorSummary keeps `key={submitAttempt}` and its focus-on-mount behaviour.
- The reviewed design statement that alert re-announcement is "acceptable and not tested" is superseded by this stricter rule.
- Open modals re-render in place with focus kept.

**Completion note.** `overlayNoteKey` keeps returning a key. `composeCompletionNote` returns `{kind:'task_note', key}` or `{kind:'fixed', parts:[keys]}` or `null`. `task_note` renders through `SiteText` (`as="p"`, `id=COMPLETION_NOTE_ID`, existing className) or an equivalent hook preserving the `SiteText.tsx:51` lang rule. `fixed` renders as a plain node with the same id and className, parts joined by a space. The quiz-composed note is never owner-editable. Applies at `LessonTaskBar.tsx:186-188`, `:257-261` and `LessonCompletionNote.tsx:35-44`. Hints keep `id=hintId` and `aria-describedby` wiring.

**Accessibility.**

- `html lang` follows the toggle.
- Localized accessible names: task group `lesson_task.bar.label`, accent toolbar and insert buttons, modal titles, chip word and sr text, and the Modal close button via a new optional `closeLabel` prop defaulting to "Close modal".
- Chip glyph is `aria-hidden`; glyph plus word.
- WCAG 2.2 AA; no contrast or token changes.
- App Modal with Escape and Close, and focus return.

**Owner editor.** New group `{ id: 'lesson_task', page: 'business', title: 'Student pages — Lesson tasks' }` after `feedback`, before `band`.

- Eleven standard rows with "Appears on: ..." helper text. Privacy: "the Lesson task bar, under the Save draft and Review and submit buttons". Hints: "the hint above each answer box that must be written in Spanish / in English / where either language is fine". Seven completion rows labelled in plain words, for example "Completion note: Submitted, lesson marked", using "lesson marked" and "lesson not marked yet", with the surface "the note under the Lesson task bar when the task is {status} and the lesson is {marked | not marked yet}", plus "While a quiz is still outstanding, the quiz message is shown instead."
- Non-hideable variant: no "Shown on site" switch (`withToggle=false`). A static note styled like `.owner-key-row-note` reads "Always shown. Students always see this text. You can change the wording but not hide it." Reset to default stays. The server rejects `enabled:false` for these keys with a field error.
- Provenance tags unchanged (Built-in default, Built-in Spanish default, Custom text, Falls back to English).
- English admin wording is a proposal, adjustable within "plain, English, distinct" (D-208-11).

**Placeholder validation.** Opt-in per registry entry (a `placeholders` field, even `[]`). Legacy keys without the field are untouched, so existing production owner rows containing braces remain savable. Reject only closed tokens matching `\{(\w+)\}`; a bare "{" or "}" is allowed. Shipped messages:

- One token: `Remove "{token}". This text can't use placeholders.`
- Several tokens: `Remove the placeholders in curly braces. This text can't use them.`
- Generic branch for future keys (covered by one synthetic registry-test fixture, no shipped consumer): `Keep {token} in this text. It is filled in automatically.` and `"{token}" isn't available here. You can use: {allowed list}.`

The check lives in `siteContentAuthorization.ts` beside the length check. Order: forbidden characters, length, placeholder. First failure per field. Placement and focus use the existing `surfaceErrors`.

**Locale.** `formatTime` uses the active site language on student surfaces. ES copy has no English digit grouping. The counter `0000 / max` stays as is.

**Permitted variation.** Wrap-rule selector structure; registry flag names and shapes; row order and final English admin wording; the mechanism for `lang="en"` provided `SiteText` semantics hold; `Intl.NumberFormat` versus a per-language literal for the 20,000 limit.

**Binding conditions from the design review, adopted as acceptance criteria.**

- R1: every rendered English `lesson_quiz.*` string carries `lang="en"` while the site language is `es`, and none when `en`. Marking is set on the smallest element whose resolved text differs from its nearest ancestor's language, with no blanket wrapper on QuizPanel (J-208-003): `QuizItemFieldset.tsx:63-64` and `:121` mount `AccentStrip` inside QuizPanel, its toolbar label comes from English `lesson_quiz.accent.*` copy, but each insert button's accessible name comes from `lesson_task.accent.insert` (Spanish under `es`). Mark each English quiz string on its own element, or on a quiz-only container that holds no Spanish-resolved fixed strings, per return branch of QuizPanel (loading, error, group content) and on the quiz Modal (add an optional `lang` prop to Modal applied to the dialog element, passed from QuizPanel). `AccentStrip` sets `lang` on the toolbar to its label's language and on each insert button to the insert name's language, both from the resolver's returned `lang`: inside a quiz under `es` the toolbar is `en` and the buttons `es`; on task surfaces both `es`; under `en` no lang attributes are added. Quiz prompts keep their own lang (`QuizItemFieldset.tsx:52`, `:110`, `:226`; QuizRevealView and QuizResultsView `quizLang`). Also apply to quizLinkLabel and QuizStatusChip on `/learn` cards, and on LearnQuizPage and WeekDetailPage quiz text. Step 0 enumerates every English `lesson_quiz` render site. Add one DOM language-map check (RED test 9) on a quiz+task lesson and a `/learn` card with a quiz.
- R2: Modal gains optional `closeLabel` (default "Close modal", so admin callers are unchanged). The task submit modal and the leave guard pass the fixed bilingual key `lesson_task.modal.close`. A journey checks the Close accessible name in Spanish.
- R3: the owner helper text reads "While a quiz is still outstanding, the quiz message is shown instead." because `composeCompletionNote` uses the quiz sentence only while a quiz requirement is outstanding (`lessonQuizLogic.ts:248-256`). Once the quiz is passed, an outstanding task falls through to the editable task note. A journey covers both states.
- R4: ES parity covers all fixed keys and the 11 editable keys (their ES defaults ship as registry `default.es` sourced from the same table). Merge is gated on Lizbeth's approval, so parity is enforced at merge, not pre-approval.

## 6. Architecture

**A1 Single source table.** `src/lib/lessonTaskCopy.ts` becomes `LESSON_TASK_COPY: Record<LessonTaskCopyKey, { en: string; es: string }>`. A missing `es` is a compile error (the `signInCopy` precedent). EN values stay byte-identical to `f8a95a3`. The same treatment applies to the 18 shared keys in `src/lib/lessonQuizCopy.ts`: only those 18 gain `es`, and the type makes a missing `es` on those 18 a compile error (for example a separate `LESSON_QUIZ_SHARED_COPY` record or a typed subset). Both modules stay dependency-free and Deno-importable (explicit `.ts` imports only) because the registry imports defaults from `lessonTaskCopy.ts`.

**A2 Pure resolver.** `lessonTaskText(key, lang, vars?)` returns the fixed string for `lang` with `\{(\w+)\}` interpolation. The unused `override` parameter is removed. A `LESSON_TASK_EDITABLE_KEYS` constant lists the 11 editable keys.

**A3 React.** A hook `useLessonTaskText()` (in `src/lib/lessonTask/` or `src/context/`) reads `language` and `content` from `PublicContentContext` and returns `t(key, vars?)` plus `resolve(key, vars?) -> { text, lang }`.

- Fixed key: the fixed table value for the language. Owner rows for fixed keys are ignored even if present.
- Editable key (after PR B): resolves through the registry entry with `resolveSiteText` and returns `sourceLang` so the render site can mark `lang="en"`.
- With no provider it resolves English (`NO_PROVIDER_VALUE`), keeping bare component tests valid.
- This replaces the unwired `useLessonTaskCopy` comment.

**A4 Non-React logic returns descriptors, not strings.**

- `validateForSubmit` and `serverFieldErrors` return `{ itemId, partId, code, key, vars }`.
- `counterState(count, max)` returns `announce` and `over` plus descriptor keys and vars instead of text.
- `useLessonTask` stores visible-text descriptors `{ key, vars }`; render sites call `t(...)` at render. Hidden polite live regions are the exception: they render an emission-time snapshot string (A12, J-208-002).
- `composeCompletionNote` returns the structured result (section 5).
- This removes translated text from state (F3) and makes visible text re-render correctly on a language switch. Live regions follow A12, so the switch produces no announcement.

**A5 Chip single source.** `LESSON_TASK_STATUS_COPY` keeps glyph and tier. The word comes from `lesson_task.chip.<status>` via the hook (status `returned_for_revision` maps to `lesson_task.chip.returned`). `SubmissionLedgerRow`'s aria-label (owner, English) uses the same resolution. Visible marker: `lesson_task.chip.new_marker`. Sr-only text: `lesson_task.chip.new`.

**A6 Language switching.** The existing toggle changes context `language`; every hook consumer re-renders; no translated visible text is cached (hidden live regions hold an emission-time snapshot and are cleared on a switch, A12); the switch produces no announcement; localStorage persists the choice; `/admin/*` is always English; `html lang` follows.

**A7 Owner-editable keys (PR B).** The registry gains, for each of the 11 keys, an entry with `group: 'lesson_task'`, `default: { en, es }` imported from `LESSON_TASK_COPY` (single source), `placeholders: []`, `hideable: false`, `role: 'text'`, and maxLength (privacy 120, each hint 120, each completion note 300; all satisfy >= ceil(1.25 x EN) and >= ES length). Registry key equals copy key (single namespace).

**A8 Validation.** In `siteContentAuthorization.ts`: (a) the placeholder check, opt-in, as designed; (b) `enabled: false` on a `hideable: false` entry is a field error (`<key>.enabled`, message "This text is always shown and can't be hidden."). The same module runs in the client form and the Edge function.

**A9 Fallback order.**

- Fixed keys: the language's fixed string (ES always present by type); an unknown key cannot compile.
- Editable keys: `resolveSiteText` order (stored ES; built-in ES when no custom EN; custom EN marked `lang="en"`; default EN).
- For `hideable: false` entries the resolver treats a stored `enabled=false` row as enabled (defense in depth).
- A stored value that fails placeholder validation (for example written outside the Edge path) renders the built-in default for that language (client guard).
- Content fetch failure: defaults (existing silent behaviour).

**A10 Remaining English quiz text** gets `lang="en"` on the smallest element whose resolved text differs from its nearest ancestor's language, with no blanket `QuizPanel` wrapper, while the site language is `es` (R1, J-208-003). `AccentStrip` marks toolbar and insert buttons separately.

**A11 Old-Edge skew safety (PR B, J-208-001).** The frontend degrades safely whichever of Netlify or the Edge deploys first.

1. Capability probe. The new `site-content` Edge answers an owner-authenticated GET with 200 `{ "capabilities": { "lesson_task_copy": true } }` (PUT behaviour unchanged). The old Edge returns 405 for GET (`index.ts:44-46` at `f8a95a3`; Step 0 confirms the `8e89737` source has the same branch and the same registry key set). The owner editor probes on mount. A 405, a network failure or a missing capability means "unsupported": the "Student pages — Lesson tasks" group renders with no inputs and an inline admin note in English: "Editing lesson task text will be available after the next server update. Students already see the built-in text." New keys therefore cannot become dirty.
2. Partitioned save (defense in depth). The commit sends keys from the legacy set (a frozen constant equal to the `f8a95a3` registry keys, pinned by a test against `siteTextBaseline`) and new keys in separate PUTs, legacy first. A rejection of new keys never blocks or discards legacy edits, and drafts of rejected rows stay dirty.
3. Error surfacing. `saveSiteContent` parses the `FunctionsHttpError` response body (`error.context`) to recover `error` and `fieldErrors`. A row-level error renderer handles `<key>` and `<key>.enabled` fields: `<p id="{rowId}-error" role="alert" class="owner-settings-field-error">` inside the row, referenced by `aria-describedby` of the row's EN input. `surfaceErrors` focuses the row's EN input when the only error is row-level. The old Edge's "Unknown content key." for a `lesson_task` key maps to "This text can't be saved yet because the server hasn't been updated. Your other changes were saved." (only when the legacy PUT succeeded; otherwise the generic save error).
4. Hosted order stays Edge first, then Netlify (D-208-8), now as a preference; the frontend is safe under either order.

**A12 Live-region discipline (PR A, J-208-002).**

- Snapshot rule: hidden polite regions render a snapshot string captured at emission time in the then-current language, are cleared to an empty string in the same commit as a language change, and stay empty until the next real event.
- Announce-once rule: visible alert and status regions carry their live role or `aria-live` only for the emission window (until about 1500 ms after the content or its event key first appears); afterwards the attribute is removed and the content stays.
- Net effect: a language switch mutates no live content, so nothing is announced. NVDA verification is optional manual evidence, not a gate.

## 7. Per-key classification and draft Spanish

Rule: Fixed (F) = anything a student operates or that reports system state: button and link labels, status chips, save status, errors and validation, live announcements, form labels and counters, accessible names, headings, modal titles and actions, read-only captions. Editable (E) = prose that explains a policy or process, whose wording the teacher may reasonably want to tune and whose absence of a placeholder makes owner edits safe.

Classes: F fixed functional (not editable or hideable); E owner-editable explanatory (not hideable); U unused (proposed removal, D-208-3); N new fixed key; Q shared `lesson_quiz` key, fixed.

Every Spanish string below is **DRAFT** and unapproved. English strings are byte-exact from `f8a95a3`. Token sets (`{n}`, `{max}`, `{time}`, `{a}` to `{d}`, `{char}`, `{course}`) must match between EN and ES.

Counts: 88 `lesson_task` keys = 71 F + 11 E + 6 U; plus 3 N and 18 Q. That is 109 strings with Spanish drafts (103 if the 6 unused keys are removed).

| # | Key | Class | English (exact) | Español (DRAFT) | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | `lesson_task.chip.not_started` | F | Not started | Sin empezar | |
| 2 | `lesson_task.chip.draft` | F | Draft saved | Borrador guardado | |
| 3 | `lesson_task.chip.submitted` | F | Submitted, awaiting review | Enviada, pendiente de revisión | |
| 4 | `lesson_task.chip.returned` | F | Returned for revision | Devuelta para corregir | |
| 5 | `lesson_task.chip.reviewed` | F | Reviewed | Revisada | |
| 6 | `lesson_task.chip.new` | F | New feedback | Comentarios nuevos | screen-reader text on the chip |
| 7 | `lesson_task.bar.label` | F | Lesson task | Tarea de la lección | accessible name of the task bar |
| 8 | `lesson_task.bar.privacy` | E | Your teacher sees your answers only after you submit. | Tu profesora ve tus respuestas solo después de que las envíes. | |
| 9 | `lesson_task.bar.save_draft` | F | Save draft | Guardar borrador | |
| 10 | `lesson_task.bar.submit` | F | Review and submit | Revisar y enviar | |
| 11 | `lesson_task.bar.resubmit` | F | Revise and resubmit | Corregir y volver a enviar | |
| 12 | `lesson_task.bar.loading` | F | Loading your lesson task… | Cargando tu tarea de la lección… | |
| 13 | `lesson_task.bar.updated` | F | This task was updated. Refresh to see the latest version. | Esta tarea se actualizó. Actualiza la página para ver la versión más reciente. | |
| 14 | `lesson_task.bar.refresh` | F | Refresh | Actualizar | |
| 15 | `lesson_task.save.saving` | F | Saving… | Guardando… | |
| 16 | `lesson_task.save.saved_at` | F | Draft saved at {time} | Borrador guardado a las {time} | {time} formatted in the site language |
| 17 | `lesson_task.save.failed` | F | Couldn't save. Your answers are still here. Try again. | No se pudo guardar. Tus respuestas siguen aquí. Inténtalo de nuevo. | |
| 18 | `lesson_task.save.retry` | F | Retry | Reintentar | |
| 19 | `lesson_task.save.offline` | F | You're offline. We'll try again when you're back online. | No tienes conexión. Lo intentaremos de nuevo cuando vuelvas a estar en línea. | |
| 20 | `lesson_task.save.nothing` | F | Nothing to save yet. | Todavía no hay nada que guardar. | |
| 21 | `lesson_task.save.too_long_draft` | F | This answer is too long to save as a draft (limit 20,000 characters). Shorten it to keep saving. | Esta respuesta es demasiado larga para guardarla como borrador (límite: 20 000 caracteres). Acórtala para seguir guardando. | D-208-6 |
| 22 | `lesson_task.error.load` | F | We couldn't load your lesson task. Please try again. | No pudimos cargar tu tarea de la lección. Inténtalo de nuevo. | |
| 23 | `lesson_task.error.retry` | F | Retry | Reintentar | |
| 24 | `lesson_task.error.submit` | F | Couldn't submit right now. Your answers are safely saved as a draft. Please try again. | No se pudo enviar en este momento. Tus respuestas están guardadas como borrador. Inténtalo de nuevo. | |
| 25 | `lesson_task.error.required` | F | Write an answer for this item before submitting. | Escribe una respuesta para este ejercicio antes de enviar. | |
| 26 | `lesson_task.error.too_long` | F | This answer is {n} characters over the {max}-character limit. | Esta respuesta tiene {n} caracteres más que el límite de {max}. | |
| 27 | `lesson_task.error.too_long_one` | F | This answer is 1 character over the {max}-character limit. | Esta respuesta tiene 1 carácter más que el límite de {max}. | |
| 28 | `lesson_task.error.summary_heading` | F | Fix these answers before submitting | Corrige estas respuestas antes de enviar | |
| 29 | `lesson_task.error.conflict` | F | This task changed since you opened it. Reload to see the latest version, or keep editing. Your changes are still here. | Esta tarea cambió desde que la abriste. Vuelve a cargarla para ver la versión más reciente o sigue editando. Tus cambios siguen aquí. | |
| 30 | `lesson_task.error.reload` | F | Reload task | Volver a cargar la tarea | |
| 31 | `lesson_task.error.keep_editing` | F | Keep editing | Seguir editando | |
| 32 | `lesson_task.error.unavailable` | F | This task isn't available right now. | Esta tarea no está disponible en este momento. | |
| 33 | `lesson_task.readonly.submitted` | F | Submitted: read only until your teacher responds. | Enviada: solo lectura hasta que tu profesora responda. | |
| 34 | `lesson_task.readonly.reviewed` | F | Reviewed: read only. | Revisada: solo lectura. | |
| 35 | `lesson_task.announce.submitted` | F | Submitted. Your answers are now read-only until your teacher responds. | Enviada. Tus respuestas quedan en solo lectura hasta que tu profesora responda. | screen-reader announcement |
| 36 | `lesson_task.announce.recorded` | F | Mark recorded. Waiting for your teacher's review. | Marca guardada. En espera de la revisión de tu profesora. | screen-reader announcement; D-208-4 |
| 37 | `lesson_task.announce.reviewed` | F | Your teacher has reviewed this task. | Tu profesora revisó esta tarea. | screen-reader announcement |
| 38 | `lesson_task.announce.saved_failed` | F | Couldn't save | No se pudo guardar | screen-reader announcement |
| 39 | `lesson_task.field.your_answer` | F | Your answer | Tu respuesta | |
| 40 | `lesson_task.field.hint_es` | E | Write your answer in Spanish | Escribe tu respuesta en español | |
| 41 | `lesson_task.field.hint_en` | E | Write your answer in English | Escribe tu respuesta en inglés | |
| 42 | `lesson_task.field.hint_mixed` | E | Write your answer in Spanish and English as the prompt asks | Escribe tu respuesta en español y en inglés, según lo pida el enunciado | |
| 43 | `lesson_task.field.counter_over` | F | {n} over the limit | {n} por encima del límite | |
| 44 | `lesson_task.field.counter_80` | F | 80% of the character limit used | Usaste el 80 % del límite de caracteres | screen-reader announcement |
| 45 | `lesson_task.field.counter_95` | F | 95% of the character limit used | Usaste el 95 % del límite de caracteres | screen-reader announcement |
| 46 | `lesson_task.field.counter_100` | F | Character limit reached | Llegaste al límite de caracteres | screen-reader announcement |
| 47 | `lesson_task.field.counter_over_announce` | F | Over the limit by {n} characters | Te pasaste del límite por {n} caracteres | screen-reader announcement |
| 48 | `lesson_task.field.counter_over_announce_one` | F | Over the limit by 1 character | Te pasaste del límite por 1 carácter | screen-reader announcement |
| 49 | `lesson_task.field.practice_legend` | F | Practice, part {n} | Práctica, parte {n} | |
| 50 | `lesson_task.accent.toolbar` | F | Insert accented characters | Insertar caracteres con acento | accessible name |
| 51 | `lesson_task.accent.insert` | F | Insert {char} | Insertar {char} | accessible name |
| 52 | `lesson_task.practice.scenario` | U | Scenario | Situación | unused |
| 53 | `lesson_task.practice.roles` | U | Your role(s) | Tu papel o tus papeles | unused |
| 54 | `lesson_task.practice.write` | U | What to write | Qué escribir | unused |
| 55 | `lesson_task.practice.format` | U | Length and format | Extensión y formato | unused |
| 56 | `lesson_task.practice.register` | U | Register and dialect | Registro y variante | unused |
| 57 | `lesson_task.practice.phrases` | U | Use these phrases | Usa estas frases | unused |
| 58 | `lesson_task.practice.checklist` | F | Success checklist | Lista de verificación | |
| 59 | `lesson_task.modal.submit_title` | F | Submit final answers | Enviar respuestas finales | |
| 60 | `lesson_task.modal.submit_counts` | F | {a} of {b} translation tasks answered. {c} of {d} practice fields answered. | {a} de {b} tareas de traducción respondidas. {c} de {d} campos de práctica respondidos. | |
| 61 | `lesson_task.modal.submit_warning` | F | Once you submit, your answers become read-only until your teacher responds. | Cuando envíes, tus respuestas quedarán en solo lectura hasta que tu profesora responda. | borderline, kept fixed (D-208-1) |
| 62 | `lesson_task.modal.submit_confirm` | F | Submit final answers | Enviar respuestas finales | |
| 63 | `lesson_task.modal.keep_editing` | F | Keep editing | Seguir editando | |
| 64 | `lesson_task.leave.title` | F | Leave without saving? | ¿Salir sin guardar? | |
| 65 | `lesson_task.leave.body` | F | We couldn't save your latest changes. If you leave now they may be lost. | No pudimos guardar tus últimos cambios. Si sales ahora, podrías perderlos. | borderline, kept fixed |
| 66 | `lesson_task.leave.stay` | F | Stay and try saving again | Quedarme e intentar guardar de nuevo | |
| 67 | `lesson_task.leave.leave` | F | Leave without saving | Salir sin guardar | |
| 68 | `lesson_task.feedback.heading` | F | Feedback from your teacher | Comentarios de tu profesora | |
| 69 | `lesson_task.feedback.earlier` | F | Earlier feedback | Comentarios anteriores | |
| 70 | `lesson_task.feedback.score` | F | Score: {n} / 100 | Calificación: {n} / 100 | |
| 71 | `lesson_task.page.back` | F | ← Back to {course} | ← Volver a {course} | |
| 72 | `lesson_task.page.translation_heading` | F | Translation tasks | Tareas de traducción | |
| 73 | `lesson_task.page.practice_heading` | F | Practice | Práctica | |
| 74 | `lesson_task.link.not_started` | F | Open task | Abrir tarea | |
| 75 | `lesson_task.link.draft` | F | Continue task | Continuar tarea | |
| 76 | `lesson_task.link.returned` | F | Revise and resubmit | Corregir y volver a enviar | |
| 77 | `lesson_task.link.submitted` | F | View your submission | Ver tu entrega | |
| 78 | `lesson_task.link.reviewed` | F | View feedback | Ver comentarios | |
| 79 | `lesson_task.card.waiting` | F | Waiting for teacher review | En espera de la revisión de tu profesora | |
| 80 | `lesson_task.completion.mark_recorded` | F | Mark recorded | Marca guardada | D-208-4 |
| 81 | `lesson_task.completion.mark_recorded_short` | F | Mark recorded | Marca guardada | |
| 82 | `lesson_task.completion.not_started_unmarked` | E | This lesson completes after you mark it complete, submit your task, and your teacher reviews it. | Esta lección se completa cuando la marques como completada, envíes tu tarea y tu profesora la revise. | |
| 83 | `lesson_task.completion.not_started_recorded` | E | You've marked this lesson. Submit your task next. It completes after your teacher reviews it. | Ya marcaste esta lección. Ahora envía tu tarea. Se completa cuando tu profesora la revise. | |
| 84 | `lesson_task.completion.submitted_unmarked` | E | Your task is waiting for teacher review. Mark this lesson complete now and it finishes once your teacher reviews your task. | Tu tarea está en espera de la revisión de tu profesora. Marca esta lección como completada ahora y terminará cuando tu profesora revise tu tarea. | |
| 85 | `lesson_task.completion.submitted_recorded` | E | Waiting for teacher review. Your lesson will complete automatically once your teacher reviews your task. | En espera de la revisión de tu profesora. Tu lección se completará automáticamente cuando tu profesora revise tu tarea. | |
| 86 | `lesson_task.completion.returned_unmarked` | E | Your teacher returned your task. Revise and resubmit. The lesson completes after the next review. | Tu profesora te devolvió la tarea. Corrígela y vuelve a enviarla. La lección se completa después de la próxima revisión. | |
| 87 | `lesson_task.completion.returned_recorded` | E | You've marked this lesson. Revise and resubmit your task. It completes after your teacher reviews it. | Ya marcaste esta lección. Corrige tu tarea y vuelve a enviarla. Se completa cuando tu profesora la revise. | |
| 88 | `lesson_task.completion.reviewed_unmarked` | E | Your teacher reviewed your task. Mark this lesson complete to finish. | Tu profesora revisó tu tarea. Marca esta lección como completada para terminar. | |
| N1 | `lesson_task.chip.new_marker` | N | New | Nuevo | visible marker next to the chip glyph; replaces hard-coded "▪ New" text (glyph stays) |
| N2 | `lesson_task.page.course_fallback` | N | your course | tu curso | replaces hard-coded 'your course' at `LearnTaskPage.tsx:46` |
| N3 | `lesson_task.modal.close` | N | Close modal | Cerrar ventana | Close button accessible name on the task submit and leave modals (R2) |
| Q1 | `lesson_quiz.leave.title` | Q | Leave this quiz? | ¿Salir de este cuestionario? | |
| Q2 | `lesson_quiz.leave.body` | Q | Your answers haven't been submitted and will be lost. | Tus respuestas no se han enviado y se perderán. | |
| Q3 | `lesson_quiz.leave.stay` | Q | Stay on quiz | Seguir en el cuestionario | |
| Q4 | `lesson_quiz.leave.leave` | Q | Leave quiz | Salir del cuestionario | |
| Q5 | `lesson_quiz.leave.combined.title` | Q | Leave this page? | ¿Salir de esta página? | |
| Q6 | `lesson_quiz.leave.combined.quiz_line` | Q | Your quiz answers haven't been submitted and will be lost. | Tus respuestas del cuestionario no se han enviado y se perderán. | |
| Q7 | `lesson_quiz.leave.combined.stay` | Q | Stay on page | Quedarme en la página | |
| Q8 | `lesson_quiz.leave.combined.leave` | Q | Leave page | Salir de la página | |
| Q9 | `lesson_quiz.completion.open_unmarked` | Q | This lesson completes after you mark it complete and pass the quiz. | Esta lección se completa cuando la marques como completada y apruebes el cuestionario. | |
| Q10 | `lesson_quiz.completion.open_recorded` | Q | You've marked this lesson. Pass the quiz to finish it. | Ya marcaste esta lección. Aprueba el cuestionario para terminarla. | |
| Q11 | `lesson_quiz.completion.pending_unmarked` | Q | Your quiz attempt is waiting for your teacher to grade. Mark this lesson complete now and it finishes once your quiz is graded and passed. | Tu intento del cuestionario está esperando la calificación de tu profesora. Marca esta lección como completada ahora y terminará cuando tu cuestionario esté calificado y aprobado. | |
| Q12 | `lesson_quiz.completion.pending_recorded` | Q | Waiting for your teacher to grade your quiz attempt. Your lesson will complete automatically if it's graded as a pass. | Esperando que tu profesora califique tu intento del cuestionario. Tu lección se completará automáticamente si lo califica como aprobado. | |
| Q13 | `lesson_quiz.completion.exhausted_unmarked` | Q | You've used all your quiz attempts without reaching the pass mark. Ask your teacher about next steps. | Usaste todos tus intentos del cuestionario sin alcanzar la nota mínima. Pregúntale a tu profesora cuáles son los próximos pasos. | |
| Q14 | `lesson_quiz.completion.exhausted_recorded` | Q | You've marked this lesson, but you've used all your quiz attempts without reaching the pass mark. Ask your teacher about next steps. | Ya marcaste esta lección, pero usaste todos tus intentos del cuestionario sin alcanzar la nota mínima. Pregúntale a tu profesora cuáles son los próximos pasos. | |
| Q15 | `lesson_quiz.completion.task_tail_notsubmitted` | Q | Your task also needs to be submitted and reviewed. | También tienes que enviar tu tarea y tu profesora tiene que revisarla. | |
| Q16 | `lesson_quiz.completion.task_tail_submitted` | Q | Your task is also waiting for review. | Tu tarea también está en espera de revisión. | |
| Q17 | `lesson_quiz.completion.task_tail_returned` | Q | Your teacher also returned your task for revision. | Tu profesora también te devolvió la tarea para que la corrijas. | |
| Q18 | `lesson_quiz.completion.passed_no_task` | Q | You passed the quiz. Mark this lesson complete to finish. | Aprobaste el cuestionario. Marca esta lección como completada para terminar. | |

The review document numbers the same strings 1 to 109 in reading order by where students see them (rows 1 to 92 fixed, 93 to 103 editable, 104 to 109 unused). Its numbering differs from the `#` column above; it is the numbering Lizbeth uses when she replies.

## 8. Ordered work

**Step 0 (every PR).**

1. Fetch origin; record the base SHA. If `main` moved past `f8a95a3`, re-verify every cited `file:line` and trigger the stale-plan check on a material change.
2. Enumerate every English `lesson_quiz` render site (R1).
3. Run `rg -n "lessonTaskText\(|lessonQuizText\(" src --glob "!src/__tests__/**"` and record the counts.
4. Record the vitest and e2e baseline per parent plan 11.3.

**Step 1 (Scribe, now, as part of this plan).** The Lizbeth review document (`docs/plans/lizbeth-spanish-208-es-review.md`) is written with this plan. The orchestrator sends it to Rob for Lizbeth. Her decision is recorded in that document by Scribe (approved rows, amended rows with her wording, date). Her amendments flow into the PRs.

**PR A `208a` "Fixed bilingual lesson-task copy"** (T1; base `main`; Refs #208; no Edge, no registry, no migration).

- Scope: A1 to A6, A10 and A12; R1 and R2; the 3 new fixed keys; removal of the 6 unused `practice.*` keys (if D-208-3 is approved); `formatTime` locale; the 20,000 limit per D-208-6; the CSS wrap rule.
- The 11 editable keys render fixed bilingual in this PR (interim; English still byte-identical).
- Tests: see section 10.
- Shippable alone: Netlify deploy only (separate approval).

**PR B `208b` "Owner-editable lesson-task explanations"** (T1; base `main` after PR A merges, never stacked; Closes #208).

- Scope: A7 to A9 and A11 (capability probe, partitioned save, `FunctionsHttpError` body parsing, row-level error renderer, Edge GET capability response); registry group and 11 entries; authorization changes; resolver non-hideable guard.
- Render the 11 through `SiteText` or the hook with lang marking and stable ids (`hintId`, `COMPLETION_NOTE_ID`).
- Editor group, non-hideable row variant, helper text.
- `siteTextBaseline` fixture and registry test updates (documented intentional changes). Edge local integration tests.

**Merge gate (both PRs).** PRs may be opened while the Spanish is DRAFT. Neither merges until Lizbeth's approval is recorded in `docs/plans/lizbeth-spanish-208-es-review.md` and the code ES values equal the approved column (Verifier diffs code against the document). Rob merges; no push to `main`.

**Hosted actions** (separate explicit approvals per parent D-28).

1. After PR A merges: Netlify deploy.
2. After PR B merges: preferred order is the `site-content` Edge redeploy to production first (it accepts a superset of keys and adds the GET capability response), then Netlify deploy. The order is a preference, not a safety dependency: the PR B frontend probes the Edge, shows an "unavailable until the next server update" note while the Edge is old, and saves legacy keys separately from new keys (A11). Under the reverse order, owners cannot edit the new group until the Edge is redeployed; no data is lost.
3. Optional read-only production query before the Edge redeploy (D-208-9).

**Follow-ups.** After approval the orchestrator files, via `gh`, an issue for the remaining `lesson_quiz.*` strings and other English student-surface strings (D-208-5). Include two further hard-coded English strings found in review: `LearnDetailPage.tsx:623` "Lesson marked complete." and `QuizRevealView.tsx:54` / `QuizResultsView.tsx:32` "Question {n}".

## 9. Interfaces and data

- `lessonTaskText(key, lang, vars?)` signature change; callers updated in PR A.
- `SubmitFieldError` gains `key` and `vars`; `message` is removed or derived at render.
- `CounterState.announceText` and `overText` are replaced by descriptors.
- `composeCompletionNote` returns a structured result.
- `Modal` gains optional `closeLabel` and `lang` props; defaults preserve current behaviour.
- `SiteContentEntry` gains optional `placeholders?: readonly string[]` and `hideable?: boolean` (default true; existing entries unchanged).
- New group id `lesson_task`.
- Data: no migration. New `site_content` rows (key `lesson_task.*`) are created only by owner edits after PR B and the Edge redeploy. Existing rows are untouched. Rollback never deletes rows.

## 10. Acceptance and validation

**Per PR (parent 11.1).** `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`; full `npx vitest run` on a freshly reset mirror stack with no new failures versus the recorded baseline; a RED test shown failing before and passing after (both runs recorded); Verifier PASS; Browser Validator PASS; PR against `main` with Refs or Closes #208; no merge.

**RED tests, PR A** (each fails on `f8a95a3`):

1. `lessonTaskCopy` parity: every key has non-empty `en` and `es`; EN values byte-identical to a fixture snapshot of `f8a95a3`'s 88 values (less removed keys); the set of `{tokens}` in `es` equals that in `en` for every key; same for the 18 shared quiz keys and the 3 new keys.
2. `lessonTaskText(key,'es',vars)` interpolates `{n}`, `{max}`, `{time}`, `{a}` to `{d}`, `{char}`, `{course}`.
3. `LessonTaskBar` rendered with `PublicContentContext` language `es` shows "Guardar borrador" and "Revisar y enviar" (approved strings); with no provider, English is unchanged.
4. Language switch: render with an error summary in EN, switch the context to `es`, assert summary and inline field errors re-render in ES, textarea values intact, and `document.activeElement` unchanged.
   4b. Live regions (J-208-002): with a saved draft and an error summary shown, switch the context language. The hidden polite region text becomes `''` (not the ES string); the visible save line shows ES; ErrorSummary shows ES and no longer has `role="alert"` after the emission window; a new save after the switch announces in ES.
5. Chip: `LessonTaskStatusChip` in `es` shows the ES word and visible marker and sr-only ES text; under an `/admin` path it is English; no literal chip words remain in `lessonTaskStatus.ts` (source assertion).
6. Logic: `validateForSubmit` and `serverFieldErrors` return descriptors; `counterState` returns descriptors; `composeCompletionNote` returns the structured kinds for task-only, quiz-outstanding with tails, passed-with-task, and null cases.
7. Dead-key guard: every `LessonTaskCopyKey` is referenced in product source (fails today on the six practice keys and six chip keys).
8. Modal `closeLabel`: the task submit modal and leave guard Close button accessible name is ES under `es`; admin modals still "Close modal".
9. Quiz lang marking (R1, J-208-003), a DOM language-map check on a quiz+task lesson and a `/learn` quiz card under `es`: for every known Spanish fixed string (text or `aria-label`) the closest `[lang]` ancestor-or-self is `es`; for every known English `lesson_quiz` string it is `en`; under `en` no lang attributes are added.
10. `formatTime` under `es` uses the Spanish locale; the too-long draft message shows no English digit grouping under `es`.
11. CSS: the cssCascade and one-selector-per-line guard passes; the wrap selectors exist.

**RED tests, PR B:**

1. Registry: 11 `lesson_task` entries in group `lesson_task` with `default.en === LESSON_TASK_COPY[key].en` and `default.es === LESSON_TASK_COPY[key].es`, `placeholders` `[]` and `hideable` false; baseline fixture updated; ES-default list is now the six `signin` keys plus the 11 (intentional, documented); group titles include "Student pages — Lesson tasks"; the maxLength rule holds for EN and ES.
2. Authorization: `{n}` in en or es of a `lesson_task` key gives a field error with the one-token message; two tokens give the several-token message; a bare "{" is accepted; a legacy key (for example `signin.tagline_full`) with `{n}` is still accepted; `enabled:false` on a `lesson_task` key gives a `<key>.enabled` field error; a synthetic-fixture test covers the required and unsupported branch.
3. Resolver: `hideable:false` ignores a stored `enabled=false` row; a stored invalid-token value falls back to the built-in default; ES order is unchanged for legacy keys.
4. Hook: owner override EN and ES applies to editable keys and is ignored for fixed keys even when a row exists; `lang="en"` marking for custom EN shown under `es`.
5. Editor: the group renders 11 rows, no "Shown on site" control on them, the "Always shown" note, provenance tags; entering `{n}` and saving opens the group, focuses the field, shows the inline alert, and sends nothing.
6. Edge (local mirror, live): owner PUT for `lesson_task.bar.privacy` succeeds; PUT with `{n}` gives 422 `fieldErrors`; PUT `enabled:false` gives 422; unknown key gives 422; non-owner gives 403. After changing `src/lib` files imported by the Edge function, restart the edge runtime (`docker restart supabase_edge_runtime_lizbeth_spanish`) or do a full `supabase stop` and `start` in the mirror.
7. Probe (A11): a 405 probe response renders the group's unsupported note and no inputs; a 200 probe with the capability renders the 11 rows.
8. Partitioned save (A11): the legacy PUT succeeds and the new-key PUT returns 422 "Unknown content key." Result: the legacy key is saved; a row-level inline alert appears on the new row; its draft is preserved; focus lands on that row's EN input.
9. `saveSiteContent` recovers `error` and `fieldErrors` from a `FunctionsHttpError` body (fails on `f8a95a3`).

**Browser UI dialog policy (required).** No `alert`, `confirm`, `prompt`, `window.alert/confirm/prompt`, or `beforeunload` prompts. The submit and leave confirmations stay on the app-owned accessible Modal (`src/components/Modal.tsx`) with Escape and Close and focus return. Owner validation is inline (field error with `role="alert"`, `aria-invalid`, `aria-describedby`, focus on the first invalid field). Verification, every PR:

- Deterministic source scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits.
- Each new or changed spec registers a failing `page.on('dialog')` listener.
- Modal keyboard and focus checks (Escape, Close, focus return).

**Commands** (mirror; PowerShell):

```powershell
cd H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run   # per-file copies from the PR worktree; never robocopy /MIR; keep the mirror's local CSP patch and .env.local with VITE Supabase URL http://127.0.0.1:64321
npx supabase start ; npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish   # first request after reset may 502
$env:SUPABASE_API_URL='http://127.0.0.1:64321'; $env:SUPABASE_DB_PORT='64322'
npx vite --host 127.0.0.1 --port 5183 --strictPort   # any free 518x
$env:E2E_BASE_URL='http://127.0.0.1:5183'; npx playwright test src/__tests__/e2e/issue208-*.spec.ts --project=chromium
```

**Browser validation brief** (`browser_ui_validation`).

- Launch and readiness: the mirror commands above; ready when `http://127.0.0.1:<port>/` serves the sign-in card ("Open my journal" visible).
- Base URL: `http://127.0.0.1:<port>` (`E2E_BASE_URL` set to the same).
- Fixtures and reset: `db reset` plus seed, then the docker restart. Students via `src/__tests__/e2e/isolated-accounts.ts` `provisionIsolatedStudent` (disposable, removed in `afterAll`). Beginner weeks 3 and 4 task lessons as in `issue179c-student-task-form.spec.ts`. At least one quiz+task lesson with the quiz outstanding and one with the quiz passed. Task states: draft, submitted, returned_for_revision, reviewed with unseen feedback. Owner `owner@test.local` / `password` for owner actions only. Owner journeys model on `issue227-site-copy-preview.spec.ts`; `afterAll` deletes `lesson_task.%` `site_content` rows through a loopback-guarded cleanup. Never mutate seeded credentials.
- Viewports: 1440x900 and 390x844 for every journey; 320-wide spot check for J1, J2 and J5 (including the inline quiet buttons in the save line and updated note).
- New specs: `src/__tests__/e2e/issue208-lesson-task-copy-es.spec.ts` (PR A), `src/__tests__/e2e/issue208-owner-lesson-task-copy.spec.ts` (PR B) and `src/__tests__/e2e/issue208-owner-old-edge-skew.spec.ts` (PR B, J11).
- Evidence: screenshots per viewport and language under `browser-validation-artifacts/issue208/`.

Journeys and visible outcomes:

- **J1 (PR A)** Student on Español: `/learn` cards (link, chip, marker), standalone task page, Roadmap bar. Spanish throughout; no clipped or truncated button text; `scrollWidth <= clientWidth` at 1440/390/320; long labels wrap in full-width stacked buttons at 390/320; `html lang="es"`.
- **J2 (PR A)** Quiz+task lesson on Español: combined leave modal (title, quiz_line, stay, leave) fully Spanish; quiz-composed completion note Spanish in open, pending, exhausted and passed states with task tails; every remaining English quiz node (panel branches, quiz modal, `/learn` quiz link and chip) carries `lang="en"` on its own element or a quiz-only container; the `AccentStrip` inside the quiz has toolbar `en` and each insert button (closest lang) `es`; no lang attributes added when English.
- **J3 (PR A, replaced by J-208-002)** Language switch with a saved draft, a counter at 80% and an error summary older than the emission window (header toggle at 1440; MobileNavPanel at 390). A MutationObserver installed with `page.addInitScript` records text and attribute mutations inside any element with `aria-live`, `role="status"` or `role="alert"`. Outcomes: zero mutations that add non-empty text inside a live container during the switch (clearing is allowed); `activeElement` unchanged; textarea values intact; visible text, including the summary and inline errors, in the new language.
- **J4 (PR A)** Submit and leave modals in Spanish: Escape and Close dismiss; Close accessible name is Spanish; focus returns to the trigger or bar; zero dialog events.
- **J5 (PR A)** Save failure (route-abort the save), offline and conflict states in Spanish: conflict actions stack; no overflow at 320; saved time in Spanish locale; too-long draft message with Spanish digit grouping.
- **J6 (PR A)** English regression: a student on English sees byte-identical existing strings (Save draft, Review and submit, privacy note, chips).
- **J7 (PR A and B)** Admin pages with the chip (`/admin/submissions`, submission detail) stay English while localStorage holds `es`.
- **J8 (PR B)** Owner opens "Student pages — Lesson tasks": 11 rows; no "Shown on site" control; "Always shown" note; provenance tags (Built-in default / Built-in Spanish default); completion rows use the exact key names (`data-site-key`).
- **J9 (PR B)** Owner enters `{n}` in an editable key and saves: group opens; focus on the first invalid input; inline English alert; `aria-invalid` and `aria-describedby` set; nothing saved (no network PUT or a 422). A bare "{" saves. Correcting clears and saves. A legacy key containing braces stays savable.
- **J10 (PR B)** Owner saves custom EN and ES for `lesson_task.bar.privacy` and a completion row: a Spanish student sees the custom ES; with ES blank and custom EN, sees the EN with `lang="en"`; Reset to default restores the built-in text in both languages; on a quiz+task lesson with the quiz outstanding the fixed quiz note shows; after the quiz is passed with the task outstanding the edited task note shows.
- **J11 (PR B, new spec `issue208-owner-old-edge-skew.spec.ts`, 1440 and 390)** New frontend against old-Edge behaviour, emulated with `page.route` on `**/functions/v1/site-content`: GET returns 405 `{"error":"Method not allowed. Use PUT to save site content."}`; a PUT containing any `lesson_task.*` key returns 422 `{"error":"Validation failed.","fieldErrors":[{"field":"<key>","message":"Unknown content key."}]}`; other PUTs continue to the real local Edge. Outcomes: the unsupported note is shown, no `lesson_task` inputs render, and a legacy key edit saves. With the probe forced supported but PUT rejecting, a mixed save persists the legacy key (verified via `public_site_content`) and shows the row-level alert. No native dialog.
- **Live skew run (Browser Validator, once).** The mirror Edge is served from the `f8a95a3` tree (unchanged mirror `src/lib` and `supabase/functions`) while vite serves the PR B frontend from the PR worktree with VITE Supabase URL `http://127.0.0.1:64321`. Same outcomes as J11.

## 11. Judge route

Per `docs/JUDGE-CONTRACT.md`, shadow policy. No judge pass has been run and no judge finding is recorded here.

| Checkpoint | Requiredness | Note |
| --- | --- | --- |
| PLAN_DUCK | Eligible on this draft before approval | The orchestrator runs it. |
| CODE_REVIEW | Recommended for PR B | Shared client and Edge validation at a trust boundary. |
| VERIFICATION_CHALLENGE | Optional for PR A | Descriptor refactor coverage. |
| VISUAL_REVIEW | Not required | Compact route, not brand-critical. |

Respect the 2/4 call caps. Deterministic failures dominate. Finding IDs, if any are produced later, flow into the engineering job brief and the Verifier gate.

## 12. Risks and rollback

| ID | Risk | Mitigation |
| --- | --- | --- |
| R-1 | Spanish ships before approval | Merge gate tied to the recorded approval; Verifier diffs code ES against the review document. |
| R-2 | English regression for English students | EN byte-identical fixture test; existing EN tests unchanged; J6. |
| R-3 | Netlify deployed before the Edge redeploy for PR B | Contained by A11 (probe, partitioned save, row-level errors, R-10); no data loss. Runbook order stays Edge first as a preference. |
| R-4 | Owner text breaks interpolation | None of the 11 keys has placeholders; opt-in validation rejects closed tokens in client and Edge; client render guard falls back to the default. |
| R-5 | New validation blocks legacy production rows | Validation is opt-in only on entries that declare `placeholders` or `hideable: false`; legacy keys untouched; test with a legacy key containing braces. |
| R-6 | Descriptor refactor regresses validation or announcement behaviour (#209/#210 work in `useLessonTask`) | RED tests 4 and 6; existing issue179c, issue209 and issue210 specs green; T2 escalation rules. |
| R-7 | Mixed-language pages remain (quiz panel, other student keys) | Disclosed non-goal; `lang="en"` marking (R1); follow-up issue. |
| R-8 | Spanish text overflow at 390/320 | Wrap rule; J1 and J5 bounding and `scrollWidth` checks. |
| R-9 | Stale base | Step 0; stale-plan conditions (section 14). |
| R-10 | Frontend ahead of Edge (old-Edge skew; the hosted Edge was last deployed from `8e89737`) | Contained by the capability probe, partitioned save and row-level errors (A11); RED tests 7 to 9, J11 and the live skew run. |

Rollback: PR A is a revert (no data). PR B: revert the frontend and redeploy the previous Edge build. Any `lesson_task.*` rows saved in the meantime stay in `site_content` and are ignored by older code (`getSiteContentEntry` filters unknown keys); never delete rows. No migration, so no database rollback.

## 13. Decisions for the user

Each needs an explicit user answer. Recommendation given; none is settled until answered.

- **D-208-1 Classification.** 71 fixed functional, 11 owner-editable explanatory (`lesson_task.bar.privacy`, the 3 field hints, the 7 completion notes), 6 unused. Borderline items kept fixed: `modal.submit_warning` (pre-commit consequence disclosure), `leave.body` (data-loss warning), `card.waiting` and `bar.updated` (status), `save.too_long_draft` and `error.conflict` (errors). Recommend: as classified.
- **D-208-2 Non-hideable editable keys.** The 11 editable keys have no switch; blank means default; the server rejects `enabled:false`. Recommend: yes (each carries information a student needs: response language, completion rule, privacy; hiding a hint would also orphan `aria-describedby`).
- **D-208-3 Unused and duplicate keys.** Remove the 6 unused `practice.*` keys and make `chip.*` the single chip vocabulary (remove the duplicate literals). Recommend: yes. Their ES drafts appear in the review appendix only in case the answer is no.
- **D-208-4 Register and terms.** tú; "tu profesora"; "tarea" for task (feminine agreement, for example "Enviada"); "cuestionario" for quiz (alternative "prueba"); avoid "Marca registrada" (means trademark) and use "Marca guardada". Recommend: as drafted; Lizbeth may change.
- **D-208-5 Remaining English.** The remaining `lesson_quiz.*` strings and other English student-surface strings are out of scope; file one follow-up issue. Recommend: yes.
- **D-208-6 The 20,000 draft limit.** Per-language literal (EN "20,000" unchanged, ES "20 000") versus `Intl.NumberFormat` with a new placeholder. Recommend: per-language literal (no new placeholder; EN byte-identical).
- **D-208-7 Merge gating.** PRs may open with DRAFT Spanish; no merge until Lizbeth's approval is recorded and applied. Recommend: yes.
- **D-208-8 Hosted order for PR B.** Edge `site-content` redeploy first, then Netlify; each a separate approval (parent D-28). Edge first is a preference; the frontend is safe under either order (A11). Recommend: yes.
- **D-208-9 Optional read-only production query** before the Edge redeploy, run by Rob. Nothing is changed. Recommend: yes.
  - `select count(*) from public.site_content where key like 'lesson_task.%';` (expect 0)
  - `select key, enabled, value ? 'en' as has_en, value ? 'es' as has_es, updated_at from public.site_content order by key;` (inventory of owner-customized rows)
- **D-208-10 Saved-time locale** follows the site language (`formatTime` 'es' or 'en') rather than the browser locale. Recommend: yes.
- **D-208-11 Final English admin wording** for the new group (labels, "Appears on" text, "Always shown" note, error messages) as proposed. Recommend: accept as drafted; T1 may polish within plain, English, distinct.

Assumptions (safe): tú register and "tu profesora" (`signInCopy` precedent); Latin-American-neutral Spanish; Lizbeth is the teacher students write to; `main` remains `f8a95a3` or is re-verified at Step 0.

## 14. Approval gate and handoff

**Approvals required.**

1. Explicit user approval of this plan.
2. Answers to D-208-1 to D-208-11.
3. Lizbeth's approval of the Spanish (review document) before any merge.
4. Separate approvals for each hosted action (Netlify after A; Edge redeploy then Netlify after B).
5. No commit, push to `main`, merge or deploy without explicit instruction.

T1 does not start until item 1 is recorded here by Scribe on the lead's relay of explicit user approval.

**Stale-plan conditions.** Re-plan if any of these occurs:

- `origin/main` moves past `f8a95a3` with changes to any cited file: `lessonTaskCopy.ts`, `lessonQuizCopy.ts`, `lessonTaskLogic.ts`, `lessonQuizLogic.ts`, `useLessonTask.tsx`, `LessonTask*.tsx`, `QuizPanel.tsx`, `Modal.tsx`, `siteContent*.ts`, `SiteContentFields.tsx`, `PublicContentContext.tsx`, `site-content/index.ts`, `siteContentRegistry.test.ts`, `siteTextBaseline.ts`.
- A new `lesson_task` key is added.
- Lizbeth's amendments add or remove strings.
- Any decision answer differs from the recommendation in a way that changes PR scope.

**Downstream owners.** Engineering fleet (PR A, PR B); Scribe (review document and recording Lizbeth's approval); orchestrator (`gh` follow-up issue, hosted actions after approval).
