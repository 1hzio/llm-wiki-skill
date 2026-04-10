#!/usr/bin/env bash
# wiki-init.sh — Initialize an LLM Wiki directory structure
# Usage: wiki-init.sh [path] [--project|--research|--team]

set -euo pipefail

WIKI_PATH="${1:-docs/wiki}"
TEMPLATE="${2:---project}"

# Strip leading --
TEMPLATE="${TEMPLATE#--}"

echo "Initializing LLM Wiki at: $WIKI_PATH (template: $TEMPLATE)"

# Create directory structure
mkdir -p "$WIKI_PATH"

# Create index.md
cat > "$WIKI_PATH/index.md" << 'EOF'
# Wiki Index

<!-- Organize your pages by category. Update this file whenever you add or remove a page. -->
<!-- Format: - [[page-name]] — one-line description -->

## Getting Started
- This Wiki is empty. Run `/wikic ingest` to add your first knowledge.
EOF

# Create log.md
cat > "$WIKI_PATH/log.md" << EOF
# Operation Log

## [$(date +%Y-%m-%d)] init | Wiki initialized
- Template: $TEMPLATE
- Path: $WIKI_PATH
EOF

# Create CLAUDE.md based on template
case "$TEMPLATE" in
  project)
    cat > "$WIKI_PATH/CLAUDE.md" << 'SCHEMA'
# Wiki Schema — Project Knowledge Base

## Purpose
This Wiki maintains structured knowledge about the project codebase, architecture,
and business logic. It supports cross-session knowledge accumulation for AI agents.

## Conventions
- All Wiki pages live in this directory
- Use `[[page-name]]` for cross-references between pages
- Every page must have YAML frontmatter: title, created, updated, tags
- Update index.md and log.md after every operation

## Page Types
- **architecture**: System design and component relationships
- **tech-stack**: Technology choices and configuration
- **flow**: Business or technical processes
- **entity**: Data models and API specs
- **reference**: Config, environment, deployment info
- **trace**: Cross-component feature file mapping

## Enrichment Dimensions
Each page should cover as many as applicable:
- **What**: facts, components, definitions
- **Where**: source file paths (verified via Glob/Grep)
- **How**: step-by-step processes
- **Why**: design decisions and rationale
- **What Not**: anti-patterns and past mistakes

## Ingest Workflow
1. Read the source material
2. Extract key information
3. Create or update relevant Wiki pages
4. Add [[cross-references]] to related pages
5. Update index.md and log.md

## Query Workflow
1. Read index.md to locate relevant pages
2. Read specific pages (not all — be selective)
3. Synthesize answer with [[page]] citations
4. If answer has lasting value, save as exploration page

## Maintenance (Lint)
- Check cross-reference consistency
- Flag outdated information
- Merge duplicate content
- Identify knowledge gaps
SCHEMA
    ;;

  research)
    cat > "$WIKI_PATH/CLAUDE.md" << 'SCHEMA'
# Wiki Schema — Research Knowledge Base

## Purpose
This Wiki compiles and synthesizes research materials — papers, articles, talks,
experiments — into a structured, growing body of knowledge.

## Conventions
- All Wiki pages live in this directory
- Use `[[page-name]]` for cross-references
- Every page must have YAML frontmatter: title, created, updated, sources, tags
- Update index.md and log.md after every operation

## Page Types
- **entity**: People, organizations, projects
- **concept**: Ideas, methods, theories
- **source**: Summary of a paper/article/talk
- **exploration**: Comparative analysis, synthesis, investigation

## Ingest Workflow
1. Read the source material
2. Discuss key takeaways with user
3. Create source summary page
4. Update related entity and concept pages
5. Flag contradictions with existing knowledge
6. Update index.md and log.md

## Query Workflow
1. Read index.md to locate relevant pages
2. Synthesize answer with citations
3. Archive valuable answers as exploration pages

## Maintenance
- Check for contradictions between pages
- Identify orphan pages (no inbound links)
- Suggest new research directions
- Run bias check: are pages presenting only one viewpoint?
SCHEMA
    ;;

  team)
    cat > "$WIKI_PATH/CLAUDE.md" << 'SCHEMA'
# Wiki Schema — Team Knowledge Base

## Purpose
This Wiki captures team knowledge — decisions, processes, incidents, onboarding
context — so it persists beyond individual memory and chat history.

## Conventions
- All Wiki pages live in this directory
- Use `[[page-name]]` for cross-references
- Every page must have YAML frontmatter: title, created, updated, tags
- Update index.md and log.md after every operation

## Page Types
- **process**: How we do things (deployment, review, on-call)
- **decision**: ADRs — why we chose X over Y
- **incident**: Post-mortems and lessons learned
- **onboarding**: Context new team members need
- **reference**: Tools, environments, access

## Ingest Priority
1. Incident reports (highest — lessons learned are most valuable)
2. Architecture decision records
3. Process documentation
4. Meeting notes and decisions

## Ingest Workflow
1. Read the source material
2. Extract actionable knowledge
3. Create or update Wiki pages
4. Cross-reference related pages
5. Update index.md and log.md

## Maintenance
- Review for outdated processes
- Check that incidents have prevention measures documented
- Ensure onboarding pages reflect current reality
SCHEMA
    ;;

  *)
    echo "Unknown template: $TEMPLATE (use --project, --research, or --team)"
    exit 1
    ;;
esac

echo ""
echo "Wiki initialized successfully!"
echo ""
echo "Structure:"
echo "  $WIKI_PATH/"
echo "  ├── CLAUDE.md    (schema — customize for your domain)"
echo "  ├── index.md     (page index — updated automatically)"
echo "  └── log.md       (operation log — updated automatically)"
echo ""
echo "Next steps:"
echo "  1. Customize CLAUDE.md for your specific domain"
echo "  2. Add raw materials to a raw/ directory (optional)"
echo "  3. Run: /wikic ingest <source> to start building knowledge"
