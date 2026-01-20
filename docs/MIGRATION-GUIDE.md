# Migration Guide: BMAD/MLDA v1 to Neocortex v2

**Version:** 2.0
**Reference:** [DEC-002](decisions/DEC-002-neocortex-methodology.md) Section 10

---

## Overview

This guide covers migrating existing BMAD/MLDA v1 projects to the Neocortex v2 methodology. The migration is **non-breaking** - existing projects continue working without modification.

### What's New in Neocortex v2

| Feature | v1 (BMAD/MLDA) | v2 (Neocortex) |
|---------|----------------|----------------|
| Context gathering | Breadth-first traversal | Prediction-based, two-phase loading |
| Relationships | Static declarations | Task-type predictions |
| Learning | None | Topic-based, persisted per-domain |
| Large contexts | Manual management | Threshold monitoring + decomposition |
| Document metadata | Basic sidecar | Enhanced with frames & boundaries |

### Migration Levels

Choose your migration depth:

| Level | Effort | Benefit |
|-------|--------|---------|
| **Level 0: No changes** | None | Full backward compatibility |
| **Level 1: Add topics folder** | Low | Enable learning persistence |
| **Level 2: Upgrade sidecars** | Medium | Enable prediction-based gathering |
| **Level 3: Full adoption** | Higher | All Neocortex features |

---

## Level 0: No Changes Required

Existing projects work without modification:

- Sidecar v1 fields remain valid
- `predictions`, `reference_frames`, `boundaries` are optional
- Topics folder is optional - works without learning
- Config file is optional - default thresholds apply

**To verify compatibility:**
```powershell
# Validate existing sidecars still work
.\.mlda\scripts\mlda-validate.ps1
```

---

## Level 1: Add Topics Folder

Enable topic-based learning without changing existing sidecars.

### Step 1.1: Create Topics Structure

```powershell
# Create topics folder
mkdir .mlda\topics

# Initialize a topic (e.g., based on your primary domain)
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -Init
```

This creates:
```
.mlda/topics/authentication/
├── learning.yaml    # Accumulated learnings
└── domain.yaml      # Sub-domain configuration
```

### Step 1.2: Identify Topics from Existing Documents

Derive topics from your existing DOC-ID domains:

```
Existing documents:
DOC-AUTH-001, DOC-AUTH-002, DOC-AUTH-003  →  Topic: authentication
DOC-API-001, DOC-API-002                   →  Topic: api
DOC-SEC-001                                →  Topic: security
```

```powershell
# Initialize each topic
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -Init
.\.mlda\scripts\mlda-learning.ps1 -Topic api -Init
.\.mlda\scripts\mlda-learning.ps1 -Topic security -Init
```

### Step 1.3: Seed Initial Groupings (Optional)

If you know logical groupings within a topic:

```powershell
# Add groupings based on your knowledge of the domain
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication `
    -AddGrouping -Name "token-management" `
    -Docs "DOC-AUTH-001,DOC-AUTH-002" `
    -Origin human
```

### Result

After Level 1, agents can:
- Load topic-specific learnings when starting work
- Accumulate learnings over sessions
- Track co-activation patterns

---

## Level 2: Upgrade Sidecars to v2

Add prediction-based context gathering to existing documents.

### Step 2.1: Understand Sidecar v2 Fields

New optional fields in sidecar v2:

```yaml
# NEW: Predictive context
predictions:
  when_implementing:
    required: [DOC-XXX-NNN]    # Must load for this task type
    likely: [DOC-YYY-NNN]      # Probably needed

# NEW: Reference frames (positional context)
reference_frames:
  domain: authentication       # Problem space
  layer: implementation        # requirements | design | implementation | testing
  stability: stable            # evolving | stable | deprecated
  scope: backend               # frontend | backend | infrastructure | cross-cutting

# NEW: Traversal boundaries
boundaries:
  related_domains: [rbac]      # OK to traverse into
  isolated_from: [invoicing]   # Never traverse into

# NEW: Critical markers flag
has_critical_markers: false    # true if doc contains <!-- CRITICAL --> markers

