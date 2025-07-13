# 🚀 Overlux Proxy Server

<div align="center">

![Overlux Logo](https://img.shields.io/badge/Overlux-Proxy%20Server-blue?style=for-the-badge&logo=server)
![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-2.0.0-orange?style=for-the-badge)

**High-Performance Proxy Server với Load Balancing Round-Robin**

[![GitHub stars](https://img.shields.io/github/stars/AZZ-vopp/overlux?style=social)](https://github.com/AZZ-vopp/overlux/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/AZZ-vopp/overlux?style=social)](https://github.com/AZZ-vopp/overlux/network)
[![GitHub issues](https://img.shields.io/github/issues/AZZ-vopp/overlux)](https://github.com/AZZ-vopp/overlux/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/AZZ-vopp/overlux)](https://github.com/AZZ-vopp/overlux/pulls)

</div>

---

## 📋 Mục lục

- [🌟 Tính năng](#-tính-năng)
- [🚀 Cài đặt nhanh](#-cài-đặt-nhanh)
- [📖 Hướng dẫn sử dụng](#-hướng-dẫn-sử-dụng)
- [🔧 Cấu hình](#-cấu-hình)
- [📊 Monitoring](#-monitoring)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🤝 Đóng góp](#-đóng-góp)
- [📄 License](#-license)

---

## 🌟 Tính năng

### 🔄 Load Balancing
- **Round-Robin Load Balancing**: Phân phối kết nối đều cho nhiều backend
- **Multi-Backend Support**: Hỗ trợ nhiều backend cho mỗi rule
- **Dynamic Backend Management**: Thêm/xóa/sửa backend trong runtime
- **Health Monitoring**: Theo dõi trạng thái backend

### 🚀 Performance
- **TCP/UDP Forwarding**: Hỗ trợ cả TCP và UDP với tối ưu hóa
- **Low Latency Mode**: Giảm độ trễ tối đa
- **Buffer Optimization**: Tối ưu buffer size cho hiệu suất cao
- **Connection Pooling**: Quản lý kết nối hiệu quả

### 🛡️ Security
- **Anti-DDoS Protection**: Bảo vệ chống DDoS tự động
- **Country Whitelist**: Chặn theo quốc gia
- **SSH Key Management**: Quản lý SSH key tự động
- **Traffic Encryption**: Mã hóa lưu lượng

### 📱 Management
- **Vietnamese Menu**: Giao diện tiếng Việt dễ sử dụng
- **Real-time Monitoring**: Theo dõi real-time
- **Log Management**: Hệ thống log chi tiết

### 🔧 Advanced Features
- **PROXY Protocol v1/v2**: Hỗ trợ PROXY Protocol
- **Live Stream Optimization**: Tối ưu cho live streaming
- **Speedtest Support**: Tích hợp speedtest
- **Systemd Service**: Chạy như systemd service

---

## 🚀 Cài đặt nhanh

### Phương pháp 1: Git Clone (Khuyến nghị)

```bash
# Clone repository
git clone https://github.com/AZZ-vopp/overlux.git
cd overlux

# Cài đặt và kích hoạt (All-in-One)
sudo bash install.sh 5
```

### Phương pháp 2: Interactive Mode

```bash
# Clone repository
git clone https://github.com/AZZ-vopp/overlux.git
cd overlux

# Chạy script với menu tương tác
sudo bash install.sh
```

### Phương pháp 3: Step by Step

```bash
# Clone repository
git clone https://github.com/AZZ-vopp/overlux.git
cd overlux

# Cài đặt
sudo bash install.sh 1

# Kích hoạt
sudo bash install.sh 2

# Restart nếu cần
sudo bash install.sh 3
```

---

## 📖 Hướng dẫn sử dụng

### 🎯 Khởi động lần đầu

```bash
# Cách 1: All-in-One (Khuyến nghị)
sudo bash install.sh 5

# Cách 2: Interactive Mode
sudo bash install.sh

# Cách 3: Step by Step
sudo bash install.sh 1  # Cài đặt
sudo bash install.sh 2  # Kích hoạt

# Cách 4: Chạy trực tiếp
sudo overlux
```

### 🔧 Quản lý Service

```bash
# Xem trạng thái
sudo systemctl status overlux

# Khởi động
sudo systemctl start overlux

# Dừng
sudo systemctl stop overlux

# Restart (Khuyến nghị)
sudo bash install.sh 3

# Restart thủ công
sudo systemctl restart overlux

# Enable auto-start
sudo systemctl enable overlux
```

### 📊 Xem Logs

```bash
# Xem log service
journalctl -u overlux -f

# Xem log forwarding
tail -f /var/log/overlux/forwarding.log

# Xem log real-time
journalctl -u overlux --follow --lines=50
```

---

## 🔧 Cấu hình

### 📋 Load Balancing Configuration

#### Thêm Rule với Load Balancing

1. **Chọn "Quản lý chuyển tiếp"**
2. **Chọn "Thêm rule mới"**
3. **Nhập port lắng nghe** (VD: 8080)
4. **Thêm backend đầu tiên** (IP:port)
5. **Thêm backend khác** (y/n)
6. **Hoàn tất**

#### Ví dụ cấu hình:

```
Port: 8080
Backend 1: 192.168.1.100:8080
Backend 2: 192.168.1.101:8080
Backend 3: 192.168.1.102:8080
```

### 🌍 Country Whitelist

```bash
# Thêm quốc gia vào whitelist
Menu → Quản lý chặn quốc gia → Thêm quốc gia
# Nhập mã quốc gia: VN, US, JP, etc.
```

### 🛡️ Anti-DDoS Settings

```bash
# Bật/tắt Anti-DDoS
Menu → Bật Anti-DDoS / Tắt Anti-DDoS
```

---

## 📊 Monitoring

### 📈 Real-time Statistics

```bash
# Xem thống kê real-time
sudo overlux
# Menu sẽ hiển thị:
# - Số kết nối đang hoạt động
# - Tổng kết nối
# - Số backend
# - Trạng thái load balancing
```

### 🔍 System Monitoring

```bash
# Xem process
ps aux | grep overlux

# Xem port đang mở
sudo netstat -tlnp | grep overlux

# Xem memory usage
top -p $(pgrep overlux)
```

### 📊 Performance Metrics

- **Connection Count**: Số kết nối đồng thời
- **Throughput**: Băng thông sử dụng
- **Latency**: Độ trễ trung bình
- **Backend Health**: Trạng thái backend

---

## 🛠️ Troubleshooting

### ❌ Lỗi thường gặp

#### 1. Service không khởi động

```bash
# Kiểm tra log
journalctl -u overlux -n 50

# Kiểm tra quyền
ls -la /usr/local/bin/overlux

# Kiểm tra kích hoạt
ls -la /etc/overlux/.unlocked

# Nếu chưa kích hoạt, chạy:
sudo bash install.sh 2

# Restart service (Khuyến nghị)
sudo bash install.sh 3

# Hoặc restart thủ công
sudo systemctl restart overlux
```

#### 2. Port bị block

```bash
# Kiểm tra firewall
sudo iptables -L | grep overlux

# Mở port thủ công
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

#### 3. Load Balancing không hoạt động

```bash
# Kiểm tra backend
sudo overlux
# Menu → Quản lý chuyển tiếp → Xem rules

# Test kết nối backend
telnet backend-ip backend-port
```

#### 4. Không thể kích hoạt

```bash
# Kiểm tra mật khẩu
# Đảm bảo có mật khẩu kích hoạt từ pass.txt

# Reset kích hoạt nếu cần
sudo rm /etc/overlux/.unlocked
sudo overlux

# Hoặc sử dụng script kích hoạt
sudo bash install.sh 2
```

#### 5. Lỗi "Text file busy" khi cài đặt

```bash
# Lỗi này xảy ra khi service đang chạy
# Giải pháp:

# Cách 1: Sử dụng script restart (Khuyến nghị)
sudo bash install.sh 3

# Cách 2: Stop service thủ công
sudo systemctl stop overlux
sudo bash install.sh 1

# Cách 3: Force restart
sudo systemctl stop overlux
sleep 3
sudo systemctl start overlux
```

#### 6. Telegram bot không gửi thông báo

```bash
# Kiểm tra cấu hình Telegram
# Đảm bảo bot token và chat ID đúng
# Kiểm tra kết nối internet
```

### 🔧 Debug Mode

```bash
# Chạy với debug mode
DEBUG=true sudo overlux

# Xem log chi tiết
journalctl -u overlux --follow --lines=100
```

---

## 🤝 Đóng góp

### 📝 Cách đóng góp

1. **Fork repository**
   ```bash
   git clone https://github.com/AZZ-vopp/overlux.git
   ```

2. **Tạo branch mới**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

4. **Push và tạo Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### 🐛 Báo lỗi

- Tạo [Issue](https://github.com/AZZ-vopp/overlux/issues) với mô tả chi tiết
- Đính kèm log và screenshot nếu có
- Cung cấp thông tin hệ thống

### 💡 Đề xuất tính năng

- Tạo [Discussion](https://github.com/AZZ-vopp/overlux/discussions)
- Mô tả chi tiết tính năng mong muốn
- Thảo luận với community


---

<div align="center">

**⭐ Nếu dự án này hữu ích, hãy cho chúng tôi một star! ⭐**

</div> 