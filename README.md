# Neocortex Methodology

A knowledge-graph-based AI-assisted software development methodology for Claude Code.

**Neocortex** treats documentation as a neural network that agents navigate to gather context. Built on the **RMS** (Rules - Modes - Skills) framework.

## Overview

```
Documentation = Knowledge Graph

Documents → Neurons (units of knowledge)
Relationships → Dendrites (connections)
DOC-IDs → Axons (unique identifiers)
Agent reading → Signal activation
Following relationships → Signal propagation
```

**Key Principle:** Tasks are entry points into the knowledge graph, not self-contained specs. Agents navigate to gather context.

## Quick Start

### Installation

1. **Clone this repository**:
   ```bash
   git clone https://github.com/nicholasgriffintn/neocortex-methodology.git
   ```

2. **Open Claude Code** in the folder:
   ```bash
   cd neocortex-methodology
   claude
   ```

3. **Start using modes and skills** - they work automatically!

### Alternative: Global Installation

To make Neocortex available in all projects:

1. Copy `CLAUDE.md` to `~/.claude/CLAUDE.md`
2. Copy `.claude/commands/` to `~/.claude/commands/`

## Core Workflow (5 Phases)

```
┌──────────┐     ┌───────────┐     ┌───────────┐     ┌──────────┐     ┌───────────┐
│ Analyst  │ ──► │ Architect │ ──► │ UX-Expert │ ──► │ Analyst  │ ──► │ Developer │
│ (Maya)   │     │ (Winston) │     │ (Uma)     │     │ (stories)│     │ (Devon)   │
└──────────┘     └───────────┘     └───────────┘     └──────────┘     └───────────┘
```

| Phase | Role | Mode | Purpose |
|-------|------|------|---------|
| 1 | **Analyst** | `/modes:analyst` | Requirements, PRDs, epics |
| 2 | **Architect** | `/modes:architect` | Critical review, technical refinement, architecture docs |
| 3 | **UX-Expert** | `/modes:ux-expert` | UI/UX design, wireframes, design system |
| 4 | **Analyst** | `/modes:analyst` | Stories from UX specs |
| 5 | **Developer** | `/modes:dev` | Implementation, test-first development, quality gates |

Each role hands off via `docs/handoff.md`.

## RMS Framework

| Layer | Purpose | How to Use |
|-------|---------|------------|
| **Rules** | Universal standards (always active) | Automatic via `CLAUDE.md` |
| **Modes** | Expert personas | `/modes:analyst`, `/modes:architect`, `/modes:dev` |
| **Skills** | Discrete workflows | `/skills:gather-context`, `/skills:create-doc`, etc. |

### Essential Skills

| Skill | Purpose |
|-------|---------|
| `/skills:gather-context` | Navigate knowledge graph from entry point |
| `/skills:manage-learning` | Save/load topic-based learnings |
| `/skills:handoff` | Generate phase transition document |
| `/skills:init-project` | Initialize project with MLDA scaffolding |
| `/skills:create-doc` | Create documents from YAML templates |
| `/skills:qa-gate` | Quality gate decisions (PASS/CONCERNS/FAIL/WAIVED) |

See `.claude/commands/skills/` for all available skills.

### Mode Commands

Once in a mode:

| Command | Action |
|---------|--------|
| `*help` | Show available commands |
| `*exit` | Leave current mode |
| `*explore {DOC-ID}` | Navigate from a document |
| `*related` | Show related documents |
| `*context` | Display gathered context |

## Neocortex Features

### Knowledge Graph Navigation

Documents connect via relationships in `.meta.yaml` sidecars:

| Relationship | Signal | When to Follow |
|--------------|--------|----------------|
| `depends-on` | **Strong** | Always - cannot understand without target |
| `extends` | **Medium** | If depth allows - adds detail |
| `references` | **Weak** | If relevant to current task |
| `supersedes` | **Redirect** | Follow this instead of target |

### Topic-Based Learning (Automatic)

Learning **automatically** loads during mode activation and persists across sessions:

```
1. Mode activated → Agent checks MLDA status
2. Topic identified from DOC-IDs, beads labels, or user mention
3. Agent reads: .mlda/topics/{topic}/learning.yaml (direct file read)
4. Learning status displayed in greeting (MANDATORY visible confirmation)
5. Work proceeds with topic context + session tracking
6. Session ends: Agent proposes saving new learnings
```

