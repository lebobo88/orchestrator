# Plan: Owner-editable site text with optional Spanish (lizbeth-spanish issue #177)

**Status:** APPROVED by the user on 2026-10-03 (all four approved together in the orchestrator session). Cleared for engineering per this plan. See the Approval record at the end of this document for the limits of that approval.

- Plan ID: `lizbeth-spanish-issue177-owner-editable-site-text`
- Plan path: `docs/plans/lizbeth-spanish-issue177-owner-editable-site-text.md`
- Route: engineering (non-basic)
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (its own git repo; default branch `main`; GitHub `lebobo88/lizbeth-spanish`)
- Tracking: GitHub issue `lebobo88/lizbeth-spanish#177` "Owner-editable site text (landing, catalog, brand chrome) with optional Spanish" (epic #172)
- Planning date: 2026-10-03
- Engineering mode: standard
- Downstream owner: Engineering Fleet (T1 implements; T2 on counted gate failures)

## 1. Outcome and audience

The course owner can edit, disable (hide), or blank every non-course, non-functional site string from the existing admin screens Business settings (`/admin/business-settings`) and Brand & design (`/admin/brand-design`), with an optional Spanish value per key. Anonymous visitors (sign-in page, `/courses`) and signed-in students see the owner's text in the language they choose through a public English/Español toggle. With no owner overrides, every page renders byte-identical to today.

Audiences: the owner (editor), anonymous visitors, students, and the Engineering Fleet (T1 implementer, Verifier, Browser Validator).

## 2. Scope and non-goals

### In scope (user decisions, final)

1. Singleton `owner_settings` fix first (approved).
2. New `site_content` storage plus a narrow anonymous read path (approved; reverses migration `202607250002` for site copy only).
3. A code registry of editable keys whose defaults equal today's literals.
4. An owner-gated write Edge Function.
5. A `PublicContentProvider` mounted above `AuthGate`.
6. Admin form groups in `BusinessSettingsPage` and `BrandDesignPage`.
7. Wiring every in-scope literal in the key inventory (section 8), including `Field Journal`, student page eyebrows, headings, intros and empty states, the `78 weeks / Three volumes / A1 to C1` text, the roadmap ledger label and footnote, and the page `<title>` and meta description (runtime `document.title` and meta update).
8. Public es/en language choice through one `LanguageToggle` component with three render sites: the anonymous sign-in panel and `/courses` header, the authenticated desktop app header, and the mobile navigation panel (non-admin routes only). The authenticated toggle is in scope (PLAN_DUCK J-PLAN-001; formerly decision D4).
9. Wiring bug fix: the hardcoded eyebrow at `AdminShell.tsx:118` binds to `branding.brand_name`.
10. Tests, browser validation, and a user-gated production migration.

### Non-goals

- Course content: titles, descriptions, lessons, `course_title`, week content.
- Functional text: navigation labels, button labels, form labels, validation, error, status and loading messages, enrollment result messages.
- Admin chrome H1s and eyebrows: `Owner desk`, `Business settings`, `Brand & design`, `Owner desk · Business`. `/admin/*` routes get no language toggle and stay English.
- The `BrandDesignPage` static preview block (`:85-95`), locked static by `docs/plans/lizbeth-spanish-issue43-brand-catalog-screens.md`.
- Decorative `L` monogram glyphs (`App.tsx:666`, `PublicCatalogPage.tsx:113`, `BrandLogo.tsx:31`, `BrandDesignPage.tsx:86`), which are aria-hidden decoration. Deferred to a follow-up issue (decision D6): `App.tsx:666` is a fixed-position SVG `<text>` (x=28, y=38, `text-anchor` middle in a 56×56 viewBox) with no auto-fit, and one shared key would carry that overflow risk to `PublicCatalogPage.tsx:113` and `BrandLogo.tsx:31`. The `BrandDesignPage.tsx:86` static preview stays static (issue43 lock).
- Translating the admin UI.
- Machine translation or fabricated Spanish defaults. All Spanish defaults are empty.
- Rich text, HTML, or markdown.
- Server-side rendering or SEO prerendering.
- Exposing `owner_settings` itself to anonymous users.
- Electron desktop packaging changes.
- The pre-existing `PublicCatalogPage.css` forced-colors gap (separate ticket). Only a `.lang-toggle`-scoped forced-colors block is added there.
- New default meta description wording, an owner-configurable default language for first-time visitors, and a brand-bound sign-in fallback heading (`Sign in to <brand_name>`). All are follow-up issues (section 14).

## 3. Repository findings and evidence references

Planner verified these at file level on 2026-10-03. All paths are relative to `lizbeth_spanish/`.

### 3.1 Public and authenticated surfaces

| Surface | Evidence | Finding |
| --- | --- | --- |
| Sign-in brand panel | `src/App.tsx:654-695` | SVG `L` mark `:666`; wordmark `Lizbeth Spanish` `:669`; line 2 `Field Journal` `:670`; h1 `:673-677` renders `Learn in{' '}<br />the open` (DOM: `Learn in ` + `<br>` + `the open`); tagline-full `:680` `Seventy-eight weeks of Spanish, one notebook page at a time. Your week opens when you reach it.`; tagline-short `:683` `Seventy-eight weeks of Spanish, one notebook page at a time.` (a CSS-switched responsive pair); footer `:690` `Beginner &middot; Intermediate &middot; Advanced` and `:691` `78 weeks`. The brass.300 wordmark and footer color is a ratified WCAG fix (comment `:651-653`) and must not revert. |
| Authenticated header | `src/App.tsx:468-469` | Eyebrow `{branding.brand_name}`, title `Field Journal`. `BrandingProvider` mounts only inside `AuthGate`'s session branch (`App.tsx:750-754`). `App()` at `:757-765` is `AccessibilityProvider > AuthProvider > AuthGate`. `AuthGate` routes `/courses` and `/courses/:id` to `PublicCatalogPage` before auth (`:626-628`). |
| Login form | `src/components/LoginForm.tsx:96` | Eyebrow `Access`. The `Sign in` h2 (`:97`) is functional and out of scope. |
| Public catalog | `src/pages/PublicCatalogPage.tsx` | Header mark `L` `:113`; wordmark `Lizbeth Spanish` `:120`; title `Field Journal` `:121`; footer `:132` `Lizbeth Spanish`, `:133` `Field Journal — Spanish, done right.`; preview chrome heading `Course preview` `:193`, `:198` (the content-loaded h1 at `:147`, course title or `Course preview`, stays course content and is out of scope); preview intro `:148` `This preview shows the published learning experience. Sign in to enroll.`; h2 `:150` `What you'll learn`; hero eyebrow `:211` `Three volumes · 78 weeks · A1 to C1`; h1 `:212` `Explore courses`; body `:213-215` `Each volume is twenty-six weeks. Weeks open on your own schedule, counted from the day you enrol — not on a fixed class calendar.` (the implementer must verify the exact whitespace collapse from the JSX line break); empty state `:257` eyebrow `Catalog empty`, `:258` body `No course volumes are published yet. Check back soon.` |
| Admin shell | `src/components/AdminShell.tsx:116,118` | `BrandLogo` uses `branding.brand_name` but the `:118` eyebrow is hardcoded `Lizbeth Spanish`. |
| Roadmap ledger (added in revision) | `RoadmapPage.tsx:127,129,144` | Container `aria-label="Filed progress"` at `:127` (functional, unchanged); label `Filed` at `:129`; footnote `SOLID = COMPLETE · HATCHED = IN HAND` at `:144`. Both strings are now in scope (decision D7). |
| Authenticated header and mobile menu (added in revision) | `src/App.tsx` header; `App.tsx:538-549` (`MobileNavPanel`); `src/components/MobileNavPanel.tsx`; `src/lib/headerNavBreakpoint.ts` | `.app-header` holds the bordered `.app-nav` and `.app-header-signout`. `HEADER_NAV_BREAKPOINT_REM` is `56.25rem` (900 px). `headerNavBreakpoint.ts` documents an a11y-trigger overlap sweep (`--a11y-trigger-footprint` remediation). Source: Planner's revision handoff; Scribe did not re-read these files. |
| Student pages | `RoadmapPage.tsx:117-118`; `LearnIndexPage.tsx:151,152,167`; `LearnDetailPage.tsx:377-413,451,453`; `FeedbackForm.tsx:219-222,234-236`; `FeedbackPage.tsx:29`; `BandRoadmap.tsx:185`; `OwnerDashboardPage.tsx:109` | `Contents` / `Your roadmap`; `Your learning` / `Your courses` / empty body `No enrolled courses yet. Once you enroll in a course, it appears here.`; eyebrow `Course` at `:377/385/405/413/451`, h1 `Your course` at `:378/:386`, empty `No lessons published yet. Check back soon.` `:407`, h2 `Your progress` `:453`; FeedbackForm eyebrow `:219-221`, h1 `Leave a note` `:222`, intro `:234-236`; FeedbackPage fallback h1 `Leave a note` `:29` (same key as `FeedbackForm:222`); `No weeks published yet for this band.`; owner dashboard subtitle `A calm view of who is moving forward and where to help.` The `course_title` h1s at `LearnDetailPage.tsx:406/:414/:452` are course content and out of scope. The implementer must read the exact FeedbackForm eyebrow and intro literals before writing the registry. |
| Document metadata | `index.html:7-9` | Meta description `Lizbeth Spanish Course Platform - Phase 0 Scaffold` (stale) at `:7`; `<title>Lizbeth Spanish Course Platform</title>` at `:9`; CSP `script-src 'self'` at `:8`. Runtime title and meta updates through JS are CSP-compatible. No inline script may be added. |

### 3.2 Data and write path

- `owner_settings` is defined at `supabase/migrations/202607170001_init_schema.sql:76-87`: `id uuid PK`, `owner_id uuid NOT NULL UNIQUE references auth.users ON DELETE CASCADE`, `brand_name`, `brand_primary_color`, `brand_secondary_color`, `logo_storage_path`, `legal_copyright_text`, `legal_ip_notice`, `created_at`, `updated_at`. The table comment says "singleton" but only `owner_id` is unique.
- `supabase/migrations/202607250002_fix_bands_owner_settings_read_scoping.sql` limits the read policy to `to authenticated` (anon removed, user-approved). Writes go only through `service_role`.
- `supabase/functions/owner-settings/index.ts:109-113` upserts `{ owner_id: caller.id, ...sanitized }` with `onConflict 'owner_id'`. A save by a second owner therefore inserts a second row.
- `src/services/ownerSettingsData.ts:96-101` reads with `.maybeSingle()`. With two rows it errors and returns defaults for everyone, so the legal IP notice is silently replaced by a placeholder.
- A second production owner exists (`docs/plans/lizbeth-spanish-admin-role-grant.md` R-B / finding A7). G14.1 added `--skip-owner-settings` to `scripts/set-owner-role.ts`, which still upserts with `onConflict 'owner_id'` at `:264-271` by default.
- Regression guard `src/__tests__/ownerSettingsData.test.ts:93` (G14.2) asserts degrade-to-defaults on a `maybeSingle` error. It stays.
- `src/lib/ownerSettingsAuthorization.ts` is dependency-free and imported by the Deno function with explicit `.ts` extensions. `isOwnerUser` is `app_metadata.role === 'owner'`, and the sanitizer whitelists fields. New pure modules follow the same Deno-importable convention.
- `BrandingContext.tsx` renders defaults immediately, then fetches, and calls `refresh()` after save.
- Admin pages: `BusinessSettingsPage.tsx` (D.7 header; `brand_name`, copyright and IP notice fields; one form; `Control tier=primary` submit; field errors `role=alert`; focus on the first invalid field via refs; success `role=status`) and `BrandDesignPage.tsx` (D.8 52px bookplate H1; colors and logo; static preview; one form). Both share `OwnerSettingsPage.css`.
- Latest migration: `202609150002_revoke_backfill_legacy_courses_execute.sql`. Production has applied migrations. The forward-only policy is recorded in the `202607250002` header.

### 3.3 Existing guards and tooling

- Guards: `src/__tests__/nativeDialogPolicy.test.ts` (native-dialog scan), `tokenFallbackAuditLint.test.ts` (no raw hex outside `src/tokens`, no undefined `var()`, zero border-radius, no blurred shadow), `modal-scroll-overflow.test.ts`. `src/components/Modal.tsx` and `src/hooks/useFocusTrap.ts` are the only sanctioned confirmation mechanism.
- About 21 test files assert literal copy (`App.test.tsx`, `PublicCatalogPage-anonymous-access.test.tsx`, `AuthGatePublicRouting`, `wp12FeedbackComposition`, `wp6BrandDesignConformance`, `Issue4SettingsPages`, e2e `wp9`/`wp2`/`wp13`/`wp6` specs, and others). Because defaults are byte-identical and hooks fall back to registry defaults without a provider, these must pass unmodified. Any edit to them must be justified individually.
- Commands (`package.json`): `npm run type-check` (`tsc --noEmit`), `npm run lint`, `npx vitest run`, `npm run test:e2e` (Playwright; `playwright.config.ts` baseURL `http://localhost:8888` via `npm run build && netlify serve --context production --port 8888` unless `E2E_BASE_URL` is set), `npm run verify:build` (build, service-role leak, build config, and lesson content leak checks).
- Local stack (`README.md:49-60`): `npx supabase start`, `npx supabase db reset` (migrations, `seed.sql`, `seeds/full-catalog.sql`; accounts `owner@test.local` and `student1-6@test.local`), `npm run dev` at `http://localhost:5173`. `supabase/config.toml` registers functions.

## 4. Research evidence

No new nested research ran in this planning run. The architecture recommendation comes from prior research relayed by the lead in the PLAN_JOB: `public.site_content` with key, jsonb value and enabled columns; a code registry; a public view; an owner-gated Edge Function; `PublicContentProvider` above `AuthGate`; grouped fieldsets; counters; inline reset; focus management; a forward-only migration. It is treated as user-approved direction.

## 5. Reviewed design handoff

`DESIGN_ROUTE`: profile standard. Reasons: multi-state admin form IA, new anonymous content states, language toggle. Agents: design-director (Sonnet), ux-architect, visual-system-designer, design-reviewer. Prototype forbidden. Existing-system mode: preserve.

`DESIGN_REVIEW_RESULT`: verdict PASS on the third design revision. History: the original review returned NEEDS_REVISION (a two-key disable carve-out that conflicted with the user's "every key can be disabled" decision; launch guidance that did not match the repo's netlify-serve e2e harness; the tagline pair toggle). The revision passed. The judge remediation revision (after PLAN_DUCK, section 6) returned NEEDS_REVISION on two fallback strings; the user chose option A; the result passed. The reviewer independently verified the H1 enumeration, the clip-rect precedent, the FeedbackPage fallback, the admin-chrome exclusion, and the launch commands. The full packet is held in the planner chain; the binding parts follow.

### 5.1 Direction

Field Journal admin-form extension, preserve and extend only. Zero new DTCG tokens. New composition classes only: `.owner-key-group-summary`, `.owner-key-row`, `.owner-key-row-spanish`, `.owner-key-row-spanish-label`, `.owner-key-row-counter`, `.owner-key-row-controls`, `.owner-key-row-note`, `.owner-key-group-note`, `.owner-settings-pending`, `.lang-toggle`, `.lang-toggle--on-dark`, plus one page-local clip-rect hidden-heading class per H1 surface (recipe from `FlashcardsViewer.css:224-233` and `WeekDetailPage.css:37-49`).

### 5.2 Information architecture

- Groups are `<details>` (collapsed by default) containing `<fieldset>`/`<legend>`. The legend may be visually hidden or folded into the summary.
- Business settings: the existing three fields first, then groups "Page title & search description", "Owner dashboard", "Student pages — Roadmap", "— Your learning", "— Course detail", "— Feedback", "— Band roadmap".
- Brand & design: the existing colors and logo fields, then "Sign-in page" and "Public catalog" groups. Shared brand-chrome keys such as the wordmark and product title live in Brand & design.

### 5.3 Per-key row (identical for every key)

- Label and English input (textarea if multiline).
- Indented optional "(Spanish)" sub-row (margin-left `--space-5`, hairline `paper-300` left border, `ink-700` label).
- Character counter: visual on every keystroke; `aria-live` polite announcement debounced 500 ms; near-limit color `--color-status-warning-text`, never the error color.
- `Control tier="toggle"` "Shown on site" (`aria-pressed`, always operable, never natively disabled).
- `Control tier="quiet"` "Reset to default" (stages the literal default into the field; saved only on Save).

### 5.4 Three states, uniform for every key

| State | Condition | Rendering |
| --- | --- | --- |
| Edited | Non-empty and enabled | Renders the active language; per-key English fallback when Spanish is empty. |
| Blank | Empty and enabled | Renders the byte-identical registry default ("blank = no override"). Blank is always a valid save, never a validation error. |
| Disabled | Toggle off | The key renders and announces nothing of its own content (neither owner text nor registry default). It is absent from the DOM and accessibility tree, with no empty node and no gap. For an H1-bearing key, a structural fallback `<h1>` mounts only while the key is disabled (see below). |

Structural fallback model (PLAN_DUCK J-PLAN-002). Each H1-bearing key has a fixed, non-owner-editable fallback `<h1>` that mounts only while that key is disabled. It is clip-rect hidden through a page-local class per surface (recipe `FlashcardsViewer.css:224-233` and `WeekDetailPage.css:37-49`; never `aria-hidden`, `display:none`, or `visibility:hidden`). Every page therefore keeps exactly one valid, non-empty `h1`. Fallback strings are functional text: not editable, English-only like navigation labels, and each distinct from its key's default.

| H1 surface | Fallback `h1` text |
| --- | --- |
| Sign-in page | `Sign in` (plain, no brand name, so it cannot go stale or leak a disabled string; the hidden h1 followed by `LoginForm`'s visible h2 `Sign in` at `LoginForm.tsx:97` is reviewer-confirmed acceptable) |
| Public catalog list | `Course catalog` |
| Catalog preview chrome heading | `Course details` |
| Roadmap | `Roadmap` |
| Your learning | `Learn` |
| Course detail | `Course` |
| Feedback (`FeedbackForm` and `FeedbackPage` fallback) | `Feedback` |

Blank remains "no override, default renders". Non-H1 disabled keys are removed from the DOM with no gap.

Metadata rules: `page_title` blank or disabled renders the registry default title (never `brand_name`). `meta_description` blank or disabled renders exactly `Lizbeth Spanish Course Platform - Phase 0 Scaffold` (hyphen, not em dash), byte-identical to `index.html:7`, which stays unchanged. It is never empty or missing.

Ledger keys: disabling `roadmap.ledger_label` removes only that text span. The count span stays and the container `aria-label="Filed progress"` (`:127`) stays functional and unchanged. Disabling `roadmap.ledger_footnote` removes the whole footnote `<p>`.

H1-bearing keys: sign-in heading (`App.tsx:673-677`), catalog hero h1 (`PublicCatalogPage.tsx:212`), catalog preview chrome heading `Course preview` (`:193`, `:198`; the content-loaded h1 at `:147` is course content and out of scope), `RoadmapPage.tsx:118`, `LearnIndexPage.tsx:152`, `LearnDetailPage.tsx:378/:386`, `FeedbackForm.tsx:222` plus `FeedbackPage.tsx:29` (one key, two render sites).

### 5.5 Tagline pair

The full and short taglines are two keys sharing one "Shown on site" toggle, rendered once beneath both rows. Disabling hides both. Each line keeps its own EN/ES text, counter, reset, and blank-to-own-default behavior.

### 5.6 Save model

One save per page, using the existing single form and single `Control tier="primary"` (exactly one primary per view). Unsaved edits show a persistent `role="status"` `aria-live="polite"` "N unsaved changes" line (brass/warning family) in the same slot as the success line (moss family); the two are mutually exclusive. There is no navigation-guard modal and no `beforeunload` (prohibited). Loss on tab close is an accepted residual risk.

### 5.7 Validation

Only genuine failures (over `maxLength`, invalid characters, unknown key) are errors: inline `role="alert"` per field, the enclosing `<details>` opened explicitly (`open=true`), and focus moved to the first invalid field using the existing refs pattern (`BusinessSettingsPage.tsx:36`).

### 5.8 Language toggle

One `LanguageToggle` component: a `div role="group" aria-label="Site language"` with two `Control tier="toggle"` buttons "English" and "Español" (`aria-pressed`). All render sites share one `localStorage` key, set `<html lang>`, and keep focus on the pressed button after switching. Render sites:

| Render site | Placement | Variant |
| --- | --- | --- |
| Anonymous sign-in brand panel | First in `.auth-brand-panel-top`, before the lockup | `.lang-toggle--on-dark` (page-scoped in `LoginForm.css`) |
| `/courses` catalog header | First child of `.catalog-header` | `.lang-toggle--on-dark` (page-scoped in `PublicCatalogPage.css`) |
| Authenticated desktop `.app-header` | After the bordered `.app-nav` and before `.app-header-signout`; visible only at 900 px and wider (`src/lib/headerNavBreakpoint.ts`, `HEADER_NAV_BREAKPOINT_REM` `56.25rem`) | Bare `.lang-toggle` on the light `paper-200` header |
| `MobileNavPanel` (`App.tsx:538-549`) | An item near Sign out; below 900 px; non-admin routes only | Bare `.lang-toggle` |

`AdminShell` (`/admin/*`) gets no toggle and stays English. `.lang-toggle--on-dark` swaps `--shadow-card` for `--shadow-brass` / `--shadow-brass-press` and is used only on the two anonymous dark surfaces. `PublicCatalogPage.css` gets its first forced-colors block, scoped only to `.lang-toggle`. A required check in WP7 and WP8: re-run the documented a11y-trigger overlap sweep from `headerNavBreakpoint.ts` (900, 1000, 1100, 1200, 1258, 1280, 1295, 1366 px) with the toggle present. The `--a11y-trigger-footprint` remediation must still clear.

### 5.9 Anonymous states

Defaults render in the final DOM node immediately (no skeleton, no fade, no layout shift). Fetch failure is fully silent. Long text is protected by per-key `maxLength` (sized for roughly 20 to 30 percent Spanish expansion) and wrapping, with no runtime truncation. 320 px reflow shows no horizontal scroll.

### 5.10 Engineering invariants (binding)

1. Byte-identical defaults, including the `Learn in / the open` line break, middle dots, and em dash.
2. Plain text only, rendered as React text nodes, never `dangerouslySetInnerHTML`.
3. The structural fallback model in 5.4: a disabled H1-bearing key renders and announces nothing of its own content; a fixed, non-editable, clip-rect-hidden fallback `h1` mounts only while disabled, with the seven fallback texts `Sign in`, `Course catalog`, `Course details`, `Roadmap`, `Learn`, `Course`, `Feedback`. Every page keeps exactly one non-empty `h1`.
4. The state rules in 5.4.
5. Title and meta rules: `page_title` blank or disabled gives the registry default title; `meta_description` blank or disabled gives exactly `Lizbeth Spanish Course Platform - Phase 0 Scaffold`; `index.html` is unchanged.
6. `PublicContentProvider` above `AuthGate`; defaults immediate; silent failure.
7. No native dialogs; `nativeDialogPolicy.test.ts` passes.
8. One primary Control per view; one save per page.
9. `Control.css` `.control--toggle` and `.control:disabled` are never edited. `.lang-toggle--on-dark` is used only on the two anonymous dark surfaces.
10. The `AdminShell.tsx:118` eyebrow binds to `branding.brand_name` like `App.tsx:468`.
11. The `BrandDesignPage` static preview stays static, and the `L` glyphs are deferred to a follow-up issue.
12. D.7 and D.8 admin header treatments stay unmerged.
13. Shared tagline toggle.
14. The `OwnerSettingsPage.css` forced-colors block stays the last block, with new selectors appended inside it; hidden-heading rules stay page-local.
15. Focus moves to the first invalid field only for genuine validation failures.
16. Roadmap ledger: the container `aria-label="Filed progress"` is unchanged; disabling the label removes only its text span; disabling the footnote removes the whole `<p>`.
17. Language toggle: render sites as in 5.8; none on `/admin/*`; the header overlap sweep is re-verified; focus stays on the pressed button.

Also preserved from issue43: brass.300 on ink.900 for wordmark, footer, and eyebrow ink; the 390 px overflow audit; `tokenFallbackAuditLint` green.

### 5.11 Design items left open (non-blocking)

- Exact helper and pending-line copy (placeholder).
- Per-key `maxLength` and near-limit thresholds (engineering decides).
- A plain `.owner-settings-field input :focus-visible` rule exists only under `.owner-settings-page--brand` (`OwnerSettingsPage.css:536-539`). Business settings inputs need the same focus-visible treatment.
- Confirm `LoginForm.css` and `PublicCatalogPage.css` narrow-width `overflow-wrap` guards before long strings ship.

## 6. Judge route

Risk: HIGH (RLS and anonymous exposure change, forward-only production migrations, owner-gated write path, about 20 surfaces). Call cap: 4 (1 used: PLAN_DUCK). Initial shadow policy follows `docs/JUDGE-CONTRACT.md`. Deterministic failures always dominate. Codex findings are advisory unless evidence-backed under blocking mode, and no judge pass is assumed until observed.

| Checkpoint | Requirement | Timing and rubric |
| --- | --- | --- |
| PLAN_DUCK | Required | After this draft, before approval. Rubric: scope fidelity to user decisions, anonymous exposure narrowness, singleton migration safety and rollback, byte-identical default strategy, browser brief completeness. Run: shadow/advisory, verdict REVISE. Findings and disposition are recorded below. |
| CODE_REVIEW | Required | After PR-A and PR-B JOB_DONE (may be one call covering both if executed together). Rubric: RLS, grants and view privilege; Edge Function authorization, whitelist, and length/character validation; no `dangerouslySetInnerHTML`; singleton write correctness; no service-role leak. |
| VERIFICATION_CHALLENGE | Conditional | Only if Verifier evidence leaves coverage gaps on literal-test preservation or RLS integration. |
| VISUAL_REVIEW | Skipped | Standard route, not Studio or brand-critical. |

Finding IDs flow into the T1 job brief and the Verifier gate. T1 cannot self-approve.

### PLAN_DUCK findings and disposition

Verdict: REVISE. Mode: shadow/advisory (high risk). Judge calls used: PLAN_DUCK 1 of cap 4.

| Finding | Severity | Summary | Resolution |
| --- | --- | --- | --- |
| J-PLAN-001 | major | Signed-in students could not change language. | Fixed by an in-scope authenticated language toggle (5.8, WP5, WP7). |
| J-PLAN-002 | major | A disabled H1 was both removed and clip-hidden with its default text. | Fixed by the structural fallback model (5.4). |
| J-PLAN-003 | major | Decision D2 (new meta default copy) conflicted with byte-identical defaults. | Fixed by pinning the meta default to the exact `index.html:7` string; new wording is a follow-up issue. |

Disposition: all three accepted. The design was re-reviewed: the judge remediation revision returned NEEDS_REVISION on two fallback strings, the user chose option A, and the result passed independent design review (section 5).

## 7. Ordered work

Owners: T1 per Engineering Fleet unless escalated. Each work package (WP) ends with green targeted tests. Commits, pushes, and PRs happen only when the user explicitly authorizes them.

### 7.1 Branch strategy

Two sequential PRs from up-to-date `main` in the `lizbeth_spanish` repo.

- PR-A, branch `fix/issue-177-owner-settings-singleton`, contains WP0 and WP1. It is small, independently shippable, and merges first (user decision: the singleton fix goes first).
- PR-B, branch `feat/issue-177-owner-editable-site-text`, is created from `main` after PR-A merges (or stacked on PR-A if the user prefers not to wait, then rebased onto `main` after PR-A merges). It contains WP2 through WP8.
- WP9 production steps are user-gated and run per PR after merge approval.
- No force-push to `main`; no direct commits to `main`.

### 7.2 Work packages

| WP | PR | Title | Summary |
| --- | --- | --- | --- |
| WP0 | A | Baseline (blocking) | Clean tree, current `main`, branch, green baseline, byte-level literal fixture. |
| WP1 | A | Singleton `owner_settings` | Forward migration, function and script upsert change, tests. |
| WP2 | B | `site_content` schema and anonymous read | Table, view, grants, RLS tests. |
| WP3 | B | Registry and pure logic | Registry, resolver, sanitizer, unit tests. |
| WP4 | B | Write Edge Function and client | `site-content` function, `siteContentData.ts`. |
| WP5 | B | Provider and language | Context, hooks, `SiteText`, metadata, `LanguageToggle`. |
| WP6 | B | Admin UI | Registry-driven groups on both pages, single save, AdminShell fix. |
| WP7 | B | Surface wiring | Replace every inventory literal. |
| WP8 | B | Tests and validation | Unit, RLS, e2e, scans, then Verifier and Browser Validator. |
| WP9 | A, B | Production rollout | User-gated per step. |

### WP0 Baseline (blocking)

- Confirm the `lizbeth_spanish` working tree is clean and on current `main` (`git status`, `git fetch`, `git log -1 origin/main`). Create the branch.
- Run `npm run type-check`, `npm run lint`, and `npx vitest run`. Record pass and fail counts verbatim. If anything is already red, return JOB_BLOCKED rather than building on a broken baseline.
- Capture a byte-level baseline of every in-scope literal in a new test helper and fixture `src/__tests__/fixtures/siteTextBaseline.ts`. It records each literal, and the sign-in h1 innerHTML `Learn in <br>the open`, read from current source before any edits.

### WP1 Singleton `owner_settings` (PR-A)

New forward migration `supabase/migrations/<YYYYMMDDNNNN>_issue177_owner_settings_singleton.sql` (timestamp after `202609150002`):

- (a) Guard: if `count(*) > 1`, `RAISE EXCEPTION` with a clear message. No automatic data merge. The user decides which row survives during the WP9 pre-check.
- (b) Add `singleton boolean not null default true`, `check (singleton)`, and a unique index or constraint on `singleton`.
- (c) Make `owner_id` nullable and change its FK to `ON DELETE SET NULL` (deleting an owner account must not delete site settings). Keep `owner_id` UNIQUE for rollback compatibility: an old-function insert of a second row then fails safely on `singleton`.

Semantics: `owner_id` means "last saved by".

Code changes:

- `supabase/functions/owner-settings/index.ts` upserts `{ singleton: true, owner_id: caller.id, updated_at: now, ...sanitized }` with `onConflict 'singleton'`, so any owner updates the one row.
- `scripts/set-owner-role.ts` default upsert moves to the same singleton semantics (or `--skip-owner-settings` behavior becomes safe by default), with matching updates to `src/__tests__/set-owner-role.test.ts`.
- Update the `supabase/seed.sql` insert if needed.
- Keep the G14.2 test.

New tests:

- A second-owner save updates the same row (function unit or contract test with a mocked client).
- A DB-level second-row insert is rejected (rlsIntegration-style test against local Supabase).
- `ON DELETE SET NULL` behavior.

### WP2 `site_content` schema and anonymous read (PR-B)

Forward migration `<ts>_issue177_site_content.sql`:

- Table `public.site_content`: `key text primary key` with `check (key ~ '^[a-z][a-z0-9_.]{1,63}$')`; `value jsonb not null default '{}'::jsonb` with `check (jsonb_typeof(value)='object')`; `enabled boolean not null default true`; `updated_at timestamptz not null default now()`; `updated_by uuid references auth.users(id) on delete set null`.
- RLS enabled. No anon or authenticated policies or grants on the base table. `service_role` has full access (follow the `202607170008` and `202607170009` grant patterns).
- View `public.public_site_content (key, value, enabled)` owned by `postgres`, `select` granted to `anon` and `authenticated` only, with no write grants.
- `owner_settings` stays authenticated-only. Anonymous users need no `owner_settings` field because brand chrome keys live in `site_content`. This is narrower than the approved exposure; record it.
- No production seed rows. An empty table means all defaults (byte-identical).
- Add the migration to the existing migration-ordering and security tests (`securityFindings.test.ts`, `rlsIntegration.test.ts`): anon can select the view; anon cannot select `site_content` or `owner_settings`; anon and authenticated cannot insert, update, or delete either table.

### WP3 Registry and pure logic (PR-B)

- `src/lib/siteContentRegistry.ts` (dependency-free, Deno-importable, explicit `.ts` imports). Entries have the shape `{ key, group, page: 'business'|'brand', surface, label, default: { en: <current literal> }, maxLength, multiline, role: 'h1'|'text'|'title'|'meta', toggleGroup?, fallbackH1? }` (`fallbackH1` is fixed English functional text, not owner-editable, present only on `role: 'h1'` entries, with the seven values in 5.4) covering the key inventory in section 8.
- `resolveSiteText(entry, row|undefined, lang)` implements the three states, with a disabled key resolving to "render nothing" and the H1 structural fallback handled by the renderer.
- `src/lib/siteContentAuthorization.ts` exports `sanitizeSiteContentPayload`: whitelist keys, string-only `en`/`es`, trim, length in code points at most `maxLength` per language, reject control characters except `\n` on multiline keys, boolean `enabled`, and maximum entries equal to the registry size.
- Unit tests: every registry default equals the WP0 baseline fixture byte-for-byte; a resolver truth table (edited, blank, disabled across en, es, and role); the sanitizer rejects an unknown key, a non-string, over-length text, and control characters; HTML is stored as literal text and rendered escaped.

### WP4 Write Edge Function and client (PR-B)

- `supabase/functions/site-content/index.ts`: PUT only; CORS like `owner-settings`; verifies the token via `auth.getUser`; requires `isOwnerUser`; sanitizes; upserts by key with `updated_by` set to the caller and `updated_at=now()` through the service-role client; returns saved rows; generic 403 for non-owners. Register in `supabase/config.toml` with `verify_jwt` true.
- Client `src/services/siteContentData.ts`: `getPublicSiteContent()` reads the view and never throws (errors yield an empty map); `saveSiteContent(entries)` uses `functions.invoke` with a typed `SiteContentWriteError` carrying `fieldErrors`.
- Tests mirror `ownerSettingsData.test.ts`. `npm run verify:build` proves no service-role leak.

### WP5 PublicContentProvider and language (PR-B)

- `src/context/PublicContentContext.tsx` mounted in `App()` above `AuthGate` (`AccessibilityProvider > PublicContentProvider > AuthProvider > AuthGate`, or equivalent above `AuthGate`). It renders registry defaults synchronously, fetches the view once on mount, and exposes `refresh()` (called after an owner save).
- `useSiteText(key)` returns the resolved value and MUST fall back to registry defaults when no provider is mounted, because existing component tests render pages without one.
- `useSiteLanguage` uses a `localStorage` key (for example `lizbeth.siteLanguage`), defaults to `en`, and sets `document.documentElement.lang`.
- A `<SiteText k as=...>` renderer turns `\n` into `<br>`, producing DOM identical to today (sign-in h1 innerHTML `Learn in <br>the open`). For the H1 role, while the key is disabled the renderer omits the key's own content (owner and default text) and mounts the fixed structural fallback `h1` (clip-rect hidden, page-local class).
- Metadata: a provider effect sets `document.title` and `meta[name="description"]` content from resolved keys (fallback rules in 5.4). The static `index.html` stays as the crawler default. SEO limit to record: non-JS crawlers see only `index.html`.
- `LanguageToggle` component per section 5.8: one component, shared `localStorage` key, focus stays on the pressed button.

### WP6 Admin UI (PR-B)

- Extend `BusinessSettingsPage.tsx` and `BrandDesignPage.tsx` with registry-driven groups per section 5. A shared `SiteContentFieldset` / `SiteContentKeyRow` component is permitted.
- Single Save per page: submit the existing `owner_settings` fields (unchanged behavior) and, only when site keys are dirty, call `saveSiteContent`. On partial failure show a `role="alert"` naming which part failed and keep the unsaved state. Refresh `BrandingContext` and `PublicContentProvider` after success.
- Counters, reset-to-default staging, the shared tagline toggle, the pending-changes line, focus management, and Business settings input `:focus-visible` parity.
- CSS appended per the invariants (`OwnerSettingsPage.css` forced-colors block last).
- Fix `AdminShell.tsx:118` so the eyebrow renders `{branding.brand_name}`.

### WP7 Surface wiring (PR-B)

- Replace every inventory literal with `useSiteText` or `SiteText` at the cited lines: `App.tsx` sign-in panel and header title; `LoginForm` eyebrow; `PublicCatalogPage` header, hero, empty state, footer, and preview copy; `RoadmapPage`; `LearnIndexPage`; `LearnDetailPage`; `FeedbackForm`; `FeedbackPage` fallback; `BandRoadmap`; `OwnerDashboardPage` subtitle.
- Add `LanguageToggle` at all render sites in 5.8: sign-in panel, catalog header, authenticated desktop `.app-header` (900 px and wider only), and `MobileNavPanel` (below 900 px, non-admin routes). Affected files include `src/App.tsx` (header) and `src/components/MobileNavPanel.tsx`. `AdminShell` gets no toggle.
- Wire the roadmap ledger keys: the label removes only its text span; the footnote removes its whole `<p>`; `aria-label="Filed progress"` is unchanged.
- Add the page-local clip-rect structural fallback `h1` classes and mount each fallback only while its key is disabled.
- Re-run the `headerNavBreakpoint.ts` a11y-trigger overlap sweep (900, 1000, 1100, 1200, 1258, 1280, 1295, 1366 px) with the toggle present; the `--a11y-trigger-footprint` remediation must still clear.
- Preserve all class names, DOM order, aria attributes, landmark structure, and the locked `<main>` child order on `PublicCatalogPage` (issue43).

### WP8 Tests and validation (PR-B)

- All pre-existing literal-asserting unit and e2e tests pass UNMODIFIED. Any change is individually justified in the job report.
- New unit tests: registry, resolver, sanitizer, provider, no-provider fallback, language toggle, metadata, admin rows, tagline toggle, pending line, focus-to-invalid, ledger label and footnote disable behavior, and `LanguageToggle` at every render site (absent on `/admin/*`). For each H1 surface, assert exactly one `h1` and its text in each state (enabled, blank, disabled), and that the disabled key's owner and default text are absent from the DOM.
- Header overlap sweep per WP7 with the toggle present, recorded in the job report.
- RLS integration tests.
- New Playwright spec `src/__tests__/e2e/issue177-site-text.spec.ts` covering the journeys in section 11.
- `nativeDialogPolicy`, `tokenFallbackAuditLint`, and `modal-scroll-overflow` green.
- A 390 px overflow audit of changed surfaces (issue43 R2 pattern).
- Then Verifier, then Browser Validator.

### WP9 Production rollout (USER-GATED)

Each step needs explicit user approval at the time. T1 never performs these autonomously.

1. Read-only pre-check on production: `select count(*), array_agg(owner_id), array_agg(updated_at) from owner_settings`. If more than one row, STOP and ask the user which row survives. Manual consolidation is its own approved step.
2. Back up `owner_settings` (data-only dump, stored outside the repo, never committed).
3. `npx supabase migration list --linked` to confirm no drift.
4. `npx supabase db push` for the PR-A migration; deploy the function with `npx supabase functions deploy owner-settings`. Smoke: an owner save from each owner account updates the single row.
5. After PR-B merges: `db push` the `site_content` migration; deploy the `site-content` function; Netlify production deploy through the repo's normal merge flow. Smoke journeys 1, 3b, and 4 against production with the owner account, then reset changed keys to blank (defaults).
6. Record evidence under `lizbeth_spanish/docs/cutover-evidence/` (safe summaries only, no secrets).

Deploy order: DB, then functions, then app.

## 8. Key inventory

Defaults equal the exact current literal. The implementer confirms each against source in WP0. Key names are illustrative; final naming is engineering discretion.

### Brand & design: Sign-in page (brand chrome)

| Key | Default | Notes |
| --- | --- | --- |
| `brand.wordmark` | `Lizbeth Spanish` | Shared by sign-in wordmark line 1 (`App.tsx:669`), catalog header (`:120`), catalog footer left (`:132`). Distinct from `owner_settings.brand_name` (decision D1, resolved). |
| `brand.product_title` | `Field Journal` | `App.tsx:469` header title, `App.tsx:670` wordmark line 2, `PublicCatalogPage.tsx:121`. |
| `signin.heading` [h1] | `Learn in\nthe open` | Multiline; renders `Learn in <br>the open`. Fallback `h1` while disabled: `Sign in`. |
| `signin.tagline_full`, `signin.tagline_short` | literals in 3.1 | Share one toggle. |
| `signin.footer_levels` | `Beginner · Intermediate · Advanced` | |
| `signin.footer_duration` | `78 weeks` | |
| `signin.card_eyebrow` | `Access` | `LoginForm.tsx:96`. |

### Brand & design: Public catalog

| Key | Default |
| --- | --- |
| `catalog.hero_eyebrow` | `Three volumes · 78 weeks · A1 to C1` |
| `catalog.heading` [h1] | `Explore courses` (fallback `h1` while disabled: `Course catalog`) |
| `catalog.hero_body` | `Each volume is twenty-six weeks. Weeks open on your own schedule, counted from the day you enrol — not on a fixed class calendar.` (verify whitespace) |
| `catalog.empty_eyebrow` | `Catalog empty` |
| `catalog.empty_body` | `No course volumes are published yet. Check back soon.` |
| `catalog.footer_tagline` | `Field Journal — Spanish, done right.` |
| `catalog.preview_heading` [h1] (preview chrome heading, `PublicCatalogPage.tsx:193/:198`) | `Course preview` (fallback `h1` while disabled: `Course details`) |
| `catalog.preview_intro` | `This preview shows the published learning experience. Sign in to enroll.` |
| `catalog.preview_learn_heading` | `What you'll learn` |

### Business settings

| Group | Key | Default |
| --- | --- | --- |
| Page title & search description | `meta.page_title` [title] | `Lizbeth Spanish Course Platform` |
| Page title & search description | `meta.description` [meta] | `Lizbeth Spanish Course Platform - Phase 0 Scaffold` (byte-identical to `index.html:7`; hyphen, not em dash; new wording is a follow-up issue) |
| Owner dashboard | `dashboard.subtitle` | `A calm view of who is moving forward and where to help.` |
| Student pages: Roadmap | `roadmap.eyebrow`, `roadmap.heading` [h1], `roadmap.ledger_label`, `roadmap.ledger_footnote` | `Contents`, `Your roadmap` (fallback `h1` `Roadmap`), `Filed` (`RoadmapPage.tsx:129`; disabling removes only the text span), `SOLID = COMPLETE · HATCHED = IN HAND` (`:144`; disabling removes the whole `<p>`) |
| Student pages: Your learning | `learn.eyebrow`, `learn.heading` [h1], `learn.empty_body` | `Your learning`, `Your courses` (fallback `h1` `Learn`), `No enrolled courses yet. Once you enroll in a course, it appears here.` |
| Student pages: Course detail | `course.eyebrow`, `course.heading` [h1], `course.empty_body`, `course.progress_heading` | `Course`, `Your course` (fallback `h1` `Course`), `No lessons published yet. Check back soon.`, `Your progress` |
| Student pages: Feedback | `feedback.eyebrow`, `feedback.heading` [h1], `feedback.intro` | eyebrow and intro literals from `FeedbackForm.tsx:219-221` and `:234-236` (read exactly in WP0); `Leave a note` (`FeedbackForm:222` and `FeedbackPage:29`; fallback `h1` `Feedback`) |
| Student pages: Band roadmap | `band.empty_body` | `No weeks published yet for this band.` |

### Excluded, with reason

`Sign in` h2; navigation, button and form labels; the ledger container `aria-label="Filed progress"`; all loading, error and status strings; the seven structural fallback `h1` texts (functional, English-only); course titles, including the content-loaded h1 at `PublicCatalogPage.tsx:147`; admin chrome headings; `L` glyphs (follow-up issue).

## 9. Interfaces and data

- Database: `owner_settings` gains `singleton boolean` (unique, check true); `owner_id` becomes nullable FK `ON DELETE SET NULL` and stays unique. New `public.site_content(key text PK, value jsonb {"en"?: string, "es"?: string}, enabled bool, updated_at, updated_by)`. New view `public.public_site_content (key, value, enabled)`, select-only for anon and authenticated. No change to the `owner_settings` read policy.
- Edge Functions: `owner-settings` PUT keeps the same request and response contract, with the write target now the singleton row. New `site-content` PUT body `{ entries: [{ key, en?: string, es?: string, enabled: boolean }] }` returns `200 { data: rows }`, or `400/401/403/405/422 { error, fieldErrors? }`, or `500`.
- Client: `getPublicSiteContent()`, `saveSiteContent()`, `PublicContentProvider`, `usePublicContent`, `useSiteText`, `useSiteLanguage`, `SiteText`, `LanguageToggle`. The registry module is shared by client and Deno function.
- Compatibility: empty `site_content` yields a byte-identical UI. A missing view (app deployed before the migration) yields silent defaults. Deploy order is DB, functions, app. The `localStorage` key is new and no existing keys are touched. CSP is unchanged.

## 10. Acceptance checks

### Deterministic

- `npm run type-check`.
- `npm run lint`.
- `npx vitest run`: full suite green, pre-existing literal tests unmodified.
- Targeted: `npx vitest run src/__tests__/nativeDialogPolicy.test.ts src/__tests__/tokenFallbackAuditLint.test.ts src/__tests__/ownerSettingsData.test.ts src/__tests__/set-owner-role.test.ts src/__tests__/securityFindings.test.ts`.
- RLS integration against local Supabase: `npx supabase start && npx supabase db reset`, then `npx vitest run src/__tests__/rlsIntegration.test.ts`.
- `npm run verify:build`.
- `npm run test:e2e` (includes the new issue177 spec and the existing wp2, wp6, wp9, wp13 specs).
- Source scans: no `alert`, `confirm`, `prompt`, `window.alert|confirm|prompt`, `onbeforeunload`, or `addEventListener('beforeunload')` in `src`; no `dangerouslySetInnerHTML` in new or changed files; no raw hex outside `src/tokens`; `Control.css` canonical toggle and disabled rules unchanged (git diff check); the `OwnerSettingsPage.css` forced-colors block remains last.

### Functional

- A second owner save updates the single `owner_settings` row, and no second row is possible.
- With empty `site_content`, every in-scope surface is byte-identical to the WP0 baseline.
- Every inventory key is editable, disable-able, and blank-able with optional Spanish from the correct admin page.
- Anonymous users read only the view.
- A non-owner write gets 403.
- The AdminShell eyebrow follows `brand_name`.

### Review gates

CODE_REVIEW (judge), then Verifier, then Browser Validator. T1 cannot self-approve.

## 11. Browser UI validation brief

### Dialog policy (required)

No `alert`, `confirm`, `prompt`, `window.alert/confirm/prompt`, or `beforeunload` prompts anywhere. No confirmation is designed. If one becomes necessary it must use the existing app-owned accessible `Modal.tsx` plus `useFocusTrap.ts` (focus trap, Escape cancels, focus returns to the trigger, labelled dialog). Validation is inline (`role="alert"` per field, `aria-invalid`, `aria-describedby`), with the enclosing details opened and focus moved to the first invalid field. `src/__tests__/nativeDialogPolicy.test.ts` must pass with all new files included. Keyboard and focus verification of every new control (summary, toggles, reset, language toggle) is required in both unit tests and the browser pass.

### Launch and readiness

- Interactive: `npx supabase start`, then `npx supabase db reset` (migrations, `seed.sql`, full catalog; accounts `owner@test.local` and `student1-6@test.local` with the local test password from seed or README), then `npm run dev`. Ready when `http://localhost:5173` responds with the sign-in page (confirm the printed port).
- Production-parity and automated: `npm run test:e2e` (`playwright.config.ts` webServer `npm run build && netlify serve --context production --port 8888`, baseURL `http://localhost:8888` unless `E2E_BASE_URL` is set). `npm run preview` is not used.
- Reset between journeys: `npx supabase db reset` (empty `site_content` yields defaults) and clear the site-language `localStorage` key.
- Viewports: 320, 390, 900, 1440 CSS px (390, 900, 1440 required by the issue; 320 for WCAG reflow).

### Journeys and visible outcomes

1. The owner edits the sign-in heading `Learn in the open` in Brand & design, saves, signs out, and `/` shows the new heading with no layout jump.
2. Blank the sign-in heading and the page title, then save. Save succeeds with no error; the default heading text and default `document.title` render.
3. (a) Disable the catalog empty-state body: `/courses` (empty catalog fixture) shows no body and no gap. (b) Disable the catalog hero h1: the visible heading is gone, `Explore courses` is absent from the DOM and accessibility tree, and exactly one `<h1>` `Course catalog` is present (clip-rect hidden). (c) Disable the catalog preview heading: `Course preview` is absent and exactly one `<h1>` `Course details` is present. (d) Disable the sign-in heading: `Learn in the open` is absent and exactly one `<h1>` `Sign in` is present, followed by the visible h2 `Sign in`.
4. Enter Spanish for the sign-in heading, then choose Español on `/`. Spanish renders, `<html lang="es">` is set, and the choice persists after reload and on `/courses`.
5. A key with empty Spanish falls back to English while sibling keys show Spanish.
6. Near-`maxLength` strings render without horizontal scroll at all four viewports on sign-in, `/courses`, and a student page.
7. A blocked or failed `public_site_content` request leaves defaults in place with no error UI.
8. Keyboard-only pass over every summary, toggle, reset, Save, and language toggle, with visible focus and targets of at least 24 px.
9. Forced-colors pass on both admin pages and all three language toggle render sites (sign-in panel, catalog header, authenticated header and mobile menu).
10. Changing `brand_name` makes the AdminShell masthead eyebrow follow it; `brand.wordmark` stays independent.
11. The no-native-dialog scan is green.
12. An unsaved edit shows the polite pending line, distinct from and never simultaneous with the success line.
13. A disabled or blank page title yields the registry default title, not `brand_name`.
14. A disabled or blank meta description yields exactly `Lizbeth Spanish Course Platform - Phase 0 Scaffold`.
15. Shared tagline toggle off hides both full and short taglines at every breakpoint.
16. `student1` signs in, opens `/roadmap`, and switches to Español through the desktop header toggle at 900 and 1440 px and through the mobile menu toggle at 390 px. Spanish shows where provided and English elsewhere, the choice persists on reload, there is no sign-out, and focus stays on the pressed button. The toggle is absent from the header at 390 px and absent on every `/admin/*` route at every viewport. The student page heading, intro, and empty-state owner edits are also visible (for example `Your roadmap`, and the `Your courses` empty state).
17. Roadmap `Filed` label disabled: the text is gone while the count and percent and the `aria-label` stay intact. Footnote disabled: the whole line is gone and the bar is unaffected.
18. Header overlap sweep at 900, 1000, 1100, 1200, 1258, 1280, 1295, and 1366 px with the toggle present: no nav wrap, no Sign out clipping, and no collision with the fixed accessibility trigger.
19. A second owner account (created locally via `scripts/set-owner-role.ts` against the local stack) saves Business settings; there is still one `owner_settings` row and branding is unchanged for all users.

## 12. Risks and rollback

| ID | Severity | Risk | Mitigation | Rollback |
| --- | --- | --- | --- | --- |
| R1 | HIGH | Anonymous exposure regression (reverses part of `202607250002`) | Base table has no anon grants; select-only view of three columns; RLS integration tests prove anon cannot read `owner_settings` or `site_content` base tables or write anything; content is owner-authored public copy only | Forward migration revoking view grants (app degrades silently to defaults) |
| R2 | HIGH | Production singleton migration with duplicate rows present | Migration aborts on more than one row; read-only pre-check, backup, and user decision before push (WP9) | Forward migration dropping the singleton column and constraint; `owner_id` UNIQUE retained so a reverted function cannot create silent duplicates beyond today's behavior |
| R3 | HIGH | Deleting an owner account currently cascades away settings | `ON DELETE SET NULL`; verify no code depends on non-null `owner_id` (`ownerSettingsData` selects no `owner_id`) | Forward migration |
| R4 | MEDIUM | Byte-identical default drift (whitespace, entities, line break) breaking about 21 literal tests or visuals | WP0 baseline fixture, registry-vs-baseline test, unmodified literal tests, innerHTML check on the sign-in h1 | Revert PR-B |
| R5 | MEDIUM | Stored XSS or markup injection | Plain text only, React text nodes, sanitizer character rules, `dangerouslySetInnerHTML` scan; `document.title` and meta set via DOM properties, not innerHTML | Revert PR-B |
| R6 | MEDIUM | Layout overflow from long or Spanish text (390 px recurring defect per issue43 R2) | Per-key `maxLength`, overflow audit, journeys at 320/390/900/1440 | Owner resets keys; revert PR-B |
| R7 | MEDIUM | A disabled H1 leaves the page without a heading or still announces the disabled text | Structural fallback `h1` model plus tests asserting exactly one `h1` per state per surface | Revert PR-B |
| R8 | MEDIUM | Partial save across two endpoints | Dirty-scoped calls, explicit partial-failure alert, retained unsaved state | Owner retries |
| R9 | LOW | SEO: runtime title and meta are invisible to non-JS crawlers | Static `index.html` default retained (default pinned byte-identical; new wording is a follow-up issue) | Not applicable |
| R10 | LOW | Flash of default before owner text on slow networks | Accepted; defaults render immediately, then swap without layout transition; documented | Not applicable |
| R11 | LOW | Unsaved edits lost on tab close (`beforeunload` prohibited) | Pending-changes status line; accepted residual risk | Not applicable |
| R12 | MEDIUM | Authenticated header crowding or a11y-trigger collision from the new toggle | The documented overlap sweep (journey 18) and placement at 900 px and wider only (mobile uses the menu item) | Revert PR-B |

Containment: two PRs, each revertible via `git revert` of the merge; DB changes are forward-only; the app tolerates a missing view.

## 13. Dependencies

- WP1 (PR-A) merges before PR-B, unless the user approves a stacked PR.
- WP3 depends on the WP0 baseline fixture. WP4 and WP5 depend on WP3. WP6 and WP7 depend on WP3 through WP5. WP8 depends on WP2 through WP7.
- Local Supabase stack, Netlify CLI, and Playwright for validation.
- Production steps depend on explicit user approval and a drift-free `migration list --linked`.

## 14. Assumptions and decisions

### Safe assumptions

- "Left blank" means no override, so the default renders. The owner hides text via Disabled.
- A disabled H1-bearing key leaves the page with a fixed structural fallback `h1` (user rule: a page never lacks a valid H1).
- User rules: Spanish is optional for all text keys; blank means the default shows; disabled means hidden.
- The admin UI stays English.
- Spanish defaults are empty.
- Brand chrome keys live in `site_content` so `owner_settings` stays authenticated-only.
- `localStorage` language persistence is acceptable (no account-level preference).

### Resolved decisions

| ID | Decision | Resolution |
| --- | --- | --- |
| D1 | `brand.wordmark` key | Separate `site_content` key, distinct from `owner_settings.brand_name`. |
| D2 | Meta description default | Unchanged: byte-identical to `index.html:7`. New wording is a follow-up issue. |
| D3 | Owner-configurable default language for first-time visitors | Out of scope; follow-up issue. |
| D4 | Language toggle in authenticated chrome | In scope (PLAN_DUCK J-PLAN-001), per 5.8. |
| D5 | PR strategy | Two sequential PRs. |
| D6 | `L` monogram glyph as an editable key | Deferred to a follow-up issue: `App.tsx:666` is fixed-position SVG `<text>` (x=28, y=38, `text-anchor` middle in a 56×56 viewBox) with no auto-fit, and one shared key would inherit that overflow risk across `PublicCatalogPage.tsx:113` and `BrandLogo.tsx:31`. `BrandDesignPage.tsx:86` stays static (issue43 lock). |
| D7 | Roadmap ledger labels | Included: `roadmap.ledger_label` and `roadmap.ledger_footnote`. |

User rules recorded: Spanish is optional for all text keys; blank means the default shows; disabled means hidden.

### Follow-up issues (not in this plan)

- New meta description wording.
- Owner-configurable default language for first-time visitors.
- `L` monogram editable key.
- Brand-bound sign-in fallback heading (`Sign in to <brand_name>`).
- The pre-existing `PublicCatalogPage.css` forced-colors gap.

### Remaining open items (non-blocking, engineering)

- Per-key `maxLength` and near-limit counter thresholds.
- Business settings plain-input `:focus-visible` parity (the `OwnerSettingsPage.css:536-539` rule is brand-variant only).
- Confirmation of narrow-width overflow guards in `LoginForm.css` and `PublicCatalogPage.css`.
- `<details>` marker consistency.

## 15. Required approvals

- Explicit user approval of this plan before any engineering starts. Scribe updates this status only after the lead relays that approval.
- Explicit authorization for commits, pushes, and PR creation.
- Explicit per-step approval for every production action in WP9 (pre-check query, backup, `db push`, function deploys, Netlify deploy).

## 16. Engineering mode and downstream owner

- Engineering mode: standard. Serial T1 work packages; T2 on counted gate failures; no extreme-advisory team, because coupling is manageable with sequential WPs and two PRs.
- Team authorization: not applicable.
- Downstream owner: Engineering Fleet. The fleet receives only this approved plan path. A material assumption change before T1 edits is reported as `Plan stale`.

## Approval record

Approved by the user on 2026-10-03, together with the plans for the other three lizbeth-spanish issues among #173, #176, #177, and #178, in the orchestrator session.

- Covered: commits, pushes, and pull requests for this item. User instruction: create new branches and PRs as needed; existing unmerged local work in lizbeth_spanish lands as its own cleanup PR first.
- Not covered: production writes (storage re-tag, migrations, Edge Function deploys, Netlify deploys). Each needs a separate explicit user go-ahead after local validation.
