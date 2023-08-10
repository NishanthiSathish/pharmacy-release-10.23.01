/*
	Pharmacy client setting for the UHB interface
	Only need for testing purpose as should already exist on site
*/

DECLARE @SiteNumber varchar(3)
SET @SiteNumber = 

DECLARE @OutputPath varchar(256)
SET @OutputPath = 



DECLARE @ErrorMsg  varchar(300)
IF (len(@SiteNumber) > 3)
BEGIN
	SELECT @ErrorMsg = 'ERROR: All Site Number must be 3 digits or less'
	GOTO ErrorHandler
END

IF NOT EXISTS(SELECT TOP 1 1 FROM Site WHERE SiteNumber=@SiteNumber)
BEGIN
	SELECT @ErrorMsg = 'ERROR: Site number ' + CAST(@SiteNumber as varchar(10)) + ' also need to be present in the Site table'
	GOTO ErrorHandler
END

IF (@OutputPath IS NULL OR LEN(@OutputPath) = 0)
BEGIN
	SELECT @ErrorMsg = 'ERROR: output path is not set'
	GOTO ErrorHandler
END

DECLARE @SiteID int
SELECT TOP 1 @SiteID = Site.LocationID FROM Site WHERE  Site.SiteNumber = @SiteNumber

SET @OutputPath = '"' + @OutputPath + '"'

DECLARE @FilePointerName as varchar(256)
SET @FilePointerName = '"\\core-store\Development\innov\dispdata.' + @SiteNumber + '\StockInt"'

Exec pWConfigurationWrite 0, @SiteID,'D|Genint','GenericInterface','SupplierTypes','"EWS"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','BatchDataRTFFile','"UHBOrdData.rtf"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','ExportFilePath',@OutputPath
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','FilePrefix','"ASCRIBE_"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','Filesuffix','"_POR"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','InterfacePointerFile',@FilePointerName
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','OutputFileExtension','".xml"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','OrderLogInterface','RTFFile','"UHBOrdData.rtf"'
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','ExportFilePath',@OutputPath
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','FilePrefix','"ASCRIBE_"'
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','Filesuffix','"_STK"'
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','InterfacePointerFile',@FilePointerName
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','OutputFileExtension','".xml"'
Exec pWConfigurationWrite 0, @SiteID,'D|GenInt','StockInterface','RTFFile','"UHBStock.rtf"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','ExportFilePath',@OutputPath
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','FilePrefix','"ASCRIBE_"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','Filesuffix','"_SUP"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','InterfacePointerFile',@FilePointerName
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','OutputFileExtension','".xml"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','SupplierInterface','RTFFile','"UHBSup.rtf"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','ExportFilePath',@OutputPath
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','FilePrefix','"ASCRIBE_"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','Filesuffix','"_ISS"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','InterfacePointerFile',@FilePointerName
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','OutputFileExtension','".xml"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','PatientPaymentDefault','"UNKNOWN"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','PaymentFilter','"UNKNOWN"'
Exec pWConfigurationWrite 0, @SiteID,'D|Genint','TranslogInterface','RTFFile','"UHBIss.rtf"'
Exec pWConfigurationWrite 0, @SiteID,'D|PatMed','GenericInterface','OrderInterface','"Y"'
Exec pWConfigurationWrite 0, @SiteID,'D|PatMed','GenericInterface','PrintingInterface','"Y"'
Exec pWConfigurationWrite 0, @SiteID,'D|patmed','GenericInterface','StockInterface','"True"'
Exec pWConfigurationWrite 0, @SiteID,'D|patmed','GenericInterface','SupplierInterface','"Y"'

IF NOT EXISTS(SELECT TOP 1 1 FROM WFilePointer WHERE Category='D|StockInt' and SiteID=@SiteID)
	INSERT INTO wFilePointer (SiteID, Category, PointerID, DSSMasterSiteID) VALUES (@SiteID, 'D|StockInt', 1, NULL)

ErrorHandler:
IF @ErrorMsg <> ''
	raiserror (@ErrorMsg, 16, 1)
GO
	
--Add to Version Log
INSERT VersionLog ([Type], [Description], [Date]) SELECT 'Config', 'UHB Pharmacy Client Interface configuration script (for testing only).sql v3', GETDATE()
GO