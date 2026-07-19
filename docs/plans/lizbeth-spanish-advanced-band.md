# Plan: Lizbeth Spanish Advanced Band — Grounded Roadmap and Authoring Sequence

Status: **Draft — pending explicit user approval.** This plan operates under the already-approved
governing plan `docs/plans/lizbeth-spanish-course-platform.md` (approved by the user 2026-07-17),
specifically its Phase 6 (full-scale, up-front curriculum content authoring, decision D5 answered). It
adds no new scope beyond that governing plan's Phase 6, **provided the content-style template
interpretation in Section 5 below is accepted** as this band's authoring approach; if the instructor
instead selects the alternative (true PBLL-fidelity cumulative deliverables), that alternative is
explicitly out of this plan's scope and would require its own new or amended engineering plan before
any such tooling change proceeds.

task_id: lizbeth-spanish-course-platform
plan_id: lizbeth-spanish-advanced-band

No downstream Advanced-band batch authoring begins until the user explicitly approves this plan and
confirms the five remaining instructor decisions in Section 9.

---

## 1. Outcome and audience

This plan authorizes and sequences the Advanced-band (C1/C2, approximately 26-week) content-authoring
effort for the Lizbeth Spanish course platform, using the evidence-grounded roadmap
`lizbeth_spanish/curriculum/advanced-band-syllabus.md` (revised and superseding its first-pass draft,
commit ba2cbd9) and the new research briefing `docs/research/advanced-spanish-c1-c2-instructional-design.md`.

Audience: the instructor (course owner), for approval of this plan and confirmation of its remaining
open decisions; and the orchestrator, for downstream routing once approved (Scribe for content
authoring, engineering-fleet for materials generation and verification).

## 2. Scope and non-goals

**In scope for this plan:**

- The grounded Advanced-band roadmap itself (`advanced-band-syllabus.md`), already revised and written
  as a companion deliverable to this plan.
- The research briefing that grounds it (`docs/research/advanced-spanish-c1-c2-instructional-design.md`),
  already written as a companion deliverable to this plan.
- This plan-of-record: the approval gate, the batching/execution recommendation, and the explicit
  instructor decisions that must be confirmed before downstream authoring begins.

**Out of scope for this plan (explicitly excluded, not silently deferred):**

- Authoring any actual Advanced-band weekly lesson content (vocabulary lists, phrase sets, Q&A,
  practice activities, flashcards, weekly review recaps, or generated PPTX/PDF materials). That is
  downstream work this plan authorizes but does not itself perform.
- Any code or tooling change, including any change to `LessonContentParser`, the PPTX/PDF/TypeScript
  generators, the pytest suite, or the app's `import.meta.glob` week-discovery. If the instructor
  selects the cumulative-tracked-artifact template alternative (Section 5), that change is out of this
  plan's scope entirely and requires its own new or amended engineering plan.
- Phase 7 (professional translator/interpreter-certification track) and Phase 8 (heritage-learner
  track) content or design work. Both remain governed entirely by the governing plan's own Phase 7/8
  entries and sequencing; this plan does not touch them.
- Re-litigating any already-verified Beginner- or Intermediate-band content. This plan and its
  companion documents treat both prior bands' content as settled, checked baseline (see Section 3).

## 3. Repository findings and evidence references

- **The revised Advanced-band syllabus**, `lizbeth_spanish/curriculum/advanced-band-syllabus.md`,
  supersedes its first-pass draft (commit ba2cbd9) in place. It retains the draft's overall
  architecture (26 weeks; the six-file-per-week template; four domain arcs — Legal Weeks 1-6, Finance
  Weeks 7-11, Technology Weeks 14-18, Literature Weeks 19-23; old/modern concentration at Weeks 5, 19,
  20, 22; business-communication escalation; dialect rotation with its honest weighting flag) and
  applies the cited, evidence-grounded revisions summarized in Section 4 below.
- **The new research briefing**, `docs/research/advanced-spanish-c1-c2-instructional-design.md`,
  supplies the external evidence every revision in the syllabus cites.
- **The generation-pipeline coupling that makes a per-week template change build-affecting.** The
  Python tooling at `lizbeth_spanish/tools/lesson-generation/` is built around `LessonContentParser`
  expecting exactly six fixed input files per week, feeding the PPTX/PDF/TypeScript generators and a
  pytest suite; the app auto-discovers weeks via Vite's `import.meta.glob`. This means the six-file
  weekly package is a load-bearing contract, not an incidental convention: any change to what a "week"
  structurally contains (for example, a shared cumulative artifact spanning several weeks) would touch
  the parser's input contract, the generators, the tests, and week-discovery simultaneously. This
  finding directly grounds Section 5's decision framing below.
