# Neocortex Architecture Overview

Visual representation of the Neocortex methodology's knowledge graph architecture.

---

## 1. The Neural Network Metaphor

```
                            ╔═══════════════════════════════════════════════════════════════╗
                            ║              NEOCORTEX KNOWLEDGE GRAPH                        ║
                            ║         "Documentation as Neural Network"                     ║
                            ╚═══════════════════════════════════════════════════════════════╝

    ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                                                             │
    │      ┌──────────┐                                              ┌──────────┐                │
    │      │ DOC-AUTH │◄═══════════════ depends-on ═════════════════►│ DOC-RBAC │                │
    │      │   -001   │                 (STRONG)                      │   -001   │                │
    │      │ ┌──────┐ │                                              │ ┌──────┐ │                │
    │      │ │NEURON│ │                                              │ │NEURON│ │                │
    │      │ └──────┘ │                                              │ └──────┘ │                │
    │      └────┬─────┘                                              └────┬─────┘                │
    │           │                                                         │                       │
    │           │ extends (MEDIUM)                                        │ references (WEAK)     │
    │           ▼                                                         ▼                       │
    │      ┌──────────┐                                              ┌──────────┐                │
    │      │ DOC-AUTH │───────────── references ────────────────────►│ DOC-SEC  │                │
    │      │   -002   │               (WEAK)                          │   -001   │                │
    │      │ ┌──────┐ │                                              │ ┌──────┐ │                │
    │      │ │NEURON│ │                                              │ │NEURON│ │                │
    │      │ └──────┘ │                                              │ └──────┘ │                │
    │      └────┬─────┘                                              └──────────┘                │
    │           │                                                                                 │
    │           │ extends (MEDIUM)                                                                │
    │           ▼                                                                                 │
    │      ┌──────────┐          supersedes           ┌──────────┐                               │
    │      │ DOC-AUTH │═══════════(REDIRECT)═════════►│ DOC-AUTH │  (deprecated)                 │
    │      │   -003   │                                │   -001v1 │                               │
    │      │ ┌──────┐ │                               │ ┌──────┐ │                               │
    │      │ │NEURON│ │                               │ │░░░░░░│ │                               │
    │      │ └──────┘ │                               │ └──────┘ │                               │
    │      └──────────┘                               └──────────┘                               │
    │                                                                                             │
    └─────────────────────────────────────────────────────────────────────────────────────────────┘

    ╔═════════════════════════════════════════════════════════════════════════════════════════════╗
    ║  LEGEND                                                                                     ║
    ╠═════════════════════════════════════════════════════════════════════════════════════════════╣
    ║  ┌──────────┐                                                                               ║
    ║  │ DOC-ID   │  = NEURON (Document)         ═══════  = STRONG signal (always follow)        ║
    ║  │          │    Unit of knowledge          ───────  = MEDIUM signal (follow if depth)     ║
    ║  │ ┌──────┐ │                               ·······  = WEAK signal (follow if relevant)    ║
    ║  │ │NEURON│ │                                                                               ║
    ║  │ └──────┘ │    DOC-ID = AXON             ═(REDIRECT)═ = Follow this instead              ║
    ║  └──────────┘    (unique identifier)                                                        ║
    ║                                                                                             ║
    ║  Relationships = DENDRITES (connections between documents)                                  ║
    ╚═════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Signal Flow (Context Gathering)

```
                    ╔════════════════════════════════════════════════════════════════╗
                    ║                    SIGNAL PROPAGATION                          ║
                    ║            "Agent reading = Signal activation"                 ║
                    ╚════════════════════════════════════════════════════════════════╝

    ENTRY POINT (Task/Story)
           │
           ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  PHASE 1: METADATA SCAN (Lightweight)                                           │
    │                                                                                 │
    │     ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐             │
    │     │.meta.yml│      │.meta.yml│      │.meta.yml│      │.meta.yml│             │
    │     │ ░░░░░░░ │      │ ░░░░░░░ │      │ ░░░░░░░ │      │ ░░░░░░░ │             │
    │     │ AUTH-001│      │ AUTH-002│      │ RBAC-001│      │ SEC-001 │             │
    │     └────┬────┘      └────┬────┘      └────┬────┘      └────┬────┘             │
    │          │                │                │                │                   │
    │          ▼                ▼                ▼                ▼                   │
    │     ┌─────────────────────────────────────────────────────────────┐             │
    │     │  Relevance Assessment: HIGH=3  MEDIUM=1  LOW=0  SKIP=1     │             │
    │     └─────────────────────────────────────────────────────────────┘             │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  PHASE 2: SELECTIVE FULL LOAD                                                   │
    │                                                                                 │
    │     HIGH RELEVANCE              MEDIUM RELEVANCE           LOW RELEVANCE        │
    │     (Full Document)             (Key Sections)             (Skip)               │
    │                                                                                 │
    │     ┌───────────────┐          ┌───────────────┐          ┌───────────────┐    │
    │     │ DOC-AUTH-001  │          │ DOC-RBAC-001  │          │ DOC-SEC-001   │    │
    │     │ ▓▓▓▓▓▓▓▓▓▓▓▓▓ │          │ ░░░▓▓▓▓░░░░░ │          │               │    │
    │     │ ▓▓▓▓▓▓▓▓▓▓▓▓▓ │          │ ░░░▓▓▓▓░░░░░ │          │    (skipped)  │    │
    │     │ ▓▓▓▓▓▓▓▓▓▓▓▓▓ │          │ ░░░░░░░░░░░░ │          │               │    │
    │     └───────────────┘          └───────────────┘          └───────────────┘    │
    │                                                                                 │
    │     ▓ = Loaded content          ░ = Skipped content                            │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  TRAVERSAL RULES                                                                │
    │                                                                                 │
    │     1. ═══ depends-on ═══  →  ALWAYS follow (cannot understand without)        │
    │     2. ─── extends ───     →  Follow if depth < limit                          │
    │     3. ··· references ···  →  Follow only if directly relevant                 │
    │     4. ═══ supersedes ═══  →  REDIRECT: follow this, ignore target             │
    │     5. ╳ STOP at domain boundaries (unless task requires crossing)             │
    │     6. ╳ NEVER traverse into isolated_from domains                             │
    │                                                                                 │
    └─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Token Budget Management

