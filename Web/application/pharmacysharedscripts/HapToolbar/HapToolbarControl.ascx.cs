// --------------------------------------------------------------------------------------------------------------------
// <copyright file="HapToolbarControl.ascx.cs" company="Ascribe Ltd">
//     Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
// Provides a telerik toolbar populated from the ToolMenu DB table (loaded by WindowID from query string)
//
// Each button in the tool menu will be give attribute eventName=ToolMenu.EventName
// There are client side method to 
//      HapToolbarEnable    - Enable\disable toolbar button
//      HapToolbarClick     - Called to click a toolbar button
//      HapToolbarSetImage  - Set toolbar button image
//
// Usage
//  <%@ Register src="../pharmacysharedscripts/HapToolbar/HapToolbarControl.ascx" tagname="Toolbar" tagPrefix="uc" %>
//  :
//  <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"                 async></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/HapToolbar/HapToolbarControl.js" async></script>>
//  :
//  <uc1:GridControl ID="userGrid" runat="server" CellSpacing="0" CellPadding="2" />
//      
//  Modification History:
//  01Jun15 XN Created 39882
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System;
using ascribe.pharmacy.icwdatalayer;
using Telerik.Web.UI;

public partial class HapToolbarControl : System.Web.UI.UserControl
{
    /// <summary>
    /// Called when page is loaded
    /// Loads the tool menu from ToolMenu via WindowID
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The event</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            // Load tool bar
            ToolMenu toolMenu = new ToolMenu();
            toolMenu.LoadByWindowID(int.Parse(this.Request["WindowID"]));

            // Populate toolbar
            foreach (ToolMenuRow toolMenuRow in toolMenu)
            {
                RadToolBarButton button = new RadToolBarButton();
                if (toolMenuRow.Divider)
                {
                    button.IsSeparator = true;
                }
                else
                {
                    if (!string.IsNullOrEmpty(toolMenuRow.GetFullButtonImagePath()))
                    {
                        button.ImageUrl = toolMenuRow.GetFullButtonImagePath();
                    }

                    if (!string.IsNullOrEmpty(toolMenuRow.EventName))
                    {
                        button.CommandName = string.Format("{0}('{1}', {2})", toolMenuRow.EventName, toolMenuRow.ButtonData, toolMenuRow.WindowID);
                        button.Attributes.Add("eventName", toolMenuRow.EventName);
                    }
                    
                    button.Text        = toolMenuRow.Description;
                    button.ToolTip     = toolMenuRow.Detail;
                }

                radToolbar.Items.Add(button);
            }            
        }
    }
}