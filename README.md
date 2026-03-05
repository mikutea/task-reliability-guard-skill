# task-reliability-guard

A reliability-first OpenClaw skill for long-running and restart-prone tasks.

It enforces:
- start/progress acknowledgements before heavy actions
- serial execution on critical paths
- checkpoint-before-restart and resume-after-restart workflow
- concise normal-mode output (debug traces only when explicitly requested)

## Install

```bash
cd ~/.openclaw/workspace/skills
git clone <YOUR_GITHUB_REPO_URL> task-reliability-guard
openclaw skills info task-reliability-guard
```

Expected: `✓ Ready`

## Files

- `SKILL.md` — skill rules
- `scripts/restart-with-checkpoint.sh` — guarded restart helper
- `scripts/resume-guard.sh` — restart resume trigger script

## Recommended wiring (optional)

Use `ExecStartPost` in your gateway systemd unit to trigger `resume-guard.sh` once after each restart.

Example:
```ini
ExecStartPost=/bin/bash -lc "sleep 8; ~/.openclaw/workspace/skills/task-reliability-guard/scripts/resume-guard.sh"
```

## Privacy & security

This repository intentionally contains no personal IDs, tokens, or API keys.
Set these at runtime via environment variables if needed.

- `WORKSPACE_DIR` (default: `~/.openclaw/workspace`)
- `RECOVERY_CHANNEL` (default: `feishu`)
- `RECOVERY_TARGET` (optional, e.g. `user:open_id`)
