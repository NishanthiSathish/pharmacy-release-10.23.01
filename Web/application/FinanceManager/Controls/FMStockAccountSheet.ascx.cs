﻿//===========================================================================
//
//						        FMStockAccountSheet.ascx.cs
//
//  Control used to create a stock balance sheet.
//        
//  The control displays stock account header information, and a table of the 
//  WFMStockAccountSheetLayout sections showing section description, quantity, and value.
//
//  The sheet is built up using the data from tables WFMStockAccountSheetLayout
//  WFMLogCahce, and WFMDailyStockLevel, using following setting (to get account code)
//  System:  FinanceManager
//  Section: StockAccountSheet
//  Key:     AccountCode
//
//  The columns displayed in the sheet (Ex Vat, Inc Vat, and Vat) are configurable
//  System:  FinanceManager
//  Section: StockAccountSheet
//  Key:     DisplayColumns
//  Value:   CSV list of ExVat,IncVat,Vat
//  
//  Sheets are generated by calling the Create method. For a summary account 
//  sheet set the WFMStockAccountSheetSettings.NSVCode to blank, otherwise for a summary 
//  sheet for a particular drug fills these values in.
//  
//  The following html attributes are stored on the controls main panel
//      SheetID   - unique id of the sheet passed in to Create
//      Settings  - JSON serialised string of the settings passed into Create
//
//  Each row in the balance sheet can have the following attributes
//      id          - id from WFMStockAccountSheetLayout.WFMBalanceSheetLayoutID
//      parent_id   - for sub section in the sheet from 
//                    WFMStockAccountSheetLayout.WFMBalanceSheetLayoutID_Parent
//      sectionType = WFMStockAccountSheetLayout section type for row 
//      openRow     - for main section if row's sub sections are open or closed
//
//  Update sheet
//  ------------
//  The process flow when user clicks the drug description on a sheet
//      lbDrug_OnClick                          - java event fired when drug description on sheet is clicked
//          PharmacyProductSearchModal.aspx     - select drug screen for new account sheet to display
//              CreateStockAccountSheet         - Server web method (on ICW_FinanaceManager.aspx.cs) called by client to create new sheet (returns WFMBalanceSheetData)
//                  FMStockAccountSheet.Create  - called to create sheet (render HTML is extracted and passed client side in WFMBalanceSheetData)
//                      UpdateSheet             - client method called to update sheet takes WFMBalanceSheetData to display sheet
//
//  Usage:
//  To create a sheet
//  WFMStockAccountSheetSettings settings = new WFMStockAccountSheetSettings();
//  settings.startDate  = DateTime.Now.AddYear(-1);    
//  settings.endDate    = DateTime.Now.AddDay(-1);    
//  settings.siteNumbers= new int[]{ 503, 504, 505, 506 };
//  accountStockSheet.Create(settings);
//
//	Modification History:
//	15May13 XN  Written (27038) 
//  02Dec13 XN  Knock on changes for VAT account code handling 79631
//  07Jan14 XN  Rename Report headers 81136
//              Right justify value columns 81139
//              Expand All button 81143
//  09Jan14 XN  Added configurable value columns  
//  17Feb14 XN  If rule has vat account code then zero the tax (84499)
//              Swapped order of Ex Vat and Inc Vat columns
//  28Mar14 XN  Got LogView lookup to work in Stock acount popup (87377)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_FinanceManager_controls_FMStockAccountSheet : System.Web.UI.UserControl
{
    #region Constants
    // Column widths for grid
    private const int ColumnWidth_ExpandIcon    = 15;
    private const int ColumnWidth_Description   = 285;
    private const int ColumnWidth_Quantity      = 125;
    private const int ColumnWidth_ValueExVat    = 125;
    private const int ColumnWidth_ValueIncVat   = 125;
    private const int ColumnWidth_ValueVat      = 125;
    #endregion

    #region Member Variables
    /// <summary>Sheet setting</summary>
    protected WFMStockAccountSheetSettings settings;

    /// <summary>List of columns to display (Ex.Vat,Inc.Vat,Vat)</summary>
    protected FMStockAccountSheetColumnType[] displayColumns;
    #endregion

    /// <summary>Creates a balance sheet using  the data from WFMStockAccountSheetLayout WFMLogCahce, and WFMDailyStockLevel.</summary>
    /// <param name="showChangeDrugButtons">If the find,previous,next, and summary buttons are visible</param>
    public void Create(WFMStockAccountSheetSettings settings, bool showChangeDrugButtons)
    {
        this.settings = settings;
        bool summaryPage = string.IsNullOrEmpty(settings.NSVCode);

        short stockAccountCode = WFMSettings.StockAccountSheet.AccountCode;

        // get sites
        Sites site = new Sites();
        site.LoadAll();

        // Get columns to display
        this.displayColumns = WFMSettings.StockAccountSheet.DisplayColumns;

        // get layout info
        WFMStockAccountSheetLayout stockAccountSheetLayout = new WFMStockAccountSheetLayout();
        stockAccountSheetLayout.LoadAll();
        var ruleCodes   = stockAccountSheetLayout.SelectMany(s => s.RuleCodes).ToList();
        var siteIDs     = settings.siteNumbers.Select(s => site.FindSiteIDBySiteNumber(s) ?? 0).ToList();

        // get opening and closing balance and account sheet logs
        WFMLogCache logs = new WFMLogCache();
        logs.LoadByDatesSitesRulesAccountNSVCodes(settings.startDate, settings.endDate, siteIDs, ruleCodes, stockAccountCode, settings.NSVCode);

        WFMDailyStockLevel openingStockLevel = new WFMDailyStockLevel();
        openingStockLevel.LoadByDateSitesAndNSVCode(settings.startDate, siteIDs, settings.NSVCode);

        WFMDailyStockLevel closingStockLevel = new WFMDailyStockLevel();
        closingStockLevel.LoadByDateSitesAndNSVCode(settings.endDate, siteIDs, settings.NSVCode);

        WFMRule rules = new WFMRule();
        rules.LoadAll();

        // Get list of sites that can reclaim vat (has a vat account code set) (84499)
        IEnumerable<int> siteIDsThatReclaimVat;
        var rulesWithVatAccountCodes = rules.Where(r => ruleCodes.Contains(r.Code)).Where(r => r.AccountCode_Vat_Debit == stockAccountCode || r.AccountCode_Vat_Credit == stockAccountCode);
        if (rulesWithVatAccountCodes.Any(r => r.LocationID_Site == null))
            siteIDsThatReclaimVat = siteIDs;                                               // Vat account code applies to all sites so all sites must be able to reclaim vat
        else
            siteIDsThatReclaimVat = rulesWithVatAccountCodes.Select(r => r.LocationID_Site.Value).ToArray();  // Get sites that have vat account codes

        // Calculate sheet layout
        var accountSheetData = stockAccountSheetLayout.Layout(openingStockLevel, closingStockLevel, logs, siteIDsThatReclaimVat);

        // Calculate discrepancies (if needed)
        if ((settings.discrepancesNSVCodes == null || !settings.discrepancesNSVCodes.Any()) && summaryPage)
            settings.discrepancesNSVCodes = logs.CalculateDiscrepancies(stockAccountCode, openingStockLevel, closingStockLevel, siteIDsThatReclaimVat).Select(d => d.NSVCode).ToList();

        // Set sheet attributes
        this.pnStockAccountPanel.Attributes.Add("SheetID",  settings.sheetID.ToString());
        this.pnStockAccountPanel.Attributes.Add("Settings", Newtonsoft.Json.JsonConvert.SerializeObject(settings));

        // Get trust name
        ascribe.pharmacy.icwdatalayer.Location location = new ascribe.pharmacy.icwdatalayer.Location();
        location.LoadByLocationType("Trust");
        lbHospitalNam.Text = location.Any() ? location.First().Description : string.Empty;

        // Set header info
        lbDateCreated.Text       = DateTime.Now.ToPharmacyDateString();
        lbSites.Text             = "Site No: " + settings.siteNumbers.Select(s => s.ToString("000")).ToCSVString(" ");
        lbDatePeriod.Text        = string.Format("Period: {0} - {1}", settings.startDate.ToPharmacyDateString(), settings.endDate.ToPharmacyDateString());
        lbDrug.InnerText         = summaryPage ? "<Summary>" : string.Format("{0} - {1}", settings.NSVCode, WProduct.ProductDetails(settings.NSVCode));
        divRebuildWarning.Visible= WFMSettings.General.RebuildLogs;

        if (showChangeDrugButtons)
        {
            // Set search button
            btnSearch.Attributes.Add("onclick", string.Format("lbDrug_OnClick('{0}');", settings.sheetID.ToString())); 

            // Get index of the drug in the list of discrepancies (might not be there)
            int discrepancyIndex = -1;
            if (!summaryPage)
                discrepancyIndex = settings.discrepancesNSVCodes.IndexOf(settings.NSVCode);

            // Setup next and previous buttons
            btnPrevious.Visible = (summaryPage && settings.discrepancesNSVCodes.Count > 0) || discrepancyIndex >= 0;
            if (btnPrevious.Visible)
            {
                int previousIndex = discrepancyIndex - 1;
                if (previousIndex < 0)
                    previousIndex = settings.discrepancesNSVCodes.Count - 1;
                btnPrevious.Attributes.Add("onclick", string.Format("UpdateStockAccountSheet('{0}', '{1}');", settings.sheetID.ToString(), settings.discrepancesNSVCodes[previousIndex])); 
            }

            btnNext.Visible = (summaryPage && settings.discrepancesNSVCodes.Count > 0) || discrepancyIndex >= 0;
            if (btnNext.Visible)
            {
                int nextIndex = discrepancyIndex + 1;
                if (nextIndex >= settings.discrepancesNSVCodes.Count)
                    nextIndex = 0;
                btnNext.Attributes.Add("onclick", string.Format("UpdateStockAccountSheet('{0}', '{1}');", settings.sheetID.ToString(), settings.discrepancesNSVCodes[nextIndex])); 
            }

            btnSummary.Visible = !summaryPage;
            btnSummary.Attributes.Add("onclick", string.Format("UpdateStockAccountSheet('{0}', null);", settings.sheetID.ToString())); 

            // Got LogView lookup to work in Stock acount popup (87377) 28Mar14 XN  
            //btnLog.Visible = !summaryPage;
            //btnLog.Attributes.Add("onclick", string.Format("ViewLabUtils('{0}');", settings.sheetID.ToString())); 
        }
        else
        {
            btnSearch.Visible   = false;
            btnPrevious.Visible = false;
            btnNext.Visible     = false;
            btnSummary.Visible  = false;
        }

        // LogView button always visible (87377) 28Mar14 XN  
        btnLog.Visible = !summaryPage;
        btnLog.Attributes.Add("onclick", string.Format("ViewLabUtils('{0}');", settings.sheetID.ToString())); 

        // Create table
        CreateHeaderRow();
        CreateTable(settings.sheetID, rules, accountSheetData);
    }

    /// <summary>
    /// Returns the suggested colour mapping for the sheet (used when doing a print out)
    /// Maps web colours from the screen to HEdit colours
    /// </summary>
    public static IEnumerable<FinanceManagerReport.ColourMapInfo> GetColourMapping()
    {
        // Colour table index values can be found in FinanceManagerReport.ConvertToHEditColorIndex        
        List<FinanceManagerReport.ColourMapInfo> colorMap = new List<FinanceManagerReport.ColourMapInfo>();
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(65,  127, 143), colorTableIndex=9  /*D. Grey*/,  shadingPercentage=100}); // Font colour
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(86,   86,  82), colorTableIndex=14 /* Teal  */,  shadingPercentage=100}); // Font colour
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(234, 234, 234), colorTableIndex=15 /* Silver*/,  shadingPercentage=35 }); // Light grey background (supplier volumns)
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(220, 230, 251), colorTableIndex=9  /* Teal  */,  shadingPercentage=20 }); // header background
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb( 77, 158,  31), colorTableIndex=10 /* Green */,  shadingPercentage=100}); // border
        return colorMap;
    }

    #region Private Methods
    /// <summary>
    /// Create balance sheet table heading 
    ///     {Expand icon}
    ///     Description
    ///     Quantity
    ///     Value
    /// </summary>
    private void CreateHeaderRow()
    {
        TableRow headerRow = new TableRow();
        TableCell cell;
        int descriptionIndex;

        headerRow.Attributes.Add("headerRow", "1");

        // expand icon + Description (merged for the buttons)
        cell = new TableCell();
        cell.ColumnSpan = 2;
        cell.Width = new Unit(0);   // Calculate at end depending on number of columns
        cell.Text  = "<button class='PharmButtonSmall fm-sa-expandcollapsbutton' onclick='ExpandAll(\"" + settings.sheetID + "\", true);  return false;'>Expand All</button>" + 
                     "<button class='PharmButtonSmall fm-sa-expandcollapsbutton' onclick='ExpandAll(\"" + settings.sheetID + "\", false); return false;'>Collapse All</button>";
        descriptionIndex = headerRow.Cells.Add(cell);

        // Quantity
        cell = new TableCell();
        cell.Width = new Unit(ColumnWidth_Quantity);
        cell.Text  = "Quantity<br />(in issue units)";
        cell.CssClass = "fm-sa-table-header";
        cell.Style.Add(HtmlTextWriterStyle.TextAlign, "right");
        headerRow.Cells.Add(cell);

        // Inc Vat
        if (displayColumns.Contains(FMStockAccountSheetColumnType.IncVat))
        {
            cell = new TableCell();
            cell.Width = new Unit(ColumnWidth_ValueIncVat);
            cell.Text  = "Value Inc. " + PharmacyCultureInfo.SalesTaxName;
            cell.CssClass = "fm-sa-table-header";
            cell.Style.Add(HtmlTextWriterStyle.TextAlign, "right");
            headerRow.Cells.Add(cell);
        }

        // Ex Vat
        if (displayColumns.Contains(FMStockAccountSheetColumnType.ExVat))
        {
            cell = new TableCell();
            cell.Width = new Unit(ColumnWidth_ValueExVat);
            cell.Text  = "Value Ex. " + PharmacyCultureInfo.SalesTaxName;
            cell.CssClass = "fm-sa-table-header";
            cell.Style.Add(HtmlTextWriterStyle.TextAlign, "right");
            headerRow.Cells.Add(cell);
        }

        // Vat
        if (displayColumns.Contains(FMStockAccountSheetColumnType.Vat))
        {
            cell = new TableCell();
            cell.Width = new Unit(ColumnWidth_ValueVat);
            cell.Text  = PharmacyCultureInfo.SalesTaxName;
            cell.CssClass = "fm-sa-table-header";
            cell.Style.Add(HtmlTextWriterStyle.TextAlign, "right");
            headerRow.Cells.Add(cell);
        }

        // Recalculate description length
        double totalWidth   = headerRow.Cells.OfType<TableCell>().Sum(c => c.Width.Value);
        double allowedWidth = ColumnWidth_ExpandIcon + ColumnWidth_Description + ColumnWidth_Quantity + ColumnWidth_ValueExVat + ColumnWidth_ValueIncVat + ColumnWidth_ValueVat;
        headerRow.Cells[descriptionIndex].Width = new Unit(allowedWidth - totalWidth);

        // Add header
        table.Rows.Add(headerRow);
    }

    /// <summary>Create account sheet table</summary>
    /// <param name="sheetID">sheet ID</param>
    /// <param name="results">results to display</param>
    private void CreateTable(Guid sheetID, WFMRule rules, IEnumerable<WFMAccountSheetData> results)
    {
        Color? backgroundColour = null;
        Color? textColour       = null;

        foreach (WFMAccountSheetData result in results.OrderBy(r => r.section.SortIndex))
        {
            WFMStockAccountSheetLayoutRow section  = result.section;
            TableRow                headerRow = table.Rows[0];
            TableRow                row       = new TableRow();
            TableCell               cell;
            bool                    openingClosingBalance = section.SectionType != WFMStockAccountSheetSectionType.AccountSection && section.SectionType != WFMStockAccountSheetSectionType.MainSection;

            // If main section get new colour for section and sub sections
            if (section.SectionType != WFMStockAccountSheetSectionType.AccountSection)
            {
                backgroundColour = section.BackgroundColour;
                textColour       = section.TextColour;
            }

            // Set section text and background colour (comes from last main section)
            if (backgroundColour != null)
            {
                Color bc = backgroundColour.Value;
                if (section.SectionType == WFMStockAccountSheetSectionType.AccountSection)
                    bc = bc.Lighten(30);
                row.Style[HtmlTextWriterStyle.BackgroundColor] = bc.ToWebColorString();
            }
            if (textColour != null)
                row.Style[HtmlTextWriterStyle.Color] = textColour.Value.ToWebColorString();

            // Set row attributes
            row.Attributes["id"]          = section.WFMStockAccountSheetLayoutID.ToString();
            row.Attributes["sectionType"] = EnumDBCodeAttribute.EnumToDBCode(section.SectionType);
            if (section.SectionType == WFMStockAccountSheetSectionType.AccountSection)
            {
                row.Attributes["id_parent"] = section.WFMStockAccountSheetLayoutID_Parent.ToString();
                row.CssClass = "fm-sa-table-accountsection";
            }
            else
            {
                row.Attributes["openRow"] = "false";
                row.CssClass = "fm-sa-table-mainsection";
            }

            // Set row db click
            if (section.SectionType == WFMStockAccountSheetSectionType.AccountSection || section.SectionType == WFMStockAccountSheetSectionType.MainSection || section.SectionType == WFMStockAccountSheetSectionType.ClosingBalanceDiscrepancies)
                row.Attributes["ondblclick"] = string.Format("stockAccountSheetRow_OnDblClick('{0}', {1});", sheetID, section.WFMStockAccountSheetLayoutID);
            row.Attributes["onmousedown"] = string.Format("stockAccountTable_onmousedown(this);");

            // expand icon
            cell = new TableCell();
            cell.Width = new Unit(ColumnWidth_ExpandIcon);
            if (section.SectionType == WFMStockAccountSheetSectionType.MainSection)
                cell.Text = string.Format("<img src='../../images/grid/imp_open.gif' width='15' onclick=\"stockAccountSheetToggleSection('{0}', {1});\" />", sheetID, section.WFMStockAccountSheetLayoutID);
            row.Cells.Add(cell);

            // Description
            cell = new TableCell();
            cell.Width  = new Unit(ColumnWidth_Description);
            if (section.SectionType == WFMStockAccountSheetSectionType.AccountSection)
                cell.Text = "&nbsp;&nbsp;&nbsp;&nbsp;";
            cell.Text += section.ToStringWithFormatting();
            cell.CssClass = (section.SectionType == WFMStockAccountSheetSectionType.AccountSection) ? "fm-sa-table-accountsection" : "fm-sa-table-mainsection" ;
            row.Cells.Add(cell);

            // Quantity
            cell = new TableCell();
            cell.Width  = new Unit(ColumnWidth_Quantity);
            cell.Text   = "<span id='table-value'>" + ((result.quantity != null) ? result.quantity.Value.RoundQuantity().ToString("0.###") : "&nbsp;") + "</span>";
            cell.CssClass = "fm-sa-table-value";
            row.Cells.Add(cell);

            // Inc Vat
            if (displayColumns.Contains(FMStockAccountSheetColumnType.IncVat))
            {
                cell = new TableCell();
                cell.Width = new Unit(ColumnWidth_ValueIncVat);
                cell.Text += "<span id='table-value'>" + ((result.costIncVat != null) ? result.costIncVat.Value.RoundCost().ToMoneyString(MoneyDisplayType.Show) : "&nbsp;") + "</span>";
                cell.CssClass = "fm-sa-table-value";
                row.Cells.Add(cell);
            }

            // Ex Vat
            if (displayColumns.Contains(FMStockAccountSheetColumnType.ExVat))
            {
                cell = new TableCell();
                cell.Width = new Unit(ColumnWidth_ValueExVat);
                cell.Text  = "<span id='table-value'>" + ((result.cost != null) ? result.cost.Value.RoundCost().ToMoneyString(MoneyDisplayType.Show) : "&nbsp;") + "</span>";
                cell.CssClass = "fm-sa-table-value";
                row.Cells.Add(cell);
            }

            // Vat
            if (displayColumns.Contains(FMStockAccountSheetColumnType.Vat))
            {
                cell = new TableCell();
                cell.Width = new Unit(ColumnWidth_ValueVat);
                cell.Text += "<span id='table-value'>" + ((result.vat != null) ? result.vat.Value.RoundCost().ToMoneyString(MoneyDisplayType.Show) : "&nbsp;") + "</span>";
                cell.CssClass = "fm-sa-table-value";
                row.Cells.Add(cell);
            }

            // Add header
            table.Rows.Add(row);
        }
    }
    #endregion
}
