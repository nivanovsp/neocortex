# MLDA Topics

Topic-based learning for Neocortex methodology.

## Overview

Each topic/domain has its own folder containing:

| File | Purpose | Schema |
|------|---------|--------|
| `domain.yaml` | Sub-domain structure, entry points, decomposition strategy | `topic-domain.schema.yaml` |
| `learning.yaml` | Accumulated learnings, activations, verification notes | `topic-learning.schema.yaml` |

## Folder Structure

```
topics/
├── _example/           # Template (copy for new topics)
│   ├── domain.yaml
│   └── learning.yaml
├── _cross-domain/      # Patterns spanning multiple domains
│   └── patterns.yaml
├── authentication/     # Example real topic
│   ├── domain.yaml
│   └── learning.yaml
└── README.md           # This file
```

## Creating a New Topic

1. Copy the `_example/` folder:
   ```bash
   cp -r .mlda/topics/_example .mlda/topics/your-topic-name
   ```

2. Edit `domain.yaml`:
   - Change `domain:` to your topic name
   - Define sub-domains
   - Set entry points
   - Configure decomposition strategy

3. Edit `learning.yaml`:
   - Change `topic:` to your topic name
   - Leave other sections empty (they accumulate over time)

4. Validate (optional):
   ```bash
   # Using ajv-cli
   ajv validate -s .mlda/schemas/topic-domain.schema.yaml -d .mlda/topics/your-topic/domain.yaml
   ```

## How Topics Are Used

### Session Start

1. Minimal context loaded (no topic learning)
2. User selects task from beads
3. Agent identifies topic from task (DOC-ID prefix, labels, or inference)
4. Agent loads `topics/{topic}/learning.yaml`
5. Work proceeds with topic context

### During Session

- Agent references `domain.yaml` for navigation strategy
- Activations are tracked internally
- Verification notes accumulate

### Session End

1. Agent proposes new learnings
2. User approves/modifies
3. Written to `learning.yaml`
4. Version incremented

## File Details

### domain.yaml

Defines the static structure of a topic:

```yaml
domain: authentication
version: 2
last_updated: "2026-01-20"
source: hybrid  # human | agent | hybrid

sub_domains:
  - name: token-management
    docs: [DOC-AUTH-002, DOC-AUTH-003]
    entry_point: DOC-AUTH-002

entry_points:
  default: DOC-AUTH-001
  by_task:
    implementing: DOC-AUTH-002
    debugging: DOC-AUTH-010

decomposition:
  strategy: by_sub_domain
  max_docs_per_agent: 5
  parallel_allowed: true
```

### learning.yaml

Accumulates learnings over time:

```yaml
topic: authentication
version: 5
last_updated: "2026-01-20"
sessions_contributed: 12

groupings:
  - name: oauth-flow
    docs: [DOC-AUTH-006, DOC-AUTH-011]
    origin: agent
    confidence: high

activations:
  - docs: [DOC-AUTH-001, DOC-SEC-001]
    frequency: 7
    typical_tasks: [architecting]

verification_notes:
  - session: "2026-01-15"
    caught: "PCI-DSS requirement"
    lesson: "Check compliance markers in token docs"
```

### _cross-domain/patterns.yaml

Tracks patterns spanning multiple domains:

```yaml
patterns:
  - name: auth-rbac-bridge
    domains: [authentication, rbac]
    docs: [DOC-AUTH-008, DOC-RBAC-001]
    description: "Auth provides identity for RBAC"
```

## Validation

Schemas are in `.mlda/schemas/`:

```bash
# Validate domain file
ajv validate -s .mlda/schemas/topic-domain.schema.yaml -d .mlda/topics/auth/domain.yaml

# Validate learning file
ajv validate -s .mlda/schemas/topic-learning.schema.yaml -d .mlda/topics/auth/learning.yaml
```

## VS Code Integration

Add to `.vscode/settings.json`:

```json
{
  "yaml.schemas": {
    ".mlda/schemas/topic-domain.schema.yaml": ".mlda/topics/*/domain.yaml",
    ".mlda/schemas/topic-learning.schema.yaml": ".mlda/topics/*/learning.yaml"
  }
}
```

---

*Neocortex Methodology v2.0*
