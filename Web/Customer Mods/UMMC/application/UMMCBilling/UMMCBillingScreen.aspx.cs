//===========================================================================
//
//							UMMCBillingScreen.cs
//
//  UMMC specific screen that displays a list of dispensing that are to be 
//  sent to another billing system.
//
//  The list of dispensing are read form the WTranslog table, by selecting
//  all I, O, D, L type transactions for the patient (not just this episode)
//  over a specific time range. The dispensing list is grouped by NSVCode, 
//  episode, consultant code, prescription num, and ward code.
//
//  Once a user selects the dispensing, these are saved in the
//  BillingTransactionBatch, and BillingTransaction tables, and will be picked
// up by a PAS interface to send to the billing system
//
//  The patient details displayed at the top of the form are determined by 
//  sp pUMMCCalculateCostsScreenPatientDetails this sp should return 1 row
//  with each column displayed as a label value pair.
//
//  Unlike most other pharmacy forms this is not site specific.
//
//  The form has two modes one will just display the dispensing and will send any
//  selected to the payment system, the other will highlight if the dispensing 
//  has already been sent for billing (or been partially billed), and give user 
//  option of not sending items already billed. This is determined by 
//      System:  Pharmacy 
//      Section: UMMCBilling 
//      Key:     HighlightBilledTransactions
//
//  Usage 
//  UMMCBillingScreen.aspx?SessionID=941
//
//	Modification History:
//	03Sep10 XN  Written
//  20Sep10 XN  Removed the PrescriptionNum from the aggregation, as now 
//              replaced by the site generated code
//  30Sep10 XN  F0097623 Got to use ProductStock.cost for the billing 
//              transaction, also fixed spelling mistakes
//  05Oct10 XN  F0098140 Won't display the RxTracker 
//  06Oct10 XN  Added check, and uncheck all buttons
//  11Nov10 XN  Removed episode Id as now gets it from the Session State
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.ummcdatalayer;

public partial class application_bespoke_UMMC_Billing_UMMCBillingScreen : System.Web.UI.Page
{
    #region Constants
    // Extra attributes saved with each dispensing row in the gird
    protected static readonly string AttrConsultantCode         = "consultantcode";
    protected static readonly string AttrWardCode               = "wardcode";
    protected static readonly string AttrEpisodeID              = "episodeid";
    protected static readonly string AttrNSVCode                = "nsvcode";
    protected static readonly string AttrDescription            = "storesdescription";
    protected static readonly string AttrSiteNumber             = "sitenumber";
    protected static readonly string AttrSiteID                 = "siteid";
    protected static readonly string AttrPrescriptionNum        = "prescriptionnum";
    protected static readonly string AttrQuantityUnBilled       = "qtyunbilled";
    protected static readonly string AttrQuantityTotal          = "qtytotal";
    protected static readonly string AttrCostUnBilled           = "costunbilled";
    protected static readonly string AttrCostTotal              = "costtotal";
    protected static readonly string AttrWTranslogIDsUnBilled   = "wtranslogidsunbilled";
    protected static readonly string AttrWTranslogIDsTotal      = "wtranslogidstotal";
    protected static readonly string AttrBilledState            = "billedstate";
    #endregion

    #region Data Types
    /// <summary>Billed state of a dispensing line</summary>
    protected enum BillingState
    {
        AllBilled,
        PartBilled,
        NonBilled,
    }    
    #endregion

    #region Memeber variables
    /// <summary>Patient the form is to display info about</summary>
    private int entityID;    

