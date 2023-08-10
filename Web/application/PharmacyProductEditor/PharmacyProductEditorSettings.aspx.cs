//==============================================================================================
//
//      					        PharmacyProductEditorSettings.aspx.cs
//
//  Allows editing of the Pharmacy Product Editor desktop layout
//
//  Currently only supports
//      Editing of views displayed in the desktop - This is loaded and saved to the WindowParameter (name = ViewIndexToDisplay)
//      
//
//	Modification History:
//	03Mar14 XN  Written
//==============================================================================================
using System;
using System.Linq;
using System.Web.UI.WebControls;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_PharmacyProductEditor_PharmacyProductEditorSettings : System.Web.UI.Page
{
    /// <summary>List of views on the pharamcy product editor desktop (read from URL parameter)</summary>
    protected string viewIndexesToDisplayStr;

    /// <summary>Pharmacy product editor window id</summary>
    protected int windowID;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        viewIndexesToDisplayStr = Request["ViewIndexToDisplay"] ?? "All";
        windowID                = int.Parse(Request["WindowID"]);
        if (!this.IsPostBack)
        {
            PopulateDesktop();

            tabButtons.SelectedIndex = 0;
            mvViews.SetActiveView(vDesktop);
        }
    }

    /// <summary>
    /// Called when Use All Views button is clicked on the Desktop tab
    /// Reset the form to hide select views (and display all views) list box
    /// hides avaible views, and buttons
    /// </summary>
    protected void cbDesktopUseAllViews_OnCheckedChanged(object sender, EventArgs e)
    {
        lbDesktopAllViews.Visible      = cbDesktopUseAllViews.Checked;
        lbDesktopSelectedViews.Visible = !cbDesktopUseAllViews.Checked;
        btnDesktopAdd.Visible          = !cbDesktopUseAllViews.Checked;
        btnDesktopDown.Visible         = !cbDesktopUseAllViews.Checked;
        btnDesktopRemove.Visible       = !cbDesktopUseAllViews.Checked;
        btnDesktopUp.Visible           = !cbDesktopUseAllViews.Checked;
        lbDesktopAvaliableViews.Visible= !cbDesktopUseAllViews.Checked;
    }

    /// <summary>Called when add button is clicked in Desktop tab (moves items from avaialbe to selected listbox)</summary>
    protected void btnDesktopAdd_OnClick(object sender, EventArgs e)
    {
        var selectedItems = lbDesktopAvaliableViews.Items.Cast<ListItem>().Where(l => l.Selected).ToArray();

        lbDesktopSelectedViews.Items.Cast<ListItem>().Where(l => l.Selected).ToList().ForEach(l => l.Selected = false);

        lbDesktopSelectedViews.Items.AddRange(selectedItems);
        foreach(var item in selectedItems)
            lbDesktopAvaliableViews.Items.Remove(item);
    }

    /// <summary>Called when remove button is clicked in Desktop tab (moves items from selected to avaialbe listbox)</summary>
    protected void btnDesktopRemove_OnClick(object sender, EventArgs e)
    {
        var selectedItems = lbDesktopSelectedViews.Items.Cast<ListItem>().Where(l => l.Selected).ToArray();

        lbDesktopAvaliableViews.Items.Cast<ListItem>().Where(l => l.Selected).ToList().ForEach(l => l.Selected = false);

        lbDesktopAvaliableViews.Items.AddRange(selectedItems);
        foreach(var item in selectedItems)
            lbDesktopSelectedViews.Items.Remove(item);
    }

    /// <summary>Called when up button is clicked in Desktop tab (moves selected item up the selected list)</summary>
    protected void btnDesktopUp_OnClick(object sender, EventArgs e)
    {
        var selectedItems = lbDesktopSelectedViews.Items.Cast<ListItem>().Where(l => l.Selected).ToArray();
        foreach(var i in selectedItems)
        {
            var pos = lbDesktopSelectedViews.Items.IndexOf(i);
            if (pos == 0)
                return;

            lbDesktopSelectedViews.Items.RemoveAt(pos);
            lbDesktopSelectedViews.Items.Insert(pos - 1, i);
        }
    }

    /// <summary>Called when down button is clicked in Desktop tab (moves selected item down the selected list)</summary>
    protected void btnDesktopDown_OnClick(object sender, EventArgs e)
    {
        var selectedItems = lbDesktopSelectedViews.Items.Cast<ListItem>().Where(l => l.Selected).ToArray();
        foreach(var i in selectedItems.Reverse())
        {
            var pos = lbDesktopSelectedViews.Items.IndexOf(i) + 1;
            if (pos == lbDesktopSelectedViews.Items.Count)
                return;

            lbDesktopSelectedViews.Items.RemoveAt(pos - 1);
            lbDesktopSelectedViews.Items.Insert(pos, i);
        }
    }

    /// <summary>Called when save button is clicked (validats and saved data)</summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        SaveDesktop();
    }

    /// <summary>Saves data in desktop tab</summary>
    private void SaveDesktop()
    {
        // load existing window parameter (else create)
        WindowParameter windowParameter = new WindowParameter();
        windowParameter.LoadByWindowIDAndDescription(windowID, "ViewIndexToDisplay");
        if (!windowParameter.Any())
        {
            WindowParameterRow row = windowParameter.Add();
            row.WindowID    = windowID;
            row.Description = "ViewIndexToDisplay";
        }

        // Set parameter value
        if (cbDesktopUseAllViews.Checked)
            windowParameter.First().Value = "All";
        else
            windowParameter.First().Value = lbDesktopSelectedViews.Items.Cast<ListItem>().Select(l => l.Value).ToCSVString(",");

        // Save
        windowParameter.Save();
    }

    /// <summary>Populate desktop tab</summary>
    private void PopulateDesktop()
    {
        // Set if Use All Views is checked
        cbDesktopUseAllViews.Checked = viewIndexesToDisplayStr.EqualsNoCase("All");

        // Populate selected views list
        var selectedViews = WProductQSProcessor.GetProductEditorViews(viewIndexesToDisplayStr.ParseCSV<int>(",", true));
        lbDesktopSelectedViews.Items.AddRange(selectedViews.Select(v => new ListItem(v.Value, v.Key.ToString())).ToArray());

        // Populate all views (displayed when Use All Views is checked)
        var allViews = WProductQSProcessor.GetProductEditorViews(true);
        lbDesktopAllViews.Items.AddRange(allViews.Select(v => new ListItem(v.Value, v.Key.ToString())).ToArray());

        // Populate avaiable views (remove currently selected items)
        var avaliableViews = WProductQSProcessor.GetProductEditorViews(false);
        foreach(var i in selectedViews)
            avaliableViews.Remove(i.Key);
        lbDesktopAvaliableViews.Items.AddRange(avaliableViews.OrderBy(v => v.Value).Select(v => new ListItem(v.Value, v.Key.ToString())).ToArray());

        // Update state of listboxes
        cbDesktopUseAllViews_OnCheckedChanged(this, null);
    }
}