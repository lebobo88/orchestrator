# Lizbeth Spanish, Issue #178: self-paced, online-only Communicative Practice

Status: APPROVED by the user on 2026-10-03 (all four approved together in the orchestrator session). Cleared for engineering per this plan. Gate E (exemplar approval) and Step 10 (hosted reconciliation) each still need their own later approval, described below.

Plan ID: `lizbeth-spanish-issue178-self-paced-practice`
Route: engineering (mixed: curriculum content authored by Scribe; tooling, tests, and regeneration by the engineering fleet)
Target: `H:\CommandCenter\orchestrator\lizbeth_spanish` (own git repo, branch from `main`) plus the nested, independent repo `H:\CommandCenter\orchestrator\lizbeth_spanish\tools\lesson-generation`
Source issue: GitHub `lebobo88/lizbeth-spanish#178` "Practice segment: self-paced, online-only (rewrite 78 activities, spec, generator)", part of epic #172
Engineering mode: standard (team authorization: not applicable)
Downstream owner: engineering-fleet (T1 for tooling, tests, regeneration, and local refresh; Scribe for the spec amendment and all 78 content rewrites, sequenced by the orchestrator per the ordered work below)
Research evidence: none. Research was not needed: the user supplied the pedagogical decisions and the pattern menu, and no current external fact changes the plan.

## Outcome and audience

Observable result: every one of the 78 Communicative Practice activities (`curriculum/lessons/<band>-week-NN/practice-activity.md`) is a self-paced, online-only, text-response task that a single learner can complete alone in the app. The curriculum spec states this delivery rule. The generators no longer emit classroom role-play framing. Derived artifacts (content-source TypeScript, `lesson-content.json`, instructor PPTX) are regenerated. A deterministic test prevents classroom framing from returning.

Audience:

- Self-paced adult online learners (the student-facing practice text).
- The course owner (content review at the gates below).
- Downstream issue #179 (submission task form), which will template the new task-prompt structure defined here.

## User decisions (binding)

- Practice is SELF-PACED and ONLINE-ONLY.
- TEXT RESPONSES ONLY. There is no in-app audio recording; that is deferred to a later issue. `handoff.md:316-320` at the orchestrator root already says record/upload/playback needs its own design increment.
- Students will submit practice responses through the task form built in #179. This plan defines a clearly structured "task prompt" that #179 can template. This plan must NOT build the submission form.
- KEEP: the 20-minute Practice segment, the 30/10/20 rhythm (§5.1), the band task types (§5.4: Beginner controlled, Intermediate situational/task-based, Advanced content-based or project-based), the dialect and register requirements (§5.4 last paragraph, §4.2-4.4, §6), and the five-pillar can-do outcomes.

## Scope and non-goals

In scope:

1. Amend `curriculum/curriculum-architecture.md` §5.4 with a virtual self-paced delivery rule and an approved pattern menu.
2. Rewrite all 78 `practice-activity.md` files (exemplar beginner-week-01 first, then band batches), renaming "Materials needed" to "Digital materials" and adding a fixed "Task prompt" section.
3. Fix `tools/lesson-generation/lesson_generator.py` practice parsing and PPTX practice slide, and `generate_lesson_ts.py` as needed.
4. Regenerate `content-source/<band>WeekNN.ts` practice blocks, `supabase/storage-seed/lesson-assets/<band>/week-NN/lesson-content.json` (exactly 78), and the 78 instructor PPTX files.
5. Update pinned tests only where titles or summaries actually change.
6. Add a deterministic classroom-term detection test, seeded RED against current content.
7. Local storage refresh. Production reconciliation is documented as a separate, user-gated step (Step 10).

Non-goals:

