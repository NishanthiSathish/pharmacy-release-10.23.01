/*

					    PharmacyReferenceData.js


	Specific script for the ICW_PharmacyReferenceData.aspx page.
*/

// called when page resizes
// resizes the stock account panels so at max height
function body_onResize() 
{
    var divView       = $('#divView');
    var viewsRightPos = $('#trViews').offset().left + $('#trViews').width();
    var width         = $(window).width();
    var height        = $(window).height() * 0.935;
    var buttonHeight  = $('#trButtons').height();

    $('#tbl').width(width);
	divView.offset();
    divView.width (width - viewsRightPos);
    divView.height(height - divView.offset().top - buttonHeight);

    el_onResize('editList');
}

function pageLoad() 
{
    window.document.getElementById('__EVENTARGUMENT').value = '';    
}

// Called when key pressed in main view
// if del key will click the Delete button
function divView_onkeydown()
{
    switch (event.keyCode)
    {
    case 46: // del
        var selectedCell = el_GetSelectedCell('editList');
        if (selectedCell.attr('SiteNumber') != undefined)
            $('#btnDelete').click();
        break;
    }
}

// Called when add button is pressed
// Displays the ReferenceDataEditor.aspx page
function btnAdd_OnClick()
{
    var viewKey          = getSelectedViewKey();
    var strURLParameters = getURLParameters();
    strURLParameters += "&WLookupContextType=" + viewKey;

    var objArgs = new Object();
    objArgs.icwwindow = window.parent.ICWWindow();

    var returnVal = window.showModalDialog('AddNewCode.aspx' + strURLParameters, objArgs, 'status:off;center:Yes');
    if (returnVal == 'logoutFromActivityTimeout') {
        returnVal = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (returnVal != undefined)
    {
        strURLParameters += "&Code=" + URLEscape(returnVal) + "&AddMode=Y";
        returnVal = window.showModalDialog('ReferenceDataEditor.aspx' + strURLParameters, objArgs, 'status:off;center:Yes');
        if (returnVal == 'logoutFromActivityTimeout') {
            returnVal = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

    }
    if (returnVal != undefined)
        __doPostBack('upView', 'Update:' + returnVal);
}

// Called when edit button is pressed
// Displays the ReferenceDataEditor.aspx page
function btnEdit_OnClick()
{
    // If not on editable cell then end (dss or code cell)
    var selectedCell = el_GetSelectedCell('editList');
    if (selectedCell == undefined || selectedCell.attr("SiteNumber") == undefined)
    {
        alertEnh('Non editable cell');
        return;
    }
    
    // Display editor
    var strURLParameters = getURLParameters();
    strURLParameters += "&AddMode=N";
    strURLParameters += "&Code="               + URLEscape(XMLUnescape(selectedCell.prop("Code")));
    strURLParameters += "&EditingSiteNumber="  + selectedCell.attr("SiteNumber");
    strURLParameters += "&WLookupContextType=" + getSelectedViewKey();

    var objArgs = new Object();
    objArgs.icwwindow = window.parent.ICWWindow();

    var code = window.showModalDialog('ReferenceDataEditor.aspx' + strURLParameters, objArgs, 'status:off;center:Yes');
    if (code == 'logoutFromActivityTimeout') {
        code = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (code != undefined)
    {
        // Get cell text via post back
        var parameters = {  sessionID:          sessionID,
                            siteNumber:         siteNumber,
                            code:               XMLUnescape(code),
                            editingSiteNumber:  selectedCell.attr("SiteNumber"),
                            contextType:        getSelectedViewKey() }
        var cellText = PostServerMessage("ICW_PharmacyReferenceData.aspx/GetCellText", JSON.stringify(parameters));
    }

    // Set cell text
    if (cellText != undefined)
    {
        el_SetCellValue(selectedCell, cellText.d);
        selectedCell.attr('Code', code);    // Need to reset code as might of changed when changing blank code to !_
     }
}

// Called when delete key is pressed
// Ask user if they want to delete, the deletes value web method call
function btnDelete_OnClick()
{
    // If not on editable cell (or already empty) then end (dss or code cell)
    var selectedCell = el_GetSelectedCell('editList');
    if (selectedCell == undefined || selectedCell.attr("SiteNumber") == undefined || selectedCell.children('.EmptyCell').length > 0)
    {
        alertEnh('Non editable cell');
        return;
    }

    // check if can delete the look
    var parameters = { sessionID:           sessionID,
                       siteNumber:          siteNumber,
                       code:                XMLUnescape(selectedCell.prop("Code")),
                       editingSiteNumber:   selectedCell.attr("SiteNumber"),
                       contextType:         getSelectedViewKey() };
    var errorMgs = PostServerMessage("ICW_PharmacyReferenceData.aspx/CanDelete", JSON.stringify(parameters)); 
    if (errorMgs.d != null)
    {
        alertEnh(errorMgs.d, undefined, '550px');
        return;
    }

    // Ask user if they want to delete
    var msg = "Delete code '" + XMLUnescape(selectedCell.prop("Code")) + "' from site " + selectedCell.attr("SiteNumber");
    confirmEnh  (msg, 
                 false, 
                 function() 
                 { 
                     // Delete via web method
                     var selectedCell = el_GetSelectedCell('editList');
                     var parameters = { sessionID:           sessionID,
                                        siteNumber:          siteNumber,
                                        code:                XMLUnescape(selectedCell.prop("Code")),
                                        editingSiteNumber:   selectedCell.attr("SiteNumber"),
                                        contextType:         getSelectedViewKey() };

                     var result = PostServerMessage("ICW_PharmacyReferenceData.aspx/Delete", JSON.stringify(parameters)); 
                     if (result != undefined)
                         el_SetCellValue(selectedCell, result.d);   // Update cell

                     // Set focus on timeout (so message box has time to close)
                     setTimeout(function() { el_GetSelectedCell('editList').focus(); }, 250);
                 },
                 function() { setTimeout(function() { el_GetSelectedCell('editList').focus(); }, 250); });
}


function btnPrint_OnClick()
{
    if ($('#divSites input').length == 1)
        __doPostBack('upView', 'Print');    // If ony 1 site then just print
    else
    {
        $('#divSites').dialog(
            {
                modal: true,
                buttons: [  
                            { text: 'OK',     click: function() { $(this).dialog('destroy');  __doPostBack('upView', 'Print'); } },
                            { text: 'Cancel', click: function() { $(this).dialog('destroy'); } }      
                         ],
                title: 'Select sites',
                open: function(type, data) { $(this).parents('.ui-dialog-buttonpane button:eq(0)').focus(); },
                width: '350px',
                maxHeight: '400px',
                closeOnEscape: true,
                draggable: false,
                resizable: false,
                appendTo: 'form'
            })
    }
}

// Currently selected view
function getSelectedViewKey()
{
    return $('#hfSelectedViewKey').val();
}