using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Globalization;
using _Shared;
using System.Data;
using System.Text;
using ascribe.pharmacy.basedatalayer;

public partial class application_PNSettings_DssCustomisation : System.Web.UI.Page
{
    #region Constants
    /// <summary>Format for pharmacy date to long time string convert</summary>
    static readonly string LastModDateTimePattern = "dd/MM/yyyy HH:mm:ss.fff";
    #endregion

    private PNDssCustomisation customisation = new PNDssCustomisation();
    private int    tableID;
    private string parameterName;
    private int?   pnProductID;
    private int?   pnRuleID;

    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        parameterName = Request["ParameterName"];

        if (!string.IsNullOrEmpty(Request["PNProductID"]))
        {
            pnProductID = int.Parse(Request["PNProductID"]);
            PNProduct product = new PNProduct();            
            tableID = product.GetTableID();

            customisation.LoadByTableIDPNProductIDAndParameterName(tableID, pnProductID.Value, parameterName, false);
        }
        if (!string.IsNullOrEmpty(Request["RuleID"]))
        {
            pnRuleID = int.Parse(Request["RuleID"]);
            PNRule rule = new PNRule();            
            tableID = rule.GetTableID();

            customisation.LoadByTableIDPNRuleIDAndParameterName(tableID, pnRuleID.Value, parameterName, false);
        }

        if (pnProductID.HasValue && pnRuleID.HasValue)
            throw new ApplicationException("Can only set PNProductID or PNRuleID (in query string) but not both at the same time.");
        if (!pnProductID.HasValue && !pnRuleID.HasValue)
            throw new ApplicationException("Need to set PNProductID or PNRuleID (in query string).");

        lbPrompt.Text = "Enter the custom " + parameterName.ToLower() + " information";

