Rem Removal
Rem Deletes all files on the disk, provided that is we find the same file in the Sor
Rem
Rem Usage:
Rem removal.bat [optional foldername]
Rem If we have no folder parameter we will use today's date

Rem Settings
set JAVA_OPTS=-Xmx3072M
if "%1" equ "" (set datestamp=%date:~9,4%-%date:~6,2%-%date:~3,2%) else (set datestamp=%1)
set root_folder=%ROOT%\%datestamp%

if NOT EXIST %root_folder% (
	Echo No tasks to do for %root_folder%
	exit 0
)

if NOT EXIST %root_folder%\instruction.xml (
	echo No instruction found at %root_folder%\instruction.xml
	EXIT -1
)

call groovy %SORIMPORT_HOME%\src\main\flow2\remove_file.groovy %root_folder%\instruction.xml >> %SORIMPORT_HOME%\log\flow2\%datestamp%.rapport.txt
call groovy %SORIMPORT_HOME%\src\main\flow2\remove_folder.groovy %root_folder% >> %SORIMPORT_HOME%\log\flow2\%datestamp%.removal.log
call groovy -cp %SORIMPORT_HOME%\src\main\flow2\mail-1.4.6.jar %SORIMPORT_HOME%\src\main\flow2\mail.groovy %SORIMPORT_HOME%\log\flow2\%datestamp%.rapport.txt

exit 0