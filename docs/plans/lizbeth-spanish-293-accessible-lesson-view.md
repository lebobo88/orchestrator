# Plan: Lizbeth Spanish #293, accessible online lesson view on /learn (PR 293a, PR 293b)

- Plan id: `lizbeth-spanish-293-accessible-lesson-view`
- Task id: `lizbeth-293-accessible-lesson-view`
- Status: **APPROVED 2026-10-17.** The user stated, verbatim: "Approve the plan for 293 and proceed as planned for 290, 291, 276, and 277." Open decisions D-293-1 through D-293-15 are adopted at their recommendations, including D-293-15 (warning, not block, for images without alt text). Hosted actions (migration apply, Edge deploy, Netlify deploy, any production DB write) still each require separate explicit approval; production is live and nothing may be lost. Written 2026-10-17, Revision 1 applied 2026-10-17.
- Parent: approved plan `docs/plans/lizbeth-spanish-196-per-lesson-handouts.md`, decision D-196-15 option B ("ship handouts with honest disclosure and file a follow-up issue for an accessible authored lesson view"). This plan is that follow-up (issue #293). It also implements the option-A strings that plan pre-approved for the moment an online lesson exists (196 plan section 4.13, last paragraph).
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team.
- Target: `lebobo88/lizbeth-spanish` at `main`. Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013` at `3594188fcabf842823e6eadc81128d102781ee7f` (`3594188`, the worktree HEAD of the refreshed read-only checkout). This base includes #294 (#196 PR 8c, the handouts UI), #286 (task copy) and #269 (gate). The first draft was written against `767de59`. The live remote SHA was not verified. Every `file:line` below refers to that checkout and must be re-verified at Step 0.
- Evidence labels: Observed (read in code, an approved plan or cited documentation), Inference (derived from Observed facts, with the test that verifies it), Unknown (not established).
- Design: Standard profile, reviewed `DESIGN_HANDOFF` revision 2, review verdict PASS (section 4), plus the Revision 1 design deltas listed in section 4.
- Judge route: Shadow (advisory), section 9.

**History.** Design review 1 returned NEEDS_REVISION (DR-01 focus obscured by the fixed Aa trigger; DR-02 content parity per lesson kind; DR-03 Spanish drafts must stay inert; DR-04 state precedence; DR-05 title language and WCAG 3.1.2; minor DR-06 to DR-12). Revision 2 resolved every item and the independent re-review verdict is PASS. The re-review left five engineering items (E1 to E5), which are carried into sections 4.3, 4.7, 4.8 and 12. E4 (the kind mapping) is resolved by the merged #294 code (4.6).

**Revision 1 (PLAN_DUCK J-293-001..007, shadow, Codex).** One revision applied in place across every affected section; no superseded text is kept. Planner re-checked each finding against the code at the new base and accepted all seven. The base moved from `767de59` to `3594188`, which includes #294 (#196 PR 8c), #286 and #269. The plan was later approved on 2026-10-17 (see the Status line). Three behavior changes (capability gating, image rendering, unsafe media value as plain text) and one reconciliation (the Back control reuse) are design deltas from PLAN_DUCK Revision 1, not re-reviewed by design-reviewer; the Browser Validator verifies them. No new design review is claimed.

- J-293-001 (rebase; #196 PR 8c merged), ACCEPTED. Every "8c not merged" statement and the D-293-7 fallback are removed; D-293-7 is resolved: 293b builds on #294 and includes the handout-row "Read online" link and the copy switches, under the capability gate of J-293-004. The online view imports the exported helpers of `src/services/lessonHandoutContent.ts` (`printableCards`, `printablePrompts`, `printableMedia`, `slotTitle`) instead of a new shared model module and keeps no second kind matrix; the RPC's server-side kind list must equal `CARD_KINDS`, asserted by a test. The Back control reuses the `lesson_task.page.back` and `lesson_task.page.course_fallback` pattern from #286, so J5 shows "← Back to your course". Sections touched: header, 2, 3 (F1, F7, F13, new 3.3), 4 (4.2, 4.6, 4.8, 4.14), 5.1, 5.2, 6, 7, 10 (R8), 11, 12 (D-293-7), 13.
- J-293-002 (recursive server projection), ACCEPTED. The RPC projects each TipTap body recursively through a node, mark and attribute allowlist with an internal helper; nothing from `content` is passed through; unknown nodes are unwrapped; depth and node-count caps apply; the client renderer applies the same allowlist again. New RED nested-leak fixtures with a recursive key walk. Sections touched: 4 (4.9, 4.13, 4.14), 5.1, 6, 7, 9, 10 (R1), 12 (D-293-1).
- J-293-003 (images without alt text), ACCEPTED. The student renderer shows an image only for an absolute https source; an empty or missing alt adds a visible note after the image; any other source shows a visible "can't be shown here" note in its place. The owner gets an English-only warning (Handouts tab lesson panel and Content tab), not a publish blocker (D-293-15). The gap against WCAG 1.1.1 is recorded with 3.1.2 as a residual gap, and nothing may claim full conformance. Sections touched: standing constraints, 1, 2, 4 (4.1, 4.8, 4.9, 4.14, 4.16), 6, 7, 8, 10 (R12, H0 q4), 11, 12 (D-293-15).
- J-293-004 (truthful, capability-gated copy), ACCEPTED. "No runtime capability probe" is removed everywhere. The 293a migration adds `get_lesson_read_capability()` (D-293-14). One cached client call per page load gates the card link, the handout-row link, the student note switch and the owner disclosure switch; any error or pending call keeps the shipped strings and shows no link. The lesson page itself still shows J7 on a missing read RPC. Skew runs S1, S2 and the new S3 (rollback) assert exact strings. Sections touched: 1, 2, 4 (design deltas, 4.2, 4.4, 4.8, 4.14), 5.1, 5.2, 5.3, 6, 7, 8, 10 (R4, R5, rollback, H1), 12 (D-293-14).
- J-293-005 (explicit parity), ACCEPTED. New parity subsection defining the online content set and order against the merged code (title, both bodies, media link, vocabulary, prompts), the intentional differences from the PDF, and the parity test. A media value that is not an http or https URL renders as plain text "Media link: {value}" instead of omitting the section, and the media section moves before Vocabulary to match the PDF order. Sections touched: 4 (4.1, 4.5, 4.6, 4.7, 4.9), 7, 8 (V1, V17), 10 (R13).
- J-293-006 (malformed UUID), ACCEPTED. A malformed id fails uuid input conversion (22P02, HTTP 400) before the function runs and never returns NULL. The page validates both ids and shows J5 without a request; the RPC test expects an error for malformed input and NULL only for well-formed nonexistent or refused ids; the client classifier maps 22P02 and HTTP 400 to J5 as defense in depth. Sections touched: 4 (4.3), 5.1, 5.2, 7.
- J-293-007 (V5 assertion), ACCEPTED. `get_student_learn_course` already returns every lesson title, so "no lesson title in any network response" was false. V5 now asserts that the read RPC response body is exactly null for every refusal cause, that no response carries body, cards, prompts or media for a refused lesson, and that titles from `get_student_learn_course` are expected. Sections touched: 7, 8 (V5).
- Coordinator process notes, applied. The `lesson_revisions_student_read` hardening issue is filed by the coordinator and is removed from the fleet's work items and from Scribe's follow-up texts (D-293-10 now reads "Follow-up filed by the coordinator; out of scope."). A new user rule limits dev servers during browser validation (record every PID, stop each by PID, confirm nothing listens on 5180, sequential skew runs, stop the mirror stack). Sections touched: 2, 6, 8, 12 (D-293-10).

Reading guide: approvers need sections 1, 2, 10, 12 and 13. Sections 3 and 4 hold the evidence and the reviewed design. Sections 5 to 9 are execution detail for the engineering fleet.

### Standing constraint: production is live

Recorded 2026-10-13 from the user's words, carried from the approved 196 plan: "from this point forward we must consider the project live and production supabase as live with real student and course tracking data. moving forward nothing can be lost in production supabase and all migrations must account for that."

- Production is live, with real student and course tracking data.
- No production data may be lost.
- Every migration must be non-destructive and account for existing production rows. That means:
  - no DROP, TRUNCATE or DELETE of student, enrollment, progress, submission, attempt, entitlement, course or content data without an approved, logged and reversible data plan;
  - additive or backfilled schema changes with safe defaults;
  - rollbacks that preserve data written after apply;
  - a read-only production preview before any apply that changes access or data.
- Hosted actions still need separate explicit approval.

This plan's only database change is one additive migration that creates read-only functions. It writes nothing and changes no table, policy or row.

### Standing constraints

Carried forward from the user and the 196 plan:

- Accomplish the goal with proper root-cause analysis.
- Pull requests only: base `main`, no push to `main`, the user merges.
- Production is LIVE. Nothing may be lost. Migrations are additive and non-destructive. Each hosted action is separately approved.
- Owner admin copy is English-only.
- Student Spanish strings are drafted for Lizbeth's approval and stay inert until she approves them.
- Deploy-skew safety: every new frontend degrades safely against an older backend, proven by an e2e run.
- Honest disclosure: nothing may describe the PDF as accessible, and nothing may claim the online page fully conforms to WCAG 2.2 AA. Two residual gaps are disclosed: 3.1.2 (Language of Parts) for vocabulary cards and practice prompts, which are not language-keyed (section 4.7), and 1.1.1 for imported images without a text description, which a visible note mitigates but does not cure (section 4.9).

---

## 1. Outcome and audience

Audience: Rob (approver), Lizbeth (Spanish copy and label vocabulary), and the engineering fleet.

Outcome: an entitled student in an authored (non-legacy) course can open an accessible online view of each open lesson at `/learn/:enrollmentId/lessons/:lessonRevisionId`. The view renders the same authored content the #196 handout PDF prints (title, Spanish and English bodies, vocabulary, practice-question prompts without answers, media link, per lesson kind). It targets WCAG 2.2 AA, with two disclosed residual gaps: partial 3.1.2 on non-language-keyed vocabulary and prompts, and 1.1.1 for imported images without a text description (mitigated by a visible note). It is reachable from each eligible lesson card and each handout row through a "Read online" link that appears only after a positive server capability answer, it prints cleanly, and it shows no content for locked, paused or unavailable lessons.

This closes the D-196-15 option B follow-up (issue #293) and lets the handout be described honestly as a printable version of the online lesson.

Delivery: two pull requests against `main`, serial, single writer. PR 293a is the backend (one additive migration with the read RPC, its projection helper and a capability function, plus a rollback file). PR 293b is the frontend. No merge and no hosted action by the fleet.

## 2. Scope and non-goals

In scope:

1. Additive SECURITY DEFINER read RPC `get_student_lesson_content` with a recursive allowlist projection helper, an additive capability function `get_lesson_read_capability`, and a rollback file.
2. Reuse of the exported content helpers in `src/services/lessonHandoutContent.ts` (`printableCards`, `printablePrompts`, `printableMedia`, `slotTitle`) so the online view and the handout use one kind mapping; no second kind matrix.
3. A safe React renderer for TipTap JSON, including image rendering with visible notes for images without a description or that cannot be shown.
4. New route, page, data service and copy module (English final, Spanish drafts inert).
5. "Read online" entry links on `/learn` lesson cards and on handout rows, shown only while the capability function answers positively.
6. Switch of the #196 student handout note and owner disclosure to the pre-approved option-A strings, only while the capability function answers positively; otherwise the strings shipped by #294 stay exactly as they are.
7. An English-only owner warning for lessons that contain an image without a text description (Handouts tab lesson panel and Content tab).
8. RED tests first: unit and RTL, pg and live SQL, e2e at 1440, 390 and 320, forced colors, print, axe, and sequential deploy-skew and rollback e2e.
9. Hosted rollout plan and decisions.

Non-goals:

- Legacy (band) courses and Roadmap/WeekDetailPage. Legacy lessons keep `LessonContentView`; legacy-course deep links go to the existing Roadmap pointer.
- Tagged PDF or PDF/UA.
- Any change to handout generation beyond importing its existing helpers (at most a small behavior-preserving exported constant; existing #294 tests stay green).
- Per-side language fields for vocabulary cards and prompts (follow-up).
- Editing or requiring alt text for images in the authoring workspace (follow-up; the owner gets a warning only, D-293-15).
- Progress or completion writes from the view (read-only).
- A Print button (print stylesheet only).
- A language toggle.
- Tightening the `lesson_revisions_student_read` RLS policy (follow-up issue filed by the coordinator).
- Any change to `get_student_learn_course`, `get_student_lesson_assets`, `record_lesson_completion` or entitlement data.
- Any hosted action or merge without separate approval; any commit or push to `main`.

## 3. Repository findings and evidence

Findings F1 to F13 were first observed at `767de59` and are updated where `3594188` changed them; anchors that moved or are new at `3594188` are in 3.3. File:line references are to the evidence checkout and must be re-verified at Step 0.

### 3.1 Findings

| Id | Finding | Label |
|---|---|---|
| F1 | No authored lesson body view exists. `LearnDetailPage` cards (`src/pages/LearnDetailPage.tsx:299-464`) render title, state, task and quiz links (task link `:415`, quiz link `:429` at `3594188`, `a.control` plus `navigate`), Mark complete, and "Lesson materials" with `ResourcesPanel` embedded only when `isMaterialsEligible` (materials comment `:450`; line shift only). `get_student_learn_course` (`supabase/migrations/202608310002_issue5_phase5_student_learn_sql_core.sql:74-163`) never returns content but does return every lesson's title, including locked ones. No `src` code reads `lesson_revisions.content` for students. `LessonContentView` (`src/components/LessonContentView.tsx`) renders only legacy structured JSON for `WeekDetailPage` and is not a TipTap renderer (its CSS vocabulary may be reused). | Observed |
| F2 | Routes: `src/hooks/useRoute.ts:239-266` define `LEARN_DETAIL_PATTERN` `^/learn/([^/]+)$`, `LEARN_TASK_PATTERN` (`.../lessons/([^/]+)/tasks$`) and `LEARN_QUIZ_PATTERN` (`.../quiz$`). A suffix-less `/learn/:e/lessons/:rev` does not exist and does not collide, so a new matcher is additive. Page precedent `src/pages/LearnTaskPage.tsx:26-117`: UUID validation before any request, Back control, h1 `tabIndex -1`, one generic unavailable state for every refusal, fail closed. | Observed |
| F3 | Content model. Client `saveDraft` (`src/services/courseAuthoring.ts:121`) persists `content = {kind, title:{es,en}, body:{es:TipTapDoc,en:TipTapDoc}, metadata:{cards?:[{front,back}], questions?:[{id,prompt}], mediaUrl?}}` and sends answers separately to `assessment_answer_keys`. `save_outline` (`supabase/migrations/202610120003_issue202_save_outline_identity.sql:66-80`) strips only top-level `answers`, `answer_key`, `assessment_key`. `getCourse` (`courseAuthoring.ts:118`) normalizes older shapes (string title, single body, legacy structured fields via `structuredContentToTiptap` at `:117`, and `content.quiz[].answer` mapped into `metadata.questions[].answer` for the owner). Kinds: `CourseBlockKind = rich_text \| exercise \| vocabulary \| media \| checkpoint` (`src/lib/courseAuthoring.ts:6`). Cards and questions are not language-keyed. `lesson_revisions.title` is plain text; the table is defined at `202608280003:55-65`; answer keys live in `assessment_answer_keys` (`:67-73`). | Observed |
| F3i | Revisions created through the editor carry no answers in `content`, but imported, backfilled or structured-shape revisions may carry `content.quiz[].answer` or other answer-bearing keys, and answer-bearing keys could sit at any depth of a TipTap body. The RPC must therefore project an allowlist recursively and never pass `content` through. Verified by hosted check H0 q3 and by the RED nested-leak tests. | Inference |
| F4 | The editor is `@tiptap/react` plus StarterKit v3 (`package.json:38-39`; `CourseWorkspacePage.tsx:2-3`) with no Image or Table extension, so image and table nodes arrive only through imported content, and alt text cannot be edited in the app. `@tiptap/core` 3.30.5 exports `generateHTML`, `generateJSON`, `generateText`. No `@tiptap/html`, `@tiptap/static-renderer` or HTML sanitizer (no `dompurify`) is installed. `@axe-core/playwright` `^4.13.0` and `@playwright/test` `^1.61.1` are devDependencies (`package.json:51,53`). | Observed (image and table origin is Inference) |
| F5 | Canonical entitlement predicate: `get_student_lesson_assets` (`202610160001_issue196_lesson_handouts.sql:451-494`) and `record_lesson_completion` (`202610040006_issue179c_completion_gate.sql:253-274`) require own active enrollment, `is_account_active(auth.uid())`, not `user_requires_password_change()`, an entitlement row, `manual_release_state` not in (`held`, `revoked`), and (`released` or `unlock_at <= now()`). The 5c-2 week-state migration (`202610150002_issue198_5c2_roadmap_week_states.sql:12-19, 85-96`) derives open, paused, locked and unavailable from the same rule, merges held and revoked into paused, returns NULL for not-own, inactive or password-change, revokes EXECUTE from `public`, `anon` and `service_role`, grants `authenticated`, and starts with `begin; set local lock_timeout '5s'; set local statement_timeout '60s'`. The client `isMaterialsEligible` (`src/services/learnMaterials.ts:46-51`) mirrors it. | Observed |
| F6 | Existing RLS gap. Policy `lesson_revisions_student_read` (`202608280003:521`, its only definition) plus `grant select on lesson_revisions to authenticated` (`:536`) lets an entitled student SELECT `lesson_revisions` rows, including `content`, when `unlock_at <= now` and not held or revoked, with an active enrollment. It has no `is_account_active` or password-change check, does not honour released-early, and does not check version mapping. A direct table read is therefore not the canonical rule and returns raw content. Content is already student-readable for open lessons, so the new RPC widens exposure only to released-early lessons, which the canonical rule allows. The legacy branch of `fetchLearnMaterials` depends on this policy (`learnMaterials.ts:99`), so tightening it is a separate follow-up. | Observed (widening statement is Inference) |
| F7 | #196 state at `3594188`: PR 8a (`202610150001` immutability), PR 8b (`202610160001` handouts, `src/lib/lessonHandouts.ts`) and PR 8c (#294, the handouts UI: PDF builder, Handouts tab, student labels and note, `learnMaterials` language and kind pass-through) are all on `main`. `learnMaterials.ts:86-101` passes language and kind through with an ES-then-EN rank; `ResourcesPanel.tsx:126-133` holds the handout language label and `:193` the handout note id used for `aria-describedby`; `src/lib/handoutStudentCopy.ts:7-24` holds the English labels and note ("Printable handout for this lesson. If you need it in another format, ask your teacher.", `:11`) and the inert Spanish draft catalog `HANDOUT_STUDENT_COPY_ES_DRAFT`; `src/pages/HandoutsTab.tsx:180` holds the owner disclosure. The 196 plan pre-approved these option-A strings for when an online lesson exists: owner "Students can read this lesson online. This PDF is a printable version of it."; student note "Printable handout for this lesson."; student link "Open the online lesson" (superseded here by "Read online", D-293-5). 196 invariant 7 forbids claiming an online lesson until the route exists, which is why the switch is capability-gated (4.4). | Observed |
| F8 | Bilingual mechanism: `useSiteLanguage` (`src/context/PublicContentContext.tsx`), `LanguageToggle`, `src/lib/siteLanguage.ts` (#187; `/admin` is English-only). Functional-copy precedent `src/lib/roadmapCopy.ts:1-25` (`Record<'en'\|'es'>`, Spanish entries carry the status "DRAFT - pending Lizbeth's approval"). Language of parts: `src/components/EnglishText.tsx` (#282). | Observed |
| F9 | Fixed overlay: `.accessibility-button` is `position: fixed` (`src/components/AccessibilitySettings.css:12-31`), `--a11y-trigger-footprint` is defined at `App.css:100`, and the h1 clearance applies below 640px only (`App.css:1063-1065`). This is design finding DR-01. | Observed |
| F10 | `fetchLearnCourse` (`src/services/learnData.ts:121-129`) throws one `LearnDataError` for both not-found and transport failure (design item E1). | Observed |
| F11 | The latest migration on `main` is `202610160001_issue196_lesson_handouts.sql`; none is newer at `3594188`. | Observed |
| F12 | Test infrastructure: `src/__tests__/helpers/testConfig.ts` (API from `SUPABASE_API_URL`, then `LIZBETH_TEST_API_PORT`, default 54321; DB from `SUPABASE_DB_URL`, then `SUPABASE_DB_PORT`, `LIZBETH_TEST_DB_PORT`, `E2E_DB_PORT`, `PGPORT`, default 54322; loopback enforced); `playwright.config.ts` (baseURL from `E2E_BASE_URL`, else `netlify serve` on 8888; workers 1); fixtures `src/__tests__/e2e/course-fixtures.ts` (`createOwnerCourseFixture`) and `issue174-fixtures.ts`; live SQL test precedent `src/__tests__/issue196bLessonHandoutsSql.test.ts`. The mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` uses `supabase/config.toml` api 64321 (`:10`), db 64322 (`:35`), studio 64323 (`:98`) and `.env.local:1` `VITE_SUPABASE_URL=http://127.0.0.1:64321`. | Observed |
| F13 | The text of issue #293 and of #278 could not be read (the Researcher Bash hook blocks `gh`, and the repository is private). The only local #278 reference (`src/__tests__/e2e/issue177-overflow.spec.ts:191`) says "#278 moved the roadmap to the server week states"; #278 is therefore probably the 5c-2 server week-state rule, consistent with F5. The exact change of #269 (gate) could not be identified from local evidence; Inference: it is frontend or test only, because no migration exists after `202610160001`. This plan relies on the user's brief. Step 0 must reconcile it with `gh issue view 293` and with the #269 diff. | Unknown (#278 identity and #269 scope are Inference) |

### 3.2 Research evidence

Researcher `RESEARCH_EVIDENCE` of 2026-10-17 was read-only and local only. Claims C0 to C5 are reflected in F2, F4, F5, F6, F7, F11, F12 and F13. Sources: checkout migrations `202608280003:521`, `202608310002:74-163`, `202610040006:253-306`, `202610160001:451-494`, `202610130002:39-87`; `src/hooks/useRoute.ts:225-273`; `package.json:38-39`; mirror `config.toml` and `.env.local`; `testConfig.ts:1-87`; worktree HEAD and `FETCH_HEAD`. Limits: no `gh` or GitHub access, so issue texts and the remote SHA are Unknown. The base moved to `3594188` after this evidence was gathered; the Planner's re-check at the new base is recorded in 3.3 (Observed per the Planner handoff; Scribe did not re-read the code). No external sources were used.

### 3.3 New and updated anchors at `3594188` (Observed, from the Planner re-check)

| Anchor | Fact |
|---|---|
| `src/services/lessonHandoutContent.ts:37-39` | `CARD_KINDS` = `rich_text`, `exercise`, `vocabulary`, `media` (private `printsCards`). |
| `src/services/lessonHandoutContent.ts:143-145` | `printableCards`, `printablePrompts`, `printableMedia`. `printableMedia` returns the trimmed `mediaUrl` for kind `media` with no scheme check. |
| `src/services/lessonHandoutContent.ts:166-169` | `slotTitle`: slot language, then the other language, then "Untitled lesson". |
| `src/services/lessonHandoutContent.ts:83-133, 72, 124, 123` | `blocksFromDoc` TipTap mapping; image dropped (`:72`, `:124`); table flattened with " \| " (`:123`). |
| `src/services/lessonHandoutContent.ts:152-154, 7-18` | `lessonHasImages`; `HandoutLessonInput`. |
| `src/services/lessonHandoutPdf.ts:202-203, 214, 243, 128-130` | PDF order is body, then "Media link: {url}", then vocabulary, then prompts; `allStrings`. |
| `src/lib/handoutStudentCopy.ts:7-24` | English labels and note (`:11`); inert Spanish catalog `HANDOUT_STUDENT_COPY_ES_DRAFT` (`:17-24`). |
| `src/pages/HandoutsTab.tsx:180` | Owner disclosure: "For students, this PDF may be the only way to read this lesson's text. Generated handouts have selectable text but are not tagged for screen readers. Students are told to ask their teacher for another format." |
| `src/components/handouts/HandoutSlot.tsx:144, 395` | Image notice via `lessonHasImages` (`:144`); upload warning (`:395`). |
| `src/components/ResourcesPanel.tsx:126-133, 193`; `src/services/learnMaterials.ts:86-101` | Handout language label; handout note id for `aria-describedby`; language and kind pass-through with ES-then-EN rank. |
| `src/lib/lessonTaskCopy.ts:110-113` (#286) | `lesson_task.page.back` = `{ en: '← Back to {course}', es: '← Volver a {course}' }` and `lesson_task.page.course_fallback` = `{ en: 'your course', es: 'tu curso' }` (live, not drafts). `LearnQuizPage.tsx:47` spreads an English-lang attribute on its Back control. |
| `src/pages/LearnDetailPage.tsx:415, 429, 450` | Task link, quiz link, materials comment (line shift only). |
| Migrations | None exists after `202610160001_issue196_lesson_handouts.sql`, so the 293a timestamp follows it. |
| #269 (gate) | Exact change Unknown from local evidence; Inference: frontend or test only. Step 0 reads the diff and reconciles. |

## 4. Design (Standard profile, reviewed `DESIGN_HANDOFF` revision 2, verdict PASS)

`DESIGN_ROUTE`: profile standard; reasons: a new student screen with many states, entry-link changes on existing surfaces, accessibility as the purpose, and bilingual language-of-parts; agents design-director (Sonnet 5, high) with ux-architect and visual-system-designer, and design-reviewer (Sonnet) as the independent pass. Motion and asset specialists were not invoked (no trigger). Prototype forbidden. `existing_system_mode` extend.

**Design deltas from PLAN_DUCK Revision 1 (not re-reviewed by design-reviewer; the Browser Validator verifies them).** Where the sections below conflict with revision 2 of the design handoff, these deltas govern. No new design review is claimed.

1. Capability gating (J-293-004): the "Read online" links, the student note switch and the owner disclosure switch appear only after a positive capability answer (4.4).
2. Image rendering (J-293-003): an absolute https image shows with its alt, or with a visible note when alt is missing; any other image source shows a visible note in its place (4.9). The owner gets an image warning.
3. Media value (J-293-005): a media value that is not an http or https URL renders as plain text "Media link: {value}" instead of omitting the section, and the media section sits after the bodies and before Vocabulary, matching the PDF order (4.5, 4.6, 4.9).
4. Back control (J-293-001): it reuses the live `lesson_task.page.back` and `lesson_task.page.course_fallback` pattern from #286 (4.8).

### 4.1 Selected direction and constraints

Selected direction: **Plain reading page** in the Field Workbook system, extending the `LearnTaskPage` pattern. One column capped at `--measure` (65ch). Structure comes from headings, rules, weight and indentation, never from colour alone. The page is a reading document, not a dashboard.

Constraints:

- No new typeface, token, motion or imagery. No modal and no native dialog.
- Quiz answers and answer keys never appear.
- The PDF is never claimed accessible, and no copy, test name or evidence may claim the page fully conforms to WCAG 2.2 AA. The residual gaps are 3.1.2 (cards and prompts) and 1.1.1 (images without a description).
- Student Spanish strings are drafts and inert until Lizbeth approves them. Owner copy is English-only.
- The exactly-one-primary rule on lesson cards is untouched.

Anti-goals: cards inside cards, a language toggle that hides content, a Print button, decorative or branded treatment, and any reason-specific refusal copy (anti-enumeration).

Success measures:

- An entitled student reaches the full content from an eligible lesson card or handout row and returns with focus restored.
- Axe is clean, with keyboard operation, no horizontal scroll at 320 CSS px, forced-colors legibility and print-clean output.
- Every ineligible request shows one generic view and no content in the DOM.
- The online content set equals the PDF content set per kind, modulo the intentional differences listed in 4.6.

### 4.2 Journeys

| Id | Journey |
|---|---|
| J1 | Card to lesson. When the capability answer is positive (4.4), an eligible authored lesson card shows the quiet link "Read online" (accessible name "Read online: {lesson title}"). It uses the same `a.control` plus `navigate()` pattern as the task and quiz links (`LearnDetailPage.tsx:415, 429`), with a plain `href` so modifier-click and middle-click work. The page mounts with Back and the status "Loading your lesson...". On ready the h1 is focused and `document.title` becomes "{lesson title} - {course title} - {brand}" (unknown parts omitted). |
| J2 | Handout row to lesson. Once the capability answer is positive, each `ResourcesPanel` row with `kind === 'lesson_handout'` (passed through by `learnMaterials.ts:86-101`) gains a quiet "Read online" link after Download, through the existing per-`resource_type` `rowRenderer` slot (`ResourcesPanel.tsx:48, :302`; re-verified at Step 0). Same accessible name and URL as J1. The card-level link stays so lessons without handouts remain reachable. |
| J3 | Back with focus restoration. The Back control reuses the `lesson_task.page.back` and `lesson_task.page.course_fallback` pattern from #286 ("← Back to {course}", fallback "← Back to your course") and navigates to `/learn/{enrollmentId}`. Before navigating it writes `sessionStorage` key `learn.returnFocus.{enrollmentId}` = `lesson-read-link-{lessonRevisionId}`. `LearnDetailPage`, once `status === 'ready'`, reads the key for its own enrollment and deletes it on that first read regardless of outcome, then focuses the element with that id if present. If the element or key is absent, the existing load focus applies. Browser Back writes no key. |
| J4 | Direct URL or reload: ordered state resolution (4.3). |
| J5 | Generic refusal for every ineligible cause. |
| J6 | Load error with Retry. |
| J7 | Deploy skew calm state (read RPC missing; reachable by deep link during skew or after a rollback). |
| J8 | Legacy course lesson pointer to the Roadmap. |
| J9 | Print through the browser; no Print button (D-293-9). |

Every non-ready view keeps Back as the first tab stop. J6 has Retry, J8 has the Roadmap link, J5 and J7 have Back only.

### 4.3 J4 state-resolution table

Resolution is ordered and the first match wins. Retry (J6) re-runs from the failed step.

| Step | Check | Outcome |
|---|---|---|
| 1 | `enrollmentId` and `lessonRevisionId` both match the UUID regex used at `LearnTaskPage.tsx:26` | No: J5 generic refusal, no request made (a malformed id would otherwise fail uuid conversion with 22P02 or HTTP 400 before the function runs, J-293-006) |
| 2 | Call `fetchLearnCourse(enrollmentId)` (ownership-gated by the server) | 2a NULL, denied, not found or not this student's: J5, RPC not called. 2b resolved and `course_is_legacy && !has_any_entitlement_row` (the condition at `LearnDetailPage.tsx:669`): J8, RPC not called. 2c resolved otherwise: remember course title and lesson number, go to step 3. 2d fetch fails (network or 5xx): do not block; go to step 3 with course information unknown |
| 3 | Call RPC `get_student_lesson_content(p_enrollment_id, p_lesson_revision_id)` | 3a function missing (PostgREST PGRST202 or HTTP 404 naming the function, or Postgres 42883; the only J7 trigger): J7. 3b NULL, or 22P02 or HTTP 400 (uuid conversion; defense in depth, never J6 or J7): J5. 3c network, 5xx, any other error, or an unusable payload (not an object, or no kind): J6 with Retry. 3d success: ready |

Consequences:

- J8 is reachable only after step 2b, which requires an enrollment owned by the signed-in student, so J8 never appears for an enrollment the student does not own.
- Legacy plus skew shows J8 (step 2b precedes 3a).
- A legacy course that has entitlement rows goes to step 3 and NULL gives J5. The RPC is authored-only and the card link is hidden for legacy courses, so this is reachable only by direct URL.
- A failed course fetch with a successful RPC (2d then 3d) renders the lesson with the fixed "← Back to your course" label, and the fact line and document title omit unknown parts.
- Focus lands on the h1 of whichever view renders.
- J7 here concerns the lesson page only. Whether links and new copy appear on `/learn` is decided by the capability function, not by this table (4.4).

Engineering item E1: assertions that the RPC is not called after 2a rely on telling not-found from transport failure, which `fetchLearnCourse` does not currently do (F10). Either add a typed not-found discriminator to `fetchLearnCourse` as a behavior-preserving additive change (D-293-13), or relax those assertions to the visible outcome only. Never parse error strings.

### 4.4 Non-ready views and capability gating

- **J5 refusal.** Back (always the fixed fallback label "← Back to your course" from `lesson_task.page.course_fallback`, never the course title, so it is identical for every cause; mirror `LearnQuizPage.tsx:47`, which spreads an English-lang attribute on its Back control), h1 "This lesson isn't available right now.", one paragraph "Go back to your course to see which lessons are open." No reason, no lesson title, no content, no difference in wording or timing between causes. The h1 is focused.
- **J6 load error.** Back, then a `.form-error` container with `role="alert"` and `tabIndex={-1}`, focused: "We couldn't load this lesson. Please try again." plus a secondary Control "Retry". While pending, Retry stays mounted with `aria-disabled="true"` and `aria-busy="true"` and the status "Loading your lesson..." shows. Success renders the lesson and focuses the h1. A repeat failure re-renders the alert so it re-announces. No h1 (title unknown).
- **J7 deploy skew.** A calm note, not an alert: Back, h1 "Reading lessons online isn't available yet", paragraph "You can still use the lesson materials on your course page." No Retry. The h1 is focused. The lesson page keeps J7 for a deep link that reaches a missing read RPC (during skew or after a rollback). Entry points and copy are gated separately by the capability function (below). The release order stays binding as defense in depth: the 293a migration is applied and verified in the target environment before the frontend merges and deploys.
- **J8 legacy.** Back, h1 "This lesson is on your classic Roadmap", paragraph "This course is still being set up here. Its lessons, materials and tasks are on the Roadmap.", and a secondary link "Go to Roadmap" with the same target as the legacy call to action at `LearnDetailPage.tsx:691-698`. No auto-redirect. Card and row links never render for legacy courses because the legacy panel replaces the cards.
- **Loading.** Back plus `<p role="status" aria-live="polite">Loading your lesson...</p>` from mount, emptied on ready. No skeleton, spinner or animation. The h1 does not exist until the title is known (R4).
- **Capability gating (J-293-004).** The 293a migration adds `get_lesson_read_capability()`, which returns `{"lesson_read": 1}` (5.1, D-293-14). A small hook (for example `useLessonReadCapability`) makes one cached call per page load. The answer is positive only on a successful response with `lesson_read = 1`. PGRST202, HTTP 404, 42883, any other error, or a call still pending all count as unavailable, so links and new copy appear only after a positive answer. Gated on a positive answer:
  - the card "Read online" link;
  - the handout-row "Read online" link;
  - the student handout note: positive shows "Printable handout for this lesson."; otherwise it keeps exactly "Printable handout for this lesson. If you need it in another format, ask your teacher." (`handoutStudentCopy.ts:11`);
  - the owner disclosure in `HandoutsTab`: positive shows "Students can read this lesson online. This PDF is a printable version of it."; otherwise it keeps exactly the current text at `HandoutsTab.tsx:180`.

### 4.5 Information architecture

- Route `/learn/:enrollmentId/lessons/:lessonRevisionId` (suffix-less). A new matcher (design name `matchLearnReadRoute`; the planning name `matchLearnLessonRoute` is equivalent) sits beside the task and quiz matchers in `useRoute.ts`, with the same `decodeURIComponent` and fail-closed null. `App.tsx` branch order: tasks, quiz, read, detail. `LEARN_DETAIL_PATTERN` is untouched.
- Document titles: ready "{lesson title} - {course title} - {brand}" (unknown parts omitted); refusal "Lesson not available - {brand}"; error and skew "Lesson - {brand}"; legacy "Classic Roadmap lesson - {brand}". Pattern `PrivacyPolicyPage.tsx:133-155` (restore the previous title on unmount). When the lesson title language differs from the site language, also set `lang` on the `<title>` element and restore it on unmount (best effort; the h1 `lang` is the real requirement, item E3). Error, skew and legacy titles are copy-deck keys with draft Spanish (item E2).
- Landmarks: the app shell is untouched; page content is the sole child of the single `<main>`. No aside. No nav landmark for the jump link.
- Heading levels: exactly one h1. h2 elements are "Español", "English", "Lesson media", "Vocabulary" and "Practice questions" (the last three only where the kind matrix allows, in the PDF's order). h3 to h6 are authored TipTap body headings only.

Ready outline (site language Spanish shown; the order of the two language sections swaps for English):

```text
[Back control]                      quiet Control type=button; first tab stop in content
h1  {lesson title}                  tabIndex=-1; lang set only when the selected title's language differs from the site language
p   {course title} · Lesson {n}     mono fact line; parts omitted when unknown; not a heading
p   jump link to the other language same-page link; instant scroll; focus the target h2; never mutates location.hash
section#lesson-section-es lang="es"  h2 "Español" (tabIndex=-1), rendered body.es or the empty-language note
section#lesson-section-en lang="en"  h2 "English" (tabIndex=-1), rendered body.en or the empty-language note
section Lesson media                media kind only, only if the media value is non-empty
  p > a "Open the lesson media" + span.mono {hostname} inside the anchor (http or https value)
  p "Media link: {value}" as plain text, no link (any other value)
section Vocabulary                  kinds in CARD_KINDS only, only if cards exist; no lang attribute
  table: visible caption, th scope=col Front / Back, one row per card
section Practice questions          kinds in CARD_KINDS only, only if prompts exist; no lang attribute
  ol of prompts, then "(Answers are not included.)"
```

There are no footer controls, no Print button and no primary control anywhere on the page. Media, vocabulary and practice render once, after both bodies and in the PDF's order (media link, vocabulary, prompts), because they are not language-keyed.

### 4.6 Kind parity and online content set (J-293-001, J-293-005)

**One mapping.** The online view imports the exported helpers of `src/services/lessonHandoutContent.ts` (`printableCards`, `printablePrompts`, `printableMedia`, `slotTitle`, and the `HandoutLessonInput` type at `:7-18`) and builds a `HandoutLessonInput` from the RPC result. It creates no second kind matrix and no new shared model module. The RPC's server-side kind gating must equal `CARD_KINDS` (`rich_text`, `exercise`, `vocabulary`, `media`; `:37-39`), and a test asserts that the SQL kind list equals `CARD_KINDS` read from the module. At most a small exported constant may be added to `lessonHandoutContent.ts` if the test needs it (behavior-preserving; the existing #294 tests stay green). This resolves the earlier item E4 (the mapping of kinds to "standard" is now Observed in code).

| Lesson kind | Title block and both bodies | Media link | Vocabulary (cards) | Practice questions (prompts) |
|---|---|---|---|---|
| `rich_text`, `exercise`, `vocabulary` | yes | no | yes, if cards exist | yes, if questions exist |
| `media` | yes | yes, if the media value is non-empty | yes, if cards exist | yes, if questions exist |
| `checkpoint` and any other kind | yes | no | no | no |

A kind permitted to show a part but holding no data omits that section. The client renders only what the RPC returns and never infers extra sections.

**Online content set and order**, defined against the merged code:

1. Title: the `slotTitle` rule with the site language as the slot language (slot language, then the other language, then "Untitled lesson"). The design's `selectLessonTitle` (4.7) adds the plain `lesson_revisions.title` as a step before the "Untitled lesson" literal; engineering reconciles the two at Step 0 and records the result.
2. Spanish and English bodies, both, site language first, each through the same node set as `blocksFromDoc` (`:83-133`).
3. For kind `media`, the media link (`printableMedia`), after the bodies and before vocabulary, matching the approved 196 media ordering and `lessonHandoutPdf.ts:202-203`.
4. Vocabulary (`printableCards`; PDF `:214`).
5. Practice prompts (`printablePrompts`; PDF `:243`) followed by "(Answers are not included.)" (Spanish draft "(Las respuestas no están incluidas.)").

**Media handling online.** `printableMedia` has no scheme check, so the online page treats the value as described in 4.9: an http or https URL renders as a link; any other non-empty value renders as plain text "Media link: {value}" with no link. The content set therefore still equals the PDF's.

**Intentional differences from the PDF:**

- Both languages appear on one page; the PDF is one language per file and repeats the shared sections in each file.
- Semantic headings, lists and marks are preserved; the PDF flattens marks.
- Tables are real tables; the PDF prints " | " rows.
- Links are clickable for safe schemes; the PDF prints "text (url)".
- Images are rendered per 4.9; the PDF drops them.
- A title fallback is marked by `lang` on the h1; the PDF uses a language tag.
- There is no page footer or page numbers.
- Characters the PDF font cannot print (for example emoji) render online, while PDF generation blocks.
- The fact line names the course title.

**Parity test.** For each fixture kind (`rich_text`, `exercise`, `vocabulary`, `media`, `checkpoint`, and an unknown kind), the normalized text strings from `blocksFromDoc`, `printableMedia`, `printableCards` and `printablePrompts` equal the online page's rendered text strings, modulo exactly the differences listed above. The test also fails if any answer text appears in either output.

### 4.7 Language decisions

- Both language sections always render, site language first, each with a correct `lang` (D-293-4). No toggle, no hidden content, no persisted state.
- The headings "Español" and "English" are endonym language names in their own languages. They are not draft-gated.
- **Title selection** (one shared helper `selectLessonTitle`, used by the h1, the document title, the `<title lang>` and the card and row aria-labels wherever both languages are available): choose the site-language title if non-empty, else the other language's title (with `lang` for that language set on the h1 and on `<title>`), else the plain `lesson_revisions.title` (language unknown: no `lang`, no guessing). aria-labels cannot carry `lang`; they use the same selection and the difference is accepted and recorded (item E5). A surface holding only the plain title uses it. The PDF behaves the same way (English title with an ESPAÑOL tag when only English exists). The helper wraps `slotTitle` as described in 4.6.
- **Known partial limitation (WCAG 3.1.2 Language of Parts).** Vocabulary cards and practice prompts carry no `lang` attribute (D-293-6). Their language is unknown or mixed, there is no heuristic detection, and a wrong `lang` is worse than none. The page must not be described in UI copy, tests, release notes or evidence as fully conforming. The follow-up (per-side language fields in the authoring workspace) is listed in section 6.
- Empty body in one language: keep the section and h2 and show a one-line note, so the outline and jump link stay stable. If nothing is available at all (no body text in either language and no kind-permitted cards, questions or media), show the h1, the fact line and the single "no online content yet" note, with no sections.

### 4.8 Copy deck

English is final. Every Spanish entry carries the status **"DRAFT - pending Lizbeth's approval"** and is inert, except the two `lesson_task` keys, which already exist and are live in `lessonTaskCopy.ts`. Proposed module `src/lib/lessonReadCopy.ts`.

**Draft-gate mechanism.** Follow `src/lib/roadmapCopy.ts:1-25` typing exactly: `Record<'en'|'es', ...>` over one key set (a missing Spanish key is a compile error), `ES_DRAFT_STATUS = "DRAFT - pending Lizbeth's approval"`, and a `d(text)` helper that creates `{text, status: ES_DRAFT_STATUS}` for every Spanish entry. The resolver `readCopy(key, siteLang)` returns `{ text, lang }`. It returns the Spanish text with `lang: 'es'` only when that entry's status is the explicit approved status, a reviewed constant set in a separate reviewed change after Lizbeth approves (the approval constant is named in the module and confirmed by the Verifier, item E4). In every other case it returns the English text with `lang: 'en'`. Every rendered functional string takes its `lang` attribute from the resolver (precedent `EnglishText.tsx`), so English functional copy on a Spanish-site page is correctly marked `lang="en"`. Unit tests assert that every Spanish entry currently has the draft status, that with site language Spanish every functional string renders English with `lang="en"`, and that Spanish is released only through the same approval gate as the other Spanish entries.

| Key | EN (final) | ES (DRAFT - pending Lizbeth's approval; inert) |
|---|---|---|
| `lesson_task.page.back` (existing key, `src/lib/lessonTaskCopy.ts:110-113`, reused; live, not a draft) | ← Back to {course} | ← Volver a {course} |
| `lesson_task.page.course_fallback` (existing key, reused; J5 and any view where the course is unknown, giving "← Back to your course") | your course | tu curso |
| `lesson_read.page.fact` | {course} · Lesson {n} (parts omitted when unknown) | {course} · Lección {n} |
| `lesson_read.jump.to_en` | Skip to the English version | Ir a la versión en inglés |
| `lesson_read.jump.to_es` | Skip to the Spanish version | Ir a la versión en español |
| `lesson_read.section.es` (endonym; not gated; always `lang="es"`) | Español | Español |
| `lesson_read.section.en` (endonym; not gated; always `lang="en"`) | English | English |
| `lesson_read.empty.es` (note inside the `lang="es"` section; rendered through the resolver, so `lang="en"` while the draft stands) | This lesson has no Spanish text yet. | Esta lección aún no tiene texto en español. |
| `lesson_read.empty.en` (note inside the `lang="en"` section) | This lesson has no English text yet. | Esta lección aún no tiene texto en inglés. |
| `lesson_read.empty.all` | This lesson has no online content yet. Ask your teacher if you expected something here. | Esta lección aún no tiene contenido en línea. Si esperabas ver algo aquí, pregúntale a tu docente. |
| `lesson_read.vocab.heading` | Vocabulary | Vocabulario |
| `lesson_read.vocab.caption` | Vocabulary for this lesson | Vocabulario de esta lección |
| `lesson_read.vocab.col_front` | Front | Anverso |
| `lesson_read.vocab.col_back` | Back | Reverso |
| `lesson_read.practice.heading` | Practice questions | Preguntas de práctica |
| `lesson_read.practice.no_answers` | (Answers are not included.) | (Las respuestas no están incluidas.) |
| `lesson_read.media.heading` | Lesson media | Material multimedia |
| `lesson_read.media.link` | Open the lesson media | Abrir el material multimedia |
| `lesson_read.media.plain` (a media value that is not an http or https URL, shown as plain text) | Media link: {value} | Enlace multimedia: {value} |
| `lesson_read.status.loading` | Loading your lesson... | Cargando tu lección... |
| `lesson_read.unavailable.title` | This lesson isn't available right now. | Esta lección no está disponible por ahora. |
| `lesson_read.unavailable.body` | Go back to your course to see which lessons are open. | Vuelve a tu curso para ver qué lecciones están abiertas. |
| `lesson_read.error.load` | We couldn't load this lesson. Please try again. | No pudimos cargar esta lección. Inténtalo de nuevo. |
| `lesson_read.error.retry` | Retry | Reintentar |
| `lesson_read.skew.title` | Reading lessons online isn't available yet | Leer las lecciones en línea aún no está disponible |
| `lesson_read.skew.body` | You can still use the lesson materials on your course page. | Puedes seguir usando los materiales de la lección en la página de tu curso. |
| `lesson_read.legacy.title` | This lesson is on your classic Roadmap | Esta lección está en tu Roadmap clásico |
| `lesson_read.legacy.body` | This course is still being set up here. Its lessons, materials and tasks are on the Roadmap. | Este curso aún se está configurando aquí. Sus lecciones, materiales y tareas están en el Roadmap. |
| `lesson_read.legacy.cta` | Go to Roadmap | Ir al Roadmap |
| `lesson_read.link.read_online` (card and row, visible; shown only while the capability answer is positive) | Read online | Leer en línea |
| `lesson_read.link.read_online_name` (aria-label) | Read online: {lesson title} | Leer en línea: {lesson title} |
| `lesson_read.handout.note` (student, once per card; shown only while the capability answer is positive; otherwise the shipped note "Printable handout for this lesson. If you need it in another format, ask your teacher." stays) | Printable handout for this lesson. | Material imprimible de esta lección. |
| `lesson_read.image.no_alt` (visible note directly after an image with an empty or missing alt) | This image has no description. Ask your teacher what it shows. | Esta imagen no tiene descripción. Pregúntale a tu docente qué muestra. |
| `lesson_read.image.unavailable` (visible note in place of an image whose source is not an absolute https URL) | This lesson includes an image that can't be shown here. Ask your teacher about it. | Esta lección incluye una imagen que no se puede mostrar aquí. Pregúntale a tu docente. |
| `lesson_read.table.region` (aria-label for an unnamed imported table; n counts 1, 2, 3 in document order across the page) | Table {n} | Tabla {n} |
| `lesson_read.doc_title.unavailable` | Lesson not available | Lección no disponible |
| `owner_handout.disclosure` (English only, `/admin`; not a student string; shown only while the capability answer is positive, otherwise the text at `HandoutsTab.tsx:180` stays) | Students can read this lesson online. This PDF is a printable version of it. | n/a |
| `owner_handout.image_alt_warning` (English only, `/admin`; Handouts tab lesson panel next to the existing image notice at `HandoutSlot.tsx:144`, and Content tab for the selected lesson; shown when any body image lacks a non-empty alt; no gate) | This lesson has an image without a text description. Students using a screen reader won't know what it shows. Describe the image in the lesson text. | n/a |

Document-title keys for the error, skew and legacy views (E2) are added to the deck with draft Spanish by engineering, using the titles in 4.5.

The Spanish drafts for `lesson_read.image.no_alt`, `lesson_read.image.unavailable` and `lesson_read.media.plain` were drafted by Scribe for this revision; Lizbeth reviews them with the rest of the deck. The Back control reuses the `lesson_task` keys above and mirrors the English-lang handling of `LearnQuizPage.tsx:47`.

Label choice: "Read online" (the user's requested label) replaces the earlier placeholder "Open the online lesson" (D-293-5). It is verb-first, parallel to sibling controls ("Download ...", "View flashcards"), and fits beside Download at 320px. The accessible name "Read online: {lesson title}" contains the visible text verbatim (2.5.3 Label in Name) and follows the `ResourcesPanel.tsx:275-278` aria-label pattern. The option-A student note and owner disclosure are kept verbatim as pre-approved.

### 4.9 Rich-text renderer and links

An allowlisted TipTap-JSON renderer producing React elements. It never uses `dangerouslySetInnerHTML`.

| Node or mark | Output |
|---|---|
| doc | fragment |
| paragraph | `p` (empty paragraph omitted) |
| text | text node, marks applied inner to outer |
| heading | Rank compression per language section: collect the distinct TipTap levels used in that section, sort ascending, map to h3, h4, h5, h6 in rank order (source h2 and h4 become h3 and h4, so no skipped levels); the fifth and later ranks clamp to h6. A TipTap h1 never becomes the page h1 |
| bulletList, orderedList, listItem | `ul`, `ol` (`attrs.start` honoured if a positive integer), `li`, nesting preserved |
| blockquote, codeBlock, hardBreak, horizontalRule | `blockquote`, `pre > code` (pre-wrap), `br`, `hr` |
| bold, italic, strike, underline, code | `strong`, `em`, `s`, `u`, `code` |
| link | see below |
| unknown mark | ignored, text still rendered |
| image (imported only) | Absolute https `src` only. A non-empty alt renders `<img src alt loading="lazy">` with the alt verbatim and max-width 100%. An empty or missing alt renders `<img alt="">` followed directly by the visible note "This image has no description. Ask your teacher what it shows." so the image is not hidden. Any other `src` (http, data:, relative, same-origin path, invalid) is not loaded, and the visible note "This lesson includes an image that can't be shown here. Ask your teacher about it." appears in its place. `attrs.title` is ignored |
| table, tableRow, tableHeader, tableCell (imported only) | `table`, `tr`, `th` (scope col in the first row, scope row in the first column), `td`; colspan and rowspan honoured if positive integers; wrapped in `div.lesson-table-scroll` with `tabindex="0"`, `role="region"`, `aria-label` from the caption text or "Table {n}" |
| unknown node type | its descendant text leaves rendered as one `p`; no text, nothing. No attribute pass-through beyond this allowlist |

Content that is not an object with type `doc` is treated as an empty section. The renderer never throws to the page and never exposes raw JSON or HTML. It applies the same node, mark and attribute allowlist the RPC projects (5.1), as defense in depth.

**Images and WCAG 1.1.1.** An informative image without alt text is a gap that the visible note mitigates but does not cure. It is recorded with the 3.1.2 limitation as a residual gap, and nothing may claim full conformance. The editor has no Image extension (F4), so images arrive only through imported content and alt text cannot be edited in the app (D-293-15).

**Body links.** The `href` is accepted if `new URL(href, origin)` parses with protocol https, http or mailto, or it is a same-origin path starting with "/". Otherwise the mark is dropped and the text renders unlinked (blocks `javascript:`, `data:`, `vbscript:`, `blob:`). External origins get `rel="noopener noreferrer"` and open in the same tab. Empty link text renders the href as the text. Known `/learn` routes may use `navigate()`.

**Media rule** (J-293-005; replaces "omit the section when unsafe"). `printableMedia` returns the trimmed `mediaUrl` for kind `media` with no scheme check, so the online page keeps the content set equal to the PDF's. If the value parses with `new URL(value)` (absolute, no base) and its protocol is exactly `https:` or `http:`, it renders as a link with `rel="noopener noreferrer"`, same tab, with the hostname (`new URL(value).hostname`) inside the anchor, so the visible link text is "Open the lesson media {hostname}" and no aria-label is needed. Any other non-empty value (relative, `mailto:`, `javascript:`, `data:`, `blob:`, `vbscript:`, or free text) renders as plain text "Media link: {value}" with no link and no `href`. An empty value gives no media section.

### 4.10 Visual system

Plain reading page; zero new tokens (no new primitive or semantic token, no hex literals in the new CSS, print uses the `black` and `white` keywords). One selector per line (the cssCascade guard). Control.css is not edited.

- **Page.** Wrapper `<div class="learn-page lesson-read-page">`: `.learn-page` supplies the measure and focus ring; `.lesson-read-page` repeats `LearnTaskPage` padding (`var(--space-8) var(--space-6)`, and `var(--space-6) var(--space-4)` at 48rem and below), with `padding-inline: 0` at 22.5rem and below because `.app-main` already supplies 16px. The ground is the inherited paper-50.
- **Typography.** Fraunces headings, Source Sans 3 body, IBM Plex Mono for the fact line, hostname and code. Every body-family size is `calc(<size> * var(--text-size-multiplier))` and uses `--font-family-body`, so the user's accessibility settings (text size, font, line height, measure) keep flowing through. Body text 1.125rem with line-height `max(1.75, user line-height, floor)`, left-aligned, never justified, `hyphens: manual`. Body headings h3 to h6: Fraunces 1.25rem 600, Fraunces 1.125rem 700, body-family 1.125rem 700, body-family 1rem 700. Muted notes and status text are upright (not synthesized oblique). h1 is inherited from `.learn-page h1` and gets `overflow-wrap: anywhere`, with a clamp at 22.5rem and below.
- **Layout and rhythm.** Spacing tokens only. Back to h1 `--space-4`, h1 to fact line `--space-3`, fact line to jump paragraph `--space-5`, jump paragraph to first section `--space-6`, between top-level sections `--space-8`. Each top-level section has a thin `ink-700` top rule and `--space-6` top padding; this rule is the single structural cue marking where the language changes.
- **Vocabulary table.** A real table at every width: `width: 100%`, `table-layout: fixed`, two 50% columns, visible caption, `th[scope=col]`, cell borders in `ink-1000` (thin), header on paper-200 with a heavier bottom rule. It is never restacked and never wrapped in a scroll region. Cells use `overflow-wrap: break-word` (links and code inside cells keep `anywhere`) so ordinary Spanish words are not split mid-word unless they cannot fit (DR-12).
- **Reflow.** `overflow-wrap: anywhere` on h1, links and code; `break-word` on h2 to h6, p, li, blockquote, figcaption and table cells; `pre-wrap` on code; images `max-width: 100%`. Only imported tables scroll, inside the labelled focusable region (the 1.4.10 data-table exception).
- **Entry links.** Rendered only while the capability answer is positive (4.4). Card link: `<a class="control control--quiet lesson-card-read-link">`, first in the card's action cluster (before the task link), `align-self: flex-start`, `margin-block-start: var(--space-2)`; it must not copy `text-decoration: none` from the task link, because the quiet tier depends on its underline; it is never primary or secondary and never the "Up next" target. Row link: `<a class="control control--quiet resources-panel-row-read-link">` inside a new wrapper `.resources-panel-row-actions` (flex, wrap) after Download; at 700px and below the link resets to `width: auto` so it wraps onto its own line, left-aligned, and does not look like a button. The student handout note renders in `.resources-panel-row-main` under the type label, upright, `overflow-wrap: anywhere`.
- **Notes and errors.** The load error uses the shared `.form-error` treatment unchanged (spacing only is added). Calm notes (skew, legacy) are neutral panels with no `role="alert"`. The note after an image without a description and the "can't be shown here" note are muted upright notes (`.lesson-read-note--muted`).
- **Contrast** (hand-computed with the WCAG 2.x formula from the repo hex values; the Verifier confirms with a tool): ink-900 on paper-50 about 14.92:1; ink-1000 on paper-50 17.65:1; ink-700 on paper-50 8.64:1; brass-700 (links) on paper-50 5.65:1, on paper-200 4.89:1; terracotta-600 on paper-50 4.69:1; focus ring ink-slate on paper-50 6.72:1; table borders ink-1000 on paper-50 17.65:1. Body links against adjacent ink-900 text are only 2.64:1, so the underline on every link is mandatory (1.4.1). paper-300 never draws a boundary (1.34:1) and brass-500 is decorative only.
- **Forced colors.** `@media (forced-colors: active)`: table, rule, hr, blockquote, pre and calm-note borders use `CanvasText`; links use `LinkText` with underline kept; focus rings use `Highlight`; the header row survives by weight and bottom rule. `.form-error` already maps its border to `CanvasText`.

### 4.11 Print

- Hide with `display: none !important`: `.app-header`, `.app-footer`, `.skip-to-content-link`, `.accessibility-button`, `.lesson-read-page .control`, `.lesson-read-back`, `.lesson-read-jump`, `.lesson-read-status`, `.lesson-read-error`, `.lesson-read-note--calm .control`.
- Show: the h1 and fact line (the print title block, with no separate print-only title), both language sections, the media section, the vocabulary table with caption and header row, and practice questions with the answers line, each per the kind matrix.
- Scoped resets only: `.lesson-read-page { max-width: none; padding: 0; }` and `.lesson-read-page p { max-width: none; }`. No resets on all descendants, so `img` keeps `max-width: 100%` and `pre`, `td`, `th`, `blockquote`, `code` keep their padding (DR-07).
- Colour: black on white by keyword. Underlines kept; focus outlines removed. Table cell borders 1pt black, header bottom 2pt, header row repeats.
- Link targets: `http` and `mailto:` link targets are appended in parentheses after the link (scoped under `.lesson-read-page`, 9pt mono); the media link already shows its hostname and gets the full URL appended.
- Pagination: headings and captions `break-after: avoid`; `tr`, `li`, `figure`, `pre`, `blockquote` `break-inside: avoid`; orphans and widows 3; no forced page breaks; no global `@page` rule (a named page is optional).
- Print sizes in pt: body 11 / 1.5, h1 20, fact line 10 mono, h2 15, h3 13, h4 12, h5 11, h6 10.5, caption 11, table text 11, notes 10, code 9.5, appended URL 9.

### 4.12 Accessibility requirements

- **Focus on load.** After the ready render, focus the h1 (`tabIndex -1`, ring as `LearnTaskPage.css:22-25`). Refusal, skew and legacy views focus their h1. The load error focuses the alert container. Loading does not move focus.
- **Focus Not Obscured (DR-01).** The fixed Accessibility Settings trigger overlays the top-right of the viewport at every width (F9), so an earlier claim of "no sticky elements" is withdrawn. Every focusable element and every programmatic focus or scroll target on the page keeps a clearance of `calc(var(--a11y-trigger-footprint) + var(--space-2))` (4.5rem) at the top of the viewport. Implementation: `scroll-margin-top` with that value on `.lesson-read-page a`, `button`, `[tabindex]`, `h2` to `h6` and `.lesson-table-scroll` (one selector per line). The permitted alternative is `html:has(.lesson-read-page) { scroll-padding-top: ... }` alone, never both. Verified at 320x568, 390x844 and 768x1024 (V16).
- **Jump link.** One same-page link under the fact line naming the other language. On click: `preventDefault`, `scrollIntoView({ behavior: 'instant', block: 'start' })` (the global `html { scroll-behavior: smooth }` would otherwise animate it), focus the target h2, never mutate `location.hash` (`RoadmapPage.tsx:65-81`). Shown whenever both sections render; hidden in print.
- **Keyboard order (ready).** Back, jump link, links in the first language body, links in the second, imported table scroll regions, media link. The h1 and h2 elements are programmatically focusable only. No traps; Escape does nothing.
- **Announcements.** Loading is a polite status; ready has no live text (the h1 focus announces the title); the load error is `role="alert"`; refusal, skew and legacy are static.
- **Target size.** Back, Retry and the card and row links are 48px (`--control-height`); the jump and media links are at least 44px (`--hit-target-min`); inline body links are exempt under 2.5.8.
- **Reading order.** DOM order equals visual order equals print order; no CSS reordering.
- **Reduced motion.** Nothing animates; the jump scroll is instant.
- **Colour independence.** All states are text; the table header is marked by `th` semantics, weight and a rule; the blockquote by rule and indent; the error by role, text and border.

### 4.13 Server and data contract (summary; section 5 holds the interface)

The RPC returns NULL for every refusal of a well-formed request, recursively projects each TipTap body through a node and mark allowlist (5.1), and gates parts by kind per 4.6. The client renders only what the RPC returns and applies the same allowlist again. The design proposed payload fields `title_es`, `title_en`, `body_es`, `body_en`, optional `lesson_number`, `cards`, `questions`, `media_url`; the planning interface in section 5.1 groups them as `title_i18n` and `body`. The exact key names are confirmed by engineering and tested against the allowlist.

### 4.14 Engineering invariants

1. Zero new tokens; no hex literals in new CSS; one selector per line; `Control.css`, `LessonTask.css`, `LearnTaskPage.css` and other shared sheets are not edited.
2. The page ground is the inherited paper-50; the page sets no background except on `th`, inline code, `pre`, calm notes and `.form-error`.
3. `.form-error` is used unmodified (spacing only added).
4. Entry links are `<a class="control control--quiet ...">` (never `<Control>`, which renders a button) and keep their underline. "Read online" is never primary or secondary and is never the "Up next" target.
5. Body links are always underlined; the focus ring is a 3px slate outline at a 2px offset drawn with `outline`, never `box-shadow`.
6. The vocabulary table is a real `<table>` with caption, `thead th[scope=col]`, `table-layout: fixed` and 50/50 columns; never restacked.
7. Only imported tables scroll, inside the focusable labelled region; the page never scrolls horizontally at 320 CSS px.
8. Body text is at least 1.125rem multiplied, with line-height at or above `max(1.75, user line-height)`; sizes honour `--text-size-multiplier`; body text uses `--font-family-body`; mono uses `--typography-role-label-fontFamily`.
9. DOM order equals visual order equals print order.
10. No motion; the jump scroll is instant and honours the trigger clearance.
11. Print shows only content, in black on white, with underlines, repeated table headers and appended external URLs; scoped resets only.
12. Forced-colors rules ship with the page.
13. The trigger clearance ships on all focus and jump targets; it is never replaced by `--space-6` and never combined with `scroll-padding-top`.
14. Table cells use `overflow-wrap: break-word`; links and code use `anywhere`.
15. Both language sections always render, site language first, each with a correct `lang`. Cards and prompts carry no `lang`. No toggle, no Print button, no modal.
16. Quiz answers and answer keys never appear anywhere (DOM, network response, test output).
17. The renderer is an allowlist (the same one the RPC projects) producing React elements; `dangerouslySetInnerHTML` is never used; body links are safe-protocol only; unknown nodes fail safe.
18. The ES draft gate holds: every Spanish entry in the new module is draft and none renders until the reviewed approval constant is set. The owner disclosure is English-only. No copy calls the PDF accessible or the page fully conformant.
19. No native `alert`, `confirm`, `prompt`, `window.*` variants or `beforeunload`; `window.print` is not used. The page has no modal, so the modal keyboard and focus check is not applicable (recorded explicitly in verification evidence, not skipped silently).
20. Focus return uses the per-enrollment `sessionStorage` key, deleted on first read regardless of outcome.
21. The release order is binding as defense in depth: the 293a migration is applied and verified before the frontend merges. Links and new copy additionally depend on a positive capability answer; an unavailable, failed or pending capability call shows no "Read online" link and keeps the shipped strings.
22. Images render only for an absolute https source; an empty or missing alt always adds the visible note; any other source shows the "can't be shown here" note (4.9).
23. A media value that is not an http or https URL is plain text with no link (4.9).
24. Content mapping imports the `lessonHandoutContent.ts` helpers; there is no second kind matrix; the SQL kind list equals `CARD_KINDS` (tested).

### 4.15 Permitted variation

- Class names other than the `lesson-read-*` prefix convention.
- Vertical rhythm may shift by one spacing step.
- The jump-link mechanism (JS instant scroll or the page-scoped CSS override), provided the trigger clearance holds.
- Per-element `scroll-margin-top` or a page-level `scroll-padding-top` (one, never both).
- Whether `.resources-panel-row-actions` is a new wrapper or an equivalent existing flex container.
- The h1 clamp floor at 22.5rem and below, between 1.5rem and 2rem.
- An optional named `@page` with margins of 15 to 20mm.
- Muted notes upright (recommended) or following the repo's italic hint convention.
- Table column headers "Front" and "Back" may become "Term" and "Meaning" as a copy-only change.
- The `u` mark may render as a plain span if it proves confusable with links.
- `sessionStorage` may be replaced by a routing-state mechanism, if one exists, with the same per-enrollment and consume-once semantics.
- The document-title brand segment.
- Registering the `lessonRead` DTCG aliases is optional (recommended: do not register).

### 4.16 Remaining design limits

Residual gaps: partial WCAG 3.1.2 for vocabulary cards and prompts, and 1.1.1 for images without a text description (mitigated by a visible note; nothing may claim full conformance). Contrast ratios and 320px cell widths are hand-computed estimates until a tool or browser confirms them. Spanish strings and the "Read online" label need Lizbeth. Review was static only; no rendered validation has run, and the Revision 1 design deltas were not re-reviewed by design-reviewer. Whether alt text should be required before publish is an owner policy call (D-293-15 chooses a warning for now). Unresolved, non-blocking design choices: registering DTCG aliases, upright versus italic muted notes, and the jump-link mechanism.

## 5. Interfaces and data

### 5.1 `get_student_lesson_content`, projection helper and capability function (PR 293a; additive; read only)

Signature: `get_student_lesson_content(p_enrollment_id uuid, p_lesson_revision_id uuid) returns jsonb`. `language sql stable security definer set search_path = public`. A malformed id fails PostgREST and Postgres uuid input conversion (SQLSTATE 22P02, HTTP 400) before the function runs, so the function cannot return NULL for it; NULL is returned only for well-formed ids that do not exist or are refused (J-293-006).

It returns NULL (one generic refusal, anti-enumeration) unless every condition holds:

- `auth.uid()` is not null;
- `student_enrollments se`: `se.id = p_enrollment_id`, `se.user_id = auth.uid()`, `se.status = 'active'`;
- `is_account_active(auth.uid())`;
- not `user_requires_password_change()`;
- `course_versions cv`: `cv.id = se.course_version_id` and `cv.status = 'published'` (the enrollment's own pinned version, D-293-2);
- `courses c`: `c.legacy_band_id is null`;
- `course_version_lessons` maps (`se.course_version_id`, `p_lesson_revision_id`);
- an `enrollment_lesson_entitlements` row (`se.id`, `p_lesson_revision_id`) with `manual_release_state not in ('held','revoked')` and (`manual_release_state = 'released'` or `unlock_at <= now()`).

It never reads `assessment_answer_keys`, `course_assets`, storage, thresholds or progress evidence.

Return shape (allowlist projection; engineering confirms exact key names; no pass-through of `content`):

- `lesson_revision_id`, `position`, `lesson_count`, `course_title`;
- `title` (`lr.title`) and `title_i18n {es, en}` (strings only);
- `kind`;
- `body {es, en}` (TipTap document objects projected recursively, see below; older single-body shapes normalized per F3; the legacy structured shape projected to its allowlisted textual fields without any answer);
- kind-gated parts: `cards [{front, back}]` (strings only) and question prompts `[{id, prompt}]` (strings only) only for the kinds in `CARD_KINDS` (`rich_text`, `exercise`, `vocabulary`, `media`; `src/services/lessonHandoutContent.ts:37-39`); `media_url` (string only) only for kind `media`; checkpoint and other kinds get title and body only. The SQL kind list must equal `CARD_KINDS`, asserted by a test that reads the constant from the module (a small exported constant may be added to that module, behavior-preserving, existing #294 tests stay green).

The result never contains the keys `answer`, `answers`, `answer_key`, `assessment_key`, `passing_score`, storage paths, or URLs other than `media_url` and links and image sources inside the projected TipTap body.

**Recursive TipTap projection (J-293-002).** The RPC passes nothing from `content` through. Each body is projected recursively by an internal helper (for example `public.project_lesson_tiptap(jsonb, depth int)`, immutable, plpgsql or recursive sql; EXECUTE revoked from `public`, `anon` and `authenticated`; called only from the definer function).

- Allowed node types and attributes: `doc`; `paragraph`; `heading` (`attrs.level`, integer 1 to 6 only); `bulletList`; `orderedList` (`attrs.start`, integer only); `listItem`; `blockquote`; `codeBlock` (no attrs); `hardBreak`; `horizontalRule`; `text` (a `text` string plus projected marks); `table`, `tableRow`, `tableHeader`, `tableCell` (no attrs, or integer `colspan` and `rowspan` only); `image` (`attrs.src`, `alt`, `title`, strings only).
- Allowed marks: `bold`, `italic`, `strike`, `underline`, `code`, and `link` (`attrs.href`, string only).
- Every other key on any node or mark is dropped. An unknown node type is unwrapped: its projected allowed descendants stay in place, and its own type and attrs are dropped. A non-string `text` is dropped.
- Caps: depth 32 and a node-count cap (engineering sets the value, for example 5000); truncation beyond a cap is tested.
- Cards: `front` and `back` strings only. Questions: `prompt` string (and `id`) only. `media_url`: string only.
- The client renderer applies the same allowlist again (defense in depth).

**Capability function (J-293-004, D-293-14).** `get_lesson_read_capability()` returns `jsonb` `{"lesson_read": 1}`; `language sql stable security definer`; EXECUTE `authenticated` only. It reads no table. It is explicit and also serves the owner surface, which is why it is preferred over a probe of the read RPC with a nil UUID.

Migration file `supabase/migrations/<timestamp after 202610160001>_issue293_student_lesson_content.sql`: `begin; set local lock_timeout '5s'; set local statement_timeout '60s';` then create or replace the projection helper (revoke all from `public`, `anon`, `authenticated`; no grant), the read function and the capability function; comment on each; revoke all on the read and capability functions from `public`, `anon`, `service_role`; grant execute on them to `authenticated`; `commit;`. Additive; writes nothing; no table, policy or data change.

Rollback file `supabase/rollbacks/issue293_student_lesson_content_rollback.sql` drops the three functions this migration creates (the read RPC, the capability function and the internal projection helper). No data is touched.

No Edge change.

### 5.2 Frontend interfaces (PR 293b)

- Content mapping: import the exported helpers from `src/services/lessonHandoutContent.ts` (`printableCards`, `printablePrompts`, `printableMedia`, `slotTitle`, and `HandoutLessonInput` at `:7-18`) and build a `HandoutLessonInput` from the RPC result. No second kind matrix and no new shared model module. #294 is merged, so the PDF builder and these helpers already exist.
- Safe renderer component (for example `src/components/lessonRead/TiptapContent.tsx`) per 4.9.
- Data service (for example `src/services/lessonReadData.ts`) with typed outcomes: `ready`, `not_found` (NULL, and also 22P02 or HTTP 400 as defense in depth), `unavailable` (PGRST202 or HTTP 404 naming the function, or 42883 only), `error`.
- Capability hook (for example `useLessonReadCapability`): one cached call to `get_lesson_read_capability` per page load; positive only on a successful response with `lesson_read = 1`; everything else, including pending, is unavailable (4.4).
- Gated copy and links: the card link in `LearnDetailPage`, the row link and the note switch in `ResourcesPanel` and `handoutStudentCopy`, and the disclosure switch in `HandoutsTab`, all read the hook.
- Owner image warning: in the `HandoutsTab` lesson panel next to the existing image notice (`HandoutSlot.tsx:144`, `lessonHasImages` at `lessonHandoutContent.ts:152-154`, extended to detect a missing alt) and in the Content tab for the selected lesson.
- Route matcher in `src/hooks/useRoute.ts` and `App.tsx` wiring under the existing `/learn` auth handling.
- Page (for example `src/pages/LearnLessonPage.tsx` plus CSS) implementing the J4 table, the states, the print stylesheet and the trigger clearance.
- Copy module `src/lib/lessonReadCopy.ts` per 4.8.
- Optional typed not-found discriminator in `fetchLearnCourse` (E1, D-293-13).

### 5.3 Compatibility matrix

| Combination | Behavior |
|---|---|
| New frontend, old backend or rolled-back 293a (functions missing) | The capability call is unavailable: no "Read online" link on cards or handout rows; the student note and owner disclosure keep exactly their shipped strings; a deep link to the lesson route shows the J7 calm state (no `role="alert"`) |
| New frontend, capability call errors (for example HTTP 500) or is still pending | Same as the row above (conservative) |
| New frontend, new backend | Links and option-A strings appear; the lesson page reads the RPC |
| New frontend, RPC returns NULL | J5 generic refusal with "← Back to your course" |
| New frontend, network or 5xx on the read RPC | J6 error with Retry |
| Old frontend, new backend | No change (the functions are unused) |

Gating is by the capability function (D-293-14). The rollout order stays binding as defense in depth.

## 6. Ordered work

PRs only, base `main`, never push to `main`, the user merges, serial single writer, T1 first-line in standard mode. The plan is approved and decisions D-293-1 to D-293-15 are adopted (2026-10-17); hosted actions still need separate approval.

**Step 0 (every PR).** Fetch origin and record the base SHA (expected `3594188` or later). The orchestrator runs `gh issue view 293 --comments`, `gh issue view 278` and `gh pr list --search 196 --state all` and records the results in the PR. Re-verify every cited `file:line`. Read the #269 diff (its exact change is Unknown from local evidence; Inference: frontend or test only) and reconcile it with this plan. Confirm #294 is on the base. Run the stale-plan check (section 13).

**PR 293a (S-M): backend, "Refs #293".**

1. RED live SQL tests first: `src/__tests__/issue293StudentLessonContentSql.test.ts`, live against the local stack.
2. The migration (5.1): projection helper, read function, capability function.
3. The rollback file (5.1), which drops the three functions.
4. No Edge change. CODE_REVIEW required.

**PR 293b (M-L): frontend, "Closes #293"** (unless Step 0 finds remaining #293 acceptance criteria).

1. Content mapping: import the exported helpers from `src/services/lessonHandoutContent.ts` and build a `HandoutLessonInput` from the RPC result (5.2). No second kind matrix.
2. Safe renderer component (4.9). Never `dangerouslySetInnerHTML`; link scheme allowlist; the same projection allowlist; unknown nodes flattened to text; image and media rules.
3. Data service with the typed outcomes (5.2).
4. Route matcher and `App.tsx` wiring.
5. Page, CSS, J4 resolution, states, print stylesheet and trigger clearance; the Back control reuses the `lesson_task` keys and mirrors `LearnQuizPage.tsx:47`.
6. Copy module, with Spanish drafts inert through the named approval constant (E4).
7. Capability hook `useLessonReadCapability` (4.4, 5.2).
8. `LearnDetailPage` card "Read online" link (quiet tier, never primary; only when `isMaterialsEligible`, not legacy, and the capability answer is positive) with focus return via `learn.returnFocus.{enrollmentId}`.
9. Handout-row "Read online" in `ResourcesPanel` for `lesson_handout` rows (#294 is merged), and the student note and owner disclosure switched to the option-A strings, all under the capability gate (4.4).
10. Owner image warning in the Handouts tab lesson panel and the Content tab (D-293-15).
11. Optional typed not-found discriminator in `fetchLearnCourse` (E1).
12. e2e spec `src/__tests__/e2e/issue293-lesson-read.spec.ts`.
13. Follow-up issue texts drafted by Scribe for the orchestrator: per-side language fields for vocabulary cards and prompts; image alt-text authoring (editing or requiring alt text in the workspace). The `lesson_revisions_student_read` hardening issue is filed by the coordinator and is not a fleet work item.

Dependencies: 293a before 293b. 293b merges only after hosted step H1 (migration applied and verified). #294 (#196 PR 8c) is already merged, so 293b builds on it (D-293-7 resolved). Owners: T1 (T2 per fleet escalation); Verifier; Browser Validator for 293b; Scribe for follow-up issue texts; orchestrator for `gh` actions after approval.

**Process rule for engineering and browser validation (user rule).** Run no more than one dev server per browser validation at a time. Record the PID of every server started (`vite`, and `netlify serve` if used) and stop each by PID (`Stop-Process -Id <pid>`) when its run ends. Nothing is left running; confirm at the end that nothing listens on 5180 (`Get-NetTCPConnection -LocalPort 5180` returns none). More than one server runs only intentionally, for example a comparison against `main`, and both are stopped afterwards. Skew runs S1, S2 and S3 are therefore sequential, with the frontend server stopped between them. At the end of the validation run, stop the mirror Supabase stack with `npx supabase stop` unless the coordinator says to keep it.

## 7. Acceptance and validation

Per PR: Step 0; `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`; full `npx vitest run` on a freshly reset local stack with no new failures versus the recorded baseline; RED shown failing then passing (record both); Verifier PASS; Browser Validator PASS for 293b; CODE_REVIEW where routed; PR opened against `main`; no merge by the fleet.

**RED tests, PR 293a (live SQL):**

- Open own lesson returns content.
- Released-early (`released` with `unlock_at` in the future) returns content.
- Future unlock returns NULL; held returns NULL; revoked returns NULL.
- No entitlement row (prerequisite) returns NULL.
- Another student's enrollment returns NULL.
- Inactive enrollment, deactivated account, forced password change each return NULL.
- A revision not mapped in the enrollment's version (including a v2-only revision for a v1 enrollment) returns NULL.
- A v1 enrollment still reads its own v1 lesson after v2 publishes.
- A legacy course returns NULL.
- Well-formed but nonexistent ids return NULL. Malformed text input fails uuid conversion with an error (SQLSTATE 22P02 or HTTP 400) and never returns NULL.
- Answer absence: a fixture with `assessment_answer_keys` rows plus planted answer keys at top level, in `metadata.questions[].answer` and in `content.quiz[].answer` yields no answer-bearing key or answer value anywhere in the result.
- Nested leaks (J-293-002): answer-bearing and owner-only keys inside paragraph attrs; extra keys on a heading; inside an unknown node type (for example `quizBlock` with `attrs.answer` and a child text node, whose child text must survive while its attrs and type do not); inside link mark attrs; inside image attrs (for example `data-answer`); extra keys on `listItem` and `text` nodes; at doc level (`answers`, `owner_notes`); owner-only field names (for example `owner_notes`, `assessment_key`) at several depths; nesting beyond the depth cap; and a body beyond the node-count cap. A recursive key walk in the test asserts that no key outside the allowlist exists anywhere in the result, and that the intended text survives.
- Kind gating: `rich_text`, `exercise`, `vocabulary`, `media`, `checkpoint` and an unknown kind, each carrying cards, questions and `mediaUrl`, return exactly the matrix parts (4.6). The SQL kind list equals `CARD_KINDS` read from `src/services/lessonHandoutContent.ts`.
- The result's top-level keys equal the allowlist.
- Capability function: returns `{"lesson_read": 1}` for an authenticated session; EXECUTE `authenticated` only.
- Catalog: EXECUTE for `authenticated` only on the read and capability functions (none for `anon`, `public`, `service_role`), SECURITY DEFINER, `search_path` public, STABLE; the projection helper has no EXECUTE for `public`, `anon` or `authenticated`.
- The functions write nothing (no row-count change across calls).
- The rollback drops the three functions and touches no data.

**293b unit and RTL:**

- Renderer node and mark mapping, heading rank compression, unknown nodes flattened, unsafe link schemes rendered as text, the same allowlist applied client-side, and a source scan showing no `dangerouslySetInnerHTML`.
- Image rendering: an absolute https image with alt shows the alt; an empty or missing alt adds the visible note; http, `data:`, relative and invalid sources show the "can't be shown here" note and load nothing.
- Media: an http or https value renders a link with `rel="noopener noreferrer"` and the hostname inside the anchor; any other non-empty value renders plain text "Media link: {value}" with no `href`; an empty value renders nothing.
- Parity test (4.6): per fixture kind (`rich_text`, `exercise`, `vocabulary`, `media`, `checkpoint`, unknown), the normalized text strings from `blocksFromDoc`, `printableMedia`, `printableCards` and `printablePrompts` equal the online page's rendered text strings, modulo exactly the listed differences. The test also fails if any answer text appears in either output.
- Data-service classification: PGRST202, HTTP 404 and 42883 map to `unavailable` only; NULL, 22P02 and HTTP 400 map to `not_found`; anything else maps to `error`.
- Capability hook: positive only on a successful response with `lesson_read = 1`; PGRST202, 404, 42883, 500 and pending are unavailable; one call per page load.
- Gating: with an unavailable capability, no "Read online" link on cards or handout rows, the student note equals the shipped string and the owner disclosure equals the `HandoutsTab.tsx:180` text; with a positive answer the links and the option-A strings appear.
- The J4 resolution table, including legacy plus skew, a failed course fetch with a successful RPC, a not-yours enrollment, and a malformed id making no request.
- Card link visibility per state and the one-primary rule unchanged.
- Title selection helper and h1 `lang`.
- The focus-return key is deleted on first read, including when the target is absent.
- Copy module: every Spanish entry in the new module is draft and none is rendered; with site language Spanish, functional strings render English with `lang="en"`.
- Owner image warning appears when any body image lacks a non-empty alt, in the Handouts tab lesson panel and the Content tab.
- No quiz-answer rendering (source scan).
- Copy scan: no string claims the PDF is accessible or the page is fully conformant.
- Deterministic no-native-dialog scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits (`window.print` is not used).

**293b e2e** (`src/__tests__/e2e/issue293-lesson-read.spec.ts`, chromium, one worker, a failing `page.on('dialog')` listener in every journey):

- Design brief journeys V1 to V18 (section 8) at 1440x900, 390x844 and 320x568.
- Forced colors (`page.emulateMedia({forcedColors:'active'})`) at 1440x900 and 320x568.
- Print emulation (`emulateMedia({media:'print'})`) checks.
- `@axe-core/playwright` `AxeBuilder` with tags `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `wcag22aa` returns zero violations on the ready, J5, J6, J7 and J8 states at every viewport. A WCAG 1.1.1 gap for an image without alt is expected from content, not from the page; the visible note is asserted instead and the gap is reported, not hidden.
- A keyboard-only journey.
- 320 reflow: document `scrollWidth <= clientWidth`.
- Heading outline and landmark structure assertions; `lang` attributes on sections and on the fallback h1.
- Focus not obscured by the Aa trigger at 320, 390 and 768 (V16).
- Refusal responses (J-293-007): for every refusal cause the `get_student_lesson_content` response body is exactly `null` (a malformed id makes no request); no response contains body, cards, prompts or media for a refused lesson; the page shows no lesson content. Lesson titles returned by `get_student_learn_course` are expected and allowed.
- Skew and rollback runs, executed sequentially with the frontend server stopped between them (section 6 process rule):
  - S1, the new 293b frontend against the mirror database without the 293a migration, asserts exact strings: no "Read online" text anywhere on `/learn` cards or handout rows; the student note equals "Printable handout for this lesson. If you need it in another format, ask your teacher."; the owner disclosure equals the `HandoutsTab.tsx:180` text; a deep link shows the exact J7 strings ("Reading lessons online isn't available yet" and "You can still use the lesson materials on your course page."); no `role="alert"`.
  - S2, the old frontend (`main` at the base) against the 293a backend, leaves `/learn` unchanged.
  - S3 (rollback), the new frontend after the 293a rollback file runs, gives the same assertions as S1.
  - A case where the capability call returns HTTP 500 (route-intercepted): links hidden, shipped strings shown.
  - Route-intercepted PGRST202 404 and 500 variants for the read RPC.

## 8. Browser UI dialog policy and browser validation

Dialog policy (required): no `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt` or `beforeunload`. This page uses no modal, so the modal keyboard and focus check is not applicable and is recorded as such. Any future acknowledgement uses the app-owned `src/components/Modal.tsx`. Status uses inline `role="status"` and `role="alert"` regions. `window.print` is not used. Verification: the deterministic source scan above and a failing `page.on('dialog')` listener in every journey.

`browser_ui_validation`:

- **Mirror.** The port-shifted untracked mirror pattern of `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (`supabase/config.toml` API 64321, DB 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`). Windows reserves 54314-54413. Copy PR files per file, never `robocopy /MIR`; never commit the mirror. For skew S1, keep the mirror database at `main` (no 293a migration) and serve the 293b frontend. For S3, apply the 293a migration, then the rollback file, and serve the 293b frontend.
- **Launch and readiness.** `npx supabase start`; `npx supabase db reset`; `docker restart supabase_rest_lizbeth_spanish supabase_kong_lizbeth_spanish` (PostgREST schema reload after a migration change; the first request may return 502); `npx vite --host 127.0.0.1 --port 5180 --strictPort`; ready when `http://127.0.0.1:5180` serves sign-in.
- **Dev-server hygiene (user rule).** At most one dev server per browser validation at a time. Record the PID of every server started (`vite`, and `netlify serve` if used) and stop each by PID (`Stop-Process -Id <pid>`) when its run ends, so nothing is left running. Confirm at the end that nothing listens on 5180 (`Get-NetTCPConnection -LocalPort 5180` returns none). More than one server runs only intentionally, for example a comparison against `main`, and both are stopped afterwards. Skew runs S1, S2 and S3 are sequential, with the frontend server stopped between them. At the end of the validation run, stop the mirror Supabase stack with `npx supabase stop` unless the coordinator says to keep it.
- **Test environment.** `SUPABASE_API_URL=http://127.0.0.1:64321` (or `LIZBETH_TEST_API_PORT=64321`), `SUPABASE_DB_PORT=64322`, `SUPABASE_SERVICE_ROLE_KEY=<from npx supabase status>`, `E2E_BASE_URL=http://127.0.0.1:5180`; run `npx playwright test src/__tests__/e2e/issue293-lesson-read.spec.ts --workers=1`.
- **Base URL.** `http://127.0.0.1:5180`.
- **Fixtures and reset.** `db reset` plus seed (`owner@test.local`, `student1@test.local`, `fullaccess@test.local`; password "password"). A per-journey disposable authored course via `createOwnerCourseFixture`, published, with these lessons (invented text is labelled "Placeholder"):
  - L1: `rich_text`, bilingual, with h1 to h3 headings (including TipTap levels 1, 2 and 4), nested bullet and ordered lists, bold, italic, strike, underline and code marks, links (https, mailto, relative, `javascript:`), blockquote, codeBlock, horizontalRule, hardBreak, a long unbroken word, vocabulary cards including long Spanish words (for example "responsabilidad", "desafortunadamente", and one placeholder word of 20 to 25 characters), and question prompts with answers stored in `assessment_answer_keys`.
  - L2: Spanish body only.
  - L3: title only in English (fallback h1 `lang`); a lesson with no `content.title` (plain-title fallback) is added.
  - L4: `media` kind with an https media URL plus cards and questions.
  - L5: `checkpoint` kind carrying cards, questions and a media URL (must show title and body only).
  - L6: `media` kind with a `javascript:` media value (renders as plain text "Media link: {value}" with no link); a relative and a `mailto:` media value variant render the same way.
  - L7: vocabulary-only.
  - L8: a very long title and a long unbroken URL.
  - L9: a revision with planted answer keys (top level, `metadata.questions[].answer`, `content.quiz[].answer`) inserted via the service role, plus the nested-leak shapes from section 7.
  - An `exercise` kind fixture and an unknown or other kind fixture; an empty-English variant; a nothing-at-all variant; a body with an imported table of more than two columns and an unnamed second imported table.
  - Image fixtures: an https image with alt, an https image without alt, an http image source, and a `data:` image source.
  - Entitlements via `set_lesson_access_state` and direct fixture rows: open, released-early, future-locked, held, revoked, and no entitlement (prerequisite).
  - Also: a second student (not-yours enrollment), a v1 enrollment after v2 publishes, a legacy band course (with and without entitlement rows, plus skew), a deactivated account, a forced-password-change student, a course-fetch failure with RPC success through route interception, and a capability call returning HTTP 500 through route interception.
  - Loopback-guarded cleanup in `afterEach` of rows and courses created by the test only. Site language reset to English after any Spanish check.
- **Viewports.** 1440x900, 390x844, 320x568; forced colors at 1440x900 and 320x568; print emulation; 768x1024 for V16; 1280x720 at 400% zoom (320 CSS px). Run the 200% text-size and OpenDyslexic font accessibility settings on the rich lesson.
- **Visible outcomes.** A semantic outline (one h1, sections with `lang`, vocabulary table with caption and column headers); no answers anywhere; no lesson content in refusal states; a calm skew state with no alert role; no horizontal scroll at 390 and 320; visible unobscured focus; forced-colors legibility; print showing only lesson content with link URLs; card and row links present only for eligible authored lessons after a positive capability answer and never primary; visible notes for images without a description or that cannot be shown; no raw backend text in the DOM.
- **Evidence.** Screenshots per state, viewport, forced-colors or print mode and skew mode; axe JSON; network logs; an accessibility-tree summary of the ready state; all under `browser-validation-artifacts/293/`. The record of server PIDs and the final port-5180 check are part of the evidence.

**Journeys** (design `browser_validation_brief`, revision 2, with the Revision 1 deltas):

| Id | Journey and visible outcome |
|---|---|
| V1 | Card to lesson. With a positive capability answer, an eligible authored card shows "Read online" first in its action cluster, quiet and underlined; the primary action is unchanged. Activate by Enter. The URL is the lesson route, the h1 equals the selected title and is focused, there is one h1, the outline is h1 > h2 (per kind) > h3 (rank-compressed, no skipped levels), the table has a visible caption and two `th[scope=col]`, prompts are an ordered list followed by "(Answers are not included.)", and for an http or https media value the media section (after the bodies, before Vocabulary) is a real anchor with the hostname inside it. No answer text anywhere. |
| V2 | Handout row to lesson. With a positive capability answer, the `lesson_handout` row in "Lesson materials" shows "Read online" after Download, with the accessible name "Read online: {title}", leading to the same page as V1. At 320px it wraps under Download without looking like a button. |
| V3 | Return. Back returns to the course page with focus on the originating "Read online" link (`lesson-read-link-{id}`), and the `sessionStorage` key is gone after load (also when the target is absent). Browser Back gives no error and default focus. A key left for another enrollment is not consumed. |
| V4 | Language order and draft gate. Site language Spanish shows the Español section first and the jump link text as the English functional string with `lang="en"` while the draft stands; "Español" and "English" headings appear in their own languages. Site language English shows English first. The jump link lands on the other h2 instantly, with a visible ring, below the trigger, and no `location.hash` change. The empty-language note in the Spanish section reads "This lesson has no Spanish text yet." with `lang="en"` inside the `lang="es"` section. A unit check confirms every Spanish entry is draft and none renders. |
| V5 | Refusal. Direct URL for locked, paused, unavailable, another student's enrollment, an invalid id and legacy-with-rows gives an identical generic view (h1 "This lesson isn't available right now.", one paragraph, Back labelled exactly "← Back to your course"), h1 focused, and no lesson content on the page. For every refusal cause the `get_student_lesson_content` response body is exactly `null` (a malformed id makes no request at all); no response contains body, cards, prompts or media for a refused lesson. Lesson titles returned by `get_student_learn_course` are expected and allowed (it returns every lesson title, F1). No card or row link on the course page for locked, paused or unavailable lessons. |
| V6 | Load error. With the RPC intercepted at HTTP 500, the `.form-error` alert is focused with Retry; Retry shows a busy state without losing focus; a success response renders the lesson and focuses the h1; a repeat failure re-announces. |
| V7 | Deploy skew and capability. With the capability call and the read RPC intercepted as PGRST202 (and, separately, with the capability call returning HTTP 500): no "Read online" text anywhere on `/learn` cards or handout rows; the student note equals exactly "Printable handout for this lesson. If you need it in another format, ask your teacher."; the owner disclosure equals exactly the current text at `HandoutsTab.tsx:180`; a deep link to the lesson route shows the J7 calm note (h1 "Reading lessons online isn't available yet", paragraph "You can still use the lesson materials on your course page.", no `role="alert"`, no Retry), and Back works. With a positive capability answer the links and option-A strings appear. With a legacy-no-entitlement enrollment and skew, the J8 legacy view shows instead and the RPC is not called. |
| V8 | Legacy. For an owned legacy course with no entitlement row, h1 "This lesson is on your classic Roadmap", the explanatory paragraph and a secondary "Go to Roadmap" link that reaches the Roadmap; the RPC is not called. A legacy enrollment the student does not own shows J5, never J8. No card or row links on the legacy course page. |
| V9 | Content-shape states. Empty English keeps the English h2 with the one-line note and the jump link; vocabulary-and-prompts-only shows both empty notes then the table and prompts; nothing-at-all shows h1, fact line and the single "no online content yet" note; a `javascript:` body link renders as plain text; an imported table sits in a focusable labelled scroll region ("Table 1", "Table 2" when unnamed) while the page does not scroll horizontally; an https image with alt shows the alt; an https image without alt shows the note "This image has no description. Ask your teacher what it shows." directly after it; http and `data:` image sources show "This lesson includes an image that can't be shown here. Ask your teacher about it." in place of the image; a non-http media value shows plain text "Media link: {value}" with no link. |
| V10 | Reflow. At 320x568 and at 400% zoom there is no horizontal page scroll (`scrollWidth <= clientWidth`), long words and URLs wrap, the vocabulary table stays a two-column real table, and the h1 fits beside the Aa trigger. Record whether the long Spanish placeholder word breaks mid-word. |
| V11 | Keyboard only. Tab order is Back, jump link, body links (first language then second), any table scroll regions, media link. Every stop shows a 3px slate ring, there are no traps, and h1 and h2 are not tab stops. An accessibility-tree review confirms `lang` on each section, the table caption, and `lang="en"` on the fallback English title. |
| V12 | Forced colors. Table cell borders, section rules, the focus ring (`Highlight`) and link underlines are visible, and the error container keeps its border. |
| V13 | Print. On the rich standard and media lessons at A4 portrait, only lesson content shows (h1, fact line, both sections, the media section for the media kind, vocabulary table, practice questions); no header, footer, trigger, Back, jump link, status or `.control`; black on white; http and mailto targets appended; images fit; headings are not stranded at page bottoms; table rows are not split; the table header repeats on break; both language sections are included. |
| V14 | Automated. Axe (WCAG 2.2 AA tags) is clean on ready (Spanish and English, each kind), refusal, error, skew and legacy; the no-native-dialog scan passes; a contrast computation confirms the pairs in 4.10. |
| V15 | No answers. Network and DOM inspection of every kind fixture, including the nested-leak fixture, shows no answer fields, answer-key data or `assessment_answer_keys` content. |
| V16 | Focus not obscured. At 320x568, 390x844 and 768x1024, scroll the rich lesson and Tab through the jump link, body links, the table scroll region and the media link, and activate the jump link. After each step the focused element is not entirely behind the fixed trigger (its bounding box is not fully covered by the trigger's 3rem box at top 1rem, right 1rem), and the jump target h2 sits at least 4.5rem below the viewport top. |
| V17 | Kind parity. For `rich_text`, `exercise`, `vocabulary`, `media`, `checkpoint` and other-kind fixtures the online content set equals the PDF content set modulo the intentional differences in 4.6 (also enforced by the parity test); the checkpoint shows no Vocabulary, Practice or Lesson media section even though its revision holds that data. |
| V18 | Title language. With site language Spanish on an English-title-only lesson, the h1 and the `<title>` element carry `lang="en"`, the document title shows the English title, and the card and row aria-labels use the same title. |

Plus skew S1, S2 and S3, the capability HTTP 500 case, and the route-intercepted 404 and 500 variants.

## 9. Judge route

Shadow (advisory) per `docs/JUDGE-CONTRACT.md`. The Codex judge model is `gpt-6-astra` (user standing rule).

- PLAN_DUCK was run on the first draft (J-293-001..007, folded in as Revision 1); a second PLAN_DUCK on Revision 1 is eligible before approval (the orchestrator runs it).
- CODE_REVIEW is required for PR 293a (SECURITY DEFINER read RPC, recursive projection helper, capability function, answer-free projection, grants) and recommended for PR 293b.
- VERIFICATION_CHALLENGE is optional for 293a refusal-matrix and nested-leak coverage.
- VISUAL_REVIEW is optional for 293b.
- Respect the two and four call caps. Deterministic failures dominate. Finding ids flow into the engineering job and the Verifier brief. No live Codex call without explicit usage approval. No judge result beyond the PLAN_DUCK findings summarized in Revision 1 is reported here.

## 10. Risks, rollback and hosted rollout

| Id | Risk | Mitigation |
|---|---|---|
| R1 | Content leak through the SECURITY DEFINER function (answers, other students, locked lessons) | Recursive allowlist projection of every TipTap body (node types, marks and attrs; unknown nodes unwrapped; depth and node-count caps) with nothing passed through from `content`; canonical predicate; NULL refusal; refusal-matrix, nested-leak and answer-absence tests with a recursive key walk; catalog test; CODE_REVIEW |
| R2 | Predicate drift from the canonical rule | Copy the `get_student_lesson_assets` and `record_lesson_completion` predicate; released-early and held/revoked tests |
| R3 | XSS through authored TipTap content | React element renderer, no raw HTML, scheme allowlist, unknown nodes as text, source scan |
| R4 | Deploy skew | Capability function gate (conservative: links and new copy only after a positive answer), binding order as defense in depth, exact unavailable classification for the page, skew e2e S1, S2 and S3 with exact-string assertions |
| R5 | Honest-disclosure violation (owner or student copy claims an online lesson before it exists) | Option-A strings appear only while the capability answer is positive; otherwise the shipped strings stay exactly; skew exact-string assertions; copy scan |
| R6 | Partial 3.1.2 for cards and prompts | Disclosed limitation, no full-conformance claim, follow-up issue |
| R7 | Content parity drift between PDF and online view | Import of the `lessonHandoutContent.ts` helpers, no second kind matrix, SQL kind list equals `CARD_KINDS` (tested), parity test |
| R8 | Drift in the merged #294 code that 293b consumes (`lessonHandoutContent.ts`, `ResourcesPanel`, `learnMaterials`, `HandoutsTab`, `HandoutSlot`, `handoutStudentCopy`) | Import rather than copy, parity test, Step 0 check; D-293-7 is resolved |
| R9 | Hosted migration ordering | `supabase db push` applies every pending migration; apply the 293a migration only after earlier pending migrations have their own approvals, or together only with explicit approval naming each |
| R10 | The existing RLS gap F6 remains | Out of scope; follow-up issue filed by the coordinator |
| R11 | Focus obscured by the fixed Aa trigger | Clearance rule (4.12), V16 |
| R12 | Imported images without alt text leave a WCAG 1.1.1 gap | Visible student notes, owner warning, H0 q4 counts images with and without alt, disclosed residual gap, follow-up issue for alt authoring |
| R13 | A media value that is not an http or https URL | Rendered as plain text with no link, so the content set still equals the PDF's and nothing executes |
| R14 | #269 (gate) has an unknown scope | Step 0 reads the diff and reconciles it with this plan |

Rollback: revert 293b (Netlify redeploy); run the 293a rollback file, which drops only the three functions this migration created. A deployed 293b then sees the capability call fail, hides every "Read online" link and keeps the shipped strings (S3), and a deep link shows the J7 calm state. No data is written, so there is nothing to restore.

Hosted rollout (each step separately approved; the user runs hosted actions):

- **H0**, read-only queries the user runs:
  - q1: `supabase_migrations.schema_migrations` pending list versus `main`.
  - q2: count of authored (`legacy_band_id` null) lesson revisions mapped in published versions with active enrollments, by content shape (body object with `es`/`en`, single body, structured legacy shape, string title).
  - q3: count of those revisions whose content contains any answer-bearing key (`answer`, `answers`, `answer_key`, `assessment_key`) at any depth (expected 0 from the editor; any hit confirms the allowlist need).
  - q4: count of image or table nodes in those bodies, and the number of images with and without a non-empty alt.
  - q5: distribution of `content.kind` and of `metadata.cards`, `metadata.questions` and `mediaUrl` presence per kind.
- **H1**: apply the 293a migration (after R9), then a read-only catalog verification: the three functions exist, the read and capability functions are SECURITY DEFINER with EXECUTE `authenticated` only, and the projection helper has no EXECUTE for `public`, `anon` or `authenticated`.
- **H2**: the user merges 293b (Netlify deploys) only after H1 is verified. Read-only smoke: a signed-out visit to the route goes to sign-in. Any signed-in student smoke only with a test student on a non-production-relevant test course and with explicit approval.

## 11. Assumptions and unknowns

Safe assumptions:

- The enrollment's `course_version_id` is the version a student sees (as `get_student_learn_course`).
- `course_versions.status = 'published'` applies to older published versions too.
- Site-language resolution through `useSiteLanguage` is available on `/learn`.
- supabase-js surfaces a missing function as PGRST202 or HTTP 404 (engineering confirms locally with a mirror lacking the migration).
- `sessionStorage` is acceptable for one-shot focus return because `navigate()` carries no state.
- Handout rows carry `kind === 'lesson_handout'` and `language` (#294 is merged; `learnMaterials.ts:86-101`).
- The viewport (`html`) is the scroll container for the clearance rule; if a nested scroller is found, the rule moves to that scroller's `scroll-padding-top`.

Unknowns:

- The text and acceptance criteria of issue #293 and of #278 (F13).
- The exact change of #269 (F13), and the live remote SHA of `main`.
- Hosted content shapes (H0 q2 to q5), including how many imported images lack alt text.
- The exact RPC key names.
- How `selectLessonTitle` and `slotTitle` reconcile on the final fallback (4.6).
- Whether any `u` mark ambiguity or an owner alt-text policy needs an owner call.
- Contrast ratios and 320px cell widths (hand-computed only).
- The hosted pending-migration set.

## 12. Decisions

Adopted 2026-10-17: the user approved the plan, and every decision D-293-1 through D-293-15 is adopted at its recommendation in the right column. Hosted actions still need separate explicit approval. Changed in Revision 1: D-293-1, D-293-7, D-293-10. New: D-293-14, D-293-15.

| Id | Decision | Recommendation |
|---|---|---|
| D-293-1 | Read path: a new additive SECURITY DEFINER RPC `get_student_lesson_content` with the canonical predicate and a recursive allowlist projection of each TipTap body (nothing passed through from `content`), versus a direct RLS select of `lesson_revisions` (rejected: weaker non-canonical predicate F6, raw content, no kind gating or version mapping). (Changed: recursive projection.) | RPC |
| D-293-2 | Version scope: the enrollment's own pinned published version, not the course's current version, matching #196 per-version serving and `get_student_learn_course`. | Enrollment's own version |
| D-293-3 | Renderer: a custom React renderer of TipTap JSON with allowlisted nodes and marks and a URL scheme allowlist and no new dependency, versus `@tiptap/core` `generateHTML` plus a sanitizer dependency (DOMPurify) or `@tiptap/static-renderer` (a new dependency that needs install approval). | Custom renderer, no dependency |
| D-293-4 | Language presentation: both bodies always rendered, site language first, each section with `lang`; no toggle. | Yes, per the reviewed design |
| D-293-5 | Student label "Read online" (Spanish draft "Leer en línea") replacing the earlier placeholder "Open the online lesson"; Lizbeth approves the vocabulary and all Spanish drafts; English ships, Spanish stays inert until approved. | Yes |
| D-293-6 | Vocabulary cards and prompts carry no `lang` attribute (not language-keyed; no heuristic detection); disclosed partial 3.1.2 limitation; follow-up issue for per-side language fields. | Accept with disclosure |
| D-293-7 | Sequencing with #196 PR 8c: resolved. #294 is merged, so 293b builds on it and includes the handout-row "Read online" link, the student note change ("Printable handout for this lesson.") and the owner disclosure change ("Students can read this lesson online. This PDF is a printable version of it."), all under the capability gate of D-293-14. (Changed: resolved.) | Resolved |
| D-293-8 | The view is read-only: no "open" progress record, no auto-completion, no task or quiz embedding (links only). | Yes |
| D-293-9 | No Print button; print stylesheet only (`window.print` is not a prohibited dialog, but it is unnecessary). | Yes |
| D-293-10 | Follow-up filed by the coordinator; out of scope. (The issue hardens `lesson_revisions_student_read` with the account-active, password-change and canonical-predicate checks, noting the legacy `learnMaterials` bridge dependency.) (Changed.) | Yes, follow-up |
| D-293-11 | Hosted post-deploy smoke stays read-only; any signed-in student smoke only on a test course with explicit approval. | Yes |
| D-293-12 | Legacy courses: the route is authored-only; legacy course cards get no "Read online" link; a legacy deep link resolves to the J8 Roadmap pointer per the J4 table. | Yes |
| D-293-13 | Add a typed not-found discriminator to `fetchLearnCourse` (E1) so "RPC not called" assertions hold, versus visible-outcome-only assertions. | Add the discriminator if it is a behavior-preserving additive change; else relax |
| D-293-14 | Capability signal: an additive `get_lesson_read_capability()` in the 293a migration returning `{"lesson_read": 1}` (explicit, also serves the owner surface), versus a nil-UUID probe of the read RPC. Gating is conservative: any error or pending call means unavailable. (New.) | Capability function |
| D-293-15 | Imported images without alt text: an English-only owner warning (Handouts tab lesson panel and Content tab) and student visible notes, versus requiring alt text before publish (rejected for now: there is no in-app way to add alt text). (New.) | Warning |

## 13. Approvals and stale-plan conditions

Approvals required:

1. Explicit user approval of this plan. Granted 2026-10-17 (see the Status line).
2. Answers to D-293-1 to D-293-15. Adopted at their recommendations 2026-10-17.
3. Lizbeth's approval of every Spanish string and of the "Read online" label before any Spanish student string ships.
4. Separate approval for hosted steps H1 and H2 (H0 is user-run and read-only).
5. No commit to `main`, merge, deploy or live Codex call without explicit instruction.

Stale-plan conditions:

- `origin/main` moves past `3594188` with changes to any cited file: `LearnDetailPage.tsx`, `LearnQuizPage.tsx`, `useRoute.ts`, `App.tsx`, `learnMaterials.ts`, `learnData.ts`, `ResourcesPanel.tsx`, `HandoutsTab.tsx`, `HandoutSlot.tsx`, `handoutStudentCopy.ts`, `lessonTaskCopy.ts`, `lessonHandoutContent.ts`, `lessonHandoutPdf.ts`, either `courseAuthoring.ts`, or the `202610160001`, `202610040006`, `202610150002` and `202608280003` functions and policies.
- The Step 0 reading of #269 shows a change to a cited file or to the entitlement or gate behavior.
- The criteria in `gh issue view 293` differ materially from this plan's outcome.
- The merged #294 code changes `CARD_KINDS`, the printable helpers, the student copy, the owner disclosure or the PDF content order.
- A student lesson route lands.
- `lesson_revisions_student_read` or the canonical predicate changes.
- The content model or `CourseBlockKind` changes.
- H0 q2 to q5 find shapes the allowlist does not cover.
- The hosted pending-migration set changes.
