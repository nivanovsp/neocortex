<#
.SYNOPSIS
    Regenerates the MLDA document registry from .meta.yaml files.

.DESCRIPTION
    Scans all .meta.yaml sidecar files in .mlda/docs/ and rebuilds
    registry.yaml with current document index. Preserves domain
    configuration and adds health statistics.

.PARAMETER Verify
    Check registry against actual files without modifying (dry run)

.PARAMETER Stats
    Show statistics only, don't regenerate

.EXAMPLE
    .\mlda-registry.ps1           # Regenerate registry
    .\mlda-registry.ps1 -Verify   # Check without modifying
    .\mlda-registry.ps1 -Stats    # Show stats only
#>

param(
    [switch]$Verify,
    [switch]$Stats
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Simple YAML parser for meta files (handles our specific format)
function Read-MetaYaml {
    param([string]$Path)

    $meta = @{
        id = ""
        title = ""
        status = "active"
        tags = @()
        beads = ""
        created_date = ""
        created_by = ""
    }

    $content = Get-Content $Path -ErrorAction SilentlyContinue
    if (-not $content) { return $null }

    $inTags = $false
    $inCreated = $false

    foreach ($line in $content) {
        # Reset section flags on non-indented lines
        if ($line -match "^\w") {
            $inTags = $false
            $inCreated = $false
        }

        if ($line -match "^id:\s*(.+)") {
            $meta.id = $Matches[1].Trim()
        }
        elseif ($line -match "^title:\s*[`"']?([^`"']+)[`"']?") {
            $meta.title = $Matches[1].Trim()
        }
        elseif ($line -match "^status:\s*(\w+)") {
            $meta.status = $Matches[1].Trim()
        }
        elseif ($line -match "^beads:\s*[`"']?([^`"']+)[`"']?") {
            $meta.beads = $Matches[1].Trim()
        }
        elseif ($line -match "^tags:") {
            $inTags = $true
        }
        elseif ($line -match "^created:") {
            $inCreated = $true
        }
        elseif ($inTags -and $line -match "^\s+-\s*(.+)") {
            $meta.tags += $Matches[1].Trim()
        }
        elseif ($inCreated -and $line -match "^\s+date:\s*[`"']?([^`"']+)[`"']?") {
            $meta.created_date = $Matches[1].Trim()
        }
        elseif ($inCreated -and $line -match "^\s+by:\s*[`"']?([^`"']+)[`"']?") {
            $meta.created_by = $Matches[1].Trim()
        }
    }

    return $meta
}

# Extract domains from current registry
function Get-CurrentDomains {
    if (-not (Test-Path $RegistryFile)) {
        return @("AUTH", "UM", "API", "UI", "DATA")
    }

    $domains = @()
    $inDomains = $false
    $content = Get-Content $RegistryFile

    foreach ($line in $content) {
        if ($line -match "^domains:") {
            $inDomains = $true
            continue
        }
        if ($inDomains) {
            if ($line -match "^\s+-\s*(\w+)") {
                $domains += $Matches[1].Trim()
            }
            elseif ($line -match "^\w" -and $line -notmatch "^\s*#") {
                break
            }
        }
    }

    return $domains
}

# Main execution
Write-Host "`n=== MLDA Registry ===" -ForegroundColor Cyan

# Check if docs directory exists
if (-not (Test-Path $DocsDir)) {
    Write-Host "No docs directory found at: $DocsDir" -ForegroundColor Yellow
    Write-Host "Creating empty registry."
    $documents = @()
}
else {
    # Find all .meta.yaml files
    $metaFiles = Get-ChildItem -Path $DocsDir -Filter "*.meta.yaml" -Recurse -ErrorAction SilentlyContinue

    Write-Host "Scanning: $DocsDir"
    Write-Host "Found:    $($metaFiles.Count) meta files"

    # Parse each meta file
    $documents = @()
    $errors = @()

    foreach ($metaFile in $metaFiles) {
        $meta = Read-MetaYaml $metaFile.FullName

        if (-not $meta -or -not $meta.id) {
            $errors += "Invalid meta file: $($metaFile.FullName)"
            continue
        }

        # Calculate relative path to the .md file
        $mdFile = $metaFile.FullName -replace "\.meta\.yaml$", ".md"
        $relativePath = $mdFile.Substring($MldaRoot.Length + 1) -replace "\\", "/"

        # Check if .md file exists
        $mdExists = Test-Path $mdFile

        $documents += [PSCustomObject]@{
            Id = $meta.id
            Title = $meta.title
            Path = $relativePath
            Status = $meta.status
            Tags = $meta.tags
            Beads = $meta.beads
            CreatedDate = $meta.created_date
            CreatedBy = $meta.created_by
            MdExists = $mdExists
            MetaPath = $metaFile.FullName
        }
    }
}

