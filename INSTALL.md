# Installation guide

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7.
- GitHub Copilot CLI installed and authenticated.
- Internet access to install the public `sqlserver-query-plans` plugin.
- An interactive terminal. The Copilot plugin installer may ask for
  confirmation.

The package does not require SQL Server, `sqlcmd`, a connection string, or
database credentials to install.

## Install

Clone the repository:

```powershell
git clone https://github.com/cbragdon/GitHub-Copilot-For-MSSQL.git
Set-Location .\GitHub-Copilot-For-MSSQL
```

Preview the changes:

```powershell
.\Install-GitHubCopilotMSSQL.ps1 -WhatIf
```

Install the personal skills and the execution-plan plugin:

```powershell
.\Install-GitHubCopilotMSSQL.ps1
```

The installer copies the following folders into `~\.copilot\skills` and enables
them:

- `sqlserver-index-analysis`
- `copilot-subagent-governance`
- `copilot-open-asks`
- `copilot-session-recovery`
- `copilot-usage-budget`

It installs and enables the public `query-plan-analysis` plugin from
[Erik Darling's `sqlserver-query-plans` repository component](https://github.com/erikdarlingdata/claude-plugins/tree/main/plugins/sqlserver-query-plans):

```text
erikdarlingdata/claude-plugins:plugins/sqlserver-query-plans
```

The installer uses GitHub Copilot CLI's plugin command. It does not use a
Claude API or install a Claude runtime. The plugin remains Erik Darling's
upstream work; this repository only installs it through Copilot CLI.

## Installer options

```powershell
# Install skills only.
.\Install-GitHubCopilotMSSQL.ps1 -SkipQueryPlanPlugin

# Copy skills but leave enablement unchanged.
.\Install-GitHubCopilotMSSQL.ps1 -SkipSkillEnable

# Use a non-default personal skills location.
.\Install-GitHubCopilotMSSQL.ps1 -Destination 'D:\Copilot\skills'

# Preview all changes.
.\Install-GitHubCopilotMSSQL.ps1 -WhatIf
```

## Verify

Start a new Copilot CLI session, or run:

```text
/skills reload
/skills list
```

Confirm the plugin is installed:

```powershell
copilot plugin list
```

Invoke a skill explicitly when desired:

```text
/sqlserver-index-analysis Analyze this query and actual plan.
/copilot-subagent-governance Coordinate these independent tasks.
```

## Update

Pull the latest repository changes and rerun the installer:

```powershell
git pull --ff-only
.\Install-GitHubCopilotMSSQL.ps1
```

To update the public plan-analysis plugin:

```powershell
copilot plugin update sqlserver-query-plans
```

## Uninstall

Remove the personal skill folders you no longer want:

```powershell
$skills = @(
    'sqlserver-index-analysis',
    'copilot-subagent-governance',
    'copilot-open-asks',
    'copilot-session-recovery',
    'copilot-usage-budget'
)

$skills | ForEach-Object {
    Remove-Item -LiteralPath (Join-Path $HOME ".copilot\skills\$_") -Recurse
}
```

Then uninstall the plugin if it is no longer needed:

```powershell
copilot plugin uninstall sqlserver-query-plans
```

Review the resolved paths before running removal commands. Uninstalling the
skills does not delete Copilot sessions, settings, permissions, or SQL Server
objects.
