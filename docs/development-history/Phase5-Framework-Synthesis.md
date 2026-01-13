# Phase 5: Framework Synthesis - Modular Linked Documentation Architecture

**Document ID:** DOC-WOD-005
**Version:** 1.0
**Created:** 2026-01-12
**Created By:** Mary (Business Analyst)

---

## Related Documents

- [DOC-WOD-001: Phase 1 Problem Analysis](Phase1-Problem-Analysis.md)
- [DOC-WOD-002: Phase 2 Rapid Ideation](Phase2-Rapid-Ideation.md)
- [DOC-WOD-003: Phase 3 Six Thinking Hats](Phase3-Six-Thinking-Hats.md)
- [DOC-WOD-004: Phase 4 SCAMPER Analysis](Phase4-SCAMPER-Analysis.md)

---

## Executive Summary

This document presents the complete **Modular Linked Documentation Architecture (MLDA)** framework, synthesized from our brainstorming sessions. MLDA replaces monolithic documents with interconnected topic documents, enabling better AI context management, traceability, and living documentation.

---

## Part 1: Core Principles

### 1.1 The Five Pillars

| Pillar | Description |
|--------|-------------|
| **Modularity** | Small, focused topic documents instead of monolithic files |
| **Linkability** | Every document references related docs via DOC-IDs |
| **Traceability** | All changes versioned with author, date, reason |
| **Machine-Readability** | Structured metadata for AI agent consumption |
| **Living Documentation** | Auto-generated indexes, always current |

### 1.2 Key Shifts from Current Practice

| From | To |
|------|-----|
| Comprehensive BA/Arch/PRD documents | Topic documents with role tags |
| Documents created per phase | Documents created per topic/capability |
| Manual cross-referencing | Automated linking via DOC-IDs |
| Project Brief written first | Project Brief auto-generated last |
| PRD as single artifact | Requirements Index aggregating topic docs |
| Context lost between sessions | Session manifests preserve continuity |

---

## Part 2: Document Structure

### 2.1 Document ID Convention

```
DOC-{DOMAIN}-{NNN}

Where:
- DOMAIN = 2-6 character topic area code
- NNN = 3-digit sequential number within domain

Examples:
- DOC-AUTH-001   (Authentication topic #1)
- DOC-ONBOARD-003 (Onboarding topic #3)
- DOC-UM-012     (User Management topic #12)
- DOC-WOD-005    (Ways of Development topic #5)
```

**Rules:**
- IDs are permanent; never change once assigned
- Registry validates uniqueness
- Deleted docs become tombstones (ID reserved forever)

### 2.2 File Structure

Each topic document consists of two files:

```
/docs/{domain}/
  ├── {topic-name}.md           # Content file
  └── {topic-name}.meta.yaml    # Metadata sidecar
```

**Example:**
```
/docs/auth/
  ├── access-control.md
  └── access-control.meta.yaml
```

### 2.3 Content File Template (.md)

```markdown
# {Title}

---

## Summary

**One-liner:** {AI-generated, human-approved}

**Paragraph:** {AI-generated, human-approved}

**Full Summary:**
{Human-written comprehensive summary - 3-5 sentences}

---

## {Main Content Sections}

{Organized by topic, not by phase/role}

---

## Requirements

{If applicable - extracted for Requirements Index}

- REQ-001: {Requirement text}
- REQ-002: {Requirement text}

---

## Decisions

{Key decisions made regarding this topic}

| ID | Decision | Rationale | Date | Stakeholders |
|----|----------|-----------|------|--------------|
| DEC-001 | {What was decided} | {Why} | {When} | {Who} |

---

## Open Questions

{Unresolved items - tracked until closed}

- [ ] {Question 1}
- [ ] {Question 2}

---

## What Links Here

{Auto-generated section - documents that reference this one}

- [DOC-XXX-NNN: Title](path)

---

## Change Log

| Version | Date | Author | Reason | Summary |
|---------|------|--------|--------|---------|
| 1.0 | YYYY-MM-DD | {Agent/Person} | Initial creation | {What} |
```

### 2.4 Metadata Sidecar Template (.meta.yaml)

