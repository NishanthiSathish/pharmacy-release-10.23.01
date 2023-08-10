-- FUTURE GENERATIONS PLEASE NOTE.
-- You are advised not to change the field names or their data type. If you need to add a new field to the 
-- table, do a search on the keyword TABLE_STRUCTURE to navigate to the field list to do your changes. That's
-- all you will neet to do.

DECLARE @NumOfRecs1	INT	
DECLARE @NumOfRecs2	INT	

SET @NumOfRecs1 = 0
SET @NumOfRecs2 = 0

-- If the table exists
IF OBJECT_ID('rFinancialSnapshot') IS NOT NULL
	BEGIN	
		-- If records are found, dump them into temp_rFinancialSnapshot
		SET @NumOfRecs1 = ISNULL((SELECT COUNT(NSVCode) FROM rFinancialSnapshot), 0)
		IF @NumOfRecs1 > 0
			BEGIN
				IF OBJECT_ID('temp_rFinancialSnapshot') IS NOT NULL
					BEGIN
						DROP TABLE temp_rFinancialSnapshot
					END
				SELECT 	
					-- Fields for temporary table (exclude identity field)
					SnapDate, 
					NSVCode, 
					Site, 
					StockLevel, 
					ValueNet, 
					ValueGross, 
					LossesGainsValueNet, 
					LossesGainsValueGross
				INTO temp_rFinancialSnapshot
				FROM rFinancialSnapshot
	
				-- Get the number of records dumped
				SET @NumOfRecs2 = (SELECT COUNT(NSVCode) FROM temp_rFinancialSnapshot)
			END
	END

-- Regardless whether table exists	
IF @NumOfRecs2 = @NumOfRecs1 
	BEGIN
		BEGIN TRANSACTION
			IF OBJECT_ID('rFinancialSnapshot') IS NOT NULL
				BEGIN
					DROP TABLE rFinancialSnapshot
				END
			CREATE TABLE rFinancialSnapshot (
				-- TABLE_STRUCTURE for new table
				SnapDate datetime NULL ,
				NSVCode varchar (7) NULL ,
				Site int NULL ,
				StockLevel float NULL ,
				ValueNet money NULL ,
				ValueGross money NULL ,
				LossesGainsValueNet money NULL ,
				LossesGainsValueGross money NULL 
			)
			
			IF @@ERROR > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
			ELSE
				BEGIN
					COMMIT TRANSACTION
					IF @NumOfRecs1 > 0
						BEGIN
							-- Copy the records from temp_rFinancialSnapshot back in
							BEGIN TRANSACTION
								INSERT INTO rFinancialSnapshot (
									-- Field List for new table
									SnapDate, 
									NSVCode, 
									Site, 
									StockLevel, 
									ValueNet, 
									ValueGross, 
									LossesGainsValueNet, 
									LossesGainsValueGross
									)
								SELECT * FROM temp_rFinancialSnapshot
		
								IF @@ERROR > 0
									BEGIN
										ROLLBACK TRANSACTION
									END
								ELSE
									BEGIN
										COMMIT TRANSACTION
										IF OBJECT_ID('temp_rFinancialSnapshot') IS NOT NULL
											DROP TABLE temp_rFinancialSnapshot
									END
						END					
				END
	END


-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rFinancialSnapshot_NSVCode' and id = object_id(N'[rFinancialSnapshot]'))
DROP INDEX [rFinancialSnapshot].[IX_rFinancialSnapshot_NSVCode]
GO
CREATE INDEX [IX_rFinancialSnapshot_NSVCode] ON [rFinancialSnapshot]([NSVCode]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rFinancialSnapshot_NSVCodeSite' and id = object_id(N'[rFinancialSnapshot]'))
DROP INDEX [rFinancialSnapshot].[IX_rFinancialSnapshot_NSVCodeSite]
GO
CREATE INDEX [IX_rFinancialSnapshot_NSVCodeSite] ON [rFinancialSnapshot]([NSVCode],[Site]) ON [PRIMARY]
GO
