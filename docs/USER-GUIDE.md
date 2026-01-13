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

**You don't invoke rules** - they're always active.

#### 2. Modes (Expert Personas)

Modes are specialists you summon for specific work:

| Mode | Expert | Use For |
|------|--------|---------|
| `/modes:analyst` | Mary | Research, brainstorming, project briefs |
| `/modes:architect` | Winston | System design, architecture docs |
| `/modes:pm` | John | PRDs, product strategy, roadmaps |
| `/modes:po` | Oliver | Backlog, stories, acceptance criteria |
| `/modes:dev` | James | Code implementation, debugging |
| `/modes:qa` | Quinn | Testing, quality gates, reviews |
| `/modes:sm` | Scott | Agile process, sprint ceremonies |
| `/modes:ux-expert` | Uma | UI/UX design, wireframes |
| `/modes:bmad-master` | Brian | Multi-domain work, one-off tasks |
| `/modes:bmad-orchestrator` | Oscar | Workflow guidance, mode selection |

**Mode Commands:**
```
*help     - Show available commands for this mode
*exit     - Leave the current mode
*yolo     - Toggle autonomous mode (where supported)
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
| `/skills:shard-doc` | Break document into modules |

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
| `mlda-create.ps1` | Create new topic document with DOC-ID |
| `mlda-registry.ps1` | Rebuild document registry |
| `mlda-validate.ps1` | Check link integrity |
| `mlda-brief.ps1` | Regenerate project brief |

### Setting Up MLDA in a Project

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

---

## BMAD Methodology

### What is BMAD?

**BMAD** is a software development methodology implemented as an RMS expansion pack. It provides:
- Specialized roles for each phase of development
- Document templates for common artifacts
- Quality gates and checklists
- Workflows for greenfield and brownfield projects

### BMAD Workflow

#### Greenfield Project (New)

```
1. Analyst    → Research, Project Brief
2. PM         → PRD (Product Requirements)
3. Architect  → Architecture Document
4. PO         → Epic & Stories
5. Dev        → Implementation
6. QA         → Review & Quality Gate
```

#### Brownfield Project (Existing)

```
1. Analyst    → Document existing system
2. PM         → Brownfield PRD
3. Architect  → Brownfield Architecture
4. PO         → Stories for changes
5. Dev        → Implementation
6. QA         → Review & Quality Gate
```

### Using BMAD

**Start a Greenfield Project:**
```
/modes:analyst
*create-project-brief
[Complete the brief]
*exit

/modes:pm
*create-prd
[Complete the PRD]
*exit

/modes:architect
*create-fullstack-architecture
[Complete architecture]
*exit

/modes:po
*create-next-story
[Create stories]
*exit
```

**Implement a Story:**
```
/modes:dev
*develop-story
[Follow the workflow]
*exit

/modes:qa
*review {story}
[Review creates QA gate]
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
| `*yolo` | Toggle autonomous mode |

### Mode-Specific Commands

#### Analyst Mode
| Command | Description |
|---------|-------------|
| `*brainstorm {topic}` | Facilitate brainstorming |
| `*create-project-brief` | Create project brief |
| `*create-competitor-analysis` | Competitive analysis |
| `*perform-market-research` | Market research |
| `*elicit` | Requirements elicitation |
| `*research {topic}` | Create research prompt |

#### Architect Mode
| Command | Description |
|---------|-------------|
| `*create-backend-architecture` | Backend architecture |
| `*create-frontend-architecture` | Frontend architecture |
| `*create-fullstack-architecture` | Full stack architecture |
| `*create-brownfield-architecture` | Existing system architecture |
| `*document-project` | Document existing code |
| `*execute-checklist` | Run architect checklist |
| `*shard-doc` | Break doc into modules |

#### PM Mode
| Command | Description |
|---------|-------------|
| `*create-prd` | Create PRD |
| `*create-brownfield-prd` | PRD for existing product |
| `*create-epic` | Create epic |
| `*create-story` | Create story |
| `*correct-course` | Course correction |
| `*shard-prd` | Break PRD into modules |

#### Dev Mode
| Command | Description |
|---------|-------------|
| `*develop-story` | Implement story |
| `*run-tests` | Execute tests |
| `*review-qa` | Apply QA fixes |
| `*explain` | Explain what was done |

#### QA Mode
| Command | Description |
|---------|-------------|
| `*review {story}` | Comprehensive review |
| `*gate {story}` | Create quality gate |
| `*test-design {story}` | Create test scenarios |
| `*trace {story}` | Requirements traceability |
| `*risk-profile {story}` | Risk assessment |
| `*nfr-assess {story}` | NFR validation |

### MLDA Scripts

| Script | Usage |
|--------|-------|
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

*User Guide v1.0 | RMS + MLDA + BMAD | 2026-01-12*
