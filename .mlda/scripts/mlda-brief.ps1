<#
.SYNOPSIS
    Generates a project brief from MLDA topic documents.

.DESCRIPTION
    Reads all topic documents from the registry and extracts their
    Summary sections to create a consolidated project brief organized
    by domain. The brief provides a high-level overview of all
    documented topics in the project.

.PARAMETER Output
    Output file path (default: .mlda/project-brief.md)

.PARAMETER Format
    Output format: markdown (default), json, or console

.PARAMETER IncludeDeprecated
    Include deprecated documents in the brief

.EXAMPLE
    .\mlda-brief.ps1                           # Generate default brief
    .\mlda-brief.ps1 -Output docs/brief.md     # Custom output path
    .\mlda-brief.ps1 -Format console           # Print to console only
    .\mlda-brief.ps1 -Format json              # Output as JSON
#>

param(
    [Parameter()]
    [string]$Output,

    [Parameter()]
    [ValidateSet("markdown", "json", "console")]
    [string]$Format = "markdown",

    [switch]$IncludeDeprecated
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

if (-not $Output) {
    $Output = Join-Path $MldaRoot "project-brief.md"
}

# Domain display names
$DomainNames = @{
    "AUTH" = "Authentication"
    "UM" = "User Management"
    "API" = "API Design"
    "UI" = "User Interface"
    "DATA" = "Data Models"
    "INT" = "Integrations"
    "SEC" = "Security"
    "PERF" = "Performance"
    "ONBOARD" = "Onboarding"
    "BILL" = "Billing"
    "INFRA" = "Infrastructure"
    "TEST" = "Testing"
    "DOC" = "Documentation"
}

# Load registry
function Load-Registry {
    $documents = @()

    if (-not (Test-Path $RegistryFile)) {
        Write-Host "Warning: Registry file not found" -ForegroundColor Yellow
        return $documents
    }

    $currentDoc = $null

    foreach ($line in (Get-Content $RegistryFile)) {
        # Skip comment lines
        if ($line -match "^\s*#") { continue }

        if ($line -match "^\s+-\s*id:\s*(.+)") {
            if ($currentDoc) { $documents += $currentDoc }
            $currentDoc = @{
                id = $Matches[1].Trim()
                title = ""
                path = ""
                status = "active"
            }
        }
        elseif ($currentDoc) {
            if ($line -match "^\s+title:\s*[`"']?([^`"']+)[`"']?") {
                $currentDoc.title = $Matches[1].Trim()
            }
            elseif ($line -match "^\s+path:\s*(.+)") {
                $currentDoc.path = $Matches[1].Trim()
            }
            elseif ($line -match "^\s+status:\s*(\w+)") {
                $currentDoc.status = $Matches[1].Trim()
            }
        }
    }

    if ($currentDoc) { $documents += $currentDoc }

    # Use comma operator to prevent PowerShell from unwrapping single-element array
    return ,$documents
}

# Extract summary from markdown file
function Get-Summary {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $content = Get-Content $FilePath -Raw

    # Extract text between "## Summary" and the next "---" or "##"
    if ($content -match "(?s)## Summary\s*\n+(.*?)(?=\n---|\n## |\z)") {
        $summary = $Matches[1].Trim()

        # Skip placeholder text
        if ($summary -match "^\{.*\}$" -or $summary -eq "") {
            return $null
        }

        return $summary
    }

    return $null
}

# Extract domain from DOC-ID
function Get-Domain {
    param([string]$DocId)

    if ($DocId -match "DOC-(\w+)-\d+") {
        return $Matches[1]
    }
    return "OTHER"
}

# Main execution
Write-Host "`n=== MLDA Brief Generator ===" -ForegroundColor Cyan

# Load documents from registry
Write-Host "`nLoading registry..." -ForegroundColor Yellow
$documents = Load-Registry

if ($documents.Count -eq 0) {
    Write-Host "No documents found in registry." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($documents.Count) document(s)"

# Filter by status
if (-not $IncludeDeprecated) {
    $documents = @($documents | Where-Object { $_.status -eq "active" })
    Write-Host "Active documents: $($documents.Count)"
}

# Extract summaries and group by domain
$byDomain = @{}
$noSummary = @()
$missingFile = @()

foreach ($doc in $documents) {
    $fullPath = Join-Path $MldaRoot $doc.path

    if (-not (Test-Path $fullPath)) {
        $missingFile += $doc
        continue
    }

    $summary = Get-Summary -FilePath $fullPath
    $domain = Get-Domain -DocId $doc.id

    if (-not $byDomain[$domain]) {
        $byDomain[$domain] = @()
    }

    $docInfo = @{
        id = $doc.id
        title = $doc.title
        path = $doc.path
        summary = $summary
    }

    if ($summary) {
        $byDomain[$domain] += $docInfo
    }
    else {
        $noSummary += $docInfo
    }
}

# Statistics
$stats = @{
    TotalDocs = $documents.Count
    WithSummary = ($byDomain.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
    NoSummary = $noSummary.Count
    MissingFile = $missingFile.Count
    Domains = $byDomain.Keys.Count
}

Write-Host "`nExtracted summaries from $($stats.WithSummary) document(s)"
if ($stats.NoSummary -gt 0) {
    Write-Host "Documents without summary: $($stats.NoSummary)" -ForegroundColor Yellow
}
if ($stats.MissingFile -gt 0) {
    Write-Host "Missing files: $($stats.MissingFile)" -ForegroundColor Red
}

# Generate output based on format
$date = Get-Date -Format "yyyy-MM-dd"

if ($Format -eq "json") {
    # JSON output
    $jsonOutput = @{
        generated = $date
        statistics = $stats
        domains = @{}
    }

    foreach ($domain in $byDomain.Keys | Sort-Object) {
        $jsonOutput.domains[$domain] = $byDomain[$domain]
    }

    $jsonContent = $jsonOutput | ConvertTo-Json -Depth 5

    if ($Format -eq "console") {
        Write-Host $jsonContent
    }
    else {
        $jsonPath = $Output -replace "\.md$", ".json"
        Set-Content $jsonPath -Value $jsonContent
        Write-Host "`nWritten: $jsonPath" -ForegroundColor Green
    }
}
else {
    # Markdown output
    $brief = @"
# Project Brief

> Auto-generated from MLDA topic documents on $date

---

## Overview

This brief provides a consolidated view of all documented topics in the project,
organized by domain. Each entry includes the document's summary extracted from
its topic document.

**Statistics:**
- Total documents: $($stats.TotalDocs)
- With summaries: $($stats.WithSummary)
- Domains covered: $($stats.Domains)

---

"@

    # Add domain sections
    foreach ($domain in $byDomain.Keys | Sort-Object) {
        $domainDocs = $byDomain[$domain]
        $domainName = if ($DomainNames[$domain]) { $DomainNames[$domain] } else { $domain }

        $brief += "`n## $domainName ($domain)`n`n"

        foreach ($doc in $domainDocs | Sort-Object { $_.id }) {
            $brief += "### $($doc.title)`n`n"
            $brief += "**ID:** $($doc.id) | **File:** ``$($doc.path)```n`n"
            $brief += "$($doc.summary)`n`n"
        }
    }

    # Add documents without summaries section
    if ($noSummary.Count -gt 0) {
        $brief += @"

---

## Documents Pending Summary

The following documents exist but don't have summaries yet:

"@
        foreach ($doc in $noSummary | Sort-Object { $_.id }) {
            $brief += "- **$($doc.id)**: $($doc.title) (``$($doc.path)``)`n"
        }
    }

    # Add footer
    $brief += @"

---

*Generated by mlda-brief.ps1*
"@

    if ($Format -eq "console") {
        Write-Host $brief
    }
    else {
        Set-Content $Output -Value $brief
        Write-Host "`nWritten: $Output" -ForegroundColor Green
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host ""
