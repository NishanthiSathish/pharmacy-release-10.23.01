//==============================================================================================
//
//							    QuesScrl.ascx.cs
//
//  QuesScrl takes settings from WConfigruation to define a configurable user input form.
//  The control can be used for single or multiple sites.
//
//  The control can support data that user pharmacy Opermistic or Pessimistic locking (ie display correct error message if method asserts)
//
//  The parts that make up QuesScrl are defined into two types
//  View Data       - How the form is to be configured (info held in WConfiguration)
//  Editable Data   - The actual data the user is trying to edit like WSupplier information.
//
//  View Data
//  ---------
//  There are a number of WConfiguration settings. All settings require the same Category
//
//  The settings includes a view setup as follows
//      Section: Normaly set to Views
//      Key:     index number
//      Value: {view description},{data index 1},{data index 2},{data index 3},...
//  were if data index is -ve the control is read-only, index of 0 is a spacer row.
//
//  Each data item is setup as follows
//      Section: Normaly set to Data
//      Key: data index
//      Value: {help id},{max char length},{control type},{Description},{info},{mask or default Value},{mask},{tooltip},{If lookup only},{Force Mandatory}
//  Control type is
//      -1 - text box upper case only
//       0 - text box any char
//       1 - text box digits only     
//       2 - Y\N option (checkbox)
//       3 - text box digits and decimal only     
//       4 - text box digits and -/+ only     
//       5 - text box digits decimal and -/+ only 
//       8 - Uses pattern mask (validation done server side)
//       9 - Single char code mask gives valid characters
//      15 - Checkbox
//      20 - Date picker
//      200- Button
//  If lookup Only is if the control value must be set by a lookup
//  If Force Mandatory is false then field may still be hardcode to mandatory.
//
//  View data is read by QSView (using the Load method). 
//  Each index in the view is stored as a QSDataInputItem in QSView.
//  QSDataInputItem contains the data configuration info, plus creates and holds the input web control 
//  with one control for each site in QuesScrl.
//
//  Editable Data
//  -------------
//  Requires deriving a class from QSBaseProcessor that will map the data indexes to table fields
//  This will require overriding the following methods in QSBaseProcessor
//  PopulateForEditor       - maps each data index to a table row value
//  Validate                - validates the current QuesScrl value of each data index (returns errors as QSValidationList)
//  Update                  - Updates BaseTabe with the QuesScrl values (but does not save to db).
//  GetDifferences          - Returns differences between table row and QuesScrl values (returns difference as QSDifferenceList).
//  GetRequiredDataIndexes  - Returns data indexes that are madatory that user filles (so QuesScrl can indicate to user).
//  SetLookupItem           - Updates QSDataInputItem with the URL of the lookup form.
//  (see WProductQSProcessor for example of how to implement)
//
//  Usage:
//  in your html add
//  <%@ Register src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx" tagname="QuesScrl" tagprefix="uc" %>
//  :
//  <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
//  <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css"             rel="stylesheet" type="text/css" />
//  :
//  <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"             ></script>
//  <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"        ></script>
//  <script type="text/javascript" src="../sharedscripts/icwcombined.js"                      ></script>    /* only needed for URLEscape */
//  :
//  <uc:QuesScrl ID="editorControl" runat="server" ShowHeaderRow="true" OnValidated="editorControl_OnValidated" OnSaved="editorControl_OnSaved" />
//
//
//  Initalise the control (for displaying supplier profile editro)
//  WSupplierProfile supplierProfile = new WSupplierProfile();
//  supplierProfile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, "SUPP1", "FGE342D");
//
//  WSupplierProfileQSProcessor processor = new WSupplierProfileQSProcessor(supplierProfile, new [] { SessionInfo.SiteID });
//
//  editorControl.Initalise(processor, "D|SUPPROF", "Views", "Data", 1, false);
//
//
//  To save the changes first call
//  editorControl.Validation();
//
//  Next when control validates succesfully it will fire event Validated
//  Use this to save.
//  editorControl_OnValidated()
//  {
//      editorControl.Save();
//  }
//
//  When the control has saved data it will fire event OnSaved
//  editorControl_OnSaved()
//  {
//      ScriptManager.RegisterStartupScript(this, this.GetType(), "alert('Saved');", true);
//  }
//    
//	Modification History:
//	23Jan14 XN  Written
//  16Jun14 XN  Updates to Validate, and DisplayDifferences, for QS ToHTML 88509
//  02Oct14 XN  Fixed client side issue with GPEcontainer undefiend 
//  17Nov14 XN  Added support for custom headers via CreatedHeaderEventHandler
//  19Nov14 XN  104568 Alow to show more the 14 sites import from and to panels
//  02Mar16 XN  99381 added simple edit mode
//  22Mar16 XN  99381 prevent selection of full text in simple edit mode
//  21Jul16 XN  126641 allowed warnings box to be dynamically resized 
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using _Shared;
using System.Data;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;

