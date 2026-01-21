---
description: 'Generate detailed wireframe descriptions with Neocortex context'
---
# Create Wireframe Skill

**RMS Skill v2.0** | Generate detailed wireframe descriptions using design system context, requirements, and user flows from the MLDA knowledge graph

## When to Use

- Creating wireframe descriptions for new screens or components
- Documenting UI layouts before visual design
- Communicating structure to developers or stakeholders
- Iterating on layout alternatives

## Prerequisites

- Design system documentation available (recommended)
- Requirements or user stories with DOC-ID references
- MLDA initialized if using Neocortex integration

---

## Workflow Overview

```
+-----------------------------------------------------------------------+
|                    CREATE WIREFRAME WORKFLOW                           |
+-----------------------------------------------------------------------+
|                                                                        |
|  Phase 1: Context Gathering (Neocortex)                               |
|    +-- Load design system docs (DOC-UI-xxx, DOC-DS-xxx)               |
|    +-- Load relevant requirements (DOC-REQ-xxx)                        |
|    +-- Load user flow context if available                            |
|    +-- Extract component patterns and constraints                      |
|                                                                        |
|  Phase 2: Screen/Component Identification                              |
|    +-- Clarify scope (screen, component, or flow)                     |
|    +-- Identify purpose and user goals                                |
|    +-- Define viewport targets (mobile, tablet, desktop)              |
|                                                                        |
|  Phase 3: Layout Structure Definition                                  |
|    +-- Define grid system (from design system or specify)             |
|    +-- Establish visual hierarchy zones                               |
|    +-- Map information architecture to layout                         |
|                                                                        |
|  Phase 4: Component Specification                                      |
|    +-- List all UI components needed                                  |
|    +-- Reference design system components where available             |
|    +-- Specify placement, sizing, and spacing                         |
|    +-- Document component states (default, hover, active, disabled)   |
|                                                                        |
|  Phase 5: Interaction Documentation                                    |
|    +-- Define interactive elements and behaviors                      |
|    +-- Document navigation and transitions                            |
|    +-- Specify feedback mechanisms                                    |
|                                                                        |
|  Phase 6: Responsive Breakpoints                                       |
|    +-- Define layout changes per breakpoint                           |
|    +-- Document component adaptations                                 |
|    +-- Note mobile-specific interactions                              |
|                                                                        |
|  Phase 7: Output Generation                                            |
|    +-- Generate structured wireframe description                      |
|    +-- Include design system references                               |
|    +-- Add implementation notes for developers                        |
|                                                                        |
+-----------------------------------------------------------------------+
```

---

## Phase 1: Context Gathering

**Goal:** Load relevant design context before creating wireframe.

### Neocortex Integration

If MLDA is available, gather context from:

| Domain | DOC-ID Prefix | What to Extract |
|--------|---------------|-----------------|
| Design System | DOC-DS-xxx | Colors, typography, spacing, components |
| UI Patterns | DOC-UI-xxx | Existing patterns, layouts, conventions |
| Requirements | DOC-REQ-xxx | Functional requirements, constraints |
| User Flows | DOC-UF-xxx | User journey context, entry/exit points |

### Context Gathering Command

```
*gather-context --domains UI,DS,REQ --task-type wireframing
```

### Without MLDA

If no MLDA context available, elicit:
1. What design system or style guide exists?
2. What are the key requirements for this screen?
3. What user flow does this screen belong to?
4. Are there existing similar screens to reference?

---

## Phase 2: Screen/Component Identification

### Questions to Clarify

| Question | Purpose |
|----------|---------|
| What is being wireframed? | Screen, component, or multi-step flow |
| What is the primary user goal? | Focus the hierarchy |
| What is the entry point? | How users arrive here |
| What are the exit points? | Where users go next |
| What viewport(s) to target? | Mobile-first, desktop, or both |

### Scope Classification

| Type | Description | Output Format |
|------|-------------|---------------|
| **Screen** | Full page layout | Complete wireframe description |
| **Component** | Reusable UI element | Component specification |
| **Flow** | Multi-screen sequence | Wireframe set with transitions |

---

## Phase 3: Layout Structure Definition

### Grid System

Reference design system grid or define:

