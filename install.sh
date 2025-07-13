#!/bin/bash

# =============================================================================
# Overlux Proxy Server - All-in-One Installation Script
# Tối ưu hóa với logging, error handling, và security features
# =============================================================================

set -euo pipefail  # Strict error handling

# =============================================================================
# CONFIGURATION
# =============================================================================
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="3.0.0"
readonly REPO_URL="https://github.com/AZZ-vopp/overlux.git"
readonly REPO_DIR="overlux"
readonly BINARY_NAME="overlux"
readonly BINARY_PATH="/usr/local/bin/overlux"
readonly SERVICE_NAME="overlux"
readonly SERVICE_PATH="/etc/systemd/system/overlux.service"
readonly LOG_DIR="/var/log/overlux"
readonly CONFIG_DIR="/etc/overlux"
readonly UNLOCK_FILE="/etc/overlux/.unlocked"
readonly BACKUP_DIR="/tmp/overlux_backup_$(date +%Y%m%d_%H%M%S)"

# =============================================================================
# COLOR CODES FOR OUTPUT
# =============================================================================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_fail() {
    echo -e "${RED}❌${NC} $1"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    OVERLUX PROXY SERVER                     ║"
    echo "║                   All-in-One Installer                      ║"
    echo "║                        v${SCRIPT_VERSION}                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    echo -e "${CYAN}"
    echo "📋 CHỌN HÀNH ĐỘNG:"
    echo -e "${NC}"
    echo "1. 🔧 Cài đặt Overlux (Install)"
    echo "2. 🔑 Kích hoạt Overlux (Activate)"
    echo "3. 🔄 Restart Service (Restart)"
    echo "4. 📊 Xem trạng thái (Status)"
    echo "5. 🚀 Cài đặt + Kích hoạt (Install + Activate)"
    echo "6. 🛠️  Troubleshooting"
    echo "0. 🚪 Thoát"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Script này cần quyền root để chạy!"
        log_info "Sử dụng: sudo $0"
        exit 1
    fi
}

check_system() {
    log_info "Kiểm tra hệ thống..."
    
    # Kiểm tra OS
    if [[ ! -f /etc/os-release ]]; then
        log_error "Không thể xác định hệ điều hành!"
        exit 1
    fi
    
    # Kiểm tra systemd
    if ! command -v systemctl &> /dev/null; then
        log_error "Systemd không được tìm thấy! Overlux yêu cầu systemd."
        exit 1
    fi
    
    # Kiểm tra git
    if ! command -v git &> /dev/null; then
        log_warn "Git không được tìm thấy, đang cài đặt..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y git
        elif command -v yum &> /dev/null; then
            yum install -y git
        else
            log_error "Không thể cài đặt git! Vui lòng cài đặt thủ công."
            exit 1
        fi
    fi
    
    log_success "Hệ thống đã sẵn sàng"
}

backup_existing() {
    if [[ -f "$BINARY_PATH" ]]; then
        log_info "Tạo backup cho file hiện tại..."
        mkdir -p "$BACKUP_DIR"
        cp "$BINARY_PATH" "$BACKUP_DIR/"
        log_success "Backup đã được tạo tại: $BACKUP_DIR"
    fi
}

download_binary() {
    log_info "Tải xuống Overlux binary..."
    
    # Kiểm tra file hiện tại
    if [[ -f "$BINARY_NAME" ]]; then
        log_info "Tìm thấy file $BINARY_NAME hiện tại"
        return 0
    fi
    
    # Clone repo nếu cần
    if [[ ! -d "$REPO_DIR" ]]; then
        log_info "Clone repository từ GitHub..."
        if ! git clone "$REPO_URL" "$REPO_DIR"; then
            log_error "Không thể clone repository!"
            exit 1
        fi
    fi
    
    # Copy binary
    if [[ -f "$REPO_DIR/$BINARY_NAME" ]]; then
        cp "$REPO_DIR/$BINARY_NAME" "./$BINARY_NAME"
        log_success "Đã tải xuống binary thành công"
    else
        log_error "Không tìm thấy binary trong repository!"
        exit 1
    fi
}

