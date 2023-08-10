@Echo off
Echo > log.txt
Echo Updating the Reporting Database.
FOR %%c IN (*.sql) DO call osql -E -S ASC-JOHNKU -d ASC_REPORT -U dbo -i %%c -n |echo Running script %%c >> log.txt 
