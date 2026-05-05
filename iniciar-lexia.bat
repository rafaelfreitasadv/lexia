@echo off
title Lexia - Servidor Local
cd /d "%~dp0"
echo.
echo ============================================
echo   LEXIA - Servidor de teste local
echo ============================================
echo.
echo Pasta: %CD%
echo.
echo Verificando se a porta 8000 ja esta em uso...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8000" ^| findstr "LISTENING"') do (
  echo Porta 8000 em uso pelo PID %%a, encerrando...
  taskkill /F /PID %%a >nul 2>&1
)
timeout /t 1 /nobreak >nul

echo Iniciando servidor PowerShell em http://localhost:8000 ...
echo Abrindo Chrome em 3 segundos...
echo Para parar o servidor: feche esta janela.
echo.
start "" "http://localhost:8000"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
