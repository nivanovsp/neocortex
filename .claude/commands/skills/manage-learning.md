---
description: 'Manage topic-based learning for Neocortex methodology'
---
# Manage Learning Skill

**RMS Skill v2.0** | Topic-based learning management for Neocortex

This skill manages the topic-based learning system that allows agents to accumulate and persist knowledge across sessions. Learning is stored in `.mlda/topics/{topic}/learning.yaml` files.

**Reference:** [DEC-002](../../docs/decisions/DEC-002-neocortex-methodology.md) section 5

## Purpose

- **Load** topic-specific learnings at session start (after task selection)
- **Save** new learnings at session end (user-approved)
- **Propose** document groupings discovered during work
- **Update** co-activation patterns (which docs are used together)
- **Record** verification notes (lessons learned from past sessions)

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Topic must be identified (from task DOC-IDs or explicit selection)

---

## Commands

| Command | Description | Script |
|---------|-------------|--------|
| `*learning list` | List all available topics | `mlda-learning.ps1 -List` |
| `*learning load {topic}` | Load learnings for a topic | `mlda-learning.ps1 -Topic {topic} -Load` |
| `*learning init {topic}` | Initialize a new topic | `mlda-learning.ps1 -Topic {topic} -Init` |
| `*learning status` | Show current learning state | Interactive (no script needed) |
| `*learning save` | Propose saving session learnings | Interactive workflow |
| `*learning grouping` | Add a document grouping | Interactive + script |
| `*learning activation` | Add co-activation pattern | Interactive + script |
| `*learning note` | Add verification note | Interactive workflow |
| `*learning-index` | Regenerate learning index | `mlda-generate-index.ps1` |

---

## Workflow: Load Topic Learning

**When:** After task selection, when topic is identified

### Step 1: Identify Topic

```
Task: "Implement authentication token refresh"
      ^^^^^^^^^^^^^^
      Topic: authentication

How identified:
1. DOC-ID references: DOC-AUTH-xxx → authentication
2. Beads labels: auth, authentication
3. Description keywords: "authentication", "auth"
4. User confirmation (if uncertain)
```

### Step 2: Check Topic Exists

```powershell
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -Load
```

**If topic exists:**
```
=== Topic Learning: authentication ===
Version:  3
Updated:  2026-01-20
Sessions: 12

--- Groupings ---
  - token-management
  - oauth-integration

--- Activations ---
  - [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]

--- Verification Notes ---
  - Always check for compliance markers in token-related docs
```

**If topic doesn't exist:**
```
No learning file found for topic: authentication
→ Note: "New topic - will create learning at session end"
→ Proceed without learnings
```

### Step 3: Apply Learnings

Use loaded learnings to inform work:

| Learning Type | How to Use |
|---------------|------------|
| **Groupings** | Know which docs belong together for decomposition |
| **Activations** | Prioritize loading frequently co-activated docs |
| **Verification Notes** | Watch for issues caught in past sessions |
| **Related Domains** | Know which domain boundaries might need crossing |

---

## Workflow: Check Learning Status

**When:** Anytime during a session to see current learning state

### Purpose

Provides visibility into:
- Whether learnings are currently loaded
- What topic is active
- Session tracking summary
- Pending save status

### Output Format

**If learnings are loaded:**
```
=== Learning Status ===

Topic: authentication
Loaded: Yes (v3, 12 sessions contributed)
Last updated: 2026-01-18

Groupings Available:
  - token-management (3 docs)
  - session-handling (2 docs)
  - oauth-integration (4 docs)

High-Frequency Activations:
  - [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001] (7 times)
  - [DOC-AUTH-002, DOC-AUTH-003] (5 times)

Verification Notes: 2 recorded

--- Session Tracking ---
Documents accessed this session: 4
  - DOC-AUTH-001, DOC-AUTH-002, DOC-API-003, DOC-SEC-001
Potential new co-activation: [DOC-AUTH-001, DOC-API-003]
Pending verification notes: 1

Pending Save: Yes (new patterns discovered)
```

**If no learnings loaded:**
```
=== Learning Status ===

Topic: None loaded
Loaded: No

To load learnings, use: *learning load {topic}
Available topics: authentication, user-management, payments

--- Session Tracking ---
Documents accessed this session: 0
No patterns tracked yet.

Pending Save: No
```

### When to Use

- After activation to verify learnings loaded correctly
- Mid-session to check what's been tracked
- Before ending session to see what will be proposed for save
- When switching topics to see current state

---

## Workflow: Save Session Learnings

**When:** At session end (before closing conversation)

### Step 1: Gather Proposed Learnings

