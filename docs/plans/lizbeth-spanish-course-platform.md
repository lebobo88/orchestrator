# Plan: Lizbeth Spanish Course Platform

Status: **Approved by the user on 2026-07-17. Cleared for phased downstream execution per the ordered work in Section 5; each phase and sub-phase still passes its own acceptance, Verifier, and (for UI) Browser Validator gates before completion.**

task_id: lizbeth-spanish-course-platform
plan_id: lizbeth-spanish-course-platform

The user has approved this plan. Downstream engineering (T1/T2/T3/Engineering Lead) and Scribe content-authoring phases are now authorized to proceed under this plan's phase gates, in the order set out in Section 5. The approved plan path is `ENGINEERING_JOB.approved_plan` for engineering-fleet work, and the same approved path authorizes Scribe's content-deliverable phases. Each phase and sub-phase must still pass its own acceptance checks, an independent Verifier pass, and, for browser-rendered UI work, a Browser Validator pass, before it is treated as complete. If a material change invalidates a phase's basis after this approval, that phase must report the plan stale rather than proceeding.

**Revision note.** This is the finalized plan. The translator/interpreter-certification and heritage-learner tracks are committed scope; the Beginner/Intermediate/Advanced band set with the dual parallel-entry-plus-sequential-progression model is adopted; full-scale, up-front authoring of every committed band and track is committed scope, with a labeled recommendation on internal author-then-validate sequencing; and a seventh, evidence-backed "Central American" dialect zone covers El Salvador and Honduras. Decisions D1 through D5 are all settled per Section 11.2; no open user decisions remain.

---

## 1. Outcome and audience

Deliver, in phases, an approved implementation package for "Lizbeth Spanish": a research-grounded, multi-CEFR-band, dialectally-rich English-Spanish course, plus the accessible web application that gates and delivers it.

The finished package comprises:

1. A curriculum architecture document grounded in the project's anchor research, covering the CEFR/ACTFL five-pillar competency model, a dialect-zone matrix, and old/modern, formal/informal, and inclusive-language treatment layers.
2. One fully worked example lesson (the reusable content template): vocabulary list, phrase set, Q&A set, a 20-minute communicative practice activity, flashcards, a weekly vocabulary review recap, a generated and accessibility-validated instructor PPTX, and a generated and accessibility-validated student PDF.
3. A locally buildable, Chrome-validated, accessibility-first web application implementing enrollment-relative weekly content gating (with permanent access to previously unlocked weeks), a lesson viewer, gated per-lesson resource delivery, a feedback/topic-suggestion form, and owner-configurable branding and legal/IP content.
4. A standalone image-generation manifest document listing every planned image asset with a complete, externally runnable generation prompt.

Audience: a single instructor who is also the platform owner/admin, and adult learners (individuals, working professionals, and businesses) across CEFR levels A1 through C2, including learners with low vision and dyslexia.

New project root (does not yet exist and will be created under this plan): `H:\CommandCenter\orchestrator\lizbeth_spanish`.

**Committed additive scope (decision D4, Section 11.2).** The user has confirmed reversing this plan's original recommendation to exclude the anchor research's professional translator/interpreter-certification track and its dedicated heritage-learner academic track; both are now committed additive tracks layered on top of the core bilingual bands. Both tracks are described in Section 2.3 and in the now-committed Phase 7 and Phase 8 entries in Section 5, sequenced after the core bilingual bands and the Phase 2 template are validated. The flagged design-increment prerequisite for their interpreting/CAT-tool UI (Section 2.3; Section 4.4, item 10) still applies and is not removed by this confirmation.

---

## 2. Scope

### 2.1 In scope

- Curriculum architecture document grounded in the anchor research's five-pillar model, dialect-zone matrix, and register/inclusive-language framework (Phase 1).
- One fully worked example lesson as the reusable template for all future content (Phase 2).
- The reviewed Studio design system ("The Field Workbook," golden-hour finca-tequilera direction) as the binding visual/interaction language for the app (Phase 0 and Phase 3).
- A Phase-1, LOCAL-only web application (Chrome-validated) implementing:
  - Enrollment-relative, weekly-gated lesson access with permanent retention of previously unlocked weeks.
  - A lesson viewer presenting the four-chunk anatomy (rule box / example / translation task / dialect note) and the rhythm stepper (30/10/20 minutes, advisory pacing).
  - Gated per-lesson resource delivery (PDF, PPTX, flashcards, weekly vocabulary review).
  - A feedback / topic-suggestion form.
  - Owner/admin branding and legal-content configuration, including runtime-adjustable brand colors with an accessibility clamp.
  - A user-adjustable reading/accessibility system, global and persistent across every authenticated screen.
- WCAG 2.2 AA conformance plus explicit low-vision and dyslexia accommodations.
- Owner-editable IP/copyright notice content, explicitly labeled as non-legal-advice boilerplate pending counsel review.
- A standalone image-generation manifest document covering every planned image asset (lesson vocabulary-example images plus design-fleet-identified UI/brand/spot-illustration assets), each with a complete external prompt.
- The CEFR-band/track structure settled in decision D2 (Section 11.2): three bands (Beginner, Intermediate, Advanced), with a dual model of parallel band-entry (enrolling directly into the assessed-appropriate band) plus sequential band-progression (continuing into the next band on completion, with account and progress continuity), detailed in Section 6.
- The committed translator/interpreter-certification track and heritage-learner academic track (decision D4, Section 2.3; Phase 7 and Phase 8 in Section 5), sequenced after the core bilingual bands and the Phase 2 template are validated.

### 2.2 Non-goals (explicit boundaries requiring user confirmation, not silent choices)

- **Production hosting.** Wiring the application to live Netlify and Supabase hosted accounts is deferred to a later phase. This plan covers only the local build. (Neon was evaluated and is no longer presented as a live alternative; see decision D1, Section 11.2.)
- **In-app video conferencing or session recording.** The plan treats external recording as a design constraint: the instructor records sessions externally (for example, via Zoom or Loom) and uploads the resulting file for gated storage and playback under the same access and IP rules as other resources, with no in-app capture or conferencing. The user has confirmed this as a settled constraint, not merely an assumption; see decision D3, Section 11.2.

### 2.3 Committed additive scope: translator/interpreter-certification and heritage-learner tracks (decision D4)

The user has confirmed decision D4. This plan's scope includes two additive tracks layered on the core bilingual conversational/business bands, sequenced after the core bands and the Phase 2 worked-lesson template are validated, not as part of the initial core build pass:

- **Professional translator/interpreter-certification track.** Per the anchor research's two-interlocking-tracks model, this track begins at CEFR B2 and layers onto the bilingual track. It covers CAT-tool orientation, domain specialization, and consecutive, simultaneous, and sight-interpreting practice.
- **Heritage-learner academic track.** A dedicated path per the anchor research, covering academic literacy, register and genre expansion, and identity-aware pedagogy for heritage speakers.

