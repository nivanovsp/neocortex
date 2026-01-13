# RMS Framework

**Rules - Modes - Skills**

A methodology for organizing AI assistant configurations.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Core Concepts](#core-concepts)
3. [The Three Layers](#the-three-layers)
4. [Rules Layer](#rules-layer)
5. [Modes Layer](#modes-layer)
6. [Skills Layer](#skills-layer)
7. [How Layers Interact](#how-layers-interact)
8. [Getting Started](#getting-started)
9. [Templates](#templates)
10. [Best Practices](#best-practices)
11. [Expansion Packs](#expansion-packs)

---

## Introduction

### What is RMS?

RMS (Rules-Modes-Skills) is a methodology for organizing instructions, behaviors, and workflows when working with AI assistants. It provides a clean separation of concerns that makes configurations:

- **Maintainable** - Change once, apply everywhere
- **Scalable** - Add new capabilities without bloating existing ones
- **Shareable** - Others can understand and extend your setup
- **Efficient** - Load only what's needed for the current task

### The Problem RMS Solves

Without structure, AI assistant configurations tend to become:

- **Monolithic** - Everything in one giant file
- **Duplicated** - Same instructions repeated across contexts
- **Inconsistent** - Similar tasks handled differently
- **Unmaintainable** - Changing one thing requires updating many places

### The RMS Solution

Separate your instructions into three distinct layers:

```
┌─────────────────────────────────────────────┐
│  RULES        Always active, universal      │
├─────────────────────────────────────────────┤
│  MODES        Expert personas, activated    │
├─────────────────────────────────────────────┤
│  SKILLS       Discrete workflows, invoked   │
└─────────────────────────────────────────────┘
```

---

## Core Concepts

### The Expert Analogy

Think of working with an AI assistant like working with a team of experts:

- **Rules** are like company policies - everyone follows them, always
- **Modes** are like summoning an expert - they bring their knowledge and principles
- **Skills** are like standard procedures - anyone can execute them

When you summon an expert (activate a Mode), they bring their expertise but still follow company policies (Rules) and can execute standard procedures (Skills).

### Key Principles

1. **Single Source of Truth** - Each instruction lives in exactly one place
2. **Appropriate Scope** - Instructions live at the right level (universal vs contextual)
3. **Composition Over Duplication** - Modes use Skills, not copy them
4. **Lean Definitions** - Each component contains only what makes it unique

---

## The Three Layers

| Layer | Purpose | Activation | Scope |
|-------|---------|------------|-------|
| **Rules** | Universal standards | Always active | All interactions |
| **Modes** | Expert personas | Explicitly activated | Until deactivated |
| **Skills** | Discrete workflows | Explicitly invoked | Single execution |

### Quick Comparison

| Aspect | Rules | Modes | Skills |
|--------|-------|-------|--------|
| When active | Always | When summoned | When called |
| Duration | Permanent | Session/until exit | One task |
| Contains | Standards, conventions | Persona, principles, permissions | Steps, workflow |
| Example | "Use kebab-case for files" | "QA Expert mode" | "Run code review" |

---

## Rules Layer

### What Are Rules?

Rules are universal instructions that apply regardless of context. They define:

- Conventions and standards
- Always-on behaviors
- Universal commands
- Shared protocols

### Characteristics of Good Rules

- **Universal** - Apply in all contexts
- **Stable** - Rarely change
- **Non-conflicting** - Don't contradict each other
- **Concise** - Easy to remember and apply

### What Belongs in Rules

| Include | Exclude |
|---------|---------|
| File naming conventions | Role-specific behaviors |
| Code style standards | Specialized workflows |
| Communication protocols | Context-dependent logic |
| Universal commands | One-time procedures |
| Safety guidelines | Temporary instructions |

### Rules Location

Rules typically live in a central configuration file that's always loaded:

- Claude Code: `CLAUDE.md`
- Other systems: Main system prompt or config

### Rules Template

```markdown
# Project Rules

## Conventions

### File Naming
- Use kebab-case for all files
- Suffix test files with `.test.{ext}`

### Code Style
- [Your standards here]

## Protocols

### Communication
- Present options as numbered lists
- Ask for clarification when ambiguous

### Safety
- Never commit secrets
- Validate user input at boundaries

## Universal Commands

All modes support these commands:
- `help` - Show available commands
- `exit` - Leave current mode
```

---

## Modes Layer

### What Are Modes?

Modes are "expert personas" that you activate when you need specialized behavior. When a Mode is active, it brings:

- **Identity** - Who the expert is
- **Principles** - What they believe and prioritize
- **Permissions** - What they can and cannot modify
- **Commands** - Shortcuts they provide
- **Dependencies** - Skills and data they use

### The Expert Mental Model

When you activate a Mode, think of it as summoning an expert:

- They arrive with their knowledge and experience
- They follow company policies (Rules) while active
- They can perform standard procedures (Skills)
- They leave when dismissed, taking their context with them

### Characteristics of Good Modes

- **Focused** - Clear area of expertise
- **Distinct** - Different from other Modes
- **Lean** - Only unique content, no duplication
- **Self-contained** - Everything needed is declared

### What Belongs in Modes

| Include | Exclude |
|---------|---------|
| Persona definition | Universal standards (use Rules) |
| Role-specific principles | Complete workflow steps (use Skills) |
| File permissions | Duplicated instructions |
| Commands (shortcuts to Skills) | Generic behaviors |
| Mode-specific startup | Content shared across Modes |

### Mode Template

```yaml
---
description: 'Brief description for when to use this mode'
---
# Mode Name

mode:
  name: [Display Name]
  id: [short-id]
  title: [Role Title]
  icon: [emoji]

persona:
  role: [Detailed role description]
  style: [Communication style - concise, verbose, technical, etc.]
  identity: [Who this expert is and what they specialize in]
  focus: [Primary concerns and priorities]

core_principles:
  - [Principle 1 - what makes this mode UNIQUE]
  - [Principle 2]
  - [Principle 3]

file_permissions:
  can_edit:
    - [file patterns or sections this mode can modify]
  cannot_edit:
    - [file patterns or sections this mode must not touch]

commands:
  command-name:
    description: "What this command does"
    skill: "skill-to-invoke"  # References a Skill
  another-command:
    description: "Description"
    sequence: "Inline short workflow"

dependencies:
  skills: [list of skills this mode uses]
  data: [reference data files]

on_activate:
  load_files: [files to load on startup]
  greet: true|false
  show_help: true|false
```

---

## Skills Layer

### What Are Skills?

Skills are discrete, reusable workflows that accomplish specific tasks. They:

- Have a clear start and end
- Follow defined steps
- Can be invoked by anyone (or any Mode)
- Are self-documenting

### Characteristics of Good Skills

- **Bounded** - Clear scope, finite execution
- **Reusable** - Not tied to specific Mode
- **Documented** - Steps are explicit
- **Composable** - Can be combined or sequenced

### What Belongs in Skills

| Include | Exclude |
|---------|---------|
| Step-by-step workflow | Behavioral principles (use Modes) |
| Input requirements | Universal standards (use Rules) |
| Output format | Persona definitions |
| Validation steps | Mode-specific logic |
| Error handling | Always-on behaviors |

### Skill Template

```markdown
---
description: 'Brief description of what this skill does'
---
# Skill Name

## Purpose

[What this skill accomplishes]

## Prerequisites

- [What's needed before running]
- [Required inputs]

## Workflow

### Step 1: [Name]
[Instructions]

### Step 2: [Name]
[Instructions]

### Step 3: [Name]
[Instructions]

## Output

[What this skill produces]

## Validation

[How to verify success]
```

---

## How Layers Interact

### Reference Patterns

```
Rules ◄──────────────── Always active, inherited by all
  │
  │ (Modes follow Rules)
  ▼
Modes ────────────────► Activate/deactivate
  │
  │ (Modes invoke Skills)
  ▼
Skills ───────────────► Execute and complete
```

### Interaction Examples

**Rules mandate Skills:**
```markdown
# In Rules
When completing a story, always run the `definition-of-done` skill.
```

**Modes invoke Skills:**
```yaml
# In Mode
commands:
  review:
    description: "Run code review"
    skill: "code-review"
```

**Skills reference Rules:**
```markdown
# In Skill
## Step 3: Naming
Name the output file following project conventions (see Rules).
```

### Precedence

When instructions could conflict:

1. **Mode-specific** takes precedence over **Universal**
2. **Explicit** takes precedence over **Implicit**
3. **Narrow scope** takes precedence over **Broad scope**

Example: If Rules say "be concise" but a Mode's style is "verbose, educational" - the Mode's style wins while that Mode is active.

---

## Getting Started

### Step 1: Audit Your Current Setup

List all instructions you currently give your AI assistant:
- Where do they live?
- Are any duplicated?
- Which are universal vs contextual?

### Step 2: Categorize

For each instruction, ask:

| Question | If Yes → |
|----------|----------|
| Does this apply always, regardless of task? | **Rule** |
| Does this define how to behave in a role? | **Mode** |
| Does this describe steps to complete a task? | **Skill** |

### Step 3: Create Rules File

Start with your universal instructions:

```markdown
# Rules

## Conventions
[Your universal standards]

## Protocols
[Your universal behaviors]

## Commands
[Universal commands all modes support]
```

### Step 4: Extract Modes

For each "expert persona" you need:

1. Define identity and principles
2. Specify what they can/cannot edit
3. List their commands (shortcuts to Skills)
4. Declare dependencies

### Step 5: Extract Skills

For each reusable workflow:

1. Document the steps
2. Define inputs and outputs
3. Make it Mode-agnostic

### Step 6: Connect

- Rules reference Skills where universal workflows exist
- Modes reference Skills in their commands
- Skills reference Rules for conventions

---

## Templates

### Minimal Rules Template

```markdown
# Rules

## Conventions
- [Convention 1]
- [Convention 2]

## Universal Commands
- `help` - Show available commands
- `exit` - Exit current mode
```

### Minimal Mode Template

```yaml
---
description: '[When to use this mode]'
---
# [Mode Name]

mode:
  name: [Name]
  id: [id]

persona:
  role: [Role]
  style: [Style]

core_principles:
  - [Unique principle 1]
  - [Unique principle 2]

commands:
  [command]: "[description]"
```

### Minimal Skill Template

```markdown
---
description: '[What this does]'
---
# [Skill Name]

## Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output
[What is produced]
```

---

## Best Practices

### Do

- **Keep Rules lean** - Only truly universal content
- **Keep Modes focused** - One expert, one domain
- **Keep Skills atomic** - One task, clear boundaries
- **Name consistently** - Use patterns (`review-*`, `create-*`)
- **Document why** - Explain reasoning, not just what

### Don't

- **Don't duplicate** - If it's in Rules, don't repeat in Modes
- **Don't over-abstract** - Three similar lines beats a premature abstraction
- **Don't nest Modes** - One Mode active at a time
- **Don't hardcode in Skills** - Keep Skills reusable across contexts
- **Don't mix layers** - Rules shouldn't contain workflows, Skills shouldn't contain principles

### Signs of Good Structure

- Changing a convention requires editing one file (Rules)
- Adding a new expert requires one new file (Mode)
- A workflow can be reused by multiple Modes (Skill)
- No instruction appears in more than one place

### Signs of Poor Structure

- Same instruction in multiple files
- Modes that are 90% identical
- Skills that only work for one Mode
- Confusion about where something should live

---

## Expansion Packs

### What Are Expansion Packs?

Expansion Packs are pre-built collections of Modes and Skills for specific domains. They provide:

- Ready-to-use Modes for that domain
- Pre-built Skills for common workflows
- Domain-specific Rules additions
- Templates and examples

### Using Expansion Packs

1. Install the RMS Framework (this methodology)
2. Add expansion pack(s) for your domain
3. Customize as needed

### Example Expansion Packs

| Domain | Modes | Skills |
|--------|-------|--------|
| Software Development | Dev, QA, Architect, PM | code-review, create-doc, qa-gate |
| Design | UX Researcher, Visual Designer | create-wireframe, audit-accessibility |
| Data Science | Analyst, ML Engineer | explore-data, train-model |
| Content | Writer, Editor, SEO | draft-article, review-copy |

### Creating Expansion Packs

An expansion pack contains:

```
my-expansion-pack/
├── README.md           # Overview and installation
├── rules-additions.md  # Domain-specific rules to add
├── modes/
│   ├── mode-1.yaml
│   └── mode-2.yaml
├── skills/
│   ├── skill-1.md
│   └── skill-2.md
└── templates/          # Optional templates
    └── ...
```

---

## Summary

RMS Framework provides a clean mental model for organizing AI assistant configurations:

| Layer | Question to Ask | Lives In |
|-------|-----------------|----------|
| **Rules** | "Should this always apply?" | Central config (CLAUDE.md) |
| **Modes** | "Is this expert-specific behavior?" | Mode files |
| **Skills** | "Is this a discrete workflow?" | Skill files |

The key insight: **Separate what's universal from what's contextual from what's procedural.**

This separation enables maintainable, scalable, and shareable AI configurations.

---

## Version

- **Framework Version:** 1.0
- **Date:** 2026-01-12
- **Authors:** Collaborative development

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-12 | Initial framework definition |
