//===========================================================================
//
//					            BNFLookup.aspx.cs
//
//  Displays list of all BNF codes, return the selected code, or undefined
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number   } On or the other
//  SiteID              - Site ID       }
//  Depth               - Default depth to show BNF code 
//                        between 1 to 4
//                        Overridden by config setting D|stkmaint.BNFlevels.Display if presnet
//  SelectedBNF         - Default selected BNF code (if present in list)
//  
//  Usage:
//  BNFLookup.aspx?SessionID=123&AscribeSiteNumber=3232&Depth=3@SelectedBNF=01.02.03
//
//	Modification History:
//	19Dec13 XN   78339 Created
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;

public partial class application_PharmacyProductEditor_BNFLookup : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int depth          = int.Parse(Request["Depth"]);
        string selectedBNF = Request["SelectedBNF"] ?? string.Empty;

        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Setting overrides the depth passed in
        depth = WConfiguration.Load(SessionInfo.SiteID, "D|stkmaint", "BNFlevels", "Display", depth, false);
        if (depth < 1 || depth > 4)
            depth = 4;

        // Load BNF settings
        List<SqlParameter> parameters = new List<SqlParameter>();
        GenericTable2 table = new GenericTable2();
        parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
        parameters.Add(new SqlParameter("@depth",            depth                ));
        table.LoadBySP("pOrderCatalogueSelectForPharmacyBNF", parameters);

        // List codes
        gcBNF.AddColumn("Code",        15);
        gcBNF.AddColumn("Description", 85);

        int selectedIndex = 0;
        foreach(var row in table)
        {
            string bnfCode = row.RawRow["Code"].ToString();
            gcBNF.AddRow();
            gcBNF.AddRowAttribute("Code", bnfCode);
            gcBNF.SetCell(0, bnfCode);
            gcBNF.SetCell(1, row.RawRow["Value"].ToString());

            if (selectedBNF == bnfCode)
                selectedIndex = gcBNF.RowCount - 1;
        }

        // Select code by default
        string script = string.Format("selectRow('gcBNF', {0}, true); $('#gcBNF').focus();", selectedIndex);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "selectRow", script, true);
    }
}