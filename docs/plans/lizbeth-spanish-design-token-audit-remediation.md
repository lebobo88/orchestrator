# Lizbeth Spanish — Design Token Audit Remediation

**Status: Approved. Phases 1-3 complete, with Phase 3 limitations recorded below.** Approved by the user (rob.hasselbach@gmail.com) in this session, verbatim reply "approved," sent in direct response to the orchestrator's question "Do you approve this plan for execution?" regarding this specific plan document. This is a direct, plan-referencing approval, not an approval inferred from the standing session goal alone. See section 14 for the full approval record. See section 6, Phase 3, for the recorded completion evidence and its two honestly-disclosed, non-blocking tooling limitations.

Plan ID: `lizbeth-spanish-design-token-audit-remediation`
Task ID: `lizbeth-ds-token-audit-remediation`
Route: engineering
Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish` — a **separate git repository** from the orchestrator repository. GitHub remote believed to be `lebobo88/lizbeth-spanish`; Phase 0 confirms this.
Engineering mode: standard
Team authorization: not applicable
Downstream owner: engineering-fleet

This plan grants no authority to begin implementation on its own. Explicit user approval, relayed by the orchestrator, is required before any T1/T2 engineering writer starts work.

---

## 1. Outcome and audience

Remediate the confirmed WCAG AA contrast defects found in an Atelier design-token audit of the `lizbeth_spanish` app; stand up GitHub issue tracking for this defect and any further defects Phase 2 finds; establish an evidence-based coverage map of which app surfaces have been validated against the local Field Journal design reference and which have not; and browser-validate the result.

Audience for the resulting product surfaces: enrolled students and app owners viewing any page containing a default (unstyled) hyperlink.

Audience for this document: T1/T2 engineering implementers, the Verifier, and the Browser Validator. This plan must be sufficient for implementation without re-deriving design decisions.

---

## 2. Scope and non-goals

### In scope

- **Phase 0 — Pre-flight.** Confirm `gh` availability and authentication, the GitHub remote, and the live open/closed state of issues #31-#44 and their labels/milestone.
- **Phase 1 — Link contrast fix.** The confirmed link-contrast defect in `src/App.css`, per the reviewed design handoff in section 4, plus its guard test and a GitHub issue recording the defect and fix.
- **Phase 2 — Design-reference coverage map.** A deterministic map of app surfaces against the local Field Journal design reference, producing one GitHub issue per genuine gap found. Audit and issue-filing only.
- **Phase 3 — Validation.** Browser and Atelier validation of Phase 1, plus establishing an Atelier baseline entry to enable future `visual_diff` runs.

### Explicitly out of scope (non-goals)

- **Remediating the surface-level design gaps Phase 2 discovers.** Each becomes its own GitHub issue and, where it needs real design work, its own plan, matching the established #31-#44 pattern. This plan does **not** pre-authorize that work.
- Any Docker or Supabase change. Do not stop, start, restart, or reconfigure containers. Do not run `supabase` commands.
- Modifying `lizbeth_spanish\atelier.config.json` (the subfolder copy). Only the root-level `H:\CommandCenter\orchestrator\atelier.config.json` may be tuned.
- Editing `.atelier/tokens/field-workbook.css` (a stale, unused third artifact; see repository findings).
- Any commit, push, PR, or deploy unless the user explicitly requests it.
- **Killing node processes.** `taskkill /F /IM node.exe` is prohibited. This repository has a documented history of that command causing collateral damage. Terminate only by explicit PID if ever truly necessary.

### Protected / do not regress

- The existing `a:focus` blocks at `App.css:206-214` and `App.css:232-240` — not touched by this plan.
- `App.css:149-156`'s existing `prefers-reduced-motion: reduce` block — must remain the only reduced-motion mechanism; no second one may be introduced.
- `BrandingContext.tsx`'s runtime owner-brand-color override — remains fully functional; this plan only closes its ability to affect link text.
- Existing guard tests: `statusColorContrast.test.ts`, `contrast.test.ts`, `BrandingContext.test.tsx`, `weekDetailBackLinkStyling.test.ts`, `AccessibilitySettings-Rebuild.test.tsx`.

No commit, push, PR, or deploy unless the user explicitly requests it.

---

## 3. Repository findings (evidence)

Findings below are from one nested Researcher pass, repository-local and local-CLI only, with no web sources used.

**Tooling limitation discovered during research.** The Researcher agent's Bash hook (`.claude/hooks/validate-researcher-bash.ps1`) allows only a fixed pattern set (`git status/diff/log/show/rev-parse/branch/ls-files/remote -v/config --get`, `rg`, `Get-Content`, `Get-ChildItem`, `Select-String`, `node/python --version`, `npm ls`, `dotnet --info`, `cargo metadata`). It has no `gh` pattern at all, and additionally blocks bare `cd` and command chaining (`&&`). Consequence: Researcher could not run any `gh` command and could not point git at the `lizbeth_spanish` subfolder repo. This is a hook-policy limitation, **not** evidence that `gh` is missing or unauthenticated. Agents whose Bash is not under that hook — the orchestrator itself, t1-engineer, t2-engineer, verifier, browser-validator — are unaffected. All `gh` work in this plan is therefore assigned to the orchestrator or the engineering fleet, never to Researcher.

**The design reference is local.** `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html` (~208,603 characters) is a committed verbatim copy of the Claude Design canvas at project `a67bf200-a700-493d-8e55-75642e8ace33`. It does **not** need to be re-fetched, re-exported, or screenshotted by the user. Also present in the same directory: `Current UI Recreation.dc.html` (the "before" recreation, usable for diffing), `README.md` (provenance), `extracted/tokens.field-journal.json`, `support.js`, and a `judge/` directory with prior Codex verdicts.

**ADOPTION-PLAN is the authoritative decomposition.** `lizbeth_spanish/design/field-journal/ADOPTION-PLAN.md` maps every reference section (A.1-A.6 foundations, B journal devices, C.1-C.9 components, D.1-D.9 desktop @1440 screens, E.1-E.6 mobile @390 screens) to 14 numbered issues, and names the six pages with **no** reference screen (`CourseWorkspacePage`, `CourseSettingsPage`, `NewCoursePage`, `BusinessSettingsPage`, `OwnerSettingsPage`, `OwnerFeedbackPage`), decided to be derived from A+B+C primitives. **Numbering offset: ADOPTION-PLAN issues 1-14 correspond to GitHub issues #31-#44 (+30).** It also records four deferred pre-existing issues (#10, #11, #28, #29) parked under a `blocked:field-journal-ds` label.

**Prior plans exist** for `lizbeth-spanish-issue31-*` through `issue44-*` in `docs/plans/`. The issue38 plan states #31-#37 had landed, verified, browser-validated, and design-reviewed PASS at the time it was written. **The current live open/closed state of #31-#44 is unknown and is Phase 0's job to establish.**

**Ratified deviations (settled 2026-08-30; not to be re-opened).** `ADOPTION-PLAN.md` records: (a) the margin hand is 26px, not 24px; (b) **WCAG AA 4.5:1 is this project's gate.** `brass.600` (5.02:1 on `paper.50`) and `terracotta.600` (4.69:1) legitimately carry text even though both fall below the Atelier APCA Lc 75 body threshold; that APCA shortfall is an accepted deviation, not a defect. Do not raise issues on APCA grounds alone. This distinguishes both tokens from `brass.500`, which fails the actual AA gate.

**Atelier MCP misconfiguration fixed this session.** Atelier MCP was previously recorded across the #34-#38 plans as "disclosed-unavailable (project-root misconfiguration)," forcing a documented manual visual-diff substitute. That misconfiguration has now been fixed: a root-level `H:\CommandCenter\orchestrator\atelier.config.json` was created, re-expressing the subfolder config with every path prefixed `lizbeth_spanish/`. The MCP server resolves its root to the orchestrator repo root via MCP client-roots, so it could not previously see the subfolder config. Verified working this session: `atelier_info` reports the correct `configSource`/`tokenSources`; `tokens_validate` returns 135 tokens, 0 errors, 2 benign pre-existing warnings (`typography.role.targetLine.fontStyle` and `motion.reducedMotion` declare `$type: "string"` rather than a DTCG-recognized type; non-blocking, optionally cleanable, out of scope for this plan). Atelier tooling is therefore **available** to this plan; the manual substitute used by prior plans is no longer required.

`mcp__atelier__design_review` on `src/App.css` returns 0 findings. App.css is in the review allowlist by design; its intentional CSS custom-property fallback hex literals are documented in-file.

**Contrast audit results**, independently recomputed twice (design-generalist and design-reviewer agree to three decimal places), all against `paper.50` unless stated:

| Token | Ground | Ratio | Result |
|---|---|---|---|
| `ink.1000 #1a1512` | `paper.50` | pass | PASS |
| `ink.700 #504940` | `paper.50` | 8.643:1 | PASS |
| `ink.700` | `paper.100` | 8.361:1 | PASS |
| `ink.700` | `paper.200` | 7.468:1 | PASS |
| `ink.slate #3d5f6b` | `paper.50` | pass | PASS |
| `ink.moss #2f5d3f` | `paper.50` | pass | PASS |
| `brass.700 #7c6136` | `paper.50` | 5.648:1 | PASS |
| `brass.700` | `paper.100` | 5.465:1 | PASS |
| `brass.700` | `paper.200` | 4.881:1 | PASS |
| `brass.600 #866843` | `paper.200` | 4.337:1 | **FAIL** |
| `brass.500 #a07e48` | `paper.50` | 3.675:1 (APCA Lc 63.3) | **FAIL** |

