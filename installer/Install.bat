@echo off
cd %~dp0
powershell -ExecutionPolicy ByPass ".\src\Install.ps1"