<#
.SYNOPSIS
    Manages topic-based learning files for Neocortex methodology.

.DESCRIPTION
    Script for managing topic learning in .mlda/topics/{topic}/learning.yaml.
    Supports loading, saving, and listing topic learnings.

.PARAMETER Topic
    The topic name (required for Load/Save operations)

.PARAMETER Load
    Load and display learnings for the specified topic

.PARAMETER Save
    Save new learnings to the specified topic (interactive)

.PARAMETER List
    List all available topics with learning files

.PARAMETER AddGrouping
    Add a new grouping to the topic learning (use with -Name, -Docs)

.PARAMETER AddActivation
    Add a new activation pattern (use with -Docs, -Tasks)

.PARAMETER Name
    Name for grouping (used with -AddGrouping)

.PARAMETER Docs
    Document IDs as comma-separated string (used with -AddGrouping or -AddActivation)

.PARAMETER Tasks
    Task types as comma-separated string (used with -AddActivation)

.PARAMETER Init
    Initialize a new topic with empty learning.yaml and domain.yaml

.EXAMPLE
    .\mlda-learning.ps1 -List
    .\mlda-learning.ps1 -Topic authentication -Load
    .\mlda-learning.ps1 -Topic authentication -Init
    .\mlda-learning.ps1 -Topic authentication -AddGrouping -Name "token-management" -Docs "DOC-AUTH-001,DOC-AUTH-002"
    .\mlda-learning.ps1 -Topic authentication -AddActivation -Docs "DOC-AUTH-001,DOC-SEC-001" -Tasks "implementing,debugging"
#>

param(
    [Parameter(Position=0)]
    [string]$Topic,

    [switch]$Load,
    [switch]$Save,
    [switch]$List,
    [switch]$Init,
    [switch]$AddGrouping,
    [switch]$AddActivation,

    [string]$Name,
    [string]$Docs,
    [string]$Tasks,

    [ValidateSet("human", "agent")]
    [string]$Origin = "human"
)

$ErrorActionPreference = "Stop"

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MldaRoot = Split-Path -Parent $ScriptDir
$TopicsDir = Join-Path $MldaRoot "topics"
$TemplatesDir = Join-Path $MldaRoot "templates"

# Ensure topics directory exists
if (-not (Test-Path $TopicsDir)) {
    New-Item -ItemType Directory -Path $TopicsDir -Force | Out-Null
}

# Helper: Get topic directory
function Get-TopicDir {
    param([string]$TopicName)
    return Join-Path $TopicsDir $TopicName
}

# Helper: Get learning file path
function Get-LearningFile {
    param([string]$TopicName)
    return Join-Path (Get-TopicDir $TopicName) "learning.yaml"
}

# Helper: Get domain file path
function Get-DomainFile {
    param([string]$TopicName)
    return Join-Path (Get-TopicDir $TopicName) "domain.yaml"
}

# Helper: Parse simple YAML value
function Get-YamlValue {
    param([string]$Content, [string]$Key)
    if ($Content -match "(?m)^$Key\s*:\s*(.+)$") {
        return $Matches[1].Trim().Trim('"').Trim("'")
    }
    return $null
}

# List all topics
function Show-TopicsList {
    Write-Host "`n=== Available Topics ===" -ForegroundColor Cyan

    $topics = Get-ChildItem -Path $TopicsDir -Directory -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -notlike "_*" }

    if ($topics.Count -eq 0) {
        Write-Host "No topics found." -ForegroundColor Yellow
        Write-Host "Use -Init -Topic <name> to create a new topic."
        return
    }

    foreach ($topicDir in $topics) {
        $learningFile = Join-Path $topicDir.FullName "learning.yaml"
        $domainFile = Join-Path $topicDir.FullName "domain.yaml"

        $hasLearning = Test-Path $learningFile
        $hasDomain = Test-Path $domainFile

        $status = ""
        if ($hasLearning -and $hasDomain) {
            $status = "[complete]"

            # Try to get version and session count
            if ($hasLearning) {
                $content = Get-Content $learningFile -Raw -ErrorAction SilentlyContinue
                $version = Get-YamlValue $content "version"
                $sessions = Get-YamlValue $content "sessions_contributed"
                if ($version) { $status = "[v$version, $sessions sessions]" }
            }
        } elseif ($hasLearning -or $hasDomain) {
            $status = "[partial]"
        } else {
            $status = "[empty]"
        }

        Write-Host "  $($topicDir.Name) " -NoNewline -ForegroundColor White
        Write-Host $status -ForegroundColor DarkGray
    }

    Write-Host ""
}

