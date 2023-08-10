//===========================================================================
//
//							        ICW_PNWorklist.aspx.cs
//
//  Used for creationg the PN Patient Parenteral Nutrition, Parenteral Nutrition, 
//  and PN Supply request worklists.
//
//  The worklist can be populated by sps
//      pPNWorklistPrescriptionWithOutPatient
//      pPNWorklistPrescriptionWithPatient
//      pPNWorklistRegimen
//      pPNWorklistSupplierRequest
//      pPNWorklistSupplierRequestWithOutPatient
//      pPNWorklistSupplyRequestComplete
//
//  And functions
//      fHasPNRegimen
//      fHasPNSupplyRequest
//
//	Modification History:
//  28Nov12 XN 29759 Show or hide expand icon on row depending if prescription 
//             or regimen has children
//  11Sep14 XN  88799 Added printing of prescription from regimen
//  15Sep14 XN  50736 Improved resizing of headers to get them to match up with columns
//  29Sep15 TH  130427 Added Overlay for URL scheme for call back 
//  15Oct15 XN  77977 On load if there is a prescription session attribute will auto select it
//  05Nov15 XN  134442 Updated the progress message to use new version
//  18Nov15 XN  133905 Added event handler PHARMACY_PNWorklist_SelectRequestAndPrint
//  27Jul16 XN  159036 Added expand\collapse via left \ right arrow
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using System.Xml.XPath;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ICWDTL10;
using Telerik.Web.UI;

