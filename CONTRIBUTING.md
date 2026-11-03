# Contributing

Issues and pull requests are welcome. For anything beyond a small correction,
open an issue first so the approach can be agreed before implementation.

## Reporting a problem

Include:

- GitHub Copilot CLI version (`copilot --version`).
- PowerShell version (`$PSVersionTable.PSVersion`).
- The command or skill invocation used.
- The full error text and whether the skill was installed as a personal or
  project skill.

Remove private information before posting: server names, database names, login
names, query text, parameter values, execution plans, and access tokens.

## Pull requests

- Branch from `main` and keep one focused change per pull request.
- Describe what changed, why it is needed, and every validation command run.
- Do not report a test as passed when it was not run.
- Update README or installation documentation when behavior changes.
- Keep personal skills platform-neutral where possible and do not add
  credentials, connection strings, or automatic database changes.

## Rules every change keeps

- The installer uses GitHub Copilot CLI commands, not Claude APIs.
- Skills do not execute SQL DDL or connect to a database without explicit
  authorization in the active task.
- Generated index recommendations are review material, not commands to run.
- Hook-like controls are described as advisory unless Copilot exposes an
  enforceable native capability.

## License

By contributing, you agree that your contribution is licensed under the
[MIT License](LICENSE).
