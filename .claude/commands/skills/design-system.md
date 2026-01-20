---
description: 'Define and document design system components with Neocortex integration'
---
# Design System Skill

**RMS Skill v2.0** | Define, document, and evolve design system foundations using requirements context and existing UI patterns from the MLDA knowledge graph

## When to Use

- Establishing a new design system for a project
- Documenting existing design patterns into a formal system
- Extending a design system with new components
- Auditing design system consistency

## Prerequisites

- Brand guidelines or visual identity (recommended)
- Requirements or user stories for context
- Existing UI implementations to reference (recommended)
- MLDA initialized if using Neocortex integration

---

## Workflow Overview

```
+-----------------------------------------------------------------------+
|                    DESIGN SYSTEM WORKFLOW                              |
+-----------------------------------------------------------------------+
|                                                                        |
|  Phase 1: Context Gathering (Neocortex)                               |
|    +-- Load brand guidelines (DOC-BRAND-xxx)                          |
|    +-- Load existing UI patterns (DOC-UI-xxx)                         |
|    +-- Load requirements for context (DOC-REQ-xxx)                    |
|    +-- Load accessibility requirements (DOC-A11Y-xxx)                 |
|                                                                        |
|  Phase 2: Foundation Definition                                        |
|    +-- Design Tokens (colors, typography, spacing, shadows)           |
|    +-- Grid System                                                     |
|    +-- Breakpoints                                                     |
|    +-- Animation/Motion principles                                     |
|                                                                        |
|  Phase 3: Component Library                                            |
|    +-- Primitive components (buttons, inputs, icons)                  |
|    +-- Composite components (cards, forms, navigation)                |
|    +-- Pattern components (page layouts, templates)                   |
|                                                                        |
|  Phase 4: Documentation Standards                                      |
|    +-- Component specification format                                  |
|    +-- Usage guidelines                                                |
|    +-- Do's and Don'ts                                                 |
|    +-- Code examples                                                   |
|                                                                        |
|  Phase 5: Governance                                                   |
|    +-- Contribution process                                            |
|    +-- Version management                                              |
|    +-- Deprecation policy                                              |
|                                                                        |
+-----------------------------------------------------------------------+
```

---

## Phase 1: Context Gathering

**Goal:** Load relevant brand and UI context before defining design system.

### Neocortex Integration

If MLDA is available, gather context from:

| Domain | DOC-ID Prefix | What to Extract |
|--------|---------------|-----------------|
| Brand | DOC-BRAND-xxx | Logo, colors, typography, voice |
| UI Patterns | DOC-UI-xxx | Existing components, layouts |
| Accessibility | DOC-A11Y-xxx | Accessibility requirements |
| Requirements | DOC-REQ-xxx | Product requirements, constraints |

### Context Gathering Command

```
*gather-context --domains BRAND,UI,A11Y,REQ --task-type design_system
```

### Key Questions to Answer

1. Is there existing brand identity to align with?
2. What platforms/devices must be supported?
3. What accessibility level is required?
4. Are there existing components to incorporate?
5. What are the performance constraints?

---

## Phase 2: Foundation Definition

### Design Tokens

Design tokens are the atomic values that define the visual language.

#### Color Tokens

```yaml
colors:
  # Brand colors
  primary:
    50: "#E3F2FD"   # Lightest
    100: "#BBDEFB"
    200: "#90CAF9"
    300: "#64B5F6"
    400: "#42A5F5"
    500: "#2196F3"  # Base
    600: "#1E88E5"
    700: "#1976D2"
    800: "#1565C0"
    900: "#0D47A1"  # Darkest

  secondary:
    # ... similar scale

  # Semantic colors
  semantic:
    success: "#4CAF50"
    warning: "#FF9800"
    error: "#F44336"
    info: "#2196F3"

  # Neutral colors
  neutral:
    white: "#FFFFFF"
    gray-50: "#FAFAFA"
    gray-100: "#F5F5F5"
    # ... full gray scale
    gray-900: "#212121"
    black: "#000000"

  # Surface colors
  surface:
    background: "{neutral.white}"
    card: "{neutral.white}"
    elevated: "{neutral.white}"
    overlay: "rgba(0, 0, 0, 0.5)"

  # Text colors
  text:
    primary: "{neutral.gray-900}"
    secondary: "{neutral.gray-600}"
    disabled: "{neutral.gray-400}"
    inverse: "{neutral.white}"
    link: "{primary.600}"
```