```
    ╔════════════════════════════════════════════════════════════════════════════════╗
    ║                         TOKEN BUDGET THRESHOLDS                                ║
    ╚════════════════════════════════════════════════════════════════════════════════╝

    0 tokens                                                              MAX
    │                                                                      │
    ├──────────────────┬────────────────────┬──────────────────────────────┤
    │   SAFE ZONE      │   SOFT THRESHOLD   │     HARD STOP               │
    │                  │   (35,000 tokens)  │     (50,000 tokens)         │
    │                  │   8 documents      │     12 documents            │
    │   Normal         │                    │                              │
    │   operation      │   ⚠ Self-assess:   │   🛑 MUST:                  │
    │                  │   • Can recall?    │   • Decompose to sub-agents │
    │                  │   • Re-reading?    │   • Or pause and clarify    │
    │                  │   • Vague?         │                              │
    │                  │   • Connections?   │                              │
    │                  │                    │                              │
    │                  │   If 2+ issues:    │                              │
    │                  │   → Decompose      │                              │
    │                  │                    │                              │
    ├──────────────────┴────────────────────┴──────────────────────────────┤
    │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░████████████████████████████│
    │ ◄─── 70% safe ───►◄── 20% caution ──►◄────── 10% danger ──────────►│
    └──────────────────────────────────────────────────────────────────────┘

    TASK-SPECIFIC OVERRIDES:
    ┌────────────────────┬───────────────┬─────────────┐
    │ Task Type          │ Soft          │ Hardstop    │
    ├────────────────────┼───────────────┼─────────────┤
    │ Research           │ 50,000        │ 70,000      │
    │ Document creation  │ 30,000        │ 45,000      │
    │ Review             │ 40,000        │ 55,000      │
    │ Architecture       │ 30,000        │ 45,000      │
    └────────────────────┴───────────────┴─────────────┘
```

---

