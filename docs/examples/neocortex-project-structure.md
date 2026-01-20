# Example: Neocortex Project Structure

A complete example showing Neocortex in action for an e-commerce authentication system.

---

## Project Overview

This example shows how to structure documentation for a typical feature domain using Neocortex methodology. The example covers an **authentication system** with:

- JWT token management
- OAuth integration
- Session handling
- RBAC integration

---

## Full Project Structure

```
my-ecommerce-project/
├── CLAUDE.md                          # Project rules (RMS Rules layer)
├── .claude/
│   └── commands/                      # Modes and skills (if project-specific)
├── .mlda/
│   ├── config.yaml                    # Neocortex configuration
│   ├── registry.yaml                  # Document index (auto-generated)
│   ├── docs/                          # Topic documents by domain
│   │   ├── auth/
│   │   │   ├── authentication-overview.md
│   │   │   ├── authentication-overview.meta.yaml
│   │   │   ├── token-management.md
│   │   │   ├── token-management.meta.yaml
│   │   │   ├── oauth-integration.md
│   │   │   └── oauth-integration.meta.yaml
│   │   ├── api/
│   │   │   ├── auth-endpoints.md
│   │   │   └── auth-endpoints.meta.yaml
│   │   └── sec/
│   │       ├── security-baseline.md
│   │       └── security-baseline.meta.yaml
│   ├── topics/                        # Topic-based learning
│   │   ├── authentication/
│   │   │   ├── domain.yaml
│   │   │   └── learning.yaml
│   │   └── _cross-domain/
│   │       └── patterns.yaml
│   ├── scripts/                       # MLDA tooling
│   └── templates/                     # Document templates
├── .beads/                            # Issue tracking
│   └── issues.jsonl
├── docs/
│   ├── NEOCORTEX.md                   # Methodology documentation
│   ├── handoff.md                     # Phase transition document
│   └── decisions/
│       └── DEC-001-auth-strategy.md
└── src/                               # Source code
```

---

## Sample Files

### 1. Neocortex Configuration

**File: `.mlda/config.yaml`**

```yaml
# Neocortex Configuration
# Schema: .mlda/schemas/neocortex-config.schema.yaml

version: "2.0"

# ═══════════════════════════════════════════════════════════════════════════════
# CONTEXT LIMITS
# Controls when agents should pause and consider decomposition
# ═══════════════════════════════════════════════════════════════════════════════

context_limits:
  # Default thresholds
  soft_threshold_tokens: 35000      # Trigger self-assessment
  hardstop_tokens: 50000            # Must decompose or pause
  soft_threshold_documents: 8
  hardstop_documents: 12

  # Task-specific overrides
  by_task_type:
    research:
      soft_threshold: 50000
      hardstop: 70000
    document_creation:
      soft_threshold: 30000
      hardstop: 45000
    review:
      soft_threshold: 40000
      hardstop: 55000
    architecture:
      soft_threshold: 30000
      hardstop: 45000

# ═══════════════════════════════════════════════════════════════════════════════
# LEARNING BEHAVIOR
# Controls topic-based learning persistence
# ═══════════════════════════════════════════════════════════════════════════════

learning:
  auto_save_prompt: true            # Ask to save learnings at session end
  activation_logging: true          # Track co-activation patterns
  min_sessions_for_confidence: 3    # Sessions before pattern is "medium" confidence

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFICATION
# Controls the verification stack for sub-agent summaries
# ═══════════════════════════════════════════════════════════════════════════════

verification:
  # Domains where cross-verification (Layer 5) is always used
  cross_verification_domains:
    - security
    - compliance
    - auth

  # Critical marker syntax for verbatim extraction
  critical_marker_syntax: "<!-- CRITICAL: {type} -->"

  # Marker types recognized
  critical_marker_types:
    - compliance
    - security
    - breaking
    - dependency

# ═══════════════════════════════════════════════════════════════════════════════
# MULTI-AGENT
# Controls decomposition behavior when thresholds exceeded
# ═══════════════════════════════════════════════════════════════════════════════

multi_agent:
  auto_decompose: false             # Always ask user before spawning sub-agents
  max_sub_agents: 6                 # Maximum concurrent sub-agents
  default_strategy: by_sub_domain   # by_sub_domain | by_document_count | custom
```

