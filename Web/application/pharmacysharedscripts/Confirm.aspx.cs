// --------------------------------------------------------------------------------------------------------------------
// <copyright file="Confirm.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Confirm message
//       
//  Call the page with the follow parameters
//  Msg                 - Message to display
//  EscapeReturnValue   - (optional) value to return if the user press X, or escapes
//  DefaultButton       - OK or cancel for the default button
//  OkText              - Text for the OK button
//  CancelText          - Text for the Cancel button
//
//  Page will return the true if okay button is pressed, false for cancel button, or EscapeReturnValue if user close form
//      
//  Modification History:
//  18Feb15 XN  Created
//  03Jul15 XN  Fixed default EscapeReturnValue 39882
//  24Jul15 XN  Added OkText, CancelText options, and setting keyboard shortcuts 114905
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using ascribe.pharmacy.shared;

/// <summary>Confirm message box</summary>
public partial class application_pharmacysharedscripts_Confirm : System.Web.UI.Page
{
    /// <summary>Gets escape return value</summary>
    protected string EscapeReturnValue { get; private set; }

    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">Page sender</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        this.lbMsg.InnerHtml    = this.Request["Msg"];
        this.EscapeReturnValue  = this.Request["EscapeReturnValue"] ?? "false";
        this.btnOK.Value        = this.Request["OkText"]     ?? "OK";       // Added 24Jul15 XN 114905
        this.btnCancel.Value    = this.Request["CancelText"] ?? "Cancel";   // Added 24Jul15 XN 114905

        this.btnOK.Attributes.Add    ("accesskey", this.btnOK.Value.SafeSubstring    (0, 1));   // Added 24Jul15 XN 114905
        this.btnCancel.Attributes.Add("accesskey", this.btnCancel.Value.SafeSubstring(0, 1));   // Added 24Jul15 XN 114905

        if ("Cancel".EqualsNoCase(this.Request["DefaultButton"]))
        {
            this.btnCancel.Focus();
        }
        else 
        {
            this.btnOK.Focus();
        }
    }
}