//===========================================================================
//
//							WWardProductList.cs
//
//  This class represents the WWardProductList table.  
//  This replaces the WSupplier type W items.
//
//  Only supports reading, updating, and inserting from table.
//  Saveing will save changes to the WPharmacyLog (under WWardProductList)
//  where the thread is the WWardProductListID.
//
//  Usage:
//
//  WWardProductList list = WWardProductList();
//  list.LoadByWWardProductListID(listID);
//  list.Save();
//      
//	Modification History:
//	17Dec14 XN  Written
//  31Dec14 XN  Changed LoadBySite to LoadBySiteAndInUse 89292
//  20Jan15 XN  Update Save to use new WPharmacyLogType 26734
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.wardstocklistlayer
{
    /// <summary>Represents a record in the WWardProductList table</summary>
    public class WWardProductListRow : BaseRow
    {
		public int WWardProductListID 
        { 
            get { return FieldToInt(RawRow["WWardProductListID"]).Value; } 
            internal set 
            {  
                RawRow.Table.Columns["WWardProductListID"].ReadOnly = false;
                RawRow["WWardProductListID"] = IntToField(value); 
                RawRow.Table.Columns["WWardProductListID"].ReadOnly = true;
            }
        }

        public int? SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]);  } 
            set { RawRow["SiteID"] = IntToField(value); } 
        }

        public string Code
        {
            get { return FieldToStr(RawRow["Code"], true, string.Empty);  } 
            set { RawRow["Code"] = StrToField(value);                     } 
        }

        /// <summary>Short name description</summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"], false, string.Empty);  } 
            set { RawRow["Description"] = StrToField(value);                      } 
        }

        public string FullName
        {
            get { return FieldToStr(RawRow["FullName"], false, string.Empty);   } 
            set { RawRow["FullName"] = StrToField(value);                       } 
        }

        public bool PrintDeliveryNote
        {
            get { return FieldToBoolean(RawRow["PrintDeliveryNote"]).Value;  } 
            set { RawRow["PrintDeliveryNote"] = BooleanToField(value);       } 
        }

        public bool PrintPickTicket
        {
            get { return FieldToBoolean(RawRow["PrintPickTicket"]).Value;  } 
            set { RawRow["PrintPickTicket"] = BooleanToField(value);       } 
        }

        /// <summary>Associated pharmacy ward (WCustomer table)</summary>
        public int? WCustomerID
        {
            get { return FieldToInt(RawRow["WCustomerID"]);  } 
            set { RawRow["WCustomerID"] = IntToField(value); } 
        }

        public bool VisibleToWard
        {
            get { return FieldToBoolean(RawRow["VisibleToWard"]).Value;  } 
            set { RawRow["VisibleToWard"] = BooleanToField(value);       } 
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value;  } 
            set { RawRow["InUse"] = BooleanToField(value);       } 
        }

        public int SessionLock
        {
            get { return FieldToInt(RawRow["SessionLock"]).Value;  } 
            set { RawRow["SessionLock"] = IntToField(value);       } 
        }

        public WCustomerRow GetCustomer()
        {
            return this.WCustomerID == null ? null : WCustomer.GetByID(this.WCustomerID.Value);
        }

        /// <summary>Returns Code - Description</summary>
        public override string ToString()
        {
            return this.Code.TrimEnd() + " - " + this.Description.TrimEnd();
        }
    }

    /// <summary>Provides column information about the WWardProductList table</summary>
    public class WWardProductListColumnInfo : BaseColumnInfo
    {
        public WWardProductListColumnInfo() : base ("WWardProductList") {  }

        public int CodeLength        { get { return FindColumnByName("Code"       ).Length; } }
        public int DescriptionLength { get { return FindColumnByName("Description").Length; } }
        public int FullNameLength    { get { return FindColumnByName("FullName"   ).Length; } }
    }

    /// <summary>Represent the WWardProductList table</summary>
    public class WWardProductList : BaseTable2<WWardProductListRow, WWardProductListColumnInfo>
    {
        public WWardProductList() : base ("WWardProductList") {  }

        /// <summary>
        /// Sets 
        ///     WWardProductListID   = -1    
        ///     PrintPickTicket      = false
        ///     PrintDeliveryNote    = false
        ///     InUse                = true
        ///     VisibleToWard        = true
        ///     SiteID               = current site id
        ///     SessionLock          = 0;
        /// </summary>
        public override WWardProductListRow Add()
        {
            WWardProductListRow newRow = base.Add();
            newRow.WWardProductListID   = -1;
            newRow.PrintPickTicket      = false;
            newRow.PrintDeliveryNote    = false;
            newRow.InUse                = false;
            newRow.VisibleToWard        = true;
            newRow.SiteID               = SessionInfo.HasSite ? SessionInfo.SiteID : (int?)null;
            newRow.SessionLock          = 0;
            return newRow;
        }

        /// <summary>Loads list with specified ID</summary>
        public void LoadByID(int wwardProductListID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WWardProductListID", wwardProductListID);
            LoadBySP("pWWardProductListByID", parameters);
        }

        /// <summary>Loads all lists with specified IDs</summary>
        public void LoadByIDs(IEnumerable<int> wardProductListIDs)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WWardProductListIDs", wardProductListIDs.ToCSVString(","));
            LoadBySP("pWWardProductListByIDs", parameters);
        }

        /// <summary>Load list by Site, Code and if in use (optional) should be single site</summary>
        public void LoadBySiteCodeAndInUse(int? siteID, string code, bool? inUse)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", siteID);
            parameters.Add("Code",   code  );
            parameters.Add("inUse",  inUse );
            LoadBySP("pWWardProductListBySiteCodeAndInUse", parameters);            
        }

        /// <summary>Loads all in-use lists that contain a drug with the NSVCode (for this site or global lists)</summary>
        public void LoadBySiteAndNSVCode(int siteID, string NSVCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", siteID);
            parameters.Add("NSVCode",NSVCode);
            LoadBySP("pWWardProductListBySiteAndNSVCode", parameters);            
        }

        /// <summary>Loads all lists for this site or global lists</summary>
        public void LoadBySiteAndInUse(int siteID, bool? inUse = true)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", siteID);
            parameters.Add("InUse",  inUse );
            LoadBySP("pWWardProductListBySiteAndInUse", parameters);            
        }

        /// <summary>Returns site code and if in use</summary>
        public static WWardProductListRow GetBySiteCodeAndInUse(int? siteID, string code, bool? inUse)
        {
            WWardProductList list = new WWardProductList();
            list.LoadBySiteCodeAndInUse(siteID, code, inUse);
            return list.FirstOrDefault();
        }

        /// <summary>Returns list by ID or null if no matching list</summary>
        /// <param name="WWardProductListID">ID of list</param>
        /// <returns>list by ID or null if no matching list</returns>
        public static WWardProductListRow GetByID(int WWardProductListID)
        {
            WWardProductList list = new WWardProductList();
            list.LoadByID(WWardProductListID);
            return list.FirstOrDefault();
        }

        /// <summary>Extends the base class so that changes are saved to the WPharmacyLog as WWardProductList</summary>
        public override void Save()
        {
            // Create pharmacy log
            WPharmacyLog log = new WPharmacyLog();
            //log.AddRange(this, "WWardProductList", r => r.Code, r => r.SiteID);   20Jan15 XN 26734           
            log.AddRange(this, WPharmacyLogType.WWardProductList, r => r.Code, r => r.SiteID);

            // And save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                base.Save();

                // Update the thread value from the DBID
                log.UpdateDBID();
                log.ToList().ForEach(l => l.Thread = l.DBID);

                // Save log
                log.Save();

                trans.Commit();
            }
        }
    }
}
