@echo off
set "GODOT=C:\Users\baxte\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if not exist "%GODOT%" (
  echo Godot was not found at the configured path. Import project.godot in your Godot installation instead.
  pause
  exit /b 1
)
"%GODOT%" --path "%~dp0."
