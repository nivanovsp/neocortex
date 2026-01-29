---
description: 'Gather context from MLDA knowledge graph before starting work'
---
# Gather Context Skill

**RMS Skill v2.0** | Neocortex context-gathering workflow with topic loading, two-phase document loading, boundary-aware traversal, and threshold monitoring

This skill defines the standard context-gathering workflow that agents should follow before starting implementation, review, or other substantive work. It implements the Neocortex methodology for navigating the MLDA knowledge graph.

**Reference:** [DEC-002](../../docs/decisions/DEC-002-neocortex-methodology.md) sections 3, 5, 8, 9

## When to Use

- Starting work on a story or task with DOC-ID references
- Beginning a review that requires understanding requirements context
- Needing to understand how a feature fits into the broader system
- Exploring documentation before creating new content

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Registry should be current (`mlda-registry.ps1` has been run)
- Story/task should contain DOC-ID references as entry points

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    GATHER CONTEXT WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Phase 1: Topic Identification                                          │
│    └─ Extract domain from task/story DOC-IDs                            │
│    └─ Load topic learning: .mlda/topics/{topic}/learning.yaml           │
│                                                                          │
│  Phase 2: Entry Point Discovery                                          │
│    └─ Parse DOC-ID references from task                                  │
│    └─ Validate against registry                                          │
│    └─ Check predictions[task_type] for required/likely docs             │
│                                                                          │
│  Phase 3: Two-Phase Document Loading                                     │
│    └─ Phase A: Load sidecars only (metadata)                            │
│    └─ Phase B: Selective full document load                             │
│                                                                          │
│  Phase 4: Boundary-Aware Traversal                                       │
│    └─ Follow depends-on always                                          │
│    └─ Follow extends if within depth limit                              │
│    └─ Respect isolated_from boundaries                                   │
│    └─ Monitor context thresholds                                         │
│                                                                          │
│  Phase 5: Context Synthesis                                              │
│    └─ Structured extraction (not free-form summary)                     │
│    └─ Extract CRITICAL markers verbatim                                  │
│    └─ Report confidence and gaps                                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisite Check: Topic Learning Status

Before proceeding with Phase 1, verify topic learning status:

### Check Sequence

1. **Is current topic identified?**
   - From mode activation (should have been identified during activation protocol)
   - From DOC-ID prefixes in the task/story
   - From explicit user mention

2. **Is topic learning loaded?**
   - Check if `*learning load {topic}` was executed during mode activation
   - If learnings are loaded, proceed to Phase 1

3. **If topic learning NOT loaded and topic IS identified:**
   ```
   ⚠ Topic learning not loaded

   Topic identified: {topic-name}
   Action: Execute `*learning load {topic}` before proceeding

   This ensures learned co-activation patterns are available for document prioritization.
   ```

   → Execute: `*learning load {topic}` first
   → Then proceed with Phase 1

4. **If topic NOT identified:**
   - Proceed to Phase 1 to identify topic from DOC-IDs
   - Load learnings once topic is determined

### Why This Matters

Topic learnings contain:
- **Co-activation patterns**: Which documents are frequently needed together
- **Groupings**: Sub-domain clusters for efficient loading
- **Verification notes**: Past lessons learned to avoid repeating mistakes

Loading these BEFORE context gathering makes the process more efficient and accurate.

---

## Phase 1: Topic Identification

**Goal:** Identify the topic domain and load relevant learnings.

### Topic Identification Methods

1. **DOC-ID extraction** from task references (DOC-AUTH-xxx → authentication)
2. **Inference from description** (confirm with user if uncertain)

### Topic Loading

```bash
# Check if topic exists
.\.mlda\scripts\mlda-learning.ps1 -Topic {topic} -Load

# If topic doesn't exist
# Note: "New topic, will create learning at session end"
```

### What to Extract from Learning File

| Section | Purpose | How to Use |
|---------|---------|------------|
| `groupings` | Sub-domain document clusters | Prioritize loading documents from relevant groupings |
| `activations` | Co-activation patterns | Load frequently co-activated documents together |
| `verification_notes` | Past lessons learned | Watch for issues caught before |
| `related_domains` | Cross-domain touchpoints | Know which domain boundaries might need crossing |

### Topic Loading Output

