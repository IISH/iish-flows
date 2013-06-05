Rem Removals
Rem Iterates thought the main folder; get all subfolder names; then calls removal.bat plus the sub foldername
Rem
Rem Rem For example, if we have two sub folders:
Rem \ROOT_FLOW2\folder_1
Rem \ROOT_FLOW2\folder_2
Rem Then there will be two independent calls:
Rem removal.bat folder_1
Rem removal.bat folder_2

Rem Usage: removals.bat

Rem Settings
set JAVA_OPTS=-Xmx3072M
net use %SHARE_FLOW2%

call groovy %SORIMPORT_HOME%\src\main\flow2\run_app.groovy %ROOT_FLOW2% removal.bat