# DEC-004: Learning Load Optimization

**DOC-PROC-004** | Token Efficiency Amendment to DEC-003

---

**Status:** Approved
**Date:** 2026-01-21
**Authors:** Human + Claude collaboration
**Related:** DEC-003-automatic-learning-integration.md
**Beads:** Ways of Development-109 (Epic), Ways of Development-110 (This task)

---

## Executive Summary

This document addresses a **token efficiency problem** discovered in the DEC-003 learning integration implementation. The current approach uses `*learning load {topic}` command syntax during mode activation, which triggers loading the full `manage-learning` skill (457 lines) just to read a tiny learning file (25 lines). Combined with agents not visibly confirming learning was loaded, users trigger duplicate loads.

**Key Decision:** Change mode activation protocols to **directly read learning files** instead of invoking the skill command.

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Root Cause Analysis](#2-root-cause-analysis)
3. [Solution](#3-solution)
4. [Implementation](#4-implementation)
5. [Affected Files](#5-affected-files)
6. [Testing](#6-testing)

---

## 1. Problem Statement

### Observed Behavior

User reported:
1. Mode activation drops context from 100% to ~84% (~32K tokens)
2. After explicitly asking for learning, context drops to ~55% (~90K tokens)
3. Total: ~90K tokens before any work begins
4. Expected: ~45K tokens maximum (per DEC-002 estimates)

### Expected Behavior

- Mode activation should consume ~25-45K tokens total (including learning)
- Learning should be visibly loaded during activation
- No duplicate loading required

---

## 2. Root Cause Analysis

### The Double-Load Problem

**Current DEC-003 Protocol (problematic):**
```markdown
### Step 2: Topic Identification & Learning Load
- [ ] If topic identified, execute: `*learning load {topic}`
```

**What happens:**
1. Agent reads activation protocol
2. Protocol says `*learning load {topic}` (command syntax)
3. To understand the command, agent loads `manage-learning.md` skill (457 lines)
4. Skill instructs agent to read learning file (25 lines)
5. Agent may not visibly report "Learning loaded"
6. User can't tell if learning was loaded
7. User explicitly asks → triggers ANOTHER load of skill + file

**Token overhead:**
| Component | Tokens (est.) |
|-----------|---------------|
| manage-learning skill | ~12K |
| learning.yaml file | ~100 |
| Verbose response | ~500 |
| **Duplicate load total** | ~12.5K wasted |

### Why Command Syntax Causes This

The `*learning load {topic}` syntax is designed for **user-invoked commands**. When used in activation protocols:
- Agent treats it as "execute this skill"
- Skill file gets loaded to understand execution context
- Heavy overhead for a simple file read operation

---

## 3. Solution

### Change: Direct File Read Instead of Command

**New Protocol:**
```markdown
### Step 2: Topic Identification & Learning Load
- [ ] Identify topic from DOC-IDs, beads labels, or user mention
- [ ] If topic identified, read: `.mlda/topics/{topic}/learning.yaml`
- [ ] Report learning status using format below

**Learning Status Report (MANDATORY):**
```
Topic: {topic-name}
Learning: v{version}, {n} sessions contributed
Groupings: {list or "none"}
Activations: {list or "none"}
```
```

### Benefits

| Before | After |
|--------|-------|
| Load 457-line skill | Read 25-line file directly |
| Implicit confirmation | Mandatory visible report |
| User asks again | User sees confirmation |
| ~12.5K tokens wasted | ~100 tokens used |

### Command Preservation

The `*learning` commands remain available for:
- `*learning save` - Save session learnings (interactive)
- `*learning status` - Check current state mid-session
- `*learning note` - Add verification notes
- `*learning grouping` - Add document groupings

Only the **initial load during activation** changes to direct file read.

---

## 4. Implementation

### Mode File Changes

Replace in ALL mode activation protocols:

**Before:**
```markdown
### Step 2: Topic Identification & Learning Load
- [ ] Identify topic from one of:
  - DOC-ID references in task/request
  - Beads task labels
  - Explicit user mention
  - Context from conversation
- [ ] If topic identified, execute: `*learning load {topic}`
- [ ] If topic not identified, note "Topic: None identified"
```

**After:**
```markdown
### Step 2: Topic Identification & Learning Load
- [ ] Identify topic from one of:
  - DOC-ID references in task/request (DOC-AUTH-xxx → authentication)
  - Beads task labels (if working from beads)
  - Explicit user mention ("working on authentication")
  - Context from conversation
- [ ] If topic identified:
  - [ ] Read file: `.mlda/topics/{topic}/learning.yaml`
  - [ ] Parse and report using format below
- [ ] If topic not identified, note "Topic: None identified - will determine from task"

**MANDATORY Learning Status Report:**
```
Topic: {topic-name}
Learning: v{version}, {n} sessions contributed
Groupings: {grouping-name} ({n} docs), ... | or "none yet"
Activations: [{DOC-IDs}] (freq: {n}) | or "none yet"
Note: "{relevant verification note}" | or omit if none
```

**Example:**
```
Topic: authentication
Learning: v2, 3 sessions contributed
Groupings: token-management (2 docs)
Activations: [DOC-AUTH-001, DOC-AUTH-002] (freq: 3)
Note: "Check compliance markers in token docs"
```
```

### Key Changes Summary

1. **Direct file read** instead of `*learning load` command
2. **Mandatory output format** so user sees confirmation
3. **Example included** for clarity
4. **Graceful handling** when no learnings exist

---

## 5. Affected Files

### Source Repository (Ways of Development)

| File | Change |
|------|--------|
| `.claude/commands/modes/analyst.md` | Update Step 2 in Activation Protocol |
| `.claude/commands/modes/architect.md` | Update Step 3 in Activation Protocol |
| `.claude/commands/modes/dev.md` | Update Step 3 in Activation Protocol |
| `.claude/commands/modes/ux-expert.md` | Update Step 2 in Activation Protocol |
| `.claude/commands/modes/bmad-master.md` | Update Step 2 in Activation Protocol |

### Global Installation

| File | Change |
|------|--------|
| `C:/Users/User/.claude/commands/modes/*.md` | Same updates as source |

### Documentation

| File | Change |
|------|--------|
| `docs/decisions/DEC-003-automatic-learning-integration.md` | Add reference to DEC-004 |
| `CHANGELOG.md` | Add v1.5.1 entry |
| `README.md` | No change needed (high-level) |

---

## 6. Testing

### Test Case: Mode Activation Token Efficiency

**Before fix:**
```
/modes:analyst
→ Context: 100% → 84% (mode load)
→ User: "Load the learning"
→ Context: 84% → 55% (duplicate load)
→ Total: ~90K tokens
```

**After fix:**
```
/modes:analyst
→ Context: 100% → ~70% (mode load + direct learning read)
→ User sees: "Topic: authentication, Learning: v2..."
→ No need to ask again
→ Total: ~60K tokens (estimated)
```

### Success Criteria

| Criterion | Target |
|-----------|--------|
| Mode activation + learning | ≤60K tokens |
| Learning confirmation visible | 100% of activations |
| No duplicate load requests | 0 occurrences |
| Commands still work | `*learning save/status/note` functional |

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-003-automatic-learning-integration.md | Parent decision (amended) |
| DEC-002-neocortex-methodology.md | Root methodology |
| manage-learning.md | Skill (commands preserved) |

---

*DOC-PROC-004 | Learning Load Optimization | v1.0*
