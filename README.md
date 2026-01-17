# RMS-BMAD Methodology

A comprehensive AI-assisted software development methodology for Claude Code.

**RMS** (Rules - Modes - Skills) provides a structured framework for AI assistant behavior, while **BMAD** (Business, Marketing, Architecture, Development) extends this with specialized workflows for the full software development lifecycle.

## Quick Start

### Installation

1. **Clone this repository** into your project or a dedicated folder:
   ```bash
   git clone https://github.com/nivanovsp/rms-bmad-framework.git
   ```

2. **Open Claude Code** in the repository folder:
   ```bash
   cd rms-bmad-framework
   claude
   ```

3. **Start using modes and skills** - they work automatically!

That's it! Claude Code automatically detects the `CLAUDE.md` file and `.claude/commands/` folder.

### Alternative: Global Installation

To make RMS-BMAD available in ALL your projects:

1. Copy `CLAUDE.md` to `~/.claude/CLAUDE.md` (or `C:\Users\<username>\.claude\CLAUDE.md` on Windows)
2. Copy the `.claude/commands/` folder to `~/.claude/commands/`

## What's Included

### RMS Framework (Rules - Modes - Skills)

| Layer | Purpose | How to Use |
|-------|---------|------------|
| **Rules** | Universal standards (always active) | Automatic via `CLAUDE.md` |
| **Modes** | Expert personas | `/modes:architect`, `/modes:qa`, etc. |
| **Skills** | Discrete workflows | `/skills:qa-gate`, `/skills:create-doc`, etc. |

### Critical Thinking Protocol

All agents operate with an **always-on critical thinking substrate** that shapes how they process information:

- **Layer 1: Dispositions** — Accuracy over speed, acknowledge uncertainty, question assumptions
- **Layer 2: Triggers** — Automatic deeper analysis for ambiguous/high-stakes tasks
- **Layer 3: Standards** — Quality checks before responding (clarity, accuracy, relevance)
- **Layer 4: Metacognition** — Self-monitoring for pattern-matching vs. reasoning

Agents use calibrated language ("This will..." / "This should..." / "This might...") and surface assumptions explicitly. See `docs/decisions/DEC-001-critical-thinking-protocol.md` for full specification.

### Available Modes (Expert Personas)

| Mode | Use For |
|------|---------|
| `/modes:analyst` | Market research, brainstorming, competitive analysis, project briefs |
| `/modes:architect` | System design, architecture docs, technology selection, API design |
| `/modes:pm` | PRDs, product strategy, feature prioritization, roadmaps |
| `/modes:po` | Backlog management, story refinement, acceptance criteria, sprints |
| `/modes:dev` | Code implementation, debugging, refactoring, best practices |
| `/modes:qa` | Test architecture, quality gates, code improvement, risk assessment |
| `/modes:sm` | Story creation, epic management, retrospectives, agile guidance |
| `/modes:ux-expert` | UI/UX design, wireframes, prototypes, front-end specs |
| `/modes:bmad-master` | Comprehensive expertise across all domains |
| `/modes:bmad-orchestrator` | Workflow coordination, multi-agent tasks |

### Available Skills (Workflows)

| Skill | Purpose |
|-------|---------|
| `/skills:init-project` | Initialize project with MLDA scaffolding |
| `/skills:create-doc` | Create documents from YAML templates |
| `/skills:qa-gate` | Quality gate decisions (PASS/CONCERNS/FAIL/WAIVED) |
| `/skills:execute-checklist` | Validate against checklists |
| `/skills:create-next-story` | Create the next story from backlog |
| `/skills:review-story` | Review story for completeness |
| `/skills:document-project` | Document an existing project |
| `/skills:facilitate-brainstorming-session` | Run structured brainstorming |
| ...and more | See `.claude/commands/skills/` |

### Supporting Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| Checklists | `.claude/commands/checklists/` | Quality validation |
| Templates | `.claude/commands/templates/` | Document scaffolds (YAML-driven) |
| Data | `.claude/commands/data/` | Reference knowledge bases |

## Usage Examples

### Start a New Project

```
/modes:analyst
*help
```
Then follow the analyst's guidance for project discovery.

### Create Architecture Documentation

```
/modes:architect
*help
```
Or directly: `/skills:create-doc architecture`

