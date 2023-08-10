//===========================================================================
//
//							        WCustomer.cs
//
//  Provides access to WCustomer table (holds pharmacy details about wards)
//  This replaces the WSupplier table for SupplierType = 'W'
//
//  SPs for this object should return all fields from WCustomer,
//  and a links in the following extra field
//      Ward_Out_Of_Use which comes from ward.out_of_use
//      Ward_Deleted which comes from location._deleted 
//
//  Only supports reading, updating, and inserting from table.
//  New customers will be saved to Worderlog as C types
//  Any changes will be automatically saved to the PharmacyLog under "WCustomer"
//  
//	Modification History:
//	16Jun14 XN  Written
//	31Oct14 XN  Written 102842 Added ToNameString
//  11Nov14 XN  Added ToXMLHeap, update Save to save to interface file 43318
//  19Nov14 XN  set default AdHocDelNote, and InPatientDirection to false 104304
//  31Dec14 XN  Added Ward_InUse 69194
//  20Jan15 XN  Update Save to use new WPharmacyLogType 26734
//  24Feb15 XN  Marked WCustomer.PrintDeliveryNote, and WCustomer.PrintPickTicket as Obsolete
//  08May15 XN  Removed PrintDeliveryNote, and PrintPickTicket
//  14Apr16 XN  Updated LoadBySiteAndCode with append, Save for PharmacyInterface changes, added FindBySiteAndCode 123082
//  17Aug16 XN  160443 Updated ParseXML with missing parameters
//  12/0517 KR  Bug 183869 : Unable to Print Delivery Notes [10.15.02]
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class WCustomerRow : BaseRow
    {
		public int WCustomerID 
        { 
            get { return FieldToInt(RawRow["WCustomerID"]).Value; } 
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; } 
            set { RawRow["SiteID"] = IntToField(value);      } 
        }

        public string Code
        {
            get { return FieldToStr(RawRow["Code"], true, string.Empty);  } 
            set { RawRow["Code"] = StrToField(value);                     } 
        }

        /// <summary>was originally the short name</summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); } 
            set { RawRow["Description"] = StrToField(value);                    } 
        }

        public string FullName
        {
            get { return FieldToStr(RawRow["FullName"], true, string.Empty);} 
            set { RawRow["FullName"] = StrToField(value);                   } 
        }

        public string Address
        {
            get { return FieldToStr(RawRow["Address"], true, string.Empty); } 
            set { RawRow["Address"] = StrToField(value);                    } 
        }

        public string TelephoneNo
        {
            get { return FieldToStr(RawRow["TelephoneNo"], true, string.Empty); } 
            set { RawRow["TelephoneNo"] = StrToField(value);                    } 
        }

        public string FaxNo
        {
            get { return FieldToStr(RawRow["FaxNo"], true, string.Empty); } 
            set { RawRow["FaxNo"] = StrToField(value);                    } 
        }

        public string CostCentre
        {
            get { return FieldToStr(RawRow["CostCentre"], true, string.Empty); } 
            set { RawRow["CostCentre"] = StrToField(value);                    } 
        }

        public bool? InPatientDirections
        {
            get { return FieldToBoolean(RawRow["InPatientDirections"]);  } 
            set { RawRow["InPatientDirections"] = BooleanToField(value); } 
        }

        public string OnCost
        {
            get { return FieldToStr(RawRow["OnCost"], false, string.Empty); } 
            set { RawRow["OnCost"] = StrToField(value);                    } 
        }

        public bool? AdHocDelNote
        {
            get { return FieldToBoolean(RawRow["AdHocDelNote"]);  } 
            set { RawRow["AdHocDelNote"] = BooleanToField(value); } 
        }

        public string GlobalLocationNumber
        {
            get { return FieldToStr(RawRow["GlobalLocationNumber"], true, string.Empty); } 
            set { RawRow["GlobalLocationNumber"] = StrToField(value);                    } 
        }

        public bool IsCustomer
        {
            get { return FieldToBoolean(RawRow["IsCustomer"]).Value;  } 
            set { RawRow["IsCustomer"] = BooleanToField(value);       } 
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value;  } 
            set { RawRow["InUse"] = BooleanToField(value);       } 
        }

        /// <summary>
        /// 0 if (Ward.Out_Of_Use or Ward._Deleted) set 
        /// null if no associated ward
        /// </summary>
        public bool? Ward_InUse
        {
            get 
            { 
                if (FieldToBoolean(RawRow["Ward_Out_Of_Use"]) == null || FieldToBoolean(RawRow["Ward_Deleted"]) == null)
                    return null;
                else if (FieldToBoolean(RawRow["Ward_Out_Of_Use"]) == true || FieldToBoolean(RawRow["Ward_Deleted"]) == true)
                    return false;
                else
                    return true;
            } 
        }

        // Porbably not needed
        public int SessionLock
        {
            get { return FieldToInt(RawRow["SessionLock"]).Value;  } 
            set { RawRow["SessionLock"] = IntToField(value);       } 
        }

        public string UserField1
        {
            get { return FieldToStr(RawRow["UserField1"], false, string.Empty); } 
            set { RawRow["UserField1"] = StrToField(value);                     } 
        }

        public string UserField2
        {
            get { return FieldToStr(RawRow["UserField2"], false, string.Empty); } 
            set { RawRow["UserField2"] = StrToField(value);                     } 
        }

        /// <summary>Use to be WExtraSupplierData.ContactName1</summary>
        public string UserField3
        {
            get { return FieldToStr(RawRow["UserField3"], true, string.Empty); } 
            set { RawRow["UserField3"] = StrToField(value);                     } 
        }

        /// <summary>Use to be WExtraSupplierData.ContactName2</summary>
        public string UserField4
        {
            get { return FieldToStr(RawRow["UserField4"], true, string.Empty); } 
            set { RawRow["UserField4"] = StrToField(value);                     } 
        }

        /// <summary>Should Requisitions from this ward print a Delivery Note</summary>
        public bool? PrintDeliveryNote
        {
            get { return FieldToBoolean(RawRow["PrintDeliveryNote"]); }
            set { RawRow["PrintDeliveryNote"] = BooleanToField(value); }
        }

        /// <summary>Should Requisitions from this ward print a Picking Ticket</summary>
        public bool? PrintPickTicket
        {
            get { return FieldToBoolean(RawRow["PrintPickTicket"]); }
            set { RawRow["PrintPickTicket"] = BooleanToField(value); }
        }

        /// <summary>WardTopUp interval used to calculate Issue</summary>
        public string TopUpLevel
        {
            get { return FieldToStr(RawRow["TopUpLevel"], true, string.Empty); }
            set { RawRow["TopUpLevel"] = StrToField(value); }
        }
        /// <summary>Returns Code - Description</summary>
        public override string ToString()
        {
            return string.Format("{0} - {1}", this.Code, this.Description);
        }

        /// <summary>
        /// Returns customer name (and address)
        /// SupplierNameType.ShortAndLongName
        ///     Description
        /// SupplierNameType.FullName
        ///     FullName\Description, Address
        /// SupplierNameType.Short
        ///     Description, Address
        ///     
        /// 31Oct14 XN  102842
        /// </summary>
        public string ToNameString(SupplierNameType supplierNameDisplayType)
        {
            switch (supplierNameDisplayType)
            {
            case SupplierNameType.ShortAndLongName : 
                return this.Description;    // This is correct as long name is then normally displayed separately (so could do with improvement)
            case SupplierNameType.FullName : 
                string name =  StringExtensions.IsNullOrEmptyAfterTrim(this.FullName) ? this.Description : this.FullName;
                return this.AppendNameAddess(name, this.Address); 
            default: 
                return this.AppendNameAddess(this.Description, this.Address);
            }
        }

        /// <summary>
        /// Creates an XML heap for a supplier 43318
        /// Replaces vb6 SupPatME.BAS method FillHeapSupplierInfo 
        /// </summary>
        public string ToXMLHeap()
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
                xmlWriter.WriteAttributeString("sCode",       this.Code);
                xmlWriter.WriteAttributeString("sCodeXML",    this.Code.XMLEscape());                                   // 17Aug16 XN 160443 Added 
                xmlWriter.WriteAttributeString("SiteNumber",  Site2.GetSiteNumberByID(this.SiteID).ToString("000"));    // 17Aug16 XN 160443 Added 
                xmlWriter.WriteAttributeString("sSupAddress", this.Address.Trim()); // Legacy print item
                xmlWriter.WriteAttributeString("sAddress", this.Address.Trim());
                xmlWriter.WriteAttributeString("sSupTelNo", this.TelephoneNo);      // Legacy print item
                xmlWriter.WriteAttributeString("sTelNo", this.TelephoneNo);
                xmlWriter.WriteAttributeString("sName", this.Description);
                xmlWriter.WriteAttributeString("sNameXML", this.Description.XMLEscape());
                xmlWriter.WriteAttributeString("sfullname", this.FullName.Trim());
                string fullnameTrim = this.FullName.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "FullnameTrim", 32, true));
                xmlWriter.WriteAttributeString("sfullnameTrim", fullnameTrim);
                xmlWriter.WriteAttributeString("sfullnameTrimXML", fullnameTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sCostCentre", this.CostCentre.Trim());
                string costCenterTrim = this.CostCentre.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "CostCentreTrim", 8, true));
                xmlWriter.WriteAttributeString("sCostCentreTrim", costCenterTrim);
                xmlWriter.WriteAttributeString("sCostCentreTrimXML", costCenterTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sPrintDelNote", this.PrintDeliveryNote.ToYNString());   //13Apr17 TH Reinstated
                xmlWriter.WriteAttributeString("sPrintPickTick", this.PrintPickTicket.ToYNString());    //13Apr17 TH Reinstated
                xmlWriter.WriteAttributeString("sSupType", "W");    // Legacy print item
                xmlWriter.WriteAttributeString("sInUse", this.InUse.ToYNString());

                xmlWriter.WriteAttributeString("sAdHocDelNote", this.AdHocDelNote.ToYNString());
                xmlWriter.WriteAttributeString("sInPatientDirections", this.InPatientDirections.ToYNString());
                xmlWriter.WriteAttributeString("sIsCustomer", this.IsCustomer.ToYNString());
                xmlWriter.WriteAttributeString("sOnCost", this.OnCost.Trim());
                xmlWriter.WriteAttributeString("sGlobalLocationNumber", this.GlobalLocationNumber);
                xmlWriter.WriteAttributeString("sCntFaxNo", string.Empty);                              // 17Aug16 XN 160443 Added 
                xmlWriter.WriteAttributeString("sSupFaxNo", string.Empty);                              // 17Aug16 XN 160443 Added 
                xmlWriter.WriteAttributeString("sInvFaxNo", string.Empty);                              // 17Aug16 XN 160443 Added 
                xmlWriter.WriteAttributeString("sMethodExp",string.Empty);                              // 17Aug16 XN 160443 Added 
                
                // For UHB - parse the address onto 4 lines
                var address = this.Address.Split(',');
                for (int c = 0; c < 4; c++)
                {
                    string aline = ((address.Length - 1) > c) ? address[c] : string.Empty;
                    xmlWriter.WriteAttributeString("sSuppAdd" + (c + 1).ToString(), aline);                     // 17Aug16 XN 160443 SuppAdd index starts at 1 
                    xmlWriter.WriteAttributeString("sSuppAdd" + (c + 1).ToString() + "XML", aline.XMLEscape()); // 17Aug16 XN 160443 SuppAdd index starts at 1
                }
                xmlWriter.WriteAttributeString("sSuppPostcode", address.Length > 0 ? address[address.Length - 1] : string.Empty);   // 17Aug16 XN 160443 Cover both cases
                xmlWriter.WriteAttributeString("sPostcode",     address.Length > 0 ? address[address.Length - 1] : string.Empty);   
         
                xmlWriter.WriteAttributeString("sUserField1", this.UserField1);
                xmlWriter.WriteAttributeString("sUserField2", this.UserField2);
                xmlWriter.WriteAttributeString("sUserField3", this.UserField3); // Contract Name 1
                xmlWriter.WriteAttributeString("sUserField4", this.UserField4); // Contract Name 2

                xmlWriter.WriteAttributeString("sTopUpLevel", this.TopUpLevel); // 17Jul17 TH TFS 184566    TopUp Interval 

                WCustomerExtraDataRow extraData = WCustomerExtraData.GetByID(this.WCustomerID);
                xmlWriter.WriteAttributeString("sNewContractData",     extraData == null ? string.Empty : extraData.Notes.Trim());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>Append the name and the address (with comma in-between)</summary>
        private string AppendNameAddess(string name, string address)
        {
            string result = string.Empty;
            if (!string.IsNullOrEmpty(name))
                result += name.TrimEnd(new [] { '.' });
            if (!string.IsNullOrEmpty(address))
                result += ", " + address;
            return result;
        }
    }

    public class WCustomerColumnInfo : BaseColumnInfo
    {
        public WCustomerColumnInfo() : base ("WCustomer") {  }

        public int CodeLength           { get { return FindColumnByName("Code"                  ).Length; } }
        public int DescriptionLength    { get { return FindColumnByName("Description"           ).Length; } }
        public int FullNameLength       { get { return FindColumnByName("FullName"              ).Length; } }
        public int AddressLength        { get { return FindColumnByName("Address"               ).Length; } }
        public int TelephoneNoLength    { get { return FindColumnByName("TelephoneNo"           ).Length; } }
        public int FaxNoLength          { get { return FindColumnByName("FaxNo"                 ).Length; } }
        public int CostCentreLength     { get { return FindColumnByName("CostCentre"            ).Length; } }
        public int OnCostLength         { get { return FindColumnByName("OnCost"                ).Length; } }
        public int UserField1Length     { get { return FindColumnByName("UserField1"            ).Length; } }
        public int UserField2Length     { get { return FindColumnByName("UserField2"            ).Length; } }
        public int UserField3Length     { get { return FindColumnByName("UserField3"            ).Length; } }
        public int UserField4Length     { get { return FindColumnByName("UserField4"            ).Length; } }
        public int GlobalLocationNumber { get { return FindColumnByName("GlobalLocationNumber"  ).Length; } }
        public int TopUpLevelLength     { get { return FindColumnByName("TopUpLevel"            ).Length; } }
    }

    public class WCustomer : BaseTable2<WCustomerRow, WCustomerColumnInfo>
    {
        public WCustomer() : base ("WCustomer") 
        {  
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Adds and returns new WCustomer row and sets up certain fields</summary>
        public override WCustomerRow Add()
        {
            WCustomerRow newRow = base.Add();
            newRow.Code                 = string.Empty;
            newRow.Description          = string.Empty;
            newRow.FullName             = string.Empty;
            newRow.Address              = string.Empty;
            newRow.TelephoneNo          = string.Empty;
            newRow.FaxNo                = string.Empty;
            newRow.CostCentre           = string.Empty;
            newRow.OnCost               = string.Empty;
            newRow.PrintPickTicket      = false;    //13Apr17 TH Reinstated
            newRow.PrintDeliveryNote    = false;    //13Apr17 TH Reinstated
            newRow.AdHocDelNote         = false;    // = null;  19Nov14 XN 104304
            newRow.InPatientDirections  = false;    // = null;  19Nov14 XN 104304
            newRow.IsCustomer           = false;
            newRow.InUse                = true;
            newRow.SiteID               = SessionInfo.SiteID;
            newRow.UserField1           = string.Empty;
            newRow.UserField2           = string.Empty;
            newRow.UserField3           = string.Empty;
            newRow.UserField4           = string.Empty;
            newRow.SessionLock          = 0;
            newRow.TopUpLevel           = string.Empty;
            return newRow;
        }

        /// <summary>Load row by ID</summary>
        public void LoadByID(int ID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WCustomerID", ID);
            LoadBySP("pWCustomerByID", parameters);
        }

        /// <summary>Loads customers by site and if in use</summary>
        /// <param name="siteID">site ID</param>
        /// <param name="inUseOnly">null for all (in use or not), else equal to rows in-use flag</param>
        public void LoadBySiteIDAndInUse(int siteID, bool? inUse)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",    siteID   );
            parameters.Add("InUseOnly", inUse);
            LoadBySP("pWCustomerSiteIDAndInUse", parameters);
        }

        /// <summary>Loads all customers for all sites with specified code</summary>
        public void LoadByCode(string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("Code", code);
            LoadBySP("pWCustomerCode", parameters);
        }

        /// <summary>Load all customers for a site and with a specified code</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="code">code</param>
        /// <param name="append">append method 14Apr16 XN 123082</param>
        public void LoadBySiteAndCode(int siteID, string code, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",    siteID  );
            parameters.Add("Code",      code    );
            LoadBySP(append, "pWCustomerSiteAndCode", parameters);
        }

        /// <summary>Get row by ID (else null)</summary>
        public static WCustomerRow GetByID(int wcustomerID)
        {
            WCustomer customer = new WCustomer();
            customer.LoadByID(wcustomerID);
            return customer.FirstOrDefault();
        }

        /// <summary>Returns a customer with the specified site ID and code</summary>
        /// <param name="siteID">site Id</param>
        /// <param name="code">code</param>
        public static WCustomerRow GetBySiteIDAndCode(int siteID, string code)
        {
            WCustomer customer = new WCustomer();
            customer.LoadBySiteAndCode(siteID, code);
            return customer.FirstOrDefault();
        }

        /// <summary>
        /// Returns if the code is already in used by site 
        /// (will test WCustomer, and WSupplier2 as code must be unique in WSupplier2)
        /// </summary>
        /// <param name="code">code</param>
        /// <param name="siteID">site Id</param>
        public static bool IsCodeUnique(string code, int siteID)
        {
            return WCustomer.GetBySiteIDAndCode(siteID, code) == null && WSupplier2.GetBySiteIDAndCode(siteID, code) == null;
        }

        /// <summary>Overrides the base class to write to orderlog and WPharmacyLog</summary>
        public override void Save()
        {
            DateTime now = DateTime.Now;

            // Get all modified records (get at start as state will change up save) 43318 XN 11Nov14
            var recordsToAdd    = this.Where(s => s.RawRow.RowState == DataRowState.Added   ).ToList();
            var recordsToUpdate = this.Where(s => s.RawRow.RowState == DataRowState.Modified).ToList();
            //var recordsToDelete = this.DeletedItemsTable.Rows.OfType<WCustomerRow>().ToList(); delete is not really supported (by interface)

            // Create orderlog entry for any newly created suppliers
            WOrderlog orderlog = new WOrderlog();
            //foreach (var sup in this.Where(s => s.RawRow.RowState == DataRowState.Added)) 43318 XN 11Nov14
            foreach (var sup in recordsToAdd)
            {
                WOrderlogRow row = orderlog.Add();
                row.OrderNumber     = string.Empty;
                row.NSVCode         = string.Empty;
                row.ConversionFactor= null;
                row.IssueUnits      = string.Empty;
                row.DateTimeOrd     = now;
                row.DateOrdered     = now;
                row.DateReceived    = DateTimeExtensions.PharmacyEpoch;
                row.DateInvoiced    = DateTimeExtensions.PharmacyEpoch;
                row.VatCode         = 1;
                row.VatRate         = PharmacyConverters.VatCodeToRate(sup.SiteID, row.VatCode);
                row.CostIncVat      = 0;
                row.CostExVat       = 0;
                row.VatCost         = 0;
                row.Kind            = WOrderLogType.CreateSupplier;
                row.SupplierCode    = sup.Code;
                row.SiteNumber      = Sites.GetNumberBySiteID(sup.SiteID);
                row.SiteID          = sup.SiteID;
            }

            // Save changes to the pharmacy log
            WPharmacyLog log = new WPharmacyLog();
            //log.AddRange(this, "WCustomer", r => r.Code, r => r.SiteID);
            log.AddRange(this, WPharmacyLogType.WCustomer, r => r.Code, r => r.SiteID); // 20Jan15 XN  Update Save to use new WPharmacyLogType 26734

            // And save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                base.Save();
                orderlog.Save();
                log.Save();
                trans.Commit();
            }

            // Write rows (only add or updated) to the interface file 43318 XN 11 Nov14
            PharmacyInterface interfaceFile = new PharmacyInterface();
            foreach (var row in recordsToAdd.Concat(recordsToUpdate))
            {
                IPharmacyInterfaceSettings settings = new SupplierInterfaceSettings(row.SiteID, SupplierType.Ward); // Note that this is correct it should use the SupplierInterfaceSettings for legacy reasons (both customer, and suppliers were in the WSupplier table)
                if (settings.Enabled)
                {
                    // interfaceFile.Initalise(row.ToXMLHeap(), settings); 14Apr16 XN 123082
                    interfaceFile.Initialise(settings);
                    interfaceFile.ParseXml(row.ToXMLHeap());
                    interfaceFile.Parse("sUpdateflag", recordsToAdd.Contains(row) ? "Create" : "Update");
                    interfaceFile.Save();
                }
            }
        }
    }

    public static class WCustomerEnumerableExtensions
    {
        /// <summary>Returns all customers with specified site ID</summary>
        public static IEnumerable<WCustomerRow> FindBySiteID(this IEnumerable<WCustomerRow> customers, int siteID)
        {
            return customers.Where(c => c.SiteID == siteID);
        }

        /// <summary>Returns first row by site id and code 14Apr16 XN 123082</summary>
        /// <param name="customers">List of customer</param>
        /// <param name="siteID">Site id</param>
        /// <param name="code">customer code</param>
        /// <returns>Matching row or null</returns>
        public static WCustomerRow FindBySiteAndCode(this IEnumerable<WCustomerRow> customers, int siteID, string code)
        {
            return customers.FirstOrDefault(c => code.EqualsNoCaseTrimEnd(c.Code) && siteID == siteID);
        }
    }
}
