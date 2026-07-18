# Lizbeth Spanish Course Platform — Session Handoff

**Purpose of this document.** This is a single-file resume point for a future orchestrator
session (or a human) that has not seen the prior conversation. It was written by re-reading the
approved plan and by directly inspecting the `lizbeth_spanish` project's files and git history on
2026-07-18. Every status claim below is labeled as verified (with the command or file used to
verify it), inferred, or unconfirmed. Do not treat anything marked unconfirmed as settled without
re-checking it yourself; see Section 8 for the exact re-verification steps to run first.

---

## 1. Project summary

**Lizbeth Spanish** is an English<->Spanish instructional course platform being built for a single
instructor, "Lizbeth," who is also the platform's owner/admin. It targets adult learners across
CEFR levels A1-C2: individuals, working professionals, and businesses. The project is built
strictly per an approved plan:

`H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-course-platform.md`

The plan's approval banner (verified by reading the file) reads: *"Approved by the user on
2026-07-17. Cleared for phased downstream execution per the ordered work in Section 5..."* All
five open decisions the plan originally tracked (D1-D5) are recorded as confirmed; no open user
decisions remain in the plan itself.

The application's design identity is the Studio "Field Workbook" direction: an editorial,
print-craft aesthetic with a golden-hour, brass, and aged-paper materiality (the user's own
"finca-tequilera" elaboration) confined to chrome, covers, dividers, badges, and empty states only
— never behind reading or form content. This is documented in Section 4 of the plan and is
binding on all engineering and content work.

The project root is a real, separate directory tree:

`H:\CommandCenter\orchestrator\lizbeth_spanish`

---

## 2. Where the approved plan lives and what it says

**Path:** `docs/plans/lizbeth-spanish-course-platform.md` (read in full for this handoff).

This plan is the source of truth for scope and acceptance criteria for every phase. Do not
re-derive scope from memory or from this handoff alone — re-read the plan section for any phase
you are about to work on, since it carries per-phase acceptance criteria, risks, and rollback
boundaries that this handoff only summarizes.

**Phase structure (Section 5 of the plan), 0 through 8:**

| Phase | Deliverable | Owner |
|---|---|---|
| 0 | Project scaffolding + design-system foundation (tokens, reading/accessibility system, focus ring, app-owned modal primitive) | engineering-fleet (T1) |
| 1 | Curriculum architecture document (CEFR bands, five-pillar model, dialect-zone mapping, register/inclusive layers, lesson template spec) | Scribe |
| 2 | One fully worked example lesson (the reusable template): vocabulary, phrases, Q&A, practice activity, flashcards, weekly review, generated+validated PPTX/PDF | Scribe (content) + engineering support for tooling |
| 3 (3a-3e) | Full local web app: data model/RLS (3a), roadmap/dashboard (3b), lesson viewer/resources (3c), feedback form (3d), owner/admin branding+legal config (3e) | engineering-fleet |
| 4 | Standalone image-generation manifest (every planned image asset, with a complete external prompt) | Scribe |
| 5 | Legal/IP notice content, owner-editable, non-legal-advice-labeled | Scribe (content) + engineering-fleet (wiring) |
| 6 | Full-scale, up-front lesson authoring: ~26 weeks each for Beginner, Intermediate, Advanced (~78 core lessons total), scaled from the Phase 2 template | Scribe |
| 7 (committed) | Professional translator/interpreter-certification track (content from CEFR B2 up, ~26 weeks) + its own net-new UI, gated on a not-yet-run design increment | Scribe (content) + engineering-fleet (UI, after design increment) |
| 8 (committed) | Heritage-learner academic track (content, ~26 weeks) + any track-specific UI, same design-increment gate | Scribe (content) + engineering-fleet (any UI) |

**Grand total per the plan:** approximately 130 weekly lesson packages across all committed bands
and tracks (~78 core + ~26 translator/interpreter + ~26 heritage), each with vocabulary, phrases,
Q&A, practice activity, flashcards, weekly review, plus a generated and accessibility-validated
instructor PPTX and student PDF. This is stated in the plan as a rough planning estimate, not a
precise figure.

**Two anchor research documents grounding the plan and Phase 1 content:**

