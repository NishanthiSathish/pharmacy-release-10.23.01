-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8BatchStockLevelInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8BatchStockLevelInsert
GO

CREATE PROCEDURE pV8BatchStockLevelInsert 
	(
			@sessionid					integer
		,	@locationid_site			integer
		,	@id							integer
		,	@nsvcode						varchar(15)
		,	@description				varchar(56)
		,	@batchnumber				varchar(15)
		,	@expiry						datetime
		,	@qty							float
		,	@wbatchstocklevelsid		integer		OUTPUT
	)
AS
	begin

		exec pWBatchStockLevelInsert	@sessionid,
												@locationid_site,
												@description,
												@nsvcode,
												@batchnumber,
												@expiry,
												@qty,
												@wbatchstocklevelsid 		OUTPUT
	end 

GO