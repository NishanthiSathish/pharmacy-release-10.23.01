-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8SupplierProfileInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8SupplierProfileInsert
GO

CREATE PROCEDURE pV8SupplierProfileInsert 
	(
			@sessionid				integer
		,	@locationid_site		integer
		,	@nsvcode					char(7)
		,	@supcode					char(5)
		,	@primarysupplier		bit
		,	@cost						char(9)
		,	@contno					char(10)
		,	@reorderpcksize		char(5)
		,	@reorderlvl				char(8)
		,	@reorderqty				char(6)
		,	@sislistprice			char(9)
		,	@contprice				char(9)
		,	@leadtime				char(3)
		,	@lastreconcileprice	char(9)
		,	@tradename				char(30)
		,	@supprefno				char(20)
		,	@altbarcode				char(13)
		,	@vatrate					char(1)
		,	@wsupplierprofileid	integer		OUTPUT
)	
AS
	begin

		exec pWSupplierProfileInsert	@sessionid,
												@nsvcode,
												@supcode, 
												@primarysupplier,
												@contno,
												@reorderpcksize,
												@reorderqty, 
												@reorderlvl,
												@sislistprice,
												@contprice,
												@leadtime, 
												@lastreconcileprice,
												@tradename,
												@supprefno, 
												@vatrate,
												@locationid_site,
												@wsupplierprofileid		OUTPUT
				
	end 
GO

