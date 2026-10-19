# Codex CLI Harness Architecture & Specification

## Overview

This repository (`H:\CommandCenter\orchestrator`) provides a first-class, additive, coexistence-safe **OpenAI Codex CLI** harness operating side-by-side with the existing **Claude Code** harness.

Both harnesses share the repository workspace while maintaining strictly isolated runtime boundaries, configuration stacks, hook definitions, and role definitions.

## Dual-Harness Coexistence & PowerShell Scoping

### Runtime Boundaries
- **New Codex CLI Harness Components**: Require **PowerShell 7+ (`pwsh.exe`)** and .NET Core / .NET 6+ runtime APIs:
  - Strongly-typed `ProcessStartInfo.ArgumentList` eliminating command line concatenation and shell quoting vulnerabilities.
  - Native asynchronous stream I/O via C# Tasks in `ProcessRunnerHelper.cs`.
  - Process tree snapshot tracking via Win32 Toolhelp32 APIs (`CreateToolhelp32Snapshot`, `Process32FirstW`, `Process32NextW`).
  - AST zero-error parsing via `[System.Management.Automation.Language.Parser]::ParseFile`.
- **Existing Claude Code Components**: Preserved under **Windows PowerShell 5.1 (`powershell.exe`)** to guarantee zero regression of the active production Claude harness.
- **Test Broker**: Dynamically routes tests to their intended shell runtime (`pwsh.exe` for Codex parity suites, `powershell.exe` for legacy Claude suites).

## Core Architecture Components

### 1. Configuration & Security Profiles (`.codex/config.toml`)
- Project-level configuration is placed in `.codex/config.toml`.
- Top-level keys precede tables:
  - `sandbox_mode = "workspace-write"`
  - `approval_policy = "on-request"`
  - `web_search = "disabled"`
- Features enabled: `hooks = true`, `multi_agent = true`, `unified_exec = true`.
- Security Profiles:
  - `snapshot-isolated`: Defines `extends = ":workspace"` with `network.enabled = false` for deterministic test broker runs.
  - `orchestrator-governed`: Dedicated permissions profile for role execution.

### 2. Managed Policy Requirements (`.codex/requirements.template.toml`)
- Template for enterprise/system-level deployment to `%ProgramData%\OpenAI\Codex\requirements.toml`.
- Restricts `allowed_permission_profiles` to `[":read-only", "orchestrator-governed"]`.
- Enforces Level 2 elevated Windows sandboxing.

### 3. Lifecycle Hooks (`.codex/hooks.json` & `.codex/hooks/*.ps1`)
- Registered in `.codex/hooks.json` and executed via `pwsh.exe -NoProfile -ExecutionPolicy Bypass -File <script>`.
- Hook validators:
  - `validate-control-plane-write.ps1`: Protects `.codex/**`, `.claude/**`, `AGENTS.md`, `CLAUDE.md`, and contracts against write and shell mutation.
  - `validate-agent-dispatch.ps1`: Validates subagent dispatches against authorized roles; rejects background/named/team invocations.
  - `validate-researcher-bash.ps1`: Restricts researcher shell commands strictly to read-only inspection commands without composition or interpolation.
  - `validate-scribe-write.ps1`: Restricts scribe writes to documentation formats outside control-plane directories.
  - `validate-design-prototype-write.ps1`: Confines prototype generation to `.design/prototypes/<task-slug>/`.
  - `validate-judge-command.ps1`: Gages judge executions to deterministic cross-vendor adapter invocations.
  - `validate-terminal-packet.ps1`: Enforces delimited terminal packet contracts for role completion.

### 4. Process Execution Stack (`.agents/scripts/`)
- `CodexLauncherResolver.psm1`: Side-effect-free launcher resolver (inspects `codex.exe` and npm shim `codex.cmd` without spawning processes).
- `ProcessRunnerHelper.cs`: High-performance asynchronous C# process runner with Toolhelp32 snapshot helper, single 3000 ms cleanup budget (750 ms emergency reserve), and canonical taskkill tree cleanup.
- `invoke-codex-process.ps1`: Shared process launcher mediating environment modes (`AuthenticatedRole` vs `IsolatedSandbox`).
- `orchestrate-role.ps1`: Role dispatch orchestrator enforcing `routing_edges` call graph.
- `trusted-writer.ps1`: Hardened path-constrained file writer for read-only roles.
- `test-broker.ps1`: Deterministic test broker executing test suites in isolated sandboxes.

## Verification Tiers

1. **Tier 1 (Level 1 Functional-Project Readiness)**:
   - Validated without administrator privileges.
   - Evaluates strict TOML syntax, active profile resolution, hook execution, launcher concurrent I/O, role precedence, and test broker isolation.
2. **Tier 2 (Level 2 Managed System Parity)**:
   - Requires administrative privileges to deploy `%ProgramData%\OpenAI\Codex\requirements.toml`.
   - Axis A: Filesystem Hard-Fence Parity verified through exact path write denial via true outer-to-inner wrapper chains.
   - Axis B: Elevated Windows Network & User Isolation verified through allowlisted principal checks and outside HTTPS controls.
