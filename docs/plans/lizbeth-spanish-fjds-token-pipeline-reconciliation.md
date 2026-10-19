# Lizbeth Spanish, Field Journal DS: token pipeline reconciliation

Status: Approved. Approved by the user (rob.hasselbach@gmail.com) in this session, verbatim reply "approve," sent in direct response to the orchestrator's question "Do you approve this plan for execution?" regarding this specific plan document. This is a direct, plan-referencing approval, not an approval inferred from the standing session goal alone. See "Required approvals" below for the full approval record. Approval of this document authorizes ONLY the token-pipeline reconciliation scoped below (backlog item 1). It does not authorize any of backlog items 2-7; each needs its own plan and its own approval.

Plan ID: `lizbeth-spanish-fjds-token-pipeline-reconciliation`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` (separate git repo; GitHub remote `lebobo88/lizbeth-spanish`)
Engineering mode: standard
Team authorization: not applicable
Downstream owner: `engineering-fleet`
Design route: compact (`design-generalist` plus mandatory independent `design-reviewer`; prototype forbidden; model tier Sonnet; existing-system mode: preserve)

## Outcome and audience

The Field Journal design system's token pipeline is compiled for real for the first time. The app's shipped token file (`src/tokens/field-workbook.generated.css`) is proven to be a lossless, tool-verified reproduction of its authored DTCG source (`.atelier/tokens/field-workbook.tokens.json`), rather than an unverified hand transcription, and the stale, broken generator output (`.atelier/tokens/field-workbook.css`) is fixed.

Audience: the engineering fleet executing this plan, and the user tracking Field Journal DS completion across GitHub issues #31-#44.

## Scope and non-goals

**In scope:**

1. Confirming the Atelier `projectRoot` fix is real for `lizbeth_spanish/`-prefixed paths.
2. Running the real Atelier pipeline against `.atelier/tokens/field-workbook.tokens.json` to produce regenerated output.
3. A two-check verification: a primary source-to-output oracle comparing regenerated output against an independently resolved DTCG source map (correctness), and a secondary output-to-shipped comparison against the hand-transcribed file (migration regression), both order-insensitive and per-custom-property.
4. Resolving every genuine mismatch found by either check, using the Branch A adjudication rule below, in the stated risk order.
5. Installing the verified regenerated output as the shipped token file and removing its now-false "not verified-by-tool" header.
6. Confirming the Branch B carve-out (`App.css:40`'s `--color-focus-ring`) survives untouched.
7. Updating three named tests (`statusColorContrast.test.ts`, `typographyFourHands.test.ts`, `tokenFallbackAuditLint.test.ts`) to assert against regenerated pipeline output instead of hand-written values.
8. A documentation-only correction to `band.advanced`'s `$description` comment text.
9. Re-running the named contrast re-validation scope.
10. Full deterministic gate (test suite, token fallback audit lint, no-native-dialog scan), then an independent Verifier pass, then a Browser Validator pass on the six no-fallback focus consumers, `.admin-shell-link`, and the other journeys described below.
11. Landing a repo-local, re-runnable primary-oracle script (suggested `scripts/verify-token-pipeline.mjs`, or an equivalent Vitest case) that resolves the DTCG source independently and compares it to regenerated output. This script is itself a deliverable, not a throwaway.
12. Creating and closing a GitHub tracking issue for this work per the Issue tracking section below.

**Non-goals — explicitly deferred to their own future plans and approvals:**

- Re-validating the token-layer issues (#31, #32, #33) against the regenerated pipeline beyond the three named test files (backlog item 2).
- Authenticated-route visual validation of the screen issues: #38 roadmap, #39 week detail, #40 flashcards, #41 feedback, #42 owner dashboard/roster (backlog item 3).
- Unauthenticated-route visual validation of #37 login/signin and #43 brand/catalog (backlog item 4).
- Component-level fidelity re-check of #34 journal devices, #35 controls/fields/marks, #36 week card/chunks/ledgers/metric plate (backlog item 5).
- #44 derived owner pages (backlog item 6).
- Closing any GitHub issue (backlog item 7); the four deferred pre-existing issues #10, #11, #28, #29 (`blocked:field-journal-ds`) remain blocked until then.
- Introducing any new token name, palette entry, type size, radius, shadow, or motion value. Only the resolution of existing pipeline output/hand-file disagreement is authorized.
- Any change to `lizbeth_spanish\atelier.config.json`. Only the root-level `H:\CommandCenter\orchestrator\atelier.config.json` may be tuned if needed.
- Any Docker, Supabase, or dev-server infrastructure change.

## Repository findings

Verified by direct file evidence, not by trusting either the older per-issue plan's completion claim or the raw "all 14 issues OPEN" GitHub state alone:

- `H:\CommandCenter\orchestrator\lizbeth_spanish\.atelier\tokens\field-workbook.tokens.json` — the DTCG generator SOURCE. Current and rich, carrying every Field Journal token through issue #41.
- `H:\CommandCenter\orchestrator\lizbeth_spanish\.atelier\tokens\field-workbook.css` — the generator OUTPUT. Stale and pre-Field-Journal: only ~29 declarations. Missing the entire Field Journal layer (no `ink-1000`, `ink-moss`, `ink-slate`, `paper-300`, `brass-300`/`700`, `status-*`, `roadmap-*`, `border-width-hairline`/`rule`, `motion-duration-flip`/`page-turn`/`press`/`stamp`, `focus-ring-*`, `control-height`, `hit-target-min`, or the typography scale). Still carries `--color-focus: #0284c7` (generic sky blue) where the source specifies `#3d5f6b` (ink.slate). Contains a literally unresolved reference: `--shadow-print: .3rem .3rem 0rem 0rem {color.brass.500};`.
- `H:\CommandCenter\orchestrator\lizbeth_spanish\src\tokens\field-workbook.generated.css` — the hand transcription the app ships, self-labeled "MANUALLY TRANSCRIBED 2026-08-31 because the Atelier MCP server's project-root resolution was broken... Regenerate via the real pipeline and diff against this file once Atelier is restored; do not treat this file as verified-by-tool."
- `H:\CommandCenter\orchestrator\lizbeth_spanish\src\App.css:13` — `@import url('./tokens/field-workbook.generated.css')`, confirming the hand file is genuinely what ships.
- `src/App.css:32-40, 209-214, 749` — the separate `--color-focus-ring: var(--color-ink-slate, #3d5f6b)` mechanism and its consumers, distinct from `--color-focus`.
- `src/__tests__/tokenFallbackAuditLint.test.ts:18-24, 166-174, 480-490` — `FOCUS_RING_EXCEPTION_RE`, a line-exact `App.css` whitelist, including a test asserting a hex literal one character outside the documented line still fails.
- Six focus consumers with NO `--color-focus` colour fallback: `src/pages/OwnerSettingsPage.css:270`, `src/pages/RoadmapPage.css:96`, `src/components/SegmentLedger.css:69`, `src/components/ui/Field.css:43`, `src/components/ui/Control.css:139`, `src/components/Modal.css:36,89` (Modal has a `3px` width fallback but no colour fallback).
- `src/components/FlashcardsViewer.css:127,283` — the only consumer with a full fallback chain; not representative of pipeline health generally.
- `src/components/AdminShell.tsx:44` / `src/components/AdminShell.css:47` — renders `.admin-shell-link` (NOT `.admin-shell-tab`, which exists only in `App.css` style rules and tests).
- `H:\CommandCenter\orchestrator\lizbeth_spanish\design\field-journal\ADOPTION-PLAN.md` — authoritative section-to-issue decomposition; ADOPTION-PLAN issue N = GitHub issue N+30.
- `H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-design-reference-coverage-map.md` — prior coverage audit, independently corroborating the discrepancy resolution below.

