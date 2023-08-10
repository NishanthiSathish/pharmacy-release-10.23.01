<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="_Shared.modOrderCommsDefs" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Ascribe.Xml" %>

<html>

<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
<script type="text/javascript" language="javascript">

    // If the scrollbar in divDSSResults is shown then show the UP and DOWN buttons
    // otherwise hide them
    function CheckButtonsDisplay() {
        var divDssResults = $('#divDSSResults');
        var tdUpdownButtons = $('#tdUpdownButtons');

        if (divDssResults.scrollHeight > divDssResults.clientHeight) {
            tdUpdownButtons.show();
        }
    }

    // Returns if DSS warnings scroll bar is at bottom of scroll pane
    // (will return false if there is no scroll bar)
    function IsScrollBarAtBottomOffPage() {
        var divDssResults = $('#divDSSResults');
        var tableDssResults = $('#tableDSSResults');

        return (divDssResults.scrollTop() + divDssResults.height() >= tableDssResults.height());
    }

    // Called when the divDSSResults scroll bar moves
    // If scroll bar moves to bottom of pane then enabled the Yes button, and hides the scrollInfoText field
    function divDSSResults_onscroll() {
        if (IsScrollBarAtBottomOffPage()) {
            $('#cmdYes').removeAttr('disabled');
            $('#scrollInfoText').fadeOut();
        }
    }

    // Called when the form loads
    function form_onload(bForceToViewAllWarnings) {
        if (bForceToViewAllWarnings && !IsScrollBarAtBottomOffPage()) {
            $('#cmdYes').attr('disabled', 'disabled');  // Disabled Yes button
            $('#scrollInfoText').show();
        }
        else
            $('#scrollInfoText').hide();    // Hides scrollInfoText field
    }

    function GetDssResultsXml() {
        if (dssData) {
            return dssData;
        }
    }

    function GetDssLogResultsXml() {
        if (dsslogresults) {
            return dsslogresults;
        }
    }
</script>

<head>
<title>Drug Administration DSS Results</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel="stylesheet" type="text/css" href="../../style/dss.css" />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>

<%
	Dim OnLoad As String = String.Empty
    Dim sessionId As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim requestId As Integer = Integer.Parse(Request.QueryString(DA_REQUESTID))
    Dim isGenericTemplate As Boolean = IIf(Not Request.QueryString("IsGenericTemplate") = Nothing AndAlso Request.QueryString("IsGenericTemplate") = 1, True, False)
    Dim IsOptionSelection As Boolean = Not String.IsNullOrEmpty(Request.QueryString("OptionSelected")) AndAlso Request.QueryString("OptionSelected") = "1"
    Dim ResultsInSessionAttribute As Boolean = Request.QueryString("ResultsInSessionAttribute") = "1"
    Dim oSettingRead As New GENRTL10.SettingRead()
    Dim bForceToViewAllWarnings As Boolean = False
    Dim trueSettings() As String = {"Y", "YES", "1", "-1", "T", "TRUE"}
    If (sessionId = 0) OrElse Array.IndexOf(trueSettings, oSettingRead.GetValue(sessionId, "OCS", "DSS", "ForceToViewAllWarnings", "TRUE").ToUpper()) > -1 Then
        bForceToViewAllWarnings = True
    End If
    Dim dssResultsXml As String = String.Empty

    '	
    If ResultsInSessionAttribute Then
        dssResultsXml = New GENRTL10.StateRead().SessionAttributeGet(sessionId, "DrugChartAdminCheckResults")
        If Not SaveResults.ScriptSaveResults(sessionId, dssResultsXml, False, True, hideUpDownButtons:=True) Then
            OnLoad = "window.parent.ShowPrescripton('pass');"
        End If
    Else If Not isGenericTemplate Then
        Dim checkInV11 As Boolean = Boolean.Parse(oSettingRead.GetValue(sessionId, "ICW", "OrderEntry", "UseV11", CStr(False)))
        Dim adminRequestXml As String = String.Empty
        
        If Not IsOptionSelection Then
            adminRequestXml = AdminRequestByID(sessionId, requestId)
        End If

        If IsOptionSelection OrElse adminRequestXml <> "" Then
            Dim requestIdPrescription As Integer
            If IsOptionSelection Then
                requestIdPrescription = Integer.Parse(Request.QueryString(DA_PRESCRIPTIONID))
            Else
                Dim adminRequest As New XmlDocument()
                adminRequest.TryLoadXml(adminRequestXml)
                Dim item As XmlElement = adminRequest.SelectSingleNode("root/*")
                requestIdPrescription = Integer.Parse(item.GetAttribute("RequestID_Prescription"))
            End If
            
            Dim prescriptionDataXml As String = New OCSRTL10.OrderCommsItemRead().GetXML_RX(sessionId, requestIdPrescription)
            Dim inProgress As Boolean = False
            Dim isDurationInfusion As Boolean = Not (prescriptionDataXml = "<root></root>") AndAlso IsLongDurationBasedInfusion(prescriptionDataXml, sessionId)
            If isDurationInfusion Then
                Dim prescription As New XmlDocument()
                prescription.TryLoadXml(prescriptionDataXml)
                inProgress = (GetXMLValueNested(prescription, "root/data", "InfusionInProgress") = "1")
            End If

            If inProgress Then
                OnLoad = "window.parent.ShowPrescripton('pass');"
            Else
                '20Apr11    Rams    F0114570 - Incorrect display for Dose Range Checking DSS Alert on Admin
                If checkInV11 Then
                    Dim sUrl As String = ConfigurationManager.AppSettings("ICW_V11Location") & "/OrderComms/Pending/OrderCheckingXml.aspx?sessionId=" & sessionId & "&orderId=" & requestIdPrescription & "&noteType=''" & "&eventName=OnAdministerPrescription"
                    ' Dim oHttpRequest As MSXML 2.XMLHTTP = New MSXML 2.XMLHTTP()
                    ' oHttpRequest.open("GET", sUrl, False)
                    ' oHttpRequest.send()
                    
                    Using client As WebClient = New WebClient()
                        Dim strWebResponse As String = client.DownloadString(sUrl)
                    
                        If strWebResponse <> "" Then
                            dssResultsXml = strWebResponse
                        End If
                    End Using
                Else
                    dssResultsXml = New DSSRTL20.DssCheckEvaluation().CheckPrescription(sessionId, OCSEventEnum.ocsOnAdministerPrescription, prescriptionDataXml, -1, -1, String.Empty)
                End If
                '18Nov Ajay 6701 - Hide the Up Down buttons as onLoad -> CheckButtonsDisplay will handle this
                If Not SaveResults.ScriptSaveResults(sessionId, dssResultsXml, False, True, hideUpDownButtons:=True) Then
                    OnLoad = "window.parent.ShowPrescripton('pass');"
                End If
            End If
        Else
            OnLoad = "window.parent.ShowPrescripton('pass');"
        End If
    Else
        OnLoad = "window.parent.ShowPrescripton('pass');"
    End If%>
	
<body onload="document.body.style.cursor = 'default';<%= OnLoad %>;CheckButtonsDisplay();form_onload(<%= bForceToViewAllWarnings.ToString().ToLower() %>);">

</body>
<xml id="dssData" sid='<%= sessionId %>'>
    <%=dssResultsXml%>
</xml>
</html>