#### Typography Tokens

```yaml
typography:
  font_families:
    heading: "'Inter', -apple-system, sans-serif"
    body: "'Inter', -apple-system, sans-serif"
    mono: "'Fira Code', 'Consolas', monospace"

  font_weights:
    regular: 400
    medium: 500
    semibold: 600
    bold: 700

  font_sizes:
    xs: "0.75rem"    # 12px
    sm: "0.875rem"   # 14px
    base: "1rem"     # 16px
    lg: "1.125rem"   # 18px
    xl: "1.25rem"    # 20px
    2xl: "1.5rem"    # 24px
    3xl: "1.875rem"  # 30px
    4xl: "2.25rem"   # 36px
    5xl: "3rem"      # 48px

  line_heights:
    tight: 1.25
    normal: 1.5
    relaxed: 1.75

  # Composite text styles
  styles:
    h1:
      family: "{font_families.heading}"
      size: "{font_sizes.4xl}"
      weight: "{font_weights.bold}"
      line_height: "{line_heights.tight}"

    h2:
      family: "{font_families.heading}"
      size: "{font_sizes.3xl}"
      weight: "{font_weights.semibold}"
      line_height: "{line_heights.tight}"

    body:
      family: "{font_families.body}"
      size: "{font_sizes.base}"
      weight: "{font_weights.regular}"
      line_height: "{line_heights.normal}"

    caption:
      family: "{font_families.body}"
      size: "{font_sizes.sm}"
      weight: "{font_weights.regular}"
      line_height: "{line_heights.normal}"
```

#### Spacing Tokens

```yaml
spacing:
  # Base unit: 4px
  0: "0"
  1: "0.25rem"   # 4px
  2: "0.5rem"    # 8px
  3: "0.75rem"   # 12px
  4: "1rem"      # 16px
  5: "1.25rem"   # 20px
  6: "1.5rem"    # 24px
  8: "2rem"      # 32px
  10: "2.5rem"   # 40px
  12: "3rem"     # 48px
  16: "4rem"     # 64px
  20: "5rem"     # 80px
  24: "6rem"     # 96px

  # Semantic spacing
  component:
    padding-sm: "{spacing.2}"
    padding-md: "{spacing.4}"
    padding-lg: "{spacing.6}"

  layout:
    section-gap: "{spacing.16}"
    container-padding: "{spacing.4}"
```

#### Shadow Tokens

```yaml
shadows:
  none: "none"
  sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)"
  base: "0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)"
  md: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)"
  lg: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)"
  xl: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)"
  inner: "inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)"

  # Semantic shadows
  card: "{shadows.base}"
  dropdown: "{shadows.lg}"
  modal: "{shadows.xl}"
```

#### Border Tokens

```yaml
borders:
  radius:
    none: "0"
    sm: "0.125rem"   # 2px
    base: "0.25rem"  # 4px
    md: "0.375rem"   # 6px
    lg: "0.5rem"     # 8px
    xl: "0.75rem"    # 12px
    2xl: "1rem"      # 16px
    full: "9999px"

  width:
    none: "0"
    thin: "1px"
    base: "2px"
    thick: "4px"

  # Semantic borders
  input: "{borders.width.thin} solid {colors.neutral.gray-300}"
  input-focus: "{borders.width.base} solid {colors.primary.500}"
  divider: "{borders.width.thin} solid {colors.neutral.gray-200}"
```

### Grid System

```yaml
grid:
  columns: 12
  gutter: "{spacing.4}"  # 16px

  container:
    max_width: "1200px"
    padding:
      mobile: "{spacing.4}"
      tablet: "{spacing.6}"
      desktop: "{spacing.8}"
```

### Breakpoints

```yaml
breakpoints:
  sm: "640px"    # Mobile landscape
  md: "768px"    # Tablet
  lg: "1024px"   # Desktop
  xl: "1280px"   # Large desktop
  2xl: "1536px"  # Extra large
```

