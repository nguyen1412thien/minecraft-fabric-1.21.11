@echo off
cd /d "%~dp0"
chcp 65001 > nul

:: 1. Tự động tải Java Portable nếu chưa có
if not exist "%~dp0jdk\bin\java.exe" (
    echo ==============================================================
    echo [INFO] KHÔNG TÌM THẤY JAVA PORTABLE!
    echo Đang tự động tải và giải nén JDK 21 (Temurin)...
    echo Quá trình này chỉ diễn ra trong lần chạy đầu tiên.
    echo ==============================================================
    
    :: Tạo thư mục jdk nếu chưa có
    if not exist "%~dp0jdk" mkdir "%~dp0jdk"
    
    :: Gọi PowerShell tải và giải nén trực tiếp
    powershell -NoProfile -Command "$url='https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/adoptium?project=jdk'; Write-Host '1/3. Đang tải file Java zip...'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri $url -OutFile 'jdk.zip'; Write-Host '2/3. Đang giải nén Java...'; Expand-Archive -Path 'jdk.zip' -DestinationPath 'jdk_temp'; $dir=Get-ChildItem -Path 'jdk_temp' -Directory | Select-Object -First 1; Move-Item -Path \"$($dir.FullName)\*\" -Destination 'jdk'; Write-Host '3/3. Đang dọn dẹp file tạm...'; Remove-Item -Path 'jdk.zip'; Remove-Item -Path 'jdk_temp' -Recurse; Write-Host 'Tải Java thành công!'"
)

:: 2. Xác định lệnh Java
set JAVA_CMD="%~dp0jdk\bin\java.exe"

if not exist %JAVA_CMD% (
    echo [LỖI] Không tìm thấy Java Portable sau khi tải.
    echo Vui lòng kiểm tra kết nối mạng và chạy lại file.
    pause
    exit
)

echo =============================================
echo    ĐANG KHỞI ĐỘNG MINECRAFT NATIVE SERVER...
echo =============================================

echo Đang kiểm tra địa chỉ IP...
set LOCAL_IP=
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.InterfaceAlias -notlike '*Loopback*' } | Select-Object -First 1).IPAddress"`) do set LOCAL_IP=%%i

set PUBLIC_IP=
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Invoke-WebRequest -Uri 'https://icanhazip.com' -TimeoutSec 2).Content.Trim() 2>$null"`) do set PUBLIC_IP=%%i
if "%PUBLIC_IP%"=="" set PUBLIC_IP=Không thể lấy

echo =============================================
echo 🎮 HƯỚNG DẪN KẾT NỐI VÀO SERVER MINECRAFT:
echo.
echo 💻 DÀNH CHO MÁY TÍNH (JAVA EDITION - Cổng mặc định 25565):
if not "%LOCAL_IP%"=="" (
    echo    - Cùng mạng Wifi (LAN):             %LOCAL_IP%:25565
)
if not "%PUBLIC_IP%"=="Không thể lấy" if not "%PUBLIC_IP%"=="" (
    echo    - Khác mạng Wifi (Ngoài Internet):  %PUBLIC_IP%:25565
)
echo.
echo 📱 DÀNH CHO ĐIỆN THOẠI / IPAD / BEDROCK (PE - Cổng mặc định 19132):
if not "%LOCAL_IP%"=="" (
    echo    - Cùng mạng Wifi (LAN):             Địa chỉ: %LOCAL_IP%   Cổng: 19132
)
if not "%PUBLIC_IP%"=="Không thể lấy" if not "%PUBLIC_IP%"=="" (
    echo    - Khác mạng Wifi (Ngoài Internet):  Địa chỉ: %PUBLIC_IP%   Cổng: 19132
)
echo =============================================
echo.

cd data
%JAVA_CMD% -Xms3G -Xmx3G -XX:+UseZGC -jar fabric-server-mc.1.21.11-loader.0.19.3-launcher.1.1.1.jar nogui
pause
