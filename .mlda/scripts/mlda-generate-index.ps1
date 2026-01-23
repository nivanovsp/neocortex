<#
.SYNOPSIS
    Generates the learning-index.yaml from all topic learning files.

.DESCRIPTION
    Scans all .mlda/topics/{topic}/learning.yaml files and generates a
    lightweight index with summaries and key insights. This index is
    loaded during mode awakening (Tier 1) instead of full learning files.

    Related: DEC-007-two-tier-learning.md

.PARAMETER MaxInsights
    Maximum number of key insights to extract per topic (default: 5)

.PARAMETER DryRun
    Show what would be generated without writing the file

.PARAMETER Stats
    Show statistics only, don't generate index

.PARAMETER Verbose
    Show detailed progress during generation

.EXAMPLE
    .\mlda-generate-index.ps1                    # Generate index
    .\mlda-generate-index.ps1 -DryRun            # Preview without writing
    .\mlda-generate-index.ps1 -Stats             # Show stats only
    .\mlda-generate-index.ps1 -MaxInsights 3     # Limit to 3 insights per topic
#>

param(
    [int]$MaxInsights = 5,
    [switch]$DryRun,
    [switch]$Stats,
    [switch]$ShowVerbose
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$TopicsDir = Join-Path $MldaRoot "topics"
$IndexFile = Join-Path $MldaRoot "learning-index.yaml"
$TemplatesDir = Join-Path $MldaRoot "templates"

# Helper: Format file size for display
function Format-FileSize {
    param([long]$Bytes)
    if ($Bytes -ge 1MB) {
        return "{0:N1} MB" -f ($Bytes / 1MB)
    } elseif ($Bytes -ge 1KB) {
        return "{0:N0} KB" -f ($Bytes / 1KB)
    } else {
        return "$Bytes B"
    }
}

# Helper: Simple YAML value extractor (handles our specific format)
function Get-YamlValue {
    param(
        [string[]]$Content,
        [string]$Key
    )
    foreach ($line in $Content) {
        if ($line -match "^${Key}:\s*(.+)$") {
            $value = $Matches[1].Trim()
            # Remove quotes if present
            if ($value -match '^"(.+)"$' -or $value -match "^'(.+)'$") {
                return $Matches[1]
            }
            return $value
        }
    }
    return $null
}

# Helper: Extract array items from YAML (simple case)
function Get-YamlArrayItems {
    param(
        [string[]]$Content,
        [string]$SectionName,
        [int]$MaxItems = 10
    )

    $items = @()
    $inSection = $false
    $inItem = $false

    foreach ($line in $Content) {
        # Start of section
        if ($line -match "^${SectionName}:") {
            $inSection = $true
            continue
        }

        # End of section (new top-level key)
        if ($inSection -and $line -match "^\w+:" -and -not ($line -match "^\s")) {
            break
        }

        # Array item
        if ($inSection -and $line -match "^\s+-\s+(.+)$") {
            $items += $Matches[1].Trim()
            if ($items.Count -ge $MaxItems) { break }
        }
    }

    return $items
}

# Helper: Extract verification lessons
function Get-VerificationLessons {
    param(
        [string[]]$Content,
        [int]$MaxLessons = 5
    )

    $lessons = @()
    $inVerification = $false
    $currentLesson = ""

    foreach ($line in $Content) {
        # Start of verification section
        if ($line -match "^verification:") {
            $inVerification = $true
            continue
        }

        # End of section
        if ($inVerification -and $line -match "^\w+:" -and -not ($line -match "^\s")) {
            break
        }

        # Look for lesson field
        if ($inVerification -and $line -match "^\s+lesson:\s*[`"']?(.+?)[`"']?\s*$") {
            $lesson = $Matches[1].Trim()
            if ($lesson -and $lesson.Length -gt 10) {
                $lessons += $lesson
                if ($lessons.Count -ge $MaxLessons) { break }
            }
        }
    }

    return $lessons
}

# Helper: Extract primary docs from first grouping
function Get-PrimaryDocs {
    param(
        [string[]]$Content,
        [int]$MaxDocs = 5
    )

    $docs = @()
    $inGroupings = $false
    $inDocs = $false

    foreach ($line in $Content) {
        # Start of groupings section
        if ($line -match "^groupings:") {
            $inGroupings = $true
            continue
        }

        # End of groupings section
        if ($inGroupings -and $line -match "^\w+:" -and -not ($line -match "^\s")) {
            break
        }

        # Docs array in first grouping
        if ($inGroupings -and $line -match "^\s+docs:") {
            $inDocs = $true
            continue
        }

        # Doc ID
        if ($inDocs -and $line -match "^\s+-\s+(DOC-[A-Z]+-\d+)") {
            $docs += $Matches[1]
            if ($docs.Count -ge $MaxDocs) { break }
        }

        # End of docs array (new field at same level)
        if ($inDocs -and $line -match "^\s+\w+:" -and -not ($line -match "^\s+-")) {
            break
        }
    }

    return $docs
}

