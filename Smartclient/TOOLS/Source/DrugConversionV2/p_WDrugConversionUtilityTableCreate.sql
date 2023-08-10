   
-- =======================================================================================================
-- Author:      PJC
-- Create date: 10Sep09
-- Ref:         --
-- Description: Drug conversion temp holding/Error table + insert SP creation, pass in the table name and session.
-- =======================================================================================================
--28Sep12 TH Added new fields and extended @SQL to accomodate them
--12Mar13 TH Added sp (pSelectSiteProductDataNSV) to script (TFS 58205)
--13Mar13 TH renamed sps to stop builder versioning the sp call in compiled code (TFS 58757)

exec pDROP [pWDrugConversionUtilityTableCreate]
GO

exec pDROP [pWDrugV8ConversionUtilityTableCreate]
GO

create procedure [pWDrugV8ConversionUtilityTableCreate]
	(
			@CurrentSessionID 		int
		,	@Tablename				varchar(100)
		,	@HoldingOrErrorTable	char(1) = 'H'
	)
	as

begin

declare @SQL		varchar(8000)
declare @Tab 		char(1)
declare @CRLF 		char(2)
declare @Name 		varchar(128)
declare @Variable 	varchar(128)
declare @Datatype 	varchar(128)
declare @Fields 	varchar(4000)
declare @Variables 	varchar(4000)
declare @Values 	varchar(4000)
declare @SPName		varchar(128)

	set @Tab = char(9)
	set @CRLF = char(13) + char(10)

	if @HoldingOrErrorTable = 'H'
		begin

			set @SQL = 'pdrop [' + @Tablename + ']'
			execute (@SQL)

			set @SPName = 'p' + @Tablename + 'Insert'
			set @SQL = 'pdrop ' + @SPName
			execute (@SQL)

			set @SQL = 'create table [' + @Tablename + ']'
			+ '(  
				Code 		Varchar(8) not null 
			,   [Description] 	Varchar(56) not null
			,   inuse 		Varchar(1) null
			,   deluserid 		Varchar(3) null
			,   tradename 		Varchar(30) null
			,   cost 		Varchar(9) null
			,   contno 		Varchar(10) null
			,   supcode 		Varchar(5) null
			,   altsupcode 		Varchar(29) null
			,   warcode2 		Varchar(6) null
			,   ledcode 		Varchar(7) null
			,   SisCode 		Varchar(7) NOT null PRIMARY KEY
			,   barcode 		Varchar(13) null
			,   cyto 		Varchar(1) null
			,   civas 		Varchar(1) null
			,   formulary 		Varchar(1) null
			,   bnf 		Varchar(13) null
			,   ReconVol 		float null --single 
			,   ReconAbbr 		Varchar(3) null
			,   Diluent1Abbr 	Varchar(3) null
			,   Diluent2Abbr 	Varchar(3) null
			,   MaxmgPerml 		float null --single 
			,   warcode 		Varchar(6) null
			,   inscode 		Varchar(6) null
			,   dircode 		Varchar(6) null
			,   labelformat 	Varchar(1) null
			,   expiryminutes 	int null
			,   sisstock 		Varchar(1) null
			,   ATC 		Varchar(1) null
			,   reorderpcksize 	Varchar(5) null
			,   PrintformV 		Varchar(5) null
			,   minissue 		Varchar(4) null
			,   maxissue 		Varchar(5) null
			,   reorderlvl 		Varchar(8) null
			,   reorderqty 		Varchar(6) null
			,   convfact 		Varchar(5) null
			,   anuse 		Varchar(9) null
			,   message 		Varchar(30) null
			,   therapcode 		Varchar(2) null
			,   extralabel 		Varchar(3) null
			,   stocklvl 		Varchar(9) null
			,   sislistprice 	Varchar(9) null
			,   contprice 		Varchar(9) null
			,   livestockctrl 	Varchar(1) null
			,   leadtime 		Varchar(3) null
			,   loccode 		Varchar(3) null
			,   usagedamping 	float null --single 
			,   safetyfactor 	float null --single 
			,   indexed 		Varchar(1) null
			,   recalcatperiodend 	Varchar(1) null
			,   blank 		Varchar(6) null          
			,   lossesgains 	float null --single 
			,   spare 		Varchar(7) null           
			,   dosesperissueunit 	float null --single   
			,   mlsperpack 		int null         
			,   ordercycle 		Varchar(2) null
			,   cyclelength 	int null
			,   lastreconcileprice 	Varchar(9) null
			,   outstanding 	float null --single
			,   usethisperiod 	float null --single
			,   vatrate 		Varchar(1) null
			,   DosingUnits 	Varchar(5) null
			,   ATCCode 		Varchar(8) null
			,   UserMsg 		Varchar(2) null
			,   MaxInfusionRate 	float null --single
			,   MinmgPerml 		float null --single
			,   InfusionTime 	float null --single
			,   mgPerml 		float null --single
			,   IVcontainer 	Varchar(1) null
			,   DisplacementVolume  float null --single 
			,   PILnumber		Int null          
			,   datelastperiodend 	Varchar(8) null 
			,   MinDailyDose 	float null --single
			,   MaxDailyDose  	float null --single
			,   MinDoseFrequency 	float null --single
			,   MaxDoseFrequency 	float null --single
			,   route 		Varchar(20) null          
			,   chemical 		Varchar(50) null
			,   [local] 		Varchar(7) null           
			,   extralocal 		Varchar(3) null      
			,   DosesPerAdminUnit 	float null --double   
			,   adminunit 		Varchar(5) null       
			,   DPSform 		Varchar(25) null        
			,   storesdescription 	Varchar(56) null
			,   storespack 		Varchar(5) null
			,   teamworkbtn 	int null
			,   StrengthDesc 	Varchar(12) null     
			,   loccode2 		Varchar(3) null          
			,   lastissued 		Varchar(8) null
			,   lastordered 	Varchar(8) null
			,   CreatedUser 	Varchar(3) null
			,   createdterminal 	Varchar(15) null
			,   createddate 	Varchar(8) null
			,   createdtime 	Varchar(6) null
			,   modifieduser 	Varchar(3) null
			,   modifiedterminal 	Varchar(15) null
			,   modifieddate 	Varchar(8) null
			,   modifiedtime 	Varchar(6) null
			,   batchtracking 	Varchar(1) null
			,   stocktakestatus 	Varchar(1) null
			,   laststocktakedate 	Varchar(8) null
			,   laststocktaketime 	Varchar(6) null
			,   pflag 		Varchar(1) null
			,   issueWholePack 	Varchar(1) null
			,   HasFormula 		Varchar(1) null
			,   PIL2 		Varchar(10) null
			,   StripSize 		Varchar(5) null
			,   pipcode 		Varchar(7) null
			,   sparePIP 		Varchar(5) null
			,   MasterPip 		Varchar(7) null
			,   spareMasterPip 	Varchar(5) null
			,   PhysicalDescription 	Varchar(35) null
			,   DDDValue 	Varchar(10) null
			,   DDDUnits 	Varchar(10) null
			,   UserField1 	Varchar(10) null
			,   UserField2 	Varchar(10) null
			,   UserField3 	Varchar(10) null
			,   HIProduct 	Varchar(1) null
			,   LocationID_Site 	int not null
			,   [ID]		int IDENTITY(1,1)
			)'

			execute (@SQL )

			--build the insert SP

			declare cur cursor local FORWARD_ONLY STATIC for
				select b.[name] [name], '@' + b.[name] variable, case 
					when charindex('char',  c.[name]) <> 0 then c.[name] + '(' +  cast(b.length as varchar(50)) + ')'
					else c.name end Datatype 
				from sysobjects a 
				join syscolumns b on a.id = b.id 
				join systypes c on c.xtype = b.xtype 
				where a.name =  @Tablename
				order by b.colid

			set @Fields = ''
			set @Variables = ''
			set @Values = ''

			open cur
			Fetch Next From cur into @Name, @Variable, @Datatype		
			while @@Fetch_Status = 0
				begin
					set @Variables = @Variables + @Tab + ',' + @Tab + @Variable + ' ' + @Datatype + @CRLF
					set @Fields = @Fields + '[' + @Name + '],'
					set @Values = @Values +  @Variable + ','
					Fetch Next From cur into @Name, @Variable, @Datatype		
				end
			
			--close the cursor
			Close cur
			Deallocate cur
			
			set @Fields = replace(@Fields, '[ID],', '') 
			set @Fields = left(@Fields, len(@Fields) - 1)
			set @Values = replace(@Values, '@ID,', '') 
			set @Values = left(@Values, len(@Values) - 1)
			set @Variables = replace(@Variables, '@ID int', '@ID int OUTPUT')

			set @SQL = 'create procedure [' + @SPName + ']' + @CRLF
			+ @Tab +'(' + @CRLF
			+ @Tab + @Tab + '@CurrentSessionID int' + @CRLF
			+  @variables + @CRLF
			+  @Tab + ')' + @CRLF
			+  @Tab + 'as' + @CRLF
			+ 'begin' + @CRLF 
			+ @tab + 'Begin transaction' + @CRLF + @CRLF 
			+ @tab + 'insert into [' + @Tablename + '] ( ' + @Fields + ')' + @CRLF
			+ @tab + 'Values ( ' + @Values + ')' + @CRLF 
			+ @tab + 'If @@ERROR = 0 Commit else Rollback' + @CRLF 
			+ @tab + 'Set @ID = scope_identity()'  + @CRLF
			+ 'end' + @CRLF
			--print @SQL
			execute (@SQL)

			-- build the select SPs

			set @SPName = replace(@SPName, 'insert','select') 
			
			set @SQL = 'pdrop [' + @SPName + ']'
			execute (@SQL)

			set @SQL = 'create procedure [' + @SPName + ']' + @CRLF
			+ @Tab +'(' + @CRLF
			+ @Tab + @Tab + '@CurrentSessionID int' + @CRLF
			+  @Tab + ')' + @CRLF
			+  @Tab + 'as' + @CRLF
			+ 'begin' + @CRLF 
			+ @tab + 'select ' + @CRLF
			+ @tab + @Fields + @CRLF 
			+ @tab + ' from [' + @Tablename + ']' + @CRLF
			+ 'end' + @CRLF
			--print @SQL
			execute (@SQL)


		end
	else if @HoldingOrErrorTable = 'E'
		begin

		--now do the same for the Error table
		set @SPName = 'p' + @Tablename + 'ErrorInsert'
		set @SQL = 'pdrop [' + @Tablename + 'Error]'
		execute (@SQL)

		set @SQL = 'pdrop ' + @SPName
		execute (@SQL)

		set @SQL = 'create table [' + @Tablename + 'Error]'
		+ '(  
			ID			int IDENTITY(1,1) PRIMARY KEY
		,   [DateTime]		DateTime not null Default (GetDate())
		,   SisCode 		Varchar(7)  null
		,   LocationID_Site 	int not null
		,   ErrorText 		Varchar(500) not null
		)'
		execute (@SQL)


		set @SQL = 'create procedure [' + @SPName + ']' + @CRLF
		+ @Tab +'(' + @CRLF
		+ @Tab + @Tab + '@CurrentSessionID int' + @CRLF
		+ @Tab + ',' + @Tab + '@sisCode Varchar(7)' + @CRLF
		+ @Tab + ',' + @Tab + '@LocationID_Site int' + @CRLF
		+ @Tab + ',' + @Tab + '@ErrorText Varchar(500)' + @CRLF
		+ @Tab + ',' + @Tab + '@ID int OUTPUT' + @CRLF
		+  @Tab + ')' + @CRLF
		+  @Tab + 'as' + @CRLF
		+ 'begin' + @CRLF 
		+ @tab + 'Begin transaction' + @CRLF + @CRLF 
		+ @tab + 'insert into [' + @Tablename + 'Error] ( [sisCode], [LocationID_Site], [ErrorText])' + @CRLF
		+ @tab + 'Values ( @sisCode, @LocationID_Site, @ErrorText)' + @CRLF 
		+ @tab + 'If @@ERROR = 0 Commit else Rollback' + @CRLF 
		+ @tab + 'Set @ID = scope_identity()'  + @CRLF
		+ 'end' + @CRLF
		--print @SQL
		execute (@SQL)
	end
