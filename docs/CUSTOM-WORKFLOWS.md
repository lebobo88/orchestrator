# Custom workflows

No Dynamic Workflow ships by default. `build` is a deliberately simple interactive skill that delegates one job to `t1-engineer`.

To add a custom workflow, invoke `/workflow-author <purpose>`. Define it before use, give it a unique name, and document its trigger, inputs, stages, concurrency, outputs, verification gate, retry cap, failure behavior, side effects, and recovery steps here. The author starts from `.claude/skills/workflow-author/templates/dynamic-workflow-template.js` and only copies a finished workflow to `.claude/workflows/<kebab-name>.js` after explicit approval.

Do not put a request that needs a human answer inside a dynamic workflow. Ask and resolve that decision first. Do not call Claude through `-p`; use native Dynamic Workflow primitives, and use the Agent SDK only for an explicitly approved programmatic integration that must persist outside an interactive session.
