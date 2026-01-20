---
description: 'Validate MLDA knowledge graph integrity and health'
---
# Validate MLDA Skill

**RMS Skill v2.0** | Discrete workflow for MLDA validation with Neocortex sidecar v2 support

Validate the MLDA knowledge graph to ensure integrity, identify issues, and report health metrics.

## Purpose

MLDA models documentation as a neural network. Like a brain, it needs health checks:
1. Identify orphan documents (neurons with no connections)
2. Find broken links (dead dendrites)
3. Detect circular dependencies
4. Report overall graph health

## Prerequisites

- MLDA must be initialized (`.mlda/` folder exists)
- Registry exists (`.mlda/registry.yaml`)
- At least one document exists

## Workflow

### Step 1: Run Validation Script

```powershell
.\.mlda\scripts\mlda-validate.ps1
```

If script doesn't exist, perform manual validation.

### Step 2: Check Registry Completeness

Verify every document has:
- [ ] DOC-ID assigned
- [ ] Sidecar file (`.meta.yaml`)
- [ ] At least one relationship (except root documents)
- [ ] Valid status

### Step 2.1: Check Sidecar v2 Compliance

Verify sidecars have v2 required and recommended fields:

**Required v2 fields:**
- [ ] `id` (DOC-{DOMAIN}-{NNN} format)
- [ ] `title`
- [ ] `status` (draft | review | active | deprecated)

**Recommended v2 fields:**
- [ ] `domain` (classification)
- [ ] `summary` (1-2 sentence description)
- [ ] `related` array with `id`, `type`, `why` for each relationship

**Optional v2 enhancements:**
- [ ] `predictions` (for entry point documents)
- [ ] `reference_frames` (layer, stability, scope)
- [ ] `boundaries` (related_domains, isolated_from)
- [ ] `has_critical_markers` (if document contains CRITICAL markers)

### Step 3: Check Relationships

For each relationship in sidecars:
- [ ] Target DOC-ID exists
- [ ] Relationship type is valid (`depends-on`, `extends`, `references`, `supersedes`)
- [ ] `why` field explains the connection
- [ ] No circular `depends-on` chains

### Step 4: Identify Issues

| Issue Type | Severity | Description |
|------------|----------|-------------|
| **Orphan Document** | Warning | Document with no incoming or outgoing relationships |
| **Broken Link** | Error | Relationship points to non-existent DOC-ID |
| **Missing Sidecar** | Error | Document exists without `.meta.yaml` |
| **Circular Dependency** | Error | A depends-on B depends-on A |
| **Superseded Active** | Warning | Document marked superseded but still referenced |
| **Missing DOC-ID** | Error | Document without DOC-ID in registry |

**Sidecar v2 Issues:**

| Issue Type | Severity | Description |
|------------|----------|-------------|
| **Missing Domain** | Warning | Sidecar lacks `domain` field |
| **Missing Summary** | Info | Sidecar lacks `summary` field |
| **Invalid Relationship Type** | Error | Relationship type not in: depends-on, extends, references, supersedes |
| **Missing Relationship Why** | Warning | Relationship lacks `why` explanation |
| **Entry Point Without Predictions** | Info | Document frequently referenced but lacks `predictions` |
| **CRITICAL Markers Without Flag** | Warning | Document has `<!-- CRITICAL -->` but `has_critical_markers: false` |
| **Invalid Reference Frame** | Warning | `reference_frames` has invalid enum values |

### Step 5: Generate Validation Report

