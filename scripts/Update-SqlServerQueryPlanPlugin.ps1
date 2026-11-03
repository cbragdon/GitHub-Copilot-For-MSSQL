<#
.SYNOPSIS
    Updates an active local sqlserver-query-plans plugin checkout.

.DESCRIPTION
    On scheduled dates, fast-forwards Erik Darling's local plugin checkout and
    creates a GitHub issue in this repository after a successful update.

    The script refuses to update a dirty checkout or a checkout that cannot be
    fast-forwarded, preventing it from overwriting local work.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PluginRepositoryPath,

    [string] $GitHubRepository = 'cbragdon/GitHub-Copilot-For-MSSQL',

    [datetime] $AnchorDate = '2026-11-02',

    [switch] $Force,

    [switch] $CheckOnly
)

$ErrorActionPreference = 'Stop'

foreach ($command in @('git', 'gh', 'copilot')) {
    if ($null -eq (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command was not found on PATH: $command"
    }
}

$logDirectory = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'GitHubCopilotMSSQL\logs'
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$logPath = Join-Path $logDirectory 'sqlserver-query-plans-update.log'
Start-Transcript -Path $logPath -Append | Out-Null

try {
    $resolvedPath = (Resolve-Path -LiteralPath $PluginRepositoryPath -ErrorAction Stop).Path
    $isRepository = (& git -C $resolvedPath rev-parse --is-inside-work-tree 2>$null)
    if ($LASTEXITCODE -ne 0 -or $isRepository.Trim() -ne 'true') {
        throw "Plugin path is not a Git repository: $resolvedPath"
    }

    $remoteUrl = (& git -C $resolvedPath remote get-url origin).Trim()
    if ($LASTEXITCODE -ne 0 -or $remoteUrl -notmatch 'erikdarlingdata/claude-plugins(?:\.git)?$') {
        throw "Plugin repository must have Erik Darling's claude-plugins repository as origin: $resolvedPath"
    }

    $status = (& git -C $resolvedPath status --porcelain)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the plugin checkout status: $resolvedPath"
    }
    if (-not [string]::IsNullOrWhiteSpace(($status -join [Environment]::NewLine))) {
        throw "Plugin checkout has local changes and will not be updated: $resolvedPath"
    }

    $today = (Get-Date).Date
    $elapsedDays = ($today - $AnchorDate.Date).Days
    $isDue = $elapsedDays -ge 0 -and $elapsedDays % 14 -eq 0
    if (-not $Force -and -not $isDue) {
        Write-Host "No update check is due today. The next eligible date follows the 14-day cadence from $($AnchorDate.ToString('yyyy-MM-dd'))."
        return
    }

    & git -C $resolvedPath fetch origin main --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Could not fetch the upstream plugin repository."
    }

    $currentRef = (& git -C $resolvedPath rev-parse HEAD).Trim()
    $upstreamRef = (& git -C $resolvedPath rev-parse origin/main).Trim()
    if ($currentRef -eq $upstreamRef) {
        Write-Host "sqlserver-query-plans is already current at $currentRef."
        return
    }

    & git -C $resolvedPath merge-base --is-ancestor $currentRef $upstreamRef
    if ($LASTEXITCODE -ne 0) {
        throw "The plugin checkout cannot fast-forward to origin/main. Resolve the divergence manually: $resolvedPath"
    }

    if ($CheckOnly) {
        Write-Host "Update available: $currentRef -> $upstreamRef"
        return
    }

    & git -C $resolvedPath pull --ff-only origin main
    if ($LASTEXITCODE -ne 0) {
        throw "Could not fast-forward the plugin checkout."
    }

    $newRef = (& git -C $resolvedPath rev-parse HEAD).Trim()
    if ($newRef -ne $upstreamRef) {
        throw "Plugin checkout did not reach the expected upstream commit: $upstreamRef"
    }

    $shortCurrentRef = $currentRef.Substring(0, 12)
    $shortNewRef = $newRef.Substring(0, 12)
    $issueTitle = "Updated sqlserver-query-plans plugin to $shortNewRef"
    $issueBody = @"
The active local `sqlserver-query-plans` plugin checkout was fast-forwarded successfully.

- Previous commit: `$shortCurrentRef`
- New commit: `$shortNewRef`
- Repository: `$resolvedPath`
- Upstream: https://github.com/erikdarlingdata/claude-plugins

Start a new GitHub Copilot CLI session, or run `/skills reload`, before using the updated plugin.
"@

    & gh issue create --repo $GitHubRepository --title $issueTitle --body $issueBody
    if ($LASTEXITCODE -ne 0) {
        throw "The plugin was updated, but GitHub issue notification creation failed."
    }

    Write-Host "Updated sqlserver-query-plans to $newRef and created a GitHub issue notification."
}
finally {
    Stop-Transcript | Out-Null
}
