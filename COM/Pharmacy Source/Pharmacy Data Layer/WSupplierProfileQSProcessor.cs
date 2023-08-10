//===========================================================================
//
//							    WSupplierProfileQSProcessor.cs
//
//  Maps the fields in WSupplierProfile to QuesScrl data indexes stores in WConfiguration
//  
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Moved from QS layer to pharmacy layer 88509
//  16Oct14 XN  102114 Removed GetRequiredDataIndexes as now done by base class
//  28Oct14 XN  100212 Added GetDSSMaintainedDataIndex
//  18May15 XN  117528 Update Save due to changes in WSupplierProfile (will now log and update mod details)
//  30Jul15 XN  124545 Added extra validation of the vat code as the field is now editable
//  03Mar16 XN  Improved lookup list 99381
//  18Jul16 XN  126634 Added EdiBarcode
//===========================================================================

namespace ascribe.pharmacy.pharmacydatalayer
{
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
    using System.Text;

    public class WSupplierProfileQSProcessor : QSBaseProcessor
    {
        #region Important Data Indexes
        public const int DATAINDEX_TRADENAME = 3;
        public const int DATAINDEX_VATCODE   = 11;
        public const int DATAINDEX_EDIBARCODE= 14;  // 18Jul16 XN 126634 Added EdiBarcode
        #endregion

        #region Private Variables
        private SiteProductData siteProductData = new SiteProductData();
        #endregion

        #region Public Properties
        public WSupplierProfile SupplierProfiles { get; private set; }
        #endregion

        #region Constuctor
        public WSupplierProfileQSProcessor() : base(null) { }
    
        public WSupplierProfileQSProcessor(WSupplierProfile supplierProfiles, IEnumerable<int> siteIDs) : base(siteIDs)
        {
            this.SupplierProfiles = supplierProfiles;
            this.SiteIDs          = siteIDs.Where(s => supplierProfiles.Any(p => p.SiteID == s)).ToList();
        }
        #endregion

        #region Public Methods
        /// <summary>If drug is a dss drug returns list of DSS Maintained Data Indexes 28Oct14 XN  100212</summary>
        public int[] GetDSSMaintainedDataIndex()
        {
            List<int> returnValue = new List<int>();

            WSupplierProfileRow supplierProfile = SupplierProfiles.First();

            // Get the product so we known if the Drug is DSS maintained
            SiteProductDataRow productRow = siteProductData.FindByNSVCode( supplierProfile.NSVCode );
            if (productRow == null)
            {
                siteProductData.LoadBySiteIDAndNSVCode( supplierProfile.SiteID, supplierProfile.NSVCode, true );
                productRow = siteProductData.FindByNSVCode( supplierProfile.NSVCode );
            }

            if ( productRow.IsDSSMaintainedDrug() )
            {
                // Get list of DSS Maintained fields
                returnValue = WConfiguration.Load<string>(SessionInfo.SiteID, "D|SUPPROF", "Editor", "DSS Maintained Fields", string.Empty, false).ParseCSV<int>(",", true).ToList();

                // If tradename field is empty or whitespace then allow editing
                if ( returnValue.Contains( WSupplierProfileQSProcessor.DATAINDEX_TRADENAME ) && string.IsNullOrWhiteSpace(supplierProfile.SupplierTradename) )
                    returnValue.Remove( WSupplierProfileQSProcessor.DATAINDEX_TRADENAME );
            }

            return returnValue.ToArray();
        }
        #endregion

        #region Overridden Methods
        //  16Oct14 XN  102114 Removed GetRequiredDataIndexes as now done by base class
        //public override HashSet<int> GetRequiredDataIndexes()
        //{
        //    return new HashSet<int>();
        //}

        /// <summary>Called to update qsView with all the values (from processor data)</summary>
        public override void PopulateForEditor(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                WSupplierProfileRow row = SupplierProfiles.FirstOrDefault(s => s.SiteID == siteID);

                foreach(var qsDataInputItem in qsView)
                    qsDataInputItem.SetValueBySiteID(siteID, this.GetValueForEditor(row, qsDataInputItem.index));
            }
        }

