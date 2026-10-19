# Plan: Status Label Clarity and Forced Password Change After Temp Password

Status: ~~**DRAFT — awaiting explicit user approval.**~~ **Approved by the user, 2026-08-07.** Decision 1 is resolved as Variant (i) (auto-require a password change on "Re-issue access"). Decision 2 is resolved as screen-level plus a real backend lock (server-side enforcement, not client-only). Decision 3 is resolved as combined delivery: Piece 1 and Piece 2 ship together as one combined change, not staged separately — the recommendation in section 3 to ship Piece 1 first, on its own, is not adopted.

- Task ID: `lizbeth-spanish-status-clarity-and-forced-password-change`
- Target repository: `H:\CommandCenter\orchestrator\lizbeth_spanish`
- Audience: the solo non-technical owner-operator, and the T1 engineering agent that executes this plan after approval.
- Engineering mode: standard.
- This is the single authoritative brief for this piece of work. It sits alongside, and does not modify, the already-shipped `docs/plans/lizbeth-spanish-admin-student-operations-combined.md`.

---

## 1. What you saw, and what it actually means

You noticed something that looked like a contradiction on a student's detail page: near the top, an account shows one status, and further down in the "Account Access" panel, a different-sounding status shows for the same account. It looked like the app was disagreeing with itself.

It is not disagreeing with itself. Both indicators are correct, and they always were. They are simply answering two different questions:

- The badge near the top answers: **"Where is this account in its overall life so far?"** It can say Active, Disabled, or (this is the one that confused you) a state meaning "created, but the student hasn't signed in yet."
- The badge in the Account Access panel answers a completely different question: **"Is there a block in place that would stop this student from signing in right now?"** It shows Confirmed or Not confirmed.

An account can genuinely be both "confirmed, no sign-in block" and "hasn't actually signed in yet" at the same time — those are not opposites. A student can have every technical green light and still just not have gotten around to logging in yet. That is exactly the case you ran into, and it is legitimate, not a bug.

**So where was the actual defect?** Only in the wording. The "hasn't signed in yet" badge was labeled with the bare, truncated word **"pending."** That word is vague enough that it reads as if it might mean the same thing as "Not confirmed" sitting right below it — even though the two badges are tracking completely different things. The fix in this plan is a wording fix: replace "pending" with a specific label that says what it means, and add one short explanatory sentence in the Account Access panel so this is never confusing to read again. Nothing about how either status is calculated changes. This is presentation-only.

That is Piece 1 of this plan, and it is small enough that it does not need to wait for anything else.

Piece 2 is a separate, new capability: making sure that a temporary password you hand a student is actually replaced with a password only the student knows, instead of staying valid forever. That is a bigger piece of work, described starting in section 4.

---

## 2. Scope

### In scope

**Piece 1 — status label clarity (admin-facing, presentation only).**
- Relabel the "hasn't signed in yet" badge from "pending" to a clear, specific label.
- Add a one-line explanation in the Account Access panel that distinguishes the two indicators.

**Piece 2 — forced password change (new capability, spans the admin panel and the student-facing app).**
- A new hidden flag on a student's account, settable only by the system (never by the student), that means "this student must set their own password before doing anything else."
- A new full-page screen the student sees immediately after signing in, if that flag is set, that blocks all other use of the app until they set a new password.
- A new admin control that lets you see and set (or remove) that flag for a given student.
- A decision about whether the existing "Re-issue access" button (which generates a new temporary password) should automatically set this new flag.

### Out of scope (non-goals)

- No change to how the two existing status badges are calculated. Both are already correct; only display wording changes.
- No email sending of any kind.
- No self-service "forgot my password" for students.
- No actions that apply to more than one student at a time.
- No change to the database's structure/tables.
- No production deploy and no production data change without your separate, explicit go-ahead at that specific step.
- No new colors, text sizes, or new-looking components. Everything reuses what the app already has.

### No-touch boundary observed during planning

All planning and design work was read-only. No file in the target repository was modified while producing this plan.

---

## 3. The three decisions this plan needs from you

Before this plan can be marked approved, please decide the following three questions. Each is explained in plain language, with a recommendation.

### Decision 1 — Should "Re-issue access" automatically require a password change?

