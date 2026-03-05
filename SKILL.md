---
name: task-reliability-guard
description: "Ensure reliable task execution with natural acknowledgements and failure recovery. Use for multi-step operations, long-running work, gateway/plugin/config changes, and any task with timeout/restart/session interruption risk."
---

# Task Reliability Guard

## Execution Protocol

1. Send an immediate natural acknowledgement before starting work.
2. State a short plan and expected time when task is non-trivial.
3. For tasks >60s, send periodic progress updates every 2-5 minutes.
4. If a step exceeds timeout (90s/180s depending on tool), report possible stall and next action.
5. Retry once for transient failures; then switch to fallback path and report.
6. Never silently end a task without a final completion receipt.

## Output Verbosity Mode

- **Normal mode (default):** concise user-facing updates only. Do **not** output debug/status lines such as `进度：...`, `正在恢复任务：...`, `恢复完成：...`, or checkpoint internals.
- **Debug mode:** include detailed phase markers, checkpoint internals, and recovery traces.
- Only enable Debug mode when user explicitly asks for debug/tracing output.

## Feishu Delivery Reliability (Mandatory)

1. For Feishu tasks that require tool execution (including configuration/check/diagnosis tasks), send **start** and **progress** updates via `message` (`action=send`) before running next heavy step.
2. Do not start `exec`/multi-step actions before start acknowledgement is sent.
3. If task duration exceeds 45-60 seconds, send at least one progress update via `message`.
4. Keep updates short and natural in Normal mode:
   - start: received + plan + ETA
   - progress: current step + blocker (if any) + next ETA
5. The **final completion summary should use normal assistant reply** (not mandatory `message`), matching existing conversation flow.

## Critical-Path Safety

1. For gateway/config/credential/reply-delivery tasks, execute tools serially (one step, one validation).
2. Do not use `multi_tool_use.parallel` on critical path.
3. Avoid mid-chain gateway restart. If restart is required, notify first and provide ETA.

## Restart-Resume Protocol (Mandatory)

### Restart preflight gate (hard requirement)
1. Before any gateway restart in an in-flight task, checkpoint must exist and pass validation; otherwise restart is blocked.
2. Required checkpoint fields: `taskId`, `phase`, `nextAction`, `needsResume=true`.
3. If checkpoint invalid/missing, send blocked notice and fix checkpoint first.
4. Only maintenance restarts without in-flight task may skip checkpoint.

### Before restart (checkpoint)
1. Persist checkpoint file: `memory/runtime-task-state.json`.
2. Minimum fields:
   - `taskId`
   - `startedAt`
   - `phase` (start|progress|finish)
   - `nextAction`
   - `lastAckSent` (true/false)
   - `needsResume` (true)
3. Send pre-restart notice with reason, impact, and ETA.

### After restart (recovery)
1. First check gateway health (`openclaw gateway status`).
2. If checkpoint exists and `needsResume=true`:
   - Send a concise recovery notice in Normal mode (no debug labels)
   - Resume from `nextAction` (do not restart from scratch unless required)
   - Send one concise progress update after first resumed step
3. On success, set `needsResume=false` and write completion timestamp.
4. If resume fails, send blocked status + fallback plan.
5. After task completion, clear checkpoint immediately (delete `memory/runtime-task-state.json` or mark archived) to prevent duplicate replay on future restarts.

### Auto-resume trigger (restart-only)
- Do not use periodic polling for resume guard.
- Trigger resume guard only once on each gateway start/restart (e.g., service ExecStartPost hook).
- Resume guard must be disabled as a scheduler and invoked only by restart trigger.

### Resume action rule (action-based)
- `nextAction` must be executable action only: `task::<instruction>`.
- Remove legacy `answer::` compatibility to avoid drift and hidden replay behavior.
- In Normal mode, do not output debug traces like “正在恢复任务…/恢复完成…”.
- If `nextAction` missing/unknown, send manual-resume request with `taskId` + `nextAction` and keep checkpoint for manual handling.

### Recovery checks
- Verify pending user-visible reply is not missed.
- Verify interrupted task has either resumed or been explicitly closed.
- Never end restart cycle without a recovery/update message.

## Reply Style

- Use natural human language, not rigid template labels.
- Keep updates short and specific.
- Include current step, blockers (if any), and next ETA.

## Completion Receipt Standard

Final message must include:
- Result
- Completion status (done/partial/blocked)
- Remaining risk
- Next recommended action
