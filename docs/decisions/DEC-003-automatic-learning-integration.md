# DEC-003: Automatic Learning Integration for Neocortex

**DOC-PROC-003** | Learning System Integration Specification

---

**Status:** Approved - Implementation In Progress
**Date:** 2026-01-20
**Authors:** Human + Claude collaboration
**Related:** DEC-002-neocortex-methodology.md

---

## Executive Summary

This document defines the **Automatic Learning Integration** - enhancements to the Neocortex methodology that make topic-based learning automatic rather than manual. The learning system infrastructure exists but agents don't automatically load and use topic learnings during activation.

**Key Decisions:**
1. Convert descriptive "Activation" sections into **mandatory protocols with checkboxes**
2. Add explicit `*learning load {topic}` invocation during mode activation
3. Add **Session End Protocol** for proposing learning saves
4. Add **session tracking mechanism** for co-activation patterns
5. Extend to **bmad-master mode** for comprehensive coverage
6. Add `*learning status` command for visibility

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Approach](#2-solution-approach)
3. [Implementation Details](#3-implementation-details)
4. [Phase 1: Core Mode Updates (Completed)](#4-phase-1-core-mode-updates-completed)
5. [Phase 2: Extended Integration](#5-phase-2-extended-integration)
6. [Session Tracking Mechanism](#6-session-tracking-mechanism)
7. [Testing & Verification](#7-testing--verification)
8. [Beads Task Summary](#8-beads-task-summary)

---

## 1. Problem Statement

### Current State

The Neocortex MLDA learning system is architecturally complete:
- Learning file schema defined in `manage-learning.md`
- Topic directories at `.mlda/topics/{topic}/`
- Scripts for loading/saving learnings
- Integration documented in `gather-context.md`

However, agents don't automatically use it because:
- Mode activation sections are **descriptive** ("when activated, do X")
- No explicit step to execute `*learning load {topic}`
- No tracking of documents accessed during session
- No prompt to save learnings at session end

### Desired State

- Agents **automatically load** topic learnings when activated with a task
- Learning context is **applied during gather-context** workflow
- Documents accessed are **tracked during session**
- Session end **proposes saving** new learnings

### Impact of Not Fixing

- Learning system remains unused despite being complete
- Agents don't accumulate knowledge across sessions
- Context gathering is less efficient (no learned patterns)
- Verification notes from past sessions are lost

---

## 2. Solution Approach

### Key Insight

The modes currently say "If task context provided, identify topic and load topic learnings" - but this is buried in a list and treated as optional. We need to:

1. Make it an **explicit, numbered checklist** that MUST be executed
2. Add **concrete output expectations** (what the agent should report)
3. Integrate learning commands into the activation flow
4. Add session tracking mechanism

### Design Principles

| Principle | Application |
|-----------|-------------|
| **Prescriptive over descriptive** | Checkboxes that must be executed, not descriptions |
| **Visible feedback** | Report formats showing what was loaded |
| **Low friction** | Automatic identification, minimal user input |
| **Graceful degradation** | Works without learnings, just less efficiently |

---

## 3. Implementation Details

### Activation Protocol Template

All modes now follow this mandatory protocol:

```markdown
## Activation Protocol (MANDATORY)

When this mode is invoked, you MUST execute these steps IN ORDER:

### Step 1: MLDA Status Check
- [ ] Check if `.mlda/` folder exists
- [ ] If missing, prompt user to run `*init-project`
- [ ] If present, read `.mlda/registry.yaml` and report document count

### Step 2: Topic Identification & Learning Load
- [ ] Identify topic from DOC-IDs, beads labels, or user mention
- [ ] If topic identified, execute: `*learning load {topic}`
- [ ] Report loaded learnings (groupings, activations, notes)

### Step 3: Context Gathering (if task provided)
- [ ] Execute `*gather-context` proactively
- [ ] Apply loaded learning activations to prioritize documents

### Step 4: Greeting & Ready State
- [ ] Greet as [persona]
- [ ] Display available commands
- [ ] Await user instructions

### Session End Protocol
When session ending:
1. Propose saving learnings: `*learning save`
2. Track documents co-activated
3. Note verification insights
```

### Report Formats

**MLDA Status:**
```
MLDA Status: ✓ Initialized
Documents: 24 | Domains: AUTH, API, SEC, DATA
Last registry update: 2026-01-20
```

**Topic Learning:**
```
Topic: authentication
Learning: v3, 12 sessions contributed
Groupings: token-management (3 docs), session-handling (2 docs)
Activations: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001] (freq: 7)
Verification note: "Always check compliance markers in token docs"
```

---

## 4. Phase 1: Core Mode Updates (Completed)

### Files Modified

| File | Changes |
|------|---------|
| `modes/analyst.md` | Mandatory protocol, `*learning` command, Session End Protocol |
| `modes/architect.md` | Mandatory protocol (handoff-first), `*learning` command |
| `modes/dev.md` | Mandatory protocol (story DOC-IDs), `*learning` command |
| `modes/ux-expert.md` | Mandatory protocol, MLDA Enforcement Protocol (was missing) |
| `skills/gather-context.md` | Prerequisite check for topic learnings |

### Command Addition

All modes now include:
```
| `*learning {cmd}` | Manage topic learnings (load/save/show) | Execute `manage-learning` skill |
```

### Dependencies Updated

All modes now include `manage-learning` in their skills dependencies.

---

## 5. Phase 2: Extended Integration

### 5.1 bmad-master.md Updates

**Why:** The "comprehensive expertise" mode should also have learning integration since it handles multi-domain work.

**Changes:**
- Add MLDA Enforcement Protocol section
- Add Mandatory Activation Protocol
- Add `*learning`, `*gather-context`, `*explore` commands
- Add `manage-learning`, `gather-context`, `mlda-navigate` to dependencies
- Add Session End Protocol

### 5.2 Session Tracking Mechanism

**Why:** Modes say "track documents co-activated" but don't explain how.

**Solution:** Add internal tracking guidance to all modes:

```yaml
session_tracking:
  what_to_track:
    - Documents loaded during gather-context
    - Documents referenced during work
    - Documents loaded together repeatedly
    - Verification catches (errors found, corrections made)

  tracking_format:
    accessed_docs: []      # Append DOC-IDs as accessed
    co_activations: []     # Note when multiple docs needed together
    verification_notes: [] # Note when something was caught/corrected

  when_to_propose_save:
    - User signals session ending
    - User completes a major task
    - User runs *handoff
    - User explicitly asks
```

### 5.3 Learning Status Command

**Why:** Users should be able to see if learnings are loaded at any time.

**Add to manage-learning.md:**

| Command | Description |
|---------|-------------|
| `*learning status` | Show current learning state |

**Output:**
```
Learning Status:
  Topic: authentication
  Loaded: Yes (v3)
  Session tracking: 4 docs accessed, 1 co-activation noted
  Pending save: Yes (new patterns discovered)
```

---

## 6. Session Tracking Mechanism

### Implementation

Add to each mode file after Activation Protocol:

```markdown
## Session Tracking

During the session, maintain awareness of:

### Documents Accessed
Track DOC-IDs of documents you load or reference:
- Entry point documents
- Documents loaded via gather-context
- Documents navigated to via relationships

### Co-Activation Patterns
Note when multiple documents are needed together:
- "Needed DOC-AUTH-001 and DOC-SEC-001 together for token validation"
- "DOC-API-003 and DOC-DATA-001 always loaded together for endpoints"

### Verification Catches
Note when you discover issues:
- "DOC-AUTH-007 section 3.2 has ambiguous language about edge cases"
- "Found GDPR requirement not clearly documented in OAuth flow"

### At Session End
Use tracked information to propose learnings via `*learning save`.
```

---

## 7. Testing & Verification

### Test Cases

#### TC-1: Analyst Mode Activation with Task
```
Input: Invoke /modes:analyst with "Work on authentication stories"
Expected:
1. MLDA status reported
2. Topic "authentication" identified
3. *learning load authentication executed
4. Learning report displayed
5. Greeting as Maya
```

#### TC-2: Architect Mode Activation
```
Input: Invoke /modes:architect
Expected:
1. Handoff document read FIRST
2. Topic extracted from handoff entry points
3. *learning load {topic} executed
4. *gather-context run from entry points
5. Greeting as Winston
```

#### TC-3: Session End Learning Save
```
Input: User says "I'm done for today"
Expected:
1. Agent proposes *learning save
2. Shows tracked co-activations
3. Shows verification notes
4. Asks for confirmation before saving
```

#### TC-4: bmad-master Mode Activation
```
Input: Invoke /modes:bmad-master with task containing DOC-IDs
Expected:
1. MLDA status reported
2. Topic identified from DOC-IDs
3. *learning load executed
4. Commands displayed including *learning
```

### Success Criteria

| Criterion | Measurement |
|-----------|-------------|
| Learning auto-loaded | Agent reports learning load in 100% of activations with identifiable topic |
| Session tracking | Agent tracks accessed documents throughout session |
| Save proposal | Agent proposes save at session end in 100% of sessions with activity |
| Graceful degradation | Agent proceeds smoothly when no learnings exist |

---

## 8. Beads Task Summary

| ID | Title | Status | Blocked By |
|----|-------|--------|------------|
| TBD-101 | Epic: Automatic Learning Integration Phase 2 | Open | — |
| TBD-102 | Update bmad-master.md with learning integration | Open | — |
| TBD-103 | Add session tracking mechanism to all modes | Open | 102 |
| TBD-104 | Add *learning status command | Open | — |
| TBD-105 | Update related documentation | Open | 102, 103, 104 |

---

## References

### Related Documents

| Document | Relationship |
|----------|--------------|
| DEC-002-neocortex-methodology.md | Parent methodology |
| manage-learning.md | Learning skill specification |
| gather-context.md | Context gathering workflow |

### Files to Modify

| File | Phase |
|------|-------|
| `.claude/commands/modes/bmad-master.md` | Phase 2 |
| `.claude/commands/modes/*.md` (all) | Session tracking |
| `.claude/commands/skills/manage-learning.md` | Status command |
| `README.md` | Documentation |
| `docs/USER-GUIDE.md` | Documentation |

---

*DOC-PROC-003 | Automatic Learning Integration | v1.0*
*This document will be updated as implementation progresses.*