install_binary() {
    log_info "Cài đặt binary..."
    
    # Kiểm tra binary
    if [[ ! -f "$BINARY_NAME" ]]; then
        log_error "Không tìm thấy file $BINARY_NAME!"
        exit 1
    fi
    
    # Kiểm tra binary có thực thi được không
    if ! chmod +x "$BINARY_NAME" 2>/dev/null; then
        log_error "Không thể set quyền thực thi cho binary!"
        exit 1
    fi
    
    # Stop service nếu đang chạy để tránh "Text file busy"
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        log_info "Service đang chạy, đang dừng để cập nhật..."
        systemctl stop "$SERVICE_NAME" || true
        sleep 2
    fi
    
    # Copy binary với retry logic
    local retry_count=0
    local max_retries=3
    
    while [[ $retry_count -lt $max_retries ]]; do
        if cp "$BINARY_NAME" "$BINARY_PATH" 2>/dev/null; then
            chmod +x "$BINARY_PATH"
            break
        else
            retry_count=$((retry_count + 1))
            log_warn "Không thể copy binary (lần thử $retry_count/$max_retries)"
            
            if [[ $retry_count -lt $max_retries ]]; then
                log_info "Đang thử lại sau 3 giây..."
                sleep 3
                
                # Thử force stop service nếu cần
                if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
                    systemctl stop "$SERVICE_NAME" || true
                    sleep 2
                fi
            fi
        fi
    done
    
    # Kiểm tra binary đã được cài đặt
    if [[ ! -f "$BINARY_PATH" ]]; then
        log_error "Không thể copy binary đến $BINARY_PATH sau $max_retries lần thử!"
        log_info "Thử restart system và chạy lại script"
        exit 1
    fi
    
    log_success "Binary đã được cài đặt tại: $BINARY_PATH"
}

create_directories() {
    log_info "Tạo thư mục cần thiết..."
    
    local dirs=("$LOG_DIR" "$CONFIG_DIR" "/usr/overlux/ssh")
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            chmod 755 "$dir"
            log_debug "Đã tạo thư mục: $dir"
        fi
    done
    
    log_success "Thư mục đã được tạo"
}

create_service() {
    log_info "Tạo systemd service..."
    
    # Tạo service file với cấu hình tối ưu cho interactive mode
    cat > "$SERVICE_PATH" << EOF
[Unit]
Description=Overlux Proxy Server
Documentation=https://github.com/AZZ-vopp/overlux
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=$BINARY_PATH
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=overlux

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$LOG_DIR $CONFIG_DIR

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

# Environment variables
Environment=TERM=xterm

[Install]
WantedBy=multi-user.target
EOF
    
    # Kiểm tra service file
    if [[ ! -f "$SERVICE_PATH" ]]; then
        log_error "Không thể tạo service file!"
        exit 1
    fi
    
    log_success "Service file đã được tạo"
}

setup_firewall() {
    log_info "Cấu hình firewall cơ bản..."
    
    # Kiểm tra iptables
    if ! command -v iptables &> /dev/null; then
        log_warn "iptables không được tìm thấy, bỏ qua cấu hình firewall"
        return 0
    fi
    
    # Tạo chain cho overlux nếu chưa có
    if ! iptables -L OVERLUX &> /dev/null; then
        iptables -N OVERLUX 2>/dev/null || true
    fi
    
    log_success "Firewall đã được cấu hình cơ bản"
}

enable_service() {
    log_info "Kích hoạt service..."
    
    # Reload systemd
    if ! systemctl daemon-reload; then
        log_error "Không thể reload systemd daemon!"
        exit 1
    fi
    
    # Enable service
    if ! systemctl enable "$SERVICE_NAME"; then
        log_error "Không thể enable service!"
        exit 1
    fi
    
    log_success "Service đã được kích hoạt"
}

