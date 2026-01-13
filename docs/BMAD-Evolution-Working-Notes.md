# BMAD Evolution - Working Notes

**Status:** In Discussion
**Last Updated:** 2026-01-12
**Participants:** User + Claude

---

## Agreements So Far

### 0. Standalone Methodology: RMS Framework

**Decision:** The methodology will be standalone and shareable, named **RMS Framework** (Rules-Modes-Skills).

**Structure:**
- **Option A (Document):** Pure methodology - the standalone framework anyone can use
- **Option C (Implementation):** RMS + BMAD as expansion pack for software development

```
RMS Framework (Standalone)
    │
    └── Expansion Packs
        ├── BMAD (Software Development) ← What user needs
        ├── [Future: Design Pack]
        ├── [Future: Data Science Pack]
        └── [Future: Others...]
```

BMAD keeps its name but becomes an expansion pack built on RMS.

---

### 1. Three-Layer Architecture Model

We agreed on a clear separation of concerns:

| Layer | Purpose | Location |
|-------|---------|----------|
| **Rules (Universal)** | Always active, regardless of who's working | CLAUDE.md / project rules |
| **Agents (Mode Activators)** | Summoned experts who bring their own rules | bmad-agents/ |
| **Skills (Discrete Workflows)** | Bounded tasks anyone can invoke | bmad-tasks/ |

**Key insight from "The Hacker":** Take time with structure. Decide what should be a skill, what should be a rule, and how to scaffold this. The foundation is simple.

**Analogy agreed upon:** Agents are like human experts - when you summon them, they bring their knowledge and rules. You don't need those rules active all the time, only when that expert is present.

---

### 2. Universal Rules (Move to CLAUDE.md)

These are currently duplicated across all 10 agents and should be centralized:

- `IDE-FILE-RESOLUTION` - Dependencies map to `.bmad-core/{type}/{name}`
- `REQUEST-RESOLUTION` - Match user requests flexibly, ask if unclear
- Agent Activation Protocol (load config, greet, run help, halt)
- Elicitation requirements (`elicit: true` requires 1-9 format interaction)
- Numbered options protocol for presenting choices
- YOLO mode toggle behavior
- Universal commands (`*help`, `yolo`, `doc-out`, `exit`)

---

### 3. Agent-Bound Rules (Stay With Agent)

Each agent keeps only what makes them UNIQUE:

| Agent | Unique Rules |
|-------|--------------|
| Dev (James) | File permissions (only edit Tasks, Dev Agent Record, etc.), develop-story sequence, halt conditions |
| QA (Quinn) | Advisory only, QA Results section only, gate governance (PASS/CONCERNS/FAIL/WAIVED) |
| Analyst (Mary) | Curiosity-driven inquiry, evidence-based, divergent thinking |
| Architect (Winston) | Holistic thinking, user journeys drive architecture, boring tech preference |
| PM (John) | Champion user, ruthless prioritization, MVP focus |
| PO (Sarah) | Quality guardian, process adherence, documentation ecosystem integrity |
| SM (Bob) | NEVER implement or modify code, story prep only |

---

### 4. Lean Agent Format

Agents become "business cards" with only:

```yaml
agent:        # Identity (name, id, title, icon)
persona:      # Role, style, identity, focus
core_principles:  # What makes this agent UNIQUE
file_permissions: # What this agent can/cannot edit
commands:     # Agent-specific shortcuts to skills
dependencies: # Skills and data this agent uses
on_activate:  # Agent-specific startup behavior (if any)
```

**Benefits:**
- ~60% reduction in agent file size (90 lines → 40 lines)
- Single source of truth for universal rules
- Easier maintenance (change once, applies everywhere)
- Smaller context load per agent activation
- Cleaner extension model for new agents

---

### 5. Skills Remain As-Is

Current bmad-tasks/ are already well-structured as discrete workflows:
- `create-doc`, `execute-checklist`, `qa-gate`, `review-story`, etc.
- They are invokable, bounded, and reusable across agents

---

## Open Questions

(To be filled as discussion continues)

---

## Documents Created

1. **RMS-Framework.md** - Standalone methodology document (Option A)
   - Complete framework definition
   - Templates for Rules, Modes, Skills
   - Getting started guide
   - Best practices
   - Expansion pack concept

## Still To Discuss

- Review and refine QA mode (user requested)
- Other mode refinements (Option 2)
- Integration with MLDA framework from Phase 5
- Migration/implementation approach

---

## Final Deliverable Requirements

The user requested a final document with:
1. Description of the new methodology
2. Differences from current BMAD and what the "upgrades" are
3. Implementation information

---

## Change Log

| Date | Change |
|------|--------|
| 2026-01-12 | Initial working notes from discussion session |
