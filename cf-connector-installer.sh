#!/bin/bash

# 🌸 椿卷ฅ的CF连接器一键安装脚本

set -euo pipefail

echo "--- 🚀 Cloudflare Tunnel 连接器安装程序 ---"
echo ""

# 检查是否为 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 权限运行此脚本（sudo su）。"
    exit 1
fi

# 显示系统信息
echo "📋 系统信息:"
echo "  主机名: $(hostname)"
echo "  架构: $(uname -m)"
echo "  系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo ""

# 交互式获取配置
echo "📝 配置 Cloudflare Tunnel:"
read -p "请输入 Cloudflare Account ID: " CF_ACCOUNT_ID
read -p "请输入 Cloudflare Tunnel ID: " CF_TUNNEL_ID
read -p "请输入 Cloudflare Tunnel Secret (可选，按回车跳过): " CF_TUNNEL_SECRET

# 安装必要的依赖
echo ""
echo "📦 安装依赖..."
apt update
apt install -y curl wget gnupg

# 下载 Cloudflared
echo ""
echo "⬇️ 下载 Cloudflared..."
ARCH=$(uname -m)
case "$ARCH" in
    "x86_64")
        ARCH="amd64"
        ;;
    "aarch64"|"arm64")
        ARCH="arm64"
        ;;
    "armv7l")
        ARCH="arm"
        ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}"
curl -L "$CLOUDFLARED_URL" -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# 创建配置目录
echo ""
echo "📁 创建配置目录..."
mkdir -p /etc/cloudflared
mkdir -p /var/log/cloudflared

# 创建配置文件
if [ -n "$CF_TUNNEL_SECRET" ]; then
    # 使用提供的Secret
    cat << EOF > /etc/cloudflared/config.yml
tunnel: $CF_TUNNEL_ID
credentials-file: /etc/cloudflared/credentials.json
logfile: /var/log/cloudflared/cloudflared.log
loglevel: info
EOF

    cat << EOF > /etc/cloudflared/credentials.json
{
  "AccountTag": "$CF_ACCOUNT_ID",
  "TunnelID": "$CF_TUNNEL_ID",
  "TunnelSecret": "$CF_TUNNEL_SECRET"
}
EOF
    chmod 600 /etc/cloudflared/credentials.json
else
    # 使用服务令牌方式
    echo "🔐 使用服务令牌认证..."
    cat << EOF > /etc/cloudflared/config.yml
tunnel: $CF_TUNNEL_ID
credentials-file: /root/.cloudflared/$CF_TUNNEL_ID.json
logfile: /var/log/cloudflared/cloudflared.log
loglevel: info
EOF
    
    echo "💡 请手动运行以下命令完成认证:"
    echo "   cloudflared tunnel login"
    echo "   cloudflared tunnel run $CF_TUNNEL_ID"
fi

# 创建 Systemd 服务
cat << EOF > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run $CF_TUNNEL_ID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
echo ""
echo "⚙️ 启动服务..."
systemctl daemon-reload

if [ -n "$CF_TUNNEL_SECRET" ]; then
    systemctl enable cloudflared.service
    systemctl start cloudflared.service
    echo "✅ Cloudflare Tunnel 服务已启动"
else
    systemctl enable cloudflared.service
    echo "⚠️ 服务已启用但未启动，请先完成认证"
fi

# 创建状态检查脚本
cat << 'EOF' > /usr/local/bin/cf-status.sh
#!/bin/bash
echo "=== 🔍 Cloudflare Tunnel 状态 ==="
echo ""
echo "🔧 服务状态:"
systemctl status cloudflared.service --no-pager -l
echo ""
echo "📊 进程状态:"
ps aux | grep cloudflared | grep -v grep || echo "  进程未运行"
echo ""
echo "📝 最新日志:"
tail -n 20 /var/log/cloudflared/cloudflared.log 2>/dev/null || echo "  日志文件不存在"
echo ""
EOF

chmod +x /usr/local/bin/cf-status.sh

# 安装完成信息
echo ""
echo "----------------------------------------"
echo "✅ Cloudflare Tunnel 安装完成！"
echo ""
echo "📋 安装摘要:"
echo "  📍 Cloudflared: /usr/local/bin/cloudflared"
echo "  📁 配置文件: /etc/cloudflared/config.yml"
if [ -n "$CF_TUNNEL_SECRET" ]; then
    echo "  🔐 凭证文件: /etc/cloudflared/credentials.json"
else
    echo "  🔐 认证方式: 服务令牌 (需手动认证)"
fi
echo "  ⚙️ 服务文件: /etc/systemd/system/cloudflared.service"
echo "  📊 状态检查: /usr/local/bin/cf-status.sh"
echo "  📝 日志文件: /var/log/cloudflared/cloudflared.log"
echo ""

if [ -n "$CF_TUNNEL_SECRET" ]; then
    echo "🔄 服务状态:"
    systemctl status cloudflared.service --no-pager -l | head -10
    echo ""
    echo "💡 管理命令:"
    echo "  查看状态: cf-status.sh"
    echo "  重启服务: systemctl restart cloudflared"
    echo "  查看日志: journalctl -u cloudflared -f"
else
    echo "🔐 下一步操作:"
    echo "  1. 运行认证: cloudflared tunnel login"
    echo "  2. 启动隧道: cloudflared tunnel run $CF_TUNNEL_ID"
    echo "  3. 测试连接"
    echo "  4. 启动服务: systemctl start cloudflared"
fi

echo "----------------------------------------"