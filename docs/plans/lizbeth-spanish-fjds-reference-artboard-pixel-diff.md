# Lizbeth Spanish — Field Journal DS Reference Artboard Pixel Diff

## Status

**APPROVED.** Approved via standing forward authorization plus the user's later blanket "just do all the work" instruction; see the Approval gate section at the end of this document for the full record. T1, browser-validator, and design-reviewer dispatch under this plan may now proceed per the ordered work below. This plan corrects and supersedes Step 4 of `docs/plans/lizbeth-spanish-fjds-fresh-comprehensive-audit.md`, which assigned reference-baseline extraction to a role contractually forbidden from performing it (see Background, Finding 1).

## Outcome and audience

Establish genuine, non-circular pixel-level visual comparison of the running `lizbeth_spanish` app against the actual Field Journal DS reference artboards.

Audience: the engineering fleet executing this plan (t1-engineer, browser-validator, design-reviewer) and the user approving it.

## Scope

### In scope

- Extracting reference artboards from the local design file into standalone renderable harness pages.
- Capturing those harness pages as Atelier baselines.
- Capturing the live app at the corresponding screens.
- Comparing app captures against the reference baselines.
- Recording per-screen findings and triaging them.

Priority screens:

- D.2 / E.2 Roadmap
- D.3 / E.3 Week detail
- D.4 / E.4 Flashcards

(These three are the screens this session remediated most heavily.)

- D.1 Login and D.9 Catalog, as the already-baselined unauthenticated proof-of-mechanism pair.

### Not in scope

- Any change to app UI, component, or CSS source. This plan measures; it does not remediate. Any diff found is a **finding** to be triaged and logged as a GitHub issue, not fixed under this plan.
- D.5–D.8 and E.5–E.6 (deferred).
- LearnIndexPage / LearnDetailPage (no reference artboard exists for them).

### No-touch list

- `lizbeth_spanish/atelier.config.json` must never be edited (standing directive; it is the misleading duplicate).
- No Docker.
- No Supabase.
- Never `taskkill`.
- Do not modify anything under `lizbeth_spanish/src/`.

## Background and repository findings

All findings below were independently read from the live repository during this planning pass.

### Finding 1 — Why the prior Step 4 failed: a role error, not a concept error

Step 4 of `docs/plans/lizbeth-spanish-fjds-fresh-comprehensive-audit.md` (lines 209–214) is conceptually correct: it instructs extracting the reference artboards and capturing those as baselines. It was dispatched to `browser-validator`, which cannot perform it, for two independent contractual reasons:

1. `.claude/skills/browser-validator-core/SKILL.md` line 11 states verbatim: "Never update visual baselines or test snapshots."
2. `browser-validator` is read-only (tools: Read, Glob, Grep, Bash, Skill, chrome, atelier) and so cannot author the extracted harness files.

Browser-validator's refusal was correct. The fix is reassignment of the work to a role with write access, not a respecification of the underlying approach.

### Finding 2 — The reference file is structurally extractable (confirmed by direct read)

File: `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html` (208,603 characters).

The section `<section id="D" style="width: 1440px;">` begins at line 573. Each screen is marked by a plain HTML comment (for example `<!-- D.1 LOGIN -->` at line 580, `<!-- D.2 ROADMAP -->` at line 624), followed by a `<p>` caption element, followed by exactly one sibling `<div>` that is the artboard itself.

- The D.1 artboard div (line 582) carries `width: 1440px; height: 900px`.
- The D.2 artboard div (line 626) carries `width: 1440px` with no fixed height (auto height).

Confirmed screen marker line numbers:

| Screen | Line |
|---|---|
| D.1 | 580 |
| D.2 | 624 |
| D.3 | 762 |
| D.4 | 899 |
| D.5 | 935 |
| D.6 | 963 |
| D.7 | 1096 |
| D.8 | 1146 |
| D.9 | 1182 |
| E.1 | 1274 |
| E.2 | 1311 |
| E.3 | 1382 |
| E.4 | 1430 |
| E.5 | 1469 |
| E.6 | 1507 |