# NEW: Explicit domain code
domain: AUTH                   # Domain code (extracted from DOC-ID)
```

### Step 2.2: Upgrade Strategy

**Option A: Incremental (Recommended)**

Upgrade documents as you work with them:

1. When starting work on a document, add v2 fields
2. Focus on high-traffic documents first
3. Add predictions based on actual usage patterns

**Option B: Batch Upgrade**

Upgrade all documents at once:

```powershell
# Future script (not yet implemented)
# .\.mlda\scripts\mlda-migrate.ps1 -UpgradeSidecars
```

### Step 2.3: Manual Sidecar Upgrade

For each document, add the new sections:

**Before (v1):**
```yaml
id: DOC-AUTH-001
title: "Authentication Overview"
status: active

created:
  date: "2026-01-15"
  by: "Analyst"

tags:
  - authentication
  - overview

related:
  - id: DOC-AUTH-002
    type: extends
    why: "Token management details"
```

**After (v2):**
```yaml
id: DOC-AUTH-001
title: "Authentication Overview"
status: active

created:
  date: "2026-01-15"
  by: "Analyst"

updated:
  date: "2026-01-20"
  by: "Migration"

tags:
  - authentication
  - overview

domain: AUTH

related:
  - id: DOC-AUTH-002
    type: extends
    why: "Token management details"

# NEW v2 fields below

predictions:
  when_implementing:
    required:
      - DOC-AUTH-002
      - DOC-SEC-001
    likely:
      - DOC-API-001
  when_debugging:
    required:
      - DOC-LOG-001
    likely: []

reference_frames:
  domain: authentication
  layer: design
  stability: stable
  scope: backend

boundaries:
  related_domains:
    - rbac
    - session-management
  isolated_from:
    - invoicing
    - reporting

has_critical_markers: false
```

### Step 2.4: Prediction Guidelines

When adding predictions, consider:

| Task Type | What to Include |
|-----------|-----------------|
| `when_eliciting` | Stakeholder docs, requirements sources |
| `when_documenting` | Templates, style guides |
| `when_architecting` | NFRs, security, constraints |
| `when_reviewing_design` | Architecture docs, patterns |
| `when_implementing` | API specs, data models, existing code refs |
| `when_debugging` | Logging docs, error catalogs |
| `when_testing` | Test patterns, mock data |

**Tip:** Start with `when_implementing` - it's the most commonly used.

### Step 2.5: Validate Upgraded Sidecars

```powershell
# Validate against v2 schema
.\.mlda\scripts\mlda-validate.ps1
```

---

## Level 3: Full Neocortex Adoption

Complete adoption with configuration and critical markers.

### Step 3.1: Create Neocortex Configuration

Create `.mlda/config.yaml`:

```yaml
# Neocortex Configuration
version: "2.0"

# Token budget management
context_limits:
  soft_threshold_tokens: 35000
  hardstop_tokens: 50000
  soft_threshold_documents: 8
  hardstop_documents: 12

  by_task_type:
    research:
      soft_threshold: 50000
      hardstop: 70000
    document_creation:
      soft_threshold: 30000
      hardstop: 45000

# Learning behavior
learning:
  auto_save_prompt: true
  activation_logging: true

# Verification settings
verification:
  cross_verification_domains:
    - security
    - compliance
  critical_marker_syntax: "<!-- CRITICAL: {type} -->"

# Multi-agent settings
multi_agent:
  enabled: true
  max_recursion_depth: 2
  parallel_agents: true

# Navigation settings
navigation:
  max_traversal_depth: 3
  two_phase_loading: true
  respect_boundaries: true
```

### Step 3.2: Add Critical Markers to Documents

For compliance, security, or non-negotiable requirements, add critical markers:

```markdown
## Token Expiry Policy

<!-- CRITICAL: compliance -->
Token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8.
<!-- /CRITICAL -->

Regular content continues here...
```

Then update the sidecar:
```yaml
has_critical_markers: true
```

### Step 3.3: Configure Domain Decomposition

For topics with many documents, configure decomposition strategy:

```yaml
# .mlda/topics/authentication/domain.yaml
domain: authentication
version: 1
source: human

sub_domains:
  - name: token-management
    docs: [DOC-AUTH-001, DOC-AUTH-002, DOC-AUTH-003]
    origin: human

  - name: session-handling
    docs: [DOC-AUTH-004, DOC-AUTH-005]
    origin: human

  - name: oauth-integration
    docs: [DOC-AUTH-006, DOC-AUTH-007]
    origin: human

