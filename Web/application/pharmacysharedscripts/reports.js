/*

reports.js

Methods used to display generate reports.

Supports SSRS reports for
    Drug Report
    Customer Report
    Supplier Report

Also method for call the old vb6 call to AscribePrintJob.exe

*/

// Displays Drug Report
// Read from WPharmacyLog where log type is LabUtils
// Either NSVCode or days can be undefined to allow user to select
function ReportPharmacyLogDrugs(NSVCode, days, siteID, autoPrint)
{
    var strParameters = '';
    if (NSVCode != undefined && NSVCode != '')
        strParameters += 'NSVCode:' + NSVCode + ',';
    if (days != undefined)
        strParameters += 'Days:' + days + ',';
    if (siteID != undefined)
        strParameters += 'SiteID:' + siteID + ',';

    DisplayReport('Core\\Audit Log.rdlc', 'pPharmacyReportWPharmacyLogByDrug', strParameters, autoPrint)
}

// Displays Customer Report
// Read from WPharmacyLog where log type is WCustomer
// Either WCustomerID or days can be undefined to allow user to select
function ReportPharmacyLogWCustomer(WCustomerID, days, autoPrint)
{
    var strParameters = '';
    if (WCustomerID != undefined)
        strParameters += 'WCustomerID:' + WCustomerID + ',';
    if (days != undefined)
        strParameters += 'Days:' + days + ',';

    DisplayReport('Core\\Audit Log.rdlc', 'pPharmacyReportWPharmacyLogByWCustomer', strParameters, autoPrint);
}

// Displays Supplier Report
// Read from WPharmacyLog where log type is WSupplier2
// Either WSupplier2ID or days can be undefined to allow user to select
function ReportPharmacyLogWSupplier2(WSupplier2ID, days, autoPrint)
{
    var strParameters = '';
    if (WSupplier2ID != undefined)
        strParameters += 'WSupplier2ID:' + WSupplier2ID + ',';
    if (days != undefined)
        strParameters += 'Days:' + days + ',';

    DisplayReport('Core\\Audit Log.rdlc', 'pPharmacyReportWPharmacyLogByWSupplier2', strParameters, autoPrint);
}

// Displays the report (requires pharmacyscript.js, and jquery ui)
// reportFile- report file (rdlc file)
// SP        - to run to populate the report (must exist in Routine table)
// params    - optional parameters to pass to the sp
// autoPrint - if the report is to be auto printed
// visible   - if report is visible (should use with auto print) default is true 22Jan16 XN 124812
function DisplayReport(reportFile, sp, params, autoPrint, visible)
{
    var strURL = document.URL;

    var intSplitIndex = strURL.indexOf('application');
    var basePath = strURL.substring(0, intSplitIndex + 11);

    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    strURLParameters += '&AutoPrint='  + autoPrint.toString();
    strURLParameters += '&ReportFile=' + reportFile;
    strURLParameters += '&SP=' + sp;
    strURLParameters += '&EmbeddedMode=Y';  // 12Aug15 XN If report displayed in a popup the can't print due to bug in microsoft report viewer 10

    if (params != undefined && params != '')
        strURLParameters += '&Params=' + params;

    document.body.style.cursor = "wait";
    //window.showModalDialog(basePath + '/pharmacysharedscripts/SSRSReport.aspx' + strURLParameters, '', 'status:off; center: Yes'); 12Aug15 XN If report displayed in a popup the can't print due to bug in microsoft report viewer 10
    alertEnh('<div><iframe application="yes" style="width:700px;height:600px;" src="' + basePath + '/pharmacysharedscripts/SSRSReport.aspx' + strURLParameters + '"></iframe></div>', undefined, 730);

    // If report is hidden will automatically close the report, so report remains hidden 22Jan16 XN 124812
    // This seems to work well (when used with autoPrint still display the printer selection dialog)
    if (visible == false && parseBoolean(getICWSetting('Pharmacy', 'ReportViewer', 'AllowAutoClose', '1'))) 
    {
        $('.ui-dialog').dialog('close');
    }

    document.body.style.cursor = "default";
}

