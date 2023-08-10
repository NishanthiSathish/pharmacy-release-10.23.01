//===========================================================================
//
//							     WFMStockAccountSheetLayout.cs
//
//	Provides functions for writing to the WFMStockAccountSheetLayout table
//  Used by finance manager
//
//  Table holds the layout of the finance manager stock balance sheet.
//  
//  Each row in the balance sheet has a type like opening and closing balances.
//  The layout of the balance sheet is normal in form
//      Opening balance
//      Main Section
//          Account section
//          Account section
//      Main Section
//          Account section
//          Account section
//      :
//      Calculated Balance
//      Closing Balance
//      Closing Balance Discrepancies
//
//  Most of the rows are All either MainSections, or AccountSections.
//          Main Sections   - are the sum of the account sections. So don't have
//                            an account code, or a parent.
//          Account Sections- are child of a main section, always have an 
//                            account code, will always be same colour as main 
//                            section (so does not have a colour).
//
//  The SortIndex is always calculated, and used to determine the order 
//  sections are displayed in (more than their parent child relationship).
//  When adding rows to list use Add(inserAfterRowIndex) method (after using load all)
//
//  Supports reading, inserting, and updating.
//  
//	Modification History:
//	30Apr13 XN  Written 27038
//  16Sep13 XN  Moved WFMStockAccountSheetSettings and WFMGrniSettings to Utils  73326 
//  17Sep13 XN  Converted WFMAccountCode.Code, WFMRule.Code from string to short
//  02Dec13 XN  Added VAT account codes 79631
//  09Jan14 XN  Re added Inc Vat calculating closing balance, and discrepancies
//  20Feb14 XN  Adjust opening, and closing, balance if vat account codes are present 84499
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Data;
using System;

namespace ascribe.pharmacy.financemanagerlayer
{
    /// <summary>Defines the section type for the row</summary>
    public enum WFMStockAccountSheetSectionType
    {
        [EnumDBCode("")]  Unknown,

        /// <summary>Opening balance section</summary>
        [EnumDBCode("O")] OpeningBalance,

        /// <summary>Main balance sheet section (DB code S)</summary>
        [EnumDBCode("M")] MainSection,

        /// <summary>Account code section (DB code A)</summary>
        [EnumDBCode("A")] AccountSection,

        /// <summary>Calculated balance section</summary>
        [EnumDBCode("S")] CalculatedClosingBalance,

        /// <summary>Closing balance section</summary>
        [EnumDBCode("C")] ActualClosingBalance,

        /// <summary>Closing balance Discrepancies</summary>
        [EnumDBCode("D")] ClosingBalanceDiscrepancies,
    }

    /// <summary>Holds the values for a section in an account stock sheet</summary>
    public class WFMAccountSheetData
    {
        public WFMStockAccountSheetLayoutRow section;
        public double?                  quantity;
        public double?                  cost;
        public double?                  costIncVat;
        public double?                  vat;
    }

    /// <summary>Represents a row in the WFMStockAccountSheetLayoutRow table</summary>
    public class WFMStockAccountSheetLayoutRow : BaseRow
    {
        public int WFMStockAccountSheetLayoutID
        {
            get { return (int)FieldToInt(RawRow["WFMStockAccountSheetLayoutID"]); }
        }

        /// <summary>null for everything apart from for account sections</summary>
        public int? WFMStockAccountSheetLayoutID_Parent
        {
            get { return FieldToInt(RawRow["WFMStockAccountSheetLayoutID_Parent"]);  }
            set { RawRow["WFMStockAccountSheetLayoutID_Parent"] = IntToField(value); }
        }

        public WFMStockAccountSheetSectionType SectionType
        {
            get { return FieldToEnumByDBCode<WFMStockAccountSheetSectionType>(RawRow["SectionType"]);  }
            set { RawRow["SectionType"] = EnumToFieldByDBCode<WFMStockAccountSheetSectionType>(value); }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
            set { RawRow["Description"] = StrToField(value);                    }
        }

        public IEnumerable<short> RuleCodes
        {
            get { return FieldToStr(RawRow["RuleCodes"], true, string.Empty).Split(new char[]{','},StringSplitOptions.RemoveEmptyEntries).Select(c => short.Parse(c)); }
            set { RawRow["RuleCodes"] = StrToField(value.ToCSVString(",")); } 
        }

