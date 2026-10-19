# Codex CLI Harness Migration Plan (Authoritative Root Governance Plan)

> [!IMPORTANT]
> ## Authoritative Harness Migration Status & Governance Block
> - **Adversarial Review Assessment**: 39 reviews PASS 100/100.
> - **User Approval State**: EXPLICIT USER APPROVAL RECEIVED in the current turn ("Implementation is explicitly approved by the user in the current conversation").
> - **Implementation Status**: PHASE 1 COMPLETE (PASS) / READY FOR PHASE 2.
> - **Repository Root**: `H:\CommandCenter\orchestrator`
> - **Current Source Artifact**: `H:\CommandCenter\orchestrator\CODEX-HARNESS-MIGRATION-PLAN.md`
> - **Handoff Source of Truth Rule**: This root plan file (`H:\CommandCenter\orchestrator\CODEX-HARNESS-MIGRATION-PLAN.md`) is the authoritative handoff source of truth across all sessions and agents. It MUST be updated after the execution of every phase and gate to reflect live status, verification evidence, and the append-only progress log.
> - **Preexisting Governance Exclusion**: This user-requested preexisting governance file is strictly EXCLUDED from the 116 generated-item creation count and must NEVER be overwritten, modified, or deleted by rollback procedures.
> - **Completed Work**:
>   - Phase -1: Comprehensive 39-revision architectural design and adversarial review completed (39 reviews PASS 100/100).
>   - Explicit user approval granted in current turn.
>   - Root governance plan instantiated at `H:\CommandCenter\orchestrator\CODEX-HARNESS-MIGRATION-PLAN.md`.
>   - Status header corrected to 39 reviews PASS 100/100.
>   - Root plan initial freeze: SHA-256 `53845c155f1003c42dd726383e7fd12612e7d7b45afd60b78f805d3d2cda96ee`.
>   - Schema extracted to `C:\Users\robob\AppData\Local\Temp\codex-manifest-approved\codex-implementation-manifest.schema.json`.
>   - Approved external implementation manifest materialized at `C:\Users\robob\AppData\Local\Temp\codex-manifest-approved\codex-implementation-manifest.json` with status `"approved"`.
>   - Initial Phase 0 gate execution stopped fail-closed on parameter binding erratum in `Extract-MarkdownCodeFenceFromLines`.
>   - Plan amended to add `[AllowEmptyString()]` attribute to `[string[]]$Lines` in both controller and outer gate copies.
>   - Plan re-frozen: SHA-256 `ba6cdcde35f32e546de2aa621bbfe15788b35445d0876eada010851b0d67bfa1`.
>   - Manifest regenerated with updated SHA-256 and verified via `Test-Json` (PASS).
>   - Second Phase 0 gate execution stopped fail-closed on Roslyn C# compilation error CS1519 (`public cntThreads;` missing `uint`).
>   - Plan amended to correct line 2680 to `public uint cntThreads;`, ensuring 100% type consistency across all 5 embedded copies of `PROCESSENTRY32W`.
>   - Plan re-frozen: SHA-256 `cc81bbe909e75602c5adbec95197f17f2d168eae7db2e471f2244343f2caf700`.
>   - Manifest regenerated and verified via `Test-Json` (PASS).
>   - Complete Phase 0 External Audit Gate executed and **PASSED**:
>     - 109 repository targets checked for collision: 0 collisions found.
>     - All 109 repository targets and ancestors checked for reparse points: 0 violations found.
>     - Verified runtime parent directory and created `.runtime-parent-owner.json`.
>     - Materialized `intended-creation-manifest-fc5dc440b2264c57a033d2da08e9ac21.json` (116 items) and `phase0-baseline-fc5dc440b2264c57a033d2da08e9ac21.json` in `runtime/audit/`.
>     - Verified exact raw git porcelain v2 status byte invariance (before vs after byte-identical).
>     - Verified all preexisting dirty and untracked files 100% length and SHA-256 invariant.
>     - Verified clean disposal of external temporary staging directories.
>   - Complete Phase 1 Core Configuration, Schemas & Hooks Infrastructure implemented and **PASSED**:
>     - `.codex/config.toml` created conforming to Codex CLI syntax (`sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, `web_search = "disabled"`, `[windows] sandbox = "unelevated"`, `[features] hooks = true, multi_agent = true, unified_exec = true`, `[permissions.snapshot-isolated]`, `[permissions.orchestrator-governed]`).
>     - `.codex/requirements.template.toml` created enforcing managed enterprise security policy.
>     - Schemas `.codex/schemas/codex-agent.schema.json` and `.codex/schemas/codex-hooks.schema.json` created in Draft 2020-12 format.
>     - `.codex/hooks.json` created mapping PreToolUse and SessionStop events to strict PowerShell 7 validators.
>     - All 7 hook validators created under `.codex/hooks/`: `validate-control-plane-write.ps1`, `validate-agent-dispatch.ps1`, `validate-researcher-bash.ps1`, `validate-scribe-write.ps1`, `validate-design-prototype-write.ps1`, `validate-judge-command.ps1`, and `validate-terminal-packet.ps1`.
>     - Governance contract `AGENTS.md` and porting documentation `docs/CODEX-HARNESS.md`, `docs/CODEX-PORTING-GUIDE.md` created.
>     - Hook test packet fixture `tests/codex-parity/fixtures/hooks/test-hook-packet.json` created.
>     - Strict configuration test gate `tests/codex-parity/test-strict-config.ps1` created and executed: 4/4 gates PASSED (including live `codex sandbox -P snapshot-isolated` exit 0).
>     - Hook verification test gate `tests/codex-parity/test-codex-hooks.ps1` created and executed: 6/6 gates PASSED.
> - **Next Action**:
>   - Begin Phase 2: Shared Process Launcher, C# Async Helper with Test Seam, Resolver Module, Adapters, TOML Serializer & Test Broker (`.agents/scripts/*`).
> - **Blockers**: None. (Phase 1 complete with all verification gates passing; awaiting explicit user instruction to begin Phase 2).
> - **Validation Evidence**:
>   - Phase 0 Audit: 116 items audited, 0 collisions, raw git status byte-identical, dirty inventory 100% hash invariant.
>   - Phase 1 Strict Config Gate (`tests/codex-parity/test-strict-config.ps1`):
>     - Gate 1 PASS: `.codex/config.toml` strict structure and key order verified.
>     - Gate 2 PASS: Snapshot-isolated profile definition and network lockdown verified.
>     - Gate 3 PASS: TOML parser verification (zero syntax errors).
>     - Gate 4 PASS: Live `codex sandbox -P snapshot-isolated` execution emitted `PROFILE_OK` with exit 0.
>   - Phase 1 Hook Verification Gate (`tests/codex-parity/test-codex-hooks.ps1`):
>     - Gate 1 PASS: `.codex/hooks.json` schema validation passed.
>     - Gate 2 PASS: All hook scripts exist and are non-empty.
>     - Gate 3 PASS: PowerShell AST parser passed with zero syntax errors across all 7 hook scripts.
>     - Gate 4 PASS: Control plane write protection behavioral gate passed (both payload and CLI arguments).
>     - Gate 5 PASS: Researcher Bash validator behavioral gate passed (pipeline execution and argument checks).
>     - Gate 6 PASS: Terminal packet validator behavioral gate passed (pipeline execution and packet checks).
> - **Append-Only Progress Log**:
>   - `2026-10-01T11:12:37-04:00`: Explicit user implementation approval received.
>   - `2026-10-01T11:13:45-04:00`: Root governance plan `CODEX-HARNESS-MIGRATION-PLAN.md` established in repository root. Status marked APPROVED / Phase 0 not yet executed.
>   - `2026-10-01T11:24:07-04:00`: Corrected status header review count to 39 reviews PASS 100/100 and pointed source artifact to root plan.
>   - `2026-10-01T11:38:37-04:00`: Frozen root plan SHA-256 computed: `53845c155f1003c42dd726383e7fd12612e7d7b45afd60b78f805d3d2cda96ee`. Extracted `codex-implementation-manifest.schema.json` and materialized schema-valid approved manifest `codex-implementation-manifest.json` tied to user approval turn in OS temp. Validated via `Test-Json` (PASS).
>   - `2026-10-01T11:39:47-04:00`: Executed external Phase 0 outer gate `codex-outer-gate.ps1`. Gate terminated fail-closed: `Cannot bind argument to parameter 'Lines' because it is an empty string.` Stopped fail-closed without mutating repository or proceeding to Phase 1. All preexisting dirty and untracked files preserved intact.
>   - `2026-10-01T11:43:10-04:00`: User approved Phase 0 remediation. Recorded plan erratum on `Extract-MarkdownCodeFenceFromLines` parameter binding for empty lines. Status set to IN PROGRESS. Amended plan with `[AllowEmptyString()]` across controller and outer gate copies. Plan re-frozen for re-hashing and gate retry.
>   - `2026-10-01T11:48:42-04:00`: Re-frozen plan SHA-256 computed: `ba6cdcde35f32e546de2aa621bbfe15788b35445d0876eada010851b0d67bfa1`. Manifest regenerated and validated via `Test-Json` (PASS).
>   - `2026-10-01T11:49:21-04:00`: Re-executed external Phase 0 outer gate `codex-outer-gate.ps1`. Gate parameter binding passed and controller staged. Controller failed fail-closed on Roslyn C# compilation: error CS1519 `Invalid token ';' in a member declaration: public cntThreads;`. Staged controller directory cleaned up. Status set to BLOCKED. Preexisting repository files 100% preserved intact.
>   - `2026-10-01T11:51:55-04:00`: User approved Phase 0 remediation under same authority. Recorded second plan erratum (Roslyn CS1519 missing uint type specifier on cntThreads). Status set to IN PROGRESS. Amended line 2680 to `public uint cntThreads;` and verified type consistency across all 5 struct copies. Plan re-frozen for re-hashing and gate retry.
>   - `2026-10-01T11:54:22-04:00`: Re-frozen plan SHA-256 computed: `cc81bbe909e75602c5adbec95197f17f2d168eae7db2e471f2244343f2caf700`. Manifest regenerated and validated via `Test-Json` (PASS).
>   - `2026-10-01T11:55:03-04:00`: Complete Phase 0 External Audit Gate executed and PASSED. All 116 items verified collision-free, raw git status invariant, dirty inventory 100% hash invariant. Generated intended manifest and baseline snapshot in `runtime/audit/` (installation ID `fc5dc440b2264c57a033d2da08e9ac21`). Phase 0 complete; next action is Phase 1. Stopped without beginning Phase 1.
>   - `2026-10-01T13:15:30-04:00`: Phase 1 Core Configuration, Schemas & Hooks Infrastructure executed and completed. Created `.codex/config.toml`, `.codex/requirements.template.toml`, `.codex/schemas/codex-agent.schema.json`, `.codex/schemas/codex-hooks.schema.json`, `.codex/hooks.json`, 7 hook validators under `.codex/hooks/`, `AGENTS.md`, `docs/CODEX-HARNESS.md`, `docs/CODEX-PORTING-GUIDE.md`, and test gates `test-strict-config.ps1` & `test-codex-hooks.ps1` with fixture packet. Executed and verified both test gates under PowerShell 7 (100% PASS). Preexisting repository files preserved. Phase 1 complete; stopped before Phase 2.

---

# Definitive Codex CLI Harness Migration Implementation Plan (Thirty-Fourth Native Review Resolution - Schema Materialization & Dual-Path Outer Gate Validation)

## Executive Summary & Goal Description

This document establishes the definitive, additive, coexistence-safe architecture and complete step-by-step implementation plan for integrating a first-class **OpenAI Codex CLI** harness within `H:\CommandCenter\orchestrator`, operating side-by-side with the existing **Claude Code** harness.

All inputs from the capability ledger are treated as authoritative and inviolable. Photo Genie patterns and external unrelated files remain strictly ignored.

This thirty-fourth native review revision definitively resolves all external schema materialization, dual-path outer gate validation, and intent-authority boundaries in full with complete literal code and zero placeholders:

1. **Materialization of Implementation Manifest Schema (`codex-implementation-manifest.schema.json`)**:
   - Materialized directly beside artifacts in the conversation workspace as a formal JSON Schema draft 2020-12 document.
   - Enforces `additionalProperties: false` at top-level and across nested objects.
   - Enforces exact security constants:
     - `manifest_id = "codex-cli-harness-migration-manifest-v34"`
     - `schema_version = "1.0.0"`
     - `repo_root = "H:\\CommandCenter\\orchestrator"`
     - `total_planned_items = 116`
     - `execution_constraints.powershell_major_version = 7`
     - `execution_constraints.total_cleanup_budget_ms = 3000`
     - `execution_constraints.authoritative_subdeadline_ms = 2250`
     - `execution_constraints.emergency_reserve_ms = 750`
     - `execution_constraints.max_tracked_descendants = 64`
   - Defines strict `oneOf` lifecycle branches:
     - `pending_user_approval`: Requires `status = "pending_user_approval"`, requires `source_plan_sha256: null`, `approved_by: null`, `approved_at_utc: null`, and `approval_event_reference: null`. Execution is strictly prohibited.
     - `approved`: Requires `status = "approved"`, `source_plan_sha256` matching `^[0-9a-fA-F]{64}$`, `approved_by = "user"`, `approved_at_utc` in valid ISO 8601 date-time format, and non-empty `approval_event_reference`.

2. **Dual-Path Outer Orchestration Gate (`-ManifestPath` & `-SchemaPath`)**:
   - The outer implementation gate strictly accepts both `-ManifestPath` and `-SchemaPath`.
   - Both paths are canonicalized, validated to exist as regular leaf files, and inspected for reparse points along their entire ancestor hierarchy up to drive root.
   - Exact bytes of both files are read into memory.
   - Manifest JSON is formally validated against the schema using PowerShell `Test-Json -SchemaFile $canonicalSchema` (or supported validator), capturing validation failure fail-closed.
   - The outer gate additionally explicitly checks every security-critical constant: `manifest_id`, `schema_version`, `status == "approved"`, `approved_by == "user"`, `total_planned_items == 116`, and execution constraints (`3000`, `2250`, `750`, `64`, `powershell >= 7`).
   - Strict UTF-8 decodes `manifestBytes` into `manifestRaw`, validates raw manifest JSON DOM via `[System.Text.Json.JsonDocument]::Parse([string]$manifestRaw)` before `ConvertFrom-Json`: declares typed out `[System.Text.Json.JsonElement]` variables for `TryGetProperty`; requires approved status to have JSON string ending ordinal Z or +00:00 (rejects -00:00/nonzero/no zone), parses via `[System.DateTimeOffset]::TryParse` invariant `RoundtripKind` and Offset zero; requires pending status to have JSON null; only afterward `ConvertFrom-Json`.
   - Eliminates all unreachable URL schema dependencies: the companion pending manifest `$schema` field uses a local relative filename (`"./codex-implementation-manifest.schema.json"`).

3. **Accurate Authority Boundary & Zero Intent Fabrication**:
   - **Audit Record Invariant**: The manifest approval fields are an audit record, **not** cryptographic proof of user intent.
   - **Root Orchestrator Authority**: The root orchestrator is the sole authority and may transition the external pending manifest only in direct response to an actual explicit user approval message in this active conversation turn, recording the host-provided event reference if available.
   - **Phase 0 Strict Prohibition**: Until explicit user approval is granted in this conversation, the companion manifest remains in `pending_user_approval` status with null approval/hash fields, and Phase 0 execution is strictly prohibited.
   - **Dual Authorization Requirement**: Phase 0 requires both orchestrator authorization in the active turn AND a schema-valid approved manifest. Mutable fields alone never authorize execution.
   - **User Has Not Approved Now**: The user has reviewed this document in plan mode; no approval has been granted. Zero event IDs, timestamps, or hashes are fabricated.

4. **Inviolable Preservation of Verified Architecture, Gates & Proofs**:
   - Strict PowerShell variable interpolation before colons (`$($var):` / `${var}:`) eliminating parser ambiguity across all scripts.
   - Authoritative subdeadline bounding on lingering taskkill helper processes across all 5 implementations (waited on only until 2250 ms, never into 750 ms emergency reserve, immediate `Kill(true)` at subdeadline, unverified classification, and immediate root emergency mitigation).
   - Hardened Win32 Toolhelp32 process tree snapshot C# helper (`WindowsProcessTreeSnapshot`) with `SetLastError = true`, error code inspection accepting only `ERROR_NO_MORE_FILES` (18), and handle closure in `finally`.
   - Universal 3000 ms global cleanup deadline with mandatory 750 ms emergency reserve and unconditional root emergency mitigation (`proc.Kill(true)`) without skip guards.
   - Authoritative 41-row skill adaptation ledger (29 Direct-Sync / 12 Adapted) with exact set equality.
   - Exact manifest arithmetic: 116 items (109 declarative + 5 runtime-owned + 2 dynamic per-run GUID audit files).
   - Raw git status byte carrier using PowerShell unary comma operator (`, $rawBytes`).
   - Complete Level 2 verification gates: Axis A (Filesystem Hard-Fence Parity) and Axis B (Elevated Windows Network & User Isolation).
   - All 9 concurrent I/O test cases (Cases 0, 1A, 1B, 2, 3, 4, 5A, 5B, 6) in `test-codex-launcher.ps1` with internal observer test seam.
   - Deterministic line-based Markdown fence extraction bounded by unique HTML comment markers.

---

## User Review Required

> [!IMPORTANT]
> **Implementation Pending Explicit User Approval**:
> - The user has **not** approved implementation.
> - The root orchestrator is the authority and may transition the external pending manifest only in direct response to an actual explicit user approval message in this conversation.
> - Mutable manifest fields are an audit record, not cryptographic proof of user intent. Mutable fields alone never authorize execution.
> - Until explicit user approval is received, the external manifest remains in `pending_user_approval` status and Phase 0 bootstrap execution is strictly prohibited.

> [!IMPORTANT]
> **PowerShell Runtime Scoping & Dual-Harness Coexistence**:
> - PowerShell 7+ (`pwsh.exe`) is mandatory for all newly authored Codex harness components (`.agents/scripts/*`, `.codex/hooks/*`, `tests/codex-parity/*`). .NET Core's `ProcessStartInfo.ArgumentList`, C# in-memory compilation via `Add-Type`, and asynchronous Task APIs are required to eliminate quoting vulnerabilities, deadlocks, and shell command concatenation.
> - **Existing Claude Code components remain untouched**: Existing scripts in `.claude/` and repository tests in `tests/` that invoke `powershell.exe` (Windows PowerShell 5.1) are preserved in their native working state.
> - The test broker and test suites execute each tool under its intended, verified runtime.

> [!WARNING]
> **Two-Tier Readiness & Independent Level 2 Verification Axes**:
> - **Level 1 (Functional-Project Readiness)**: Fully operational out-of-the-box in `H:\CommandCenter\orchestrator` without administrative elevation. Uses `.codex/config.toml` (`sandbox_mode = "workspace-write"`, `approval_policy = "on-request"`, active `[permissions.snapshot-isolated]` profile) and PreToolUse hooks.
> - **Level 2 (Full Hard-Fence Parity)**: Requires administrator privileges (UAC elevation) to deploy `%ProgramData%\OpenAI\Codex\requirements.toml`.
> - **Two Independent Level 2 Verification Axes**:
>   - *Axis A (Filesystem Hard-Fence Parity)*: Validated through exact protected path write denial via true outer-to-inner wrapper sandboxing and inner positive control. Requires positive controls pass, parent validates exactly 5 unique expected target records, mutation exits exactly 13, single valid JSON result, classified access-denied CLR/HRESULT error evidence without regex, zero launcher/syntax/config/timeout/missing-file error, and baseline file hash byte-identical.
>   - *Axis B (Elevated Windows Network & User Isolation)*: Validated through bounded outside HTTPS connection response, inside diagnostic exit 0 without timeout, and exact match against administrator-supplied allowlist. If unavailable, reported as `NOT VERIFIED`.

> [!CAUTION]
> **Phase 0 Bootstrap Discipline & Live File Inviolability**:
> - The Phase 0 audit driver resides strictly outside the repository workspace in an exclusively created temporary GUID directory (`[System.IO.Path]::GetTempPath()\codex-phase0-<guid>\invoke-phase0-audit.ps1`).
> - The implementation controller stages the driver bytes, verifies canonical non-reparse temp ancestry, creates the directory via atomic `CreateDirectoryW` fail-if-exists, writes with `FileMode.CreateNew`, hashes back, executes the driver, and cleans only the marker-owned temp directory in `finally`.
> - All mutation tests in Phase 7 operate strictly on disposable checkouts (`runtime/validation-checkouts/<guid>/`) containing syntactically valid sacrificial sentinels. Mutation attempts against live repository files are strictly prohibited.

---

## Implementation Manifest Specification (Decoupled External Approval & Hash Pinning)

To decouple normative execution from the text of this plan, eliminate circular self-referential hash paradoxes, and prevent any fabricated approval claims, harness bootstrapping and Phase 0 execution are governed by an **External Implementation Manifest**.

### 1. Formal Implementation Manifest JSON Schema (`codex-implementation-manifest.schema.json`)

Materialized at `C:\Users\robob\.gemini\antigravity-cli\brain\42a9f4d1-2218-4524-891c-2894965115fd\codex-implementation-manifest.schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "codex-implementation-manifest.schema.json",
  "title": "CodexImplementationManifest",
  "description": "Formal JSON Schema for external Codex harness migration implementation manifest. Decouples plan bytes from approval and hash state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "manifest_id",
    "schema_version",
    "status",
    "source_plan_path",
    "source_plan_sha256",
    "approved_by",
    "approved_at_utc",
    "approval_event_reference",
    "repo_root",
    "total_planned_items",
    "execution_constraints"
  ],
  "properties": {
    "$schema": {
      "type": "string"
    },
    "manifest_id": {
      "type": "string",
      "const": "codex-cli-harness-migration-manifest-v34"
    },
    "schema_version": {
      "type": "string",
      "const": "1.0.0"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending_user_approval",
        "approved"
      ]
    },
    "source_plan_path": {
      "type": "string",
      "minLength": 1
    },
    "source_plan_sha256": {
      "type": [
        "string",
        "null"
      ]
    },
    "approved_by": {
      "type": [
        "string",
        "null"
      ]
    },
    "approved_at_utc": {
      "type": [
        "string",
        "null"
      ],
      "format": "date-time"
    },
    "approval_event_reference": {
      "type": [
        "string",
        "null"
      ]
    },
    "repo_root": {
      "type": "string",
      "const": "H:\\CommandCenter\\orchestrator"
    },
    "total_planned_items": {
      "type": "integer",
      "const": 116
    },
    "execution_constraints": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "powershell_major_version",
        "total_cleanup_budget_ms",
        "authoritative_subdeadline_ms",
        "emergency_reserve_ms",
        "max_tracked_descendants"
      ],
      "properties": {
        "powershell_major_version": {
          "type": "integer",
          "const": 7
        },
        "total_cleanup_budget_ms": {
          "type": "integer",
          "const": 3000
        },
        "authoritative_subdeadline_ms": {
          "type": "integer",
          "const": 2250
        },
        "emergency_reserve_ms": {
          "type": "integer",
          "const": 750
        },
        "max_tracked_descendants": {
          "type": "integer",
          "const": 64
        }
      }
    }
  },
  "oneOf": [
    {
      "description": "Pending approval state requires null approval and hash fields, and strictly forbids execution.",
      "properties": {
        "status": {
          "const": "pending_user_approval"
        },
        "source_plan_sha256": {
          "type": "null"
        },
        "approved_by": {
          "type": "null"
        },
        "approved_at_utc": {
          "type": "null"
        },
        "approval_event_reference": {
          "type": "null"
        }
      }
    },
    {
      "description": "Approved state requires exact frozen source_plan_path, valid 64-hex source_plan_sha256, approved_by='user', and non-null approval timestamp and event reference.",
      "properties": {
        "status": {
          "const": "approved"
        },
        "source_plan_sha256": {
          "type": "string",
          "pattern": "^[0-9a-fA-F]{64}$"
        },
        "approved_by": {
          "type": "string",
          "const": "user"
        },
        "approved_at_utc": {
          "type": "string",
          "format": "date-time"
        },
        "approval_event_reference": {
          "type": "string",
          "minLength": 1
        }
      }
    }
  ]
}
```

### 2. Companion Pending Manifest (`codex-implementation-manifest.pending.json`)

Materialized at `C:\Users\robob\.gemini\antigravity-cli\brain\42a9f4d1-2218-4524-891c-2894965115fd\codex-implementation-manifest.pending.json`:

```json
{
  "$schema": "./codex-implementation-manifest.schema.json",
  "manifest_id": "codex-cli-harness-migration-manifest-v34",
  "schema_version": "1.0.0",
  "status": "pending_user_approval",
  "source_plan_path": "C:/Users/robob/.gemini/antigravity-cli/brain/42a9f4d1-2218-4524-891c-2894965115fd/codex_cli_harness_migration_plan.md",
  "source_plan_sha256": null,
  "approved_by": null,
  "approved_at_utc": null,
  "approval_event_reference": null,
  "repo_root": "H:\\CommandCenter\\orchestrator",
  "total_planned_items": 116,
  "execution_constraints": {
    "powershell_major_version": 7,
    "total_cleanup_budget_ms": 3000,
    "authoritative_subdeadline_ms": 2250,
    "emergency_reserve_ms": 750,
    "max_tracked_descendants": 64
  }
}
```

### 3. Manifest Lifecycle & Decoupled Approval Workflow

1. **Plan Authoring & Byte Freezing**:
   - The technical design document is authored, verified, and saved to disk.
   - Once saved, its byte sequence is frozen and immutable.
2. **Companion Pending Manifest Generation**:
   - A companion manifest file (`codex-implementation-manifest.pending.json`) is instantiated outside the repository root.
   - Its status is set to `"pending_user_approval"`.
   - `approved_by` is set to `null`.
   - `approved_at_utc` is set to `null`.
   - `approval_event_reference` is set to `null`.
   - `source_plan_path` points to the canonical path of the frozen plan file.
   - `source_plan_sha256` remains `null` until final bytes are frozen on disk; no hash is invented or assumed.
3. **Explicit User Approval Gate**:
   - The user reviews the frozen implementation plan artifact.
   - Upon explicit approval from the user, the companion manifest is updated:
     - The true SHA-256 hash of the frozen plan bytes is computed and recorded in `source_plan_sha256`.
     - `status` is transitioned to `"approved"`.
     - `approved_by` is set to `"user"`.
     - `approved_at_utc` is set to the current ISO-8601 UTC timestamp.
     - `approval_event_reference` records the user's approval instruction or conversation turn ID.
   - **Crucial Rule**: The plan document bytes are **never** mutated during or after approval.
4. **Phase 0 Gate Enforcement**:
   - The outer implementation gate accepts `-ManifestPath <canonical-path-to-manifest>` and `-SchemaPath <canonical-path-to-schema>`.
   - Validates the manifest against `codex-implementation-manifest.schema.json` using `Test-Json -SchemaFile`.
   - Validates that `status -eq 'approved'`. If status is `pending_user_approval` or any other value, execution terminates immediately fail-closed.
   - Validates that `approved_by -eq 'user'`, and that `approved_at_utc` and `approval_event_reference` are non-null and non-empty.
   - Validates raw `approved_at_utc` before `ConvertFrom-Json`: approved requires JSON string ending ordinal Z or +00:00, rejects -00:00/nonzero/no zone, TryParse invariant RoundtripKind and Offset zero; pending requires JSON null; only afterward `ConvertFrom-Json`.
   - Performs a single `ReadAllBytes` on `source_plan_path`, computes SHA-256, verifies ordinal match against `source_plan_sha256`, decodes strictly with UTF-8, and extracts code fences from in-memory lines.

---

## Official Command Reference & Installed CLI Citations

1. **`codex sandbox` Non-LLM Runner**:
   - **Syntax**: `codex sandbox [OPTIONS] -- <COMMAND>...`
   - **Options**:
     - `-P, --permission-profile <PROFILE>`: Permission profile name (`:read-only`, `snapshot-isolated`, or `orchestrator-governed`).
     - `-C, --cd <DIR>`: Sets target working directory and anchors relative profile paths (never `--cwd`).
     - `--include-managed-config`: Incorporates managed enterprise configuration (`requirements.toml`).
     - `--`: Explicit argument separator. All trailing arguments pass directly to the OS process loader without LLM interpretation.
   - **Reference**: [Codex Developer Commands Reference](https://learn.chatgpt.com/docs/developer-commands), `codex sandbox --help`.

2. **`codex exec` Ephemeral Headless Execution with Stdin Prompt**:
   - **Syntax**: `codex exec [OPTIONS] -`
   - **Options**:
     - `-c, --config <KEY=VALUE>`: Dynamic configuration overrides, specifically `-c developer_instructions=<TOML-basic-string>`.
     - `--sandbox <MODE>`: Execution sandbox mode (`read-only` or `workspace-write`).
     - `-m, --model <MODEL>`: Target LLM model.
     - `-c model_reasoning_effort=<EFFORT>`: Model reasoning effort (`low`, `medium`, `high`).
     - `--ephemeral`: Isolated session without persisting to session history.
     - `--json`: Formats output events as newline-delimited JSON.
     - `-o, --output-last-message <PATH>`: Writes final response message to file (never `--output`).
     - `-`: Dash prompt argument indicating prompt content is provided via standard input (stdin).
   - **Reference**: [Codex Developer Commands Reference](https://learn.chatgpt.com/docs/developer-commands), `codex exec --help`.

3. **`codex --worktree` Native Flag**:
   - **Syntax**: `codex --worktree` (Valueless boolean flag). Positional arguments (`codex --worktree <name>`) are invalid.
   - **Reference**: [Codex Worktrees Manual](https://learn.chatgpt.com/docs/worktrees).

4. **Configuration Discovery & Environment Overrides (`CODEX_HOME`)**:
   - When `$CODEX_HOME` is set, it serves as the complete Codex state root for that child process, encapsulating `config.toml`, authentication state (`auth.json`), logs, session history, and cached skills. It replaces `%USERPROFILE%\.codex`.
   - Project configuration (`.codex/config.toml`) is discovered separately from the project working tree upwards.
   - **Reference**: [Codex Configuration Reference](https://learn.chatgpt.com/docs/configuration).

5. **Windows Sandbox Architecture**:
   - **Elevated Mode (`[windows] sandbox = "elevated"`)**: Utilizes a dedicated Windows service user and Windows Defender Firewall rules for kernel-level socket and process isolation.
   - **Unelevated Mode (`[windows] sandbox = "unelevated"`)**: Utilizes Windows Restricted Tokens (`CreateRestrictedToken`) and filesystem ACLs.
   - **Reference**: [Codex Windows Sandboxing Guide](https://learn.chatgpt.com/docs/windows).

---

## PowerShell Scoping & Direct Process Execution Architecture

### 1. Scope Boundary: PowerShell 7 (`pwsh.exe`) vs Windows PowerShell (`powershell.exe`)

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                             COEXISTENCE POWERSHELL SCOPING                             │
├───────────────────────────────────────────┬────────────────────────────────────────────┤
│ NEW CODEX CLI HARNESS ASSETS              │ EXISTING CLAUDE CODE ASSETS                │
│ (Requires PowerShell 7+ pwsh.exe)         │ (Preserved under powershell.exe / Host PS) │
├───────────────────────────────────────────┼────────────────────────────────────────────┤
│ • .agents/scripts/ProcessRunnerHelper.cs  │ • .claude/hooks/*.ps1                      │
│ • .agents/scripts/CodexLauncherResolver.psm1│ • .claude/skills/*                      │
│ • .agents/scripts/invoke-codex-process.ps1│ • tests/validate.ps1                       │
│ • .agents/scripts/orchestrate-role.ps1    │ • tests/test-research-hooks.ps1            │
│ • .agents/scripts/test-broker.ps1         │ • tests/test-design-hooks.ps1              │
│ • .agents/scripts/trusted-writer.ps1      │ • tests/test-agent-protocol-hooks.ps1      │
│ • .agents/scripts/toml-serializer.ps1     │ • tests/test-codex-judge.ps1               │
│ • .agents/scripts/invoke-claude-judge.ps1 │ • tests/test-statusline.ps1                │
│ • .codex/hooks/*.ps1                      │ • tests/test-control-plane-write-hook.ps1  │
│ • Staged temp/invoke-phase0-audit.ps1     │ • tests/verify-governance.ps1              │
│ • tests/codex-parity/*.ps1                │                                            │
├───────────────────────────────────────────┴────────────────────────────────────────────┤
│ RATIONALE:                                                                             │
│ 1. Codex harness constructs process arguments dynamically, requiring ArgumentList      │
│    (available only in .NET Core 2.1+ / .NET 5+ under PowerShell 7+).                   │
│ 2. Asynchronous concurrent non-deadlocking I/O requires C# native Task APIs loaded     │
│    cleanly via Add-Type in pwsh 7.                                                     │
│ 3. Existing Claude scripts and tests run in production on the host; preserving them    │
│    unchanged guarantees zero regression of the active Claude harness.                  │
│ 4. The test broker executes each harness under its validated, intended shell.          │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2. Runtime Prerequisite Assertion Helper with Feature Probing

Every newly authored Codex harness script includes this runtime assertion, which feature-probes `ProcessStartInfo.ArgumentList`, `Process.WaitForExitAsync` with a true strongly typed `[System.Type[]]` array, and Roslyn `Add-Type` compilation validated via `-PassThru` and `PSTypeName`:

```powershell
function Assert-PowerShell7Prerequisite {
    [CmdletBinding()]
    param()

    # 1. Shell Major Version Check (PowerShell 7+ required; documented minimum: PS 7.2+ LTS on .NET 6.0+)
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "Fail-closed: PowerShell 7+ (pwsh.exe) is required for Codex harness operations. Running under PowerShell $($PSVersionTable.PSVersion). Windows PowerShell 5.1 is unsupported for this script."
    }

    # 2. Feature Probe: ProcessStartInfo.ArgumentList (.NET Core 2.1+)
    $argProp = [System.Diagnostics.ProcessStartInfo].GetProperty('ArgumentList')
    if (-not $argProp) {
        throw "Fail-closed: System.Diagnostics.ProcessStartInfo.ArgumentList property is not available in the current runtime environment."
    }

    # 3. Feature Probe: Process.WaitForExitAsync (.NET 5+) using True Type Array & GetMethods Filter
    $tokenType = [System.Threading.CancellationToken]
    $typeArray = [System.Type[]]@($tokenType)
    $waitForExitAsyncMethod = [System.Diagnostics.Process].GetMethod('WaitForExitAsync', $typeArray)
    
    if (-not $waitForExitAsyncMethod) {
        $waitForExitAsyncMethod = [System.Diagnostics.Process].GetMethod('WaitForExitAsync', [System.Type]::EmptyTypes)
    }
    
    if (-not $waitForExitAsyncMethod) {
        $waitForExitAsyncMethod = [System.Diagnostics.Process].GetMethods() | Where-Object {
            $_.Name -eq 'WaitForExitAsync' -and
            $_.GetParameters().Count -eq 1 -and
            $_.GetParameters()[0].ParameterType -eq [System.Threading.CancellationToken]
        } | Select-Object -First 1
    }

    if (-not $waitForExitAsyncMethod) {
        throw "Fail-closed: System.Diagnostics.Process.WaitForExitAsync method is not available in the current runtime environment (.NET 5+ required)."
    }

    # 4. Feature Probe: Roslyn Add-Type Compilation Validated via -PassThru & PSTypeName
    $probeTypeName = "CodexHarnessPrereqProbe_" + [System.Guid]::NewGuid().ToString('N')
    $probeSource = @"
namespace CodexHarnessPrereq {
    public static class $probeTypeName {
        public static bool IsSupported() => true;
    }
}
"@
    try {
        $compiledTypes = Add-Type -TypeDefinition $probeSource -Language CSharp -PassThru -ErrorAction Stop
        $probeType = $compiledTypes | Where-Object { $_.FullName -eq "CodexHarnessPrereq.$probeTypeName" } | Select-Object -First 1
        
        if (-not $probeType) {
            $probeType = ([System.Management.Automation.PSTypeName]"CodexHarnessPrereq.$probeTypeName").Type
        }
        
        if (-not $probeType -or -not ($probeType::IsSupported())) {
            throw "Probe type CodexHarnessPrereq.$probeTypeName could not be resolved or invoked after compilation."
        }
    } catch {
        throw "Fail-closed: Add-Type C# compilation probe failed. A working C# compiler (Roslyn/dotnet toolchain) is required: $_"
    }
}
```

### 3. Trusted `pwsh.exe` Discovery & Resolution

```powershell
function Resolve-TrustedPwsh {
    [CmdletBinding()]
    param()

    # 1. Check current process executable if running under pwsh
    $currentProc = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if ($currentProc -match '(?i)pwsh\.exe$' -and (Test-Path -LiteralPath $currentProc -PathType Leaf)) {
        return [System.IO.Path]::GetFullPath($currentProc)
    }

    # 2. Check PATH
    $pwshCmd = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
    if ($pwshCmd -and $pwshCmd.Source -match '(?i)pwsh\.exe$' -and (Test-Path -LiteralPath $pwshCmd.Source -PathType Leaf)) {
        return [System.IO.Path]::GetFullPath($pwshCmd.Source)
    }

    # 3. Check standard Windows PowerShell 7 install paths
    $candidatePaths = @(
        (Join-Path $env:ProgramFiles "PowerShell\7\pwsh.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "PowerShell\7\pwsh.exe"),
        (Join-Path $env:LOCALAPPDATA "Microsoft\PowerShell\pwsh.exe")
    )
    foreach ($cand in $candidatePaths) {
        if (Test-Path -LiteralPath $cand -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($cand)
        }
    }

    throw "Fail-closed: PowerShell 7 executable (pwsh.exe) could not be resolved on PATH or standard install locations."
}
```

---

## Namespaced .NET C# Helper with Atomic Filesystem & Process Seams

Process execution, resolution, and atomic directory creation are strictly partitioned into three cohesive components:
1. **A side-effect-free launcher resolver module (`CodexLauncherResolver.psm1`)** that resolves binary and npm shim entry points through pure filesystem inspection with no mandatory parameters and strictly zero process execution.
2. **A compiled .NET C# helper (`ProcessRunnerHelper.cs`)** implementing:
   - Atomic directory creation via PInvoke `CreateDirectoryW` fail-if-exists semantics (`CodexHarness.NativeFileSystem`).
   - Pure native asynchronous I/O with verified timeout tree cleanup, mandatory canonical `taskkill` exit 0 evidence, an internal `ITreeKiller` test seam with a dedicated test shim in the same assembly, and distinct `TreeCleanupUnverifiedException` classification. Public production `ExecuteProcessAsync` has strictly no observer parameter.
   - Global single-Stopwatch cleanup budget (**3000 ms total** with a mandatory reserved emergency window of **750 ms**, giving an authoritative subdeadline of **2250 ms**) spanning taskkill exit, drains, unconditional root kill mitigation, and affirmative process exit checks.
3. **A PowerShell 7 launcher (`invoke-codex-process.ps1`)** that imports the resolver module, configures `ProcessStartInfo.ArgumentList`, enforces environment modes, and calls the public production C# helper.

### 1. Namespaced .NET C# Helper Source (`.agents/scripts/ProcessRunnerHelper.cs`)

```csharp
#nullable enable
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarness
{
    public static class NativeFileSystem
    {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CreateDirectoryW(string lpPathName, IntPtr lpSecurityAttributes);

        /// <summary>
        /// Creates a directory atomically with fail-if-exists semantics via Win32 CreateDirectoryW.
        /// Throws IOException if directory already exists (ERROR_ALREADY_EXISTS = 183) or on other Win32 errors.
        /// </summary>
        public static bool CreateDirectoryFailIfExists(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                throw new ArgumentNullException(nameof(path));
            }

            string fullPath = Path.GetFullPath(path);
            if (!CreateDirectoryW(fullPath, IntPtr.Zero))
            {
                int error = Marshal.GetLastWin32Error();
                throw new IOException($"CreateDirectoryW failed for '{fullPath}' with Win32 error code {error}.");
            }
            return true;
        }
    }

    public class TreeCleanupUnverifiedException : InvalidOperationException
    {
        public TreeCleanupUnverifiedException(string message) : base(message) { }
        public TreeCleanupUnverifiedException(string message, Exception innerException) : base(message, innerException) { }
    }

    public class ProcessObserverSetupException : InvalidOperationException
    {
        public ProcessObserverSetupException(string message) : base(message) { }
        public ProcessObserverSetupException(string message, Exception innerException) : base(message, innerException) { }
    }

    public sealed class ProcessExecutionResult
    {
        public int ExitCode { get; set; }
        public string Stdout { get; set; } = string.Empty;
        public string Stderr { get; set; } = string.Empty;
        public bool TimedOut { get; set; }
        public bool TreeCleanupUnverified { get; set; }
        public bool StdinCompleted { get; set; }
        public bool StdoutDrained { get; set; }
        public bool StderrDrained { get; set; }
    }

    internal sealed class TreeKillResult
    {
        public bool CompletedWithinTimeout { get; set; }
        public int? ExitCode { get; set; }
        public bool ExitZero { get; set; }
        public string Stdout { get; set; } = string.Empty;
        public string Stderr { get; set; } = string.Empty;
    }

    internal interface ITreeKiller
    {
        TreeKillResult KillProcessTree(int processId, int totalTimeoutMs);
    }

    internal sealed class WindowsTaskkillTreeKiller : ITreeKiller
    {
        public TreeKillResult KillProcessTree(int processId, int totalTimeoutMs)
        {
            var result = new TreeKillResult();
            var sw = Stopwatch.StartNew();

            try
            {
                // 1. Derive absolute canonical SystemRoot\System32\taskkill.exe
                string systemRoot = Environment.GetFolderPath(Environment.SpecialFolder.Windows);
                if (string.IsNullOrWhiteSpace(systemRoot))
                {
                    systemRoot = Environment.GetEnvironmentVariable("SystemRoot") ?? @"C:\Windows";
                }
                string canonicalSystem32 = Path.GetFullPath(Path.Combine(systemRoot, "System32"));
                if (!canonicalSystem32.EndsWith(Path.DirectorySeparatorChar.ToString()))
                {
                    canonicalSystem32 += Path.DirectorySeparatorChar;
                }

                string fullTaskkillPath = Path.GetFullPath(Path.Combine(canonicalSystem32, "taskkill.exe"));

                // 2. Validate path containment strictly within canonical System32
                if (!fullTaskkillPath.StartsWith(canonicalSystem32, StringComparison.OrdinalIgnoreCase))
                {
                    result.Stderr = $"Security violation: taskkill path escapes canonical System32: {fullTaskkillPath}";
                    return result;
                }

                // 3. Validate regular file and zero reparse point on taskkill.exe
                var fi = new FileInfo(fullTaskkillPath);
                if (!fi.Exists)
                {
                    result.Stderr = $"Fail-closed: taskkill.exe does not exist at canonical path: {fullTaskkillPath}";
                    return result;
                }
                if ((fi.Attributes & FileAttributes.ReparsePoint) != 0)
                {
                    result.Stderr = $"Security violation: taskkill.exe is a reparse point: {fullTaskkillPath}";
                    return result;
                }

                // 4. Validate zero reparse points on all ancestor directories up to system root
                var dir = fi.Directory;
                while (dir != null && dir.FullName.Length >= systemRoot.Length)
                {
                    if (dir.Exists && (dir.Attributes & FileAttributes.ReparsePoint) != 0)
                    {
                        result.Stderr = $"Security violation: reparse point detected in taskkill ancestor: {dir.FullName}";
                        return result;
                    }
                    dir = dir.Parent;
                }

                // 5. Execute taskkill using ONLY the validated absolute path
                var killPsi = new ProcessStartInfo
                {
                    FileName = fullTaskkillPath,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                };
                killPsi.ArgumentList.Add("/PID");
                killPsi.ArgumentList.Add(processId.ToString());
                killPsi.ArgumentList.Add("/T");
                killPsi.ArgumentList.Add("/F");

                using var killProc = Process.Start(killPsi);
                if (killProc == null)
                {
                    result.Stderr = "Failed to start taskkill process.";
                    return result;
                }

                var kOutTask = killProc.StandardOutput.ReadToEndAsync();
                var kErrTask = killProc.StandardError.ReadToEndAsync();

                // 6. True global deadline: compute remaining = totalTimeoutMs - elapsed. Never Math.Max or minimum wait.
                int remainingExitMs = totalTimeoutMs - (int)sw.ElapsedMilliseconds;
                if (remainingExitMs <= 0 || !killProc.WaitForExit(remainingExitMs))
                {
                    try { killProc.Kill(); } catch { }
                    result.CompletedWithinTimeout = false;
                    result.Stderr = $"taskkill process did not exit within total budget of {totalTimeoutMs} ms.";
                    return result;
                }

                int remainingDrainMs = totalTimeoutMs - (int)sw.ElapsedMilliseconds;
                if (remainingDrainMs <= 0)
                {
                    result.CompletedWithinTimeout = false;
                    result.Stderr = $"taskkill streams did not drain within total budget of {totalTimeoutMs} ms.";
                    return result;
                }

                var streamsTask = Task.WhenAll(kOutTask, kErrTask);
                if (!streamsTask.Wait(remainingDrainMs))
                {
                    result.CompletedWithinTimeout = false;
                    result.Stderr = $"taskkill stdout/stderr drain timed out within remaining budget ({remainingDrainMs} ms).";
                    return result;
                }

                // 7. Success within budget
                result.CompletedWithinTimeout = true;
                result.Stdout = kOutTask.Result;
                result.Stderr = kErrTask.Result;
                result.ExitCode = killProc.ExitCode;
                result.ExitZero = (killProc.ExitCode == 0);
            }
            catch (Exception ex)
            {
                result.CompletedWithinTimeout = false;
                result.Stderr = ex.Message;
            }
            return result;
        }
    }

    internal sealed class FailingTreeKiller : ITreeKiller
    {
        private readonly int _exitCode;
        private readonly bool _simulateTimeout;
        private readonly string _errorMessage;

        public FailingTreeKiller(int exitCode = 1, bool simulateTimeout = false, string errorMessage = "Simulated tree kill failure")
        {
            _exitCode = exitCode;
            _simulateTimeout = simulateTimeout;
            _errorMessage = errorMessage;
        }

        public TreeKillResult KillProcessTree(int processId, int totalTimeoutMs)
        {
            if (_simulateTimeout)
            {
                return new TreeKillResult
            {
                    CompletedWithinTimeout = false,
                    ExitCode = null,
                    ExitZero = false,
                    Stderr = "Simulated taskkill timeout"
                };
            }

            return new TreeKillResult
            {
                CompletedWithinTimeout = true,
                ExitCode = _exitCode,
                ExitZero = (_exitCode == 0),
                Stderr = _errorMessage
            };
        }
    }

    public static class NativeProcessRunnerTestShim
    {
        public static Task<ProcessExecutionResult> ExecuteWithObserverAsync(
            ProcessStartInfo psi,
            string? stdinText,
            int timeoutSeconds,
            Action<Process>? onProcessStarted = null)
        {
            return NativeProcessRunner.ExecuteProcessInternalAsync(
                psi, stdinText, timeoutSeconds, new WindowsTaskkillTreeKiller(), onProcessStarted);
        }

        public static Task<ProcessExecutionResult> ExecuteWithFailingTreeKillerAsync(
            ProcessStartInfo psi,
            string? stdinText,
            int timeoutSeconds,
            int simulatedExitCode = 1,
            bool simulateTimeout = false,
            Action<Process>? onProcessStarted = null)
        {
            var killer = new FailingTreeKiller(simulatedExitCode, simulateTimeout, "Simulated taskkill failure from test shim");
            return NativeProcessRunner.ExecuteProcessInternalAsync(psi, stdinText, timeoutSeconds, killer, onProcessStarted);
        }
    }

    public static class NativeProcessRunner
    {
        // Public production method: strictly always uses concrete WindowsTaskkillTreeKiller with NO observer parameter
        public static Task<ProcessExecutionResult> ExecuteProcessAsync(
            ProcessStartInfo psi,
            string? stdinText,
            int timeoutSeconds)
        {
            return ExecuteProcessInternalAsync(psi, stdinText, timeoutSeconds, new WindowsTaskkillTreeKiller(), null);
        }

        // Internal test seam: accepts ITreeKiller dependency and optional process started callback
        internal static async Task<ProcessExecutionResult> ExecuteProcessInternalAsync(
            ProcessStartInfo psi,
            string? stdinText,
            int timeoutSeconds,
            ITreeKiller treeKiller,
            Action<Process>? onProcessStarted = null)
        {
            if (psi == null) throw new ArgumentNullException(nameof(psi));
            if (treeKiller == null) throw new ArgumentNullException(nameof(treeKiller));

            psi.UseShellExecute = false;
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError = true;
            psi.RedirectStandardInput = true;

            using var proc = new Process { StartInfo = psi };
            if (!proc.Start())
            {
                throw new InvalidOperationException($"Failed to start process: {psi.FileName}");
            }

            // Immediately invoke callback upon successful process start if provided (internal test seam only)
            if (onProcessStarted != null)
            {
                try
                {
                    onProcessStarted(proc);
                }
                catch (Exception observerEx)
                {
                    // Observer throw causes synchronous bounded tree kill verification under 3000 ms single deadline (750 ms mandatory emergency reserve)
                    var swObs = Stopwatch.StartNew();
                    const int totalObsBudgetMs = 3000;
                    const int reserveObsEmergencyMs = 750;
                    const int authoritativeObsSubdeadlineMs = totalObsBudgetMs - reserveObsEmergencyMs; // 2250 ms

                    var killResult = treeKiller.KillProcessTree(proc.Id, authoritativeObsSubdeadlineMs);
                    
                    bool procExited = false;
                    int remObsExitMs = authoritativeObsSubdeadlineMs - (int)swObs.ElapsedMilliseconds;
                    if ($remObsExitMs > 0)
                    {
                        try
                        {
                            procExited = proc.WaitForExit(remObsExitMs) || proc.HasExited;
                        }
                        catch { }
                    }
                    else
                    {
                        try { procExited = proc.HasExited; } catch { }
                    }

                    bool verifiedCleanup = killResult.CompletedWithinTimeout && killResult.ExitZero && procExited;
                    if (!verifiedCleanup)
                    {
                        // Universal emergency mitigation: ALWAYS attempt proc.Kill(true) bounded by final global deadline
                        // Never guard mitigation call with a remaining-time condition that can skip it
                        try
                        {
                            if (!proc.HasExited)
                            {
                                proc.Kill(entireProcessTree: true);
                                int remObsMitWaitMs = totalObsBudgetMs - (int)swObs.ElapsedMilliseconds;
                                if (remObsMitWaitMs > 0)
                                {
                                    proc.WaitForExit(remObsMitWaitMs);
                                }
                            }
                        }
                        catch { }

                        throw new TreeCleanupUnverifiedException(
                            $"TreeCleanupUnverified after observer setup throw for PID {proc.Id}. " +
                            $"Taskkill exit zero: {killResult.ExitZero}, Process exited: {procExited}.",
                            observerEx);
                    }

                    throw new ProcessObserverSetupException(
                        $"Process observer setup delegate failed during startup: {observerEx.Message}",
                        observerEx);
                }
            }

            using var cts = new CancellationTokenSource();
            var timeoutTask = Task.Delay(TimeSpan.FromSeconds(timeoutSeconds), cts.Token);

            var stdoutTask = proc.StandardOutput.ReadToEndAsync();
            var stderrTask = proc.StandardError.ReadToEndAsync();

            var stdinCompleted = false;
            async Task WriteStdinAsync()
            {
                try
                {
                    if (!string.IsNullOrEmpty(stdinText))
                    {
                        using var writer = new StreamWriter(proc.StandardInput.BaseStream, new UTF8Encoding(false), 4096, leaveOpen: false);
                        await writer.WriteAsync(stdinText).ConfigureAwait(false);
                        await writer.FlushAsync().ConfigureAwait(false);
                    }
                    else
                    {
                        proc.StandardInput.Close();
                    }
                    stdinCompleted = true;
                }
                catch (IOException)
                {
                    stdinCompleted = true;
                }
                catch (ObjectDisposedException)
                {
                    stdinCompleted = true;
                }
            }

            var stdinTask = WriteStdinAsync();
            var exitTask = proc.WaitForExitAsync();

            var allOpsTask = Task.WhenAll(stdinTask, exitTask, stdoutTask, stderrTask);
            var completedTask = await Task.WhenAny(allOpsTask, timeoutTask).ConfigureAwait(false);

            if (completedTask == timeoutTask)
            {
                // WATCHDOG EXPIRED: Process timed out. Invoke tree killer with single Stopwatch budget (total 3000 ms with 750 ms emergency reserve).
                var swWatchdog = Stopwatch.StartNew();
                const int totalWatchdogBudgetMs = 3000;
                const int reserveEmergencyMs = 750;
                const int authoritativeSubdeadlineMs = totalWatchdogBudgetMs - reserveEmergencyMs; // 2250 ms

                var killResult = treeKiller.KillProcessTree(proc.Id, authoritativeSubdeadlineMs);

                bool originalExited = false;
                int remProcExitMs = authoritativeSubdeadlineMs - (int)swWatchdog.ElapsedMilliseconds;
                if (remProcExitMs > 0)
                {
                    try
                    {
                        originalExited = proc.WaitForExit(remProcExitMs) || proc.HasExited;
                    }
                    catch { }
                }
                else
                {
                    try { originalExited = proc.HasExited; } catch { }
                }

                bool verifiedTreeCleanup = killResult.CompletedWithinTimeout && killResult.ExitZero && originalExited;

                if (!verifiedTreeCleanup)
                {
                    // Fallback emergency mitigation: ALWAYS call proc.Kill(entireProcessTree: true) bounded by remaining reserve
                    // Never guard mitigation call with a remaining-time condition that can skip it
                    try
                    {
                        if (!proc.HasExited)
                        {
                            proc.Kill(entireProcessTree: true);
                            int remFallbackWaitMs = totalWatchdogBudgetMs - (int)swWatchdog.ElapsedMilliseconds;
                            if (remFallbackWaitMs > 0)
                            {
                                proc.WaitForExit(remFallbackWaitMs);
                            }
                        }
                    }
                    catch { }

                    throw new TreeCleanupUnverifiedException(
                        $"TreeCleanupUnverified: Process tree termination could not be verified for PID {proc.Id}. " +
                        $"Taskkill completed: {killResult.CompletedWithinTimeout}, Taskkill exit code: {killResult.ExitCode}, " +
                        $"Taskkill exit zero: {killResult.ExitZero}, Original process exited: {originalExited}. " +
                        $"Taskkill stdout: '{killResult.Stdout}', Taskkill stderr: '{killResult.Stderr}'. Descendants are not independently proven gone.");
                }

                int remDrainBudgetMs = totalWatchdogBudgetMs - (int)swWatchdog.ElapsedMilliseconds;
                if (remDrainBudgetMs > 0)
                {
                    var cleanupDrainTask = Task.WhenAll(stdoutTask, stderrTask);
                    var cleanupTimeoutTask = Task.Delay(remDrainBudgetMs);
                    await Task.WhenAny(cleanupDrainTask, cleanupTimeoutTask).ConfigureAwait(false);
                }

                var partialStdout = stdoutTask.IsCompletedSuccessfully ? stdoutTask.Result : string.Empty;
                var partialStderr = stderrTask.IsCompletedSuccessfully ? stderrTask.Result : string.Empty;

                return new ProcessExecutionResult
                {
                    ExitCode = 124,
                    Stdout = partialStdout,
                    Stderr = $"Process timed out after {timeoutSeconds} seconds and process tree was verified terminated. Partial Stderr: {partialStderr}",
                    TimedOut = true,
                    TreeCleanupUnverified = false,
                    StdinCompleted = stdinCompleted,
                    StdoutDrained = stdoutTask.IsCompletedSuccessfully,
                    StderrDrained = stderrTask.IsCompletedSuccessfully
                };
            }

            cts.Cancel();
            await allOpsTask.ConfigureAwait(false);

            return new ProcessExecutionResult
            {
                ExitCode = proc.ExitCode,
                Stdout = stdoutTask.Result,
                Stderr = stderrTask.Result,
                TimedOut = false,
                TreeCleanupUnverified = false,
                StdinCompleted = stdinCompleted,
                StdoutDrained = true,
                StderrDrained = true
            };
        }
    }
}
```

### 2. Side-Effect-Free Launcher Resolution Module (`.agents/scripts/CodexLauncherResolver.psm1`)

```powershell
# .agents/scripts/CodexLauncherResolver.psm1
# Side-effect-free module for resolving the OpenAI Codex CLI launcher.
# Has NO mandatory execution parameters and NEVER starts a process.


function Resolve-NpmShim {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ShimPath
    )

    if (-not (Test-Path -LiteralPath $ShimPath -PathType Leaf)) {
        throw "Fail-closed: npm shim file does not exist: $ShimPath"
    }

    $shimContent = Get-Content -Raw -LiteralPath $ShimPath
    if ([string]::IsNullOrWhiteSpace($shimContent)) {
        throw "Fail-closed: npm shim file is empty: $ShimPath"
    }

    $shimDir = Split-Path -Parent [System.IO.Path]::GetFullPath($ShimPath)
    
    # Strictly probe candidates without starting any process
    $nodeCandidates = @(
        (Join-Path $shimDir "node.exe"),
        "C:\Program Files\nodejs\node.exe",
        "C:\Program Files (x86)\nodejs\node.exe"
    )
    $resolvedNode = $null
    foreach ($cand in $nodeCandidates) {
        $fullCand = [System.IO.Path]::GetFullPath($cand)
        if (Test-Path -LiteralPath $fullCand -PathType Leaf) {
            $resolvedNode = $fullCand
            break
        }
    }

    if (-not $resolvedNode) {
        $nodeCmd = Get-Command "node.exe" -ErrorAction SilentlyContinue
        if ($nodeCmd -and $nodeCmd.Source -and (Test-Path -LiteralPath $nodeCmd.Source -PathType Leaf)) {
            $resolvedNode = [System.IO.Path]::GetFullPath($nodeCmd.Source)
        }
    }

    if (-not $resolvedNode) {
        throw "Fail-closed: node.exe runtime could not be resolved for npm shim: $ShimPath"
    }

    $entryCandidates = @(
        (Join-Path $shimDir "node_modules\@openai\codex\bin\codex.js"),
        (Join-Path (Split-Path $shimDir -Parent) "node_modules\@openai\codex\bin\codex.js"),
        (Join-Path $env:APPDATA "npm\node_modules\@openai\codex\bin\codex.js"),
        "C:\Program Files\nodejs\node_modules\@openai\codex\bin\codex.js"
    )
    $resolvedEntry = $null
    foreach ($cand in $entryCandidates) {
        $fullCand = [System.IO.Path]::GetFullPath($cand)
        if (Test-Path -LiteralPath $fullCand -PathType Leaf) {
            $resolvedEntry = $fullCand
            break
        }
    }

    if (-not $resolvedEntry) {
        throw "Fail-closed: @openai/codex/bin/codex.js entry point not found on disk."
    }

    $pkgJsonPath = [System.IO.Path]::GetFullPath((Join-Path (Split-Path (Split-Path $resolvedEntry -Parent) -Parent) "package.json"))
    if (-not (Test-Path -LiteralPath $pkgJsonPath -PathType Leaf)) {
        throw "Fail-closed: package.json missing at expected package root: $pkgJsonPath"
    }

    $pkgData = Get-Content -Raw -LiteralPath $pkgJsonPath | ConvertFrom-Json
    if ($pkgData.name -ne "@openai/codex") {
        throw "Fail-closed: package.json name is '$($pkgData.name)', expected '@openai/codex'."
    }
    $rawVersion = if ($pkgData.version) { "$($pkgData.version)".Trim() } else { $null }
    if ([string]::IsNullOrWhiteSpace($rawVersion)) {
        throw "Fail-closed: package.json missing valid non-empty version string."
    }

    $cleanVersion = $rawVersion.TrimStart('v')
    if ($cleanVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
        throw "Fail-closed: package.json version '$rawVersion' is not a valid dotted SemVer string."
    }

    return [ordered]@{
        LauncherType = "NodeScriptEntry"
        ExecutablePath = [System.IO.Path]::GetFullPath($resolvedNode)
        ScriptEntry = $resolvedEntry
        PackageVersion = $rawVersion
        PackageJsonPath = $pkgJsonPath
    }
}

function Resolve-CodexLauncher {
    [CmdletBinding()]
    param()

    if ($env:CODEX_EXECUTABLE) {
        if (-not (Test-Path -LiteralPath $env:CODEX_EXECUTABLE -PathType Leaf)) {
            throw "CODEX_EXECUTABLE was set to '$env:CODEX_EXECUTABLE' but file does not exist."
        }
        if ($env:CODEX_EXECUTABLE -like "*.ps1") {
            throw "Security violation: execution of codex.ps1 is strictly rejected."
        }
        if ($env:CODEX_EXECUTABLE -like "*.cmd" -or $env:CODEX_EXECUTABLE -like "*.bat") {
            return Resolve-NpmShim -ShimPath $env:CODEX_EXECUTABLE
        }
        return [ordered]@{
            LauncherType = "NativeBinary"
            ExecutablePath = [System.IO.Path]::GetFullPath($env:CODEX_EXECUTABLE)
            ScriptEntry = $null
            PackageVersion = $null
            PackageJsonPath = $null
        }
    }

    if ($env:OS -eq 'Windows_NT') {
        $nativeCmd = Get-Command "codex.exe" -ErrorAction SilentlyContinue
        if ($nativeCmd -and $nativeCmd.Source -notlike "*.cmd" -and $nativeCmd.Source -notlike "*.ps1") {
            return [ordered]@{
                LauncherType = "NativeBinary"
                ExecutablePath = [System.IO.Path]::GetFullPath($nativeCmd.Source)
                ScriptEntry = $null
                PackageVersion = $null
                PackageJsonPath = $null
            }
        }

        $candidateExePaths = @(
            (Join-Path $env:APPDATA "npm\codex.exe"),
            "C:\Program Files\nodejs\codex.exe",
            (Join-Path $env:LOCALAPPDATA "Programs\codex\codex.exe")
        )
        foreach ($cand in $candidateExePaths) {
            if (Test-Path -LiteralPath $cand -PathType Leaf) {
                return [ordered]@{
                    LauncherType = "NativeBinary"
                    ExecutablePath = [System.IO.Path]::GetFullPath($cand)
                    ScriptEntry = $null
                    PackageVersion = $null
                    PackageJsonPath = $null
                }
            }
        }

        $shimCmd = Get-Command "codex.cmd" -ErrorAction SilentlyContinue
        $shimPath = if ($shimCmd) { $shimCmd.Source } else { (Join-Path $env:APPDATA "npm\codex.cmd") }
        if (Test-Path -LiteralPath $shimPath -PathType Leaf) {
            return Resolve-NpmShim -ShimPath $shimPath
        }

        throw "Codex CLI was not found as codex.exe or a valid npm shim codex.cmd on PATH."
    } else {
        $nixCmd = Get-Command "codex" -ErrorAction Stop
        return [ordered]@{
            LauncherType = "NativeBinary"
            ExecutablePath = [System.IO.Path]::GetFullPath($nixCmd.Source)
            ScriptEntry = $null
            PackageVersion = $null
            PackageJsonPath = $null
        }
    }
}

Export-ModuleMember -Function Resolve-CodexLauncher
```

### 3. Complete Shared Process Launcher (`.agents/scripts/invoke-codex-process.ps1`)

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Argv,

    [Parameter(Mandatory = $true)]
    [ValidateSet("AuthenticatedRole", "IsolatedSandbox")]
    [string]$EnvironmentMode,

    [Parameter(Mandatory = $false)]
    [string]$CodexHome,

    [Parameter(Mandatory = $false)]
    [string]$StdinText,

    [Parameter(Mandatory = $false)]
    [string]$WorkingDirectory = ".",

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 600
)

$ErrorActionPreference = 'Stop'

# 1. Prerequisite verification
Assert-PowerShell7Prerequisite

# 2. Compile/Load Namespaced .NET C# Helper
$helperSourcePath = (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "ProcessRunnerHelper.cs")
if (-not ([System.Management.Automation.PSTypeName]'CodexHarness.NativeProcessRunner').Type) {
    if (-not (Test-Path -LiteralPath $helperSourcePath -PathType Leaf)) {
        throw "Fail-closed: ProcessRunnerHelper.cs source file missing at $helperSourcePath"
    }
    $csharpSource = Get-Content -Raw -LiteralPath $helperSourcePath -Encoding UTF8
    if ($csharpSource -notmatch '(?m)^\s*#nullable\s+enable') {
        throw "Fail-closed: ProcessRunnerHelper.cs missing mandatory '#nullable enable' compiler directive."
    }
    try {
        Add-Type -TypeDefinition $csharpSource -Language CSharp -ErrorAction Stop
    } catch {
        throw "Fail-closed: Add-Type compilation failed for CodexHarness.NativeProcessRunner: $_"
    }
}

# 3. Import Side-Effect-Free Resolver Module & Resolve Launcher
$resolverModulePath = (Join-Path (Split-Path $MyInvocation.MyCommand.Path) "CodexLauncherResolver.psm1")
if (-not (Test-Path -LiteralPath $resolverModulePath -PathType Leaf)) {
    throw "Fail-closed: CodexLauncherResolver.psm1 module missing at $resolverModulePath"
}
Import-Module -Name $resolverModulePath -ErrorAction Stop

$launcher = Resolve-CodexLauncher

# 4. ProcessStartInfo configuration
$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $launcher.ExecutablePath
$psi.WorkingDirectory = [System.IO.Path]::GetFullPath($WorkingDirectory)
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.RedirectStandardInput = $true

if ($launcher.LauncherType -eq "NodeScriptEntry") {
    $psi.ArgumentList.Add($launcher.ScriptEntry)
}
foreach ($arg in $Argv) {
    $psi.ArgumentList.Add($arg)
}

# 5. Environment Mode Scoping
switch ($EnvironmentMode) {
    "AuthenticatedRole" {
        if ($CodexHome) {
            throw "Security violation: CodexHome parameter cannot be specified in AuthenticatedRole mode."
        }
    }
    "IsolatedSandbox" {
        if ([string]::IsNullOrWhiteSpace($CodexHome)) {
            throw "Security violation: IsolatedSandbox mode requires an explicit -CodexHome path."
        }
        $normalizedHome = [System.IO.Path]::GetFullPath($CodexHome)
        if (-not (Test-Path -LiteralPath $normalizedHome -PathType Container)) {
            throw "IsolatedSandbox CodexHome directory does not exist: $normalizedHome"
        }
        
        $configFile = (Join-Path $normalizedHome "config.toml")
        if (-not (Test-Path -LiteralPath $configFile -PathType Leaf)) {
            throw "IsolatedSandbox CodexHome missing required config.toml: $configFile"
        }

        $authFiles = Get-ChildItem -LiteralPath $normalizedHome -Recurse -File -Include "auth.json", "*.token", "*credential*", "*key*"
        if ($authFiles.Count -gt 0) {
            throw "Security violation: isolated CODEX_HOME contains authentication files: $($authFiles[0].FullName)"
        }

        $psi.EnvironmentVariables["CODEX_HOME"] = $normalizedHome
    }
}

# 6. Execute via C# NativeProcessRunner (Single Top-Level Task Await - Strictly Public Production API without Observer)
$runnerTask = [CodexHarness.NativeProcessRunner]::ExecuteProcessAsync($psi, $StdinText, $TimeoutSeconds)
$execResult = $runnerTask.GetAwaiter().GetResult()

return @{
    ExitCode = $execResult.ExitCode
    Stdout = $execResult.Stdout
    Stderr = $execResult.Stderr
    TimedOut = $execResult.TimedOut
    TreeCleanupUnverified = $execResult.TreeCleanupUnverified
    StdinCompleted = $execResult.StdinCompleted
    StdoutDrained = $execResult.StdoutDrained
    StderrDrained = $execResult.StderrDrained
}
```

---

## Toolhelp32 Process Tree Snapshot C# Helper Specification

To eliminate all PowerShell scriptblock execution inside `Task.Run` and eliminate `Get-CimInstance`, the following self-contained C# class (`CodexHarnessSnapshot.WindowsProcessTreeSnapshot`) is compiled via `Add-Type` in all components that perform process tree tracking.

### C# Source Architecture

```csharp
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarnessSnapshot
{
    public sealed class SnapshotResult
    {
        public bool Success { get; set; }
        public bool TimedOut { get; set; }
        public bool Overflow { get; set; }
        public int[] Pids { get; set; } = Array.Empty<int>();
        public string ErrorMessage { get; set; } = string.Empty;
    }

    public static class WindowsProcessTreeSnapshot
    {
        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int ERROR_NO_MORE_FILES = 18;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W
        {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr hObject);

        public static SnapshotResult TakeDescendantSnapshot(int rootPid, int maxDescendants = 64)
        {
            var result = new SnapshotResult();
            IntPtr hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot == INVALID_HANDLE_VALUE)
            {
                int err = Marshal.GetLastWin32Error();
                result.Success = false;
                result.ErrorMessage = $"CreateToolhelp32Snapshot failed with Win32 error {err}.";
                return result;
            }

            try
            {
                var parentToChildren = new Dictionary<int, List<int>>();
                var pe = new PROCESSENTRY32W();
                pe.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32W));

                if (!Process32FirstW(hSnapshot, ref pe))
                {
                    int err = Marshal.GetLastWin32Error();
                    if (err == ERROR_NO_MORE_FILES)
                    {
                        result.Success = true;
                        result.Pids = Array.Empty<int>();
                        return result;
                    }
                    result.Success = false;
                    result.ErrorMessage = $"Process32FirstW failed with Win32 error {err}.";
                    return result;
                }

                bool hasMore;
                do
                {
                    int ppid = (int)pe.th32ParentProcessID;
                    int pid = (int)pe.th32ProcessID;
                    if (pid > 0 && ppid > 0 && pid != ppid)
                    {
                        if (!parentToChildren.TryGetValue(ppid, out var children))
                        {
                            children = new List<int>();
                            parentToChildren[ppid] = children;
                        }
                        children.Add(pid);
                    }
                    hasMore = Process32NextW(hSnapshot, ref pe);
                } while (hasMore);

                int nextErr = Marshal.GetLastWin32Error();
                if (nextErr != ERROR_NO_MORE_FILES)
                {
                    result.Success = false;
                    result.Pids = Array.Empty<int>();
                    result.ErrorMessage = $"Process32NextW iteration failed with Win32 error {nextErr}.";
                    return result;
                }

                var descendants = new List<int>();
                var queue = new Queue<int>();
                queue.Enqueue(rootPid);

                while (queue.Count > 0)
                {
                    int current = queue.Dequeue();
                    if (parentToChildren.TryGetValue(current, out var children))
                    {
                        foreach (int childPid in children)
                        {
                            if (!descendants.Contains(childPid))
                            {
                                if (descendants.Count >= maxDescendants)
                                {
                                    result.Success = false;
                                    result.Overflow = true;
                                    result.Pids = descendants.ToArray();
                                    result.ErrorMessage = $"Descendant process count exceeded safe cap of {maxDescendants} for PID {rootPid}.";
                                    return result;
                                }
                                descendants.Add(childPid);
                                queue.Enqueue(childPid);
                            }
                        }
                    }
                }

                result.Success = true;
                result.Pids = descendants.ToArray();
                return result;
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Pids = Array.Empty<int>();
                result.ErrorMessage = $"Exception during Toolhelp32 snapshot: {ex.Message}";
                return result;
            }
            finally
            {
                CloseHandle(hSnapshot);
            }
        }

        public static SnapshotResult TakeDescendantSnapshotBounded(int rootPid, int timeoutMs, int maxDescendants = 64)
        {
            if (timeoutMs <= 0)
            {
                return new SnapshotResult
                {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Snapshot timeout expired before execution ({timeoutMs} ms)."
                };
            }

            var task = Task.Run(() => TakeDescendantSnapshot(rootPid, maxDescendants));
            if (!task.Wait(timeoutMs))
            {
                return new SnapshotResult
                {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Descendant snapshot timed out after {timeoutMs} ms."
                };
            }

            return task.Result;
        }
    }
}
```

---

## Complete Self-Contained External Phase 0 Audit Driver & Staging Procedure

### 1. Specification & Architecture

1. **Self-Contained External Phase 0 Script**:
   - The Phase 0 audit driver (`invoke-phase0-audit.ps1`) is completely self-contained. It incorporates its own in-memory PInvoke `CreateDirectoryW` compilation (`CodexHarnessPhase0.NativeFileSystem`), native C# Toolhelp32 snapshot helper (`CodexHarnessSnapshot.WindowsProcessTreeSnapshot`), canonical System32 `taskkill.exe` path validation, ancestor reparse checking, git porcelain v2 raw byte stream handling via unary comma carrier, collision auditing across all 116 planned items, runtime/audit reparse point inspection, and deep baseline hash verification.
   - It possesses **zero** runtime dependency on Phase 2 scripts or helper assemblies.
   - **Hardened Git Process Execution (`Invoke-GitProcessDirectBytes`)**:
     - Eliminates dynamic shell call operators (`& $canonicalTaskkill`) and unbounded `Task.WaitAll`.
     - Executes `taskkill.exe` via structured `ProcessStartInfo.ArgumentList` under a single true global cleanup deadline of **3000 ms** with a mandatory reserved emergency window of at least **750 ms** (authoritative subdeadline: **2250 ms**).
     - Descendant snapshot uses `CodexHarnessSnapshot.WindowsProcessTreeSnapshot::TakeDescendantSnapshotBounded` (capped at 64 PIDs, failing on overflow or query timeout). Pure C# runs on the Task worker; PowerShell never runs on the worker.
     - Never uses `[Math]::Max` or minimum waits when the budget expires; if `remaining <= 0`, it fails immediately closed.
     - On snapshot failure, taskkill failure, or exit timeout, captures primary error and immediately enters emergency mitigation while reserve remains.
     - **Authoritative Subdeadline Bounding on Lingering Taskkill Helper**: In `finally`, if `$tkProc` is live, it issues an immediate tree kill, may be waited on **only until the authoritative 2250 ms subdeadline** ($authoritativeSubdeadlineMs), never into the 750 ms reserve. At subdeadline, issues immediate `Kill(true)`, records helper unverified if not exited, and transitions immediately to root emergency mitigation using the reserve.
     - **Universal Emergency Mitigation**: ALWAYS attempts `Process.Kill(true)` directly on the still-live root handle, bounded by the remaining global deadline.
     - The mitigation call is NEVER guarded by a remaining-time condition that can skip it. If the final global deadline is already unexpectedly exhausted, issues immediate non-waiting `Kill(true)` in a last best-effort statement and still throws `TreeCleanupUnverified`.
     - Affirmatively checks within the remaining global reserve that the root process AND every captured descendant PID are completely gone.
     - Only after mitigation throws distinct `TreeCleanupUnverified` preserving primary failure and survivor list. Any authoritative failure remains `TreeCleanupUnverified` even if emergency mitigation successfully kills all processes.
     - Its `finally` block verifies that if `$proc` is live, it calls verified tree cleanup and propagates cleanup failure rather than suppressing it. No possibly live process is merely disposed.

2. **Implementation Controller Staging, Verification & Cleanup Procedure**:
   - Accepts mandatory explicit parameters: `-SourcePlanPath` and `-ExpectedSourcePlanSha256` (provided directly from the externally approved implementation manifest).
   - **TOCTOU Elimination**: Calls `[System.IO.File]::ReadAllBytes($canonicalPlan)` exactly once. Calculates SHA-256 over that exact byte buffer, validates the mandatory expected hash, decodes that same immutable buffer using strict UTF-8, splits lines and extracts code fence markers from the in-memory array. Never calls `Get-FileHash` followed by a file reread.
   - Derives the canonical OS temp directory: `$osTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())`.
   - Validates that `$osTemp` and every ancestor up to the drive root has zero reparse points.
   - Generates a per-run GUID `$phase0Guid = [System.Guid]::NewGuid().ToString('N')`.
   - Derives `$tempDriverDir = [System.IO.Path]::GetFullPath((Join-Path $osTemp "codex-phase0-$phase0Guid"))`.
   - Atomically creates `$tempDriverDir` fail-if-exists via PInvoke `CreateDirectoryW`.
   - Writes `.phase0-owner.json` marker using `[System.IO.FileMode]::CreateNew`.
   - Directly writes the UTF-8 bytes to `$tempDriverDir\invoke-phase0-audit.ps1` using `[System.IO.FileMode]::CreateNew`.
   - Reads back and verifies the SHA-256 hash against the in-memory expectation.
   - **Self-Contained `Invoke-VerifiedTreeKill` in Controller**:
     - Resolves canonical `[SystemRoot]\System32\taskkill.exe`, verifies regular file, zero reparse points, and non-reparse System32 ancestry up to system root.
     - Uses Toolhelp32 snapshot helper (`TakeDescendantSnapshotBounded`) with pure C# delegate on Task worker under authoritative subdeadline (capped at 64 PIDs, failing on overflow or query timeout).
     - Executes taskkill via structured `ProcessStartInfo.ArgumentList` (`/PID`, `<pid>`, `/T`, `/F`) under a single true global deadline (**3000 ms total**, **750 ms emergency reserve**, 2250 ms authoritative subdeadline) without `[Math]::Max` floor waits.
     - Lingering taskkill helper process waited on only until 2250 ms subdeadline, never into the 750 ms reserve. At subdeadline: immediate `Kill(true)`, records helper unverified if not exited, and transitions immediately to root emergency mitigation using reserve.
     - On any primary failure (snapshot, launch, exit timeout, drain timeout, or exit code != 0), captures failure, always executes emergency mitigation on original live root via `Kill(true)` without skip guard, checks root and captured descendants within remaining reserve, and only then throws distinct `TreeCleanupUnverified` with survivor reporting.
     - The `finally` block verifies that if `$driverProc` is alive, it calls verified tree cleanup and propagates cleanup failure before calling `.Dispose()`.
   - In `finally`: validates canonical temp containment, checks `.phase0-owner.json` marker with matching GUID, checks directory and ancestor reparse points, and removes only the owned temp directory. If any check fails, it explicitly refuses deletion and throws a terminating security exception.

3. **Reconciled Manifest & Derived Total (116 Items)**:
   - Total items = **109** declarative repository targets + **5** runtime-owned targets + **2** dynamic per-run GUID audit files (`intended-creation-manifest-<guid>.json` and `phase0-baseline-<guid>.json`) = **116 items**.
   - The staged temp driver remains outside the repository workspace and is consistently excluded from repository manifests.

### 2. Complete Self-Contained Phase 0 External Audit Driver Script (`invoke-phase0-audit.ps1`)

<!-- BEGIN_PHASE0_DRIVER_SCRIPT -->
```powershell
[CmdletBinding()]
param(
    [string]$RepoRoot = "H:\CommandCenter\orchestrator"
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "Fail-closed: PowerShell 7+ (pwsh.exe) is required for invoke-phase0-audit.ps1. Running under $($PSVersionTable.PSVersion)."
}

$normalizedRoot = [System.IO.Path]::GetFullPath($RepoRoot)
if (-not $normalizedRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $normalizedRoot += [System.IO.Path]::DirectorySeparatorChar
}

# 1. Self-Contained In-Memory CreateDirectoryW PInvoke
$nativeFsSource = @"
using System;
using System.IO;
using System.Runtime.InteropServices;

namespace CodexHarnessPhase0 {
    public static class NativeFileSystem {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CreateDirectoryW(string lpPathName, IntPtr lpSecurityAttributes);

        public static bool CreateDirectoryFailIfExists(string path) {
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentNullException(nameof(path));
            string fullPath = Path.GetFullPath(path);
            if (!CreateDirectoryW(fullPath, IntPtr.Zero)) {
                int error = Marshal.GetLastWin32Error();
                throw new IOException($"CreateDirectoryW failed for '{fullPath}' with Win32 error code {error}.");
            }
            return true;
        }
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]'CodexHarnessPhase0.NativeFileSystem').Type) {
    Add-Type -TypeDefinition $nativeFsSource -Language CSharp -ErrorAction Stop
}

# 2. Self-Contained In-Memory C# Windows Toolhelp32 Process Tree Snapshot Helper with Error-Checked Iteration
$snapshotSource = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarnessSnapshot {
    public sealed class SnapshotResult {
        public bool Success { get; set; }
        public bool TimedOut { get; set; }
        public bool Overflow { get; set; }
        public int[] Pids { get; set; } = Array.Empty<int>();
        public string ErrorMessage { get; set; } = string.Empty;
    }

    public static class WindowsProcessTreeSnapshot {
        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int ERROR_NO_MORE_FILES = 18;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr hObject);

        public static SnapshotResult TakeDescendantSnapshot(int rootPid, int maxDescendants = 64) {
            var result = new SnapshotResult();
            IntPtr hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot == INVALID_HANDLE_VALUE) {
                int err = Marshal.GetLastWin32Error();
                result.Success = false;
                result.ErrorMessage = $"CreateToolhelp32Snapshot failed with Win32 error {err}.";
                return result;
            }

            try {
                var parentToChildren = new Dictionary<int, List<int>>();
                var pe = new PROCESSENTRY32W();
                pe.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32W));

                if (!Process32FirstW(hSnapshot, ref pe)) {
                    int err = Marshal.GetLastWin32Error();
                    if (err == ERROR_NO_MORE_FILES) {
                        result.Success = true;
                        result.Pids = Array.Empty<int>();
                        return result;
                    }
                    result.Success = false;
                    result.ErrorMessage = $"Process32FirstW failed with Win32 error {err}.";
                    return result;
                }

                bool hasMore;
                do {
                    int ppid = (int)pe.th32ParentProcessID;
                    int pid = (int)pe.th32ProcessID;
                    if (pid > 0 && ppid > 0 && pid != ppid) {
                        if (!parentToChildren.TryGetValue(ppid, out var children)) {
                            children = new List<int>();
                            parentToChildren[ppid] = children;
                        }
                        children.Add(pid);
                    }
                    hasMore = Process32NextW(hSnapshot, ref pe);
                } while (hasMore);

                int nextErr = Marshal.GetLastWin32Error();
                if (nextErr != ERROR_NO_MORE_FILES) {
                    result.Success = false;
                    result.Pids = Array.Empty<int>();
                    result.ErrorMessage = $"Process32NextW iteration failed with Win32 error {nextErr}.";
                    return result;
                }

                var descendants = new List<int>();
                var queue = new Queue<int>();
                queue.Enqueue(rootPid);

                while (queue.Count > 0) {
                    int current = queue.Dequeue();
                    if (parentToChildren.TryGetValue(current, out var children)) {
                        foreach (int childPid in children) {
                            if (!descendants.Contains(childPid)) {
                                if (descendants.Count >= maxDescendants) {
                                    result.Success = false;
                                    result.Overflow = true;
                                    result.Pids = descendants.ToArray();
                                    result.ErrorMessage = $"Descendant process count exceeded safe cap of {maxDescendants} for PID {rootPid}.";
                                    return result;
                                }
                                descendants.Add(childPid);
                                queue.Enqueue(childPid);
                            }
                        }
                    }
                }

                result.Success = true;
                result.Pids = descendants.ToArray();
                return result;
            } catch (Exception ex) {
                result.Success = false;
                result.Pids = Array.Empty<int>();
                result.ErrorMessage = $"Exception during Toolhelp32 snapshot: {ex.Message}";
                return result;
            } finally {
                CloseHandle(hSnapshot);
            }
        }

        public static SnapshotResult TakeDescendantSnapshotBounded(int rootPid, int timeoutMs, int maxDescendants = 64) {
            if (timeoutMs <= 0) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Snapshot timeout expired before execution ({timeoutMs} ms)."
                };
            }

            var task = Task.Run(() => TakeDescendantSnapshot(rootPid, maxDescendants));
            if (!task.Wait(timeoutMs)) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Descendant snapshot timed out after {timeoutMs} ms."
                };
            }

            return task.Result;
        }
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]'CodexHarnessSnapshot.WindowsProcessTreeSnapshot').Type) {
    Add-Type -TypeDefinition $snapshotSource -Language CSharp -ErrorAction Stop
}

# 3. Resolve and Validate Canonical Absolute taskkill.exe
$systemRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
if ([string]::IsNullOrWhiteSpace($systemRoot)) {
    $systemRoot = $env:SystemRoot
    if ([string]::IsNullOrWhiteSpace($systemRoot)) { $systemRoot = "C:\Windows" }
}
$canonicalSys32 = [System.IO.Path]::GetFullPath((Join-Path $systemRoot "System32"))
if (-not $canonicalSys32.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $canonicalSys32 += [System.IO.Path]::DirectorySeparatorChar
}
$canonicalTaskkill = [System.IO.Path]::GetFullPath((Join-Path $canonicalSys32 "taskkill.exe"))

if (-not $canonicalTaskkill.StartsWith($canonicalSys32, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Security violation: taskkill path escapes canonical System32: $canonicalTaskkill"
}
$taskkillFi = [System.IO.FileInfo]::new($canonicalTaskkill)
if (-not $taskkillFi.Exists -or ($taskkillFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
    throw "Security violation: taskkill.exe is missing or is a reparse point: $canonicalTaskkill"
}
$tkDir = $taskkillFi.Directory
while ($tkDir -and $tkDir.FullName.Length -ge $systemRoot.Length) {
    if ($tkDir.Exists -and ($tkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: reparse point detected in taskkill ancestor: $($tkDir.FullName)"
    }
    $tkDir = $tkDir.Parent
}

# Helper for bounded taskkill process tree kill with single global stopwatch budget (3000 ms total, 750 ms emergency reserve),
# Toolhelp32 snapshot, authoritative subdeadline wait limit on taskkill helper, and universal emergency mitigation
function Invoke-Phase0TaskkillTree(
    [int]$TargetPid,
    [System.Diagnostics.Process]$TargetProcess = $null,
    [int]$TotalBudgetMs = 3000,
    [int]$ReserveEmergencyMs = 750
) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $authoritativeSubdeadlineMs = $TotalBudgetMs - $ReserveEmergencyMs # 2250 ms
    $maxTrackedDescendants = 64
    $descendantPids = [System.Collections.Generic.List[int]]::new()
    $primaryFailures = [System.Collections.Generic.List[string]]::new()

    # A. Bounded snapshot of known descendants via C# Toolhelp32 helper (pure C# on worker; no PowerShell scriptblock)
    # Bounded strictly by authoritative subdeadline
    $remSnap = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
    if ($remSnap -le 0) {
        $primaryFailures.Add("Authoritative subdeadline exhausted before descendant snapshot ($($sw.ElapsedMilliseconds) ms elapsed).")
    } else {
        try {
            $snapRes = [CodexHarnessSnapshot.WindowsProcessTreeSnapshot]::TakeDescendantSnapshotBounded($TargetPid, $remSnap, $maxTrackedDescendants)
            if (-not $snapRes.Success) {
                # Snapshot failure is NEVER treated as empty!
                $primaryFailures.Add("Descendant snapshot failed: $($snapRes.ErrorMessage) (TimedOut=$($snapRes.TimedOut), Overflow=$($snapRes.Overflow)).")
            }
            if ($null -ne $snapRes.Pids) {
                foreach ($p in $snapRes.Pids) {
                    if ($p -gt 0 -and -not $descendantPids.Contains($p)) {
                        $descendantPids.Add([int]$p)
                    }
                }
            }
        } catch {
            $primaryFailures.Add("Descendant snapshot threw exception: $($_.Exception.Message)")
        }
    }

    # B. Execute canonical System32 taskkill via structured ProcessStartInfo bounded strictly by authoritative subdeadline
    $tkPsi = [System.Diagnostics.ProcessStartInfo]::new()
    $tkPsi.FileName = $canonicalTaskkill
    $tkPsi.UseShellExecute = $false
    $tkPsi.CreateNoWindow = $true
    $tkPsi.RedirectStandardOutput = $true
    $tkPsi.RedirectStandardError = $true
    $tkPsi.ArgumentList.Add("/PID")
    $tkPsi.ArgumentList.Add($TargetPid.ToString())
    $tkPsi.ArgumentList.Add("/T")
    $tkPsi.ArgumentList.Add("/F")

    $tkProc = $null
    $tkExitZero = $false

    try {
        $remTkStart = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
        if ($remTkStart -le 0) {
            $primaryFailures.Add("Authoritative subdeadline exhausted before taskkill start.")
        } else {
            $tkProc = [System.Diagnostics.Process]::Start($tkPsi)
            if ($null -eq $tkProc) {
                $primaryFailures.Add("Process.Start returned null for taskkill.exe.")
            } else {
                try {
                    $outT = $tkProc.StandardOutput.ReadToEndAsync()
                    $errT = $tkProc.StandardError.ReadToEndAsync()
                    $remExit = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                    if ($remExit -le 0 -or -not $tkProc.WaitForExit($remExit)) {
                        try { $tkProc.Kill() } catch { }
                        $primaryFailures.Add("taskkill process did not exit within authoritative subdeadline ($remExit ms remaining).")
                    } else {
                        $remDrain = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                        if ($remDrain -le 0) {
                            $primaryFailures.Add("taskkill stream drain budget exhausted within authoritative subdeadline.")
                        } else {
                            $streams = [System.Threading.Tasks.Task]::WhenAll($outT, $errT)
                            if (-not $streams.Wait($remDrain)) {
                                $primaryFailures.Add("taskkill streams failed to drain within authoritative subdeadline.")
                            } else {
                                if ($tkProc.ExitCode -eq 0) {
                                    $tkExitZero = $true
                                } else {
                                    $primaryFailures.Add("taskkill exited with code $($tkProc.ExitCode): $($errT.Result)")
                                }
                            }
                        }
                    }
                } finally {
                    # Taskkill helper process cleanup: may be waited on ONLY until 2250 ms authoritative subdeadline, never into 750 ms reserve.
                    # At subdeadline, issue immediate Kill(true), record helper unverified if not exited, and transition immediately to root emergency mitigation.
                    try {
                        if (-not $tkProc.HasExited) {
                            try { $tkProc.Kill($true) } catch { try { $tkProc.Kill() } catch { } }
                            $remTkWait = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                            if ($remTkWait -gt 0) {
                                $null = $tkProc.WaitForExit($remTkWait)
                            }
                            if (-not $tkProc.HasExited) {
                                try { $tkProc.Kill($true) } catch { }
                                $primaryFailures.Add("taskkill helper process PID $($tkProc.Id) could not be verified exited before authoritative subdeadline.")
                            }
                        }
                    } catch {
                        $primaryFailures.Add("Exception during taskkill helper cleanup: $($_.Exception.Message)")
                    }
                    $tkProc.Dispose()
                }
            }
        }
    } catch {
        $primaryFailures.Add("taskkill invocation threw exception: $($_.Exception.Message)")
    }

    # C. Universal Emergency Mitigation: ALWAYS attempt emergency mitigation on original live root
    # NEVER guard mitigation with a remaining-time condition that can skip it!
    # Even if authoritative subdeadline was exhausted, immediately enter emergency mitigation while reserve remains.
    # If final global deadline is already unexpectedly exhausted, issue immediate non-waiting Kill(true) in a last best-effort statement.
    if ($null -ne $TargetProcess) {
        try {
            $isLive = $false
            try { $isLive = -not $TargetProcess.HasExited } catch { $isLive = $true }
            if ($isLive) {
                $TargetProcess.Kill($true)
            }
        } catch { }
    } else {
        try {
            $rootP = [System.Diagnostics.Process]::GetProcessById($TargetPid)
            try {
                $isLive = $false
                try { $isLive = -not $rootP.HasExited } catch { $isLive = $true }
                if ($isLive) {
                    $rootP.Kill($true)
                }
            } finally {
                $rootP.Dispose()
            }
        } catch { }
    }

    foreach ($dPid in $descendantPids) {
        try {
            $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
            try {
                $isLive = $false
                try { $isLive = -not $dP.HasExited } catch { $isLive = $true }
                if ($isLive) {
                    $dP.Kill()
                }
            } finally {
                $dP.Dispose()
            }
        } catch { }
    }

    # D. Affirmative root and descendant exit verification within remaining global reserve
    $rootExited = $false
    $remRootWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
    if ($remRootWait -gt 0) {
        if ($null -ne $TargetProcess) {
            try { $rootExited = $TargetProcess.WaitForExit($remRootWait) -or $TargetProcess.HasExited } catch { $rootExited = $true }
        } else {
            try {
                $p = [System.Diagnostics.Process]::GetProcessById($TargetPid)
                $rootExited = $p.WaitForExit($remRootWait) -or $p.HasExited
                $p.Dispose()
            } catch { $rootExited = $true }
        }
    } else {
        if ($null -ne $TargetProcess) {
            try { $rootExited = $TargetProcess.HasExited } catch { $rootExited = $false }
        } else {
            try {
                $p = [System.Diagnostics.Process]::GetProcessById($TargetPid)
                $rootExited = $p.HasExited
                $p.Dispose()
            } catch { $rootExited = $true }
        }
    }

    $survivors = [System.Collections.Generic.List[int]]::new()
    if (-not $rootExited) { $survivors.Add($TargetPid) }

    foreach ($dPid in $descendantPids) {
        $remChildWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
        $dExited = $false
        if ($remChildWait -gt 0) {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.WaitForExit($remChildWait) -or $dP.HasExited
                $dP.Dispose()
            } catch {
                $dExited = $true
            }
        } else {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.HasExited
                $dP.Dispose()
            } catch { $dExited = $true }
        }
        if (-not $dExited) { $survivors.Add($dPid) }
    }

    $allProcessesGone = ($rootExited -and $survivors.Count -eq 0)

    # Throw distinct TreeCleanupUnverified if taskkill failed, any primary failure occurred, or any survivor remains
    # Any authoritative failure remains TreeCleanupUnverified even if emergency termination succeeds!
    if (-not ($tkExitZero -and $primaryFailures.Count -eq 0 -and $allProcessesGone)) {
        $diag = [ordered]@{
            status = "TreeCleanupUnverified"
            targetPid = $TargetPid
            totalBudgetMs = $TotalBudgetMs
            reserveEmergencyMs = $ReserveEmergencyMs
            authoritativeSubdeadlineMs = $authoritativeSubdeadlineMs
            elapsedMs = [int]$sw.ElapsedMilliseconds
            taskkillExitZero = $tkExitZero
            primaryFailures = @($primaryFailures)
            rootExited = $rootExited
            trackedDescendants = $descendantPids.Count
            survivorCount = $survivors.Count
            survivorPids = @($survivors)
        }
        $diagJson = ($diag | ConvertTo-Json -Compress)
        throw "TreeCleanupUnverified: Process tree cleanup unverified for PID $($TargetPid) within $TotalBudgetMs ms budget ($ReserveEmergencyMs ms reserve). Detail: $diagJson"
    }
}

# 4. Direct Process Invocation for Git Returning Raw Stdout Bytes (Unary Comma Carrier)
function Invoke-GitProcessDirectBytes([string]$WorkingDirectory, [string[]]$Arguments) {
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = "git.exe"
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    foreach ($arg in $Arguments) {
        $psi.ArgumentList.Add($arg)
    }

    $proc = [System.Diagnostics.Process]::Start($psi)
    if ($null -eq $proc) {
        throw "Failed to start git.exe process."
    }

    $msOut = [System.IO.MemoryStream]::new()
    $msErr = [System.IO.MemoryStream]::new()
    $outTask = $proc.StandardOutput.BaseStream.CopyToAsync($msOut)
    $errTask = $proc.StandardError.BaseStream.CopyToAsync($msErr)

    $gitTimeoutMs = 30000
    $swGit = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        if (-not $proc.WaitForExit($gitTimeoutMs)) {
            Invoke-Phase0TaskkillTree -TargetPid $proc.Id -TargetProcess $proc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "git $($Arguments -join ' ') timed out after 30 seconds (process tree verified terminated)."
        }

        $remDrainMs = 5000 - [int]$swGit.ElapsedMilliseconds
        if ($remDrainMs -le 0) {
            Invoke-Phase0TaskkillTree -TargetPid $proc.Id -TargetProcess $proc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "git $($Arguments -join ' ') stream drain budget exhausted (process tree verified terminated)."
        }

        $streamsTask = [System.Threading.Tasks.Task]::WhenAll($outTask, $errTask)
        if (-not $streamsTask.Wait($remDrainMs)) {
            Invoke-Phase0TaskkillTree -TargetPid $proc.Id -TargetProcess $proc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "git $($Arguments -join ' ') stream drain timed out (process tree verified terminated)."
        }

        if ($proc.ExitCode -ne 0) {
            $errStr = [System.Text.Encoding]::UTF8.GetString($msErr.ToArray())
            throw "git $($Arguments -join ' ') failed with exit code $($proc.ExitCode): $errStr"
        }

        $rawBytes = $msOut.ToArray()
        # Unary comma prevents PowerShell from unrolling empty byte[] into $null
        return ,$rawBytes
    } finally {
        if ($null -ne $proc) {
            $isLive = $false
            try { $isLive = -not $proc.HasExited } catch { $isLive = $false }
            if ($isLive) {
                Invoke-Phase0TaskkillTree -TargetPid $proc.Id -TargetProcess $proc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            }
            $proc.Dispose()
        }
        $msOut.Dispose()
        $msErr.Dispose()
    }
}

# Ancestor reparse point and canonical containment validator
function Assert-CanonicalAndNoReparseAncestors([string]$targetPath, [string]$rootPath) {
    $fullTarget = [System.IO.Path]::GetFullPath($targetPath)
    if (-not $fullTarget.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -or $fullTarget -eq $rootPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
        throw "Security violation: Target escapes repository root: $fullTarget"
    }

    $current = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName($fullTarget))
    $rootInfo = [System.IO.DirectoryInfo]::new($rootPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar))
    
    while ($current -and $current.FullName.Length -ge $rootInfo.FullName.Length) {
        if ($current.Exists -and ($current.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw "Security violation: reparse point detected in ancestor path: $($current.FullName)"
        }
        $current = $current.Parent
    }
}

# 5. Capture Raw Invariant Pre-Audit Status Bytes and Separately Decode
$statusBeforeBytes = Invoke-GitProcessDirectBytes -WorkingDirectory $normalizedRoot -Arguments @("status", "--porcelain=v2", "-z", "-uall")
$statusBeforeRaw = if ($statusBeforeBytes.Length -gt 0) { [System.Text.Encoding]::UTF8.GetString($statusBeforeBytes) } else { "" }

# 6. Robust NUL-Delimited Parsing & Complete Baseline Inventory
$rawTokens = if ($statusBeforeRaw.Length -gt 0) { $statusBeforeRaw.Split([char]0) } else { @() }
$dirtyInventory = @()

for ($i = 0; $i -lt $rawTokens.Length; $i++) {
    $token = $rawTokens[$i]
    if ([string]::IsNullOrEmpty($token)) { continue }

    $state = $null
    $relPath = $null
    $origPath = $null
    $blobId = $null
    $fileMode = $null

    if ($token.StartsWith("1 ")) {
        # Ordinary tracked changes: 1 <xy> <sub> <mH> <mI> <mW> <hH> <hI> <path> (8 space delimiters)
        $spaceIndices = [System.Collections.Generic.List[int]]::new()
        for ($c = 0; $c -lt $token.Length; $c++) {
            if ($token[$c] -eq ' ') {
                $spaceIndices.Add($c)
                if ($spaceIndices.Count -eq 8) { break }
            }
        }
        if ($spaceIndices.Count -lt 8) {
            throw "Corrupt porcelain v2 ordinary record: $token"
        }
        $headerParts = $token.Substring(0, $spaceIndices[7]).Split(' ')
        $xy = $headerParts[1]
        $fileMode = $headerParts[4]
        $blobId = $headerParts[7]
        if ($blobId -match '^0+$') { $blobId = $headerParts[6] }
        
        $relPath = $token.Substring($spaceIndices[7] + 1)
        $state = if ($xy -match 'D') { "deleted" } else { "modified" }
    } elseif ($token.StartsWith("2 ")) {
        # Renamed/copied changes: 2 <xy> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><NUL><origPath> (9 space delimiters)
        $spaceIndices = [System.Collections.Generic.List[int]]::new()
        for ($c = 0; $c -lt $token.Length; $c++) {
            if ($token[$c] -eq ' ') {
                $spaceIndices.Add($c)
                if ($spaceIndices.Count -eq 9) { break }
            }
        }
        if ($spaceIndices.Count -lt 9) {
            throw "Corrupt porcelain v2 rename record: $token"
        }
        $headerParts = $token.Substring(0, $spaceIndices[8]).Split(' ')
        $fileMode = $headerParts[4]
        $blobId = $headerParts[7]
        $relPath = $token.Substring($spaceIndices[8] + 1)
        
        $i++
        if ($i -ge $rawTokens.Length) {
            throw "Porcelain v2 rename record missing origPath token."
        }
        $origPath = $rawTokens[$i]
        $state = "renamed"
    } elseif ($token.StartsWith("? ")) {
        # Untracked paths: ? <path>
        $relPath = $token.Substring(2)
        $state = "untracked"
    } elseif ($token.StartsWith("u ")) {
        # Unmerged changes: u <xy> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path> (10 space delimiters)
        $spaceIndices = [System.Collections.Generic.List[int]]::new()
        for ($c = 0; $c -lt $token.Length; $c++) {
            if ($token[$c] -eq ' ') {
                $spaceIndices.Add($c)
                if ($spaceIndices.Count -eq 10) { break }
            }
        }
        if ($spaceIndices.Count -lt 10) {
            throw "Corrupt porcelain v2 unmerged record: $token"
        }
        $relPath = $token.Substring($spaceIndices[9] + 1)
        $state = "unmerged"
    } else {
        continue
    }

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot $relPath))
    Assert-CanonicalAndNoReparseAncestors -targetPath $fullPath -rootPath $normalizedRoot

    $sha256 = $null
    $byteLength = 0

    if ($state -eq "deleted") {
        $sha256 = $null
        $byteLength = 0
    } elseif (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        $fi = [System.IO.FileInfo]::new($fullPath)
        if ($fi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Security violation: leaf file is a reparse point: $fullPath"
        }
        $sha256 = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash
        $byteLength = $fi.Length
    }

    $dirtyInventory += [ordered]@{
        path = $relPath
        state = $state
        origPath = $origPath
        blobId = $blobId
        mode = $fileMode
        sha256 = $sha256
        byteLength = $byteLength
    }
}

# 7. Authoritative Exhaustive Creation Manifest (Exact 116 Items)
$plannedRootDocs = @(
    "AGENTS.md",
    "docs/CODEX-HARNESS.md",
    "docs/CODEX-PORTING-GUIDE.md"
)

$plannedConfigsAndSchemas = @(
    ".codex/config.toml",
    ".codex/requirements.template.toml",
    ".codex/schemas/codex-agent.schema.json",
    ".codex/schemas/codex-hooks.schema.json"
)

$plannedHooks = @(
    ".codex/hooks.json",
    ".codex/hooks/validate-agent-dispatch.ps1",
    ".codex/hooks/validate-control-plane-write.ps1",
    ".codex/hooks/validate-researcher-bash.ps1",
    ".codex/hooks/validate-scribe-write.ps1",
    ".codex/hooks/validate-design-prototype-write.ps1",
    ".codex/hooks/validate-judge-command.ps1",
    ".codex/hooks/validate-terminal-packet.ps1"
)

$plannedScripts = @(
    ".agents/scripts/ProcessRunnerHelper.cs",
    ".agents/scripts/CodexLauncherResolver.psm1",
    ".agents/scripts/invoke-codex-process.ps1",
    ".agents/scripts/orchestrate-role.ps1",
    ".agents/scripts/test-broker.ps1",
    ".agents/scripts/trusted-writer.ps1",
    ".agents/scripts/toml-serializer.ps1",
    ".agents/scripts/invoke-claude-judge.ps1"
)

$plannedAgents = @(
    "orchestrator", "planner", "design-director", "researcher", "scribe",
    "t1-engineer", "t2-engineer", "t3-engineering-advisor", "engineering-lead",
    "verifier", "browser-validator", "codex-judge-runner", "ux-architect",
    "visual-system-designer", "motion-designer", "asset-art-director",
    "design-generalist", "design-reviewer", "design-prototyper"
) | ForEach-Object { ".codex/agents/$_.toml" }

$plannedSkills = @(
    "browser-validator-core", "build", "claude-operations", "cross-vendor-judging",
    "design-core", "design-direction", "design-prototype", "design-review",
    "engineering-fleet", "motion-and-assets", "planner-core",
    "planner-repository-analysis", "planner-risk-validation",
    "planner-specification-decomposition", "research-architecture",
    "research-browser-ui-safety", "research-comparison", "research-high-stakes",
    "research-root-cause", "research-source-audit", "research-strategic-general",
    "research", "researcher-core", "scribe-core", "scribe-editorial-quality",
    "scribe-research-briefing", "scribe-specification-and-planning",
    "scribe-technical-documentation", "t1-api-integration-contracts", "t1-core",
    "t1-performance-evidence", "t1-refactor-safety", "t1-route-tracing",
    "t1-security-reliability", "t1-tdd-test-design", "t1-ui-wiring-verification",
    "t2-escalation", "ux-architecture", "verifier-core", "visual-system",
    "workflow-author"
) | ForEach-Object { ".agents/skills/$_/SKILL.md" }

$plannedTests = @(
    "tests/codex-parity/validate-codex.ps1",
    "tests/codex-parity/test-codex-launcher.ps1",
    "tests/codex-parity/test-toml-serializer.ps1",
    "tests/codex-parity/test-role-precedence.ps1",
    "tests/codex-parity/test-orchestration-adapter.ps1",
    "tests/codex-parity/test-trusted-writer.ps1",
    "tests/codex-parity/test-broker.ps1",
    "tests/codex-parity/test-broker-probe.ps1",
    "tests/codex-parity/test-codex-hooks.ps1",
    "tests/codex-parity/test-claude-judge.ps1",
    "tests/codex-parity/test-strict-config.ps1",
    "tests/codex-parity/test-sentinel-validation.ps1",
    "tests/codex-parity/test-hard-fence.ps1",
    "tests/codex-parity/test-hard-fence-bypass.ps1",
    "tests/codex-parity/rollback.ps1"
)

$plannedFixtures = @(
    "tests/codex-parity/fixtures/orchestration/dispatch-orchestrator-to-planner.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-planner-to-researcher.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-planner-to-scribe.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-orchestrator-to-t1.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-orchestrator-to-lead.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-orchestrator-to-verifier.json",
    "tests/codex-parity/fixtures/orchestration/dispatch-director-to-prototyper.json",
    "tests/codex-parity/fixtures/orchestration/invalid-dispatch-leaf-to-peer.json",
    "tests/codex-parity/fixtures/broker/allowlist-sample.json",
    "tests/codex-parity/fixtures/broker/sensitive-sample.env",
    "tests/codex-parity/fixtures/hooks/test-hook-packet.json"
)

$plannedRuntimeOwned = @(
    "runtime/audit/",
    "runtime/audit/.runtime-parent-owner.json",
    "runtime/test-sandboxes/",
    "runtime/validation-checkouts/",
    "runtime/logs/"
)

# Derived exact manifest: 109 declarative + 5 runtime owned + 2 dynamic = 116 total items
$repoDeclarativeTargets = @(
    $plannedRootDocs +
    $plannedConfigsAndSchemas +
    $plannedHooks +
    $plannedScripts +
    $plannedAgents +
    $plannedSkills +
    $plannedTests +
    $plannedFixtures
)

$totalPlannedCount = $repoDeclarativeTargets.Count + $plannedRuntimeOwned.Count + 2 # +2 for dynamic manifest and baseline json files
Write-Output "Derived Exhaustive Manifest: $($repoDeclarativeTargets.Count) repository-contained targets + $($plannedRuntimeOwned.Count + 2) runtime-owned targets = $totalPlannedCount total items."

# 8. Pre-Collision & Reparse Ancestry Audit on All Repository Targets
$collisionFailures = @()
foreach ($target in $repoDeclarativeTargets) {
    $fullTarget = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot $target))
    if (Test-Path -LiteralPath $fullTarget) {
        $collisionFailures += "Target path already exists: $target"
    }
    try {
        Assert-CanonicalAndNoReparseAncestors -targetPath $fullTarget -rootPath $normalizedRoot
    } catch {
        $collisionFailures += "Ancestor reparse point violation for $($target): $_"
    }
}

if ($collisionFailures.Count -gt 0) {
    throw "Phase 0 Collision Audit Failed:`n" + ($collisionFailures -join "`n")
}

# 9. Validate Runtime/Audit Ancestry, Audit Directory Itself & Enforce Ownership Marker
$installationId = [System.Guid]::NewGuid().ToString('N')
$runtimeParent = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot "runtime"))
Assert-CanonicalAndNoReparseAncestors -targetPath $runtimeParent -rootPath $normalizedRoot

if (-not (Test-Path -LiteralPath $runtimeParent -PathType Container)) {
    $null = [CodexHarnessPhase0.NativeFileSystem]::CreateDirectoryFailIfExists($runtimeParent)
} else {
    $rtDi = [System.IO.DirectoryInfo]::new($runtimeParent)
    if ($rtDi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Security violation: runtime directory itself is a reparse point: $runtimeParent"
    }
}

$auditDir = [System.IO.Path]::GetFullPath((Join-Path $runtimeParent "audit"))
Assert-CanonicalAndNoReparseAncestors -targetPath $auditDir -rootPath $normalizedRoot

$parentMarkerFile = (Join-Path $auditDir ".runtime-parent-owner.json")

if (Test-Path -LiteralPath $auditDir -PathType Container) {
    $auditDi = [System.IO.DirectoryInfo]::new($auditDir)
    if ($auditDi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Security violation: runtime/audit itself is a reparse point: $auditDir"
    }

    if (-not (Test-Path -LiteralPath $parentMarkerFile -PathType Leaf)) {
        throw "Fail-closed: Pre-existing runtime/audit directory missing mandatory .runtime-parent-owner.json marker."
    }
    $markerFi = [System.IO.FileInfo]::new($parentMarkerFile)
    if ($markerFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "Security violation: .runtime-parent-owner.json is a reparse point: $parentMarkerFile"
    }
    $existingOwner = Get-Content -Raw -LiteralPath $parentMarkerFile | ConvertFrom-Json
    if ($existingOwner.owner -ne "CodexHarnessRuntime" -or -not [string]::Equals($existingOwner.repoRoot, $normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Fail-closed: Pre-existing runtime/audit directory has invalid or unverified ownership metadata."
    }
} else {
    $null = [CodexHarnessPhase0.NativeFileSystem]::CreateDirectoryFailIfExists($auditDir)
    $parentMarkerPayload = [ordered]@{
        owner = "CodexHarnessRuntime"
        repoRoot = $normalizedRoot
        initializedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
    $markerStream = [System.IO.FileStream]::new($parentMarkerFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $markerBytes = [System.Text.Encoding]::UTF8.GetBytes(($parentMarkerPayload | ConvertTo-Json -Depth 3))
        $markerStream.Write($markerBytes, 0, $markerBytes.Length)
    } finally {
        $markerStream.Dispose()
    }
}

# Write Intended Manifest and Baseline Snapshot Exclusively using Per-Run GUID
$intendedManifestFile = (Join-Path $auditDir "intended-creation-manifest-$installationId.json")
$intendedPayload = [ordered]@{
    installationId = $installationId
    timestampUtc = (Get-Date).ToUniversalTime().ToString('o')
    totalCount = $totalPlannedCount
    repositoryTargets = $repoDeclarativeTargets
    runtimeOwned = $plannedRuntimeOwned
}
$mStream = [System.IO.FileStream]::new($intendedManifestFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
try {
    $mBytes = [System.Text.Encoding]::UTF8.GetBytes(($intendedPayload | ConvertTo-Json -Depth 5))
    $mStream.Write($mBytes, 0, $mBytes.Length)
} finally {
    $mStream.Dispose()
}

$baselineFile = (Join-Path $auditDir "phase0-baseline-$installationId.json")
$baselinePayload = [ordered]@{
    installationId = $installationId
    timestampUtc = (Get-Date).ToUniversalTime().ToString('o')
    dirtyInventory = $dirtyInventory
}
$bStream = [System.IO.FileStream]::new($baselineFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
try {
    $bBytes = [System.Text.Encoding]::UTF8.GetBytes(($baselinePayload | ConvertTo-Json -Depth 5))
    $bStream.Write($bBytes, 0, $bBytes.Length)
} finally {
    $bStream.Dispose()
}

# 10. Exact Byte-for-Byte Raw Git Status Invariance & Deep Baseline Rehash Gate
$statusAfterBytes = Invoke-GitProcessDirectBytes -WorkingDirectory $normalizedRoot -Arguments @("status", "--porcelain=v2", "-z", "-uall")

if ($statusBeforeBytes.Length -ne $statusAfterBytes.Length) {
    throw "Fail-closed: Repository state mutated during Phase 0 bootstrap audit! Raw byte count differs ($($statusBeforeBytes.Length) vs $($statusAfterBytes.Length))."
}
for ($b = 0; $b -lt $statusBeforeBytes.Length; $b++) {
    if ($statusBeforeBytes[$b] -ne $statusAfterBytes[$b]) {
        throw "Fail-closed: Repository state mutated during Phase 0 bootstrap audit! Raw status differs at byte offset $b."
    }
}

# Re-inspect every baseline dirty/untracked file for deep type and hash invariance
foreach ($invItem in $dirtyInventory) {
    $itemRel = $invItem.path
    $itemFull = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot $itemRel))
    
    if ($invItem.state -eq "deleted") {
        if (Test-Path -LiteralPath $itemFull) {
            throw "Fail-closed: Baseline deleted file resurrected during audit: $itemRel"
        }
    } else {
        if (-not (Test-Path -LiteralPath $itemFull -PathType Leaf)) {
            throw "Fail-closed: Baseline file missing or changed type after audit: $itemRel"
        }
        $postFi = [System.IO.FileInfo]::new($itemFull)
        if ($postFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Security violation: Baseline file converted to reparse point during audit: $itemRel"
        }
        if ($postFi.Length -ne $invItem.byteLength) {
            throw "Fail-closed: Baseline file length mutated during audit: $itemRel"
        }
        $postHash = (Get-FileHash -LiteralPath $itemFull -Algorithm SHA256).Hash
        if ($postHash -ne $invItem.sha256) {
            throw "Fail-closed: Baseline file SHA-256 hash mutated during audit: $itemRel"
        }
    }
}

Write-Output "Phase 0 Audit Complete. Intended manifest: $intendedManifestFile. All $totalPlannedCount planned items derived, verified collision-free, raw status byte-identical, and dirty inventory proven 100% hash invariant."
```
<!-- END_PHASE0_DRIVER_SCRIPT -->


---

### 3. Implementation Controller Staging, Verification & Guarded Cleanup Procedure

The following controller procedure is staged and executed by outer implementation orchestration prior to creating any repository file. It accepts mandatory `-SourcePlanPath` and `-ExpectedSourcePlanSha256`, eliminates TOCTOU by calling `[System.IO.File]::ReadAllBytes` exactly once, calculates the SHA-256 hash over that pinned byte buffer, verifies the SHA-256 expectation via ordinal normalized comparison, decodes that same immutable byte buffer using strict UTF-8, extracts the driver code fence strictly from the in-memory line buffer using a deterministic line-based extractor (never using regexes, never reading from disk twice, and never inspecting `$MyInvocation.MyCommand.Path`), and uses a self-contained, hardened `Invoke-VerifiedTreeKill` powered by the C# Toolhelp32 snapshot helper with a single Stopwatch **3000 ms total deadline**, **750 ms emergency reserve** (2250 ms authoritative subdeadline), authoritative subdeadline wait limit on taskkill helper, universal emergency mitigation without skip guards, and 64 descendant cap:

<!-- BEGIN_PHASE0_CONTROLLER_SCRIPT -->
```powershell
# ==============================================================================
# Phase 0 Implementation Controller: External Staging, Invocation & Guarded Cleanup
# ==============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePlanPath,

    [Parameter(Mandatory = $true)]
    [string]$ExpectedSourcePlanSha256
)

$ErrorActionPreference = 'Stop'

# 1. Assert PowerShell 7 prerequisite
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "Fail-closed: PowerShell 7+ required for Phase 0 controller execution."
}

# 2. Canonicalize and verify explicit SourcePlanPath & Mandatory Manifest Pin
if ([string]::IsNullOrWhiteSpace($SourcePlanPath)) {
    throw "Fail-closed: Mandatory parameter -SourcePlanPath was empty or missing."
}
$canonicalSourcePlan = [System.IO.Path]::GetFullPath($SourcePlanPath)
if (-not (Test-Path -LiteralPath $canonicalSourcePlan -PathType Leaf)) {
    throw "Fail-closed: SourcePlanPath does not exist as a regular leaf file: $canonicalSourcePlan"
}
$planFi = [System.IO.FileInfo]::new($canonicalSourcePlan)
if ($planFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    throw "Security violation: SourcePlanPath file is a reparse point: $canonicalSourcePlan"
}
$planAnc = $planFi.Directory
while ($null -ne $planAnc) {
    if ($planAnc.Exists -and ($planAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: Reparse point detected in SourcePlanPath ancestor: $($planAnc.FullName)"
    }
    $planAnc = $planAnc.Parent
}

if ([string]::IsNullOrWhiteSpace($ExpectedSourcePlanSha256) -or $ExpectedSourcePlanSha256 -notmatch '^[0-9a-fA-F]{64}$') {
    throw "Fail-closed: Mandatory parameter -ExpectedSourcePlanSha256 must be exactly 64 hexadecimal characters."
}

# TOCTOU Elimination: Read bytes EXACTLY ONCE, compute hash directly on buffer, and pin immutable buffer
$planBytes = [System.IO.File]::ReadAllBytes($canonicalSourcePlan)
$sha256Managed = [System.Security.Cryptography.SHA256]::Create()
$actualPlanShaBytes = $sha256Managed.ComputeHash($planBytes)
$actualPlanSha = ($actualPlanShaBytes | ForEach-Object { $_.ToString("x2") }) -join ""

if (-not [string]::Equals($actualPlanSha, $ExpectedSourcePlanSha256, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Fail-closed: SourcePlanPath hash mismatch! Expected: $ExpectedSourcePlanSha256, Actual: $actualPlanSha. Stale-plan or TOCTOU condition detected."
}

# Decode immutable buffer using strict UTF-8 (no fallback reread from disk)
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$planText = $utf8Strict.GetString($planBytes)
$planLines = $planText -split "`r?`n"

# 3. Deterministic Line-Based Markdown Fence Extractor Operating Strictly on In-Memory Lines (Zero Regex, Zero Disk Reread)
function Extract-MarkdownCodeFenceFromLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory = $true)][string]$StartMarker,
        [Parameter(Mandatory = $true)][string]$EndMarker
    )

    $startIdx = -1
    for ($i = 0; $i -lt $Lines.Length; $i++) {
        if ($Lines[$i].Trim() -eq $StartMarker) {
            $startIdx = $i
            break
        }
    }
    if ($startIdx -eq -1) {
        throw "Fail-closed: Start marker '$StartMarker' not found in plan lines."
    }

    $endIdx = -1
    for ($i = $startIdx + 1; $i -lt $Lines.Length; $i++) {
        if ($Lines[$i].Trim() -eq $EndMarker) {
            $endIdx = $i
            break
        }
    }
    if ($endIdx -eq -1) {
        throw "Fail-closed: End marker '$EndMarker' not found after start marker in plan lines."
    }

    if ($endIdx -le $startIdx + 2) {
        throw "Fail-closed: Insufficient content between markers."
    }

    $fenceRegion = $Lines[($startIdx + 1)..($endIdx - 1)]

    if ($fenceRegion[0].Trim() -ne '```powershell') {
        throw "Fail-closed: First line inside marker region is '$($fenceRegion[0])', expected exactly '```powershell'."
    }
    if ($fenceRegion[-1].Trim() -ne '```') {
        throw "Fail-closed: Last line inside marker region is '$($fenceRegion[-1])', expected exactly '```'."
    }

    $interiorLines = $fenceRegion[1..($fenceRegion.Length - 2)]
    $extractedScript = $interiorLines -join [System.Environment]::NewLine

    $pTokens = $null
    $pErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($extractedScript, [ref]$pTokens, [ref]$pErrors)
    if ($pErrors -and $pErrors.Count -gt 0) {
        throw "Fail-closed: Extracted script failed PowerShell parser zero-error audit: $($pErrors -join '; ')"
    }

    return $extractedScript
}

# 4. Self-Contained In-Memory CreateDirectoryW helper for temp staging
$stagingFsSource = @"
using System;
using System.IO;
using System.Runtime.InteropServices;

namespace CodexPhase0Controller {
    public static class StagingFs {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CreateDirectoryW(string lpPathName, IntPtr lpSecurityAttributes);

        public static bool CreateDirectoryFailIfExists(string path) {
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentNullException(nameof(path));
            string fullPath = Path.GetFullPath(path);
            if (!CreateDirectoryW(fullPath, IntPtr.Zero)) {
                int error = Marshal.GetLastWin32Error();
                throw new IOException($"CreateDirectoryW failed for '{fullPath}' with Win32 error code {error}.");
            }
            return true;
        }
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]'CodexPhase0Controller.StagingFs').Type) {
    Add-Type -TypeDefinition $stagingFsSource -Language CSharp -ErrorAction Stop
}

# 5. Self-Contained In-Memory C# Windows Toolhelp32 Process Tree Snapshot Helper with Error-Checked Iteration
$snapshotSourceController = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarnessSnapshot {
    public sealed class SnapshotResult {
        public bool Success { get; set; }
        public bool TimedOut { get; set; }
        public bool Overflow { get; set; }
        public int[] Pids { get; set; } = Array.Empty<int>();
        public string ErrorMessage { get; set; } = string.Empty;
    }

    public static class WindowsProcessTreeSnapshot {
        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int ERROR_NO_MORE_FILES = 18;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr hObject);

        public static SnapshotResult TakeDescendantSnapshot(int rootPid, int maxDescendants = 64) {
            var result = new SnapshotResult();
            IntPtr hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot == INVALID_HANDLE_VALUE) {
                int err = Marshal.GetLastWin32Error();
                result.Success = false;
                result.ErrorMessage = $"CreateToolhelp32Snapshot failed with Win32 error {err}.";
                return result;
            }

            try {
                var parentToChildren = new Dictionary<int, List<int>>();
                var pe = new PROCESSENTRY32W();
                pe.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32W));

                if (!Process32FirstW(hSnapshot, ref pe)) {
                    int err = Marshal.GetLastWin32Error();
                    if (err == ERROR_NO_MORE_FILES) {
                        result.Success = true;
                        result.Pids = Array.Empty<int>();
                        return result;
                    }
                    result.Success = false;
                    result.ErrorMessage = $"Process32FirstW failed with Win32 error {err}.";
                    return result;
                }

                bool hasMore;
                do {
                    int ppid = (int)pe.th32ParentProcessID;
                    int pid = (int)pe.th32ProcessID;
                    if (pid > 0 && ppid > 0 && pid != ppid) {
                        if (!parentToChildren.TryGetValue(ppid, out var children)) {
                            children = new List<int>();
                            parentToChildren[ppid] = children;
                        }
                        children.Add(pid);
                    }
                    hasMore = Process32NextW(hSnapshot, ref pe);
                } while (hasMore);

                int nextErr = Marshal.GetLastWin32Error();
                if (nextErr != ERROR_NO_MORE_FILES) {
                    result.Success = false;
                    result.Pids = Array.Empty<int>();
                    result.ErrorMessage = $"Process32NextW iteration failed with Win32 error {nextErr}.";
                    return result;
                }

                var descendants = new List<int>();
                var queue = new Queue<int>();
                queue.Enqueue(rootPid);

                while (queue.Count > 0) {
                    int current = queue.Dequeue();
                    if (parentToChildren.TryGetValue(current, out var children)) {
                        foreach (int childPid in children) {
                            if (!descendants.Contains(childPid)) {
                                if (descendants.Count >= maxDescendants) {
                                    result.Success = false;
                                    result.Overflow = true;
                                    result.Pids = descendants.ToArray();
                                    result.ErrorMessage = $"Descendant process count exceeded safe cap of {maxDescendants} for PID {rootPid}.";
                                    return result;
                                }
                                descendants.Add(childPid);
                                queue.Enqueue(childPid);
                            }
                        }
                    }
                }

                result.Success = true;
                result.Pids = descendants.ToArray();
                return result;
            } catch (Exception ex) {
                result.Success = false;
                result.Pids = Array.Empty<int>();
                result.ErrorMessage = $"Exception during Toolhelp32 snapshot: {ex.Message}";
                return result;
            } finally {
                CloseHandle(hSnapshot);
            }
        }

        public static SnapshotResult TakeDescendantSnapshotBounded(int rootPid, int timeoutMs, int maxDescendants = 64) {
            if (timeoutMs <= 0) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Snapshot timeout expired before execution ({timeoutMs} ms)."
                };
            }

            var task = Task.Run(() => TakeDescendantSnapshot(rootPid, maxDescendants));
            if (!task.Wait(timeoutMs)) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Descendant snapshot timed out after {timeoutMs} ms."
                };
            }

            return task.Result;
        }
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]'CodexHarnessSnapshot.WindowsProcessTreeSnapshot').Type) {
    Add-Type -TypeDefinition $snapshotSourceController -Language CSharp -ErrorAction Stop
}

# 6. Canonical Temp Root Resolution & Reparse Audit
$rawTemp = [System.IO.Path]::GetTempPath()
$osTemp = [System.IO.Path]::GetFullPath($rawTemp)
if (-not $osTemp.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $osTemp += [System.IO.Path]::DirectorySeparatorChar
}

$tempDi = [System.IO.DirectoryInfo]::new($osTemp)
if ($tempDi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    throw "Security violation: OS temp directory is a reparse point: $osTemp"
}
$tCur = $tempDi.Parent
while ($null -ne $tCur) {
    if ($tCur.Exists -and ($tCur.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: Reparse point detected in OS temp ancestor: $($tCur.FullName)"
    }
    $tCur = $tCur.Parent
}

$phase0Guid = [System.Guid]::NewGuid().ToString('N')
$tempDriverDir = [System.IO.Path]::GetFullPath((Join-Path $osTemp "codex-phase0-$phase0Guid"))
$tempMarkerFile = (Join-Path $tempDriverDir ".phase0-owner.json")
$stagedDriverPath = (Join-Path $tempDriverDir "invoke-phase0-audit.ps1")
$stagingCleaned = $false

# 7. Self-Contained Hardened Verified Tree Kill Helper for Implementation Controller
function Invoke-VerifiedTreeKill(
    [int]$ProcessId,
    [System.Diagnostics.Process]$TargetProcess = $null,
    [int]$TotalBudgetMs = 3000,
    [int]$ReserveEmergencyMs = 750
) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $authoritativeSubdeadlineMs = $TotalBudgetMs - $ReserveEmergencyMs # 2250 ms
    $maxTrackedDescendants = 64
    $descendantPids = [System.Collections.Generic.List[int]]::new()
    $primaryFailures = [System.Collections.Generic.List[string]]::new()

    # 1. Resolve canonical SystemRoot\System32\taskkill.exe
    $systemRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
    if ([string]::IsNullOrWhiteSpace($systemRoot)) {
        $systemRoot = $env:SystemRoot
        if ([string]::IsNullOrWhiteSpace($systemRoot)) { $systemRoot = "C:\Windows" }
    }
    $canonicalSys32 = [System.IO.Path]::GetFullPath((Join-Path $systemRoot "System32"))
    if (-not $canonicalSys32.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
        $canonicalSys32 += [System.IO.Path]::DirectorySeparatorChar
    }
    $canonicalTaskkill = [System.IO.Path]::GetFullPath((Join-Path $canonicalSys32 "taskkill.exe"))

    if (-not $canonicalTaskkill.StartsWith($canonicalSys32, [System.StringComparison]::OrdinalIgnoreCase)) {
        $primaryFailures.Add("taskkill path escapes canonical System32: $canonicalTaskkill")
    }
    $tkFi = [System.IO.FileInfo]::new($canonicalTaskkill)
    if (-not $tkFi.Exists -or ($tkFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        $primaryFailures.Add("taskkill.exe missing or is a reparse point: $canonicalTaskkill")
    }
    $tkDir = $tkFi.Directory
    while ($tkDir -and $tkDir.FullName.Length -ge $systemRoot.Length) {
        if ($tkDir.Exists -and ($tkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $primaryFailures.Add("reparse point detected in taskkill ancestor: $($tkDir.FullName)")
            break
        }
        $tkDir = $tkDir.Parent
    }

    # 2. Bounded snapshot of known descendants via C# Toolhelp32 helper (pure C# on worker; no PowerShell scriptblock)
    # Bounded strictly by authoritative subdeadline
    $remSnap = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
    if ($remSnap -le 0) {
        $primaryFailures.Add("Authoritative subdeadline exhausted before descendant snapshot.")
    } else {
        try {
            $snapRes = [CodexHarnessSnapshot.WindowsProcessTreeSnapshot]::TakeDescendantSnapshotBounded($ProcessId, $remSnap, $maxTrackedDescendants)
            if (-not $snapRes.Success) {
                # Snapshot failure is NEVER treated as empty!
                $primaryFailures.Add("Descendant snapshot failed: $($snapRes.ErrorMessage) (TimedOut=$($snapRes.TimedOut), Overflow=$($snapRes.Overflow)).")
            }
            if ($null -ne $snapRes.Pids) {
                foreach ($p in $snapRes.Pids) {
                    if ($p -gt 0 -and -not $descendantPids.Contains($p)) {
                        $descendantPids.Add([int]$p)
                    }
                }
            }
        } catch {
            $primaryFailures.Add("Descendant snapshot threw exception: $($_.Exception.Message)")
        }
    }

    # 3. Execute taskkill using structured ProcessStartInfo under authoritative subdeadline
    $tkPsi = [System.Diagnostics.ProcessStartInfo]::new()
    $tkPsi.FileName = $canonicalTaskkill
    $tkPsi.UseShellExecute = $false
    $tkPsi.CreateNoWindow = $true
    $tkPsi.RedirectStandardOutput = $true
    $tkPsi.RedirectStandardError = $true
    $tkPsi.ArgumentList.Add("/PID")
    $tkPsi.ArgumentList.Add($ProcessId.ToString())
    $tkPsi.ArgumentList.Add("/T")
    $tkPsi.ArgumentList.Add("/F")

    $tkProc = $null
    $tkExitZero = $false

    try {
        $remTkStart = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
        if ($remTkStart -le 0) {
            $primaryFailures.Add("Authoritative subdeadline exhausted before taskkill start.")
        } else {
            $tkProc = [System.Diagnostics.Process]::Start($tkPsi)
            if ($null -eq $tkProc) {
                $primaryFailures.Add("Process.Start returned null for taskkill.exe.")
            } else {
                try {
                    $outT = $tkProc.StandardOutput.ReadToEndAsync()
                    $errT = $tkProc.StandardError.ReadToEndAsync()
                    $remExit = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                    if ($remExit -le 0 -or -not $tkProc.WaitForExit($remExit)) {
                        try { $tkProc.Kill() } catch { }
                        $primaryFailures.Add("taskkill process did not exit within authoritative subdeadline ($remExit ms remaining) for PID $($ProcessId).")
                    } else {
                        $remDrain = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                        if ($remDrain -le 0) {
                            $primaryFailures.Add("taskkill stream drain budget exhausted for PID $($ProcessId).")
                        } else {
                            $streams = [System.Threading.Tasks.Task]::WhenAll($outT, $errT)
                            if (-not $streams.Wait($remDrain)) {
                                $primaryFailures.Add("taskkill streams failed to drain within authoritative subdeadline for PID $($ProcessId).")
                            } else {
                                if ($tkProc.ExitCode -eq 0) {
                                    $tkExitZero = $true
                                } else {
                                    $primaryFailures.Add("taskkill exited with code $($tkProc.ExitCode): $($errT.Result)")
                                }
                            }
                        }
                    }
                } finally {
                    # Taskkill helper process cleanup: may be waited on ONLY until 2250 ms authoritative subdeadline, never into 750 ms reserve.
                    # At subdeadline, issue immediate Kill(true), record helper unverified if not exited, and transition immediately to root emergency mitigation.
                    try {
                        if (-not $tkProc.HasExited) {
                            try { $tkProc.Kill($true) } catch { try { $tkProc.Kill() } catch { } }
                            $remTkWait = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                            if ($remTkWait -gt 0) {
                                $null = $tkProc.WaitForExit($remTkWait)
                            }
                            if (-not $tkProc.HasExited) {
                                try { $tkProc.Kill($true) } catch { }
                                $primaryFailures.Add("taskkill helper process PID $($tkProc.Id) could not be verified exited before authoritative subdeadline.")
                            }
                        }
                    } catch {
                        $primaryFailures.Add("Exception during taskkill helper cleanup for PID $($ProcessId): $($_.Exception.Message)")
                    }
                    $tkProc.Dispose()
                }
            }
        }
    } catch {
        $primaryFailures.Add("taskkill invocation threw exception: $($_.Exception.Message)")
    }

    # 4. Universal Emergency Mitigation: ALWAYS attempt emergency mitigation on original live root
    # NEVER guard mitigation with a remaining-time condition that can skip it!
    # Even if authoritative subdeadline was exhausted, immediately enter emergency mitigation while reserve remains.
    # If final global deadline is already unexpectedly exhausted, issue immediate non-waiting Kill(true) in a last best-effort statement.
    if ($null -ne $TargetProcess) {
        try {
            $isLive = $false
            try { $isLive = -not $TargetProcess.HasExited } catch { $isLive = $true }
            if ($isLive) {
                $TargetProcess.Kill($true)
            }
        } catch { }
    } else {
        try {
            $rootP = [System.Diagnostics.Process]::GetProcessById($ProcessId)
            try {
                $isLive = $false
                try { $isLive = -not $rootP.HasExited } catch { $isLive = $true }
                if ($isLive) {
                    $rootP.Kill($true)
                }
            } finally {
                $rootP.Dispose()
            }
        } catch { }
    }

    foreach ($dPid in $descendantPids) {
        try {
            $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
            try {
                $isLive = $false
                try { $isLive = -not $dP.HasExited } catch { $isLive = $true }
                if ($isLive) {
                    $dP.Kill()
                }
            } finally {
                $dP.Dispose()
            }
        } catch { }
    }

    # 5. Affirmative root and descendant process exit verification within remaining global reserve
    $rootExited = $false
    $remRootWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
    if ($remRootWait -gt 0) {
        if ($null -ne $TargetProcess) {
            try { $rootExited = $TargetProcess.WaitForExit($remRootWait) -or $TargetProcess.HasExited } catch { $rootExited = $true }
        } else {
            try {
                $p = [System.Diagnostics.Process]::GetProcessById($ProcessId)
                $rootExited = $p.WaitForExit($remRootWait) -or $p.HasExited
                $p.Dispose()
            } catch { $rootExited = $true }
        }
    } else {
        if ($null -ne $TargetProcess) {
            try { $rootExited = $TargetProcess.HasExited } catch { $rootExited = $false }
        } else {
            try {
                $p = [System.Diagnostics.Process]::GetProcessById($ProcessId)
                $rootExited = $p.HasExited
                $p.Dispose()
            } catch { $rootExited = $true }
        }
    }

    $survivors = [System.Collections.Generic.List[int]]::new()
    if (-not $rootExited) { $survivors.Add($ProcessId) }

    foreach ($dPid in $descendantPids) {
        $remChildWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
        $dExited = $false
        if ($remChildWait -gt 0) {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.WaitForExit($remChildWait) -or $dP.HasExited
                $dP.Dispose()
            } catch {
                $dExited = $true
            }
        } else {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.HasExited
                $dP.Dispose()
            } catch { $dExited = $true }
        }
        if (-not $dExited) { $survivors.Add($dPid) }
    }

    $allProcessesGone = ($rootExited -and $survivors.Count -eq 0)

    # Throw distinct TreeCleanupUnverified if taskkill failed, any primary failure occurred, or any survivor remains
    # Any authoritative failure remains TreeCleanupUnverified even if emergency termination succeeds!
    if (-not ($tkExitZero -and $primaryFailures.Count -eq 0 -and $allProcessesGone)) {
        $cleanupSummary = [ordered]@{
            status = "TreeCleanupUnverified"
            processId = $ProcessId
            totalBudgetMs = $TotalBudgetMs
            reserveEmergencyMs = $ReserveEmergencyMs
            authoritativeSubdeadlineMs = $authoritativeSubdeadlineMs
            elapsedMs = [int]$sw.ElapsedMilliseconds
            taskkillExitZero = $tkExitZero
            primaryFailures = @($primaryFailures)
            fallbackKillTreeInvoked = $true
            rootExited = $rootExited
            knownDescendantCount = $descendantPids.Count
            knownSurvivorCount = $survivors.Count
            knownSurvivors = @($survivors)
        }
        $jsonSummary = ($cleanupSummary | ConvertTo-Json -Compress)
        throw "TreeCleanupUnverified: Process tree termination unverified for PID $($ProcessId) within $TotalBudgetMs ms budget ($ReserveEmergencyMs ms reserve). Summary: $jsonSummary"
    }
}

try {
    # 8. Atomic directory creation fail-if-exists
    $null = [CodexPhase0Controller.StagingFs]::CreateDirectoryFailIfExists($tempDriverDir)

    # 9. Write ownership marker file with FileMode.CreateNew
    $markerPayload = [ordered]@{
        owner = "CodexPhase0Controller"
        guid = $phase0Guid
        stagedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
    $mStream = [System.IO.FileStream]::new($tempMarkerFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes(($markerPayload | ConvertTo-Json))
        $mStream.Write($mBytes, 0, $mBytes.Length)
    } finally {
        $mStream.Dispose()
    }

    # 10. Retrieve exact driver source strictly from pinned in-memory line buffer using line-based extractor (Zero Disk Reread)
    $exactDriverText = Extract-MarkdownCodeFenceFromLines `
        -Lines $planLines `
        -StartMarker "<!-- BEGIN_PHASE0_DRIVER_SCRIPT -->" `
        -EndMarker "<!-- END_PHASE0_DRIVER_SCRIPT -->"

    # 11. Write exact UTF-8 driver bytes directly to staged temp path
    $driverBytes = [System.Text.Encoding]::UTF8.GetBytes($exactDriverText)
    $dStream = [System.IO.FileStream]::new($stagedDriverPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $dStream.Write($driverBytes, 0, $driverBytes.Length)
    } finally {
        $dStream.Dispose()
    }

    # 12. Read back and verify exact SHA-256 hash match
    $expectedHash = (New-Object System.Security.Cryptography.SHA256Managed).ComputeHash($driverBytes)
    $expectedHashStr = ($expectedHash | ForEach-Object { $_.ToString("X2") }) -join ""
    $actualHashStr = (Get-FileHash -LiteralPath $stagedDriverPath -Algorithm SHA256).Hash

    if (-not [string]::Equals($expectedHashStr, $actualHashStr, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Fail-closed: Staged Phase 0 driver hash mismatch! Expected: $expectedHashStr, Found: $actualHashStr"
    }

    # 13. Execute staged driver with parse-correct try/finally Dispose and Bounded Runner
    $pwshExe = (Get-Command "pwsh.exe" -ErrorAction Stop).Source
    $procInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $procInfo.FileName = $pwshExe
    $procInfo.ArgumentList.Add("-NoProfile")
    $procInfo.ArgumentList.Add("-ExecutionPolicy")
    $procInfo.ArgumentList.Add("Bypass")
    $procInfo.ArgumentList.Add("-File")
    $procInfo.ArgumentList.Add($stagedDriverPath)
    $procInfo.ArgumentList.Add("-RepoRoot")
    $procInfo.ArgumentList.Add("H:\CommandCenter\orchestrator")
    $procInfo.UseShellExecute = $false
    $procInfo.RedirectStandardOutput = $true
    $procInfo.RedirectStandardError = $true

    $driverProc = [System.Diagnostics.Process]::Start($procInfo)
    if ($null -eq $driverProc) {
        throw "Failed to start staged Phase 0 audit driver process."
    }

    $swDriver = [System.Diagnostics.Stopwatch]::StartNew()
    $driverTimeoutMs = 60000

    try {
        $outTask = $driverProc.StandardOutput.ReadToEndAsync()
        $errTask = $driverProc.StandardError.ReadToEndAsync()

        $remExitMs = $driverTimeoutMs - [int]$swDriver.ElapsedMilliseconds
        if ($remExitMs -le 0 -or -not $driverProc.WaitForExit($remExitMs)) {
            Invoke-VerifiedTreeKill -ProcessId $driverProc.Id -TargetProcess $driverProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "Phase 0 audit driver timed out after 60 seconds (process tree verified terminated)."
        }

        $remDrainMs = 5000 - [int]$swDriver.ElapsedMilliseconds
        if ($remDrainMs -le 0) {
            Invoke-VerifiedTreeKill -ProcessId $driverProc.Id -TargetProcess $driverProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "Phase 0 audit driver stream drain budget exhausted (process tree verified terminated)."
        }
        $streamsTask = [System.Threading.Tasks.Task]::WhenAll($outTask, $errTask)
        if (-not $streamsTask.Wait($remDrainMs)) {
            Invoke-VerifiedTreeKill -ProcessId $driverProc.Id -TargetProcess $driverProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            throw "Phase 0 audit driver streams failed to drain within remaining budget (process tree verified terminated)."
        }

        Write-Output $outTask.Result
        if ($driverProc.ExitCode -ne 0) {
            throw "Phase 0 audit driver failed with exit code $($driverProc.ExitCode): $($errTask.Result)"
        }
    } finally {
        if ($null -ne $driverProc) {
            $isLive = $false
            try { $isLive = -not $driverProc.HasExited } catch { $isLive = $false }
            if ($isLive) {
                Invoke-VerifiedTreeKill -ProcessId $driverProc.Id -TargetProcess $driverProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
            }
            $driverProc.Dispose()
        }
    }
} finally {
    # 14. Guarded Cleanup: Verifies temp containment, marker ownership, non-reparse integrity, and refuses deletion on violation
    if (Test-Path -LiteralPath $tempDriverDir) {
        $canDelete = $true
        $fullDel = [System.IO.Path]::GetFullPath($tempDriverDir)
        if (-not $fullDel.StartsWith($osTemp, [System.StringComparison]::OrdinalIgnoreCase) -or $fullDel -eq $osTemp.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
            $canDelete = $false
            throw "Cleanup Security Violation: Staged temp path escapes OS temp directory: $fullDel. Refusing deletion."
        }
        if (-not (Test-Path -LiteralPath $tempMarkerFile -PathType Leaf)) {
            $canDelete = $false
            throw "Cleanup Security Violation: Ownership marker missing from staged temp directory: $tempMarkerFile. Refusing deletion."
        } else {
            $mContent = Get-Content -Raw -LiteralPath $tempMarkerFile | ConvertFrom-Json
            if ($mContent.guid -ne $phase0Guid) {
                $canDelete = $false
                throw "Cleanup Security Violation: Staged temp directory ownership marker mismatch. Refusing deletion."
            }
        }
        $delDi = [System.IO.DirectoryInfo]::new($fullDel)
        if ($delDi.Exists -and ($delDi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $canDelete = $false
            throw "Cleanup Security Violation: Staged temp directory is a reparse point: $fullDel. Refusing deletion."
        }

        $dAnc = $delDi.Parent
        while ($null -ne $dAnc) {
            if ($dAnc.Exists -and ($dAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                $canDelete = $false
                throw "Cleanup Security Violation: Reparse point in staged temp directory ancestor: $($dAnc.FullName). Refusing deletion."
            }
            $dAnc = $dAnc.Parent
        }

        if ($canDelete) {
            Remove-Item -LiteralPath $fullDel -Recurse -Force -ErrorAction Stop
            $stagingCleaned = $true
            Write-Output "Phase 0 Staging Cleanup Complete: Deleted owned staging directory $fullDel."
        }
    }
}
```
<!-- END_PHASE0_CONTROLLER_SCRIPT -->

---

## Nested Sandbox Bypass, Axis A & Axis B Verification (`tests/codex-parity/test-hard-fence-bypass.ps1`)

The Level 2 Hard-Fence Bypass Verification suite evaluates both independent Level 2 axes using syntactically valid sacrificial sentinels in a disposable checkout, enforcing true outer-to-inner wrapper execution, strict error classification, parse-audited payloads, deterministic profile differential under official config precedence, and hardened recursive cleanup refusal. The nested probe wrapper incorporates the C# Toolhelp32 snapshot helper, authoritative subdeadline bounding on the taskkill helper, and universal emergency mitigation:

```powershell
[CmdletBinding()]
param(
    [string]$RepoRoot = "H:\CommandCenter\orchestrator",
    [Parameter(Mandatory = $false)][string[]]$AdminApprovedPrincipalAllowlist = $null,
    [Parameter(Mandatory = $false)][string]$PrincipalEvidenceReference = $null
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw "Fail-closed: PowerShell 7+ (pwsh.exe) is required for test-hard-fence-bypass.ps1."
}

$normalizedRepoRoot = [System.IO.Path]::GetFullPath($RepoRoot)
if (-not $normalizedRepoRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $normalizedRepoRoot += [System.IO.Path]::DirectorySeparatorChar
}

$runGuid = [System.Guid]::NewGuid().ToString('N')
$valCheckoutsBase = [System.IO.Path]::GetFullPath((Join-Path $normalizedRepoRoot "runtime/validation-checkouts"))
if (-not $valCheckoutsBase.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $valCheckoutsBase += [System.IO.Path]::DirectorySeparatorChar
}

$valCheckout = [System.IO.Path]::GetFullPath((Join-Path $valCheckoutsBase $runGuid))

# 1. Canonical Validation of Checkout Directory Base and Ancestors
if (-not $valCheckout.StartsWith($valCheckoutsBase, [System.StringComparison]::OrdinalIgnoreCase) -or
    $valCheckout -eq $valCheckoutsBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
    throw "Security violation: validation checkout path escapes canonical validation-checkouts base: $valCheckout"
}

$chkCurrent = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName($valCheckout))
while ($chkCurrent -and $chkCurrent.FullName.Length -ge $normalizedRepoRoot.Length) {
    if ($chkCurrent.Exists -and ($chkCurrent.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: reparse point detected in checkout ancestor: $($chkCurrent.FullName)"
    }
    $chkCurrent = $chkCurrent.Parent
}

# Load C# helper for atomic fail-if-exists directory creation if not already loaded
$helperSourcePath = (Join-Path $normalizedRepoRoot ".agents/scripts/ProcessRunnerHelper.cs")
if (-not ([System.Management.Automation.PSTypeName]'CodexHarness.NativeFileSystem').Type) {
    $csharpSource = Get-Content -Raw -LiteralPath $helperSourcePath -Encoding UTF8
    Add-Type -TypeDefinition $csharpSource -Language CSharp -ErrorAction Stop
}

$ownerMarkerPath = (Join-Path $valCheckout ".checkout-owner.json")
$cleanupSucceeded = $false
$testFailure = $null

try {
    # Atomic Directory Creation via PInvoke CreateDirectoryW
    $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists($valCheckout)

    # 2. Write Unique Ownership Marker File using FileMode.CreateNew
    $ownerPayload = [ordered]@{
        runGuid = $runGuid
        checkoutPath = $valCheckout
        createdAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
    $mStream = [System.IO.FileStream]::new($ownerMarkerPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes(($ownerPayload | ConvertTo-Json))
        $mStream.Write($mBytes, 0, $mBytes.Length)
    } finally {
        $mStream.Dispose()
    }

    Write-Output "Executing True Nested Sandbox Bypass & Managed Profile Exclusion Verification..."

    # 3. Provision Isolated Dual Codex Homes (Zero [profiles.*] tables, Zero Legacy Settings in Inner Config)
    $outerCodexHome = (Join-Path $valCheckout "outer-codex-home")
    $innerCodexHome = (Join-Path $valCheckout "inner-codex-home")
    $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists($outerCodexHome)
    $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists($innerCodexHome)

    # Normalized forward-slash path for TOML table keys
    $valCheckoutTomlPath = $valCheckout.Replace("\", "/")

    # Outer Home Config: defines snapshot-isolated profile locally and declares checkout trusted
    $outerConfig = @"
sandbox_mode = "read-only"
approval_policy = "on-request"

[windows]
sandbox = "elevated"
sandbox_private_desktop = true

[projects."$valCheckoutTomlPath"]
trust_level = "trusted"

[permissions.snapshot-isolated]
description = "Outer snapshot-isolated profile"
extends = ":workspace"
network.enabled = false
"@
    $outCfgStream = [System.IO.FileStream]::new((Join-Path $outerCodexHome "config.toml"), [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $b = [System.Text.Encoding]::UTF8.GetBytes($outerConfig)
        $outCfgStream.Write($b, 0, $b.Length)
    } finally { $outCfgStream.Dispose() }

    # Inner Home Config: Defines only [permissions.snapshot-isolated] extends = ":workspace" using official schema.
    # Completely eliminates every [profiles.*] table and eliminates legacy sandbox_mode / approval_policy settings.
    $innerConfig = @"
[projects."$valCheckoutTomlPath"]
trust_level = "trusted"

[permissions.snapshot-isolated]
description = "Inner snapshot-isolated profile with workspace write"
extends = ":workspace"
"@
    $inCfgStream = [System.IO.FileStream]::new((Join-Path $innerCodexHome "config.toml"), [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $b = [System.Text.Encoding]::UTF8.GetBytes($innerConfig)
        $inCfgStream.Write($b, 0, $b.Length)
    } finally { $inCfgStream.Dispose() }

    # 4. Plant Syntactically Valid Sacrificial Sentinels
    $sentinelDirs = @(".codex", ".claude", "docs", "scratch")
    foreach ($d in $sentinelDirs) {
        $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists((Join-Path $valCheckout $d))
    }

    $protectedSentinels = [ordered]@{
        ".codex/config.toml" = "# Sacrificial protected project configuration sentinel for Axis A immutability verification`n# Contains harmless supported project configuration with zero overlapping permission keys`nproject_doc_fallback_filenames = [`"TEAM_GUIDE.md`", `".agents.md`"]`n`n[features]`nunified_exec = false`n"
        ".claude/settings.json" = "{`"model`": `"claude-3-7-sonnet`"}`n"
        "AGENTS.md" = "# AGENTS CONTRACT`n`nProtected instructions.`n"
        "CLAUDE.md" = "# CLAUDE CONTRACT`n`nProtected instructions.`n"
        "docs/PLAN-CONTRACT.md" = "# PLAN CONTRACT`n`nProtected contract.`n"
    }

    $expectedProtectedKeys = @($protectedSentinels.Keys)
    if ($expectedProtectedKeys.Count -ne 5) {
        throw "Fail-closed: Expected exactly 5 protected sentinels, found $($expectedProtectedKeys.Count)."
    }

    $baselineHashes = [ordered]@{ }
    foreach ($rel in $expectedProtectedKeys) {
        $sentinelPath = (Join-Path $valCheckout $rel)
        $fs = [System.IO.FileStream]::new($sentinelPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
        try {
            $b = [System.Text.Encoding]::UTF8.GetBytes($protectedSentinels[$rel])
            $fs.Write($b, 0, $b.Length)
        } finally { $fs.Dispose() }
        $baselineHashes[$rel] = (Get-FileHash -LiteralPath $sentinelPath -Algorithm SHA256).Hash
    }

    # Plant Unprotected Positive Control Sentinel
    $positiveSentinel = (Join-Path $valCheckout "scratch/unprotected-sentinel.txt")
    $posFs = [System.IO.FileStream]::new($positiveSentinel, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $b = [System.Text.Encoding]::UTF8.GetBytes("INITIAL_CONTENT`n")
        $posFs.Write($b, 0, $b.Length)
    } finally { $posFs.Dispose() }

    $launcherScript = (Join-Path $normalizedRepoRoot ".agents/scripts/invoke-codex-process.ps1")
    $resolverModule = (Join-Path $normalizedRepoRoot ".agents/scripts/CodexLauncherResolver.psm1")
    Import-Module $resolverModule -ErrorAction Stop
    $launcher = Resolve-CodexLauncher
    $pwshPath = (Get-Command "pwsh.exe" -ErrorAction Stop).Source

    # 5. Create Trusted Direct Outer-to-Inner Wrapper Script with Toolhelp32 Snapshot and Universal Mitigation
    $wrapperScriptPath = (Join-Path $valCheckout "nested-probe-wrapper.ps1")
    $wrapperSource = @'
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InnerLauncherExecutable,
    [Parameter(Mandatory = $false)][string]$InnerScriptEntry,
    [Parameter(Mandatory = $true)][string]$InnerCodexHome,
    [Parameter(Mandatory = $true)][string]$OuterCodexHome,
    [Parameter(Mandatory = $true)][string]$CheckoutDir,
    [Parameter(Mandatory = $true)][string]$TargetPayloadScript,
    [Parameter(Mandatory = $false)][string]$ExpectedInnerProfile = "snapshot-isolated"
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ExpectedInnerProfile)) {
    [Console]::Error.WriteLine("Wrapper Error: ExpectedInnerProfile must be non-empty and specified.")
    exit 98
}

# 1. Assert outer process environment CODEX_HOME is strictly $OuterCodexHome
$currentOuterHome = $env:CODEX_HOME
if (-not [string]::Equals([System.IO.Path]::GetFullPath($currentOuterHome), [System.IO.Path]::GetFullPath($OuterCodexHome), [System.StringComparison]::OrdinalIgnoreCase)) {
    [Console]::Error.WriteLine("Wrapper Error: Outer CODEX_HOME is '$currentOuterHome', expected '$OuterCodexHome'.")
    exit 99
}

# 2. Derive and validate canonical System32 taskkill.exe with zero reparse points
$sysRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
if ([string]::IsNullOrWhiteSpace($sysRoot)) { $sysRoot = $env:SystemRoot; if (-not $sysRoot) { $sysRoot = "C:\Windows" } }
$canonicalSys32 = [System.IO.Path]::GetFullPath((Join-Path $sysRoot "System32"))
if (-not $canonicalSys32.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) { $canonicalSys32 += [System.IO.Path]::DirectorySeparatorChar }
$canonicalTaskkill = [System.IO.Path]::GetFullPath((Join-Path $canonicalSys32 "taskkill.exe"))

if (-not $canonicalTaskkill.StartsWith($canonicalSys32, [System.StringComparison]::OrdinalIgnoreCase)) {
    [Console]::Error.WriteLine("TreeCleanupUnverified: taskkill path escapes canonical System32: $canonicalTaskkill")
    exit 125
}
$tkFi = [System.IO.FileInfo]::new($canonicalTaskkill)
if (-not $tkFi.Exists -or ($tkFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
    [Console]::Error.WriteLine("TreeCleanupUnverified: taskkill.exe missing or is a reparse point: $canonicalTaskkill")
    exit 125
}
$tkAnc = $tkFi.Directory
while ($tkAnc -and $tkAnc.FullName.Length -ge $sysRoot.Length) {
    if ($tkAnc.Exists -and ($tkAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        [Console]::Error.WriteLine("TreeCleanupUnverified: Reparse point detected in taskkill ancestor: $($tkAnc.FullName)")
        exit 125
    }
    $tkAnc = $tkAnc.Parent
}

# 3. Compile in-memory C# Toolhelp32 Snapshot Helper for nested wrapper with Error-Checked Iteration
$wrapperSnapshotSource = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarnessSnapshot {
    public sealed class SnapshotResult {
        public bool Success { get; set; }
        public bool TimedOut { get; set; }
        public bool Overflow { get; set; }
        public int[] Pids { get; set; } = Array.Empty<int>();
        public string ErrorMessage { get; set; } = string.Empty;
    }

    public static class WindowsProcessTreeSnapshot {
        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int ERROR_NO_MORE_FILES = 18;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr hObject);

        public static SnapshotResult TakeDescendantSnapshot(int rootPid, int maxDescendants = 64) {
            var result = new SnapshotResult();
            IntPtr hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot == INVALID_HANDLE_VALUE) {
                int err = Marshal.GetLastWin32Error();
                result.Success = false;
                result.ErrorMessage = $"CreateToolhelp32Snapshot failed with Win32 error {err}.";
                return result;
            }

            try {
                var parentToChildren = new Dictionary<int, List<int>>();
                var pe = new PROCESSENTRY32W();
                pe.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32W));

                if (!Process32FirstW(hSnapshot, ref pe)) {
                    int err = Marshal.GetLastWin32Error();
                    if (err == ERROR_NO_MORE_FILES) {
                        result.Success = true;
                        result.Pids = Array.Empty<int>();
                        return result;
                    }
                    result.Success = false;
                    result.ErrorMessage = $"Process32FirstW failed with Win32 error {err}.";
                    return result;
                }

                bool hasMore;
                do {
                    int ppid = (int)pe.th32ParentProcessID;
                    int pid = (int)pe.th32ProcessID;
                    if (pid > 0 && ppid > 0 && pid != ppid) {
                        if (!parentToChildren.TryGetValue(ppid, out var children)) {
                            children = new List<int>();
                            parentToChildren[ppid] = children;
                        }
                        children.Add(pid);
                    }
                    hasMore = Process32NextW(hSnapshot, ref pe);
                } while (hasMore);

                int nextErr = Marshal.GetLastWin32Error();
                if (nextErr != ERROR_NO_MORE_FILES) {
                    result.Success = false;
                    result.Pids = Array.Empty<int>();
                    result.ErrorMessage = $"Process32NextW iteration failed with Win32 error {nextErr}.";
                    return result;
                }

                var descendants = new List<int>();
                var queue = new Queue<int>();
                queue.Enqueue(rootPid);

                while (queue.Count > 0) {
                    int current = queue.Dequeue();
                    if (parentToChildren.TryGetValue(current, out var children)) {
                        foreach (int childPid in children) {
                            if (!descendants.Contains(childPid)) {
                                if (descendants.Count >= maxDescendants) {
                                    result.Success = false;
                                    result.Overflow = true;
                                    result.Pids = descendants.ToArray();
                                    result.ErrorMessage = $"Descendant process count exceeded safe cap of {maxDescendants} for PID {rootPid}.";
                                    return result;
                                }
                                descendants.Add(childPid);
                                queue.Enqueue(childPid);
                            }
                        }
                    }
                }

                result.Success = true;
                result.Pids = descendants.ToArray();
                return result;
            } catch (Exception ex) {
                result.Success = false;
                result.Pids = Array.Empty<int>();
                result.ErrorMessage = $"Exception during Toolhelp32 snapshot: {ex.Message}";
                return result;
            } finally {
                CloseHandle(hSnapshot);
            }
        }

        public static SnapshotResult TakeDescendantSnapshotBounded(int rootPid, int timeoutMs, int maxDescendants = 64) {
            if (timeoutMs <= 0) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Snapshot timeout expired before execution ({timeoutMs} ms)."
                };
            }

            var task = Task.Run(() => TakeDescendantSnapshot(rootPid, maxDescendants));
            if (!task.Wait(timeoutMs)) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Descendant snapshot timed out after {timeoutMs} ms."
                };
            }

            return task.Result;
        }
    }
}
"@
if (-not ([System.Management.Automation.PSTypeName]'CodexHarnessSnapshot.WindowsProcessTreeSnapshot').Type) {
    Add-Type -TypeDefinition $wrapperSnapshotSource -Language CSharp -ErrorAction Stop
}

# Helper for verified tree cleanup with Toolhelp32 snapshot, single global stopwatch budget (3000 ms total, 750 ms emergency reserve),
# authoritative subdeadline wait limit on taskkill helper, and universal mitigation without skip guards
function Invoke-InnerVerifiedTreeKill(
    [System.Diagnostics.Process]$proc,
    [int]$tkBudgetMs = 3000,
    [int]$tkReserveMs = 750
) {
    $tkSw = [System.Diagnostics.Stopwatch]::StartNew()
    $authoritativeSubdeadlineMs = $tkBudgetMs - $tkReserveMs # 2250 ms
    $maxTrackedDescendants = 64
    $descendantPids = [System.Collections.Generic.List[int]]::new()
    $primaryFailures = [System.Collections.Generic.List[string]]::new()

    # A. Bounded snapshot of known descendants via Toolhelp32 bounded by authoritative subdeadline
    $remSnap = $authoritativeSubdeadlineMs - [int]$tkSw.ElapsedMilliseconds
    if ($remSnap -le 0) {
        $primaryFailures.Add("Cleanup budget exhausted before descendant snapshot.")
    } else {
        try {
            $snapRes = [CodexHarnessSnapshot.WindowsProcessTreeSnapshot]::TakeDescendantSnapshotBounded($proc.Id, $remSnap, $maxTrackedDescendants)
            if (-not $snapRes.Success) {
                $primaryFailures.Add("Descendant snapshot failed: $($snapRes.ErrorMessage)")
            }
            if ($null -ne $snapRes.Pids) {
                foreach ($p in $snapRes.Pids) {
                    if ($p -gt 0 -and -not $descendantPids.Contains($p)) {
                        $descendantPids.Add([int]$p)
                    }
                }
            }
        } catch {
            $primaryFailures.Add("Snapshot threw exception: $($_.Exception.Message)")
        }
    }

    # B. Execute canonical System32 taskkill bounded by authoritative subdeadline
    $tkPsi = [System.Diagnostics.ProcessStartInfo]::new()
    $tkPsi.FileName = $canonicalTaskkill
    $tkPsi.UseShellExecute = $false
    $tkPsi.CreateNoWindow = $true
    $tkPsi.RedirectStandardOutput = $true
    $tkPsi.RedirectStandardError = $true
    $tkPsi.ArgumentList.Add("/PID")
    $tkPsi.ArgumentList.Add($proc.Id.ToString())
    $tkPsi.ArgumentList.Add("/T")
    $tkPsi.ArgumentList.Add("/F")

    $tkProc = $null
    $tkExitZero = $false

    try {
        $remTkStart = $authoritativeSubdeadlineMs - [int]$tkSw.ElapsedMilliseconds
        if ($remTkStart -le 0) {
            $primaryFailures.Add("Budget exhausted before taskkill start.")
        } else {
            $tkProc = [System.Diagnostics.Process]::Start($tkPsi)
            if ($null -eq $tkProc) {
                $primaryFailures.Add("Process.Start returned null for taskkill.exe.")
            } else {
                try {
                    $tkOutTask = $tkProc.StandardOutput.ReadToEndAsync()
                    $tkErrTask = $tkProc.StandardError.ReadToEndAsync()

                    $tkRemExitMs = $authoritativeSubdeadlineMs - [int]$tkSw.ElapsedMilliseconds
                    if ($tkRemExitMs -gt 0 -and $tkProc.WaitForExit($tkRemExitMs)) {
                        $tkRemDrainMs = $authoritativeSubdeadlineMs - [int]$tkSw.ElapsedMilliseconds
                        if ($tkRemDrainMs -gt 0) {
                            $tkStreams = [System.Threading.Tasks.Task]::WhenAll($tkOutTask, $tkErrTask)
                            if ($tkStreams.Wait($tkRemDrainMs)) {
                                if ($tkProc.ExitCode -eq 0) {
                                    $tkExitZero = $true
                                } else {
                                    $primaryFailures.Add("taskkill exited with code $($tkProc.ExitCode): $($tkErrTask.Result)")
                                }
                            } else {
                                $primaryFailures.Add("taskkill stream drain timed out.")
                            }
                        } else {
                            $primaryFailures.Add("taskkill stream drain budget exhausted.")
                        }
                    } else {
                        try { $tkProc.Kill() } catch { }
                        $primaryFailures.Add("taskkill process did not exit within budget.")
                    }
                } finally {
                    # Taskkill helper process cleanup: may be waited on ONLY until 2250 ms authoritative subdeadline, never into 750 ms reserve.
                    # At subdeadline, issue immediate Kill(true), record helper unverified if not exited, and transition immediately to root emergency mitigation.
                    try {
                        if (-not $tkProc.HasExited) {
                            try { $tkProc.Kill($true) } catch { try { $tkProc.Kill() } catch { } }
                            $remW = $authoritativeSubdeadlineMs - [int]$tkSw.ElapsedMilliseconds
                            if ($remW -gt 0) { $null = $tkProc.WaitForExit($remW) }
                            if (-not $tkProc.HasExited) {
                                try { $tkProc.Kill($true) } catch { }
                                $primaryFailures.Add("taskkill helper process PID $($tkProc.Id) could not be verified exited before authoritative subdeadline.")
                            }
                        }
                    } catch {
                        $primaryFailures.Add("Exception during taskkill helper cleanup: $($_.Exception.Message)")
                    }
                    $tkProc.Dispose()
                }
            }
        }
    } catch {
        $primaryFailures.Add("taskkill invocation threw: $($_.Exception.Message)")
    }

    # C. Universal Emergency Mitigation: ALWAYS attempt emergency mitigation on live root
    # NEVER guard mitigation with a remaining-time condition that can skip it!
    # If final global deadline is already unexpectedly exhausted, issue immediate non-waiting Kill(true) in a last best-effort statement.
    try {
        $isLive = $false
        try { $isLive = -not $proc.HasExited } catch { $isLive = $true }
        if ($isLive) { $proc.Kill($true) }
    } catch { }

    foreach ($dPid in $descendantPids) {
        try {
            $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
            try {
                $isLive = $false
                try { $isLive = -not $dP.HasExited } catch { $isLive = $true }
                if ($isLive) { $dP.Kill() }
            } finally {
                $dP.Dispose()
            }
        } catch { }
    }

    # D. Affirmative root and descendant exit checks within remaining global reserve
    $rootExited = $false
    $remRootWait = $tkBudgetMs - [int]$tkSw.ElapsedMilliseconds
    if ($remRootWait -gt 0) {
        try { $rootExited = $proc.WaitForExit($remRootWait) -or $proc.HasExited } catch { $rootExited = $true }
    } else {
        try { $rootExited = $proc.HasExited } catch { $rootExited = $false }
    }

    $survivors = [System.Collections.Generic.List[int]]::new()
    if (-not $rootExited) { $survivors.Add($proc.Id) }

    foreach ($dPid in $descendantPids) {
        $remChildWait = $tkBudgetMs - [int]$tkSw.ElapsedMilliseconds
        $dExited = $false
        if ($remChildWait -gt 0) {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.WaitForExit($remChildWait) -or $dP.HasExited
                $dP.Dispose()
            } catch {
                $dExited = $true
            }
        } else {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                $dExited = $dP.HasExited
                $dP.Dispose()
            } catch { $dExited = $true }
        }
        if (-not $dExited) { $survivors.Add($dPid) }
    }

    $allGone = ($rootExited -and $survivors.Count -eq 0)

    # Any authoritative failure remains TreeCleanupUnverified even if emergency mitigation killed everything!
    if (-not ($tkExitZero -and $primaryFailures.Count -eq 0 -and $allGone)) {
        $cleanupSummary = [ordered]@{
            status = "TreeCleanupUnverified"
            processId = $proc.Id
            totalBudgetMs = $tkBudgetMs
            reserveEmergencyMs = $tkReserveMs
            authoritativeSubdeadlineMs = $authoritativeSubdeadlineMs
            elapsedMs = [int]$tkSw.ElapsedMilliseconds
            taskkillExitZero = $tkExitZero
            primaryFailures = @($primaryFailures)
            fallbackKillTreeInvoked = $true
            rootExited = $rootExited
            knownDescendantCount = $descendantPids.Count
            knownSurvivorCount = $survivors.Count
            knownSurvivors = @($survivors)
        }
        $jsonSummary = ($cleanupSummary | ConvertTo-Json -Compress)
        [Console]::Error.WriteLine("TreeCleanupUnverified: Inner process PID $($proc.Id) cleanup unverified. Summary: $jsonSummary")
        exit 125
    }
}

# Helper for bounded inner execution with single global stopwatch budget
function Invoke-BoundedInnerProcess([System.Diagnostics.ProcessStartInfo]$psi, [int]$totalBudgetMs) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $proc = [System.Diagnostics.Process]::Start($psi)
    if ($null -eq $proc) {
        [Console]::Error.WriteLine("Wrapper Error: Failed to start inner process.")
        exit 97
    }

    try {
        $outTask = $proc.StandardOutput.ReadToEndAsync()
        $errTask = $proc.StandardError.ReadToEndAsync()

        $remExitMs = $totalBudgetMs - [int]$sw.ElapsedMilliseconds
        $overrunOccurred = $false
        $overrunReason = ""

        if ($remExitMs -le 0 -or -not $proc.WaitForExit($remExitMs)) {
            $overrunOccurred = $true
            $overrunReason = "process execution timeout ($totalBudgetMs ms)"
        } else {
            $remDrainMs = $totalBudgetMs - [int]$sw.ElapsedMilliseconds
            if ($remDrainMs -le 0) {
                $overrunOccurred = $true
                $overrunReason = "stream drain budget exhaustion"
            } else {
                $streamsTask = [System.Threading.Tasks.Task]::WhenAll($outTask, $errTask)
                if (-not $streamsTask.Wait($remDrainMs)) {
                    $overrunOccurred = $true
                    $overrunReason = "stdout/stderr stream drain timeout ($remDrainMs ms)"
                }
            }
        }

        if ($overrunOccurred) {
            Invoke-InnerVerifiedTreeKill -proc $proc -tkBudgetMs 3000 -tkReserveMs 750
            [Console]::Error.WriteLine("Wrapper Error: Inner process timed out due to $overrunReason (process tree verified terminated).")
            exit 124
        }

        return @{
            ExitCode = $proc.ExitCode
            Stdout = $outTask.Result
            Stderr = $errTask.Result
        }
    } finally {
        if ($null -ne $proc) {
            $isLive = $false
            try { $isLive = -not $proc.HasExited } catch { $isLive = $false }
            if ($isLive) {
                Invoke-InnerVerifiedTreeKill -proc $proc -tkBudgetMs 3000 -tkReserveMs 750
            }
            $proc.Dispose()
        }
    }
}

# 4. Build and Execute Target Inner Process with Mandatory -P $ExpectedInnerProfile
$targetPsi = [System.Diagnostics.ProcessStartInfo]::new()
$targetPsi.FileName = $InnerLauncherExecutable
$targetPsi.WorkingDirectory = $CheckoutDir
$targetPsi.UseShellExecute = $false
$targetPsi.RedirectStandardOutput = $true
$targetPsi.RedirectStandardError = $true
$targetPsi.RedirectStandardInput = $true
$targetPsi.Environment["CODEX_HOME"] = $InnerCodexHome

if (-not [string]::IsNullOrWhiteSpace($InnerScriptEntry)) {
    $targetPsi.ArgumentList.Add($InnerScriptEntry)
}
$targetPsi.ArgumentList.Add("sandbox")
$targetPsi.ArgumentList.Add("-P")
$targetPsi.ArgumentList.Add($ExpectedInnerProfile)
$targetPsi.ArgumentList.Add("-C")
$targetPsi.ArgumentList.Add($CheckoutDir)
$targetPsi.ArgumentList.Add("--")
$targetPsi.ArgumentList.Add((Get-Command "pwsh.exe" -ErrorAction Stop).Source)
$targetPsi.ArgumentList.Add("-NoProfile")
$targetPsi.ArgumentList.Add("-Command")
$targetPsi.ArgumentList.Add($TargetPayloadScript)

$res = Invoke-BoundedInnerProcess -psi $targetPsi -totalBudgetMs 15000
if (-not [string]::IsNullOrEmpty($res.Stdout)) { [Console]::Out.Write($res.Stdout) }
if (-not [string]::IsNullOrEmpty($res.Stderr)) { [Console]::Error.Write($res.Stderr) }
exit $res.ExitCode
'@

    # Separately parse-audit generated wrapper script payload before writing
    $wTokens = $null
    $wErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseInput($wrapperSource, [ref]$wTokens, [ref]$wErrors)
    if ($wErrors -and $wErrors.Count -gt 0) {
        throw "Fail-closed: Generated wrapper script failed parser zero-error audit: $($wErrors -join '; ')"
    }

    $wrFs = [System.IO.FileStream]::new($wrapperScriptPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $b = [System.Text.Encoding]::UTF8.GetBytes($wrapperSource)
        $wrFs.Write($b, 0, $b.Length)
    } finally { $wrFs.Dispose() }

    # 6. ExpectedInnerProfile Deterministic Differential Behavioral Verification (Explicit -P in Both Runs)
    Write-Output "Executing ExpectedInnerProfile Deterministic Differential Behavioral Probes..."
    $probeSentinelPath = (Join-Path $valCheckout "scratch/inner-probe-sentinel.txt")
    $psFs = [System.IO.FileStream]::new($probeSentinelPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $b = [System.Text.Encoding]::UTF8.GetBytes("INITIAL_PROBE_CONTENT`n")
        $psFs.Write($b, 0, $b.Length)
    } finally { $psFs.Dispose() }
    $probeBaselineHash = (Get-FileHash -LiteralPath $probeSentinelPath -Algorithm SHA256).Hash

    # Run A Inner Probe Script: Bounded exception unwrapping emitting EXACTLY ONE structured JSON record, then exit 13
    $innerProbeScriptA = @"
try {
    Add-Content -LiteralPath '$($probeSentinelPath.Replace("'", "''"))' -Value 'MUTATED_BY_INNER_PROFILE' -ErrorAction Stop
    `$resultObj = [ordered]@{
        status = 'MUTATED'
        target = '$($probeSentinelPath.Replace("'", "''"))'
        exitCode = 0
    }
    [Console]::Out.WriteLine((`$resultObj | ConvertTo-Json -Compress))
    exit 0
} catch {
    `$currEx = `$_.Exception
    `$depth = 0
    while (`$null -ne `$currEx -and `$depth -lt 10) {
        if (`$currEx -is [System.AggregateException] -and `$currEx.InnerExceptions.Count -gt 0) {
            `$currEx = `$currEx.InnerExceptions[0]
        } elseif (`$null -ne `$currEx.InnerException) {
            `$currEx = `$currEx.InnerException
        } else {
            break
        }
        `$depth++
    }

    `$isAccessDenied = `$false
    `$hresult = 0
    if (`$currEx -is [System.UnauthorizedAccessException]) {
        `$isAccessDenied = `$true
        `$hresult = `$currEx.HResult
    } elseif (`$currEx -is [System.IO.IOException]) {
        `$hr = `$currEx.HResult
        if (`$hr -eq -2147024891 -or (`$hr -band 0xFFFF) -eq 5) {
            `$isAccessDenied = `$true
            `$hresult = `$hr
        }
    }

    `$errObj = [ordered]@{
        status = if (`$isAccessDenied) { 'DENIED' } else { 'FAILED' }
        target = '$($probeSentinelPath.Replace("'", "''"))'
        errorType = `$currEx.GetType().FullName
        hresult = `$hresult
        isTerminatingDenial = `$isAccessDenied
    }
    [Console]::Out.WriteLine((`$errObj | ConvertTo-Json -Compress))
    exit 13
}
"@
    $null = [System.Management.Automation.Language.Parser]::ParseInput($innerProbeScriptA, [ref]$wTokens, [ref]$wErrors)
    if ($wErrors -and $wErrors.Count -gt 0) { throw "Fail-closed: Inner probe script A failed parse audit: $($wErrors -join '; ')" }

    # Run A: With built-in -P :read-only -> built-in read-only profile is explicitly enforced; write is denied
    $runAArgs = @(
        $pwshPath, "-NoProfile", "-File", $wrapperScriptPath,
        "-InnerLauncherExecutable", $launcher.ExecutablePath,
        "-InnerScriptEntry", $(if ($launcher.ScriptEntry) { $launcher.ScriptEntry } else { "" }),
        "-InnerCodexHome", $innerCodexHome,
        "-OuterCodexHome", $outerCodexHome,
        "-CheckoutDir", $valCheckout,
        "-TargetPayloadScript", $innerProbeScriptA,
        "-ExpectedInnerProfile", ":read-only"
    )
    $outerRunAArgv = @("sandbox", "--include-managed-config", "-P", "orchestrator-governed", "-C", $valCheckout, "--") + $runAArgs
    $resRunA = & $launcherScript -Argv $outerRunAArgv -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 30

    if ($resRunA.ExitCode -ne 13) {
        throw "Inner Behavioral Differential Probe A Failed: Expected exact exit code 13, received $($resRunA.ExitCode). Stderr: $($resRunA.Stderr), Stdout: $($resRunA.Stdout)"
    }

    $rawLinesA = $resRunA.Stdout.Trim() -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($rawLinesA.Count -ne 1) {
        throw "Inner Behavioral Differential Probe A Failed: Expected exactly one output JSON line, found $($rawLinesA.Count): $($resRunA.Stdout)"
    }

    $jsonObjA = $null
    try {
        $jsonObjA = $rawLinesA[0] | ConvertFrom-Json
    } catch {
        throw "Inner Behavioral Differential Probe A Failed: Output line is not valid JSON: $($rawLinesA[0])"
    }

    if ($jsonObjA.target -ne $probeSentinelPath) {
        throw "Inner Behavioral Differential Probe A Failed: JSON target mismatch (Expected: $probeSentinelPath, Received: $($jsonObjA.target))."
    }
    if ($jsonObjA.status -ne 'DENIED' -or -not $jsonObjA.isTerminatingDenial) {
        throw "Inner Behavioral Differential Probe A Failed: Status was '$($jsonObjA.status)' (isTerminatingDenial=$($jsonObjA.isTerminatingDenial)), expected DENIED."
    }
    $allowedTypes = @("System.UnauthorizedAccessException", "System.IO.IOException")
    if (-not ($allowedTypes -contains $jsonObjA.errorType)) {
        throw "Inner Behavioral Differential Probe A Failed: Error type '$($jsonObjA.errorType)' not allowed. Must be UnauthorizedAccessException or IOException."
    }
    if ($jsonObjA.errorType -eq "System.IO.IOException" -and $jsonObjA.hresult -ne -2147024891 -and ($jsonObjA.hresult -band 0xFFFF) -ne 5) {
        throw "Inner Behavioral Differential Probe A Failed: IOException did not have exact access-denied code (HRESULT: $($jsonObjA.hresult))."
    }

    $hashAfterA = (Get-FileHash -LiteralPath $probeSentinelPath -Algorithm SHA256).Hash
    if ($hashAfterA -ne $probeBaselineHash) {
        throw "Inner Behavioral Differential Probe A Failed: Sentinel hash mutated despite denial!"
    }
    Write-Output "Behavioral Probe A Succeeded: Built-in profile -P :read-only denied write with verified exit 13, structured JSON, and hash invariance."

    # Run B: With -P snapshot-isolated -> explicit profile selection grants workspace-write permissions
    $innerProbeScriptB = @"
try {
    Add-Content -LiteralPath '$($probeSentinelPath.Replace("'", "''"))' -Value 'MUTATED_BY_INNER_PROFILE' -ErrorAction Stop
    Write-Output 'PROBE_MUTATED'
    exit 0
} catch {
    Write-Output 'PROBE_DENIED'
    exit 13
}
"@
    $runBArgs = @(
        $pwshPath, "-NoProfile", "-File", $wrapperScriptPath,
        "-InnerLauncherExecutable", $launcher.ExecutablePath,
        "-InnerScriptEntry", $(if ($launcher.ScriptEntry) { $launcher.ScriptEntry } else { "" }),
        "-InnerCodexHome", $innerCodexHome,
        "-OuterCodexHome", $outerCodexHome,
        "-CheckoutDir", $valCheckout,
        "-TargetPayloadScript", $innerProbeScriptB,
        "-ExpectedInnerProfile", "snapshot-isolated"
    )
    $outerRunBArgv = @("sandbox", "--include-managed-config", "-P", "orchestrator-governed", "-C", $valCheckout, "--") + $runBArgs
    $resRunB = & $launcherScript -Argv $outerRunBArgv -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 30

    $contentAfterB = Get-Content -Raw -LiteralPath $probeSentinelPath
    if ($resRunB.ExitCode -ne 0 -or $resRunB.Stdout -notmatch 'PROBE_MUTATED' -or $contentAfterB -notmatch 'MUTATED_BY_INNER_PROFILE') {
        throw "Inner Behavioral Differential Probe B Failed: Inner profile -P snapshot-isolated failed to permit write: ExitCode=$($resRunB.ExitCode), Out=$($resRunB.Stdout), Err=$($resRunB.Stderr)"
    }
    Write-Output "Behavioral Probe B Succeeded: Explicit profile -P snapshot-isolated successfully applied and permitted write."

    # Clean probe sentinel safely
    Remove-Item -LiteralPath $probeSentinelPath -Force -ErrorAction Stop

    # 7. Positive Control: True Outer-to-Inner Chain Mutates Unprotected Sentinel
    Write-Output "Running True Outer-to-Inner Positive Control Mutation..."
    $posProbeScript = @"
try {
    Add-Content -LiteralPath '$($positiveSentinel.Replace("'", "''"))' -Value 'MUTATED_BY_TRUE_NESTED_CHAIN' -ErrorAction Stop
    `$resultObj = [ordered]@{
        status = 'MUTATED'
        target = '$($positiveSentinel.Replace("'", "''"))'
        exitCode = 0
    }
    [Console]::Out.WriteLine((`$resultObj | ConvertTo-Json -Compress))
    exit 0
} catch {
    `$errObj = [ordered]@{
        status = 'ERROR'
        target = '$($positiveSentinel.Replace("'", "''"))'
        errorType = `$_.Exception.GetType().FullName
        errorMessage = `$_.Exception.Message
    }
    [Console]::Out.WriteLine((`$errObj | ConvertTo-Json -Compress))
    exit 1
}
"@
    $null = [System.Management.Automation.Language.Parser]::ParseInput($posProbeScript, [ref]$wTokens, [ref]$wErrors)
    if ($wErrors -and $wErrors.Count -gt 0) { throw "Fail-closed: Positive control script failed parse audit: $($wErrors -join '; ')" }

    $wrapperArgs = @(
        $pwshPath, "-NoProfile", "-File", $wrapperScriptPath,
        "-InnerLauncherExecutable", $launcher.ExecutablePath,
        "-InnerScriptEntry", $(if ($launcher.ScriptEntry) { $launcher.ScriptEntry } else { "" }),
        "-InnerCodexHome", $innerCodexHome,
        "-OuterCodexHome", $outerCodexHome,
        "-CheckoutDir", $valCheckout,
        "-TargetPayloadScript", $posProbeScript,
        "-ExpectedInnerProfile", "snapshot-isolated"
    )

    $outerPosArgv = @("sandbox", "--include-managed-config", "-P", "orchestrator-governed", "-C", $valCheckout, "--") + $wrapperArgs
    $posRes = & $launcherScript -Argv $outerPosArgv -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 30

    if ($posRes.TimedOut) {
        throw "Positive Control Failed: Nested probe timed out."
    }

    $posJson = $null
    try {
        $posJson = $posRes.Stdout.Trim() | ConvertFrom-Json
    } catch { }

    if ($posRes.ExitCode -ne 0 -or -not $posJson -or $posJson.status -ne 'MUTATED' -or (Get-Content -Raw -LiteralPath $positiveSentinel) -notmatch "MUTATED_BY_TRUE_NESTED_CHAIN") {
        throw "Positive Control Failed: True nested chain unable to write to unprotected sentinel. ExitCode=$($posRes.ExitCode), Output=$($posRes.Stdout), Stderr=$($posRes.Stderr)"
    }
    Write-Output "Positive Control Succeeded: True nested chain mutates unprotected sentinel with verified exit 0 and structured JSON."

    # 8. Axis A: Filesystem Hard-Fence Parity Gate via True Outer-to-Inner Chain
    Write-Output "Evaluating Axis A: Exact Path Write Denial on All 5 Protected Targets via True Outer-to-Inner Chain..."
    
    $evaluatedTargets = [System.Collections.Generic.List[string]]::new()

    foreach ($rel in $expectedProtectedKeys) {
        $targetFile = (Join-Path $valCheckout $rel)
        $evaluatedTargets.Add($rel)

        # Inner attack probe: strictly no message regex; inspects exact CLR type and Win32/HRESULT codes
        $mutateProbeScript = @"
try {
    Add-Content -LiteralPath '$($targetFile.Replace("'", "''"))' -Value 'TAMPER_EVIDENCE' -ErrorAction Stop
    `$resultObj = [ordered]@{
        status = 'MUTATED'
        target = '$($rel.Replace("'", "''"))'
        exitCode = 0
    }
    [Console]::Out.WriteLine((`$resultObj | ConvertTo-Json -Compress))
    exit 0
} catch {
    `$currEx = `$_.Exception
    `$depth = 0
    while (`$null -ne `$currEx -and `$depth -lt 10) {
        if (`$currEx -is [System.AggregateException] -and `$currEx.InnerExceptions.Count -gt 0) {
            `$currEx = `$currEx.InnerExceptions[0]
        } elseif (`$null -ne `$currEx.InnerException) {
            `$currEx = `$currEx.InnerException
        } else {
            break
        }
        `$depth++
    }

    `$isAccessDenied = `$false
    `$hresult = 0
    if (`$currEx -is [System.UnauthorizedAccessException]) {
        `$isAccessDenied = `$true
        `$hresult = `$currEx.HResult
    } elseif (`$currEx -is [System.IO.IOException]) {
        `$hr = `$currEx.HResult
        if (`$hr -eq -2147024891 -or (`$hr -band 0xFFFF) -eq 5) {
            `$isAccessDenied = `$true
            `$hresult = `$hr
        }
    }

    `$errObj = [ordered]@{
        status = if (`$isAccessDenied) { 'DENIED' } else { 'FAILED' }
        target = '$($rel.Replace("'", "''"))'
        errorType = `$currEx.GetType().FullName
        hresult = `$hresult
        isTerminatingDenial = `$isAccessDenied
    }
    [Console]::Out.WriteLine((`$errObj | ConvertTo-Json -Compress))
    exit 13
}
"@
        $null = [System.Management.Automation.Language.Parser]::ParseInput($mutateProbeScript, [ref]$wTokens, [ref]$wErrors)
        if ($wErrors -and $wErrors.Count -gt 0) { throw "Fail-closed: Mutate probe script failed parse audit: $($wErrors -join '; ')" }

        $attackWrapperArgs = @(
            $pwshPath, "-NoProfile", "-File", $wrapperScriptPath,
            "-InnerLauncherExecutable", $launcher.ExecutablePath,
            "-InnerScriptEntry", $(if ($launcher.ScriptEntry) { $launcher.ScriptEntry } else { "" }),
            "-InnerCodexHome", $innerCodexHome,
            "-OuterCodexHome", $outerCodexHome,
            "-CheckoutDir", $valCheckout,
            "-TargetPayloadScript", $mutateProbeScript,
            "-ExpectedInnerProfile", "snapshot-isolated"
        )

        $outerAttackArgv = @("sandbox", "--include-managed-config", "-P", "orchestrator-governed", "-C", $valCheckout, "--") + $attackWrapperArgs
        $attackRes = & $launcherScript -Argv $outerAttackArgv -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 30

        if ($attackRes.ExitCode -ne 13) {
            throw "Axis A Inconclusive: Expected exact exit code 13 on '$rel', received $($attackRes.ExitCode). Stderr: $($attackRes.Stderr), Stdout: $($attackRes.Stdout)"
        }

        $rawLines = $attackRes.Stdout.Trim() -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        if ($rawLines.Count -ne 1) {
            throw "Axis A Inconclusive: Expected exactly one output JSON line on '$rel', found $($rawLines.Count): $($attackRes.Stdout)"
        }

        $jsonObj = $null
        try {
            $jsonObj = $rawLines[0] | ConvertFrom-Json
        } catch {
            throw "Axis A Inconclusive: Probe output did not contain valid structured JSON on '$rel': $($rawLines[0])"
        }

        if ($jsonObj.target -ne $rel) {
            throw "Axis A Inconclusive: JSON target mismatch (Received: '$($jsonObj.target)', Expected: '$rel')."
        }

        if ($jsonObj.status -ne 'DENIED' -or -not $jsonObj.isTerminatingDenial) {
            throw "Axis A Rejected: Received unaccepted status '$($jsonObj.status)' with errorType '$($jsonObj.errorType)' on '$rel'."
        }

        if (-not ($allowedTypes -contains $jsonObj.errorType)) {
            throw "Axis A Rejected: Terminal exception type was '$($jsonObj.errorType)' on '$rel'. Must be UnauthorizedAccessException or IOException."
        }
        if ($jsonObj.errorType -eq "System.IO.IOException" -and $jsonObj.hresult -ne -2147024891 -and ($jsonObj.hresult -band 0xFFFF) -ne 5) {
            throw "Axis A Rejected: IOException on '$rel' did not have exact access-denied HRESULT/Win32 code (HRESULT: $($jsonObj.hresult))."
        }

        $currentHash = (Get-FileHash -LiteralPath $targetFile -Algorithm SHA256).Hash
        if ($currentHash -ne $baselineHashes[$rel]) {
            throw "Axis A Critical Failure: Hash for '$rel' mutated despite denial! Baseline: $($baselineHashes[$rel]), Current: $currentHash"
        }
    }

    if ($evaluatedTargets.Count -ne 5) {
        throw "Axis A Failure: Exactly 5 targets were required to be evaluated; evaluated $($evaluatedTargets.Count)."
    }
    Write-Output "Axis A: PASS (All 5 protected paths proven immutable under true outer-to-inner wrapper write attempts with exact exit 13 and non-regex CLR/Win32 error evidence)."

    # 9. Managed Profile Exclusion 2-Run Differential Sentinel Gate
    Write-Output "Executing Managed Profile Exclusion 2-Run Differential Sentinel Gate..."
    $sentinelRun1Path = (Join-Path $valCheckout "scratch/managed-exclusion-sentinel-$runGuid.txt")
    $expectedSentinelRun1Content = "MANAGED_EXCLUSION_RUN1_PAYLOAD_$runGuid"

    $run1Payload = @"
Set-Content -LiteralPath '$($sentinelRun1Path.Replace("'", "''"))' -Value '$expectedSentinelRun1Content' -Encoding UTF8 -ErrorAction Stop
Write-Output 'DIFF_RUN1_OK'
exit 0
"@
    $null = [System.Management.Automation.Language.Parser]::ParseInput($run1Payload, [ref]$wTokens, [ref]$wErrors)
    if ($wErrors -and $wErrors.Count -gt 0) { throw "Fail-closed: Run 1 payload failed parse audit: $($wErrors -join '; ')" }

    # Run 1: Without --include-managed-config (succeeds locally via outer home's snapshot-isolated profile)
    $run1Res = & $launcherScript -Argv @("sandbox", "-P", "snapshot-isolated", "-C", $valCheckout, "--", $pwshPath, "-NoProfile", "-Command", $run1Payload) `
        -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 15

    if ($run1Res.ExitCode -ne 0 -or $run1Res.Stdout -notmatch "DIFF_RUN1_OK") {
        throw "Managed Exclusion Run 1 Failed: Local snapshot-isolated profile failed to execute without managed config: ExitCode=$($run1Res.ExitCode), Stderr=$($run1Res.Stderr)"
    }
    if (-not (Test-Path -LiteralPath $sentinelRun1Path -PathType Leaf)) {
        throw "Managed Exclusion Run 1 Failed: Sentinel file was not created by unmanaged snapshot-isolated run."
    }
    $run1Content = (Get-Content -Raw -LiteralPath $sentinelRun1Path -Encoding UTF8).Trim()
    if ($run1Content -ne $expectedSentinelRun1Content) {
        throw "Managed Exclusion Run 1 Failed: Sentinel content mismatch! Expected: '$expectedSentinelRun1Content', Found: '$run1Content'."
    }
    Remove-Item -LiteralPath $sentinelRun1Path -Force -ErrorAction Stop
    Write-Output "Managed Exclusion Run 1 Succeeded: Unmanaged snapshot-isolated executed write and verified sentinel."

    # Run 2: With --include-managed-config (fails closed before payload because managed requirements.toml excludes snapshot-isolated)
    $run2Payload = @"
Set-Content -LiteralPath '$($sentinelRun1Path.Replace("'", "''"))' -Value 'RUN2_SHOULD_NEVER_WRITE' -Encoding UTF8 -ErrorAction Stop
Write-Output 'RUN2_BREACH'
exit 0
"@
    $run2Res = & $launcherScript -Argv @("sandbox", "--include-managed-config", "-P", "snapshot-isolated", "-C", $valCheckout, "--", $pwshPath, "-NoProfile", "-Command", $run2Payload) `
        -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 15

    if ($run2Res.ExitCode -eq 0) {
        throw "Managed Exclusion Run 2 Violation: snapshot-isolated succeeded despite exclusion in managed policy."
    }
    if (Test-Path -LiteralPath $sentinelRun1Path) {
        throw "Managed Exclusion Run 2 Violation: Sentinel file was created or mutated during rejected Run 2!"
    }

    $exclusionErr = $run2Res.Stderr + "`n" + $run2Res.Stdout
    if ($exclusionErr -notmatch "(?i)(profile.*not allowed|allowed_permission_profiles|disallowed profile|policy violation)") {
        throw "Managed Exclusion Run 2 Inconclusive: Error did not match expected managed policy profile exclusion signature: $exclusionErr"
    }
    Write-Output "Managed Profile Exclusion: PASS (Snapshot-isolated verified excluded by managed policy before payload; sentinel remained absent)."

    # 10. Axis B: Elevated Windows Network & User Isolation Diagnostics
    Write-Output "Evaluating Axis B: Elevated Windows Network & User Isolation Diagnostics..."
    
    # Outside-Network Positive Control: Requires successful bounded HTTPS request and response; NO TCP CanWrite fallback
    $outsideHttpsConfirmed = $false
    try {
        $handler = [System.Net.Http.SocketsHttpHandler]::new()
        $handler.ConnectTimeout = [System.TimeSpan]::FromSeconds(3)
        $client = [System.Net.Http.HttpClient]::new($handler)
        $client.Timeout = [System.TimeSpan]::FromSeconds(4)
        try {
            $response = $client.GetAsync("https://www.example.com").GetAwaiter().GetResult()
            if ($response.IsSuccessStatusCode) {
                $outsideHttpsConfirmed = $true
            }
        } finally {
            $client.Dispose()
            $handler.Dispose()
        }
    } catch {
        $outsideHttpsConfirmed = $false
    }

    if ($outsideHttpsConfirmed) {
        Write-Output "Axis B Positive Control: Outside HTTPS connection and response confirmed in unconfined baseline."
    } else {
        Write-Output "Axis B Positive Control: Outside HTTPS connection failed in baseline; host offline."
    }

    # Inside-Sandbox Probe: Query current Windows Identity
    $diagCmd = "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"
    $diagRes = & $launcherScript -Argv @("sandbox", "--include-managed-config", "-P", "orchestrator-governed", "-C", $valCheckout, "--", $pwshPath, "-NoProfile", "-Command", $diagCmd) `
        -EnvironmentMode IsolatedSandbox -CodexHome $outerCodexHome -TimeoutSeconds 10

    $insideExitSuccess = (-not $diagRes.TimedOut -and $diagRes.ExitCode -eq 0)
    $actualPrincipal = $diagRes.Stdout.Trim()

    # Axis B Certification Gate: Strict evaluation against supplied allowlist and evidence reference
    $allowlistProvided = ($null -ne $AdminApprovedPrincipalAllowlist -and $AdminApprovedPrincipalAllowlist.Length -gt 0)
    $evidenceProvided = (-not [string]::IsNullOrWhiteSpace($PrincipalEvidenceReference))
    $principalMatchesAllowlist = $false

    if ($allowlistProvided) {
        $allowlistSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($p in $AdminApprovedPrincipalAllowlist) { [void]$allowlistSet.Add($p.Trim()) }
        $principalMatchesAllowlist = $allowlistSet.Contains($actualPrincipal)
    }

    if ($allowlistProvided -and $evidenceProvided -and $outsideHttpsConfirmed -and $insideExitSuccess -and $principalMatchesAllowlist) {
        Write-Output "Axis B: PASS (Elevated principal '$actualPrincipal' verified against administrator allowlist with evidence reference '$PrincipalEvidenceReference')."
    } else {
        $reasons = @()
        if (-not $allowlistProvided) { $reasons += "AdminApprovedPrincipalAllowlist not supplied" }
        if (-not $evidenceProvided) { $reasons += "PrincipalEvidenceReference not supplied" }
        if (-not $outsideHttpsConfirmed) { $reasons += "Outside HTTPS positive control failed" }
        if (-not $insideExitSuccess) { $reasons += "Inside diagnostic command timed out or failed" }
        if ($allowlistProvided -and -not $principalMatchesAllowlist) { $reasons += "Inside principal '$actualPrincipal' not present in supplied allowlist" }
        Write-Output "Axis B: NOT VERIFIED ($($reasons -join '; ')). Generic errors and heuristic regex matching rejected as proof."
    }

} catch {
    $testFailure = $_
} finally {
    # 11. Hardened Recursive Cleanup with Explicit Refusal on Validation Failure
    Write-Output "Executing Hardened Cleanup for Validation Checkout: $valCheckout"
    
    $fullVal = [System.IO.Path]::GetFullPath($valCheckout)
    $canDeleteCheckout = $true

    if (-not $fullVal.StartsWith($valCheckoutsBase, [System.StringComparison]::OrdinalIgnoreCase) -or
        $fullVal -eq $valCheckoutsBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
        $cleanupErrMsg = "Cleanup Security Violation: Target escapes validation-checkouts root: $($fullVal). Refusing recursive delete."
        $canDeleteCheckout = $false
        throw $cleanupErrMsg
    }

    if (-not (Test-Path -LiteralPath $ownerMarkerPath -PathType Leaf)) {
        $cleanupErrMsg = "Cleanup Failure: Ownership marker missing at $ownerMarkerPath. Refusing to delete unowned directory."
        $canDeleteCheckout = $false
        throw $cleanupErrMsg
    }
    $markerContent = Get-Content -Raw -LiteralPath $ownerMarkerPath | ConvertFrom-Json
    if ($markerContent.runGuid -ne $runGuid) {
        $cleanupErrMsg = "Cleanup Failure: Ownership marker mismatch (Found: $($markerContent.runGuid), Expected: $runGuid). Refusing recursive delete."
        $canDeleteCheckout = $false
        throw $cleanupErrMsg
    }

    $valDirInfo = [System.IO.DirectoryInfo]::new($fullVal)
    if ($valDirInfo.Exists -and ($valDirInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        $cleanupErrMsg = "Cleanup Security Violation: Checkout directory is a reparse point: $($fullVal). Refusing recursive delete."
        $canDeleteCheckout = $false
        throw $cleanupErrMsg
    }

    $chkAnc = $valDirInfo.Parent
    while ($chkAnc -and $chkAnc.FullName.Length -ge $normalizedRepoRoot.Length) {
        if ($chkAnc.Exists -and ($chkAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $cleanupErrMsg = "Cleanup Security Violation: Reparse point detected in checkout ancestor: $($chkAnc.FullName). Refusing recursive delete."
            $canDeleteCheckout = $false
            throw $cleanupErrMsg
        }
        $chkAnc = $chkAnc.Parent
    }

    if ($canDeleteCheckout) {
        try {
            Remove-Item -LiteralPath $fullVal -Recurse -Force -ErrorAction Stop
            if (Test-Path -LiteralPath $fullVal) {
                throw "Directory still exists after Remove-Item."
            }
            $cleanupSucceeded = $true
            Write-Output "Cleanup Succeeded: Deleted owned checkout directory $($fullVal)."
        } catch {
            $cleanupErrMsg = "Cleanup Failure: Failed to remove validation checkout $($fullVal): $_"
            if ($null -ne $testFailure) {
                throw "$($testFailure.Exception.Message) | $cleanupErrMsg"
            } else {
                throw $cleanupErrMsg
            }
        }
    }

    if ($null -ne $testFailure) { throw $testFailure }
}
```


---

## Hardened Non-Recursive Rollback (`tests/codex-parity/rollback.ps1`)

Recursive deletion (`-Recurse`) is strictly forbidden to protect user-owned and untracked files.

### 1. Creation Manifest with Explicit Installation ID
Every created path is recorded with its install-time SHA-256 hash in `runtime/audit/created-files-<InstallationId>.json`. Rollback requires `-InstallationId <guid>` and never selects "newest" automatically. External backup paths (`runtime/audit/$InstallationId/config.toml.pre-elevated.bak`) and expected hashes are also recorded here.

### 2. Ancestor Reparse Point Check & Containment
Before touching any file, rollback:
1. Normalizes repository root with a trailing separator (`\`).
2. Asserts ordinal ignore-case path containment (`StartsWith`).
3. Rejects exact root targeting.
4. **Checks every existing ancestor directory** between repository root and target path for `ReparsePoint` file attributes (junctions, symlinks). If any ancestor is a junction or symlink, rollback terminates immediately.
5. Verifies that the current SHA-256 hash matches the install-time recorded hash. If the user modified the file post-install, it is **retained** and reported.
6. Removes empty directories individually from deepest to shallowest.

---

## Complete Role Definitions & 41 Skills Inventory

### 1. 19 Role Definitions (`.codex/agents/*.toml`)

| Role Name | Category | Sandbox Mode | Model | Reasoning Effort | Authorized Routing Dispatches (`routing_edges`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `orchestrator` | Root Lead | `read-only` | `gpt-5.6-sol` | `high` | `planner`, `researcher`, `scribe`, `t1-engineer`, `t2-engineer`, `t3-engineering-advisor`, `engineering-lead`, `verifier`, `browser-validator`, `codex-judge-runner` |
| `planner` | Planning Lead | `read-only` | `gpt-5.6-sol` | `high` | `researcher`, `scribe`, `design-generalist`, `design-director`, `design-reviewer`, `design-prototyper` |
| `design-director` | Design Lead | `read-only` | `gpt-5.6-sol` | `high` | `ux-architect`, `visual-system-designer`, `motion-designer`, `asset-art-director` |
| `researcher` | Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `scribe` | Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* (Writes materialized via `trusted-writer.ps1`) |
| `t1-engineer` | Engineering | `workspace-write` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `t2-engineer` | Engineering | `workspace-write` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `t3-engineering-advisor`| Specialist | `read-only` | `gpt-5.6-sol` | `high` | *(None - Leaf)* |
| `engineering-lead` | Specialist | `read-only` | `gpt-5.6-sol` | `high` | *(None - Leaf)* |
| `verifier` | Verification | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `browser-validator` | Verification | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `codex-judge-runner` | Critic | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `ux-architect` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `visual-system-designer`| Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `motion-designer` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `asset-art-director` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `design-generalist` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `design-reviewer` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* |
| `design-prototyper` | Design Specialist | `read-only` | `gpt-5.6-sol` | `medium` | *(None - Leaf)* (Writes materialized via `trusted-writer.ps1`) |

### 2. Complete 41-Row Adaptation/Classification/Semantic-Diff Ledger (Exact 29 Direct-Sync / 12 Adapted)

Enforces exact source/destination set equality: `{.claude/skills/*/SKILL.md} == {.agents/skills/*/SKILL.md}` with exact arithmetic (29 Direct-Sync + 12 Adapted = 41):

| # | Skill Name | Source Path | Destination Path | Classification | Semantic Diff & Adaptation Rationale |
|---|---|---|---|---|---|
| 1 | `browser-validator-core` | `.claude/skills/browser-validator-core/SKILL.md` | `.agents/skills/browser-validator-core/SKILL.md` | Direct-Sync | Vendor-neutral browser journey validation protocol. Synchronized verbatim. |
| 2 | `build` | `.claude/skills/build/SKILL.md` | `.agents/skills/build/SKILL.md` | Adapted | Replaces Claude-specific `/build` and subagent call stack references with Codex CLI invocation rules and `orchestrate-role.ps1` dispatch state machine; routes critic loop to `invoke-claude-judge.ps1`. |
| 3 | `claude-operations` | `.claude/skills/claude-operations/SKILL.md` | `.agents/skills/claude-operations/SKILL.md` | Adapted | Governs dual-harness operation from Codex; documents how to bridge to Claude Code primitives or delegate cross-harness requests safely without mutating foreign state. |
| 4 | `cross-vendor-judging` | `.claude/skills/cross-vendor-judging/SKILL.md` | `.agents/skills/cross-vendor-judging/SKILL.md` | Adapted | Under Codex, routes judgment to Claude critic via `invoke-claude-judge.ps1` (`agy`) rather than Codex `invoke-codex-judge.ps1`; preserves checkpoints (`PLAN_DUCK`, `CODE_REVIEW`, etc.) and blocking thresholds. |
| 5 | `design-core` | `.claude/skills/design-core/SKILL.md` | `.agents/skills/design-core/SKILL.md` | Direct-Sync | Visual design principles, typography, spacing, and accessibility criteria. Synchronized verbatim. |
| 6 | `design-direction` | `.claude/skills/design-direction/SKILL.md` | `.agents/skills/design-direction/SKILL.md` | Direct-Sync | Design review governance, brand alignment, and design system contracts. Synchronized verbatim. |
| 7 | `design-prototype` | `.claude/skills/design-prototype/SKILL.md` | `.agents/skills/design-prototype/SKILL.md` | Adapted | Adapts prototype artifact generation to route file materialization through `trusted-writer.ps1` targeting `.design/prototypes/<slug>/*` since `design-prototyper` operates in a read-only sandbox under Codex. |
| 8 | `design-review` | `.claude/skills/design-review/SKILL.md` | `.agents/skills/design-review/SKILL.md` | Direct-Sync | Review rubrics for UI/UX inspection. Synchronized verbatim. |
| 9 | `engineering-fleet` | `.claude/skills/engineering-fleet/SKILL.md` | `.agents/skills/engineering-fleet/SKILL.md` | Adapted | Maps role dispatch contracts to `.codex/agents/*.toml` roles and `orchestrate-role.ps1` execution envelopes instead of Claude Agent tool calls. |
| 10 | `motion-and-assets` | `.claude/skills/motion-and-assets/SKILL.md` | `.agents/skills/motion-and-assets/SKILL.md` | Direct-Sync | Guidelines for motion design and asset optimization. Synchronized verbatim. |
| 11 | `planner-core` | `.claude/skills/planner-core/SKILL.md` | `.agents/skills/planner-core/SKILL.md` | Adapted | Adapts planning lifecycle to dispatch nested Researcher and Scribe via `orchestrate-role.ps1` envelopes, with plan files committed via `trusted-writer.ps1`. |
| 12 | `planner-repository-analysis` | `.claude/skills/planner-repository-analysis/SKILL.md` | `.agents/skills/planner-repository-analysis/SKILL.md` | Direct-Sync | Static repository structural analysis patterns. Synchronized verbatim. |
| 13 | `planner-risk-validation` | `.claude/skills/planner-risk-validation/SKILL.md` | `.agents/skills/planner-risk-validation/SKILL.md` | Direct-Sync | Risk tier classification rubrics. Synchronized verbatim. |
| 14 | `planner-specification-decomposition`| `.claude/skills/planner-specification-decomposition/SKILL.md` | `.agents/skills/planner-specification-decomposition/SKILL.md` | Direct-Sync | Spec parsing and milestone breakdown contracts. Synchronized verbatim. |
| 15 | `research-architecture` | `.claude/skills/research-architecture/SKILL.md` | `.agents/skills/research-architecture/SKILL.md` | Direct-Sync | Architecture research synthesis protocols. Synchronized verbatim. |
| 16 | `research-browser-ui-safety` | `.claude/skills/research-browser-ui-safety/SKILL.md` | `.agents/skills/research-browser-ui-safety/SKILL.md` | Direct-Sync | Browser automation safety invariants. Synchronized verbatim. |
| 17 | `research-comparison` | `.claude/skills/research-comparison/SKILL.md` | `.agents/skills/research-comparison/SKILL.md` | Direct-Sync | Comparative technology analysis rubrics. Synchronized verbatim. |
| 18 | `research-high-stakes` | `.claude/skills/research-high-stakes/SKILL.md` | `.agents/skills/research-high-stakes/SKILL.md` | Direct-Sync | Adversarial challenge protocols. Synchronized verbatim. |
| 19 | `research-root-cause` | `.claude/skills/research-root-cause/SKILL.md` | `.agents/skills/research-root-cause/SKILL.md` | Direct-Sync | Root cause investigation methods. Synchronized verbatim. |
| 20 | `research-source-audit` | `.claude/skills/research-source-audit/SKILL.md` | `.agents/skills/research-source-audit/SKILL.md` | Direct-Sync | Citation and provenance auditing protocols. Synchronized verbatim. |
| 21 | `research-strategic-general` | `.claude/skills/research-strategic-general/SKILL.md` | `.agents/skills/research-strategic-general/SKILL.md` | Direct-Sync | High-level synthesis frameworks. Synchronized verbatim. |
| 22 | `research` | `.claude/skills/research/SKILL.md` | `.agents/skills/research/SKILL.md` | Direct-Sync | Core research dispatch router. Synchronized verbatim. |
| 23 | `researcher-core` | `.claude/skills/researcher-core/SKILL.md` | `.agents/skills/researcher-core/SKILL.md` | Adapted | Confirms read-only sandbox mode and read-only shell boundaries; replaces references to Claude bash tool with Codex execution policy constraints. |
| 24 | `scribe-core` | `.claude/skills/scribe-core/SKILL.md` | `.agents/skills/scribe-core/SKILL.md` | Adapted | Replaces direct file write instructions with invocations of `trusted-writer.ps1` for plan files under `docs/plans/*.md`. |
| 25 | `scribe-editorial-quality` | `.claude/skills/scribe-editorial-quality/SKILL.md` | `.agents/skills/scribe-editorial-quality/SKILL.md` | Direct-Sync | Editorial quality standards. Synchronized verbatim. |
| 26 | `scribe-research-briefing` | `.claude/skills/scribe-research-briefing/SKILL.md` | `.agents/skills/scribe-research-briefing/SKILL.md` | Direct-Sync | Briefing structure formats. Synchronized verbatim. |
| 27 | `scribe-specification-and-planning`| `.claude/skills/scribe-specification-and-planning/SKILL.md` | `.agents/skills/scribe-specification-and-planning/SKILL.md` | Direct-Sync | Specification document schema. Synchronized verbatim. |
| 28 | `scribe-technical-documentation`| `.claude/skills/scribe-technical-documentation/SKILL.md` | `.agents/skills/scribe-technical-documentation/SKILL.md` | Direct-Sync | Technical documentation style standards. Synchronized verbatim. |
| 29 | `t1-api-integration-contracts` | `.claude/skills/t1-api-integration-contracts/SKILL.md` | `.agents/skills/t1-api-integration-contracts/SKILL.md` | Direct-Sync | API boundary contract validation. Synchronized verbatim. |
| 30 | `t1-core` | `.claude/skills/t1-core/SKILL.md` | `.agents/skills/t1-core/SKILL.md` | Adapted | Confirms `workspace-write` sandbox mode; aligns TDD cycle with `test-broker.ps1` execution instead of direct unmediated terminal calls. |
| 31 | `t1-performance-evidence` | `.claude/skills/t1-performance-evidence/SKILL.md` | `.agents/skills/t1-performance-evidence/SKILL.md` | Direct-Sync | Performance profiling evidence standards. Synchronized verbatim. |
| 32 | `t1-refactor-safety` | `.claude/skills/t1-refactor-safety/SKILL.md` | `.agents/skills/t1-refactor-safety/SKILL.md` | Direct-Sync | Refactoring safety protocols and test coverage requirements. Synchronized verbatim. |
| 33 | `t1-route-tracing` | `.claude/skills/t1-route-tracing/SKILL.md` | `.agents/skills/t1-route-tracing/SKILL.md` | Direct-Sync | End-to-end request route tracing procedures. Synchronized verbatim. |
| 34 | `t1-security-reliability` | `.claude/skills/t1-security-reliability/SKILL.md` | `.agents/skills/t1-security-reliability/SKILL.md` | Direct-Sync | Security boundary validation and error handling invariants. Synchronized verbatim. |
| 35 | `t1-tdd-test-design` | `.claude/skills/t1-tdd-test-design/SKILL.md` | `.agents/skills/t1-tdd-test-design/SKILL.md` | Direct-Sync | Test-driven design methodology and red-green-refactor loop. Synchronized verbatim. |
| 36 | `t1-ui-wiring-verification` | `.claude/skills/t1-ui-wiring-verification/SKILL.md` | `.agents/skills/t1-ui-wiring-verification/SKILL.md` | Direct-Sync | UI state management and prop binding verification. Synchronized verbatim. |
| 37 | `t2-escalation` | `.claude/skills/t2-escalation/SKILL.md` | `.agents/skills/t2-escalation/SKILL.md` | Adapted | Replaces Claude subagent escalation primitives with Codex CLI `orchestrate-role.ps1` escalation triggers, routing high-severity architectural escalations to `t2-engineer` and `t3-engineering-advisor` roles with `workspace-write` enforcement and `test-broker.ps1` validation. |
| 38 | `ux-architecture` | `.claude/skills/ux-architecture/SKILL.md` | `.agents/skills/ux-architecture/SKILL.md` | Direct-Sync | Information architecture and user journey flows. Synchronized verbatim. |
| 39 | `verifier-core` | `.claude/skills/verifier-core/SKILL.md` | `.agents/skills/verifier-core/SKILL.md` | Adapted | Confirms read-only sandbox mode; integrates verification receipts and test broker runs under `IsolatedSandbox`. |
| 40 | `visual-system` | `.claude/skills/visual-system/SKILL.md` | `.agents/skills/visual-system/SKILL.md` | Direct-Sync | Design system tokens and styling contracts. Synchronized verbatim. |
| 41 | `workflow-author` | `.claude/skills/workflow-author/SKILL.md` | `.agents/skills/workflow-author/SKILL.md` | Adapted | Replaces Claude Code skills/custom agents with `.agents/skills` and `.codex/agents/*.toml` schemas; replaces `.claude` workflows with `.codex` lifecycle hooks and `.agents/scripts`; replaces `/build` with `orchestrate-role.ps1` dispatch state machine; replaces `claude -p` headless execution with `codex exec -`; and replaces Claude Agent SDK references with Codex CLI subagent configuration. |

---

## Shared Process Launcher Concurrent I/O Test Suite (`tests/codex-parity/test-codex-launcher.ps1`)

The shared launcher test suite verifies direct process execution under PowerShell 7, pure native async I/O streams, non-deadlocking pipe concurrency, timeout tree cleanup with affirmative root and descendant verification, failure classification, and complete absence of shell string parsing:

```powershell
[CmdletBinding()]
param(
    [string]$RepoRoot = "H:\CommandCenter\orchestrator"
)

$ErrorActionPreference = 'Stop'

# Assert PowerShell 7 prerequisite
Assert-PowerShell7Prerequisite

$pwsh = (Get-Command "pwsh.exe" -ErrorAction Stop).Source
$launcherScript = (Join-Path $RepoRoot ".agents/scripts/invoke-codex-process.ps1")
$resolverModule = (Join-Path $RepoRoot ".agents/scripts/CodexLauncherResolver.psm1")
$helperSourcePath = (Join-Path $RepoRoot ".agents/scripts/ProcessRunnerHelper.cs")

# Derive and validate canonical System32 taskkill.exe for test assertions
$systemRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
if ([string]::IsNullOrWhiteSpace($systemRoot)) {
    $systemRoot = $env:SystemRoot; if (-not $systemRoot) { $systemRoot = "C:\Windows" }
}
$canonicalSys32 = [System.IO.Path]::GetFullPath((Join-Path $systemRoot "System32"))
if (-not $canonicalSys32.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $canonicalSys32 += [System.IO.Path]::DirectorySeparatorChar
}
$canonicalTaskkill = [System.IO.Path]::GetFullPath((Join-Path $canonicalSys32 "taskkill.exe"))
$tkFi = [System.IO.FileInfo]::new($canonicalTaskkill)
if (-not $tkFi.Exists -or ($tkFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
    throw "Security violation: taskkill.exe is missing or is a reparse point: $canonicalTaskkill"
}
$tkDir = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName($canonicalTaskkill))
while ($tkDir -and $tkDir.FullName.Length -ge $systemRoot.Length) {
    if ($tkDir.Exists -and ($tkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: Reparse point in taskkill ancestor: $($tkDir.FullName)"
    }
    $tkDir = $tkDir.Parent
}

# Parse-correct bounded taskkill helper using ProcessStartInfo (eliminates synchronous PowerShell call-operator invocations)
# Enforces authoritative subdeadline wait limit on taskkill helper, never waiting into the emergency reserve
function Invoke-TestBoundedTaskkill {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId,

        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Stopwatch]$Stopwatch,

        [int]$AuthoritativeSubdeadlineMs = 2250,
        [int]$TotalBudgetMs = 3000,
        [bool]$IncludeTree = $true
    )

    $result = [ordered]@{
        Success = $false
        ExitCode = -1
        TimedOut = $false
        ErrorMessage = ""
    }

    $remStart = $AuthoritativeSubdeadlineMs - [int]$Stopwatch.ElapsedMilliseconds
    if ($remStart -le 0) {
        $result.TimedOut = $true
        $result.ErrorMessage = "Authoritative subdeadline expired before taskkill start for PID $($ProcessId)."
        return [pscustomobject]$result
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $canonicalTaskkill
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.ArgumentList.Add("/PID")
    $psi.ArgumentList.Add($ProcessId.ToString())
    if ($IncludeTree) {
        $psi.ArgumentList.Add("/T")
    }
    $psi.ArgumentList.Add("/F")

    $proc = $null
    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        if ($null -eq $proc) {
            $result.ErrorMessage = "Process.Start returned null for taskkill.exe on PID $($ProcessId)."
            return [pscustomobject]$result
        }

        try {
            $outTask = $proc.StandardOutput.ReadToEndAsync()
            $errTask = $proc.StandardError.ReadToEndAsync()

            $remExit = $AuthoritativeSubdeadlineMs - [int]$Stopwatch.ElapsedMilliseconds
            if ($remExit -le 0 -or -not $proc.WaitForExit($remExit)) {
                $result.TimedOut = $true
                $result.ErrorMessage = "taskkill.exe timed out before authoritative subdeadline for PID $($ProcessId)."
                try { if (-not $proc.HasExited) { $proc.Kill($true) } } catch { }
                return [pscustomobject]$result
            }

            $remDrain = $AuthoritativeSubdeadlineMs - [int]$Stopwatch.ElapsedMilliseconds
            if ($remDrain -le 0) {
                $result.TimedOut = $true
                $result.ErrorMessage = "taskkill.exe stream drain timed out before authoritative subdeadline for PID $($ProcessId)."
                return [pscustomobject]$result
            }

            $drainTask = [System.Threading.Tasks.Task]::WhenAll($outTask, $errTask)
            if (-not $drainTask.Wait($remDrain)) {
                $result.TimedOut = $true
                $result.ErrorMessage = "taskkill.exe streams failed to drain before authoritative subdeadline for PID $($ProcessId)."
                return [pscustomobject]$result
            }

            $result.ExitCode = $proc.ExitCode
            if ($proc.ExitCode -eq 0) {
                $result.Success = $true
            } else {
                $result.ErrorMessage = "taskkill.exe exited with code $($proc.ExitCode): $($errTask.Result)"
            }
        } finally {
            # Taskkill helper process cleanup: may be waited on ONLY until 2250 ms authoritative subdeadline, never into 750 ms reserve.
            # At subdeadline, issue immediate Kill(true), record helper unverified if not exited.
            try {
                if (-not $proc.HasExited) {
                    try { $proc.Kill($true) } catch { try { $proc.Kill() } catch { } }
                    $remHelperWait = $AuthoritativeSubdeadlineMs - [int]$Stopwatch.ElapsedMilliseconds
                    if ($remHelperWait -gt 0) {
                        $null = $proc.WaitForExit($remHelperWait)
                    }
                    if (-not $proc.HasExited) {
                        try { $proc.Kill($true) } catch { }
                        $result.ErrorMessage = "taskkill.exe helper process PID $($proc.Id) could not be verified exited before authoritative subdeadline."
                        $result.TimedOut = $true
                    }
                }
            } catch {
                $result.ErrorMessage = "Exception during taskkill helper cleanup for PID $($ProcessId): $($_.Exception.Message)"
            }
            $proc.Dispose()
        }
    } catch {
        $result.ErrorMessage = "Exception launching taskkill.exe for PID $($ProcessId): $($_.Exception.Message)"
    }

    return [pscustomobject]$result
}

# ==============================================================================
# Test Case 0: Mandatory ProcessRunnerHelper.cs Compile-Only Acceptance Gate
# ==============================================================================
Write-Output "Executing Test Case 0: ProcessRunnerHelper.cs Compile-Only Acceptance Gate..."
if (-not (Test-Path -LiteralPath $helperSourcePath -PathType Leaf)) {
    throw "Test 0 Failed: ProcessRunnerHelper.cs missing at $helperSourcePath"
}
$sourceText = Get-Content -Raw -LiteralPath $helperSourcePath -Encoding UTF8

if ($sourceText -notmatch '(?m)^\s*#nullable\s+enable') {
    throw "Test 0 Failed: ProcessRunnerHelper.cs missing mandatory '#nullable enable' compiler directive."
}

try {
    Add-Type -TypeDefinition $sourceText -Language CSharp -ErrorAction Stop
} catch {
    throw "Test 0 Failed: Add-Type compilation failed for ProcessRunnerHelper.cs: $_"
}

$helperType = [System.Management.Automation.PSTypeName]'CodexHarness.NativeProcessRunner'.Type
if (-not $helperType) { throw "Test 0 Failed: CodexHarness.NativeProcessRunner type was not registered." }

# Verify public production API has strictly NO observer parameter (3 parameters: psi, stdinText, timeoutSeconds)
$method = $helperType.GetMethod("ExecuteProcessAsync", [System.Reflection.BindingFlags]'Public,Static')
if (-not $method) { throw "Test 0 Failed: ExecuteProcessAsync method missing on CodexHarness.NativeProcessRunner." }
if ($method.GetParameters().Length -ne 3) {
    throw "Test 0 Failed: Public ExecuteProcessAsync must have exactly 3 parameters (no observer parameter allowed in public API). Found: $($method.GetParameters().Length)"
}

$shimType = [System.Management.Automation.PSTypeName]'CodexHarness.NativeProcessRunnerTestShim'.Type
if (-not $shimType) { throw "Test 0 Failed: CodexHarness.NativeProcessRunnerTestShim type was not registered." }
$excType = [System.Management.Automation.PSTypeName]'CodexHarness.TreeCleanupUnverifiedException'.Type
if (-not $excType) { throw "Test 0 Failed: CodexHarness.TreeCleanupUnverifiedException type was not registered." }
$obsExcType = [System.Management.Automation.PSTypeName]'CodexHarness.ProcessObserverSetupException'.Type
if (-not $obsExcType) { throw "Test 0 Failed: CodexHarness.ProcessObserverSetupException type was not registered." }
$fsType = [System.Management.Automation.PSTypeName]'CodexHarness.NativeFileSystem'.Type
if (-not $fsType) { throw "Test 0 Failed: CodexHarness.NativeFileSystem type was not registered." }
Write-Output "Test Case 0 Passed: Compile-only acceptance gate verified."

# ==============================================================================
# Test Case 1A: Module Import, AST Allowlist Static Safety & Strict Environment Invariants
# ==============================================================================
Write-Output "Executing Test Case 1A: Module Import, AST Allowlist Static Safety & Invariants..."

$tokens = $null
$parseErrors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($resolverModule, [ref]$tokens, [ref]$parseErrors)

if ($parseErrors -and $parseErrors.Count -gt 0) {
    throw "Test 1A Failed: Parser zero-error acceptance failed on CodexLauncherResolver.psm1: $($parseErrors -join '; ')"
}

# Explicit AST allowlist audit
$allowedCommands = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@('Test-Path', 'Get-Content', 'ConvertFrom-Json', 'Join-Path', 'Split-Path', 'Get-Command', 'Export-ModuleMember', 'Resolve-NpmShim') | ForEach-Object { [void]$allowedCommands.Add($_) }

$allowedTypes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@('string', 'System.IO.Path', 'ordered', 'char', 'int', 'bool', 'Parameter', 'CmdletBinding') | ForEach-Object { [void]$allowedTypes.Add($_) }

$allowedStaticMethods = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@('System.IO.Path::GetDirectoryName', 'System.IO.Path::GetFullPath', 'string::IsNullOrWhiteSpace') | ForEach-Object { [void]$allowedStaticMethods.Add($_) }

$allowedInstanceMethods = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@('Trim', 'TrimStart') | ForEach-Object { [void]$allowedInstanceMethods.Add($_) }

$commandElements = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true)
foreach ($cmdAst in $commandElements) {
    if ($cmdAst.InvocationOperator -ne [System.Management.Automation.Language.TokenKind]::None) {
        throw "Test 1A Failed: Dynamic invocation operator '$($cmdAst.InvocationOperator)' detected in resolver: $($cmdAst.Extent.Text)"
    }
    $cmdName = $cmdAst.GetCommandName()
    if ([string]::IsNullOrWhiteSpace($cmdName)) {
        throw "Test 1A Failed: Expression or dynamic command name detected in resolver: $($cmdAst.Extent.Text)"
    }
    if (-not $allowedCommands.Contains($cmdName)) {
        throw "Test 1A Failed: Non-allowlisted command '$cmdName' detected in resolver: $($cmdAst.Extent.Text)"
    }
    if ($cmdAst.Redirections -and $cmdAst.Redirections.Count -gt 0) {
        throw "Test 1A Failed: File redirection detected in command: $($cmdAst.Extent.Text)"
    }
}

$typeElements = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.TypeExpressionAst] }, $true)
foreach ($typeAst in $typeElements) {
    $typeName = $typeAst.TypeName.Name
    if (-not $allowedTypes.Contains($typeName)) {
        throw "Test 1A Failed: Non-allowlisted type '[$typeName]' detected in resolver: $($typeAst.Extent.Text)"
    }
}

$invokeMemberElements = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] }, $true)
foreach ($invAst in $invokeMemberElements) {
    if ($invAst.Expression -is [System.Management.Automation.Language.TypeExpressionAst]) {
        $targetType = $invAst.Expression.TypeName.Name
        $methodName = $invAst.Member.Extent.Text
        $staticSig = "$targetType::$methodName"
        if (-not $allowedStaticMethods.Contains($staticSig)) {
            throw "Test 1A Failed: Non-allowlisted static method call '$staticSig' detected in resolver: $($invAst.Extent.Text)"
        }
    } else {
        $memberName = $invAst.Member.Extent.Text
        if (-not $allowedInstanceMethods.Contains($memberName)) {
            throw "Test 1A Failed: Non-allowlisted instance method '$memberName' detected in resolver: $($invAst.Extent.Text)"
        }
    }
}

$assignmentElements = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)
foreach ($assignAst in $assignmentElements) {
    $left = $assignAst.Left
    if ($left -is [System.Management.Automation.Language.VariableExpressionAst] -and $left.VariablePath.IsUnscoped -eq $false -and $left.VariablePath.DriveName -eq "env") {
        throw "Test 1A Failed: Environment variable assignment detected: $($assignAst.Extent.Text)"
    }
}

$scriptBlockElements = $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.ScriptBlockAst] }, $true)
if ($scriptBlockElements.Count -gt 3) {
    throw "Test 1A Failed: Unauthorized scriptblock escaping function boundaries detected in resolver."
}

$disallowedAstNodes = $ast.FindAll({ param($node)
    $node -is [System.Management.Automation.Language.ScriptBlockExpressionAst] -or
    $node -is [System.Management.Automation.Language.FileRedirectionAst]
}, $true)
if ($disallowedAstNodes.Count -gt 0) {
    throw "Test 1A Failed: Disallowed dynamic/redirection AST node detected: $($disallowedAstNodes[0].Extent.Text)"
}

$envSnapshotBefore = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
foreach ($item in (Get-ChildItem env:)) { $envSnapshotBefore[$item.Name] = $item.Value }
$locationBefore = (Get-Location).Path
$preferencesBefore = [ordered]@{
    ErrorActionPreference = $ErrorActionPreference
    WarningPreference = $WarningPreference
    VerbosePreference = $VerbosePreference
    DebugPreference = $DebugPreference
    InformationPreference = $InformationPreference
    ProgressPreference = $ProgressPreference
    ConfirmPreference = $ConfirmPreference
    WhatIfPreference = $WhatIfPreference
}

Import-Module -Name $resolverModule -Force -ErrorAction Stop
$resolvedInfo = Resolve-CodexLauncher
if ($null -eq $resolvedInfo -or [string]::IsNullOrWhiteSpace($resolvedInfo.ExecutablePath)) {
    throw "Test 1A Failed: Resolve-CodexLauncher returned null or empty ExecutablePath."
}

$envSnapshotAfter = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::Ordinal)
foreach ($item in (Get-ChildItem env:)) { $envSnapshotAfter[$item.Name] = $item.Value }
$locationAfter = (Get-Location).Path
$preferencesAfter = [ordered]@{
    ErrorActionPreference = $ErrorActionPreference
    WarningPreference = $WarningPreference
    VerbosePreference = $VerbosePreference
    DebugPreference = $DebugPreference
    InformationPreference = $InformationPreference
    ProgressPreference = $ProgressPreference
    ConfirmPreference = $ConfirmPreference
    WhatIfPreference = $WhatIfPreference
}

if ($envSnapshotBefore.Count -ne $envSnapshotAfter.Count) {
    throw "Test 1A Failed: Environment variable count changed after resolver execution."
}
foreach ($kv in $envSnapshotBefore) {
    if (-not $envSnapshotAfter.ContainsKey($kv.Key) -or -not [string]::Equals($kv.Value, $envSnapshotAfter[$kv.Key], [System.StringComparison]::Ordinal)) {
        throw "Test 1A Failed: Environment variable '$($kv.Key)' mutated during resolver execution."
    }
}
if (-not [string]::Equals($locationBefore, $locationAfter, [System.StringComparison]::Ordinal)) {
    throw "Test 1A Failed: Current location mutated during resolver execution."
}
foreach ($prefKey in $preferencesBefore.Keys) {
    if (-not [string]::Equals("$($preferencesBefore[$prefKey])", "$($preferencesAfter[$prefKey])", [System.StringComparison]::Ordinal)) {
        throw "Test 1A Failed: Preference variable '$prefKey' mutated during resolver execution."
    }
}

Write-Output "Test Case 1A Passed: AST allowlist static safety, internal Resolve-NpmShim call, Parser zero-error acceptance, and strict environment/location/preference invariants verified."

# ==============================================================================
# Test Case 1B: Structured Version Smoke & Exact Identity Assertion
# ==============================================================================
$versionRes = & $launcherScript -Argv @("--version") -EnvironmentMode AuthenticatedRole -TimeoutSeconds 15
if ($versionRes.TimedOut -or $versionRes.ExitCode -ne 0) {
    throw "Test 1B Failed: Version smoke failed. ExitCode=$($versionRes.ExitCode), Stderr=$($versionRes.Stderr)"
}
$rawOutput = $versionRes.Stdout.Trim()
$lines = $rawOutput -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
if ($lines.Count -ne 1) { throw "Test 1B Failed: Version output contained extra lines: '$rawOutput'" }
$verMatch = [regex]::Match($lines[0].Trim(), '^codex-cli\s+v?(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)$')
if (-not $verMatch.Success) { throw "Test 1B Failed: Output '$($lines[0])' did not match '^codex-cli <version>'." }
$extractedToken = $verMatch.Groups[1].Value

if ($resolvedInfo.LauncherType -eq "NodeScriptEntry" -and $resolvedInfo.PackageVersion) {
    $expectedVer = "$($resolvedInfo.PackageVersion)".Trim().TrimStart('v')
    if ($extractedToken.TrimStart('v') -ne $expectedVer) {
        throw "Test 1B Failed: Extracted version '$extractedToken' does not match package.json '$expectedVer'."
    }
}
Write-Output "Test Case 1B Passed: Structured version smoke verified: codex-cli $extractedToken"

# ==============================================================================
# Test Case 2: Child that Never Reads Stdin
# ==============================================================================
$largeInput = "A" * 131072
$noReadScript = "Write-Output 'NO_READ_SUCCESS'; exit 0"
$noReadRes = & $launcherScript -Argv @("sandbox", "--", $pwsh, "-NoProfile", "-Command", $noReadScript) `
    -EnvironmentMode AuthenticatedRole -StdinText $largeInput -TimeoutSeconds 10
if ($noReadRes.TimedOut -or $noReadRes.ExitCode -ne 0 -or $noReadRes.Stdout -notmatch "NO_READ_SUCCESS") {
    throw "Test 2 Failed: Unconsumed stdin caused hang or failure."
}
Write-Output "Test Case 2 Passed: Child never reads stdin completes cleanly."

# ==============================================================================
# Test Case 3: Child Fills Stdout Before Reading Stdin (Concurrent Drain Deadlock Prevention)
# ==============================================================================
$deadlockTestScript = @"
`$chunk = 'B' * 65536
[Console]::Out.WriteLine(`$chunk)
[Console]::Out.Flush()
`$in = [Console]::In.ReadToEnd()
Write-Output (`"READ_LENGTH=`" + `$in.Length)
exit 0
"@
$deadlockInput = "C" * 32768
$deadlockRes = & $launcherScript -Argv @("sandbox", "--", $pwsh, "-NoProfile", "-Command", $deadlockTestScript) `
    -EnvironmentMode AuthenticatedRole -StdinText $deadlockInput -TimeoutSeconds 15
if ($deadlockRes.TimedOut -or $deadlockRes.ExitCode -ne 0 -or $deadlockRes.Stdout -notmatch "READ_LENGTH=32768") {
    throw "Test 3 Failed: Pipe deadlock detected."
}
Write-Output "Test Case 3 Passed: Concurrent stdout drain prevents pipe deadlock."

# ==============================================================================
# Test Case 4: Large Input / Large Output Round Trip
# ==============================================================================
$roundTripInput = "D" * 262144
$echoScript = "`$data = [Console]::In.ReadToEnd(); [Console]::Out.Write(`$data); exit 0"
$roundTripRes = & $launcherScript -Argv @("sandbox", "--", $pwsh, "-NoProfile", "-Command", $echoScript) `
    -EnvironmentMode AuthenticatedRole -StdinText $roundTripInput -TimeoutSeconds 20
if ($roundTripRes.TimedOut -or $roundTripRes.ExitCode -ne 0 -or $roundTripRes.Stdout.Length -lt 262144) {
    throw "Test 4 Failed: Large I/O round-trip failed."
}
Write-Output "Test Case 4 Passed: Large input/output round-trip verified (256 KB)."

# ==============================================================================
# Test Case 5A: Timeout Watchdog & Process Tree Cleanup (Child + Descendant)
# ==============================================================================
$test5aGuid = [System.Guid]::NewGuid().ToString('N')
$sandboxesBase = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "runtime/test-sandboxes"))
if (-not $sandboxesBase.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
    $sandboxesBase += [System.IO.Path]::DirectorySeparatorChar
}

$test5aDir = [System.IO.Path]::GetFullPath((Join-Path $sandboxesBase "test5a-$test5aGuid"))

if (-not $test5aDir.StartsWith($sandboxesBase, [System.StringComparison]::OrdinalIgnoreCase) -or $test5aDir -eq $sandboxesBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
    throw "Security violation: Test 5A sandbox escapes runtime base: $test5aDir"
}

$chkDir = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName($test5aDir))
while ($chkDir -and $chkDir.FullName.Length -ge $RepoRoot.Length) {
    if ($chkDir.Exists -and ($chkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: Reparse point in Test 5A ancestor: $($chkDir.FullName)"
    }
    $chkDir = $chkDir.Parent
}

$ownerMarker5a = (Join-Path $test5aDir ".sandbox-owner.json")
$pidFile5a = (Join-Path $test5aDir "timeout-tree-pids.txt")
$candidatePids5a = [System.Collections.Generic.List[int]]::new()
$capturedHandles5a = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()
$test5aFailure = $null

try {
    $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists($test5aDir)
    
    $mStream5a = [System.IO.FileStream]::new($ownerMarker5a, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes((@{ runGuid = $test5aGuid; createdAtUtc = (Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json))
        $mStream5a.Write($mBytes, 0, $mBytes.Length)
    } finally { $mStream5a.Dispose() }

    $treeScript = @"
`$parentPid = `$PID
`$descProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-Command", "Start-Sleep -Seconds 60" -WindowStyle Hidden -PassThru
`$descPid = `$descProc.Id
Set-Content -LiteralPath '$($pidFile5a.Replace("'", "''"))' -Value "`$parentPid,`$descPid" -Encoding UTF8
Start-Sleep -Seconds 30
Write-Output 'SHOULD_NOT_ARRIVE'
"@

    $onStartedCallback5a = [Action[System.Diagnostics.Process]]{
        param($p)
        $capturedHandles5a.Add($p)
        $candidatePids5a.Add($p.Id)
    }

    $psi5a = [System.Diagnostics.ProcessStartInfo]::new()
    $psi5a.FileName = $pwsh
    $psi5a.WorkingDirectory = $RepoRoot
    $psi5a.UseShellExecute = $false
    $psi5a.RedirectStandardOutput = $true
    $psi5a.RedirectStandardError = $true
    $psi5a.RedirectStandardInput = $true
    $psi5a.ArgumentList.Add("-NoProfile")
    $psi5a.ArgumentList.Add("-Command")
    $psi5a.ArgumentList.Add($treeScript)

    $task5a = [CodexHarness.NativeProcessRunnerTestShim]::ExecuteWithObserverAsync($psi5a, $null, 3, $onStartedCallback5a)
    $timeoutRes = $task5a.GetAwaiter().GetResult()

    if (-not $timeoutRes.TimedOut -or $timeoutRes.ExitCode -ne 124) {
        throw "Test 5A Failed: Timeout watchdog did not return ExitCode 124."
    }

    if (Test-Path -LiteralPath $pidFile5a -PathType Leaf) {
        $rawContent = (Get-Content -Raw -LiteralPath $pidFile5a).Trim()
        if (-not [string]::IsNullOrWhiteSpace($rawContent)) {
            $tokens = $rawContent.Split(',') | ForEach-Object { $_.Trim() }
            foreach ($tok in $tokens) {
                $pidVal = 0
                if ([int]::TryParse($tok, [ref]$pidVal) -and $pidVal -gt 0 -and -not $candidatePids5a.Contains($pidVal)) {
                    $candidatePids5a.Add($pidVal)
                    try { $capturedHandles5a.Add([System.Diagnostics.Process]::GetProcessById($pidVal)) } catch { }
                }
            }
        }
    } else {
        throw "Test 5A Failed: PID fixture file was not created."
    }

    if ($candidatePids5a.Count -lt 2) {
        throw "Test 5A Failed: Incomplete fixture; expected at least 2 distinct PIDs."
    }

} catch {
    $test5aFailure = $_
} finally {
    $cleanupErrors5a = [System.Collections.Generic.List[string]]::new()
    $swCleanup5a = [System.Diagnostics.Stopwatch]::StartNew()
    $cleanupBudget5a = 3000
    $cleanupReserve5a = 750
    $authoritativeSubdeadline5a = $cleanupBudget5a - $cleanupReserve5a # 2250 ms
    $authoritativeRootSuccess5a = $false

    # 1. Authoritative phase: invoke Invoke-TestBoundedTaskkill on live captured root bounded strictly by authoritative subdeadline (2250 ms)
    if ($capturedHandles5a.Count -gt 0 -and $null -ne $capturedHandles5a[0]) {
        $rootProc = $capturedHandles5a[0]
        $rootExited = $false
        try { $rootExited = $rootProc.HasExited } catch { $rootExited = $true }
        if (-not $rootExited) {
            $remAuthWait = $authoritativeSubdeadline5a - [int]$swCleanup5a.ElapsedMilliseconds
            if ($remAuthWait -gt 0) {
                $tkRes = Invoke-TestBoundedTaskkill -ProcessId $rootProc.Id -Stopwatch $swCleanup5a -AuthoritativeSubdeadlineMs $authoritativeSubdeadline5a -TotalBudgetMs $cleanupBudget5a -IncludeTree $true
                if ($tkRes.Success) {
                    $remRootWait = $authoritativeSubdeadline5a - [int]$swCleanup5a.ElapsedMilliseconds
                    if ($remRootWait -gt 0) {
                        try {
                            if ($rootProc.WaitForExit($remRootWait) -or $rootProc.HasExited) {
                                $authoritativeRootSuccess5a = $true
                            }
                        } catch { $authoritativeRootSuccess5a = $true }
                    }
                } else {
                    $cleanupErrors5a.Add("TreeCleanupUnverified: Authoritative root taskkill failed: $($tkRes.ErrorMessage)")
                }
            } else {
                $cleanupErrors5a.Add("TreeCleanupUnverified: Authoritative subdeadline exhausted before root taskkill.")
            }
        } else {
            $authoritativeRootSuccess5a = $true
        }
    }

    # If authoritative taskkill cannot complete with exit 0 before the subdeadline, immediately record TreeCleanupUnverified
    # and transition immediately to root emergency mitigation using reserve
    if (-not $authoritativeRootSuccess5a) {
        if (-not ($cleanupErrors5a -join "; " -match "TreeCleanupUnverified")) {
            $cleanupErrors5a.Add("TreeCleanupUnverified: Root taskkill did not complete with exit 0 before authoritative subdeadline.")
        }
    }

    # 2. Candidate cleanup: use bounded helper only while authoritative time remains; otherwise emergency mitigation
    for ($i = 0; $i -lt $candidatePids5a.Count; $i++) {
        $pId = $candidatePids5a[$i]
        $pHandle = if ($i -lt $capturedHandles5a.Count) { $capturedHandles5a[$i] } else { $null }

        $alreadyExited = $false
        if ($null -ne $pHandle) { try { $alreadyExited = $pHandle.HasExited } catch { $alreadyExited = $true } }

        if (-not $alreadyExited) {
            $remAuth = $authoritativeSubdeadline5a - [int]$swCleanup5a.ElapsedMilliseconds
            if ($authoritativeRootSuccess5a -and $remAuth -gt 0) {
                $candRes = Invoke-TestBoundedTaskkill -ProcessId $pId -Stopwatch $swCleanup5a -AuthoritativeSubdeadlineMs $authoritativeSubdeadline5a -TotalBudgetMs $cleanupBudget5a -IncludeTree $false
                if (-not $candRes.Success) {
                    # Fallback to emergency mitigation within global budget
                    if ($null -ne $pHandle) {
                        try { $pHandle.Kill($true) } catch { try { $pHandle.Kill() } catch { } }
                    }
                    try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
                }
            } else {
                # Emergency mitigation within global 3000 ms budget using reserve
                if ($null -ne $pHandle) {
                    try { $pHandle.Kill($true) } catch { try { $pHandle.Kill() } catch { } }
                }
                try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
            }
        }
    }

    # 3. Bounded wait and affirmative zero-survivor assertion within single remaining reserve (up to 3000 ms global budget)
    for ($i = 0; $i -lt $candidatePids5a.Count; $i++) {
        $pId = $candidatePids5a[$i]
        $pHandle = if ($i -lt $capturedHandles5a.Count) { $capturedHandles5a[$i] } else { $null }

        $remWait = $cleanupBudget5a - [int]$swCleanup5a.ElapsedMilliseconds
        if ($remWait -gt 0) {
            if ($null -ne $pHandle) {
                try { $null = $pHandle.WaitForExit($remWait) } catch { }
                try { $pHandle.Dispose() } catch { }
            }
        }

        $remaining = Get-Process -Id $pId -ErrorAction SilentlyContinue
        if ($null -ne $remaining) {
            try { $remaining.Kill($true) } catch { try { $remaining.Kill() } catch { } }
            try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
            $remaining2 = Get-Process -Id $pId -ErrorAction SilentlyContinue
            if ($null -ne $remaining2) {
                $cleanupErrors5a.Add("TreeCleanupUnverified: Process $pId remains alive after termination attempts.")
            }
        }
    }

    # 4. Hardened directory deletion
    if (Test-Path -LiteralPath $test5aDir) {
        $canDelete5a = $true
        if (-not $test5aDir.StartsWith($sandboxesBase, [System.StringComparison]::OrdinalIgnoreCase) -or $test5aDir -eq $sandboxesBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
            $cleanupErrors5a.Add("Security Violation: Test 5A sandbox escapes runtime base: $test5aDir. Refusing recursive delete.")
            $canDelete5a = $false
        }
        if (-not (Test-Path -LiteralPath $ownerMarker5a -PathType Leaf)) {
            $cleanupErrors5a.Add("Security Violation: Test 5A ownership marker missing. Refusing recursive delete.")
            $canDelete5a = $false
        } else {
            $mContent = Get-Content -Raw -LiteralPath $ownerMarker5a | ConvertFrom-Json
            if ($mContent.runGuid -ne $test5aGuid) {
                $cleanupErrors5a.Add("Security Violation: Test 5A ownership marker mismatch. Refusing recursive delete.")
                $canDelete5a = $false
            }
        }
        $dInfo = [System.IO.DirectoryInfo]::new($test5aDir)
        if ($dInfo.Exists -and ($dInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $cleanupErrors5a.Add("Security Violation: Test 5A directory is a reparse point. Refusing recursive delete.")
            $canDelete5a = $false
        }
        $anc = $dInfo.Parent
        while ($anc -and $anc.FullName.Length -ge $RepoRoot.Length) {
            if ($anc.Exists -and ($anc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                $cleanupErrors5a.Add("Security Violation: Reparse point in Test 5A ancestor $($anc.FullName). Refusing recursive delete.")
                $canDelete5a = $false
                break
            }
            $anc = $anc.Parent
        }

        if ($canDelete5a) {
            try {
                Remove-Item -LiteralPath $test5aDir -Recurse -Force -ErrorAction Stop
                if (Test-Path -LiteralPath $test5aDir) { throw "Directory still exists after Remove-Item." }
            } catch {
                $cleanupErrors5a.Add("Failed to delete Test 5A sandbox: $_")
            }
        }
    }

    if ($cleanupErrors5a.Count -gt 0) {
        $msg = "Test 5A Cleanup Verification Failed: " + ($cleanupErrors5a -join "; ")
        if ($null -ne $test5aFailure) { throw "$($test5aFailure.Exception.Message) | $msg" } else { throw $msg }
    }

    if ($null -ne $test5aFailure) { throw $test5aFailure }
}

Write-Output "Test Case 5A Passed: Timeout watchdog verified; live root killed via Invoke-TestBoundedTaskkill first, child and descendant absent, sandbox cleanly deleted."

# ==============================================================================
# Test Case 5B: Fail-Closed Taskkill Failure Classification Gate (TreeCleanupUnverified)
# ==============================================================================
Write-Output "Executing Test Case 5B: Taskkill Failure Classification Gate via Internal Test Seam..."

$test5bGuid = [System.Guid]::NewGuid().ToString('N')
$test5bDir = [System.IO.Path]::GetFullPath((Join-Path $sandboxesBase "test5b-$test5bGuid"))

if (-not $test5bDir.StartsWith($sandboxesBase, [System.StringComparison]::OrdinalIgnoreCase) -or $test5bDir -eq $sandboxesBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
    throw "Security violation: Test 5B sandbox escapes runtime base: $test5bDir"
}

$chkDir = [System.IO.DirectoryInfo]::new([System.IO.Path]::GetDirectoryName($test5bDir))
while ($chkDir -and $chkDir.FullName.Length -ge $RepoRoot.Length) {
    if ($chkDir.Exists -and ($chkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Security violation: Reparse point in Test 5B ancestor: $($chkDir.FullName)"
    }
    $chkDir = $chkDir.Parent
}

$ownerMarker5b = (Join-Path $test5bDir ".sandbox-owner.json")
$failPidFile = (Join-Path $test5bDir "timeout-fail-pids.txt")
$candidatePids = [System.Collections.Generic.List[int]]::new()
$capturedHandles = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()
$setupSucceeded = $false
$threwTreeCleanupUnverified = $false
$testFailure = $null

try {
    $null = [CodexHarness.NativeFileSystem]::CreateDirectoryFailIfExists($test5bDir)

    $mStream5b = [System.IO.FileStream]::new($ownerMarker5b, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
    try {
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes((@{ runGuid = $test5bGuid; createdAtUtc = (Get-Date).ToUniversalTime().ToString('o') } | ConvertTo-Json))
        $mStream5b.Write($mBytes, 0, $mBytes.Length)
    } finally { $mStream5b.Dispose() }

    $failTreeScript = @"
`$parentPid = `$PID
`$descProc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-Command", "Start-Sleep -Seconds 60" -WindowStyle Hidden -PassThru
`$descPid = `$descProc.Id
Set-Content -LiteralPath '$($failPidFile.Replace("'", "''"))' -Value "`$parentPid,`$descPid" -Encoding UTF8
Start-Sleep -Seconds 30
Write-Output 'SHOULD_NOT_ARRIVE'
"@

    $failPsi = [System.Diagnostics.ProcessStartInfo]::new()
    $failPsi.FileName = $pwsh
    $failPsi.WorkingDirectory = $RepoRoot
    $failPsi.UseShellExecute = $false
    $failPsi.RedirectStandardOutput = $true
    $failPsi.RedirectStandardError = $true
    $failPsi.RedirectStandardInput = $true
    $failPsi.ArgumentList.Add("-NoProfile")
    $failPsi.ArgumentList.Add("-Command")
    $failPsi.ArgumentList.Add($failTreeScript)

    # 1. Start runner task asynchronously with immediate root process capture callback
    $onStartedCallback5b = [Action[System.Diagnostics.Process]]{
        param($p)
        $capturedHandles.Add($p)
        $candidatePids.Add($p.Id)
    }

    $runnerTask = [CodexHarness.NativeProcessRunnerTestShim]::ExecuteWithFailingTreeKillerAsync($failPsi, $null, 5, 1, $false, $onStartedCallback5b)

    # 2. Incrementally poll and capture PID tokens available from fixture
    $fixtureDeadline = [System.DateTime]::UtcNow.AddSeconds(4)
    while (-not (Test-Path -LiteralPath $failPidFile -PathType Leaf) -and ([System.DateTime]::UtcNow -lt $fixtureDeadline)) {
        Start-Sleep -Milliseconds 50
    }

    if (-not (Test-Path -LiteralPath $failPidFile -PathType Leaf)) {
        throw "Test 5B Setup Failed: PID fixture file not created within deadline ($failPidFile)."
    }

    $rawContent = (Get-Content -Raw -LiteralPath $failPidFile -Encoding UTF8)
    if ([string]::IsNullOrWhiteSpace($rawContent)) {
        throw "Test 5B Setup Failed: PID fixture file is empty."
    }

    $pidTokens = $rawContent.Trim().Split(',') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    foreach ($tok in $pidTokens) {
        $val = 0
        if ([int]::TryParse($tok.Trim(), [ref]$val) -and $val -gt 0 -and -not $candidatePids.Contains($val)) {
            $candidatePids.Add($val)
            try { $capturedHandles.Add([System.Diagnostics.Process]::GetProcessById($val)) } catch { }
        }
    }

    $setupSucceeded = ($candidatePids.Count -ge 2)
    if (-not $setupSucceeded) {
        throw "Test 5B Setup Failed: Incomplete fixture; expected at least 2 distinct PIDs."
    }

    # 3. Await runner task and assert TreeCleanupUnverifiedException is thrown via CLR unwrapping
    try {
        $execResult = $runnerTask.GetAwaiter().GetResult()
        throw "Test 5B Failed: Runner did not throw exception on simulated taskkill failure."
    } catch {
        $currEx = $_.Exception
        $depth = 0
        while ($null -ne $currEx -and $depth -lt 10) {
            if ($currEx -is [System.AggregateException] -and $currEx.InnerExceptions.Count -gt 0) {
                $currEx = $currEx.InnerExceptions[0]
            } elseif ($null -ne $currEx.InnerException) {
                $currEx = $currEx.InnerException
            } else {
                break
            }
            $depth++
        }

        if ($currEx -is [CodexHarness.TreeCleanupUnverifiedException]) {
            $threwTreeCleanupUnverified = $true
            Write-Output "Test 5B Verified: TreeCleanupUnverifiedException correctly thrown and unwrapped via CLR."
        } else {
            throw "Test 5B Failed: Exception was '$($currEx.GetType().FullName)', expected CodexHarness.TreeCleanupUnverifiedException. Message: $($currEx.Message)"
        }
    }

} catch {
    $testFailure = $_
} finally {
    $cleanupErrors = [System.Collections.Generic.List[string]]::new()
    $swCleanup = [System.Diagnostics.Stopwatch]::StartNew()
    $cleanupBudgetMs = 3000
    $cleanupReserveMs = 750
    $authoritativeSubdeadlineMs = $cleanupBudgetMs - $cleanupReserveMs # 2250 ms
    $authoritativeRootSuccess5b = $false

    # 1. Authoritative phase: terminate captured root via Invoke-TestBoundedTaskkill first bounded strictly by authoritative subdeadline (2250 ms)
    if ($capturedHandles.Count -gt 0 -and $null -ne $capturedHandles[0]) {
        $rootProc = $capturedHandles[0]
        $rootExited = $false
        try { $rootExited = $rootProc.HasExited } catch { $rootExited = $true }
        if (-not $rootExited) {
            $remAuthWait = $authoritativeSubdeadlineMs - [int]$swCleanup.ElapsedMilliseconds
            if ($remAuthWait -gt 0) {
                $tkRes = Invoke-TestBoundedTaskkill -ProcessId $rootProc.Id -Stopwatch $swCleanup -AuthoritativeSubdeadlineMs $authoritativeSubdeadlineMs -TotalBudgetMs $cleanupBudgetMs -IncludeTree $true
                if ($tkRes.Success) {
                    $remRootWait = $authoritativeSubdeadlineMs - [int]$swCleanup.ElapsedMilliseconds
                    if ($remRootWait -gt 0) {
                        try {
                            if ($rootProc.WaitForExit($remRootWait) -or $rootProc.HasExited) {
                                $authoritativeRootSuccess5b = $true
                            }
                        } catch { $authoritativeRootSuccess5b = $true }
                    }
                } else {
                    $cleanupErrors.Add("TreeCleanupUnverified: Authoritative root taskkill failed: $($tkRes.ErrorMessage)")
                }
            } else {
                $cleanupErrors.Add("TreeCleanupUnverified: Authoritative subdeadline exhausted before root taskkill.")
            }
        } else {
            $authoritativeRootSuccess5b = $true
        }
    }

    # If authoritative taskkill cannot complete with exit 0 before the subdeadline, immediately record TreeCleanupUnverified
    # and transition immediately to root emergency mitigation using reserve
    if (-not $authoritativeRootSuccess5b) {
        if (-not ($cleanupErrors -join "; " -match "TreeCleanupUnverified")) {
            $cleanupErrors.Add("TreeCleanupUnverified: Root taskkill did not complete with exit 0 before authoritative subdeadline.")
        }
    }

    # 2. Candidate cleanup: use bounded helper only while authoritative time remains; otherwise emergency mitigation
    for ($i = 0; $i -lt $candidatePids.Count; $i++) {
        $pId = $candidatePids[$i]
        $pHandle = if ($i -lt $capturedHandles.Count) { $capturedHandles[$i] } else { $null }

        $alreadyExited = $false
        if ($null -ne $pHandle) { try { $alreadyExited = $pHandle.HasExited } catch { $alreadyExited = $true } }

        if (-not $alreadyExited) {
            $remAuth = $authoritativeSubdeadlineMs - [int]$swCleanup.ElapsedMilliseconds
            if ($authoritativeRootSuccess5b -and $remAuth -gt 0) {
                $candRes = Invoke-TestBoundedTaskkill -ProcessId $pId -Stopwatch $swCleanup -AuthoritativeSubdeadlineMs $authoritativeSubdeadlineMs -TotalBudgetMs $cleanupBudgetMs -IncludeTree $false
                if (-not $candRes.Success) {
                    # Fallback to emergency mitigation within global budget
                    if ($null -ne $pHandle) {
                        try { $pHandle.Kill($true) } catch { try { $pHandle.Kill() } catch { } }
                    }
                    try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
                }
            } else {
                # Emergency mitigation within global 3000 ms budget using reserve
                if ($null -ne $pHandle) {
                    try { $pHandle.Kill($true) } catch { try { $pHandle.Kill() } catch { } }
                }
                try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
            }
        }
    }

    # 3. Bounded wait and affirmative zero-survivor assertion within single remaining reserve (up to 3000 ms global budget)
    for ($i = 0; $i -lt $candidatePids.Count; $i++) {
        $pId = $candidatePids[$i]
        $pHandle = if ($i -lt $capturedHandles.Count) { $capturedHandles[$i] } else { $null }

        $remWait = $cleanupBudgetMs - [int]$swCleanup.ElapsedMilliseconds
        if ($remWait -gt 0) {
            if ($null -ne $pHandle) {
                try { $null = $pHandle.WaitForExit($remWait) } catch { }
                try { $pHandle.Dispose() } catch { }
            }
        }

        $remaining = Get-Process -Id $pId -ErrorAction SilentlyContinue
        if ($null -ne $remaining) {
            try { $remaining.Kill($true) } catch { try { $remaining.Kill() } catch { } }
            try { Stop-Process -Id $pId -Force -ErrorAction SilentlyContinue } catch { }
            $remaining2 = Get-Process -Id $pId -ErrorAction SilentlyContinue
            if ($null -ne $remaining2) {
                $cleanupErrors.Add("TreeCleanupUnverified: Process $pId remains alive after termination attempts.")
            }
        }
    }

    # 4. Hardened sandbox directory deletion
    if (Test-Path -LiteralPath $test5bDir) {
        $canDelete5b = $true
        if (-not $test5bDir.StartsWith($sandboxesBase, [System.StringComparison]::OrdinalIgnoreCase) -or $test5bDir -eq $sandboxesBase.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
            $cleanupErrors.Add("Security Violation: Test 5B sandbox escapes runtime base: $test5bDir. Refusing recursive delete.")
            $canDelete5b = $false
        }
        if (-not (Test-Path -LiteralPath $ownerMarker5b -PathType Leaf)) {
            $cleanupErrors.Add("Security Violation: Test 5B ownership marker missing. Refusing recursive delete.")
            $canDelete5b = $false
        } else {
            $mContent = Get-Content -Raw -LiteralPath $ownerMarker5b | ConvertFrom-Json
            if ($mContent.runGuid -ne $test5bGuid) {
                $cleanupErrors.Add("Security Violation: Test 5B ownership marker mismatch. Refusing recursive delete.")
                $canDelete5b = $false
            }
        }

        $dInfo5b = [System.IO.DirectoryInfo]::new($test5bDir)
        if ($dInfo5b.Exists -and ($dInfo5b.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            $cleanupErrors.Add("Security Violation: Test 5B directory is a reparse point. Refusing recursive delete.")
            $canDelete5b = $false
        }
        $anc5b = $dInfo5b.Parent
        while ($anc5b -and $anc5b.FullName.Length -ge $RepoRoot.Length) {
            if ($anc5b.Exists -and ($anc5b.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                $cleanupErrors.Add("Security Violation: Reparse point in Test 5B ancestor $($anc5b.FullName). Refusing recursive delete.")
                $canDelete5b = $false
                break
            }
            $anc5b = $anc5b.Parent
        }

        if ($canDelete5b) {
            try {
                Remove-Item -LiteralPath $test5bDir -Recurse -Force -ErrorAction Stop
                if (Test-Path -LiteralPath $test5bDir) { throw "Directory still exists after Remove-Item." }
            } catch {
                $cleanupErrors.Add("Failed to remove Test 5B directory: $_")
            }
        }
    }

    if ($cleanupErrors.Count -gt 0) {
        $cleanupErrMsg = "Test 5B Affirmative Cleanup Verification Failed: " + ($cleanupErrors -join "; ")
        if ($null -ne $testFailure) {
            throw "$($testFailure.Exception.Message) | $cleanupErrMsg"
        } else {
            throw $cleanupErrMsg
        }
    }

    if (-not $setupSucceeded) {
        if ($null -ne $testFailure) { throw $testFailure } else { throw "Test 5B Failed: Setup did not succeed." }
    }

    if ($null -ne $testFailure) { throw $testFailure }
}

Write-Output "Test Case 5B Passed: FailingTreeKiller correctly classified as TreeCleanupUnverifiedException via CLR unwrapping; live root killed via Invoke-TestBoundedTaskkill first, affirmative zero-survivor evidence verified."

# ==============================================================================
# Test Case 6: Add-Type Helper Exception Safety
# ==============================================================================
$psiInvalid = [System.Diagnostics.ProcessStartInfo]::new()
$psiInvalid.FileName = "non_existent_binary_for_test_12345.exe"
$threwExpected = $false
try {
    $null = [CodexHarness.NativeProcessRunner]::ExecuteProcessAsync($psiInvalid, $null, 5).GetAwaiter().GetResult()
} catch {
    $threwExpected = $true
}
if (-not $threwExpected) {
    throw "Test 6 Failed: NativeProcessRunner did not throw expected exception on invalid binary start."
}
Write-Output "Test Case 6 Passed: Helper exception safety verified."

Write-Output "ALL SHARED LAUNCHER CONCURRENT I/O TESTS PASSED (9/9 - Cases 0, 1A, 1B, 2, 3, 4, 5A, 5B, 6)."
```


---

## Step-by-Step Implementation Phases & Gate Governance

```
PREREQUISITE GATE: Assert-PowerShell7Prerequisite (pwsh.exe available, PSVersion >= 7, ArgumentList, WaitForExitAsync, and Add-Type probe)
  │
  ▼
PHASE 0: Baseline Snapshot, Full Creation Manifest & External Dynamic Audit Gate (Read-only workspace, driver staged in external temp GUID directory)
  │   - Implementation Manifest & Hash Pin: Outer orchestration consumes -ManifestPath pointing to the externally approved implementation manifest
  │     and -SchemaPath pointing to codex-implementation-manifest.schema.json, validates schema conformance via Test-Json -SchemaFile,
  │     asserts status == 'approved', asserts approved_by == 'user', asserts non-null approved_at_utc and approval_event_reference,
  │     verifies DateTimeOffset parse and UTC offset (Offset == 0), verifies manifest_id, schema_version, 116 items, 3000/2250/750/64 constraints,
  │     validates mandatory concrete source_plan_path and source_plan_sha256 fields, canonicalizes and verifies non-reparse ancestry,
  │     calls File.ReadAllBytes exactly once on source_plan_path, calculates SHA-256 directly on that byte buffer, validates against manifest
  │     source_plan_sha256 (64 hex, ordinal normalized comparison), decodes that same immutable buffer with strict UTF-8, and extracts controller
  │     fence from the in-memory line buffer (never rereading from disk).
  │   - Staged controller calls File.ReadAllBytes exactly once on source_plan_path, validates hash, decodes with strict UTF-8,
  │     and extracts driver fence strictly from in-memory lines using the deterministic line-based extractor.
  │   - Unique HTML marker boundaries: Driver surrounded by <!-- BEGIN_PHASE0_DRIVER_SCRIPT --> and Controller by <!-- BEGIN_PHASE0_CONTROLLER_SCRIPT -->;
  │     driver block placed before controller, and controller placed before outer orchestration; searches select earlier actual block.
  │   - Ancestor reparse validation: Before creating or deleting staging directory, canonicalizes OS temp and all ancestors, rejecting any reparse points.
  │   - Stage: implementation controller stages exact driver bytes in $osTemp\codex-phase0-<guid>\ via CreateDirectoryW fail-if-exists.
  │   - Toolhelp32 Process Tree Snapshot: Pure C# delegate code on Task worker via Add-Type; PowerShell never runs on the worker.
  │     Inspects Marshal.GetLastWin32Error() on false returns, accepts only ERROR_NO_MORE_FILES=18 as normal completion, discards partial PIDs on error,
  │     disposes snapshot handle in finally, builds parent-child map, caps descendant closure at 64, requires completion within authoritative subdeadline,
  │     and snapshot failure is never treated as empty.
  │   - Universal 3000 ms Global Cleanup Deadline with Mandatory 750 ms Reserve: Authoritative phases (snapshot and taskkill) bounded strictly
  │     by authoritative subdeadline (TotalBudgetMs 3000 ms - ReserveEmergencyMs 750 ms = 2250 ms); lingering taskkill helper waited on only
  │     until the 2250 ms authoritative subdeadline, never into the 750 ms reserve. At subdeadline issues immediate Kill(true), records helper
  │     unverified if not exited, and transitions immediately to root emergency mitigation using reserve.
  │   - Universal Emergency Mitigation: ALWAYS attempts Kill(entireProcessTree: true) on original live root handle bounded by remaining global deadline;
  │     NEVER guards mitigation with a remaining-time condition that can skip it; if global deadline is already unexpectedly exhausted, issues immediate
  │     non-waiting Kill(true) in a last best-effort statement and still throws TreeCleanupUnverified.
  │   - Affirmatively checks within remaining reserve that root process AND every captured descendant PID are completely gone.
  │   - Only after mitigation throws distinct TreeCleanupUnverified preserving primary failure and survivor list. Any authoritative failure remains
  │     TreeCleanupUnverified even if emergency mitigation killed everything. No possibly live process is merely disposed.
  │   - True global cleanup deadline everywhere: single Stopwatch budget (total 3000 ms, 750 ms emergency reserve, 2250 ms authoritative subdeadline),
  │     never Math.Max or minimum wait.
  │   - Parse-correct PowerShell try/finally Dispose across driver execution and streams; zero C#-style using blocks; full AST parse-auditing.
  │   - Pre-status & post-status byte-for-byte raw byte comparison using unary comma carrier (non-null byte[0] on clean repos).
  │   - Parse porcelain v2 via separate UTF-8 decoding; deep baseline dirty/untracked rehash and type invariance checks.
  │   - Generate authoritative exhaustive creation manifest (116 items: 109 declarative + 5 runtime owned + 2 dynamic).
  │   - Pre-collision check: verify no intended target pre-exists; audit all ancestor directories for reparse points.
  │   - Reparse point check on runtime/audit/ itself and marker file before reading or writing.
  │   - Fixed 10-space boundary parsing for git porcelain v2 unmerged records without whitespace splitting on paths.
  │   - Exclusive per-run GUID outputs (intended-creation-manifest-<guid>.json and phase0-baseline-<guid>.json) via FileMode.CreateNew.
  │   - Cleanup refuses deletion if containment, marker, or reparse validation fails.
  ▼
PHASE 1: Root Harness Assets, Config Scaffolding, Absolute Hooks & Trust Setup
  │   - Immediate pre-check: verify non-existence and ancestor reparse integrity before creating each file.
  │   - Enforces Parser zero-error acceptance ([System.Management.Automation.Language.Parser]::ParseFile) on all generated ps1/psm1 files.
  │   - Creates AGENTS.md, docs/CODEX-HARNESS.md, docs/CODEX-PORTING-GUIDE.md, .codex/config.toml, .codex/requirements.template.toml, .codex/schemas/*, absolute pwsh hooks.
  │   - Documents interactive project trust launch & /hooks review; verifies config loads.
  │   - GATE: codex --strict-config PASS & profile-resolution PASS via pwsh.
  ▼
PHASE 2: Shared Process Launcher, C# Async Helper with Test Seam, Resolver Module, Adapters, TOML Serializer & Test Broker (.agents/scripts/*)
  │   - Immediate pre-check before creating each script; Parser zero-error acceptance on all scripts/modules.
  │   - Creates ProcessRunnerHelper.cs (.NET C# native async I/O helper with #nullable enable, NativeFileSystem.CreateDirectoryFailIfExists,
  │     TreeCleanupUnverifiedException, ProcessObserverSetupException, public ExecuteProcessAsync without observer, internal ITreeKiller seam,
  │     NativeProcessRunnerTestShim, canonical System32 taskkill, single global Stopwatch budget (total 3000 ms, 750 ms emergency reserve) without Math.Max,
  │     unconditional emergency root kill, and bounded stream drains).
  │   - Creates CodexLauncherResolver.psm1 (side-effect-free module with pure AST allowlist, zero process starts).
  │   - MANDATORY GATE: Compile-only acceptance test gate (Case 0 via Add-Type).
  │   - Creates invoke-codex-process.ps1 importing CodexLauncherResolver.psm1 and loading C# helper.
  │   - Creates orchestrate-role.ps1, test-broker.ps1, toml-serializer.ps1.
  │   - MANDATORY GATE: Full concurrent I/O test suite (9 of 9: Cases 0, 1A, 1B, 2, 3, 4, 5A, 5B, 6) with parse-correct Invoke-TestBoundedTaskkill helper,
  │     taskkill helper subdeadline wait bounding, and zero-error parser compliance across all variable interpolations before colons ($($ProcessId):).
  ▼
PHASE 3: Custom Agent Soft-Policy Layer (.codex/agents/*.toml - 19 roles)
  │   - Immediate pre-check before creating each role file.
  │   - Authors all 19 .codex/agents/*.toml role definitions.
  │   - MANDATORY EXIT GATE: Windows Command Line Ceiling Audit (all 19 roles <= 24,576 chars).
  │   - MANDATORY EXIT GATE: Full Round-Trip Untruncated Gate for 16KB+ instructions.
  │   - HARD GATE: Zero role execution in Phase 4/5/6 permitted until this exit gate passes.
  ▼
PHASE 4: 41-Skill Synchronization & Dual-Vendor Adaptation (.agents/skills/*)
  │   - Immediate pre-check before creating each skill directory/file.
  │   - Synchronizes 29 Direct-Sync skills and authors 12 Dual-Vendor Adapted skills (including workflow-author and t2-escalation).
  │   - Enforces exact source/destination set equality: 41 skills in .claude/skills == 41 skills in .agents/skills.
  ▼
PHASE 5: Cross-Vendor Critic Adapter & agy Probing (.agents/scripts/invoke-claude-judge.ps1)
  │   - Creates invoke-claude-judge.ps1 adapting Codex judging to Claude critic via agy; passes Parser zero-error acceptance.
  │   - Validates JSON output conformance with .claude/schemas/judge-result.schema.json.
  ▼
PHASE 6: Level 1 Functional Parity Test Execution (tests/codex-parity/*)
  │   - Executes test-codex-launcher.ps1 (verifying 9 of 9 launcher cases), test-orchestration-adapter.ps1, test-broker.ps1, test-broker-probe.ps1, test-codex-hooks.ps1 via pwsh.
  ▼
  ├── LEVEL 1 CERTIFICATION: Functional-Project Readiness [PASS]
  │
  ▼
PHASE 7: Managed Level 2 Staging, Sentinel Validation & Administrative Activation Gate
  │   - Provision two isolated Codex homes: outer (elevated + valid local snapshot-isolated) & inner.
  │   - Confirm checkout trust state consistently in both homes via [projects."<valCheckout>"] trust_level = "trusted".
  │   - Plant syntactically valid sacrificial sentinels (.codex/config.toml, .claude/settings.json, AGENTS.md, CLAUDE.md, docs/PLAN-CONTRACT.md);
  │     sacrificial .codex/config.toml contains harmless supported config and sentinel comment with ZERO permission keys
  │     and ZERO sandbox_mode or approval_policy keys, keeping no overlapping permission keys.
  │   - Permission-Profile Differential with installed Codex-compatible explicit -P in both runs:
  │     Inner CODEX_HOME config defines only [permissions.snapshot-isolated] extends = ":workspace" using official schema;
  │     Run A uses built-in -P :read-only (denies write with bounded CLR unwrap emitting exactly one JSON record with target,
  │     isTerminatingDenial true, exact access-denied code, exits 13, and baseline hash 100% byte-identical);
  │     Run B uses -P snapshot-isolated (permits write with MUTATED_BY_INNER_PROFILE);
  │     nested wrapper requires a nonempty exact ExpectedInnerProfile, Run A passes/asserts :read-only exact argv, and Run B/positive control/protected attacks pass/assert snapshot-isolated exact argv;
  │   - Evaluate Axis A: true outer-to-inner wrapper chain with structured argv, process-local CODEX_HOME;
  │     nested wrapper enforces canonical taskkill path, non-reparse checks, bounded process and stream completion;
  │     when overrun occurs, invokes verified tree kill using C# Toolhelp32 snapshot (with ERROR_NO_MORE_FILES error check),
  │     single 3000 ms budget (750 ms emergency reserve, 2250 ms authoritative subdeadline), taskkill helper waited on only
  │     until authoritative subdeadline, capped descendants (64), universal emergency mitigation on live root without skip guard,
  │     affirmative root/descendant checks, emits structured JSON cleanup result, reports surviving PIDs, and classifies distinctly
  │     as TreeCleanupUnverified exit 125;
  │     wrapper finally ensures live process invokes verified tree kill before Dispose;
  │     Positive control mutates unprotected sentinel via wrapper chain with verified exit 0, JSON status MUTATED, and file content;
  │     Parent pre-evaluation validates exactly 5 unique records matching expected paths by ordinal set equality;
  │     Per-target denial requires verified exact exit 13, single JSON result, target match, status DENIED,
  │     terminal exception limited strictly to UnauthorizedAccessException or IOException with exact access-denied Win32/HRESULT code without regex,
  │     and target hash 100% byte-identical;
  │   - Evaluate Axis B: bounded outside HTTPS connection response; inside diagnostic command exit 0 without timeout;
  │     principal validated strictly against supplied AdminApprovedPrincipalAllowlist with PrincipalEvidenceReference;
  │     reports NOT VERIFIED if parameters missing or any prerequisite fails;
  │   - Managed profile exclusion 2-run differential test:
  │     Run 1 without --include-managed-config creates and verifies GUID-owned unprotected sentinel write through snapshot-isolated,
  │     verifies exact content and hash, and cleans up sentinel;
  │     Run 2 with --include-managed-config rejects snapshot-isolated before payload and sentinel remains absent/unmutated;
  │   - Hardened cleanup: validates canonical validation-checkouts containment, verifies run GUID ownership marker,
  │     checks ancestor reparse points, deletes only owned checkout, explicitly refuses deletion on validation failure.
  │   - Conditional hash-guarded rollback.
  ▼
FINAL CERTIFICATION: Level 2 Managed System Parity [Axis A: PASS, Axis B: PASS / NOT VERIFIED, Managed Exclusion: PASS]
```

---

## End-to-End Acceptance & Verification Matrix

### Tier 1: Functional-Project Readiness Matrix

| # | Acceptance Smoke Test | Test Script / Fixture | Scope & Invariant Verified |
|---|---|---|---|
| 1 | **Strict Config & TOML Structure** | `test-strict-config.ps1` | Validates `codex --strict-config` in trusted test project. Asserts top-level keys (`sandbox_mode`, `approval_policy`, `web_search`) precede tables and are not nested. Asserts Parser zero-error acceptance on all generated scripts. |
| 2 | **Active `snapshot-isolated` Profile Resolution** | `test-strict-config.ps1` | Verifies `snapshot-isolated` is defined in `.codex/config.toml` with `extends = ":workspace"` and `network.enabled = false`. Executes `codex sandbox -P snapshot-isolated -C <snapshot> -- pwsh.exe -NoProfile -Command Write-Output PROFILE_OK` via shared launcher and asserts exit 0 and `PROFILE_OK`. |
| 3 | **Interactive Project & Hook Trust Flow** | `test-strict-config.ps1` | Verifies interactive trust prompt approval flow and `/hooks` hash review; asserts `.codex/config.toml` loads successfully. |
| 4 | **Side-Effect-Free Resolver Module AST & Environment Safety** | `test-codex-launcher.ps1` | Statically parses `CodexLauncherResolver.psm1` AST with zero parser errors against explicit allowlist (8 commands including internal `Resolve-NpmShim`, 8 types, 3 static methods, 2 instance methods), proving zero process-launch or execution constructs. Imports module and executes `Resolve-CodexLauncher`, proving exact ordinal environment preservation, location invariance, and preference variable stability. Never dot-sources executable launcher. |
| 5 | **Direct Process Launcher C# Compilation & Async I/O Gate** | `test-codex-launcher.ps1` | Extracts `.agents/scripts/ProcessRunnerHelper.cs` and verifies compilation via `Add-Type` under pwsh 7 with `#nullable enable` directive verified. Verifies public `ExecuteProcessAsync` has no observer parameter, native binary preference, validated npm shim inspection to `node.exe` + `codex.js`, `ArgumentList` usage under PowerShell 7, native async stdout/stderr drains and stdin delivery, and passes all 9 concurrent I/O test cases (Cases 0, 1A, 1B, 2, 3, 4, 5A, 5B, 6). |
| 6 | **Mandatory Timeout Tree Cleanup & Failure Classification** | `test-codex-launcher.ps1` | Tests timeout tree cleanup: uses pure C# Toolhelp32 snapshot helper (with `ERROR_NO_MORE_FILES` check), requires canonical System32 `taskkill.exe /PID /T /F` exit code 0 within timeout and original process exit under a single 3000 ms budget (750 ms emergency reserve, 2250 ms authoritative subdeadline) with capped descendants (64) and zero Math.Max floor waits. In launcher Tests 5A and 5B, eliminates every synchronous PowerShell call-operator invocation of taskkill (`& taskkill`) across root, candidate, and survivor loops, utilizing the parse-correct `Invoke-TestBoundedTaskkill` helper with `ProcessStartInfo` (`UseShellExecute = false`, structured `ArgumentList`, redirected stdout/stderr). Authoritative root taskkill occurs first under 2250 ms subdeadline; lingering taskkill helper is waited on only until 2250 ms subdeadline, never into the 750 ms reserve. If exit 0 is not achieved before subdeadline, immediately issues `Kill(true)`, records helper unverified if not exited, enters emergency mitigation (`Kill(true)`/`Stop-Process`) within final 3000 ms global deadline, verifying root and captured PIDs while still classifying as `TreeCleanupUnverified`. Candidate cleanup uses bounded helper only while authoritative time remains; otherwise emergency mitigation. Case 5A spawns descendant with `WindowStyle Hidden`, terminates live captured root process via `Invoke-TestBoundedTaskkill` first, executes emergency mitigation unconditionally without skip guard, and asserts child and descendant PIDs are absent. Case 5B exercises taskkill failure classification via `NativeProcessRunnerTestShim` in a dedicated per-run GUID sandbox, requiring immediate handle tracking via internal observer seam, live root kill via `Invoke-TestBoundedTaskkill` first, incremental PID capture, bounded zero-survivor verification, CLR-only exception unwrapping, and separation of cleanup from classification. Refuses recursive delete on containment, marker, or reparse validation failure. |
| 7 | **Mutually Exclusive Environment Modes** | `test-codex-launcher.ps1` | Verifies `AuthenticatedRole` inherits host environment and allows credential authentication; verifies `IsolatedSandbox` requires `$CodexHome`, sets child `CODEX_HOME`, fails if credentials exist, and isolates execution. Verifies omitting mode throws error. |
| 8 | **TOML Serializer Integrity** | `test-toml-serializer.ps1` | Verifies TOML basic string escaping: quotes, backslashes, line breaks, Unicode, injection resistance, and immediate NUL byte rejection. |
| 9 | **Dash Stdin Prompt Delivery & Post-Phase 3 16KB+ Round-Trip** | `test-role-precedence.ps1` | Verifies role tasks pass via stdin with `-` prompt argument. Post-Phase 3 audit proves all 19 roles $\le 24,576$ characters. Proves full 16KB+ instructions for Orchestrator and Browser Validator arrive 100% untruncated and unaltered before any role execution runs. |
| 10 | **Dispatch Edges vs Chronological Chains** | `test-orchestration-adapter.ps1` | Verifies call stack state machine: asserts direct dispatches comply with `routing_edges`, and receipts match `expected_chain` across all 8 canonical fixtures. |
| 11 | **Writer Path Rejection & Success** | `test-trusted-writer.ps1` | Tests `trusted-writer.ps1` accepting `docs/plans/*.md` and `.design/prototypes/<slug>/*`; rejects `.codex/**`, `CLAUDE.md`, directory traversal `../`, and dependency manifests. |
| 12 | **Deterministic Non-LLM Test Broker** | `test-broker.ps1` | Tests execution of test scripts via shared launcher in `IsolatedSandbox` mode. Verifies synthetic Git initialization (`core.hooksPath=NUL`) and zero live `.git` leakage. |
| 13 | **Snapshot Filtering & Secret Exclusion** | `test-broker.ps1` | Tests snapshot copying uses tracked manifest + reviewed allowlist, excludes `.env*`, keys, db, runtime, and Photo Genie patterns, failing closed on sensitive matches. |
| 14 | **Completed Snapshot Preflight** | `test-broker.ps1` | Proves fail-closed profile check runs on actual completed snapshot using shared launcher in `IsolatedSandbox` mode before running catalog tests. |
| 15 | **Broker Snapshot Isolation & Probe** | `test-broker-probe.ps1` | Probes snapshot workspace isolation: asserts live workspace files are not modified during test runs, and test sandbox executes in an ephemeral directory. |

### Tier 2: Managed System Parity Matrix

| # | Acceptance Verification Gate | Test Script / Fixture | Scope & Invariant Verified |
|---|---|---|---|
| 16 | **Sacrificial Sentinel Immutability Gate (Axis A)** | `test-hard-fence-bypass.ps1` | Validates Axis A: Evaluates exact protected path write denial across all 5 protected targets (`.codex/config.toml`, `.claude/settings.json`, `AGENTS.md`, `CLAUDE.md`, `docs/PLAN-CONTRACT.md`) via true outer-to-inner wrapper execution chain in a disposable checkout. Parent asserts positive control passes on unprotected sentinel (`scratch/unprotected-sentinel.txt`), confirms exactly 5 target evaluations matching expected keys by ordinal set equality, asserts each write attempt exits with exact code 13, emits a single valid JSON record with target and `isTerminatingDenial: true`, classifies the failure strictly as `UnauthorizedAccessException` or `IOException` with exact access-denied HRESULT/Win32 error evidence without regex, and confirms all baseline file hashes are 100% byte-identical. |
| 17 | **Managed Profile Exclusion Gate** | `test-hard-fence-bypass.ps1` | Evaluates enterprise policy enforcement: In Run 1 (unmanaged), executes local `snapshot-isolated` profile without `--include-managed-config`, creates and verifies sacrificial sentinel write, validates content and hash, and cleans up sentinel. In Run 2 (managed), executes same profile with `--include-managed-config` incorporated; asserts command fails closed before payload execution with error matching profile exclusion signature, and proves sacrificial sentinel remains completely absent and unmutated. |
| 18 | **Elevated Isolation Diagnostic Certification (Axis B)** | `test-hard-fence-bypass.ps1` | Validates Axis B: Executes outside-network positive control verifying successful HTTPS request and response (`example.com`). Executes inside-sandbox diagnostic command querying `[System.Security.Principal.WindowsIdentity]::GetCurrent().Name` under `orchestrator-governed` profile with `--include-managed-config`. Requires command exits 0 without timeout. Asserts the actual running principal strictly matches an administrator-supplied allowlist (`AdminApprovedPrincipalAllowlist`) and references a concrete verification ticket (`PrincipalEvidenceReference`). If allowlist or evidence is missing, host is offline, or inside command fails, certifies Axis B strictly as `NOT VERIFIED`. Generic TCP socket errors and username regex matching are explicitly rejected as proof. |
| 19 | **Hardened Non-Recursive Rollback Gate** | `rollback.ps1` | Verifies rollback execution: Requires explicit `-InstallationId <guid>`, rejects default or automatic newest selection. Validates canonical path containment, checks all ancestor directories for reparse points, verifies current SHA-256 hashes against install-time manifest records, removes only unmodified created files, retains user-modified files, and removes empty directories from deepest to shallowest without `-Recurse`. |

---
## Verification Plan

### Automated Tests
Every automated verification command is executable directly via PowerShell 7 (`pwsh.exe`):

1. **Phase 0 Baseline Snapshot, Creation Manifest & Collision Audit (Governed by Approved Manifest)**:
   The outer implementation orchestration consumes `-ManifestPath` pointing to the externally approved implementation manifest (`codex-implementation-manifest.json`) and `-SchemaPath` pointing to `codex-implementation-manifest.schema.json`. It canonicalizes both paths, verifies that neither the files nor any ancestors are reparse points, reads exact bytes of both files, validates manifest JSON schema conformance using PowerShell `Test-Json -SchemaFile $canonicalSchema`, captures validation failures fail-closed, asserts status `approved`, asserts `approved_by` equals `user`, asserts non-null `approved_at_utc` and `approval_event_reference`, verifies `approved_at_utc` via `[System.DateTimeOffset]::TryParse` and confirms `$parsedDto.Offset -eq [System.TimeSpan]::Zero` (strictly UTC), checks exact constants (`manifest_id`, `schema_version`, `116` items, `3000/2250/750/64` constraints), validates mandatory concrete `source_plan_path` and `source_plan_sha256` fields, eliminates TOCTOU by calling `[System.IO.File]::ReadAllBytes` exactly once on `source_plan_path`, calculates the SHA-256 directly over that pinned buffer, validates hash equality, decodes that same buffer with strict UTF-8, extracts the controller fence strictly from the in-memory line buffer using the deterministic line-based extractor (never rereading from disk), stages the controller to an exclusive temp path, and invokes `pwsh` with `-NoProfile -File <recorded absolute controller path> -SourcePlanPath <plan> -ExpectedSourcePlanSha256 <sha>` using `ProcessStartInfo.ArgumentList`. It captures bounded exit/stdout/stderr using a verified single-Stopwatch tree kill watchdog powered by the C# Toolhelp32 snapshot helper (with `ERROR_NO_MORE_FILES` check) with universal emergency mitigation without skip guards, taskkill helper subdeadline bounding (waited on only until 2250 ms subdeadline, never into 750 ms reserve; immediate Kill(true) and unverified recording at subdeadline), capped descendants (64), single 3000 ms budget (750 ms emergency reserve, 2250 ms authoritative subdeadline), and zero Math.Max waits, requires exit 0 and structured PASS (`Phase 0 Audit Complete`), and performs owned cleanup with refusal on validation failure:

   ```powershell
   # Implementation Orchestration Invocation Gate for Phase 0
   [CmdletBinding()]
   param(
       [Parameter(Mandatory = $true)]
       [string]$ManifestPath,

       [Parameter(Mandatory = $true)]
       [string]$SchemaPath
   )

   $ErrorActionPreference = 'Stop'
   $canonicalRepo = "H:\CommandCenter\orchestrator"

   # 1. Canonicalize explicit SchemaPath and verify leaf existence & non-reparse ancestry
   if ([string]::IsNullOrWhiteSpace($SchemaPath)) {
       throw "Fail-closed: Mandatory parameter -SchemaPath is empty."
   }
   $canonicalSchema = [System.IO.Path]::GetFullPath($SchemaPath)
   if (-not (Test-Path -LiteralPath $canonicalSchema -PathType Leaf)) {
       throw "Fail-closed: Schema file does not exist as a regular file: $canonicalSchema"
   }
   $schemaFi = [System.IO.FileInfo]::new($canonicalSchema)
   if ($schemaFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
       throw "Security violation: SchemaPath is a reparse point: $canonicalSchema"
   }
   $sAnc = $schemaFi.Directory
   while ($null -ne $sAnc) {
       if ($sAnc.Exists -and ($sAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
           throw "Security violation: Reparse point detected in SchemaPath ancestor: $($sAnc.FullName)"
       }
       $sAnc = $sAnc.Parent
   }

   # 2. Canonicalize explicit ManifestPath and verify leaf existence & non-reparse ancestry
   if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
       throw "Fail-closed: Mandatory parameter -ManifestPath is empty."
   }
   $canonicalManifest = [System.IO.Path]::GetFullPath($ManifestPath)
   if (-not (Test-Path -LiteralPath $canonicalManifest -PathType Leaf)) {
       throw "Fail-closed: Manifest does not exist as a regular file: $canonicalManifest. Searching or falling back to previous UUID plans is strictly forbidden."
   }
   $manifestFi = [System.IO.FileInfo]::new($canonicalManifest)
   if ($manifestFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
       throw "Security violation: ManifestPath is a reparse point: $canonicalManifest"
   }
   $mAnc = $manifestFi.Directory
   while ($null -ne $mAnc) {
       if ($mAnc.Exists -and ($mAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
           throw "Security violation: Reparse point detected in ManifestPath ancestor: $($mAnc.FullName)"
       }
       $mAnc = $mAnc.Parent
   }

   # 3. Read exact bytes of schema and manifest
   $schemaBytes = [System.IO.File]::ReadAllBytes($canonicalSchema)
   $manifestBytes = [System.IO.File]::ReadAllBytes($canonicalManifest)

   $utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
   $schemaRaw = $utf8Strict.GetString($schemaBytes)
   $manifestRaw = $utf8Strict.GetString($manifestBytes)

   # 4. Validate manifest JSON against schema using Test-Json -SchemaFile
   try {
       $jsonValid = Test-Json -Json $manifestRaw -SchemaFile $canonicalSchema -ErrorAction Stop
       if (-not $jsonValid) {
           throw "Test-Json returned false for manifest against schema: $canonicalSchema"
       }
   } catch {
       throw "Fail-closed: Manifest schema validation failure: $($_.Exception.Message)"
   }

   # Strict JSON DOM inspection for status and raw approved_at_utc timestamp gate
   $jsonDoc = [System.Text.Json.JsonDocument]::Parse([string]$manifestRaw)
   try {
       $root = $jsonDoc.RootElement
       [System.Text.Json.JsonElement]$statusProp = [System.Text.Json.JsonElement]::new()
       if (-not $root.TryGetProperty("status", [ref]$statusProp)) {
           throw "Fail-closed: Manifest missing mandatory 'status' property."
       }
       $rawStatus = $statusProp.GetString()

       [System.Text.Json.JsonElement]$approvedAtProp = [System.Text.Json.JsonElement]::new()
       if (-not $root.TryGetProperty("approved_at_utc", [ref]$approvedAtProp)) {
           throw "Fail-closed: Manifest missing mandatory 'approved_at_utc' property."
       }

       if ($rawStatus -eq "pending_user_approval") {
           if ($approvedAtProp.ValueKind -ne [System.Text.Json.JsonValueKind]::Null) {
               throw "Fail-closed: Manifest with status 'pending_user_approval' requires JSON null for 'approved_at_utc'."
           }
       } elseif ($rawStatus -eq "approved") {
           if ($approvedAtProp.ValueKind -ne [System.Text.Json.JsonValueKind]::String) {
               throw "Fail-closed: Approved manifest requires JSON string for 'approved_at_utc'."
           }
           $rawApprovedAt = $approvedAtProp.GetString()
           if ([string]::IsNullOrWhiteSpace($rawApprovedAt)) {
               throw "Fail-closed: Manifest 'approved_at_utc' cannot be empty or whitespace."
           }
           if ($rawApprovedAt.EndsWith('-00:00', [System.StringComparison]::Ordinal)) {
               throw "Fail-closed: Manifest 'approved_at_utc' explicitly rejects '-00:00'."
           }
           if (-not ($rawApprovedAt.EndsWith('Z', [System.StringComparison]::Ordinal) -or $rawApprovedAt.EndsWith('+00:00', [System.StringComparison]::Ordinal))) {
               throw "Fail-closed: Manifest 'approved_at_utc' must end with ordinal 'Z' or '+00:00' (no nonzero offset or missing zone allowed): $rawApprovedAt"
           }
           [System.DateTimeOffset]$parsedDto = [System.DateTimeOffset]::MinValue
           if (-not [System.DateTimeOffset]::TryParse(
               $rawApprovedAt,
               [System.Globalization.CultureInfo]::InvariantCulture,
               [System.Globalization.DateTimeStyles]::RoundtripKind,
               [ref]$parsedDto)) {
               throw "Fail-closed: Manifest 'approved_at_utc' could not be parsed as valid DateTimeOffset: $rawApprovedAt"
           }
           if ($parsedDto.Offset -ne [System.TimeSpan]::Zero) {
               throw "Fail-closed: Manifest 'approved_at_utc' must have UTC offset (+00:00 or Z), found offset: $($parsedDto.Offset)"
           }
       } else {
           throw "Fail-closed: Manifest status '$rawStatus' is unrecognized."
       }

       if ($rawStatus -ne "approved") {
           throw "Fail-closed: Manifest status is '$rawStatus', expected 'approved'. Implementation is pending explicit user approval and Phase 0 is strictly prohibited."
       }
   } finally {
       $jsonDoc.Dispose()
   }

   # Parse JSON object from strict UTF-8 string only after DOM gate validation
   $manifestObj = $manifestRaw | ConvertFrom-Json
   if (-not $manifestObj) {
       throw "Fail-closed: Manifest JSON could not be parsed: $canonicalManifest"
   }

   # 5. Explicitly check every security-critical const and invariant
   if ($manifestObj.manifest_id -ne "codex-cli-harness-migration-manifest-v34") {
       throw "Fail-closed: Manifest manifest_id is '$($manifestObj.manifest_id)', expected 'codex-cli-harness-migration-manifest-v34'."
   }
   if ($manifestObj.schema_version -ne "1.0.0") {
       throw "Fail-closed: Manifest schema_version is '$($manifestObj.schema_version)', expected '1.0.0'."
   }
   if ($manifestObj.approved_by -ne "user") {
       throw "Fail-closed: Manifest approved_by is '$($manifestObj.approved_by)', expected 'user'."
   }
   if ([string]::IsNullOrWhiteSpace($manifestObj.approval_event_reference)) {
       throw "Fail-closed: Manifest missing mandatory non-null 'approval_event_reference'."
   }

   # Check repo_root const
   $normalizedRepoRoot = [System.IO.Path]::GetFullPath($canonicalRepo)
   $manifestRepoRoot = [System.IO.Path]::GetFullPath($manifestObj.repo_root)
   if (-not [string]::Equals($manifestRepoRoot, $normalizedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
       throw "Fail-closed: Manifest repo_root is '$($manifestObj.repo_root)', expected '$canonicalRepo'."
   }

   # Check total_planned_items const (116)
   if ($manifestObj.total_planned_items -ne 116) {
       throw "Fail-closed: Manifest total_planned_items is $($manifestObj.total_planned_items), expected 116."
   }

   # Check execution_constraints consts (3000 / 2250 / 750 / 64 and powershell 7)
   $ec = $manifestObj.execution_constraints
   if ($null -eq $ec) {
       throw "Fail-closed: Manifest execution_constraints missing."
   }
   if ($ec.powershell_major_version -ne 7) {
       throw "Fail-closed: Manifest execution_constraints.powershell_major_version is $($ec.powershell_major_version), expected 7."
   }
   if ($ec.total_cleanup_budget_ms -ne 3000) {
       throw "Fail-closed: Manifest execution_constraints.total_cleanup_budget_ms is $($ec.total_cleanup_budget_ms), expected 3000."
   }
   if ($ec.authoritative_subdeadline_ms -ne 2250) {
       throw "Fail-closed: Manifest execution_constraints.authoritative_subdeadline_ms is $($ec.authoritative_subdeadline_ms), expected 2250."
   }
   if ($ec.emergency_reserve_ms -ne 750) {
       throw "Fail-closed: Manifest execution_constraints.emergency_reserve_ms is $($ec.emergency_reserve_ms), expected 750."
   }
   if ($ec.max_tracked_descendants -ne 64) {
       throw "Fail-closed: Manifest execution_constraints.max_tracked_descendants is $($ec.max_tracked_descendants), expected 64."
   }

   $sourcePlanPath = $manifestObj.source_plan_path
   $expectedSourcePlanSha256 = $manifestObj.source_plan_sha256

   if ([string]::IsNullOrWhiteSpace($sourcePlanPath)) {
       throw "Fail-closed: Manifest missing mandatory concrete field 'source_plan_path'."
   }
   if ([string]::IsNullOrWhiteSpace($expectedSourcePlanSha256) -or $expectedSourcePlanSha256 -notmatch '^[0-9a-fA-F]{64}$') {
       throw "Fail-closed: Manifest missing or invalid mandatory concrete field 'source_plan_sha256' (must be exactly 64 hex characters)."
   }

   $canonicalPlan = [System.IO.Path]::GetFullPath($sourcePlanPath)
   if (-not (Test-Path -LiteralPath $canonicalPlan -PathType Leaf)) {
       throw "Fail-closed: Manifest source_plan_path does not exist as a regular leaf file: $canonicalPlan."
   }
   $planFi = [System.IO.FileInfo]::new($canonicalPlan)
   if ($planFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
       throw "Security violation: source_plan_path is a reparse point: $canonicalPlan"
   }
   $pAnc = $planFi.Directory
   while ($null -ne $pAnc) {
       if ($pAnc.Exists -and ($pAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
           throw "Security violation: Reparse point detected in source_plan_path ancestor: $($pAnc.FullName)"
       }
       $pAnc = $pAnc.Parent
   }

   # TOCTOU Elimination: Call ReadAllBytes EXACTLY ONCE on SourcePlanPath, calculate hash directly over buffer, and pin
   $planBytes = [System.IO.File]::ReadAllBytes($canonicalPlan)
   $sha256 = [System.Security.Cryptography.SHA256]::Create()
   $actPlanShaBytes = $sha256.ComputeHash($planBytes)
   $actPlanSha = ($actPlanShaBytes | ForEach-Object { $_.ToString("x2") }) -join ""

   if (-not [string]::Equals($actPlanSha, $expectedSourcePlanSha256, [System.StringComparison]::OrdinalIgnoreCase)) {
       throw "Fail-closed: Pinned source plan bytes hash mismatch! Expected: $expectedSourcePlanSha256, Found: $actPlanSha. Stale-plan or TOCTOU condition detected."
   }

   # Decode immutable buffer with strict UTF-8 (zero disk reread)
   $utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
   $planText = $utf8Strict.GetString($planBytes)
   $planLines = $planText -split "`r?`n"

   # 6. Canonicalize OS temp root and check every ancestor for reparse points
   $rawTemp = [System.IO.Path]::GetTempPath()
   $osTemp = [System.IO.Path]::GetFullPath($rawTemp)
   if (-not $osTemp.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) {
       $osTemp += [System.IO.Path]::DirectorySeparatorChar
   }
   $tempDi = [System.IO.DirectoryInfo]::new($osTemp)
   if ($tempDi.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
       throw "Security violation: OS temp directory is a reparse point: $osTemp"
   }
   $tCur = $tempDi.Parent
   while ($null -ne $tCur) {
       if ($tCur.Exists -and ($tCur.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
           throw "Security violation: Reparse point detected in OS temp ancestor: $($tCur.FullName)"
       }
       $tCur = $tCur.Parent
   }

   $orchGuid = [System.Guid]::NewGuid().ToString('N')
   $tempControllerDir = [System.IO.Path]::GetFullPath((Join-Path $osTemp "codex-phase0-orch-$orchGuid"))
   $controllerMarkerFile = (Join-Path $tempControllerDir ".phase0-controller-owner.json")
   $stagedControllerPath = (Join-Path $tempControllerDir "invoke-phase0-controller.ps1")

   # 7. Deterministic Line-Based Extractor Operating Strictly on In-Memory Lines (Zero Regex, Zero Disk Reread)
   function Extract-MarkdownCodeFenceFromLines {
       [CmdletBinding()]
       param(
           [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
           [Parameter(Mandatory = $true)][string]$StartMarker,
           [Parameter(Mandatory = $true)][string]$EndMarker
       )

       $startIdx = -1
       for ($i = 0; $i -lt $Lines.Length; $i++) {
           if ($Lines[$i].Trim() -eq $StartMarker) {
               $startIdx = $i
               break
           }
       }
       if ($startIdx -eq -1) {
           throw "Fail-closed: Start marker '$StartMarker' not found in plan lines."
       }

       $endIdx = -1
       for ($i = $startIdx + 1; $i -lt $Lines.Length; $i++) {
           if ($Lines[$i].Trim() -eq $EndMarker) {
               $endIdx = $i
               break
           }
       }
       if ($endIdx -eq -1) {
           throw "Fail-closed: End marker '$EndMarker' not found after start marker in plan lines."
       }

       if ($endIdx -le $startIdx + 2) {
           throw "Fail-closed: Insufficient content between markers."
       }

       $fenceRegion = $Lines[($startIdx + 1)..($endIdx - 1)]

       if ($fenceRegion[0].Trim() -ne '```powershell') {
           throw "Fail-closed: First line inside marker region is '$($fenceRegion[0])', expected exactly '```powershell'."
       }
       if ($fenceRegion[-1].Trim() -ne '```') {
           throw "Fail-closed: Last line inside marker region is '$($fenceRegion[-1])', expected exactly '```'."
       }

       $interiorLines = $fenceRegion[1..($fenceRegion.Length - 2)]
       $extractedScript = $interiorLines -join [System.Environment]::NewLine

       $pTokens = $null
       $pErrors = $null
       $null = [System.Management.Automation.Language.Parser]::ParseInput($extractedScript, [ref]$pTokens, [ref]$pErrors)
       if ($pErrors -and $pErrors.Count -gt 0) {
           throw "Fail-closed: Extracted script failed PowerShell parser zero-error audit: $($pErrors -join '; ')"
       }

       return $extractedScript
   }

   # Extract exact controller source fence strictly from pinned in-memory lines
   $exactControllerText = Extract-MarkdownCodeFenceFromLines `
       -Lines $planLines `
       -StartMarker "<!-- BEGIN_PHASE0_CONTROLLER_SCRIPT -->" `
       -EndMarker "<!-- END_PHASE0_CONTROLLER_SCRIPT -->"

   # Load in-memory CreateDirectoryW
   if (-not ([System.Management.Automation.PSTypeName]'CodexPhase0Controller.StagingFs').Type) {
       $fsSrc = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
namespace CodexPhase0Controller {
    public static class StagingFs {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CreateDirectoryW(string lpPathName, IntPtr lpSecurityAttributes);
        public static bool CreateDirectoryFailIfExists(string path) {
            if (string.IsNullOrWhiteSpace(path)) throw new ArgumentNullException(nameof(path));
            string fullPath = Path.GetFullPath(path);
            if (!CreateDirectoryW(fullPath, IntPtr.Zero)) {
                int error = Marshal.GetLastWin32Error();
                throw new IOException($"CreateDirectoryW failed for '{fullPath}' with Win32 error code {error}.");
            }
            return true;
        }
    }
}
"@
       Add-Type -TypeDefinition $fsSrc -Language CSharp -ErrorAction Stop
   }

   # Load in-memory C# Windows Toolhelp32 Process Tree Snapshot Helper with Error-Checked Iteration
   $snapSrc = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace CodexHarnessSnapshot {
    public sealed class SnapshotResult {
        public bool Success { get; set; }
        public bool TimedOut { get; set; }
        public bool Overflow { get; set; }
        public int[] Pids { get; set; } = Array.Empty<int>();
        public string ErrorMessage { get; set; } = string.Empty;
    }

    public static class WindowsProcessTreeSnapshot {
        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int ERROR_NO_MORE_FILES = 18;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool CloseHandle(IntPtr hObject);

        public static SnapshotResult TakeDescendantSnapshot(int rootPid, int maxDescendants = 64) {
            var result = new SnapshotResult();
            IntPtr hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot == INVALID_HANDLE_VALUE) {
                int err = Marshal.GetLastWin32Error();
                result.Success = false;
                result.ErrorMessage = $"CreateToolhelp32Snapshot failed with Win32 error {err}.";
                return result;
            }

            try {
                var parentToChildren = new Dictionary<int, List<int>>();
                var pe = new PROCESSENTRY32W();
                pe.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32W));

                if (!Process32FirstW(hSnapshot, ref pe)) {
                    int err = Marshal.GetLastWin32Error();
                    if (err == ERROR_NO_MORE_FILES) {
                        result.Success = true;
                        result.Pids = Array.Empty<int>();
                        return result;
                    }
                    result.Success = false;
                    result.ErrorMessage = $"Process32FirstW failed with Win32 error {err}.";
                    return result;
                }

                bool hasMore;
                do {
                    int ppid = (int)pe.th32ParentProcessID;
                    int pid = (int)pe.th32ProcessID;
                    if (pid > 0 && ppid > 0 && pid != ppid) {
                        if (!parentToChildren.TryGetValue(ppid, out var children)) {
                            children = new List<int>();
                            parentToChildren[ppid] = children;
                        }
                        children.Add(pid);
                    }
                    hasMore = Process32NextW(hSnapshot, ref pe);
                } while (hasMore);

                int nextErr = Marshal.GetLastWin32Error();
                if (nextErr != ERROR_NO_MORE_FILES) {
                    result.Success = false;
                    result.Pids = Array.Empty<int>();
                    result.ErrorMessage = $"Process32NextW iteration failed with Win32 error {nextErr}.";
                    return result;
                }

                var descendants = new List<int>();
                var queue = new Queue<int>();
                queue.Enqueue(rootPid);

                while (queue.Count > 0) {
                    int current = queue.Dequeue();
                    if (parentToChildren.TryGetValue(current, out var children)) {
                        foreach (int childPid in children) {
                            if (!descendants.Contains(childPid)) {
                                if (descendants.Count >= maxDescendants) {
                                    result.Success = false;
                                    result.Overflow = true;
                                    result.Pids = descendants.ToArray();
                                    result.ErrorMessage = $"Descendant process count exceeded safe cap of {maxDescendants} for PID {rootPid}.";
                                    return result;
                                }
                                descendants.Add(childPid);
                                queue.Enqueue(childPid);
                            }
                        }
                    }
                }

                result.Success = true;
                result.Pids = descendants.ToArray();
                return result;
            } catch (Exception ex) {
                result.Success = false;
                result.Pids = Array.Empty<int>();
                result.ErrorMessage = $"Exception during Toolhelp32 snapshot: {ex.Message}";
                return result;
            } finally {
                CloseHandle(hSnapshot);
            }
        }

        public static SnapshotResult TakeDescendantSnapshotBounded(int rootPid, int timeoutMs, int maxDescendants = 64) {
            if (timeoutMs <= 0) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Snapshot timeout expired before execution ({timeoutMs} ms)."
                };
            }

            var task = Task.Run(() => TakeDescendantSnapshot(rootPid, maxDescendants));
            if (!task.Wait(timeoutMs)) {
                return new SnapshotResult {
                    Success = false,
                    TimedOut = true,
                    ErrorMessage = $"Descendant snapshot timed out after {timeoutMs} ms."
                };
            }

            return task.Result;
        }
    }
}
"@
   if (-not ([System.Management.Automation.PSTypeName]'CodexHarnessSnapshot.WindowsProcessTreeSnapshot').Type) {
       Add-Type -TypeDefinition $snapSrc -Language CSharp -ErrorAction Stop
   }

   # Hardened tree kill helper for outer orchestration watchdog with single Stopwatch 3000 ms budget (750 ms emergency reserve),
   # Toolhelp32 snapshot, authoritative subdeadline wait limit on taskkill helper, and universal mitigation without skip guards
   function Invoke-OrchVerifiedTreeKill(
       [int]$ProcessId,
       [System.Diagnostics.Process]$TargetProcess = $null,
       [int]$TotalBudgetMs = 3000,
       [int]$ReserveEmergencyMs = 750
   ) {
       $sw = [System.Diagnostics.Stopwatch]::StartNew()
       $authoritativeSubdeadlineMs = $TotalBudgetMs - $ReserveEmergencyMs # 2250 ms
       $maxTrackedDescendants = 64
       $descendantPids = [System.Collections.Generic.List[int]]::new()
       $primaryFailures = [System.Collections.Generic.List[string]]::new()

       # 1. Resolve canonical SystemRoot\System32\taskkill.exe
       $sysRoot = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
       if ([string]::IsNullOrWhiteSpace($sysRoot)) { $sysRoot = $env:SystemRoot; if (-not $sysRoot) { $sysRoot = "C:\Windows" } }
       $canonicalSys32 = [System.IO.Path]::GetFullPath((Join-Path $sysRoot "System32"))
       if (-not $canonicalSys32.EndsWith([System.IO.Path]::DirectorySeparatorChar.ToString())) { $canonicalSys32 += [System.IO.Path]::DirectorySeparatorChar }
       $canonicalTaskkill = [System.IO.Path]::GetFullPath((Join-Path $canonicalSys32 "taskkill.exe"))

       if (-not $canonicalTaskkill.StartsWith($canonicalSys32, [System.StringComparison]::OrdinalIgnoreCase)) {
           $primaryFailures.Add("taskkill path escapes canonical System32: $canonicalTaskkill")
       }
       $tkFi = [System.IO.FileInfo]::new($canonicalTaskkill)
       if (-not $tkFi.Exists -or ($tkFi.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
           $primaryFailures.Add("taskkill.exe missing or is a reparse point: $canonicalTaskkill")
       }
        $tkDir = $tkFi.Directory
        while ($tkDir -and $tkDir.FullName.Length -ge $sysRoot.Length) {
            if ($tkDir.Exists -and ($tkDir.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                $primaryFailures.Add("reparse point detected in taskkill ancestor: $($tkDir.FullName)")
                break
            }
            $tkDir = $tkDir.Parent
        }

        # 2. Bounded snapshot of known descendants via Toolhelp32 bounded by authoritative subdeadline
        $remSnap = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
        if ($remSnap -le 0) {
            $primaryFailures.Add("Cleanup budget exhausted before descendant snapshot.")
        } else {
            try {
                $snapRes = [CodexHarnessSnapshot.WindowsProcessTreeSnapshot]::TakeDescendantSnapshotBounded($ProcessId, $remSnap, $maxTrackedDescendants)
                if (-not $snapRes.Success) {
                    $primaryFailures.Add("Snapshot failed: $($snapRes.ErrorMessage)")
                }
                if ($null -ne $snapRes.Pids) {
                    foreach ($p in $snapRes.Pids) {
                        if ($p -gt 0 -and -not $descendantPids.Contains($p)) {
                            $descendantPids.Add([int]$p)
                        }
                    }
                }
            } catch {
                $primaryFailures.Add("Snapshot threw exception: $($_.Exception.Message)")
            }
        }

        # 3. Execute taskkill via structured ProcessStartInfo bounded by authoritative subdeadline
        $tkPsi = [System.Diagnostics.ProcessStartInfo]::new()
        $tkPsi.FileName = $canonicalTaskkill
        $tkPsi.UseShellExecute = $false
        $tkPsi.CreateNoWindow = $true
        $tkPsi.RedirectStandardOutput = $true
        $tkPsi.RedirectStandardError = $true
        $tkPsi.ArgumentList.Add("/PID")
        $tkPsi.ArgumentList.Add($ProcessId.ToString())
        $tkPsi.ArgumentList.Add("/T")
        $tkPsi.ArgumentList.Add("/F")

        $tkProc = $null
        $tkExitZero = $false

        try {
            $remTkStart = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
            if ($remTkStart -le 0) {
                $primaryFailures.Add("Cleanup budget exhausted before taskkill start.")
            } else {
                $tkProc = [System.Diagnostics.Process]::Start($tkPsi)
                if ($null -eq $tkProc) {
                    $primaryFailures.Add("Process.Start returned null for taskkill.exe.")
                } else {
                    try {
                        $outT = $tkProc.StandardOutput.ReadToEndAsync()
                        $errT = $tkProc.StandardError.ReadToEndAsync()
                        $remExit = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                        if ($remExit -le 0 -or -not $tkProc.WaitForExit($remExit)) {
                            try { $tkProc.Kill() } catch { }
                            $primaryFailures.Add("taskkill process did not exit within remaining budget for PID $($ProcessId).")
                        } else {
                            $remDrain = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                            if ($remDrain -le 0) {
                                $primaryFailures.Add("taskkill stream drain budget exhausted for PID $($ProcessId).")
                            } else {
                                $streams = [System.Threading.Tasks.Task]::WhenAll($outT, $errT)
                                if (-not $streams.Wait($remDrain)) {
                                    $primaryFailures.Add("taskkill streams failed to drain within remaining budget for PID $($ProcessId).")
                                } else {
                                    if ($tkProc.ExitCode -eq 0) {
                                        $tkExitZero = $true
                                    } else {
                                        $primaryFailures.Add("taskkill exited with code $($tkProc.ExitCode): $($errT.Result)")
                                    }
                                }
                            }
                        }
                    } finally {
                        # Taskkill helper process cleanup: may be waited on ONLY until 2250 ms authoritative subdeadline, never into 750 ms reserve.
                        # At subdeadline, issue immediate Kill(true), record helper unverified if not exited, and transition immediately to root emergency mitigation.
                        try {
                            if (-not $tkProc.HasExited) {
                                try { $tkProc.Kill($true) } catch { try { $tkProc.Kill() } catch { } }
                                $remW = $authoritativeSubdeadlineMs - [int]$sw.ElapsedMilliseconds
                                if ($remW -gt 0) { $null = $tkProc.WaitForExit($remW) }
                                if (-not $tkProc.HasExited) {
                                    try { $tkProc.Kill($true) } catch { }
                                    $primaryFailures.Add("taskkill helper process PID $($tkProc.Id) could not be verified exited before authoritative subdeadline.")
                                }
                            }
                        } catch {
                            $primaryFailures.Add("Exception during taskkill helper cleanup for PID $($ProcessId): $($_.Exception.Message)")
                        }
                        $tkProc.Dispose()
                    }
                }
            }
        } catch {
            $primaryFailures.Add("taskkill invocation threw exception: $($_.Exception.Message)")
        }

        # 4. Universal Emergency Mitigation: ALWAYS attempt emergency mitigation on original live root
        # NEVER guard mitigation with a remaining-time condition that can skip it!
        # If final global deadline is already unexpectedly exhausted, issue immediate non-waiting Kill(true) in a last best-effort statement.
        if ($null -ne $TargetProcess) {
            try {
                $isLive = $false
                try { $isLive = -not $TargetProcess.HasExited } catch { $isLive = $true }
                if ($isLive) {
                    $TargetProcess.Kill($true)
                }
            } catch { }
        } else {
            try {
                $rootP = [System.Diagnostics.Process]::GetProcessById($ProcessId)
                try {
                    $isLive = $false
                    try { $isLive = -not $rootP.HasExited } catch { $isLive = $true }
                    if ($isLive) {
                        $rootP.Kill($true)
                    }
                } finally {
                    $rootP.Dispose()
                }
            } catch { }
        }

        foreach ($dPid in $descendantPids) {
            try {
                $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                try {
                    $isLive = $false
                    try { $isLive = -not $dP.HasExited } catch { $isLive = $true }
                    if ($isLive) {
                        $dP.Kill()
                    }
                } finally {
                    $dP.Dispose()
                }
            } catch { }
        }

        # 5. Affirmative root and descendant exit checks strictly within remaining global reserve
        $rootExited = $false
        $remRootWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
        if ($remRootWait -gt 0) {
            if ($null -ne $TargetProcess) {
                try { $rootExited = $TargetProcess.WaitForExit($remRootWait) -or $TargetProcess.HasExited } catch { $rootExited = $true }
            } else {
                try {
                    $p = [System.Diagnostics.Process]::GetProcessById($ProcessId)
                    $rootExited = $p.WaitForExit($remRootWait) -or $p.HasExited
                    $p.Dispose()
                } catch { $rootExited = $true }
            }
        } else {
            if ($null -ne $TargetProcess) {
                try { $rootExited = $TargetProcess.HasExited } catch { $rootExited = $false }
            } else {
                try {
                    $p = [System.Diagnostics.Process]::GetProcessById($ProcessId)
                    $rootExited = $p.HasExited
                    $p.Dispose()
                } catch { $rootExited = $true }
            }
        }

        $survivors = [System.Collections.Generic.List[int]]::new()
        if (-not $rootExited) { $survivors.Add($ProcessId) }

        foreach ($dPid in $descendantPids) {
            $remChildWait = $TotalBudgetMs - [int]$sw.ElapsedMilliseconds
            $dExited = $false
            if ($remChildWait -gt 0) {
                try {
                    $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                    $dExited = $dP.WaitForExit($remChildWait) -or $dP.HasExited
                    $dP.Dispose()
                } catch {
                    $dExited = $true
                }
            } else {
                try {
                    $dP = [System.Diagnostics.Process]::GetProcessById($dPid)
                    $dExited = $dP.HasExited
                    $dP.Dispose()
                } catch { $dExited = $true }
            }
            if (-not $dExited) { $survivors.Add($dPid) }
        }

        $allGone = ($rootExited -and $survivors.Count -eq 0)

        # Any authoritative failure remains TreeCleanupUnverified even if emergency mitigation killed everything!
        if (-not ($tkExitZero -and $primaryFailures.Count -eq 0 -and $allGone)) {
            $cleanupSummary = [ordered]@{
                status = "TreeCleanupUnverified"
                processId = $ProcessId
                totalBudgetMs = $TotalBudgetMs
                reserveEmergencyMs = $ReserveEmergencyMs
                authoritativeSubdeadlineMs = $authoritativeSubdeadlineMs
                elapsedMs = [int]$sw.ElapsedMilliseconds
                taskkillExitZero = $tkExitZero
                primaryFailures = @($primaryFailures)
                fallbackKillTreeInvoked = $true
                rootExited = $rootExited
                knownDescendantCount = $descendantPids.Count
                knownSurvivorCount = $survivors.Count
                knownSurvivors = @($survivors)
            }
            $jsonSummary = ($cleanupSummary | ConvertTo-Json -Compress)
            throw "TreeCleanupUnverified: Orchestration watchdog tree kill unverified for PID $($ProcessId) within $TotalBudgetMs ms budget ($ReserveEmergencyMs ms reserve). Summary: $jsonSummary"
        }
    }

    try {
        $null = [CodexPhase0Controller.StagingFs]::CreateDirectoryFailIfExists($tempControllerDir)
        $markerPayload = [ordered]@{ owner = "Phase0Orchestrator"; guid = $orchGuid; stagedAtUtc = (Get-Date).ToUniversalTime().ToString('o') }
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes(($markerPayload | ConvertTo-Json))
        $mFs = [System.IO.FileStream]::new($controllerMarkerFile, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
        try { $mFs.Write($mBytes, 0, $mBytes.Length) } finally { $mFs.Dispose() }

        $ctrlBytes = [System.Text.Encoding]::UTF8.GetBytes($exactControllerText)
        $cFs = [System.IO.FileStream]::new($stagedControllerPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
        try { $cFs.Write($ctrlBytes, 0, $ctrlBytes.Length) } finally { $cFs.Dispose() }

        $expHash = (New-Object System.Security.Cryptography.SHA256Managed).ComputeHash($ctrlBytes)
        $expHashStr = ($expHash | ForEach-Object { $_.ToString("X2") }) -join ""
        $actHashStr = (Get-FileHash -LiteralPath $stagedControllerPath -Algorithm SHA256).Hash
        if (-not [string]::Equals($expHashStr, $actHashStr, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Fail-closed: Controller hash mismatch! Expected: $expHashStr, Found: $actHashStr"
        }

        $pwshExe = (Get-Command "pwsh.exe" -ErrorAction Stop).Source
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $pwshExe
        $psi.ArgumentList.Add("-NoProfile")
        $psi.ArgumentList.Add("-ExecutionPolicy")
        $psi.ArgumentList.Add("Bypass")
        $psi.ArgumentList.Add("-File")
        $psi.ArgumentList.Add($stagedControllerPath)
        $psi.ArgumentList.Add("-SourcePlanPath")
        $psi.ArgumentList.Add($canonicalPlan)
        $psi.ArgumentList.Add("-ExpectedSourcePlanSha256")
        $psi.ArgumentList.Add($expectedSourcePlanSha256)
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true

        $orchProc = [System.Diagnostics.Process]::Start($psi)
        if ($null -eq $orchProc) {
            throw "Failed to start Phase 0 controller process."
        }

        $swWatchdog = [System.Diagnostics.Stopwatch]::StartNew()
        $watchdogTimeoutMs = 90000

        try {
            $outTask = $orchProc.StandardOutput.ReadToEndAsync()
            $errTask = $orchProc.StandardError.ReadToEndAsync()

            $remExit = $watchdogTimeoutMs - [int]$swWatchdog.ElapsedMilliseconds
            if ($remExit -le 0 -or -not $orchProc.WaitForExit($remExit)) {
                Invoke-OrchVerifiedTreeKill -ProcessId $orchProc.Id -TargetProcess $orchProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
                throw "Phase 0 controller timed out after 90 seconds (process tree verified terminated)."
            }

            $remDrain = 5000 - [int]$swWatchdog.ElapsedMilliseconds
            if ($remDrain -le 0) {
                Invoke-OrchVerifiedTreeKill -ProcessId $orchProc.Id -TargetProcess $orchProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
                throw "Phase 0 controller stream drain budget exhausted."
            }
            $streamsTask = [System.Threading.Tasks.Task]::WhenAll($outTask, $errTask)
            if (-not $streamsTask.Wait($remDrain)) {
                Invoke-OrchVerifiedTreeKill -ProcessId $orchProc.Id -TargetProcess $orchProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
                throw "Phase 0 controller output streams failed to drain within remaining budget."
            }

            $stdOut = $outTask.Result
            $stdErr = $errTask.Result
            Write-Output $stdOut
            if ($orchProc.ExitCode -ne 0 -or $stdOut -notmatch "Phase 0 Audit Complete") {
                throw "Phase 0 gate failed: ExitCode=$($orchProc.ExitCode), Output did not match structured PASS: $stdErr"
            }
        } finally {
            if ($null -ne $orchProc) {
                $isLive = $false
                try { $isLive = -not $orchProc.HasExited } catch { $isLive = $false }
                if ($isLive) {
                    Invoke-OrchVerifiedTreeKill -ProcessId $orchProc.Id -TargetProcess $orchProc -TotalBudgetMs 3000 -ReserveEmergencyMs 750
                }
                $orchProc.Dispose()
            }
        }
    } finally {
        if (Test-Path -LiteralPath $tempControllerDir) {
            $canDel = $true
            $fullD = [System.IO.Path]::GetFullPath($tempControllerDir)
            if (-not $fullD.StartsWith($osTemp, [System.StringComparison]::OrdinalIgnoreCase) -or $fullD -eq $osTemp.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) {
                $canDel = $false
                throw "Cleanup Security Violation: Staged controller path escapes OS temp directory: $fullD. Refusing deletion."
            }
            if (-not (Test-Path -LiteralPath $controllerMarkerFile -PathType Leaf)) {
                $canDel = $false
                throw "Cleanup Security Violation: Ownership marker missing from controller temp directory: $controllerMarkerFile. Refusing deletion."
            } else {
                $mObj = Get-Content -Raw -LiteralPath $controllerMarkerFile | ConvertFrom-Json
                if ($mObj.guid -ne $orchGuid) {
                    $canDel = $false
                    throw "Cleanup Security Violation: Controller staging directory ownership marker mismatch. Refusing deletion."
                }
            }
            $dInf = [System.IO.DirectoryInfo]::new($fullD)
            if ($dInf.Exists -and ($dInf.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                $canDel = $false
                throw "Cleanup Security Violation: Controller staging directory is a reparse point: $fullD. Refusing deletion."
            }
            $dAnc = $dInf.Parent
            while ($null -ne $dAnc) {
                if ($dAnc.Exists -and ($dAnc.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                    $canDel = $false
                    throw "Cleanup Security Violation: Reparse point detected in controller staging ancestor: $($dAnc.FullName). Refusing deletion."
                }
                $dAnc = $dAnc.Parent
            }

            if ($canDel) {
                Remove-Item -LiteralPath $fullD -Recurse -Force -ErrorAction Stop
                Write-Output "Phase 0 Controller Staging Cleanup Complete: Deleted $fullD."
            }
        }
    }
    ```
2. **Static Schema, Parser Zero-Error Acceptance & Lint Validation**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/validate-codex.ps1
    ```
3. **Unified Process Launcher C# Native Async I/O Test Suite (All 9 Cases: Cases 0, 1A, 1B, 2, 3, 4, 5A, 5B, 6)**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-codex-launcher.ps1
    ```
4. **Deterministic TOML Serializer Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-toml-serializer.ps1
    ```
5. **Post-Phase 3 Command Line Ceiling Audit & 16KB+ Round-Trip Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-role-precedence.ps1
    ```
6. **Orchestration Adapter & Dynamic Role Graph Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-orchestration-adapter.ps1
    ```
7. **Trusted Writer Containment Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-trusted-writer.ps1
    ```
8. **Deterministic Test Broker & Preflight Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-broker.ps1
    ```
9. **Broker Snapshot Isolation Probe**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-broker-probe.ps1
    ```
10. **Codex Hooks Resolution & Path Traversal Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-codex-hooks.ps1
    ```
11. **Cross-Vendor `agy` Critic Adapter Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-claude-judge.ps1
    ```
12. **Strict Configuration & Active Profile Resolution**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-strict-config.ps1
    ```
13. **Dual-Home True Outer-to-Inner Wrapper Bypass, Axis A/B & Managed Profile Exclusion Gate**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-hard-fence-bypass.ps1
    ```
14. **Sacrificial Sentinel Exact-Path Write Denial Test Suite**:
    ```powershell
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-sentinel-validation.ps1
    ```
15. **Claude Harness Coexistence Regression Test Suite**:
    ```powershell
    # Preserves Claude's intended execution environment under Windows PowerShell 5.1
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/validate.ps1
    ```

### Manual Verification
1. **Interactive Project Trust Flow**:
   - Launch `codex` interactively in `H:\CommandCenter\orchestrator`.
   - Accept the interactive project trust prompt.
   - Run `/hooks` to inspect hook hashes.
   - Confirm `.codex/config.toml` is loaded and active.
2. **Level 2 Administrative Staging & Verification**:
   - In an elevated PowerShell 7 terminal, execute the staged deployment script to copy `.codex/requirements.template.toml` to `%ProgramData%\OpenAI\Codex\requirements.toml`.
   - Execute:
     ```powershell
     pwsh.exe -NoProfile -ExecutionPolicy Bypass -File tests/codex-parity/test-hard-fence.ps1
     ```
   - Verify `[Axis A: Filesystem Hard-Fence Parity: PASS]`, `[Axis B: Elevated Isolation: PASS / NOT VERIFIED]`, and `[Managed Profile Exclusion: PASS]`.

---

## Remaining Genuine Gaps & Platform Realities

The following technical differences remain between the harnesses and cannot be bridged without upstream platform modifications:
1. **Elevated Windows Network & User Isolation Diagnostic Boundary**: Upstream Codex CLI does not currently expose an authoritative, documented public diagnostic API to query internal elevated sandbox tokens or service user state from within a child process. Generic TCP connection failures and username regex matching do not constitute proof of elevation. Therefore, Level 2 reports Axis A (Filesystem Hard-Fence Parity) as proven via exact path testing, true outer-to-inner sandboxing, and positive controls, while Axis B (Elevated Windows Network & User Isolation) is certified only when authoritative diagnostic evidence or exact known principals are available alongside outside-network HTTPS positive controls, reporting `NOT VERIFIED` otherwise.
2. **Interactive Subagent Abort**: Codex `SubagentStart` hooks cannot abort subagent launches (`continue: false` is ignored). Hard role boundaries and role transition graphs are enforced deterministically via the local orchestration adapter (`orchestrate-role.ps1`).
3. **Dynamic TUI Statusline**: Codex `tui.status_line` supports only predefined system identifiers (`model`, `git-branch`). Dynamic role statusline indicators are logged to `runtime/` files rather than displayed in the terminal statusline.
4. **Command Line Character Ceiling Escalation**: Windows `CreateProcessW` limits total command lines to 32,767 characters. Roles currently fit under a tested 24 KB ceiling. If future role instructions exceed 24 KB, transitioning that role to `codex app-server` (JSON-RPC) or declarative agent profiles is required, rather than attempting shell slicing.
5. **`agy` Critic Process Isolation**: The `agy` tool's `--sandbox` flag provides terminal-level restriction rather than filesystem read-only locks or network blocks; adapter-level output parsing and validation enforce integrity.
6. **No CLI `codex import` Subcommand**: Upstream Codex CLI does not provide a CLI import command; configuration scaffolding must be performed via interactive composer `/import` in an isolated worktree or through declarative repository assets.

---

## Structural Acceptance Proof of Line-Based Extractor

The line-based extractor implemented above satisfies all structural invariants:
1. **Marker Position Invariant**:
   - `<!-- BEGIN_PHASE0_DRIVER_SCRIPT -->` appears before the controller block in this document.
   - `<!-- BEGIN_PHASE0_CONTROLLER_SCRIPT -->` appears before the outer orchestration block in this document.
   - Any linear search from index 0 matching exact trimmed lines selects the actual script block and ignores any string literals inside subsequent blocks.
2. **Zero-Regex Invariant**:
   - Neither outer orchestration nor the implementation controller contains any regular expression patterns for code fence extraction.
   - Fence extraction is 100% deterministic line indexing with exact boundary validation (````powershell` and ```` `).
3. **PowerShell AST Parsing**:
   - Both extracted script texts are parsed via `[System.Management.Automation.Language.Parser]::ParseInput` and enforced to have zero syntax errors prior to file writing or execution.
4. **TOCTOU Invariant**:
   - Both outer orchestration and the staged controller read the file into an in-memory byte buffer via `[System.IO.File]::ReadAllBytes` exactly once, hash that exact buffer, decode with strict UTF-8, and extract directly from that decoded line array without rereading from disk.
