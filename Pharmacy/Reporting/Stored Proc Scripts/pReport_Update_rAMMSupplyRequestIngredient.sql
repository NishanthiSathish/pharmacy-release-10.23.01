-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('pReport_Update_rAMMSupplyRequestIngredient') IS NOT NULL
	DROP PROCEDURE pReport_Update_rAMMSupplyRequestIngredient
GO

CREATE PROCEDURE pReport_Update_rAMMSupplyRequestIngredient
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)

    PRINT 'pReport_Update_rAMMSupplyRequestIngredient'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rAMMSupplyRequestIngredient
    
    SET @sql = 'INSERT INTO rAMMSupplyRequestIngredient (
					AMMSupplyRequestIngredientID,
					RequestID,
					NSVCode,
					BatchNumber,
					ExpiryDate,
					[State],
					AssembledBy_Date,
					AssembledBy_EntityID,
					AssembledBy_Initials,
					CheckedBy_Date,
					CheckedBy_EntityID,
					CheckedBy_Initials,
					QtyInIssueUnits,
					FormulaIndex,
					[ErrorMessage],
					SelfCheckReason)
	
				SELECT	
					i.AmmSupplyRequestIngredientID,
					i.RequestID,
					i.NSVCode,
					i.BatchNumber,
					i.ExpiryDate,
					i.[State],
					i.AssembledBy_Date,
					i.AssembledBy_EntityID,
					CAST(per_Assemble.Initials as varchar(10)) AS AssembledBy_Initials,
					i.CheckedBy_Date,
					i.CheckedBy_EntityID,
					CAST(per_Checked.Initials as varchar(10)) AS CheckedBy_Initials,
					i.QtyInIssueUnits,
					i.FormulaIndex,
					i.[ErrorMessage],
					i.SelfCheckReason
				FROM
					' + @LiveDB + '.icwsys.AMMSupplyRequestIngredient i
					LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Assemble    ON i.AssembledBy_EntityID = per_Assemble.EntityID
					LEFT JOIN ' + @LiveDB + '.icwsys.Person    per_Checked     ON i.CheckedBy_EntityID = per_Checked.EntityID'

    EXECUTE (@sql)

    PRINT ''    
END
GO
