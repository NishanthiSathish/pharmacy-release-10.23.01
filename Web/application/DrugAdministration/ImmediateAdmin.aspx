<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<html>
<head>
<title>Administer Immediate Doses</title>

<script type="text/javascript" language="javascript">
	var m_closeFromFrame = false;

	function CloseFromFrame()
	{
		return m_closeFromFrame;
	}
</script>
<%
    '---------------------------------------------------------------------------------------------------------
    '
    'ImmediateAdmin.aspx
    'Call with string of items to be immediately administered DR-06-0776
    'Run AdministrationPrescriptionDetail.aspx for each item if requested
    '
    'Querystring Params:
    '
    'SessionID:				(mandatory)
    '
    'xmlItems: XML data of all items to be processed.
    '<items>
    '<item PrescriptionID='1234'/>
    '<item PrescriptionID='1235'/>
    '<item PrescriptionID='1236'/>
    '</items>
    '
    'Initialise with 'start' Phase:
    'Display question
    '
    'Calling ScriptButton_AdminRequest()
    'DA_REQUESTID
    '
    'Calling AdministrationPrescriptionDetail.aspx:
    'DA_PRESCRIPTIONID
    '
    'Modification History:
    '
    'var strFeatures = dialogHeight:300px; size of this dialog
    '+ dialogWidth:450px;
    '+ resizable:no;unadorned:no;
    '+ status:no;help:no;
    '
    '
    '---------------------------------------------------------------------------------------------------------
    'incomming

    Dim sessionId As Integer = CIntX(Request.QueryString("SessionID"))
    Dim strPhase As String = Request.QueryString("Phase")
	
    If strPhase = "startfast" Then
        SessionAttributeSet(sessionId, IA_INDEX, "-1")
        strPhase = "increment"
    End If
    
    Dim immediateDoc As New XmlDocument
    Dim immediateItemsXml As String = SessionAttribute(sessionId, IA_ITEMS)
    
	If strPhase.ToLower <> "closenoadmin" Then
		immediateDoc.TryLoadXml(immediateItemsXml)
	End If
	
    Dim OnLoad As String = String.Empty

    Dim domRx As New XmlDocument
    Dim adminRequest As XmlNode = Nothing
    Dim immediateIndex As Integer
    Dim strHeight As String = Request.QueryString("height")
    Dim strWidth As String = Request.QueryString("width")
    Dim isGeneric As String = "0"
    '23Mar2012  Rams    29839 - Immediate Admin prompt does not prevent administration
    Dim canBeAdministered As Boolean = True
    
    'item list in state
    Dim immediateItems As XmlNodeList = immediateDoc.SelectNodes("//ImmediateAdmin/Prescription")
    Dim immediateCount As Integer = immediateItems.Count

    Dim strStillRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "StillRequiredAdminText", "Still Required")
    Dim strNoLongerRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "NoLongerRequiredAdminText", "No Longer Required")
    Dim blnShowRequiredMessage As Boolean = (SettingGet(sessionId, "OCS", "Prescribing", "DiscontinueDecisionOnOutstandingRequests", "false").ToLower() = "true")

    If strPhase = "increment" Then
        'increment the item counter
        immediateIndex = CIntX(SessionAttribute(sessionId, IA_INDEX))
        'get item index from state
        immediateIndex = immediateIndex + 1
        SessionAttributeSet(sessionId, IA_INDEX, immediateIndex.ToString())
        'set the index back to state
        If immediateIndex >= immediateCount Then
            'clear the immediate admin state
            SessionAttributeSet(sessionId, IA_ITEMS, "")
            SessionAttributeSet(sessionId, IA_INDEX, "")
            SessionAttributeSet(sessionId, DA_REQUESTID, "")
            SessionAttributeSet(sessionId, IA_ADMIN, "")
			Response.Write("<script language=""javascript"">m_closeFromFrame = true;window.close();</script>")
            Response.End()
        Else
            strPhase = "cycle"
            'go back to display of next item
        End If
    End If
    
    Select Case LCase(strPhase)
        Case "cycle"
            'adminster the item
            immediateIndex = CIntX(SessionAttribute(sessionId, IA_INDEX))
            Dim immediateItem As XmlNode = immediateItems(immediateIndex)
            'get item index from state
            'number of items in the list of items
            Dim adminRequestId As Integer = CIntX(immediateItem.Attributes("RequestID_Administration").Value)
            Dim creationType As String = immediateItem.Attributes("CreationType").Value
            If creationType = "Homely Remedy" Then
                OnLoad = " onload=""btnYes_onClick();"""
            End If
            SessionAttributeSet(sessionId, IA_ADMIN, "1")
            'get the admin request needed to script the admin button
            Dim strRequestXml As String = AdminRequestByID(sessionId, adminRequestId).ToString()
            domRx.TryLoadXml(strRequestXml)
            adminRequest = domRx.SelectSingleNode("//AdminRequest")
            
			If adminRequest.Attributes("IsGenericTemplate") IsNot Nothing AndAlso adminRequest.Attributes("IsGenericTemplate").Value = "1" Then
				isGeneric = "1"
			End If
            
            'set state for DrugAdmin/AdministrationPrescriptionDetail.aspx
            SessionAttributeSet(sessionId, DA_REQUESTID, adminRequestId.ToString())
        Case "admin"
            'script drugadmin iframe
            SessionAttributeSet(sessionId, IA_ADMIN, "1")
            'inform admin that this is an immediate admin (da must check for this so it can return
            SessionAttributeSet(sessionId, DA_HEIGHT, strHeight)
            SessionAttributeSet(sessionId, DA_WIDTH, strWidth)
        Case "closenoadmin"
            Dim requestId As Integer
            '
            If Int32.TryParse(SessionAttribute(sessionId, DA_REQUESTID), requestId) Then
                Dim requestLock = New OCSRTL10.RequestLock()
                requestLock.UnlockMyRequestLock(sessionId, requestId)
            End If
            SessionAttributeSet(sessionId, IA_ITEMS, "")
            SessionAttributeSet(sessionId, IA_INDEX, "")
            SessionAttributeSet(sessionId, DA_REQUESTID, "")
            SessionAttributeSet(sessionId, IA_ADMIN, "")
    End Select
