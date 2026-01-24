# DEC-009: Activation Context Optimization

**DOC-PROC-009** | Reduce Pre-Work Context Consumption

---

**Status:** Implemented
**Date:** 2026-01-24
**Authors:** Human + Claude collaboration
**Related:** DEC-007 (two-tier learning), DEC-008 (auto-regenerate index)
**Beads:** N/A
**Version:** v1.9.0

---

## Executive Summary

Despite DEC-007's two-tier learning system, modes still consume ~36% of context before work begins. Investigation reveals:
1. **Inconsistent load order** - Dev/Architect load handoff.md before learning-index.yaml
2. **Full file loading** - handoff.md (1378 lines) and registry.yaml (425 lines) loaded entirely
3. **No selective reading** - Modes read complete files instead of relevant sections

**Key Decision:** Introduce a pre-computed `activation-context.yaml` file (~50 lines) that consolidates all awakening-time information. Modes load ONE small file on activation; deep files (handoff, registry, full learning) loaded only when actively needed.

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

User reported ~36% context consumption on mode activation in a mid-sized project (Tasks app):

```
● Read(docs\handoff.md)           → 1378 lines
● Read(.mlda\config.yaml)         → 90 lines
● Read(.mlda\registry.yaml)       → 425 lines
● Read(.mlda\learning-index.yaml) → 180 lines
```

**Total:** ~2000+ lines read before any work begins.

### Root Causes

#### 1. Inconsistent Load Order Across Modes

| Mode | Step 1 | Step 2 | Step 3 | Step 4 |
|------|--------|--------|--------|--------|
| **Analyst** | registry.yaml | learning-index.yaml | Deep learning | — |
| **Dev** | handoff.md (FULL) | config + registry | learning-index.yaml | Deep learning |
| **Architect** | handoff.md (FULL) | registry | config | learning-index.yaml |

DEC-007 specified learning-index should load at "mode awakening" (early), but Dev/Architect modes load handoff.md first.

#### 2. Full File Loading

**handoff.md:** Contains all phase history, but modes only need:
- Current phase status
- Entry points for this phase
- Open questions

**registry.yaml:** Contains full DOC-ID registry, but activation only needs:
- Document count
- Domain list
- Health status

#### 3. Multiple File Reads

Four separate file reads on activation:
1. handoff.md (if applicable)
2. config.yaml
3. registry.yaml
4. learning-index.yaml

Each read has overhead beyond just the content.

### Context Budget Analysis

| Component | Current Size | Actually Needed at Awakening |
|-----------|--------------|------------------------------|
| handoff.md | ~1400 lines | ~30 lines (current phase summary) |
| registry.yaml | ~425 lines | ~10 lines (status + counts) |
| config.yaml | ~90 lines | ~15 lines (key settings) |
| learning-index.yaml | ~180 lines | ~180 lines (already optimized) |
| **Total** | ~2100 lines | ~235 lines |

**Potential savings:** ~90% reduction in activation context.

---

## 2. Solution Design

### Option A: Unified Activation Context File (Recommended)

Create `.mlda/activation-context.yaml` - a pre-computed file containing everything needed for mode awakening.

```yaml
# .mlda/activation-context.yaml
# Auto-generated on registry/handoff/learning changes
# ~50-80 lines max

generated: 2026-01-24T10:30:00Z
generator_version: 1

# MLDA Status (from registry.yaml)
mlda:
  status: initialized
  doc_count: 47
  domains: [API, UI, SEC, AUTH, DATA]
  orphan_count: 0
  health: healthy
  last_registry_update: 2026-01-23

# Handoff Summary (from docs/handoff.md)
handoff:
  current_phase: development
  current_phase_owner: dev
  ready_items:
    - id: STORY-AUTH-001
      title: "Implement token refresh"
    - id: STORY-UI-003
      title: "Add mobile navigation"
  open_questions:
    - "Token refresh strategy - long-lived vs short-lived?"
    - "Mobile breakpoint at 768px or 640px?"
  entry_points: [DOC-AUTH-001, DOC-AUTH-002, DOC-UI-005]
  phases_completed: [analyst, architect, ux-expert]

# Learning Summary (from learning-index.yaml)
learning:
  topics_total: 11
  topics_with_data: 7
  sessions_total: 41
  recent_topics: [AUTH, UI, TASK]
  # Top 3 insights from most active topics
  highlights:
    - topic: UI
      insight: "Bottom sheets require 48px touch targets"
    - topic: AUTH
      insight: "Refresh tokens in httpOnly cookies only"
    - topic: TASK
      insight: "Use optimistic updates for task completion"

# Config Essentials (from .mlda/config.yaml)
config:
  context_soft_limit: 35000
  context_hard_limit: 50000
  auto_gather_context: true
```

