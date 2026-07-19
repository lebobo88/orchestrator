# Plan: Lizbeth Spanish Production Readiness Assessment, Remediation Plan, and Flaky-Test Fix

## Status

**Approved — 2026-07-19.** The user has explicitly approved the flaky-test fix (Section 4/F1) and all of Bucket A (Section 5), including Bucket A4 (the all-weeks content/data wiring). Bucket B (Section 5) is explicitly deferred; the user stated "we'll do this last." Bucket C (Section 5) remains deferred and unauthorized: the user confirmed local-first, hosted/deploy-last sequencing intent, but has not authorized Bucket C execution now. Bucket C still requires a separate, explicit user authorization at execution time, consistent with this plan's existing requirement. This plan deliberately stops BEFORE any live deployment; actually deploying to Netlify/Supabase requires that separate, explicit user authorization at execution time.

## 1. Outcome and audience

**Audience.** The single owner/instructor of the Lizbeth Spanish course platform (the user), who will review this document and decide what to approve.

**Outcome.** Two deliverables, both grounded in read-only repository evidence and a targeted root-cause investigation:

1. A root-caused fix for a known flaky unit test, sized as a small bounded engineering job.
2. A comprehensive production-readiness checklist covering the entire application for Netlify (frontend) + Supabase (backend) deployment, including a functionality-completeness audit against the governing plan's Phase 0–6 promises, partitioned into three clearly separated buckets so the user can see exactly what engineering can do now, what only the user can do, and what requires a later, separate deployment authorization.

This document is a **readiness checklist to review and authorize**, not a deployment record. Nothing in this plan performs a live deploy, a hosted migration, or a publish.

## 2. Scope and non-goals

### 2.1 In scope

- Root-cause analysis and a fix recommendation for the flaky test `OwnerSettingsPage.test.tsx` subtest "rejects a brand name over the length limit inline, with focus moved to the field."
- A production-readiness checklist spanning: build verification, Netlify configuration, Supabase production-migration requirements, environment/secrets handling, and a functionality-completeness audit (including whether all 78 authored weeks are actually reachable and functional in the running app).
- A clear three-way partition of every readiness item into: code/config work engineering-fleet can execute now after approval (Bucket A); actions only the user can take outside this codebase (Bucket B); and actions that require a separate, explicit deployment authorization at execution time (Bucket C).
- Specification of the in-scope engineering work (the flaky-test fix and Bucket A) at a level of detail sufficient for engineering-fleet to decompose into `ENGINEERING_JOB`s after approval.

### 2.2 Explicit non-goal: no deployment execution in this plan

The following are **out of scope for execution under this plan**, regardless of how routine they may seem once Bucket A is complete:

- Triggering a live Netlify deploy or publish.
- Running Supabase database migrations (`supabase db push` or equivalent) against a real hosted Supabase project.
- Provisioning the hosted `lesson-assets` storage bucket or uploading object bytes to a hosted bucket.
- Deploying the `owner-settings` Edge Function to a hosted project, or setting hosted secrets.
- Any action that changes the state of a live, publicly reachable deployment.

Per this project's operating rules and per the governing plan's Section 2.2 ("Production hosting... is deferred to a later phase"), deployment execution requires a separate, explicit user request or approval at execution time. Approving this readiness plan authorizes only the flaky-test fix and Bucket A code/config work in the `lizbeth_spanish` repository; it does not authorize Bucket C.

Also out of scope: Phase 7 (translator/interpreter track) and Phase 8 (heritage-learner track), and any redesign. The "Field Workbook" Studio design system approved in the governing plan is unchanged by this readiness work; no new design route was needed or run.

## 3. Repository findings and evidence

All findings below are read-only observations from `H:\CommandCenter\orchestrator\lizbeth_spanish`, a separate, independently gitignored repository from this orchestrator repo.

1. **Content authored on disk.** `src/content/` contains 78 lesson-content TypeScript modules: `beginnerWeek01`–`beginnerWeek26`, `intermediateWeek01`–`intermediateWeek26`, `advancedWeek01`–`advancedWeek26`. Generated instructor PPTX and student PDF files exist under `curriculum/lessons/<band>-week-NN/`. Beginner weeks 1–26 and Intermediate weeks 1–20+ were directly confirmed present; a repository-wide glob returned 164 PPTX/PDF matches spanning all three bands. Advanced-band PPTX/PDF completeness was not independently confirmed for every week and needs verification during execution (see Bucket A7).

