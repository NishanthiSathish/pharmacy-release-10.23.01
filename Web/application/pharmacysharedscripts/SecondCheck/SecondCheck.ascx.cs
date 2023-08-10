// -----------------------------------------------------------------------
// <copyright file="SecondCheck.ascx.cs" company="Emis Health">
//   Copyright (c) Emis Health Plc. All rights reserved.
// </copyright>
// <summary>
// Allow second user to enter username, and password to perform a second check
//
// Self check
// ----------
// Under default setting you can self check, whoever this can be prevented by passing
// the current username and password to the validate function.
//      ucSecondCheck.Validate(new [] { SessionInfo.EntityID });
// It is possible to pass a number of users to Validate to prevent them from second checking
// 
// Alternatively it is possible to pass a number of users to EntityIDsForSelfCheck, that
// if they enter a username and password they have to provide a self check reason.
//      ucSecondCheck.EntityIDsForSelfCheck = new [] { SessionInfo.EntityID };
//      :
//      ucSecondCheck.Validate();
//      :
//      if (ucSecondCheck.ShowSelfCheckReason)
//          var selfCheckReason = ucSecondCheck.SelfCheckReason;
//
// Usage
// On web side
// <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
// <%@ Register src="../pharmacysharedscripts/SecondCheck/SecondCheck.ascx" tagName="SecondCheck" tagPrefix="uc" %>
//
// <uc:SecondCheck ID="ucSecondCheck" runat="server" />
//
// First validate on client side by calling 
// validateSecondCheck(sessionId, 'ucSecondCheck');
//
// On server side to prevent self checking 
// if (ucSecondCheck.Validate(new [] { SessionInfo.EntityID }))
//    entiyId = ucSecondCheck.EntityId
//
//
// On server side to allow self checking with reason (call before display)
// ucSecondCheck.EntityIDsForSelfCheck = new [] { SessionInfo.EntityID };
// 
// First validate on client side by calling 
// validateSecondCheck(sessionId, 'ucSecondCheck');
//
// then on server
// if (ucSecondCheck.Validate())
// {
//    entiyId = ucSecondCheck.EntityId;
//    reason  = ucSecondCheck.SelfCheckReason;
// }
//
//
// On server side to allow self checking without reason
// First validate on client side by calling 
// validateSecondCheck(sessionId, 'ucSecondCheck');
//
// then on server
// if (ucSecondCheck.Validate())
//    entiyId = ucSecondCheck.EntityId;
//
// Modification History:
// 02Jul15 XN Created 39882
// 08Aug16 XN Allowed second check of other user not just self 159843
// </summary
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Xml.Linq;

using ascribe.pharmacy.shared;

using SECDTL10;
using System.Text;

public partial class SecondCheck : System.Web.UI.UserControl
{
    /// <summary>Entity that entered the username and password</summary>
    public int? EntityId { get { return string.IsNullOrEmpty(hfEntityID.Value) ? (int?)null : int.Parse(hfEntityID.Value); } }

    /// <summary>Gets or sets a value indicating whether control is enabled</summary>
    public bool Enabled
    {
        get { return tbPassword.Enabled; }
        set { tbPassword.Enabled = tbUsername.Enabled = value; }
    }

    /// <summary>If users is allows to self check</summary>
    public IEnumerable<int> EntityIDsForSelfCheck
    {
        get { return hfEntityIDsForSelfCheck.Value.ParseCSV<int>(",", true);                                         }
        set { hfEntityIDsForSelfCheck.Value = value.Any() ? "," + value.ToCSVString(",") + "," : string.Empty; }
    }

    /// <summary>Gets text entered in the self check reason</summary>
    public string SelfCheckReason
    {
        get { return this.ShowSelfCheckReason ? tbSelfCheckReason.Text : string.Empty; }
        set { tbSelfCheckReason.Text = value;                                          }
    }

    /// <summary>If showing self check reason box</summary>
    private bool ShowSelfCheckReason
    {
        get { return BoolExtensions.PharmacyParseOrNull(hfShowSelfCheckReason.Value) ?? false; }
        set { hfShowSelfCheckReason.Value = value.ToOneZeorString();                           }
    }

    /// <summary>Called on paged load</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        tbUsername.Attributes.Add("onfocus", "this.select();");
        tbPassword.Attributes.Add("onfocus", "this.select();");
        tbSelfCheckReason.Attributes.Add("onfocus", "this.select();");
    }

    /// <summary>Called to prerender page</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        trSelfCheckReasonRow1.Style.Add(HtmlTextWriterStyle.Display, this.ShowSelfCheckReason ? "display" : "none");
        trSelfCheckReasonRow2.Style.Add(HtmlTextWriterStyle.Display, this.ShowSelfCheckReason ? "display" : "none");

        if (!this.Page.ClientScript.IsClientScriptIncludeRegistered("secondCheck"))
            this.Page.ClientScript.RegisterClientScriptInclude("secondCheck", ResolveClientUrl("~/application/pharmacysharedscripts/SecondCheck/SecondCheck.js"));
        if (!this.Page.ClientScript.IsClientScriptIncludeRegistered("helperWebService"))
            this.Page.ClientScript.RegisterClientScriptInclude("helperWebService", ResolveClientUrl("~/application/pharmacysharedscripts/HelperWebService.js"));
        if (!this.Page.ClientScript.IsClientScriptIncludeRegistered("json2"))
            this.Page.ClientScript.RegisterClientScriptInclude("json2", ResolveClientUrl("~/application/sharedscripts/json2.js"));
    }

    /// <summary>
    /// Validate the user
    /// 1. Check username and password
    /// 2. Check user is not the currently selected user (optional)
    /// </summary>
    /// <param name="entityIdExcluded">List of entity ids that are not allowed to perform the second check</param>
    /// <returns>If control details are valid</returns>
    public bool Validate(IEnumerable<int> entityIdExcluded = null)
    {
        SECDTL10.SecurityAdminRead securityAdmin = new SecurityAdminRead();
        XElement xml = XElement.Parse(securityAdmin.ValidateUserNameAndPassword(SessionInfo.SessionID, tbUsername.Text, tbPassword.Text));
        bool valid;
        int entityId;
        string error;

        var  userElement  = xml.Element("User");
        if (userElement == null || userElement.Attribute("EntityID") == null || !int.TryParse(userElement.Attribute("EntityID").Value, out entityId))
        {
            divError.InnerText = "Invalid username or password";
            tbPassword.Focus();
            valid = false;
        }
        else if (entityIdExcluded != null && entityIdExcluded.Contains(entityId))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "focusUsername", "$('input[id$=tbUsername]').focus();", true);
            divError.InnerText = "Can't second check this";
            valid = false;
        }
        else if (this.ShowSelfCheckReason && !Validation.ValidateText(tbSelfCheckReason, "Self Check Reason", typeof(string), true, out error))
        {
            divError.InnerText = error;                    
            valid = false;
        }
        else
        {
            hfEntityID.Value = entityId.ToString();
            valid = true;
        }        

        return valid;
    }
}