---

### 2. Topic Document with Sidecar v2

**File: `.mlda/docs/auth/token-management.md`**

```markdown
# Token Management

## Overview

This document covers JWT token lifecycle management for the authentication system.

## Token Types

### Access Tokens

- Format: JWT (RS256)
- Expiry: 15 minutes
- Contains: user_id, roles[], permissions[]

### Refresh Tokens

- Format: Opaque string
- Expiry: 7 days
- Storage: httpOnly cookie

## Token Lifecycle

```
1. User authenticates → Access + Refresh tokens issued
2. Access token used for API calls
3. Access token expires → Refresh endpoint called
4. Refresh token validated → New Access token issued
5. Refresh token rotated (one-time use)
```

## Security Requirements

<!-- CRITICAL: compliance -->
Access token expiry must never exceed 15 minutes per PCI-DSS requirement 8.1.8.
This is a hard regulatory requirement subject to audit.
<!-- /CRITICAL -->

<!-- CRITICAL: security -->
Refresh tokens must be rotated on each use. Reuse of a refresh token
indicates potential token theft and must invalidate all tokens for the user.
<!-- /CRITICAL -->

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/token` | POST | Issue tokens |
| `/auth/refresh` | POST | Refresh access token |
| `/auth/revoke` | POST | Revoke refresh token |

## Error Handling

| Error Code | Meaning | Action |
|------------|---------|--------|
| `TOKEN_EXPIRED` | Access token expired | Call refresh endpoint |
| `TOKEN_INVALID` | Token signature invalid | Re-authenticate |
| `REFRESH_REUSED` | Refresh token reuse detected | Force logout all sessions |

## Open Questions

- Token storage for mobile: Secure enclave vs encrypted storage?
- Multi-device session limit policy?
```

**File: `.mlda/docs/auth/token-management.meta.yaml`**

```yaml
# Sidecar v2 for Token Management
# Schema: .mlda/schemas/sidecar-v2.schema.yaml

id: DOC-AUTH-002
title: "Token Management"
status: active

created:
  date: "2026-01-15"
  by: "Architect"

updated:
  date: "2026-01-20"
  by: "Developer"

tags:
  - authentication
  - jwt
  - token-management
  - security

domain: AUTH

summary: |
  JWT token lifecycle management including access tokens, refresh tokens,
  rotation policies, and security requirements. Contains PCI-DSS compliance
  requirements for token expiry.

# ─────────────────────────────────────────────────────────────────────────────
# Relationships
# ─────────────────────────────────────────────────────────────────────────────

related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Token management implements the auth flow defined in overview"

  - id: DOC-SEC-001
    type: depends-on
    why: "Security baseline defines cryptographic requirements for tokens"

  - id: DOC-API-001
    type: extends
    why: "API endpoints document provides request/response schemas"

  - id: DOC-AUTH-003
    type: references
    why: "OAuth integration uses different token handling"

# ─────────────────────────────────────────────────────────────────────────────
# Predictions
# ─────────────────────────────────────────────────────────────────────────────

predictions:
  when_implementing:
    required:
      - DOC-AUTH-001    # Auth overview for flow context
      - DOC-SEC-001     # Security requirements
    likely:
      - DOC-API-001     # API schemas
      - DOC-DATA-001    # Token storage models

  when_debugging:
    required:
      - DOC-AUTH-001
    likely:
      - DOC-AUTH-003    # OAuth might be involved

  when_architecting:
    required:
      - DOC-SEC-001
      - DOC-AUTH-001
    likely:
      - DOC-RBAC-001    # Permission model

# ─────────────────────────────────────────────────────────────────────────────
# Reference Frames
# ─────────────────────────────────────────────────────────────────────────────

reference_frames:
  domain: authentication
  layer: design
  stability: stable
  scope: backend

# ─────────────────────────────────────────────────────────────────────────────
# Boundaries
# ─────────────────────────────────────────────────────────────────────────────

boundaries:
  related_domains:
    - security
    - rbac
    - session-management
  isolated_from:
    - invoicing
    - reporting
    - analytics

# ─────────────────────────────────────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────────────────────────────────────