```yaml
id: DOC-{DOMAIN}-{NNN}
title: "{Document Title}"
path: "/docs/{domain}/{filename}.md"
version: "1.0"
status: active  # active | deprecated | archived

created:
  date: "YYYY-MM-DD"
  by: "{Agent/Person Name}"

updated:
  date: "YYYY-MM-DD"
  by: "{Agent/Person Name}"
  reason: "{Why updated}"

# Role tags (replaces rigid doc types)
tags:
  roles:
    - business-analysis
    - architecture
    - requirements
    - development
  domains:
    - authentication
    - user-management
  topics:
    - rbac
    - permissions

# AI Context Optimization
context:
  token_estimate: 1500  # Approximate tokens
  summary_tier: paragraph  # one-liner | paragraph | full
  priority: high  # high | medium | low (for context budgeting)

# Relationships
related_docs:
  - id: DOC-UM-001
    title: "User Management Core"
    relationship: extends  # extends | references | depends-on | contradicts
  - id: DOC-ONBOARD-003
    title: "Onboarding Access Rules"
    relationship: references

# Beads Integration
beads:
  linked_issues:
    - "ProjectName-42"
    - "ProjectName-43"

# Requirements extraction
requirements:
  count: 5
  ids: [REQ-001, REQ-002, REQ-003, REQ-004, REQ-005]

# Decisions extraction
decisions:
  count: 2
  ids: [DEC-001, DEC-002]
```

---

## Part 3: Registry System

### 3.1 Document Registry (doc-registry.yaml)

Master index of all documents, auto-generated from sidecar files.

```yaml
registry:
  generated: "YYYY-MM-DD HH:MM:SS"
  total_documents: 42

  domains:
    auth:
      count: 8
      documents:
        - id: DOC-AUTH-001
          title: "Access Control Overview"
          path: "/docs/auth/access-control.md"
          status: active
          tags: [rbac, permissions, security]
          token_estimate: 1500
          related_count: 3

    user-management:
      count: 12
      documents:
        - id: DOC-UM-001
          # ...

  # Aggregated views
  by_role:
    business-analysis: [DOC-AUTH-001, DOC-UM-001, ...]
    architecture: [DOC-AUTH-002, ...]
    requirements: [DOC-AUTH-001, DOC-UM-003, ...]

  by_status:
    active: 38
    deprecated: 3
    archived: 1

  # Health metrics
  health:
    orphans: []  # Docs with no incoming links
    stale: [DOC-OLD-001]  # Not updated in 30+ days
    broken_links: []  # References to non-existent docs
```

### 3.2 Project Brief (Auto-Generated)

The Project Brief is compiled from registry + document summaries.

```markdown
# Project Brief: {Project Name}

**Generated:** YYYY-MM-DD HH:MM:SS
**Total Topics:** 42 documents across 8 domains

---

## Domain Overview

### Authentication (8 documents)
{Compiled from DOC-AUTH-* one-liner summaries}

- **[Access Control](docs/auth/access-control.md):** Defines RBAC patterns and permission models
- **[Session Management](docs/auth/sessions.md):** Token lifecycle and refresh strategies
- ...

### User Management (12 documents)
...

---

## Key Decisions

{Aggregated from all decision tables}

| ID | Topic | Decision | Date |
|----|-------|----------|------|
| DOC-AUTH-001/DEC-001 | Access Control | Use RBAC over ABAC | 2026-01-10 |
| ... |

---

## Open Questions

{Aggregated from all open questions}

- [ ] DOC-AUTH-003: How to handle token revocation at scale?
- [ ] DOC-UM-005: Guest user permissions model?

---

## Requirements Index

{Aggregated from all requirements sections}

See: [Requirements Index](requirements-index.md)

---

## Health Report

- **Active Documents:** 38
- **Deprecated:** 3
- **Stale (>30 days):** 1
- **Orphaned:** 0
- **Broken Links:** 0
```

### 3.3 Requirements Index (Auto-Generated)

Replaces monolithic PRD.

