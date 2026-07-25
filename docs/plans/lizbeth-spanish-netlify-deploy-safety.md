# Lizbeth Spanish: Netlify Deploy Safety and Documentation Correction

Status: **Approved by the user, 2026-07-25.** Section 12 must-answer decisions D1-D7 are resolved as recorded in Section 12 below; D8-D11 remain deferrable and open. Phase 1 (Section 7, items 1.1-1.8) is authorized and in execution. Phase 2 and Phase 3 remain gated on their own enforcement and cutover prerequisites as written; nothing in this approval authorizes any deploy, publish, dashboard mutation, or hosted Supabase mutation beyond what Section 7 already marks agent-executable.

Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (separate git repository, remote `git@github.com:lebobo88/lizbeth-spanish.git`, HEAD `5a56398` == `origin/main` at time of writing).

Audience: the solo owner-operator of the Lizbeth Spanish repository, who will personally perform every USER-OWNED dashboard action listed below, plus an engineering agent executing the repository work.

---

## Revision note

This revision supersedes the prior draft of this plan in full. Two things changed materially:

1. **The user has created the hosted Supabase project.** The prior draft's Phase 3 was blocked on that project's existence (tied to production-readiness Bucket B). That premise is now dead. Phase 3 is rewritten below as a fully specified, strictly ordered set of executable gates (G1-G12), not a placeholder.
2. **An advisory `PLAN_DUCK` pass raised six findings (J-001 through J-006).** All six were accepted on the merits. Four are accepted in full; two (J-002 and J-005) are accepted with a refinement, because the originally proposed fix was necessary but not sufficient once cross-checked against a second research pass. See the disposition table in Section 4.

In addition, the second research pass grounding the Supabase hosted-cutover mechanics surfaced **two new critical findings that were not in the judge list and outrank parts of it**:

- **N1** — `supabase config push` is now forbidden during this cutover, because it can silently overwrite the hosted project's Site URL with the repository's current `localhost` value, re-breaking auth after it was correctly configured.
- **N2** — the app's current key-format validation (`validateAnonKeyRole`) requires a legacy JWT and will reject a modern `sb_publishable_...` key outright, which would fail the entire cutover unless resolved by a code change first.

Both are detailed in Section 3 and gate Phase 3 explicitly (see the Phase 3 prerequisite and G5).

Everything else about this plan's authority structure is unchanged: it remains read-only as to `H:\CommandCenter\orchestrator\lizbeth_spanish` at planning time, no commit or push occurs as part of writing this document, and every USER-OWNED marking from the prior draft is preserved, with new ones added for the Supabase dashboard and GitHub settings actions this revision introduces.

## 1. Outcome

Three outcomes, in the user's own stated order:

1. **Correct the documentation** so it stops asserting nothing is deployed.
2. **Stand up an enforcing pre-production pipeline** so an untested build cannot reach the live site. ("Enforcing" is load-bearing: the prior draft left this optional, which `PLAN_DUCK` correctly flagged as J-001. This revision makes at least one enforcement mechanism mandatory.)
3. **Wire the newly created hosted Supabase project to Netlify** and make the site genuinely functional, not just a live shell.

Audience: a solo owner-operator who will personally perform every dashboard, Supabase, and GitHub settings action marked USER-OWNED, plus an engineering agent executing the repository-side work.

## 2. Scope

**In scope:**
- Documentation truth correction.
- Local production-parity build and preview tooling.
- An enforcing pre-merge gate (build-time fail-fast plus a falsifiable post-build assertion).
- `netlify.toml` deploy-context scaffolding.
- A strengthened build-time secret/config guard (additive to the existing leak guard).
- The full hosted-Supabase cutover procedure, with ordered gates, verification, and rollback.

**Non-goals (explicitly excluded from agent execution):**
- Performing any deploy, publish, dashboard change, GitHub settings change, or hosted Supabase mutation. Each such action is either marked USER-OWNED below, or is agent-executable only with explicit per-step approval at execution time as stated in that gate.
- Any user-visible UI change.
- Weakening the existing leak guard (`scripts/check-no-service-role-leak.js`) in any way.
- Committing or pushing.

**No-touch boundary at planning time:** this plan-writing task is read-only as to `H:\CommandCenter\orchestrator\lizbeth_spanish`; no file in that repository has been modified to produce this document.

## 3. Repository findings (evidence)

Findings F1-F7 carry forward from the prior draft, unchanged, with F3 updated to reflect the new hosted-project fact, and a new F8 added.

**F1 — Netlify config is minimal and context-free.** `netlify.toml` lines 1-8: `[build] command = "npm run build"`, `publish = "dist"`, one redirect `/* -> /index.html` status 200. No `[context.*]` blocks, no `[build.environment]`. No `public/_redirects`, no `.github/` CI directory, no `.node-version`/`.nvmrc`.

