# RMS-BMAD Methodology Release Notes

This document tracks all changes, decisions, and updates to the RMS-BMAD methodology.

---

## [1.9.0] - 2026-01-24

### Added: Activation Context Optimization

Implemented **pre-computed activation context** to reduce mode awakening context consumption by ~97%. Despite two-tier learning (DEC-007), modes were still reading multiple large files on activation (~36% context). This release consolidates all awakening-time information into a single lightweight file.

#### The Problem

Mode activation was reading 4 separate files:
- `docs/handoff.md` (~1400 lines)
- `.mlda/config.yaml` (~90 lines)
- `.mlda/registry.yaml` (~425 lines)
- `.mlda/learning-index.yaml` (~180 lines)

Total: ~2100 lines (~36% context) before any work begins.

#### The Solution

```
┌─────────────────────────────────────────────────────────────────┐
│  ACTIVATION CONTEXT (single file, ~50-80 lines)                 │
│  - MLDA status (from registry.yaml)                             │
│  - Handoff summary (current phase, ready items, open questions) │
│  - Learning summary (topic counts, highlights)                  │
│  - Config essentials                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (on-demand when needed)
┌─────────────────────────────────────────────────────────────────┐
│  DEEP CONTEXT (loaded only when actively needed)                │
│  - Full docs/handoff.md for phase history                       │
│  - Full .mlda/registry.yaml for DOC-ID lookups                  │
│  - Full topic learning.yaml (Tier 2 from DEC-007)               │
└─────────────────────────────────────────────────────────────────┘
```

#### New Files

| File | Purpose |
|------|---------|
| `.mlda/activation-context.yaml` | Pre-computed activation context |
| `.mlda/schemas/activation-context.schema.yaml` | Validation schema |
| `.mlda/scripts/mlda-generate-activation-context.ps1` | Generation script |

#### Unified Activation Protocol

All modes now follow the same protocol:

```markdown
### Step 1: Load Activation Context
- [ ] Read `.mlda/activation-context.yaml` (single lightweight file)
- [ ] If missing, fall back to individual file reads
- [ ] Report activation summary

### Step 2: Topic Detection & Deep Learning (Tier 2 - AUTOMATIC)
[Same as DEC-007]

### Step 3: Deep Context (ON-DEMAND)
Load full handoff.md, registry.yaml only when actively needed
```

#### Auto-Regeneration

Activation context regenerates automatically when:
- Learning is saved (`*learning save`) - chained from DEC-008
- Handoff is updated (`*handoff`)
- Documents are created (registry update)

#### Performance Improvements

| Scenario | Before | After | Reduction |
|----------|--------|-------|-----------|
| Dev mode awakening | ~2100 lines | ~50-80 lines | ~97% |
| Architect awakening | ~1900 lines | ~50-80 lines | ~96% |
| Analyst awakening | ~700 lines | ~50-80 lines | ~90% |
| File reads on activation | 4 | 1 | 75% |

**Key benefit:** Activation is now O(1) - constant small context regardless of project size.

#### Updated Files

| File | Changes |
|------|---------|
| `analyst.md` | Unified activation protocol |
| `architect.md` | Unified activation protocol |
| `dev.md` | Unified activation protocol |
| `ux-expert.md` | Unified activation protocol |
| `bmad-master.md` | Unified activation protocol |
| `handoff.md` skill | Add activation context regeneration |
| `mlda-generate-index.ps1` | Chain activation context regeneration |
| `.mlda/README.md` | Activation context documentation |
| `CLAUDE.md` (project) | DEC-009 protocol section (v1.9) |
| `CLAUDE.md` (global) | DEC-009 protocol section |

#### Documentation

| Document | Purpose |
|----------|---------|
| `docs/decisions/DEC-009-activation-context-optimization.md` | Full specification |
| `CHANGELOG.md` | Release notes |

#### Backward Compatibility

If `activation-context.yaml` doesn't exist, modes fall back to DEC-007 behavior (individual file reads) with a warning.

---

## [1.8.0] - 2026-01-23

