//===========================================================================
//
//						   FMBalanceSheetSubSection.aspx.cs
//
//  Allows user to add, edit, or delete an finance manager balance sheet account section.
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  Mode                - 'add' or 'edit'
//  RecordID            - Id of record if in edit mode
//  RecordID_parent     - Id of the parent record (account sections add mode only)
//  RecordID_insertAfter- Id of record after which new record should be added (account sections add mode only)
//
//  As it is possible to link multiple rules to a sub section, these are displayed 
//  in a pharmacy grid on the from. As the grid does not support view state there 
//  are hfGridRules, and hfSelectedRowIndex, hidden fields.
//       hfGridRules is an xml version of WFMBalanceSheetLinkRule
//       hfSelectedRowIndex holds the selected row index
//
//  Usage:
//  To add
//  FMRule.aspx?SessionID=123&Mode=add&RecordID_parent=5&RecordID_insertAfter=6
//
//  To edit
//  FMRule.aspx?SessionID=123&Mode=edit&RecordID=4
//
//	Modification History:
//	30Apr13 XN  Written 27038
//  07Jan14 XN  HTML Escape data returned from page 81147
//===========================================================================
using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;
using _Shared;
using System.Collections.Generic;

public partial class application_FinanceManagerSettings_FMBalanceSheetSubSection : System.Web.UI.Page
{
    int  sessionID;
    int  recordID;
    int  recordID_parent;
    int  recordID_insertAfter;
    bool addMode;

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        addMode = Request["Mode"].EqualsNoCaseTrimEnd("add");

        if (!int.TryParse(Request["RecordID"], out recordID))
            recordID = -1;

        if (!int.TryParse(Request["RecordID_parent"], out recordID_parent))
            recordID_parent = -1;

        if (!int.TryParse(Request["RecordID_insertAfter"], out recordID_insertAfter))
            recordID_insertAfter = -1;

