@echo off
echo *****************************************
echo *****************************************
echo ******  EMIS HEALTH PHARMACY LTD  *******
echo *****************************************
echo *****************************************
echo ** THIS BATCH FILE WILL REGISTER DLL'S ** 
echo ** AND OCX'S WITHIN THE SMART CLIENT   **
echo ** FOLDER.                             ** 
echo *****************************************
echo *****************************************
cd %cd%
regsvr32 /u PharmacyData.dll /s
set curVar=PharmacyData.dll
if errorlevel=1 goto syntax
regsvr32 /u DispensingCtl.ocx /s
set curVar=DispensingCtl.ocx
if errorlevel=1 goto syntax
regsvr32 /u Launcher.ocx /s
set curVar=Launcher.ocx
if errorlevel=1 goto syntax
regsvr32 /u ProductStockEditor.ocx /s
set curVar=ProductStockEditor.ocx
if errorlevel=1 goto syntax
echo on
goto end
:syntax
echo !!!!! There was an error trying to Unregister %curVar%. Please inform your Emis Health administrator !!!!!!
PAUSE