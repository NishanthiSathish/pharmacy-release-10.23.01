-- 12Nov14 XN 103883 Due to the updates to the supplier, and wards the conversion process has been changed
--		      First the data is read into the WExtraSupplierData_Old, and then pWSupplierConvert is called into add it to new WCustomer, WCustomerExtraData, WSupplier2, WSupplier2ExtraData, and WWardProductList tables


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WExtraSupplierDataInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WExtraSupplierDataInsert
GO

CREATE PROCEDURE pV8WExtraSupplierDataInsert 
	(
			@sessionid					integer
		,	@locationid_site			integer
		,	@supcode						char(5)
		,	@currentcontractdata		varchar(1024)
		,	@newcontractdata			varchar(1024)
		,	@dateofchange				varchar(10)
		,	@contactname1				varchar(50)
		,	@contactname2				varchar(50)
		,	@notes						varchar(1024)
		,	@wextrasupplierdataid	integer OUTPUT
	)
AS
	begin
		--exec pWExtraSupplierData_OldInsert	@sessionid,
		--											@locationid_site,
		--											@supcode,
		--											@currentcontractdata,
		--											@newcontractdata,
		--											@dateofchange,
		--											@contactname1,
		--											@contactname2,
		--											@notes,
		--											@wextrasupplierdataid	OUTPUT   103883 
		
	    Insert into [WExtraSupplierData_Old] ( [LocationID_Site], [SupCode], [CurrentContractData],  [NewContractData], [DateofChange],[ContactName1],[ContactName2], [Notes])
	    values ( @locationid_site, @supcode, @currentcontractdata, @newcontractdata,@dateofchange,@contactname1, @contactname2, @notes)

        Set @WExtraSupplierDataID = @@IDENTITY  
	end
GO
