/*

                           PharmacyLabelPanelControl.js


Scipts with number of helper functions for the PharmacyLabelPanel.

All methods in this file will require a unique ID, this should 
be the id of grid control set in the web page .

    <uc1:GridControl ID="userGrid" runat="server" />  
    
Lots of methods require a row index this is zero based (top of list)
*/
      
// Set panel label text      
function setPanelLabel(controlID, name, value)
{
    $('#' + controlID + ' td[name="' + name + '"]').text(value);
}

// Set panel label text as pure HTML 09Aug13 XN 24653
function setPanelLabelHtml(controlID, name, value)
{
    $('#' + controlID + ' td[name="' + name + '"]').html(value);
}

// Returns all the label names in the panel (names can be used with setPanelLabel)
function getAllPanelLabelNames(controlID)
{
    return $('#' + controlID + ' td[name]').map(function(){ return $(this).attr("name"); }).get();
}

function clearLabels(controlID)
{
    $('#' + controlID + ' div table td:odd').text(' ');
}