---
name: t1-tdd-test-design
description: T1 test-first and test-design playbook. Use for every implementation job before production edits and whenever a test failure needs diagnosis.
user-invocable: false
---

# TDD and test design

Choose the narrowest executable behavioral check that would fail for the requested defect or missing behavior. Read local test conventions first.

- For behavior changes: state the behavior and boundary, write/update the focused test first, run it RED before production code, then make the smallest GREEN change.
- For pure refactors: establish a characterization test baseline before moving code; preserve observably equivalent behavior.
- Prefer deterministic tests with explicit setup, input, expected output/effect, and cleanup. Cover the material happy path, failure/edge path, and regression trigger without testing implementation trivia.
- Diagnose a failing test before changing it. Do not weaken expectations merely to make code pass; prove the test is wrong or return a blocker.
- Re-run the same focused check after every material refactor, then run the strongest practical broader verification.
