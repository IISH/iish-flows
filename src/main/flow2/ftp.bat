Rem ftp.bat
Rem 
Rem Usage:
Rem ftp.bat [datestamp yyyy-mm-dd]

call %SORIMPORT_HOME%\config.bat

set JAVA_OPTS=-Xmx3072M
if "%1" equ "" (set datestamp=%date:~9,4%-%date:~6,2%-%date:~3,2%) else (set datestamp=%1)
set root_folder=%ROOT_FLOW2%\%datestamp%
set log_files=%SORIMPORT_HOME%\log\flow2\flow2\%datestamp%.files.ftp.log
set log_instruction=%SORIMPORT_HOME%\log\flow2\flow2\%datestamp%.instruction.ftp.log
set log_retry=%SORIMPORT_HOME%\log\flow2\flow2\%datestamp%.retry.ftp.log
set ftp_script=%SORIMPORT_HOME%\log\flow2\flow2\%datestamp%.stagingarea.objectrepository.org.ftp.txt

net use %SHARE_FLOW2%
if NOT EXIST %root_folder% (
	Echo No tasks to do for %root_folder%
	exit 0
)

Rem LCD to the root directory. This will be the working directory from the point of view of WinSCP
%ROOT_FLOW2%
cd %ROOT_FLOW2%
echo root_folder=%root_folder%

if EXIST %log_files% DEL %log_files%
if EXIST %log_instruction% DEL %log_instruction%
if EXIST %log_retry% DEL %log_retry%
if EXIST %root_folder%\instruction.xml DEL %root_folder%\instruction.xml

Rem Create the upload ftp_script and start it
echo option batch continue>%ftp_script%
echo option confirm off>>%ftp_script%
echo option transfer binary>>%ftp_script%
echo option reconnecttime 5>>%ftp_script%
echo open %ftp%>>%ftp_script%
echo put %datestamp%>>%ftp_script%
echo close>>%ftp_script%
echo exit>>%ftp_script%
%WinSCP% /console /script=%ftp_script% /parameter %datestamp% /log:%log_files%
set log=%log_files%
call %SORIMPORT_HOME%\src\main\flow2\retry.bat

Rem Produce instruction
call groovy %SORIMPORT_HOME%\src\main\flow2\instruction -na %NA% -fileSet %root_folder% -autoIngestValidInstruction true -label "%datestamp% batch filer4" -notificationEMail lwo@iisg.nl
Rem Upload the instruction
echo option batch continue>%ftp_script%
echo option confirm off>>%ftp_script%
echo option transfer binary>>%ftp_script%
echo option reconnecttime 5>>%ftp_script%
echo open %ftp%>>%ftp_script%
echo put %datestamp%\instruction.xml %datestamp%/instruction.xml>>%ftp_script%
echo close>>%ftp_script%
echo exit>>%ftp_script%
%WinSCP% /console /script=%ftp_script% /parameter %datestamp% /log:%log_instruction%
set log=%log_instruction%
call %SORIMPORT_HOME%\src\main\flow2\retry.bat