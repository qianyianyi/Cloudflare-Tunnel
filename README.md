# 🌸 椿卷ฅ的CF连接器一键安装脚本

## 🚀 简介

这是一个简洁高效的 Cloudflare Tunnel 连接器一键安装脚本，让你快速部署和管理 Cloudflare Tunnel 服务。

## ✨ 特性

- ✅ **一键安装** - 自动化安装和配置
- ✅ **多架构支持** - x86_64, arm64, armv7l
- ✅ **Systemd服务** - 专业的服务管理
- ✅ **自动认证** - 支持Secret和服务令牌两种方式
- ✅ **状态监控** - 内置状态检查工具
- ✅ **日志管理** - 完整的日志记录和查看

## 📦 快速安装

### 一键安装
```bash
# 🌸 使用椿卷ฅ的标准语法
bash <(curl -s https://raw.githubusercontent.com/RapheaI/cf-connector-installer/main/cf-connector-installer.sh)
```

### 手动安装
```bash
# 1. 下载脚本
curl -s -o cf-connector-installer.sh https://raw.githubusercontent.com/RapheaI/cf-connector-installer/main/cf-connector-installer.sh

# 2. 运行安装
chmod +x cf-connector-installer.sh
sudo ./cf-connector-installer.sh
```

## 🔧 安装过程

安装脚本会：

1. 🔐 **权限检查** - 确保root权限运行
2. 📋 **系统检测** - 检测系统架构和版本
3. 📝 **配置输入** - 输入Cloudflare配置信息
4. 📦 **依赖安装** - 安装必要的工具
5. ⬇️ **下载Cloudflared** - 自动下载适合架构的版本
6. 📁 **创建配置** - 生成配置文件和凭证
7. ⚙️ **服务配置** - 创建Systemd服务
8. 🚀 **启动服务** - 启用并启动隧道服务

## 📋 配置信息

### 必需信息
- **Cloudflare Account ID** - 你的Cloudflare账户ID
- **Cloudflare Tunnel ID** - 隧道ID

### 可选信息
- **Cloudflare Tunnel Secret** - 隧道Secret（如果提供，自动完成认证）

## 🛠️ 管理命令

### 查看状态
```bash
# 使用内置状态检查脚本
cf-status.sh

# 查看服务状态
systemctl status cloudflared.service

# 查看实时日志
journalctl -u cloudflared -f
```

### 服务管理
```bash
# 启动服务
systemctl start cloudflared

# 停止服务
systemctl stop cloudflared

# 重启服务
systemctl restart cloudflared

# 启用开机自启
systemctl enable cloudflared

# 禁用开机自启
systemctl disable cloudflared
```

### 手动认证（如果未提供Secret）
```bash
# 登录认证
cloudflared tunnel login

# 运行隧道
cloudflared tunnel run <TUNNEL_ID>
```

## 📁 文件结构

```
/usr/local/bin/cloudflared          # Cloudflared二进制文件
/usr/local/bin/cf-status.sh         # 状态检查脚本
/etc/cloudflared/config.yml         # 主配置文件
/etc/cloudflared/credentials.json   # 凭证文件（如果使用Secret）
/etc/systemd/system/cloudflared.service  # Systemd服务文件
/var/log/cloudflared/cloudflared.log     # 日志文件
```

## 🔍 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 检查服务状态
systemctl status cloudflared.service

# 查看详细日志
journalctl -u cloudflared.service -n 50

# 检查配置文件
cat /etc/cloudflared/config.yml
```

#### 2. 认证问题
```bash
# 手动运行认证
cloudflared tunnel login

# 检查凭证文件
ls -la /root/.cloudflared/
```

#### 3. 网络连接问题
```bash
# 测试Cloudflare连接
curl -s https://www.cloudflare.com/

# 检查DNS解析
dig @1.1.1.1 cloudflare.com
```

### 日志位置
- **Systemd日志**: `journalctl -u cloudflared`
- **文件日志**: `/var/log/cloudflared/cloudflared.log`

## 🎯 支持的架构

- ✅ **x86_64** (amd64)
- ✅ **aarch64** (arm64) 
- ✅ **armv7l** (arm)

## 📄 许可证

MIT License - 椿卷ฅ 版权所有

---

**🌸 椿卷ฅ的简洁高效CF连接器安装系统**