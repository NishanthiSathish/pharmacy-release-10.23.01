using System;
//===========================================================================
//
//						            XMLHeap.cs
//
//  This class is used to replace vb6 Heap methods to get the data to an RTF report
//  The data will be converted to XML, for standard RTF printing. 
//
//  Usage:
//  Server side
//  WProductRow product = WProduct.GetByProductAndSiteID("DFV435D", SessionInfo.SiteID);
//  string xmlHeap = XMLHeap.DrugInfo(product);
//  PharmacyDataCache.SaveToDBSession("PharmacyGeneralReportAttribute", xmlHeap);
//  
//  Then on client side
//  ICWWindow().document.frames['fraPrintProcessor'].PrintReport(2323, 'Pharmacy Shelf Label 3', 0, false, '');
//  
//	Modification History:
//	29Jan14 XN  Created
//  06May14 XN  Added XMLHeap.LookupInfo
//===========================================================================
using System.Text;
using System.Xml;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.reportlayer
{
    public static class XMLHeap
    {
        /// <summary>
        /// Implementation of SUBPATME.BAS FillHeapDrugInfo method
        ///  The XML will be in the form
        ///     {Heap 
        ///         iCode="{code}"
        ///         iDescription="{description}"
        ///         :
        ///     /}
        ///     
        /// No longer supports fields
        ///     iDeluserid
        ///     iAltsupcode
        ///     iDirectioncode
        ///     iAtc
        ///     iIndexed
        ///     iIndexedyn
        ///     iATCcode
        ///     iChemical
        ///     
        /// Many of the xml node names are in form iCost/100 which is not XML compatable.
        /// These have been xml escaped, but it is unclear if these are unescaed at other end (this has not been tested)
        /// 
        /// Also a lot of double, and decimal values have been converted directly to string without any rounding applied to them 
        /// </summary>
        /// <param name="product">to convert</param>
        /// <returns>product data as xml for printing</returns>
        public static string DrugInfo(WProductRow product)
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                xmlWriter.WriteAttributeString("iCode", product.Code);
                string description = product.Description.Replace('!', ' ');
                xmlWriter.WriteAttributeString("iDescription", description);
                xmlWriter.WriteAttributeString("iDescriptionXML", description.XMLEscape());
                string descriptionTrim = description.SafeSubstring(0, WConfiguration.LoadAndCache<int>(product.SiteID, "D|genint", "StockInterface", "DescriptionTrim", 20, false));
                xmlWriter.WriteAttributeString("iDescriptionTrim", descriptionTrim);
                xmlWriter.WriteAttributeString("iDescriptionTrimXML", descriptionTrim.XMLEscape());
                xmlWriter.WriteAttributeString("iInuse", product.InUse.ToYNString());
                xmlWriter.WriteAttributeString("iTradename", product.Tradename);
                xmlWriter.WriteAttributeString("iCost", product.AverageCostExVatPerPack.ToString("0.####"));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100"), (product.AverageCostExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iContno", product.ContractNumber);
                xmlWriter.WriteAttributeString("iSupcode", product.SupplierCode);
                xmlWriter.WriteAttributeString("iWarningcode2", product.WarningCode2);
                xmlWriter.WriteAttributeString("iLedcode", product.LedgerCode);
                xmlWriter.WriteAttributeString("iNSVcode", product.NSVCode);
                xmlWriter.WriteAttributeString("iBarcode", product.Barcode);
                xmlWriter.WriteAttributeString("iCyto", product.IsCytotoxic.ToYNString());
                xmlWriter.WriteAttributeString("iCivas", product.IsCIVAS.ToYNString());
                xmlWriter.WriteAttributeString("iFormulary", product.FormularyCode);
                xmlWriter.WriteAttributeString("iBnf", product.BNF);
                xmlWriter.WriteAttributeString("iReconvol", product.ReconstitutionVolumeInml.ToString());
                xmlWriter.WriteAttributeString("iReconabbr", product.ReconstitutionAbbreviation);
                xmlWriter.WriteAttributeString("iDiluent1abbr", product.DiluentAbbreviation1);
                xmlWriter.WriteAttributeString("iDiluent2abbr", product.DiluentAbbreviation2);
                xmlWriter.WriteAttributeString("iMaxmgPerml", product.MaxConcentrationInDoseUnitsPerml.ToString());
                xmlWriter.WriteAttributeString("iWarningcode", product.WarningCode);
                xmlWriter.WriteAttributeString("iInscode", product.InstructionCode);
                xmlWriter.WriteAttributeString("iLabelformat", product.LabelFormat);
                xmlWriter.WriteAttributeString("iExpirymin", product.ExpiryTimeInMintues.ToString());
                xmlWriter.WriteAttributeString("iExpiryDays", ((product.ExpiryTimeInMintues + 1339) / 1440).ToString());
                xmlWriter.WriteAttributeString("iStockedyn", product.IsStocked.ToYesNoString().PadRight(5, ' '));
                xmlWriter.WriteAttributeString("iStocked", product.IsStocked.ToYNString());
                xmlWriter.WriteAttributeString("iReordpcksize", product.ReorderPackSize.ToString());
                xmlWriter.WriteAttributeString("iPrintform", product.PrintformV);
                xmlWriter.WriteAttributeString("iMinissue", product.MinIssueInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iMaxissue", product.MaxIssueInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iReorderlevel", product.ReorderLevelInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iReorderquantity", product.ReOrderQuantityInPacks.ToString());
                xmlWriter.WriteAttributeString("iPackSize", product.ConversionFactorPackToIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iAnuse", product.AnnualUsageInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iMessage", product.Notes);
                xmlWriter.WriteAttributeString("iTherapcode", product.TherapyCode);
                xmlWriter.WriteAttributeString("iExtralabel", product.ExtraLabel);
                xmlWriter.WriteAttributeString("iStocklevel", product.StockLevelInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iSislistprice", product.LastReceivedPriceExVatPerPack.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iSislistprice/100"), (product.LastReceivedPriceExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iContprice", product.ContractPrice.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iContprice/100"), (product.ContractPrice / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iLivestock", product.IfLiveStockControl.ToYNString());
                xmlWriter.WriteAttributeString("iLeadtime",product.LeadTimeInDays.ToString());
                xmlWriter.WriteAttributeString("iLeadtimeVal", product.LeadTimeInDays.ToString());
                xmlWriter.WriteAttributeString("iLocation", product.Location);
                xmlWriter.WriteAttributeString("iUsagedamping", product.UsageDamping.ToString());
                xmlWriter.WriteAttributeString("iSafetyfactor", product.SafetyFactor.ToString());
                xmlWriter.WriteAttributeString("iRecalcatperiodend", product.ReCalculateAtPeriodEnd.ToYNString());
                xmlWriter.WriteAttributeString("iLossesgains", product.LossesGainExVat.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iLossesgains/100"), (product.LossesGainExVat / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iDoses/Issunit"), product.DosesPerIssueUnit.ToString());
                xmlWriter.WriteAttributeString("iMlsperpack", product.mlsPerPack.ToString());
                xmlWriter.WriteAttributeString("iOrdercycle", product.OrderCycle);
                xmlWriter.WriteAttributeString("iCyclelength", product.CycleLengthInDays.ToString());
                xmlWriter.WriteAttributeString("iReconcileprice", product.LastReconcilePriceExVatPerPack.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iReconcileprice/100"), (product.LastReconcilePriceExVatPerPack / 100).ToString("0.00"));
                xmlWriter.WriteAttributeString("iOutstanding", product.OutstandingInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iUseThisPeriod", product.UseThisPeriodInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("iVATrate", product.VATRate.ToString("0.##"));
                xmlWriter.WriteAttributeString("iDosingunits", product.DosingUnits);
                xmlWriter.WriteAttributeString("iUsermessage", product.MessageCode);
                xmlWriter.WriteAttributeString("iMaxInfRate", product.MaxInfusionRate.ToString());
                xmlWriter.WriteAttributeString("iMinmgPerml", product.MinConcentrationInDoseUnitsPerml.ToString());
                xmlWriter.WriteAttributeString("iInfusiontime", product.InfusionTime.ToString());
                xmlWriter.WriteAttributeString("iMgPerml", product.mlsPerPack.ToString());
                xmlWriter.WriteAttributeString("iIVcontainer", product.IVContainer);
                xmlWriter.WriteAttributeString("iDisplVol", product.DisplacementVolumeInml.ToString());
                xmlWriter.WriteAttributeString("iPILnumber", product.PILnumber.ToString());
                xmlWriter.WriteAttributeString("iDatelastperiodend", product.StartOfPeriod.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("iMindailydose", product.MinDailyDose.ToString());
                xmlWriter.WriteAttributeString("iMaxdailydose", product.MaxDailyDose.ToString());
                xmlWriter.WriteAttributeString("iMinDoseFreq", product.MinDoseFrequency.ToString());
                xmlWriter.WriteAttributeString("iMaxDoseFreq", product.MaxDoseFrequency.ToString());
                xmlWriter.WriteAttributeString("iLocalCode", product.LocalProductCode);
                xmlWriter.WriteAttributeString("iDSSform", product.DPSForm);
                xmlWriter.WriteAttributeString("iStoresdesc", product.StoresDescription.Replace('!', ' '));
                xmlWriter.WriteAttributeString("iGendesc", product.ToString());
                xmlWriter.WriteAttributeString("iStorespack", product.StoresPack);
                xmlWriter.WriteAttributeString("iLocation2", product.Location2);
                xmlWriter.WriteAttributeString("iPipCode", product.PIPCode);
                xmlWriter.WriteAttributeString("iMasterPip", product.MasterPIP);
                xmlWriter.WriteAttributeString("ilastissued", product.LastIssuedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ilastordered", product.LastOrderedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ibatchtracking", EnumDBCodeAttribute.EnumToDBCode(product.BatchTracking));
                xmlWriter.WriteAttributeString("ilaststocktakedate", product.LastStockTakeDateTime.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("ilaststocktaketime", product.LastStockTakeDateTime.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("iCreatedUser", product.CreatedByUserInitials);
                xmlWriter.WriteAttributeString("icreatedterminal", product.CreatedOnTerminal);
                xmlWriter.WriteAttributeString("icreateddate", product.CreatedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("icreatedtime", product.CreatedDate.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("imodifieduser", product.ModifiedByUserInitials);
                xmlWriter.WriteAttributeString("imodifiedterminal", product.ModifiedOnTerminal);
                xmlWriter.WriteAttributeString("imodifieddate", product.ModifiedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("imodifiedtime", product.ModifiedDate.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("iSuprefno", product.SupplierReferenceNumber);
                xmlWriter.WriteAttributeString("iSupTradeName", product.SupplierTradename);
                switch (product.BatchTracking)
                {
                case BatchTrackingType.OnReceipt :                      xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(product.SiteID, "D|winord", string.Empty, "BatchTracking1", "Record Batch on Receipt",                               false)); break;
                case BatchTrackingType.OnReceiptWithExpiry :            xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(product.SiteID, "D|winord", string.Empty, "BatchTracking2", "Record Batch and Expiry on Receipt",                    false)); break;
                case BatchTrackingType.OnReceiptWithExpiryAndConfirm :  xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(product.SiteID, "D|winord", string.Empty, "BatchTracking3", "Record Batch and Expiry on Receipt & Confirm on Issue", false)); break;
                default :                                               xmlWriter.WriteAttributeString("ibatchtrackingTxt", WConfiguration.LoadAndCache<string>(product.SiteID, "D|winord", string.Empty, "BatchTracking4", "Batch Tracking Off",                                    false)); break;
                }
                xmlWriter.WriteAttributeString("iBatchTrack", (product.BatchTracking > BatchTrackingType.None).ToYNString());
                if (product.ConversionFactorPackToIssueUnits > 0)
                {
                   xmlWriter.WriteAttributeString("iCostUnit", (product.AverageCostExVatPerPack / product.ConversionFactorPackToIssueUnits).ToString("0.####"));
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100Unit"), ((product.AverageCostExVatPerPack / product.ConversionFactorPackToIssueUnits) / 100).ToString("0.00"));
                   xmlWriter.WriteAttributeString("iCostGross", (product.AverageCostExVatPerPack * product.VATRate).ToString("0.####"));
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCostGross/100"), ((product.AverageCostExVatPerPack * product.VATRate) / 100).ToString("0.00"));
                }
                else
                {
                   xmlWriter.WriteAttributeString("iCostUnit", "0");
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCost/100Unit"), "0");
                   xmlWriter.WriteAttributeString("iCostGross", "0");
                   xmlWriter.WriteAttributeString(XmlConvert.EncodeName("iCostGross/100"), "0");
                }
                xmlWriter.WriteAttributeString("iDDDValue", product.RawRow["DDDValue"].ToString());
                xmlWriter.WriteAttributeString("iDDDUnits", product.RawRow["DDDUnits"].ToString());
                xmlWriter.WriteAttributeString("iUserField1", product.UserField1);
                xmlWriter.WriteAttributeString("iUserField2", product.UserField2);
                xmlWriter.WriteAttributeString("iUserField3", product.UserField3);
                xmlWriter.WriteAttributeString("iHIProduct", product.RawRow["HIProduct"].ToString());
                xmlWriter.WriteAttributeString("iEDILinkCode", product.EDILinkCode);
                xmlWriter.WriteAttributeString("iPASANPCCode", product.PASANPCCode);
                xmlWriter.WriteAttributeString("iPNExclude", product.PNExclude.ToYNString());
                xmlWriter.WriteAttributeString("iPSOLabel", product.PSOLabel.ToYNString());
                xmlWriter.WriteAttributeString("iEyeLabel", product.EyeLabel.ToYNString());
         
                xmlWriter.WriteAttributeString("iPhysicalDescription", product.PhysicalDescription);
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Implementation of PRNTCTRL.BAS printextralabel method
        ///  The XML will be in the form
        ///     {Heap}
        ///         {StdLbl1A}
        ///         {StdLbl2A}
        ///         :
        ///     {/Heap}
        /// Each line of the WLookup.Value will be a different StdLbl item
        /// </summary>
        public static string LookupInfo(WLookupRow lookup)
        {
            string[] value = lookup.Value.Split(new [] { "\r\n" }, StringSplitOptions.None);

            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                for (int c = 0; c < value.Length; c++)
                    xmlWriter.WriteAttributeString(string.Format("StdLbl{0}A", c + 1), value[c].Replace("\n", ""));
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Creates an XML heap for a supplier
        /// Replaces vb6 SupPatME.BAS method FillHeapSupplierInfo 
        /// </summary>
        public static string SupplierInfo(WSupplier2Row supplier)
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                xmlWriter.WriteAttributeString("sCode",       supplier.Code);
                xmlWriter.WriteAttributeString("sCntAddress", supplier.ContractAddress);
                xmlWriter.WriteAttributeString("sSupAddress", supplier.SupplierAddress);
                xmlWriter.WriteAttributeString("sInvAddress", supplier.InvoiceAddress);
                xmlWriter.WriteAttributeString("sCntTelNo", supplier.ContractTelNo);
                xmlWriter.WriteAttributeString("sSupTelNo", supplier.SupplierTelNo);
                xmlWriter.WriteAttributeString("sInvTelNo", supplier.InvoiceTelNo);
                xmlWriter.WriteAttributeString("sDiscountDesc", supplier.DiscountDesc);
                xmlWriter.WriteAttributeString("sDiscountVal", supplier.DiscountVal);
                xmlWriter.WriteAttributeString("sMethod", EnumDBCodeAttribute.EnumToDBCode(supplier.Method));
                xmlWriter.WriteAttributeString("sEDI", (supplier.Method == SupplierMethod.EDI).ToYNString());
                switch (supplier.Method)
                {
                case SupplierMethod.EDI:      xmlWriter.WriteAttributeString("sMethodExp", "EDI"); break;
                case SupplierMethod.Fax:      xmlWriter.WriteAttributeString("sMethodExp", "Fax"); break;  
                case SupplierMethod.Internal: xmlWriter.WriteAttributeString("sMethodExp", "Internal"); break;
                case SupplierMethod.Direct:   xmlWriter.WriteAttributeString("sMethodExp", "Direct"); break;  
                default:                      xmlWriter.WriteAttributeString("sMethodExp", "Other"); break;  
                }
                xmlWriter.WriteAttributeString("sOrdMessage", supplier.OrdMessage.Trim());
                xmlWriter.WriteAttributeString("sAvgLeadTime", supplier.AvLeadTime.Trim());
                xmlWriter.WriteAttributeString("sCntFaxNo", supplier.ContractFaxNo);
                xmlWriter.WriteAttributeString("sSupFaxNo", supplier.SupplierFaxNo);
                xmlWriter.WriteAttributeString("sInvFaxNo", supplier.InvoiceFaxNo);
                xmlWriter.WriteAttributeString("sName", supplier.Description);
                xmlWriter.WriteAttributeString("sNameXML", supplier.Description.XMLEscape());
                xmlWriter.WriteAttributeString("sPtn", supplier.PrintTradeName.ToYNString());
                xmlWriter.WriteAttributeString("sPsis", supplier.PrintNSVCode.ToYNString());
                xmlWriter.WriteAttributeString("sfullname", supplier.FullName.Trim());
                string fullnameTrim = supplier.FullName.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "FullnameTrim", 32, true));
                xmlWriter.WriteAttributeString("sfullnameTrim", fullnameTrim);
                xmlWriter.WriteAttributeString("sfullnameTrimXML", fullnameTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sDiscountBelow", supplier.DiscountBelow);
                xmlWriter.WriteAttributeString("sDiscountAbove", supplier.DiscountAbove);
                xmlWriter.WriteAttributeString("sCostCentre", supplier.CostCentre.Trim());
                string costCenterTrim = supplier.CostCentre.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "CostCentreTrim", 8, true));
                xmlWriter.WriteAttributeString("sCostCentreTrim", costCenterTrim);
                xmlWriter.WriteAttributeString("sCostCentreTrimXML", costCenterTrim.XMLEscape());
                //xmlWriter.WriteAttributeString("sPrintPickTick", Trim$(sup.PrintPickTicket), 0
                xmlWriter.WriteAttributeString("sSupType", EnumDBCodeAttribute.EnumToDBCode(supplier.Type));
                xmlWriter.WriteAttributeString("sOrdOutput", supplier.OrderOutput.Trim());
                //xmlWriter.WriteAttributeString("sReceiveGoods", Trim$(sup.ReceiveGoods), 0
                //xmlWriter.WriteAttributeString("sTopUp", Trim$(sup.TopupInterval), 0
                //xmlWriter.WriteAttributeString("sATC", Trim$(sup.ATCSupplied), 0
                //parsedate sup.topupdate, strDate, "dd/mmm/ccyy", 0
                //xmlWriter.WriteAttributeString("sTopUpDate", strDate, 0
                xmlWriter.WriteAttributeString("sInUse", supplier.InUse.ToYNString());
                //xmlWriter.WriteAttributeString("swardcode", Trim$(sup.wardcode), 0                    '21Oct09 TH (F0066973)
                //xmlWriter.WriteAttributeString("swardcodeXML", XMLEscape(Trim$(sup.wardcode)), 0      '21Oct09 TH Addd for good measure (Zetes)
                xmlWriter.WriteAttributeString("sMinOrderValue", supplier.MinimumOrderValue.ToString());

                // For UHB - parse the address onto 4 lines
                var address = supplier.SupplierAddress.Split(',');
                for (int c = 0; c < 4; c++)
                {
                    string aline = ((address.Length - 1) > c) ? address[c] : string.Empty;
                    xmlWriter.WriteAttributeString("sSuppAdd" + c.ToString(), aline);
                    xmlWriter.WriteAttributeString("sSuppAdd" + c.ToString() + "XML", aline.XMLEscape());
                }
                xmlWriter.WriteAttributeString("sSuppPostcode", address.Length > 0 ? address[address.Length - 1] : string.Empty);
         
                xmlWriter.WriteAttributeString("sNationalSupplierCode", supplier.NationalSupplierCode);
                xmlWriter.WriteAttributeString("sDUNSReference", supplier.DUNSReference);
                xmlWriter.WriteAttributeString("sUserField1", supplier.UserField1);
                xmlWriter.WriteAttributeString("sUserField2", supplier.UserField2);
                xmlWriter.WriteAttributeString("sUserField3", supplier.UserField3); // Contract Name 1
                xmlWriter.WriteAttributeString("sUserField4", supplier.UserField4); // Contract Name 2

                WSupplier2ExtraDataRow extraData = WSupplier2ExtraData.GetByID(supplier.WSupplier2ID);
                xmlWriter.WriteAttributeString("sCurrentContractData", extraData == null ? string.Empty : extraData.CurrentContractData.Trim());
                xmlWriter.WriteAttributeString("sNewContractData",     extraData == null ? string.Empty : extraData.NewContractData.Trim());
                xmlWriter.WriteAttributeString("sDateofChange",        extraData == null ? string.Empty : extraData.DateOfChange.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("sNotes",               extraData == null ? string.Empty : extraData.Notes.Trim());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Creates an XML heap for a supplier
        /// Replaces vb6 SupPatME.BAS method FillHeapSupplierInfo 
        /// </summary>
        public static string CustomerInfo(WCustomerRow customer)
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                xmlWriter.WriteAttributeString("sCode",       customer.Code);
                xmlWriter.WriteAttributeString("sSupAddress", customer.Address.Trim()); // Legacy print item
                xmlWriter.WriteAttributeString("sAddress", customer.Address.Trim());
                xmlWriter.WriteAttributeString("sSupTelNo", customer.TelephoneNo);      // Legacy print item
                xmlWriter.WriteAttributeString("sTelNo", customer.TelephoneNo);
                xmlWriter.WriteAttributeString("sName", customer.Description);
                xmlWriter.WriteAttributeString("sNameXML", customer.Description.XMLEscape());
                xmlWriter.WriteAttributeString("sfullname", customer.FullName.Trim());
                string fullnameTrim = customer.FullName.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "FullnameTrim", 32, true));
                xmlWriter.WriteAttributeString("sfullnameTrim", fullnameTrim);
                xmlWriter.WriteAttributeString("sfullnameTrimXML", fullnameTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sCostCentre", customer.CostCentre.Trim());
                string costCenterTrim = customer.CostCentre.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "CostCentreTrim", 8, true));
                xmlWriter.WriteAttributeString("sCostCentreTrim", costCenterTrim);
                xmlWriter.WriteAttributeString("sCostCentreTrimXML", costCenterTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sPrintDelNote", customer.PrintDeliveryNote.ToYNString());
                xmlWriter.WriteAttributeString("sPrintPickTick", customer.PrintPickTicket.ToYNString());
                xmlWriter.WriteAttributeString("sSupType", "W");    // Legacy print item
                xmlWriter.WriteAttributeString("sInUse", customer.InUse.ToYNString());

                xmlWriter.WriteAttributeString("sAdHocDelNote", customer.AdHocDelNote.ToYNString());
                xmlWriter.WriteAttributeString("sInPatientDirections", customer.InPatientDirections.ToYNString());
                xmlWriter.WriteAttributeString("sIsCustomer", customer.IsCustomer.ToYNString());
                xmlWriter.WriteAttributeString("sOnCost", customer.OnCost.Trim());
                xmlWriter.WriteAttributeString("sGlobalLocationNumber", customer.GlobalLocationNumber);

                // For UHB - parse the address onto 4 lines
                var address = customer.Address.Split(',');
                for (int c = 0; c < 4; c++)
                {
                    string aline = ((address.Length - 1) > c) ? address[c] : string.Empty;
                    xmlWriter.WriteAttributeString("sSuppAdd" + c.ToString(), aline);
                    xmlWriter.WriteAttributeString("sSuppAdd" + c.ToString() + "XML", aline.XMLEscape());
                }
                xmlWriter.WriteAttributeString("sSuppPostcode", address.Length > 0 ? address[address.Length - 1] : string.Empty);
         
                xmlWriter.WriteAttributeString("sUserField1", customer.UserField1);
                xmlWriter.WriteAttributeString("sUserField2", customer.UserField2);
                xmlWriter.WriteAttributeString("sUserField3", customer.UserField3); // Contract Name 1
                xmlWriter.WriteAttributeString("sUserField4", customer.UserField4); // Contract Name 2

                WCustomerExtraDataRow extraData = WCustomerExtraData.GetByID(customer.WCustomerID);
                xmlWriter.WriteAttributeString("sNewContractData",     extraData == null ? string.Empty : extraData.Notes.Trim());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }
}
