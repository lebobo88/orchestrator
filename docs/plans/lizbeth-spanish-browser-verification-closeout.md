# Plan: Lizbeth Spanish Browser Verification Closeout

## Status

**Implemented.** Verification/closing-evidence work only; no new features. *(Header corrected 2026-07-25.)* This header previously read "Draft — awaiting explicit user approval," but repository evidence shows this plan's scope has been fully implemented and pushed. No record of an explicit user approval event for this specific plan was found during this correction; the status update reflects that the work was executed, not that a prior approval is being retroactively asserted. If confirmation of the original approval is needed, it should be sought from the user directly.

## 1. Outcome and audience

**Audience.** The single owner/instructor of the Lizbeth Spanish course platform (the user), who reviews and approves this plan.

**Outcome.** A bounded, executable verification and closing-evidence plan that captures genuine browser-level proof for three narrow gaps that were never fully confirmed at the browser level in a prior session, solely because of browser-automation tooling instability in that session. Nothing in these three areas was found broken during the prior session; the gap is a confirmation gap, not a known defect. If browser testing under this plan actually reveals that one of the three is broken, that becomes in-scope, root-caused bug-fix work matching the rigor already established on this project: no shortcuts, no timeout-only fixes, and independent red/green re-proof after any fix.

The three gaps are:

1. Owner-settings Save persists across a full page reload.
2. A non-owner is actually denied Course Settings in the browser, with an accessible, non-native denial view.
3. A student directly attempting a locked or unentitled resource is actually denied at the storage/RLS layer, not merely un-linked in the UI.

## 2. Scope and non-goals

### 2.1 In scope

- Browser-level end-to-end verification of exactly the three mechanisms above, each proven with a red/green pair (a positive control that must pass and a negative case that must be denied) and screenshot evidence.
- Root-cause investigation and a fix for any of the three that browser testing proves broken, with independent re-proof to genuine green after the fix (Verifier, then Browser Validator).

### 2.2 Non-goals

- No new features.
- No re-architecture of the RLS/signed-URL system. That system was reportedly already exercised and confirmed correct in prior A4 reachability testing; this plan closes only the unauthorized-access angle for the three named gaps.
- No redesign. This plan runs no design route (see Section 9).
- No deployment. Bucket B and Bucket C of the sibling production-readiness plan (`docs/plans/lizbeth-spanish-production-readiness.md`) remain unauthorized by this plan.
- No changes to the 78-week content wiring.
- The full content-provisioning script (`scripts/provision-lessons.ts`) is not required for these three journeys; they rely only on the Beginner weeks 1–4 seed fixtures that always exist after `supabase start`.

## 3. Repository findings and evidence

All findings below are from `H:\CommandCenter\orchestrator\lizbeth_spanish`, a separate, independently gitignored repository from this orchestrator repo, as supplied in the planning handoff.

1. **Owner save path.** `src/pages/OwnerSettingsPage.tsx` `handleSubmit` calls `src/services/ownerSettingsData.ts` `saveOwnerSettings`, which invokes `client.functions.invoke('owner-settings', PUT)`. The Edge Function `supabase/functions/owner-settings/index.ts` verifies the caller's JWT against GoTrue, requires `app_metadata.role === 'owner'`, then performs a service-role upsert into `owner_settings` keyed on `owner_id`. Success is shown inline via a `role="status"` `aria-live` region (`OwnerSettingsPage.tsx`, roughly lines 293–297), never a native dialog. On the success branch the page also updates local field state and calls `refresh()`.

2. **Persistence read path.** `src/context/BrandingContext.tsx` `BrandingProvider` fetches `getOwnerBranding()` (`src/services/ownerSettingsData.ts`) via the anon-key, RLS-respecting client. `owner_settings` grants authenticated read-only `SELECT` (migration `202607170007_owner_settings_authenticated_read.sql`), so after a full reload the saved `brand_name` repopulates both the app header (`src/App.tsx`, `<p class="app-header-brand-name">{branding.brand_name}</p>`, roughly line 62) and the `OwnerSettingsPage` brand-name field (a `useEffect` sync, roughly lines 98–102). This dual-surface repopulation is the persistence proof.

3. **Edge runtime.** `supabase/config.toml` sets `[edge_runtime] enabled = true`, so `npx supabase start` serves the `owner-settings` function locally (`verify_jwt` defaults to `true`). A function that is not actually being served locally is the single most likely cause of a prior false failure; readiness must confirm the function is reachable, and the reload-based positive control distinguishes a genuine save from a false "success."