**Flagged limit, still applies: a design increment is needed before either track's UI can build.** Confirming D4 settles only the yes/no inclusion of these tracks; it does not resolve this prerequisite. The passed Studio design system (Section 4) covers the core bilingual application: the roadmap, lesson viewer, resource delivery, feedback form, and admin surfaces. Written translation-task content for these two tracks already fits the reviewed "translation task" chunk anatomy (Section 4.2). However, the net-new UI surfaces these tracks need, specifically interpreting-practice audio playback, a record/upload/playback surface for interpreting exercises, and CAT-tool-orientation views, are not covered by the existing design pass and are not yet designed. A scoped design increment (a follow-up Compact or Standard design route through Design Director and Design Reviewer) is required before any Phase 7 or Phase 8 UI sub-phase can build. This is an honestly flagged limit, not a silent assumption, and remains a committed prerequisite even though the tracks themselves are now committed scope.

---

## 3. Repository findings and evidence

- **Greenfield target.** `H:\CommandCenter\orchestrator\lizbeth_spanish` does not exist. There is no existing code or design asset to reconcile; this plan defines the internal structure (an application-source tree, a curriculum-content tree, and a docs tree holding the image manifest and legal/config templates) for the engineering phase to instantiate.
- **Anchor research (mandatory grounding).** `docs/research/Global Spanish–English Language and Translation Training Ecosystems  Curriculum Architecture, Dialect Matrices, and Market Strategy.md` supplies:
  - The CEFR/ACTFL five-pillar competency model (reading, listening, speaking, writing, cross-language mediation).
  - The dialect-zone matrix (Peninsular, Mexican, Andean, Rioplatense, Caribbean, US Spanish) and the CEFR A1-C2 curriculum scaffolding table.
  - Cognitive-load packet anatomy (rule box / example / translation task / dialect note).
  - Taboo and register handling, business-track guidance, and market-positioning analysis, plus a separate professional-translator/heritage-learner track that this plan now includes as committed additive scope (see Section 2.3 and Section 11.2, decision D4), sequenced after the core bands and Phase 2 template are validated.
  - This document's principles are applied **within** the user's explicit weekly-lesson, 6-month course format. Its full translator-certification and heritage-learner tracks are adopted as committed additive tracks per confirmed decision D4 (Section 2.3, Section 11.2), sequenced after the core bands and Phase 2 template are validated; the design-increment prerequisite in Section 2.3 still applies.
- **Dialect-zone taxonomy verification (supports the Phase 1 mapping table in Section 5).** The anchor research names exactly six zones: Peninsular, Mexican, Andean, Rioplatense, Caribbean, and US Spanish. It explicitly places Cuba, Puerto Rico, Dominican Republic, and coastal Colombia/Venezuela under Caribbean; Argentina and Uruguay under Rioplatense; Castilian and Andalusian varieties under Peninsular. It does **not** explicitly enumerate countries under Andean, and it does **not** define a distinct "Central American" zone; it states only that US Spanish varieties are influenced by Mexican, Caribbean, and Central American input. This is used below to check the dialect-country mapping table for internal consistency and to avoid asserting a zone the anchor research does not name on the anchor's own authority.
- **Seventh zone: Central American (El Salvador and Honduras), an evidence-backed extension of the anchor's six-zone scheme.** Supporting evidence closes the gap the anchor left open for El Salvador and Honduras. "Central American Spanish" is an independently recognized dialect area in mainstream dialectology (Rona 1964; Zamora Munne & Guitart 1988; reviewed in Moreno Fernandez & Ueda 2018, *Open Linguistics* 4:722-742). Core members of the zone include Guatemala, El Salvador, Honduras, Nicaragua, and Costa Rica (Guatemala and Nicaragua are available if the curriculum later expands beyond the current ten locations). Defining teachable features documented for El Salvador and Honduras: (1) voseo with monophthongized, final-syllable-stressed verb forms (*vos hablás, tenés, comés, vivís*; imperatives *hablá, comé*); (2) a three-way tu/vos/usted politeness system with usted strong in formal and business register, directly relevant to this plan's business-communication track; (3) lowland/radical phonology, specifically syllable- and word-final /s/ aspiration or elision, word-final /n/ velarization, and /x/ weakening to [h]. Salvadoran and Honduran voseo are documented as essentially identical in form, supporting one shared zone for both countries. Additional sources: the "El tu como un mask: Voseo and Salvadoran and Honduran Identity" study (Rivera-Mills) and the *Cambridge Handbook of Spanish Linguistics*, chapter 23 (geographic varieties).
  - **Why the nearest existing zones were rejected, not silently reused.** Not Caribbean: Caribbean shares s-aspiration and n-velarization with Central American Spanish but is tuteante (built on tu), so mapping El Salvador/Honduras there would erase voseo, the highest-frequency teachable contrast for these two locations. Not Rioplatense: Rioplatense shares voseo but differs in phonology and lacks tu in its pronoun system, unlike the three-way tu/vos/usted system documented for El Salvador and Honduras. Not Mexican: Mexican Spanish is tuteante with conservative coda /s/, mismatching both the voseo and the lowland-phonology features.
  - **Framing.** This seventh zone extends, and does not contradict, the anchor research's six-zone scheme: the anchor is silent on where El Salvador and Honduras belong (it names Central American input only as an influence on US Spanish, never as its own mapped zone), so adding a seventh zone on independent, cited dialectology grounds fills a genuine gap rather than overriding a position the anchor actually took.