## 4. Multi-Agent Decomposition

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                         MULTI-AGENT SCALING                                     ║
    ║              "When context exceeds thresholds, decompose"                       ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

                                    ┌─────────────────────┐
                                    │    PRIMARY AGENT    │
                                    │                     │
                                    │  • Coordinates work │
                                    │  • Synthesizes      │
                                    │  • Makes decisions  │
                                    └──────────┬──────────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │                          │                          │
                    ▼                          ▼                          ▼
    ┌───────────────────────┐  ┌───────────────────────┐  ┌───────────────────────┐
    │    SUB-AGENT 1        │  │    SUB-AGENT 2        │  │    SUB-AGENT 3        │
    │  Token Management     │  │  Session Handling     │  │  OAuth Integration    │
    │                       │  │                       │  │                       │
    │  ┌─────┐ ┌─────┐     │  │  ┌─────┐ ┌─────┐     │  │  ┌─────┐ ┌─────┐     │
    │  │AUTH │ │AUTH │     │  │  │AUTH │ │AUTH │     │  │  │AUTH │ │INT  │     │
    │  │-002 │ │-003 │     │  │  │-004 │ │-005 │     │  │  │-006 │ │-001 │     │
    │  └─────┘ └─────┘     │  │  └─────┘ └─────┘     │  │  └─────┘ └─────┘     │
    │  ┌─────┐ ┌─────┐     │  │  ┌─────┐             │  │  ┌─────┐ ┌─────┐     │
    │  │AUTH │ │SEC  │     │  │  │DATA │             │  │  │INT  │ │SEC  │     │
    │  │-007 │ │-002 │     │  │  │-001 │             │  │  │-002 │ │-003 │     │
    │  └─────┘ └─────┘     │  │  └─────┘             │  │  └─────┘ └─────┘     │
    │                       │  │                       │  │                       │
    │  4 docs / ~12k tokens │  │  3 docs / ~9k tokens  │  │  4 docs / ~11k tokens │
    └───────────┬───────────┘  └───────────┬───────────┘  └───────────┬───────────┘
                │                          │                          │
                └──────────────────────────┼──────────────────────────┘
                                           │
                                           ▼
                           ┌───────────────────────────────┐
                           │  STRUCTURED RETURN FORMAT     │
                           │                               │
                           │  • key_requirements[]         │
                           │  • critical_items[]           │
                           │  • dependencies_identified[]  │
                           │  • meta.confidence            │
                           │  • meta.uncertainty_flags[]   │
                           └───────────────────────────────┘
                                           │
                                           ▼
                           ┌───────────────────────────────┐
                           │  PRIMARY SYNTHESIZES          │
                           │                               │
                           │  Merges summaries with        │
                           │  provenance tracking          │
                           └───────────────────────────────┘
