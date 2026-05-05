---
description: Retrospective on project harness files, subsystem READMEs, and docs
---

Review the current conversation for opportunities to improve the project's harness files.

## Scope

Only project-level files:

- `CLAUDE.md`
- `**/README.md` — all subsystem READMEs in the repo
- `docs/` — architecture and reference docs
- `.claude/skills/` — project-level skills
- `.claude/commands/` — project-level commands

Do NOT review global files (`~/.claude/skills/`, `~/.claude/instructions/`, `~/.claude/commands/`).

## What to Look For

Each finding must be grounded in something that actually happened in the conversation.
No hypothetical improvements.

- **Corrections** — the user told you to do something differently
- **Retries** — you took a wrong path and had to backtrack
- **Misunderstandings** — you misinterpreted a pattern or convention
- **Missing guidance** — you had to ask something a harness file could have answered
- **Friction** — unnecessary back-and-forth that better docs would prevent

## Process

1. Review the conversation for findings (if none, say so and stop)
1. For each finding, read the relevant harness file and show:
   - **File**: which file to update
   - **Issue**: what happened in the conversation that revealed this
   - **Proposed edit**: the specific text change (old → new)
1. Wait for the user to approve, reject, or modify each one
1. Apply approved edits
1. Summarize what changed
