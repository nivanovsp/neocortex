# RMS Framework - Global Configuration

**Rules - Modes - Skills**

This directory contains your global AI assistant configuration following the RMS methodology.

## Structure

```
.claude/
├── CLAUDE.md              # Rules Layer (always active)
└── commands/
    ├── modes/             # Expert personas
    ├── skills/            # Discrete workflows
    ├── checklists/        # Validation checklists
    ├── templates/         # Document templates
    └── data/              # Reference data
```

## Quick Reference

### Invoking Modes

Modes are expert personas you can activate for specialized work:

| Command | Mode | Expert |
|---------|------|--------|
| `/modes:analyst` | Business Analyst | Maya |
| `/modes:architect` | System Architect | Winston |
| `/modes:dev` | Developer + QA | Devon |
| `/modes:ux-expert` | UX/UI Expert | Uma |
| `/modes:bmad-master` | BMAD Master | Brian |
| `/modes:bmad-orchestrator` | Workflow Orchestrator | Oscar |

**Deprecated (Jan 2026):** `/modes:pm`, `/modes:po`, `/modes:sm`, `/modes:qa` - use `/modes:analyst` or `/modes:dev` instead.

Once in a mode, use `*help` to see available commands and `*exit` to leave.

### Invoking Skills

Skills are discrete workflows you can run independently:

| Command | Purpose |
|---------|---------|
| `/skills:create-doc` | Create document from template |
| `/skills:qa-gate` | Create quality gate decision |
| `/skills:execute-checklist` | Run validation checklist |
| `/skills:review-story` | Comprehensive story review |
| `/skills:create-next-story` | Create next user story |
| `/skills:advanced-elicitation` | Requirements gathering |
| `/skills:facilitate-brainstorming-session` | Run brainstorming session |
| `/skills:create-wireframe` | Generate wireframe descriptions (UX) |
| `/skills:review-accessibility` | WCAG compliance audit (UX) |
| `/skills:design-system` | Define design system components (UX) |
| `/skills:user-flow` | Map user journeys and flows (UX) |

### Available Checklists

- `architect-checklist` - Architecture review
- `pm-checklist` - Product manager review
- `po-master-checklist` - Product owner review
- `story-dod-checklist` - Story definition of done
- `story-draft-checklist` - Story draft review
- `change-checklist` - Change impact review

### Available Templates

**Architecture:**
- `architecture-tmpl.yaml` - Backend architecture
- `fullstack-architecture-tmpl.yaml` - Full stack architecture
- `front-end-architecture-tmpl.yaml` - Frontend architecture
- `brownfield-architecture-tmpl.yaml` - Existing codebase architecture

**Product:**
- `prd-tmpl.yaml` - Product requirements document
- `brownfield-prd-tmpl.yaml` - PRD for existing products
- `project-brief-tmpl.yaml` - Project brief
- `story-tmpl.yaml` - User story

**Research:**
- `market-research-tmpl.yaml` - Market research
- `competitor-analysis-tmpl.yaml` - Competitive analysis
- `brainstorming-output-tmpl.yaml` - Brainstorming session output

**Other:**
- `front-end-spec-tmpl.yaml` - Frontend specification
- `qa-gate-tmpl.yaml` - QA gate decision

## The Three RMS Layers

### Rules (CLAUDE.md)
Universal standards that always apply:
- File naming conventions
- Code style standards
- Communication protocols
- Safety guidelines
- MLDA documentation protocol
- Git conventions

### Modes (commands/modes/)
Expert personas activated for specialized work:
- Bring domain expertise and principles
- Have specific file permissions
- Provide mode-specific commands
- Reference skills they commonly use

### Skills (commands/skills/)
Discrete, reusable workflows:
- Have clear start and end
- Follow defined steps
- Can be invoked by anyone or any mode
- Produce specific outputs

## Single Source of Truth (v2.4.0)

All mode definitions are in `commands/modes/`. The duplicate `bmad-agents/` folder has been removed.

Use `/modes:*` for all mode invocations (e.g., `/modes:dev`, `/modes:analyst`).

Legacy `/bmad-tasks:*` commands remain available for task workflows.

## Adding New Components

### New Mode
Create `commands/modes/{name}.md` with:
```yaml
---
description: 'When to use this mode'
---
# Mode Name

mode:
  name: [Display Name]
  id: [short-id]
  title: [Role Title]
  icon: [emoji]

persona:
  role: [Role description]
  style: [Communication style]
  identity: [Who this expert is]
  focus: [Primary concerns]

core_principles:
  - [Unique principle 1]
  - [Unique principle 2]

commands:
  help: Show available commands
  [command]: [description]

dependencies:
  skills: [skills used]
  checklists: [checklists used]
  templates: [templates used]
```

### New Skill
Create `commands/skills/{name}.md` with:
```markdown
---
description: 'What this skill does'
---
# Skill Name

**RMS Skill** | Brief description

## Purpose
[What this accomplishes]

## Prerequisites
- [Required inputs]

## Workflow
### Step 1
[Instructions]

### Step 2
[Instructions]

## Output
[What is produced]
```

## Version

- **RMS Framework:** 1.0
- **BMAD Expansion Pack:** Integrated
- **Last Updated:** 2026-01-12