4. **Permission-denied path.** The `/admin` route matches for any authenticated user (`src/hooks/useRoute.ts`, `matchAdminRoute`; the code comment there states that a direct visit by a non-owner still reaches this route, and the page itself renders the inline permission-denied state). `src/App.tsx` hides the "Course settings" nav button when the user is not the owner, but does not block the route itself. `OwnerSettingsPage.tsx` (roughly lines 113–123), for a non-owner, returns an inline `<p role="alert" class="owner-settings-permission-denied">` with no form fields rendered. `isOwnerUser` (`src/lib/ownerSettingsAuthorization.ts`) is the client-side UX check only; the real security boundary is the Edge Function plus RLS.

5. **Negative data-layer path.** `src/components/ResourcesPanel.tsx` calls `src/lib/storageSigning.ts` `getSignedResourceUrl`, which calls `client.storage.from('lesson-assets').createSignedUrl(path)`. This is gated by the RLS policy `students_read_unlocked_lesson_assets` on `storage.objects` (migration `202607170005_storage_gating_policy.sql`), which joins `resources` → `lessons` → `student_enrollments` and requires that the week be unlocked (`now() >= enrollment_date + unlock_offset_days`) or have a past `completed_at`. `getSignedResourceUrl` returns `{ok: false, reason}` identically for both a denial and a not-found case, so a denial response cannot be used to probe existence. Locked weeks render no resource rows in the UI at all (resources-table RLS blocks the rows, so `WeekDetailPage` never enters its "available" view-state for a locked week), so the storage-layer denial cannot be exercised through app UI alone; it must be exercised from the authenticated browser JS context directly.

6. **Seed fixtures.** `supabase/seed.sql` (always present after `supabase start`, independent of the full provisioning script) provisions:
   - `owner@test.local` (UUID ending `...099`, role `owner`).
   - `student1@test.local` (UUID ending `...001`, Beginner band, enrolled 21 days ago, giving access to weeks 1–4 with week 1 unlocked).
   - `student4@test.local` (UUID ending `...004`, Beginner band, enrolled 5 days ago, with a 21-day unlock offset, so week 4 is locked; week-4 resource rows and the corresponding storage object exist).
   - `student5@test.local` (UUID ending `...005`, zero enrollments).
   - All seed passwords are `password`.
   - Beginner weeks 1–4 have resource rows and distinct per-week storage paths (for example `beginner/week-01/beginner-week-01-student-handout.pdf` through `week-04`), which deliberately keep each week's gating independent even though the underlying bytes are reused across weeks.

7. **No-native-dialog invariant.** This is enforced app-wide and by a deterministic scan, `src/__tests__/nativeDialogPolicy.test.ts`. The modal primitive `src/components/Modal.tsx` is accessible: it implements a focus trap, `Esc` handling, and focus restoration.

No new research evidence was supplied for this plan; all evidence above is local repository observation carried over from the planning handoff and empirically re-verified against documented behavior during execution.

## 4. Ordered work per gap, with acceptance checks

### Gap 1 — Owner-settings Save persists across a full reload

1a. **Preconditions.** Run `npx supabase start` and confirm via `npx supabase status` that Postgres, Storage, and the `owner-settings` Edge Function are reachable. Then, as a required deterministic reachability gate before any browser testing begins, either run `npx supabase functions serve owner-settings` explicitly or issue a direct unauthenticated `PUT` to the function URL (`.../functions/v1/owner-settings`) and require an HTTP 401 response body "Missing Authorization bearer token." as proof the function is served and reachable; the function responds only to `PUT`/`OPTIONS`. A connection-refused response, a 404, or a timeout means the function is unserved and must be resolved before Gap 1 testing proceeds, so an unserved function is caught by this readiness gate rather than surfacing later as a false Gap 1 save failure. This direct-PUT check complements, and does not replace, the `npx supabase status` check. Then run `npm run dev` and confirm the actual printed dev URL (do not assume a fixed port).

1b. **Positive end-to-end.** Sign in as `owner@test.local` / `password`. Navigate to `/admin` and confirm the real owner-settings form renders. Change `brand_name` to a distinctive, previously-absent sentinel value (for example, a value that includes a timestamp). Click "Save settings." Confirm the inline success status appears (`role="status"`, `aria-live`), never a native dialog. Capture a screenshot.

