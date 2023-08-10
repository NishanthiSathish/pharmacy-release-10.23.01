-- FUTURE GENERATIONS PLEASE NOTE.
-- You are advised not to change the field names or their data type. If you need to add a new field to the 
-- table, do a search on the keyword TABLE_STRUCTURE to navigate to the field list to do your changes. That's
-- all you will neet to do.

DECLARE @NumOfRecs1	INT	
DECLARE @NumOfRecs2	INT	

SET @NumOfRecs1 = 0
SET @NumOfRecs2 = 0

-- If the table exists
IF OBJECT_ID('rSpreadsheetLinks') IS NOT NULL
	BEGIN	
		-- If records are found, dump them into temp_rSpreadsheetLinks
		SET @NumOfRecs1 = ISNULL((SELECT COUNT(ProcedureName) FROM rSpreadsheetLinks), 0)
		IF @NumOfRecs1 > 0
			BEGIN
				IF OBJECT_ID('temp_rSpreadsheetLinks') IS NOT NULL
					BEGIN
						DROP TABLE temp_rSpreadsheetLinks
					END
				SELECT 	
					-- Fields for temporary table (exclude identity field)
					ProcedureName, 
					SpreadsheetName, 
					XLSFileName, 
					FileLocation
				INTO temp_rSpreadsheetLinks
				FROM rSpreadsheetLinks
	
				-- Get the number of records dumped
				SET @NumOfRecs2 = (SELECT COUNT(ProcedureName) FROM temp_rSpreadsheetLinks)
			END
	END

-- Regardless whether table exists	
IF @NumOfRecs2 = @NumOfRecs1 
	BEGIN
		BEGIN TRANSACTION
			IF OBJECT_ID('rSpreadsheetLinks') IS NOT NULL
				BEGIN
					DROP TABLE rSpreadsheetLinks
				END
			CREATE TABLE rSpreadsheetLinks (
				-- TABLE_STRUCTURE for new table
				ProcedureName VARCHAR (100) PRIMARY KEY NOT NULL ,
				SpreadsheetName VARCHAR (15) NULL ,
				XLSFileName VARCHAR (50) NULL ,
				FileLocation VARCHAR (500) NULL
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
							-- Copy the records from temp_rSpreadsheetLinks back in
							BEGIN TRANSACTION
								INSERT INTO rSpreadsheetLinks (
									-- Field List for new table
									ProcedureName, 
									SpreadsheetName, 
									XLSFileName, 
									FileLocation
									)
								SELECT * FROM temp_rSpreadsheetLinks
		
								IF @@ERROR > 0
									BEGIN
										ROLLBACK TRANSACTION
									END
								ELSE
									BEGIN
										COMMIT TRANSACTION
										IF OBJECT_ID('temp_rSpreadsheetLinks') IS NOT NULL
											DROP TABLE temp_rSpreadsheetLinks
									END
						END					
				END
	END
