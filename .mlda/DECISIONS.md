# MLDA Integration Decisions

**Date:** 2026-01-12
**Status:** Approved for validation

---

## Context

MLDA (Modular Linked Documentation Architecture) is being validated as a documentation approach before potential integration with BMAD. These decisions guide the validation phase.

---

## Decisions

### 1. Integration Strategy

**Decision:** Option C (Parallel) for validation, then Option A (Extension), then Option B (Replacement) over time.

**Rationale:** Validate MLDA in isolation before touching existing BMAD workflows. Low risk approach with clear progression path.

### 2. Beads Integration

**Decision:** Wrapper script

**Rationale:** Tests the full workflow without modifying Beads internals. Easy to discard if MLDA doesn't validate.

**Implementation:** `mlda-create` script that:
- Runs `bd create` to create the bead
- Scaffolds topic doc + metadata sidecar
- Updates registry automatically

### 3. Registry Ownership

**Decision:** Auto-generated (via wrapper and dedicated script)

**Rationale:** Keeps registry in sync with zero manual effort. Wrapper updates on create, regenerator script can rebuild from `.meta.yaml` files.

### 4. Template Format

**Decision:** Simple markdown (`.md` + `.meta.yaml`)

**Rationale:** Easier to read/edit directly. No dependency on BMAD's template system during validation. Can convert to YAML templates later if needed.

### 5. Agent Changes

**Decision:** Update all agents at once

**Rationale:** Full validation experience requires all agents to understand MLDA protocol. Partial adoption would give incomplete feedback.

### 6. Existing Documentation

**Decision:** Fresh start (no migration)

**Rationale:** No time investment in migrating existing docs. Only new topics use MLDA. Existing BMAD docs stay as-is.

### 7. Tooling Investment

**Decision:** Build full script suite

**Scripts to build:**
| Script | Purpose |
|--------|---------|
| `mlda-create` | Create doc + meta + update registry + link bead |
| `mlda-registry` | Regenerate registry from all `.meta.yaml` files |
| `mlda-validate` | Check all DOC-ID references resolve |
| `mlda-brief` | Generate project brief from topic summaries |

### 8. Success Metrics

**MLDA validation succeeds if:**
- [ ] Topic docs are easier to find/read than monoliths
- [ ] DOC-ID links actually get used in practice
- [ ] No repeated discussions across sessions
- [ ] Creating a new topic feels lighter than creating PRD sections
- [ ] Auto-generated brief is actually useful

---

## Implementation Plan

### Phase 1: Tooling
1. Build `mlda-create` wrapper script
2. Build `mlda-registry` generator script
3. Build `mlda-validate` link validator script
4. Build `mlda-brief` brief generator script

### Phase 2: Agent Updates
5. Update all BMAD agents with MLDA protocol awareness

### Phase 3: Validation
6. Create 2-3 real topic documents using the workflow
7. Evaluate against success metrics

---

## Related Documents

- [RMS-Framework.md](../RMS-Framework.md) - Rules-Modes-Skills methodology
- [MLDA-BMAD-Integration-Analysis.md](../MLDA-BMAD-Integration-Analysis.md) - Full integration analysis
- [Phase5-Framework-Synthesis.md](../Phase5-Framework-Synthesis.md) - Complete MLDA specification

---

## Change Log

| Date | Change |
|------|--------|
| 2026-01-12 | Initial decisions captured |
