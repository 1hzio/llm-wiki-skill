# Wiki Page Templates

## Architecture Page

```markdown
---
title: "Component Name"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [architecture]
---

> TLDR: One-line summary of this architectural component.

## Overview
What this component does and why it exists.

## Key Components
- Component A: description
- Component B: description

## Communication Patterns
How this component interacts with others.

## Key Files

| File | Path | Description |
|------|------|-------------|
| MainClass | `src/path/to/MainClass.java` | Entry point |

## Architecture Decisions (Why)

- **Why X over Y**: rationale...

## Anti-Pattern Warnings (What Not)

- **Don't do X**: because...

## Related
- [[other-component]] — relationship
```

## Tech Stack Page

```markdown
---
title: "Project Tech Stack"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tech-stack]
---

> TLDR: Core technologies used in this project.

## Core Framework
- Language: X
- Framework: Y
- ORM/DB: Z

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| lib-a | ^1.0 | State management |

## Development Tools
- Build: ...
- Lint: ...
- Test: ...

## Key Files

| File | Path | Description |
|------|------|-------------|
| package.json | `package.json` | Dependencies |

## Architecture Decisions (Why)

- **Why this framework**: rationale...
```

## Business Flow Page

```markdown
---
title: "Feature Flow"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [flow, business]
---

> TLDR: How [feature] works end-to-end.

## Flow Overview

```
Step 1 → Step 2 → Step 3 → Step 4
```

## Detailed Steps

### 1. Step Name
What happens, who initiates, what data flows.

### 2. Step Name
...

## Key Files

| File | Path | Description |
|------|------|-------------|
| Controller | `src/web/Controller.java` | API entry |

## Architecture Decisions (Why)

- **Why async**: rationale...

## Anti-Pattern Warnings (What Not)

- **Don't bypass X**: because...

## Related
- [[related-flow]] — upstream/downstream
```

## Cross-Repo Trace Page

```markdown
---
title: "Cross-Repo Trace: Feature Name"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [trace, cross-repo]
---

> TLDR: All files involved in [feature] across all repositories.

## 1. Frontend (repo-name)

| Step | File | Description |
|------|------|-------------|
| User action | `src/pages/Feature.vue` | Entry point |

## 2. API Layer (backend-repo)

| Step | File | Description |
|------|------|-------------|
| POST /api/x | `src/web/Controller.java` | Endpoint |

## 3. Business Logic (backend-repo)

| Step | File | Description |
|------|------|-------------|
| Process | `src/service/Service.java` | Core logic |

## 4. Data Layer

| Step | File | Description |
|------|------|-------------|
| Query | `src/repo/Repository.java` | Data access |
```

## Entity / Data Model Page

```markdown
---
title: "Data Model: Entity Name"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [entity, data-model]
---

> TLDR: Core data entities and their relationships.

## Entities

### EntityA
- Field 1: type — description
- Field 2: type — description
- Relationships: belongs to EntityB, has many EntityC

### EntityB
...

## Entity Relationship Diagram

```
EntityA ──1:N──> EntityC
    │
    └──N:1──> EntityB
```

## Key Files

| File | Path | Description |
|------|------|-------------|
| EntityA | `src/domain/EntityA.java` | Entity definition |
```