    /// <summary>Episode for the patient that was used to call the form</summary>
    private int episodeID;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        // Initialise the Session
        int sessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);
        
        // Get the episode id (from state)
        GENRTL10.StateRead stateRead = new GENRTL10.StateRead();
        episodeID = stateRead.GetKey(sessionID, "Episode");

        // Determine the entity Id from the session
        entityID = Episode.GetEntityID(episodeID);

        if (!IsPostBack)
        {
            // Put the start date to the start of today’s date
            DateTime startDate = DateTime.Now.Date;
            this.startDate.Text = Ascribe.Common.Generic.Date2ddmmccyy(startDate);
            this.startDate.Attributes.Add("LastValue", Ascribe.Common.Generic.Date2ddmmccyy(startDate));

            // Put the end date to the end of today’s date
            DateTime endDate   = DateTime.Now.Date.AddDays(1.0).AddTicks(-1);
            this.endDate.Text = Ascribe.Common.Generic.Date2ddmmccyy(endDate);
            this.endDate.Attributes.Add("LastValue", Ascribe.Common.Generic.Date2ddmmccyy(endDate));

            // Populate the form
            PopulatePatientDetails();
            PopulateDispensingGrid(startDate, endDate);
        }
    }

    #region Protected Properties
    /// <summary>Gets for mode of if billed dispensing rows are highlighted</summary>
    protected bool HighlightBilledTransactions
    {
        get { return SettingsController.LoadAndCache<bool>("Pharmacy", "UMMCBilling", "HighlightBilledTransactions", false); }
    }

    /// <summary>Get setting used to close form automatically after user has pressed the billed button</summary>
    protected bool CloseFormAfterBillingComplted
    {
        get { return SettingsController.LoadAndCache<bool>("Pharmacy", "UMMCBilling", "CloseFormAfterBillingCompleted", true); }
    }    

    /// <summary>Colour of row when totally qty has already been billed.</summary>
    protected string HighlightColourAllBilled
    {
        get { return SettingsController.LoadAndCache<string>("Pharmacy", "UMMCBilling", "HighlightColourAllBilled", "Plum"); }
    }

    /// <summary>Colour of row when only part of the qty has already been billed.</summary>
    protected string HighlightColourPartBilled 
    {
        get { return SettingsController.LoadAndCache<string>("Pharmacy", "UMMCBilling", "HighlightColourPartBilled", "Thistle"); }
    }
    
    /// <summary>Colour of row when nothing has been billed.</summary>
    protected string HighlightColourNonBilled
    {
        get { return SettingsController.LoadAndCache<string>("Pharmacy", "UMMCBilling", "HighlightColourNonBilled", "#ffffff"); }
    }
    #endregion

    #region Protected Methods
    /// <summary>Gets the patient details to show at the top of the form by calling pUMMCCalculateCostsScreenPatientDetails</summary>
    protected void PopulatePatientDetails()
    {
        // A db column called separate is used to split the display into multiple columns
        const string SeparatorFieldName = "Separator";

        // Called the sp to get the patient details
        GenericTable table = new GenericTable(string.Empty, string.Empty);
        table.LoadBySP("pUMMCCalculateCostsScreenPatientDetails", "EntityID", entityID);

        // Get list of the column names
        List<string> fieldNames = new List<string>(table.Table.Columns.Count);
        for (int c = 0; c < table.Table.Columns.Count; c++)
            fieldNames.Add(table.Table.Columns[c].ColumnName);

        // Get the single row returned by the sp
        BaseRow row = table[0];

        // Get number of display columns.
        // Determined by number of columns called separator data return from pUMMCCalculateCostsScreenPatientDetails
        int columnCount = fieldNames.Count(n => n.StartsWith(SeparatorFieldName, StringComparison.CurrentCultureIgnoreCase)) + 1;
        patientInfo.SetColumns(columnCount);

        // Get number of display columns
        int col = 0;
        patientInfo.SetColumnWidth(col, 100 / columnCount);

        if (table.Count > 0)
        {
            // Iterate each column in data from db, and convert to label value pair in the form
            // If encounter a column called separator in the data then move to next display column
            foreach (string field in fieldNames)
            {
                if (!field.StartsWith(SeparatorFieldName, StringComparison.CurrentCultureIgnoreCase))
                    patientInfo.AddLabel(col, field + ":&nbsp;", table[0].RawRow[field].ToString());
                else
                {
                    // This db column is called separator so move the the next column
                    col++;
                    patientInfo.SetColumnWidth(col, 100 / columnCount);
                }
            }
        }
    }

    /// <summary>
    /// Displays the dispensing grid
    /// </summary>
    /// <param name="startDate">start date of the WTranslog recrods to use</param>
    /// <param name="endDate">end date of the WTranslog recrods to use</param>
    protected void PopulateDispensingGrid(DateTime startDate, DateTime endDate)
    {
        // Load all the episodes for the entity
        Episode episode = new Episode();
        episode.LoadByEntityID(entityID);

        // Get list of WTranslog items that have already been billed
        HashSet<int> billedWTransactionIDs = new HashSet<int>();
        if (this.HighlightBilledTransactions)
            billedWTransactionIDs = BillingTransactionBatch.GetBilledWTranslogIDs(entityID, startDate, endDate);

        // Load the WTranslog records for this entity, within the time range (get UMMC specific version)
        UMMCWTranslogView translog = new UMMCWTranslogView();
        translog.LoadByEpisodeAndDateRange(entityID, startDate, endDate);

        // Group all the Wtranslog records by NSVCode, episode, consultant code, prescription num, and ward code
        var dispensingData = from t in translog
                             where t.QuantityInIssueUnits > 0
                             group t by new
                             {
                                 t.NSVCode,
                                 t.EpisodeID,
                                 t.ConsultantCode,
                                 t.RxNumber,
                                 t.WardCode
                             } into t_group
                             orderby t_group.Key.NSVCode
                             select new
                             {
                                 t_group.Key.NSVCode,
                                 t_group.First().SiteNumber,
                                 t_group.First().SiteID,
                                 t_group.First().ProductDescription,
                                 t_group.Key.EpisodeID,
                                 t_group.Key.ConsultantCode,
                                 t_group.First().ConsultantName,
                                 PrescriptionNum = string.IsNullOrEmpty(t_group.Key.RxNumber) ? "0" : t_group.Key.RxNumber,
                                 t_group.Key.WardCode,
                                 t_group.First().IssueUnits,
                                 t_group.First().ConversionFactorPackToIssueUnits,
                                 TansactionInfo = t_group.Select(i => new { i.WTranslogID, Quantity = i.QuantityInIssueUnits }).ToList(),
                             };

        // Create the columns for the form
        dispensingsGrid.EmptyGridMessage = "No dispensing for this patient occurred in the selected time range.";
        dispensingsGrid.AddColumn(string.Empty,  3, PharmacyGridControl.ColumnType.Checkbox);
        dispensingsGrid.AddColumn("NSV Code",   13);
        dispensingsGrid.AddColumn("Description",32);
        dispensingsGrid.AddColumn("Episode",    13);
        dispensingsGrid.AddColumn("Consultant", 13);
        dispensingsGrid.AddColumn("Ward",       10);
        dispensingsGrid.AddColumn("Rx Num",     10, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
        dispensingsGrid.AddColumn("Qty",         6, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);

        // Enable column sorting an alternate row highlighting if applicable
        dispensingsGrid.SortableColumns = true;
        dispensingsGrid.EnableAlternateRowShading = !this.HighlightBilledTransactions;

        // populate the grid
        foreach (var rowData in dispensingData)
        {
            dispensingsGrid.AddRow();

            // Store the all the row information with each attribute
            dispensingsGrid.AddRowAttribute(AttrConsultantCode,  rowData.ConsultantCode);
            dispensingsGrid.AddRowAttribute(AttrWardCode,        rowData.WardCode);
            dispensingsGrid.AddRowAttribute(AttrEpisodeID,       rowData.EpisodeID.ToString());
            dispensingsGrid.AddRowAttribute(AttrNSVCode,         rowData.NSVCode);
            dispensingsGrid.AddRowAttribute(AttrDescription,     rowData.ProductDescription);
            dispensingsGrid.AddRowAttribute(AttrSiteNumber,      rowData.SiteNumber.ToString());
            dispensingsGrid.AddRowAttribute(AttrSiteID,          rowData.SiteID.ToString());
            dispensingsGrid.AddRowAttribute(AttrPrescriptionNum, rowData.PrescriptionNum);

            // Save as attribute all transaction Ids
            dispensingsGrid.AddRowAttribute(AttrWTranslogIDsTotal, rowData.TansactionInfo.Select(i => i.WTranslogID).ToCSVString(","));

            // Get list of unbilled WTranslog entries
            var unbilledTransactions = rowData.TansactionInfo.Where(i => !billedWTransactionIDs.Contains(i.WTranslogID)).ToList();
            dispensingsGrid.AddRowAttribute(AttrWTranslogIDsUnBilled, unbilledTransactions.Select(i => i.WTranslogID).ToCSVString(","));

            // Determine and store the total qty of item dispensed
            decimal totalQtyInIssueUnits = rowData.TansactionInfo.Sum(i => i.Quantity);
            dispensingsGrid.AddRowAttribute(AttrQuantityTotal, totalQtyInIssueUnits.ToString());

            // Determine and store the unbilled qty of item dispensed
            decimal qtyUnbilledInIssueUnits = unbilledTransactions.Sum(i => i.Quantity);
            dispensingsGrid.AddRowAttribute(AttrQuantityUnBilled, qtyUnbilledInIssueUnits.ToString());

            // populate the grid cells
            dispensingsGrid.SetCheck(0, false);
            dispensingsGrid.SetCell(1, rowData.NSVCode);
            dispensingsGrid.SetCell(2, rowData.ProductDescription);
            dispensingsGrid.SetCell(3, episode.FindByID(rowData.EpisodeID).Description);
            dispensingsGrid.SetCell(4, rowData.ConsultantName);
            dispensingsGrid.SetCell(5, rowData.WardCode);
            dispensingsGrid.SetCell(6, rowData.PrescriptionNum);
            dispensingsGrid.SetCell(7, string.Format("{0} {1}", totalQtyInIssueUnits, rowData.IssueUnits));

            // determine how the row will be highlighted
            if (this.HighlightBilledTransactions)
            {
                if (unbilledTransactions.Count == 0)
                {
                    // All transaction for this line have already been billed
                    dispensingsGrid.SetCheck(0, false);
                    dispensingsGrid.SetRowBackgroundColour(HighlightColourAllBilled);
                    dispensingsGrid.AddRowAttribute(AttrBilledState, BillingState.AllBilled.ToString());
                }
                else if (unbilledTransactions.Count == rowData.TansactionInfo.Count)
                {
                    // No transaction for this line have been billed
                    dispensingsGrid.SetCheck(0, true);
                    dispensingsGrid.SetRowBackgroundColour(HighlightColourNonBilled);
                    dispensingsGrid.AddRowAttribute(AttrBilledState, BillingState.NonBilled.ToString());
                }
                else
                {
                    // some transactions for this line have been billed
                    dispensingsGrid.SetCheck(0, true);
                    dispensingsGrid.SetRowBackgroundColour(HighlightColourPartBilled);
                    dispensingsGrid.AddRowAttribute(AttrBilledState, BillingState.PartBilled.ToString());
                }
            }
        }

        // Update if the legend should be displayed.
        rowHighlightKey.Visible = this.HighlightBilledTransactions;
    }    
    #endregion

    #region Event hanlders
    /// <summary>
    /// Called when the update button is clicked
    /// Updates the gird.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Update_Click(object sender, EventArgs e)
    {
        try
        {
            // Get start date (reset to start of the day 00:00:00)
            DateTime startDate;
            if (!DateTime.TryParse(this.startDate.Text, out startDate))
                throw new ApplicationException("Invalid start date");
            startDate = startDate.Date;

            // Get end date (reset to end of the day 23:59:59)
            DateTime endDate;
            if (!DateTime.TryParse(this.endDate.Text, out endDate))
                throw new ApplicationException("Invalid end date");
            endDate = endDate.AddDays(1.0).AddTicks(-1);

            // Error if wrong way around
            if (startDate > endDate)
                throw new ApplicationException("Start date must occur before the end date.");

            // Populate the gird
            PopulateDispensingGrid(startDate, endDate);
        }
        catch (Exception ex)
        {
            errorMessageDate.Text = ex.Message;
        }
    }

    /// <summary>
    /// Called when the billed button is clicked
    /// Will add the selected transaction to the BillingTransactionBatch, and BillingTransaction tables
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void billPatient_Click(object sender, EventArgs e)
    {
        // Get all the rows that have been selected for billing
        // Gives a attribute name to value pairing for the rows
        IEnumerable<Dictionary<string, string>> billingRowArray = PharmacyGridControl.ParseRowAttributes(this.selectedTransactionIDs.Value);

        try
        {
            // Get if user has only selected to send unbilled items
            bool onlySendUnbilledItems = false;
            if (!string.IsNullOrEmpty(this.onlySendUnbilledItems.Value))
                onlySendUnbilledItems = BoolExtensions.PharmacyParse(this.onlySendUnbilledItems.Value);

            // If there is nothing to bill then error
            if (!billingRowArray.Any())
                throw new ApplicationException("No dispensing selected.");

            // If only sending billed transactions, then filter out item that have already been completely billed
            if (onlySendUnbilledItems)
                billingRowArray = billingRowArray.Where(i => i[AttrBilledState] != BillingState.AllBilled.ToString());
            if (!billingRowArray.Any())
                throw new ApplicationException("There is nothing left to bill.");

            ProductStock productStock = new ProductStock();
            ProductStockRow productStockRow = null;

            // Save to database
            using (ICWTransaction scope = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Create the batch
                BillingTransactionBatch batch = new BillingTransactionBatch();
                BillingTransactionBatchRow batchRow = batch.Add();
                batchRow.LocationID_Terminal = SessionInfo.LocationID;
                batchRow.EntityID_Patient = entityID;
                batchRow.EpisodeID_Patient= episodeID;
                batch.Save();

                // Create the billing transaction
                BillingTransaction transaction = new BillingTransaction();
                foreach (Dictionary<string, string> billingRow in billingRowArray)
                {
                    int billingTransactionSiteID = int.Parse(billingRow[AttrSiteID]);

                    BillingTransactionRow transactionRow = transaction.Add();
                    transactionRow.NoteID_Thread        = batchRow.NoteID;
                    transactionRow.EpisodeID            = string.IsNullOrEmpty(billingRow[AttrEpisodeID])  ? (int?)null : int.Parse(billingRow[AttrEpisodeID]);
                    transactionRow.NSVCode              = billingRow[AttrNSVCode];
                    transactionRow.StoresDescription    = billingRow[AttrDescription].SafeSubstring(0, BillingTransaction.GetColumnInfo().StoresDescriptionLength);
                    transactionRow.SiteNumber           = int.Parse(billingRow[AttrSiteNumber]);
                    transactionRow.PrescriptionNum      = billingRow[AttrPrescriptionNum];
                    transactionRow.QuantityInIssueUnits = onlySendUnbilledItems ? decimal.Parse(billingRow[AttrQuantityUnBilled]) : decimal.Parse(billingRow[AttrQuantityTotal]);

                    // Get the cost from the product stock row, first check to see if it is loaded else reload from db.
                    productStockRow = productStock.FirstOrDefault(i => i.NSVCode.EqualsNoCaseTrimEnd(transactionRow.NSVCode) && (i.SiteID == billingTransactionSiteID));
                    if (productStockRow == null)
                    {
                        // If not loaded then load in appending to dataset
                        productStock.LoadBySiteIDAndNSVCode(transactionRow.NSVCode, billingTransactionSiteID, true);
                        productStockRow = productStock.FirstOrDefault(i => i.NSVCode.EqualsNoCaseTrimEnd(transactionRow.NSVCode) && (i.SiteID == billingTransactionSiteID));

                        // If still nothing then error
                        if (productStockRow == null)
                            throw new ApplicationException(string.Format("No product stock for drug '{0}' on site {1}", transactionRow.NSVCode, transactionRow.SiteNumber));
                    }
                    transactionRow.CostPerPackExVat = productStockRow.AverageCostExVatPerPack;

                    // Get the consultant entity ID, from the code
                    ConsultantRow consultant = Consultant.GetByConsultnatCode(billingRow[AttrConsultantCode]);
                    if (consultant != null)
                        transactionRow.EntityID_Consultant = consultant.EntityID;

                    // Get the ward location id, from the code
                    WardRow ward = Ward.GetByWardCode(billingRow[AttrWardCode]);
                    if (ward != null)
                        transactionRow.LocationID_Ward = ward.LocationID;

                    // Save the transaction
                    transaction.Save();

                    // Save each wtranslog id with the billingtransaction
                    string tanslogIDs = onlySendUnbilledItems ? billingRow[AttrWTranslogIDsUnBilled] : billingRow[AttrWTranslogIDsTotal];
                    IEnumerable<int> wtranlogIDs = tanslogIDs.Split(new char[] { ',' }).Distinct().Select(i => int.Parse(i));
                    transaction.AssociateBillingTransactionWithWTranslog(transactionRow.NoteID, wtranlogIDs);
                }

                scope.Commit();
            }

            // Call the client side BillingCompleted java script
            // to inform the user all went well
            string script = string.Format("BillingCompleted({0})", CloseFormAfterBillingComplted.ToString().ToLower());
            ScriptManager.RegisterStartupScript(this, typeof(Page), UniqueID, script, true);
        }
        catch (Exception ex)
        {
            errorMessageGrid.Text = ex.Message;
        }
    } 
    #endregion
}
