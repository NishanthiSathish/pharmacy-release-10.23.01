//===========================================================================
//
//							       WRequis.cs
//
//  Provides access to WRequis table.
//
//  Classes are derived from BaseOrderRow
//
//  WRequis table holds information about individual completed requisition lines.
//
//  SP for this object should return all fields from the WRequis table, and a 
//  links in the following extra fields
//      WSupplier.Name           as supname
//      WSupplier.SupplierType   as WSupplier_SupplierType
//      SiteProductData.Convfact as SiteProductData_Convfact
//
//  Supports reading, and inserting
//
//	Modification History:
//	01Jun09 XN  Written
//  22Jul09 XN  Added LoadByID method
//  24Jul09 XN  Added custom insert methods
//  29Apr10 XN  Made more robust against DB nulls, and extended to replace 
//              business layer class RequisitionProcessor.
//  19Aug14 XN  Now using BaseTable2
//  20nov14 XN  Added LoadByWWardProductListLineAndState
//  19Feb15 XN  Added LoadBySiteIDNSVCodeAndState 89162
//  20Oct15 TH  Alterations for PECOS interface (TFS 95744)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a record in the WRequis table</summary>
    public class WRequisRow : BaseOrderRow
    {
        public int WRequisID 
        { 
            get { return FieldToInt(RawRow["WRequisID"]).Value; }
        }

        public string RequisitionNumber 
        { 
            get { return FieldToStr(RawRow["RequisitionNum"], false, string.Empty); }
            set { RawRow["RequisitionNum"] = StrToField(value);                     }
        }

        public bool DLO
        {
            get { return FieldToBoolean(RawRow["DLO"]) ?? false; }
            set { RawRow["DLO"] = BooleanToField(value); }
        }

        public string DLOWard
        {
            get { return FieldToStr(RawRow["DLOWard"], false, string.Empty); }
            set { RawRow["DLOWard"] = StrToField(value); }
        }

        /// <summary>
        /// DB string field [Outstanding]
        /// Represents quantity left to receive
        /// Will always be in packs (issues with WRequis have been corrected)
        /// </summary>
        public override decimal? OutstandingInPacks
        { 
            get 
            {
                decimal? outstanding = FieldStrToDecimal(RawRow["Outstanding"]);
                if (outstanding.HasValue && ((SupplierType == SupplierType.Ward) || (SupplierType == SupplierType.List)) && !PrintInPacks)
                    outstanding = outstanding / FieldToInt(SiteProductData_ConversionFactorPackToIssueUnits);
                    //outstanding = outstanding / FieldToInt(RawRow["SiteProductData_Convfact"]); 07Oct15 TH Replaced with above

                return outstanding;  
            }
            set 
            { 
                if (value.HasValue && ((SupplierType == SupplierType.Ward) || (SupplierType == SupplierType.List)) && !PrintInPacks)
                    value = value * FieldToInt(SiteProductData_ConversionFactorPackToIssueUnits);
                //value = value * FieldToInt(RawRow["SiteProductData_Convfact"]);  07Oct15 TH Replaced with above

                RawRow["Outstanding"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().OutstandingInPacksLength, true);
            }
        }

        /// <summary>
        /// Displaying of requisition outstanding value in whole packs is complicated by the fact 
        /// it is dependant on supplier type, and if the print in packs config option is enabled.
        /// 
        /// If (Supplier is W or L) and Not PrintInPacks  
        ///	    Returns outstanding in issue units
        /// Else if not in whole packs
	    ///     Returns outstanding in issue units
        /// Else 
        ///     Returns outstanding x conversion factor
        /// </summary>
        /// <param name="conversionFactorPackToIssueUnits">product conversion factor</param>
        /// <returns>String to display outstanding value in whole packs</returns>
        public string OutstandingInPacksToWholePackString ()
        {
            bool printInPacks = ((SupplierType != SupplierType.Ward) && (SupplierType != SupplierType.List)) || PrintInPacks;
            int conversionFactorPackToIssueUnits = FieldToInt(RawRow["SiteProductData_Convfact"]).Value;
            return (OutstandingInPacks ?? 0m).ToWholePackString ( conversionFactorPackToIssueUnits, printInPacks);
        }


        /// <summary>
        /// DB string field [Received]
        /// Will always be in packs (issues with WRequis have been corrected)
        /// </summary>
        public override decimal? ReceivedInPacks
        { 
            get 
            {
                decimal? received = FieldStrToDecimal(RawRow["Received"]);  

                if (received.HasValue && ((SupplierType == SupplierType.Ward) || (SupplierType == SupplierType.List)) && !PrintInPacks)
                    received = received / FieldToInt(RawRow["SiteProductData_Convfact"]);  

                return received;
            }
            set 
            { 
                if (SupplierType == SupplierType.Unknown)
                    throw new ApplicationException("Must set SupplierType before setting ReceivedInPacks value");

                if (value.HasValue && ((SupplierType == SupplierType.Ward) || (SupplierType == SupplierType.List)) && !PrintInPacks)
                    value = value * FieldToInt(RawRow["SiteProductData_Convfact"]);  

                RawRow["Received"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().ReceivedInPacksLength, true);    
            }
        }

        /// <summary>
        /// Displaying of requisition received value in whole packs is complicated by the fact 
        /// it is dependant on supplier type, and if the print in packs config option is enabled.
        /// 
        /// If (Supplier is W or L) and Not PrintInPacks  
        ///	    Returns received in issue units
        /// Else if not in whole packs
	    ///     Returns received in issue units
        /// Else 
        ///     Returns received x conversion factor
        /// </summary>
        /// <returns>String to display outstanding value in whole packs</returns>
        public string ReceivedInPacksToWholePackString ()
        {
            bool printInPacks = ((SupplierType != SupplierType.Ward) && (SupplierType != SupplierType.List)) || PrintInPacks;
            return (ReceivedInPacks ?? 0m).ToWholePackString ( SiteProductData_ConversionFactorPackToIssueUnits, printInPacks);
        }

        #region Private Methods
        /// <summary>
        /// Returns the PrintInPacks configuration information
        /// Either read from web cache, or from WConfiguration category=d|WorkingDefaults and key=PrintInPacks
        /// </summary>
        private static bool PrintInPacks
        {
            get 
            {
                string cachedName = string.Format("{0}.PrintInPacks[{1}]", typeof(WRequisRow).FullName, SessionInfo.SiteID);

                object value = PharmacyDataCache.GetFromContext(cachedName);
                if ( value == null )
                {
                    value =  WConfigurationController.LoadASetting(SessionInfo.SiteID, "d|WorkingDefaults", "", "PrintInPacks", "0", false, typeof(bool));
                    PharmacyDataCache.SaveToContext(cachedName, value);
                }
                                
                return (bool)value; 
            }
        }

        /// <summary>
        /// DB field SiteProductData.convfact
        /// If value does not exist (newly created line) then manualy loads value from db
        /// </summary>
        private int SiteProductData_ConversionFactorPackToIssueUnits
        {
            get
            {
                if (RawRow.Table.Columns.Contains("SiteProductData_Convfact"))
                    return FieldToInt(RawRow["SiteProductData_Convfact"]).Value;
                else
                {
                    // May not existing in the exsting data set 
                    WProduct product = new WProduct();
                    product.LoadByProductAndSiteID(this.NSVCode, this.SiteID);
                    if (product.Count == 0)
                        throw new ApplicationException(string.Format("Failed to load product '{0}' for site id {1} (required for converting WRequis data from issue units to packs)", this.NSVCode, this.SiteID));

                    return product[0].ConversionFactorPackToIssueUnits;
                }
            }
        }
        #endregion
    }
    
    /// <summary>Provides column information about the WRequis table</summary>
    public class WRequisColumnInfo : BaseOrderColumnInfo
    {
        public WRequisColumnInfo() : base("WRequis") { }
    }

    /// <summary>Represent the WRequis table</summary>
    //public class WRequis : BaseTable<WRequisRow, WRequisColumnInfo>  19Aug14 XN  Now using BaseTable2
    public class WRequis : BaseTable2<WRequisRow, WRequisColumnInfo>
    {
        public WRequis() : base("WRequis")  { }

        /// <summary>
        /// Gets all the requisitions for a site, or nsv code, limited to a date.
        /// The sp returns extra NOrddate, and NRecdate, fields but these are not 
        /// exposed by the WRequisRow oject as they are a legacy issue and only used by 
        /// the stores drug info (F4) screen
        /// </summary>
        /// <param name="siteID">ID of the site</param>
        /// <param name="NSVCode">nsv code</param>
        /// <param name="from">returns all orders from this date (set to null to return all)</param>
        public void LoadBySiteIDNSVCodeAndFromDate (int siteID, string NSVCode, DateTime? from)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("FromDate",          from ?? DateTimeExtensions.MinDBValue);
            LoadBySP("pWRequisBySiteIDNSVCodeAndFromDate", parameters);
        }

        /// <summary>
        /// Gets a single requisitions line by pk.
        /// </summary>
        /// <param name="wrequisID">pk of record to get</param>
        public void LoadByID(int wrequisID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("WRequisID",         wrequisID);
            LoadBySP("pWRequisByID", parameters);
        }

        /// <summary>Gets all wrequis by WWardProductListLineIDs, and states</summary>
        public void LoadByWWardProductListLineAndState(IEnumerable<int> WWardProductListLineID, OrderStatusType[] states)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("WWardProductListLineIDs", WWardProductListLineID.ToCSVString(","));
            parameters.Add("States",                  "'" + states.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'");
            LoadBySP( "pWRequisByWWardProductListLineAndState", parameters);
        }

        /// <summary>Loads the lines, by site, NSVCode, and state 19Feb14 XN 89162</summary>
        /// <param name="siteID">ID of the site</param>
        /// <param name="NSVCode">nsv code</param>
        /// <param name="Status">States to load</param>
        public void LoadBySiteIDNSVCodeAndState(int siteID, string NSVCode, OrderStatusType[] status)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("SiteID",            siteID);   
            parameters.Add("NSVCode",           NSVCode);
            parameters.Add("States",            "'" + status.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'");
            LoadBySP( "pWRequisBySiteIDNSVCodeAndState", parameters );
        }

        ///// <summary>
        ///// Need to do insert manually as sp parameter don't match column names
        ///// </summary>
        ///// <param name="row">Row to insert</param>
        //protected override void InsertRow(DataRow row)
        //{
        //    StringBuilder parameters = new StringBuilder();

        //    // Build up parameter list
        //    AddInputParam(parameters, "LocationID_Site", row, "SiteID");
        //    AddInputParam(parameters, "Code",            row, "Code");          
        //    AddInputParam(parameters, "convfact",        row, "convfact");      
        //    AddInputParam(parameters, "cost",            row, "cost");          
        //    AddInputParam(parameters, "CreatedUser",     row, "CreatedUser");   
        //    AddInputParam(parameters, "custordno",       row, "custordno");     
        //    AddInputParam(parameters, "description",     row, "description");   
        //    AddInputParam(parameters, "Indispute",       row, "Indispute");       
        //    AddInputParam(parameters, "IndisputeUser",   row, "IndisputeUser"); 
        //    AddInputParam(parameters, "internalmethod",  row, "internalmethod");
        //    AddInputParam(parameters, "internalsiteno",  row, "internalsiteno");
        //    AddInputParam(parameters, "invnum",          row, "invnum");        
        //    AddInputParam(parameters, "IssueUnits",      row, "IssueUnits");    
        //    AddInputParam(parameters, "loccode",         row, "loccode");         
        //    AddInputParam(parameters, "RequisitionNum",  row, "RequisitionNum");
        //    AddInputParam(parameters, "numprefix",       row, "numprefix");       
        //    AddInputParam(parameters, "orddate",         row, "orddate");       
        //    AddInputParam(parameters, "ordtime",         row, "ordtime");       
        //    AddInputParam(parameters, "outstanding",     row, "outstanding");     
        //    AddInputParam(parameters, "paydate",         row, "paydate");       
        //    AddInputParam(parameters, "pflag",           row, "pflag");                
        //    AddInputParam(parameters, "pickno",          row, "pickno");        
        //    AddInputParam(parameters, "qtyordered",      row, "qtyordered");    
        //    AddInputParam(parameters, "recdate",         row, "recdate");         
        //    AddInputParam(parameters, "received",        row, "received");         
        //    AddInputParam(parameters, "Reconciledate",   string.Empty);   // Not used by sp!  
        //    AddInputParam(parameters, "rectime",         row, "rectime");       
        //    AddInputParam(parameters, "revisionlevel",   row, "revisionlevel"); 
        //    AddInputParam(parameters, "ShelfPrinted",    row, "ShelfPrinted");  
        //    AddInputParam(parameters, "Status",          row, "Status");        
        //    AddInputParam(parameters, "Stocked",         row, "Stocked");       
        //    AddInputParam(parameters, "supcode",         row, "supcode");       
        //    AddInputParam(parameters, "suppliertype",    row, "suppliertype");  
        //    AddInputParam(parameters, "tofollow",        row, "tofollow");        
        //    AddInputParam(parameters, "urgency",         row, "urgency");       
        //    AddInputParam(parameters, "VATAmount",       row, "VATAmount");     
        //    AddInputParam(parameters, "VATInclusive",    row, "VATInclusive");  
        //    AddInputParam(parameters, "VATRateCode",     row, "VATRateCode");     
        //    AddInputParam(parameters, "VATRatePCT",      row, "VATRatePCT");    
        //    AddInputParam(parameters, "CodingSlipDate",  string.Empty);   // Not used by sp!  
        //    AddInputParam(parameters, "DeliveryNoteReference", row, "DeliveryNoteReference");
        //    AddInputParam(parameters, "DLO",             row, "DLO");
        //    AddInputParam(parameters, "DLOWard",         row, "DLOWard");

        //    // Perform the insert
        //    int pk = dblayer.ExecuteInsertSP(SessionInfo.SessionID, TableName, parameters.ToString());

        //    // update local dataset pk
        //    row.Table.Columns[PKColumnName].ReadOnly = false;
        //    row[PKColumnName] = pk;
        //    row.Table.Columns[PKColumnName].ReadOnly = true;
        //}
    }
}