### Motion/Animation

```yaml
motion:
  duration:
    instant: "0ms"
    fast: "150ms"
    normal: "300ms"
    slow: "500ms"

  easing:
    default: "cubic-bezier(0.4, 0, 0.2, 1)"
    in: "cubic-bezier(0.4, 0, 1, 1)"
    out: "cubic-bezier(0, 0, 0.2, 1)"
    in-out: "cubic-bezier(0.4, 0, 0.2, 1)"

  # Reduced motion support
  reduced_motion:
    duration: "0ms"
    transitions: false
```

---

## Phase 3: Component Library

### Component Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **Primitives** | Basic building blocks | Button, Input, Icon, Badge |
| **Composites** | Combined primitives | Card, Form Field, Alert |
| **Patterns** | Complex UI patterns | Navigation, Modal, Data Table |
| **Layouts** | Page structures | Page Shell, Grid Layout |

### Component Specification Format

```yaml
component:
  name: "Button"
  doc_id: "DOC-DS-BTN-001"
  category: primitive
  status: stable  # draft, stable, deprecated

  description: |
    Buttons trigger actions or navigate users. Use primary buttons
    for main actions, secondary for alternatives, and tertiary for
    low-emphasis actions.

  variants:
    - name: primary
      description: "Main call-to-action"
      use_when: "Primary action on a page or in a form"

    - name: secondary
      description: "Alternative action"
      use_when: "Secondary actions alongside primary"

    - name: tertiary
      description: "Low-emphasis action"
      use_when: "Tertiary actions, inline actions"

    - name: destructive
      description: "Dangerous/irreversible action"
      use_when: "Delete, remove, or destructive actions"

  sizes:
    - name: sm
      height: "32px"
      padding: "{spacing.2} {spacing.3}"
      font_size: "{typography.font_sizes.sm}"

    - name: md
      height: "40px"
      padding: "{spacing.2} {spacing.4}"
      font_size: "{typography.font_sizes.base}"

    - name: lg
      height: "48px"
      padding: "{spacing.3} {spacing.6}"
      font_size: "{typography.font_sizes.lg}"

  states:
    - name: default
      description: "Normal resting state"

    - name: hover
      description: "Mouse over"
      changes: "Darker background, cursor pointer"

    - name: active
      description: "Being clicked"
      changes: "Darkest background, slight scale"

    - name: focus
      description: "Keyboard focus"
      changes: "Focus ring visible"

    - name: disabled
      description: "Not interactive"
      changes: "Reduced opacity, cursor not-allowed"

    - name: loading
      description: "Action in progress"
      changes: "Spinner replaces content"

  anatomy:
    - element: "Container"
      description: "Button wrapper with background and border"

    - element: "Label"
      description: "Text content"

    - element: "Icon (optional)"
      description: "Leading or trailing icon"

    - element: "Spinner (loading state)"
      description: "Loading indicator"

  accessibility:
    role: "button"
    keyboard:
      - key: "Enter"
        action: "Activate button"
      - key: "Space"
        action: "Activate button"
    aria:
      - "aria-disabled when disabled"
      - "aria-busy when loading"
      - "aria-label if icon-only"
    focus_indicator: "2px offset ring, primary color"

  dos:
    - "Use clear, action-oriented labels"
    - "Provide visual feedback for all states"
    - "Maintain minimum touch target (44x44px)"
    - "Use icons to reinforce meaning, not replace text"

  donts:
    - "Don't use more than one primary button per section"
    - "Don't disable buttons without explanation"
    - "Don't use vague labels like 'Click here'"
    - "Don't rely on color alone to convey state"

  related:
    - doc_id: "DOC-DS-ICON-001"
      relationship: "uses"
    - doc_id: "DOC-DS-SPINNER-001"
      relationship: "uses"

  examples:
    - name: "Primary button"
      code: |
        <Button variant="primary">Submit</Button>

    - name: "With icon"
      code: |
        <Button variant="primary" icon="arrow-right" iconPosition="end">
          Continue
        </Button>

    - name: "Loading state"
      code: |
        <Button variant="primary" loading>
          Submitting...
        </Button>
```

