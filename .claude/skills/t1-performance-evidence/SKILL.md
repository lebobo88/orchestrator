---
name: t1-performance-evidence
description: T1 measurement-driven performance optimization playbook. Use when a job claims latency, throughput, rendering, query, memory, or resource concerns.
user-invocable: false
---

# Performance evidence

1. Define the user-visible or operational metric, workload, environment, and acceptable regression limit.
2. Capture a reproducible baseline before changing production code. Trace the likely bottleneck and distinguish CPU, memory, I/O, network, database, rendering, and algorithmic causes.
3. Form a bounded hypothesis; make one small change at a time under the normal TDD loop.
4. Measure before/after with the same method. Do not claim improvement without comparable evidence.
5. Check correctness, error behavior, cache invalidation, resource lifecycle, and worst-case/edge inputs. Report noise, limits, and any tradeoff honestly.