You already have a "Re-issue access" button on a student's detail page. It generates a brand-new temporary password when a student forgot theirs or never got it. Today, once you hand that new password to the student, it works forever with no further step — nothing makes them replace it with a password of their own choosing.

This plan gives you two ways to close that gap:

- **Variant (i) — recommended.** Every time you use "Re-issue access," the student is automatically required to set their own password the next time they sign in. You would not have to do anything extra. The button's confirmation screen would also be reworded slightly to say this plainly.
- **Variant (ii).** "Re-issue access" behaves exactly as it does today (no automatic requirement). If you also want to force a password change for that student, you would need a separate, deliberate step: go to the new admin control (Piece 2b, described below) and turn the requirement on yourself.

**Recommendation: Variant (i).** It is standard, sensible practice for a one-time password an administrator hands out to be replaced quickly by something only the student knows, and it removes an extra manual step you would otherwise have to remember every time. This is offered as an industry good-practice recommendation, not a legal requirement — nothing about this app is subject to a law that mandates it.

Either way, the exact wording for both variants is fully written out in section 6 below, so whichever you pick can be implemented directly without guesswork.

### Decision 2 — What should the "you must change your password" requirement actually block?

There are two ways to enforce this requirement, at different levels of thoroughness:

- **Screen-level only.** The student sees a screen that blocks them from getting to the rest of the app in the browser. This is straightforward, but a technically sophisticated student could, in theory, try to fetch their data directly without going through that screen.
- **Screen-level plus a real backend lock — recommended.** In addition to the screen, the server itself refuses to hand over the student's lesson content or profile data while the flag is set, no matter how the request is made. This is more work to build, but it is the honest, complete way to enforce the rule: the screen is for a normal student's experience, and the backend lock is what actually prevents someone from working around it.

**Recommendation: the second option (screen plus backend lock).** The screen alone is what a normal student experiences and is not, by itself, a real security boundary — it is just where they're guided. The backend lock is what actually protects the data. This plan is written to include both.

### Decision 3 — Should Piece 1 (the wording fix) ship immediately, on its own?

The confusing "pending" label is live in production right now, and the fix is small, self-contained, and does not touch anything else. You can choose to:

- Ship Piece 1 by itself, right away, ahead of the larger Piece 2 work, or
- Hold both pieces together and ship them as one combined change.

**Recommendation: ship Piece 1 first, on its own**, since it is a pure wording correction with no new mechanism, and there is no reason to make it wait on the more involved password-change work. This plan is written so either choice works: Stage 1 below (Piece 1) is deliberately self-contained and independently shippable.

---

## 4. Outcome and audience

**Outcome:**

1. An admin reading a student's detail page never perceives the two status indicators as contradictory, because the confusing label is replaced with a clear one and a one-line explanation is added.
2. A student handed an admin-generated temporary password is reliably and understandably required to set their own password before they can use the app for anything else.

**Audience:** you, the solo owner-operator, and the T1 engineering agent that executes this plan after your approval.

---

## 5. Important verification step that must happen before certain wording is finalized

There is one fact this plan could not settle just by reading the code, and it matters for what the app is allowed to say to you and to students.

**The question:** when you use "Re-issue access" today to generate a new password for a student, does that also sign them out of any device where they're currently logged in? The already-shipped combined plan (`docs/plans/lizbeth-spanish-admin-student-operations-combined.md`) states that it does **not** sign them out elsewhere. New evidence gathered for this plan, from the underlying authentication software's own source code, points the other way — that an administrator-issued password change of this kind typically **does** log the student out everywhere. The two sources disagree, and this plan cannot determine on its own which is true for your specific hosted setup, because the exact version of that authentication software running for your project is not something visible from the code — it is a Supabase dashboard setting that has to be checked directly.

**What this plan requires before any related copy is treated as final:** a short, cheap, hands-on test, described below. Every piece of copy that touches on this topic in this plan is written so it is correct regardless of which way the test comes out — it never promises one outcome or the other.

**The test (must be run before Stage 3 in section 7 begins):**
1. Sign in as a test student on two separate browsers (or one regular window and one private/incognito window).
2. Leave both signed in.
3. From the admin panel, use "Re-issue access" on that test student.
4. On the browser you did **not** just use to generate the new password — the one that's still sitting there signed in — try to do something in the app (navigate to a new page, or just wait for the app to refresh its session).
5. Record what happens: does that other browser get signed out, or does it keep working normally?

