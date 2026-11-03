---
name: copilot-usage-budget
description: Plan and monitor GitHub Copilot CLI work within a user-specified usage budget. Use when asked to limit AI credits, manage token or agent budget, or reduce expensive multi-agent work.
---

# Copilot usage budget

Use native `/limits` and `/usage` controls when the user has supplied a budget
or asks for budget visibility.

## Workflow

1. Record the budget the user specified: AI credits, time, or agent count.
2. Set only those explicit limits; never invent a numeric ceiling.
3. Prefer direct investigation and focused tool calls over broad delegation.
4. Use `/usage` and `/limits` to report available native telemetry.
5. Before starting costly work, explain the expected scope and choose the
   smallest approach that can answer the request.

Copilot does not expose a universal hook for exact shared child-agent token
accounting or automatic budget enforcement. State that limitation clearly and
stop or narrow work when the configured native limit is reached.