# Calculate statistics
$docStats = @{
    Total = $documents.Count
    Active = ($documents | Where-Object { $_.Status -eq "active" }).Count
    Deprecated = ($documents | Where-Object { $_.Status -eq "deprecated" }).Count
    WithBeads = ($documents | Where-Object { $_.Beads }).Count
    MissingMd = ($documents | Where-Object { -not $_.MdExists }).Count
    ByDomain = @{}
}

foreach ($doc in $documents) {
    if ($doc.Id -match "DOC-(\w+)-\d+") {
        $domain = $Matches[1]
        if (-not $docStats.ByDomain[$domain]) {
            $docStats.ByDomain[$domain] = 0
        }
        $docStats.ByDomain[$domain]++
    }
}

# Display statistics
Write-Host "`n--- Statistics ---" -ForegroundColor Yellow
Write-Host "Total documents:  $($docStats.Total)"
Write-Host "  Active:         $($docStats.Active)"
Write-Host "  Deprecated:     $($docStats.Deprecated)"
Write-Host "  With Beads:     $($docStats.WithBeads)"

if ($docStats.MissingMd -gt 0) {
    Write-Host "  Missing .md:    $($docStats.MissingMd)" -ForegroundColor Red
}

if ($docStats.ByDomain.Count -gt 0) {
    Write-Host "`nBy Domain:"
    foreach ($domain in $docStats.ByDomain.Keys | Sort-Object) {
        Write-Host "  ${domain}: $($docStats.ByDomain[$domain])"
    }
}

if ($errors.Count -gt 0) {
    Write-Host "`n--- Errors ---" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  $err"
    }
}

# Stats only mode - exit here
if ($Stats) {
    Write-Host ""
    exit 0
}

# Verify mode - check for issues
if ($Verify) {
    Write-Host "`n--- Verification ---" -ForegroundColor Yellow

    $issues = @()

    # Check for missing .md files
    foreach ($doc in $documents | Where-Object { -not $_.MdExists }) {
        $issues += "Missing .md file for $($doc.Id): $($doc.Path)"
    }

    # Check for orphan .md files (no meta)
    $mdFiles = Get-ChildItem -Path $DocsDir -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
    foreach ($mdFile in $mdFiles) {
        $metaPath = $mdFile.FullName -replace "\.md$", ".meta.yaml"
        if (-not (Test-Path $metaPath)) {
            $relativePath = $mdFile.FullName.Substring($MldaRoot.Length + 1) -replace "\\", "/"
            $issues += "Orphan .md file (no meta): $relativePath"
        }
    }

    # Check for duplicate IDs
    $idCounts = $documents | Group-Object -Property Id | Where-Object { $_.Count -gt 1 }
    foreach ($dup in $idCounts) {
        $issues += "Duplicate DOC-ID: $($dup.Name) (found $($dup.Count) times)"
    }

    if ($issues.Count -eq 0) {
        Write-Host "No issues found." -ForegroundColor Green
    }
    else {
        Write-Host "Found $($issues.Count) issue(s):" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "  - $issue"
        }
    }

    Write-Host ""
    exit 0
}

# Regenerate registry
Write-Host "`n--- Regenerating Registry ---" -ForegroundColor Yellow

$currentDomains = Get-CurrentDomains
$date = Get-Date -Format "yyyy-MM-dd"

# Build registry content
$registryContent = @"
# MLDA Document Registry
# Auto-generated by mlda-registry.ps1
# Last regenerated: $date

last_updated: $date

# Domain codes used in this project
domains:
"@

foreach ($domain in $currentDomains) {
    $registryContent += "`n  - $domain"
}

# Add any new domains discovered
foreach ($domain in $docStats.ByDomain.Keys | Sort-Object) {
    if ($domain -notin $currentDomains) {
        $registryContent += "`n  - $domain    # Auto-discovered"
    }
}

$registryContent += @"

# Document index (auto-generated)
# Total: $($docStats.Total) | Active: $($docStats.Active) | Deprecated: $($docStats.Deprecated)
documents:
"@

if ($documents.Count -eq 0) {
    $registryContent += " []"
}
else {
    # Sort by domain then ID number
    $sorted = $documents | Sort-Object {
        if ($_.Id -match "DOC-(\w+)-(\d+)") {
            "{0}-{1:D5}" -f $Matches[1], [int]$Matches[2]
        } else {
            $_.Id
        }
    }

    foreach ($doc in $sorted) {
        $registryContent += "`n  - id: $($doc.Id)"
        $registryContent += "`n    title: `"$($doc.Title)`""
        $registryContent += "`n    path: $($doc.Path)"
        $registryContent += "`n    status: $($doc.Status)"
        if ($doc.Beads) {
            $registryContent += "`n    beads: `"$($doc.Beads)`""
        }
    }
}

$registryContent += "`n"

# Write registry
Set-Content $RegistryFile -Value $registryContent -NoNewline
Write-Host "Written: registry.yaml" -ForegroundColor Green

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host ""
