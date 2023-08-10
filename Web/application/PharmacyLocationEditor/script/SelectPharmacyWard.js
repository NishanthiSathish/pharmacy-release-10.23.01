/*

SelectPharmacyWard.js

Specific script for the select pharmacy ward page.

*/

//var disableUpdateOfSeachTexBox = false;   02Sep14 XN  88509

// Handles key down on the search text box
function body_onload()
{
    //updateGridSelection(true);    02Sep14 XN  88509
    try 
    { 
        $('#tbSearch').focus(); 
    } 
    catch(ex) { };
}

function body_onkeydown()
{
    switch (event.keyCode)
    {
    case 13: 
        window.event.cancelBubble = true;
        window.event.returnValue  = false;
        $('#btnOk').click(); 
        break;
    case 27: 
        window.close();      
        break;
    case 33:   // page up                
    case 34:   // page down              
    case 38:   // up arrow               
    case 40:   // down arrow
        gridcontrol_onkeydown_internal('gcGrid', event); 
        break;
    }
}
        
// Handles key up on the search text box
function tbSearch_onkeyup(event)
{
    switch (event.keyCode)
    {
    case 33: // page up               
    case 34: // page down               
    case 38: // up arrow               
    case 40: // down arrow
    case 13: // enter  
        break;
    default:
        filterList();
    }
}    

// filter the list  02Sep14 XN  88509
function filterList()
{
    filterRows('gcGrid', [0, 1], $('#tbSearch').val());
    refreshRowStripes('gcGrid');

    // If no row selected then select the first visible one in the list
    var row = getSelectedRow('gcGrid');
    if (row.length == 0 || !isRowVisisble(row))
    {
        var rowcount = getVisibleRowCount('gcGrid');
        if ( rowcount > 0 )
            selectRow('gcGrid', getNextVisibleRow('gcGrid', 0, 1));
        else
            unselectRow('gcGrid', getSelectedRowIndex('gcGrid'));
    }
}

// Called when row selected
// Updates the selected text in the hidden fields
function gcGrid_OnRowSelected()
{
    var row = getSelectedRow('gcGrid');
    $('#hfSelectedID').val( row.attr('ID'  ) );
//    if (!disableUpdateOfSeachTexBox)  02Sep14 XN  88509
//        $('#tbSearch').val( row.attr('Code') )
    $('#lbInfo').hide();
}

// Called when row unselected
// Updates the selected item in the hidden fields
function gcGrid_OnRowUnselected()
{
    $('#hfSelectedID').val ('');
}

// Called when row double clicked
// Clicks ok button
function gcGrid_OnDblClick() 
{
    $('#btnOk').click();    
}

// When okay button is clicked
// If no row selected then shows warning, and cancels ok
function btnOk_onclick()
{
    if ($('#hfSelectedID').val() == '')
        $('#lbInfo').show();

    return ($('#hfSelectedID').val() != '');
}