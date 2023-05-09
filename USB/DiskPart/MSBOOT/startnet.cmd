@echo off
echo "Startnet Windows 10 USB -  version 1.1"
wpeinit
for %%a in (C D E F G H I) do @if exist %%a:\Images\ set IMAGESDRIVE=%%a
:: echo Found %IMAGESDRIVE%
cd /d %IMAGESDRIVE%:\
:: pause
menu.cmd


