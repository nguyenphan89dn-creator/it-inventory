@echo off
title KIEM TRA CAU HINH MAY

echo.
echo =====================================
echo      KIEM KE THIET BI CNTT
echo =====================================
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0inventory.ps1"

echo.
echo =====================================
echo      DA HOAN THANH
echo =====================================
echo.
pause