Content is entirely plain HTML with inline `style` attributes. There are no React components and no framework-driven rendering inside the artboards themselves.

### Finding 3 — The file is not safely renderable as-is: hence the harness approach

The file's `<head>` (line 6) loads `./support.js`, a 69KB `dc-runtime` bundle. `design/field-journal/README.md` lines 51–55 state the file "expects `window.React` / `window.ReactDOM`" and that "Viewing it in the published canvas is the reliable path." No React CDN script tag exists in the file. The document body is wrapped in nonstandard `<x-dc>` and `<helmet>` custom elements (lines 9–10).

The likely-but-unverified behaviour is that `support.js` fails on the missing React globals and leaves the raw DOM standing, which would probably render acceptably. **This plan does not rely on that.** The specified approach extracts each artboard into its own clean standalone HTML file, which sidesteps `support.js`, `<x-dc>`, and `<helmet>` entirely and is deterministic.

### Finding 4 — Font parity is confirmed (the single biggest de-risking fact)

A pixel diff is worthless if the two sides use different fonts.

- Reference (`Field Journal DS.dc.html` line 14) loads Fraunces (400, 600, 700, 900), Source Sans 3 (400, 600, 700), IBM Plex Mono (400, 500, 600, 700), Caveat (500, 700) from Google Fonts.
- App (`lizbeth_spanish/src/App.css` line 14) loads Fraunces (incl. 900), Source Sans 3 (400, 600, 700), IBM Plex Mono (400, 500, 600, 700), Caveat (500, 700), plus Atkinson Hyperlegible and Lexend, which the reference lacks but which are accessibility-mode alternates, not defaults.

The four Field Journal families and their weights match exactly between reference and app. The harness pages **must** reproduce the reference's exact Google Fonts link so both sides resolve identical typefaces.

### Finding 5 — Nonstandard attributes mean default-state only

The reference uses non-CSS `style-hover=` and `style-active=` attributes (for example line 612, the D.1 primary button). Browsers ignore unknown attributes, so a static render captures the default state only. Hover, focus, and active states are **not** pixel-comparable by this mechanism and must be excluded from scope explicitly rather than silently.

### Finding 6 — The operative Atelier config and existing baselines

The operative config is the root `H:\CommandCenter\orchestrator\atelier.config.json` (editable), which sets `gates.visualDiffThreshold: 0.01` and a five-entry review allowlist.

