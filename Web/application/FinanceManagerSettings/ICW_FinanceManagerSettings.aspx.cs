//===========================================================================
//
//						  ICW_FinanceManagerSettings.aspx.cs
//
//  Displays pn settings page to the user.
//
//  Call the page with the follow parameters
//  SessionID  - ICW session ID
//  
//  Usage:
//  ICW_FinanceManagerSettings.aspx?SessionID=123
//
//	Modification History:
//	28Oct11 XN  Written
//===========================================================================
using System;
using ascribe.pharmacy.shared;

public partial class application_FinanceManagerSettings_ICW_FinanceManagerSettings : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);
    }
}
