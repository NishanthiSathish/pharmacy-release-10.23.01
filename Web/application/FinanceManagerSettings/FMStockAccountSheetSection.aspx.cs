//===========================================================================
//
//						     FMStockAccountSheetSection.aspx.cs
//
//  Displays editor for main section of the balance sheet.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  Mode                - add\edit mode
//  RecordID            - record being editr
//  RecordID_insertAfter- Record after which new record should be added
//
//  Usage:
//  FMStockAccountSheetLayoutEditor.aspx?SessionID=123&Mode=add&RecordID_insertAfter=144
//
//	Modification History:
//  30Apr13 XN  Created 27038
//  07Jan14 XN  HTML Escape data returned from page 81147
//===========================================================================
using System;
using System.Drawing;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;

public partial class application_FinanceManagerSettings_FMStockAccountSheetSection : System.Web.UI.Page
{
    int  sessionID;
    int  recordID;
    int  recordID_insertAfter;
    bool addMode;

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        addMode   = Request["Mode"].EqualsNoCaseTrimEnd("add");

        if (!int.TryParse(Request["RecordID"], out recordID))
            recordID = -1;
        if (!int.TryParse(Request["RecordID_insertAfter"], out recordID_insertAfter))
            recordID_insertAfter = -1;

        Initalise();
        if (!this.IsPostBack)
        { 
            WFMStockAccountSheetLayout StockAccountSheetLayout = new WFMStockAccountSheetLayout();
            if (addMode)
                Populate(StockAccountSheetLayout.Add(null, WFMStockAccountSheetSectionType.MainSection));
            else
            {
                StockAccountSheetLayout.LoadByID(recordID);
                Populate(StockAccountSheetLayout[0]);
            }
        }
    }

    /// <summary>
    /// Called when okay button is clicked, 
    /// 1. validates
    /// 2. saves
    /// 3. closes form
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            Save();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue={0}; window.close();", recordID), true);
        }
    }

    /// <summary>Delete section (and sub sections)</summary>
    [WebMethod]
    public static void Delete(int sessionID, int recordID)
    {
        SessionInfo.InitialiseSession(sessionID);

        WFMStockAccountSheetLayout StockAccountSheetLayout = new WFMStockAccountSheetLayout();
        StockAccountSheetLayout.LoadAll();
        StockAccountSheetLayout.RemoveAll(StockAccountSheetLayout.Where(i => i.WFMStockAccountSheetLayoutID_Parent == recordID).ToList());
        StockAccountSheetLayout.RemoveAll(StockAccountSheetLayout.Where(i => i.WFMStockAccountSheetLayoutID == recordID).ToList());
        StockAccountSheetLayout.Save();
    }

    /// <summary>
    /// Initalise the form (normaly for non view state data)
    /// </summary>
    private void Initalise()
    {
        // Clear error messages
        this.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<Ascribe.Core.Controls.ControlBase>().ToList().ForEach(c => c.ErrorMessage = string.Empty);

        // Set client side event handlers
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");

        // Set Max Chars
        tbSectionDescription.MaxCharacters = WFMStockAccountSheetLayout.GetColumnInfo().DescriptionLength;
    }

    /// <summary>Populate form with value from record</summary>
    /// <param name="recordID">Record to eidt</param>
    private void Populate(WFMStockAccountSheetLayoutRow row)
    {
        // Setup values
        tbSectionDescription.Value           = row.Description;
        backgroundColorPicker.SelectedColor  = row.BackgroundColour ?? Color.Empty;
        textColorPicker.SelectedColor        = row.TextColour       ?? Color.Empty;
    }

    /// <summary>Validate data on form</summary>
    private bool Validate()
    {
        string error;
        bool ok = true;

        if (!Validation.ValidateText(tbSectionDescription, "Description", typeof(string), true, out error))
        {
            tbSectionDescription.ErrorMessage = error;
            ok = false;
        }

        return ok;
    }

    /// <summary>Save data from from</summary>
    private void Save()
    {
        WFMStockAccountSheetLayout StockAccountSheetLayout = new WFMStockAccountSheetLayout();
        WFMStockAccountSheetLayoutRow item;
        if (addMode)
        {
            // Load all record, and update sort index (so can place new row in correct place)
            StockAccountSheetLayout.LoadAll();
            if (recordID_insertAfter < 0)
                recordID_insertAfter = StockAccountSheetLayout.FindFirstRowBeforeCalculatedClosingBalance().WFMStockAccountSheetLayoutID;

            WFMStockAccountSheetLayoutRow row_insertAfter = StockAccountSheetLayout.First(l => l.WFMStockAccountSheetLayoutID == recordID_insertAfter);
            item = StockAccountSheetLayout.Add(row_insertAfter, WFMStockAccountSheetSectionType.MainSection);
        }
        else
        {
            // Load row to update
            StockAccountSheetLayout.LoadByID(recordID);
            item = StockAccountSheetLayout[0];
        }

        // Update data
        item.Description = tbSectionDescription.Value.XMLUnescape();
        if (backgroundColorPicker.SelectedColor.IsEmpty)
            item.BackgroundColour = null;
        else
            item.BackgroundColour = Color.FromArgb(0, backgroundColorPicker.SelectedColor.R, backgroundColorPicker.SelectedColor.G, backgroundColorPicker.SelectedColor.B);
        if (textColorPicker.SelectedColor.IsEmpty)
            item.TextColour = null;
        else
            item.TextColour = Color.FromArgb(0, textColorPicker.SelectedColor.R, textColorPicker.SelectedColor.G, textColorPicker.SelectedColor.B);        

        // Save
        StockAccountSheetLayout.Save();
    }
}