# Helper: Get topic summary from domain.yaml
function Get-TopicSummary {
    param([string]$TopicDir)

    $domainFile = Join-Path $TopicDir "domain.yaml"
    if (Test-Path $domainFile) {
        $content = Get-Content $domainFile
        $desc = Get-YamlValue -Content $content -Key "description"
        if ($desc) {
            # Truncate to 200 chars
            if ($desc.Length -gt 200) {
                return $desc.Substring(0, 197) + "..."
            }
            return $desc
        }

        $displayName = Get-YamlValue -Content $content -Key "display_name"
        if ($displayName) { return $displayName }
    }

    return "Topic learnings"
}

# Helper: Check if topic has content
function Test-TopicHasContent {
    param([string[]]$Content)

    $sessionCount = Get-YamlValue -Content $Content -Key "session_count"
    if ($sessionCount -and [int]$sessionCount -gt 0) { return $true }

    $sessionsContributed = Get-YamlValue -Content $Content -Key "sessions_contributed"
    if ($sessionsContributed -and [int]$sessionsContributed -gt 0) { return $true }

    # Check for non-empty groupings
    foreach ($line in $Content) {
        if ($line -match "^\s+-\s+name:") { return $true }
    }

    return $false
}

# Main: Scan topics and build index
Write-Host "`n  Learning Index Generator" -ForegroundColor Cyan
Write-Host "  ========================`n"

if (-not (Test-Path $TopicsDir)) {
    Write-Host "  No topics directory found at: $TopicsDir" -ForegroundColor Yellow
    exit 0
}

# Get all topic directories
$topicDirs = Get-ChildItem -Path $TopicsDir -Directory | Where-Object { $_.Name -notmatch "^_" }

if ($topicDirs.Count -eq 0) {
    Write-Host "  No topics found in: $TopicsDir" -ForegroundColor Yellow
    exit 0
}

Write-Host "  Found $($topicDirs.Count) topic directories`n"

# Build index data
$indexData = @{
    version = 1
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    generated_from = 0
    total_sessions = 0
    generator_script = "mlda-generate-index.ps1"
    topics = @{}
    empty_topics = @()
}

$processedCount = 0
$emptyCount = 0
$totalSize = 0

foreach ($topicDir in $topicDirs) {
    $topicName = $topicDir.Name
    $learningFile = Join-Path $topicDir.FullName "learning.yaml"

    if (-not (Test-Path $learningFile)) {
        if ($ShowVerbose) {
            Write-Host "    Skipping $topicName (no learning.yaml)" -ForegroundColor DarkGray
        }
        continue
    }

    $content = Get-Content $learningFile
    $fileInfo = Get-Item $learningFile
    $fileSize = $fileInfo.Length
    $totalSize += $fileSize

    # Check if topic has actual learnings
    $hasContent = Test-TopicHasContent -Content $content

    if (-not $hasContent) {
        $indexData.empty_topics += $topicName
        $emptyCount++
        if ($ShowVerbose) {
            Write-Host "    $topicName - empty (stub only)" -ForegroundColor DarkGray
        }
        continue
    }

    # Extract data
    $sessionCount = Get-YamlValue -Content $content -Key "session_count"
    if (-not $sessionCount) {
        $sessionCount = Get-YamlValue -Content $content -Key "sessions_contributed"
    }
    if (-not $sessionCount) { $sessionCount = 0 }
    $sessionCount = [int]$sessionCount

    $lastUpdated = Get-YamlValue -Content $content -Key "last_updated"

    $summary = Get-TopicSummary -TopicDir $topicDir.FullName
    $lessons = Get-VerificationLessons -Content $content -MaxLessons $MaxInsights
    $primaryDocs = Get-PrimaryDocs -Content $content -MaxDocs 5

    # Check for groupings/activations
    $hasGroupings = $false
    $hasActivations = $false
    foreach ($line in $content) {
        if ($line -match "^\s+-\s+name:" -and -not $hasGroupings) { $hasGroupings = $true }
        if ($line -match "^\s+-\s+docs:" -and $hasGroupings) { $hasActivations = $true; break }
    }

    # Build topic entry
    $topicEntry = @{
        summary = $summary
        sessions = $sessionCount
        size = Format-FileSize -Bytes $fileSize
        learning_path = ".mlda/topics/$topicName/learning.yaml"
        has_groupings = $hasGroupings
        has_activations = $hasActivations
    }

    if ($lastUpdated) { $topicEntry.last_updated = $lastUpdated }
    if ($lessons.Count -gt 0) { $topicEntry.key_insights = $lessons }
    if ($primaryDocs.Count -gt 0) { $topicEntry.primary_docs = $primaryDocs }

    $indexData.topics[$topicName] = $topicEntry
    $indexData.total_sessions += $sessionCount
    $processedCount++

    if ($ShowVerbose) {
        Write-Host "    $topicName - $sessionCount sessions, $(Format-FileSize $fileSize)" -ForegroundColor Green
    }
}

