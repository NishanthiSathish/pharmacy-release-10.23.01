//===========================================================================
//
//					          AbbreviationRule.aspx.cs
//
//  Displays the abbreviation rule editor.
//
//  abbreviation rules is saved to the WConfiguration setting
//      D|mechdisp.common.AbbreviationRules
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number   } On or the other
//  SiteID              - Site ID       }
//  
//  Usage:
//  AbbreviationRule.aspx?SessionID=123&AscribeSiteNumber=3232
//
//	Modification History:
//	13Jan14 XN   78339 Created
//===========================================================================
using System;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyProductEditor_AbbreviationRule : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        if (!this.IsPostBack)
            tbText.Text = WConfiguration.Load<string>(SessionInfo.SiteID, "D|mechdisp", "common", "AbbreviationRules", string.Empty, false);
    }

    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        WConfiguration.Save(SessionInfo.SiteID, "D|mechdisp", "common", "AbbreviationRules", tbText.Text, false);
        this.ClosePage();
    }
}