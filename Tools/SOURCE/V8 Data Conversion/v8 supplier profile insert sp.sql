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
		,	@nsvcode					varchar(7)
		,	@supcode					varchar(5)
		,	@primarysupplier		bit
		,	@cost						varchar(9)
		,	@contno					varchar(10)
		,	@reorderpcksize		varchar(5)
		,	@reorderlvl				varchar(8)
		,	@reorderqty				varchar(6)
		,	@sislistprice			varchar(9)
		,	@contprice				varchar(9)
		,	@leadtime				varchar(3)
		,	@lastreconcileprice	varchar(9)
		,	@tradename				varchar(30)
		,	@supprefno				varchar(20)
		,	@altbarcode				varchar(13)
		,	@vatrate					varchar(1)
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