- Submission form or UI, response storage, and grading (all #179).
- Audio recording, upload, or playback.
- Any change to the `LessonContent` TypeScript schema or to `LessonContentView.tsx` component or layout.
- Changes to the Phrases or Q&A segments. §5.2 and §5.3 are left as-is; §5.3's "live or asynchronous" wording is noted but not edited.
- Student PDF/DOCX regeneration. `PDFGenerator` has no practice section, so student handouts are unaffected.
- Hosted or production writes.
- Phases 7-8 tracks.
- The storage content-type fix (#173).

## Repository findings

Items are observations unless marked INFERENCE/RISK or "re-check".

### Curriculum spec

- `curriculum/curriculum-architecture.md` §5.1 table, lines 199-205: Practice is "Communicative Practice | 20 minutes"; the rhythm is advisory.
- §5.3, line 221, says Q&A is "a live or asynchronous 10-minute format".
- §5.4, lines 223-231, defines the band task types and the dialect-context rule but never states delivery modality.
- §5.5, line 241, references the instructor-facing PPTX and the student PDF.

### The 78 practice files

- 78 `practice-activity.md` files exist (26 per band, beginner/intermediate/advanced, weeks 01-26).
- Shared skeleton, verified in beginner-week-01 and advanced-week-05: an "# Communicative Practice ..." H1; an intro "Segment 3 of 3 ... Type: ..."; one "## <Spanish name> (<English>)" H2 activity heading; "### Timing breakdown (20 minutes total)" table; "### Setup"; rounds; "### Debrief"; "## Accessibility and inclusion note"; "## Materials needed"; "## Grounding". Advanced-week-05 also has "### The scenario (read aloud or distributed ...)".
- Classroom framing is pervasive. A broad case-insensitive scan (classroom, classmate(s), circulat*, instructor, role card(s), printed, handout, whiteboard, index card, name tag, stand(ing) up, pair(s), small group(s), the room, mingle, aloud) returned 931 hits across 78/78 files. The job brief's narrower count was about 409; both confirm 78/78.
- beginner-week-01 contains physical role cards, "Students circulate the room", "instructor collects", printed/projected cards, name tags, and a seated partner-rotation accessibility alternative.
- beginner-week-01 is the declared reusable template (`curriculum/lessons/beginner-week-01/README.md` line 4: "serving as the reusable template for Phase 6"). The brief's claim that beginner-week-04/05/06 cite it was NOT reproduced by a local grep for "week 1|week-01|Mercado|reusable" in those folders. Re-check during execution.
- Cross-references to the week-01 activity title "El Mercado de Presentaciones" exist outside week-01: `curriculum/lessons/beginner-week-03/practice-activity.md`, `curriculum/lessons/beginner-week-08/vocabulary-list.md`, `curriculum/lessons/beginner-week-01/README.md`, `content-source/beginnerWeek01.ts` and `beginnerWeek03.ts`, storage-seed week-01 and week-03 `lesson-content.json`, and `src/__tests__/lessonContent.test.ts`.

### Generators (nested repo)

- `tools/lesson-generation/lesson_generator.py`: `_parse_practice_activity` (lines 403-437) takes the first "## ... (" heading as the name and hardcodes type `'role-play'`, timing 20, and `role_cards=_extract_role_cards` (lines 439-464, which parses a table whose header contains "Student character"). `_add_practice_slide` (lines 700-722) writes "Practice Activity: <name>", "Duration", "Type: Role-Play", and "Role cards: N". `PDFGenerator` (line 740+) has no practice section. The CLI (`main`, lines 1138-1173) generates PPTX only when `--pptx-output` is given and PDF only when `--pdf-output` is given, so PPTX can be regenerated without Word COM or PDF.
- `tools/lesson-generation/generate_lesson_ts.py` `parse_practice` (lines 399-425): title is the first "## " heading; duration is the first "(\d+) minutes total" match (default 20); summary is the first block after the title up to the next "##"/"###" heading, with newlines collapsed. The rewritten files must therefore keep the activity H2 as the first H2, keep the "20 minutes total" phrase, and put the student-facing summary paragraph immediately under the H2.
- `tools/lesson-generation` is a SEPARATE nested git repo: it has its own `.git` (branch `main`, `.git/config` has NO remote), and the outer repo ignores it (`lizbeth_spanish/.gitignore` lines 49-54: "/tools/lesson-generation/" kept untracked and independent, no submodule).
- Nested tests: `test_lesson_generator.py` (lines 731-767, `test_title_slide_and_practice_activity_per_week`, asserts activity names "El Mercado de Presentaciones", "La Agenda Semanal", "En el Restaurante" and uses absolute `H:/` paths) and `test_generate_lesson_ts.py` (lines 40-57 and 213-240, practice parsing fixtures). No existing test asserts role cards or "Role-Play".

### Derived chain

`practice-activity.md` -> `generate_lesson_ts.py` -> `content-source/<band>WeekNN.ts` `practice{title, summary, durationMinutes}` (top-level `content-source/`, for example `content-source/beginnerWeek01.ts` line 169) -> `scripts/generate-lesson-content-json.ts` (decision D-2 in its header: generated FROM the TS modules because they are byte-for-byte what production rendered; line 247 fails unless exactly 78 artifacts are written) -> `supabase/storage-seed/lesson-assets/<band>/week-NN/lesson-content.json` -> local storage via `supabase/config.toml` `objects_path` on `npx supabase db reset` (README lines 186-198) or hosted via `scripts/provision-lessons.ts` (README line 215, for hosted targets) -> `src/components/LessonContentView.tsx` lines 320-324, which renders only `<h3>{practice.title}</h3><p>{practice.summary}</p>`.

INFERENCE/RISK: running `generate_lesson_ts.py` to fully regenerate a content-source module could change non-practice fields if the markdown and the TS have drifted (D-2 says TS is the production truth). Content-source updates must therefore be practice-block-only.

### Pinned tests

- `src/__tests__/lessonContent.test.ts:76-80`: week-01 title `/mercado de presentaciones/i`, duration 20.
- `src/__tests__/LessonContentView.test.tsx:198-205`: `getByText /mercado de presentaciones/i` after clicking the Practice tab.
- `src/__tests__/lessonContentLoading.test.ts:108-112`: week-02 title 'La Agenda Semanal (The Weekly Planner)'; and `:144-148`: week-03 title 'Mi Árbol Familiar (My Family Tree)'.
- `src/__tests__/lessonContentViewPanelMounting.test.tsx:215-219`: renders `content.practice.summary` (data-driven).
- `src/__tests__/generateLessonContentJson.test.ts:82` and the WeekDetailPage / `weekDetailMobileHeaderChrome` tests use synthetic fixtures (unaffected).
- `tools/lesson-generation/test_lesson_generator.py:753`.

### Authoring and hosted state

- `supabase/functions/course-authoring/index.ts` lines 131-145 (`get_version`) hydrates `lesson_revisions.content` from the `lesson_content` course_asset in storage at read time. Hosted `lesson_revisions` rows and hosted storage objects may still hold the old classroom text until a hosted re-provision or republish.
- Generated binaries: each lesson folder holds `<name>-instructor.pptx`, `-student-handout.docx`, and `-student-handout.pdf`, tracked in the outer repo.

### Launch facts

`package.json` scripts: `dev=vite` (`predev` ensures the lesson-assets bucket), `test=vitest`, `test:e2e=playwright`. `vite.config.ts` port 5173. README: `npx supabase start`; `npx supabase db reset` repopulates the full 78-week catalog and storage-seed; app at `http://localhost:5173`; seed accounts `student1-6@test.local` and `owner@test.local`.

## Design route and handoff

DESIGN_ROUTE profile: none. Reasons: no component, layout, state, token, or interaction change; `LessonContentView` renders the same title and summary text nodes. Agents required: none. Prototype: forbidden. Model tier: not applicable. Existing system mode: preserve. Design handoff: none. Design review: none.

Guardrail: rewritten summaries should stay within the current summary length range. Measure min and max across the 78 current summaries at Step 0, and flag any summary more than about 25% longer than the current max, so the rendered panel does not need design work. If execution finds a needed UI change, stop and return to planning for a Compact route.

## Judge route

Per `docs/JUDGE-CONTRACT.md`; policy is currently shadow.

- PLAN_DUCK: eligible (multi-file content plus tooling plan, user-visible text). The orchestrator runs it before approval; findings are advisory in shadow.
- CODE_REVIEW: eligible for the tooling and test diff (`lesson_generator.py`, `generate_lesson_ts.py`, the new detection test) after JOB_DONE and before Verifier.
- VERIFICATION_CHALLENGE: optional, only if per-batch coverage evidence is weak.
- VISUAL_REVIEW: skipped (no design route, not brand-critical UI).
- Standard cap: at most two calls; additional calls need user approval. Deterministic test failures always dominate.

PLAN_DUCK has since run once; its result is recorded in the Plan review record below. No CODE_REVIEW or VERIFICATION_CHALLENGE findings have been observed yet.

## Plan review record

PLAN_DUCK (Codex, shadow/advisory) returned REVISE with four findings, J-001 through J-004 (three major, one minor). All four were accepted and are resolved by this revision:

| ID | Topic | Resolution in this plan |
| --- | --- | --- |
| J-001 | Nested repo delivery path | Tracked `git format-patch` artifact in the main repo (Steps 0, 6, 9; risks table). |
| J-002 | Deterministic Task prompt and timing parser | Shared parser plus vitest checks in Step 1, a matching pytest in Step 6, acceptance items. |
| J-003 | Reproducible per-week conformance artifact | Baseline manifest generated at Step 0 and a per-week conformance test in Step 1. |
| J-004 | Seeded-RED denominator and baseline report | Precise 702-check denominator and tracked baseline and final reports (Steps 1 and 7). |

The four items previously listed as open decisions are now recorded decisions (see Assumptions and decisions). The judge findings are advisory in shadow mode; the dispositions above are the plan author's recorded responses, and deterministic tests remain the authority.

## Ordered work

### Step 0: branches and baseline (owner: T1)

- Outer repo: create branch `issue-178-self-paced-practice` from `main`.
- Nested repo `tools/lesson-generation`: create a local branch of the same name from its `main` (no remote exists; there is no PR for it).
- Record the nested repo base commit: `git -C tools/lesson-generation rev-parse HEAD` (call it `BASE_SHA`). Step 9 uses it to export the tooling patch series.
- Record the baseline: outer `npx vitest run` and nested `pytest` results; current classroom-term scan counts; current practice summary length min and max; and SHA-256 of all 78 `lesson-content.json` files.
- Generate the tracked baseline manifest `curriculum/practice-baseline-manifest.json` from the CURRENT sources, before any rewrite, using a deterministic script (for example `scripts/build-practice-baseline-manifest.ts`). One record per week (78) with:
  - band and week;
  - activity title;
  - band task type from §5.4;
  - phrase-group labels (Group A..E) present in that week's `phrases-and-qa.md`;
  - dialect zone names (fixed vocabulary from the §4.2 ten-location table);
  - register tokens (tú, usted, vos/voseo, vosotros) and business-channel tokens (in-person, phone, email, §6 references) found in that week's current `practice-activity.md` and dialect notes;
  - the can-do statements from that week's README or `phrases-and-qa.md` overview, each with an explicit can-do reference id or number.
  
  Re-running the script on the baseline commit must reproduce the file byte-for-byte.

### Step 1: detection test, seeded RED (owner: T1, TDD)

Add `src/__tests__/practiceSelfPacedContent.test.ts` (vitest; reads files via `fs`, no network) covering three surfaces:

- (a) `curriculum/lessons/*/practice-activity.md` full text.
- (b) `content-source/*Week*.ts` `practice.title` and `practice.summary` (import the modules).
- (c) `supabase/storage-seed/lesson-assets/*/week-*/lesson-content.json` practice fields.

Denylist (case-insensitive, word-boundary): classroom, classmate(s), circulate/circulating, the room, mingle, instructor (distributes|collects|reads|calls|assigns|walks), role card(s) when physical (printed/distribute/hand out), printed, projected, handout (as a physical artifact), whiteboard, board (as classroom board), index card, name tag, stand up/standing, seated, raise (your) hand, in class, partner-rotation, "read aloud to the class", small groups, "pairs report", "the teacher".

Scoped allow-list: entries keyed by (file glob, exact phrase, justification) only. Required initial entries:

- Business "in-person register" references to §6.1.
- "negotiation role play(s)" as a named business genre.
- "Group A/B/C/D/E" phrase-group labels.
- Dialogue content in which characters inside a scripted scenario speak of their own physical setting, allowed only inside clearly marked dialogue or card text, with each instance listed.

No global wildcard allow entries.

Structural assertions per file: exactly one activity H2 as the first H2; "20 minutes total" present; a "## Task prompt" section with all required fields (Step 3); "## Digital materials" present and "## Materials needed" absent; a "Pattern:" line naming one approved §5.4 pattern.

Implement as per-week cases plus a `PENDING_WEEKS` list. Converted weeks must pass all checks. A separate completeness test asserts `PENDING_WEEKS` is empty and remains RED until the last batch.

Deterministic Task prompt and timing parser (J-002). Add a parser (for example `src/__tests__/helpers/parsePracticeActivity.ts`) used by the vitest suite. Per activity it enforces:

- exactly one "## Task prompt" section;
- the eight fields `Scenario:`, `Your role(s):`, `What to write:`, `Length and format:`, `Register and dialect:`, `Use these phrases:`, `Success checklist:`, `Model answer:` each present exactly once, in that fixed order, and non-empty;
- `Success checklist:` has 3-6 bullet items, and `Model answer:` is non-empty;
- exactly one "Pattern:" line whose value is in the approved §5.4 menu;
- the Timing breakdown heading contains "(20 minutes total)" AND the Minutes column of the timing table sums to exactly 20;
- the first H2 is the activity title, and the following paragraph (the in-app summary) contains no Task prompt field label and no "Model answer".

This parser is the reference contract for #179.

Per-week conformance test (J-003), part of the Step 1 suite and governed by `PENDING_WEEKS`. For every rewritten week it asserts, against `curriculum/practice-baseline-manifest.json` (Step 0):

- the Pattern is allowed for the band;
- "Use these phrases" names only groups that exist for that week and includes every baseline group the old activity used;
- every baseline zone, register, and business-channel token is still present in the rewritten file (exceptions only through a scoped, justified exception list keyed by week plus token);
- the Grounding section cites the week's can-do statements, and the Success checklist has at least one item per baseline can-do statement, matched by the explicit can-do reference id or number recorded in the manifest.

The per-batch Verifier rubric (Step 5) remains for semantic quality and runs on top of this deterministic floor.

Seeded-RED denominator and baseline report (J-004). Three surfaces, each with 78 units: A = 78 `practice-activity.md` files; B = 78 content-source modules' `practice.title` plus `practice.summary`; C = 78 `lesson-content.json` practice fields. Checks per unit:

| Surface | Checks per unit | Check results |
| --- | --- | --- |
| A | denylist, structure, Task prompt parser, timing sum, conformance (5) | 390 |
| B | denylist, summary-has-no-field-labels (2) | 156 |
| C | denylist, summary-has-no-field-labels (2) | 156 |
| Total | | 702 |

A deterministic script (for example `scripts/report-practice-checks.ts`) writes a tracked report `docs/evidence/issue-178/practice-checks-baseline.json` at Step 1, with per-surface, per-check, per-week pass/fail, denylist hit counts, and totals. Expected seeded RED: surface A 78/78 units failing; surfaces B and C failing counts recorded exactly as measured (observation from the planner: a quick scan already shows at least 26 summaries with denylisted terms).

Seed RED evidence: run once against current content with `PENDING_WEEKS` empty and record failure counts (expect 78/78 failing on surface A). Then populate `PENDING_WEEKS` with all 78 so the per-week suite is green-by-pending. Vitest is the canonical gate; Step 6 adds a matching pytest in the nested repo.

### Step 2: spec amendment (owner: Scribe)

Amend `curriculum/curriculum-architecture.md` §5.4. Keep §5.1, §5.2, and §5.3 text unchanged. Add:

- (a) Delivery rule: Communicative Practice is self-paced and online-only; one learner completes it alone in the app within 20 minutes; responses are typed text only (no audio recording in this phase); no instructor, classmates, physical materials, or synchronous session is assumed.
- (b) Approved pattern menu: self-paced scripted dialogue where the learner plays both roles from on-screen dialogue cards; written alternatives (written role-play, message or email, chat-style exchange, short narrative or report scaled by band); self-check against a model answer with an explicit checklist; an integrated translation or interpreting-in-writing task (Advanced); all materials digital and on-screen.
- (c) Band task types and the dialect, register, and business-context rule are preserved and must be exercised within the chosen pattern.
- (d) The standard `practice-activity.md` skeleton, including the "Task prompt" contract below, so #179 can template it.
- (e) A short note that §5.3 Q&A wording is unchanged by this issue.

Update §5.5's instructor PPTX sentence only if needed, to say the PPTX practice slide summarizes the self-paced task.

### Step 3: task prompt contract (owner: Scribe, within Step 2 and every rewrite)

Each `practice-activity.md` gains a "## Task prompt" section with these labeled fields in fixed order:

1. `Scenario:` (1-3 sentences)
2. `Your role(s):` (which roles the learner voices or writes)
3. `What to write:` (the concrete deliverable)
4. `Length and format:` (for example "6-10 lines of dialogue" or "120-180 words")
5. `Register and dialect:` (zone and register requirement from the week's dialect note)
6. `Use these phrases:` (the week's phrase groups to use, by Group label)
7. `Success checklist:` (3-6 bullet self-check criteria tied to the week's can-do outcomes)
8. `Model answer:` (a complete exemplar response, kept in the markdown; not part of the in-app summary)

Field labels are stable, machine-parseable strings for #179. #178 does not change the `LessonContent` schema or JSON shape (see Decisions).

### Step 4: exemplar (owner: Scribe; gate: owner review)

Rewrite `curriculum/lessons/beginner-week-01/practice-activity.md` first.

- Preference: keep the existing H2 activity title (Spanish name plus English gloss) unless the title itself is classroom-bound. The "Introductions Market" may be kept as an on-screen scenario metaphor.
- Replace role cards with on-screen dialogue cards the learner works through alone (the learner voices both speakers in writing across the zone/register cards).
- Convert "meet the instructor" to a written usted-register exchange with an authority character.
- Convert the debrief to a written self-check against the model answer.
- Convert the registration-form task to an on-screen form translation.
- Rename "Materials needed" to "Digital materials".
- Rewrite "Accessibility and inclusion note" for self-paced digital use: screen reader order, keyboard-only completion, no time pressure inside the 20-minute advisory pacing, text-only.
- Keep the timing table totalling 20 minutes with self-paced phases.
- Keep "Grounding" citing §5.4 and the new delivery rule.
- Update `beginner-week-01/README.md` only where it describes the practice as classroom-delivered.

Gate E: the user or owner reviews the amended §5.4 plus the exemplar and explicitly approves the pattern before any batch begins. This approval fixes the template for all remaining batches.

### Step 5: band batches (owner: Scribe; gate per batch)

Nine batches of 8-9 weeks, in band order:

| Batch | Band | Weeks |
| --- | --- | --- |
| B1 | beginner | 02-09 |
| B2 | beginner | 10-17 |
| B3 | beginner | 18-26 |
| I1 | intermediate | 01-09 |
| I2 | intermediate | 10-18 |
| I3 | intermediate | 19-26 |
| A1 | advanced | 01-09 |
| A2 | advanced | 10-18 |
| A3 | advanced | 19-26 |

For each file:

- Preserve the H2 title unless it is classroom-bound. If a title changes, list it for Step 7 and update in-batch cross-references in sibling lesson files such as `beginner-week-03/practice-activity.md` and `beginner-week-08/vocabulary-list.md`.
- Preserve the band task type, the week's phrase groups, the dialect, register, and business context (§6 in-person, phone, and email registers remain as scenario content, not as delivery mode), and the can-do outcomes.
- Apply the skeleton and the Task prompt contract.
- Keep the first paragraph under the H2 a self-contained student-facing summary within the length guardrail.
- Fix classroom framing in sibling lesson files only where they describe how the practice segment is delivered (bounded; list each touched file).

Per-batch gate (all must pass before the next batch):

1. T1 removes the batch's weeks from `PENDING_WEEKS` and runs the detection test; all batch weeks are green.
2. A `generate_lesson_ts.py`-based dry parse (the Step 6 tool) of the batch shows title, summary, and duration 20 parse correctly.
3. Independent read-only review by `verifier` against a fixed rubric: band task type preserved; dialect, register, and business context exercised; phrase groups used; can-do outcomes intact; 20-minute timing totals; Task prompt fields complete and the model answer coherent with the success checklist; no new factual or dialect claims beyond the existing lesson; no audio dependency.
4. Any finding is fixed by Scribe and re-checked once. A second failure on the same batch blocks for user review.

### Step 6: tooling (owner: T1)

May run in parallel with Step 5 content since paths do not overlap, but serial by default. In nested repo `tools/lesson-generation`:

- `lesson_generator.py`: replace the hardcoded `'role-play'` type and role-card parsing with parsing of the "Pattern:" line and the Task prompt fields. `_add_practice_slide` renders "Practice Activity: <name>", "Duration: 20 minutes (self-paced, online)", "Pattern: <pattern>", and a concise task-prompt summary (Scenario, What to write, Length and format), with no "Role cards" or "Role-Play". Keep slide title uniqueness and accessibility markup. Remove or retain `_extract_role_cards` only if it is still referenced (no dead code).
- `generate_lesson_ts.py`: keep the title, summary, and duration contract. Add a practice-only update mode (for example `--practice-only`) or a small companion script that rewrites only the `practice: {...}` block of an existing content-source module, leaving every other byte unchanged. Make summary extraction stop at the first blank line after the H2 paragraph if needed, so the Task prompt never leaks into the summary.
- Tests first: extend `test_lesson_generator.py` (practice slide text has no "Role-Play" or "Role cards", has Pattern and duration; parsing of the new skeleton) and `test_generate_lesson_ts.py` (summary excludes Task prompt; practice-only mode changes only the practice block). Update the `test_lesson_generator.py:753` expected names only if titles change.
- Add a matching pytest (J-002) that runs the Python generator's practice parser over all 78 files and asserts the same Task prompt field order and the same timing sum as the TypeScript parser, so the TS gate and the generator agree. T1 decides how it handles weeks not yet converted; it must cover all 78 files once the last batch passes.
- Commit the tooling changes on the nested local branch `issue-178-self-paced-practice` (J-001). Delivery to the main repo happens through the Step 9 patch export.

### Step 7: regeneration (owner: T1, after all batches pass)

- (a) For all 78 weeks, apply the practice-only update to `content-source/<band>WeekNN.ts`. Verify with a scripted check that importing each module before and after yields deep-equal objects except `practice`.
- (b) Run `npx tsx scripts/generate-lesson-content-json.ts` (must report exactly 78 written). Verify each `lesson-content.json` differs from baseline only in `practice`.
- (c) Regenerate the 78 instructor PPTX files with `python tools/lesson-generation/lesson_generator.py <lesson_dir> --pptx-output <lesson_dir>/<name>-instructor.pptx` only (no `--pdf-output`; PDF and DOCX untouched). Verify with python-pptx that only the practice slide text changed and slide titles remain unique.
- (d) Update pinned outer tests only where values changed: `lessonContent.test.ts:76-80`, `LessonContentView.test.tsx:204`, `lessonContentLoading.test.ts:110/146`. The data-driven `lessonContentViewPanelMounting.test.tsx:219` should need no edit.
- (e) Set the detection test's `PENDING_WEEKS` to empty; the full gate must be green.
- (f) Regenerate `docs/evidence/issue-178/practice-checks-final.json` with the report script. It must show 0 failures across all 702 check results. Both the baseline and final reports are committed and referenced by the PR.

### Step 8: local storage refresh (owner: T1)

- With local Supabase running, run `npx supabase db reset` (re-seeds storage from storage-seed per `config.toml` `objects_path`). If a bucket error occurs, run `npm run ensure:bucket`. Confirm in the app that the practice text is the new text.
- Coordinate with #173 (storage content-type for uploaded lesson assets). If #173 has merged, re-provisioning must use its content-type behavior. If not, the local reset still works, and the hosted step (Step 10) must be sequenced after #173 or explicitly accept the current content-type.
- Do not run `scripts/provision-lessons.ts` against any hosted target.

### Step 9: verification and PR (owners: Verifier, Browser Validator, orchestrator)

- Verifier re-runs all deterministic gates. Browser Validator runs the light journey in the Browser UI section below.
- Export the tooling patch series (J-001). Decision: a tracked patch artifact in the main repo. Justification: the main repo deliberately leaves `tools/lesson-generation` untracked (`.gitignore` lines 49-54: own prior history, no remote, no submodule). Vendoring copies of the generator into the main repo would create two diverging sources of truth, and a submodule is impossible without a remote. A `git format-patch` series keeps the nested repo as the single source of truth, makes every tooling line reviewable in the main PR diff, and is reproducible. Mechanism:
  1. Step 0 recorded `BASE_SHA`.
  2. Step 6 committed tooling changes on the nested local branch `issue-178-self-paced-practice`.
  3. At Step 9, run `git -C tools/lesson-generation format-patch <BASE_SHA>..HEAD -o docs/tooling-patches/lesson-generation/issue-178/`, writing into the MAIN repo. Per the planner, that path is tracked and `.gitignore` only ignores `docs/cutover-evidence` dumps (re-check before export).
  4. Add a `README.md` in that directory recording `BASE_SHA`, the resulting nested `HEAD` SHA, the patch file list with SHA-256 checksums, and the reviewer and CI reproduction procedure: fresh copy of the nested repo at `BASE_SHA`, then `git am docs/tooling-patches/lesson-generation/issue-178/*.patch`, confirm the resulting HEAD tree matches the recorded SHA, run `pytest` (green), then regenerate one week's practice block and PPTX and compare to the committed outputs.
  5. The main PR description links the patch directory.
  6. Merging the nested branch into the nested local `main` still happens only with user approval.
- Commits and PR happen only on explicit user request at that time: outer repo commit(s) on `issue-178-self-paced-practice` and a PR to `main` referencing #178 and epic #172, including the patch directory and both evidence reports. The nested repo is committed separately on its own local branch.

### Step 10: production reconciliation (SEPARATE, USER-GATED; not part of this plan's approval)

Hosted storage `lesson-content.json` objects and hosted `lesson_revisions` and `course_versions` may still serve or hydrate the old classroom text (`course-authoring/index.ts:131-145` reads storage at `get_version` time). A follow-up job, after explicit user approval and after #173 sequencing, would:

- Dry-run and diff hosted objects against the new storage-seed.
- Re-provision hosted `lesson-content.json` via `scripts/provision-lessons.ts` with its hosted guards.
- Decide whether existing published `course_versions` need a republish or new revision.
- Verify that owner authoring shows the new text.

This requires credentials and explicit authorization. No hosted writes occur under #178.

## Interfaces and data

- Markdown contract for `practice-activity.md`: first H2 is the activity title; the following paragraph is the in-app summary; "20 minutes total" present; a "Pattern:" line; "## Task prompt" with the fixed field labels; "## Digital materials".
- `content-source` `practice{title, summary, durationMinutes}` shape unchanged. `lesson-content.json` shape unchanged. `LessonContent` type and `LessonContentView` unchanged.
- PPTX practice slide content changes (instructor-facing).
- New tracked artifacts in the main repo: `curriculum/practice-baseline-manifest.json`, `scripts/build-practice-baseline-manifest.ts`, `scripts/report-practice-checks.ts`, `src/__tests__/helpers/parsePracticeActivity.ts`, `docs/evidence/issue-178/practice-checks-baseline.json`, `docs/evidence/issue-178/practice-checks-final.json`, and `docs/tooling-patches/lesson-generation/issue-178/` (patch series plus README). Script and helper names are examples; T1 may adjust them.
- No database migration.
- Compatibility: hosted content keeps the old text until Step 10.

## Acceptance and validation

- Detection test (`src/__tests__/practiceSelfPacedContent.test.ts`) green with `PENDING_WEEKS` empty across all three surfaces; seeded RED evidence recorded at Step 1 in `docs/evidence/issue-178/practice-checks-baseline.json` (surface A expected 78/78 units failing; B and C as measured).
- `docs/evidence/issue-178/practice-checks-final.json` shows 0 failures across all 702 check results (390 + 156 + 156).
- Task prompt and timing parser (J-002): all 78 activities pass the field order, non-empty, 3-6 checklist items, approved Pattern, and Minutes-column-sums-to-20 checks; the nested pytest agrees with the TS parser on field order and timing sum.
- Baseline manifest (J-003): `curriculum/practice-baseline-manifest.json` was generated before any rewrite and reproduces byte-for-byte on the baseline commit; 78/78 weeks pass the conformance test.
- Tooling delivery (J-001): `docs/tooling-patches/lesson-generation/issue-178/` holds the patch series and README; the reproduction procedure (fresh copy at `BASE_SHA`, `git am`, HEAD tree matches recorded SHA, `pytest` green, one-week regeneration comparison) has been run once and its result recorded.
- Grep of `practice-activity.md`: 0 "## Materials needed", 78 "## Digital materials", 78 "## Task prompt" sections with all eight fields, 78 "20 minutes total".
- `npx vitest run` full suite green; `npm run type-check` and `npm run lint` green; `npm run build` succeeds.
- In `tools/lesson-generation`: `pytest` green (`test_lesson_generator.py`, `test_generate_lesson_ts.py`).
- `npx tsx scripts/generate-lesson-content-json.ts` writes exactly 78; non-practice diff check equals 0 for all 78 content-source modules and all 78 JSON files.
- PPTX check: 78 regenerated; the practice slide has no "Role-Play" or "Role cards"; unique titles preserved; non-practice slides unchanged; PDF and DOCX files byte-unchanged.
- Per-batch verifier rubric passes (Step 5). Owner approval of the exemplar (Gate E). Owner sample review of one week per band before merge: beginner-week-01 (exemplar), one Intermediate week with a §6 business register, and one Advanced week with an integrated translation task (for example advanced-week-05); the owner picks if preferred.
- Summary length guardrail respected, or each exception approved.

## Browser UI dialog policy and validation

The Browser UI invariant applies (lizbeth_spanish web app): no native `alert`, `confirm`, `prompt`, `window.*` variants, or `beforeunload`. This plan adds no dialogs or interactions. Require a deterministic source scan (for example grep over `src/` for `\b(window\.)?(alert|confirm|prompt)\s*\(` and `beforeunload`) showing no new occurrences in the diff. Existing app-owned modal and inline-validation behavior and the keyboard and focus behavior of the segment tabs must remain unchanged; existing `LessonContentView` and `SegmentLedger` tests stay green.

Browser validation: light.

- Launch and readiness: `npx supabase start`, then `npx supabase db reset` (from `H:\CommandCenter\orchestrator\lizbeth_spanish`), then `npm run dev` (`predev` ensures the bucket). Ready when `http://localhost:5173` serves the sign-in page (use the printed URL if 5173 is taken).
- Base URL: `http://localhost:5173`.
- Fixture and reset: `npx supabase db reset` (loads `seed.sql`, full-catalog, storage-seed). Sign in with a seeded student account (`student1@test.local` per the README seed accounts) enrolled in the needed band, or `owner@test.local` preview, as the README describes.
- Journeys: for one week in each of three bands (beginner-week-01, one intermediate week, one advanced week reachable for the fixture account; if a band is not enrolled for any seed student, use the owner preview path or document the limitation), open the week, select the "3 of 3: Practice, 20 minutes" tab via keyboard and pointer, and confirm the panel shows the new title and new self-paced summary text and none of the denylisted classroom terms.
- Viewports: 390x844 (mobile) and 1440x900 (desktop).
- Visible outcomes: Practice tab label unchanged; new summary visible and fully readable without overflow or clipping; no native dialog appears; focus moves into the practice panel as before; no console errors.

## Risks and rollback

| Risk | Mitigation |
| --- | --- |
| Content drift (loss of dialect, register, business context, or band task type) | Exemplar gate, fixed rubric, per-batch verifier, owner samples. |
| Generator regression altering non-practice content (D-2 byte-for-byte production truth) | Practice-only update mode and deep-equal diff check. Rollback: revert content-source and JSON files. |
| Summary regex leaking Task prompt or model answer into the in-app summary | Step 6 tests and the detection test check that the summary contains no "Model answer:" or field labels. |
| Over-broad denylist blocking legitimate content (§6.1 in-person register, negotiation role plays, Group A-D) | Scoped, justified allow-list entries only. |
| Title changes breaking cross-references and pinned tests | Default to preserving titles; any change is listed and cross-references updated in-batch. |
| Nested repo has no remote, so tooling commits could be lost or become unreviewable | Export a `git format-patch` series into the tracked `docs/tooling-patches/lesson-generation/issue-178/` with a README recording `BASE_SHA`, nested HEAD SHA, and checksums (J-001); optional local backup. Adding a remote or a submodule is out of scope. |
| Baseline manifest extraction misreads a token or can-do statement, weakening the conformance floor | Deterministic script reproducible byte-for-byte; manifest reviewed at Gate E; exceptions only through a scoped, justified list keyed by week plus token; per-batch Verifier covers semantics. |
| Hosted or production stale text and #173 content-type interaction | Explicitly deferred to Step 10 behind user approval. |
| Large binary churn (78 PPTX) | Accepted; verified by slide-text diff. |

Rollback: revert the outer branch or PR (content, content-source, JSON, PPTX, tests) and reset the nested repo branch. A local `npx supabase db reset` restores prior storage from the reverted seed.

## Dependencies

- #179 (submission task form) consumes the Task prompt contract defined here; #178 does not build it.
- The baseline manifest (Step 0) must exist before the Step 1 conformance test and before any rewrite.
- The nested repo `BASE_SHA` (Step 0) is required for the Step 9 patch export.
- #173 (storage content-type) constrains the sequencing of Step 8 re-provisioning and Step 10.
- Epic #172 is the parent; the PR references both #178 and #172.

## Assumptions and decisions

Safe assumptions:

- Activity titles can be preserved in most weeks.
- The in-app view continues to show only title and summary until #179.
- PDF and DOCX need no regeneration.
- Vitest is the canonical detection gate.

Recorded decisions (resolved; moved from the earlier open list):

1. No structured `practice.taskPrompt` field is added in #178. The #179 task form owns the data format. #178 defines the fixed labelled Task prompt sections now so #179 can parse them; the J-002 parser is the reference contract for #179.
2. The owner picks the Intermediate and Advanced sample weeks. advanced-week-05 remains only a suggestion.
3. Model answers stay in markdown only. Showing them to students is deferred to #179.
4. Nested repo delivery uses the tracked patch artifact in the main repo (J-001).

Open item:

- Step 10 hosted reconciliation timing relative to #173 remains a separate, later approval. It is not a blocker for approving this plan.

Approvals required:

- Explicit user approval of this plan before any work.
- Gate E exemplar approval before batches.
- Explicit user request before any commit, push, or PR.
- Separate explicit approval for Step 10 hosted writes.

## Approval record

Approved by the user on 2026-10-03, together with the plans for issues #173, #176, and #177, in the orchestrator session.

- Covered: commits, pushes, and pull requests for this item. User instruction: create new branches and PRs as needed; existing unmerged local work in lizbeth_spanish lands as its own cleanup PR first.
- Not covered: production writes (storage re-tag, migrations, Edge Function deploys, Netlify deploys). Each needs a separate explicit user go-ahead after local validation.
- Gate E remains required: the user must approve the amended §5.4 and the rewritten beginner-week-01 activity before the other 77 rewrites begin.
