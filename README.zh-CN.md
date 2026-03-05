# task-reliability-guard

[![English](https://img.shields.io/badge/Language-English-blue)](./README.md)
[![中文](https://img.shields.io/badge/%E8%AF%AD%E8%A8%80-%E4%B8%AD%E6%96%87-red)](./README.zh-CN.md)

一个面向 OpenClaw 的“任务可靠性”技能，适合长任务、重启中断、关键配置变更等场景。

核心能力：
- 开工/进度回执先行
- 关键路径串行执行
- 重启前 checkpoint、重启后自动恢复
- 正常模式下无痕输出（调试信息仅在显式开启 debug 时显示）

## 安装

```bash
cd ~/.openclaw/workspace/skills
git clone https://github.com/mikutea/task-reliability-guard-skill.git task-reliability-guard
openclaw skills info task-reliability-guard
```

期望结果：`✓ Ready`

## 文件说明

- `SKILL.md`：技能规则
- `scripts/restart-with-checkpoint.sh`：重启前强制 checkpoint 的辅助脚本
- `scripts/resume-guard.sh`：重启后恢复触发脚本

## 推荐接入（可选）

建议在 gateway 的 systemd service 里加 `ExecStartPost`，让每次重启后只触发一次恢复检查：

```ini
ExecStartPost=/bin/bash -lc "sleep 8; ~/.openclaw/workspace/skills/task-reliability-guard/scripts/resume-guard.sh"
```

## 隐私与安全

仓库已去除个人隐私信息、API Key、Token 等敏感数据。
如需定制，请通过环境变量注入：

- `WORKSPACE_DIR`（默认 `~/.openclaw/workspace`）
- `RECOVERY_CHANNEL`（默认 `feishu`）
- `RECOVERY_TARGET`（可选，例如 `user:open_id`）
