# GitHub Copilot SQL Server prompts

These prompts use the installed GitHub Copilot skills to diagnose an actual
SQL Server execution plan and make one evidence-backed index decision. They do
not execute SQL DDL.

The `query-plan-analysis` skill is provided by
[Erik Darling's `sqlserver-query-plans` plugin](https://github.com/erikdarlingdata/claude-plugins/tree/main/plugins/sqlserver-query-plans).
This repository installs the plugin through GitHub Copilot CLI and does not
bundle or claim authorship of its source.

## Required artifacts

Provide the following artifacts with either prompt:

| Artifact | Requirement |
|---|---|
| Query text | The complete statement or stored-procedure statement under investigation. Remove confidential literals when necessary. |
| Parameters | Representative runtime parameter values and the execution scenario they represent. |
| Execution plan | A complete **actual** `.sqlplan` file or actual `SHOWPLAN_XML` document. Do not use an estimated plan to claim what was slow. Attach the plan file rather than pasting raw XML. |
| Existing indexes | Key columns and sort direction, included columns, filters, and uniqueness for every referenced table. |

Supply these artifacts when available:

| Artifact | Why it matters |
|---|---|
| Query Store evidence | Confirms execution frequency, regressions, and whether a candidate helps the broader workload. |
| `usp_IndexAnalysis` `REALIGN` output | Produces a candidate after authorized plan analysis; it is evidence, not final DDL. |
| Table sizes and write profile | Reveals index storage and insert, update, and delete maintenance cost. |

Never include credentials, connection strings, production secrets, or data you
are not authorized to share. Execution plans and parameter values can reveal
object names and sensitive values.

## Prompt: plan diagnosis and index selection

Use this when an actual plan is available and you need both a performance
diagnosis and an index recommendation.

```text
Use /query-plan-analysis and /sqlserver-index-analysis.

Analyze the supplied SQL Server query, actual execution plan (.sqlplan or
SHOWPLAN_XML), existing indexes, Query Store evidence, and
dbo.usp_IndexAnalysis REALIGN output when supplied.

First determine what was actually slow and why using runtime evidence only:
operator self elapsed/CPU time, actual versus estimated rows per execution,
warnings, spills, memory grants, compiled versus runtime parameters, and
parallelism. Do not use estimated cost percentages as measurements. Do not
call a scan or key lookup bad without row-count and runtime evidence. Treat
missing-index suggestions and generated index DDL only as hypotheses.

Then recommend at most one index only if it resolves a demonstrated Sort,
Group By, window-processing operation, repeated key lookup, selective scan, or
eager index spool and does not duplicate or unnecessarily overlap an existing
index.

For a POC/FPOC candidate, validate key order as:
1. equality or applicable filter columns;
2. GROUP BY and PARTITION BY columns;
3. ORDER BY columns, preserving ASC/DESC direction;
4. INCLUDE columns only when required for coverage.

If GROUP BY and PARTITION BY differ, justify their combined order from the
actual plan's grouping, window, and Sort operators. Use a filtered index only
when its predicate is stable, selective, and logically implied by the query.
Consider storage and write-maintenance cost across the broader workload.

Return:
- a concise root-cause finding with cited plan evidence;
- either one proposed CREATE INDEX statement or "no index recommended";
- key order, INCLUDE columns, and filter rationale;
- expected plan change;
- write, maintenance, and overlap risks; and
- a validation plan comparing baseline and candidate actual plans using elapsed
  time, CPU, logical reads, spills, lookup executions, and Query Store
  regression data.

Do not execute DDL. If the plan is estimated or evidence is insufficient,
recommend no index and explain what artifact is missing.
```

## Prompt: index selection only

Use this when the plan has already been summarized, or you want the index skill
to assess supplied evidence without a separate plan-diagnosis request.

```text
Use /sqlserver-index-analysis.

Evaluate this SQL Server query for one evidence-backed index recommendation. I
am providing the query, representative parameter values, actual plan digest,
existing indexes, Query Store evidence, and dbo.usp_IndexAnalysis REALIGN
output where available.

Assess conventional nonclustered, covering, filtered, POC, and FPOC candidates.
Return at most one proposed CREATE INDEX statement or "no index recommended,"
with key order, INCLUDE/filter rationale, expected plan change, write and
overlap risk, and validation steps. Do not execute DDL.

If the supplied plan is estimated, incomplete, or does not show a demonstrated
indexable problem, do not infer a bottleneck or recommend an index. State the
missing artifact or evidence instead.
```

## Using `usp_IndexAnalysis`

Only run `[YourUtilityDatabase].dbo.usp_IndexAnalysis` when complete actual
`SHOWPLAN_XML` is available and the user explicitly authorizes access to the
intended SQL Server. The procedure can be installed in any existing database;
a dedicated utility database such as `DBAdmin` is recommended. See
[USP-INDEXANALYSIS.md](USP-INDEXANALYSIS.md) for manual installation.

Use:

```sql
EXEC [YourUtilityDatabase].dbo.usp_IndexAnalysis
    @StatementPlanXml = @PlanXml,
    @Output = 'REALIGN',
    @RankingSource = 'BLEND';
```

Do not guess a server, database, or authentication method. Treat the output as
candidate evidence only; never execute generated `CREATE INDEX`, `ALTER INDEX`,
or `DROP INDEX` statements without independent review and validation.
