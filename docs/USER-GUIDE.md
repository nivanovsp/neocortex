# Neocortex User Guide

A comprehensive guide to the Neocortex methodology for AI-assisted software development.

**Version:** 2.4.0
**Date:** 2026-01-26

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [RMS Framework](#rms-framework)
4. [5-Phase Workflow](#5-phase-workflow)
5. [MLDA & Knowledge Graph](#mlda--knowledge-graph)
6. [Context Optimization](#context-optimization)
7. [Topic-Based Learning](#topic-based-learning)
8. [Multi-Agent Scaling](#multi-agent-scaling)
9. [Command Reference](#command-reference)
10. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Neocortex?

Neocortex treats documentation as a **knowledge graph** that agents navigate to gather context. Built on the **RMS** (Rules - Modes - Skills) framework.

```
Documentation = Knowledge Graph

Documents → Neurons (units of knowledge)
Relationships → Dendrites (connections)
DOC-IDs → Axons (unique identifiers)
Agent reading → Signal activation
Following relationships → Signal propagation
```

**Key Principle:** Tasks are entry points into the knowledge graph, not self-contained specs. Agents navigate to gather context.

### Framework Stack

```
┌─────────────────────────────────────────────────────────────┐
│  RMS Framework (Foundation)                                 │
│  ├── Rules: Universal standards (CLAUDE.md)                 │
│  ├── Modes: Expert personas (analyst, architect, dev, etc.) │
│  └── Skills: Reusable workflows (create-doc, qa-gate, etc.) │
├─────────────────────────────────────────────────────────────┤
│  MLDA (Documentation Layer)                                 │
│  ├── Modular topic documents instead of monoliths           │
│  ├── DOC-ID linking system                                  │
│  └── Knowledge graph navigation                             │
├─────────────────────────────────────────────────────────────┤
│  Neocortex (Intelligence Layer)                             │
│  ├── Context gathering and optimization                     │
│  ├── Topic-based learning across sessions                   │
│  └── Multi-agent scaling for large contexts                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Your First Mode

1. Start Claude Code in any project
2. Type `/modes:architect` to activate the Architect mode
3. You'll be greeted by Winston, the System Architect
4. Type `*help` to see available commands
5. Type `*exit` when done

### Your First Skill

```
/skills:create-doc
```
Select a template when prompted and follow the interactive workflow.

### Your First MLDA Document

```powershell
.mlda/scripts/mlda-create.ps1 -Domain API -Title "Authentication Flow"
```

This creates a topic document with DOC-ID and metadata sidecar.

---

## RMS Framework

### The Three Layers

| Layer | Location | Purpose | Invocation |
|-------|----------|---------|------------|
| **Rules** | `CLAUDE.md` | Universal standards (always active) | Automatic |
| **Modes** | `commands/modes/` | Expert personas | `/modes:analyst` |
| **Skills** | `commands/skills/` | Discrete workflows | `/skills:create-doc` |

### Modes (Expert Personas)

| Mode | Expert | Use For |
|------|--------|---------|
| `/modes:analyst` | Maya | Requirements, PRDs, epics, stories, handoff |
| `/modes:architect` | Winston | Critical review, architecture docs, technical refinement |
| `/modes:dev` | Devon | Implementation, testing, quality gates (Dev+QA combined) |
| `/modes:ux-expert` | Uma | UI/UX design, wireframes, accessibility, design systems |
| `/modes:bmad-master` | BMad Master | Multi-domain work, one-off tasks |
| `/modes:bmad-orchestrator` | Oscar | Workflow guidance, mode selection |

**Deprecated Modes (January 2026):** PM, PO, SM, QA - functionality consolidated into analyst and dev modes.

**Note (v2.4.0):** All modes are now in a single location: `.claude/commands/modes/`. The duplicate `bmad-agents/` folder has been removed.

### Skills (Discrete Workflows)

| Skill | Purpose |
|-------|---------|
| `/skills:create-doc` | Create document from template |
| `/skills:gather-context` | Navigate knowledge graph |
| `/skills:manage-learning` | Save/load topic learnings |
| `/skills:handoff` | Generate phase transition document |
| `/skills:qa-gate` | Create quality gate decision |
| `/skills:init-project` | Initialize project with MLDA |

### Mode Commands

Once in a mode:
```
*help     - Show available commands
*exit     - Leave current mode
*explore  - Navigate from a DOC-ID
*related  - Show related documents
*context  - Display gathered context
```

### Critical Thinking Protocol

All agents operate with an **always-on critical thinking substrate**:

| Layer | Purpose |
|-------|---------|
| **Dispositions** | Accuracy over speed, acknowledge uncertainty, question assumptions |
| **Triggers** | Automatic deeper analysis for ambiguous/security/multi-file tasks |
| **Standards** | Quality checks: clarity, accuracy, relevance, completeness |
| **Metacognition** | Self-monitoring for pattern-matching vs. reasoning |

**Uncertainty Language:**
- High confidence: "This will..."
- Medium: "This should..."
- Low: "This might..."
- Assumptions: "I'm assuming [X]—please verify"

---

## 5-Phase Workflow

```
┌──────────┐     ┌───────────┐     ┌───────────┐     ┌──────────┐     ┌───────────┐
│ Analyst  │ ──► │ Architect │ ──► │ UX-Expert │ ──► │ Analyst  │ ──► │ Developer │
│ (Maya)   │     │ (Winston) │     │ (Uma)     │     │ (stories)│     │ (Devon)   │
└──────────┘     └───────────┘     └───────────┘     └──────────┘     └───────────┘
```

| Phase | Role | Mode | Purpose |
|-------|------|------|---------|
| 1 | **Analyst** | `/modes:analyst` | Requirements, PRDs, epics |
| 2 | **Architect** | `/modes:architect` | Critical review, architecture docs |
| 3 | **UX-Expert** | `/modes:ux-expert` | UI/UX design, wireframes, design system |
| 4 | **Analyst** | `/modes:analyst` | Stories from UX specs |
| 5 | **Developer** | `/modes:dev` | Implementation, test-first, quality gates |

Each phase hands off via `docs/handoff.md` with **open questions** for the next role.

### Greenfield Project Flow

```
Phase 1: /modes:analyst
  *create-project-brief
  *create-prd
  *handoff  → Open questions for Architect

Phase 2: /modes:architect
  *review-docs
  *create-architecture
  *handoff  → Open questions for UX-Expert

Phase 3: /modes:ux-expert
  *create-wireframe-doc
  *create-design-system-doc
  *handoff  → Open questions for Analyst

Phase 4: /modes:analyst
  *create-next-story  (from UX specs)
  *handoff  → Stories ready for Developer

Phase 5: /modes:dev
  *review-story
  *create-test-cases
  *develop-story
  *qa-gate
```

---

## MLDA & Knowledge Graph

### Core Concepts

**MLDA** (Modular Linked Documentation Architecture) implements the knowledge graph:

| Concept | Description |
|---------|-------------|
| **Topic Documents** | Small, focused docs on single topics |
| **DOC-IDs** | Unique identifiers: `DOC-{DOMAIN}-{NNN}` |
| **Sidecars** | `.meta.yaml` companions with relationships |
| **Registry** | Auto-generated index of all documents |

### DOC-ID Domains

| Domain | Use For |
|--------|---------|
| AUTH | Authentication & authorization |
| API | API design & endpoints |
| UI | User interface (wireframes) |
| DS | Design system |
| UX | User flows, journeys |
| A11Y | Accessibility |
| DATA | Data models & storage |
| SEC | Security |

### Relationship Types

| Type | Signal | When Agent Follows |
|------|--------|-------------------|
| `depends-on` | **Strong** | Always - cannot understand without target |
| `extends` | **Medium** | If depth allows - adds detail |
| `references` | **Weak** | If relevant to current task |
| `supersedes` | **Redirect** | Follow this instead of target |

### Metadata Sidecar

Each topic doc has a `.meta.yaml` companion:

```yaml
id: DOC-AUTH-001
title: Authentication Flow
domain: AUTH
status: active

related:
  - id: DOC-API-003
    type: depends-on
    why: "Auth endpoints defined here"
  - id: DOC-SEC-001
    type: references
    why: "Security baseline"
```

### MLDA Scripts

| Script | Purpose |
|--------|---------|
| `mlda-create.ps1` | Create new topic document |
| `mlda-registry.ps1` | Rebuild document registry |
| `mlda-validate.ps1` | Check link integrity |
| `mlda-generate-index.ps1` | Generate learning index |

**Deprecated:** `mlda-generate-activation-context.ps1` - no longer used (see DEC-JAN-26).

---

## Context Optimization

### Two-Tier Learning System (DEC-007)

As projects grow, learning files can become large (60+ KB per topic). The two-tier system optimizes context:

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (loaded on mode awakening)              │
│  - Lightweight (~5-10 KB total)                                 │
│  - Contains topic summaries and top insights                    │
│  - Agent "knows what exists"                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (loaded when topic identified)           │
│  - Complete learning.yaml for active topic only                 │
│  - Full depth available for current work                        │
└─────────────────────────────────────────────────────────────────┘
```

**Auto-Regeneration (DEC-008):** When you save learnings via `*learning save`, the learning index is automatically regenerated.

### Simplified Activation Protocol (DEC-JAN-26)

Mode activation uses a simple 4-step flow with native beads integration:

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Learning Index (~30 lines)                             │
│  Read .mlda/learning-index.yaml                                 │
│  Agent knows what topics exist, top insights                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Beads Check (~10 lines)                                │
│  Run: bd ready --json                                           │
│  Agent shows pending tasks by priority                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: Greet & Ready State                                    │
│  Report status, await instructions                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (ON-DEMAND when task selected)
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: Deep Context (only when needed)                        │
│  - Topic learning.yaml                                          │
│  - Relevant handoff section (not full file)                     │
│  - Registry lookups for DOC-IDs                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Context Savings:**
| Scenario | Before | After DEC-JAN-26 | Reduction |
|----------|--------|------------------|-----------|
| Mode awakening | ~1900 lines | ~40 lines | ~98% |

### Context Thresholds

| Threshold | Tokens | Documents | Action |
|-----------|--------|-----------|--------|
| **Soft** | 35,000 | 8 | Self-assess, consider decomposition |
| **Hard** | 50,000 | 12 | Must decompose or pause |

---

## Topic-Based Learning

Learning persists across sessions, making each session smarter than the last.

### Session Workflow

```
1. Session starts (minimal context)
2. User selects task (e.g., "Let's work on AUTH-003")
3. Agent identifies topic from DOC-ID prefix
4. Agent loads: .mlda/topics/authentication/learning.yaml
5. Work proceeds with topic context
6. Session ends: Agent proposes saving new learnings
```

### What Gets Learned

| Learning Type | Example | How It Helps |
|---------------|---------|--------------|
| **Groupings** | "token-management" = [AUTH-002, AUTH-003] | Agent knows which docs belong together |
| **Activations** | AUTH-001 + SEC-001 used together 7 times | Agent loads them together automatically |
| **Verification Notes** | "Check compliance markers in token docs" | Agent watches for issues caught before |

### Learning Commands

| Command | Description |
|---------|-------------|
| `*learning status` | Show current learning state |
| `*learning save` | Propose saving session learnings |
| `*learning load {topic}` | Load learnings for a topic |
| `*learning list` | List all available topics |

### Example: Session End

```
Agent: This session covered authentication tasks.

## Session Learnings Proposed

### New Co-Activation Pattern
Documents accessed together: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Task type: implementing
Save this pattern? [y/n]

### Verification Note
Caught: GDPR consent requirement in OAuth flow
Lesson: "Check GDPR markers when working with OAuth user data"
Save this note? [y/n]

Proceed with save? [y/n/modify]
```

---

## Multi-Agent Scaling

When context grows too large, agents can decompose work across sub-agents.

### When It Happens

```
Agent: ⚠ CONTEXT THRESHOLD REACHED

Documents: 14 (limit: 12)
Estimated tokens: 52,000 (limit: 50,000)

Options:
1. **Spawn sub-agents** for sub-domains (recommended)
   - Token management: 4 docs
   - Session handling: 3 docs
   - OAuth integration: 4 docs

2. **Progressive summarization**

3. **Pause and ask**

Which approach would you like? [1/2/3]
```

### Verification Stack

Six layers ensure sub-agent summaries don't miss critical information:

| Layer | Status | Purpose |
|-------|--------|---------|
| 1. Structured Extraction | Mandatory | Template-driven, not open summarization |
| 2. Critical Markers | Mandatory | `<!-- CRITICAL -->` always extracted verbatim |
| 3. Confidence Self-Assessment | Mandatory | Report uncertainty, recommend reviews |
| 4. Provenance Tracking | Mandatory | Every claim traces to source |
| 5. Cross-Verification | Optional | Two sub-agents compare outputs |
| 6. Verification Pass | Optional | Primary spot-checks suspicious absences |

### Critical Markers

Mark critical information in documents:

```markdown
<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS 8.1.8.
<!-- /CRITICAL -->
```

**Marker types:** `compliance`, `security`, `breaking`, `dependency`

---

## Command Reference

### Global Commands

| Command | Description |
|---------|-------------|
| `/modes:{name}` | Activate a mode |
| `/skills:{name}` | Run a skill |
| `*help` | Show mode commands |
| `*exit` | Leave current mode |

### Analyst Mode (Maya)

| Command | Description |
|---------|-------------|
| `*brainstorm` | Facilitate brainstorming session |
| `*create-project-brief` | Create project brief |
| `*create-prd` | Create product requirements document |
| `*create-epic` | Create epic |
| `*create-next-story` | Create user story |
| `*elicit` | Advanced requirements elicitation |
| `*research` | Create deep research prompt |
| `*handoff` | Generate handoff document |
| `*init-project` | Initialize MLDA in project |

### Architect Mode (Winston)

| Command | Description |
|---------|-------------|
| `*review-docs` | Critical review of analyst work |
| `*create-architecture` | Create architecture document |
| `*create-front-end-architecture` | Front-end architecture |
| `*create-back-end-architecture` | Back-end architecture |
| `*split-document` | Split monolithic doc into MLDA modules |
| `*validate-mlda` | Validate MLDA integrity |
| `*handoff` | Generate handoff document |

### Developer Mode (Devon)

| Command | Description |
|---------|-------------|
| `*review-story` | Review story before implementing |
| `*create-test-cases` | Create test cases for story |
| `*develop-story` | Execute story implementation |
| `*write-tests` | Write unit/integration tests |
| `*run-tests` | Execute all tests |
| `*qa-gate` | Quality gate decision |
| `*handoff` | Update handoff with implementation notes |

### UX-Expert Mode (Uma)

**Quick Commands:**
| Command | Description |
|---------|-------------|
| `*create-wireframe` | Generate wireframe description |
| `*design-system` | Define design system components |
| `*user-flow` | Map user journeys |
| `*review-accessibility` | WCAG compliance audit |

**MLDA Document Commands:**
| Command | Output DOC-ID |
|---------|---------------|
| `*create-wireframe-doc` | DOC-UI-xxx |
| `*create-design-system-doc` | DOC-DS-xxx |
| `*create-flow-doc` | DOC-UX-xxx |
| `*create-a11y-report` | DOC-A11Y-xxx |

### Navigation Commands (All Modes)

| Command | Description |
|---------|-------------|
| `*explore {DOC-ID}` | Navigate from a specific document |
| `*related` | Show documents related to current context |
| `*context` | Display gathered context summary |
| `*gather-context` | Full context gathering workflow |
| `*learning {cmd}` | Manage topic learnings |

### MLDA Scripts

| Script | Usage |
|--------|-------|
| `mlda-init-project.ps1` | `-Domains API,AUTH [-Migrate]` |
| `mlda-create.ps1` | `-Domain AUTH -Title "OAuth Flow"` |
| `mlda-registry.ps1` | No args, or `-Graph` |
| `mlda-validate.ps1` | No args |
| `mlda-generate-index.ps1` | No args |

### Beads Commands

| Command | Description |
|---------|-------------|
| `bd init` | Initialize beads in project |
| `bd ready` | Show unblocked tasks |
| `bd create "desc" -t task -p 1` | Create issue |
| `bd update {id} --status in_progress` | Update status |
| `bd close {id} --reason "Done"` | Close issue |
| `bd stats` | Project overview |

---

## Troubleshooting

### Mode Not Activating

**Problem:** `/modes:architect` doesn't work

**Solutions:**
1. Check the file exists in `commands/modes/`
2. Restart Claude Code to reload configuration
3. Verify YAML frontmatter is valid

### Context Not Loading

**Problem:** "No entry points found"

**Solutions:**
1. Check story has DOC-ID references
2. Verify registry is current: `.\.mlda\scripts\mlda-registry.ps1`
3. Manually specify entry point: `*explore DOC-AUTH-001`

### Learning Not Persisting

**Problem:** Agent doesn't remember patterns from last session

**Solutions:**
1. Verify learning was saved: check `.mlda/topics/{topic}/learning.yaml`
2. Ensure topic was correctly identified (check DOC-ID domain prefix)
3. Manual load: `*learning load {topic}`

### Mode Activation Reading Too Many Files

**Problem:** Mode activation is slow or reads handoff.md/registry.yaml at startup

**Solutions:**
1. Update to latest mode files (v2.3+) with simplified activation protocol
2. Ensure `.mlda/learning-index.yaml` exists (generated by `*learning save`)
3. Mode should only read learning-index.yaml and check beads on activation
4. Full files are loaded ON-DEMAND when you select a task

### MLDA Scripts Not Running

**Problem:** PowerShell scripts fail

**Solutions:**
1. Run from project root containing `.mlda/` folder
2. Check execution policy: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
3. Verify scripts have correct line endings (CRLF on Windows)

---

## Configuration

### .mlda/config.yaml

```yaml
version: "2.0"

context_limits:
  soft_threshold_tokens: 35000
  hardstop_tokens: 50000
  soft_threshold_documents: 8
  hardstop_documents: 12

learning:
  auto_save_prompt: true
  activation_logging: true

verification:
  cross_verification_domains: [security, compliance]
  critical_marker_syntax: "<!-- CRITICAL: {type} -->"
```

---

## References

| Document | Purpose |
|----------|---------|
| [NEOCORTEX.md](NEOCORTEX.md) | Full methodology specification |
| [.mlda/README.md](../.mlda/README.md) | MLDA quick start |
| [DEC-007](decisions/DEC-007-two-tier-learning.md) | Two-tier learning system |
| [DEC-008](decisions/DEC-008-auto-regenerate-learning-index.md) | Auto-regenerate index |
| [DEC-009](decisions/DEC-009-activation-context-optimization.md) | Activation context optimization (deprecated) |
| [DEC-JAN-26](decisions/DEC-JAN-26-simplified-activation-protocol.md) | Simplified activation protocol |
| [release-notes.md](release-notes.md) | Version history |

---

*Neocortex User Guide v2.4.0 | 2026-01-26*
