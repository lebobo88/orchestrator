# Plan: gitignore-and-history-purge — Ignore 11 scratch folders and purge 3 from Git history

Status: Approved. The user gave explicit approval of this plan on 2026-07-17, including explicit confirmation of understanding and acceptance of the irreversible force-push in step 6, and explicit confirmation of the single-owner, zero-fork, zero-collaborator assumption recorded in Section 10.

task_id: gitignore-and-history-purge
plan_id: gitignore-and-history-purge

This plan recommends work. It does not grant execution authority. No engineering writer (T1/T2/T3/Engineering Lead) may start work against this plan until the user has given explicit approval. Once approved, the approved plan path becomes `ENGINEERING_JOB.approved_plan` for the engineering fleet.

**This plan contains an irreversible destructive operation.** Step 6 rewrites and force-pushes the `main` branch history. Once the force-push completes, the pre-rewrite commit history is permanently gone from `origin` unless it is manually restored from a backup (Section 8, Rollback). Anyone who has already cloned or fetched the old history retains the purged files in their local copy unless they separately rewrite their own clone. Only the pre-rewrite filesystem backup and Git bundle created in step 2 make this operation reversible before the user confirms the result is correct. Approving this plan is approving that irreversible history rewrite, not a reversible preview.

## 1. Outcome and audience

For the repository owner (single owner, `lebobo88`), this plan delivers three outcomes against `H:\CommandCenter\orchestrator`:

1. `.gitignore` is extended so that all 11 named top-level scratch/experiment folders are ignored by Git going forward, and none of them is ever tracked again.
2. The three currently tracked folders — `calculator-financial-2`, `calculator-financial-3`, and `calculator-test-1` — are removed from every commit reachable from local `main` and from `origin/main` (force-pushed), while every file in those three folders remains untouched on local disk.
3. No other tracked content and none of the large volume of currently uncommitted working-tree changes is lost, deleted, or accidentally committed as a side effect of this operation.

The audience is the repository owner acting as operator, running PowerShell (with Bash also available) on the Windows 11 host that holds the working repository at `H:\CommandCenter\orchestrator`.

## 2. Scope

### 2.1 In scope

1. Editing `H:\CommandCenter\orchestrator\.gitignore` to append root-anchored, directory-form ignore rules for exactly 11 named folders.
2. Rewriting Git history to remove exactly 3 named folders (`calculator-financial-2`, `calculator-financial-3`, `calculator-test-1`) from all commits, using `git-filter-repo` (already installed, v2.47.0) run against a separate throwaway bare mirror clone — never against the working repository directly.
3. Force-pushing the rewritten `main` branch to `origin` (`git@github.com:lebobo88/orchestrator.git`).
4. Reconciling the local working repository's `main` branch to the rewritten history using `git fetch` + `git reset --mixed` only, so that the on-disk folders and all uncommitted edits are preserved.
5. Committing only the `.gitignore` change on top of the rewritten history, and pushing that commit (a normal fast-forward push, no force needed).
6. Producing a pre-rewrite filesystem backup and an all-refs Git bundle before any history rewrite begins, and verifying the result from a fresh throwaway clone of `origin` afterward.

### 2.2 Non-goals and exclusions

- Do not delete any file from the local filesystem at any point. All 11 folders, including the 3 being purged from history, remain on disk with their contents intact throughout and after this plan.
- Do not rewrite history for any folder or file other than the 3 named (`calculator-financial-2`, `calculator-financial-3`, `calculator-test-1`).
- Do not run `git rm --cached` on the 8 untracked folders (`calculator-financial-tauri-3`, `-5`, `-6`, `-7`, `-8`, `photo-genie`, `mythic-proportion`, `lizbeth_spanish`) — they are already untracked and this command is unnecessary.
- Do not run `git rm --cached` on the 3 purged folders — the mirror rewrite followed by `git reset --mixed` already untracks them in the working repository without touching disk.
- Do not change repository visibility, collaborator access, or any other GitHub repository setting.
- Do not commit the large volume of unrelated pre-existing uncommitted work (~32 modified tracked files, 1 deleted tracked file, dozens of untracked new files) as part of this task. Step 9 stages only `.gitignore`.
- **Hard no-touch boundary**: never run `git reset --hard` or `git clean` in the working repository (`H:\CommandCenter\orchestrator`) at any point in this plan. Every reconciliation step in the working repository uses `git reset --mixed` only, which preserves the working tree.

