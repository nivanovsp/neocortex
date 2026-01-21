# DEC-005: Handoff Workflow Extension and Question Protocol

**DOC-PROC-005** | Extended Workflow with UX Phase and Communication Rules

---

**Status:** Approved - Ready for Implementation
**Date:** 2026-01-21
**Authors:** Human + Claude collaboration
**Related:** DEC-003-automatic-learning-integration.md, DEC-004-learning-load-optimization.md
**Beads:** Ways of Development-116 (Epic), Tasks #117-124

---

## Executive Summary

This document specifies two improvements to the RMS-BMAD methodology:

1. **Extended Handoff Workflow** - Add UX-Expert as a phase after Architect, with explicit phase markers in the handoff document
2. **Question Protocol** - Universal rule requiring agents to ask questions one at a time

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution: Extended Workflow](#2-solution-extended-workflow)
3. [Solution: Question Protocol](#3-solution-question-protocol)
4. [Implementation Details](#4-implementation-details)
5. [Files to Modify](#5-files-to-modify)
6. [Testing](#6-testing)

---

## 1. Problem Statement

### 1.1 Workflow Gap

**Current workflow:**
```
Analyst → Architect → Developer
```

**Issue:** UX-Expert has no place in the handoff chain. UX work happens after architectural decisions but before implementation stories are created.

**Desired workflow:**
```
Analyst → Architect → UX-Expert → Analyst (stories) → Developer
```

### 1.2 Handoff Document Structure

**Current:** Single document with implicit phases, sections can blur together.

**Desired:** Single document with explicit phase markers for clarity.

### 1.3 Question Overload

**Issue:** Agents ask 5-10 questions at once, overwhelming the user.

**Desired:** Agents ask questions one at a time, waiting for response before next question.

---

## 2. Solution: Extended Workflow

### 2.1 New Workflow Diagram

```
┌──────────┐     ┌───────────┐     ┌───────────┐     ┌──────────┐     ┌───────────┐
│ Analyst  │ ──► │ Architect │ ──► │ UX-Expert │ ──► │ Analyst  │ ──► │ Developer │
│ (Maya)   │     │ (Winston) │     │ (Uma)     │     │ (stories)│     │ (Devon)   │
└──────────┘     └───────────┘     └───────────┘     └──────────┘     └───────────┘
     │                 │                 │                 │                 │
     ▼                 ▼                 ▼                 ▼                 ▼
  Phase 1           Phase 2           Phase 3           Phase 4           Phase 5
  Requirements      Architecture      UI/UX Design      Stories           Implementation
```

### 2.2 Handoff Document Structure

**File:** `docs/handoff.md`

```markdown
# Project Handoff Document

> Single evolving document tracking context across all phases.
> Each agent APPENDS to their section, never replaces.

## Project Overview
[Brief description - set by Analyst in Phase 1]

---

## Phase 1: Analyst → Architect
**Status:** [Draft | Complete]
**Date:** YYYY-MM-DD
**Agent:** Maya (Analyst)

### Work Completed
- [List of documents created]
- [Key decisions made]

### Entry Points for Architect
- DOC-ID-001: [description]
- DOC-ID-002: [description]

### Open Questions for Architect
1. [Question requiring architectural decision]
2. [Question about technical approach]

---

## Phase 2: Architect → UX-Expert
**Status:** [Draft | Complete]
**Date:** YYYY-MM-DD
**Agent:** Winston (Architect)

### Work Completed
- [Architecture documents created]
- [Technical decisions made]

### Resolved Questions from Phase 1
- Q1: [Answer]
- Q2: [Answer]

### Entry Points for UX-Expert
- DOC-ID-003: [description]
- DOC-ID-004: [description]

### Open Questions for UX-Expert
1. [Question about UI/UX approach]
2. [Question about user flows]

---

## Phase 3: UX-Expert → Analyst (Stories)
**Status:** [Draft | Complete]
**Date:** YYYY-MM-DD
**Agent:** Uma (UX-Expert)

### Work Completed
- [Wireframes created]
- [Design system decisions]
- [User flow documents]

### Resolved Questions from Phase 2
- Q1: [Answer]
- Q2: [Answer]

### Entry Points for Story Creation
- DOC-ID-005: [description]
- DOC-ID-006: [description]

### Open Questions for Analyst
1. [Question about story breakdown]
2. [Question about acceptance criteria]

---

## Phase 4: Analyst → Developer
**Status:** [Draft | Complete]
**Date:** YYYY-MM-DD
**Agent:** Maya (Analyst)

### Stories Created
- STORY-001: [title]
- STORY-002: [title]

### Entry Points for Developer
- DOC-ID-007: [description]
- Stories in docs/stories/

### Open Questions for Developer
1. [Question about implementation]

---

## Phase 5: Developer (Implementation)
**Status:** [Draft | In Progress | Complete]
**Date:** YYYY-MM-DD
**Agent:** Devon (Developer)

### Implementation Notes
- [Key decisions during implementation]
- [Deviations from spec with justification]

### Completed Stories
- [x] STORY-001
- [ ] STORY-002

### Issues Discovered
- [Technical debt noted]
- [Bugs found and fixed]
```

### 2.3 UX-Expert Handoff Command

Add to `modes/ux-expert.md`:

```markdown
| `*handoff` | Generate/update handoff document for Analyst (stories) | Execute `handoff` skill |
```

**Command details section:**
```markdown
### *handoff
**Skill:** `handoff`
**Output:** `docs/handoff.md`
**Process:**
1. Update Phase 3 section of handoff document
2. Document UX work completed (wireframes, flows, design decisions)
3. List resolved questions from architect phase
4. Define entry points for story creation
5. Add open questions for analyst (story breakdown, acceptance criteria)
```

**Dependencies to add:**
```yaml
skills:
  - handoff
```

---

## 3. Solution: Question Protocol

### 3.1 Rule Definition

Add to **CLAUDE.md** under "Universal Protocols > Communication":

```markdown
### Question Protocol

When gathering information or clarifying requirements:

- **Ask ONE question at a time** and wait for the user's response
- Do not batch multiple questions in a single message
- **Exception:** Tightly coupled questions (max 2-3) may be grouped
  - Example OK: "What's the component name and where should it be created?"
  - Example NOT OK: 5 separate questions about different aspects

**Why:** Batched questions overwhelm users and often result in incomplete answers.
```

### 3.2 Placement

Add this rule to:
1. Global `~/.claude/CLAUDE.md` - Universal Protocols > Communication section
2. Project `CLAUDE.md` - Universal Protocols > Communication section

This automatically applies to ALL agents in ALL modes.

---

## 4. Implementation Details

### 4.1 Task Breakdown

| Task ID | Description | Blocked By |
|---------|-------------|------------|
| #117 | Create DEC-005 (this document) | - |
| #118 | Update CLAUDE.md with question protocol | #117 |
| #119 | Add `*handoff` to UX-Expert mode | #117 |
| #120 | Update handoff skill with phase markers | #117 |
| #121 | Update README, CHANGELOG | #118, #119, #120 |
| #122 | Apply to global .claude | #118, #119, #120 |
| #123 | Apply to Tasks app project | #122 |
| #124 | Push to GitHub | #121, #123 |

### 4.2 Exact Changes Per File

#### 4.2.1 CLAUDE.md (both global and project)

**Location:** Universal Protocols > Communication section

**Add after existing communication rules:**
```markdown
### Question Protocol

When gathering information or clarifying requirements:

- **Ask ONE question at a time** and wait for the user's response
- Do not batch multiple questions in a single message
- **Exception:** Tightly coupled questions (max 2-3) may be grouped
  - Example OK: "What's the component name and where should it be created?"
  - Example NOT OK: 5 separate questions about different aspects

**Why:** Batched questions overwhelm users and often result in incomplete answers.
```

#### 4.2.2 modes/ux-expert.md

**Add to Commands table:**
```markdown
| `*handoff` | Generate/update handoff document for Analyst (stories) | Execute `handoff` skill |
```

**Add Command Execution Details section:**
```markdown
### *handoff
**Skill:** `handoff`
**Output:** `docs/handoff.md`
**Process:**
1. Update Phase 3 section of handoff document
2. Document UX work completed (wireframes, flows, design decisions)
3. List resolved questions from architect phase
4. Define entry points for story creation
5. Add open questions for analyst (story breakdown, acceptance criteria)
```

**Add to Dependencies:**
```yaml
skills:
  - handoff
```

#### 4.2.3 skills/handoff.md

**Update the skill to support phase markers:**

1. Add phase parameter support
2. Update template generation to use explicit phase sections
3. Add UX-Expert phase (Phase 3)
4. Renumber subsequent phases

**Key changes:**
- Detect current agent/phase automatically
- Append to correct phase section
- Include standard section structure (Work Completed, Resolved Questions, Entry Points, Open Questions)

#### 4.2.4 README.md

**Update Core Workflow section:**

Change:
```
Analyst → Architect → Developer
```

To:
```
Analyst → Architect → UX-Expert → Analyst (stories) → Developer
```

**Update workflow table with UX-Expert role.**

#### 4.2.5 CHANGELOG.md

**Add v1.6.0 entry:**
```markdown
## [1.6.0] - 2026-01-21

### Added
- UX-Expert now has `*handoff` command to hand off to Analyst for story creation
- Explicit phase markers in handoff document structure
- Question Protocol: Agents must ask questions one at a time (Universal rule)

### Changed
- Workflow extended: Analyst → Architect → UX-Expert → Analyst (stories) → Developer
- Handoff skill updated to support 5-phase workflow with explicit sections
```

---

## 5. Files to Modify

### 5.1 Source Repository (Ways of Development)

| File | Change |
|------|--------|
| `CLAUDE.md` | Add Question Protocol to Communication section |
| `.claude/commands/modes/ux-expert.md` | Add `*handoff` command and dependencies |
| `.claude/commands/skills/handoff.md` | Update with phase markers structure |
| `README.md` | Update workflow diagram |
| `CHANGELOG.md` | Add v1.6.0 entry |
| `docs/decisions/DEC-005-*.md` | This document |

### 5.2 Global Installation

| File | Change |
|------|--------|
| `C:/Users/User/.claude/CLAUDE.md` | Add Question Protocol |
| `C:/Users/User/.claude/commands/modes/ux-expert.md` | Add `*handoff` |
| `C:/Users/User/.claude/commands/skills/handoff.md` | Update with phase markers |

### 5.3 Tasks App Project

| File | Change |
|------|--------|
| `D:/Dev Projects/Tasks app/.claude/commands/modes/ux-expert.md` | Add `*handoff` |
| `D:/Dev Projects/Tasks app/.claude/commands/skills/handoff.md` | Update with phase markers |

**Note:** Tasks app uses global CLAUDE.md, so Question Protocol applies automatically.

---

## 6. Testing

### 6.1 Test Cases

#### TC-1: UX-Expert Handoff
```
1. Invoke /modes:ux-expert
2. Run *handoff
3. Verify Phase 3 section created/updated in docs/handoff.md
4. Verify includes: Work Completed, Entry Points, Open Questions for Analyst
```

#### TC-2: Question Protocol
```
1. Start any mode
2. Ask agent to gather requirements for a feature
3. Verify agent asks ONE question, waits for response
4. Verify agent does NOT batch 5+ questions
```

#### TC-3: Full Workflow
```
1. Analyst creates requirements, runs *handoff (Phase 1)
2. Architect reviews, runs *handoff (Phase 2)
3. UX-Expert designs, runs *handoff (Phase 3)
4. Analyst creates stories, runs *handoff (Phase 4)
5. Developer implements, updates handoff (Phase 5)
6. Verify all phases present in single docs/handoff.md
```

### 6.2 Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| UX-Expert handoff works | Phase 3 section created correctly |
| Phase markers visible | All 5 phases clearly separated |
| Questions one-at-a-time | No batched questions in elicitation |
| Backward compatible | Existing handoff docs still work |

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-003-automatic-learning-integration.md | Activation protocol |
| DEC-004-learning-load-optimization.md | Token optimization |
| modes/ux-expert.md | Mode to update |
| skills/handoff.md | Skill to update |

---

*DOC-PROC-005 | Handoff Workflow Extension | v1.0*