---

## Phase 4: Documentation Standards

### Component Documentation Checklist

For each component, document:

- [ ] **Name and ID** - Unique identifier (DOC-DS-XXX-NNN)
- [ ] **Description** - What it is and when to use it
- [ ] **Variants** - Visual/functional variations
- [ ] **Sizes** - Available size options
- [ ] **States** - All interactive states
- [ ] **Anatomy** - Component parts breakdown
- [ ] **Accessibility** - ARIA, keyboard, focus requirements
- [ ] **Do's and Don'ts** - Usage guidelines
- [ ] **Related Components** - Links to related items
- [ ] **Code Examples** - Implementation samples

### Design System Document Structure

```
.mlda/docs/design-system/
├── index.md                    # Design system overview
├── foundations/
│   ├── colors.md               # Color tokens
│   ├── typography.md           # Typography tokens
│   ├── spacing.md              # Spacing tokens
│   ├── grid.md                 # Grid system
│   └── motion.md               # Animation tokens
├── components/
│   ├── primitives/
│   │   ├── button.md
│   │   ├── input.md
│   │   └── ...
│   ├── composites/
│   │   ├── card.md
│   │   ├── form-field.md
│   │   └── ...
│   └── patterns/
│       ├── navigation.md
│       ├── modal.md
│       └── ...
└── guidelines/
    ├── accessibility.md
    ├── responsive.md
    └── writing.md
```

---

## Phase 5: Governance

### Version Management

```yaml
versioning:
  current: "2.1.0"
  scheme: "semver"

  changelog:
    - version: "2.1.0"
      date: "2026-01-15"
      changes:
        added:
          - "New Badge component"
        changed:
          - "Button hover states updated"
        deprecated:
          - "LinkButton (use Button with as='a')"
        removed: []

  compatibility:
    breaking_changes: "Major version only"
    deprecation_period: "2 minor versions"
```

### Contribution Process

```yaml
contribution:
  proposal:
    required_info:
      - "Use case description"
      - "Proposed design"
      - "Accessibility considerations"
      - "Related components"

  review:
    - "Design review by UX team"
    - "Accessibility audit"
    - "Technical feasibility"
    - "Documentation completeness"

  approval:
    required_approvals: 2
    approvers: ["ux-lead", "dev-lead"]
```

---

## Output: Design System Document

### Design System Overview Template

```markdown
# [Project Name] Design System

**DOC-ID:** DOC-DS-001
**Version:** 1.0.0
**Last Updated:** [Date]

## Overview

[Brief description of the design system purpose and principles]

## Design Principles

1. **[Principle 1]** - [Description]
2. **[Principle 2]** - [Description]
3. **[Principle 3]** - [Description]

## Foundations

### Colors
[Link to DOC-DS-COLORS-001]

### Typography
[Link to DOC-DS-TYPE-001]

### Spacing
[Link to DOC-DS-SPACE-001]

### Grid
[Link to DOC-DS-GRID-001]

## Components

### Primitives
- [Button](DOC-DS-BTN-001)
- [Input](DOC-DS-INPUT-001)
- ...

### Composites
- [Card](DOC-DS-CARD-001)
- [Form Field](DOC-DS-FORM-001)
- ...

### Patterns
- [Navigation](DOC-DS-NAV-001)
- [Modal](DOC-DS-MODAL-001)
- ...

## Resources

- Figma Library: [Link]
- Code Repository: [Link]
- Contribution Guide: [Link]

---
*[Project] Design System v1.0.0*
```

---

## Commands

Invoke this skill via:
- `/skills:design-system`
- `*design-system` (when in UX mode)

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--scope` | full, foundations, component | full |
| `--component` | Specific component to define | none |
| `--context` | DOC-IDs for context | auto-detect |

---

## Learning Integration

At session end, if new patterns discovered:

```
New learnings identified:
- Token pattern: "8px base unit works well for this project"
- Component pattern: "Card always needs elevation for this brand"
- Accessibility: "Minimum contrast ratio increased to 5:1"

Save to .mlda/topics/design-system/learning.yaml? [y/n]
```

---

*design-system v2.0 | Neocortex Methodology | UX Skill*
