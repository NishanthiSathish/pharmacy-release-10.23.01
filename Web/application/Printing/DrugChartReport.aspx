<%@ Page Language="VB" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>

<script runat="server">

    Dim SessionID As Integer
    Dim ReportData As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        SessionID = Integer.Parse(Request.QueryString("SessionID"))
        ReportData = Request.Url.OriginalString.Replace("DrugChartReport", "DrugChartLoader")
		If SessionID > 0 Then
			'See if we have a cookie on the client who's guid also exists in the DB
			Dim CookieID As Integer = GetCookieID(SessionID)
			If CookieID = -1 Then
				'Create cookie because it doesnt exist
				CookieID = CreateCookie(SessionID)
			End If
			
            ' Check to see if we always want to ask for the printer to be selected
            Dim alwaysShowPrinterList As Boolean = Convert.ToBoolean(New GENRTL10.SettingRead().GetValue(SessionID, "ICW", "Printing", "AlwaysShowPrinterList", "False"))
            If alwaysShowPrinterList = False Then
                Dim DeviceName As String = New PRTRTL10.PrintDeviceRead().GetDeviceByCookieMediaType(SessionID, CookieID, 1)
                txtDevice.Value = DeviceName
            Else
                txtDevice.Value = String.Empty
            End If
		End If
    End Sub
    
</script>

<script type="text/javascript" language="javascript">

function body_onload() {
    var DeviceName = new String(txtDevice.value);
    var DeviceList = new String(HEditAssist.GetWindowsPrintDeviceList());
    if (DeviceName == "" || DeviceList.indexOf(DeviceName.split(",")[0], 0) == -1)
	{
		var strFeatures = "dialogWidth:640px;dialogHeight:480px;scroll:no;status:no;resizable:yes";
        DeviceName = window.showModalDialog("PrintDeviceSelector.aspx?SessionID=<%= SessionID%>", 'A4', strFeatures);
        

		if (DeviceName == undefined) {
		    window.close();
//			DeviceName = HEditAssist.GetDefaultWindowsPrintDevice();
//			if (DeviceName == '')
//			{
//			    window.close();
//			}
//			else
//			{
//			    PrintReport(DeviceName);
//			}
		}
		else
		{
			PrintDeviceSave(1, DeviceName);
		}
	}
	else
	{
		PrintReport(DeviceName);
	}
}

function PrintDeviceSave(MediaTypeID, DeviceName)
{
	fraPrintDeviceSaver.document.all("txtMediaTypeID").value = MediaTypeID;
	fraPrintDeviceSaver.document.all("txtDeviceName").value = DeviceName;
	fraPrintDeviceSaver.document.all("frmPrintDeviceSaver").submit();
}

function PrintDeviceSaveComplete(DeviceName)
{
	PrintReport(DeviceName);
}

function PrintReport(DeviceName) {
    var DefaultPrinter = HEditAssist.GetDefaultWindowsPrintDevice();
    var ReportPrinter = DeviceName.split(",")[0];
    if (ReportPrinter != DefaultPrinter)
    {
        HEditAssist.SetDefaultWindowsPrintDevice(ReportPrinter);
    }

    ImagePrinting.PrintServerFile('<%= ReportData%>');
    if (ReportPrinter != DefaultPrinter)
    {
        HEditAssist.SetDefaultWindowsPrintDevice(DefaultPrinter);
    }
    window.close();
}

</script>
<html>
<head runat="server">
    <title>Printing...</title>
</head>
<body onload="body_onload();" >

<OBJECT style="visibility:hidden" id="ImagePrinting" classid="CLSID:B1E95B15-B4E2-38B3-870E-B8701AC91D1C" VIEWASTEXT></OBJECT> <!--ImagePrinting.dll#Ascribe.ImagePrinting.DrugChartPrinter" VIEWASTEXT>-->
<OBJECT style="visibility:hidden" id="HEditAssist" classid="CLSID:22A94461-82F5-47D5-B001-9A1681C67CAF" VIEWASTEXT></OBJECT>

<input runat="server" id="txtDevice" type="hidden" />
<iframe frameborder=1 application=yes style="visibility:hidden" width="100%" id='fraPrintDeviceSaver' src='../Printing/PrintDeviceSaver.aspx?SessionID=<%= SessionID %>'></iframe>

</body>
</html>
