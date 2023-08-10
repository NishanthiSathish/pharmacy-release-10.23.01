//===========================================================================
//
//							      UMMCWTranslog.cs
//
//  Provides a view of the WTranslog table, to link in extra information that
//  is UMMC specicific. 
//
//  SP for this object should return following extra fields:
//      SiteProductData.StoresDescription or SiteProductData.[LabelDescription] as ProductDescription
//      Entity.Description as ConsultantDescription via WTranslog.Consultant to EntityAlias.Alias where AliasGroup is WConsultantCodes
//      RxNumber - If prescription has RxTracker associated with it then 
//                 returns CommitBatch.SiteGeneratedCode else returns null
//
//  Only supports reading
//
//	Modification History:
//	05Oct10 XN  Written (F0082255)
//===========================================================================
using System;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;

namespace ascribe.pharmacy.ummcdatalayer
{
    /// <summary>Represents a view of the WTranslog table</summary>
    public class UMMCWTranslogViewRow : BaseRow
    {
        public int WTranslogID { get { return FieldToInt(RawRow["WTranslogID"]).Value; } }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["SisCode"], true, string.Empty); }
            set { RawRow["SisCode"] = StrToField(value, false);             }
        }

        /// <summary>DB int field [Site]</summary>
        public int SiteNumber
        {
            get { return FieldToInt(RawRow["Site"]).Value;  } 
            set { RawRow["Site"] = IntToField(value);       } 
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value;  } 
            set { RawRow["SiteID"] = IntToField(value);       } 
        }

        public int EpisodeID
        {
            get { return FieldToInt(RawRow["Episode"]) ?? 0; }
            set { RawRow["Episode"] = IntToField(value);     }
        }

        /// <summary>Stores or label description for the products order with the ! replaced with space</summary>
        public string ProductDescription
        {
            get { return FieldToStr(RawRow["ProductDescription"]).Replace('!', ' ');  }
        }

        /// <summary>DB int field convfact</summary>
        public int ConversionFactorPackToIssueUnits
        {
            get { return FieldToInt(RawRow["ConvFact"]).Value; }
            set { RawRow["ConvFact"] = IntToField(value);      }
        }

        /// <summary>DB string field Qty</summary>
        public decimal QuantityInIssueUnits
        {
            get { return FieldToDecimal(RawRow["Qty"]) ?? 0m;                                                 }
            set { RawRow["Qty"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().QuantityIssuedLength);   }
        }

        public string IssueUnits
        {
            get { return FieldToStr(RawRow["IssueUnits"], true, string.Empty); }
            set { RawRow["IssueUnits"] = StrToField(value, false);              }
        }

        /// <summary>DB string field Consultant</summary>
        public string ConsultantCode
        {
            get { return FieldToStr(RawRow["Consultant"], false, string.Empty); }
            set { RawRow["Consultant"] = StrToField(value, false);              }
        }
        
        /// <summary>Read from Consultant.Description via ConsultantCode</summary>
        public string ConsultantName
        {
            get { return FieldToStr(RawRow["ConsultantDescription"], true, string.Empty); }
        }

        /// <summary>DB string field Ward</summary>
        public string WardCode
        {
            get { return FieldToStr(RawRow["Ward"], false, string.Empty); }
            set { RawRow["Ward"] = StrToField(value, false);              }
        }

        /// <summary>If prescription has RxTracker associated with it then returns CommitBatch.SiteGeneratedCode else returns null</summary>
        public string RxNumber
        {
            get { return FieldToStr(RawRow["RxNumber"]); }
        }
    }

    /// <summary>Provides column information about the WTranslog table</summary>
    public class UMMCWTranslogviewColumnInfo : BaseColumnInfo
    {
        public UMMCWTranslogviewColumnInfo () : base("WTranslog") { }
    }

    /// <summary>Represents WTranslog table with exteneded UMMC specific properties</summary>
    public class UMMCWTranslogView : BaseTable<UMMCWTranslogViewRow, UMMCWTranslogviewColumnInfo>
    {
        public UMMCWTranslogView() : base("WTranslog", "WTranslogID") 
        {
        }

        public UMMCWTranslogView(RowLocking rowLocking) : base("WTranslog", "WTranslogID", rowLocking) 
        { 
        }

        /// <summary>
        /// Loads all 'I', 'O', 'D', 'L' type logs for the patient in the specified time range.
        /// </summary>
        /// <param name="entityID">Matched on PatID</param>
        /// <param name="startDate">From date and time</param>
        /// <param name="endDate">End date and tiime</param>
        public void LoadByEpisodeAndDateRange(int entityID, DateTime startDate, DateTime endDate)
        {
            StringBuilder parameters = new StringBuilder();

            AddInputParam(parameters, "EntityID",  entityID );
            AddInputParam(parameters, "StartDate", startDate); 
            AddInputParam(parameters, "EndDate",   endDate  ); 

            LoadRecordSetStream("pUMMCWTranslogByEntityAndDateRange", parameters);
        }
    }
}
