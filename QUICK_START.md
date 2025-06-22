# NarratoAI 快速开始指南

欢迎使用 NarratoAI！这是一个一站式 AI 影视解说+自动化剪辑工具。

## 🚀 一键部署

### 方法一：Docker 部署（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/linyqh/NarratoAI.git
cd NarratoAI

# 2. 安装环境依赖
bash scripts/install.sh docker

# 3. 一键部署
bash scripts/deploy.sh docker

# 4. 配置 API 密钥
cp config.example.toml config.toml
vim config.toml  # 编辑您的API密钥

# 5. 重启服务
bash scripts/manage.sh restart

# 6. 访问应用
# 浏览器打开: http://localhost:8501
```

### 方法二：源码部署

```bash
# 1. 克隆项目
git clone https://github.com/linyqh/NarratoAI.git
cd NarratoAI

# 2. 安装环境依赖
bash scripts/install.sh python

# 3. 一键部署
bash scripts/deploy.sh source

# 4. 配置 API 密钥
cp config.example.toml config.toml
vim config.toml  # 编辑您的API密钥

# 5. 启动服务
source narrato_env/bin/activate
streamlit run webui.py

# 6. 访问应用
# 浏览器打开: http://localhost:8501
```

## ⚙️ 配置 API 密钥

编辑 `config.toml` 文件，配置您的 AI 服务商 API 密钥：

### 硅基流动（推荐，性价比高）
```toml
[app]
    text_llm_provider = "siliconflow"
    vision_llm_provider = "siliconflow"
    
    text_siliconflow_api_key = "sk-your-api-key"
    vision_siliconflow_api_key = "sk-your-api-key"
```

**获取密钥**: https://cloud.siliconflow.cn/i/pyOKqFCV

### OpenAI
```toml
[app]
    text_llm_provider = "openai"
    vision_llm_provider = "openai"
    
    text_openai_api_key = "sk-your-api-key"
    vision_openai_api_key = "sk-your-api-key"
```

**获取密钥**: https://platform.openai.com/api-keys

### DeepSeek
```toml
[app]
    text_llm_provider = "deepseek"
    
    text_deepseek_api_key = "sk-your-api-key"
```

**获取密钥**: https://platform.deepseek.com/api_keys

## 📋 系统要求

- **CPU**: 4核心或以上
- **内存**: 8GB 或以上  
- **存储**: 50GB 可用空间
- **操作系统**: Ubuntu 20.04+, CentOS 8+, macOS 11.0+, Windows 10/11

## 🛠️ 常用命令

```bash
# 查看服务状态
bash scripts/manage.sh status

# 启动服务
bash scripts/manage.sh start

# 停止服务
bash scripts/manage.sh stop

# 查看日志
bash scripts/manage.sh logs

# 备份数据
bash scripts/manage.sh backup

# 更新应用
bash scripts/manage.sh update

# 健康检查
bash scripts/monitor.sh check
```

## 🎯 主要功能

- 🎬 **智能影视解说**: 基于LLM的自动文案生成
- ✂️ **自动视频剪辑**: 智能镜头切换和节奏控制
- 🗣️ **AI配音**: 多种TTS引擎支持
- 📝 **字幕生成**: 自动添加字幕和特效
- 🎭 **短剧混剪**: 支持短剧内容创作
- 👁️ **视频理解**: AI分析视频内容和情节

## 🔧 故障排除

### 1. 端口被占用
```bash
# 查看端口使用情况
sudo lsof -i :8501

# 修改端口配置
vim docker-compose.yml  # 修改端口映射
```

### 2. 内存不足
```bash
# 添加交换分区
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 3. API 连接失败
```bash
# 测试网络连接
curl -I https://api.siliconflow.cn/v1/models

# 检查代理设置
export http_proxy=http://127.0.0.1:7890
```

### 4. Docker 权限问题
```bash
# 添加用户到docker组
sudo usermod -aG docker $USER
newgrp docker

# 或重新登录系统
```

## 📚 更多资源

- 📖 **完整部署文档**: [DEPLOYMENT.md](DEPLOYMENT.md)
- 🛠️ **脚本使用说明**: [scripts/README.md](scripts/README.md)
- 🌐 **官方文档**: https://p9mf6rjv3c.feishu.cn/wiki/SP8swLLZki5WRWkhuFvc2CyInDg
- 🐛 **问题反馈**: https://github.com/linyqh/NarratoAI/issues
- 💬 **社区交流**: https://discord.com/invite/V2pbAqqQNb

## 🎉 成功部署

部署成功后，您将看到：

1. **Web界面**: http://localhost:8501
2. **服务状态**: 运行中
3. **日志输出**: 无错误信息

开始您的AI视频创作之旅吧！🚀

---

**💡 小贴士**: 首次使用建议先阅读官方文档，了解各项功能的使用方法。 