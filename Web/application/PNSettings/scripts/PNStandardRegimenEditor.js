/*

PNStandardRegimenEditor.js

Specific script for the PNStandardRegimenEditor.aspx page.

*/

function pharmacygridcontrol_onselectrow(controlID, rowindex)
{
    if (controlID == 'gridItemList')
        $('#hfSelectedPNCode').val(getRow(controlID, rowindex).attr('PNCode'));
    else if (controlID == 'gridSelectProduct')
        $('#wizardAddProduct_selectProductCtrl_hfSelectedProductPNCode').val(getRow(controlID, rowindex).attr('PNCode'));
}

function UpdateGridRow(rowData)
{
    // Convert to HTML
    var rowData = ImprovedXMLReturn(rowData);

    // Add or edit row
    var PNCode    = $(rowData).attr('PNCode');
    var sortIndex = $(rowData).attr('SortIndex');
    
    var rowIndex = getRowIndexByAttribute('gridItemList', 'PNCode', PNCode);
    if (rowIndex == -1) 
    {
       // Add row                
       // Find position to add the row
       var rowsBefore = $('#gridItemList tbody').children('tr').filter(function()
           { 
                return parseInt(this.attributes['SortIndex'].value) > sortIndex;
            });
           
       // Insert or update row
        if (rowsBefore.length > 0)
            $(rowsBefore[0]).before(rowData);
        else
            addRow('gridItemList', rowData);
    }
    else
        replaceRow('gridItemList', rowIndex, rowData);

    // Refresh stripes
    refreshRowStripes('gridItemList');

    // Ensure row is selected
    rowIndex = getRowIndexByAttribute('gridItemList', 'PNCode', PNCode);
    selectRow('gridItemList', rowIndex);
    
    // Ensure it is in view
    if (!IsRowInView('gridItemList', rowIndex))
        scrollRowIntoView('gridItemList', rowIndex, false);
        
    $('#gridItemList').focus();
}

function HasSelectedProduct()
{
    if ($('#hfSelectedPNCode').val() == '')
    {
        $('#gridItemListError').text('Select item from list');
        return false;
    }
    else
        return true;
} 

function PNSelectProduct_validation(source, clientside_arguments)
{
    clientside_arguments.IsValid = (getSelectedRowIndex('gridSelectProduct') > -1) && ($('#wizardAddProduct_selectProductCtrl_hfSelectedProductPNCode').val() != '');
}

function wizardPopup_onkeydown(event) 
{
    switch (event.keyCode)  // Check which key was pressed
    {
        case 27:    // Esc close form
            $('#wizardAddProduct_StartNavigationTemplateContainerID_CancelButton').click();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
        case 13:    // Enter moves to next stage
            ProgressWizard();
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
    }
}

// Progress wizard to next stage
function ProgressWizard() 
{
    $('#wizardAddProduct_FinishNavigationTemplateContainerID_FinishButton').click();
    $('#wizardAddProduct_StepNavigationTemplateContainerID_StepNextButton').click();
    $('#wizardAddProduct_StartNavigationTemplateContainerID_StartNextButton').click();
}
