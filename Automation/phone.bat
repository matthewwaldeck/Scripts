@ECHO off
:: Launches both of the applications needed for the phone system.
:: NEC SP350 as the softphone, and TouchPoint for call queues.

START "" "C:\Program Files (x86)\NEC\SP350\ClientPhone32.exe"
START "" "C:\Program Files (x86)\Telephony\TouchPoint\TouchPoint.exe"