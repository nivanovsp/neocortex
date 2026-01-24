# Neocortex Methodology

> "The Neocortex methodology, built on the RMS framework"

**Version:** 2.1
**Decision Record:** [DEC-002](decisions/DEC-002-neocortex-methodology.md)

---

## Overview

Neocortex is a methodology for AI-assisted software development where documentation forms a **knowledge graph** that agents navigate like signals through a neural network.

| Concept | Description |
|---------|-------------|
| **Documents** | Neurons - units of knowledge |
| **Relationships** | Dendrites - connections between documents |
| **DOC-IDs** | Axons - unique identifiers enabling connections |
| **Agent reading** | Signal activation |
| **Following relationships** | Signal propagation |

**Key Principle:** Tasks are entry points into the knowledge graph, not self-contained specs. Agents navigate to gather context.

---

## Quick Reference

### RMS Framework Layers

| Layer | Location | Purpose |
|-------|----------|---------|
| **Rules** | `CLAUDE.md` | Universal standards, always active |
| **Modes** | `commands/modes/` | Expert personas (`/modes:analyst`, `/modes:architect`, `/modes:dev`) |
| **Skills** | `commands/skills/` | Discrete workflows (`/skills:gather-context`, `/skills:create-doc`) |

### Core Workflow (5 Phases)

```
┌──────────┐     ┌───────────┐     ┌───────────┐     ┌──────────┐     ┌───────────┐
│ Analyst  │ ──► │ Architect │ ──► │ UX-Expert │ ──► │ Analyst  │ ──► │ Developer │
│ (Maya)   │     │ (Winston) │     │ (Uma)     │     │ (stories)│     │ (Devon)   │
└──────────┘     └───────────┘     └───────────┘     └──────────┘     └───────────┘
```

| Phase | Role | Mode | Purpose |
|-------|------|------|---------|
| 1 | Analyst | `/modes:analyst` | Requirements, PRDs, epics |
| 2 | Architect | `/modes:architect` | Critical review, architecture docs |
| 3 | UX-Expert | `/modes:ux-expert` | UI/UX design, wireframes, design system |
| 4 | Analyst | `/modes:analyst` | Stories from UX specs |
| 5 | Developer | `/modes:dev` | Implementation, test-first, quality gates |

Each phase hands off via `docs/handoff.md` with **open questions** for the next role.

### Essential Commands

```bash
# Modes
/modes:analyst          # Requirements, PRDs, stories
/modes:architect        # Design, technical review
/modes:ux-expert        # UI/UX design, wireframes
/modes:dev              # Implementation, testing (Dev+QA combined)

# Skills
/skills:gather-context  # Navigate knowledge graph
/skills:manage-learning # Save/load topic learnings
/skills:handoff         # Generate phase transition doc

# In-mode
*help                   # Show mode commands
*exit                   # Leave mode
*explore {DOC-ID}       # Navigate from document
```

---

## Project Structure

```
project/
├── .mlda/
│   ├── topics/                    # Topic-based learning (NEW)
│   │   ├── {topic}/
│   │   │   ├── domain.yaml        # Sub-domain structure
│   │   │   └── learning.yaml      # Accumulated learnings + activations
│   │   ├── _cross-domain/
│   │   │   └── patterns.yaml      # Cross-domain patterns
│   │   └── _example/              # Template for new topics
│   ├── docs/                      # Topic documents
│   │   └── {domain}/
│   │       ├── {topic}.md
│   │       └── {topic}.meta.yaml
│   ├── scripts/                   # MLDA tooling
│   ├── templates/                 # Document templates
│   ├── registry.yaml              # Document index
│   └── config.yaml                # Neocortex configuration
├── docs/
│   ├── decisions/                 # Decision records (DEC-xxx)
│   ├── handoff.md                 # Phase transition document
│   └── NEOCORTEX.md               # This file
├── CLAUDE.md                      # Project rules
└── .beads/                        # Task tracking
```

---

## Sidecar Schema v2

Every document has a companion `.meta.yaml` sidecar:

```yaml
# Required
id: DOC-XXX-NNN
title: "Document Title"
status: draft | review | active | deprecated

# Timestamps
created:
  date: "YYYY-MM-DD"
  by: "Author"
updated:
  date: "YYYY-MM-DD"
  by: "Author"

# Classification
tags: []
domain: XXX  # AUTH, API, DATA, SEC, etc.

# Relationships
related:
  - id: DOC-YYY-NNN
    type: depends-on | extends | references | supersedes
    why: "Explanation"

# Predictive Context (NEW)
predictions:
  when_eliciting:
    required: []
    likely: []
  when_architecting:
    required: []
    likely: []
  when_implementing:
    required: []
    likely: []
  when_debugging:
    required: []
    likely: []

# Reference Frames (NEW)
reference_frames:
  domain: string
  layer: requirements | design | implementation | testing
  stability: evolving | stable | deprecated
  scope: frontend | backend | infrastructure | cross-cutting

# Traversal Boundaries (NEW)
boundaries:
  related_domains: []
  isolated_from: []

# Critical markers flag
has_critical_markers: true | false

# Beads tracking
beads: "Project-ID"
```

### Relationship Types

| Type | Signal Strength | When to Follow |
|------|-----------------|----------------|
| `depends-on` | **Strong** | Always - cannot understand without target |
| `extends` | **Medium** | If depth allows - adds detail |
| `references` | **Weak** | If relevant to current task |
| `supersedes` | **Redirect** | Follow this instead of target |

### Prediction Task Types

| Role | Task Types |
|------|------------|
| **Analyst** | `when_eliciting`, `when_documenting` |
| **Architect** | `when_architecting`, `when_reviewing_design` |
| **Developer** | `when_implementing`, `when_debugging`, `when_testing` |

---

## Topic-Based Learning

Learning persists in project files, loaded lazily per topic.

### Learning File Schema

```yaml
# .mlda/topics/{topic}/learning.yaml
topic: authentication
version: 3
last_updated: 2026-01-20
sessions_contributed: 12

groupings:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003]
    origin: agent | human
    confidence: high | medium | low

activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002]
    frequency: 7
    typical_tasks: [architecting, implementing]

verification_notes:
  - session: 2026-01-15
    caught: "PCI-DSS requirement in DOC-AUTH-003"
    lesson: "Check compliance markers in token docs"

related_domains:
  - domain: rbac
    relationship: "Auth provides identity for RBAC"
    typical_overlap: [DOC-AUTH-008, DOC-RBAC-001]
```

### Session Workflow

```
1. Session starts (minimal context)
2. User checks beads: `bd ready`
3. User selects task: "Let's work on TASK-AUTH-003"
4. Agent identifies topic: authentication
5. Agent loads: .mlda/topics/authentication/learning.yaml
6. Work proceeds with topic context
7. Session ends: Agent proposes saving new learnings
```

### Two-Tier Learning System (DEC-007)

As projects grow, topic learning files can become large (60+ KB per topic). The two-tier system optimizes context:

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (loaded on mode awakening)              │
│  File: .mlda/learning-index.yaml (~5-10 KB)                     │
│  - Contains topic summaries and top insights                    │
│  - Agent "knows what exists" without full load                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (loaded when topic identified)           │
│  File: .mlda/topics/{topic}/learning.yaml                       │
│  - Complete learning for active topic only                      │
│  - Full depth available for current work                        │
└─────────────────────────────────────────────────────────────────┘
```

**Reference:** [DEC-007](decisions/DEC-007-two-tier-learning.md)

### Auto-Regeneration (DEC-008)

When learnings are saved via `*learning save`, the learning index is automatically regenerated. No separate command needed.

**Manual regeneration:**
```powershell
.\.mlda\scripts\mlda-generate-index.ps1
```

**Reference:** [DEC-008](decisions/DEC-008-auto-regenerate-learning-index.md)

---

## Activation Protocol (DEC-009)

Mode activation is optimized through a pre-computed activation context file.

### Unified Activation Flow

```
1. Mode awakens → Load activation-context.yaml (single file, ~50-80 lines)
2. Agent has: MLDA status, handoff summary, learning highlights, config
3. Deep context (full handoff, registry, learning) loaded ON-DEMAND only
```

### Activation Context File

**Location:** `.mlda/activation-context.yaml`

Pre-computed from registry, handoff, learning-index, and config. Contains:
- MLDA status (doc count, domains, health)
- Handoff summary (current phase, ready items, open questions)
- Learning highlights (topic counts, top insights)
- Config essentials (context limits)

### Context Savings

| Scenario | Without DEC-009 | With DEC-009 | Reduction |
|----------|-----------------|--------------|-----------|
| Mode awakening | ~2100 lines | ~50-80 lines | ~97% |

### Auto-Regeneration Triggers

- Learning saves (`*learning save`) - chained from DEC-008
- Handoff updates (`*handoff`)
- Registry updates (document creation)

**Manual regeneration:**
```powershell
.\.mlda\scripts\mlda-generate-activation-context.ps1
```

**Fallback:** If `activation-context.yaml` doesn't exist, modes fall back to individual file reads (DEC-007 behavior).

**Reference:** [DEC-009](decisions/DEC-009-activation-context-optimization.md)

---

## Context Gathering

### Two-Phase Loading

**Phase 1 - Metadata only:**
- Load sidecars, not full documents
- Assess relevance scores
- Build context summary

**Phase 2 - Selective full load:**
- Load high-relevance documents fully
- Load specific sections from medium-relevance
- Skip low-relevance entirely

### Traversal Rules

1. Follow `depends-on` relationships always
2. Follow `extends` if within depth limit
3. Follow `references` only if directly relevant
4. **Stop at domain boundaries** unless task explicitly requires crossing
5. Never traverse into `isolated_from` domains

### Gather Context Algorithm

```
1. Load entry document (from task/story)
2. Identify task type (implementing, debugging, etc.)
3. Check predictions[task_type] for required/likely docs
4. For each predicted doc:
   a. Assess relevance to current task
   b. If relevant: load and recurse
   c. If not: note for potential later use
