# Plan: Lizbeth Spanish privacy policy (research, draft text, and implementation)

- Plan id: `lizbeth-spanish-privacy-policy`
- Task id: `lizbeth-privacy-policy-2026-10`
- Status: **APPROVED 2026-10-13.** The user stated, verbatim, on 2026-10-13: "H:\CommandCenter\orchestrator\docs\plans\lizbeth-spanish-privacy-policy.md is approved." Decisions D-P1 to D-P20 are adopted at their recommendations. The proposed GitHub issue in section 20 may now be filed. PR A starts after PR #229 merges. Placeholder business details stay owner-editable in brand/business settings. The attorney review launch gate (D-P5) is a decision of this plan and is unchanged by this approval. Hosted actions still need separate explicit approval.
- Route: research-backed engineering plus document. The policy text is drafted in this plan. The engineering fleet implements after approval.
- Target: `lebobo88/lizbeth-spanish` (private). Evidence base: read-only checkout `H:\CommandCenter\orchestrator\lizbeth_spanish-main-88b` at `origin/main` `88b43fd`. Every `file:line` in this plan refers to `88b43fd` unless stated. This plan lives in the orchestrator repository, a separate repository from the target.
- Research accessed: 2026-10-12. Evidence labels: Observation (read in code), Inference (derived), Assumption, Unknown. Source tags: primary, secondary, UNVERIFIED.
- Revision log:
  - R1 2026-10-12: judge findings J-001 (email-correction promise and claim audit) and J-002 (enforceable launch gate) addressed; design REV2 reviewed PASS.

> **Informational research, not legal advice.** This plan and the draft policy in it summarize public sources and a code inventory. They are not legal advice and create no attorney-client relationship. A licensed attorney must review the policy before it is published (launch gate, decision D-P5).

Reading guide: an approver needs sections 3, 15, 16, and 18. Sections 4 to 6 hold the evidence. Sections 7 and 8 are the draft policy text. Sections 9 to 14 are execution detail for the engineering fleet.

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

---

## 1. Outcome and audience

User request, verbatim: "Let's add another gh issue outlining requirements to include a privacy policy. Do deep web research on the legal requirements for our platform and let's plan the writing and implementation of an appropriate privacy policy."

Follow-up answers, verbatim: "1 Michigan in United States, 2 only 18 and up, 3 payment is separate from the site and you need to investigate the codebase to answer the rest, 4 use placeholders for now and let owner account edit it in brand/business settings as appropriate." The user also asked to use the local "senate" legal-council repository as a reference (section 4.5).

This plan delivers:

1. Legal-requirements findings with citations and a per-law applicability verdict (section 4).
2. A code-cited data inventory (section 5).
3. The policy outline, a coverage matrix, the full DRAFT policy in English with `{{placeholders}}` bound to owner settings, and a full Spanish translation drafted for Lizbeth's approval (sections 6 to 8). The Spanish approach follows the #208 / D-21 precedent: "you draft and she approves".
4. An implementation plan (section 9).
5. Numbered decisions with recommendations (section 15).
6. A proposed GitHub issue title and body (section 20).

Audience: Rob (operator, approver), Lizbeth (owner and teacher, approves the Spanish text and fills the four variables), the engineering fleet, and the reviewing attorney.

## 2. Scope and non-goals

In scope:

- A public `/privacy` page in English and Spanish.
- Privacy links on the sign-in page, the public catalog footer, and the authenticated footer (including `/admin`).
- A "Privacy policy details" fieldset in the owner Business settings page for four variables.
- Database and Edge changes for those variables, with a migration and a rollback.
- Tests and browser validation.
- The policy draft text in English and Spanish.
- The GitHub issue text.

Non-goals:

- This plan writes no repository code.
- No issue is filed by this plan. The orchestrator files after approval.
- No commit or push to main. Work ships as pull requests only.
- No hosted migration apply, Edge deploy, or Netlify deploy without a separate explicit approval (D-P16).
- No cookie banner.
- No Terms of Service (a possible follow-up).
- No rich-text policy editor.
- No self-service deletion or export tool (follow-up candidates only).
- No claim of GDPR compliance.

## 3. Summary

### 3.1 Applicable laws (verdicts as of 2026-10-12)

| Verdict | Laws |
|---|---|
| Applies | FTC Act section 5 (policy must match practice); Michigan Identity Theft Protection Act (standing duty, probably not triggered by current data); state breach-notification laws per affected resident's state |
| Likely applies | Michigan Consumer Protection Act (backstop); CalOPPA (certain if any California-resident student); Delaware OPPA and Nevada NRS 603A (if students reside there) |
| Uncertain, attorney question | Connecticut CTDPA as amended (sensitive-data trigger with no volume floor); ADA Title III for a web-only business; GDPR, UK GDPR, PIPEDA, Quebec Law 25, Mexico LFPDPPP if the teacher knowingly accepts a resident of those places |
| Does not apply | CAN-SPAM (no email sent today); COPPA (adult audience); CCPA/CPRA (thresholds); other comprehensive state privacy laws (volume thresholds); FERPA; Michigan SOPPA; EU/UK/Canada/Mexico law absent deliberate offering to residents |
| Not enacted (watch) | Michigan SB 359 (Personal Data Privacy Act); Michigan SB 360-364 breach amendments (House status UNVERIFIED) |

### 3.2 Key data findings

- The app stores account email, enrollments, progress, free-text lesson answers (including server-saved drafts), quiz answers, teacher feedback, student feedback to the instructor, and an activity log. It stores no names, no payment data, and no student uploads on main.
- Three localStorage items exist (language, accessibility settings, and the Supabase session). No cookies, analytics, ads, error reporting, or embeds exist in app code.
- Google Fonts loads from every page, including the anonymous sign-in page, so Google receives visitor IP addresses. An owner-set logo may hotlink from any http(s) host.
- There is no self-service deletion, no data export, no retention purge, and no age gate. Owner hard delete cascades most records but leaves activity-log rows with the actor nulled.
- No privacy policy or link exists today.

### 3.3 Top decisions

D-P1 (foreign-law stance, recommend a US-focused policy that voluntarily meets the GDPR Art. 13 content list), D-P2 and D-P3 (owner edits four variables only, stored in `owner_settings` with an anon SELECT-only view), D-P5 (mandatory attorney review), D-P6 (12-month retention default), D-P8 (self-host Google Fonts), D-P17 (student email correction: the site cannot change an account email today), D-P18 (who flips the published state), D-P19 (pre-launch behavior), D-P20 (behavior when the policy version changes after publish). All are in section 15.

---

## 4. Legal-requirements findings

### 4.1 Disclaimer and method

This section is informational research accessed on 2026-10-12. It is not legal advice. Each verdict below is a compressed IRAC (issue, rule, application, conclusion) in the style of the Senate `legal-reasoning` skill. Where a point could not be verified from a primary source, it is labeled UNVERIFIED. Assumptions A1 to A5 (section 16) underpin the verdicts. The strictest applicable regime sets the floor: the policy is written to satisfy the CalOPPA content list because it is the most prescriptive regime that likely applies.

### 4.2 Per-law verdict table

Source IDs refer to the ledger in Appendix A. "Op." means operational.

| Law | Citation | Jurisdiction | Validity / as-of | Verdict | Reasoning | Policy-content obligations | Op. obligations | Sources |
|---|---|---|---|---|---|---|---|---|
| FTC Act section 5 | 15 U.S.C. 45 | US federal | In force; as of 2026-10-12 | **APPLIES** | The FTC treats broken privacy promises and inadequate security as deception or unfairness. The deception standard applies to policies. | Policy must match code exactly (disclose Google Fonts; no absolute security claims). | Keep promises; security appropriate to the data; no retroactive looser changes without notice or consent. | P2-S1, P2-S38 |
| CAN-SPAM | 15 U.S.C. 7701 et seq. | US federal | In force | **DOES NOT APPLY** to the app today (no email sent). Applies to any future teacher promotional email. | Transactional and relationship email is exempt except header accuracy. | Email statement in policy section 4. | If promotional email is ever sent: opt-out, postal address, accurate headers. | P2-S3 |
| COPPA | 15 U.S.C. 6501-6506; 16 CFR 312 | US federal | Amended rule published 2025-04-22, effective 2025-06-23, compliance date 2026-04-22 (dates via secondary; Federal Register primary was blocked) | **DOES NOT APPLY** (adult audience, teacher-provisioned accounts) unless actual knowledge of an under-13 user | Then delete or obtain consent. | 18+ statement (sections 2 and 12). | Delete on discovery. | P2-S6, P2-S5 |
| Michigan Identity Theft Protection Act | MCL 445.63, 445.72 | Michigan | In force; amendments pending (4c) | **APPLIES** as a standing duty | "Personal information" means name plus SSN, driver's license, or financial account number. Email plus password is NOT within the current Michigan definition (secondary DWT summary; primary not retrieved; confidence medium-high). The app stores no names, SSN, or financial data, so a breach of current data probably would not trigger Michigan notice. $250 per knowing failure (primary excerpt). The $750k cap and notice-content items are UNVERIFIED (sources conflict). | Breach sentence: "as required by applicable law". | Incident runbook (Appendix B). Pending SB 360-364 (passed Senate Aug 2025; House status UNVERIFIED) would add a 45-day deadline and AG notice. | P2-S10 (secondary), P2-S11 (primary), P2-S8, P2-S9 |
| Michigan Consumer Protection Act | MCL 445.903(1)(s), (cc) | Michigan | In force | **LIKELY APPLIES** as a backstop for misleading statements or material omissions | An inaccurate policy could be a misleading statement. | Accuracy (M9). | Parity review (Step 9). | P2-S12 |
| Michigan SB 359 (Personal Data Privacy Act) | Bill, 2025-2026 session | Michigan | **NOT ENACTED**; last action 2025-06-12, referred to Committee of the Whole | **Horizon watch** | No duty exists. | None now. | Re-check at stale-plan review. | P2-S13, P2-S14 |
| Michigan SOPPA | 2016 PA 368 | Michigan | In force | **DOES NOT APPLY** | Covers K-12 school-purpose operators only. | None. | None. | P2-S15 |
| CalOPPA | Cal. Bus. & Prof. Code 22575-22579 | California | In force; text via statute reproductions (official site blocked) | **LIKELY APPLIES** (certain if any California-resident student; no size threshold) | An operator of a commercial website that collects personally identifiable information from California residents must post a policy. Violation only if not posted within 30 days after notice. | Section 22575(b): categories of PII collected and third parties shared with; review/change process if any; how users are notified of material changes; effective date; Do Not Track response; whether other parties collect PII across sites over time. Section 22577(b): "conspicuously post" via a link containing the word "Privacy" on the home or first significant page in noticeable type. | Link placement (sign-in, catalog footer, authenticated footer). | P2-S16, P2-S17 |
| CCPA / CPRA | Cal. Civ. Code 1798.140(d) | California | Revenue threshold $26,625,000 effective 2025-01-01 per CPPA | **DOES NOT APPLY** | Thresholds: $26,625,000 revenue, 100,000 consumers, or 50% of revenue from selling or sharing. Assumption A1 (revenue under $1M). | None required. | Re-check if revenue or volume changes. | P2-S19 |
| Delaware Online Privacy and Protection Act | 6 Del. C. 1202C, 1205C | Delaware | In force (primary) | **LIKELY APPLIES** if any Delaware resident | CalOPPA-parallel contents; policy "conspicuously available". | Same content list as CalOPPA. | Same link placement. | P2-S21 |
| Nevada privacy notice law | NRS 603A.300-.360 | Nevada | In force (primary) | **LIKELY APPLIES** if Nevada students and nexus (wording UNVERIFIED) | Exemption requires being located in Nevada (not available). | Notice of covered-information categories, third parties, review process, change notice, third-party tracking, effective date (603A.340). | Designated request address for sale opt-out (603A.345); whether required when there is no sale is UNVERIFIED. | P2-S22 |
| Other comprehensive state privacy laws | VA, CO, UT, IA, IN, KY, RI, TN, MT, OR, TX, NE, MN, FL, DE DPDPA, NH, NJ, MD | Various | Thresholds mostly via secondary sources (UNVERIFIED) | **DO NOT APPLY** at this scale | Volume thresholds of 25k to 175k consumers or revenue tests. Texas and Nebraska exempt SBA small businesses except the sensitive-data-sale consent rule, and there is no sale. | None required. | Re-check if volume grows. | P2-S20 (secondary), P2-S27, P2-S28 |
| Connecticut CTDPA as amended by PA 25-113 | Conn. law, amended effective 2026-07-01 | Connecticut | Via secondary (Hunton) | **UNCERTAIN, attorney question** | Applies to controllers that process ANY sensitive data of CT consumers (no volume floor) or 35k consumers. Free-text answers could incidentally reveal health or disability data. | Sensitive-information instruction (policy section 3). | Delete on request. Mitigation: ask students not to include sensitive personal information. | P2-S25, P2-S26 |
| FERPA | 20 U.S.C. 1232g; 34 CFR 99.1 | US federal | In force | **DOES NOT APPLY** (no Department of Education program funds) | Do not use FERPA terms in the policy. | None. | None. | P2-S29 |
| ADA Title III and web accessibility | ADA Title III (no web regulation; DOJ 2022 guidance) | US federal | No Title III web regulation | **UNCERTAIN** as a mandate for a web-only Michigan business | DOJ 2022 guidance says the ADA reaches web offerings of public accommodations. Sixth Circuit physical-place case law is from general knowledge and UNVERIFIED. | Recommend WCAG 2.2 AA for the policy page. | WCAG 2.2 AA conformance for the new page. | P2-S30 |
| State breach-notification laws | All 50 states, DC, territories | Per affected resident's state | In force | **APPLY** per affected resident's state | California Civ. Code 1798.82(h) includes username or email plus password, so a credential breach can require notice to California residents even where Michigan's definition is not met (secondary). | Breach sentence. | Keep an incident runbook; be able to determine students' states. | P2-S31, P2-S32 (secondary) |
| EU GDPR | Arts. 3(2), 13, 27; EDPB Guidelines 3/2018 | EU | In force | S1 (no deliberate offering to EU residents): **NOT APPLICABLE** (high). S2 (teacher knowingly accepts an EU resident): **ARGUABLE** (medium-low). | Spanish is a language generally used in the US (about 44.9M speakers, ACS 2024 via USAFacts), so a Spanish UI is weak or no targeting evidence (Recital 23). Progress tracking in a closed course is weakly "monitoring". Art. 27 representative duty has a doubtful "occasional" exemption (EDPB paragraph 16). | Voluntary Art. 13-style floor items (D-P1). No "GDPR compliant" claim. | Re-evaluate before knowingly accepting a non-US resident. | P3-S2, P3-S3, P3-S1, P3-S4, P3-S43 |
| UK GDPR | Arts. 3(2), 27 (post-DUAA 2025) | UK | In force | Same verdicts as EU | As EU. | As EU. | As EU. | P3-S6, P3-S7, P3-S36 |
| Canada PIPEDA; Quebec Law 25 | PIPEDA; Bill C-36 | Canada | Bill C-36 first reading 15 June 2026, not enacted | PIPEDA: S1 not applicable; S2 possible (real and substantial connection). Quebec Law 25: S1 not applicable (medium); S2 uncertain. | Cases A.T. v. Globe24h.com, 2017 FC 114, and Lawson v. Accusearch, 2007 FC 125 (the latter cited via secondary). | None now. | Re-evaluate under D-P1. | P3-S30 (IAPP), P3-S31, P3-S29, P3-S32 |
| Mexico LFPDPPP | New law, DOF 20 Mar 2025, in force 21 Mar 2025; amended 14 Nov 2025 | Mexico | Territorial article UNVERIFIED | S1 not applicable (medium); S2 probably not | Territorial reach could not be confirmed. | None now. | Re-evaluate under D-P1. | P3-S33 |
| Device storage rules | ePrivacy Art. 5(3) (EDPB 2/2023; WP194 via secondary); UK PECR reg. 6 and Sch. A1 (from 5 Feb 2026) | EU / UK | PECR Sch. A1 lists "authenticating the user's identity or recording selections made on a website" as strictly necessary | **NO CONSENT BANNER NEEDED** for the three localStorage items | Disclose each key, purpose, persistence, and how to clear. Google Fonts sets no cookies but receives IP, URL, user agent, referer. LG Munchen I, 20 Jan 2022 (3 O 17493/20), awarded 100 EUR for dynamic Google Fonts under GDPR (relevant only in S2). US: no general cookie-banner law. | Storage table (policy section 10). | Parity test for storage keys. | P3-S9, P3-S11, P3-S13, P3-S14, P3-S15, P3-S16 |
| Bilingual disclosure | FTC 16 CFR 14.9; WP260 paragraph 13 | US federal; EU guidance | As of 2026-10-12 | **Practice recommendation** | Disclosures should be in the language of the target audience; translations must be accurate. | Full Spanish version, same effective date and version, "English controls unless applicable law requires otherwise", offer to clarify in Spanish. | Translation parity test. | P3-S40, P3-S41, P3-S44 |