**Confirmed by independent design review:** a full line-by-line comparison found the DTCG source and the shipped hand file already agree on every resolved value inspected. Only the stale generator output genuinely disagrees. The reconciliation task is therefore narrower than "reconcile three conflicting sources": it is to prove a real regeneration reproduces the already-correct hand file losslessly, and to fix the broken generator output.

Research evidence: none. No external or current-fact question was material to this plan; all findings are local file evidence, read in full for the three token artifacts.

## Discrepancy resolution — GitHub issues #31-#44 live state

The user's Phase 0 check found GitHub issues #31-#44 all OPEN, contradicting an older plan's claim that #31-#37 had "landed, verified, browser-validated, and design-reviewed PASS." This section resolves that contradiction by direct file evidence rather than by trusting either source.

**Resolution: option (a) — the work landed; the issues were deliberately left open.** This is a tracking-and-verification-gate state, not an implementation gap.

Evidence supporting this resolution:

- `src/tokens/` contains all five token artifacts (`primitives.json`, `semantic.json`, `components.json`, `tokenSystem.ts`, `field-workbook.generated.css`) — #31/#32 landed.
- `field-workbook.generated.css` contains the issue #33 status/roadmap component-token block and the issue #40 motion-duration additions, each with in-file provenance comments — #33 and #40 landed.
- `src/components/journal/` contains ClipRing, Folio, JournalEmptyState, Stamp, TabStack plus `journal-devices.css` — #34 landed.
- `src/__tests__/` contains `ClipRing.test.tsx`, `Folio.test.tsx`, `JournalEmptyState.test.tsx`, `Control.test.tsx`, `Field.test.tsx`, `Badge.test.tsx`, `statusColorContrast.test.ts`, `tokenFallbackAuditLint.test.ts`, `nativeDialogPolicy.test.ts` — #33/#34/#35 landed with test coverage.
- `.atelier/tokens/field-workbook.tokens.json` carries authored token entries explicitly annotated for issues #33, #35, #36, #37, #38, #39, #40, #41 — those issues' design decisions are all recorded in the source of truth.
- `docs/plans/lizbeth-spanish-design-reference-coverage-map.md` independently records implementation, verification, browser validation, and design review evidence on every one of #31-#44, and states each was left OPEN as "conditionally complete" pending one shared re-verification gate owned by #31.

