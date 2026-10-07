# Lizbeth Spanish live-site anonymous smoke, 2026-10-06

Read-only. Anonymous browser only: no logins, no clicks, no mutation controls, no impersonation or login links. A Playwright route guard aborts any non-GET request except Supabase `/rest/v1/rpc/` reads (none fired). No secrets recorded.

- Site: Netlify `lizbeth-spanish` (id 36497726-71dd-42f6-a84e-834353a92cba), `https://lizbeth-spanish.netlify.app`.
- Runner: repo-local Playwright (chromium) from a clean `git archive 8e89737` export (scratch), 1280x800, `networkidle` plus 1.5 s.
- Raw data and screenshots: `docs/evidence/lizbeth-spanish-prod-smoke-20261006-assets/` (`smoke.json` + sha256, one PNG per route).

## What is live (Netlify API, read-only)

| Item | Value |
|---|---|
| Published production deploy | `6ac5045e461e825c56ea9044`, branch `main`, commit `aa99662` (merge of PR #217), published 2026-10-06T14:25:18Z, locked |
| Newer production deploy (built, NOT published) | `6ac517d80521ad00081477a8`, commit `8e89737` (PR #219), ready, `published_at` null |
| Previously live release | `6aaa9a540d612bf3163361c6` (20260917 candidate), published 2026-09-18 |
| Live main bundle | `assets/index-BTS_ugjy.js` (the 20260917 candidate bundle was `index-tJn-0Hw3.js`) |

The live client is therefore the full `main` at `aa99662`: it already contains the #174, #175, #176, #177, #179 and #180 client code, while the hosted backend has none of the matching migrations (see the audit report). Netlify builds main automatically and the publish step is held by the deploy lock.

## Route results (all anonymous)

| Route | HTTP | Final URL | Visible | Console errors | Page errors | Failed requests | Backend calls (status) |
|---|---|---|---|---|---|---|---|
| `/` | 200 | same | Sign-in gate ("Learn in the open ... ACCESS Sign in EMAIL PASSWORD Open my journal") | 1 (404 resource) | 0 | 0 | `GET rest/v1/public_site_content` 404 |
| `/courses` | 200 | same | Public catalog ("Three volumes, 78 weeks, A1 to C1 / Explore courses", Beginner...) plus SIGN IN link | 1 (404) | 0 | 0 | `public_site_content` 404; `course_catalog` 200 |
| `/learn` | 200 | same | Sign-in gate | 1 (404) | 0 | 0 | `public_site_content` 404 |
| `/roadmap` | 200 | same | Sign-in gate | 1 (404) | 0 | 0 | `public_site_content` 404 |
| `/feedback` | 200 | same | Sign-in gate | 1 (404) | 0 | 0 | `public_site_content` 404 |
| `/week/1` | 200 | same | Sign-in gate | 1 (404) | 0 | 0 | `public_site_content` 404 |
| `/admin/dashboard` | 200 | same | Sign-in gate (no admin content for anonymous) | 1 (404) | 0 | 0 | `public_site_content` 404 |
| `/does-not-exist-smoke` | 200 | same | Sign-in gate (SPA fallback) | 1 (404) | 0 | 0 | `public_site_content` 404 |

No uncaught page errors, no network-level failures, no 400s. The only error on every route is the 404 for the `public_site_content` view, which does not exist in the hosted database (pending migration `202610040001_issue177_site_content`). Pages still render with built-in copy. The `/courses` catalog and the sign-in gate work.

## New-client features that would hit backend that is not yet deployed

Method: RPC, table and function names extracted from the live bundle, checked against the hosted database (read-only `pg_proc` and `to_regclass`) and the deployed Edge Function list.

| Client feature | Backend dependency | Hosted state | Pending migration or deploy |
|---|---|---|---|
| Roadmap completion read (#176) | RPC `get_enrollment_lesson_completion` | MISSING | `202610030001_issue176_single_completion_record` |
| Public/owner editable site text (#177) | view `public_site_content`; Edge Function `site-content` | view MISSING (404 seen live); function NOT deployed | `202610040001_issue177_site_content`; deploy `site-content` |
| Owner settings singleton (#177) | table `owner_settings` | exists, 1 row; function `owner-settings` is v1 (old) | `202610030003`; redeploy `owner-settings` |
| Student handout links (#174) | RPC `get_student_lesson_assets` | MISSING | `202610040002_issue174_student_course_assets` |
| Lesson task form (#179) | RPCs `get_lesson_task`, `get_lesson_task_summaries`, `save_lesson_task_draft`, `submit_lesson_task`, `mark_lesson_task_feedback_seen` | all MISSING | `202610040003` to `202610040007` |
| Lesson quizzes (#180) | RPCs `get_lesson_quiz`, `get_lesson_quiz_summaries`, `reveal_lesson_quiz`, `submit_lesson_quiz_attempt`, `mark_lesson_quiz_results_seen` | all MISSING | `202610050001` to `202610050005` |
| Owner review/grading, owner event attribution (#179b, #180c) | Edge Functions `admin-student-operations`, `course-authoring` (v1, old) | deployed but old versions | redeploy after migrations |
| Existing flows | `record_lesson_progress`, `record_lesson_completion`, `request_version_enrollment`, `course_catalog`, `lessons`, `bands`, `resources`, `student_enrollments`, `lesson_revisions`, `feedback_submissions` | present | none |

These student and owner features are only reachable after sign-in, so the anonymous smoke could not trigger them; the table is derived from the bundle against the database. Expect them to fail (RPC not found) for a signed-in user until the 15 pending migrations are applied and the Edge Functions redeployed. Tasks and quizzes also need their seed content (migrations `...040004`, `...050002`) and refreshed lesson-content storage objects.

Note: the #219 merge (scripts and tests only) produced the unpublished production deploy `6ac517d8`; it changes no client code.
