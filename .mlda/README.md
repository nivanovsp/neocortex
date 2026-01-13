# MLDA - Modular Linked Documentation Architecture

A lightweight system for creating small, linked topic documents instead of monolithic docs.

**Core idea:** One topic = one document + one metadata sidecar.

---

## Quick Start

### Initialize MLDA in a New Project

**Via Analyst Mode (Recommended):**
```
/modes:analyst
*init-project
```

**Via Skill:**
```
/skills:init-project
```

**Via PowerShell:**
```powershell
.\.mlda\scripts\mlda-init-project.ps1 -Domains API,AUTH,INV
```

### Automatic Integration

Once MLDA is initialized, document-creating commands **automatically**:
- Assign DOC-IDs from the registry
- Create `.meta.yaml` sidecars
- Update the registry
- Ask about related documents

Just use `*create-project-brief`, `*brainstorm`, etc. as normal!

---

## Structure

```
.mlda/
├── docs/              # Your topic documents go here
│   └── {domain}/      # Organized by domain (auth/, api/, inv/, etc.)
│       ├── {topic}.md
│       └── {topic}.meta.yaml
├── scripts/           # MLDA tooling
│   ├── mlda-init-project.ps1
│   ├── mlda-create.ps1
│   ├── mlda-registry.ps1
│   ├── mlda-validate.ps1
│   └── mlda-brief.ps1
├── templates/         # Copy these when creating new docs
│   ├── topic-doc.md
│   └── topic-meta.yaml
├── registry.yaml      # Index of all documents
└── README.md          # You are here
```

---

## Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `mlda-init-project.ps1` | Initialize MLDA in a project | `-Domains API,INV [-Migrate]` |
| `mlda-create.ps1` | Create a new topic document | `-Domain API -Title "My Doc"` |
| `mlda-registry.ps1` | Rebuild document registry | No arguments |
| `mlda-validate.ps1` | Check link integrity | No arguments |
| `mlda-brief.ps1` | Regenerate project brief | No arguments |

---

## Creating a Topic Document

### Option 1: Using the Script (Recommended)

```powershell
.\.mlda\scripts\mlda-create.ps1 -Domain API -Title "REST Endpoints"
```

This automatically:
- Assigns the next DOC-ID
- Creates both `.md` and `.meta.yaml` files
- Updates the registry

### Option 2: Manual Creation

1. **Pick a domain** (e.g., `auth`, `api`, `inv`)

2. **Create the folder** if it doesn't exist:
   ```
   .mlda/docs/auth/
   ```

3. **Copy templates** and rename:
   ```
   .mlda/docs/auth/access-control.md
   .mlda/docs/auth/access-control.meta.yaml
   ```

4. **Assign a DOC-ID** using format `DOC-{DOMAIN}-{NNN}`:
   ```
   DOC-AUTH-001
   ```

5. **Fill in the content** and metadata

6. **Add to registry.yaml**

---

## DOC-ID Convention

```
DOC-{DOMAIN}-{NNN}

Examples:
- DOC-AUTH-001   (Authentication topic #1)
- DOC-API-003    (API topic #3)
- DOC-INV-012    (Invoicing topic #12)
```

### Standard Domains

| Code | Domain |
|------|--------|
| API | API specifications |
| AUTH | Authentication |
| DATA | Data models |
| INV | Invoicing |
| SEC | Security |
| UI | User Interface |
| INFRA | Infrastructure |
| INT | Integrations |
| TEST | Testing |

Custom domains can be added per project.

---

## Linking Documents

In your `.md` file, reference other docs by DOC-ID:

```markdown
See [DOC-AUTH-001](../auth/access-control.md) for authentication details.
```

In your `.meta.yaml`, track relationships:

```yaml
related:
  - id: DOC-AUTH-001
    type: depends-on
    why: "Defines auth patterns used here"
```

Relationship types: `references`, `extends`, `depends-on`, `supersedes`

---

## Migration

For existing projects with documents:

```powershell
.\.mlda\scripts\mlda-init-project.ps1 -Domains INV -Migrate
```

The `-Migrate` flag:
- Creates `.meta.yaml` sidecars for existing `.md` files
- Assigns DOC-IDs sequentially
- Adds entries to registry

---

*MLDA v1.1 | RMS-BMAD Methodology*
