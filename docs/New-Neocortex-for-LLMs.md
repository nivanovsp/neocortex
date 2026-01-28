# Neocortex v3: LLM-Native Architecture

**Status**: Proposal
**Version**: 0.1.4
**Date**: 2026-01-26
**Author**: Claude (Architect Mode)
**Revisions**:
- 0.1.1: Changed chunk/memory storage from YAML to Markdown with frontmatter
- 0.1.2: Removed config.yaml, using folder existence for detection + environment variables for settings
- 0.1.3: Decided embedding model: local `e5-small-v2` (free, no API needed)
- 0.1.4: Decided vector index: NumPy + pickle (simple, zero deps, fast enough)

---

## Executive Summary

The current Neocortex/MLDA methodology consumes 35-40% of context window at session start for a moderately complex project. This document proposes **Neocortex v3**, a revolutionary redesign based on how LLMs actually process information rather than human cognitive metaphors.

**Key Changes:**
- Replace graph traversal with embedding-based retrieval
- Replace monolithic document loading with chunk-based assembly
- Replace YAML-heavy structures with natural language + minimal metadata
- Replace predefined relationship types with semantic similarity
- Implement position-aware context assembly (primacy/recency optimization)
- Introduce atomic experiential memories instead of monolithic learning files

**Expected Outcome:** Reduce initial context consumption from 35-40% to 5-10% while improving relevance of loaded context.

---

## Table of Contents

