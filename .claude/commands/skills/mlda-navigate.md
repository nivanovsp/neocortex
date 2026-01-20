---
description: 'Navigate MLDA knowledge graph - explore documents, follow relationships, gather context'
---
# MLDA Navigate Skill

**RMS Skill v2.0** | Knowledge graph traversal and context gathering with Neocortex sidecar v2 support

This skill enables agents to navigate the MLDA documentation graph by following relationships (dendrites) between documents (neurons). See DOC-CORE-001 (Neocortex Paradigm) and DOC-CORE-002 (Navigation Protocol) for conceptual foundation.

## Prerequisites

- `.mlda/` folder must exist in project root
- `.mlda/registry.yaml` must be present
- Documents must have `.meta.yaml` sidecars with `related` fields

## Commands

This skill provides these navigation commands:

| Command | Description |
|---------|-------------|
| `*explore {DOC-ID}` | Start navigation from a specific document |
| `*explore --entry {ID1,ID2}` | Multiple entry points |
| `*explore --depth N` | Set max traversal depth (default: 3) |
| `*related` | Show documents related to current context |
| `*context` | Display gathered context summary |
| `*graph {DOC-ID}` | Visualize local graph around a document |

---

## Execution Flow

### Step 1: Verify MLDA Active

```
Check for .mlda/ folder in project root

IF .mlda/ folder exists:
  → Read .mlda/registry.yaml
  → Count documents and domains
  → Report: "MLDA active: {N} documents across {domains}"
ELSE:
  → Report: "MLDA not initialized. Run /skills:init-project first."
  → EXIT
```

### Step 2: Parse Entry Points

Entry points can come from:

1. **Explicit command:** `*explore DOC-API-001`
2. **Multiple entries:** `*explore --entry DOC-API-001,DOC-AUTH-002`
3. **Current story/task:** Parse DOC-IDs from story file
4. **User query:** "I need to understand authentication" → search registry tags

**If no entry points provided:**
```
Ask user:
"No entry point specified. How would you like to start?

1. Search by keyword (I'll search registry tags)
2. Browse domains (list available domains)
3. Enter DOC-ID directly
4. Use recent documents

Select 1-4:"
```

### Step 3: Validate Entry Points

```
FOR each entry_point:
  IF exists in registry.yaml:
    → Add to traversal queue
    → Report: "✓ Found: {DOC-ID} - {title}"
  ELSE:
    → Report: "⚠ Not found: {DOC-ID}"
    → Suggest similar IDs if available
```

### Step 4: Initialize Traversal

```yaml
traversal_state:
  visited: []
  queue: [{entry_points}]
  context_gathered: []
  current_depth: 0
  max_depth: 3  # or user-specified
  max_documents: 20
```

### Step 5: Execute Traversal Loop

```
WHILE queue NOT empty
  AND visited.length < max_documents
  AND current_depth < max_depth:

  current = queue.pop_first()

  IF current IN visited:
    CONTINUE  # Skip already processed

  # Read document and sidecar
  doc = read_document(current.path)
  sidecar = read_sidecar(current.path)

  # Add to visited
  visited.add(current)

  # Extract context
  context_gathered.add({
    id: current,
    title: sidecar.title,
    summary: sidecar.summary OR first_paragraph(doc),
    tags: sidecar.tags
  })

  # Report progress
  Report: "📄 Reading: {current} - {sidecar.title}"

  # Evaluate relationships (dendrites)
  FOR each rel IN sidecar.related:
    IF should_follow(rel):
      queue.add(rel.id)
      Report: "  → Following: {rel.id} ({rel.type}: {rel.why})"
    ELSE:
      Report: "  · Skipping: {rel.id} (low relevance)"
```

### Step 6: Should Follow Decision

Evaluate each relationship using v2 fields:

```
FUNCTION should_follow(relationship, task_context, current_sidecar, target_sidecar):

  # Check v2 boundaries first
  IF current_sidecar.boundaries.isolated_from CONTAINS target_sidecar.domain:
    LOG "Boundary: isolated from " + target_sidecar.domain
    RETURN false

  # Check if crossing domain boundary
  IF target_sidecar.domain != entry_domain:
    IF target_sidecar.domain NOT IN current_sidecar.boundaries.related_domains:
      LOG "Boundary: stopping at " + target_sidecar.domain
      NOTE_DEPENDENCY(target_sidecar)  # Note but don't traverse
      RETURN false

  # Check v2 reference_frames alignment (optional filter)
  IF task_context.scope AND target_sidecar.reference_frames.scope:
    IF target_sidecar.reference_frames.scope NOT IN [task_context.scope, "cross-cutting"]:
      # Lower priority, may skip if at depth limit
      priority = LOW

  # Always follow dependencies
  IF relationship.type == "depends-on":
    RETURN true

  # Always follow supersedes (and mark target obsolete)
  IF relationship.type == "supersedes":
    RETURN true

  # Follow extends if depth allows
  IF relationship.type == "extends" AND current_depth < max_depth - 1:
    RETURN true

  # For references, check relevance
  IF relationship.type == "references":
    # Check if 'why' field matches task keywords
    IF relationship.why MATCHES task_context.keywords:
      RETURN true
    RETURN false

  # No type specified - treat as weak reference
  RETURN relevance_score(relationship.why) > 0.5
```

### Step 7: Termination Check

Stop traversal when:

