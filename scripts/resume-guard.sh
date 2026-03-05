#!/usr/bin/env bash
set -euo pipefail

CKPT="/home/openclaw/.openclaw/workspace/memory/runtime-task-state.json"

# No checkpoint => nothing to do
if [[ ! -f "$CKPT" ]]; then
  exit 0
fi

openclaw agent \
  --agent main \
  --message "检查 /home/openclaw/.openclaw/workspace/memory/runtime-task-state.json：若不存在或 needsResume!=true，回复 NO_REPLY。若需要恢复：1) 读取 taskId 与 nextAction；2) 发送一条简短恢复提示到 channel=feishu,target=user:ou_255da7002cf061b97b019b275e0bf578（不要输出调试细节）；3) 执行 nextAction：仅支持 task:: 前缀，将后续文本作为待执行任务并完成；其他前缀一律视为需人工续跑并附 taskId/nextAction；4) 成功后将 needsResume=false 并删除 checkpoint；5) 发送一条简短完成提示（不要输出“正在恢复任务/恢复完成”这类调试文案）。" \
  --json >/tmp/openclaw-resume-guard.json 2>&1 || true
