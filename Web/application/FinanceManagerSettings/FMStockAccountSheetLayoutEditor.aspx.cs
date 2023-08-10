//===========================================================================
//
//						     FMStockAccountSheetLayoutEditor.aspx.cs
//
//  Displays layout of finance manager balance sheet.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//
//  Usage:
//  FMStockAccountSheetLayoutEditor.aspx?SessionID=123
//
//	Modification History:
//  30Apr13 XN  Created 27038
//===========================================================================
using System;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;

public partial class application_FinanceManagerSettings_FMStockAccountSheetLayoutEditor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        if (!this.IsPostBack)
        {
            // Get the account code used for the balance sheet
            WFMAccountCode accountCode = new WFMAccountCode();
            accountCode.LoadByCode(WFMSettings.StockAccountSheet.AccountCode);
            lbAccountCode.Text = accountCode.Any() ? accountCode[0].ToString() : WFMSettings.StockAccountSheet.AccountCode.ToString();

            // Setup the Add\Delete buttons
            btnAddSection.Visible = WFMSettings.StockAccountEditor.AllowAdd;
            btnAddAccount.Visible = WFMSettings.StockAccountEditor.AllowAdd;
            btnDelete.Visible     = WFMSettings.StockAccountEditor.AllowDelete;

            // Fill gird
            PopulateGrid();
        }

        // Deal with __postBack events
        string args = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];

        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "Refresh" :
                // Refresh after update
                PopulateGrid();
                if (argParams.Length > 1)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshed", "selectRowByID(" + argParams[1] + ");", true);
                break;
            }
        }
    }

    /// <summary>
    /// Called when refresh button is clicked
    /// Repopulates the list
    /// </summary>
    protected void btnRefresh_OnClick(object sender, EventArgs e)
    {
        PopulateGrid();
    }

    /// <summary>Populates the list</summary>
    protected void PopulateGrid()
    {
        Color? backgroundColor = null;
        Color? textColor       = null;

        // Load balance sheet layout
        WFMStockAccountSheetLayout StockAccountSheetLayout = new WFMStockAccountSheetLayout();
        StockAccountSheetLayout.LoadAll();

        // Setup grid
        gridItemList.AddColumn("Description", 100);
        gridItemList.ColumnAllowTextWrap (0, true);
        gridItemList.ColumnKeepWhiteSpace(0, true);

        // Populate list
        foreach (var sheetRow in StockAccountSheetLayout.OrderBy(s => s.SortIndex))
        {
            gridItemList.AddRow();
            gridItemList.AddRowAttribute("SectionType", EnumDBCodeAttribute.EnumToDBCode(sheetRow.SectionType));
            gridItemList.AddRowAttribute("RecordID",    sheetRow.WFMStockAccountSheetLayoutID.ToString());
            if (sheetRow.WFMStockAccountSheetLayoutID_Parent != null)
                gridItemList.AddRowAttribute("RecordID_Parent", sheetRow.WFMStockAccountSheetLayoutID_Parent.Value.ToString());

            if (sheetRow.SectionType != WFMStockAccountSheetSectionType.AccountSection)
            {
                backgroundColor = sheetRow.BackgroundColour;
                textColor       = sheetRow.TextColour;
            }
            
            gridItemList.SetCell(0, sheetRow.ToStringWithFormatting());
            if (backgroundColor != null)
            {
            
                Color bc = backgroundColor.Value;
                if (sheetRow.SectionType == WFMStockAccountSheetSectionType.AccountSection)
                    bc = bc.Lighten(30);
                gridItemList.SetRowBackgroundColour(bc.ToWebColorString());
            }
            if (textColor != null)
                gridItemList.SetRowTextColour(textColor.Value.ToWebColorString());
        }
    }
}
