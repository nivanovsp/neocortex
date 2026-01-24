---
description: 'Generate or update the handoff document for phase transitions'
---
# Handoff Skill

**RMS Skill v2.2** | Discrete workflow for phase handoff document management with Neocortex awareness

Generate or update the handoff document (`docs/handoff.md`) to pass context between workflow phases.

## Purpose

The handoff document is a **single, evolving document** that:
1. Maintains context across all 5 phases of the workflow
2. Serves as the entry point for each receiving agent
3. Tracks open questions and their resolutions
4. Provides audit trail of decisions

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Registry must be current (`.mlda/registry.yaml`)
- Role must be identified (analyst, architect, ux-expert, or developer)

## Handoff Document Location

**ALWAYS** create/update at: `docs/handoff.md`

## 5-Phase Workflow

```
┌──────────┐     ┌───────────┐     ┌───────────┐     ┌──────────┐     ┌───────────┐
│ Analyst  │ ──► │ Architect │ ──► │ UX-Expert │ ──► │ Analyst  │ ──► │ Developer │
│ (Maya)   │     │ (Winston) │     │ (Uma)     │     │ (stories)│     │ (Devon)   │
└──────────┘     └───────────┘     └───────────┘     └──────────┘     └───────────┘
   Phase 1          Phase 2          Phase 3          Phase 4          Phase 5
```

## Workflow

### Step 1: Identify Current Phase

Determine which phase is handing off:
- **Phase 1 (Analyst → Architect)**: Requirements discovery complete
- **Phase 2 (Architect → UX-Expert)**: Architecture review complete
- **Phase 3 (UX-Expert → Analyst)**: UI/UX design complete
- **Phase 4 (Analyst → Developer)**: Stories created from UX specs
- **Phase 5 (Developer)**: Implementation complete

### Step 2: Gather Data

1. Read `.mlda/registry.yaml` to get document statistics
2. Identify documents created/modified in this phase
3. Collect key decisions made
4. **For Analyst**: REQUIRE open questions for architect (this is MANDATORY)
5. Identify entry points for next phase

### Step 3: Generate/Update Handoff

If `docs/handoff.md` doesn't exist, create it with full structure.
If it exists, update the current phase section and preserve previous phases.

## Handoff Document Schema

```markdown
# Project Handoff Document

**Project:** [Project Name]
**Last Updated:** [Date]
**Current Phase:** [1: Analyst | 2: Architect | 3: UX-Expert | 4: Analyst (stories) | 5: Developer]
**Last Handoff By:** [Role]

> Single evolving document tracking context across all phases.
> Each agent APPENDS to their section, never replaces.

---

## Project Overview
[Brief description - set by Analyst in Phase 1]

---

## Phase 1: Analyst → Architect
**Status:** [Draft | Complete]
**Date:** [YYYY-MM-DD]
**Agent:** Maya (Analyst)

### Work Completed
- [List of documents created]
- [Key decisions made]

### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|
| DOC-XXX-001 | ... | ... | ... |

### Entry Points for Architect
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-XXX-001 | ... | ... |

### Open Questions for Architect (REQUIRED)
> These are questions the analyst could not resolve alone and require architectural input.

1. **[Question Title]**
   - Context: [Why this is a question]
   - Options considered: [What analyst thought about]
   - Recommendation: [If any]

---

## Phase 2: Architect → UX-Expert
**Status:** [Draft | Complete]
**Date:** [YYYY-MM-DD]
**Agent:** Winston (Architect)

### Work Completed
- [Architecture documents created]
- [Technical decisions made]

### Resolved Questions from Phase 1
- Q1: [Answer]
- Q2: [Answer]

### Documents Modified/Created
| DOC-ID | Title | Domain | Changes/Description |
|--------|-------|--------|---------------------|

### Entry Points for UX-Expert
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|

### Open Questions for UX-Expert (REQUIRED)
1. **[Question Title]**
   - Context: [Why this needs UX input]
   - Constraints: [Technical constraints to consider]

---

## Phase 3: UX-Expert → Analyst (Stories)
**Status:** [Draft | Complete]
**Date:** [YYYY-MM-DD]
**Agent:** Uma (UX-Expert)

### Work Completed
- [Wireframes created]
- [Design system decisions]
- [User flow documents]

### Resolved Questions from Phase 2
- Q1: [Answer]
- Q2: [Answer]

### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|

### Entry Points for Story Creation
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|

### Open Questions for Analyst (REQUIRED)
1. **[Question Title]**
   - Context: [Why this needs story-level clarification]
   - UX recommendation: [If any]

---

## Phase 4: Analyst → Developer
**Status:** [Draft | Complete]
**Date:** [YYYY-MM-DD]
**Agent:** Maya (Analyst)

### Stories Created
| Story ID | Title | Priority | Complexity |
|----------|-------|----------|------------|
| STORY-001 | ... | ... | ... |

### Resolved Questions from Phase 3
- Q1: [Answer]
- Q2: [Answer]

### Entry Points for Developer
| Priority | DOC-ID/Story | Title | Why Start Here |
|----------|--------------|-------|----------------|
| 1 | STORY-001 | ... | ... |

### Open Questions for Developer (REQUIRED)
1. **[Question Title]**
   - Context: [Why this needs dev input]
   - Acceptance criteria notes: [If relevant]

---

## Phase 5: Developer (Implementation)
**Status:** [Draft | In Progress | Complete]
**Date:** [YYYY-MM-DD]
**Agent:** Devon (Developer+QA)

### Implementation Notes
- [Key implementation decisions]
- [Deviations from spec with justification]

### Completed Stories
- [x] STORY-001: [Title]
- [ ] STORY-002: [Title]

### Test Coverage
| Component | Unit | Integration | E2E |
|-----------|------|-------------|-----|

### Issues Discovered
1. [Issue with resolution]

---

## Document Statistics

**Total Documents:** [Auto-calculated from registry]
**By Domain:**
- AUTH: [count]
- API: [count]
- UI: [count]
- UX: [count]
...

**Sidecar v2 Coverage:**
- Documents with predictions: [count]
- Documents with boundaries: [count]
- Documents with CRITICAL markers: [count]

**Relationship Health:**
- Orphan documents: [count]
- Broken links: [count]
```

