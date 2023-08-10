
--eHub Interface Configuration patch


declare @siteID int

set @siteID = 15 -- << Set Here

--Main PSO Switch
exec pWConfigurationwrite 0,@siteID,'D|PSO','PSO','AllowPSO','"Y"'

exec pWConfigurationwrite 0,@siteID,'D|Patmed','GenericInterface','PSOOrderInterface','"Y"'

exec pWConfigurationwrite 0,@siteID,'D|GenInt','GenericInterface','PSOOrderKinds','"D"'  --We only want outboud paper PSO orders

exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOSupplierTypes','"WSE"'

exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','FilePrefix','"ASCRIBE_"'


exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','FilesuffixCredit','"_CRO"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','FilesuffixOrder','"_POR"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','FilesuffixAdjust','"_STA"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','FilesuffixReceipt','"_GRN"'


exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSORTFFile','"HubOrderLine.rtf"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOBatchFooterRTFFile','"eHubOrderFooterOutput.rtf"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOBatchHeaderRTFFile','"eHubOrderHeaderOutput.rtf"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOBatchDataRTFFile','"eHubOrderLineOutput.rtf"'

exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOExportFilePath','""' --<< Set the Hub Order export directory here !!!
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOFilePrefix','""'


exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','InterfacePointerFile','"E:\ascroot\eHub"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOOutputFileExtension','".xml"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','Ordering','PSOBatchOrderOutput','"Y"'

exec pWConfigurationwrite 0,@siteID,'D|Patmed','GenericInterface','PSOOrderInterface','"Y"'

exec pWConfigurationwrite 0,@siteID,'D|Winord','eHubIntegration','eHubOrderLineTransferPrint','"Y"'
exec pWConfigurationwrite 0,@siteID,'D|Winord','eHubIntegration','eHubOrderLinesp','"pPharmacyeHubIntegration"'
exec pWConfigurationwrite 0,@siteID,'D|Winord','eHubIntegration','eHubOrderLineTransfer','"Y"'

declare @DSSMasterSiteID int

select @DSSMasterSiteID = DSSMasterSiteID from DSSMasterSiteLinkSite where SiteID = @siteID
insert into WFilePointer (SiteID,category,PointerID,DSSMastersiteID) values( @siteID,'A|PSOOrderOutput',1,@DSSMasterSiteID)

insert into WFilePointer (SiteID,category,PointerID,DSSMastersiteID) values( @siteID,'A|Orderint.dat',1,@DSSMasterSiteID)

insert into WFilePointer (SiteID,category,PointerID,DSSMastersiteID) values( @siteID,'D|Orderint.dat',1,0)

--Disp UI stuff
Sets the default type of order on none medicinal issue
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','DefaultNonMed','"Service"'

--Set here the defaults 9if required) for the renewal details
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','DefaultRenewalContact','""'
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','DefaultRenewalTelNo','""'
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','DefaultRenewalEmail','""'

--Stores POD
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','AllowHubPOD','"Y"'  --Use Hub POD Processing

exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','HubPODImportPath','""' --<< Set the import directory for POD here !!!

exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','HubPODArchivePath','""' --<< Set the directory for POD Archivehere !!!

--Invoice
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','HubInvoiceArchivePath','""' --<< Set the Hub Invoice Archive directory here !!!

--line differentials 
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','eHubBatchDataRTFFile_Medicinal','"eHubOrderLineOutput_Medicinal.rtf"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','eHubBatchDataRTFFile_Service','"eHubOrderLineOutput_Service.rtf"'
exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','eHubBatchDataRTFFile_Equipment','"eHubOrderLineOutput_Equipment.rtf"'


--eHub Invoicing Defaults

--Not yet implemented, but these represent the default limits for eHub invoicing. THe import path should be defined here also
exec pWConfigurationwrite 0,@siteID,'D|PSO','Default','HUBInvLowerDiff','"5"'
exec pWConfigurationwrite 0,@siteID,'D|PSO','Default','HUBInvUpperDiff','"5"'
exec pWConfigurationwrite 0,@siteID,'D|PSO','Default','HUBImportPath','""'  --<< Set the Hub Invoice import directory here !!!
exec pWConfigurationwrite 0,@siteID,'D|PSO','Default','HUBInvLowerDiffOC','"5"'
exec pWConfigurationwrite 0,@siteID,'D|PSO','Default','HUBInvUpperDiffOC','"5"'

--Hub Validation - on NHS Number
exec pWConfigurationwrite 0,@siteID,'D|PSO','eHubIntegration','DefaultPatientID','"nhnumber"'

exec pWConfigurationwrite 0,@siteID,'D|Genint','OrderlogInterface','PSOMethodTypes','"DFEIMTH"'
