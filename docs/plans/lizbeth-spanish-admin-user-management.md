# Lizbeth Spanish: Admin Student & User Management (Increment 1)

## Status

**Implemented.** *(Header corrected 2026-07-25.)* This header previously read "Draft — awaiting user approval," but repository evidence shows this plan's scope has been fully implemented and pushed. No record of an explicit user approval event for this specific plan was found during this correction; the status update reflects that the work was executed, not that a prior approval is being retroactively asserted. If confirmation of the original approval is needed, it should be sought from the user directly.

## Outcome and audience

**Audience:** the single course owner (Lizbeth), who reviews and approves this plan before any implementation.

**Outcome:** an executable, Increment-1 plan for an in-app admin "Students" surface that lets the owner:

- Register students (owner-created accounts).
- Soft-disable/re-enable accounts, and hard-delete accounts.
- Manage per-student course (band) access under a non-destructive multi-save model.

This plan is grounded in read-only repository evidence, a passed Standard design route, and full risk/security scrutiny (target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`).

## Scope and non-goals

### In scope (Increment 1)

- A new owner-only "Students" section inside the existing `/admin` area: a student roster (email, account status, active course-assignment summary) and a per-student detail view (saves grouped by band).
- **Register a new student:** owner-created account via a service-role Edge Function that returns a ONE-TIME temporary password (no real outbound email exists locally); a pending-first-login indicator.
- **Soft-disable** (primary, reversible, preserves records) + **re-enable**; **hard-delete** (secondary, irreversible, extra typed confirmation).
- **Course access management:** assign a band (choose enrollment/attempt date); NON-DESTRUCTIVE unassign (active save becomes preserved); re-assign with an explicit resume-a-preserved-save vs start-a-fresh-attempt choice; wipe a specific save (destructive, extra typed confirmation). Exactly one ACTIVE save per (student, band); only the active save grants access.
- The required schema migration + RLS hardening enabling the above (see "Interfaces and data").
- Service-role Edge Function admin operations + owner-only frontend + tests + browser validation.

### Non-goals / out of scope

- **Increment 2** = explicit backup/restore snapshots (owner-triggered in-DB snapshots, Option A, no file export/import). This is documented here as future work only and is **not built in Increment 1**.
- No live deploy, hosted migration, Netlify/Supabase promotion, or hosted secrets (consistent with the production-readiness plan's deferral).
- No multi-admin/role hierarchy.
- No new routing library, no new modal mechanism, no new design primitives/fonts/radius tiers.
- No student-facing UI changes beyond the RLS effect that students see only their single ACTIVE save.

## Repository findings and evidence references

All findings below are direct observations from the current repository state (`lizbeth_spanish`), supplied by Planner's nested repository analysis. No external research was used for this plan (`research_evidence: none`) — GoTrue Admin API behavior and Supabase RLS mechanics are treated as stable, known platform behavior and are demonstrated locally by the existing seed and Edge Function patterns.

- **Data model** (`supabase/migrations/202607170001_init_schema.sql`): "bands" ARE courses (Beginner/Intermediate/Advanced + an "Advanced Immersion (Unpublished)" fixture). `student_enrollments` is the entitlement table with `constraint unique_active_enrollment unique (user_id, band_id)` (line 45) — one row per (user, band) today; columns `enrollment_date` (drives per-week unlock via `lessons.unlock_offset_days`), `completed_at` (with a `completed_at<=now` check). Foreign keys to `auth.users` are `ON DELETE CASCADE` (a hard user delete wipes that user's enrollments and feedback_submissions).
- **RLS entitlement surface that keys on enrollment existence and MUST be hardened** (see "Interfaces and data"):
  - `students_read_enrolled_band_lessons` (lessons) and `students_read_unlocked_resources` (resources) in `202607170002_rls_policies.sql`.
  - `students_read_unlocked_lesson_assets` (`storage.objects` — the signed-URL layer) in `202607170005_storage_gating_policy.sql`.
  - `students_read_own_enrollments` (students see their own rows) in `202607170002`.
  - Every table also has a `service_role_all_*` policy. Authenticated grants are SELECT-only on these tables (`202607170004`, `202607170009`); `owner_settings` is service-role-write only.
- **Owner authorization:** owner = `raw_app_meta_data {"role":"owner"}` claim, writable only via service-role/seed (`supabase/seed.sql`), never via any authenticated/RLS path. Shared check `isOwnerUser` in `src/lib/ownerSettingsAuthorization.ts` (used both client-side for UX routing and server-side in the Edge Function as the real gate).
- **Established secure-write pattern to mirror:** `supabase/functions/owner-settings/index.ts` — verifies the caller token via `auth.getUser`, requires `isOwnerUser`, then uses a service-role client (`SUPABASE_SERVICE_ROLE_KEY`, server-only) to write; returns `{data}`/`{error}`; input validated by a dependency-free lib importable by both Vite and Deno (`ownerSettingsAuthorization.ts`). Client data layer mirror: `src/services/ownerSettingsData.ts` (`invoke('...')` via `functions.invoke`).
- **Frontend conventions:**
  - `src/App.tsx` (owner-only nav button gated by `isOwnerUser`; `AuthenticatedApp` route switch).
  - `src/hooks/useRoute.ts` (dependency-free router; `navigate()`, `matchAdminRoute()==='/admin'`, `matchWeekDetailRoute` param-shape precedent).
  - `src/pages/OwnerSettingsPage.tsx` (owner admin page precedent: inline `<p role="alert">` permission-denied at ~lines 113-123 and hardcoded `<h1>Course settings</h1>` at lines 116/177; `SaveState` idle/saving/success/error pattern; focus-first-invalid-field).
  - `src/components/Modal.tsx` + `Modal.css` (the ONLY accessible confirmation mechanism: `role=dialog`, `aria-modal`, focus trap including container, Escape, focus restoration, inert backdrop; 640px breakpoint; no footer slot).
  - `src/tokens/{primitives.json,semantic.json,components.json,tokenSystem.ts}` (Field Workbook DTCG tokens; `color.surface.chrome.text = ink.800` precedent).
  - Native-dialog policy enforced by `src/__tests__/nativeDialogPolicy.test.ts` (whole-`src` scan; automatically covers new files).
- **Auth config** (`supabase/config.toml`): `enable_signup=true`, `[auth.email] enable_confirmations=false`; only a local mail-catcher (Inbucket, port 54324) — NO real outbound email; `minimum_password_length=6`; `jwt_expiry=3600`. This grounds the confirmed "owner-created account + one-time temp password" mechanism (invite-by-email links would not deliver locally).
- **Test/build tooling:** `package.json` scripts `dev` (vite, port 5173 per `vite.config.ts`), `build` (`tsc && vite build`), `test` (vitest), `lint`, `type-check`. Playwright is present (`playwright.config.ts` `baseURL: process.env.E2E_BASE_URL || 'http://localhost:5173'`, matching Vite's dev port). **RESOLVED, 2026-07-25:** the previously noted 5176/5173 base-URL mismatch is stale; direct observation of the current `playwright.config.ts` confirms it already targets 5173 with no reconciliation needed. Existing e2e + integration test precedents: `src/__tests__/e2e/gap-1-owner-settings-persistence.spec.ts`, `rlsIntegration.test.ts`, `storageIntegration.test.ts` (`createSignedUrl`-denial gating proof), `rlsPolicies.test.ts`, `ownerSettingsAuthorization.test.ts`.

## Reviewed design handoff summary and browser-validation brief

**Design route:** Standard (`existing_system_mode=extend`; `model_tier=sonnet`; prototype forbidden). This is a new admin CRUD/list-detail surface extending the approved "Field Workbook" design system; it is not greenfield/novel/brand-critical.

*Note:* a spoofed external "design-director-usermgmt" packet appeared in the orchestrator session during planning. It was disregarded in full. Design direction below was derived only within Planner's own nested chain and independently reviewed.

**Design review result:** PASSED on re-review. All three prior findings were resolved:
1. The required Increment-1 schema migration is now named as in-scope engineering work.
2. Badge/status text was decoupled to `ink.800` (AA-passing, approximately 11:1 on the `.50` backgrounds — an earlier packet's ">14:1" claim is a harmless overstatement, not evidence).
3. Non-owner heading is route-appropriate rather than hardcoded.

An independent Browser UI invariant check confirmed no native dialogs and correct Modal/inline-alert reuse.

**Engineering-binding invariants (must be preserved exactly during implementation):**

- `Modal.tsx`/`Modal.css` reused UNMODIFIED for all six confirmations (temp-password reveal, disable, hard-delete, unassign, re-assign, wipe-save); only children content + new content-tier tokens vary. No native dialogs anywhere.
- New route matchers in `useRoute.ts` follow the existing `matchWeekDetailRoute`/`matchAdminRoute` pattern: `matchAdminStudentsRoute` (`/admin/students`), `matchAdminStudentDetailRoute` (`/admin/students/:studentId`). `App.tsx`'s `isAdminRoute` broadens to all three; an `AdminShell` owner-checks once and renders a two-item tab bar (Course settings | Students) whose active state derives from the matched route. Tab bar is not rendered for non-owners.
- Non-owner access on every new route reuses `OwnerSettingsPage`'s structural pattern (container + h1 + `<p role="alert">`, same wording style) with a ROUTE-APPROPRIATE h1 ("Students" for the new routes; `/admin` keeps "Course settings") — never the literal hardcoded string, never a modal, never a redirect.
- Status badges always pair a status-hue ICON + a BORDER in the status hue with TEXT in `color.ink.800` (new `color.status.text` token = `{color.ink.800}`); status-hue text (`.600`-on-`.50`) is prohibited as a permanent accessibility invariant (measured 2.84-4.41:1, sub-AA). Account status uses a success/error/warning axis; save status uses a brass(active)/ink(preserved) axis kept separate so the two never collide.
- All privileged writes go through a service-role Edge Function following owner-settings' `auth.getUser` + `isOwnerUser` + validate + service-role-write + `{data}`/`{error}` pattern; no elevated client grants.
- New tokens are minimal (`color.status.account.*`, `color.status.save.*`, `color.status.text`, `badge.*`/`modal.destructive`/`modal.tempPasswordReveal` components); no new primitive hex, font, or radius tier (`card.radius 0.375rem` already exists).
- Temp-password reveal: one-time, selectable/monospace, Copy with `role=status` "Copied" (text `ink.800` + success-colored icon), explicit non-recoverability warning, Done.
- Destructive tier (hard-delete, wipe-save): `error.50` itemized-consequences block + typed-confirmation gating a disabled-until-exact-match `error.600`-fill confirm button. Calm tier (disable, unassign): single-step confirm, `button.primary`. Re-enable: no modal (lower friction, by design). Exact specs (fixed by remediation, not engineering discretion):
  - **Hard-delete:** the itemized-consequences block must RENDER in the DOM before the confirm control becomes enabled (not merely gated eventually), listing: (1) the student's login/auth account; (2) ALL their course saves for every band, both active AND preserved; (3) all their feedback submissions; (4) that the removal is an irreversible cascade. Typed-confirmation string = the student's exact email address. Confirm button reads "Delete permanently," starts disabled, and enables only on an exact match.
  - **Wipe-save:** the itemized-consequences block must render before the confirm control enables, stating that only the progress and completion record of that ONE specific save/attempt for that band is erased; it must explicitly contrast with unassign (unassign PRESERVES the save; wipe removes it entirely) and state there is no effect on the account or other saves. Typed-confirmation string = the literal text `WIPE`. Confirm button starts disabled and enables only when the typed value exactly equals `WIPE`.

### Browser-validation brief

- **Launch/readiness:** local Supabase (`supabase start`; `supabase db reset` to apply migrations + seed) and the Vite dev server (`npm run dev`). **RESOLVED, 2026-07-25:** `vite.config.ts` serves port 5173 and `playwright.config.ts`'s `baseURL` is `process.env.E2E_BASE_URL || 'http://localhost:5173'` — the two already match; no reconciliation is needed for the browser-validation pass.
- **Base URL:** the local dev origin's `/admin`, `/admin/students`, and `/admin/students/:id` paths.
- **Fixture/reset:** extend `supabase/seed.sql` to cover an owner account plus students exercising each state: an active account with an active save, a disabled account, a pending-first-login account, a student with MULTIPLE preserved saves in the same band (requires the Increment-1 migration), and a student with zero enrollments. Follow the existing `student1..6@test.local` synthetic pattern; no real PII.
- **Journeys:**
  - Register + temp-password (submitting state, modal focus trap, Copy announces via `role=status`, Done restores focus, roster shows Pending badge).
  - Disable/re-enable (badge flips; re-enable has no modal).
  - Hard-delete (typed-email gate, mismatch `role=alert`, row removed, mid-nav not-found is not a crash).
  - Assign (date defaults today, active save appears).
  - Non-destructive unassign (copy states progress preserved; save flips active -> preserved in place).
  - Re-assign resume-vs-new-attempt (radio group for 2+ preserved, Start-new reveals date field, Continue disabled until choice, arrow-key select does not auto-submit).
  - Wipe-save (spatially separated trigger, typed WIPE gate, save row removed, visually distinct from unassign).
  - Non-owner `/admin/students` shows a "Students"-headed permission-denied, not "Course settings".
- **Viewport profiles:** desktop >=1024px (table roster + side-by-side save rows), tablet ~768px (verify table->card reflow boundary), mobile ~375px (stacked cards, modal at 95vw).
- **Visible outcomes:** screenshots per state/viewport; status badges never rely on color alone (grayscale/contrast pass); hard-delete and wipe-save must read as equally high-stakes and clearly distinct from disable/unassign's calm tier.

### Browser UI dialog policy (mandatory, strict)

No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` anywhere. Every acknowledgement/confirmation (temp-password reveal, disable, hard-delete, unassign, re-assign, wipe-save) uses the app-owned accessible Modal (`src/components/Modal.tsx`) with correct keyboard/focus behavior, or inline validation where better. Enforced by `src/__tests__/nativeDialogPolicy.test.ts` (deterministic source scan) plus modal keyboard/focus verification.

## Ordered work

Sequence for engineering after approval. Each item is a logical unit suitable for a local commit.

1. **Schema migration:** add a status discriminator to `student_enrollments` and enforce at most one ACTIVE row per `(user_id, band_id)`. Exact SQL is fixed (see "Interfaces and data" for the full statements and rationale); include a down migration per the runbook in "Risks and rollback" (R1).
2. **RLS hardening (SECURITY-CRITICAL):** create the `public.is_account_active(uuid)` helper (see "Interfaces and data") and update all four entitlement predicates so access requires BOTH an active enrollment AND an active (non-banned) account:
   - Add the active-status and account-active conditions to `students_read_enrolled_band_lessons` (lessons).
   - Add them to `students_read_unlocked_resources` (resources).
   - Add them to `students_read_unlocked_lesson_assets` (`storage.objects`).
   - Constrain `students_read_own_enrollments` so a student sees only their ACTIVE save on an active account (decision: preserved/disabled saves are owner-only).
   - This RLS-layer account-active check is the mechanism that closes the disabled-account residual-access window (see "Risks and rollback," R3); GoTrue ban/unban alone is insufficient because access tokens are stateless JWTs that ban cannot revoke.
3. **Shared dependency-free auth/validation lib** (mirror `ownerSettingsAuthorization.ts`) importable by Vite + Deno: `isOwnerUser` reuse + input validation for each admin operation.
4. **Service-role Edge Function admin operations** (mirror owner-settings' three-layer pattern; owner re-checked server-side):
   - Roster read (users + status + enrollments).
   - Register (GoTrue Admin `createUser` -> return one-time temp password; set pending-first-login).
   - Disable (GoTrue ban) + re-enable (unban).
   - Hard-delete (GoTrue admin `deleteUser`; cascade acknowledged).
   - Assign (insert active enrollment with chosen date).
   - Unassign (active -> preserved).
   - Re-assign (resume chosen preserved -> active, or insert fresh active).
   - Wipe-save (delete one enrollment row).
   - Temp password is never persisted in plaintext beyond GoTrue; it is returned once.
5. **Client data-access layer** (mirror `ownerSettingsData.ts`) calling the Edge Function; typed errors.
6. **Frontend:** new route matchers + `AdminShell`/tab bar; roster view (loading/empty/error/success, search/filter); per-student detail (saves grouped by band); all six Modal confirmations + inline validation; status badges per the passed design tokens; owner-only + non-owner inline `role=alert` with route-appropriate h1.
7. **Tests** (see "Acceptance and validation") including the RLS-regression suite.
8. **Verifier pass, then Browser Validator pass.**

## Interfaces and data

- **MIGRATION (required, in-scope; exact SQL, not engineering discretion):** this is a change to the verified entitlement table and is treated as security-sensitive.
  ```sql
  -- Add the status column (text + CHECK, chosen over a pg enum to avoid
  -- enum-alteration friction and to match this schema's existing
  -- text-with-values convention, e.g. resource_type).
  alter table public.student_enrollments
    add column status text not null default 'active' check (status in ('active','preserved'));

  -- Explicit backfill (belt-and-suspenders; covers the case where the
  -- column is added nullable first). Existing rows are already populated
  -- to 'active' by the column default.
  update public.student_enrollments set status = 'active' where status is null;

  -- Drop the old table-wide unique constraint.
  alter table public.student_enrollments drop constraint unique_active_enrollment;

  -- Partial unique index: exactly one ACTIVE row per (user_id, band_id);
  -- multiple preserved rows are permitted.
  create unique index student_enrollments_one_active_per_band
    on public.student_enrollments (user_id, band_id)
    where status = 'active';
  ```
  The down-migration is specified as a runbook, not a bare statement list, because rollback safety depends on data state at rollback time; see "Risks and rollback," R1, for the full numbered runbook.
- **ACCOUNT-ACTIVE HELPER (required, new):** a `SECURITY DEFINER`, `STABLE` SQL function used by all four RLS predicates below to close the GoTrue-ban residual-access window (rationale in "Risks and rollback," R3):
  ```sql
  create function public.is_account_active(uid uuid)
    returns boolean
    language sql
    security definer
    stable
  as $$
    select not exists (
      select 1 from auth.users u
      where u.id = uid
        and u.banned_until is not null
        and u.banned_until > now()
    );
  $$;
  ```
  This function must be owned by a role with `SELECT` on `auth.users`; execute should be revoked from `anon` where appropriate. Exact ownership/grants are at engineering discretion, but the contract — every one of the four RLS predicates below enforces account-active in addition to enrollment-active — is fixed.
- **RLS CONTRACT CHANGE (required, exact predicate edits):** all four policies must gate on BOTH the enrollment being active AND the account being active. Missing either condition on any one policy silently lets a preserved/unassigned or disabled student retain resource access — this is the central risk of the increment.
  - `students_read_enrolled_band_lessons` (lessons): to the existing `exists (select 1 from public.student_enrollments where user_id = auth.uid() and band_id = lessons.band_id)`, add `and student_enrollments.status = 'active'` and `and public.is_account_active(auth.uid())`.
  - `students_read_unlocked_resources` (resources): to the existing exists-join (alongside the existing unlock/`completed_at` conditions), add `and se.status = 'active'` and `and public.is_account_active(auth.uid())`.
  - `students_read_unlocked_lesson_assets` (`storage.objects`, migration `202607170005_storage_gating_policy.sql`): to its exists-join, add `and se.status = 'active'` and `and public.is_account_active(auth.uid())`.
  - `students_read_own_enrollments`: change `using (user_id = auth.uid())` to `using (user_id = auth.uid() and status = 'active' and public.is_account_active(auth.uid()))` so a student sees ONLY their active save; preserved/disabled saves remain owner-only.
- **EDGE FUNCTION CONTRACT:** one or more service-role functions exposing the operations in "Ordered work" step 4; each verifies `auth.getUser` + `isOwnerUser` before any service-role write; returns `{data}`/`{error}`; never exposes the service-role key to the browser.
- **SOFT-DISABLE MECHANISM:** GoTrue Admin ban (`banned_until`/`ban_duration`) blocks new sign-ins and refresh; records are preserved. Re-enable clears the ban. Because access tokens are stateless JWTs, ban/unban alone cannot revoke an already-issued access token — immediate revocation on disable is enforced at the RLS layer by `public.is_account_active`, not by the ban call alone (see R3).
- **COMPATIBILITY:** existing single-enrollment rows remain valid (`status='active'` backfill); `RoadmapPage` already renders one card per enrollment and keys routes by `enrollmentId`, so active-only student visibility is consistent with current behavior.

## Acceptance and validation

- **RLS-REGRESSION SUITE (mandatory, named SECURITY GATE):** extend `rlsIntegration.test.ts` / `storageIntegration.test.ts` / `rlsPolicies.test.ts` patterns. This is FOUR separate deterministic regression tests, one per policy, each covering the active / preserved / disabled(banned) states, plus one transition test. Aggregating these into a single combined test is not sufficient:
  1. **Lessons visibility** (`students_read_enrolled_band_lessons`): active+active-account sees lessons; preserved denies; disabled(banned) account denies even with an active enrollment row.
  2. **Resources rows** (`students_read_unlocked_resources`): same three-state matrix, including the existing unlock/`completed_at` conditions.
  3. **Storage `createSignedUrl`** (`students_read_unlocked_lesson_assets`): extend the existing `storageIntegration.test.ts` `createSignedUrl`-denial pattern; signed URL creation must be DENIED for preserved and for disabled, and GRANTED only for active+unlocked.
  4. **Own-enrollments visibility** (`students_read_own_enrollments`): a student sees only their own ACTIVE rows; preserved and disabled-account rows are not visible to the student (owner-only).
  5. **Transition test:** assign -> active (access granted); unassign -> preserved (access revoked); re-assign -> active (access restored); disable -> access revoked immediately; re-enable -> access restored. The disable step specifically proves immediate revocation: disable, then issue a query using the still-valid pre-disable access token, and confirm it returns zero rows / denies `createSignedUrl` without waiting for `jwt_expiry`.
  - The partial unique index rejects a second ACTIVE row per (user, band).
  This gate is deterministic and dominates any judge or advisory signal; completion cannot be claimed while it fails.
- **Edge Function/authorization unit tests:** non-owner rejected on every operation; input validation; temp-password returned once and not persisted in plaintext.
- **Destructive-confirmation acceptance (hard-delete, wipe-save):** the itemized-consequences block renders in the DOM before the confirm control becomes enabled (verified, not assumed); the confirm button starts disabled and enables only on an exact match of the specified typed-confirmation string (student's exact email for hard-delete; literal `WIPE` for wipe-save). See "Reviewed design handoff summary" for the exact itemized content required for each.
- **Browser UI invariant:** `nativeDialogPolicy.test.ts` (extended over new files) returns zero matches; keyboard/focus verification for all six Modal usages (Tab/Shift+Tab cycle including container, Escape, focus restoration; confirm buttons unreachable-as-enabled until valid).
- **Accessibility/contrast check:** every account/pending badge text (`ink.800`) and the "Copied" status text meet >=4.5:1 on their `.50` backgrounds; status hue only in icon/border; status never color-alone.
- **Build/type/lint clean:** `tsc && vite build`; `npm run type-check`; `npm run lint` (confirm `import.meta.glob` content bundling and the Deno Edge Function are handled correctly outside the Vite build path).
- **Independent Verifier pass THEN Browser Validator pass before any completion claim.**

## Risks and rollback

**RISK TIER: HIGH.** This increment touches the verified RLS entitlement boundary via a schema migration, and adds account lifecycle, destructive actions, and credential handling. This risk tier is not reduced by any mitigation listed below; mitigations are controls, not a downgrade of severity.

- **R1 (critical) — RLS regression via preserved/disabled rows granting access.** Mitigation: the mandatory RLS-regression suite (four per-policy tests plus the transition test) gates completion; all four predicates plus own-enrollments enforce both enrollment-active and account-active; deny-by-default. **Rollback runbook (numbered, runnable; supersedes a bare "restore the constraint" statement):**
  1. **Pre-downgrade validation.** Capture counts (total enrollments; active count; preserved count) and run a duplicate-pair guard that ABORTS the runbook if any student has more than one row per band:
     ```sql
     do $$ begin
       if exists (
         select 1 from public.student_enrollments
         group by user_id, band_id having count(*) > 1
       ) then
         raise exception 'Cannot downgrade: duplicate (user_id, band_id) pairs exist; resolve multi-save rows first';
       end if;
     end $$;
     ```
  2. **Down-migration SQL** (only runs if step 1 passes):
     ```sql
     drop index if exists public.student_enrollments_one_active_per_band;
     alter table public.student_enrollments drop column status;
     alter table public.student_enrollments add constraint unique_active_enrollment unique (user_id, band_id);
     drop function if exists public.is_account_active(uuid);
     ```
     and revert the four RLS predicates (lessons, resources, storage.objects, own-enrollments) to their pre-feature form.
  3. **Post-downgrade validation.** Verify the row count is unchanged from step 1 and that `unique_active_enrollment` is present.
  4. **Re-run the FULL RLS-regression suite after rollback** to confirm pre-feature gating semantics are restored (a single active enrollment gates access; no residual access).
  5. **Explicit caveat.** This rollback is safe only while no student has more than one save per band, i.e. before multi-save data exists in practice. Once multi-save rows exist, rollback requires an explicit data-reconciliation decision about which preserved rows to drop. Treat that case as a stop-and-consult condition, not an automatic downgrade.
- **R2 — Migration on `student_enrollments`.** Existing rows backfill to active; the partial index is non-conflicting for current unique rows; verify before/after row counts. Keep the down migration (R1 runbook) available.
- **R3 — Disabled-account residual access, RESOLVED at the RLS layer.** Supabase access tokens are stateless JWTs: GoTrue ban/unban blocks new logins and revokes refresh tokens, but it CANNOT revoke an already-issued access token. An auth-layer-only control would therefore leave a residual access window of up to `jwt_expiry` (3600s) after disable — this was previously accepted as a bounded residual risk, and that framing is now superseded. Enforcement is moved to the RLS layer via `public.is_account_active` (see "Interfaces and data"), consistent with this app's existing design where RLS, not the auth layer, is the real access gate. Soft-disable still sets `banned_until` via the GoTrue admin API (blocking new logins/refresh); the RLS helper makes revocation take effect IMMEDIATELY on the next query regardless of any outstanding access token. The acceptance criterion is: a disabled account is denied at the RLS layer immediately upon disable — its next lessons/resources/storage query returns zero rows and `createSignedUrl` is denied, without waiting for JWT expiry. This is proven by the disable-transition test in "Acceptance and validation."
- **R4 — Hard-delete cascade** irreversibly removes account + enrollments + feedback. Mitigation: typed-email confirmation modal + itemized consequences + owner-only + server re-check.
- **R5 — Temp-password/PII handling.** One-time reveal, copy, never re-shown; no plaintext storage; conveyed out-of-band. No regenerate path in this increment (carried open item, see below).
- **R6 — Privilege boundary.** All writes go through the service-role Edge Function only; no elevated client grants; `isOwnerUser` re-checked server-side (defense in depth, matching the owner-settings precedent).
- **R7 — Browser UI invariant regression.** Mitigated by the native-dialog scan, Modal reuse, and the Browser Validator pass.

**Stale-plan trigger:** if `student_enrollments` schema, the RLS predicates, the owner-claim mechanism, or the Edge Function pattern change materially before or during implementation, the writer must return `JOB_BLOCKED "Plan stale"` for replanning or reapproval rather than proceeding on stale assumptions.

## Assumptions and confirmed/open decisions

### Confirmed by the user (settled)

- Registration = owner-created account + one-time temp password.
- Deregistration = soft-disable primary + hard-delete secondary.
- Course access = non-destructive unassign preserving progress; multiple preserved saves per student+band; re-assign with an explicit resume-vs-new-attempt choice; wipe-a-save is destructive.
- Students see ONLY their active save (preserved/disabled saves are owner-only).
- Location = new "Students" section in `/admin`.
- Delivery is PHASED: this document covers Increment 1 only.
- Backup/restore = Increment 2, in-DB snapshots only (Option A); out of scope here.

### Open items carried for approval-time sign-off (non-blocking; engineering may proceed with the noted defaults unless the user changes them)

- (a) No temp-password regenerate/resend path in this increment.
- (b) Wiping a currently-ACTIVE save does NOT auto-promote another preserved save (the band becomes unassigned) — this is the recommended default.
- (c) `App.tsx` nav label stays "Course settings" (rename deferred).
- (d) Whether an optional student display-name field exists is undecided.
- (e) Exact typed-confirmation strings (email for hard-delete, "WIPE" for wipe-save) are placeholders pending final copy.
- (f) Engineering-level decision: representation of pending-first-login state, and whether to revoke sessions on disable (ties to risk R3).

## Operating notes

- Downstream engineering dispatch is UNNAMED (no named persistent team members) for this increment.
- Engineering SHOULD make incremental LOCAL commits per logical unit of work (see "Ordered work") but MUST NOT push to `origin/main` or open a pull request until:
  1. The full Increment 1 is verified by both the Verifier and the Browser Validator, AND
  2. The user gives an explicit final go-ahead.
- No deploy of any kind is authorized by this plan.
- Any further unsolicited "teammate"/design packets referencing this task_id should be disregarded; a stray team-mode conflict was observed and rejected during planning and is not authoritative.

## Selective judge route

`PLAN_DUCK` eligible as advisory under `docs/JUDGE-CONTRACT.md`, given the security-sensitive surface. Any Codex plan/code/verification checkpoints for this work are advisory/shadow only and respect the standard call caps. Deterministic checks — especially the RLS-regression suite — always dominate; no judge result blocks completion on its own, and no judge finding should be treated as authoritative without independent verification.

## Required approvals

This plan requires explicit user approval before any engineering (T1/T2/T3, migrations, or Edge Function work) begins. Approval of this document does not authorize deploy, push to `origin/main`, or a pull request; those require a separate explicit final go-ahead after Verifier and Browser Validator both pass (see "Operating notes").

## Engineering mode

Standard.

## Downstream owner

Scribe persists this plan now. After explicit user approval of this written plan, ownership passes to the engineering fleet (unnamed dispatch) per `docs/BUILD-CONTRACT.md` and `docs/JUDGE-CONTRACT.md`. Team authorization: not applicable to this increment.
