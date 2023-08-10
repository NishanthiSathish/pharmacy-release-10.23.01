/*

FMStockAccountDrillDown.js


Specific script for the Finance Manager stock account drill down page.

*/

// Called when export to CSV button is clicked
// splits table up into CSV, and the calls SaveAs.aspx to ask user where to save the file
function btnExportToCSV_OnClick() 
{
    var headingInfo = '';
    var cr = String.fromCharCode(13);   // row separator characters

    // Get heading info
    headingInfo += $('#lbHeading').text()   + cr;
    headingInfo += $('#lbSites').text()     + cr;
    headingInfo += $('#lbDatePeriod').text()+ cr;
    headingInfo += $('#lbDrug').text()      + cr;

    // Convert to table to CSV string
    var gridStr = ConvertTableToCSV( $('#table') );

    // Perform save as
    document.frames['fraSaveAs'].SetSaveAsData($('#lbHeading').text() + '.csv', headingInfo + gridStr + cr);
}

// When row double clicked display the log veiwer
function row_OnDblClick(row) 
{
    var siteNumbers = $(row).prop('SiteNumbers');
    var wardSupCode = $(row).prop('WardSupCode');
    var NSVCode     = $(row).prop('NSVCode');

    if (summaryPage && !discrepancies)
        DisplayStockAccountPopup(NSVCode);
    else
        DisplayLogViewer(siteNumbers, wardSupCode, NSVCode);
}

// Called when print button is clicked
function btnPrint_OnClick()
{
    var parameters = {    sessionID:      sessionID,
                          title:          $('#lbHeading').text(),
                          setting:        $('#lbSites').text() + '\n' + $('#lbDatePeriod').text() + '\n' + $('#lbDrug').text(),
                          grid:           MarshalRows($('#table')),
                          reportName:     'Finance Manager Stock Account Drill Down Report'
                     };    
    var result = PostServerMessage('FMStockAccountDrillDown.aspx/SaveReportForPrinting', JSON.stringify(parameters));
    if (result != undefined) 
        window.dialogArguments.icwwindow.document.frames['fraPrintProcessor'].PrintReport(sessionID, result.d, 0, false, '');
}

// Displays the log view 
function DisplayLogViewer(siteNumbers, wardSupCode, NSVCode)
{
    // Save the log viewer settings to the SessionAttribute DB table
    var data = 
    {
        sessionID:                      sessionID,
        settings:                       GetSettings(sheetSettingsStr),
        wfmStockAccountSheetLayoutID:   wfmStockAccountSheetLayoutID,
        siteNumbers:                    siteNumbers,
        wardSupCode:                    wardSupCode,
        NSVCode:                        NSVCode
    }
    PostServerMessage('FMStockAccountDrillDown.aspx/SaveLogViewerSearchCriteria', JSON.stringify(data));

    // Display the pharmacy log
    var newParemters = '';
    newParemters += '?SessionID='         + sessionID.toString();
    //newParemters += '&SiteNumber=' + settings.siteNumbers[0].toString(); XN 28Aug14 88922 changeded to AscribeSitenumber
    newParemters += '&AscribeSiteNumber=' + data.siteNumbers.split(",")[0];
    var ret=window.showModalDialog("../PharmacyLogViewer/DisplayLogRows.aspx" + newParemters, undefined, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

// Displays stock account popup 
function DisplayStockAccountPopup(NSVCode)
{
    var setting = GetSettings(sheetSettingsStr);
    if (NSVCode != undefined && NSVCode != '')
        setting.NSVCode = NSVCode;

    // 27Oct14 XN  Now save settings to context via SaveFMSettings web method to fix issue if settings struct is very big then can't pass in on query
    var data = {
                  sessionID: sessionID,
                  settings : setting
               }
    PostServerMessage('FMStockAccountPopup.aspx/SaveFMSettings', JSON.stringify(data));

    var newParemters = '';
    newParemters += '?SessionID=' + sessionID.toString();
    var ret=window.showModalDialog("FMStockAccountPopup.aspx" + newParemters, window.dialogArguments, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}