## 3. Repository findings (confirmed by read-only inspection)

- **Tracked and committed, must be purged from history**: 38 files across the 3 target folders.
  - `calculator-financial-2`: 14 files, including 4 `screenshot_*.png` and 3 `__pycache__/*.pyc`.
  - `calculator-financial-3`: 18 files, including `history.db`, `requirements.txt`, and 8 `__pycache__/*.pyc`.
  - `calculator-test-1`: 6 files.
  - All three folders are tracked and clean: on-disk content matches `HEAD`, with no local modifications inside them.
- **Untracked, gitignore-only, no history purge needed**: `calculator-financial-tauri-3`, `calculator-financial-tauri-5`, `calculator-financial-tauri-6`, `calculator-financial-tauri-7`, `calculator-financial-tauri-8`, `photo-genie`, `mythic-proportion`, `lizbeth_spanish`. Each returns zero rows from `git ls-files`.
- `mythic-proportion` contains its own embedded `.git` directory (a nested repository) but is **not** a Git submodule — no `.gitmodules` file exists in the repository. Git currently treats it as opaque untracked content. Adding `mythic-proportion/` to `.gitignore` stops Git from descending into it; no special submodule handling is required.
- **Remote**: `origin` = `git@github.com:lebobo88/orchestrator.git` over SSH. History is 9 commits on a single branch, `main`, with no other refs or tags.
- **Working tree state**: heavily dirty but unrelated to the 3 target folders. Approximately 32 modified tracked files and 1 deleted tracked file (under `.claude/`, `docs/`, `tests/`, `CLAUDE.md`, `README.md`, `.claude/settings.json`, and `.gitignore` itself), plus dozens of untracked new files. None of the 3 tracked calculator folders appears in the modified/deleted set. This uncommitted work must survive every step of this plan.
- **Current `.gitignore`** (`H:\CommandCenter\orchestrator\.gitignore`) contains only:
  ```
  /.claude/worktrees/
  .claude/.runtime/
  .runtime/
  runtime/*
  !runtime/README.md
  ```
- **Tooling confirmed present**: `git-filter-repo` 2.47.0 (launcher at `C:\Users\robob\AppData\Local\Programs\Python\Python312\Scripts\git-filter-repo.exe`), Python 3.12.10, GitHub CLI at `C:\Program Files\GitHub CLI\gh.exe`.

## 4. Research evidence

Grounded in a nested Researcher `RESEARCH_EVIDENCE` packet (source ledger S1–S5; S4 is the official `newren/git-filter-repo` man page and S5 is the official `INSTALL.md`, both fetched 2026-07-17). Documented behaviors that shape this plan's step ordering:

- `git-filter-repo` resets the working tree to the rewritten commits and runs `reflog expire` plus `git gc --prune=now` as part of its normal operation. Run in place against the working repository, this would delete the 3 on-disk target folders and discard the ~32 uncommitted edits. This is why the plan requires operating on a separate bare mirror clone (Section 6, steps 3–4) rather than the working repository.
- `git-filter-repo` removes the `origin` remote after rewriting a clone, as a safety measure against accidental pushes of unreviewed rewritten history. The remote must be re-added before pushing (Section 6, step 6).
- `git-filter-repo` matches `--path` values against directories recursively, and `--invert-paths` removes exactly the listed paths while keeping everything else. This is the mechanism used in step 4.
- `git-filter-repo` refuses to run unless invoked from a fresh clone, or given `--force`. This plan uses a fresh bare mirror clone (step 3) specifically so `--force` is never needed.
- `git-filter-repo` does **not** preserve `refs/original/*` the way `git filter-branch` sometimes does. There is no built-in undo inside the rewritten repository. An external backup taken before the rewrite (Section 6, step 2) is the only reliable rollback path.

