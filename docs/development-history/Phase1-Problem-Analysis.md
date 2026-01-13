# Phase 1: Problem-First Analysis

**Document ID:** DOC-WOD-001
**Version:** 1.0
**Created:** 2026-01-12
**Created By:** Mary (Business Analyst)

---

## Executive Summary

This document captures the pain points and initial requirements for improving the documentation and AI context management workflow within Dominaite's development process.

---

## Current Workflow

### Phases

| Phase | Actor | Activities |
|-------|-------|------------|
| 1 | Business Analyst | Multiple sessions → Generate docs → Comprehensive analysis → Project Brief |
| 2 | Architect | Review BA docs → Architecture sessions → Comprehensive architecture doc |
| 3 | Project Manager | Review all docs → PRD creation (multiple sessions) → Comprehensive PRD |
| 4 | Development | Agentic development based on PRD |

### Context
- BMAD methodology is used across all phases
- Beads is used for issue/task tracking
- Solutions architect pre-defines tech stack (backend/frontend language, environment)
- Epics/stories/tasks are excluded from PRD; created during development

---

## Pain Points Identified

### P1: Monolithic Documents
**Problem:** Comprehensive documents are too large for AI agents to effectively retain context.
**Impact:** Loss of nuance, incomplete understanding, repeated explanations.

### P2: Repeated Discussions
**Problem:** Same topics are discussed multiple times across sessions without reference to prior decisions.
**Impact:** Inconsistent results, wasted time, potential contradictions between documents.

### P3: No Inter-Document Relations
**Problem:** Documents exist in isolation; no links between related topics.
**Impact:** Context fragmentation; e.g., onboarding discusses access control but doesn't link to user management docs.

### P4: PRD-Only Development Context
**Problem:** Developers rely solely on PRD, which lacks full analytical and architectural context.
**Impact:** Unexpected implementations, decisions made without full understanding.

### P5: Unnecessary Sections
**Problem:** Standard templates include sections not relevant to Dominaite's workflow.
**Impact:** Document bloat, noise obscures important information.

---

## Proposed Solution: Modular Linked Documentation Architecture

### Core Principles

1. **Modularity** - Smaller, focused documents instead of monolithic ones
2. **Linkability** - Cross-references between related documents via Document IDs
3. **Single Source of Truth** - Project Brief serves as master index
4. **Traceability** - All changes versioned with agent name, date, and reason
5. **Living Documentation** - Updates propagate across related documents

### Document Structure

```
PROJECT BRIEF (Source of Truth / Master Index)
    │
    ├── Business Analysis Documents (modular)
    │       └── Cross-linked by topic
    │
    ├── Architecture Documents (modular)
    │       └── Cross-linked to BA docs + each other
    │
    └── PRD Documents (modular, per topic/section)
            └── Links to BA + Architecture for full context
```

### Key Decisions

| Decision | Specification |
|----------|---------------|
| Document Naming | Fixed name and location; never changes |
| Versioning | Versions tracked within document; name/location stable |
| Link Format | Document IDs (e.g., DOC-AUTH-001) |
| Granularity | Determined per session; maps to Beads tracker items |
| Update Process | Agent proposes → Human approves → Agent updates with version info |
| Version Metadata | Agent name, date, reason for change, summary of change |

---

## Document Discovery System

### Layer 1: Document Registry (doc-registry.yaml)
Machine-readable index containing:
- Document ID
- Title
- File path
- Category
- Tags (for semantic discovery)
- Summary
- Related document IDs

### Layer 2: Project Brief
Human-readable narrative overview with curated links to key documents per topic.

### Layer 3: In-Document Metadata
Each document includes YAML frontmatter:
```yaml
---
id: DOC-XXX-NNN
version: X.Y
last_updated: YYYY-MM-DD
updated_by: [Agent Name]
change_reason: [Why this version exists]
change_summary: [What changed]
related_docs:
  - DOC-XXX-NNN: Description
---
```

### Discovery Flow for Agents
1. Receive Project Brief → understand scope
2. Query doc-registry.yaml for relevant tags/categories
3. Read specific documents + follow related_docs links
4. Full context achieved without loading all documents

---

## Open Questions for Further Phases

1. What template structure should modular documents follow?
2. How should the doc-registry.yaml be maintained (manual vs auto-generated)?
3. What tooling/automation can support update propagation?
4. How do we handle conflicts when multiple agents update related docs?

---

## Related Documents

*None yet - this is the first document in the Ways of Development initiative.*

---

## Change Log

| Version | Date | Author | Change Summary |
|---------|------|--------|----------------|
| 1.0 | 2026-01-12 | Mary (Business Analyst) | Initial creation |
