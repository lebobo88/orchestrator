---
name: workflow-author
description: Define, review, or change a named opt-in Claude Code Dynamic Workflow for a reusable multi-stage process. Use only when the user explicitly requests a custom workflow or changes to one; never for the default build route.
disable-model-invocation: true
argument-hint: "<workflow purpose>"
---

# Dynamic workflow authoring

Use this only on an explicit request. Before writing a workflow, establish its name, trigger, inputs, stages, allowed parallel branches, outputs, success condition, maximum retries, failure behavior, and whether it changes files. Dynamic workflows cannot depend on an unanswered mid-run human question; stop and ask that question before the workflow starts.

Start from `templates/dynamic-workflow-template.js`, copy the resulting file to `.claude/workflows/<kebab-name>.js`, replace its metadata/input contract/schema, and preserve its defensive args normalization. A workflow script has no direct filesystem control; it delegates through typed agents and must rely on their structured return values. Use `phase`, `log`, `agent`, and `pipeline` only where the workflow API supports them.

Keep the workflow narrow and reproducible. Use structured stage results, bounded retries, and explicit final status (`completed`, `blocked`, or `failed`). Do not replace an ordinary interactive `/build` task with a workflow. Do not embed `claude -p` calls; if programmatic orchestration becomes essential, use the Claude Agent SDK's interactive streaming/session APIs and obtain explicit user approval first.

After implementation, validate the workflow with a harmless fixture or dry-run path and document the invocation, inputs, side effects, and recovery steps in `docs/CUSTOM-WORKFLOWS.md`.
