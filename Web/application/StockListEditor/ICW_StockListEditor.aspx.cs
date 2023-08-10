// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ICW_StockListEditor.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Desktop for the ward stock list editor screen.
//
//  The screen displays all the lines on the ward stock list, 
//  Yellow panel for displaying details about lines, updated client side as user selects item's on list (values stored as attributes on grid row)
//  Green panel for displaying details about list properties, with a total cost that is updated on client from the WardStockListController
//
//  Both the grid and panels in the editor are populated from the QSDisplayItem table 
//  Category: StockList
//  Section: From desktop parameter, but common standard values are
//              GridForPharamcy (default if no parameter), or GridForWard, or GridForPharmacyTempEdit
//              LeftPanelForPharmacy (default if no parameter), or LeftPanelForWard, or LeftPanelForPharmacyTempEdit
//              RightPanelForPharmacy (default if no parameter), or RightPanelForWard, or RightPanelForPharmacyTempEdit
//  Using QSDisplayAccessor's WWardProductListAccessor, WWardProductListLineAccessor, and WProductQSProcessor
//
//  User will be able to load all ward stock lists for the current site (or lists that don't have a site), except in terminal specific mode where the 
//  list should be limited to just ones for the ward that the terminal is under
//
//  Locking
//  -------
//  List can be soft locked (user can issue or return but not edit) occurs when user opens list and no other user has a hard lock (but has not locked for editing)
//  or hard locked where user has locked the list (can only do if no other user has list open ie no soft lock) preventing others from opening
//
//  WardStockListController
//  -----------------------
//  Most of the editing of items on the list is done by the WardStockListController (accessible from both server and client side)
//  This also handles caching of data (List lines, products, and list properties) to the DB session cache, which is reload every time the list is opened.
//  The list data is cached in WardStockListController (caches all large data lines\product in DB SessionCache) smaller properties are transfered to client using JSON
//  The controller is also responsible to maintaining the total cost value (with is displayed on the green list properties panel)
//
//  Issue\Returning
//  ---------------
//  If list has print picking ticket enabled when an issue is performed, it will actual actually create a requisition (which requires user to print a picking ticket and then issue)
//  If print picking ticket is off then item will be issued immediately
//  Normally the system does not allow you to issue to wards that are out of use, but this can be overridden by configuration setting D|StockList..AllowIssueToOutOfUseWard
//  It is also possible to perform an issue\return to a temporary line (in temp edit mode) but the Last Issued info will not be updated.
//  Ad-hoc issues (performed via stores) will cause the last issue details of all ward stock list lines for that drug and ward to be updated.
//
//  Call the page with the following parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number
//  SiteID              -
//  ActiveXControl      - Enable\Disable if to load the active X control for the desktop
//  LimitIssueToTopupLvl- If list is limited to the top-up level or not
//  StockListView       - QS display name used to populate the list default GridForPharmacy
//  LeftPanelView       - QS display name used to populate left panel default LeftPanelForPharmacy
//  RightPanelView      - QS display name used to populate left panel default RightPanelForPharmacy
//  SortSelector        - Sort column used for the ward stock list selector
//  Mode                - Either ViewOnly/TemporaryEdit/Editable depending what mode the list is in
//                              ViewOnly        - Can't edit list but can issue and return
//                              TemporaryEdit   - Can edit list but can't save.
//                              Editable        - Allows full editing of the list
//  HideCost            - If list should hide costs
//  SelectListByTerminal- If selection of list should be limited to just ones for the ward that the terminal is under.
//
//  Modification History:
//  23Feb15 XN  Written 43318
//  08May15 XN  Renamed ProductSeatchType to ProductSearchType 111893 
//  15Jul15 XN  Added Find and Issue\Return 123057
//  20Jul15 XN  OpenList can get locking error on page load (not good for jquery) so use telerik on first load 122935 
//  04Aug15 XN  SaveLogViewerSearchCriteria update toDate should be end of day 124789
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;
using Newtonsoft.Json;
using Telerik.Web.UI;

public partial class application_StockListEditor_ICW_StockListEditor : System.Web.UI.Page
{
    #region Data Types
    /// <summary>Structure used to save the copy\cut information to the clipboard in JSON format</summary>
    private struct CopyPasteType
    {
        /// <summary>Site from which the copy\cut was performed</summary>
        public int AscribeSiteNumber;

        /// <summary>XML for the data set rows that are to be copy\cut</summary>
        public string RowsXML;
    }
    #endregion

    #region Constants
    private const string EventNameNew               = "WardStockList_New";
    private const string EventNameOpen              = "WardStockList_Open";
    private const string EventNameSave              = "WardStockList_Save";
    private const string EventNameSaveAs            = "WardStockList_SaveAs";
    private const string EventNameSaveAsNew         = "WardStockList_SaveAsNew";
    private const string EventNameSaveAsCSV         = "WardStockList_SaveAsCSV";
    private const string EventNameSaveAsInterface   = "WardStockList_SaveAsInterface";
    private const string EventNameCopy              = "WardStockList_Copy";
    private const string EventNameCut               = "WardStockList_Cut";
    private const string EventNamePaste             = "WardStockList_Paste";
    private const string EventNamePasteAbove        = "WardStockList_PasteAbove";
    private const string EventNamePasteBelow        = "WardStockList_PasteBelow";
    private const string EventNameInsertDrugAbove   = "WardStockList_InsertDrugAbove";
    private const string EventNameInsertDrugBelow   = "WardStockList_InsertDrugBelow";
    private const string EventNameInsertTitleAbove  = "WardStockList_InsertTitleAbove";
    private const string EventNameInsertTitleBelow  = "WardStockList_InsertTitleBelow";
    private const string EventNameDelete            = "WardStockList_Delete";
    private const string EventNameMoveUp            = "WardStockList_MoveUp";
    private const string EventNameMoveDown          = "WardStockList_MoveDown";
    private const string EventNameSort              = "WardStockList_Sort";
    private const string EventNameSortTitleAsc      = "WardStockList_SortTitleAsc";
    private const string EventNameSortTitleDes      = "WardStockList_SortTitleDes";
    private const string EventNameSortNSVCodeAsc    = "WardStockList_SortNSVCodeAsc";
    private const string EventNameSortNSVCodeDes    = "WardStockList_SortNSVCodeDes";
    private const string EventNameFind              = "WardStockList_Find";
    private const string EventNameFindIssue         = "WardStockList_FindIssue";    // 15Jul15 XN 123057 Added
    private const string EventNameFindReturn        = "WardStockList_FindReturn";   // 15Jul15 XN 123057 Added
    private const string EventNameIssue             = "WardStockList_Issue";
    private const string EventNameReturn            = "WardStockList_Return";
    private const string EventNameList              = "WardStockList_List";
    private const string EventNameListProperties    = "WardStockList_ListProperties";
    private const string EventNameDeleteList        = "WardStockList_DeleteList";
    private const string EventNameLogView           = "WardStockList_LogView";
    private const string EventNameItemEnquiry       = "WardStockList_ItemEnquiry";
    private const string EventNameLock              = "WardStockList_Lock";
    #endregion

    #region Member Variables
    /// <summary>List of sites</summary>
    protected Sites sites = new Sites();

