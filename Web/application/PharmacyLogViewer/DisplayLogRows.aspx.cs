//===========================================================================
//
//							      DisplayLogRows.aspx.cs
//
//  Provides a way to search for and display rows from pharmacy logs 
//  The control only displays rows from Worderlog or WTranslog, and does NOT provide 
//  a UI for the user to change the search criteria.
//
//  The page provides a replacement for vb6 LogView.bas (method NewUserLogViewer)
//
//  To perform a search on a log, need to fill in structure PharmacyDisplayLogRows.GeneralSearchCriteria
//  plus either 
//      PharmacyDisplayLogRows.OrderlogSearchCriteria       - If searching WOrderlog
//      PharmacyDisplayLogRows.TranslogSearchCriteria       - If searching WTranslog
//      PharmacyDisplayLogRows.CombinedLogSearchCriteria    - If searching both logs
//      PharmacyDisplayLogRows.PharmacyLogSearchCriteria    - If searching WPharmacyLog
//  When defining search criteria, you don't need to provide all criteria but must provide at least
//      GeneralSearchCriteria.fromDate
//      GeneralSearchCriteria.toDate
//      GeneralSearchCriteria.moneyDisplayType
//  There is also an optional parameter to define the columns to display in the log (see PharmacyGridControl for details)
//
//  To use the page you need to save the search criteria (defined by structures in DisplayLogRow) 
//  to the ICW SessionAttribute table as a JSON string, save the data as follows
//  Key to save to SessionAttribute table       Search Critera structure to save
//  -------------------------------------       --------------------------------
//  Pharmacy.LogViewer.GeneralSearchCriteria    PharmacyDisplayLogRows.GeneralSearchCriteria
//  Pharmacy.LogViewer.LogSearchCriteria        PharmacyDisplayLogRows.OrderlogSearchCriteria
//                                              PharmacyDisplayLogRows.TranslogSearchCriteria
//                                              PharmacyDisplayLogRows.CombinedLogSearchCriteria
//                                              PharmacyDisplayLogRows.PharmacyLogSearchCriteria
//  Pharmacy.LogViewer.Columns                  Columns to display from the orderlog or translog 
//                                              See PharmacyGridControl for details (can be empty to use default)
//  The search criteria will be cached until the web page is called.
//
//  After the search criteria have been saved the page should be called with the following parmeters
//      SessionID - ICW session ID
//      SiteNumber- Ascribe site number
// 
//  Usage:
//  Search both WOrderlog, and WTranslog
//  On server side
//  PharmacyDisplayLogRows.GeneralSearchCriteria generalCriteria = new PharmacyDisplayLogRows.GeneralSearchCriteria();
//  generalCriteria.pharmacyLog     = PharmcyLogType.Unknown;
//  generalCriteria.fromDate        = DateTime.Now.AddMonth(-1);
//  generalCriteria.toDate          = DateTime.Now;
//  generalCriteria.siteNumbers     = new [] { 503 };
//  generalCriteria.NSVCode         = "DUV432F";
//  generalCriteria.moneyDisplayType= MoneyDisplayType.Show;
//
//  PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalCriteria)                                         );
//  PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria",      JsonConvert.SerializeObject(new PharmacyDisplayLogRows.CombinedLogSearchCriteria())  );
//  PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns",                WFMSettings.StockAccountSheet.LogViewerColumns                                       );
//
//  On client side
//  var newParemters = '';
//  newParemters += '?SessionID='  + sessionID.toString();
//  newParemters += '&SiteNumber=' + data.siteNumbers.split(",")[0];
//  window.showModalDialog("../PharmacyLogViewer/DisplayLogRows.aspx" + newParemters, undefined, 'center:yes; status:off');            
//
//	Modification History:
//  05Jul13 XN  Written 27252
//  09Jun14 XN  Added display of WPharmacyLog 
//  28Aug14 XN  Got load to use new SessionInfo method so can handle site number or ID 88922
//  21Jan15 XN  Improved size calculation of form 108627
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class application_PharmacyLogViewer_DisplayLogRows : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get search criteria from SessionAttribute table
        string generalCriteriaStr  = PharmacyDataCache.GetFromDBSession("Pharmacy.LogViewer.GeneralSearchCriteria");
        string logCriteriaStr      = PharmacyDataCache.GetFromDBSession("Pharmacy.LogViewer.LogSearchCriteria");
        string logViewerColumns    = PharmacyDataCache.GetFromDBSession("Pharmacy.LogViewer.Columns");

        if (string.IsNullOrEmpty(generalCriteriaStr))
            throw new ApplicationException("Need to specify GeneralSearchCriteria and save it to Session.Attribute with key Pharmacy.LogViewer.GeneralSearchCriteria");

        PharmacyDisplayLogRows.GeneralSearchCriteria generalCriteria = JsonConvert.DeserializeObject<PharmacyDisplayLogRows.GeneralSearchCriteria> (generalCriteriaStr);

        // Populate grid
        switch (generalCriteria.pharmacyLog)
        {
        case PharmacyLogType.Orderlog: 
            PharmacyDisplayLogRows.OrderlogSearchCriteria orderlogCriteria = new PharmacyDisplayLogRows.OrderlogSearchCriteria();
            if (!string.IsNullOrEmpty(logCriteriaStr))
                orderlogCriteria = JsonConvert.DeserializeObject<PharmacyDisplayLogRows.OrderlogSearchCriteria>(logCriteriaStr);
            logRows.Initalise(generalCriteria, orderlogCriteria, logViewerColumns); 
            break;

        case PharmacyLogType.Translog: 
            PharmacyDisplayLogRows.TranslogSearchCriteria translogCriteria = new PharmacyDisplayLogRows.TranslogSearchCriteria();
            if (!string.IsNullOrEmpty(logCriteriaStr))
                translogCriteria = JsonConvert.DeserializeObject<PharmacyDisplayLogRows.TranslogSearchCriteria>(logCriteriaStr);
            logRows.Initalise(generalCriteria, translogCriteria, logViewerColumns); 
            break;

        case PharmacyLogType.PharmacyLog:
            PharmacyDisplayLogRows.PharmacyLogSearchCriteria pharmacylogCriteria = new PharmacyDisplayLogRows.PharmacyLogSearchCriteria();
            if (!string.IsNullOrEmpty(logCriteriaStr))
                pharmacylogCriteria = JsonConvert.DeserializeObject<PharmacyDisplayLogRows.PharmacyLogSearchCriteria>(logCriteriaStr);
            logRows.Initalise(generalCriteria, pharmacylogCriteria, logViewerColumns); 
            break;

        case PharmacyLogType.Unknown : 
            PharmacyDisplayLogRows.CombinedLogSearchCriteria combinedCriteria = new PharmacyDisplayLogRows.CombinedLogSearchCriteria();
            if (!string.IsNullOrEmpty(logCriteriaStr))
                combinedCriteria = JsonConvert.DeserializeObject<PharmacyDisplayLogRows.CombinedLogSearchCriteria>(logCriteriaStr);
            logRows.Initalise(generalCriteria, combinedCriteria, logViewerColumns);  
            break; 
        }

        // Clear items from SessionAttribute table
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",   String.Empty);
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria",       String.Empty);
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns",                 String.Empty);
    }
}
