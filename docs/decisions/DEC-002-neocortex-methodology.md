# DEC-002: Neocortex Methodology

**DOC-METH-001** | Methodology Evolution Specification

---

**Status:** Approved - Ready for Implementation
**Beads Epic:** Ways of Development-71
**Date:** 2026-01-20
**Authors:** Human + Claude collaboration
**Supersedes:** RMS-BMAD Methodology v1.3

**Research Sources:**
- Recursive Language Models paper (arxiv.org/2512.24601v1)
- Claude Code 2.1.0 Changelog (Anthropic)
- "A Thousand Brains: A New Theory of Intelligence" by Jeff Hawkins (2021)

---

## Executive Summary

This document defines **Neocortex** - a methodology evolution that transforms how AI agents gather, process, and learn from documentation. Built on the RMS framework, Neocortex replaces the previous BMAD/MLDA approach with a neural-inspired knowledge graph navigation system.

> "The Neocortex methodology, built on the RMS framework"

**Key Innovations:**
1. **Predictive context gathering** - Documents predict what context they need based on task type
2. **Topic-based learning** - Institutional knowledge persists in project files, loaded lazily per topic
3. **Multi-agent scaling** - Recursive agent decomposition for large context scenarios
4. **Verification stack** - Six-layer verification to ensure sub-agent summaries don't miss critical information
5. **Token budget management** - Self-assessment with hardstop safety nets

