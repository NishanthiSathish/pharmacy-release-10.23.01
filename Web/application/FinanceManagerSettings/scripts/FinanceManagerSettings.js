/*

FinanceManagerSettings.js

Specific script for the ICW_FinanceManagerSettings.aspx page.

*/

function menuItem_onclick(menuItem, displayPage, dataType, title) 
{
    var cancel = false;

    // Check if there are any unsaved changes
    var fraSelectedItem = document.frames['fraSelectedItem'];
    if ((fraSelectedItem.isPageDirty != undefined) && fraSelectedItem.isPageDirty) 
    {
        if (confirm("Continue and lose your changes?") == false)
            cancel = true;
    }

    if (!cancel) 
    {
        $('#menu input.menuItemSelected').removeClass('menuItemSelected');
        $(menuItem).addClass('menuItemSelected');

        var url = displayPage;

        $('#tdSetting').show();
        $('#fraSelectedItem')[0].src = displayPage + '?SessionID=' + sessionID + '&DataType=' + dataType;
        $('#fraSelectedItem')[0].contentWindow.opener = self;
        $('#panelTitle').text(title);
    }

    window.event.cancelBubble = true;
    window.event.returnValue = false;
}