<#
.SYNOPSIS
    Creates an MLDA topic document with linked Beads issue.

.DESCRIPTION
    Wrapper script that:
    1. Creates a Beads issue for tracking
    2. Scaffolds topic doc (.md) and metadata sidecar (.meta.yaml)
    3. Assigns DOC-ID from the specified domain
    4. Links bead ID in metadata
    5. Updates registry.yaml

.PARAMETER Title
    The title of the topic document (required)

.PARAMETER Domain
    The domain code (AUTH, UM, API, UI, DATA, etc.) (required)

.PARAMETER Type
    Beads issue type: task, bug, epic, story (default: task)

.PARAMETER Priority
    Beads priority 0-4, lower=higher (default: 2)

.PARAMETER Author
    Author name for metadata (default: current user)

.PARAMETER NoBead
    Skip creating Beads issue (document only)

.EXAMPLE
    .\mlda-create.ps1 -Title "Access Control Patterns" -Domain AUTH
    .\mlda-create.ps1 -Title "OAuth Integration" -Domain AUTH -Type epic -Priority 1
    .\mlda-create.ps1 -Title "Quick Note" -Domain API -NoBead
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Title,

    [Parameter(Mandatory=$true, Position=1)]
    [ValidateSet("AUTH", "UM", "API", "UI", "DATA", "INT", "SEC", "PERF", "ONBOARD", "BILL", "INFRA", "TEST", "DOC", "CORE", "METH", "PROC")]
    [string]$Domain,

    [Parameter()]
    [ValidateSet("task", "bug", "epic", "story")]
    [string]$Type = "task",

    [Parameter()]
    [ValidateRange(0, 4)]
    [int]$Priority = 2,

    [Parameter()]
    [string]$Author = $env:USERNAME,

    [switch]$NoBead
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$TemplatesDir = Join-Path $MldaRoot "templates"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Generate slug from title
function ConvertTo-Slug {
    param([string]$Text)
    $Text.ToLower() -replace '[^a-z0-9\s-]', '' -replace '\s+', '-' -replace '-+', '-' -replace '^-|-$', ''
}

# Get next DOC-ID for domain from registry
function Get-NextDocId {
    param([string]$Domain)

    if (-not (Test-Path $RegistryFile)) {
        return "DOC-$Domain-001"
    }

    $content = Get-Content $RegistryFile -Raw
    $pattern = "DOC-$Domain-(\d{3})"
    $matches = [regex]::Matches($content, $pattern)

    if ($matches.Count -eq 0) {
        return "DOC-$Domain-001"
    }

    $maxNum = 0
    foreach ($match in $matches) {
        $num = [int]$match.Groups[1].Value
        if ($num -gt $maxNum) { $maxNum = $num }
    }

    $nextNum = $maxNum + 1
    return "DOC-$Domain-{0:D3}" -f $nextNum
}

# Add entry to registry
function Add-ToRegistry {
    param(
        [string]$DocId,
        [string]$Title,
        [string]$RelPath
    )

    $entry = @"

  - id: $DocId
    title: "$Title"
    path: $RelPath
    status: active
"@

    # Read current content
    $content = Get-Content $RegistryFile -Raw

    # Replace empty documents array or append to existing
    if ($content -match "documents:\s*\[\]") {
        $content = $content -replace "documents:\s*\[\]", "documents:$entry"
    } else {
        # Append before any trailing comments or whitespace
        $content = $content.TrimEnd() + $entry + "`n"
    }

    Set-Content $RegistryFile -Value $content -NoNewline
}

# Main execution
Write-Host "`n=== MLDA Create ===" -ForegroundColor Cyan

$slug = ConvertTo-Slug $Title
$docId = Get-NextDocId $Domain
$domainLower = $Domain.ToLower()
$date = Get-Date -Format "yyyy-MM-dd"

Write-Host "Title:   $Title"
Write-Host "Domain:  $Domain"
Write-Host "DOC-ID:  $docId"
Write-Host "Slug:    $slug"

# Create domain folder if needed
$domainDir = Join-Path $DocsDir $domainLower
if (-not (Test-Path $domainDir)) {
    New-Item -ItemType Directory -Path $domainDir -Force | Out-Null
    Write-Host "Created: $domainLower/" -ForegroundColor Green
}

# File paths
$mdFile = Join-Path $domainDir "$slug.md"
$metaFile = Join-Path $domainDir "$slug.meta.yaml"

