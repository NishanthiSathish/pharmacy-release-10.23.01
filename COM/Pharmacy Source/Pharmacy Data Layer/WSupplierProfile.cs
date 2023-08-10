//===========================================================================
//
//							  WSupplierProfile.cs
//
//  Provides access to WSupplierProfile table.
//
//  WSupplierProfile table provides information on a suppliers products.
//
//  A WSupplierProfile row is filtered by site, supplier, and NSV code.
//
//  Unlike other pharmacy tables WSupplierProfile does not support row locking
//  instead when making updates the associated product stock row should be locked.
//
//  SP for this object should return all fields from the WSupplierProfile table, 
//  and a links in the following extra fields
//      WSupplier.Name as supname
//      WSupplier.SupplierType as SupplierType
//
//  Only supports reading, inserting, and updating
//  When updating the table does not have a lock itself but should use the lock on product stock
//  Saving a delete will also delete the row from the WExtraDrugDetail
//  Saving a row can update the drug modified date (if profile is primary) 
//  Saving can write changes to the WPharmacyLog
//
//	Modification History:
//	15Apr09 XN  Written
//  02Feb10 XN  Fixed problem with supplier name being null sometimes
//  11Jan13 XN  52255 Only display supplier tradename in F4 not the SiteProductData tradename
//  06Mar13 XN  58233 Use correct field to get tradename (SupplierTradename instead of Tradename)
//  04Apr13 XN  Removed updating pk in UpdateRow
//  24Jul13 XN  Moved to BaseTable2 and added LoadByWSupplierProfileID method 24653
//  19Dec13 XN  78339 Made LeadTimeInDays nullable.
//              Made ReorderLevelInIssueUnits, ReOrderQuantityInPacks, Tradname Obsolete
//              Forced pkColumnName as not set in DB
//  29Jan14 XN  82431 Updated Save to prevented crash when nothing was loaded
//  03Feb14 XN  82433 Added helper method ReorderPackSizeAsFormattedString
//  18May15 XN  117528 Added IsPrimarySupplier, add Save to save to log, and mod dates
//  18Jul16 XN  126634 Added EdiBarcode
//  10Oct16 XN  164388 Added LoadByNSVCode
//  10Jan16 XN  164388 Prevent duplicates supplier code on barcode editor
//===========================================================================
 