- **The Intermediate Week 26 seam.** `lizbeth_spanish/curriculum/lessons/intermediate-week-26/weekly-review-recap.md`
  states the exact, evidence-backed can-do baseline (grammar, vocabulary-domain breadth, dialect/badge
  exposure, business-communication competency, and B1+B2 translation/interpretation outcomes) a
  sequential-progression student carries into the Advanced band, and the equivalent baseline a
  parallel-entry student is assumed to hold. The revised syllabus's Section 1 already reconciles Week 1
  against this exact seam; this plan does not re-derive it, only references it as the checked baseline
  Advanced Week 1 authoring must respect.

## 4. Research grounding (summary)

`docs/research/advanced-spanish-c1-c2-instructional-design.md` is a deep, strategic-general research
briefing that investigated five sub-decisions: (a) official CEFR guidance and third-party contact-hour
benchmarks; (b) multi-week unit-continuity mechanics, the syllabus draft's single largest open item;
(c) competitor/comparable-model context (Instituto Cervantes, AVE Global, SIELE, DELE); (d) diachronic/
historical-register sourceability, including the readability-management tool LECOLE's actual validation
scope; and (e) core-band interpreting/translation depth, including a direct citation-scope check against
the anchor research's own footnotes. Its findings resolved the template-structure question (Section 5),
strengthened the interpreting-depth hedges at Weeks 12/24/25, added a CEFR Companion Volume grounding
note for the translation/mediation pillar, added a pacing directional caveat and a new contact-hour-scale
caveat, revised the old/modern mechanism's sourcing (confirming it while flagging LECOLE's contemporary-
only validation and recommending a stronger Week 19 text choice), and added competitor context on this
project's comparatively ambitious C2 commitment. Every revision made to the syllabus is cited to this
briefing; full detail, the complete source ledger, and stated confidence levels are in the briefing
itself, not restated here.

## 5. The resolved template-structure decision

The syllabus draft's single largest open item was whether "content-based and project-driven" design
requires a change to the existing per-week, six-file lesson template to support genuine multi-week
continuity. This plan carries forward the resolution the revised syllabus states in its own Section 6:

**Option A (recommended default, in scope for this plan): content style, zero tooling change.** Each
domain arc's weeks advance a single named, recurring scenario, client, case, product, or text. That
week's running "arc project state" is narrated directly within the existing `practice-activity.md` file
(the Communicative Practice segment already designated as this band's content-based/project-driven task
home) and consolidated at the arc's own consolidation/capstone week's existing `weekly-review-recap.md`.
This requires no new file type and no change to `LessonContentParser`, the generators, the test suite,
or week-discovery. This option is grounded in convergent external evidence (TBLT/CLIL's 6-8-week
modules; Instituto Cervantes' own AVE Global roughly-10-hour topic blocks; PBLL's own definitional
range), none of which requires a template-level continuity mechanic for a bounded multi-week thematic
block of the size this band's arcs already use.

**Option B (explicitly out of scope for this plan): true PBLL fidelity, a build-affecting tooling
change.** If the instructor instead wants a single cumulative, tracked deliverable or artifact that
literally accumulates across an arc's weeks (rather than a narrated scenario recapped in prose), that
requires a scoped engineering change: a new or amended data field in `LessonContentParser`'s input
contract, corresponding changes to the PPTX/PDF/TypeScript generators, updated test coverage, and
possibly a change to how the app's `import.meta.glob` week-discovery groups an arc's weeks together.
This sizing is a repository-grounded estimate of what such a change would touch, not a scoped
engineering plan itself; adopting Option B would require its own new or amended plan, separate from
this one, before any such tooling change proceeds.

This plan's own zero-new-scope claim (see the Status line) depends on the instructor accepting Option A.
Section 9 records this as the first remaining instructor decision.

## 6. Recommended execution and batching approach

Once approved, the approximately 26 Advanced-band weeks are authored using the same three-stage pattern
already used for all 52 prior Beginner- and Intermediate-band weeks: Scribe authors each week's content
package, engineering-fleet's T1 generates the accessibility-validated PPTX/PDF/TypeScript materials from
that content, and Verifier independently checks the writer's completion claim before the batch is
treated as done.

