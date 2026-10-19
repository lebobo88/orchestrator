# Sub-plan: Lizbeth Spanish #187, owner-selectable default site language

- Plan id: `lizbeth-spanish-187-owner-default-language`
- Task id: `lizbeth-wave6-187-default-language`
- Status: **APPROVED 2026-10-15 (Revision 1).** User words, verbatim, 2026-10-15: "Approve all four plans as recommended". Decisions D-L2 to D-L11 are adopted at their recommendations; D-L1 was already approved as parent D-19. Each hosted step (H0 to H4) still needs its own separate explicit approval (parent decision D-28). Lizbeth must approve any drafted Spanish before it ships. Written 2026-10-15.
- Parent: approved plan `docs/plans/lizbeth-spanish-open-issues-deep-dive-2026-10.md`. Relevant parent locations: section 4.2 "#187" at `:397-401`; Wave 6 at `:776-778`; section 9.1 at `:791` ("re-plan and approval at wave start"); section 10 at `:806` ("#187 may add a migration"); section 14 D-19 at `:953`, approved recommendation "owner_settings column plus anon view, in a sub-plan". The parent prerequisite "after PRs #229 and #232 merge" is satisfied (parent status note: merged to `main` at `37f851e`).
- Route: engineering. Engineering mode: standard (T1 first-line, T2 escalation per fleet rules). No extreme-advisory team; team authorization not applicable. Downstream owner: engineering fleet.
- Target: `lebobo88/lizbeth-spanish` (private), `main` at `f8a95a3` (`f8a95a3e928d17a52e467950e50ba8e33217a276`, verified from the worktree HEAD).
- Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_main_verify_20261013`. Every `file:line` below refers to `f8a95a3`.
- Base update (Observed per the coordinator; no local checkout at the new SHA, so Unknown in detail): `origin/main` is now `73fe9f2`, which includes #273 (self-hosted fonts, stricter CSP). Evidence `file:line` references stay at `f8a95a3` and Step 0 must re-verify them at `73fe9f2` or later. Closest local evidence of #273 is the worktree `H:\CommandCenter\orchestrator\lizbeth_spanish-fonts` (branch `feat/252-self-host-fonts`): its `index.html:8` CSP keeps `script-src 'self'`, sets `font-src 'self'`, and drops `fonts.googleapis.com` and `fonts.gstatic.com`.
- Evidence labels: Observed (read in code or an approved plan), Inference (derived from Observed facts, with the test that verifies it), Unknown (not established).
- Research: not needed. All decisions are grounded in local code. The PostgREST error codes used for detection (`PGRST205` or `42P01` for a missing relation, `PGRST204` or `42703` for a missing column) are handled defensively: unknown codes fall back to the safe "read failed" or generic path, so external confirmation is not material.

**Revision 1 (PLAN_DUCK J-187-01..05, shadow, Codex).** One revision applied in place. The verdict was REVISE and all five findings are accepted. The status stays DRAFT. Call count: 1 of 2 used.

- J-187-01 (major, first paint). Finding: `index.html:2` ships static `lang="en"`; `html[lang]` is set in a passive `useEffect` (`PublicContentContext.tsx:138-140`) and title and meta in another (`:143-148`), which can run after paint. The gate line is intentionally bilingual, so the earlier J8 criterion "no English visible text" was unachievable as written. Disposition: accepted. Fix: keep the reviewed bilingual gate line; add a pure helper `resolveInitialLanguage()` used by both `src/main.tsx` (set `document.documentElement.lang` synchronously before render when the language is already known) and the provider's initial state; move `html[lang]`, title and meta updates to `useLayoutEffect`; rewrite J8 to criteria achievable under the CSP; add unit tests. No inline script, no new script file, no CSP change. Sections touched: 5.7, 5.9, 6, 7 (2.1, 2.3, 2.3a), 10 (J8), 11 (R4), 13 (D-L4), 14.
- J-187-02 (major, skew matrix). Finding: the matrix did not exercise the claimed paths (with the view removed the UI never calls the action). Disposition: accepted. Fix: a matrix S1 to S9 where every row names its fixture and the path it exercises, including a local-only stub-view fixture, a real old-Edge run, and old-frontend runs that prove the generic upsert does not reset the column. Sections touched: 4.1, 8.3, 10 (J5), 11 (R10), 12 (H3), 14.
- J-187-03 (major, cache invalidation). Finding: the cache had no record format, TTL or invalidation rules, so a schema rollback or an owner change could keep a stale language indefinitely. Disposition: accepted. Fix: a versioned JSON record, a 7-day TTL (new decision D-L11), and explicit write, clear and keep rules. Sections touched: 4.2, 7 (2.1, 2.3), 10 (J10b, J10c), 11 (R7), 13 (D-L5, D-L11).
- J-187-04 (minor, owner copy). Finding: one "unsupported" note was inaccurate for the read-time, save-time 400 and save-time 503 cases. Disposition: accepted. Fix: three state-specific notes with their own ids. This is a copy-only change within the design's permitted placeholder-copy variation (D-L9) and changes no layout, control, state set or focus rule, so no design re-review is required; the rationale is recorded here. Sections touched: 5.2, 5.3, 5.4, 5.10, 7 (2.1), 10 (J5, A4).
- J-187-05 (minor, generation guard). Finding: a stale read could overwrite a newer saved value. Disposition: accepted. Fix: a monotonically increasing `defaultGeneration` in the provider and a request sequence in the owner fieldset. Sections touched: 4.2, 7 (2.1, 2.3), 10 (J12b).

Reading guide: approvers need sections 1, 2, 3.1, 12, 13 and 14. Sections 3.2 to 3.9 hold the evidence. Sections 4 to 11 are execution detail for the engineering fleet. Section 5 is the design handoff and is the authoritative design text.

### Standing constraint: production is live

Recorded 2026-10-13 from the user's words: "from this point forward we must consider the project live and production supabase as live with real student and course tracking data. moving forward nothing can be lost in production supabase and all migrations must account for that."

- Production is live, with real student and course tracking data, as of 2026-10-13.
- No production data may be lost.
- Every migration must be non-destructive and account for existing production rows. That means:
  - no DROP, TRUNCATE or DELETE of student, enrollment, progress, submission, attempt, entitlement, course or content data without an approved, logged and reversible data plan;
  - additive or backfilled schema changes with safe defaults;
  - rollbacks that preserve data written after apply;
  - a read-only production preview before any apply that changes access or data.
- Hosted actions still need separate explicit approval.

### Standing constraints

Carried forward from the user:

- Accomplish the goal with proper root-cause analysis.
- Pull requests only: never push directly to `main`.
- Production is LIVE with real student and course data. Nothing may be lost. Migrations are additive with safe defaults. Rollbacks preserve data.
- Each hosted action is separately approved. The user (or the owner) runs hosted actions.
- The student UI is bilingual. The owner admin is English-only.
- Deploy-skew lesson: Netlify builds `main`, so the frontend may publish before the hosted migration or Edge deploy. Every new frontend must degrade safely when the column, the view or the Edge capability is missing. This plan includes an end-to-end test of the new frontend against the previous schema (section 9.3).

---

## 1. Outcome and audience

Audience: the approver (Rob, repository owner) and the downstream engineering fleet.

Outcome: the course owner can choose the site default language (English or Spanish) in Business settings. A visitor with no explicit choice sees that default from first paint on the sign-in card, the `/courses` catalog, the anonymous `/privacy` page and the signed-in student shell. An explicit visitor choice always wins. `/admin` stays English. Every combination of old or new frontend, Edge function and schema degrades safely to today's behaviour (English), with no false save success and no broken existing save.

Delivery: two pull requests against `main` (decision D-L7), both referencing #187; PR 2 closes it. No merge by the fleet. No hosted action without separate approval.

## 2. Scope and non-goals

In scope:

1. `owner_settings` column, a new anon-readable view, and grants.
2. A rollback script that preserves data.
3. A dedicated owner-settings Edge action plus a shared validation library.
4. Frontend precedence, cache, and a bounded first-paint gate.
5. An owner fieldset on Business settings.
6. RED unit, SQL-live, Edge-live and e2e tests, including old-schema skew runs.
7. Hosted rollout steps.

Non-goals:

- Per-student profile language stored server-side.
- Translating the owner admin.
- `Accept-Language` or `navigator.language` auto-detection (a possible future issue).
- Server-side rendering, Netlify Edge HTML injection, or any CSP change.
- Changing `index.html` static `lang="en"`, title or meta (crawlers without JavaScript keep English).
- New owner-editable `site_content` registry keys.
- "Preview as visitor".
- Any change to the generic business save payload.
- Touching #252 privacy behaviour.

## 3. Repository findings

### 3.1 Root cause (Observed)

`readStoredLanguage` in `src/context/PublicContentContext.tsx:50-57` returns the stored value when it is `'es'`, otherwise `'en'`, and returns `'en'` when storage throws. It collapses four distinct states (absent, invalid, blocked, explicit `'en'`) into one value. A default therefore cannot be layered underneath an explicit choice today, because an explicit English choice is indistinguishable from "no choice". No default-language setting exists anywhere (confirmed by search). The fix needs a tri-state stored read, a new owner-controlled source, and a defined precedence.

### 3.2 Evidence re-verification against the PLAN_JOB brief (Observed, with corrections)

- The brief's path "PublicContentContext.tsx" is `src/context/PublicContentContext.tsx` (singular `context`).
- `readStoredLanguage` is at `:50-57` (the brief said `:33-50`). `SITE_LANGUAGE_STORAGE_KEY = 'lizbeth.siteLanguage'` is at `:23`.
- Admin forcing is at `:59-99` (the brief said `:58-92`): `isAdminPath` `:65-67`, `useOnAdminRoute` `:69-82`, `language = onAdmin ? 'en' : storedLanguage` at `:99`.
- `setLanguage` writes localStorage only on an explicit toggle (`:123-130`). The html `lang` effect is at `:138-140`; title and meta effects at `:143-148`. `NO_PROVIDER_VALUE` language `'en'` is at `:39-45`.
- `owner_settings` is readable only by `authenticated`: `202607170007_owner_settings_authenticated_read.sql:29-39` (grant select to authenticated; policy `using(true)`). Writes go only through `service_role` (migration `202607170002` RLS). It is a singleton row: `202610030003_issue177_owner_settings_singleton.sql:47-54` (`singleton boolean unique`; `owner_id` is the last saver).
- The anon-projection precedent is issue #252, migration `supabase/migrations/202610140001_issue252_privacy_details.sql`. The brief called it "#268"; #268 may be the PR number. That is Unknown. The discrepancy is recorded here.
  - It creates view `public.public_privacy_details` at `:80-88` without `security_invoker` (comment `:78-79`).
  - It then runs `revoke all` from `public`, `anon`, `authenticated` and `grant select` to `anon`, `authenticated` at `:90-93`.
  - It issues `notify pgrst` at `:101` and sets `lock_timeout` 5s and `statement_timeout` 30s at `:25-26`.
  - Its rollback `supabase/rollbacks/issue252_privacy_details_rollback.sql` archives owner-entered values into a `service_role`-only archive table before dropping (`:17-50`) and provides a restore `UPDATE` (`:69-76`).
  - The earlier precedent `public.public_site_content` (`202610040001_issue177_site_content.sql:12-17`) keeps `owner_settings` non-anon.
- First-paint flash risk is confirmed. `PublicContentProvider` is mounted above `AuthGate` (`src/App.tsx:945-955`). `/courses` returns `PublicCatalogPage` at `App.tsx:847-848` BEFORE the auth loading branch (`:850-861`, `div.app.app-initial-loading > p role=status {signInCopy.loading}`). Anonymous `/privacy` is at `:866`; the sign-in card at `:914-936`; the signed-in shell at `:938-942`. Any asynchronous default read paints English first and then flips.

### 3.3 Edge function (Observed)

`supabase/functions/owner-settings/index.ts`:

- PUT only; token verified via GoTrue `:83-93`; owner claim `:95-99`.
- Action routing `:111-125` accepts only `PRIVACY_ACTION_NAMES` and otherwise returns 400 `{error:'Unknown privacy policy action.'}`.
- Generic save `:127-169` goes through `sanitizeOwnerSettingsPayload` and `writeOwnerSettings` (`src/lib/ownerSettingsWrite.ts:41-49`, upsert `onConflict 'singleton'`, `owner_id` = caller, `updated_at`).
- Inference from current code (hosted version Unknown): an Edge older than #252 has no action branch, so `{action, language}` sanitizes to nothing and returns 400 `{error:'No recognized settings fields were provided.'}` (`:132-134`).

### 3.4 Why a dedicated action (Observed, root cause for skew)

`sanitizeOwnerSettingsPayload` (`src/lib/ownerSettingsAuthorization.ts:124-319`) reads only known fields and silently ignores others (doc `:118-123`). If `default_site_language` were added to the generic save:

- (a) an old Edge would silently drop it while saving other fields and return 200, which is a FALSE SUCCESS;
- (b) a new Edge on an old schema would include an unknown column in the upsert and fail the WHOLE business save (500).

Hence a dedicated action, and the generic save must never carry this field.

### 3.5 Client data layer (Observed)

- `src/services/ownerSettingsData.ts` `saveOwnerSettings` `:138-166` (invoke `owner-settings` PUT; maps `fieldErrors`); `getOwnerBranding` reads `owner_settings` (authenticated).
- `src/services/privacyDetailsData.ts` is the read precedent: never throws, `AbortController` plus timeout, returns `{row, failed}` at `:33-63`; action errors mapped to fixed copy at `:120-136`.
- `src/services/siteContentData.ts:37-46` is a public view read with silent failure.

### 3.6 Owner UI (Observed)

- `src/pages/BusinessSettingsPage.tsx` is a single form with one primary Control "Save business settings" (`:109`), `pendingCount` (`:46-48`), sequential save then site-content commit with a named partial failure (`:67-85`), `PrivacyDetailsFieldset` at `:102`, privacy modals outside the form at `:113`. Admin route `/admin/business-settings` (`App.tsx:111`).
- Styles: `src/pages/OwnerSettingsPage.css` (privacy fieldset about `:748-797`; the final forced-colors block must remain last, comment about `:827`).
- Control is natively disabled while saving (`src/components/ui/Control.tsx:16-20`, per design reviewer).
- `LanguageToggle` (`src/components/LanguageToggle.tsx:20-35`) is an `aria-pressed` pair, never natively disabled, rendered on the sign-in panel, `/courses`, the authenticated header and the mobile menu (`App.tsx:585`, `:714`; `PublicCatalogPage.tsx:126`; `MobileNavPanel.tsx:190`; `PrivacyPolicyPage.tsx:313`).

### 3.7 CSP (Observed)

`index.html:8` meta CSP has `script-src 'self'` (no inline script). `connect-src` lists `127.0.0.1:54321` only (the local mirror edits it to 64321). `index.html:2` has static `lang="en"`. `desktop/main.cjs:24` has its own CSP. An inline bootstrap script is therefore prohibited, and an external same-origin boot script cannot read the owner default synchronously either.

After #273 (`origin/main` `73fe9f2`, Observed per the coordinator; closest local evidence is the `lizbeth_spanish-fonts` worktree, `index.html:8`): `script-src 'self'` is kept, `font-src 'self'` is set, and the Google font origins are dropped. The conclusions above are unchanged. The "CSP unchanged" acceptance check in this plan refers to the `73fe9f2` CSP. The mirror's local CSP edit must be re-derived from the `73fe9f2` `index.html`: only `connect-src` gains `64321` and the vite websocket origin, and the Google font origins are never reintroduced. `src/main.tsx` is an external module already allowed by `script-src 'self'` and already runs pre-render work (`main.tsx:6-10`, at `f8a95a3`); section 5.7 uses it.

### 3.8 Tests and infrastructure (Observed)

- `playwright.config.ts`: `testDir` `src/__tests__/e2e`, workers 1, `baseURL` `E2E_BASE_URL` or 8888, projects `chromium` and `webkit-mobile`.
- `src/__tests__/helpers/testConfig.ts` resolves `SUPABASE_API_URL` and `SUPABASE_DB_PORT` (loopback-guarded). Native dialog policy test: `src/__tests__/nativeDialogPolicy.test.ts`.
- e2e precedent `src/__tests__/e2e/issue252-privacy-policy.spec.ts`: dialog guard `:35-39`, `VIEWPORTS` 1440x900 and 390x844 `:14-17`, SQL fixtures via loopback pg `:19-33`. Note: its `addInitScript` localStorage removal at `:74` runs on every navigation including reload, so reload-persistence journeys in this plan must use fresh contexts instead.
- SQL test precedent `src/__tests__/issue252PrivacyDetailsSql.test.ts` (asserts no `security_invoker` at `:80`).
- Mirror `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run`: `supabase/config.toml` api 64321, db 64322, studio 64323, shadow 64320. Its `index.html` CSP is edited for 64321 (mirror-local, never committed); for this plan the edit must be re-derived from the `73fe9f2` `index.html` (section 3.7).

### 3.9 Migrations (Observed, Unknown hosted state)

The latest migration on `main` is `202610140001_issue252_privacy_details.sql`. The hosted-applied status of `202610110001` through `202610140001` is Unknown (the parent status lists several as pending hosted apply).

## 4. Interfaces and data

- DB: `public.owner_settings.default_site_language text NOT NULL DEFAULT 'en'` with a `CHECK` in (`'en'`,`'es'`). View `public.public_site_settings(default_site_language)` is SELECT-only for `anon` and `authenticated`, with no `security_invoker` (definer-rights projection per the #252 precedent). Base table grants and policies are unchanged.
- Edge: `PUT owner-settings {action:'set_default_site_language', language:'en'|'es'}` returns one of:
  - 200 `{data:{default_site_language}}`
  - 401
  - 403
  - 422 `{error:'Validation failed.', fieldErrors}`
  - 503 `{error, code:'default_language_unavailable'}`
  - 500 `{error:'Failed to save settings.'}`
  - Legacy responses the client must recognize: 400 `'Unknown privacy policy action.'` (post-#252 Edge) and 400 `'No recognized settings fields were provided.'` (pre-#252 Edge).
- Client: `siteSettingsData.readDefaultSiteLanguage(): Promise<{value:'en'|'es'|null; failed:boolean; reason?:'unsupported'|'read_failed'}>` and `saveDefaultSiteLanguage(lang)`. `PublicContentContext` adds `languageResolved:boolean` and `applyOwnerDefault(lang)`.
- localStorage: `lizbeth.siteLanguage` (explicit choice, unchanged semantics) and a new cache key `lizbeth.siteDefaultLanguage` (last-known owner default as a versioned record, section 4.2; never treated as a choice).
- Precedence: `/admin` gives `'en'`; otherwise the explicit stored choice, then the owner default (live this load, else cached), then `'en'`.

### 4.1 Skew matrix (all must be safe; every row names its fixture and the path it exercises)

With the view removed the UI never calls the action, so the save-time paths need their own fixtures. "Old schema" means the rollback is applied (no column, no view). "Base-commit" means the PR 1 merge base (`73fe9f2` or later).

| # | Frontend | Schema | Edge | Fixture | Path exercised and expected behaviour |
|---|---|---|---|---|---|
| S1 | new | new | new | Main spec. | Full feature. |
| S2 | new | old (rollback applied) | new | Rollback applied via loopback pg, then `notify pgrst`. | Read-time unsupported via the real `PGRST205` or `42P01` response. Visitors English. Owner fieldset shows the read-time unsupported copy. Network assertion: the action is never called. A brand-name business save returns 200 and persists. |
| S3 | new | view present, column missing | new | Local-only, loopback-guarded fixture `src/__tests__/fixtures/issue187-stub-view-no-column.sql`: after the rollback, `create view public.public_site_settings as select 'en'::text as default_site_language from public.owner_settings`, with the same revoke and grant. Removed after the run (drop the stub view, re-apply the migration). | The UI loads ready and Save calls the REAL new Edge, which hits the missing column and returns the REAL 503 `default_language_unavailable`. Assert the save-time 503 UI state and copy; business fields are still saved. |
| S4 | new | new | OLD (post-#252) | Copy the base-commit `owner-settings` function and its imported `src/lib` files into the mirror per file; restart `supabase_edge_runtime`; restore the new Edge afterwards. | Save returns the REAL 400 `Unknown privacy policy action.`. Assert the save-time 400 state and copy, no false success, and the live view value unchanged. |
| S5 | new | new | pre-#252 legacy body | Playwright route intercept returning exactly 400 `{error:'No recognized settings fields were provided.'}`. Recorded as a contract simulation; no pre-#252 deployable is required. | Same save-time 400 state as S4. The unit mapper test covers the same body. |
| S6 | OLD (base-commit build, served by `vite preview` on a second port) | new | new | Seed `default_site_language` to `'es'` first. | An explicit owner journey edits the brand name and saves, 200. SQL then asserts `default_site_language` is unchanged, proving the generic singleton upsert does not reset the column. The old-frontend visitor journey renders English as today (the old frontend ignores the default; expected) with no console errors. |
| S7 | OLD | new | OLD | As S6 with the old Edge from S4. | Same business-save assertion as S6 (column preserved). |
| S8 | OLD | old | new | Rollback applied. | The base-commit sign-in and `issue252` specs pass, and a brand-name save works (generic path unchanged). |
| S9 | n/a | rollback then re-apply | n/a | Set `'es'`, apply the rollback (value archived), re-apply the migration, run the restore snippet. | Assert `'es'` is restored. |

The live Edge API tests in PR 1 still cover the 503 and the legacy 400s directly.

### 4.2 Cache record, invalidation and generation guard

Cache record. Key `lizbeth.siteDefaultLanguage` stores JSON `{v:1, value:'en'|'es', savedAt:<epoch ms>}`. A malformed record, or one with another version, is cleared and treated as none.

TTL. Constant `SITE_DEFAULT_LANGUAGE_CACHE_TTL_MS`, recommended 7 days (decision D-L11). An expired record is treated as none (the first-ever-visitor gate applies) and is cleared.

Rules per read outcome:

| Read outcome | Cache action |
|---|---|
| Success with a value | Overwrite the record (value, `savedAt` now). |
| Success with zero rows | Clear the cache. |
| Reason `unsupported` (view missing) | Clear the cache. |
| Reason `read_failed` (network or timeout) | Keep the cache unchanged (still TTL-bounded). |
| Any failure | Never write. |

D-L5 still holds: these changes never switch an already-rendered page; they take effect on the next load. Consequence after a schema rollback: a visitor with cached `es` sees Spanish for at most one more load, then English (an accepted extension of R7).

Generation guard. In `PublicContentContext`, a monotonically increasing `defaultGeneration` ref. Every default read captures the generation at start. `applyOwnerDefault(value)` increments it before applying. A read result (state AND cache write or clear) is applied only if its captured generation still equals the current one. In the owner fieldset, the live read and each save carry a request sequence: a read that started before a completed save is discarded, and save responses apply only for the latest sequence (Save is single-flight already; the guard is a backstop).

## 5. Design route and reviewed design handoff

`DESIGN_ROUTE` profile: compact. Reasons: bounded brownfield; one fieldset on an existing owner page plus a text-only gate on existing public surfaces. Agents required: design-generalist, design-reviewer. Prototype: forbidden. Model tier: sonnet. Existing system mode: preserve.

Design review: `DESIGN_REVIEW_RESULT` verdict PASS (design-reviewer, Sonnet). The first pass returned NEEDS_REVISION with findings F1 to F9 (skew-rule contradiction, focus loss on disabled controls, unsupported versus read-failed split, cache hydration and propagation, tri-state read and lang/title flash, status-node duplication and radio sizing, CSS placement before the forced-colors block, browser-brief gaps, validation-path dead code). All were resolved in revision 1. Reviewer limit: the second pass reviewed a planner delta summary against first-pass verified evidence. This section is the authoritative design text and engineering must not deviate from it. Plan Revision 1 (J-187-01, J-187-04) amended the owner notes (5.2 to 5.4) and the first-paint mechanics (5.7) as described there; the amendments change no layout, control, state set or focus rule and are copy and effect-timing changes within the permitted variation, so no design re-review was run.

### 5.1 Direction and placement

- Preserve the Owner desk system. One fieldset on Business settings reuses the Privacy fieldset treatment; the existing loading status line is reused. No new look, token, typeface or motion.
- Placement: Business settings, a new fieldset after "IP / copyright notice" and before "Privacy policy details". Rejected: Brand design (a look-only page with its own save cycle).

### 5.2 Control and copy

- Control: native radio group in a `<fieldset>` with `<legend>`; `name` `default-site-language`; one Tab stop, native arrows, no custom keys, no select, toggle or modal.
- Copy (English only; placeholder pending owner wording review, decision D-L9):
  - Legend: "Default site language".
  - Helper (id `default-language-helper`): "Sets the language visitors see when they have not picked one themselves. A visitor's own choice always wins. The owner admin area always stays in English."
  - Radio "English" (`en`).
  - Radio `<span lang="es">Español</span> (Spanish)` (`es`).
- Fieldset `aria-describedby` = helper plus any visible note or error id: `default-language-loading`, `default-language-unsupported` (read-time), `default-language-save-unavailable` (save-time 400), `default-language-schema-unavailable` (save-time 503), `default-language-read-failed`, `default-language-error`, `default-language-form-error`.

### 5.3 States

| State | Behaviour |
|---|---|
| Loading | Radios natively disabled, `role=status` "Loading the current default…". Other fields stay editable. |
| Ready | Live-read value checked. Zero rows means English checked and not dirty. |
| Unsupported, read-time | View missing (S2). Radios disabled; English checked. Note id `default-language-unsupported`: "The default language setting is not available yet, so visitors see English. Your other business settings can still be saved." Excluded from `pendingCount` and payload; no success. |
| Unsupported, save-time 400 | Edge lacks the action; view present (S4, S5). Radios disabled; the retained selection stays checked. Note id `default-language-save-unavailable`: "Saving the default language is not available yet, so your selection was not saved. Visitors still see {English\|Spanish}, the current default. Your other business settings can still be saved." where the braces hold the label of the live-read baseline value. Excluded from `pendingCount` and payload; no success. |
| Unsupported, save-time 503 | Column missing (S3). Radios disabled; the retained selection stays checked. Note id `default-language-schema-unavailable`: "The default language setting is not available yet, so your selection was not saved and visitors see English. Your other business settings can still be saved." Excluded from `pendingCount` and payload; no success. |
| Read failed | Network or timeout. Radios disabled, none checked. Note: "Could not load the current default, so this setting is locked. Reload the page to try again." Excluded. |
| Saving | Save Control reads "Saving…" and is natively disabled. Radios stay enabled but ignore changes. |
| Success | "Business settings saved." only when `pendingCount` is 0 and every needed step succeeded. Baseline = the server-returned value. |
| Error | Fixed copy only, in the existing `role=alert` `.owner-settings-error` slot. Never raw server text, status or codes. |
| Validation | Unit-test-only path. A non en/es value reverts. Inline "Choose English or Spanish." (id `default-language-error`), focus the checked radio. Form-level "The default language could not be saved. Choose English or Spanish." (id `default-language-form-error`). |

### 5.4 Save sequence and failure copy

Order: business save, then site-content commit, then the language step only when dirty and supported.

- Language-only failure alert: "Business settings were saved, but the default language could not be saved. Your language selection is still unsaved. Please try again." Selection kept, still 1 unsaved change.
- Site text and language both failed: "Business settings were saved, but the site text and the default language could not be saved. Your site text edits and language selection are still unsaved."
- Business save fails first: existing path; language untouched and dirty.
- Save-time skew (400 unknown action or 503 `default_language_unavailable`): the fieldset becomes unsupported with the retained selection checked and radios disabled. A 400 shows the `default-language-save-unavailable` note; a 503 shows the `default-language-schema-unavailable` note (section 5.3). The step leaves `pendingCount` and the payload. The form alert is the same for both: "Business settings were saved, but the default language setting is not available yet. Your selection was not saved." Only a reload re-probes. Radios are never re-enabled for retry.

### 5.5 Focus contract

When a save settles and `document.activeElement` is `body`, move focus to the Save Control by ref. Run this in an effect after the commit that re-enables Save (reviewer advisory A1: calling `focus()` before re-enable is a silent no-op).

### 5.6 Hydration

The owner fieldset hydrates only from a live read, never from the visitor cache. On language-step success, write the server-returned value to the `PublicContentProvider` default state and to the cache key.

### 5.7 Visitor gate

- Reuse `div.app.app-initial-loading` with `<p role="status">`. Text: `<span lang="en">Loading…</span> / <span lang="es">Cargando…</span>` while unresolved (strings from `signInCopy.ts:65` and `:88`). The line is intentionally bilingual and is the language-neutral status; it is unchanged by Revision 1.
- Pre-render language (Revision 1, J-187-01): a pure helper `resolveInitialLanguage()` (tri-state stored choice, valid unexpired cache, admin path) is used by BOTH `src/main.tsx` and the provider's initial state. `main.tsx` sets `document.documentElement.lang` synchronously before `ReactDOM` render whenever the language is already known (stored choice, valid cache, or `/admin`). It is an external module already allowed by `script-src 'self'`. No inline script, no new script file, no CSP change.
- The static `lang="en"` in `index.html` during the empty-`#root` and gate phase is accepted and is not a failure: removing it would violate WCAG 3.1.1, and changing it needs an inline script, which the CSP prohibits.
- The gate and the auth-loading branch are ONE element in one position (status node inserted once). `/courses` gains the branch. The real page is not mounted until resolved.
- Target under 300 ms. Hard maximum is a single named constant within 1000 to 2000 ms, then English. No `aria-busy`, no focus, no animation.
- `html[lang]`, `document.title` and meta updates run in `useLayoutEffect`, so they commit before paint in the same commit as the first non-gate content. While unresolved they are skipped (the static `index.html` `lang="en"` and title remain only while `#root` is empty or shows the bilingual gate).
- Late responses never change an already-rendered page; they only update the cache (exception: an owner save in the same session updates provider state).
- `LanguageToggle` `aria-pressed` reflects the resolved language and is never natively disabled.
- The cache key is separate from `lizbeth.siteLanguage` and is never copied into it. The cache record, TTL and invalidation rules are in section 4.2.

