-- FUTURE GENERATIONS PLEASE NOTE.
-- You are advised not to change the field names or their data type. If you need to add a new field to the 
-- table, do a search on the keyword TABLE_STRUCTURE to navigate to the field list to do your changes. That's
-- all you will neet to do.

DECLARE @NumOfRecs1	INT	
DECLARE @NumOfRecs2	INT	

SET @NumOfRecs1 = 0
SET @NumOfRecs2 = 0

-- If the table exists
IF OBJECT_ID('rOrders') IS NOT NULL
	BEGIN	
		-- If records are found, dump them into temp_rOrders
		SET @NumOfRecs1 = ISNULL((SELECT COUNT(wOrderID) FROM rOrders), 0)
		IF @NumOfRecs1 > 0
			BEGIN
				IF OBJECT_ID('temp_rOrders') IS NOT NULL
					BEGIN
						DROP TABLE temp_rOrders
					END
				SELECT 	
					-- Fields for temporary table (exclude identity field)
					wOrderID, 
					[Month], 
					Site, 
					NSVCode, 
					Outstanding, 
					OutstandingValueNet, 
					OutstandingValueGross, 
					OrderDate, 
					LocCode, 
					Supplier, 
					Status, 
					NumPrefix, 
					OrderNumber, 
					PackCostNet, 
					PackCostGross, 
					PickNo, 
					ReceivedPacks, 
					ReceivedDate, 
					OrderedPacks, 
					Urgency, 
					ToFollow, 
					INTernalSiteNo, 
					INTernalMethod, 
					SupplierType, 
					PFlag, 
					CreatedUser, 
					CustOrdNo, 
					InDispute, 
					InDisputeUser, 
					ShelfPrINTed, 
					StoresDescription, 
					ContractPrice, 
					ReOrderPacksize, 
					ContractNumber, 
					TaxCode, 
					TaxRate
				INTO temp_rOrders
				FROM rOrders
	
				-- Get the number of records dumped
				SET @NumOfRecs2 = (SELECT COUNT(wOrderID) FROM temp_rOrders)
			END
	END

-- Regardless whether table exists	
IF @NumOfRecs2 = @NumOfRecs1 
	BEGIN
		BEGIN TRANSACTION
			IF OBJECT_ID('rOrders') IS NOT NULL
				BEGIN
					DROP TABLE rOrders
				END
			CREATE TABLE rOrders (
				-- TABLE_STRUCTURE for new table
				wOrderID INT NOT NULL ,
				[Month] VARCHAR (6) NOT NULL ,
				Site INT NOT NULL ,
				NSVCode VARCHAR (7) NULL ,
				Outstanding FLOAT NULL ,
				OutstandingValueNet MONEY NULL ,
				OutstandingValueGross MONEY NULL ,
				OrderDate DATETIME NULL ,
				LocCode VARCHAR (3) NULL ,
				Supplier VARCHAR (5) NULL ,
				Status VARCHAR (1) NULL ,
				NumPrefix VARCHAR (6) NULL ,
				OrderNumber INT NULL ,
				PackCostNet FLOAT NULL ,
				PackCostGross FLOAT NULL ,
				PickNo INT NULL ,
				ReceivedPacks VARCHAR (13) NULL ,
				ReceivedDate VARCHAR (8) NULL ,
				OrderedPacks VARCHAR (13) NULL ,
				Urgency VARCHAR (1) NULL ,
				ToFollow VARCHAR (1) NULL ,
				INTernalSiteNo VARCHAR (3) NULL ,
				INTernalMethod VARCHAR (1) NULL ,
				SupplierType VARCHAR (1) NULL ,
				PFlag VARCHAR (1) NULL ,
				CreatedUser VARCHAR (3) NULL ,
				CustOrdNo VARCHAR (12) NULL ,
				InDispute VARCHAR (1) NULL ,
				InDisputeUser VARCHAR (3) NULL ,
				ShelfPrINTed VARCHAR (1) NULL ,
				StoresDescription VARCHAR (56) NULL ,
				ContractPrice VARCHAR (9) NULL ,
				ReOrderPacksize INT NULL ,
				ContractNumber VARCHAR (10) NULL ,
				TaxCode VARCHAR (1) NULL ,
				TaxRate FLOAT NULL 
				CONSTRAINT rOrders_Unique_wOrderID_Month UNIQUE  NONCLUSTERED 
				(
					wOrderID,
					[Month]
				)
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
							-- Copy the records from temp_rOrders back in
							BEGIN TRANSACTION
								INSERT INTO rOrders (
									-- Field List for new table
									wOrderID, 
									[Month], 
									Site, 
									NSVCode, 
									Outstanding, 
									OutstandingValueNet, 
									OutstandingValueGross, 
									OrderDate, 
									LocCode, 
									Supplier, 
									Status, 
									NumPrefix, 
									OrderNumber, 
									PackCostNet, 
									PackCostGross, 
									PickNo, 
									ReceivedPacks, 
									ReceivedDate, 
									OrderedPacks, 
									Urgency, 
									ToFollow, 
									INTernalSiteNo, 
									INTernalMethod, 
									SupplierType, 
									PFlag, 
									CreatedUser, 
									CustOrdNo, 
									InDispute, 
									InDisputeUser, 
									ShelfPrINTed, 
									StoresDescription, 
									ContractPrice, 
									ReOrderPacksize, 
									ContractNumber, 
									TaxCode, 
									TaxRate
									)
								SELECT * FROM temp_rOrders
		
								IF @@ERROR > 0
									BEGIN
										ROLLBACK TRANSACTION
									END
								ELSE
									BEGIN
										COMMIT TRANSACTION
										IF OBJECT_ID('temp_rOrders') IS NOT NULL
											DROP TABLE temp_rOrders
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

IF exists (SELECT * from sysindexes where name = N'IX_rOrders_SupplierSite' and id = object_id(N'[rOrders]'))
DROP INDEX [rOrders].[IX_rOrders_SupplierSite]
GO
CREATE INDEX [IX_rOrders_SupplierSite] ON [rOrders]([Supplier],[Site]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rOrders_NSVCode' and id = object_id(N'[rOrders]'))
DROP INDEX [rOrders].[IX_rOrders_NSVCode]
GO
CREATE INDEX [IX_rOrders_NSVCode] ON [rOrders]([NSVCode]) ON [PRIMARY]
GO

IF exists (SELECT * from sysindexes where name = N'IX_rOrders_NSVCodeSite' and id = object_id(N'[rOrders]'))
DROP INDEX [rOrders].[IX_rOrders_NSVCodeSite]
GO
CREATE INDEX [IX_rOrders_NSVCodeSite] ON [rOrders]([NSVCode],[Site]) ON [PRIMARY]
GO
