# Claude 5.5 family, Claude Code alignment, OpenAI GPT-6 judges, and pricing

Research report for plan phases R1, R2, and the Claude Code hook facts that R3 depends on, from `docs/plans/orchestrator-upgrade-series-2026-10.md`. Audience: the repository owner and the Planner revising the upgrade series. All sources are official. All were accessed 2026-10-19.

Confidence labels: CONFIRMED means an official source states it. UNCONFIRMED means no official source read states it. CONTRADICTED means an official source shows a premise is false. Fleet-fit statements are inferences and are labeled as such.

## Scope note on R3

The R3 plan item covers Windows process-tree termination, Playwright `webServer` teardown, Vite `strictPort`, and the `gh` workflow surface. The evidence supplied for this report covers only the Claude Code hook behavior relevant to R3 (section 5). Windows process lifecycle, Playwright, Vite, and `gh` workflow commands were not researched here. R3 remains open for those topics.

## 1. Summary of decisions this evidence affects

1. The D-gate asks whether all three OpenAI judge IDs and the medium effort are confirmed. They are: `gpt-6-luna`, `gpt-6-astra`, and `gpt-6.1-sol` exist and all three accept medium effort [S17, S19, S20, S21]. The D-gate condition is met on the evidence read, with two caveats: the `gpt-6.1-sol` release date and API-key Codex availability per model are UNCONFIRMED.
2. "Fable 5.5" does not exist (CONTRADICTED) [S1]. The current Fable model is Fable 5.1 (`claude-fable-5-1`). Fable 5 (`claude-fable-5`) is a legacy active model.
3. The `haiku` alias now resolves to Haiku 5.5, which changes the behavior of `codex-judge-runner` (section 3.4) [S5, S6].
4. The repo's Anthropic model sentences are stale relative to the current family (section 3.5).
5. `gpt-5.6-terra` is current and not deprecated. Removing it from the repo's judging is the owner's local design decision (approved by the user 2026-10-19), not a vendor deprecation [S18, S22, S23].

## 2. Claude model family

### 2.1 Current models (CONFIRMED) [S1]

| Model ID | Context | Max output | Training data cutoff |
| --- | --- | --- | --- |
| `claude-fable-5-1` | 1M | 128K | Jun 2026 |
| `claude-opus-5-5` | 1M | 128K | Jun 2026 |
| `claude-sonnet-5-5` | 1M | 128K | Jun 2026 |
| `claude-haiku-5-5` | 1M | 128K | Jun 2026 |

### 2.2 Release and retirement dates (CONFIRMED) [S1, S4]

| Model | Released | Retire not before |
| --- | --- | --- |
| Haiku 5.5 | 2026-10-07 | 2027-10-07 |
| Opus 5.5 | not stated in supplied evidence | 2027-09-22 |
| Sonnet 5.5 | not stated in supplied evidence | 2027-09-28 |
| Fable 5.1 | not stated in supplied evidence | 2027-09-01 |

### 2.3 Legacy active models (CONFIRMED) [S1, S4]

| Model ID | Retire not before |
| --- | --- |
| `claude-sonnet-5` | 2027-06-30 |
| `claude-opus-4-8` | 2027-05-28 |
| `claude-fable-5` | 2027-06-09 |
| `claude-haiku-4-5-20251001` | 2026-10-15 (imminent) |

`claude-sonnet-4-5-20250929` is deprecated and retires 2026-11-30. The named replacement is `claude-sonnet-5-5` [S4].

### 2.4 Effort and sampling parameters

- API default effort (CONFIRMED) [S3]: Opus 5.5 medium, Haiku 5.5 medium, Sonnet 5.5 high, Fable 5.1 high. All four support low, medium, high, xhigh, and max.
- Opus 5.5 thinking cannot be disabled (CONFIRMED) [S3].
- Non-default `temperature`, `top_p`, or `top_k` return a 400 error on models 4.7 and later (CONFIRMED) [S3].

## 3. Claude Code behavior

### 3.1 Effort resolution (CONFIRMED) [S8]

- Claude Code's default effort is medium for Opus, Sonnet, and Haiku 5.5.
- Precedence: `CLAUDE_CODE_EFFORT_LEVEL` or `--effort`, then settings, then the model default.
- Subagent frontmatter `effort` overrides the session level but not the environment variable.
- The settings key `effortLevel` accepts low, medium, high, and xhigh, but not max. Frontmatter accepts max.

