# Decision Records

This directory contains Architecture Decision Records (ADRs) for the RMS-BMAD/Neocortex methodology.

## Decision Index

| ID | Title | Status | Date | Summary |
|----|-------|--------|------|---------|
| DEC-001 | [Critical Thinking Protocol](DEC-001-critical-thinking-protocol.md) | Approved | 2026-01-14 | Always-on cognitive substrate for all agents |
| DEC-002 | [Neocortex Methodology](DEC-002-neocortex-methodology.md) | Approved | 2026-01-15 | MLDA knowledge graph documentation paradigm |
| DEC-003 | [Automatic Learning Integration](DEC-003-automatic-learning-integration.md) | Approved | 2026-01-20 | Topic-based learning loaded during mode activation |
| DEC-004 | [Learning Load Optimization](DEC-004-learning-load-optimization.md) | Approved | 2026-01-21 | Direct file read instead of skill invocation |
| DEC-005 | [Handoff Workflow Extension](DEC-005-handoff-workflow-extension.md) | Approved | 2026-01-21 | 5-phase workflow with UX handoff and question protocol |
| DEC-006 | [UX MLDA Integration](DEC-006-ux-mlda-integration.md) | Approved | 2026-01-22 | Full MLDA integration for UX-Expert mode |
| DEC-007 | [Two-Tier Learning](DEC-007-two-tier-learning.md) | Approved | 2026-01-23 | Lightweight index + on-demand full learning load |

## Decision Relationships

```
DEC-001 (Critical Thinking)
    │
    ▼
DEC-002 (Neocortex/MLDA)
    │
    ├──► DEC-003 (Auto Learning) ──► DEC-004 (Load Optimization) ──► DEC-007 (Two-Tier)
    │
    ├──► DEC-005 (Handoff Workflow)
    │
    └──► DEC-006 (UX Integration)
```

## Version History

| Version | Date | Key Decisions |
|---------|------|---------------|
| v1.0 | 2026-01-14 | DEC-001: Critical Thinking Protocol |
| v1.1 | 2026-01-15 | DEC-002: Neocortex Methodology |
| v1.5 | 2026-01-20 | DEC-003: Automatic Learning |
| v1.5.1 | 2026-01-21 | DEC-004: Learning Optimization |
| v1.6 | 2026-01-21 | DEC-005: Handoff Workflow |
| v1.7 | 2026-01-22 | DEC-006: UX Integration |
| v1.8 | 2026-01-23 | DEC-007: Two-Tier Learning |

## Creating New Decisions

1. Use the next available DEC-XXX number
2. Follow the template structure from existing decisions
3. Include: Problem Statement, Solution, Implementation, Testing, Rollback Plan
4. Update this README with the new entry
5. Create a corresponding beads task for tracking

---

*Last updated: 2026-01-23*
