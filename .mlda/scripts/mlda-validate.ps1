<#
.SYNOPSIS
    Validates links and DOC-ID references in MLDA documents.

.DESCRIPTION
    Scans all markdown files in .mlda/docs/ and validates:
    1. DOC-ID references (DOC-{DOMAIN}-{NNN}) exist in registry
    2. Markdown links to local files exist on disk
    3. Related document links in .meta.yaml are valid
    4. Consistency between registry and actual files

.PARAMETER Fix
    Attempt to auto-fix issues where possible (e.g., remove dead links from meta)

.PARAMETER Verbose
    Show detailed output including all checked links

.EXAMPLE
    .\mlda-validate.ps1              # Validate all links
    .\mlda-validate.ps1 -Verbose     # Show detailed output
    .\mlda-validate.ps1 -Fix         # Attempt to fix issues
#>

param(
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Statistics
$stats = @{
    FilesScanned = 0
    DocIdRefsFound = 0
    FileLinksFound = 0
    MetaLinksFound = 0
    BrokenDocIds = 0
    BrokenFileLinks = 0
    BrokenMetaLinks = 0
    OrphanDocs = 0
    MissingMeta = 0
    FixedIssues = 0
    # v2 stats
    V2Sidecars = 0
    V1Sidecars = 0
    PredictionRefs = 0
    BrokenPredictionRefs = 0
}

$issues = @()

# Load registry into hashtable for fast lookup
function Load-Registry {
    $registry = @{
        DocIds = @{}
        Paths = @{}
    }

    if (-not (Test-Path $RegistryFile)) {
        Write-Host "Warning: Registry file not found at $RegistryFile" -ForegroundColor Yellow
        return $registry
    }

    $content = Get-Content $RegistryFile -Raw
    $inDocuments = $false
    $currentDoc = @{}

    foreach ($line in (Get-Content $RegistryFile)) {
        if ($line -match "^documents:") {
            $inDocuments = $true
            continue
        }

        if ($inDocuments) {
            if ($line -match "^\s+-\s*id:\s*(.+)") {
                # Save previous doc if exists
                if ($currentDoc.id) {
                    $registry.DocIds[$currentDoc.id] = $currentDoc
                    if ($currentDoc.path) {
                        $registry.Paths[$currentDoc.path] = $currentDoc.id
                    }
                }
                $currentDoc = @{ id = $Matches[1].Trim() }
            }
            elseif ($line -match "^\s+title:\s*[`"']?([^`"']+)[`"']?") {
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

    # Save last doc
    if ($currentDoc.id) {
        $registry.DocIds[$currentDoc.id] = $currentDoc
        if ($currentDoc.path) {
            $registry.Paths[$currentDoc.path] = $currentDoc.id
        }
    }

    return $registry
}

# Find code block regions (fenced ``` and inline `) to exclude from validation
function Find-CodeBlockRegions {
    param([string]$Content)

    $regions = @()

    # Find fenced code blocks (```...```)
    $fencedPattern = '(?s)```[^\n]*\n.*?```'
    $fencedMatches = [regex]::Matches($Content, $fencedPattern)
    foreach ($match in $fencedMatches) {
        $regions += [PSCustomObject]@{
            Start = $match.Index
            End = $match.Index + $match.Length
        }
    }

    # Find inline code blocks (`...`) - simple approach using character scan
    # PowerShell backticks are tricky in regex, so we scan manually
    $inBacktick = $false
    $btStart = 0
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $char = $Content[$i]
        if ($char -eq [char]96) {  # 96 is ASCII for backtick
            if (-not $inBacktick) {
                $inBacktick = $true
                $btStart = $i
            } else {
                # Check we're not inside a fenced block
                $inFenced = $false
                foreach ($region in $regions) {
                    if ($btStart -ge $region.Start -and $btStart -lt $region.End) {
                        $inFenced = $true
                        break
                    }
                }
                if (-not $inFenced) {
                    $regions += [PSCustomObject]@{
                        Start = $btStart
                        End = $i + 1
                    }
                }
                $inBacktick = $false
            }
        }
        # Reset on newline (inline code doesn't span lines)
        if ($char -eq "`n") {
            $inBacktick = $false
        }
    }

    return $regions
}

# Check if a position is inside any code block region
function Test-InsideCodeBlock {
    param([int]$Position, [array]$CodeRegions)

    foreach ($region in $CodeRegions) {
        if ($Position -ge $region.Start -and $Position -lt $region.End) {
            return $true
        }
    }
    return $false
}

# Extract DOC-ID references from markdown content (excluding code blocks)
function Find-DocIdRefs {
    param([string]$Content, [string]$FilePath)

    $refs = @()
    $pattern = "DOC-[A-Z]+-\d{3}"

    # Find code block regions to exclude
    $codeRegions = Find-CodeBlockRegions -Content $Content

    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
        # Skip DOC-IDs inside code blocks (these are examples, not real references)
        if (Test-InsideCodeBlock -Position $match.Index -CodeRegions $codeRegions) {
            continue
        }

        $refs += [PSCustomObject]@{
            DocId = $match.Value
            File = $FilePath
            Position = $match.Index
        }
    }

    return $refs
}