```
Topic: authentication
Learning: v3, 12 sessions contributed
Relevant groupings: token-management (3 docs), session-handling (2 docs)
High-frequency activations: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Verification note: "Always check compliance markers in token docs"
```

---

## Phase 2: Entry Point Discovery

**Goal:** Identify all entry documents and predicted context.

### Step 2.1: Parse DOC-ID References

```
Task: "Implement user authentication flow for story 3.2"

Scan for:
- DOC-XXX-NNN patterns
- REQ-XXX-NNN patterns
- "Documentation References" section

Found entry points:
- DOC-AUTH-001 (primary)
- DOC-API-003 (secondary)
```

### Step 2.2: Determine Task Type

Map the current task to a prediction category:

| Task Type | Prediction Key | Typical Roles |
|-----------|---------------|---------------|
| Requirements gathering | `when_eliciting` | Analyst |
| Documentation writing | `when_documenting` | Analyst |
| Architecture design | `when_architecting` | Architect |
| Design review | `when_reviewing_design` | Architect |
| Implementation | `when_implementing` | Developer |
| Debugging | `when_debugging` | Developer |
| Testing | `when_testing` | Developer, QA |

### Step 2.3: Check Predictions

For each entry document, read its sidecar and check `predictions[task_type]`:

```yaml
# From DOC-AUTH-001.meta.yaml
predictions:
  when_implementing:
    required:
      - DOC-AUTH-002  # Token management
      - DOC-SEC-001   # Security baseline
    likely:
      - DOC-API-001   # API contracts
```

### Entry Point Summary

```
Entry Points: DOC-AUTH-001, DOC-API-003
Task Type: implementing
Predicted Required: DOC-AUTH-002, DOC-SEC-001
Predicted Likely: DOC-API-001
```

---

## Phase 3: Two-Phase Document Loading

**Goal:** Minimize token usage by loading metadata first, then selective full content.

### Phase 3A: Metadata-Only Load

Load only `.meta.yaml` sidecars for:
- Entry point documents
- Predicted required documents
- Predicted likely documents

For each sidecar, extract:
- `id`, `title`, `status`, `domain`
- `summary` (if present)
- `related` (relationships)
- `predictions` (for recursion)
- `boundaries` (traversal rules)
- `reference_frames` (layer, stability, scope)
- `has_critical_markers`

### Phase 3A Output

```
┌──────────────────────────────────────────────────────────────────┐
│ CONTEXT SUMMARY (Metadata Phase)                                  │
├──────────────────────────────────────────────────────────────────┤
│ Documents discovered: 8                                           │
│ High relevance (will load fully): 4                              │
│ Medium relevance (selective sections): 2                         │
│ Low relevance (skip for now): 2                                  │
│                                                                   │
│ Documents with CRITICAL markers: 2                               │
│ Domain boundaries: authentication, rbac (allowed), security      │
│ Isolated from: invoicing, reporting                              │
└──────────────────────────────────────────────────────────────────┘
```

### Phase 3B: Selective Full Load

Load full document content for:
- **High relevance**: Full document
- **Medium relevance**: Specific sections only
- **Documents with `has_critical_markers: true`**: Extract CRITICAL markers

### Relevance Assessment Criteria

| Relevance | Criteria | Action |
|-----------|----------|--------|
| **High** | Entry point, predicted required, depends-on relationship | Load fully |
| **Medium** | Predicted likely, extends relationship | Load summary + key sections |
| **Low** | References relationship, beyond depth 3 | Skip unless needed |

### Reference Frames Filtering (v2)

Use `reference_frames` from sidecars to further filter relevance:

| Task Type | Prioritize Layer | Prioritize Stability |
|-----------|-----------------|---------------------|
| Implementing | implementation, design | stable |
| Debugging | implementation | any |
| Architecting | design, requirements | stable, evolving |
| Eliciting | requirements | evolving |
| Testing | testing, implementation | stable |

**Scope filtering**: Match `reference_frames.scope` to task scope:
- Frontend tasks → prioritize `scope: frontend` or `cross-cutting`
- Backend tasks → prioritize `scope: backend` or `cross-cutting`
- Infrastructure tasks → prioritize `scope: infrastructure` or `cross-cutting`

---

## Phase 4: Boundary-Aware Traversal

**Goal:** Navigate relationships while respecting domain boundaries and monitoring thresholds.

### Relationship Signal Strength

