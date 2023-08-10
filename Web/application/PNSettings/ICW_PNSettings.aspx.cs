//===========================================================================
//
//						      ICW_PNSettings.aspx.cs
//
//  Displays pn settings page to the user.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - site number
//  ReplicateToSiteNumbers      - Sites allowed to replicate to (optional)
//  SiteNumbersSelectedByDefault- Replicate to sites selected by default (optional)
//  
//  Usage:
//  ICW_PNSettings.aspx?SessionID=123&AscribeSiteNumber=503
//
//	Modification History:
//	28Oct11 XN  Written
//===========================================================================
using System;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;

public partial class application_PN_Settings_ICW_PNSettings : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        int siteNumber = int.Parse(Request["AscribeSiteNumber"]);

        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        PNLog.WriteToLog(SessionInfo.SiteID, "User has viewed PN settings desktop");
    }
}
