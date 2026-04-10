---
name: llm-wiki
description: >
  Compile knowledge into a persistent Wiki of interlinked Markdown pages — ~55% token savings vs re-reading raw sources.
  Init, ingest, query, lint, trace, and stats for codebase/research/team wikis.
  Trigger on: "wiki", "knowledge base", "ingest", "摄入", "知识库", "build wiki", "update wiki", "lint wiki",
  or requests to create/organize/audit a knowledge base, turn raw documents into structured notes,
  maintain cross-referenced documentation, or set up a "second brain".
---

# LLM Wiki Skill

Build and maintain a persistent, structured knowledge base as interlinked Markdown files.
Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Core Concept

Instead of retrieving from raw documents each time (RAG), you **compile** knowledge into a persistent Wiki that grows richer with every interaction. The Wiki sits between you and the raw sources — cross-references are pre-built, contradictions are flagged, synthesis reflects everything ingested so far.

```
Human: curate sources, ask questions, guide direction
LLM:   summarize, cross-reference, file, maintain — all the bookkeeping
```

## Three-Layer Architecture

```
┌─────────────────────────────────────┐
│  Schema Layer (CLAUDE.md/AGENTS.md) │  ← How to operate the Wiki
├─────────────────────────────────────┤
│  Wiki Layer (wiki/*.md)             │  ← LLM-generated knowledge
├─────────────────────────────────────┤
│  Raw Layer (raw/*)                  │  ← Immutable source documents
└─────────────────────────────────────┘
```

- **Raw**: immutable source documents. LLM reads but never writes.
- **Wiki**: LLM-owned Markdown files. Create, update, cross-reference, maintain.
- **Schema**: tells LLM how to operate. You and LLM co-evolve this.

## Operations

### 1. Initialize (`/wiki init`)

When user wants to create a new Wiki, run the init script:

```bash
bash <skill-path>/scripts/wiki-init.sh [wiki-path] [--project|--research|--team]
```

This creates the directory structure, schema CLAUDE.md, empty index.md and log.md. The `--project` flag is for codebase wikis, `--research` for research/learning, `--team` for team knowledge.

If no path given, default to `docs/wiki/` in the current working directory.

After init, customize the schema:
1. Read the generated `CLAUDE.md` in the wiki directory
2. Ask the user about their domain, focus areas, and page types
3. Update the schema accordingly

### 2. Ingest (`/wiki ingest <source>`)

Add new knowledge from a source (file, URL, codebase, conversation).

**Workflow:**
1. Read the source material
2. Read `wiki/index.md` to understand existing knowledge
3. Identify what's new, what updates existing pages, what contradicts
4. Present a plan to the user:
   - New pages to create
   - Existing pages to update
   - Contradictions to flag
5. On confirmation, execute:
   - Create/update wiki pages with YAML frontmatter
   - Add `[[cross-references]]` to related pages
   - Update `index.md` with new entries
   - Append to `log.md`

**Page format:**
```markdown
---
title: "Page Title"
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [list of source references]
tags: [relevant, tags]
---

> TLDR: One-line summary for quick scanning.

## Content sections...

## Related
- [[other-page]] — relationship description
```

**Enrichment dimensions** — for each page, try to cover:
- **What**: facts, definitions, components
- **Where**: file paths, URLs, locations (for code wikis)
- **How**: processes, workflows, step-by-step
- **Why**: design decisions, rationale, trade-offs
- **What Not**: anti-patterns, pitfalls, past mistakes

### 3. Batch Ingest (`/wiki batch-ingest <folder> [--category <cat>]`)

Ingest all files in a folder. Useful for onboarding an existing document set.

**Workflow:**
1. Scan the folder and list all ingestible files (Markdown, text, PDF, etc.)
2. Present the file list with detected categories for user confirmation
3. Process files sequentially, applying the Ingest workflow to each
4. Pause every 5 files — show progress and ask whether to continue
5. After completion, update `index.md` and append a single batch entry to `log.md`

Supported categories: `architecture`, `tech-stack`, `flow`, `entity`, `reference`, or auto-detect from content.

### 4. Query (`/wiki query <question>`)

Answer questions using Wiki knowledge.

**Workflow:**
1. Read `wiki/index.md` to locate relevant pages
2. Read the relevant pages (not all — be selective)
3. Synthesize an answer with `[[page]]` citations
4. If the answer has lasting value, offer to save it as a new exploration page

The key insight: **good answers should be filed back into the Wiki**. A comparison analysis, a discovered connection — these shouldn't vanish into chat history.

### 5. Digest (`/wiki digest <topic>`)

Deep cross-source synthesis on a topic. Unlike Query (which answers a specific question), Digest explores a topic across all related sources to find patterns, contradictions, and gaps.

**Workflow:**
1. Read `wiki/index.md` to identify all pages touching the topic
2. Read those pages plus any relevant `raw/` sources
3. Synthesize a comprehensive analysis:
   - **Patterns**: recurring themes across sources
   - **Contradictions**: where sources disagree (with source attribution)
   - **Gaps**: what's missing or under-documented
   - **Evolution**: how understanding of this topic changed over time
4. Save the result as a new `wiki/digest-<topic>.md` page
5. Update `index.md` and `log.md`

The output is a persistent page, not a chat response. Digests are the Wiki's highest-value synthesis artifacts.

### 6. Compound (`/wiki compound`)

Capture experience from a recently solved problem. Trigger after debugging sessions, architecture decisions, or any learning moment worth preserving.

**Two tracks:**

