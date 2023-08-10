/*

FMStockAccountPopup.js


Specific script for the finanace manager popup window

*/

function form_onload() 
{
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
}  

function btnPrint_OnClick()
{
    var divSheet = $('[id$="divSheets"]');
    var parameters = GetStockAccountPrintData (divSheet);
    var result = PostServerMessage('FMStockAccountPopup.aspx/SaveReportForPrinting', JSON.stringify(parameters));
    if (result != undefined) 
        window.dialogArguments.icwwindow.document.frames['fraPrintProcessor'].PrintReport(sessionID, result.d, 0, false, '');
}

// 84572 Added Export to CSV button XN 27Oct14         
function btnExportToCSV_OnClick()
{
    var divSheet = $('[id$="divSheets"]');
    var csv      = ConvertStockAccountToCSV ( divSheet );
    document.frames['fraSaveAs'].SetSaveAsData('Stock Balance Sheet.csv', csv);
}

// Replacement for ICW_FinanceManager.js GetSheetSettings
function GetSheetSettings(sheetID)
{
    var sheetDiv = $('div[SheetID="' + sheetID + '"]');                    
    return GetSettings(sheetDiv.attr('Settings'));
}    