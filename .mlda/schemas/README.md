# Neocortex Schemas

JSON Schema definitions for Neocortex methodology YAML files.

## Schemas

| Schema | File | Purpose |
|--------|------|---------|
| **Sidecar v2** | `sidecar-v2.schema.yaml` | Document metadata sidecars (.meta.yaml) |
| **Topic Learning** | `topic-learning.schema.yaml` | Accumulated topic learnings |
| **Topic Domain** | `topic-domain.schema.yaml` | Domain structure and decomposition |
| **Neocortex Config** | `neocortex-config.schema.yaml` | Project configuration |

## Usage

### Validation with yq/ajv

```bash
# Using ajv-cli
ajv validate -s sidecar-v2.schema.yaml -d ../docs/auth/access-control.meta.yaml

# Using yq for basic structure check
yq eval '.' ../docs/auth/access-control.meta.yaml
```

### IDE Integration

Add to VS Code `settings.json` for YAML validation:

```json
{
  "yaml.schemas": {
    ".mlda/schemas/sidecar-v2.schema.yaml": "**/*.meta.yaml",
    ".mlda/schemas/topic-learning.schema.yaml": ".mlda/topics/*/learning.yaml",
    ".mlda/schemas/topic-domain.schema.yaml": ".mlda/topics/*/domain.yaml",
    ".mlda/schemas/neocortex-config.schema.yaml": ".mlda/config.yaml"
  }
}
```

## Schema Overview

### Sidecar v2 (sidecar-v2.schema.yaml)

New fields in v2:
- `predictions` - Task-type context predictions
- `reference_frames` - Positional context in knowledge space
- `boundaries` - Domain traversal rules
- `has_critical_markers` - Flag for critical content

### Topic Learning (topic-learning.schema.yaml)

Stores:
- `groupings` - Learned sub-domain groupings
- `activations` - Co-activation patterns
- `verification_notes` - What verification caught
- `related_domains` - Cross-domain touchpoints

### Topic Domain (topic-domain.schema.yaml)

Defines:
- `sub_domains` - Logical subdivisions
- `entry_points` - Starting documents by task type
- `decomposition` - Multi-agent splitting strategy
- `related_domains` - Cross-domain relationships

### Neocortex Config (neocortex-config.schema.yaml)

Configures:
- `context_limits` - Token budget thresholds
- `learning` - Learning behavior settings
- `verification` - Verification stack settings
- `multi_agent` - Multi-agent scaling settings
- `navigation` - Graph navigation settings

## Version

Neocortex Methodology v2.0
