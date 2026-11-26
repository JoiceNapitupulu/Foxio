@echo off
setlocal
title Foxio Dev Launcher
color 0E

echo ==================================================
echo   FOXIO - Lightweight Dev Launcher
echo   Backend API + HP Android USB / Chrome Preview
echo ==================================================
echo.

REM Pastikan semua path SDK terbaca saat dijalankan lewat klik 2x
set "DOTNET_DIR=%USERPROFILE%\.dotnet"
set "FLUTTER_BIN=%USERPROFILE%\flutter\bin"
set "ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%DOTNET_DIR%;%FLUTTER_BIN%;%ANDROID_SDK%\platform-tools;%PATH%"

REM 1. Jalankan Backend ASP.NET Core di jendela terpisah jika port 5188 belum aktif
netstat -ano | findstr /R /C:":5188 .*LISTENING" >nul 2>&1
if not errorlevel 1 goto :backend_ready

echo [1/3] Menyalakan Foxio Backend API di http://localhost:5188 ...
if /i "%~1"=="--dry-run" goto :detect_device
start "Foxio Backend API" /d "%~dp0backend\src\Foxio.API" cmd /k "dotnet watch run"
goto :detect_device

:backend_ready
echo [1/3] Foxio Backend API sudah aktif di port 5188.

:detect_device
REM 2. Deteksi HP Android fisik yang terhubung lewat kabel USB
set "USB_DEVICE="
for /f "skip=1 tokens=1,2" %%A in ('adb devices 2^>nul') do if "%%B"=="device" if not defined USB_DEVICE set "USB_DEVICE=%%A"

cd /d "%~dp0mobile"
if defined USB_DEVICE goto :run_usb

echo [2/3] Tidak ada HP USB terdeteksi - Membuka Preview Ringan di Chrome...
echo [3/3] Menjalankan Foxio di Chrome...
echo       Tips: tekan 'r' = Hot Reload, 'R' = Hot Restart, 'q' = berhenti
echo.
if /i "%~1"=="--dry-run" exit /b 0
call flutter run -d chrome --web-browser-flag="--window-size=430,900"
goto :done

:run_usb
echo [2/3] HP Android fisik terdeteksi [%USB_DEVICE%] - Mengaktifkan USB tunnel adb reverse tcp:5188...
echo [3/3] Menjalankan Foxio ke HP Android fisik...
echo       Tips: tekan 'r' = Hot Reload, 'R' = Hot Restart, 'q' = berhenti
echo.
if /i "%~1"=="--dry-run" exit /b 0
adb -s "%USB_DEVICE%" reverse tcp:5188 tcp:5188
call flutter run -d "%USB_DEVICE%"

:done
pause
