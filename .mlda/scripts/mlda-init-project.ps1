<#
.SYNOPSIS
    Initializes MLDA (Modular Linked Documentation Architecture) with Neocortex v2 support.

.DESCRIPTION
    Scaffolds the complete MLDA structure with Neocortex v2 features:
    - docs/ folder with domain subfolders
    - scripts/ folder with MLDA utilities (including mlda-learning.ps1)
    - templates/ folder with document templates (v2 sidecar format)
    - schemas/ folder with validation schemas
    - topics/ folder for topic-based learning
    - config.yaml for Neocortex configuration
    - registry.yaml for document tracking
    - README.md with project-specific instructions

.PARAMETER ProjectPath
    Target path where .mlda/ will be created. Defaults to current directory.

.PARAMETER Domains
    Array of domain codes (API, AUTH, DATA, INV, SEC, UI, INFRA, INT, TEST, DOC)

.PARAMETER ProjectName
    Name of the project (used in registry). Defaults to folder name.

.PARAMETER SourcePath
    Path to source MLDA scripts/templates. Defaults to script's parent .mlda folder.

.PARAMETER Migrate
    If set, will create .meta.yaml sidecars for existing .md files.

.EXAMPLE
    .\mlda-init-project.ps1 -Domains API,DATA,SEC
    .\mlda-init-project.ps1 -ProjectPath "C:\Projects\MyProject" -Domains API,AUTH -Migrate
    .\mlda-init-project.ps1 -Domains INV -ProjectName "Invoice Module"
#>

param(
    [Parameter()]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter(Mandatory=$true)]
    [ValidateSet("API", "AUTH", "DATA", "INV", "SEC", "UI", "INFRA", "INT", "TEST", "DOC")]
    [string[]]$Domains,

    [Parameter()]
    [string]$ProjectName,

    [Parameter()]
    [string]$SourcePath,

    [switch]$Migrate
)

$ErrorActionPreference = "Stop"

# Resolve paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $SourcePath) {
    $SourcePath = Split-Path -Parent $ScriptDir  # Parent of scripts/ = .mlda/
}

$TargetMlda = Join-Path $ProjectPath ".mlda"
$TargetDocs = Join-Path $TargetMlda "docs"
$TargetScripts = Join-Path $TargetMlda "scripts"
$TargetTemplates = Join-Path $TargetMlda "templates"
$TargetSchemas = Join-Path $TargetMlda "schemas"
$TargetTopics = Join-Path $TargetMlda "topics"

if (-not $ProjectName) {
    $ProjectName = Split-Path $ProjectPath -Leaf
}

$Date = Get-Date -Format "yyyy-MM-dd"

Write-Host "`n=== MLDA Project Initialization ===" -ForegroundColor Cyan
Write-Host "Project:  $ProjectName"
Write-Host "Target:   $TargetMlda"
Write-Host "Domains:  $($Domains -join ', ')"
Write-Host "Source:   $SourcePath"

# Check if .mlda already exists
if (Test-Path $TargetMlda) {
    Write-Host "`nWarning: .mlda/ already exists at target location!" -ForegroundColor Yellow
    $response = Read-Host "Overwrite (o), Merge (m), or Cancel (c)?"
    switch ($response.ToLower()) {
        "c" { Write-Host "Cancelled."; exit 0 }
        "o" { Remove-Item -Path $TargetMlda -Recurse -Force }
        "m" { Write-Host "Merging with existing structure..." }
        default { Write-Host "Invalid option. Cancelled."; exit 1 }
    }
}

# Create folder structure
Write-Host "`nCreating folder structure..." -ForegroundColor Yellow

# Main folders
New-Item -ItemType Directory -Path $TargetMlda -Force | Out-Null
New-Item -ItemType Directory -Path $TargetDocs -Force | Out-Null
New-Item -ItemType Directory -Path $TargetScripts -Force | Out-Null
New-Item -ItemType Directory -Path $TargetTemplates -Force | Out-Null
New-Item -ItemType Directory -Path $TargetSchemas -Force | Out-Null
New-Item -ItemType Directory -Path $TargetTopics -Force | Out-Null

