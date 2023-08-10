//===========================================================================
//
//							        WFMAccountCode.cs
//
//	Provides functions for writing to the WFMAccountCode table
//  Used by finance manager
//
//  Table holds the account codes used to organise the transactions in finance manager
//  these include things like 'Stock Account', 'Goods Received Not Invoiced'.
//  Each account is give a 3 digit code. 
//  Codes like 100, 200 are give to major accounts, with sub accounts given values 110, 220, etc.
//  Each code is assigned to either an Worderlog, or Wtranslog line via the FMRules
//
//  Supports reading, inserting, and updating.
//  
//	Modification History:
//	23Apr13 XN  Written 53147
//  17Sep13 XN  Added FindByCode, and FindBySubCode 73326
//  17Sep13 XN  Converted WFMAccountCode.Code from string to short
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.financemanagerlayer
{
    /// <summary>Represents a row in the WFMAccountCode table</summary>
    public class WFMAccountCodeRow : BaseRow
    {
        public int WFMAccountCodeID
        {
            get { return (int)FieldToInt(RawRow["WFMAccountCodeID"]); }
        }

        public short Code
        {
            get { return FieldToShort(RawRow["Code"]).Value; }
            set { RawRow["Code"] = ShortToField(value);      }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
            set { RawRow["Description"] = StrToField(value, true);              }
        }

        /// <summary>
        /// Returns the level of the account (derived from code)
        /// If code is in 100's then returns 0 (e.g. 200, 100, 800)
        /// If code is in 10's  then returns 1 (e.g. 210, 120, 840)
        /// If code is in 1's   then returns 2 (e.g. 212, 122, 843)
        /// </summary>
        public int AccountLevel
        {
            get
            {
                if (Code % 10 != 0)
                    return 2;
                else if (Code % 100 != 0)
                    return 1;
                else
                    return 0;
            }
        }

        /// <summary>
        /// Returns account description with formatting
        /// If AccountLevel is 0 (e.g. 100, 200, 800) then description will be in capitals
        /// </summary>
        public string DescriptionWithDisplayFormatting()
        {
            string description = Description;
            if (this.AccountLevel == 0)
                description = description.ToUpper();
            return description;
        }

        /// <summary>Return {Code} - {Description}</summary>
        public override string ToString()
        {
 	        return string.Format("{0} - {1}", Code, Description);
        }

        /// <summary>
        /// Return {Code} - {Description}
        /// with tabs at start of string depending on the level.
        /// description in capital if level 0 account (e.g. 100, 200, 800)
        /// </summary>
        /// <param name="includeSpaces">If to include space before the code</param>
        public string ToStringWithFormatting(bool includeSpaces)
        {
            StringBuilder str = new StringBuilder();

            if (includeSpaces)
            {
                for (int c = AccountLevel; c > 0; c--)
                    str.Append("   ");
            }

            str.Append(this.Code);
            str.Append(" - ");
            str.Append(this.DescriptionWithDisplayFormatting());

 	        return str.ToString();
        }
    }

    /// <summary>Provides column information about the WFMAccountCode table</summary>
    public class WFMAccountCodeColumnInfo : BaseColumnInfo
    {
        public WFMAccountCodeColumnInfo() : base("WFMAccountCode") { }

        public int CodeLength        { get { return 3;                                           } }
        public int DescriptionLength { get { return base.FindColumnByName("Description").Length; } }
    }


    /// <summary>Represent the WFMSegment1Code table</summary>
    public class WFMAccountCode : BaseTable2<WFMAccountCodeRow, WFMAccountCodeColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WFMAccountCode() : base("WFMAccountCode") { }


        /// <summary>Load all FM Log types</summary>
        public void LoadAll()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            LoadBySP("pWFMAccountCodeAll", parameters);
        }

        /// <summary>Loads account code by WFMAccountCodeID</summary>
        public void LoadByID(int accountCodeID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("WFMAccountCodeID", accountCodeID));
            LoadBySP("pWFMAccountCodeByID", parameters);
        }

        /// <summary>Loads account code by code</summary>
        public void LoadByCode(int code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("Code", code));
            LoadBySP("pWFMAccountCodeByCode", parameters);
        }

        /// <summary>Returns items with selected account code, else null 17Sep13 XN 73326</summary>
        public WFMAccountCodeRow FindByCode(int accountCode)
        {
            return this.FirstOrDefault(a => a.Code == accountCode);
        }

        /// <summary>Returns items with under this account item (with option to including this account item 17Sep13 XN 73326</summary>
        public IEnumerable<WFMAccountCodeRow> FindAllSubCodes(int accountCode, bool includeSelf)
        {
            WFMAccountCodeRow majorSection = this.FirstOrDefault(a => a.Code == accountCode);
            if (majorSection == null)
                return new List<WFMAccountCodeRow>();

            int accountCodeStart = accountCode;
            int accountCodeEnd   = accountCodeStart + (int)Math.Pow(10, 3 - majorSection.AccountLevel - 1);

            if (includeSelf)
                return this.Where(a => a.Code >= accountCodeStart && a.Code < accountCodeEnd);
            else
                return this.Where(a => a.Code  > accountCodeStart && a.Code < accountCodeEnd);
        }

        /// <summary>Returns account with WFMAccountCodeID value (or null if does not exist)</summary>
        public static WFMAccountCodeRow GetByID(int accountCodeID)
        {
            WFMAccountCode logType = new WFMAccountCode();
            logType.LoadByID(accountCodeID);
            return logType.FirstOrDefault();
        }

        /// <summary>Returns true if the code does not already exist in the db table WFMAccountCode</summary>
        /// <param name="code">Code to test</param>
        public static bool CheckCodeIsUnique(short code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@Code", code));
            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM WFMAccountCode WHERE Code Like @Code", parameters) == null;
        }
    }

}
