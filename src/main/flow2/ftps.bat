Rem start.bat
Rem
Rem Will iterate over the desired folder; take all subfolders; and for each kickstart the creation of an instruction.
Rem For example, if we have two sub folders:
Rem \ROOT_FLOW2\folder_1
Rem \ROOT_FLOW2\folder_2
Rem Then there will be two independent calls:
Rem ftp.bat folder_1
Rem ftp.bat folder_2
Rem
Rem Usage:
Rem start.bat [folder]

net use %SHARE_FLOW2%

$files=Get-ChildItem $ROOT_FLOW2 | ?{ $_.PSIsContainer } | Select-Object FullName
PS C:\Users\Administrator> forEach( $item in $files ) {echo $item}