```yaml
grid:
  type: 12-column  # or 6-column, flexible
  gutter: 16px     # or design system token
  margins:
    mobile: 16px
    tablet: 24px
    desktop: 32px
  max_width: 1200px
```

### Visual Hierarchy Zones

Define the major layout zones:

```
+--------------------------------------------------+
|  HEADER (navigation, branding)                    |
+--------------------------------------------------+
|                                                   |
|  HERO / PRIMARY CONTENT ZONE                      |
|  (Main user task or information)                  |
|                                                   |
+--------------------------------------------------+
|  SECONDARY CONTENT                                |
|  (Supporting information, related actions)        |
+--------------------------------------------------+
|  FOOTER (links, legal, secondary nav)             |
+--------------------------------------------------+
```

---

## Phase 4: Component Specification

### Component Documentation Format

For each component in the wireframe:

```yaml
component:
  name: "Primary Action Button"
  design_system_ref: "DS-BTN-001"  # If exists

  placement:
    zone: "Hero"
    position: "Bottom right of form"
    grid_columns: "span 4 (desktop), full-width (mobile)"

  sizing:
    width: "auto / min 120px"
    height: "48px (touch target)"
    padding: "12px 24px"

  states:
    - default: "Blue background, white text"
    - hover: "Darker blue, slight elevation"
    - active: "Darkest blue, pressed effect"
    - disabled: "Gray background, reduced opacity"
    - loading: "Spinner replaces text"

  content:
    label: "Submit Application"
    icon: "none / optional arrow-right"

  accessibility:
    role: "button"
    aria_label: "Submit your application form"
    keyboard: "Enter/Space to activate"
```

### Component Checklist

For each component, document:
- [ ] Name and design system reference (if exists)
- [ ] Placement (zone, position, grid alignment)
- [ ] Sizing (width, height, padding, margins)
- [ ] States (default, hover, active, disabled, loading, error)
- [ ] Content (text, icons, images)
- [ ] Accessibility considerations

---

## Phase 5: Interaction Documentation

### Interaction Types

| Type | Document |
|------|----------|
| **Click/Tap** | Target element, resulting action, feedback |
| **Hover** | Visual change, tooltip content |
| **Focus** | Focus indicator, keyboard navigation order |
| **Scroll** | Infinite scroll, lazy loading, sticky elements |
| **Swipe** | Mobile gestures, carousel behavior |
| **Drag** | Drag handles, drop zones, reordering |

### Interaction Documentation Format

```yaml
interaction:
  trigger: "Click 'Submit' button"
  preconditions:
    - "Form validation passes"
    - "User is authenticated"
  action: "Submit form data to API"
  feedback:
    immediate: "Button shows loading spinner"
    success: "Navigate to confirmation screen"
    error: "Display error toast, highlight invalid fields"
  accessibility:
    announcement: "Form submitted successfully" # Screen reader
```

---

## Phase 6: Responsive Breakpoints

### Standard Breakpoints

```yaml
breakpoints:
  mobile:
    range: "0 - 767px"
    columns: 4
    layout_changes: []

  tablet:
    range: "768px - 1023px"
    columns: 8
    layout_changes: []

  desktop:
    range: "1024px+"
    columns: 12
    layout_changes: []
```

### Documenting Responsive Changes

For each breakpoint, note:
- Layout restructuring (stack vs. side-by-side)
- Component visibility changes (show/hide)
- Navigation changes (hamburger menu vs. full nav)
- Typography scaling
- Touch target adjustments

---

## Phase 7: Output Generation

### Wireframe Description Template

```markdown
# Wireframe: [Screen/Component Name]

**DOC-ID:** DOC-WF-XXX (if registered)
**Related:** [DOC-REQ-xxx, DOC-UF-xxx, DOC-DS-xxx]
**Version:** 1.0
**Last Updated:** [Date]

## Overview

**Purpose:** [What this screen/component achieves]
**User Goal:** [Primary user objective]
**Entry Points:** [How users arrive here]
**Exit Points:** [Where users go next]

## Layout Structure

### Grid
- Type: [12-column / 6-column / flexible]
- Max Width: [1200px]
- Margins: [16px mobile, 24px tablet, 32px desktop]

### Zones
[ASCII or description of major layout zones]

## Components

### [Component 1 Name]
- **Design System Ref:** [DS-XXX-NNN or "Custom"]
- **Placement:** [Zone, position, grid columns]
- **States:** [List key states]
- **Content:** [Text, icons, media]

### [Component 2 Name]
...

## Interactions

### [Interaction 1]
- **Trigger:** [User action]
- **Result:** [System response]
- **Feedback:** [Visual/audio feedback]

## Responsive Behavior

### Mobile (< 768px)
- [Layout changes]
- [Component adaptations]

### Tablet (768px - 1023px)
- [Layout changes]

### Desktop (1024px+)
- [Layout changes]

## Accessibility Notes

- [Keyboard navigation order]
- [Screen reader considerations]
- [Focus management]

## Implementation Notes

- [Technical considerations for developers]
- [Component library references]
- [API dependencies]

## Open Questions

- [Unresolved design decisions]
```

