# DEC-007: Two-Tier Learning Loading System

**DOC-PROC-007** | Context Optimization for Growing Projects

---

**Status:** Approved
**Date:** 2026-01-23
**Authors:** Human + Claude collaboration
**Related:** DEC-003, DEC-004 (learning system decisions)
**Beads:** Ways of Development-125 (This task)
**Version:** v1.8.0

---

## Executive Summary

As projects mature, topic learning files accumulate content (e.g., UI topic alone reaches 61 KB after 15 sessions). Currently, modes load full learning files during activation, consuming ~35% of context before work begins. This decision introduces a **two-tier loading system** that mirrors human cognition: know what exists (lightweight index), retrieve details when needed (full learning on-demand).

**Key Decision:** Replace eager loading of full learning files with a two-tier approach:
1. **Tier 1:** Load lightweight `learning-index.yaml` on mode awakening (~5-10 KB)
2. **Tier 2:** Auto-load full `learning.yaml` when topic is detected from task/conversation

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Solution Design](#2-solution-design)
3. [Implementation](#3-implementation)
4. [Affected Files](#4-affected-files)
5. [Migration](#5-migration)
6. [Testing](#6-testing)
7. [Rollback Plan](#7-rollback-plan)

---

## 1. Problem Statement

### Observed Behavior

User reported ~35% context consumption before any work begins on a mid-sized project (Tasks app):
- 16 topic learning files totaling ~165 KB
- UI learning alone: 61 KB (15 sessions, 1,242 lines)
- Handoff document: 63 KB
- Mode + rules: ~60 KB

Combined, agents consume significant context just to "wake up" - even when the user wants a simple conversation or to work on an unrelated topic.

### Root Cause

DEC-004 optimized learning loads by using direct file reads instead of skill invocation. However, it still loads the **full learning file** for the identified topic during activation. As projects grow:

| Project Age | Learning Files | Pre-Work Context |
|-------------|----------------|------------------|
| New project | ~5 KB total | ~10% |
| 3 months | ~50 KB total | ~20% |
| 6 months | ~150 KB total | ~35% |
| 1 year | ~300 KB+ total | ~50%+ |

### The Human Analogy

When starting work, humans don't recall every detail of every topic. They:
1. Know what topics/domains exist (mental index)
2. Retrieve specific details when needed (on-demand recall)

Current system loads everything upfront - equivalent to memorizing all documentation before starting any task.

---

## 2. Solution Design

### Two-Tier Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (Auto-loaded on awakening)          │
│  - Lightweight (~5-10 KB total)                             │
│  - Lists all topics with summaries                          │
│  - Contains top 3-5 key insights per topic                  │
│  - Agent "knows what exists"                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (Auto-loaded when topic identified)  │
│  - Complete learning.yaml for active topic only             │
│  - Loaded automatically (no manual command needed)          │
│  - Agent has full depth for current work                    │
└─────────────────────────────────────────────────────────────┘
```

### Learning Index Structure

**Location:** `.mlda/learning-index.yaml`

```yaml
# MLDA Learning Index
# Auto-generated summary of all topic learnings
# Last regenerated: 2026-01-23

version: 1
generated_from: 16 topic learning files
total_sessions: 47

topics:
  UI:
    summary: "Component patterns, accessibility, mobile-first design, 4 breakpoints"
    sessions: 15
    size: "61 KB"
    key_insights:
      - "Bottom sheets require specific touch targets (48px min)"
      - "Always use semantic HTML before ARIA attributes"
      - "Mobile-first: design 320px first, scale up"
    primary_docs: [DOC-UI-001, DOC-UI-002, DOC-DS-001]
    learning_path: .mlda/topics/UI/learning.yaml

  AUTH:
    summary: "Session management, OAuth flow, token refresh patterns"
    sessions: 3
    size: "16 KB"
    key_insights:
      - "Refresh tokens in httpOnly cookies only"
      - "Access tokens: 15 min expiry, refresh: 7 days"
    primary_docs: [DOC-AUTH-001, DOC-AUTH-002]
    learning_path: .mlda/topics/AUTH/learning.yaml

  # ... other topics with same structure

# Topics without learnings (empty stubs)
empty_topics:
  - API
  - DATA
  - INFRA
```

**Size estimate:** 16 topics x ~300 bytes = ~5 KB (vs 165 KB for all full files)

### Auto-Loading Triggers

Tier 2 (full learning) loads automatically when ANY of these occur:

| Trigger | Example | Topic Detected |
|---------|---------|----------------|
| DOC-ID reference in task | Story references `DOC-AUTH-001` | AUTH |
| User mentions topic | "Let's work on authentication" | AUTH |
| Beads task label | Task has label `["auth"]` | AUTH |
| Navigation command | `*explore DOC-GAMIF-001` | GAMIF |

**Multi-topic handling:** If work spans 2+ topics, load both (with warning if combined size exceeds soft threshold of 35K tokens).

---

## 3. Implementation

### 3.1 New Files

#### Schema: `.mlda/schemas/learning-index.schema.yaml`

Defines the structure for learning-index.yaml validation.

#### Template: `.mlda/templates/learning-index.yaml`

Empty template for new projects.

#### Script: `.mlda/scripts/mlda-generate-index.ps1`

PowerShell script to generate/regenerate the learning index from all topic learning files.

```powershell
# Key parameters
param(
    [int]$MaxInsightsPerTopic = 5,
    [switch]$DryRun
)

# Algorithm:
# 1. Scan .mlda/topics/ for all learning.yaml files
# 2. For each topic:
#    - Read learning.yaml
#    - Extract: session_count, file size
#    - Extract top N verification lessons (by recency)
#    - Extract primary_docs from first grouping
#    - Generate summary from domain.yaml description
# 3. Write to .mlda/learning-index.yaml
```

### 3.2 Mode Activation Protocol Changes

**Current (DEC-004):**
```markdown
### Step 2: Topic Identification & Learning Load
- [ ] Identify topic from DOC-IDs, beads labels, or user mention
- [ ] If topic identified, read: `.mlda/topics/{topic}/learning.yaml`
- [ ] Report learning status
```

**New (DEC-007):**
```markdown
### Step 2: Learning Index Load
- [ ] Read `.mlda/learning-index.yaml`
- [ ] Report: "Learning index: {n} topics, {total_sessions} sessions"
- [ ] **DO NOT load full learning files yet**

### Step 3: Topic Detection & Deep Learning (AUTOMATIC)
When topic is identified (from task, DOC-ID, conversation, or beads):
- [ ] Read `.mlda/topics/{topic}/learning.yaml`
- [ ] Report: "Deep learning: {topic} (v{n}, {sessions} sessions)"
- [ ] Apply groupings and activations to context gathering

**Topic identification signals (priority order):**
1. DOC-ID prefix in task/story (strongest signal)
2. Beads task labels
3. Explicit user mention ("working on authentication")
4. Keyword inference (confirm with user if uncertain)
```

### 3.3 New Command: *learning-index

Add to `manage-learning.md` skill:

```markdown
### *learning-index

Regenerate the learning index from all topic files.

**Usage:** `*learning-index regenerate`

**When to use:**
- After significant learning accumulation
- After creating new topics
- If index seems stale (check `generated_at` timestamp)
```

---

## 4. Affected Files

### New Files

| File | Purpose |
|------|---------|
| `.mlda/schemas/learning-index.schema.yaml` | Index validation schema |
| `.mlda/templates/learning-index.yaml` | Template for new projects |
| `.mlda/scripts/mlda-generate-index.ps1` | Index generation script |
| `.mlda/learning-index.yaml` | Generated index (per project) |

### Modified Files

| File | Change |
|------|--------|
| `.claude/commands/modes/analyst.md` | Update activation protocol (Step 2 → index, Step 3 → deep learning) |
| `.claude/commands/modes/architect.md` | Update activation protocol |
| `.claude/commands/modes/dev.md` | Update activation protocol |
| `.claude/commands/modes/ux-expert.md` | Update activation protocol |
| `.claude/commands/modes/bmad-master.md` | Update activation protocol |
| `.claude/commands/skills/manage-learning.md` | Add *learning-index command |
| `.claude/commands/skills/gather-context.md` | Integrate with index (optional) |
| `CLAUDE.md` (project) | Document two-tier protocol |
| `~/.claude/CLAUDE.md` (global) | Document two-tier protocol |

### Documentation

| File | Change |
|------|---------|
| `.mlda/README.md` | Document learning-index.yaml |
| `docs/user-guides/learning-system.md` | User guide for two-tier system |
| `CHANGELOG.md` | v1.8.0 release notes |

---

## 5. Migration

### For Existing Projects

1. **Generate index:** Run `mlda-generate-index.ps1` to create `learning-index.yaml` from existing learning files
2. **Update modes:** Copy updated mode files from source repository
3. **Verify:** Test mode activation loads index, not full learning

### For New Projects

1. **Initialize:** `mlda-init-project.ps1` creates empty `learning-index.yaml`
2. **First learning:** After first session with learnings, regenerate index

### Backward Compatibility

If `learning-index.yaml` doesn't exist:
- Modes fall back to DEC-004 behavior (load full learning file directly)
- Warning displayed: "Learning index not found - using full learning load"

---

## 6. Testing

### Test Cases

| Test | Expected Behavior |
|------|-------------------|
| Mode activation (no task) | Loads index only (~5 KB), reports topic count |
| Mode activation + DOC-ID task | Loads index, then auto-loads topic learning |
| Mode activation + conversation topic | Loads index, detects topic from conversation, loads learning |
| Multi-topic work | Loads index, loads both topic learnings, warns if large |
| Missing index file | Falls back to DEC-004 behavior with warning |

### Success Criteria

| Metric | Target |
|--------|--------|
| Pre-work context (no task) | ≤15% (down from ~35%) |
| Index file size | ≤10 KB |
| Topic auto-detection accuracy | >95% |
| Fallback works | 100% |

### Context Savings Projection

| Scenario | Current | With Two-Tier | Savings |
|----------|---------|---------------|---------|
| Mode awakening (no task) | 35-71 KB | 5-10 KB | ~25-60 KB |
| Working on UI task | 61 KB upfront | 5 KB + 61 KB on-demand | Deferred |
| Working on AUTH task | 16 KB upfront | 5 KB + 16 KB on-demand | Deferred |
| Simple conversation | 35-71 KB | 5-10 KB | ~25-60 KB |

**Key benefit:** Context is deferred until actually needed. Simple conversations and unrelated work don't pay the learning tax.

---

## 7. Rollback Plan

If issues arise after deployment:

1. **Revert mode files** to DEC-004 version (git checkout)
2. **Remove learning-index.yaml** - modes will fall back to direct learning load
3. **Restore previous CLAUDE.md** versions
4. **Document issue** in this decision document (Lessons Learned section)

### Rollback Triggers

- Auto-detection accuracy <80%
- Users frequently need to manually load topics
- Index generation fails consistently
- Performance regression (slower activation)

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-003-automatic-learning-integration.md | Parent decision |
| DEC-004-learning-load-optimization.md | Direct predecessor (amended) |
| DEC-002-neocortex-methodology.md | Root methodology |
| manage-learning.md | Skill (extended with *learning-index) |

---

*DOC-PROC-007 | Two-Tier Learning Loading System | v1.0*