### Added: Two-Tier Learning System

Implemented **context-optimized learning loading** to reduce pre-work context consumption. As projects mature, learning files grow large (60+ KB per topic). This release introduces a two-tier architecture that mirrors human cognition: know what exists (index), retrieve details when needed (full learning).

#### The Problem

Mid-sized projects were consuming ~35% of context before any work began:
- 16 topic learning files totaling ~165 KB
- UI learning alone: 61 KB (15 sessions)
- Significant context spent just to "wake up"

#### The Solution

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (loaded at mode awakening)              │
│  - Lightweight (~5-10 KB total)                                 │
│  - Contains topic summaries and top 3-5 insights per topic      │
│  - Agent "knows what exists" without full context load          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (loaded when topic identified)           │
│  - Complete learning.yaml for active topic only                 │
│  - Auto-triggered by DOC-ID, beads labels, or conversation      │
│  - Full depth available for current work                        │
└─────────────────────────────────────────────────────────────────┘
```

#### New Files

| File | Purpose |
|------|---------|
| `.mlda/learning-index.yaml` | Lightweight index of all topic learnings |
| `.mlda/schemas/learning-index.schema.yaml` | Index validation schema |
| `.mlda/templates/learning-index.yaml` | Template for new projects |
| `.mlda/scripts/mlda-generate-index.ps1` | Index generation script |

#### New Command

| Command | Description |
|---------|-------------|
| `*learning-index` | Regenerate learning index from all topic files |

#### Updated Mode Activation Protocol

All modes now follow this two-tier flow:

```markdown
### Step 2: Learning Index Load
- [ ] Read `.mlda/learning-index.yaml`
- [ ] Report: "Learning index: {n} topics, {total_sessions} sessions"
- [ ] **DO NOT load full learning files yet**

### Step 3: Topic Detection & Deep Learning (AUTOMATIC)
When topic is identified (from task, DOC-ID, conversation, or beads):
- [ ] Read `.mlda/topics/{topic}/learning.yaml`
- [ ] Report: "Deep learning: {topic} (v{n}, {sessions} sessions)"
```

#### Performance Improvements

| Scenario | Before | After | Savings |
|----------|--------|-------|---------|
| Mode awakening (no task) | 35-71 KB | 5-10 KB | ~25-60 KB |
| Simple conversation | All learning loaded | Index only | Significant |
| Topic-specific work | Upfront load | Deferred | Context preserved |

#### Updated Files

| File | Changes |
|------|---------|
| `analyst.md` | Two-tier activation protocol |
| `architect.md` | Two-tier activation protocol |
| `dev.md` | Two-tier activation protocol |
| `ux-expert.md` | Two-tier activation protocol |
| `bmad-master.md` | Two-tier activation protocol |
| `manage-learning.md` | Added `*learning-index` command (v2.1) |
| `.mlda/README.md` | Two-tier learning documentation |
| `CLAUDE.md` (project) | Two-tier protocol section (v1.8) |
| `CLAUDE.md` (global) | Two-tier protocol section (v2.2) |

#### Documentation

| Document | Purpose |
|----------|---------|
| `docs/decisions/DEC-007-two-tier-learning.md` | Full specification |
| `docs/user-guides/learning-system.md` | User guide for learning system |
| `CHANGELOG.md` | Release notes |

#### Backward Compatibility

If `learning-index.yaml` doesn't exist, modes fall back to DEC-004 behavior (load full learning file directly) with a warning.

#### Beads Tracking

- Phase 1 (Documentation): TT-001, TT-002
- Phase 2 (Implementation): TT-010 through TT-014
- Phase 3 (Mode Updates): TT-020 through TT-024
- Phase 4 (Skills/Docs): TT-030 through TT-034

---

## [1.7.0] - 2026-01-21

### Added: Full MLDA Integration for UX-Expert

Implemented **complete Neocortex knowledge graph integration** for UX-Expert (Uma). UX work now participates in the knowledge graph, allowing developers and other agents to navigate to and from UX documentation.

#### Key Features

- **UX Topic Learning**: New `.mlda/topics/ux/` with domain configuration and learning accumulation
- **4 New UX Domains**:
  - `UI` - User Interface (wireframes, component specs, layouts)
  - `DS` - Design System (tokens, patterns, components)
  - `UX` - User Experience (user flows, journey maps, personas)
  - `A11Y` - Accessibility (audits, remediation, guidelines)
- **4 New MLDA Document Commands** in UX-Expert mode:
  - `*create-wireframe-doc` → `.mlda/docs/ui/` with DOC-UI-xxx
  - `*create-design-system-doc` → `.mlda/docs/ds/` with DOC-DS-xxx
  - `*create-flow-doc` → `.mlda/docs/ux/` with DOC-UX-xxx
  - `*create-a11y-report` → `.mlda/docs/a11y/` with DOC-A11Y-xxx
- **MLDA Finalization** added to all UX skills (automatic DOC-ID, sidecar, registry update)

#### New Templates

| Template | Output | DOC-ID |
|----------|--------|--------|
| `wireframe-tmpl.yaml` | MLDA wireframe document | DOC-UI-xxx |
| `design-system-tmpl.yaml` | MLDA design system document | DOC-DS-xxx |
| `user-flow-tmpl.yaml` | MLDA user flow document | DOC-UX-xxx |
| `accessibility-report-tmpl.yaml` | MLDA accessibility report | DOC-A11Y-xxx |

#### Cross-Agent Benefits

Developers can now gather UX context automatically:
```
Story references: DOC-UI-005 (wireframe)
Developer runs: *gather-context
  → Loads wireframe
  → Follows depends-on → DOC-DS-001 (design system)
  → Follows references → DOC-A11Y-002 (accessibility)
  → Full UI context available
