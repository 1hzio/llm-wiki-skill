# Wiki Page Enrichment Guide

## The Five Dimensions

Every Wiki page should aim to cover these five dimensions. Not all apply to every page, but strive for at least three.

### 1. What (Facts)
The baseline — what is this thing?
- Definitions, components, specifications
- Data structures, API endpoints, configurations
- **Verification**: can someone unfamiliar understand what this is?

### 2. Where (Location)
Concrete file paths so AI can directly locate code.
- Source file paths (verified via Glob/Grep, never guessed)
- Configuration file locations
- URL endpoints
- **Format**: use a "Key Files" table

```markdown
## Key Files

| File | Path | Description |
|------|------|-------------|
| UserService | `src/service/UserService.java` | Core user logic |
```

**Rule**: every path in the Wiki must be verified against the actual filesystem. A stale path is worse than no path — it sends AI to a dead end.

### 3. How (Process)
Step-by-step workflows and procedures.
- Numbered steps for processes
- Flow diagrams (ASCII art)
- Decision trees
- API call sequences

### 4. Why (Decisions)
Architecture decisions and rationale — the most underappreciated dimension.
- Why was technology X chosen over Y?
- What constraints drove this design?
- What trade-offs were made?

```markdown
## Architecture Decisions (Why)

- **Why Jimmer over JPA**: Jimmer's immutable objects and DSL queries 
  reduce boilerplate by 60%. JPA's mutable entities cause subtle bugs 
  with detached objects in async contexts.
```

**Why this matters**: without Why, AI will make decisions that seem reasonable but violate unstated constraints. With Why, AI can extrapolate to novel situations.

### 5. What Not (Anti-Patterns)
Mistakes to avoid — captured from real incidents and past pain.
- Anti-patterns specific to this codebase
- Past incidents and their root causes
- Common mistakes newcomers make

```markdown
## Anti-Pattern Warnings (What Not)

- **Don't bypass the transaction wrapper**: Direct DB updates skip 
  the audit log and wallet consistency check. Always go through 
  BatchProcessor.
- **Don't assume network in scheduled tasks**: Scheduled tasks run 
  without HTTP context. Use explicit TenantContext.runAs().
```

**Why this matters**: preventing one repeated mistake saves more time than documenting ten features.

## Completeness Scoring

Use this rubric to assess page quality:

| Score | Criteria |
|-------|----------|
| 20/100 | What only — page exists but AI can't act on it |
| 40/100 | What + Where — AI can locate files |
| 60/100 | What + Where + How — AI can follow processes |
| 80/100 | + Why — AI can make architectural judgments |
| 100/100 | + What Not — AI avoids known pitfalls |

## Prioritization

When enriching a Wiki with limited time:

1. **P0**: Add Where (file paths) to all pages — highest ROI, enables AI to skip exploration
2. **P1**: Add Why to architecturally critical pages (auth, data model, core flows)
3. **P2**: Add What Not to pages where past mistakes occurred
4. **P3**: Add How to complex processes
5. **P4**: Improve What coverage for missing topics
