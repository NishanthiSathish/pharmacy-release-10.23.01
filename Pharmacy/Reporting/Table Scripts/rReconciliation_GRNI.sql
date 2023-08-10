-- FUTURE GENERATIONS PLEASE NOTE.
-- You are advised not to change the field names or their data type. If you need to add a new field to the 
-- table, do a search on the keyword TABLE_STRUCTURE to navigate to the field list to do your changes. That's
-- all you will neet to do.

-- =======================================================================================================
-- Author:			Paul Crawford (PJC)
-- Amended date:	03Sep09
-- Ref:				F0050136
-- Description:		Alters the LedgerCode field in the rReconciliation_GRNI in the reporting database 
--					from 7 to 20 characters.
-- =======================================================================================================

DECLARE @NumOfRecs1	INT	
DECLARE @NumOfRecs2	INT	

SET @NumOfRecs1 = 0
SET @NumOfRecs2 = 0

-- If the table exists
IF OBJECT_ID('rReconciliation_GRNI') IS NOT NULL
	BEGIN	
		-- If records are found, dump them into temp_rReconciliation_GRNI
		SET @NumOfRecs1 = ISNULL((SELECT COUNT(wReconcilID) FROM rReconciliation_GRNI), 0)
		IF @NumOfRecs1 > 0
			BEGIN
				IF OBJECT_ID('temp_rReconciliation_GRNI') IS NOT NULL
					BEGIN
						DROP TABLE temp_rReconciliation_GRNI
					END
				SELECT 	
					-- Fields for temporary table (exclude identity field)
					wReconcilID, 
					Site, 
					[Month], 
					Supplier, 
					SupplierName, 
					OrderNumber, 
					NSVCode, 
					StoresDescription, 
					OrderDate, 
					ReceivedDate, 
					OrderedPacks, 
					PackCost, 
					ReceivedPacks, 
					NetValue, 
					GrossValue, 
					LedCode, 
					FinanceSupplierCode, 
					TaxRate, 
					LocCode, 
					OrdDate, 
					RecDate, 
					InDispute, 
					InDisputeUser, 
					SiteID, 
					Status
				INTO temp_rReconciliation_GRNI
				FROM rReconciliation_GRNI
	
				-- Get the number of records dumped
				SET @NumOfRecs2 = (SELECT COUNT(wReconcilID) FROM temp_rReconciliation_GRNI)
			END
	END

-- Regardless whether table exists	
IF @NumOfRecs2 = @NumOfRecs1 
	BEGIN
		BEGIN TRANSACTION
			IF OBJECT_ID('rReconciliation_GRNI') IS NOT NULL
				BEGIN
					DROP TABLE rReconciliation_GRNI
				END
			CREATE TABLE rReconciliation_GRNI (
				-- TABLE_STRUCTURE for new table
				wReconcilID INT NOT NULL,
				Site INT NOT NULL ,
				[Month] VARCHAR (6) NOT NULL ,
				Supplier VARCHAR (5) NULL ,
				SupplierName VARCHAR (15) NULL ,
				OrderNumber INT NULL ,
				NSVCode VARCHAR (7) NULL ,
				StoresDescription VARCHAR (56) NULL ,
				OrderDate datetime NULL ,
				ReceivedDate datetime NULL ,
				OrderedPacks VARCHAR (13) NULL ,
				PackCost VARCHAR (13) NULL ,
				ReceivedPacks FLOAT NULL ,
				NetValue MONEY NULL ,
				GrossValue MONEY NULL ,
				LedCode VARCHAR (20) NULL ,
				FinanceSupplierCode VARCHAR (15) NULL ,
				TaxRate float NULL ,
				LocCode VARCHAR (3) NULL ,
				OrdDate VARCHAR (8) NULL ,
				RecDate VARCHAR (8) NULL ,
				InDispute VARCHAR (1) NULL ,
				InDisputeUser VARCHAR (3) NULL ,
				SiteID INT NOT NULL ,
				Status VARCHAR (1) NULL 
			
				CONSTRAINT rReconcilUniqueGroup UNIQUE (
					wReconcilID,
					Site,
					[Month])
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
							-- Copy the records from temp_rReconciliation_GRNI back in
							BEGIN TRANSACTION
								INSERT INTO rReconciliation_GRNI (
									-- Field List for new table
									wReconcilID, 
									Site, 
									[Month], 
									Supplier, 
									SupplierName, 
									OrderNumber, 
									NSVCode, 
									StoresDescription, 
									OrderDate, 
									ReceivedDate, 
									OrderedPacks, 
									PackCost, 
									ReceivedPacks, 
									NetValue, 
									GrossValue, 
									LedCode, 
									FinanceSupplierCode, 
									TaxRate, 
									LocCode, 
									OrdDate, 
									RecDate, 
									InDispute, 
									InDisputeUser, 
									SiteID, 
									Status
									)
								SELECT * FROM temp_rReconciliation_GRNI
		
								IF @@ERROR > 0
									BEGIN
										ROLLBACK TRANSACTION
									END
								ELSE
									BEGIN
										COMMIT TRANSACTION
										IF OBJECT_ID('temp_rReconciliation_GRNI') IS NOT NULL
											DROP TABLE temp_rReconciliation_GRNI
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

IF exists (SELECT * from sysindexes where name = N'IX_rReconciliation_GRNI_SupplierSite' and id = object_id(N'[rReconciliation_GRNI]'))
DROP INDEX [rReconciliation_GRNI].[IX_rReconciliation_GRNI_SupplierSite]
GO
CREATE INDEX [IX_rReconciliation_GRNI_SupplierSite] ON [rReconciliation_GRNI]([Supplier],[Site]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rReconciliation_GRNI_NSVCode' and id = object_id(N'[rReconciliation_GRNI]'))
DROP INDEX [rReconciliation_GRNI].[IX_rReconciliation_GRNI_NSVCode]
GO
CREATE INDEX [IX_rReconciliation_GRNI_NSVCode] ON [rReconciliation_GRNI]([NSVCode]) ON [PRIMARY]
GO