```

---

## 5. Verification Stack

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                         VERIFICATION STACK                                      ║
    ║              "Six layers ensuring nothing critical is missed"                   ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 6: VERIFICATION PASS (Optional)                                          │
    │  ────────────────────────────────────────                                       │
    │  Primary spot-checks suspicious absences                                        │
    │  "Why didn't sub-agent mention X? Let me verify..."                             │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 5: CROSS-VERIFICATION (Optional)                                         │
    │  ────────────────────────────────────────                                       │
    │  Two independent sub-agents compare outputs                                     │
    │  Enabled for: security, compliance domains                                      │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 4: PROVENANCE TRACKING (Mandatory)                                       │
    │  ────────────────────────────────────────                                       │
    │  Every claim traces to: doc_id + section + line                                 │
    │  Example: {doc: DOC-AUTH-002, section: "2.1", line: 47}                         │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 3: CONFIDENCE SELF-ASSESSMENT (Mandatory)                                │
    │  ────────────────────────────────────────                                       │
    │  Each sub-agent reports: high | medium | low confidence                         │
    │  Flags uncertainty and recommends primary review areas                          │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 2: CRITICAL MARKERS (Mandatory)                                          │
    │  ────────────────────────────────────────                                       │
    │  <!-- CRITICAL: compliance --> content <!-- /CRITICAL -->                       │
    │  ALWAYS extracted verbatim, never summarized                                    │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  LAYER 1: STRUCTURED EXTRACTION (Mandatory)                                     │
    │  ────────────────────────────────────────                                       │
    │  Template-driven extraction, NOT open summarization                             │
    │  Forces: requirements[], constraints[], dependencies[]                          │
    └─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Topic-Based Learning

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                         TOPIC-BASED LEARNING                                    ║
    ║              "Learning persists across sessions"                                ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

    SESSION WORKFLOW:
    ────────────────

    ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
    │   SESSION    │         │    TOPIC     │         │   SESSION    │
    │   STARTS     │────────►│  IDENTIFIED  │────────►│    WORK      │
    │              │         │              │         │              │
    │ (minimal     │         │ From task:   │         │ With topic   │
    │  context)    │         │ AUTH, API,   │         │ context      │
    │              │         │ etc.         │         │ loaded       │
    └──────────────┘         └──────────────┘         └──────┬───────┘
                                                             │
                                    ┌────────────────────────┘
                                    │
                                    ▼
                             ┌──────────────┐         ┌──────────────┐
                             │   SESSION    │         │   LEARNING   │
                             │    ENDS      │────────►│    SAVED     │
                             │              │         │              │
                             │ Agent        │         │ To topic     │
                             │ proposes     │         │ file         │
                             │ learnings    │         │              │
                             └──────────────┘         └──────────────┘


    TOPIC FILE STRUCTURE:
    ─────────────────────

    .mlda/topics/authentication/
    │
    ├── domain.yaml                 ◄── Sub-domain structure
    │   ┌────────────────────────────────────────┐
    │   │ topic: authentication                   │
    │   │ sub_domains:                            │
    │   │   - token-management                    │
    │   │   - session-handling                    │
    │   │   - oauth-integration                   │
    │   │ entry_points:                           │
    │   │   - DOC-AUTH-001                        │
    │   │ decomposition_strategy: by-subdomain   │
    │   └────────────────────────────────────────┘
    │
    └── learning.yaml               ◄── Accumulated learnings
        ┌────────────────────────────────────────┐
        │ groupings:                              │
        │   - name: token-management              │
        │     docs: [DOC-AUTH-002, DOC-AUTH-003] │
        │     confidence: high                    │
        │                                         │
        │ activations:                            │
        │   - docs: [DOC-AUTH-001, DOC-AUTH-002] │
        │     frequency: 7                        │
        │     typical_tasks: [implementing]       │
        │                                         │
        │ verification_notes:                     │
        │   - session: 2026-01-15                 │
        │     caught: "PCI-DSS in AUTH-003"       │
        │     lesson: "Check compliance markers"  │
        └────────────────────────────────────────┘


    CROSS-SESSION BENEFIT:
    ──────────────────────

    Session 1                Session 5                Session 12
    ─────────                ─────────                ──────────
    ┌─────────┐              ┌─────────┐              ┌─────────┐
    │ Learn:  │              │ Learn:  │              │ BENEFIT │
    │ AUTH-001│───save──────►│ AUTH-003│───save──────►│         │
    │ +AUTH-002│             │ +SEC-002 │              │ Agent   │
    │ often   │              │ related │              │ knows:  │
    │ together│              │         │              │ • Groups│
    └─────────┘              └─────────┘              │ • Freq  │
                                                      │ • Notes │
                                                      └─────────┘
```

---

## 7. Two-Tier Learning System (DEC-007)

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                         TWO-TIER LEARNING SYSTEM                                ║
    ║              "Load lightweight index first, full learning on-demand"            ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

    MODE AWAKENING (Tier 1 - Always loaded)
    ────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  .mlda/learning-index.yaml  (~5-10 KB)                                          │
    │                                                                                 │
    │  ┌─────────────────────────────────────────────────────────────────────────┐   │
    │  │  topics:                                                                 │   │
    │  │    authentication:                                                       │   │
    │  │      sessions: 12                                                        │   │
    │  │      last_updated: 2026-01-20                                            │   │
    │  │      top_insights:                                                       │   │
    │  │        - "Token docs require compliance marker check"                    │   │
    │  │        - "AUTH-001 + AUTH-002 always load together"                      │   │
    │  │    api-design:                                                           │   │
    │  │      sessions: 8                                                         │   │
    │  │      top_insights:                                                       │   │
    │  │        - "REST patterns in API-001 are canonical"                        │   │
    │  └─────────────────────────────────────────────────────────────────────────┘   │
    │                                                                                 │
    │  Agent "knows what exists" without loading 60+ KB per topic                     │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           │  Topic detected from task/DOC-ID
                                           ▼
    TOPIC DETECTION (Tier 2 - On-demand)
    ────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  .mlda/topics/authentication/learning.yaml  (full file)                         │
    │                                                                                 │
    │  ┌─────────────────────────────────────────────────────────────────────────┐   │
    │  │  topic: authentication                                                   │   │
    │  │  version: 3                                                              │   │
    │  │  sessions_contributed: 12                                                │   │
    │  │                                                                          │   │
    │  │  groupings:                                                              │   │
    │  │    - name: token-management                                              │   │
    │  │      docs: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007]                   │   │
    │  │    - name: session-handling                                              │   │
    │  │      docs: [DOC-AUTH-004, DOC-AUTH-005]                                 │   │
    │  │                                                                          │   │
    │  │  activations:                                                            │   │
    │  │    - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]                    │   │
    │  │      frequency: 7                                                        │   │
    │  │                                                                          │   │
    │  │  verification_notes:                                                     │   │
    │  │    - caught: "PCI-DSS requirement"                                       │   │
    │  │      lesson: "Check compliance markers in token docs"                    │   │
    │  └─────────────────────────────────────────────────────────────────────────┘   │
    │                                                                                 │
    │  Full depth available for current work                                          │
    └─────────────────────────────────────────────────────────────────────────────────┘

    AUTO-REGENERATION (DEC-008):
    ────────────────────────────
    When *learning save executes → learning-index.yaml auto-regenerates
