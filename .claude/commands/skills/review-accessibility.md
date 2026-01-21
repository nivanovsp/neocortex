---
description: 'WCAG compliance audit with Neocortex context and checklist-driven review'
---
# Review Accessibility Skill

**RMS Skill v2.0** | Comprehensive WCAG 2.1 accessibility audit using design system context, requirements, and structured checklist methodology

## When to Use

- Auditing designs or implementations for accessibility compliance
- Reviewing UI components against WCAG guidelines
- Validating accessibility requirements are met before release
- Creating accessibility remediation plans

## Prerequisites

- Design documentation, wireframes, or implementation to review
- Target WCAG conformance level (A, AA, or AAA)
- Design system documentation (recommended)
- MLDA initialized if using Neocortex integration

---

## Workflow Overview

```
+-----------------------------------------------------------------------+
|                    REVIEW ACCESSIBILITY WORKFLOW                       |
+-----------------------------------------------------------------------+
|                                                                        |
|  Phase 1: Context Gathering (Neocortex)                               |
|    +-- Load design system accessibility specs (DOC-DS-xxx)            |
|    +-- Load relevant requirements (DOC-REQ-xxx, DOC-A11Y-xxx)         |
|    +-- Load component/screen being reviewed                            |
|    +-- Extract existing accessibility decisions                        |
|                                                                        |
|  Phase 2: Scope Definition                                             |
|    +-- Identify what is being reviewed (design, code, or both)        |
|    +-- Determine target conformance level (A, AA, AAA)                |
|    +-- Identify user groups and assistive technologies                |
|                                                                        |
|  Phase 3: WCAG Principle Review                                        |
|    +-- Perceivable: Content accessible to senses                      |
|    +-- Operable: UI components navigable and operable                 |
|    +-- Understandable: Content readable and predictable               |
|    +-- Robust: Compatible with assistive technologies                 |
|                                                                        |
|  Phase 4: Findings Documentation                                       |
|    +-- Categorize by severity (Critical, Major, Minor)                |
|    +-- Map to WCAG success criteria                                   |
|    +-- Document remediation recommendations                            |
|                                                                        |
|  Phase 5: Report Generation                                            |
|    +-- Generate structured accessibility report                       |
|    +-- Prioritize remediation efforts                                 |
|    +-- Track against requirements                                      |
|                                                                        |
+-----------------------------------------------------------------------+
```

---

## Phase 1: Context Gathering

**Goal:** Load relevant accessibility context before review.

### Neocortex Integration

If MLDA is available, gather context from:

| Domain | DOC-ID Prefix | What to Extract |
|--------|---------------|-----------------|
| Accessibility | DOC-A11Y-xxx | Accessibility requirements, policies |
| Design System | DOC-DS-xxx | Accessible component patterns, color contrast |
| Requirements | DOC-REQ-xxx | User needs, compliance requirements |
| UI Patterns | DOC-UI-xxx | Component accessibility specs |

### Context Gathering Command

```
*gather-context --domains A11Y,DS,REQ --task-type accessibility_review
```

### Key Context to Extract

- Target conformance level (WCAG 2.1 Level AA is common)
- Regulatory requirements (ADA, Section 508, EN 301 549)
- User groups to support (screen reader users, keyboard-only, etc.)
- Existing accessibility decisions and patterns

---

## Phase 2: Scope Definition

### Review Scope Options

| Scope | What's Reviewed | Methods |
|-------|-----------------|---------|
| **Design Review** | Wireframes, mockups, prototypes | Visual inspection, annotation review |
| **Code Review** | HTML, ARIA, CSS, JavaScript | Static analysis, code inspection |
| **Full Audit** | Live implementation | Automated + manual testing |

### Conformance Levels

| Level | Description | Typical Requirement |
|-------|-------------|---------------------|
| **Level A** | Minimum accessibility | Rarely sufficient alone |
| **Level AA** | Standard accessibility | Most common target |
| **Level AAA** | Enhanced accessibility | Specific user groups |

### User Groups Checklist

