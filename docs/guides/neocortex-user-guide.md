# Neocortex User Guide

A practical guide to using Neocortex features for AI-assisted development.

**Version:** 2.0
**Reference:** [docs/NEOCORTEX.md](../NEOCORTEX.md) for full methodology

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Context Gathering](#context-gathering)
3. [Topic-Based Learning](#topic-based-learning)
4. [Multi-Agent Scaling](#multi-agent-scaling)
5. [Verification Stack](#verification-stack)
6. [Common Workflows](#common-workflows)
7. [Troubleshooting](#troubleshooting)

---

## Getting Started

### What is Neocortex?

Neocortex treats your documentation as a **knowledge graph** that agents navigate to gather context. Instead of loading entire documents or relying on you to provide all context, agents:

1. Start from entry points (stories, tasks with DOC-ID references)
2. Follow relationships between documents
3. Load only what's needed for the current task
4. Learn patterns across sessions

### Prerequisites

- MLDA initialized in your project (`.mlda/` folder)
- Registry current (`mlda-registry.ps1` has been run)
- Documents have `.meta.yaml` sidecars with relationships

### Quick Check

```powershell
# Verify MLDA is set up
Test-Path ".mlda/registry.yaml"

# Check document count
.\.mlda\scripts\mlda-registry.ps1 -Graph
```

---

## Context Gathering

The `gather-context` skill navigates your knowledge graph before you start work.

### When to Use

- Starting a new story or task
- Beginning a code review
- Exploring an unfamiliar area
- Understanding how features connect

### Basic Usage

```
# Via skill
/skills:gather-context

# In any mode
*gather-context

# Automatic (when story has DOC-IDs)
"Let's work on Ways of Development-123"
→ Agent automatically gathers context from referenced docs
```

### Example Session

```
You: Let's implement the token refresh feature from story AUTH-003

Agent: I'll gather context for this task.

Entry Points: DOC-AUTH-001, DOC-AUTH-002
Task Type: implementing
Topic: authentication

Loading topic learnings... Found v3, 12 sessions contributed.
High-frequency activations: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Verification note: "Always check compliance markers in token docs"

Phase 1: Metadata scan (8 documents discovered)
Phase 2: Selective full load (4 high-relevance docs)

## Context Gathered

**Documents Processed:** 8
**Depth Reached:** 3
**Context Status:** ✓ Within threshold (28k/35k tokens)

### Key Requirements
- JWT tokens with 15-minute expiry (DOC-AUTH-002)
- Refresh token rotation on each use (DOC-AUTH-002)

### Critical Items (Compliance)
> ⚠ Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8
> Source: DOC-AUTH-003 (verbatim)

### Open Questions
1. Token storage: httpOnly cookie vs localStorage?

Ready to proceed. Shall I explore any area deeper?
```

### What Happens Behind the Scenes

```
┌─────────────────────────────────────────────────────────────┐
│  1. TOPIC IDENTIFICATION                                     │
│     Task mentions AUTH → Topic: authentication               │
│     Load: .mlda/topics/authentication/learning.yaml          │
├─────────────────────────────────────────────────────────────┤
│  2. ENTRY POINT DISCOVERY                                    │
│     Find DOC-IDs in story: DOC-AUTH-001, DOC-AUTH-002       │
│     Check predictions for "implementing" task type           │
├─────────────────────────────────────────────────────────────┤
│  3. TWO-PHASE LOADING                                        │
│     Phase A: Load sidecars only (low token cost)            │
│     Phase B: Full load for high-relevance docs              │
├─────────────────────────────────────────────────────────────┤
│  4. BOUNDARY-AWARE TRAVERSAL                                 │
│     Follow depends-on: always                               │
│     Follow extends: if depth ≤ 3                            │
│     Stop at isolated_from boundaries                        │
├─────────────────────────────────────────────────────────────┤
│  5. THRESHOLD MONITORING                                     │
│     Track: tokens (~28k), documents (8)                     │
│     Status: within soft threshold                           │
├─────────────────────────────────────────────────────────────┤
│  6. STRUCTURED OUTPUT                                        │
│     Requirements, constraints, critical items, gaps          │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Commands

Once context is gathered, use these commands to explore further:

| Command | Description |
|---------|-------------|
| `*explore DOC-AUTH-003` | Navigate from a specific document |
| `*related` | Show documents related to current context |
| `*context` | Display the gathered context summary |

### Controlling Depth

By default, agents follow relationships up to depth 3. You can adjust:

```
*gather-context --depth 5    # Go deeper (architect work)
*gather-context --depth 2    # Stay shallow (quick task)
```

---

## Topic-Based Learning

Learning persists across sessions, making each session smarter than the last.

### How It Works

```
Session 1: Work on authentication
  → Agent discovers DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001 used together
  → Session ends: "Save this co-activation pattern?" [y]

Session 2: Work on authentication again
  → Agent loads: .mlda/topics/authentication/learning.yaml
  → Already knows to load those 3 docs together
  → Faster context gathering, better results
```

### Basic Usage

```
# List available topics
*learning list

# Load a topic's learnings
*learning load authentication

# Initialize a new topic
*learning init user-management

# Save session learnings (prompted at session end)
*learning save
```

### Example: Session End

```
Agent: This session covered authentication tasks.

## Session Learnings Proposed

### New Co-Activation Pattern
Documents accessed together: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Task type: implementing
Save this pattern? [y/n]

### Verification Note
Session: 2026-01-20
Caught: GDPR consent requirement in OAuth flow
Doc: DOC-AUTH-011
Section: "5.2 User Consent"
Lesson: "Check GDPR markers when working with OAuth user data"
Save this note? [y/n]

Proceed with save? [y/n/modify]
```

### What Gets Learned

| Learning Type | Example | How It Helps |
|---------------|---------|--------------|
| **Groupings** | "token-management" = [AUTH-002, AUTH-003, AUTH-007] | Agent knows which docs belong together |
| **Activations** | AUTH-001 + SEC-001 used together 7 times | Agent loads them together automatically |
| **Verification Notes** | "Check compliance markers in token docs" | Agent watches for issues caught before |
| **Anti-Patterns** | "Loading all AUTH docs causes overflow" | Agent avoids past mistakes |

### Learning File Location

```
.mlda/topics/
├── authentication/
│   ├── learning.yaml    # Accumulated learnings
│   └── domain.yaml      # Sub-domain structure
├── user-management/
│   ├── learning.yaml
│   └── domain.yaml
└── _cross-domain/
    └── patterns.yaml    # Cross-domain patterns
```

### Manual Learning Management

```
# Add a document grouping
*learning grouping
Topic: authentication
Name: session-handling
Documents: DOC-AUTH-004, DOC-AUTH-005, DOC-AUTH-010
Save? [y]

# Add a verification note
*learning note
Topic: authentication
Caught: "PCI-DSS token expiry requirement"
Lesson: "Always check for compliance markers"
Save? [y]
```

---

## Multi-Agent Scaling

When context grows too large, agents can decompose work across sub-agents.

### When It Happens

Neocortex monitors context size against thresholds:

| Threshold | Tokens | Documents | What Happens |
|-----------|--------|-----------|--------------|
| **Under soft** | <35k | <8 | Normal operation |
| **At soft** | 35k | 8 | Self-assessment triggered |
| **At hard** | 50k | 12 | Decomposition proposed |

### What You'll See

```
Agent: ⚠ CONTEXT THRESHOLD REACHED

Documents: 14 (limit: 12)
Estimated tokens: 52,000 (limit: 50,000)

I cannot continue loading more documents without risking context degradation.

Options:
1. **Spawn sub-agents** for sub-domains (recommended)
   - Token management: 4 docs
   - Session handling: 3 docs
   - OAuth integration: 4 docs
   - RBAC dependencies: 3 docs

2. **Progressive summarization**
   - Summarize processed documents, continue with summary

3. **Pause and ask**
   - Get guidance on which areas to prioritize

Which approach would you like? [1/2/3]
```

### How Sub-Agents Work

```
You: 1

Agent: Spawning sub-agents...

Primary Agent
│
├─► Sub-Agent-1: Token management (4 docs)
│   └─ Returns: structured requirements, critical items
│
├─► Sub-Agent-2: Session handling (3 docs)
│   └─ Returns: structured requirements, dependencies
│
├─► Sub-Agent-3: OAuth integration (4 docs)
│   └─ Returns: structured requirements, compliance notes
│
└─► Sub-Agent-4: RBAC dependencies (3 docs)
    └─ Returns: role requirements, permission model

Synthesizing sub-agent results...

## Combined Context (from 4 sub-agents)

[Merged structured output with provenance tracking]
```

### Sub-Agent Return Format

Each sub-agent returns structured data, not free-form text:

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
    source: DOC-AUTH-003
    verbatim: true  # Extracted word-for-word

meta:
  completeness_confidence: medium
  recommend_primary_review: [DOC-AUTH-007 section 3.2]
```

### Task-Specific Thresholds

Different tasks have different context needs:

| Task Type | Soft Threshold | Hard Stop |
|-----------|---------------|-----------|
| Research | 50k tokens | 70k |
| Implementation | 35k tokens | 50k |
| Review | 40k tokens | 55k |
| Architecture | 30k tokens | 45k |

---

## Verification Stack

Six layers ensure sub-agent summaries don't miss critical information.

### The Six Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: STRUCTURED EXTRACTION           [Mandatory]       │
│  Template-driven extraction, not free-form summarization    │
│  → Requirements, constraints, APIs, data models             │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: CRITICAL MARKERS                [Mandatory]       │
│  <!-- CRITICAL: compliance --> tags extracted verbatim      │
│  → Never summarized, never paraphrased                      │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: CONFIDENCE SELF-ASSESSMENT      [Mandatory]       │
│  Sub-agent reports uncertainty and gaps                     │
│  → "Section 3.2 was ambiguous—recommend primary review"     │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: PROVENANCE TRACKING             [Mandatory]       │
│  Every claim traces to source document + section            │
│  → "JWT 15-min: DOC-AUTH-002, section 2.1"                 │
├─────────────────────────────────────────────────────────────┤
│  Layer 5: CROSS-VERIFICATION              [Optional]        │
│  Two sub-agents independently process same docs             │
│  → Discrepancies flagged for primary review                 │
├─────────────────────────────────────────────────────────────┤
│  Layer 6: VERIFICATION PASS               [Optional]        │
│  Primary agent spot-checks suspicious absences              │
│  → "RBAC mentioned in 3 docs but not in auth summary?"     │
└─────────────────────────────────────────────────────────────┘
```

### Critical Markers in Your Documents

Mark critical information so it's never lost in summarization:

```markdown
## Token Expiry Policy

<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8.
This is a hard regulatory requirement with audit implications.
<!-- /CRITICAL -->

Regular content here can be summarized...
```

**Marker types:**
- `compliance` - Regulatory requirements
- `security` - Security-critical information
- `breaking` - Breaking changes or migration requirements
- `dependency` - Critical external dependencies

### When Verification Kicks In

| Situation | Layers Used |
|-----------|-------------|
| Normal context gathering | 1, 2, 3, 4 |
| Multi-agent decomposition | 1, 2, 3, 4 |
| Security/compliance domains | 1, 2, 3, 4, 5 |
| High-stakes decisions | 1, 2, 3, 4, 5, 6 |

### What You'll See

```
Agent: Sub-agent summaries received. Running verification...

Layer 1 ✓ Structured extraction complete
Layer 2 ✓ 3 CRITICAL markers extracted verbatim
Layer 3 ⚠ Sub-agent-2 reported low confidence on DOC-AUTH-007
Layer 4 ✓ All claims have provenance

Verification notes:
- DOC-AUTH-007 section 3.2: Marked for primary review (ambiguous)
- CRITICAL compliance marker preserved from DOC-AUTH-003

Proceed with synthesized context? [y/n/review DOC-AUTH-007]
```

---

## Common Workflows

### Starting a New Feature

```
1. Select task from beads
   bd ready
   "Let's work on Ways of Development-123"

2. Agent gathers context automatically
   → Identifies topic, loads learnings
   → Navigates knowledge graph
   → Presents structured context

3. Review and proceed
   *related              # See connected docs
   *explore DOC-API-005  # Dive deeper if needed

4. Do the work

5. Session end: save learnings
   *learning save
```

### Exploring an Unfamiliar Area

```
1. Start with a known document
   *explore DOC-AUTH-001

2. Follow relationships
   Agent: DOC-AUTH-001 relates to:
   - DOC-AUTH-002 (depends-on): Token lifecycle
   - DOC-SEC-001 (references): Security baseline
   - DOC-API-003 (extends): Auth endpoints

   Which would you like to explore?

3. Build understanding iteratively
   *explore DOC-AUTH-002
   *related
```

### Reviewing a Large Feature

```
1. Gather context with review depth
   *gather-context --depth 4

2. If threshold hit, decompose
   Agent proposes sub-agents for sub-domains

3. Review synthesized context
   Check critical items, provenance

4. Spot-check if needed
   *explore DOC-AUTH-007  # Review flagged section
```

### Cross-Domain Work

```
1. Start in primary domain
   *gather-context  # Entry: DOC-AUTH-001

2. Agent notes boundary crossing
   "RBAC (DOC-RBAC-001) is referenced but in different domain.
    Include RBAC context? [y/n]"

3. Expand if needed
   [y] → Agent loads RBAC docs within boundaries
```

### UX Design with MLDA Integration

UX-Expert (Uma) can create and consume MLDA documents:

**Creating UX Documents:**
```
1. Activate UX mode
   /modes:ux-expert

2. Create MLDA-compliant wireframe
   *create-wireframe-doc
   → Interactive elicitation
   → Auto-assigns DOC-UI-xxx
   → Creates .meta.yaml sidecar
   → Updates registry

3. Or create other UX docs
   *create-design-system-doc  # DOC-DS-xxx
   *create-flow-doc           # DOC-UX-xxx
   *create-a11y-report        # DOC-A11Y-xxx
```

**Developer Consuming UX Context:**
```
1. Story references UX docs
   Documentation References:
   - DOC-UI-005: Navigation wireframe
   - DOC-DS-001: Design system

2. Developer gathers context
   /modes:dev
   *gather-context

3. Agent navigates UX knowledge
   → Loads DOC-UI-005 (wireframe)
   → Follows depends-on → DOC-DS-001
   → Follows references → DOC-A11Y-002
   → Full UI context available
```

**UX Domains:**
| Domain | Code | Content |
|--------|------|---------|
| User Interface | UI | Wireframes, component specs |
| Design System | DS | Tokens, patterns, components |
| User Experience | UX | User flows, journey maps |
| Accessibility | A11Y | Audits, remediation |

---

## Troubleshooting

### Context Not Loading

**Symptom:** "No entry points found"

**Solutions:**
1. Check story has DOC-ID references
2. Verify registry is current: `.\.mlda\scripts\mlda-registry.ps1`
3. Manually specify entry point: `*explore DOC-AUTH-001`

### Topic Not Found

**Symptom:** "No learning file found for topic"

**Solutions:**
1. This is normal for new topics
2. Agent will create learning at session end
3. Or initialize manually: `*learning init {topic}`

### Threshold Hit Too Early

**Symptom:** Decomposition proposed when you expected more context

**Solutions:**
1. Check config thresholds in `.mlda/config.yaml`
2. Use task-specific override: `*gather-context --task-type research`
3. Documents may be larger than expected—check individual sizes

### Missing Critical Information

**Symptom:** Important info not in context summary

**Solutions:**
1. Add `<!-- CRITICAL -->` markers to source documents
2. Check relationship type—`depends-on` always followed, `references` conditional
3. Verify document has proper sidecar with relationships

### Learning Not Persisting

**Symptom:** Agent doesn't remember patterns from last session

**Solutions:**
1. Verify learning was saved: check `.mlda/topics/{topic}/learning.yaml`
2. Ensure topic was correctly identified (check DOC-ID domain prefix)
3. Manual load: `*learning load {topic}`

### Sub-Agent Results Incomplete

**Symptom:** Missing information after multi-agent decomposition

**Solutions:**
1. Check Layer 3 confidence reports
2. Review flagged sections: `*explore {flagged-doc}`
3. For critical domains, request cross-verification (Layer 5)

---

## Configuration Reference

### .mlda/config.yaml

```yaml
version: "2.0"

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

learning:
  auto_save_prompt: true
  activation_logging: true

verification:
  cross_verification_domains: [security, compliance]
  critical_marker_syntax: "<!-- CRITICAL: {type} -->"
```

### Relationship Types Quick Reference

| Type | Signal | Default Behavior |
|------|--------|------------------|
| `depends-on` | Strong | Always follow |
| `extends` | Medium | Follow if depth ≤ 3 |
| `references` | Weak | Follow if task-relevant |
| `supersedes` | Redirect | Follow target, skip current |

---

## References

| Document | Purpose |
|----------|---------|
| [Example Project Structure](../examples/neocortex-project-structure.md) | Complete example with sample files |
| [NEOCORTEX.md](../NEOCORTEX.md) | Full methodology specification |
| [.mlda/README.md](../../.mlda/README.md) | MLDA quick start |
| [gather-context skill](../../.claude/commands/skills/gather-context.md) | Technical specification |
| [manage-learning skill](../../.claude/commands/skills/manage-learning.md) | Technical specification |
| [DEC-002](../decisions/DEC-002-neocortex-methodology.md) | Decision record |

---

*Neocortex User Guide v2.0 | Practical guide to knowledge graph navigation*