        /// <summary>
        /// For AccountSections value will always be null, as use colour of MainSection.
        /// Can also be null if MainSection should use standard text colour.
        /// </summary>
        public Color? TextColour
        {
            get 
            { 
                int? colour = FieldToInt(RawRow["TextColour"]);
                return (colour == null) ? (Color?)null : Color.FromArgb(colour.Value); 
            }
            set 
            {
                int? colour = value == null ? (int?)null : value.Value.ToArgb();
                RawRow["TextColour"] = IntToField(colour);                    
            }
        }


        /// <summary>
        /// For AccountSections value will always be null, as use colour of MainSection.
        /// Can also be null if MainSection should use standard background colour.
        /// </summary>
        public Color? BackgroundColour
        {
            get 
            { 
                int? colour = FieldToInt(RawRow["BackgroundColour"]);
                return (colour == null) ? (Color?)null : Color.FromArgb(colour.Value); 
            }
            set 
            {
                int? colour = value == null ? (int?)null : value.Value.ToArgb();
                RawRow["BackgroundColour"] = IntToField(colour);                    
            }
        }

        public int SortIndex
        {
            get { return FieldToInt(RawRow["SortIndex"]).Value; }
            set { RawRow["SortIndex"] = IntToField(value);      }
        }

        /// <summary>
        /// Returns description with formatting
        /// Space before description of account sections 
        /// All other sections description is in capitals
        /// </summary>
        public string ToStringWithFormatting()
        {
            if (this.WFMStockAccountSheetLayoutID_Parent != null)
                return "   " + this.Description;
            else
                return this.Description.ToUpper();
        }
    }

    /// <summary>Provides column information about the WFMStockAccountSheetLayout table</summary>
    public class WFMStockAccountSheetLayoutColumnInfo : BaseColumnInfo
    {
        public WFMStockAccountSheetLayoutColumnInfo() : base("WFMStockAccountSheetLayout") { }

        public int DescriptionLength { get { return base.FindColumnByName("Description").Length; } }
        public int AccountCodeLength { get { return base.FindColumnByName("AccountCode").Length; } }
    }

    /// <summary>Represent the WFMStockAccountSheetLayout table</summary>
    public class WFMStockAccountSheetLayout : BaseTable2<WFMStockAccountSheetLayoutRow, WFMStockAccountSheetLayoutColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WFMStockAccountSheetLayout() : base("WFMStockAccountSheetLayout") { }

        /// <summary>
        /// Adds new row to table.
        /// Updates all SortIndexes in the table so that the new row
        /// appears after insertAfterRowIndex in balance sheet.
        /// </summary>
        /// <param name="insertAfterRow">row to insert after</param>
        /// <returns>new row</returns>
        public WFMStockAccountSheetLayoutRow Add(WFMStockAccountSheetLayoutRow insertAfterRow, WFMStockAccountSheetSectionType sectionType)
        {
            int insertAfterRowSortIndex = 0;

            if (insertAfterRow != null)
            {
                // Get ID of balance sheet row ID to insert after
                int wfmStockAccountSheetLayoutID_Parent;
                if (insertAfterRow.SectionType == WFMStockAccountSheetSectionType.AccountSection)
                    wfmStockAccountSheetLayoutID_Parent = insertAfterRow.WFMStockAccountSheetLayoutID_Parent ?? 0;
                else
                    wfmStockAccountSheetLayoutID_Parent = insertAfterRow.WFMStockAccountSheetLayoutID;

                // If main section row then get the last sub item 
                if (sectionType != WFMStockAccountSheetSectionType.AccountSection && this.Any(l => l.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID_Parent))
                {
                    var items = this.Where(l => l.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID_Parent).OrderByDescending(l => l.SortIndex);
                    insertAfterRow = items.First();
                }

                // Update sort index
                insertAfterRowSortIndex = insertAfterRow.SortIndex;
                this.Where(l => l.SortIndex > insertAfterRowSortIndex).ToList().ForEach(l => l.SortIndex++);
            }

            WFMStockAccountSheetLayoutRow newRow = base.Add();
            newRow.SortIndex                        = insertAfterRowSortIndex + 1;
            newRow.SectionType                      = sectionType;
            newRow.WFMStockAccountSheetLayoutID_Parent   = null;
            newRow.BackgroundColour                 = null;
            newRow.TextColour                       = null;

            return newRow;
        }

