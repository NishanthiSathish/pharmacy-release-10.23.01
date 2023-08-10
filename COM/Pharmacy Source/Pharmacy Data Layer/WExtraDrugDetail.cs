//===========================================================================
//
//							WExtraDrugDetail.cs
//
//  This class represents the WExtraDrugDetail table in the Pharmacy Data Layer.
//
//  This table contains contract information for a supplier (and drug) with the date 
//  that this information comes into effect. 
//  When this contract information does come into effect the overnight job will then 
//  update WSupplierProfile with the new contract information.
//
//  Usage:
//
//  WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
//  extraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(19, supplier.Code, product.NSVCode);
//  extraDrugDetail[0].NewContractNumber = "FS323D";
//  extraDrugDetail.Save();
//      
//	Modification History:
//	22Jul13 XN  24653 Written
//  03Feb14 XN  82433 Updates for SqlParameters
//  15Jul16 XN  126634 added NewEDIBarcode, LoadByDueSiteIDSupCodeAndEdiBarcode, 
//              LoadBySiteIdAndNSVCode, FindByIsStillDue, FindByActiveOrExpired 
//  24Jan17 XN  126634 Added FindLastByActiveOrExpired
//  11May18 GB  211742 Additional handling of expired contracts
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Represents a row in the WExtraDrugDetail table 15Jul16 XN 126634</summary>
    public class WExtraDrugDetailRow : BaseRow
    {
        public int WExtraDrugDetailID { get { return FieldToInt(RawRow["WExtraDrugDetailID"]).Value; } }

        public int LocationID_Site 
        { 
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; } 
            set { RawRow["LocationID_Site"] = IntToField(value);      } 
        }

        public string NSVCode
        { 
            get { return FieldToStr(RawRow["NSVCode"], true, string.Empty); } 
            set { RawRow["NSVCode"] = StrToField(value, false);             } 
        }

        /// <summary>Db code [SupplierCode]</summary>
        public string SupCode
        { 
            get { return FieldToStr(RawRow["SupplierCode"], true, string.Empty); } 
            set { RawRow["SupplierCode"] = StrToField(value, false);             } 
        }

        /// <summary>Date that then new contract comes into effect</summary>
        public DateTime? DateOfChange
        { 
            get { return FieldStrDateToDateTime(RawRow["DateOfChange"], DateType.DD_MM_YYYY);                           } 
            set { RawRow["DateOfChange"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DD_MM_YYYY, '/');  } 
        }

        /// <summary>Date that then contract ends (Db code [NewStopDate])</summary>
        public DateTime? StopDate
        { 
            get { return FieldStrDateToDateTime(RawRow["NewStopDate"], DateType.DD_MM_YYYY);                        } 
            set { RawRow["NewStopDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DD_MM_YYYY, '/');   } 
        }

        /// <summary>
        /// Has the contract ended
        /// </summary>
        public Boolean IsExpired
        {
            get
            {
                return
                    StopDate.HasValue
                    &&
                    StopDate <= DateTime.Today;
            }
        }

        /// <summary>
        /// Is the contract still active
        /// </summary>
        public Boolean IsActive
        {
            get
            {
                return IsExpired == false;
            }
        }

        /// <summary>
        /// Used by the overnight job to track last time the contract information was checked
        /// Db code [DateUpdated]
        /// </summary>
        public DateTime? DateUpdated_ByOvernighJob
        { 
            get { return FieldStrDateToDateTime(RawRow["DateUpdated"], DateType.DD_MM_YYYY); } 
            set { RawRow["DateUpdated"] = DateTimeToFieldStrDate(value, null, DateType.DD_MM_YYYY, '/');  }
        }

        /// <summary>New contract number to set (can be empty)</summary>
        public string NewContractNumber
        { 
            get { return FieldToStr(RawRow["NewContractNumber"], true, string.Empty); } 
            set { RawRow["NewContractNumber"] = StrToField(value, false);             } 
        }

        /// <summary>New contract price to set (can be null but normally not)</summary>
        public decimal? NewContractPrice
        { 
            get { return FieldStrToDecimal(RawRow["NewContractPrice"]);                                                                 } 
            set { RawRow["NewContractPrice"] = DecimalToFieldStr(value, WExtraDrugDetail.GetColumnInfo().NewContractPriceLength, true); } 
        }

        /// <summary>
        /// New supplier reference number (can be empty)
        /// Db field [NewSupRefNo]
        /// </summary>
        public string NewSupplierReferenceNumber
        { 
            get { return FieldToStr(RawRow["NewSupRefNo"], true, string.Empty); } 
            set { RawRow["NewSupRefNo"] = StrToField(value, false);              } 
        }

        /// <summary>New supplier tradename (can be empty)</summary>
        public string NewSupplierTradeName
        { 
            get { return FieldToStr(RawRow["NewSupplierTradeName"], true, string.Empty); }
            set { RawRow["NewSupplierTradeName"] = StrToField(value, false);              } 
        }

        /// <summary>If this supplier should become the default supplier</summary>
        public bool SetAsDefaultSupplier
        {
            get { return FieldToBoolean(RawRow["SetDefaultSupplier"], false).Value;   } 
            set { RawRow["SetDefaultSupplier"] = BooleanToField(value);               } 
        }

        /// <summary>Initials of person who last updated the record</summary>
        public string UpdatedBy 
        {
            get { return FieldToStr(RawRow["UpDatedBy"], true, string.Empty); } 
            set { RawRow["UpDatedBy"] = StrToField(value, false);              } 
        }

        /// <summary>Date field was last updated.</summary>
        public DateTime? DateEntered
        { 
            get { return FieldStrDateToDateTime(RawRow["DateEntered"], DateType.DD_MM_YYYY);                        } 
            set { RawRow["DateEntered"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DD_MM_YYYY, '/');   } 
        }

        /// <summary>Edi barcode 28Jun16 XN 126641</summary>
        public string  NewEDIBarcode
        {
            get { return FieldToStr(RawRow["NewEDIBarcode"], trimString: true, nullVal: null); }
            set { RawRow["NewEDIBarcode"] = StrToField(value, emptyStrAsNullVal: false);       }
        }
    }

    /// <summary>Represents the WExtraDrugDetail table column information</summary>
    public class WExtraDrugDetailColumnInfo : BaseColumnInfo
    {
        public WExtraDrugDetailColumnInfo() : base("WExtraDrugDetail") { }

        public int NSVCodeLength                    { get { return tableInfo.GetFieldLength("NSVCode");             } }
        public int SupCodeLength                    { get { return tableInfo.GetFieldLength("SupplierCode");        } }
        public int UpdatedByLength                  { get { return tableInfo.GetFieldLength("UpDatedBy");           } }
        public int NewContractNumberLength          { get { return tableInfo.GetFieldLength("NewContractNumber");   } }
        public int NewContractPriceLength           { get { return tableInfo.GetFieldLength("NewContractPrice");    } }
        public int NewSupplierReferenceNumberLength { get { return tableInfo.GetFieldLength("NewSupRefNo");         } }
        public int NewSupplierTradeNameNumberLength { get { return tableInfo.GetFieldLength("NewSupplierTradeName");} }
        public int NewEDIBarcodeLength              { get { return tableInfo.GetFieldLength("NewEDIBarcode");       } } // 28Jun16 XN 126641
    }

    /// <summary>Represents WExtraDrugDetail table</summary>
    public class WExtraDrugDetail : BaseTable2<WExtraDrugDetailRow, WExtraDrugDetailColumnInfo>
    {
        public WExtraDrugDetail() : base("WExtraDrugDetail") { }

        /// <summary>Load the WExtraDrugDetail by ID</summary>
        public void LoadByID(int wextraDrugDetailID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@WExtraDrugDetailID",  wextraDrugDetailID);
            this.LoadBySP("pWExtraDrugDetailByID", parameters);
        }

        /// <summary>Loads all records by site ID, NSVCode and supplier code (should only be one)</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSVCode</param>
        /// <param name="supCode">Supplier code</param>
        /// <param name="append">If appending the data</param>
        public void LoadBySiteIDNSVCodeAndSupCode(int siteID, string NSVCode, string supCode, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SiteID",  siteID );
            parameters.Add("@SupCode", supCode);
            parameters.Add("@NSVCode", NSVCode);
            this.LoadBySP(append, "pWExtraDrugDetailBySiteIDNSVCodeAndSupCode", parameters);
        }

        /// <summary>Loads all records by NSVCode and supplier code</summary>
        /// <param name="NSVCode">NSVCode</param>
        /// <param name="supCode">Supplier code</param>
        public void LoadByNSVCodeAndSupCode(string NSVCode, string supCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SupCode", supCode);
            parameters.Add("@NSVCode", NSVCode);
            this.LoadBySP("pWExtraDrugDetailByNSVCodeAndSupCode", parameters);
        }

        /// <summary>Loads all records by supcode, edi link code, start date, and stop date 15Jul16 XN 126634</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="supCode">Supplier code</param>
        /// <param name="ediBarcode">Edi Barcode</param>
        public void LoadByDueSiteIDSupCodeAndEdiBarcode(int siteID, string supCode, string ediBarcode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SiteId",     siteID    );
            parameters.Add("@SupCode",    supCode   );
            parameters.Add("@EdiBarcode", ediBarcode);
            this.LoadBySP("pWExtraDrugDetailByDueSiteIDSupCodeAndEdiBarcode", parameters);
        }

        /// <summary>Loads all records by SiteId, NSVCode and from 15Jul16 XN 126634</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSVCode</param>
        public void LoadBySiteIdAndNSVCode(int siteId, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SiteId",   siteId   );
            parameters.Add("@NSVCode",  NSVCode  );
            this.LoadBySP("pWExtraDrugDetailBySiteIDAndNSVCode", parameters);
        }

        /// <summary>Returns first record loaded by site ID, NSVCode and supplier code (else null if these is none)</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSVCode</param>
        /// <param name="supCode">Supplier code</param>
        public static WExtraDrugDetailRow GetBySiteIDNSVCodeAndSupCode(int siteID, string NSVCode, string supCode)
        {
            WExtraDrugDetail wextraDrugDetail = new WExtraDrugDetail();
            wextraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(siteID, NSVCode, supCode);
            return wextraDrugDetail.FirstOrDefault();
        }
    }

    /// <summary>Provides extension methods to for IEnumerable{WExtraDrugDetailRow}</summary>
    public static class WExtraDrugDetailExtensions
    {
        /// <summary>Returns all rows that contains this siteID</summary>
        public static IEnumerable<WExtraDrugDetailRow> FindBySiteID(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail, int siteID)
        {
            return wextraDrugDetail.Where(c => c.LocationID_Site == siteID);
        }

        /// <summary>
        /// Returns latest contract whose stop date is still active 
        /// (DateUpdated filled in and stop date has not been reached)
        /// </summary>
        public static WExtraDrugDetailRow FindByIsActive(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail)
        {
            DateTime today = DateTime.Today;

            return (from c in wextraDrugDetail
                    where c.DateUpdated_ByOvernighJob != null
                          && 
                          c.IsActive
                    orderby c.DateUpdated_ByOvernighJob descending, c.WExtraDrugDetailID descending
                    select c).FirstOrDefault();
        }


        /// <summary>
        /// Returns first contract detail is still due to be implemented 
        /// (DateUpdated not filled in and stop date has not been reached)
        /// </summary>
        public static WExtraDrugDetailRow FindFirstByIsStillDue(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail)
        {
            DateTime today = DateTime.Today;

            return (from c in wextraDrugDetail
                    where c.DateUpdated_ByOvernighJob == null
                          && 
                          c.IsActive
                    orderby c.DateOfChange, c.WExtraDrugDetailID
                    select c).FirstOrDefault();
        }

        /// <summary>Returns all contracts that are still due to be implemented 15Jul16 XN 126634</summary>
        /// <param name="wextraDrugDetail">list of contracts</param>
        /// <returns>contract still due</returns>
        public static IEnumerable<WExtraDrugDetailRow> FindByIsStillDue(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail)
        {            
            DateTime today = DateTime.Today;
            return  from c in wextraDrugDetail
                    where c.DateUpdated_ByOvernighJob == null
                          && 
                          c.IsActive
                    select c;
        }

        /// <summary>Returns all currently active and expired contracts 15Jul16 XN 126634</summary>
        /// <param name="wextraDrugDetail">list of contracts</param>
        /// <returns>expired contracts</returns>
        public static  IEnumerable<WExtraDrugDetailRow> FindByActiveOrExpired(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail)
        {
            DateTime today = DateTime.Today;
            return wextraDrugDetail.Where(c => c.DateUpdated_ByOvernighJob != null || c.IsExpired);
        }

        /// <summary>Returns current active or latest expired contact 24Jan17 XN 126634</summary>
        /// <param name="wextraDrugDetail">list of contracts</param>
        /// <returns>active or expired contracts</returns>
        public static WExtraDrugDetailRow FindLastByActiveOrExpired(this IEnumerable<WExtraDrugDetailRow> wextraDrugDetail)
        {
            DateTime today = DateTime.Today;
            return (from c in wextraDrugDetail
                    where c.DateUpdated_ByOvernighJob != null || c.IsExpired
                    orderby c.DateUpdated_ByOvernighJob descending, c.WExtraDrugDetailID descending
                    select c).FirstOrDefault();
        }
    }
}
