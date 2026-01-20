# {PROJECT_NAME}

**Neocortex Methodology: Rules Layer**

This file contains project-specific rules and references the global Neocortex methodology.

---

## Project Overview

{Brief description of the project - 2-3 sentences}

**Tech Stack:** {e.g., TypeScript, React, Node.js, PostgreSQL}
**Primary Domains:** {e.g., AUTH, API, DATA}

---

## RMS Framework

This configuration follows the **RMS (Rules - Modes - Skills)** methodology:

| Layer | Location | Purpose |
|-------|----------|---------|
| **Rules** | This file (CLAUDE.md) | Project-specific standards |
| **Modes** | `.claude/commands/modes/` | Expert personas |
| **Skills** | `.claude/commands/skills/` | Discrete workflows |

### Core Workflow (3 Roles)

```
Analyst → Architect → Developer+QA
```

| Phase | Mode | Purpose |
|-------|------|---------|
| 1 | `/modes:analyst` | Requirements, PRDs, stories |
| 2 | `/modes:architect` | Critical review, architecture |
| 3 | `/modes:dev` | Implementation, testing |

Each role hands off via `docs/handoff.md`.

### Quick Commands

```bash
# Modes
/modes:analyst          # Requirements phase
/modes:architect        # Design phase
/modes:dev              # Implementation phase

# Skills
/skills:gather-context  # Navigate knowledge graph
/skills:manage-learning # Topic learning management
/skills:handoff         # Phase transition

# In-mode
*help                   # Show commands
*exit                   # Leave mode
*explore {DOC-ID}       # Navigate from document
```

---

## Project Conventions

### File Naming
- Use kebab-case for all file names
- Suffix test files with `.test.{ext}` or `.spec.{ext}`
{Add project-specific naming conventions}

### Code Style
{Add project-specific code style rules}

### Documentation
- Document the "why", not just the "what"
- Keep docs close to code
- Update docs when changing behavior

---

## Neocortex Protocol

Documentation forms a **knowledge graph** that agents navigate.

| Concept | Description |
|---------|-------------|
| **Documents** | Neurons - units of knowledge |
| **Relationships** | Dendrites - connections |
| **DOC-IDs** | Axons - unique identifiers |

### Relationship Types

| Type | Signal | When to Follow |
|------|--------|----------------|
| `depends-on` | **Strong** | Always |
| `extends` | **Medium** | If depth allows |
| `references` | **Weak** | If relevant |
| `supersedes` | **Redirect** | Follow instead of target |

### Topic-Based Learning

Learning persists per topic in `.mlda/topics/{topic}/`.

**Session Workflow:**
1. Session starts (minimal context)
2. User selects task from beads
3. Agent loads `.mlda/topics/{topic}/learning.yaml`
4. Work proceeds with topic context
5. Session ends: Agent proposes saving learnings

### Context Limits

| Threshold | Tokens | Documents | Action |
|-----------|--------|-----------|--------|
| **Soft** | 35,000 | 8 | Self-assess |
| **Hard** | 50,000 | 12 | Must decompose |

### Navigation Commands

- `*explore {DOC-ID}` - Navigate from document
- `*related` - Show related documents
- `*context` - Display gathered context

### Scripts

```bash
.\.mlda\scripts\mlda-create.ps1 -Title "X" -Domain AUTH
.\.mlda\scripts\mlda-learning.ps1 -Topic auth -Load
.\.mlda\scripts\mlda-registry.ps1
.\.mlda\scripts\mlda-validate.ps1
```

---

## Issue Tracking with Beads

```bash
bd init                              # Initialize
bd ready                             # Show unblocked tasks
bd create "Task" -t task -p 1        # Create issue
bd update <id> --status in_progress  # Claim
bd close <id> --reason "Done"        # Complete
```

---

## Handoff Protocol

The **handoff document** (`docs/handoff.md`) maintains context across phases.

| Phase | Required Section |
|-------|------------------|
| Analyst → Architect | "Open Questions for Architect" |
| Architect → Developer | "Open Questions for Developer" |
| Developer (completion) | "Implementation Notes" |

---

## Project-Specific Rules

{Add rules specific to this project}

### Security
{Add security requirements}

### Testing
{Add testing requirements}

### Deployment
{Add deployment notes}

---

## Git Conventions

- Keep commit messages clean and concise
- Focus on the "why" not just the "what"
- Never force push to main/master

---

## Development Servers

{Add instructions for dev server setup, or note if not applicable}

---

## Universal Commands

All modes support:
- `*help` - Show available commands
- `*exit` - Leave current mode

---

*Neocortex Methodology v2.0 | Project Rules Layer*
