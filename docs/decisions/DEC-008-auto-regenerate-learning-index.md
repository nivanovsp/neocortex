# DEC-008: Auto-Regenerate Learning Index on Learning Save

**DOC-PROC-008** | Streamlined Learning Workflow

---

**Status:** Approved
**Date:** 2026-01-23
**Authors:** Human + Claude collaboration
**Related:** DEC-007 (two-tier learning system)
**Beads:** Ways of Development-142
**Version:** v1.8.1

---

## Executive Summary

When users instruct an agent to "update the learning" or "save learnings", they expect a single action to update all relevant learning files. Currently, the `learning-index.yaml` (Tier 1) requires separate regeneration after saving to topic `learning.yaml` files (Tier 2). This creates unnecessary friction.

**Key Decision:** Automatically regenerate `learning-index.yaml` after any learning save operation. Users say "update the learning" once, and both files are updated.

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Design](#2-solution-design)
3. [Implementation](#3-implementation)
4. [Affected Files](#4-affected-files)
5. [Testing](#5-testing)
6. [Rollback Plan](#6-rollback-plan)

---

## 1. Problem Statement

### Current Behavior

The two-tier learning system (DEC-007) introduced:
- **Tier 1:** `learning-index.yaml` - lightweight summary loaded at mode awakening
- **Tier 2:** `.mlda/topics/{topic}/learning.yaml` - full learning files loaded on-demand

When saving learnings, only the topic's `learning.yaml` is updated. The index remains stale until manually regenerated via `*learning-index` or the PowerShell script.

### User Expectation

When a user says:
- "Update the learning"
- "Save the learnings"
- "Record what we learned"

They expect **all learning-related files** to be updated. Having to remember a separate command for index regeneration:
1. Creates friction in the workflow
2. Leads to stale indexes
3. Contradicts the principle of single-action updates

### The Fix

Make index regeneration automatic and transparent. One user instruction = complete learning update.

---

## 2. Solution Design

### Updated Workflow

**Current (DEC-007):**
```
User: "Save the learnings"
  │
  ├─► Step 1-3: Gather, present, approve learnings
  ├─► Step 4: Save to learning.yaml
  └─► Done (index NOT updated)
```

**New (DEC-008):**
```
User: "Save the learnings"
  │
  ├─► Step 1-3: Gather, present, approve learnings
  ├─► Step 4: Save to learning.yaml
  ├─► Step 5: Auto-regenerate learning-index.yaml
  └─► Done (both files updated)
```

### Behavior

| Scenario | Current | New |
|----------|---------|-----|
| User saves learnings | `learning.yaml` updated | Both files updated |
| User asks for index regeneration | Explicit `*learning-index` | Still available, but rarely needed |
| Mode awakening | May load stale index | Always loads fresh index |

### Error Handling

If index regeneration fails:
1. Log the error
2. Warn user: "Learning saved, but index regeneration failed. Run `*learning-index` manually."
3. Do NOT fail the learning save operation

---

## 3. Implementation

### 3.1 Update manage-learning.md Skill

**Location:** `.claude/commands/skills/manage-learning.md`

Add Step 5 to "Workflow: Save Session Learnings":

```markdown
### Step 5: Auto-Regenerate Learning Index

After saving to learning.yaml, automatically regenerate the learning index:

```powershell
.\.mlda\scripts\mlda-generate-index.ps1
```

**Agent reports:**
```
Learnings saved to: .mlda/topics/authentication/learning.yaml
Version: 3 → 4
Sessions contributed: 12 → 13

Learning index regenerated: .mlda/learning-index.yaml
  Topics: 16 (12 with learnings, 4 empty)
  Total sessions: 48

Next session will load these learnings automatically.
```

**If regeneration fails:**
```
Learnings saved to: .mlda/topics/authentication/learning.yaml
Version: 3 → 4

⚠ Learning index regeneration failed: [error message]
Run `*learning-index` manually to update the index.
```
```

### 3.2 Update Confirmation Message Template

The save confirmation should now include index status:

**Before:**
```
Learnings saved to: .mlda/topics/authentication/learning.yaml
Version: 3 → 4
Sessions contributed: 12 → 13

Next session will load these learnings automatically when working on authentication tasks.
```

**After:**
```
Learnings saved to: .mlda/topics/authentication/learning.yaml
Version: 3 → 4
Sessions contributed: 12 → 13

Learning index updated: .mlda/learning-index.yaml
  Topics: 16 | Sessions: 48

Next session will load these learnings automatically.
```

### 3.3 Optional: Script Integration

The `mlda-learning.ps1` script could be updated to call `mlda-generate-index.ps1` automatically after save operations. However, since most learning saves are agent-driven (not direct script calls), the primary implementation is in the skill file.

**If script integration is desired:**

```powershell
# At end of save operation in mlda-learning.ps1
if ($saved) {
    Write-Host "Regenerating learning index..."
    & "$PSScriptRoot\mlda-generate-index.ps1" -Quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Learning index updated."
    } else {
        Write-Warning "Index regeneration failed. Run mlda-generate-index.ps1 manually."
    }
}
```

---

## 4. Affected Files

### Modified Files

| File | Change |
|------|--------|
| `.claude/commands/skills/manage-learning.md` | Add Step 5 (auto-regenerate index) |
| `CLAUDE.md` (project) | Update two-tier learning section |
| `~/.claude/CLAUDE.md` (global) | Update two-tier learning section |

### Documentation Updates

| File | Change |
|------|--------|
| `docs/decisions/DEC-008-auto-regenerate-learning-index.md` | This document |
| `CHANGELOG.md` | v1.8.1 release notes |
| `.mlda/README.md` | Note about automatic index regeneration |

### No Changes Required

| File | Reason |
|------|--------|
| `mlda-generate-index.ps1` | Works as-is, just called more frequently |
| `mlda-learning.ps1` | Optional enhancement only |
| Mode files | No activation protocol changes |

---

## 5. Testing

### Test Cases

| Test | Expected Behavior |
|------|-------------------|
| Save learnings via `*learning save` | Both learning.yaml and learning-index.yaml updated |
| Save learnings via script | learning.yaml updated, index optional |
| Index regeneration fails | Learning still saved, warning displayed |
| Multiple topics saved | Index reflects all changes |
| First learning in new topic | Index includes new topic |

### Success Criteria

| Metric | Target |
|--------|--------|
| Index freshness after learning save | Always current |
| User actions to update all learning files | 1 (down from 2) |
| Failed saves due to index issues | 0% (index failure doesn't block save) |

---

## 6. Rollback Plan

If issues arise:

1. **Revert manage-learning.md** to remove Step 5
2. **Restore CLAUDE.md** to previous version
3. **Document issue** in this decision document

### Rollback Triggers

- Index regeneration significantly slows learning saves
- Frequent regeneration failures
- Disk space issues from frequent writes

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-007-two-tier-learning.md | Parent decision (introduces index) |
| DEC-003-automatic-learning-integration.md | Learning system foundation |
| manage-learning.md | Skill (modified) |

---

*DOC-PROC-008 | Auto-Regenerate Learning Index | v1.0*
