---
name: design-prototype
description: Creates one disposable selected-direction prototype under the isolated design prototype root.
---

# Design prototype

Prototype only a user-selected Studio direction. The job must provide one exact `prototype_root` under `.design/prototypes/<task-slug>/` and a reviewed `DESIGN_HANDOFF`.

- Write only HTML, CSS, JavaScript, JSON, SVG, or Markdown beneath that root.
- Create one self-contained direction. Do not create comparison galleries or discarded variants.
- Use repository capabilities and code-native assets only. Do not install dependencies, edit product source, configuration, manifests, lockfiles, tests, or generated assets elsewhere.
- Represent enough states and responsive behavior to validate the design thesis. Label sample data and claims as placeholders.
- Return one self-contained `PROTOTYPE_DONE` packet through `END_PROTOTYPE_DONE`, with `path:` and `validation:` plus changed paths, launch/open instructions that require no dependency installation, represented states, and known prototype limits. Use `PROTOTYPE_BLOCKED` through `END_PROTOTYPE_BLOCKED` with `reason:` and `evidence:` when the job cannot be safely completed.

The prototype is design evidence, not production code.