// Print using AscribePrintJob.exe 
// Requires the rft file to be saved on the network or on a folder location
// The method will ask the user to select a printer if non present in the context for the terminal (uses AscribePrintJobHelper.asmx to get the info)
// If present will call ShowProgressMsg, and HideProgressMsg
//
// sessionId      - session Id
// siteId         - site Id (used to get the printer driver)
// smartClientPath- location of the smart client folder
// file           - file to print
// context        - pharmacy printer context to use to get printer (and printer overrides like orientation) to use form (WConfiguration) e.g. ManWkSheet
// numberOfCopies - number of copies to print
function AscribeVB6PrintJob(sessionId, siteId, smartClientPath, file, context, numberOfCopies) 
{
    // Show the progress message
    if (typeof ShowProgressMsg === 'function')
        ShowProgressMsg(this, undefined);

    // Gets the printer to use and the overrides
    var parameters =
    {
        sessionId : sessionId,
        siteId    : siteId,
        context   : context
    };
    var result = PostServerMessage("../pharmacysharedscripts/AscribeVB6PrintJobHelper.asmx/GetPrinter", JSON.stringify(parameters));

    // Do citrix port remapping

    // Append \\ to end on client path
    if (smartClientPath.charAt(smartClientPath.length - 1) != '\\' && smartClientPath.charAt(smartClientPath.length - 1) != '/')
        smartClientPath += "\\";

    var fso = new ActiveXObject("Scripting.FileSystemObject");
    if (!fso.FileExists(smartClientPath + "AscribePrintJob.exe"))
    {
        if (typeof HideProgressMsg === 'function')
            HideProgressMsg(this, undefined);
        alert('Pharmacy client not installed ' + smartClientPath + 'AscribePrintJob.exe');
        return;
    }

    // If no printer passed in will the ask the user to select a printer
    var shell = new ActiveXObject("WScript.Shell");
    if (result != undefined && result.d.printer == '') 
    {
        // Ask the user to select a printer
        printJob = smartClientPath + "AscribePrintJob.exe SELECTPRINT";
        var wsState = shell.Exec(printJob);
        while (wsState.Status == 0)
            ;

        // Get the selected printer
        result.d.printer = wsState.StdOut.ReadLine();
        if (result.d.printer == undefined || result.d.printer == '') 
        {
            if (typeof HideProgressMsg === 'function')
                HideProgressMsg(this, undefined);
            return;
        }

        // Save the printer
        parameters =
        {
            sessionId: sessionId,
            siteId   : siteId,
            context  : context,
            printer  : result.d.printer
        };
        PostServerMessage("../pharmacysharedscripts/AscribeVB6PrintJobHelper.asmx/SetPrinter", JSON.stringify(parameters), true);

        // Do citrix port remapping
    }

    // Perform the print
    if (result != undefined)
    {
        var printJob = smartClientPath + "AscribePrintJob.exe " + file + "|" + result.d.printer + "|" + result.d.overideSettings;
        PrintAndWait(shell, printJob, undefined, numberOfCopies);
    }
}

// Internal use only so don't call directly
// Will do the print and wait for process to finish before doing next print
// When complete will call HideProgressMsg
function PrintAndWait(shell, printJob, wsState, numberOfPrints) 
{
    if ((wsState == undefined || wsState.Status != 0) && numberOfPrints > 0) 
    {
        wsState = shell.Exec(printJob);
        setTimeout(function () { PrintAndWait(shell, printJob, wsState, numberOfPrints - 1) }, 1000);
    }
    else if (wsState.Status == 0)
        setTimeout(function () { PrintAndWait(shell, printJob, wsState, numberOfPrints) }, 1000);
    else if (typeof HideProgressMsg === 'function')
        HideProgressMsg(this, undefined);
}