REM ******************************************************************************************** 
REM This is a script to copy all the ICW files, and dlls, that pharmacy uses from the ICW side
REM to the pharmacy trunk. This is normaly done at the start of regression
REM 
REM Install the latest release of the ICW server
REM SHUTDOWN all instance of VS
REM Ensure you have nothing checked out, and then do a get on your pharmacy trunk
REM Run this bat file (as admin) with two command parameters 
REM		1. The installed location of the ICW server (without final \ and not in quotes)
REM 	2. The location of the ICW trunk (without final \ and not in quotes)
REM e.g. CopyFilesFromICW.bat c:\interpub\wwwroot\ASCICW_Live-10-15-0-000 D:\SourceCode\Pharmacy\Branches\Trunk
REM 
REM Once the script has run there maybe red error messages this is where the script tries to add
REM missing files, and there are errors as the files exist.
REM 
REM Finally check in all the changes in TFS, any files that have been deleted from the ICW will
REM error at the check-in stage, and should be manually deleted
REM ******************************************************************************************** 

ECHO Doing App_Code
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\App_Code" /recursive
xcopy /y /s "%1\App_Code" "%2\Web\App_Code"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\App_Code\*.*" /recursive

ECHO Doing Web Site
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\DrugAdministration\" /recursive
del /S /Q "%2\Web\application\DrugAdministration\"
xcopy /y /s "%1\application\DrugAdministration" "%2\Web\application\DrugAdministration"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\DrugAdministration\" /recursive

"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\NotesEditor\" /recursive
del /S /Q "%2\Web\application\NotesEditor\"
xcopy /y /s "%1\application\NotesEditor" "%2\Web\application\NotesEditor"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\NotesEditor\" /recursive

"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\OrderEntry\" /recursive
del /S /Q "%2\Web\application\OrderEntry\"
xcopy /y /s "%1\application\OrderEntry" "%2\Web\application\OrderEntry"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\OrderEntry\" /recursive

"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\Printing\" /recursive
del /S /Q "%2\Web\application\Printing\"
xcopy /y /s "%1\application\Printing" "%2\Web\application\Printing"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\Printing\" /recursive

"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\routine\" /recursive
del /S /Q "%2\Web\application\routine\"
xcopy /y /s "%1\application\routine" "%2\Web\application\routine"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\routine\" /recursive

del /S /Q /F "%2\Web\application\sharedscripts\"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" get /all "%2\Web\application\sharedscripts\" /recursive
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\sharedscripts\" /recursive
xcopy /y /s "%1\application\sharedscripts" "%2\Web\application\sharedscripts"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\sharedscripts\" /recursive

"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\application\WorklistHelper\" /recursive
del /S /Q "%2\Web\application\WorklistHelper\"
xcopy /y /s "%1\application\WorklistHelper" "%2\Web\application\WorklistHelper"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\application\WorklistHelper\" /recursive

ECHO Doing Bin folder
iisreset.exe
del /S /Q /F "%2\Web\bin"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" get /all "%2\Web\bin\" /recursive
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\bin\" /recursive
xcopy /y "%1\bin\*.dll*" "%2\Web\bin"
xcopy /y "%1\bin\Ascribe.Core*.dll*" "%2\Web\bin"
xcopy /y "%1\Overlord\bin\Ascribe.Core*.dll*" "%2\Web\bin\*.*"
xcopy /y "%1\Overlord\bin\Ascribe.Framework.Server.dll*" "%2\Web\bin\*.*"
xcopy /y "%1\Overlord\bin\Ascribe.Framework.Server.dll*" "%2\Web\bin\*.*"
del /S /Q "%2\Web\bin\Client Custom.dll"
del /S /Q "%2\Web\bin\WebCustom.dll"
del /S /Q "%2\Web\bin\*.dll.config"
del /S /Q "%2\Web\bin\*.dll.refresh"
del /S /Q "%2\Web\bin\bin\*.*"
rmdir /S /Q "%2\Web\bin\bin"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\bin\*.dll*"  /recursive

ECHO Doing Images
del /S /Q /F "%2\Web\images"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\images" /recursive
xcopy /y /s "%1\images" "%2\Web\images"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\images\*.*" /recursive

ECHO Doing Style
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\Style" /recursive
xcopy /y /s "%1\Style" "%2\Web\Style"
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" add "%2\Web\Style\*.*" /recursive

ECHO Doing xml_data
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\tf.exe" checkout "%2\Web\xml_data" /recursive
xcopy /y /s "%1\xml_data\DataSet2Recordset.xslt" "%2\Web\xml_data\DataSet2Recordset.xslt"

ECHO FINISHED
PAUSE