# Check if files already exist
if ((Test-Path $mdFile) -or (Test-Path $metaFile)) {
    Write-Host "`nError: Document already exists at this path!" -ForegroundColor Red
    Write-Host "  $mdFile"
    exit 1
}

# Create Beads issue (unless -NoBead)
$beadId = ""
if (-not $NoBead) {
    Write-Host "`nCreating Beads issue..." -ForegroundColor Yellow

    # Temporarily allow errors from bd command (it outputs warnings to stderr)
    $ErrorActionPreference = "Continue"
    $bdOutput = & bd create "$Title" -t $Type -p $Priority 2>&1 | Out-String
    $ErrorActionPreference = "Stop"

    # Extract bead ID from output (format: "Created issue: ProjectName-N" or just "ProjectName-N")
    if ($bdOutput -match 'Created issue:\s*([A-Za-z0-9\s]+-\d+)') {
        $beadId = $Matches[1].Trim()
        Write-Host "Bead:    $beadId" -ForegroundColor Green
    } elseif ($bdOutput -match '([A-Za-z][A-Za-z0-9\s]*-\d+)') {
        $beadId = $Matches[1].Trim()
        Write-Host "Bead:    $beadId" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not parse Beads ID from output" -ForegroundColor Yellow
        Write-Host $bdOutput
    }
}

# Create topic document from template
$mdContent = @"
# $Title

**DOC-ID:** $docId

---

## Summary

{2-3 sentence overview of this topic}

---

## Content

{Main content - organized however makes sense for this topic}

---

## Requirements

{If applicable - delete section if not needed}

- REQ-001: {Requirement}

---

## Decisions

{Key decisions made - delete section if not needed}

| Decision | Rationale | Date |
|----------|-----------|------|
| {What} | {Why} | {When} |

---

## Open Questions

- [ ] {Unresolved question}

---

## Change Log

| Date | Author | Change |
|------|--------|--------|
| $date | $Author | Initial creation |
"@

# Create metadata sidecar (v2 format with Neocortex fields)
$beadLine = if ($beadId) { "beads: `"$beadId`"" } else { "# beads: `"Project-NNN`"" }
$metaContent = @"
# MLDA Sidecar v2 - Neocortex Format
# Schema: .mlda/schemas/sidecar-v2.schema.yaml

id: $docId
title: "$Title"
status: active

created:
  date: "$date"
  by: "$Author"

updated:
  date: "$date"
  by: "$Author"

tags:
  - $domainLower

domain: $Domain

related: []
# related:
#   - id: DOC-XXX-NNN
#     type: depends-on    # depends-on | extends | references | supersedes
#     why: "Explanation of relationship"

# Neocortex v2: Predictive Context
# Uncomment and populate based on document usage patterns
# predictions:
#   when_implementing:
#     required: []
#     likely: []
#   when_debugging:
#     required: []
#     likely: []

# Neocortex v2: Reference Frames
reference_frames:
  domain: $domainLower
  layer: requirements    # requirements | design | implementation | testing
  stability: evolving    # evolving | stable | deprecated
  scope: cross-cutting   # frontend | backend | infrastructure | cross-cutting

# Neocortex v2: Traversal Boundaries
boundaries:
  related_domains: []    # Domains OK to traverse into
  isolated_from: []      # Domains to never traverse into

# Neocortex v2: Critical Markers
has_critical_markers: false

$beadLine
"@

# Write files
Set-Content $mdFile -Value $mdContent
Write-Host "Created: docs/$domainLower/$slug.md" -ForegroundColor Green

Set-Content $metaFile -Value $metaContent.Trim()
Write-Host "Created: docs/$domainLower/$slug.meta.yaml" -ForegroundColor Green

# Update registry
Add-ToRegistry -DocId $docId -Title $Title -RelPath "docs/$domainLower/$slug.md"
Write-Host "Updated: registry.yaml" -ForegroundColor Green

# Regenerate activation context (DEC-009)
$activationScript = Join-Path $ScriptDir "mlda-generate-activation-context.ps1"
if (Test-Path $activationScript) {
    Write-Host "Regenerating activation context..." -ForegroundColor Yellow
    try {
        & $activationScript -Quiet
        Write-Host "Updated: activation-context.yaml" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not regenerate activation context" -ForegroundColor Yellow
    }
}

# Summary
Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "Document: $mdFile"
if ($beadId) {
    Write-Host "Bead:     $beadId (use 'bd show $beadId' to view)"
}
Write-Host ""
