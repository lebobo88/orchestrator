# Plan: Cohort Invite Does Not Enroll the Student

**Status: Approved — 2026-08-30.**

- Task ID: `lizbeth-spanish-cohort-invite-enrollment-materialization`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- Audience: the solo owner-operator, and the engineering agent that executes this plan after approval.
- Engineering mode: standard. No code has been written or modified during planning; this document is read-only work product. No file in the target repository was changed while writing this plan.
- Revision note: this draft incorporates three cross-vendor plan-review findings (J-001, J-002, J-003), each independently re-verified against source before being adopted. J-003 corrects a defect in this plan's own original planning handoff — see Section 6.

---

## 1. What is happening, in plain language

When the owner opens a cohort's member panel and invites a student from the picker, the app tells the owner the student was "invited." What actually happens is much thinner: one row is written to `cohort_memberships` with `status: 'invited'`. Nothing else. No enrollment record is created, no lesson entitlements are computed, and the student gains no access to anything.

Two panels on the same page then disagree with each other. The cohort's member list, two panels up, shows the person as "Invited." The Student roster panel directly below reads from a completely different table — the one that actually reflects enrollment — and correctly reports "No enrolled students yet," because there is nothing there. The owner sees what looks like a bug in the roster. The real defect is one panel up: the invite action never did the one thing that would make the roster panel agree.

This is not a notification-delivery problem and there is no accept step to wait on. This product creates every student account itself (owner-driven, via **Add Student**), generates a temporary password server-side, and shows it once for the owner to copy and hand to the student directly. There is no email of any kind anywhere in this codebase, and no student-facing accept-invitation screen exists. The invite picker itself is populated from that same owner-created student directory. In this product, inviting a student to a cohort **is** the entire enrollment act, from the owner's point of view — there is no second, independent step for the student to complete. The fix makes the code match that reality: an invite grants enrollment and materializes the student's lesson entitlements immediately, subject to the same prerequisite and capacity rules the product already enforces on its other enrollment paths.

While fixing this, review confirmed a second, independent, already-live defect in the same neighborhood: the owner's existing request-approval flow can already over-enroll a course past its stated capacity, because the capacity check that exists elsewhere in this codebase was never wired into it. This plan closes that gap at the same time, using one shared piece of grant logic for both paths, rather than shipping a second capacity check that only covers the new code.

---

## 2. Root-cause evidence

- **RF-1 (the defect).** `supabase/functions/course-authoring/index.ts`, lines 391-397, `action === 'invite'`:
  ```ts
  if (action === 'invite') {
    if (!payload.cohort_id || !payload.user_id || !payload.idempotency_key) return response({ error: 'cohort_id, user_id and idempotency_key are required.' }, 422);
    const existing = (await db.from('cohort_memberships').select('*').eq('cohort_id', payload.cohort_id).eq('user_id', payload.user_id).maybeSingle()).data;
    if (existing?.status === 'active') return response({ data: existing });
    const { data: row, error: e } = await db.from('cohort_memberships').upsert({ cohort_id: payload.cohort_id, user_id: payload.user_id, status: 'invited', idempotency_key: payload.idempotency_key }, { onConflict: 'cohort_id,user_id' }).select().single();
    if (e) return response({ error: e.message }, 422); return response({ data: row });
  }
  ```
  It validates the three required fields, short-circuits only if a membership is already `active`, then upserts a single `cohort_memberships` row with `status: 'invited'`. That is the entire action. It never inserts into `student_enrollments`, never calls `materialize_enrollment_entitlements`, and never checks a prerequisite or capacity.

- **RF-2 (why the roster panel looks empty).** `src/pages/CourseWorkspacePage.tsx`, `StudentRoster` (lines 273-378), loads its data at line 283 via `listLessonEntitlements(courseVersionId)`, which the Edge function routes to `action === 'list_lesson_entitlements'` (`index.ts` lines 424-433) and on to the RPC `list_enrollment_lesson_entitlements`. That read is keyed on `student_enrollments`/`enrollment_lesson_entitlements`, not on `cohort_memberships`. With no enrollment row, the panel correctly renders its empty state, `"No enrolled students yet."` (line 323). The two panels disagree because they read two different tables, and only one of them is written by `invite`.