2. **Critical feature-completeness gap: only 4 of 78 weeks are reachable end-to-end today.** The running app surfaces a week's lesson content and downloadable resources only when it reaches the "available" view-state in `src/pages/WeekDetailPage.tsx` (roughly lines 68–99 and 157–178). That state is entered only when `fetchResourcesForLesson()` returns one or more database resource rows; `getLessonContentSync` is called only inside that branch. In `supabase/seed.sql`, resource rows and storage objects exist only for Beginner weeks 1–4. `supabase/storage-seed/lesson-assets/` contains only `beginner/week-01` through `week-04`, and each of those four week folders is a duplicated copy of the week-01 files (see `seed.sql` roughly lines 208–251 and the `objects_path` setting under `[storage.buckets.lesson-assets]` in `config.toml`). As a result, in the app as it runs today, only Beginner weeks 1–4 are reachable and functional; the remaining ~74 weeks (Beginner 5–26, all of Intermediate, all of Advanced) render the "No resources published for this week yet" empty state or a locked state. The 78 weeks of authored content and the generated PPTX/PDF files on disk are not wired into the running app beyond those 4 weeks. Additionally, the database lesson titles are generic placeholders ("Week N: Beginner Lesson"), not the real authored titles. This is the single largest gap in "all functionality present" and the core subject of the completeness audit (Section 5).

3. **All current backend data is local seed/test data.** `supabase/seed.sql` provisions 7 synthetic test users (`student1`–`student6@test.local` and `owner@test.local`, fixed UUIDs, password `password`), a hardcoded owner `{"role":"owner"}` claim, an "Advanced Immersion (Unpublished)" fixture band, and test enrollment scenarios. None of this may ship to a production project. There is currently no mechanism to provision real lessons, resources, storage objects, or enrollments in a hosted project.

4. **No Netlify configuration exists.** There is no `netlify.toml` and no `_redirects` file anywhere in the repository (checked root, `public/`, `.github/`) and no CI configuration. The client router (`src/hooks/useRoute.ts`) uses HTML5 History `pushState`/`popstate` with real paths (`/roadmap`, `/admin`, `/feedback`, `/roadmap/:enrollmentId/week/:n`). Without a SPA catch-all rewrite, deep links and page refreshes on those routes will 404 on Netlify.

5. **Environment and secrets.** `src/services/supabase.ts` reads `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`, falling back to hardcoded local `127.0.0.1:54321` dev defaults. `validateAnonKeyRole()` fails closed if a non-anon (privileged) key is ever configured client-side, which is a correct safety property. A gitignore-respecting repository scan surfaced no `.env.example` at the repo root; the repository's `.gitignore` excludes only `.env`, `.env.local`, and `.env.*.local`, not `.env.example`, so a present file would ordinarily be visible to such a scan. Direct reads of env files are permission-shadowed for some agents, so this scan result is not a substitute for a direct check; engineering must confirm the file's actual presence at execution time rather than trusting any single scan. The service-role key is used only server-side, in `supabase/functions/owner-settings/index.ts`, and is correctly never referenced from client code.

6. **Supabase promotion facts.** Migrations `001`–`008` provision schema, row-level security, grants, and the storage gating policy (`202607170005`), but the `lesson-assets` storage bucket itself is declared only in `supabase/config.toml`; the migration `202607170003_storage_setup.sql` is commented out / documentation-only. This means `supabase db push` alone will not create the hosted bucket; it must be provisioned separately (`supabase config push`, the dashboard, or an equivalent SQL statement). Storage object bytes are local-seed-only, delivered via `objects_path`, and are not auto-uploaded to a hosted project; they must be uploaded separately. `seed.sql` runs only on local start/`db reset` and must not be run against a production database.