    /// <summary>Ward stock list controller</summary>
    protected WardStockListController controller;

    /// <summary>Desktop parameter if active x control support is enabled</summary>
    protected bool isActiveXControlEnabled;

    /// <summary>Desktop parameter if limits issue to top up level</summary>
    protected bool limitIssueToTopupLvl;
    
    /// <summary>QSDisplayItem section used for the grid view</summary>
    protected string gridView;
    
    /// <summary>QSDisplayItem section used for the left panel view</summary>
    protected string leftPanelView;
    
    /// <summary>QSDisplayItem section used for the right panel view</summary>
    protected string rightPanelView;

    /// <summary>ID of this window</summary>
    protected int windowID;

    /// <summary>Desktop parameter to determine the sort column for the Ward Stock List lookup</summary>
    protected string sortSelectorColumn;
    #endregion

    #region Event Handlers
    /// <summary>Called when the page is loaded</summary>
    /// <param name="sender">Event sender</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(Request, Response);

        // Load sites
        sites.LoadAll(true);

        // Get desktop parameters
        isActiveXControlEnabled = string.IsNullOrEmpty(Request["ActiveXControl"]) || Request["ActiveXControl"].EqualsNoCaseTrimEnd("Enable");
        limitIssueToTopupLvl    = BoolExtensions.PharmacyParse(Request["LimitIssueToTopupLvl"] ?? "Y");
        gridView                = string.IsNullOrEmpty(Request["StockListView" ]) ? "GridForPharmacy"       : Request["StockListView" ];
        leftPanelView           = string.IsNullOrEmpty(Request["LeftPanelView" ]) ? "LeftPanelForPharmacy"  : Request["LeftPanelView" ];
        rightPanelView          = string.IsNullOrEmpty(Request["RightPanelView"]) ? "RightPanelForPharmacy" : Request["RightPanelView"];
        windowID                = int.Parse(Request["WindowID"]);
        sortSelectorColumn      = Request["SortSelector"] ?? "Code";

