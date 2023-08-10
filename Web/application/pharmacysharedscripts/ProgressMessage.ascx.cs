//===========================================================================
//
//							      ProgressMessage.ascx.cs
//
//  Provides a reusable progress message.
//  
//  To be able to use the control you will need to include jquery-1.3.2.js or 
//  higher, and then just add the control to the page
//
//  Usage:
//  in your html add
//  <script type="text/javascript" src="../SharedScripts/lib/jquery-1.3.2.min.js" />
//  :
//  <%@ Register src="pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>
//  :
//  <pc:ProgressMessage ID="progressMessage" runat="server" />
//
//	Modification History:
//	02Aug13 XN  Written
//  19Sep14 XN  Dropped time out from 2 to 1.5 secs
//===========================================================================
using System;
using System.Web.UI;

public partial class application_pharmacysharedscripts_ProgressMessage : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "InitProgressMessage", "SetupProgressMsg();", true);
    }
}