Track during session:
- Documents that were loaded together (potential activations)
- Natural groupings observed (potential groupings)
- Issues caught during verification (potential notes)
- Cross-domain touchpoints discovered

### Step 2: Present to User

```markdown
## Session Learnings Proposed

**Topic:** authentication

### New Co-Activation Pattern
Documents accessed together: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
Task type: implementing
Save this pattern? [y/n]

### Potential New Grouping
Name: refresh-token-handling
Documents: [DOC-AUTH-002, DOC-AUTH-007, DOC-AUTH-009]
Origin: agent
Confidence: low (first observation)
Save this grouping? [y/n]

### Verification Note
Session: 2026-01-20
Caught: GDPR consent requirement in OAuth flow
Doc: DOC-AUTH-011
Section: "5.2 User Consent"
Lesson: "Check GDPR markers when working with OAuth user data"
Save this note? [y/n]

### Summary
- 1 activation pattern to save
- 1 grouping to save
- 1 verification note to save

Proceed with save? [y/n/modify]
```

### Step 3: Execute Save

For approved items:

```powershell
# Add activation
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -AddActivation -Docs "DOC-AUTH-001,DOC-AUTH-002,DOC-SEC-001" -Tasks "implementing"

# Add grouping
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -AddGrouping -Name "refresh-token-handling" -Docs "DOC-AUTH-002,DOC-AUTH-007,DOC-AUTH-009" -Origin agent
```

### Step 4: Confirm

```
Learnings saved to: .mlda/topics/authentication/learning.yaml
Version: 3 → 4
Sessions contributed: 12 → 13

Next session will load these learnings automatically when working on authentication tasks.
```

---

## Workflow: Initialize New Topic

**When:** First time working in a new topic area

```powershell
.\.mlda\scripts\mlda-learning.ps1 -Topic user-management -Init
```

**Creates:**
```
.mlda/topics/user-management/
├── learning.yaml      # Empty learning template
└── domain.yaml        # Domain configuration
```

**Agent reports:**
```
Initialized new topic: user-management
Location: .mlda/topics/user-management/

The learning file is empty. As you work on user-management tasks,
I'll track patterns and propose learnings at session end.
```

---

## Workflow: Add Document Grouping

### Manual Addition

```
*learning grouping

Topic: authentication
Grouping name: session-handling
Documents: DOC-AUTH-004, DOC-AUTH-005, DOC-AUTH-010
Origin: human (you're defining this)
Notes: "Session creation, validation, and invalidation"

Confirm add? [y/n]
```

### Agent-Discovered Addition

During work, agent notices pattern:
```
I've observed that DOC-AUTH-006, DOC-AUTH-011, and DOC-AUTH-012
are always loaded together when working on OAuth integration.

Would you like to save this as a grouping?
Name suggestion: oauth-integration
Confidence: medium (observed 3 times)

[y/n/rename]
```

---

## Workflow: Add Verification Note

After verification catches something:

```
*learning note

Topic: authentication
What was caught: "PCI-DSS token expiry requirement"
Document: DOC-AUTH-003
Section: "Token Expiry Policy"
Lesson: "Always check for <!-- CRITICAL: compliance --> markers in token-related docs"

This will remind future sessions to watch for similar issues.
Save? [y/n]
```

---

## Workflow: Regenerate Learning Index

**When:** After significant learning accumulation, after creating new topics, or if index seems stale

The learning index (`learning-index.yaml`) provides a lightweight summary of all topic learnings for the two-tier loading system (DEC-007). Modes load this index at awakening instead of full learning files.

### Purpose

The index enables:
- **Fast mode awakening** - only ~5-10 KB loaded initially
- **Topic awareness** - agent knows what topics exist without loading full content
- **On-demand loading** - full learning loaded only when topic is identified

### When to Regenerate

Regenerate the index when:
- You've added significant learnings to a topic (5+ sessions)
- You've created new topics
- The `generated_at` timestamp in the index is more than a week old
- The index reports fewer topics than exist in `.mlda/topics/`

### Command

```
*learning-index
```

**Or via PowerShell:**

```powershell
.\.mlda\scripts\mlda-generate-index.ps1
```

**Options:**
- `-MaxInsightsPerTopic 5` - Number of key insights to extract per topic (default: 5)
- `-DryRun` - Preview changes without writing

### Output

```
=== Learning Index Regeneration ===

Scanning: .mlda/topics/
Found: 16 topic directories

Processing topics:
  ✓ AUTH (61 KB, 15 sessions) -> 5 insights extracted
  ✓ UI (23 KB, 8 sessions) -> 4 insights extracted
  ✓ DATA (12 KB, 3 sessions) -> 3 insights extracted
  - API (empty - no learnings yet)
  ...

Generated: .mlda/learning-index.yaml
  Topics with learnings: 12
  Empty topics: 4
  Total sessions: 47
  Index size: 4.2 KB

Previous index: 3.8 KB (2026-01-15)
```

