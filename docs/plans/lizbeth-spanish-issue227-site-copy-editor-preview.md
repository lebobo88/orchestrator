# Lizbeth Spanish: Issue #227 Site Copy Editor Effective-Text Preview and Provenance

Status: APPROVED for execution (2026-10-11; user verbatim: "Approve and agree"). Execution is stacked on `fix/224-226-signin-es-guidance` (PR #229) and is third in order.

Plan ID: `lizbeth-spanish-issue227-site-copy-editor-preview`. Task ID: `lizbeth-spanish-issue227-site-copy-editor-preview`. Route: engineering. Engineering mode: standard (T1 first-line; T2 on escalation). Team authorization: not applicable. Downstream owner: engineering-fleet.

Target repository: `lebobo88/lizbeth-spanish`. Evidence worktree (read-only): `H:\CommandCenter\orchestrator\lizbeth_spanish-224` (PR #229 state: branch `fix/224-226-signin-es-guidance`, commit `2afb6d5`, unmerged), compared against `origin/main` `88b43fd` at `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b`. Paths and line numbers below are from the 224 worktree and are re-verified at S0.

Parent plan: `H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-issue-batch-2026-10.md` (Wave 2b-1). Related plan: `docs/plans/lizbeth-spanish-issue228-create-and-assign.md` (runs before this one).

Audience: the user (approver and sole merger), the engineering fleet, the Verifier and the Browser Validator.

Evidence labels: **Observed** means read at file level in the named worktree. **Inference** is a conclusion drawn from observations. **Assumption** is taken as true until a runtime step verifies it. **Unknown** is not yet established.

---

## 1. Outcome

On `/admin/brand-design` and `/admin/business-settings`, the owner (Lizbeth) can tell for every editable key where it appears, what visitors see now in English and Spanish and why (provenance), what an unsaved draft will look like, and whether the text is shown or hidden, without guessing.

## 2. Branching and delivery policy

User decision 2026-10-11 (relayed by the lead): the user prefers stacking.

- Branch `feat/227-site-copy-editor-preview` is created from `fix/224-226-signin-es-guidance` (`2afb6d5` or its then-current head).
- PR base is `fix/224-226-signin-es-guidance`. The PR body says "Closes #227" and "Depends on #229; merge #229 first".
- After #229 merges, retarget the PR to `main` and rebase; re-run the gates if the rebase changed anything.
- Reason: #227's provenance must include PR #229's built-in Spanish defaults (registry `default.es`, `fallbackH1Es`) and the resolver's D-2 Spanish order with `sourceLang`, none of which exist on `main`.
- No pushes to `main`; no agent merges; no hosted, Netlify or Edge deploy and no hosted content writes without separate approval.
- No migration. No Edge deploy is needed for correctness: the registry `surface` prose is not used in site-content Edge validation, so redeploying is a normal later release step.

## 3. Scope and non-goals

**In scope:** the shared `SiteContentFields` / `KeyRow` presentation; the `ShownToggle` call site; rewrites of about 6 multi-placement registry `surface` strings; appended `badge--provenance-*` variants; an additive admin-only `contentStatus` on `PublicContentContext`; tests.

**Non-goals:**

- Changing the resolver order (D-2 is fixed).
- Prefilling empty overrides with defaults.
- Changing single-Save, dirty-only payloads, Reset staging, or partial-save-error handling.
- Changing `LanguageToggle` or the editor toolbar toggles.
- Editing `Control.tsx` or `Control.css` shared rules.
- Changing `BrandDesignPage`'s static colour preview (`data-testid="brand-live-preview"`), which stays and is not described as a site-copy preview.
- Changing the visitor silent fallback.
- Translating admin chrome.
- Adding new keys (#191 and #208 are later waves).

## 4. Repository findings

Observed, paths in the 224 worktree.

1. `src/components/SiteContentFields.tsx:35-38` `savedDraft` maps an absent row to `''`. `TextInput` (`:259-300`) binds the raw overrides. No resolved text is shown, so an empty input does not mean empty visitor copy.
2. `src/lib/siteContentResolve.ts:54-73` `resolveSiteText` implements the Spanish D-2 order: disabled is hidden; a non-blank stored ES wins; no custom EN (blank, or equal to `default.en`) gives `default.es`; otherwise the custom EN with `sourceLang 'en'`; otherwise `default.en`. Invisible-only text counts as blank via `isInvisibleOnly` (`:42`). `:79-86` `resolveMetaText` (title/meta blank or disabled gives `default.en`). The editor uses neither.
3. `src/components/SiteText.tsx:37-53`: a disabled h1 key mounts `fallbackH1` / `fallbackH1Es` ("Sign in" / "Iniciar sesión"); English shown to an ES visitor gets `lang="en"`. `renderSiteTextLines` (`:21-29`) renders `\n` as `<br>` with React text nodes only.
4. `src/lib/siteContentRegistry.ts:26-47` entry model: `key`, `group`, `page`, `surface` prose, `label`, `default {en, es?}`, `maxLength`, `multiline`, `role` (h1, text, title, meta), `toggleGroup`, `fallbackH1`, `fallbackH1Es`. Groups at `:60-70`. `default.es` exists only on signin keys (from #224). `catalog.heading` has `fallbackH1` without `fallbackH1Es` (`:182-189`). `meta.page_title` and `meta.description` have no `default.es` (`:261-277`). Some surfaces list several places (`brand.wordmark`: "Sign-in wordmark, catalog header and catalog footer"; `brand.product_title`).
5. `KeyRow` (`:330-345`) shows the label, a note "{surface}. Leave blank to use the default[; this text is currently hidden]", EN and ES inputs, the toggle and Reset. `ShownToggle` (`:302-315`): `Control tier="toggle"`, `aria-pressed={enabled}`, `aria-label` "Shown on site: <label>", and a visible text that is always "Shown on site". The shared toggle CSS `src/components/ui/Control.css:163-195` changes only translate and shadow.
6. `src/pages/BrandDesignPage.tsx:96-106` has a static preview (hardcoded name plus swatches). `src/__tests__/siteContentAdminForm.test.tsx` about `:298-303` asserts it stays static. The test at `:176-184` queries the toggle by "Shown on site: Dashboard subtitle" with `aria-pressed` `'true'` before clicking.
7. `src/context/PublicContentContext.tsx`: content map; `/admin/*` forces English (J-177-001); fetch on mount with a silent catch (about `:95-107`). `src/services/siteContentData.ts:32-46` `getPublicSiteContent` never throws and returns `{}` on failure, so the editor cannot tell loading or failed apart from "no saved rows".
8. `useSiteContentForm` (`:68-227`): single Save, dirty-only payload, Reset stages `default.en` into EN and clears ES (no save), `toggleGroup` fan-out for `setEnabled`, focus to the first invalid field, commit sets base and clears edits.

**Root cause (confirmed):** the editor exposes raw overrides instead of resolved effective text; placement metadata is only lightly exposed; the visibility control's visible word never changes; and the admin form has no read status. **Not root causes:** the toggle works and carries an accessible name; the resolver is correct.

**Environment:** same port-shifted untracked mirror recipe as the #228 plan. Windows reserves 54314-54413; precedent `H:\CommandCenter\orchestrator\lizbeth_spanish-224-run` with api 64321, db 64322, studio 64323; `.env.local` `VITE_SUPABASE_URL=http://127.0.0.1:64321`; live tests hardcode 54321 and are rewritten in the mirror only, which is never committed.

**Known pre-existing failures to compare against, not fix:** #218 (10 e2e tests across 7 specs, including `gap-1-owner-settings-persistence` on the owner-settings path); vitest require-backup plus 2 `issue5-services` PDF tests; `fieldJournalTokens` parent-config failure.

## 5. Research

None. Local source is sufficient.

## 6. Design route and reviewed design handoff

`DESIGN_ROUTE`: profile standard. Reasons: multi-state component change on two existing owner pages. Agents: design-director, ux-architect, visual-system-designer, design-reviewer. Prototype: forbidden. Model: sonnet. Existing-system mode: extend (binding Field Workbook identity: `docs/plans/lizbeth-spanish-course-platform.md` sections 4.2, 4.5, 8; `docs/plans/lizbeth-spanish-issue177-owner-editable-site-text.md`).

### 6.1 Design review status

- Round 1: NEEDS_REVISION with 6 findings (a journey that contradicted the resolver; derivation-table invariant; title/meta collapse condition; `lang` on the structural fallback literal; pinned toggle label template; missing contract fields). All were remediated in one Director revision.
- Round 2: confirmed all six resolved but found one new HIGH defect introduced by the revision: the pinned toggle mapping was inverted relative to source (`aria-pressed={enabled}`). Under the design contract, a second disagreement is a user decision.
- USER DECISION 2026-10-11: option (a). Accept the reviewer's one-line correction as part of the reviewed design: `aria-pressed="true"` (enabled) maps to the visible word "Shown on site"; `aria-pressed="false"` (disabled) maps to "Hidden from site"; `aria-label` = `"${word}: ${label}"`. With this correction the design is accepted for planning; no further review round was required.

### 6.2 Selected direction

Field Workbook extension. No new visual system, geometry, hue, typeface, schema or dependency. Static presentation layered on the existing hook state (`draftFor`, `isDirty`, `errors`, `openGroups`).

### 6.3 Placement

Keep the registry `surface` prose as the only placement field. Rewrite the roughly 6 multi-placement surfaces into a "Page — location" segment pattern. Example: `brand.wordmark` becomes "Sign-in page — wordmark, Catalog page — header, Catalog page — footer"; `brand.product_title` similarly. `default.en` stays byte-identical. `KeyRow` shows a wrapping placement line under the label: never truncated, no tooltip, plain text.

### 6.4 Per-KeyRow order

Label, placement line, EN input, EN effective-text preview plus provenance tag plus draft marker, ES input, ES preview plus tag plus marker, `ShownToggle`, Reset, then the shortened note (the "leave blank" clause only). Toggle group (`signin.tagline_full` / `signin.tagline_short`): each member row keeps its hierarchy with no toggle of its own; one shared note and control block follows both, bracketed as one unit.

### 6.5 Provenance taxonomy (8 values)

1. Custom text
2. Falls back to English
3. Built-in Spanish default
4. Built-in default
5. Hidden (role text)
6. Structural fallback heading: '<literal>' (role h1)
7. Document title default
8. Search description default (values 7 and 8 apply to title/meta)

### 6.6 Derivation table

The tag is computed SOLELY from the `resolveSiteText` / `resolveMetaText` output `{state, sourceLang}` for that language plus `entry.role`, whether `entry.default.es` exists, and `entry.fallbackH1` / `fallbackH1Es`. The admin layer implements no independent non-empty or equality check.

| Condition | Tag |
| --- | --- |
| disabled, role text | "Hidden" |
| disabled, role h1 | "Structural fallback heading: '<fallbackH1Es if lang es and present, else fallbackH1>'" |
| disabled, role title / meta | "Document title default" / "Search description default" |
| en, edited | "Custom text" |
| en, blank | "Built-in default" |
| es, edited, sourceLang es | "Custom text" |
| es, blank, sourceLang es (default.es exists) | "Built-in Spanish default" |
| es, edited, sourceLang en | "Falls back to English" |
| es, blank, sourceLang en | "Falls back to English" |

Title/meta: a single tag is rendered once only when both columns resolve uncustomized (blank or disabled; `resolveMetaText` yields identical text). A customized EN splits into EN "Custom text" and ES "Falls back to English".

### 6.7 Row source and draft marker

The preview resolves a `SiteContentRow` built from the current draft: `{ key, value: { en: draftFor(key).en, es: draftFor(key).es }, enabled: draftFor(key).enabled }`. An adapter is required because `Draft` is flat. The saved baseline feeds only the existing `isDirty` comparison for the draft marker; there is never a second "live" preview. The draft marker "Unsaved draft" shows only while `isDirty(key)` and is silent once saved (a calm "Saved" caption is permitted).

### 6.8 Page-level read status

Additive admin-only `contentStatus: 'loading' | 'ready' | 'unavailable'` on `PublicContentContext`, computed in the same fetch effect ('loading' before it settles, 'ready' on success, 'unavailable' on the existing silent catch path). `getPublicSiteContent`'s signature and never-throw contract are unchanged, and visitor pages ignore `contentStatus`. One `aria-live` polite region above the groups with two distinct messages; it never blocks editing or Save. The timeout threshold is an engineering choice.

### 6.9 Visibility control (corrected per user decision)

Exactly one visible text node `word`: "Shown on site" when `aria-pressed="true"` (enabled), "Hidden from site" when `aria-pressed="false"` (disabled). An `aria-hidden` glyph pair: ● (shown) and ○ (hidden). `aria-label` = `"${word}: ${label}"`. Never disabled; keyboard-operable in both states. Toggle-group fan-out unchanged. Existing `aria-pressed={enabled}` semantics preserved.

### 6.10 Accessibility

- Preview and tag text is not a live region. It is appended to the input's existing `aria-describedby` chain (CharCounter pattern).
- No new tab stops (tab order: EN input, ES input, toggle, Reset).
- State is always carried by text.
- Preview Spanish content carries `lang="es"`. English shown in the ES column carries `lang="en"`, including the structural fallback literal when it is `fallbackH1` with no `fallbackH1Es` (`catalog.heading` "Course catalog"). No override applies for "Iniciar sesión".
- Admin chrome is English only.

### 6.11 Visual

- Preview: thin top rule plus an indented paragraph (not a card). Resolved text in quote marks in `--color-ink-900`, chrome in `--color-ink-700`. Rendered only via `renderSiteTextLines` (no HTML).
- Provenance tags extend Badge: `badge--provenance-custom` reuses `.badge--inclusive` (6.87:1); `-fallback` reuses `.badge--dialect` (6.16:1); `-hidden` is new: dashed ink-700 on paper-200 (7.47:1, the `Control.css` disabled signature); `-structural` reuses `.badge--register` (15.25:1) with a nested span that drops uppercase and tracking for the quoted literal; the plain baseline values reuse `.badge--register`. Ratios are cited from `docs/plans/lizbeth-spanish-issue35-controls-fields-marks.md:218,230`.
- Draft marker: a plain caption (not a Badge, never warning or error colours).
- Toggle-group bracket reuses the hairline-rule device at a lighter indent than the ES sub-row.
- Page notice: neutral `--color-ink-700`. `color.state.info` is declared in `semantic.json` but absent from the compiled `field-workbook.generated.css`, so ship on `--color-ink-700`.
- Motion and asset spec: not applicable (● ○ are text characters).

### 6.12 Engineering invariants (all persisted)

1. Reuse `resolveSiteText` / `resolveMetaText` only; no duplicate rules.
2. The preview is always resolved from the draft row adapter.
3. `renderSiteTextLines` is the only line renderer, never HTML.
4. `savedDraft`, `isDirty`, `dirtyCount`, `setEnabled` fan-out, `resetToDefault` staging and commit are unchanged; preview interaction never changes dirty count, saves, or visitor locale.
5. `Control.tsx` / `Control.css` shared rules are not edited, only the `ShownToggle` call site with the pinned corrected formula; toolbar toggles and `LanguageToggle` are untouched.
6. Existing Badge variants are unmodified; provenance variants are appended only.
7. The `BrandDesignPage` static preview is untouched; the `siteContentAdminForm.test.tsx` about-`:298` static assertion passes unmodified.
8. The visitor silent fallback and the `getPublicSiteContent` contract are unchanged; `contentStatus` is additive and admin-only.
9. `lang="en"` on an English structural fallback literal in the ES column.
10. Title/meta single-tag collapse only when uncustomized.
11. `aria-describedby` chain append only; no keystroke live region.
12. No native dialogs.
13. Admin chrome English only.
14. Forced-colors additions are appended to existing `@media (forced-colors: active)` blocks, respecting their source order.
15. The registry stays dependency-free and Deno-importable (explicit `.ts` imports), and `default.en` stays byte-identical (`siteContentRegistry.test.ts` baseline).

### 6.13 Permitted variation and open items

Permitted variation: spacing from `--space-*`; separator glyphs; wording of the remaining surface rewrites in the "Page — location" pattern; silence-as-saved versus a calm "Saved" caption; one-column versus side-by-side EN/ES previews at 1440; `contentStatus` timeout; position of the single title/meta tag.

Open, non-blocking items with defaults: surface rewrite wording (engineer/Scribe pass); silence-as-saved (default); info token (`--color-ink-700`); timeout (engineering); empirical 390 indent check (Browser Validator).

## 7. Judge route

Standard-risk task. CODE_REVIEW eligible (cap 2). VISUAL_REVIEW optional within the same cap. No PLAN_DUCK required (medium-low risk, no migration). Deterministic failures dominate. Policy per `docs/JUDGE-CONTRACT.md`. No judge result has been observed for this plan; none is claimed.

## 8. Browser UI dialog policy

Required. No `alert`, `confirm`, `prompt`, `window.*` forms or `beforeunload`. No modal is added (Reset stays non-destructive draft staging). Deterministic scan plus a runtime dialog listener.

## 9. Ordered work

One writer. This work runs THIRD, after the #140/#183 PR and the #228 PR.

- **S0 (T1):** fetch; create the branch from PR #229's then-current head; record SHAs; re-verify cited lines; build the port-shifted mirror; run the baseline (full vitest and full e2e on a fresh `db reset`) and compare with the known failures.
- **S1:** tests first (TDD list in section 11).
- **S2:** resolver-driven provenance helper, a pure function in `src/lib` (for example `siteContentProvenance.ts`) mapping resolver output plus entry to a tag, with no independent checks.
- **S3:** `PublicContentContext` `contentStatus` (additive).
- **S4:** `KeyRow` and toggle-group presentation: placement line, previews, tags, draft marker, page notice.
- **S5:** `ShownToggle` call site with the corrected formula and glyph.
- **S6:** `Badge.css` provenance variants plus `OwnerSettingsPage.css` layout (forced-colors appended).
- **S7:** registry `surface` rewrites (prose only).
- **S8:** gates: T1, CODE_REVIEW, Verifier, Browser Validator, PR opened (stacked). Two counted T1 gate failures escalate to T2; two counted T2 failures block for user review.

## 10. Interfaces and data

`PublicContentContextType` gains `contentStatus` (additive). `NO_PROVIDER_VALUE` gets `'ready'` so bare-rendered tests and pages keep working (an **Assumption** T1 confirms). A new pure provenance helper. The registry `surface` strings change (prose only; `default.en` byte-identical; Deno-importable). New CSS classes only. No database, migration, RLS or Edge contract change.

## 11. Acceptance and validation

### 11.1 Commands

Run in the mirror. Full suites are required; targeted runs are additional.

- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`.
- `npx supabase start`; `npx supabase db reset`; `docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish`.
- `npx vitest run` (full; no new failures against baseline).
- `npx vite --port 5180 --strictPort`; `E2E_BASE_URL=http://localhost:5180 npx playwright test` (full).
- No-native-dialog scan: `rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"` returns zero product hits, plus failing `page.on('dialog')` listeners in new or changed specs.

### 11.2 Targeted

- `npx vitest run src/__tests__/issue227-siteContentProvenance.test.ts src/__tests__/issue227-siteContentPreview.test.tsx src/__tests__/siteContentAdminForm.test.tsx src/__tests__/siteContentResolve.test.ts src/__tests__/siteContentRegistry.test.ts src/__tests__/PublicContentContext.test.tsx src/__tests__/siteTextWiringPublic.test.tsx src/__tests__/wp6BrandDesignConformance.test.tsx src/__tests__/Issue4SettingsPages.test.tsx src/__tests__/issue177SiteContentEdgeLive.test.ts src/__tests__/LanguageToggle.test.tsx`
- e2e: `npx playwright test src/__tests__/e2e/issue227-site-copy-preview.spec.ts src/__tests__/e2e/issue177-site-text.spec.ts src/__tests__/e2e/issue177-overflow.spec.ts src/__tests__/e2e/wp6-brand-design.spec.ts src/__tests__/e2e/wp7-settings.spec.ts` (`gap-1-owner-settings-persistence` compared with #218).
- T1 confirms each existing file exists at S0 and records any that do not.

### 11.3 TDD list

- The provenance helper covers every derivation-table row, including: no saved row; custom EN; custom ES; ES falls back to custom EN; ES falls back to default EN (key without `default.es`); stored EN equal to `default.en` with ES blank on a signin key giving "Built-in Spanish default"; blank and invisible-only values; disabled text; disabled h1 with and without `fallbackH1Es`; title/meta uncustomized collapse and customized split; multiline (line breaks preserved).
- `KeyRow` renders the placement line and both previews and tags.
- Typing updates the preview to "Custom text" with the typed text.
- Reset shows "Unsaved draft" and recomputes without a network call.
- Toggling flips the word, `aria-pressed` and the `aria-label` ("Shown on site: X" / "Hidden from site: X") and recomputes the previews to Hidden or structural. The hidden control stays enabled. The tagline group has one shared control and both previews recompute together. Hide and show preserves custom text.
- Preview interaction never changes `dirtyCount` except through real edits, never calls `saveSiteContent`, and never changes `localStorage` `lizbeth.siteLanguage` or `html lang`.
- `lang` attributes as specified.
- `contentStatus`: loading to ready; loading to unavailable (the notice shows, editing and Save still work); visitor pages' rendering is unchanged.
- Existing single-Save, dirty-only payload, partial-save-error preservation, plain-text validation, owner authorization and reset-semantics tests still pass unmodified, except the toggle-name queries, which change intentionally only where they re-query after a toggle.
- The static `brand-live-preview` assertion passes unmodified.
- The registry baseline (`default.en` byte-identical) passes.

## 12. Browser UI validation

- **Launch and readiness:** in the port-shifted mirror of the #227 worktree: `npx supabase start`; `npx supabase db reset`; docker restart (as above); `npx vite --port 5180 --strictPort`; ready when `http://localhost:5180` serves the sign-in page.
- **Base URL:** `http://localhost:5180`; pages `/admin/brand-design` and `/admin/business-settings` as `owner@test.local` / `password`.
- **Fixture and reset:** local-only service-role writes to public `site_content` rows on `http://127.0.0.1:64321` (never hosted), restored by `npx supabase db reset`. Rows needed: no saved row; custom EN plus ES; EN custom with ES blank; a disabled text row; disabled `signin.heading` (has `fallbackH1Es`) and disabled `catalog.heading` (no `fallbackH1Es`); `meta.page_title` and `meta.description` uncustomized and EN-customized; the `signin.tagline_full` / `signin.tagline_short` pair; a slow and a failed `public_site_content` fetch via Playwright route interception.
- **Viewports:** 390x844 and 1440x900 for every journey (320 and forced-colors spot checks).

### Journeys and visible outcomes

- J1: `brand.wordmark` placement line names all three places, wraps, and is not truncated.
- J2: an EN input with no saved value starts at "Built-in default" plus the default text; typing shows "Custom text" plus the typed text per keystroke, with no save and no live announcement.
- J3: EN custom with ES blank: ES shows "Falls back to English" with `lang="en"`.
- J4: typing Spanish: ES shows "Custom text", with no `lang="en"`.
- J5: hide a text row: word "Hidden from site", `aria-pressed` false, `aria-label` "Hidden from site: <label>", previews "Hidden", control still enabled, no save. Show again restores "Shown on site" with `aria-pressed` true and custom text intact.
- J6: hide `signin.heading`: ES shows "Structural fallback heading: 'Iniciar sesión'" without a `lang` override. Hide `catalog.heading`: "'Course catalog'" with `lang="en"` in the ES column.
- J7: `meta.page_title` uncustomized shows one "Document title default" tag; customizing EN splits it into EN "Custom text" and ES "Falls back to English".
- J8: Reset on a customized row: "Unsaved draft", previews recompute, no network request.
- J9: Save: markers clear together with the existing dirty-count and success state.
- J10: forced save failure: existing error and focus behaviour unchanged, markers persist.
- J11: tagline group: one shared bracketed control, both previews recompute.
- J12: delayed or failed fetch: the page notice shows the loading versus unavailable wording, then clears on ready; editing and Save work; a visitor page (`/`) is unchanged.
- J13: keyboard: tab order unchanged, no new tab stops, visible focus.
- J14: forced-colors and greyscale: toggle state readable via word, glyph and border; tags readable by text.
- J15: no native dialog events; axe zero critical or serious; no horizontal scroll at 390 and 320; the preview text matches what the public page renders for the same saved state (open `/` in EN and ES after saving one custom row and compare).

Evidence: screenshots under `browser-validation-artifacts/issue-227/`.

## 13. Risks, rollback, assumptions and decisions

### Risks

| ID | Risk | Mitigation |
| --- | --- | --- |
| R1 | The tag logic diverges from the resolver | Pure helper plus table tests, no independent checks |
| R2 | The toggle mapping is inverted | Pinned formula, the existing test at `:176-184`, and J5 |
| R3 | The stacked base changes when #229 is revised or merged | Rebase and re-run gates; stale-plan trigger |
| R4 | Surface rewrites break registry baselines or the Deno import | Prose only, baseline test, Edge live test |
| R5 | `contentStatus` changes visitor behaviour | Additive field, visitor tests |
| R6 | Contrast | Only verified pairs |

Rollback: the PR is unmerged until the user merges; a post-merge revert has no data impact (no migration).

### Assumptions

- PR #229 merges before #227. If #229 changes materially, this plan goes stale.
- `NO_PROVIDER_VALUE` `contentStatus` is `'ready'`.

### Decisions

| ID | Decision | Status |
| --- | --- | --- |
| Design | Accept the reviewer's toggle correction as part of the reviewed design | DECIDED 2026-10-11 (option a) |
| Branching | Stack on PR #229's branch | DECIDED 2026-10-11 |
| Approval | Explicit user approval of this plan before T1 | REMAINING |

### Stale-plan conditions

#229 changes the registry, resolver or `SiteText` contract; `origin/main` changes cited paths; the issue's scope changes.

### Approval gate

This plan is DRAFT. T1 execution requires explicit user approval relayed by the lead; Scribe then updates this status to approved. No approval has been recorded.