setup_alias() {
    log_info "Cấu hình alias..."
    
    local bashrc_file
    
    # Tìm file bashrc
    if [[ -f /root/.bashrc ]]; then
        bashrc_file="/root/.bashrc"
    elif [[ -f /home/$(logname)/.bashrc ]]; then
        bashrc_file="/home/$(logname)/.bashrc"
    else
        log_warn "Không tìm thấy file .bashrc, bỏ qua cấu hình alias"
        return 0
    fi
    
    # Thêm alias nếu chưa có
    if ! grep -q "alias overlux=" "$bashrc_file" 2>/dev/null; then
        echo "" >> "$bashrc_file"
        echo "# Overlux Proxy Server alias" >> "$bashrc_file"
        echo "alias overlux='sudo $BINARY_PATH'" >> "$bashrc_file"
        log_success "Đã thêm alias 'overlux' vào $bashrc_file"
    else
        log_info "Alias 'overlux' đã tồn tại"
    fi
}

check_activation() {
    if [[ -f "$UNLOCK_FILE" ]]; then
        log_success "Overlux đã được kích hoạt!"
        return 0
    else
        log_warn "Overlux chưa được kích hoạt!"
        return 1
    fi
}

activate_service() {
    log_info "Bắt đầu kích hoạt Overlux..."
    
    # Kiểm tra đã kích hoạt chưa
    if check_activation; then
        log_info "Overlux đã được kích hoạt trước đó!"
        return 0
    fi
    
    echo -e "${YELLOW}⚠️  LƯU Ý:${NC}"
    echo "• Lần đầu chạy sẽ yêu cầu nhập mật khẩu kích hoạt"
    echo "• Mật khẩu được lấy từ file pass.txt trên server cấu hình"
    echo "• Sau khi kích hoạt thành công, service sẽ tự động chạy"
    echo ""
    
    read -p "Nhấn Enter để tiếp tục hoặc Ctrl+C để hủy..."
    
    # Chạy overlux để kích hoạt
    if "$BINARY_PATH"; then
        log_success "Kích hoạt thành công!"
        
        # Kiểm tra service status
        sleep 2
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_success "Service đang chạy!"
        else
            log_warn "Service chưa chạy, đang khởi động..."
            systemctl start "$SERVICE_NAME"
            sleep 2
            if systemctl is-active --quiet "$SERVICE_NAME"; then
                log_success "Service đã khởi động thành công!"
            else
                log_error "Không thể khởi động service!"
                log_info "Kiểm tra log: journalctl -u $SERVICE_NAME -f"
            fi
        fi
    else
        log_error "Kích hoạt thất bại!"
        log_info "Kiểm tra mật khẩu và thử lại"
        return 1
    fi
}

restart_service() {
    log_info "Restart Overlux service..."
    
    # Kiểm tra kích hoạt
    if ! check_activation; then
        log_error "Overlux chưa được kích hoạt!"
        log_info "Chạy kích hoạt trước: sudo $0 2"
        return 1
    fi
    
    # Stop service
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        log_info "Đang dừng service..."
        systemctl stop "$SERVICE_NAME" || true
        sleep 2
    fi
    
    # Start service
    log_info "Đang khởi động service..."
    if systemctl start "$SERVICE_NAME"; then
        sleep 3
        
        # Kiểm tra service status
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_success "Service đã khởi động thành công!"
        else
            log_error "Service không thể khởi động!"
            log_info "Kiểm tra log: journalctl -u $SERVICE_NAME -f"
            return 1
        fi
    else
        log_error "Không thể khởi động service!"
        log_info "Kiểm tra log: journalctl -u $SERVICE_NAME -f"
        return 1
    fi
}

