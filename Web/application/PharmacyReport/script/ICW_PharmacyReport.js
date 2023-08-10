/*

								ICW_PharmacyReport.js


	Specific script for the ICW_PharmacyReport page.

*/

function pageLoad() 
{
    body_onResize();
}

// called when page resizes
// Resizes the reports
function body_onResize() 
{
    var panel       = $('#divReports');
    var totalHeight = $(window).height();
    var footerHeight= $('div[id$="pnFooter"]').height();
    var top         = panel.offset().top;
    var reportHeight = totalHeight - top - footerHeight - 50;

    if (reportHeight < 0)
        reportHeight = 0;
    panel.height(reportHeight);

    // resize selected Report
    ResizeReport();
}

// Called when add report button is clicked
// As user to selecte a report, and then create the report
function btnAddReport_OnClick() 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Get the report (if more than one ask user to select from list)
    var reportInfo = undefined;
    switch (reportInfoList.length) 
    {
    case 0:
        alert('No report have been setup in the desktop parameters');
        break;
    case 1:
        document.body.style.cursor = 'wait';
        reportInfo = reportInfoList[0];
        break;
    default:
        document.body.style.cursor = 'wait';

        // display the report selected page
        var URL = 'SelectReport.aspx' + strURLParameters;
        var index = window.showModalDialog(URL, undefined, 'center:yes; status:off');
        if (index == 'logoutFromActivityTimeout') {
           index = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

        if (index != undefined) 
        {
            for (var i = 0; i < reportInfoList.length; i++) 
            {
                if (reportInfoList[i].Index == index) 
                {
                    reportInfo = reportInfoList[i];
                    break;
                }
            }
        }
        break;
    }

    // Add report 
    if (reportInfo != undefined)
        AddReport(reportInfo);        

    document.body.style.cursor = 'default';
}

// Called when the remove report button is clicked
// Delete currently selected report
function btnRemoveReport_OnClick() 
{
    // Get selected tab
    var tabButtons  = $find("tabButtons");
    var selectedTab = tabButtons.get_selectedTab();
    if (selectedTab == null)    
        return; // Null if not tabs left
        
    var uniqueID= selectedTab.get_attributes().getAttribute("ReportID");

    tabButtons.trackChanges();
    
    // Remove tab and report
    tabButtons.get_tabs().remove(selectedTab);
    $('div[ReportID="' + uniqueID + '"]').remove();

    tabButtons.commitChanges();

    // Reselect first re[prt
    if ($('div[ReportID]').length > 0)
        SelectReport($('div[ReportID]').eq(0).attr("ReportID"));
}

// Called when tab selected (redisplays a report)
function tabSelected(sender, eventArgs) 
{
    var uniqueID = eventArgs.get_tab().get_attributes().getAttribute("ReportID");

    HideReports();
    SelectReport(uniqueID);
}

// called when report creation is cancelled
// close the currently selected report
function ssrsreport_cancelledcreation()
{
    btnRemoveReport_OnClick();
}

// Add stock balance report to page
function AddReport(info)
{
    // hide all existing report
    HideReports();

    // get new report ID
    var newReportID = 0;
    $('div[ReportID]').each(function() 
    {
        if (parseInt(this.getAttribute('ReportID')) > newReportID);
            newReportID = parseInt(this.getAttribute('ReportID'));
    });
    newReportID++;

    // add reports
    var html = format('<div ReportID="{0}" style="width:98%;"><iframe id="fra{0}" style="width:100%;height:100%;" application="yes" src="../pharmacysharedscripts/SSRSReport.aspx?SessionID={1}&SiteID={2}&ReportFile={3}&SP={4}&AutoPrint={5}&EmbeddedMode=1"></iframe></div>', newReportID, sessionID, siteID, info.File, info.SP, autoPrint);
    $('div[id$="divReports"]').append(html);

    // add tab for re[prt
    var tabButtons = $find("tabButtons");
    tabButtons.trackChanges();
    var tab = new Telerik.Web.UI.RadTab();
    tab.get_attributes().setAttribute("ReportID", newReportID);
    tab.set_text(info.Name);
    tabButtons.get_tabs().add(tab);
    tab.scrollIntoView();           
    tabButtons.commitChanges();

    // Select newly added sheet
    SelectReport(newReportID);
    
    ResizeReport();
}

// Select a report
function SelectReport(uniqueID) 
{
    var tab = $find("tabButtons").findTabByAttribute('ReportID', uniqueID);
    if (tab != undefined) 
    {
        tab.select();
        tab.scrollIntoView();
        $('div[ReportID="' + uniqueID + '"]').show();                
    }
}

// hides all reports
function HideReports() 
{
    $('div[ReportID]').hide();
}

// Resizes all report in the panel
function ResizeReport() 
{
    var reportPanel = $('#divReports');
    var reports     = $('div[ReportID]');
    reports.height(reportPanel.height() - 60);
}