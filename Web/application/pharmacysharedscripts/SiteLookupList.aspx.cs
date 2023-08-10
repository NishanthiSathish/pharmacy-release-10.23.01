// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ICW_PharmacyReport.aspx.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
// Displays list of sites to allow user to select
//  
// Desktop parameter for the page include
// SiteNumbers      - Optional list of site numbers to limit the list to (else will display all sites)
// AutoSelectSingle - If only 1 site in list then auto select
//      
//  Modification History:
//  19May15 XN  Created
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_pharmacysharedscripts_SiteLookupList : System.Web.UI.Page
{
    /// <summary>Load desktop</summary>
    /// <param name="sender">Sender object</param>
    /// <param name="e">Event args</param>    
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        IEnumerable<int> siteNumbers = (this.Request["SiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true);
        bool autoSelectSingle        = BoolExtensions.PharmacyParseOrNull(this.Request["AutoSelectSingle"]) ?? false;

        if (!this.IsPostBack)
        {
            var matched = siteNumbers.Any() ? Site2.Instance().FindBySiteNumber(siteNumbers) : Site2.Instance().ValidOnly();

            // If auto select single is enabled, and only 1 site then select and end
            if (autoSelectSingle && matched.Count() == 1)
            {
                this.ClosePage(matched.First().SiteID.ToString());
                return;
            }

            // Populate grid
            gcGrid.AddColumn("Site", 95);

            foreach (var site in matched.OrderBySiteNumber())
            {
                gcGrid.AddRow();
                gcGrid.AddRowAttribute("SiteID", site.SiteID.ToString());
                gcGrid.SetCell(0, site.ToString());
            }

            // Select first row is present
            if (gcGrid.RowCount > 0)
            {
                gcGrid.SelectRow(0);
            }

            // Set focus to grid
            ScriptManager.RegisterStartupScript(this, this.GetType(), "select", "try{ $('#gcGrid').focus(); } catch(ex) { }", true);
        }
    }
}