#!/bin/bash

# NarratoAI 监控脚本
# 用法: bash monitor.sh [check|alert|report]

set -e

# 配置
ALERT_EMAIL=""  # 设置告警邮箱
CPU_THRESHOLD=80  # CPU 使用率阈值
MEM_THRESHOLD=80  # 内存使用率阈值
DISK_THRESHOLD=85  # 磁盘使用率阈值
LOG_FILE="/var/log/narratoai_monitor.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_with_timestamp() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_with_timestamp "INFO: $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log_with_timestamp "WARN: $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_with_timestamp "ERROR: $1"
}

# 发送告警
send_alert() {
    local message="$1"
    local subject="NarratoAI 系统告警"
    
    # 记录告警
    log_error "$message"
    
    # 发送邮件告警（如果配置了邮箱）
    if [ ! -z "$ALERT_EMAIL" ] && command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    fi
    
    # 发送系统通知
    if command -v notify-send &> /dev/null; then
        notify-send "$subject" "$message" --urgency=critical
    fi
}

# 检查服务状态
check_service_status() {
    local status="正常"
    local issues=()
    
    # 检测部署方式
    if [ -f "docker-compose.yml" ] && command -v docker-compose &> /dev/null; then
        # Docker 部署
        if ! docker-compose ps | grep -q "Up"; then
            status="异常"
            issues+=("Docker 服务未运行")
        fi
    elif [ -f "narrato_env/bin/activate" ]; then
        # 源码部署
        if ! systemctl is-active --quiet narratoai; then
            status="异常"
            issues+=("系统服务未运行")
        fi
    else
        status="异常"
        issues+=("无法检测到部署方式")
    fi
    
    # 检查端口
    if ! netstat -tlnp 2>/dev/null | grep -q ":8501"; then
        status="异常"
        issues+=("端口 8501 未监听")
    fi
    
    # 检查HTTP响应
    if command -v curl &> /dev/null; then
        if ! curl -f -s --max-time 10 http://localhost:8501 > /dev/null; then
            status="异常"
            issues+=("HTTP 服务无响应")
        fi
    fi
    
    echo "$status"
    if [ ${#issues[@]} -gt 0 ]; then
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
    fi
    
    return $( [ "$status" = "正常" ] && echo 0 || echo 1 )
}

# 检查系统资源
check_system_resources() {
    local status="正常"
    local issues=()
    
    # 检查CPU使用率
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        status="警告"
        issues+=("CPU 使用率过高: ${cpu_usage}%")
    fi
    
    # 检查内存使用率
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
        status="警告"
        issues+=("内存使用率过高: ${mem_usage}%")
    fi
    
    # 检查磁盘使用率
    local disk_usage=$(df . | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        status="警告"
        issues+=("磁盘使用率过高: ${disk_usage}%")
    fi
    
    # 检查负载
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_cores=$(nproc)
    if (( $(echo "$load_avg > $cpu_cores * 2" | bc -l) )); then
        status="警告"
        issues+=("系统负载过高: $load_avg (CPU核心数: $cpu_cores)")
    fi
    
    echo "$status"
    if [ ${#issues[@]} -gt 0 ]; then
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
    fi
    
    return $( [ "$status" = "正常" ] && echo 0 || echo 1 )
}

# 检查日志错误
check_logs() {
    local status="正常"
    local error_count=0
    
    # 检查最近1小时的错误日志
    if [ -f "docker-compose.yml" ]; then
        # Docker 部署
        error_count=$(docker-compose logs --since=1h webui 2>/dev/null | grep -i "error\|exception\|fail" | wc -l)
    else
        # 源码部署
        error_count=$(journalctl -u narratoai --since="1 hour ago" 2>/dev/null | grep -i "error\|exception\|fail" | wc -l)
    fi
    
    if [ "$error_count" -gt 10 ]; then
        status="警告"
        echo "$status"
        echo "  - 最近1小时出现 $error_count 个错误"
    else
        echo "$status"
    fi
    
    return $( [ "$status" = "正常" ] && echo 0 || echo 1 )
}

# 执行完整检查
perform_check() {
    echo "=================================================="
    echo "         NarratoAI 系统监控检查                   "
    echo "=================================================="
    echo "检查时间: $(date)"
    echo ""
    
    local overall_status="正常"
    
    # 服务状态检查
    echo "🔍 服务状态检查:"
    if ! check_service_status; then
        overall_status="异常"
    fi
    echo ""
    
    # 系统资源检查
    echo "📊 系统资源检查:"
    check_system_resources
    echo ""
    
    # 日志错误检查
    echo "📝 日志错误检查:"
    check_logs
    echo ""
    
    # 网络连接检查
    echo "🌐 网络连接检查:"
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "正常"
        echo "  - 外网连接正常"
    else
        echo "警告"
        echo "  - 外网连接异常"
    fi
    echo ""
    
    # 磁盘空间详情
    echo "💾 磁盘空间详情:"
    df -h . | head -2
    echo ""
    
    # 进程信息
    echo "⚙️  进程信息:"
    if [ -f "docker-compose.yml" ]; then
        docker-compose ps
    else
        ps aux | grep -E "(streamlit|narratoai)" | grep -v grep
    fi
    echo ""
    
    echo "=================================================="
    echo "总体状态: $overall_status"
    echo "=================================================="
    
    return $( [ "$overall_status" = "正常" ] && echo 0 || echo 1 )
}

# 告警检查
alert_check() {
    log_info "执行告警检查..."
    
    # 检查服务状态
    if ! check_service_status &> /dev/null; then
        send_alert "NarratoAI 服务状态异常，请立即检查！"
    fi
    
    # 检查系统资源
    local resource_check=$(check_system_resources)
    if echo "$resource_check" | grep -q "警告"; then
        send_alert "NarratoAI 系统资源使用异常：\n$resource_check"
    fi
    
    # 检查错误日志
    local log_check=$(check_logs)
    if echo "$log_check" | grep -q "警告"; then
        send_alert "NarratoAI 出现大量错误日志：\n$log_check"
    fi
}

# 生成监控报告
generate_report() {
    local report_file="monitor_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "生成监控报告: $report_file"
    
    {
        echo "NarratoAI 监控报告"
        echo "=================="
        echo "报告时间: $(date)"
        echo ""
        
        # 系统信息
        echo "系统信息:"
        echo "--------"
        uname -a
        echo ""
        
        # 运行时间
        echo "运行时间:"
        echo "--------"
        uptime
        echo ""
        
        # 详细检查
        perform_check
        
        # 最近错误日志
        echo "最近错误日志 (最近24小时):"
        echo "-------------------------"
        if [ -f "docker-compose.yml" ]; then
            docker-compose logs --since=24h webui 2>/dev/null | grep -i "error\|exception\|fail" | tail -20
        else
            journalctl -u narratoai --since="24 hours ago" 2>/dev/null | grep -i "error\|exception\|fail" | tail -20
        fi
        
    } > "$report_file"
    
    log_info "监控报告已生成: $report_file"
}

# 安装为系统服务
install_monitoring() {
    log_info "安装监控服务..."
    
    # 创建监控脚本的系统服务
    sudo tee /etc/systemd/system/narratoai-monitor.service > /dev/null <<EOF
[Unit]
Description=NarratoAI Monitor Service
After=network.target

[Service]
Type=oneshot
ExecStart=$(pwd)/scripts/monitor.sh alert
EOF

    # 创建定时器
    sudo tee /etc/systemd/system/narratoai-monitor.timer > /dev/null <<EOF
[Unit]
Description=NarratoAI Monitor Timer
Requires=narratoai-monitor.service

[Timer]
OnCalendar=*:0/10  # 每10分钟执行一次
Persistent=true

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable narratoai-monitor.timer
    sudo systemctl start narratoai-monitor.timer
    
    log_info "监控服务安装完成，每10分钟检查一次"
}

# 显示帮助
show_help() {
    echo "NarratoAI 监控脚本"
    echo ""
    echo "用法: bash monitor.sh [命令]"
    echo ""
    echo "命令:"
    echo "  check     执行完整系统检查"
    echo "  alert     执行告警检查"
    echo "  report    生成监控报告"
    echo "  install   安装监控服务"
    echo "  help      显示帮助信息"
    echo ""
    echo "示例:"
    echo "  bash monitor.sh check"
    echo "  bash monitor.sh report"
}

# 主函数
main() {
    case "${1:-help}" in
        check)
            perform_check
            ;;
        alert)
            alert_check
            ;;
        report)
            generate_report
            ;;
        install)
            install_monitoring
            ;;
        help|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@" 