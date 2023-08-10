<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    Dim xmldom As XmlDocument
    Dim strResponse As String = String.Empty
    Dim objOcs As OCSRTL10.OrderCommsItem
    Dim lngSessionId As Integer
    Dim itemXml As String
    
    'SuspendPrescriptionSaver.aspx
    '
    'Amendment History
    '26Feb07	CJM	Created
    itemXml = New IO.StreamReader(Request.InputStream).ReadToEnd
    lngSessionId = CInt(Request.QueryString("SessionID"))
    xmldom = New XmlDocument()
    xmldom.TryLoadXml(itemXml)
    Select Case LCase(Request.QueryString("Mode"))
        Case "savesuspendchanges"
            'perform the suspension
            objOcs = New OCSRTL10.OrderCommsItem()
            strResponse = objOcs.SaveSuspendChanges(lngSessionId, xmldom.OuterXml)
        Case "savesuspendinfo"
            'Store requests to be un/suspended in session state
            Generic.SessionAttributeSet(lngSessionId, "OrderEntry/SuspensionXML", xmldom.OuterXml)
            'Request.Form.Item
            strResponse = "savesuspendinfo - saved"
        Case "unlockrequest"
            '05Feb13 Rams 30951 - Patient Locking - No locking occurs when suspending the same prescription at the same time
            Dim RequestID As Integer = Request.QueryString("RequestId")
            Dim oRequestLock As New OCSRTL10.RequestLock
            strResponse = oRequestLock.KillRequestLock(lngSessionId, RequestID)
    End Select
    Response.Write(strResponse)
    
    '"complete"
%>