### 5.8 Visual

Reuse tokens: `--space-*`, `--color-ink-1000` border, `--color-ink-900` helper, `--color-focus`, `--focus-ring-width/offset`, `--border-width-thin`, `--font-size-caption`.

- Legend weight 600 like `.owner-settings-privacy-fieldset legend`.
- Fieldset margin `var(--space-6) 0`, padding `var(--space-4) var(--space-6)` (`var(--space-4)` at 480px and below), `min-width: 0`.
- Rows stacked with gap `var(--space-2)`; flex label rows with `min-height: 44px`; radio input sizing mirrors `.privacy-attest input` (1.5rem, `flex: none`); helper `overflow-wrap: anywhere`.
- New classes `.owner-settings-language-fieldset` and `.owner-settings-language-option`, placed directly after the `.owner-settings-privacy-*` rules and before the about-`:827` comment. The final forced-colors block stays last. No new tokens or colors.

### 5.9 Engineering invariants and permitted variation

Invariants:

- One primary Control and one form submit; no modal; no native dialogs (deterministic scan).
- Existing privacy modals keep trap and restore.
- No new registry keys.
- `lizbeth.siteLanguage` is written only by the explicit toggle.
- Tri-state stored read.
- `resolveInitialLanguage()` is the single source for `main.tsx` and the provider's initial state; `html[lang]`, title and meta use `useLayoutEffect`.
- Default reads and owner saves are generation-guarded (section 4.2).
- The language action is never called when not dirty, unsupported or read-failed.
- Dedicated Edge action.
- `/admin` is always `en` and never gated.

