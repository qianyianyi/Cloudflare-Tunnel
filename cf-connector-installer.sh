#!/bin/bash

# 检查是否为 Root 权限
if [ "$(id -u)" != "0" ]; then
    echo "错误: 请使用 root 权限运行此脚本 (sudo -i)"
    exit 1
fi

echo "--- 1. 开始安装 Cloudflare Tunnel ---"

# 自动检测架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        BINARY_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
        ;;
    aarch64)
        BINARY_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
        ;;
    *)
        echo "不支持的架构: $ARCH"; exit 1
        ;;
esac

# 下载并安装
curl -L --output /usr/local/bin/cloudflared $BINARY_URL
chmod +x /usr/local/bin/cloudflared

---

echo "--- 2. 配置隧道 Token ---"
read -p "请输入你的 Cloudflare Tunnel Token: " CF_TOKEN
if [ -z "$CF_TOKEN" ]; then
    echo "Token 不能为空，脚本退出。"
    exit 1
fi

# 安装系统服务
/usr/local/bin/cloudflared service install $CF_TOKEN
systemctl daemon-reload
systemctl start cloudflared
systemctl enable cloudflared

---

echo "--- 3. 配置每日自动更新任务 ---"

# 创建更新脚本
cat << 'EOF' > /usr/local/bin/update-cloudflared.sh
#!/bin/bash
echo "正在检查 cloudflared 更新..."

# 使用 cloudflared 自带的更新命令
/usr/local/bin/cloudflared update

# 更新后重启服务以确保生效
systemctl restart cloudflared

echo "更新检查完成。"
EOF

chmod +x /usr/local/bin/update-cloudflared.sh

# 添加到 Crontab (每天凌晨 3:00 执行)
(crontab -l 2>/dev/null | grep -v "update-cloudflared.sh"; echo "0 3 * * * /usr/local/bin/update-cloudflared.sh >> /var/log/cloudflared-update.log 2>&1") | crontab -

echo "自动更新任务已设置：每天凌晨 3:00 自动检测并升级。"

echo "--- 全部配置完成！ ---"
systemctl status cloudflared --no-pager | grep "Active:"