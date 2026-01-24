<#
.SYNOPSIS
    Regenerates the MLDA document registry from .meta.yaml files.

.DESCRIPTION
    Scans all .meta.yaml sidecar files in .mlda/docs/ and rebuilds
    registry.yaml with current document index. Computes reverse
    relationships (referenced_by) for bidirectional graph traversal.
    Adds graph metadata and connectivity statistics.

.PARAMETER Verify
    Check registry against actual files without modifying (dry run)

.PARAMETER Stats
    Show statistics only, don't regenerate

.PARAMETER Graph
    Show graph connectivity analysis

.EXAMPLE
    .\mlda-registry.ps1           # Regenerate registry
    .\mlda-registry.ps1 -Verify   # Check without modifying
    .\mlda-registry.ps1 -Stats    # Show stats only
    .\mlda-registry.ps1 -Graph    # Show graph analysis
#>

param(
    [switch]$Verify,
    [switch]$Stats,
    [switch]$Graph
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$DocsDir = Join-Path $MldaRoot "docs"
$RegistryFile = Join-Path $MldaRoot "registry.yaml"

# Simple YAML parser for meta files (handles our specific format)
# Updated for sidecar v2 with Neocortex fields
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
        related = @()
        summary = ""
        # v2 fields
        domain = ""
        has_critical_markers = $false
        has_predictions = $false
        reference_layer = ""
        reference_stability = ""
        reference_scope = ""
        boundaries_related = @()
        boundaries_isolated = @()
        is_v2 = $false
    }

    $content = Get-Content $Path -ErrorAction SilentlyContinue
    if (-not $content) { return $null }

    $inTags = $false
    $inCreated = $false
    $inRelated = $false
    $inRelatedItem = $false
    $inReferenceFrames = $false
    $inBoundaries = $false
    $inBoundariesRelated = $false
    $inBoundariesIsolated = $false
    $inPredictions = $false
    $currentRelated = @{}

    foreach ($line in $content) {
        # Reset section flags on non-indented lines
        if ($line -match "^\w") {
            # Save current related item if we were building one
            if ($inRelatedItem -and $currentRelated.id) {
                $meta.related += [PSCustomObject]$currentRelated
            }
            $inTags = $false
            $inCreated = $false
            $inRelated = $false
            $inRelatedItem = $false
            $inReferenceFrames = $false
            $inBoundaries = $false
            $inBoundariesRelated = $false
            $inBoundariesIsolated = $false
            $inPredictions = $false
            $currentRelated = @{}
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
        elseif ($line -match "^related:") {
            $inRelated = $true
        }
        elseif ($line -match "^summary:\s*\|?\s*$") {
            # Multi-line summary, skip for now
        }
        elseif ($line -match "^summary:\s*[`"']?([^`"']+)[`"']?") {
            $meta.summary = $Matches[1].Trim()
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
        elseif ($inRelated -and $line -match "^\s+-\s*id:\s*(.+)") {
            # Save previous related item if exists
            if ($inRelatedItem -and $currentRelated.id) {
                $meta.related += [PSCustomObject]$currentRelated
            }
            $inRelatedItem = $true
            $currentRelated = @{
                id = $Matches[1].Trim()
                type = "references"
                why = ""
            }
        }
        elseif ($inRelatedItem -and $line -match "^\s+type:\s*(.+)") {
            $currentRelated.type = $Matches[1].Trim()
        }
        elseif ($inRelatedItem -and $line -match "^\s+why:\s*[`"']?([^`"']+)[`"']?") {
            $currentRelated.why = $Matches[1].Trim()
        }
        # v2 fields parsing
        elseif ($line -match "^domain:\s*(\w+)") {
            $meta.domain = $Matches[1].Trim()
            $meta.is_v2 = $true
        }
        elseif ($line -match "^has_critical_markers:\s*(true|false)") {
            $meta.has_critical_markers = $Matches[1].Trim() -eq "true"
            $meta.is_v2 = $true
        }
        elseif ($line -match "^predictions:") {
            $inPredictions = $true
            $meta.has_predictions = $true
            $meta.is_v2 = $true
        }
        elseif ($line -match "^reference_frames:") {
            $inReferenceFrames = $true
            $meta.is_v2 = $true
        }
        elseif ($inReferenceFrames -and $line -match "^\s+layer:\s*(\w+)") {
            $meta.reference_layer = $Matches[1].Trim()
        }
        elseif ($inReferenceFrames -and $line -match "^\s+stability:\s*(\w+)") {
            $meta.reference_stability = $Matches[1].Trim()
        }
        elseif ($inReferenceFrames -and $line -match "^\s+scope:\s*([\w-]+)") {
            $meta.reference_scope = $Matches[1].Trim()
        }
        elseif ($line -match "^boundaries:") {
            $inBoundaries = $true
            $meta.is_v2 = $true
        }
        elseif ($inBoundaries -and $line -match "^\s+related_domains:") {
            $inBoundariesRelated = $true
            $inBoundariesIsolated = $false
        }
        elseif ($inBoundaries -and $line -match "^\s+isolated_from:") {
            $inBoundariesIsolated = $true
            $inBoundariesRelated = $false
        }
        elseif ($inBoundariesRelated -and $line -match "^\s+-\s*(.+)") {
            $meta.boundaries_related += $Matches[1].Trim()
        }
        elseif ($inBoundariesIsolated -and $line -match "^\s+-\s*(.+)") {
            $meta.boundaries_isolated += $Matches[1].Trim()
        }
    }

    # Don't forget last related item
    if ($inRelatedItem -and $currentRelated.id) {
        $meta.related += [PSCustomObject]$currentRelated
    }

    return $meta
}

