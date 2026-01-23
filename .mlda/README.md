# MLDA - Modular Linked Documentation Architecture

A **knowledge graph** that agents navigate to gather context.

**Version:** 2.0 (Neocortex Methodology)
**Full Documentation:** [docs/NEOCORTEX.md](../docs/NEOCORTEX.md)

---

## The Neocortex Model

MLDA models documentation as a neural network:

```
           +---------------+
           |  DOC-API-001  |  <- Neuron (document)
           |   (neuron)    |
           +-------+-------+
                   | dendrite (relationship)
      +------------+------------+
      v            v            v
+----------+ +----------+ +----------+
|DOC-AUTH  | |DOC-DATA  | |DOC-SEC   |
|  -001    | |  -003    | |  -002    |
+----------+ +----------+ +----------+

Agent signal propagates through the network,
following dendrites based on task requirements.
```

| Brain Concept | MLDA Equivalent |
|---------------|-----------------|
| Neuron | Document |
| Dendrites | Relationships (`related` in sidecar) |
| Axon | DOC-ID (unique identifier) |
| Signal | Agent reading a document |
| Signal Propagation | Following relationships |

**Key Principle:** Stories and tasks are **entry points**, not complete specs. Agents navigate the graph to gather context.

---

## Quick Start

### Initialize MLDA in a New Project

**Via Skill (Recommended):**
```
/skills:init-project
```

**Via Analyst Mode:**
```
/modes:analyst
*init-project
```

**Via PowerShell:**
```powershell
.\.mlda\scripts\mlda-init-project.ps1 -Domains API,AUTH,INV
```

### Essential Commands

```bash
# Context gathering
/skills:gather-context       # Navigate knowledge graph from entry point

# Topic learning
/skills:manage-learning      # Save/load topic-based learnings

# In any mode
*explore {DOC-ID}           # Navigate from a document
*related                    # Show related documents
*context                    # Display gathered context
```

### Automatic Integration

Once MLDA is initialized, document-creating commands **automatically**:
- Assign DOC-IDs from the registry
- Create `.meta.yaml` sidecars (v2 schema)
- Update the registry
- Ask about related documents

---

## Structure

```
.mlda/
+-- topics/                    # Topic-based learning (Neocortex v2)
|   +-- {topic}/
|   |   +-- domain.yaml        # Sub-domain structure
|   |   +-- learning.yaml      # Accumulated learnings + activations
|   +-- _cross-domain/         # Cross-domain patterns
|   +-- _example/              # Template for new topics
+-- docs/                      # Topic documents
|   +-- {domain}/              # Organized by domain (auth/, api/, etc.)
|       +-- {topic}.md
|       +-- {topic}.meta.yaml  # Sidecar with relationships
+-- schemas/                   # YAML schemas for validation
+-- scripts/                   # MLDA tooling
+-- templates/                 # Document and config templates
+-- registry.yaml              # Index of all documents
+-- learning-index.yaml        # Two-tier learning index (DEC-007)
+-- config.yaml                # Neocortex configuration (optional)
+-- README.md                  # You are here
```

---

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `mlda-init-project.ps1` | Initialize MLDA in a project | `-Domains API,INV [-Migrate]` |
| `mlda-create.ps1` | Create a new topic document | `-Domain API -Title "My Doc"` |
| `mlda-registry.ps1` | Rebuild document registry | No args, or `-Graph` for connectivity |
| `mlda-validate.ps1` | Check link integrity | No args |
| `mlda-learning.ps1` | Manage topic learning | `-Topic X [-Save\|-Load]` |
| `mlda-generate-index.ps1` | Generate learning index | No args, or `-MaxInsightsPerTopic 5` |
| `mlda-handoff.ps1` | Generate handoff document | `-Phase analyst -Status completed` |
| `mlda-graph.ps1` | Visualize relationships | No args |
| `mlda-brief.ps1` | Regenerate project brief | No args |

---

## Templates