---

## Integration with Design System

When design system docs are available:

### Reference Format

```yaml
# In wireframe component specification
button:
  ref: "DOC-DS-001#buttons-primary"
  variant: "primary"
  size: "large"
  # Only document deviations from standard
  customizations:
    - "Icon added to right side"
```

### Design System Domains

| Domain Code | Content Type |
|-------------|--------------|
| DS | Design system (tokens, principles) |
| UI | UI patterns and components |
| WF | Wireframes |
| UF | User flows |

---

## Commands

Invoke this skill via:
- `/skills:create-wireframe`
- `*create-wireframe` (when in UX mode)

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--scope` | screen, component, or flow | screen |
| `--viewport` | mobile, tablet, desktop, all | all |
| `--context` | DOC-IDs for context | auto-detect |

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No design system docs | Elicit design preferences, proceed with inline specs |
| No requirements context | Ask for user goals and constraints |
| Scope unclear | Present options, ask user to clarify |
| Complex multi-screen flow | Suggest breaking into individual wireframes |

---

## Learning Integration

At session end, if new patterns discovered:

```
New learnings identified:
- Component pattern: "Card with action footer" used for [context]
- Layout pattern: "Two-column with sticky sidebar" for [context]

Save to .mlda/topics/ui-design/learning.yaml? [y/n]
```

---

## MLDA Finalization (Automatic)

When wireframe output is generated, automatically perform these steps:

### 1. DOC-ID Assignment

- Read `.mlda/registry.yaml` for next available ID in UI domain
- Assign: `DOC-UI-{NNN}` (e.g., DOC-UI-001, DOC-UI-002)
- UI domain covers: wireframes, component specs, layouts

### 2. Sidecar Creation

Create `{filename}.meta.yaml` alongside the wireframe document:

```yaml
id: DOC-UI-{NNN}
title: "{Wireframe title}"
status: draft
domain: UI
type: wireframe
created: "{date}"
summary: "{One-line description of what this wireframe covers}"

related:
  - id: DOC-DS-xxx
    type: depends-on  # Strong signal - design system required
    why: "Uses design system components and tokens"
  - id: DOC-REQ-xxx
    type: depends-on  # Strong signal - requirements drive design
    why: "Implements requirements from this document"
  - id: DOC-UX-xxx
    type: references  # Weak signal - related user flow
    why: "Part of user flow documented here"

reference_frames:
  layer: design
  phase: ux-design

predictions:
  when_implementing:
    - DOC-DS-xxx  # Developer needs design system
    - DOC-UI-xxx  # Related wireframes
    - DOC-A11Y-xxx  # Accessibility requirements
```

### 3. Registry Update

After creating document and sidecar:
- Run: `.mlda/scripts/mlda-registry.ps1`
- Confirm: "Document registered as DOC-UI-{NNN} in MLDA"

### 4. Report Entry Points

List DOC-IDs that stories/developers should reference:

```
Entry Points for Stories:
- DOC-UI-{NNN}: {Title} (wireframe)
- Related: DOC-DS-xxx (design system), DOC-A11Y-xxx (accessibility)

Developers should run: *gather-context DOC-UI-{NNN}
```

### Relationship Type Standards

| Old Type | Standard Type | Signal Strength |
|----------|---------------|-----------------|
| `uses` | `depends-on` | Strong - always follow |
| `leads_to` | `extends` | Medium - follow if depth allows |
| `alternative` | `references` | Weak - follow if relevant |

---

*create-wireframe v2.0 | Neocortex Methodology | UX Skill*
