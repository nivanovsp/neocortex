# User Guide: RMS, MLDA & BMAD

A comprehensive guide to using the Rules-Modes-Skills framework, Modular Linked Documentation Architecture, and BMAD methodology with Claude Code.

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [RMS Framework](#rms-framework)
4. [MLDA Documentation](#mlda-documentation)
5. [BMAD Methodology](#bmad-methodology)
6. [Common Workflows](#common-workflows)
7. [Command Reference](#command-reference)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### What Are These Frameworks?

| Framework | Purpose | Scope |
|-----------|---------|-------|
| **RMS** | Organize AI assistant behavior | How Claude responds and works |
| **MLDA** | Organize project documentation | How docs are structured and linked |
| **BMAD** | Software development methodology | How projects are built |

### How They Work Together

```
┌─────────────────────────────────────────────────────────────┐
│  RMS Framework (Foundation)                                 │
│  ├── Rules: Universal standards (CLAUDE.md)                 │
│  ├── Modes: Expert personas (architect, qa, dev, etc.)      │
│  └── Skills: Reusable workflows (create-doc, qa-gate, etc.) │
├─────────────────────────────────────────────────────────────┤
│  BMAD Expansion Pack (Built on RMS)                         │
│  ├── Software development roles and workflows               │
│  ├── Document templates for PRDs, architecture, stories     │
│  └── Quality gates and checklists                           │
├─────────────────────────────────────────────────────────────┤
│  MLDA (Documentation Layer)                                 │
│  ├── Modular topic documents instead of monoliths           │
│  ├── DOC-ID linking system                                  │
│  └── Auto-generated indexes and briefs                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### 5-Minute Setup

Your global configuration is already installed at `C:\Users\User\.claude\`. It applies to all projects automatically.

### Your First Mode

1. Start Claude Code in any project
2. Type `/modes:architect` to activate the Architect mode
3. You'll be greeted by Winston, the System Architect
4. Type `*help` to see available commands
5. Type `*exit` when done

### Your First Skill

1. Type `/skills:create-doc` to run the document creation skill
2. Select a template when prompted
3. Follow the interactive workflow

### Your First MLDA Document

1. In a project with MLDA enabled, run:
   ```powershell
   .mlda/scripts/mlda-create.ps1 -Domain API -Title "Authentication Flow"
   ```
2. This creates a topic document with proper DOC-ID and metadata sidecar

---

## RMS Framework

### The Three Layers

#### 1. Rules (Always Active)

Rules are defined in `CLAUDE.md` and apply to every interaction:

- File naming conventions (kebab-case)
- Code style standards
- Communication protocols
- Safety guidelines
- Git conventions
- Beads issue tracking
- MLDA documentation protocol
- **Critical Thinking Protocol** (see below)

**You don't invoke rules** - they're always active.

### Critical Thinking Protocol

All agents operate with an **always-on critical thinking substrate**. This is not a skill to invoke—it shapes how agents receive, process, and output information continuously.

#### The Four Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: DISPOSITIONS (Default Values)                     │
│  • Accuracy over speed                                      │
│  • Acknowledge uncertainty rather than hide it              │
│  • Question assumptions—especially your own                 │
│  • Consider alternatives before complex solutions           │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: TRIGGERS (Automatic Activation)                   │
│  • Ambiguous requirements → Clarify before proceeding       │
│  • Security/auth/data tasks → Maximum scrutiny              │
│  • Multi-file changes → Consider ripple effects             │
│  • "Too easy" solutions → Verify understanding              │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: STANDARDS (Quality Gates)                         │
│  • Clarity: Is this understandable?                         │
│  • Accuracy: Is this correct?                               │
│  • Relevance: Does this solve the actual problem?           │
│  • Completeness: Have I stated assumptions?                 │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: METACOGNITION (Self-Monitoring)                   │
│  • Am I pattern-matching or reasoning?                      │
│  • What's the strongest argument against my direction?      │
│  • If I'm wrong, what's the cost?                           │
└─────────────────────────────────────────────────────────────┘
```

#### Uncertainty Communication

Agents use calibrated language that matches actual certainty:

| Certainty | Language Pattern | Example |
|-----------|------------------|---------|
| **High** | "This will..." | Established facts, verified behavior |
| **Medium** | "This should..." | Reasonable inference |
| **Low** | "This might..." | Filling gaps, uncertain |
| **Assumptions** | "I'm assuming [X]—please verify" | Explicit statements |
| **Gaps** | "I don't have information on [X]" | Honest limits |

**Agents avoid** numeric confidence percentages (e.g., "I'm 90% sure")—research shows these are poorly calibrated.

#### Handling Disagreement

When critical thinking surfaces concerns, agents respond proportionally:

| Level | When | Response |
|-------|------|----------|
| **Mild** | Minor limitation | Implement + brief note |
| **Moderate** | Potential risk | State concern, offer to discuss |
| **Significant** | Meaningful concern | Explain, recommend alternative |
| **Severe** | Fundamental issue | Decline with explanation |

#### What This Means for You

1. **Agents will ask questions** when requirements are ambiguous
2. **Agents will state assumptions** before proceeding
3. **Agents will recommend verification** rather than claiming self-assessed correctness
4. **Agents will express proportional concern** about risky actions

**Full specification:** `docs/decisions/DEC-001-critical-thinking-protocol.md`
**Testing framework:** `docs/testing/critical-thinking-protocol-tests.md`

#### 2. Modes (Expert Personas)

Modes are specialists you summon for specific work:

| Mode | Expert | Use For |
|------|--------|---------|
| `/modes:analyst` | Maya | Requirements, PRDs, epics, stories, user guides, handoff |
| `/modes:architect` | Winston | Critical review, architecture docs, technical refinement |
| `/modes:dev` | Devon | Implementation, testing, quality gates (Dev+QA combined) |
| `/modes:ux-expert` | Uma | UI/UX design, wireframes, accessibility, design systems |
| `/modes:bmad-master` | BMad Master | Multi-domain work, one-off tasks |
| `/modes:bmad-orchestrator` | Oscar | Workflow guidance, mode selection |

**Note:** PM, PO, SM, and QA modes are deprecated (January 2026). Their functionality is now in the 3 core roles above.

**Mode Commands:**
```
*help     - Show available commands for this mode
*exit     - Leave the current mode
```

**Example Session:**
```
You: /modes:architect
Claude: 🏗️ Hello! I'm Winston, your System Architect...
        *help - Show available commands
        [lists commands]

You: *create-backend-architecture
Claude: [Starts architecture document workflow]

You: *exit
Claude: Goodbye! [Returns to normal mode]
```

#### 3. Skills (Discrete Workflows)

Skills are standalone workflows anyone can run:

| Skill | Purpose |
|-------|---------|
| `/skills:create-doc` | Create document from template |
| `/skills:qa-gate` | Create quality gate decision |
| `/skills:execute-checklist` | Run validation checklist |
| `/skills:review-story` | Comprehensive story review |
| `/skills:create-next-story` | Create user story |
| `/skills:advanced-elicitation` | Requirements gathering |
| `/skills:facilitate-brainstorming-session` | Run brainstorming |
| `/skills:document-project` | Document existing codebase |
| `/skills:split-document` | Split monolithic docs into MLDA modules |

**Skills vs Mode Commands:**
- Skills can be run independently without a mode
- Mode commands are shortcuts that invoke skills with context
- Example: In architect mode, `*create-backend-architecture` runs `create-doc` skill with the architecture template

---

## MLDA Documentation

### What is MLDA?

**Modular Linked Documentation Architecture** solves these problems:
- Monolithic documents too large for AI context
- Repeated discussions across sessions
- No relationships between documents
- Outdated comprehensive docs

### Core Concepts

#### Topic Documents
Small, focused documents on single topics instead of large monoliths.

```markdown
# DOC-AUTH-001: Authentication Flow

## Summary
Brief overview of this topic...

## Content
Detailed content here...

## Decisions
- Decision 1: [rationale]
- Decision 2: [rationale]

## Open Questions
- Question needing resolution...
```

#### DOC-ID Convention
Every document gets a unique ID: `DOC-{DOMAIN}-{NNN}`

| Domain | Use For |
|--------|---------|
| AUTH | Authentication & authorization |
| API | API design & endpoints |
| UI | User interface |
| DATA | Data models & storage |
| SEC | Security |
| PERF | Performance |
| INFRA | Infrastructure |

#### Metadata Sidecars
Each topic doc has a `.meta.yaml` companion:

```yaml
doc_id: DOC-AUTH-001
title: Authentication Flow
domain: AUTH
status: draft
related_docs:
  - doc_id: DOC-API-003
    relationship: depends-on
  - doc_id: DOC-SEC-001
    relationship: references
tags: [auth, security, jwt]
```

### MLDA Scripts

Located in `.mlda/scripts/` (project-level):

| Script | Purpose |
|--------|---------|
| `mlda-init-project.ps1` | Initialize MLDA in a new project |
| `mlda-create.ps1` | Create new topic document with DOC-ID |
| `mlda-registry.ps1` | Rebuild document registry |
| `mlda-validate.ps1` | Check link integrity |
| `mlda-brief.ps1` | Regenerate project brief |

### Setting Up MLDA in a Project

#### Option 1: Using init-project (Recommended)

For projects expecting 15+ documents:

```
/modes:analyst
*init-project
```

Or directly: `/skills:init-project`

The skill will:
1. Ask about expected documentation volume
2. Let you select domains (API, AUTH, INV, etc.)
3. Scaffold the complete `.mlda/` structure
4. Copy scripts and templates
5. Initialize the registry

#### Option 2: Manual Setup

1. **Create the structure:**
   ```
   .mlda/
   ├── docs/           # Topic documents by domain
   │   ├── api/
   │   ├── auth/
   │   └── ui/
   ├── scripts/        # MLDA tooling
   ├── templates/      # Document templates
   └── registry.yaml   # Auto-generated index
   ```

2. **Create your first topic:**
   ```powershell
   .mlda/scripts/mlda-create.ps1 -Domain API -Title "REST Endpoints"
   ```

3. **Link documents:**
   - Reference other docs by DOC-ID in content
   - Update `related_docs` in the sidecar

4. **Regenerate indexes:**
   ```powershell
   .mlda/scripts/mlda-registry.ps1
   .mlda/scripts/mlda-brief.ps1
   ```

### Automatic Learning Integration

All modes now **automatically load topic learnings** during activation. This happens without manual intervention:

#### What Happens on Mode Activation

1. **MLDA Status Check** - Agent checks for `.mlda/` folder and reports status
2. **Topic Identification** - Agent identifies topic from:
   - DOC-ID references in task (DOC-AUTH-xxx → authentication)
   - Beads task labels
   - Explicit user mention
3. **Learning Load** - Agent executes `*learning load {topic}` automatically
4. **Context Gathering** - If task provided, runs `*gather-context` proactively

#### Example Activation Output

```
MLDA Status: ✓ Initialized
Documents: 24 | Domains: AUTH, API, SEC, DATA
Last registry update: 2026-01-20

Topic: authentication
Learning: v3, 12 sessions contributed
Groupings: token-management (3 docs), session-handling (2 docs)
Activations: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001] (freq: 7)
Verification note: "Always check compliance markers in token docs"

Hello! I'm Maya, the Business Analyst...
```

#### Session Tracking

During your session, the agent tracks:
- **Documents accessed** - DOC-IDs loaded or referenced
- **Co-activations** - Documents frequently needed together
- **Verification catches** - Issues discovered (ambiguous docs, corrections made)

#### Session End

When ending a session, the agent proposes saving learnings:

```
Session Learnings for topic: authentication

Co-Activations Observed:
- [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001] - authentication work

Verification Notes:
- DOC-AUTH-007 section 3.2: "Ambiguous language clarified"

Save these learnings? [y/n]
```

#### Learning Commands

| Command | Description |
|---------|-------------|
| `*learning load {topic}` | Load learnings for a topic |
| `*learning save` | Propose saving session learnings |
| `*learning status` | Show current learning state |
| `*learning list` | List all available topics |

### Automatic MLDA Integration

When `.mlda/` exists in your project, document-creating commands **automatically integrate**:

| Command | Auto MLDA Behavior |
|---------|-------------------|
| `*create-project-brief` | Creates `.meta.yaml` sidecar, updates registry |
| `*brainstorm` | Creates sidecar for session output |
| `*research` | Creates sidecar for research prompts |
| `*create-prd` | Creates sidecar for PRD document |
| Any `create-doc` | Detects MLDA, creates sidecar, registers doc |

**No manual steps required** - just use mode commands as normal. The agent will:
1. Detect MLDA is active
2. Assign the next DOC-ID
3. Create the sidecar alongside your document
4. Ask about related documents
5. Update the registry

---

## BMAD Methodology

### What is BMAD?

**BMAD** is a software development methodology implemented as an RMS expansion pack. It provides:
- Specialized roles for each phase of development
- Document templates for common artifacts
- Quality gates and checklists
- Workflows for greenfield and brownfield projects

### BMAD Workflow (3-Role Model)

The methodology uses three core roles with clear handoffs:

```
Analyst (Maya) → Architect (Winston) → Developer+QA (Devon)
```

#### Greenfield Project (New)

```
1. Analyst    → Research, Project Brief, PRD, Epics, Stories
               → Handoff to Architect with open questions
2. Architect  → Critical review of analyst docs
               → Architecture documents, technical refinement
               → Handoff to Developer with entry points
3. Dev+QA     → Implementation with test-first approach
               → Quality gates and comprehensive testing
```

#### Brownfield Project (Existing)

```
1. Analyst    → Document existing system, Brownfield PRD
               → Stories for changes
2. Architect  → Review and refine for technical accuracy
               → Brownfield Architecture if needed
3. Dev+QA     → Implementation and testing
```

### Using BMAD

**Start a Greenfield Project:**
```
/modes:analyst
*create-project-brief
*create-prd
*create-epic
*create-story
*handoff           # Creates handoff document for architect
*exit

/modes:architect
*review-docs       # Critical review of analyst work
*create-architecture
*create-front-end-architecture   # If needed
*create-back-end-architecture    # If needed
*handoff           # Creates handoff document for developer
*exit

/modes:dev
*review-story
*create-test-cases
*develop-story
*qa-gate
*exit
```

### BMAD Templates

| Template | Agent | Purpose |
|----------|-------|---------|
| `project-brief-tmpl.yaml` | Analyst | Initial project definition |
| `prd-tmpl.yaml` | PM | Product requirements |
| `architecture-tmpl.yaml` | Architect | System architecture |
| `story-tmpl.yaml` | PO | User stories |
| `qa-gate-tmpl.yaml` | QA | Quality decisions |

### BMAD Checklists

| Checklist | Use When |
|-----------|----------|
| `architect-checklist` | Reviewing architecture docs |
| `pm-checklist` | Reviewing PRDs |
| `po-master-checklist` | Reviewing story readiness |
| `story-draft-checklist` | Before story approval |
| `story-dod-checklist` | Before marking story complete |
| `change-checklist` | Evaluating change impact |

---

## Common Workflows

### Starting a New Project

```
1. /modes:bmad-orchestrator
   *show-workflow greenfield

2. /modes:analyst
   *brainstorm {project-idea}
   *create-project-brief

3. /modes:pm
   *create-prd
   *shard-prd  (if PRD is large)

4. /modes:architect
   *create-fullstack-architecture
   *execute-checklist architect-checklist
```

### Creating and Implementing a Story

```
1. /modes:po
   *create-next-story
   *validate-story

2. /modes:dev
   *develop-story
   [Implement all tasks]
   [Run tests]

3. /modes:qa
   *review {story-id}
   *gate {story-id}
```

### Research and Analysis

```
1. /modes:analyst
   *research {topic}
   [Creates deep research prompt]

2. Use the prompt with web search or deep research tools

3. /modes:analyst
   *perform-market-research
   *create-competitor-analysis
```

### Quality Review

```
1. /modes:qa
   *review {story}           # Comprehensive review
   *test-design {story}      # Create test scenarios
   *trace {story}            # Requirements traceability
   *risk-profile {story}     # Risk assessment
   *gate {story}             # Final gate decision
```

### Documentation with MLDA

```
1. Create topic document:
   .mlda/scripts/mlda-create.ps1 -Domain AUTH -Title "OAuth Flow"

2. Edit the document and sidecar

3. Update registry:
   .mlda/scripts/mlda-registry.ps1

4. Validate links:
   .mlda/scripts/mlda-validate.ps1

5. Regenerate brief:
   .mlda/scripts/mlda-brief.ps1
```

---

## Command Reference

### Global Commands (Always Available)

| Command | Description |
|---------|-------------|
| `/modes:{name}` | Activate a mode |
| `/skills:{name}` | Run a skill |
| `*help` | Show mode commands (when in a mode) |
| `*exit` | Leave current mode |

### Complete Mode Command Reference

Each command below shows exactly which skill and template it uses.

#### Analyst Mode (Mary)

| Command | Skill | Template | Data |
|---------|-------|----------|------|
| `*brainstorm` | `facilitate-brainstorming-session` | `brainstorming-output-tmpl.yaml` | `brainstorming-techniques` |
| `*create-competitor-analysis` | `create-doc` | `competitor-analysis-tmpl.yaml` | - |
| `*create-project-brief` | `create-doc` | `project-brief-tmpl.yaml` | - |
| `*elicit` | `advanced-elicitation` | - | `elicitation-methods` |
| `*init-project` | `init-project` | MLDA scaffolding | - |
| `*market-research` | `create-doc` | `market-research-tmpl.yaml` | - |
| `*research` | `create-deep-research-prompt` | - | - |

#### Architect Mode (Winston)

| Command | Skill | Template | Checklist |
|---------|-------|----------|-----------|
| `*review-docs` | `review-docs` | - | - |
| `*create-architecture` | `create-doc` | `architecture-tmpl.yaml` | - |
| `*create-back-end-architecture` | `create-doc` | `back-end-architecture-tmpl.yaml` | - |
| `*create-brownfield-architecture` | `create-doc` | `brownfield-architecture-tmpl.yaml` | - |
| `*create-front-end-architecture` | `create-doc` | `front-end-architecture-tmpl.yaml` | - |
| `*split-document` | `split-document` | - | - |
| `*validate-mlda` | `validate-mlda` | - | - |
| `*execute-checklist` | `execute-checklist` | - | `architect-checklist` |
| `*handoff` | `handoff` | - | - |
| `*research` | `create-deep-research-prompt` | - | - |

#### PM Mode (John)

| Command | Skill | Template | Checklist |
|---------|-------|----------|-----------|
| `*correct-course` | `correct-course` | - | `change-checklist` |
| `*create-brownfield-epic` | `brownfield-create-epic` | - | - |
| `*create-brownfield-prd` | `create-doc` | `brownfield-prd-tmpl.yaml` | - |
| `*create-brownfield-story` | `brownfield-create-story` | - | - |
| `*create-epic` | `create-doc` | `prd-tmpl.yaml` | - |
| `*create-prd` | `create-doc` | `prd-tmpl.yaml` | `pm-checklist` |
| `*create-story` | `create-doc` | `story-tmpl.yaml` | - |
| `*shard-prd` | `shard-doc` | - | - |

#### PO Mode (Oliver)

| Command | Skill | Template | Checklist |
|---------|-------|----------|-----------|
| `*create-next-story` | `create-next-story` | `story-tmpl.yaml` | - |
| `*validate-story` | `validate-next-story` | - | `story-draft-checklist` |
| `*review-story` | `review-story` | - | - |
| `*execute-checklist` | `execute-checklist` | - | `po-master-checklist` |
| `*prioritize` | Manual workflow | - | - |

#### Dev Mode (James)

| Command | Skill | Template | Checklist |
|---------|-------|----------|-----------|
| `*develop-story` | `validate-next-story` | - | `story-dod-checklist` |
| `*explain` | Manual workflow | - | - |
| `*review-qa` | `apply-qa-fixes` | - | - |
| `*run-tests` | Manual workflow | - | - |

#### QA Mode (Quinn)

| Command | Skill | Template | Data |
|---------|-------|----------|------|
| `*gate` | `qa-gate` | `qa-gate-tmpl.yaml` | - |
| `*nfr-assess` | `nfr-assess` | - | `technical-preferences` |
| `*review` | `review-story` | `qa-gate-tmpl.yaml` | - |
| `*risk-profile` | `risk-profile` | - | - |
| `*test-design` | `test-design` | - | `test-levels-framework`, `test-priorities-matrix` |
| `*trace` | `trace-requirements` | - | - |

#### SM Mode (Scott)

| Command | Skill | Template | Checklist |
|---------|-------|----------|-----------|
| `*create-next-story` | `create-next-story` | `story-tmpl.yaml` | - |
| `*review-story` | `review-story` | - | `story-draft-checklist` |
| `*facilitate-retro` | Manual workflow | - | - |
| `*identify-blockers` | Manual workflow | - | - |

#### UX-Expert Mode (Uma)

| Command | Skill | Template |
|---------|-------|----------|
| `*create-frontend-spec` | `create-doc` | `front-end-spec-tmpl.yaml` |
| `*create-wireframe` | `create-wireframe` | - |
| `*review-accessibility` | `review-accessibility` | - |
| `*design-system` | `design-system` | - |
| `*user-flow` | `user-flow` | - |
| `*gather-context` | `gather-context` | - |
| `*explore` | `mlda-navigate` | - |

#### BMAD-Master Mode (Brian)

| Command | Skill | Templates Available |
|---------|-------|---------------------|
| `*analyze` | `advanced-elicitation` or `facilitate-brainstorming-session` | - |
| `*architect` | `create-doc` | All architecture templates |
| `*develop` | Manual workflow | - |
| `*test` | `qa-gate` | `qa-gate-tmpl.yaml` |
| `*manage` | `create-doc` | All PRD templates |
| `*research` | `create-deep-research-prompt` | - |
| `*create-doc` | `create-doc` | Any template (specify) |
| `*execute-checklist` | `execute-checklist` | Any checklist (specify) |

#### BMAD-Orchestrator Mode (Oscar)

| Command | Type | Purpose |
|---------|------|---------|
| `*recommend-mode` | Orchestration | Suggest best mode for task |
| `*show-workflow` | Orchestration | Display greenfield/brownfield flow |
| `*handoff` | Orchestration | Prepare context for next mode |
| `*status` | Orchestration | Show workflow position |
| `*next-step` | Orchestration | Recommend next action |

### MLDA Scripts

| Script | Usage |
|--------|-------|
| `mlda-init-project.ps1` | `-ProjectPath "path" -Domains INV,API [-Migrate]` |
| `mlda-create.ps1` | `-Domain {DOM} -Title "Title"` |
| `mlda-registry.ps1` | No arguments |
| `mlda-validate.ps1` | No arguments |
| `mlda-brief.ps1` | No arguments |

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
1. Check the file exists: `C:\Users\User\.claude\commands\modes\architect.md`
2. Restart Claude Code to reload configuration
3. Try the full path: `/Users/User/.claude/commands/modes:architect`

### Skill Not Found

**Problem:** `/skills:qa-gate` returns error

**Solutions:**
1. Verify file exists in `commands/skills/`
2. Check spelling matches filename exactly
3. Try legacy path: `/bmad-tasks:qa-gate`

### MLDA Scripts Not Running

**Problem:** PowerShell scripts fail

**Solutions:**
1. Run from project root containing `.mlda/` folder
2. Check execution policy: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
3. Verify scripts have correct line endings (CRLF on Windows)

### Templates Not Found

**Problem:** "Template not found" during create-doc

**Solutions:**
1. Check `.bmad-core/templates/` in your project
2. Or use global templates in `commands/templates/`
3. Specify full path to template if needed

### Mode Commands Not Working

**Problem:** `*help` doesn't respond

**Solutions:**
1. Ensure you're in a mode (look for greeting message)
2. Try re-activating the mode
3. Check mode file has valid YAML structure

---

## Best Practices

### RMS Best Practices

1. **One mode at a time** - Exit before switching modes
2. **Use orchestrator when unsure** - `/modes:bmad-orchestrator` helps choose
3. **Let modes use skills** - Don't bypass mode commands
4. **Rules are sacred** - Don't override global rules in modes

### MLDA Best Practices

1. **Small focused docs** - One topic per document
2. **Link liberally** - Use DOC-IDs to connect related content
3. **Rebuild registry often** - After any doc changes
4. **Validate before commits** - Run mlda-validate.ps1

### BMAD Best Practices

1. **Follow the workflow** - Analyst → PM → Architect → PO → Dev → QA
2. **Complete each phase** - Don't skip to implementation
3. **Use checklists** - They catch common issues
4. **Gate everything** - QA gates are advisory but valuable

---

## Getting Help

- **In a mode:** Type `*help` to see available commands
- **Choosing a mode:** Use `/modes:bmad-orchestrator`
- **Framework docs:** See `commands/README.md`
- **RMS specification:** See `Ways of Development/RMS-Framework.md`
- **MLDA specification:** See `Ways of Development/Phase5-Framework-Synthesis.md`

---

*User Guide v1.5 | RMS + MLDA + BMAD | 2026-01-20*
