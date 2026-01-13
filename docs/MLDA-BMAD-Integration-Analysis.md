# MLDA + BMAD Integration Analysis

**Document ID:** DOC-WOD-006
**Version:** 1.0
**Created:** 2026-01-12
**Created By:** Mary (Business Analyst)
**Purpose:** Team discussion document for integration strategy

---

## Related Documents

- [DOC-WOD-005: Framework Synthesis](Phase5-Framework-Synthesis.md) - Complete MLDA framework specification

---

## Executive Summary

This document analyzes how the **Modular Linked Documentation Architecture (MLDA)** can be integrated with the existing **BMAD** methodology and **Beads** issue tracking. Three integration strategies are presented with their trade-offs, along with detailed technical integration points.

---

## Part 1: Current BMAD Architecture

### Folder Structure

```
.bmad-core/
├── core-config.yaml      # Project configuration (paths, versions, sharding)
├── agents/               # Agent personas (analyst, architect, pm, dev, etc.)
│   ├── analyst.md
│   ├── architect.md
│   ├── pm.md
│   ├── po.md
│   ├── dev.md
│   ├── qa.md
│   └── ...
├── tasks/                # Executable workflows
│   ├── create-doc.md     # Template-driven document creation
│   ├── create-next-story.md
│   ├── qa-gate.md
│   └── ...
├── templates/            # YAML document templates
│   ├── project-brief-tmpl.yaml
│   ├── prd-tmpl.yaml
│   ├── architecture-tmpl.yaml
│   └── ...
├── checklists/           # Validation checklists
├── workflows/            # High-level workflow definitions (greenfield, brownfield)
├── data/                 # Knowledge base files
└── utils/                # Utilities
```

### Key Observations

1. **Template-driven creation**: The `create-doc.md` task combined with YAML templates drives all document creation
2. **Agent-specific commands**: Each agent has commands mapped to specific tasks + templates
3. **Sharding already exists**: `prdSharded: true` in core-config.yaml means BMAD already supports modular documents
4. **Interactive workflow**: Elicitation pattern (1-9 options) for step-by-step creation with user feedback
5. **Agent personas**: Each agent has defined role, commands, and dependencies

### Current core-config.yaml

```yaml
markdownExploder: true
qa:
  qaLocation: docs/qa
prd:
  prdFile: docs/prd.md
  prdVersion: v4
  prdSharded: true
  prdShardedLocation: docs/prd
  epicFilePattern: epic-{n}*.md
architecture:
  architectureFile: docs/architecture.md
  architectureVersion: v4
  architectureSharded: true
  architectureShardedLocation: docs/architecture
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/source-tree.md
devDebugLog: .ai/debug-log.md
devStoryLocation: docs/stories
```

---

## Part 2: Integration Strategy Options

### Option A: MLDA as BMAD Extension (Additive)

Add MLDA components alongside existing BMAD structures without replacing anything.

```
.bmad-core/
├── core-config.yaml           # Add MLDA config section
├── templates/
│   ├── topic-doc-tmpl.yaml         # NEW - Core topic document
│   ├── topic-meta-tmpl.yaml        # NEW - Sidecar metadata
│   ├── session-manifest-tmpl.yaml  # NEW - Session tracking
│   ├── decision-log-tmpl.yaml      # NEW - Decision tracking
│   ├── pattern-tmpl.yaml           # NEW - Reusable patterns
│   ├── project-brief-tmpl.yaml     # EXISTING - kept
│   ├── prd-tmpl.yaml               # EXISTING - kept
│   └── architecture-tmpl.yaml      # EXISTING - kept
├── tasks/
│   ├── create-topic-doc.md         # NEW - Creates topic + meta pair
│   ├── generate-registry.md        # NEW - Rebuilds doc-registry.yaml
│   ├── generate-brief.md           # NEW - Auto-generates brief from registry
│   ├── generate-requirements-index.md  # NEW - Aggregates requirements
│   ├── create-session-manifest.md  # NEW - End-of-session summary
│   ├── validate-links.md           # NEW - Validates DOC-ID references
│   ├── impact-analysis.md          # NEW - "What links here"
│   ├── create-doc.md               # EXISTING - kept
│   └── ...
├── data/
│   ├── mlda-guidelines.md          # NEW - Framework reference for agents
│   ├── doc-id-domains.yaml         # NEW - Valid domain codes
│   └── ...
└── agents/                         # UPDATE - Add MLDA protocol awareness
```