public partial class QuesScrl : System.Web.UI.UserControl, ascribe.pharmacy.quesscrllayer.IQSViewControl
{
    #region Private Variables
    /// <summary>Current view information</summary>
    private QSView qsView = new QSView();
    
    /// <summary>Use QSProcessor to get the processor</summary>
    private QSBaseProcessor qsprocessor;
    #endregion

    #region Public Properties
    /// <summary>If to display the site detailsheader row</summary>
    public bool ShowHeaderRow 
    { 
        get { return hfShowHeaderRow.Value == "1";             }
        set { hfShowHeaderRow.Value = value.ToOneZeorString(); }
    }

    /// <summary>Overrides the settings for the view to force the data item to be readonly (cached on page)</summary>
    public int[] ForceReadOnly
    {
        get 
        { 
            int[] val = JsonConvert.DeserializeObject<int[]>(hfForceReadOnlyPerSite.Value);
            if (val == null)
                val = new int[0];
            return val; 
        }
        set { hfForceReadOnlyPerSite.Value = JsonConvert.SerializeObject(value);  }
    }

    /// <summary>Access to the QSView data</summary>
    public QSView QSView { get { return qsView; } }
    
    /// <summary>Gets access to the QSProcessor (cached on page)</summary>
    public QSBaseProcessor QSProcessor
    {
        get 
        { 
            if (qsprocessor == null)
                qsprocessor = QSBaseProcessor.Create(hfQSProcessor.Value);
            return qsprocessor;  
        }
        private set 
        { 
            qsprocessor = value;
            hfQSProcessor.Value = qsprocessor.WriteXml();
        }
    }
    #endregion

    #region Private Properties
    /// <summary>Index of the view support by the control (relates to a WConfiguration item view) (cached on page)</summary>
    private int KeyViewIndex
    {
        get { return int.Parse(hfKeyViewIndex.Value);  }
        set { hfKeyViewIndex.Value = value.ToString(); }
    }

    /// <summary>WConfiguration category for view (cached on page)</summary>
    private string Category
    { 
        get { return hfCategory.Value;  }
        set { hfCategory.Value = value; }
    } 

    /// <summary>WConfiguration section for view (cached on page)</summary>
    private string SectionView
    {
        get { return hfSectionView.Value;  }
        set { hfSectionView.Value = value; }
    }

    /// <summary>WConfiguration section for data (cached on page)</summary>
    private string SectionData
    {
        get { return hfSectionData.Value;  }
        set { hfSectionData.Value = value; }
    }

    /// <summary>Determines if differences msg box are shown on saving</summary>
    private bool AllowDisplayDifferences
    {
        get { return hfAllowDisplayDifferences.Value == "1";             }
        set { hfAllowDisplayDifferences.Value = value.ToOneZeorString(); }
    }

    private string SelectedCellID
    {
        get { return hfSelectedCellID.Value;    }
        set { hfSelectedCellID.Value = value;   }
    }
    #endregion