**Size estimate:** ~50-80 lines (~3-5 KB) vs ~2100 lines (~60+ KB)

### Option B: Standardized Load Order + Selective Reading

Keep separate files but:
1. Standardize load order: learning-index → registry summary → handoff section
2. Implement selective reading (read specific YAML sections, not full files)

**Pros:** No new files, less infrastructure
**Cons:** Selective YAML reading is complex, still multiple file reads

### Recommendation: Option A

Option A is preferred because:
1. Single file read reduces I/O overhead
2. Pre-computed = no parsing/extraction at activation time
3. Mode-agnostic (all modes read same file)
4. Clear separation: activation context vs deep context
5. Easier to maintain and debug

---

## 3. Implementation

### 3.1 New Files

#### Schema: `.mlda/schemas/activation-context.schema.yaml`

```yaml
# Validation schema for activation-context.yaml
type: object
required: [generated, mlda, handoff, learning, config]
properties:
  generated:
    type: string
    format: date-time
  generator_version:
    type: integer
  mlda:
    type: object
    required: [status, doc_count, domains]
  handoff:
    type: object
    required: [current_phase, ready_items, entry_points]
  learning:
    type: object
    required: [topics_total, sessions_total]
  config:
    type: object
    required: [context_soft_limit, context_hard_limit]
```

#### Script: `.mlda/scripts/mlda-generate-activation-context.ps1`

```powershell
<#
.SYNOPSIS
    Generates activation-context.yaml from registry, handoff, and learning-index.

.DESCRIPTION
    Consolidates awakening-time information into a single lightweight file.
    Should be run after:
    - Registry updates
    - Handoff updates
    - Learning saves (auto-triggered by DEC-008)

.PARAMETER DryRun
    Show what would be generated without writing.
#>
param(
    [switch]$DryRun,
    [switch]$Quiet
)

# Algorithm:
# 1. Read registry.yaml → extract status, counts, domains
# 2. Read handoff.md → extract current phase, ready items, open questions
# 3. Read learning-index.yaml → extract topic counts, highlights
# 4. Read config.yaml → extract key settings
# 5. Combine into activation-context.yaml
```

### 3.2 Mode Activation Protocol Changes

**Current (varies by mode):**
```markdown
### Step 1: [Varies - Handoff or Registry]
### Step 2: [Varies - Config, Registry, or Learning]
### Step 3: [Varies - Learning Index]
### Step 4: [Deep Learning]
```

**New (unified across ALL modes):**
```markdown
## Activation Protocol (MANDATORY)

When this mode is invoked, execute these steps IN ORDER:

### Step 1: Load Activation Context
- [ ] Read `.mlda/activation-context.yaml` (single lightweight file)
- [ ] If missing, fall back to individual file reads (DEC-007 behavior)
- [ ] Report activation summary using format below

**Report format:**
```
MLDA: ✓ {doc_count} docs | Domains: {domains}
Phase: {current_phase} | Ready: {ready_item_count} items
Learning: {topics_total} topics, {sessions_total} sessions
```

**Example:**
```
MLDA: ✓ 47 docs | Domains: API, UI, SEC, AUTH
Phase: development | Ready: 3 items
Learning: 11 topics, 41 sessions
```

### Step 2: Topic Detection & Deep Learning (Tier 2 - AUTOMATIC)
[Same as DEC-007 - load full learning.yaml when topic identified]

### Step 3: Deep Context (ON-DEMAND)
When specific context is needed:
- [ ] Read full `docs/handoff.md` for phase history
- [ ] Read full `.mlda/registry.yaml` for DOC-ID lookups
- [ ] Execute `*gather-context` for comprehensive MLDA traversal

**Important:** Deep context is loaded ONLY when actively needed for a task,
not preemptively during activation.
```

### 3.3 Auto-Regeneration Triggers

Integrate with existing DEC-008 auto-regeneration:

| Event | Regenerate activation-context.yaml? |
|-------|-------------------------------------|
| Learning save (`*learning save`) | Yes (already triggers index regen) |
| Handoff update (`*handoff`) | Yes (new trigger) |
| Registry update (doc creation) | Yes (new trigger) |
| Config change | Yes (new trigger) |

**Integration point:** Add to `mlda-generate-index.ps1`:

```powershell
# After regenerating learning-index.yaml, also regenerate activation-context.yaml
if (-not $SkipActivationContext) {
    & "$PSScriptRoot\mlda-generate-activation-context.ps1" -Quiet
}
```

### 3.4 Handoff Skill Update

Update `handoff.md` skill to regenerate activation context after handoff updates:

```markdown
### Step N: Regenerate Activation Context

After updating handoff document:
```powershell
.\.mlda\scripts\mlda-generate-activation-context.ps1
```

This ensures next mode activation has current phase context.
```

---

## 4. Affected Files