```

---

## 8. Activation Protocol (DEC-009)

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                         ACTIVATION CONTEXT OPTIMIZATION                         ║
    ║              "Single pre-computed file for mode awakening"                      ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

    BEFORE DEC-009 (~2100 lines loaded on mode awakening)
    ──────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  Mode awakens → Read 4+ files sequentially:                                     │
    │                                                                                 │
    │     ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐         │
    │     │ docs/handoff.md  │   │ .mlda/registry   │   │ learning-index   │         │
    │     │   (~800 lines)   │   │  (~500 lines)    │   │  (~300 lines)    │         │
    │     └────────┬─────────┘   └────────┬─────────┘   └────────┬─────────┘         │
    │              │                      │                      │                    │
    │              └──────────────────────┼──────────────────────┘                    │
    │                                     │                                           │
    │                                     ▼                                           │
    │                            36% context consumed                                 │
    │                            before any real work!                                │
    └─────────────────────────────────────────────────────────────────────────────────┘


    AFTER DEC-009 (~50-80 lines loaded on mode awakening)
    ──────────────────────────────────────────────────────

    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  Mode awakens → Read 1 pre-computed file:                                       │
    │                                                                                 │
    │     ┌───────────────────────────────────────────────────────────────────────┐  │
    │     │  .mlda/activation-context.yaml  (~50-80 lines)                        │  │
    │     │                                                                       │  │
    │     │  mlda:                                                                │  │
    │     │    status: initialized                                                │  │
    │     │    doc_count: 47                                                      │  │
    │     │    domains: [API, AUTH, SEC, DATA]                                    │  │
    │     │                                                                       │  │
    │     │  handoff:                                                             │  │
    │     │    current_phase: development                                         │  │
    │     │    ready_items: [STORY-AUTH-001, STORY-UI-003]                        │  │
    │     │    open_questions: 2                                                  │  │
    │     │                                                                       │  │
    │     │  learning:                                                            │  │
    │     │    topics_total: 11                                                   │  │
    │     │    sessions_total: 41                                                 │  │
    │     │    highlights:                                                        │  │
    │     │      - "Token compliance markers critical"                            │  │
    │     └───────────────────────────────────────────────────────────────────────┘  │
    │                                                                                 │
    │                            ~97% context reduction!                              │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           │  Deep context ON-DEMAND only
                                           ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │  DEEP CONTEXT (loaded when actively needed)                                     │
    │                                                                                 │
    │     Full handoff.md      Full registry.yaml      Full topic/learning.yaml      │
    │     (for phase details)  (for DOC-ID lookup)     (for topic work)              │
    │                                                                                 │
    └─────────────────────────────────────────────────────────────────────────────────┘


    AUTO-REGENERATION TRIGGERS:
    ───────────────────────────

    ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
    │ *learning save  │────►│ learning-index  │────►│ activation-     │
    │                 │     │ regenerates     │     │ context         │
    └─────────────────┘     │ (DEC-008)       │     │ regenerates     │
                            └─────────────────┘     │ (DEC-009)       │
    ┌─────────────────┐                             │                 │
    │ *handoff        │────────────────────────────►│                 │
    └─────────────────┘                             └─────────────────┘
    ┌─────────────────┐                                      ▲
    │ Registry update │──────────────────────────────────────┘
    └─────────────────┘
```

---

## 9. Complete System Flow

