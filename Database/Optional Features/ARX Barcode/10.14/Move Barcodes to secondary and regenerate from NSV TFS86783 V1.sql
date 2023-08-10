/****************************************************
28Mar14 CKJ Written (TFS86783)
	Add functions fNSVToBarcode and fBarcodeToNSV.
	Move pack barcodes to secondary barcode table 
	& generate replacement barcodes from NSVcodes 
	See caveats below before running.
	Login as icwsys before running.

10.14 Compatible Version
01  12Jan16 JP		TFS 140209 - First Version
02  25Jan16 XN		Prevent main part of script running
					if there is no drugs in db 
					(so can run with conversion tool)
*****************************************************/

exec pdrop 'fNSVToBarcode'

GO

create function icwsys.fNSVToBarcode
	( 
		@NSVcode varchar(7)
	) 
	returns varchar(13)
AS
begin
-- @NSVcode must be blank or 7 characters of form AAA999A
-- returns barcode derived from NSVcode or blank if conversion not feasible

	declare @bcr varchar(13)
	declare @nsv varchar(7)
	declare @chk int
	
	declare @s1 as int
	declare @s2 as int
	declare @s3 as int
	declare @s4 as varchar(3)
	declare @s5 as int

	set @bcr = ''

	if LEN(rtrim(@NSVcode)) = 7
		begin			
			set @nsv = UPPER(rtrim(@NSVcode))		-- abc123d	=> ABC123D
			
			set @s1 = ascii(substring(@nsv,1,1))	-- A......	65
			set @s2 = ascii(substring(@nsv,2,1))	-- .B.....	66
			set @s3 = ascii(substring(@nsv,3,1))	-- ..C....	67
			set @s4 = substring(@nsv,4,3)			-- ...123.	'123'
			set @s5 = ascii(substring(@nsv,7,1))	-- ......D	68

			if  (@s1 between 65 and 90) and 
				(@s2 between 65 and 90) and 
				(@s3 between 65 and 90) and 
				(@s4 NOT LIKE '%[^0-9]%') and
				(@s5 between 65 and 90) 
				begin
					set @bcr =  STR(@s1,2) +		-- A		=> 65
								STR(@s2,2) +		-- .B		=> 6566
								STR(@s3,2) +		-- ..C		=> 656667			
								@s4 +				-- ...123	=> 656667123
								STR(@s5,2) +		-- ......D	=> 65666712368
								'0'					--			=> 656667123680					
				end
		end
		
	if LEN(@bcr) = 12
		begin						
			set @chk = 	cast(SUBSTRING(@bcr, 1,1)  as int) +	-- (sum of odd columns) + 3 x (sum of even columns)
						cast(SUBSTRING(@bcr, 3,1)  as int) + 
						cast(SUBSTRING(@bcr, 5,1)  as int) + 
						cast(SUBSTRING(@bcr, 7,1)  as int) + 
						cast(SUBSTRING(@bcr, 9,1)  as int) + 
						cast(SUBSTRING(@bcr, 11,1) as int) +
						3 * (									
							cast(SUBSTRING(@bcr, 2,1)  as int) + 
							cast(SUBSTRING(@bcr, 4,1)  as int) + 
							cast(SUBSTRING(@bcr, 6,1)  as int) + 
							cast(SUBSTRING(@bcr, 8,1)  as int) + 
							cast(SUBSTRING(@bcr, 10,1) as int) + 
							cast(SUBSTRING(@bcr, 12,1) as int) 
							)  

			set @chk = 10 - (@chk % 10)							-- 10 - (sum_from_above modulo 10)
			set @bcr = @bcr + cast(@chk % 10 as CHAR(1))		-- => 656667681236802
		end
	
	return @bcr
end

GO

exec pdrop 'fBarcodeToNSV'

GO

create function icwsys.fBarcodeToNSV
	( 
		@barcode as varchar(13)
	) 
	returns varchar(7)
AS
begin
-- @barcode must be blank or 13 digits of form aabbcc999ddex where
-- each group aa, bb, cc, dd are in the range 65 to 90 inclusive.
-- Element e must be 0. The checkdigit x must be numeric but isn't validated.
-- Returns NSVcode derived from barcode or blank if conversion not feasible.

	declare @s1 as int
	declare @s2 as int
	declare @s3 as int
	declare @s4 as varchar(3)
	declare @s5 as int
	declare @s6 as int

	declare @NSV varchar(7)
	set @nsv = ''
	 
	if LEN(rtrim(@barcode)) = 13 and @barcode NOT LIKE '%[^0-9]%'
		begin
			set @s1 = cast(substring(@barcode,1,2) as int)	-- 1,2
			set @s2 = cast(substring(@barcode,3,2) as int)	-- 3,4
			set @s3 = cast(substring(@barcode,5,2) as int)	-- 5,6
			set @s4 = substring(@barcode,7,3)				-- 7,8,9
			set @s5 = cast(substring(@barcode,10,2) as int)	-- 10,11
			set @s6 = cast(substring(@barcode,12,2) as int)	-- 12,13

			if  (@s1 between 65 and 90) and 
				(@s2 between 65 and 90) and 
				(@s3 between 65 and 90) and 
				-- @s4 already known to be between '000' and '999' 
				(@s5 between 65 and 90) and
				(@s6 between 0 and 9)				-- 00 to 09 only 
				begin
					set @NSV = char(@s1) + char(@s2) + char(@s3) + @s4 + char(@s5) 
				end
		end

	return @NSV	
