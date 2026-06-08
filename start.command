#!/bin/bash
cd "$(dirname "$0")"

echo "============================================="
echo "   ĐANG KHỞI ĐỘNG MINECRAFT SERVER..."
echo "============================================="
docker compose up -d

echo "Đang đợi console RCON sẵn sàng (có thể mất vài giây)..."
until docker exec -i minecraft-fabric rcon-cli "list" >/dev/null 2>&1
do
  echo -n "."
  sleep 1
done
echo ""

# Lấy các thông tin IP
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || ifconfig | grep -E "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
PUBLIC_IP=$(curl -s --max-time 2 icanhazip.com 2>/dev/null | tr -d '\n' || echo "Không thể lấy")

echo "============================================="
if [ ! -z "$LOCAL_IP" ]; then
  echo "   - Kết nối cùng mạng Wifi (LAN):     $LOCAL_IP:25565"
fi
if [ "$PUBLIC_IP" != "Không thể lấy" ] && [ ! -z "$PUBLIC_IP" ]; then
  echo "   - Kết nối ngoài mạng (Public IP):   $PUBLIC_IP:25565"
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
