#!/usr/bin/env bash
set -euo pipefail

# Usage:
# restart-with-checkpoint.sh <taskId> <nextAction> [phase]
# nextAction example:
#   task::continue unfinished task after restart

WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
CKPT_DIR="$WORKSPACE_DIR/memory"
CKPT_FILE="$CKPT_DIR/runtime-task-state.json"

TASK_ID="${1:-}"
NEXT_ACTION="${2:-}"
PHASE="${3:-progress}"

if [[ -z "$TASK_ID" || -z "$NEXT_ACTION" ]]; then
  echo "Usage: $0 <taskId> <nextAction> [phase]" >&2
  exit 2
fi

mkdir -p "$CKPT_DIR"
cat > "$CKPT_FILE" <<JSON
{
  "taskId": "$TASK_ID",
  "startedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "phase": "$PHASE",
  "nextAction": "$NEXT_ACTION",
  "lastAckSent": true,
  "needsResume": true
}
JSON

python3 - <<'PY'
import json, os
workspace = os.environ.get('WORKSPACE_DIR') or os.path.expanduser('~/.openclaw/workspace')
p = os.path.join(workspace, 'memory', 'runtime-task-state.json')
with open(p, 'r', encoding='utf-8') as f:
    d = json.load(f)
for k in ('taskId','phase','nextAction','needsResume'):
    if k not in d:
        raise SystemExit(f'missing field: {k}')
if d.get('needsResume') is not True:
    raise SystemExit('needsResume must be true before restart')
print('checkpoint validated')
PY

openclaw gateway restart