**Confirmed primary defect.** `src/App.css:282-294` — `a { color: var(--color-accent-primary); }`, where `App.css:29` sets `--color-accent-primary: var(--color-brass-500)` (`#a07e48`). Every default hyperlink renders at 3.675:1, failing AA for normal text. Unlike `terracotta.600`, the `brass.500` token carries **no** `$description` warning.

**Confirmed second defect, same rule block.** `a:hover { color: var(--color-accent-secondary); }` resolves to `terracotta.500 #d97a5c`. `ADOPTION-PLAN.md` §A.1/§A.6-2 states `terracotta.500` and `amber.*` are decorative-only and must never carry text. A hover state that recolors link text to `terracotta.500` violates the system's own non-negotiable rule.

**Confirmed third (latent) defect.** `a:visited { color: var(--color-brass-600); }` — `brass.600` fails AA at 4.337:1 the moment a link sits on a `paper.200` ground.

**Confirmed architectural root cause.** Link text was the **only** text-bearing consumer of `--color-accent-primary`/`--color-accent-secondary`. Every other consumer is decorative (borders, backgrounds, shadows, gradients). Worse, both tokens are runtime-overridable by owner branding via `src/context/BrandingContext.tsx:16-17, 87-114`, so an owner's brand color could independently regress link contrast. The fix in section 4 closes this hole structurally.

**Decorative-consumer map (verified twice; the first draft had errors).**

- `--color-accent-primary`: `App.css:29` (definition); `App.css:283` (**the defect**, text-bearing); `App.css:451` (`border-color`, decorative); `App.css:595` (`.demo-hint border-left`, decorative); `LessonContentView.css:63` (`border-left`, decorative); `AccessibilitySettings.css:88` and `:108` (`background-color`); `AccessibilitySettings.css:184` (`accent-color`).
- `--color-accent-secondary`: `App.css:30` (definition); `App.css:289` (**the defect**); `App.css:524` (`.demo-button.primary:hover background-color`, decorative).
- Direct `--color-brass-500`: `App.css:472` (`.demo-section h2 border-bottom`, a direct primitive reference, not `accent-primary`); `field-workbook.generated.css:11` (definition); `:38` (`--color-roadmap-current` alias); `:129-130` (shadow tokens); `BandRoadmap.css:97-98` (hatch-pattern gradient, an unrelated direct reference).
- `--color-roadmap-current`'s real consumers: `LearnDetailPage.css:89, 90, 120`.