end

GO
--exec pWDrugConversionUtilityTableCreate 0, 'sdkghkshg'

-- =======================================================================================================
-- Author:      PJC
-- Create date: 11Sep09
-- Ref:         --
-- Description: Deletes the ProductStock and WSupplierProfile based on the Location supplied.
-- =======================================================================================================

exec pDROP [pWDrugConversionUtilityPSAndWSPDeleteByLocation]
GO

exec pDROP [pWDrugV8ConversionUtilityPSAndWSPDeleteByLocation]
GO

create procedure [pWDrugV8ConversionUtilityPSAndWSPDeleteByLocation]
	(
			@CurrentSessionID 		int
		,	@LocationID_Site		int

	)
	as

begin
	
	delete from WProductFinancialsnapshot where ProductStockID in (select ProductStockID from ProductStock where LocationID_Site = @LocationID_Site)
	delete from ProductStock where LocationID_Site = @LocationID_Site
	delete from WSupplierProfile where LocationID_Site = @LocationID_Site

end
GO

exec pDROP [pWDrugConversionUtilityAlternativeBarcodeAdd]
GO

exec pDROP [pWDrugV8ConversionUtilityAlternativeBarcodeAdd]
GO

create procedure [pWDrugV8ConversionUtilityAlternativeBarcodeAdd]
	(
			@CurrentSessionID int
		,	@SiteProductDataID int
		,	@Alias varchar(255)
	)
	as

begin

	Declare @AliasGroupID int
	Declare @ReturnID int
	Select @AliasGroupID = AliasGroupID from [AliasGroup] where [AliasGroup].[Description] = 'AlternativeBarcode'

	select @ReturnID = SiteProductDataAliasID from SiteProductDataAlias 
	where 
		SiteProductDataID = @SiteProductDataID and 
		Alias = @Alias and 
		AliasGroupID = @AliasGroupID

	if @ReturnID is null
	begin 
		Insert into [SiteProductDataAlias]( [SiteProductDataID], [AliasGroupID], [Alias], [Default] ) 
		values ( @SiteProductDataID, @AliasGroupID, @Alias, 1 )

		set @ReturnID = scope_identity()
	end	
	return @ReturnID

end
GO

--12Mar13 TH Added sp to script (TFS 58205)

exec pDrop 'pSelectSiteProductDataNSV'
GO

create   procedure [pSelectSiteProductDataNSV]
	(
			@CurrentSessionID int
	)
	as

begin

	Select 
		wproduct.siscode
	from 
		wproduct
	
	
end

GO

