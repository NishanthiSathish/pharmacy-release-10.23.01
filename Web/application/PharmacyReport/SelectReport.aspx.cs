// --------------------------------------------------------------------------------------------------------------------
// <copyright file="SelectReport.aspx.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
// Allows selection of a report
//
// Will return the index (as defined in ReportName so 1 based index) of the selected report.
// 
// Parameter for the page include
// ReportName1  - 1st report name
// ReportName2  - 2nd report name
// ReportName3  - 3rd report name
// etc
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System;
using System.Web.UI;

using ascribe.pharmacy.shared;

/// <summary>Desktop to allow a user to select, and view and number of SSRS local reports (rdlc)</summary>
public partial class application_PharmacyReport_SelectReport : System.Web.UI.Page
{
    #region Constants
    /// <summary>Max number of allowed reports</summary>
    private const int MaxNumberOfReports = 15;
    #endregion

    /// <summary>Load desktop</summary>
    /// <param name="sender">Sender object</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        gcGrid.AddColumn("Report", 99);

        // Add list of reports
        for (int r = 1; r < MaxNumberOfReports; r++)
        {
            string name = this.Request["ReportName" + r];
            if (!string.IsNullOrWhiteSpace(name))
            {
                gcGrid.AddRow();
                gcGrid.AddRowAttribute("index", r.ToString());
                gcGrid.SetCell(0, name);
            }
        }

        // Select first line of the report
        if (gcGrid.RowCount > 0)
        {
            gcGrid.SelectRow(0);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "setTimeout(function(){ $('#gcGrid').focus() }, 500);", true);
        }
    }
}