// -----------------------------------------------------------------------
// <copyright file="ShiftEditor.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Control to display all the shifts in a list and allow the user to add\edit\delete
// 
// Modification History:
// 15May16 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.shared;

public partial class application_aMMSettings_controls_ShiftEditor : System.Web.UI.UserControl
{
    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>  
    protected void Page_Load(object sender, EventArgs e)
    {
        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        int selectedAmmShiftId = -1;
        switch (argParams[0])
        {
        case "Delete":
            var aMMShiftIDs = new HashSet<int>(argParams[1].ParseCSV<int>(",", true));
            aMMShift shifts = new aMMShift();
            shifts.LoadAll();
            shifts.Where(r => aMMShiftIDs.Contains(r.AMMShiftID)).ToList().ForEach(r => r.Deleted = true);
            shifts.Save();
            break;
        case "Refresh":
            selectedAmmShiftId = (argParams.Length > 1 ? int.Parse(argParams[1]) : -1);
            break;
        }

        PopulateShiftGrid(selectedAmmShiftId);
    }

    /// <summary>Populate the grid</summary>
    /// <param name="selectedAmmShiftId">Id of the shift to select</param>
    private void PopulateShiftGrid(int selectedAmmShiftId)
    {
        gcShifts.AddColumn("Description", 25, PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Left);
        gcShifts.AddColumn("Start Time",  15, PharmacyGridControl.ColumnType.DateTime, PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("End Time",    15, PharmacyGridControl.ColumnType.DateTime, PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Slots",       10, PharmacyGridControl.ColumnType.DateTime, PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Sun",         5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Mon",         5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Tues",        5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Wed",         5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Thurs",       5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Fri",         5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
        gcShifts.AddColumn("Sat",         5,  PharmacyGridControl.ColumnType.Text,     PharmacyGridControl.AlignmentType.Center);
    
        foreach(var s in aMMShift.GetAll().OrderBy(s => s.Description))
        {
            gcShifts.AddRow();
            gcShifts.AddRowAttribute("DBID", s.AMMShiftID.ToString());
            gcShifts.SetCell(0, s.Description);
            gcShifts.SetCell(1, s.StartTime.ToString(@"hh\:mm"));
            gcShifts.SetCell(2, s.EndTime.ToString  (@"hh\:mm"));
            gcShifts.SetCell(3, s.SlotsAvailable.ToString());
            gcShifts.SetCell(4, s.Sunday   ? "Yes" : string.Empty);
            gcShifts.SetCell(5, s.Monday   ? "Yes" : string.Empty);
            gcShifts.SetCell(6, s.Tuesday  ? "Yes" : string.Empty);
            gcShifts.SetCell(7, s.Wednesday? "Yes" : string.Empty);
            gcShifts.SetCell(8, s.Thursday ? "Yes" : string.Empty);
            gcShifts.SetCell(9, s.Friday   ? "Yes" : string.Empty);
            gcShifts.SetCell(10,s.Saturday ? "Yes" : string.Empty);
        }

        // If items in the list the select then select on
        if (gcShifts.RowCount > 0)
        {
            int selectedRowIndex = Math.Max(gcShifts.FindIndexByAttrbiuteValue("DBID", selectedAmmShiftId.ToString()), 0);
            gcShifts.SelectRow(selectedRowIndex, setFocus: true);
        }
    }
}