#!/bin/bash
cd "$(dirname "$0")"

echo "============================================="
echo "   ĐANG TẮT MINECRAFT SERVER..."
echo "============================================="
docker compose down

echo ""
echo "============================================="
echo "   ĐÃ TẮT SERVER THÀNH CÔNG!"
echo "============================================="
sleep 2
