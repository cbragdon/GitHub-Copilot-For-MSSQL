<#
.SYNOPSIS
    Registers a local scheduled task for the active plan-analysis plugin.

.DESCRIPTION
    The task runs daily at the specified local time. The updater performs work
    only every 14 days from its anchor date, unless it is invoked with -Force.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PluginRepositoryPath,

    [string] $GitHubRepository = 'cbragdon/GitHub-Copilot-For-MSSQL',

    [datetime] $AnchorDate = '2026-11-02',

    [datetime] $DailyAt = '09:00'
)

$ErrorActionPreference = 'Stop'

$updaterPath = Join-Path $PSScriptRoot 'Update-SqlServerQueryPlanPlugin.ps1'
if (-not (Test-Path -LiteralPath $updaterPath -PathType Leaf)) {
    throw "Updater script is missing: $updaterPath"
}

$resolvedPluginPath = (Resolve-Path -LiteralPath $PluginRepositoryPath -ErrorAction Stop).Path
$powerShellPath = (Get-Command powershell.exe -ErrorAction Stop).Source
$taskName = 'GitHub Copilot SQL Server Plan Plugin Updater'
$arguments = @(
    '-NoLogo',
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', "`"$updaterPath`"",
    '-PluginRepositoryPath', "`"$resolvedPluginPath`"",
    '-GitHubRepository', $GitHubRepository,
    '-AnchorDate', $AnchorDate.ToString('yyyy-MM-dd')
) -join ' '

$action = New-ScheduledTaskAction -Execute $powerShellPath -Argument $arguments
$trigger = New-ScheduledTaskTrigger -Daily -At $DailyAt
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description 'Fast-forwards the active sqlserver-query-plans plugin every 14 days and creates a GitHub issue notification.' `
    -Force | Out-Null

Write-Host "Registered '$taskName'. It runs daily at $($DailyAt.ToString('HH:mm')) local time and updates only on the 14-day cadence."
