# Research reports

`scribe` creates and updates one cited Markdown report per topic at `docs/research/<topic-slug>.md` from a Researcher `RESEARCH_EVIDENCE` packet. Reports are user-facing evidence artifacts, not implementation instructions. They are intentionally not staged or committed automatically.

Each report preserves its creation date, records the latest update, records `skills_used`, maintains a source ledger, and adds a change-log entry when follow-up research revises it. Researcher itself remains read-only.