%>

<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/ICWFunctions.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministration.js"></script>
<script type="text/javascript" language="javascript">

//------------------------------------------------------------------------------------
// initiate admin of the current item. If first pass then will start the cycle process
function btnYes_onClick()
{
    var phase = "<%= strPhase %>";    
    if(phase == "cycle")
        Administrate(<%= immediateIndex %>);
    else
    {
        var strUrl = "ImmediateAdmin.aspx?SessionID=<%= sessionId %>&Phase=cycle&Index=<%= immediateIndex %>";
        window.navigate(strUrl);    //go to the first item, index 0)
    }
}
//------------------------------------------------------------------------------------
//Administer the current indexed item
function Administrate(lngCurrentIndex)
{
    var strUrl;
    var leftPos, topPos; 
   	var lngHeight = window.screen.availHeight-100;
	var lngWidth  = window.screen.availWidth-100;
	if (lngHeight > 1024) lngHeight = 1024;
	if (lngWidth > 1300) lngWidth = 1300; 
    
    //calculate the left and top positions
    leftPos = ((window.screen.availWidth - lngWidth) / 2) + "px";
    topPos = ((window.screen.availHeight - lngHeight) / 2) + "px";
    
    //resise the window
    strUrl = "ImmediateAdmin.aspx?SessionID=<%= sessionId %>&Phase=admin&Index=<%= immediateIndex %>&isgeneric=<%= isGeneric %>&height=" + lngHeight + "&width=" + lngWidth;
    window.dialogWidth = lngWidth + "px";
    window.dialogHeight = lngHeight + "px";
    window.dialogLeft = leftPos;
    window.dialogTop = topPos;
    window.navigate(strUrl);
}
//------------------------------------------------------------------------------------
//dont administer current item (skip next etc)

function btnNo_onClick()
{
    var strUrl;
    var phase;
    
    phase="<%= strPhase %>";
    if(phase == "cycle")
    {
        strUrl = "ImmediateAdmin.aspx?SessionID=<%= sessionId %>&Phase=increment";
        window.navigate(strUrl);        
    }
    else
	{
		m_closeFromFrame = true;
        window.close();
	}
}
    
//------------------------------------------------------------------------------------
//called from drug administration when done administering an item
function RemoteNextItem(blnIncrement)
{
    var strUrl;
   	var leftPos = (window.screen.availWidth-450) / 2;
	var topPos  = (window.screen.availHeight-300) / 2;
	var strPhase;

    strPhase = blnIncrement ? "increment" : "cycle";
    strUrl = "ImmediateAdmin.aspx?SessionID=<%= sessionId %>&Phase=" + strPhase;
    //resize the window
    window.dialogWidth = "450px";
    window.dialogHeight = "300px";
    window.dialogLeft = leftPos + "px";
    window.dialogTop = topPos + "px";
    window.navigate(strUrl);
}
//------------------------------------------------------------------------------------

</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>
<body scroll="no"<%= OnLoad %> sid="<%= sessionId %>" class="ImmediateAdministration">

<%
    If strPhase <> "admin" Then 
%>

    <table cellpadding="4" cellspacing="0" class="tblImmediateAdministration" height="100%" width="100%">
        <tr>
            <td valign="middle" align="center">
<%
    If strPhase = "cycle" Then
        ScriptButton_AdminRequest(sessionId, adminRequest, False, blnShowRequiredMessage, strStillRequiredText, strNoLongerRequiredText, canBeAdministered) 
    Else
        Response.Write("Administer STAT Immediate doses now?")
    End If
%>
           </td>
        </tr>
        <tr>
            <td style="font-weight:bold;font-size:10pt;" valign="middle">
<%
    If canBeAdministered Then
        If strPhase = "cycle" Then
            Response.Write("Do you wish to record administration of this dose now?")
        End If
    Else
        Response.Write("This dose can not be administered")
    End If
%>
            </td>
        </tr>
        <tr valign="top" style="height:40px">
            <td>
                <table>
                    <tr>
				        <td style="width:100%">&nbsp;</td>
				        <% If canBeAdministered Then%>
				        <td><button id="btnYes" accesskey="Y" onclick="return btnYes_onClick()">Yes</button></td>                    
				        <td><button id="btnNo" accesskey="N" onclick="return btnNo_onClick()">No</button></td>                    
				        <% Else%>
				        <td><button id="btnOk" accesskey="O" onclick="return btnNo_onClick()">Ok</button></td>
				        <td>&nbsp;</td>
				        <% End If%>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
<%
    Else
%>
<iframe application="yes" frameborder="1" height="100%" width="100%" src="AdministrationDSSCheck.aspx?SessionID=<%= sessionId %>&RequestID_Admin=<%= Generic.SessionAttribute(sessionId, DA_REQUESTID) %>&IsGenericTemplate=<%= Request.QueryString("isgeneric") %>"></iframe>
<%
End If
%>
</body>
</html>