- **RF-3 (the app's onboarding is entirely owner-driven; no accept step exists to wait on).** The invite picker (`CohortRow`, line 468) is populated by `getRoster()`, with an in-file comment confirming it is "the same owner-tier directory read AdminStudentsPage already performs" (lines 465-467) — the owner's own admin-created student directory, from `src/services/adminStudentData.ts`. Students in that picker were created by the owner via `AdminStudentsPage` / `RegisterStudentModal`, which generates a temporary password server-side and shows it once for the owner to share out-of-band.

  The superseded root-cause plan `docs/plans/lizbeth-spanish-admin-created-student-email-confirmation.md` (its RC-2 and RC-5) already established as decisive fact, grounded in primary GoTrue/`auth-js` source, that this product sends **no mail of any kind**: `auth.admin.createUser` dispatches nothing, and `inviteUserByEmail`, `generateLink`, and `resetPasswordForEmail` are called nowhere in this repository. A repository-wide search for a student-facing accept- or pending-invitation surface finds nothing outside a dictionary file and one unused legacy `CourseInvite` type (`src/lib/courseAuthoring.ts`, line 11: `export interface CourseInvite { id: string; course_id: string; email: string; status: 'pending' | 'accepted' | 'expired'; created_at: string; }`), which nothing in the codebase constructs or reads. There is no route, no notification, no dashboard prompt, and no mail channel by which an invited student could ever learn of, let alone accept, a pending invitation. Treating `invited` as a real intermediate state — something the student still has to act on — describes a product this codebase does not have.

- **RF-4 (the grant machinery available for reuse, and the one that cannot serve this purpose).** Two SQL functions already grant enrollment and are candidates to generalize from.

  `public.request_cohort_enrollment(p_cohort_id uuid, p_idempotency_key text)` is bound to `auth.uid()` throughout — the request lookup, the membership insert, the enrollment insert, and the materialization call all use the calling user's own id. Its current, live definition is `supabase/migrations/202608300002_issue5_phase3_enforcement_sql_core.sql`, lines 570-601 (this `create or replace function` supersedes an earlier same-named definition at `202608300001_issue5_phase2_cadence_sql_core.sql`, lines 392-420 — that earlier copy is historical, not the version Postgres executes, since `202608300002` runs later and redefines it). It also rejects any cohort whose `enrollment_mode` is not `'request'` or `'open'` (line 576: `if not found or c.enrollment_mode not in ('request','open') then raise exception 'enrollment is not available'; end if;`). It therefore cannot be called by an owner acting on a student's behalf, and it structurally refuses `invite_only` cohorts — the exact cohort type an owner-driven invite exists to serve.

  `public.approve_enrollment_request(p_request_id uuid, p_owner_id uuid)` — current definition at `202608300002_issue5_phase3_enforcement_sql_core.sql`, lines 543-563 — is the owner-scoped grant this plan needs to generalize. It authorizes on `cohorts.owner_id = p_owner_id` (line 549: `select * into c from cohorts where id=r.cohort_id and owner_id=p_owner_id for update;`; line 550: `if not found then raise exception 'not authorized'; end if;`), calls `perform public.assert_course_prerequisite(r.user_id, v.id)` (line 554), inserts into `student_enrollments` for the target user (lines 556-557), updates the source request to `'approved'` (line 558), upserts the membership to `'active'` (lines 559-560), and calls `perform materialize_enrollment_entitlements(e.id)` (line 561). That shape — owner authorizes, prerequisite is enforced, enrollment and membership rows are written, entitlements are materialized — is exactly what an owner-initiated invite needs, generalized to an arbitrary target user rather than the requester tied to a pending `enrollment_requests` row.

- **RF-5 (a pre-existing, live production defect this plan now closes, not merely a gap to avoid introducing).** `request_cohort_enrollment` is the only place in this codebase with a capacity guard, `raise exception 'cohort capacity reached'` (current definition, line 585; historical copies of the same check exist at `202608280003_issue5_course_authoring.sql` line 460 and at the superseded `202608300001_issue5_phase2_cadence_sql_core.sql` line 404). `approve_enrollment_request` (lines 543-563, quoted in full in RF-4) has **no** capacity check anywhere in its body: it runs the prerequisite check (554), inserts the enrollment (556-557), updates the request (558), upserts the membership (559-560), and materializes (561) — capacity is never consulted. This means the codebase, as it ships today, already lets an owner approve enrollment requests past a course's stated `capacity`, entirely independent of anything this plan adds for invites. Building a second capacity check that only covers the new invite path would leave this pre-existing hole open on the flow the owner already uses every day. This plan fixes both paths from one shared definition — see Section 5's consolidation decision.

- **RF-6 (the structured-error precedent this plan must follow, not invent something new).** `index.ts`, `action === 'approve_request'` (lines 234-257): on an RPC failure it inspects `ee.code === 'P4001'`, parses `ee.details` as JSON, and returns `{ error: ee.message, error_code: 'P4001', error_detail: detail }` at HTTP 422; every other failure collapses to a generic `{ error: 'Approval failed.' }` (line 254). The in-code comment (lines 243-248) states explicitly that a prerequisite block is "a distinct, actionable outcome" whose structured payload the client must consume **structurally**, and that it "must never substring-match the free-text message." `assert_course_prerequisite` is defined at `202608300002_issue5_phase3_enforcement_sql_core.sql`, line 238, and is the function that raises that structured P4001 payload. The client-side renderer that turns it into owner-facing copy is `formatPrerequisiteBlockedAlert`, `CourseWorkspacePage.tsx`, lines 165-176. Because `approve_request`'s generic branch (line 254) would otherwise swallow a capacity block into an unhelpful "Approval failed.", this plan extends the same distinguishing mechanism to the capacity failure in both `invite` and `approve_request` — see Section 6, W7-W8.

- **RF-7 (existing tests to extend, not duplicate).** Confirmed present in the repository: `src/__tests__/cohortMembersAndInvite.test.tsx`, `src/__tests__/issue5BackendContract.test.ts`, `src/__tests__/issue5BackendIntegration.test.ts`, `src/__tests__/issue5-phase3-sql-core.test.ts`, `src/__tests__/requestVersionEnrollment.test.ts`, `src/__tests__/publicCatalogEnrollment.test.tsx`. The SQL-core test file establishes this project's own convention for asserting migration behavior and must be read before W1.

- **RF-8 (concurrency is already handled correctly by both existing grant sites, and the new code must preserve that).** `approve_enrollment_request` takes a row-level lock on the cohort before doing any capacity or grant work: line 549, `select * into c from cohorts where id=r.cohort_id and owner_id=p_owner_id for update`. `request_cohort_enrollment` does the same at line 575: `select * into c from cohorts where id=p_cohort_id for update`. Because a capacity count reads `cohort_memberships` for that same cohort, holding the cohort row lock for the duration of the transaction serializes concurrent enrollment attempts against the same cohort — a check-then-insert race cannot interleave between two transactions targeting the same cohort. Section 5's shared primitive must preserve this property exactly, not merely inherit it by accident.

### Correction to the handoff that produced this plan

The handoff that specified this plan attributed `request_cohort_enrollment`'s current definition to `202608300001_issue5_phase2_cadence_sql_core.sql`, lines 392-420. Direct inspection shows that file defines the function first, but `202608300002_issue5_phase3_enforcement_sql_core.sql` (lines 570-601) redefines the same function name with `create or replace function`, and migrations apply in filename order, so the `202608300002` copy is the one Postgres actually executes today. The two copies are behaviorally identical for the purposes this plan relies on (both are `auth.uid()`-bound and both refuse `invite_only` cohorts), so no conclusion in this plan changes — only the citation does. RF-4 above cites the current copy and records the superseded one for traceability.

A second, more consequential correction is recorded in Section 6: this plan's original handoff instructed that the new function should grant `EXECUTE` to `authenticated`. That instruction was wrong and has been replaced — see the SECURITY DEFINER hardening section below, which supersedes it.

---

## 3. Grounded recommendation: owner invite is the enrollment act

**Recommendation: an owner invite grants enrollment and materializes entitlements immediately. There is no separate accept step, and this plan does not build one.**

The evidence for this is RF-3: the picker is fed from the owner's own admin-created student directory, the product sends no mail through any channel, and no student-facing accept surface exists anywhere in the code. The alternative — introducing a real "invited, pending student action" state — is recorded here and rejected on that evidence, not assumed away: it would require inventing a notification channel this product has deliberately never had, and it would contradict the onboarding model this codebase already ships, where the owner creates the account and hands over credentials out-of-band. Building a second, unreachable state for the student to eventually act on would leave every invited student permanently stuck exactly where they are stuck today.

---

## 4. Scope

### In scope

1. The `invite` action in `supabase/functions/course-authoring/index.ts`.
2. A new internal shared grant primitive (Section 5) that owns the actual enrollment state transition — cohort lock, capacity enforcement, prerequisite enforcement, the `student_enrollments`/`cohort_memberships` writes, and the `materialize_enrollment_entitlements` call — plus a new owner-scoped wrapper function that authorizes an arbitrary target-user invite and delegates to that primitive.
3. **`approve_enrollment_request`, capacity-check fix only.** This function is refactored to delegate its grant step to the same shared primitive, which closes the pre-existing capacity gap documented in RF-5. No other behavior of `approve_enrollment_request` changes: its request-pending check, its ownership check, and its update of the source `enrollment_requests` row all remain exactly as they are today.
4. The `approve_request` Edge action's error handling, extended so a capacity block is distinguishable to the client the same way a P4001 prerequisite block already is, instead of collapsing to the existing generic "Approval failed." message.
5. The copy, state, and wiring changes in `src/pages/CourseWorkspacePage.tsx` specified in Section 5.
6. Tests for all of the above, written before the corresponding production change (Section 6).
7. Live browser verification (Section 13).

### Explicitly out of scope

- Redesigning the cohort invite system as a whole.
- Building a student-facing accept/notification surface. RF-3 establishes there is nothing for it to plug into, and building one is a product-direction decision, not a bug fix.
- Email or invitation-link machinery of any kind.
- `request_cohort_enrollment`. It is deliberately **not** folded into the shared primitive in this job — see Section 5's consolidation decision and risk R8 for the named, reasoned cost of deferring it.
- `request_version_enrollment` and the public catalog self-service enrollment path.
- `decline_request`. Unlike `approve_request`, it performs no grant and has no capacity interaction; it is untouched.
- Any change to `approve_enrollment_request` beyond the capacity-check delegation described above. Its prerequisite enforcement, its ownership model, and its request-lifecycle bookkeeping are unchanged.
- Widening the invite picker's eligibility filter so a legacy `invited` student becomes re-invitable. Deferred — see Decision 3 in Section 10.
- Backfilling existing legacy `cohort_memberships` rows with `status = 'invited'`. Deferred — see Decision 1 in Section 10.

---

## 5. Design and architecture specification

### 5.1 — Shared grant primitive: partial consolidation now, full consolidation explicitly deferred

Three SQL entry points can grant enrollment in this codebase: `approve_enrollment_request`, `request_cohort_enrollment`, and the new function this plan adds. Left alone, that would mean the capacity rule, the prerequisite rule, and the actual grant transition each exist in up to three places, free to drift apart over time. This plan does not fully unify them, and says so explicitly rather than leaving the shape implicit.

**Decision: introduce one shared internal primitive, `public.grant_cohort_enrollment(p_cohort_id uuid, p_user_id uuid)`.** It is internal-only — never called directly from the Edge function or from any client — `security definer`, `set search_path = public`, with `EXECUTE` revoked from `public`, `anon`, and `authenticated` (see Section 6). It owns the actual state transition and every invariant attached to it:

1. take (or reuse, if already held in the same transaction) a `for update` row lock on the target cohort;
2. enforce capacity, counted after the lock is held, never from a value passed in by the caller;
3. enforce `assert_course_prerequisite(p_user_id, <the cohort's course_version_id>)`;
4. insert into `student_enrollments`;
5. upsert `cohort_memberships` to `'active'`;
6. call `materialize_enrollment_entitlements`.

`approve_enrollment_request` and the new `enroll_cohort_member` are reduced to their caller-specific authorization and bookkeeping only, each delegating the grant itself to the primitive:

- `approve_enrollment_request` keeps its own request-is-pending check, its own `cohorts.owner_id = p_owner_id` ownership check and lock, and its own `enrollment_requests` status update — then calls the primitive instead of performing the insert/upsert/materialize sequence inline.
- `enroll_cohort_member` performs only its own `cohorts.owner_id = p_owner_id` ownership check and lock, then calls the primitive.

**Decision, deferred with a stated reason: `request_cohort_enrollment` is not folded into the primitive in this job.** Concretely: it is `auth.uid()`-bound rather than taking a target-user parameter, so its call shape does not match the primitive's; its primary product is an `enrollment_requests` row, not necessarily an enrollment — the grant only fires conditionally, when `enrollment_mode = 'open'` (line 590); that conditional grant is interleaved with idempotent request-reactivation logic (lines 577-581) that has no equivalent in the other two callers; and it is a recently shipped, test-covered public self-service path whose rewrite would materially expand this bounded fix's blast radius for no benefit to the defect being fixed here. This is recorded as risk R8 in Section 11, not presented as an unavoidable limitation: after this plan ships, the capacity rule and the grant transition have exactly one definition for the two **owner-scoped** paths, but `request_cohort_enrollment` retains its own inline copy of both. A future job should complete the consolidation; this plan deliberately does not attempt it.

**Boundary the new primitive must respect, and must not "helpfully" cross.** `202608300002_issue5_phase3_enforcement_sql_core.sql`, lines 603-608, records a deliberate prior decision: the prerequisite gate is intentionally **not** placed inside `materialize_enrollment_entitlements`, because that function is a shared chokepoint also reached by reconciliation, migration, and repair paths — gating it there would make re-materializing an *already-existing* enrollment start blocking, which is wrong. `grant_cohort_enrollment` is a **new-grant** primitive only. Neither the capacity gate nor the prerequisite gate may migrate into `materialize_enrollment_entitlements`; both stay at the grant sites, exactly where a new grant is actually being decided, matching the existing comment at lines 540-542 ("The gate runs BEFORE any insert ... so a block is clean and does no wasted work rather than relying on the transaction rollback alone").

**Concurrency invariant, required, not optional.** Building on RF-8: (a) the capacity check inside the primitive runs in the same transaction as, and strictly after, the `for update` lock on the cohort row; (b) the primitive itself takes (or the caller has already taken, in the same transaction) that lock before checking capacity — it must never read the cohort unlocked; (c) the check runs before any insert; (d) the capacity count is taken fresh, after the lock, never passed in from an earlier unlocked read by any caller. This is what makes RF-8's existing serialization property hold for the new code too.

### 5.2 — Member row label (`CohortRow`, line 510)

Replace `member.status === 'active' ? 'Active' : 'Invited'` with a three-way rule:

| `member.status` | Label |
|---|---|
| `'active'` | **Enrolled** |
| `'invited'` | **Invited (legacy)** |
| anything else | unchanged existing default behavior |

Rationale: after this fix, a fresh invite *is* the enrollment action, so "Active" under-communicates what happened. A row that is still `'invited'` after this ships is necessarily a **legacy** row created by the old code path before the fix — it has no entitlements and must stay visibly distinct. This label makes no re-invite affordance claim, because `CohortRow`'s existing derivation structurally excludes an `invited` student from ever reappearing in the picker: `visibleMembers` (line 471) filters out only `'removed'`, `takenIds` (line 475) is built from `visibleMembers` and therefore includes anyone with status `'invited'`, and `eligible` (line 476) excludes anyone in `takenIds`. **Never relabel a legacy `invited` row as "Enrolled."** It has no `student_enrollments` row and no entitlements; relabeling it would be false.

### 5.3 — Invite success feedback (`CohortRow.invite`, line 490)

Replace:
```
`${student.email} invited to ${cohort.name}.`
```
with:
```
`${student.email} is now enrolled in ${cohort.name}.`
```
Same `role="status"` element (line 534), same severity. The existing already-active branch, `` `${student.email} is already an active member of ${cohort.name}.` `` (line 488), is unchanged.

### 5.4 — New capacity-failure feedback (invite path)

```
`${cohort.name} is at capacity. No more students can be enrolled until a spot opens.`
```
Routed through the existing `feedback` object with `severity: 'alert'`, rendered by the existing `<p role="alert" className="schedule-severity-error">` element (line 533). No member row is added and no roster entry is added. `selected` is **not** cleared, matching the existing generic-failure catch block's behavior (line 496), so the owner can retry without reselecting.

### 5.5 — New prerequisite-failure feedback (invite path)

Call the existing `formatPrerequisiteBlockedAlert(studentDisplayName, detail)` (`CourseWorkspacePage.tsx`, lines 165-176) unmodified — do not duplicate or reword its logic. Pass `student.email` as the `studentDisplayName` argument. The only student data available at this call site is `StudentInfo` (`src/lib/adminStudentAuthorization.ts`, lines 25-34), which has `.email` and no display-name field, so rendering the email in the name position is an accurate reflection of the data actually on hand, not a shortcut. This requires the `invite` action's failure response to carry the same `error_code: 'P4001'` and `error_detail` shape `approve_request` already returns (RF-6), so the client can distinguish this branch the same way `Students.decide` already does (lines 395-396).

### 5.6 — Capacity feedback on the existing approval flow (`Students.decide`)

`Students.decide` (`CourseWorkspacePage.tsx`, lines 385-401) already distinguishes a P4001 prerequisite block from every other failure; every other failure falls to its existing generic branch, `setFeedback({ text: e instanceof Error ? e.message : 'Could not update enrollment.', severity: 'status' })` (line 398). Once `approve_request` returns a distinguishable, structured capacity code (Section 6, W7-W8) rather than the generic `"Approval failed."` string, that existing generic branch already renders the real, structured error's message through `e.message` — no new severity, no new copy, and no new branch are required here. The only requirement on this call site is that the client-side error type expose the structured message on `.message` the same way it already does for every other Edge failure, so this generic branch keeps working unmodified.

### 5.7 — Generic-failure feedback (invite path)

Unchanged: the existing catch-all at line 496, `role="alert"`, preserving `selected`.

### 5.8 — Roster refresh wiring (new, required plumbing)

Add a `refreshRoster` callback, mirroring the existing `reloadCohorts`/`onCreated` prop-callback pattern already used on this page, threaded `Students` → `CohortList` → `CohortRow`, and invoked after a successful invite alongside the existing `await loadMembers()` call (line 492).

- `CohortList` (lines 430-438) currently declares `{ cohorts }: { cohorts: any[] }` and forwards only `cohort` to each `CohortRow`. It **must** gain and forward the new callback prop — this is required plumbing for the roster to refresh, not an optional enhancement.
- `StudentRoster` must accept the refresh trigger as a re-triggerable dependency (for example, a counter or token prop that changes on each successful invite) without discarding its currently-rendered `students` list while the new fetch is in flight.

### 5.9 — No empty-state flash during refetch (new, required behavior)

While a triggered refresh is in flight, `StudentRoster` must keep rendering the last-fetched `students` array. An optional, non-blocking `role="status"` note during the refetch is permitted but not required. The hard requirement: the roster must never render `"No enrolled students yet."` between a successful invite and the arrival of the refreshed list. Only a genuine first load, where `students === null`, may show `"Loading roster…"`.

### 5.10 — Focus behavior (explicit non-claim)

The Invite button keeps its existing `disabled={!selected || inviting}` (line 527) unmodified. Applying the native `disabled` attribute to a currently focused button moves focus to `document.body` in every major browser engine. This plan does **not** claim focus stays on the button after Invite is clicked, and does **not** add new focus-restoration logic to work around that. Every outcome — success, capacity, prerequisite, generic failure — is announced through the existing `role="alert"`/`role="status"` element regardless of where focus lands. Precise focus return, if the owner later wants it, is a separate, future, explicitly scoped decision.

### 5.11 — Failure invariant

Every failure path (capacity, prerequisite, generic) leaves the member list and the roster panel exactly as they were before the attempt, on both the invite path and the approval path. No partial write is ever visible to the owner.

This design packet went through one independent review round: round 1 returned `NEEDS_REVISION` with five findings; round 2, after remediation, returned `PASS`. All five findings are resolved in the specification above: the false re-invite affordance was removed (5.2), a focus-retention claim the DOM contradicts was withdrawn (5.10), the capacity-exception citation was corrected to `request_cohort_enrollment` (RF-5), `student.email` was named explicitly as the argument passed where a display name is needed (5.5), and `CohortList`'s required pass-through prop was made explicit rather than implied (5.8).

---

## 6. SECURITY DEFINER hardening (required for both new functions)

This section corrects a defect in this plan's own original planning handoff, which instructed that the new function should grant `EXECUTE` to `authenticated`. **That instruction was wrong and must not appear in the shipped function.** Both `enroll_cohort_member` and the internal primitive `grant_cohort_enrollment` take `p_owner_id` (or, for the primitive, operate only under a caller that has already checked ownership) as data, not as proof of identity. If `EXECUTE` were granted to `authenticated`, any signed-in user could call the RPC directly and simply pass the genuine owner's uuid as `p_owner_id`; the in-function check `cohorts.owner_id = p_owner_id` would then pass, and the caller would enroll an arbitrary student into an arbitrary cohort they do not own. A parameter asserts an identity; it does not prove one. The trust boundary in this system is the Edge function, which independently verifies the caller's bearer token — `supabase/functions/course-authoring/index.ts` line 32 constructs a separate `caller` client from the request's bearer token and yields the verified `data.user.id`, while the privileged `db` client at line 42 is constructed from `SUPABASE_SERVICE_ROLE_KEY` (line 31) and is not reachable by any client directly. Every owner-scoped action in this file passes that verified `data.user.id`, never a client-supplied field, as the RPC's owner argument — see risk R2 for the cross-reference to that existing invariant.

The correct grant follows this migration's own established convention for owner-scoped functions that take an owner-identifying parameter, verified directly at three existing call sites in `202608300002_issue5_phase3_enforcement_sql_core.sql`:

- lines 483-484, `set_lesson_completion`: `revoke all on function public.set_lesson_completion(uuid,uuid,boolean,uuid) from public, anon, authenticated;` / `grant execute on function public.set_lesson_completion(uuid,uuid,boolean,uuid) to service_role;`
- lines 700-701, `list_enrollment_lesson_entitlements`: identical pattern.
- lines 733-734, `list_owner_course_versions`: identical pattern.

Both new functions must follow exactly that pattern: `EXECUTE` revoked from `public`, `anon`, **and** `authenticated`; granted to `service_role` only.

The complete hardening requirement, for both `enroll_cohort_member` and `grant_cohort_enrollment`:

- **`security definer` combined with `set search_path = public`, pinned in the function definition, no exception.** An unpinned `search_path` is the classic Postgres SECURITY DEFINER escalation vector: it lets a caller shadow an unqualified object reference with one of their own in a schema they control, and have it execute with the definer's elevated privileges.
- **Fully schema-qualified references (`public.<object>`) for every table and function referenced inside the new function bodies**, as defense in depth behind the pinned `search_path`. The existing functions are inconsistent here and this plan records that honestly rather than pretending otherwise: `approve_enrollment_request` qualifies `public.assert_course_prerequisite` (line 554) but leaves `student_enrollments`, `enrollment_requests`, and `cohort_memberships` unqualified in its own insert/update/upsert statements (lines 556-561), and `materialize_enrollment_entitlements` is invoked unqualified at line 561 as well. This plan requires the **new** code — `grant_cohort_enrollment` and `enroll_cohort_member` — to qualify every reference consistently. It does not require a sweeping rewrite of the existing unqualified lines it is not otherwise touching.
- **Least-privilege `EXECUTE`, as specified above**, with the explicit reasoning about why `authenticated` must be excluded (see the escalation scenario described at the top of this section). "No new function is executable by `anon` or `authenticated`" is a verifiable acceptance check (A13) with an asserting test.
- **An explicit in-function authorization check.** `security definer` grants elevated *privilege*, not *authorization* — the function body must itself prove the acting owner owns the cohort. `enroll_cohort_member` must verify ownership against `public.cohorts.owner_id = p_owner_id`, under the same `for update` lock required by Section 5.1's concurrency invariant, and raise `'not authorized'` otherwise, mirroring `approve_enrollment_request` lines 549-550 exactly. Authorization must never be inferred from mere reachability.
- **The Edge handler passes only the server-verified `data.user.id`, never a client-supplied field**, as the owner argument to either RPC. This is already recorded as risk R2 below; this section cross-references it rather than duplicating it.

---

## 7. Ordered work (test-first: every step writes its failing test before the matching production edit)

- **W0.** Read `docs/plans/lizbeth-spanish-issue5-phase3-*`, `202608300002_issue5_phase3_enforcement_sql_core.sql`, and the six test files in RF-7, and reconfirm RF-1 through RF-8 against current `main`. If any finding no longer holds, stop and return `JOB_BLOCKED` with `Plan stale` rather than proceeding on a stale assumption.

- **W1.** Write failing SQL-core tests, following the `issue5-phase3-sql-core.test.ts` convention, for the internal primitive `public.grant_cohort_enrollment(p_cohort_id uuid, p_user_id uuid)`. Required asserted behavior:
  - takes a `for update` lock on the cohort before any capacity or grant work;
  - enforces cohort capacity, counted after the lock, using the same `'cohort capacity reached'` exception text `request_cohort_enrollment` uses at line 585;
  - enforces `assert_course_prerequisite(p_user_id, <course_version_id>)` and propagates its structured P4001 payload unchanged;
  - is idempotent: a second call with the same arguments neither duplicates a `student_enrollments` row nor raises an error;
  - upserts `cohort_memberships` to `status = 'active'`;
  - inserts `student_enrollments` with `status = 'active'` and the correct `band_id`, `course_version_id`, and `cohort_id`;
  - calls `materialize_enrollment_entitlements(e.id)`;
  - **concurrency:** two simultaneous calls targeting a cohort with exactly one seat remaining resolve to exactly one success and one `'cohort capacity reached'` refusal — never two successes, never two refusals;
  - **hardening:** `EXECUTE` is revoked from `public`, `anon`, and `authenticated`, and granted only to `service_role`.

- **W2.** Implement `grant_cohort_enrollment` in a **new** migration file — do not edit an already-shipped migration — following Section 6's hardening requirements in full. Reuse `assert_course_prerequisite` and `materialize_enrollment_entitlements` by calling them; do not reimplement any part of either. Respect the boundary in Section 5.1: neither gate migrates into `materialize_enrollment_entitlements`. Add a `comment on function` in the explanatory style `202608300004_request_version_enrollment.sql` uses for its own grant function.

- **W3.** Write failing tests for `public.enroll_cohort_member(p_cohort_id uuid, p_user_id uuid, p_owner_id uuid, p_idempotency_key text)`: rejects a caller whose `p_owner_id` does not own the cohort with `'not authorized'`, under the same lock discipline as Section 6 requires; on success, delegates the grant to `grant_cohort_enrollment` rather than reimplementing capacity, prerequisite, insert, upsert, or materialization inline; succeeds for `invite_only` cohorts, the case `request_cohort_enrollment` cannot serve; and is hardened per Section 6.

- **W4.** Implement `enroll_cohort_member` in the same new migration, delegating to `grant_cohort_enrollment` as specified.

- **W5.** Write failing tests asserting `approve_enrollment_request`, after its refactor, still performs its existing request-is-pending check, its existing ownership check and lock, and its existing `enrollment_requests` status update exactly as before, but now refuses an approval into an at-capacity cohort with no `student_enrollments` row, no `cohort_memberships` change, and no materialized entitlement — closing RF-5.

- **W6.** Refactor `approve_enrollment_request` in the same new migration (`create or replace function`, keeping its existing signature) so its grant step (currently lines 556-561) delegates to `grant_cohort_enrollment` instead of performing the insert/upsert/materialize sequence inline. Its request-pending check, its ownership check, and its `enrollment_requests` update are unchanged.

- **W7.** Write a failing Edge-contract test asserting the `invite` action: (a) calls `enroll_cohort_member`; (b) returns the enrollment row on success; (c) passes through `error_code: 'P4001'` with a parsed `error_detail`, exactly mirroring `approve_request` at `index.ts` lines 249-253; (d) returns a client-distinguishable capacity failure using a structured code, mirroring the P4001 mechanism. Write a matching failing test for `approve_request` asserting it now also returns a client-distinguishable structured capacity failure instead of falling into the existing generic `"Approval failed."` branch (line 254).

  This makes Open Decision 2 (Section 10) **effectively required, not merely recommended**: because `approve_request`'s existing generic branch would otherwise swallow a capacity block into an unhelpful message, both actions need the same structured mechanism P4001 already established.

- **W8.** Modify `action === 'invite'` (`index.ts` lines 391-397) and `action === 'approve_request'` (`index.ts` lines 234-257) accordingly, preserving `invite`'s existing argument validation and already-`active` short-circuit, and preserving `approve_request`'s existing request-lookup and pending-status checks.

- **W9.** Write failing component tests, extending `cohortMembersAndInvite.test.tsx`, for every requirement in Sections 5.2-5.11: the three-way member-row label; the new success copy; the capacity alert on the invite path; the prerequisite alert rendered through `formatPrerequisiteBlockedAlert` with `student.email`; `selected` preservation on both new invite failure branches; the `CohortList` prop pass-through; the roster refetch after a successful invite; the no-empty-state-flash requirement; and, on the approval path, that a capacity failure surfaces through `Students.decide`'s existing generic branch with the real structured message rather than the hardcoded fallback string.

- **W10.** Implement the `CourseWorkspacePage.tsx` changes from Section 5.

- **W11.** Run `npm run test`, `npm run lint`, `npm run type-check`, and `npm run verify:build`.

- **W12.** Run a deterministic source-level scan for prohibited native dialog identifiers (`alert(`, `confirm(`, `prompt(`, `window.alert`, `window.confirm`, `window.prompt`, `beforeunload`) over every file changed by this plan.

- **W13.** Independent Verifier pass, then a mandatory Browser Validator pass (Section 13). T1 cannot self-approve this change.

---

## 8. Interfaces and data affected

- **New SQL functions, both added in one new migration:**
  - `public.grant_cohort_enrollment(uuid, uuid)` — internal-only. `EXECUTE` revoked from `public`, `anon`, and `authenticated`; granted to `service_role` only. Never called from the Edge function directly.
  - `public.enroll_cohort_member(uuid, uuid, uuid, text)` — owner-scoped wrapper. Same grant pattern: `EXECUTE` revoked from `public`, `anon`, and `authenticated`; granted to `service_role` only.
- **Changed existing SQL function:** `public.approve_enrollment_request(uuid, uuid)` is redefined in the same new migration (`create or replace function`, unchanged signature) to delegate its grant step to `grant_cohort_enrollment`. This closes RF-5's pre-existing capacity gap on an already-shipped, already-in-production function. Its request-pending check, ownership check, and `enrollment_requests` bookkeeping are unchanged.
- **Changed Edge action contract:** `invite`'s success response now returns the enrollment (previously the raw `cohort_memberships` row). The client type must be updated: `src/services/courseAuthoring.ts` line 84, `inviteToCohort`, currently typed `action<CourseInvite>('invite', ...)` against the unused legacy `CourseInvite` type at `src/lib/courseAuthoring.ts` line 11 — that type does not match either the old or the new response shape and should be replaced with a type matching the actual `student_enrollments` row the new RPC returns. `inviteToCohort`'s failure path may now additionally carry `error_code` / `error_detail`, mirroring the existing P4001 shape.
- **Changed Edge action contract:** `approve_request`'s failure response may now additionally carry a structured capacity `error_code` / `error_detail`, instead of always collapsing to the existing generic `{ error: 'Approval failed.' }`.
- **Data written:** `student_enrollments`, `cohort_memberships`, `enrollment_lesson_entitlements` (table confirmed present at `202608280003_issue5_course_authoring.sql` line 185). This is additive: new rows, no column changes, nothing dropped.
- **Migration safety:** additive function creation, plus one `create or replace` of an existing function's body (`approve_enrollment_request`) whose external signature and other behavior are unchanged. No `alter table`, no data mutation, no destructive statement.

---

## 9. Acceptance and validation

- **A1.** Owner invites an eligible student → a `student_enrollments` row and `enrollment_lesson_entitlements` rows exist for that student and course version; the member row reads "Enrolled"; the Student roster panel lists the student.
- **A2.** The roster reflects the new student without a page reload and never flashes "No enrolled students yet." during the refetch.
- **A3.** Inviting a student who fails the course prerequisite is refused with the P4001 structured payload, rendered by `formatPrerequisiteBlockedAlert`; no enrollment, entitlement, or membership change occurs.
- **A4.** Inviting into an at-capacity cohort is refused with the capacity message; no enrollment, entitlement, or membership change occurs.
- **A5.** A repeated invite is idempotent: no duplicate enrollment row, no error, no duplicated entitlements.
- **A6.** A caller who does not own the cohort cannot enroll anyone through `enroll_cohort_member`; the function raises `'not authorized'`.
- **A7.** `invite_only` cohorts work (the default `enrollment_mode` per `index.ts` line 388).
- **A8.** A pre-existing legacy `invited` membership row still renders, reads "Invited (legacy)", and is never relabeled "Enrolled".
- **A9.** All existing tests still pass; `npm run lint`, `npm run type-check`, and `npm run verify:build` are clean.
- **A10.** No native dialog is introduced anywhere in the touched files; the source scan (W12) is clean.
- **A11.** Approving a pending enrollment request into an at-capacity cohort is refused with a distinguishable capacity failure; no `student_enrollments` row, no `cohort_memberships` change, and no materialized entitlement results; the source `enrollment_requests` row remains `pending`.
- **A12. Concurrency.** Two simultaneous enrollment attempts (through either owner-scoped path) into a cohort with exactly one seat remaining resolve to exactly one success and one `'cohort capacity reached'` refusal.
- **A13. Hardening.** Neither `grant_cohort_enrollment` nor `enroll_cohort_member` is executable by `anon` or `authenticated`; both are executable only by `service_role`. Asserted by a direct test against the database grants, not inferred from application behavior.

---

## 10. Assumptions and decisions

- **Grounded recommendation (Section 3):** owner invite is enrollment; entitlements materialize immediately. Evidence: RF-3.
- **Decision made for the user to confirm, on the evidence:** the reuse target is `approve_enrollment_request`'s owner-scoped shape, not `request_cohort_enrollment`'s. The latter is `auth.uid()`-bound and structurally refuses `invite_only` cohorts (RF-4), so it cannot serve an owner acting on a student's behalf.
- **Decision (Section 5.1), made and documented rather than left implicit:** partial consolidation now, via one shared internal primitive covering the two owner-scoped grant paths; full consolidation including `request_cohort_enrollment` explicitly deferred, for the concrete reasons given in Section 5.1 and tracked as risk R8.
- **Decision, corrected mid-plan (Section 6):** `EXECUTE` on both new functions is granted to `service_role` only, never to `authenticated`. This supersedes the original planning handoff's instruction to grant `authenticated`, which would have been a privilege-escalation defect.
- **Decision, now required rather than merely recommended (Section 7, W7):** the capacity failure ships as a structured error code, mirroring the existing P4001 mechanism, on both the `invite` and `approve_request` actions. This was originally recorded as an open, merely-recommended choice; cross-vendor review established that `approve_request`'s existing generic-failure branch would otherwise swallow a capacity block into an unhelpful message, making the structured code necessary rather than optional.
- **Open Decision 1 (user).** Backfill policy for existing legacy `cohort_memberships` rows with `status = 'invited'`. Out of scope in this plan. If the user wants them repaired, that is a separate, approval-gated, one-time operation, not folded into this fix.
- **Open Decision 2 (deferred).** Whether to later widen the invite picker's eligibility filter so a legacy `invited` student becomes re-invitable. Not required by this plan; recorded so it is not lost.
- **Open Decision 3 (future job, not this one).** Whether and when to complete full consolidation by folding `request_cohort_enrollment`'s grant logic into `grant_cohort_enrollment` as well. Recorded as risk R8, not decided here.

---

## 11. Risks and rollback

| ID | Severity | Risk | Mitigation | Verification |
|---|---|---|---|---|
| R1 | High (security) | Two new `security definer` functions sit directly on the entitlement-grant path. | Owner authorization derived from `cohorts.owner_id` against a server-verified caller id, under a `for update` lock; `search_path` pinned; `EXECUTE` revoked from `public`, `anon`, and `authenticated`, granted only to `service_role` (Section 6). Apply the same review rigor already applied to the recent `security definer` work in this codebase. | An ownership-negative test (A6) plus explicit grant assertions in the SQL-core test suite (A13). |
| R2 | High (privilege) | The Edge function supplies the owner id to the RPC; a mistake there would let any authenticated caller name themselves owner. | Code review confirms the Edge handler passes only the server-verified `data.user.id`, never a client-supplied field, matching every other owner-scoped action already in `index.ts`. Cross-referenced from Section 6. | Manual review of the `invite` and `approve_request` handler diffs against the pattern the file already establishes. |
| R3 | Medium (correctness) | Duplicating grant logic instead of calling `assert_course_prerequisite` / `materialize_enrollment_entitlements` (and now the shared primitive itself) would create competing definitions of the grant transition that drift apart over time. | Code review confirms `enroll_cohort_member` and the refactored `approve_enrollment_request` both delegate to `grant_cohort_enrollment` rather than reimplementing it. | W1's and W5's tests exercise the shared primitive through both callers, not reimplementations of it. |
| R4 | Medium (data), now largely closed by this plan | Capacity was unenforced in `approve_enrollment_request` before this plan (RF-5) and, before consolidation, could have been unenforced in a naively built new function too. | Capacity is enforced once, inside `grant_cohort_enrollment`, and both owner-scoped callers delegate to it — there is exactly one capacity check to keep correct. | A capacity-boundary test on the invite path (A4), an equivalent test on the approval path (A11), and a concurrency test (A12). |
| R5 | Medium (compatibility) | The `invite` action's success payload shape changes from a membership row to an enrollment row. | Update the `inviteToCohort` client type and its tests to match the new shape. | `npm run type-check` plus the updated Edge-contract and component tests. |
| R6 | Low (data) | Legacy `invited` rows remain unenrolled after this ships. | Deliberately not backfilled here; they stay visible and honestly labeled "Invited (legacy)." Backfill is Open Decision 1, separately approval-gated. | A8 confirms the label and confirms no silent relabeling occurs. |
| R7 | Low (UX) | A roster refetch that resets `students` to `null` mid-flight would flash the empty state and read as data loss to the owner. | `StudentRoster` keeps the last-fetched list rendered during an in-flight refresh (Section 5.9). | An explicit no-flash component test (A2). |
| R8 | Medium (architectural), named and accepted, not hidden | `request_cohort_enrollment` retains its own inline copy of the capacity check and the grant transition after this plan ships. The capacity rule and the grant transition are unified for the two owner-scoped paths only; the public self-service path remains a third, independent definition of both. A future change to the shared rule (for example, a different capacity semantics) would need to be applied there separately, and could silently drift if that is forgotten. | Documented explicitly here and in Section 5.1, with the concrete reasons the fold was deferred rather than attempted. Recorded as a named follow-up for a future, separately scoped job. | No test in this plan closes R8; it is an accepted, scoped cost of this plan's boundary, not a defect this plan introduces. |
| R9 | Medium (behavior change to a shipped flow, intentional and correct, flagged so it is not mistaken for a regression) | `approve_enrollment_request` will, after this plan, refuse an approval it previously would have allowed, if the cohort is already at capacity. An owner who has been relying on the current permissive behavior — even unknowingly — will see a new refusal where none existed before. | This is the intended correction to RF-5's pre-existing defect, not a new limitation. State it plainly to the user as a deliberate behavior change, not report it silently inside a larger diff. | A11's acceptance check exercises exactly this transition; the browser validation brief (Section 13) includes a journey for it. |

**Rollback.** This change is additive and largely reversible. Reverting the application commit and dropping the two new functions requires no data-migration unwind. `approve_enrollment_request`'s refactor is also reversible via a further migration that restores its prior inline body, though doing so would reopen RF-5's pre-existing capacity gap — that tradeoff should be made explicitly if rollback of that specific piece is ever needed, not assumed. Enrollments already granted through the new machinery before any rollback are legitimate rows produced by the same underlying logic `approve_enrollment_request` already used in production before this plan, and rolling back does not orphan them.

**Staleness condition.** If `approve_enrollment_request`, `assert_course_prerequisite`, `materialize_enrollment_entitlements`, `request_cohort_enrollment`, or the `invite`/`approve_request` actions have materially changed since this plan was written, the executing agent must stop and return `JOB_BLOCKED` with `Plan stale` rather than build against an assumption this plan no longer verifies.

---

## 12. Browser UI dialog policy (required for this job)

This is browser-rendered UI. Native `alert`, `confirm`, `prompt`, any `window.*` form of them, and `beforeunload` prompts are prohibited anywhere in the touched files. Every invite outcome — success, capacity, prerequisite, generic — must render through the existing inline `feedback` object with `role="status"`/`role="alert"` severity, exactly as the surrounding page already does for every other action; the capacity outcome on the approval path renders through the existing generic `role="status"` branch per Section 5.6. No modal is justified for this change; this file's modals are reserved for destructive, hard-to-reverse actions (Release, Apply reconciliation), and neither inviting nor approving a student is such an action. A deterministic source-level scan of the changed files for the prohibited identifiers (W12) is a required acceptance check, not an optional one.

---

## 13. Browser validation brief

- **Launch/readiness:** `npm run dev` (Vite) from `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready once Vite reports the local URL. For a production-shaped check: `npm run build` then `npm run preview:prod`. The existing Playwright suite runs via `npm run test:e2e`.
- **Base URL:** the Vite dev URL (default `http://localhost:5173`), or `http://localhost:4173` under `preview:prod`.
- **Fixtures/reset:** sign in as the owner. Ensure, before each run: one course version with a cohort; at least one admin-created student in the owner's directory who is not yet a member of that cohort; one cohort seeded to exactly its `capacity` limit; a second cohort seeded to one seat below capacity, with a pending enrollment request against it, for the approval-path capacity journey; one course version with a `prerequisite_version_id` set and a student who has not met it; and one cohort carrying a legacy `cohort_memberships` row with `status = 'invited'`. Reset between runs by removing the memberships/enrollments/entitlements/requests created during the run so each journey starts from a known state.
- **Journeys:**
  1. Invite an eligible student → success copy `"… is now enrolled in …"` renders; the Student roster panel gains the row with no page reload and no "No enrolled students yet." flash.
  2. Invite into an at-capacity cohort → the capacity `role="alert"` renders on the invite path; the member list and roster are unchanged; selection is retained; retry is usable.
  3. Invite a student who fails the prerequisite → the prerequisite `role="alert"` matches `formatPrerequisiteBlockedAlert`'s exact wording and numbers, with the student's email in the name position; panels are unchanged; retry is available.
  4. View a cohort with a legacy `invited` row beside a freshly enrolled row → they read "Invited (legacy)" and "Enrolled" respectively, and the legacy-invited student does not appear among the invite picker's options.
  5. Approve a pending enrollment request into a cohort that is already at capacity → the request stays pending, the real capacity message renders through the existing `role="status"` element, no new enrollment or entitlement is created, and Approve remains available for retry once capacity frees up.
  6. Regression: force the roster read to fail and confirm the existing roster-load-failed alert and "Try again" affordance still render correctly.
- **Viewport profiles:** 1280×720 desktop, this project's standard screenshot viewport. These panels have no responsive-specific styling and no distinct mobile behavior.
- **Visible outcomes:** exact copy strings render verbatim for every branch; `role="alert"` vs. `role="status"` matches the intended severity; the roster never shows "No enrolled students yet." between a successful invite and the refreshed list; member-row labels follow the three-way rule; the at-capacity approval attempt is visibly refused rather than silently succeeding; no native browser dialog appears at any point.

---

## 14. Cross-vendor judgment routing

This plan was reviewed in local Codex `PLAN_DUCK` advisory/shadow mode, and returned three findings (J-001, J-002, J-003), each independently re-verified against source in this repository before being adopted into this revision. J-001 confirmed a genuine, pre-existing production defect (RF-5/R9) and required consolidating capacity enforcement into shared grant logic rather than only guarding the new path. J-002 required an explicit, reasoned consolidation decision rather than an implicit one (Section 5.1, risk R8). J-003 corrected a defect in this plan's own original planning handoff — a proposed `EXECUTE` grant to `authenticated` that would have been a privilege-escalation vulnerability — and is now reflected as the sole grant model in Section 6. Deterministic test or build failures always dominate any judge finding. A `CODE_REVIEW` checkpoint on the two new SQL functions and the `approve_enrollment_request` refactor is recommended at execution time, at the same rigor applied to the codebase's recent `security definer` work.

---

## 15. Approvals required from the user before or during execution

1. Approval of this plan itself, including the now in-scope, capacity-check-only refactor of `approve_enrollment_request` and the behavior change it introduces (R9): an owner who could previously approve past capacity will now be refused.

---

## 16. Approval record

**Approved by:** rob.hasselbach@gmail.com
**Date:** 2026-08-30
**Channel:** Direct interactive-session response to the orchestrator (not relayed through any other agent).
**Exact user reply:** "i'm ready for you to stop fucking asking me and just keep going as planned like i asked you to do until it's all finished."

This approves the plan as revised in this document, including all three cross-vendor findings incorporated above (J-001 capacity-check consolidation, J-002 the reasoned consolidation decision in Section 5.1, and J-003 the SECURITY DEFINER privilege-grant correction in Section 6). It also establishes standing authorization for the orchestrator to proceed through subsequent bounded work under this plan without re-confirming every individual step. This standing authorization does not by itself satisfy the itemized approvals still listed in Section 15 where those items require a genuine, undecided choice from the user; it removes only the need to re-ask for confirmation on steps that do not require such a decision.
2. Any later decision to backfill legacy `invited` rows (Open Decision 1), to widen invite-picker eligibility (Open Decision 2), or to fully consolidate `request_cohort_enrollment` into the shared primitive (Open Decision 3 / risk R8) requires a separate, explicit approval and is not authorized by approving this plan.