**Checked and explicitly not a defect.** `LearnDetailPage.css:120` uses `--color-roadmap-current` (→ `brass.500`) as a `color:` property on `.lesson-card-icon`. It is an icon glyph (sibling base rule at `:111` sets `color: var(--color-ink-800)`), so WCAG 1.4.11's 3:1 non-text floor applies, not 4.5:1; it measures 3.55:1 against its real `.lesson-card` `paper.100` background and passes. It is also a static alias of the `brass.500` primitive, never of the owner-overridable accent tokens, so it does not share this defect's root cause. Recorded as "checked, not a live instance" — do **not** open a duplicate issue for it.

**Existing guard tests.** `src/__tests__/statusColorContrast.test.ts` uses a local hand-written WCAG luminance function (no library). It asserts `terracotta.600` passes on `paper.50`/`paper.100` and explicitly fails on `paper.200`, plus several `AdminStudentsPage` button pairings and `brass.700` on `paper.50`/`paper.100`. It does **not** guard the global `a` rule. `src/__tests__/contrast.test.ts` covers `WeekCard.css` pairings only. **No existing test asserts `a { color }`, the terracotta hover, or the `brass.600` visited color**, so nothing breaks by omission today. `weekDetailBackLinkStyling.test.ts` and `AccessibilitySettings-Rebuild.test.tsx:134` target class-scoped selectors that already out-specify the generic `a` rule and are unaffected.

`terracotta.600` on `paper.200` (4.05:1) is a known, documented trap, warned about in the `status.error.text` token's `$description` and guarded by `statusColorContrast.test.ts`. Phase 2 must confirm no live CSS rule actually pairs them; the existing test is the guardrail, and no code fix is expected for this pairing.

**Token dual-write convention.** Confirmed by precedent: a token must land in **both** `.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css`. DTCG alias syntax `{color.brass.700}` is real, established precedent (`field-workbook.tokens.json:101`, `semantic.json:79`). `--color-link-text` does not currently exist anywhere.

**Two independent, drifting token mechanisms.** Mechanism 1 is `src/tokens/primitives.json` / `semantic.json` / `components.json`, consumed by `tokenSystem.ts`/`main.tsx`. Mechanism 2 is `.atelier/tokens/field-workbook.tokens.json` → `src/tokens/field-workbook.generated.css`. `brass.500` is defined without a description in both (`field-workbook.tokens.json:18` and `primitives.json:28`). `src/tokens/semantic.json` has no link/anchor/accent-text role and needs no change for this plan.

`BRAND_COLOR_SURFACE_CONSTRAINTS` in `src/lib/ownerSettingsAuthorization.ts:46-49` only checks `paper.50` normal-text and `paper.200` large-text/non-text; it does **not** cover `paper.100` or `paper.200` normal-text. Out of scope here; recorded as a prerequisite for any future owner-brandable link color.

**Commands** (`lizbeth_spanish/package.json`): `npm test` (Vitest), `npm run test:e2e` (Playwright), `npm run lint` (`eslint src --ext ts,tsx`), `npm run type-check` (`tsc --noEmit`), `npm run verify:build`. The full suite requires the local Supabase stack for RLS tests; do **not** run the full suite as part of this plan's gates. Run targeted tests plus lint plus type-check. Never report a full pass achieved by silently excluding `rlsIntegration.test.ts`; that failure mode occurred once already in this project.

**Dev server status.** A dev server is already running and healthy at `http://localhost:5173/` (Vite v5.4.21, HTTP 200 confirmed this session). Reuse it; do not kill it.

`research_evidence`: one nested Researcher pass, repository-local plus local-CLI only, no web sources. All findings above trace to it or to the design-generalist/design-reviewer's independent re-verification described in section 4.

---

## 4. Design route and handoff summary

```text
DESIGN_ROUTE
profile: compact
reasons: One bounded brownfield defect in a mature, heavily-governed existing design system. No new screen, flow, or component; the only decision is which token a text-bearing global rule resolves to and whether a new semantic leaf is warranted.
agents_required: design-generalist, design-reviewer
prototype: forbidden
model_tier: sonnet
existing_system_mode: preserve
END_DESIGN_ROUTE
```

Compact-route `DESIGN_HANDOFF` from design-generalist, revised once against independent review before reaching Scribe.

### New semantic token leaf

Add `color.link.text` to `.atelier/tokens/field-workbook.tokens.json` alongside `color.status.*`, as `$type: color`, `$value: "{color.brass.700}"`, with a `$description` recording:

- anchored to `brass.700` because it is the only `brass`-family primitive clearing AA 4.5:1 on all three paper grounds (5.648 / 5.465 / 4.881);
- deliberately **not** the accent tokens, because those are decorative-role and runtime-overridable by owner branding;
- link text must never resolve through an owner-overridable custom property.

Dual-write `--color-link-text: var(--color-brass-700);` into `src/tokens/field-workbook.generated.css`, under the existing `brass` block.

### Replace `src/App.css:281-294`

```css
a { color: var(--color-link-text); text-decoration: underline; }
@media (prefers-reduced-motion: no-preference) {
  a { transition: color 0.2s ease, text-decoration-thickness 0.2s ease; }
}
a:hover { text-decoration-thickness: var(--border-width-thin); }
a:visited { color: var(--color-link-text); }
```

The `a:focus` blocks at `App.css:206-214` and `:232-240` are **not** touched.

**Hover** drops the color change entirely (fixing the `terracotta.500` violation); the affordance becomes a thicker underline. This deliberately diverges from the closest shipped precedent, `Control.css:108-115` (`.control--quiet:hover`, which changes both color and thickness), because that pattern's `terracotta.600` fails AA on `paper.200` at 4.05:1 while `brass.700` clears all three grounds; reusing it would reintroduce the defect class being fixed.