**Recommended batching: arc-aligned batches of approximately 3-4 weeks each**, following domain-arc
boundaries rather than arbitrary week counts, so each batch corresponds to a coherent content unit:

- Legal arc (Weeks 1-6): two batches, for example Weeks 1-3 and 4-6.
- Finance arc (Weeks 7-11): two batches, for example Weeks 7-9 and 10-11 (or 7-10/11, adjustable).
- C1 cross-arc delivery/milestone (Weeks 12-13): one batch.
- Technology arc (Weeks 14-18): two batches, for example Weeks 14-16 and 17-18.
- Literature arc (Weeks 19-23): two batches, for example Weeks 19-21 and 22-23.
- C2 cross-arc delivery/capstone (Weeks 24-26): one batch.

Each batch passes its own acceptance (Section 7) before the next batch begins, mirroring the
author-then-validate sequencing the governing plan's decision D5 already recommends for full-scale
content authoring. This recommendation is adjustable: the instructor or the executing Scribe/T1/Verifier
sequence may combine or split batches differently, provided each batch still validates before the next
begins and arc coherence is preserved where practical.

## 7. Acceptance and validation

Each Advanced-band week is accepted only when all of the following hold:

- The full six-file element set is present (vocabulary list, phrases-and-Q&A, practice activity,
  flashcards, weekly review recap, and any week-level README/overview file matching the established
  prior-band convention), matching `curriculum-architecture.md` Section 5's reusable lesson-template
  specification exactly.
- The instructor-facing PPTX and student-facing PDF are actually generated (not only outlined) and pass
  the project's existing accessibility validation pipeline (PowerPoint Accessibility Checker for the
  PPTX; tagged, PDF/UA-oriented export validated in Acrobat Pro and PAC for the PDF), per the governing
  plan's Section 3, item 4 and Section 6.
- Dialect, register, old/modern, taboo, and inclusive-language badges are applied per
  `curriculum-architecture.md` Section 4's taxonomy and only where genuinely evidenced, consistent with
  the revised syllabus's own honest-flagging conventions.
- Week 1 correctly assumes, and does not exceed, the Intermediate Week 26 checked seam (Section 3
  above); it must not assume the synthetic future tense, present-perfect or pluperfect subjunctive,
  nominalization, deliberate register-shifting, or any old/modern exposure as already-taught content.
- Old/modern weeks (5, 19, 20, 22) source genuine, citable archaic/modern pairs at authoring time, per
  the syllabus's own limitation note; the roadmap's naming of a mechanism and domain is not itself
  sufficient sourcing. Week 19 specifically should default to a shorter Cervantes short story over an
  unabridged Don Quixote excerpt, per the research briefing's recommendation, unless a Phase 6 author
  documents a stronger substitution.
- Weeks 12, 24, and 25 keep interpreting content at sight-translation/consecutive-adjacent orientation
  depth and do not build simultaneous-interpreting-booth exercises, per the syllabus's strengthened
  citation-scope caveat.
- Each batch passes an independent Verifier pass before the next batch is treated as authorized to
  begin, per Section 6's batching recommendation.

## 8. Risks and rollback

- **Large authoring volume (approximately 26 weeks, each with a full six-file element set plus two
  generated documents).** Mitigation: arc-aligned author-then-validate batches (Section 6), so
  template or quality issues are caught early rather than replicating across all 26 weeks.
- **Template-decision risk: authoring proceeds under an assumption the instructor did not actually
  intend.** Mitigation: this plan recommends the in-scope content-style option (Option A, Section 5)
  as the default and requires explicit instructor confirmation of that choice before any batch begins
  (Section 9); if the instructor selects Option B instead, authoring does not proceed under this plan
  until a separate engineering plan for the tooling change is written and approved.
- **LECOLE-archaic-extension risk: a Phase 6 author could imply a validated readability tool covers
  archaic text when it does not.** Mitigation: the syllabus's explicit caveat (Section 4 of that
  document) requires authors to state the extension is unvalidated, not imply otherwise.
- **Interpreting-depth overreach risk: a Phase 6 author could build simultaneous-interpreting-booth
  content that belongs to Phase 7's separate professional track.** Mitigation: the syllabus's
  strengthened citation-scope caveat at Weeks 12, 24, and 25 explicitly prohibits this, and each
  batch's Verifier pass should check for it at those weeks specifically.