namespace ascribe.pharmacy.pharmacydatalayer
{
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    /// <summary>Represents a record in the WSupplierProfile table</summary>
    public class WSupplierProfileRow : BaseRow
    {
        public int WSupplierProfileID 
        { 
            get { return FieldToInt(RawRow["WSupplierProfileID"]).Value;    }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["NSVCode"], false, string.Empty); }
            set { RawRow["NSVCode"] = StrToField(value);                     }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value);      }
        }

        public string SupplierCode
        {
            //get { return FieldToStr(RawRow["SupCode"], false, string.Empty); }    164388 Prevent duplicates supplier code on barcode editor XN 10Jan16  
            get { return FieldToStr(RawRow["SupCode"], true, string.Empty); }
            set { RawRow["SupCode"] = StrToField(value);                    }
        }

        /// <summary>Linked in field from supplier table WSupplier.Name</summary>
        public string SupplierName
        {
            get { return FieldToStr(RawRow["supname"], true, string.Empty); }
        }

        /// <summary>Linked in field from supplier table WSupplier.SupplierType</summary>
        public SupplierType SupplierType
        {
            get { return FieldToEnumByDBCode<SupplierType>(RawRow["SupplierType"]); }
        }

        /// <summary>DB string field [ContNo]</summary>
        public string ContractNumber
        {
            get { return FieldToStr(RawRow["ContNo"], true, string.Empty); }
            set { RawRow["ContNo"] = StrToField(value);                     }
        }

        /// <summary>
        /// Outer pack size
        /// DB string field [ReorderPckSize]
        /// </summary>
        public decimal? ReorderPackSize
        {
            get { return FieldStrToDecimal(RawRow["ReorderPckSize"]);   }
            set { RawRow["ReorderPckSize"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ReorderPackSizeLength, true); }
        }

        /// <summary>DB string field [ContPrice]</summary>
        public decimal? ContractPrice
        {
            get { return FieldStrToDecimal(RawRow["ContPrice"]);   }
            set { RawRow["ContPrice"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ContractPriceLength, true); }
        }

        /// <summary>
        /// DB string field [LeadTime]
        /// 19Dec13 XN  78339 Made nullable
        /// </summary>
        public decimal? LeadTimeInDays
        {
            get { return FieldStrToDecimal(RawRow["LeadTime"]);  }
            set { RawRow["LeadTime"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().LeadTimeInDaysLength, true); }
        }

        /// <summary>Name used by the supplier for the drug</summary>
        public string SupplierTradename
        {
            get 
            {
                return FieldToStr(RawRow["SupplierTradeName"], true, string.Empty);

                //return FieldToStr(RawRow["TradeName"], true, string.Empty);   06Mar13 XN 58233 Use correct field to get tradename
                // 11Jan13 XN  52255 Only display supplier tradename in F4 not the SiteProductData tradename
                //string tradename = FieldToStr(RawRow["Tradename"], true);
                //if (string.IsNullOrEmpty(tradename))
                //    tradename = FieldToStr(RawRow["SiteProductData_Tradename"], true); 

                //return tradename;  
            }
//            set { RawRow["TradeName"] = StrToField(value);     }              06Mar13 XN 58233 Use correct field to get tradename
            set { RawRow["SupplierTradeName"] = StrToField(value);                      }
        }

        /// <summary>
        /// Name used by the supplier for the drug
        /// DB string field [SuppRefNo]
        /// </summary>
        public string SupplierReferenceNumber
        {
            //get { return FieldToStr(RawRow["SuppRefNo"], false, string.Empty);  } 22Aug14 XN Added trim so it looks correct in manual contract editor
            get { return FieldToStr(RawRow["SuppRefNo"], true, string.Empty);  }
            set { RawRow["SuppRefNo"] = StrToField(value);                      }
        }

        /// <summary>
        /// DB double field [sisListPrice]
        /// Represents the price of the drug, when it was last received from the supplier.
        /// Price is per pack, excluding vat, and in pence
        /// </summary>
        public decimal? LastReceivedPriceExVatPerPack
        {
            get { return FieldToDecimal(RawRow["sisListPrice"]);      }
            set { RawRow["sisListPrice"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().LastReceivedPriceExVatPerPackLength); }
        }

        /// <summary>
        /// DB double field [LastReconcilePrice]
        /// Price is per pack, excluding vat, and in pence
        /// </summary>
        public decimal? LastReconcilePriceExVatPerPack
        {
            get { return FieldToDecimal(RawRow["LastReconcilePrice"]); }
            set { RawRow["LastReconcilePrice"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().LastReconcilePriceExVatPerPackLength, true); }
        }

        /// <summary>
        /// DB double field [VatRate]
        /// despite the db saying vat rete it is actually a vat code.
        /// </summary>
        public int? VATCode
        {
            get { return FieldToInt(RawRow["VatRate"]);  }
            set { RawRow["VatRate"] = IntToField(value); }
        }

        /// <summary>
        /// Converts VATCode to a rate (uses the druges site id for the conversion).
        /// </summary>
        public decimal? VATRate { get { return PharmacyConverters.VatCodeToRate(SiteID, VATCode); } }

        // The following db fields are no longer used
        // PrimarySup
        // reorderlvl
        // reorderQty
        // Tradename
        [Obsolete("Use field in ProductStock")] internal decimal? ReorderLevelInIssueUnits { set { RawRow["ReorderLvl"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ReorderLevelLength          ); } }  // 19Dec13 XN  78339 made Obsolete
        [Obsolete("Use field in ProductStock")] internal decimal? ReOrderQuantityInPacks   { set { RawRow["reorderqty"] = DecimalToFieldStr(value, WSupplierProfile.GetColumnInfo().ReOrderQuantityInPacksLength); } }  // 19Dec13 XN  78339 made Obsolete
        //[Obsolete("Use field in ProductStock")] internal string   Tradename                { set { RawRow["Tradename" ] = StrToField(value); } }      100212 15Oct14 XN Removed WSupplierProfile.Tradename from DB                                                                      // 19Dec13 XN  78339 made Obsolete

        /// <summary>
        /// This is the barcode for the product used by the supplier when sending EDI orders
        /// This barcode should always exist in the list of alternate barcodes
        /// 18Jul16 XN  126634
        /// </summary>
        public string EdiBarcode
        {
            get { return FieldToStr(RawRow["EdiBarcode"], trimString: true, nullVal: string.Empty);  }
            set { RawRow["EdiBarcode"] = StrToField(value, emptyStrAsNullVal: true);                 }
        }

        /// <summary>
        /// Displays the reorder pack size as formatted string 
        /// if conversionFactorPackToIssueUnits = 1
        ///     {reorder pack size} {printform V}
        /// else
        ///     {reorder pack size} x {conversion factor} {printform V}
        /// </summary>
        public string ReorderPackSizeAsFormattedString(int conversionFactorPackToIssueUnits, string printFormV)
        {
            decimal reorderPackSize = this.ReorderPackSize ?? 1;
            if (conversionFactorPackToIssueUnits == 1)
                return string.Format("{0} {1}", reorderPackSize, printFormV);
            else
                return string.Format("{0} x {1} {2}", reorderPackSize.ToString(WProduct.GetColumnInfo().ReorderPackSizeLength), conversionFactorPackToIssueUnits, printFormV);
        }

        /// <summary>
        /// Returns if the supplier profile is the primary supplier for the drug
        /// As calls DB might be bit slow to test large number of profiles
        /// 18May15 XN 117528
        /// </summary>
        /// <returns>If primary</returns>
        public bool IsPrimarySupplier()
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("NSVCode",  this.NSVCode);
            parameters.Add("SiteID",   this.SiteID);
            parameters.Add("SupCode",  this.SupplierCode);
            return Database.ExecuteSPReturnValue<bool>("pWSupplierProfileIsPrimary", parameters);
        }
    }
    
    /// <summary>Provides column information about the WSupplierProfile table</summary>
    public class WSupplierProfilePricesColumnInfo : BaseColumnInfo
    {
        public WSupplierProfilePricesColumnInfo() : base("WSupplierProfile") { }

        public int LastReceivedPriceExVatPerPackLength  { get { return base.tableInfo.GetFieldLength("sisListPrice");       } }
        public int LastReconcilePriceExVatPerPackLength { get { return base.tableInfo.GetFieldLength("LastReconcilePrice"); } }
        public int SupplierReferenceNumberLength        { get { return base.tableInfo.GetFieldLength("SuppRefNo");          } }      
        public int SupplierTradenameLength              { get { return base.tableInfo.GetFieldLength("Tradename");          } }      
        public int LeadTimeInDaysLength                 { get { return base.tableInfo.GetFieldLength("leadtime");           } }          
        public int ContractPriceLength                  { get { return base.tableInfo.GetFieldLength("ContPrice");          } }          
        public int ReorderPackSizeLength                { get { return base.tableInfo.GetFieldLength("ReorderPckSize");     } }          
        public int ContractNumberLength                 { get { return base.tableInfo.GetFieldLength("ContNo");             } }          

        [Obsolete("Use field in ProductStock")] internal int ReorderLevelLength                   { get { return base.tableInfo.GetFieldLength("ReorderLvl");         } }   // 19Dec13 XN  78339 made Obsolete
        [Obsolete("Use field in ProductStock")] internal int ReOrderQuantityInPacksLength         { get { return base.tableInfo.GetFieldLength("reorderqty");         } }   // 19Dec13 XN  78339 made Obsolete
    }

    /// <summary>Represent the WSupplierProfile table</summary>
    public class WSupplierProfile : BaseTable2<WSupplierProfileRow, WSupplierProfilePricesColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WSupplierProfile() : base("WSupplierProfile") 
        { 
            this.pkColumnName = "WSupplierProfileID";   // Not set as pk in db 19Dec13 XN  78339
        }

        /// <summary>
        /// Loads suppler profile by ID 
        /// 24Jul13 XN 24653
        /// 19Dec13 XN 78339 - Added append option
        /// </summary>
        public void LoadByWSupplierProfileID(int WSupplierProfileID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@WSupplierProfileID", WSupplierProfileID));
            this.LoadBySP(append, "pWSupplierProfileByWSupplierProfileID", parameters);
        }

        /// <summary>
        /// Loads all the supplier profiles for a specific drug
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSVCode</param>
        public void LoadBySiteIDAndNSVCode(int siteID, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@SiteID",           siteID               ));
            parameters.Add(new SqlParameter("@NSVCode",          NSVCode              ));
            this.LoadBySP("pWSupplierProfilebyNSVCode", parameters);
        }

        /// <summary>
        /// Loads a supplier profiles for a specific dug and supplier 
        /// </summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="supplierCode">Supplier code</param>
        /// <param name="NSVCode">NSVCode</param>
        public void LoadBySiteIDSupplierAndNSVCode(int siteID, string supplierCode, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@SiteID",           siteID               ));
            parameters.Add(new SqlParameter("@NSVCode",          NSVCode              ));
            parameters.Add(new SqlParameter("@Supcode",          supplierCode         ));
            this.LoadBySP("pWSupplierProfilebyNSVCodeandSupCode", parameters);
        }

        /// <summary>
        /// Load all the supplier profiles (across the trust) for a specific supplier or drug
        /// </summary>
        /// <param name="SupCode"></param>
        /// <param name="NSVCode"></param>
        public void LoadBySupplierAndNSVCode(string SupCode, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@Supcode", SupCode));
            parameters.Add(new SqlParameter("@NSVCode", NSVCode));
            this.LoadBySP("pWSupplierProfilebyNSVCodeandSupCodeOnly", parameters);
        }

        /// <summary>Load supplier profiles by site id, supplier code, and edi barcode 21Jul16 XN 126634</summary>
        /// <param name="siteID">site id</param>
        /// <param name="supplierCode">supplier code</param>
        /// <param name="ediBarcode">EDI barcode</param>
        /// <param name="append">if appending</param>
        public void LoadBySiteIDSupplierAndEdiBarcode(int siteID, string supCode, string ediBarcode, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",      siteID      ));
            parameters.Add(new SqlParameter("@Supcode",     supCode     ));
            parameters.Add(new SqlParameter("@EdiBarocde",  ediBarcode  ));
            this.LoadBySP(append, "pWSupplierProfilebySiteIDSupplierAndEdiBarcode", parameters);
        }

        /// <summary>Load supplier profiles by NSV Code 164388 10Oct16 XN</summary>
        /// <param name="NSVCode">NSV code</param>
        public void LoadByNSVCode(string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@NSVCode", NSVCode));
            this.LoadBySP("pWSupplierProfilebyNSVCodeOnly", parameters);
        }

        /// <summary>
        /// Overrides base class to 
        ///     Delete extra drug detail row if supplier deleted
        ///     update the drug modified date if profile is primary (won't lock product stock)
        ///     write to the WPharmacyLog 
        /// 18May15 XN 117528
        /// </summary>
        /// <param name="updateModifiedDate">If the drug modified date is updated for primary suppliers</param>
        /// <param name="saveToPharmacyLog">If any updates are saved to the WPharmacyLog</param>
        public void Save(bool updateModifiedDate, bool saveToPharmacyLog)
        {
            DateTime now = DateTime.Now;

            // Remove all extra drug detail
            WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
            if (this.DeletedItemsTable != null) // Prevent crash if nothing was loaded 29Jan14 XN 82431
            {
                foreach (DataRow row in this.DeletedItemsTable.Rows)
                {
                    int     locationID_Site = (int)   row["LocationID_Site", DataRowVersion.Original];
                    string  NSVCode         = (string)row["NSVCode",         DataRowVersion.Original];
                    string  SupCode         = (string)row["SupCode",         DataRowVersion.Original];
                    extraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(locationID_Site, NSVCode, SupCode, true);
                }
                extraDrugDetail.RemoveAll();
            }

            // Get rows that have changed and are the primary supplier 18May15 XN 117528
            List<WSupplierProfileRow> rowsToUpdateModifiedDate = new List<WSupplierProfileRow>();
            if (updateModifiedDate || saveToPharmacyLog)
            {
                rowsToUpdateModifiedDate = this.Where(r => r.HasDataChanged() && r.IsPrimarySupplier()).ToList();
            }

            // Add the updates to the log 18May15 XN 117528
            WPharmacyLog log = new WPharmacyLog();
            if (saveToPharmacyLog)
            {
                log.AddRange(   
                              this,
                              WPharmacyLogType.LabUtils,
                              r => string.Format("{0} {1}", r.SupplierCode, rowsToUpdateModifiedDate.Any(x => x.SiteID == r.SiteID && x.NSVCode == r.NSVCode && x.SupplierCode.EqualsNoCaseTrimEnd(r.SupplierCode)) ? "(primary)" : "(alternate)"),
                              r => r.SiteID,
                              r => r.NSVCode,
                              null,
                              new string[0]);
                
                // As linked into drug data need to specify that this is a supplier profile change
                log.ToList().ForEach(l => l.Detail = "SUPPLIER PROFILE\n" + l.Detail);
            }

            // Load in product stock rows to update modified data 18May15 XN 117528
            ProductStock productStock = new ProductStock();
            if (updateModifiedDate)
            {
                foreach (var r in rowsToUpdateModifiedDate)
                {
                    productStock.LoadBySiteIDAndNSVCode(r.NSVCode, r.SiteID, true);
                    productStock.FindBySiteIDAndNSVCode(r.SiteID, r.NSVCode).UpdateModifiedDetails(now);
                }
            }

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                extraDrugDetail.Save();
                base.Save();
                productStock.Save();

                // Update audit log 18May15 XN 117528
                log.UpdateDBID();
                log.Save();

                trans.Commit();
            }
        }

        /// <summary>returns supplier profiles for a specific dug and supplier (or null if does not exist)</summary>
        /// <param name="siteID">Site ID</param>
        /// <param name="supplierCode">Supplier code</param>
        /// <param name="NSVCode">NSVCode</param>
        public static WSupplierProfileRow GetBySiteIDSupplierAndNSVCode(int siteID, string supplierCode, string NSVCode)
        {
            WSupplierProfile profile = new WSupplierProfile();
            profile.LoadBySiteIDSupplierAndNSVCode(siteID, supplierCode, NSVCode);
            return profile.FirstOrDefault();
        }

        /// <summary>returns suppler profile by ID or null if it does not exist 24Jul13 XN 24653</summary>
        public static WSupplierProfileRow GetByWSupplierProfileID(int WSupplierProfileID)
        {
            WSupplierProfile profile = new WSupplierProfile();
            profile.LoadByWSupplierProfileID(WSupplierProfileID);
            return profile.FirstOrDefault();
        }
    }
}
