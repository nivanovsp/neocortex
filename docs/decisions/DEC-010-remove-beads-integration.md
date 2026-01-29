# DEC-010: Remove Beads Integration

**Status:** Active
**Date:** 2026-01-29
**Authors:** Human + Claude collaboration
**Supersedes:** Beads-related sections in DEC-JAN-26
**Related:** DEC-JAN-26 (simplified activation protocol)

---

## Executive Summary

Beads (`bd`) issue tracking has been removed from all agent instructions. It was found to be unsuitable for large projects. All mode activation protocols, skills, and documentation have been updated to remove beads checking, beads references, and beads integration points.

---

## Decision

Remove all beads (`bd`) references from:
1. Mode activation protocols (all 5 modes)
2. Skills that referenced beads for topic identification or task selection
3. Project CLAUDE.md rules
4. Checklists with beads integration checks
5. README framework description

---

## Rationale

Beads is not suitable for large projects. Rather than maintaining optional/fallback logic for a tool that won't be used, the references were removed entirely to reduce noise in agent instructions and avoid wasted activation steps.

---

## Changes Made

### Mode Files (analyst, architect, ux-expert, dev, bmad-master)

- Removed `Check beads: bd ready --json` from `on_activation` YAML block
- Removed "Step 2: Check Beads Tasks" from activation protocol
- Removed `Tasks: {ready_count} ready` and task listing from greeting status template
- Renumbered remaining steps (Step 3 → Step 2, Step 4 → Step 3)
- Activation is now 3 steps: Load learning index → Greet → Deep context on-demand

### Project CLAUDE.md

- Removed entire "Issue Tracking with Beads" section (setup, commands, workflow)
- Removed beads from activation flow diagrams (4 steps → 3 steps)
- Removed beads from step-by-step tables
- Updated "What Changed" notes to reflect beads removal
- Removed `beads labels` from tier-2 learning trigger list

### Skills

| File | Change |
|------|--------|
| `gather-context.md` | Removed beads labels from topic identification methods; removed "With Beads" integration example |
| `manage-learning.md` | Removed beads labels from topic identification; renamed "With Beads Task Selection" to "With Task Selection"; removed "Reads task from beads" step |
| `create-doc.md` | Removed `beads` field from sidecar YAML template |

### Other Files

| File | Change |
|------|--------|
| `README.md` | Removed "Beads issue tracking" from rules list |
| `neocortex-checklist.md` | Removed "8.1 Beads Integration" checklist section; renumbered 8.2 Handoff → 8.1, 8.3 RMS → 8.2 |

---

## Migration

No migration needed. Beads was optional and modes already handled its absence silently. Removing the references simply eliminates the check entirely.

---

## Impact

- **Context savings:** Each mode activation saves ~3 lines of instruction parsing and avoids a `bd ready` command that would fail
- **Simplicity:** Activation protocol reduced from 4 steps to 3 steps
- **No functionality loss:** Beads was not actively used for task tracking in this project