        /// <summary>Load all</summary>
        public void LoadAll()
        {
            LoadBySP("pWFMStockAccountSheetLayoutAll", new List<SqlParameter>());
        }

        /// <summary>Load by wfmStockAccountSheetLayoutID</summary>
        public void LoadByID(int wfmStockAccountSheetLayoutID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("WFMStockAccountSheetLayoutID", wfmStockAccountSheetLayoutID));
            LoadBySP("pWFMStockAccountSheetLayoutByID", parameters);
        }

        /// <summary>returns layouts that contain the specified rule code 66961 24Jun13 XN</summary>
        /// <param name="ruleCode">Rule code to search for</param>
        public void LoadByRuleCode(string ruleCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("RuleCode", ruleCode));
            LoadBySP("pWFMStockAccountSheetLayoutByRuleCode", parameters);
        }

        /// <summary>Returns row with the select wfmStockAccountSheetLayoutID (else null)</summary>
        public WFMStockAccountSheetLayoutRow FindByID(int wfmStockAccountSheetLayoutID)
        {
            return this.FirstOrDefault(r => r.WFMStockAccountSheetLayoutID == wfmStockAccountSheetLayoutID);
        }

        /// <summary>Returns all child rows for the parent with the select wfmStockAccountSheetLayoutID</summary>
        public IEnumerable<WFMStockAccountSheetLayoutRow> FindByChildSections(int wfmStockAccountSheetLayoutID_parent)
        {
            return this.Where(r => r.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID_parent);
        }

        /// <summary>Returns row with the selected wfmStockAccountSheetLayoutID, and all child rows</summary>
        public IEnumerable<WFMStockAccountSheetLayoutRow> FindByIDAndChildren(int wfmStockAccountSheetLayoutID)
        {
            return this.Where(r => r.WFMStockAccountSheetLayoutID == wfmStockAccountSheetLayoutID || r.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID);
        }

        /// <summary>
        /// Returns rule codes for row with the selected wfmStockAccountSheetLayoutID, and rule codes for all child rows
        /// Assums all rows have been loaded
        /// </summary>
        public IEnumerable<short> FindRuleCodeByIDAndChildren(int wfmStockAccountSheetLayoutID)
        {
            return this.Where(r => r.WFMStockAccountSheetLayoutID == wfmStockAccountSheetLayoutID || r.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID).SelectMany(s => s.RuleCodes);
        }

        /// <summary>
        /// Returns pharmacy log type of a account sheet section 
        /// by get pharmacy log type of first rule code of section or one of it child sections
        /// Assums all rows have been loaded
        /// </summary>
        /// <returns>pharmacy log type of section or Unknown</returns>
        public PharmacyLogType FindPharmacyLogTypeByIDAndChildren(int wfmStockAccountSheetLayoutID)
        {
            // Get the first rule code
            var ruleCodes = FindRuleCodeByIDAndChildren(wfmStockAccountSheetLayoutID);
            
            // Now get log type for rule
            PharmacyLogType pharmacyLog = PharmacyLogType.Unknown;
            if (ruleCodes.Any())
            {
                WFMRuleRow rule = WFMRule.GetByCode(ruleCodes.First());
                if (rule != null)
                    pharmacyLog = rule.PharmacyLog;
            }

            return pharmacyLog;
        }

        /// <summary>
        /// Returns first row, from bottom of balance sheet, 
        /// that is either a main, account or opening balance section
        /// </summary>
        public WFMStockAccountSheetLayoutRow FindFirstRowBeforeCalculatedClosingBalance()
        {
            return this.OrderByDescending(r => r.SortIndex).FirstOrDefault(r => r.SectionType == WFMStockAccountSheetSectionType.AccountSection ||
                                                                                r.SectionType == WFMStockAccountSheetSectionType.MainSection    ||
                                                                                r.SectionType == WFMStockAccountSheetSectionType.OpeningBalance);
        }

        /// <summary>
        /// Converts and returns all data loaded into the account sheet layout requested
        /// 
        /// Note: Can't calculate closing balance, or discrepancies cost inc vat as if the site has vat account code the total 
        /// down and across the table for these two fields will not add up, so these values are always null 
        /// </summary>
        /// <param name="openingBalanceData">Opening balance</param>
        /// <param name="closingBalanceData">Closing balance</param>
        /// <param name="layout">account sheet layout</param>
        /// <param name="siteIDsThatReclaimVat">List of site IDs that can reclaim vat</param>
        /// <returns>Quantity an values used to group the account sheet layout</returns>
        public IEnumerable<WFMAccountSheetData> Layout(WFMDailyStockLevel openingBalanceData, WFMDailyStockLevel closingBalanceData, WFMLogCache log, IEnumerable<int> siteIDsThatReclaimVat)
        {
            short stockAccountCode = WFMSettings.StockAccountSheet.AccountCode;

            List<WFMAccountSheetData> results = new List<WFMAccountSheetData>();
            results.AddRange(this.Select(r => new WFMAccountSheetData(){ section = r }));

            // Opening balance
            WFMAccountSheetData openingBalance = results.FirstOrDefault(s => s.section.SectionType == WFMStockAccountSheetSectionType.OpeningBalance);
            if (openingBalance != null)
            {
                openingBalance.quantity     = openingBalanceData.Sum(s => s.StockLevelInIssueUnits  ).RoundQuantity();
                openingBalance.cost         = openingBalanceData.Sum(s => s.StockValueExVat         ).RoundCost();
                openingBalance.costIncVat   = openingBalanceData.Sum(s => s.StockValueIncVat        ).RoundCost();
                openingBalance.vat          = openingBalanceData.Sum(s => s.StockValueVat           ).RoundCost();
            }

            // Rule sections (sub sections)
            // As there maybe thousands for log entries 
            // quicker to iterate throught the logs and update the correct section
            var ruleCodeToAccountSections = (from r in results 
                                            where r.section.SectionType == WFMStockAccountSheetSectionType.AccountSection
                                            from rc in r.section.RuleCodes
                                            select new { RuleCode=rc, AccountSection=r }).ToDictionary(r => r.RuleCode, r => r.AccountSection); // Group account sections by rule code
            foreach(var logRow in log)
            {
                WFMAccountSheetData accountSection;
                if (ruleCodeToAccountSections.TryGetValue(logRow.RuleCode.Value, out accountSection))
                {
                    if (logRow.GetAccountQuantityInIssueUnits(stockAccountCode) != null)    // 20Feb14 XN 84499 Skip null values else will cause total to go null (plus we don't want to default to 0 as if null field is skipped)
                        accountSection.quantity  = (accountSection.quantity ?? 0.0) + logRow.GetAccountQuantityInIssueUnits(stockAccountCode);
                    if (logRow.GetAccountCostExVat (stockAccountCode) != null)
                        accountSection.cost = (accountSection.cost ?? 0.0) + logRow.GetAccountCostExVat (stockAccountCode);
                    if (logRow.GetAccountCostIncVat (stockAccountCode) != null)
                        accountSection.costIncVat= (accountSection.costIncVat ?? 0.0) + logRow.GetAccountCostIncVat(stockAccountCode);
                    if (logRow.GetAccountVatCost (stockAccountCode) != null)
                        accountSection.vat = (accountSection.vat ?? 0.0) + logRow.GetAccountVatCost(stockAccountCode);
                }
            }

            foreach(var a in ruleCodeToAccountSections.Values)  // Round results
            {
                a.cost      = a.cost.RoundCost();            
                a.costIncVat= a.costIncVat.RoundCost();            
                a.vat       = a.vat.RoundCost();            
                a.quantity  = a.quantity.RoundQuantity();
            }

            // Main sections
            List<WFMAccountSheetData> mainSections = results.Where(s => s.section.SectionType == WFMStockAccountSheetSectionType.MainSection).ToList();
            foreach (var mainSection in mainSections)
            {
                int wfmStockAccountSheetLayoutID = mainSection.section.WFMStockAccountSheetLayoutID;
                var childSections = results.Where(r => r.section.WFMStockAccountSheetLayoutID_Parent == wfmStockAccountSheetLayoutID);

                mainSection.cost       = childSections.Sum(s => s.cost      ).RoundCost();
                mainSection.costIncVat = childSections.Sum(s => s.costIncVat).RoundCost();
                mainSection.vat        = childSections.Sum(s => s.vat       ).RoundCost();
                if (childSections.Any(s => s.quantity != null))
                    mainSection.quantity = childSections.Sum(s => s.quantity).RoundQuantity();
            }

            // Closing balance
            WFMAccountSheetData actulalClosingBalance = results.FirstOrDefault(s => s.section.SectionType == WFMStockAccountSheetSectionType.ActualClosingBalance);
            if (actulalClosingBalance != null)
            {
                actulalClosingBalance.quantity  = closingBalanceData.Sum(s => s.StockLevelInIssueUnits ).RoundQuantity();
                actulalClosingBalance.cost      = closingBalanceData.Sum(s => s.StockValueExVat        ).RoundCost();
                actulalClosingBalance.costIncVat= closingBalanceData.Sum(s => s.StockValueIncVat       ).RoundCost();
                actulalClosingBalance.vat       = closingBalanceData.Sum(s => s.StockValueVat          ).RoundCost();
            }

            // Adjust opening, and closing, balance if vat account codes are present 20Feb14 XN 84499
            // Basicaly for a site that can recmail vat (has vat account code present)
            //          opening balance Vat     = 0 
            //                          Inc Vat = Ex Vat
            //          closing balance Vat     = Closing balance Vat     - opening balance Vat (before zeroing) + vat for all log entries with T account
            //                          Inc Vat = Closing balance Inc Vat - opening balance Vat (before zeroing) + vat for all log entries with T account 
            if (siteIDsThatReclaimVat.Any())
            {
                var openingBalanceVatReclaim = openingBalanceData.Where(ob => siteIDsThatReclaimVat.Contains(ob.LocationID_Site)).Sum(ob => ob.StockValueVat);
                var vatReclaim               = log.Where(l => l.AccountCodeType == "T" && siteIDsThatReclaimVat.Contains(l.LocationID_Site ?? 0)).Sum(c => c.GetAccountVatCost(stockAccountCode));
                var vatTotal                 = (openingBalanceVatReclaim - vatReclaim).RoundCost();

                actulalClosingBalance.costIncVat-= vatTotal;
                actulalClosingBalance.vat       -= vatTotal;

                openingBalance.costIncVat -= openingBalanceVatReclaim;
                openingBalance.vat        -= openingBalanceVatReclaim;
                if (Math.Abs(openingBalance.vat ?? 0) <= 1)
                    openingBalance.vat = 0;
            }

            // Calculated closing balance
            WFMAccountSheetData calucatedClosingBalance = results.FirstOrDefault(s => s.section.SectionType == WFMStockAccountSheetSectionType.CalculatedClosingBalance);
            if (calucatedClosingBalance != null && openingBalance != null)
            {
                double cost         = mainSections.Sum(s => s.cost       ?? 0.0);
                double costIncVat   = mainSections.Sum(s => s.costIncVat ?? 0.0);
                double vat          = mainSections.Sum(s => s.vat        ?? 0.0);
                double quantity     = mainSections.Sum(s => s.quantity   ?? 0.0);

                calucatedClosingBalance.cost        = (openingBalance.cost      + cost      ).RoundCost();
                calucatedClosingBalance.costIncVat  = (openingBalance.costIncVat+ costIncVat).RoundCost();
                calucatedClosingBalance.vat         = (openingBalance.vat       + vat       ).RoundCost();
                calucatedClosingBalance.quantity    = (openingBalance.quantity  + quantity  ).RoundQuantity(); 
            }

            // Discrepancies
            WFMAccountSheetData discrepancies = results.FirstOrDefault(s => s.section.SectionType == WFMStockAccountSheetSectionType.ClosingBalanceDiscrepancies);
            if (discrepancies != null && actulalClosingBalance != null && calucatedClosingBalance != null)
            {
                discrepancies.cost      = (calucatedClosingBalance.cost         - actulalClosingBalance.cost        ).RoundCost();
                discrepancies.costIncVat= (calucatedClosingBalance.costIncVat   - actulalClosingBalance.costIncVat  ).RoundCost();
                discrepancies.vat       = (calucatedClosingBalance.vat          - actulalClosingBalance.vat         ).RoundCost();
                discrepancies.quantity  = (calucatedClosingBalance.quantity     - actulalClosingBalance.quantity    ).RoundQuantity();
            }

            return results;
        }
    }
}