- [ ] Screen reader users (JAWS, NVDA, VoiceOver)
- [ ] Keyboard-only users
- [ ] Users with low vision (magnification, high contrast)
- [ ] Users with color blindness
- [ ] Users with motor impairments
- [ ] Users with cognitive disabilities
- [ ] Users with hearing impairments

---

## Phase 3: WCAG Principle Review

### Principle 1: Perceivable

Information and UI components must be presentable to users in ways they can perceive.

#### 1.1 Text Alternatives (Level A)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 1.1.1 Non-text Content | All images have alt text | |
| | Decorative images have empty alt or CSS background | |
| | Complex images have extended descriptions | |
| | Form inputs have associated labels | |

#### 1.2 Time-based Media (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 1.2.1 Audio-only/Video-only | Alternatives provided | |
| 1.2.2 Captions (Prerecorded) | Synchronized captions | |
| 1.2.3 Audio Description | Audio description for video | |
| 1.2.5 Audio Description (AA) | Audio description for all video | |

#### 1.3 Adaptable (Level A)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 1.3.1 Info and Relationships | Semantic HTML used | |
| | Headings properly nested (h1-h6) | |
| | Lists marked up correctly | |
| | Tables have headers | |
| | Form fields have labels | |
| 1.3.2 Meaningful Sequence | Reading order logical | |
| 1.3.3 Sensory Characteristics | Instructions don't rely on shape/color alone | |

#### 1.4 Distinguishable (Level A/AA/AAA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 1.4.1 Use of Color (A) | Color not sole indicator | |
| 1.4.3 Contrast Minimum (AA) | 4.5:1 for normal text | |
| | 3:1 for large text (18pt+ or 14pt bold) | |
| 1.4.4 Resize Text (AA) | Text resizes to 200% without loss | |
| 1.4.5 Images of Text (AA) | Real text used, not images | |
| 1.4.10 Reflow (AA) | Content reflows at 320px width | |
| 1.4.11 Non-text Contrast (AA) | 3:1 for UI components and graphics | |
| 1.4.12 Text Spacing (AA) | Content works with increased spacing | |
| 1.4.13 Content on Hover/Focus (AA) | Dismissible, hoverable, persistent | |

### Principle 2: Operable

UI components and navigation must be operable.

#### 2.1 Keyboard Accessible (Level A)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 2.1.1 Keyboard | All functions keyboard accessible | |
| | Tab order logical | |
| | No keyboard traps | |
| 2.1.2 No Keyboard Trap | Can navigate away from all components | |
| 2.1.4 Character Key Shortcuts (A) | Can turn off/remap shortcuts | |

#### 2.2 Enough Time (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 2.2.1 Timing Adjustable | Users can extend time limits | |
| 2.2.2 Pause, Stop, Hide | Moving content can be paused | |

#### 2.3 Seizures and Physical Reactions (Level A)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 2.3.1 Three Flashes | No content flashes > 3 times/second | |

#### 2.4 Navigable (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 2.4.1 Bypass Blocks (A) | Skip navigation link present | |
| 2.4.2 Page Titled (A) | Descriptive page titles | |
| 2.4.3 Focus Order (A) | Focus order preserves meaning | |
| 2.4.4 Link Purpose (A) | Link text describes destination | |
| 2.4.5 Multiple Ways (AA) | Multiple ways to find pages | |
| 2.4.6 Headings and Labels (AA) | Headings/labels descriptive | |
| 2.4.7 Focus Visible (AA) | Focus indicator visible | |

#### 2.5 Input Modalities (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 2.5.1 Pointer Gestures (A) | Complex gestures have alternatives | |
| 2.5.2 Pointer Cancellation (A) | Can abort/undo pointer actions | |
| 2.5.3 Label in Name (A) | Visible label in accessible name | |
| 2.5.4 Motion Actuation (A) | Motion alternatives available | |

### Principle 3: Understandable

Information and UI operation must be understandable.

#### 3.1 Readable (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 3.1.1 Language of Page (A) | Page language declared | |
| 3.1.2 Language of Parts (AA) | Language changes marked | |

