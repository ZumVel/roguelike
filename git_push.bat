@echo off
chcp 65001 > nul

git add .

git commit -m "auto-update"

git push origin main

pause