Once this is known, record the result directly in this plan (see section 12) before finalizing any copy. If the result shows that sessions **are** ended, the already-shipped combined plan's statement that they are not is now known to be wrong for this project, and that older plan should be corrected separately — this plan is not authorized to edit that other document, but the discrepancy is recorded here so you are aware of it.

---

## 6. Piece 1 — status label clarity (small, ships independently)

### What changes

The badge that currently shows the bare word **"pending"** for an account that hasn't signed in yet is relabeled to:

> **"Awaiting first sign-in"**

This exact label change applies everywhere this badge appears — both the compact version on the student roster list and the full version on a student's detail page — so the two stay consistent with each other, the same way they already are today.

The other two labels on this same badge are also being tidied up for consistency (capitalization only, no meaning change):
- "active" becomes "**Active**"
- "disabled" becomes "**Disabled**"

The icon for each state (a checkmark for Active, an X for Disabled, an hourglass for Awaiting first sign-in) stays exactly the same. Status is never shown by color alone — this rule already holds today and continues to hold; nothing about that changes.

### The new one-line explanation

A single, always-visible sentence is added to the Account Access panel, right after its heading and before the first row of that panel:

> "This shows whether the account can currently sign in, separate from whether the student has signed in before (shown above)."

This sentence deliberately says "shown above" instead of repeating the exact wording of the top badge, so it stays accurate even if that label's exact wording is ever tweaked later. It reads as a small caption, not a warning or an alert — there is nothing wrong that needs fixing here, just something worth clarifying.

### Things to check before calling this done