        /// <summary>Returns mapped data index value as string</summary>
        public string GetValueForEditor(WSupplierProfileRow row, int index)
        {
            try
            {
                switch (index)
                {
                case  1:  return row.NSVCode;
                case  2:  SiteProductDataRow productRow = siteProductData.FindByNSVCode(row.NSVCode);
                          if (productRow == null)
                          {
                              siteProductData.LoadBySiteIDAndNSVCode(row.SiteID, row.NSVCode, true);
                              productRow = siteProductData.FindByNSVCode(row.NSVCode);
                          }
                          return productRow                        == null ? string.Empty : productRow.ToString();
                case  3:  return row.SupplierTradename;
                case  4:  return row.ContractNumber;
                case  5:  return row.ReorderPackSize               == null ? string.Empty : row.ReorderPackSize.Value.ToString("0.####");
                case  6:  return row.LastReceivedPriceExVatPerPack == null ? string.Empty : row.LastReceivedPriceExVatPerPack.Value.ToString("0.####");
                case  7:  return row.ContractPrice                 == null ? string.Empty : row.ContractPrice.Value.ToString("0.####");
                case  8:  return row.LeadTimeInDays                == null ? string.Empty : row.LeadTimeInDays.Value.ToString("0.###");
                case  9:  return row.LastReconcilePriceExVatPerPack== null ? string.Empty : row.LastReconcilePriceExVatPerPack.Value.ToString("0.###");
                case  10: return row.SupplierReferenceNumber;
                case  11: return row.VATCode                       == null ? string.Empty : row.VATCode.Value.ToString();
                case  12: return row.SupplierName;
                case  13: return row.SupplierCode;
                case  DATAINDEX_EDIBARCODE: return row.EdiBarcode;  // 18Jul16 XN 126634 Added EdiBarcode
                }
            }
            catch(Exception)
            {
            }

            return string.Empty;
        }