```markdown
# Requirements Index

**Generated:** YYYY-MM-DD
**Total Requirements:** 127

---

## By Domain

### Authentication
| Req ID | Requirement | Source | Status |
|--------|-------------|--------|--------|
| DOC-AUTH-001/REQ-001 | Users must authenticate via OAuth2 | [Access Control](link) | Active |
| DOC-AUTH-001/REQ-002 | Sessions expire after 24h inactivity | [Access Control](link) | Active |

### User Management
...

---

## By Priority

### Critical
...

### High
...
```

---

## Part 4: Session Management

### 4.1 Session Manifest

Created automatically at end of each working session.

```yaml
session:
  id: "SESSION-2026-01-12-001"
  date: "2026-01-12"
  duration: "2h 15m"

  participants:
    - role: human
      name: "{User Name}"
    - role: agent
      name: "Mary (Business Analyst)"

  beads_context:
    epic: "Ways of Development-1"
    tasks_completed:
      - "Ways of Development-2"
      - "Ways of Development-3"
    tasks_in_progress:
      - "Ways of Development-4"

  documents:
    created:
      - id: DOC-WOD-001
        title: "Phase 1 Problem Analysis"
      - id: DOC-WOD-002
        title: "Phase 2 Rapid Ideation"
    modified: []
    referenced:
      - id: DOC-UM-001
        reason: "Example of access control patterns"

  decisions_made:
    - id: DEC-SESSION-001
      topic: "Document ID format"
      decision: "Use manual DOC-{DOMAIN}-{NNN} convention"
      rationale: "Human readability over auto-generation"

  open_questions:
    - "How to handle template migrations?"
    - "Automation tooling requirements?"

  next_steps:
    - "Complete SCAMPER analysis"
    - "Synthesize into framework"

  summary: |
    Brainstorming session on improving documentation workflow.
    Identified 5 core pain points, generated 15 solution categories,
    prioritized 11 for implementation. Key innovation: modular topic
    documents with auto-generated Project Brief.
```

### 4.2 Session Continuity Protocol

When starting a new session:

1. Agent receives Project Brief (auto-generated, current)
2. Agent reads last session manifest for context
3. Agent queries registry for topic-specific docs as needed
4. Agent creates new session manifest at end

---

## Part 5: Workflow Integration

### 5.1 Beads → Document Scaffolding

When a Beads issue is created, auto-generate document stub:

```bash
bd create "Access Control Patterns" -t task
# Triggers creation of:
# - /docs/auth/access-control-patterns.md (stub)
# - /docs/auth/access-control-patterns.meta.yaml (with beads link)
```

**Stub Content:**
```markdown
# Access Control Patterns

---

## Summary

**One-liner:** {To be completed}

**Paragraph:** {To be completed}

**Full Summary:** {To be completed}

---

## Content

{To be developed}

---

## What Links Here

{Auto-generated}

---

## Change Log

| Version | Date | Author | Reason | Summary |
|---------|------|--------|--------|---------|
| 0.1 | 2026-01-12 | System | Auto-scaffolded from Beads | Stub created |
```

### 5.2 Agent Workflow by Role

#### Business Analyst
1. Receive Project Brief + registry
2. Create/update topic docs with `business-analysis` tag
3. Capture requirements in each topic doc
4. Decisions logged in decision tables
5. Session manifest generated

#### Architect
1. Receive Project Brief + registry + relevant BA docs (via links)
2. Create/update topic docs with `architecture` tag
3. Reference BA decisions, add architectural decisions
4. Update related_docs links
5. Session manifest generated

#### Project Manager
1. Receive Project Brief + Requirements Index
2. Review/refine requirements across topic docs
3. Add `requirements` tag to finalized docs
4. Requirements Index auto-regenerates
5. Session manifest generated

#### Developer
1. Receive topic-specific doc bundle (auto-assembled)
2. Create Beads from requirements
3. Reference docs during implementation
4. Flag doc updates needed via session manifest
5. Changes propagate through update protocol

### 5.3 Update Propagation Protocol

When a document changes:

1. **Agent proposes change** with impact analysis
2. **Registry queried** for "What links here"
3. **Affected docs listed** for human review
4. **Human approves** scope of updates
5. **Agent updates** all affected docs with:
   - New version number
   - Change log entry (author, date, reason, summary)