1c. **Persistence proof.** Perform a full browser reload of `/admin` (F5 or a fresh navigation, not a client-side route change). Confirm the brand-name field repopulates with the sentinel value and that the app header brand-name also shows the sentinel, proving the value round-tripped through the Edge Function into the `owner_settings` table and back out through `getOwnerBranding`, rather than merely persisting in React state. Capture the header's pre-change value and its post-reload value so the two can be shown to differ (this guards against a silent false pass). Capture screenshots of both states.

1d. **Contingent fix.** If Save shows the error branch instead of success (for example, the Edge Function is not served, a CORS failure, or an owner-claim failure), that is a real finding: root-cause it, fix it, and re-run 1b–1c to genuine green. No timeout-only or cosmetic fix is acceptable.

**Acceptance (Gap 1).** The sentinel `brand_name` is present in both the settings field and the header after a full reload; success was shown inline and never as a native dialog; the deterministic no-native-dialog scan passes; and persistence is demonstrated as an observed change from a captured prior value.

### Gap 2 — Non-owner is denied Course Settings in the browser, accessibly and non-natively

2a. Sign in as `student1@test.local` / `password` (a non-owner). Confirm the "Course settings" nav button is absent for this user.

2b. Directly navigate to `/admin` (typed URL, `pushState`, or a reload while already on `/admin`). Confirm the inline permission-denied view renders: the "Course settings" heading plus the `role="alert"` paragraph ("You do not have permission to view or change course settings..."), and that no settings form fields (the brand-name input, the Save button) are present. Capture a screenshot.

2c. Confirm the denial is app-owned and accessible: a `role="alert"` region, a keyboard-reachable page, and no native `alert`/`confirm`/`prompt` anywhere in the journey. Run the deterministic no-native-dialog scan. Verify the denied view at a 320px viewport reflow (given a prior WCAG header-clip finding on this project) with no clipping or overlap. Capture a screenshot at 320px.

2d. **Positive control (role discrimination).** The owner's `/admin` form from Gap 1 confirms the gate discriminates by role rather than blanket-blocking every visitor.

2e. **Contingent fix.** If a non-owner reaches any settings field, or the denial is rendered as a native dialog, or content is clipped at 320px, that is a real finding: root-cause it, fix it, and re-prove.

**Acceptance (Gap 2).** A non-owner visiting `/admin` sees only the accessible inline denial with zero form fields; the owner sees the real form; zero native dialogs occur anywhere in the journey; and the 320px reflow is clean.

### Gap 3 — Student directly attempting a locked/unentitled resource is denied at the storage/RLS layer

3a-pre. **Required pre-test target confirmation.** The RLS policy `students_read_unlocked_lesson_assets` (migration `202607170005`) grants access to a `storage.objects` path only when a `public.resources` row's `storage_path` equals that object name and the joined lesson's week is unlocked for the caller's enrollment. Per `supabase/seed.sql` (the resource-insert `CASE`, roughly lines 257–278), every Beginner weeks 1–4 resource row hardcodes the week-01 filename under a distinct per-week directory, so the week-4 PDF resource row's `storage_path` is exactly `lesson-assets` / `beginner/week-04/beginner-week-01-student-handout.pdf`. That is the correct, RLS-relevant target for the locked-week negative control, and the corresponding object exists on disk at `supabase/storage-seed/lesson-assets/beginner/week-04/beginner-week-01-student-handout.pdf`. Note that the `week-04` directory also contains a second, unreferenced file, `beginner-week-04-student-handout.pdf`, that no resource row points to; this file must not be used for the locked-week test, because a denial on it would mean "no matching resource row" rather than "week locked," and would misrepresent the RLS finding. Before treating any `createSignedUrl` failure as an RLS denial, independently confirm the target object actually exists at the exact `beginner/week-04/beginner-week-01-student-handout.pdf` path, for example via a service-role or Studio storage listing, or by confirming an entitled user can sign that exact path, so a genuinely missing object (a 404) can never be mistaken for an RLS denial.

3a. **Negative, locked and enrolled.** Sign in as `student4@test.local` / `password` (Beginner band, week 4 locked). From the authenticated browser JS context, invoke a signed-URL request for the confirmed locked-week target `lesson-assets` / `beginner/week-04/beginner-week-01-student-handout.pdf`. The authoritative proof of RLS denial is captured at the `createSignedUrl` call itself: `createSignedUrl` returns an error and no `signedUrl` (`data.signedUrl` is `null` with an error object), because `createSignedUrl` is itself the RLS-gated operation, the storage API evaluates the `SELECT` RLS policy on `storage.objects` at the sign request (`POST /storage/v1/object/sign/...`), not at a later fetch of the resulting URL. Capture the actual error object and HTTP status the local Supabase storage API returns for this call. `getSignedResourceUrl` should correspondingly return `{ok: false, reason: ...}`.