## Enforcement Rules

### For Analyst (Phase 1)
- **REQUIRED**: "Open Questions for Architect" section must have at least one question
- If no questions, analyst must explicitly state "None - all requirements are clear" with justification
- Entry points must be defined

### For Architect (Phase 2)
- Must resolve questions from Phase 1
- Must document all modifications made
- Must define entry points for UX-Expert
- **REQUIRED**: "Open Questions for UX-Expert" section

### For UX-Expert (Phase 3)
- Must resolve questions from Phase 2
- Must document wireframes, flows, and design decisions
- Must define entry points for story creation
- **REQUIRED**: "Open Questions for Analyst" section

### For Analyst (Phase 4 - Stories)
- Must create stories from UX specifications
- Must resolve questions from Phase 3
- Must define entry points for developer
- **REQUIRED**: "Open Questions for Developer" section

### For Developer+QA (Phase 5)
- Must document implementation decisions
- Must list completed stories
- Must note any discovered issues

## Elicitation Process

When running this skill, prompt the user for:

1. **Work Summary**: "Please provide a brief summary of what was accomplished in this phase."

2. **Key Decisions**: "What key decisions were made? List them with rationale."

3. **Open Questions** (Analyst only):
   "What questions need architectural input? (REQUIRED - at least one, or explicit 'None' with justification)"

4. **Entry Points**: "Which documents should the next role start with? Why?"

## Output

1. Create/update `docs/handoff.md` with phase-appropriate content
2. Run `mlda-validate` to check MLDA integrity
3. Report any orphan documents as warnings
4. Report sidecar v2 coverage (predictions, boundaries, critical markers)
5. **Regenerate activation context (DEC-009):**
   ```powershell
   .\.mlda\scripts\mlda-generate-activation-context.ps1
   ```
   This ensures the next mode activation has current handoff context.
6. Confirm handoff is complete

## Neocortex v2 Considerations

During handoff, assess and report on:

### For Phase 1: Analyst → Architect Handoff
- Are key documents marked as entry points (have `predictions` defined)?
- Are domain boundaries clear (documents have `boundaries.related_domains`)?
- Are compliance items marked with `<!-- CRITICAL -->` and `has_critical_markers: true`?

### For Phase 2: Architect → UX-Expert Handoff
- Are UI/UX-relevant docs identified?
- Do architecture docs specify user interaction constraints?
- Are there documents with `reference_frames.layer: presentation`?

### For Phase 3: UX-Expert → Analyst Handoff
- Are wireframes and user flows documented?
- Do design specs include accessibility requirements?
- Are component specifications ready for story creation?

### For Phase 4: Analyst → Developer Handoff
- Do stories reference correct DOC-IDs?
- Are acceptance criteria clear and testable?
- Do implementation-relevant docs have `predictions.when_implementing`?

### For Phase 5: Developer Implementation
- Are there documents with `reference_frames.layer: implementation`?
- Are cross-domain dependencies noted in boundaries?

### Sidecar v2 Validation Checklist
- [ ] All documents have `domain` field set
- [ ] All documents have `summary` field
- [ ] Entry points have `predictions` for relevant task types
- [ ] Security/compliance docs have `has_critical_markers: true` if applicable
- [ ] Documents define `related_domains` for cross-domain traversal

## Key Principles

- Single evolving document - never replace, always update
- Open Questions are MANDATORY for analyst handoff
- Entry points guide the next role's navigation
- Previous phase content is preserved
- MLDA validation runs after handoff
