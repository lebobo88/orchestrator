# Lizbeth Spanish — Field Journal DS reference coverage map

Audit-only deliverable (Phase 2 of `docs/plans/lizbeth-spanish-design-token-audit-remediation.md`).
No production code was touched while producing this map. Nothing here was remediated; genuine
gaps found were filed as new GitHub issues (Step 6) instead.

## Method

1. Re-confirmed the live state of GitHub issues #31-#44 in `lebobo88/lizbeth-spanish`
   (`gh issue list --milestone "Field Journal DS"` and per-issue `gh issue view`).
2. Read `design/field-journal/ADOPTION-PLAN.md` in full for the section-to-issue decomposition.
3. Spot-checked `DS.dc.html` line/char-offset citations already present in the issue-31 and
   issue-37 plan docs and in `design/field-journal/extracted/tokens.field-journal.json`, by
   re-resolving each cited offset/line against the current
   `design/field-journal/Field Journal DS.dc.html` (211,116 bytes / 208,603 chars — the char
   count matches the plan's stated byte-identical copy; the byte/char delta is pure UTF-8
   multi-byte punctuation, not drift).
4. Ran `mcp__atelier__contrast_check` (direct foreground/background arguments, since the broad
   token-aware scan is blocked — see "Known blocker" below) against the documented
   terracotta.600/paper.200 trap, and grepped `src/**/*.css` for every live occurrence of
   `--color-status-error-text` / `--color-terracotta-600` paired with
   `--color-surface-chrome-default` / `--color-paper-200` in the same rule.
5. Read the GitHub comment thread on every one of #31-#44 for recorded implementation,
   verification, browser-validation, and design-review evidence.

### Known blocker (not remediated, already tracked)

`mcp__atelier__design_review` and the broad form of `mcp__atelier__contrast_check` both resolve
their project root to `H:\CommandCenter\orchestrator` instead of `lizbeth_spanish`, so they cannot
see this repository's own `atelier.config.json` or CSS surface. This is the same infrastructure
defect already recorded and tracked in issue #31's plan amendment
(`docs/plans/lizbeth-spanish-issue31-design-system-foundations.md`, "Amendment" section) and in
that issue's binding follow-up requirement. No new issue is filed for it here — it is already
owned by #31's re-verification requirement. The direct-argument form of `contrast_check` (passing
literal hex values) is unaffected by this misconfiguration and was used instead for the trap
re-check in Step 4.

## Citation cross-check result

Spot-checked (not exhaustive, given the number of citations across 14 plan documents and three
token files):

