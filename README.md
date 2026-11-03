# GitHub Copilot for SQL Server

Portable GitHub Copilot CLI skills and a PowerShell installer for SQL Server
index and execution-plan analysis. The package installs review-oriented
workflows; it does not connect to SQL Server, create an index, or modify a
database.

## What is included

| Component | Purpose |
|---|---|
| `sqlserver-index-analysis` | Evidence-backed conventional, covering, filtered, POC, and FPOC index analysis. |
| `query-plan-analysis` plugin | Actual SQL Server execution-plan analysis from [Erik Darling's `sqlserver-query-plans` plugin](https://github.com/erikdarlingdata/claude-plugins/tree/main/plugins/sqlserver-query-plans), installed separately by the installer. |
| `ComparePlans_v1.py` | Optional, deterministic offline comparison of two to four actual plan files, including aggregate and per-statement evidence. |
| `usp_IndexAnalysis.sql` | Optional SQL Server stored procedure for index analysis; install manually in a chosen database, preferably a DBA utility database. |
| `copilot-subagent-governance` | Advisory lanes, reporting, and guardrails for Copilot subagents. |
| `copilot-open-asks` | Tracks unresolved task questions and decisions. |
| `copilot-session-recovery` | Uses native session recovery and compaction commands. |
| `copilot-usage-budget` | Uses native usage and limit controls for budget-aware work. |

The skills are personal Copilot skills installed under `~\.copilot\skills`.
They can be used automatically when a request matches their description or
explicitly with `/SKILL-NAME`.

## Requirements

- Python 3 is required for the plan extractor used by
  `query-plan-analysis` and for the optional `ComparePlans_v1.py` tool.
  Python 3.13.17 was used for package testing.
- GitHub Copilot CLI must be installed and authenticated.
- Windows PowerShell is required to run the package installer.

## Quick start

1. Install Python 3 and GitHub Copilot CLI, then authenticate Copilot with
   GitHub.
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
validation, and uninstall steps. See [PROMPTS.md](PROMPTS.md) for the
copy-ready index-analysis prompts and required artifacts.

## SQL Server index workflow

For an index decision, provide the query text, representative parameter values,
an **actual** execution plan, existing indexes, and Query Store evidence when
available. Use both skills as a layered workflow when plan diagnosis and index
selection are needed:

```text
Use /query-plan-analysis and /sqlserver-index-analysis to analyze this query
and actual plan, then determine whether one index is justified.
```

`query-plan-analysis` is the plan-diagnosis authority: it extracts the plan
digest and applies its timing, warnings, cardinality, parallelism, index, and
rewrite references as applicable. `sqlserver-index-analysis` then uses that
evidence for the package's distinct overlap analysis, POC/FPOC design,
`usp_IndexAnalysis` interpretation, one-candidate limit, and validation rules.
The package does not copy or replace Erik Darling's plugin references.

`sqlserver-index-analysis` can use `[YourUtilityDatabase].dbo.usp_IndexAnalysis`
only when the user explicitly authorizes access and supplies complete actual
`SHOWPLAN_XML`. Its output is candidate evidence, not executable DDL.

## Optional `usp_IndexAnalysis` procedure

The package includes `usp_IndexAnalysis.sql`. It is not deployed by
`Install-GitHubCopilotMSSQL.ps1`; download and run it manually in any existing
database you choose. A dedicated DBA utility database, such as `DBAdmin`, is
recommended so the procedure can analyze other databases on the same instance
without being coupled to an application database.

See [USP-INDEXANALYSIS.md](USP-INDEXANALYSIS.md) for download, permissions,
manual installation, and verification steps.

## Optional `ComparePlans_v1.py`

`ComparePlans_v1.py` is the deterministic, offline companion to the comparison
prompt. Copilot provides qualitative diagnosis and recommendations; the script
produces reproducible aggregate and per-statement measurements that support the
comparison tables and result layout.

It is optional and is not included in `Install-GitHubCopilotMSSQL.ps1`. By
default it reads only local actual plan files and needs no database connection.
Its opt-in `--analyze-indexes` mode can connect to SQL Server to run
`usp_IndexAnalysis`; review the usage documentation before enabling that mode.

```powershell
python .\ComparePlans_v1.py baseline.sqlplan candidate.sqlplan --format md
```

See the upstream [usage guide](https://github.com/cbragdon/sql-perf-diagnostics/blob/main/USAGE-ComparePlans_v1.md)
and [recommendations catalog](https://github.com/cbragdon/sql-perf-diagnostics/blob/main/ComparePlans-Recommendations-Catalog.md)
for complete usage and recommendation details. Provide the original plan files
to Copilot with the script output; the output supports analysis but does not
replace plan evidence.

## Update the plan-analysis plugin

Check the installed plugin and its version:

```powershell
copilot plugin list
```

When an update is available, update Erik Darling's plan-analysis plugin:

```powershell
copilot plugin update sqlserver-query-plans
```

Then start a new Copilot CLI session, or run `/skills reload`, so Copilot loads
the updated skill and its references.

## Upstream attribution

The `query-plan-analysis` capability is provided by
[Erik Darling's `sqlserver-query-plans` plugin](https://github.com/erikdarlingdata/claude-plugins/tree/main/plugins/sqlserver-query-plans).
This repository installs that public GitHub Copilot plugin; it does not claim
authorship of or bundle its source code.

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
|-- PROMPTS.md
|-- ComparePlans_v1.py
|-- plan_extract.py
|-- LICENSE-plan_extract.txt
|-- scripts/sync_erik_plan_extract.py
|-- scripts/Update-SqlServerQueryPlanPlugin.ps1
|-- scripts/Register-SqlServerQueryPlanPluginUpdater.ps1
|-- .github/workflows/sync-erik-plan-extract.yml
|-- .github/workflows/watch-erik-plan-references.yml
|-- USP-INDEXANALYSIS.md
|-- usp_IndexAnalysis.sql
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
