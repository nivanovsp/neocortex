# MLDA Starter Kit

**Modular Linked Documentation Architecture** - Minimal validation setup.

---

## What's This?

A lightweight system for creating small, linked topic documents instead of monolithic docs.

**Core idea:** One topic = one document + one metadata file.

---

## Structure

```
.mlda/
├── docs/              # Your topic documents go here
│   └── {domain}/      # Organized by domain (auth/, api/, etc.)
│       ├── {topic}.md
│       └── {topic}.meta.yaml
├── templates/         # Copy these when creating new docs
│   ├── topic-doc.md
│   └── topic-meta.yaml
├── registry.yaml      # Index of all documents
└── README.md          # You are here
```

---

## How to Create a Topic Document

1. **Pick a domain** (e.g., `auth`, `api`, `ui`)

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
- DOC-UI-012     (UI topic #12)
```

Rules:
- IDs are permanent (never reuse)
- Numbers are sequential within domain
- Keep a simple counter per domain

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
    why: "Defines auth patterns used here"
```

---

## What to Validate

Use this setup to test:

1. **Do small topic docs work better?** - Easier to read/update than monoliths?
2. **Does DOC-ID linking help?** - Can you trace relationships?
3. **Is the overhead worth it?** - Does the metadata sidecar add value?

If yes to all three, consider fuller adoption.

---

## What's NOT Included (On Purpose)

- Auto-generation scripts
- Session manifests
- Health metrics
- Complex registry structures

Add these only if you feel the pain that justifies them.
