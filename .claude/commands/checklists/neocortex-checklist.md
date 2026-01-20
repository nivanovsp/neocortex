# Neocortex Compliance Checklist

This checklist validates that a project properly implements the Neocortex methodology - the knowledge graph documentation architecture where documents form neurons, relationships form dendrites, and agents navigate via signal propagation.

[[LLM: INITIALIZATION INSTRUCTIONS

Before proceeding with this checklist, gather the following:

1. Check if `.mlda/` directory exists
2. Check if `.mlda/config.yaml` exists
3. Check if `.mlda/registry.yaml` exists
4. List contents of `.mlda/schemas/` if present
5. List any `.meta.yaml` sidecar files in the project
6. Check if `.mlda/topics/` directory exists

VALIDATION APPROACH:
For each section, you must:

1. Verify presence - Check if required files/folders exist
2. Validate structure - Ensure correct format and required fields
3. Check relationships - Verify links are valid (not broken)
4. Assess completeness - Identify gaps in coverage

EXECUTION MODE:
Ask the user if they want to work through the checklist:

- Section by section (interactive mode)
- All at once (comprehensive mode)
- Targeted validation (specific section only)]]

## 1. FOLDER STRUCTURE

[[LLM: The MLDA folder structure is the foundation. Without correct structure, the knowledge graph cannot function. Check for the essential directories and files that enable Neocortex operation.]]

### 1.1 Required Root Structure

- [ ] `.mlda/` directory exists at project root
- [ ] `.mlda/registry.yaml` exists (document index)
- [ ] `.mlda/README.md` exists (quick start guide)
- [ ] `.mlda/scripts/` directory exists with utility scripts

### 1.2 Optional Neocortex v2 Structure

- [ ] `.mlda/config.yaml` exists (Neocortex configuration)
- [ ] `.mlda/schemas/` directory exists with validation schemas
- [ ] `.mlda/templates/` directory exists for document scaffolding
- [ ] `.mlda/topics/` directory exists for topic-based learning
- [ ] `.mlda/docs/` directory exists for topic documents (alternative to `docs/`)

### 1.3 Documentation Structure

- [ ] `docs/` directory exists for project documentation
- [ ] `docs/decisions/` directory exists for decision records
- [ ] `docs/handoff.md` exists (phase transition document)
- [ ] `CLAUDE.md` exists at project root with methodology rules

### 1.4 Scripts Presence

- [ ] `mlda-create.ps1` exists (document scaffolding)
- [ ] `mlda-registry.ps1` exists (registry management)
- [ ] `mlda-validate.ps1` exists (link integrity checking)
- [ ] `mlda-learning.ps1` exists (topic learning management) [v2 only]

## 2. CONFIGURATION COMPLIANCE

[[LLM: The config.yaml file controls Neocortex behavior. If present, it must conform to the neocortex-config.schema.yaml specification. Even if optional, misconfigurations can cause unexpected agent behavior.]]

### 2.1 Config File Presence

- [ ] `.mlda/config.yaml` exists (optional but recommended)
- [ ] Config file is valid YAML syntax
- [ ] Config has required `version` field

### 2.2 Context Limits Configuration

- [ ] `context_limits.soft_threshold_tokens` is within valid range (10000-100000)
- [ ] `context_limits.hardstop_tokens` is within valid range (20000-150000)
- [ ] `context_limits.soft_threshold_documents` is within valid range (3-30)
- [ ] `context_limits.hardstop_documents` is within valid range (5-50)
- [ ] Soft thresholds are less than hard thresholds

If `by_task_type` overrides present:

- [ ] Each task type key is valid (research, document_creation, review, architecture, etc.)
- [ ] Each override has `soft_threshold` within valid token range
- [ ] Each override has `hardstop` within valid token range
- [ ] Soft thresholds are less than hardstops for each task type

### 2.3 Learning Configuration

- [ ] `learning.auto_save_prompt` is boolean if present
- [ ] `learning.activation_logging` is boolean if present
- [ ] `learning.min_activation_frequency` is positive integer if present
- [ ] `learning.max_learnings_per_topic` is within range (10-1000) if present

### 2.4 Verification Configuration

- [ ] `verification.extraction_template` is valid enum if present (standard|minimal|comprehensive)
- [ ] `verification.cross_verification_domains` is array of strings if present
- [ ] `verification.cross_verification_threshold` is within range (1-20) if present

### 2.5 Multi-Agent Configuration

- [ ] `multi_agent.max_recursion_depth` is within range (1-5) if present
- [ ] `multi_agent.max_parallel_agents` is within range (1-10) if present
- [ ] `multi_agent.decomposition_strategy` is valid enum if present

### 2.6 Navigation Configuration

- [ ] `navigation.max_traversal_depth` is within range (1-10) if present
- [ ] Boolean fields (`follow_weak_links`, `respect_boundaries`, `two_phase_loading`) are valid

## 3. SIDECAR COMPLIANCE

[[LLM: Sidecars are the metadata that make the knowledge graph navigable. Every document should have a companion .meta.yaml file. Required fields must be present; relationships must reference valid DOC-IDs.]]

### 3.1 Sidecar Presence