**Pros:**
- Minimal disruption to existing workflow
- Teams can adopt MLDA gradually
- Existing documents still work
- Low risk

**Cons:**
- Two systems coexisting (old templates + MLDA)
- Potential confusion about which approach to use
- May lead to inconsistent documentation

**Best for:** Gradual adoption, risk-averse teams, existing projects with lots of docs

---

### Option B: MLDA Replaces Core Templates (Transformative)

Replace existing monolithic templates with MLDA modular approach entirely.

```
.bmad-core/
├── core-config.yaml           # Rewritten for MLDA-first approach
├── templates/
│   ├── topic-doc-tmpl.yaml         # Core template for ALL topics
│   ├── topic-meta-tmpl.yaml        # Sidecar metadata
│   ├── session-manifest-tmpl.yaml  # Session tracking
│   ├── decision-log-tmpl.yaml      # Decision tracking
│   ├── pattern-tmpl.yaml           # Reusable patterns
│   └── (REMOVED: prd-tmpl, architecture-tmpl, project-brief-tmpl)
│       # These become auto-generated indexes, not templates
├── tasks/
│   ├── create-topic-doc.md         # Primary creation task
│   ├── generate-indexes.md         # Generates PRD, Brief, Arch from topics
│   ├── generate-registry.md
│   ├── validate-links.md
│   ├── impact-analysis.md
│   └── ...
├── generators/                     # NEW - Index generation logic
│   ├── project-brief-generator.md
│   ├── requirements-index-generator.md
│   └── architecture-index-generator.md
└── agents/                         # Rewritten with MLDA as core approach
```

**Pros:**
- Clean, unified system
- No ambiguity about which approach to use
- Full benefits of MLDA from day one
- Consistent documentation across all projects

**Cons:**
- Breaking change - existing workflows disrupted
- Migration effort for existing documents
- Learning curve for team
- Higher initial investment

**Best for:** New projects, teams ready for full commitment, clean-slate scenarios

---

### Option C: MLDA as Parallel Layer (Separate)

MLDA lives alongside BMAD as a completely separate system.

```
.bmad-core/               # UNCHANGED - existing BMAD
├── core-config.yaml
├── agents/
├── tasks/
├── templates/
└── ...

.mlda/                    # NEW - parallel MLDA structure
├── config.yaml           # MLDA-specific configuration
├── registry/
│   └── doc-registry.yaml
├── templates/
│   ├── topic-doc-tmpl.yaml
│   ├── topic-meta-tmpl.yaml
│   └── ...
├── tasks/
│   ├── create-topic-doc.md
│   ├── generate-registry.md
│   └── ...
├── generators/
│   ├── brief-generator.md
│   └── requirements-index-generator.md
└── docs/                 # MLDA-managed documents
    ├── topics/
    ├── patterns/
    └── manifests/
```

**Pros:**
- Zero changes to BMAD
- Clear separation of concerns
- Can experiment with MLDA without risk
- Easy to remove if it doesn't work

**Cons:**
- Duplication of concepts
- Two places to maintain
- Agents need to know about both systems
- Potential for docs to fall out of sync

**Best for:** Experimentation, teams unsure about commitment, parallel evaluation

---

## Part 3: Detailed Integration Points

### 3.1 core-config.yaml Changes

Regardless of strategy, MLDA needs configuration:

```yaml
# Existing BMAD config
prd:
  prdFile: docs/prd.md
  prdSharded: true
  prdShardedLocation: docs/prd

# NEW: MLDA configuration section
mlda:
  enabled: true

  # Registry configuration
  registryFile: docs/doc-registry.yaml
  autoGenerateRegistry: true

  # Topic documents
  topicDocsLocation: docs/topics
  metadataSidecar: true  # Use .meta.yaml files

  # Auto-generation
  autoGenerateBrief: true
  briefOutputFile: docs/project-brief.md
  autoGenerateRequirementsIndex: true
  requirementsIndexFile: docs/requirements-index.md

  # DOC-ID configuration
  docIdPrefix: "DOC"
  docIdDomains:
    - code: AUTH
      name: Authentication
    - code: UM
      name: User Management
    - code: ONBOARD
      name: Onboarding
    - code: BILL
      name: Billing
    - code: API
      name: API Design
    - code: UI
      name: User Interface
    - code: DATA
      name: Data Models
    - code: INT
      name: Integrations
    - code: SEC
      name: Security
    - code: PERF
      name: Performance

  # Session management
  sessionManifestsLocation: docs/sessions
  autoCreateSessionManifest: true

  # Beads integration
  beadsIntegration:
    enabled: true
    autoScaffoldOnCreate: true
    linkBeadIdInMeta: true

  # Validation
  validateLinksOnSave: true
  detectStaleDocsAfterDays: 30
  detectOrphanDocs: true
```

