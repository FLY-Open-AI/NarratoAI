# NarratoAI 部署与管理脚本

本目录包含了 NarratoAI 的自动化部署和管理脚本，可以帮助您快速部署和管理应用。

## 脚本说明

### 1. deploy.sh - 一键部署脚本

快速部署 NarratoAI 应用的脚本。

**使用方法:**
```bash
# Docker 部署（推荐）
bash scripts/deploy.sh docker

# 源码部署
bash scripts/deploy.sh source

# 查看帮助
bash scripts/deploy.sh help
```

**功能特性:**
- 自动检测操作系统
- 安装必要的依赖
- 配置文件初始化
- 服务启动验证

### 2. manage.sh - 服务管理脚本

管理 NarratoAI 服务的日常操作脚本。

**使用方法:**
```bash
# 启动服务
bash scripts/manage.sh start

# 停止服务
bash scripts/manage.sh stop

# 重启服务
bash scripts/manage.sh restart

# 查看状态
bash scripts/manage.sh status

# 查看日志
bash scripts/manage.sh logs

# 备份数据
bash scripts/manage.sh backup

# 查看帮助
bash scripts/manage.sh help
```

### 3. monitor.sh - 监控脚本

系统监控和健康检查脚本。

**使用方法:**
```bash
# 执行系统检查
bash scripts/monitor.sh check

# 生成监控报告
bash scripts/monitor.sh report

# 安装监控服务
bash scripts/monitor.sh install

# 查看帮助
bash scripts/monitor.sh help
```

## 快速开始

### 首次部署

1. **Docker 部署（推荐）:**
```bash
# 克隆项目
git clone https://github.com/linyqh/NarratoAI.git
cd NarratoAI

# 一键部署
bash scripts/deploy.sh docker

# 配置 API 密钥
vim config.toml

# 重启服务
bash scripts/manage.sh restart
```

2. **源码部署:**
```bash
# 安装 Python 3.10
sudo apt install python3.10 python3.10-venv

# 一键部署
bash scripts/deploy.sh source

# 配置 API 密钥
vim config.toml

# 启动服务
source narrato_env/bin/activate
streamlit run webui.py
```

### 日常管理

```bash
# 查看服务状态
bash scripts/manage.sh status

# 查看实时日志
bash scripts/manage.sh logs

# 备份重要数据
bash scripts/manage.sh backup

# 执行健康检查
bash scripts/monitor.sh check
```

## 配置说明

### API 密钥配置

编辑 `config.toml` 文件，配置您的 AI 服务商 API 密钥：

```toml
[app]
    # 推荐使用硅基流动（性价比高）
    text_llm_provider = "siliconflow"
    vision_llm_provider = "siliconflow"
    
    # 硅基流动 API 配置
    text_siliconflow_api_key = "您的API密钥"
    vision_siliconflow_api_key = "您的API密钥"
```

### 获取 API 密钥

- **硅基流动**（推荐）: https://cloud.siliconflow.cn/i/pyOKqFCV
- **OpenAI**: https://platform.openai.com/api-keys
- **DeepSeek**: https://platform.deepseek.com/api_keys

## 常见问题

### 1. 端口被占用
```bash
# 查看端口占用
sudo lsof -i :8501

# 修改端口（docker-compose.yml）
ports:
  - "8502:8501"  # 改为8502端口
```

### 2. 内存不足
```bash
# 增加交换分区
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 3. 权限问题
```bash
# 修复文件权限
sudo chown -R $USER:$USER /path/to/NarratoAI
chmod -R 755 /path/to/NarratoAI
```

## 技术支持

- 📚 完整部署文档: [DEPLOYMENT.md](../DEPLOYMENT.md)
- 🐛 问题反馈: https://github.com/linyqh/NarratoAI/issues
- 💬 社区交流: https://discord.com/invite/V2pbAqqQNb

---

**部署成功后，访问 http://localhost:8501 开始使用 NarratoAI！** 