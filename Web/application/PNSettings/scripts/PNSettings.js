/*

PNSettings.js

Specific script for the ICW_PNsettings.aspx page.

*/
var PNEDITOR_FEATURES = 'dialogHeight:710px; dialogWidth:650px; status:off';

// Called on postback 26Oct15 XN 106278
function pageLoad() 
{
    window.document.getElementById('__EVENTARGUMENT').value = '';
}

// On double click of the suppliers grid will popup pn product editor.
function DisplayPNProductEditor(pnProductID, drugDefRequestID) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // add product and mode
    if (pnProductID == undefined)
        strURLParameters += "&Mode=add";
    else
    {
        strURLParameters += "&Mode=edit";
        strURLParameters += "&PNProductID=" + pnProductID.toString();
    }

    if (drugDefRequestID != undefined) 
    {
        strURLParameters += "&DSSDrugDefRequestID=" + drugDefRequestID;
    }
    
    var objArgs = new Object();
    objArgs.icwwindow = window.opener.parent.ICWWindow();
    
    // Displays the suppliers details window
    
    var ret = window.showModalDialog('PNProductEditor.aspx' + strURLParameters, objArgs, PNEDITOR_FEATURES);
    //if (ret == 'logoutFromActivityTimeout') {
    //    window.returnValue = 'logoutFromActivityTimeout';
    //    window.close();
    //    window.parent.close();
    //    window.parent.ICWWindow().Exit();
    //}
    return ret;

}

// On double click of the grid will popup pn standard regimen editor.
function DisplayPNStandardRegimenEditor(ageRange, pnStandardRegimenID) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // add product and mode
    if (pnStandardRegimenID == undefined)
    {
        strURLParameters += "&Mode=add";
        strURLParameters += "&AgeRange=" + ageRange;
    }
    else
    {
        strURLParameters += "&Mode=edit";
        strURLParameters += "&AgeRange=" + ageRange;
        strURLParameters += "&PNStandardRegimenID=" + pnStandardRegimenID.toString();
    }
    
    var objArgs = new Object();
    objArgs.icwwindow = window.opener.parent.ICWWindow();
    
    // Displays the suppliers details window
    
    var ret = window.showModalDialog('PNStandardRegimen.aspx' + strURLParameters, objArgs, PNEDITOR_FEATURES);
   return ret;
}

// On double click of the suppliers grid will popup pn rule editor.
// rule type should be ingredientbyproduct, or regimenvalidation
function DisplayPNRuleEditor(ruleType, ruleID) 
{
    var strURL           = document.URL;
    var intSplitIndex    = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // add product and mode
    if (ruleID == undefined)
    {
        strURLParameters += "&Mode=add";
        strURLParameters += "&RuleType=" + ruleType;
    }
    else
    {
        strURLParameters += "&Mode=edit";
        strURLParameters += "&RuleType=" + ruleType;
        strURLParameters += "&RuleID=" + ruleID.toString();
    }
    
    var objArgs = new Object();
    objArgs.icwwindow = window.opener.parent.ICWWindow();
        
    // Displays the suppliers details window
    var ret = window.showModalDialog('PNRuleEditor.aspx' + strURLParameters, objArgs, PNEDITOR_FEATURES);
    
    return ret;
}


// Displays the DssCustomisation form
function DisplayDssCustomisation(parameterName) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Displays dss customisation from (PNProductID or PNRuleID already exist on strURLParameters)
    strURLParameters += '&ParameterName=' + parameterName;
    var ret = window.showModalDialog('DssCustomisation.aspx' + strURLParameters, '', 'status:off');
    if (ret == 'logoutFromActivityTimeout') {
        window.returnValue = 'logoutFromActivityTimeout';
        ret = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }
    return ret;

}

// Called when menu item on main page is clicked
function menuItem_onclick(menuItem, displayType, dataType, title)
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

        //var sessionID = $('body').attr('SessionID');
        //var siteID = $('body').attr('SiteID');    Use standard url parameters so get all desktop parameter 26Oct15 XN 106278
        var strURL = document.URL;
        var intSplitIndex = strURL.indexOf('?');
        var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
        var url = '';

        switch (displayType)
        {
            case 'EditList': url = 'EditList.aspx'; break;
            case 'Settings': url = 'Settings.aspx'; break;
        }

        $('#tdSetting').show();
        //$('#fraSelectedItem')[0].src = url + '?SessionID=' + sessionID + '&SiteID=' + siteID + '&DataType=' + dataType;  26Oct15 XN 106278
        $('#fraSelectedItem')[0].src = url + strURLParameters + '&DataType=' + dataType;
       $('#fraSelectedItem')[0].contentWindow.opener = self;
        $('#panelTitle').text(title);
    }
                    
    window.event.cancelBubble = true;
    window.event.returnValue  = false;
}

// Called when select site link is clicked
// Displays list of sites to replicate to 
// 26Oct15 XN 106278
function lbtSelectSites_onclick() 
{
    // If no sites in list don't display
    if ($('#divSites input').length == 0) 
    {
        return;
    }

    $('#divSites').dialog(
        {
            modal: true,
            buttons: [{ text: 'OK',     width: 80, click: function () { $(this).dialog('destroy'); __doPostBack('updatePanel', 'SelectedNewSites'); } },
                      { text: 'Cancel', width: 80, click: function () { $(this).dialog('destroy'); } }
                     ],
            title: 'Select sites',
            open: function (type, data) { $(this).parents('.ui-dialog-buttonpane button:eq(0)').focus(); },
            width: '300px',
            maxHeight: '400px',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form'
        })
}

// Displays list of sites that can be selected to print from
// 26Oct15 XN 106278
function showSitesToPrint() 
{
    $('#divSitesToPrint').dialog(
        {
            modal: true,
            buttons: [{ text: 'OK',     width: 80, click: function () { $(this).dialog('destroy'); divSitesOk_onclick(); } },
                      { text: 'Cancel', width: 80, click: function () { $(this).dialog('destroy'); } }
                     ],
            title: 'Select site',
            open: function (type, data) { setTimeout(function() { $('#gridSites').focus(); }, 250); },
            width: '400px',
            maxHeight: '400px',
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form'
        })
}

// Called when user select a site to print from, and click ok
// 26Oct15 XN 106278
function divSitesOk_onclick() 
{
    if ($('#divSitesToPrint:visible').length > 0) 
        $('#divSitesToPrint').dialog("destroy");
    __doPostBack('updatePanel', 'PrintSite:' + getSelectedRow('gridSites').attr('SiteID'));
}