# Load and display topic learnings
function Show-TopicLearning {
    param([string]$TopicName)

    $learningFile = Get-LearningFile $TopicName

    if (-not (Test-Path $learningFile)) {
        Write-Host "`nNo learning file found for topic: $TopicName" -ForegroundColor Yellow
        Write-Host "Use -Init -Topic $TopicName to create one."
        return
    }

    Write-Host "`n=== Topic Learning: $TopicName ===" -ForegroundColor Cyan

    $content = Get-Content $learningFile -Raw

    # Display basic info
    $version = Get-YamlValue $content "version"
    $lastUpdated = Get-YamlValue $content "last_updated"
    $sessions = Get-YamlValue $content "sessions_contributed"

    Write-Host "Version:  $version"
    Write-Host "Updated:  $lastUpdated"
    Write-Host "Sessions: $sessions"

    # Display groupings
    Write-Host "`n--- Groupings ---" -ForegroundColor Yellow
    if ($content -match "(?ms)groupings:\s*\[\]") {
        Write-Host "  (none)"
    } elseif ($content -match "(?ms)groupings:(.+?)(?=\n[a-z_]+:|$)") {
        $groupingsSection = $Matches[1]
        $groupingMatches = [regex]::Matches($groupingsSection, "- name:\s*([^\n]+)")
        foreach ($g in $groupingMatches) {
            Write-Host "  - $($g.Groups[1].Value.Trim())" -ForegroundColor White
        }
        if ($groupingMatches.Count -eq 0) {
            Write-Host "  (none)"
        }
    }

    # Display activations
    Write-Host "`n--- Activations ---" -ForegroundColor Yellow
    if ($content -match "(?ms)activations:\s*\[\]") {
        Write-Host "  (none)"
    } elseif ($content -match "(?ms)activations:(.+?)(?=\n[a-z_]+:|$)") {
        $activationsSection = $Matches[1]
        $activationMatches = [regex]::Matches($activationsSection, "- docs:\s*\[([^\]]+)\]")
        foreach ($a in $activationMatches) {
            Write-Host "  - [$($a.Groups[1].Value.Trim())]" -ForegroundColor White
        }
        if ($activationMatches.Count -eq 0) {
            Write-Host "  (none)"
        }
    }

    # Display verification notes
    Write-Host "`n--- Verification Notes ---" -ForegroundColor Yellow
    if ($content -match "(?ms)verification_notes:\s*\[\]") {
        Write-Host "  (none)"
    } elseif ($content -match "(?ms)verification_notes:(.+?)(?=\n[a-z_]+:|$)") {
        $notesSection = $Matches[1]
        $noteMatches = [regex]::Matches($notesSection, "lesson:\s*`"([^`"]+)`"")
        foreach ($n in $noteMatches) {
            Write-Host "  - $($n.Groups[1].Value.Trim())" -ForegroundColor White
        }
        if ($noteMatches.Count -eq 0) {
            Write-Host "  (none)"
        }
    }

    Write-Host ""
}

# Initialize a new topic
function Initialize-Topic {
    param([string]$TopicName)

    $topicDir = Get-TopicDir $TopicName
    $learningFile = Get-LearningFile $TopicName
    $domainFile = Get-DomainFile $TopicName

    if (Test-Path $topicDir) {
        Write-Host "`nTopic directory already exists: $TopicName" -ForegroundColor Yellow

        if (-not (Test-Path $learningFile)) {
            Write-Host "Creating missing learning.yaml..." -ForegroundColor Cyan
        }
        if (-not (Test-Path $domainFile)) {
            Write-Host "Creating missing domain.yaml..." -ForegroundColor Cyan
        }
    } else {
        New-Item -ItemType Directory -Path $topicDir -Force | Out-Null
        Write-Host "`nCreated topic directory: $TopicName" -ForegroundColor Green
    }

    $date = Get-Date -Format "yyyy-MM-dd"

    # Create learning.yaml if missing
    if (-not (Test-Path $learningFile)) {
        $learningContent = @"
# Topic Learning File
# Schema: .mlda/schemas/topic-learning.schema.yaml

topic: $TopicName
version: 1
last_updated: "$date"
sessions_contributed: 0

groupings: []

activations: []

verification_notes: []

related_domains: []

anti_patterns: []
"@
        Set-Content $learningFile -Value $learningContent
        Write-Host "Created: learning.yaml" -ForegroundColor Green
    }

    # Create domain.yaml if missing
    if (-not (Test-Path $domainFile)) {
        $domainContent = @"
# Topic Domain Configuration
# Schema: .mlda/schemas/topic-domain.schema.yaml

domain: $TopicName
version: 1
last_updated: "$date"
source: human

sub_domains: []

entry_points:
  default: null
  by_task: {}

decomposition:
  strategy: by_sub_domain
  max_docs_per_agent: 5
  parallel_allowed: true

override_allowed: true
override_requires_approval: false

related_domains: []

isolated_from: []
"@
        Set-Content $domainFile -Value $domainContent
        Write-Host "Created: domain.yaml" -ForegroundColor Green
    }

    Write-Host "`nTopic initialized: $TopicName" -ForegroundColor Cyan
    Write-Host "Location: .mlda/topics/$TopicName/"
}

# Add a grouping to learning.yaml
function Add-Grouping {
    param(
        [string]$TopicName,
        [string]$GroupName,
        [string]$DocsList,
        [string]$GroupOrigin
    )

    $learningFile = Get-LearningFile $TopicName

    if (-not (Test-Path $learningFile)) {
        Write-Host "Error: Topic not initialized. Run with -Init first." -ForegroundColor Red
        return
    }

    $content = Get-Content $learningFile -Raw
    $date = Get-Date -Format "yyyy-MM-dd"

    # Parse docs list
    $docsArray = $DocsList -split ',' | ForEach-Object { $_.Trim() }
    $docsYaml = ($docsArray | ForEach-Object { "      - $_" }) -join "`n"

    $newGrouping = @"

  - name: $GroupName
    docs:
$docsYaml
    origin: $GroupOrigin
    confidence: medium
"@

    # Replace empty groupings array or append
    if ($content -match "groupings:\s*\[\]") {
        $content = $content -replace "groupings:\s*\[\]", "groupings:$newGrouping"
    } else {
        # Find groupings section and append
        $content = $content -replace "(groupings:.*?)(\n\n|\nactivations:)", "`$1$newGrouping`$2"
    }

    # Update version and date
    $currentVersion = Get-YamlValue $content "version"
    $newVersion = [int]$currentVersion + 1
    $content = $content -replace "version:\s*\d+", "version: $newVersion"
    $content = $content -replace 'last_updated:\s*"[^"]+"', "last_updated: `"$date`""

    Set-Content $learningFile -Value $content
    Write-Host "Added grouping '$GroupName' to $TopicName (v$newVersion)" -ForegroundColor Green
}

# Add an activation pattern
function Add-Activation {
    param(
        [string]$TopicName,
        [string]$DocsList,
        [string]$TasksList
    )

    $learningFile = Get-LearningFile $TopicName

    if (-not (Test-Path $learningFile)) {
        Write-Host "Error: Topic not initialized. Run with -Init first." -ForegroundColor Red
        return
    }

    $content = Get-Content $learningFile -Raw
    $date = Get-Date -Format "yyyy-MM-dd"

    # Parse docs and tasks
    $docsArray = $DocsList -split ',' | ForEach-Object { $_.Trim() }
    $tasksArray = $TasksList -split ',' | ForEach-Object { $_.Trim() }

    $docsYaml = "[" + ($docsArray -join ", ") + "]"
    $tasksYaml = "`n" + ($tasksArray | ForEach-Object { "      - $_" } | Out-String).TrimEnd()

    $newActivation = @"

  - docs: $docsYaml
    frequency: 1
    typical_tasks:$tasksYaml
    last_session: "$date"
"@

    # Replace empty activations array or append
    if ($content -match "activations:\s*\[\]") {
        $content = $content -replace "activations:\s*\[\]", "activations:$newActivation"
    } else {
        # Find activations section and append
        $content = $content -replace "(activations:.*?)(\n\n|\nverification_notes:)", "`$1$newActivation`$2"
    }

    # Update version and date
    $currentVersion = Get-YamlValue $content "version"
    $newVersion = [int]$currentVersion + 1
    $content = $content -replace "version:\s*\d+", "version: $newVersion"
    $content = $content -replace 'last_updated:\s*"[^"]+"', "last_updated: `"$date`""

    Set-Content $learningFile -Value $content
    Write-Host "Added activation pattern to $TopicName (v$newVersion)" -ForegroundColor Green
}

# Main execution
if ($List) {
    Show-TopicsList
    exit 0
}

if (-not $Topic) {
    Write-Host "Error: -Topic is required for this operation" -ForegroundColor Red
    Write-Host "Usage: .\mlda-learning.ps1 -Topic <name> [-Load|-Init|-AddGrouping|-AddActivation]"
    Write-Host "       .\mlda-learning.ps1 -List"
    exit 1
}

# Validate topic name
if ($Topic -notmatch "^[a-z][a-z0-9-]*$") {
    Write-Host "Error: Topic name must be lowercase with hyphens only (e.g., 'authentication', 'user-management')" -ForegroundColor Red
    exit 1
}

if ($Init) {
    Initialize-Topic $Topic
    exit 0
}

if ($Load) {
    Show-TopicLearning $Topic
    exit 0
}

if ($AddGrouping) {
    if (-not $Name -or -not $Docs) {
        Write-Host "Error: -AddGrouping requires -Name and -Docs parameters" -ForegroundColor Red
        Write-Host "Example: -AddGrouping -Name 'token-management' -Docs 'DOC-AUTH-001,DOC-AUTH-002'"
        exit 1
    }
    Add-Grouping -TopicName $Topic -GroupName $Name -DocsList $Docs -GroupOrigin $Origin
    exit 0
}

if ($AddActivation) {
    if (-not $Docs -or -not $Tasks) {
        Write-Host "Error: -AddActivation requires -Docs and -Tasks parameters" -ForegroundColor Red
        Write-Host "Example: -AddActivation -Docs 'DOC-AUTH-001,DOC-SEC-001' -Tasks 'implementing,debugging'"
        exit 1
    }
    Add-Activation -TopicName $Topic -DocsList $Docs -TasksList $Tasks
    exit 0
}

# Default: show help
Write-Host "MLDA Learning Management" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:"
Write-Host "  -List                    List all topics"
Write-Host "  -Topic <name> -Load      Load and display topic learnings"
Write-Host "  -Topic <name> -Init      Initialize new topic"
Write-Host "  -Topic <name> -AddGrouping -Name <name> -Docs <docs>"
Write-Host "                           Add a document grouping"
Write-Host "  -Topic <name> -AddActivation -Docs <docs> -Tasks <tasks>"
Write-Host "                           Add an activation pattern"
Write-Host ""