7. **Auth production-configuration gaps.** `supabase/config.toml` currently sets `[auth.email] enable_confirmations=false`, `site_url="http://127.0.0.1:3000"`, local-only SMTP (Inbucket, no real outbound mail), and `minimum_password_length=6`. A production deployment needs a real `site_url` (the Netlify domain), a redirect-URL allow-list, a real SMTP provider, and a deliberate email-confirmation policy. Supabase's Free plan auto-pauses a project after 7 days of database inactivity, which is unsuitable for a 24/7 student-facing platform; a paid plan or an explicit keep-alive strategy is a production prerequisite. These vendor facts were current as of the research date (2026-07-19) and should be re-verified at go-live since vendor terms change.

8. **Owner-account provisioning is a manual, service-role-only action.** The owner role is a `raw_app_meta_data {"role":"owner"}` claim, writable only via a service-role or seed context, never through any authenticated or RLS-governed path. In a production project, the real instructor's account must have this claim set manually via the service-role key. This is necessarily an operator action outside the codebase (Bucket B).

9. **Build verification has not yet been executed under this plan.** `package.json` defines `build` as `tsc && vite build` with Vite `outDir` `dist`. Because this plan is read-only planning, the build, `npm run type-check`, and `npm run lint` were not run here and must be verified clean before any deploy preparation proceeds, including confirming that Vite's `import.meta.glob` eager bundling of the 78 content modules builds successfully and that the Deno Edge Function is handled outside the Vite build path.

10. **`README.md` is stale.** It documents only "Phase 0 complete," describes a demo app, and references a dev server at port 5174. It does not reflect the actual current state (a full Phase 3 application with 78 weeks of authored content) and contains no deployment runbook.

## 4. Flaky-test root cause and fix

### 4.1 Root cause

Test: `OwnerSettingsPage.test.tsx`, subtest "rejects a brand name over the length limit inline, with focus moved to the field" (roughly lines 172–185).

The test calls `await user.type(nameInput, 'x'.repeat(201))` against a controlled input, which drives 201 individual character-by-character keystrokes. Each keystroke re-renders `OwnerSettingsPage`. Each render runs `clampColorForMultipleContrasts` twice, once per always-mounted `ColorPreview` component; both currently hold the complete default hex `#2a2420`, so the clamp function actually executes each time rather than short-circuiting. That yields roughly 201 renders times 2 clamp calls, about 402 synchronous CPU-bound computations, plus 201 `userEvent` interaction cycles, for a single assertion of the max-length validation message and a focus check.

Vitest's default `forks` pool runs test files concurrently (`fileParallelism: true`). Under full-suite CPU contention this occasionally crosses the default 5000ms `testTimeout`, while the same test finishes in roughly 3–4 seconds when run in isolation. This is deterministic resource-contention flakiness driven by an O(N) interaction cost, not nondeterministic application logic.

### 4.2 Fix

**Primary fix (mechanism-correct, addresses the actual cause).** Replace the char-by-char `user.type` bulk entry in this test only with either:

- `user.paste('x'.repeat(201))` after clearing and focusing the field (preferred; stays inside the `user-event` interaction model), or
- `fireEvent.change(nameInput, { target: { value: 'x'.repeat(201) } })` as a lighter fallback.

Either change collapses the interaction to a single input event, so the component re-renders once and the clamp runs about twice instead of about 402 times, turning an O(N) cost into O(1). This is legitimate because the test asserts only the submit-time max-length validation message and that focus moves to the field, not any per-keystroke behavior. Neither of the test's two assertions changes.

**Complementary fix (real product performance, optional, does not replace the primary fix).** Wrap `ColorPreview` in `React.memo`, and/or memoize the contrast-clamp computation, so that typing in the name field no longer recomputes the color-contrast clamps on every keystroke. This is a genuine perf improvement to the owner-settings page but by itself does not remove the 201 keystroke-driven event cycles, so it complements rather than substitutes for the primary fix.

**Explicitly rejected approaches.**

- A per-test timeout override (e.g., raising `testTimeout` for this one test) masks the symptom rather than fixing the cause. It is acceptable only as a small defensive margin layered on top of the primary fix, not as the fix itself.
- Changing `userEvent`'s `delay` option does not help; it already defaults to 0 in `user-event` v14.

### 4.3 Sizing and acceptance

