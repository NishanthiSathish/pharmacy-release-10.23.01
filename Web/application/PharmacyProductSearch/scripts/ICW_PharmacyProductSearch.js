/*

								ICW_PharmacyProductSearch.js


	Specific script for the ICW_PharmacyProductSearch frame.

*/

var lastRowSiteProductDataID = undefined;
var timerHandle              = undefined;
var gridSearchString               = '';
var lastSearchTime           = new Date();

function body_onload()
{
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
    EndRequestHandler();
}

// Called when key is pressed in from
// if ESC key performs same operation as cancel button
// if OK key performs same operation as ok button
function body_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 27: btnCancel_click(); break;  // ESC (close the form only works when page is called as modal dialog)
    case 13: btnOK_click();     break;  // Enter (close the form setting return value)  
    case 66:                            // Alt+B (toggles between BNF view)
        if (allowBNF && event.altKey)
            __doPostBack('updatePanel', 'ToggleBNFDisplay');
        break;
    }
}

// Called when key is pressed in the grid
// if is char key performs search calling performGridSearch
// 05May15 XN 40374
function grid_onkeydown(event)
{
    // test for altKey to filter out Alt+B to move to BNF view
    if (48 <= event.keyCode && event.keyCode <= 90 && !event.altKey)
        performGridSearch(String.fromCharCode(event.keyCode));
}

// Called when row is selected in the grid
// if row index has not changed after 0.25 secs will update the labels in the gird
function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    var rowSiteProductDataID = getSelectedRow('gcSearchResults').attr('SiteProductDataID');
    
    if (lastRowSiteProductDataID == rowSiteProductDataID)
    {
        if (timerHandle != undefined)
        {
            clearInterval(timerHandle);
            timerHandle = undefined;
        }
        
        UpdateLabels(rowSiteProductDataID);        
    }
    else if(timerHandle == undefined)
        timerHandle = setInterval(function() { pharmacygridcontrol_onselectrow('gcSearchResults', -1); }, 250);
        
    lastRowSiteProductDataID = rowSiteProductDataID;
}

// Updates the label at the bottom of the screen
function UpdateLabels(rowSiteProductDataID)
{
    if (rowSiteProductDataID != undefined)
    {
        // Get XML and populate panel
        var xml = $('#xmlRowData')[0];        
        $('Row[SiteProductDataID="'+ rowSiteProductDataID + '"]', xml).children().each(function() 
        { 
            if (this.attributes.getNamedItem("isHTML") != null)
                setPanelLabelHtml('lpcProductDetail', this.tagName, this.text); 
            else
                setPanelLabel('lpcProductDetail', this.tagName, this.text); 
        });

        // If embeded mode raise ICW event that product selected
        if (embeddedMode && window.parent.PharmacyProductSelected != undefined)
        {
            var NSVCode     = $('Row[SiteProductDataID="' + rowSiteProductDataID + '"] NSVCode', xml).text()
            var rowIndex    = getRowIndexByAttribute('gcSearchResults', 'SiteProductDataID', rowSiteProductDataID);
            var description = getCell('gcSearchResults', rowIndex, 0).text().replace('|', ' ');
            window.parent.PharmacyProductSelected(NSVCode, rowSiteProductDataID, description);
        }
    }
    else    
    {
        // No row selected so clear bottom panel
        clearLabels('lpcProductDetail')

        // If embeded mode raise ICW event that product selection cleared
        if (embeddedMode && window.parent.PharmacyProductSelectionCleared != undefined)        
            window.parent.PharmacyProductSelectionCleared();
    }
}

// Handles key presses on the search text box
function tbSearch_onkeydown(event)
{
    switch (event.keyCode)  // Check which key was pressed
    {
    case 13:    // Clicks search button
        window.event.cancelBubble = true;
        window.event.returnValue = false;
        $('#btnSearch').click();
        break;
    case 66:    // Alt+B (toggles between BNF view)
        if (event.altKey) 
        {
            event.cancelBubble = true;
            event.returnValue  = false;
            __doPostBack('updatePanel', 'ToggleBNFDisplay');
        }
        break;
    }
}

// Called when ok button is clicked 
// Sets return value SiteProductDataID|Description|NSVCode, and closes from
function btnOK_click()
{
    var selectedRow = getSelectedRow('gcSearchResults');
    var rowIndex    = getSelectedRowIndex('gcSearchResults');
    //if (selectedRow != undefined) fixed issue if have BNF and do enter 111652 XN 19Feb15
    if (selectedRow != undefined && selectedRow.length > 0)
    {
        var rowSiteProductDataID = selectedRow.attr('SiteProductDataID');
        var description          = getCell('gcSearchResults', rowIndex, 0).text().replace('|', ' ');
        var NSVCode              = $('Row[SiteProductDataID="'+ rowSiteProductDataID + '"] NSVCode', $('#xmlRowData')[0]).text();
        
        if (embeddedMode)
        { 
            if (window.parent.PharmacyProductDoubleClicked != undefined)  
                window.parent.PharmacyProductDoubleClicked(NSVCode, rowSiteProductDataID, description);
            
            event.returnValue  = false;   // Need else has odd effect in embedded mode 
            event.cancelBubble = true;  
        }
        else
        {        
            window.returnValue = rowSiteProductDataID + "|" + description + "|" + NSVCode;
            window.close();
         }
    }    
}

// Called when cancel button is clicked
// sets return value to null, and closes the form
function btnCancel_click()
{
    window.returnValue = null;
    window.close();
}

// Called when server request ends
function EndRequestHandler()
{
    window.document.getElementById('__EVENTARGUMENT').value = '';

    if (getRowCount('gcSearchResults') > 0)
    {
        // If any rows in grid, enable ok button, and select first row
        $('#btnOK').removeAttr('disabled');
        selectRow('gcSearchResults', 0);
        setTimeout(function(){$('#gcSearchResults').focus()},250); // Set focus using timer (else won't always get focust
    }
    else
    {
        // If rows selcted clear panel, and disable ok button
        UpdateLabels();
        $('#btnOK').attr('disabled', true);
        setTimeout(function()
                { 
                    var tbSearch = $('#tbSearch'); 
                    if (tbSearch.is(':visible'))   // Might not be visible in BNF mode
                    { 
                        tbSearch[0].select(); 
                        tbSearch.focus();
                    }
                    else 
                        $('#bnfTree').focus();
                }, 250); // Set focus using timer (else won't always get focust
    }
}

// Used by extrnal pages to return focus to the search grid
function SetFocusToGrid()
{
    $('#gcSearchResults').focus();
}

function bnfTree_OnClientNodeSelected(bnf) 
{
    __doPostBack('updatePanel', 'SelectedBNF:' + bnf);
}

// Moves the current highlighted to the drug that starts with gridSearchString
// newChar is appended to gridSearchString, which is cleared down if this method has not been called for 1sec
// 05May15 XN 40374
function performGridSearch(newChar)
{
    // If timed out in 1 secs then clear search string
    var currentTime = new Date();
    if ((currentTime - lastSearchTime) > 1000)
        gridSearchString = '';

    // append to current search string
    gridSearchString += newChar;

    // Do search
    var currentSelectedIndex = getSelectedRowIndex('gcSearchResults');
    var newRowIndex = findIndexOfFirstRowStartWith('gcSearchResults', currentSelectedIndex, 0, gridSearchString, true);
    if (newRowIndex > -1)
        selectRow('gcSearchResults', newRowIndex, true);

    // Update search time    
    lastSearchTime = new Date();
}