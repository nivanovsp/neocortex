# RMS-BMAD Methodology Release Notes

This document tracks all changes, decisions, and updates to the RMS-BMAD methodology.

---

## [1.2.0] - 2026-01-16

Agent command cleanup and architecture template improvements.

### Agent Command Removals

#### Analyst Agent (Maya)
- **Remove `*yolo`** - Causes hallucination and rework; autonomous mode leads to compounding errors in documentation work
- **Remove `*doc-out`** - Unclear use case; document output already handled by create-doc skill

#### Architect Agent (Winston)
- **Remove `*yolo`** - Same reasoning as analyst; critical review requires human checkpoints
- **Create `*create-back-end-architecture`** - New command for back-end architecture documents
- **Remove `*create-full-stack-architecture`** - Full-stack in one document invites monolithic designs; use separate front-end and back-end templates instead

#### Developer Agent (Devon)
- **Remove `*yolo`** - Implementation requires validation at each step
- **Remove `*handoff`** - Redundant; implementation notes already captured in story file updates, commit messages, and PR descriptions

#### BMad Master Agent
- **Remove `*yolo`** - Consistent with other agents
- **Remove `*doc-out`** - Consistent with analyst removal
- **Remove `*shard-doc`** - Use `*split-document` instead for proper MLDA-aware document splitting

### Documentation Updates
- Update CLAUDE.md (global and local) to reflect command changes
- Update USER-GUIDE.md with revised agent commands
- Update all related documentation

### Decisions Log

| Decision | Rationale | Date |
|----------|-----------|------|
| Remove `*yolo` from all agents | Autonomous mode causes hallucination and compounding errors; requires significant rework | 2026-01-16 |
| Remove `*doc-out` | Unclear purpose; create-doc skill handles output | 2026-01-16 |
| Keep `*handoff` for Analyst and Architect | Maintains context across sessions for phase transitions | 2026-01-16 |
| Remove `*handoff` from Developer | Redundant with story file updates | 2026-01-16 |
| Keep brownfield architecture | Useful for less experienced users who need extra guidance | 2026-01-16 |
| Remove full-stack architecture | Separate front-end and back-end forces modular thinking | 2026-01-16 |
| Remove shard-doc, keep split-document | shard-doc is not MLDA-aware; split-document provides proper knowledge graph integration | 2026-01-16 |

---

## [1.1.0] - 2026-01-13

### Changed
- Evolved to 3-role workflow: Analyst, Architect, Developer+QA
- Deprecated PM, PO, SM, QA roles (consolidated into 3 core roles)
- Implemented MLDA Neocortex paradigm for knowledge graph navigation
- Added automatic MLDA integration to document-creating skills

### Added
- Architect critical review of analyst work
- Handoff document protocol for phase transitions
- MLDA auto-initialization skill

---

## [1.0.0] - Initial Release

### Added
- RMS Framework (Rules - Modes - Skills)
- Initial agent personas (PM, PO, SM, Analyst, Architect, Dev, QA, UX Expert)
- MLDA (Modular Linked Documentation Architecture)
- Core skills and templates
- Beads integration for issue tracking

---

*Note: This release notes file should be updated with each methodology change. For global changes, ensure both `~/.claude/` and project-level `.claude/` configurations are updated.*
