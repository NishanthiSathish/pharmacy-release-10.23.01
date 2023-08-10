@Echo off
Echo Updating the Emis Health Reporting Database.
Echo > log.txt
osql -E -S ASC-JOHNKU -d ASC_REPORT -U dbo -i StoredProcedures.txt -n -o log.txt
rem Call Notepad.exe log.txt
