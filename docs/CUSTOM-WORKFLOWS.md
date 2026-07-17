# Reusable engineering modes

`build` is an interactive skill, not a JavaScript workflow runtime. Reusable Claude Code behavior belongs in Skills and custom agent definitions under `.claude/`.

The active modes are standard T1 work, evidence-backed T2 escalation, and explicit extreme advisory teams. Future best-of-3 or swarm modes must be documented here before activation with their trigger, models/cost policy, roles, writable paths, dependencies, retry cap, fallback, terminal verification, and user approval requirement.

Do not put an unanswered material user decision inside an automated route. Do not call Claude through `-p`; use the Agent SDK only for an explicitly approved programmatic integration that must persist outside an interactive session.