        if (this.IsPostBack)
            controller = WardStockListController.Create(hfController.Value);
        else
        {
            // Load toolbar
            ToolMenu toolMenu = new ToolMenu();
            toolMenu.LoadByWindowID( windowID );
            
            // create new page info
            controller                      = new WardStockListController();
            controller.Mode                 = (WardStockListMode)Enum.Parse(typeof(WardStockListMode), Request.QueryString["Mode"] ?? WardStockListMode.ViewOnly.ToString(), true);
            controller.MoneyDisplayType     = BoolExtensions.PharmacyParse(Request.QueryString["HideCost"]             ?? "No") ? MoneyDisplayType.HideWithLeadingSpace : MoneyDisplayType.Show;
            controller.SelectListByTerminal = BoolExtensions.PharmacyParse(Request.QueryString["SelectListByTerminal"] ?? "No");
            controller.TerminalID           = SessionInfo.LocationID;

            // Create toolbar and menu
            GenerateTelrikToolBar(toolMenu,   radToolbar );
            GenerateTelrikMenu   (radToolbar, contextMenu);

            // if in terminal select list mode then check if there is a single list for the terminal then open that
            // else show the list selector
            if (controller.SelectListByTerminal)
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("SiteID",    SessionInfo.SiteID      );
                parameters.Add("LocationID",controller.TerminalID   );
                parameters.Add("SortBy",    sortSelectorColumn      );

                GenericTable2 lists = new GenericTable2();
                lists.LoadBySP("pWWardProductListByLocationForLookup", parameters);
                if (lists.Count == 0)
                    Response.Redirect("..\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=No stock list associated with this terminal (LocationID:" + controller.TerminalID.ToString() + ").<br/>Need a terminal under a ward, associated with a pharmacy location, that is then associated with a stock list (which is in-use and visible to the ward)!!!");
                else if (lists.Count == 1)
                {   // Only 1 list so load by default
                    int wwardProductListID = (int)lists.First().RawRow["DBID"];
                    OpenList(wwardProductListID);
                }
                else // multiple lists so display stock list open method to allow user to choose
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "DisplayLists", "setTimeout(function() { pageLoad(); WardStockList_Open(); }, 1000);", true);
            }
        }

        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "NewList":
            {
            string wardProductListXML = argParams.Skip(1).ToCSVString(":");
            WWardProductList list = new WWardProductList();
            list.ReadXml(wardProductListXML);
            controller.NewList(list[0]);
            UpdateLockButton();
            }
            break;
        case "OpenList":
            {
            int wwardProductListID = int.Parse(argParams[1]);
            OpenList(wwardProductListID);
            UpdateLockButton();
            }
            break;
        case "Save":
            try
            {
                controller.Save();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDirtyFlag", "clearIsPageDirty(); alertEnh(\"Saved changes\", function() { $('#grid').focus(); });", true);
            }
            catch (ApplicationException ex)
            {
                string msg = "Failed to save<br />" + ex.Message;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorCodeInUse", "alertEnh('" + msg.JavaStringEscape() + "', function() { $('#grid').focus(); });", true);
            }
            break;
        case "SaveAs":
            {
            string wardProductListXML = argParams.Skip(1).ToCSVString(":");
            
            // Load new ward stock list properties
            WWardProductList list = new WWardProductList();
            list.ReadXml(wardProductListXML);

            try
            {
                string originalCode = controller.WardStockList.First().Code;
                string newCode      = list.First().Code;

                // Called controller saved as (will also set it as a new list)
                controller.SaveAs( list.First() );

                // Tell user list has been saved
                string script = string.Format("clearIsPageDirty(); alertEnh(\"Ward Stock List for '{0}' copied to '{1}'\", function() {{ $('#grid').focus(); }});", originalCode.JavaStringEscape(), newCode.JavaStringEscape());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDirtyFlag", script, true);
            }
            catch (ApplicationException ex)
            {
                string msg = "Failed to save as<br />" + ex.Message;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorCodeInUse", "alertEnh('" + msg.JavaStringEscape() + "', function() { $('#grid').focus(); });", true);
            }
            }
            break;
        case "ExportWinCE":
            {
            // More of an export to some vb6 CSV format

            string script;
            string URLtoken = "";
            if (!this.isActiveXControlEnabled)
                script = string.Format("alertEnh('Desktop parameter ActiveXControl=Disabled so this feature is unavailable.', function() {{ $('#grid').focus(); }});");            
            else
            {
                 GENRTL10.SettingRead settingReaad = new GENRTL10.SettingRead();
                 int intPortNumber = settingReaad.GetPortNumber(SessionInfo.SessionID, "Pharmacy", "Database", "PortNoWebTransport");

                 if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                 {
                     // Call vb6 control to ge4t ward stock export
                     URLtoken = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;   // URL token for embedded client side control
                 }
                 else
                 {
                     URLtoken = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;   // URL token for embedded client side control
                 }
                script = string.Format("var result = $('#objStoresControl')[0].WardStockExport({0}, {1}, '{2}', '{3}');", SessionInfo.SessionID, SessionInfo.SiteNumber, controller.WardStockList[0].Code, URLtoken);
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ExportToWinCE", script, true);
            }
            break;
        case "UpdateLine":
            {
            // Called to update the selected (single) line
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(controller.GetSelectedLine().NSVCode, SessionInfo.SiteID);
            UpdateLines(new [] { controller.SelectedLineID }, controller.SelectedLineID, product, "replace");
            }
            break;
        case "AddLine":
            {
            // Adds a line to the gird line must already exist in WardStockListLine structure
            var aboveOrBelow = argParams[1];
            var newLineID    = int.Parse(argParams[2]);
            
            int originalSelectedLineID;
            if ( !int.TryParse(argParams[3], out originalSelectedLineID) )
                originalSelectedLineID  = int.MinValue;

            // Load in the product data
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID( controller.WardStockListLines.FindByID(newLineID).NSVCode, SessionInfo.SiteID );

            // Updating the line will do the required add operation
            UpdateLines(new [] { newLineID }, originalSelectedLineID, product, aboveOrBelow);
            }
            break;
        case "Paste":
            {
            var aboveOrBelow  = argParams[1];
            var data          = argParams.Skip(2).ToCSVString(":");
            int selectedLineID= controller.SelectedLineID;
            WProduct productsForLine;

            try
            {
                // Get the data (original from clipboard) convert from json string
                CopyPasteType copyPasteData = JsonConvert.DeserializeObject<CopyPasteType>(data);

                // If not for current site then error.
                if (copyPasteData.AscribeSiteNumber == SessionInfo.SiteNumber)
                {
                    controller.AddLines(copyPasteData.RowsXML, ref aboveOrBelow, out productsForLine);
                    UpdateLines(controller.MultiSelectLineIDs, selectedLineID, productsForLine, aboveOrBelow);
                }
                else
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "CopyPasteError", "alertEnh('Cannot copy and paste between sites', function() { $('#grid').focus(); });", true);
            }
            catch(Exception) { }    // Silent error if pasted data is not correct (as just an invalid copy)
            }
            break;
        case "Sort":
            {
            string sortType = argParams[1];
            int count      = controller.MultiSelectLineIDs.Count();

            if (count <= 1)
            {
                // If 1 or less items selected then ward user
                string script = "alertEnh('Need to select multiple lines to do a sort.', function() { $('#grid').focus(); });";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "NeedMultSelect", script, true);
            }
            else if (controller.IsSelectedLinesContiguous())
            {
                // Best to reorder first so known that all numbers are correct
                controller.WardStockListLines.OrderByScreenPos().ToList().ResetScreenPositions();

                // Get selected block and reorder
                var selectedBlock = controller.WardStockListLines.FindByIDs( controller.MultiSelectLineIDs ).OrderByScreenPos();
                switch (sortType.ToLower())
                {
                case "titleasc"  : selectedBlock = selectedBlock.OrderBy          (l => l.ToString()); break;
                case "titledes"  : selectedBlock = selectedBlock.OrderByDescending(l => l.ToString()); break;
                case "nsvcodeasc": selectedBlock = selectedBlock.OrderBy          (l => l.NSVCode   ); break;
                case "nsvcodedes": selectedBlock = selectedBlock.OrderByDescending(l => l.NSVCode   ); break;
                }

                // Update screen pos
                selectedBlock.ResetScreenPositions( selectedBlock.Min(l => l.DisplayIndex) );

                ScriptManager.RegisterStartupScript(this, this.GetType(), "focusToGrid", "setIsPageDirty(); $('#grid').focus();", true);
            }
            else if (count > 0)
            {
                // Error if not contiguous block
                string script = "alertEnh('The marked block is not contiguous.<br />Please ensure that all lines between the start and the end of the block are selected', function() { $('#grid').focus(); });";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "noteContiguous", script, true);
            }
            }
            break;
        case "Lock":    // Lock\Unlock list
            try
            {
                if ( controller.CanEdit )
                {
                    controller.Unlock();
                    controller.OpenList( controller.WardProductListID );
                }
                else
                    controller.Lock();
                UpdateLockButton();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDirtyFlag", "clearIsPageDirty(); $('#grid').focus();", true);
            }
            catch(SoftLockException ex)
            {
                string msg = string.Format("List is currently in-use<br /><br />By: <b>{0}</b><br />Terminal: <b>{1}</b>", ex.GetLockerName(), ex.GetTerminal());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "lockError", "alertEnh('" + msg.JavaStringEscape() + "', function() { $('#grid').focus(); });", true);
            }
            catch(LockException ex)
            {
                string msg = string.Format("List is currently locked<br /><br />By: <b>{0}</b><br />Terminal: <b>{1}</b>", ex.GetLockerName(), ex.GetTerminal());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "lockError", "alertEnh('" + msg.JavaStringEscape() + "', function() { $('#grid').focus(); });", true);
            }
            break;
        case "PerformActiveXOpertaion":
            {
            // Performs the requested issue or return operation using the vb6 control
            string                  mode                = argParams[1]; // I - Issue or R - Return
            bool                    ignoreOutOfUseWard  = BoolExtensions.PharmacyParse(argParams[2]);
            bool                    isBarcode           = BoolExtensions.PharmacyParse(argParams[3]); // Obsolete now will always be false (barcode issue or return)
            string                  script              = string.Empty;
            WWardProductListLineRow line                = controller.GetSelectedLine();
            WCustomerRow            customer            = null;
            WardRow                 ward                = null;
            bool                    wardInUse           = true;

            // Get's list customer (not all lists have customers)
            customer = controller.WardStockList.First().GetCustomer();
            if (customer != null)
            {
                wardInUse = customer.InUse;
                ward      = Ward.GetByWardCode(customer.Code);
            }

            if (!this.isActiveXControlEnabled)
                 script = "alertEnh('Desktop parameter ActiveXControl=Disabled so this feature is unavailable.', function() { $('#grid').focus(); });"; 
            else if (!isBarcode && controller.MultiSelectLineIDs.Count() > 1)
                 script = "alertEnh('Only select a single line.', function() { $('#grid').focus(); });";
            else if (!isBarcode && (line == null || line.LineType != WWardProductListLineType.Drug))
                 script = "alertEnh('Select a drug line.', function() { $('#grid').focus(); });";
            else if (!wardInUse && !ignoreOutOfUseWard)
            {
                // Should not issue to out of use wards
                if (Settings.AllowIssueToOutOfUseWard)
                    script = string.Format("confirmEnh('Ward is out of use.<br />Do you want to continue?', false, function() {{ __doPostBack('upDummy', 'PerformActiveXOpertaion:{0}:1:{1}'); }}, function() {{ $('#grid').focus(); }} );", mode, isBarcode.ToOneZeorString());
                else
                    script = "alertEnh('Operation cannot be performed as ward is out of use.', function() { $('#grid').focus(); });";
            }
            else
            {
                // Perform the issue\return
                GENRTL10.SettingRead settingReaad = new GENRTL10.SettingRead();
                string URLtoken = "";
                 int intPortNumber = settingReaad.GetPortNumber(SessionInfo.SessionID, "Pharmacy", "Database", "PortNoWebTransport");

                 if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                 {
                     URLtoken = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;   // URL token for embedded client side control
                 }
                 else
                 {
                     URLtoken = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;   // URL token for embedded client side control
                 }
                if (controller.Mode == WardStockListMode.TemporaryEdit && controller.SelectedLineID < 0)
                {                    
                    script = string.Format("var result = $('#objStoresControl')[0].WardStockActionForUnsavedLine({0}, {1}, '{2}', '{3}', '{4}', '{5}', '{6}', '{7}', '{8}', {9}, '{10}');", SessionInfo.SessionID, SessionInfo.SiteNumber, line, line.NSVCode, line.GetConversionFactorPackToIssueUnits(), EnumDBCodeAttribute.EnumToDBCode(line.PrintLabel), line.TopupLvl, customer.Code, mode, limitIssueToTopupLvl.ToString().ToLower(), URLtoken);
                    script += "if (result != 0) { __doPostBack('upDummy', 'IssuedOrReturned:' + result ); };";
                }
                else 
                {
                    script = string.Format("$('#objStoresControl')[0].WardStockAction({0}, {1}, {2}, '{3}', {4}, {5}, '{6}');", SessionInfo.SessionID, SessionInfo.SiteNumber, controller.SelectedLineID, mode, isBarcode.ToString().ToLower(), limitIssueToTopupLvl.ToString().ToLower(), URLtoken);
                    script += "__doPostBack('upDummy', 'IssuedOrReturned');";
                }
            }

            ScriptManager.RegisterStartupScript(this, this.GetType(), "CallActiveX", script, true);
            }
            break;
        case "IssuedOrReturned":
            {
            // Called after the issue or return has been performed to update the grid
            int qty         = this.controller.Mode == WardStockListMode.TemporaryEdit && this.controller.SelectedLineID < 0 ? int.Parse(argParams[1]) : 0; // Only returns qty in temp edit mode
            var selectedRow = this.controller.WardStockListLines.FindByID(this.controller.SelectedLineID);
            bool isDirty    = this.controller.WardStockListLines.Table.GetChanges() != null;

            // Will update the gird line
            if (this.controller.SelectedLineID < 0)
            {
                // Temporary line so update values
                selectedRow.IsMultiIssueOnIssueDate = selectedRow.LastIssueDate != null;
                selectedRow.LastIssue               = qty;
                selectedRow.LastIssueDate           = DateTime.Now;
                selectedRow.DailyIssue              = (selectedRow.DailyIssue ?? 0) + qty;
            }
            else
            {
                // Load from DB. Okay to do this and overwrite as list must be saved before doing issue or return
                var line = WWardProductListLine.GetByID(SessionInfo.SiteID, this.controller.SelectedLineID);
                selectedRow.CopyFrom(line);
            }

            // Don't really care about the changes as come from DB or is temp edit so accept
            if (!isDirty)
            {
                this.controller.WardStockListLines.Table.AcceptChanges();
            }

            // Refresh displaying of lines
            UpdateLines(new [] { this.controller.SelectedLineID }, this.controller.SelectedLineID, this.controller.GetProductsForWorklist(), "replace");
            
            // if the Find and issue dialog is open then reselect find text box (meeds to occur after grid focus) 15Jul15 XN 123057
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SelectFindIssue", "setTimeout(function() { if ($('#divFindIssueReturn').is(':visible')) { $('#tbFindIssueReturn').select(); $('#tbFindIssueReturn').focus(); } }, 100);", true);
            }
            break;
        case "DeleteList":
            // Deletes the whole list
            controller.DeleteList();
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "ClosePage", "clearIsPageDirty(); $('#grid').focus();", true);
            break;
        case "UpdateListProperties":
            {
            // Get list properties
            string wardProductListXML = argParams.Skip(1).ToCSVString(":");
            WWardProductList list = new WWardProductList();
            list.ReadXml(wardProductListXML);
            controller.WardStockList[0].CopyFrom(list[0]);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "setFocus", "setIsPageDirty(); $('#grid').focus();", true);
            }
            break;
        }

        // Update temp edit message
        trTempEditMessage.Visible = (controller.Mode == WardStockListMode.TemporaryEdit) && controller.CanEdit;
        trLockingMessage.Visible  = (controller.Mode != WardStockListMode.TemporaryEdit) && controller.CanEdit && controller.WardProductListID != -1;

        // If another user is viewing the list warns user
        trInUseMessage.Visible = false;
        if (controller.Mode != WardStockListMode.TemporaryEdit && !controller.CanEdit && controller.CanUse)
        {
            var details = controller.IfListOpenByOthers();
            if (details != null)
            {
                trInUseMessage.Visible    = true;
                divInUseMessage.InnerHtml = string.Format("Stock list in use by <b>{0}</b> on terminal <b>{1}</b>", details.GetLockerName(), details.GetTerminal());
            }
        }
    }

    /// <summary>
    /// Called before pre-rendering
    /// If doing a full update then populate grid, and panels
    /// </summary>
    /// <param name="sender">Event sender</param>
    /// <param name="e">Event args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(Request["__EVENTTARGET"]) || Request["__EVENTTARGET"] == upMain.ID)
        {
            WProduct products = controller.GetProductsForWorklist();
            PopulateGrid(grid, controller.WardStockListLines, products, controller);
            controller.ReCalcualteCost();   // As performing full update recalc cost so stops getting out of sync
            PopulatePanels();
        }

        hfController.Value = controller.SaveToCache();
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Updates the state of the lock button
    /// If list is in editing mode (locked) will change edit button to Lock button (text, and image), 
    /// otherwise it will set it as the edit button (text and image)
    /// </summary>
    private void UpdateLockButton()
    {
        // Get the lock button (end if not present)
        var btnLock = radToolbar.GetAllControlsByType<RadToolBarButton>().FirstOrDefault(b => b.Attributes["eventName"] == EventNameLock);
        if (btnLock == null)
            return;

        // Get menu item
        ToolMenu menu = new ToolMenu();
        menu.LoadByWindowID(windowID);
        var editMenuItem = menu.FirstOrDefault(m => m.EventName == EventNameLock);
        if (editMenuItem == null)
            return;

        RadToolBarButton btnNewLock;
        if (controller.CanEdit)
        {
            // List in edit mode (locked) so change edit button to discard
            btnNewLock = CreateToolbarButton(@"..\..\images\User\lock open.gif", "Unlock", "Unlock list to allow other people to use it.", EventNameLock, string.Empty, editMenuItem.HotKey);
        }
        else
        {
            // If list is locked then display the edit button as normal (reads details from ToolMenu table)
            btnNewLock = CreateToolbarButton(editMenuItem.GetFullButtonImagePath(), editMenuItem.Description, editMenuItem.Detail, EventNameLock, string.Empty, editMenuItem.HotKey);
        }

        // Set button data
        btnLock.Text    = btnNewLock.Text;
        btnLock.ToolTip = btnNewLock.ToolTip;
        btnLock.ImageUrl= btnNewLock.ImageUrl;

        // Update toolbar
        upToolbar.Update();
    }

    /// <summary>
    /// Updates individual lines in a grid (can also perform add and delete operations)
    /// This method only updates the rendering of the grid, not the updating of the data.
    /// The method will call client side method 'updateLines' 
    /// In replace mode can only do one line at a time
    /// </summary>
    /// <param name="lineIDsToUpdate">Line IDs to update (add or delete)</param>
    /// <param name="wwardProductListLineID">if operation=above or below line ID to add new lines above or below, if operation=replace ID of line to update</param>
    /// <param name="product">Product data for all the lines in lineIDsToUpdate</param>
    /// <param name="operation">Operation to perform (above, below, replace)</param>
    private void UpdateLines(int [] lineIDsToUpdate, int wwardProductListLineID, WProduct product, string operation)
    {
        // Get lines to update
        var newLines = controller.WardStockListLines.FindByIDs(lineIDsToUpdate).ToList();

        // Convert to HTML table rows
        PopulateGrid(grid, newLines, product, controller);
        var rowHTML = grid.ExtractHTMLRows(0, newLines.Count).ToCSVString(string.Empty).Replace("\r\n", string.Empty);

        // Replace mode can only do one line at a time
        if (operation.EqualsNoCase("replace") && lineIDsToUpdate.Count() > 1)
            throw new ApplicationException("Can't replace more that one line at a time");

        // Call client side method
        string script = string.Format("updateLines('{0}', {1}, '{2}', '{3}'); $('#grid').focus();", 
                                                controller.SaveToCache().XMLEscape(), 
                                                wwardProductListLineID,
                                                rowHTML.XMLEscape(),
                                                operation.ToLower());
        ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateLine", script, true);
    }

    /// <summary>Opens list (puts list in soft lock mode) displays error if someone else has hard lock on list</summary>
    /// <param name="wwardProductListID">ID of list to open</param>
    private void OpenList(int wwardProductListID)
    {
        try
        {
            controller.OpenList(wwardProductListID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "lockError", "$('#grid').focus();", true);
        }
        catch (HardLockException ex)
        {
            string msg = string.Format("List is currently being edited<br /><br />By: <b>{0}</b><br />Terminal: <b>{1}</b>", ex.GetLockerName(), ex.GetTerminal());
            if (this.IsPostBack)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "lockError", "alertEnh('" + msg.JavaStringEscape() + "', function() { $('#grid').focus(); });", true);
            }
            else
            {
                radWindowManager.RadAlert(msg, null, null, "EMIS Health", null);    // 20Jul15 XN 122935 In terminal mode this msg fires on page load (not good for jquery) so use telerik on first load (if statement so has standard look and feel in normal mode)
            }
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDirtyFlag", "clearIsPageDirty();", true);
    }
    
    /// <summary>
    /// Creates the Telerik toolbar
    /// Using the data from ToolMenu table
    /// </summary>
    /// <param name="toolMenu">Tool menu to populate the toolbar with</param>
    /// <param name="radToolbar">Toolbar to populate</param>
    private void GenerateTelrikToolBar(ascribe.pharmacy.icwdatalayer.ToolMenu toolMenu, RadToolBar radToolbar)
    {
        foreach (ToolMenuRow toolMenuRow in toolMenu)
        {
            if (toolMenuRow.Divider)
            {
                RadToolBarButton button = new RadToolBarButton();
                button.IsSeparator = true;
                radToolbar.Items.Add(button);
            }
            else
            {
                switch (toolMenuRow.EventName)
                {
                case "WardStockList_SaveAs":
                    {
                    RadToolBarDropDown dropDown = CreateToolbarDropDown(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.HotKey, EventNameSave);
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Save As",                "Save As",                  EventNameSaveAsNew,        toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Save To CSV",            "Export list to CSV",       EventNameSaveAsCSV,        toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Save To Interface File", "Export to Interface File", EventNameSaveAsInterface,  toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    radToolbar.Items.Add(dropDown);
                    }
                    break;
                case "WardStockList_Copy":  // 16Jan14 XN 18211 Added default shortcut tooltip 
                    radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail + " (Ctrl+C)", EventNameCopy, toolMenuRow.ButtonData, string.Empty));
                    break;
                case "WardStockList_Cut":   // 16Jan14 XN 18211 Added default shortcut tooltip
                    radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail + " (Ctrl+X)", EventNameCut, toolMenuRow.ButtonData, string.Empty));
                    break;
                case "WardStockList_Paste": // 16Jan14 XN 18211 Added default shortcut tooltip
                    {
                    RadToolBarDropDown dropDown = CreateToolbarDropDown(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.HotKey, EventNamePaste);
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Paste Above", "Paste Above (Ctrl+V)",       EventNamePasteAbove, toolMenuRow.ButtonData, string.Empty));
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Paste Below", "Paste Below (Ctrl+Shift+V)", EventNamePasteBelow, toolMenuRow.ButtonData, string.Empty));
                    radToolbar.Items.Add(dropDown);
                    }
                    break;
                case "WardStockList_Delete":    // 16Jan14 XN 18211 Added default shortcut tooltip
                    radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail + " (Del)", EventNameDelete, toolMenuRow.ButtonData, string.Empty));
                    break;
                case "WardStockList_Sort":
                    {
                    RadToolBarDropDown dropDown = CreateToolbarDropDown(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.HotKey, EventNameSort);
                    dropDown.Buttons.Add(CreateToolbarButton(@"..\..\images\User\sort_asc.gif", "By Description Ascending",   "Sort Marked Block By Description Ascending",    EventNameSortTitleAsc,   toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(CreateToolbarButton(@"..\..\images\User\sort_des.gif", "By Description Descending",  "Sort Marked Block By Description Descending",   EventNameSortTitleDes,   toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(CreateToolbarButton(@"..\..\images\User\sort_asc.gif", "By NSVCode Ascending", "Sort Marked Block By NSVCode Ascending",  EventNameSortNSVCodeAsc, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(CreateToolbarButton(@"..\..\images\User\sort_des.gif", "By NSVCode Descending","Sort Marked Block By NSVCode Descending", EventNameSortNSVCodeDes, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    radToolbar.Items.Add(dropDown);
                    }
                    break;
                case "WardStockList_List": 
                    {
                    RadToolBarDropDown dropDown = CreateToolbarDropDown(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.HotKey, EventNameList);
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "List Properties", "Display List properties", EventNameListProperties, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    dropDown.Buttons.Add(new RadToolBarButton() { IsSeparator=true });
                    dropDown.Buttons.Add(CreateToolbarButton(string.Empty, "Delete List",     "Delete the current list", EventNameDeleteList, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    radToolbar.Items.Add(dropDown);
                    }
                    break;
                case "WardStockList_ItemEnquiry":   // 16Jan14 XN 18211 Added default shortcut tooltip
                    radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail + " (F4)", EventNameItemEnquiry, toolMenuRow.ButtonData, string.Empty));
                    break;
                case "WardStockList_Find":  
                    if (toolMenu.Any(t => t.EventName == "WardStockList_Issue" || t.EventName == "WardStockList_Return"))
                    {
                        // 15Jul15 XN 123057 Added find and issue option
                        RadToolBarDropDown dropDown = this.CreateToolbarDropDown(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.HotKey, EventNameList);
                        dropDown.Buttons.Add(this.CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description,            toolMenuRow.Detail,          EventNameFind,      toolMenuRow.ButtonData, toolMenuRow.HotKey));
                        if (toolMenu.Any(t => t.EventName == "WardStockList_Issue"))
                            dropDown.Buttons.Add(this.CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description + " Issue", "Find and issue by barcode", EventNameFindIssue, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                        if (toolMenu.Any(t => t.EventName == "WardStockList_Return"))
                            dropDown.Buttons.Add(this.CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description + " Return", "Find and return by barcode", EventNameFindReturn, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                        radToolbar.Items.Add(dropDown);
                    }
                    else
                        radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.EventName, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    break;
                default:
                    radToolbar.Items.Add(CreateToolbarButton(toolMenuRow.GetFullButtonImagePath(), toolMenuRow.Description, toolMenuRow.Detail, toolMenuRow.EventName, toolMenuRow.ButtonData, toolMenuRow.HotKey));
                    break;
                }
            }
        }
    }
    
    /// <summary>Builds the telerik right click menu from the buttons on the toolbar</summary>
    /// <param name="radToolbar">Toolbar to to create the menu</param>
    /// <param name="contextMenu">Context menu to create</param>
    private void GenerateTelrikMenu(RadToolBar radToolbar, RadContextMenu contextMenu)
    {
        List<RadToolBarButton>   allButtons       = radToolbar.GetAllControlsByType<RadToolBarButton>().ToList();
        List<RadToolBarDropDown> allDropDowns     = radToolbar.GetAllControlsByType<RadToolBarDropDown>().ToList();
        RadToolBarDropDown       radToolBarParent = null;
        int                      lastCount        = 0;
                
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameFind ));   // Find

        // Item enquiry (only appears on menu so just add manually)
        RadMenuItem menuItem = new RadMenuItem() { ImageUrl=@"..\..\images\User\report2.gif", Text="Item Enquiry", Value=EventNameItemEnquiry+"()" };
        menuItem.Attributes.Add("eventName", EventNameItemEnquiry);
        contextMenu.Items.Add(menuItem);

        if (lastCount < contextMenu.Items.Count)
            contextMenu.Items.Add(new RadMenuItem(){ IsSeparator=true }); 
        lastCount = contextMenu.Items.Count;

        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameCopy      ));   // Copy
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameCut       ));   // Cut
        radToolBarParent = allDropDowns.FirstOrDefault(b => b.Attributes["eventName"] == EventNamePaste);
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNamePasteAbove), radToolBarParent);   // Paste Above
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNamePasteBelow), radToolBarParent);   // Paste Below

        if (lastCount < contextMenu.Items.Count)
            contextMenu.Items.Add(new RadMenuItem(){ IsSeparator=true }); 
        lastCount = contextMenu.Items.Count;

        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameMoveUp    ));   // Move up
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameMoveDown  ));   // Move Down

        if (lastCount < contextMenu.Items.Count)
            contextMenu.Items.Add(new RadMenuItem(){ IsSeparator=true }); 
        lastCount = contextMenu.Items.Count;

        // Insert drug above or below
        if (allButtons.Any(b => b.Attributes["eventName"] == EventNameInsertDrugBelow || b.Attributes["eventName"] == EventNameInsertDrugAbove))
        {
            menuItem = new RadMenuItem() { ImageUrl = @"..\..\images\User\insert_above.gif", Text = "Add Item Above", Value=EventNameInsertDrugAbove+"()" };
            menuItem.Attributes.Add("eventName", EventNameInsertDrugAbove);
            contextMenu.Items.Add(menuItem);

            menuItem = new RadMenuItem() { ImageUrl = @"..\..\images\User\insert_below.gif", Text = "Add Item Below", Value=EventNameInsertDrugBelow+"()" };
            menuItem.Attributes.Add("eventName", EventNameInsertDrugBelow);
            contextMenu.Items.Add(menuItem);
        }

        // Insert title above or below        
        if (allButtons.Any(b => b.Attributes["eventName"] == EventNameInsertTitleBelow || b.Attributes["eventName"] == EventNameInsertTitleAbove))
        {
            menuItem = new RadMenuItem() { ImageUrl = @"..\..\images\User\insert_above.gif", Text = "Add Title Above", Value=EventNameInsertTitleAbove+"()" };
            menuItem.Attributes.Add("eventName", EventNameInsertTitleAbove);
            contextMenu.Items.Add(menuItem);

            menuItem = new RadMenuItem() { ImageUrl = @"..\..\images\User\insert_below.gif", Text = "Add Title Below", Value=EventNameInsertTitleBelow+"()" };
            menuItem.Attributes.Add("eventName", EventNameInsertTitleBelow);
            contextMenu.Items.Add(menuItem);
        }

        if (lastCount < contextMenu.Items.Count)
            contextMenu.Items.Add(new RadMenuItem(){ IsSeparator=true }); 
        lastCount = contextMenu.Items.Count;

        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameDelete ));   // Delete

        if (lastCount < contextMenu.Items.Count)
            contextMenu.Items.Add(new RadMenuItem(){ IsSeparator=true }); 
        lastCount = contextMenu.Items.Count;

        radToolBarParent = allDropDowns.FirstOrDefault(b => b.Attributes["eventName"] == EventNameSort);
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameSortTitleAsc  ), radToolBarParent);   // Sort description asc
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameSortTitleDes  ), radToolBarParent);   // Sort description desc
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameSortNSVCodeAsc), radToolBarParent);   // Sort NSVCode asc
        AddMenuItem(contextMenu, allButtons.FirstOrDefault(b => b.Attributes["eventName"] == EventNameSortNSVCodeDes), radToolBarParent);   // Sort NSVCode desc
    }

    /// <summary>Add item to context menu</summary>
    /// <param name="contextMenu">Context menu to add the item to</param>
    /// <param name="associatedButton">associated toolbar button to get the menu item info</param>
    /// <param name="parentAssociatedButton">Parent associated button</param>
    private void AddMenuItem(RadContextMenu contextMenu, RadToolBarButton associatedButton, RadToolBarDropDown parentAssociatedButton = null)
    {
        if (associatedButton == null)
            return;

        RadMenuItem menuItem = new RadMenuItem();
        menuItem.ImageUrl   = associatedButton.ImageUrl;
        menuItem.Text       = associatedButton.Text;
        menuItem.Value      = associatedButton.CommandName; // javascript function to run
        menuItem.Attributes.Add("eventName", associatedButton.Attributes["eventName"]);

        if (parentAssociatedButton == null)
            contextMenu.Items.Add(menuItem);
        else
        {
            RadMenuItem parentMenuItem = contextMenu.FindItemByText(parentAssociatedButton.Text);
            if (parentMenuItem == null)
            {
                parentMenuItem = new RadMenuItem() { Text=parentAssociatedButton.Text };
                parentMenuItem.Attributes.Add("eventName", parentAssociatedButton.Attributes["eventName"]);
                contextMenu.Items.Add(parentMenuItem);
            }
            parentMenuItem.Items.Add(menuItem);
        }
    }

    /// <summary>Create drop down button for the toolbar</summary>
    /// <param name="image">image url</param>
    /// <param name="text">button text</param>
    /// <param name="tooltip">button tooltip</param>
    /// <param name="accessKey">Access key</param>
    /// <param name="eventName">event name</param>
    /// <returns></returns>
    private RadToolBarDropDown CreateToolbarDropDown(string image, string text, string tooltip, string accessKey, string eventName = null)
    {
        RadToolBarDropDown button = new RadToolBarDropDown();
        if (!string.IsNullOrEmpty(image))
        {
            button.ImageUrl = image;
            button.ImagePosition = ToolBarImagePosition.AboveText;
        }
        if (!string.IsNullOrEmpty(eventName))
            button.Attributes.Add("eventName", eventName);
        button.Text     = text;
        button.ToolTip  = tooltip;
        button.AccessKey= accessKey;
        return button;
    }

    /// <summary>
    /// Creates and returns the telerik toolbar button
    /// Access key will be displayed added to end of the tooltip, for will also under line the char in the button text
    /// Button will have attribute name eventName="{eventName}"
    /// Button click will be eventName(buttonData)
    /// </summary>
    /// <param name="image">image path</param>
    /// <param name="text">Button text</param>
    /// <param name="tooltip">Tool tip</param>
    /// <param name="eventName">Event name</param>
    /// <param name="buttonData">Button data</param>
    /// <param name="accessKey">single char Alt+access key</param>
    /// <returns>New Key</returns>
    private RadToolBarButton CreateToolbarButton(string image, string text, string tooltip, string eventName, string buttonData, string accessKey)
    {
        RadToolBarButton button = new RadToolBarButton();
        if (!string.IsNullOrEmpty(image))
        {
            button.ImageUrl = image;
            button.ImagePosition = ToolBarImagePosition.AboveText;
        }
        
        // display info on access keys (underline text, and add to tooltip)
        if ( !string.IsNullOrEmpty(accessKey) )
        {
            // find access key in text, and 
            int index = text.IndexOf( accessKey, StringComparison.InvariantCultureIgnoreCase );
            if (index >= 0)
            {
                text = text.SafeSubstring(0, index) + "<u>" + text.SafeSubstring(index, 1) + "</u>" + text.SafeSubstring(index + 1, text.Length - index - 1);
            }

            tooltip += string.Format(" (Alt+{0})", accessKey);
            button.AccessKey= accessKey;
        }

        button.Attributes.Add("eventName", eventName);
        button.Text     = text;
        button.ToolTip  = tooltip;
        if (!string.IsNullOrEmpty(eventName))
        {
            button.CommandName = string.Format("{0}('{1}')", eventName, buttonData);
        }

        return button;
    }    
    
    /// <summary>
    /// Populates the grid with the list of stock lines
    /// User QSDisplayAccessor's WWardProductListLineAccessor and WProductQSProcessor
    /// </summary>
    /// <param name="grid">Grid to populate</param>
    /// <param name="stockLines">Lines to populate grid with</param>
    /// <param name="products">List of products for all stock lines</param>
    /// <param name="controller">Ward stock list controller</param>
    private void PopulateGrid(PharmacyGridControl grid, IEnumerable<WWardProductListLineRow> stockLines, IEnumerable<WProductRow> products, WardStockListController controller)
    {
        bool      printPickingTicket = controller.WardStockList.Any() ? controller.WardStockList[0].PrintPickTicket : false;
        int       siteID             = SessionInfo.SiteID;

        IQSDisplayAccessor[] accessors = new IQSDisplayAccessor[]{ new WWardProductListLineAccessor(controller.WardStockList.FirstOrDefault(), products, controller.MoneyDisplayType, printPickingTicket), 
                                                                   new WProductQSProcessor(controller.MoneyDisplayType) };
        BaseRow[] dataRows = new BaseRow[accessors.Length];

        // Remove existing rows
        while (grid.ColumnCount > 0)
            grid.RemoveColumn(0);
        grid.ClearRows();

        // Load in QS layout
        grid.QSLoadConfiguration       (siteID, "StockList", gridView);
        pnlRowPanel.QSLoadConfiguration(siteID, "StockList", leftPanelView);

        grid.AddColumnsQS();

        // Populate list with lines
        foreach(var line in stockLines.OrderByScreenPos())
        {
            if (line.LineType == WWardProductListLineType.Drug)
            {
                // Drug line so get product
                dataRows[0] = line;
                dataRows[1] = products.FindBySiteIDAndNSVCode(siteID, line.NSVCode);
                if (dataRows[1] != null)    
                {
                    grid.AddRowQS(dataRows, accessors);
                    grid.AddRowAttributesQS(pnlRowPanel.QSDisplayItems, dataRows, accessors);

                    grid.AddRowAttribute("DBID",     line.WWardProductListLineID.ToString() );
                    grid.AddRowAttribute("lineType", line.LineType.ToString()               );
                    grid.AddRowAttribute("NSVCode",  line.NSVCode                           );
                }
            }
            else
            {
                // title line
                grid.AddRow();
                grid.SetRowStyle("font-weight:bold;");
                grid.SetCell(0, line.ToString());

                grid.AddRowAttribute("DBID",     line.WWardProductListLineID.ToString() );
                grid.AddRowAttribute("lineType", line.LineType.ToString()               );
                grid.AddRowAttribute("NSVCode",  string.Empty                           );
            }
        }
    }
    
    /// <summary>
    /// Populates yellow and green panels
    /// Yellow panel mainly used for stock line items (updated client-side by labels as user moves up and down the list)
    /// Green panel used for the ward stock list properties so is mainly static apart from the total cost line.
    /// Uses QSDisplayAccessor's WWardProductListAccessor
    /// </summary>
    /// <param name="products"></param>
    private void PopulatePanels()
    {
        int siteID = SessionInfo.SiteID;

        // Setup the yellow row panel
        pnlRowPanel.QSLoadConfiguration(siteID, "StockList", leftPanelView);
        pnlRowPanel.SetColumnsQS();
        pnlRowPanel.AddNamedLabelsQS();

        // Populate the green list properties panel
        WWardProductListRow list = controller.WardStockList.FirstOrDefault();
        IQSDisplayAccessor[] accessors = new IQSDisplayAccessor[]{ new WWardProductListAccessor() };
        BaseRow[] dataRows = new BaseRow[] { list };

        pnlListPanel.QSLoadConfiguration(siteID, "StockList", rightPanelView);
        pnlListPanel.SetColumnsQS();
        if (list != null)
            pnlListPanel.AddLabelsQS(dataRows, accessors);
        else
            pnlListPanel.AddNamedLabelsQS();

        // Set the label name for the total cost lines (so can be updated client side)
        var qsTotalCost = pnlListPanel.GetLabelByQSPropertyName("{totalcost}");
        if (qsTotalCost != null)
            qsTotalCost.name = "{totalcost}";

        // Set panel height based on QSPanel value
        trPanels.Height = Math.Max(pnlListPanel.CalculatedHeightInPixelsQS(), pnlRowPanel.CalculatedHeightInPixelsQS()) + "px";

        hfNameForCSVFile.Value = (list == null ) ? string.Empty : list.Code + "_" + list.FullName.TrimEnd() + ".csv";

        // Update title on page
        upTitle.Update();
    }
    #endregion

    #region Web Methods
    /// <summary>
    /// Called when copy or cut is performed
    /// Returns the data to save the clipboard
    /// If cut removes the lines from the list's cached data.
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="mode">If cut or copy</param>
    /// <param name="controller">ward stock list controller</param>
    /// <returns>data to save the clipboard</returns>
    [WebMethod]
    public static string CopyCut(int sessionID, int siteID, string mode, WardStockListController controller)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        controller.LoadFromCache();
        
        // List of rows to copy
        var rowsToCopy = controller.WardStockListLines.FindByIDs( controller.MultiSelectLineIDs ).OrderBy( l => l.DisplayIndex ).ToList();
 
        // Copy rows to new list
        WWardProductListLine lines = new WWardProductListLine();
        lines.CopyFrom( rowsToCopy );
        
        // Clear last issue and to follow
        foreach (WWardProductListLineRow l in lines)
            l.ClearIssuingFields();

        // If cutting remove existing lines
        if (mode.EqualsNoCaseTrimEnd("Cut"))
        {
            var NSVCodes = lines.Select(l => l.NSVCode).Distinct();

            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(NSVCodes, SessionInfo.SiteID);

            controller.DeleteLines( rowsToCopy, product );
        }

        // Create clipboard JSON structure
        CopyPasteType copyPasteData = new CopyPasteType();
        copyPasteData.AscribeSiteNumber = SessionInfo.SiteNumber;
        copyPasteData.RowsXML           = lines.WriteXml();

        controller.returnData = JsonConvert.SerializeObject(copyPasteData);

        return controller.SaveToCache();
    }

    /// <summary>
    /// Returns if list of drugs
    ///     NSVCode - Line description
    /// That have open requisitions
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="controller">ward stock list controller</param>
    /// <returns></returns>
    [WebMethod]
    public static IEnumerable<string> HasOpenRequisitions(int sessionID, int siteID, WardStockListController controller)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        controller.LoadFromCache();

        // Get requisitions
        WRequis requis = new WRequis();
        var states = Settings.OutstandingRequisState;
        if (states.Any())
        {
            requis.LoadByWWardProductListLineAndState(controller.MultiSelectLineIDs, Settings.OutstandingRequisState.ToArray());
        }

        // Return list of drugs with open requisitions
        var NSVCodes = requis.Select(r => r.NSVCode).Distinct();
        var lines = controller.WardStockListLines;
        return NSVCodes.Select(r => r + " - " + lines.First(l => l.NSVCode == r).ToString());
    }

    /// <summary>
    /// Delete selected lines from the cached data
    /// Returns controller with newly selected lines
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="controller">ward stock list controller</param>
    /// <returns>Returns controller as JSON string</returns>
    [WebMethod]
    public static string Delete(int sessionID, int siteID, WardStockListController controller)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        controller.LoadFromCache();

        var linesToRemove = controller.WardStockListLines.FindByIDs( controller.MultiSelectLineIDs ).ToList();
        var NSVCodes      = linesToRemove.Select(l => l.NSVCode).Distinct();

        WProduct products = new WProduct();
        products.LoadByProductAndSiteID(NSVCodes, SessionInfo.SiteID);

        controller.DeleteLines( linesToRemove, products );

        return controller.SaveToCache();
    }

    /// <summary>
    /// Called when user moves lines up or down the grid
    /// Resorts the internal data structures
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="controller">ward stock list controller</param>
    /// <param name="rowIDs">lines to reorder (in required order)</param>
    [WebMethod]
    public static void UpdateOrder(int sessionID, int siteID, WardStockListController controller, int[] rowIDs)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        controller.LoadFromCache();

        Dictionary<int,WWardProductListLineRow> idToLine = controller.WardStockListLines.ToDictionary(r => r.WWardProductListLineID);

        List<WWardProductListLineRow> newOrder = new List<WWardProductListLineRow>(controller.WardStockListLines.Count);
        foreach(int id in rowIDs)
            newOrder.Add(idToLine[id]);

        newOrder.ResetScreenPositions();

        controller.SaveToCache();
    }

    /// <summary>
    /// Used to save the Pharmacy Log Viewer search criteria to the DB session cache (for user by the log viewer)
    /// Search criteria is for translog data from date to date for specified line for translog kinds specified by setting D|StockList.IssueLog.Kind
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">SiteID</param>
    /// <param name="controller">WardStockListController</param>
    /// <param name="WWardProductListLineID">Drug line to search for in the log</param>
    /// <param name="fromDate">optional from date (default is today - D|StockList.IssueLog.PeriodInDays (default 7))</param>
    /// <param name="toDate">optional to date else now</param>
    /// <returns></returns>
    [WebMethod]    
    public static string SaveLogViewerSearchCriteria(int sessionID, int siteID, WardStockListController controller, int WWardProductListLineID, DateTime? fromDate, DateTime? toDate)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        controller.LoadFromCache();
        
        WWardProductListLineRow line= controller.WardStockListLines.FindByID(WWardProductListLineID);
        DateTime                now = DateTime.Now;

        if (controller.MultiSelectLineIDs.Count() > 1)
            return "Only select a single line.";
        else if (line == null || line.LineType != WWardProductListLineType.Drug)
            return "Select a drug line.";
        else
        {
            // Set log viewer search criteria
            PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
            generalSettings.pharmacyLog     = PharmacyLogType.Translog;
            generalSettings.fromDate        = fromDate ?? now.AddDays(-Settings.IssueLogPeriodInDays).ToStartOfDay();
            generalSettings.toDate          = toDate   ?? now.ToEndOfDay(); // XN 124789 4Aug15 Changed to end of day to be on the safe side.
            generalSettings.useLogDateTime  = true;
            generalSettings.siteNumbers     = new [] { SessionInfo.SiteNumber };
            generalSettings.NSVCode         = line.NSVCode;
            generalSettings.moneyDisplayType= controller.MoneyDisplayType;
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings) );
            
            PharmacyDisplayLogRows.TranslogSearchCriteria translogSearchCriteria = new PharmacyDisplayLogRows.TranslogSearchCriteria();
            translogSearchCriteria.kinds = Settings.IssueLogKind.ToArray();
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria", JsonConvert.SerializeObject(translogSearchCriteria) ); 

            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns", Settings.IssueLogColumns);

            return string.Empty;
        }
    }

    /// <summary>
    /// Returns list of NSVCode that have the specified barcode (can be more than one).
    /// Will search primary and secondary barcode
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">SiteID</param>
    /// <param name="barcode">barcode to read</param>
    [WebMethod]
    public static string[] GetNSVCodesByBarcode(int sessionID, int siteID, string barcode)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
        ProductSearchType searchType = ProductSearchType.Barcode;
        WProduct product = ProductSearch.DoSearch(barcode, ref searchType, false);
        return product.Select(p => p.NSVCode).Distinct().ToArray();
    }

    /// <summary>
    /// Called when page is closed
    /// Removes the data from the cache
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">SiteID</param>
    /// <param name="controller">WardStockListController</param>
    [WebMethod]
    public static void CleanUp(int sessionID, int siteID, WardStockListController controller)
    {
        try
        {
            SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);
            controller.LoadFromCache();
            controller.Clear();
        }
        catch(Exception){ } // Fail silently as problems occur if user logs out from page (as data does not exist to cleanup)
    }
    #endregion
}