This is a small, bounded T1 job: edit one test file, with an optional one-line `React.memo` wrap on one component.

Acceptance: running the **full test suite** (not the isolated test) repeatedly under the default parallel `forks` pool, the target subtest completes well under the 5000ms `testTimeout` with no flake, and both existing assertions (the max-length validation message and the focus-moved-to-field check) are unchanged.

## 5. Production-readiness checklist

### Flaky-test fix (in scope now)

- **F1.** Apply the primary fix to `src/__tests__/OwnerSettingsPage.test.tsx` (`paste` or `fireEvent.change` for the 201-character bulk entry). Optionally add `React.memo` to `ColorPreview` in `src/pages/OwnerSettingsPage.tsx`. Acceptance per Section 4.3.

### Bucket A: code/config gaps to fix now (in scope for engineering-fleet after approval)

All Bucket A changes are code/config edits inside the `lizbeth_spanish` repository. No hosted state is touched. Rollback for every item is a plain commit revert.

- **A1. Add Netlify configuration.** Create `netlify.toml` with `[build] command = "npm run build"`, `publish = "dist"`, and a single SPA catch-all redirect rule `/* /index.html 200`. Use exactly one source of truth for the rewrite (either `netlify.toml` or `public/_redirects`, not both) to avoid conflicting rules.
- **A2. Confirm and, as needed, create or augment `.env.example`.** Verify directly whether a root `.env.example` exists, since env files are permission-shadowed from some scans and the repository-scan finding in Section 3, item 5 is not a substitute for a direct check. If absent, create it; if present, review and augment it. Either way, ensure it documents `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` with hosted-value guidance, and states that the anon key is public-by-design (protected by row-level security) while the service-role key must never be a `VITE_`-prefixed build variable.
- **A3. Production build verification.** Confirm `npm run build`, `npm run type-check`, and `npm run lint` all pass clean. Keep the existing deterministic no-native-dialog scan. Add a deterministic check that no `VITE_`-prefixed service-role variable is present anywhere in the codebase or build output.
- **A4. Production content/data provisioning tooling, including an automated production-data preflight guard (largest sub-effort; decompose into its own sub-phase).** Build an idempotent, service-role-driven provisioning mechanism that: (a) inserts real lesson rows, with the real authored titles, and resource rows for every week that has authored materials; and (b) uploads the real per-week `curriculum/` files (PPTX, PDF, flashcards, weekly review) to the `lesson-assets` bucket, not duplicated week-01 files, so the authored content for all 78 weeks becomes reachable in the lesson viewer. Verify locally, against the local Supabase stack, that all authored weeks surface correctly. Building and validating this tooling locally is in scope for Bucket A; running it against a real hosted project is deployment execution and belongs to Bucket C.

  This tooling must include, as an explicit, sized component, not a narrative caution, an automated production-data preflight guard:
  - A separate, explicitly allowlisted production data manifest is the only sanctioned source of production lessons, resources, and enrollments. `seed.sql` is never an input to this tooling.
  - The tool refuses to run if the manifest, or the target project's existing state, contains any of the following confirmed local-fixture identifiers (verified directly against `supabase/seed.sql`): the seven test-account emails `student1@test.local` through `student6@test.local` and `owner@test.local`; their fixed fixture UUIDs `00000000-0000-0000-0000-000000000001` through `...000006` and `...000099`; the fixture band name "Advanced Immersion (Unpublished)"; or a resource row whose stored file is a `beginner-week-01-*` object (for example `beginner-week-01-student-handout.pdf` or `beginner-week-01-instructor.pptx`) reused for a different week, matching the duplicated-week-01 fixture pattern.
  - The tool runs a required post-run verification query against the target project proving that none of the seven test accounts (by email and by UUID), no "Advanced Immersion (Unpublished)" fixture band, and no fixture resource rows matching the duplicated-week-01 pattern exist in that target.
