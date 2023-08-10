/*

FMAccountSheet.js


Specific script for the Account Enquiry control (Controls\FMAccountSheet.ascx).
file also depends on functions in ICW_FinanceManager.js

*/

// called when account Enquiry row is double clicked
// displays log view for the row
function asRow_OnDblClick(sheetID, row)
{
    if ($(row).attr('rowType') != 'value')
        return;

    var settings = GetSheetSettings(sheetID);
    
    // Save the log viewer search criteria to the SessionAttribute DB table
    var data = {
                  sessionID  : sessionID,
                  settings   : settings,
                  siteNumber : $(row).prop('siteNumber'),
                  NSVCode    : $(row).prop('NSVCode')
               }
    PostServerMessage('ICW_FinanceManager.aspx/SaveAccountLogViewerSearchCriteria', JSON.stringify(data));

    // Display the pharmacy log viewer
    var newParemters = '';
    newParemters += '?SessionID='         + sessionID.toString();
    //newParemters += '&SiteNumber=' + settings.siteNumbers[0].toString(); XN 28Aug14 88922 changeded to AscribeSitenumber
    newParemters += '&AscribeSiteNumber=' + settings.siteNumbers[0].toString();
    var ret=window.showModalDialog("../PharmacyLogViewer/DisplayLogRows.aspx" + newParemters, undefined, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

function ResizeAccountSheet(selectedSheet)
{
    var table        = $('#divTable', selectedSheet);
    var totalHeight  = $('#divSheets').height();
    var top          = table.offset().top;
    var warningHeight= $('#divRebuildWarning', selectedSheet).height();
    var tableHeight  = totalHeight - top + 15 - warningHeight - 25;

    if (tableHeight < 0)
        tableHeight = 0;

    table.height(tableHeight);

    var topPos = (table[0].scrollTop - 2).toString() + 'px';
    $('.fm-as-table-header1',          selectedSheet).css({ top: topPos });
    $('.fm-as-table-header2',          selectedSheet).css({ top: topPos });
    $('.fm-as-table-header-emptycell', selectedSheet).css({ top: topPos });
}

function GetAccountPrintData(selectedSheet)
{
    return {    sessionID:      parseInt(sessionID),
                title:          $('#lbHeading', selectedSheet).text(),
                hospitalName:   $('#lbHospitalNam', selectedSheet).text(),
                setting:        $('#lbSites', selectedSheet).text() + '\n' + $('#lbDatePeriod', selectedSheet).text(),
                drug:           '',
                grid:           MarshalRows($('#table', selectedSheet)),
                warning:        $('#divRebuildWarning', selectedSheet).text(),
                reportName:     'Finance Manager Account Report'
           };
}

// Convert the sheet data to CSV string
// 27Oct14 XN 84572
function ConvertAccountToCSV(selectedSheet)
{
    var cr = String.fromCharCode(13);   // row separator characters

    // Get heading info
    var info = $('#lbHeading',    selectedSheet).text() + cr + cr +
               $('#lbSites',      selectedSheet).text() + cr +
               $('#lbDatePeriod', selectedSheet).text() + cr;

    // Convert to table to CSV string
    var gridStr = ConvertTableToCSV( $('#table', selectedSheet) );

    return info + cr + gridStr + cr;
}