6. **Registry regenerates** automatically
7. **Project Brief regenerates** automatically

---

## Part 6: Patterns & Recovery

### 6.1 Pattern Library Structure

```
/patterns/
  ├── patterns-index.md          # Overview of all patterns
  ├── rbac-standard.md           # Pattern: Standard RBAC
  ├── rbac-standard.meta.yaml
  ├── api-pagination.md          # Pattern: API Pagination
  └── ...
```

**Pattern Document Template:**
```markdown
# Pattern: {Name}

## When to Use
{Situations where this pattern applies}

## Implementation
{How to implement}

## Examples
{Links to docs that use this pattern}

## Anti-Pattern
{What NOT to do and why}
```

### 6.2 Tombstone Protocol (Deprecation)

When a document is deprecated:

1. Status changed to `deprecated` in meta.yaml
2. Content replaced with tombstone:

```markdown
# {Original Title} [DEPRECATED]

**Status:** Deprecated as of YYYY-MM-DD
**Reason:** {Why deprecated}
**Superseded By:** [DOC-XXX-NNN: New Title](link)

---

Original content archived. This DOC-ID is permanently reserved.
```

3. Links to deprecated doc show warning in "What Links Here"
4. Registry marks as deprecated, suggests replacement

### 6.3 Merge Protocol

When documents need combining:

1. Create new document with new DOC-ID
2. Update both old docs as deprecated → point to new
3. Update all incoming links to point to new doc
4. Registry reflects merge in health report

### 6.4 Split Protocol

When a document grows too large:

1. Create new documents for split topics
2. Original becomes index pointing to children
3. Incoming links may need updating based on specificity
4. Registry reflects split in health report

---

## Part 7: Implementation Roadmap

### Phase 1: Foundation
- [ ] Define folder structure convention
- [ ] Create document template (.md)
- [ ] Create metadata template (.meta.yaml)
- [ ] Establish DOC-ID registry process
- [ ] Create initial doc-registry.yaml

### Phase 2: Tooling
- [ ] Script: Generate doc-registry.yaml from sidecar files
- [ ] Script: Validate all links resolve
- [ ] Script: Generate Project Brief from registry
- [ ] Script: Generate Requirements Index
- [ ] Script: Beads → Doc scaffold integration

### Phase 3: Migration
- [ ] Identify existing docs to migrate
- [ ] Assign DOC-IDs to existing content
- [ ] Create sidecar files for existing docs
- [ ] Populate initial registry

### Phase 4: Workflow Integration
- [ ] Update agent prompts to enforce MLDA
- [ ] Create session manifest template
- [ ] Document handoff protocols
- [ ] Train team on new workflow

### Phase 5: Optimization
- [ ] Implement "What links here" auto-generation
- [ ] Add staleness detection
- [ ] Create health dashboard
- [ ] Establish pattern library

---

## Part 8: Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Avg doc size | < 3KB | Registry token estimates |
| Orphan docs | 0 | Registry health report |
| Broken links | 0 | Link validation script |
| Session continuity | 100% | Manifest coverage |
| Repeated discussions | -80% | Self-reported |
| Context load time | < 5 docs per task | Developer feedback |

---

## Appendix: Quick Reference

### File Naming
- Lowercase, kebab-case: `access-control.md`
- No spaces, no special characters
- Descriptive but concise

### DOC-ID Domains (Initial Set)
| Code | Domain |
|------|--------|
| AUTH | Authentication |
| UM | User Management |
| ONBOARD | Onboarding |
| BILL | Billing |
| API | API Design |
| UI | User Interface |
| DATA | Data Models |
| INT | Integrations |
| SEC | Security |
| PERF | Performance |
| WOD | Ways of Development |

### Relationship Types
| Type | Meaning |
|------|---------|
| extends | Builds upon the linked doc |
| references | Mentions but doesn't depend on |
| depends-on | Requires linked doc to function |
| contradicts | Conflicts with (needs resolution) |

---

## Change Log

| Version | Date | Author | Reason | Summary |
|---------|------|--------|--------|---------|
| 1.0 | 2026-01-12 | Mary (Business Analyst) | Initial creation | Complete framework synthesis |
