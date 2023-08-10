// ===========================================================================
//
//                          WWardProductListLine.cs
//
//  This class represents the WWardProductListLine table.  
//  Holds details on individual lines on a WWardProductList
//  This replaces the WWardStockList table for.
//
//  SPs for this object should return all fields from the WWardProductListLine table, and a 
//  links in the following extra fields
//      WRequis is linked via WWardProductListLineID and Status='5' or '6' and ToFollow=1   as HasToFollow
//      WRequis.RequisitionNum                                                              as RequisitionNum_WRequis
//      WRequis.OrdDate                                                                     as OrdDate_WRequis
//      WRequis.OrdTime                                                                     as OrdTime_WRequis
//      WRequis.Outstanding                                                                 as Outstanding_WRequis
//      WRequis.QtyOrdered                                                                  as QtyOrdered_WRequis
//      SiteProductData.StoresDescription or if null spd.LabelDescription                   as Description_SiteProductData,
//      SiteProductData.convfact                                                            as PackSize_SiteProductData,
//      SiteProductData.PrintFormV                                                          as IssueUnits_SiteProductData   
//  where WRequis is linked via WWardProductListLineID and Status='5' or '6' order by ToFollow desc and WRequestID desc top item
//
//  Lines can be LineType = WWardProductListLineType.Title or WWardProductListLineType.Drug
//  
//  NOTE that any deletes of a drug line will be a logical delete
//  of the line (as need to keep for reporting purposes)
//  However this class will never reload the line.
//  
//  Only supports reading, updating, and inserting from table.
//  Saving will save changes to the WPharmacyLog (under WWardProductListLines)
//  where the thread is the WWardProductListID.
//
//  Usage:
//
//  WWardProductListLine lines = WWardProductListLine WSupplier2();
//  lines.LoadByWWardProductListID(siteID, listID);
//  lines.Save();
//      
//  Modification History:
//  24Nov14 XN  Written
//  20Jan15 XN  Update Save to use new WPharmacyLogType 26734
//  25Mar15 XN  Ensured that the InUse field is copied from WProduct when adding
//  08May15 XN  Update WWardProductListLineRow for changes in BaseRow (change field from static to instance for error handling improvements)
//  11Oct16 XN  164662\182087 WSL does not handle null Description
//  02Nov16 XN  Updated Description to return empty string if null to prevent crash
//              Updated ToString as don't need to test null
// ===========================================================================
namespace ascribe.pharmacy.wardstocklistlayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using _Shared;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>If the WWardProductListLine is a Title or Drug line</summary>
    public enum WWardProductListLineType
    {
        Title,
        Drug
    }

    /// <summary>Represents a record in the WWardProductListLine table</summary>
    public class WWardProductListLineRow : BaseRow
    {
        public int WWardProductListLineID
        {
            get { return FieldToInt(RawRow["WWardProductListLineID"]) ?? -1; } 
            internal set 
            { 
                RawRow.Table.Columns["WWardProductListLineID"].ReadOnly = false;
                RawRow["WWardProductListLineID"] = IntToField(value); 
                RawRow.Table.Columns["WWardProductListLineID"].ReadOnly = true;
            }
        }

        public int WWardProductListID
        {
            get { return FieldToInt(RawRow["WWardProductListID"]).Value; } 
            set { RawRow["WWardProductListID"] = IntToField(value);      }
        }

        /// <summary>Line description (can be null on site so defaults to product description)</summary>
        public string Description
        {
            //get { return FieldToStr(RawRow["Description"], true, null); } 164662\182087 XN 11Oct16 
            get { return FieldToStr(RawRow["Description"], true, this.Description_SiteProductData); } 
            set { RawRow["Description"] = StrToField(value);            } 
        }

        /// <summary>Value from siteProductData table (replaces ! with space)</summary>
        public string Description_SiteProductData
        {
            //get { return FieldToStr(RawRow["Description_SiteProductData"], true, string.Empty).Replace('!', ' '); }  164662\182087 XN 11Oct16 
            get { return FieldToStr(RawRow["Description_SiteProductData"], true, string.Empty).Replace('!', ' '); } 
        }

        /// <summary>DB Field ScreenPosn</summary>
        public int DisplayIndex
        {
            get { return FieldToInt(RawRow["ScreenPosn"]) ?? -1; } 
            set { RawRow["ScreenPosn"] = IntToField(value);      }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["NSVcode"]);     } 
            set { RawRow["NSVcode"] = StrToField(value);    } 
        }

        /// <summary>
        /// Might be null if should be using PackSize_SiteProductData
        /// Use GetConversionFactorPackToIssueUnits to get the correct packsize
        /// DB field [PackSize]
        /// </summary>
        public int? ConversionFactorPackToIssueUnits
        {
            get { return FieldToInt(RawRow["PackSize"]);    } 
            set { RawRow["PackSize"] = IntToField(value);   } 
        }

        /// <summary>
        /// Value from siteProductData table
        /// DB field [PackSize_SiteProductData]
        /// </summary>
        public int? ConversionFactorPackToIssueUnits_SiteProductData
        {
            get { return FieldToInt(RawRow["PackSize_SiteProductData"]);  } 
        }

        /// <summary>Value from siteProductData table</summary>
        public string IssueUnits_SiteProductData
        {
            get { return FieldToStr(RawRow["IssueUnits_SiteProductData"]);  } 
        }

        /// <summary>If product is in use</summary>
        public bool InUse_ProductStock
        {
            get { return this.FieldToBoolean(this.RawRow["InUse_ProductStock"]) ?? false;  } 
        }

        public PrintLabelType PrintLabel
        {
            get { return FieldToEnumByDBCode<PrintLabelType>(RawRow["PrintLabel"]);  }
            set { RawRow["PrintLabel"] = EnumToFieldByDBCode<PrintLabelType>(value); }
        }

        public int TopupLvl
        {
            get { return FieldToInt(RawRow["TopupLvl"]) ?? 0; } 
            set { RawRow["TopupLvl"] = IntToField(value);     } 
        }

        public int? LastIssue
        {
            get { return FieldToInt(RawRow["LastIssue"]);   } 
            set { RawRow["LastIssue"] = IntToField(value);  } 
        }

        public DateTime? LastIssueDate
        {
            get { return FieldToDateTime(RawRow["LastIssueDate"]);   } 
            set { RawRow["LastIssueDate"] = DateTimeToField(value);  } 
        }

        public int? DailyIssue
        {
            get { return FieldToInt(RawRow["DailyIssue"]);   } 
            set { RawRow["DailyIssue"] = IntToField(value);  } 
        }

        /// <summary>
        /// Gets if there are any ToFolows from the WREquis for this line
        /// Where any WREquis has Status is '5' or '6' (linked via WRequis.WWardProductListLineID) and ToFollow='1'
        /// </summary>
        public bool HasToFollow
        {
            get { return FieldToBoolean(RawRow["HasToFollow"]) ?? false;  } 
        }

        /// <summary>
        /// Gets the RequisitionNum from the WRequis for this line
        /// Where any WRequis has Status is '5' or '6' (linked via WRequis.WWardProductListLineID) order by ToFollow desc, the WRequestID
        /// </summary>
        public string RequisitionNum_WRequis
        {
            get { return this.FieldToStr(this.RawRow["RequisitionNum_WRequis"], true);  } 
        }

        /// <summary>
        /// Gets the RequisitionNum from the WRequis for this line
        /// Where any WRequis has Status is '5' or '6' (linked via WRequis.WWardProductListLineID) order by ToFollow desc, the WRequestID
        /// </summary>
        public DateTime? OrdDateTime_WRequis
        {
            get
            {
                DateTime? dateOrdered = FieldStrDateToDateTime(RawRow["OrdDate_WRequis"], DateType.DDMMYYYY);
                TimeSpan? timeOrdered = FieldStrTimeToTimeSpan(RawRow["OrdTime_WRequis"]);

                if (dateOrdered.HasValue && timeOrdered.HasValue)
                {
                    return dateOrdered.Value + timeOrdered.Value;
                }
                else if (dateOrdered.HasValue) 
                {
                    return dateOrdered.Value;
                }
                else 
                {
                    return null;
                }
            }
        }

        /// <summary>
        /// Gets the outstanding amount for the requisition
        /// Where any WRequis has Status is '5' or '6' (linked via WRequis.WWardProductListLineID) order by ToFollow desc, the WRequestID
        /// </summary>
        public decimal? Outstanding_WRequis
        {
            get { return this.FieldToDecimal(this.RawRow["Outstanding_WRequis"]); }
        }

        /// <summary>
        /// Gets the QtyOrdered amount for the requisition
        /// Where any WRequis has Status is '5' or '6' (linked via WRequis.WWardProductListLineID) order by ToFollow desc, the WRequestID
        /// </summary>
        public decimal? QtyOrdered_WRequis
        {
            get { return this.FieldToDecimal(this.RawRow["QtyOrdered_WRequis"]); }
        }

        public string Comment
        {
            get { return FieldToStr(RawRow["Comment"]);     } 
            set { RawRow["Comment"] = StrToField(value);    } 
        }

        /// <summary>If last issue values was from an Ad-Hoc Issue</summary>
        public bool IsIssueAdHoc
        {
            get { return FieldToBoolean(RawRow["IsIssueAdHoc"]).Value;  } 
            set { RawRow["IsIssueAdHoc"] = BooleanToField(value);       } 
        }

        /// <summary>If multiple issues were done on the last issue date</summary>
        public bool IsMultiIssueOnIssueDate
        {
            get { return FieldToBoolean(RawRow["IsMultiIssueOnIssueDate"]).Value;  } 
            set { RawRow["IsMultiIssueOnIssueDate"] = BooleanToField(value);       } 
        }

        #region Helper Methods
        /// <summary>
        /// Gets either the PackSize or PackSize_SiteProductData
        /// But could still be null if the line is a title row
        /// </summary>
        public int? GetConversionFactorPackToIssueUnits()
        {
            return ConversionFactorPackToIssueUnits ?? ConversionFactorPackToIssueUnits_SiteProductData;
        }

        /// <summary>Return if this row is a drug row or a title</summary>
        public WWardProductListLineType LineType { get { return NSVCode.Length >= 7 ? WWardProductListLineType.Drug : WWardProductListLineType.Title; } }

        /// <summary>
        /// Clears following fields releated to issuing
        ///     ToFollow_WRequis
        ///     LastIssue
        ///     LastIssueDate
        ///     DailyIssue
        ///     IsIssueAdHoc
        ///     IsMultiIssueOnIssueDate
        /// </summary>
        public void ClearIssuingFields()
        {
            this.RawRow["HasToFollow"]            = DBNull.Value;
            this.RawRow["RequisitionNum_WRequis"] = DBNull.Value;
            this.RawRow["OrdDate_WRequis"]        = DBNull.Value;
            this.RawRow["OrdTime_WRequis"]        = DBNull.Value;
            this.RawRow["Outstanding_WRequis"]    = DBNull.Value;
            this.RawRow["QtyOrdered_WRequis"]     = DBNull.Value;
            this.LastIssue                        = 0;
            this.LastIssueDate                    = null;
            this.DailyIssue                       = 0;
            this.IsIssueAdHoc                     = false;
            this.IsMultiIssueOnIssueDate          = false;
        } 

        /// <summary>Returns Description</summary>
        public override string ToString()
        {
            //return Description ?? Description_SiteProductData.Replace('!', ' '); XN 2Nov16 don't support null description so no reason to test
            return Description;
        }
        #endregion
    }


    /// <summary>Provides column information about the WWardProductListLine table</summary>
    public class WWardProductListLineColumnInfo : BaseColumnInfo
    {
        public WWardProductListLineColumnInfo() : base ("WWardProductListLine") { } 

        public int  DescriptionLength{ get { return FindColumnByName("Description"   ).Length;   } }
        public int  NSVcodeLength    { get { return FindColumnByName("NSVcode"       ).Length;   } }
        public int  PrintLabelLength { get { return FindColumnByName("PrintLabel"    ).Length;   } } 
        public int  CommentLength    { get { return FindColumnByName("Comment"       ).Length;   } }
        public int  PackSizeMin      { get { return 0;        } }
        public int  PackSizeMax      { get { return 99999;    } }
        public int  TopupLvlMin      { get { return 0;        } }
        public int  TopupLvlMax      { get { return 99999;    } } 
    }

    /// <summary>Represent the WWardProductListLine table</summary>
    public class WWardProductListLine : BaseTable2<WWardProductListLineRow, WWardProductListLineColumnInfo>
    {
        public WWardProductListLine() : base ("WWardProductListLine") 
        { 
            this.UseLogicalDelete = true;
        }

        public WWardProductListLineRow Add(WProductRow linkedProduct)
        {
            WWardProductListLineRow row = this.Add();
            row.NSVCode = linkedProduct.NSVCode;
            if (row.RawRow.Table.Columns.Contains("PackSize_SiteProductData"))
            {
                row.RawRow["PackSize_SiteProductData"]      = linkedProduct.ConversionFactorPackToIssueUnits;
                row.RawRow["IssueUnits_SiteProductData"]    = linkedProduct.PrintformV;
                row.RawRow["Description_SiteProductData"]   = linkedProduct.ToString();
                row.RawRow["InUse_ProductStock"]            = linkedProduct.InUse;
            }
            return row;
        }

        public override WWardProductListLineRow Add()
        {
            WWardProductListLineRow row = base.Add();
            row.WWardProductListLineID  = this.Min(l => l.WWardProductListLineID) - 1;
            row.DisplayIndex              = -1;
            row.NSVCode                 = string.Empty;
            row.PrintLabel              = PrintLabelType.NoLabel;
            row.Comment                 = string.Empty;
            row.DailyIssue              = 0;
            row.LastIssue               = 0;
            row.IsMultiIssueOnIssueDate = false;    // 108301 16Jan14 XN Prevent Last Issue being blank when first created
            row.IsIssueAdHoc            = false;    // 108301 16Jan14 XN Prevent Last Issue being blank when first created
            return row;
        }

        /// <summary>Loads a single line by WWardProductListLineID</summary>
        /// <param name="siteID">Site ID of list</param>
        /// <param name="wwardProductListLineID">ID of line to load</param>
        public void LoadByWWardProductListLineID(int siteID, int wwardProductListLineID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WWardProductListLineID", wwardProductListLineID);
            parameters.Add("SiteID",                 siteID);
            LoadBySP("pWWardProductListLineByWWardProductListLineID", parameters);
        }

        /// <summary>
        /// Gets WWardProductListLines by wwardProductListID
        /// siteID only needed to get info from SiteProductData so any site will do
        /// </summary>
        public void LoadByWWardProductListID(int siteID, int wwardProductListID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WWardProductListID", wwardProductListID);
            parameters.Add("SiteID",             siteID);
            LoadBySP("pWWardProductListLineByWWardProductListID", parameters);
        }

        public void LoadByNSVCodeAndSite(string NSVCode, int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("NSVCode", NSVCode);
            parameters.Add("SiteID",  siteID );
            LoadBySP("pWWardProductListLineByNSVCodeAndSite", parameters);
        }

        protected override void CreateEmpty()
        {
            base.CreateEmpty();
            // Need to manually add these items as they come from siteProductData table so won't be created by Create Empty
            // Need if starting with a new empty list
            this.Table.Columns.Add("PackSize_SiteProductData",    typeof(int)   );
            this.Table.Columns.Add("IssueUnits_SiteProductData",  typeof(string));
            this.Table.Columns.Add("Description_SiteProductData", typeof(string));
            this.Table.Columns.Add("ToFollow_WRequis",            typeof(string));  // Is bool but stored as string in DB so needs to be string here
            this.Table.Columns.Add("HasToFollow",                 typeof(string));  
            this.Table.Columns.Add("RequisitionNum_WRequis",      typeof(string));  
            this.Table.Columns.Add("OrdDate_WRequis",             typeof(string));  
            this.Table.Columns.Add("OrdTime_WRequis",             typeof(string));  
            this.Table.Columns.Add("Outstanding_WRequis",         typeof(string));  
            this.Table.Columns.Add("QtyOrdered_WRequis",          typeof(string));  
            this.Table.Columns.Add("InUse_ProductStock",          typeof(string));  
        }

        public override void Save()
        {
            throw new ApplicationException("WWardProductListLine.Save is invalid use WWardProductListLine.Save(list) instead");
        }

        /// <summary>This version of save will write data to the WPharmacyLog</summary>
        /// <param name="stockLists"></param>
        public void Save(WWardProductList stockLists)
        {
            // Create pharmacy log
            WPharmacyLog log = new WPharmacyLog();
            log.AddRange ( this, 
                           WPharmacyLogType.WWardProductListLines,      // "WWardProductListLines", 20Jan15 XN 26734
                           r => r.LineType == WWardProductListLineType.Title ? r.Description : r.NSVCode,
                           r => stockLists.FindByID(r.WWardProductListID).SiteID,
                           r => r.NSVCode,
                           r => r.WWardProductListID, /* Set Thread to WWardProductListID value */
                           new [] { "ScreenPosn" });

            // And save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                base.Save();
                log.Save();
                trans.Commit();
            }
        }

        /// <summary>Returns a single WWardProductListLine</summary>
        /// <param name="siteID">Site ID of list</param>
        /// <param name="wwardProductListLineID">ID of line to load</param>
        /// <returns>line or null if does not exist</returns>
        public static WWardProductListLineRow GetByID(int siteID, int wwardProductListLineID)
        {
            WWardProductListLine lines = new WWardProductListLine();
            lines.LoadByWWardProductListLineID(siteID, wwardProductListLineID);
            return lines.FirstOrDefault();
        }
    }

    /// <summary>Enumerator for the WWardProductListLines</summary>
    public static class WWardProductListLineEnumerator
    {
        /// <summary>Returns list order by DisplayIndex</summary>
        /// <param name="list">List to sort</param>
        /// <returns>Sorted list</returns>
        public static IEnumerable<WWardProductListLineRow> OrderByScreenPos(this IEnumerable<WWardProductListLineRow> list)
        {
            return list.OrderBy(l => l.DisplayIndex);
        }

        /// <summary>Returns the index of the item with the specified line ID (else -1)</summary>
        /// <param name="list">List to search</param>
        /// <param name="wWardProductListLineID">Line ID to search for</param>
        /// <returns>Index of the line, or -1</returns>
        public static int IndexOf(this IEnumerable<WWardProductListLineRow> list, int wWardProductListLineID)
        {
            int i = 0;

            foreach (var current in list)
            {
                if (current.WWardProductListLineID == wWardProductListLineID)
                    return i;
                i++;        
            }

            return -1;
        }

        /// <summary>Returns all lines in list that are drug lines</summary>
        /// <param name="list">List to search</param>
        /// <returns>All list items that are drug lines</returns>
        public static IEnumerable<WWardProductListLineRow> FindDrugLines(this IEnumerable<WWardProductListLineRow> list)
        {
            return list.Where(l => l.LineType == WWardProductListLineType.Drug);
        }

        /// <summary>
        /// Reindexes list screen position (so displayed in list order)
        ///     list[0].DisplayIndex = startPos
        ///     list[1].DisplayIndex = startPos + 1
        /// </summary>
        /// <param name="list">List to reindex</param>
        /// <param name="startPos">Start index to set first item in list</param>
        public static void ResetScreenPositions(this IEnumerable<WWardProductListLineRow> list, int startPos = 0)
        {
            foreach (var row in list)
                row.DisplayIndex = startPos++;
        }
    }
}
