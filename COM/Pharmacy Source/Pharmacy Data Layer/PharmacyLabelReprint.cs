// -----------------------------------------------------------------------
// <copyright file="PharmacyLabelReprint.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to PharmacyLabelReprint table.
//
// You don't need to load tables directly from PharmacyLabelReprint, just use 
// the static save, and get methods
//
// Usage
// To save (insert\update) label for amm supply request
// PharmacyLabelReprint.SaveByAmmSupplyRequest(4524, PharmacyLabelReprintType.Worksheet, rtfWorksheet);
//
// To load the label
// rtfWorksheet = PharmacyLabelReprint.GetLabelByAmmSupplyRequestAndType(4524, PharmacyLabelReprintType.Worksheet);
//
// Modification History:
// 27May16 XN Created Written 123082
// 22Aug16 XN Added reprint tag 160920
// </summary>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;
    using System.Data.SqlClient;
    using ascribe.pharmacy.reportlayer;

    /// <summary>Label type</summary>
    public enum PharmacyLabelReprintType
    {
        /// <summary>Unknown type</summary>
        Unknown,

        /// <summary>Worksheet type</summary>
        [EnumDBCode("Wks")]
        Worksheet,

        /// <summary>Label type</summary>
        [EnumDBCode("Lbl")]
        Label,

        /// <summary>Raw label</summary>
        [EnumDBCode("Rlb")]
        RawLabel,
    }

    /// <summary>Row in the PharmacyLabelReprint table</summary>
    public class PharmacyLabelReprintRow : BaseRow
    {
        public int PharmacyLabelReprintID
        {
            get { return FieldToInt(RawRow["PharmacyLabelReprintID"]).Value; }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value);      }
        }

        public int LabelNumber
        {
            get { return FieldToInt(RawRow["LabelNumber"]).Value; }
            set { RawRow["LabelNumber"] = IntToField(value);      }
        }

        public int? WLabelID
        {
            get { return FieldToInt(RawRow["WLabelID"]);    }
            set { RawRow["WLabelID"] = IntToField(value);   }
        }


        public string Label 
        {
            get { return FieldToStr(RawRow["Label"], trimString: false, nullVal: string.Empty ); }
            set { RawRow["Label"] = StrToField(value, emptyStrAsNullVal: true);            	     }
        }	

        public PharmacyLabelReprintType Type
        {
            get { return FieldToEnumByDBCode<PharmacyLabelReprintType>(RawRow["Prefix"]); }
            set { RawRow["Prefix"] = EnumToFieldByDBCode(value);            	          }
        }

        public DateTime Date
        {
            get { return FieldToDateTime(RawRow["Date"]).Value; }
            set { RawRow["Date"] = DateTimeToField(value);      }
        }
    }


    /// <summary>Table info for PharmacyLabelReprint table</summary>
    public class PharmacyLabelReprintColumnInfo : BaseColumnInfo
    {
        public PharmacyLabelReprintColumnInfo() : base("PharmacyLabelReprint") { }

        public int PrefixLength { get { return this.FindColumnByName("Prefix").Length; } }
    }


    /// <summary>Represent the PharmacyLabelReprint table</summary>
    public class PharmacyLabelReprint : BaseTable2<PharmacyLabelReprintRow, PharmacyLabelReprintColumnInfo>
    {
        public PharmacyLabelReprint() : base("PharmacyLabelReprint") { }

        /// <summary>Loads the label by site, amm supply request Id, and type (prefix)</summary>
        /// <param name="requestId_AmmSupplyRequest">amm supply request Id</param>
        /// <param name="type">type (prefix)</param>
        private void LoadByAmmSupplyRequestSiteAndType(int requestId_AmmSupplyRequest, PharmacyLabelReprintType type)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",              SessionInfo.SessionID);
            parameters.Add("SiteID",                        SiteInfo.PatientDataSiteId());
            parameters.Add("requestId_AmmSupplyRequest",    requestId_AmmSupplyRequest);   
            parameters.Add("Prefix",                        EnumDBCodeAttribute.EnumToDBCode(type));
            this.LoadBySP("pPharmacyLabelReprintbyAmmSupplyRequestSiteAndPrefix", parameters);
        }

        /// <summary>
        /// Saves a label (will do an insert or update)
        /// Won't save if setting D|patmed..EnableReprints is disabled
        /// </summary>
        /// <param name="requestId_AmmSupplyRequest">amm supply request Id</param>
        /// <param name="type">type (prefix)</param>
        /// <param name="label">rtf text to save</param>
        public static void SaveByAmmSupplyRequest(int requestId_AmmSupplyRequest, PharmacyLabelReprintType type, string label)
        {
            if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|patmed", string.Empty, "EnableReprints", false, false))
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("CurrentSessionID",           SessionInfo.SessionID);
                parameters.Add("SiteID",                     SiteInfo.PatientDataSiteId());
                parameters.Add("LabelNumber",                type == PharmacyLabelReprintType.Worksheet ? 0 : 1);
                parameters.Add("requestId_AmmSupplyRequest", requestId_AmmSupplyRequest);
                parameters.Add("Label",                      label);
                parameters.Add("Prefix",                     EnumDBCodeAttribute.EnumToDBCode(type));
                Database.ExecuteSPNonQuery("pPharmacyLabelReprintWriteForAmmSupplyRequest", parameters);
            }
        }

        /// <summary>
        /// Reads a rtf label from the reprint table
        /// Won't load anything if setting D|patmed..EnableReprints is disabled
        /// </summary>
        /// <param name="requestId_AmmSupplyRequest">amm supply request Id</param>
        /// <param name="type">type (prefix)</param>
        /// <returns>rtf label type</returns>
        public static string GetLabelByAmmSupplyRequestAndType(int requestId_AmmSupplyRequest, PharmacyLabelReprintType type)
        {
            // Load the reprint
            PharmacyLabelReprint reprint = new PharmacyLabelReprint();
            if (WConfiguration.Load(SessionInfo.SiteID, "D|patmed", string.Empty, "EnableReprints", false, false))
                reprint.LoadByAmmSupplyRequestSiteAndType(requestId_AmmSupplyRequest, type);

            // Parse the reprint marker
            RTFParser rtf = new RTFParser();
            if (reprint.Any())
            {
                string reprintMarker = WConfiguration.Load(SessionInfo.SiteID, "D|patmed", string.Empty, "ReprintMarker", "*",         false);
                string reprintText   = WConfiguration.Load(SessionInfo.SiteID, "D|patmed", string.Empty, "ReprintText",   @"{\cf0 R}", false);

                rtf.Read(reprint.OrderBy(r => r.LabelNumber).Select(r => r.Label).FirstOrDefault());
                rtf.Parse(reprintMarker, reprintText);
                rtf.Parse("ORIGINAL PRINT", string.Format("Reprinted by {0} on {1}", SessionInfo.UserInitials, DateTime.Now.ToPharmacyDateTimeString()));   // 22Aug16 XN 160920 Added tag
            }

            return rtf.ToString();
        }
    }


    /// <summary>PharmacyLabelReprint enumeration extension methods</summary>
    public static class PharmacyLabelReprintEnumerable
    {
    }
}
