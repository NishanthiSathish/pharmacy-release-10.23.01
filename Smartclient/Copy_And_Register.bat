@echo off
echo *****************************************
echo ** Will first unregister all dlls		**
echo ** ActiveX controls in %2 will then	**
echo ** copy all files from current to %2	**
echo ** and re-register						**
echo *****************************************
mkdir "%1"
chdir "%1"
"%1\EnhRegSvr.exe" /u
xcopy /Y /R "%2\*.*" "%1\*.*"
"%1\EnhRegSvr.exe"
