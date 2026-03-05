# task-reliability-guard

[![English](https://img.shields.io/badge/Language-English-blue)](./README.md)
[![中文](https://img.shields.io/badge/%E8%AF%AD%E8%A8%80-%E4%B8%AD%E6%96%87-red)](./README.zh-CN.md)

A reliability-first OpenClaw skill for long-running and restart-prone tasks.

It enforces:
- start/progress acknowledgements before heavy actions
- serial execution on critical paths
- checkpoint-before-restart and resume-after-restart workflow
- concise normal-mode output (debug traces only when explicitly requested)

## Install

```bash
cd ~/.openclaw/workspace/skills
git clone https://github.com/mikutea/task-reliability-guard-skill.git task-reliability-guard
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