### 3.2 Aliases and version requirements (CONFIRMED) [S8, S16]

| Alias | Resolves to | Notes |
| --- | --- | --- |
| `opus` | Opus 5.5 | Added in Claude Code v2.1.280 |
| `sonnet` | Sonnet 5.5 | Added in v2.1.284 |
| `haiku` | Haiku 5.5 | Requires Claude Code 2.1.293 or later |
| `fable` | Fable 5.1 | Added in v2.1.257 |

The latest version seen in the changelog is 2.1.303. The local install is 2.1.303 (see the baseline evidence file).

### 3.3 Model resolution for subagents (CONFIRMED) [S9]

Order: per-invocation model, then frontmatter model, then `CLAUDE_CODE_SUBAGENT_MODEL`, then the main session model. The Agent tool accepts a per-invocation `effort` (added v2.1.292).

### 3.4 Effect on `codex-judge-runner` (CONFIRMED facts, local consequence stated)

The `haiku` alias now resolves to Haiku 5.5 [S8]. Haiku 5.5 uses about 30 percent more tokens than earlier tokenizers, adds new safeguard refusals, and has thinking on by default [S5, S6]. Any role pinned to the `haiku` alias, including `codex-judge-runner`, inherits these changes.

### 3.5 Stale repo statements (observation)

Six design agents in this repo pin `claude-sonnet-5`. The project instructions describe Sonnet 5 as the default, Opus 4.8 as the premium escalation, and Fable 5 as the top model. The current family is 5.5 (Sonnet, Opus, Haiku) plus Fable 5.1. `claude-sonnet-5`, `claude-opus-4-8`, and `claude-fable-5` remain active legacy models (section 2.3), so the pins still work until their retirement dates.

### 3.6 Haiku 5.5 guidance [S5, S6]

CONFIRMED from official docs:

- Positioned for high-volume, latency-sensitive classification, routing, extraction, and subagent tasks.
- For agentic coding, start at medium effort. Low effort risks early stopping and skipped checks.
- Documented failure modes and mitigations: early stopping at low effort in long agent prompts; reporting done without running checks; possible skipped tool calls when thinking is off and structured JSON output is requested; `tool_result` text treated as untrusted.
- Prompts above 100K tokens move to the $0.50 input and $2.50 output tier (section 6.1).

INFERENCE (medium confidence, proposal only): Haiku 5.5 fits transport and mechanical roles best. The T1 writer role needs an evaluation before any move. Planner, design, and verifier judgment roles should not move to Haiku 5.5 without evaluations.

### 3.7 Subagent frontmatter and runtime (CONFIRMED) [S9]