        // As form is generate dynamicall need to do this everytime form is loaded else will be lost
        CreateTable();
    }

    protected void Save_Click(object sender, EventArgs e)
    {
        if (Validate())
        {
            if (Save())
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "window.close();", true);
        }
    }

    private void CreateTable()
    {
        Dictionary<Guid, string> customers = PNUtils.GetDSSCustomerList();
        StringBuilder initScript = new StringBuilder();

        if (!customers.Any())
            lbPrompt.Text = "No PN customer's setup in your Customer and Packages DB";

        foreach (KeyValuePair<Guid, string> customer in customers.OrderBy(c => c.Value))
        {
            TableRow row = new TableRow();
            TableCell cell;
            string idSuffix = customer.Key.ToString().Replace("-", string.Empty);
            PNDssCustomisationRow customValue = customisation.FindByCustomerID(customer.Key).FirstOrDefault();

            // Customer code
            HiddenField hfCustomerID = new HiddenField();
            hfCustomerID.ID = "hfID" + idSuffix;
            hfCustomerID.Value = customer.Key.ToString();
            cell = new TableCell();
            cell.Controls.Add(hfCustomerID);
            row.Cells.Add(cell);

            // Customer Name
            cell = new TableCell();
            cell.Text = customer.Value;
            row.Cells.Add(cell);

            // Check box
            CheckBox cb = new CheckBox();
            cb.ID = "cb" + idSuffix;
            cb.Checked = (customValue != null);
            cb.Attributes.Add("onclick", string.Format("checkbox_onclick('cb{0}', 'tb{0}');", idSuffix));
            cell = new TableCell();
            cell.Controls.Add(cb);
            row.Cells.Add(cell);

            // Value (initalise enabling\disabling of value just before post back as depends on existing form values)
            TextBox tbValue = new TextBox();
            tbValue.ID   = "tb" + idSuffix;
            tbValue.Text = (customValue == null) ? string.Empty : customValue.Value;
            tbValue.Width= Unit.Pixel(250);
            cell = new TableCell();
            cell.Controls.Add(tbValue);
            row.Cells.Add(cell);

            // Add error row
            Label errorLabel = new Label();
            errorLabel.CssClass = "ErrorMessage";
            errorLabel.ID = "lb" + idSuffix;
            errorLabel.Text = "&nbsp;";
            cell = new TableCell();
            cell.Controls.Add(errorLabel);
            row.Cells.Add(cell);

            table.Rows.Add(row);

            // Add initalise of value textbox client side as if doing a postback the code above will 
            // only hold the correct state of the CheckBox yet as it's view state has not been updated
            initScript.AppendFormat("checkbox_onclick('cb{0}', 'tb{0}');", idSuffix);
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "initaliseControls", initScript.ToString(), true);
    }

    private bool Validate()
    {
        PNProductColumnInfo columnInfoProduct = PNProduct.GetColumnInfo();
        PNRuleColumnInfo    columnInfoRule    = PNRule.GetColumnInfo();
        bool valid = true;

        foreach (TableRow row in table.Rows)
        {
            Guid customerID         = new Guid ((row.Cells[0].Controls[0] as HiddenField).Value);
            bool hasCustomValue     = (row.Cells[2].Controls[0] as CheckBox).Checked;
            TextBox value           =  row.Cells[3].Controls[0] as TextBox;
            Label errorLabel        =  row.Cells[4].Controls[0] as Label;
            PNDssCustomisationRow customValue = customisation.FindByCustomerID(customerID).FirstOrDefault();

            if (hasCustomValue && ((customValue == null) || (customValue.Value != value.Text)))
            {
                if (pnProductID.HasValue)
                {
                    string paramName = parameterName;
                    if (PNIngredient.GetInstance().FindByDBName(parameterName) != null) // if parameter is an ingredient the validation use a generic ingredient tag
                        paramName = "ingredient";
                    valid &= PNSettingsProcessor.RangeValidationPNProduct(columnInfoProduct, value, errorLabel, paramName, string.Empty);
                }
                else
                    valid &= PNSettingsProcessor.RangeValidationPNRule(columnInfoRule, value, errorLabel, parameterName, RuleType.RegimenValidation);
            }
        }

        return valid;
    }

    private bool Save()
    {
        DateTime now = DateTime.Now;
        PNDssCustomisationColumnInfo columnInfo = PNDssCustomisation.GetColumnInfo();
        bool changesToSave = false;
        bool ok = false;

        // Reload the customation (just incase a deleted one exists in the list list in which case update that rather than create a new one)
        if (pnProductID.HasValue)
            customisation.LoadByTableIDPNProductIDAndParameterName(tableID, pnProductID.Value, parameterName, true);
        else
            customisation.LoadByTableIDPNRuleIDAndParameterName(tableID, pnRuleID.Value, parameterName, true);

        PNDssCustomisation copyOfCustomisation = new PNDssCustomisation();
        copyOfCustomisation.CopyFrom(customisation);

        foreach (TableRow row in table.Rows)
        {
            Guid customerID         = new Guid ((row.Cells[0].Controls[0] as HiddenField).Value);
            bool hasCustomValue     = (row.Cells[2].Controls[0] as CheckBox).Checked;
            PNDssCustomisationRow customValue = customisation.FindByCustomerID(customerID).FirstOrDefault();

            if (hasCustomValue)
            {
                string   newValue = (row.Cells[3].Controls[0] as TextBox).Text;
                bool     update   = false;

                // Determine if the value needs to be updates
                if (customValue == null)
                {
                    customValue = customisation.Add();
                    customValue.CustomerID = customerID;
                    customValue.ParameterName = this.parameterName;
                    customValue.TableID = this.tableID;
                    customValue.PNProductID = pnProductID;
                    customValue.PNRuleID    = pnRuleID;
                    update = true;
                }
                else if (customValue.Value != newValue)
                    update = true;

                // Update the value if needed
                if (update)
                {
                    customValue.LastModDate = now;
                    customValue.LastModTerm = SessionInfo.Terminal.SafeSubstring    (0, columnInfo.LastModTermLength);
                    customValue.LastModUser = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.LastModUserLength);
                    customValue.Value = newValue;
                    customValue._Deleted = false;
                    changesToSave = true;
                }
            }
            else
            {
                // Remove the value is exists and opted for no customisation (logically delete it)
                if (customValue != null)
                {
                    //customisation.Remove(customValue);
                    customValue._Deleted = true;    // TFS32067 15May12 XN
                    changesToSave = true;
                }
            }
        }


        // Save
        try
        {
            if (changesToSave)
            {
                // Create log
                StringBuilder log = new StringBuilder("Following changes have been made to PNDssCustomisation table");
                PNLog.CompareDataRows(log, customisation.Select(r => r.RawRow), copyOfCustomisation.Select(r => r.RawRow));

                // Save Data
                using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
                {
                    customisation.Save();
                    PNLog.WriteToLog(0, null, null, pnProductID, pnRuleID, null, log.ToString(), string.Empty);
                    trans.Commit();
                }
            }

            ok = true;
        }
        catch (DBConcurrencyException)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "EditByAnotherUser", "alert('Item has been recently modified, and can't be saved. Refresh list and try again.');", true);
        }

        return ok;
    }
}
