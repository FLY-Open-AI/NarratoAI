#!/bin/bash

# NarratoAI 服务管理脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# 检测部署方式
detect_deployment() {
    if [ -f "docker-compose.yml" ] && command -v docker-compose &> /dev/null; then
        DEPLOYMENT="docker"
    elif [ -f "narrato_env/bin/activate" ]; then
        DEPLOYMENT="source"
    else
        log_error "无法检测到部署方式"
        exit 1
    fi
}

# 启动服务
start_service() {
    case $DEPLOYMENT in
        docker)
            log_info "启动 Docker 服务..."
            docker-compose up -d
            ;;
        source)
            log_info "请使用以下命令启动服务:"
            echo "source narrato_env/bin/activate && streamlit run webui.py"
            ;;
    esac
}

# 停止服务
stop_service() {
    case $DEPLOYMENT in
        docker)
            log_info "停止 Docker 服务..."
            docker-compose down
            ;;
        source)
            log_info "请手动停止 streamlit 进程"
            ;;
    esac
}

# 查看状态
check_status() {
    case $DEPLOYMENT in
        docker)
            echo "Docker 服务状态:"
            docker-compose ps
            ;;
        source)
            echo "源码部署模式"
            if pgrep -f "streamlit.*webui.py" > /dev/null; then
                echo -e "状态: ${GREEN}运行中${NC}"
            else
                echo -e "状态: ${RED}已停止${NC}"
            fi
            ;;
    esac
}

# 查看日志
view_logs() {
    case $DEPLOYMENT in
        docker)
            docker-compose logs -f webui
            ;;
        source)
            log_info "源码模式请查看终端输出"
            ;;
    esac
}

# 备份数据
backup_data() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="backup_$TIMESTAMP.tar.gz"
    
    tar -czf "$BACKUP_FILE" config.toml output/ 2>/dev/null || true
    log_info "备份完成: $BACKUP_FILE"
}

# 显示帮助
show_help() {
    echo "NarratoAI 服务管理脚本"
    echo ""
    echo "用法: bash manage.sh [命令]"
    echo ""
    echo "命令:"
    echo "  start     启动服务"
    echo "  stop      停止服务"
    echo "  restart   重启服务"
    echo "  status    查看服务状态"
    echo "  logs      查看服务日志"
    echo "  backup    备份数据"
    echo "  help      显示帮助信息"
}

# 主函数
main() {
    detect_deployment
    
    case "${1:-help}" in
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            stop_service
            sleep 2
            start_service
            ;;
        status)
            check_status
            ;;
        logs)
            view_logs
            ;;
        backup)
            backup_data
            ;;
        help|*)
            show_help
            ;;
    esac
}

main "$@"