show_status() {
    log_info "Kiểm tra trạng thái cài đặt..."
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📊 TRẠNG THÁI CÀI ĐẶT:${NC}"
    
    # Kiểm tra binary
    if [[ -f "$BINARY_PATH" ]]; then
        echo -e "${GREEN}✅ Binary: $BINARY_PATH${NC}"
    else
        echo -e "${RED}❌ Binary: Không tìm thấy${NC}"
    fi
    
    # Kiểm tra service
    if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}✅ Service: Đã enable${NC}"
    else
        echo -e "${RED}❌ Service: Chưa enable${NC}"
    fi
    
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}✅ Service: Đang chạy${NC}"
    else
        echo -e "${RED}❌ Service: Không chạy${NC}"
    fi
    
    # Kiểm tra kích hoạt
    if check_activation; then
        echo -e "${GREEN}✅ Kích hoạt: Đã kích hoạt${NC}"
    else
        echo -e "${RED}❌ Kích hoạt: Chưa kích hoạt${NC}"
    fi
    
    # Kiểm tra thư mục
    if [[ -d "$LOG_DIR" ]]; then
        echo -e "${GREEN}✅ Log directory: $LOG_DIR${NC}"
    else
        echo -e "${RED}❌ Log directory: Không tìm thấy${NC}"
    fi
    
    if [[ -d "$CONFIG_DIR" ]]; then
        echo -e "${GREEN}✅ Config directory: $CONFIG_DIR${NC}"
    else
        echo -e "${RED}❌ Config directory: Không tìm thấy${NC}"
    fi
    
    # Hiển thị thông tin process
    local pid=$(pgrep -f "$BINARY_PATH" 2>/dev/null || echo "")
    if [[ -n "$pid" ]]; then
        echo -e "${GREEN}✅ Process ID: $pid${NC}"
    else
        echo -e "${RED}❌ Process: Không tìm thấy${NC}"
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

show_troubleshooting() {
    echo -e "${CYAN}"
    echo "🛠️  TROUBLESHOOTING GUIDE:"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}❌ Lỗi thường gặp:${NC}"
    echo "1. Service không khởi động:"
    echo "   journalctl -u $SERVICE_NAME -n 50"
    echo ""
    echo "2. Lỗi 'Text file busy':"
    echo "   sudo systemctl stop $SERVICE_NAME"
    echo "   sudo $0 1"
    echo ""
    echo "3. Không thể kích hoạt:"
    echo "   sudo rm $UNLOCK_FILE"
    echo "   sudo $0 2"
    echo ""
    echo "4. Port bị block:"
    echo "   sudo iptables -L | grep overlux"
    echo "   sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT"
    echo ""
    echo -e "${YELLOW}🔧 Lệnh hữu ích:${NC}"
    echo "• Xem log: journalctl -u $SERVICE_NAME -f"
    echo "• Xem process: ps aux | grep overlux"
    echo "• Xem port: sudo netstat -tlnp | grep overlux"
    echo "• Xem log forwarding: tail -f $LOG_DIR/forwarding.log"
    echo ""
}

show_usage() {
    echo -e "${CYAN}"
    echo "📖 HƯỚNG DẪN SỬ DỤNG:"
    echo -e "${NC}"
    echo "  • Xem trạng thái: sudo systemctl status $SERVICE_NAME"
    echo "  • Xem log: journalctl -u $SERVICE_NAME -f"
    echo "  • Restart: sudo $0 3"
    echo "  • Stop: sudo systemctl stop $SERVICE_NAME"
    echo "  • Chạy lại: sudo overlux"
    echo ""
    echo -e "${YELLOW}⚠️  LƯU Ý QUAN TRỌNG:${NC}"
    echo "  • Lần đầu chạy sẽ yêu cầu nhập mật khẩu kích hoạt"
    echo "  • Service sẽ tự động restart nếu gặp lỗi"
    echo "  • Kiểm tra log nếu service không khởi động"
    echo ""
}

