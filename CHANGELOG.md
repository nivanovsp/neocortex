# Changelog

All notable changes to the Neocortex Methodology will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2026-01-21

### Added
- **UX MLDA Integration** - UX-Expert now fully participates in the Neocortex knowledge graph (DEC-006)
- **UX Topic Learning** - New `.mlda/topics/ux/` with domain.yaml and learning.yaml for session-based learning
- **4 New UX Document Commands**:
  - `*create-wireframe-doc` - Creates MLDA wireframe with DOC-UI-xxx
  - `*create-design-system-doc` - Creates MLDA design system with DOC-DS-xxx
  - `*create-flow-doc` - Creates MLDA user flow with DOC-UX-xxx
  - `*create-a11y-report` - Creates MLDA accessibility report with DOC-A11Y-xxx
- **4 New MLDA Templates** in `.claude/commands/templates/`:
  - `wireframe-tmpl.yaml`
  - `design-system-tmpl.yaml`
  - `user-flow-tmpl.yaml`
  - `accessibility-report-tmpl.yaml`

### Changed
- **UX Skills Updated** - All 4 UX skills now include MLDA Finalization sections:
  - Automatic DOC-ID assignment from registry
  - Automatic sidecar `.meta.yaml` creation
  - Registry update after document creation
  - Entry point reporting for stories
- **Standardized Relationship Types**: `uses` → `depends-on`, `leads_to` → `extends`, `alternative` → `references`

### Documentation
- Added `docs/decisions/DEC-006-ux-mlda-integration.md`

---

## [1.6.0] - 2026-01-21

### Added
- **UX-Expert Handoff** - UX-Expert now has `*handoff` command to hand off to Analyst for story creation (DEC-005)
- **Explicit Phase Markers** - Handoff document now has 5 explicit phase sections
- **Question Protocol** - Universal rule: Agents must ask questions one at a time, not in batches

### Changed
- **Extended Workflow**: `Analyst → Architect → UX-Expert → Analyst (stories) → Developer`
- Handoff skill updated to support 5-phase workflow with explicit sections
- CLAUDE.md Core Workflow updated from 3-role to 5-phase
- Handoff Document Protocol updated with all 5 phases

### Documentation
- Added `docs/decisions/DEC-005-handoff-workflow-extension.md`

### Implementation Status
- [x] Update CLAUDE.md with Question Protocol
- [x] Add `*handoff` to UX-Expert mode
- [x] Update handoff skill with phase markers
- [x] Update README with 5-phase workflow
- [x] Apply to global .claude
- [x] Apply to Tasks app project
- [ ] Push to GitHub (pending)

---

## [1.5.1] - 2026-01-21

### Fixed
- **Learning Load Optimization** - Mode activation now reads learning files directly instead of invoking the `*learning load` command, reducing token consumption by ~12K tokens per session (DEC-004)

### Changed
- All mode activation protocols updated to use direct file read for learning
- Learning status report is now MANDATORY and visible in mode greeting
- Added concrete examples to all mode activation protocols

### Affected Files
- `.claude/commands/modes/analyst.md`
- `.claude/commands/modes/architect.md`
- `.claude/commands/modes/dev.md`
- `.claude/commands/modes/ux-expert.md`
- `.claude/commands/modes/bmad-master.md`

### Documentation
- Added `docs/decisions/DEC-004-learning-load-optimization.md`
- Updated `README.md` to reflect direct file read approach
- Updated `docs/decisions/DEC-003-automatic-learning-integration.md` with DEC-004 reference

---

## [1.5.0] - 2026-01-20

### Added
- **Automatic Learning Integration** - Topic-based learning now loads automatically during mode activation (DEC-003)
- Session tracking mechanism for document co-activation patterns
- `*learning status` command for visibility into loaded learnings
- Session End Protocol for proposing learning saves

### Changed
- All modes now have mandatory Activation Protocol with checkboxes
- Modes include `manage-learning` skill dependency
- bmad-master mode updated with full MLDA/learning integration

---

## [1.4.0] - 2026-01-19

### Added
- UX Expert skills with Neocortex integration
- Design system skill (`/skills:design-system`)
- Wireframe creation skill (`/skills:create-wireframe`)
- User flow mapping skill (`/skills:user-flow`)
- Accessibility review skill (`/skills:review-accessibility`)

---

## [1.3.0] - 2026-01-18

### Added
- **Critical Thinking Protocol** - Always-on cognitive substrate for all agents (DEC-001)
- Uncertainty communication patterns
- Handling disagreement guidelines
- Domain-specific checkpoints

---

## [1.2.0] - 2026-01-17

### Changed
- Agent command cleanup and architecture template improvements
- Consolidated deprecated modes (pm, po, sm, qa) with deprecation notices

---

## [1.1.0] - 2026-01-15

### Added
- Initial Neocortex methodology implementation
- MLDA (Modular Linked Documentation Architecture)
- Topic-based learning infrastructure
- Core modes: analyst, architect, dev

---

*Neocortex Methodology | Built on the RMS Framework*
