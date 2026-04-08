@echo off
title SkyPredict Air Monitoring System
echo.
echo ============================================
echo   SkyPredict Air Monitoring System
echo   Starting all services...
echo ============================================
echo.

:: Start ML Prediction Server (Python)
echo [1/3] Starting ML Server (port 8000)...
start "SkyPredict ML Server" cmd /k "cd /d %~dp0ml_model && python server.py"
timeout /t 3 /nobreak > nul

:: Start Node.js Backend (serves frontend too)
echo [2/3] Starting Backend Server (port 3000)...
start "SkyPredict Backend" cmd /k "cd /d %~dp0backend && npm start"
timeout /t 2 /nobreak > nul

:: Start Sensor Bridge (simulation mode)
echo [3/3] Starting Sensor Bridge (10s intervals)...
start "SkyPredict Sensors" cmd /k "cd /d %~dp0hardware && node sensor_bridge.js"
timeout /t 2 /nobreak > nul

echo.
echo ============================================
echo   All services started!
echo.
echo   Dashboard:  http://localhost:3000
echo   ML Server:  http://localhost:8000
echo   Sensors:    Posting every 10 seconds
echo ============================================
echo.
echo Press any key to open the dashboard...
pause > nul
start http://localhost:3000