# Extract domains from current registry
function Get-CurrentDomains {
    if (-not (Test-Path $RegistryFile)) {
        return @("AUTH", "UM", "API", "UI", "DATA", "CORE")
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
            Related = $meta.related
            Summary = $meta.summary
            MdExists = $mdExists
            MetaPath = $metaFile.FullName
            ReferencedBy = @()  # Will be computed
            # v2 fields
            Domain = $meta.domain
            HasCriticalMarkers = $meta.has_critical_markers
            HasPredictions = $meta.has_predictions
            ReferenceLayer = $meta.reference_layer
            ReferenceStability = $meta.reference_stability
            ReferenceScope = $meta.reference_scope
            BoundariesRelated = $meta.boundaries_related
            BoundariesIsolated = $meta.boundaries_isolated
            IsV2 = $meta.is_v2
        }
    }
}

# Compute reverse relationships (referenced_by)
Write-Host "`nComputing reverse relationships..." -ForegroundColor Yellow
$docIndex = @{}
foreach ($doc in $documents) {
    $docIndex[$doc.Id] = $doc
}

foreach ($doc in $documents) {
    foreach ($rel in $doc.Related) {
        $targetId = $rel.id
        if ($docIndex.ContainsKey($targetId)) {
            $reverseRel = [PSCustomObject]@{
                id = $doc.Id
                type = switch ($rel.type) {
                    "depends-on" { "depended-by" }
                    "extends" { "extended-by" }
                    "supersedes" { "superseded-by" }
                    default { "referenced-by" }
                }
                why = $rel.why
            }
            $docIndex[$targetId].ReferencedBy += $reverseRel
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
    WithRelationships = ($documents | Where-Object { $_.Related.Count -gt 0 }).Count
    TotalRelationships = ($documents | ForEach-Object { $_.Related.Count } | Measure-Object -Sum).Sum
    ByDomain = @{}
    ByRelationType = @{}
    # v2 stats
    V2Sidecars = ($documents | Where-Object { $_.IsV2 }).Count
    V1Sidecars = ($documents | Where-Object { -not $_.IsV2 }).Count
    WithCriticalMarkers = ($documents | Where-Object { $_.HasCriticalMarkers }).Count
    WithPredictions = ($documents | Where-Object { $_.HasPredictions }).Count
    ByLayer = @{}
}

# Count by domain
foreach ($doc in $documents) {
    if ($doc.Id -match "^(?:DOC-)?(\w+)-\d+") {
        $domain = $Matches[1]
        if (-not $docStats.ByDomain[$domain]) {
            $docStats.ByDomain[$domain] = 0
        }
        $docStats.ByDomain[$domain]++
    }
}

# Count relationship types
foreach ($doc in $documents) {
    foreach ($rel in $doc.Related) {
        $type = if ($rel.type) { $rel.type } else { "references" }
        if (-not $docStats.ByRelationType[$type]) {
            $docStats.ByRelationType[$type] = 0
        }
        $docStats.ByRelationType[$type]++
    }
}

# Count by reference layer (v2)
foreach ($doc in $documents) {
    if ($doc.ReferenceLayer) {
        if (-not $docStats.ByLayer[$doc.ReferenceLayer]) {
            $docStats.ByLayer[$doc.ReferenceLayer] = 0
        }
        $docStats.ByLayer[$doc.ReferenceLayer]++
    }
}

# Find high-connectivity nodes (hubs)
$hubThreshold = 3
$hubs = $documents | Where-Object {
    ($_.Related.Count + $_.ReferencedBy.Count) -ge $hubThreshold
} | Sort-Object { $_.Related.Count + $_.ReferencedBy.Count } -Descending

# Display statistics
Write-Host "`n--- Statistics ---" -ForegroundColor Yellow
Write-Host "Total documents:      $($docStats.Total)"
Write-Host "  Active:             $($docStats.Active)"
Write-Host "  Deprecated:         $($docStats.Deprecated)"
Write-Host "  With Beads:         $($docStats.WithBeads)"
Write-Host "  With Relationships: $($docStats.WithRelationships)"

if ($docStats.MissingMd -gt 0) {
    Write-Host "  Missing .md:        $($docStats.MissingMd)" -ForegroundColor Red
}

Write-Host "`nNeocortex v2 Status:"
Write-Host "  v2 sidecars:        $($docStats.V2Sidecars)" -ForegroundColor $(if ($docStats.V2Sidecars -gt 0) { "Green" } else { "Gray" })
Write-Host "  v1 sidecars:        $($docStats.V1Sidecars)" -ForegroundColor $(if ($docStats.V1Sidecars -gt 0) { "Yellow" } else { "Gray" })
Write-Host "  With predictions:   $($docStats.WithPredictions)"
Write-Host "  Critical markers:   $($docStats.WithCriticalMarkers)"

if ($docStats.ByLayer.Count -gt 0) {
    Write-Host "`nBy Reference Layer:"
    foreach ($layer in $docStats.ByLayer.Keys | Sort-Object) {
        Write-Host "  ${layer}: $($docStats.ByLayer[$layer])"
    }
}

Write-Host "`nRelationships:        $($docStats.TotalRelationships) total"
if ($docStats.ByRelationType.Count -gt 0) {
    foreach ($type in $docStats.ByRelationType.Keys | Sort-Object) {
        Write-Host "  ${type}: $($docStats.ByRelationType[$type])"
    }
}

if ($docStats.ByDomain.Count -gt 0) {
    Write-Host "`nBy Domain:"
    foreach ($domain in $docStats.ByDomain.Keys | Sort-Object) {
        Write-Host "  ${domain}: $($docStats.ByDomain[$domain])"
    }
}

if ($hubs.Count -gt 0) {
    Write-Host "`nHigh-Connectivity Nodes (hubs):" -ForegroundColor Cyan
    foreach ($hub in $hubs | Select-Object -First 5) {
        $totalConn = $hub.Related.Count + $hub.ReferencedBy.Count
        Write-Host "  $($hub.Id): $totalConn connections ($($hub.Related.Count) out, $($hub.ReferencedBy.Count) in)"
    }
}

if ($errors.Count -gt 0) {
    Write-Host "`n--- Errors ---" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  $err"
    }
}

# Graph mode - detailed connectivity analysis
if ($Graph) {
    Write-Host "`n--- Graph Analysis ---" -ForegroundColor Yellow

    # Find orphan nodes (no connections)
    $orphans = $documents | Where-Object {
        $_.Related.Count -eq 0 -and $_.ReferencedBy.Count -eq 0
    }

    if ($orphans.Count -gt 0) {
        Write-Host "`nOrphan Nodes (no connections):" -ForegroundColor Red
        foreach ($orphan in $orphans) {
            Write-Host "  $($orphan.Id): $($orphan.Title)"
        }
    }

    # Show all connections for each document
    Write-Host "`nDocument Connections:"
    foreach ($doc in $documents | Sort-Object Id) {
        $totalConn = $doc.Related.Count + $doc.ReferencedBy.Count
        if ($totalConn -gt 0) {
            Write-Host "`n  $($doc.Id) ($totalConn connections):" -ForegroundColor Cyan
            foreach ($rel in $doc.Related) {
                Write-Host "    -> $($rel.id) [$($rel.type)]"
            }
            foreach ($ref in $doc.ReferencedBy) {
                Write-Host "    <- $($ref.id) [$($ref.type)]"
            }
        }
    }

    Write-Host ""
    exit 0
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

    # Check for broken relationships
    foreach ($doc in $documents) {
        foreach ($rel in $doc.Related) {
            if (-not $docIndex.ContainsKey($rel.id)) {
                $issues += "Broken relationship in $($doc.Id): references non-existent $($rel.id)"
            }
        }
    }

    # Check for orphan nodes (warning, not error)
    $orphans = $documents | Where-Object {
        $_.Related.Count -eq 0 -and $_.ReferencedBy.Count -eq 0
    }
    if ($orphans.Count -gt 0) {
        Write-Host "`nWarning: $($orphans.Count) orphan node(s) with no connections" -ForegroundColor Yellow
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
#
# Neocortex Model: Documents are neurons, relationships are dendrites
# Use this registry for graph navigation and reverse lookups

last_updated: $date

# Graph Statistics
graph:
  total_documents: $($docStats.Total)
  total_relationships: $($docStats.TotalRelationships)
  documents_with_relationships: $($docStats.WithRelationships)
  orphan_documents: $($documents | Where-Object { $_.Related.Count -eq 0 -and $_.ReferencedBy.Count -eq 0 } | Measure-Object).Count

# Neocortex v2 Statistics
neocortex:
  v2_sidecars: $($docStats.V2Sidecars)
  v1_sidecars: $($docStats.V1Sidecars)
  with_predictions: $($docStats.WithPredictions)
  with_critical_markers: $($docStats.WithCriticalMarkers)

# Relationship type counts
relationship_types:
"@

foreach ($type in $docStats.ByRelationType.Keys | Sort-Object) {
    $registryContent += "`n  $type`: $($docStats.ByRelationType[$type])"
}

if ($docStats.ByRelationType.Count -eq 0) {
    $registryContent += "`n  # No relationships defined yet"
}

$registryContent += @"

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

# High-connectivity nodes (hubs) - good entry points for navigation
hubs:
"@

if ($hubs.Count -gt 0) {
    foreach ($hub in $hubs | Select-Object -First 10) {
        $totalConn = $hub.Related.Count + $hub.ReferencedBy.Count
        $registryContent += "`n  - id: $($hub.Id)"
        $registryContent += "`n    connections: $totalConn"
        $registryContent += "`n    outgoing: $($hub.Related.Count)"
        $registryContent += "`n    incoming: $($hub.ReferencedBy.Count)"
    }
}
else {
    $registryContent += "`n  # No hub documents yet (need 3+ connections)"
}

$registryContent += @"

# Document index with relationships
# Total: $($docStats.Total) | Active: $($docStats.Active) | Deprecated: $($docStats.Deprecated)
documents:
"@

if ($documents.Count -eq 0) {
    $registryContent += " []"
}
else {
    # Sort by domain then ID number
    $sorted = $documents | Sort-Object {
        if ($_.Id -match "^(?:DOC-)?(\w+)-(\d+)") {
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

        if ($doc.Tags.Count -gt 0) {
            $registryContent += "`n    tags: [$($doc.Tags -join ', ')]"
        }

        if ($doc.Beads) {
            $registryContent += "`n    beads: `"$($doc.Beads)`""
        }

        # v2 fields
        if ($doc.Domain) {
            $registryContent += "`n    domain: $($doc.Domain)"
        }
        if ($doc.ReferenceLayer) {
            $registryContent += "`n    layer: $($doc.ReferenceLayer)"
        }
        if ($doc.HasCriticalMarkers) {
            $registryContent += "`n    has_critical_markers: true"
        }
        if ($doc.HasPredictions) {
            $registryContent += "`n    has_predictions: true"
        }

        # Forward relationships (relates_to)
        if ($doc.Related.Count -gt 0) {
            $registryContent += "`n    relates_to:"
            foreach ($rel in $doc.Related) {
                $registryContent += "`n      - id: $($rel.id)"
                $registryContent += "`n        type: $($rel.type)"
            }
        }

        # Reverse relationships (referenced_by) - computed
        if ($doc.ReferencedBy.Count -gt 0) {
            $registryContent += "`n    referenced_by:"
            foreach ($ref in $doc.ReferencedBy) {
                $registryContent += "`n      - id: $($ref.id)"
                $registryContent += "`n        type: $($ref.type)"
            }
        }
    }
}

$registryContent += "`n"

# Write registry
Set-Content $RegistryFile -Value $registryContent -NoNewline
Write-Host "Written: registry.yaml" -ForegroundColor Green

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

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host ""
