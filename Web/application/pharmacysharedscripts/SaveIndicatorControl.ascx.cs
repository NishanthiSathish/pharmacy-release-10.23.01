//===========================================================================
//
//					    SaveIndicatorControl.aspx.cs
//
//  Displays if data in the form has been saved.
//  If page is dirty displays 'Unsaved' message in red.
//  
//  If you want to show 'Saved' message when page is not dirty
//  call si_showSave(true) (or serverside method ShowSavedText) this automatically 
//  overwritten by Unsaved when page is drity again.
//  Call si_showSave(false) to cleare the 'Saved' massage (when new item loaded)
//
//  To force update of control call clinet side si_Update, or side Update
//
//  Gets it's information from pharmacyscript.js isPageDirty flag.
//  (pools the flag on an 1.5 sec interval)
//
//  Usage:
//  <%@ Register src="../pharmacysharedscripts/SaveIndicatorControl.ascx" tagname="SaveIndicator" tagprefix="uc" %>
//  :
//  <uc:SaveIndicator runat="server" />
//
//	Modification History:
//	17Sep14 XN  95415 Created
//  17Nov14 XN  Added the Saved label 104369
//===========================================================================
using System;
using System.Web.UI;

public partial class application_pharmacysharedscripts_SaveIndicatorControl : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            // Embedded js did not work too well in the control HTML so added in on the server.
            string script = "var si_showSaved   = false;"                                           +
                            "var si_unsavedText = 'Unsaved';"                                       +
                            "var si_savedText   = 'Saved';"                                         +
                            ""                                                                      +
                            "setInterval(function () { si_Update(); }, 1500);"                      +
                            ""                                                                      +
                            "function si_Update()"                                                  +
                            "{"                                                                     +
                            "   var spanSaveIndicator = $('#" + this.UniqueID.ToString() + "');"    +
                            "   var isUnsavedVisible  = spanSaveIndicator.is('[visible]:contains(' + si_unsavedText + ')');"    +
                            "   var isSavedVisible    = spanSaveIndicator.is('[visible]:contains(' + si_savedText   + ')');"    +
                            "   if (isPageDirty)"                                                   +
                            "   {"                                                                  +
                            "       if (!isUnsavedVisible)"                                         +
                            "       {"                                                              +
                            "           spanSaveIndicator.css('background-color', '#FF0000');"      +
                            "           spanSaveIndicator.text(si_unsavedText);"                    +
                            "           spanSaveIndicator.attr('visible', 'visible');"              +
                            "       }"                                                              +
                            "   }"                                                                  +
                            "   else if (!isPageDirty)"                                             +
                            "   {"                                                                  +
                            "       if (si_showSaved && !isSavedVisible)"                           +
                            "       {"                                                              +
                            "           spanSaveIndicator.css('background-color', '#009900');"      +
                            "           spanSaveIndicator.text(si_savedText);"                      +
                            "           spanSaveIndicator.attr('visible', 'visible');"              +
                            "       }"                                                              +
                            "       else if (!si_showSaved && (isSavedVisible || isUnsavedVisible))"+
                            "       {"                                                              +
                            "           spanSaveIndicator.css('background-color', '');"             +
                            "           spanSaveIndicator.text('&nbsp;');"                          +
                            "           spanSaveIndicator.removeAttr('visible');"                   +
                            "       }"                                                              +
                            "   }"                                                                  +
                            "}"                                                                     +
                            ""                                                                      +
                            "function si_showSave(show)"                                            +
                            "{"                                                                     +
                            "   si_showSaved = show;"                                               +
                            "}";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "saveIndicator", script, true);
        }
    }

    /// <summary>If the form is not dirty if "Saved" text is displayed (otherwise shows nothing)</summary>
    public void ShowSavedText(bool showSaved)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "saveIndicatorShowSaved", string.Format("si_showSave({0});", showSaved.ToString().ToLower()), true);
    }

    /// <summary>Force control state to update ahead of timer update</summary>
    public void Update()
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "saveIndicatorUpdate", "si_Update();", true);
    }
}