        /// <summary>Call to setup all the lookups in QSView</summary>
        public override void SetLookupItem(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                var supplierProfile = this.SupplierProfiles.FirstOrDefault(c => c.SiteID == siteID);

                //if (qsView.ContainsDataIndex(11)) 03Mar16 XN 99381 Duplicate of below 
                //    qsView.FindByDataIndex(11).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title={2}&Info=Choose {2} Code&sp=pTaxLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Code,15,Description,85&selectedDBID={{currentValue}}&Width=300&Height=400", SessionInfo.SessionID, siteID, PharmacyCultureInfo.SalesTaxName);
                if (qsView.ContainsDataIndex(DATAINDEX_VATCODE))   // Vat Code
                    qsView.FindByDataIndex(DATAINDEX_VATCODE).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title={2}&Info=Choose {2} Code&sp=pTaxLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Code,15,Description,85&selectedDBID={{currentValue}}&SearchType=TypeAndSelect&SearchColumns=0&SearchText={{typedText}}&Width=300&Height=400", SessionInfo.SessionID, siteID, PharmacyCultureInfo.SalesTaxName);
                    //qsView.FindByDataIndex(DATAINDEX_VATCODE).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title={2}&Info=Choose {2} Code&sp=pTaxLookup&Params=CurrentSessionID:{0},SiteID:{1}&Columns=Code,15,Description,85&selectedDBID={{currentValue}}&Width=300&Height=400", SessionInfo.SessionID, siteID, PharmacyCultureInfo.SalesTaxName); 03Mar16 XN 99381 
                
                // 18Jul16 XN 126634 Added EdiBarcode
                if (qsView.ContainsDataIndex(DATAINDEX_EDIBARCODE) && supplierProfile != null)
                    qsView.FindByDataIndex(DATAINDEX_EDIBARCODE).SetLookupMap(siteID, @"PharmacyProductEditor\SupplierProfileEdiBarcodeLookup.aspx?SessionID={0}&SiteID={1}&NSVCode={2}&SelectedBarcode={{currentValue}}", SessionInfo.SessionID, siteID, supplierProfile.NSVCode);
            }
        }

        /// <summary>
        /// Called to validate the web controls in QSView
        /// 16Oct14 XN 102125 Updated to handle forced mandatory option
        /// </summary>
        /// <returns>Returns list of validation errors or warnings</returns>
        public override QSValidationList Validate(QSView qsView)
        {
            QSValidationList validationInfo = new QSValidationList();
            HashSet<int>     required       = this.GetRequiredDataIndexes(qsView);

            foreach (var siteID in SiteIDs)
            {
                WSupplierProfileRow row = this.SupplierProfiles.FirstOrDefault(s => s.SiteID == siteID);
                if (row == null)
                    continue;
            
                foreach(QSDataInputItem item in qsView)
                {
                    try
                    {
                        WebControl webCtrl = item.GetBySiteID(siteID);
                        if (webCtrl is Label || !item.Enabled)
                            continue;

                        string value = item.GetValueBySiteID(siteID);
                        string error = string.Empty;

                        // 16Oct14 XN 102125 allow setting item mandatory via config
                        if (item.ForceMandatory && string.IsNullOrWhiteSpace(value))
                            validationInfo.AddError(siteID, "Please enter " + item.description + " value");

                        // 30Jul15 XN 124545 added VAT code validation
                        switch(item.index)
                        {
                        case DATAINDEX_VATCODE: // VATCODE 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(int), required.Contains(item.index), 0, 9, out error))
                            {
                                validationInfo.AddError(siteID, error);
                            }
                            else
                            {
                                int? vatCode = string.IsNullOrEmpty(value) ? (int?)null : int.Parse(value);
                                if (row.VATCode != vatCode)    
                                {
                                    WProductQSProcessor.ValidateVATCode(siteID, row.NSVCode, row.SupplierCode, validationInfo);
                                }
                            }
                            break;

                        case DATAINDEX_EDIBARCODE: // EDI Barcode   126634 XN 21Jul16
                            var originalVal = GetValueForEditor(row, item.index);
                            if (!Validation.ValidateBarcode(webCtrl, item.description, false, out error))
                                validationInfo.AddError(siteID, error);
                            else if (!string.IsNullOrEmpty(value) && item.CompareValues(siteID, originalVal) != null)
                                CheckIfEdiBarcodeInUse(siteID, row.NSVCode, row.SupplierCode, originalVal, value, DateTime.Today, DateTime.MaxValue, item.description, validationInfo);
                            break;
                        }
                    }
                    catch (Exception ex)
                    {
                        validationInfo.AddError(siteID, "Failed validating {0} error\n{1}", item.description, ex.GetAllMessaages().ToCSVString("\n"));
                    }
                }
            }

            return validationInfo;
        }

        /// <summary>
        /// Checks if the EDI barocde is in use by a supplier profile or a contract for another drug
        /// Adds the appropriate warning to validationInfo
        /// 1. Check if WSupplierProfile for another dug by same supplier has the same edi barcode (if this occurs need to clear down the profile)
        /// 2. Check if any contract currently in the system might be overwritten when this edi barcode is set
        /// 3. Check if any contract currently in the system might overwrite the edi barcode when set for the supplier profile
        /// 126634 XN 21Jul16
        /// </summary>
        /// <param name="siteID">site id</param>
        /// <param name="NSVCode">current drug NSVCode</param>
        /// <param name="supCode">Supplier code</param>
        /// <param name="originalEdiBarcode">Original Edi barcode</param>
        /// <param name="newEdiBarcode">New Edi barcode being set</param>
        /// <param name="fromDate">when edi barcode is going to be set</param>
        /// <param name="toDate">When supplier is going to stop being active</param>
        /// <param name="controlName">name of control (Edi barcode)</param>
        /// <param name="errors">validation info</param>
        public static void CheckIfEdiBarcodeInUse(int siteID, string NSVCode, string supCode, string originalEdiBarcode, string newEdiBarcode, DateTime fromDate, DateTime toDate, string controlName, QSValidationList errors)
        {
            WExtraDrugDetail extraDetail = new WExtraDrugDetail();
            extraDetail.LoadByDueSiteIDSupCodeAndEdiBarcode(siteID, supCode, newEdiBarcode);

            // Check if any contract currently in the system might be overwritten when this edi barcode is set
            var otherDrugsDetails = (from ex in extraDetail
                                        where ex.NSVCode      != NSVCode  && 
                                              ex.DateOfChange >  fromDate && 
                                              ex.DateOfChange <  toDate
                                        orderby ex.DateOfChange, ex.NSVCode
                                        select ex.DateOfChange.ToPharmacyDateString() + " - " + ex.NSVCode + " - " + WProduct.ProductDetails(ex.NSVCode, siteID)).ToCSVString("\n");
            if (!string.IsNullOrEmpty(otherDrugsDetails))
                errors.AddWarning(siteID, "{0} will be overwritten by the following contract updates\n{1}\n", controlName, otherDrugsDetails);

            // Check if any contract currently in the system might overwrite the edi barcode when set for the supplier profile
            otherDrugsDetails     = (from ex in extraDetail
                                        where ex.NSVCode != NSVCode         && 
                                              fromDate   >  ex.DateOfChange && 
                                              toDate     <  ex.DateOfChange
                                        orderby ex.DateOfChange, ex.NSVCode
                                        select ex.DateOfChange.ToPharmacyDateString() + " - " + ex.NSVCode + " - " + WProduct.ProductDetails(ex.NSVCode, siteID)).ToCSVString("\n");
            if (!string.IsNullOrEmpty(otherDrugsDetails))
                errors.AddWarning(siteID, "{0} will overwrite in the following contract updates\n{1}\n", controlName, otherDrugsDetails);
        
            // Check if WSupplierProfile for another dug by same supplier has the same edi barcode 
            WSupplierProfile supplierProfile = new WSupplierProfile();
            supplierProfile.LoadBySiteIDSupplierAndEdiBarcode(siteID, supCode, newEdiBarcode);                                
            var otherDrugs = (from sp in supplierProfile 
                                where sp.NSVCode != NSVCode
                                orderby NSVCode
                                select NSVCode + " - " + WProduct.ProductDetails(NSVCode, siteID)).ToCSVString("\n");
            if (!string.IsNullOrEmpty(otherDrugs))
                errors.AddWarning(siteID, "{0} in use by \n{1}\n if you proceed {0} will be removed {2}from other profiles\n", controlName, otherDrugs, fromDate.Date == DateTime.Today ? string.Empty : "when updated ");

            if (!string.IsNullOrWhiteSpace(originalEdiBarcode))
            {
                // Check if EDI Barocde is in use on an order
                WOrder orders = new WOrder();
                orders.LoadBySiteIDNSVCodeSupCodeAndState(siteID, NSVCode, supCode, new [] { OrderStatusType.WaitingTransmissionConfirmation, OrderStatusType.WaitingToReceive });
                var activeOrderNumbers = from o in orders where o.EDIProductIdentifier == originalEdiBarcode select o.OrderNumber;

                // Check if EDI Barocde is in use on an reconcil order
                WReconcil reconcil = new WReconcil();
                reconcil.LoadBySiteIDNSVCodeSupCodeAndState(siteID, NSVCode, supCode, new [] { OrderStatusType.Received });
                var activeReconcilNumbers = from r in reconcil where r.EDIProductIdentifier == originalEdiBarcode select r.OrderNumber;

                if (activeOrderNumbers.Any() || activeReconcilNumbers.Any())
                    errors.AddWarning(siteID, "Original {0} is currently active orders\n{1}\n", controlName, activeOrderNumbers.Concat(activeReconcilNumbers).Distinct().ToCSVString("\n"));
            }
        }

        /// <summary>Called to get difference between QS data and (original) process data</summary>
        public override QSDifferencesList GetDifferences(QSView qsView)
        {
            QSDifferencesList differences = new QSDifferencesList();
            foreach (int siteID in this.SiteIDs)
            {
                WSupplierProfileRow supplierProfileRow = this.SupplierProfiles.FirstOrDefault(s => s.SiteID == siteID);

                foreach (QSDataInputItem item in qsView)
                {
                    if (item.Enabled)
                    {
                        QSDifference? difference = item.CompareValues(siteID, this.GetValueForEditor(supplierProfileRow, item.index));
                        if (difference != null)
                            differences.Add(difference.Value);
                    }
                }
            }
            return differences;
        }

        /// <summary>Save the values from QSView to the DB (or just localy)</summary>
        /// <param name="qsView">QueScrl controls that hold the data</param>
        /// <param name="saveToDB">If the qsView data is to be saved to the DB (or just updated local data)</param>
        public override void Save(QSView qsView, bool saveToDB)
        {
            WSupplierProfile otherDrugProfiles = new WSupplierProfile();    // 126634 XN 21Jul16

            foreach (int siteID in this.SiteIDs)
            {
                WSupplierProfileRow row = this.SupplierProfiles.FirstOrDefault(s => s.SiteID == siteID);
                if (row == null)
                    continue;

                foreach (QSDataInputItem item in qsView)
                {
                    if (!item.Enabled || item.CompareValues(siteID, GetValueForEditor(row, item.index)) == null)
                        continue;

                    string value = item.GetValueBySiteID(siteID);
                    switch(item.index)
                    {
                    case  3:  row.SupplierTradename             = value;                                                                break;
                    case  4:  row.ContractNumber                = value;                                                                break;
                    case  5:  row.ReorderPackSize               = string.IsNullOrEmpty(value) ? (decimal?)null : decimal.Parse(value);  break;
                    case  6:  row.LastReceivedPriceExVatPerPack = string.IsNullOrEmpty(value) ? (decimal?)null : decimal.Parse(value);  break;
                    case  7:  row.ContractPrice                 = string.IsNullOrEmpty(value) ? (decimal?)null : decimal.Parse(value);  break;
                    case  8:  row.LeadTimeInDays                = string.IsNullOrEmpty(value) ? (decimal?)null : decimal.Parse(value);  break;
                    case  9:  row.LastReconcilePriceExVatPerPack= string.IsNullOrEmpty(value) ? (decimal?)null : decimal.Parse(value);  break;
                    case  10: row.SupplierReferenceNumber       = value;                                                                break;
                    case  11: row.VATCode                       = string.IsNullOrEmpty(value) ? (int?)null     : int.Parse(value);      break;
                    case  DATAINDEX_EDIBARCODE: // 126634 XN 21Jul16
                        if (!string.IsNullOrEmpty(value))
                            otherDrugProfiles.LoadBySiteIDSupplierAndEdiBarcode(siteID, row.SupplierCode, value, append: true);
                        row.EdiBarcode  = value;                                                                
                        break;
                    }
                }
            }

            // Clear the edi barcodes of any other drug 126634 XN 21Jul16
            otherDrugProfiles.ForEach(r => r.EdiBarcode = string.Empty);

            // Save
            if (saveToDB)
            {
                this.SupplierProfiles.Save(updateModifiedDate: true, saveToPharmacyLog: true);
                otherDrugProfiles.Save(updateModifiedDate: true, saveToPharmacyLog: true);  // 126634 XN 21Jul16
            }
        }

        /// <summary>Writes object data to XML writer</summary>
        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            this.SupplierProfiles.WriteXml(writer);
        }

        /// <summary>Reads object data from XML reader</summary>
        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            this.SupplierProfiles = new WSupplierProfile();
            this.SupplierProfiles.ReadXml(reader);
        }
        #endregion
    }
}
