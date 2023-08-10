//===========================================================================
//
//							   PrescriptionMerge.aspx.cs
//
//  Allows user to select prescription for prescription linking (asymmetric linking)
//  
//  The page is normally called from the dispensing PMR, it gets a list of prescriptions
//  that can be dispensed to the current patient.
//  It will then filter out any prescriptions that are not suitable for prescription
//  linking based on selected prescription from the dispensing PMR.
//
//  Prescriptions suitable for prescription linking are shown in the top, and
//  the others are displayed in the bottom gird with a reason why they were excluded.
//
//  Full set of conditions for determining if a prescription can be prescription linked 
//  can be found in AsymmetricProcessor.cs but general includes
//      Prescription is not currently in prescription link
//      Is of type standard, or does less, and does not have does range
//      Has same route as selected prescription
//      Is in same branch of selected product's family tree.
//      Has consecutive time range for selected prescriptions
//
//  When form is initially created. It converts the AsymmetricCandidate strucutre used to 
//  describe a prescription (for sending to AsymmetricProcessor) to row attribute
//  of the gridAsymetricCandidates grid. When user selects an item to add to the prescription link, 
//  the selected item row attribute are sent back to server using client side CallServer method. 
//  Server side method RaiseCallBackEvent will parse back to AsymmetricCandidate structure so 
//  AsymmetricLinkingProcessor can test if prescription can be added to link.
//  As initial prescription selected in PMR is not present in gridAsymetricCandidates it's 
//  AsymmetricCandidate attributes are stored in hfSelectedDrugData.
//
//  Usage:
//  PrescriptionMerge.aspx?SessionID=123&EpisodeID=4565&RequestID=4572
//
//  SessionID - ICW session ID
//  EpisodeID - Current episode
//  RequestID - selected prescription as starting point of link
//  
//	Modification History:
//	24Jul11 XN   Written
//  01Dec11 XN   Update Prescription due to change to ICWTypes
//  20Apr12 XN   Minor updates for TFS32378 (Factoring in RxReasons)
//  06Mar15 XN   Added LoadAsymmetricCandidateTimeSlots top timeslot data
//  24Jul15 XN   Got RaiseCallbackEvent to return newly created request ID 114905
//  15Aep15 XN   In ConvertAsymmetricCandidateFromPrescription added ProductFormId 129200
//  12Oct15 TH   In ConvertAsymmetricCandidateFromPrescription added Ingredient_ProductID 130104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.asymmetricdosing;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;
using System.Web.Services;

public partial class application_DispensingPMR_PrescriptionMerge : System.Web.UI.Page, ICallbackEventHandler
{
    #region Member variables
    /// <summary>Current session from request URL</summary>
    protected int sessionID;

    /// <summary>Current patient episode from request URL</summary>
    protected int episodeID;

    /// <summary>Selected prescription from request URL (normaly sent from Dispensing PMR)</summary>
    protected int requestID;

