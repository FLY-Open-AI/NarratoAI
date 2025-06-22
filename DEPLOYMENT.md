# NarratoAI 部署文档

## 目录
- [系统要求](#系统要求)
- [部署方式](#部署方式)
  - [Docker 部署（推荐）](#docker-部署推荐)
  - [源码部署](#源码部署)
- [配置说明](#配置说明)
- [启动服务](#启动服务)
- [服务管理](#服务管理)
- [监控与日志](#监控与日志)
- [性能优化](#性能优化)
- [故障排除](#故障排除)
- [升级指南](#升级指南)

## 系统要求

### 硬件要求
- **CPU**: 4核心或以上（推荐 8核心）
- **内存**: 8GB 或以上（推荐 16GB）
- **存储**: 50GB 可用空间（推荐 SSD）
- **显卡**: 非必需（有GPU可加速处理）

### 操作系统
- **Linux**: Ubuntu 20.04+, CentOS 8+, Debian 11+
- **Windows**: Windows 10/11
- **macOS**: macOS 11.0+

### 软件依赖
- **Docker**: 20.10+ 和 Docker Compose 2.0+（Docker部署）
- **Python**: 3.10+（源码部署）
- **Git**: 用于代码获取
- **FFmpeg**: 音视频处理（源码部署需要）

## 部署方式

### Docker 部署（推荐）

#### 1. 环境准备

```bash
# 安装 Docker 和 Docker Compose (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version
```

#### 2. 获取代码

```bash
# 克隆项目
git clone https://github.com/linyqh/NarratoAI.git
cd NarratoAI

# 设置适当的目录权限
sudo chown -R $USER:$USER .
chmod -R 755 .
```

#### 3. 配置文件

```bash
# 复制配置文件模板
cp config.example.toml config.toml

# 编辑配置文件（详见配置说明章节）
vim config.toml
```

#### 4. 构建和启动

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 源码部署

#### 1. 环境准备

```bash
# Ubuntu/Debian 系统依赖
sudo apt update
sudo apt install -y python3.10 python3.10-venv python3.10-dev
sudo apt install -y ffmpeg imagemagick git git-lfs
sudo apt install -y build-essential libssl-dev libffi-dev

# CentOS/RHEL 系统依赖
sudo yum install -y python3.10 python3.10-devel
sudo yum install -y ffmpeg ImageMagick git git-lfs
sudo yum groupinstall -y "Development Tools"
```

#### 2. Python 环境

```bash
# 创建虚拟环境
python3.10 -m venv narrato_env
source narrato_env/bin/activate

# 升级 pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt
```

#### 3. 配置文件

```bash
# 复制并编辑配置
cp config.example.toml config.toml
vim config.toml
```

#### 4. 系统服务配置

创建 systemd 服务文件:

```bash
sudo tee /etc/systemd/system/narratoai.service > /dev/null <<EOF
[Unit]
Description=NarratoAI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/path/to/NarratoAI
Environment=PATH=/path/to/NarratoAI/narrato_env/bin
ExecStart=/path/to/NarratoAI/narrato_env/bin/python webui.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
sudo systemctl enable narratoai
sudo systemctl start narratoai
```

## 配置说明

### 核心配置项

编辑 `config.toml` 文件：

```toml
[app]
    # 项目版本（勿修改）
    project_version="0.6.2"
    
    # 视觉模型提供商配置
    vision_llm_provider="siliconflow"  # 可选: gemini, siliconflow, qwenvl, openai
    
    # 文本模型提供商配置
    text_llm_provider="siliconflow"    # 可选: openai, siliconflow, deepseek, gemini, qwen, moonshot
    
    # 隐藏Web界面配置项
    hide_config = true

# 各AI服务商API配置
[app]
    # 硅基流动配置（推荐，性价比高）
    text_siliconflow_api_key = "sk-your-api-key"
    text_siliconflow_base_url = "https://api.siliconflow.cn/v1"
    text_siliconflow_model_name = "deepseek-ai/DeepSeek-R1"
    
    vision_siliconflow_api_key = "sk-your-api-key"
    vision_siliconflow_base_url = "https://api.siliconflow.cn/v1"
    vision_siliconflow_model_name = "Qwen/Qwen2.5-VL-32B-Instruct"

# 代理配置（如需要）
[proxy]
    http = "http://127.0.0.1:7890"
    https = "http://127.0.0.1:7890"
    enabled = false

# 性能配置
[frames]
    frame_interval_input = 3    # 关键帧提取间隔（秒）
    vision_batch_size = 10      # 单次处理帧数
```

### API 密钥获取

1. **硅基流动**（推荐）
   - 注册：https://cloud.siliconflow.cn/i/pyOKqFCV
   - 获取API Key：https://cloud.siliconflow.cn/account/ak
   - 新用户送2000万免费Token

2. **OpenAI**
   - 获取：https://platform.openai.com/api-keys
   - 需要VPN访问

3. **DeepSeek**
   - 获取：https://platform.deepseek.com/api_keys
   - 国内可直接访问

4. **通义千问**
   - 获取：https://bailian.console.aliyun.com/#/api-key
   - 阿里云服务

## 启动服务

### Docker 方式

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f webui

# 停止服务
docker-compose down

# 重启服务
docker-compose restart
```

### 源码方式

```bash
# 激活虚拟环境
source narrato_env/bin/activate

# 启动Web界面
streamlit run webui.py --server.port=8501 --server.address=0.0.0.0

# 或启动API服务
python main.py
```

### 访问界面

- **Web界面**: http://localhost:8501
- **API文档**: http://localhost:8080/docs（如启动API服务）

## 服务管理

### Docker Compose 命令

```bash
# 查看服务状态
docker-compose ps

# 查看资源使用
docker stats

# 进入容器
docker-compose exec webui bash

# 查看详细日志
docker-compose logs --tail=100 -f webui

# 重新构建
docker-compose build --no-cache

# 更新镜像
docker-compose pull
docker-compose up -d
```

### Systemd 服务管理

```bash
# 查看服务状态
sudo systemctl status narratoai

# 启动/停止/重启
sudo systemctl start narratoai
sudo systemctl stop narratoai
sudo systemctl restart narratoai

# 查看日志
sudo journalctl -u narratoai -f

# 查看服务配置
sudo systemctl cat narratoai
```

## 监控与日志

### 日志管理

#### Docker 环境
```bash
# 实时查看日志
docker-compose logs -f --tail=50 webui

# 查看错误日志
docker-compose logs webui | grep -i error

# 日志轮转配置（已在docker-compose.yml中配置）
# - 最大200MB
# - 保留3个文件
```

#### 源码环境
```bash
# 应用日志位置
tail -f /var/log/narratoai/app.log

# 系统服务日志
sudo journalctl -u narratoai --since "1 hour ago"
```

### 性能监控

```bash
# 系统资源监控
htop

# Docker 容器资源
docker stats

# 磁盘使用情况
df -h
du -sh /path/to/NarratoAI

# 网络连接
netstat -tlnp | grep 8501
```

## 性能优化

### 系统层面

```bash
# 内存优化
echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
sysctl -p

# 文件描述符限制
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf
```

### 应用层面

1. **配置优化**
```toml
# 调整处理批次大小
[frames]
    vision_batch_size = 5  # 降低显存使用
    frame_interval_input = 5  # 增加间隔减少处理量
```

2. **Docker 资源限制**
```yaml
# docker-compose.yml
services:
  webui:
    mem_limit: 8g
    mem_reservation: 4g
    cpus: 4.0
    tmpfs:
      - /tmp:size=2G
```

3. **并发处理**
```bash
# 设置环境变量
export PYTHONUNBUFFERED=1
export OPENCV_OPENCL_RUNTIME=disabled
export CUDA_VISIBLE_DEVICES=0  # 如有GPU
```

## 故障排除

### 常见问题

#### 1. 内存不足
```bash
# 症状：OOM错误、处理缓慢
# 解决：增加交换分区
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

#### 2. API 连接失败
```bash
# 检查网络连接
curl -I https://api.siliconflow.cn/v1/models

# 测试代理（如使用）
export http_proxy=http://127.0.0.1:7890
curl -I https://api.openai.com/v1/models
```

#### 3. 端口被占用
```bash
# 查找占用进程
sudo lsof -i :8501
sudo netstat -tlnp | grep 8501

# 修改端口
# 编辑 docker-compose.yml 或启动命令中的端口映射
```

#### 4. 权限问题
```bash
# 修复文件权限
sudo chown -R $USER:$USER /path/to/NarratoAI
chmod -R 755 /path/to/NarratoAI

# Docker 权限
sudo usermod -aG docker $USER
newgrp docker
```

### 日志分析

```bash
# 查找错误模式
grep -i "error\|exception\|fail" /var/log/narratoai/app.log

# 查看API调用失败
grep "API.*fail\|timeout\|connection" /var/log/narratoai/app.log

# 内存使用分析
grep "memory\|OOM" /var/log/syslog
```

## 升级指南

### Docker 部署升级

```bash
# 备份数据
cp -r ./output ./output_backup
cp config.toml config.toml.backup

# 拉取最新代码
git pull origin main

# 重新构建和启动
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 验证升级
docker-compose logs webui
```

### 源码部署升级

```bash
# 停止服务
sudo systemctl stop narratoai

# 备份
cp -r /path/to/NarratoAI /path/to/NarratoAI_backup

# 更新代码
cd /path/to/NarratoAI
git pull origin main

# 更新依赖
source narrato_env/bin/activate
pip install -r requirements.txt --upgrade

# 更新配置（对比差异）
diff config.toml config.example.toml

# 重启服务
sudo systemctl start narratoai
```

### 版本回滚

```bash
# Docker 方式
docker-compose down
git checkout <previous_version_tag>
docker-compose build --no-cache
docker-compose up -d

# 源码方式
sudo systemctl stop narratoai
git checkout <previous_version_tag>
sudo systemctl start narratoai
```

## 安全建议

1. **API 密钥保护**
```bash
# 设置文件权限
chmod 600 config.toml
chown root:root config.toml  # 或特定用户
```

2. **网络安全**
```bash
# 防火墙配置
sudo ufw allow 8501/tcp
sudo ufw enable

# 反向代理（可选）
# 使用 Nginx 作为反向代理，启用 HTTPS
```

3. **定期备份**
```bash
# 创建备份脚本
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /backup/narratoai_backup_$DATE.tar.gz \
    /path/to/NarratoAI/config.toml \
    /path/to/NarratoAI/output
find /backup -name "narratoai_backup_*.tar.gz" -mtime +7 -delete
```

## 联系支持

- GitHub Issues: https://github.com/linyqh/NarratoAI/issues
- Discord 社区: https://discord.com/invite/V2pbAqqQNb
- 官方文档: https://p9mf6rjv3c.feishu.cn/wiki/SP8swLLZki5WRWkhuFvc2CyInDg

---

**部署成功后，访问 http://localhost:8501 开始使用 NarratoAI！** 