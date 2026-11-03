# GitHub Copilot for SQL Server

Portable GitHub Copilot CLI skills and a PowerShell installer for SQL Server
index and execution-plan analysis. The package installs review-oriented
workflows; it does not connect to SQL Server, create an index, or modify a
database.

## What is included

| Component | Purpose |
|---|---|
| `sqlserver-index-analysis` | Evidence-backed conventional, covering, filtered, POC, and FPOC index analysis. |
| `query-plan-analysis` plugin | Actual SQL Server execution-plan analysis, installed separately by the installer. |
| `copilot-subagent-governance` | Advisory lanes, reporting, and guardrails for Copilot subagents. |
| `copilot-open-asks` | Tracks unresolved task questions and decisions. |
| `copilot-session-recovery` | Uses native session recovery and compaction commands. |
| `copilot-usage-budget` | Uses native usage and limit controls for budget-aware work. |

The skills are personal Copilot skills installed under `~\.copilot\skills`.
They can be used automatically when a request matches their description or
explicitly with `/SKILL-NAME`.

## Quick start

1. Install GitHub Copilot CLI and authenticate with GitHub.
2. Clone or download this repository.
3. In an interactive PowerShell terminal, run:

   ```powershell
   .\Install-GitHubCopilotMSSQL.ps1
   ```

4. Restart Copilot CLI, or run `/skills reload` in an existing session.
5. Verify the skills with `/skills list` and the plugin with:

   ```powershell
   copilot plugin list
   ```

See [INSTALL.md](INSTALL.md) for prerequisites, dry-run behavior, updates,
validation, and uninstall steps.

## SQL Server index workflow

For an index decision, provide the query text, representative parameter values,
an **actual** execution plan, existing indexes, and Query Store evidence when
available. Use both skills when plan diagnosis and index selection are needed:

```text
Use /query-plan-analysis and /sqlserver-index-analysis to analyze this query
and actual plan, then determine whether one index is justified.
```

`sqlserver-index-analysis` can use `DBAdmin.dbo.usp_IndexAnalysis` only when
the user explicitly authorizes access and supplies complete actual
`SHOWPLAN_XML`. Its output is candidate evidence, not executable DDL.

## Safety and scope

- The installer does not accept, store, or create database credentials.
- It does not install a SQL Server procedure or run a SQL statement.
- It never executes generated `CREATE INDEX`, `ALTER INDEX`, or `DROP INDEX`
  statements.
- The public `sqlserver-query-plans` plugin is installed through the Copilot CLI
  and may request confirmation.
- Subagent governance is advisory. Copilot skills cannot enforce lifecycle
  hooks, exact child token telemetry, or hard concurrency limits.

## Repository layout

```text
.
|-- Install-GitHubCopilotMSSQL.ps1
|-- INSTALL.md
|-- skills/
|   |-- sqlserver-index-analysis/
|   |-- copilot-subagent-governance/
|   |-- copilot-open-asks/
|   |-- copilot-session-recovery/
|   `-- copilot-usage-budget/
|-- CONTRIBUTING.md
|-- SECURITY.md
`-- LICENSE
```

## License

This repository is licensed under the [MIT License](LICENSE).
