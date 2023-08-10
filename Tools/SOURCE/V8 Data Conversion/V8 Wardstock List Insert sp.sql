--12Nov14 XN 103883 Due to the updates to the supplier, and wards the conversion process has been changed
--		     First the data is read into the WWardStockList_Old, and then pWWardStockListConvert is called into add it to WWardProductListLine table

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WWardStocklistInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WWardStocklistInsert
GO

CREATE PROCEDURE pV8WWardStocklistInsert 
	(
			@sessionid				integer
		,	@locationid_site		integer
		,	@barcode					varchar(15)
		,	@dailyissue				integer
		,	@screenposn				integer
		,	@nsvcode					varchar(7)
		,	@titletext				varchar(56)
		,	@printlabel				varchar(1)
		,	@sitename				varchar(5)
		,	@topuplvl				integer
		,	@lastissue				integer
		,	@packsize				integer
		,	@lastissuedate			varchar(10)
		,	@localcode				varchar(7)
		,	@wwardstocklistid	integer OUTPUT
	)
AS
	begin

		declare 	@_wsupplierid		integer

		select @_wsupplierid = wsupplierid
		-- from wsupplier
		from wsupplier_Old
		where code = @sitename
		and SiteID = @locationid_site

		--exec pWWardStockListInsert	@sessionid,
		--									@locationid_site,
		--									@screenposn,
		--									@nsvcode,
		--									@titletext,
		--									@printlabel,
		--									@sitename,
		--									@topuplvl,
		--									@lastissue,
		--									@packsize,
		--									@lastissuedate,
		--									@localcode,
		--									@barcode,
		--									@dailyissue,
		--									@_wsupplierid,
		--									@wwardstocklistid	OUTPUT  103883 											

		If NOT EXISTS(SELECT TOP 1 1 FROM WWardStockList_Old WHERE [WSupplierID]=@_wsupplierid AND [SiteID]=@LocationID_Site AND [ScreenPosn]=@ScreenPosn AND [TitleText]=@TitleText)
		Begin
			Insert into [WWardStockList_Old] ( [ScreenPosn], 
										   [NSVcode], 
										   [TitleText], 
										   [PrintLabel], 
										   [SiteName], 
										   [TopupLvl], 
										   [LastIssue], 
										   [PackSize], 
										   [LastIssueDate], 
										   [LocalCode], 
										   [SiteID],
										   [BarCode],
										   [DailyIssue],
										   [WSupplierID])   
			values ( @ScreenPosn, 
					 @NSVcode, 
					 @TitleText, 
					 @PrintLabel, 
					 @SiteName, 
					 @TopupLvl, 
					 @LastIssue, 
					 @PackSize, 
					 @LastIssueDate, 
					 @LocalCode, 
					 @LocationID_Site, 
					 @BarCode, 
					 @DailyIssue,
					 @_wsupplierid)  											
 
		Set @WWardStockListID = scope_identity()  
	end
	end
GO