| Template | Purpose |
|----------|---------|
| `topic-doc.md` | Standard topic document |
| `topic-meta.yaml` | Basic sidecar (v1) |
| `topic-meta-v2.yaml` | Full sidecar with predictions/boundaries |
| `topic-domain.yaml` | Topic domain structure |
| `topic-learning.yaml` | Topic learning file |
| `learning-index.yaml` | Learning index for two-tier system |
| `neocortex-config.yaml` | Project configuration |
| `project-claude-md.md` | Project CLAUDE.md template |

---

## Topic-Based Learning

Learning persists in project files, loaded lazily per topic.

**Session Workflow:**
```
1. Session starts (minimal context)
2. User checks: bd ready
3. User selects task -> Agent identifies topic
4. Agent loads: .mlda/topics/{topic}/learning.yaml
5. Work proceeds with topic context
6. Session ends: Agent proposes saving new learnings
```

**Learning captures:**
- Document co-activation patterns
- Task-specific groupings
- Verification notes and lessons learned
- Cross-domain relationships

See [docs/NEOCORTEX.md](../docs/NEOCORTEX.md) for full schema and workflow.

---

## Two-Tier Learning System (DEC-007)

As projects grow, topic learning files can become large (60+ KB per topic). The two-tier system optimizes context usage by deferring full learning loads.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (loaded on mode awakening)              │
│  - Lightweight (~5-10 KB total)                                 │
│  - Lists all topics with summaries                              │
│  - Contains top 3-5 key insights per topic                      │
│  - Agent "knows what exists"                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (loaded when topic identified)           │
│  - Complete learning.yaml for active topic only                 │
│  - Loaded automatically (no manual command needed)              │
│  - Agent has full depth for current work                        │
└─────────────────────────────────────────────────────────────────┘
```

### Learning Index (`learning-index.yaml`)

A lightweight summary of all topic learnings, auto-generated from individual learning files.

**Location:** `.mlda/learning-index.yaml`

**Structure:**
```yaml
version: 1
generated_at: "2026-01-23"
generated_from: 16 topic learning files
total_sessions: 47

topics:
  AUTH:
    summary: "Session management, OAuth flow, token refresh patterns"
    sessions: 15
    size: "61 KB"
    key_insights:
      - "Refresh tokens in httpOnly cookies only"
      - "Access tokens: 15 min expiry, refresh: 7 days"
    primary_docs: [DOC-AUTH-001, DOC-AUTH-002]
    learning_path: .mlda/topics/AUTH/learning.yaml

  UI:
    summary: "Component patterns, accessibility, mobile-first design"
    sessions: 8
    # ... similar structure

empty_topics:
  - API
  - INFRA
```

### Index Auto-Regeneration (DEC-008)

The learning index is **automatically regenerated** whenever you save learnings via `*learning save`. No separate command needed - "update the learning" updates both files.

### Manual Regeneration (if needed)

For manual regeneration after creating new topics:

```powershell
.\.mlda\scripts\mlda-generate-index.ps1
```

Or via the manage-learning skill:
```
*learning-index
```

### Context Savings

| Scenario | Without Two-Tier | With Two-Tier | Savings |
|----------|------------------|---------------|---------|
| Mode awakening (no task) | 35-71 KB | 5-10 KB | ~25-60 KB |
| Working on specific topic | Full load upfront | Deferred until needed | Context preserved |
| Simple conversation | All learning loaded | Index only | Significant |

See [DEC-007](../docs/decisions/DEC-007-two-tier-learning.md) for two-tier architecture and [DEC-008](../docs/decisions/DEC-008-auto-regenerate-learning-index.md) for auto-regeneration.

---

## Sidecar Schema v2

Every document has a companion `.meta.yaml` sidecar:

```yaml
# Required
id: DOC-XXX-NNN
title: "Document Title"
status: draft | review | active | deprecated