    /// <summary>Call back results</summary>
    private string callBackResult;    
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // Add callserver function to the script
        String cbReference = Page.ClientScript.GetCallbackEventReference(this, "arg", "ReceiveServerData", "context");
        String callbackScript = "function CallServer(arg, context)" + "{ " + cbReference + ";}";
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "CallServer", callbackScript, true);

        // Extract request URL parameters
        sessionID = int.Parse(Request.QueryString["SessionID"]);
        requestID = int.Parse(Request.QueryString["RequestID"]);
        episodeID = int.Parse(Request.QueryString["EpisodeID"]);

        SessionInfo.InitialiseSession(sessionID);

        if (!this.IsPostBack)
        {
            try
            {
                AsymmetricProcessor processor = new AsymmetricProcessor();
                string reason;

                // Get the selected prescription
                Prescription prescriptions = new Prescription();
                prescriptions.LoadByRequestID(requestID);
                if (!prescriptions.Any())
                    throw new ApplicationException("Selected dispensing has been removed from the list. So can't be used.");

                // Convert selected prescription to asymmetric candidate and test it is suitable
                AsymmetricCandidate selectedPrescription = ConvertAsymmetricCandidateFromPrescription(prescriptions[0]);
                // if (!processor.IfSuitablePrescription(selectedPrescription, out reason)) TFS32378 20Ap12 XN Factoring RxReason
                if (!processor.IfSuitablePrescription(selectedPrescription, true, out reason))
                    throw new ApplicationException(reason);

                // Set header info
                lblSelectedDrug.Text = prescriptions[0].Description;
                lbDate.Text = "Date " + prescriptions[0].RequestDate.ToPharmacyDateString();
                if (prescriptions[0].StopDate.HasValue)
                    lbDate.Text += " to " + prescriptions[0].StopDate.ToPharmacyDateString();
                hfSelectedDrugData.Value = selectedPrescription.Marshal(false);

                // Get the chemical family for the prescription
                ICWTypeData? productTypeData_Chemical = ICWTypes.GetTypeByDescription(ICWType.Product, "Chemical");
                int? productTypeID_Chemical = (productTypeData_Chemical == null) ? (int?)null : productTypeData_Chemical.Value.ID;

                ProductFamily family = new ProductFamily();
                family.LoadByRelatedProduct(selectedPrescription.ProductID);
                int productID_Chemical = family.First(f => f.ProductTypeID_Product == productTypeID_Chemical).ProductID;

                // Load all realated prescriptions (under same product family)
                prescriptions.LoadByPatientProductFamilyAndActive(episodeID, productID_Chemical);

                // Set asymmertic candidates table headers
                gridAsymetricCandidates.AddColumn(string.Empty, 4, PharmacyGridControl.ColumnType.Checkbox);
                gridAsymetricCandidates.AddColumn("Description", 75, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Left, true);
                gridAsymetricCandidates.ColumnAllowTextWrap(1, true);
                gridAsymetricCandidates.AddColumn("Start Date", 10, PharmacyGridControl.ColumnType.DateTime, PharmacyGridControl.AlignmentType.Left, true);
                gridAsymetricCandidates.AddColumn("End Date", 10, PharmacyGridControl.ColumnType.DateTime, PharmacyGridControl.AlignmentType.Left, true);

                // Set non asymmertic candidates table headers
                gridNonAsymetricCandidates.AddColumn("Description", 60, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Left, true);
                gridNonAsymetricCandidates.ColumnAllowTextWrap(0, true);
                gridNonAsymetricCandidates.AddColumn("Reason Why Excluded", 40, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Left, true);
                gridNonAsymetricCandidates.ColumnAllowTextWrap(1, true);
                gridNonAsymetricCandidates.ColumnXMLEscaped   (1, false);   // TFS32378 20Ap12 XN Added to correctly format prescription reason message

                // Determine which prescritpions are suitable for asymmetric dosing
                foreach (PrescriptionRow prescription in prescriptions)
                {
                    if (prescription.RequestID == this.requestID)
                        continue;

                    // Convert prescription to an asymmetric candidate, and test if it is okay
                    AsymmetricCandidate item = ConvertAsymmetricCandidateFromPrescription(prescription);
                    if (processor.IfSuitablePrescription(item, false, out reason) && processor.CanLink(item, new AsymmetricCandidate[] { selectedPrescription }, true, out reason))
                    {
                        // Load in schedule template body data
                        this.LoadAsymmetricCandidateTimeSlots(item);

                        // add to asymmetric candidate list
                        gridAsymetricCandidates.AddRow();

                        gridAsymetricCandidates.AddRowAttribute("RequestID", item.RequestID.ToString());
                        gridAsymetricCandidates.AddRowAttribute("Data",      item.Marshal(false));

                        gridAsymetricCandidates.SetCell(1, prescription.Description);
                        gridAsymetricCandidates.SetCell(2, item.StartDate.ToPharmacyDateString());
                        gridAsymetricCandidates.SetCell(3, item.StopDate.ToPharmacyDateString ());
                    }
                    else
                    {
                        // Add to non asymmetric candidate list
                        gridNonAsymetricCandidates.AddRow();
                        gridNonAsymetricCandidates.SetCell(0, prescription.Description);
                        gridNonAsymetricCandidates.SetCell(1, reason);
                    }
                }
            }
            catch (ApplicationException ex)
            {
                // error so display message and closes
                string msg = ("Selected prescription is not suitable for prescription linking.\\n" + ex.Message).Replace("'", "\\'");
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "NoPrecriptionLinking", "alert('" + msg + "');window.close();", true); // Close the current window            	
            }
        }
    }
    #endregion

    #region Private Methods
    /// <summary>Convert prescription to asymmetric candidate</summary>
    /// <param name="prescription">prescription to convert</param>
    /// <returns>asymmetric candidate</returns>
    private AsymmetricCandidate ConvertAsymmetricCandidateFromPrescription(PrescriptionRow prescription)
    {
        AsymmetricCandidate asymmetricCandidate = new AsymmetricCandidate();
        asymmetricCandidate.RequestID           = prescription.RequestID;
        asymmetricCandidate.RequestTypeID       = prescription.RequestTypeID;
        asymmetricCandidate.ProductID           = prescription.ProductID;
        asymmetricCandidate.ProductTypeID       = prescription.ProductTypeID;
        asymmetricCandidate.ProductRouteID      = prescription.ProductRouteID;
        asymmetricCandidate.StartDate           = prescription.RequestDate;
        asymmetricCandidate.StopDate            = prescription.StopDate;
        asymmetricCandidate.ScheduleID          = prescription.ScheduleID_Administration;
        asymmetricCandidate.ProductFormId       = prescription.ProductFormId;  // Added 15Sep15 XN  129200
	    asymmetricCandidate.Ingredient_ProductID= prescription.Ingredient_ProductID;  // Added 12Oct15 TH 130104
        asymmetricCandidate.SingleDose          = prescription.SingleDose;      // 01Dec15 XN 136911 Added
        asymmetricCandidate.IfWhenRequired      = prescription.IsWhenRequired;  // 01Dec15 XN 136911 Added

        if (prescription is PrescriptionStandardRow)
        {
            asymmetricCandidate.ArbTextID_Direction = (prescription as PrescriptionStandardRow).ArbTextID_Direction;
            asymmetricCandidate.DirectionText       = (prescription as PrescriptionStandardRow).DirectionText;
            asymmetricCandidate.Dose                = (prescription as PrescriptionStandardRow).Dose.Value;
            asymmetricCandidate.DoseLow             = (prescription as PrescriptionStandardRow).DoseLow ?? 0;
        }
        else if (prescription is PrescriptionDoselessRow)
        {
            asymmetricCandidate.ArbTextID_Direction = (prescription as PrescriptionDoselessRow).ArbTextID_Direction;
            asymmetricCandidate.DirectionText       = (prescription as PrescriptionDoselessRow).DirectionText;
        }

        return asymmetricCandidate;
    }

    /// <summary>Load and sets the ScheduleTemplateBody timeslots for candidate</summary>
    /// <param name="candidate">Candidate time slots</param>
    private void LoadAsymmetricCandidateTimeSlots(AsymmetricCandidate candidate)
    {
        ScheduleTemplateBody template = new ScheduleTemplateBody();
        template.LoadByScheduleID(candidate.ScheduleID);
        if (template.Any())
        {
            candidate.TimeSlotCount       = template.CalculateDailyTimeSlots(template[0].ScheduleTemplateID);
            candidate.FirstTimeSlotInSecs = (int)template.Min(t => t.DailyFrequencyStartTime).TotalSeconds;
        }
    }
    #endregion

    #region Web methods
    /// <summary>
    /// Unlinks the selected link prescription
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID">Request of the WPrescriptionMerge to unlink</param>
    [WebMethod]
    public static void Unlink(int sessionID, int requestID)
    {
        SessionInfo.InitialiseSession(sessionID);

        AsymmetricProcessor processor = new AsymmetricProcessor();
        processor.RemoveLink(requestID);
    } 
    #endregion

    #region ICallbackEventHandler Members
    /// <summary>
    /// Called when client side calls CallServer
    /// Event args are supposed to be in the form
    /// {operation}\n{data}
    /// 
    /// for operation event args are 
    /// newselection
    /// ------------
    /// eventArgument = newselectionindex\n{selectedRowIndex}\n{row 1 attributes}\n{row 2 attributes}\n{row 3 attributes}\n{row 4 attributes}...
    /// return results= link={true\false}:{reason can't link or warning}
    /// 
    /// create
    /// ------
    /// eventArgument = create\n{row 1 attributes}\n{row 2 attributes}\n{row 3 attributes}\n{row 4 attributes}...      
    /// return results= created={true\false}
    /// </summary>
    /// <param name="eventArgument">args</param>
    public void RaiseCallbackEvent(string eventArgument)
    {
        try
        {
            // Split event args
            string[] eventparts = eventArgument.Split(new char[]{'\n'}, StringSplitOptions.RemoveEmptyEntries);

            // Check correct number of parameters
            if (eventparts.Length < 3)
                throw new ApplicationException("Invalid number of parameters");

            // Determin operation requested
            string operation = eventparts[0];
            switch (operation.ToLower())
            {
                case "newselection":
                    {
                        string reason;

                        // Convert all the checked row attributes to AsymmetricCandidate
                        // (skip first two eventparts as this is the operation, and selected row index)
                        List<AsymmetricCandidate> existingItems = eventparts.Skip(2).Select(s => AsymmetricCandidate.Parse(s)).ToList();

                        // Get the newly selected index prescription attributes, and remove it from the list
                        int newItemIndex = int.Parse(eventparts[1]);
                        AsymmetricCandidate newItem = existingItems[newItemIndex];
                        existingItems.RemoveAt(newItemIndex);

                        // Check if newly selected item can be asymmetricly linked with existing items
                        AsymmetricProcessor processor = new AsymmetricProcessor();
                        bool canLink = processor.CanLink(newItem, existingItems, false, out reason);

                        // set the return result
                        this.callBackResult = string.Format("link={0}\n{1}", canLink, reason);
                    }
                    break;

                case "create":
                    {
                        // Convert all the checked row attributes to AsymmetricCandidate
                        // (skip first eventparts as this is the operation)
                        List<AsymmetricCandidate> existingItems = eventparts.Skip(1).Select(s => AsymmetricCandidate.Parse(s)).ToList();

                        // And save
                        AsymmetricProcessor processor = new AsymmetricProcessor();
                        int requestID = processor.SaveLink(this.episodeID, existingItems);

                        //this.callBackResult = "created"; 24Jul15 XN 114905 now returns new request ID
                        this.callBackResult = "created\n" + requestID;
                    }
                    break;
            }
        }
        catch (Exception ex)
        {
            this.callBackResult = ex.Message;
        }
    }

    /// <summary>Returns result for CallServer</summary>
    /// <returns>CallServer result</returns>
    public string GetCallbackResult()
    {
        return this.callBackResult;
    }
    #endregion
}