**Name Origin:** The neocortex is the brain's outer layer responsible for higher cognitive functions. Jeff Hawkins' "Thousand Brains Theory" models it as ~150,000 cortical columns, each building complete world models. Neocortex methodology applies this paradigm: documents are neurons, relationships are dendrites, agents send signals through the network.

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Theoretical Foundation](#2-theoretical-foundation)
3. [Core Improvements](#3-core-improvements)
4. [Sidecar Schema v2](#4-sidecar-schema-v2)
5. [Topic-Based Learning](#5-topic-based-learning)
6. [Multi-Agent Scaling](#6-multi-agent-scaling)
7. [Verification Stack](#7-verification-stack)
8. [Token Budget Management](#8-token-budget-management)
9. [Session Lifecycle](#9-session-lifecycle)
10. [Backward Compatibility](#10-backward-compatibility)
11. [Implementation Phases](#11-implementation-phases)
12. [References](#12-references)

---

## 1. Problem Statement

### Current Limitations (BMAD/MLDA v1.x)

| Limitation | Impact |
|------------|--------|
| **Static relationships** | Documents declare relationships but not *when* they matter |
| **Flat traversal** | Breadth-first document loading regardless of task relevance |
| **No learning persistence** | Each session starts fresh, no institutional memory |
| **Context explosion** | Large document sets exceed agent processing capacity |
| **No verification** | Sub-agent summaries may miss critical information |
| **Session-start loading** | All learning loaded upfront, wasting tokens on irrelevant topics |

### The Opportunity

Three external inputs informed this evolution:

1. **Recursive Language Models paper** - Demonstrates LLMs can programmatically decompose and recursively process content beyond context limits

2. **Claude Code 2.1.0** - Introduces sub-agent context forking, agent type specification, and hooks for coordination

3. **Hawkins' Thousand Brains Theory** - Provides neuroscience-grounded model for distributed, predictive knowledge representation

**Insight:** By combining these, we can create a methodology where agents navigate documentation like signals through a neural network - predictively, recursively, and with learning that accumulates over time.

---

## 2. Theoretical Foundation

### The Thousand Brains Model (Hawkins)

| Brain Concept | Neocortex Equivalent | Description |
|---------------|---------------------|-------------|
| **Cortical Column** | Document | A single unit storing specific knowledge |
| **Reference Frames** | Reference frame metadata | Positional context within knowledge space |
| **Dendrites** | Relationships (`related` in sidecar) | Connections to other documents |
| **Axon** | DOC-ID | The unique identifier that enables connections |
| **Signal** | Agent reading a document | Activation that triggers exploration |
| **Signal Propagation** | Following relationships | Agent traversing from doc to doc |
| **Voting** | N/A (replaced by traversal boundaries) | See Decision 4 below |
| **Prediction** | `predictions` block in sidecar | Documents anticipate needed context |

### Key Principle: Prediction, Not Reaction

Hawkins' model is fundamentally predictive - cortical columns anticipate what they'll sense next. Prediction errors drive learning.

**Application to Neocortex:** Documents don't just declare relationships; they predict what context will be needed based on the *type of task* being performed.

### RLM Paper Insights

The Recursive Language Models paper demonstrates:

1. **Programmatic context manipulation** - Treat documents as environmental objects to manipulate, not just content to load
2. **Recursive self-calls** - Agents can spawn sub-agents on sub-problems
3. **Emergent filtering strategies** - Without explicit training, models develop regex filtering, chunking, and verification

**Application to Neocortex:** Agents don't load all related documents. They programmatically decide which relationships to follow, recursively decompose large document sets, and verify findings.

---

## 3. Core Improvements

### Decision 1: Reference Frames

**Problem:** DOC-IDs provide identity but not *position* in knowledge space.

**Decision:** Add reference frame metadata to sidecars.

```yaml
reference_frames:
  domain: authentication        # Problem space
  layer: implementation        # requirements | design | implementation | testing
  stability: stable            # evolving | stable | deprecated
  scope: backend               # frontend | backend | infrastructure | cross-cutting
```

**Benefit:** Agents can query "show me all implementation-layer documents in the authentication domain" rather than traversing blindly.

---

### Decision 2: Predictive Context

**Problem:** Documents declare relationships but not *when* those relationships matter.

**Decision:** Add task-type predictions to sidecars (role-agnostic).

```yaml
predictions:
  # Analyst tasks
  when_eliciting:
    required: [DOC-REQ-001]
    likely: [DOC-STAKE-001]
  when_documenting:
    required: [DOC-TMPL-001]
    likely: []

  # Architect tasks
  when_architecting:
    required: [DOC-NFR-001, DOC-SEC-001]
    likely: [DOC-INT-001]
  when_reviewing_design:
    required: [DOC-ARCH-001]
    likely: []

  # Developer tasks
  when_implementing:
    required: [DOC-API-001, DOC-DATA-001]
    likely: [DOC-TEST-001]
  when_debugging:
    required: [DOC-LOG-001]
    likely: [DOC-ERR-001]
  when_testing:
    required: [DOC-TEST-001]
    likely: [DOC-MOCK-001]
```

**Benefit:** Context gathering adapts to task type, not just document identity.

---

### Decision 3: Recursive Context Gathering (RLM-Inspired)

**Problem:** Breadth-first traversal loads everything regardless of relevance.

**Decision:** Recursive, relevance-filtered gathering.

```
Algorithm: Recursive Context Gather

1. Load entry document (story, task)
2. Extract task type (implementing, debugging, reviewing)
3. Check document's predictions[task_type]
4. For each predicted doc:
   a. Assess relevance to current task (agent judgment)
   b. If relevant: load and recurse
   c. If not: skip (but note for potential later)
5. Aggregate findings through structured extraction (not concatenation)
6. Return structured context object
```

**Benefit:** Only loads what's actually needed, with relevance assessed at each step.

---

### Decision 4: Traversal Boundaries (Not Voting)

**Problem:** Initial proposal included "voting/consensus" for conflicting documents.

**Decision:** Replace with **traversal boundaries**. The model is entry-point-based, not authority-based.

```yaml
boundaries:
  domain: authentication
  related_domains: [rbac, session-management]
  isolated_from: [invoicing, reporting, inventory]
```

**Agent Rule:** Follow relationships within domain. Stop at domain boundaries unless the task explicitly requires crossing.

**Example:**
```
Task: "Design authentication architecture"
Entry: DOC-AUTH-001

Agent follows: DOC-AUTH-002, DOC-AUTH-003 (same domain)
Agent sees: DOC-RBAC-001 link
  → Check: Is RBAC in scope for this task?
  → Task says "authentication architecture" not "RBAC integration"
  → Decision: Note the dependency, don't traverse into RBAC details
Agent does NOT follow: DOC-INV-001 (invoicing) even if somehow linked
```

---

### Decision 5: Activation Logging

**Problem:** No learning about which documents are actually used together.

**Decision:** Track co-activation patterns in `.mlda/topics/{topic}/learning.yaml`.

```yaml
activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
    frequency: 7
    typical_tasks: [architecting, implementing]
    last_session: 2026-01-20
```

**Benefit:** Over time, the system learns actual usage patterns. Can suggest missing relationships or identify "hub" documents.

---

### Decision 6: Mode-Specific Context Forks

**Problem:** All modes load the same context structure.

**Decision:** Each mode operates with a filtered view of the knowledge graph.

| Mode | Primary Reference Frames | Prediction Context |
|------|-------------------------|-------------------|
| Analyst | layer: requirements | when_eliciting, when_documenting |
| Architect | layer: design | when_architecting, when_reviewing_design |
| Developer | layer: implementation | when_implementing, when_debugging, when_testing |

**Implementation:** Use Claude Code 2.1's `context: fork` in mode skill frontmatter.

---

### Decision 7: Sparse Activation (Two-Phase Loading)

**Problem:** Loading full documents when only metadata needed.

**Decision:** Two-phase activation.

**Phase 1 - Metadata only:**
```yaml
context_summary:
  - doc_id: DOC-API-001
    title: "API Authentication"
    predictions: {implementing: [DOC-SEC-001]}
    relevance_score: 0.9  # Agent-assessed
```

**Phase 2 - Selective full load:**
```
Agent decides: "I need DOC-API-001 fully, DOC-SEC-001 just the 'jwt' section"
```

**Benefit:** Mirrors RLM's programmatic filtering and Claude Code's MCP auto-defer pattern.

---

## 4. Sidecar Schema v2

Complete enhanced sidecar schema:

```yaml
# Required fields
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

# Existing relationships (enhanced)
related:
  - id: DOC-YYY-NNN
    type: depends-on | extends | references | supersedes
    why: "Explanation of relationship"

# NEW: Predictive context
predictions:
  when_eliciting:
    required: []
    likely: []
  when_documenting:
    required: []
    likely: []
  when_architecting:
    required: []
    likely: []
  when_reviewing_design:
    required: []
    likely: []
  when_implementing:
    required: []
    likely: []
  when_debugging:
    required: []
    likely: []
  when_testing:
    required: []
    likely: []

# NEW: Reference frames
reference_frames:
  domain: string           # Problem space
  layer: requirements | design | implementation | testing
  stability: evolving | stable | deprecated
  scope: frontend | backend | infrastructure | cross-cutting

# NEW: Traversal boundaries
boundaries:
  related_domains: []      # OK to traverse into
  isolated_from: []        # Never traverse into

# NEW: Critical markers flag
has_critical_markers: true | false

# Beads tracking (existing)
beads: "Project-ID"

# Version
version: "X.Y"
```

---

## 5. Topic-Based Learning

### Decision: Lazy Loading by Topic

**Problem:** Loading all learning data at session start wastes tokens on irrelevant topics.

**Decision:** Learning loads only after task selection, scoped to the task's topic.

### Folder Structure

```
.mlda/
├── topics/
│   ├── authentication/
│   │   ├── domain.yaml        # Sub-domain structure
│   │   └── learning.yaml      # Accumulated learnings + activations
│   ├── invoicing/
│   │   ├── domain.yaml
│   │   └── learning.yaml
│   ├── _cross-domain/
│   │   └── patterns.yaml      # Patterns spanning multiple domains
│   └── _example/              # Template for new topics
├── docs/                      # Existing document storage
├── scripts/                   # Existing scripts
├── templates/                 # Existing templates
└── config.yaml                # Neocortex configuration
```

### Learning File Schema

```yaml
# .mlda/topics/authentication/learning.yaml
topic: authentication
version: 3
last_updated: 2026-01-20
sessions_contributed: 12

# Learned sub-domain groupings
groupings:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007]
    origin: agent | human
    confidence: high | medium | low
    notes: "Optional notes"

  - name: session-handling
    docs: [DOC-AUTH-004, DOC-AUTH-005]
    origin: human
    notes: "User corrected agent's initial grouping"

# Co-activation patterns
activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
    frequency: 7
    typical_tasks: [architecting, implementing]

# Verification insights
verification_notes:
  - session: 2026-01-15
    caught: "PCI-DSS compliance requirement in DOC-AUTH-003"
    lesson: "Always check for compliance markers in token-related docs"

# Cross-domain touchpoints
related_domains:
  - domain: rbac
    relationship: "Authentication provides identity claims for RBAC"
    typical_overlap: [DOC-AUTH-008, DOC-RBAC-001]
```

### Domain Map Schema (Hybrid Approach)

```yaml
# .mlda/topics/authentication/domain.yaml
domain: authentication
version: 2
last_updated: 2026-01-20
source: hybrid  # human | agent | hybrid

sub_domains:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007, DOC-AUTH-009]
    origin: human

  - name: session-handling
    docs: [DOC-AUTH-004, DOC-AUTH-005, DOC-AUTH-010]
    origin: human

  - name: oauth-integration
    docs: [DOC-AUTH-006, DOC-AUTH-011, DOC-AUTH-012, DOC-AUTH-013]
    origin: agent
    discovered_during: "TASK-2024-0145"
    human_approved: true

override_allowed: true
override_requires_approval: false
```

### Workflow

```
Session Start
│
├─ Minimal context loaded (System prompt, CLAUDE.md, tools)
│  (Learning NOT loaded yet)
│
├─ User: "Check beads status"
│   └─ Agent: runs `bd ready`
│      Returns task list. Still no learning loaded.
│
├─ User: "Let's work on TASK-AUTH-003"
│   └─ Agent:
│      1. Reads task details (beads + any linked docs)
│      2. Identifies domain: authentication
│      3. Checks: .mlda/topics/authentication/ exists?
│      4. If yes: Load topic-specific learning
│      5. If no: Note "new topic, will create learning at session end"
│      6. Proceed with task, now with relevant context
│
└─ Session End (if learning occurred)
    └─ Agent proposes: "Save learnings to authentication?"
    └─ User approves/modifies
    └─ Written to .mlda/topics/authentication/learning.yaml
```

### Topic Identification

1. **Explicit:** Task has domain tag in beads metadata
2. **Inferred:** Task references DOC-IDs → extract domain from ID prefix (DOC-AUTH-xxx)
3. **Fallback:** Agent infers from description, confirms with user if uncertain

---

## 6. Multi-Agent Scaling

### Decision: True Recursive Agent Decomposition

**Problem:** Large document sets exceed single-agent processing capacity, leading to context loss and hallucination.

**Decision:** Allow recursive sub-agent spawning with structured return.

### When to Trigger

```yaml
# In agent behavior or config
context_scaling:
  threshold_documents: 10
  threshold_tokens: 35000  # Soft threshold
  action: propose_decomposition
```

When threshold hit, agent proposes decomposition:

```
I'm gathering context for authentication architecture.
I've identified 15 relevant documents across 4 sub-domains:
- Token Management (4 docs)
- Session Handling (3 docs)
- OAuth/OIDC (4 docs)
- RBAC Dependencies (4 docs)

This exceeds efficient single-agent processing.

Options:
1. Spawn sub-agents to analyze each sub-domain in parallel
2. Process sequentially with progressive summarization
3. Proceed anyway (risk: context degradation)

Recommended: Option 1
```

### Sub-Agent Structure

```
Primary Agent (authentication requirements)
│
├─► Detects: 15 documents, context growing large
│
├─► Identifies logical subdivisions (from domain.yaml or dynamic)
│
├─► Spawns Sub-Agents:
│   ├── Sub-Agent-1: "Extract token management requirements"
│   ├── Sub-Agent-2: "Extract session handling requirements"
│   ├── Sub-Agent-3: "Extract OAuth integration requirements"
│   └── Sub-Agent-4: "Identify RBAC dependencies (don't solve, just list)"
│
├─► Sub-agents return structured summaries (not full context)
│
└─► Primary agent synthesizes into coherent output
```

### Structured Return Format

```yaml
# Sub-agent output
sub_domain: token-management
documents_processed: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007, DOC-AUTH-009]

key_requirements:
  - requirement: "JWT tokens with 15-minute expiry"
    source:
      doc: DOC-AUTH-002
      section: "2.1 Token Lifecycle"
    confidence: high

critical_items:
  - marker: "compliance"
    content: "Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8"
    source: DOC-AUTH-003, line 47
    verbatim: true

dependencies_identified:
  - doc_id: DOC-RBAC-001
    reason: "Token claims must include role information"

open_questions:
  - "Token storage: httpOnly cookie vs localStorage?"

edge_cases:
  - "Multi-device session handling"

meta:
  completeness_confidence: medium
  uncertainty_flags:
    - doc: DOC-AUTH-007
      section: "3.2 - Edge Cases"
      reason: "Ambiguous language, multiple interpretations possible"
  recommend_primary_review:
    - DOC-AUTH-007 section 3.2
```

### Recursion Depth

Sub-agents may spawn their own sub-agents if needed (true recursion). Use cases:
- Scientific paper analysis with many sources
- Large research projects
- Complex multi-domain systems

---

## 7. Verification Stack

### Decision: Six-Layer Verification for Sub-Agent Summaries

**Problem:** Sub-agents may miss critical information when summarizing.

**Decision:** Implement six verification layers.

### Layer 1: Structured Extraction (Mandatory)

Instead of "summarize this", use explicit extraction templates:

```yaml
extraction_template:
  must_extract:
    - requirements (functional)
    - requirements (non-functional)
    - constraints (technical)
    - constraints (business/compliance)
    - dependencies (internal)
    - dependencies (external)
    - edge_cases
    - open_questions
    - risks
    - assumptions_made

  format: structured_yaml
  completeness_check: true
```

### Layer 2: Critical Markers (Mandatory)

Documents mark non-negotiable information:

```markdown
<!-- In document content -->

## Token Expiry Policy

<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8.
<!-- /CRITICAL -->
```

**Sub-agent instruction:** Always extract CRITICAL markers verbatim, regardless of summarization.

### Layer 3: Confidence Self-Assessment (Mandatory)

Sub-agents report uncertainty:

```yaml
meta:
  documents_processed: 4
  completeness_confidence: medium
  uncertainty_flags:
    - doc: DOC-AUTH-007
      section: "3.2"
      reason: "Ambiguous language"
  recommend_primary_review:
    - DOC-AUTH-007 section 3.2
```

### Layer 4: Provenance Tracking (Mandatory)

Every extracted item traces to source:

```yaml
key_requirements:
  - requirement: "Refresh token rotation on each use"
    source:
      doc: DOC-AUTH-002
      section: "2.3 Token Lifecycle"
      line: 78
    verbatim: false
    confidence: high
```

### Layer 5: Cross-Verification (Optional - High Stakes)

For critical domains, spawn two independent sub-agents on same documents:

- If outputs agree → High confidence
- If outputs diverge → Flag for primary agent review

**Use for:** Security-critical, compliance-related, high-ambiguity domains.

### Layer 6: Verification Pass (Optional)

After synthesis, primary agent does targeted verification:

```
Thought process:

Sub-agent reported 0 compliance requirements for OAuth integration.
This seems unlikely given we're handling user data.
Verification: Read DOC-AUTH-011 section on compliance directly.

Result: Sub-agent missed GDPR consent requirement in section 5.2.
Action: Add to synthesis, note verification caught this.
```

### Summary

| Layer | Status | Purpose |
|-------|--------|---------|
| 1. Structured Extraction | Mandatory | Comprehensive extraction vs judgment-based |
| 2. Critical Markers | Mandatory | Non-negotiables always extracted |
| 3. Confidence Self-Assessment | Mandatory | Know where uncertainty exists |
| 4. Provenance Tracking | Mandatory | Verify claims if needed |
| 5. Cross-Verification | Optional | Catch different blind spots |
| 6. Verification Pass | Optional | Spot-check suspicious absences |

---

## 8. Token Budget Management

### Decision: Self-Assessment with Hardstop Safety Net

**Problem:** Context growth can exceed reliable processing capacity.

### Token Allocation (200k total)

```
Fixed Overhead (approximate):
├─ System prompt:           ~2,000
├─ CLAUDE.md (both):        ~5,000
├─ Tool definitions:        ~8,000
├─ Conversation history:    ~10,000-30,000 (grows)
└─ Subtotal:                ~25,000-45,000

Variable (task-dependent):
├─ Document context:        Managed by thresholds below
├─ Beads commands/output:   ~2,000-5,000
├─ Sub-agent coordination:  ~5,000-10,000 (if spawning)
├─ Output generation:       ~10,000-50,000 (depends on task)
└─ Iteration buffer:        Remaining
```

### Threshold Configuration

```yaml
# .mlda/config.yaml
context_limits:
  # Conservative defaults
  soft_threshold_tokens: 35000    # ~17% of 200k
  hardstop_tokens: 50000          # 25% of 200k
  soft_threshold_documents: 8
  hardstop_documents: 12

  # Task-specific overrides
  by_task_type:
    research:
      soft_threshold: 50000
      hardstop: 70000
    document_creation:
      soft_threshold: 30000
      hardstop: 45000
    review:
      soft_threshold: 40000
      hardstop: 55000
    architecture:
      soft_threshold: 30000
      hardstop: 45000
```

### Behavior

**At soft threshold:**
```
Agent: *internal self-assessment*
- Am I maintaining coherence?
- Is my extraction quality degrading?
- How much more context do I anticipate needing?
- How large is my expected output?

If struggling OR large task ahead → Propose decomposition
If fine → Continue with caution, report status
```

**At hardstop:**
```
Agent: "I've reached context limits. I must decompose or pause."

Options:
1. Decompose into sub-agents (recommended)
2. Progressive summarization of processed content
3. Pause and ask for human guidance

Cannot continue loading more documents.
```

### Self-Assessment Checklist

```
1. Can I accurately recall key points from documents read earlier?
2. Am I finding myself re-reading sections I already processed?
3. Are my extractions becoming more vague or generic?
4. Can I still see clear connections between documents?
5. Am I making assumptions that should be answered by docs I've read?

If 2+ answers concerning → Recommend decomposition
```

### Principle

> "Decompose while comfortable, not when desperate."

---

## 9. Session Lifecycle

### Complete Protocol

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SESSION LIFECYCLE                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  START                                                                   │
│    └─ Load: System prompt, CLAUDE.md, tools                             │
│       (Topic learning NOT loaded)                                        │
│                                                                          │
│  TASK SELECTION                                                          │
│    └─ User picks task from beads                                        │
│    └─ Agent identifies domain(s) from task                              │
│    └─ Agent loads: .mlda/topics/{domain}/learning.yaml                  │
│    └─ If new domain: proceed without, note for creation                 │
│                                                                          │
│  CONTEXT GATHERING                                                       │
│    └─ Read entry document(s) referenced by task                         │
│    └─ Check predictions[task_type] for required/likely docs             │
│    └─ Two-phase load: metadata first, then selective full load          │
│    └─ Monitor context size against thresholds                           │
│    └─ If threshold reached: self-assess, propose decomposition          │
│                                                                          │
│  WORK                                                                    │
│    └─ Execute task with gathered context                                │
│    └─ Note new learnings as they occur                                  │
│    └─ Update activation patterns                                        │
│                                                                          │
│  END                                                                     │
│    └─ Agent proposes saving new learnings                               │
│    └─ User approves/modifies                                            │
│    └─ Written to .mlda/topics/{domain}/learning.yaml                    │
│    └─ Activation patterns updated                                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Notes

- **Topic change mid-session:** Close current session, start new one (user's preference)
- **Cross-domain tasks:** Should not happen - use beads to split into smaller tasks
- **New topics:** Bootstrap naturally, propose learning structure at session end

---

## 10. Backward Compatibility

### Guarantee

Existing projects using current MLDA structure continue working without modification.

### How

1. **Sidecar v2 is additive** - New fields are optional; old sidecars remain valid
2. **Topics folder is optional** - If `.mlda/topics/` doesn't exist, system works without learning
3. **Predictions optional** - If no `predictions` block, fallback to existing relationship traversal
4. **Config optional** - Default thresholds apply if no `.mlda/config.yaml`

### Migration Path

See migration guide (Ways of Development-94) for:
- Adding predictions to existing sidecars
- Creating topic structure from existing domains
- Initializing learning from historical patterns

---

## 11. Implementation Phases

### Phase 1: Foundation Documentation (Ready Now)

| Task | ID | Dependencies |
|------|-----|-------------|
| DEC-002: This document | 72 | None |
| NEOCORTEX.md: Full specification | 73 | None |
| Architecture overview diagram | 74 | None |

### Phase 2: Schema Definitions

| Task | ID | Dependencies |
|------|-----|-------------|
| Sidecar schema v2 | 75 | 73 |
| Topic learning file schema | 76 | 73 |
| Domain/topic configuration schema | 77 | 73 |
| Neocortex config schema | 78 | 73 |

### Phase 3: Structure & Scripts

| Task | ID | Dependencies |
|------|-----|-------------|
| Define .mlda/topics/ hierarchy | 79 | 76, 77 |
| mlda-learning.ps1 script | 80 | 76, 79 |
| Update existing MLDA scripts | 81 | 79 |

### Phase 4: Templates

| Task | ID | Dependencies |
|------|-----|-------------|
| Sidecar template v2 | 82 | 75 |
| Learning file template | 83 | 76 |
| Domain/topic template | 84 | 77 |
| Neocortex config template | 85 | 78 |

### Phase 5: CLAUDE.md Updates

| Task | ID | Dependencies |
|------|-----|-------------|
| Global CLAUDE.md rewrite | 86 | 73, 75-78 |
| Project CLAUDE.md template | 87 | 86 |

### Phase 6: Modes & Skills

| Task | ID | Dependencies |
|------|-----|-------------|
| Update modes for context gathering | 88 | 86 |
| Update existing skills | 89 | 86 |
| New gather-context skill | 90 | 86, 80 |
| New manage-learning skill | 91 | 86, 80 |

### Phase 7: Documentation

| Task | ID | Dependencies |
|------|-----|-------------|
| Update README.md | 92 | 86, 88, 89 |
| Update .mlda/README.md | 93 | 79, 80 |
| Migration guide | 94 | 86, 87 |
| User guide | 95 | 86, 90, 91 |
| Example project structure | 96 | 79, 82-85 |

### Phase 8: Validation

| Task | ID | Dependencies |
|------|-----|-------------|
| Compliance checklist | 97 | 73, 86 |
| End-to-end test | 98 | 92-97 |

### Phase 9: Post-Implementation

| Task | ID | Dependencies |
|------|-----|-------------|
| New GitHub repository | 99 | 98 |

---

## 12. References

### Research Papers

| Paper | Key Contribution |
|-------|------------------|
| "Recursive Language Models" (MIT CSAIL, 2025) | Programmatic context manipulation, recursive self-calls |
| "Large Language Models Cannot Self-Correct Reasoning Yet" (ICLR 2024) | External verification requirement |
| "The Danger of Overthinking" (Berkeley 2025) | Context degradation with large inputs |

### Books

| Book | Author | Contribution |
|------|--------|--------------|
| "A Thousand Brains: A New Theory of Intelligence" | Jeff Hawkins (2021) | Cortical columns, reference frames, prediction |

### Software

| Software | Version | Features Used |
|----------|---------|---------------|
| Claude Code | 2.1.0 | Sub-agent context forking, agent type specification, hooks |
| Beads | Current | Task tracking, dependencies |

### Prior Methodology

| Document | Status |
|----------|--------|
| RMS-BMAD v1.3 | Superseded by this document |
| DEC-001: Critical Thinking Protocol | Active, integrates with Neocortex |
| DOC-CORE-001: MLDA Neocortex Paradigm | To be updated per this document |

---

## Beads Task Summary

| ID | Title | Status | Phase |
|----|-------|--------|-------|
| 71 | Epic: Implement Neocortex Methodology v2.0 | Open | - |
| 72 | DEC-002: Neocortex Methodology Decision Record | In Progress | 1 |
| 73-74 | Foundation Documentation | Open | 1 |
| 75-78 | Schema Definitions | Blocked | 2 |
| 79-81 | Structure & Scripts | Blocked | 3 |
| 82-85 | Templates | Blocked | 4 |
| 86-87 | CLAUDE.md Updates | Blocked | 5 |
| 88-91 | Modes & Skills | Blocked | 6 |
| 92-96 | Documentation | Blocked | 7 |
| 97-98 | Validation | Blocked | 8 |
| 99 | GitHub Repository | Blocked | 9 |

---

*DOC-METH-001 | Neocortex Methodology | v2.0*
*This document will be updated as implementation progresses.*