# Extract markdown file links from content
function Find-FileLinks {
    param([string]$Content, [string]$FilePath, [string]$FileDir)

    $links = @()
    # Match markdown links: [text](path) - but not external URLs
    $pattern = '\[([^\]]+)\]\(([^)]+)\)'

    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
        $linkPath = $match.Groups[2].Value

        # Skip external URLs and anchors
        if ($linkPath -match "^https?://" -or $linkPath -match "^#" -or $linkPath -match "^mailto:") {
            continue
        }

        # Remove anchor from path
        $cleanPath = $linkPath -replace "#.*$", ""

        if ($cleanPath) {
            $links += [PSCustomObject]@{
                Text = $match.Groups[1].Value
                Path = $cleanPath
                FullMatch = $match.Value
                File = $FilePath
                FileDir = $FileDir
            }
        }
    }

    return $links
}

# Parse related links from .meta.yaml
function Find-MetaLinks {
    param([string]$MetaPath)

    $links = @()

    if (-not (Test-Path $MetaPath)) {
        return $links
    }

    $content = Get-Content $MetaPath
    $inRelated = $false

    foreach ($line in $content) {
        if ($line -match "^related:") {
            $inRelated = $true
            continue
        }
        if ($inRelated) {
            if ($line -match "^\s+-\s*(.+)") {
                $relatedId = $Matches[1].Trim() -replace "[`"']", ""
                if ($relatedId -and $relatedId -ne "[]") {
                    $links += $relatedId
                }
            }
            elseif ($line -match "^\w" -and $line -notmatch "^\s*#") {
                break
            }
        }
    }

    return $links
}

# Check sidecar for v2 fields and extract prediction DOC-IDs
function Get-MetaV2Info {
    param([string]$MetaPath)

    $info = @{
        IsV2 = $false
        PredictionRefs = @()
        HasPredictions = $false
        HasReferenceFrames = $false
        HasBoundaries = $false
        HasCriticalMarkers = $false
    }

    if (-not (Test-Path $MetaPath)) {
        return $info
    }

    $content = Get-Content $MetaPath -Raw

    # Check for v2 indicators
    if ($content -match "^reference_frames:" -or $content -match "`nreference_frames:") {
        $info.IsV2 = $true
        $info.HasReferenceFrames = $true
    }
    if ($content -match "^predictions:" -or $content -match "`npredictions:") {
        $info.IsV2 = $true
        $info.HasPredictions = $true
    }
    if ($content -match "^boundaries:" -or $content -match "`nboundaries:") {
        $info.IsV2 = $true
        $info.HasBoundaries = $true
    }
    if ($content -match "^domain:\s*\w+" -or $content -match "`ndomain:\s*\w+") {
        $info.IsV2 = $true
    }
    if ($content -match "has_critical_markers:\s*true") {
        $info.HasCriticalMarkers = $true
    }

    # Extract DOC-IDs from predictions
    if ($info.HasPredictions) {
        $docIdPattern = "DOC-[A-Z]+-\d{3}"
        $inPredictions = $false

        foreach ($line in (Get-Content $MetaPath)) {
            if ($line -match "^predictions:") {
                $inPredictions = $true
                continue
            }
            if ($inPredictions) {
                if ($line -match "^\w" -and $line -notmatch "^\s") {
                    break
                }
                $matches = [regex]::Matches($line, $docIdPattern)
                foreach ($match in $matches) {
                    if ($match.Value -notin $info.PredictionRefs) {
                        $info.PredictionRefs += $match.Value
                    }
                }
            }
        }
    }

    return $info
}

# Main execution
Write-Host "`n=== MLDA Link Validator ===" -ForegroundColor Cyan