Permitted variation: class names, state shape, hook structure, timeout within 1000 to 2000 ms, cache key name, internal reason carriage, and language-step order versus site-content commit if failures are named accurately.

Not permitted: moving the control off Business settings; a select, toggle or modal; an English-only gate line; a spinner requirement; radios enabled for retry after skew; blocking `/admin`.

### 5.10 Reviewer advisories carried into this plan

- A1: focus restore in an effect after Save re-enables (section 5.5).
- A2: treat a 404 as unsupported only when the body carries `PGRST205` or `42P01`; match the save-time 400 on status AND exact message; any other 400 maps to generic error copy.
- A3: add a deterministic check of zero CSP violations in the console and no inline `<script>` in built `index.html` across the gate and cached-default journeys.
- A4: resolved by the per-state notes (J-187-04), each of which names what visitors see and whether the selection was saved. Keep the screenshot check in the browser pass that each note and a retained Español selection read coherently. Copy adjusts only if owner wording review flags it.

## 6. Judge route

- PLAN_DUCK: required after Scribe (migration on live production plus a new anon-readable surface). Observed disposition: PLAN_DUCK (Codex, shadow) returned verdict REVISE with J-187-01..05; all five accepted and applied in Revision 1. Call count: 1 of 2 used.

| Finding | Severity | Disposition | Applied in |
|---|---|---|---|
| J-187-01 first paint | major | Accepted | Revision 1 |
| J-187-02 skew matrix | major | Accepted | Revision 1 |
| J-187-03 cache invalidation | major | Accepted | Revision 1 |
| J-187-04 owner copy | minor | Accepted | Revision 1 |
| J-187-05 generation guard | minor | Accepted | Revision 1 |

