# LLM Wiki Skill

A [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code) for building and maintaining persistent, structured knowledge bases using Markdown files.

Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — instead of retrieving from raw documents each time (RAG), you **compile** knowledge into a persistent Wiki that grows richer with every interaction.

## Why?

Traditional approaches (RAG, file uploads) start from scratch every query. LLM Wiki is different:

- **Knowledge compounds** — each ingestion builds on previous ones
- **Cross-references are pre-built** — no re-discovery needed
- **Contradictions are flagged** — inconsistencies don't hide
- **AI gets smarter per-project** — Wiki carries context across sessions

Real-world impact: **~55% token reduction** per coding task when the Wiki covers the codebase well enough to skip exploration.

## Install

```bash
# From skills.sh (recommended)
npx skills add 1hzio/agent-skills --skill wikic

# Claude Code CLI
claude skill install /path/to/agent-skills/wikic

# Or add to .claude/settings.json
{
  "skills": ["/path/to/agent-skills/wikic"]
}
```

## Quick Start

```
> /wikic init                          # Initialize a new Wiki
> /wikic ingest src/                   # Ingest codebase structure
> /wikic batch-ingest raw/             # Ingest all files in a folder
> /wikic query "How does auth work?"   # Query with Wiki context
> /wikic digest "authentication"       # Deep cross-source synthesis
> /wikic compound                      # Capture experience from solved problem
> /wikic lint                          # Audit Wiki health
> /wikic trace "deposit flow"          # Map cross-repo feature
> /wikic graph                         # Generate knowledge graph
> /wikic stats                         # Show Wiki metrics
```

## Commands

| Command | Description |
|---------|-------------|
| `/wikic init [path] [--project\|--research\|--team]` | Initialize Wiki with template |
| `/wikic ingest <source>` | Add knowledge from source |
| `/wikic batch-ingest <folder> [--category <cat>]` | Ingest all files in a folder |
| `/wikic query <question>` | Answer using Wiki knowledge |
| `/wikic digest <topic>` | Deep cross-source synthesis |
| `/wikic compound` | Capture experience from solved problem |
| `/wikic lint` | Audit health, find issues |
| `/wikic trace <feature>` | Map cross-repo feature files |
| `/wikic graph` | Generate Mermaid knowledge graph |
| `/wikic stats` | Show metrics and token estimates |

## Wiki Structure

```
docs/wiki/
├── CLAUDE.md      # Schema — how LLM operates this Wiki
├── index.md       # Page index (entry point for AI)
├── log.md         # Operation history
├── page-a.md      # Knowledge pages...
├── page-b.md
└── trace-*.md     # Cross-repo traces
```

## Page Quality Model

Every page is scored on five dimensions:

| Dimension | What it covers | Impact |
|-----------|---------------|--------|
| **What** | Facts, definitions | Baseline understanding |
| **Where** | Source file paths | AI skips Grep exploration |
| **How** | Step-by-step processes | AI follows correct workflow |
| **Why** | Design decisions | AI makes consistent judgments |
| **What Not** | Anti-patterns, pitfalls | AI avoids known mistakes |

## Templates

Three Wiki templates for different use cases:

- **`--project`** — Codebase knowledge: architecture, tech stack, flows, data models
- **`--research`** — Research synthesis: papers, concepts, entities, explorations
- **`--team`** — Team knowledge: processes, decisions, incidents, onboarding

## Token Economics

| Wiki Size | Est. Tokens | Sonnet 200K | Opus 1M |
|-----------|-------------|-------------|---------|
| 10 pages | ~8K | 4% | 0.8% |
| 30 pages | ~30K | 15% | 3% |
| 50 pages | ~55K | 27% | 5.5% |
| 100 pages | ~100K | 50% | 10% |

For Sonnet, load selectively (index + 3-5 pages). For Opus, full loading works up to ~100 pages.

## Obsidian Compatible

The Wiki uses standard Markdown with `[[wikilinks]]` and YAML frontmatter — it works out of the box as an [Obsidian](https://obsidian.md) vault. Use Graph View to visualize connections, Dataview for dynamic queries.

## Credits

- Core idea: [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- Enrichment model & implementation: Built from real-world usage on a multi-repo IoT project

## License

MIT
