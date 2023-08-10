//===========================================================================
//
//					        ReferenceDataSelector.aspx.cs
//
//  Provides quick method of selecting and item from the pharmacy reference data.
//
//  Given a siteID, and context will load the data from WLookup, displaying it in
//  a list, for the user to select. Returns the selected items Code.
//
//  To access PIL use 
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  SiteID              - Site
//  Title               - Title to display on the page
//  Info                - Info text to display on the top of the page
//  selectedDBID        - DBID to select by default when form loads
//  ExtraLines          - Allows extra line to be added to the top of the list
//                        line must be csv list of column values (same number as columns + DB ID column)
//                              {DB ID},{column 1},{column 2},...  
//                        e.g. -1,<Add New Product>
//  contextType         - enum from WLookupContextType (e.g. Warning)
//
//  Usage:
//  Display list of all Instructionsm selects item with Code (DBID) e.g. 'DSW'
//  Has extra line at top of list '<No Instruction>'
//  ..\PharmacyReferenceData\ReferenceDataSelector.aspx?SessionID=512&SiteID=19&Title=Instructions&Info=Select Instruction&contextType=Instruction&selectedDBID=DSW&ExtraLines=,,<No Instruction>
//  
//	Modification History:
//  29Apr14	XN	88858 Created
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyReferenceData_ReferenceDataSelector : System.Web.UI.Page
{
    #region Protected Variables
    /// <summary>Title to display at top of screen (url parameter)</summary>
    protected string title;
    
    /// <summary>DBID to selected by default</summary>
    protected string selectedDBID;

    /// <summary>CSV of extra lines to display at top of list</summary>
    protected string extraLines;

    /// <summary>Context type</summary>
    protected WLookupContextType contextType;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        title           = Request["Title"        ];
        lbInfo.Text     = Request["Info"         ];
        selectedDBID    = Request["selectedDBID" ];
        extraLines      = Request["ExtraLines"   ];
        contextType     = ConvertExtensions.ChangeType<WLookupContextType>(Request["contextType"]);

        Populate();
    }

    /// <summary>Populate grid</summary>
    private void Populate()
    {
        // Setyp columns
        gcGrid.AddColumn("Code",        20);
        gcGrid.AddColumn("Description", 77);
        gcGrid.ColumnXMLEscaped(1, false);

        // Add the extra line by default (passed in via url)
        if (!string.IsNullOrEmpty(extraLines))
        {
            string[] rowData = extraLines.Split(',');

            gcGrid.AddRow();
            if (rowData[0].Length > 0 && rowData[0][0] == 65533)
                gcGrid.AddRowAttribute("DBID", "¡");    // Oddity with Warnsing and lookups where ¡ represents blank value (which does not come through on URL correctly) 28Oct14 XN Not really used anymore but kept in just incase
            else
                gcGrid.AddRowAttribute("DBID", rowData[0]);

            gcGrid.SetCell(0, rowData[1]);
            gcGrid.SetCell(1, string.IsNullOrWhiteSpace(rowData[2]) ? "&nbsp;" : rowData[2].XMLEscape());
        }

        // Load data
        WLookup lookups = new WLookup();
        lookups.LoadBySiteAndContext(SessionInfo.SiteID, contextType);

        // Populate list (use group by on code so only get single code)
        int selectedIndex = 0;
        foreach (var row in lookups.GroupBy(l => l.Code).OrderBy(l => l.Key))
        {
            string code  = row.Key;
            string value = row.OrderBy(l => l.WLookupID).First().ValueWithoutColourInfo();
            value = (string.IsNullOrWhiteSpace(value)) ? "&nbsp;" : value.XMLEscape().Replace("\r\n", "<br />");

            gcGrid.AddRow();
            gcGrid.AddRowAttribute("DBID", code);
            gcGrid.SetCell(0, code);
            gcGrid.SetCell(1, "<div style='ValueCell'>" + value + "</div>");

            if (code.EqualsNoCase(selectedDBID))
                selectedIndex = gcGrid.RowCount - 1;
        }

        // Select default row in grid
        string script = "try{ selectRow('gcGrid', " + selectedIndex.ToString() + ", true); gcGrid.focus(); } catch(ex) { }";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "select", script, true);
    }
}