has_critical_markers: true

beads: "ECOM-AUTH-003"
```

---

### 3. Topic Domain Configuration

**File: `.mlda/topics/authentication/domain.yaml`**

```yaml
# Topic Domain Configuration: Authentication
# Schema: .mlda/schemas/topic-domain.schema.yaml

domain: authentication
version: 2
last_updated: "2026-01-20"
source: human

# ═══════════════════════════════════════════════════════════════════════════════
# SUB-DOMAIN DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════════

sub_domains:
  - name: token-management
    docs:
      - DOC-AUTH-002
      - DOC-AUTH-005
    origin: human
    description: "JWT token lifecycle, refresh, and rotation"
    entry_point: DOC-AUTH-002

  - name: oauth-integration
    docs:
      - DOC-AUTH-003
      - DOC-AUTH-006
      - DOC-AUTH-007
    origin: human
    description: "OAuth 2.0 provider integrations (Google, GitHub, etc.)"
    entry_point: DOC-AUTH-003

  - name: session-handling
    docs:
      - DOC-AUTH-004
      - DOC-AUTH-008
    origin: human
    description: "User session management and invalidation"
    entry_point: DOC-AUTH-004

# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY POINTS BY TASK
# ═══════════════════════════════════════════════════════════════════════════════

entry_points:
  default: DOC-AUTH-001  # Authentication overview

  by_task:
    implementing: DOC-AUTH-002     # Start with token management for impl
    debugging: DOC-AUTH-001        # Start with overview for debug context
    architecting: DOC-AUTH-001     # Start with overview for design
    testing: DOC-AUTH-002          # Start with token management for test cases
    reviewing: DOC-AUTH-001        # Start with overview for reviews

# ═══════════════════════════════════════════════════════════════════════════════
# DECOMPOSITION STRATEGY
# ═══════════════════════════════════════════════════════════════════════════════

decomposition:
  strategy: by_sub_domain
  max_docs_per_agent: 4
  parallel_allowed: true

# ═══════════════════════════════════════════════════════════════════════════════
# CROSS-DOMAIN RELATIONSHIPS
# ═══════════════════════════════════════════════════════════════════════════════

related_domains:
  - domain: rbac
    relationship: "Authentication provides identity for RBAC authorization"
    boundary_docs:
      - DOC-AUTH-002    # Token claims contain roles
      - DOC-RBAC-001    # Role definitions
    traversal_allowed: true

  - domain: security
    relationship: "Security baseline governs auth implementation"
    boundary_docs:
      - DOC-AUTH-002
      - DOC-SEC-001
    traversal_allowed: true

isolated_from:
  - invoicing
  - inventory
  - reporting
```

---

### 4. Topic Learning File

**File: `.mlda/topics/authentication/learning.yaml`**

```yaml
# Topic Learning: Authentication
# Schema: .mlda/schemas/topic-learning.schema.yaml
#
# This file accumulates learnings over sessions.
# Agents propose updates; you approve them.

topic: authentication
version: 4
last_updated: "2026-01-20"
sessions_contributed: 12

# ═══════════════════════════════════════════════════════════════════════════════
# LEARNED GROUPINGS
# ═══════════════════════════════════════════════════════════════════════════════

groupings:
  - name: token-management
    docs:
      - DOC-AUTH-002
      - DOC-AUTH-005
      - DOC-SEC-001
    origin: human
    confidence: high
    notes: "Core token docs + security baseline always needed together"

  - name: oauth-providers
    docs:
      - DOC-AUTH-003
      - DOC-AUTH-006
      - DOC-AUTH-007
    origin: agent
    confidence: medium
    notes: "OAuth docs cluster - discovered via co-activation patterns"

  - name: session-security
    docs:
      - DOC-AUTH-004
      - DOC-AUTH-008
      - DOC-SEC-002
    origin: hybrid
    confidence: medium
    notes: "Session handling with security considerations"

# ═══════════════════════════════════════════════════════════════════════════════
# CO-ACTIVATION PATTERNS
# ═══════════════════════════════════════════════════════════════════════════════