```

#### Standardized Relationship Types

| Old | Standard | Signal |
|-----|----------|--------|
| `uses` | `depends-on` | Strong |
| `leads_to` | `extends` | Medium |
| `alternative` | `references` | Weak |

#### Documentation

| Document | Purpose |
|----------|---------|
| `docs/decisions/DEC-006-ux-mlda-integration.md` | Full specification |

---

## [1.6.0] - 2026-01-21

### Added: Extended Workflow with UX Phase and Question Protocol

See DEC-005 for full specification.

---

## [1.5.0] - 2026-01-20

### Added: Automatic Learning Integration

Implemented **automatic topic-based learning integration** across all modes. The learning system infrastructure existed but agents weren't automatically loading and using topic learnings. This release makes learning automatic rather than manual.

#### Key Features

- **Mandatory Activation Protocol**: All modes now have a prescriptive, step-by-step activation protocol that MUST be executed (not just descriptive lists)
- **Automatic Learning Load**: Agents automatically execute `*learning load {topic}` when topic is identified during activation
- **Session Tracking**: All modes now track document access patterns, co-activations, and verification catches during sessions
- **Session End Protocol**: Agents propose saving learnings at session end with tracked patterns
- **Learning Status Command**: New `*learning status` command shows current learning state at any time

#### Updated Modes

| Mode | Key Changes |
|------|-------------|
| `analyst.md` | Mandatory protocol, `*learning` command, session tracking, session end protocol |
| `architect.md` | Mandatory protocol (handoff-first), `*learning` command, session tracking |
| `dev.md` | Mandatory protocol (story DOC-IDs), `*learning` command, session tracking |
| `ux-expert.md` | Added MLDA Enforcement Protocol (was missing), mandatory protocol, session tracking |
| `bmad-master.md` | Complete learning integration (was missing), MLDA protocol, session tracking |

#### Updated Skills

| Skill | Changes |
|-------|---------|
| `manage-learning.md` | Added `*learning status` command with output formats |
| `gather-context.md` | Added prerequisite check for topic learnings before Phase 1 |

#### Activation Protocol Structure

All modes now follow this structure:
1. **Step 1: MLDA Status Check** - Check for `.mlda/` folder, report document count
2. **Step 2: Topic Identification & Learning Load** - Identify topic, execute `*learning load {topic}`
3. **Step 3: Context Gathering** - Run `*gather-context` proactively if task provided
4. **Step 4: Greeting & Ready State** - Greet as persona, display commands, await instructions
5. **Session End Protocol** - Propose saving learnings when session ends

#### Session Tracking Categories

| Category | What to Track |
|----------|--------------|
| Documents Accessed | DOC-IDs loaded or referenced |
| Co-Activations | Documents needed together |
| Verification Catches | Issues discovered in docs |
| Domain-Specific | Architecture patterns, implementation gotchas, etc. |

#### Documentation

| Document | Purpose |
|----------|---------|
| `docs/decisions/DEC-003-automatic-learning-integration.md` | Full specification |
| Updated `docs/USER-GUIDE.md` | User-facing documentation |

#### Beads Tracking

- Epic: Ways of Development-104
- Task 105: bmad-master.md update (closed)
- Task 106: Session tracking mechanism (closed)
- Task 107: Learning status command (closed)
- Task 108: Documentation updates (closed)

---

## [1.4.0] - 2026-01-20

### Added: UX Skills with Neocortex Integration

Converted 4 UX manual workflows to proper skills with full Neocortex integration.

#### New Skills

| Skill | Purpose | Key Features |
|-------|---------|--------------|
| `create-wireframe` | Generate wireframe descriptions | Grid systems, component specs, responsive breakpoints, design system refs |
| `review-accessibility` | WCAG 2.1 compliance audit | Full checklist, severity levels, remediation tracking, traceability |
| `design-system` | Define design system components | Design tokens, component library, governance, versioning |
| `user-flow` | Map user journeys | Entry/exit points, step mapping, error scenarios, Mermaid diagrams |

#### Neocortex Integration

All skills support:
- Context gathering from design system, requirements, and existing patterns
- Topic-based learning integration (`.mlda/topics/{topic}/learning.yaml`)
- DOC-ID references for traceability
- Domain-specific context (DOC-DS-xxx, DOC-UI-xxx, DOC-UF-xxx, DOC-A11Y-xxx)

#### Updated Files

- `.claude/commands/modes/ux-expert.md` - Commands now reference skills
- `.claude/commands/bmad-agents/ux-expert.md` - Updated persona (Uma) and commands
- `.claude/commands/README.md` - Added new skills to quick reference
- `docs/USER-GUIDE.md` - Updated UX-Expert Mode section

#### Validation Script Fix

- Fixed `mlda-validate.ps1` to skip DOC-IDs inside code blocks (fenced and inline)
- Example DOC-IDs in documentation no longer cause false positive validation errors

#### Beads Tracking

- Discussion: Ways of Development-100
- Validation fix: Ways of Development-103

---

## [1.3.0] - 2026-01-17

### Added: Critical Thinking Protocol

Implemented an **always-on critical thinking substrate** for all agents. This is not a skill to invoke—it shapes how agents receive, process, and output information continuously.

#### Key Features

- **Four-layer cognitive model:**
  - Layer 1: Dispositions (accuracy over speed, acknowledge uncertainty, question assumptions)
  - Layer 2: Triggers (automatic deeper analysis for ambiguous/high-stakes tasks)
  - Layer 3: Standards (quality checks before responding)
  - Layer 4: Metacognition (self-monitoring for pattern-matching vs. reasoning)

- **Calibrated uncertainty communication:**
  - "This will..." (high confidence)
  - "This should..." (medium confidence)
  - "This might..." (low confidence)
  - Explicit assumption statements
  - No numeric confidence percentages (research shows poor calibration)

- **Graduated disagreement response:**
  - Mild → Moderate → Significant → Severe levels
  - Proportional to concern level

- **External verification principle:**
  - Agents recommend verification rather than claiming self-assessed correctness
  - Based on research showing LLMs cannot reliably self-correct without external feedback

- **Domain-specific checkpoints:**
  - Requirements analysis, implementation, debugging, refactoring, security

- **Anti-patterns to avoid:**
  - Analysis paralysis, performative hedging, over-questioning
  - Citation theater, false humility, numeric confidence

#### Documentation

| Document | Purpose |
|----------|---------|
| `docs/decisions/DEC-001-critical-thinking-protocol.md` | Full specification (DOC-PROC-001) |
| `docs/testing/critical-thinking-protocol-tests.md` | Test framework (DOC-TEST-001) |
| `CLAUDE.md` | Protocol implementation (Rules layer) |

#### Research Basis

Based on academic research including:
- Google DeepMind ICLR 2024: "LLMs Cannot Self-Correct Reasoning Yet"
- Berkeley 2025: "The Danger of Overthinking"
- ACL 2024: "CriticBench" GQC framework
- Paul-Elder Critical Thinking Framework

#### Beads Tracking

- Epic: Ways of Development-63
- Phases 1-4: Ways of Development-64 through 67
- Documentation: Ways of Development-68 through 70

---

## [1.2.0] - 2026-01-16

Agent command cleanup and architecture template improvements.

### Agent Command Removals

#### Analyst Agent (Maya)
- **Remove `*yolo`** - Causes hallucination and rework; autonomous mode leads to compounding errors in documentation work
- **Remove `*doc-out`** - Unclear use case; document output already handled by create-doc skill

#### Architect Agent (Winston)
- **Remove `*yolo`** - Same reasoning as analyst; critical review requires human checkpoints
- **Create `*create-back-end-architecture`** - New command for back-end architecture documents
- **Remove `*create-full-stack-architecture`** - Full-stack in one document invites monolithic designs; use separate front-end and back-end templates instead

#### Developer Agent (Devon)
- **Remove `*yolo`** - Implementation requires validation at each step
- **Remove `*handoff`** - Redundant; implementation notes already captured in story file updates, commit messages, and PR descriptions

#### BMad Master Agent
- **Remove `*yolo`** - Consistent with other agents
- **Remove `*doc-out`** - Consistent with analyst removal
- **Remove `*shard-doc`** - Use `*split-document` instead for proper MLDA-aware document splitting

### Documentation Updates
- Update CLAUDE.md (global and local) to reflect command changes
- Update USER-GUIDE.md with revised agent commands
- Update all related documentation

### Decisions Log

| Decision | Rationale | Date |
|----------|-----------|------|
| Remove `*yolo` from all agents | Autonomous mode causes hallucination and compounding errors; requires significant rework | 2026-01-16 |
| Remove `*doc-out` | Unclear purpose; create-doc skill handles output | 2026-01-16 |
| Keep `*handoff` for Analyst and Architect | Maintains context across sessions for phase transitions | 2026-01-16 |
| Remove `*handoff` from Developer | Redundant with story file updates | 2026-01-16 |
| Keep brownfield architecture | Useful for less experienced users who need extra guidance | 2026-01-16 |
| Remove full-stack architecture | Separate front-end and back-end forces modular thinking | 2026-01-16 |
| Remove shard-doc, keep split-document | shard-doc is not MLDA-aware; split-document provides proper knowledge graph integration | 2026-01-16 |

---

## [1.1.0] - 2026-01-13

### Changed
- Evolved to 3-role workflow: Analyst, Architect, Developer+QA
- Deprecated PM, PO, SM, QA roles (consolidated into 3 core roles)
- Implemented MLDA Neocortex paradigm for knowledge graph navigation
- Added automatic MLDA integration to document-creating skills

### Added
- Architect critical review of analyst work
- Handoff document protocol for phase transitions
- MLDA auto-initialization skill

---

## [1.0.0] - Initial Release

### Added
- RMS Framework (Rules - Modes - Skills)
- Initial agent personas (PM, PO, SM, Analyst, Architect, Dev, QA, UX Expert)
- MLDA (Modular Linked Documentation Architecture)
- Core skills and templates
- Beads integration for issue tracking

---

*Note: This release notes file should be updated with each methodology change. For global changes, ensure both `~/.claude/` and project-level `.claude/` configurations are updated.*
