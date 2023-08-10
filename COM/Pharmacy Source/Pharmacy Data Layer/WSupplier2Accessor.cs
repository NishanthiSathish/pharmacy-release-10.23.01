//===========================================================================
//
//							    WSupplier2Accessor.cs
//
//  Maps the fields in WSupplier2 to QuesScrl data indexes stores in WConfiguration
//  
//	Modification History:
//	24Jun14 XN  Written
//  05Nov14 XN  Added checking for outstanding orders when chaning method 103549
//  06Feb15 XN  P type stored as D type in DB 110710 
//  03Mar16 XN  Improved lookup list 99381
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Maps the fields in WSupplier2 to QuesScrl data indexes stores in WConfiguration</summary>
    public class WSupplier2Accessor : QSBaseProcessor
    {
        #region Data Indexes
        public const int DATAINDEX_CODE                 = 1;
        public const int DATAINDEX_FULLNAME             = 2;
        public const int DATAINDEX_CONTRACTADDRESS      = 3;
        public const int DATAINDEX_CONTRACTTELNO        = 4;
        public const int DATAINDEX_CONTRACTFAXNO        = 5;
        public const int DATAINDEX_SUPPLIERADDRESS      = 6;
        public const int DATAINDEX_SUPPLIERTELNO        = 7;
        public const int DATAINDEX_SUPPLIERFAXNO        = 8;
        public const int DATAINDEX_INVOICEADDRESS       = 9;
        public const int DATAINDEX_INVOICETELNO         = 10;
        public const int DATAINDEX_INVOICEFAXNO         = 11;
        public const int DATAINDEX_DISCOUNTDESC         = 12;
        public const int DATAINDEX_DISCOUNTVAL          = 13;
        public const int DATAINDEX_CONTRACTDETAILS      = 14;
        public const int DATAINDEX_ORDMESSAGE           = 15;
        public const int DATAINDEX_NOTES                = 18;
        public const int DATAINDEX_DESCRIPTION          = 20;
        public const int DATAINDEX_PHARMACYSTOCKHOLDING = 21;
        public const int DATAINDEX_PRINTTRADENAME       = 22;
        public const int DATAINDEX_PRINTNSVCODE         = 23;
        public const int DATAINDEX_METHOD               = 25;
        public const int DATAINDEX_COSTCENTRE           = 26;
        public const int DATAINDEX_PRINTDELIVERYNOTE    = 31;
        public const int DATAINDEX_INUSE                = 36;
        public const int DATAINDEX_ONCOST               = 37;
        public const int DATAINDEX_MINIMUMORDERVALUE    = 40;
        public const int DATAINDEX_LEADTIME             = 41;
        public const int DATAINDEX_PSOSUPPLIER          = 42;
        public const int DATAINDEX_NATIONALSUPPLIERCODE = 45;
        public const int DATAINDEX_USERFIELD1           = 46; 
        public const int DATAINDEX_USERFIELD2           = 47; 
        public const int DATAINDEX_USERFIELD3           = 16;
        public const int DATAINDEX_USERFIELD4           = 17;
        public const int DATAINDEX_DUNSREFERENCE        = 48; 
        #endregion

        #region View Indexes
        public const int VIEWINDEX_ADD_EXTERNALSUPPLIER = 1;
        public const int VIEWINDEX_ADD_OTHERSITE        = 2;
        public const int VIEWINDEX_EDITOR               = 3;
        public const int VIEWINDEX_ADD_INTERNALSUPPLIER = 4;
        #endregion

        #region Public Properties
        public WSupplier2 Suppliers { get; private set; }
        #endregion

        #region Constuctor
        public WSupplier2Accessor() : base(null) { }
    
        public WSupplier2Accessor(WSupplier2 suppliers, IEnumerable<int> siteIDs) : base(siteIDs)
        {
            this.Suppliers = suppliers;
            this.SiteIDs   = siteIDs.Where(s => suppliers.Any(p => p.SiteID == s)).ToList();
        }
        #endregion

        #region Overridden Methods
        /// <summary>Returns a list of data field indexes whose values must be filled in by user</summary>
        public override HashSet<int> GetRequiredDataIndexes(QSView qsView)
        {
            HashSet<int> requiredIndexs = new HashSet<int>();
            requiredIndexs.Add(DATAINDEX_CODE               );
            requiredIndexs.Add(DATAINDEX_FULLNAME           );
            requiredIndexs.Add(DATAINDEX_DESCRIPTION        );
            requiredIndexs.Add(DATAINDEX_PRINTTRADENAME     );
            requiredIndexs.Add(DATAINDEX_PRINTNSVCODE       );
            requiredIndexs.Add(DATAINDEX_METHOD             );
            requiredIndexs.Add(DATAINDEX_PSOSUPPLIER        );
            return requiredIndexs;
        }

        /// <summary>Called to update qsView with all the values (from processor data)</summary>
        public override void PopulateForEditor(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                WSupplier2Row row = Suppliers.FirstOrDefault(s => s.SiteID == siteID);

                foreach(var qsDataInputItem in qsView)
                    qsDataInputItem.SetValueBySiteID(siteID, this.GetValueForEditor(row, qsDataInputItem.index));
            }
        }

        /// <summary>Returns mapped data index value as string</summary>
        public string GetValueForEditor(WSupplier2Row row, int index)
        {
            try
            {
                switch (index)
                {
                case DATAINDEX_CODE:                return row.Code;
                case DATAINDEX_FULLNAME:            return row.FullName;
                case DATAINDEX_CONTRACTADDRESS:     return row.ContractAddress;
                case DATAINDEX_CONTRACTTELNO:       return row.ContractTelNo;
                case DATAINDEX_CONTRACTFAXNO:       return row.ContractFaxNo;
                case DATAINDEX_SUPPLIERADDRESS:     return row.SupplierAddress;
                case DATAINDEX_SUPPLIERTELNO:       return row.SupplierTelNo;
                case DATAINDEX_SUPPLIERFAXNO:       return row.SupplierFaxNo;
                case DATAINDEX_INVOICEADDRESS:      return row.InvoiceAddress;
                case DATAINDEX_INVOICETELNO:        return row.InvoiceTelNo;
                case DATAINDEX_INVOICEFAXNO:        return row.InvoiceFaxNo;
                case DATAINDEX_DISCOUNTDESC:        return row.DiscountDesc ?? string.Empty;    
                case DATAINDEX_DISCOUNTVAL:         return row.DiscountVal  ?? string.Empty;
                case DATAINDEX_ORDMESSAGE:          return row.OrdMessage   ?? string.Empty;
                case DATAINDEX_DESCRIPTION:         return row.Description; 
                case DATAINDEX_PHARMACYSTOCKHOLDING:return row.LocationID_PharmacyStockholding == null ? string.Empty : row.GetPharmacyStockholdingNumber().Value.ToString("000");
                case DATAINDEX_PRINTTRADENAME:      return row.PrintTradeName.ToYNString();
                case DATAINDEX_PRINTNSVCODE:        return row.PrintNSVCode.ToYNString();
                case DATAINDEX_METHOD:              return row.Method == SupplierMethod.Direct ? "P" : row.RawRow["Method"].ToString();
                case DATAINDEX_COSTCENTRE:          return row.CostCentre   ?? string.Empty;
                case DATAINDEX_INUSE:               return row.InUse.ToYNString();
                case DATAINDEX_ONCOST:              return row.OnCost;
                case DATAINDEX_MINIMUMORDERVALUE:   return row.MinimumOrderValue == null ? string.Empty : row.MinimumOrderValue.Value.ToString("0.00");
                case DATAINDEX_LEADTIME:            return row.LeadTime ?? string.Empty;
                case DATAINDEX_PSOSUPPLIER:         return row.PSOSupplier.ToYNString();
                case DATAINDEX_NATIONALSUPPLIERCODE:return row.NationalSupplierCode;
                case DATAINDEX_DUNSREFERENCE:  return row.DUNSReference;
                case DATAINDEX_USERFIELD1:          return row.UserField1;
                case DATAINDEX_USERFIELD2:          return row.UserField2;
                case DATAINDEX_USERFIELD3:          return row.UserField3;
                case DATAINDEX_USERFIELD4:          return row.UserField4;
                case DATAINDEX_PRINTDELIVERYNOTE: return row.PrintDeliveryNote.ToYNString();
                }
            }
            catch(Exception)
            {
            }

            return string.Empty;
        }

        /// <summary>Used to as QS lookup handlers</summary>
        public override void SetLookupItem(QSView qsView) 
        {   
            foreach(int siteID in this.SiteIDs)
            {
                if (qsView.ContainsDataIndex(DATAINDEX_PHARMACYSTOCKHOLDING))
                    qsView.FindByDataIndex(DATAINDEX_PHARMACYSTOCKHOLDING).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Site&Info=Select a site&sp=pSiteForLookupList&Params=&Columns=Site Number,98&selectedDBID={{currentValue}}&SearchType=TypeAndSelect&SearchColumns=0&SearchText={{typedText}}", SessionInfo.SessionID, siteID);
                    //qsView.FindByDataIndex(DATAINDEX_PHARMACYSTOCKHOLDING).SetLookupMap(siteID, @"pharmacysharedscripts\PharmacyLookupList.aspx?SessionID={0}&SiteID={1}&Title=Site&Info=Select a site&sp=pSiteForLookupList&Params=&Columns=Site Number,98&selectedDBID={{currentValue}}", SessionInfo.SessionID, siteID); 3Mar16 XN 99381
            }
        }

        /// <summary>Called to validate the web controls in QSView</summary>
        /// <returns>Returns list of validation error or warnings</returns>
        public override QSValidationList Validate(QSView qsView)
        {
            QSValidationList validationInfo = new QSValidationList();
            WSupplier2ColumnInfo columnInfo = WSupplier2.GetColumnInfo();
            HashSet<int> required = this.GetRequiredDataIndexes(qsView);

            foreach (var siteID in SiteIDs)
            {
                WSupplier2Row row = Suppliers.FindBySiteID(siteID).FirstOrDefault();
                if (row == null)
                    continue;

                bool addMode = (row.RawRow.RowState == System.Data.DataRowState.Added);

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
                        // ****** Should uncomment 2 lines below on merge down but all check below check if item is required anyway
                        //if (item.ForceMandatory && string.IsNullOrWhiteSpace(value))
                        //    validationInfo.AddError(siteID, "Please enter " + item.description + " value");

                        switch(item.index)
                        {
                        case DATAINDEX_CODE: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.CodeLength), out error))
                                validationInfo.AddError(siteID, error);
                            else if ((addMode || value != row.Code) && !WSupplier2.IsCodeUnique(value, siteID))    // originally used WSupplier so code was unique against all suppliers
                                validationInfo.AddError(siteID, "Code " + row.Code + " already exists");
                            break;
                        case DATAINDEX_FULLNAME: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.FullNameLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_CONTRACTADDRESS:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.ContractAddressLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_CONTRACTTELNO:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.ContractTelNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_CONTRACTFAXNO:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.ContractFaxNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_SUPPLIERADDRESS:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.SupplierAddressLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_SUPPLIERTELNO:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.SupplierTelNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_SUPPLIERFAXNO:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.SupplierFaxNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_INVOICEADDRESS: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.InvoiceAddressLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_INVOICETELNO:   
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.InvoiceTelNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_INVOICEFAXNO:   
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.InvoiceFaxNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_DISCOUNTDESC:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DiscountDescLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_DISCOUNTVAL:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DiscountValLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_ORDMESSAGE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.OrdMessageLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_DESCRIPTION: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DescriptionLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PRINTTRADENAME:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PRINTNSVCODE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_METHOD:            
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), item.maxLength, out error))
                                validationInfo.AddError(siteID, error);
                            else 
                            {
                                var newValue = value.EqualsNoCaseTrimEnd("P") ? SupplierMethod.Direct : EnumDBCodeAttribute.DBCodeToEnum<SupplierMethod>(value);  // 6Feb14 XN 110710 P type stored as D in DB
                                if (row.Method != newValue)    
                                {
                                    // Test if there are any outstanding orders 5nov14 XN
                                    WOrder orders = new WOrder();
                                    string outstandingOrderStates = WConfiguration.Load(siteID, "D|WSupplier2", "Validation", "MethodOutstandingOrderStates", string.Empty, false);
                                    if (!string.IsNullOrEmpty(outstandingOrderStates))
                                        orders.LoadBySiteIDSupCodeAndState(siteID, row.Code, outstandingOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());

                                    WReconcil reconcil = new WReconcil();
                                    string reconcilOrderStates = WConfiguration.Load(siteID, "D|WSupplier2", "Validation", "MethodReconcilOrderStates", string.Empty, false);
                                    if (!string.IsNullOrEmpty(reconcilOrderStates))
                                        reconcil.LoadBySiteIDSupCodeAndState(siteID, row.Code, reconcilOrderStates.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<OrderStatusType>(c.ToString())).ToArray());

                                    if (orders.Any() || reconcil.Any())
                                        validationInfo.AddError(siteID, "Order output type: Can't change as outstanding orders/credit notes");
                                }
                            }
                            break;
                        case DATAINDEX_COSTCENTRE:        
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.CostCentreLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_INUSE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_ONCOST:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.OnCostLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_MINIMUMORDERVALUE: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(double), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_LEADTIME:          
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.LeadTimeLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PSOSUPPLIER:       
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            else
                            {
                                int? locationID = row.LocationID_PharmacyStockholding;
                                if (qsView.ContainsDataIndex(DATAINDEX_PHARMACYSTOCKHOLDING))
                                    locationID = qsView.GetValueByDataIndexAndSiteID<int>(DATAINDEX_PHARMACYSTOCKHOLDING, siteID);

                                SupplierMethod method = row.Method;
                                if (qsView.ContainsDataIndex(DATAINDEX_METHOD))
                                    method = EnumDBCodeAttribute.DBCodeToEnum<SupplierMethod>(qsView.GetValueByDataIndexAndSiteID(DATAINDEX_METHOD, siteID));

                                bool PSO = BoolExtensions.PharmacyParseOrNull(value) ?? false;
                   
                                if (PSO && locationID != null)
                                {
                                    validationInfo.AddWarning(siteID, "PSO only supported for exteneral suppliers and will be set off\nChange supplier type to enable PSO");
                                    qsView.FindByDataIndex(DATAINDEX_PSOSUPPLIER).SetValueBySiteID(siteID, "N");
                                }
                                else if (PSO && method == SupplierMethod.EDI)
                                {
                                    validationInfo.AddWarning(siteID, "PSO not supported for EDI ordering and will be set off\nChange order method to enable PSO");
                                    qsView.FindByDataIndex(DATAINDEX_PSOSUPPLIER).SetValueBySiteID(siteID, "N");
                                }
                                else if (!PSO && method == SupplierMethod.HUB)
                                {
                                    validationInfo.AddWarning(siteID, "HUB ordering requires PSO to be enabled.");
                                    qsView.FindByDataIndex(DATAINDEX_PSOSUPPLIER).SetValueBySiteID(siteID, "Y");
                                }
                            }
                            break;
                        case DATAINDEX_NATIONALSUPPLIERCODE:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.NationalSupplierCodeLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_DUNSREFERENCE:  
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DUNSReferenceLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_USERFIELD1:        
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.UserField1Length), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_USERFIELD2:        
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.UserField2Length), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PRINTDELIVERYNOTE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        }
                    }
                    catch (Exception ex)
                    {
                        validationInfo.AddError(siteID, "Failed validating {0}\n{1}", item.description, ex.GetAllMessaages().ToCSVString("\n"));
                    }
                }
            }

            return validationInfo;
        }

        /// <summary>Called to get difference between QS data and (original) process data</summary>
        public override QSDifferencesList GetDifferences(QSView qsView)
        {
            QSDifferencesList differences = new QSDifferencesList();
            foreach (int siteID in this.SiteIDs)
            {
                WSupplier2Row row = this.Suppliers.FindBySiteID(siteID).FirstOrDefault();

                foreach (QSDataInputItem item in qsView)
                {
                    if (item.Enabled)
                    {
                        QSDifference? difference = item.CompareValues(siteID, this.GetValueForEditor(row, item.index));
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
            foreach (int siteID in this.SiteIDs)
            {
                WSupplier2Row row = this.Suppliers.FindBySiteID(siteID).FirstOrDefault();
                if (row == null)
                    continue;

                foreach (QSDataInputItem item in qsView)
                {
                    if (!item.Enabled || item.CompareValues(siteID, GetValueForEditor(row, item.index)) == null)
                        continue;

                    string value = item.GetValueBySiteID(siteID);
                    switch(item.index)
                    {
                    case DATAINDEX_CODE:                row.Code                = value; break;
                    case DATAINDEX_FULLNAME:            row.FullName            = value; break;
                    case DATAINDEX_CONTRACTADDRESS:     row.ContractAddress     = value; break;
                    case DATAINDEX_CONTRACTTELNO:       row.ContractTelNo       = value; break;
                    case DATAINDEX_CONTRACTFAXNO:       row.ContractFaxNo       = value; break;    
                    case DATAINDEX_SUPPLIERADDRESS:     row.SupplierAddress     = value; break;    
                    case DATAINDEX_SUPPLIERTELNO:       row.SupplierTelNo       = value; break;    
                    case DATAINDEX_SUPPLIERFAXNO:       row.SupplierFaxNo       = value; break;    
                    case DATAINDEX_INVOICEADDRESS:      row.InvoiceAddress      = value; break;    
                    case DATAINDEX_INVOICETELNO:        row.InvoiceTelNo        = value; break;    
                    case DATAINDEX_INVOICEFAXNO:        row.InvoiceFaxNo        = value; break;    
                    case DATAINDEX_DISCOUNTDESC:        row.DiscountDesc        = value; break;    
                    case DATAINDEX_DISCOUNTVAL:         row.DiscountVal         = value; break;    
                    case DATAINDEX_ORDMESSAGE:          row.OrdMessage          = value; break;        
                    case DATAINDEX_DESCRIPTION:         row.Description         = value; break;
                    case DATAINDEX_PHARMACYSTOCKHOLDING:row.LocationID_PharmacyStockholding = Sites.GetSiteIDByNumber(int.Parse(value)); 
                                                        row.Type = (row.LocationID_PharmacyStockholding == null ? SupplierType.External : SupplierType.Stores);
                                                        break;
                    case DATAINDEX_PRINTTRADENAME:      row.PrintTradeName      = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_PRINTNSVCODE:        row.PrintNSVCode        = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_METHOD:              row.RawRow["Method"]    = value.Replace("P", "D"); break;   // 6Feb15 XN 110710 P type stored as D type in DB
                    case DATAINDEX_COSTCENTRE:          row.CostCentre          = value; break;
                    case DATAINDEX_INUSE:               row.InUse               = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_ONCOST:              row.OnCost              = value; break;
                    case DATAINDEX_MINIMUMORDERVALUE:   row.MinimumOrderValue   = string.IsNullOrWhiteSpace(value) ? (double?)null : double.Parse(value); break;
                    case DATAINDEX_LEADTIME:            row.LeadTime            = value; break;
                    case DATAINDEX_PSOSUPPLIER:         row.PSOSupplier         = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_NATIONALSUPPLIERCODE:row.NationalSupplierCode= value; break;
                    case DATAINDEX_DUNSREFERENCE:  row.DUNSReference       = value; break;
                    case DATAINDEX_USERFIELD1:          row.UserField1          = value; break;
                    case DATAINDEX_USERFIELD2:          row.UserField2          = value; break;
                    case DATAINDEX_USERFIELD3:          row.UserField3          = value; break;
                    case DATAINDEX_USERFIELD4:          row.UserField4          = value; break;
                    case DATAINDEX_PRINTDELIVERYNOTE:   row.PrintDeliveryNote = BoolExtensions.PharmacyParse(value); break;
                   
                    }
                }
            }

            // Save
            if (saveToDB)
                this.Suppliers.Save();
        }
                
        /// <summary>Called when QS data time button is clicked</summary>
        /// <param name="qsView">QueScrl controls</param>
        /// <param name="index">Index of the button clicked</param>
        /// <param name="siteID">site ID</param>
        override public void ButtonClickEvent(QSView qsView, int index, int siteID)
        { 
            switch (index)
            {
            case DATAINDEX_NOTES:   // note editor
                {
                WebControl button = qsView.FindByDataIndex(index).GetBySiteID(siteID);
                string script = string.Format("var res=window.showModalDialog('Notes.aspx?SessionID={0}&WSupplier2ID={1}', '', 'status:off; center:Yes;'); if (res == 'logoutFromActivityTimeout'){res = null; window.close(); window.parent.close();window.parent.ICWWindow().Exit();}", SessionInfo.SessionID, this.Suppliers.FindBySiteID(siteID).First().WSupplier2ID); 
                script = "setTimeout(function() { " + script + "}, 200)";   // Use timer to allow form behind to size correct or goes bit funny 85845 XN 07Mar14 
                ScriptManager.RegisterStartupScript(button, button.GetType(), "Notes", script, true);
                }
                break;
            case DATAINDEX_CONTRACTDETAILS: // Contract detials
                {
                WebControl button = qsView.FindByDataIndex(index).GetBySiteID(siteID);
                string script = string.Format("var res=window.showModalDialog('ContractDetails.aspx?SessionID={0}&WSupplier2ID={1}', '', 'status:off; center:Yes; if (res == 'logoutFromActivityTimeout') {res = null; window.close(); window.parent.close();window.parent.ICWWindow().Exit();}');", SessionInfo.SessionID, this.Suppliers.FindBySiteID(siteID).First().WSupplier2ID); 
                script = "setTimeout(function() { " + script + "}, 200)";   // Use timer to allow form behind to size correct or goes bit funny 85845 XN 07Mar14 
                ScriptManager.RegisterStartupScript(button, button.GetType(), "ContractDetails", script, true);
                }
                break;
            }
        }

        /// <summary>Writes object data to XML writer</summary>
        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            this.Suppliers.WriteXml(writer);
        }

        /// <summary>Reads object data from XML reader</summary>
        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            this.Suppliers = new WSupplier2();
            this.Suppliers.ReadXml(reader);
        }
        #endregion
    }
}