# Load registry
Write-Host "`nLoading registry..." -ForegroundColor Yellow
$registry = Load-Registry
Write-Host "Found $($registry.DocIds.Count) registered documents"

# Check if docs directory exists
if (-not (Test-Path $DocsDir)) {
    Write-Host "`nNo docs directory found. Nothing to validate." -ForegroundColor Yellow
    exit 0
}

# Get all markdown files
$mdFiles = Get-ChildItem -Path $DocsDir -Filter "*.md" -Recurse -ErrorAction SilentlyContinue

Write-Host "`nScanning $($mdFiles.Count) markdown file(s)..." -ForegroundColor Yellow

foreach ($mdFile in $mdFiles) {
    $stats.FilesScanned++
    $relativePath = $mdFile.FullName.Substring($MldaRoot.Length + 1) -replace "\\", "/"
    $fileDir = Split-Path -Parent $mdFile.FullName

    if ($Verbose) {
        Write-Host "`n  Checking: $relativePath" -ForegroundColor Gray
    }

    $content = Get-Content $mdFile.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    # Check DOC-ID references
    $docIdRefs = Find-DocIdRefs -Content $content -FilePath $relativePath
    $stats.DocIdRefsFound += $docIdRefs.Count

    foreach ($ref in $docIdRefs) {
        if (-not $registry.DocIds.ContainsKey($ref.DocId)) {
            # Check if it's the document's own ID (in frontmatter)
            $ownIdPattern = "^\*\*DOC-ID:\*\*\s*$($ref.DocId)"
            if ($content -notmatch $ownIdPattern) {
                $stats.BrokenDocIds++
                $issues += [PSCustomObject]@{
                    Type = "BrokenDocId"
                    Severity = "Error"
                    File = $ref.File
                    Detail = "Reference to unknown DOC-ID: $($ref.DocId)"
                }
            }
        }
        elseif ($Verbose) {
            Write-Host "    [OK] DOC-ID: $($ref.DocId)" -ForegroundColor DarkGreen
        }
    }

    # Check file links
    $fileLinks = Find-FileLinks -Content $content -FilePath $relativePath -FileDir $fileDir
    $stats.FileLinksFound += $fileLinks.Count

    foreach ($link in $fileLinks) {
        # Resolve relative path
        $targetPath = if ([System.IO.Path]::IsPathRooted($link.Path)) {
            $link.Path
        } else {
            Join-Path $link.FileDir $link.Path
        }

        # Normalize path
        try {
            $normalizedPath = [System.IO.Path]::GetFullPath($targetPath)
        } catch {
            $normalizedPath = $targetPath
        }

        if (-not (Test-Path $normalizedPath)) {
            $stats.BrokenFileLinks++
            $issues += [PSCustomObject]@{
                Type = "BrokenFileLink"
                Severity = "Error"
                File = $link.File
                Detail = "Broken link: [$($link.Text)]($($link.Path))"
            }
        }
        elseif ($Verbose) {
            Write-Host "    [OK] Link: $($link.Path)" -ForegroundColor DarkGreen
        }
    }

    # Check corresponding .meta.yaml
    $metaPath = $mdFile.FullName -replace "\.md$", ".meta.yaml"
    if (-not (Test-Path $metaPath)) {
        $stats.MissingMeta++
        $issues += [PSCustomObject]@{
            Type = "MissingMeta"
            Severity = "Warning"
            File = $relativePath
            Detail = "No .meta.yaml sidecar file found"
        }
    }
    else {
        # Check related links in meta
        $metaLinks = Find-MetaLinks -MetaPath $metaPath
        $stats.MetaLinksFound += $metaLinks.Count

        foreach ($relatedId in $metaLinks) {
            if ($relatedId -match "^DOC-") {
                if (-not $registry.DocIds.ContainsKey($relatedId)) {
                    $stats.BrokenMetaLinks++
                    $issues += [PSCustomObject]@{
                        Type = "BrokenMetaLink"
                        Severity = "Error"
                        File = $relativePath
                        Detail = "Meta related: references unknown DOC-ID: $relatedId"
                    }
                }
                elseif ($Verbose) {
                    Write-Host "    [OK] Meta related: $relatedId" -ForegroundColor DarkGreen
                }
            }
        }

        # Check v2 fields
        $v2Info = Get-MetaV2Info -MetaPath $metaPath

        if ($v2Info.IsV2) {
            $stats.V2Sidecars++
        } else {
            $stats.V1Sidecars++
        }

        # Validate prediction DOC-ID references
        if ($v2Info.PredictionRefs.Count -gt 0) {
            $stats.PredictionRefs += $v2Info.PredictionRefs.Count

            foreach ($predRef in $v2Info.PredictionRefs) {
                if (-not $registry.DocIds.ContainsKey($predRef)) {
                    $stats.BrokenPredictionRefs++
                    $issues += [PSCustomObject]@{
                        Type = "BrokenPrediction"
                        Severity = "Warning"
                        File = $relativePath
                        Detail = "Prediction references unknown DOC-ID: $predRef"
                    }
                }
                elseif ($Verbose) {
                    Write-Host "    [OK] Prediction ref: $predRef" -ForegroundColor DarkGreen
                }
            }
        }
    }
}

