/*
Author: Xavier Norman
Date: 11-May-2017

Description: Updates desktops to new version
*/

DELETE FROM wConfiguration where Category='D|Terminal' and [Key]='LocalFilePath'
INSERT INTO wConfiguration (SiteID, [Category], section, [Key], Value, DSS) 
       SELECT distinct SiteID, 'D|Terminal', 'default', 'LocalFilePath', '"C:\ProgramData\EMIS\"', 0  FROM wConfiguration WHERE siteid > 0
GO

INSERT VersionLog (Type, Description, Date) SELECT 'Config', 'UpdateLocalFilPath.sql v1', GETDATE()
GO