- `docs/research/Global Spanish–English Language and Translation Training Ecosystems  Curriculum
  Architecture, Dialect Matrices, and Market Strategy.md` — verified present at
  `H:\CommandCenter\orchestrator\docs\research\`. This supplies the CEFR/ACTFL five-pillar model,
  the original six-zone dialect matrix, cognitive-load packet anatomy, and the
  translator/interpreter and heritage-learner track frameworks.
- `docs/research/inclusive-spanish-usage.md` — verified present at the same path. This resolves a
  previously flagged gap in the curriculum architecture document's inclusive-language treatment
  (Section 4.4 of `curriculum-architecture.md` cites this resolution directly).

Every phase and sub-phase, per the plan, must still pass its own acceptance checks, an
independent Verifier pass, and (for UI) a Browser Validator pass before being treated as complete
— approval of the overall plan does not waive per-phase gates.

---

## 3. Current build status, phase by phase (verified against actual files and git log)

Verification method: directory listings of `lizbeth_spanish/`, `curriculum/`, `curriculum/lessons/`,
`src/content/`, `legal/`, `assets/`; `git log --oneline` in both the outer `lizbeth_spanish` repo
and the nested `tools/lesson-generation` repo; `git status` in both repos.

| Phase | Status | Evidence |
|---|---|---|
| **Phase 0** — scaffold/design system | **Done** | Outer repo's first commit `45c60bf "Initial commit: lizbeth_spanish course platform, Phases 0-3b"`. Token system, reading/accessibility settings, and app-owned modal primitive files exist under `src/`. |
| **Phase 1** — curriculum architecture doc | **Done** | `curriculum/curriculum-architecture.md` exists (46,564 bytes), explicitly labeled "Phase 1 deliverable of the approved plan," covers the five-pillar model, D2 band model, and (per its own Section 4.4 note) resolves inclusive-language treatment via `inclusive-spanish-usage.md`. |
| **Phase 2** — worked example lesson + reusable pipeline | **Done** | `curriculum/lessons/beginner-week-01/` contains all required artifacts (vocabulary-list.md, phrases-and-qa.md, practice-activity.md, flashcards.md, weekly-review-recap.md, README.md, generated `.pptx`/`.pdf`/`.docx`). The reusable pipeline (`tools/lesson-generation/`) exists with its own passing test history (see Section 4). |
| **Phase 3a-3e** — full app (backend/RLS, roadmap, lesson viewer, feedback form, owner/branding config) | **Done** | Commit history shows each sub-phase individually: `92821e0 "Phase 3c..."`, `bf82103 "Phase 3d..."`, `ea68944 "Phase 3e..."`, plus the initial commit covering 0-3b. `PHASE_3A_SETUP.md` documents the schema/RLS/seed-data work in detail (its own header says "Status: Complete (schema, RLS, and tests implemented; local stack verification pending)" — the "verification pending" phrase is stale wording worth re-checking; see Section 6). `src/__tests__/` contains RLS-specific tests: `rlsIntegration.test.ts`, `rlsPolicies.test.ts`. |
| **Phase 4** — image manifest + embedded images | **Done** | `assets/image-manifest.md` exists (35,433 bytes); `assets/` contains generated spot and vocabulary images (`spot_01.png` through `spot_03_3.png`, `voc_a.png` through `voc_e_3.png`). Commit `f78537e "Add Phase 4 image manifest and Phase 5 IP-notice source document"` and `95500d1 "Embed final Phase 4 vocabulary and spot images into Phase 2 materials and app UI"` confirm embedding into both materials and app UI. |
| **Phase 5** — finalized legal/IP notice | **Done** | `legal/ip-notice.md` exists (10,138 bytes). Commit `842b1c3 "Apply finalized IP/copyright notice text (Phase 5)"`. |
| **Phase 6** — full-scale lesson authoring | **Beginner band: done. Intermediate/Advanced bands: not started.** | `curriculum/lessons/` contains `beginner-week-01` through `beginner-week-26` — all 26 directories verified present, each containing the full six-artifact set plus generated `.pptx`/`.pdf`/`.docx`. `src/content/` contains all 26 corresponding `beginnerWeek01.ts` through `beginnerWeek26.ts` generated TypeScript modules (verified count: 26). Outer repo's most recent commit is `2134c6a "Complete Beginner band: Weeks 24-26 + full corpus regeneration"`. No `intermediate-*` or `advanced-*` directories, files, or filenames exist anywhere in the project (verified by a recursive search for "intermediate" and "advanced" — zero hits outside this handoff's own text). |
| **Phases 7-8** — translator-certification track, heritage-learner track | **Not started** | No files, directories, or filenames referencing "translator" or "heritage" exist anywhere in the project (verified by recursive search — zero hits). The Section 2.3 design increment these phases require has not been run. |
| **Intermediate and Advanced bands** (~26 weeks each) | **Not started** | Same evidence as above; only a Beginner band syllabus (`curriculum/beginner-band-syllabus.md`) exists. No Intermediate or Advanced syllabus document exists yet. |

**Nested tools repo (`tools/lesson-generation/`) commit history**, oldest to newest:

```
31dd320 Fix Word COM intermittency and flashcards parsing bug in lesson generator
2f76600 Embed vocabulary group images into generated PPTX/PDF/DOCX with alt text
595aa83 Phase 6: Generalize lesson generation pipeline and expand tests
a9e2892 Add auto-generation pipeline for lesson TypeScript modules
645cf02 Fix title/practice-activity bug and add regression tests   <- most recent
```

This confirms the pipeline was built incrementally and specifically hardened for Phase 6 scale
("Generalize lesson generation pipeline") and later extended with the TypeScript-generation step
("Add auto-generation pipeline for lesson TypeScript modules").

---

## 4. Critical architectural facts a future session MUST know

**Two separate Git repositories, not one.**
- `H:\CommandCenter\orchestrator\lizbeth_spanish\` has its own git repository (confirmed: `.git`
  present, 20 commits from `45c60bf` initial commit to `2134c6a` most recent, on `main`, working
  tree clean at verification time). The outer orchestrator repo gitignores this whole directory
  (per the outer repo's own `.gitignore`, not re-quoted here — check it directly if this matters
  to your task).
- `lizbeth_spanish\tools\lesson-generation\` has its **own, separate** nested git repository (5
  commits, `31dd320` to `645cf02`, on `main`). The outer `lizbeth_spanish/.gitignore` explains why
  in an explicit comment: *"tools/lesson-generation keeps its own separate git history (a real,
  prior commit predates this repo and there is no remote to wire it as a proper git submodule).
  Rather than let it get added as an orphan gitlink with no .gitmodules entry, this repo leaves it
  untracked and independent."* The line `/tools/lesson-generation/` is in the outer repo's
  `.gitignore` for exactly this reason. **Check both repos' `git log` and `git status`
  independently** — commits to one do not appear in the other, and a "clean" outer `git status`
  tells you nothing about the nested repo's state (and vice versa).
- At verification time, the nested `tools/lesson-generation` repo had **uncommitted changes**:
  modified `__pycache__/*.pyc` files and two small untracked stray text files, `week24_activity.txt`
  and `week26_activity.txt` (one line each, apparently debug-script leftovers — see Section 6).
  These are not part of the committed lesson-generation source and are not gitignored in that
  nested repo (its own `.gitignore`, if any, was not separately audited here — check it before
  assuming these will stay out of a future commit).

**The reusable lesson-generation pipeline** lives at `lizbeth_spanish/tools/lesson-generation/`:
- `lesson_generator.py` — the core parser/generator library (PPTX + PDF generation with
  accessibility markup).
- `regenerate-phase2.py` — a CLI wrapper. **Verified in its own README:** it takes an optional
  lesson-directory-name argument and *defaults to `beginner-week-01` if no argument is given* ("for
  backward compatibility"). This default-argument behavior is exactly the kind of thing that has
  caused an accidental Week 1 regeneration before — **always pass the lesson directory explicitly**,
  e.g. `python regenerate-phase2.py beginner-week-14`, never rely on the default.
- `generate_lesson_ts.py` — generates the TypeScript content module (`beginnerWeekNN.ts`) that the
  app actually renders in the browser.

**Both scripts must be run for a new lesson to be fully usable**: `regenerate-phase2.py` (or
`lesson_generator.py` directly) produces the instructor PPTX, student PDF, and student DOCX;
`generate_lesson_ts.py` produces the `.ts` module the running app reads. Authoring the markdown
content alone is not sufficient — a week is not "done" until both generation steps have run
successfully and their outputs are verified.

**Vite `import.meta.glob` auto-discovery is real and confirmed working.** Verified directly by
reading `lizbeth_spanish/src/content/lessonContent.ts`: it uses
`import.meta.glob<...>('./beginnerWeek*.ts', { eager: true })` to auto-discover all week modules
at build time. The file's own comment block states this was a deliberate fix (referenced in-code
as "J-001 fix"): *"We use Vite's import.meta.glob with eager loading to auto-discover all
beginnerWeek*.ts modules at build time. This ensures new weeks are picked up without any
TypeScript edits."* All 26 `beginnerWeekNN.ts` files were confirmed present in `src/content/`.
**Do not reintroduce manual per-week registration in this file** — adding a new week's generated
`.ts` file requires zero edits to `lessonContent.ts`.

**t1-engineer availability is unconfirmed for this session.** The prior session's history (per
this job's brief) reported t1-engineer became unavailable partway through due to a
runtime/registry issue, with cause unconfirmed, and the user authorized T2 as the default writer
for the remainder. This handoff cannot itself confirm live agent availability (Scribe has no way
to invoke or probe another agent's runtime status). What was verified: the agent definition file
`.claude/agents/t1-engineer.md` exists in the outer orchestrator repo and shows as recently
modified in git status, which is consistent with it being an active, maintained definition, but
this is not proof of functional runtime availability. **Before routing new engineering work, the
resuming session should actually attempt a bounded T1 dispatch (or otherwise confirm registry
health) rather than assuming either outcome.** If T1 is available, prefer it as the normal
first-line writer per standard project policy. If it is still unavailable, T2 remains authorized
as default per the user's own prior instruction — but that authorization should still be quoted
explicitly in any new job packet rather than asserted from memory, consistent with this project's
own evidence-first norms.

**Blanket "commit as you go" authorization.** The user gave this authorization in the prior
session (per this job's brief). Under this project's protocol, commits at verified checkpoints do
not require re-asking each time, but every job packet that relies on this authorization should
still quote the user's own words directly rather than relying on an orchestrator-relayed summary,
since agents in this project correctly refuse to treat relayed authorization alone as sufficient.
This handoff document itself was written under `commit_authority: no` and creates no commits.

**Recurring process hazard: broad `taskkill` calls.** Per this job's brief, a subagent
(specifically browser-validator) has twice run a broad `taskkill /F /IM node.exe /T`, causing
collateral damage to unrelated processes, despite explicit scoped-termination instructions each
time. **Verified: no technical hook guardrail against this currently exists** — a search of
`.claude/hooks/` in the outer orchestrator repo for any `taskkill`-related guardrail returned no
matches. If this recurs, a technical hook guardrail (blocking or rewriting an unscoped
`taskkill /IM node.exe` invocation to a PID-scoped form) should be seriously considered rather than
relying on instruction-only mitigation a third time. In the meantime, always instruct scoped-PID
process termination explicitly in any browser-validation job packet.

**Content-authoring quality bar established during Phase 6** (applies to Intermediate/Advanced
bands and to Phases 7-8 as well):
- `vocabulary-list.md` and `flashcards.md` must have an **exact 1:1 item count**, verified
  explicitly (e.g., actually counting entries), never assumed. This exact bug class recurred
  multiple times during Beginner-band authoring. `tools/lesson-generation/test_lesson_generator.py`
  contains at least one relevant assertion (`# Count should match Phase 2's documented 31
  flashcards`), but this is a generator-level structural test, not a substitute for a per-week
  content-accuracy check — the two are different failure modes and both matter.
- Every grammar point or vocabulary item a lesson's own documents (its README, vocabulary list,
  etc.) claim to teach must have real, corresponding content, **checked across all six files per
  week** (README.md, vocabulary-list.md, phrases-and-qa.md, practice-activity.md, flashcards.md,
  weekly-review-recap.md). This exact bug survived once in the Beginner band because only some of
  the six files were checked in a batch — do not narrow the check to "the files that usually have
  the problem."
- No grammar item may be used before its scheduled introduction, per whichever syllabus document
  governs that band (`curriculum/beginner-band-syllabus.md` for the Beginner band; an equivalent,
  not-yet-written document will be needed for Intermediate and Advanced). This leaked at least
  four times during the Beginner band per this job's brief, including once discovered
  retroactively in an already-committed week. Commit `d058dd4 "Fix Week 11 retroactive content
  correction: restore lost 'todavía estoy enfermo' dialogue"` is direct git evidence of at least
  one retroactive content fix in this project's real history (confirmed by reading the commit
  log; the exact nature of what was fixed was not re-derived from the diff itself for this
  handoff — if the precise defect matters, read that commit's diff directly).

---

## 5. Batching/verification pattern established for Phase 6

This pattern is evidenced by the commit history (batch-numbered commits: "Phase 6 batch 1" through
"batch 6," plus a final "Complete Beginner band" commit) and should be reused for Intermediate and
Advanced bands:

1. **Content authored via Scribe in batches of approximately 3-4 weeks**, each batch referencing
   the relevant per-band syllabus document (`curriculum/beginner-band-syllabus.md` for Beginner;
   an equivalent document must be written first for Intermediate, then Advanced) for topic,
   grammar, and vocabulary progression. Batch commits observed: weeks 2-3, 4-7, 8-11, 12-15,
   16-19, 20-23, then 24-26 as a final batch alongside "full corpus regeneration."
2. **Materials generated via T1/T2 running both pipeline scripts** (`regenerate-phase2.py`/
   `lesson_generator.py` and `generate_lesson_ts.py`) **with explicit `lesson_dir` arguments in
   every invocation** — never relying on either script's default argument, which has caused an
   accidental Week 1 regeneration before (see Section 4).
3. **An independent Verifier pass per batch**, not necessarily exhaustive every time, but which has
   consistently caught real bugs when applied (per this job's brief; the specific bugs caught were
   not independently re-derived from Verifier transcripts for this handoff, since those transcripts
   are not part of this project's persisted repository state).
4. **The full test suite** — vitest (front end) plus the Python pytest suite(s) — must be run with
   **no exclusions**, and with the local Supabase stack confirmed running, since RLS-dependent
   tests require a live database. **A clarification worth flagging:** this job's brief refers to
   "both Python pytest suites," but this handoff's own file search found only **one** Python
   test location in the project: `tools/lesson-generation/`, containing two test files
   (`test_lesson_generator.py` and `test_generate_lesson_ts.py`). Running `pytest` from that
   directory discovers both files as one suite run, not two separately located suites. No other
   `.py` files exist anywhere in the project outside `tools/lesson-generation/` (verified by a
   recursive search). If a second, separately located Python suite was intended, it does not
   currently exist in the repository and should be treated as either a misremembered detail or
   something that needs to be created — do not assume it exists.
   On the vitest side, `src/__tests__/` contains 48 test files (counted directly), including
   `rlsIntegration.test.ts` and `rlsPolicies.test.ts` — the RLS-dependent tests referenced in this
   job's brief. A prior job in this project once falsely reported a full pass by silently
   excluding `rlsIntegration.test.ts`; that failure mode was caught and corrected previously and
   must not recur. **This handoff could not itself confirm whether the local Supabase stack is
   currently running** — an attempted `npx supabase status` check during this document's
   preparation did not return before timing out, and was not force-retried since that risks the
   same kind of destructive/unscoped process interaction flagged in Section 4. The resuming
   session must check this directly (see Section 8) before trusting any test-suite result,
   past or future.

---

## 6. Known outstanding minor items (verified at this handoff's preparation time)

- **Stale root `README.md`.** `lizbeth_spanish/README.md` still describes project status as
  "Phase 0: Scaffold and Design System COMPLETE" with Phases 1-3 listed under "Upcoming Phases."
  This is materially stale: Phases 0 through 6 (full Beginner band) are actually complete per
  Section 3 above. This should be corrected or at least flagged before external/onboarding use of
  that file.
- **Port number discrepancy.** The same stale README states the dev server "will open at
  `http://localhost:5174`," but `vite.config.ts` (read directly) configures `port: 5173`. Minor,
  but worth fixing alongside the README update above.
- **`PHASE_3A_SETUP.md` carries stale-sounding status wording.** Its own header reads: "Status:
  Complete (schema, RLS, and tests implemented; local stack verification pending)." Given that
  Phase 3a is listed as done in the plan's own downstream commit history (and later phases 3b-3e,
  4, 5, and 6 all build on top of it), "verification pending" may simply be stale wording from
  when the document was first written, or may reflect a genuinely still-open item. **Unconfirmed
  either way** — re-read this file's full contents and cross-check against the RLS test files
  before assuming either interpretation.
- **Two small orphaned files in the nested `tools/lesson-generation` repo.** `week24_activity.txt`
  and `week26_activity.txt` are one-line text files (each containing only the string "Mi
  Presentación Final") sitting untracked in that repo's working tree. They look like leftover
  output from a debug or generation script rather than intentional deliverables. They do not
  block anything but should be cleaned up or explained.
- **Nested repo has uncommitted `__pycache__` changes.** The nested `tools/lesson-generation`
  git status shows modified `.pyc` cache files and additional untracked cache files. These appear
  to be ordinary bytecode-cache churn, not meaningful source changes, but the nested repo's own
  `.gitignore` (not separately inspected here) should be checked — if `__pycache__/` is not
  ignored in that specific nested repo, it should be added there.
- **Outer repo git status was fully clean** at verification time (`nothing to commit, working
  tree clean` on `main`) — there is no uncommitted work in the outer `lizbeth_spanish` repo itself.

---

## 7. What's next per the approved plan

In the order the plan itself sequences remaining work (Section 5 and Section 10 of the plan):

1. **Write an Intermediate-band syllabus document**, mirroring the approach and depth of
   `curriculum/beginner-band-syllabus.md` (grounded in `curriculum-architecture.md` and the anchor
   research's CEFR scaffolding table), covering the Intermediate band's own ~26-week grammar,
   vocabulary, and dialect-rotation sequencing. No such document currently exists (verified: no
   `intermediate-*` file anywhere in the project).
2. **Author the Intermediate band's ~26 weekly lessons** in batches, following the same rigor as
   Section 5 above: syllabus-referenced batches, explicit `lesson_dir` arguments for both pipeline
   scripts, independent per-batch Verifier passes, and a full, unexcluded test-suite run with the
   local Supabase stack confirmed running before any batch is treated as accepted.
3. **Write an Advanced-band syllabus, then author its ~26 weekly lessons**, same pattern.
4. **Phases 7 and 8** (translator/interpreter-certification and heritage-learner tracks) — per the
   plan's Section 2.3 and Section 4.4 item 10, **neither phase's UI may build until a scoped
   design increment runs** (a follow-up Compact or Standard design route through Design Director
   and Design Reviewer) covering interpreting-practice audio playback, a record/upload/playback
   surface, and CAT-tool-orientation views — none of which the existing Studio design pass covers.
   Content authoring for these two tracks may proceed once the Phase 2 template is validated (it
   is) and the core bands are sequenced appropriately per the plan's dependency table (Section 10:
   "Phase 7 and Phase 8... depend on... Phase 6 sequencing for the relevant band(s)"), but check
   the plan's exact wording again before starting, since "the relevant band(s)" is not spelled out
   as a single fixed gate in Section 10 and may warrant a direct question to the user about
   whether Phase 7/8 content authoring may start before Intermediate/Advanced are both fully done,
   or only after.
5. Neither Phase 7 nor Phase 8 is a dependency of the other, nor of the core band work (Section 10
   of the plan states this explicitly) — they can be sequenced independently once their own
   prerequisites are met.

---

## 8. How to verify this document is accurate before relying on it

This document reflects a snapshot taken on 2026-07-18. Project state can shift. Before proceeding
with any new work based on this handoff, run these checks yourself:

1. **Git log and status in both repos:**
   ```
   cd H:\CommandCenter\orchestrator\lizbeth_spanish && git log --oneline -10 && git status
   cd H:\CommandCenter\orchestrator\lizbeth_spanish\tools\lesson-generation && git log --oneline -10 && git status
   ```
   Confirm the most recent commits and clean/dirty state match what Section 3 and Section 6 above
   describe. If they don't, trust the live repository over this document.

2. **Directory listing of the lessons tree:**
   ```
   ls H:\CommandCenter\orchestrator\lizbeth_spanish\curriculum\lessons
   ```
   Confirm which `beginner-week-NN`, `intermediate-week-NN`, or `advanced-week-NN` directories
   actually exist, and spot-check that a few contain all six markdown artifacts plus generated
   `.pptx`/`.pdf`/`.docx` files, not just placeholders.

3. **Run the full test suite once, with the local Supabase stack confirmed running first.**
   Verify `npx supabase status` (or the project's documented equivalent) reports the local stack
   up before running vitest, and run vitest and the `tools/lesson-generation` pytest suite with no
   exclusions. Do not accept a "full pass" claim that silently excludes `rlsIntegration.test.ts` or
   any other RLS-dependent test — this exact failure mode happened once already in this project.

Only after these three checks confirm (or update) this document's claims should new work proceed
on the assumption that this handoff is accurate.