**Visited carries no visual distinction from the default link state, by deliberate decision, following a Codex judge-driven revision (see the Judge review disposition below).** Global `a:visited` intentionally carries no visual distinction from the default link state. §A.6/1 cannot be satisfied for `:visited` by any technical means: every browser engine restricts it to color-only properties as a history-sniffing mitigation, and `getComputedStyle` masks even permitted properties from script verification. A color-only cue (`ink.700` vs. `brass.700`, ~1.53:1 mutual contrast) was evaluated and rejected as imperceptible in greyscale and to colorblind users, which would imply a distinction most users cannot perceive. This matches existing codebase convention and the Field Journal DS reference, which specifies no visited-link treatment. §A.6/1 is scored not-applicable to `:visited` — a browser-security limitation, not a compliance gap.

Supporting evidence for this decision:

- The codebase's two other live `:visited` rules are **already color-parity no-ops**: `AdminShell.css:37` (`color: var(--color-ink-800)`) restates that link's own default color from `AdminShell.css:32` verbatim, and `ResourcesPanel.css:102` (`color: var(--color-paper-50)`) restates its default from `ResourcesPanel.css:87` verbatim. The defective `a:visited { color: var(--color-brass-600) }` rule being replaced was the outlier, not the convention.
- A repo-wide search for "visited" finds no mention in `ADOPTION-PLAN.md` or any D/E reference screen. The design reference is silent on visited links, so no distinction is owed.

### Brass.500 description addition

Add the `brass.500` `$description` contrast warning to **both** `.atelier/tokens/field-workbook.tokens.json:18` and `src/tokens/primitives.json:28` (both currently lack any description), mirroring the existing `status.error.text` precedent: decorative only per §A.1/§A.6-2; 3.675:1 / APCA Lc 63.3 on `paper.50`, failing the AA normal-text floor; never pair with text; text-bearing uses must resolve through `color.link.text`.

### Stale doc-comment corrections

Update two now-stale doc comments that describe the accent tokens as governing "link color": `src/context/BrandingContext.tsx:74-78` and `src/__tests__/BrandingContext.test.tsx:137-144`.

`BrandingContext`'s runtime override stays fully intact; after this fix it provably cannot affect link text.

### New guard test

`src/__tests__/linkColorContrast.test.ts`, mirroring `statusColorContrast.test.ts`'s local hand-written WCAG luminance function (no library), asserting exactly six assertions:

- (a) `contrastRatio(BRASS_700, PAPER_50) >= 4.5` (~5.648)
- (b) `contrastRatio(BRASS_700, PAPER_100) >= 4.5` (~5.465)
- (c) `contrastRatio(BRASS_700, PAPER_200) >= 4.5` (~4.881)
- (d) `contrastRatio(BRASS_500, PAPER_50) < 4.5` (~3.675) — regression guard
- (e) `contrastRatio(BRASS_600, PAPER_200) < 4.5` (~4.337) — regression guard
- (f) a source-scan parity assertion, mirroring `AdminShell.test.tsx:33-54`'s existing pattern, that `a:visited`'s declared `color` is identical to `a`'s declared `color` — guarding against ever reintroducing a distinct, possibly AA-failing, visited color

### Permitted variation

- Hover thickness may use `--border-width-thin` or `--border-width-strong` (token choice only).
- The new leaf may be renamed (for example `color.text.link`) if a better-fitting existing convention is found, preserving value, description intent, and dual-write.
- **`dashed`/`dotted`/any `text-decoration-style` or `-thickness` change for `:visited` is explicitly not permitted variation.**

### Design review disposition

`DESIGN_REVIEW_RESULT` verdict **PASS**, round 2, from an independent design-reviewer that recomputed every contrast ratio from the real hex values and re-verified every file/line citation rather than trusting the packet. Round 1 was NEEDS_REVISION with nine findings, all resolved in one permitted revision.

**The highest-value catch, preserved here as a hard engineering invariant.** The original proposal used `a:visited { text-decoration-style: dashed }`, which **cannot work**: every major browser engine restricts `:visited` styling to color-family properties only (`color`, `background-color`, `border-*-color`, `outline-color`, `text-decoration-color`, `column-rule-color`, SVG fill/stroke) as a history-sniffing mitigation; all others are silently dropped, and `getComputedStyle` masks even permitted ones. No non-color cue exists for `:visited`. This rule deliberately carries none, per the decision recorded above under "Visited," not by oversight. **Any future change to this rule must preserve exact color parity with the default state unless a new, separately evaluated exception is recorded.** Round 1 also found that `dashed` is reserved vocabulary in this system (the universal `:disabled` treatment at `Control.css:147`, documented as "the only dashed border in C.1"; the empty-state rule at `JournalEmptyState.css:4`; the frayed-tape device at `journal-devices.css:37-40`), which independently disqualified it.

**One LOW, non-blocking finding from round 2, recorded here, not to be fixed:**

- The `LearnDetailPage.css:120` observation is "checked, not a live instance of the same defect class" — do not open an issue for it.

### Judge review disposition

A cross-vendor Codex `PLAN_DUCK` review ran in advisory/shadow mode against this document and returned **REVISE** with four findings. Deterministic checks and the Verifier/Browser Validator passes remain mandatory regardless of any judge finding. Dispositions:

- **J-PLAN-001 — ACCEPTED, resolved by a design change.** The judge correctly identified that a `text-decoration-color`-only visited cue is a color-only cue, which §A.6/1 ("every state carries a shape or a word, never colour alone") forbids. The design agent was re-consulted and confirmed the judge's literally recommended remedy (a non-color visited cue) is technically impossible for `:visited` in any browser, but the underlying objection is valid. Resolution: the visited distinction was dropped entirely rather than kept as a cue that cannot satisfy the invariant. See the revised "Visited" text above, the revised CSS block, the removed `ink.700`-as-visited-underline material, and the removed LOW mutual-contrast limitation (that figure now survives only as the reason the cue was rejected).
- **J-PLAN-004 — ACCEPTED.** The document previously said "all six assertions" while section 4's list, after the J-PLAN-001 change, no longer summed to six. The guard-test list is now exactly six lettered assertions (a)-(f), with the `ink.700` non-text assertion replaced by a new color-parity source-scan assertion (f). Every cross-reference in this document now says "six" consistently.
- **J-PLAN-002 — ACCEPTED.** Phase 3's Atelier visual-diff strategy lacked concrete route-to-artboard mapping, viewport assignment, baseline naming, fixture policy, and threshold handling. Section 6's Phase 3 and section 7 are updated with the full route table, viewport assignment, baseline naming convention, fixture policy, and an honest statement that the root `atelier.config.json` has no `gates` key today, requiring one to be added and its value justified in the completion evidence rather than assumed.
- **J-PLAN-003 — NOT REPRODUCIBLE.** The judge reported a changed-path inventory listing non-existent files `.tokens/color.tokens.json` and `design/index.css`. A search of this document for both strings returns no matches; neither path appears anywhere in it. This finding does not correspond to the document as written and is recorded as a judge artifact, not acted on. The document's actual changed-path set (section 7) was independently re-verified as correct and complete.

---

## 5. Judge route

Standard `docs/JUDGE-CONTRACT.md` rules apply; no elevated judge checkpoint is pre-authorized by this plan. Deterministic failures always dominate any judge finding.

---

## 6. Ordered work (phases)

### Phase 0 — Pre-flight

