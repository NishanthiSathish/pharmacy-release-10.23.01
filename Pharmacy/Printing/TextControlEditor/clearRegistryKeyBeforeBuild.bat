@echo off
reg query "HKEY_CLASSES_ROOT\WOW6432Node\TypeLib\{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5}" >nul 2> 1
if %errorlevel% equ 0 (
  echo "{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5} exists- do delete before build"
  reg delete "HKEY_CLASSES_ROOT\WOW6432Node\TypeLib\{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5}" /f
) else (
reg query "HKEY_CLASSES_ROOT\TypeLib\{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5}" >nul 2> 1
if %errorlevel% equ 0 (
  echo "{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5} exists- do delete before build"
  reg delete "HKEY_CLASSES_ROOT\WOW6432Node\TypeLib\{6AAFB283-E58A-4E7A-BC6A-FF5507A7A1A5}" /f
)
)