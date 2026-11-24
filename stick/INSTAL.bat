@echo off
set "GB=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%GB%" (
  echo Git for Windows belum terpasang. Pasang dulu dari https://git-scm.com/download/win lalu jalankan lagi.
  pause
  exit /b 1
)
"%GB%" "%~dp0install-windows.sh"