    #region IQSControl Implementation
        /// <summary>Validates the current values (validation success is reported by event Validated)</summary>
    public void Validate()
    {
        QSValidationList errors = QSProcessor.Validate(this.qsView);
        if (errors.Any())
        {
            bool onlyWarnings = errors.All(err => !err.error);
            if (onlyWarnings)
            {
                // Calculate the width of the dialog message 7px per char + 50px with total min of 300   21Jul16 XN  126641
                int width = Math.Max(50 + errors.GetLongestCharLength() * 7, 300); 

                // Only warnings display and ask user if they want to save (if they click yes does postback with arg DisplayDifference)
                string msg = "<div style='max-height:500px'>" + errors.ToHTML(Sites.GetDictonarySiteIDToNumber()) + "<br /><p>Do you still want to save changes?</p></div>";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("divGPE_onResize(); confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'ValidatedOK') }}, undefined, '{2}px' );", msg, upGPE.ClientID, width), true);
            }
            else
            {
                // error os display 
                string msg = "<div style='max-height:500px'>" + errors.ToHTML(Sites.GetDictonarySiteIDToNumber()) + "<br /><p>Updates were not saved</p></div>";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("alertEnh(\"{0}\");", msg), true);
            }
        }
        else
        {
            if (Validated != null)
                Validated();
        }
    }

    /// <summary>Event fired when data has been validated sucessfully</summary>
    public event ValidatedEventHandler Validated;
    
    /// <summary>Saves the current values in the web control to quesScrl (success is report by event Saved)</summary>
    public void Save()
    {
        if (this.AllowDisplayDifferences)
            this.DisplayDifferences();
        else
            this.SaveData();
    }
    
    /// <summary>Event fired when data has been saved to db</summary>
    public event SavedEventHandler Saved;

    /// <summary>Suppresses builing of the conrol</summary>
    public bool SuppressControlCreation { get; set; }
    #endregion

    #region Public Methods
    public void Initalise(QSBaseProcessor processor, string category, string sectionView, string sectionData, int keyViewIndex, bool allowDisplayDifferences, bool selectFirstCell = true)
    {
        // Cache important data on page
        this.Category               = category;
        this.SectionView            = sectionView;
        this.SectionData            = sectionData;
        this.KeyViewIndex           = keyViewIndex;
        this.QSProcessor            = processor;
        this.AllowDisplayDifferences= allowDisplayDifferences;

        // Create controls
        TemplateControl.Controls.Remove(tblGPE);    // 86273 XN 25Mar14 Clear view state
        CreateCtrls();

        // Populate Controls
        //foreach (int siteID in this.QSProcessor.SiteIDs)  86273 XN 20Mar14 No needed so is slowing things down
        //{
        processor.PopulateForEditor(this.qsView);
        processor.SetLookupItem    (this.qsView);
        //}
    
        // Get client to clear dirty flag, and select first cell
        ScriptManager.RegisterStartupScript(this, this.GetType(), "InitQuesScrl", "GPEUpdateLocalVariables();", true);
        if (selectFirstCell)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "selectFirstCell", "GPESelectCell($('tr:first td:eq(2)',GPEtable));", true);
    }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack)
        {
            // As the list of controls are dynamically created, need to rebuild when control created
            //if (tblGPE.Rows.Count == 0 && !this.SuppressControlCreation && !string.IsNullOrEmpty(hfKeyViewIndex.Value))  86273 XN 25Mar14 Always rebuild to prevent view state problems
            if (tblGPE.Rows.Count == 0 && !string.IsNullOrEmpty(hfKeyViewIndex.Value))
            {
                CreateCtrls();
                this.QSProcessor.SetLookupItem(this.qsView);    // 86273 XN 20Mar14 Need to update as lost as no view state (as causing issues when rebuilding controls)
            }

            //if (!string.IsNullOrEmpty(this.SelectedCellID))
            //{
            //    string script = string.Format("GPESelectCell($('#{0}').parent());", this.SelectedCellID);
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ReSelectCell", script, true);
            //}
        }
        else
            hfSimpleEditMode.Value = SettingsController.Load<bool>("Pharmacy", "QSEditor", "SimpleEditMode", false).ToString(); // 2Mar16 XN 99381 simple edit mode
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args) && target == upGPE.ClientID)
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "ValidatedOK": if (Validated != null) { Validated(); }; break;
        case "Save":        SaveData();                              break;
        }
    }

    /// <summary>
    /// Called when QS input button is clicked
    /// Will call QSProcessor.ButtonClickEvent
    /// </summary>
    public void inputControls_Click(object sender, EventArgs arg)
    {
        Button button = (Button)sender;
        int index = int.Parse(button.Attributes["Index" ]);
        int siteID= int.Parse(button.Attributes["SiteID"]);
        this.QSProcessor.ButtonClickEvent(this.qsView, index, siteID);
    }
    #endregion

    #region Events
    public event CreatedHeaderEventHandler CreatedHeader;
    #endregion

    #region Private Methods
    /// <summary>As controls on page are dynamic need to recreate them each time</summary>
    private void CreateCtrls()
    {
        int mainSiteID= SessionInfo.SiteID;
        var siteIDs   = this.QSProcessor.SiteIDs.ToList();
        int[] readOnlyStates = this.ForceReadOnly;
        bool simpleEditMode = this.hfSimpleEditMode.Value<bool>();  // 2Mar16 XN 99381 simple edit mode
        Unit smallWidth = new Unit(15, UnitType.Pixel);

        // Loads configuration, and builds controls
        qsView = new QSView();
        qsView.Load(this.Category, this.SectionView, this.SectionData, this.KeyViewIndex, siteIDs);

        HashSet<int> required = this.QSProcessor.GetRequiredDataIndexes(qsView);

        // Set readonly items
        foreach(QSDataInputItem item in this.qsView)
        {
            if (readOnlyStates != null && readOnlyStates.Contains(item.index))
            {
                foreach(int siteID in siteIDs)
                    item.GetBySiteID(siteID).Enabled = false;
            }
        }

        // Set click event
        qsView.SelectMany(v => v.inputControls).OfType<Button>().ToList().ForEach(b => b.Click += inputControls_Click);

        // Remove any existing rows from the table
        while (tblGPE.Rows.Count > 0)
            tblGPE.Rows.RemoveAt(0);

        // Skip adding site control in header row if only 1 site
        if (this.ShowHeaderRow)
        {
            TableHeaderRow headerRow = new TableHeaderRow();
            headerRow.TableSection = TableRowSection.TableHeader;

            // Description column (not used in header)
            TableHeaderCell headerCell = new TableHeaderCell();
            headerCell.Text     = "&nbsp;";
            headerCell.CssClass = "labelCell fixedLeft";
            headerRow.Cells.Add(headerCell);

            // Mandatory column (not used in header)
            headerCell = new TableHeaderCell();
            headerCell.Text     = "&nbsp;";
            headerCell.CssClass = "labelCell fixedLeft Mandatroy";
            headerRow.Cells.Add(headerCell);

            // Add sites columns
            for (int s = 0; s < siteIDs.Count; s++)
            {
                headerCell = new TableHeaderCell();

                if (CreatedHeader == null)
                {
                    Panel panel = new Panel();
                    //panel.Style.Add(HtmlTextWriterStyle.Padding, "15px");

                    // Site colour control
                    SiteColourPanelControl colourControl = (this.LoadControl("../SiteColourPanelControl.ascx") as SiteColourPanelControl);
                    colourControl.SiteID = siteIDs[s];
                    panel.Controls.Add(colourControl);

                    // Site name control
                    SiteNamePanelControl siteNameControl = (this.LoadControl("../SiteNamePanelControl.ascx") as SiteNamePanelControl);
                    siteNameControl.SiteID = siteIDs[s];
                    siteNameControl.TextFormat = SiteNamePanelControl.TextFormatType.LocalHospitalName;
                    panel.Controls.Add(siteNameControl);

                    // Add panels to header
                    headerCell.Controls.Add(panel);
                    if (s == 0 && mainSiteID == siteIDs[s])
                        headerCell.CssClass = "fixedLeft";  // Fix site if first site column and it is the main site ID
                }
                else
                    CreatedHeader(headerCell, siteIDs[s]);

                headerRow.Cells.Add(headerCell);
            }
            tblGPE.Rows.Add(headerRow);
        }

        // Add rows to the table
        foreach(QSDataInputItem item in qsView)
        {
            TableRow row = new TableRow();
            row.TableSection = TableRowSection.TableBody;

            // Indicate if spacer row
            if (item.isSpacer)
                row.Attributes.Add("isSpacer", "isSpacer");

            // Add description column
            TableCell cell = new TableCell();
            cell.CssClass = "labelCell fixedLeft";
            cell.Text    = string.IsNullOrEmpty(item.description) ? "&nbsp;" : item.description;
            cell.ToolTip = item.index.ToString();
            if (!string.IsNullOrEmpty(item.infoText))
            {
                cell.Text += (item.description.Length + item.infoText.Length > 30) ? "<br />" : " - ";
                cell.Text += item.infoText;
            }
            row.Cells.Add(cell);

            // Add Mandatroy column
            cell = new TableCell();
            cell.CssClass = "labelCell fixedLeft Mandatroy";
            if (required.Contains(item.index))
            {
                cell.Text    = "*";
                cell.ToolTip = "Mandatroy field"; 
            }
            else
                cell.Text = "&nbsp;";
            row.Cells.Add(cell);

            // Add sites columns
            for (int s = 0; s < siteIDs.Count; s++)
            {
                // Create cell and add control to it
                TableCell cellSite = new TableCell();
                if (s == 0 && mainSiteID == siteIDs[s])
                    cellSite.CssClass = "fixedLeft";    // Fix site if first site column and it is the main site ID
                row.Cells.Add(cellSite);

                // 2Mar16 XN 99381 simple edit mode
                if (simpleEditMode && item.IsLookupOnly && item.Enabled)
                {
                    Image img = new Image();
                    img.ImageUrl = "display_list_button.gif";
                    img.Attributes.Add("onclick", "DoLookup(this.parentNode.childNodes[1]);");
                    img.AlternateText = "Select value";
                    img.Width = smallWidth;
                    img.Height= smallWidth;
                    cellSite.Controls.Add(img);
                }

                WebControl webControl = item.GetBySiteID(siteIDs[s]);
                cellSite.Controls.Add(webControl);

                // Add click event handels to control (only if not spacer)
                if (!item.isSpacer)
                {
                    //cellSite.Attributes.Add("onclick",    "GPEControl_onclick(this.childNodes[0]);");     3Mar16 XN 99381 simple edit mode
                    //cellSite.Attributes.Add("ondblclick", "GPEControl_onclick(this.childNodes[0]);");     3Mar16 XN 99381 simple edit mode
                    cellSite.Attributes.Add("onmousedown", string.Format("GPEControl_onmousedown(this.childNodes[{0}]);", cellSite.Controls.Count - 1));

                    //webControl.Attributes.Add("onclick",    "GPEControl_onclick(this);"     );    3Mar16 XN 99381 simple edit mode
                    //webControl.Attributes.Add("ondblclick", "GPEControl_ondblclick(this);"  );    3Mar16 XN 99381 simple edit mode
                    //webControl.Attributes.Add("readonly", "readonly");                            3Mar16 XN 99381 simple edit mode
                    webControl.Attributes.Add("onmousedown", "GPEControl_onmousedown(this);" );
                    //webControl.Attributes.Add("onfocus",     simpleEditMode ? "moveCaretToEnd(this);" : "this.select();");
                    webControl.Attributes.Add("onfocus",     "this.select();");
                    
                    if (!simpleEditMode || item.IsLookupOnly)
                        webControl.Attributes.Add("readonly", "readonly");
                }

                // 2Mar16 XN 99381 simple edit mode
                if (!item.Enabled)
                    cellSite.CssClass = "DisabledCell";

                // Remove boarder so correct style
                if (webControl is TextBox)
                    webControl.BorderStyle = BorderStyle.None;
            }
            tblGPE.Rows.Add(row);
        }
    }

    /// <summary>Displays differences</summary>
    private void DisplayDifferences()
    {
        // If difference then display
        // After use clicks yes to the message will post back to Save (which is caught in Page_PreRender which does the actual save)
        QSDifferencesList differences = QSProcessor.GetDifferences(this.QSView);
        if (differences.Any())
        {
            string msg = string.Format("<div style='max-height:600px;overflow-y:scroll;overflow-x:hidden;'>{0}</div><br /><p>OK to save the changes?</p>", differences.ToHTML( Sites.GetDictonarySiteIDToNumber() ));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, upGPE.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
        else if (Saved != null)
            Saved();    // 18Sep14 XN if nothing to save then send out event so dirty flag gets cleared
    }        
    
    /// <summary>Saves data and sends out save event</summary>
    private void SaveData()
    {
        try
        {
            QSProcessor.Save(this.qsView, true);
            if (Saved != null)
                Saved();
        }
        catch (DBConcurrencyException)
        {
            string script = "alertEnh('Your changes cannot be saved, as the record has been updated by another user.<br /><br />Refresh the view, reapply your changes, and try again.')";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
        catch (LockException ex)
        {
            string script = string.Format("alertEnh('Records in use by user \"{0}\" (EntityID: {1}).<br />Please try again in a few minutes?')", ex.GetLockerUsername(), ex.GetLockerEntityID());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
    }
    #endregion
}
