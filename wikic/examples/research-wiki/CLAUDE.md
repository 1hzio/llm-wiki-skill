# Wiki Schema — Example: AI Research

## Purpose
Personal research wiki tracking developments in large language models.

## Conventions
- Wiki pages in this directory
- `[[page-name]]` for cross-references
- YAML frontmatter: title, created, updated, sources, tags
- Update index.md and log.md after every change

## Page Types
- **entity**: people, companies, labs
- **concept**: techniques, architectures, methods
- **source**: paper/article summaries
- **exploration**: comparative analysis, synthesis

## Ingest Priority
1. Seminal papers (highest value per token)
2. Recent breakthrough papers
3. Technical blog posts
4. News articles (lowest — facts change fast)

## Special Rules
- Flag contradictions between sources explicitly
- Track claim evolution over time
- Include confidence levels for claims
- Run divergence check: seek counterarguments for every strong claim
