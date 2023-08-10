-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8StockLabelInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8StockLabelInsert
GO

CREATE PROCEDURE pV8StockLabelInsert 
	(
			@sessionid			integer
		,	@locationid_site	integer
		,	@id					integer
		,	@drugcode			varchar(7)
		,	@wardcode			varchar(5)
		,	@rtffilename		varchar(13)
		,	@wstocklabelsid	integer		OUTPUT
	)
AS
	begin

			exec pWStockLabelsInsert @sessionid,
									 @locationid_site,
							 		 @drugcode,
									 @wardcode,
									 @rtffilename,
									 @wstocklabelsid 		OUTPUT
	end 

GO