```
    ╔═════════════════════════════════════════════════════════════════════════════════╗
    ║                    COMPLETE NEOCORTEX FLOW (with DEC-009)                       ║
    ╚═════════════════════════════════════════════════════════════════════════════════╝

                                    ┌───────────────┐
                                    │  /modes:dev   │
                                    │  (or any mode)│
                                    └───────┬───────┘
                                            │
                                            ▼
                                    ┌───────────────────────────┐
                                    │ STEP 1: Load Activation   │
                                    │ Context (DEC-009)         │
                                    │                           │
                                    │ .mlda/activation-context  │
                                    │ (~50-80 lines)            │
                                    └───────────┬───────────────┘
                                                │
                                                ▼
                                    ┌───────────────────────────┐
                                    │ Agent now knows:          │
                                    │ • MLDA status (47 docs)   │
                                    │ • Current phase (dev)     │
                                    │ • Ready items (3 stories) │
                                    │ • Learning highlights     │
                                    └───────────┬───────────────┘
                                                │
                                                ▼
                                    ┌───────────────┐
                                    │  bd ready     │
                                    │  (User picks  │
                                    │   a task)     │
                                    └───────┬───────┘
                                            │
                                            ▼
                                    ┌───────────────┐
                                    │ Identify Topic│
                                    │ from task     │
                                    │ DOC-ID/domain │
                                    └───────┬───────┘
                                            │
                                            ▼
                                    ┌───────────────────────────┐
                                    │ STEP 2: Load Full Topic   │
                                    │ Learning (Tier 2)         │
                                    │                           │
                                    │ .mlda/topics/{topic}/     │
                                    │ learning.yaml             │
                                    └───────────┬───────────────┘
                                                │
                                                ▼
                                    ┌───────────────────────────┐
                                    │  GATHER CONTEXT           │
                                    │  /skills:gather-context   │
                                    │                           │
                                    │  Phase 1: Metadata scan   │
                                    │  Phase 2: Selective load  │
                                    └───────────┬───────────────┘
                                                │
                              ┌─────────────────┴─────────────────┐
                              │                                   │
                        Under threshold?                    Over threshold?
                              │                                   │
                              ▼                                   ▼
                    ┌─────────────────┐                 ┌─────────────────┐
                    │ SINGLE AGENT    │                 │ MULTI-AGENT     │
                    │ PROCESSING      │                 │ DECOMPOSITION   │
                    │                 │                 │                 │
                    │ Work on task    │                 │ Spawn sub-agents│
                    │ with full       │                 │ per sub-domain  │
                    │ context         │                 │                 │
                    └────────┬────────┘                 └────────┬────────┘
                             │                                   │
                             │         ┌─────────────────────────┘
                             │         │
                             │         ▼
                             │  ┌─────────────────┐
                             │  │ VERIFICATION    │
                             │  │ STACK           │
                             │  │                 │
                             │  │ 6 layers ensure │
                             │  │ nothing missed  │
                             │  └────────┬────────┘
                             │           │
                             └─────┬─────┘
                                   │
                                   ▼
                            ┌───────────────┐
                            │ WORK ON TASK  │
                            │               │
                            │ With verified │
                            │ context       │
                            └───────┬───────┘
                                    │
                                    ▼
                            ┌───────────────┐
                            │ SESSION END   │
                            │               │
                            │ Propose       │
                            │ learnings     │
                            └───────┬───────┘
                                    │
                                    ▼
                            ┌───────────────┐
                            │ SAVE LEARNING │
                            │               │
                            │ To topic/     │
                            │ learning.yaml │
                            └───────────────┘
```

---

## Key Takeaways

| Concept | Implementation |
|---------|----------------|
| **Documents = Neurons** | `.md` files with `.meta.yaml` sidecars |
| **Relationships = Dendrites** | `related:` section in sidecars with `type` and `why` |
| **DOC-IDs = Axons** | `DOC-{DOMAIN}-{NNN}` format enables connections |
| **Signal = Agent reading** | Context gathering via `/skills:gather-context` |
| **Propagation = Following links** | Traversal rules based on relationship type |
| **Learning = Topic files** | `.mlda/topics/{topic}/learning.yaml` |
| **Two-Tier Learning** | Index first (Tier 1), full topic on-demand (Tier 2) |
| **Activation Context** | Pre-computed `.mlda/activation-context.yaml` for mode awakening |
| **Scaling = Sub-agents** | Decompose when context exceeds thresholds |
| **Safety = Verification stack** | 6 layers ensure critical info preserved |

---

*Neocortex Architecture Diagrams v2.1*
