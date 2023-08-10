//===========================================================================
//
//					  	   ICW_PNViewAndAdjust.aspx.cs
//                              (aka The Griddy)
//
//  ICW desktop for the Parenteral Nutrition desktop. 
//  Allows viewing, editing, authorising, printing and issuing of the regimen.
//
//  Call the page with the follow parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Pharmacy site
//  RequestID               - PN Regimen RequestID
//  RequestID_Parent        - PN Prescription RequestID (only when creating new regimen)
// 
//  When this screen is first displayed to the user it will display the PN usage message (can trun this off via a setting)
//
//  ICW policies for desktop
//  ------------------------
//  Only users with ICW policies
//      'Parenteral Nutrition - Viewer'     - can only view and print regimen
//      'Parenteral Nutrition - Authoriser' - can only view (but not print) and authorise regimen
//      'Parenteral Nutrition - Editor'     - can view, and edit regimen, but not print or authorise 
//
//  Grid columns
//  ------------
//  All grid columns come from PNIngredient DB table (where ForViewAdjust is true). Includes volume column.
//  The table also defines order that the columns are displayed in.
//  This does not include ml/kg column that always appears as last in list.
//
//  Updates to grid
//  ---------------
//  Whenever data is added, or updated, in grid it is sent to client in JSON fromat as follows
//  {
//     "Remove":["INTI110"],
//     "Rows":["<tr PNCode=\\"VAMI090\\" SortIndex=\\"100\\" RowType=\\"product\\" VolumeInml=\\"23.4\\" Phosphate_mmol=\\"0.00\\" PhosphateInorganic_mmol=\\"0.00\\" PhosphateOrganic_mmol=\\"0.00\\" ><td><span id=\\"Edited\\">&#149;</span>Vamin 9</td><td><input type=\\"text\\" value=\\"23.4\\"  /></td>...<td><input type=\\"text\\" value=\\"0.42\\"  /></td></tr >",
//             "<tr PNCode=\\"TotalInml\\" SortIndex=\\"99999996\\" RowType=\\"total\\" VolumeInml=\\"23.4\\" Phosphate_mmol=\\"0.00\\" PhosphateInorganic_mmol=\\"0.00\\" PhosphateOrganic_mmol=\\"0.00\\" ><td style=\\"padding-left: 50px;\\">Total</td><td><input type=\\"text\\" value=\\"23.4\\"  /></td>...<td><input type=\\"text\\" value=\\"0.42\\"  /></td></tr >",
//             "<tr PNCode=\\"TotalInmlPerkg\\" SortIndex=\\"99999997\\" RowType=\\"total\\" VolumeInml=\\"23.4\\" Phosphate_mmol=\\"0.00\\" PhosphateInorganic_mmol=\\"0.00\\" PhosphateOrganic_mmol=\\"0.00\\" ><td style=\\"padding-left: 50px;\\">Total/kg</td><td><input type=\\"text\\" value=\\"0.42\\"  /></td>...<td><input type=\\"text\\" value=\\"0.42\\"  /></td></tr >"]
//  }
//  The remove list is of products to be removed from the regimen
//  Rows are view and adjust grid rows to be add or updated (the columns will match that in the view and adjust screen)
//
//  The list of rows also includes the total, and total per kg, pharmacy prescription, and prescriber prescription rows 
//  that are treated as products in json data with PNCodes 'TotalInml', 'TotalInmlPerkg', 'PharmacyPrescription', 'PrescriberPrescription' 
//  with sort indexes 99999996, 99999997, 99999998, 99999999 so they appear at end of list.
//
//  Each row has a RowType these are 'product', 'total', 'requirements', 'prescription'
//
//  Return regimen info from grid
//  -----------------------------
//  Whenever regimen info is returned from grid it is sent to client in JSON format as follows
//  [
//     ["VAMI091","18.0"],
//     ["WATI000","50.0"],
//     ["GLUI050","22.0"]
//  ]
//  For post backs the data is sent in hidden field hfRegimenData, 
//  for web methods the data is sent as part of the methods parameter.
//
//  Phosphate tooltip
//  -----------------
//  When user hold there mouse over item in Phosphate column a tooltip will be displayed, showing the phosphate content breakdown.
//  This is done using the jquery.tooltip.min.js to display the tooltip
//  Whem tooltip is displayed jquery plug-in calls javascript method getphosphateTooltip that subs the rows phosphate values into phosphateTooltip div for display as a tooltip.
//
//  Volume tooltop -
//  --------------
//  When user holds mouse over volume column tooltip is displayed showing volume, and overage, breakdown.
//      PNProcessor.ToJSONString - creates the overage data
//          UpdateGrid           - Javascript method stores overage data in javascript variable overagesAndVolumes
//              getVolumeTooltip - Javascript method extras data from overagesAndVolumes, and displays in tooltip using jquery.tooltip.min.js
//
//  Add Product Wizard
//  ------------------
//  The button IDs on the add product wizard are as follows
//  wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton
//  wizardAddProduct_StartNavigationTemplateContainerID_CancelButton
//  wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton
//  wizardAddProduct_FinishNavigationTemplateContainerID_CancelButton
//  wizardAddProduct_StepNavigationTemplateContainerID_StepPreviousButton
//  wizardAddProduct_StepNavigationTemplateContainerID_StepNextButton
//  wizardAddProduct_StepNavigationTemplateContainerID_CancelButton
//  
//  Multply By
//  ----------
//  When multiply by button is clicked
//  MultiplyBy_OnClick - server side function to initalise and display form
//  |
//  -> DisplayMultiplyByForm - client side method to display multiply form
//     |
//      -> btnMultiplyByFormOK_OnClick - server side function when user presses ok button on form
//         |                             Builds messsage informing user of scaling
//         -> askMultiplyByFactor - client side form displays message box 
//            |                     Does _dPostBack if user click okay
//            -> __doPostBack('upMultiplyByForm', 'Scale:' + scale) - Scales regimen                                                  
//  MultiplyBy_onkeydown client side form used to handle key presses on the form
//  tbMultiplyBy_keyup client side function when user enter value in multiply text area updates slider
//
//  Authorise\Save -
//  --------------
//  Both option perform a stability check on the regimen. 
//  Is user tries to authorise, and there are critical errors then they will only be able to save
//      Authorise_OnClick or Save_OnClick           - user click one of the buttons
//          LockRegimen                             - If authorising and regimen not lock then lock it
//          CheckRegimen                            - performs stability check on regimen, and builds up warning
//              PNProcessor.PerformStabilityCheck   - Populate blackboard
//                  pPNCheckRules                   - SP called to check stability of regimen
//              DisplayBrokenRules                  - Display any stability rules
//                  __doPostBack('upButtonsAndPatientDetails', Authorise or Save)  - performs desired operation
//
//  Usage:
//  ICW_PNViewAndAdjust.aspx?SessionID=123&AscribeSiteNumber=504&RequestID=54
//
//	Modification History:
//	15Nov11 XN  Written
//  25Mar12 XN  TFS29994 Added more advance regimen name generation, and 
//              modification number. So regimen name can fit on label
//  29Nov12 XN  31900 don't display mmol Entry type form in wizard if request 
//              comes from pressing enter in total or total/kg cells
//  19Feb13 XN  30734 So on save calls PNRegimenRow.UpdateTotalValues
//              so regimen totals go to reporting db.
//  21Mar13 XN  Added no glucose or water mix option to standard reg list (59607)
//  26Mar13 XN  Update to no glucose or water mix option to standard reg list (59607)
//  03Apr13 XN  Cached processor to web page as last resort.
//  24Apr13 XN  Prevent crash is user does not have permission (62389)
//  14May13 XN  get the IsCombined default PN settings the correct way around (63857)
//  16May13 XN  Can amend of if in view only mode (in certain situations) (64345)
//  05Jul13 XN  Moved location of GetCaseNumberDisplayName and GetNHSNumberDisplayName 
//              (method SetPatientDetails) 27252
//  10Sep14 XN  95272 If when standard regimen selected replace the regimen name with standard name
//  12Sep14 XN  95898 If double click on total cell will launch add ingredient wizard.
//  11Mar15 XN  113321 Warning dialog displayed from a timeout to fix very occasional issue displaying in ie8 
//  25Sep15 XN  77780 SetPatientDetails Hong Kong specific mode to display Chinese name 
//  18Nov15 XN  133905 Added mode ViewReadOnly
//  18Dec17 DR  Bug 200550 - Regimen status appears to change in VIEW only mode
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using _Shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using ascribe.pharmacy.icwdatalayer;
using System.Collections;
using System.Drawing;
using System.Web.UI.HtmlControls;
using ascribe.pharmacy.basedatalayer;
using System.Web;
using System.Data;
using System.Data.SqlClient;

public partial class application_PNViewAndAdjust_ICW_PNViewAndAdjust : System.Web.UI.Page
{
    #region Constants
    protected const int ColumnWidthIngredient = 42;     // if change this also need to chagne PN.css '#PNGrid tbody input width'
    protected const int ColumnWidthProductName= 200;
    #endregion

    #region Data Types
    /// <summary>Steps in PN add product wizard</summary>
    protected enum WizardStepType
    {
        wsAddMethod,
        wsSelectProduct,
        wsSelectIngredient,
        wsmmolEntry,
        wsEnterVolume,
        wsSelectIngredientWithQuatity,
        wsWizardMessage,
        wsSetMethod,
        wsEnterOverage,
        wsSelectGlucoseProduct,
        wsSelectAqueousOrLipid,
        wsSelectStandardRegimen,
    }
    #endregion

    #region Member variables
    /// <summary>Session ID</summary>
    protected int sessionID;

    /// <summary>Site number (from desktop settings)</summary>
    protected int siteNumber;

    /// <summary>Regimen ID (null if new regimen)</summary>
    protected int? requestID_Regimen = null;

    /// <summary>Prescription  ID (null if new regimen)</summary>
    protected int? requestID_Prescription = null;

    /// <summary>Get the regimen mode 12Nov15 XN 133905</summary>
    protected PNRegimenMode mode;

    /// <summary>Width of client application</summary>
    protected int clientWidth = 0;

    /// <summary>Need to call InitaliseRegimenProcessor before calling this method</summary>
    private PNProcessor regimenProcessor = null;

    private PNViewAndAdjustInfo viewAndAdjustInfo = new PNViewAndAdjustInfo();
    #endregion
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // Get URL parameters
        sessionID = int.Parse(Request["SessionID"]);
        siteNumber= int.Parse(Request["AscribeSiteNumber"]);

        // Get the RequestID (can't use request ID from query in-case we are doing a copy)
        if (!string.IsNullOrEmpty(hfRequestID.Value))
            requestID_Regimen = int.Parse(hfRequestID.Value);

        // Get the RequestID parent if present
        if (!string.IsNullOrEmpty(Request["RequestID_Parent"]))
            viewAndAdjustInfo.requestID_Prescription = int.Parse(Request["RequestID_Parent"]);