### New Files

| File | Purpose |
|------|---------|
| `.mlda/activation-context.yaml` | Pre-computed activation context (per project) |
| `.mlda/schemas/activation-context.schema.yaml` | Validation schema |
| `.mlda/scripts/mlda-generate-activation-context.ps1` | Generation script |

### Modified Files

| File | Change |
|------|--------|
| `.claude/commands/modes/analyst.md` | Unified activation protocol (Step 1 → activation-context) |
| `.claude/commands/modes/architect.md` | Unified activation protocol |
| `.claude/commands/modes/dev.md` | Unified activation protocol |
| `.claude/commands/modes/ux-expert.md` | Unified activation protocol |
| `.claude/commands/modes/bmad-master.md` | Unified activation protocol |
| `.claude/commands/skills/handoff.md` | Add activation context regeneration |
| `.mlda/scripts/mlda-generate-index.ps1` | Chain activation context regeneration |
| `CLAUDE.md` (project) | Document activation context optimization |
| `~/.claude/CLAUDE.md` (global) | Document activation context optimization |

### Documentation

| File | Change |
|------|--------|
| `.mlda/README.md` | Document activation-context.yaml |
| `CHANGELOG.md` | v1.9.0 release notes |

---

## 5. Migration

### For Existing Projects

1. **Generate activation context:**
   ```powershell
   .\.mlda\scripts\mlda-generate-activation-context.ps1
   ```

2. **Update modes:** Copy updated mode files from source repository

3. **Verify:** Test mode activation loads activation-context.yaml

### For New Projects

1. **Initialize:** `mlda-init-project.ps1` generates empty activation-context.yaml
2. **After first handoff:** Activation context auto-regenerated

### Backward Compatibility

If `activation-context.yaml` doesn't exist:
- Modes fall back to DEC-007 behavior (individual file reads)
- Warning displayed: "Activation context not found - using individual file reads"

---

## 6. Testing

### Test Cases

| Test | Expected Behavior |
|------|-------------------|
| Mode activation (fresh project) | Loads activation-context.yaml (~50 lines), reports summary |
| Mode activation (no activation-context) | Falls back to individual reads with warning |
| Handoff update | Activation context regenerated automatically |
| Learning save | Activation context regenerated automatically |
| Registry update (doc creation) | Activation context regenerated automatically |
| Stale activation context | Displays warning if generated >24h ago |

### Success Criteria

| Metric | Current | Target |
|--------|---------|--------|
| Pre-work context (activation) | ~36% (~2100 lines) | ~5% (~200 lines) |
| File reads on activation | 4 | 1 |
| Activation context file size | N/A | ≤100 lines |
| Fallback works | N/A | 100% |

### Context Savings Projection

| Scenario | Current | With DEC-009 | Savings |
|----------|---------|--------------|---------|
| Dev mode awakening | 2100 lines | 50-80 lines | ~97% |
| Architect mode awakening | 1900 lines | 50-80 lines | ~96% |
| Analyst mode awakening | 700 lines | 50-80 lines | ~90% |
| Any mode + topic work | +topic learning | Same | No change |

**Key benefit:** Activation is now O(1) - constant small context regardless of project size. Deep context loaded only when needed.

---

## 7. Rollback Plan

If issues arise:

1. **Revert mode files** to DEC-007 version (git checkout)
2. **Remove activation-context.yaml** - modes fall back to individual reads
3. **Restore previous CLAUDE.md** versions
4. **Document issue** in this decision document

### Rollback Triggers

- Activation context frequently stale (auto-regen not triggering)
- Information loss (critical data not in activation context)
- Parsing issues with YAML structure
- Performance regression (generation slower than direct reads)

---

## 8. Future Considerations

### Phase 2: Selective Deep Reading

If Option A proves successful, consider adding selective reading for deep files:

```yaml
# In activation-context.yaml
deep_context:
  handoff:
    current_phase_offset: 847  # Line number for quick seek
    current_phase_length: 120
  registry:
    lookup_offset: 50  # Start of DOC-ID entries
```

This would enable reading only relevant sections when deep context is needed.

### Phase 3: Context Prediction

Use learning data to predict which deep context will be needed:

```yaml
predictions:
  likely_topics: [AUTH, UI]  # Based on ready_items
  likely_docs: [DOC-AUTH-001, DOC-UI-005]  # Based on entry_points
```

Pre-warm cache for predicted documents.

---

## References

| Document | Relationship |
|----------|--------------|
| DEC-007-two-tier-learning.md | Parent decision (two-tier architecture) |
| DEC-008-auto-regenerate-learning-index.md | Auto-regeneration pattern |
| DEC-004-learning-load-optimization.md | Earlier optimization attempt |

---

*DOC-PROC-009 | Activation Context Optimization | v1.0*