#### 3.2 Predictable (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 3.2.1 On Focus (A) | Focus doesn't trigger context change | |
| 3.2.2 On Input (A) | Input doesn't auto-submit | |
| 3.2.3 Consistent Navigation (AA) | Navigation consistent across pages | |
| 3.2.4 Consistent Identification (AA) | Same function = same label | |

#### 3.3 Input Assistance (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 3.3.1 Error Identification (A) | Errors identified in text | |
| 3.3.2 Labels or Instructions (A) | Required fields indicated | |
| 3.3.3 Error Suggestion (AA) | Suggestions for fixing errors | |
| 3.3.4 Error Prevention (AA) | Reversible, checked, confirmed | |

### Principle 4: Robust

Content must be robust enough for assistive technologies.

#### 4.1 Compatible (Level A/AA)

| Criterion | Check | Pass/Fail |
|-----------|-------|-----------|
| 4.1.1 Parsing (A) | Valid HTML (no duplicate IDs) | |
| 4.1.2 Name, Role, Value (A) | Custom controls have ARIA | |
| 4.1.3 Status Messages (AA) | Status messages announced | |

---

## Phase 4: Findings Documentation

### Severity Levels

| Severity | Definition | Examples |
|----------|------------|----------|
| **Critical** | Blocks access entirely | No keyboard access, missing form labels |
| **Major** | Significant barrier | Poor contrast, confusing navigation |
| **Minor** | Usability issue | Missing skip link, verbose alt text |

### Finding Documentation Format

```yaml
finding:
  id: A11Y-001
  severity: Critical
  wcag_criterion: "1.1.1 Non-text Content"
  conformance_level: A

  location:
    screen: "Login Page"
    component: "Submit Button"
    element: "button.submit-btn"

  issue: "Button has no accessible name"
  impact: "Screen reader users cannot identify button purpose"
  affected_users:
    - Screen reader users
    - Voice control users

  recommendation:
    short: "Add aria-label or visible text"
    detailed: |
      Option 1: Add visible text inside button
      Option 2: Add aria-label="Submit login form"
      Option 3: Add aria-labelledby referencing visible label

  design_system_ref: "DOC-DS-001#buttons"  # If applicable
  effort: low  # low, medium, high
```

---

## Phase 5: Report Generation

### Accessibility Report Template

```markdown
# Accessibility Review Report

**DOC-ID:** DOC-A11Y-XXX (if registered)
**Reviewed:** [Screen/Component/Application name]
**Date:** [Date]
**Reviewer:** UX Expert (Uma)
**Target Level:** WCAG 2.1 Level AA

## Executive Summary

**Overall Status:** [Pass / Pass with Issues / Fail]
**Critical Issues:** [N]
**Major Issues:** [N]
**Minor Issues:** [N]

### Conformance Summary

| Principle | Level A | Level AA |
|-----------|---------|----------|
| Perceivable | X/Y | X/Y |
| Operable | X/Y | X/Y |
| Understandable | X/Y | X/Y |
| Robust | X/Y | X/Y |

## Scope

- **What was reviewed:** [Description]
- **Testing methods:** [Manual inspection, automated tools, assistive tech]
- **Browsers/Devices:** [List]
- **Assistive Technologies:** [Screen readers, etc.]

## Findings

### Critical Issues

#### A11Y-001: [Issue Title]
- **WCAG:** [Criterion]
- **Location:** [Where]
- **Issue:** [Description]
- **Impact:** [Who is affected]
- **Recommendation:** [How to fix]
- **Effort:** [Low/Medium/High]

### Major Issues
...

### Minor Issues
...

## Passed Criteria

[List criteria that passed, for compliance documentation]

## Remediation Priority

| Priority | Finding | Effort | Impact |
|----------|---------|--------|--------|
| 1 | A11Y-001 | Low | Critical |
| 2 | A11Y-003 | Medium | Major |
| ... | ... | ... | ... |

## Recommendations

### Quick Wins (Low Effort, High Impact)
- [List]

### Design System Updates
- [Components needing accessibility improvements]

### Process Improvements
- [Suggestions for preventing future issues]

## Testing Tools Used

- [axe DevTools]
- [WAVE]
- [Lighthouse]
- [Color contrast analyzer]
- [Screen reader: NVDA/VoiceOver]

## References

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- Design System: [DOC-DS-XXX]
- Requirements: [DOC-REQ-XXX]

---
*Generated by UX Expert accessibility review*
```

