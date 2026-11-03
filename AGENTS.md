# Maintainer guidance

This repository packages GitHub Copilot tooling for evidence-based SQL Server
plan and index analysis. Keep changes useful to people: explain the purpose of
an instruction or safety rule, not only the command to run.

## Boundaries

- Erik Darling's `sqlserver-query-plans` plugin is external upstream work.
  Preserve attribution and do not copy its skills, references, or other source
  into this repository.
- `plan_extract.py` is the sole vendored exception. Preserve its license and
  update it only through the extractor synchronization workflow.
- Do not add SQL Server deployment, credentials, connection strings, or schema
  changes to `Install-GitHubCopilotMSSQL.ps1`. The installer manages personal
  Copilot skills and the external plugin only.
- `usp_IndexAnalysis.sql` is manually deployed by the user. Preserve its
  source formatting and ANSI settings; do not reformat its upstream whitespace.

## Skill and prompt changes

- Keep `skills/sqlserver-index-analysis/SKILL.md` focused on index decisions.
  It must use `query-plan-analysis` for plan diagnosis and its applicable
  upstream references before recommending an index.
- Keep the packaged skill byte-identical to
  `~\.copilot\skills\sqlserver-index-analysis\SKILL.md` after changing it.
- Keep `PROMPTS.md` aligned with the skills. Require actual-plan evidence,
  representative parameters, existing indexes, and non-production validation.
  Never direct users to execute generated DDL.

## Synchronization and local notes

- The extractor workflow opens a review pull request; it must not update
  `main` directly.
- The reference watcher opens an issue when Erik's upstream reference files
  change. It reports changes; it does not vendor or automatically adopt them.
- `Sync.md` is an ignored personal reminder file. Do not add it to commits.

## Validation

- For installer changes, run a PowerShell parse check and `-WhatIf`; run the
  installer when its deployment behavior changes.
- For Python changes, run the smallest applicable command, such as
  `python ComparePlans_v1.py --help`.
- For documentation, check local Markdown links and run `git diff --check`.
- Preserve `.gitattributes` protections for vendored and source-derived files.
