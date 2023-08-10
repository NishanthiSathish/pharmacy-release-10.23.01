-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('pReport_Update_rPNRegimenProductVolume') IS NOT NULL
	DROP PROCEDURE pReport_Update_rPNRegimenProductVolume
GO


CREATE PROCEDURE pReport_Update_rPNRegimenProductVolume
AS
Begin
    DECLARE @LiveDB	VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'Running pReport_Update_rPNRegimenProductVolume'

    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

    TRUNCATE TABLE rPNRegimenProductVolume
    
    -- Copy over the rPNRegimenProductVolume
    SET @sql = 'INSERT INTO rPNRegimenProductVolume(
	                [PNRegimenProductVolumeID],
	                [RequestID],
	                [PNProductID],
	                [Volume_mL],
	                [TotalVolumeIncOverage])
                SELECT
	                prodVol.[PNRegimenProductVolumeID],
	                prodVol.[RequestID],
	                prodVol.[PNProductID],
	                prodVol.[Volume_mL],
	                prodVol.[TotalVolumeIncOverage]
    	        FROM ' + @LiveDB + '.icwsys.PNRegimenProductVolume prodVol'
    EXECUTE (@sql)


    PRINT ''
END
GO
