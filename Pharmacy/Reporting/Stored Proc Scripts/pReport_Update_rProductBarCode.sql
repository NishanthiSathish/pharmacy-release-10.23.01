/*
	Purpose:	Support function for the Barcode Functions below - SQLServer has no mod function?
	JKu Note: Execute the pReport_Update_rProduct procedure BEFORE executing this procedure!

*/

SET ANSI_NULLS ON
GO

IF OBJECT_ID('fReport_Mod') IS NOT NULL
	DROP Function fReport_Mod
GO

create function fReport_Mod
	(
	@ToBeDivided 	int,
	@Divisor	int
	)
	returns int
as
begin
	return @ToBeDivided - (abs(@ToBeDivided/@Divisor) * @Divisor)
end
GO

/*
	Purpose:	Required for the identification of a 'Dummy' barcode. Ported from the old
			Version 8 VB code -  take 12 digits as string & find the check digit

*/


SET ANSI_NULLS ON
GO

IF OBJECT_ID('fReport_EANAddChkDigit') IS NOT NULL
	DROP Function fReport_EANAddChkDigit
GO

CREATE FUNCTION fReport_EANAddChkDigit
		(
			@ip varchar(20)
		)
	returns varchar(14)
as
-- CHANGE LOG
-- ==========
-- 29Apr09 TH F0052134 replaced sys with icwsys
begin
declare @i int
declare @chk int
declare @ean table ([id]  int  identity , ean int)
declare @return varchar(14)
declare @val int


   set @return = ''
   If Len(@ip) = 12 
	begin
		set @i = 1
		while @i <= 12
		begin
			insert into @ean (ean) values (cast(substring(@ip, @i, 1) as int))
			set @i = @i + 1
		end
		
		set @chk = 0
		set @i = 2
		while @i<= 12
		begin
			select @val = ean from @ean where id = @i
			set @chk = @chk + @val
			set @i = @i + 2
		end 
		
		set @chk = @chk * 3
		set @chk = dbo.fReport_Mod(@chk , 10 )
		
		set @i = 1
		while @i<=11
		begin
			select @val = ean from @ean where id = @i
			set @chk = @chk + @val
			set @i = @i + 2
		end
		
		set @chk = dbo.fReport_Mod(@chk , 10)
		set @chk = dbo.fReport_Mod((10 - @chk) , 10)
		If @chk < 0 set @chk = @chk + 10
		set @Return = Right(cast(@chk as varchar(14)), 1)
		
	end
	return @Return

End 

GO

/*
	Purpose:	Required for the identification of a 'Dummy' barcode. Ported from the old
			Version 8 VB code -  Create pseudo EAN code from NSVcode

*/
SET ANSI_NULLS ON
GO

IF OBJECT_ID('fReport_DummyBarCode') IS NOT NULL
	DROP Function fReport_DummyBarCode
GO

CREATE FUNCTION fReport_DummyBarCode
	(
		@NSVCode varchar(7)
	)
	returns varchar(14)

as

begin
	declare @tmp	int
	declare @in		varchar(50) 
	declare @Count	int
	declare @op		varchar(14)
	
	set @op = ''
	If Len(@NSVCode) = 7
		begin
			set @in = UPPER(@NSVCode)
			set @Count = 1
			while @Count <= 7
				begin
					set @tmp = ASCII(SUBSTRING(@in, @Count, 1))           	--ASCII value of character
					if @tmp >=48 and @tmp <=57 set @op = @op + Char(@tmp)    --0 to 9      0-9 unchanged
					Else set @op = @op + cast(@tmp as varchar(10)) 				--A to Z etc  A -> 65
					set @Count = @Count + 1
				end   
			set @op = Left(@op + REPLICATE ( '0' , 12 ), 12)       			--pad to 12 digits if necessary
			set @op = @op + dbo.fReport_EANAddChkDigit(@op)
		end
		return @op
end
GO

SET ANSI_NULLS ON
GO

IF OBJECT_ID('pReport_Update_rProductBarCode') IS NOT NULL
	DROP PROCEDURE pReport_Update_rProductBarCode
GO


CREATE PROCEDURE pReport_Update_rProductBarCode

AS

SET NOCOUNT ON
PRINT 'Running pReport_Update_rProductBarCode'

DECLARE @TEXT 			VARCHAR (8000)
DECLARE @LiveDB		VARCHAR (max)

--Get the Live database name we to extract our data from.
SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')

--JKu We create rProductBarCode on the fly. 
IF OBJECT_ID('rProductBarCode') IS NOT NULL
	DROP TABLE rProductBarCode

CREATE TABLE rProductBarCode(
		[NSVCode] varchar (7) PRIMARY KEY not null,
		[Barcode] varchar (14) NULL,
		[SupBarcode1] varchar (14) NULL,
		[SupBarcode2] varchar (14) NULL,
		[SupBarcode3] varchar (14) NULL,
		[SupBarcode4] varchar (14) NULL,
		[SupBarcode5] varchar (14) NULL,
	)

--Just in case
IF OBJECT_ID('tempDB..#TempBarcodes') IS NOT NULL
	DROP TABLE #TempBarcodes

