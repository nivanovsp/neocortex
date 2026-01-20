---
description: 'Generate or update the handoff document for phase transitions'
---
# Handoff Skill

**RMS Skill v2.0** | Discrete workflow for phase handoff document management with Neocortex awareness

Generate or update the handoff document (`docs/handoff.md`) to pass context between workflow phases.

## Purpose

The handoff document is a **single, evolving document** that:
1. Maintains context across all phases (Analyst → Architect → Developer+QA)
2. Serves as the entry point for each receiving agent
3. Tracks open questions and their resolutions
4. Provides audit trail of decisions

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Registry must be current (`.mlda/registry.yaml`)
- Role must be identified (analyst, architect, or developer)

## Handoff Document Location

**ALWAYS** create/update at: `docs/handoff.md`

## Workflow

### Step 1: Identify Current Phase

Determine which phase is handing off:
- **Phase 1 (Analyst)**: Creating initial documentation
- **Phase 2 (Architect)**: Reviewing and refining
- **Phase 3 (Developer+QA)**: Implementation complete

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
**Current Phase:** [Analyst | Architect | Developer+QA]
**Last Handoff By:** [Role]

---

## Phase History

### Phase 1: Analyst Discovery
**Status:** [In Progress | Completed | Handed Off]
**Agent:** Maya (Analyst)
**Dates:** [Start] - [End]

#### Work Summary
[Brief description of what was accomplished]

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|
| DOC-XXX-001 | ... | ... | ... |

**Total Documents:** [Count]
**Domains Covered:** [List]

#### Key Decisions Made
1. [Decision with rationale]
2. [Decision with rationale]

#### Open Questions for Architect (REQUIRED)
> These are questions the analyst could not resolve alone and require architectural input.

1. **[Question Title]**
   - Context: [Why this is a question]
   - Options considered: [What analyst thought about]
   - Recommendation: [If any]

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-XXX-001 | ... | ... |

---

### Phase 2: Architecture Refinement
**Status:** [Not Started | In Progress | Completed | Handed Off]
**Agent:** Winston (Architect)
**Dates:** [Start] - [End]

#### Review Summary
[What was reviewed and key findings]

#### Documents Modified
| DOC-ID | Title | Changes Made | Rationale |
|--------|-------|--------------|-----------|

#### Documents Created
| DOC-ID | Title | Domain | Description |
|--------|-------|--------|-------------|

#### Questions Resolved
| From Phase | Question | Resolution |
|------------|----------|------------|

#### Open Questions for Developer+QA (REQUIRED)
1. **[Question Title]**
   ...

#### Entry Points for Next Phase
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|

---

### Phase 3: Implementation
**Status:** [Not Started | In Progress | Completed]
**Agent:** Devon (Developer+QA)
**Dates:** [Start] - [End]

#### Implementation Notes
[Key implementation decisions and notes]

#### Stories Completed
| Story ID | Title | Status | Notes |
|----------|-------|--------|-------|

#### Test Coverage
| Component | Unit | Integration | Functional |
|-----------|------|-------------|------------|

#### Issues Discovered
1. [Issue with resolution]

---

## Document Statistics

**Total Documents:** [Auto-calculated from registry]
**By Domain:**
- AUTH: [count]
- API: [count]
- DATA: [count]
...

**Sidecar v2 Coverage:**
- Documents with predictions: [count]
- Documents with boundaries: [count]
- Documents with CRITICAL markers: [count]

**Relationship Health:**
- Orphan documents: [count]
- Broken links: [count]

**Context Readiness:**
- Entry point documents: [count with predictions defined]
- Cross-domain boundaries defined: [yes/no]
```

## Enforcement Rules

### For Analyst (Phase 1)
- **REQUIRED**: "Open Questions for Architect" section must have at least one question
- If no questions, analyst must explicitly state "None - all requirements are clear" with justification
- Entry points must be defined

### For Architect (Phase 2)
- Must resolve questions from Phase 1
- Must document all modifications made
- Must define entry points for developer

### For Developer+QA (Phase 3)
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
5. Confirm handoff is complete

## Neocortex v2 Considerations

During handoff, assess and report on:

### For Analyst → Architect Handoff
- Are key documents marked as entry points (have `predictions` defined)?
- Are domain boundaries clear (documents have `boundaries.related_domains`)?
- Are compliance items marked with `<!-- CRITICAL -->` and `has_critical_markers: true`?

### For Architect → Developer Handoff
- Do implementation-relevant docs have `predictions.when_implementing`?
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