- **Rollback.** This plan's own deliverables (the syllabus revision and the research briefing) are
  additive documentation; rollback is a straightforward revert of those commits. Downstream authored
  content (once begun) rolls back per-batch, consistent with the governing plan's own per-phase
  rollback posture; no code or production data is touched by this plan or by Advanced-band content
  authoring itself.

## 9. Remaining instructor decisions to confirm at approval

1. **Content-style vs. tooling-change template interpretation (Section 5).** Recommended: content-
   style (Option A), zero new engineering scope. If the instructor instead wants true PBLL fidelity
   (Option B), that requires a separate, new or amended engineering plan before any Advanced-band
   authoring that depends on it begins.
2. **The 13/13 C1/C2 pacing split.** Currently an unconfirmed working default, carried forward from
   both prior bands, with a new mild directional caveat from the research briefing (third-party
   estimates suggest C2 tends to need more hours than C1 generically). The instructor should confirm
   this split, or state a preferred alternative, before Phase 6 authors reach the C2 weeks (Week 14
   onward).
3. **The curated/accelerated contact-hour positioning statement.** This band delivers roughly 26
   contact hours per CEFR level, well below generic guided-hour benchmarks for a CEFR level. The
   syllabus positions this explicitly as a curated, accelerated, instructor-led program, not a claim of
   matching generic benchmarks. The instructor should confirm this is the intended framing, particularly
   before any outcome-facing or marketing-adjacent copy is written from this content.
4. **The "mentoring/curriculum-design participation" C2 Table-1 item.** Currently unassigned to any
   teaching week. The instructor should confirm whether it belongs only to Phase 7's separate
   professional track, or whether a lighter, orientation-only touch belongs somewhere in this band
   (most plausibly Week 25 or 26).