**Bug Track** — for solved bugs and incidents:
```markdown
---
title: "Solution: Brief Description"
type: solution
tags: [solution, bug]
created: YYYY-MM-DD
---

## Problem
What went wrong, symptoms observed.

## Investigation
Steps taken to diagnose. Dead ends included.

## Root Cause
The actual underlying issue.

## Fix
What was changed and why.

## Prevention
How to avoid this class of problem in the future.
```

**Knowledge Track** — for decisions, discoveries, or learned patterns:
```markdown
---
title: "Knowledge: Topic"
type: solution
tags: [solution, knowledge]
created: YYYY-MM-DD
---

## Background
Context and motivation.

## Insight
The key learning or decision.

## Applicability
When and where this applies. Conditions and constraints.

## Related
- [[relevant-pages]] — how this connects to existing knowledge
```

**Workflow:**
1. Ask the user: bug fix or knowledge capture?
2. Gather details through conversation
3. Create the solution page in `wiki/`
4. Cross-reference with existing pages
5. Update `index.md` and `log.md`

### 7. Lint (`/wiki lint`)

Audit Wiki health and fix issues.

**Run the audit script first:**
```bash
bash <skill-path>/scripts/wiki-lint.sh [wiki-path]
```

This checks for dead links, orphan pages, missing frontmatter, and pages without cross-references. Then do a deeper semantic review:

**Checklist:**
- [ ] **Contradictions**: do any pages disagree with each other?
- [ ] **Staleness**: are any facts outdated given recent changes?
- [ ] **Orphans**: pages with no inbound `[[links]]`?
- [ ] **Dead links**: `[[references]]` to non-existent pages?
- [ ] **Missing coverage**: important topics without dedicated pages?
- [ ] **Bias check**: are pages presenting only one viewpoint?

Present findings as a report. Fix issues on user confirmation.

### 8. Trace (`/wiki trace <feature>`)

For codebase wikis: create a cross-repo trace page that maps all files involved in an end-to-end feature.

**Workflow:**
1. Identify the feature to trace (e.g., "deposit flow", "user authentication")
2. Use Glob/Grep across all repositories to find involved files
3. Organize by layer: frontend → API → service → database
4. Create a trace page with numbered steps and file tables

**Format:**
```markdown
---
title: "Cross-Repo Trace: Feature Name"
tags: [trace, cross-repo]
---

## 1. Frontend Entry (repo-name)
| Step | File | Description |
|------|------|-------------|
| User clicks X | `src/pages/Feature.vue` | Entry point |

## 2. API Layer (backend-repo)
| Step | File | Description |
|------|------|-------------|
| POST /api/feature | `src/web/FeatureController.java` | API endpoint |

## 3. Business Logic
...
```

### 9. Graph (`/wiki graph`)

Generate a knowledge graph showing relationships between Wiki pages.

**Run the graph script:**
```bash
bash <skill-path>/scripts/wiki-graph.sh [wiki-path]
```

This scans all `[[wikilinks]]` and generates a Mermaid diagram saved to `wiki/knowledge-graph.md`. Pages become nodes, cross-references become edges. Helps visualize knowledge clusters and isolated pages.

Open in any Mermaid-compatible viewer or Obsidian for interactive exploration.

### 10. Stats (`/wiki stats`)

Show Wiki health metrics:
```bash
bash <skill-path>/scripts/wiki-stats.sh [wiki-path]
```

Reports: file count, total lines, estimated tokens, cross-reference count, dead links, pages missing Where/Why/What-Not sections.

## Page Types

| Type | Purpose | Example |
|------|---------|---------|
| **architecture** | System design, component relationships | `architecture-overview.md` |
| **tech-stack** | Technology choices and configuration | `backend-tech-stack.md` |
| **flow** | Business or technical process | `deposit-lifecycle.md` |
| **entity** | Data models, API specs | `user-data-model.md` |
| **reference** | Config, environment, deployment | `deployment-guide.md` |
| **trace** | Cross-component feature mapping | `trace-auth-flow.md` |
| **exploration** | Analysis, comparison, investigation | `framework-comparison.md` |
| **solution** | Bug fixes, decisions, learned patterns | `solution-memory-leak.md` |
| **digest** | Deep cross-source synthesis | `digest-auth-patterns.md` |

## Best Practices

**Keep pages focused.** One concept per page. If a page exceeds 100 lines, consider splitting.

**Cross-reference liberally.** Use `[[page-name]]` whenever mentioning a concept that has its own page. This is how knowledge compounds.

**Frontmatter is mandatory.** Every page needs `title`, `created`, `updated`, `tags`. Sources and status are recommended.

**Index is the entry point.** Always update `index.md` when adding/removing pages. Group by category with one-line descriptions.

**Log tracks history.** Append to `log.md` after every operation. Format: `## [YYYY-MM-DD] action | description`.

**Verify paths before recommending.** For codebase wikis, always Glob/Grep to confirm file paths exist before adding them to Wiki pages.

**Token budget awareness.** For Sonnet (200K context), load index + 3-5 pages selectively. For Opus (1M context), full Wiki loading is fine up to ~100K tokens.

**Obsidian compatible.** The Wiki uses standard Markdown with `[[wikilinks]]` and YAML frontmatter — it works out of the box as an Obsidian vault. Use Graph View to visualize connections, Dataview for dynamic queries.

## When NOT to Use This Skill

- Reading a single file (just use Read tool)
- Writing documentation from scratch without a Wiki structure
- Managing TODO lists or task tracking (use task tools)
- Git operations (use git commands)