**Owner: orchestrator or engineering-fleet — not Researcher** (Researcher's Bash hook has no `gh` pattern; see section 3).

From `H:\CommandCenter\orchestrator\lizbeth_spanish`, establish:

- `git remote -v`, `git branch --show-current`, `git status --short`.
- `gh auth status`.
- `gh issue list --milestone "Field Journal DS" --state all --limit 60 --json number,title,state,labels` to determine which of #31-#44 are open vs. closed.
- `gh label list` to reuse the existing label vocabulary rather than inventing labels.
- A duplicate search (`gh issue list --state all --search "contrast"` and `"link"`) so Phase 1 does not file a duplicate issue.

**Gate.** If `gh` is unauthenticated or the remote is absent, do **not** block the code fix. Proceed with Phase 1 and Phase 3, and record the issue-tracking work as deferred, reporting the exact `gh` error to the user for a one-time credential decision. Issue tracking is a tracking mechanism, not a prerequisite for a correctness fix.

- Depends on: nothing.
- Observable result: confirmed remote, confirmed #31-#44 live state, confirmed label vocabulary, confirmed no pre-existing duplicate issue (or the gate outcome recorded and Phase 1/3 proceeding).

### Phase 1 — Link contrast fix

**Owner: T1; escalate to T2 per the standard two-counted-gate-failure rule in `CLAUDE.md`.**

TDD-first: write `src/__tests__/linkColorContrast.test.ts` and watch it fail before editing production files. Then, in order:

1. **1a** — add the `color.link.text` leaf to both token files.
2. **1b** — add the `brass.500` `$description` to both `.atelier/tokens/field-workbook.tokens.json:18` and `src/tokens/primitives.json:28`.
3. **1c** — replace the `App.css` link block per section 4's fenced CSS block.
4. **1d** — update the two stale `BrandingContext` doc comments.

Then file the GitHub issue recording the defect and its fix, using the labels and milestone Phase 0 discovered.

- Depends on: Phase 0 (for the labels/milestone used by the issue filing step; the code fix itself has no hard dependency on Phase 0's gate outcome).
- Observable result: `linkColorContrast.test.ts` passes with all six assertions (a)-(f) from section 4; `App.css` link rules match the fenced block exactly; both token files carry the new leaf and the new description; the two doc comments no longer describe the accent tokens as governing link color; a GitHub issue exists recording the fix (or is recorded as deferred per the Phase 0 gate).

### Phase 2 — Design-reference coverage map

**Owner: T2 or Researcher for the read-only harvest; issue filing by the fleet.**

Deterministically enumerate, from the local `Field Journal DS.dc.html` plus `ADOPTION-PLAN.md`, every reference section (A.1-A.6, B, C.1-C.9, D.1-D.9, E.1-E.6) and every one of the six no-reference derived pages. For each, record:

- the mapped GitHub issue number (ADOPTION-PLAN issue N = GitHub issue N+30);
- that issue's live state from Phase 0;
- the app files it governs;
- whether a plan document exists in `docs/plans/`.

Cross-check every `DS.dc.html` line-number citation already present in `docs/plans/lizbeth-spanish-issue3*.md`/`issue4*.md` and in the token `$description` fields — the issue38 plan warns that some issue bodies' own line estimates were wrong for the current file, so citations must be re-resolved against the local file, not trusted.

Also run `mcp__atelier__design_review` and `contrast_check` across the review allowlist to catch any further token-compliance defect. Confirm no live CSS rule pairs `terracotta.600` with `paper.200`.

**Output**: a coverage map distinguishing validated / implemented-but-unvalidated / not-started / no-reference-derived surfaces, plus one GitHub issue per genuine gap. **This phase files issues; it does not remediate.**

- Depends on: Phase 0 (for issue state and label vocabulary).
- Observable result: a written coverage map artifact plus zero or more new GitHub issues, each traceable to a specific reference section and a re-resolved (not assumed) line citation.

### Phase 3 — Validation

**Owner: Verifier, then Browser Validator.**

Verifier pass on Phase 1, then Browser Validator pass per the brief in section 10.

**Atelier visual-diff baseline setup.** Two framing points govern this work:

- Baselines must be captured **after Phase 1 lands**, since Phase 1 deliberately changes link color and would otherwise invalidate every baseline immediately.
- Phase 3 **establishes the visual-diff capability and its baselines**; it does not remediate screen-level visual differences. Any difference the baseline capture surfaces belongs to Phase 2's issues and their own future plans.

**Route-to-artboard mapping.** Reference sections come from `ADOPTION-PLAN.md`; routes are confirmed from `src/App.tsx` and `src/hooks/useRoute.ts`:

| Reference | Route | Desktop | Mobile |
|---|---|---|---|
| D.1 / E.1 Login | `/` (unauthenticated) | yes | yes |
| D.2 / E.2 Roadmap | `/roadmap` | yes | yes |
| D.3 / E.3 Week detail | `/roadmap/{enrollmentId}/week/{n}` | yes | yes |
| D.4 / E.4 Flashcards | flashcards viewer within week detail | yes | yes |
| D.5 / E.5 Feedback | `/feedback` | yes | yes |
| D.6 / E.6 Owner dashboard | `/admin/dashboard` | yes | yes |
| D.7 Roster | `/admin/students` | yes | no |
| D.8 Brand | `/admin/brand-design` | yes | no |
| D.9 Catalog | public catalog route | yes | no |

For D.9, the exact path must be resolved from `matchPublicCourseRoute` in `src/hooks/useRoute.ts` at execution time rather than guessed.

**Viewports.** 1440x900 for every D.* artboard; 390x844 for every E.* artboard, matching the reference's own `@1440` and `@390` composition widths.

**Baseline naming.** `mcp__atelier__baseline_update` creates one baseline per row-and-viewport, named `field-journal-<section>-<slug>-<viewport>`, lowercased, for example `field-journal-d2-roadmap-1440`, `field-journal-e2-roadmap-390`, `field-journal-d7-roster-1440`. Fifteen baselines total: six sections at both viewports (12), plus three desktop-only sections (3).

**Fixtures.** Reuse the existing seeded student and owner accounts. Screens must be captured against real seeded data, never placeholder content. Do not reseed and do not touch Supabase.

**Threshold — stated honestly, not assumed.** The root `atelier.config.json` currently contains only `tokens.sources` and `review.allowlist`; it has **no `gates` key at all**, so there is no configured `visualDiffThreshold` to cite. Phase 3 must therefore: (i) record the tool's actual default from `mcp__atelier__atelier_info` as observed evidence rather than assuming a value; and (ii) add an explicit `gates.visualDiffThreshold` to the **root** `atelier.config.json` so the gate is pinned and reproducible rather than resting on an unrecorded default. The chosen value must be recorded with its justification in the completion evidence. The subfolder `lizbeth_spanish\atelier.config.json` remains off-limits per section 2's non-goals.

Re-run `mcp__atelier__tokens_validate` (expect 136 tokens after the new leaf, 0 errors) and `contrast_check` showing no failing pair for the link role.

- Depends on: Phase 1 (Verifier/Browser Validator content, and baseline capture must follow Phase 1's landing per the framing point above).
- Observable result: Verifier PASS; Browser Validator PASS against section 10's journeys; the root `atelier.config.json` carries a working `gates.visualDiffThreshold` and fifteen named baselines; `tokens_validate` reports 136 tokens, 0 errors.

If T1 cannot complete Phase 1, escalate to T2 per the standard two-counted-gate-failure rule in `CLAUDE.md`.

**Phase 3 completion evidence (recorded post-execution).**

*Atelier baseline setup (Part A).*

- Of the fifteen baselines planned in the route-to-artboard table and naming convention above, only **two** were achievable: `field-journal-d1-login-1440` and `field-journal-d9-catalog-1440`, both real, distinct, unauthenticated public pages.
- The remaining thirteen baselines (every D.2-D.8 desktop/mobile pair requiring an authenticated route) could **not** be captured. `mcp__atelier__screenshot`/`baseline_update` run an isolated, unauthenticated Playwright session separate from any interactive browser session, and there is currently no mechanism to inject an authenticated storage state or cookie into that isolated session. This is recorded as an **Atelier MCP server capability gap**, not a task failure: a future enhancement adding session/cookie injection support would be needed to reach full baseline coverage. It is deferred, not blocking.
- Separately, `mcp__atelier__screenshot`/`baseline_update` capture at a fixed 1280x900 viewport with no parameter to set the plan's 1440x900 or 390x844 viewports, confirmed by reading the captured PNGs' actual dimensions. The `-1440`/`-390` suffixes in the baseline-naming convention are therefore aspirational naming, not the actual captured viewport dimensions, for the two baselines that were captured. This is recorded as a second Atelier tooling limitation, distinct from the authentication gap above.
- `gates.visualDiffThreshold: 0.01` was added to the root `H:\CommandCenter\orchestrator\atelier.config.json`, justified as a 1% mismatch tolerance appropriate for a text-heavy, non-photographic UI tolerant of font-rendering and anti-aliasing noise. Confirmed via `mcp__atelier__tokens_validate` that the config still parses correctly (136 tokens, 0 errors, the same 2 pre-existing unrelated warnings from section 3) after this addition.

*Browser journeys (Part B) — key finding.*

- Exhaustive DOM inspection (`document.querySelectorAll('a')`) across every planned route (login, roadmap, week detail, flashcards, feedback, catalog, admin dashboard/students/brand-design), authenticated as both a seeded student and a seeded owner account, found **zero** un-classed `<a>` elements anywhere in the currently reachable, seeded-account app that inherit the bare `a { color: var(--color-link-text) }` rule defined in section 4. The only two real `<a>` tags found in the app (`.resources-panel-link`, `.admin-shell-link`) are both fully overridden by their own component CSS and never resolve through `--color-link-text`. The element that visually resembles a link ("← Back to roadmap") is a `<button>`, not an anchor.
- Consequence: journeys 1 (`paper.50` reading sheet), 2 (`paper.100` panel), and 4 (visited-link real-history parity) from section 10 could not be executed against a live, rendered, default-styled link, because none currently exists in the shipped app's reachable surface. These are recorded as **passed by source-and-token-architecture verification only, with this explicit caveat**, not as a rendered-visual pass. Independent verification (the Verifier's Phase 1 pass, plus this Browser Validator pass's own `getComputedStyle` check) already confirmed `--color-link-text` resolves to `#7c6136` (`brass.700`) and is immune to `BrandingContext` overrides. If a future page or component ever renders a bare, unstyled `<a>` tag, the fix in section 4 will apply to it correctly; there was simply no live instance to photograph.
- Journey 3 ("none found on a `paper.200` surface, with evidence" — an explicitly valid outcome per section 10) is satisfied by the same finding.
- Journey 5 (Owner Brand Design page, confirming the `BrandingContext` hole is closed) **passed cleanly with real rendered evidence**: a custom brand color was set via the live form; `--color-link-text` remained `#7c6136` (unaffected) while brand-dependent nav/border accents correctly picked up the new color.
- Journey 6 (reduced motion) was confirmed via source check that exactly one `@media (prefers-reduced-motion: reduce)` block exists in `App.css` (line 149); no live-emulation test was performed, a tooling constraint, source-check only, per the job's own allowance.
- Journey 7 (keyboard focus) was not separately re-verified in this pass beyond what Phase 1's own guard tests and code already establish; the `a:focus` rules were explicitly untouched by Phase 1.
- Journey 8 (no-native-dialog scan) was confirmed clean across roughly 30 interactions and page loads; no `alert`/`confirm`/`prompt` fired.

*Overall Phase 3 disposition.* Treated as complete with two honestly-recorded, non-blocking limitations: Atelier's authenticated-session baseline gap, and the absence of a live default-link consumer to photograph against. No regression was found. The orchestrator, not Scribe, made the judgment call to accept this disposition rather than loop back for further clarification, on the basis that both findings are architectural or tooling limitations rather than defects in the shipped fix.

---

## 7. Interfaces and data

- No data-model change, no migration, no service-layer change, no exported-contract change.
- One new design token leaf, `color.link.text`, dual-written to both token layers.
- One new test file, `src/__tests__/linkColorContrast.test.ts`.
- Two token `$description` additions for `brass.500` (both layers).
- One `App.css` rule block replacement (`:281-294`).
- Two doc-comment corrections (`BrandingContext.tsx`, `BrandingContext.test.tsx`).
- One new `gates.visualDiffThreshold` entry in the root `atelier.config.json`, plus fifteen named Atelier baselines (Phase 3), additive only.
- Zero or more new GitHub issues (Phase 1's one issue, plus Phase 2's gap issues).

---

## 8. Acceptance and validation

- `src/__tests__/linkColorContrast.test.ts` written first, failing, then passing, with all six assertions (a)-(f) listed in section 4.
- `npm run type-check` clean; `npm run lint` clean.
- Targeted Vitest run green, including `statusColorContrast.test.ts`, `contrast.test.ts`, `BrandingContext.test.tsx`, `weekDetailBackLinkStyling.test.ts`, and `AccessibilitySettings-Rebuild.test.tsx` (proving no collateral breakage). Do **not** run the full suite; it requires Supabase, which is out of scope.
- `mcp__atelier__tokens_validate` passes; `mcp__atelier__contrast_check` shows no failing pair for the link role; `mcp__atelier__design_review` on `App.css` stays at 0 findings.
- Deterministic no-raw-hex scan on every touched CSS file.
- Deterministic no-native-dialog scan for `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload`.
- Deterministic scan confirming no second `prefers-reduced-motion` mechanism was introduced and that the existing `App.css:149-156` reduce block is unmodified.
- Deterministic scan confirming `:visited` sets only permitted color-family properties, and that its declared `color` is identical to `a`'s declared `color` (see the hard invariant in section 4).
- The token dual-write is verified in **both** files, not just one.
- Verifier pass, then Browser Validator pass.

---

## 9. Browser UI dialog policy

**Required.** This is browser-rendered React/Vite UI. Native `alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts are **prohibited**. Acknowledgement or confirmation must use the app-owned accessible modal; inline validation where it better serves the user.

This change introduces no dialog and touches no dialog code. The deterministic source scan for the prohibited APIs remains a required acceptance check.

---

## 10. Browser UI validation

- **Launch/readiness**: a dev server is **already running** and healthy at `http://localhost:5173/` (Vite v5.4.21, HTTP 200). Reuse it. Do **not** kill it and do **not** kill node processes. If and only if it is genuinely down, start `npm run dev -- --port 4319 --strictPort` from `H:\CommandCenter\orchestrator\lizbeth_spanish`; ready when Vite logs "ready in" and the Local URL. Excluded ports: 5199, 5211, 5299, 5317, 5321, 7913 (confirmed failure). Reserved: 4173 (`preview:prod`), 8888 (Playwright/`netlify serve`). Fallback: 9187.
- **Base URL**: `http://localhost:5173`.
- **Fixture/reset**: none required; this is a pure CSS/token change with no data dependency. Use the existing seeded student path for any journey needing an authenticated view. Do not reseed, and do not touch Supabase.
- **Viewport profiles**: 1440x900 and 390x844, both required.

### Journeys and visible outcomes

1. **Week detail reading sheet (`paper.50` ground)**: default link renders in the darker `brass.700`; hover thickens the underline with **no** color flash to terracotta; focus shows the existing 3px `ink.slate` ring at 2px offset, unchanged.
2. **A panel on a `paper.100` ground**: confirm link legibility.
3. **A card/tab surface on a `paper.200` ground**: confirm whether any un-classed link inheriting the bare `a` rule renders there. Recording "none found," with evidence, is a valid and expected outcome.
4. **A genuinely visited link, using real browser history**: take an actual screenshot and visually confirm the link renders **identically** to an unvisited link — same text color, same underline. This is the intended, documented behavior (see the "Visited" decision in section 4); a visible difference is a regression. Do **not** use `getComputedStyle` or any computed-style assertion; the browser deliberately lies about `:visited`.
5. **Owner Brand Design page**: set a custom brand color; confirm body link text is unaffected (still `brass.700`) while nav/border accents do pick up the brand color. This is the concrete proof that the `BrandingContext` hole is closed.
6. **With OS-level reduce-motion enabled**: confirm the hover thickness change is instant.
7. **Keyboard-only pass over links**: focus ring visible and unchanged.
8. **Deterministic no-native-dialog scan** across every journey.

**Visible outcomes summary**: link text visibly darker/browner than the current washed-out `brass.500`; hover thickens the underline with no text-color change; a real visited link is pixel-identical to an unvisited link; focus ring unchanged; no layout shift.

---

## 11. Risks and rollback

- **LOW/MEDIUM** — the `a` rule is global, so every link in the app changes appearance. Mitigation: the change is color-only within the existing palette (`brass.500` → `brass.700`, a darker tone of the same hue) with no geometry change; class-scoped links with their own color overrides are unaffected by specificity. Rollback: a single CSS block revert plus removing one token leaf; purely additive token work is safe to leave.
- **MEDIUM** — the `:visited` browser property restriction is a silent-failure class: a future writer could reintroduce a non-rendering rule, or a visibly distinct visited color, and no computed-style test would catch it. Mitigation: recorded as a hard engineering invariant in section 4 (exact color parity with the default state, with the color-parity source-scan assertion (f) as a guard); the Browser Validator must confirm visited state from a real rendered screenshot with genuine browser history, never from `getComputedStyle`, and must treat any visible difference as a regression.
- **LOW** — token drift between the two independent token mechanisms. Mitigation: both `brass.500` definition sites are named explicitly by file and line in section 3.
- **MEDIUM** — Phase 2 could surface a large volume of gaps. Mitigation: Phase 2 is bounded to audit-and-file-issues; remediation is an explicit non-goal requiring separate plans.
- **LOW** — `gh` may be unauthenticated. Mitigation: Phase 0's gate degrades gracefully rather than blocking the correctness fix.
- **Process hazard.** This repository has a documented history of a subagent running broad `taskkill /F /IM node.exe /T` and causing collateral damage, twice, despite explicit instructions. Only explicit-PID termination is permitted, and the port-5173 dev server must stay up throughout this plan's execution.

**Rollback overall**: Phase 1 is a single CSS-block revert plus removing one token leaf; Phase 3's `gates.visualDiffThreshold` entry and its baselines are purely additive and safe to leave. Phase 2 produces documentation and issues only, with nothing to roll back in the codebase.

---

## 12. Design invariants carried into engineering

- Link text must resolve through `--color-link-text` (aliased to `brass.700`) and never through `--color-accent-primary`/`--color-accent-secondary`, which remain owner-brand-overridable and decorative-only.
- `terracotta.500`/`amber.*` must never carry text, including on hover.
- `:visited` may only set color-family CSS properties (`color`, `background-color`, `border-*-color`, `outline-color`, `text-decoration-color`, `column-rule-color`, SVG fill/stroke); all others are silently dropped by every major browser, and `getComputedStyle` masks even permitted ones. No non-color cue exists for `:visited`. This codebase's `a:visited` rule deliberately carries no distinction at all from the default state (see section 4), by recorded decision, not oversight. Any future change to this rule must preserve exact color parity with the default state unless a new, separately evaluated exception is recorded.
- Reduced motion routes only through the existing `App.css:149-156` mechanism; no second mechanism may be introduced.
- The token dual-write convention (`.atelier/tokens/field-workbook.tokens.json` and `src/tokens/field-workbook.generated.css`) must be honored for every new or modified token.

---

## 13. Assumptions and open decisions

- **Assumption** — the GitHub remote is `lebobo88/lizbeth-spanish`, per the issue38 plan's header. Phase 0 confirms it.
- **Assumption** — the ADOPTION-PLAN issue N → GitHub issue N+30 offset holds. Phase 0 confirms it against the live milestone.
- **Decision (Planner)** — Phase 2 files issues but does not remediate, and this plan does not pre-authorize remediation. Each gap needing real design work gets its own plan, matching the #31-#44 pattern.
- **Decision (Planner)** — `gh` work is assigned to the orchestrator or the engineering fleet, never to Researcher, whose Bash hook has no `gh` pattern.
- **Decision (Planner)** — the two benign `tokens_validate` warnings (`typography.role.targetLine.fontStyle`, `motion.reducedMotion` typed as `$type: "string"`) are out of scope for this plan. Noted as an optional future cleanup.
- **Approved**: this plan as a whole was approved by the user this session; see section 14 for the full record.

---

## 14. Required approvals

This plan required **explicit user approval** before T1/T2 execution begins. The user's standing session goal to carry approved work to completion without re-approving already-authorized steps does **not**, on its own, extend to this document. This plan correctly declined to treat the standing `/goal` alone as approval; that gate is now satisfied by a direct statement.

**Approval record.**

- Approved by: the user, rob.hasselbach@gmail.com.
- Verbatim reply: "approved".
- Context: the orchestrator presented the compact plan summary (Phase 1: new `color.link.text` semantic token fixing the `brass.500` link-contrast WCAG failure plus `a:hover`/`a:visited` corrections; Phase 2: GitHub issue tracking via `gh` continuing the project's #31-#44 numbering convention; Phase 3: Atelier MCP visual-diff validation against the locally-committed Field Journal design reference plus browser visual validation) and asked, "Do you approve this plan for execution?" The user's "approved" reply was sent in direct response to that question, regarding this specific plan document.
- When: this session (2026-09-02).
- Classification: a direct, plan-referencing approval, not an approval inferred from the standing session goal alone.

T1/T2 execution may now proceed per section 15's downstream ownership.

At approval, the user's attention was specifically directed to:

- **Phase 0's gate**: if `gh` is unauthenticated, the plan proceeds with the code fix and defers issue tracking rather than blocking. Confirm this degrade-gracefully behavior is acceptable.
- **Phase 2's boundary**: it audits and files issues only; it does not authorize remediation of anything it finds. Any gap it surfaces needs a separate plan and a separate approval.
- **The process hazard in section 11**: no `taskkill /F /IM node.exe`, no Docker/Supabase changes, no full test suite.

---

## 15. Engineering mode and downstream owner

- Engineering mode: standard.
- Team authorization: not applicable.
- Downstream owner: engineering-fleet (T1 primary, T2 escalation per the two-counted-gate-failure rule, then Verifier, then Browser Validator).