decomposition:
  strategy: by_sub_domain
  max_docs_per_agent: 5
  parallel_allowed: true
```

---

## Migration Checklist

### Level 1 Checklist
- [ ] Created `.mlda/topics/` folder
- [ ] Initialized topic for each domain (authentication, api, etc.)
- [ ] Added initial groupings for known document clusters
- [ ] Ran `mlda-validate.ps1` to verify

### Level 2 Checklist
- [ ] Identified high-traffic documents to upgrade first
- [ ] Added `domain` field to sidecars
- [ ] Added `predictions` block (at least `when_implementing`)
- [ ] Added `reference_frames` block
- [ ] Added `boundaries` block
- [ ] Ran `mlda-registry.ps1` to rebuild registry
- [ ] Ran `mlda-validate.ps1` to verify

### Level 3 Checklist
- [ ] Created `.mlda/config.yaml`
- [ ] Configured context thresholds appropriate for project
- [ ] Added critical markers to compliance/security documents
- [ ] Set `has_critical_markers: true` for marked documents
- [ ] Configured domain decomposition strategies
- [ ] Updated team on new workflow

---

## Common Migration Patterns

### Pattern 1: Requirements-Heavy Projects

If your project has many requirements documents:

```yaml
# In requirements doc sidecars
predictions:
  when_eliciting:
    required: []  # Usually standalone
    likely: [DOC-STAKE-001]  # Stakeholder context
  when_implementing:
    required: [DOC-API-001]  # Implementation reference
    likely: [DOC-TEST-001]   # Test patterns
```

### Pattern 2: API-First Projects

If your project centers on API specifications:

```yaml
# In API doc sidecars
predictions:
  when_implementing:
    required:
      - DOC-DATA-001    # Data models
      - DOC-AUTH-001    # Authentication
    likely:
      - DOC-ERR-001     # Error handling
  when_testing:
    required:
      - DOC-TEST-001    # Test patterns
    likely:
      - DOC-MOCK-001    # Mock data
```

### Pattern 3: Security-Critical Projects

For projects with compliance requirements:

```yaml
# In security-related sidecars
reference_frames:
  stability: stable  # Don't modify without review

boundaries:
  related_domains:
    - authentication
    - authorization
  isolated_from: []  # Security crosses all domains

has_critical_markers: true

# In config.yaml
verification:
  cross_verification_domains:
    - security
    - compliance
```

---

## Troubleshooting

### Issue: Validation Fails After Migration

```
Error: Unknown field 'predictions' in sidecar
```

**Solution:** Ensure scripts are updated to support v2 fields:
```powershell
git pull  # Get latest scripts
.\.mlda\scripts\mlda-validate.ps1
```

### Issue: Topic Not Found During Context Gathering

```
Topic 'authentication' not found, proceeding without learnings
```

**Solution:** Initialize the topic:
```powershell
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -Init
```

### Issue: Registry Missing New Documents

```
DOC-AUTH-005 not found in registry
```

**Solution:** Rebuild registry:
```powershell
.\.mlda\scripts\mlda-registry.ps1
```

### Issue: Predictions Not Being Used

**Check:**
1. Task type is correctly identified (implementing, debugging, etc.)
2. Sidecar has `predictions` block for that task type
3. Referenced documents exist in registry

---

## Rollback

If you need to rollback:

1. **Level 3 → Level 2:** Delete `.mlda/config.yaml`, remove critical markers
2. **Level 2 → Level 1:** Remove v2 fields from sidecars (they're optional)
3. **Level 1 → Level 0:** Delete `.mlda/topics/` folder

The v2 fields are additive and optional - removing them returns to v1 behavior.

---

## Next Steps After Migration

1. **Run a test task** using `/skills:gather-context` to verify behavior
2. **Monitor learnings** accumulated during sessions
3. **Refine predictions** based on actual usage patterns
4. **Configure thresholds** if defaults don't fit your project

---

## Support Resources

| Resource | Purpose |
|----------|---------|
| [NEOCORTEX.md](NEOCORTEX.md) | Full methodology specification |
| [DEC-002](decisions/DEC-002-neocortex-methodology.md) | Decision record with rationale |
| `.mlda/schemas/` | JSON schemas for validation |
| `/skills:gather-context` | Test context gathering |

---

*Migration Guide v2.0 | Neocortex Methodology*
