// -----------------------------------------------------------------------
// <copyright file="aMMShiftEditor.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Allows user to edit an AMM shift.
//
// Call the page with the follow parameters
// SessionID           - ICW session ID
// AscribeSiteNumber   - Ascribe site number
// SiteID      
// AMMShiftID          - shift to edit (don't set if adding)
//
// Usage:
// aMMShiftEditor.aspx?SessionID=123&SiteID=24&AMMShiftID=1
//
// Modification History:
// 16May16 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.shared;

public partial class application_aMMSettings_aMMShiftEditor : System.Web.UI.Page
{
    /// <summary>AMM Shift id to edit</summary>
    private int? ammShiftID;

    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>    
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        this.ammShiftID = (this.Request["AMMShiftID"] == null ? (int?)null : int.Parse(this.Request["AMMShiftID"]));

        if (!this.IsPostBack)
        {
            if (this.ammShiftID != null)
                this.Populate();
        }

        this.GetAllControlsByType<TextBox>().ToList().ForEach(tb => tb.Attributes["onfocus"] = "this.select()");
    }

    /// <summary>
    /// Called when save button is called
    /// 1. Validates the page
    /// 2. Saves data
    /// 3. Closes the page
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>    
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (this.Validate())
        {
            this.Save();
            this.ClosePage(this.ammShiftID.ToString());
        }
    }

    /// <summary>Populates the page with the shift to edit</summary>
    private void Populate()
    {
        var ammShift = aMMShift.GetById(this.ammShiftID.Value);
        this.tbDescription.Text     = ammShift.Description;
        this.tbSlotsAvailable.Text  = ammShift.SlotsAvailable.ToString();
        this.tbStartTime.Text       = ammShift.StartTime.ToString(@"hh\:mm");
        this.tbEndTime.Text         = ammShift.EndTime.ToString(@"hh\:mm");
        this.cbSat.Checked          = ammShift.Saturday;
        this.cbMon.Checked          = ammShift.Monday;
        this.cbTues.Checked         = ammShift.Tuesday;
        this.cbWed.Checked          = ammShift.Wednesday;
        this.cbThurs.Checked        = ammShift.Thursday;
        this.cbFri.Checked          = ammShift.Friday;
        this.cbSun.Checked          = ammShift.Sunday;
    }

    /// <summary>Validates the page data</summary>
    /// <returns>If valid</returns>
    private bool Validate()
    {
        var culturalInfo = CultureInfo.CurrentCulture;
        TimeSpan timeInfo;
        string error;
        bool ok = true;

        // Description
        if (!Validation.ValidateText(tbDescription, string.Empty, typeof(string), true, aMMShift.GetColumnInfo().DescriptionLength, out error))
        {
            ok = false;
            tdDescriptionError.InnerHtml = error;
        }
        else if (aMMShift.GetAll().Any(s => s.Description.EqualsNoCaseTrimEnd(tbDescription.Text) && s.AMMShiftID != ammShiftID))
        {
            ok = false;
            tdDescriptionError.InnerHtml = "Not unique";
        }

        // Slots available
        if (!Validation.ValidateText(tbSlotsAvailable, string.Empty, typeof(int), true, 1, double.MaxValue, out error))
        {
            ok = false;
            tdSlotsAvailableError.InnerHtml = error;
        }

        // Start time
        if (!Validation.ValidateText(tbStartTime, "Start Time", typeof(string), true, out error))
        {
            ok = false;
            tdTimeError.InnerHtml = error;
        }
        else if (!TimeSpan.TryParseExact(tbStartTime.Text,@"hh\:mm", culturalInfo, out timeInfo))
        {
            ok = false;
            tdTimeError.InnerHtml = "Start time invalid must be HH:MM";
        }
        else if (timeInfo < TimeSpan.Zero || timeInfo > TimeSpan.FromDays(1))
        {
            ok = false;
            tdTimeError.InnerHtml = "Start time invalid must from 00:00 to 24:00";
        }

        // End time
        if (!Validation.ValidateText(tbEndTime, "End Time", typeof(string), true, out error))
        {
            ok = false;
            tdTimeError.InnerHtml = error;
        }
        else if (!TimeSpan.TryParseExact(tbEndTime.Text,@"hh\:mm", culturalInfo, out timeInfo))
        {
            ok = false;
            tdTimeError.InnerHtml = "End time invalid must be HH:MM";
        }
        else if (timeInfo < TimeSpan.Zero || timeInfo > TimeSpan.FromDays(1))
        {
            ok = false;
            tdTimeError.InnerHtml = "End time invalid must from 00:00 to 24:00";
        }

        // Days of week
        if (this.GetAllControlsByType<CheckBox>().All(cb => !cb.Checked))
        {
            ok = false;
            divDayError.InnerHtml = "Select a day<br />of the week.";
        }

        return ok;
    }

    /// <summary>Save the data</summary>
    private void Save()
    {
        var culturalInfo = CultureInfo.CurrentCulture;

        aMMShift ammShifts = new aMMShift();
        if (this.ammShiftID != null)
            ammShifts.LoadById(this.ammShiftID.Value);

        var row = ammShifts.Any() ? ammShifts[0] : ammShifts.Add();

        row.Description    = this.tbDescription.Text;
        row.SlotsAvailable = int.Parse(this.tbSlotsAvailable.Text);
        row.StartTime      = TimeSpan.ParseExact(this.tbStartTime.Text, @"hh\:mm", culturalInfo);
        row.EndTime        = TimeSpan.ParseExact(this.tbEndTime.Text,   @"hh\:mm", culturalInfo);
        row.Sunday         = this.cbSun.Checked;
        row.Monday         = this.cbMon.Checked;
        row.Tuesday        = this.cbTues.Checked;
        row.Wednesday      = this.cbWed.Checked;
        row.Thursday       = this.cbThurs.Checked;
        row.Friday         = this.cbFri.Checked;
        row.Saturday       = this.cbSat.Checked;
        row.Deleted        = false;
        row.SiteID         = SessionInfo.SiteID;
    
        ammShifts.Save();

        this.ammShiftID = row.AMMShiftID;
    }
}