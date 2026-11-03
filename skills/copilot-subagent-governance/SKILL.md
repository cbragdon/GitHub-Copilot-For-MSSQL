---
name: copilot-subagent-governance
description: Establish advisory guardrails for GitHub Copilot CLI subagents. Use when coordinating multiple agents or when asked to enforce agent lanes, model policy, concurrency, context, fencing, watchdogs, or reporting.
---

# Copilot subagent governance

This skill provides advisory controls. It cannot intercept subagent creation,
read child token telemetry, or block an already-started agent.

## Before delegation

- Handle a task directly when it can be resolved with a small number of focused
  tool calls. Delegate only bounded work that needs separate context.
- Define a distinct lane for each agent: objective, allowed scope, expected
  evidence, and a stopping condition. Never assign overlapping investigation.
- Use the current `/subagents` configuration. Do not select dated or
  version-pinned model IDs. Override a model only when the user explicitly
  requires it.
- Do not invent a concurrency, time, or AI-credit limit. If the user supplies a
  limit, set it through the applicable Copilot controls before delegation.
- Do not delegate work to bypass permissions, approvals, safety checks, or
  review requirements.

## While agents run

- Keep work independent; do not wake an agent repeatedly for status updates.
- Avoid nested delegation unless it is necessary to complete the assigned lane.
- Limit each agent to evidence needed for its objective. Prefer summaries and
  targeted extracts over full files, logs, or plans.
- When a result is available, read it once and either use it or request one
  bounded follow-up in the same lane.
- Stop agents that have become irrelevant, duplicate another lane, or cannot
  make progress with their assigned evidence.

## Required agent report

Require each agent to return:

1. Outcome: completed, blocked, or inconclusive.
2. Evidence: files, commands, measurements, or source locations.
3. Changes made, if any.
4. Remaining risk or the precise missing input.

## Completion gate

Before responding, reconcile all agent reports against the original request.
State incomplete or unenforceable controls plainly. Do not claim that advisory
guidance automatically prevented a subagent action.
