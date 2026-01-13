# Phase 4: SCAMPER - Systematic Innovation

**Document ID:** DOC-WOD-004
**Version:** 1.0
**Created:** 2026-01-12
**Created By:** Mary (Business Analyst)

---

## Related Documents

- [DOC-WOD-001: Phase 1 Problem Analysis](Phase1-Problem-Analysis.md)
- [DOC-WOD-002: Phase 2 Rapid Ideation](Phase2-Rapid-Ideation.md)
- [DOC-WOD-003: Phase 3 Six Thinking Hats](Phase3-Six-Thinking-Hats.md)

---

## Executive Summary

This document applies the SCAMPER innovation technique to stress-test and enhance our modular documentation solution. Key innovations identified include auto-generated Project Brief, Beads-to-doc scaffolding, and reverse reference tracking.

---

## SCAMPER Analysis

### S - Substitute

| Current Idea | Substitute With | Benefit | Decision |
|--------------|-----------------|---------|----------|
| Manual DOC-IDs | Auto-generated UUIDs | No conflicts | **REJECTED** - Keep manual IDs for readability |
| Markdown frontmatter | Separate `.meta.yaml` sidecar files | Cleaner docs, easier parsing | **ACCEPTED** |
| Human-written summaries | AI-generated + human-approved | Faster, consistent | **MODIFIED** - Hybrid approach |
| File-based registry | Git-tracked SQLite | Better queries | Deferred |
| Session manifests as docs | Beads annotations | Less duplication | Consider |

**Final Decisions:**
- Manual DOC-IDs with convention: `DOC-{DOMAIN}-{NNN}`
- Sidecar `.meta.yaml` files for metadata
- Hybrid summaries: AI-generated one-liner/paragraph, human-written full summary

---

### C - Combine

| Combine | With | Result | Decision |
|---------|------|--------|----------|
| Decision Log | Session Manifest | Decisions in context | **ACCEPTED** |
| Pattern Library | Anti-Pattern Registry | Single Patterns doc with DO/DON'T | **ACCEPTED** |
| doc-registry.yaml | Project Brief | Single source | **REJECTED** - Keep separate |
| Context budgeting | Summary tiers | Unified weight system | **ACCEPTED** |
| Beads tracker | Doc generation | Auto-scaffold docs | **ACCEPTED** |

**Final Decisions:**
- Keep doc-registry.yaml separate from Project Brief
- Beads creates doc scaffolds automatically
- Decision logs embedded in session manifests

---

### A - Adapt

| Source Domain | Concept | Adaptation |
|---------------|---------|------------|
| Wikipedia | Disambiguation pages | Index pages for ambiguous terms |
| API Documentation | OpenAPI/Swagger | Machine-readable doc specs |
| Git | Commit messages | Change messages for doc updates |
| Package managers | Dependency resolution | Auto-load docs based on dependencies |
| Search engines | PageRank | Rank docs by reference frequency |
| Wikis | "What links here" | Reverse references in each doc |

**Priority Adaptation:** "What links here" reverse references - critical for impact analysis.

---

### M - Modify / Magnify / Minimize

#### Magnify
- Automation (registry generation, link validation, staleness detection)
- Summaries (expand to 5 tiers if needed)
- Cross-linking (prevent orphan docs)

#### Minimize
- Manual metadata entry (infer where possible)
- Template sections (fewer required, more optional)
- Approval friction (trust agents for non-breaking changes)
- Document types (role tags instead of BA/Arch/PRD hierarchy)

**Key Decision:** Use role tags instead of rigid document type hierarchy.

---

### P - Put to Other Uses

| Original Purpose | Alternative Use |
|------------------|-----------------|
| Documentation | Onboarding guide generator |
| Session manifests | Audit trail for compliance |
| Pattern library | Training material |
| doc-registry | Project health dashboard |
| Decision logs | Retrospective fuel |
| Context packs | Demo preparation |

**Priority Use:** Onboarding paths - generate "start here" trails for new team members.

---

### E - Eliminate

| Eliminated | Rationale |
|------------|-----------|
| PRD as massive document | Requirements live in topic docs; use Requirements Index |
| Separate Architecture docs | Merge into topic docs with architecture tag |
| Rigid phase separation | More fluid, tag-based approach |

**Key Elimination:** PRD replaced by Requirements Index that aggregates from topic docs.

---

### R - Reverse / Rearrange

| Current Assumption | Reversed |
|--------------------|----------|
| Project Brief created first | Project Brief auto-generated last |
| Humans write, agents consume | Agents draft, humans curate |
| Sequential phases (BA→Arch→PM) | Parallel perspectives |
| Docs per module | Docs per capability (cross-module) |

**Key Reversal:** Project Brief auto-generated from topic docs - always current, never stale.

---

## Final Innovation List

| Rank | Innovation | Category |
|------|------------|----------|
| 1 | Project Brief auto-generated from topic docs | Reverse |
| 2 | Beads creates doc scaffolds automatically | Combine |
| 3 | "What links here" reverse references | Adapt |
| 4 | Sidecar `.meta.yaml` files | Substitute |
| 5 | Eliminate PRD; use Requirements Index | Eliminate |
| 6 | Role tags instead of doc type hierarchy | Minimize |
| 7 | Manual DOC-IDs with `DOC-{DOMAIN}-{NNN}` convention | Substitute (modified) |
| 8 | Separate doc-registry.yaml from Project Brief | Combine (rejected merge) |
| 9 | Hybrid summaries (AI + human) | Substitute |

---

## Change Log

| Version | Date | Author | Change Summary |
|---------|------|--------|----------------|
| 1.0 | 2026-01-12 | Mary (Business Analyst) | Initial creation with user modifications |