- Supported frontmatter fields: `name`, `description`, `tools`, `disallowedTools`, `model`, `effort`, `permissionMode`, `maxTurns`, `autoCompactWindow`, `skills` (maximum 32), `mcpServers`, `hooks`, `memory`, `background`, `isolation`, `omitClaudeMd`, `color`, `initialPrompt`, `experimental.cacheTtl`.
- Unknown fields are silently ignored.
- Subagent spawn depth defaults to 3 (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`). The design chain Orchestrator, Planner, Design Director, UX specialist is exactly at that limit (the chain length is an observation from the repo's routing rules; the default is CONFIRMED).
- Fork mode is the default in interactive sessions. `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` forces foreground work.

## 4. Settings, skills, teams, statusline

CONFIRMED unless stated.

- Settings precedence: managed, then `--settings`, then `settings.local`, then `settings`, then user [S11].
- Settings keys relevant to this series: `maxEffortLevel`, `modelSettings`, `availableModels` and `deniedModels`, `modelPricing` (managed only), `worktree.baseRef`, `worktree.bgIsolation`, `worktree.sparsePaths`, `worktree.symlinkDirectories`, `idleCompaction`, `autoCompactWindow` [S11, S12].
- Skill frontmatter fields include `context: fork`, `allowed-tools`, `model`, `effort`, `hooks`, `paths`, and `shell`. The skill description is truncated at 1,536 characters [S13].
- Agent teams are experimental and off by default. Nested teams are not supported. Split panes are unsupported in Windows Terminal [S14].
- The statusline JSON includes `cost.total_cost_usd`, `context_window`, `prompt_cache`, `effort`, and `rate_limits` [S15].
- Other changes in v2.1.243 to v2.1.303 (CONFIRMED from changelog, read selectively) [S16]: auto mode is the default, `PreModelSwitch` and `PostModelSwitch` hooks exist, MCP protocol 2026-07-28 is supported, prompt and agent hooks are capped at 12 concurrent, and a worktree fix applies for git 2.56 and later.

## 5. Hooks (relevant to R3 and to fail-closed design)

CONFIRMED [S10, S16]:

- Exit 0 means success. Exit 2 blocks on blockable events. Any other exit code is non-blocking unless the hook sets `onFailure: "block"` (v2.1.295).
- `PreToolUse` and several other events are blockable. `SessionStart` and `SessionEnd` are not blockable.
- `SessionEnd` has a shared 1.5 second budget, which is too short for a process reaper (inference from the stated budget).
- `SubagentStop` is blockable and can be matched on `agent_id` or `agent_type`.
- v2.1.299 fixed `PreToolUse` hooks failing open when Git for Windows was missing.
- v2.1.293 fixed a stop terminating an unrelated process on Windows.

These facts match the DF-1 finding in the baseline evidence: an exit code of 1 is non-blocking, so a hook that errors with code 1 fails open.

## 6. Pricing

### 6.1 Anthropic, USD per 1M tokens (CONFIRMED) [S2]

| Model | Input | 5m cache write | 1h cache write | Cache read | Output |
| --- | --- | --- | --- | --- | --- |
| Fable 5.1 | 10 | 12.50 | 20 | 0.25 | 50 |
| Fable 5 | 10 | 12.50 | 20 | 1.00 | 50 |
| Opus 5.5 | 4 | 5 | 8 | 0.20 | 20 |
| Opus 5 and Opus 4.8 | 5 | 6.25 | 10 | 0.50 | 25 |
| Sonnet 5.5 | 2 | 2.50 | 4 | 0.10 | 10 |
| Sonnet 5 | 2 | 2.50 | 4 | 0.20 | 10 |
| Sonnet 4.6 | 3 | 3.75 | 6 | 0.30 | 15 |
| Haiku 5.5, prompts up to 100K | 0.10 | 0.125 | 0.20 | 0.01 | 0.50 |
| Haiku 5.5, prompts over 100K | 0.50 | 0.625 | 1 | 0.05 | 2.50 |
| Haiku 4.5 | 1 | 1.25 | 2 | 0.10 | 5 |

Batch pricing: Opus 5.5 is 2 input and 10 output; Sonnet 5.5 is 1 input and 5 output; Haiku 5.5 batch halves both tiers. Modifiers: batch is 50 percent, `inference_geo` US is 1.1x, and the 4.7 and later tokenizer produces about 30 percent more tokens.

### 6.2 OpenAI, USD per 1M tokens, standard tier (CONFIRMED) [S18, S22, S23]

Short context means up to 272K tokens. Cache write column is shown where the source gives it.

| Model | Input | Cached input | Cache writes | Output | Long-context (input / cached / writes / output) |
| --- | --- | --- | --- | --- | --- |
| `gpt-6-astra` | 10 | 1 | 12.50 | 50 | 20 / 2 / 25 / 75 |
| `gpt-6.1-sol` | 2 | 0.10 | 2.50 | 10 | 4 / 0.20 / 5 / 15 |
| `gpt-6-luna` | 0.10 | 0.01 | 0.125 | 0.50 | 0.20 / 0.02 / 0.25 / 0.75 |
| `gpt-5.6-terra` (reference) | 2 | 0.20 | 2.50 | 12 | not supplied |

Batch and Flex are 50 percent. Fast is 2x and Ultrafast is 6x, for astra and 6.1-sol.

### 6.3 Billing caveat

With ChatGPT sign-in, the Codex CLI is plan-billed. Per-token prices are therefore estimates for budget gates, not invoices.

## 7. OpenAI judge models

### 7.1 Model facts (CONFIRMED) [S17, S19, S20, S21]

- `gpt-6-luna`, `gpt-6-astra`, and `gpt-6.1-sol` all exist.
- Each has a 1,050,000 token context window and 128,000 max output tokens.
- Supported efforts:

| Model | Efforts | Default |
| --- | --- | --- |
| `gpt-6-luna` | none, low, medium, high, xhigh, max | medium |
| `gpt-6.1-sol` | low, medium, high, xhigh, max | medium |
| `gpt-6-astra` | low, medium, high, xhigh, max | not stated |

- Medium is valid on all three.
- Codex CLI uses the `model_reasoning_effort` config key and lists the three models [S24, S26].
- Enterprise and Edu workspaces need admin enablement.

### 7.2 Unconfirmed items

- API-key Codex availability for each of the three models: UNCONFIRMED.
- `gpt-6.1-sol` release date: UNCONFIRMED. The announcement page returned 403 and was not read.
- `gpt-6-astra` default effort: not stated in the sources read.

### 7.3 Terra

The only Terra model is `gpt-5.6-terra`. It is current and not deprecated. OpenAI deprecation notices name it as a replacement. No GPT-6 Terra exists. Dropping Terra from the repo's judging is the owner's local design decision, approved by the user on 2026-10-19 [S18, S22, S23].

## 8. Contradictions and unknowns

| Item | Status |
| --- | --- |
| "Fable 5.5" as a model | CONTRADICTED: no such model; use Fable 5.1 [S1] |
| Terra described as deprecated | CONTRADICTED: `gpt-5.6-terra` is current [S18, S22, S23] |
| `gpt-6.1-sol` release date | UNCONFIRMED |
| API-key Codex availability per GPT-6 model | UNCONFIRMED |
| `gpt-6-astra` default effort | UNCONFIRMED (not stated) |
| `-c mcp_servers={}` disables user MCP servers in `codex exec` | UNCONFIRMED (see baseline evidence file) |
| Windows process lifecycle, Playwright, Vite, `gh` workflow surface (R3 core) | Not researched in this report |

## 9. Research limits

- Long documentation pages were read partly through summarizing fetches. Details may be missing.
- The Claude Code memory page and the Sonnet 5.5 and Fable 5.1 prompting guides were not fetched.
- The changelog was read selectively for v2.1.243 to v2.1.303; v2.1.297 and v2.1.298 were not shown, and entries below v2.1.243 were not reviewed.
- Opus 5.5, Sonnet 5.5, and Fable 5.1 release dates were not part of the evidence supplied for this report.
- Fleet-fit statements about Haiku 5.5 are inferences and need evaluation before any change.

## 10. Validation measures

- Re-fetch the models overview, pricing, and OpenAI model pages before the D1 registry is written; record `verified_at` per entry.
- Run `codex exec --ignore-user-config` and a variant with `-c mcp_servers={}` against a fake or harmless prompt, with explicit usage approval, to settle the MCP question.
- Evaluate `codex-judge-runner` on Haiku 5.5 against the existing judge routing cases before relying on the `haiku` alias.

## 11. Source ledger

All sources are official and were accessed 2026-10-19.

| ID | Source |
| --- | --- |
| S1 | https://platform.claude.com/docs/en/about-claude/models/overview |
| S2 | https://platform.claude.com/docs/en/about-claude/pricing |
| S3 | https://platform.claude.com/docs/en/build-with-claude/effort |
| S4 | https://platform.claude.com/docs/en/about-claude/model-deprecations |
| S5 | https://platform.claude.com/docs/en/models/haiku-5-5/overview |
| S6 | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5 |
| S7 | https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5 |
| S8 | https://code.claude.com/docs/en/model-config |
| S9 | https://code.claude.com/docs/en/sub-agents |
| S10 | https://code.claude.com/docs/en/hooks |
| S11 | https://code.claude.com/docs/en/settings |
| S12 | https://code.claude.com/docs/en/settings-reference |
| S13 | https://code.claude.com/docs/en/skills |
| S14 | https://code.claude.com/docs/en/agent-teams |
| S15 | https://code.claude.com/docs/en/statusline |
| S16 | https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md (read selectively, v2.1.243 to v2.1.303) |
| S17 | https://developers.openai.com/api/docs/models/all |
| S18 | https://developers.openai.com/api/docs/pricing |
| S19 | https://developers.openai.com/api/docs/models/gpt-6-luna |
| S20 | https://developers.openai.com/api/docs/models/gpt-6-astra |
| S21 | https://developers.openai.com/api/docs/models/gpt-6.1-sol |
| S22 | https://developers.openai.com/api/docs/guides/latest-model |
| S23 | https://developers.openai.com/api/docs/deprecations |
| S24 | https://learn.chatgpt.com/docs/models (Codex docs) |
| S25 | https://learn.chatgpt.com/docs/developer-commands?surface=cli (Codex docs) |
| S26 | https://learn.chatgpt.com/docs/config-file/config-reference (Codex docs) |
| S27 | https://learn.chatgpt.com/docs/non-interactive-mode.md (Codex docs) |
| S28 | https://openai.com/index/introducing-gpt-6-1-sol/ (HTTP 403, not read) |