| Citation | Source | Resolves to |
|---|---|---|
| `§A.1 palette (~4625)` | issue #31 GH body | Correct — palette section boundary |
| `§A.3 rules & elevation (~17040)` | issue #31 GH body | Correct — geometry/elevation/paper section boundary |
| `§A.5 motion (~21337)` | issue #31 GH body | Correct — motion + a11y section boundary |
| `chars 4055-24437` | `extracted/tokens.field-journal.json` `$description` | Correct — exact start of `<section id="A">` to end of section A / start of section B |
| `DS.dc.html:590,1285,603,1291` | `field-workbook.generated.css` line 188 comment (issue #37 hero/signin sizes) | Correct — lines 590/1285/603/1291 are the four cited `<h1>`/`<h2>` specimens at 88px/46px/44px/32px, matching the four component-token values (5.5rem/2.875rem/2.75rem/2rem) exactly |

No citation drift found in the sampled set. The file is byte-identical to the plan's recorded copy
(208,603 chars).

## Terracotta.600 / paper.200 trap re-check — GENUINE DEFECT FOUND

The documented trap (`terracotta.600` on `paper.200` fails WCAG AA at 4.05:1 / APCA Lc 61.49,
re-confirmed via `mcp__atelier__contrast_check(foreground: "#a85e4a", background: "#f0ebe2")`) is
**not fully guarded**. `src/__tests__/statusColorContrast.test.ts` (issue #33) only asserts the
computed hex-pair math; it does not scan live CSS for the pairing. A live scan
(`grep -rn "color-status-error-text" src --include=*.css` cross-referenced against
`--color-surface-chrome-default: var(--color-paper-200)` in `src/App.css:47`) found two real,
currently-shipping instances in `src/components/LoginForm.css`:

- line 334: `.login-form-error { color: var(--color-status-error-text); background-color: var(--color-surface-chrome-default); ... }`
- line 339: `.auth-session-error-card .session-error { color: var(--color-status-error-text); background-color: var(--color-surface-chrome-default); ... }`

Both pair terracotta.600 text on a paper.200 background, failing AA. Filed as
**[#60](https://github.com/lebobo88/lizbeth-spanish/issues/60)** (new issue, Step 6). This is not
covered by any existing #31-#44 issue's recorded acceptance criteria or validation evidence.

The already-recorded non-defect at `LearnDetailPage.css:120` was re-checked and confirmed still
not a live instance of the trap (current line 120 is an unrelated `.lesson-card--unlocked-*`
icon-color rule) — no duplicate issue filed, per the brief.

## Coverage map

All 14 GitHub issues (#31-#44) are **OPEN**, each carrying a GitHub comment recording
implementation + engineering verification + browser validation (with named remediation cycles
where real defects were caught) + independent design review, and each explicitly left OPEN and
tracked as "conditionally complete" pending the shared Atelier re-verification gap owned by #31
(see "Known blocker" above). A corresponding `docs/plans/lizbeth-spanish-issue<N>-*.md` plan
document exists for every one.

| ADOPTION-PLAN section(s) | GitHub issue | State | App files governed | Plan doc exists | Classification |
|---|---|---|---|---|---|
| A.1, A.3, A.4, A.5 (foundations: palette, geometry/elevation, paper stocks, motion) | #31 | OPEN | `src/tokens/primitives.json`, `semantic.json`, `components.json`, `.atelier/tokens/field-workbook.tokens.json`, `src/tokens/field-workbook.generated.css` | Yes (`issue31-design-system-foundations.md`) | **validated** |
| A.2 (typography: four hands) | #32 | OPEN | `src/App.css` (`@import`), token files, `src/tokens/tokenSystem.ts` | Yes (`issue32-typography-four-hands.md`) | **validated** |
| A.6 (token plumbing + fallback audit + enforcement lint) | #33 | OPEN | every `src/**/*.css`, `src/components/icons.tsx`, new lint test | Yes (`issue33-token-fallback-audit-enforcement-lint.md`) | **validated** |
| B, C.9 (journal devices + empty state) | #34 | OPEN | `src/components/journal/`, `SpotIllustration.tsx`, `IpNotice.tsx/.css` | Yes (`issue34-journal-devices-empty-state.md`) | **validated** |
| C.1-C.3 (controls, fields, marks & stamps) | #35 | OPEN | `src/components/ui/`, `Modal.*`, `LoginForm.*`, `RegisterStudentModal.*`, `AdminStudentModals.*`, `AccessibilitySettings.*`, `ForcedPasswordChangeGate.*` | Yes (`issue35-controls-fields-marks.md`) | **validated** (see LoginForm.css contrast defect above, filed as #60 — not caught by #35's recorded validation) |
| C.4-C.8 (week card, four-chunk anatomy, segment ledger, owner ledger row, metric plate) | #36 | OPEN | `WeekCard.*`, `LessonContentView.*`, `BandRoadmap.*`, `FlashcardsViewer.*` | Yes (`issue36-week-card-lesson-chunks-ledgers-metric-plate.md`) | **validated** |
| D.1 + E.1 (Login / Sign in) | #37 | OPEN | `LoginForm.*`, `ForcedPasswordChangeGate.*` | Yes (`issue37-login-signin-screen.md`) | **validated** (same LoginForm.css caveat as #35 above) |
| D.2 + E.2 (Roadmap) | #38 | OPEN | `RoadmapPage.*`, `BandRoadmap.*`, `WeekCard.*` | Yes (`issue38-screen-roadmap.md`) | **validated** |
| D.3 + E.3 (Week detail: reading sheet + attachments rail) | #39 | OPEN | `WeekDetailPage.*`, `LessonContentView.*`, `ResourcesPanel.*` | Yes (`issue39-week-detail-reading-sheet-attachments-rail.md`) | **validated** |
| D.4 + E.4 (Flashcards) | #40 | OPEN | `FlashcardsViewer.*` | Yes (`issue40-flashcards-screen.md`) | **validated** |
| D.5 + E.5 (Feedback) | #41 | OPEN | `FeedbackPage.*`, `FeedbackForm.*`, `OwnerFeedbackPage.*` | Yes (`issue41-feedback-screen.md`) | **validated** |
| D.6, D.7 + E.6 (Owner dashboard + Roster) | #42 | OPEN | `OwnerDashboardPage.*`, `AdminStudentsPage.*`, `AdminShell.*` | Yes (`issue42-owner-dashboard-roster-screen.md`) | **validated** |
| D.8, D.9 (Brand + Catalog) | #43 | OPEN | `BrandDesignPage.tsx`, `PublicCatalogPage.*` | Yes (`issue43-brand-catalog-screens.md`) | **validated** |
| Derived screens (A+B+C primitives, no reference artboard) | #44 | OPEN | `CourseWorkspacePage.tsx`, `CourseWorkspace.css`, `CourseSettingsPage.tsx`, `CourseSettingsFix.css` *(now removed — see note)*, `NewCoursePage.tsx`, `BusinessSettingsPage.tsx`, `OwnerSettingsPage.*` | Yes (`issue44-derived-owner-pages.md`) | **validated / no-reference-derived** — this single issue covers all six no-reference pages named in the brief |

Note on #44: `git status` shows `src/pages/CourseSettingsFix.css` deleted in the working tree,
consistent with the issue's recorded consolidation of that page onto shared A+B+C primitives
rather than its own override file. This is expected, not a gap.

### The six no-reference-derived pages, individually

Per the ADOPTION-PLAN, `CourseWorkspacePage`, `CourseSettingsPage`, `NewCoursePage`,
`BusinessSettingsPage`, `OwnerSettingsPage`, and `OwnerFeedbackPage` have no reference artboard by
design and are covered collectively by #44 (composed from A+B+C primitives, judged against the
primitives rather than a screenshot, per the plan). All six file paths above are present in the
current working tree and are in scope of #44's recorded implementation/verification/browser
validation. No separate gap issue is needed for any of the six individually — this matches the
plan's explicit decision that no reference screen means no per-page gap issue, only confirmation
of shared-primitive composition, which #44's evidence already provides.

## Step 6 — issues filed

One new issue filed for the one genuine gap found:

- **[#60](https://github.com/lebobo88/lizbeth-spanish/issues/60)** — "Field Journal DS: LoginForm.css
  pairs terracotta.600 error text with paper.200 background, failing WCAG AA." Labels:
  `bug`, `area:contrast`, `area:auth`, `area:design-system`, `severity:S3`. References §A.6/2 and
  the ratified band-ink contrast note in `ADOPTION-PLAN.md`; cites the re-resolved contrast
  measurement (WCAG 4.05, APCA Lc 61.49) and the two exact live CSS rules. Depends on #37, #33.

No other genuine gap was found in this audit. Every ADOPTION-PLAN section maps to an existing
tracked issue with recorded implementation and validation evidence; the Atelier MCP
projectRoot-misconfiguration blocker is already tracked on #31 and is not duplicated here; the
`LearnDetailPage.css:120` non-defect was re-checked and confirmed not live, and was not
re-reported.
