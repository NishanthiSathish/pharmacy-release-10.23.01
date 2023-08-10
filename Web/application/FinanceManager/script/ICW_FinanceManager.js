/*

ICW_FinanceManager.js


Specific script for the finanace manager.

*/

function form_onload() 
{
    Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
}  

// Called when add stock balance sheet button is clicked
// Then calls ICW_FinanceManager.aspx/CreateStockAccountSheet to create the sheet
function btnAddStockAccountSheet_OnClick() 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);        
    
    addSheet("FMAddStockAccountSheet.aspx" + strURLParameters, "CreateStockAccountSheet");
}

// Called when add account Enquiry button is clicked
// Then calls ICW_FinanceManager.aspx/CreateAccountSheet to create the sheet
function btnAddAccountSheet_OnClick()
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);        
    
    addSheet("FMAddAccountSheet.aspx" + strURLParameters, "CreateAccountSheet");
}

// Called when add GRNI sheet button is clicked
// Then calls ICW_FinanceManager.aspx/CreateGrniSheet to create the sheet
function btnAddGRNISheet_OnClick()
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);        
    
    addSheet("FMAddGRNISheet.aspx" + strURLParameters, "CreateGrniSheet");
}

// Called when remove button is clicked
// Removes sheet and tab, plus calls ICW_FinanceManager.aspx/RemoveSheet to remove sheet data
function btnRemoveSheet_OnClick() 
{
    // Get selected tab
    var tabButtons  = $find("tabButtons");
    var selectedTab = tabButtons.get_selectedTab();
    if (selectedTab == null)    
        return; // Null if not tabs left
        
    var uniqueID= selectedTab.get_attributes().getAttribute("SheetID");

    tabButtons.trackChanges();
    
    // Remove tab and sheet
    tabButtons.get_tabs().remove(selectedTab);
    $('div[SheetID="' + uniqueID + '"]').remove();

    tabButtons.commitChanges();

    // Resetelct first sheet
    if ($('div[SheetID]').length > 0)
        SelectSheet($('div[SheetID]').eq(0).attr("SheetID"));
}

function btnPrint_OnClick()
{
    var selectedSheet = getSelectedSheet();
    if (selectedSheet == null)
        return;
    
    var table = $('[id$="table"]', getSelectedSheet());
    
    switch (selectedSheet.attr('id'))
    {
    case 'pnGRNIPanel'   :      var parameters = GetGRNIPrintData         (selectedSheet); break;
    case 'pnAccountPanel':      var parameters = GetAccountPrintData      (selectedSheet); break;
    case 'pnStockAccountPanel': var parameters = GetStockAccountPrintData (selectedSheet); break;
    }    

    var result = PostServerMessage('ICW_FinanceManager.aspx/SaveReportForPrinting', JSON.stringify(parameters));

    if (result != undefined) 
        ICWWindow().document.frames['fraPrintProcessor'].PrintReport(sessionID, result.d, 0, false, '');
}

// Called when tab selected (redisplays a sheet)
function tabSelected(sender, eventArgs) 
{
    var uniqueID = eventArgs.get_tab().get_attributes().getAttribute("SheetID");

    HideSheets();
    SelectSheet(uniqueID);
}

// called when page resizes
// resizes the stock account panels so at max height
function body_onResize() 
{
    var panel       = $('#divSheets');
    var totalHeight = $(window).height();
    var footerHeight= $('div[id$="pnFooter"]').height();
    var top         = panel.offset().top;
    var sheetHeight = totalHeight - top - footerHeight - 50;

    if (sheetHeight < 0)
        sheetHeight = 0;
    panel.height(sheetHeight);

    // resize selected sheet
    ResizeSelectedSheet();
}
        
