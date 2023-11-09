@echo off
:: https://community.spiceworks.com/scripts/show/1577-clear-and-reset-print-spooler
echo Stopping print spooler.
echo.
net stop spooler
echo deleting temp files.
echo.
del %windir%\system32\spool\printers\*.* /q
echo Starting print spooler.
echo.
net start spooler
