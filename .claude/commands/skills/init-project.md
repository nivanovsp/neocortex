---
description: 'Initialize new project with optional MLDA documentation scaffolding'
---
# Initialize Project Skill

**RMS Skill v2.0** | Project initialization with MLDA (Modular Linked Documentation Architecture) and Neocortex setup

## Purpose

When starting a new project or folder that will contain significant documentation, this skill:

1. Assesses documentation scope
2. Scaffolds MLDA infrastructure if threshold is met
3. Sets up domain-specific folders
4. Initializes the document registry

## Execution Flow

### Step 1: Assess Documentation Scope

Ask the user:

```
What is the expected documentation volume for this project?

1. Documentation-heavy (15+ documents expected) - MLDA recommended
2. Code-focused (fewer than 15 documents) - Manual linking sufficient
3. Not sure yet - I'll help you assess

Select 1-3:
```

**If option 1:** Proceed to Step 2
**If option 2:** Inform user they can run this skill later if needs change. Exit.
**If option 3:** Ask clarifying questions about project scope, then recommend based on answers.

### Step 2: Select Documentation Domains

Present domain options:

```
Select documentation domains for this project (comma-separated numbers):

1. API - API specifications, endpoints, contracts
2. AUTH - Authentication, authorization, identity
3. DATA - Data models, schemas, migrations
4. INV - Invoicing, billing, payments
5. SEC - Security, compliance, auditing
6. UI - User interface, components, UX
7. INFRA - Infrastructure, DevOps, deployment
8. INT - Integrations, third-party services
9. TEST - Testing strategies, test plans
10. DOC - General documentation, guides
11. Custom domain (specify)

Example: 1,3,5 or 1-5,8

Select domains:
```

### Step 3: Confirm Target Location

```
MLDA will be initialized at: {current_directory}/.mlda/

Confirm location?
1. Yes, proceed
2. No, specify different path
3. Cancel

Select 1-3:
```

### Step 4: Execute Scaffolding

Run the scaffolding process:

1. **Create `.mlda/` folder structure (Neocortex v2):**
   ```
   .mlda/
   ├── docs/
   │   └── {selected-domains}/
   ├── schemas/                    # NEW in v2
   │   └── sidecar-v2.schema.yaml
   ├── scripts/
   │   ├── mlda-create.ps1
   │   ├── mlda-registry.ps1
   │   ├── mlda-validate.ps1
   │   ├── mlda-learning.ps1       # NEW in v2 (topic learning)
   │   └── mlda-brief.ps1
   ├── templates/
   │   ├── topic-doc.md
   │   ├── topic-meta-v2.yaml      # v2 sidecar template
   │   ├── topic-domain.yaml       # NEW in v2 (domain decomposition)
   │   └── topic-learning.yaml     # NEW in v2 (topic learnings)
   ├── topics/                     # NEW in v2 (Neocortex topic-based learning)
   │   └── {domain}/
   │       ├── domain.yaml         # Sub-domain structure
   │       └── learning.yaml       # Accumulated learnings
   ├── config.yaml                 # NEW in v2 (Neocortex config)
   ├── registry.yaml
   └── README.md
   ```

2. **Copy scripts from methodology source** (if available) or create new ones

3. **Initialize registry.yaml:**
   ```yaml
   # MLDA Document Registry
   project: {project_name}
   created: {date}
   domains: [{selected_domains}]
   schema_version: "2.0"           # v2 indicator

   documents: []
   ```

4. **Initialize config.yaml (Neocortex v2):**
   ```yaml
   # Neocortex Configuration
   version: "2.0"

   context_limits:
     soft_threshold_tokens: 35000
     hardstop_tokens: 50000
     soft_threshold_documents: 8
     hardstop_documents: 12

   topic_learning:
     enabled: true
     auto_save: false              # Prompt before saving
     min_sessions_for_grouping: 3

   validation:
     require_domain: true
     require_summary: true
     require_relationships: true
     warn_missing_predictions: true
   ```

4. **Create README.md** with project-specific instructions

### Step 5: Provide Next Steps

```
MLDA initialized successfully with Neocortex v2 support!

Created:
- .mlda/docs/{domains}/
- .mlda/schemas/ (v2 schema)
- .mlda/scripts/ (5 scripts including mlda-learning.ps1)
- .mlda/templates/ (4 templates including v2 sidecar)
- .mlda/topics/ (topic-based learning folders)
- .mlda/config.yaml (Neocortex configuration)
- .mlda/registry.yaml
- .mlda/README.md

Next steps:
1. Create new documents: .mlda/scripts/mlda-create.ps1 -Title "Doc Name" -Domain API
2. Rebuild registry: .mlda/scripts/mlda-registry.ps1
3. Validate links: .mlda/scripts/mlda-validate.ps1

Neocortex features:
- Topic learning persists across sessions in .mlda/topics/{domain}/learning.yaml
- Use *gather-context to load topic learnings when starting work
- Sidecars support predictions, boundaries, and reference_frames (v2)

For existing documents, add .meta.yaml sidecars manually or use migration guidance.
```

## Domain Codes Reference

| Code | Domain | DOC-ID Format |
|------|--------|---------------|
| API | API specifications | DOC-API-NNN |
| AUTH | Authentication | DOC-AUTH-NNN |
| DATA | Data models | DOC-DATA-NNN |
| INV | Invoicing | DOC-INV-NNN |
| SEC | Security | DOC-SEC-NNN |
| UI | User Interface | DOC-UI-NNN |
| INFRA | Infrastructure | DOC-INFRA-NNN |
| INT | Integrations | DOC-INT-NNN |
| TEST | Testing | DOC-TEST-NNN |
| DOC | General docs | DOC-DOC-NNN |

Custom domains use format: DOC-{CUSTOM}-NNN

## Migration Mode

If existing documents are detected in the target folder, offer migration:

```
Detected {N} existing markdown files in this folder.

Would you like to:
1. Scaffold MLDA and migrate existing docs (add .meta.yaml sidecars)
2. Scaffold MLDA only (migrate manually later)
3. Cancel

Select 1-3:
```

**If option 1:**
- Create `.meta.yaml` sidecar for each existing `.md` file
- Assign DOC-IDs sequentially
- Add to registry.yaml
- Report: "Migrated {N} documents. Review .meta.yaml files to add relationships."

## Error Handling

| Situation | Response |
|-----------|----------|
| `.mlda/` already exists | Ask: Overwrite, merge, or cancel? |
| No write permission | Report error, suggest alternative location |
| Invalid domain code | Show valid options, ask again |
| Script copy fails | Create minimal scripts inline |

## Dependencies

```yaml
scripts:
  - mlda-init-project.ps1
  - mlda-create.ps1
  - mlda-registry.ps1
  - mlda-validate.ps1
  - mlda-learning.ps1            # v2 topic learning
  - mlda-brief.ps1
templates:
  - topic-doc.md
  - topic-meta-v2.yaml           # v2 sidecar template
  - topic-domain.yaml            # v2 domain decomposition
  - topic-learning.yaml          # v2 topic learnings
schemas:
  - sidecar-v2.schema.yaml       # v2 schema
configs:
  - neocortex-config.yaml        # v2 default config template
```

## Invocation

This skill can be invoked via:
- `/skills:init-project`
- `*init-project` (when in analyst mode)
- `*init-mlda` (alias)