// Displays the Add Sheet form (defined by url addFormUrl)
// Then with the settings returned by the sheet calls the ICW_FinanceManager.aspx/{webMethodName}
// The data returned from the web method is added as another form
function addSheet(addFormUrl, webMethodName) 
{
    // Displays the Add stock balance sheet options
    var infoStr = window.showModalDialog(addFormUrl, undefined, 'center:yes; status:off');
    if (infoStr == 'logoutFromActivityTimeout') {
        infoStr = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (infoStr)
    {
        // parse the WFMStockAccountSheetSettings returned from FMAddAccountSheet.aspx
        // need to manualy reparse the dates and times, as JSON.parse does not do this correctly
        var settings = JSON.parse(infoStr);
        if (settings.startDate != undefined)             
            settings.startDate = new Date(parseInt(settings.startDate.substr(6)));
        if (settings.endDate != undefined)             
            settings.endDate = new Date(parseInt(settings.endDate.substr(6)));
        if (settings.upToDate != undefined)             
            settings.upToDate = new Date(parseInt(settings.upToDate.substr(6)));
        
        // Get the balance sheet
        var data = { 
                     sessionID: sessionID,
                     settings:  settings
                   }                
        var sheetInfo = PostServerMessageExtendedTimeout('ICW_FinanceManager.aspx/' + webMethodName, JSON.stringify(data), 5 * 60 * 1000 /* 5mins */);
        if (sheetInfo)
            AddSheet(sheetInfo.d.uniqueID, sheetInfo.d.name, XMLUnescape(sheetInfo.d.sheetData));
    }
}

// Add stock balance sheet to page
function AddSheet(sheetId, name, newSheet) 
{
    // hide all existing sheets
    HideSheets();

    // add sheet 
    $('div[id$="divSheets"]').append(newSheet);

    // add tab for sheet
    var tabButtons = $find("tabButtons")
    tabButtons.trackChanges();
    var tab = new Telerik.Web.UI.RadTab();
    tab.get_attributes().setAttribute("SheetID", sheetId);
    tab.set_text(name);
    tabButtons.get_tabs().add(tab);
    tab.scrollIntoView();           // 08Jul13 XN 65597 add scrolling of tabs
    tabButtons.commitChanges();

    // Minimise all sections in the sheet
    stockAccountSheeMinimiseAllSections(sheetId);
    
    // Select newly added sheet
    SelectSheet(sheetId);
    
    ResizeSelectedSheet();
}

// Returns the div for the currently selected sheet        
function getSelectedSheet()
{
    var tabButtons  = $find("tabButtons");
    if (tabButtons == null)    
        return null;
        
    var selectedTab = tabButtons.get_selectedTab();
    if (selectedTab == null)    
        return null;

    var uniqueID= selectedTab.get_attributes().getAttribute("SheetID");
    return $('div[SheetID="' + uniqueID + '"]');
}

// Gets the settings for the sheet (will also correct the datetime issue when parsing the JSON.
function GetSheetSettings(sheetID)
{
    var sheetDiv = $('div[SheetID="' + sheetID + '"]');                    
    return GetSettings(sheetDiv.attr('Settings'));
}

// Select a sheet
function SelectSheet(uniqueID) 
{
    var tab = $find("tabButtons").findTabByAttribute('SheetID', uniqueID);
    if (tab != undefined) 
    {
        tab.select();
        tab.scrollIntoView();   // 08Jul13 XN 65597 add scrolling of tabs
        $('div[SheetID="' + uniqueID + '"]').show();                
        
        ResizeSelectedSheet();
    }
}

// hides all sheets
function HideSheets() 
{
    $('div[SheetID]').hide();
}

function ResizeSelectedSheet()
{
    var selectedSheet = getSelectedSheet();
    if (selectedSheet == null)
        return;

    switch (selectedSheet.attr('id'))
    {
    case 'pnGRNIPanel'   : ResizeGRNISheet(selectedSheet);    break;
    case 'pnAccountPanel': ResizeAccountSheet(selectedSheet); break;
    }               
}
        
// jquery ajax server call
function PostServerMessageExtendedTimeout(url, data, timeout)
{
    var result;
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        timeout: timeout,
        success: function(msg) 
        {
            result = msg;
        },
        error: function(jqXHR, textStatus, errorThrown) 
        {
            if (textStatus == 'error') 
                alert('Failed due to error\r\n\r\n' + jQuery.parseJSON(jqXHR.responseText).Message);
        }
    });
    return result;
}

// 84572 Added Export to CSV button XN 27Oct14         
function btnExportToCSV_OnClick()
{
    var selectedSheet = getSelectedSheet();
    if (selectedSheet == null)
        return;

    // Convert to CSV
    switch (selectedSheet.attr('id'))
    {
    case 'pnGRNIPanel'   :      var csv = ConvertGRNIToCSV         (selectedSheet); break;
    case 'pnAccountPanel':      var csv = ConvertAccountToCSV      (selectedSheet); break;
    case 'pnStockAccountPanel': var csv = ConvertStockAccountToCSV (selectedSheet); break;
    }

    // Get sheet name
    var nameOfSheet = $find("tabButtons").get_selectedTab().get_text();

    // Perform save as
    document.frames['fraSaveAs'].SetSaveAsData(nameOfSheet + '.csv', csv);
}