### Index Structure

```yaml
# MLDA Learning Index
# Auto-generated summary of all topic learnings

version: 1
generated_at: "2026-01-23"
generated_from: 16 topic learning files
total_sessions: 47

topics:
  AUTH:
    summary: "Session management, OAuth flow, token refresh patterns"
    sessions: 15
    size: "61 KB"
    key_insights:
      - "Refresh tokens in httpOnly cookies only"
      - "Access tokens: 15 min expiry, refresh: 7 days"
      - "Always validate token scope before operations"
    primary_docs: [DOC-AUTH-001, DOC-AUTH-002]
    learning_path: .mlda/topics/AUTH/learning.yaml

  UI:
    summary: "Component patterns, accessibility, mobile-first design"
    sessions: 8
    # ... similar structure

# Topics without learnings yet
empty_topics:
  - API
  - INFRA
```

### Integration with Mode Awakening

After regeneration, modes will:
1. Load `learning-index.yaml` at awakening (~5 KB)
2. Report: "Learning index: 16 topics, 47 sessions"
3. Wait for topic identification before loading full learning

See DEC-007 for the two-tier loading architecture.

---

## Learning File Schema

```yaml
topic: authentication
version: 3
last_updated: "2026-01-20"
sessions_contributed: 12

# Learned sub-domain groupings
groupings:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003, DOC-AUTH-007]
    origin: human              # human | agent
    confidence: high           # high | medium | low
    notes: "Core token handling"

# Co-activation patterns
activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
    frequency: 7
    typical_tasks: [architecting, implementing]
    last_session: "2026-01-18"

# Verification insights
verification_notes:
  - session: "2026-01-15"
    caught: "PCI-DSS compliance requirement"
    doc: DOC-AUTH-003
    section: "Token Expiry Policy"
    lesson: "Always check for compliance markers in token-related docs"

# Cross-domain touchpoints
related_domains:
  - domain: rbac
    relationship: "Authentication provides identity claims for RBAC"
    typical_overlap: [DOC-AUTH-008, DOC-RBAC-001]

# What didn't work
anti_patterns:
  - pattern: "Loading all AUTH docs at once for simple token validation"
    reason: "Context overflow - only DOC-AUTH-002 and DOC-AUTH-003 needed"
    session: "2026-01-10"
```

---

## Integration Points

### With gather-context Skill

After loading topic learnings, `gather-context` uses them:

```yaml
# From learning.yaml
activations:
  - docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
    frequency: 7

# gather-context behavior:
# "These docs frequently co-activate - load them together"
```

### With Beads Task Selection

When user selects a task:

```
User: "Let's work on Ways of Development-123"

Agent:
1. Reads task from beads
2. Identifies topic from DOC-ID references
3. Calls: *learning load {topic}
4. Proceeds with task using learnings
```

### At Session End

Before session close, agent proposes saving learnings:

```
This session covered authentication tasks.

I observed:
- DOC-AUTH-001, DOC-AUTH-002, DOC-API-003 accessed together (new pattern)
- Verification caught missing CORS config in DOC-AUTH-006

Save these learnings? [y/n]
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Topic directory missing | Offer to initialize with `-Init` |
| Learning file corrupted | Warn user, offer to recreate from template |
| Script not found | Provide manual YAML editing instructions |
| Invalid topic name | Show naming rules (lowercase, hyphenated) |
| Save conflict | Show diff, ask user to resolve |

---

## Best Practices

### When to Save Learnings

- **Do save:** Patterns observed 2+ times, verification catches, user corrections
- **Don't save:** One-time anomalies, task-specific context, temporary workarounds

### Confidence Levels

| Level | When to Use |
|-------|-------------|
| **high** | Proven pattern used successfully 5+ times |
| **medium** | Pattern observed 2-4 times, seems reliable |
| **low** | New observation, hypothesis, needs validation |

### Human vs Agent Origin

- `human`: User explicitly defined this grouping/pattern
- `agent`: Agent discovered during work (should be marked for human approval)

---

## Invocation

This skill can be invoked via:
- `/skills:manage-learning`
- `*learning {command}` (when in any agent mode)
- Automatically triggered at session end (propose save)
- Automatically triggered after task selection (load)

---

*manage-learning v2.1 | Neocortex Methodology | DEC-002, DEC-007 (Two-Tier Loading)*