# Check for orphan documents (in registry but file missing)
Write-Host "`nChecking registry consistency..." -ForegroundColor Yellow

foreach ($docId in $registry.DocIds.Keys) {
    $doc = $registry.DocIds[$docId]
    if ($doc.path) {
        $fullPath = Join-Path $MldaRoot $doc.path
        if (-not (Test-Path $fullPath)) {
            $stats.OrphanDocs++
            $issues += [PSCustomObject]@{
                Type = "OrphanRegistry"
                Severity = "Error"
                File = $doc.path
                Detail = "Registry entry $docId points to missing file"
            }
        }
    }
}

# Results
Write-Host "`n=== Validation Results ===" -ForegroundColor Cyan

Write-Host "`n--- Statistics ---" -ForegroundColor Yellow
Write-Host "Files scanned:        $($stats.FilesScanned)"
Write-Host "DOC-ID refs found:    $($stats.DocIdRefsFound)"
Write-Host "File links found:     $($stats.FileLinksFound)"
Write-Host "Meta links found:     $($stats.MetaLinksFound)"

Write-Host "`nNeocortex v2 Status:"
Write-Host "  v2 sidecars:        $($stats.V2Sidecars)" -ForegroundColor $(if ($stats.V2Sidecars -gt 0) { "Green" } else { "Gray" })
Write-Host "  v1 sidecars:        $($stats.V1Sidecars)" -ForegroundColor $(if ($stats.V1Sidecars -gt 0) { "Yellow" } else { "Gray" })
Write-Host "  Prediction refs:    $($stats.PredictionRefs)"

$hasIssues = $issues.Count -gt 0

if ($hasIssues) {
    Write-Host "`n--- Issues Found ---" -ForegroundColor Red

    # Group by type
    $grouped = $issues | Group-Object -Property Type

    foreach ($group in $grouped) {
        $color = if ($group.Group[0].Severity -eq "Error") { "Red" } else { "Yellow" }
        Write-Host "`n$($group.Name) ($($group.Count)):" -ForegroundColor $color

        foreach ($issue in $group.Group) {
            Write-Host "  - [$($issue.File)] $($issue.Detail)" -ForegroundColor $color
        }
    }

    # Summary
    Write-Host "`n--- Summary ---" -ForegroundColor Yellow
    Write-Host "Broken DOC-ID refs:   $($stats.BrokenDocIds)" -ForegroundColor $(if ($stats.BrokenDocIds -gt 0) { "Red" } else { "Green" })
    Write-Host "Broken file links:    $($stats.BrokenFileLinks)" -ForegroundColor $(if ($stats.BrokenFileLinks -gt 0) { "Red" } else { "Green" })
    Write-Host "Broken meta links:    $($stats.BrokenMetaLinks)" -ForegroundColor $(if ($stats.BrokenMetaLinks -gt 0) { "Red" } else { "Green" })
    Write-Host "Broken predictions:   $($stats.BrokenPredictionRefs)" -ForegroundColor $(if ($stats.BrokenPredictionRefs -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Missing .meta.yaml:   $($stats.MissingMeta)" -ForegroundColor $(if ($stats.MissingMeta -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Orphan registry:      $($stats.OrphanDocs)" -ForegroundColor $(if ($stats.OrphanDocs -gt 0) { "Red" } else { "Green" })

    Write-Host "`nTotal issues: $($issues.Count)" -ForegroundColor Red

    if ($Fix) {
        Write-Host "`n--- Auto-Fix ---" -ForegroundColor Yellow
        Write-Host "Auto-fix not yet implemented. Run 'mlda-registry.ps1' to rebuild registry." -ForegroundColor Gray
    }

    exit 1
}
else {
    Write-Host "`nNo issues found. All links are valid." -ForegroundColor Green
    exit 0
}
