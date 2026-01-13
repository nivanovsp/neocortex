# Phase 2: Rapid Ideation - Solution Generation

**Document ID:** DOC-WOD-002
**Version:** 1.0
**Created:** 2026-01-12
**Created By:** Mary (Business Analyst)

---

## Related Documents

- [DOC-WOD-001: Phase 1 Problem Analysis](Phase1-Problem-Analysis.md)

---

## Executive Summary

This document captures all solution ideas generated during brainstorming for the Modular Linked Documentation Architecture. Ideas are organized by category, with prioritized selections marked.

---

## Prioritized Ideas (Selected for Implementation)

The following 11 idea categories were selected as high-value:

### Category 1: Document Templates ⭐
- Standardized frontmatter schema for all doc types
- Minimal templates (BA, Arch, PRD variants)
- Auto-generated related docs section

### Category 2: Registry Automation ⭐
- Script that scans docs and builds/updates `doc-registry.yaml`
- CI hook that validates links on commit
- Orphan document detection (docs not in registry)

### Category 3: Workflow Integration ⭐
- Beads → Document mapping (each bead = one doc)
- Agent prompts that enforce linking behavior
- Pre-session context loader (reads Project Brief + registry)

### Category 4: Update Propagation ⭐
- Dependency graph visualization
- "Impact analysis" command before changes
- Changelog aggregation across related docs

### Category 5: Developer Experience ⭐
- Topic-specific "context bundles" (auto-assembled from registry)
- Quick reference cards (summary + links only)
- Search CLI for doc discovery

### Category 6: AI Context Optimization ⭐
- **Context budgeting** - Each doc includes a "token count" estimate; agents know what fits in context
- **Summary tiers** - Every doc has 3 summaries: one-liner, paragraph, full (agents pick based on need)
- **Semantic chunking** - Documents structured so sections can be loaded independently
- **Pre-compiled context packs** - For common workflows, pre-assembled doc bundles ready to inject

### Category 7: Decision Tracking ⭐
- **Decision Log document type** - Dedicated docs for key decisions with: context, options considered, rationale, date, stakeholders
- **Decision references** - Requirements link to decisions that shaped them
- **Decision review triggers** - Flag decisions older than X months for re-evaluation

### Category 9: Cross-Project Learning ⭐
- **Pattern library** - Reusable patterns extracted from multiple modules (e.g., "standard RBAC pattern")
- **Anti-pattern registry** - Document what NOT to do, with links to why
- **Module comparison** - "How did we solve X in Module A vs Module B?"

### Category 12: Recovery & Maintenance ⭐
- **Broken link repair** - When a doc is renamed, auto-update all references
- **Archive protocol** - How to deprecate docs without breaking links (tombstone pattern)
- **Merge protocol** - How to combine docs if granularity was too fine
- **Split protocol** - How to divide docs if they grew too large

### Category 13: Session Management ⭐
- **Session manifest** - Each working session produces a manifest: what was discussed, docs created/modified, decisions made
- **Session replay** - New agent can "replay" session manifest to understand history
- **Cross-session continuity** - Link sessions to Beads items for full traceability

### Category 15: Template Evolution ⭐
- **Template versioning** - Templates evolve; docs note which template version they used
- **Migration guides** - When templates change, guide for updating old docs
- **Custom sections** - Allow module-specific sections without breaking standard structure

---

## Ideas for Future Consideration (Not Prioritized)

### Category 8: Quality Gates
- Link validation - Automated check that all DOC-IDs resolve to real documents
- Staleness detection - Flag docs not updated in X days while related docs changed
- Coverage reports - Which Beads items lack documentation?
- Consistency checker - Detect contradictions between related docs (AI-assisted)

### Category 10: Collaboration & Handoff
- Agent handoff protocol - Structured format when BA hands to Architect, Architect to PM
- Context transfer doc - Auto-generated summary of "what happened in this phase"
- Open questions registry - Unresolved items tracked across phases, assigned to resolver

### Category 11: Visualization & Navigation
- Documentation map - Visual graph of all docs and their relationships
- Topic clustering - Auto-group related docs by semantic similarity
- Breadcrumb trails - "You are here" context showing doc's place in hierarchy
- Heat maps - Which docs are most referenced? Which are orphans?

### Category 14: Metrics & Insights
- Documentation velocity - Docs created/updated per phase
- Context efficiency - How many docs needed per development task?
- Rework tracking - How often do docs get revised? Why?
- Agent feedback loop - Agents flag when docs were insufficient (improves future docs)

---

## Meta-Themes Identified

| Theme | Description |
|-------|-------------|
| **Machine-Readable First** | Structure everything so agents can parse and navigate programmatically |
| **Traceability Everywhere** | Every artifact links to its origin, rationale, and dependents |
| **Self-Healing System** | Automation detects and helps fix inconsistencies |

---

## Change Log

| Version | Date | Author | Change Summary |
|---------|------|--------|----------------|
| 1.0 | 2026-01-12 | Mary (Business Analyst) | Initial creation with 15 idea categories, 11 prioritized |
