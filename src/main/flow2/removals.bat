Rem Removals
Rem Iterates thought the main folder; get all subfolder names; then calls removal.bat plus the sub foldername
Rem
Rem Usage: removals.bat

Rem Settings
set JAVA_OPTS=-Xmx3072M
net use %SHARE_FLOW2%

call groovy %SORIMPORT_HOME%\src\main\global\run_app.groovy %ROOT_FLOW2% removal.bat