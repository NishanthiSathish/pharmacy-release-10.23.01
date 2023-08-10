<%@ Page Language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<html>
<head>

<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim BatchID As Integer = Integer.Parse(Request.QueryString("BatchID"))
    Dim IsReprint As String = Request.QueryString("IsReprint").Trim
    Dim IsPrintPreview As String = Request.QueryString("Preview").Trim
    Dim ShowAlert As String = Request.QueryString("ShowAlert").Trim
%>

<title>Printing...</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />

<script type="text/javascript" src="../sharedscripts/Printing/Printing.js"></script>
<script type="text/javascript" src="../sharedscripts/icw.js"></script>
<script type="text/javascript">

function ReadyToPrint()
{
	var BatchID = Number(document.body.getAttribute("BatchID"));
    var IsPrintPreview = (document.body.getAttribute("IsPrintPreview") == "true");
    var IsReprint = (document.body.getAttribute("IsReprint") == "true");

    fraOCSReportControl.PrintBatch(BatchID, IsPrintPreview, IsReprint);
}

function AllReportsPrinted()
{
    var pntFunctionCalledWhenPrintComplete = window.dialogArguments;

    if (pntFunctionCalledWhenPrintComplete != undefined)
    {
        pntFunctionCalledWhenPrintComplete();
    }

	var BatchID = document.body.getAttribute("BatchID");
    divProgress.innerText = "Batch " + BatchID + " printed.";
    //24Jun09    Rams   F0048155(Section 4.4.2) Display Print batch number after printing

    var ShowAlert = (document.body.getAttribute("ShowAlert") == "true");
    if(ShowAlert)
    {
	    alert("Batch " + BatchID + " printed.");
    }	
    window.close();
}

function DocumentPrinted(ReportName, DeviceName)
{
	var BatchID = document.body.getAttribute("BatchID");
	divProgress.innerText = "Batch " + BatchID + " printed " + ReportName + " to " + DeviceName;	 
}

function DocumentPrinting(ReportName, DeviceName, Copy, NoOfCopies)
{
	var BatchID = document.body.getAttribute("BatchID");
	divProgress.innerText = "Batch " + BatchID + " printing: " + ReportName + "(" + Copy + " of " + NoOfCopies + ")" + " to " + DeviceName;
}

function PrintCancelled()
{
    var BatchID = document.body.getAttribute("BatchID");
    var ShowAlert = (document.body.getAttribute("ShowAlert") == "true");
    if (ShowAlert) {
        alert("Batch " + BatchID + " print cancelled");
    }
    window.close();
}


</script>

</head>
<body IsPrintPreview="<%= IsPrintPreview %>" BatchID="<%= BatchID %>" IsReprint="<%= IsReprint %>" ShowAlert="<%= ShowAlert %>">

    <table height="100%" width="100%">
        <tr height="1%">
            <td>
                <div id="divProgress"/>
            </td>
        </tr>
        <tr>
            <td>  
			    <iframe application="yes" id="fraOCSReportControl" src="../Printing/OCSReportControl.aspx?SessionID=<%= SessionID %>" width="100%" height="100%" />
            </td>
        </tr>
    </table>
</body>
</html>