activations:
  - docs:
      - DOC-AUTH-001
      - DOC-AUTH-002
      - DOC-SEC-001
    frequency: 8
    typical_tasks:
      - implementing
      - architecting
    last_session: "2026-01-20"

  - docs:
      - DOC-AUTH-002
      - DOC-API-001
      - DOC-DATA-001
    frequency: 5
    typical_tasks:
      - implementing
      - debugging
    last_session: "2026-01-19"

  - docs:
      - DOC-AUTH-003
      - DOC-AUTH-006
    frequency: 4
    typical_tasks:
      - implementing
    last_session: "2026-01-18"

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFICATION NOTES
# ═══════════════════════════════════════════════════════════════════════════════

verification_notes:
  - session: "2026-01-15"
    caught: "PCI-DSS 15-minute token expiry requirement"
    doc: DOC-AUTH-002
    section: "Security Requirements"
    lesson: "Always check CRITICAL compliance markers in token docs"

  - session: "2026-01-18"
    caught: "Missing GDPR consent check in OAuth flow"
    doc: DOC-AUTH-003
    section: "User Data Handling"
    lesson: "Check GDPR markers when implementing OAuth user data access"

  - session: "2026-01-19"
    caught: "Refresh token rotation not implemented"
    doc: DOC-AUTH-002
    section: "Token Lifecycle"
    lesson: "Verify refresh token security requirements are implemented"

# ═══════════════════════════════════════════════════════════════════════════════
# CROSS-DOMAIN TOUCHPOINTS
# ═══════════════════════════════════════════════════════════════════════════════

related_domains:
  - domain: rbac
    relationship: "Token claims contain role information for authorization"
    typical_overlap:
      - DOC-AUTH-002
      - DOC-RBAC-001

  - domain: api
    relationship: "Auth endpoints documented in API specs"
    typical_overlap:
      - DOC-AUTH-002
      - DOC-API-001

# ═══════════════════════════════════════════════════════════════════════════════
# ANTI-PATTERNS
# ═══════════════════════════════════════════════════════════════════════════════

anti_patterns:
  - pattern: "Loading all AUTH docs for simple token validation"
    reason: "Context overflow - only DOC-AUTH-002 and DOC-SEC-001 needed"
    session: "2026-01-10"

  - pattern: "Skipping security baseline when debugging auth issues"
    reason: "Missed cryptographic requirements causing hard-to-find bugs"
    session: "2026-01-12"
```

---

### 5. Cross-Domain Patterns

**File: `.mlda/topics/_cross-domain/patterns.yaml`**

```yaml
# Cross-Domain Patterns
# Patterns that span multiple topic domains

version: 2
last_updated: "2026-01-20"

# Patterns discovered across domain boundaries
patterns:
  - name: auth-to-rbac-flow
    domains:
      - authentication
      - rbac
    docs:
      - DOC-AUTH-002
      - DOC-RBAC-001
      - DOC-RBAC-002
    frequency: 6
    description: "Auth tokens contain roles that RBAC validates"
    typical_tasks:
      - implementing
      - debugging

  - name: security-compliance-check
    domains:
      - authentication
      - security
    docs:
      - DOC-AUTH-002
      - DOC-SEC-001
      - DOC-SEC-003
    frequency: 4
    description: "Security baseline + compliance requirements for auth"
    typical_tasks:
      - architecting
      - reviewing
```

---

### 6. Document Registry

**File: `.mlda/registry.yaml`** (auto-generated by `mlda-registry.ps1`)

```yaml
# MLDA Document Registry
# Auto-generated by mlda-registry.ps1
# Last updated: 2026-01-20T14:30:00Z

version: 2
document_count: 12

domains:
  AUTH:
    count: 8
    documents:
      - id: DOC-AUTH-001
        title: "Authentication Overview"
        path: ".mlda/docs/auth/authentication-overview.md"
        status: active
      - id: DOC-AUTH-002
        title: "Token Management"
        path: ".mlda/docs/auth/token-management.md"
        status: active
      - id: DOC-AUTH-003
        title: "OAuth Integration"
        path: ".mlda/docs/auth/oauth-integration.md"
        status: active
      # ... more docs

  API:
    count: 2
    documents:
      - id: DOC-API-001
        title: "Auth Endpoints"
        path: ".mlda/docs/api/auth-endpoints.md"
        status: active

  SEC:
    count: 2
    documents:
      - id: DOC-SEC-001
        title: "Security Baseline"
        path: ".mlda/docs/sec/security-baseline.md"
        status: active

