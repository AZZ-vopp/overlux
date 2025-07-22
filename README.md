# 🚀 Overlux Proxy Manager

## Giới thiệu
**Overlux** là phần mềm proxy chuyển tiếp cao cấp, tối ưu cho tốc độ, độ ổn định, bảo mật và quản lý dễ dàng. Hỗ trợ cân bằng tải, cảnh báo quá tải, tự động tối ưu hệ thống mạng, gửi thông báo Telegram, và nhiều tính năng nâng cao khác.

---

## 🌟 Tính năng nổi bật
- Chuyển tiếp proxy TCP tối ưu, hỗ trợ PROXY Protocol
- Cân bằng tải (Load Balancing) nhiều backend, round-robin
- Tự động tối ưu hệ thống mạng, bật BBR, tăng buffer, giảm ping
- Chống DDoS SSH: Yêu cầu đổi port SSH khi cài đặt
- Cảnh báo quá tải CPU/RAM về Telegram cá nhân
- Quản lý menu tiếng Việt, thao tác dễ dàng
- Tự động chạy nền, có thể gọi `overlux` ở bất kỳ thư mục nào
- Lưu giữ cấu hình khi cập nhật phần mềm

---

## 🚀 Cài đặt nhanh
```bash
curl -sSL https://raw.githubusercontent.com/AZZ-vopp/overlux/main/install.sh | bash
```

Sau khi cài đặt, bạn có thể gõ `overlux` ở bất kỳ thư mục nào để mở menu quản lý.

---

## 📖 Hướng dẫn sử dụng
- **Cài đặt proxy chuyển tiếp:**
  - Yêu cầu nhập port SSH mới để bảo vệ chống DDoS.
  - Quá trình cài đặt hiển thị tiến trình % chuyên nghiệp.
- **Thêm/xóa/sửa cấu hình proxy:**
  - Hỗ trợ nhiều IP backend, cân bằng tải tự động.
- **Cảnh báo quá tải VPS:**
  - Nhập token và chat_id Telegram cá nhân, nhận cảnh báo khi CPU/RAM >80%.
- **Cập nhật phần mềm:**
  - Tự động giữ lại cấu hình cũ, tải bản mới nhất từ GitHub Releases.

---

## 🔒 Bảo mật & Lưu ý
- Tự động đổi port SSH khi cài đặt, chống scan SSH mặc định.
- Giao diện cài đặt trực quan, thân thiện, không gây rối cho người dùng.

---

## 🛠️ Tối ưu hệ thống
- Bật `net.ipv4.ip_forward=1` và các sysctl tối ưu TCP, buffer, BBR.
- Tăng buffer TCP, retry khi mất gói, đảm bảo ổn định và tốc độ cao.

---

## 📞 Hỗ trợ & Liên hệ
- Telegram Dev: [@tnetz](https://t.me/tnetz)
- Website: [https://shoptnetz.com](https://shoptnetz.com)
- Đóng góp, báo lỗi, đề xuất: Vui lòng tạo Issue hoặc Pull Request trên GitHub.

---

**⭐ Nếu bạn thấy dự án hữu ích, hãy cho Overlux một star trên GitHub!** 