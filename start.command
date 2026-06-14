#!/bin/bash
cd "$(dirname "$0")"

echo "============================================="
echo "   ĐANG KHỞI ĐỘNG MINECRAFT SERVER..."
echo "============================================="

# 1. Kiểm tra xem Docker Desktop đã chạy chưa
if ! docker info >/dev/null 2>&1; then
  echo ""
  echo "❌ LỖI: Docker Desktop chưa được mở!"
  echo "👉 Vui lòng mở ứng dụng Docker Desktop trên máy Mac của bạn rồi chạy lại file này."
  echo "============================================="
  echo "Nhấn phím bất kỳ để thoát..."
  read -n 1 -s -r
  exit 1
fi

# 2. Khởi chạy Docker Compose
docker compose up -d
if [ $? -ne 0 ]; then
  echo ""
  echo "❌ LỖI: Không thể khởi chạy Docker Compose!"
  echo "👉 Có thể do cổng kết nối (25565 hoặc 19132) đã bị ứng dụng khác sử dụng."
  echo "============================================="
  echo "Nhấn phím bất kỳ để xem log lỗi..."
  read -n 1 -s -r
  docker compose logs
  exit 1
fi

# 3. Đợi server và RCON sẵn sàng (tối đa 90 giây)
echo "Đang đợi server khởi động và RCON sẵn sàng (tối đa 90 giây)..."
COUNTER=0
MAX_WAIT=90
SUCCESS=false

while [ $COUNTER -lt $MAX_WAIT ]; do
  # Kiểm tra xem container còn chạy không (tránh đợi vô ích nếu bị crash)
  if [ "$(docker inspect -f '{{.State.Running}}' minecraft-fabric 2>/dev/null)" != "true" ]; then
    echo ""
    echo "❌ LỖI: Server Minecraft đã bị dừng đột ngột (Crash)!"
    echo "============================================="
    echo "Nhấn phím bất kỳ để xem log lỗi chi tiết..."
    read -n 1 -s -r
    docker compose logs
    exit 1
  fi

  # Kiểm tra kết nối RCON
  if docker exec -i minecraft-fabric rcon-cli "list" >/dev/null 2>&1; then
    SUCCESS=true
    break
  fi

  echo -n "."
  sleep 1
  COUNTER=$((COUNTER + 1))
done

if [ "$SUCCESS" = false ]; then
  echo ""
  echo "⚠️ CẢNH BÁO: Server đang tải lâu hơn bình thường."
  echo "👉 Có thể bản đồ (world) của bạn đang được tạo hoặc máy tải nặng."
  echo "Bạn vẫn có thể thử vào game kết nối, hoặc:"
  echo "============================================="
  echo "Nhấn phím bất kỳ để xem log hoạt động hiện tại..."
  read -n 1 -s -r
  docker compose logs
  exit 1
fi
echo ""

# Lấy các thông tin IP
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || ifconfig | grep -E "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
PUBLIC_IP=$(curl -s --max-time 2 icanhazip.com 2>/dev/null | tr -d '\n' || echo "Không thể lấy")

echo "============================================="
echo "🎮 HƯỚNG DẪN KẾT NỐI VÀO SERVER MINECRAFT:"
echo ""
echo "💻 DÀNH CHO MÁY TÍNH (JAVA EDITION - Cổng mặc định 25565):"
if [ ! -z "$LOCAL_IP" ]; then
  echo "   - Cùng mạng Wifi (LAN):             $LOCAL_IP:25565"
fi
if [ "$PUBLIC_IP" != "Không thể lấy" ] && [ ! -z "$PUBLIC_IP" ]; then
  echo "   - Khác mạng Wifi (Ngoài Internet):  $PUBLIC_IP:25565"
fi
echo ""
echo "📱 DÀNH CHO ĐIỆN THOẠI / IPAD / BEDROCK (PE - Cổng mặc định 19132):"
if [ ! -z "$LOCAL_IP" ]; then
  echo "   - Cùng mạng Wifi (LAN):             Địa chỉ: $LOCAL_IP   Cổng (Port): 19132"
fi
if [ "$PUBLIC_IP" != "Không thể lấy" ] && [ ! -z "$PUBLIC_IP" ]; then
  echo "   - Khác mạng Wifi (Ngoài Internet):  Địa chỉ: $PUBLIC_IP   Cổng (Port): 19132"
fi
echo "============================================="
echo "Nhấn phím bất kỳ để vào console game..."
read -n 1 -s -r

echo ""
echo "============================================="
echo "   ĐÃ KẾT NỐI VỚI CONSOLE GAME!"
echo "   (Nhấn Ctrl+C hoặc gõ 'exit' để thoát)"
echo "============================================="
docker exec -it minecraft-fabric rcon-cli