```markdown
# MLDA Validation Report

**Generated:** {timestamp}
**Project:** {project name}

## Summary

| Metric | Value | Status |
|--------|-------|--------|
| Total Documents | 45 | - |
| With Sidecars | 45 | OK |
| Orphan Documents | 2 | WARNING |
| Broken Links | 0 | OK |
| Circular Dependencies | 0 | OK |

**Overall Health:** HEALTHY / WARNINGS / UNHEALTHY

## Sidecar v2 Coverage

| v2 Field | Documents With | Coverage |
|----------|---------------|----------|
| `domain` | 42/45 | 93% |
| `summary` | 38/45 | 84% |
| `predictions` | 8/45 | 18% (entry points) |
| `reference_frames` | 30/45 | 67% |
| `boundaries` | 15/45 | 33% |
| `has_critical_markers` | 5/45 | 11% |

**v2 Compliance:** FULL / PARTIAL / MINIMAL

## Document Statistics

### By Domain
| Domain | Count | Orphans |
|--------|-------|---------|
| AUTH | 12 | 0 |
| API | 15 | 1 |
| DATA | 10 | 0 |
| UI | 8 | 1 |

### By Status
| Status | Count |
|--------|-------|
| approved | 30 |
| draft | 10 |
| superseded | 5 |

## Issues Found

### Errors (Must Fix)

None / List of errors

### Warnings (Should Fix)

#### Orphan Documents
| DOC-ID | Title | Recommendation |
|--------|-------|----------------|
| DOC-API-015 | Legacy Endpoint Docs | Add relationship or supersede |
| DOC-UI-008 | Old Wireframes | Add relationship or supersede |

## Relationship Graph Health

### Connectivity
- **Root Documents:** 3 (entry points with no incoming depends-on)
- **Leaf Documents:** 12 (no outgoing relationships)
- **Average Connections:** 2.4 per document

### Strongest Paths
Documents most frequently depended upon:
1. DOC-AUTH-001 (8 incoming)
2. DOC-API-001 (6 incoming)
3. DOC-DATA-001 (5 incoming)

## Recommendations

1. [Specific recommendation based on findings]
2. [Specific recommendation based on findings]
```

## Health Status Definitions

| Status | Criteria |
|--------|----------|
| **HEALTHY** | No errors, 0-2 warnings |
| **WARNINGS** | No errors, 3+ warnings |
| **UNHEALTHY** | Any errors present |

## Common Issues and Fixes

### Orphan Document

**Cause:** Document created without relationships
**Fix:**
1. Identify what this document relates to
2. Add relationship in sidecar:
   ```yaml
   related:
     - doc_id: DOC-XXX-NNN
       type: references
       why: "Explains the connection"
   ```
3. Re-run validation

### Broken Link

**Cause:** Referenced DOC-ID doesn't exist (renamed, deleted, typo)
**Fix:**
1. Check if DOC-ID was renamed → update reference
2. Check if document was deleted → remove relationship
3. Check for typo → correct DOC-ID

### Missing Sidecar

**Cause:** Document created without MLDA protocol
**Fix:**
1. Create sidecar using template:
   ```bash
   .\.mlda\scripts\mlda-create.ps1 -ExistingDoc "path/to/doc.md"
   ```
2. Or manually create `.meta.yaml` with required fields

### Circular Dependency

**Cause:** A depends-on B, B depends-on A
**Fix:**
1. Determine which dependency is actually required
2. Change one to `references` (weaker signal)
3. Or restructure documents to break cycle

## Output

1. **Validation report** to console or file
2. **Update registry** with validation timestamp
3. **List of actionable issues** with severity

## Integration with Workflow

### When to Run

| Trigger | Reason |
|---------|--------|
| After creating documents | Ensure new docs are connected |
| Before handoff | Verify graph health before phase transition |
| After splitting documents | Ensure relationships updated correctly |
| Periodically | Maintenance health check |

### Handoff Integration

Add to `docs/handoff.md`:
```markdown
## Document Statistics

**MLDA Validation:** HEALTHY
**Last Validated:** {timestamp}

**By Domain:**
- AUTH: 12 documents
- API: 15 documents
- DATA: 10 documents

**Relationship Health:**
- Orphan documents: 0
- Broken links: 0
```

## Key Principles

- Run validation after any document changes
- Fix errors before proceeding with workflow
- Warnings indicate technical debt - schedule fixes
- Orphan documents are "dead neurons" - connect or remove them
- Strong connectivity = healthy knowledge graph
