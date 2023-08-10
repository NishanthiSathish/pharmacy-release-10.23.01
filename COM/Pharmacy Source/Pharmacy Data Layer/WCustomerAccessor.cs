//===========================================================================
//
//							    WCustomerAccessor.cs
//
//  Maps the fields in WCustomer to QuesScrl data indexes stores in WConfiguration
//  
//	Modification History:
//	16Jun14 XN  Written
//  08May15 XN  Removed PrintDeliveryNote, and PrintPickTicket
//  12May17 KR  Bug 183869 : Unable to Print Delivery Notes [10.15.02]
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using System.Web.UI;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Maps the fields in WProduct to QuesScrl data indexes stores in WConfiguration</summary>
    public class WCustomerAccessor : QSBaseProcessor
    {
        #region Data Indexes
        public const int DATAINDEX_CODE                 = 1;
        public const int DATAINDEX_FULLNAME             = 2;
        public const int DATAINDEX_ADDRESS              = 6;
        public const int DATAINDEX_TELEPHONENO          = 7;
        public const int DATAINDEX_FAXNO                = 8;
        public const int DATAINDEX_USERFIELD3           = 16;   // Old WExtraSupplierData.ContactName1 field
        public const int DATAINDEX_USERFIELD4           = 17;   // Old WExtraSupplierData.ContactName2 field
        public const int DATAINDEX_NOTES                = 18;
        public const int DATAINDEX_DESCRIPTION          = 20;
        public const int DATAINDEX_COSTCENTRE           = 26;
        public const int DATAINDEX_PRINTPICKINGTICKET   = 30;  //13Apr17 TH Reinstated
        public const int DATAINDEX_PRINTDELIVERYNOTE    = 31;  //13Apr17 TH Reinstated
        public const int DATAINDEX_TOPUPLEVEL           = 33;  //17Jul17 TH Reinstater (TFS 184566)
        public const int DATAINDEX_INUSE                = 36;
        public const int DATAINDEX_ONCOST               = 37;
        public const int DATAINDEX_INPATIENTDIRECTIONS  = 38;
        public const int DATAINDEX_ADHOCDELNOTE         = 39;
        public const int DATAINDEX_ISCUSTOMER           = 40;
        public const int DATAINDEX_USERFIELD1           = 46;
        public const int DATAINDEX_USERFIELD2           = 47;
        public const int DATAINDEX_GLOBALLOCATIONNUMBER = 48;
        #endregion

        #region Public Properties
        public WCustomer Customers { get; private set; }
        #endregion

        #region Constuctor
        public WCustomerAccessor() : base(null) { }
    
        public WCustomerAccessor(WCustomer customers, IEnumerable<int> siteIDs) : base(siteIDs)
        {
            this.Customers = customers;
            this.SiteIDs   = siteIDs.Where(s => customers.Any(p => p.SiteID == s)).ToList();
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
            requiredIndexs.Add(DATAINDEX_ISCUSTOMER         );
            requiredIndexs.Add(DATAINDEX_INUSE              );
            return requiredIndexs;
        }

        /// <summary>Called to update qsView with all the values (from processor data)</summary>
        public override void PopulateForEditor(QSView qsView)
        {
            foreach(int siteID in this.SiteIDs)
            {
                WCustomerRow row = Customers.FirstOrDefault(s => s.SiteID == siteID);

                foreach(var qsDataInputItem in qsView)
                    qsDataInputItem.SetValueBySiteID(siteID, this.GetValueForEditor(row, qsDataInputItem.index));
            }
        }

        /// <summary>Returns mapped data index value as string</summary>
        public string GetValueForEditor(WCustomerRow row, int index)
        {
            try
            {
                switch (index)
                {
                case DATAINDEX_CODE:                return row.Code;
                case DATAINDEX_FULLNAME:            return row.FullName;
                case DATAINDEX_ADDRESS:             return row.Address;
                case DATAINDEX_TELEPHONENO:         return row.TelephoneNo;
                case DATAINDEX_FAXNO:               return row.FaxNo;
                case DATAINDEX_DESCRIPTION:         return row.Description;
                case DATAINDEX_COSTCENTRE:          return row.CostCentre;
                case DATAINDEX_INUSE:               return row.InUse.ToYNString();
                case DATAINDEX_ONCOST:              return row.OnCost;
                case DATAINDEX_INPATIENTDIRECTIONS: return row.InPatientDirections.ToYNString();
                case DATAINDEX_ADHOCDELNOTE:        return row.AdHocDelNote.ToYNString();
                case DATAINDEX_ISCUSTOMER:          return row.IsCustomer.ToYNString();
                case DATAINDEX_USERFIELD1:          return row.UserField1;
                case DATAINDEX_USERFIELD2:          return row.UserField2;
                case DATAINDEX_USERFIELD3:          return row.UserField3;  // Old WExtraSupplierData.ContactName1 field
                case DATAINDEX_USERFIELD4:          return row.UserField4;  // Old WExtraSupplierData.ContactName2 field
                case DATAINDEX_TOPUPLEVEL:          return row.TopUpLevel;  //17Jul17 TH reinstated (TFS 184566)
                case DATAINDEX_GLOBALLOCATIONNUMBER:return row.GlobalLocationNumber;
                case DATAINDEX_PRINTDELIVERYNOTE:   return row.PrintDeliveryNote.ToYNString();  //13Apr17 TH Reinstated
                case DATAINDEX_PRINTPICKINGTICKET:  return row.PrintPickTicket.ToYNString();   //13Apr17 TH Reinstated
                }
            }
            catch(Exception)
            {
            }

            return string.Empty;
        }

        /// <summary>Used to as QS lookup handlers</summary>
        public override void SetLookupItem(QSView qsView) { }

        /// <summary>Called to validate the web controls in QSView</summary>
        /// <returns>Returns list of validation error or warnings</returns>
        public override QSValidationList Validate(QSView qsView)
        {
            QSValidationList validationInfo = new QSValidationList();
            WCustomerColumnInfo columnInfo = WCustomer.GetColumnInfo();
            HashSet<int> required = this.GetRequiredDataIndexes(qsView);

            foreach (var siteID in SiteIDs)
            {
                WCustomerRow row = Customers.FindBySiteID(siteID).FirstOrDefault();
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
                        // ****** Should uncomment 2 lines below on merge down but all check below check if item is required anyway
                        //if (item.ForceMandatory && string.IsNullOrWhiteSpace(value))
                        //    validationInfo.AddError(siteID, "Please enter " + item.description + " value");

                        switch(item.index)
                        {
                        case DATAINDEX_CODE: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.CodeLength), out error))
                                validationInfo.AddError(siteID, error);
                            else if (value != row.Code && !WCustomer.IsCodeUnique(value, siteID))    // originally used WSupplier so code was unique against all suppliers, and customers
                                validationInfo.AddError(siteID, "Code " + row.Code + " already exists");
                            break;
                        case DATAINDEX_FULLNAME: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.FullNameLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_ADDRESS: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.AddressLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_TELEPHONENO: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.TelephoneNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_FAXNO: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.FaxNoLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_DESCRIPTION: 
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.DescriptionLength), out error))
                                validationInfo.AddError(siteID, error);
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
                        case DATAINDEX_INPATIENTDIRECTIONS:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_ADHOCDELNOTE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_ISCUSTOMER:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
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
                        case DATAINDEX_USERFIELD3:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.UserField3Length), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_USERFIELD4:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.UserField4Length), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_TOPUPLEVEL:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.TopUpLevelLength), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_GLOBALLOCATIONNUMBER:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(string), required.Contains(item.index), Math.Min(item.maxLength, columnInfo.GlobalLocationNumber), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PRINTDELIVERYNOTE:
                            if (!Validation.ValidateText(webCtrl, item.description, typeof(bool), required.Contains(item.index), out error))
                                validationInfo.AddError(siteID, error);
                            break;
                        case DATAINDEX_PRINTPICKINGTICKET:
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
                WCustomerRow customerRow = this.Customers.FirstOrDefault(s => s.SiteID == siteID);

                foreach (QSDataInputItem item in qsView)
                {
                    if (item.Enabled)
                    {
                        QSDifference? difference = item.CompareValues(siteID, this.GetValueForEditor(customerRow, item.index));
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
                WCustomerRow row = this.Customers.FirstOrDefault(s => s.SiteID == siteID);
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
                    case DATAINDEX_ADDRESS:             row.Address             = value; break;
                    case DATAINDEX_TELEPHONENO:         row.TelephoneNo         = value; break;
                    case DATAINDEX_FAXNO:               row.FaxNo               = value; break;
                    case DATAINDEX_DESCRIPTION:         row.Description         = value; break;
                    case DATAINDEX_COSTCENTRE:          row.CostCentre          = value; break;
                    case DATAINDEX_INUSE:               row.InUse               = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_ONCOST:              row.OnCost              = value; break;
                    case DATAINDEX_INPATIENTDIRECTIONS: row.InPatientDirections = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_ADHOCDELNOTE:        row.AdHocDelNote        = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_ISCUSTOMER:          row.IsCustomer          = BoolExtensions.PharmacyParse(value); break;
                    case DATAINDEX_USERFIELD1:          row.UserField1          = value; break;
                    case DATAINDEX_USERFIELD2:          row.UserField2          = value; break;
                    case DATAINDEX_USERFIELD3:          row.UserField3          = value; break;
                    case DATAINDEX_USERFIELD4:          row.UserField4          = value; break;
                    case DATAINDEX_TOPUPLEVEL:          row.TopUpLevel          = value; break;
                    case DATAINDEX_GLOBALLOCATIONNUMBER:row.GlobalLocationNumber= value; break;
                    case DATAINDEX_PRINTDELIVERYNOTE:   row.PrintDeliveryNote = BoolExtensions.PharmacyParse(value); break;  //13Apr17 TH Added
                    case DATAINDEX_PRINTPICKINGTICKET:  row.PrintPickTicket = BoolExtensions.PharmacyParse(value); break;    //13Apr17 TH Added
                    }
                }
            }

            // Save
            if (saveToDB)
                this.Customers.Save();
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
                WebControl button = qsView.FindByDataIndex(index).GetBySiteID(siteID);
                string script = string.Format("var res=window.showModalDialog('Notes.aspx?SessionID={0}&WCustomerID={1}', '', 'status:off; center:Yes;if (res == 'logoutFromActivityTimeout') {res = null; window.close(); window.parent.close();window.parent.ICWWindow().Exit();}');", SessionInfo.SessionID, this.Customers.FindBySiteID(siteID).First().WCustomerID); 
                script = "setTimeout(function() { " + script + "}, 200);";   // Use timer to allow form behind to size correct or goes bit funny 85845 XN 07Mar14 
                ScriptManager.RegisterStartupScript(button, button.GetType(), "Notes", script, true);
                break;
            }
        }

        /// <summary>Writes object data to XML writer</summary>
        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            this.Customers.WriteXml(writer);
        }

        /// <summary>Reads object data from XML reader</summary>
        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            this.Customers = new WCustomer();
            this.Customers.ReadXml(reader);
        }
        #endregion
    }
}
