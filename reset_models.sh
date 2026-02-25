#!/bin/bash
set -e

echo "=== OpenClaw 一键清空所有模型 ==="

openclaw config unset agents.defaults.models
openclaw config unset agents.defaults.model.primary

echo "已清空模型配置，正在重启网关..."
openclaw gateway restart

echo "当前模型列表："
openclaw models list

echo "=== 完成，所有模型已删除 ==="
