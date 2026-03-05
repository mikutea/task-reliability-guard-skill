#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
RECOVERY_CHANNEL="${RECOVERY_CHANNEL:-feishu}"
RECOVERY_TARGET="${RECOVERY_TARGET:-}"
CKPT="$WORKSPACE_DIR/memory/runtime-task-state.json"

if [[ ! -f "$CKPT" ]]; then
  exit 0
fi

TARGET_ARG=""
if [[ -n "$RECOVERY_TARGET" ]]; then
  TARGET_ARG=", target=$RECOVERY_TARGET"
fi

openclaw agent \
  --agent main \
  --message "Check $CKPT. If missing or needsResume!=true, reply NO_REPLY. If recovery is needed: (1) read taskId and nextAction; (2) send one brief recovery notice via message tool (channel=$RECOVERY_CHANNEL$TARGET_ARG) with no debug details; (3) execute nextAction and only support task:: prefix; unknown prefix => ask for manual resume with taskId/nextAction; (4) on success set needsResume=false and delete checkpoint; (5) send one brief completion notice without debug traces." \
  --json >/tmp/openclaw-resume-guard.json 2>&1 || true
