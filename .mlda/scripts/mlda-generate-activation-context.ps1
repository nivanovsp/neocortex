<#
.SYNOPSIS
    Generates the activation-context.yaml from registry, handoff, learning-index, and config.

.DESCRIPTION
    Consolidates all awakening-time information into a single lightweight file.
    This file is loaded during mode activation instead of reading 4+ separate files.

    Sources:
    - .mlda/registry.yaml (MLDA status, doc counts)
    - docs/handoff.md (current phase, ready items, open questions)
    - .mlda/learning-index.yaml (topic counts, highlights)
    - .mlda/config.yaml (context limits)

    Related: DEC-009-activation-context-optimization.md

.PARAMETER DryRun
    Show what would be generated without writing the file

.PARAMETER Quiet
    Suppress output (useful when chained from other scripts)

.PARAMETER Force
    Regenerate even if sources haven't changed

.EXAMPLE
    .\mlda-generate-activation-context.ps1                # Generate activation context
    .\mlda-generate-activation-context.ps1 -DryRun        # Preview without writing
    .\mlda-generate-activation-context.ps1 -Quiet         # Silent operation
#>

param(
    [switch]$DryRun,
    [switch]$Quiet,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$ProjectRoot = Split-Path -Parent $MldaRoot
$RegistryFile = Join-Path $MldaRoot "registry.yaml"
$LearningIndexFile = Join-Path $MldaRoot "learning-index.yaml"
$ConfigFile = Join-Path $MldaRoot "config.yaml"
$HandoffFile = Join-Path $ProjectRoot "docs\handoff.md"
$OutputFile = Join-Path $MldaRoot "activation-context.yaml"

# Helper: Write output if not quiet
function Write-Info {
    param([string]$Message, [string]$Color = "White")
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Helper: Simple YAML value extractor
function Get-YamlValue {
    param(
        [string[]]$Content,
        [string]$Key
    )
    foreach ($line in $Content) {
        if ($line -match "^${Key}:\s*(.+)$") {
            $value = $Matches[1].Trim()
            if ($value -match '^"(.+)"$' -or $value -match "^'(.+)'$") {
                return $Matches[1]
            }
            return $value
        }
    }
    return $null
}

# Helper: Extract array items from YAML
function Get-YamlArrayItems {
    param(
        [string[]]$Content,
        [string]$SectionName,
        [int]$MaxItems = 10
    )

    $items = @()
    $inSection = $false

    foreach ($line in $Content) {
        if ($line -match "^${SectionName}:") {
            $inSection = $true
            continue
        }

        if ($inSection -and $line -match "^\w+:" -and -not ($line -match "^\s")) {
            break
        }

        if ($inSection -and $line -match "^\s+-\s+(.+)$") {
            $items += $Matches[1].Trim()
            if ($items.Count -ge $MaxItems) { break }
        }
    }

    return $items
}

# ============================================
# EXTRACT: MLDA Status from registry.yaml
# ============================================

function Get-MldaStatus {
    $mlda = @{
        status = "not_initialized"
        doc_count = 0
        domains = @()
        orphan_count = 0
        health = "healthy"
    }

    if (-not (Test-Path $RegistryFile)) {
        return $mlda
    }

    $content = Get-Content $RegistryFile
    $mlda.status = "initialized"

    # Count documents
    $docCount = 0
    $domains = @{}
    $inDocuments = $false

    foreach ($line in $content) {
        if ($line -match "^documents:") {
            $inDocuments = $true
            continue
        }

        if ($inDocuments -and $line -match "^\s+(DOC-([A-Z]+)-\d+):") {
            $docCount++
            $domain = $Matches[2]
            $domains[$domain] = $true
        }

        if ($inDocuments -and $line -match "^\w+:" -and -not ($line -match "^\s")) {
            break
        }
    }

    $mlda.doc_count = $docCount
    $mlda.domains = @($domains.Keys | Sort-Object)

    # Get last update date
    $lastUpdate = Get-YamlValue -Content $content -Key "last_updated"
    if ($lastUpdate) {
        $mlda.last_registry_update = $lastUpdate
    }

    # Get orphan count if available
    $orphans = Get-YamlValue -Content $content -Key "orphan_count"
    if ($orphans) {
        $mlda.orphan_count = [int]$orphans
        if ($mlda.orphan_count -gt 3) {
            $mlda.health = "warning"
        }
    }

    return $mlda
}

# ============================================
# EXTRACT: Handoff Summary from docs/handoff.md
# ============================================

function Get-HandoffSummary {
    $handoff = @{
        current_phase = "analyst"
        ready_items = @()
        open_questions = @()
        entry_points = @()
        phases_completed = @()
    }

    if (-not (Test-Path $HandoffFile)) {
        return $null
    }

    $content = Get-Content $HandoffFile -Raw

    # Detect current phase from headers
    $phasePatterns = @{
        "## Phase 5: Developer" = "development"
        "## Phase 4: Analyst" = "stories"
        "## Phase 3: UX-Expert" = "ux-expert"
        "## Phase 2: Architect" = "architect"
        "## Phase 1: Analyst" = "analyst"
    }

    $foundPhases = @()
    foreach ($pattern in $phasePatterns.Keys) {
        if ($content -match [regex]::Escape($pattern)) {
            $foundPhases += $phasePatterns[$pattern]
        }
    }

    if ($foundPhases.Count -gt 0) {
        # Current phase is the last one found
        $handoff.current_phase = $foundPhases[0]
        # Completed phases are earlier ones
        $handoff.phases_completed = $foundPhases | Select-Object -Skip 1
    }

    # Set phase owner
    $phaseOwners = @{
        "analyst" = "analyst"
        "architect" = "architect"
        "ux-expert" = "ux-expert"
        "stories" = "analyst"
        "development" = "dev"
    }
    $handoff.current_phase_owner = $phaseOwners[$handoff.current_phase]

    # Extract open questions (look for "Open Questions" section)
    if ($content -match "(?ms)### Open Questions.*?(?=###|\z)") {
        $questionsSection = $Matches[0]
        $questions = [regex]::Matches($questionsSection, "^\s*[-*]\s+(.+?)$", "Multiline")
        foreach ($q in $questions | Select-Object -First 5) {
            $question = $q.Groups[1].Value.Trim()
            if ($question.Length -gt 10 -and $question.Length -le 200) {
                $handoff.open_questions += $question
            }
        }
    }

    # Extract entry points (DOC-IDs mentioned)
    $docIds = [regex]::Matches($content, "DOC-[A-Z]+-\d{3}")
    $uniqueDocIds = @{}
    foreach ($match in $docIds) {
        $uniqueDocIds[$match.Value] = $true
    }
    $handoff.entry_points = @($uniqueDocIds.Keys | Select-Object -First 10)

    # Extract ready items (look for story/task patterns)
    $storyPattern = "(?:STORY|TASK|EPIC)-[A-Z]+-\d+"
    $stories = [regex]::Matches($content, $storyPattern)
    $readyItems = @{}
    foreach ($s in $stories) {
        $id = $s.Value
        if (-not $readyItems.ContainsKey($id)) {
            $readyItems[$id] = @{ id = $id; title = "See handoff for details" }
        }
    }
    $handoff.ready_items = @($readyItems.Values | Select-Object -First 10)

    return $handoff
}

# ============================================
# EXTRACT: Learning Summary from learning-index.yaml
# ============================================

function Get-LearningSummary {
    $learning = @{
        topics_total = 0
        topics_with_data = 0
        sessions_total = 0
        recent_topics = @()
        highlights = @()
    }

    if (-not (Test-Path $LearningIndexFile)) {
        return $learning
    }

    $content = Get-Content $LearningIndexFile

    # Get totals
    $generated_from = Get-YamlValue -Content $content -Key "generated_from"
    $total_sessions = Get-YamlValue -Content $content -Key "total_sessions"

    if ($generated_from) { $learning.topics_with_data = [int]$generated_from }
    if ($total_sessions) { $learning.sessions_total = [int]$total_sessions }

    # Count total topics (including empty)
    $emptyTopics = Get-YamlArrayItems -Content $content -SectionName "empty_topics"
    $learning.topics_total = $learning.topics_with_data + $emptyTopics.Count

    # Extract topic names and their sessions for sorting
    $topicData = @{}
    $inTopics = $false
    $currentTopic = $null

    foreach ($line in $content) {
        if ($line -match "^topics:") {
            $inTopics = $true
            continue
        }

        if ($inTopics -and $line -match "^empty_topics:") {
            break
        }

        if ($inTopics -and $line -match "^\s{2}([A-Z0-9_-]+):$") {
            $currentTopic = $Matches[1]
            $topicData[$currentTopic] = @{ sessions = 0; insight = "" }
        }

        if ($currentTopic -and $line -match "^\s+sessions:\s*(\d+)") {
            $topicData[$currentTopic].sessions = [int]$Matches[1]
        }

        if ($currentTopic -and $line -match '^\s+-\s+"(.+)"') {
            if (-not $topicData[$currentTopic].insight) {
                $topicData[$currentTopic].insight = $Matches[1]
            }
        }
    }

    # Sort by sessions and get top topics
    $sortedTopics = $topicData.GetEnumerator() | Sort-Object { $_.Value.sessions } -Descending
    $learning.recent_topics = @($sortedTopics | Select-Object -First 5 | ForEach-Object { $_.Key })

    # Get highlights (top insight from each top topic)
    foreach ($topic in $sortedTopics | Select-Object -First 5) {
        if ($topic.Value.insight) {
            $learning.highlights += @{
                topic = $topic.Key
                insight = $topic.Value.insight
            }
        }
    }

    return $learning
}

# ============================================
# EXTRACT: Config Essentials from config.yaml
# ============================================

function Get-ConfigEssentials {
    $config = @{
        context_soft_limit = 35000
        context_hard_limit = 50000
        auto_gather_context = $true
    }

    if (-not (Test-Path $ConfigFile)) {
        return $config
    }

    $content = Get-Content $ConfigFile

    $softLimit = Get-YamlValue -Content $content -Key "context_soft_limit"
    $hardLimit = Get-YamlValue -Content $content -Key "context_hard_limit"
    $autoGather = Get-YamlValue -Content $content -Key "auto_gather_context"

    if ($softLimit) { $config.context_soft_limit = [int]$softLimit }
    if ($hardLimit) { $config.context_hard_limit = [int]$hardLimit }
    if ($autoGather -eq "false") { $config.auto_gather_context = $false }

    return $config
}

# ============================================
# MAIN: Generate Activation Context
# ============================================

Write-Info "`n  Activation Context Generator" "Cyan"
Write-Info "  ===========================`n"

# Gather data from all sources
Write-Info "  Reading sources..."
$mlda = Get-MldaStatus
$handoff = Get-HandoffSummary
$learning = Get-LearningSummary
$config = Get-ConfigEssentials

Write-Info "    MLDA:     $($mlda.status), $($mlda.doc_count) docs" "DarkGray"
Write-Info "    Handoff:  $(if ($handoff) { $handoff.current_phase } else { 'not found' })" "DarkGray"
Write-Info "    Learning: $($learning.topics_total) topics, $($learning.sessions_total) sessions" "DarkGray"
Write-Info "    Config:   soft=$($config.context_soft_limit), hard=$($config.context_hard_limit)" "DarkGray"

# Build YAML output
$timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

$yaml = @"
# MLDA Activation Context
# Pre-computed lightweight context for mode awakening
# Generated: $timestamp
# Generator: mlda-generate-activation-context.ps1
#
# This file consolidates registry, handoff, learning-index, and config
# for single-file mode activation (DEC-009).
# DO NOT EDIT MANUALLY - regenerate with: .\mlda-generate-activation-context.ps1

generated: "$timestamp"
generator_version: 1
generator_script: "mlda-generate-activation-context.ps1"

# ============================================
# MLDA STATUS (from registry.yaml)
# ============================================
mlda:
  status: $($mlda.status)
  doc_count: $($mlda.doc_count)
  domains: [$($mlda.domains -join ", ")]
  orphan_count: $($mlda.orphan_count)
  health: $($mlda.health)
"@

if ($mlda.last_registry_update) {
    $yaml += "`n  last_registry_update: `"$($mlda.last_registry_update)`""
}

# Handoff section
if ($handoff) {
    $yaml += @"

# ============================================
# HANDOFF SUMMARY (from docs/handoff.md)
# ============================================
handoff:
  current_phase: $($handoff.current_phase)
  current_phase_owner: $($handoff.current_phase_owner)
"@

    if ($handoff.ready_items.Count -gt 0) {
        $yaml += "`n  ready_items:"
        foreach ($item in $handoff.ready_items | Select-Object -First 5) {
            $yaml += "`n    - id: `"$($item.id)`""
            $yaml += "`n      title: `"$($item.title -replace '"', '\"')`""
        }
    } else {
        $yaml += "`n  ready_items: []"
    }

    if ($handoff.open_questions.Count -gt 0) {
        $yaml += "`n  open_questions:"
        foreach ($q in $handoff.open_questions | Select-Object -First 5) {
            $escaped = $q -replace '"', '\"'
            $yaml += "`n    - `"$escaped`""
        }
    } else {
        $yaml += "`n  open_questions: []"
    }

    if ($handoff.entry_points.Count -gt 0) {
        $yaml += "`n  entry_points:"
        foreach ($ep in $handoff.entry_points | Select-Object -First 10) {
            $yaml += "`n    - $ep"
        }
    } else {
        $yaml += "`n  entry_points: []"
    }

    if ($handoff.phases_completed.Count -gt 0) {
        $yaml += "`n  phases_completed: [$($handoff.phases_completed -join ", ")]"
    } else {
        $yaml += "`n  phases_completed: []"
    }
} else {
    $yaml += @"

# ============================================
# HANDOFF SUMMARY
# ============================================
# No handoff document found at docs/handoff.md
handoff: null
"@
}

# Learning section
$yaml += @"

# ============================================
# LEARNING SUMMARY (from learning-index.yaml)
# ============================================
learning:
  topics_total: $($learning.topics_total)
  topics_with_data: $($learning.topics_with_data)
  sessions_total: $($learning.sessions_total)
"@

if ($learning.recent_topics.Count -gt 0) {
    $yaml += "`n  recent_topics: [$($learning.recent_topics -join ", ")]"
} else {
    $yaml += "`n  recent_topics: []"
}

if ($learning.highlights.Count -gt 0) {
    $yaml += "`n  highlights:"
    foreach ($h in $learning.highlights | Select-Object -First 5) {
        $escaped = $h.insight -replace '"', '\"'
        $yaml += "`n    - topic: $($h.topic)"
        $yaml += "`n      insight: `"$escaped`""
    }
} else {
    $yaml += "`n  highlights: []"
}

# Config section
$yaml += @"

# ============================================
# CONFIG ESSENTIALS (from .mlda/config.yaml)
# ============================================
config:
  context_soft_limit: $($config.context_soft_limit)
  context_hard_limit: $($config.context_hard_limit)
  auto_gather_context: $($config.auto_gather_context.ToString().ToLower())
"@

$yaml += "`n"

# Output
if ($DryRun) {
    Write-Info "`n  DRY RUN - Would generate:`n" "Yellow"
    Write-Host $yaml
    Write-Info "`n  File would be written to: $OutputFile" "Yellow"
} else {
    $yaml | Out-File -FilePath $OutputFile -Encoding UTF8 -Force
    $fileSize = (Get-Item $OutputFile).Length
    Write-Info ""
    Write-Info "  Generated activation-context.yaml" "Green"
    Write-Info "    MLDA status:    $($mlda.status) ($($mlda.doc_count) docs)"
    Write-Info "    Current phase:  $(if ($handoff) { $handoff.current_phase } else { 'N/A' })"
    Write-Info "    Learning:       $($learning.topics_total) topics, $($learning.sessions_total) sessions"
    Write-Info "    File size:      $fileSize bytes"
    Write-Info "    Output:         $OutputFile`n"
}