- CODE_REVIEW: required after JOB_DONE for each PR (grants, anon exposure, skew error mapping).
- VERIFICATION_CHALLENGE: only if coverage risk remains after Verifier.
- VISUAL_REVIEW: skipped (compact, not brand-critical).
- Risk: medium. Call cap: 2 (standard); a third call needs user approval.
- Rubric IDs: `data-safety` (additive, rollback preserves data), `anon-exposure` (exact column allowlist, no DML via view), `skew-degradation` (skew runs S1 to S9, section 4.1), `precedence-correctness`, `first-paint` (no EN-before-ES in text, lang, title), `a11y`.
- Finding IDs flow from the judge into the engineering job brief and the Verifier checklist. The only judge pass observed so far is the PLAN_DUCK result recorded above; no CODE_REVIEW result exists yet and none is promised by this document.

## 7. Ordered work

**Step 0, preflight (writer).** Confirm the `origin/main` SHA (the coordinator reports `73fe9f2`, including #273) and re-read every cited file, re-verifying each `file:line` at `73fe9f2` or later because the references were taken at `f8a95a3`. The plan is stale if `main` (including #273) changed `PublicContentContext.tsx`, `App.tsx` AuthGate, `src/main.tsx`, `BusinessSettingsPage.tsx`, `OwnerSettingsPage.css` (materially), `owner-settings/index.ts` or `ownerSettingsAuthorization.ts`, or added a migration touching `owner_settings`. Branch per PR from current `main`; PRs only, never push to `main`.

### PR 1 "issue187 data + Edge"

Branch `issue187-default-language-data`. Refs #187. No visible UI change.

**1.1 RED tests first**

- `src/__tests__/issue187DefaultLanguageSql.test.ts` (live, loopback pg):
  - column `default_site_language` exists, `text NOT NULL default 'en'`;
  - the existing row gets `'en'`;
  - `CHECK` rejects `'fr'` and `''`;
  - view `public.public_site_settings` exposes exactly `[default_site_language]`;
  - `reloptions` has no `security_invoker` (matches the #252 precedent; R1 is the compensating control);
  - `anon` and `authenticated` have SELECT only (`has_table_privilege` INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER all false);
  - as `anon`, UPDATE, INSERT and DELETE through the view fail with permission denied (simple views are auto-updatable, so this is load-bearing);
  - `anon` SELECT on `owner_settings` is still denied; `authenticated` SELECT on `owner_settings` is unchanged;
  - all other `owner_settings` column values are byte-identical before and after apply;
  - migration re-run is idempotent;
  - rollback archives the value into `default_site_language_rollback_archive`, drops view, constraint and column, and the documented restore returns `'es'` after re-apply;
  - an empty `owner_settings` table makes the view return zero rows.
- `src/__tests__/issue187SiteLanguageSetting.test.ts` (unit, lib):
  - validate accepts only `'en'` or `'es'` (422 `fieldErrors [{field:'default_site_language', message:'Choose English or Spanish.'}]` otherwise, including non-string);
  - action name `set_default_site_language` does not collide with `PRIVACY_ACTION_NAMES`;
  - a missing-column DB error (`PGRST204` or `42703` in code or message) gives 503 `{error:'The default language setting is not available yet.', code:'default_language_unavailable'}`;
  - other DB errors give 500 `{error:'Failed to save settings.'}` with no raw text;
  - success gives 200 `{data:{default_site_language}}`;
  - `sanitizeOwnerSettingsPayload` ignores `default_site_language` (pins the generic-save skew guarantee).
- `src/__tests__/issue187OwnerSettingsEdgeLive.test.ts` (live, mirrors `issue252PrivacyEdgeLive.test.ts`): owner 200 and persisted; student 403; no token 401; bad value 422; privacy actions still route; an unknown action still returns 400 `'Unknown privacy policy action.'` (message unchanged for compatibility); with the 187 rollback applied, the action returns 503 `default_language_unavailable` and a generic `brand_name` save still returns 200.

**1.2 Migration** `supabase/migrations/<YYYYMMDD>0001_issue187_default_site_language.sql` (next free timestamp after `202610140001`, naming per parent `:808`):

- Header comment (what, data safety, rollback pointer) mirroring `202610140001`.
- `begin; set local lock_timeout '5s'; set local statement_timeout '30s';`
- `alter table public.owner_settings add column if not exists default_site_language text not null default 'en';`
- `drop constraint if exists` then `add constraint owner_settings_default_site_language_check check (default_site_language in ('en','es'));`
- Column comment.
- `create or replace view public.public_site_settings as select default_site_language from public.owner_settings;`
- `revoke all on public.public_site_settings from public, anon, authenticated;` then `grant select` to `anon`, `authenticated`.
- View comment stating that every column must be intentionally public.
- `commit; notify pgrst, 'reload schema';`
- No DROP, TRUNCATE or DELETE. `ADD COLUMN` with a constant default is metadata-only on PostgreSQL 11 and later, and the table is a one-row singleton.

**1.3 Rollback** `supabase/rollbacks/issue187_default_site_language_rollback.sql` (prepared, NOT applied):

- `create table if not exists public.default_site_language_rollback_archive(archived_at timestamptz default now(), owner_settings_id uuid, default_site_language text)`, RLS on, `revoke all` from `public`/`anon`/`authenticated`, `grant select, insert` to `service_role`.
- Insert the snapshot only if the column exists.
- `drop view if exists`; `drop constraint if exists`; `drop column if exists`; `commit`; `notify pgrst`.
- Restore snippet (`distinct on owner_settings_id order by archived_at desc`).
- The archive is never dropped. Order: no frontend revert is needed (it degrades); the Edge may stay (it returns 503).

**1.4** `src/lib/siteLanguageSetting.ts` (dependency-free, Deno-importable, explicit `.ts` import convention): `SITE_LANGUAGE_ACTION_NAMES`, `SiteLanguage` type reuse, `validateDefaultSiteLanguage`, and `runSiteLanguageAction(client, payload, callerId, nowIso)`, which writes `{default_site_language}` through `writeOwnerSettings` (singleton upsert, `owner_id`, `updated_at`) and maps errors as tested.

**1.5** `supabase/functions/owner-settings/index.ts`: in the action branch (`:111-125`), route `PRIVACY_ACTION_NAMES` to privacy, `SITE_LANGUAGE_ACTION_NAMES` to `runSiteLanguageAction` (owner check already done above), else the unchanged 400. The generic save path is untouched.

**1.6** GREEN, lint, `tsc`, full vitest; CODE_REVIEW; Verifier.

### PR 2 "issue187 frontend"

Branch `issue187-default-language-ui`, after PR 1 merges. Closes #187.

**2.1 RED tests first**

- `src/__tests__/issue187SiteSettingsData.test.ts`:
  - `readDefaultSiteLanguage` never throws;
  - `'en'`/`'es'` give the value; zero rows, null and other strings give `value: null, failed: false`;
  - an error body with `PGRST205` or `42P01` gives `{failed:true, reason:'unsupported'}`;
  - a bare 404 without those codes, a network error and a timeout give `reason: 'read_failed'`;
  - `saveDefaultSiteLanguage` maps 400 with the exact `'Unknown privacy policy action.'` or the exact `'No recognized settings fields were provided.'` to unsupported, and 503 code `default_language_unavailable` to unsupported;
  - any other 400, 401/403, 422, 500 or network error gives fixed copy; server text is never surfaced.
- `src/__tests__/issue187LanguagePrecedence.test.tsx` (PublicContentContext):
  - tri-state stored read;
  - stored `en` beats owner `es`; stored `es` beats owner `en`; no stored value uses the owner default; no stored value and a failed read gives `en`;
  - an invalid stored value is treated as none; blocked storage (`getItem` throws) does not crash;
  - `/admin` gives `en` regardless and is never gated;
  - the gate is active only when not admin AND stored none AND no valid unexpired cache;
  - the gate releases on success, failure or `SITE_DEFAULT_LANGUAGE_TIMEOUT_MS` (recommend 1500);
  - a late response after release updates the cache only; a failed read never writes the cache;
  - `setLanguage` writes only `lizbeth.siteLanguage`; the default path never writes `lizbeth.siteLanguage`;
  - html `lang`, title and meta effects are skipped while unresolved;
  - `applyOwnerDefault(value)` updates provider state and cache.
  - `resolveInitialLanguage` matrix (tri-state stored choice, valid and expired cache, malformed cache, admin path, blocked storage).
  - `main.tsx` sets `document.documentElement.lang` before render (module test).
  - Layout-effect ordering: `lang` and title equal the resolved language at the first content commit.
  - Cache rules (section 4.2): one case each for success with a value, zero rows, `unsupported`, `read_failed` (cache kept), no write on failure, TTL expiry, malformed record, other version.
  - Generation guard: a read starts, the owner save applies `'es'`, the stale read resolves `'en'` and is ignored for both state and cache.
- `src/__tests__/issue187AuthGateGate.test.tsx` (App): one status node across gate and auth loading (inserted once); `/courses` gated; anonymous `/privacy` gated; signed-in shell gated; `/admin` not gated; bilingual gate text with `lang` spans.
- `src/__tests__/issue187BusinessSettingsLanguage.test.tsx`: all fieldset states (including the three unsupported notes with their ids and the baseline-label substitution); `pendingCount`; both partial-failure combinations; skew rule; action not invoked when clean, unsupported or read-failed; focus restore after settle; validation path; English-only owner copy; no native dialogs; a read that started before a completed save is discarded and does not overwrite the saved baseline.
- Extend an existing CSP or content test: built or source `index.html` gains no inline `<script>` and the CSP string is unchanged relative to the `73fe9f2` CSP.
- Add the local-only fixture `src/__tests__/fixtures/issue187-stub-view-no-column.sql` (loopback-guarded; used by skew run S3).

**2.2** `src/services/siteSettingsData.ts`: read with `AbortController` and timeout like `privacyDetailsData.ts:33-63`; save via `functions.invoke('owner-settings', {method:'PUT', body:{action:'set_default_site_language', language}})`; fixed-copy mapper.

**2.3** `src/context/PublicContentContext.tsx`:

- tri-state `readStoredChoice` and the pure `resolveInitialLanguage()` (shared with `src/main.tsx`, which sets `document.documentElement.lang` before render when the language is known; see 2.3a);
- cache key `lizbeth.siteDefaultLanguage` holding the versioned record, TTL and invalidation rules of section 4.2 (`SITE_DEFAULT_LANGUAGE_CACHE_TTL_MS`, recommend 7 days);
- a `defaultGeneration` ref; every default read captures it, `applyOwnerDefault` increments it first, and a stale result is dropped for state and cache;
- `html[lang]`, title and meta updates in `useLayoutEffect`, skipped while unresolved;
- `ownerDefault` state seeded from the cache;
- `languageStatus` of `'resolving'` or `'ready'`;
- one default read on mount (on admin it may still run to refresh the cache, but must never block admin);
- `language = onAdmin ? 'en' : stored ?? ownerDefault ?? 'en'`;
- expose `languageResolved` and `applyOwnerDefault`;
- keep `NO_PROVIDER_VALUE` behaviour for bare-rendered tests.

**2.3a** `src/main.tsx`: call `resolveInitialLanguage()` and set `document.documentElement.lang` synchronously before `ReactDOM` render whenever the language is already known (stored choice, valid cache, or `/admin`). External module only; no inline script, no new script file, no CSP change.

**2.4** `src/App.tsx` AuthGate: a single loading element rendered when the gate is active OR auth is loading OR pendingLanding. `/courses` and public course routes wait only on the gate (not on auth loading, preserving today's catalog behaviour). Gate text is bilingual while unresolved and uses the existing `signInCopy.loading` afterwards (same node).

**2.5** Owner UI: a new component (for example `src/components/DefaultLanguageFieldset.tsx`) plus `BusinessSettingsPage` integration per section 5; CSS in `OwnerSettingsPage.css` at the specified position.

**2.6** e2e `src/__tests__/e2e/issue187-default-language.spec.ts` (journeys in section 10) plus the skew procedure. Artifacts in `browser-validation-artifacts/issue-187/`.

**2.7** GREEN, lint, `tsc`, full vitest, existing e2e regressions (`issue252-privacy-policy.spec.ts`, sign-in specs); CODE_REVIEW; Verifier; Browser Validator.

Owners: T1 implements each PR (T2 on escalation per fleet rules); Verifier; Browser Validator for PR 2 (and the PR 1 skew smoke via e2e only); Scribe for any later evidence document. Hosted steps H0 to H4 run only after separate explicit approvals.

## 8. Acceptance and validation

### 8.1 Per-PR gates

- `npm run lint`; `npx tsc --noEmit` (or `npm run build` = `tsc && vite build`).
- Targeted vitest RED to GREEN evidence; full `npx vitest run` green.
- Live SQL and Edge suites against the local mirror.
- `nativeDialogPolicy.test.ts` green.
- Deterministic grep over changed files for `alert(`, `confirm(`, `prompt(`, `window.alert`/`confirm`/`prompt`, `beforeunload`: zero hits.

### 8.2 PR 2 browser gates

- e2e on chromium at 1440x900 and 390x844, plus 320x568 for the fieldset and gate, plus forced-colors and reduced-motion runs.
- Existing `issue252` and sign-in specs green.

### 8.3 Skew e2e (mandatory in PR 2)

Run the nine skew runs S1 to S9 defined in section 4.1. Each row there names its fixture and the path it exercises; this section adds the common assertions and procedure.

- Spec tags: the old-schema journeys carry `@skew-old-schema`; S3 uses the stub-view fixture and S4 uses the copied base-commit Edge. Both are restored or removed after the run (drop the stub view and re-apply the migration; restore the new Edge and restart `supabase_edge_runtime`).
- S2 to S5 common assertions: visitors see English with no console errors; the gate is released on error (not on timeout); the owner fieldset shows the state-specific unsupported note from section 5.3; no false success; the language action is never called in S2; a brand-name business save succeeds and persists.
- S6 to S8 (old frontend): build the base-commit frontend, serve it with `vite preview` on a second port, and run against the migrated or rolled-back DB as defined. S6 and S7 seed `default_site_language` to `'es'` and assert it is unchanged after a brand-name save. S8 runs the base-commit sign-in and `issue252` specs unchanged.
- S9: set `'es'`, apply the rollback (value archived), re-apply the migration, run the restore snippet, and assert `'es'`.
- Contract simulation: S5 is a route intercept recorded as such. All other rows use real responses.

### 8.4 Deterministic checks

Zero CSP violations in the console across the gate and cached-default journeys; built `dist/index.html` contains no inline `<script>`; the default-language path never writes `lizbeth.siteLanguage` (storage spy). The CSP assertion compares against the `73fe9f2` CSP (self-hosted fonts, no Google font origins).

### 8.5 Hosted acceptance

Per step H1 to H4 in section 12.

## 9. Browser UI dialog policy

Required. No native `alert`, `confirm`, `prompt`, `window.alert`/`confirm`/`prompt`, or `beforeunload` anywhere in changed source. This feature uses inline status only (no new modal). Every e2e page registers a failing `page.on('dialog')` guard. The existing #252 privacy publish and unpublish modals must still trap focus, close on Escape, and restore focus to their trigger (regression check on Business settings). A deterministic no-native-dialog scan plus `nativeDialogPolicy.test.ts` enforce this.

## 10. Browser validation brief (`browser_ui_validation`)

**Mirror.** Port-shifted untracked mirror following `H:\CommandCenter\orchestrator\lizbeth_spanish-218e-run` (API 64321, DB 64322, studio 64323, shadow 64320; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`; mirror-local `index.html` CSP edit, never committed: re-derive it from the `73fe9f2` `index.html`, where only `connect-src` gains `64321` and the vite websocket origin, and the Google font origins are never reintroduced). Copy PR files per file, never `robocopy /MIR`; never commit the mirror.

**Launch and readiness.**

- `npx supabase start`; `npx supabase db reset`.
- `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish` (the first request may 502).
- `npx vite --host 127.0.0.1 --port 5187 --strictPort` (any free 518x).
- Ready when `http://127.0.0.1:5187` serves the sign-in card and `GET http://127.0.0.1:64321/rest/v1/public_site_settings` with the local anon key returns `[{"default_site_language":"en"}]`.

**Test environment.** `SUPABASE_API_URL=http://127.0.0.1:64321`, `SUPABASE_DB_PORT=64322`, `SUPABASE_SERVICE_ROLE_KEY=<from npx supabase status>`, `E2E_BASE_URL=http://127.0.0.1:5187`. Command: `npx playwright test src/__tests__/e2e/issue187-default-language.spec.ts --project=chromium --workers=1`.

**Base URL.** `http://127.0.0.1:5187`.

**Fixture and reset.** `db reset` plus seed (`owner@test.local`, `student1@test.local`; password "password"). Before and after each test run `update public.owner_settings set default_site_language='en'` via loopback pg (insert the singleton row if absent, like the issue252 spec `:60-67`). Each journey uses a fresh browser context for storage; do NOT use an `addInitScript` that clears localStorage on every navigation for reload journeys. Cached-default and stored-choice states are seeded with context `storageState`. Blocked storage uses `addInitScript` that makes `Storage.prototype.getItem`/`setItem` throw. Delays and failures use `page.route` on `**/rest/v1/public_site_settings*` and `**/functions/v1/owner-settings`.

**Viewports.** 1440x900 and 390x844 for all journeys; 320x568 for the owner fieldset, the gate line and a 400% zoom proxy; one `forcedColors:'active'` run; one `reducedMotion:'reduce'` run.

**Journeys and visible outcomes.**

| Id | Journey and outcome |
|---|---|
| J1 | Owner opens Business settings: legend, helper, both radios, live value checked, no pending line. |
| J2 | Arrow to Español: "1 unsaved change"; Save, "Saving…", "Business settings saved."; reload shows Español; `activeElement` is Save. |
| J3 | Business field plus language: "2 unsaved changes", one success. |
| J4 | Partial failures. Language-only (action 500): alert copy, selection kept, pending 1, business field persists after reload. Site text plus language both fail: one alert naming both. `activeElement` is Save after each. |
| J5 | Skew, referencing runs S2 to S5. S2 read-time view-missing (real `PGRST205`/`42P01`): note `default-language-unsupported`, radios disabled, no success. S3 save-time 503 (real Edge): note `default-language-schema-unavailable`. S4 save-time 400 `Unknown privacy policy action.` (real old Edge): note `default-language-save-unavailable` with the baseline label. S5 save-time 400 `No recognized settings fields were provided.` (route intercept). Save-time cases show the form alert "Business settings were saved, but the default language setting is not available yet. Your selection was not saved." with the selection checked and radios disabled. A brand-name save still shows "Business settings saved." Reload re-probes. A fresh visitor sees English. |
| J6 | Owner read failed (network and timeout): read-failed note, radios disabled, none checked, business save works. |
| J7 | Fieldset loading (delayed read) and saving (delayed action: changes ignored, focus not lost). |
| J8 | First-ever visitor, empty storage, default `es`: "Loading… / Cargando…" then Spanish on `/`, `/courses`, anonymous `/privacy` and the signed-in student shell. A MutationObserver installed at document start (Playwright `addInitScript`) records, for each mutation, `documentElement.lang`, `document.title` and `#root` text. Pass when: (a) before resolution, `#root` contains nothing or only the gate node, whose two spans carry `lang="en"` and `lang="es"`; (b) at the first mutation that inserts non-gate content, `documentElement.lang === 'es'` and the title equals the Spanish-resolved title in that same record; (c) no monolingual English UI text (for example the English sign-in heading, button labels or catalog headings) ever appears; (d) the gate status node is inserted once. The static `lang="en"` during the empty and gate phase is accepted and is not a failure (removing it would violate WCAG 3.1.1, and changing it needs an inline script, prohibited by the CSP). For stored or cached `es` visitors, (b) holds from the very first record because `main.tsx` sets `lang` before render. |
| J9 | Stored `en` plus default `es` gives English, no gate. Stored `es` plus default `en` gives Spanish. `LanguageToggle` `aria-pressed` matches after resolve. |
| J10 | Cached default (valid, unexpired), no stored choice: correct language at first paint, no gate. Stale cache (cached `es`, server `en`): Spanish this load, cache updated, next fresh load English. |
| J10b | Seed cache `es`, apply the rollback (S2 state). Load 1 renders Spanish and the cache is cleared. Load 2 renders English, with the gate behaviour of a first-ever visitor resolved to English. |
| J10c | Expired cache (older than the TTL): treated as none, so the gate applies, and the record is cleared. |
| J11 | Read failure and delay past the timeout give English; a late response does not change the rendered language. |
| J12 | After the owner saves Spanish, SPA-navigate to `/courses` (no stored choice): Spanish without reload. |
| J12b | Delay the view read via `page.route`, save Spanish, then release the stale read. Spanish persists on SPA navigation to `/courses` and in the cache. |
| J13 | `/admin/*` with default `es` and stored `es`: English, no gate. |
| J14 | Keyboard: a single Tab stop into the radio group, arrows change, Tab exits to the Privacy fields, visible focus ring. The accessibility tree shows the legend and helper association, note ids while visible, and `lang="es"` on Español. |
| J15 | 320x568: no horizontal scroll, rows at least 24px (target 44), helper wraps, radio sizing matches the privacy attestation. Gate screenshot at 320. |
| J16 | Forced colors: fieldset ready and checked, and focus ring visible. |
| J17 | Reduced motion: no animation. |
| J18 | Blocked localStorage: the visitor path does not crash; the owner page works. |
| J19 | Network assertion: the language action is never called when not dirty, unsupported or read-failed. |

Plus advisory A4: the unsupported note with a retained Español selection reads coherently.

**Evidence.** Screenshots of the fieldset in ready, loading, unsupported, read-failed and error states at 1440 and 390 (ready also at 320 and forced-colors) and the gate at 1440, 390 and 320; network logs; console logs (zero CSP violations); all under `browser-validation-artifacts/issue-187/`.

## 11. Risks and rollback

| Id | Risk | Control |
|---|---|---|
| R1 | Anon write through an auto-updatable definer-rights view. | Revoke all then grant select only; SQL tests assert DML denied as `anon` and `authenticated`; exact one-column allowlist test; CODE_REVIEW `anon-exposure` rubric. |
| R2 | Hosted `supabase db push` would also apply any other pending migrations (`202610110001` to `202610140001` status Unknown). | H0 read-only migration list first; apply #187 only when every earlier migration is applied, or separately approved and applied in order; never let a push apply unapproved migrations. |
| R3 | Deploying `owner-settings` from `main` also ships any undeployed `main` Edge changes (for example #252 privacy actions, which need the `202610140001` columns). | H2 precondition: hosted `202610140001` applied and the #252 Edge rollout state known; otherwise stop and ask. |
| R4 | First-ever visitors wait up to the timeout (recommend 1500 ms). | The cache (7-day TTL, section 4.2) removes the wait for repeat visitors; the read runs in parallel with auth `getSession`; target under 300 ms; timeout falls back to English. |
| R5 | False save success under skew. | Dedicated action, exact legacy-body matching, read-after-save baseline from the server value. |
| R6 | Generic business save broken under skew. | The field is never in the generic payload; pinned sanitize test. |
| R7 | Stale cache shows the previous default once after an owner change, and after a schema rollback a visitor with cached `es` sees Spanish for at most one more load, then English. | Accepted. The 7-day TTL and the clear-on-zero-rows and clear-on-`unsupported` rules (section 4.2) bound it; J10, J10b and J10c validate. |
| R11 | A stale default read overwrites a newer saved value. | Generation guard in the provider and request sequence in the owner fieldset (section 4.2); J12b validates. |
| R8 | Existing students who never toggled switch to Spanish when the owner selects Spanish. | Intended; helper copy explains; explicit choices unaffected. |
| R9 | Crawlers without JavaScript keep English (`index.html` lang and meta are static). | Accepted non-goal. |
| R10 | Deploy skew in any order. | Skew runs S1 to S9 (section 4.1), each with a named fixture; recommended order is still migration, then Edge, then Netlify. |

Rollback:

- Netlify instant republish of the previous deploy (no data impact).
- Edge redeploy of the previous bundle (optional; the new Edge on an old schema is safe).
- DB rollback script only with separate approval; it archives the value first; the restore snippet applies after re-apply.
- No data loss in any path.

## 12. Hosted rollout (each step separately approved; never bundled)

| Step | Action | Verification |
|---|---|---|
| H0 | Read-only preflight (approval): `supabase migration list` against the linked project; record which of `202610110001` to `202610140001` are applied; record the deployed `owner-settings` Edge version and date. Production read-only preview: `select count(*) from public.owner_settings` (expect 1); confirm the `default_site_language` column and `public_site_settings` view are absent; snapshot an md5 of the row's other columns. | Recorded results. |
| H1 | Apply the #187 migration (approval A), after PR 1 merges, only per R2. | Anon `GET /rest/v1/public_site_settings` returns `[{"default_site_language":"en"}]`; anon PATCH, POST and DELETE on the view denied; anon GET `owner_settings` still denied; md5 of other columns unchanged. |
| H2 | Deploy the `owner-settings` Edge from `main` (approval B), only per R3. | OPTIONS 200; PUT without token 401; unknown action 400 unchanged. The owner smoke of `set_default_site_language` is left for H4. |
| H3 | Merge PR 2 (approval C; merge to `main` triggers the Netlify production build). | In a fresh private window: English (default `en`), no CSP console errors, owner Business settings fieldset ready with English checked. If the migration is not yet applied at this point (skew S2), the fieldset shows the read-time unsupported note and visitors see English. |
| H4 | Owner action (Lizbeth or Rob; not engineering): choose the default. | A fresh private window shows it on `/`, `/courses` and `/privacy`; a browser with an explicit toggle keeps its choice. Record evidence in a Scribe evidence document. |

Recommended order: H0, H1, H2, H3. Any other order remains safe by the skew matrix (section 4.1).

## 13. Decisions

D-L1 is already approved (parent D-19). Approval of this plan is requested for D-L2 to D-L11 as recommended, or amended.

| Id | Decision | Recommendation |
|---|---|---|
| D-L1 | Storage: `owner_settings` column plus anon view (parent D-19, approved). | Confirmed. |
| D-L2 | Projection: a NEW view `public.public_site_settings`, or extend `public_privacy_details`. | New view. Reasons: semantic separation; #252's rollback drops `public_privacy_details` and would silently take the language default with it; #252 SQL tests pin that view's column list; hosted #252 apply status is Unknown and extending would couple the two rollouts; independent rollback. Cost: one more view with the same grant pattern. |
| D-L3 | Write path: a dedicated Edge action `set_default_site_language`, or a field in the generic save. | Dedicated action. Reason: root cause in section 3.4 (false success on an old Edge; whole-save failure on an old schema). |
| D-L4 | First-paint mitigation. | Cached last-known default (separate key, versioned record with TTL, section 4.2) plus a pre-render step in `src/main.tsx` that sets `document.documentElement.lang` from `resolveInitialLanguage()` when the language is already known, plus layout-effect `lang`, title and meta updates, plus a bounded gate for first-ever visitors only, with timeout constant 1500 ms. Rejected: inline bootstrap script (CSP `script-src 'self'`); CSP hash or nonce change (weakens a pinned policy, also desktop CSP); an external head boot script (an extra render-blocking request with no benefit over `main.tsx`, because `#root` is empty until React renders; it also cannot read the owner default synchronously, and a synchronous XHR would block parsing); build-time env default (not owner-editable, needs a deploy per change); Netlify Edge HTML injection (new infrastructure, out of scope); no gate (guaranteed EN-to-ES flash). |
| D-L5 | Late response. | Never switch an already-rendered page; update the cache only, under the generation guard and cache rules of section 4.2. Accept a one-time stale default after an owner change or a schema rollback. |
| D-L6 | Signed-in students. | Follow the same visitor precedence; no server-side per-student language (non-goal). |
| D-L7 | PR split. | Two PRs (data plus Edge, then frontend) rather than one. Reason: the hosted migration is applied from `main` before the UI publishes; smaller reviews. Both reference #187; PR 2 closes it. |
| D-L8 | Hosted rollout order and preconditions. | H0 to H4 with R2 and R3; each step separately approved. |
| D-L9 | Copy. | The English owner copy in section 5 is placeholder. Optional owner wording review before PR 2 merge; recommended: proceed with the drafted copy and revise later without re-design. Revision 1 (J-187-04) already replaced the single unsupported note with three state-specific notes under this permission. |
| D-L10 | View rights model. | Definer-rights view without `security_invoker`, matching #252, with revoke-all plus select-only grants and DML-denied tests as the compensating control. |
| D-L11 | Cache TTL (new in Revision 1). | `SITE_DEFAULT_LANGUAGE_CACHE_TTL_MS` of 7 days (recommended). An expired record is treated as none, so the first-ever-visitor gate applies. |

Remaining decisions for the user: approve the plan and D-L2 to D-L11 as recommended (or amend), and separately approve each hosted step.

## 14. Assumptions, unknowns and approvals

Safe assumptions:

- `owner_settings` stays a singleton.
- PostgREST returns `PGRST205`/`42P01` for a missing view and `PGRST204`/`42703` for a missing column; unknown codes fall back to the safe path.
- The local mirror reproduces hosted behaviour for grants.

Unknowns:

- Whether #268 is the issue or the PR number for the privacy-details work (migration file names it issue252).
- The hosted-applied status of `202610110001` to `202610140001`.
- The deployed `owner-settings` Edge version on hosted.
- Whether the base-commit (PR 1 merge base) `owner-settings` function and its imported `src/lib` files can be copied into the mirror for skew run S4. S5 is a route intercept by design.
- What #273 (`origin/main` `73fe9f2`) changed in the files this plan cites. No local checkout exists at that SHA; Step 0 re-verifies.

Approvals required:

- Explicit user approval of this plan before any T1 dispatch. Scribe updates the status line only on a lead-relayed approval.
- Separate explicit approval for each of H0 to H4 and for any rollback.
- A third judge call needs user approval.

## 15. Stale-plan conditions

The plan is stale and must be re-verified before execution if #273 (`73fe9f2`) changed materially, or if `origin/main` has moved beyond `73fe9f2` and changes any of: `src/context/PublicContentContext.tsx`, the `AuthGate` in `src/App.tsx`, `src/main.tsx`, `src/pages/BusinessSettingsPage.tsx`, `src/pages/OwnerSettingsPage.css`, `supabase/functions/owner-settings/index.ts`, `src/lib/ownerSettingsAuthorization.ts`, `index.html` (CSP), or if a new migration touches `owner_settings`. Line references are valid for `f8a95a3` only and must be re-verified at `73fe9f2` or later.

## 16. Engineering mode and downstream owner

Engineering mode: standard (T1 first-line, T2 escalation; no extreme advisory team). Team authorization: not applicable. Downstream owner: engineering fleet, after explicit user approval of this plan.