The Researcher's evidence is time-sensitive to the tool version and date fetched; if execution happens substantially after 2026-07-17, re-confirm `git filter-repo --version` behavior against the currently installed version before relying on this plan's exact command forms.

## 5. Design route

Not applicable. This is a repository/history-maintenance operation with no user-visible interface.

## 6. Ordered work

Every step below is an operator instruction for the approved engineering writer to execute after explicit user approval of this plan. Steps 0–1 are read-only verification. Step 2 is the mandatory backup gate and must complete successfully before any step that modifies history. Numbering matches the approved handoff; no step may be skipped or reordered.

**Step 0 — Verify tooling (read-only).**
```powershell
git filter-repo --version
```
Expect `2.47.0`. If `git filter-repo` does not resolve on PATH, invoke it by full path instead for every later `git filter-repo` call in this plan:
```powershell
python "C:\Users\robob\AppData\Local\Programs\Python\Python312\Scripts\git-filter-repo" ...
```
Then confirm:
```powershell
gh --version
gh auth status
```

**Step 1 — Verify force-push is safe (read-only).**
```powershell
gh api repos/lebobo88/orchestrator --jq '{fork:.fork, forks:.forks_count, private:.private}'
gh api repos/lebobo88/orchestrator/forks
gh api repos/lebobo88/orchestrator/collaborators
```
Expect a single owner, `forks_count: 0`, and `private: true`. If `gh` is unauthenticated, confirm the same facts through the GitHub web UI instead. Do not proceed past this step if unexpected forks or collaborators are found without re-confirming with the user first — a fork or collaborator changes who is affected by the force-push in step 6.

**Step 2 — Backup, both forms (mandatory rollback point, taken before any rewrite).**

a. Full filesystem copy of the entire working folder, including all uncommitted and untracked content and the on-disk calculator folders:
```powershell
Copy-Item -Recurse -Force 'H:\CommandCenter\orchestrator' 'H:\CommandCenter\orchestrator-BACKUP-<yyyyMMdd-HHmm>'
```
Replace `<yyyyMMdd-HHmm>` with the actual timestamp at execution time.

b. Git-native all-refs history backup:
```powershell
git bundle create H:\CommandCenter\orchestrator-allrefs.bundle --all
```
Do not proceed to step 3 unless both (a) and (b) complete without error and are spot-checked to exist and be non-empty.

**Step 3 — Create a bare mirror clone from the local repository.** This clone has the full history including the 3 target folders, and has no working tree to accidentally clobber:
```powershell
git clone --mirror H:\CommandCenter\orchestrator H:\CommandCenter\orchestrator-purge.git
```

**Step 4 — Purge the 3 folders inside the mirror only.** From inside `H:\CommandCenter\orchestrator-purge.git` (this is a fresh clone, so `--force` is not required):
```powershell
git filter-repo --invert-paths --path calculator-financial-2 --path calculator-financial-3 --path calculator-test-1
```

**Step 5 — Verify the purge inside the mirror before pushing anywhere.**
```powershell
git log --all -- calculator-financial-2 calculator-financial-3 calculator-test-1
```
Expect empty output.
```powershell
git rev-list --objects --all
```
Pipe or scan the result for any of the three folder names; expect no hits. Do not proceed to step 6 unless both checks confirm the purge is complete inside the mirror.

**Step 6 — Re-add origin and force-push only `main`.** `git filter-repo` removed the `origin` remote from the mirror as a safety measure; re-add it explicitly before pushing:
```powershell
git remote add origin git@github.com:lebobo88/orchestrator.git
git push --force-with-lease origin main
```
No tags or other branches exist in this repository, so nothing else needs to be pushed. Use `--force-with-lease`, not plain `--force` — it aborts instead of overwriting if `origin/main` has moved since the mirror was cloned in step 3. **This is the irreversible step.** Once it completes, the pre-rewrite history is gone from `origin` and only the step 2 backups can restore it.

**Step 7 — Reconcile the working repository without touching the working tree.** In `H:\CommandCenter\orchestrator`:
```powershell
git fetch origin
git reset --mixed origin/main
```
Never substitute `--hard` for `--mixed`, and never run `git clean` here or anywhere else in this plan. The result of `reset --mixed`: `HEAD` and the index move to the rewritten tip; the ~32 modified files remain present as unstaged edits; all untracked files remain present; the 3 calculator folders remain present on disk but become untracked (since they are no longer in the rewritten history).

