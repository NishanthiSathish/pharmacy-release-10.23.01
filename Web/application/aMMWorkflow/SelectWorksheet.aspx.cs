// -----------------------------------------------------------------------
// <copyright file="SelectWorksheet.aspx.cs" company="Emis Health Plc">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// Allows selection of the manufacturing worksheet for printing. 
// 
//  Modification History:
//  26Apr15 XN Created 123082
// </summary
// -----------------------------------------------------------------------
using System;
using System.Linq;
using System.Web.UI.WebControls;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.shared;

public partial class application_aMMWorkflow_SelectWorksheet : System.Web.UI.Page
{
    /// <summary>Populates the page</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        int formulaId = int.Parse(this.Request["wformulaId"]);
        
        var listItem = WFormula.GetById(formulaId).Layout().Where(l => !string.IsNullOrWhiteSpace(l)).Select(l => new ListItem(l)).ToArray();
        lbSheetToPrint.Items.AddRange(listItem);

        if (lbSheetToPrint.Items.Count > 0);
            lbSheetToPrint.SelectedIndex = 0;            
    }
}