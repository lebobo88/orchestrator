# Local harness runtime

This directory is the existing writable anchor for ephemeral cross-vendor judge jobs and provenance. Git ignores every runtime file except this README. Judge jobs are deleted immediately after the adapter reads them; provenance contains hashes and usage metadata, never source or full prompts.