3b. **Negative, unentitled and unenrolled.** Sign in as `student5@test.local` / `password` (zero enrollments). Invoke `createSignedUrl` for an otherwise-valid path, `beginner/week-01/beginner-week-01-student-handout.pdf`, and confirm it is denied at the `createSignedUrl` call in the same way as 3a: `data.signedUrl` is `null` with an error object. Capture the actual raw response.

3c. **Positive control (red/green).** Sign in as `student1@test.local` / `password` (Beginner, week 1 unlocked). Invoke `createSignedUrl` for `beginner/week-01/beginner-week-01-student-handout.pdf` and confirm it succeeds and that the returned URL actually downloads (HTTP 200). This proves the gate discriminates correctly rather than failing globally.

3d. **Denied-vs-not-found equivalence control.** Add a genuinely nonexistent object path as an explicit paired control, for example `beginner/week-99/does-not-exist.pdf`, a path with no resource row and no underlying storage object. As any signed-in student, invoke `createSignedUrl` for this path and capture the raw storage response alongside the app-layer `getSignedResourceUrl` result. Capture both the raw storage-API responses and the app-layer `getSignedResourceUrl` results for all three cases (locked/enrolled from 3a, unentitled/unenrolled from 3b, and genuinely missing from this step). The concrete, load-bearing assertion is at the app-surfaced layer only: `getSignedResourceUrl` must return the same generic denial reason string for the locked/unentitled cases and for the genuinely-missing-object case, so a student cannot use the app to distinguish "this exists but I am not entitled" from "this does not exist" (no existence probing is possible from the app). The raw storage-API responses may differ between these cases at the transport level; that difference is expected and is not itself a finding. Both raw responses are captured only as supporting evidence for the app-layer comparison.

3e. **Method (no production code change).** From Claude in Chrome or Playwright's `page.evaluate`, construct an anon-key supabase-js client bound to the signed-in student's session access token read from `localStorage` (the anon key is public-by-design and RLS-protected), and call `storage.from('lesson-assets').createSignedUrl(path)`. This exercises the same `storage.objects` RLS boundary the app itself uses, from the browser, with no UI or production change. Do not ship any dev-only client exposure; if a temporary `window` exposure is used for this test it must be dev-guarded and removed afterward. Capture screenshots and the raw response payloads as evidence.

3f. **Contingent fix.** If a locked or unentitled `createSignedUrl` call succeeds, that is a genuine security finding: root-cause it against the RLS policy and the resource/storage-path mapping, fix it, and re-prove the full red/green set.

**Acceptance (Gap 3).** The locked (`student4`, week 4, at the confirmed `beginner/week-04/beginner-week-01-student-handout.pdf` target) and unentitled (`student5`) `createSignedUrl` calls each return `data.signedUrl: null` with a captured error object, proven at the sign-request call itself; the entitled request (`student1`, week 1) succeeds and its returned URL downloads (HTTP 200); and the app-layer `getSignedResourceUrl` reason string is the same for the locked/unentitled cases and the genuinely-missing-object case, so denied and not-found remain indistinguishable to the app's caller. The pre-test target-existence confirmation in 3a-pre was performed before any denial was attributed to RLS.

## 5. Reliability and tooling strategy

This section responds directly to the user's explicit request to prevent a repeat of the prior pattern in which browser automation "silently failed to work correctly four separate times."

- **Primary tool.** Claude in Chrome (the Browser Validator Chrome-first path), reusing the existing Chrome session with a localhost site permission.
- **Documented fallback.** Playwright (headed Chromium), used if the Chrome extension destabilizes. The switch trigger is explicit and bounded: two consecutive tool timeouts, a lost or unresponsive tab, or a non-responsive DOM. The same tool must not be silently retried past that trigger; the tool switch must be recorded in the evidence log.
- **Anti-silent-failure design.** Every gap is proven as a red/green pair, a positive control that must pass and a negative case that must be denied, so a pass cannot be a coincidental silent failure. For Gap 1, the sentinel value must differ from a captured prior value. For Gap 3, the denial must be a captured response payload, not merely the absence of a link.
- **Evidence.** A screenshot at every milestone of every journey, plus captured console and network payloads for Gap 3, written to a known artifacts directory under the `lizbeth_spanish` repository (gitignored, for example a `browser-validation-artifacts` folder). Results are reported as visible outcomes, never as bare completion claims.
- **Fixture scope.** The full provisioning script (`scripts/provision-lessons.ts`) is not required for these three journeys; they rely only on the Beginner weeks 1–4 seed fixtures that always exist after `supabase start`. Gap 3 specifically relies on the seed's distinct per-week storage paths.

