#!/bin/bash

# NarratoAI 一键部署脚本
# 作者: NarratoAI Team  
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "NarratoAI 一键部署脚本"
    echo ""
    echo "用法: bash deploy.sh [docker|source]"
    echo ""
    echo "选项:"
    echo "  docker    使用 Docker 部署 (推荐)"
    echo "  source    使用源码部署"
    echo "  help      显示帮助信息"
}

# Docker 部署
deploy_docker() {
    log_info "开始 Docker 部署..."
    
    # 检查配置文件
    if [ ! -f config.toml ]; then
        cp config.example.toml config.toml
        log_info "已创建配置文件 config.toml，请配置您的 API 密钥"
    fi
    
    # 启动服务
    log_info "启动 Docker 服务..."
    docker compose up -d
    
    log_info "✅ Docker 部署成功！访问地址: http://localhost:8501"
}

# 源码部署
deploy_source() {
    log_info "开始源码部署..."
    
    # 检查 Python
    if ! command -v python3.10 &> /dev/null; then
        log_error "请先安装 Python 3.10"
        exit 1
    fi
    
    # 创建虚拟环境
    if [ ! -d "narrato_env" ]; then
        log_info "创建虚拟环境..."
        python3.10 -m venv narrato_env
    fi
    
    # 激活虚拟环境并安装依赖
    source narrato_env/bin/activate
    pip install -r requirements.txt
    
    # 检查配置文件
    if [ ! -f config.toml ]; then
        cp config.example.toml config.toml
        log_info "已创建配置文件 config.toml，请配置您的 API 密钥"
    fi
    
    log_info "✅ 源码部署成功！"
    log_info "启动命令: source narrato_env/bin/activate && streamlit run webui.py"
}

# 主函数
main() {
    case "${1:-help}" in
        docker)
            deploy_docker
            ;;
        source)
            deploy_source
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@"
