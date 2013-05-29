Rem There are always one or more files that failed to transport properly.
Rem We will use the log to detect such events.

:retry
set script=%SORIMPORT_HOME%\temp\%datestamp%.stagingarea.objectrepository.org.retry.txt
echo option batch continue>%script%
echo option confirm off>>%script%
echo option transfer binary>>%script%
echo option reconnecttime 5>>%script%
echo open %ftp%>>%script%
if EXIST %log_retry% del %log_retry%
copy %log% %log_retry%
if NOT EXIST %log_retry% (
	echo No ftp log found at %log_retry%
	exit -1
)
if EXIST DEL %ftp_script%
call groovy %SORIMPORT_HOME%\src\main\flow2\retry %log_retry% %ftp_script%
if EXIST %ftp_script% (
	del %log_retry%
	%WinSCP% /console /script=%ftp_script% /parameter %datestamp% /log:%log_retry%
	goto retry
)