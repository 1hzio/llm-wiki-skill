# Wiki Schema — Example: SaaS Project

## Purpose
Knowledge base for a multi-service SaaS application.

## Conventions
- Wiki pages in this directory
- `[[page-name]]` for cross-references
- YAML frontmatter on every page: title, created, updated, tags
- Update index.md and log.md after every change

## Page Types
- **architecture**: system design, service boundaries
- **tech-stack**: technology choices per service
- **flow**: business processes (signup, billing, notification)
- **entity**: data models, API contracts
- **trace**: cross-service feature file mapping
- **reference**: environments, deployment, configuration

## Enrichment Checklist
For each page, cover:
- [ ] What: facts and definitions
- [ ] Where: source file paths (verified)
- [ ] How: step-by-step processes
- [ ] Why: design decisions
- [ ] What Not: anti-patterns and pitfalls