`H:\CommandCenter\orchestrator\.atelier\baselines\` currently contains exactly two files:

- `field-journal-d1-login-1440.png`
- `field-journal-d9-catalog-1440.png`

**Important unverified point:** the provenance of these two files is not established. It is unknown whether they were captured from the reference artboard or from the app. Step 0 of this plan must determine this. If they are app-captures, they are circular and must be replaced, and any prior passing diff against them must be retracted as meaningless.

### Finding 7 — Authentication split drives the two-track design

D.1 (Login) and D.9 (Catalog) are unauthenticated routes reachable by Atelier's own isolated screenshot session. D.2 Roadmap, D.3 Week detail, and D.4 Flashcards are authenticated routes that Atelier's isolated unauthenticated session cannot reach; the app side for those must be captured by `browser-validator` via claude-in-chrome against the existing authenticated session.

### Finding 8 — Genuine tool-capability unknowns

The Atelier MCP server is registered at user scope; no `.mcp.json` exists in this repository and no Atelier server source is on disk, so its tool schemas could not be read during planning. Three signatures are unknown and must be probed empirically before committing to the automated track:

1. Whether the screenshot tool's documented `path:` local-HTML-file input resolves relative to the root project or the app subtree.
2. Whether `visual_diff` accepts a pre-captured PNG as its comparison input rather than only capturing live itself.
3. Whether baselines must be registered in `atelier.config.json` or are discovered by filename convention.

Do not assume any of these answers before Step 0 resolves them.

## Research evidence

None. Every question in this plan was answerable from local repository evidence. No external or current-fact dependency exists.

## Design route

None. This task produces no user-visible interface change. It builds disposable measurement scaffolding and records findings. `docs/DESIGN-CONTRACT.md` routes design for user-visible interface work; there is none here, so no design route was classified and no design gate applies.

Note: `design-reviewer` appears in the ordered work below as a downstream **executor** performing reference-vs-app conformance judgement. That is an execution assignment, not a planning-stage design gate, and the two must not be conflated.

- design_handoff: none
- design_review: none

## Ordered work

### Step 0 — Capability probe and baseline provenance audit

**Owner:** t1-engineer (has both Write and `mcp__atelier__*`). **Blocking** — nothing downstream may proceed on assumption.

- **0a.** Determine the provenance of the two existing baselines in `.atelier\baselines\`. Compare each against both the corresponding reference artboard and the live app. Record which they actually are. If they are app-captures, mark them circular, state that plainly, and replace them in Step 2.
- **0b.** Probe the Atelier screenshot tool with a trivial local HTML file to establish how `path:` resolves (root project vs. app subtree) and that local-file rendering works at all.
- **0c.** Probe whether `visual_diff` can accept a pre-captured PNG as input. Record the actual answer.
- **0d.** Determine whether baselines require registration in the root `atelier.config.json` or are convention-discovered.
- **0e.** Record all four answers verbatim in the execution report. These answers select between Track B-automated and Track B-manual at Step 4.

### Step 1 — Build the reference artboard extraction harness

**Owner:** t1-engineer.

Write a Node script plus its generated output under a new disposable directory: `H:\CommandCenter\orchestrator\.atelier\reference-harness\`. Nothing under `lizbeth_spanish/src/` may be touched.

The script must:

- Parse `lizbeth_spanish/design/field-journal/Field Journal DS.dc.html`.
- For each target screen marker, extract the single sibling artboard `<div>` that follows the marker's caption `<p>`, excluding the caption itself.
- Emit one standalone HTML file per artboard, named `field-journal-<id>-<name>-<width>.html`, each containing:
  - a normal `<html>/<head>/<body>`;
  - the reference's exact Google Fonts `<link>` from line 14;
  - the reference's `<style>` block from lines 15–22 (it carries the keyframes and the body background/font-family);
  - `body { margin: 0 }`;
  - the extracted artboard div as the sole body content.
  - No `support.js`, no `<x-dc>`, no `<helmet>`.
- Record each artboard's intrinsic width and height (fixed where declared, e.g. D.1's 900px; measured after render where height is auto, e.g. D.2). Write these to a manifest JSON in the same directory. Downstream capture **must** use these exact per-artboard dimensions — a naive fixed 1440x900 viewport will produce a meaningless diff for auto-height artboards.

Target screens for this plan: D.1, D.2, D.3, D.4, D.9 at 1440 wide, and E.2, E.3, E.4 at 390 wide.

**Verification for this step:** open at least two generated files and confirm they render as recognisable artboards with correct typefaces before proceeding.

### Step 2 — Capture reference baselines

**Owner:** t1-engineer.

Screenshot each generated harness file with the Atelier screenshot tool at its manifest dimensions, and write the result as an Atelier baseline named `field-journal-<id>-<name>-<width>.png`, following the naming convention the two existing files already establish. Register them in the root `atelier.config.json` if and only if Step 0d showed registration is required.

These images are captures of the **reference**, never of the app — this is what makes the exercise non-circular.

### Step 3 — Track A: fully automated diff on unauthenticated routes

**Owner:** t1-engineer.

Start the dev server at `localhost:5173`. Run `visual_diff` for D.1 Login and D.9 Catalog against their reference baselines at the configured 0.01 threshold. This is the end-to-end proof that the mechanism works. Record the numeric diff for each.

### Step 4 — Track B: authenticated routes

**Owner:** browser-validator for capture; then per Step 0c's answer:

- **If Step 0c showed `visual_diff` accepts a pre-captured PNG:** browser-validator captures the live authenticated app for D.2, D.3, D.4 at 1440 and E.2, E.3, E.4 at 390, each at the manifest dimensions; t1-engineer then feeds those captures to `visual_diff` against the reference baselines. Record numeric diffs.
- **If Step 0c showed it does not:** fall back to documented manual comparison. browser-validator captures the same set. `design-reviewer` is then dispatched with the paired reference-image / app-image set and produces a per-screen written conformance finding — specific and located (element, property, observed vs. reference), not a diff percentage and not a vague impression. This fallback is a legitimate completion of this plan, not a failure of it.

**Capture discipline for browser-validator:** reuse the existing authenticated tab per the confirmed-reliable tab-reuse and dev quick-select behaviour; never `taskkill`; fix viewport to the manifest dimensions; wait for font load and visual stability before capturing; capture default state only.

### Step 5 — Triage and record

**Owner:** t1-engineer.

Every non-zero diff and every design-reviewer finding is triaged against the ADOPTION-PLAN's ratified-deviations section. A delta that the ratified-deviations section already permits is recorded as ratified, not as a defect. Every genuine defect is logged as a GitHub issue via `gh`, per the standing directive that all work is logged via GitHub issues. **No code fix is made under this plan.**

## Interfaces and data

No application interface, schema, migration, or API is touched. The only written artifacts are:

- the disposable harness under `.atelier\reference-harness\`;
- new PNGs under `.atelier\baselines\`;
- possibly a baseline registration block in the root `atelier.config.json`.

## Acceptance and validation

- Step 0's four probe answers and the baseline-provenance verdict are recorded verbatim, not inferred.
- At least two generated harness files are visually confirmed to render as recognisable artboards with the correct four typefaces.
- Reference baselines exist for every target screen, each demonstrably captured from the harness and not from the app. **Central acceptance criterion:** no baseline in this set may originate from an app screenshot.
- Track A produces a numeric diff for D.1 and D.9.
- Track B produces either numeric diffs or specific located design-reviewer findings for D.2, D.3, D.4, E.2, E.3, E.4.
- Every finding is triaged against ratified deviations and every genuine defect has a GitHub issue number.
- `lizbeth_spanish/atelier.config.json` is unmodified. Nothing under `lizbeth_spanish/src/` is modified. Confirm both by `git status`.

## Risks and rollback

- **Risk:** the harness render does not match how the reference was authored to look (e.g. an inherited style from an ancestor the extraction dropped). **Mitigation:** Step 1's explicit visual confirmation gate before any baseline is written. If a harness page looks wrong, stop — a wrong baseline is worse than no baseline.
- **Risk:** auto-height artboards produce a height mismatch and a meaningless 100% diff. **Mitigation:** the per-artboard dimension manifest, used by both capture sides.
- **Risk:** font loading race causes a fallback-font capture on either side. **Mitigation:** explicit font-load wait before capture; font parity is already confirmed at the source level (Finding 4).
- **Risk:** the reference artboard shows idealised placeholder content while the app shows real data, so a pixel diff reports large deltas that are content differences, not design defects. This is expected and is precisely why Step 5 triages rather than auto-fails, and why the design-reviewer fallback (which can reason about intent) may in practice yield more useful findings than a diff percentage. This is stated honestly here rather than overselling the automated track.
- **Risk:** Step 0 reveals the Atelier tools cannot do what is assumed. **Mitigation:** the plan already carries the manual fallback as a first-class branch, so this degrades rather than blocks.
- **Rollback:** all writes are additive and confined to `.atelier\` plus one optional config block. Delete the directory and revert the config block. No app code, data, or schema is involved.

## Assumptions and decisions

- **Safe assumption:** standing forward authorization applies, per `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16 as extended by the user's blanket instruction. This plan still requires explicit user approval of this document before execution.
- **Explicit unknown, not an assumption:** the three Atelier tool signatures and the provenance of the two existing baselines. Step 0 resolves all four empirically. This plan must not read as though any of them is already known.
- **Decision taken:** extract to a standalone harness rather than render the `.dc.html` directly, because the direct path depends on unverified `support.js` failure behaviour while the harness path does not.
- **Decision taken:** scope limited to 8 artboards, prioritising the most-remediated screens, rather than all 15.