# Timestamps & classification
created: { date: "YYYY-MM-DD", by: "Author" }
updated: { date: "YYYY-MM-DD", by: "Author" }
tags: []
domain: XXX

# Relationships (dendrites)
related:
  - id: DOC-YYY-NNN
    type: depends-on | extends | references | supersedes
    why: "Explanation"

# Neocortex v2 additions (optional)
predictions:          # What docs are needed for specific tasks
  when_implementing: { required: [], likely: [] }
  when_debugging: { required: [], likely: [] }

reference_frames:     # Classification metadata
  layer: requirements | design | implementation
  stability: evolving | stable | deprecated

boundaries:           # Traversal limits
  related_domains: []
  isolated_from: []

has_critical_markers: true | false
```

### Relationship Types

| Type | Signal | When to Follow |
|------|--------|----------------|
| `depends-on` | **Strong** | Always - cannot understand without target |
| `extends` | **Medium** | If depth allows - adds detail |
| `references` | **Weak** | If relevant to current task |
| `supersedes` | **Redirect** | Follow this instead of target |

---

## Context Management

### Thresholds

| Threshold | Tokens | Documents | Action |
|-----------|--------|-----------|--------|
| **Soft** | 35,000 | 8 | Self-assess, consider decomposition |
| **Hard** | 50,000 | 12 | Must decompose or pause |

### Multi-Agent Scaling

When context exceeds thresholds, propose decomposition:
```
1. Spawn sub-agents for sub-domains (recommended)
2. Progressive summarization
3. Proceed anyway (risk: degradation)
```

See [docs/NEOCORTEX.md](../docs/NEOCORTEX.md) for verification stack and structured return formats.

---

## Creating a Topic Document

### Option 1: Using the Script (Recommended)

```powershell
.\.mlda\scripts\mlda-create.ps1 -Domain API -Title "REST Endpoints"
```

This automatically:
- Assigns the next DOC-ID
- Creates both `.md` and `.meta.yaml` files
- Updates the registry

### Option 2: Manual Creation

1. **Pick a domain** (e.g., `auth`, `api`, `inv`)
2. **Create the folder** if needed: `.mlda/docs/auth/`
3. **Copy templates** and rename:
   - `.mlda/docs/auth/access-control.md`
   - `.mlda/docs/auth/access-control.meta.yaml`
4. **Assign DOC-ID**: `DOC-AUTH-001`
5. **Fill in content** and metadata
6. **Run**: `.\.mlda\scripts\mlda-registry.ps1`

---

## DOC-ID Convention

```
DOC-{DOMAIN}-{NNN}

Examples:
- DOC-AUTH-001   (Authentication topic #1)
- DOC-API-003    (API topic #3)
- DOC-SEC-012    (Security topic #12)
```

### Standard Domains

| Code | Domain |
|------|--------|
| API | API specifications |
| AUTH | Authentication |
| DATA | Data models |
| SEC | Security |
| UI | User Interface |
| INFRA | Infrastructure |
| INT | Integrations |
| TEST | Testing |
| PROC | Processes/protocols |
| METH | Methodology |

Custom domains can be added per project.

---

## Migration

For existing projects with documents:

```powershell
.\.mlda\scripts\mlda-init-project.ps1 -Domains INV -Migrate
```

The `-Migrate` flag:
- Creates `.meta.yaml` sidecars for existing `.md` files
- Assigns DOC-IDs sequentially
- Adds entries to registry

### Backward Compatibility

- Sidecar v2 fields are **optional** - old sidecars work
- Topics folder is **optional** - works without learning
- Config is **optional** - default thresholds apply

---

## References

| Document | Purpose |
|----------|---------|
| [docs/NEOCORTEX.md](../docs/NEOCORTEX.md) | Full methodology documentation |
| [DEC-002](../docs/decisions/DEC-002-neocortex-methodology.md) | Decision record with rationale |
| [CLAUDE.md](../CLAUDE.md) | Project rules layer |

---

*MLDA v2.1 | Neocortex Methodology*