- **Governing constraint.** `CLAUDE.md`'s Browser UI invariant applies in full: the application is browser-rendered, and native dialogs (`alert`, `confirm`, `prompt`, their `window.*` forms, and `beforeunload` prompts) are prohibited everywhere. See Section 8 (Browser UI dialog policy) and Section 7's acceptance checks.
- **Research evidence used for this plan** (grounding only, not scope authority; volatile items dated as-of 2026-07-16):
  1. *Accessibility.* Target WCAG 2.2 AA. Dyslexia-font efficacy is contested in the evidence; the plan does not mandate a single dyslexia font. Instead it specifies a user-adjustable typography system (Section 6) offering Atkinson Hyperlegible, Lexend, and OpenDyslexic as user-selectable options alongside the default sans, plus user controls for text size, line-height, letter/word spacing, and reading measure. Contrast targets: 4.5:1 body text, 3:1 large text and non-text elements. Color independence is required everywhere (icon plus text, never color alone). Relevant WCAG 2.2 success criteria, with corrected level attribution per the independent design review: 2.4.11 Focus Not Obscured (AA) and 3.3.8 Accessible Authentication (AA) are required at AA; 3.3.7 Redundant Entry is Level A; 2.4.13 Focus Appearance (AAA) is voluntarily exceeded by the fixed focus-ring token.
  2. *Drip UX.* An enrollment-relative unlock model (`unlock_date = enrollment_date + unlock_offset_days`, computed per student and per unit) mirrors the established "drip N days after enrollment" pattern used by platforms such as Kajabi, Thinkific, and Teachable. Units render in three states: completed/available (linked), current, and locked (dimmed, lock icon, accessible name, and an inline "Unlocks in X days / on <date>" message). Past units remain permanently accessible; future units are visible but locked; the next unlock is communicated inline, never via a native dialog.
  3. *Backend recommendation.* Netlify + Supabase, recommended over Netlify + Neon. Supabase bundles the three Phase-1 needs as integrated, RLS-governed, locally reproducible services: built-in Auth (email/password now, social later), native Postgres row-level security for per-row enrollment-date gating, and Supabase Storage with time-limited signed URLs for gated PDF/PPTX/(later) video delivery. The Supabase CLI runs a full local stack (Postgres, Auth, Storage, Edge Functions), which fits the Phase-1 local-only build and promotes cleanly to a hosted deployment. Neon is Postgres-only: it has no built-in auth and no object storage, so choosing it would require a separate auth layer and a custom authorization/streaming Function for every gated download (Netlify Blobs has no signed or public URLs, so every read would need to be proxied through an authorization Function), which is materially more integration and security surface for a single-instructor operation. Neon would be preferable only if a specific auth stack were mandated, or if database-branch-per-preview were a hard requirement. Free-tier and pricing details are volatile and should be re-verified at build time; note that Supabase free projects auto-pause after seven days of inactivity, which is not suitable for 24/7 production but does not affect the Phase-1 local build.
  4. *Accessible PPTX/PDF pipeline.* Exported PowerPoint-to-PDF files are not automatically PDF/UA conformant. The evidence-backed pipeline is: author with structure, run the PowerPoint Accessibility Checker, fix flagged issues, export as PDF with "Document structure tags for accessibility" enabled (never Print-to-PDF), validate in Acrobat Pro and PAC, remediate tags and tables, and add the PDF/UA identifier. Manual, human-verified steps that cannot be skipped: reading order, alt text on vocabulary-example images, unique slide titles, and table header scope. `python-pptx` can generate a `.pptx` from structured lesson content but has limited accessibility-feature coverage and no tagged-PDF output, so full accessibility is an author-and-validate step, not a pure code export. For born-accessible handout PDFs, an HTML-to-tagged-PDF or authored-Word-to-tagged-PDF path is preferred over naive library export.
  5. *Deferred and adjacent items, not to be silently started:* a delivery/transcoding and captioning approach for future video recordings; a payment/enrollment provider (for example, Stripe); interpreting-practice audio playback/recording infrastructure for the now-committed Phase 7 (Section 2.3), which remains deferred until the Section 2.3 design increment passes, regardless of D4 now being confirmed.
  6. *Central American dialect zone (El Salvador and Honduras).* See the dedicated evidence bullet above (Section 3): Rona (1964); Zamora Munne & Guitart (1988); Moreno Fernandez & Ueda (2018, *Open Linguistics* 4:722-742); Rivera-Mills' "El tu como un mask" study; and the *Cambridge Handbook of Spanish Linguistics*, chapter 23.

---

## 4. Design handoff summary and browser-validation brief

### 4.1 Design route and review status

`design_route`: **studio** (greenfield, brand-critical, accessibility-critical, high-value). The Design Director ran the studio process with ux-architect, visual-system-designer, and a bounded asset-art-director; motion-designer was not warranted for this build. `design_handoff`: **PASSED**, independently reviewed. `design_review`: **PASS**, with three low-severity, non-blocking findings folded into this plan as follow-ups (Section 4.4).

Selected direction: **refined ("The Field Workbook")** with the user's golden-hour finca-tequilera elaboration. Editorial print-craft aesthetic; warm golden-hour, brass, and aged-paper materiality is confined to chrome, covers, dividers, badges, and empty states only, and is never permitted behind reading or form content. The direction is elegant and classic, with an explicit anti-kitsch prohibition list carried by the design fleet's own artifacts (not restated here in full; engineering must consult the design system for the prohibition list before building chrome/cover/divider assets).

This design pass covers the core bilingual application only. It does not cover any UI for the now-committed translator/interpreter or heritage-learner tracks (Section 2.3); a scoped design increment is a committed prerequisite before those tracks' UI can build; see Section 4.4, follow-up 10.

### 4.2 Design system essentials binding on engineering