public partial class application_PNWorklist_ICW_PNWorklist : System.Web.UI.Page
{
    #region Data Types
    /// <summary>structure reutrned when client calls GetPrintXML 11Sep14 XN  88799</summary>
    public struct PrintXMLReturn
    {
        public int requestID_Regimen;
        public int requestID_SupplyRequest;
        public string XML;
    }
    #endregion
    protected string   strURLScheme         = string.Empty;
    protected int      sessionID;
    protected int      siteID;
    protected bool     selectEpisodeMode    = false;
    protected int?     episodeID            = null;
    protected bool     suppressTerms        = true;
    protected string[] routines             = new string[3];
    protected string   token                = string.Empty;
    protected int intPortNumber;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(Request["AscribeSiteNumber"]))
            throw new ApplicationException("Need to set a desktop parameter AscribeSiteNumber");

        // Initialise session
        int sessionID = int.Parse(Request["SessionID"]);
        int SiteNumber = int.Parse(Request["AscribeSiteNumber"]);
        SessionInfo.InitialiseSessionAndSiteNumber (sessionID, SiteNumber);
        siteID = SiteProcessor.GetSiteIDByNumber(SiteNumber);

        // Get URL parameters
        selectEpisodeMode = false;
        if (!string.IsNullOrEmpty(Request["SelectEpisode"]))
            selectEpisodeMode = BoolExtensions.PharmacyParse(Request["SelectEpisode"]);

        episodeID = null;
        if (!string.IsNullOrEmpty(Request["EpisodeID"]))
            episodeID = int.Parse(Request["EpisodeID"]);

        // If episode mode, and no eiposde 
        if (!selectEpisodeMode && !episodeID.HasValue)
        {
            GENRTL10.StateRead state = new GENRTL10.StateRead();
            episodeID = state.GetKey(sessionID, "Episode");
        }

        routines[0] = Request["RoutineLevel1"];
        routines[1] = Request["RoutineLevel2"];
        routines[2] = Request["RoutineLevel3"];
        if (string.IsNullOrEmpty(routines[0]))
            throw new ApplicationException("Need to set a desktop parameter RoutineLevel1");

	    GENRTL10.SettingRead URLsettingread = new GENRTL10.SettingRead();
        strURLScheme = URLsettingread.GetValue(sessionID, "Pharmacy","WebConnection", "URLscheme", Request.Url.Scheme);
        intPortNumber = URLsettingread.GetPortNumber(SessionInfo.SessionID, "Pharmacy", "Database", "PortNoWebTransport");
			

        if (!this.IsPostBack)
        {
            // Check to see if terms need to be suppressed (only shown once per a session or desktop DBSession info set in Terms.aspx when user click accept)
            suppressTerms = WConfiguration.LoadAndCache(siteID, "D|PN", "Accept", "Suppress", false, false);
            if (!suppressTerms)
            {
                string key = "PN|Terms|Suppress|WindowID=" + Request["WindowID"];
                BoolExtensions.TryPharmacyParse(PharmacyDataCache.GetFromDBSession(key), out suppressTerms);
            }

            // Get filter options
            bool showFilterByWard = false, showFilterByDays = false, showIncludeCancelled = false, showWithoutSupplyRequest = false;
            BoolExtensions.TryPharmacyParse(Request["ShowFilterByWard"],         out showFilterByWard           );
            BoolExtensions.TryPharmacyParse(Request["ShowFilterByDays"],         out showFilterByDays           );
            BoolExtensions.TryPharmacyParse(Request["ShowIncludeCancelled"],     out showIncludeCancelled       );
            BoolExtensions.TryPharmacyParse(Request["ShowWithoutSupplyRequest"], out showWithoutSupplyRequest   );
        
            int filterToolBarWidth = 15;    // 15 pixels of padding
            divWards.Visible = showFilterByWard;
            if (showFilterByWard)
                filterToolBarWidth += 355;

            divDays.Visible = showFilterByDays;
            if (showFilterByDays)
                filterToolBarWidth += 175;

            cbIncludeCancelled.Visible = showIncludeCancelled;
            if (showIncludeCancelled)
                filterToolBarWidth += 130;

            cbWithoutSupplyRequest.Visible = showWithoutSupplyRequest;
            if (showWithoutSupplyRequest)
                filterToolBarWidth += 220;

            radToolbarFilters.Width   = new System.Web.UI.WebControls.Unit(filterToolBarWidth);
            radToolbarFilters.Visible = (filterToolBarWidth != 15);
            toolBarDiv.Visible        = (filterToolBarWidth != 15);

            // Populate filter toolbar

            ascribe.pharmacy.icwdatalayer.ToolMenu toolMenu = new ascribe.pharmacy.icwdatalayer.ToolMenu();
            toolMenu.LoadByWindowID(int.Parse(Request["WindowID"]));
            GenerateTelrikToolBar(toolMenu, radToolbar);

            LookupList wards = new LookupList();
            wards.LoadByWard();
            ddlWards.Items.Add(new ListItem("<All>", "-1"));
            foreach (LookupListRow w in wards)
                ddlWards.Items.Add(new ListItem(w.Descritpion, w.DBID.ToString()));

            //LookupList wardGroup = new LookupList();
            //wardGroup.LoadByWardGroup();
            //ddlWardGroup.Items.Add(new ListItem("<All>", "-1"));
            //foreach (LookupListRow w in wards)
            //    ddlWardGroup.Items.Add(new ListItem(w.Descritpion, w.DBID.ToString()));

            if (ddlDays.Visible)
            {
                LookupList days = new LookupList();
                days.LoadByPNDaysPast();
                if (this.episodeID.HasValue)
                    ddlDays.Items.Add(new ListItem("<All>", "-1"));
                foreach (LookupListRow d in days)
                    ddlDays.Items.Add(new ListItem(d.Descritpion, d.DBID.ToString()));
                if (days.Any(i => i.DBID == 7))
                    ddlDays.SelectedValue = 7.ToString();
            }
            else
                ddlDays.Items.Add(new ListItem("<All>", "-1"));

            PopulateGrid_Level1();
            if ((worklist.DataSource as DataView).Count > 0)
            {
                // If AutoSelectPrescription setting is on and there is a OrderEntry/OrdersXML in the SessionAttribute table the selected that prescription
                // The OrderEntry/OrdersXML is in the form <display><item class="request" id="116571" ... ></item></display>
                // 15Oct15 XN 77977 
                // worklist.SelectedIndexes.Add(new int[] { 0 });
                int selectedPrescritpionIndex = 0;
                if (PNSettings.Worklist.AutoSelectPrescription)
                {
                    try
                    {
                        string selectedPrescriptionXml = SessionInfo.GetAttribute("OrderEntry/OrdersXML", string.Empty);
                        int selectedPrescriptionId = int.Parse(XElement.Parse(selectedPrescriptionXml).XPathSelectElement(@"/item[@class='request']").Attribute("id").Value);
                        DataRow row = (worklist.DataSource as DataView).Table.Rows.Cast<DataRow>().First(s => ((int)s["RequestID"]) == selectedPrescriptionId);

                        if ((worklist.DataSource as DataView).Table.Rows.IndexOf(row) != -1)
                        {
                            selectedPrescritpionIndex = (worklist.DataSource as DataView).Table.Rows.IndexOf(row);
                            ExpandItem(selectedPrescriptionId, selectedPrescriptionId);
                        }
                    }
                    catch(Exception)
                    {
                    }
                }

                worklist.SelectedIndexes.Add(new int[] { selectedPrescritpionIndex });
                worklist.MasterTableView.Focus();
            }

            // If no level 3 routine then remove the level 3 table
            if (string.IsNullOrEmpty(routines[2]))
            {
                worklist.MasterTableView.DetailTables[0].ExpandCollapseColumn.Visible = false;
                worklist.MasterTableView.DetailTables[0].DetailTables.RemoveAt(0);
            }

            // If no level 2 routine then remove the level 2 table
            if (string.IsNullOrEmpty(routines[1]))
            {
                worklist.MasterTableView.ExpandCollapseColumn.Visible = false;
                worklist.MasterTableView.DetailTables.RemoveAt(0);
            }
        }


        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];

        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (target)
        {
        case "lpWorklist":
            // Update from buttons 
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                    // Fires when row is to be expanded
                    case "expand":
                        ExpandItem(int.Parse(argParams[1]), int.Parse(argParams[2]));
                        break;

                    // Manually fired to collapse a row  27Jul16 XN 158922
                    case "collapse":
                        {
                        var requestID_ToCollapse = int.Parse(argParams[1]);
                        var row = Find(worklist.MasterTableView, requestID_ToCollapse);
                        if (row != null)
                        {
                            row.Expanded = false;
                            row.Selected = true;
                        }
                        }
                        break;

                    // Fires when row is to be expanded
                    case "expandParent":
                        {
                            GridDataItem item   = Find(worklist.MasterTableView, int.Parse(argParams[1]));
                            GridDataItem parent = (item.OwnerTableView.ParentItem as GridDataItem);         
                            int selectedRequestID = int.Parse(argParams[2]);
                            if (selectedRequestID == -1)
                            {
                                XElement xml = XElement.Parse(PharmacyDataCache.GetFromDBSession("OrderEntry/OrdersXML"));
                                selectedRequestID = int.Parse(xml.Descendants("item").First().Attribute("id").Value);
                            }

                            int? requestID_Parent = (parent == null) ? null : (int?)parent.GetDataKeyValue("RequestID");
                            ExpandItem(requestID_Parent, selectedRequestID);
                        }
                        break;

                    // Fires when row is to be expanded
                    case "refresh":
                        {
                            PopulateGrid_Level1();

                            // If second parameter is a ID then select that row by default XN 19Oct15 77976
                            int? selectedRequestID = argParams.Length == 1 ? (int?)null : int.Parse(argParams[1]);
                            GridDataItem newItem = Find(worklist.MasterTableView, selectedRequestID);
                            if (newItem != null)
                            {
                                newItem.Selected = true;
                            }
                            else if (worklist.SelectedItems.Count == 0 && worklist.MasterTableView.Items.Count > 0)
                            {
                                worklist.MasterTableView.Items[0].Selected = true;  // 24Nov15 XN 135999 Select first item by default
                            }
                        }
                        break;

                case "setStatus":
                        {
                            int requestID = int.Parse(argParams[1]);
                            string status = argParams[2];

                            bool set = false;
                            BoolExtensions.TryPharmacyParse(argParams[3], out set);

                            // Set status
                            Request requests = new Request();
                            requests.LoadByRequestID(requestID);
                            if (requests[0].IsCancelled())
                				ScriptManager.RegisterStartupScript(this, this.GetType(), "setStatusError", "alert('Item has been cancelled');", true);
                            else if ((status.EqualsNoCase("PNIssued") || status.EqualsNoCase("PNPrinted") || status.EqualsNoCase("PNBeingMade") || status.EqualsNoCase("PNComplete")) &&
                                     (requests[0].RequestTypeID != ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.ID))
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "setStatusError", "alert('Must be supply request');", true);
                            else
                            {
                                requests[0].SetStatus(status, set);

                                // Refresh
                                GridDataItem item = Find(worklist.MasterTableView, requestID);
                                GridDataItem parent = (item.OwnerTableView.ParentItem as GridDataItem);
                                int? requestID_Parent = (parent == null) ? null : (int?)parent.GetDataKeyValue("RequestID");
                                ExpandItem(requestID_Parent, requestID);
                            }
                        }
                        break;

                    case "respondToItem":
                    {
                        int requestID = int.Parse(argParams[1]);
                        Request requests = new Request();
                        requests.LoadByRequestID(requestID);
                        requests[0].Complete("PN Supply Complete");
                        ExpandItem(requests[0].RequestID_Parent, requestID);
                    }
                    break;

                    case "find":    // 12Nov15 XN 133905 
                    {
                        Request requests = new Request();
                        List<int> requestIDs = new List<int>();
                        int requestId = int.Parse(argParams[1]);

                        // Need to find the complete hierarchy of the request prescription, regimen, supply request
                        // so that we known what to expand
                        requestIDs.Add(requestId);
                        do
                        {
                            requests.LoadByRequestID(requestIDs.Last());
                            requestIDs.Add(requests[0].RequestID_Parent);
                        } while (requests[0].RequestID_Parent != 0);

                        // Remove the empty request Id (and original as don't want to expand that)
                        requestIDs.Remove(0);
                        requestIDs.Remove(requestId);
                        requestIDs.Reverse();

                        // Expand each request
                        requestIDs.ForEach(id => ExpandItem(id, requestId));

                        // Perform the requested button action (have to do on delay to allow the grid to update)
                        string action = argParams.Length  > 2 ? argParams[2] : string.Empty;
                        if (!string.IsNullOrEmpty(action))
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "action", "setTimeout(function() { " + action + "(); }, 1000);", true);
                        }
                    }
                    break;
                }
            }
            break;

        case "upDummy":
            // Update from buttons 
            if (argParams.Count() > 0)
            {
                switch (argParams[0])
                {
                case "viewRegimen":
                    {   
                        // Called when View Regimen button is clicked from supply request, will display the regimen supply request is connected to
                        int requestID_SupplyRequest = int.Parse(argParams[1]);
                        Request request = new Request();
                        request.LoadByRequestID(requestID_SupplyRequest);
                        string script = string.Format("DisplayViewAndAdjust({0}, null, 'view');", request[0].RequestID_Parent);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "viewRegimen", script, true);
                    }
                    break;

                case "viewPrescription":
                    {   
                        // Called when View Prescription button is clicked from supply request, will display the prescription supply request is connected to
                        int requestID_SupplyRequest = int.Parse(argParams[1]);
                        Request request = new Request();
                        request.LoadByRequestID(requestID_SupplyRequest);       // Load supply request
                        request.LoadByRequestID(request[0].RequestID_Parent);   // Load regimen
                        string script = string.Format("RAISE_RequestSelected({0}); DoAction(OCS_VIEW);", request[0].RequestID_Parent);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "viewPrescription", script, true);
                    }
                    break;
                
		        //15Feb12 TH Test plumbing
		        case "issue":
                    {
                        // 11Sep14 XN  88799 Added printing of prescription from regimen
                        //int requestID = int.Parse(argParams[1]);
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
		                //ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'I'," + requestID + ",'','','" + ocxURL +"'); __doPostBack('lpWorklist', 'expandParent:" + requestID + ":" + requestID + "');", true);

                        int supplyRequestID = int.Parse(argParams[1]);
                        int regimenRequestID= ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(supplyRequestID).RequestID_Parent;
                        string ocxURL = string.Empty;
			            
                        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                        {
                            //string ocxURL = Request.Url.Scheme  + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        else
                        {
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
		                ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'I'," + regimenRequestID + "," + supplyRequestID + ",'','','" + ocxURL +"'); __doPostBack('lpWorklist', 'expandParent:" + supplyRequestID + ":" + supplyRequestID + "');", true);
		            }
                    break;

			    //20Feb12 TH Log Viewer
			    case "logview":
                    {
                        // 11Sep14 XN  88799 Added printing of prescription from regimen
                        //int requestID = int.Parse(argParams[1]);
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
			            //ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var strLocktoSite = document.body.getAttribute('LocktoSite');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'L'," + requestID + ",'',strLocktoSite,'" + ocxURL +"');", true);
                        int supplyRequestID = int.Parse(argParams[1]);
                        int regimenRequestID= ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(supplyRequestID).RequestID_Parent;
                        string ocxURL = string.Empty;

                        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                        {
                            //02Dec15 TH Had missed removing this line on previous merge TFS 136407
                            //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        else
                        {
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
			            ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var strLocktoSite = document.body.getAttribute('LocktoSite');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'L'," + regimenRequestID + "," + supplyRequestID + ",'',strLocktoSite,'" + ocxURL +"');", true);
			        }
                    break;

			    case "editlayouts":
                    {
                        string ocxURL = string.Empty;

                        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                        {
                            //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID; //05Sep15 TH missed scheme overload on first pass (TFS 130427)
                        }
                        else
                        {
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID; //05Sep15 TH missed scheme overload on first pass (TFS 130427)
                        }
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'E',0,0,'','','" + ocxURL + "');", true);
                        //ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'E',0,'','','" + ocxURL +"');", true); 11Sep14 XN 88799 Added printing of prescription from regimen
                    }
                    break;

                case "viewlayouts":
                    {
                        string ocxURL = string.Empty;

                        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                        {
                            //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        else
                        {
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'V',0,0,'','','" + ocxURL + "');", true);
                        //ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'V',0,'','','" + ocxURL +"');", true); 11Sep14 XN  88799 Added printing of prescription from regimen
                    }
                    break;

                //02Mar12 TH Added			
                case "return":
                    {
                        // 11Sep14 XN  88799 Added printing of prescription from regimen
                        //int requestID = int.Parse(argParams[1]);
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        //ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'R'," + requestID + ",'','','" + ocxURL +"'); __doPostBack('lpWorklist', 'expandParent:" + requestID + ":" + requestID + "');", true);

                        int supplyRequestID = int.Parse(argParams[1]);
                        int regimenRequestID= ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(supplyRequestID).RequestID_Parent;
                        string ocxURL = string.Empty;

                        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                        {
                            //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        else
                        {
                            ocxURL = strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(sessionID) + "&SessionID=" + sessionID;
                        }
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "processPN", " var strAscribeSiteNumber = document.body.getAttribute('AscribeSiteNumber');var ctrlRD = document.getElementById('objPN'); ctrlRD.ProcessPN(" + sessionID + ",strAscribeSiteNumber,'R'," + regimenRequestID + "," + supplyRequestID + ",'','','" + ocxURL + "'); __doPostBack('lpWorklist', 'expandParent:" + supplyRequestID + ":" + supplyRequestID + "');", true);
                    }
                    break;
                }		
            }	    
            break;
        }
    }

    private void GenerateTelrikToolBar(ascribe.pharmacy.icwdatalayer.ToolMenu toolMenu, RadToolBar radToolbar)
    {
        foreach (ToolMenuRow toolMenuRow in toolMenu)
        {
            RadToolBarButton button = new RadToolBarButton();
            if (toolMenuRow.Divider)
                button.IsSeparator = true;
            else
            {
                if (!string.IsNullOrEmpty(toolMenuRow.GetFullButtonImagePath()))
                    button.ImageUrl = toolMenuRow.GetFullButtonImagePath();
                if (!string.IsNullOrEmpty(toolMenuRow.EventName))
                    button.CommandName = string.Format("btnToolBar_onclick('{0}', '{1}', {2})", toolMenuRow.EventName, toolMenuRow.ButtonData, toolMenuRow.WindowID);
                    
                button.Text        = toolMenuRow.Description;
                button.ToolTip     = toolMenuRow.Detail;
            }

            radToolbar.Items.Add(button);
        }
    }

    private GridDataItem Find(GridTableView view, int? requestID)
    {
        if (requestID == null)
            return null;

        foreach(GridDataItem item in view.Items)
        {
            if (((int)item.GetDataKeyValue("RequestID")) == requestID)
                return item;
            
            GridDataItem childItem = null;
            if (item.ChildItem != null)
                childItem = Find(item.ChildItem.NestedTableViews[0], requestID);

            if (childItem != null)
                return childItem;
        }

        return null;

    }

    /// <summary>Expands the request, if already expanded that level will be refreshed</summary>
    /// <param name="requestID_ToExpand">Item to expand</param>
    /// <param name="requestID_Selected">Item to select</param>
    private void ExpandItem(int? requestID_ToExpand, int requestID_Selected)
    {
        GridDataItem item = Find(worklist.MasterTableView, requestID_ToExpand);
        
        // If can't find item refresh top level and try find again 19Nov15 XN 133905
        if (item == null)
        {
            PopulateGrid_Level1();
            item = Find(worklist.MasterTableView, requestID_ToExpand);
        }

        if (item != null)
        {
            if (item.ChildItem.NestedTableViews.Any())
                item.ChildItem.NestedTableViews[0].Rebind();
            item.Expanded = true;
            item.ExpandHierarchyToTop();
        }
        //else
        //    PopulateGrid_Level1();    19Nov15 XN 133905

        GridDataItem newItem = Find(worklist.MasterTableView, requestID_Selected);
        if (newItem != null)
            newItem.Selected = true;

        // Show or hide expand icon on row depending if it has children (only really for refresh expand) 29759  XN 28Nov12 
        if (item != null)
        {
            if (item.ChildItem.NestedTableViews[0].Items.Count > 0)
            {
                item.Expanded = true;
                item.Cells[0].Style.Remove("visibility");   // Show expand icon
            }
            else
            {
                item.Expanded = false;
                item.Cells[0].Style["visibility"] = "hidden";   // Hide expand icon
            }
        }
    }

    protected void PopulateGrid_Level1()
    {
        MetaDataRead metaDataRead = new MetaDataRead();
        string routineLevel1 = metaDataRead.ConvertRoutineDescriptionToName(routines[0]);

        GenericTable prescription = new GenericTable("Level1", "RequestID");
        prescription.LoadBySP(routineLevel1, "EpisodeID", episodeID ?? -1, "Ward", ddlWards.SelectedValue, "Days", ddlDays.SelectedValue, "IncludeCancelled", cbIncludeCancelled.Checked, "WithoutSupplyRequest", cbWithoutSupplyRequest.Checked, "SiteID", SessionInfo.SiteID);

        worklist.DataSource = prescription.Table.DefaultView;
        worklist.DataBind();
    }

    protected void worklist_DetailTableDataBind(object source, GridDetailTableDataBindEventArgs e)
    {
        GridDataItem dataItem = (GridDataItem)e.DetailTableView.ParentItem;
        int requestID_Parent = (int)dataItem.GetDataKeyValue("RequestID");
        bool includeCancelled = cbIncludeCancelled.Checked;
        MetaDataRead metaDataRead = new MetaDataRead();

        switch (e.DetailTableView.Name)
        {
        case "RoutimeLevel2":
            string routineLevel2 = metaDataRead.ConvertRoutineDescriptionToName(routines[1]);      // Normanly regimen             
            if (!string.IsNullOrEmpty(routineLevel2))
            {
                GenericTable regimen = new GenericTable("Level2", "RequestID");
                regimen.LoadBySP(routineLevel2, "RequestID_Parent", requestID_Parent, "Ward", ddlWards.SelectedValue, "Days", ddlDays.SelectedValue, "IncludeCancelled", cbIncludeCancelled.Checked, "WithoutSupplyRequest", cbWithoutSupplyRequest.Checked, "SiteID", SessionInfo.SiteID);
                e.DetailTableView.DataSource = regimen.Table.DefaultView;
            }
            break;

        case "RoutimeLevel3":
            string routineLevel3 = metaDataRead.ConvertRoutineDescriptionToName(routines[2]);
            if (!string.IsNullOrEmpty(routineLevel3))
            {
                GenericTable supplierRequest = new GenericTable("Level3", "RequestID");
                supplierRequest.LoadBySP(routineLevel3, "RequestID_Parent", requestID_Parent, "Ward", ddlWards.SelectedValue, "Days", ddlDays.SelectedValue, "IncludeCancelled", cbIncludeCancelled.Checked, "WithoutSupplyRequest", cbWithoutSupplyRequest.Checked, "SiteID", SessionInfo.SiteID);
                e.DetailTableView.DataSource = supplierRequest.Table.DefaultView;
            }
            break;
        }
    }

    protected void worklist_OnItemDataBound(object source, GridItemEventArgs e)
    {
        DataRowView row = (DataRowView)e.Item.DataItem;        
        if (row != null)
        {
            e.Item.Font.Strikeout   = (row["Request Cancellation"].ToString() == "1");

            // Show or hide expand icon on row depending if it has children 29759  XN 28Nov12 
            if ((bool)row["HasChildren"] == false)
                e.Item.Cells[0].Style["visibility"] = "hidden";
        }
    }

    protected void worklist_ColumnCreated(object sender, GridColumnCreatedEventArgs e)
    {
        GridColumn column = (e.Column as GridColumn);
        column.HeaderStyle.HorizontalAlign = HorizontalAlign.Center;

        if ((column.UniqueName == "RequestID") || (column.UniqueName == "RequestType") || (column.UniqueName == "Request Cancellation") ||
            (column.UniqueName == "EntityID")  || (column.UniqueName == "EpisodeID")   || (column.UniqueName == "HasChildren"))
            column.Visible = false;
        else if (column.UniqueName == "Authorised")
        {
            column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
//            column.ItemStyle.Width           = System.Web.UI.WebControls.Unit.Pixel(10);  prevent setting to help line up columns wih header 15Sep14 XN 50736
        }
        else if (column.UniqueName == "Batch Number")
        {
            column.HeaderStyle.Width  = System.Web.UI.WebControls.Unit.Pixel(100);
//            column.ItemStyle.Width    = System.Web.UI.WebControls.Unit.Pixel(100);    prevent setting to help line up columns wih header 15Sep14 XN 50736
        }
        else if (column.DataType.Name == typeof(int).Name)
        {
            column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
//            column.ItemStyle.Width           = System.Web.UI.WebControls.Unit.Pixel(100); prevent setting to help line up columns wih header 15Sep14 XN 50736
        }
        else if (column.DataType.Name == typeof(DateTime).Name)
        {
            column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
//            column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;                     Changed to center just for ken!    
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Center;
//            column.ItemStyle.Width           = System.Web.UI.WebControls.Unit.Pixel(100); prevent setting to help line up columns wih header 15Sep14 XN 50736
            if (column.UniqueName == "Last Modified On" || column.UniqueName == "Created Date")    // Last modified on should show daate and time
                ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + " " + DateTimeExtensions.TimePattern + "}";
            else
                ((GridBoundColumn)column).DataFormatString = "{0:" + DateTimeExtensions.ShortDatePattern + "}";
        }
        else if (column.DataType.Name == typeof(double).Name)
        {
            column.HeaderStyle.Width         = System.Web.UI.WebControls.Unit.Pixel(100);
            column.ItemStyle.HorizontalAlign = HorizontalAlign.Right;
//            column.ItemStyle.Width           = System.Web.UI.WebControls.Unit.Pixel(100); prevent setting to help line up columns wih header 15Sep14 XN 50736
        }
    }

    protected void dropDownListFilter_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        PopulateGrid_Level1();

    }

    protected void checkboxFilter_OnCheckedChanged(object sender, EventArgs e)
    {
        PopulateGrid_Level1();
    }

    [WebMethod]
    public static string GetToken(int sessionID)
    {
        return secrtl_c.TokenGenerator.GenerateToken(sessionID);
    }

    /// <summary>Returns is the regimen has been authorised 11Sep14 XN  88799</summary>
    [WebMethod]
    public static bool IsAuthorised(int sessionID, int requestID_Regimen)
    {
        SessionInfo.InitialiseSession(sessionID);
        PNRegimen regimen = new PNRegimen();
        regimen.LoadByRequestID(requestID_Regimen);
        return regimen.Any() && regimen.First().GetStatus("PNAuthorised");
    }

    /// <summary>
    /// Returns print XML data depending on request ID
    /// request ID can be a PN supply request or a regimen
    /// Will return XML data, and regimen id assocaited with the request, and the supply request ID (or -1)
    /// </summary>
    [WebMethod]
    public static PrintXMLReturn? GetPrintXML(int sessionID, int siteNumber, int requestID)
    //public static string GetPrintXML(int sessionID, int siteNumber, int requestID)
    {
        // 11Sep14 XN  88799 Added printing of prescription from regimen
        //SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);
        //PNPrintProcessor printProcessor = new PNPrintProcessor();
        //return printProcessor.GetPrintXML(requestID);

        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);
                 
        // Get the request type
        RequestRow      request     = ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(requestID);
        ICWTypeData?    requestType = ICWTypes.GetTypeByRequestTypeID(ICWType.Request, request.RequestTypeID);
        PrintXMLReturn? returnData  = null;
        
        // Get the print XML data depending on request type
        if (requestType != null)
        {
            switch (requestType.Value.Description.ToLower())
            {
            case "pn regimen"       : 
                returnData = new PrintXMLReturn()
                    {
                        requestID_Regimen       = request.RequestID,
                        requestID_SupplyRequest = -1,
                        XML                     = PNPrintProcessor.GetPrintXMLFromRegimen(requestID)
                    };
                break;
            case "supply request"   : 
                returnData = new PrintXMLReturn()
                    {
                        requestID_Regimen       = request.RequestID_Parent,
                        requestID_SupplyRequest = request.RequestID,
                        XML                     = PNPrintProcessor.GetPrintXMLFromSupplyRequest(requestID)
                    };
                break;
            }
        }

        return returnData;
    }

    [WebMethod]
    public static void SetState_Episode(int sessionID, int entityID, int episodeID)
    { 
        GENRTL10.State state = new GENRTL10.State();
        state.SetKey(sessionID, "Episode", episodeID);
        state.SetKey(sessionID, "Entity",  entityID);
    }

    /// <summary>
    /// Returns error if not possible to cancel the requested item
    /// or '{ASKUSER}' if need to ask user if they really want to delete (due to supply request).
    /// or empty string if okay to delete.
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="requestID">PN Prescription, Regimen or Supply Request ID</param>
    /// <param name="requestType">Request type of the above ID</param>
    /// <returns>Reason can't cancel, or empty string</returns>
    [WebMethod]
    public static string CanCancel(int sessionID, int requestID, string requestType)
    {
        SessionInfo.InitialiseSession(sessionID);
        string error = "Invalid type";

        switch (requestType)
        {
        case "PN Prescription":
            PNPrescrtiption prescription = new PNPrescrtiption();
            prescription.LoadByRequestID(requestID);
            if (prescription.Any())
            {
                if (prescription[0].CanCancel(out error))
                {
                    PNRegimen regimens = new PNRegimen();
                    regimens.LoadByPrescription(requestID, false);
                    if (regimens.Any(p => p.HasSupplyRequest()))
                        error = "<ASKUSER>";
                }
            }
            break;
        case "PN Regimen":
            PNRegimen regimen = new PNRegimen();
            regimen.LoadByRequestID(requestID);
            if (regimen.Any())
            {
                if (regimen[0].CanCancel(out error))
                {
                    if (regimen[0].HasSupplyRequest())
                        error = "<ASKUSER>";
                }
            }
            break;
        case "Supply Request":
            PNSupplyRequest supplyRequest = new PNSupplyRequest();
            supplyRequest.LoadByRequestID(requestID);            
            if (supplyRequest.Any())
                supplyRequest[0].CanCancel(out error);
            break;
        }

        return error;
    }
}