        Initalise();
        if (!this.IsPostBack)
        { 
            WFMStockAccountSheetLayout balanceSheetLayout = new WFMStockAccountSheetLayout();
            if (addMode)
                Populate(balanceSheetLayout.Add(null, WFMStockAccountSheetSectionType.AccountSection));
            else
            {
                balanceSheetLayout.LoadByID(recordID);
                Populate(balanceSheetLayout[0]);
            }
        }
    }

    /// <summary>
    /// Called when add buttom is clicked
    /// Will display the rule message box
    /// </summary>
    protected void btnAdd_OnClick(object sender, EventArgs e)
    {
        mbRule.Visible = true;
        lRules.SelectedIndex = -1;
    }

    /// <summary>
    /// Called when delete button is clicked
    /// Will delete the selected rule from the list
    /// </summary>
    protected void btnDelete_OnClick(object sender, EventArgs e)
    {
        // Check row is selected
        int rowIndex;
        if (string.IsNullOrEmpty(hfSelectedRowIndex.Value) || !int.TryParse(hfSelectedRowIndex.Value, out rowIndex))
        {
            gridRulesError.Text = "Select row form list";
            return;
        }

        // Load in the rules
        // Delete and refresh the list
        List<short> ruleNumbers = hfGridRules.Value.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => short.Parse(s)).ToList();
        ruleNumbers.RemoveAt(rowIndex);

        PopulateGrid(ruleNumbers);
    }

    /// <summary>Called when OK button is clicked in the rule message box</summary>
    protected void mbRuleOk_OnClick(object sender, Ascribe.Core.Controls.MessageBox.MessageBoxButtonClickEventArgs e)
    {
        string error;
        bool ok = true;

        // Load the cached rules
        List<short> ruleNumbers = hfGridRules.Value.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => short.Parse(s)).ToList();

        // Validate rule code
        if (!Validation.ValidateList(lRules, "Rule Code", true, out error))
        {
            lRules.ErrorMessage = error;
            ok = false;
        }

        // Check rule code is unique
        short selectedRuleNumber = short.Parse(lRules.SelectedValue); 
        if (ruleNumbers.Any(r => r == selectedRuleNumber))
        {
            lRules.ErrorMessage = "Rule has already been added";
            ok = false;
        }

        if (ok)
        {
            // Add rule
            ruleNumbers.Add(selectedRuleNumber);

            // Populate the grid
            PopulateGrid(ruleNumbers);
        }

        e.CloseMessageBox = ok;
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

    /// <summary>Method to delete record</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="recordID">Record to delete</param>
    [WebMethod]
    public static void Delete(int sessionID, int recordID)
    {
        SessionInfo.InitialiseSession(sessionID);

        WFMStockAccountSheetLayout balanceSheetLayout = new WFMStockAccountSheetLayout();
        balanceSheetLayout.LoadByID(recordID);
        balanceSheetLayout.RemoveAll();
        balanceSheetLayout.Save();
    }

    /// <summary>Initialise the control</summary>
    private void Initalise()
    {
        // Clear error messages
        this.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<Ascribe.Core.Controls.ControlBase>().ToList().ForEach(c => c.ErrorMessage = string.Empty);

        // Set max chars of text boxes
        WFMStockAccountSheetLayoutColumnInfo columnInfo = WFMStockAccountSheetLayout.GetColumnInfo();
        tbAccountDescription.MaxCharacters = columnInfo.DescriptionLength;

        // Set client side events
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");

        var ruleNumbers = hfGridRules.Value.Split(new char[]{ ',' }, StringSplitOptions.RemoveEmptyEntries).Select(s => short.Parse(s));
        PopulateGrid(ruleNumbers);

        if (!this.IsPostBack)
        {
            // Load rule codes
            WFMRule ruleCodes = new WFMRule();
            ruleCodes.LoadAll();
            lRules.Items.AddRange(ruleCodes.Select(r => new ListItem(r.ToString(), r.Code.ToString())).ToArray());
        }
    }

    /// <summary>Populate the grid with the rules</summary>
    private void PopulateGrid(IEnumerable<short> ruleNumbers)
    {
        // Set headers
        if (gridRules.RowCount == 0)
            gridRules.AddColumn("Code", 100, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Center);

        // Update grid
        gridRules.ClearRows();
        foreach(short r in ruleNumbers)
        {
            gridRules.AddRow();
            gridRules.SetCell(0, r.ToString());
        }

        // Cache the data
        hfGridRules.Value = ruleNumbers.ToCSVString(",");
    }

    /// <summary>Populate form data</summary>
    /// <param name="row">record</param>
    /// <param name="balanceSheetLinkRules">rule to update</param>
    private void Populate(WFMStockAccountSheetLayoutRow row)
    {
        // Populate the form
        tbAccountDescription.Value      = row.Description;
        PopulateGrid(row.RuleCodes);
    }

    /// <summary>Validates form</summary>
    private bool Validate()
    {
        WFMStockAccountSheetLayoutColumnInfo columnInfo = WFMStockAccountSheetLayout.GetColumnInfo();
        string error;
        bool ok = true;

        // Description
        if (!Validation.ValidateText(tbAccountDescription, "Description", typeof(string), true, columnInfo.DescriptionLength, out error))
        {
            tbAccountDescription.ErrorMessage = error;
            ok = false;
        }

        // Rule code
        if (gridRules.RowCount == 0)
        {
            gridRulesError.Text = "Enter at least one Rule Code";
            ok = false;
        }

        // Check rule code is not already in use 66961 24Jun13 XN
        WFMStockAccountSheetLayout stockAccountSheetLayout = new WFMStockAccountSheetLayout();
        string[] ruleCodes = hfGridRules.Value.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);
        foreach (string ruleCode in ruleCodes)
        {
            stockAccountSheetLayout.LoadByRuleCode(ruleCode);

            WFMStockAccountSheetLayoutRow differentRule = stockAccountSheetLayout.FirstOrDefault(s => s.WFMStockAccountSheetLayoutID != this.recordID);
            if (differentRule != null)
            {
                gridRulesError.Text = string.Format("Rule code {0} already in use by '{1}'", ruleCode, differentRule.Description);
                ok = false;
            }
        }

        return ok;
    }

    /// <summary>Save the data</summary>
    private void Save()
    {   
        WFMStockAccountSheetLayout balanceSheetLayout = new WFMStockAccountSheetLayout();
        WFMStockAccountSheetLayoutRow item;
        if (addMode)
        {
            // Load all rows (so can update sort index)
            balanceSheetLayout.LoadAll();

            // Insert (updates sort index of other rows)
            var row_InsertAfter = balanceSheetLayout.First(l => l.WFMStockAccountSheetLayoutID == recordID_insertAfter);
            item = balanceSheetLayout.Add(row_InsertAfter, WFMStockAccountSheetSectionType.AccountSection);

            // add new row
            item.WFMStockAccountSheetLayoutID_Parent = recordID_parent;
        }
        else
        {
            // Load row to edit
            balanceSheetLayout.LoadByID(recordID);
            item = balanceSheetLayout[0];
        }

        // Update data
        item.Description    = tbAccountDescription.Value.XMLUnescape();
        item.RuleCodes      = hfGridRules.Value.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries).Select(s => short.Parse(s));

        // Save
        balanceSheetLayout.Save();
    }
}