```
IF queue IS empty:
  Report: "Navigation complete - no more relationships to follow"

IF visited.length >= max_documents:
  Report: "Navigation complete - document limit ({max_documents}) reached"

IF current_depth >= max_depth:
  Report: "Navigation complete - depth limit ({max_depth}) reached"

IF user_interrupt:
  Report: "Navigation stopped by user"
```

### Step 8: Generate Navigation Report

```markdown
## Navigation Summary

**Entry Points:** DOC-API-001, DOC-AUTH-002
**Documents Explored:** 8
**Depth Reached:** 3
**Termination:** Sufficient context gathered

### Traversal Path

```
DOC-API-001 (API Endpoints)
├── DOC-AUTH-001 (Authentication) [depends-on]
│   └── DOC-SEC-002 (Security Policies) [depends-on]
├── DOC-DATA-003 (Data Models) [depends-on]
└── DOC-UI-007 (Frontend Integration) [references]

DOC-AUTH-002 (Authorization)
└── DOC-AUTH-001 (Authentication) [already visited]
```

### Context Gathered

| DOC-ID | Title | Key Points |
|--------|-------|------------|
| DOC-API-001 | API Endpoints | REST API spec, 15 endpoints |
| DOC-AUTH-001 | Authentication | JWT tokens, refresh flow |
| ... | ... | ... |

### Documents Not Visited

These related documents were identified but not explored:
- DOC-UI-012 (low relevance to current task)
- DOC-TEST-003 (testing docs, not needed for implementation)

### Open Questions

- DOC-DATA-003 mentions migration strategy - should this be explored?
- Security requirements in DOC-SEC-002 need architect review
```

---

## Context Commands

### `*related`

Show documents related to current navigation context:

```markdown
## Related Documents

Based on your current context (8 documents explored):

**Directly Related (in visited docs):**
- DOC-UI-012 - Frontend Components (referenced by DOC-API-001)
- DOC-TEST-003 - API Test Suite (referenced by DOC-API-001)

**Potentially Related (registry search):**
- DOC-PERF-001 - Performance Guidelines (shares tags: api, optimization)
- DOC-ERROR-002 - Error Handling (shares tags: api, validation)

Explore any of these? Enter DOC-ID or 'skip':
```

### `*context`

Display gathered context summary:

```markdown
## Gathered Context

**Navigation Session:** Started from DOC-API-001
**Documents Read:** 8
**Total Context Tokens:** ~2,400

### Key Information Extracted

**Authentication:**
- JWT-based, 15-minute access tokens
- Refresh tokens stored in httpOnly cookies
- Source: DOC-AUTH-001

**Data Models:**
- Invoice entity with 12 fields
- Transaction items as embedded documents
- Source: DOC-DATA-003

**API Patterns:**
- RESTful with JSON responses
- Rate limiting: 100 req/min
- Source: DOC-API-001

### Decisions Found

1. "Use UUID v4 for all entity IDs" (DOC-DATA-003)
2. "Prefer soft deletes over hard deletes" (DOC-DATA-003)
3. "All endpoints require authentication except /health" (DOC-API-001)
```

### `*graph {DOC-ID}`

Visualize local graph (text-based):

```
            ┌──────────────┐
            │ DOC-AUTH-002 │
            │Authorization │
            └──────┬───────┘
                   │ depends-on
                   ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ DOC-API-001  │──│ DOC-AUTH-001 │──│ DOC-SEC-002  │
│ API Endpoints│  │Authentication│  │Security Pol. │
└──────────────┘  └──────────────┘  └──────────────┘
       │                 │
       │ depends-on      │ extends
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ DOC-DATA-003 │  │ DOC-AUTH-005 │
│ Data Models  │  │ Token Refresh│
└──────────────┘  └──────────────┘

Legend: ─── depends-on  ═══ extends  ··· references
```

---

## Integration with Agents

### Automatic Navigation on Story Receipt

When an agent receives a story containing DOC-ID references:

```
1. Parse story for DOC-ID patterns (DOC-XXX-NNN, REQ-XXX-NNN, etc.)
2. If DOC-IDs found:
   → "Found {N} document references in story. Navigating..."
   → Auto-execute navigation from those entry points
   → Present context summary
   → "Ready to proceed. Need me to explore any specific area deeper?"
3. If no DOC-IDs found:
   → "No document references in story. Proceeding without MLDA context."
```

### Session Persistence

Navigation context persists for the session:
- Visited documents remembered
- Gathered context available for queries
- Can resume navigation with `*explore --continue`

---

## Error Handling

| Situation | Response |
|-----------|----------|
| Registry not found | "MLDA registry not found. Run `.mlda/scripts/mlda-registry.ps1` to rebuild." |
| Document not found | "Document {ID} not in registry. It may have been removed or renamed." |
| Sidecar missing | "Warning: {ID} has no sidecar. Reading document without relationships." |
| Circular reference | "Detected cycle: {path}. Skipping to avoid infinite loop." |
| Empty registry | "Registry is empty. Create documents first with `/skills:create-doc`." |

---

## Dependencies

```yaml
requires:
  - .mlda/registry.yaml
references:
  - DOC-CORE-001 (Neocortex Paradigm)
  - DOC-CORE-002 (Navigation Protocol)
  - DOC-CORE-003 (Sidecar Schema)
```

---

## Invocation

This skill can be invoked via:
- `/skills:mlda-navigate`
- `*explore {DOC-ID}` (when in any agent mode)
- `*related` (when in any agent mode)
- `*context` (when in any agent mode)
- `*graph {DOC-ID}` (when in any agent mode)