# Connectivity analysis
connectivity:
  total_relationships: 24
  orphan_documents: 0          # Documents with no relationships
  most_connected: DOC-AUTH-002  # 6 relationships
  isolated_domains: []         # Domains with no cross-domain links
```

---

## Relationship Visualization

```
                    ┌─────────────────┐
                    │  DOC-AUTH-001   │
                    │    Overview     │
                    └────────┬────────┘
                             │ depends-on
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
       ┌────────────┐ ┌────────────┐ ┌────────────┐
       │DOC-AUTH-002│ │DOC-AUTH-003│ │DOC-AUTH-004│
       │   Tokens   │ │   OAuth    │ │  Sessions  │
       └─────┬──────┘ └─────┬──────┘ └─────┬──────┘
             │              │              │
    ┌────────┴────────┐     │              │
    ▼                 ▼     ▼              ▼
┌────────┐      ┌────────┐ ┌────────┐ ┌────────┐
│SEC-001 │      │API-001 │ │AUTH-006│ │AUTH-008│
│Security│      │  API   │ │ OAuth  │ │Sessions│
└────────┘      └────────┘ └────────┘ └────────┘
    │
    ▼
┌────────┐
│RBAC-001│  (cross-domain)
│ Roles  │
└────────┘
```

---

## How Context Gathering Works

When an agent starts work on a task referencing `DOC-AUTH-002`:

```
1. TOPIC IDENTIFICATION
   DOC-AUTH-002 → domain: AUTH → topic: authentication
   Load: .mlda/topics/authentication/learning.yaml

2. APPLY LEARNINGS
   - High-frequency activation: [DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001]
   - Verification note: "Check CRITICAL compliance markers"
   - Grouping: token-management includes DOC-AUTH-005

3. ENTRY POINT EXPANSION
   Task: implementing
   Entry: DOC-AUTH-002
   Predictions: required=[DOC-AUTH-001, DOC-SEC-001], likely=[DOC-API-001]

4. TWO-PHASE LOADING
   Phase A: Load 6 sidecars (metadata only)
   Phase B: Full load for DOC-AUTH-001, DOC-AUTH-002, DOC-SEC-001

5. TRAVERSAL
   DOC-AUTH-002 → depends-on → DOC-AUTH-001 ✓
   DOC-AUTH-002 → depends-on → DOC-SEC-001 ✓
   DOC-AUTH-002 → extends → DOC-API-001 ✓ (depth=2)
   DOC-AUTH-002 → references → DOC-AUTH-003 (skip, not relevant)

6. BOUNDARY CHECK
   DOC-AUTH-002.boundaries.related_domains includes "rbac"
   → DOC-RBAC-001 noted as dependency but not fully loaded

7. CONTEXT SYNTHESIS
   Tokens: ~25,000 (within soft threshold)
   Documents: 5
   Critical markers: 2 extracted verbatim
```

---

## Quick Setup Commands

```powershell
# Initialize a new project with authentication domain
.\.mlda\scripts\mlda-init-project.ps1 -Domains AUTH,API,SEC

# Create a new topic document
.\.mlda\scripts\mlda-create.ps1 -Domain AUTH -Title "Token Management"

# Initialize topic learning
.\.mlda\scripts\mlda-learning.ps1 -Topic authentication -Init

# Rebuild registry after changes
.\.mlda\scripts\mlda-registry.ps1

# Validate all relationships
.\.mlda\scripts\mlda-validate.ps1

# View connectivity graph
.\.mlda\scripts\mlda-registry.ps1 -Graph
```

---

## References

| Resource | Purpose |
|----------|---------|
| [.mlda/schemas/](../../.mlda/schemas/) | YAML schemas for validation |
| [.mlda/templates/](../../.mlda/templates/) | Document and config templates |
| [Neocortex User Guide](../guides/neocortex-user-guide.md) | Feature usage guide |
| [NEOCORTEX.md](../NEOCORTEX.md) | Full methodology specification |

---

*Example Project Structure v2.0 | Neocortex Methodology*