**F2 — CRITICAL: the production build silently falls back to localhost.** `src/services/supabase.ts` line 18 `const LOCAL_DEFAULT_URL = 'http://127.0.0.1:54321'`; line 20 a hardcoded demo anon key; line 38 `return readEnv('VITE_SUPABASE_URL') || LOCAL_DEFAULT_URL;`; line 42 the same pattern for the anon key. Vite inlines `VITE_`-prefixed values at build time (https://vite.dev/guide/env-and-mode), so an unset variable's fallback is baked permanently into the bundle. `validateAnonKeyRole` (lines 74-101) only rejects a non-`anon` JWT role, and the demo fallback key IS role `anon`, so it passes validation and the client constructs successfully. The site serves a working HTML shell while being functionally dead. A live `index.html` is not evidence of a working application.

**F3 — UPDATED. A hosted Supabase project now exists (user-supplied fact, authoritative); the repository does not yet know about it.** `supabase/config.toml` line 5 `project_id = "lizbeth_spanish"` (a local stack name, not a hosted project ref); line 171 `site_url = "http://127.0.0.1:3000"`; line 175 `additional_redirect_urls = ["https://127.0.0.1:3000"]`; line 238 `enable_confirmations = false`; lines 134-137 declare `[storage.buckets.lesson-assets]` with `objects_path = "./storage-seed/lesson-assets"`. `supabase link` has still never been run. The hosted project ref is not observable from this repository and is a user-confirmation item (Decision D3, "must-answer" group below).

**F4 — The service-role leak guard exists but never runs automatically.** `scripts/check-no-service-role-leak.js` scans `src/` and `dist/` for `VITE_`-prefixed privileged variable NAMES and exits 1 on a hit. `package.json` line 8 `build` is `tsc && vite build` — the guard is not invoked. `netlify.toml` line 2 runs `npm run build` — the guard does not run in the Netlify production build. Documented as a manual command only (`README.md` line 218). No CI runs it.

**F5 — Netlify CLI is absent.** `package.json` lines 20-44 list no `netlify-cli`. Playwright (`@playwright/test` ^1.61.1, line 22) is a devDependency with no npm script. Existing scripts (lines 7-13): `dev`, `build`, `preview`, `test`, `test:ui`, `lint`, `type-check`.

**F6 — The 5176 base-URL mismatch is already resolved.** `playwright.config.ts` line 11 `baseURL: process.env.E2E_BASE_URL || 'http://localhost:5173'`; line 24 `webServer: undefined`. This matches `vite.config.ts` line 7 (`port: 5173`). The `5176` figure does not appear in the file. Stale claims: `docs/plans/lizbeth-spanish-admin-user-management.md` line 88; `docs/plans/lizbeth-spanish-local-content-seeding-and-back-button.md` lines 50, 176, 192. Residual nuance: 5173 is the dev-server port; a production-parity preview runs on a different port (Vite `preview` defaults to 4173).

**F7 — Stale or false deployment claims to correct, with citations:**
- `README.md` line 17: "the codebase is deployment-prepared, but **nothing has been deployed**... no hosted Supabase project or live Netlify site exists yet for it." Both halves are now stale: the Netlify half was already false (site is live), and the Supabase half is now also stale (a hosted project exists, though it is not yet linked or wired — see F3).
- `README.md` line 265 (Bucket C bullet): "the live Netlify build/publish have **not happened**. This application is not deployed anywhere." False as to Netlify; the Supabase items in that bullet are narrower now that a hosted project exists but remain true for linking, migration, storage, and provisioning.
- `README.md` line 3, stack description — accurate, no change.
- `README.md` lines 244-249, "Deployment Readiness" — needs a "What is live" subsection plus a note that a hosted Supabase project exists but is not yet linked or wired (new item 1.8).
- `README.md` line 156 and line 263 (A7 audit) — remain accurate; do not alter.
- `DEPLOYMENT_NOTES.md` lines 13-16 — currently present `supabase config push` as "Option A (Recommended)" for hosted bucket creation. **This recommendation is now unsafe** per N1 below and must be corrected (new item 1.7).
- `DEPLOYMENT_NOTES.md` lines 50-60 — the re-run rule at line 60 is accurate and load-bearing; carried forward unchanged (see J-004 and G9).
- `docs/plans/lizbeth-spanish-production-readiness.md` line 51: "No Netlify configuration exists" — a historical finding, since superseded by the `netlify.toml` addition (F1). Mark superseded, do not rewrite history.
- `docs/plans/lizbeth-spanish-production-readiness.md` lines 129-138, 204, 218 (Bucket C) — the Netlify publish portion has occurred outside that plan's authorization flow; the Supabase portions' premise has also changed now that a hosted project exists. Append a dated addendum; do not delete findings.

**F8 — NEW. The fixture guard in `scripts/provision-lessons.ts` is real and must be preserved and used, not bypassed.** Lines 107-114 enumerate forbidden emails `student1`-`6@test.local`, `fullaccess@test.local`, `owner@test.local`; line 127 the forbidden band name `"Advanced Immersion (Unpublished)"`; line 130 a forbidden resource pattern. Lines 345-364 hard-code the local URL `http://127.0.0.1:54321` and refuse any non-local target unless `PROVISION_LESSONS_ALLOW_REMOTE=true`. `preflightCheck` (line 277) and the post-run verification (documented at lines 10-18) exit 1 on any fixture identifier. **This guard is the mechanism that keeps fixture data out of production. It must be invoked in Phase 3 (G9), and it must never be bypassed, disabled, or worked around.**

**Editorial rule, unchanged and load-bearing:** correct the FACT (Netlify is live and auto-deploys from `main`) without overclaiming FUNCTION (the data layer is unverified and, per F2, currently falls back to localhost). Every corrected passage carries this distinction.

## 4. Research evidence and judge disposition

### 4a. Netlify mechanics (carried forward, R1-R14)

R1-R14 carry forward from the prior draft unchanged: `netlify.toml` authority layers and their limits (R1); the env-var override trap where `netlify.toml` silently supersedes dashboard values (R2); local production-parity options and their caveats (R3); build-time-only env vars (R4); Deploy Previews requiring a PR (R5); branch deploys firing on push with no PR (R6); the exact dashboard path for branch/context configuration (R7); locked deploys mechanics (R8); the "Stop builds" anti-recommendation (R9); per-context env syntax (R10); Netlify's injected build env vars including `CONTEXT` (R11); Playwright `webServer` options (R12); `netlify deploy --prod` vs. draft behavior (R13); and `netlify-cli` install guidance (R14). Full citations: https://docs.netlify.com/build/configure-builds/file-based-configuration/, /build/environment-variables/overview/, https://cli.netlify.com/commands/build/, /commands/serve/, /commands/dev/, /commands/deploy/, https://docs.netlify.com/api-and-cli-guides/cli-guides/local-development/, https://vite.dev/guide/static-deploy, https://docs.netlify.com/deploy/deploy-types/deploy-previews/, /branch-deploys/, https://docs.netlify.com/deploy/manage-deploys/manage-deploys-overview/, https://docs.netlify.com/build/configure-builds/stop-or-activate-builds/, /environment-variables/, https://playwright.dev/docs/test-webserver.

### 4b. Supabase hosted-cutover mechanics (new second research pass, all official sources, accessed 2026-07-25)

**S-A** — Official deployment order: `supabase login`, then `supabase link --project-ref <ref>`, then `supabase db push`. Seed data reaches a hosted project **only** via the explicit `--include-seed` flag. https://supabase.com/docs/guides/deployment/database-migrations

**S-B** — `supabase db push` does **not** create Storage buckets. Documented creation paths: the Dashboard (Storage > New Bucket), a SQL insert into `storage.buckets`, or a client `createBucket()` call. Corroborated in-repo: `supabase/migrations/202607170003_storage_setup.sql` states verbatim that the `lesson-assets` bucket is not created by that migration or by `db push`. https://supabase.com/docs/guides/storage/buckets/creating-buckets

**S-C** — `supabase db push --dry-run` prints the migrations that would be applied without applying them; `supabase db diff --linked` diffs local migrations against the linked project. https://supabase.com/docs/reference/cli/supabase-db-push , /supabase-db-diff

**S-D** — Hosted auth URLs live at Authentication > URL Configuration in the Dashboard. "Site URL" constructs email links and is the default redirect when no `redirectTo` is given. https://supabase.com/docs/guides/auth/redirect-urls

**S-E** — Redirect allow-list supports glob wildcards (`*`, `**`, `?`; separators `.` and `/`). Netlify's documented example is `https://**--my_org.netlify.app/**`. For this site, `https://**--lizbeth-spanish.netlify.app/**` covers deploy previews and branch deploys; production needs its own exact entry `https://lizbeth-spanish.netlify.app/**`. Documented caveat: a wildcard trusts every preview of the site as an auth redirect target, so anyone able to open a PR could receive auth tokens at a URL they control. Same source.

**S-F** — "Confirm email" (Authentication > Providers > Email) is **enabled by default on hosted projects**, while the repo's local config has `enable_confirmations = false` (`config.toml` line 238). https://supabase.com/docs/guides/auth/auth-email

**S-G** — Supabase's built-in email service sends 2 messages/hour, only to pre-authorized project team members, and is explicitly "not meant for production use." Custom SMTP (Authentication > SMTP Settings) raises the default limit to 30/hour. https://supabase.com/docs/guides/auth/auth-smtp , https://supabase.com/docs/guides/platform/going-into-prod

**S-H** — Security Advisor (Database > Security Advisor) publishes lint `0013_rls_disabled_in_public` (ERROR): a public table without RLS is fully accessible to anyone with the project URL; and `0007_policy_exists_rls_disabled` (INFO): a policy exists but is unenforced because RLS is off. https://supabase.com/docs/guides/database/database-advisors

**S-I** — The anon/publishable key is safe in a browser bundle **only in combination with RLS**. Tables created via raw SQL migrations do not get RLS automatically; it must be enabled per table. `service_role` bypasses RLS entirely. https://supabase.com/docs/guides/database/postgres/row-level-security , /guides/api/api-keys

**S-J** — Netlify instant rollback: "Publish deploy" on any prior successful deploy republishes it without a rebuild, and rollbacks are instantaneous. **Critical caveat, verbatim:** "If your site is connected to Git with auto-publishing enabled, new Git-triggered production deploys will overwrite the rolled-back version." https://docs.netlify.com/deploy/manage-deploys/manage-deploys-overview/

**S-K** — Supabase has **no instant migration rollback**. Automatic daily backups are Pro/Team/Enterprise only (7/14/up to 30 day retention); Free-tier projects get none and must export via `db dump`. PITR is a paid add-on requiring at least a Small compute add-on. https://supabase.com/docs/guides/platform/backups

**S-L** — `supabase db reset --linked` resets the linked project to local migrations, drops all user-created remote entities, and reseeds by default unless `--no-seed`. https://supabase.com/docs/reference/cli/supabase-db-reset

**S-M** — Free-plan projects pause after roughly one week of insufficient database activity; current docs state a 1-year restore window from the Dashboard. A 2024 changelog states 90 days — a documented discrepancy, flagged rather than resolved. https://supabase.com/docs/guides/platform/free-project-pausing

**S-N** — Supabase Branching requires Pro+ and is billed per branch-hour, with official GitHub integration documented. No official documentation of Netlify-preview integration was found — treat auto-wiring a branch database into a Netlify preview as **not officially supported**. Pricing figures are volatile; re-verify before quoting. https://supabase.com/docs/guides/deployment/branching

### 4c. Two new critical findings (not in the judge list; outrank parts of it)

**N1 (CRITICAL) — `supabase config push` is forbidden during this cutover.** The command "Updates the configurations of a linked Supabase project with the local `supabase/config.toml` file" (https://supabase.com/docs/reference/cli/supabase-config-push). Auth settings are within its documented remote surface. Official docs publish no authoritative inventory of exactly which sections it writes, and no documented diff or confirmation prompt. Because `config.toml` line 171 currently holds `site_url = "http://127.0.0.1:3000"`, running `config push` in the current repo state must be treated as capable of overwriting the hosted project's Site URL with `localhost`, silently re-breaking auth after it was correctly configured. **Rule for this plan: `supabase config push` is forbidden throughout this cutover.** Hosted auth URLs are set only in the Dashboard (G1). `DEPLOYMENT_NOTES.md` lines 13-16 currently recommend `config push` as "Option A (Recommended)" for bucket creation; that recommendation is now unsafe and Phase 1 corrects it (item 1.7).

**N2 (CRITICAL) — the current key-format validation will reject a modern Supabase key.** Supabase now issues `sb_publishable_...` and `sb_secret_...` keys; legacy JWT anon/service_role keys "will be deprecated by the end of 2026" (https://supabase.com/docs/guides/api/api-keys). `src/services/supabase.ts`'s `validateAnonKeyRole` (lines 74-101) requires a three-segment JWT with a `role` claim equal to `"anon"`. A `sb_publishable_` key is not a JWT and would throw at client construction. Depending on where that throw is caught, the live site either errors outright or is left on the localhost fallback — either way the cutover fails. This must be resolved **before** Phase 3 wiring and requires a code change, not just configuration (Phase 3 prerequisite, Decision D3). This is the single most likely cause of "I set the env vars and it still doesn't work."

### 4d. `PLAN_DUCK` findings disposition

`PLAN_DUCK` ran in shadow/advisory mode against the prior draft and produced six findings. All six are accepted on the merits; four in full, two with a refinement made necessary by the second research pass. No further judge checkpoint is proposed for planning; the orchestrator owns whether to re-run `PLAN_DUCK` on this revision.

| Finding | Severity | Disposition | Evidence |
|---|---|---|---|
| J-001 — production bypass: enforcement left optional | Critical | **Accepted in full.** The prior draft's enforcement was contained in decisions D3/D7, making it advisory. Corrected: at least one enforcement mechanism is now mandatory (Section 7, "Enforcement"). | Prior draft Decisions D3/D7 were phrased as open choices with no required minimum. |
| J-002 — AC4 was unfalsifiable | Major | **Accepted in full; the prior AC4 was wrong.** `resolveUrl()` (`src/services/supabase.ts` line 38) is `readEnv(...) \|\| LOCAL_DEFAULT_URL`, and `LOCAL_DEFAULT_URL` is a module constant at line 18 present in the shipped bundle regardless of whether build-time variables were supplied. Scanning `dist` for `127.0.0.1:54321` cannot distinguish a correct build from a fallback build. Replaced by AC4-new (Section 9). | Direct line citation, `src/services/supabase.ts` lines 18, 38. |
| J-003 — stale sequencing | Critical | **Accepted in full**, now compounded by the hosted project existing. Addressed by the ordered Phase 3 gate sequence (G1-G12). | Prior draft's Phase 3 was gated on a not-yet-existing hosted project; that premise changed. |
| J-004 — storage/provisioning lifecycle | Major | **Accepted in full.** Confirmed against `DEPLOYMENT_NOTES.md` lines 50-60; line 60 carries the re-run rule verbatim in substance: never run `supabase db push`, or any reset/re-seed, after provisioning without immediately re-running the provisioning script, because its writes are live API calls not captured in migrations or seed files. | `DEPLOYMENT_NOTES.md` lines 50-60. |
| J-005 — leak-guard gap | Major | **Accepted, with a refinement that matters.** Confirmed: `scripts/check-no-service-role-leak.js` builds its regex from `VITE_` plus privileged NAME keywords (lines 19-27, 49), so a service-role VALUE pasted into the correctly named `VITE_SUPABASE_ANON_KEY` passes cleanly. The judge's proposed fix (validate by JWT role claim) is necessary but not sufficient given N2: modern `sb_secret_` keys are not JWTs and carry no role claim, so a JWT-only check would miss them entirely. The strengthened guard does **both**: reject any three-segment JWT whose decoded role claim is not `"anon"`, and reject any value matching the `sb_secret_` prefix. Existing name-based detection is retained unchanged; this is purely additive. | `scripts/check-no-service-role-leak.js` lines 19-27, 49; N2 above. |
| J-006 — rollback and hosted cutover validation | Major | **Accepted in full.** Addressed by AC11-AC18 (Section 9) and the blast-radius section (Section 10). | Prior draft had no rollback drill or hosted-specific acceptance checks. |

## 5. Design route

`profile: none`. No user-visible interface or design-system change; this work is documentation, build tooling, configuration, scripts, and a non-visual guard. No design agent or design review was invoked. Explicit caveat: if Decision D3 (key format) or any other item resolves toward a user-visible "backend misconfigured" banner rather than a build-time failure, that is out of scope for this plan and needs a new plan with a design route.

## 6. Judge route

`PLAN_DUCK` ran in shadow/advisory mode on the prior draft and produced J-001 through J-006, disposed above (Section 4d). No further judge checkpoint is proposed for planning. The orchestrator owns whether to re-run `PLAN_DUCK` on this revision before requesting user approval.

## 7. Ordered work

### Phase 1 — Documentation truth correction (agent-executable, no hosted or dashboard action)

Items 1.1-1.6 carry forward from the prior draft unchanged in intent:

1.1 Rewrite `README.md` line 17: Netlify production is live at `https://lizbeth-spanish.netlify.app/` and auto-deploys on every push to `main`; preserve the F2 caveat that the data layer is unverified.

1.2 Rewrite the `README.md` line 265 Bucket C bullet, separating the live Netlify frontend from the remaining Supabase items.

1.3 Add a "What is live" subsection under `README.md`'s "Deployment Readiness" (lines 244+): production URL, auto-deploy-on-`main` trigger, the fact that a git-triggered build leaves no local `.netlify/` directory or deploy log (absence of local evidence is not evidence of no deployment), and the build-time-only nature of `VITE_` vars.

1.4 Add a scoped note to `DEPLOYMENT_NOTES.md` stating the Netlify frontend is live and auto-deploying, without otherwise rewriting the storage/provisioning content.

1.5 Append a dated status addendum to `docs/plans/lizbeth-spanish-production-readiness.md`: line 51 is a historical finding superseded by the `netlify.toml` addition; lines 129-138/204/218's premise has changed (Netlify publish has occurred; a hosted Supabase project now exists but is not yet linked). Do not delete or silently rewrite the original findings.

1.6 Correct the stale 5176 base-URL item at `docs/plans/lizbeth-spanish-admin-user-management.md` line 88 and `docs/plans/lizbeth-spanish-local-content-seeding-and-back-button.md` lines 50, 176, 192, recording the mismatch as resolved by observation (F6).

**1.7 — NEW.** Correct `DEPLOYMENT_NOTES.md` lines 13-16, which currently present `supabase config push` as "Option A (Recommended)" for hosted bucket creation. Per N1, this is unsafe while `config.toml` line 171 holds a localhost `site_url`. Rewrite to recommend the Dashboard path (Storage > New Bucket, private) and carry an explicit warning that `config push` can overwrite hosted auth settings from local values.

**1.8 — NEW.** Update `README.md` to record that a hosted Supabase project now exists but is not yet linked or wired, preserving the fact/function distinction.

**Editorial rule, unchanged and load-bearing:** correct the FACT without overclaiming FUNCTION. Every corrected passage carries that distinction.

### Phase 2 — Enforcing pre-production pipeline (repository work is agent-executable; enforcement itself is USER-OWNED)

2.1 Add a `test:e2e` npm script and a production-build preview gate. Add `preview:prod` running `vite preview --port 4173 --strictPort`. Make `playwright.config.ts`'s `webServer` conditional: `E2E_BASE_URL` unset runs `npm run build && npm run preview:prod` against `http://localhost:4173`; `E2E_BASE_URL` set leaves `webServer` undefined so the suite can target a deploy-preview URL. Keep `reuseExistingServer: !process.env.CI`; raise `timeout` to 120000.

**2.2 — REPLACES the prior 2.2 (this is the J-002 fix and absorbs the former Decision D4).** Implement a falsifiable build-configuration check with two parts:
  (a) a build-time fail-fast that **aborts** a production-context build when `VITE_SUPABASE_URL` or `VITE_SUPABASE_ANON_KEY` is unset or resolves to a localhost/`127.0.0.1` host, branching on Netlify's `CONTEXT` env var so local and preview builds are unaffected;
  (b) a positive post-build assertion that the built bundle **contains** the expected hosted Supabase project ref (the `<ref>.supabase.co` host, supplied as an expectation to the check).
  Part (b) is genuinely falsifiable: that string can only appear if the variable was actually supplied at build time, whereas the localhost constant appears unconditionally (per J-002's finding).

2.3 Strengthen `scripts/check-no-service-role-leak.js` additively (the J-005 refinement): retain every existing pattern, both scans, and exit-1 behavior unchanged; ADD value-based detection that (i) decodes any three-segment JWT found in a `VITE_`-prefixed assignment and fails if its role claim is not `"anon"`, and (ii) fails on any value matching the `sb_secret_` prefix. Add a `verify:build` composite script: build, then the strengthened leak guard, then the 2.2 checks.

2.4 Add `netlify.toml` `[context.deploy-preview]` and `[context.branch-deploy]` blocks. Populate their `.environment` tables with the non-production Supabase target only if Decision D9 (deferrable) selects a staging project; otherwise leave the blocks present but unpopulated with a comment. In both cases include a comment recording the R2 trap: `netlify.toml` env vars override same-key Netlify UI values, so production keys must never appear here.

2.5 Document the local production-parity workflow in `README.md`, including supplying `VITE_SUPABASE_URL`/`VITE_SUPABASE_ANON_KEY` via a gitignored `.env.local`. Verify `.gitignore` actually covers `.env.local`; add it if missing.

2.6 Add a deep-route check to the gate: request `/roadmap` directly against the served build, assert HTTP 200 plus index.html. Record honestly that under `vite preview` this exercises Vite's own SPA fallback, not the `netlify.toml` catch-all; only a Netlify-CLI-served build exercises the `/*` rule.

**2.7 — NEW.** Make `netlify.toml`'s build command call `verify:build`, so the guards run on every Netlify build (closes the former Decision D5 in favor of enforcement, per J-005). Accepted tradeoff: a guard defect can block a production deploy — the intended failure direction for a security/configuration guard.

### Enforcement (USER-OWNED, and non-optional — the J-001 fix)

The user must adopt **at least one** of the following before Phase 3. The plan's recommended path is **E1 plus E2 together**.

- **USER-OWNED E1 (recommended, required in the default path)** — Netlify locked production deploys. On the site's Deploys page, "Lock to stop auto publishing." `main` still builds and is verifiable; promotion becomes an explicit "Publish deploy" click. Also the prerequisite for rollback surviving (S-J: with auto-publishing on, the next push to `main` silently overwrites a rollback).
- **USER-OWNED E2 (recommended)** — GitHub branch protection on `main` in `lebobo88/lizbeth-spanish` settings: require a pull request before merging, and require the pre-merge status check to pass. This is what makes the branch/PR workflow actually enforcing rather than advisory; Deploy Previews only exist when a PR is opened.
- **USER-OWNED E3 (alternative)** — Change the Netlify production branch away from `main`, so pushing `main` can no longer publish. Project configuration > Build & deploy > Continuous Deployment > Branches and deploy contexts > Configure.

**Adopting none of E1/E2/E3 leaves a direct push to `main` auto-publishing an untested build, which defeats the entire purpose of this plan.**

**USER-OWNED anti-recommendation, carried forward:** do not use "Stop builds" — it disables production deploys AND Deploy Previews AND branch deploys and would destroy the previews this plan depends on.

### Phase 3 — Hosted Supabase cutover (now fully specified and executable)

Strictly ordered gates. Each gate has a pass condition; do not proceed on failure. Owner is marked per step.

**Prerequisite (blocking).** Resolve Decision D3 (key format). If the hosted project issues `sb_publishable_` keys, `src/services/supabase.ts`'s `validateAnonKeyRole` must be updated to accept both the legacy JWT-anon shape and the `sb_publishable_` shape, and continue rejecting anything else, **before any wiring**. Otherwise the cutover cannot succeed (N2).

- **G1 — USER-OWNED, Dashboard.** Authentication > URL Configuration. Set Site URL to `https://lizbeth-spanish.netlify.app`. Set Redirect URLs to include `https://lizbeth-spanish.netlify.app/**` and, if Decision D4 permits, `https://**--lizbeth-spanish.netlify.app/**` for previews, plus `http://localhost:5173/**` and `http://localhost:4173/**` for local work. **Must happen before any Netlify env var is set (G10).** Violating this order means every signup or password reset in that window emails a localhost link the recipient can never use, and those emails cannot be recalled — non-rollbackable user harm.
- **G2 — USER-OWNED, Dashboard.** Decide and set the Confirm-email posture (Authentication > Providers > Email) and configure custom SMTP (Authentication > SMTP Settings) before any real user signs up. Per S-G, the built-in service sends 2/hour, only to project team members; real signups fail at the email step without custom SMTP. Practical trap: with Confirm email on by default, a newly provisioned owner/instructor account cannot sign in until confirmed, and the confirmation email only delivers to a team-member address unless custom SMTP is configured first.
- **G3 — Agent-executable with user-supplied credentials.** `supabase login`, then `supabase link --project-ref <ref>`. The ref is a user-confirmation item (part of Decision D3). `link` writes gitignored local state under `supabase/.temp/`; the exact filename is not officially documented — do not assert it.
- **G4 — GATE.** `supabase db push --dry-run`. Pass condition: output lists exactly the expected migrations from `supabase/migrations/` and nothing else. Review before proceeding.
- **G5 — Agent-executable.** `supabase db push`. **Forbidden by name, under any circumstances:** `--include-seed` (would inject `supabase/seed.sql`'s `@test.local` accounts and the "Advanced Immersion (Unpublished)" fixture band into production — S-A) and `supabase db reset --linked` (drops all user-created remote entities and reseeds by default — S-L). **Also forbidden:** `supabase config push` (N1). On Free tier, take a `supabase db dump` immediately before this step; per S-K it is the only rollback that exists.
- **G6 — GATE, verification.** `supabase db diff --linked` returns empty (no drift). Then Dashboard > Database > Security Advisor must report **zero** `0013_rls_disabled_in_public` and **zero** `0007_policy_exists_rls_disabled` findings. Do not proceed while any `0013` finding exists: per S-I a public table without RLS is world-writable by anyone holding the project URL and the publishable key, which this plan is about to ship into a browser bundle.
- **G7 — USER-OWNED or agent-with-approval.** Create the `lesson-assets` Storage bucket, **private**. Per S-B and the in-repo migration comment, `db push` does not create it. Recommended path: Dashboard > Storage > New Bucket. Alternative: `supabase seed buckets --linked`, which also uploads every file under `./storage-seed/lesson-assets` into production storage — this alternative is Decision D5 and needs explicit approval before use.
- **G8 — GATE, fixture-leak verification before any wiring.** Run a read-only check against the hosted project confirming zero rows in `auth.users` matching `%@test.local` and that the band "Advanced Immersion (Unpublished)" is absent. This is the hard requirement's checkpoint.
- **G9 — Agent-executable with approval, content provisioning.** Per J-004 and `DEPLOYMENT_NOTES.md` lines 50-60, the order is: migrations current (G5), bucket created (G7), then `scripts/provision-lessons.ts` against the hosted target with `PROVISION_LESSONS_ALLOW_REMOTE=true`. Its preflight (line 277) and post-run fixture verification must both pass; neither may be bypassed or disabled. **Re-run rule, recorded prominently, quoting `DEPLOYMENT_NOTES.md` line 60 in substance:** never run `supabase db push`, or any reset/re-seed that runs migrations, after provisioning without immediately re-running the provisioning script, because the script's writes are live API calls not captured in migrations or seed files. The script is idempotent specifically so re-running is the safe recovery action.
- **G10 — USER-OWNED, Netlify.** Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in the Production context. Per R4 these are build-time only and take effect only on a new build and deploy. Ensure deploys are locked (E1) before triggering, so the resulting build does not auto-publish.
- **G11 — GATE, smoke test on a non-production artifact before publishing.** Trigger the build and verify the resulting deploy at its unique deploy URL or a deploy-preview URL — **not** the live origin — running the browser validation journeys (Section 14). Only after that passes does the user click "Publish deploy." This is the step that makes the cutover reversible.
- **G12 — Record.** Record the previous production deploy ID before publishing, so the instant rollback path is known and available.

## 8. Interfaces and data

No application API or component contract changes. Changed surfaces: `package.json` scripts; `playwright.config.ts` `webServer`/`baseURL` handling; `netlify.toml` build command and context blocks; `scripts/check-no-service-role-leak.js` (additive only); new build-check scripts; possibly `.gitignore`; and, contingent on Decision D3, `src/services/supabase.ts` key validation. Database: existing migrations under `supabase/migrations/` are applied to the new hosted target unchanged; no new migration is authored by this plan. Backward compatibility: `playwright.config.ts` must keep honoring `E2E_BASE_URL`; `netlify.toml`'s existing `/*` catch-all must not change behavior.

## 9. Acceptance criteria and validation

- **AC1** — `npm run build`, `npm run type-check`, `npm run lint` all pass clean.
- **AC2** — The strengthened leak guard's existing detection is provably unchanged (same patterns, same `src/`/`dist/` coverage, same exit-1), verified by diff review, not claim. New detection is additive only.
- **AC3** — `verify:build` runs build, strengthened leak guard, and the 2.2 checks, and exits non-zero if any stage fails.
- **AC4-new (REPLACES the withdrawn AC4; the J-002 fix; must be demonstrated in both directions):**
  (a) a production-context build with `VITE_SUPABASE_URL` unset aborts with a clear error rather than producing a bundle;
  (b) a production-context build with `VITE_SUPABASE_URL` set to a localhost/`127.0.0.1` host aborts;
  (c) a build with both variables set to the hosted values succeeds, and the post-build assertion confirms the expected `<ref>.supabase.co` host is present in the built bundle;
  (d) explicitly record that the withdrawn check (scanning `dist` for `127.0.0.1:54321`) is not a valid signal, because that constant ships unconditionally from `src/services/supabase.ts` line 18.
- **AC5** — `npm run test:e2e` with `E2E_BASE_URL` unset builds, serves the production bundle, and runs the Playwright suite against it.
- **AC6** — `E2E_BASE_URL=<url> npm run test:e2e` runs the same suite against that URL without starting a local server.
- **AC7** — The existing vitest suite passes, including `src/__tests__/nativeDialogPolicy.test.ts`.
- **AC8** — A deep client route (`/roadmap`) requested directly against the served production build returns HTTP 200 and index.html.
- **AC9** — Every documentation correction is verified against the cited file and line; no corrected passage asserts the live site is functional.
- **AC10** — Verifier confirms no unauthorized hosted mutation, no deploy, no publish, no commit, no push, and no dashboard change by any agent.
- **AC11 — NEW, leak-guard efficacy.** A synthetic value carrying a non-`anon` JWT role claim assigned to `VITE_SUPABASE_ANON_KEY` is detected and fails the guard. A synthetic `sb_secret_`-prefixed value is detected and fails. Both must be demonstrated, since the pre-existing name-based guard passes both.
- **AC12 — NEW, enforcement is real.** With E1 adopted, demonstrate a build produced from `main` is not auto-published and requires an explicit publish action.
- **AC13 — NEW, schema gate.** `supabase db diff --linked` returns empty and Security Advisor reports zero `0013` and zero `0007` findings.
- **AC14 — NEW, fixture isolation.** Zero `auth.users` rows matching `%@test.local` and no "Advanced Immersion (Unpublished)" band exist on the hosted project, verified both before wiring (G8) and again after provisioning (G9 post-run check).
- **AC15 — NEW, auth cutover.** A real end-to-end signup against the verified deploy produces a confirmation email whose link host is `lizbeth-spanish.netlify.app`, not localhost. Use a team-member address if custom SMTP is not yet configured.
- **AC16 — NEW, RLS behavior end-to-end.** An authorized user retrieves a gated lesson asset via signed URL; an unauthorized user is denied. The negative check is required; a passing positive alone is not acceptance.
- **AC17 — NEW, storage.** The `lesson-assets` bucket exists on the hosted project and is private.
- **AC18 — NEW, rollback drill.** Before publishing, the previous production deploy ID is recorded, its detail page and "Publish deploy" button are confirmed reachable, and the user demonstrates understanding that with auto-publishing unlocked the next push to `main` would silently overwrite a rollback.

## 10. Risks, rollback, and blast radius

Carried forward from the prior draft: a `netlify.toml` env key silently overriding a working production value; documentation overclaiming function; `netlify-cli` dependency weight; `netlify serve` redirect behavior being implied rather than documented; locked deploys changing release to a manual click; a slow rebuild-per-run gate. Mitigations and rollback for each are unchanged from the prior draft's risk table.

**Blast radius if Phase 3 goes wrong mid-cutover:**

- **Asymmetric rollback.** A Netlify rollback republishes a previous artifact instantly without rebuilding, but because Vite inlines `VITE_` values at build time, rolling back the frontend reverts it to the **previous** Supabase binding baked into that artifact. It does **not** roll back applied Supabase migrations. Frontend and backend roll back independently and at different speeds.
- **Rollback is defeated by auto-publish.** Per S-J, with auto-publishing enabled, the next Git-triggered production deploy overwrites the rolled-back version. Locking deploys (E1) is a rollback prerequisite, not merely a workflow preference.
- **No Supabase rollback on Free tier.** Per S-K, no automatic daily backups on Free and no PITR. A bad migration is recoverable only via a hand-written down migration or a `db dump` taken immediately before the push. That dump is a required step while on Free (see G5).
- **Irreversible failure modes**, stated plainly as the two things a rollback cannot fix: (1) fixture data reaching production, and (2) confirmation or password-reset emails already sent carrying localhost links. Both are prevented only by ordering (G1 before G10) and by the fixture gates (G8, G9), never by rollback.
- **Free-tier pausing.** Per S-M, a Free project pauses after roughly a week of insufficient activity; a paused backend means the live site starts failing. A low-traffic instructor site is a realistic candidate. Feeds Decision D6.
- **Mid-cutover summary:** between G10 and G11 the live site still serves the OLD artifact, so exposure is limited to whatever is published at G11. Publishing without the G11 smoke test is what converts a contained change into a live outage.

## 11. Assumptions

- The working tree at HEAD `5a56398` is the state under discussion.
- The Netlify site name is `lizbeth-spanish`, per the production URL.
- The Supabase publishable/anon key is public by design and safe in a bundle only in combination with RLS.

**Resolved and removed from the decision list, with reason recorded:** the former Decision D3 (adopt locked deploys) and D7 (branch/PR convention) from the prior draft are resolved into the mandatory Enforcement subsection per J-001; the former D4 (build-time fail-fast) is resolved to YES, because it is the mechanism that makes the build check falsifiable per J-002; the former D5 (guards in the Netlify build) is resolved to YES per J-005; the former D9 (sequencing) is resolved by the user's explicit order — documentation, then pipeline, then hosted wiring. (Decision numbers below are renumbered for this revision and do not correspond to the prior draft's numbering.)

## 12. Open decisions

Split into two groups. The must-answer group blocks implementation of the affected work items; the deferrable group does not block implementation start.

### Must be answered before implementation starts

- **D1** — Dashboard and settings facts not observable from the repository. Netlify: are `VITE_SUPABASE_URL`/`VITE_SUPABASE_ANON_KEY` currently configured in the build environment and what do they point at; current production branch; Deploy Previews enabled; branch deploys enabled and for which branches; deploys currently locked; account plan tier. Supabase: hosted project ref; plan tier; whether Confirm email is on; whether custom SMTP is configured. GitHub: whether branch protection exists on `main`. The documentation correction's accuracy depends on the first Netlify item.

  **RESOLVED, 2026-07-25.** The user confirmed `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are NOT currently set in the Netlify build environment. This makes F2's finding definitive rather than probable: the live production site at `https://lizbeth-spanish.netlify.app/` is currently a non-functional shell whose client falls back to `http://127.0.0.1:54321` in the shipped bundle. The hosted Supabase project ref is `udrlwexyzaqaqxdxdsml`, on the Free plan tier. Remaining D1 items (production branch, Deploy Previews/branch deploys status, lock status, Confirm-email/SMTP posture, GitHub branch protection) remain unconfirmed and are not required to unblock Phase 1.
- **D2** — Which enforcement mechanism does the user adopt: E1 alone, E2 alone, E1+E2 (recommended), or E3? At least one is required; adopting none is not an acceptable outcome.

  **RESOLVED, 2026-07-25.** The user adopts E1 + E2 together, the plan's recommended path: Netlify locked production deploys, plus GitHub branch protection on `main` in `lebobo88/lizbeth-spanish` requiring a pull request and a passing pre-merge status check before merge. Both remain USER-OWNED dashboard/settings actions per Section 7's Enforcement subsection; this decision does not itself perform them.
- **D3** — Key format (blocking Phase 3, per N2). Does the hosted project issue legacy JWT anon keys or `sb_publishable_` keys? If the latter, approve the code change to `src/services/supabase.ts`'s `validateAnonKeyRole` to accept both shapes while continuing to reject everything else. Without this the cutover cannot succeed. (Includes confirming the project ref for G3.)

  **RESOLVED, 2026-07-25.** The hosted project (ref `udrlwexyzaqaqxdxdsml`) issues `sb_publishable_` keys, not legacy JWT anon keys. The user approved the code change to `validateAnonKeyRole` in `src/services/supabase.ts` to accept both the legacy JWT-anon shape and the `sb_publishable_` shape while continuing to reject everything else, per the Phase 3 prerequisite. This is Phase 2/3 repository work, not Phase 1 documentation, and is not implemented by this Phase 1 pass; it is recorded here as an approved decision gating Phase 3's prerequisite step.
- **D4** — Redirect allow-list scope. Include `https://**--lizbeth-spanish.netlify.app/**` to let deploy previews authenticate, accepting the documented risk that this trusts every preview as an auth redirect target (anyone able to open a PR could receive auth tokens at a URL they control)? Or restrict to the exact production origin, accepting that previews cannot exercise authenticated journeys?

  **RESOLVED, 2026-07-25.** Include `https://**--lizbeth-spanish.netlify.app/**` in the Supabase redirect allow-list, so deploy previews can exercise authenticated journeys. Rationale, recorded explicitly: `lebobo88/lizbeth-spanish` is a single-maintainer, private repository, so the documented risk (anyone able to open a PR could receive auth tokens at a preview URL they control) does not apply under the current access model. This decision should be revisited if the repository ever gains additional contributors with PR access, at which point the wildcard trust assumption would no longer hold.
- **D5** — Bucket creation method. Dashboard > Storage > New Bucket (private, recommended), or `supabase seed buckets --linked`, which also uploads every local file under `./storage-seed/lesson-assets` into production storage?

  **RESOLVED, 2026-07-25.** Use the CLI, `supabase seed buckets --linked`, to create the `lesson-assets` bucket. **New preflight requirement added to G7:** before running this command, enumerate the contents of `./storage-seed/lesson-assets` and confirm every file is genuine authored lesson content with no test fixtures, because this command uploads the entire directory into production storage as a side effect of bucket creation. If any fixture file is present, stop and return to the user rather than proceeding or filtering silently.
- **D6** — Plan tier before go-live. Accept Free (no daily backups, no PITR, no branching, pauses after roughly a week of inactivity, taking the live site down) or upgrade to Pro? Directly determines whether any Supabase rollback exists.

  **RESOLVED, 2026-07-25.** Stay on the Supabase Free tier for now. The user is aware of and accepts the consequences already established in Section 4b/10: no automatic daily backups (S-K), no PITR without a paid compute add-on (S-K), no rollback beyond a manually taken `db dump` immediately before a risky operation (G5), and pausing after roughly a week of database inactivity (S-M), which takes the live site down until manually restored from the Dashboard. This is a reversible decision and can be revisited by upgrading to Pro later.
- **D7** — `netlify-cli` as a devDependency for true Netlify-parity local builds and redirect-accurate serving, versus staying dependency-free with `vite preview`, accepting that the `netlify.toml` catch-all and Netlify context env vars are not exercised locally.

  **RESOLVED, 2026-07-25.** Add `netlify-cli` as a devDependency, for true Netlify-parity local builds and redirect-accurate serving. This is Phase 2 repository work, not implemented by this Phase 1 pass. It resolves D11's dependency: D11 (canonical Playwright port/mode for the parity gate) now follows the Netlify-CLI-served build path (port 8888 via `netlify serve --context production`) rather than the bare `vite preview` path (port 4173), since D7 makes the Netlify-CLI option available. D11 itself remains open and deferrable pending final selection, but is no longer blocked on whether `netlify-cli` exists in the project.

### Deferrable — can be answered later without blocking implementation

- **D8** — Provision a `NETLIFY_AUTH_TOKEN` for agent-run CLI builds and draft deploys, or keep all Netlify CLI use manual and owner-run? Only relevant if D7 is yes.
- **D9** — Non-production backend for previews: a second Supabase project as staging (lets preview builds exercise authenticated journeys without touching production data), Supabase Branching (Pro-only, usage-billed, no official Netlify deploy-preview integration), or neither for now (previews validate build, shell, and routing only). Until answered, deploy previews cannot verify authenticated journeys.
- **D10** — Custom SMTP provider selection. Required before real users sign up, not before implementation begins.
- **D11** — Canonical Playwright port and mode for the parity gate: `vite preview` on 4173, or a Netlify-CLI-served build on 8888. Follows from D7. The old 5176 figure is obsolete per F6.

  **Note, 2026-07-25.** D7 is resolved (adopt `netlify-cli`). D11 remains open, but with `netlify-cli` now approved as a devDependency, the Netlify-CLI-served build on port 8888 is the available and recommended parity mode; final selection is deferred to Phase 2 implementation.

## 13. Browser UI dialog policy

Required and preserved unchanged. No native `alert`, `confirm`, `prompt`, any `window.*` form, or `beforeunload` may be introduced. Current state verified clean in product code under `src/`: the only occurrences are the deterministic policy test `src/__tests__/nativeDialogPolicy.test.ts`, a component assertion in `RegisterStudentModal.test.tsx`, a `beforeunload` assertion in `weekDetailBackLinkStyling.test.ts`, and an unrelated `javascript:alert(1)` XSS fixture string in `ownerSettingsAuthorization.test.ts`. Any acknowledgement or confirmation surface remains an app-owned accessible modal (the existing `Modal`/`RegisterStudentModal` pattern) with focus trap, Escape and cancel, focus restored on close, and an accessible name, or inline validation where that serves the user better. `nativeDialogPolicy.test.ts` stays green and stays in the pre-merge run.

Automation rationale, retained: Playwright auto-dismisses native dialogs by default, so a native dialog would let an E2E gate silently pass over a blocked flow — a zero-native-dialog codebase is precisely what makes this plan's gate trustworthy.

**Added this revision:** if Decision D3 or the 2.2 fail-fast ever grows a user-facing "backend misconfigured" surface, it must be an app-owned modal or inline state, never a native dialog — and per the Section 5 design-route note, that would need a new plan.

## 14. Browser UI validation

Required — supplied in full, now covering the hosted cutover smoke test.

**Launch/readiness, local parity mode:** `npm run build` then `npm run preview:prod` (`vite preview --port 4173 --strictPort`); ready when the URL returns HTTP 200. Netlify CLI alternative if D7 selects it: `netlify serve --context production --port 8888`. For data-dependent journeys locally: `supabase start` then `supabase db reset`.

**Base URL:** `http://localhost:4173` (or `http://localhost:8888`), determined by D11. For the hosted cutover gate G11: the specific deploy URL or deploy-preview URL of the candidate build, supplied via `E2E_BASE_URL` — explicitly **not** the live production origin, because the whole point of G11 is to verify before publishing. The obsolete `5176` value must not be used; 5173 is the dev-server port and is not a production-parity target.

**Fixture/reset — local only.** `supabase db reset` restores migrations plus `supabase/seed.sql` fixtures and `supabase/seeds/full-catalog.sql`, and repopulates the local `lesson-assets` bucket from `supabase/storage-seed/`. Seeded accounts: `student1`-`student6@test.local` and `owner@test.local`. Reset before each local validation run. **Never** run any reset, seed, or provisioning command against the hosted target outside the G9 procedure with its guards intact.

**Journeys:**
1. Load the base URL; confirm the app shell renders with its real title.
2. Sign in as a seeded student; reach the roadmap.
3. Open a week detail view; confirm lesson content and resources load.
4. Request a deep client route directly (`/roadmap`, and `/roadmap/:enrollmentId/week/:n`) as a fresh navigation; confirm HTTP 200 with the correct view rather than a 404.
5. Reload that deep route to confirm refresh survives.
6. Confirm the browser console shows no failed request to `127.0.0.1:54321` — the direct observable signature of the F2 fallback.
7. **NEW, hosted only.** Complete a signup and confirm the resulting email's link host is `lizbeth-spanish.netlify.app`, not localhost.
8. **NEW, hosted only.** Confirm an authorized user can open a gated lesson asset and an unauthorized user cannot.

**Viewport profiles:** 1440x900 desktop and 390x844 mobile. Both required.

**Visible outcomes:** app shell renders with title "Lizbeth Spanish Course Platform"; authenticated navigation reaches the roadmap with real enrollment data; a week detail view shows its lesson title and resource list; deep-link and refresh render the correct view with no 404; no native browser dialog appears at any point; no console request targets `127.0.0.1:54321`; the gated-asset negative check denies the unauthorized user; layout reflows at both viewports with no horizontal scroll.

**Scope limits, stated honestly:** journeys 2, 3, 6, 7, and 8 require a working backend. Against a deploy-preview URL they can only pass once D9 provides a non-production backend; until then a preview validates build, shell, and routing only (journeys 1, 4, 5), and a partial preview pass must never be reported as functional verification. Journeys 7 and 8 run only at G11 against the candidate hosted deploy.

## 15. Approval gate

This plan requires explicit user approval before any execution begins, including Phase 1 documentation edits. Upon relayed user approval, this status header must be updated to "Approved" before T1/Scribe execution starts. The must-answer decisions in Section 12 gate their affected work items and should be resolved as part of, or immediately following, that approval; the deferrable decisions may be resolved later without blocking implementation start.

**Approval recorded, 2026-07-25.** The user approved this plan and resolved decisions D1-D7 as recorded in Section 12. Phase 1 (Section 7, items 1.1-1.8) is authorized and executed by Scribe under this approval. Phase 2 and Phase 3 remain unimplemented by this pass and route through the standard T1/T2 engineering fleet per Section 16, subject to the Enforcement subsection (Section 7) and the Phase 3 ordered gates, both unchanged by this approval.

## 16. Engineering mode and ownership

`engineering_mode: standard`. `team_authorization: not applicable`. `downstream_owner: engineering-fleet`. Phase 1 document edits are Scribe-owned at execution time; Phase 2 and Phase 3 repository-side steps route through the standard T1/T2 engineering fleet, subject to the same no-touch boundary on hosted mutations without explicit per-gate approval, and the same prohibition on any deploy, publish, commit, or push by any agent.