        // Get mode of page
        this.mode = PNRegimenMode.View;
        if (!string.IsNullOrEmpty(Request["mode"]))
            this.mode = (PNRegimenMode)Enum.Parse(typeof(PNRegimenMode), Request["mode"], true);

        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];

        // Initialise session
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        if (!this.IsPostBack)
        {
            try
            {
                // Reload cache data so always get the latest
                PNIngredient.GetInstance(true);
                PNProduct.GetInstance(true);

                // Load regimen
                PNRegimen regimen = new PNRegimen();
                IEnumerable<PNRegimenItem> regimenItems;
                if (!string.IsNullOrEmpty(Request["RequestID"]))
                {
                    regimen.LoadByRequestID(int.Parse(Request["RequestID"]));
                    if (!regimen.Any())
                        throw new ApplicationException(string.Format("Invalid regimen request ID {0}", Request["RequestID"]));

                    viewAndAdjustInfo.requestID_Prescription = regimen[0].RequestID_Parent;
                }

                // Get user policies for PN
                bool viewer = SessionInfo.HasAnyPolicies(PNUtils.Policy.Viewer);
                bool editor     = this.mode != PNRegimenMode.ViewReadOnly && SessionInfo.HasAnyPolicies(PNUtils.Policy.Editor);     // 12Nov15 XN 133905 add view read only check
                bool authoriser = this.mode != PNRegimenMode.ViewReadOnly && SessionInfo.HasAnyPolicies(PNUtils.Policy.Authoriser); // 12Nov15 XN 133905 add view read only check

                if (!viewer && !editor && !authoriser)
                {
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CanNotUse", "alert('You have insufficient privilege to use this.'); window.close();", true);
                    return;
                }

                // Calculate the width of the client
                clientWidth = ((PNIngredient.GetInstance().FindByForViewAdjust().Count() + 1) * (ColumnWidthIngredient + 4)) + (ColumnWidthProductName + 4) + 10;
                ToolBar.Style["width"] = clientWidth + "px";
                pnDetails.Width = System.Web.UI.WebControls.Unit.Pixel(clientWidth - 18);
                gridPanel.Width = System.Web.UI.WebControls.Unit.Pixel(clientWidth - 1);

                bool performAutoPopulate = false;

                // Load regimen details (use the query string requestID in-case we are doing a copy)
                if (regimen.Any())
                {
                    if (this.mode == PNRegimenMode.View || this.mode == PNRegimenMode.ViewReadOnly)
                    {
                        hfRequestID.Value = regimen[0].RequestID.ToString();    // Only set if not copying
                        requestID_Regimen = regimen[0].RequestID;
                        regimenItems = regimen[0].GetRegimenItems();

                        // Log event
                        PNLog.WriteToLog(null, regimen[0].EntityID, regimen[0].EpisodeID, null, null, regimen[0].RequestID, "User is viewing regimen '" + regimen[0].Description + "'", string.Empty);
                    }
                    else
                    {
                        // Copying so create copy
                        PNRegimen original = regimen;
                        regimen = new PNRegimen();
                        regimen.Add();
                        regimen[0].CopyFrom(original[0], true);

                        // Create name from original regimen
                        // TFS29994 25Mar12 XN  Added more advance regimen name generation, and modification number. So regimen name can fit on label
                        regimen[0].ModificationNumber   = PNRegimen.GetRegimenCount(regimen[0].RequestID_Parent);
                        regimen[0].RequestDate          = DateTime.Now;  // Ensure items are in correct order in list
                        regimenItems = original[0].GetRegimenItems().ToList();
                        regimen[0].CreateName(original[0].ExtractBaseName());

                        // Log event
                        PNLog.WriteToLog(null, regimen[0].EntityID, regimen[0].EpisodeID, null, null, null, "User is has started creating copy (not yet saved) of regimen '" + regimen[0].Description + "'", string.Empty);
                    }
                }
                else
                {
                    PNPrescrtiption prescription = new PNPrescrtiption();
                    prescription.LoadByRequestID(viewAndAdjustInfo.requestID_Prescription);
                    if (!prescription.Any())
                        throw new ApplicationException(string.Format("Invalid prescription request ID {0}", viewAndAdjustInfo.requestID_Prescription));

                    // Create regimen name from prescription
                    PNRegimenRow newRegimen = regimen.Add();
                    newRegimen.ModificationNumber             = PNRegimen.GetRegimenCount(prescription[0].RequestID);
                    newRegimen.RequestID_Parent               = viewAndAdjustInfo.requestID_Prescription;
                    newRegimen.LocationID_Site                = SessionInfo.SiteID;
                    newRegimen.IsCombined                     = prescription[0].IsCombined ?? !PNSettings.Defaults.GetSeparateAqueousAndLipidLabels(prescription[0].AgeRage);   // XN 14May13 63857 get the default PN settings the correct way around.
                    newRegimen.CentralLineOnly                = prescription[0].CentralLineRequired;
                    newRegimen.InfusionHoursAqueousOrCombined = PNSettings.Defaults.GetInfusionDurationInHours(prescription[0].AgeRage, PNProductType.Aqueous);
                    newRegimen.InfusionHoursLipid             = PNSettings.Defaults.GetInfusionDurationInHours(prescription[0].AgeRage, PNProductType.Lipid);
                    newRegimen.SupplyLipidSyringe             = false;
                    newRegimen.RequestDate                    = DateTime.Now;
                    newRegimen.EpisodeID                      = prescription[0].EpisodeID;
                    newRegimen.EntityID_Owner                 = SessionInfo.EntityID;
                    newRegimen.OverageAqueousOrCombined       = PNSettings.Defaults.GetOverageVolumeInml(prescription[0].AgeRage, newRegimen.IsCombined ? PNProductType.Combined : PNProductType.Aqueous);
                    newRegimen.OverageLipid                   = PNSettings.Defaults.GetOverageVolumeInml(prescription[0].AgeRage, PNProductType.Lipid);
                    newRegimen.Supply48Hours                  = prescription[0].Supply48Hours;
                    newRegimen.SessionLock                    = sessionID;
                    newRegimen.LastModifiedDate               = DateTime.Now;
                    newRegimen.LastModifiedEntityID_User      = SessionInfo.EntityID;
                    newRegimen.LastModifiedLocationID         = SessionInfo.LocationID;
                    newRegimen.CreateName(prescription[0]);  // TFS29994 25Mar12 XN  Added more advance regimen name generation, and modification number. So regimen name can fit on label

                    // Log event
                    PNLog.WriteToLog(null, regimen[0].EntityID, regimen[0].EpisodeID, null, null, null, "User is has started new regime (not yet saved) '" + regimen[0].Description + "'", string.Empty);

                    // Copy regimen items
                    foreach(PNIngredientRow ing in PNIngredient.GetInstance())
                    {
                        if (regimen.Table.Columns.Contains(ing.DBName) && prescription.Table.Columns.Contains(ing.DBName))
                            newRegimen.SetIngredient(ing.DBName, prescription[0].GetIngredient(ing.DBName));
                    }

                    // get standard regimen items
                    regimenItems = prescription[0].GetPrescriptionItems().ToList();

                    // If no regimen items the auto populate the regimen
                    performAutoPopulate = !regimenItems.Any();
                }

                // Create and cache processor
                regimenProcessor = new PNProcessor();
                regimenProcessor.Initalise(regimen, regimenItems);
                bool validRegimen = PerformStartupValidation();
                PNProcessor.SaveToCache(requestID_Regimen, regimenProcessor, false);

                // Auto populate regimen if needed (if new regiemn that does not contain products)
                if (performAutoPopulate && validRegimen && PNSettings.ViewAndAdjust.GetAutoPopulateNewRegimen(regimenProcessor.Prescription.AgeRage))
                    this.AutoPopulateRegimen(true);

                PNRegimenStatus status;
                if (requestID_Regimen.HasValue && regimen[0].Cancelled)
                    status = PNRegimenStatus.Cancelled;
                else if (!requestID_Regimen.HasValue)
                    status = PNRegimenStatus.Edited;
                else if (regimen[0].PNAuthorised)
                    status = PNRegimenStatus.Authorised;
                else
                    status = PNRegimenStatus.Saved;

                // Populate page
                SetViewAndAdjustInfo();
                SetButtons();
                SetPatientDetails();
                SetRegimeDetails(status);

                // Generates JSON data to initalise the two total rows in regimen grid.
                // Calls form_load first as script block is run before body events are called.
                bool readOnly = !editor || this.regimenProcessor.Regimen.Cancelled || !this.regimenProcessor.Regimen.IsLocked;
                if (validRegimen)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "AddTotals", "form_onload(" + clientWidth.ToString() + "); $(document).ready(function(){ UpdateGrid('" + regimenProcessor.ToJSONString(true, true, readOnly, true) + "'); });", true);    // 15Oct14 XN 64572 UpdateGrid modified document before load finish which error in i8 so need doc ready check
                    //ScriptManager.RegisterStartupScript(this, this.GetType(), "AddTotals", "form_onload(" + clientWidth.ToString() + "); UpdateGrid('" + regimenProcessor.ToJSONString(true, true, readOnly, true) + "');", true);

                // If request will click the btnEdit on open 19Nov15 XN 133905
                if (BoolExtensions.PharmacyParseOrNull(this.Request["EnableEdit"]) ?? false)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "EnableEdit", "$('#btnEdit').click();", true);
            }
            catch (ApplicationException ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Error", "alertEnh('" + ex.Message + "'); window.close();", true);
                return;
            }
        }
        else
        {
            viewAndAdjustInfo = JsonConvert.DeserializeObject<PNViewAndAdjustInfo>(hfViewAndAdjustInfo.Value);

            // Get regimen processor (if not cached anymore then get version cached on page 03Apr13 XN)
            regimenProcessor = PNProcessor.GetFromCache(this.requestID_Regimen, false);
            if (regimenProcessor == null)
            {
                // Read processor from page cache
                regimenProcessor = new PNProcessor();
                regimenProcessor.ReadXml(this.hfProcessor.Value);
                PNProcessor.SaveToCache(this.requestID_Regimen, regimenProcessor, false);

                // Read regimen processor copy from page cache
                if (!string.IsNullOrEmpty(this.hfProcessorCopy.Value))
                {
                    PNProcessor regimenProcessorCopy = new PNProcessor();
                    regimenProcessorCopy.ReadXml(hfProcessorCopy.Value);
                    PNProcessor.SaveToCache(this.requestID_Regimen, regimenProcessorCopy, true);
                }
            }

            // Some postback done require clearing of flags
            if (!args.ToLower().Contains("suppresscleareditflags"))
                regimenProcessor.ClearEditFlag();
        }


        // Deal with __postBack events
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (target)
        {
        case "upWizard" :
            // Do nothing if not in edit mode
            if (!regimenProcessor.Regimen.IsLocked)
                return;

            // Update from buttons 
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                // Fires when user click on product column header (starts add product wizard)
                case "AddByProduct":    
                    ProductColumnHeaderOnClick();
                    break;

                // Fires when user click on ingredient column header (starts add product wizard for ingredient)
                // Volume, and calories are handled differently from other ingredients
                case "AddByIngredient":
                    if (argParams.Count() > 1)
                    {
                        string                ingDBName         = argParams[1];
                        PNUtils.mmolEntryType mmolEntryType     = argParams[2].EqualsNoCaseTrimEnd("Total") ? PNUtils.mmolEntryType.Total : PNUtils.mmolEntryType.PerKg;    // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
                        bool                  askmmolEntryType  = BoolExtensions.PharmacyParse(argParams[3]);   // 31900 XN 29Nov12 don't display mmol Entry selection if request comes from total columns

                        if ((ingDBName == PNIngDBNames.Volume) || (ingDBName == PNIngDBNames.Calories))
                            SetColumnHeaderOnClick(ingDBName, mmolEntryType);
                        else
                            IngredientColumnHeaderOnClick(ingDBName, mmolEntryType, askmmolEntryType);
                    }
                    break;

                // Fires when user clicks ml/kg column
                case "AdjustVolume":
                    SetColumnHeaderOnClick(PNIngDBNames.Volume, PNUtils.mmolEntryType.PerKg);
                    break;
                }
            }
            break;

        case "upAskAdjustMsgBox":
            // Postback for upAskAdjustMsgBox
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                // Fires when user edits a value, and need to ask if to readjust 
                case "AskAdjust":
                    if (argParams.Count() == 2)
                    {
                        string PNCode = argParams[1];     // Product being updated

                        PNProcessor originalRegimen = PNProcessor.GetFromCache(this.requestID_Regimen, true);
                        PNProductRow product = PNProduct.GetInstance().FindByPNCode(PNCode);

                        // Display ask adjust message
                        if (msgBoxAskAdjustIng.AskAdjust(string.Empty, product, originalRegimen, regimenProcessor, viewAndAdjustInfo))
                            DisplayAdjustLevelMsgBox();
                    }
                    break;

                // Do the adjustment (and update grid)
                case "PerformAdjust":
                    {
                        PNProcessor originalRegimen = PNProcessor.GetFromCache(this.requestID_Regimen, true);
                        PNProcessor.RemoveFromCache(this.requestID_Regimen, true);
                        msgBoxAskAdjustIng.PerformAdjust(originalRegimen, regimenProcessor, viewAndAdjustInfo);
                        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "');", true);
                        SetRegimeDetails(PNRegimenStatus.Edited);
                    }
                    break;
                }
            }
            break;

        case "upMultiplyByForm":
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                // Fires when user scales the regimen
                case "Scale":
                    if (argParams.Count() == 2)
                    {
                        // Scale regimen
                        double scale = double.Parse(argParams[1]);  // TFS31013 2Apr12 XN Allow scaling by double value (rather than just integer)
                        regimenProcessor.ScaleBy(scale);

                        // Update the grid
                        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "');", true);
                        SetRegimeDetails(PNRegimenStatus.Edited);
                    }
                    break;
                }
            }
            break;

        case "upButtonsAndPatientDetails":
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {         
                case "Authorise":   // Authorise
                    this.regimenProcessor.Regimen.SessionLock = 0;

                    SetRegimeDetails(PNRegimenStatus.Authorised);   // Set state to authoriesed early else will be overridden by save

                    Save();
                    this.regimenProcessor.Regimen.Authorise();

                    PNRegimenRow regimen = this.regimenProcessor.Regimen;
                    IEnumerable<PNBrokenRule> brokenRules = this.regimenProcessor.PerformStabilityCheck();
                    string message = "Authorised";
                    if (brokenRules.Any())
                        message += "\nFollowing rules fired\n" + this.regimenProcessor.PerformStabilityCheck().Select(i => i.RuleNumber.ToString() + " - " + i.Description).ToCSVString("\n");
                    PNLog.WriteToLog(SessionInfo.SiteID, regimen.EntityID, regimen.EpisodeID, null, null, regimen.RequestID, message, string.Empty);

                    SetButtons();
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, true, false) + "');", true);
                    upButtonsAndPatientDetails.Update();
                    break;

                case "Save":        // Save
                    Save();
                    upButtonsAndPatientDetails.Update();
                    break;
                
                case "EditWhenAuthorised":
                    Edit(true);
                    upButtonsAndPatientDetails.Update();
                    break;

                case "RefreshPatientDetails":
                    bool readOnly = this.regimenProcessor.Regimen.Cancelled || !this.regimenProcessor.Regimen.IsLocked; // 16May13 XN 64345 if form is read-only then redraw in readonly mode
                    bool authorised = this.regimenProcessor.Regimen.PNAuthorised;
                    SetViewAndAdjustInfo();
                    SetRegimeDetails(readOnly ? (authorised ? PNRegimenStatus.Authorised : PNRegimenStatus.Saved ) : PNRegimenStatus.Edited);    // 16May13 XN 64345 If readonly then can't be in save mode  SetRegimeDetails(PNRegimenStatus.Edited);
                    // Only need to update regimen row must have to do whole thing
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "updateRegimen", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, readOnly, true) + "');", true);   // 16May13 XN 64345 if form is read-only then redraw in readonly mode     ScriptManager.RegisterStartupScript(this, this.GetType(), "updateRegimen", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, false, true) + "');", true);
                    upButtonsAndPatientDetails.Update();
                    break;

                case "RefreshRegimenDetails":   // TFS31076 11Apr12 XN added for refreshing after save/authorise (if user cancels) as lipid syring calc may of updated overage
                    SetRegimeDetails(null);
                    upButtonsAndPatientDetails.Update();
                    break;

                case "AutoPopulate":
                    Dictionary<PNProductRow,double> doseReducedForMax, doseReducedForMaxPerKg;
                    bool removeNegative = (argParams.Count() == 2) && argParams[1].EqualsNoCaseTrimEnd("RemoveNegative");
                    this.regimenProcessor.AutoPopulateRegimen(out doseReducedForMax, out doseReducedForMaxPerKg, removeNegative);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "updateRegimen", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, false, false) + "');", true);
                    SetRegimeDetails(PNRegimenStatus.Edited);
                    break;
                }
            }
            break;

        case "upRegimenItems":
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                // Do the delete after message is displayed, and if needed display the ask adjustment message.
                case "Delete":
                    {
                        string PNCodeToDelete        = argParams[1];
                        PNProductRow productToDelete = PNProduct.GetInstance().FindByPNCode(PNCodeToDelete);

                        // Create copy or processor beofre change (for the ask adjust)
                        PNProcessor originalProcessor = (PNProcessor)regimenProcessor.Clone();

                        // Remove regimen item
                        regimenProcessor.RemoveItem(PNCodeToDelete);

                        // Determin if showing ask adjust message
                        string msg = "Removed " + productToDelete.Description;
                        if (msgBoxAskAdjustIng.AskAdjust(msg, productToDelete, originalProcessor, regimenProcessor, viewAndAdjustInfo))
                        {
                            PNProcessor.SaveToCache(this.requestID_Regimen, originalProcessor, true);
                            DisplayAdjustLevelMsgBox();
                        }

                        // And update
                        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "');", true);
                        SetRegimeDetails(PNRegimenStatus.Edited);
                    }
                    break;
                }
            }
            break;
        }
    }

    /// <summary>Overridden so can write regimen processor to page 03Apr13 XN</summary>
    protected override void OnPreRender(EventArgs e)
    {
        bool updating = false;
        string temp;

        // Write regimen processor to web page (extra caching incase web cache fails)
        if (this.regimenProcessor != null)  // 62389 24Apr13 XN Prevent crash is user does not have permission
        {
            temp = this.regimenProcessor.WriteXml();
            if (temp != hfProcessor.Value)
            {
                hfProcessor.Value = temp;
                updating = true;
            }
        }

        // Write copy of regimen processor to web page (extra caching incase web cache fails)
        PNProcessor regimenTemp = PNProcessor.GetFromCache(this.requestID_Regimen, true);
        temp = regimenTemp == null ? string.Empty : regimenTemp.WriteXml();
        if (temp != hfProcessorCopy.Value)
        {
            hfProcessorCopy.Value = temp;
            updating = true;
        }

        // If any changes the update
        if (updating)
            upRegimenItems.Update();

        base.OnPreRender(e);
    }

    #region Event Handlers    
    /// <summary>Called when prescription button is clicked initalise displays the prescription</summary>
    protected void Prescription_OnClick(object sender, EventArgs e)
    {
        // Save OrdersXML to the session table
        ICWTypeData typeData = ICWTypes.GetTypeByDescription(ICWType.Request, "PN Prescription").Value;
        string ordersXML = string.Format("<display><item class=\"request\" id=\"{0}\" description=\"\" detail=\"\" tableid=\"{1}\" productid=\"0\" ocstype=\"request\" ocstypeid=\"{2}\" autocommit=\"1\"  ></item></display>", this.regimenProcessor.Prescription.RequestID, typeData.TableID, typeData.ID);
        PharmacyDataCache.SaveToDBSession("OrderEntry/OrdersXML", ordersXML);

        // Display the prescription
        string script = string.Format("var ret = window.showModalDialog('../OrderEntry/OrderEntryModal.aspx?SessionID={0}&Action=load&DispensaryMode=0&DefaultCreationType=undefined', null, OrderEntryFeaturesV11()); HandleResultForTimeout(ret);delayedPNGridFocus();", SessionInfo.SessionID);
        
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Prescription", script, true);
    }

    /// <summary>Called when regimen button is clicked shows the regimen dialog (with regimen tab selected)</summary>
    protected void Regimen_OnClick(object sender, EventArgs e)
    {
        //string script = string.Format("if (window.showModalDialog('PNRegimenDetails.aspx?SessionID={0}&SiteID={1}&RequestID={2}&Tab=Info', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;') == true) {{ __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails'); }}", SessionInfo.SessionID, SessionInfo.SiteID, requestID_Regimen);   TFS31032 2Apr12 XN Return focus to grid after form closes
        //string script = string.Format("if (window.showModalDialog('PNRegimenDetails.aspx?SessionID={0}&SiteID={1}&RequestID={2}&Tab=Info', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;') == true) {{ __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails'); }}", SessionInfo.SessionID, SessionInfo.SiteID, requestID_Regimen);   TFS31032 2Apr12 XN Return focus to grid after form closes
        string script = string.Format("var ret=window.showModalDialog('PNRegimenDetails.aspx?SessionID={0}&SiteID={1}&RequestID={2}&Tab=Info', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;'); HandleResultForTimeout(ret); if (ret == true) {{ __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails');}}; $('#PNGrid').focus();", SessionInfo.SessionID, SessionInfo.SiteID, requestID_Regimen);

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Regimen", script, true);
    }

    /// <summary>Called when requirements button is clicked shows the requirement dialog (with requirments tab selected)</summary>
    protected void Requirements_OnClick(object sender, EventArgs e)
    {
        //string script = string.Format("if (window.showModalDialog('PNRegimenDetails.aspx?SessionID={0}&SiteID={1}&RequestID={2}&Tab=Requirements', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;') == true) {{ __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails'); }}", SessionInfo.SessionID, SessionInfo.SiteID, requestID_Regimen);   TFS31032 2Apr12 XN Return focus to grid after form closes
        string script = string.Format("var ret=window.showModalDialog('PNRegimenDetails.aspx?SessionID={0}&SiteID={1}&RequestID={2}&Tab=Requirements', null, 'status:no;dialogHeight:575px;dialogWidth:600px;center:yes;'); HandleResultForTimeout(ret); if (ret == true) {{ __doPostBack('upButtonsAndPatientDetails', 'RefreshPatientDetails');}}; $('#PNGrid').focus();", SessionInfo.SessionID, SessionInfo.SiteID, requestID_Regimen);

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Requirements", script, true);
    }

    /// <summary>Called when populate button is clicked shows the populate form</summary>
    protected void Populate_OnClick(object sender, EventArgs e)
    {
        this.selectStandardRegimenCtrl.Initalise(this.regimenProcessor);
        InitaliseWizard(PNUtils.PNWizardType.standardRegimen, WizardStepType.wsSelectStandardRegimen);
        if (regimenProcessor.Prescription.AgeRage == AgeRangeType.Adult)
            wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;
    }

    /// <summary>Called when add product button is clicked initalise the add product wizard</summary>
    protected void AddProduct_OnClick(object send, EventArgs e)
    {
        // Check have not reached max number of products
        if (this.regimenProcessor.RegimenItems.Count() >= PNSettings.MaxNumberOfProductsInRegimen)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "MaxNumOfProducts", "alert('No more room available in table.');", true);
            return;
        }

        InitaliseWizard(null, WizardStepType.wsAddMethod);
    }

    /// <summary>Called when replace product button is clicked initalise the wizard for replace wizard</summary>
    protected void ReplaceProduct_OnClick(object send, EventArgs e)
    {
        PNProductRow  product   = PNProduct.GetInstance().FindByPNCode(hfCurrentRowPNCode.Value);
        PNRegimenItem item      = regimenProcessor.RegimenItems.FindByPNCode(hfCurrentRowPNCode.Value);
        string currentColDBName = hfCurrentColDBName.Value;

        // Ensure a product row is selected
        if ((product == null) || (item == null))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SelectProduct", "alert('Place cursor on line to be replaced and on column of ingredient to be preserved.');", true);
            return;
        }

        // Calls IPNWizardCtrl.Initalise on each control in wizard
        InitaliseWizard(PNUtils.PNWizardType.replace, WizardStepType.wsSelectIngredientWithQuatity);
        wizardAddProduct.WizardSteps[(int)WizardStepType.wsSelectProduct].AllowReturn = true;

        // Initalise the wizard (to the ingredient selection screen
        IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForViewAdjust().FindByForPNProduct(product, true);
        selectIngredientWithQuantityCtrl.Initalise(ingredients, product, currentColDBName, item.VolumneInml);
    }

    /// <summary>
    /// Called when the delete button is clicked
    /// Displays the AskAdjust message box, but also uses it to ask user if they want to delete
    /// </summary>
    protected void DeleteProduct_OnClick(object send, EventArgs e)
    {
        PNProductRow  product   = PNProduct.GetInstance().FindByPNCode(hfCurrentRowPNCode.Value);
        PNRegimenItem item      = regimenProcessor.RegimenItems.FindByPNCode(hfCurrentRowPNCode.Value);

        // Ensure a row is selected
        if ((product == null) || (item == null))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SelectProduct", "alert('Highlight the line required before deleting a product.');", true);
            return;
        }

        // Set jquery buttons
        string buttons = "[{ text: 'Yes', click: function() { $(this).dialog('close'); __doPostBack('upRegimenItems', 'Delete:" + item.PNCode + "');       } }," +
                          "{ text: 'No',  click: function() { $(this).dialog('close'); } }]";   

        // Ask user if they want to delete
        string msg = "<div><br />OK to remove " + product.Description + " from regimen<br /></div>";
        DisplayMsgBox("Delete item", msg, buttons, 1, 500);
    }

    /// <summary>
    /// Called when set button is clicked.
    /// Starts the set calories or volume wizard
    /// </summary>
    protected void Set_OnClick(object send, EventArgs e)
    {
        // Check if there any glucose only products or a universal diluent in the regimen else can't continue
        if (!regimenProcessor.RegimenItems.FindByOnlyContainGlucose().Any())
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CannotSet", "alert('No glucose only product or diluent present in the regimen, so cannot set volume or calorie content.');", true);
            return;
        }

        InitaliseWizard(PNUtils.PNWizardType.setCaloriesOrVolume, WizardStepType.wsSetMethod);
    }

    /// <summary>
    /// Called when overage button is clicked.
    /// Starts the overage wizard
    /// </summary>
    protected void Overage_OnClick(object send, EventArgs e)
    {
        bool anyAqueous = regimenProcessor.RegimenItems.FindByAqueousOrLipid(PNProductType.Aqueous).Any();
        bool anyLipid   = regimenProcessor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid  ).Any();

        if (!anyAqueous && !anyLipid)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CannotOverage", "alert('Cannot adjust overage until regimen defined.');", true);
            return;
        }

        InitaliseWizard(PNUtils.PNWizardType.overage, WizardStepType.wsSelectAqueousOrLipid);

        // If combined then jump past selection of aqueous and lipid to next stage
        // else set up first page of wizard to allow user to select.
        if (this.regimenProcessor.Regimen.IsCombined)
        {
            selectAqueousOrLipidCtrl.SetSelection(PNProductType.Combined);
            WizardOverage(WizardStepType.wsSelectAqueousOrLipid);
            InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
        }
        else
            selectAqueousOrLipidCtrl.Initalise(regimenProcessor, viewAndAdjustInfo);
    }

    /// <summary>
    /// Called when product weights button is clicked.
    /// Displays the product weights form
    /// </summary>
    protected void ProductWeight_OnClick(object send, EventArgs e)
    {
        weightsAndVolumeCtrl.Update(regimenProcessor, false);
        lbSupplyPeriod.Text = regimenProcessor.Regimen.Supply48Hours ? "For 48Hr Supply" : "For 24Hr Supply";
        btnWeightFullWeight.Text = "Show Full Volume";
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "ProductWeight", "popup('weightAndVolumes', 'blanket'); $('#weightAndVolumes').focus()", true);
    }

    protected void WeightFullWeight_OnClick(object send, EventArgs e)
    {
        bool showFullWeight = btnWeightFullWeight.Text.StartsWith("Show");
        btnWeightFullWeight.Text = showFullWeight ? "Hide Full Volume" : "Show Full Volume";
        weightsAndVolumeCtrl.Update(regimenProcessor, showFullWeight);
    }

    /// <summary>
    /// Called when product weights button is clicked.
    /// Displays the product weights form
    /// </summary>
    protected void Summary_OnClick(object send, EventArgs e)
    {
        summaryViewCtrl.Initalise(requestID_Regimen);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SummaryView", "popup('summaryView', 'blanket');", true);
    }

    /// <summary>
    /// Called when the save button is clicked
    /// Saves regimen to database
    /// </summary>
    protected void Save_OnClick(object send, EventArgs e)
    {
        if (this.regimenProcessor.Regimen.IsLocked)
            CheckRegimen(false);
    }

    private void Save()
    {
        PNRegimen regimenOringal = new PNRegimen();
        DateTime now = DateTime.Now;

        if (this.requestID_Regimen.HasValue)
            regimenOringal.CopyFrom(regimenProcessor.Regimens);

        // Update the regimen total values (for reporting) 30734                        
        this.regimenProcessor.Regimen.UpdateTotalValues(regimenProcessor.RegimenItems, regimenProcessor.Prescription.DosingWeightInkg);

        // Update regimen details
        regimenProcessor.Regimen.LastModifiedDate          = now;
        regimenProcessor.Regimen.LastModifiedEntityID_User = SessionInfo.EntityID;
        regimenProcessor.Regimen.LastModifiedLocationID    = SessionInfo.LocationID;

        // Write to log
        StringBuilder log = new StringBuilder();
        if (regimenOringal.Any())
        {
            log.AppendLine("Updating regimen '" + regimenProcessor.Regimen.Description + "'");
            PNLog.CompareDataRow(log, regimenOringal[0].RawRow, regimenProcessor.Regimen.RawRow);
        }
        else
            PNLog.AddDataRow(log, "Created new regimen '" + regimenProcessor.Regimen.Description + "'", regimenProcessor.Regimen.RawRow);

        // And save
        using (ICWTransaction transaction = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        {
            regimenProcessor.Regimens.Save();
            PNLog.WriteToLog(SessionInfo.SiteID, regimenProcessor.Regimen.EntityID_Owner, regimenProcessor.Regimen.EpisodeID, null, null, regimenProcessor.Regimen.RequestID, log.ToString(), string.Empty);

            // Determine the total aqueous or lipid amount
            bool isCombined    = this.regimenProcessor.Regimen.IsCombined;
            double supplyMulti = this.regimenProcessor.Regimen.SupplyMultiplier;
            double totalAqueosOrCombined = this.regimenProcessor.RegimenItems.FindByAqueousOrLipid(isCombined ? PNProductType.Combined : PNProductType.Aqueous).CalculateTotal(PNIngDBNames.Volume) * supplyMulti;
            double totalLipid            = this.regimenProcessor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid                                        ).CalculateTotal(PNIngDBNames.Volume) * supplyMulti;

            // Calculate product overage
            List<double> overage = new List<double>();
            foreach (PNRegimenItem item in this.regimenProcessor.RegimenItems)
            {
               bool aqueousOrCombined = isCombined || (item.GetProduct().AqueousOrLipid == PNProductType.Aqueous);
               overage.Add((item.VolumneInml * supplyMulti) + this.regimenProcessor.CalculateProductOverage(item.PNCode, aqueousOrCombined ? totalAqueosOrCombined : totalLipid));
            }
            regimenProcessor.Regimen.SaveRegimenItems(this.regimenProcessor.RegimenItems, overage);

            transaction.Commit();
        }

        // Remove original cached data, and resave new value (under new RequestID)
        PNProcessor.RemoveFromCache(requestID_Regimen, false);
        PNProcessor.SaveToCache(regimenProcessor.Regimen.RequestID, regimenProcessor, false);

        hfRequestID.Value = regimenProcessor.Regimen.RequestID.ToString();
        SetRegimeDetails(PNRegimenStatus.Saved);            
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "hasSaved = true;", true);   // TFS30354  Due to problems with authorisation state on worklist not updating this line is not really needed and could be removed
    }

    protected void Edit_OnClick(object send, EventArgs e)
    {
        Edit(false);
    }

    private void Edit(bool force)
    {
        if (this.regimenProcessor.Regimen.HasSupplyRequest())
        {
            // Can't edit has regimen has supply request       
            DisplayMsgBox("Edit", "<div>Can&#39;t edit regimen, as supplier request has been created.</div>", "[ { text: 'OK',  click: function() { $(this).dialog('close'); } } ]", 0, 450);
            return;
        }
        if (this.regimenProcessor.Regimen.PNAuthorised && !force)
        {
            // Regimen has been authorised so check with user
            string buttons = "[{ text: 'Yes', click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'EditWhenAuthorised'); } }, " +
                             " { text: 'No',  click: function() { $(this).dialog('close'); } } ]";
            DisplayMsgBox("Edit", "<div>Regimen has been authorised<br /><br />Are you sure you want to edit it?</div>", buttons, 1, 300);
            return;
        }

        // Cancel the original request
        int discontinuationReasonID = Database.ExecuteSQLScalar<int?>("SELECT TOP 1 DiscontinuationReasonID FROM DiscontinuationReason WHERE [Code] Like 'pnedit'") ?? 0;
        this.regimenProcessor.Regimen.Cancel(discontinuationReasonID, "Requested to edit", true);

        // Create copy
        PNRegimen regimens = new PNRegimen();
        PNRegimenRow regimen = regimens.Add();
        regimen.CopyFrom(regimenProcessor.Regimen, true);
        
        // Update modification number and name
        // TFS29994 25Mar12 XN  Added more advance regimen name generation, and modification number. So regimen name can fit on label
        regimen.ModificationNumber = PNRegimen.GetRegimenCount(regimen.RequestID_Parent);
        regimen.CreateName(regimenProcessor.Regimen.ExtractBaseName());

        this.regimenProcessor.Initalise(regimens, regimenProcessor.Regimen.GetRegimenItems());
        Save();

        // Lock and reload row (if needed)
        if (!this.regimenProcessor.Regimen.IsLocked && LockRegimen())
        {
            regimens.LoadByRequestID(this.requestID_Regimen.Value);
            regimenProcessor.Initalise(regimens, regimens[0].GetRegimenItems());
        }

        // Update screen
        if (this.regimenProcessor.Regimen.IsLocked)
        {
            PNLog.WriteToLog(null, regimen.EntityID, regimen.EpisodeID, null, null, regimen.RequestID, "User is has started editing regimen '" + regimen.Description + "'", string.Empty);

            SetButtons();
            SetPatientDetails();
            SetViewAndAdjustInfo();
            SetRegimeDetails(PNRegimenStatus.Saved);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AddTotals", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, this.regimenProcessor.Regimen.Cancelled, false) + "');", true);
        }
    }

    private bool LockRegimen()
    {
        try
        {
            LockResults lockResults = new LockResults("PNRegimen", "RequestID");
            lockResults.LockRows(regimenProcessor.Regimens.Table);
            return true;
        }
        catch (LockException ex)
        {
            string username = ex.GetLockerUsername();
            if (string.IsNullOrEmpty(username))
                username = "another user";
            username = username.Replace("\'", "\\\'");

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "lockFailed", "alertEnh('Regimen is being edited by " + username + "')", true);
            return false;
        }
    }

    protected void Authorise_OnClick(object send, EventArgs e)
    {
        if (!regimenProcessor.Regimen.IsLocked)
        {
            if (LockRegimen())
            {
                // And refresh
                PNRegimen regimens = new PNRegimen();
                regimens.LoadByRequestID(this.requestID_Regimen.Value);
                regimenProcessor.Initalise(regimens, regimens[0].GetRegimenItems());

                // Update views
                SetButtons();
                SetPatientDetails();
                SetRegimeDetails(null);

                ScriptManager.RegisterStartupScript(this, this.GetType(), "AddTotals", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, regimens[0].Cancelled, false) + "');", true);
            }
        }

        CheckRegimen(true);
    }

    /// <summary>
    /// Perform stability check on the regimen, and displays the results
    /// Used when both authorising, and saving the regimen.
    /// If the user tries to authorise the regimen, and their are critical errors, they will only be allowed to save. 
    /// The actual authorise\save operation is performed by postback on upButtonsAndPatientDetails
    /// </summary>
    /// <param name="authorise">If authorising (or saving)</param>
    private void CheckRegimen(bool authorise)
    {
        IEnumerable<PNBrokenRule> brokenRules = regimenProcessor.PerformStabilityCheck();
        bool ciricalErrors = brokenRules.Any(r => r.Type == PNBrokenRuleType.Critical);

        // Determine operation to be performed, (if critical error then can't authorise)
        string caption, buttons;
        if (!authorise || ciricalErrors)
        {
            caption   = "OK to save this regimen?";
            buttons   = "[{ text: 'Yes', click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'Save'); } }, " +
                        " { text: 'No',  click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'RefreshRegimenDetails'); } }]";   // TFS31076 11Apr12 XN still refresh regimen details as Lipid syringe calculation may of updated overage
        }
        else
        {
            caption   = "OK to authorise this regimen?";
            buttons   = "[{ text: 'Yes', click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'Authorise'); } }, " +
                        " { text: 'No',  click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'RefreshRegimenDetails'); } }]";   // TFS31076 11Apr12 XN still refresh regimen details as Lipid syringe calculation may of updated overage
        }

        if (ciricalErrors && authorise)
            caption += "<span class='ErrorMessage' style='padding-left:30px;'>You are not able to authorise this regimen.</span>";

        DisplayBrokenRules(authorise ? "Authorise" : "Save", brokenRules, caption, buttons, 0, string.Empty);
    }

    private bool PerformStartupValidation()
    {
        IEnumerable<PNBrokenRule> brokenRules = regimenProcessor.Validate();
        bool criticalErrors = brokenRules.Any(r => r.Type == PNBrokenRuleType.Critical);

        if (brokenRules.Any())
        {
            string caption, buttons, closeEvent;
            if (criticalErrors)
            {
                caption = string.Empty;
                buttons = "[ { text: 'Close', click: function() { $(this).dialog('close'); window.close(); } } ] ";
                //closeEvent = "function(event, ui) { window.close(); }";       TFS31032 2Apr12 XN Return focus to grid after form closes
                closeEvent = "function(event, ui) { window.close(); window.event.cancelBubble = true; window.event.returnValue = false; }"; 
            }
            else
            {
                caption = "OK to continue?";
                buttons = "[{ text: 'Yes', click: function() { $(this).dialog('close');                    } }, " +
                           "{ text: 'No',  click: function() { $(this).dialog('close'); window.close();    } } ]";
                closeEvent = string.Empty;
            }

            DisplayBrokenRules("Validation report", brokenRules, caption, buttons, 0, closeEvent);
        }

        return !criticalErrors;
    }

    /// <summary>
    /// Called when Muliply by button is clicked
    /// Displays multiply by form
    /// </summary>
    protected void MultiplyBy_OnClick(object send, EventArgs e)
    {
        const int MultiplyByMin     = 1;
        const int MultiplyByMax     = 200;
        const int MultiplyByDefault = 100;

        // If no regimen then error
        if (!regimenProcessor.RegimenItems.Any())
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CannotMultiply", "alert('No items in regimen.');", true);
            return;
        }

        // Reset form 
        lbMultiplyByValueError.Text = "&nbsp;";
        tbMultiplyBy.Text           = MultiplyByDefault.ToString();
        tbMultiplyBy.Focus();

        // Display form
        // Set the slider to default value
        // As the slide works from 200 (at top to 1 at bottom) need to reverse the value 
        string script = string.Format("DisplayMultiplyByForm(); $('#multiplyBySlider').slider('value', {0});", MultiplyByMax - MultiplyByDefault + MultiplyByMin);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CannotOverage", script, true);        
    }

    /// <summary>
    /// Called when multiply by form OK button is clicked
    /// Validates form value
    /// Displays message box show scaling to be performed, 
    /// and any products that will be deleted (as sacling will cause volue to zero)
    /// </summary>
    protected void btnMultiplyByFormOK_OnClick(object sender, EventArgs e)
    {
        // Validate multiply range
        string error;
        //if (!Validation.ValidateText(tbMultiplyBy, "multiply by", typeof(int), true, 1, 1000, out error)) TFS31013 2Apr12 XN allow entry of doubles in multiply by
        if (!Validation.ValidateText(tbMultiplyBy, "multiply by", typeof(double), true, 1, 1000, out error))
        {
            // After postback form seems to hide again, to prevent this need to re-display
            lbMultiplyByValueError.Text = error;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DisplayMultiplyByForm", "DisplayMultiplyByForm();", true);
            return;
        }

        //int    mutlplyByPercentage  = int.Parse(tbMultiplyBy.Text);   TFS31013 2Apr12 XN allow entry of doubles in multiply by
        double mutlplyByPercentage  = double.Parse(tbMultiplyBy.Text);
        double mutlplyByScaling     = (mutlplyByPercentage / 100.0).To3SigFigish();

        // Determine the items that will be removed by the multiply
        PNProcessor orginalRegimen = (PNProcessor)regimenProcessor.Clone();
        orginalRegimen.ScaleBy(mutlplyByPercentage);
        IEnumerable<PNRegimenItem> itemsThatWillBeRemoved = orginalRegimen.RegimenItems.Where(i => !regimenProcessor.RegimenItems.Any(o => o.PNCode==i.PNCode));
        PNProduct product = PNProduct.GetInstance();

        // Build up message
        StringBuilder message = new StringBuilder();
        message.AppendFormat("Yes to multiply all ingredients by {0} ?<br />({1}% of current regimen)", mutlplyByScaling, mutlplyByPercentage);
        if (itemsThatWillBeRemoved.Any())
        {
            message.Append("<br /><br />");
            message.Append("Following items will be removed from regimen, as volume will be below 0.01ml.");
            message.Append("<br />");
            foreach (PNRegimenItem item in itemsThatWillBeRemoved)
                message.AppendFormat("&nbsp;&nbsp;&nbsp;{0}<br />", product.FindByPNCode(item.PNCode));
        }

        // Hide multply by form, and display message
        string script = string.Format("hidePopup('multiplyByForm', 'blanket'); askMultiplyByFactor('{0}', {1});", message.ToString(), mutlplyByPercentage);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "DisplayMultiplyByAsk", script, true);
    }

    /// <summary>
    /// Called via post back when product column header is clicked.
    /// Starts add product wizard using AddMethod.byProduct
    /// </summary>
    protected void ProductColumnHeaderOnClick()
    {
        // Check have not reached max number of products
        if (this.regimenProcessor.RegimenItems.Count() >= PNSettings.MaxNumberOfProductsInRegimen)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "MaxNumOfProducts", "alert('No more room available in table.');", true);
            return;
        }

        // Initalise wizard and move to next step
        InitaliseWizard(PNUtils.PNWizardType.byProduct, WizardStepType.wsAddMethod);
        WizardAddByProduct(WizardStepType.wsAddMethod);
        InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
    }

    /// <summary>
    /// Called via post back when ingredient column header is clicked.
    /// Starts add product wizard using AddMethod.byIngredient, having ingredient automatically selected
    /// </summary>
    /// <param name="ingDBName">Ingredient DB Name</param>
    /// <param name="mmolEntryType">Default entry type to use</param>
    protected void IngredientColumnHeaderOnClick(string ingDBName, PNUtils.mmolEntryType mmolEntryType, bool askmmolEntryType)
    {
        // Check have not reached max number of products
        if (this.regimenProcessor.RegimenItems.Count() >= PNSettings.MaxNumberOfProductsInRegimen)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "MaxNumOfProducts", "alert('No more room available in table.');", true);
            return;
        }

        // Setup wizard to add by ingredient
        InitaliseWizard(PNUtils.PNWizardType.byIngredient, WizardStepType.wsAddMethod);
        hfDefaultmmlEntryType.Value = mmolEntryType.ToString();     // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
        hfAskmmolEntryType.Value    = askmmolEntryType.ToString();  // 31900 XN 29Nov12 don't display mmol Entry selection if request comes from total columns

        // Set up the select ingredient page in the wizard (to selected ingredient)
        wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectIngredient;
        IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForViewAdjust().OrderBySortIndex();
        selectIngredientCtrl.Initalise(ingredients, string.Empty, true);
        selectIngredientCtrl.SetIngredient(ingDBName);

        // Move to next step
        WizardAddByIngredient(WizardStepType.wsSelectIngredient);
        InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
    }

    /// <summary>
    /// Called via post back when volume or calories column header is clicked.
    /// Starts set wizard, having ingredient automatically selected
    /// </summary>
    /// <param name="ingDBName">Ingredient DB Name</param>
    /// <param name="mmolEntryType">Entry type to use (null to allow user select)</param>
    protected void SetColumnHeaderOnClick(string ingDBName, PNUtils.mmolEntryType? mmolEntryType)
    {
        // Check if there any glucose only products or a universal diluent in the regimen else can't continue
        if (!regimenProcessor.RegimenItems.FindByOnlyContainGlucose().Any())
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CannotSet", "alert('No glucose only product or diluent present in the regimen, so cannot set volume or calorie content.');", true);
            return;
        }

        // Setup wizard to add by ingredient
        InitaliseWizard(PNUtils.PNWizardType.setCaloriesOrVolume, WizardStepType.wsSetMethod);

        // Set up the set option page in the wizard
        wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSetMethod;
        PNIngredientRow ingredient = PNIngredient.GetInstance().FindByDBName(ingDBName);
        setMethodCtrl.Initalise();
        setMethodCtrl.SetIngredientToSet(ingredient);

        // Setup the mmolEntry option in the wizard
        if (mmolEntryType.HasValue)
        {
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsmmolEntry;
            mmolEntryCtrl.Initalise(viewAndAdjustInfo.ageRange, viewAndAdjustInfo.dosingWeightInKg, ingredient, regimenProcessor);
            mmolEntryCtrl.EntryType = mmolEntryType.Value;
        }

        // Move to next step
        WizardSetCaloriesOrVolume((WizardStepType)wizardAddProduct.ActiveStepIndex);
        InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
    }

    /// <summary>Called when user edits a row in the grid</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="PNCode">PNCode of product being updated</param>
    /// <param name="value">New product value</param>
    /// <param name="ingDBName">Ingredient DBName of value being edited</param>
    /// <param name="viewAndAdjustStr">View and adjust info as JSON string (struct PNViewAndAdjustInfo)</param>
    /// <param name="requestID">regimen request ID</param>
    /// <param name="PNProcessorXML">cached processors XML data</param>
    /// <returns>Updated rows in grid</returns>
    [WebMethod]
    public static string EditedCell(int sessionID, int siteID, string PNCode, string value, string ingDBName, string viewAndAdjustStr, int? requestID, string PNProcessorXML)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        PNViewAndAdjustInfo viewAndAdjustInfo = JsonConvert.DeserializeObject<PNViewAndAdjustInfo>(viewAndAdjustStr);

        // Get regimen processor (if not cached anymore then get version cached on page 03Apr13 XN)
        // No need to do regimen copy as not used at start of Edited cell
        PNProcessor regimenProcessor = PNProcessor.GetFromCache(requestID, false);
        if (regimenProcessor == null)
        {
            regimenProcessor = new PNProcessor();
            regimenProcessor.ReadXml(PNProcessorXML);
            PNProcessor.SaveToCache(requestID, regimenProcessor, false);
        }
        regimenProcessor.ClearEditFlag();

        // Convert value to double
        double valueDbl;
        double? volumeInml;
        if (!double.TryParse(value, out valueDbl))
            return string.Empty;

        valueDbl = valueDbl.To3SigFigish();

        // Get the product being updated
        PNProductRow product = PNProduct.GetInstance().FindByPNCode(PNCode);        

        // Calcualte the products new volume
        if (ingDBName == PNIngDBNames.Volume)
            volumeInml = valueDbl;
        else if (ingDBName == "mlPerKg")
            volumeInml = valueDbl * viewAndAdjustInfo.dosingWeightInKg;
        else
        {
            volumeInml = product.CalculateVolume(ingDBName, valueDbl);
            if (!volumeInml.HasValue)
              return string.Empty;
        }

        PNProcessor originalRegimen = (PNProcessor)regimenProcessor.Clone();

        // Update products new volume, and return grid update
        regimenProcessor.UpdateItem(PNCode, volumeInml.Value);

        // Determine if Na, and K values can be adjust back to original
        // This repeats the functionality in application_PNViewAndAdjust_controls_PNAskAdjustIng and should
        // at somepoint go into PNProcessor instead
        bool adjustments = false;
        if (regimenProcessor.AskAdjustNa && (product.PNCode != regimenProcessor.NaClPNCode) && (regimenProcessor.RegimenItems.Count() > 1))
        {
            double original = originalRegimen.CalculateTotals (new string[]{ PNIngDBNames.Sodium }).First();
            double newValue = regimenProcessor.CalculateTotals(new string[]{ PNIngDBNames.Sodium }).First();
            double IngDifference = newValue - original;
            if (!IngDifference.IsZero(2) && original > 0.0)
                adjustments = true;
        }
        if (regimenProcessor.AskAdjustK && (product.PNCode != regimenProcessor.KClPNCode) && (regimenProcessor.RegimenItems.Count() > 1))
        {
            double original = originalRegimen.CalculateTotals (new string[]{ PNIngDBNames.Potassium }).First();
            double newValue = regimenProcessor.CalculateTotals(new string[]{ PNIngDBNames.Potassium }).First();
            double IngDifference = newValue - original;
            if (!IngDifference.IsZero(2) && original > 0.0)
                adjustments = true;
        }

        // If adjusting save original
        PNProcessor.SaveToCache(requestID, originalRegimen, true);

        using (TextWriter writer = new StringWriter())
        {
            using (JsonTextWriter jsonWriter = new JsonTextWriter(writer))
            {
                jsonWriter.WriteStartObject();

                jsonWriter.WritePropertyName("Regimen");
                jsonWriter.WriteValue(regimenProcessor.ToJSONString(false, false));

                KeyValuePair<string, string>[] Items = new KeyValuePair<string, string>[3];
                // Glucose concentration label
                Items[0] = new KeyValuePair<string, string>("lbGlucoseConcentration", regimenProcessor.CalculateGlucosePercenrtageAsString());
                // Calorie Ratio label
                Items[1] = new KeyValuePair<string, string>("lbCalorieRatio", regimenProcessor.CalculateCalorieRatio());
                // Status label
                Items[2] = new KeyValuePair<string, string>("lbSavedStatus", PNRegimenStatus.Edited.ToString());

                jsonWriter.WritePropertyName("Status");
                jsonWriter.WriteValue(JsonConvert.SerializeObject(Items));

                if (adjustments)
                {
                    jsonWriter.WritePropertyName("askAdjustPNCode");
                    jsonWriter.WriteValue(PNCode);
                }

                // Write XML processor back out 03Apr13 XN
                jsonWriter.WritePropertyName("PNProcessorXML");
                jsonWriter.WriteValue(regimenProcessor.WriteXml());

                // Write XML processor copy back out (used by potassium and sodium adjustment) 03Apr13 XN
                jsonWriter.WritePropertyName("PNProcessorCopyXML");
                jsonWriter.WriteValue(originalRegimen.WriteXml());

                jsonWriter.WriteEndObject();
                jsonWriter.Close();
            }

            writer.Close();
            return writer.ToString();
        }
    }

    [WebMethod]
    public static void CleanUp(int sessionID, int? requestID)
    {
        SessionInfo.InitialiseSession(sessionID);

        PNProcessor processor =  PNProcessor.GetFromCache(requestID, false);
        if (requestID.HasValue && (processor != null) && (processor.Regimen.IsLocked))
        {
            LockResults lockResults = new LockResults("PNRegimen", "RequestID");
            lockResults.UnlockRow(requestID.Value);
        }

        PNProcessor.RemoveFromCache(requestID, false);
        PNProcessor.RemoveFromCache(requestID, true);
    }
    #endregion

    #region Add product wizard method
    /// <summary>
    /// Called when wizard next, of finish buttons are clicked.
    /// Validates current page, and moves wizard to the next stage.
    /// Some wizard pages have client side validation
    /// </summary>
    protected void wizard_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        // Get page
        int             startStepIndex  = e.CurrentStepIndex;
        WizardStepBase  currentStep     = wizardAddProduct.WizardSteps[e.CurrentStepIndex];
        IPNWizardCtrl   page            = currentStep.Controls.OfType<IPNWizardCtrl>().FirstOrDefault();
        WizardStepType  currentStepType = GetCurrentWizardStep();

        // Validate page
        if ((page != null) && !page.Validate(this.regimenProcessor, this.viewAndAdjustInfo))
            e.Cancel = true;

        // If okay move the next page (depends on add method)
        if (!e.Cancel)
        {
            switch (GetWizardType())
            {
            case PNUtils.PNWizardType.bymlProduct:          WizardAddBymlProduct     (currentStepType);       break;
            case PNUtils.PNWizardType.byProduct:            WizardAddByProduct       (currentStepType);       break;
            case PNUtils.PNWizardType.byIngredient:         WizardAddByIngredient    (currentStepType);       break;
            case PNUtils.PNWizardType.replace:              WizardReplace            (currentStepType, true); break;   
            case PNUtils.PNWizardType.setCaloriesOrVolume:  WizardSetCaloriesOrVolume(currentStepType);       break; 
            case PNUtils.PNWizardType.overage:              WizardOverage            (currentStepType);       break; 
            case PNUtils.PNWizardType.standardRegimen:      WizardStandardRegimen    (currentStepType, e);    break; 
            }

            if (startStepIndex != wizardAddProduct.ActiveStepIndex && 
                wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().Any())
                InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
        }
    }

    /// <summary>
    /// Initalise wizard step on display
    ///     Sets wizard hight based on control
    ///     Sets wizard focus
    /// </summary>
    protected void InitialiseWizardStep(IPNWizardCtrl wizardStep)
    {
        if (wizardStep == null)
            return;

        // Resize wizard depending on form size
        wizardAddProduct.Height = wizardStep.RequiredHeight ?? 200;
        string script = string.Format("$('#wizardPopup').height('{0}px'); $('#wizardPopup')[0].style.top = eval(($('#blanket').height() - {0}) / 2) + 'px'", wizardAddProduct.Height.Value + 50);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), Guid.NewGuid().ToString(), script.ToString(), true);

        // Set wizard focus
        wizardStep.Focus();
    }

    /// <summary>
    /// Called when wizard previous button is clicked
    /// Moves to previous step (only supported by some parts of the replace wizard)
    /// </summary>
    protected void wizard_PreviousButtonClick(object sender, WizardNavigationEventArgs e)
    {
        // Get page
        WizardStepBase          currentStep     = wizardAddProduct.WizardSteps[e.CurrentStepIndex];
        IPNWizardCtrl page            = currentStep.Controls.OfType<IPNWizardCtrl>().FirstOrDefault();
        WizardStepType          currentStepType = GetCurrentWizardStep();

        // If okay move the previous page (depends on add method)
        if (!e.Cancel)
        {
            switch (GetWizardType())
            {
            case PNUtils.PNWizardType.replace: WizardReplace(currentStepType, false); break;   
            }

            if (wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().Any())
                InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
        }
    }

    /// <summary>
    /// Called when add product wizard cancel button is clicked
    /// Hides the wizard
    /// </summary>
    protected void wizard_CancelButtonClick(object sender, EventArgs e)
    {
        //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CancelWizard", "hidePopup('wizardPopup', 'blanket');", true);  TFS31032  2Apr12  XN Set focus back to grid when wizard closes
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CancelWizard", "hidePopup('wizardPopup', 'blanket'); delayedPNGridFocus();", true);
    }

    /// <summary>Returns the current wizard step</summary>
    protected WizardStepType GetCurrentWizardStep()
    {
        switch (wizardAddProduct.ActiveStep.ID.ToLower())
        {
            case "wsaddmethod":                    return WizardStepType.wsAddMethod;
            case "wsselectproduct":                return WizardStepType.wsSelectProduct;
            case "wsselectingredient":             return WizardStepType.wsSelectIngredient;
            case "wsmmolentry":                    return WizardStepType.wsmmolEntry;
            case "wsentervolume":                  return WizardStepType.wsEnterVolume;
            case "wsselectingredientwithquantity": return WizardStepType.wsSelectIngredientWithQuatity;
            case "wssetmethod":                    return WizardStepType.wsSetMethod;
            case "wsenteroverage":                 return WizardStepType.wsEnterOverage;
            case "wsselectglucoseproduct":         return WizardStepType.wsSelectGlucoseProduct;
            case "wsselectaqueousorlipid":         return WizardStepType.wsSelectAqueousOrLipid;
            case "wsselectstandardregimen":        return WizardStepType.wsSelectStandardRegimen;
            case "wswizardmessage":                return WizardStepType.wsWizardMessage;
        }

        throw new ApplicationException("Invlaid wizard step " + wizardAddProduct.ActiveStep.ID);
    }

    /// <summary>
    /// Gets the wizard type that is currently being display
    /// Information is either stored in hfWizardType (set via InitaliseWizard), or read from addMethodCtrl.GetWizardType
    /// </summary>
    protected PNUtils.PNWizardType GetWizardType()
    {
        if (string.IsNullOrEmpty(hfWizardType.Value))
            return addMethodCtrl.GetWizardType();
        else
            return (PNUtils.PNWizardType)Enum.Parse(typeof(PNUtils.PNWizardType), this.hfWizardType.Value, true);
    }

    /// <summary>
    /// Initalises the add product wizard
    /// 1. Calls IPNWizardCtrl.Initalise on each control in wizard
    /// 2. Sets wizard step to startWizardStep
    /// 3. Send client side command to display the wizard
    /// </summary>
    /// <param name="wizardType">Wizard type to be displayed (null if displaying add method wizard)</param>
    /// <param name="startWizardStep">Start step for the wizard</param>
    private void InitaliseWizard(PNUtils.PNWizardType? wizardType, WizardStepType startWizardStep)
    {
        // Calls IPNWizardCtrl.Initalise on each control in wizard
        IEnumerable<Control> controls = wizardAddProduct.WizardSteps.OfType<Control>().Desendants(c => c.Controls.OfType<Control>());
        foreach (IPNWizardCtrl page in controls.OfType<IPNWizardCtrl>())
            page.Initalise();

        wizardAddProduct.ActiveStepIndex     = (int)startWizardStep;
        wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Start;

        hfWizardType.Value          = wizardType.HasValue ? wizardType.Value.ToString() : string.Empty;
        hfDefaultmmlEntryType.Value = string.Empty;     // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
        hfAskmmolEntryType.Value    = string.Empty;     // 31900 XN 29Nov12 don't display mmol Entry selection if request comes from total columns

        // Hide back button
        wizardAddProduct.WizardSteps.OfType<WizardStep>().ToList().ForEach(c => c.AllowReturn = false);

        // Send client side command to display the wizard
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "StartWizard", "popup('wizardPopup', 'blanket');", true);
        InitialiseWizardStep(wizardAddProduct.ActiveStep.Controls.OfType<IPNWizardCtrl>().First());
    }

    /// <summary>
    /// Runs the add product wizard in by ml mode so displays froms
    /// 1. Select product
    /// 2. Enter volume
    /// 3. Ask if to maintain Na, and K values
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    private void WizardAddBymlProduct(WizardStepType currentStep)
    {
        PNIngredientRow volumeIng       = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume);
        PNProductRow    selectedProduct = selectProductCtrl.GetSelectedProduct();

        switch (currentStep)
        {
            case WizardStepType.wsAddMethod:
                IEnumerable<PNProductRow> products = PNProduct.GetInstance().FindByAgeRange(viewAndAdjustInfo.ageRange).FindByInUse().OrderBySortIndex();
                selectProductCtrl.Initalise(products, regimenProcessor.RegimenItems, "Select product to add or amend", false);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectProduct;
                break;

            case WizardStepType.wsSelectProduct:
                enterVolumeCtrl.Initalise(selectedProduct, regimenProcessor, volumeIng, PNUtils.mmolEntryType.Total, viewAndAdjustInfo.dosingWeightInKg);
                wizardAddProduct.ActiveStepIndex     = (int)WizardStepType.wsEnterVolume;
                wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish; 
                break;

            case WizardStepType.wsEnterVolume:
                // Create copy of regimen (for ask adjust Na or K)
                PNProcessor originalRegimenProcessor = (PNProcessor)regimenProcessor.Clone();

                //Generate message before change
                string msg = GenerateAddWizardConfirmation(selectedProduct, volumeIng, enterVolumeCtrl.Value, PNUtils.mmolEntryType.Total);

                // Add the ingredient
                regimenProcessor.UpdateItem(selectProductCtrl.GetSelectedProduct().PNCode, enterVolumeCtrl.GetVolumeInml());

                // Display ask adjust message
                if (msgBoxAskAdjustIng.AskAdjust(msg, selectedProduct, originalRegimenProcessor, regimenProcessor, this.viewAndAdjustInfo))
                {
                    PNProcessor.SaveToCache(this.requestID_Regimen, originalRegimenProcessor, true);
                    DisplayAdjustLevelMsgBox();
                }

                // Update grid
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "hidePopup('wizardPopup', 'blanket'); UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); delayedPNGridFocus();", true);
                SetRegimeDetails(PNRegimenStatus.Edited);
                break;
        }
    }

    /// <summary>
    /// Runs the add product wizard in by product mode so displays froms
    /// 1. Select product
    /// 2. Select ingredient
    /// 3. Enter mmol entry type
    /// 4. Enter value
    /// 5. Ask if to maintain Na, and K values
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    private void WizardAddByProduct(WizardStepType currentStep)
    {
        PNProductRow    selectedProduct    = selectProductCtrl.GetSelectedProduct();
        PNIngredientRow selectedIngredient = selectIngredientCtrl.GetSelectedIngredient();

        switch (currentStep)
        {
            case WizardStepType.wsAddMethod:
                IEnumerable<PNProductRow> products = PNProduct.GetInstance().FindByAgeRange(viewAndAdjustInfo.ageRange).FindByInUse().OrderBySortIndex();
                selectProductCtrl.Initalise(products, regimenProcessor.RegimenItems, "Select product to add or amend", false);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectProduct;
                break;

            case WizardStepType.wsSelectProduct:
                IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForViewAdjust().FindByForPNProduct(selectedProduct, true).OrderBySortIndex();
                selectIngredientCtrl.Initalise(ingredients, selectedProduct.ToString(), true);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectIngredient;
                break;

            case WizardStepType.wsSelectIngredient:
                mmolEntryCtrl.Initalise(viewAndAdjustInfo.ageRange, selectedProduct.ToString(), selectedIngredient.Description, selectedIngredient.GetUnit().Abbreviation);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsmmolEntry;
                break;

            case WizardStepType.wsmmolEntry:
                enterVolumeCtrl.Initalise(selectedProduct, regimenProcessor, selectedIngredient, mmolEntryCtrl.EntryType, viewAndAdjustInfo.dosingWeightInKg);
                wizardAddProduct.ActiveStepIndex     = (int)WizardStepType.wsEnterVolume;
                wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish; 
                break;

            case WizardStepType.wsEnterVolume:
                // Create copy of regimen (for ask adjust Na or K)
                PNProcessor originalRegimenProcessor = (PNProcessor)regimenProcessor.Clone();

                //Generate message before change
                string msg = GenerateAddWizardConfirmation(selectedProduct, selectedIngredient, enterVolumeCtrl.Value, mmolEntryCtrl.EntryType);

                // Add the product
                regimenProcessor.UpdateItem(selectedProduct.PNCode, enterVolumeCtrl.GetVolumeInml());

                // Display ask adjust message
                if (msgBoxAskAdjustIng.AskAdjust(msg, selectedProduct, originalRegimenProcessor, regimenProcessor, this.viewAndAdjustInfo))
                {
                    PNProcessor.SaveToCache(this.requestID_Regimen, originalRegimenProcessor, true);
                    DisplayAdjustLevelMsgBox();
                }

                // Update grid
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "hidePopup('wizardPopup', 'blanket'); UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); delayedPNGridFocus();", true);
                SetRegimeDetails(PNRegimenStatus.Edited);
                break;
        }
    }

    /// <summary>
    /// Runs the add product wizard in by ingredient mode so displays froms
    /// 1. Select ingredient
    /// 2. Select product
    /// 3. Enter mmol entry type
    /// 4. Enter value
    /// 5. Ask if to maintain Na, and K values
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    private void WizardAddByIngredient(WizardStepType currentStep)
    {
        PNProductRow    selectedProduct    = selectProductCtrl.GetSelectedProduct();
        PNIngredientRow selectedIngredient = selectIngredientCtrl.GetSelectedIngredient();

        switch (currentStep)
        {
            case WizardStepType.wsAddMethod:
                IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForViewAdjust().OrderBySortIndex();
                selectIngredientCtrl.Initalise(ingredients, null, false);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectIngredient;
                break;

            case WizardStepType.wsSelectIngredient:
                IEnumerable<PNProductRow> products = PNProduct.GetInstance().FindByInUse().FindByAgeRange(viewAndAdjustInfo.ageRange).FindByIngredient(selectedIngredient.DBName).OrderBySortIndex();
                selectProductCtrl.Initalise(products, regimenProcessor.RegimenItems, "Select product to add or amend", false);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectProduct;
                break;

            case WizardStepType.wsSelectProduct:
                mmolEntryCtrl.Initalise(viewAndAdjustInfo.ageRange, selectedProduct.ToString(), selectedIngredient.Description, selectedIngredient.GetUnit().Abbreviation);
                if (!string.IsNullOrEmpty(hfDefaultmmlEntryType.Value))         // TFS31243 5Apr12 XN When add by clicking on total row either add by total or per kg depending on total row selected
                    mmolEntryCtrl.EntryType = (PNUtils.mmolEntryType)Enum.Parse(typeof(PNUtils.mmolEntryType), hfDefaultmmlEntryType.Value);

                if (string.IsNullOrEmpty(hfAskmmolEntryType.Value) || BoolExtensions.PharmacyParse(hfAskmmolEntryType.Value))
                    wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsmmolEntry;
                else
                    WizardAddByIngredient(WizardStepType.wsmmolEntry);  // 31900 XN 29Nov12 don't display mmol Entry selection if request comes from total columns
                break;

            case WizardStepType.wsmmolEntry:
                enterVolumeCtrl.Initalise(selectedProduct, regimenProcessor, selectedIngredient, mmolEntryCtrl.EntryType, viewAndAdjustInfo.dosingWeightInKg);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsEnterVolume;
                wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish; 
                break;

            case WizardStepType.wsEnterVolume:
                // Create copy of regimen (for ask adjust Na or K)
                PNProcessor originalRegimenProcessor = (PNProcessor)regimenProcessor.Clone();

                //Generate message before change
                string msg = GenerateAddWizardConfirmation(selectedProduct, selectedIngredient, enterVolumeCtrl.Value, mmolEntryCtrl.EntryType);

                // Add the ingredient
                regimenProcessor.UpdateItem(selectedProduct.PNCode, enterVolumeCtrl.GetVolumeInml());

                // Display ask adjust message
                if (msgBoxAskAdjustIng.AskAdjust(msg, selectedProduct, originalRegimenProcessor, regimenProcessor, this.viewAndAdjustInfo))
                {
                    PNProcessor.SaveToCache(this.requestID_Regimen, originalRegimenProcessor, true);
                    DisplayAdjustLevelMsgBox();
                }

                // Update grid
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "hidePopup('wizardPopup', 'blanket'); UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); delayedPNGridFocus();", true);
                SetRegimeDetails(PNRegimenStatus.Edited);
                break;
        }
    }    

    /// <summary>
    /// Runs the replace product wizard so displays froms
    /// 1. Select ingredient (displayed with quantity)
    /// 2. Select product
    /// 3. Ask if to maintain Na, and K values, and confirm
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    /// <param name="next">If next button pressed (if false then use back button)</param>
    private void WizardReplace(WizardStepType currentStep, bool next)
    {
        PNProductRow    originalProduct    = PNProduct.GetInstance().FindByPNCode(hfCurrentRowPNCode.Value);
        PNProductRow    selectedProduct    = selectProductCtrl.GetSelectedProduct();
        PNIngredientRow selectedIngredient = selectIngredientWithQuantityCtrl.GetSelectedIngredient();

        switch (currentStep)
        {
            case WizardStepType.wsSelectIngredientWithQuatity:
                {
                IEnumerable<string> existingPNCodes= regimenProcessor.RegimenItems.Select(r => r.PNCode);
                IEnumerable<PNProductRow> products = PNProduct.GetInstance().FindByInUse().FindByAgeRange(viewAndAdjustInfo.ageRange).RemoveByPNCode(existingPNCodes).FindByIngredient(selectedIngredient.DBName).OrderBySortIndex();
                string caption = string.Format("Select product to replace {0}", originalProduct);

                selectProductCtrl.Initalise(products, regimenProcessor.RegimenItems, caption, false);
                wizardAddProduct.ActiveStepIndex     = (int)WizardStepType.wsSelectProduct;
                wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Step;
                }
                break;

            case WizardStepType.wsSelectProduct:
                {
                    PNRegimenItem originalItem = regimenProcessor.RegimenItems.FindByPNCode(originalProduct.PNCode);
                    string volumnUnits = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume).GetUnit().Abbreviation;
                    string ingUnits = PNIngredient.GetInstance().FindByDBName(selectedIngredient.DBName).GetUnit().Abbreviation;
                    double ingOriginalValue = originalProduct.CalculateIngredientValue(selectedIngredient.DBName, originalItem.VolumneInml);
                    double newProductVolume = selectedProduct.CalculateVolume(selectedIngredient.DBName, ingOriginalValue).Value;
                    double ingNewValue = selectedProduct.CalculateIngredientValue(selectedIngredient.DBName, newProductVolume);

                    StringBuilder caption = new StringBuilder("Click Finish to replace<br /><br />");
                    caption.AppendFormat("{0} {1} {2} ({3} {4} {5}) with<br />", originalItem.VolumneInml.ToPNString(), volumnUnits, originalProduct, ingOriginalValue.To3SigFigish().ToPNString(), ingUnits, selectedIngredient);
                    caption.AppendFormat("{0} {1} {2} ({3} {4} {5})<br /><br />", newProductVolume.ToPNString(), volumnUnits, selectedProduct, ingNewValue.To3SigFigish().ToPNString(), ingUnits, selectedIngredient);
                    caption.Append("else go Previous and choose another product.");

                    wizardMessageCtrl.Message = caption.ToString();
                    wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsWizardMessage;
                    wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;
                }
                break;

            case WizardStepType.wsWizardMessage:
                if (next)
                {
                    PNProcessor originalRegimenProcessor = (PNProcessor)regimenProcessor.Clone();
                    regimenProcessor.Replace (originalProduct.PNCode, selectedProduct.PNCode, selectedIngredient.DBName);

                    // Display ask adjust message
                    string msg = string.Format("Replaced '{0}' with '{1}'", originalProduct, selectedProduct);
                    if (msgBoxAskAdjustIng.AskAdjust(msg, selectedProduct, originalRegimenProcessor, regimenProcessor, this.viewAndAdjustInfo))
                    {
                        PNProcessor.SaveToCache(this.requestID_Regimen, originalRegimenProcessor, true);
                        DisplayAdjustLevelMsgBox();
                    }

                    // Update grid (while reselecting newly added row)
                    string script = "hidePopup('wizardPopup', 'blanket'); UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); delayedPNGridFocus();";
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", script, true);
                    SetRegimeDetails(PNRegimenStatus.Edited);
                }
                else
                    WizardReplace(WizardStepType.wsSelectIngredientWithQuatity, true);
                break;
        }
    }

    /// <summary>
    /// Runs the set volume or calories product wizard. 
    /// Displays froms
    /// 1. Select Set method
    /// 2. Select total or total/kg
    /// 3. Enter volume
    /// 4. Select glucose product
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    private void WizardSetCaloriesOrVolume(WizardStepType currentStep)
    {
        PNIngredientRow ingToSet = setMethodCtrl.GetIngredientToSet();

        switch (currentStep)
        {
        case WizardStepType.wsSetMethod:
            if (ingToSet.DBName == PNIngDBNames.Glucose)
            {
                mmolEntryCtrl.EntryType = PNUtils.mmolEntryType.Total;
                enterVolumeCtrl.Initalise(regimenProcessor, ingToSet, mmolEntryCtrl.EntryType, this.viewAndAdjustInfo);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsEnterVolume;
            }
            else
            {
                mmolEntryCtrl.Initalise(viewAndAdjustInfo.ageRange, viewAndAdjustInfo.dosingWeightInKg, ingToSet, regimenProcessor);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsmmolEntry;
            }
            break;

        case WizardStepType.wsmmolEntry:
            enterVolumeCtrl.Initalise(regimenProcessor, ingToSet, mmolEntryCtrl.EntryType, this.viewAndAdjustInfo);
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsEnterVolume;
            wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Step;
            break;

        case WizardStepType.wsEnterVolume:
            selectGlucoseProductCtrl.Initalise(ingToSet, enterVolumeCtrl.GetTotalValueForSetWizard(regimenProcessor), regimenProcessor, viewAndAdjustInfo, false);
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectGlucoseProduct;
            wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;
            break;

        case WizardStepType.wsSelectGlucoseProduct:
            PNProductRow selectedProduct = selectGlucoseProductCtrl.GetSelectedProduct();          
            bool         mixing          = selectGlucoseProductCtrl.Mixing;

            if (ingToSet.DBName == PNIngDBNames.Volume)
                regimenProcessor.AdjustVolume(mixing, selectedProduct.PNCode, enterVolumeCtrl.GetTotalValueForSetWizard(regimenProcessor), viewAndAdjustInfo);
            else // Calories or Glucose
                regimenProcessor.AdjustCalories(mixing, selectedProduct.PNCode, enterVolumeCtrl.GetTotalValueForSetWizard(regimenProcessor), viewAndAdjustInfo);

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "hidePopup('wizardPopup', 'blanket'); UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); delayedPNGridFocus();", true);
            SetRegimeDetails(PNRegimenStatus.Edited);
            break;
        }
    }

    /// <summary>
    /// Runs the overage wizard. 
    /// Displays froms
    /// 1. Select Aqueous Or Lipid
    /// 2. Select product
    /// 3. Enter volume
    /// 4. Calculated volume
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    private void WizardOverage(WizardStepType currentStep)
    {
        PNProductType type            = selectAqueousOrLipidCtrl.GetSelection();
        PNProductRow  selectedProduct = selectProductCtrl.GetSelectedProduct();

        switch (currentStep)
        {
        case WizardStepType.wsSelectAqueousOrLipid:
            PNProduct products =  PNProduct.GetInstance();
            IEnumerable<PNProductRow> productToDisplay;

            productToDisplay = regimenProcessor.RegimenItems.FindByAqueousOrLipid(type).Select(i => products.FindByPNCode(i.PNCode));

            string caption = "Overage will be adjusted so that whole containers of one product can be used.<br />Select the product which is to be used in full.";
            selectProductCtrl.Initalise(productToDisplay, regimenProcessor.RegimenItems, caption, regimenProcessor.Regimen.Supply48Hours);
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectProduct;
            break;

        case WizardStepType.wsSelectProduct:
            enterVolumeCtrl.Initalise(selectedProduct, regimenProcessor);
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsEnterVolume;
            break;

        case WizardStepType.wsEnterVolume:
            PNRegimenItem item       = regimenProcessor.RegimenItems.FindByPNCode(selectedProduct.PNCode);            
            double totalVolumeInml   = regimenProcessor.RegimenItems.FindByAqueousOrLipid(type).Sum(i => i.VolumneInml);
            double currentVolumeInml = item.VolumneInml;

            if (regimenProcessor.Regimen.Supply48Hours)
            {
                totalVolumeInml   *= 2.0; 
                currentVolumeInml *= 2.0;
            }
            double overageInml = (totalVolumeInml * (enterVolumeCtrl.Value - currentVolumeInml) /  currentVolumeInml).To3SigFigish();

            enterOverageCtrl.Initalise();
            enterOverageCtrl.Initalise(selectedProduct, overageInml, regimenProcessor);

            wizardAddProduct.ActiveStepIndex     = (int)WizardStepType.wsEnterOverage;
            wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;
            break;

        case WizardStepType.wsEnterOverage:
            if (type == PNProductType.Lipid)
                regimenProcessor.Regimen.OverageLipid = enterOverageCtrl.Value;
            else 
                regimenProcessor.Regimen.OverageAqueousOrCombined = enterOverageCtrl.Value;

            SetRegimeDetails(PNRegimenStatus.Edited);
            StoreViewAndAdjustInfo();
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "hidePopup", "hidePopup('wizardPopup', 'blanket');", true);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true) + "'); delayedPNGridFocus();", true);
            break;
        }
    }

    /// <summary>
    /// Runs the standard regime wizard. 
    /// Displays froms
    /// 1. Select standard regime
    /// if pead
    ///     2. Select total or total/kg
    ///     3. Enter volumer volume
    ///     4. Select glucose productulated volume
    /// </summary>
    /// <param name="currentStep">current wizard step</param>
    /// <param name="e">Wizard args so can canel the move next</param>
    private void WizardStandardRegimen(WizardStepType currentStep, WizardNavigationEventArgs e)
    {
        PNStandardRegimenRow standardRegimen = selectStandardRegimenCtrl.GetSelectedStandardRegimen();
        PNIngredientRow      volume          = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume);
        double requriedVolumeInml;

        switch (currentStep)
        {
        case WizardStepType.wsSelectStandardRegimen:
            if (standardRegimen == null)
            {
                AutoPopulateRegimen(false);
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "hidePopup", "hidePopup('wizardPopup', 'blanket');", true);
            }
            else if (regimenProcessor.Prescription.AgeRage == AgeRangeType.Adult)
            {
                IEnumerable<PNProductRow> validItems = PNProduct.GetInstance().FindByInUse().FindByAgeRange(regimenProcessor.Prescription.AgeRage);
                this.regimenProcessor.Set(standardRegimen.GetRegimenItems(validItems).ToList());

                // 95272 10Sep14 XN set to standard regimen name              
                if (PNSettings.ViewAndAdjust.SetRegimenNameToStandardRegimenName)
                    regimenProcessor.Regimen.CreateName(regimenProcessor.Prescription, standardRegimen);

                PNBrokenRule? brokenRule = regimenProcessor.ValidateProductLimits();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "hidePopup", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true) + "');hidePopup('wizardPopup', 'blanket');", true);
                if (brokenRule.HasValue)
                    DisplayBrokenRules("Maximum dose exceeded", new PNBrokenRule[] { brokenRule.Value }, string.Empty, "[{ text: 'OK', click: function() { $(this).dialog('close'); } }]", 0, string.Empty);
                SetRegimeDetails(PNRegimenStatus.Edited);
            }
            else if (!standardRegimen.GetRegimenItems().FindByOnlyContainGlucose().Any())
            {
                //  21Mar13 XN  If no glucode in standard regimen then don't display glucose selection list.
                wizardMessageCtrl.Message            = "No glucose is present in the regimen<br /><br />Cannot adjust volume and calorie content";
                wizardAddProduct.ActiveStepIndex     = (int)WizardStepType.wsWizardMessage;
                wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;
            }
            else
            {   // Pead
                mmolEntryCtrl.Initalise(AgeRangeType.Paediatric, standardRegimen.ToString(), volume.Description, volume.GetUnit().Abbreviation);
                wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsmmolEntry;
            }
            break;

        case WizardStepType.wsWizardMessage:
            {
                //  21Mar13 XN  If no glucode in standard regimen then then have informed user so just populate the regimen
                IEnumerable<PNProductRow> validItems = PNProduct.GetInstance().FindByInUse().FindByAgeRange(regimenProcessor.Prescription.AgeRage);
                var standardRegimenItem = standardRegimen.GetRegimenItems(validItems).ToList();
                if (regimenProcessor.Prescription.AgeRage == AgeRangeType.Paediatric)
                    standardRegimenItem.ForEach(v => v.VolumneInml *= regimenProcessor.Prescription.DosingWeightInkg);

                regimenProcessor.Set(standardRegimenItem);

                // 95272 10Sep14 XN set to standard regimen name              
                if (PNSettings.ViewAndAdjust.SetRegimenNameToStandardRegimenName)
                    regimenProcessor.Regimen.CreateName(regimenProcessor.Prescription, standardRegimen);

                PNBrokenRule? brokenRule = regimenProcessor.ValidateProductLimits();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); hidePopup('wizardPopup', 'blanket');", true);
                if (brokenRule.HasValue)
                    DisplayBrokenRules("Maximum dose exceeded", new PNBrokenRule[] { brokenRule.Value }, string.Empty, "[{ text: 'OK', click: function() { $(this).dialog('close'); } }]", 0, string.Empty);
                SetRegimeDetails(PNRegimenStatus.Edited);
            }
            break;

        case WizardStepType.wsmmolEntry:
            double mlsPerKg;
            if (regimenProcessor.Prescription.DosingWeightInkg < 20.0 )
                mlsPerKg = 100.0;
            else if (regimenProcessor.Prescription.DosingWeightInkg < 30.0 )
                mlsPerKg = 80.0;
            else
                mlsPerKg = 60.0;

            if (mmolEntryCtrl.EntryType == PNUtils.mmolEntryType.PerKg)
                enterVolumeCtrl.Initalise("Enter total volume of feed in ml /kg of body weight", mlsPerKg);
            else
                enterVolumeCtrl.Initalise("Enter total volume of feed (mls)", mlsPerKg * regimenProcessor.Prescription.DosingWeightInkg);
            wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsEnterVolume;
            break;

        case WizardStepType.wsEnterVolume:
            {
                IEnumerable<PNProductRow> validItems = PNProduct.GetInstance().FindByInUse().FindByAgeRange(regimenProcessor.Prescription.AgeRage);
                List<PNRegimenItem> standardRegimenItems = standardRegimen.GetRegimenItems(validItems).ToList();
                standardRegimenItems.ForEach(i => i.VolumneInml *= regimenProcessor.Prescription.DosingWeightInkg);

                PNProcessor processorCopy = (PNProcessor)regimenProcessor.Clone();
                processorCopy.Set(standardRegimenItems);
                PNProcessor.SaveToCache(requestID_Regimen, processorCopy, true);

                PNBrokenRule? brokenRule = processorCopy.ValidateProductLimits();

                double totalVolume = standardRegimenItems.CalculateTotal(PNIngDBNames.Volume); 
                double totalVolmueGlucodeOnly = standardRegimenItems.FindByOnlyContainGlucose().CalculateTotal(PNIngDBNames.Volume);
                double totalGlucose = standardRegimenItems.CalculateTotal(PNIngDBNames.Glucose);

                requriedVolumeInml = enterVolumeCtrl.Value;
                if (mmolEntryCtrl.EntryType == PNUtils.mmolEntryType.PerKg)
                    requriedVolumeInml *= processorCopy.Prescription.DosingWeightInkg;

                if ((totalVolume - totalVolmueGlucodeOnly) > requriedVolumeInml)
                {
                    enterVolumeCtrl.ErrorMessage = string.Format("Volume of ingredient is {0} ml and is greater than the final volume required.", (totalVolume - totalVolmueGlucodeOnly).ToVDUIncludeZeroString());                
                    e.Cancel = true;    // XN 26Mar13 59607 If don't cancel wizard will jump to next step
                }
                else 
                {
                    selectGlucoseProductCtrl.Initalise(volume, requriedVolumeInml, processorCopy, viewAndAdjustInfo, true, true);
                    wizardAddProduct.ActiveStepIndex = (int)WizardStepType.wsSelectGlucoseProduct;
                    wizardAddProduct.ActiveStep.StepType = System.Web.UI.WebControls.WizardStepType.Finish;

                    if (brokenRule != null)
                        DisplayBrokenRules("Maximum dose exceeded", new PNBrokenRule[] { brokenRule.Value }, string.Empty, "[{ text: 'OK', click: function() { $(this).dialog('close'); } }]", 0, string.Empty);
                }
            }
            break;
       
        case WizardStepType.wsSelectGlucoseProduct:
            {
            PNProductRow selectedProduct = selectGlucoseProductCtrl.GetSelectedProduct();          
            bool         mixing          = selectGlucoseProductCtrl.Mixing;

            requriedVolumeInml = enterVolumeCtrl.Value;
            if (mmolEntryCtrl.EntryType == PNUtils.mmolEntryType.PerKg)
                requriedVolumeInml *= regimenProcessor.Prescription.DosingWeightInkg;

            PNProcessor processorTemp = PNProcessor.GetFromCache(requestID_Regimen, true);
            regimenProcessor.Set(processorTemp.RegimenItems.ToList());

            if (selectedProduct != null)
                regimenProcessor.AdjustVolume(mixing, selectedProduct.PNCode, requriedVolumeInml, viewAndAdjustInfo);

            // 95272 10Sep14 XN set to standard regimen name              
            if (PNSettings.ViewAndAdjust.SetRegimenNameToStandardRegimenName)
                regimenProcessor.Regimen.CreateName(regimenProcessor.Prescription, standardRegimen);

            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Update", "UpdateGrid('" + regimenProcessor.ToJSONString(true, false) + "'); hidePopup('wizardPopup', 'blanket');", true);
            SetRegimeDetails(PNRegimenStatus.Edited);

            PNProcessor.RemoveFromCache(requestID_Regimen, true);
            }
            break;
        }
    }

    private void StoreViewAndAdjustInfo()
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "StoreViewAndAdjustInfo", "$('#hfViewAndAdjustInfo').val('" + JsonConvert.SerializeObject(viewAndAdjustInfo) + "');", true);
    }

    /// <summary>Generates final message on the Add wizards</summary>
    /// <param name="product">Product being added</param>
    /// <param name="ing">Ingredient being added</param>
    /// <param name="value">Ingredient value</param>
    /// <param name="entryType">If by total or per Kg</param>
    /// <returns>final message</returns>
    private string GenerateAddWizardConfirmation(PNProductRow product, PNIngredientRow ing, double value, PNUtils.mmolEntryType entryType)
    {
        bool adding    = (regimenProcessor.RegimenItems.FindByPNCode(product.PNCode) == null);
        bool byVolume  = (ing.DBName == PNIngDBNames.Volume);
        string perKgStr= (entryType == PNUtils.mmolEntryType.PerKg) ? "/kg" : string.Empty;

        StringBuilder msg = new StringBuilder();
        if (adding && byVolume)         // Adding by volume
            msg.AppendFormat("Added {0} {1}{2} of {3} to regimen.", value.ToPNString(), ing.GetUnit().Abbreviation, perKgStr, product.Description);
        else if (!adding && byVolume)   // Updating by volume
            msg.AppendFormat("Updated {0} to {1} {2}{3}", product.Description, value.ToPNString(), ing.GetUnit().Abbreviation, perKgStr);
        else if (adding && !byVolume)   // Adding by ingredient
            msg.AppendFormat("Added {0} to set total {1} to {2} {3}{4}.", product.Description, ing.Description, value.ToPNString(), ing.GetUnit().Abbreviation, perKgStr);
        else if (!adding && !byVolume)  // Updating by ingredient
            msg.AppendFormat("Updated {0} to set total {1} to {2} {3}{4}.", product.Description, ing.Description, value.ToPNString(), ing.GetUnit().Abbreviation, perKgStr);

        return msg.ToString();
    }
    #endregion

    #region Private Methods
    private void SetViewAndAdjustInfo()
    {
        viewAndAdjustInfo.ageRange                = regimenProcessor.Prescription.AgeRage;
        viewAndAdjustInfo.dosingWeightInKg        = regimenProcessor.Prescription.DosingWeightInkg;
        viewAndAdjustInfo.requestID_Prescription  = regimenProcessor.Regimen.RequestID_Parent;

        hfViewAndAdjustInfo.Value = JsonConvert.SerializeObject(viewAndAdjustInfo);
    }

    private void SetButtons()
    {
        // Get user policies for PN
        bool viewer     = SessionInfo.HasAnyPolicies(PNUtils.Policy.Viewer);
        bool editor     = this.mode != PNRegimenMode.ViewReadOnly && SessionInfo.HasAnyPolicies(PNUtils.Policy.Editor);     // 12Nov15 XN 133905 add view read only check
        bool authoriser = this.mode != PNRegimenMode.ViewReadOnly && SessionInfo.HasAnyPolicies(PNUtils.Policy.Authoriser); // 12Nov15 XN 133905 add view read only check

        // Determine if the regimen setat
        bool readOnly = this.regimenProcessor.Regimen.Cancelled || !this.regimenProcessor.Regimen.IsLocked;

        // Setup buttons to determine what user can do
        btnPrescription.Enabled = viewer;
        btnRegimen.Enabled      = viewer;
        btnRequirements.Enabled = viewer;
        btnPopulate.Enabled     = editor && !readOnly;
        btnAdd.Enabled          = editor && !readOnly;
        btnReplace.Enabled      = editor && !readOnly;
        btnDelete.Enabled       = editor && !readOnly;
        btnSet.Enabled          = editor && !readOnly;
        btnMultiplyBy.Enabled   = editor && !readOnly;
        btnOverage.Enabled      = editor && !readOnly;
        btnSummary.Enabled      = viewer;
        btnProductWeight.Enabled= viewer;
        btnSave.Enabled         = editor && !readOnly;
        btnAuthorise.Enabled    = authoriser && !this.regimenProcessor.Regimen.Cancelled && !this.regimenProcessor.Regimen.PNAuthorised;
        btnEdit.Enabled         = editor     && !this.regimenProcessor.Regimen.Cancelled && !this.regimenProcessor.Regimen.IsLocked;
        btnExit.Enabled         = true;
    }

    /// <summary>Sets patient status information</summary>
    /// <param name="patient">Patient Info</param>
    /// <param name="episode">Episode info</param>
    private void SetPatientDetails()
    {
        lbName.Text         = regimenProcessor.Patient.Description;
        lbWeight.Text       = viewAndAdjustInfo.dosingWeightInKg.ToString("0.##") + "kg";
        lbDOB.Text          = regimenProcessor.Patient.DOB.ToPharmacyDateString();
        lbPatientStatus.Text= regimenProcessor.Episode.EpisodeTypeStr;

        WardRow ward = regimenProcessor.Episode.GetWard();
        lbWard.Text = (ward != null) ? ward.ToString() : "&nbsp;";

        ConsultantRow consultant = regimenProcessor.Episode.GetConsultant();
        lbConsultant.Text = (consultant != null) ? consultant.Description : "&nbsp;";

        //string caseNoDisplayName = regimenProcessor.Patient.GetCaseNumberDisplayName();   05Jul13 XN  27252
        string caseNoDisplayName = PharmacyCultureInfo.CaseNumberDisplayName;
        lbCaseNoDisplayName.Text    = caseNoDisplayName + ": ";
        lbCaseNo.Text               = regimenProcessor.Patient.GetCaseNumber();

        //string NHSNumberDisplayName = regimenProcessor.Patient.GetNHSNumberDisplayName(); 05Jul13 XN  27252
        string NHSNumberDisplayName = PharmacyCultureInfo.NHSNumberDisplayName;
        if (!NHSNumberDisplayName.EqualsNoCase(caseNoDisplayName))
        {
            lbNHSNumberDisplayName.Text = NHSNumberDisplayName + ": ";
            lbNHSNumber.Text            = regimenProcessor.Patient.GetNHSNumber();
        }
        else
        {
            lbNHSNumberDisplayName.Visible = false;
            lbNHSNumber.Visible            = false;
        }

        // Hong Kong specific mode to get and display patient Chinese name 25Sep15 XN 77780 
        if (Database.CheckSPExist("pPNRegimenPatientExtraInfo"))
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",  SessionInfo.SessionID);
            parameters.Add("EpisodeID",         regimenProcessor.Episode.EpisodeID);
            parameters.Add("RequestID_Regimen", this.requestID_Regimen ?? 0);

            GenericTable2 entityExtraInfo = new GenericTable2("Table");
            entityExtraInfo.LoadBySP("pPNRegimenPatientExtraInfo", parameters);

            foreach (DataColumn c in entityExtraInfo.Table.Columns)
            {
                string labelName = c.ColumnName;
                var    label     = this.pnDetails.FindControl(labelName) as Label;
                if (label != null && entityExtraInfo.Count > 0 && entityExtraInfo[0].RawRow[labelName] != DBNull.Value)
                {
                    label.Text += " " + entityExtraInfo[0].RawRow[labelName];
                }
            }
        }
    }

    /// <summary>
    /// Set's the regimen detail in the status panel.
    /// Due to issues with maintaining view state (with an ASP.NET wizard), 
    /// and the order that scripts are run with regards to view state
    /// The method will set the status labels directly and call java side SetStatus method
    /// </summary>
    private void SetRegimeDetails(PNRegimenStatus? status)
    {
        List<KeyValuePair<string, string>> Items = new List<KeyValuePair<string,string>>(); 

        // Name
        lbRegimen.Text = regimenProcessor.Regimen.Description;
        Items.Add(new KeyValuePair<string,string>(lbRegimen.ID, lbRegimen.Text));   // // 95272 10Sep14 XN added so that name gets update as can now change

        // Overage
        if (this.regimenProcessor.Regimen.IsCombined)
            lbOverage.Text = string.Format("{0} mL (Combined)", regimenProcessor.Regimen.OverageAqueousOrCombined);
        else
            lbOverage.Text = string.Format("aqueous {0} mL, lipid {1} mL", regimenProcessor.Regimen.OverageAqueousOrCombined, regimenProcessor.Regimen.OverageLipid);
        Items.Add(new KeyValuePair<string,string>(lbOverage.ID, lbOverage.Text));

        // Route
        if (regimenProcessor.Regimen.CentralLineOnly)
            lbRoute.Text = "For Central Intravenous use only";
        else
            lbRoute.Text = "For either Central or Peripheral Intravenous use";
        Items.Add(new KeyValuePair<string,string>(lbRoute.ID, lbRoute.Text));

        // Age Range
        lbType.Text = viewAndAdjustInfo.ageRange.ToString();
        Items.Add(new KeyValuePair<string,string>(lbType.ID, lbType.Text));

        // Supply Duration
        if (PNSettings.Prescribing.Allow48HourBags() || regimenProcessor.Regimen.Supply48Hours)
        {
            lbSupplyLabel.Visible = true;
            lbSupply.Text = regimenProcessor.Regimen.Supply48Hours ? "48Hrs (values displayed for 24Hrs)" : "24Hrs";
            Items.Add(new KeyValuePair<string, string>(lbSupply.ID, lbSupply.Text));
        }
        else
            lbSupplyLabel.Visible = false;

        // Glucose concentration
        lbGlucoseConcentration.Text = regimenProcessor.CalculateGlucosePercenrtageAsString();
        Items.Add(new KeyValuePair<string,string>(lbGlucoseConcentration.ID, lbGlucoseConcentration.Text));

        // Calorie Ratio
        lbCalorieRatio.Text = regimenProcessor.CalculateCalorieRatio();
        Items.Add(new KeyValuePair<string,string>(lbCalorieRatio.ID, lbCalorieRatio.Text));

        // Saved Status
        if (status.HasValue)
        {
            lbSavedStatus.Text = status.ToString();
            if (status.Value == PNRegimenStatus.Cancelled)
                lbSavedStatus.ForeColor = Color.Red;
            Items.Add(new KeyValuePair<string, string>(lbSavedStatus.ID, lbSavedStatus.Text));
        }

        // Additional Instrcutions
        lbAdditionalInstructions.Text = this.regimenProcessor.Prescription.GetFreeTextDirection();

        // Dispensing Instrcutions
        lbDispensingInstructions.Text = this.regimenProcessor.Prescription.GetDispensingInstruction();

        // Call java side SetStatus method 
        // JSON string
        // {
        //  "ID": "lbOverage"
        //  "Value": 10 ml (Combined)
        // }
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SetCalculatedRegimeDetails", "SetStatus('" + JsonConvert.SerializeObject(Items.ToArray()) + "');", true);
    }

    /// <summary>
    /// Auto populates regimen from ingredients using PNProcessor.AutoPopulateRegimen method.
    /// Will warn user if any product volume has to be reduced as over maximum.
    /// Will warn user if any product volume is below 0 (at which point to autopopulate is via post back in Page_Load)
    /// </summary>
    /// <param name="autoPopulateOnCancel">If canceling -ve volume popup cause it to still auto populate with -ve volumes (normal on inital regimen creation)</param>
    private void AutoPopulateRegimen(bool autoPopulateOnCancel)
    {
        PNProcessor copyOfProcessor = (PNProcessor)regimenProcessor.Clone();
        Dictionary<PNProductRow,double> doseReducedForMax, doseReducedForMaxPerKg;
        StringBuilder limitedValueMessage  = new StringBuilder();
        StringBuilder negativeValueMessage = new StringBuilder();
        string script = string.Empty;
        bool doNow = true;

        copyOfProcessor.AutoPopulateRegimen(out doseReducedForMax, out doseReducedForMaxPerKg, false);

        // Create limit messages
        foreach (KeyValuePair<PNProductRow, double> product in doseReducedForMax)
            limitedValueMessage.AppendFormat("{0}: dose reduced from {1} mL to maximum of {2} mL<br />", product.Key, product.Value.ToPNString(), product.Key.MaxmlTotal);
        foreach (KeyValuePair<PNProductRow, double> product in doseReducedForMaxPerKg)
            limitedValueMessage.AppendFormat("{0}: dose reduced from {1} mL per kg to maximum of {2} mL per kg<br />", product.Key, (product.Value / copyOfProcessor.Prescription.DosingWeightInkg).ToPNString(), product.Key.MaxmlPerKg);  // TFS30926 30Mar12 XN added per kg text

        if (limitedValueMessage.Length > 0)
        {
            script += "$('<div>" + limitedValueMessage.ToString() + "</div>').dialog({" +
                                "modal: true, " +
                                "resizable: false, " +
                                "width: 600, " +
                                "maxHeight: 700, " +
                                "title: 'Please Note', " +
                                "appendTo: 'form', " + 
                                "focus: function(type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(0)').focus(); }, " + 
                                "close: function(event, ui) { window.event.cancelBubble = true; window.event.returnValue = false; }," +     // TFS31032  2Apr12  XN If escape pressed prevent it trying to close the view and adjust from
                                "buttons: [ { text: 'OK', click: function() { $(this).dialog('close'); } } ] " + 
                     "});";
        }

        // Create -ve volume message
        if (copyOfProcessor.RegimenItems.Any(i => i.VolumneInml < 0.0))
        {
            negativeValueMessage.Append("It is not possible to create the regimen exactly as defined.<br /><br />");
            negativeValueMessage.Append("The following would require a negative volume, since other<br />");
            negativeValueMessage.Append("ingredients alone provide more constituents than the regimen requires.<br /><br />");
            foreach (PNRegimenItem item in copyOfProcessor.RegimenItems.Where(i => i.VolumneInml < 0.0))
                negativeValueMessage.AppendFormat("{0} ml    {1}<br />", item.VolumneInml, item.GetProduct());
            negativeValueMessage.Append("<br />You may leave these in the regimen and manually amend or replace with<br />");
            negativeValueMessage.Append("alternatives, or you may remove these products from the regimen now.<br /><br />");
            negativeValueMessage.Append("Do you wish to remove the product(s) listed above from the regimen now?");
        }

        if (negativeValueMessage.Length > 0)
        {
            // Dialog displayed from a timeout to fix very occasional issue displaying it in ie8 113321 XN 11Mar15
            script += "setTimeout(function(){ $('<div>" + negativeValueMessage.ToString() + "</div>').dialog({" +
                                "modal: true, " +
                                "resizable: false, " +
                                "draggable: false, " + 
                                "width: 600, " +
                                "maxHeight: 700, " +
                                "title: 'CAUTION - Regimen cannot be created', " +
                                "appendTo: 'form', " + 
                                "focus: function(type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(1)').focus(); }, " + 
                                "buttons: [ " +
                                          " { text: 'Yes', click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'AutoPopulate:RemoveNegative'); } }, " +
                                          " { text: 'No',  click: function() { $(this).dialog('close'); __doPostBack('upButtonsAndPatientDetails', 'AutoPopulate'); } } " +
                                          " ] ";

            // If allowed canceling -ve volume popup from will cause it to auto populate (normal when method is called during regimen creation)
            // TFS30738 29Mar12 XN also prevented having multi postback as event also fires if user clicks the Yes or No button (caused complete refresh of form as IsPostBack method always returned false)
            // TFS31032  2Apr12  XN If escape pressed prevent it trying to close the view and adjust from
            if (autoPopulateOnCancel)
                script += ", close: function(event, ui) { if (event.button == 0) { __doPostBack('upButtonsAndPatientDetails', 'AutoPopulate'); window.event.cancelBubble = true; window.event.returnValue = false; } }";
            else
                script += ", close: function(event, ui) { window.event.cancelBubble = true; window.event.returnValue = false; }";

            script += "}); }, 60);";

            doNow = false;                
        }

        // All okay so go for it
        if (doNow)
        {   
            regimenProcessor.Set(copyOfProcessor.RegimenItems.ToList());                                
            ScriptManager.RegisterStartupScript(this, this.GetType(), "updateRegimen", "UpdateGrid('" + regimenProcessor.ToJSONString(true, true, false, false) + "');", true);
            SetRegimeDetails(PNRegimenStatus.Edited);
        }

        // Display error
        if (script.Length > 0)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AutoPopulate", script, true);    // Ask user questions first
    }

    private void DisplayBrokenRules(string title, IEnumerable<PNBrokenRule> brokenRules, string caption, string buttons, int defaultButton, string closeEvent)
    {
        // Dialog displayed from a timeout to fix very occasional issue displaying it in ie8 113321 XN 11Mar15
        StringBuilder script = new StringBuilder("setTimeout(function(){ $(\"<div><table cellspacing='10'><colgroup><col width='15px' valign='top'></col><col width='30%' valign='top'></col><col width='70%' valign='top'></col></colgroup>");
        foreach (PNBrokenRule rule in brokenRules)
        {
            script.Append("<tr>");

            // Add image
            script.Append("<td>");
            switch (rule.Type)
            {
            case PNBrokenRuleType.Critical: script.Append("<img src='images/exclamation_red.gif'    />"); break;
            case PNBrokenRuleType.Warning : script.Append("<img src='images/exclamation_yellow.gif' />"); break;
            case PNBrokenRuleType.Info    : script.Append("<img src='images/info.gif'               />"); break;
            }
            script.Append("</td>");

            // Description
            script.Append("<td>");
            script.Append(rule.Description.Replace("[cr]", "<br />"));
            script.Append("</td>");

            // Explanation
            script.Append("<td>");
            script.Append(rule.Explanation.Replace("[cr]", "<br />"));
            script.Append("</td>");

            script.Append("</tr>");
        }
        script.Append("</table><br />");
    
        if (!string.IsNullOrEmpty(caption))
            script.AppendFormat("<p>{0}</p></div>", caption);

        // If close event is empty (add preventing bubbling up of escape) TFS31032  2Apr12  XN 
        if (string.IsNullOrEmpty(closeEvent))
            closeEvent = "function(event, ui) { window.event.cancelBubble = true; window.event.returnValue = false; $('#PNGrid').focus(); }";

        script.Append("\").dialog({");
        script.Append(      "modal: true, ");
        script.Append(      "resizable: false, ");
        script.Append(      "width: " + (brokenRules.Any() ? "600" : "300") + ",");
        script.Append(      "maxHeight: 700, ");
        script.Append(      "title: '" + title + "', ");
        script.Append(      "appendTo: 'form', ");
        script.Append(      "focus: function(type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(" + defaultButton.ToString() + ")').focus(); }, ");
        script.Append(      "close: " + closeEvent + ",");
        script.Append(      "buttons: " + buttons + ",");
        script.Append(      "draggable: false,");
        script.Append(      "zIndex: 9009");
        script.Append("}); }, 50);");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "BrokenRules", script.ToString(), true);  // TFS29359 XN 16Mar12 - changed from RegisterClientScriptBlock to RegisterStartupScript so always displays at startup
    }

    /// <summary>Displays the Na and K adjustment message box</summary>
    private void DisplayAdjustLevelMsgBox()
    {
        string buttons, openExtraLines;
        if (msgBoxAskAdjustIng.AnyIngredientsToAdjust)
        {
            buttons        = "[{ text: 'OK',     click: function() { $(this).dialog('close'); __doPostBack('upAskAdjustMsgBox', 'PerformAdjust:SuppressClearEditFlags'); } }, " +
                             " { text: 'Cancel', click: function() { $(this).dialog('close'); } } ]";
            openExtraLines = "var buttons = $('.ui-dialog-buttonpane button', $(this).parent());" +
                             "buttons.eq(1).css({ width: '85px' });" +    // Expand cancel button
                             "setTimeout(function() { $('.ui-dialog-buttonpane button:eq(0)').focus(); }, 250);";
        }
        else
        {
            buttons        = "[{ text: 'OK', click: function() { $(this).dialog('close'); } } ]";
            openExtraLines = string.Empty;
        }
        DisplayMsgBox("Adjust levels", "#askAdjustMsgBox", buttons, 0, 500, openExtraLines);
        upAskAdjustMsgBox.Update();
    }

    /// <summary>Displays the jquery dialogue</summary>
    /// <param name="title">Message box title</param>
    /// <param name="message">Message to display (can be a #{element id}, or {div}Hello there{/div}</param>
    /// <param name="buttons">jquery ui button property e.g. "[{ text: 'OK', click: function() { $(this).dialog('close'); } }]"</param>
    /// <param name="defaultButton">Index of default button</param>
    /// <param name="width">Optional width to display for the message box</param>
    private void DisplayMsgBox(string title, string message, string buttons, int defaultButton, int? width)
    {
        DisplayMsgBox(title, message, buttons, defaultButton, width, string.Empty);
    }
    private void DisplayMsgBox(string title, string message, string buttons, int defaultButton, int? width, string openExtraLines)
    {
        StringBuilder script = new StringBuilder();
        script.Append("$('" + message + "').dialog({");
        script.Append(      "modal: true, ");
        script.Append(      "resizable: false, ");
        if (width.HasValue)
            script.Append(  "width: " + width.ToString() + ", ");
        script.Append(      "maxHeight: 700, ");
        script.Append(      "title: '" + title + "', ");
        script.Append(      "appendTo: 'form', ");
        script.Append(      "focus: function(type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(" + defaultButton.ToString() + ")').focus(); }, ");
        script.Append(      "open: function(type, data) { ");
        script.Append(openExtraLines);
        script.Append(          "},");
        script.Append(      "buttons: " + buttons + ",");
        script.Append(      "close: function(type, data) { window.event.cancelBubble = true; window.event.returnValue = false; $('#PNGrid').focus(); },");    // TFS31032  2Apr12  XN If escape pressed prevent it trying to close the view and adjust from
        script.Append(      "zIndex: 9009");
        script.Append("});");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "AskAdjustMsg", script.ToString(), true); // TFS29359 XN 16Mar12 - changed from RegisterClientScriptBlock to RegisterStartupScript so always displays at startup
    }
    #endregion
}