### 4.3 Consolidated element list

Policy elements required by the "likely applies" regimes (CalOPPA, Delaware, Nevada), labeled M1 to M9, and the recommended elements R1 to R11:

| Id | Element | Source of the requirement |
|---|---|---|
| M1 | Categories of personal information collected | CalOPPA 22575(b); DOPPA; NRS 603A.340 |
| M2 | Categories of third parties the information is shared with | Same |
| M3 | Process to review and change information, if one exists | Same |
| M4 | How users are notified of material changes | Same |
| M5 | Effective date | Same |
| M6 | Response to Do Not Track signals | CalOPPA 22575(b); DOPPA |
| M7 | Whether other parties collect PII across sites over time | CalOPPA 22575(b); NRS 603A.340 (third-party tracking) |
| M8 | Conspicuous link containing the word "Privacy" | CalOPPA 22577(b); DOPPA "conspicuously available" |
| M9 | Accuracy against actual practice | FTC Act section 5; MCPA |
| R1 | 18+ statement | COPPA avoidance; D-P1 |
| R2 | No sale, no ads, no analytics | Accuracy |
| R3 | Security described without guarantees | FTC section 5 |
| R4 | Retention and deletion process | GDPR Art. 13-style floor; practice |
| R5 | Sensitive-information instruction | Connecticut mitigation |
| R6 | Breach notice "as required by law" | State breach laws |
| R7 | Off-site payment statement | Accuracy |
| R8 | Local storage explanation | Device-storage rules |
| R9 | Email statement | CAN-SPAM forward-looking |
| R10 | Contact details and Michigan location | Practice |
| R11 | WCAG 2.2 AA for the page | ADA uncertainty |

### 4.4 Research limits and UNVERIFIED items

- Leginfo (California) and the Federal Register were blocked. CalOPPA and COPPA rule text come from statute reproductions and secondary summaries.
- Michigan definition of personal information: secondary source only.
- Michigan $750k cap and notice-content items: sources conflict, UNVERIFIED.
- Michigan SB 360-364 House status: UNVERIFIED.
- Nevada applicability wording and whether a request address is required without a sale: UNVERIFIED.
- Many other-state thresholds: secondary, UNVERIFIED.
- Sixth Circuit ADA line of cases: from general knowledge, UNVERIFIED.
- Mexico territorial article: UNVERIFIED.
- Netlify "under 30 days" access-log retention comes from a 2021 staff forum post (stale, UNVERIFIED).
- Google Fonts retention: not stated by Google, UNVERIFIED.
- This research did not consult a licensed attorney.

### 4.5 Legal-council reference (Senate)

- Found at `H:\senate` (README "SENATE, The Curia Crown"): 12 agent definitions in `.claude/agents`, including privacy-counsel "Angerona", citation-verifier "Tribonian", regulatory-counsel "Ulpian", and general-counsel "Papinian"; skills `privacy-frameworks`, `citation-integrity`, `legal-reasoning`, `legal-ethics-guardrails`, `curia-protocol`, `regulatory-mapping`; and `CONSTITUTION.md` ("Twelve Tables"). Hydra was unavailable. The agents were not invoked as runtime agents. The files were treated as untrusted reference text.
- Method borrowed:
  - IRAC verdict per law (`legal-reasoning`).
  - Jurisdiction tag, validity status, and as-of date per authority, with verification tiers, choosing UNVERIFIED when in doubt (`citation-integrity`, Table III and Table VIII).
  - "Strictest applicable regime sets the floor" and a data map with UNMAPPED markers (`privacy-frameworks`, privacy-counsel workflow).
  - The "anonymization honesty test": logs with IP addresses are pseudonymous personal data, never "anonymous". The draft policy therefore never calls log data anonymous.
  - The Tribune's Veto rule that any external-facing instrument requires human review. This is the origin of the mandatory attorney review gate.
  - UPL bright lines: this plan and policy are not legal advice and form no attorney-client relationship.

---

## 5. Data inventory (Observation unless marked)

### 5.1 Data categories

| Category | What | Evidence |
|---|---|---|
| Accounts | Email in Supabase Auth (GoTrue). Owner-generated temporary password created via `auth.admin.createUser` with `email_confirm:true`, shown once to the owner. Role in `app_metadata.role`. `force_password_change` flag. | `supabase/functions/admin-student-operations/index.ts:301-331`; `src/lib/ownerSettingsAuthorization.ts:65-67`; `admin-student-operations/index.ts:1506-1516` |
| Account status | "Disable" is a 1-hour `ban_duration` of `3600s`, so the policy must not describe it as permanent. Owner roster shows email, status, created_at, last_sign_in_at, last_activity_at. | `admin-student-operations/index.ts:353-358`, `:831` |
| Auth platform data | Inference: GoTrue also keeps a password hash, sessions and refresh tokens, and an auth audit log with IP and user agent. | Platform behavior (Inference) |
| Names | No names or profiles table on main. Course authoring reads `user_metadata.full_name` falling back to email, but nothing writes it. PR #231 may add names (Unknown). | `supabase/functions/course-authoring/index.ts:258-260` |
| Enrollments and cohorts | `student_enrollments` (FK to `auth.users` ON DELETE CASCADE); `cohort_memberships`, `enrollment_requests`. | `supabase/migrations/202607170001_init_schema.sql:34-46`; `202608280003_issue5_course_authoring.sql:121-142` |
| Progress | `student_lesson_progress` (first and last opened, completed); `enrollment_lesson_entitlements`. | `202608270001_issue2_progress_dashboard.sql:2-14`; `202608280003:185-196` |
| Lesson task drafts and submissions | `lesson_task_submissions.responses` (jsonb free text), `teacher_feedback`, `score`; immutable `lesson_task_submission_attempts` snapshots; server-side draft autosave including keepalive on page hide. | `202610040003_issue179_lesson_tasks.sql:41-81`; `src/services/lessonTaskData.ts:129-154` |
| Quiz attempts | Answers, score, grades. | `202608280003:144-152`; `202610050001_issue180_lesson_quizzes.sql:53-67` |
| Student feedback and topic suggestions | `feedback_submissions` content, 1 to 5000 characters. UI says "Private · you and the instructor only". | `202608280001_issue3_feedback_inbox.sql:4-35`; `src/lib/siteContentRegistry.ts:385` |
| Activity log | `activity_events` (actor_id ON DELETE SET NULL; payload ids). Owner reads the latest 200. No retention or purge job anywhere. | `202608280003:156-165` |
| Not persisted | Flashcard and vocabulary review state. | Observation |
| Owner settings | brand_name, colors, logo URL (any http(s) host), `legal_copyright_text`, `legal_ip_notice`. SELECT granted to authenticated only. Writes through the owner-settings Edge function (service role). NOT anon-readable. | `202607170007_owner_settings_authenticated_read.sql`; `202607250002`; `src/services/ownerSettingsData.ts:1-20` |
| Site content | Owner-editable registry text. Base table is service-role only. View `public.public_site_content` is SELECT to anon and authenticated. Keys are short plain text (max length 320) and allowlisted. Adding a key requires a site-content Edge redeploy for writes. | `202610040001_issue177_site_content.sql:26-60`; `src/lib/siteContentRegistry.ts`; `src/lib/siteContentAuthorization.ts:37-128` |
| Storage | One private bucket `lesson-assets` (teacher materials). No student uploads. | `supabase/config.toml:134-137` |
| Network identifiers | No IP or user-agent columns in app tables. Rate limiting is GoTrue config plus a 750 ms draft interval. | `202610040007` |

### 5.2 Deletion, export, and access

| Operation | Behavior | Evidence |
|---|---|---|
| Owner hard delete | Owner retypes the email, then `auth.admin.deleteUser`. Cascades enrollments, progress, entitlements, submissions and attempts, quiz attempts, feedback, and cohort rows. | `admin-student-operations/index.ts:401-449` |
| Activity log after delete | `activity_events` rows survive with the actor nulled and may hold enrollment or lesson UUIDs (Inference, high). | `202608280003:156-165` |
| Partial operations | Unassign (preserve), wipe-save. | `admin-student-operations/index.ts:542-616` |
| Self-service | No self-service deletion, no data export, no self email change. | Observation |

### 5.3 Browser storage

| Item | Purpose | Evidence |
|---|---|---|
| `localStorage` `lizbeth.siteLanguage` | Remember English or Spanish | `src/context/PublicContentContext.tsx:23` |
| `localStorage` `lizbeth-accessibility-settings` | Text size, typography, line height, letter spacing, measure | `src/context/AccessibilityContext.tsx:5-49` |
| Supabase session (`persistSession:true`) | Keep the user signed in. Library-default key `sb-<project-ref>-auth-token` (Inference, high; verify in browser). | `src/services/supabase.ts:170-176` |
| Others | No `sessionStorage`, cookies, or IndexedDB in app code. | Observation |

### 5.4 Third parties and age/legal state

- Google Fonts through `@import` of `fonts.googleapis.com` in `src/App.css:14` (global, so the anonymous sign-in page too), with files from `fonts.gstatic.com`. CSP meta in `index.html:8` (`connect-src 'self' https: …`; no `frame-src`).
- Owner logo hotlinked from any http(s) host on signed-in pages (`src/components/BrandLogo.tsx:26-27`).
- No analytics, error reporting, ads, embeds, or payment links (`package.json:35-49`).
- The app sends no email; onboarding is email-free (`admin-student-operations/index.ts:311`). Hosted SMTP and `enable_signup` are Unknown (local config has `enable_signup=true` but the UI has sign-in only).
- Subprocessors: Netlify, Supabase, and Google Fonts (an independent recipient). `esm.sh` is used only at Edge bundle time (no user data). Local desktop spellcheck (LanguageTool on 127.0.0.1) is not a subprocessor.
- Age and legal: no age gate, no date of birth, no 18+ statement, no privacy or terms page or link. `legal_copyright_text` renders in the authenticated footer only when set (`src/App.tsx:631-635`). `legal_ip_notice` appears on the week-detail page.