### Run a Quality Gate

```
/skills:qa-gate
```

### Validate Against a Checklist

```
/skills:execute-checklist architect-checklist
```

## Mode Commands

Once in a mode, these universal commands are available:

| Command | Action |
|---------|--------|
| `*help` | Show available commands for current mode |
| `*exit` | Leave current mode |
| `*yolo` | Toggle autonomous mode (where supported) |

## Quick Command Reference

Each mode command automatically loads the right skill and template:

### Key Analyst Commands
| Command | Skill | Template |
|---------|-------|----------|
| `*create-project-brief` | `create-doc` | `project-brief-tmpl.yaml` |
| `*brainstorm` | `facilitate-brainstorming-session` | `brainstorming-output-tmpl.yaml` |
| `*init-project` | `init-project` | MLDA scaffolding |

### Key Architect Commands
| Command | Skill | Template |
|---------|-------|----------|
| `*create-fullstack-architecture` | `create-doc` | `fullstack-architecture-tmpl.yaml` |
| `*execute-checklist` | `execute-checklist` | + `architect-checklist` |

### Key PM Commands
| Command | Skill | Template |
|---------|-------|----------|
| `*create-prd` | `create-doc` | `prd-tmpl.yaml` |
| `*create-story` | `create-doc` | `story-tmpl.yaml` |

### Key QA Commands
| Command | Skill | Template |
|---------|-------|----------|
| `*gate` | `qa-gate` | `qa-gate-tmpl.yaml` |
| `*review` | `review-story` | `qa-gate-tmpl.yaml` |

See [USER-GUIDE.md](docs/USER-GUIDE.md) for the complete command reference with all skill/template mappings.

## Repository Structure

```
rms-bmad-methodology/
├── CLAUDE.md                      # Rules layer (auto-loaded)
├── README.md                      # This file
├── .claude/
│   ├── commands/
│   │   ├── modes/                 # Expert personas
│   │   ├── skills/                # Reusable workflows
│   │   ├── checklists/            # Quality validation
│   │   ├── templates/             # Document templates
│   │   ├── data/                  # Knowledge bases
│   │   ├── bmad-agents/           # Agent definitions
│   │   └── bmad-tasks/            # Task definitions
│   └── settings.local.json        # Project permissions
├── .mlda/                         # MLDA starter kit (optional)
│   ├── scripts/                   # PowerShell automation
│   ├── templates/                 # Topic doc templates
│   └── docs/                      # Your topic documents
└── docs/
    ├── USER-GUIDE.md              # Comprehensive guide
    ├── RMS-Framework.md           # Methodology specification
    └── development-history/       # How this was built
```

## Optional: MLDA Integration

**MLDA** (Modular Linked Documentation Architecture) replaces monolithic docs with interconnected topic documents.

- Each topic = 1 markdown file + 1 metadata YAML sidecar
- Documents link via DOC-IDs: `DOC-{DOMAIN}-{NNN}`
- PowerShell scripts automate registry and validation

### Quick Setup

```bash
# Via skill (recommended for 15+ documents)
/skills:init-project

# Or via analyst mode
/modes:analyst
*init-project
```

### Automatic Integration

When `.mlda/` exists in your project, document-creating commands automatically:
- Assign DOC-IDs from the registry
- Create `.meta.yaml` sidecars alongside documents
- Update the registry
- Ask about related documents

No manual steps required - just use `*create-project-brief`, `*brainstorm`, etc. as normal.

See `.mlda/README.md` for the starter kit.

## Optional: Beads Issue Tracking

**Beads** is a lightweight issue tracking system with dependency management.

```bash
bd init                           # Initialize in your project
bd create "Task description" -p 1 # Create a task
bd ready                          # See unblocked work
bd close <id> --reason "Done"     # Complete a task
```

## Documentation

- **[USER-GUIDE.md](docs/USER-GUIDE.md)** - Comprehensive usage guide
- **[RMS-Framework.md](docs/RMS-Framework.md)** - Methodology specification
- **[Development History](docs/development-history/)** - How this framework was built

## Contributing

Contributions welcome! Please follow the conventions in `CLAUDE.md`.

## License

MIT License - see LICENSE file for details.

---

*RMS-BMAD Methodology v1.0*