| Type | Signal | Action |
|------|--------|--------|
| `depends-on` | **Strong** | Always follow - cannot understand without |
| `extends` | **Medium** | Follow if depth ≤ 3 |
| `references` | **Weak** | Follow only if directly relevant to task |
| `supersedes` | **Redirect** | Follow target instead of current |

### Traversal Algorithm

```
function traverse(doc, depth, visited):
    if doc in visited: return
    if depth > max_depth: return

    visited.add(doc)
    sidecar = load_sidecar(doc)

    # Check boundaries
    if sidecar.boundaries.isolated_from includes current_domain:
        log("Boundary: isolated from " + doc.domain)
        return

    # Check if crossing domain boundary
    if doc.domain != entry_domain:
        if doc.domain not in sidecar.boundaries.related_domains:
            log("Boundary: stopping at " + doc.domain)
            note_dependency(doc)  # Note but don't traverse
            return

    # Process relationships by signal strength
    for rel in sidecar.related:
        if rel.type == "depends-on":
            traverse(rel.id, depth + 1, visited)  # Always follow
        elif rel.type == "extends" and depth < 3:
            traverse(rel.id, depth + 1, visited)  # Follow if shallow
        elif rel.type == "references":
            if is_relevant_to_task(rel):
                traverse(rel.id, depth + 1, visited)  # Conditional
        elif rel.type == "supersedes":
            traverse(rel.id, depth, visited)  # Redirect (same depth)
```

### Boundary Handling Examples

```
Task: "Design authentication architecture"
Entry: DOC-AUTH-001

✓ DOC-AUTH-002 (same domain: authentication)
✓ DOC-AUTH-003 (same domain)
⚠ DOC-RBAC-001 (boundary: rbac in related_domains)
  → Check: Is RBAC in scope?
  → Decision: Note dependency, don't traverse details
✗ DOC-INV-001 (boundary: invoicing in isolated_from)
  → Skip entirely
```

---

## Phase 5: Context Threshold Monitoring

**Goal:** Detect when context is growing too large and propose decomposition.

### Default Thresholds

```yaml
# From .mlda/config.yaml or defaults
context_limits:
  soft_threshold_tokens: 35000
  hardstop_tokens: 50000
  soft_threshold_documents: 8
  hardstop_documents: 12
```

### Task-Specific Overrides

| Task Type | Soft Threshold | Hardstop |
|-----------|---------------|----------|
| Research | 50,000 tokens | 70,000 |
| Document creation | 30,000 tokens | 45,000 |
| Review | 40,000 tokens | 55,000 |
| Architecture | 30,000 tokens | 45,000 |
| Implementation | 35,000 tokens | 50,000 |

### Token Estimation

Approximate tokens per document type:
- Sidecar only: ~200-500 tokens
- Full document (small): ~1,000-2,000 tokens
- Full document (medium): ~2,000-5,000 tokens
- Full document (large): ~5,000-15,000 tokens

### At Soft Threshold: Self-Assessment

When approaching soft threshold, perform self-assessment:

```
Self-Assessment Checklist:
1. Can I accurately recall key points from earlier documents?
2. Am I finding myself re-reading sections I already processed?
3. Are my extractions becoming more vague or generic?
4. Can I still see clear connections between documents?
5. Am I making assumptions that should be answered by docs I've read?

If 2+ answers concerning → Recommend decomposition
```

### At Hardstop: Propose Decomposition

```
⚠ CONTEXT THRESHOLD REACHED

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

Which approach would you like?
```

---

## Phase 6: Context Synthesis

**Goal:** Produce structured context output (not free-form summary).

### Structured Extraction Template

