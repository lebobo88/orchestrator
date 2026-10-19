# Lizbeth Spanish — production owner email change receipt — 2026-09-17

## Scope and authorization

- Backend: `cultural-spanish` / `gvobtuhbpqvfhjljjcye`.
- Authorized change: rename the existing owner email from
  `thereallizbeth@gmail.com` to `theuniquelizbeth@gmail.com`.
- Excluded: account creation/replacement/deletion, password or reset-link
  actions, permissions or course-ownership changes, metadata rewrites,
  seed/backfill, frontend/deployment/environment changes, impersonation, and
  login-link minting.

## Read-only preflight

- Supabase CLI was linked to the target project, which reported
  `ACTIVE_HEALTHY`.
- Exact Auth email matches: source `1`; destination `0`.
- Source was email-confirmed and had `app_metadata.role = owner`.
- No pending `email_change` row matched either source or destination.
- Source relationships before mutation: `owner_settings = 1`, owned courses
  `= 3`, student enrollments `= 0`, feedback `= 0`.
- Live public schema had no public email columns and no stored email-based
  owner/profile relationship requiring a compatible application update.
  Owner relationships are UUID-based; owner display fallback reads Auth email.

## Mutation

- Method: Supabase Auth Admin API
  `auth.admin.updateUserById(existingUserUuid, { email: destination })`.
- Exactly one update call was made. The payload did not include `email_confirm`,
  metadata, role, password, or any other field.
- The API returned a user successfully. Supabase documents this Admin API
  method as a direct server-side update without a confirmation flow:
  <https://supabase.com/docs/reference/javascript/auth-admin-updateuserbyid>.

## Verification

- Same Auth UUID preserved (redacted; verified by exact UUID comparison).
- Post-mutation exact email matches: source `0`; destination `1`.
- `email_confirmed` remained `true`; no pending email change was present.
- `app_metadata.role` remained `owner`.
- `user_metadata` hash unchanged:
  `bc1b96ca0c67f1f9dd82d0b6ecf0b357` before and after.
- `app_metadata` hash unchanged:
  `d6c79a55f6471e771f48e259f6c9262b` before and after.
- Relationship counts preserved: `owner_settings = 1`, owned courses `= 3`,
  student enrollments `= 0`, feedback `= 0`.

## Judgment and limits

- Pre-mutation AGY: terminal `SUCCESS`, exact model
  `gemini-3.8-flash-medium`, verdict `APPROVE`, conversation
  `d7067165-a382-49e2-867a-20ca1a735399`.
- Post-mutation AGY: terminal `SUCCESS`, exact model
  `gemini-3.8-flash-medium`, verdict `APPROVE`, conversation
  `3fcf20f1-b1c3-4b70-9ec6-0efbb0199f41`.
- Credentials were obtained through the authenticated native Supabase CLI,
  held in process memory only, and not recorded. No raw Auth object, token,
  password, or database dump was recorded.
- No login or mailbox-access test was performed. The receipt establishes the
  Auth state and preservation checks above; it does not prove the owner has
  access to the destination mailbox.
- The 78 dirty YAML files and existing untracked fixture/report were preserved;
  no commit or push was made.
