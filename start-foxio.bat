@echo off
title Foxio Dev Launcher
color 0E

echo ==================================================
echo   FOXIO - All-in-One Dev Launcher
echo   Backend API + Android Emulator + Flutter App
echo ==================================================
echo.

REM Pastikan semua path SDK terbaca saat dijalankan lewat klik 2x
set "DOTNET_DIR=%USERPROFILE%\.dotnet"
set "FLUTTER_BIN=%USERPROFILE%\flutter\bin"
set "ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk"
set "PATH=%DOTNET_DIR%;%FLUTTER_BIN%;%ANDROID_SDK%\platform-tools;%ANDROID_SDK%\emulator;%PATH%"

REM 1. Jalankan Backend ASP.NET Core di jendela terpisah
echo [1/3] Menyalakan Foxio Backend API (http://localhost:5188)...
start "Foxio Backend API" cmd /k "cd /d d:\DummyProject\Foxio\backend\src\Foxio.API && set PATH=%DOTNET_DIR%;%PATH% && dotnet watch run"

REM 2. Cek apakah Emulator Android sudah menyala; jika belum, jalankan
echo [2/3] Memeriksa Android Emulator (medium_phone)...
adb devices | findstr /R /C:"emulator-[0-9]*[	 ]*device" >nul 2>&1
if errorlevel 1 (
    echo       Menyalakan emulator medium_phone...
    start "" /b cmd /c "flutter emulators --launch medium_phone"
    echo       Menunggu Android Emulator selesai booting...
    adb wait-for-device
    :wait_boot
    for /f "delims=" %%i in ('adb shell getprop sys.boot_completed 2^>nul') do set "BOOTED=%%i"
    if not "%BOOTED%"=="1" (
        timeout /t 3 /nobreak >nul
        goto wait_boot
    )
    echo       Android Emulator siap!
) else (
    echo       Android Emulator sudah aktif!
)

REM 3. Jalankan Flutter App di jendela ini (tekan r = Hot Reload, R = Hot Restart, q = Quit)
echo.
echo [3/3] Menjalankan Flutter App Foxio ke Emulator...
echo       (Tips: tekan 'r' untuk Hot Reload, 'R' untuk Hot Restart, 'q' untuk berhenti)
echo.
cd /d d:\DummyProject\Foxio\mobile
flutter run

pause