### 5.5 Vendor facts

| Vendor | Role | Facts | Sources |
|---|---|---|---|
| Supabase (contracting entity Supabase Pte. Ltd.) | Processor: database, authentication, storage, Edge Functions | Holds email, password hash (bcrypt per secondary source; the policy says "hashed", not the algorithm) and all learning records. Project region chosen at creation: [CONFIRM: Supabase project region]. API/edge logs capture client IP and user agent; auth logs capture IP. Retention by plan: API/DB logs Free 1 day, Pro 7 days, Team 28 days; auth audit logs Free 1 hour, Pro 7 days: [CONFIRM: Supabase plan]. DPA v1 (1 Aug 2026) is part of the Terms and includes EU SCCs Modules 2/3 plus UK/Swiss addenda. Subprocessors include AWS and Cloudflare. Default Supabase SMTP delivers only to team members; production auth emails need custom SMTP (another subprocessor): [CONFIRM: whether invites or password-reset emails are used and the SMTP provider]. | P3-S17 to P3-S21 |
| Netlify | Processor: hosting and CDN | Request logs include client IP, URL, user agent. Observability windows: Free 24h, Pro 7 days, Enterprise 30 days. DPA incorporated by reference. No cookies expected unless split testing (`nf_ab`). | P3-S24 to P3-S27 |
| Google Fonts | Independent recipient (no DPA) | IP, URL, user agent, referer on every page including anonymous sign-in. No cookies. IP is used to serve fonts and for security. Retention not stated (UNVERIFIED). | P3-S16 |
| Owner-set logo host | Arbitrary third party | Receives signed-in users' IP and user agent. Practices unknown. | Observation |

---

## 6. Policy outline and coverage matrix

### 6.1 Outline

The Summary card "The short version" (5 to 7 bullets) followed by 14 sections in this order: 1 Who we are and how to contact us; 2 Who this site is for; 3 Information we collect; 4 How we use it; 5 Who we share it with; 6 Where your information is stored; 7 How long we keep it; 8 How we protect it; 9 Your choices and requests; 10 Cookies and browser storage; 11 Do Not Track; 12 Children; 13 Changes to this policy; 14 Language versions.

Placeholder tokens: owner-set `{{business_legal_name}}`, `{{privacy_contact_email}}`, `{{mailing_address}}`, `{{effective_date}}`; code-owned `{{policy_version}}`, `{{last_updated}}`. Bracketed items `[CONFIRM: ...]` must be resolved before publishing. Conditional clauses are marked `[IF ...]` or `[UNTIL ...]`. Governing-law and venue language is excluded (it belongs in Terms).

### 6.2 Coverage matrix

| Element | Policy location |
|---|---|
| M1 Categories collected | Section 3 |
| M2 Third-party categories | Section 5 |
| M3 Review and change process | Section 9 (what the user can edit, how to ask for other corrections, and the email limitation per D-P17; the draft promises no teacher email change) |
| M4 Notification of changes | Section 13 |
| M5 Effective date | Page meta list (Effective date, Last updated, Version) and section 13 |
| M6 Do Not Track | Section 11 |
| M7 Cross-site collection by other parties | Section 11 (with section 5) |
| M8 Conspicuous "Privacy" link | Not policy text. Implemented by PrivacyLink on four surfaces (section 9.5) |
| M9 Accuracy | Whole policy; inventory-parity tests (section 11.2); Step 9 reviews |
| R1 18+ statement | Sections 2 and 12 |
| R2 No sale, ads, or analytics | Summary; sections 4 and 5 |
| R3 Security without guarantees | Section 8 |
| R4 Retention and deletion process | Sections 7 and 9 |
| R5 Sensitive-information instruction | Section 3 |
| R6 Breach notice "as required by law" | Section 8 |
| R7 Off-site payment statement | Summary; section 3 |
| R8 Local storage explanation | Section 10 |
| R9 Email statement | Section 4 |
| R10 Contact and Michigan location | Section 1 |
| R11 WCAG 2.2 AA | Section 1 (accessibility sentence) and the implementation tests |
| Art. 13-style floor: identity and contact | Section 1 |
| Art. 13-style floor: purposes | Section 4 |
| Art. 13-style floor: recipients | Section 5 |
| Art. 13-style floor: international processing | Section 6 |
| Art. 13-style floor: retention | Section 7 |
| Art. 13-style floor: rights and requests | Section 9 |
| Complaint-to-authority right | Deliberately omitted under D-P1 Option A; add only if a non-US resident is knowingly accepted |

### 6.3 Claim audit (each promise in the draft policy versus current product evidence)

Statuses: Satisfied; Satisfied by owner practice (no automation, the owner must do it); Qualified in R1 (the draft text was narrowed in revision R1 to match the evidence); Requires confirmation. Paths are relative to the checkout at `88b43fd`.

| Policy section | Claim | Status | Evidence |
|---|---|---|---|
| 2 | The site has no sign-up page; your teacher creates accounts | Qualified in R1; Requires confirmation | UI is sign-in only (`src/App.tsx:788-803`). Hosted `enable_signup` is Unknown; local `supabase/config.toml:188` has `enable_signup = true`. Marker `[CONFIRM: hosted Supabase sign-ups disabled]` added; section 16 recommends `enable_signup=false` on hosted. |
| 3 | Temporary password, forced change at first sign-in | Satisfied | `force_password_change` (`admin-student-operations/index.ts:1506-1516`) |
| 3, 8 | Passwords stored hashed | Satisfied (platform) | Supabase Auth stores password hashes (P3 sources). The algorithm comes only from a secondary source, so the policy does not name it. |
| 5, 8 | Access limited to you, your teacher, the site maintainer, and service providers | Qualified in R1 | The earlier draft said "you and your teacher", which was inaccurate: the site administrator (service-role access) and listed providers can also access data. RLS gives students their own rows (`202607200002:86-87`; `202610040003:98-125`), the owner reads all, and service-role Edge functions exist. Follow-up observation only: the UI note "Private · you and the instructor only" (`src/lib/siteContentRegistry.ts:385`) has the same gap. UI scope is not changed by this plan. |
| 8 | HTTPS | Satisfied for production | Hosted Netlify and Supabase serve over HTTPS; the local dev mirror uses http. Step 0 checks that hosted URLs are https. |
| 8 | Role-based database access rules | Satisfied | RLS migrations |
| Summary, 7 | Retention period, then deletion | Satisfied by owner practice | No automated purge exists. The text now says the teacher reviews accounts at least once a year (D-P6; Appendix B.1 annual review). |
| 9 | Deletion on request | Satisfied | Owner hard delete cascades (`admin-student-operations/index.ts:401-449`). Qualifier added: deleted information may remain in providers' backups and logs until they expire. `[CONFIRM: Supabase backup retention for the project plan]`; backups were not researched in P3 (UNVERIFIED). |
| 7 | Activity log retained without identity | Satisfied (Inference, high) | `actor_id` ON DELETE SET NULL (`202608280003:156-165`) |
| 9 | Access copy | Qualified in R1 | The text promises "a copy of the information available to your teacher through the site's tools". There is no export file and vendor technical logs are not fully accessible. No text promises an export or a portable file. Step 0 checks whether the owner can view student draft responses. |
| 9 | Correction | Qualified in R1 | No owner-driven student email change exists on main. The only student `auth.admin.updateUserById` call sets `email_confirm: true` (`admin-student-operations/index.ts:1459-1461`). Delete-and-recreate loses records (`:401-449`). The 2026-09-17 receipt (`docs/evidence/lizbeth-spanish-owner-email-change-20260917.md`) records a one-time operator procedure on the owner's own email, not a product capability. See D-P17. Students can edit their own drafts; lesson completion reset exists (`admin-student-operations/index.ts:851-854`). |
| 9, 13 | 30-day response; direct notice of material changes | Satisfied by owner practice | D-P7, D-P12 |
| 6 | Data location | Requires confirmation | Conditional on the confirmed Supabase region |
| 11 | Do Not Track and cross-site tracking | Qualified in R1 | The vague "to our knowledge" sentence was replaced by an explicit statement: no analytics, advertising, or cross-site tracking tools are used. Google Fonts (until self-hosted) and a teacher-chosen logo host receive standard request data. Google states that Google Fonts does not set cookies and does not use this data to build profiles or target ads (P3-S16); Google's retention is not stated. |
| 10 | No cookies | Requires confirmation | Existing marker `[CONFIRM: no Netlify or Supabase cookies]` |
| Summary, 4, 5 | No sale, ads, or analytics | Satisfied | `package.json:35-49`; source search for analytics, ads, and embeds |
| 4 | No marketing email; promotional email would include an opt-out | Satisfied today; an owner commitment for the future | The app sends no email (`admin-student-operations/index.ts:311`) |
| 8 | Breach notice "as required by law" | Satisfied by legal duty and the runbook | Appendix B.2 |
| 12 | Deletion of under-18 accounts on discovery | Satisfied | Owner hard delete |
| Summary, 3 | Payment off-site; no card data | Satisfied | No payment code in the app; user statement (A4) |

---

## 7. Draft policy, English (DRAFT, not for publication)

Status: DRAFT for attorney review. Do not publish with unresolved `[CONFIRM]`, `[IF ...]`, or `[UNTIL ...]` markers or with empty owner variables. Transcribe into the code content model only from the approved version.

---

# Privacy policy

Effective date: {{effective_date}}. Last updated: {{last_updated}}. Version: {{policy_version}}.

## The short version

- This site is a private online Spanish course run by {{business_legal_name}}. It is for adults, 18 and older.
- We collect only what we need to run your course: your email address, your progress, your answers, and your teacher's feedback.
- We do not sell your information, show ads, or use analytics or tracking tools.
- A few service providers host and deliver the site. They receive technical data such as your IP address.
- We keep your records while you have course access and for up to [CONFIRM: retention months, default 12] months after your last course ends. You can ask us to delete them sooner.
- Payment happens outside this site. We never receive your card details.
- For questions or requests, write to {{privacy_contact_email}}.

## 1. Who we are and how to contact us

This site is operated by {{business_legal_name}} ("we", "us"), located in Michigan, United States. You can reach us at {{privacy_contact_email}} or by mail at {{mailing_address}}, Michigan, USA.

We aim for this page to meet the Web Content Accessibility Guidelines (WCAG) 2.2 at level AA. If you have trouble reading or using it, contact us and we will provide the information another way.

## 2. Who this site is for

[IF D-P1 Option A:] This site is intended for adult learners in the United States. You must be 18 or older to have an account. The site has no sign-up page. Your teacher creates accounts. [CONFIRM: hosted Supabase sign-ups disabled]

## 3. Information we collect

Information you or your teacher give us:

