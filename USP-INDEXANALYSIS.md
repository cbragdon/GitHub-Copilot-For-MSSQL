# `usp_IndexAnalysis` procedure

`usp_IndexAnalysis.sql` is an optional stored procedure that analyzes index
metadata and workload evidence for databases on the same SQL Server instance.
It is sourced from [SQL Server performance diagnostics](https://github.com/cbragdon/sql-perf-diagnostics)
and included here for use with the Copilot index-analysis workflow.

The GitHub Copilot installer does **not** deploy this procedure. Download and
install it manually so you control the target instance, database, permissions,
and timing.

## Choose an installation database

The procedure can be installed in **any existing database** on the SQL Server
instance. A dedicated DBA utility database, such as `DBAdmin`, is recommended:

- It separates administrative tooling from application databases.
- The procedure can analyze another database through `@DatabaseName`.
- It can analyze all eligible databases on the same instance through
  `@AllDatabases = 1`, subject to the caller's permissions.

Do not install it in an application database unless that placement is an
intentional operational decision.

## Download

Download the script from this repository:

```text
https://github.com/cbragdon/GitHub-Copilot-For-MSSQL/raw/main/usp_IndexAnalysis.sql
```

Or clone the repository and use the included file:

```powershell
git clone https://github.com/cbragdon/GitHub-Copilot-For-MSSQL.git
Set-Location .\GitHub-Copilot-For-MSSQL
```

## Install manually

### SQL Server Management Studio

1. Connect to the intended SQL Server instance.
2. Select the chosen existing installation database, such as `DBAdmin`.
3. Open `usp_IndexAnalysis.sql`.
4. Confirm the query window database is the intended installation database.
5. Execute the script.

The script uses `CREATE OR ALTER PROCEDURE`, so it can create the procedure or
replace its definition in the selected database. It contains no `USE` statement;
the database selected in the query window controls where it is installed.

Before creating or altering the procedure, the script sets `ANSI_NULLS`,
`ANSI_PADDING`, `ANSI_WARNINGS`, `ARITHABORT`,
`CONCAT_NULL_YIELDS_NULL`, and `QUOTED_IDENTIFIER` to `ON`, and
`NUMERIC_ROUNDABORT` to `OFF`.

### sqlcmd

Use Windows Integrated authentication and replace the instance and database
values as needed:

```powershell
sqlcmd `
  -S 'YOUR-SQL-INSTANCE' `
  -d 'DBAdmin' `
  -E `
  -C `
  -b `
  -i .\usp_IndexAnalysis.sql
```

The command does not create the target database. Create or select the utility
database through your normal DBA process before running the script.

## Permissions

To install the procedure, the deployment identity needs permission to create a
procedure in the chosen database and alter the `dbo` schema when replacing an
existing version. `db_ddladmin` or `db_owner` typically covers those deployment
permissions.

Permissions to run the procedure later depend on the target databases and
options used. SQL Server metadata and plan analysis commonly require `VIEW
SERVER STATE` (or `VIEW SERVER PERFORMANCE STATE` on newer versions), `VIEW
DATABASE STATE`, and `SHOWPLAN`. Grant only the rights required by your
instance and usage scenario.

## Verify

Run this in the chosen installation database:

```sql
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    name AS ProcedureName
FROM sys.procedures
WHERE object_id = OBJECT_ID(N'dbo.usp_IndexAnalysis', N'P');
```

The result should show `dbo` and `usp_IndexAnalysis`.

## Use with Copilot

Once installed in a utility database, provide the database name in the task and
allow access explicitly. For example:

```sql
EXEC [DBAdmin].dbo.usp_IndexAnalysis
    @StatementPlanXml = @PlanXml,
    @Output = 'REALIGN',
    @RankingSource = 'BLEND';
```

The procedure output is candidate evidence only. Review its recommendation
against the actual plan, existing indexes, broader workload, and write cost
before executing any generated index DDL.
