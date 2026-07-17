---
name: workflow-author
description: Define or revise a documented reusable engineering mode using native Claude Code Skills and custom agents. It does not create JavaScript workflow runtimes.
disable-model-invocation: true
argument-hint: "<workflow purpose>"
---

# Engineering mode authoring

Use this only on an explicit request. Before writing a mode, establish its name, trigger, inputs, roles/models, write ownership, allowed parallel branches, outputs, success condition, maximum retries, failure behavior, and whether it changes files. A reusable route cannot depend on an unanswered material mid-run human question.

Add or revise a Skill and only the custom agent definitions required for the mode. Do not create `.claude/workflows/*.js` or invent unsupported `phase`, `log`, `agent`, or `pipeline` APIs. Keep the skill as instructions and structured handoff contracts that the interactive orchestrator executes.

Keep the mode narrow and reproducible. Use structured handoffs, bounded retries, and explicit terminal status (`completed`, `blocked`, or `failed`). Do not replace an ordinary interactive `/build` task with a hidden runtime. Do not embed `claude -p` calls; if programmatic orchestration becomes essential, use the Claude Agent SDK's interactive streaming/session APIs and obtain explicit user approval first.

After implementation, add static routing fixtures and document the trigger, inputs, side effects, and recovery steps in `docs/CUSTOM-WORKFLOWS.md`.