- [ ] Every `.md` document in `docs/` has a corresponding `.meta.yaml` sidecar
- [ ] Sidecars are named `{document-name}.meta.yaml` (matching the .md file)
- [ ] No orphan sidecars (sidecars without matching documents)

### 3.2 Required Fields

For each sidecar, verify:

- [ ] `id` field exists and matches pattern `DOC-{DOMAIN}-{NNN}` (e.g., DOC-AUTH-001)
- [ ] `title` field exists and is non-empty (1-200 characters)
- [ ] `status` field exists and is valid enum (draft|review|active|deprecated)

### 3.3 Timestamp Fields

- [ ] `created.date` is valid ISO date format (YYYY-MM-DD) if present
- [ ] `created.by` is non-empty string if created block present
- [ ] `updated.date` is valid ISO date format if present
- [ ] `updated.by` is non-empty string if updated block present

### 3.4 Classification Fields

- [ ] `domain` matches pattern `^[A-Z]+$` if present (e.g., AUTH, API, SEC)
- [ ] `domain` in `id` field matches `domain` field if both present
- [ ] `tags` is array of lowercase hyphenated strings if present

### 3.5 Relationship Fields

For each `related` entry:

- [ ] `id` matches DOC-ID pattern `^DOC-[A-Z]+-[0-9]{3}$`
- [ ] `type` is valid enum (depends-on|extends|references|supersedes)
- [ ] `why` field exists and is non-empty (explains the relationship)
- [ ] Referenced DOC-ID exists in registry (no broken links)

### 3.6 Predictive Context Fields (v2)

If `predictions` block present:

- [ ] Task type keys are valid (when_eliciting, when_documenting, when_architecting, when_reviewing_design, when_implementing, when_debugging, when_testing)
- [ ] `required` arrays contain valid DOC-IDs
- [ ] `likely` arrays contain valid DOC-IDs
- [ ] Referenced DOC-IDs exist in registry

### 3.7 Reference Frames Fields (v2)

If `reference_frames` block present:

- [ ] `domain` field exists and describes the problem space (e.g., authentication, invoicing)
- [ ] `layer` is valid enum (requirements|design|implementation|testing)
- [ ] `stability` is valid enum (evolving|stable|deprecated)
- [ ] `scope` is valid enum (frontend|backend|infrastructure|cross-cutting)

### 3.8 Boundary Fields (v2)

If `boundaries` block present:

- [ ] `related_domains` is array of strings
- [ ] `isolated_from` is array of strings
- [ ] No overlap between `related_domains` and `isolated_from`

### 3.9 Critical Markers Flag

- [ ] If document contains `<!-- CRITICAL -->` markers, `has_critical_markers: true` is set
- [ ] If `has_critical_markers: true`, document actually contains CRITICAL markers

## 4. REGISTRY COMPLIANCE

[[LLM: The registry.yaml is the index of all documents. It must be complete and accurate for navigation to work. Run mlda-registry.ps1 to regenerate if needed.]]

### 4.1 Registry Structure

- [ ] Registry file exists at `.mlda/registry.yaml`
- [ ] Registry is valid YAML syntax
- [ ] Registry has `documents` array

### 4.2 Registry Completeness

- [ ] All documents with sidecars are listed in registry
- [ ] No phantom entries (registry entries without actual documents)
- [ ] DOC-IDs in registry match sidecar `id` fields

### 4.3 Registry Consistency

- [ ] All DOC-IDs are unique (no duplicates)
- [ ] DOC-IDs follow sequential numbering within domains
- [ ] File paths in registry are correct and resolvable

## 5. TOPIC LEARNING COMPLIANCE (v2)

[[LLM: Topic-based learning is optional but enables persistent context across sessions. If the topics folder exists, validate its structure.]]

### 5.1 Topics Folder Structure

- [ ] `.mlda/topics/` directory exists (optional)
- [ ] Each topic has its own subdirectory
- [ ] Topic directories are lowercase hyphenated names

### 5.2 Domain File Compliance

For each `domain.yaml` file:

- [ ] `domain` field exists and matches directory name
- [ ] `version` is positive integer
- [ ] `last_updated` is valid ISO date
- [ ] `source` is valid enum if present (human|agent|hybrid)

If `sub_domains` array present:

- [ ] Each sub-domain has `name` field (lowercase hyphenated)
- [ ] Each sub-domain has `docs` array with valid DOC-IDs
- [ ] Each sub-domain has `origin` field (human|agent)
- [ ] If origin is `agent`, `discovered_during` field documents the task
- [ ] If origin is `agent`, `human_approved` boolean indicates review status
- [ ] DOC-IDs in sub-domains exist in registry

If `entry_points` block present:

- [ ] `default` is a valid DOC-ID
- [ ] `by_task` entries map task types to valid DOC-IDs

If `decomposition` block present:

- [ ] `strategy` is valid enum (by_sub_domain|by_document_count|by_task_type|custom)
- [ ] `max_docs_per_agent` is within range (1-20) if present
- [ ] `parallel_allowed` is boolean if present

### 5.3 Learning File Compliance

For each `learning.yaml` file:

**Required fields:**