## 6. Browser UI dialog policy

This policy is required and binding for all work under this plan.

- No `alert`, `confirm`, or `prompt`, no `window.*` variants of them, and no `beforeunload` prompt anywhere touched by this plan.
- The permission-denied view must remain an app-owned, accessible, inline `role="alert"` region and must never become a native dialog.
- Save success must remain an inline `aria-live` status, never a native dialog.
- The deterministic no-native-dialog scan (`src/__tests__/nativeDialogPolicy.test.ts`) must pass, and zero native dialogs must be observed across all three journeys.
- Any native dialog observed during any journey is an automatic fail; it is not a waivable note.
- Any modal involved in any journey must preserve keyboard and focus behavior: focus trap, `Esc` handling, and focus restoration. This check is unconditional and required, not optional, for any modal actually encountered during any of the three journeys. The three journeys as specified are expected to be inline surfaces (the permission-denied view is an inline `role="alert"` region, save success is an inline `aria-live` status, and the resource-access denial is an inline app-layer result), so a modal may not appear during a clean run; but if a modal does appear in any journey, this focus-trap/Esc/focus-restoration check is a required acceptance check for that journey, not a conditional or optional note.

## 7. Browser validation brief

- **Launch/readiness.** `npx supabase start`; confirm Postgres (54321/54322), Storage, and the `owner-settings` Edge Function are reachable via `npx supabase status`. As a required, additional deterministic reachability gate before Gap 1 testing begins, either run `npx supabase functions serve owner-settings` explicitly or issue a direct unauthenticated `PUT` to `.../functions/v1/owner-settings` and require the HTTP 401 body "Missing Authorization bearer token." as proof the function is served (the function responds only to `PUT`/`OPTIONS`); a connection-refused response, a 404, or a timeout means the function is unserved and must be resolved first. This direct-PUT check complements, and does not replace, the `npx supabase status` check. Then `npm run dev`; confirm the actual printed dev URL.
- **Base URL.** `http://localhost:5173` (the Vite default). Confirm the actual printed port at runtime; the README is authoritative but Vite may select the next free port if 5173 is in use.
- **Fixture/reset.** `supabase/seed.sql` fixtures, loaded automatically by `npx supabase start`; reset with `npx supabase db reset` if needed. Accounts required for the three journeys, all with password `password`:
  - `owner@test.local` (owner).
  - `student1@test.local` (Beginner, week 1 unlocked; entitled positive control).
  - `student4@test.local` (Beginner, week 4 locked; negative case).
  - `student5@test.local` (zero enrollments; negative case).
- **Journeys.** The three gap journeys in Section 4, each executed as a red/green pair.
- **Viewport profiles.** Desktop 1440x900 as primary; a 320px reflow check on the permission-denied view and the owner-settings form (given the prior WCAG header-clip finding); mobile 360x800; and desktop at 200% zoom on the settings and denied views.
- **Visible outcomes.**
  - The sentinel `brand_name` persists in both the settings field and the header after a full reload, and differs from a captured prior value.
  - A non-owner visiting `/admin` sees only the accessible inline denial with zero form fields, with a clean 320px reflow.
  - Locked (`student4`, week 4) and unentitled (`student5`) `createSignedUrl` requests return captured denial payloads, a forged-URL fetch returns HTTP 403, and the entitled (`student1`, week 1) request succeeds and downloads.

## 8. Interfaces and data

- The `owner-settings` Edge Function (`PUT`), performing a service-role upsert into `owner_settings`, and an anon-key authenticated `SELECT` for reads (migration `202607170007_owner_settings_authenticated_read.sql`).
- The `storage.objects` RLS policy `students_read_unlocked_lesson_assets` (migration `202607170005_storage_gating_policy.sql`) and the `resources` / `lessons` / `student_enrollments` RLS chain (migration `002`).
- No schema, migration, or interface change is planned by this document. Any contingent bug fix arising from Section 4 must preserve these existing contracts rather than altering them.
- No hosted state is touched anywhere in this plan; all work runs against the local Supabase stack only.