- The new, longer label ("Awaiting first sign-in") must not get visually cut off anywhere it appears. It has been checked and the badge has no fixed narrow width that would clip it, so this should render fine, but this is worth a visual confirmation pass.
- Both places this badge appears (the roster list and a student's own detail page) must show the same label for the same state.
- At a very narrow screen width (a phone) and at a heavily zoomed-in browser view, the badge and the new sentence must remain fully readable with no sideways scrolling required.

---

## 7. Piece 2 — the forced password change requirement

### 7.1 The idea in plain terms

Today, when you create a student or use "Re-issue access," a temporary password is generated and shown to you once, and you hand it to the student directly (there is no email involved — that is intentional and is not changing). The problem this plan solves: nothing currently makes the student replace that password with one of their own. It stays valid indefinitely, which means anyone who ever saw that temporary password (including you) could keep using it.

The fix has three parts working together:

1. A hidden marker on the student's account saying "this student must set a new password before doing anything else." Only the system can turn this marker on or off — the student can never clear it themselves, even if they know how the app works internally. This matters because if a student *could* clear it on their own, the whole requirement would be pointless.
2. A screen the student sees the moment they sign in (or refresh the page) while that marker is on. It fully replaces the normal app — no menus, nothing else usable underneath it — until they've set a new password.
3. Once the student successfully sets a new password, the marker is cleared, and they proceed into the app normally, the same as any other student.

You also get a way to see and directly control this marker for any student from the same Account Access panel used for the other two controls.

### 7.2 What the student sees, step by step

The moment a flagged student finishes signing in — including if they refresh the browser partway through, at any time the marker is still set — they see a dedicated screen, not a pop-up and not something layered over the app. It looks and feels like a continuation of the sign-in screen they just used, not a jarring new design.

**Heading:** "Choose a new password"

**Explanation:** "For your security, please set a new password before continuing. You'll use this new password every time you sign in from now on."

Then two fields:
- **"New password"**
- **"Confirm new password"**

Below the New Password field, a small always-visible hint: **"Must be at least 8 characters."**

A **"Set password"** button submits the form (its label changes to **"Setting password..."** while it is working).

Below that, a clearly secondary, de-emphasized link: **"Sign out and come back later."** A student is never trapped on this screen — they can always leave and try again later.

**If the student enters a password that's too short:**
"Your new password needs to be at least 8 characters." — the New Password field is marked as invalid and gets keyboard focus.

**If the two password fields don't match:**
"Those passwords don't match. Please re-enter them." — the Confirm New Password field gets keyboard focus.

**If everything succeeds:**
The screen shows "Password updated." and then, after a brief pause (at least one full second), moves the student into the normal app. That pause exists specifically so a screen-reader user has time to actually hear the confirmation before the screen changes out from under them — this is not a cosmetic delay, it is required for accessibility.

**If something goes only partly wrong:** this is the part that matters most for never leaving a student stuck or confused. There are three distinct ways a step after the password itself might fail, and each has its own honest, specific message — the student is never told to "try again" in a way that would make them think their new password didn't save when it actually did:

- *The password saved, but the system couldn't clear the "must change password" marker itself:* "We couldn't finish updating your account status just now, but your new password is saved and ready to use." A "Continue" button retries just that last step. The sign-out link is reworded to: "Sign out and come back later - your new password is already saved. Use your new password next time you sign in."
- *The password saved and the marker cleared, but the app's local copy of the sign-in session needs a refresh that didn't work:* "Your new password is saved and ready. We just need to refresh your session to continue." A "Try again" button retries just the refresh. A second option, "Sign out and sign in again," is always available too — that will work regardless, since the marker really is cleared on the server already.
- *The request to save the new password never went through at all (e.g. no internet connection), so it's genuinely unclear whether it worked:* "We couldn't reach the server to save your new password. Please check your connection and try again." Retrying keeps whatever the student already typed. The sign-out link in this specific case gets an honest caveat: "If you sign out now, try your current password first the next time you sign in, since we're not sure your new one was saved."

The sign-out link is always available except for the brief moment a request is actually in flight, when it is temporarily disabled rather than hidden.

### 7.3 The admin control (Account Access panel, new third row)

This adds a third row to the existing Account Access panel on a student's detail page, alongside the two rows you already have ("Mark email confirmed" and "Re-issue access").

**When the requirement is off (default):**
- Status: "Not required"
- Description: "No password reset is pending for this student."
- Button: "Require password reset"

**When the requirement is on:**
- Status: "Reset required at next sign-in"
- Description: "This student will be asked to choose a new password the next time they sign in."
- Button: "Remove reset requirement"

Clicking either button opens a plain confirmation dialog (not a "type to confirm" dialog, and not styled as an alarming warning — this is a normal, reversible admin action):

**Setting it:**
- Title: "Require Password Reset"
- Body: "The next time {student's email} signs in, they'll be asked to choose a new password before they can do anything else. Continue?"
- Buttons: "Cancel" / "Require Reset"

**Removing it:**
- Title: "Remove Password Reset Requirement"
- Body: "{student's email} will be able to sign in with their current password without being asked to change it. Continue?"
- Buttons: "Cancel" / "Remove Requirement"

While the request is running, the confirming button's label changes to "Requiring…" or "Removing…". If it fails: "Couldn't update the password reset requirement. Try again." — the dialog stays open so you can retry.

On success, the dialog closes, the row updates to show the new state, and keyboard focus is deliberately moved to the updated status text (this needs to be done on purpose in the code — it will not happen automatically).

You will normally see this row already reset itself back to "Not required" on its own after a student successfully completes the password-change screen — you do not need to remember to turn it off yourself in the normal case.

### 7.4 How "Re-issue access" is affected (depends on Decision 1)

The exact copy for both possible outcomes of Decision 1 is written out here so either can be implemented directly.

**If you choose Variant (i) — recommended (auto-require):**

The existing "Re-issue access" confirmation dialog keeps its current first and third bullet points unchanged, but its **second bullet point is replaced** (not left in place alongside new text) because the current wording makes a promise the evidence can no longer support (see section 5):

- Old bullet (being replaced): "If they're already signed in somewhere, that won't change — this doesn't sign them out."
- **New bullet:** "If they're already signed in somewhere, this might or might not sign them out there too — either way, they'll need the new password the next time they sign in."

A new fourth bullet is added:

- "The next time they sign in, they'll be asked to choose their own new password before doing anything else."

And the password-reveal screen that appears after generating the new password gets one additional trailing sentence: "When they sign in with it, they'll be asked to set their own password before continuing."

**If you choose Variant (ii) (manual-only):**

"Re-issue access" is not touched at all — its dialog and reveal-screen copy stay exactly as they are today, including that same unresolved "won't sign them out" claim from the original wording. That claim remains a separate, standalone accuracy problem regardless of which variant you pick, and is not fixed as part of Piece 2 under this variant. If you'd like it corrected even without adopting automatic-requiring, say so and it can be handled as a small follow-up.

### 7.5 What this control does and does not protect against

The screen the student sees is there to guide a normal student through a normal situation. It is not, by itself, a real security barrier — a sufficiently technical person could in theory try to access data without going through that screen. That is exactly why Decision 2 (section 3) matters: this plan is written to also lock the relevant data down on the server side while the flag is set, so the real protection does not depend on the screen alone.

---

## 8. Ordered work

### Stage 1 — Piece 1: status label clarity (independently shippable)

1.1. Relabel the "hasn't signed in yet" badge from "pending" to "Awaiting first sign-in" everywhere it appears (roster list and detail page). Update the "active"/"disabled" labels to "Active"/"Disabled" for consistency. Keep the existing icons and existing color/contrast treatment; do not change how any of these three states is calculated.

1.2. Add the new one-line explanation sentence to the Account Access panel, placed immediately after its heading and before the first row.

1.3. Confirm the longer new label does not clip anywhere, and that both badge locations stay consistent. Confirm readability at a narrow phone width and at high browser zoom, with no sideways scrolling.

1.4. Write tests covering: the correct label renders for all three states at both locations; status is still never shown by color alone; narrow-width and zoomed display is unaffected.

**This stage can be dispatched and shipped entirely on its own if you choose Decision 3's recommended path.**

### Stage 2 — settle the session-behavior question (must happen before Stage 4's copy is written)

2.1. Run the two-browser test described in section 5. Record the exact observed result directly into this plan document (see section 12) before any Stage 4 copy is treated as final. If the result differs from what's already written in this plan, correct the copy before proceeding — every version of the copy in this plan was written to be safe under either outcome, so this should not require a rewrite, only a confirmation.

### Stage 3 — the hidden account marker (backend)

3.1. Add the new hidden "must change password" marker, stored the same protected way the existing "owner" account marker already is (a location on the account that only the system, never the student, can write to).

3.2. Add a new admin action that turns the marker on for a given student, following the same authorization checks, input validation, and error-handling approach already used by the existing admin actions on this same screen.

3.3. Add a separate action, usable only by a signed-in student acting on their *own* account, that turns the marker off — but only as part of a successful password change, never on request by itself.

3.4. Before this ships, directly confirm that setting this new marker can never accidentally erase or overwrite the separate, existing "owner" marker on any account — the two must never interfere with each other. Write a test that proves this.

3.5. Add the new marker to the information already sent to the roster list and student detail screens. This is a pure addition — nothing that already exists changes shape or behavior.

### Stage 4 — the real backend lock (per Decision 2, if adopted)

4.1. While the marker is set, deny the student's access to their own lesson content and profile data at the server level too, not just by hiding it on screen. The exact technical method for checking this must be confirmed directly against this project's specific setup at implementation time, rather than assumed from a generic example — implementation details can vary between versions.

### Stage 5 — the student-facing screen

5.1. Build the full-page screen described in section 7.2, matching that section's copy exactly.

5.2. This screen must check the marker every single time the app's main screen would normally load — including on a plain page refresh, not only right after signing in. A page refresh while the marker is set must never accidentally let the student into the normal app.

5.3. Add the ability for the app to refresh its own copy of the sign-in session (this does not exist in the code today and needs to be added) — this is required so that once the marker is cleared, the block actually goes away without requiring the student to sign out and back in.

5.4. Build every state described in section 7.2, including both partial-failure states, the network-failure state, and the mandatory sign-out option available in every state except while a request is actively in progress.

5.5. Build the "Password updated." confirmation with the required hold before the screen changes, so a screen-reader user has time to hear it.

5.6. Test every state listed above, plus specifically: a page refresh while flagged shows the block screen again rather than the normal app (this is the single most important test in this stage); the student genuinely cannot clear the marker themselves through any available means.

### Stage 6 — the admin control

6.1. Add the new third row to the Account Access panel exactly as described in section 7.3, reusing the same visual pattern already used by the existing two rows.

6.2. Build both confirmation dialogs and all their states (working, success, failure), matching this plan's exact copy.

6.3. After a successful change, move keyboard focus to the updated status text, the same way this already happens for the existing two rows.

### Stage 7 — "Re-issue access" integration (per Decision 1)

7.1. Implement whichever variant you chose in Decision 1, using the exact copy from section 7.4.

### Stage 8 — verification and release

8.1. Full local check: code style, type checking, a full build, the complete automated test suite, full browser-based tests, and a local run of the affected server functions.

8.2. An independent reviewer (not the engineer who built it) checks the work separately.

8.3. A separate check specifically confirms the rendered screens behave correctly in a real browser, across screen sizes, including the specific tests called out above.

8.4. Only after all of the above pass: a separate, explicit go-ahead from you specifically for the production deploy.

8.5. After deploying: create one throwaway test student, confirm the entire flow (temp password to forced change to normal app access) actually works end-to-end in production, then delete that test account.

---

## 9. What changes, technically (for T1's reference)

- A new field is added to a student's account data (an `app_metadata`-style flag on the Supabase user record) that only server-side/service-role code can write. The exact internal field name is left to T1 to decide, following the same pattern already used for the existing "owner" marker in `src/lib/ownerSettingsAuthorization.ts`.
- Two new server actions: one to set the flag (admin-only), one to clear it (student, own account only, only as part of a successful password change).
- The roster and detail data responses gain this flag as a pure addition — nothing existing changes shape.
- `AuthContext.tsx` gains a new `refreshSession()` capability that does not exist today.
- One new top-level, full-page view for the student-facing gate. It is never a Modal/dialog — it fully replaces the app shell while active.
- No database schema change. No existing application data table is touched.
- Data-level changes involved: an account gains a new flag value; a student's password changes when they complete the gate flow.
- **Presentation-only guardrail:** all new visual work must reuse the app's existing color/spacing/type values exactly as documented (no new hex colors, no new type sizes) — every new piece of styling binds to a token the app already generates. Two small, unrelated, pre-existing styling gaps were noticed while preparing this plan (described in section 11) and are explicitly **not** to be fixed as part of this work.

---

## 10. Acceptance and validation checklist

- Every combination of the two account indicators reads clearly, and is specifically tested for the exact case that started this: a confirmed account that hasn't signed in yet.
- A page refresh while the password-change flag is set re-shows the gate screen rather than the normal app — a direct, dedicated test for this exact scenario.
- A student cannot clear the flag themselves under any circumstance — proven by a test that specifically tries and confirms it fails.
- A direct attempt to fetch a flagged student's data, bypassing the on-screen gate entirely, is denied by the server — not just hidden by the screen.
- The gate stops appearing only after the app's session information is actually refreshed; if that refresh is skipped, the gate must still correctly reappear.
- The separate, existing "owner" account marker is proven, by test, to survive unaffected when this new flag is written.
- Both partial-failure states described in section 7.2 leave the student able to recover, never repeating in a loop, and never actually locked out.
- Every non-submitting state of the gate screen has a way to sign out.
- The "Password updated." message is confirmed to be perceivable by assistive technology before the screen changes.
- Color contrast for every new piece of text/icon combination is checked with a real contrast-checking tool, not estimated by eye.
- A direct scan of the changed code confirms no native browser pop-ups (`alert`, `confirm`, `prompt`, or "are you sure you want to leave this page") appear anywhere.
- No password value, and no version of the new flag's value, ever appears in a log message or an error message.

### Browser UI dialog policy (required)

No native browser dialogs anywhere in this work: no `alert`, `confirm`, `prompt`, or "leaving this page" browser prompts. Every confirmation in this feature uses the app's own existing accessible dialog component. All validation uses the app's existing inline-alert pattern. Keyboard operation and visible focus outlines are required for every new control, specifically including: focus landing on the gate's heading when it first appears, focus moving to the first invalid field on a form error, and focus returning correctly after each admin action completes.

### Browser validation brief

- **Launch and readiness:** the existing local development server, plus the local Supabase stack with the relevant server functions running locally.
- **Test data:** existing seeded local test-student accounts; one test student with the new flag deliberately set; one test student with a confirmed email but who has never signed in (the exact scenario that prompted Piece 1).
- **Journeys to check:** the "confirmed but awaiting first sign-in" detail page reading clearly, not as a contradiction; signing in with a flagged account and reaching the gate; completing the gate successfully; refreshing the page mid-gate and confirming the gate still shows; both partial-failure paths; the network-failure path; signing out from the gate; an admin turning the flag on and off from the new third row (including its failure state); the chosen "Re-issue access" variant; and a full keyboard-only pass through every new screen, confirming Escape correctly closes the two plain confirmation dialogs.
- **Screen sizes:** a narrow 320px-wide phone view, a tablet width, a standard desktop width, and a 400%-zoomed view, confirming no sideways scrolling appears anywhere.
- **What "correct" looks like:** the exact wording in this plan matches what's on screen for every state; status is never shown by color alone; every new control shows a visible focus outline; no errors appear in the browser's technical console; no password is ever left visible or retrievable after the flow completes; no native browser pop-up appears anywhere.

---

## 11. Risks and what protects against each one

**Risk — a student could bypass the gate with a page refresh (high severity).** This is the single most important implementation detail in this whole plan. **Protection:** the gate is required to be built as a check that re-runs on every single screen load, including a plain refresh — never a one-time check that only runs right after signing in. A dedicated regression test proves this directly (see section 10).

**Risk — mistaking the on-screen gate for a real security boundary (high severity).** The screen alone only guides a normal student; it does not stop a determined attempt to fetch data directly. **Protection:** Stage 4's server-side lock (contingent on Decision 2) is required specifically so the real protection does not depend on the screen.

**Risk — putting the new flag in the wrong place on the account record (high severity).** There are two different places a flag like this could technically be stored on a Supabase account; one of them (`user_metadata`) is directly editable by the student themselves through the app's normal "update my profile" mechanism, which would make the whole requirement pointless — the student could just turn it off. **Protection:** the flag must go in the other, protected location (`app_metadata`), which only server-side code can write. A specific test proves a student's own attempt to change this location is rejected.

**Risk — accidentally erasing the existing "owner" marker while writing the new flag (high severity).** Both markers would live in the same general area of the account record; writing one carelessly could wipe out the other. **Protection:** this must be directly verified and covered by a dedicated test (Stage 3.4) before this ships.

**Risk — a student getting stuck on the gate screen with no way out (medium severity).** **Protection:** a way to sign out is present on every non-submitting state of the gate, by requirement (section 7.2).

**Risk — writing copy that promises a specific outcome about signing a student out elsewhere, when that outcome is actually unverified (medium severity).** **Protection:** Stage 2's hands-on test settles this before any related copy is finalized, and every version of the copy already written in this plan is worded to be accurate no matter which way that test comes out.

**Risk — the already-shipped combined plan may contain an inaccurate claim about session behavior (medium severity).** If Stage 2's test shows sessions *are* ended by "Re-issue access," the earlier combined plan's statement that they are not would be known to be wrong. **Protection:** this plan does not edit that other document, but records the discrepancy here so you are aware a correction may be needed there separately.

**Risk — the exact version of the underlying authentication software running on your hosted project is not something visible from the code (medium severity).** All research grounding this plan was checked against the current published version of that software, which may not exactly match what's actually running for your project. **Protection:** Stage 2's direct, hands-on test is the actual authority here, not the research alone.

**Risk — this work touches several different parts of the app at once (medium severity).** It spans a server function, the sign-in logic, the admin screen, and an entirely new student-facing screen. **Protection:** the staged sequencing above; and Piece 1 (Stage 1) can be shipped completely on its own, ahead of everything else, if you'd like the confusing label fixed immediately without waiting on the larger work.

**Rollback:** all code changes revert through normal version control. If something needs to be undone after a production deploy, the affected server function is rolled back by redeploying its last known-good version. Turning a flag off for an individual student (unlike some other past changes in this codebase) is fully reversible at any time — it is not a one-way action.

---

## 12. Verification record

*(Completed during implementation. Test was run empirically to settle session behavior fact.)*

- Date test run: August 7, 2026
- Result observed: **Sessions ARE revoked.** When `updateUserById({password})` is called via the admin API to issue a new password, both the first and second simultaneously-authenticated sessions are invalidated. Verified with:
  - Test student signed in from two separate browser sessions
  - Admin re-issued access (password changed via service-role API)
  - Both sessions immediately became invalid (failed auth.getUser() calls after 2s delay)
  - Test cleanup: all test users deleted
- Action taken based on result: **ReissueAccessModal copy corrected.** Updated the second bullet point from "won't sign them out" (factually incorrect) to "will sign them out there too — they'll need the new password the next time they sign in." Added fourth bullet about automatic password change requirement. Password reveal screen updated with note about mandatory password change.

---

## 13. Two small, unrelated issues noticed but not touched by this work

While preparing this plan, two small pre-existing styling issues were noticed elsewhere on the same pages this work touches. Neither is caused by, or fixed by, this plan — they are flagged here only so you're aware of them and can decide later whether to have them fixed as a small separate follow-up:

- The existing "Confirmed" / "Not confirmed" badges in the Account Access panel are referencing a color setting that doesn't actually exist in the app's design system, so they're quietly rendering slightly generic, off-brand colors instead of the app's real palette. This has been happening already, before this plan.
- A specific medium-gray text color is referenced in a few places on these same pages but was never actually set up in the app's design system, so it also quietly falls back to a generic gray instead of the intended warm tone. Also pre-existing.

Both are cosmetic-only, low-severity, and not part of this plan's scope.

---

## 14. Approvals still required

1. ~~Your approval of this plan.~~ **Resolved, 2026-08-07: approved.**
2. ~~Your decision on Decision 1 (auto-require on re-issue, or manual-only).~~ **Resolved, 2026-08-07: Variant (i), auto-require.** "Re-issue access" automatically flags the account for a forced password change on the student's next sign-in.
3. ~~Your decision on Decision 2 (screen-only, or screen plus a real backend lock — recommended).~~ **Resolved, 2026-08-07: screen plus a real backend lock.** The block is enforced server-side, not only in the client-side UI.
4. ~~Your decision on Decision 3 (ship Piece 1 immediately on its own, or hold it with Piece 2).~~ **Resolved, 2026-08-07: hold both pieces together.** Piece 1 and Piece 2 ship together as one combined change; Piece 1 is not staged or shipped separately, notwithstanding this plan's recommendation in section 3 to ship it first on its own.
5. ~~A separate, explicit go-ahead for the production deploy step (section 8.4), after all verification has passed. Still required — not yet given.~~ **Resolved, 2026-08-07: given.** After being told that all verification (Verifier, Codex security review, and browser validation) had passed for this plan, the user explicitly said "yes push to production," authorizing the production deploy step in section 8.4. Following that go-ahead: the Edge Function was deployed to the production project (ref `udrlwexyzaqaqxdxdsml`, confirmed ACTIVE); the RLS migration `202608070001_force_password_change_rls_enforcement.sql` was applied to production; and the frontend changes were committed (`7cd1669`) and pushed to `main`, which triggered a Netlify auto-build. The Netlify publish click itself is a separate, manual, user-owned action and is not yet confirmed as done — it is not covered by this approval record and remains outstanding.

### Execution note

T1 remains the engineer of record, under its normal test-first process and full quality review. Before any implementation of Stage 4 or later begins, T1 must directly confirm the exact technical syntax needed for the server-side data lock against this project's actual Supabase setup, rather than copying a generic example — this is called out explicitly because it was flagged as unverified during planning.

---

## 15. Status

~~**DRAFT.** Awaiting your explicit approval of this plan and your answers to Decisions 1, 2, and 3 above.~~ ~~**Approved by the user, 2026-08-07.** Decisions 1, 2, and 3 are resolved: Decision 1 as Variant (i) (auto-require a password change on "Re-issue access"), Decision 2 as screen-level plus a real backend lock (server-side enforcement, not client-only), and Decision 3 as combined delivery (Piece 1 and Piece 2 ship together, not staged separately). Stage 2's verification test was completed and recorded in section 12. A separate, explicit go-ahead is still required before production deploy (step 8.4).~~ **Approved and deployed to production, 2026-08-07.** Decisions 1, 2, and 3 are resolved as above, and Stage 2's verification test was completed and recorded in section 12. After Verifier, Codex security review, and browser validation all passed, the user gave an explicit go-ahead for production deploy ("yes push to production"), and the deploy proceeded: the Edge Function is ACTIVE in production (project ref `udrlwexyzaqaqxdxdsml`), the RLS migration `202608070001_force_password_change_rls_enforcement.sql` is applied, and the frontend changes are committed (`7cd1669`) and pushed to `main`, triggering a Netlify auto-build. The Netlify manual publish click remains a separate, outstanding, user-owned action, not yet confirmed done.
