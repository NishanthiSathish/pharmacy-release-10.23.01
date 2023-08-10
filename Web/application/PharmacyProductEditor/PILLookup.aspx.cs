//===========================================================================
//
//					            PILLookup.aspx.cs
//
//  Displays list of all Patient Information Leaflets.
//
//  The form is an initial replacement to vb6 ProdStockEditor.bas EditFiles
//  but does not currently handle viewing, editing or creating new files
//  There are security issues with getting IIS to open the file (from server side)
//
//  Theses are read from WConfiguration
//  Category: D|PILdesc
//  Section: <Blank>
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number   } On or the other
//  SiteID              - Site ID       }
//  SelectedPIL         - Default selected PIL code (if present in list)
//
//  Returns the selected PIL filename (without the extension).
//  
//  Usage:
//  PILLookup.aspx?SessionID=123&AscribeSiteNumber=3232&SelectedPIL=05
//
//	Modification History:
//	17Jan14 XN   78339 Created
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;
using System.Web.Services;
using System.IO;

public partial class application_PharmacyProductEditor_PILLookup : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        string selectedPIL = Request["SelectedPIL"] ?? string.Empty;

        // Load PIL settings
        WConfiguration config = new WConfiguration();
        config.LoadBySiteCategoryAndSection(SessionInfo.SiteID, "D|PILdesc", string.Empty);

        int numEntries = 0;
        var numEntriesRow = config.FindByKey("NumEntries");
        if (numEntriesRow == null || int.TryParse(numEntriesRow.Value, out numEntries))
            numEntries = config.Count;

        // List codes
        gcPIL.AddColumn("File",        15);
        gcPIL.AddColumn("Description", 85);

        // try to order them but keep safe
        int selectedIndex = 0, temp;
        var orderedRows = config.Where(c => int.TryParse(c.Key, out temp) && temp <= numEntries).OrderBy(c => int.Parse(c.Key));
        foreach(WConfigurationRow c in orderedRows)
        {
            string[] value = c.Value.Split(new [] { '|' });
            string   PILFile    = value.Length > 0 ? value[0] : string.Empty;
            string   code       = PILFile.Split(new [] { '.' })[0];
            string   descritpion= value.Length > 1 ? value[1] : string.Empty;

            gcPIL.AddRow();
            gcPIL.AddRowAttribute("Code", code);
            gcPIL.SetCell(0, PILFile    );
            gcPIL.SetCell(1, descritpion);

            if (selectedPIL == code)
                selectedIndex = gcPIL.RowCount - 1;
        }

        // Select code by default
        string script = string.Format("selectRow('gcPIL', {0}, true); $('#gcPIL').focus();", selectedIndex);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "selectRow", script, true);    
    }

}