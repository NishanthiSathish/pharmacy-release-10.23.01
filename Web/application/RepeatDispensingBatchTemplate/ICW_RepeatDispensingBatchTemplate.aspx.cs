//===========================================================================
//
//			ICW_RepeatDispensingBatchTemplate.aspx
//
//  Main desktop for the repeat disepnsing batch templates. 
//  Allows creating, updating, and deletion, of a repeat dispensing templates
//
//  Call the page with the follow parameters
//  SessionID  - ICW session ID
//  IsModal    - If pages is called from popup window  (optional default to no)           
//  
//  Usage:
//  ICW_RepeatDispensingBatchTemplate.aspxSessionID=123&IsModal=No
//
//	Modification History:
//	12May11 XN  Written
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Ascribe.Common;

public partial class application_RepeatDispensingBatchTemplate_ICW_RepeatDispensingBatchTemplate : System.Web.UI.Page
{
    protected int sessionID;
    protected bool isModal;
 
    protected void Page_Load(object sender, EventArgs e)
    {
        // Initialise the Session
        sessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // Get if modal page
        string isModalStr = Request.QueryString["IsModal"];
        if (!string.IsNullOrEmpty(isModalStr))
            isModal = BoolExtensions.PharmacyParse(isModalStr);

        if (!IsPostBack)
        {
            // Load templates (all templates that are not marked as deleted), and populate list
            RepeatDispensingBatchTemplate templates = new  RepeatDispensingBatchTemplate();
            templates.LoadAll();
            PopulateTemplateList(templates);
        }

        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        int templateID;    

        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (target)
        {
        case "upButtons" :
            // Update from buttons to delete template 
            // args are in form Delete|{template ID}|{Force}
            // Where Force forces deletion
            if ((argParams.Count() > 1) && (argParams[0] == "Delete") && int.TryParse(argParams[1], out templateID))
                DeleteTemplate(templateID, args.Contains("Force"));
            if ((argParams.Count() > 1) && (argParams[0] == "Refresh") && int.TryParse(argParams[1], out templateID))
                RefreshTemplate(templateID);
            break;
        }
    }

    /// <summary>Populates the grid with the templates</summary>
    /// <param name="templates">template to populate grid with</param>
    private void PopulateTemplateList(RepeatDispensingBatchTemplate templates)
    {
        // Setup grid
        RDispTemplatesGrid.SortableColumns           = true;
        RDispTemplatesGrid.EnableAlternateRowShading = true;

        RDispTemplatesGrid.AddColumn("Template name", 90, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Left,   true);
        RDispTemplatesGrid.ColumnAllowTextWrap(0, true);
        RDispTemplatesGrid.AddColumn("In Use",        10, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Center, true);           

        // Populate grid
        foreach (RepeatDispensingBatchTemplateRow template in templates.OrderBy(t => t.Description))
        {
            RDispTemplatesGrid.AddRow();

            RDispTemplatesGrid.AddRowAttribute ("RDispBatchTemplateID", template.RepeatDispensingBatchTemplateID.ToString());
            RDispTemplatesGrid.SetCell (0, template.Description);
            RDispTemplatesGrid.SetCell (1, template.InUse.ToYesNoString());
        }
    }

    /// <summary>
    /// Reloads the template, and sends the data to the client to update the list
    /// </summary>
    /// <param name="templateID">Repeat Dispensing Batch Template ID</param>
    private void RefreshTemplate(int templateID)
    {
        // Load template, and populate list
        RepeatDispensingBatchTemplate templates = new RepeatDispensingBatchTemplate();
        templates.LoadByRepeatDispensingBatchTemplateID(templateID);
        PopulateTemplateList(templates);

        // extract HTML row to refresh from grid
        string row = RDispTemplatesGrid.ExtractHTMLRows(0, 1)[0].Replace("\r\n", string.Empty);

        // Call client side UpdateGridRow to update grid with HTML row
        string script = string.Format("UpdateGridRow({0}, '{1}');", templateID, Generic.XMLEscape(row));
        ScriptManager.RegisterStartupScript(this, this.GetType(), "updategridrow", script, true);
    }

    /// <summary>
    /// Deletes template (marks template as deleted)
    /// Can only delete template if
    /// 1. Not part of active repeat dispensing batch
    /// 2. If template attached to patients then notify user and ask if they want to delete.
    /// 
    /// Normaly called first time with force to false, and if connected to patient will set javascript 
    /// to ask use if they really want to delete. If so called second time with force set to true.
    /// 
    /// Once deleted the method will call client side function RemoveGridRow to update the view
    /// </summary>
    /// <param name="templateID">Repeat Dispensing Batch Template ID</param>
    /// <param name="force">If to force deletion (don't ask user)</param>
    private void DeleteTemplate(int templateID, bool force)
    {
        // Check if template is part of repeat disensing batch
        if (RepeatDispensingBatch.CountByTemplateAndActive(templateID) > 0)
        {
            lbError.Text = "Contains active templates so can't delete.";
            return;
        }

        // check how many patients are connected to the template
        // If there are connected patients then ask user if they want to delete
        int numberOfLinkedPatients = RepeatDispensingPatient.CountByTemplate(templateID);
        if (!force && (numberOfLinkedPatients > 0))
        {
            string script = string.Format("if (ICWConfirm('The template is linked to {0} patients, are you sure you want to delete?','Yes,No','Delete','dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;') == 'Yes') {{ __doPostBack('{1}', 'Delete:{2}:Force'); }}", numberOfLinkedPatients, upButtons.ID, templateID);
            ScriptManager.RegisterStartupScript(this, GetType(), "shoulddelete", script, true); 
            return;
        }

        // And delete
        RepeatDispensingPatient.ClearRepeatDispensingBatchTemplateID(templateID);

        RepeatDispensingBatchTemplate templates = new RepeatDispensingBatchTemplate();
        templates.LoadByRepeatDispensingBatchTemplateID(templateID);
        if (templates.Any())
            templates.Remove(templates[0]);
        templates.Save();


        // Update the grid
        ScriptManager.RegisterStartupScript(this, GetType(), "removegridrow", "RemoveGridRow(" + templateID + ")", true);         
    }
}
