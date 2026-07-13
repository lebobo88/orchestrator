// Copy this file to .claude/workflows/<kebab-name>.js only after the user has
// explicitly approved a concrete reusable Dynamic Workflow. This is a template,
// not the default build route.

export const meta = {
  name: 'replace-with-kebab-name',
  description: 'Replace with the workflow purpose and exact invocation contract.',
  phases: [
    { title: 'Implement' },
    { title: 'Verify' },
  ],
}

const RESULT_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['done', 'blocked', 'failed'] },
    summary: { type: 'string' },
    verification: { type: 'string' },
  },
  required: ['status', 'summary', 'verification'],
}

let input = args
if (typeof input === 'string') {
  try {
    input = JSON.parse(input)
  } catch {
    throw new Error('Workflow args must be a JSON object.')
  }
}

if (!input || typeof input !== 'object' || !input.request || !input.target) {
  throw new Error('Expected workflow args: { request, target, acceptance_checks }.')
}

phase('Implement')
const result = await agent(
  `ENGINEERING_JOB\nrequest: ${input.request}\ntarget: ${input.target}\nacceptance_checks: ${input.acceptance_checks || 'Inspect and run the strongest practical verification.'}\ntdd: required — test first, RED → GREEN → REFACTOR\ncommit_authority: no\nEND_ENGINEERING_JOB\nBecause this is a Dynamic Workflow, return only the schema-valid JSON status, summary, and verification fields.`,
  { agentType: 't1-engineer', phase: 'Implement', label: 't1-engineer', schema: RESULT_SCHEMA }
)

phase('Verify')
if (result.status !== 'done') {
  return { status: result.status, summary: result.summary, verification: result.verification }
}

return { status: 'done', summary: result.summary, verification: result.verification }
