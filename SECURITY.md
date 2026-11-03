# Security policy

## Supported versions

Only the latest commit on `main` is supported. Fixes are made there; older
copies are not patched separately.

## Reporting a vulnerability

Report security problems privately through the repository's **Security** tab:

1. Choose **Report a vulnerability**.
2. Describe the affected file, how to reproduce the issue in a test
   environment, and what an attacker could gain.
3. Remove server names, database names, logins, query text, plans, parameter
   values, access tokens, and other private information.

## Security boundaries

The project is designed to keep these boundaries:

- The installer does not accept or store database credentials.
- The skills do not connect to SQL Server by themselves.
- `usp_IndexAnalysis.sql` is not executed by the installer. A user manually
  chooses its database and authentication context before deployment.
- The installer uses Copilot CLI's reviewed plugin installation flow.
- Index DDL is never automatically executed.
- The public `query-plan-analysis` capability comes from
  [Erik Darling's `sqlserver-query-plans` plugin](https://github.com/erikdarlingdata/claude-plugins/tree/main/plugins/sqlserver-query-plans).
  Report vulnerabilities in that plugin to its upstream maintainer as well as
  documenting the impact here.

## Out of scope

Vulnerabilities in GitHub Copilot CLI, GitHub authentication, SQL Server,
PowerShell, or Windows should be reported to their respective vendors unless
this repository's code introduces the issue.
