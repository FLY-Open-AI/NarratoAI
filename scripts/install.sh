#!/bin/bash

# NarratoAI 环境安装脚本
# 一键安装所有必要的依赖

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            OS="ubuntu"
        elif command -v yum &> /dev/null; then
            OS="centos"
        else
            log_error "不支持的Linux发行版"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        log_error "不支持的操作系统: $OSTYPE"
        exit 1
    fi
    log_info "检测到操作系统: $OS"
}

# 安装 Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_info "Docker 已安装"
        return
    fi
    
    log_info "安装 Docker..."
    case $OS in
        ubuntu)
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
            ;;
        centos)
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
            ;;
        macos)
            log_warn "请手动安装 Docker Desktop for Mac"
            return
            ;;
    esac
    log_info "Docker 安装完成"
}

# 安装 Docker Compose
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_info "Docker Compose 已安装"
        return
    fi
    
    log_info "安装 Docker Compose..."
    case $OS in
        ubuntu|centos)
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            ;;
        macos)
            log_info "Docker Desktop for Mac 已包含 Docker Compose"
            ;;
    esac
    log_info "Docker Compose 安装完成"
}

# 安装 Python 3.10
install_python() {
    if command -v python3.10 &> /dev/null; then
        log_info "Python 3.10 已安装"
        return
    fi
    
    log_info "安装 Python 3.10..."
    case $OS in
        ubuntu)
            sudo apt update
            sudo apt install -y python3.10 python3.10-venv python3.10-dev
            ;;
        centos)
            sudo yum install -y epel-release
            sudo yum install -y python310 python310-devel
            ;;
        macos)
            if command -v brew &> /dev/null; then
                brew install python@3.10
            else
                log_error "请先安装 Homebrew"
                exit 1
            fi
            ;;
    esac
    log_info "Python 3.10 安装完成"
}

# 安装系统依赖
install_system_deps() {
    log_info "安装系统依赖..."
    case $OS in
        ubuntu)
            sudo apt update
            sudo apt install -y curl wget git git-lfs unzip ffmpeg imagemagick
            sudo apt install -y build-essential libssl-dev libffi-dev
            ;;
        centos)
            sudo yum update -y
            sudo yum install -y curl wget git git-lfs unzip ffmpeg ImageMagick
            sudo yum groupinstall -y "Development Tools"
            ;;
        macos)
            if command -v brew &> /dev/null; then
                brew install git git-lfs ffmpeg imagemagick
            else
                log_error "请先安装 Homebrew"
                exit 1
            fi
            ;;
    esac
    
    # 安装 git-lfs
    git lfs install
    log_info "系统依赖安装完成"
}

# 验证安装
verify_installation() {
    log_info "验证安装..."
    
    # 检查 Docker
    if command -v docker &> /dev/null; then
        echo "✅ Docker: $(docker --version)"
    else
        echo "❌ Docker 未安装"
    fi
    
    # 检查 Docker Compose
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose: $(docker-compose --version)"
    else
        echo "❌ Docker Compose 未安装"
    fi
    
    # 检查 Python
    if command -v python3.10 &> /dev/null; then
        echo "✅ Python: $(python3.10 --version)"
    else
        echo "❌ Python 3.10 未安装"
    fi
    
    # 检查 Git
    if command -v git &> /dev/null; then
        echo "✅ Git: $(git --version)"
    else
        echo "❌ Git 未安装"
    fi
    
    # 检查 FFmpeg
    if command -v ffmpeg &> /dev/null; then
        echo "✅ FFmpeg: $(ffmpeg -version | head -1)"
    else
        echo "❌ FFmpeg 未安装"
    fi
}

# 主函数
main() {
    echo "=================================================="
    echo "         NarratoAI 环境安装脚本                   "
    echo "=================================================="
    
    detect_os
    
    case "${1:-all}" in
        docker)
            install_docker
            install_docker_compose
            ;;
        python)
            install_python
            install_system_deps
            ;;
        all)
            install_system_deps
            install_python
            install_docker
            install_docker_compose
            ;;
        verify)
            verify_installation
            return
            ;;
        *)
            echo "用法: bash install.sh [docker|python|all|verify]"
            return
            ;;
    esac
    
    verify_installation
    
    echo ""
    echo "=================================================="
    echo "                安装完成！                        "
    echo "=================================================="
    echo ""
    echo "下一步："
    echo "1. 运行部署脚本: bash scripts/deploy.sh docker"
    echo "2. 配置 API 密钥: vim config.toml"
    echo "3. 访问应用: http://localhost:8501"
    echo ""
    
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "centos" ]]; then
        log_warn "请重新登录或运行 'newgrp docker' 以使 Docker 权限生效"
    fi
}

main "$@"
