# DEC-006: Full MLDA Integration for UX-Expert

**DOC-PROC-006** | UX-Expert Integration with Neocortex Knowledge Graph

---

**Status:** Implemented
**Date:** 2026-01-21
**Authors:** Human + Claude collaboration
**Related:** DEC-003-automatic-learning-integration.md, DEC-005-handoff-workflow-extension.md

---

## Executive Summary

This document specifies the full MLDA integration for UX-Expert (Uma), enabling the UX role to participate in the Neocortex knowledge graph both as a consumer and contributor. UX-Expert can now create MLDA-compliant wireframes, design systems, user flows, and accessibility reports that other agents can navigate.

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Overview](#2-solution-overview)
3. [Implementation Details](#3-implementation-details)
4. [Cross-Agent Benefits](#4-cross-agent-benefits)
5. [Testing](#5-testing)

---

## 1. Problem Statement

### 1.1 Knowledge Graph Gap

**Issue:** UX-Expert creates valuable design artifacts (wireframes, design systems, user flows, accessibility audits) but these aren't integrated into the MLDA knowledge graph. Developers and other agents can't navigate to UX work using DOC-IDs.

**Impact:**
- UX work exists outside the knowledge graph
- Stories can't reference UX docs with DOC-IDs
- Developers lose context when implementing UI
- No traceability from requirements → UX → implementation

### 1.2 Missing Topic Structure

**Issue:** No topic learning structure for UX domain. Agents can't accumulate learnings about UX patterns across sessions.

### 1.3 Skill Gaps

**Issue:** UX skills create documents but don't:
- Assign DOC-IDs from registry
- Create `.meta.yaml` sidecars
- Update the MLDA registry
- Report entry points for stories

---

## 2. Solution Overview

### 2.1 New UX Domains

| Domain Code | Name | Content Types |
|-------------|------|---------------|
| **UI** | User Interface | Wireframes, component specs, layouts |
| **DS** | Design System | Tokens, patterns, components |
| **UX** | User Experience | User flows, journey maps, personas |
| **A11Y** | Accessibility | Audits, remediation, guidelines |

### 2.2 Output Locations

```
.mlda/docs/
├── ui/             # DOC-UI-xxx wireframes
├── ds/             # DOC-DS-xxx design systems
├── ux/             # DOC-UX-xxx user flows
└── a11y/           # DOC-A11Y-xxx accessibility reports
```

### 2.3 New Commands

| Command | Template | Output |
|---------|----------|--------|
| `*create-wireframe-doc` | `wireframe-tmpl.yaml` | MLDA wireframe |
| `*create-design-system-doc` | `design-system-tmpl.yaml` | MLDA design system |
| `*create-flow-doc` | `user-flow-tmpl.yaml` | MLDA user flow |
| `*create-a11y-report` | `accessibility-report-tmpl.yaml` | MLDA audit |

**Note:** Existing quick commands (`*create-wireframe`, `*design-system`, etc.) remain for rapid generation without full MLDA formality.

---

## 3. Implementation Details

### 3.1 Files Created

| File | Purpose |
|------|---------|
| `.mlda/topics/ux/domain.yaml` | UX domain configuration with 4 sub-domains |
| `.mlda/topics/ux/learning.yaml` | Empty learning file for session accumulation |
| `.claude/commands/templates/wireframe-tmpl.yaml` | MLDA wireframe template |
| `.claude/commands/templates/design-system-tmpl.yaml` | MLDA design system template |
| `.claude/commands/templates/user-flow-tmpl.yaml` | MLDA user flow template |
| `.claude/commands/templates/accessibility-report-tmpl.yaml` | MLDA accessibility report template |

### 3.2 Files Modified

| File | Changes |
|------|---------|
| `.claude/commands/skills/create-wireframe.md` | Added MLDA Finalization section (DOC-UI-xxx) |
| `.claude/commands/skills/design-system.md` | Added MLDA Finalization section (DOC-DS-xxx) |
| `.claude/commands/skills/user-flow.md` | Added MLDA Finalization section (DOC-UX-xxx) |
| `.claude/commands/skills/review-accessibility.md` | Added MLDA Finalization section (DOC-A11Y-xxx) |
| `.claude/commands/modes/ux-expert.md` | Added 4 new `*create-*-doc` commands |

### 3.3 MLDA Finalization Pattern

Each UX skill now includes automatic finalization:

```yaml
# 1. DOC-ID Assignment
- Read .mlda/registry.yaml for next available ID
- Assign: DOC-{DOMAIN}-{NNN}

# 2. Sidecar Creation
- Create {filename}.meta.yaml alongside document
- Include: id, title, status, domain, type, summary
- Include: related (with relationship types)
- Include: reference_frames.layer: design
- Include: predictions.when_implementing

# 3. Registry Update
- Run: .mlda/scripts/mlda-registry.ps1

# 4. Report Entry Points
- List DOC-IDs for stories/developers to reference
```

### 3.4 Standardized Relationship Types

| Old Type | Standard Type | Signal Strength |
|----------|---------------|-----------------|
| `uses` | `depends-on` | Strong - always follow |
| `leads_to` | `extends` | Medium - follow if depth allows |
| `alternative` | `references` | Weak - follow if relevant |

---

## 4. Cross-Agent Benefits

### 4.1 Developer Context Gathering

```
Developer receives story with:
  Documentation References:
    - DOC-UI-005: Navigation wireframe
    - DOC-DS-001: Design system tokens
    - DOC-A11Y-002: Accessibility requirements

Developer runs: *gather-context
  → Loads DOC-UI-005 (wireframe)
  → Follows depends-on → DOC-DS-001 (design system)
  → Follows references → DOC-A11Y-002 (accessibility)
  → Has full context for UI implementation
```

### 4.2 Handoff Phase 3 Integration

```markdown
## Phase 3: UX-Expert → Analyst (Stories)

### Entry Points for Story Creation
| Priority | DOC-ID | Title | Why Start Here |
|----------|--------|-------|----------------|
| 1 | DOC-UI-005 | Navigation Wireframe | Component specs |
| 2 | DOC-DS-001 | Design System | Token references |
| 3 | DOC-UX-003 | Login User Flow | Acceptance criteria |
```

### 4.3 Topic Learning Accumulation

Session learnings for UX work:
- Co-activation patterns (UI + DS + A11Y docs together)
- Verification notes (accessibility findings)
- Design pattern discoveries

---

## 5. Testing

### 5.1 Test Cases

#### TC-1: Topic Learning Load
```
1. Activate /modes:ux-expert
2. Verify greeting shows: "Topic: ux, Learning: v1, 0 sessions"
3. Work on wireframe task
4. At session end, verify learning save proposal includes document patterns
```

#### TC-2: MLDA Document Creation
```
1. Run *create-wireframe-doc
2. Complete interactive elicitation
3. Verify: Document created in .mlda/docs/ui/
4. Verify: DOC-UI-xxx assigned
5. Verify: .meta.yaml sidecar created
6. Verify: Registry updated
```

#### TC-3: Cross-Agent Context
```
1. Create wireframe with DOC-UI-001
2. Create story referencing DOC-UI-001
3. Switch to /modes:dev
4. Run *gather-context
5. Verify: Wireframe loaded in context
6. Verify: Related design system docs followed
```

### 5.2 Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| Topic learning works | Loading shows UX topic status |
| DOC-IDs assigned | All UX docs have DOC-{UI,DS,UX,A11Y}-xxx |
| Sidecars created | All docs have .meta.yaml with relationships |
| Registry updated | mlda-registry.ps1 shows new docs |
| Cross-agent works | Developers can gather UX context |

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-003-automatic-learning-integration.md | Learning integration pattern |
| DEC-005-handoff-workflow-extension.md | UX in workflow |
| modes/ux-expert.md | Updated mode |
| skills/create-wireframe.md | Updated skill |

---

*DOC-PROC-006 | UX MLDA Integration | v1.0*