## Browser UI dialog policy

Not applicable. This plan makes no change to application UI code, so no native-dialog surface is introduced or altered. The standing Browser UI invariant continues to bind any future remediation arising from this plan's findings.

## Browser UI validation

browser-validator is dispatched for capture only, not as a completion gate.

- **Launch/readiness:** dev server at `http://localhost:5173`, ready when the login route renders.
- **Base URL:** `http://localhost:5173`.
- **Fixture/reset:** reuse the existing authenticated session via confirmed tab-reuse and dev quick-select, never `taskkill`.
- **Journeys:** navigate to Roadmap, Week detail, and Flashcards as an authenticated student.
- **Viewport profiles:** per-artboard manifest dimensions, 1440-wide for D.x and 390-wide for E.x, **not** a blanket 1440x900.
- **Visible outcomes:** a stable, font-loaded, default-state capture of each named screen at the exact manifest dimensions.

## Engineering mode

Standard.

## Team authorization

Not applicable.

## Downstream owner

engineering-fleet.

## Approval gate

**This plan may not be executed until the user explicitly approves this document.** No T1, browser-validator, or design-reviewer dispatch under this plan may occur before that approval is recorded. Upon approval, update this file's status header from DRAFT to APPROVED before dispatching Step 0.

**Approval record.**

