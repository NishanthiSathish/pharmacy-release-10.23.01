// -----------------------------------------------------------------------
// <copyright file="ICW_aMMSettings.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Displays the amm settings, the page mainly calls controls that do the
// main work for the page.
//
// Currently only editing amm shifts are supported.
// 
// Modification History:
// 15May16 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using ascribe.pharmacy.shared;

public partial class application_aMMSettings_ICW_aMMSettings : System.Web.UI.Page
{
    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
    }
}