/*

                            ICW_ReceiveGoods.js


Specific script for the ICW_ReceiveGoods page.

*/

// settings for the F4 screen
var STORESDISPLAYSCREEN_FEATURES = 'dialogHeight:760px; dialogWidth:870px; status:off; center: Yes';

// When row is clicked select it
function gridcontrol_onclick(rowIndex) {
    selectLoadingRow(rowIndex);
}

// When row is double clicked display the F4 screen
function gridcontrol_ondblclick(rowIndex) 
{
    displayStoresDisplayScreen(rowIndex);
}

// Returns the row index of the selected row (or null if no row selected)
function getSelectedRowIndex(controlID)
{
    var rowindex = $('#' + controlID + ' tbody tr[selected]').attr('rowindex');
    return (rowindex == undefined) ? null : parseInt(rowindex);
}

// Returns the next visible row index
// startRowIndex - is the start row
// incremeant    - -1 to move up the table, 1 to move down the table
function getNextVisibleRow(controlID, startRowIndex, incremeant)
{
    var row;    
    if (incremeant < 0) 
    {
        // moving up the table so get all visible row below startRowIndex (up table)
        var rows = $.grep($('#' + controlID + ' tbody tr'), function(r)
                   {
                       var rowindex = parseInt(r.attributes['rowindex'].value);
                       return (r.currentStyle.display != 'none') && (rowindex < startRowIndex);
                   });

        // Get top row as wil be first row above startRowIndex             
        if (rows.length > 0) 
           row = rows[rows.length - 1];
    }
    else 
    {
        // moving down the table so get all visible row above startRowIndex (down table)
        var rows = $.grep($('#' + controlID + ' tbody tr'), function(r)
                   {
                      var rowindex = parseInt(r.attributes['rowindex'].value);
                      return (r.currentStyle.display != 'none') && (rowindex > startRowIndex);
                   });

        // Get bottom row as wil be last row below startRowIndex             
        if (rows.length > 0)
           row = rows[0];
    }

    // If no row defined then must alread be at top or bottom of list
    // else get index of new row
    return (row == undefined) ? startRowIndex : parseInt(row.attributes['rowindex'].value);
}

// Sets the spececified row as being the selected row
// The rows colour will also change
function selectRow(controlID, rowindex)
{
    // Remove existing selection
    var allRows = $('#' + controlID + ' tbody tr');
    allRows.removeClass('Selected');
    allRows.removeAttr('selected');

    // Select the row
    if (rowindex != undefined) 
    {
        var selectedRow = $('#' + controlID + ' tbody tr[rowindex=' + rowindex + ']');
        selectedRow.addClass('Selected');
        selectedRow.attr('selected', 'true');
    }
}

// Called when key is pressed
function form_onkeydown(event) 
{
    switch (event.keyCode) {
        case 27:    // ESC (close the form only works when page is called from Pharmacy stores application)  
            window.close();
            break;

        case 115:   // F4 displays F4 Stores product screen (disabled at moment but will need to be renabled at some point)
            var rowIndex = $('#orderItemsGrid tbody tr[selected]').attr('rowindex');
            if (rowIndex != undefined)
                displayStoresDisplayScreen(rowIndex);
            break;
            
        case 38:    // up key
            var rowindex = getSelectedRowIndex('orderItemsGrid');
            if (rowindex == null)
                rowindex = getNextVisibleRow('orderItemsGrid', -1, 1);
            else
                rowindex = getNextVisibleRow('orderItemsGrid', rowindex, -1);

            selectRow('orderItemsGrid', rowindex);
            break;

        case 40:    // down key
            var rowindex = getSelectedRowIndex('orderItemsGrid');
            if (rowindex == null)
                rowindex = getNextVisibleRow('orderItemsGrid', -1, 1);
            else
                rowindex = getNextVisibleRow('orderItemsGrid', rowindex, 1);

            selectRow('orderItemsGrid', rowindex);
            break;            
    }
}

// When close button is clicked closes the form
function close_onclick()
{
    window.close();
}

// Marks a row as selected in the table
function selectLoadingRow(rowIndex) 
{
    $('#orderItemsGrid tbody tr').removeClass('Selected');
    $('#orderItemsGrid tbody tr').removeAttr('selected');

    if (rowIndex != undefined) 
    {
        $('#orderItemsGrid tbody tr[rowindex=' + rowIndex + ']').addClass('Selected');
        $('#orderItemsGrid tbody tr[rowindex=' + rowIndex + ']').attr('selected', 'true');
    }
}

// Displays the F4 screen for the specified row
// Currently not called by anything but will be when F4 screens are added to project
function displayStoresDisplayScreen(rowIndex) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Get the NSVCode for the row
    var nsvcode = $('#orderItemsGrid tbody tr[rowindex=' + rowIndex + ']').attr('NSVCode');
    strURLParameters += "&NSVCode=" + nsvcode;

    // Displays the suppliers details window
    var ret=window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', STORESDISPLAYSCREEN_FEATURES);  // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
    if (ret == 'logoutFromActivityTimeout') {
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}
