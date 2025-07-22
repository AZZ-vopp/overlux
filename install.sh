#!/bin/bash
# Script cài đặt Overlux Proxy Manager từ GitHub
set -e

REPO="https://github.com/AZZ-vopp/overlux.git"
DIR="overlux"
CONFIG="proxy_backup.json"

if ! command -v git &> /dev/null; then
  echo "Vui lòng cài đặt git trước khi tiếp tục!"
  exit 1
fi

# Clone hoặc pull repo
if [ -d "$DIR" ]; then
  cd "$DIR"
  git pull origin main
else
  git clone "$REPO"
  cd "$DIR"
fi

# Giữ lại file cấu hình backup nếu có
if [ -f "../$CONFIG" ]; then
  cp "../$CONFIG" .
fi

chmod +x overlux

# Hiện tiến trình % cài đặt
for i in $(seq 1 100); do
  echo -ne "\rĐang cài đặt: $i%"
  sleep 0.01
done
echo -e "\nHoàn tất cài đặt!"

# Tạo service systemd cho overlux nếu là Linux
if [[ "$(uname)" == "Linux" ]]; then
  SERVICE_FILE="/etc/systemd/system/overlux.service"
  sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Overlux Proxy Manager
After=network.target

[Service]
Type=simple
ExecStart=$(pwd)/overlux
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable overlux
  sudo systemctl start overlux
  echo "Đã tạo service systemd: overlux.service"
  echo "Dùng lệnh: sudo systemctl start overlux && sudo systemctl status overlux"
fi 