cleanup() {
    log_info "Dọn dẹp file tạm..."
    
    # Xóa repo nếu đã clone
    if [[ -d "$REPO_DIR" ]]; then
        rm -rf "$REPO_DIR"
        log_debug "Đã xóa thư mục repo"
    fi
    
    # Xóa binary tạm
    if [[ -f "$BINARY_NAME" ]]; then
        rm -f "$BINARY_NAME"
        log_debug "Đã xóa binary tạm"
    fi
    
    log_success "Dọn dẹp hoàn tất"
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================
install_overlux() {
    log_info "Bắt đầu cài đặt Overlux Proxy Server..."
    
    # Kiểm tra quyền root
    check_root
    
    # Kiểm tra hệ thống
    check_system
    
    # Backup nếu cần
    backup_existing
    
    # Tải và cài đặt binary
    download_binary
    install_binary
    
    # Tạo thư mục cần thiết
    create_directories
    
    # Tạo service
    create_service
    
    # Cấu hình firewall
    setup_firewall
    
    # Kích hoạt service (không start vì cần kích hoạt trước)
    enable_service
    
    # Cấu hình alias
    setup_alias
    
    # Dọn dẹp
    cleanup
    
    log_success "Cài đặt Overlux Proxy Server hoàn tất!"
}

activate_overlux() {
    log_info "Bắt đầu kích hoạt Overlux..."
    
    # Kiểm tra cài đặt
    if [[ ! -f "$BINARY_PATH" ]]; then
        log_error "Overlux chưa được cài đặt!"
        log_info "Chạy: sudo $0 1"
        return 1
    fi
    
    if ! systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        log_error "Service chưa được enable!"
        log_info "Chạy: sudo $0 1"
        return 1
    fi
    
    # Kích hoạt service
    activate_service
    
    log_success "Kích hoạt Overlux Proxy Server hoàn tất!"
}

restart_overlux() {
    log_info "Bắt đầu restart Overlux..."
    
    # Kiểm tra cài đặt
    if [[ ! -f "$BINARY_PATH" ]]; then
        log_error "Overlux chưa được cài đặt!"
        log_info "Chạy: sudo $0 1"
        return 1
    fi
    
    # Restart service
    restart_service
    
    log_success "Restart Overlux Proxy Server hoàn tất!"
}

install_and_activate() {
    log_info "Bắt đầu cài đặt và kích hoạt Overlux..."
    
    # Cài đặt
    install_overlux
    
    # Kích hoạt
    activate_overlux
    
    log_success "Cài đặt và kích hoạt Overlux Proxy Server hoàn tất!"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    print_banner
    
    # Kiểm tra quyền root
    check_root
    
    # Xử lý command line arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            1)
                install_overlux
                ;;
            2)
                activate_overlux
                ;;
            3)
                restart_overlux
                ;;
            4)
                show_status
                ;;
            5)
                install_and_activate
                ;;
            6)
                show_troubleshooting
                ;;
            0)
                log_info "Tạm biệt!"
                exit 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ: $1"
                exit 1
                ;;
        esac
        
        # Hiển thị trạng thái và hướng dẫn
        show_status
        show_usage
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        echo -e "${CYAN}Chọn hành động (0-6): ${NC}"
        read -r choice
        
        case "$choice" in
            1)
                install_overlux
                show_status
                show_usage
                break
                ;;
            2)
                activate_overlux
                show_status
                show_usage
                break
                ;;
            3)
                restart_overlux
                show_status
                show_usage
                break
                ;;
            4)
                show_status
                ;;
            5)
                install_and_activate
                show_status
                show_usage
                break
                ;;
            6)
                show_troubleshooting
                ;;
            0)
                log_info "Tạm biệt!"
                exit 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                ;;
        esac
        
        echo ""
        read -p "Nhấn Enter để tiếp tục..."
    done
}

# =============================================================================
# ERROR HANDLING
# =============================================================================
trap 'log_error "Script bị dừng bởi signal $?"; exit 1' INT TERM

# =============================================================================
# EXECUTE MAIN
# =============================================================================
main "$@" 