---

## Automated Testing Integration

### Recommended Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| axe-core | Automated WCAG testing | Browser extension, CI/CD |
| WAVE | Visual accessibility evaluation | Browser extension |
| Lighthouse | Performance + accessibility | Browser DevTools, CI/CD |
| pa11y | Command-line testing | CI/CD integration |

### Automated vs. Manual

| Automated Can Detect | Manual Required For |
|---------------------|---------------------|
| Missing alt text | Alt text quality |
| Color contrast ratios | Meaningful reading order |
| Missing form labels | Keyboard usability |
| ARIA attribute errors | Screen reader experience |
| Duplicate IDs | Cognitive load assessment |

---

## Commands

Invoke this skill via:
- `/skills:review-accessibility`
- `*review-accessibility` (when in UX mode)

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--level` | Target conformance (A, AA, AAA) | AA |
| `--scope` | design, code, or full | design |
| `--context` | DOC-IDs for context | auto-detect |

---

## Learning Integration

At session end, if new patterns discovered:

```
New learnings identified:
- Common issue: "Color-only error indication in forms"
- Pattern: "Toast notifications need aria-live regions"
- Project-specific: "Brand blue fails contrast on gray background"

Save to .mlda/topics/accessibility/learning.yaml? [y/n]
```

---

## MLDA Finalization (Automatic)

When accessibility review output is generated, automatically perform these steps:

### 1. DOC-ID Assignment

- Read `.mlda/registry.yaml` for next available ID in A11Y domain
- Assign: `DOC-A11Y-{NNN}` (e.g., DOC-A11Y-001, DOC-A11Y-002)
- A11Y domain covers: audits, remediation plans, accessibility guidelines

### 2. Sidecar Creation

Create `{filename}.meta.yaml` alongside the accessibility report:

```yaml
id: DOC-A11Y-{NNN}
title: "{Accessibility Report title}"
status: draft
domain: A11Y
type: audit  # or: remediation, guidelines
created: "{date}"
summary: "{One-line description of audit scope and findings}"

related:
  - id: DOC-UI-xxx
    type: depends-on  # Strong signal - audits UI components
    why: "Accessibility review of this wireframe/component"
  - id: DOC-DS-xxx
    type: depends-on  # Strong signal - design system compliance
    why: "Verifies design system accessibility"
  - id: DOC-REQ-xxx
    type: references  # Weak signal - requirement context
    why: "Accessibility requirements from this document"

reference_frames:
  layer: design
  phase: ux-design

predictions:
  when_implementing:
    - DOC-UI-xxx  # Components being remediated
    - DOC-DS-xxx  # Design system updates needed
    - DOC-A11Y-xxx  # Related accessibility docs
```

### 3. Registry Update

After creating document and sidecar:
- Run: `.mlda/scripts/mlda-registry.ps1`
- Confirm: "Document registered as DOC-A11Y-{NNN} in MLDA"

### 4. Report Entry Points

List DOC-IDs that stories/developers should reference:

```
Entry Points for Stories:
- DOC-A11Y-{NNN}: {Title} (accessibility audit)
- Remediation needed for: {list affected DOC-UI-xxx}
- Design system updates: {list affected DOC-DS-xxx}

Developers should run: *gather-context DOC-A11Y-{NNN}
```

### Relationship Type Standards

| Old Type | Standard Type | Signal Strength |
|----------|---------------|-----------------|
| `uses` | `depends-on` | Strong - always follow |
| `leads_to` | `extends` | Medium - follow if depth allows |
| `alternative` | `references` | Weak - follow if relevant |

---

*review-accessibility v2.0 | Neocortex Methodology | UX Skill*
