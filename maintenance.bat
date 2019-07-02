@ECHO off
powershell -noprofile -command "&{ start-process powershell -ArgumentList '-noprofile -file %~dp0maintenance.ps1' -verb RunAs}"