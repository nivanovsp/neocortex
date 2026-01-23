# Learning System User Guide

**Neocortex Methodology v1.8** | Two-Tier Learning System

---

## Overview

The learning system allows agents to accumulate and persist knowledge across sessions. As you work on a project, agents learn:
- Which documents are frequently used together (co-activation patterns)
- How to group related documents (groupings)
- Lessons from past sessions (verification notes)

This knowledge is stored in `.mlda/topics/{topic}/learning.yaml` files and loaded automatically when you work on related tasks.

---

## Two-Tier Architecture (DEC-007)

As projects grow, learning files can become large (60+ KB per topic). The two-tier system optimizes context usage:

```
┌─────────────────────────────────────────────────────────────────┐
│  TIER 1: Learning Index (loaded at mode awakening)              │
│  - Lightweight (~5-10 KB total)                                 │
│  - Contains topic summaries and top insights                    │
│  - Agent "knows what exists" without full context load          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ (auto-triggered on topic detection)
┌─────────────────────────────────────────────────────────────────┐
│  TIER 2: Full Learning (loaded when topic identified)           │
│  - Complete learning.yaml for active topic only                 │
│  - Loaded automatically (no manual command needed)              │
│  - Full depth available for current work                        │
└─────────────────────────────────────────────────────────────────┘
```

### Benefits

| Scenario | Without Two-Tier | With Two-Tier | Savings |
|----------|------------------|---------------|---------|
| Mode awakening | 35-71 KB loaded | 5-10 KB loaded | ~25-60 KB |
| Simple conversation | All learning loaded | Index only | Significant |
| Topic-specific work | Same | Same (deferred) | Context preserved |

---

## How It Works

### 1. Mode Awakening

When you activate a mode (`/modes:analyst`, `/modes:dev`, etc.):

```
=== Analyst Mode Activated ===

Activation Protocol:
✓ Handoff document loaded (docs/handoff.md)
✓ Learning index loaded (12 topics, 47 sessions)
✓ Awaiting task selection for deep learning

Ready. Use *help for commands.
```

The agent loads only the lightweight index at this point.

### 2. Topic Detection

When you select a task or mention a topic, the agent automatically loads full learning:

**Detection triggers:**
- DOC-ID in task: `DOC-AUTH-001` → AUTH topic
- Beads task label: `["auth"]` → AUTH topic
- Conversation: "Let's work on authentication" → AUTH topic
- Navigation: `*explore DOC-UI-001` → UI topic

```
Deep learning loaded: AUTH (v3, 15 sessions)
- 3 groupings available
- 5 co-activation patterns
- 2 verification notes

Proceeding with full AUTH context.
```

### 3. Session End

At session end, the agent proposes saving new learnings:

```
## Session Learnings Proposed

**Topic:** AUTH

### New Co-Activation Pattern
Documents accessed together: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Save this pattern? [y/n]

### Verification Note
Caught: Token expiry edge case in refresh flow
Lesson: "Check token state before refresh attempt"
Save this note? [y/n]
```

---

## Commands

### Learning Management

| Command | Description |
|---------|-------------|
| `*learning status` | Show current learning state |
| `*learning list` | List all available topics |
| `*learning load {topic}` | Manually load a topic's learning |
| `*learning save` | Propose saving session learnings |

### Learning Index

| Command | Description |
|---------|-------------|
| `*learning-index` | Regenerate learning index from all topics |

**When to regenerate:**
- After significant learning accumulation (5+ sessions)
- After creating new topics
- If index seems stale (check `generated_at` timestamp)

---

## File Locations

### Learning Index
```
.mlda/learning-index.yaml    # Lightweight summary of all topics
```

### Topic Learning Files
```
.mlda/topics/
├── AUTH/
│   ├── domain.yaml          # Topic structure
│   └── learning.yaml        # Full learning (loaded on-demand)
├── UI/
│   ├── domain.yaml
│   └── learning.yaml
└── ...
```

---

## Learning Index Structure

```yaml
# .mlda/learning-index.yaml
version: 1
generated_at: "2026-01-23"
generated_from: 12 topic learning files
total_sessions: 47

topics:
  AUTH:
    summary: "Session management, OAuth flow, token refresh"
    sessions: 15
    size: "61 KB"
    key_insights:
      - "Refresh tokens in httpOnly cookies only"
      - "Access tokens: 15 min expiry"
    primary_docs: [DOC-AUTH-001, DOC-AUTH-002]
    learning_path: .mlda/topics/AUTH/learning.yaml

  UI:
    summary: "Component patterns, accessibility, mobile-first"
    sessions: 8
    size: "23 KB"
    key_insights:
      - "Bottom sheets need 48px touch targets"
      - "Mobile-first: design 320px first"
    primary_docs: [DOC-UI-001, DOC-DS-001]
    learning_path: .mlda/topics/UI/learning.yaml

empty_topics:
  - API
  - INFRA
```

---

## Full Learning Structure

```yaml
# .mlda/topics/AUTH/learning.yaml
topic: AUTH
version: 3
last_updated: "2026-01-20"
sessions_contributed: 15

groupings:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007]
    origin: human
    confidence: high
    notes: "Core token handling docs"

activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
    frequency: 7
    typical_tasks: [architecting, implementing]

verification_notes:
  - session: "2026-01-15"
    caught: "PCI-DSS compliance requirement"
    doc: DOC-AUTH-003
    lesson: "Always check for compliance markers"

related_domains:
  - domain: SEC
    relationship: "Security policies affect auth implementation"
```

---

## Troubleshooting

### "Learning index not found"

The index file doesn't exist. Generate it:
```
*learning-index
```
Or via PowerShell:
```powershell
.\.mlda\scripts\mlda-generate-index.ps1
```

### "Topic not detected"

If the agent doesn't auto-detect your topic, load manually:
```
*learning load AUTH
```

### "Index seems stale"

Check the `generated_at` timestamp in the index. If old, regenerate:
```
*learning-index
```

### "Context still high after awakening"

Verify mode is using two-tier protocol (v1.8+). Check mode file for:
```markdown
### Step 2: Learning Index Load
- [ ] Read `.mlda/learning-index.yaml`
```

---

## Best Practices

1. **Let auto-detection work** - Don't manually load unless needed
2. **Regenerate index periodically** - After every ~5 sessions with learnings
3. **Review proposed learnings** - Don't blindly accept; verify patterns are real
4. **Keep topics focused** - Large topics should be split (see domain.yaml)

---

## References

| Document | Purpose |
|----------|---------|
| [DEC-007](../decisions/DEC-007-two-tier-learning.md) | Two-tier system specification |
| [DEC-003](../decisions/DEC-003-automatic-learning-integration.md) | Original learning system |
| [manage-learning skill](../../.claude/commands/skills/manage-learning.md) | Full command reference |
| [.mlda/README.md](../../.mlda/README.md) | MLDA overview |

---

*Learning System User Guide v1.0 | Neocortex Methodology v1.8*