## 9. Design route

No design route is run. Reasons: this plan verifies existing surfaces in preserve mode; it introduces no new interface, component, flow, or design-system value. Any in-scope bug fix arising from Section 4 must be a minimal brownfield repair that preserves the existing design system. A fix that would require a materially new user-visible surface is a re-plan trigger, not part of this plan's authorization. `agents_required`: none. Prototype: forbidden. `existing_system_mode`: preserve. No design agents were, or will be, invoked; design status is not applicable.

## 10. Risks and rollback

- **Risk: the `owner-settings` Edge Function is not served locally, producing a false Gap 1 failure.** Mitigation: explicit readiness confirmation of function reachability (Section 4, step 1a) plus the reload-based positive control that distinguishes real persistence from a false success. Severity: medium, a false-negative testing risk rather than a product defect.
- **Risk: a genuine defect is found in one of the three areas.** Then an in-scope, root-caused fix applies per the relevant gap's contingent-fix step, re-proven red/green. Rollback is a plain commit revert in the `lizbeth_spanish` repository. No hosted state is affected.
- **Risk: `createSignedUrl` RLS does not behave as documented, and the Gap 3 negative case succeeds when it should be denied.** This is treated as a real security finding requiring a fix. The architecture was reportedly already exercised via prior A4 reachability testing, so the probability is assessed as low, but the impact would be high if the finding occurs.
- **Rollback for all work under this plan.** A plain commit revert in the `lizbeth_spanish` repository. No hosted or deployed state is touched by any activity under this plan.

## 11. Assumptions and open decisions

- **Labeled assumption.** These three areas are currently believed correct and merely unverified at the browser level. This plan is verification-first, with a contingent in-scope fix applying only if a defect is actually found during execution.
- **Decision.** Gap 3's storage-layer negative test is driven from the browser JS context (`page.evaluate` or console) using an anon-key client bound to the signed-in student's session token, because locked weeks intentionally expose no UI affordance that reaches `createSignedUrl`. This method adds no production code. If a temporary dev-only client exposure is used for this test, it must be dev-guarded and must not be shipped.
- **Decision.** No design route is run under this plan, and no full content provisioning is required for these journeys.
- **Approval still needed.** Explicit user approval of this plan is required before any execution. If execution reveals a defect requiring more than a minimal brownfield fix, for example a materially new user-visible surface, that is a re-plan trigger requiring a new plan or explicit reapproval; it is not covered by this plan's authorization.
- **Plan revision note.** This document was revised once, before any execution, in response to a PLAN_DUCK shadow-mode REVISE verdict (findings J-001 through J-005). The corrections were plan-methodology only: they grounded the Gap 3 locked-week storage target in the actual seeded `resources.storage_path` and added a pre-test existence check (J-001); moved the authoritative Gap 3 RLS-denial proof to the `createSignedUrl` call itself and removed the forged-URL-fetch-403 step, which could fail for an unrelated signature-validation reason before reaching the RLS boundary (J-002); precisely defined the denied-vs-not-found equivalence as an app-layer `getSignedResourceUrl` assertion, with a genuinely nonexistent path as a paired control (J-004); added a deterministic direct-PUT reachability gate for the `owner-settings` function ahead of Gap 1 testing (J-003); and made modal keyboard/focus checks unconditional for any modal actually encountered (J-005). Scope, non-goals, the three named gaps, and the Draft status were not changed by this revision.

## 12. Engineering mode

**Standard.** After approval, `engineering-fleet` decomposes this plan into verification `ENGINEERING_JOB`s, one per gap is acceptable, each running through Verifier and then Browser Validator per the brief in Section 7. Any contingent fix arising from a genuine finding is a bounded T1 job with its own Verifier and Browser Validator re-proof. No extreme-advisory team is warranted for this scope.

`team_authorization`: not applicable.

## 13. Downstream owners and approval gate

**Downstream owner.** `engineering-fleet`.

**Approval gate.** This document is a plan for review, not authority to execute. No verification job, and no contingent fix, may begin until the user has explicitly approved this plan. Upon approval, this Status section should be updated to record the approval, consistent with the sibling plan's practice in `docs/plans/lizbeth-spanish-production-readiness.md`.
