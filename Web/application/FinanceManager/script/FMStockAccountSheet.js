/*

FMStockAccountSheet.js


Specific script for the Stock Account control (Controls\FMStockAccountSheet.ascx).
file also depends on functions int ICW_FinanceManager.js

*/

// Called when user clicks drug label
// Displays drug selection screen 
// Then calls ICW_FinanceManager.aspx/UpdateSheet to create the sheet
function lbDrug_OnClick(sheetID) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Displays the suppliers details window
    var info = window.showModalDialog("../PharmacyProductSearch/PharmacyProductSearchModal.aspx" + strURLParameters, undefined, 'center:yes; status:off');
    if (info == 'logoutFromActivityTimeout') {
        info = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (info)
    {
        // Get selected drug info
        var selectDrugInfo = info.split('|');
        if (selectDrugInfo.length >= 3)
            UpdateStockAccountSheet(sheetID, selectDrugInfo[2]);
    }
}

function stockAccountSheetRow_OnDblClick(sheetID, wfmBalanceSheetLayoutID)
{
    // 27Oct14 XN  Now save settings to context via SaveFMSettings web method to fix issue if settings struct is very big then can't pass in on query
    var data = {
                  sessionID: sessionID,
                  settings : GetSheetSettings(sheetID)
               }
    PostServerMessage('FMStockAccountDrillDown.aspx/SaveFMSettings', JSON.stringify(data));                

    var newParemters = '';
    newParemters += '?SessionID=' + sessionID;
    newParemters += '&WFMStockAccountSheetLayoutID=' + wfmBalanceSheetLayoutID;

    // Displays the drill down screen
    var objArgs = new Object();
    objArgs.icwwindow = ICWWindow();
    var ret = window.showModalDialog("FMStockAccountDrillDown.aspx" + newParemters, objArgs, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

// Called when used clicks a mount button on a row in the stock account table
// If right click button show context menu
// Contect menu selection is handled by PopMenu_ItemSelected
function stockAccountTable_onmousedown(tr)
{
    if (window.event.button == 2)
    {
        ID_selectedForEdit = $(tr).attr('id');
        
	    var objPopup = new ICWPopupMenu();		
	    objPopup.AddItem('Edit section...', MNU_EDIT_SECTION, true);		
	    objPopup.Show(window.event.screenX, window.event.screenY);
    }
}

// Called from right click context (on stock balance sheet)
function PopMenu_ItemSelected(selIndex, selDesc) 
{		
	switch (selIndex)
	{
	case MNU_EDIT_SECTION: PopMenu_EditSection(); break;
	}
}
		
// Called when user selects "Edit Section..." in the right click context menu
// Displays account sheet layout editor, and then refresh stock balance sheet with updates made to layout
// uses method from FinanceManagerSettings\scripts\FMStockAccountSheetLayoutEditor.js
function PopMenu_EditSection()
{
    // Get selected tab
    var tabButtons  = $find("tabButtons");
    var selectedTab = tabButtons.get_selectedTab();
    var sheetID     = selectedTab.get_attributes().getAttribute("SheetID");

    // Get section type
    var sectionType = $('div[SheetID="' + sheetID + '"] tr[id="' + ID_selectedForEdit + '"]').attr('SectionType');
    
    // Display balance sheet editor (uses FinanceManagerSettings\scripts\FMStockAccountSheetLayoutEditor.js)
    var updateID;
    if (sectionType == sectionType_AccountSection)
        updateID = DisplayEditor('FMStockAccountSheetSubSection.aspx', ID_selectedForEdit, undefined, undefined);
    else
        updateID = DisplayEditor('FMStockAccountSheetSection.aspx', ID_selectedForEdit, undefined, undefined);
        
    // If chances made then update sheet.                
    if (updateID != undefined)
    {                
        var settings = GetSheetSettings(sheetID);            
        UpdateStockAccountSheet(sheetID, settings.NSVCode);                            
    }
}
		
// Called when user clicks next\previous buttons on a blance sheet
// Move the balance sheet to through the drugs 
function UpdateStockAccountSheet(sheetID, NSVCode) 
{
    // Get the balance sheet original setting
    // need to manually reparse the dates and times, as JSON.parse does not do this correctly
    var sheetDiv = $('div[SheetID="' + sheetID + '"]');                    
    var settings = JSON.parse(sheetDiv.attr('Settings'));                
    settings.startDate = new Date(parseInt(settings.startDate.substr(6)));
    settings.endDate   = new Date(parseInt(settings.endDate.substr  (6)));
    
    // Set the selected drug ID
    settings.NSVCode = NSVCode;
    
    // Get the balance sheet
    var data = {
                  sessionID: sessionID,
                  settings : settings
               }
               
    info = PostServerMessage('ICW_FinanceManager.aspx/CreateStockAccountSheet', JSON.stringify(data));                
    if (info)
    {
        // Get list of sections that are already open
        var openRows      = $('div[SheetID="' + sheetID + '"] tr[openRow="true"]');
        var openParentIDs = $.map(openRows, function(tr) { return tr.getAttribute('id'); } );
                                
        // REplace the sheet                                                
        $('div[SheetID="' + sheetID + '"]').replaceWith(XMLUnescape(info.d.sheetData));
        
        // Minimise all sections then reopen the ones that were already open
        stockAccountSheeMinimiseAllSections(sheetID);
        for(var i = 0; i < openParentIDs.length; i++)
            stockAccountSheetToggleSection(sheetID, openParentIDs[i]);
    }
}

// Called when account section expand button is clicked
// Expands or hides a section
function stockAccountSheetToggleSection(uniqueId, id) 
{
    var tr  = $('div[SheetID="' + uniqueId + '"] tr[id=' + id + ']')
    var open = parseBoolean(tr.attr('openRow'));
    var childRows = $('tr[id_parent=' + id + ']', tr[0].parentNode);

    if (!open) 
    {
        childRows.show();
        tr.attr('openRow', 'true');
        $('img:eq(0)', tr).attr('src', '../../images/grid/imp_closed.gif');
//                $('#table-value', tr).hide();
    }
    else 
    {
        childRows.hide();
        tr.attr('openRow', 'false');
        $('img:eq(0)', tr).attr('src', '../../images/grid/imp_open.gif');
//                $('#table-value', tr).show();
    }
}

// 
function ViewLabUtils(sheetID)
{
    // Save the log viewer settings to the SessionAttribute DB table
    var data = 
    {
        sessionID:  sessionID,
        settings:   GetSheetSettings(sheetID)
    }
    PostServerMessage('ICW_FinanceManager.aspx/SaveLogViewerSearchCriteria', JSON.stringify(data));

    // Display the pharmacy log
    var newParemters = '';
    newParemters += '?SessionID='         + sessionID.toString();
    //newParemters += '&SiteNumber=' + data.settings.siteNumbers[0]; XN 28Aug14 88922 changeded to AscribeSitenumber
    newParemters += '&AscribeSiteNumber=' + data.settings.siteNumbers[0];
   var ret= window.showModalDialog("../PharmacyLogViewer/DisplayLogRows.aspx" + newParemters, undefined, 'center:yes; status:off');
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

// Minimise all sections in the sheet
function stockAccountSheeMinimiseAllSections(sheetID)
{
    $('div[SheetID="' + sheetID + '"] tr[id_parent]').hide();
}

function GetStockAccountPrintData(selectedSheet)
{
    return {    sessionID:      parseInt(sessionID),
                title:          $('[id$="lbHeading"]', selectedSheet).text(),
                hospitalName:   $('[id$="lbHospitalNam"]', selectedSheet).text(),
                setting:        $('[id$="lbSites"]', selectedSheet).text() + '\n' + $('[id$="lbDatePeriod"]', selectedSheet).text(),
                drug:           $('[id$="lbDrug"]', selectedSheet).text(),
                grid:           MarshalRows($('[id$="table"]', selectedSheet)),
                warning:        $('[id$="divRebuildWarning"]', selectedSheet).text(),
                reportName:     'Finance Manager Stock Account Report'
           };
}

// Expands or collapses all sheet sections
function ExpandAll(uniqueId, expand)
{
    var closedRows = $('div[SheetID="' + uniqueId + '"] tr[openRow="' + !expand + '"]');
    for(var c = 0; c < closedRows.length; c++)
        stockAccountSheetToggleSection(uniqueId, closedRows.eq(c).attr('id'));
}

// Convert the sheet data to CSV string#
// 27Oct14 XN 84572
function ConvertStockAccountToCSV(selectedSheet)
{
    var cr = String.fromCharCode(13);   // row separator characters

    // Get heading info
    var info = $('[id$="lbHeading"]',    selectedSheet).text() + cr + cr +
               $('[id$="lbSites"]',      selectedSheet).text() + cr +
               $('[id$="lbDatePeriod"]', selectedSheet).text() + cr +
               $('[id$="lbDrug"]',       selectedSheet).text() + cr;

    // Convert to table to CSV string
    var gridStr = ConvertTableToCSV( $('[id$="table"]', selectedSheet) );

    return info + cr + gridStr + cr;
}