- **A5. Bucket lifecycle as config-as-code.** Ensure the hosted `lesson-assets` bucket is provisioned by `supabase config push` or an explicit migration, rather than assumed to be created by `db push`, and document this step so it is not skipped at deploy time.
- **A6. Update `README.md`.** Reflect the true current state of the application (full Phase 3 build, 78 weeks of authored content) and add a deployment runbook that references this readiness checklist.
- **A7. Functionality-completeness audit via Browser Validator against the local stack.** A full walkthrough enumerating which Phase 0–6 promises from the governing plan are actually wired and reachable: accessibility settings, the modal primitive, roadmap three-state gating, the lesson viewer's four-chunk anatomy with badges and rhythm stepper, gated PDF/PPTX/flashcards download including negative gating for unentitled access, the feedback form, owner branding/legal configuration including the live-as-typed clamp, and the IP notice. Critically, this audit includes the all-weeks reachability check described in Section 6. It produces the evidence base for the completeness section of this checklist and should also confirm Advanced-band PPTX/PDF completeness noted as unverified in Section 3, item 1.

### Bucket B: requires the user's own external action (no code can complete these)

- Create a hosted Supabase project; obtain its project URL, anon key, service-role key, and project reference.
- Create a Netlify site; connect a git remote; set Netlify build environment variables (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`).
- Configure hosted Supabase auth: a real `site_url` matching the Netlify domain, a redirect-URL allow-list, a real SMTP provider, and a deliberate email-confirmation policy.
- Choose a paid Supabase plan or design an explicit keep-alive strategy to avoid the Free-tier 7-day auto-pause.
- Provision the real instructor's owner account and set its `{"role":"owner"}` claim via the service-role key.
- Optional: purchase and configure a custom domain.

### Bucket C: requires explicit, separate deployment authorization (not authorized by approving this plan)

- `supabase link` and `supabase db push` to apply migrations to the hosted project.
- Provisioning the hosted `lesson-assets` bucket and uploading the real object bytes.
- Running the Bucket-A4 production data-provisioning tooling against the hosted project (real lessons, resources, enrollments). This step is not complete unless both of A4's automated guard checks pass against the hosted target: the preflight allowlist/rejection check (no fixture emails, fixture UUIDs, the "Advanced Immersion (Unpublished)" band, or duplicated-week-01 resource rows in the manifest or the existing target state) and the required post-run verification query (confirming zero of those fixture accounts, band, or rows exist in the hosted target after the run). As a one-line reminder: `seed.sql` itself is local-only and is never an input to this step, but the enforceable guard above, not that reminder, is the real control.
- `supabase functions deploy owner-settings` and `supabase secrets set` for its service-role secret.
- The Netlify production build and publish.
- Post-deploy verification: a Browser Validator pass against the live URL, including the negative unentitled-PPTX gating check and a deep-link/refresh check confirming the SPA redirect works in production.

Approving this plan authorizes only the flaky-test fix and Bucket A. Bucket B is the user's own action and is not something engineering-fleet can execute. Bucket C requires a separate, explicit user authorization at execution time, distinct from approval of this readiness plan.

## 6. Functionality-completeness audit plan

The audit's central question is: of the 78 authored weeks (26 Beginner, 26 Intermediate, 26 Advanced) and the full set of Phase 0–6 feature promises in the governing plan, what is actually reachable and functional in the running application today, and what remains after Bucket A's remediation?

**The all-weeks reachability gap (Section 3, item 2) is the audit's highest-priority finding.** Today only Beginner weeks 1–4 are reachable end-to-end; the remaining 74 weeks show an empty or locked state despite the underlying content and generated materials existing on disk. The audit must:

1. Confirm this gap directly by attempting to reach representative weeks across all three bands in the running local app (see the browser-validation brief, Section 8, for the specific week sample and journey).
2. After Bucket A4's provisioning tooling is built and run against the local Supabase stack, re-verify that the same representative weeks now render their real authored content, the real lesson title (not the placeholder), and their downloadable materials.
3. Enumerate, feature by feature against the governing plan's Section 4.5 journeys 1–9, which Phase 0–6 promises are wired and reachable, which are present but with a defect, and which are absent, with screenshot evidence for each.
4. Explicitly confirm Advanced-band PPTX/PDF file completeness, which Section 3, item 1 above flags as not yet independently verified for every week.

The audit's output is factual evidence (reachable / not reachable / defective, per feature and per representative week), not a completion claim. It feeds directly into whether the user considers Bucket A4 essential before any Bucket C authorization, or acceptable to defer.

## 7. Interfaces and data

- Supabase Postgres, Auth, Storage, and row-level security; one Edge Function, `owner-settings`, running with service-role privileges server-side only.
- Migrations `001`–`008` are present and provision schema, RLS, and grants. The `lesson-assets` storage bucket itself is declared only in `supabase/config.toml`, not in an executable migration (Section 3, item 6).
- The local-to-hosted contract must remain identical, per the governing plan's Section 6: the same auth, gating, and storage behavior must hold whether the client points at the local Supabase stack or a hosted project.
- Client environment contract: `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`, both baked in at build time because Vite statically inlines `VITE_`-prefixed variables. The service-role key is never a client or build variable.
- Bucket A4's production data-provisioning mechanism is a new interface being designed under this plan: a service-role-driven, idempotent tool that inserts lesson/resource rows and uploads real per-week storage objects. Its exact shape (script, CLI command, or migration-adjacent tool) is an engineering decision to be made during A4's execution, not asserted here.

## 8. Acceptance and validation

- `npm run build`, `npm run type-check`, and `npm run lint` all pass clean (Bucket A3).
- The flaky test is fixed and stable: the full test suite, run repeatedly under the default parallel `forks` pool, shows the target subtest completing well under 5000ms with no flake, and its two original assertions are unchanged (Section 4.3).
- The deterministic no-native-dialog scan passes, and zero native browser dialogs are observed in any journey during the Browser Validator audit.
- The completeness audit (Section 6) enumerates reachable versus unreachable features with screenshot evidence, explicitly including the all-weeks reachability finding, both before and after Bucket A4's local provisioning.
- The readiness checklist in Section 5 is complete and correctly partitioned into Buckets A, B, and C, with no item misplaced across a bucket boundary.
- No live Netlify deploy, hosted Supabase migration, hosted bucket provisioning, hosted object upload, or Edge Function deploy occurs as part of executing this plan.

## 9. Browser UI dialog policy (required, binding on the Section 6 audit and any future Bucket C post-deploy check)

Native browser dialogs are prohibited everywhere in this application's UI: `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts. Destructive actions and route guards must use an app-owned, accessible modal; other validation must use inline, `aria-live` feedback. The completeness walkthrough (Bucket A7) must run the deterministic no-native-dialog scan and must observe zero native dialogs across every journey exercised. Any native dialog observed anywhere is an automatic fail of that check, not a note to be waived.

## 10. Browser validation brief (binding on Bucket A7 and any future Bucket C post-deploy check)

- **Launch/readiness command.** Start the local Supabase stack with `npx supabase start`, then run `npm run dev`.
- **Base URL.** The documented dev URL; `README.md` currently states `http://localhost:5174`, but engineering must confirm the actual port in use before the audit runs, since the README is known to be stale (Section 3, item 10).
- **Fixture/reset procedure.** The existing `supabase/seed.sql` local fixtures (test students, the owner account, enrollment scenarios, and Beginner weeks 1–4 resources), plus, specifically for the all-weeks reachability check, the Bucket A4-provisioned local dataset once it exists.
- **Viewport profiles.** Mobile 360x800, tablet 768x1024, desktop 1440x900, desktop at 200% zoom, and a 320px reflow check.
- **Journeys.** Reuse the governing plan's Section 4.5 journeys 1 through 9: roadmap three-state gating including locked-URL no-leak on direct navigation; the lesson viewer's four-chunk anatomy, badges, and rhythm stepper; gated PDF/PPTX/flashcards delivery including the negative unentitled-PPTX access check; the feedback form's inline validation; owner branding's live-as-typed clamp plus its route-guard and destructive-action modals and its permission-denied state; reading-settings persistence; and the per-viewport accessibility sweep.
- **New journey for this plan.** Navigate a representative set of weeks spanning all three bands (for example, Beginner weeks 1, 13, and 26; Intermediate weeks 1 and 26; Advanced weeks 1 and 26) and confirm that the authored lesson content and downloadable materials actually render. This journey is the direct evidence for the all-weeks reachability finding in Section 6.
- **Evidence standard.** Screenshot evidence at each milestone in every journey, reported as visible outcomes, not as completion claims.

## 11. Risks and rollback

| Risk | Severity | Mitigation |
|---|---|---|
| ~74 of 78 weeks are unreachable in the running app despite authored content and generated materials existing on disk. | High | Bucket A4 is the direct remediation; it is flagged as the largest sub-effort in this plan and requires explicit user confirmation of scope (Section 12). |
| A native browser dialog appears in any journey. | High if it occurs | The no-native-dialog invariant (Section 9) is binding; any observed instance is an automatic fail requiring a fix before sign-off. |
| Seed/test data or the service-role key reaches a production build or a hosted project. | High if it occurs | Bucket A3's deterministic check for `VITE_`-prefixed service-role variables, and A4's automated production-data preflight guard (Section 5, Bucket A): the tool refuses to run against a manifest or target containing any known fixture email, fixture UUID, the "Advanced Immersion (Unpublished)" band, or a duplicated-week-01 resource pattern, and a required post-run verification query proves none of those are present in the hosted target. Bucket C's provisioning step (Section 5) is gated on both checks passing, not on a narrative warning alone. |
| Local-to-hosted configuration drift (auth, gating, storage contracts diverge between local and hosted). | Medium | Keep the local-to-hosted contract identical per the governing plan's Section 6; verify explicitly during any future Bucket C promotion, not assumed. |
| Supabase Free-tier auto-pause after 7 days of inactivity, unsuitable for a 24/7 platform. | Medium | Flagged in Bucket B as a decision the user must make (paid plan versus an explicit keep-alive strategy) before any Bucket C deployment. |

**Rollback.** All in-scope work under this plan (the flaky-test fix and Bucket A) is a set of code and configuration commits in the separate `lizbeth_spanish` git repository. Rollback is a plain commit revert. No hosted state is touched by any in-scope work, so there is nothing to roll back on the hosting side as a result of this plan.

## 12. Assumptions and open user decisions

**Labeled assumption.** The user's stated goal of "all functionality present" is read here as requiring Bucket A4's all-weeks wiring to be in scope for immediate engineering execution once this plan is approved. This is flagged explicitly as the plan's largest sub-effort so the user can confirm it or choose to defer it, rather than treating it as a settled fact.

**Open user decisions — status as of approval (2026-07-19):**

1. **Resolved.** Bucket A4 (all-weeks content/data wiring) proceeds now, alongside the rest of Bucket A. The user explicitly approved Bucket A4 as in scope, confirming it despite its flagged size as the plan's largest sub-effort.
2. **Still open / deferred.** The choice between a paid Supabase plan and an explicit keep-alive strategy for the Free-tier auto-pause limitation (Bucket B) remains unresolved. This decision is deferred consistent with the user's deferral of Bucket B as a whole ("we'll do this last") and does not block Bucket A execution.
3. **Satisfied.** The user has explicitly approved this plan, authorizing the flaky-test fix and Bucket A (including A4) to begin. Bucket C remains unauthorized: a separate, explicit authorization is still required later, before any Bucket C deployment step is executed, distinct from this approval. The user has clarified intended sequencing (local-first; hosted/deploy last) without granting that later authorization now.

No other open decisions were identified in the supplied evidence.

## 13. Engineering mode

Standard. After approval, decompose Bucket A into sub-phase `ENGINEERING_JOB`s, with Bucket A4 (production content/data provisioning tooling) treated as its own sub-phase given its size. Each sub-phase runs through its own Verifier pass, and Bucket A7's completeness audit runs through Browser Validator per the brief in Section 10. No extreme-advisory team is warranted for this work.

## 14. Downstream owners and approval gate

- **engineering-fleet** owns execution of the flaky-test fix (Section 4) and Bucket A (Section 5), and only after the user explicitly approves this plan.
- **The user** owns every Bucket B action; no engineering agent can complete these.
- **A separate, explicit user authorization**, requested at execution time and distinct from approving this plan, is required before any Bucket C deployment step (Section 5) is executed.

This plan's terminal deliverable is the reviewable readiness checklist above. Approving it authorizes preparation and code/config remediation only; it does not authorize deployment.