```yaml
context_gathered:
  entry_points: [DOC-AUTH-001, DOC-API-003]
  task_type: implementing
  documents_processed: 8
  depth_reached: 3

  key_requirements:
    - requirement: "JWT tokens with 15-minute expiry"
      source:
        doc: DOC-AUTH-002
        section: "2.1 Token Lifecycle"
      confidence: high
    - requirement: "Refresh token rotation on each use"
      source:
        doc: DOC-AUTH-002
        section: "2.3"
      confidence: high

  technical_constraints:
    - constraint: "Use existing AuthService pattern"
      source: DOC-API-003
      reason: "Consistency with existing codebase"
    - constraint: "No third-party auth libraries"
      source: DOC-SEC-001
      reason: "Security audit requirement"

  critical_items:  # From <!-- CRITICAL --> markers
    - marker: "compliance"
      content: "Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8"
      source: DOC-AUTH-003, line 47
      verbatim: true

  dependencies_identified:
    - doc_id: DOC-RBAC-001
      reason: "Token claims must include role information"
      traversed: false  # Noted but not loaded

  api_context:
    - endpoint: "POST /auth/token"
      source: DOC-API-003
    - model: "TokenResponse"
      source: DOC-DATA-001

  open_questions:
    - "Token storage: httpOnly cookie vs localStorage?"
    - "Multi-device session handling policy?"

  gaps_identified:
    - "No documentation found for refresh token blacklisting"
    - "Error response format not specified"

  meta:
    context_tokens: ~28,000
    threshold_status: "within soft threshold"
    confidence: high
    recommend_review: []
```

### Critical Marker Extraction

Documents may contain `<!-- CRITICAL: {type} -->` markers. These MUST be extracted verbatim:

```markdown
<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8.
<!-- /CRITICAL -->
```

→ Extract as:
```yaml
critical_items:
  - marker: "compliance"
    content: "Token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8."
    source: DOC-AUTH-003
    verbatim: true
```

---

## User-Facing Output

After gathering context, present to user:

```markdown
## Context Gathered

**Entry Points:** DOC-AUTH-001, DOC-API-003
**Task Type:** implementing
**Documents Processed:** 8
**Depth Reached:** 3
**Context Status:** ✓ Within threshold (28k/35k tokens)

### Key Requirements
- JWT tokens with 15-minute expiry (DOC-AUTH-002)
- Refresh token rotation on each use (DOC-AUTH-002)

### Technical Constraints
- Use existing AuthService pattern (DOC-API-003)
- No third-party auth libraries (DOC-SEC-001)

### Critical Items (Compliance)
> ⚠ Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8
> Source: DOC-AUTH-003 (verbatim)

### Dependencies Noted
- DOC-RBAC-001: Token claims need role information (not traversed)

### Open Questions
1. Token storage: httpOnly cookie vs localStorage?
2. Multi-device session handling policy?

### Gaps Found
- No documentation for refresh token blacklisting
- Error response format not specified

---
Ready to proceed with: [task description]
Shall I explore any area deeper?
```

---

## Decomposition Protocol

When thresholds are exceeded, propose multi-agent decomposition:

### Sub-Agent Spawn Format

```
Spawning sub-agent for: token-management
Documents: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007, DOC-AUTH-009]
Task: "Extract token management requirements for authentication implementation"
Return format: structured_yaml
```

### Sub-Agent Return Format

```yaml
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

meta:
  completeness_confidence: medium
  uncertainty_flags:
    - doc: DOC-AUTH-007
      section: "3.2"
      reason: "Ambiguous language about edge cases"
  recommend_primary_review: [DOC-AUTH-007 section 3.2]
```

---

## Depth Guidelines by Role

| Role | Default Depth | Focus Areas |
|------|---------------|-------------|
| Developer | 3 | Implementation details, API contracts, data models |
| QA | 4 | Requirements → test path, edge cases |
| Architect | 5 | Broader system understanding, cross-domain |
| Analyst | 4 | Requirements context, stakeholder docs |

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No MLDA folder | Inform user, suggest `/skills:init-project` |
| Entry point not found | Search registry for similar, suggest alternatives |
| Broken relationship | Log warning, continue with available paths |
| Insufficient context | Report gaps, ask for additional entry points |
| Registry outdated | Suggest running `mlda-registry.ps1` |
| Topic doesn't exist | Note as new topic, proceed without learnings |
| Threshold exceeded | Present decomposition options (don't auto-decompose) |

---

## Integration Points

### With Topic Learning

At session end, if new patterns discovered:
```
New learnings identified:
- Co-activation: [DOC-AUTH-001, DOC-SEC-001, DOC-API-003]
- Verification note: "DOC-AUTH-007 section 3.2 is ambiguous"

Save to .mlda/topics/authentication/learning.yaml? [y/n]
```

---

## Commands

Invoke this skill via:
- `/skills:gather-context`
- `*gather-context` (when in agent mode)
- Automatically triggered when story with DOC-IDs is loaded

---

*gather-context v2.1 | Neocortex Methodology | DEC-002 Implementation | Sidecar v2 aligned*