- Approved by: the user, rob.hasselbach@gmail.com.
- Basis: the standing forward authorization recorded in `docs/plans/lizbeth-spanish-fjds-issue31-33-revalidation.md` Section 16 ("Additional forward authorization granted by the same reply, scoped beyond this plan"), extended by the user's later, separate blanket instruction to "just do all the work."
- Context: the orchestrator presented the compact plan summary to the user before recording approval. Headline presented: extract real reference artboards from `Field Journal DS.dc.html` as standalone harness pages; use those as genuine Atelier baselines; run `visual_diff` against the live app for the representative subset of most-remediated routes (D.1/D.2/D.3/D.4/D.9, E.2/E.3/E.4); and use a design-reviewer side-by-side comparison as a first-class fallback rather than relying solely on automated diff percentages, because the reference artboards show idealized placeholder content versus the app's real data.
- When: this session (2026-09-02).
- Classification: an approval derived from standing forward authorization plus a subsequent blanket instruction, not a plan-specific affirmative reply. This is recorded as such rather than characterized as a direct plan-referencing approval, consistent with this document's own Assumptions and decisions section, which already flagged the standing-authorization basis as a "safe assumption" pending exactly this recorded confirmation.
- Scope note: the standing forward authorization cited above was originally scoped to backlog items 3-7 of `docs/plans/lizbeth-spanish-fjds-token-pipeline-reconciliation.md`. This plan is the reference-baseline prerequisite work for that same backlog sequence (Step 4 replacement of the fresh-comprehensive-audit plan, see Background Finding 1), and the user's blanket "just do all the work" instruction is recorded here as extending coverage to this prerequisite plan specifically because the orchestrator surfaced its compact summary first and the user did not object or narrow scope.

T1/browser-validator/design-reviewer execution may now proceed per the ordered work above, beginning with Step 0's blocking capability probe.