5. **Dialect-weighting methodology across the pluricentric curriculum — RESOLVED.** A second, deeper
   research briefing (`docs/research/advanced-spanish-dialect-weighting-methodology.md`) confirmed the
   first briefing's finding that no ready-made, purpose-built dialect-weighting methodology exists
   anywhere in the pluricentric-language pedagogy literature, but it went further and evidence-graded
   four candidate allocation methodologies against a decisive missing input the course owner has since
   confirmed: **the platform's learner base is "a mix"** — general adult learners, with no dominant
   regional or heritage tie and no dominant business-only focus. What follows is the adversarially-
   structured comparative analysis that input resolves, written to be fair to each candidate, including
   the strongest case against this decision's own recommendation.

   **Candidate A — balanced rotation with an enforced spaced-exposure floor (the current working
   default, made rigorous).** Rule: every location at least two passes, spaced across the band; the
   floor is a hard minimum, not an incidental outcome; ceiling exceptions beyond the floor go only to
   zones with genuine, evidence-grounded content ties. Under "a mix," this candidate is the strongest
   fit: a general audience with no stated regional or business skew has no positive reason to receive
   concentrated exposure to any one zone, and broad, roughly even multi-variety coverage directly serves
   the stated goal of cultural breadth across a pluricentric language. This also matches Instituto
   Cervantes' own PCIC guidance, which endorses calibrating variety emphasis to "the speaking community
   in which learners are immersed, and the[ir] interests and perspectives" — for a confirmed "mix" with
   no such specific community, broad coverage is the direct application of that same PCIC principle, not
   a default chosen merely because nothing else was available. Its floor sub-principle is also this
   entire research question's single best-evidenced element (spaced-repetition/frequency science,
   applied by analogy from vocabulary items to dialect-zone-feature consolidation). Its weakness, stated
   plainly: it does not by itself specify which zones earn a ceiling exception, so some author judgment
   is still required at the margin — addressed concretely below, not left open.

   **Candidate B — population-weighted, steelmanned.** The strongest case for a mixed audience is not
   full proportional weighting, which the underlying data shows would give Mexico roughly eight to nine
   passes and reduce El Salvador and Puerto Rico toward zero — starving zones this project deliberately
   chose to include, and producing a course that is not "broad multi-variety exposure" but "mostly one
   variety with token appearances by the rest," which fails the mixed-audience goal on its own terms.
   But a *narrower* steelman survives: a general learner with no stated preference is, in the aggregate,
   still statistically most likely to encounter Mexican Spanish specifically in real-world media,
   travel, and business contexts, given Mexico's outsized global footprint. This is a real, if modest,
   argument for *some* population-informed lean, not zero. This decision treats that narrower steelman
   as partially persuasive (addressed in the concrete allocation below via Mexico's existing Week-1
   opening-anchor placement, not via a numeric third pass) and treats full proportional weighting as
   correctly rejected: the data is strong, but the pedagogical warrant for applying it wholesale to a
   mixed, multi-variety-seeking audience is weak, and the real-world precedent (media "neutral Spanish,"
   Duolingo's Brazilian-Portuguese default) is for single-variety reach, the opposite of this course's
   goal.

   **Candidate C — diaspora/learner-relevance-weighted, steelmanned.** The steelman here is real: this
   project's own ten-location set is already diaspora-skewed (heavy on US-diaspora-relevant Central
   American and Caribbean zones — El Salvador, Honduras, the Dominican Republic, Puerto Rico), so a critic
   could argue a *light* diaspora-lean on pass counts would simply be consistent with a rationale the
   project has already partially adopted at the location-selection stage, not a new imposition. This is
   the steelman's full strength, and it should not be dismissed as baseless. It fails, however, as the
   *governing* methodology for pass-count allocation specifically because the confirmed "a mix" learner
   base directly contradicts Candidate C's core premise, which requires a concrete, non-mixed learner
   profile tied to a specific diaspora composition (the US Hispanic-origin proxy) to be applicable at
   all. Applying full diaspora-weighting on top of an already diaspora-influenced location list would
   also compound, rather than correct, that existing lean — over-weighting El Salvador, Honduras, the
   Dominican Republic, and Puerto Rico beyond what a genuinely mixed audience needs, and under-weighting
   Argentina, Peru, and Spain, all locations the mixed audience has equal reason to encounter. The
   location-selection-stage diaspora lean is accepted as already baked in and not revisited by this
   decision; a second, pass-count-level diaspora lean on top of it is not adopted.

   **Candidate D — business/economic-relevance-weighted, steelmanned.** The steelman: this band does
   carry a real, escalating business-communication framework (Legal and Finance arcs, negotiation and
   presentation escalation across Weeks 1, 9, 10, 14, 17, 24, 25), so a critic could argue the zones that
   framework already leans on (Mexico for manufacturing-adjacent legal content, Argentina for Rioplatense
   finance, Caribbean zones for tourism-adjacent content) deserve weighting credit for that reason. This
   steelman is the same observation Candidate A's own ceiling-exception logic already uses for
   Argentina (below) — which is exactly why Candidate D is not needed as an independent governing
   scheme: its one genuinely load-bearing insight (business-content locations deserve consideration for
   a ceiling exception) is fully absorbed by Candidate A's own "richest teachable contrast" ceiling
   logic. As a *governing* scheme covering the whole ten-location allocation, Candidate D fails under
   "a mix" for the same reason as Candidates B and C: the confirmed learner base is not business-only,
   so weighting the entire rotation toward business-vertical relevance would over-serve a subset of the
   audience's goals at the expense of the general-cultural-breadth goal the mixed audience actually has.

   **Recommendation.** Candidate A, refined, is this decision's genuine best judgment: balanced rotation
   with an enforced, spaced two-pass floor as the governing rule for all ten locations, plus evidence-
   grounded ceiling exceptions applied narrowly and named explicitly (below), not left to unconstrained
   per-week author discretion. This is falsifiable: if the platform's actual enrolled learner base is
   later found to be concentrated in a specific diaspora, region, or business-only segment (contradicting
   the "a mix" finding this recommendation rests on), Candidates C or D should be reopened and
   re-evaluated against that new, more specific evidence, not treated as permanently foreclosed.

   **The strongest case against this recommendation.** A fair critic's best objection is not that
   Candidate A lacks evidence for its floor (that part is genuinely the best-evidenced element in the
   whole research record) but that Candidate A's *ceiling* remains, honestly, author judgment dressed in
   evidence-graded language: deciding which zones get a third pass beyond the floor is not itself a
   rule the evidence hands over, and a critic could reasonably argue this decision has not actually
   "resolved" the methodology so much as formalized the status quo default with better-organized
   justification for its floor. This decision accepts that critique as substantially correct for the
   ceiling specifically, and states plainly, rather than obscures, exactly which parts of the final
   allocation below are evidence-backed and which are author judgment.

   **Concrete allocation for the ~26-week, roughly 20–21-location-anchor-slot Advanced band.** The floor
   of two passes, spaced, applies to all ten locations. One location receives a third pass, on evidence-
   grounded structural grounds already established in the syllabus, not on a population or diaspora
   basis:

   - **Spain: three passes (Weeks 5, 19, 20).** This is the one ceiling exception this decision adopts,
     and it is evidence-grounded, not an arbitrary pick: the syllabus's old/modern register-concentration
     mechanism (Section 4) structurally requires Golden Age literature and historical legal register,
     both conventionally Peninsular-associated bodies of content, and three of the band's four old/modern
     weeks fall naturally to Spain as a direct structural consequence, not a weighting preference chosen
     independently of content.
   - **Mexico, Colombia, El Salvador, Honduras, Argentina, Peru, the Dominican Republic, Puerto Rico, and
     Ecuador: two passes each**, at the floor, spaced across the band, per the existing week assignments
     already in `advanced-band-syllabus.md` Section 3 (Mexico Weeks 1, 15; Colombia Weeks 2, 16; El
     Salvador Weeks 3, 21; Honduras Weeks 4, 6; Argentina Weeks 7, 9; Peru Weeks 8, 22; Dominican Republic
     Weeks 10, 24; Puerto Rico Weeks 12, 17; Ecuador Weeks 14, 17).
   - **Argentina was evaluated for, and declined, a third pass.** Its "Rioplatense for finance" sector
     tie is the strongest evidence-grounded ceiling case of any location besides Spain's structurally-
     necessitated one. It was not elevated because doing so within the band's fixed roughly-21-slot
     budget would require either breaking another location's own evidence-backed floor (rejected, since
     the floor is the best-evidenced element available) or restructuring the already-sequenced
     grammar/topic/week connections spanning Weeks 7–26, a distinct content-authoring decision this plan
     does not make. This is stated explicitly as author judgment: if a future revision changes the week
     budget or grammar sequencing, Argentina is the first candidate the evidence would support elevating.
   - **Mexico's real-world encounter frequency was considered as a tie-break input, not adopted as a
     numeric addition.** Applying it as an extra pass would reintroduce the population-proportional logic
     this decision explicitly declines to govern the whole scheme by (see Candidate B above). Instead,
     Mexico's existing placement as the band's Week 1 opening anchor is treated as sufficient structural
     prominence without a numeric third pass.

   **What remains explicit author judgment, stated plainly rather than implied as evidence-backed.** The
   floor of two, spaced across the band, is evidence-backed (spaced-repetition/frequency science, applied
   by analogy). The choice of balanced rotation over population-, diaspora-, or business-weighting as the
   *governing* scheme is a reasoned values-and-context judgment resting on the confirmed "a mix" learner-
   base input, not a directly evidenced finding on its own. Spain's third pass is evidence-grounded via
   the old/modern mechanism's structural requirements. The decision not to elevate Argentina or Mexico
   to a third pass is author judgment, made transparently for the stated week-budget and sequencing
   reasons, not because the evidence argues against them. This resolution supersedes the syllabus's prior
   "Unknown" flag on dialect-weighting methodology (`advanced-band-syllabus.md` Section 8, items 3 and
   13, both updated to reflect this resolution); the instructor may still substitute a specific week's
   anchor zone per the syllabus's own standing substitution provision, provided any substitution
   preserves the floor and spacing this resolution establishes.

## 10. Downstream owner

Scribe owns Advanced-band content authoring (the six-file element set for each week, per the approved
batching sequence). Engineering-fleet (T1 for materials generation; Verifier for independent completion
checks) owns generating and validating each week's PPTX/PDF/TypeScript materials, under the governing
plan's standard engineering mode. Neither begins Advanced-band batch work until this plan is approved.

team_authorization: not applicable. This plan does not require or authorize an agent-team session; the
standard serial Planner/Scribe/engineering-fleet routing already in effect for this project governs its
execution.

## 11. Approval gate

**No downstream Advanced-band batch authoring begins until the user explicitly approves this plan and
confirms the five remaining instructor decisions in Section 9.** Approval of this plan alone, without
Section 9's decisions being confirmed, is not sufficient to begin batch authoring: Section 9, item 1 in
particular determines whether this plan's own zero-new-engineering-scope claim holds. Once approved and
confirmed, this plan's approved path authorizes the batching sequence in Section 6 to begin, subject to
each batch's own acceptance checks (Section 7) and the standard Verifier gate before any batch is
treated as complete.