**Session Tracking**: Agents track documents accessed, co-activation patterns, and verification catches throughout the session.

**Learning Commands**:
- `*learning status` - Show current learning state
- `*learning save` - Save session learnings
- `*learning note` - Add verification note

### Context Management

| Threshold | Tokens | Documents | Action |
|-----------|--------|-----------|--------|
| **Soft** | 35,000 | 8 | Self-assess, consider decomposition |
| **Hard** | 50,000 | 12 | Must decompose or pause |

When context exceeds thresholds, agents propose multi-agent decomposition.

### Critical Thinking Protocol

All agents operate with an always-on critical thinking substrate:

- **Dispositions** — Accuracy over speed, acknowledge uncertainty, question assumptions
- **Triggers** — Automatic deeper analysis for ambiguous/high-stakes tasks
- **Standards** — Quality checks before responding (clarity, accuracy, relevance)
- **Metacognition** — Self-monitoring for pattern-matching vs. reasoning

See `docs/decisions/DEC-001-critical-thinking-protocol.md` for specification.

## Repository Structure

```
neocortex-methodology/
├── CLAUDE.md                      # Rules layer (auto-loaded)
├── README.md                      # This file
├── .claude/
│   └── commands/
│       ├── modes/                 # Expert personas (analyst, architect, dev)
│       ├── skills/                # Reusable workflows
│       ├── checklists/            # Quality validation
│       ├── templates/             # Document templates (YAML-driven)
│       └── data/                  # Reference knowledge bases
├── .mlda/                         # MLDA knowledge graph
│   ├── topics/                    # Topic-based learning
│   │   └── {topic}/
│   │       ├── domain.yaml        # Sub-domain structure
│   │       └── learning.yaml      # Accumulated learnings
│   ├── docs/                      # Topic documents
│   │   └── {domain}/
│   │       ├── {topic}.md
│   │       └── {topic}.meta.yaml
│   ├── scripts/                   # PowerShell automation
│   ├── templates/                 # Document templates
│   ├── schemas/                   # YAML validation schemas
│   ├── registry.yaml              # Document index
│   └── config.yaml                # Neocortex configuration
├── .beads/                        # Issue tracking (optional)
└── docs/
    ├── NEOCORTEX.md               # Full methodology documentation
    ├── handoff.md                 # Phase transition document
    └── decisions/                 # Decision records
```

## MLDA Integration

**MLDA** (Modular Linked Documentation Architecture) implements the knowledge graph:

- Each topic = 1 markdown file + 1 metadata YAML sidecar
- Documents link via DOC-IDs: `DOC-{DOMAIN}-{NNN}`
- PowerShell scripts automate registry and validation

### Initialize MLDA

```bash
# Via skill (recommended)
/skills:init-project

# Or via analyst mode
/modes:analyst
*init-project
```

See `.mlda/README.md` for details.

## Beads Issue Tracking

**Beads** provides lightweight issue tracking with dependency management:

```bash
bd init                           # Initialize
bd ready                          # Show unblocked work
bd create "Task" -p 1             # Create task (priority 0-4)
bd update <id> --status in_progress
bd close <id> --reason "Done"
```

## Documentation

| Document | Purpose |
|----------|---------|
| [docs/NEOCORTEX.md](docs/NEOCORTEX.md) | Full methodology documentation |
| [.mlda/README.md](.mlda/README.md) | MLDA quick start |
| [docs/decisions/](docs/decisions/) | Decision records |

## Deprecated Modes

The following modes are deprecated (January 2026) and will be removed in February 2026:

| Deprecated | Use Instead |
|------------|-------------|
| `/modes:pm` | `/modes:analyst` |
| `/modes:po` | `/modes:analyst` |
| `/modes:sm` | `/modes:analyst` |
| `/modes:qa` | `/modes:dev` |

These roles were consolidated into the 3-role workflow to reduce handoffs.

## Contributing

Contributions welcome! Please follow the conventions in `CLAUDE.md`.

## License

MIT License - see LICENSE file for details.

---

*Neocortex Methodology v2.1 | Built on the RMS Framework*
