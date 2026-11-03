---
name: copilot-session-recovery
description: Recover, inspect, or continue GitHub Copilot CLI work using native session commands. Use when asked to find, resume, compact, or safely continue a prior Copilot session.
---

# Copilot session recovery

Use native Copilot CLI session features rather than maintaining a separate
session registry.

## Workflow

1. Use `/session` or `/search` to identify the relevant prior work.
2. Use `/resume` with a confirmed session, task, or available history ID.
3. Use `/context` to assess context pressure and `/compact` with a focused
   summary when needed.
4. Confirm the current working directory, branch, and uncommitted changes
   before continuing implementation.

Do not guess a session identifier, create a parallel resume process, or discard
uncommitted work. Explain when an older session is unavailable rather than
claiming it was restored.