### 3.2 Agent Instruction Updates

Each agent needs MLDA protocol awareness added to their definition:

```yaml
# Addition to agent YAML files
mlda_protocol:
  awareness:
    - Understand MLDA modular documentation approach
    - Know the DOC-ID convention: DOC-{DOMAIN}-{NNN}
    - Recognize topic documents vs. auto-generated indexes

  document_creation:
    - Always create topic documents, not monolithic documents
    - Each topic doc must have a companion .meta.yaml sidecar
    - Assign DOC-ID from appropriate domain
    - Include all required frontmatter sections

  linking:
    - Use DOC-IDs when referencing other documents
    - Update related_docs in sidecar when creating links
    - Specify relationship type (extends, references, depends-on)

  session_management:
    - Generate session manifest at end of each session
    - Record documents created/modified
    - Capture decisions made during session
    - Note open questions for follow-up

  registry:
    - Propose registry regeneration after creating new docs
    - Use registry for document discovery
    - Check "what links here" before modifying docs
```

### 3.3 New Tasks Required

| Task | Purpose | Description |
|------|---------|-------------|
| `create-topic-doc.md` | Primary creation | Creates paired .md + .meta.yaml files, assigns DOC-ID, scaffolds structure |
| `generate-registry.md` | Registry management | Scans all .meta.yaml files, rebuilds doc-registry.yaml |
| `generate-brief.md` | Brief compilation | Reads registry, pulls summaries, generates Project Brief |
| `generate-requirements-index.md` | Requirements aggregation | Extracts requirements from all topics, creates index |
| `create-session-manifest.md` | Session tracking | End-of-session summary with docs, decisions, questions |
| `validate-links.md` | Link validation | Checks all DOC-ID references resolve to real documents |
| `impact-analysis.md` | Change analysis | Shows "what links here" for a document before changes |
| `deprecate-doc.md` | Safe deprecation | Converts doc to tombstone, updates links |
| `merge-docs.md` | Document merge | Combines two docs, updates all references |
| `split-doc.md` | Document split | Divides doc, updates all references |

### 3.4 New Templates Required

| Template | Purpose | Key Sections |
|----------|---------|--------------|
| `topic-doc-tmpl.yaml` | Standard topic document | Summary (3 tiers), Content, Requirements, Decisions, Open Questions, Change Log |
| `topic-meta-tmpl.yaml` | Sidecar metadata | ID, version, status, tags, context info, relationships, beads links |
| `session-manifest-tmpl.yaml` | Session summary | Participants, beads context, docs touched, decisions, next steps |
| `decision-log-tmpl.yaml` | Decision tracking | Context, options, rationale, stakeholders, date |
| `pattern-tmpl.yaml` | Reusable patterns | When to use, implementation, examples, anti-patterns |
| `requirements-index-tmpl.yaml` | Requirements view | By domain, by priority, with source links |

### 3.5 Beads Integration

Three possible approaches for Beads + MLDA integration:

#### Approach 1: Automated Hook (Recommended)

Create a Beads hook/plugin that auto-scaffolds documents:

```bash
# When user runs:
bd create "Access Control Patterns" -t task --domain AUTH

# Beads hook automatically:
# 1. Creates the bead issue
# 2. Scaffolds docs/topics/auth/access-control-patterns.md
# 3. Scaffolds docs/topics/auth/access-control-patterns.meta.yaml
# 4. Links bead ID in the meta.yaml
# 5. Adds to doc-registry.yaml
```

**Implementation:** Beads post-create hook script

#### Approach 2: Wrapper Script

Create a wrapper command that combines both:

```bash
# Custom command:
mlda-create "Access Control Patterns" --domain AUTH --type task

# Internally runs:
# 1. bd create "Access Control Patterns" -t task
# 2. Creates topic doc + meta
# 3. Links them
```

**Implementation:** Shell script or CLI tool

#### Approach 3: Manual Protocol

Agent follows protocol manually:

1. Agent creates bead via `bd create`
2. Agent runs `*create-topic-doc` task
3. Agent links bead ID in meta.yaml
4. Agent triggers registry update

**Implementation:** Agent instructions only

---

## Part 4: Key Decision Points

### Question 1: Integration Strategy

| Option | Risk Level | Effort | Best For |
|--------|------------|--------|----------|
| A: Extension | Low | Medium | Gradual adoption, existing projects |
| B: Replacement | High | High | New projects, full commitment |
| C: Parallel | Low | Medium | Experimentation, evaluation |

**Recommendation:** Start with **Option A** (Extension), with a path to migrate toward **Option B** over time.

### Question 2: MLDA Coupling to BMAD

| Coupling | Description | Trade-off |
|----------|-------------|-----------|
| Tight | MLDA IS how BMAD works | Maximum integration, minimum flexibility |
| Loose | MLDA is optional layer | Maximum flexibility, potential inconsistency |

**Recommendation:** **Loose coupling initially**, tighten as MLDA proves value.

### Question 3: Beads Scaffolding

| Approach | Automation | Complexity |
|----------|------------|------------|
| Hook | Full auto | Requires Beads modification |
| Wrapper | Semi-auto | New tooling to maintain |
| Manual | None | Relies on discipline |

**Recommendation:** **Wrapper script** as middle ground - automates without modifying Beads core.

### Question 4: Migration Approach

| Approach | Risk | Effort |
|----------|------|--------|
| Fresh start | None | N/A for existing |
| Gradual migration | Low | Ongoing |
| Big bang migration | High | One-time |

**Recommendation:** **Fresh start for new modules**, gradual migration for existing as they're updated.

---

## Part 5: Implementation Phases (Proposed)

### Phase 1: Foundation
- Add MLDA config section to core-config.yaml
- Create topic-doc-tmpl.yaml and topic-meta-tmpl.yaml
- Create create-topic-doc.md task
- Create mlda-guidelines.md in data/
- Test with one new topic document

### Phase 2: Registry & Generation
- Create generate-registry.md task
- Create doc-registry.yaml structure
- Create generate-brief.md task
- Create generate-requirements-index.md task
- Test auto-generation pipeline

### Phase 3: Agent Integration
- Update agent files with MLDA protocol
- Add MLDA commands to relevant agents
- Create session-manifest-tmpl.yaml
- Test end-to-end workflow with agents

### Phase 4: Beads Integration
- Implement chosen scaffolding approach (hook/wrapper/manual)
- Test bead → doc creation flow
- Document integration procedure

### Phase 5: Validation & Tooling
- Create validate-links.md task
- Create impact-analysis.md task
- Add health reporting to registry
- Test validation pipeline

### Phase 6: Advanced Features
- Pattern library structure
- Deprecation/merge/split protocols
- Migration tooling for existing docs

---

## Part 6: Open Questions for Team Discussion

1. **Strategy preference:** Extension (A), Replacement (B), or Parallel (C)?

2. **Beads integration:** Hook, wrapper, or manual protocol?

3. **Who owns the registry?** Auto-generated only, or curated?

4. **Template format:** Keep YAML templates, or simplify?

5. **Agent changes:** Update all agents at once, or roll out gradually?

6. **Existing docs:** Migrate Dominaite docs, or start fresh?

7. **Tooling investment:** Build automation scripts, or rely on manual processes?

8. **Success metrics:** How do we measure if MLDA is working?

---

## Appendix: File References

### BMAD Files Reviewed
- `.bmad-core/core-config.yaml` - Current configuration
- `.bmad-core/tasks/create-doc.md` - Document creation workflow
- `.bmad-core/templates/project-brief-tmpl.yaml` - Template structure example
- `.bmad-core/agents/analyst.md` - Agent definition example

### MLDA Framework Documents
- `Phase1-Problem-Analysis.md` - Pain points identified
- `Phase2-Rapid-Ideation.md` - Solution ideas generated
- `Phase3-Six-Thinking-Hats.md` - Multi-perspective analysis
- `Phase4-SCAMPER-Analysis.md` - Innovation refinements
- `Phase5-Framework-Synthesis.md` - Complete MLDA specification

---

## Change Log

| Version | Date | Author | Change Summary |
|---------|------|--------|----------------|
| 1.0 | 2026-01-12 | Mary (Business Analyst) | Initial creation for team discussion |