1. [The Problem in Detail](#1-the-problem-in-detail)
2. [LLM Processing Fundamentals](#2-llm-processing-fundamentals)
3. [Neocortex v3 Architecture](#3-neocortex-v3-architecture)
4. [Detailed Component Specifications](#4-detailed-component-specifications)
5. [Implementation Plan](#5-implementation-plan)
6. [Migration Strategy](#6-migration-strategy)
7. [Coexistence Strategy](#7-coexistence-strategy)
8. [Risk Assessment](#8-risk-assessment)
9. [Open Questions](#9-open-questions)

---

## 1. The Problem in Detail

### 1.1 Current Context Consumption Breakdown

For a moderately complex project (Tasks App), the current system loads:

| Component | Approximate Tokens | % of 200K Window |
|-----------|-------------------|------------------|
| Global CLAUDE.md | ~4,000 | 2% |
| Project CLAUDE.md | ~5,000 | 2.5% |
| Mode activation file | ~2,000 | 1% |
| learning-index.yaml | ~500 | 0.25% |
| bd ready --json | ~300 | 0.15% |
| handoff.md (full) | ~15,000 | 7.5% |
| Topic learning.yaml (on task) | ~3,000 | 1.5% |
| Referenced documents | ~20,000+ | 10%+ |
| System prompts & tools | ~20,000 | 10% |
| **Total at Task Start** | **~70,000** | **~35%** |

For a complex enterprise project, this could easily reach:
- handoff.md: 30,000+ tokens (multiple phases, many decisions)
- Multiple topic learnings: 10,000+ tokens
- Referenced documents: 50,000+ tokens
- **Total: 120,000+ tokens (60%+)**

### 1.2 Why This Is Architecturally Flawed

The current approach has three fundamental problems:

#### Problem 1: Load-Everything Model

The system loads entire documents even when only specific sections are relevant. A 2,000-token document loaded for a 50-token relevant section is 97.5% waste.

```
Current: Load DOC-AUTH-001 (2000 tokens) → Use 50 tokens → 97.5% waste
Optimal: Retrieve relevant chunk (60 tokens) → Use 50 tokens → 17% overhead
```

#### Problem 2: Human Mental Model Mismatch

The "neural network" metaphor assumes:
- Sequential signal propagation (LLMs process in parallel)
- Predefined connection strengths (LLMs determine relevance dynamically)
- Navigation through links (LLMs see full context simultaneously)

This mismatch means the architecture fights against LLM processing patterns rather than leveraging them.

#### Problem 3: Position-Agnostic Loading

Current system doesn't consider where information lands in context:
- Critical requirements might end up in the "lost middle" zone
- Background context might consume prime positions
- No optimization for primacy/recency bias

### 1.3 Scaling Problem

| Project Complexity | Current Approach | LLM-Native Approach |
|-------------------|------------------|---------------------|
| Simple (Tasks App) | 35% | ~8% |
| Medium (Enterprise API) | 50% | ~10% |
| Complex (Multi-service Platform) | 65%+ | ~12% |
| Very Complex (Enterprise Suite) | 80%+ (unusable) | ~15% |

The current approach scales linearly (or worse) with project complexity. The LLM-native approach scales logarithmically because it retrieves only relevant chunks.

---

## 2. LLM Processing Fundamentals

### 2.1 How Attention Mechanisms Work

LLMs use **self-attention** to process context:

```
For each token being processed:
  1. Create Query vector (Q) from current token
  2. Create Key vectors (K) from all context tokens
  3. Create Value vectors (V) from all context tokens
  4. Compute attention scores: softmax(Q · K^T / √d)
  5. Weight Values by attention scores
  6. Sum weighted Values for output
```

**Critical Insight:** Attention is computed for ALL tokens simultaneously. There is no "traversal" or "signal propagation" - the model sees everything at once and computes relevance scores dynamically.

### 2.2 The "Lost in the Middle" Phenomenon

Research demonstrates a U-shaped attention curve:

```
Attention
    │
100%├─■                                           ■
    │  ■                                        ■
 80%├    ■                                    ■
    │      ■                                ■
 60%├        ■                            ■
    │          ■                        ■
 40%├            ■■                  ■■
    │               ■■■■■■■■■■■■■■■■
 20%├─────────────────────────────────────────────
    │
    └─────────────────────────────────────────────►
      Start              Middle               End
              Position in Context Window
```

**Implications:**
- Information at positions 0-15% gets high attention (primacy)
- Information at positions 85-100% gets high attention (recency)
- Information at positions 30-70% receives degraded attention
- Critical information in the middle may be effectively ignored

### 2.3 Structured Format Processing Overhead

Research shows structured formats impose cognitive overhead:

| Format | Reasoning Degradation | Token Efficiency |
|--------|----------------------|------------------|
| Natural Language | 0% (baseline) | Medium |
| Markdown | 2-5% | Good |
| JSON | 10-15% | Poor |
| YAML | 8-12% | Medium |
| XML | 15-20% | Very Poor |

**Current MLDA Problem:** Heavy YAML usage (sidecars, learning files, registry) imposes 8-12% reasoning penalty on top of token consumption.

### 2.4 Optimal Information Density

Research on context engineering reveals optimal patterns:

```
HIGH SIGNAL                          LOW SIGNAL
─────────────────────────────────────────────────
"Use JWT with RS256"                 "Authentication is important
                                      for security. There are many
                                      ways to implement auth..."

"FormField wrapper required          "When working with forms,
for PasswordInput"                    consider various input types
                                      and their validation needs..."
```

**Principle:** Every token should carry maximum signal. Verbose explanations dilute information density.

---

## 3. Neocortex v3 Architecture

### 3.1 Core Paradigm Shift

| Aspect | Neocortex v2 (Current) | Neocortex v3 (Proposed) |
|--------|------------------------|-------------------------|
| **Model** | Knowledge Graph (neural network metaphor) | Semantic Memory Space (embedding space) |
| **Unit** | Document | Chunk (atomic knowledge unit) |
| **Connection** | Predefined relationships (depends-on, extends) | Dynamic semantic similarity |
| **Retrieval** | Graph traversal | Vector similarity search |
| **Loading** | Full documents | Relevant chunks only |
| **Position** | Arbitrary | Optimized for attention patterns |
| **Format** | YAML-heavy | Natural language primary |
| **Memory** | Monolithic files | Atomic memories with embeddings |

### 3.2 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     NEOCORTEX v3 ARCHITECTURE                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │   CHUNK      │     │   MEMORY     │     │   CONTEXT    │    │
│  │   STORE      │     │   STORE      │     │   ASSEMBLER  │    │
│  │              │     │              │     │              │    │
│  │ - Embeddings │     │ - Atomic     │     │ - Position   │    │
│  │ - Metadata   │     │   memories   │     │   aware      │    │
│  │ - Source ref │     │ - Keywords   │     │ - Relevance  │    │
│  │              │     │ - Links      │     │   ranked     │    │
│  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘    │
│         │                    │                    │             │
│         └────────────────────┼────────────────────┘             │
│                              │                                  │
│                              ▼                                  │
│                    ┌──────────────────┐                         │
│                    │    RETRIEVAL     │                         │
│                    │    ENGINE        │                         │
│                    │                  │                         │
│                    │ - Query embedding│                         │
│                    │ - Similarity     │                         │
│                    │ - Ranking        │                         │
│                    │ - Deduplication  │                         │
│                    └────────┬─────────┘                         │
│                             │                                   │
│                             ▼                                   │
│                    ┌──────────────────┐                         │
│                    │  CONTEXT FRAME   │                         │
│                    │                  │                         │
│                    │ [CRITICAL-TOP]   │ ← Primacy zone          │
│                    │ [SUPPORTING]     │ ← Middle (less critical)│
│                    │ [BACKGROUND]     │ ← Middle (background)   │
│                    │ [CRITICAL-BOT]   │ ← Recency zone          │
│                    │ [INSTRUCTIONS]   │ ← Very end              │
│                    └──────────────────┘                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 The Three Stores

#### 3.3.1 Chunk Store

Replaces document-based storage with chunk-based:

```
Source Document (DOC-AUTH-001, 2000 tokens)
                    │
                    ▼
         ┌──────────┴──────────┐
         │      CHUNKER        │
         │  (semantic-aware)   │
         └──────────┬──────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌────────┐    ┌────────┐     ┌────────┐
│Chunk 1 │    │Chunk 2 │     │Chunk 3 │
│~300 tok│    │~400 tok│     │~350 tok│
│        │    │        │     │        │
│embed:  │    │embed:  │     │embed:  │
│[0.2,.. │    │[0.1,.. │     │[-0.3,..│
│        │    │        │     │        │
│source: │    │source: │     │source: │
│AUTH-001│    │AUTH-001│     │AUTH-001│
│sec: 2  │    │sec: 3  │     │sec: 4  │
└────────┘    └────────┘     └────────┘
```

**Chunk Schema (Markdown with YAML frontmatter):**
```markdown
---
id: CHK-AUTH-001-003
source_doc: DOC-AUTH-001
source_section: "Token Refresh Logic"
source_lines: [45, 72]
tokens: 47
keywords: ["token", "refresh", "jwt", "cookie", "401"]
created: "2026-01-20"
last_retrieved: "2026-01-25"
retrieval_count: 12
---

Token refresh uses silent refresh pattern. Access tokens expire
after 15 minutes. Refresh tokens stored in httpOnly cookies.
On 401 response, automatically attempt refresh before retry.
```

**Why Markdown?** Research shows YAML imposes 8-12% reasoning degradation vs 2-5% for Markdown. Content is in natural language format that LLMs process optimally. Metadata stays structured (small YAML frontmatter) for scripts to parse.

#### 3.3.2 Memory Store

Replaces monolithic learning.yaml with atomic memories:

```markdown
---
id: MEM-2026-01-20-001
type: experiential
domain: AUTH
confidence: high
keywords: ["form", "password", "input", "wrapper", "oauth"]
source_session: "2026-01-20-afternoon"
task_context: "Implement OAuth settings UI"
related_docs: ["DOC-AUTH-001", "DOC-UI-003"]
retrieval_count: 5
last_retrieved: "2026-01-25"
verified: true
---

## Learning

FormField wrapper is required for PasswordInput component.
Using label prop directly on PasswordInput doesn't work.

## Context

Discovered while implementing OAuth settings UI.
The component threw a runtime error without the wrapper.
```

**Memory Types:**

| Type | Description | Example |
|------|-------------|---------|
| **Factual** | Stable knowledge, rarely changes | "API uses REST with JSON responses" |
| **Experiential** | Lessons learned, may evolve | "FormField wrapper required for PasswordInput" |
| **Procedural** | How to do something | "Run bd ready before starting work" |

#### 3.3.3 Context Assembler

Builds position-optimized context frames:

```
Input: Task description + current state
                │
                ▼
        ┌───────────────┐
        │ Query Encoder │
        └───────┬───────┘
                │
                ▼
        ┌───────────────┐
        │  Retriever    │──► Top-k chunks from Chunk Store
        │               │──► Top-k memories from Memory Store
        └───────┬───────┘
                │
                ▼
        ┌───────────────┐
        │   Ranker      │──► Score by relevance to task
        │               │──► Deduplicate overlapping content
        └───────┬───────┘
                │
                ▼
        ┌───────────────┐
        │  Assembler    │──► Position-aware placement
        │               │──► Token budget management
        └───────┬───────┘
                │
                ▼
        [Context Frame]
```

### 3.4 Context Frame Structure

The Context Frame is the assembled context sent to the LLM:

```markdown
<!-- CONTEXT FRAME: Task XYZ -->

## CRITICAL: Task Definition
<!-- POSITION: TOP (primacy zone, high attention) -->

**Task:** Implement token refresh in OAuth settings
**Acceptance Criteria:**
- Silent refresh on 401 responses
- Refresh token in httpOnly cookie
- User sees no interruption

**Blockers:** None
**Dependencies:** DOC-AUTH-001 (token logic)

---

## Relevant Knowledge
<!-- POSITION: UPPER-MIDDLE (moderate attention) -->

### From DOC-AUTH-001 (Token Refresh Logic)
Token refresh uses silent refresh pattern. Access tokens expire
after 15 minutes. Refresh tokens stored in httpOnly cookies.
On 401 response, automatically attempt refresh before retry.

### From DOC-SEC-001 (Security Requirements)
All tokens must use RS256 signing. Never expose refresh tokens
to JavaScript. Cookie must have SameSite=Strict.

---

## Past Learnings
<!-- POSITION: LOWER-MIDDLE (moderate attention) -->

- FormField wrapper required for PasswordInput (MEM-2026-01-20-001)
- Settings components live in src/components/settings/ (MEM-2026-01-18-003)
- Always test with expired token scenario (MEM-2026-01-22-001)

---

## Current State
<!-- POSITION: BOTTOM (recency zone, high attention) -->

**Phase:** Development
**Epic:** Authentication System
**Story:** STORY-AUTH-005 (Token Refresh)
**Status:** In Progress

**Recent Changes:**
- OAuth provider selection implemented (2026-01-24)
- Token storage mechanism decided: httpOnly cookies (2026-01-23)

---

## Instructions
<!-- POSITION: VERY END (maximum recency attention) -->

Implement the token refresh logic following the patterns above.
Focus on the silent refresh mechanism. Test with expired tokens.
```

### 3.5 Token Budget Management

The Context Assembler manages a strict token budget:

```
Total Available: 200,000 tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reserved (fixed):
  - System prompts & tools:     20,000 tokens (10%)
  - CLAUDE.md (global+project): 10,000 tokens (5%)
  - Mode activation:             2,000 tokens (1%)
  - Response generation:        40,000 tokens (20%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Subtotal Reserved:              72,000 tokens (36%)

Available for Context Frame:   128,000 tokens (64%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Context Frame Budget Allocation:
  - CRITICAL-TOP (task):         2,000 tokens (1.5%)
  - Relevant Knowledge:         10,000 tokens (8%)    ← Retrieved chunks
  - Past Learnings:              2,000 tokens (1.5%)  ← Retrieved memories
  - Current State:               1,000 tokens (0.8%)
  - Instructions:                  500 tokens (0.4%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Context Frame Total:            15,500 tokens (~12%)

Remaining for Conversation:    112,500 tokens (56%)
```

**Comparison:**
- Current approach: 70,000 tokens (35%) consumed at task start
- Neocortex v3: 15,500 tokens (8%) consumed at task start
- **Improvement: 77% reduction in initial context consumption**

---

## 4. Detailed Component Specifications

### 4.1 Chunk Store Implementation

#### 4.1.1 Chunking Strategy

**Semantic-Aware Chunking** (not fixed-size):

```python
# Pseudocode for semantic chunking
def chunk_document(doc: Document) -> List[Chunk]:
    # 1. Split by markdown headers first
    sections = split_by_headers(doc.content)

    chunks = []
    for section in sections:
        # 2. If section is small enough, keep as single chunk
        if token_count(section) <= MAX_CHUNK_SIZE:  # 500 tokens
            chunks.append(create_chunk(section))
        else:
            # 3. Split large sections by paragraph
            paragraphs = split_by_paragraph(section)

            # 4. Merge small paragraphs, split large ones
            current_chunk = ""
            for para in paragraphs:
                if token_count(current_chunk + para) <= MAX_CHUNK_SIZE:
                    current_chunk += para
                else:
                    if current_chunk:
                        chunks.append(create_chunk(current_chunk))
                    current_chunk = para

            if current_chunk:
                chunks.append(create_chunk(current_chunk))

    return chunks
```

**Chunking Parameters:**

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| MAX_CHUNK_SIZE | 500 tokens | Balance between context and granularity |
| MIN_CHUNK_SIZE | 50 tokens | Avoid fragments that lack context |
| OVERLAP | 50 tokens | Maintain continuity at boundaries |
| HEADER_WEIGHT | 1.5x | Headers are natural chunk boundaries |

#### 4.1.2 Embedding Generation

**Embedding Model: `e5-small-v2` (Local, Free)**

| Model | Dimensions | Size | Max Tokens | Cost |
|-------|------------|------|------------|------|
| `intfloat/e5-small-v2` | 384 | ~130MB | 512 | Free |

**Why this model:**
- Specifically designed for retrieval tasks (our exact use case)
- 512 token max aligns with our chunk size (500 tokens)
- Outperforms alternatives on retrieval benchmarks
- Runs locally - no API costs, no internet required
- Fast on any modern CPU

**Setup** (handled automatically by `ncx-init`):
```powershell
pip install sentence-transformers
# Model auto-downloads on first use (~130MB)
```

**Embedding Storage (Markdown with frontmatter):**

```markdown
<!-- File: .neocortex/chunks/AUTH/AUTH-001-003.md -->
---
id: CHK-AUTH-001-003
source_doc: DOC-AUTH-001
source_section: "Token Refresh Logic"
source_lines: [45, 72]
tokens: 47
keywords: ["token", "refresh", "jwt"]
created: "2026-01-20T14:30:00Z"
retrieval_count: 12
---

Token refresh uses silent refresh pattern. Access tokens expire
after 15 minutes. Refresh tokens stored in httpOnly cookies.
On 401 response, automatically attempt refresh before retry.
```

Embedding vectors stored separately in binary `.emb` files for efficiency.

**Embedding Index:**

```
.neocortex/
├── chunks/
│   ├── AUTH/
│   │   ├── AUTH-001-001.md       # Markdown chunk (LLM-friendly)
│   │   ├── AUTH-001-001.emb      # Binary embedding vector
│   │   ├── AUTH-001-002.md
│   │   └── ...
│   └── UI/
│       └── ...
├── index/
│   ├── chunks.index      # FAISS or similar vector index
│   └── chunks.metadata   # Fast metadata lookup
└── ...
```

#### 4.1.3 Chunk Retrieval

**Retrieval Algorithm:**

```python
def retrieve_chunks(query: str, k: int = 10) -> List[Chunk]:
    # 1. Embed the query
    query_embedding = embed(query)

    # 2. Find k nearest neighbors in vector space
    candidates = vector_index.search(query_embedding, k=k*2)  # Over-fetch

    # 3. Re-rank by additional signals
    ranked = []
    for chunk_id, similarity in candidates:
        chunk = load_chunk(chunk_id)
        score = compute_final_score(
            similarity=similarity,
            recency=chunk.last_retrieved,
            frequency=chunk.retrieval_count,
            keyword_overlap=keyword_match(query, chunk.keywords)
        )
        ranked.append((chunk, score))

    # 4. Sort and deduplicate
    ranked.sort(key=lambda x: x[1], reverse=True)
    deduplicated = remove_overlapping_chunks(ranked)

    # 5. Return top-k
    return deduplicated[:k]
```

**Scoring Formula:**

```
final_score = (
    0.6 * semantic_similarity +     # Primary signal
    0.2 * keyword_overlap +         # Keyword boost
    0.1 * recency_factor +          # Recent chunks slightly preferred
    0.1 * frequency_factor          # Frequently useful chunks preferred
)
```

### 4.2 Memory Store Implementation

#### 4.2.1 Memory Schema (Markdown with YAML Frontmatter)

```markdown
<!-- File: .neocortex/memories/MEM-2026-01-20-001.md -->
---
id: MEM-2026-01-20-001
version: 1

# Classification
type: experiential
domain: AUTH
confidence: high

# Extraction metadata
source_session: "2026-01-20-afternoon"
source_task: "Implement OAuth settings UI"
trigger: runtime_error

# Semantic indexing
keywords: ["form", "password", "input", "wrapper", "oauth", "settings"]

# Relationships (discovered via embedding similarity)
related:
  - id: MEM-2026-01-18-003
    similarity: 0.82
  - id: CHK-UI-003-002
    similarity: 0.76

# Evolution tracking
created: "2026-01-20T16:45:00Z"
updated: "2026-01-20T16:45:00Z"
verified: true
verification_date: "2026-01-22T10:00:00Z"

# Usage statistics
retrieval_count: 5
last_retrieved: "2026-01-25T09:30:00Z"
usefulness_score: 0.9
---

## Learning

FormField wrapper is required for PasswordInput component.
Using label prop directly on PasswordInput doesn't work.

## Context

Discovered while implementing OAuth settings UI.
The component threw a runtime error without the wrapper.

## Related

- **MEM-2026-01-18-003** (0.82): Both about form components
- **CHK-UI-003-002** (0.76): Form component documentation
```

Embedding vectors stored separately in `.emb` files (binary format).

#### 4.2.2 Memory Formation

**When Memories Are Created:**

| Trigger | Description | Memory Type |
|---------|-------------|-------------|
| Error Resolution | Fixed a bug, learned cause | Experiential |
| Verification | Confirmed something works | Factual |
| Pattern Discovery | Found a useful pattern | Procedural |
| Explicit Save | User says "remember this" | Any |
| Session End | Agent proposes key learnings | Any |

**Memory Extraction Process:**

```python
def extract_memories(session: Session) -> List[Memory]:
    memories = []

    # 1. Scan for explicit learning markers
    explicit = find_explicit_learnings(session.conversation)
    memories.extend(explicit)

    # 2. Detect error resolution patterns
    errors = find_error_resolutions(session.conversation)
    for error in errors:
        if error.was_resolved:
            memories.append(create_memory(
                type="experiential",
                content=f"{error.symptom} → {error.solution}",
                context=error.context,
                confidence="high" if error.verified else "medium"
            ))

    # 3. Detect verification patterns
    verifications = find_verifications(session.conversation)
    for v in verifications:
        memories.append(create_memory(
            type="factual",
            content=v.confirmed_fact,
            confidence="high"
        ))

    # 4. Propose session summary learnings
    summary = generate_session_summary(session)
    memories.extend(summary.proposed_learnings)

    # 5. Generate embeddings and find relationships
    for memory in memories:
        memory.embedding = embed(memory.content + memory.context)
        memory.related = find_similar_memories(memory.embedding)

    return memories
```

#### 4.2.3 Memory Evolution

Memories are not static. They evolve:

```python
def update_memory(memory: Memory, feedback: Feedback):
    if feedback.type == "confirmed_useful":
        memory.usefulness_score = min(1.0, memory.usefulness_score + 0.1)
        memory.confidence = upgrade_confidence(memory.confidence)

    elif feedback.type == "incorrect":
        memory.confidence = "low"
        memory.content += f"\n\n[CORRECTION {today()}]: {feedback.correction}"
        memory.embedding = embed(memory.content)  # Re-embed

    elif feedback.type == "superseded":
        memory.status = "superseded"
        memory.superseded_by = feedback.new_memory_id

    memory.updated = now()
    save_memory(memory)
```

### 4.3 Context Assembler Implementation

#### 4.3.1 Assembly Pipeline

```python
def assemble_context(task: Task, budget: TokenBudget) -> ContextFrame:
    frame = ContextFrame()

    # === PHASE 1: CRITICAL-TOP (Primacy Zone) ===
    frame.critical_top = format_task_definition(
        task=task,
        acceptance_criteria=task.acceptance_criteria,
        blockers=task.blockers,
        dependencies=task.doc_refs
    )
    budget.consume(frame.critical_top)

    # === PHASE 2: Retrieve Relevant Chunks ===
    query = f"{task.title} {task.description} {' '.join(task.keywords)}"
    chunks = retrieve_chunks(query, k=20)

    # Filter to budget
    selected_chunks = []
    for chunk in chunks:
        if budget.can_fit(chunk.tokens):
            selected_chunks.append(chunk)
            budget.consume(chunk.tokens)
        if len(selected_chunks) >= 10:
            break

    frame.relevant_knowledge = format_chunks(selected_chunks)

    # === PHASE 3: Retrieve Relevant Memories ===
    memories = retrieve_memories(query, k=10)

    selected_memories = []
    for memory in memories:
        if budget.can_fit(memory.tokens):
            selected_memories.append(memory)
            budget.consume(memory.tokens)
        if len(selected_memories) >= 5:
            break

    frame.past_learnings = format_memories(selected_memories)

    # === PHASE 4: CRITICAL-BOTTOM (Recency Zone) ===
    frame.current_state = format_current_state(
        phase=get_current_phase(),
        recent_changes=get_recent_changes(limit=3),
        beads_status=get_beads_status()
    )
    budget.consume(frame.current_state)

    # === PHASE 5: Instructions (Very End) ===
    frame.instructions = generate_instructions(task)
    budget.consume(frame.instructions)

    return frame
```

#### 4.3.2 Position-Aware Formatting

```python
def format_context_frame(frame: ContextFrame) -> str:
    """
    Assemble frame with position optimization.

    Position importance (based on attention research):
    - 0-15%: HIGH (primacy)
    - 15-35%: MEDIUM-HIGH
    - 35-65%: LOW (lost in middle)
    - 65-85%: MEDIUM-HIGH
    - 85-100%: HIGH (recency)

    Strategy: Put critical info in 0-15% and 85-100%
    Put supporting info in 15-35% and 65-85%
    Put background info in 35-65%
    """

    output = []

    # === PRIMACY ZONE (0-15%) ===
    output.append("## CRITICAL: Task Definition")
    output.append(frame.critical_top)
    output.append("")

    # === UPPER-MIDDLE (15-35%) ===
    output.append("## Relevant Knowledge")
    output.append(frame.relevant_knowledge)
    output.append("")

    # === MIDDLE (35-65%) - least critical ===
    output.append("## Background Context")
    output.append(frame.background)  # If any
    output.append("")

    # === LOWER-MIDDLE (65-85%) ===
    output.append("## Past Learnings")
    output.append(frame.past_learnings)
    output.append("")

    # === RECENCY ZONE (85-100%) ===
    output.append("## Current State")
    output.append(frame.current_state)
    output.append("")

    output.append("## Instructions")
    output.append(frame.instructions)

    return "\n".join(output)
```

### 4.4 Index Management

#### 4.4.1 Vector Index

**Technology: NumPy + Pickle (Brute-Force)**

At the scale of a methodology framework (<500 chunks), brute-force cosine similarity is:
- **Fast enough:** <1ms for 500 vectors on any modern CPU
- **Zero dependencies:** NumPy already required for embeddings
- **Simple:** No index corruption, no rebuild needed, just load and search

**Index Structure:**

```
.neocortex/index/
├── chunks.pkl        # Pickled numpy array of chunk embeddings
├── chunks.meta.json  # Chunk ID → metadata mapping
├── memories.pkl      # Pickled numpy array of memory embeddings
└── memories.meta.json
```

**Upgrade Path:** If projects grow to 10K+ chunks, can migrate to FAISS with a simple script change.

#### 4.4.2 Index Updates

**Incremental Update Strategy:**

```python
def update_index_for_document(doc: Document):
    # 1. Remove old chunks for this document
    old_chunk_ids = index.get_chunks_for_doc(doc.id)
    index.remove(old_chunk_ids)

    # 2. Chunk the updated document
    new_chunks = chunk_document(doc)

    # 3. Generate embeddings
    for chunk in new_chunks:
        chunk.embedding = embed(chunk.content)

    # 4. Add to index
    index.add(new_chunks)

    # 5. Save chunk files
    for chunk in new_chunks:
        save_chunk(chunk)

    # 6. Update metadata
    index.save_metadata()
```

**Full Rebuild (periodic):**

```bash
# Run weekly or after major changes
neocortex index rebuild --full
```

### 4.5 Scripts and Tooling

#### 4.5.1 Core Scripts

| Script | Purpose | Input | Output |
|--------|---------|-------|--------|
| `ncx-init` | Initialize Neocortex v3 | Project root | .neocortex/ structure |
| `ncx-chunk` | Chunk a document | Document path | Chunk files + index update |
| `ncx-index` | Rebuild vector indices | All chunks/memories | Index files |
| `ncx-retrieve` | Test retrieval | Query string | Ranked results |
| `ncx-assemble` | Build context frame | Task description | Context frame |
| `ncx-memory add` | Add a memory | Memory content | Memory file |
| `ncx-memory evolve` | Update memory | Memory ID + feedback | Updated memory |
| `ncx-migrate` | Migrate from v2 | .mlda/ | .neocortex/ |

#### 4.5.2 Integration Points

**Mode Activation (simplified):**

```markdown
<!-- File: .claude/commands/modes/analyst.md -->

## Neocortex v3 Protocol

### On Activation

1. Run `ncx-status` for quick health check (< 100 tokens output)
2. Run `bd ready --json` to see available tasks
3. Greet as your persona and show ready tasks
4. **Do NOT load documents** - wait for task selection

### On Task Start

When user selects a task:

1. Run `ncx-assemble --task "{task_description}"` to build context frame
2. The context frame contains position-optimized relevant knowledge
3. Proceed with task using assembled context
```

This keeps mode files as pure Markdown - no embedded YAML that would incur the 8-12% reasoning penalty.

**Beads Integration:**

```python
def on_task_selected(task_id: str):
    task = beads.get(task_id)

    # Build query from task metadata
    query = f"{task.title} {task.description}"
    if task.labels:
        query += f" {' '.join(task.labels)}"

    # Assemble context frame
    frame = ncx_assemble(query)

    # Inject into conversation
    inject_context(frame)
```

---

## 5. Implementation Plan

**Implementation Note:** All scripts, tooling, and setup will be implemented by Claude during the development phases. No prior experience with embeddings, vector indices, or ML tooling is required from the user. The `ncx-init` script will handle all dependencies and configuration automatically.

### 5.1 Phase 1: Foundation (Week 1-2)

**Objective:** Create core infrastructure without changing existing workflow.

**Deliverables:**

1. **Directory Structure**
   ```
   .neocortex/
   ├── chunks/               # Chunk storage by domain
   ├── memories/             # Memory storage
   ├── index/                # Vector indices
   └── scripts/              # PowerShell scripts
   ```

   Version detection: Presence of `.neocortex/` folder indicates v3.
   Settings via environment variables (see Appendix D).

2. **Chunking Pipeline**
   - Semantic-aware chunker
   - Markdown header detection
   - Token counting (tiktoken)
   - Chunk file generation

3. **Embedding Pipeline**
   - Local `e5-small-v2` model via sentence-transformers
   - Batch embedding for efficiency
   - Embedding storage format (binary `.emb` files)

4. **Vector Index**
   - FAISS or Annoy integration
   - Index creation and update
   - Basic similarity search

**Success Criteria:**
- Can chunk a document into semantic units
- Can embed chunks and store in vector index
- Can retrieve top-k similar chunks for a query

### 5.2 Phase 2: Memory System (Week 3-4)

**Objective:** Implement atomic memory system.

**Deliverables:**

1. **Memory Schema**
   - Markdown with YAML frontmatter specification
   - Validation schema for frontmatter
   - Relationship tracking

2. **Memory Formation**
   - Manual memory creation (`ncx-memory add`)
   - Memory embedding and indexing
   - Automatic relationship discovery

3. **Memory Retrieval**
   - Similarity-based retrieval
   - Filtering by type, domain, confidence
   - Relevance scoring

4. **Memory Evolution**
   - Update mechanisms
   - Supersession tracking
   - Confidence adjustment

**Success Criteria:**
- Can create memories manually
- Can retrieve relevant memories for a query
- Can update memory confidence/content

### 5.3 Phase 3: Context Assembly (Week 5-6)

**Objective:** Build the context assembler with position optimization.

**Deliverables:**

1. **Context Frame Structure**
   - Position zones (primacy, middle, recency)
   - Token budget management
   - Section formatting

2. **Assembly Pipeline**
   - Query construction from task
   - Chunk retrieval and selection
   - Memory retrieval and selection
   - Frame composition

3. **Integration Scripts**
   - `ncx-assemble` command
   - Beads integration hook
   - Mode activation integration

**Success Criteria:**
- Can build context frame for a task
- Frame respects token budget
- Critical info at edges, supporting in middle

### 5.4 Phase 4: Mode Integration (Week 7-8)

**Objective:** Integrate with existing mode/skill system.

**Deliverables:**

1. **Mode Activation Protocol**
   - Minimal activation (status check only)
   - On-demand context loading
   - Context frame injection

2. **Skill Updates**
   - `*gather-context` uses v3 assembly
   - `*memory save` creates atomic memory
   - `*memory query` retrieves relevant memories

3. **Learning Extraction**
   - Session-end memory extraction
   - Automatic relationship discovery
   - Memory proposal for user review

**Success Criteria:**
- Mode activation < 5% context
- Task start loads relevant context only
- Memories are created from sessions

### 5.5 Phase 5: Migration & Optimization (Week 9-10)

**Objective:** Migrate existing data and optimize performance.

**Deliverables:**

1. **Migration Script**
   - Convert existing documents to chunks
   - Convert learning.yaml to atomic memories
   - Preserve DOC-IDs as source references

2. **Performance Optimization**
   - Index compression
   - Caching for frequent retrievals
   - Parallel embedding generation

3. **Quality Tuning**
   - Retrieval quality evaluation
   - Scoring formula adjustment
   - Position optimization refinement

**Success Criteria:**
- All existing knowledge migrated
- Retrieval quality >= current relevance
- Performance acceptable (< 2s for context assembly)

---

## 6. Migration Strategy

### 6.1 What Changes

| Current (v2) | New (v3) | Migration |
|--------------|----------|-----------|
| `.mlda/docs/*.md` | `.neocortex/chunks/` | Chunk and embed |
| `.mlda/docs/*.meta.yaml` | Chunk metadata | Extract to chunks |
| `.mlda/topics/*/learning.yaml` | `.neocortex/memories/` | Split into atomic memories |
| `.mlda/topics/*/domain.yaml` | Not migrated | Domain info embedded in chunk metadata |
| `.mlda/registry.yaml` | `.neocortex/index/` | Replaced by vector index |
| `.mlda/learning-index.yaml` | Not needed | Replaced by memory index |
| `docs/handoff.md` | Kept (chunked) | Chunk and embed |

### 6.2 What Stays the Same

| Component | Status | Notes |
|-----------|--------|-------|
| DOC-IDs | Preserved | Stored in chunk metadata as `source_doc` |
| Document content | Preserved | Chunks reference original documents |
| CLAUDE.md files | Unchanged | Still loaded at session start |
| Mode files | Modified | Updated activation protocol |
| Skill files | Modified | Updated context gathering |
| Beads integration | Enhanced | Triggers context assembly |

### 6.3 Migration Script Design

```powershell
# ncx-migrate.ps1
param(
    [switch]$DryRun,
    [switch]$PreserveOld
)

# Step 1: Initialize v3 structure
Initialize-NeocortexV3

# Step 2: Migrate documents to chunks
$docs = Get-ChildItem ".mlda/docs" -Recurse -Filter "*.md"
foreach ($doc in $docs) {
    $sidecar = Get-Sidecar $doc
    $chunks = Convert-ToChunks $doc $sidecar

    foreach ($chunk in $chunks) {
        $chunk.embedding = Get-Embedding $chunk.content
        Save-Chunk $chunk
    }
}

# Step 3: Migrate learnings to memories
$learnings = Get-ChildItem ".mlda/topics" -Recurse -Filter "learning.yaml"
foreach ($learning in $learnings) {
    $entries = Parse-LearningYaml $learning

    foreach ($entry in $entries) {
        $memory = Convert-ToMemory $entry
        $memory.embedding = Get-Embedding $memory.content
        $memory.related = Find-SimilarMemories $memory.embedding
        Save-Memory $memory
    }
}

# Step 4: Build indices
Build-ChunkIndex
Build-MemoryIndex

# Step 5: Update mode files (interactive)
Update-ModeFiles -Interactive

# Step 6: Validate migration
Test-Migration

if (-not $PreserveOld) {
    # Archive old structure
    Move-Item ".mlda" ".mlda.archive"
}
```

### 6.4 Rollback Strategy

If v3 proves problematic:

1. **Keep .mlda.archive** - Original structure preserved
2. **Rename folders to switch** - Remove `.neocortex/`, restore `.mlda/` from archive
3. **Gradual rollout** - Test on one project before others

```powershell
# Rollback to v2
Remove-Item -Recurse .neocortex/
Move-Item .mlda.archive/ .mlda/
```

---

## 7. Coexistence Strategy

### 7.1 Project-Level Versioning

Different projects can use different versions:

```
Project A (Ways of Development)/
├── .neocortex/              # Uses v3
└── CLAUDE.md                # References v3 protocol

Project B (Tasks App)/
├── .mlda/                   # Uses v2
└── CLAUDE.md                # References v2 protocol
```

### 7.2 Detection Logic

Mode files detect which version to use via natural language instructions:

```markdown
<!-- In mode file (.claude/commands/modes/analyst.md) -->

## Neocortex Protocol

**Version Detection:**
- If `.neocortex/` folder exists → Use v3 protocol (below)
- If `.mlda/` folder exists → Use v2 protocol (MLDA)
- If neither exists → Neocortex not initialized

### V3 Protocol

(v3 activation and task start instructions here)

### V2 Protocol (Legacy)

(existing MLDA protocol here)
```

**Detection Script** (for tooling, not loaded into LLM):

```python
# Detection logic - runs in scripts, not in context
def detect_neocortex_version():
    if is_dir(".neocortex"):
        return "v3"
    elif is_dir(".mlda"):
        return "v2"
    else:
        return None
```

### 7.3 Shared Components

Some components remain shared between versions:

| Component | Shared? | Notes |
|-----------|---------|-------|
| CLAUDE.md (global) | Yes | Version-agnostic rules |
| CLAUDE.md (project) | Partially | Protocol section differs |
| Beads integration | Yes | Works with both |
| Mode personas | Yes | Same personas, different loading |
| Skill logic | Partially | Context gathering differs |

### 7.4 Transition Path for Existing Projects

For projects like Tasks App, you have three options:

**Option A: Stay on v2**
- No changes needed
- Continue using .mlda/
- Works until you hit scaling limits

**Option B: Migrate to v3**
- Run migration script
- Test thoroughly
- Remove old structure

**Option C: Hybrid (not recommended)**
- Keep both structures
- More complexity
- Higher maintenance

**Recommendation:** Stay on v2 for existing projects until v3 is proven stable in Ways of Development. Then migrate one project at a time.

---

## 8. Risk Assessment

### 8.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Embedding API costs | Medium | Medium | Use local embeddings for development |
| Retrieval quality < current | Medium | High | Extensive testing, tuning |
| Index corruption | Low | High | Backup, rebuild capability |
| Performance too slow | Medium | Medium | Caching, optimization |
| Chunking loses context | Medium | Medium | Overlap, semantic boundaries |

### 8.2 Process Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Migration data loss | Low | High | Dry run, preserve archive |
| Learning curve | Medium | Medium | Documentation, gradual rollout |
| Breaking existing workflows | Medium | High | Version coexistence |
| Scope creep | High | Medium | Strict phase boundaries |

### 8.3 Adoption Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Doesn't improve context usage | Low | High | Measure before/after |
| More complex than v2 | Medium | Medium | Better tooling, automation |
| External dependency (embeddings) | Medium | Medium | Local embedding fallback |

---

## 9. Open Questions

### 9.1 Technical Decisions Needed

1. **Embedding Provider** ✅ DECIDED
   - **Decision:** Local `e5-small-v2` via sentence-transformers
   - **Rationale:** Free, designed for retrieval, 512 token max fits chunk size
   - **Setup:** Handled by `ncx-init` script during implementation

2. **Vector Index Technology** ✅ DECIDED
   - **Decision:** NumPy + pickle (brute-force cosine similarity)
   - **Rationale:** At <500 chunks, brute-force is <1ms. Zero additional dependencies.
   - **Upgrade path:** Can migrate to FAISS/Annoy later if needed

3. **Chunk Size** ✅ DECIDED
   - **Decision:** 500 tokens max, 50 token overlap
   - **Rationale:** Matches e5-small-v2 max input (512), balanced granularity

4. **Memory Extraction Automation** ✅ DECIDED
   - **Decision:** Hybrid with confidence threshold
   - **High confidence** (verified fixes, explicit "remember this") → auto-save
   - **Medium/low confidence** → propose for user approval
   - **User can:** approve all, reject all, or select individually

### 9.2 Process Decisions Needed

1. **Migration Timing**
   - Migrate Ways of Development first, then wait?
   - Parallel development in both systems?
   - Full commitment to v3?

2. **Backward Compatibility**
   - How long to support v2?
   - Can external agents still use v2 consumer protocol?

3. **Documentation**
   - Where does v3 documentation live?
   - How to communicate changes to future projects?

### 9.3 Validation Criteria

How do we know v3 is successful?

| Metric | Target | Measurement |
|--------|--------|-------------|
| Initial context consumption | < 10% | Token count at task start |
| Retrieval relevance | >= 80% | Manual evaluation of top-5 |
| Memory usefulness | >= 70% | User feedback on suggestions |
| Assembly time | < 2 seconds | Benchmark |
| Migration success | 100% | All content accessible |

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| **Chunk** | Atomic unit of knowledge (~300-500 tokens) |
| **Chunk Store** | Collection of all chunks with embeddings |
| **Context Frame** | Position-optimized assembled context |
| **Embedding** | Vector representation of text for similarity |
| **Memory** | Atomic experiential/factual/procedural learning |
| **Memory Store** | Collection of all memories with embeddings |
| **Primacy Zone** | First 15% of context (high attention) |
| **Recency Zone** | Last 15% of context (high attention) |
| **Retrieval** | Finding relevant chunks/memories via similarity |
| **Semantic Similarity** | Cosine distance between embeddings |

---

## Appendix B: File Structure Reference

```
.neocortex/
├── chunks/
│   ├── AUTH/
│   │   ├── AUTH-001-001.md        # Chunk content (Markdown with frontmatter)
│   │   ├── AUTH-001-001.emb       # Chunk embedding (binary)
│   │   ├── AUTH-001-002.md
│   │   └── ...
│   ├── UI/
│   └── ...
├── memories/
│   ├── MEM-2026-01-20-001.md      # Memory content (Markdown with frontmatter)
│   ├── MEM-2026-01-20-001.emb     # Memory embedding (binary)
│   └── ...
├── index/
│   ├── chunks.pkl                 # Chunk embeddings (numpy array, pickled)
│   ├── chunks.meta.json           # Chunk ID → metadata mapping
│   ├── memories.pkl               # Memory embeddings (numpy array, pickled)
│   └── memories.meta.json         # Memory ID → metadata mapping
├── scripts/
│   ├── ncx-init.ps1
│   ├── ncx-chunk.ps1
│   ├── ncx-index.ps1
│   ├── ncx-retrieve.ps1
│   ├── ncx-assemble.ps1
│   ├── ncx-memory.ps1
│   └── ncx-migrate.ps1
└── cache/
    └── embeddings/                # Cached embeddings
```

**Format Rationale:**
| File Type | Format | Reason |
|-----------|--------|--------|
| Chunks | `.md` | LLM-friendly content, 2-5% degradation vs 8-12% for YAML |
| Memories | `.md` | Same - natural language content with minimal frontmatter |
| Index metadata | `.json` | Fast parsing for lookups, never loaded into LLM context |
| Embeddings | `.emb` | Binary vectors, not text |

**Configuration:** No config file needed. Version detected by folder existence (`.neocortex/` = v3). Runtime settings via environment variables (see Appendix D).

---

## Appendix C: Example Context Frame

```markdown
<!-- CONTEXT FRAME: Implement Token Refresh -->
<!-- Generated: 2026-01-26T10:30:00Z -->
<!-- Token Budget: 15,000 / Used: 12,847 -->

## CRITICAL: Task Definition

**Task ID:** TASK-AUTH-005
**Title:** Implement token refresh in OAuth settings

**Acceptance Criteria:**
- Silent refresh on 401 responses
- Refresh token stored in httpOnly cookie
- User experiences no interruption
- Works with all OAuth providers (Google, GitHub)

**Blockers:** None
**Related Docs:** DOC-AUTH-001, DOC-SEC-001

---

## Relevant Knowledge

### Token Refresh Logic (DOC-AUTH-001, section 3)
Token refresh uses silent refresh pattern. Access tokens expire after 15 minutes.
Refresh tokens stored in httpOnly cookies with SameSite=Strict.
On 401 response, automatically attempt refresh before retry.
Maximum 3 refresh attempts before forcing re-authentication.

### Security Requirements (DOC-SEC-001, section 2)
All tokens must use RS256 signing algorithm.
Never expose refresh tokens to JavaScript (httpOnly required).
Implement CSRF protection on token endpoints.
Log all token refresh events for audit.

### OAuth Provider Specifics (DOC-AUTH-003, section 4)
Google: refresh_token only issued on first consent, store permanently.
GitHub: tokens don't expire but can be revoked, check on each use.
Custom: follows standard OAuth 2.0 refresh flow.

---

## Past Learnings

- **MEM-2026-01-20-001** (high confidence): FormField wrapper required for
  PasswordInput component - label prop alone doesn't work.

- **MEM-2026-01-18-003** (high confidence): Settings components in
  src/components/settings/ - LinkedAccounts shows/manages auth methods.

- **MEM-2026-01-22-001** (medium confidence): Always test with expired token
  scenario - use browser dev tools to manually expire tokens.

---

## Current State

**Phase:** Development
**Epic:** Authentication System (EPIC-AUTH)
**Sprint:** 2026-W04

**Recent Activity:**
- 2026-01-25: OAuth provider selection UI completed
- 2026-01-24: Token storage mechanism finalized (httpOnly cookies)
- 2026-01-23: Security review passed for token handling

**Beads Status:**
- TASK-AUTH-004: completed (OAuth UI)
- TASK-AUTH-005: in_progress (this task)
- TASK-AUTH-006: pending (blocked by this)

---

## Instructions

Implement the token refresh mechanism following the security requirements above.
Focus on:
1. Interceptor for 401 responses
2. Silent refresh logic with retry limit
3. Cookie handling (httpOnly, SameSite=Strict)
4. Provider-specific handling (Google vs GitHub vs Custom)

Test with manually expired tokens using browser dev tools.
Update LinkedAccounts component to show refresh status if needed.
```

---

## Appendix D: Environment Variables

Configuration is handled via environment variables instead of config files:

| Variable | Default | Description |
|----------|---------|-------------|
| `NCX_EMBEDDING_MODEL` | `intfloat/e5-small-v2` | Local embedding model (sentence-transformers) |
| `NCX_CHUNK_SIZE` | `500` | Maximum tokens per chunk |
| `NCX_CHUNK_OVERLAP` | `50` | Token overlap between chunks |
| `NCX_RETRIEVAL_TOP_K` | `10` | Default number of chunks to retrieve |
| `NCX_MEMORY_TOP_K` | `5` | Default number of memories to retrieve |
| `NCX_TOKEN_BUDGET` | `15000` | Token budget for context frame |

**Why environment variables?**
- No config file to maintain
- Works with CI/CD and containerization
- Can be overridden per-session
- Secrets (API keys) stay out of repo

**Example setup (PowerShell):**
```powershell
# Usually no setup needed - defaults work out of the box
# Override only if needed:
$env:NCX_CHUNK_SIZE = 400  # Smaller chunks if desired
```

**Example setup (Bash):**
```bash
# Usually no setup needed - defaults work out of the box
# Override only if needed:
export NCX_CHUNK_SIZE=400  # Smaller chunks if desired
```

**Note:** The local embedding model (`e5-small-v2`) requires no API key. It downloads automatically on first use (~130MB).

---

*Document generated: 2026-01-26*
*Neocortex v3 Proposal - Draft for Review*