# Domain folders (docs and topics)
foreach ($domain in $Domains) {
    $domainLower = $domain.ToLower()

    # Create docs domain folder
    $domainPath = Join-Path $TargetDocs $domainLower
    New-Item -ItemType Directory -Path $domainPath -Force | Out-Null
    Write-Host "  Created: docs/$domainLower/" -ForegroundColor Green

    # Create topics domain folder with learning.yaml and domain.yaml
    $topicDomainPath = Join-Path $TargetTopics $domainLower
    New-Item -ItemType Directory -Path $topicDomainPath -Force | Out-Null
    Write-Host "  Created: topics/$domainLower/" -ForegroundColor Green
}

# Copy scripts from source
Write-Host "`nCopying scripts..." -ForegroundColor Yellow
$sourceScripts = Join-Path $SourcePath "scripts"
if (Test-Path $sourceScripts) {
    $scriptFiles = @(
        "mlda-create.ps1",
        "mlda-registry.ps1",
        "mlda-validate.ps1",
        "mlda-brief.ps1",
        "mlda-learning.ps1",
        "mlda-generate-index.ps1",              # DEC-007: Two-tier learning
        "mlda-generate-activation-context.ps1", # DEC-009: Activation context
        "mlda-handoff.ps1",
        "mlda-graph.ps1"
    )
    foreach ($script in $scriptFiles) {
        $srcFile = Join-Path $sourceScripts $script
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination $TargetScripts
            Write-Host "  Copied: scripts/$script" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  Warning: Source scripts not found. Creating minimal versions." -ForegroundColor Yellow
}

# Copy schemas from source
Write-Host "`nCopying schemas..." -ForegroundColor Yellow
$sourceSchemas = Join-Path $SourcePath "schemas"
if (Test-Path $sourceSchemas) {
    Copy-Item -Path "$sourceSchemas\*" -Destination $TargetSchemas -Force
    Write-Host "  Copied: schemas/*" -ForegroundColor Green
} else {
    Write-Host "  Warning: Source schemas not found." -ForegroundColor Yellow
}

# Copy templates from source
Write-Host "`nCopying templates..." -ForegroundColor Yellow
$sourceTemplates = Join-Path $SourcePath "templates"
if (Test-Path $sourceTemplates) {
    Copy-Item -Path "$sourceTemplates\*" -Destination $TargetTemplates -Force
    Write-Host "  Copied: templates/*" -ForegroundColor Green
} else {
    # Create minimal templates
    $topicDocTemplate = @"
# {Title}

**DOC-ID:** {DOC-ID}

---

## Summary

{Overview of this topic}

---

## Content

{Main content}

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| {date} | {author} | Initial creation |
"@
    Set-Content -Path (Join-Path $TargetTemplates "topic-doc.md") -Value $topicDocTemplate

    $topicMetaTemplate = @"
id: {DOC-ID}
title: "{Title}"
status: active

created:
  date: "{date}"
  by: "{author}"

updated:
  date: "{date}"
  by: "{author}"

tags: []
related: []
"@
    Set-Content -Path (Join-Path $TargetTemplates "topic-meta.yaml") -Value $topicMetaTemplate
    Write-Host "  Created: templates/topic-doc.md" -ForegroundColor Green
    Write-Host "  Created: templates/topic-meta.yaml" -ForegroundColor Green
}

# Create config.yaml (Neocortex v2)
Write-Host "`nCreating Neocortex config..." -ForegroundColor Yellow
$sourceConfigTemplate = Join-Path $SourcePath "templates\neocortex-config.yaml"
if (Test-Path $sourceConfigTemplate) {
    Copy-Item -Path $sourceConfigTemplate -Destination (Join-Path $TargetMlda "config.yaml")
    Write-Host "  Copied: config.yaml (from template)" -ForegroundColor Green
} else {
    # Create minimal config inline
    $configContent = @"
# Neocortex Configuration
# Schema: .mlda/schemas/neocortex-config.schema.yaml

version: "2.0"

context_limits:
  soft_threshold_tokens: 35000
  hardstop_tokens: 50000
  soft_threshold_documents: 8
  hardstop_documents: 12

learning:
  auto_save_prompt: true
  activation_logging: true

multi_agent:
  enabled: true
  auto_decompose: false

navigation:
  max_traversal_depth: 3
  two_phase_loading: true
"@
    Set-Content -Path (Join-Path $TargetMlda "config.yaml") -Value $configContent
    Write-Host "  Created: config.yaml (minimal)" -ForegroundColor Green
}

# Create registry.yaml
Write-Host "`nCreating registry..." -ForegroundColor Yellow
$domainsYaml = ($Domains | ForEach-Object { $_.ToLower() }) -join ", "
$registryContent = @"
# MLDA Document Registry
# Project: $ProjectName
# Initialized: $Date
# Schema Version: 2.0 (Neocortex)

project: "$ProjectName"
created: "$Date"
schema_version: "2.0"
domains: [$domainsYaml]

# Document entries are added automatically by mlda-create.ps1
# or manually following this format:
#
# documents:
#   - id: DOC-API-001
#     title: "Document Title"
#     path: docs/api/document-slug.md
#     status: active

documents: []
"@
Set-Content -Path (Join-Path $TargetMlda "registry.yaml") -Value $registryContent
Write-Host "  Created: registry.yaml" -ForegroundColor Green

# Create README.md
Write-Host "`nCreating README..." -ForegroundColor Yellow

# Build domain list for README
$domainList = ($Domains | ForEach-Object { "  - $($_.ToLower())/" }) -join "`n"
$domainExamples = ($Domains | ForEach-Object { "- $_ -> DOC-$_-001" }) -join "`n"

$topicList = ($Domains | ForEach-Object { "    - $($_.ToLower())/" }) -join "`n"
$readmeContent = @"
# MLDA - $ProjectName

**Modular Linked Documentation Architecture** with **Neocortex v2**

Initialized: $Date

---

## Structure

``````
.mlda/
  docs/                # Topic documents organized by domain
$domainList
  schemas/             # Validation schemas (v2)
  scripts/             # MLDA utilities
    - mlda-create.ps1
    - mlda-registry.ps1
    - mlda-validate.ps1
    - mlda-brief.ps1
    - mlda-learning.ps1                   # Topic learning
    - mlda-generate-index.ps1             # DEC-007: Learning index
    - mlda-generate-activation-context.ps1 # DEC-009: Activation context
    - mlda-handoff.ps1
    - mlda-graph.ps1
  templates/           # Document templates
  topics/              # v2: Topic-based learning
$topicList
  config.yaml          # v2: Neocortex configuration
  registry.yaml        # Document index
  README.md            # This file
``````

---

## Quick Start

### Create a New Document

``````powershell
.\.mlda\scripts\mlda-create.ps1 -Title "My Document" -Domain $($Domains[0])
``````

### Rebuild Registry

``````powershell
.\.mlda\scripts\mlda-registry.ps1
``````

### Validate Links

``````powershell
.\.mlda\scripts\mlda-validate.ps1
``````

---

## Neocortex v2 Features

### Topic-Based Learning

``````powershell
# List available topics
.\.mlda\scripts\mlda-learning.ps1 -List

# Initialize a topic
.\.mlda\scripts\mlda-learning.ps1 -Topic $($Domains[0].ToLower()) -Init

# Load topic learnings
.\.mlda\scripts\mlda-learning.ps1 -Topic $($Domains[0].ToLower()) -Load
``````

### Configuration

Edit ``config.yaml`` to customize:
- Context limits (tokens, documents)
- Learning behavior
- Multi-agent settings
- Navigation rules

---

## DOC-ID Convention

Format: ``DOC-{DOMAIN}-{NNN}``

Examples:
$domainExamples

---

## Adding Relationships

In ``.meta.yaml`` sidecars, use the ``related`` field:

``````yaml
related:
  - id: DOC-API-001
    type: references
    why: "Uses patterns defined here"
``````

Relationship types: ``references``, ``extends``, ``depends-on``, ``supersedes``

---

*Neocortex v2.0 | MLDA with topic-based learning*
"@
Set-Content -Path (Join-Path $TargetMlda "README.md") -Value $readmeContent
Write-Host "  Created: README.md" -ForegroundColor Green

# Migration mode - create .meta.yaml for existing .md files
if ($Migrate) {
    Write-Host "`nMigrating existing documents..." -ForegroundColor Yellow

    $existingDocs = Get-ChildItem -Path $ProjectPath -Filter "*.md" -File |
                    Where-Object { $_.Name -ne "README.md" }

    if ($existingDocs.Count -gt 0) {
        $counter = @{}
        foreach ($domain in $Domains) {
            $counter[$domain] = 1
        }

        # Default domain for migration
        $defaultDomain = $Domains[0]

        foreach ($doc in $existingDocs) {
            $docId = "DOC-$defaultDomain-{0:D3}" -f $counter[$defaultDomain]
            $counter[$defaultDomain]++

            $metaFile = $doc.FullName -replace '\.md$', '.meta.yaml'

            if (-not (Test-Path $metaFile)) {
                $metaContent = @"
id: $docId
title: "$($doc.BaseName)"
status: active

created:
  date: "$Date"
  by: "migration"

updated:
  date: "$Date"
  by: "migration"

tags:
  - migrated
  - $($defaultDomain.ToLower())

related: []

# NOTE: This sidecar was auto-generated during MLDA migration.
# Review and update:
# - Correct the domain if needed
# - Add related document references
# - Update tags
"@
                Set-Content -Path $metaFile -Value $metaContent
                Write-Host "  Created: $($doc.Name -replace '\.md$', '.meta.yaml')" -ForegroundColor Green
            }
        }

        Write-Host "`n  Migrated $($existingDocs.Count) documents" -ForegroundColor Cyan
        Write-Host "  Review .meta.yaml files to correct domains and add relationships" -ForegroundColor Yellow
    } else {
        Write-Host "  No existing .md files found to migrate" -ForegroundColor Gray
    }
}

# Generate initial activation context (DEC-009)
Write-Host "`nGenerating activation context..." -ForegroundColor Yellow
$activationScript = Join-Path $TargetScripts "mlda-generate-activation-context.ps1"
$sourceActivationScript = Join-Path $sourceScripts "mlda-generate-activation-context.ps1"

# Copy the activation context generator script if not already copied
if ((Test-Path $sourceActivationScript) -and -not (Test-Path $activationScript)) {
    Copy-Item -Path $sourceActivationScript -Destination $TargetScripts
    Write-Host "  Copied: scripts/mlda-generate-activation-context.ps1" -ForegroundColor Green
}

# Also copy the learning index generator (DEC-007)
$sourceIndexScript = Join-Path $sourceScripts "mlda-generate-index.ps1"
$targetIndexScript = Join-Path $TargetScripts "mlda-generate-index.ps1"
if ((Test-Path $sourceIndexScript) -and -not (Test-Path $targetIndexScript)) {
    Copy-Item -Path $sourceIndexScript -Destination $TargetScripts
    Write-Host "  Copied: scripts/mlda-generate-index.ps1" -ForegroundColor Green
}

# Generate initial activation context
if (Test-Path $activationScript) {
    try {
        & $activationScript -Quiet
        Write-Host "  Generated: activation-context.yaml" -ForegroundColor Green
    } catch {
        Write-Host "  Warning: Could not generate activation context. Run manually later." -ForegroundColor Yellow
    }
} else {
    # Create minimal activation context inline
    $activationContent = @"
# MLDA Activation Context
# Pre-computed lightweight context for mode awakening (DEC-009)
# Generated: $Date
# Generator: mlda-init-project.ps1 (initial)

generated: "$Date"
generator_version: 1
generator_script: "mlda-init-project.ps1"

mlda:
  status: initialized
  doc_count: 0
  domains: [$domainsYaml]
  orphan_count: 0
  health: healthy

handoff: null

learning:
  topics_total: $($Domains.Count)
  topics_with_data: 0
  sessions_total: 0
  recent_topics: []
  highlights: []

config:
  context_soft_limit: 35000
  context_hard_limit: 50000
  auto_gather_context: true
"@
    Set-Content -Path (Join-Path $TargetMlda "activation-context.yaml") -Value $activationContent
    Write-Host "  Created: activation-context.yaml (minimal)" -ForegroundColor Green
}

# Summary
Write-Host "`n=== Initialization Complete (Neocortex v2) ===" -ForegroundColor Cyan
Write-Host @"

MLDA has been initialized at: $TargetMlda

Created:
- docs/           Domain folders for documents
- schemas/        Validation schemas
- scripts/        MLDA utilities
- templates/      Document templates
- topics/         Topic-based learning folders
- config.yaml     Neocortex configuration
- registry.yaml   Document index
- activation-context.yaml  Pre-computed activation context (DEC-009)

Next steps:
1. Create new documents:
   .\.mlda\scripts\mlda-create.ps1 -Title "Doc Name" -Domain $($Domains[0])

2. Initialize topic learning:
   .\.mlda\scripts\mlda-learning.ps1 -Topic $($Domains[0].ToLower()) -Init

3. Validate link integrity:
   .\.mlda\scripts\mlda-validate.ps1

"@