end

GO

/****************************************************
28Mar14 CKJ Written (TFS86783)
	Move pack barcodes to secondary barcode table 
	& generate replacement barcodes from NSVcodes 
	for all items except the DSS master products.
	
	Note this data is common to all sites and will
	therefore affect all robot interfaces etc.
	The 'before' and 'after' figures are displayed
	on successful completion otherwise transaction
	rolls back & no changes are made. 
	
	This might result in duplication between the 
	primary and secondary barcodes, eg a manually
	entered secondary barcode against the wrong drug
	for which a primary barcode is generated. The
	final report lists any items for which manual 
	tidying of the secondary barcode table is needed.
	If no rows are shown under 'Duplicated barcode'
	then no tidying is required.
*****************************************************/

Declare @AliasGroupID int

	set @AliasGroupID = (select [AliasGroupID] from icwsys.aliasgroup where [Description] = 'AlternativeBarcode')
	if  @AliasGroupID is null
		begin
			print 'AliasGroup is missing for AlternativeBarcode. Please correct this & try again.'
		end
	else if EXISTS(select TOP 1 1 from icwsys.SiteProductData) 
		begin
			begin tran
			select	(select count(*) from icwsys.SiteProductData
						where DSSMasterSiteID > 0) 
						as 'All Products (Before)'
				,	(select count(*) from icwsys.SiteProductData 
						where DSSMasterSiteID > 0 
						and barcode is null) 
						as 'Null Barcodes'
				,	(select count(*) from icwsys.SiteProductData
						where DSSMasterSiteID > 0 
						and not barcode is null 
						and len(rtrim(barcode)) = 0) 
						as 'Blank Barcodes'
				,	(select count(*) from icwsys.SiteProductData
						where DSSMasterSiteID > 0 
						and not barcode is null 
						and len(rtrim(barcode)) > 0
						and barcode <> icwsys.fNSVtoBarcode(siscode)) 
						as 'Pack Barcodes'
				,	(select count(*) from icwsys.SiteProductData
						where DSSMasterSiteID > 0 
						and not barcode is null 
						and len(rtrim(barcode)) > 0
						and barcode = icwsys.fNSVtoBarcode(siscode)) 
						as 'NSV derived Barcodes'
			
			If @@ERROR <> 0
				begin
					print 'Error while counting barcodes'
				end
			else
				begin
					insert into icwsys.SiteProductDataAlias
					(		SiteProductDataID
						,	AliasGroupID
						,	Alias
						,	[Default]
					)
						select 
							SiteProductDataID,
							@AliasGroupID,
							barcode,
							1
						from icwsys.siteproductdata
						where DSSMasterSiteID > 0
							and not barcode is null 
							and len(rtrim(barcode)) > 0
							and icwsys.fNSVtoBarcode(siscode) <> barcode
					
					if @@ERROR <> 0 
						begin
							print 'Error while copying primary barcodes to SiteProductDataAlias table'
						end
					else
						begin
							update icwsys.siteproductdata
							set barcode = icwsys.fNSVtoBarcode(siscode)
							where DSSMasterSiteID > 0
								and 
								(barcode is null
								or len(rtrim(barcode)) = 0
								or barcode <> icwsys.fNSVtoBarcode(siscode) 
								)
								
							if @@ERROR <> 0
								begin
									print 'Error while generating replacement primary barcodes'
								end
							else
								begin
									commit tran 

									select	(select count(*) from icwsys.SiteProductData
												where DSSMasterSiteID > 0) 
												as 'All Products (After)'
										,	(select count(*) from icwsys.SiteProductData 
												where DSSMasterSiteID > 0 
												and barcode is null) 
												as 'Null Barcodes'
										,	(select count(*) from icwsys.SiteProductData
												where DSSMasterSiteID > 0 
												and not barcode is null 
												and len(rtrim(barcode)) = 0) 
												as 'Blank Barcodes'
										,	(select count(*) from icwsys.SiteProductData
												where DSSMasterSiteID > 0 
												and not barcode is null 
												and len(rtrim(barcode)) > 0
												and barcode <> icwsys.fNSVtoBarcode(siscode)) 
												as 'Pack Barcodes'
										,	(select count(*) from icwsys.SiteProductData
												where DSSMasterSiteID > 0 
												and not barcode is null 
												and len(rtrim(barcode)) > 0
												and barcode = icwsys.fNSVtoBarcode(siscode)) 
												as 'NSV derived Barcodes'	
																					
									select  d.barcode as 'Duplicated barcode'
										,	d.siscode as 'Primary'
										,	p.siscode as 'Secondary'
									from icwsys.SiteProductData d					-- drug with primary barcode
									join icwsys.SiteProductDataAlias a				-- alias with secondary barcode
										on d.barcode = a.alias
									left join icwsys.SiteProductData p				-- parent of alias
										on a.SiteProductDataID = p.SiteProductDataID
									where d.DSSMasterSiteID = p.DSSMasterSiteID		-- duplicate is allowed in DSS data and any other 'system' in the same db
								end
						end
				end
			if @@TRANCOUNT > 0
				begin
					rollback tran
				end
		end	
			
GO

-- update version table --
INSERT VersionLog (Type, [Description], [Date]) SELECT 'Config', 'Move Barcodes to secondary & regenerate from NSV TFS86783 (10.14) V2.sql', GETDATE()

GO
----------------------------------------------------------------------