$indexData.generated_from = $processedCount

# Stats mode
if ($Stats) {
    Write-Host "  Statistics:" -ForegroundColor Cyan
    Write-Host "    Topics with learnings: $processedCount"
    Write-Host "    Empty topics (stubs):  $emptyCount"
    Write-Host "    Total sessions:        $($indexData.total_sessions)"
    Write-Host "    Total learning size:   $(Format-FileSize $totalSize)"
    Write-Host ""
    exit 0
}

# Generate YAML output
$yaml = @"
# MLDA Learning Index
# Auto-generated summary of all topic learnings
# Generated: $($indexData.generated_at)
# Generator: $($indexData.generator_script)
#
# This file provides Tier 1 loading for two-tier learning system (DEC-007).
# DO NOT EDIT MANUALLY - regenerate with: .\mlda-generate-index.ps1

version: $($indexData.version)
generated_at: "$($indexData.generated_at)"
generated_from: $($indexData.generated_from)
total_sessions: $($indexData.total_sessions)
generator_script: "$($indexData.generator_script)"

topics:
"@

foreach ($topic in $indexData.topics.Keys | Sort-Object) {
    $t = $indexData.topics[$topic]
    $yaml += "`n  $topic`:"
    $yaml += "`n    summary: `"$($t.summary -replace '"', '\"')`""
    $yaml += "`n    sessions: $($t.sessions)"
    $yaml += "`n    size: `"$($t.size)`""

    if ($t.key_insights -and $t.key_insights.Count -gt 0) {
        $yaml += "`n    key_insights:"
        foreach ($insight in $t.key_insights) {
            $escaped = $insight -replace '"', '\"'
            $yaml += "`n      - `"$escaped`""
        }
    }

    if ($t.primary_docs -and $t.primary_docs.Count -gt 0) {
        $yaml += "`n    primary_docs:"
        foreach ($doc in $t.primary_docs) {
            $yaml += "`n      - $doc"
        }
    }

    $yaml += "`n    learning_path: $($t.learning_path)"
    if ($t.last_updated) { $yaml += "`n    last_updated: `"$($t.last_updated)`"" }
    $yaml += "`n    has_groupings: $($t.has_groupings.ToString().ToLower())"
    $yaml += "`n    has_activations: $($t.has_activations.ToString().ToLower())"
}

if ($indexData.empty_topics.Count -gt 0) {
    $yaml += "`n`nempty_topics:"
    foreach ($empty in $indexData.empty_topics | Sort-Object) {
        $yaml += "`n  - $empty"
    }
} else {
    $yaml += "`n`nempty_topics: []"
}

$yaml += "`n`n# Cross-domain hints (optional - add manually if needed)"
$yaml += "`ncross_domain_hints: []"
$yaml += "`n"

# Output
if ($DryRun) {
    Write-Host "  DRY RUN - Would generate:`n" -ForegroundColor Yellow
    Write-Host $yaml
    Write-Host "`n  File would be written to: $IndexFile" -ForegroundColor Yellow
} else {
    $yaml | Out-File -FilePath $IndexFile -Encoding UTF8 -Force
    Write-Host "  Generated learning-index.yaml" -ForegroundColor Green
    Write-Host "    Topics indexed:    $processedCount"
    Write-Host "    Empty topics:      $emptyCount"
    Write-Host "    Total sessions:    $($indexData.total_sessions)"
    Write-Host "    Index file size:   $(Format-FileSize (Get-Item $IndexFile).Length)"
    Write-Host "    Output:            $IndexFile`n"
}
