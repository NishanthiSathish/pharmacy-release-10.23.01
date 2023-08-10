//===========================================================================
//
//							WSupplier2.cs
//
//  This class represents the WSupplier2 table.  
//  Holds pharmacy details about external suppliers and other sites (as a supplier)
//  This replaces the WSupplier table for SupplierType = 'E' AND 'S'
//
//  Any changes will be automatically saved to the PharmacyLog under "WSupplier2"
//
//  Usage:
//
//  WSupplier2 dbsupplier = new WSupplier2();
//  dbsupplier.LoadByCodeAndSiteID("EX1", siteID);
//  dbsupplier[0].Name = "External Supplier 1";
//  dbsupplier.Save();
//      
//	Modification History:
//	24Jun14 XN  Written
//	31Oct14 XN  Written 102842 Added ToNameString
//  11Nov14 XN  Added ToXMLHeap, update Save to save to interface file 43318
//  20Jan15 XN  Update Save to use new WPharmacyLogType 26734
//  14Apr16 XN  Update Save for changes in PharmacyInterface 123082
//  24Jun16 XN  Update ToXMLHeap to include sCodeXML, SiteNumber, sPostcode 108889
//  17Aug16 XN  160443 Fixed address issue with ParseXML
//  11Oct16 XN  Indicate if a Homecare supplier 87483
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Xml;
using System.Text;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Single row in WSupplier2 and inherits from basedatalayer.BaseRow and contains all properties for all WSupplier2 fields which needs to be read/set</summary>
    public class WSupplier2Row : BaseRow
    {
        public int WSupplier2ID
        {
            get { return FieldToInt(RawRow["WSupplier2ID"]).Value; }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; } 
            set { RawRow["SiteID"] = IntToField(value);      } 
        }

        public string Code
        {
            get { return FieldToStr(RawRow["Code"], true, string.Empty); }
            set { RawRow["Code"] = StrToField(value);                    }
        }

        /// <summary>Replace old WSupplier.Name</summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
            set { RawRow["Description"] = StrToField(value ?? string.Empty); }
        }

        public string FullName
        {
            get { return FieldToStr(RawRow["FullName"], true, string.Empty); }
            set { RawRow["FullName"] = StrToField(value ?? string.Empty); }
        }

        public string ContractAddress
        {
            get { return FieldToStr(RawRow["ContractAddress"], true, string.Empty); }
            set { RawRow["ContractAddress"] = StrToField(value); }
        }

        /// <summary>DB field [SupAddress]</summary>
        public string SupplierAddress
        {
            get { return FieldToStr(RawRow["SupAddress"], true, string.Empty); } 
            set { RawRow["SupAddress"] = StrToField(value); }
        }

        /// <summary>DB field [InvAddress]</summary>
        public string InvoiceAddress
        {
            get { return FieldToStr(RawRow["InvAddress"], true, string.Empty); }
            set { RawRow["InvAddress"] = StrToField(value); }
        }

        /// <summary>DB field [ContTelNo]</summary>
        public string ContractTelNo
        {
            get { return FieldToStr(RawRow["ContTelNo"], true, string.Empty); }
            set { RawRow["ContTelNo"] = StrToField(value); }
        }

        /// <summary>DB field [SupTelNo]</summary>
        public string SupplierTelNo
        {
            get { return FieldToStr(RawRow["SupTelNo"], true, string.Empty); }
            set { RawRow["SupTelNo"] = StrToField(value); }
        }

        /// <summary>DB field [InvTelNo]</summary>
        public string InvoiceTelNo
        {
            get { return FieldToStr(RawRow["InvTelNo"], true, string.Empty); }
            set { RawRow["InvTelNo"] = StrToField(value); }
        }

        /// <summary>DB field [ContFaxNo]</summary>
        public string ContractFaxNo
        {
            get { return FieldToStr(RawRow["ContFaxNo"], true, string.Empty); }
            set { RawRow["ContFaxNo"] = StrToField(value); }
        }

        /// <summary>DB field [SupFaxNo]</summary>
        public string SupplierFaxNo
        {
            get { return FieldToStr(RawRow["SupFaxNo"], true, string.Empty); }
            set { RawRow["SupFaxNo"] = StrToField(value); }
        }

        /// <summary>DB field [InvFaxNo]</summary>
        public string InvoiceFaxNo
        {
            get { return FieldToStr(RawRow["InvFaxNo"], true, string.Empty); }
            set { RawRow["InvFaxNo"] = StrToField(value); }
        }

        public string DiscountDesc
        {
            get { return FieldToStr(RawRow["DiscountDesc"], true);    }  
            set { RawRow["DiscountDesc"] = StrToField(value);   }
        }

        public string DiscountVal
        {
            get { return FieldToStr(RawRow["DiscountVal"], true);    }
            set { RawRow["DiscountVal"] = StrToField(value);   }
        }

        public SupplierMethod Method
        {
            get { return FieldToEnumByDBCode<SupplierMethod>(RawRow["Method"]); }
            set { RawRow["Method"] = EnumToFieldByDBCode(value); }
        }

        public string OrdMessage
        {
            get { return FieldToStr(RawRow["OrdMessage"], true, string.Empty); }
            set { RawRow["OrdMessage"] = StrToField(value); }
        }

        public string AvLeadTime
        {
            get { return FieldToStr(RawRow["AvLeadTime"], true, string.Empty); }
            set { RawRow["AvLeadTime"] = StrToField(value); }
        }

        /// <summary>Replace old WSupplier.Ptn</summary>
        public bool PrintTradeName
        {
            get { return FieldToBoolean(RawRow["PrintTradeName"]) ?? false; }
            set { RawRow["PrintTradeName"] = BooleanToField(value);         }
        }

        /// <summary>Replace old WSupplier.PSis</summary>
        public bool PrintNSVCode
        {
            get { return FieldToBoolean(RawRow["PrintNSVCode"]) ?? false; }
            set { RawRow["PrintNSVCode"] = BooleanToField(value);         }
        }

        public string DiscountBelow
        {
            get { return FieldToStr(RawRow["DiscountBelow"], true, string.Empty); }
            set { RawRow["DiscountBelow"] = StrToField(value); }
        }

        public string DiscountAbove
        {
            get { return FieldToStr(RawRow["DiscountAbove"], true, string.Empty); }
            set { RawRow["DiscountAbove"] = StrToField(value); }
        }

        public string CostCentre
        {
            get { return FieldToStr(RawRow["CostCentre"], true, string.Empty);  }
            set { RawRow["CostCentre"] = StrToField(value); }
        }

        public string OrderOutput
        {
            get { return FieldToStr(RawRow["OrderOutput"], true, string.Empty); }
            set { RawRow["OrderOutput"] = StrToField(value); }
        }

        public string OnCost
        {
            get { return FieldToStr(RawRow["OnCost"], true, string.Empty); }
            set { RawRow["OnCost"] = StrToField(value); }
        }

        public double? MinimumOrderValue
        {
            get { return FieldToDouble(RawRow["MinimumOrderValue"]);}
            set { RawRow["MinimumOrderValue"] = DoubleToField(value); }   
        }

        public string LeadTime
        {
            get { return FieldToStr(RawRow["LeadTime"], true, string.Empty); }
            set { RawRow["LeadTime"] = StrToField(value); }
        }

        /// <summary>Returns if PSO supplier (DB field code [PSO])</summary>
        public bool PSOSupplier
        {
            get { return FieldToBoolean(RawRow["PSO"]) ?? false;    }
            set { RawRow["PSO"] = BooleanToField(value);            }   
        }

        public string NationalSupplierCode
        {
            get { return FieldToStr(RawRow["NationalSupplierCode"], true, string.Empty); }
            set { RawRow["NationalSupplierCode"] = StrToField(value);                    }
        }

        public string DUNSReference
        {
            get { return FieldToStr(RawRow["DUNSReference"], true, string.Empty); }
            set { RawRow["DUNSReference"] = StrToField(value);                    }
        }

        public string UserField1
        {
            get { return FieldToStr(RawRow["UserField1"], true, string.Empty); }
            set { RawRow["UserField1"] = StrToField(value);                     }
        }

        public string UserField2
        {
            get { return FieldToStr(RawRow["UserField2"], true, string.Empty); }
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

        public int? LocationID_PharmacyStockholding
        {
            get { return FieldToInt(RawRow["LocationID_PharmacyStockholding"]);   }
            set { RawRow["LocationID_PharmacyStockholding"] = IntToField(value);  }
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]) ?? true;    }
            set { RawRow["InUse"] = BooleanToField(value);           }   
        }

        public int SessionLock
        {
            get { return FieldToInt(RawRow["SessionLock"]).Value;   }
            set { RawRow["SessionLock"] = IntToField(value);        }
        }

        /// <summary>DB field SupplierType (only supports external 'E' or site 'S')</summary>
        public SupplierType Type
        {
            get { return FieldToEnumByDBCode<SupplierType>(RawRow["SupplierType"]); }
            set 
            { 
                if (value != SupplierType.External && value != SupplierType.Stores)
                    throw new ApplicationException("WSupplier2 only SupplierType External or Stores");
                RawRow["SupplierType"] = EnumToFieldByDBCode<SupplierType>(value); 
            }
        }

        /// <summary>Returns the site number if the this supplier is another site</summary>
        public int? GetPharmacyStockholdingNumber()
        {
            int? locationID_PharmacyStockholding = this.LocationID_PharmacyStockholding;
            if (locationID_PharmacyStockholding == null)
                return null;
            else
                return Sites.GetNumberBySiteID( locationID_PharmacyStockholding.Value );
        }

        /// <summary>Should Requisitions from this ward print a Delivery Note</summary>
        public bool? PrintDeliveryNote
        {
            get { return FieldToBoolean(RawRow["PrintDeliveryNote"]); }
            set { RawRow["PrintDeliveryNote"] = BooleanToField(value); }
        }

        /// <summary>Returns the supplier code - Description</summary>
        public override string ToString()
        {
            return string.Format("{0} - {1}", this.Code, this.Description);
        }

        /// <summary>
        /// Returns supplier name (and address)
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
                return this.Description;    // This is correct as long name is then normally displayed separatley (so could do with improvment)
            case SupplierNameType.FullName :
                string name =  StringExtensions.IsNullOrEmptyAfterTrim(this.FullName) ? this.Description : this.FullName;
                return this.AppendNameAddess(name, this.SupplierAddress); 
            default:             
                return this.AppendNameAddess(this.Description, this.SupplierAddress); 
            }
        }

        /// <summary>
        /// Creates an XML heap for a supplier  43318
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
                xmlWriter.WriteAttributeString("sCodeXML",    this.Code.XMLEscape());                                   // 15Aug16 XN 108889 Added 
                xmlWriter.WriteAttributeString("SiteNumber",  Site2.GetSiteNumberByID(this.SiteID).ToString("000"));    // 15Aug16 XN 108889 Added 
                xmlWriter.WriteAttributeString("sCntAddress", this.ContractAddress);
                xmlWriter.WriteAttributeString("sSupAddress", this.SupplierAddress);
                xmlWriter.WriteAttributeString("sInvAddress", this.InvoiceAddress);
                xmlWriter.WriteAttributeString("sCntTelNo", this.ContractTelNo);
                xmlWriter.WriteAttributeString("sSupTelNo", this.SupplierTelNo);
                xmlWriter.WriteAttributeString("sInvTelNo", this.InvoiceTelNo);
                xmlWriter.WriteAttributeString("sDiscountDesc", this.DiscountDesc);
                xmlWriter.WriteAttributeString("sDiscountVal", this.DiscountVal);
                xmlWriter.WriteAttributeString("sMethod", EnumDBCodeAttribute.EnumToDBCode(this.Method));
                xmlWriter.WriteAttributeString("sEDI", (this.Method == SupplierMethod.EDI).ToYNString());
                switch (this.Method)
                {
                case SupplierMethod.EDI:      xmlWriter.WriteAttributeString("sMethodExp", "EDI"); break;
                case SupplierMethod.Fax:      xmlWriter.WriteAttributeString("sMethodExp", "Fax"); break;  
                case SupplierMethod.Internal: xmlWriter.WriteAttributeString("sMethodExp", "Internal"); break;
                case SupplierMethod.Direct:   xmlWriter.WriteAttributeString("sMethodExp", "Direct"); break;  
                default:                      xmlWriter.WriteAttributeString("sMethodExp", "Other"); break;  
                }
                xmlWriter.WriteAttributeString("sOrdMessage", this.OrdMessage.Trim());
                xmlWriter.WriteAttributeString("sAvgLeadTime", this.AvLeadTime.Trim());
                xmlWriter.WriteAttributeString("sCntFaxNo", this.ContractFaxNo);
                xmlWriter.WriteAttributeString("sSupFaxNo", this.SupplierFaxNo);
                xmlWriter.WriteAttributeString("sInvFaxNo", this.InvoiceFaxNo);
                xmlWriter.WriteAttributeString("sName", this.Description);
                xmlWriter.WriteAttributeString("sNameXML", this.Description.XMLEscape());
                xmlWriter.WriteAttributeString("sPtn", this.PrintTradeName.ToYNString());
                xmlWriter.WriteAttributeString("sPsis", this.PrintNSVCode.ToYNString());
                xmlWriter.WriteAttributeString("sfullname", this.FullName.Trim());
                string fullnameTrim = this.FullName.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "FullnameTrim", 32, true));
                xmlWriter.WriteAttributeString("sfullnameTrim", fullnameTrim);
                xmlWriter.WriteAttributeString("sfullnameTrimXML", fullnameTrim.XMLEscape());
                xmlWriter.WriteAttributeString("sDiscountBelow", this.DiscountBelow);
                xmlWriter.WriteAttributeString("sDiscountAbove", this.DiscountAbove);
                xmlWriter.WriteAttributeString("sCostCentre", this.CostCentre.Trim());
                string costCenterTrim = this.CostCentre.SafeSubstring(0, WConfiguration.LoadAndCache<int>(SessionInfo.SiteID, "D|genint", "SupplierInterface", "CostCentreTrim", 8, true));
                xmlWriter.WriteAttributeString("sCostCentreTrim", costCenterTrim);
                xmlWriter.WriteAttributeString("sCostCentreTrimXML", costCenterTrim.XMLEscape());
                //xmlWriter.WriteAttributeString("sPrintPickTick", Trim$(sup.PrintPickTicket), 0
                xmlWriter.WriteAttributeString("sSupType", EnumDBCodeAttribute.EnumToDBCode(this.Type));
                xmlWriter.WriteAttributeString("sOrdOutput", this.OrderOutput.Trim());
                xmlWriter.WriteAttributeString("sPrintDelNote", this.PrintDeliveryNote.ToYNString());
                //xmlWriter.WriteAttributeString("sReceiveGoods", Trim$(sup.ReceiveGoods), 0
                //xmlWriter.WriteAttributeString("sTopUp", Trim$(sup.TopupInterval), 0
                //xmlWriter.WriteAttributeString("sATC", Trim$(sup.ATCSupplied), 0
                //parsedate sup.topupdate, strDate, "dd/mmm/ccyy", 0
                //xmlWriter.WriteAttributeString("sTopUpDate", strDate, 0
                xmlWriter.WriteAttributeString("sInUse", this.InUse.ToYNString());
                //xmlWriter.WriteAttributeString("swardcode", Trim$(sup.wardcode), 0                    '21Oct09 TH (F0066973)
                //xmlWriter.WriteAttributeString("swardcodeXML", XMLEscape(Trim$(sup.wardcode)), 0      '21Oct09 TH Addd for good measure (Zetes)
                xmlWriter.WriteAttributeString("sMinOrderValue", this.MinimumOrderValue.ToString());

                // For UHB - parse the address onto 4 lines
                var address = this.SupplierAddress.Split(',');
                for (int c = 0; c < 4; c++)
                {
                    string aline = ((address.Length - 1) > c) ? address[c] : string.Empty;
                    xmlWriter.WriteAttributeString("sSuppAdd" + (c + 1).ToString(), aline);                     // 17Aug16 XN 160443 SuppAdd index starts at 1 
                    xmlWriter.WriteAttributeString("sSuppAdd" + (c + 1).ToString() + "XML", aline.XMLEscape()); // 17Aug16 XN 160443 SuppAdd index starts at 1 
                }
                xmlWriter.WriteAttributeString("sSuppPostcode", address.Length > 0 ? address[address.Length - 1] : string.Empty);   // 17Aug16 XN 160443\108889 Cover both cases
                xmlWriter.WriteAttributeString("sPostcode",     address.Length > 0 ? address[address.Length - 1] : string.Empty);   
         
                xmlWriter.WriteAttributeString("sNationalSupplierCode", this.NationalSupplierCode);
                xmlWriter.WriteAttributeString("sDUNSReference", this.DUNSReference);
                xmlWriter.WriteAttributeString("sUserField1", this.UserField1);
                xmlWriter.WriteAttributeString("sUserField2", this.UserField2);
                xmlWriter.WriteAttributeString("sUserField3", this.UserField3); // Contract Name 1
                xmlWriter.WriteAttributeString("sUserField4", this.UserField4); // Contract Name 2

                WSupplier2ExtraDataRow extraData = WSupplier2ExtraData.GetByID(this.WSupplier2ID);
                xmlWriter.WriteAttributeString("sCurrentContractData", extraData == null ? string.Empty : extraData.CurrentContractData.Trim());
                xmlWriter.WriteAttributeString("sNewContractData",     extraData == null ? string.Empty : extraData.NewContractData.Trim());
                xmlWriter.WriteAttributeString("sDateofChange",        extraData == null ? string.Empty : extraData.DateOfChange.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("sNotes",               extraData == null ? string.Empty : extraData.Notes.Trim());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>Append the name and the address (with comma inbetween)</summary>
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


    /// <summary>Provides column information for WSupplier2, such as maximum field lengths</summary>
    public class WSupplier2ColumnInfo : BaseColumnInfo
    {
        public WSupplier2ColumnInfo() : base("WSupplier2") { }

        public int CodeLength           { get { return tableInfo.GetFieldLength("Code");            } }
        public int DescriptionLength    { get { return tableInfo.GetFieldLength("Description");     } }
        public int FullNameLength       { get { return tableInfo.GetFieldLength("FullName");        } }
        public int ContractAddressLength{ get { return tableInfo.GetFieldLength("ContractAddress"); } }
        public int SupplierAddressLength{ get { return tableInfo.GetFieldLength("SupAddress");      } }
        public int InvoiceAddressLength { get { return tableInfo.GetFieldLength("InvAddress");      } }
        public int ContractTelNoLength  { get { return tableInfo.GetFieldLength("ContTelNo");       } }
        public int SupplierTelNoLength  { get { return tableInfo.GetFieldLength("SupTelNo");        } }
        public int InvoiceTelNoLength   { get { return tableInfo.GetFieldLength("InvTelNo");        } }
        public int ContractFaxNoLength  { get { return tableInfo.GetFieldLength("ContFaxNo");       } }
        public int SupplierFaxNoLength  { get { return tableInfo.GetFieldLength("SupFaxNo");        } }
        public int InvoiceFaxNoLength   { get { return tableInfo.GetFieldLength("InvFaxNo");        } }

        public int DiscountDescLength   { get { return tableInfo.GetFieldLength("DiscountDesc");    } }
        public int DiscountValLength    { get { return tableInfo.GetFieldLength("DiscountVal");     } }
        public int OrdMessageLength     { get { return tableInfo.GetFieldLength("OrdMessage");      } }
        public int AvLeadTimeLength     { get { return tableInfo.GetFieldLength("AvLeadTime");      } }
        public int DiscountBelowLength  { get { return tableInfo.GetFieldLength("DiscountBelow");   } }
        public int DiscountAboveLength  { get { return tableInfo.GetFieldLength("DiscountAbove");   } }
        public int CostCentreLength     { get { return tableInfo.GetFieldLength("CostCentre");      } }
        public int OrderOutputLength    { get { return tableInfo.GetFieldLength("OrderOutput");     } }
        public int OnCostLength         { get { return tableInfo.GetFieldLength("OnCost");          } }
        public int LeadTimeLength       { get { return tableInfo.GetFieldLength("LeadTime");        } }
        public int NationalSupplierCodeLength   { get { return tableInfo.GetFieldLength("NationalSupplierCode"); } }
        public int DUNSReferenceLength  { get { return tableInfo.GetFieldLength("DUNSReference");   } }

        public int UserField1Length     { get { return tableInfo.GetFieldLength("UserField1");      } }
        public int UserField2Length     { get { return tableInfo.GetFieldLength("UserField2");      } }
        public int UserField3Length     { get { return tableInfo.GetFieldLength("UserField3");      } }
        public int UserField4Length     { get { return tableInfo.GetFieldLength("UserField4");      } }
    }

    /// <summary>Represents WSupplier2 table</summary>
    public class WSupplier2 : BaseTable2<WSupplier2Row, WSupplier2ColumnInfo>
    {
        public WSupplier2() : base("WSupplier2") 
        { 
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Adds and returns new WSupplier2 row and sets up certain fields</summary>
        public override WSupplier2Row Add()
        {
            
            WSupplier2Row newRow = base.Add();
            newRow.Code                 = string.Empty;
            newRow.Description          = string.Empty;
            newRow.FullName             = string.Empty;
            newRow.ContractAddress      = string.Empty;
            newRow.SupplierAddress      = string.Empty;
            newRow.InvoiceAddress       = string.Empty;
            newRow.ContractTelNo        = string.Empty;
            newRow.SupplierTelNo        = string.Empty;
            newRow.InvoiceTelNo         = string.Empty;
            newRow.ContractFaxNo        = string.Empty;
            newRow.SupplierFaxNo        = string.Empty;
            newRow.InvoiceFaxNo         = string.Empty;
            newRow.Method               = SupplierMethod.Unknown;
            newRow.PrintTradeName       = false;
            newRow.PrintNSVCode         = false;
            newRow.CostCentre           = string.Empty;
            newRow.OnCost               = string.Empty;
            newRow.PrintDeliveryNote    = false;
            newRow.OrderOutput          = string.Empty;
            newRow.PSOSupplier          = false;
            newRow.NationalSupplierCode = string.Empty;
            newRow.UserField1           = string.Empty;
            newRow.UserField2           = string.Empty;
            newRow.UserField3           = string.Empty;
            newRow.UserField4           = string.Empty;
            newRow.InUse                = true;
            newRow.SessionLock          = 0;
            newRow.MinimumOrderValue    = 0;
            newRow.DUNSReference        = string.Empty;
            return newRow;
        }

        /// <summary>Load row by ID</summary>
        public void LoadByID(int ID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WSupplier2ID", ID);
            LoadBySP("pWSupplier2ByID", parameters);
        }

        /// <summary>Loads all supplier for all sites with sepcified code</summary>
        public void LoadByCode(string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("Code", code);
            LoadBySP("pWSupplier2ByCode", parameters);
        }

        /// <summary>Loads supplier by sites and code</summary>
        public void LoadBySiteAndCode(int siteID, string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", siteID);
            parameters.Add("Code",   code   );
            LoadBySP("pWSupplier2BySiteAndCode", parameters);
        }

        /// <summary>Loads suppliers by site and code 87483 11Oct16 XN</summary>
        /// <param name="siteID">site to load</param>
        /// <param name="codes">supplier codes</param>
        public void LoadBySiteAndCodes(int siteID, IEnumerable<string> codes)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", siteID);
            parameters.Add("Codes",  "'" + codes.ToCSVString("','") + "'");
            LoadBySP("pWSupplier2BySiteAndCodes", parameters);
        }

        /// <summary>Loads supplier by site and if in use</summary>
        /// <param name="siteID">site ID</param>
        /// <param name="inUseOnly">null for all (in use or not), else equal to rows inuse flag</param>
        public void LoadBySiteIDAndInUse(int siteID, bool? inUse)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",    siteID   );
            parameters.Add("InUseOnly", inUse);
            LoadBySP("pWSupplier2SiteIDAndInUse", parameters);
        }

        /// <summary>Get row by ID (else null)</summary>
        public static WSupplier2Row GetByID(int wsupplierID)
        {
            WSupplier2 supplier = new WSupplier2();
            supplier.LoadByID(wsupplierID);
            return supplier.FirstOrDefault();
        }

        /// <summary>Returns a supplier with the specified site ID and code</summary>
        /// <param name="siteID">site Id</param>
        /// <param name="code">code</param>
        public static WSupplier2Row GetBySiteIDAndCode(int siteID, string code)
        {
            WSupplier2 supplier = new WSupplier2();
            supplier.LoadBySiteAndCode(siteID, code);
            return supplier.FirstOrDefault();
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

            // Get all modified records (get at start as state will change up save) 43318
            var recordsToAdd    = this.Where(s => s.RawRow.RowState == DataRowState.Added   ).ToList();
            var recordsToUpdate = this.Where(s => s.RawRow.RowState == DataRowState.Modified).ToList();
            //var recordsToDelete = this.DeletedItemsTable.Rows.OfType<WCustomerRow>().ToList(); delete is not really supported (by interface)

            // Create orderlog entry for any newly created suppliers
            WOrderlog orderlog = new WOrderlog();
            //foreach (var sup in this.Where(s => s.RawRow.RowState == DataRowState.Added)) 43318
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
            //log.AddRange(this, "WSupplier2", r => r.Code, r => r.SiteID);  20Jan15 XN 26734
            log.AddRange(this, WPharmacyLogType.WSupplier2, r => r.Code, r => r.SiteID);

            // And save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                base.Save();
                orderlog.Save();
                log.Save();
                trans.Commit();
            }

            // Write rows (only add or updated) to the interface file 43318
            PharmacyInterface interfaceFile = new PharmacyInterface();
            foreach (var row in recordsToAdd.Concat(recordsToUpdate))
            {
                IPharmacyInterfaceSettings settings = new SupplierInterfaceSettings(row.SiteID, row.Type);
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

    public static class WSupplier2Enumerable
    {
        /// <summary>Returns all suppliers with specified site ID</summary>
        public static IEnumerable<WSupplier2Row> FindBySiteID(this IEnumerable<WSupplier2Row> suppliers, int siteID)
        {
            return suppliers.Where(c => c.SiteID == siteID);
        }

        /// <summary>
        /// Returns first supplier by code or null if no supplier
        /// 87483 11Oct16 XN
        /// </summary>
        /// <param name="suppliers">Supplier list</param>
        /// <param name="code">Code to search for</param>
        /// <returns>first supplier by code or null</returns>
        public static WSupplier2Row FindByCode(this IEnumerable<WSupplier2Row> suppliers, string code)
        {
            return code == null ? null : suppliers.FirstOrDefault(c => code.EqualsNoCaseTrimEnd(c.Code));
        }
    }
}