- [ ] `topic` field exists and matches directory name
- [ ] `version` is positive integer
- [ ] `last_updated` is valid ISO date

**Optional tracking field:**

- [ ] `sessions_contributed` is non-negative integer if present

**Groupings array (if present):**

- [ ] Each grouping has `name` field (lowercase hyphenated)
- [ ] Each grouping has `docs` array with valid DOC-IDs
- [ ] Each grouping has `origin` field (human|agent)
- [ ] Each grouping has `confidence` field if present (high|medium|low)
- [ ] If origin is `agent`, `discovered_during` documents the task
- [ ] DOC-IDs in groupings exist in registry

**Activations array (if present):**

- [ ] Each activation has `docs` array with at least 2 DOC-IDs
- [ ] Each activation has `frequency` as positive integer
- [ ] Each activation has `typical_tasks` array with valid task types (eliciting, documenting, architecting, reviewing_design, implementing, debugging, testing)
- [ ] DOC-IDs in activations exist in registry

**Verification notes array (if present):**

- [ ] Each note has `session` as valid ISO date
- [ ] Each note has `caught` field describing what was found
- [ ] Each note has `lesson` field describing the learning

**Related domains array (if present):**

- [ ] Each entry has `domain` field
- [ ] Each entry has `relationship` field describing the connection
- [ ] `typical_overlap` DOC-IDs exist in registry if present

### 5.4 Cross-Domain Patterns

- [ ] `_cross-domain/` directory exists if cross-domain patterns are used
- [ ] `patterns.yaml` follows expected structure

## 6. DOCUMENT QUALITY

[[LLM: Beyond structural compliance, documents should be well-connected (not isolated neurons) and follow Neocortex conventions.]]

### 6.1 Connectivity

- [ ] No isolated documents (documents with zero relationships)
- [ ] No orphan documents (documents not referenced by any other document)
- [ ] Dependency chains are resolvable (no circular depends-on)

### 6.2 Critical Markers

- [ ] CRITICAL markers use correct syntax: `<!-- CRITICAL: {type} -->`
- [ ] CRITICAL markers have closing tags: `<!-- /CRITICAL -->`
- [ ] Critical content is between opening and closing markers

### 6.3 DOC-ID Usage in Documents

- [ ] Document content references other docs by DOC-ID (not file paths)
- [ ] Referenced DOC-IDs in document body exist in registry

### 6.4 Status Lifecycle

- [ ] No `active` documents with broken relationships
- [ ] `deprecated` documents have `supersedes` relationships pointing to them
- [ ] `draft` documents are not heavily depended upon

## 7. SCHEMA COMPLIANCE

[[LLM: If schemas are present, all files should validate against them. This ensures consistency and catches errors early.]]

### 7.1 Schema Presence

- [ ] `sidecar-v2.schema.yaml` exists in `.mlda/schemas/`
- [ ] `neocortex-config.schema.yaml` exists in `.mlda/schemas/`
- [ ] `topic-learning.schema.yaml` exists in `.mlda/schemas/`
- [ ] `topic-domain.schema.yaml` exists in `.mlda/schemas/`

### 7.2 Schema Validation

- [ ] All sidecars validate against sidecar-v2.schema.yaml
- [ ] Config file validates against neocortex-config.schema.yaml
- [ ] Learning files validate against topic-learning.schema.yaml
- [ ] Domain files validate against topic-domain.schema.yaml

## 8. INTEGRATION COMPLIANCE

[[LLM: Neocortex integrates with other methodology components. Verify these integration points.]]

### 8.1 Beads Integration

- [ ] `beads` field in sidecars references valid task IDs if present
- [ ] Stories reference DOC-IDs in documentation sections

### 8.2 Handoff Integration

- [ ] Handoff document references DOC-IDs for context
- [ ] Phase transitions update handoff.md

### 8.3 RMS Framework Integration

- [ ] Modes have access to navigation commands (*explore, *related, *context)
- [ ] Skills for context gathering are available
- [ ] CLAUDE.md documents Neocortex protocol

[[LLM: FINAL VALIDATION REPORT GENERATION

After completing the checklist, generate a compliance report:

1. Compliance Summary
   - Overall compliance level (Full/Partial/Minimal/None)
   - Neocortex version detected (v1 basic / v2 full)
   - Total documents in knowledge graph
   - Average connectivity (relationships per document)

2. Section Results
   - Pass rate for each major section
   - Critical failures requiring immediate attention
   - Warnings for recommended improvements

3. Knowledge Graph Health
   - Isolated neurons (documents with no relationships)
   - Orphan neurons (documents not referenced by others)
   - Broken dendrites (invalid DOC-ID references)
   - Dead neurons (deprecated without supersession)

4. Recommendations
   - Must-fix: Compliance blockers
   - Should-fix: Quality improvements
   - Consider: Optional enhancements

5. Remediation Commands
   - Specific commands to fix issues (e.g., `mlda-registry.ps1` to rebuild registry)
   - Scripts to run for validation

After presenting the report, ask if the user wants:
- Detailed analysis of any section
- Help fixing specific issues
- Guidance on upgrading to full v2 compliance]]
