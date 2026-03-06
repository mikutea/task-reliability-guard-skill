---
name: task-reliability-guard
description: "Ensure reliable execution for multi-step or long-running tasks, especially gateway/config/restart paths. Enforce start/progress/final acknowledgement flow, no-silent-failure behavior, and restart-safe recovery."
---

# Task Reliability Guard

## Core Goal

Make execution reliable **and** human.

- Reliable: no silent drops, no half-finished chains, no missing final result.
- Human: natural language updates, no rigid tool-ticket tone.

## Execution ToDo (Hard Rule)

For every execution-type task (needs tools), enforce this checklist:

- [ ] Start acknowledgement sent via `message`
- [ ] Mid-progress acknowledgement sent via `message`
- [ ] If any acknowledgement was missed: pause → backfill → continue execution silently (no awkward extra chatter)
- [ ] Final completion sent as normal assistant reply (not mandatory `message`)

Execution law:
`start(message) -> progress(message) -> final(normal reply)`.
If any step is missing, backfill first, then continue. **Never leave task unfinished.**

## Tone Guard (Hard Rule)

- Keep acknowledgement language natural and warm.
- Avoid rigid labels like “开工回执/中期回执” in user-facing text.
- Prefer human phrasing, e.g.:
  - start: “我开干啦，先帮你…”
  - progress: “进展来啦，现在做到…”
- Serious tasks can be concise/professional, but must not degrade into mechanical template voice.

## Critical-Path Safety

For gateway/config/credential/reply-delivery/restart paths:

1. Execute tools serially (one step, one validation).
2. Do not use `multi_tool_use.parallel`.
3. No mid-chain restart.
4. Restart must be terminal action of that turn.

## Restart-Resume Protocol (Mandatory)

### Pre-restart
1. Send pre-restart user notice (natural wording + short ETA).
2. Ensure an in-flight checkpoint exists before restart.
3. If checkpoint invalid/missing, block restart and repair first.

Checkpoint file: `memory/runtime-task-state.json`
Required fields:
- `taskId`
- `phase`
- `nextAction`
- `needsResume=true`

### Restart commit mode
- Restart is the last tool action in that turn.
- After restart call, do not run any more tools in same turn.

### Post-restart (next turn only)
1. Verify gateway health first.
2. If checkpoint has `needsResume=true`, resume from `nextAction` (not from scratch unless required).
3. Send one concise progress update after first resumed step.
4. Finish task and send normal final summary.
5. Clear checkpoint (or archive) immediately after completion.

## Failure Handling

- Transient failure: retry once.
- If still failing: switch to fallback path and tell user what failed + next action.
- Never end with silence.

## Completion Standard

Final reply should include:
- result,
- status (done / partial / blocked),
- remaining risk (if any),
- recommended next step.