**Step 8 — Add the 11 gitignore entries.** Append the following block to the existing `H:\CommandCenter\orchestrator\.gitignore` (do not modify the existing 5 lines already in the file):
```
# Local scratch/experiment app folders — never track or push
/calculator-financial-2/
/calculator-financial-3/
/calculator-financial-tauri-3/
/calculator-financial-tauri-5/
/calculator-financial-tauri-6/
/calculator-financial-tauri-7/
/calculator-financial-tauri-8/
/calculator-test-1/
/photo-genie/
/mythic-proportion/
/lizbeth_spanish/
```
All 11 entries are root-anchored (leading `/`) and in directory form (trailing `/`), so they match only the named top-level folders and everything beneath them, not any same-named file or nested path elsewhere in the tree.

**Step 9 — Commit only `.gitignore`.** Do not stage or sweep in the unrelated uncommitted work:
```powershell
git add .gitignore
git commit -m "chore(gitignore): stop tracking local scratch app folders and purge 3 from history"
```
Use exactly this commit message. This commit sits on top of the rewritten history from step 6.

**Step 10 — Publish the gitignore commit.**
```powershell
git push origin main
```
This is a normal fast-forward push and does not require `--force` — the rewritten base was already force-pushed in step 6, and this commit only adds on top of it.

**Step 11 — Final verification from a throwaway fresh clone of origin.**
```powershell
git clone git@github.com:lebobo88/orchestrator.git <tmp-dir>
```
Replace `<tmp-dir>` with a throwaway path outside the working repository. Inside that fresh clone:
```powershell
git log --all -- calculator-financial-2 calculator-financial-3 calculator-test-1
git ls-files
```
Expect the `git log` output to be empty and `git ls-files` to list none of the three folder paths. Then confirm, back in `H:\CommandCenter\orchestrator`:
- All 11 on-disk folders still exist with files intact.
- `git status` still shows the same ~32 modified tracked files and the same untracked work as before this plan began (in addition to the 3 now-untracked-but-ignored calculator folders).

**Step 12 — Cleanup, after user confirmation only.** Delete the throwaway mirror clone:
```powershell
Remove-Item -Recurse -Force H:\CommandCenter\orchestrator-purge.git
```
Retain the step 2 filesystem backup and bundle until the owner confirms the result is fully satisfactory. Do not delete `<tmp-dir>` from step 11 until after this confirmation either; it is a convenient reference clone.

## 7. Interfaces and data

No application interfaces or data migrations are involved. The only artifacts changed are: (1) Git commit history and the remote `main` ref, (2) the local Git index/`HEAD` position, and (3) `.gitignore`. The `.gitignore` commit in step 9 uses the exact message specified there; no other commit authority is granted by this plan. Force-push authorization for step 6 is explicitly part of this plan's approval request; confirm it again at approval time given the irreversibility described above.

## 8. Acceptance and validation

This plan is complete only when all of the following hold:

1. `git log --all -- calculator-financial-2 calculator-financial-3 calculator-test-1` returns empty on local `main` after step 7's reconcile.
2. `git ls-files` in the working repository lists none of the three purged folders' paths.
3. A fresh clone of `origin` (step 11) — or equivalently `git log origin/main -- <paths>` after a fetch — shows no trace of the three folders.
4. `.gitignore` contains root-anchored, directory-form entries for all 11 named folders.
5. `git status` in the working repository shows none of the 11 folders as tracked, and none as untracked-visible by default (they appear only under `git status --ignored`).
6. All 11 folders are still present on local disk with their files intact.
7. The pre-rewrite backup (filesystem copy plus the `--all` bundle from step 2) exists locally, so the operation remains reversible up until the owner confirms the result.

### Rollback

If any verification step fails, or the owner is not satisfied with the result after step 11:

- Restore from `H:\CommandCenter\orchestrator-BACKUP-<yyyyMMdd-HHmm>` (full filesystem restore), or
- Fetch the pre-rewrite history back from the bundle and force-push it to `origin` to undo the rewrite:
  ```powershell
  git fetch H:\CommandCenter\orchestrator-allrefs.bundle "refs/heads/main:refs/heads/pre-purge-main"
  git push --force-with-lease origin pre-purge-main:main
  ```
  Then hard-reset local `main` to `pre-purge-main` if needed. This rollback is itself a force-push and carries the same irreversibility characteristics as step 6; use it only if the step 6 force-push has already happened and needs to be undone.

## 9. Risks and rollback

- **Risk (high): the history rewrite plus force-push in step 6 is irreversible for anyone else holding the old history.** Anyone who already cloned or fetched `origin/main` before step 6 keeps the purged files in their own copy unless they separately rewrite their clone. Mitigations: single-owner/zero-fork verification (step 1) before proceeding; full filesystem backup plus all-refs bundle (step 2) before any rewrite; `--force-with-lease` rather than plain `--force` (step 6) to avoid silently overwriting an unexpected remote change.
- **Risk: an in-place `git filter-repo` run would delete the 3 on-disk folders and discard the ~32 uncommitted edits**, per the documented reset-and-gc behavior in Section 4. Mitigation: all rewriting happens in a separate bare mirror clone (steps 3–4); the working repository only ever receives `git fetch` plus `git reset --mixed` (steps 7), never `--hard` or `git clean`.
- **Risk: accidentally committing the large volume of unrelated uncommitted work** while making the gitignore commit. Mitigation: step 9 stages only `.gitignore` by explicit path (`git add .gitignore`, never `git add -A` or `git add .`).
- **Risk: `git filter-repo` not resolving on PATH.** Mitigation: full-path invocation fallback documented in step 0.
- **Rollback**: see Section 8, Rollback, above.

## 10. Assumptions and decisions

- **Assumption, stated by the user, requires confirmation at approval**: this is a brand-new, single-owner, private repository with no external clones or collaborators, which is why force-pushing `main` is being treated as safe. Step 1 verifies this via `gh api` immediately before any destructive action, but the initial decision to attempt a force-push at all rests on this user-stated assumption and should be reconfirmed at approval time.
- **Decision**: use `git-filter-repo` (already installed) rather than `git filter-branch` or BFG Repo-Cleaner, consistent with `git-filter-repo`'s own documented recommendation over both alternatives.
- **Decision**: use the mirror-clone-plus-`reset --mixed` sequence specifically because it is the only approach identified in this plan's research evidence that satisfies both constraints simultaneously — keeping the 3 purged folders' files on local disk, and protecting the ~32 files of unrelated uncommitted work from being touched by `git-filter-repo`'s in-place reset/gc behavior.
- **Approvals still required before any execution**: explicit user approval of this plan as a whole, and explicit confirmation that the user understands and accepts the irreversible force-push in step 6, specifically.

## 11. Browser UI dialog policy and validation

Not applicable. This plan has no browser-rendered UI or webview component.

## 12. Judge route

`PLAN_DUCK`-eligible and advisory only, per `docs/JUDGE-CONTRACT.md`, because this is a high-risk destructive operation. The orchestrator may run one Codex `PLAN_DUCK` plan checkpoint against this plan before requesting user approval. Any findings from that checkpoint are advisory; this plan's own deterministic acceptance checks in Section 8 remain the controlling validation regardless of judge output. No live judge call is authorized without separate explicit usage approval from the user.

## 13. Engineering mode and downstream owner

Engineering mode: standard. No extreme-advisory team is requested or authorized for this task.

Downstream owner: `engineering-fleet`. After explicit user approval of this plan (including explicit confirmation of the force-push in step 6), the orchestrator passes this plan's exact path, `docs/plans/gitignore-and-history-purge.md`, as `ENGINEERING_JOB.approved_plan` to the engineering fleet. The active writer must read this plan and the current state of `H:\CommandCenter\orchestrator` before executing any step, and must return `JOB_BLOCKED` with `Plan stale` if a material change (for example, a change to the tracked/untracked folder list, a change in remote fork/collaborator count, or any commit to `main` between planning and execution) invalidates an assumption recorded in Section 10.