- Your email address. Your teacher creates your account and sets a temporary password, which you may be asked to change when you first sign in. Your password is stored in hashed form by our authentication provider.
- Your course enrollments and the group or cohort you belong to.
- Your answers to lesson tasks, including drafts that are saved automatically as you type.
- Your answers to quizzes.
- Notes and topic suggestions you send to your teacher, up to 5,000 characters each.
- [IF PR #231 adds names: your name.]

Information created as you use the site:

- Your progress, such as when you first and last opened a lesson and whether you completed it.
- Scores and your teacher's feedback.
- A record of course activity, such as enrollments and submissions.
- Your last sign-in time and account status.

Information our service providers log automatically: your IP address, browser type, the pages you request, and the date and time of requests.

What we do not collect: your payment card information (payment is handled separately from this site), government identification numbers, or files uploaded by you. The site does not let students upload files.

Please do not include health information or other sensitive personal information in your answers or notes. We do not need it to teach you.

## 4. How we use it

We use your information to:

- provide your course and let you sign in;
- track your progress and show it to you and your teacher;
- give you feedback;
- keep accounts secure and prevent misuse;
- answer your questions and handle your requests; and
- follow the law.

We do not sell your information. We do not share it for advertising. We do not show ads, and we do not use analytics or tracking tools.

Email: the site itself does not send email [CONFIRM: email provider, if any]. Your teacher may contact you about your course. If we ever send promotional email, it will include a way to opt out.

## 5. Who we share it with

Your teacher can see your account details, progress, answers, and the notes you send. Notes and topic suggestions are visible to you and your teacher, and to the person who maintains the site for us (see section 8).

We use these service providers to run the site:

| Provider | What it does | What it receives |
|---|---|---|
| Netlify | Hosts the site and delivers its pages | Request data such as your IP address, the page address, and your browser type |
| Supabase | Provides our database, sign-in, and server functions | Your account and course records, plus IP address and browser type in its logs |
| [UNTIL fonts are self-hosted: Google Fonts] | Provides the typefaces used by the site | Your IP address, the page address, your browser type, and the page that referred you. It sets no cookies. Google acts as an independent recipient under its own privacy policy |
| A logo host chosen by your teacher (only if the logo is hosted elsewhere) | Provides the logo image | Your IP address and browser type when a signed-in page loads |

Our providers use their own sub-providers, such as cloud infrastructure companies, to deliver their services.

We may disclose information if the law requires it, or to protect the rights, property, or safety of our students, us, or others.

## 6. Where your information is stored

Your records are stored with Supabase in [CONFIRM: Supabase project region]. [CONFIRM region is in the United States, then keep:] Our providers process data in the United States. If you use the site from outside the United States, your information will be processed in the United States.

## 7. How long we keep it

We keep your account and learning records while you have course access and for up to [CONFIRM: retention months, default 12] months after your last course ends. Your teacher reviews accounts at least once a year and deletes accounts whose last course ended more than [CONFIRM: retention months, default 12] months earlier. We delete them sooner if you ask (see section 9).

The record of course activity may remain after your account is deleted, with your identity removed. It may still contain internal reference numbers for course items.

Our providers keep technical logs for short periods set by their plans, currently about [CONFIRM: Supabase plan log window] at Supabase and [CONFIRM: Netlify plan log window] at Netlify. Log data such as IP addresses can identify you, and we treat it as personal information.

## 8. How we protect it

We use encrypted connections (HTTPS), store passwords in hashed form, and use role-based database access rules. Access to your information on the site is limited to you, your teacher, and the person who maintains the site for us, plus our service providers as described in section 5. Please keep your password private.

No system is perfectly secure, and we cannot guarantee the security of your information. If a security breach affects your information, we will notify you as required by applicable law.

## 9. Your choices and requests

You can ask us to tell you what we hold about you, correct it, or delete it. Write to {{privacy_contact_email}} from the email address on your account (or ask your teacher to confirm your identity). We will respond within 30 days.

- Deletion: your teacher deletes your account, which removes your enrollments, progress, answers, quiz attempts, feedback, and group membership. We may keep information where the law requires it. Deleted information may remain in our providers' backups and logs for a limited time until they expire [CONFIRM: Supabase backup retention for the project plan].
- Access: your teacher can give you a copy of the information available to them through the site's tools. The site has no export file or self-service download, and our providers' technical logs are not fully available to us.
- Correction: you can edit your own lesson answers while they are drafts. Ask your teacher about other corrections, such as resetting a lesson's completion. Your account email cannot be changed on the site at this time. If it needs to change, contact us. Your teacher can close your account and create a new one under the correct email, but course records from the old account do not carry over. [IF D-P17 Option B is adopted: replace the last three sentences with "Contact us and we can update it."]
- Browser storage: you can clear it at any time (see section 10).

## 10. Cookies and browser storage

We do not use cookies or tracking cookies, and our pages do not set cookies [CONFIRM: no Netlify or Supabase cookies]. The site stores three items in your browser's local storage:

| Name | What it is for | How long it lasts | How to clear it |
|---|---|---|---|
| `lizbeth.siteLanguage` | Remembers whether you chose English or Spanish | Until you clear it | Clear site data in your browser settings |
| `lizbeth-accessibility-settings` | Remembers your text size, typography, line height, letter spacing, and line width | Until you clear it | Clear site data in your browser settings |
| `sb-[CONFIRM: project reference]-auth-token` | Keeps you signed in | Until you sign out or clear it | Sign out, or clear site data in your browser settings |

These items stay on your device. We do not use them to track you.

## 11. Do Not Track

Some browsers send "Do Not Track" or Global Privacy Control signals. We do not track you across other websites or services, so we respond to these signals the same way as to every visitor. We use no analytics, advertising, or cross-site tracking tools. [UNTIL fonts are self-hosted: Google Fonts, and] a logo host chosen by your teacher receive standard request data (your IP address, browser type, and the page address) when your browser loads files from them. [UNTIL fonts are self-hosted: Google states that Google Fonts does not set cookies and does not use this data to build profiles or target ads. Google does not state how long it keeps the data.]

## 12. Children

This site is for people 18 and older. We do not knowingly collect information from anyone under 18. If we learn that an account belongs to someone under 18, we will delete it. If you believe this has happened, contact us at {{privacy_contact_email}}.

## 13. Changes to this policy

When we change this policy, we update the version number and effective date at the top of this page. Before a material change takes effect, your teacher will notify enrolled students directly, for example by email. We will not use information we have already collected in a materially different way without telling you first and, where the law requires it, getting your consent.

## 14. Language versions

This policy is available in English and Spanish, with the same version and effective date. If the versions differ, the English version controls unless applicable law requires otherwise. If you would like something explained in Spanish, contact us at {{privacy_contact_email}}.

---

## 8. Draft policy, Spanish (DRAFT translation for Lizbeth's approval)

Estado: BORRADOR de traducción para la aprobación de Lizbeth. Misma versión, mismas variables y mismos marcadores que el texto en inglés. Las secciones usan los identificadores en inglés (por ejemplo `information-we-collect`) en ambos idiomas.

---

# Política de privacidad

Fecha de vigencia: {{effective_date}}. Última actualización: {{last_updated}}. Versión: {{policy_version}}.

Si hay alguna diferencia entre las versiones, prevalece la versión en inglés, salvo que la ley aplicable disponga otra cosa.

## En breve

- Este sitio es un curso privado de español en línea dirigido por {{business_legal_name}}. Es para personas adultas, de 18 años o más.
- Recopilamos solo lo necesario para llevar tu curso: tu correo electrónico, tu progreso, tus respuestas y los comentarios de tu docente.
- No vendemos tu información, no mostramos anuncios y no usamos herramientas de analítica ni de rastreo.
- Algunos proveedores de servicios alojan y entregan el sitio. Reciben datos técnicos, como tu dirección IP.
- Conservamos tus registros mientras tengas acceso al curso y hasta [CONFIRM: meses de conservación, por defecto 12] meses después de que termine tu último curso. Puedes pedir que los eliminemos antes.
- El pago se hace fuera de este sitio. Nunca recibimos los datos de tu tarjeta.
- Para preguntas o solicitudes, escribe a {{privacy_contact_email}}.

## 1. Quiénes somos y cómo contactarnos

Este sitio lo opera {{business_legal_name}} ("nosotros"), con sede en Michigan, Estados Unidos. Puedes escribirnos a {{privacy_contact_email}} o enviar correo postal a {{mailing_address}}, Michigan, EE. UU.

Procuramos que esta página cumpla las Pautas de Accesibilidad para el Contenido Web (WCAG) 2.2 en el nivel AA. Si tienes dificultades para leerla o usarla, contáctanos y te daremos la información de otra manera.

## 2. Para quién es este sitio

[IF D-P1 Option A:] Este sitio está dirigido a personas adultas que aprenden en Estados Unidos. Debes tener 18 años o más para tener una cuenta. El sitio no tiene página de registro. Tu docente crea las cuentas. [CONFIRM: registros desactivados en el Supabase alojado]

## 3. Información que recopilamos

Información que nos das tú o tu docente:

- Tu correo electrónico. Tu docente crea tu cuenta y define una contraseña temporal, que quizá se te pida cambiar la primera vez que inicies sesión. Nuestro proveedor de autenticación guarda tu contraseña en forma cifrada mediante hash.
- Tus inscripciones a cursos y el grupo o cohorte al que perteneces.
- Tus respuestas a las tareas de las lecciones, incluidos los borradores que se guardan automáticamente mientras escribes.
- Tus respuestas a los cuestionarios.
- Las notas y sugerencias de temas que envías a tu docente, de hasta 5,000 caracteres cada una.
- [IF PR #231 adds names: tu nombre.]

Información que se genera cuando usas el sitio:

- Tu progreso, por ejemplo cuándo abriste una lección por primera y última vez y si la completaste.
- Las puntuaciones y los comentarios de tu docente.
- Un registro de la actividad del curso, como inscripciones y entregas.
- La hora de tu último inicio de sesión y el estado de tu cuenta.

Información que registran automáticamente nuestros proveedores de servicios: tu dirección IP, el tipo de navegador, las páginas que solicitas y la fecha y hora de las solicitudes.

Lo que no recopilamos: los datos de tu tarjeta de pago (el pago se gestiona por separado de este sitio), números de identificación oficial ni archivos subidos por ti. El sitio no permite que los estudiantes suban archivos.

Por favor, no incluyas información de salud ni otra información personal sensible en tus respuestas o notas. No la necesitamos para enseñarte.

## 4. Cómo la usamos

Usamos tu información para:

- ofrecerte el curso y permitirte iniciar sesión;
- registrar tu progreso y mostrártelo a ti y a tu docente;
- darte comentarios;
- mantener las cuentas seguras y evitar el uso indebido;
- responder tus preguntas y atender tus solicitudes; y
- cumplir la ley.

No vendemos tu información. No la compartimos con fines publicitarios. No mostramos anuncios y no usamos herramientas de analítica ni de rastreo.

Correo electrónico: el sitio en sí no envía correos [CONFIRM: proveedor de correo, si lo hay]. Tu docente puede comunicarse contigo sobre tu curso. Si algún día enviamos correo promocional, incluirá una forma de dejar de recibirlo.

## 5. Con quién la compartimos

Tu docente puede ver los datos de tu cuenta, tu progreso, tus respuestas y las notas que envías. Las notas y las sugerencias de temas las ven tú, tu docente y la persona que mantiene el sitio para nosotros (consulta la sección 8).

Usamos estos proveedores de servicios para operar el sitio:

| Proveedor | Qué hace | Qué recibe |
|---|---|---|
| Netlify | Aloja el sitio y entrega sus páginas | Datos de la solicitud, como tu dirección IP, la dirección de la página y el tipo de navegador |
| Supabase | Ofrece nuestra base de datos, el inicio de sesión y las funciones del servidor | Los datos de tu cuenta y de tu curso, además de la dirección IP y el tipo de navegador en sus registros |
| [UNTIL fonts are self-hosted: Google Fonts] | Ofrece las tipografías que usa el sitio | Tu dirección IP, la dirección de la página, el tipo de navegador y la página desde la que llegaste. No coloca cookies. Google actúa como receptor independiente según su propia política de privacidad |
| Un servidor de logotipo elegido por tu docente (solo si el logotipo está alojado en otro lugar) | Ofrece la imagen del logotipo | Tu dirección IP y el tipo de navegador cuando se carga una página con sesión iniciada |

Nuestros proveedores usan sus propios subproveedores, como empresas de infraestructura en la nube, para prestar sus servicios.

Podemos revelar información si la ley lo exige o para proteger los derechos, la propiedad o la seguridad de nuestros estudiantes, de nosotros o de otras personas.

## 6. Dónde se almacena tu información

Tus registros se almacenan con Supabase en [CONFIRM: región del proyecto de Supabase]. [CONFIRM que la región está en Estados Unidos; si es así, conservar:] Nuestros proveedores procesan los datos en Estados Unidos. Si usas el sitio desde fuera de Estados Unidos, tu información se procesará en Estados Unidos.

## 7. Cuánto tiempo la conservamos

Conservamos los registros de tu cuenta y de tu aprendizaje mientras tengas acceso al curso y hasta [CONFIRM: meses de conservación, por defecto 12] meses después de que termine tu último curso. Tu docente revisa las cuentas al menos una vez al año y elimina las cuentas cuyo último curso terminó hace más de [CONFIRM: meses de conservación, por defecto 12] meses. Las eliminamos antes si lo pides (consulta la sección 9).

El registro de actividad del curso puede permanecer después de que se elimine tu cuenta, sin tu identidad. Aun así, puede contener números de referencia internos de elementos del curso.

Nuestros proveedores guardan registros técnicos durante periodos breves que dependen de su plan, actualmente alrededor de [CONFIRM: ventana de registros del plan de Supabase] en Supabase y [CONFIRM: ventana de registros del plan de Netlify] en Netlify. Los datos de los registros, como las direcciones IP, pueden identificarte, y los tratamos como información personal.

## 8. Cómo la protegemos

Usamos conexiones cifradas (HTTPS), guardamos las contraseñas mediante hash y aplicamos reglas de acceso a la base de datos según el rol. El acceso a tu información en el sitio se limita a ti, a tu docente y a la persona que mantiene el sitio para nosotros, además de nuestros proveedores de servicios según se describe en la sección 5. Por favor, mantén tu contraseña en privado.

Ningún sistema es perfectamente seguro y no podemos garantizar la seguridad de tu información. Si una brecha de seguridad afecta tu información, te lo notificaremos según lo exija la ley aplicable.

## 9. Tus opciones y solicitudes

Puedes pedirnos que te digamos qué información tenemos sobre ti, que la corrijamos o que la eliminemos. Escribe a {{privacy_contact_email}} desde el correo electrónico de tu cuenta (o pide a tu docente que confirme tu identidad). Responderemos en un plazo de 30 días.

- Eliminación: tu docente elimina tu cuenta, lo que borra tus inscripciones, progreso, respuestas, intentos de cuestionarios, comentarios y pertenencia a grupos. Podemos conservar información cuando la ley lo exija. La información eliminada puede permanecer durante un tiempo limitado en las copias de seguridad y los registros de nuestros proveedores, hasta que caduquen [CONFIRM: retención de copias de seguridad de Supabase para el plan del proyecto].
- Acceso: tu docente puede darte una copia de la información que tiene disponible mediante las herramientas del sitio. El sitio no tiene un archivo de exportación ni una descarga de autoservicio, y los registros técnicos de nuestros proveedores no están totalmente a nuestra disposición.
- Corrección: puedes editar tus propias respuestas de las lecciones mientras sean borradores. Pregunta a tu docente por otras correcciones, como restablecer la finalización de una lección. El correo electrónico de tu cuenta no se puede cambiar en el sitio por ahora. Si necesita cambiar, contáctanos. Tu docente puede cerrar tu cuenta y crear una nueva con el correo correcto, pero los registros del curso de la cuenta anterior no se trasladan. [IF D-P17 Option B is adopted: reemplazar las tres últimas oraciones por "Contáctanos y podemos actualizarlo."]
- Almacenamiento del navegador: puedes borrarlo en cualquier momento (consulta la sección 10).

## 10. Cookies y almacenamiento del navegador

No usamos cookies ni cookies de rastreo, y nuestras páginas no colocan cookies [CONFIRM: sin cookies de Netlify ni de Supabase]. El sitio guarda tres elementos en el almacenamiento local de tu navegador:

| Nombre | Para qué sirve | Cuánto dura | Cómo borrarlo |
|---|---|---|---|
| `lizbeth.siteLanguage` | Recuerda si elegiste inglés o español | Hasta que lo borres | Borra los datos del sitio en la configuración de tu navegador |
| `lizbeth-accessibility-settings` | Recuerda el tamaño del texto, la tipografía, el interlineado, el espaciado entre letras y el ancho de línea | Hasta que lo borres | Borra los datos del sitio en la configuración de tu navegador |
| `sb-[CONFIRM: referencia del proyecto]-auth-token` | Mantiene tu sesión iniciada | Hasta que cierres sesión o lo borres | Cierra sesión o borra los datos del sitio en la configuración de tu navegador |

Estos elementos permanecen en tu dispositivo. No los usamos para rastrearte.

## 11. No rastrear

Algunos navegadores envían señales de "No rastrear" o de Control Global de Privacidad. No te rastreamos en otros sitios web ni servicios, así que respondemos a estas señales igual que con cualquier visitante. No usamos herramientas de analítica, publicidad ni rastreo entre sitios. [UNTIL fonts are self-hosted: Google Fonts y] un servidor de logotipo elegido por tu docente reciben datos estándar de la solicitud (tu dirección IP, el tipo de navegador y la dirección de la página) cuando tu navegador carga archivos desde ellos. [UNTIL fonts are self-hosted: Google afirma que Google Fonts no coloca cookies ni usa estos datos para crear perfiles o dirigir anuncios. Google no indica cuánto tiempo conserva los datos.]

## 12. Menores de edad

Este sitio es para personas de 18 años o más. No recopilamos a sabiendas información de nadie menor de 18 años. Si nos enteramos de que una cuenta pertenece a una persona menor de 18 años, la eliminaremos. Si crees que esto ha ocurrido, contáctanos en {{privacy_contact_email}}.

## 13. Cambios a esta política

Cuando cambiemos esta política, actualizaremos el número de versión y la fecha de vigencia en la parte superior de esta página. Antes de que un cambio importante entre en vigor, tu docente avisará directamente a los estudiantes inscritos, por ejemplo por correo electrónico. No usaremos de una manera sustancialmente distinta la información que ya hayamos recopilado sin avisarte antes y, cuando la ley lo exija, sin obtener tu consentimiento.

## 14. Versiones en otros idiomas

Esta política está disponible en inglés y en español, con la misma versión y fecha de vigencia. Si hay alguna diferencia entre las versiones, prevalece la versión en inglés, salvo que la ley aplicable disponga otra cosa. Si quieres que te expliquemos algo en español, contáctanos en {{privacy_contact_email}}.

---

## 9. Implementation plan

### 9.1 Architecture (recommended, subject to D-P2 and D-P3)

- Policy body: a code-owned, versioned typed content model (for example `src/content/privacyPolicy/{en,es}.ts` or one structured source holding both languages) with headings, paragraphs, lists, tables, inline links, and slot tokens for the four owner variables. Constants `PRIVACY_POLICY_VERSION` and `PRIVACY_POLICY_LAST_UPDATED`. English is canonical.
- The body is not stored in `site_content` because of its length and allowlist limits and the need for accuracy and translation parity. This matches the #208 D-21 hybrid rule: legal and functional text is fixed and translated, not owner-editable.
- Owner-editable: four variables only.

### 9.2 Interfaces and data

| Item | Specification |
|---|---|
| New `owner_settings` columns (all nullable) | `privacy_legal_name text` (max 120); `privacy_contact_email text` (max 254, format check); `privacy_mailing_address text` (max 300, max 5 lines); `privacy_effective_date date`. Publication columns (REV2): `privacy_policy_published_at timestamptz` (null means not published) and `privacy_policy_published_version text`. A DB CHECK constraint requires `privacy_policy_published_at IS NULL OR` (all four detail variables are non-null and non-blank AND `privacy_policy_published_version` is non-null). |
| Public view | New SELECT-only view `public.public_privacy_details` exposing exactly those four columns plus the two publication columns (six in total; singleton), SELECT granted to `anon` and `authenticated`, following the `public_site_content` pattern (`202610040001:53-60`). `owner_settings` itself stays authenticated-only. |
| Migration | Name `YYYYMMDDNNNN_<issue>_privacy_details.sql`, dated after the latest migration at Step 0. |
| Rollback | `supabase/rollbacks/<issue>_privacy_details_rollback.sql`: drop the CHECK constraint, the two publication columns, the four detail columns, and the view (including its columns). Forward-only, issue176 precedent. |
| Validation module | `src/lib/ownerSettingsAuthorization.ts`: email, date, lengths, no control or bidi characters, reject `{{` and `}}`. |
| Edge | The owner-settings Edge function accepts the new fields and adds actions (REV2). **Publish:** owner claim required (403 otherwise); requires all four SAVED variables valid; requires the requested version to equal `PRIVACY_POLICY_VERSION`; a mismatch returns 409 `stale_policy_version`; incomplete or invalid returns 422 with field errors; success sets `published_at = now()` and `published_version`. **Unpublish:** owner only; nulls both columns. **Save while published:** any empty or invalid value of the four fields returns 422 field errors ("Required while the privacy policy is published."). This requires an owner-settings Edge redeploy (hosted step). |
| Shared version module | `PRIVACY_POLICY_VERSION` lives in one shared module imported by both the frontend and the Edge function (single source, to avoid deploy skew). Changing it therefore requires both a Netlify deploy and an owner-settings Edge redeploy (recorded in Step 8 and risk R9). |
| Client read | `src/services/privacyDetailsData.ts` reads the view with the anon client, never throws, returns nulls on failure. |
| Registry | No `site_content` registry keys are required, so no site-content Edge redeploy. UI chrome strings are code-owned EN/ES. |
| Compatibility | Existing `owner_settings` readers are unaffected. `BrandingProvider` unchanged. No change to `LoginForm`, `AuthBrandPanel`, or `SiteContentGroups`. |

### 9.3 Routing

- Custom `useRoute`. Anonymous routes today are only `/courses` and `/courses/:id` (short-circuit at `src/App.tsx:725-727`); others show sign-in (`:788-803`).
- Add `/privacy` and `/privacy/`: an AuthGate branch beside the `/courses` short-circuit renders an anonymous frame (catalog-style header with the existing `LanguageToggle` and Sign in button, plus the catalog footer). In `AuthenticatedApp`, an `isPrivacyRoute` check before the Roadmap fallback (`:583-624`) shows the page inside the shell. A signed-in direct load falls through to the shell after the session resolves and re-runs focus and hash handling (design item U1).
- Publication state (REV2): one hook, `usePrivacyPublication()`, makes one fetch per page and returns `not_published`, `published_current`, or `published_stale`. It fails closed: a pending fetch, an error, or a timeout (AbortController, about 8 s) counts as `not_published` for links and for non-owner `/privacy`. While pending, `<main>` shows the existing `<p role="status">Loading…</p>` pattern (`App.tsx:735-737`). Focus goes to the `h1` only after the state resolves, and hash handling re-runs.

### 9.4 Page design summary (reviewed design handoff REV1 "Field Workbook reading sheet")

Design route: profile compact (design-generalist plus design-reviewer, Sonnet). Prototype forbidden. Existing system mode: preserve. Reasons: brownfield UI in the Field Workbook system, one long-form public page, link placements, one settings fieldset.

- DOM order: `h1` "Privacy policy"; meta `<dl>` (Effective date, Last updated, Version); `PolicyLanguageSwitch` (local component, group aria-label "Policy language" / "Idioma de la política", buttons "Read in English" `lang=en` and "Leer en español" `lang=es`, `aria-pressed`, same `useSiteLanguage().setLanguage`; the header `LanguageToggle` is unchanged; focus stays on the activated control); an owner-only gap note (`lang="en"`, `role=note`, links to `/admin/business-settings`, shown only when any variable is empty; replaced by the REV2 preview and stale banners); Summary card `h2` "The short version" (5 to 7 bullets); `nav` "On this page" (ordered list of all `h2`s); an article with `lang` and the 14 `h2` sections in the order of section 6.1. English slugs are used for ids in both languages. The table of contents focuses the target `h2`, scrolls instantly, and uses `history.replaceState` for the hash.
- PrivacyLink component on four surfaces: sign-in plate, catalog footer, authenticated footer (including `/admin`). Labels: EN "Privacy policy"; ES "Política de privacidad (Privacy policy)" with the parenthetical in `<span lang="en">`. The accessible name must contain the literal "Privacy" in both languages (CalOPPA M8). REV1 rendered footers unconditionally; REV2 supersedes that (links and footer elements render only when the policy is published, see the REV2 block below). Links are Source Sans 3, body size, normal case, underlined, brass.700 (`color.link.text`) on light grounds only, with targets of at least 44px.
- Sign-in plate: `PublicLegalLinks`, a paper.50 plate with a 1px ink-1000 border, the final child of `.auth-card-panel` in both sign-in branches (`App.tsx:766`, `:797`). The wrapper gets the modifier class `auth-card-panel--legal`, defined only in the new privacy CSS file (at 56.25rem and wider: `flex-direction:column; gap: var(--space-5)`; centering kept). The plate sits below the card at every width. `LoginForm.css`, `LoginForm`, and `AuthBrandPanel` are untouched. PR #229 survival rule: if #229 moves the wrapper, render the plate as the final child of whatever wraps the sign-in card.
- Layout: at 1100px and wider, two columns (14rem sticky TOC rail plus a reading column at max `var(--measure)`); single column below. Gutters space-6 (space-4 at 360px and narrower). Tables are semantic at 40rem and wider; below 40rem they stack with ARIA roles and `data-label` column names and no horizontal overflow. Respect `--measure`, `--text-size-multiplier`, and `--line-height`. No horizontal scroll at 390 or 320 even at maximum text settings. Print stylesheet hides chrome, TOC, and controls, renders black on white, and keeps effective date, version, and contact.
- Typography and color: existing Field Journal tokens only (Fraunces `h1` signinLg/signinSm, `h2` displayTitle/headingMobile; Source Sans 3 body; IBM Plex Mono labels; ink-900 text, ink-700 muted; paper.100 cards; paper-200 table header). Component alias tokens only, no new primitives. Forced-colors rules. No motion. `scroll-behavior` is not smooth.
- Fallbacks (exact strings; under REV2 shown in the owner preview only):
  - Name empty: EN "the instructor who runs this site"; ES "la persona que imparte este sitio" (design U2: owner call versus `brand_name`; D-P11).
  - Email empty: EN "A privacy contact email has not been published yet. If you are a student, ask your instructor directly."; ES "Todavía no se ha publicado un correo electrónico de contacto de privacidad. Si eres estudiante, consulta directamente con tu docente." (no mailto).
  - Address empty: EN "A mailing address has not been published yet."; ES "Todavía no se ha publicado una dirección postal."
  - Date empty: "Effective date: not yet set" / "Fecha de vigencia: aún no establecida". Date filled: `Intl.DateTimeFormat(lang,{dateStyle:'long',timeZone:'UTC'})`.
  - A mailto link is produced only from a validated email. Substitution uses structured slots. A final guard replaces any surviving `{{...}}`. Owner values are never markup; no `dangerouslySetInnerHTML`.
- Title: `document.title` is "{page title} - {wordmark}" from `site_content` `brand.wordmark` (whitespace-collapsed; fallback "Lizbeth Spanish" when empty or hidden). The public view is not widened for `brand_name`.
- Business settings: a fieldset with the legend "Privacy policy details" after the IP notice field (`BusinessSettingsPage.tsx:73`) and before `<SiteContentGroups>` (`:74`). Fields: "Legal or business name"; "Privacy contact email"; "Mailing address or city and state" (textarea, rows 3); "Policy effective date" (`type=date`). Helper text: "These details fill the blanks in the public privacy policy. Leave a field empty and the policy shows a neutral fallback." Validation messages: "Enter a valid email address, for example name@example.com." / "Enter a valid date." / "Too long (maximum N characters)." / "Remove curly-brace placeholders." A completeness paragraph reads "Privacy policy details: 2 of 4 set. Not set: …" or "all 4 set." (ink-900, not live). A link "View privacy policy (opens in a new tab)" has the helper "The page shows saved details. Save first to see your changes." The pending-count expression (`:38-40`) is extended. The block coexists with PR #232 as a sibling.
- Contrast: per-surface pair assertions (plate brass.700 on paper.50 at 5.648; catalog footer and `.app-footer` resolved grounds; body links on paper.50/100/200) in a new test beside `src/__tests__/statusColorContrast.test.ts`. If a pair fails, change the ground, not the link color.

### 9.4a REV2 (publish gate)

REV2 keeps all of REV1 and adds an enforced publication state (J-002). Summary of the reviewed design:

- States: `not_published`, `published_current`, `published_stale`, read by `usePrivacyPublication()` (section 9.3). Fail closed.
- Links: the sign-in plate, catalog footer, authenticated footer, and `/admin` footer render null unless published. A hidden plate renders no DOM and leaves no gap, and the sign-in card matches the baseline layout. Footers render only elements that have content.
- Non-owners before publish see a "being prepared" page: an `h1` and one paragraph. EN "Our privacy policy is being prepared and will be posted here soon. Questions? Ask your instructor." ES "Nuestra política de privacidad se está preparando y se publicará aquí pronto. ¿Preguntas? Consulta con tu docente." It has no fallbacks, TOC, or body, and it is not a 404. Public fallbacks are therefore never visible to non-owners.
- The owner sees a full preview with a banner (`lang=en`, `role=note`, not live): "Preview: not published. Students and visitors see a "being prepared" message until you publish from Business settings." When stale, the owner instead sees: "Policy text updated to version {X}. Review the effective date and re-confirm publication in Business settings." One banner shows at a time, and it replaces the REV1 owner gap note.
- Business settings "Publication" sub-area (an `h3` inside the fieldset):
  - Status line `#privacy-publish-status` (tabindex -1): "Status: Not published" / "Status: Published on {date} (version {X})" / the stale variant.
  - An enabled "Publish privacy policy…" secondary button that validates on click: unsaved changes show "Save your changes before publishing."; incomplete shows "Save all four details before publishing. Not set: {list}." with focus on the first empty field. Helper text is always visible.
  - App-owned Modal "Publish privacy policy?": a summary `dl` (version, effective date, name, email) and a required checkbox "A licensed attorney has reviewed policy version {X}, and the review is recorded in the pull request that introduced it." Publish stays disabled until the box is checked. The checkbox and label share one `<label>` with min-height 44px. Rejections map to fixed copy (stale version, incomplete, not owner, network), never raw text.
  - "Unpublish…" opens the Modal "Unpublish privacy policy?" with no checkbox.
  - Success announces "Privacy policy published." / "Privacy policy unpublished." through `role=status`.
  - Save while published shows the field error "Required while the privacy policy is published.", focuses the first invalid field, and the value is unchanged after reload. The client mirrors the check; the server is authoritative.
  - Editing the effective date while published is allowed without re-publishing.
- Engineering invariants from review items R2-1 to R2-4:
  - Pass `triggerElement` to every Modal.
  - Move focus to `#privacy-publish-status` in a `useEffect` that runs after the modal closes and the focus-trap cleanup has run (`useFocusTrap.ts:170-181` otherwise returns focus to the trigger).
  - Render Publish and Unpublish as distinct keyed elements.
  - Mount both Modals as siblings after `</form>` (`BusinessSettingsPage.tsx:70`).
  - All buttons are `type="button"`.
  - Use `suppressDismiss={isPending}` (precedent: `AdminStudentModals.tsx`).
  - Initial focus is the dialog container (Modal has no initial-focus prop); the first Tab reaches the checkbox. Do not modify `Modal.tsx` or `useFocusTrap`.
  - Verify focus return in Chromium and in one non-Chromium engine if available.

### 9.5 Design review result

DESIGN_REVIEW_RESULT: PASS on REV2 (publish gate), which keeps REV1. The REV2 invariants are R2-1 to R2-4 in section 9.4a.

DESIGN_REVIEW_RESULT: PASS on REV1. The first pass returned NEEDS_REVISION with F1 (plate beside card at desktop), F2 (contrast grounds), F3 ("Privacy" word in the ES label), F4 (duplicate `LanguageToggle`), and F5 (title source). All were resolved. Remaining limits:

- N1: wordmark edge cases in the title.
- U1: a flash of the Sign in button on a signed-in direct load.
- Footer ground change risk needs a visual regression check in J2.
- A consistent selected cue for `PolicyLanguageSwitch`.
- TOC rail tab order validation.
- Re-verify line anchors after #229, #231, and #232 merge.

---

## 10. Ordered work and sequencing

| Step | Owner | Depends on | Work | Observable result |
|---|---|---|---|---|
| 0 | Engineering (preflight) | Plan approval | Re-verify `origin/main` against `88b43fd`, the merge state of PRs #229, #231, #232, and line anchors. Record the test baseline per the deep-dive plan section 11.3. Also check that the hosted site and Supabase URLs are https, and whether the owner can view student draft responses (claim audit, section 6.3). | Preflight note with baseline |
| 1 | Orchestrator | User approves the issue text | File the GitHub issue (section 20). | Issue number |
| 2 | User and Lizbeth (no code) | None | Confirm: Supabase region and plan; whether Auth invite or password-reset emails are used and the SMTP provider; hosted `enable_signup`; whether PR #231 adds names; retention period (D-P6); privacy contact email, legal or business name, mailing address; decisions D-P1 to D-P16. | Answers recorded |
| 3 | Scribe | Step 2 | Finalize the English draft and Spanish translation into a review copy for the attorney and Lizbeth (an in-plan appendix update or a companion file under `docs/plans/` in the orchestrator repository). | Review copy |
| 4 | Attorney (external, user-arranged) | Step 3 | A Michigan-licensed attorney reviews the English policy, the Connecticut question, and the breach runbook note. Changes return to Scribe. Lizbeth approves the Spanish text. | Approved text |
| 5 | Engineering PR A | PR #229 merged (preferably #232 too); independent of #231 except names | Implement per section 9 (including the enforced publish gate of REV2) with RED-first tests. Policy constants are transcribed verbatim from the approved text. If Step 4 is not complete, ship the content as DRAFT to a branch or PR only; do not deploy. | PR A against `main` |
| 6 | Engineering PR B (optional per D-P8) | Step 5 or independent | Self-host Google Fonts: remove the `@import` from `App.css:14`, add font files with licenses, tighten CSP `style-src` and `font-src`, and update the policy sharing and storage text in the same PR. | PR B |
| 7 | Owner (post-merge, local or hosted with approval) | Step 5 | Fill the four details, check the preview, and publish through the app-owned Modal after the attorney review is recorded in the PR that introduced the policy version (D-P18). | Status line shows "Published" |
| 8 | Hosted rollout (each separately approved, D-P16) | Steps 4, 5 | Apply the migration; deploy the owner-settings Edge function; Netlify deploy (each separately approved); then the owner publishes. Changing `PRIVACY_POLICY_VERSION` later requires both a Netlify deploy and an owner-settings Edge redeploy. The gate is enforced by the database CHECK constraint, the Edge function, and the fail-closed frontend, not by procedure alone. | Policy live only after owner publish |
| 9 | Ongoing | Step 8 | Policy-practice parity review whenever data practices change (names PR, fonts, new vendors, emails). Bump version and effective date; notify students of material changes. | Updated policy |

Dependencies: after PR #229 merges (sign-in surface); preferably after PR #232 merges (Business settings page); PR #231 matters only for names (D-P13). Deep-dive plan Wave 6 copy-registry work (#208 hybrid) does not conflict because this feature adds no registry keys. Section 15.4 of the deep-dive plan points to this separate workstream.

## 11. Acceptance and validation

### 11.1 Per PR

- Step 0 preflight.
- `npm ci`; `npm run type-check`; `npm run lint` (0 errors); `npm run verify:build`.
- Full `npx vitest run` on a freshly reset local stack with no new failures against the recorded baseline.
- A RED test shown failing before the fix and passing after.
- Verifier PASS; Browser Validator PASS.
- PR against `main` with "Closes #<issue>"; no merge.

### 11.2 Tests (RED-first)

- SQL: anon can SELECT `public_privacy_details` (exactly 4 columns) but not `owner_settings`; authenticated the same; the service-role write path works; rollback parity.
- Edge and unit: owner-settings accepts valid fields and rejects invalid email, date, length, and braces; the non-owner 403 is unchanged.
- Unit: substitution for all 16 empty and filled combinations of the four variables never renders `{{`; mailto only from a valid email; date formatting is UTC in EN and ES; EN/ES content parity (same section ids, same version, same table row counts).
- Inventory-parity guard tests: (a) every `localStorage` key written in `src` appears in the policy storage table and vice versa; (b) every third-party origin in the `index.html` CSP `style-src` and `font-src` and the `App.css` `@import` is named in the policy sharing section.
- Contrast test pairs (section 9.4).
- Component tests: PrivacyLink accessible name contains "Privacy" in EN and ES when published; settings fieldset pending count, validation, and focus.
- Publish gate, SQL (RED-first): the CHECK rejects publish with any empty or blank field and rejects clearing a field while published; the anon view exposes exactly the 4 variables plus the 2 publication columns; `owner_settings` stays non-anon; rollback parity.
- Publish gate, Edge (RED-first): publish with incomplete details returns 422; `stale_policy_version` returns 409; non-owner returns 403; success sets both columns; unpublish works; save-while-published that clears a field returns 422; a direct client-bypass request is rejected.
- Publish gate, unit and component (RED-first):
  - links render null when the state is `not_published`, pending, error, or timeout;
  - the being-prepared page renders for non-owners with no `{{` and no fallbacks;
  - owner preview and stale banners;
  - publish pre-checks;
  - modal checkbox gating;
  - focus lands on `#privacy-publish-status` after the modal closes;
  - both modals mount outside the form and all buttons are `type="button"`;
  - mapped rejection copy.
- A test that `PRIVACY_POLICY_VERSION` is one shared module used by both the frontend and the Edge function.

### 11.3 Legal-content acceptance checklist

Each row maps to a policy section; Scribe or the reviewer ticks it against the approved text.

| Check | Section | Done |
|---|---|---|
| M1 categories collected | 3 | [ ] |
| M2 third-party categories | 5 | [ ] |
| M3 review and change process | 9 | [ ] |
| M4 notification of changes | 13 | [ ] |
| M5 effective date | meta list, 13 | [ ] |
| M6 Do Not Track | 11 | [ ] |
| M7 other-party cross-site collection | 11, 5 | [ ] |
| M8 conspicuous "Privacy" link on sign-in, catalog footer, authenticated footer | link surfaces | [ ] |
| M9 accuracy (parity tests green; every [CONFIRM] resolved; claim audit in section 6.3 has no row left at "Requires confirmation") | all | [ ] |
| Launch gate enforced (CHECK constraint, Edge publish action, fail-closed links; attorney review recorded in the PR that introduced the version) | 9.2, 9.4a | [ ] |
| R1 to R11 | per section 6.2 | [ ] |
| GDPR Art. 13-style floor items per D-P1 | 1, 4, 5, 6, 7, 9 | [ ] |

### 11.4 No-native-dialog scan

```text
rg -n "\b(window\.)?(alert|confirm|prompt)\s*\(|beforeunload" src --glob "!src/__tests__/**"
```

Zero product hits, plus a failing `page.on('dialog')` listener in the new e2e spec.

## 12. Browser UI dialog policy and validation inputs

### 12.1 Dialog policy (required)

No `alert`, `confirm`, `prompt`, `window.alert`, `window.confirm`, `window.prompt`, or `beforeunload`. `/privacy` has no dialog. Business settings adds no unsaved-changes prompt (the existing inline pending count only). Any future confirmation uses the app-owned Modal (`src/components/Modal.tsx`) with Escape/Close and focus return; inline validation is preferred. Verification: the deterministic scan above, a runtime `page.on('dialog')` listener, and keyboard and focus checks (no modal touched in this scope).

### 12.2 `browser_ui_validation`

- Launch and readiness (port-shifted local Supabase mirror 643xx; Windows reserves 54314-54413; mirror `.env.local` points to `http://127.0.0.1:64321`; per-file copies, never `robocopy /MIR`; new Edge function files need a full `supabase stop/start`):

```text
npx supabase start
npx supabase db reset
docker restart supabase_kong_lizbeth_spanish supabase_rest_lizbeth_spanish supabase_edge_runtime_lizbeth_spanish   (first request may 502)
npx vite --port 5180 --strictPort    (ready when http://localhost:5180 serves sign-in)
E2E_BASE_URL=http://localhost:5180 npx playwright test    (workers 1, chromium)
```

  Exact mirror procedure: `docs/plans/lizbeth-spanish-issue228-create-and-assign.md` section 10.1.
- Base URL: `http://localhost:5180`.
- Reset and fixtures: `db reset` plus seed, then the docker restart. Accounts `owner@test.local` and `student1@test.local` (password "password"). Fixture A: all four variables empty. Fixture B: all filled with a multiline address. Fixture C: invalid stored email (seeded via service role). Fixture D: all four set, `not_published`. Fixture E: `published_current`. Fixture F: `published_stale` (an old published version). Fixture G: one field cleared, `not_published`. Restore A/B and English language after each owner save.
- Viewports: 1440x900 and 390x844; 320 spot-check; forced-colors spot checks.
- Evidence screenshots under `browser-validation-artifacts/<issue>/`.

### 12.3 Journeys

- J1: anonymous sign-in plate link opens `/privacy` with the `h1` focused. The plate sits below the card at 1440 in both the sign-in and session-error branches. The accessible name contains "Privacy" in EN and ES.
- J2: catalog `/courses` and `/courses/:id` footer link (normal-case body text, 44px, visual regression on the footer ground).
- J3: student and owner footer link inside the shell, including from `/admin`.
- J4: keyboard-only, including the skip link and TOC focus.
- J5: language via `PolicyLanguageSwitch` and the header toggle; full Spanish; governing note; same date and version; `html lang` is `es`; title "Política de privacidad - Lizbeth Spanish".
- J6: owner settings invalid email and date show inline errors; focus goes to the first invalid field; save shows "Business settings saved."; the view link shows saved values.
- J7: fixture A shows fallbacks, no mailto, no `{{` in the owner preview only; non-owners must never see fallbacks. The preview banner (`lang` en) is visible only to the owner.
- J8: a blocked variables request shows fallbacks and no error UI.
- J9: accessibility extremes produce no horizontal scroll.
- J10: print emulation.
- J11: a signed-in direct load of `/privacy#cookies-and-browser-storage` focuses that `h2` after the frame swap; with no hash it focuses the `h1`.
- J12: stacked-table accessibility tree at 390 and 320.
- J1 to J6 and J9 to J12 run against a published fixture (E) unless stated. J2 and J3 footer links appear only when published.
- J13 (pre-publish public): no links anywhere; the sign-in plate is absent; the card layout matches the baseline at 1440, 390, and 320; the being-prepared page appears in EN and ES; the page fails closed when the variables request is blocked AND when it hangs (timeout).
- J14: owner preview banner.
- J15 (publish flow): pre-checks, Tab trap, checkbox gating, Escape/Cancel/Close focus return, success focus on `#privacy-publish-status`, and a new anonymous context then sees links with "Privacy" in the accessible name and the plate below the card at 1440.
- J16: clear each field while published, plus an invalid email, plus a client-bypass server rejection that shows mapped copy.
- J17: stale banner (owner only), re-confirm, and the stale-version rejection message.
- J18: unpublish, then links are gone and the being-prepared page shows in a new context.
- J19: responsive behavior at 390 and 320.
- J20: forced colors and extended contrast pairs (banner, status line, modal text, links, and errors on the Modal ground).
- On every modal open, assert `role=dialog`, `aria-modal`, `aria-labelledby`, focus inside, the Tab trap, Escape, and focus return. Keep the `page.on('dialog')` listener on every journey.

Visible outcomes: link underlined, at least 4.5:1 on its actual ground, at least 44px, contains "Privacy"; one `h1`; TOC focus and hash; `scrollWidth <= clientWidth` at 390 and 320; prose width equals `--measure` at 1440; forced-colors borders, links, and focus visible.

## 13. Judge route

- `PLAN_DUCK`: eligible after the Scribe draft (legal content is high-stakes). Advisory and shadow policy per `docs/JUDGE-CONTRACT.md`.
- `CODE_REVIEW` on PR A, focused on the anon view exposure and the validation module.
- `VISUAL_REVIEW`: optional.
- Call cap: within the contract's per-plan cap. Rubric IDs are assigned by the orchestrator at dispatch under that contract; none are selected here.
- Finding IDs flow into the plan record, then into the engineering job brief and the Verifier's checklist. Deterministic failures dominate any judge result. No live Codex smoke call occurs without explicit usage approval. 

Judge findings recorded (PLAN_DUCK, revision R1, one-time):

| Finding | Summary | Disposition |
|---|---|---|
| J-001 | The draft promised teacher email correction, but the product has no owner-driven student email change (only an operator procedure exists), and other policy claims were not audited against evidence. | Addressed: D-P17 added (Option A recommended); every correction promise rewritten in EN and ES (section 9, M3 row, D-P7, Appendix B.1); new claim audit (section 6.3) with matching text edits (sign-up, access limits, retention, deletion qualifier, access copy, Do Not Track). |
| J-002 | The launch gate was procedural only. | Addressed: enforced publish gate (REV2, design PASS) with DB CHECK, Edge publish/unpublish actions, fail-closed frontend, and owner Modal attestation; D-P18 to D-P20 added; Step 5 to Step 8, R3, section 11, section 17, section 18, and the issue body updated. |

No other judge finding has been observed.

## 14. Risks and rollback

| Id | Risk | Containment |
|---|---|---|
| R1 | Inaccurate policy (FTC section 5, MCPA) | Inventory-parity tests; Step 9 review triggers; stale-plan triggers. |
| R2 | Anon exposure of `owner_settings` | The view exposes exactly four intended-public columns; SQL tests assert `owner_settings` stays non-anon; rollback drops the view and columns. |
| R3 | Publishing before attorney review, or with fallbacks | Enforced launch gate (REV2): DB CHECK, Edge publish action requiring all four saved variables, fail-closed frontend, owner Modal with attorney attestation, PR checklist item "Attorney review of policy version X recorded (reviewer, date)"; hosted deploys separately approved. Residual: the attestation is self-declared by the owner. |
| R4 | Conflicts with PR #229 (sign-in) and #232 (Business settings) | Sequencing after merges; design survival rules; Step 0 re-verify. |
| R5 | Translation divergence | Content parity test; "English controls" clause; Lizbeth approval. |
| R6 | Policy promises unsupported operations (deletion window, retention) | Operational runbook for the owner (Appendix B); no automated-purge claims. |
| R7 | Credential breach with multi-state notice | Short incident runbook (Appendix B); attorney review. |
| R8 | Footer contrast or ground change alters the look | Visual regression in J2. |
| R9 | Version skew: `PRIVACY_POLICY_VERSION` changes in the frontend but not in the Edge function (or the reverse), so publish returns 409 or a stale banner shows wrongly | One shared version module; a test that both sides import it; Step 8 requires a Netlify deploy and an owner-settings Edge redeploy together. |
| R10 | Product cannot honor a policy promise (email change, export, retention automation) | Claim audit (section 6.3); text qualified in R1; owner practice items in Appendix B; D-P17. |

Rollback: PR revert for UI; the migration rollback file; Edge redeploy of the previous version; the policy page can be hidden by reverting routes (no data loss).

---

## 15. Decisions

Each requires an explicit user answer. None has a silent default.

| Id | Decision | Options | Recommendation | Needs explicit answer |
|---|---|---|---|---|
| D-P1 | Student geography and foreign-law stance | A: US-focused policy that voluntarily meets the GDPR Art. 13 content list (purposes, recipients, retention, rights, contact), states the service is for adult learners in the United States, and does not claim GDPR compliance. B: full GDPR/UK readiness now (representatives, records). C: decline non-US residents. | **A.** B is disproportionate. Before knowingly accepting a non-US resident, re-evaluate (EU/UK representative, addendum with a supervisory-authority complaint right). | Yes |
| D-P2 | Owner-editable scope | Variables only; or full-text owner editing | **Variables only** (legal or business name, privacy contact email, mailing address, effective date). Body is code-owned and versioned, changed through reviewed PRs. Full-text editing is rejected for accuracy risk, translation parity, and length limits. | Yes |
| D-P3 | Variable storage | New `owner_settings` columns plus SELECT-only anon view; or four `site_content` keys | **Columns plus view `public_privacy_details`** (typed validation; consistent with deep-dive D-19). `site_content` keys avoid a migration but are untyped, bilingual-shaped, and need a site-content Edge redeploy. | Yes |
| D-P4 | First-login acknowledgement | None; or blocking gate | **None.** The US notice regime requires conspicuous posting, not assent, and a gate adds friction without current legal benefit. Use the conspicuous sign-in link. Revisit if Terms with clickwrap are added or if D-P1 scenario S2 arises. | Yes |
| D-P5 | Attorney review | Mandatory; or skip | **Mandatory** Michigan-licensed attorney review of the English policy, the Connecticut sensitive-data question, and the breach runbook before publication (launch gate). | Yes |
| D-P6 | Retention | 12 months after last course end; other period | **Account and learning records kept while the student has course access and for up to 12 months after the last course ends, then deleted by the teacher; earlier on request.** Activity-log rows remain with identity removed after account deletion; vendor logs follow vendor windows ([CONFIRM: plan]). The owner confirms the 12-month figure. Follow-up candidate: an owner "inactive accounts" report (no automated purge promised). | Yes |
| D-P7 | Access, correction, deletion request process | As below; or build self-service | **Requests by email to the privacy contact; verified by coming from the account email (or teacher confirmation); response within 30 days; deletion through the existing owner hard delete; access copy limited to what the teacher can see through the site's tools (no export tool); no promise of teacher email correction (see D-P17).** Follow-up candidate: student data export. | Yes |
| D-P8 | Google Fonts | Self-host (PR B); or keep and disclose | **Self-host**, so no third party receives visitor IPs. Until PR B merges, the policy discloses Google Fonts. | Yes |
| D-P9 | Owner logo host | Follow-up restriction; or leave | **Follow-up issue** to restrict the logo URL to the site's own origin or Supabase storage. Until then, disclose that a logo may load from a third-party host the teacher chooses. | Yes |
| D-P10 | Bilingual policy | Full ES version; or English only | **Full Spanish version**, same version and date, "English controls unless applicable law requires otherwise", plus an offer to clarify in Spanish. Scribe drafts the Spanish and Lizbeth approves (D-21 precedent). ES link label "Política de privacidad (Privacy policy)". | Yes |
| D-P11 | Name fallback (design U2) | Neutral phrase; or `brand_name` | **Neutral phrase** over `brand_name`. | Yes |
| D-P12 | Material-change notice | As below | **Update version and effective date; the teacher notifies enrolled students directly (for example by email) before a material change takes effect; no retroactive looser use without consent** (FTC 2024 guidance, P2-S38). | Yes |
| D-P13 | Names from PR #231 | Add "name" if #231 adds names | If #231 merges with name fields, add "name" to the collected categories before publishing (stale trigger). | Yes, when #231's content is known |
| D-P14 | Sensitive-information instruction | Include; or omit | **Include** a policy sentence asking students not to put health or other sensitive personal information in answers or notes (Connecticut mitigation). | Yes |
| D-P15 | File the GitHub issue | File after approval | The user already asked. The text in section 20 is READY TO FILE once the user approves it; the orchestrator files with `gh`. | Yes (approve the text) |
| D-P16 | Hosted rollout | Separate approval per action | **Each hosted action** (migration apply, owner-settings Edge deploy, Netlify deploy) is separately approved (standing D-28). | Yes |

Decisions added in revision R1:

| Id | Decision | Options | Recommendation | Needs explicit answer |
|---|---|---|---|---|
| D-P17 | Student email correction | A (default): the site cannot change an account's email today; on request the teacher can close the account and create a new one under the corrected email, and course records from the old account do not carry over. B: the site administrator (operator) changes the email manually, following the procedure in `docs/evidence/lizbeth-spanish-owner-email-change-20260917.md` (preflight uniqueness check, a single service-role update, verification, a written receipt); records are preserved; use only if the user commits to running the procedure, and if adopted the policy text becomes "contact us and we can update it". C: build an owner-driven change-email action in `admin-student-operations` (owner-claim check, uniqueness check, retype confirmation in the app-owned Modal, activity event, tests) as a follow-up issue. | **A now, C as a follow-up candidate, and B acceptable if the user commits.** A is the smallest truthful option. | Yes |
| D-P18 | Who flips the published state | Owner in Business settings through the app-owned confirmation Modal with the attorney-review attestation checkbox; operator-only through a service-role update; automatic once all four fields are set | **Owner, through the Modal with the attestation, after attorney review is recorded in the PR that introduced the policy version.** Add a PR-template or checklist item: "Attorney review of policy version X recorded (reviewer, date)". Operator-only adds friction. Automatic is rejected because it bypasses review. | Yes |
| D-P19 | Pre-launch behavior | Hidden links plus a neutral being-prepared page for non-owners and a preview for the owner; hide the route entirely (sign-in or 404) until published; show links that point to the being-prepared page | **Hidden links plus the being-prepared page and owner preview.** It never shows unreviewed legal text or placeholder fallbacks publicly, shared links do not 404, and the site does not advertise an empty page. Residual risk: until publish the site still has no posted policy (as today), so publish promptly after review. | Yes |
| D-P20 | Behavior when the code version changes after publish (stale) | Public sees the current code version and the owner sees a stale banner; or auto-unpublish until re-confirmed | **Public sees the current code version**, because text changes ship only through a reviewed PR with attorney review recorded. The owner sees the stale banner, re-confirms, and updates the effective date. Auto-unpublish would hide the policy on every text deploy. Residual: the effective date may lag until the owner updates it. | Yes |

## 16. Assumptions and confirmations

Safe assumptions:

- A1: revenue is under $1M.
- A2: student residence is unknown and may include any US state or abroad.
- A3: the app sends no email today.
- A4: payment is fully off-site and the site receives no card data.
- A5: accounts are teacher-provisioned only.

Confirmations needed (not decisions):

- Supabase project region and plan.
- Whether invite or password-reset emails are used, and the SMTP provider.
- Hosted `enable_signup`. Recommendation: set `enable_signup=false` on hosted (local `supabase/config.toml:188` has it `true`; the policy says the site has no sign-up page).
- Supabase backup retention for the project plan (not researched in P3, UNVERIFIED).
- That hosted site and Supabase URLs are https (Step 0).
- Netlify plan log window. This item was added by Scribe because the Netlify observability window depends on plan; the handoff listed only the Supabase plan.
- Whether PR #231 adds names.
- The 12-month retention figure.
- That no Netlify or Supabase cookies are set (check in a browser).
- The actual Supabase session storage key name (check in a browser).

## 17. Stale-plan conditions

This plan is stale if:

- `origin/main` moves past `88b43fd` with changes to cited files;
- PRs #229, #231, or #232 merge with changes to cited hunks;
- any new data collection, vendor, email sending, cookie, or analytics is added;
- fonts are self-hosted (the policy text changes);
- research facts change (Michigan SB 359 or SB 360-364, Connecticut amendments, Supabase or Netlify terms);
- `Modal.tsx`, `useFocusTrap`, or the owner-settings Edge contract changes;
- a product capability changes that a claim in section 6.3 depends on (for example an owner-driven email change ships, or an export is added).

## 18. Approvals required

- Explicit user approval of this plan.
- Answers to D-P1 to D-P20.
- Attorney review recorded for the policy version in the PR that introduces it, and the owner's attested publish through the Modal (the enforced launch gate).
- Approval of the GitHub issue text before filing.
- Attorney review before publication.
- Lizbeth's approval of the Spanish text and the four variables.
- A separate approval per hosted action.
- No commit to main, merge, deploy, or issue filing without instruction.

## 19. Engineering mode and downstream owner

- Engineering mode: standard (T1 first-line; T2 escalation per fleet rules). No extreme-advisory team. Team authorization: not applicable.
- Downstream owners: engineering fleet (PR A and optional PR B); Scribe (policy finalization and Spanish updates); orchestrator (issue filing after approval).

## 20. Proposed GitHub issue (READY TO FILE after the user approves this text)

**Title:** Privacy policy: public bilingual /privacy page, owner-editable details, and conspicuous links

**Labels (suggested):** enhancement, legal/privacy

**Body:**

```markdown
## Context

Lizbeth Spanish is run by a Michigan-based teacher for adult learners (18 and up). Accounts are teacher-provisioned, and payment happens outside the site. The app has no privacy policy or privacy link today. It stores account email, enrollments, progress, free-text lesson answers (including saved drafts), quiz answers, teacher feedback, student notes, and an activity log. It loads Google Fonts from every page and keeps three items in localStorage.

This is informational research, not legal advice. An attorney must review the policy before it is published.

## Legal drivers (summary of verdicts)

- FTC Act section 5: the policy must match actual practice. Applies.
- CalOPPA, Delaware OPPA, Nevada NRS 603A: required contents and a conspicuous link containing the word "Privacy". Likely apply.
- Michigan breach law and other states' breach laws: apply; keep an incident runbook.
- COPPA, CCPA/CPRA, FERPA, Michigan SOPPA, other comprehensive state laws: do not apply at this scale.
- Questions for the attorney: Connecticut sensitive-data trigger, and the stance toward any non-US resident.

## Requirements

- [ ] Route `/privacy` (and `/privacy/`) works for anonymous and signed-in users, in English and Spanish.
- [ ] Privacy links on the sign-in page, the public catalog footer, and the authenticated footer (including /admin). The accessible name contains "Privacy" in EN and ES.
- [ ] Policy content is code-owned, versioned, and available in EN and ES (Spanish approved by Lizbeth).
- [ ] Four owner variables editable in Business settings ("Privacy policy details"): legal or business name, privacy contact email, mailing address, effective date. Validation and safe fallbacks when empty.
- [ ] Anon SELECT-only view exposing exactly those four columns plus two publication columns; `owner_settings` stays non-anon. Migration plus rollback.
- [ ] Publish gate: persisted published state; DB CHECK and Edge enforcement of the four required fields while published; owner publish and unpublish through an app-owned Modal with an attorney-review attestation; links hidden and a "being prepared" page for non-owners (owner preview) until published; fail-closed frontend; a stale banner for the owner when the policy version changes.
- [ ] Email correction limitation: the site cannot change an account's email today, and the policy must not promise it (decision D-P17).
- [ ] No native browser dialogs; no beforeunload prompts.
- [ ] WCAG 2.2 AA for the page; responsive; print stylesheet.
- [ ] Tests, including inventory-parity guards (localStorage keys and third-party origins versus policy text) and EN/ES parity.
- [ ] Browser validation journeys J1 to J12 in the plan.
- [ ] Attorney review recorded for the policy version, and all four owner variables set and published through the enforced gate, before the policy is public.

## Dependencies

- Start after PR #229 merges; coordinate with #232.
- PR #231 is a stale trigger only if it adds name fields.
- Optional follow-up: self-host Google Fonts (PR B).

## Out of scope

Cookie banner, Terms of Service, rich-text policy editor, self-service deletion or export, any claim of GDPR compliance, hosted deploys (each needs separate approval).

## Plan

`docs/plans/lizbeth-spanish-privacy-policy.md` in the orchestrator repository (a separate repository from this one).
```

---

## Appendix A. Source ledger

Accessed 2026-10-12. Type column: primary and secondary are as tagged in the research handoff. "Official site" means a government or regulator domain whose tag the handoff did not state. "Statute reproduction" means the text of a statute on a non-official site (the official site was blocked). IDs use the handoff's source numbers with the pass prefix (P2 for US-law research, P3 for international and vendor research) because the two passes reuse the same numbers.

| Ledger ID | Source | URL | Type |
|---|---|---|---|
| P2-S1 | FTC privacy and security hub | https://www.ftc.gov/business-guidance/privacy-security | Official site |
| P2-S38 | FTC 2024 blog on quietly changing terms | https://www.ftc.gov/policy/advocacy-research/tech-at-ftc/2024/02/ai-other-companies-quietly-changing-your-terms-service-could-be-unfair-or-deceptive | Official site |
| P2-S3 | FTC CAN-SPAM compliance guide | https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business | Official site |
| P2-S6 | FTC COPPA FAQ | https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions | Official site |
| P2-S5 | FTC January 2025 COPPA release | URL not supplied in handoff | Official site (assumed); COPPA amendment dates via secondary |
| P2-S10 | Davis Wright Tremaine, Michigan | https://www.dwt.com/gcp/states/michigan | Secondary |
| P2-S11 | MCL 445.72 (Michigan Legislature PDF) | https://ombudsman.legislature.mi.gov/documents/mcl/pdf/MCL-445-72.pdf | Primary |
| P2-S8, P2-S9 | Michigan breach-law sources | URLs not supplied in handoff | Unlabeled; sources conflict on cap and notice content (UNVERIFIED) |
| P2-S12 | MCL 445.903 (Justia) | https://law.justia.com/codes/michigan/chapter-445/statute-act-331-of-1976/section-445-903 | Statute reproduction |
| P2-S13 | SB 359 (FastDemocracy) | https://fastdemocracy.com/bill-search/mi/2025-2026/bills/MIB00026983/ | Secondary |
| P2-S14 | SB 359 (LegiScan) | https://legiscan.com/MI/bill/SB0359/2025 | Secondary |
| P2-S15 | Michigan SOPPA (2016 PA 368) | URL not supplied in handoff | Unlabeled |
| P2-S16 | Cal. Bus. & Prof. Code 22575 | https://california.public.law/codes/business_and_professions_code_section_22575 | Statute reproduction |
| P2-S17 | Cal. Bus. & Prof. Code 22577 | https://california.public.law/codes/business_and_professions_code_section_22577 | Statute reproduction |
| P2-S19 | CPPA CPI adjustment | https://www.cppa.ca.gov/regulations/cpi_adjustment.html | Official site |
| P2-S21 | 6 Del. C. chapter 12C | https://delcode.delaware.gov/title6/c012c/index.html | Primary |
| P2-S22 | NRS chapter 603A | https://www.leg.state.nv.us/nrs/nrs-603a.html | Primary |
| P2-S20 | Clym US privacy law comparison map | https://www.clym.io/blog/us-privacy-law-comparison-map | Secondary (thresholds UNVERIFIED) |
| P2-S27 | Tex. Bus. & Com. Code 541.002 | URL not supplied in handoff | Unlabeled |
| P2-S28 | Neb. Rev. Stat. 87-1103 | https://nebraskalegislature.gov/laws/statutes.php?statute=87-1103 | Official site |
| P2-S25, P2-S26 | Hunton, Connecticut amends the CTDPA | https://www.hunton.com/privacy-and-cybersecurity-law-blog/connecticut-amends-the-connecticut-data-privacy-act | Secondary |
| P2-S29 | Student Privacy (FERPA) | https://studentprivacy.ed.gov/ferpa | Official site |
| P2-S30 | ADA web guidance | https://www.ada.gov/resources/web-guidance/ | Official site |
| P2-S31 | NCSL security breach notification laws | https://www.ncsl.org/technology-and-communication/security-breach-notification-laws | Secondary |
| P2-S32 | California breach-law summary | URL not supplied in handoff | Secondary |
| P3-S2 | GDPR Recital 23 | https://gdpr-info.eu/recitals/no-23/ | Unlabeled reproduction site |
| P3-S3 | GDPR Art. 13 | https://gdpr-info.eu/art-13-gdpr/ | Unlabeled reproduction site |
| P3-S1 | GDPR Art. 27 | https://gdpr-info.eu/art-27-gdpr/ | Unlabeled reproduction site |
| P3-S4 | EDPB Guidelines 3/2018 | https://www.edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_3_2018_territorial_scope_after_public_consultation_en_1.pdf | Official site |
| P3-S43 | USAFacts, languages spoken at home (ACS 2024) | https://usafacts.org/answers/how-many-people-speak-a-language-other-than-english-at-home/country/united-states/ | Secondary |
| P3-S6 | UK GDPR Art. 27 | https://www.legislation.gov.uk/eur/2016/679/article/27 | Official site |
| P3-S7 | UK GDPR Art. 3 | https://www.legislation.gov.uk/eur/2016/679/article/3 (URL reconstructed from the handoff's shorthand ".../article/3") | Official site |
| P3-S36 | ICO, what privacy information should we provide | https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/individual-rights/the-right-to-be-informed/what-privacy-information-should-we-provide/ | Official site |
| P3-S30 | IAPP, Globe24h PIPEDA ruling | https://www.iapp.org/news/a/globe24h-pipeda-ruling-should-be-no-surprise | Secondary |
| P3-S31, P3-S29, P3-S32 | OPC PIPEDA-2011-002; privacylawyer.ca; BCLP | URLs not supplied in handoff | Secondary (Lawson v. Accusearch cited via secondary) |
| P3-S33 | Mexico LFPDPPP (GT Law, Hunton, diputados.gob.mx) | URLs not supplied in handoff | Secondary / official; territorial article UNVERIFIED |
| P3-S9 | UK PECR Schedule A1 | https://www.legislation.gov.uk/uksi/2003/2426/schedule/A1 | Official site |
| P3-S11 | EDPB Guidelines 2/2023 | URL not supplied in handoff | Official site (assumed) |
| P3-S13, P3-S14 | WP194 summaries | URLs not supplied in handoff | Secondary |
| P3-S15 | ra-plutte.de (LG Munchen I, 3 O 17493/20) | URL not supplied in handoff | Secondary |
| P3-S16 | Google Fonts privacy FAQ | https://developers.google.com/fonts/faq/privacy | Vendor documentation |
| P3-S40 | 16 CFR 14.9 (Cornell LII) | https://www.law.cornell.edu/cfr/text/16/14.9 | Statute reproduction |
| P3-S41 | WP260 paragraph 13 | URL not supplied in handoff | Secondary |
| P3-S44 | Bilingual-notice practice | URL not supplied in handoff | Secondary |
| P3-S17 | Supabase pricing | https://supabase.com/pricing | Vendor documentation |
| P3-S18 | Supabase log field reference | https://supabase.com/docs/guides/observability/log-field-reference | Vendor documentation |
| P3-S19 | Supabase auth SMTP | https://supabase.com/docs/guides/auth/auth-smtp | Vendor documentation |
| P3-S20 | Supabase DPA | https://supabase.com/legal/dpa | Vendor documentation |
| P3-S21 | Supabase privacy | https://supabase.com/privacy | Vendor documentation |
| P3-S24 | Netlify privacy | https://www.netlify.com/privacy/ | Vendor documentation |
| P3-S25 | Netlify observability overview | https://docs.netlify.com/manage/monitoring/observability/overview/ | Vendor documentation |
| P3-S26, P3-S27 | Netlify further sources | URLs not supplied in handoff (one is a 2021 staff forum post, stale, UNVERIFIED) | Unlabeled |

## Appendix B. Owner operational runbooks (outline; attorney to review)

### B.1 Deletion, access, or correction request

1. A student emails the privacy contact. Record the date received; the 30-day response clock starts then.
2. Verify the request came from the email address on the account, or confirm the student's identity with the teacher.
3. Deletion: the owner performs a hard delete from the student roster (retype the email to confirm). This removes enrollments, progress, entitlements, submissions and attempts, quiz attempts, feedback, and cohort rows. Activity-log rows remain with the actor removed and may hold internal reference numbers (Inference, high).
4. Access: compile a copy by hand from the owner views. There is no export tool.
5. Correction: students can edit their own lesson answers while they are drafts, and the teacher can reset a lesson's completion. The site cannot change an account's email (D-P17). Under Option A, the teacher closes the account and creates a new one under the corrected email, and tells the student that course records from the old account do not carry over. Under Option B, the operator follows the procedure in `docs/evidence/lizbeth-spanish-owner-email-change-20260917.md`.
6. Reply to the student within 30 days and confirm what was done.

### B.1a Annual account review

At least once a year, the teacher reviews the student roster and deletes accounts whose last course ended more than the confirmed retention period (default 12 months) ago, using the owner hard delete. No automated purge exists, so this review is what makes the policy's retention statement true. Record the date of each review.

### B.2 Suspected breach (outline)

1. Contain: stop the exposure (rotate keys, force password resets, revoke sessions as appropriate).
2. Scope: determine what data and which students were affected, and determine each affected student's state of residence.
3. Notify: notify affected people and regulators as each applicable state's law requires. Michigan's current definition does not cover email plus password, but California's does (secondary source), and California permits electronic notice for credential-only breaches. Pending Michigan bills (SB 360-364) would add a 45-day deadline and attorney general notice.
4. Record what happened, when, and what was done. Involve the attorney early.
5. Update the policy and runbook if practices change.

This outline is informational and is not legal advice. The attorney reviews it before publication (D-P5).
