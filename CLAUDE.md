# RMS-BMAD Methodology

**RMS Framework: Rules Layer**

This file contains universal rules that apply across all projects using the RMS-BMAD methodology.

---

## RMS Framework

This configuration follows the **RMS (Rules - Modes - Skills)** methodology:

| Layer | Location | Purpose |
|-------|----------|---------|
| **Rules** | This file (CLAUDE.md) | Universal standards, always active |
| **Modes** | `.claude/commands/modes/` | Expert personas, activated via `/modes:{name}` |
| **Skills** | `.claude/commands/skills/` | Discrete workflows, invoked via `/skills:{name}` |

### Invoking Modes and Skills

- **Activate a Mode**: `/modes:architect`, `/modes:qa`, `/modes:pm`, etc.
- **Run a Skill**: `/skills:qa-gate`, `/skills:create-doc`, etc.
- **Mode Commands**: Once in a mode, use `*help` to see available commands
- **Exit Mode**: Use `*exit` or `exit` to leave current mode

### Supporting Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| Checklists | `.claude/commands/checklists/` | Quality validation checklists |
| Templates | `.claude/commands/templates/` | Document generation templates |
| Data | `.claude/commands/data/` | Reference data and knowledge bases |

---

## Universal Conventions

### File Naming
- Use kebab-case for all file names
- Suffix test files with `.test.{ext}` or `.spec.{ext}`
- Configuration files: `{name}.config.{ext}` or `.{name}rc`

### Code Style
- Prefer explicit over implicit
- Keep functions focused and single-purpose
- Use descriptive variable names

### Documentation
- Document the "why", not just the "what"
- Keep docs close to code
- Update docs when changing behavior

---

## Universal Protocols

### Communication
- Present options as numbered lists for easy selection
- Ask for clarification when requirements are ambiguous
- Summarize understanding before major actions

### Safety
- Never commit secrets, API keys, or credentials
- Validate user input at system boundaries
- Review destructive operations before executing

### Quality
- Run tests before considering work complete
- Check for linting errors
- Verify changes don't break existing functionality

---

## Issue Tracking with Beads

Use **Beads** (`bd`) for multi-session projects with complex dependencies. For simple tasks, use regular TODOs.

### Critical Setup

**ALWAYS run `bd init` first in new projects** - creates .beads/ folder for project-local isolation.

### Essential Commands

```bash
bd init                                    # Initialize (REQUIRED first step)
bd ready --json                            # Show unblocked tasks
bd create "Description" -t task -p 1       # Create issue (priority 0-4, lower=higher)
bd update <id> --status in_progress        # Claim task
bd close <id> --reason "Done"              # Complete task
bd dep add <id> --blocks <other-id>        # Add dependency
bd dep tree <id>                           # Visualize dependency graph
bd stats                                   # Project overview
```

### Workflow

1. Check `bd ready` for unblocked work
2. Claim with `bd update <id> --status in_progress`
3. File new issues as discovered: `bd create "Found bug" --deps discovered-from:<current-id>`
4. Complete with `bd close <id> --reason "Implemented"`

All commands support `--json` flag. Issues auto-sync via git-friendly JSONL files.

---

## MLDA Protocol

**Modular Linked Documentation Architecture** - for projects using MLDA:

### Document Creation
- Create topic documents, not monolithic documents
- Use `.mlda/scripts/mlda-create.ps1` to scaffold new topic docs
- Each topic doc needs a companion `.meta.yaml` sidecar
- Assign DOC-ID from appropriate domain (AUTH, API, UI, DATA, SEC, etc.)

### Linking
- Use DOC-IDs when referencing other documents: `DOC-{DOMAIN}-{NNN}`
- Update `related_docs` in sidecar when creating cross-references
- Specify relationship type: extends, references, depends-on, supersedes

### Registry Management
- Run `mlda-registry.ps1` after creating new topic docs
- Run `mlda-validate.ps1` to check link integrity
- Run `mlda-brief.ps1` to regenerate project brief

---

## Git Conventions

### Commit Messages
- Keep commit messages clean and concise
- Focus on the "why" not just the "what"

### Branch Safety
- Never force push to main/master
- Always verify before destructive operations
- Create feature branches for significant changes

---

## Development Servers

Never start dev servers - assume they are already running.

---

## Universal Commands

All modes support these commands:
- `*help` - Show available commands for current mode
- `*exit` - Leave current mode
- `*yolo` - Toggle autonomous mode (when supported)

---

*RMS-BMAD Methodology v1.0 | Rules Layer*