**Why the issues were left open, and what actually remains.** Every one of the 14 issues is blocked on a single shared gate: the Atelier MCP `projectRoot` misconfiguration prevented the real token pipeline from ever running, so `src/tokens/field-workbook.generated.css` was hand-transcribed as a documented, one-time exception (see the file's own header, quoted above). Until that pipeline runs for real and its output is verified against the hand file, none of the 14 issues can be honestly closed against their own stated Atelier-specific acceptance criteria.

**This is also the leading root-cause candidate for the user's reported visual mismatch.** The app's entire visual foundation is a hand-typed file that no tool has ever validated against its source, and the project's token tests assert those same hand-written values, making them self-confirming and structurally incapable of detecting a transcription error.

**Confirmed state of the three token artifacts** (each read in full during planning):

1. `.atelier/tokens/field-workbook.tokens.json` — DTCG source. Current through issue #41.
2. `.atelier/tokens/field-workbook.css` — generator output. Stale, pre-Field-Journal, missing the whole Field Journal layer, wrong `--color-focus`, one unresolved `{color.brass.500}` reference.
3. `src/tokens/field-workbook.generated.css` — the hand transcription the app ships; already agrees with artifact 1 on every value independent design review inspected.

**Scope note for this plan.** This is a static-file audit. It establishes that the code landed and why the issues remain open; it does not by itself re-validate rendered pixel fidelity for any section of the app. Rendered-fidelity validation is sequenced in the priority-ordered backlog below, primarily items 3-5.

## Priority-ordered backlog

Only item 1 is planned and submitted for approval in this document. Each subsequent item requires its own plan and its own separate user approval before execution.

1. **THIS PLAN — Token pipeline reconciliation** (gates GitHub issue #31, and transitively all of #32-#44). Highest priority: it is the shared blocker every other issue is waiting on, it is the leading root-cause candidate for the reported visual mismatch, and it is now unblocked by the reported Atelier `projectRoot` fix.
2. **Re-validate the token-layer issues against the regenerated pipeline** (#31, #32, #33). Once regeneration is proven lossless, update the self-confirming tests to assert against pipeline output rather than hand-written values. Expected to be cheap once item 1 lands; this plan's ordered work step 9 performs the three named test updates as part of item 1, but a fuller #31/#32/#33 re-validation pass remains a separate future item.
3. **Authenticated-route visual validation sweep** for the screen issues: #38 roadmap, #39 week detail, #40 flashcards, #41 feedback, #42 owner dashboard/roster. These are where the user's "does not match exactly" report most likely has residual substance beyond the token layer. Must use the `claude-in-chrome`-backed `browser-validator` performing a real login; Atelier's `screenshot`/`baseline_update` tools run an isolated unauthenticated Playwright session and cannot reach these routes.
4. **Unauthenticated-route visual validation** for #37 login/signin and #43 brand/catalog. Lower priority only because these routes are publicly reachable and therefore also the ones Atelier's own baseline tooling can cover, making them cheaper to check.
5. **Component-level fidelity re-check** for #34 journal devices, #35 controls/fields/marks, #36 week card/chunks/ledgers/metric plate. Sequenced after screens, since screen-level validation will surface component defects in situ.
6. **#44 derived owner pages.** Last: these have no reference artboard by design and are judged against the A/B/C primitives, components, and screens, so they can only be assessed once those primitives are confirmed correct.
7. **Close out the GitHub issues.** Only after items 1-6 are complete; the four deferred pre-existing issues #10, #11, #28, #29 (`blocked:field-journal-ds`) become unblocked at this point.

Each of backlog items 2 through 7 likewise opens and closes its own tracking issue on the same convention as this plan's item 1 (see Issue tracking below). Item 7 closes out #31-#44 and unblocks #10, #11, #28, #29.

## Issue tracking

The user has directed that all work continue to be logged and tracked via GitHub issues. This plan makes that convention explicit rather than implied:

- Repository: `lebobo88/lizbeth-spanish`.
- Titles: plain descriptive text, no "Issue #N:" prefix.
- Established label set, consistent with #31-#44, #59, and #60: `bug`, `area:contrast`, `area:accessibility`, `area:tokens`, `area:design-system`, `qa-sweep`, `severity:S1`-`S4`, `role:*`, and `blocked:field-journal-ds` for the four deferred issues #10, #11, #28, #29.
- This plan's own tracking issue is created and closed at Ordered work steps 1 and 14. Any genuine out-of-scope defect surfaced during this job is filed as its own new issue on the same convention (Ordered work step 6) rather than fixed opportunistically inside this one.
- Issue creation and closing are tracking actions authorized by this standing directive. They are not a grant of commit, push, deploy, or pull-request authority; those still require explicit user request, per this repository's standing operating contract.

## Design route and handoff

```
DESIGN_ROUTE
profile: compact
reasons: The Field Journal DS is already fully authored in ADOPTION-PLAN.md and the DTCG reference document; no new design decisions are introduced. The change is a tool-verification and reconciliation task with a real design-system blast radius, requiring genuine adjudication rules rather than a fresh creative pass.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

**Design handoff: PASSED.** Its binding content is reproduced below and in Interfaces and data / Acceptance and validation.

**Adjudication rule.**

- *Branch A — the token pipeline.* Step 1: the DTCG source is authoritative by default. Step 2: a hand-file value carrying an explicit `$description`/comment naming a specific issue number and a deliberate reason ("corrected from", "ratified", "deliberately NOT", "distinct from", "pre-authorized exception"), or cross-referenced by a named repo test, is ratified, and the source must match it. Confirmed to be the near-universal outcome, not a case-by-case negotiation. Step 3: an unmarked value disagreeing with the source loses to the source (this is what fixes the stale generator output). Step 4: an unmarked disagreement with no description anywhere defaults to the source AND must be flagged in the PR as "unmarked drift, resolved to source, please confirm" — never silently decided.
- *Branch B — ratified exceptions living OUTSIDE the pipeline.* A raw value hardcoded in application CSS is ratified and must survive regeneration untouched if it is both (a) textually documented in-file as a deliberate exception and (b) enforced by a named regex-scoped whitelist in a repo test. Confirmed instance: `src/App.css:40`'s `--color-focus-ring`, enforced line-exactly by `FOCUS_RING_EXCEPTION_RE`. Regeneration must not touch, rename, or remove it, and must not assume `--color-focus` and `--color-focus-ring` are the same property; they are separate custom properties that must independently resolve to `#3d5f6b`.

**Ratified carve-outs that must survive regeneration unchanged:**

- `color.focus` = `#3d5f6b` (ink.slate), not `#0284c7`.
- `--color-focus-ring: var(--color-ink-slate, #3d5f6b)` at `App.css:40` — separate, load-order-guarded, line-exactly whitelisted.
- `control.height` = 48px, deliberately distinct from `size.controlHeight` = 2.75rem/44px. Do not merge or alias.
- `size.controlHeightSubmit` = 54px, scoped to the FeedbackForm primary submit only, never the shared `Control.css` default.
- `radius.none` aliases `radius.square` (0px). `radius.small`/`medium`/`pill` and `motion.durationShort` are DEPRECATED-but-present aliases — do not delete.
- `border.widthThin` (2px) is deliberately distinct from the numerically identical `border.widthStrong` (2px).
- `shadow.print` is LIVE and NOT deprecated; roughly two dozen consumers across 9+ files. `shadow.card` has zero consumers. Do not deprecate or redirect either.
- `color.link.text` anchored to `{color.brass.700}`, deliberately NOT routed through the owner-overridable `color.accent.primary`/`secondary` (which are overridable at runtime via `BrandingContext.tsx`); link text must never resolve through an owner-overridable property.
- The 26px margin hand override to §A.2's 24px row label ("the specimen wins"); decorative and `aria-hidden`.
- This project's real contrast gate is WCAG AA 4.5:1, not the stricter internal APCA Lc 75; `brass.600`/`terracotta.600` legitimately carry text where they clear 4.5:1. This is an accepted deviation, not a defect.
- `color.ink.moss` is reserved exclusively for the "completed stamp" meaning and must never be assigned to a band tier.
- Status/roadmap/badgeTint component tokens are additive only — verify no shipped default changes.

**Focus-indicator failure-mode invariant.** `--color-focus` must resolve to a valid colour in every consumer at all times post-regeneration. The six no-fallback consumers listed in Repository findings have zero tolerance for it being unset or invalid: the whole `outline` declaration becomes invalid at computed-value time and the focus indicator can disappear entirely, a WCAG 2.2 AA 2.4.7 failure, more severe than a hue shift. FlashcardsViewer's fallback chain is the one safety net in the codebase and must not be treated as representative of overall pipeline health.

**Verification gate (engineering/verifier gate, NOT a browser check) — two distinct checks, corrected per Codex `PLAN_DUCK` finding J-1-VERIFICATION-ORACLE (critical).** A single comparison against the shipped hand file is circular: if the generator reproduces the same wrong value the hand file already has, that comparison passes while the DTCG source is still not faithfully reproduced. The hand file cannot be the correctness oracle, because its unverified status is the entire reason this job exists. Verification therefore splits into two checks with different jobs.

- **Primary oracle — source-to-output (establishes correctness).** Build the expected map independently from the DTCG source, not from the hand file: parse `.atelier/tokens/field-workbook.tokens.json` directly, resolve every DTCG alias/reference (for example `{color.brass.700}`, `{color.badgeTint.archaic}`, `{color.ink.slate}`) and every `var(--...)` indirection per the generator's own documented resolution semantics to a terminal resolved value, and emit an expected map of custom-property-name to resolved-value using the same name-flattening convention the pipeline uses (for example `color.status.error.text` to `--color-status-error-text`, `focusRing.width` to `--focus-ring-width`). Compare that expected map against the regenerated CSS output. Any property present in the source but missing from the output, or resolving to a different terminal value, is a generator defect and a hard stop. This is the check that establishes correctness.
- **Secondary check — output-to-shipped (migration regression, not correctness).** Retain the order-insensitive, per-custom-property, resolved-value comparison of regenerated output against `src/tokens/field-workbook.generated.css`, but its job is demoted to revealing what visibly changes for users, not establishing correctness. It remains order-insensitive (generator output is alphabetical, the hand file is grouped by issue number) and tolerant of representation differences already coexisting in the hand file (for example `var(--color-ink-moss)` indirection vs. an equivalent literal hex). A difference here is a signal to investigate and route through the Branch A adjudication rule, not automatically a defect: if the primary oracle passes and this secondary check differs, the hand file was wrong and the regenerated value wins.

**Executable form.** Ordered-work step 2 must enumerate the actually-available `mcp__atelier__*` token tools and record the real compile entrypoint and the real validation entrypoint before relying on either. `mcp__atelier__tokens_validate` is confirmed working against `lizbeth_spanish/`-prefixed paths; a compile/emit tool is NOT confirmed to exist and must not be assumed — there is no token build script in `package.json` today. The primary oracle must be implemented as a small repo-local Node/TypeScript resolver committed with this work (suggested `scripts/verify-token-pipeline.mjs`, or equivalently a Vitest case under `src/__tests__/`), because it must be executable and re-runnable in CI regardless of which Atelier tool turns out to be available; landing this script is itself a deliverable of the job, not a throwaway. The root `H:\CommandCenter\orchestrator\atelier.config.json` already declares `tokens.sources` as `lizbeth_spanish/.atelier/tokens/field-workbook.tokens.json`, confirming that file is the pipeline's declared input and therefore the correct basis for the oracle.

**Contrast re-validation scope.** Focus-ring-on-surface (hue changed; highest priority); `status.error` on `paper.200` (the known 4.05:1 trap, re-verified only on its named consumers: `Control.css`, form validation, feedback banners); `link.text` brass.700 on all three paper grounds (recorded 5.648 / 5.465 / 4.881); `band.beginner`/`intermediate` (confirm the AA-not-APCA gate still applies); `ink.slate` 6.72:1 (Lc 82.0), `ink.moss` 7.42:1, `brass.300` on `ink.900` 6.80:1 (Lc -55.0) per ADOPTION-PLAN's own re-measured figures. All cited ratios are values already recorded in the repo; none were independently recomputed during planning.

**Documentation-only correction.** `field-workbook.tokens.json:73`'s `band.advanced` `$description` still reads "7.0:1 on paper.50", the figure ADOPTION-PLAN.md explicitly calls overstated. Correct the comment text to 6.72:1 (Lc 82.0). This is a comment fix, not a value change, and is outside the adjudication rule.

**Risk ranking (sequence highest blast radius first):** (1) focus indicator disappearing entirely in the six unguarded consumers; (2) focus-ring hue regression, and independently `--color-focus-ring` failing to resolve; (3) the missing Field Journal token layer being reproduced from the stale output by mistake, silently reverting the whole visual system to pre-issue-#31; (4) `shadow.print` mis-migration across ~24 consumers; (5) `control.height` vs. `size.controlHeight` conflation resizing every button and field; (6) status/roadmap/band re-mapping; (7) typography role/fontSize scale; (8) the 26px margin hand.

**Permitted variation.** None beyond Branch A Step 4's default-to-source-and-flag. No new token names, palette entries, type sizes, radii, shadows, or motion values may be introduced. Engineering may choose its own regeneration tooling and PR sequencing provided the risk order is respected and Branch B's `App.css` exception is never touched.

**Design review: PASSED** (`DESIGN_REVIEW_RESULT: PASS`), second and final round, one permitted revision used. All three high-severity round-1 findings were resolved: the missing `--color-focus-ring` carve-out and Branch B rule; the focus failure-mode split with Mode B correctly ranked above Mode A; and the source diff moved out of browser validation into an order-insensitive resolved-value engineering gate. Four lower-severity items were also resolved.

One low-severity advisory remains, recorded but not a gate: the original browser brief named `.admin-shell-tab`, which exists only in `App.css` style rules and tests. The live app renders `.admin-shell-link` (`AdminShell.tsx:44`, `AdminShell.css:47`, same `--color-focus-ring` outline pattern). This plan's Browser UI validation section below is corrected to use `.admin-shell-link`.

## Judge route

Eligible for `PLAN_DUCK` before user approval, and for `CODE_REVIEW` on the regeneration diff, per `docs/JUDGE-CONTRACT.md`; apply that contract's rubric IDs, blocking mode, and call caps as written.

- Checkpoint `CODE_REVIEW`: required on the regeneration diff.
- Risk: medium (system-wide token surface, no data/API change).
- Rubric: Branch A/Branch B adjudication fidelity against `.atelier/tokens/field-workbook.tokens.json`; focus-indicator failure-mode handling; `--color-focus` vs. `--color-focus-ring` independence; no new token names introduced; every consumed custom property still emitted.
- Call cap: standard path per `docs/JUDGE-CONTRACT.md`, one checkpoint repeatable once after remediation.
- Deterministic results (the primary source-to-output oracle, the secondary output-to-shipped check, the full test suite, the token fallback audit lint) always dominate a judge opinion; a judge finding is advisory unless `.claude/judge-policy.json` blocking has been enabled for this checkpoint.
- `VISUAL_REVIEW` is deferred to backlog item 3, where the screen-level authenticated validation sweep actually produces screenshots. It is not in scope here.

## Ordered work

Owner: T1, escalate to T2 on two counted gate failures.

1. **Tracking.** Create a GitHub issue for this reconciliation work via `gh issue create` against the `Field Journal DS` milestone, in repo `lebobo88/lizbeth-spanish`, using a plain descriptive title with no "Issue #N:" prefix, labelled at minimum `area:tokens`, `area:design-system`, and `area:accessibility`. Reference this plan's path in the issue body and note that it gates #31 and transitively #32-#44. Record the issue number for the closing comment in step 14.
2. Enumerate the actually-available `mcp__atelier__*` token tools and record the real compile entrypoint and the real validation entrypoint in the plan evidence before relying on either. `mcp__atelier__tokens_validate` is confirmed working against `lizbeth_spanish/`-prefixed paths; do not assume a compile/emit tool exists — there is no token build script in `package.json` today. Confirm the Atelier `projectRoot` resolution genuinely works for `lizbeth_spanish/`-prefixed paths before assuming the pipeline is runnable. Repository evidence records the defect and a reported follow-up fix, not a confirmed one. If it still fails, STOP and report `JOB_BLOCKED`; do not hand-edit the token file again. Do NOT modify `lizbeth_spanish\atelier.config.json`; only the root-level `H:\CommandCenter\orchestrator\atelier.config.json` may be tuned.
3. Run the real pipeline to regenerate token output from `.atelier/tokens/field-workbook.tokens.json`. Confirm the previously unresolved `{color.brass.500}` reference now resolves and the full Field Journal token layer is emitted.
4. Build and land the primary-oracle script (`scripts/verify-token-pipeline.mjs` or an equivalent Vitest case) that independently resolves the DTCG source's aliases and `var(--...)` indirections to terminal values and compares that expected map against the regenerated output. This is the correctness check; any missing or mismatched property is a generator defect and a hard stop.
5. Run the secondary output-to-shipped check: an order-insensitive, per-custom-property, resolved-value comparison of regenerated output against `src/tokens/field-workbook.generated.css`. Produce an explicit list of genuine differences; this check reveals migration-visible change, not correctness.
6. Resolve every genuine difference surfaced by either check using the Branch A adjudication rule, in the stated risk order. Flag any Step 4 unmarked drift in the PR rather than deciding silently. Any genuine defect surfaced by the primary oracle or by contrast re-validation (step 11) that is out of this job's scope must be filed as its own new GitHub issue following the Issue tracking convention below, rather than fixed opportunistically inside this one.
7. Install the verified output as the shipped token file, replacing the hand transcription, and remove the "MANUALLY TRANSCRIBED / not verified-by-tool" header now that it is false.
8. Verify Branch B is intact: `App.css:40`'s `--color-focus-ring` untouched, `FOCUS_RING_EXCEPTION_RE` still passing line-exactly.
9. Update `statusColorContrast.test.ts`, `typographyFourHands.test.ts`, and `tokenFallbackAuditLint.test.ts` to assert against regenerated pipeline output instead of hand-written values, breaking the self-confirming loop, while leaving `FOCUS_RING_EXCEPTION_RE`'s whitelist untouched since it governs Branch B, not the pipeline.
10. Apply the `band.advanced` `$description` documentation-only correction.
11. Re-run the contrast re-validation scope named above.
12. Run the full test suite, the token fallback audit lint, and the deterministic no-native-dialog scan.
13. Independent Verifier pass, then Browser Validator pass per the brief below.
14. **Tracking.** Record the outcome as a comment on the tracking issue from step 1, including the primary-oracle result and the browser-validation evidence, then close it via `gh issue close` only after the Verifier and Browser Validator passes in step 13 have both passed. Issue creation and closing are tracking actions authorized by the standing directive in Issue tracking below; they are not a grant of commit, push, or deploy authority, which still require explicit user request.

## Interfaces and data

No API, schema, or data-model change. The only interface is the CSS custom-property surface emitted by the token pipeline and consumed across `src/**/*.css`.

**Backward compatibility requirement:** every custom property currently consumed anywhere in `src/` must still be emitted with an equivalent resolved value after regeneration. Property removal is a breaking change even when the underlying design intent is unchanged.

## Acceptance and validation

- The real Atelier pipeline runs successfully against `lizbeth_spanish/`-prefixed paths, using entrypoints actually confirmed to exist (step 2 of Ordered work).
- Regenerated output contains the complete Field Journal token layer and no unresolved `{...}` reference strings.
- **The primary source-to-output oracle passes: every custom property resolvable from `.atelier/tokens/field-workbook.tokens.json` is present in the regenerated output with a matching terminal resolved value.** This is the criterion that establishes correctness; nothing else in this list does.
- The secondary output-to-shipped comparison against `src/tokens/field-workbook.generated.css` is order-insensitive, shows no unexplained difference, and every genuine difference is resolved by a stated Branch A adjudication step, with Step 4 cases explicitly flagged in the PR.
- Every custom property consumed in `src/` is still emitted.
- The shipped token file is pipeline output, and its false "not verified-by-tool" header is gone.
- `App.css:40`'s `--color-focus-ring` is byte-unchanged and `FOCUS_RING_EXCEPTION_RE` still passes.
- `statusColorContrast.test.ts`, `typographyFourHands.test.ts`, and `tokenFallbackAuditLint.test.ts` assert regenerated output rather than hand-written values.
- The repo-local primary-oracle script (or equivalent Vitest case) is landed and re-runnable, not a throwaway.
- Full test suite, token fallback audit lint, and no-native-dialog scan all pass.
- Contrast re-validation scope re-checked with no AA regression.
- Independent Verifier pass, then Browser Validator pass, both complete.
- The GitHub tracking issue from Ordered work step 1 carries the outcome comment and is closed only after Verifier and Browser Validator both pass.

## Risks and rollback

- **Risk level: medium.** Blast radius is the app's entire visual foundation, but the change is confined to generated CSS custom-property values plus three test files, with no data or API surface change.
- **Highest risk:** the focus indicator disappearing in the six unguarded consumers (WCAG 2.2 AA 2.4.7). Mitigated by the failure-mode invariant, by ranking it first in the risk order, and by the browser brief's tab-through check.
- **Second highest risk:** accidentally reproducing the stale output's omissions, silently reverting the visual system to pre-issue-#31. Mitigated by the explicit "no unresolved references, full layer emitted" acceptance check.
- **Rollback:** the change is a single generated CSS file plus three test files in a git repository with no migration and no persisted state. Revert the commit to restore the current hand-transcribed file exactly. The regeneration should be committed separately from the test updates so they can be reverted independently.
- **Post-revert verification:** after reverting, confirm all six no-fallback `--color-focus` consumers (`OwnerSettingsPage.css:270`, `RoadmapPage.css:96`, `SegmentLedger.css:69`, `ui/Field.css:43`, `ui/Control.css:139`, `Modal.css:36,89`) plus the independently-protected `--color-focus-ring` still render a visible focus outline. Reverting must not be assumed safe on an accessibility-critical change; it must be checked.
- **Scope boundary:** this plan is local development only. It includes no deployment, release, or production step, so no production rollback runbook is in scope. Rollback is a local git revert plus the focus-outline recheck above.
- **Stale-plan trigger:** if regeneration reveals widespread genuine value conflicts between source and hand file, contradicting design review's finding that they already agree, the premise of this plan changes materially. Return `JOB_BLOCKED: Plan stale` rather than adjudicating a large conflict set under a rule scoped for a small one.

## Dependencies

- The reported Atelier MCP `projectRoot` fix, confirmed working for `lizbeth_spanish/`-prefixed paths by ordered-work step 2, before any regeneration can proceed.
- `.atelier/tokens/field-workbook.tokens.json` remaining the DTCG source of truth with no material change since the version read during planning.
- The three named test files (`statusColorContrast.test.ts`, `typographyFourHands.test.ts`, `tokenFallbackAuditLint.test.ts`) existing and being enforceable as described.
- The Vite dev server already running at `http://localhost:5173/` for Browser Validator use (see below).

## Assumptions and decisions

**Assumptions, labeled:**

- Assumed: the Atelier `projectRoot` fix reported this session works; ordered-work step 2 verifies it rather than trusting it.
- Assumed: the three named test files are present and enforceable as described.
- Not independently recomputed: all cited contrast ratios in the Contrast re-validation scope are values already recorded in the repository; none were independently recomputed during planning.

**Decisions, needing no further approval:**

- The token pipeline is the first unit of work, because it is the shared gate on all 14 issues and the leading root-cause candidate for the reported visual mismatch.
- The 26px margin hand override and the WCAG AA 4.5:1 (rather than APCA Lc 75) contrast gate are already ratified upstream and are not re-litigated here.

**Still needs user approval:** backlog items 2-7 each need their own future plan and their own future approval. This plan itself is approved; see "Required approvals" below.

## Required approvals

This plan required explicit user approval before T1/T2 execution begins. The user's standing session goal to carry approved work to completion without re-approving already-authorized steps does not, on its own, extend to this document. This plan correctly declined to treat the standing `/goal` alone as approval; that gate is now satisfied by a direct statement.

**Approval record.**

- Approved by: the user, rob.hasselbach@gmail.com.
- Verbatim reply: "approve".
- Context: the orchestrator presented the compact plan summary (root cause: all 14 design-system issues #31-#44 gated on one shared token-pipeline defect; this plan independently verifies the DTCG token source against a real regenerated output via a committed resolver script, protects the `--color-focus-ring` exception and checks six no-fallback focus-outline consumers for a WCAG 2.4.7 regression risk, and opens/closes a GitHub issue per the user's standing gh-tracking directive) and asked, "Do you approve this plan for execution?" The user's "approve" reply was sent in direct response to that question, regarding this specific plan document.
- When: this session (2026-09-02).
- Classification: a direct, plan-referencing approval, not an approval inferred from the standing session goal alone.

T1/T2 execution may now proceed per this plan's downstream owner (`engineering-fleet`, T1 primary, T2 escalation per the two-counted-gate-failure rule, then Verifier, then Browser Validator).

At approval, the user's attention was specifically directed to:

- This plan authorizes ONLY backlog item 1 (token pipeline reconciliation). Backlog items 2-7 each need their own future plan and their own future approval.
- The Branch A/Branch B adjudication rule and the ratified carve-outs that must survive regeneration unchanged, including `--color-focus-ring` at `App.css:40`.
- The focus-indicator failure-mode invariant and the risk ranking placing the focus indicator disappearing entirely first.
- The GitHub tracking issue is opened and closed per the standing gh-tracking directive; this is a tracking action only and grants no commit, push, deploy, or pull-request authority.

## Browser UI dialog policy

Required and applicable. No native `alert`, `confirm`, `prompt`, their `window.*` forms, or `beforeunload` prompts anywhere in this browser-rendered UI. Acknowledgement and confirmation use an app-owned accessible modal; inline validation where it serves the user better. The existing deterministic no-native-dialog source scan (`src/__tests__/nativeDialogPolicy.test.ts`) must pass. This change introduces no new dialog surface, but the invariant is a standing gate and must be re-checked as part of ordered-work step 12.

## Browser UI validation

**Launch/readiness:** the Vite dev server is ALREADY RUNNING at `http://localhost:5173/`. Reuse it. Do not kill or restart node processes; this repository has a documented history of collateral damage from broad `taskkill`. No `taskkill` is authorized by this plan. Only if the server is genuinely down, restart it using the project's normal dev command.

**Base URL:** `http://localhost:5173/`

**Fixture/reset:** use the existing seeded test accounts and the project's established login flow. No Docker or Supabase changes are authorized by this plan.

**Tooling constraint (important):** authenticated routes MUST be validated with the `claude-in-chrome`-backed `browser-validator` performing a real login. Atelier's `screenshot`/`baseline_update` tools run an isolated unauthenticated Playwright session with no way to inject an authenticated cookie or storage state, and can only reach public routes.

**Viewport profiles:** desktop 1440px and mobile 390px, matching the reference's D (@1440) and E (@390) artboards.

**Journeys and visible outcomes:**

- Tab through OwnerSettingsPage, RoadmapPage, SegmentLedger, a `Control`-based control, a `Field`-based field, and a `Modal`, and confirm a visible outline RENDERS AT ALL on focus in each, not merely its colour. These six are the no-fallback consumers exposed to the outline-invalidated failure mode. This check comes FIRST.
- Where an outline renders, confirm it is teal-slate `#3d5f6b`, not blue `#0284c7`. Secondary to the outline-exists check.
- Tab a generic `*:focus`/`[tabindex]:focus` element and an `.admin-shell-link` element (per `AdminShell.tsx:44`; `.admin-shell-tab` is not rendered by any component), and confirm the ring renders teal-slate there too, proving `--color-focus-ring` independently resolves.
- Every top-level page card still renders its hard-brass offset shadow (brass-coloured, `.3rem .3rem 0rem 0rem`, no blur).
- On `Control.css` and form-validation/feedback-banner surfaces specifically, error text and border render terracotta.600 and never appear against a `paper.200` panel background on those named surfaces.
- Warning text brass.700 with brass.600 border, success ink.moss, neutral ink.700 on the status-bearing surfaces: four visually distinct hues.
- Roadmap week cards: completed ink.moss, current brass.500, locked ink.700: three distinct accents.
- Band-tier badges render brass.600 (beginner), terracotta.600 (intermediate), ink.slate (advanced); none render ink.moss.
- All interactive controls and form fields measure 48px tall; the FeedbackForm primary submit alone measures 54px.
- Link text renders brass.700, not the brighter brass.500/terracotta.500.
- On the Field Journal DS surfaces enumerated in ADOPTION-PLAN.md, paired with a code-level grep for `border-radius` usage so the claim is exhaustive rather than screenshot-asserted, confirm no rounded corners appear.
- With `prefers-reduced-motion` set, flashcard flip, page-turn, and stamp animations snap instantly with no visible transition, never a fade.
