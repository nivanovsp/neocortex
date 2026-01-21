# Changelog

All notable changes to the Neocortex Methodology will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
