// -----------------------------------------------------------------------
// <copyright file="SelectRegimen.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Display list of regimens for the episode and allows user to select one
// Calls sp pPNRegimenForSelection
// 
// Modification History:
// 18Nov15 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

public partial class application_HongKong_SelectRegimen : System.Web.UI.Page
{
    /// <summary>Current patient episode id</summary>
    public int episodeId;

    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        this.episodeId = int.Parse(this.Request["EpisodeID"]);

        // Get list of regimens
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Add("EpisodeId", this.episodeId);
        parameters.Add("SiteId",    SessionInfo.SiteID);

        GenericTable2 data = new GenericTable2();
        data.LoadBySP("pPNRegimenForSelection", parameters);

        // Create the grid headers (request ID is not displayed)
        int descriptionColWidth = 100 - (data.Table.Columns.Count - 2) * 15;
        foreach (DataColumn col in data.Table.Columns)
        {
            if (!col.ColumnName.EqualsNoCase("RequestID"))
            {
                bool isDateTimeColumn = col.DataType.FullName == typeof(DateTime).FullName;
                gcGrid.AddColumn(col.ColumnName, col.ColumnName.EqualsNoCase("Description") ? descriptionColWidth : 15, isDateTimeColumn ? PharmacyGridControl.ColumnType.DateTime : PharmacyGridControl.ColumnType.Text, isDateTimeColumn ? PharmacyGridControl.AlignmentType.Center : PharmacyGridControl.AlignmentType.Left);
            }
        }

        // Display data
        foreach (var row in data)
        {
            gcGrid.AddRow();
            gcGrid.AddRowAttribute("RequestID", row.RawRow["RequestID"].ToString());

            int colIndex = 0;
            foreach (DataColumn col in data.Table.Columns)
            {
                if (!col.ColumnName.EqualsNoCase("RequestID"))
                {
                    bool isDateTimeColumn = col.DataType.FullName == typeof(DateTime).FullName;
                    object val = row.RawRow[col.Ordinal];
                    if (val == DBNull.Value)
                    {
                        gcGrid.SetCell(colIndex++, string.Empty);
                    }
                    else if (isDateTimeColumn)
                    {
                        gcGrid.SetCell(colIndex++, ((DateTime)val).ToPharmacyDateString());
                    }
                    else
                    {
                        gcGrid.SetCell(colIndex++, val.ToString().XMLEscape());
                    }
                }
            }
        }

        // Select the first row
        gcGrid.SelectRow(0);
    }
}