5. Monitor context size against thresholds
6. Return structured context object
```

---

## Token Budget Management

### Thresholds

```yaml
# .mlda/config.yaml
context_limits:
  soft_threshold_tokens: 35000    # Trigger self-assessment
  hardstop_tokens: 50000          # Must decompose or pause
  soft_threshold_documents: 8
  hardstop_documents: 12
```

### Task-Specific Overrides

| Task Type | Soft Threshold | Hardstop |
|-----------|---------------|----------|
| Research | 50k | 70k |
| Document creation | 30k | 45k |
| Review | 40k | 55k |
| Architecture | 30k | 45k |

### Self-Assessment (at soft threshold)

1. Can I recall key points from earlier documents?
2. Am I re-reading sections I already processed?
3. Are my extractions becoming vague?
4. Can I see connections between documents?
5. Am I making assumptions I shouldn't need to?

**If 2+ concerning → Recommend decomposition**

---

## Multi-Agent Scaling

When context exceeds thresholds, decompose into sub-agents.

### Trigger

```
Agent detects: 15 documents, context growing large

Proposes:
1. Spawn sub-agents for each sub-domain (recommended)
2. Progressive summarization
3. Proceed anyway (risk: degradation)
```

### Sub-Agent Structure

```
Primary Agent
│
├─► Sub-Agent-1: Token management (4 docs)
├─► Sub-Agent-2: Session handling (3 docs)
├─► Sub-Agent-3: OAuth integration (4 docs)
└─► Sub-Agent-4: RBAC dependencies (4 docs)

Each returns structured summary → Primary synthesizes
```

### Structured Return Format

```yaml
sub_domain: token-management
documents_processed: [DOC-AUTH-002, DOC-AUTH-003]

key_requirements:
  - requirement: "JWT with 15-min expiry"
    source: {doc: DOC-AUTH-002, section: "2.1"}
    confidence: high

critical_items:
  - marker: "compliance"
    content: "Max 15 min per PCI-DSS 8.1.8"
    source: DOC-AUTH-003, line 47
    verbatim: true

dependencies_identified:
  - doc_id: DOC-RBAC-001
    reason: "Token claims need roles"

meta:
  completeness_confidence: medium
  uncertainty_flags:
    - {doc: DOC-AUTH-007, section: "3.2", reason: "Ambiguous"}
  recommend_primary_review: [DOC-AUTH-007 section 3.2]
```

---

## Verification Stack

Six layers to ensure sub-agent summaries don't miss critical information.

| Layer | Status | Purpose |
|-------|--------|---------|
| **1. Structured Extraction** | Mandatory | Template-driven, not open summarization |
| **2. Critical Markers** | Mandatory | `<!-- CRITICAL -->` always extracted verbatim |
| **3. Confidence Self-Assessment** | Mandatory | Report uncertainty and recommend reviews |
| **4. Provenance Tracking** | Mandatory | Every claim traces to source |
| **5. Cross-Verification** | Optional | Two independent sub-agents compare outputs |
| **6. Verification Pass** | Optional | Primary spot-checks suspicious absences |

### Critical Markers in Documents

```markdown
## Token Expiry Policy