CREATE TABLE #TempBarcodes (NSVCode VARCHAR(7) NOT NULL, BarCode VARCHAR(14) NULL,SupBarcode VARCHAR(14) NULL,AliasGroup VARCHAR(50) NULL )

DECLARE cur CURSOR LOCAL FORWARD_ONLY STATIC FOR
		SELECT 
			NSVCode, Barcode, SupBarcode
		FROM 
			#TempBarcodes
		WHERE (AliasGroup = 'AlternativeBarcode' or  AliasGroup is null) AND
			(Barcode is not null or SupBarcode is not null)
		ORDER BY NSVCode, SupBarCode

DECLARE @NSVCode VARCHAR(7)
DECLARE @BarCode VARCHAR(14)
DECLARE @SupBarCode VARCHAR(14)
DECLARE @COUNT INT
DECLARE @COUNT_OFFSET INT
DECLARE @LastNSVCode VARCHAR(7)


SET @TEXT = 'INSERT INTO [#TempBarcodes] (
		[NSVCode] ,
		[Barcode],
		[SupBarcode],
		[AliasGroup])

	SELECT DISTINCT
		a.siscode NSVCode,
		a.barcode Barcode,
		b.Alias,
		c.[Description]
	FROM ' + @LiveDB + '.icwsys.SiteProductData a 
		left join ' + @LiveDB + '.icwsys.siteproductdataalias b on a.SiteProductDataID = b.SiteProductDataID
		left join ' + @LiveDB + '.icwsys.Aliasgroup c on b.aliasgroupid = c.aliasgroupid
	WHERE 
		a.DSSMasterSiteID <> 0'


EXECUTE (@TEXT)


SET @TEXT = ''
SET @LastNSVCode = ''
OPEN cur

FETCH NEXT FROM cur INTO @NSVCode, @BarCode, @SupBarCode

WHILE @@Fetch_Status = 0
BEGIN
	IF @NSVCode <> @LastNSVCode
	BEGIN
		IF @TEXT <> ''
		BEGIN
			WHILE @COUNT <= 5
			BEGIN
				SET @TEXT = REPLACE(@TEXT, 'NULLSupBARCode' + CAST(@Count AS VARCHAR(1)), 'NULL')
				SET @COUNT = @COUNT + 1
			END
			EXEC (@TEXT)
		END
		
		SET @LastNSVCode = @NSVCode
	
		SET @TEXT = 'INSERT INTO rProductBarCode (
				[NSVCode] ,
				[Barcode] ,
				[SupBarcode1] ,
				[SupBarcode2] ,
				[SupBarcode3] ,
				[SupBarcode4] ,
				[SupBarcode5] )
			VALUES
				(''' + @NSVCode + ''',''' + @BarCode + ''',NULLSupBARCode1,NULLSupBARCode2,NULLSupBARCode3,NULLSupBARCode4,NULLSupBARCode5)'
		
		SET @COUNT = 1
	END

	--CHECK THAT THE PRIMARY BARCODE IS NOT A SYTEM GENERATEED ONE
	IF ISNULL(@NSVCode, '')  <> '' AND @COUNT = 1
	BEGIN 
		IF dbo.fReport_DummyBarCode(@NSVCode) <> @BarCode 
		BEGIN
			SET @TEXT = REPLACE(@TEXT, 'NULLSupBARCode' + CAST(@Count AS VARCHAR(1)), ISNULL('' + @BarCode + '','NULL'))
			SET @COUNT = @COUNT + 1
		END
	END

	IF @Count <= 5 	SET @TEXT = REPLACE(@TEXT, 'NULLSupBARCode' + CAST(@Count AS VARCHAR(1)), ISNULL('' + @SupBarCode + '','NULL'))

	SET @COUNT = @COUNT + 1

	FETCH NEXT FROM cur INTO @NSVCode, @BarCode, @SupBarCode
END
CLOSE cur
DEALLOCATE cur

SET NOCOUNT OFF

IF @TEXT <> ''
BEGIN
	WHILE @COUNT <= 5
	BEGIN
		SET @TEXT = REPLACE(@TEXT, 'NULLSupBARCode' + CAST(@Count AS VARCHAR(1)), 'NULL')
		SET @COUNT = @COUNT + 1
	END
	EXEC (@TEXT)
END

DROP TABLE #TempBarcodes

--JKu Now we link rProductBarCode to rProduct to populate the barcode fields
UPDATE rProduct 
SET 
	BarCode = B.Barcode,
	SupBarcode1	= B.SupBarcode1,
	SupBarcode2	= B.SupBarcode2,
	SupBarcode3	= B.SupBarcode3,
	SupBarcode4	= B.SupBarcode4,
	SupBarcode5	= B.SupBarcode5
FROM rProduct A, rProductBarCode B
WHERE A.NSVCode = B.NSVCode

--Now that we have updateed our rProduct table with barcodes, we can safely drop the rProductBarcode table
IF OBJECT_ID('rProductBarCode') IS NOT NULL
	DROP TABLE rProductBarCode

PRINT ''
