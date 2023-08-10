//===========================================================================
//
//			        ICW_RepeatDispensingPatientHistroy.aspx.cs
//
//	Modification History:
//	12Apr12 AJK 31015 Created
//===========================================================================
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using Telerik.Web.UI;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

public partial class application_RepeatDispensingPatientHistory_RepeatDispensingPatientHistory : System.Web.UI.Page
{
    int _entityID = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Get session and entity information
        int sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);
        GENRTL10.StateRead state = new GENRTL10.StateRead();
        _entityID = state.GetKey(sessionID, "Entity");
        if (!this.IsPostBack)
        {
            PopulateGrid();
        }
    }

    /// <summary>
    /// Populates the grid with all batches for the patient
    /// </summary>
    protected void PopulateGrid()
    {
        GenericTable batches = new GenericTable("Batches", "RepeatDispensingBatchID"); 
        batches.LoadBySP("pRepeatDispensingBatchInfoByEntityID", "EntityID", _entityID);
        RadGrid1.DataSource = batches.Table.DefaultView;
        RadGrid1.DataBind();
    }

    ///// <summary>
    ///// Binds the detail table with dispensing information from the parent batch row
    ///// </summary>
    ///// <param name="sender">Control calling the method</param>
    ///// <param name="e">Event arguements</param>
    //protected void RadGrid1_DetailTableDataBind(object sender, Telerik.Web.UI.GridDetailTableDataBindEventArgs e)
    //{
    //    GridDataItem dataItem = (GridDataItem)e.DetailTableView.ParentItem;
    //    int rdBatchID = (int)dataItem.GetDataKeyValue("RepeatDispensingBatchID");
    //    GenericTable repeatDispensings = new GenericTable("RepeatDispensings", "RequestID");
    //    repeatDispensings.LoadBySP("pWLabelByEntityIDAndRepeatDispensingBatchID", "EntityID", _entityID, "RepeatDispensingBatchID", rdBatchID);
    //    e.DetailTableView.DataSource = repeatDispensings.Table.DefaultView;
    //}

    /// <summary>
    /// Called when columns are created. Formats columns.
    /// </summary>
    /// <param name="sender">Control calling the method</param>
    /// <param name="e">Event arguements</param>
    protected void RadGrid1_ColumnCreated(object sender, Telerik.Web.UI.GridColumnCreatedEventArgs e)
    {
        GridColumn column = (e.Column as GridColumn);
        column.HeaderStyle.HorizontalAlign = HorizontalAlign.Center; // Centre all headings
        // Hide key columns
        if (column.UniqueName == "RepeatDispensingBatchID" || column.UniqueName == "LocationID" || column.UniqueName == "TotalSlots" || column.UniqueName == "StartSlot" || column.UniqueName == "EndSlot")
            column.Visible = false;
        // Size columns
        else if (column.UniqueName == "Breakfast" || column.UniqueName == "Lunch" || column.UniqueName == "Tea" || column.UniqueName == "Night")
        {
            column.HeaderText = column.UniqueName.Substring(0, 1);
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(45);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(45);
        }
        else if (column.UniqueName == "Status")
        {
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(70);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(70);
        }
        else if (column.UniqueName == "BatchCreated")
        {
            column.HeaderText = "Created";
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(75);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(75);
            ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + "}";
        }
        else if (column.UniqueName == "StartDate" || column.UniqueName == "EndDate")
        {
            switch (column.UniqueName)
            {
                case "StartDate":
                    column.HeaderText = "Start";
                    break;
                case "EndDate":
                    column.HeaderText = "End";
                    break;
            }
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(90);
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(90);
        }
        else if (column.UniqueName == "Description")
        {
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(260);
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(260);
        }
        else if (column.UniqueName == "Location")
        {
            column.HeaderStyle.Width = System.Web.UI.WebControls.Unit.Pixel(90);
            column.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(90);
        }


    }

    /// <summary>
    /// Called when a row is bound from the database. Performs any calculations
    /// </summary>
    /// <param name="sender">Control calling the method</param>
    /// <param name="e">Event arguements</param>
    protected void RadGrid1_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
    {
        if (e.Item is GridDataItem)
        {
            GridDataItem item = (GridDataItem)e.Item;
	    //25Apr17 TH Removed section as no longer relevant and due to base class changes is now causing an errof (TFS 182766)
            //if (e.Item.OwnerTableView.Name == "RepeatDispensings") // Perform any dispensing calculations
            //    // Format date string from database 
            //    item["Dispensed"].Text = BaseRow.FieldStrDateToDateTime(item["Dispensed"].Text, BaseRow.DateType.DDMMYYYY).ToPharmacyDateString();
            //else // Batch data
            //{
                //item["Description"].Text = "<nobr>" + item["Description"].Text + "</nobr>";
                //item["Location"].Text = "<nobr>" + item["Location"].Text + "</nobr>";
                if (!string.IsNullOrEmpty(item["StartSlot"].Text) && item["StartSlot"].Text != "&nbsp;") // If it's a JVM batch with a start slot
                {
                    // Start calculations for deriving end date and slot and change slot numbers to strings
                    int totalSlots = int.Parse(item["TotalSlots"].Text);
                    int startSlot = int.Parse(item["StartSlot"].Text);
                    DateTime startDate = DateTime.Parse(item["StartDate"].Text);
                    int firstDaySlots = 5 - startSlot;
                    int temp;
                    temp = startSlot + totalSlots - 1;
                    int endSlot = temp % 4;
                    if (endSlot == 0) endSlot = 4;
                    string endSlotString = "";
                    switch (endSlot)
                    {
                        case 1:
                            endSlotString = "Breakfast";
                            break;
                        case 2:
                            endSlotString = "Lunch";
                            break;
                        case 3:
                            endSlotString = "Tea";
                            break;
                        case 4:
                            endSlotString = "Night";
                            break;
                    }
                    item["EndSlot"].Text = endSlotString;
                    string startSlotString = "";
                    switch (item["StartSlot"].Text)
                    {
                        case "1":
                            startSlotString = "Breakfast";
                            break;
                        case "2":
                            startSlotString = "Lunch";
                            break;
                        case "3":
                            startSlotString = "Tea";
                            break;
                        case "4":
                            startSlotString = "Night";
                            break;
                    }
                    item["StartSlot"].Text = startSlotString;
                    item["StartDate"].Text = string.Format("{0:dd/MM/yyyy}", startDate) + " " + startSlotString.Substring(0,1);
                    DateTime endDate;
                    if (totalSlots > firstDaySlots)
                    {
                        int wholeDays = totalSlots - firstDaySlots - endSlot;
                        endDate = startDate.AddDays(1);
                        if (wholeDays > 0)
                        {
                            wholeDays = wholeDays / 4;
                            endDate = endDate.AddDays(wholeDays);
                        }
                    }
                    else
                    {
                        endDate = startDate;
                    }
                    item["EndDate"].Text = string.Format("{0:dd/MM/yyyy}", endDate) + " " + endSlotString.Substring(0, 1);

                    
                }
            //}
        }
    }

    protected void RadGrid1_PreRender(object sender, EventArgs e)
    {
        foreach (GridItem item in (sender as RadGrid).MasterTableView.Items)
        {
            foreach (TableCell cell in item.Cells)
            {
                if (String.IsNullOrEmpty(cell.Text.Trim()))
                {
                    cell.Text = "&nbsp;";
                }
            }
        }

    }
}
