// -----------------------------------------------------------------------
// <copyright file="Contracts.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Displays information about Contracts for the WExtraDrugData table.
//
// Call the page with the follow parameters
// SessionID           - ICW session ID
// AscribeSiteNumber   - Pharmacy site
// HideCost            - 1 to hide prices\costs, else 0
// NSVCode             - NSV code of pharmacy product to display.
//  
// Usage:
// Requisitions.aspx?SessionID=123&AscribeSiteNumber=504&HideCost=1&NSVCode=AAA0001
//
// Modification History:
// 11Jul15 XN  Created 126634
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class application_StoresDrugInfoView_Contracts : System.Web.UI.Page
{
    /// <summary>NSV Code</summary>
    protected string NSVCode;

    /// <summary>Display money setting</summary>
    protected MoneyDisplayType moneyDisplayType;

    /// <summary>Load the page</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        
        // Load in the query string parameters
        this.NSVCode          = this.Request.QueryString["NSVCode"];
        this.moneyDisplayType = BoolExtensions.PharmacyParse(this.Request.QueryString["HideCost"]) ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;

        if (!IsPostBack)
        {
            // Load the contracts
            WExtraDrugDetail contracts = new WExtraDrugDetail();
            contracts.LoadBySiteIdAndNSVCode(SessionInfo.SiteID, this.NSVCode);

            var currentlyActive = contracts.GroupBy(c => c.SupCode).Select(c => c.FindByIsActive()).Where(c => c != null).ToList();

            // fill the active and upcoming grid
            var activeAndUpcoming = contracts.FindByIsStillDue().ToList();
            activeAndUpcoming.AddRange(currentlyActive);
            activeAndUpcoming = (from c in activeAndUpcoming 
                                 orderby c.SupCode, c.DateUpdated_ByOvernighJob == null, c.DateOfChange descending, c.WExtraDrugDetailID descending 
                                 select c).ToList();
            this.PopulateActiveAndUpcoming(activeAndUpcoming);

            // fill the expired contracts grid
            int listToDisplayContractsInYears = StoresDrugInfoViewSetting.LimitToDisplayContractsInYears;
            lblHistoricalContracts.Text = string.Format(lblHistoricalContracts.Text, listToDisplayContractsInYears);

            DateTime fromDate = DateTime.Today.AddYears(-listToDisplayContractsInYears);
            var expried = (from c in contracts.FindByActiveOrExpired()
                          where c.DateOfChange > fromDate && 
                                currentlyActive.All(a => a.WExtraDrugDetailID != c.WExtraDrugDetailID)
                          orderby c.SupCode, c.DateOfChange descending, c.WExtraDrugDetailID descending, c.StopDate ?? DateTime.MaxValue  descending
                          select c).ToList();
            this.PopulateExpiredContracts(expried);
        }
    }

    /// <summary>Populate the list of active and upcoming items</summary>
    /// <param name="rows">Rows to populate grid with</param>
    private void PopulateActiveAndUpcoming(IEnumerable<WExtraDrugDetailRow> rows)
    {        
        IQSDisplayAccessor[] accessors = new IQSDisplayAccessor[]{ new WExtraDrugDetailAccessor(this.moneyDisplayType) };
        
        // Load grid config settings
        activeAndUpcomingGrid.QSLoadConfiguration(SessionInfo.SiteID, "StoresDrugInfo", "ActiveAndUpcoming");
        if (!Winord.EnableEdiLinkCode)
        {
            // If edi link code not enabled then remove
            var ediLinkCodeFieldData = QSField.GetByAccessorTagAndProperty("Contracts", "NewEDIBarcode");
            if (ediLinkCodeFieldData != null)
            {
                var ediLinkCodeFieldID = ediLinkCodeFieldData.QSFieldID;
                var ediLinkCodeField = activeAndUpcomingGrid.QSDisplayItems.FirstOrDefault(r => r.QSFieldID == ediLinkCodeFieldID);
                activeAndUpcomingGrid.QSDisplayItems.Remove(ediLinkCodeField);
            }
        }

        // Populate grid
        activeAndUpcomingGrid.AddColumnsQS();        
        foreach (var r in rows)
            activeAndUpcomingGrid.AddRowQS(new BaseRow[] { r }, accessors);
    }

    /// <summary>Populate the list of expired items</summary>
    /// <param name="rows">Rows to populate grid with</param>
    private void PopulateExpiredContracts(IEnumerable<WExtraDrugDetailRow> rows)
    {
        IQSDisplayAccessor[] accessors = new IQSDisplayAccessor[]{ new WExtraDrugDetailAccessor(this.moneyDisplayType) };
        
        // Load grid config settings
        expiredContractsGrid.QSLoadConfiguration(SessionInfo.SiteID, "StoresDrugInfo", "ExpiredContracts");
        if (!Winord.EnableEdiLinkCode)
        {
            // If edi link code not enabled then remove
            var ediLinkCodeFieldData = QSField.GetByAccessorTagAndProperty("Contracts", "NewEDIBarcode");
            if (ediLinkCodeFieldData != null)
            {
                var ediLinkCodeFieldId = ediLinkCodeFieldData.QSFieldID;
                var ediLinkCodeField = expiredContractsGrid.QSDisplayItems.FirstOrDefault(r => r.QSFieldID == ediLinkCodeFieldId);
                expiredContractsGrid.QSDisplayItems.Remove(ediLinkCodeField);
            }
        }

        // Populate grid
        expiredContractsGrid.AddColumnsQS();
        foreach (var r in rows)
            expiredContractsGrid.AddRowQS(new BaseRow[] { r }, accessors);
    }
}