- **Typography.** Fraunces for display/headings (fixed, not user-toggleable) with Source Sans 3 as the default body font. Users may toggle body font to Atkinson Hyperlegible, Lexend, or OpenDyslexic. A `rem`-based scale carries a user size multiplier that compounds with browser/OS zoom. OpenDyslexic carries a line-height floor bump. Numerals are tabular lining with plain-text equivalents provided in accessible names. Reading measure is 60-80ch for body content, with an approximately 45ch floor at 320px viewport width so that reflow wins over a fixed measure. Hyphenation and `overflow-wrap` are required so long Spanish words never force horizontal scroll.
- **Color.** A three-tier token system (primitive/semantic/component) aligned to the DTCG format (the 2025.10 DTCG format is a stable Community Group report, not a W3C Recommendation; this distinction should be stated accurately in any engineering documentation). The default palette is a placeholder golden-hour scheme (paper/ink/amber/terracotta neutrals plus hue-separated state colors including one cool info hue). `amber.400` fails the 3:1 non-text contrast floor and is fenced to decorative/large-fill use only. `color.surface.reading` is a distinct semantic token group that must never be aliased to chrome or gradient tokens; this is a token-level guarantee that decorative material cannot land behind body content. The focus-ring token is fixed (2px ring, 2px offset, ≥3:1 contrast on every surface) and is not owner-themeable.
- **Runtime brand theming.** The owner supplies name, logo, colors, and legal/IP text at runtime; none of these are hardcoded. Any owner-supplied color used in a text, icon, or non-text-UI role passes a documented WCAG-ratio clamp (an HSL lightness-ramp derivation guaranteeing `brand.ink` ≥4.5:1 and non-text roles ≥3:1, falling back to the nearest compliant neutral). **Preview timing:** the preview updates live as the owner types, showing the clamped result and the "Brand color adjusted for readability" note in real time whenever clamping alters the input; clamping is never silent. The Save action commits the already-previewed clamped tokens; save-time remains the authoritative persistence point and the point at which a CI contrast re-check runs on the committed tokens. Raw, unclamped hex values are permitted only for non-contrast-bearing decorative fills.
- **Components and states.** A three-state unit card (completed / current / locked); locked units open an inline `aria-expanded` disclosure, never a modal. A dialect/register/taboo/inclusive-language badge taxonomy uses one fixed glyph per category plus explicit text, identical on screen and in exported PDF/PPTX, with a once-per-document printed legend covering: dialect (map-pin glyph plus zone text across all ten places named in Section 5's Phase 1 dialect mapping table: Mexico, Colombia, Argentina, Peru, Dominican Republic, El Salvador, Honduras, Ecuador, Puerto Rico, and Spain), register ("usted," formal / "tú," informal / "voseo," regional informal), old/modern (two distinct glyphs), taboo (flag glyph plus the literal text "Sensitivity note:", never icon-only, never collapsed), and inclusive language ("amigos/amigues"). Chunk anatomy follows a fixed order: rule box, example, translation task, dialect note. A rhythm stepper shows "Phrases 30 / Q&A 10 / Practice 20" with an always-visible "Segment N of 3" text label; pacing is advisory and segment-jumping is permitted. Resource rows show inline per-row download status and retry. App-owned accessible modals (focus trap, Esc plus return focus, `aria-modal`, `aria-labelledby`, inert background) are reserved for destructive admin actions and route guards; non-destructive confirmations use inline `aria-live` banners. Every surface enumerates its full state set: loading, empty, current, locked, completed, hover, focus, active, selected, error, offline, and permission-denied.
- **Assets (bounded).** A 24×24 `currentColor` outline glyph sprite, decorative and `aria-hidden`, always paired with visible sibling text. Chrome/cover/divider ornaments are implemented via CSS custom properties with real-border fallbacks under forced-colors mode. Flat-duotone spot illustrations (an agave-row horizon abstraction, a compass/pocket-watch, an open book) are used only in empty/orientation states, never behind text. A neutral bookplate logo placeholder component (`<LogoSlotPlaceholder>`) accepts an owner-uploaded logo with `object-fit: contain` inside an isolation chip and no automatic recoloring. Absolute rule carried into every engineering phase: no glyph, illustration, or ornament is ever the sole carrier of meaning or state; text is always the accessible source of truth.
- **Reading/accessibility system placement.** This system is global and persistent, reachable from every authenticated screen including the lesson viewer and the admin preview, and applies identically everywhere it appears.

### 4.3 Design review verification

The independent design reviewer recomputed key contrast ratios and confirmed them; the zero-native-dialog policy, user-adjustable typography, and clamped runtime theming were all verified as part of the design review pass. UI build phases (Section 5, Phase 3) undergo an additional independent review checkpoint before completion, separate from this design review and in addition to the Verifier and Browser Validator gates (Section 7).

### 4.4 Design-carried follow-ups (tracked here for downstream phases)

1. Correct WCAG level attribution in all engineering-facing documentation (already applied correctly in Section 3, item 1, and Section 4.2 above: 2.4.11 and 3.3.8 are AA; 3.3.7 is A; 2.4.13 is voluntarily exceeded at AAA).
2. Publish `terracotta.100`/`terracotta.600` hex values and confirm hue-distinctness against `warning.600` and `amber.600` before the token set is frozen (Phase 0). Open.
3. ~~Resolve whether the brand-color preview updates live or only on explicit invocation.~~ **Resolved** (Section 4.2): live-as-typed preview, save-time authoritative persistence and CI re-check.
4. Define the forced-colors-mode token fallback mapping (Phase 0). Open.
5. Decide whether a locked direct URL returns a distinct HTTP status or a soft in-app route with an inline "Not available yet" message (Phase 3b). Open.
6. Decide the tab-close mitigation: an in-app route-guard modal plus autosave/draft, given that true beforeunload-based protection is prohibited by the Browser UI invariant (Phase 3e). Open.
7. Decide confirm-password versus a reveal-toggle at signup (Phase 3a). Open.
8. Confirm dark-mode scope for Phase 1 (in scope, deferred, or out of scope) (Phase 0). Open.
9. Decide whether a per-dialect-zone decorative tint is used anywhere in badges or chrome (Phase 1/2 content and Phase 0 tokens). Open.
10. **(Committed prerequisite, tied to now-confirmed decision D4.)** A scoped design increment is required for interpreting-practice audio playback, record/upload/playback surfaces, and CAT-tool-orientation views before any Phase 7 or Phase 8 UI sub-phase builds (Section 2.3). D4 being confirmed does not remove this prerequisite; it remains open and blocking for those two phases' UI work.

### 4.5 Browser-validation brief (binding on every Phase 3 sub-phase)

- **Launch/readiness and base URL.** Engineering supplies the dev-server launch/readiness command and documented base URL for the Phase-1 local build at `H:\CommandCenter\orchestrator\lizbeth_spanish` (for example, a Vite dev-server command and a base URL such as `http://localhost:5173`; the exact command is an engineering decision at Phase 0, not asserted here).
- **Fixture/reset.** Seed a placeholder-branded course with a controllable mock enrollment date that exercises week-gating: at least one completed unit, one current unit, at least two locked units (one unlocking in N days), one lesson exhibiting all four chunk types and all badge types, resources covering PDF/PPTX/flashcards, a weekly vocabulary review, a student account, an owner account, and a clean unsaved-branding state. Include at least one resource-access fixture where the acting student is not yet entitled to a specific PPTX (for example, a locked-week resource), to support the negative gating journey below. All seeded content must be clearly placeholder-labeled.
- **Viewport profiles.** Mobile 360×800, tablet 768×1024, desktop 1440×900, plus desktop at 200% zoom and a 320px reflow check.
- **Journeys (each requires screenshot evidence at the stated milestone, not just a completion claim):**
  1. Student login shows three visibly distinct roadmap states, each communicated by icon plus text, never by color alone.
  2. Attempting a locked future week opens an inline, non-modal disclosure by both mouse and keyboard; Esc returns focus; no dialog appears; visiting the locked unit's direct URL renders an inline "Not available yet" state with no content leak.
  3. Revisiting a prior unlocked week succeeds and remains permanently accessible.
  4. The lesson rhythm stepper shows visible segments, supports keyboard segment-jumping, displays all four chunk types and all badge types (the taboo badge shows the literal "Sensitivity note:" text, never collapsed), and marking a lesson complete produces an inline `aria-live` confirmation, never a modal.
  5. Viewing/downloading a lesson's PDF, PPTX, and flashcards: an entitled student downloads each of the three with inline per-row status and a failure-retry path, no dialog. Separately, and specifically for the PPTX resource (not only PDF/flashcards), an unauthorized or not-yet-entitled user who attempts the PPTX resource path directly (for example, a stale or unentitled signed URL, or a locked-week resource from the fixture above) is blocked with no content leak; both the positive (entitled download) and negative (unentitled block) PPTX checks require their own screenshot evidence.
  6. Submitting feedback: an empty submission shows inline validation with focus moved to the first error; a valid submission shows a busy state then an inline `aria-live` success message; no dialog appears at any point.
  7. The owner edits branding and legal/IP text with a **live-as-typed** preview (Section 4.2): a near-white brand color shows the clamped result plus the "adjusted for readability" note as it is typed; saving shows an inline timestamped confirmation banner; replacing the logo (a destructive action) opens an app-owned, focus-trapped modal; navigating away with unsaved changes opens a route-guard modal (never a `beforeunload` prompt); a student who visits `/admin` sees an inline permission-denied state.
  8. Reading-settings controls, accessed from both the dashboard and inside a lesson, allow selecting OpenDyslexic, maximum text size, maximum spacing, and 60ch measure without clipping or horizontal scroll; the setting persists across screens including the admin preview, and a polite "Reading style updated" message confirms the change.
  9. A per-viewport accessibility sweep confirms the keyboard focus ring is visible and never obscured by sticky chrome, that 200% zoom produces no horizontal scroll of primary content, and that an offline state shows a persistent banner reading "Showing last saved progress," with downloads and the feedback submit control disabled and their disabled state explained inline.
- **Browser UI dialog policy for this brief:** required, with no exceptions. See Section 8 for the full policy and its one honestly-flagged limit.

---

## 5. Ordered work (phased; each phase below is a separate approval-scoped job once this plan is approved)

Every UI-producing phase requires an independent Verifier pass and a Browser Validator pass before any completion claim; a Verifier or Browser Validator finding blocks the phase's completion, it does not get waived by the writer. Phases 0 through 8 are this plan's committed scope, per the user's confirmation of decision D4 (Section 11.2). Phase 7 and Phase 8 still cannot start their UI sub-phases until the Section 2.3 design increment passes and until sequencing after the relevant band's core content is satisfied; those are real dependencies, not a remaining confirmation gate.

| Phase | Deliverable | Owner | Depends on | Acceptance summary |
|---|---|---|---|---|
| 0 | Project scaffolding and design-system foundation: create `lizbeth_spanish/`; choose the front-end stack (for example, Vite + React/TypeScript) and set up the Supabase local CLI stack; implement the DTCG three-tier token system, the user-adjustable reading/accessibility system, the fixed focus-ring token, and the app-owned modal primitive. | engineering-fleet (T1) | Plan approval | Token system and reading controls demonstrably work in Chrome; a deterministic no-native-dialog scan is clean; accessibility primitives are Chrome-verified. |
| 1 | Curriculum architecture document, grounded in the anchor research: CEFR-band/track reconciliation (per settled decision D2: Beginner/Intermediate/Advanced bands with the dual parallel-entry-plus-sequential-progression model); five-pillar mapping; a dialect-zone mapping table listing all ten places consistently (Mexico, Colombia, Argentina, Peru, Dominican Republic, El Salvador, Honduras, Ecuador, Puerto Rico, and Spain), mapped across seven zones: the anchor research's six (Peninsular, Mexican, Andean, Rioplatense, Caribbean, US Spanish) plus the evidence-backed seventh "Central American" zone (Section 3), with Colombia flagged as split between Caribbean (coastal) and Andean (interior) per the anchor's own text, and El Salvador and Honduras mapped to Central American (voseo, three-way tu/vos/usted, lowland phonology; Section 3), an extension of the anchor's scheme on independent dialectology grounds rather than an assignment the anchor itself makes; old/modern, formal/informal (tú/usted/voseo), and gender-neutral/inclusive-language layers; a business-communication (in-person/phone/email) framework; the reusable lesson-template specification (60-minute, 30/10/20 rhythm). | Scribe | Plan approval | Explicit grounding in the anchor five-pillar model and dialect matrix is shown; the country-to-zone mapping table is present and internally consistent, with all ten places mapped to one of seven zones and no location left unmapped; the Central American extension cites its supporting dialectology sources rather than asserting a fabricated zone. |
| 2 | One fully worked example lesson package: vocabulary list, phrase set, Q&A set, a 20-minute communicative practice activity, flashcards, a weekly vocabulary review recap, an instructor PPTX, and a student PDF, demonstrating every required element as the scaling template. The PPTX and PDF must be actual generated, accessibility-validated artifacts, not only outlines (see the Acceptance summary column). | Scribe (content authoring), with engineering support for the author-and-validate tooling in Section 6 | Phase 1 | Every required element is present; dialect/register/taboo/inclusive badges are applied per the design taxonomy in Section 4.2; the PPTX passes the PowerPoint Accessibility Checker; the PDF is tagged (PDF/UA-oriented), validated in Acrobat Pro and PAC, with correct reading order, alt text on vocabulary-example images, unique slide titles, and table header scope. Authoring outlines remain an intermediate step, not the accepted artifact. |
| 3 | Phase-1 local web app build, decomposed into five Chrome-validated sub-phases (3a data model and Supabase-local; 3b roadmap/dashboard; 3c lesson viewer and resources; 3d feedback form; 3e owner/admin branding and legal config), each with its own acceptance, risks, dependencies, and rollback boundary detailed in **Section 5.1**. | engineering-fleet | Phase 0; internal sub-phase dependencies per Section 5.1 | See Section 5.1 for per-sub-phase acceptance. |
| 4 | Image-generation manifest document: a standalone document listing every planned image asset (vocabulary-example images from the Phase-2 worked lesson plus any UI/brand/spot-illustration assets identified by the design fleet: agave-row horizon, compass/pocket-watch, open book, logo placeholder, badge glyphs as applicable), each with a complete, externally runnable image-generation prompt. | Scribe | Phase 2 (for lesson-image needs) and Section 4.2 (for design-fleet assets) | Every planned asset has a complete external prompt; no in-project image generation is performed. |
| 5 | Legal/IP and configuration content: owner-editable IP/copyright notice boilerplate (enrolled-students-only use, no reproduction for another course), clearly labeled as non-legal-advice pending counsel review; wired as an owner-configurable setting appearing on protected content, never hardcoded. | Scribe (content) and engineering-fleet (wiring) | Phase 3e (for the settings surface to wire into) | The notice appears on protected content and is owner-editable via configuration. |
| 6 | Full-scale, up-front curriculum content authoring (decision D5 answered): the complete approximately 26 weekly lessons for every committed band (Beginner, Intermediate, Advanced), scaled from the validated Phase-2 template. This is authored up front, not phased or partial. Recommendation (user may adjust): an internal execution sequence of author-one-band-then-review/validate-then-next-band, so per-band validation catches template/quality issues before they replicate across all lessons; the committed total remains full scale regardless of internal sequencing. | Scribe | Phase 2 (validated template) | Each of the ~78 core weekly lessons (~3 bands x ~26 weeks) delivers the full Phase-2 element set (vocabulary, phrases, Q&A, practice, flashcards, weekly review, plus generated and accessibility-validated PPTX and PDF); dialect/register/taboo/inclusive coverage per Section 1's framework; grounded in the anchor five-pillar model; accepted band-by-band as each band completes its author-then-validate pass, not as one all-or-nothing milestone. |
| 7 (COMMITTED, decision D4 confirmed) | Professional translator/interpreter-certification track: content (CAT-tool orientation, domain specialization, consecutive/simultaneous/sight-interpreting practice) beginning at CEFR B2, layered on the bilingual track, authored full-scale per decision D5; plus the design increment and engineering for its net-new UI (interpreting-practice audio playback, record/upload/playback surfaces, CAT-tool-orientation views). Rough planning estimate, to be refined during Phase 1 curriculum architecture: the track layers from CEFR B2 upward as roughly a 6-month track, on the order of ~26 weekly lesson packages. | Scribe (content) and engineering-fleet (UI, after a design increment) | The design increment in Section 2.3 passing before UI build; sequencing after Phase 6 for the relevant band(s) | Content demonstrates the anchor research's two-interlocking-tracks model at B2+, authored full-scale per D5; track-specific UI passes its own Verifier and Browser Validator pass once designed; no UI sub-phase of this track is built before the Section 2.3 design increment passes. |
| 8 (COMMITTED, decision D4 confirmed) | Heritage-learner academic track: content (academic literacy, register/genre expansion, identity-aware pedagogy) as its own path, authored full-scale per decision D5. Rough planning estimate, to be refined during Phase 1 curriculum architecture: a dedicated roughly 6-month track, on the order of ~26 weekly lesson packages. | Scribe (content) and engineering-fleet (any track-specific UI) | Sequencing after Phase 6 for the relevant band(s); the Section 2.3 design increment before any track-specific UI build | Content demonstrates the anchor research's heritage-learner framework, authored full-scale per D5; any track-specific UI passes Verifier and Browser Validator before it is treated as complete. |

### 5.1 Phase 3 sub-phase detail

**3a. Data model and Supabase-local setup.**
- Acceptance: Auth (email/password) works locally; Postgres row-level security enforces per-student row visibility by enrollment date, verified with at least two student fixtures on different enrollment dates; Storage signed URLs expire and are rejected after expiry, verified for every resource type including PPTX; schema matches Section 6's indicative entities.
- Risks: an RLS policy gap could leak future-week content directly via API rather than only through the UI. Mitigation: test gating at the policy/API level for every gated table, not only at the UI level.
- Dependencies: Phase 0 (local Supabase CLI stack running).
- Rollback boundary: local-only state; drop and recreate the local Supabase project. No hosted state exists to roll back.

**3b. Roadmap/dashboard.**
- Acceptance: three-state rendering (completed/current/locked) verified per Section 4.5 journeys 1 through 3; locked-URL no-leak verified for direct navigation.
- Risks: color-only state signaling (mitigation: an icon-plus-text audit of every state); a locked-URL leak enforced only client-side (mitigation: the block must be enforced server-side/by RLS, not only by a client route guard).
- Dependencies: 3a.
- Rollback boundary: revert this sub-phase's commits; 3a's data/auth layer is unaffected.

**3c. Lesson viewer and resources panel.**
- Acceptance: the four-chunk anatomy, badge taxonomy, rhythm stepper, and gated PDF/PPTX/flashcards delivery verified per Section 4.5 journeys 4 and 5, including the strengthened PPTX gating check described in Section 4.5, journey 5.
- Risks: badge icon-only signaling (mitigation: a text-pairing audit); a resource's signed URL usable after the student's access should have expired (mitigation: an expiry test for every resource type, including PPTX specifically, not only PDF).
- Dependencies: 3a; Phase 2 content for fixture data.
- Rollback boundary: revert this sub-phase's commits independently of 3a and 3b.

**3d. Feedback/topic-suggestion form.**
- Acceptance: inline validation and `aria-live` success/error states per Section 4.5 journey 6; no native dialog at any step.
- Risks: low; an isolated form surface. Mitigation: a standard form-accessibility review.
- Dependencies: 3a (authenticated session).
- Rollback boundary: revert this sub-phase's commits; no cross-sub-phase state.

**3e. Owner/admin branding and legal/IP configuration.**
- Acceptance: live-as-typed clamp preview (Section 4.2), save-time persistence with a CI contrast re-check, a destructive-action modal for logo replacement, a route-guard modal for unsaved navigation, and a permission-denied state for non-owner access, per Section 4.5 journey 7.
- Risks: an inaccessible owner-chosen color persisting despite the client-side clamp (mitigation: re-validate the clamp server-side, not only client-side); an admin-route access leak to non-owner accounts (mitigation: enforce via RLS/role check, not only by hiding the UI).
- Dependencies: 3a (auth/roles); the settings surface Phase 5's legal content is wired into.
- Rollback boundary: revert this sub-phase's commits; prior branding/legal-content state, if any, is restorable from the same local Supabase instance's history.

**Content-scaling note.** After the Phase-2 template is validated, authoring the full curriculum content for each CEFR-band track, plus the committed translator/interpreting and heritage tracks (Phase 7, Phase 8), is a subsequent, large Scribe-led effort. Decision D5 (Section 11.2) commits to full-scale, up-front authoring across all committed bands and both added tracks:

- Core bands (Beginner, Intermediate, Advanced): approximately 78 weekly lesson packages (roughly 3 bands x 26 weeks).
- Translator/interpreter-certification track (Phase 7): a rough planning estimate of approximately 26 weekly lesson packages (roughly a 6-month track layered from CEFR B2 upward).
- Heritage-learner academic track (Phase 8): a rough planning estimate of approximately 26 weekly lesson packages (roughly a 6-month dedicated track).

**Grand total: on the order of approximately 130 weekly lesson packages** (~78 core + ~26 + ~26), each carrying the full element set (vocabulary, phrases, Q&A, practice, flashcards, weekly review) plus a generated, accessibility-validated instructor PPTX and student PDF. Every figure above is a rough planning estimate to be refined during Phase 1 curriculum architecture, not a precise figure.

This scale carries a labeled recommendation, not a silent choice: an internal author-one-band-then-validate execution sequence (and author-then-validate per added track), applied across the full committed total, so that per-band and per-track validation catches template or quality issues before they replicate across all lessons.

**Timeline note.** Authoring approximately 130 full lesson packages, each with two generated and accessibility-validated documents, is a substantial multi-month content effort. This plan does not assert a specific month count as fact; the calendar duration depends on the authoring capacity agreed with the user, which is flagged here as the key assumption behind any future schedule estimate.

---

## 6. Interfaces and data model

- **Backend.** Supabase (Postgres, Auth, Storage). Core entities (indicative, not a final schema):
  - `course` / `track` (CEFR band)
  - `unit` / `week` (`unlock_offset_days`)
  - `lesson` (segments 30/10/20; chunk content; dialect/register/taboo/inclusive metadata)
  - `resource` (PDF/PPTX/flashcards/weekly-review; a storage object plus signed-URL delivery)
  - `student_enrollment` (`enrollment_date`, track)
  - `feedback_submission`
  - `owner_settings` (branding tokens, logo object, legal/IP text)
  - **Access rule:** `unlock_date = enrollment_date + unlock_offset_days`. Row-level security enforces per-student row visibility by enrollment date. Gated resources are delivered exclusively via time-limited signed URLs; un-enrolled or expired access is blocked at the storage layer, not only in the UI.
  - **Settled decision D2 (Section 11.2).** The user has confirmed the dual model: parallel entry (a new student enrolls directly into whichever CEFR-band track, Beginner/Intermediate/Advanced, matches their assessed level) plus sequential progression (a student who completes one band's track continues into the next band's track, with account and progress continuity). `student_enrollment` is a one-to-many relationship from a single student account to potentially multiple track enrollments over time, each with its own `enrollment_date` and its own per-track unlock schedule, with completed-progress history persisting across a band transition. Phase 3a's acceptance test must exercise this continuity explicitly (Section 5.1).
- **Front end.** DTCG three-tier design tokens; runtime brand-token injection with the save-time WCAG clamp described in Section 4.2; global, persistent reading/accessibility settings; the app-owned modal plus inline `aria-live` status pattern; no native dialogs anywhere.
- **Local-to-hosted compatibility.** The Phase-1 local build (using mock/local auth via the Supabase CLI) must promote cleanly to a hosted Netlify + Supabase deployment without reworking the gating, auth, or storage contracts. This compatibility requirement is a design constraint on Phase 3's implementation, not a claim that hosting work is in scope for this plan (see Section 2.2).
- **Document pipeline.** Structured lesson content flows into an author-and-validate pipeline: programmatic layout assistance is permitted, followed by PowerPoint/handout authoring, the PowerPoint Accessibility Checker, a tagged export, and Acrobat/PAC validation, per the evidence in Section 3, item 4, and the strengthened Phase 2 acceptance criteria in Section 5.

---

## 7. Acceptance and validation

- The curriculum document (Phase 1) is grounded in the anchor five-pillar model and dialect matrix, includes the country-to-zone mapping table with all ten places listed consistently and mapped across seven zones (the anchor's six plus the cited Central American extension for El Salvador and Honduras, Section 3), with no location left unmapped, and explicitly treats old/modern, formal/informal, and inclusive-language layers.
- The worked lesson (Phase 2) demonstrates every required element as the reusable template, and its PPTX and PDF are actual generated artifacts that pass the PowerPoint Accessibility Checker and Acrobat/PAC tagged-PDF validation respectively, not only outlines.
- The image manifest (Phase 4) is standalone and gives a complete external prompt for every planned asset, including design-fleet-identified assets.
- The local app (Phase 3) is visually verified in Chrome at each milestone: enrollment-relative weekly unlock with permanent prior-week access; the lesson viewer; gated access to PDF/PPTX/flashcards, including the PPTX-specific positive and negative gating checks; the feedback form; and owner branding/legal configuration.
- UI build phases undergo an additional independent review checkpoint before completion, in addition to the Verifier and Browser Validator gates.
- A deterministic no-native-dialog scan passes with zero product-code hits for `alert(`, `confirm(`, `prompt(`, `window.*` dialog forms, and `beforeunload`, **and** zero native dialogs are observed during any validation journey. Any native dialog observed during a journey is an automatic fail; every confirmation must use an app-owned accessible modal or inline validation instead.
- An accessibility review confirms WCAG 2.2 AA conformance plus the explicit low-vision and dyslexia accommodations in Section 4.2, with the design fleet holding final authority over specific implementation choices within that standard.
- The IP/legal notice (Phase 5) appears on protected content and is owner-editable via configuration, never hardcoded.
- Full-scale, up-front content authoring across all committed bands (Phase 6, decision D5 answered) is accepted band-by-band against the same Phase-2 element-set and framework checks, following the recommended internal author-then-validate sequence, not as a single all-or-nothing milestone.
- Phases 7 and 8 (committed, decision D4 confirmed) are accepted per Section 5's phase table: content against the anchor's two-interlocking-tracks and heritage-learner frameworks respectively, authored full-scale per D5, and any track-specific UI only after the Section 2.3 design increment passes and its own Verifier/Browser Validator pass succeeds.

---

## 8. Browser UI dialog policy (required, binding on Phase 3 and all later UI work)

No native `alert`, `confirm`, `prompt`, or `beforeunload` prompt is permitted anywhere in the application. Every confirmation or acknowledgement (a submitted feedback form, saved branding, a week-locked notice, a destructive admin change, or unsaved in-app navigation) must use an app-owned accessible modal or inline validation, per Section 4.2's component rules. Any interpreting-practice playback/recording controls added in the now-committed Phase 7 are bound by this same policy: no native dialog, app-owned modals for destructive actions only.

**Honestly flagged limit:** true browser tab-close protection is not achievable without a native `beforeunload` prompt, which this policy prohibits. The mitigation is an in-app route-guard modal for in-app navigation, combined with an autosave/draft mechanism (an engineering decision at Phase 3), not a native browser prompt. This limit should be stated to the user again at approval, not treated as solved.

---

## 9. Risks and rollback

| Risk | Impact | Mitigation |
|---|---|---|
| Overall scope size: a 6-month, multi-band curriculum plus an accessible app is large. | High | Phase the work template-first, then scale (Section 5); gate each phase on independent acceptance criteria; because the project is greenfield, rollback means reverting the phase's commits. |
| Runtime brand theming could let an owner set an inaccessible color. | High | The save-time WCAG clamp (Section 4.2) plus the fixed, non-owner-themeable focus-ring token; add a CI contrast re-check on any token or brand change. |
| Accessibility regressions across the adjustable-typography by zoom by spacing matrix. | Medium-high | Relative/min-height/flex layout so adjustments are additive rather than conflicting; automated axe/Lighthouse checks plus manual screen-reader testing (NVDA/VoiceOver) and a Browser Validator pass per UI phase. |
| Native-dialog leakage. | High | The mandatory deterministic scan plus the observed-journey gate in Section 7; any native dialog observed is an automatic fail. |
| Accessible-document fidelity for PPTX/PDF outputs. | Medium | The author-and-validate pipeline in Section 3, item 4 and Section 6 (PowerPoint Accessibility Checker plus Acrobat/PAC), not a naive library export; Phase 2's strengthened acceptance criteria (Section 5) require the validated artifact, not only an outline. |
| Volatile vendor facts (Supabase/Netlify pricing and features; Supabase's 7-day auto-pause). | Low-medium | Re-verify at build time; the Phase-1 local-first approach insulates near-term work from these changes. |
| Local-to-hosted promotion drift. | Medium | Keep the auth, gating, and storage contracts identical between the Supabase-local stack and any future hosted deployment (Section 6). |
| Full-scale, up-front content-authoring across all committed bands and both added tracks (Phase 6, Phase 7, Phase 8), on the order of approximately 130 weekly lesson packages in total (~78 core plus ~26 for each added track; Section 5.1), is very large. | High | This High rating reflects the full approximately 130-package grand total across all three committed bands and both added tracks, not only the ~78 core packages. Decision D5 fixes the committed total at full scale and recommends (does not silently assume) an internal author-one-band-then-validate execution sequence, applied per band and per added track across that whole total, so template/quality issues surface before they replicate; each authored band or track is still gated by its own acceptance check rather than one all-or-nothing milestone, but the total authoring volume itself remains a high risk. |
| The translator/interpreter and heritage tracks (decision D4, now committed) add scope, cost, and schedule beyond the core build, and their UI needs a design increment not yet run. | High | Sequence Phase 7 and Phase 8 strictly after the core bands and Phase 2 template are validated; require the Section 2.3 design increment to pass Design Reviewer before any Phase 7/8 UI sub-phase starts; content authoring for these tracks may proceed once Phase 2's template is validated, but their UI does not build before the design increment passes. |
| The confirmed D2 dual-enrollment model (parallel entry plus sequential progression with account continuity) adds data-model and gating complexity beyond a single-enrollment model. | Medium | Test progress continuity across a band transition explicitly in Phase 3a's acceptance (Section 5.1), since the schema must support it from the start. |

Sub-phase-specific risks for Phase 3 (3a through 3e) are detailed individually in Section 5.1 rather than aggregated in this table.

---

## 10. Dependencies

- Anchor research document (Section 3) must remain available and unchanged in substance for Phase 1, Phase 2, and Phase 6 authoring; a material change to it would make this plan stale for those phases.
- Supabase CLI and local stack availability for Phase 0 and Phase 3.
- The passed design handoff and design review (Section 4) are a binding input to Phase 0 (tokens, focus ring, modal primitive) and to every UI-producing sub-phase of Phase 3.
- Phase 2 (worked lesson) depends on Phase 1 (curriculum architecture) being complete, since the lesson is the template instantiation of that architecture.
- Phase 4 (image manifest) depends on Phase 2 for lesson-image needs and on the design fleet's asset list (Section 4.2) for UI/brand assets.
- Phase 5's content depends on nothing upstream in this plan besides approval; its wiring depends on Phase 3e's settings surface existing.
- Phase 6 depends on the validated Phase-2 template. Decision D5 answers scale and sequencing (full scale, up front, across all committed bands, with a recommended internal author-then-validate order).
- Phase 7 and Phase 8 (committed, decision D4 confirmed) depend on the Section 2.3 design increment passing before their UI sub-phases, and on Phase 6 sequencing for the relevant band(s). Neither phase is a dependency of any other phase in this plan; the core build (Phases 0 through 6) does not depend on Phase 7 or Phase 8's progress at all.

---

## 11. Assumptions and decisions

### 11.1 Safe assumptions (labeled as assumptions, not settled facts)

- Unit 1's `unlock_offset_days` is 0 (immediately available on enrollment).
- The 30/10/20 lesson rhythm is advisory pacing, not a hard gate; segment-jumping is always permitted.
- There is a single owner/admin tier; no multi-admin or role hierarchy is assumed.
- The weekly vocabulary review is a unit-level artifact, not a per-lesson artifact.
- Feedback submission requires only an authenticated session, no additional gating.
- Non-destructive saves confirm inline; app-owned modals are reserved for destructive actions and route guards (Section 4.2).
- PDF and PPTX exports can reproduce the badge icon-and-label legend described in Section 4.2.
- The five typefaces named in Section 4.2 (Fraunces, Source Sans 3, Atkinson Hyperlegible, Lexend, OpenDyslexic) are open-license and self-hostable; engineering must confirm the exact license terms at Phase 0 before shipping.

### 11.2 Confirmed decisions (no open user decisions remain)

Decisions D1 through D5 have each been confirmed directly by the user, including the Central American dialect-zone research folded into Section 3 and Section 5.

- **D1: Backend choice. Confirmed.** Netlify + Supabase is adopted as final (Section 3, item 3). Netlify + Neon was evaluated and is no longer presented as a live alternative.
- **D2: CEFR-band/track structure. Confirmed.** Band set: Beginner, Intermediate, Advanced. Dual model: parallel entry (direct enrollment into the assessed-appropriate band) plus sequential progression (continuing into the next band with account and progress continuity), detailed in Section 6.
- **D3: Recording/upload constraint. Confirmed.** External recording and upload (Zoom/Loom, gated storage and playback under the same access and IP rules, no in-app capture or conferencing) is a confirmed constraint, not an open assumption.
- **D4: Translator/interpreter-certification and heritage-learner tracks. Confirmed (committed scope).** Both tracks are included as additive tracks (Section 2.3; committed Phase 7 and Phase 8 in Section 5), sequenced after the core bilingual bands and the Phase 2 template are validated, with the honestly flagged design-increment prerequisite for interpreting/CAT-tool UI (Section 2.3; Section 4.4, item 10) still required before those tracks' UI sub-phases can build. This decision adds two full tracks' worth of content and engineering scope, added cost, and added schedule to this plan's committed total (Section 9).
- **D5: Full-content-authoring scale and sequencing. Answered: full scale.** The committed scope is complete, up-front authoring of every weekly lesson for every committed band (Beginner, Intermediate, Advanced, approximately 26 weeks each) and for both committed added tracks, not a phased or partial subset. **Recommendation (user may adjust):** within that full-scale total, an internal execution sequence of author-one-band-then-review/validate-then-next-band (and author-then-validate per added track) is recommended so that per-band validation catches template or quality issues before they replicate across all lessons. This sequencing is a recommendation only; the committed total remains full scale regardless of how the user adjusts the internal order. The grand total across all committed bands and both added tracks is on the order of approximately 130 weekly lesson packages, a rough planning estimate detailed in Section 5.1's content-scaling note.

No open user decisions remain: D1 through D5 are all settled and confirmed by the user.

The ten design-carried follow-ups in Section 4.4 are tracked separately from D1-D5; items 1 through 9 are non-blocking and do not require approval-gate confirmation, though they should be resolved during their named phase. Item 10 is a committed prerequisite for Phase 7 and Phase 8's UI sub-phases (no longer contingent on an unconfirmed D4, since D4 is now confirmed), and remains open and blocking for those two phases' UI work specifically.

---

## 12. Engineering mode

Standard: decompose Phase 3 into sub-phase `ENGINEERING_JOB`s after approval (Section 5, Section 5.1). This plan is large in total scope, now larger still with the committed full-scale authoring (D5) and the two committed additive tracks (D4), but still does not require an extreme-advisory team; no team authorization has been requested, and phasing plus per-phase Verifier/Browser Validator gates are judged sufficient to manage the complexity. Phase 6 is a Scribe-led content effort and does not change the engineering mode. The two committed tracks (Phase 7, Phase 8) route through this same standard engineering mode with their own design increment first; they do not on their own justify an extreme-advisory team. `team_authorization`: not applicable.

---

## 13. Downstream owners

Mixed ownership, by phase (Section 5):

- **engineering-fleet** owns Phase 0, Phase 3 (all sub-phases), and the configuration wiring portion of Phase 5.
- **Scribe** owns Phase 1 (curriculum architecture document), Phase 2 (worked lesson package), Phase 4 (image-generation manifest), the content portion of Phase 5 (legal/IP notice text), and Phase 6 (full-scale, up-front per-band content authoring, decision D5 answered).
- **Scribe and engineering-fleet jointly** own the committed Phase 7 (translator/interpreter-certification track) and Phase 8 (heritage-learner academic track); content authoring may proceed once the Phase-2 template is validated, but their UI does not begin until the Section 2.3 design increment passes.

All downstream work (engineering and content alike) begins only after the user gives explicit approval of this plan. Decisions D1 through D5 have been confirmed by the user directly (Section 11.2); no open user decisions remain, though plan approval itself is still required before any phase begins. An engineering writer or Scribe that finds a material repository, requirement, dependency, or evidence change invalidating a phase of this plan must report the phase stale rather than proceeding.
