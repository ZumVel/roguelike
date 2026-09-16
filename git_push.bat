@echo off
chcp 65001 > nul

git add .

git commit -m "auto-update: %date% %time%"

git push origin main

pause