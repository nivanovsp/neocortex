---
description: 'Create documents from YAML templates with interactive elicitation and MLDA integration'
---
# Create Document Skill

**RMS Skill** | Template-driven document creation with user interaction

## MLDA Auto-Integration

**Before starting document creation, check for MLDA:**

1. **Detect MLDA**: Check if `.mlda/` folder exists in project root
2. **If MLDA exists**:
   - Read `.mlda/registry.yaml` to get next available DOC-ID for the domain
   - After document creation, automatically create `.meta.yaml` sidecar
   - Add document entry to registry
   - Ask user about related documents
3. **If MLDA not present**: Proceed with standard document creation

### MLDA Sidecar Template

When MLDA is detected, create this sidecar alongside the document:

```yaml
id: {DOC-ID}           # e.g., DOC-INV-016
title: "{Document Title}"
status: active

created:
  date: "{YYYY-MM-DD}"
  by: "{current_mode or 'analyst'}"

updated:
  date: "{YYYY-MM-DD}"
  by: "{current_mode or 'analyst'}"

tags:
  - {domain}           # e.g., inv, api, auth
  - {template_type}    # e.g., project-brief, market-research

related: []            # Ask user if any related docs
```

### Registry Update

Add entry to `.mlda/registry.yaml`:

```yaml
- id: {DOC-ID}
  title: "{Document Title}"
  path: "{relative_path_to_document}"
  status: active
  type: {template_type}
```

---

## ⚠️ CRITICAL EXECUTION NOTICE ⚠️

**THIS IS AN EXECUTABLE WORKFLOW - NOT REFERENCE MATERIAL**

When this task is invoked:

1. **DISABLE ALL EFFICIENCY OPTIMIZATIONS** - This workflow requires full user interaction
2. **MANDATORY STEP-BY-STEP EXECUTION** - Each section must be processed sequentially with user feedback
3. **ELICITATION IS REQUIRED** - When `elicit: true`, you MUST use the 1-9 format and wait for user response
4. **NO SHORTCUTS ALLOWED** - Complete documents cannot be created without following this workflow

**VIOLATION INDICATOR:** If you create a complete document without user interaction, you have violated this workflow.

## Critical: Template Discovery

If a YAML Template has not been provided, list all templates from .claude/commands/templates or ask the user to provide another.

## CRITICAL: Mandatory Elicitation Format

**When `elicit: true`, this is a HARD STOP requiring user interaction:**

**YOU MUST:**

1. Present section content
2. Provide detailed rationale (explain trade-offs, assumptions, decisions made)
3. **STOP and present numbered options 1-9:**
   - **Option 1:** Always "Proceed to next section"
   - **Options 2-9:** Select 8 methods from data/elicitation-methods
   - End with: "Select 1-9 or just type your question/feedback:"
4. **WAIT FOR USER RESPONSE** - Do not proceed until user selects option or provides feedback

**WORKFLOW VIOLATION:** Creating content for elicit=true sections without user interaction violates this task.

**NEVER ask yes/no questions or use any other format.**

## Processing Flow

1. **Check for MLDA** - Look for `.mlda/` folder in project root
   - If found: Note MLDA is active, read registry for next DOC-ID
   - If not found: Proceed without MLDA integration
2. **Parse YAML template** - Load template metadata and sections
3. **Set preferences** - Show current mode (Interactive), confirm output file
   - If MLDA active: Show assigned DOC-ID (e.g., "This document will be DOC-INV-016")
4. **Process each section:**
   - Skip if condition unmet
   - Check agent permissions (owner/editors) - note if section is restricted to specific agents
   - Draft content using section instruction
   - Present content + detailed rationale
   - **IF elicit: true** → MANDATORY 1-9 options format
   - Save to file if possible
5. **Continue until complete**
6. **MLDA Finalization** (if MLDA active):
   - Create `.meta.yaml` sidecar file alongside the document
   - Ask: "Are there related documents? Enter DOC-IDs or 'none'"
   - Update `.mlda/registry.yaml` with new entry
   - Confirm: "Document registered as {DOC-ID} in MLDA"

## Detailed Rationale Requirements

When presenting section content, ALWAYS include rationale that explains:

- Trade-offs and choices made (what was chosen over alternatives and why)
- Key assumptions made during drafting
- Interesting or questionable decisions that need user attention
- Areas that might need validation

## Elicitation Results Flow

After user selects elicitation method (2-9):

1. Execute method from data/elicitation-methods
2. Present results with insights
3. Offer options:
   - **1. Apply changes and update section**
   - **2. Return to elicitation menu**
   - **3. Ask any questions or engage further with this elicitation**

## Agent Permissions

When processing sections with agent permission fields:

- **owner**: Note which agent role initially creates/populates the section
- **editors**: List agent roles allowed to modify the section
- **readonly**: Mark sections that cannot be modified after creation

**For sections with restricted access:**

- Include a note in the generated document indicating the responsible agent
- Example: "_(This section is owned by dev-agent and can only be modified by dev-agent)_"

## YOLO Mode

User can type `#yolo` to toggle to YOLO mode (process all sections at once).

## CRITICAL REMINDERS

**❌ NEVER:**

- Ask yes/no questions for elicitation
- Use any format other than 1-9 numbered options
- Create new elicitation methods

**✅ ALWAYS:**

- Use exact 1-9 format when elicit: true
- Select options 2-9 from data/elicitation-methods only
- Provide detailed rationale explaining decisions
- End with "Select 1-9 or just type your question/feedback:"