<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8.
<!-- /CRITICAL -->
```

Sub-agents **always** extract CRITICAL markers verbatim.

---

## Critical Thinking Protocol

Always active across all modes. See [DEC-001](decisions/DEC-001-critical-thinking-protocol.md).

### Quick Reference

**Dispositions:**
- Accuracy over speed
- Acknowledge uncertainty
- Question assumptions
- Consider alternatives

**Triggers (pause and think deeper):**
- Ambiguous requirements
- Security/auth/data integrity
- Multi-file coordinated changes
- Contradicts earlier context
- Solution feels "too easy"
- Modifying existing code

**Uncertainty Language:**
| Level | Pattern |
|-------|---------|
| High | "This will..." |
| Medium | "This should..." |
| Low | "This might..." |
| Assumption | "I'm assuming [X]—verify" |
| Gap | "I don't have info on [X]" |

---

## Beads Integration

Use Beads (`bd`) for task tracking across sessions.

```bash
bd ready                    # Show unblocked tasks
bd update <id> --status in_progress
bd close <id> --reason "Done"
bd create "Title" -t task -p 1 --deps "id1,id2"
```

### Topic from Task

Agent identifies topic by:
1. Explicit domain tag in task metadata
2. DOC-ID references in task (DOC-AUTH-xxx → authentication)
3. Inference from description (confirm if uncertain)

---

## Initialization

### New Project

```bash
/skills:init-project
# or
/modes:analyst → *init-project
```

### Existing Project (Migration)

```bash
.\.mlda\scripts\mlda-init-project.ps1 -Domains API,AUTH -Migrate
```

The `-Migrate` flag creates sidecars for existing documents.

### Backward Compatibility

- Sidecar v2 fields are **optional** - old sidecars work
- Topics folder is **optional** - works without learning
- Predictions are **optional** - fallback to relationship traversal
- Config is **optional** - default thresholds apply

---

## Configuration

### .mlda/config.yaml

```yaml
# Neocortex Configuration
version: "2.0"

# Token budget management
context_limits:
  soft_threshold_tokens: 35000
  hardstop_tokens: 50000
  soft_threshold_documents: 8
  hardstop_documents: 12

  by_task_type:
    research:
      soft_threshold: 50000
      hardstop: 70000
    document_creation:
      soft_threshold: 30000
      hardstop: 45000

# Learning behavior
learning:
  auto_save_prompt: true      # Ask to save learnings at session end
  activation_logging: true    # Track co-activation patterns

# Verification
verification:
  cross_verification_domains: [security, compliance]  # Always use Layer 5
  critical_marker_syntax: "<!-- CRITICAL: {type} -->"
```

---

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `mlda-init-project.ps1` | Initialize MLDA | `-Domains X,Y [-Migrate]` |
| `mlda-create.ps1` | Create topic document | `-Domain X -Title "Y"` |
| `mlda-registry.ps1` | Rebuild registry | No args, or `-Graph` |
| `mlda-validate.ps1` | Check link integrity | No args |
| `mlda-learning.ps1` | Manage topic learning | `-Topic X [-Save\|-Load]` |
| `mlda-graph.ps1` | Visualize relationships | No args |
| `mlda-generate-index.ps1` | Generate learning index | No args |
| `mlda-generate-activation-context.ps1` | Generate activation context | No args |

---

## DOC-ID Convention

```
DOC-{DOMAIN}-{NNN}

Examples:
DOC-AUTH-001  (Authentication #1)
DOC-API-003   (API #3)
DOC-SEC-012   (Security #12)
```

### Standard Domains

| Code | Domain |
|------|--------|
| API | API specifications |
| AUTH | Authentication |
| DATA | Data models |
| SEC | Security |
| UI | User interface |
| INFRA | Infrastructure |
| INT | Integrations |
| TEST | Testing |
| PROC | Processes/protocols |
| METH | Methodology |

---

## References

| Document | Purpose |
|----------|---------|
| [User Guide](USER-GUIDE.md) | Practical guide to Neocortex features |
| [Example Project](examples/neocortex-project-structure.md) | Complete example with sample files |
| [DEC-001](decisions/DEC-001-critical-thinking-protocol.md) | Critical Thinking Protocol |
| [DEC-002](decisions/DEC-002-neocortex-methodology.md) | Full decision record with rationale |
| [DEC-007](decisions/DEC-007-two-tier-learning.md) | Two-tier learning system |
| [DEC-008](decisions/DEC-008-auto-regenerate-learning-index.md) | Auto-regenerate index |
| [DEC-009](decisions/DEC-009-activation-context-optimization.md) | Activation context optimization |
| [.mlda/README.md](../.mlda/README.md) | MLDA quick start |

---

*Neocortex Methodology v2.1 | Built on the RMS Framework*
