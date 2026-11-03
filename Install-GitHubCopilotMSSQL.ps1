<#
.SYNOPSIS
    Installs GitHub Copilot CLI skills for SQL Server analysis.

.DESCRIPTION
    Copies the repository's personal skills into a Copilot skills directory,
    enables those skills, and installs the public sqlserver-query-plans plugin
    through GitHub Copilot CLI.

    The script does not connect to SQL Server, create database objects, store
    credentials, or execute generated SQL DDL.

.PARAMETER Destination
    Personal Copilot skills directory. The default is ~/.copilot/skills.

.PARAMETER SkipQueryPlanPlugin
    Do not install or enable the public sqlserver-query-plans plugin.

.PARAMETER SkipSkillEnable
    Copy skills without enabling them through Copilot CLI.

.EXAMPLE
    .\Install-GitHubCopilotMSSQL.ps1 -WhatIf
    Shows the installation actions without changing files or Copilot settings.

.EXAMPLE
    .\Install-GitHubCopilotMSSQL.ps1
    Installs and enables all included skills and the query-plan plugin.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $Destination = (Join-Path $HOME '.copilot\skills'),
    [switch] $SkipQueryPlanPlugin,
    [switch] $SkipSkillEnable
)

$ErrorActionPreference = 'Stop'

trap {
    Write-Host ("ERROR: {0} (line {1})" -f $_.Exception.Message, $_.InvocationInfo.ScriptLineNumber) -ForegroundColor Red
    exit 1
}

$root = $PSScriptRoot
$sourceSkills = Join-Path $root 'skills'
$skillNames = @(
    'sqlserver-index-analysis',
    'copilot-subagent-governance',
    'copilot-open-asks',
    'copilot-session-recovery',
    'copilot-usage-budget'
)
$pluginName = 'sqlserver-query-plans'
$pluginSource = 'erikdarlingdata/claude-plugins:plugins/sqlserver-query-plans'

if (-not (Test-Path -LiteralPath $sourceSkills -PathType Container)) {
    throw "Skill source directory is missing: $sourceSkills"
}

$copilot = Get-Command copilot -ErrorAction SilentlyContinue
if ($null -eq $copilot) {
    throw 'GitHub Copilot CLI was not found on PATH. Install and authenticate Copilot CLI before running this script.'
}

foreach ($skillName in $skillNames) {
    $skillFile = Join-Path $sourceSkills "$skillName\SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        throw "Required skill file is missing: $skillFile"
    }

    $metadata = Get-Content -LiteralPath $skillFile -Raw
    if ($metadata -notmatch "(?ms)^---\s*\r?\nname:\s*$([regex]::Escape($skillName))\s*\r?\ndescription:\s*.+?\r?\n---") {
        throw "Skill metadata is invalid: $skillFile"
    }
}

Write-Host ''
Write-Host '=== GitHub Copilot for SQL Server ===============================================' -ForegroundColor Cyan
Write-Host ("  source skills : {0}" -f $sourceSkills)
Write-Host ("  destination   : {0}" -f $Destination)
Write-Host ("  plugin        : {0}" -f $pluginName)

if ($PSCmdlet.ShouldProcess($Destination, 'Create Copilot personal skills directory')) {
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
}

foreach ($skillName in $skillNames) {
    $source = Join-Path $sourceSkills $skillName
    $target = Join-Path $Destination $skillName

    if ($PSCmdlet.ShouldProcess($target, "Install skill $skillName")) {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item -LiteralPath (Join-Path $source 'SKILL.md') -Destination $target -Force
    }
}

if ($WhatIfPreference) {
    Write-Host 'WhatIf completed. No files or Copilot settings were changed.' -ForegroundColor Yellow
    exit 0
}

if (-not $SkipSkillEnable) {
    foreach ($skillName in $skillNames) {
        if ($PSCmdlet.ShouldProcess($skillName, 'Enable Copilot skill')) {
            & $copilot.Source skill enable $skillName
            if ($LASTEXITCODE -ne 0) {
                throw "Copilot could not enable skill '$skillName' (exit $LASTEXITCODE)."
            }
        }
    }
}

$listedSkills = (& $copilot.Source skill list | Out-String)
foreach ($skillName in $skillNames) {
    if ($listedSkills -notmatch [regex]::Escape($skillName)) {
        throw "Copilot did not discover installed skill '$skillName'."
    }
}

if (-not $SkipQueryPlanPlugin) {
    $plugins = (& $copilot.Source plugin list | Out-String)
    if ($plugins -notmatch [regex]::Escape($pluginName)) {
        if ($PSCmdlet.ShouldProcess($pluginSource, "Install Copilot plugin $pluginName")) {
            & $copilot.Source plugin install $pluginSource
            if ($LASTEXITCODE -ne 0) {
                throw "Copilot could not install plugin '$pluginSource' (exit $LASTEXITCODE)."
            }
        }
    }

    if ($PSCmdlet.ShouldProcess($pluginName, 'Enable Copilot plugin')) {
        & $copilot.Source plugin enable $pluginName
        if ($LASTEXITCODE -ne 0) {
            throw "Copilot could not enable plugin '$pluginName' (exit $LASTEXITCODE)."
        }
    }

    $plugins = (& $copilot.Source plugin list | Out-String)
    if ($plugins -notmatch [regex]::Escape($pluginName)) {
        throw "Copilot did not report installed plugin '$pluginName'."
    }
}

Write-Host ''
Write-Host 'Installation completed successfully.' -ForegroundColor Green
Write-Host 'Start a new Copilot CLI session, or run /skills reload in an active session.'
