<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<html>
<%
    Dim sessionId As Integer
    Const TABLE_DEFAULT As String = "AttachedNoteText"
    Dim objTableRead As ICWRTL10.TableRead
    Dim strTable As String
    Dim strOrderFormURL As String 
    Dim FormCallType As String = String.Empty
    Dim lngTableID As Integer 
    Dim lngRowID As Integer
%>
<%
    '--------------------------------------------------------------------------------------------
    '
    'EditNote.aspx
    '
    'Page used to view / enter an attached note.
    'Contains a single instance of OrderForm.aspx, used as the
    'editing form.
    'This page is called from NotesEditor.aspx; do not call it directly.
    'All saving is done by NotesEditor.aspx.
    '
    'Querystring Parameters:
    '
    'SessionID		(mandatory)						Standard sessionID
    'NoteID			(optional)						To view an existing note, pass its ID as NoteID
    'TableName		(optional)						If left blank, an ordinary attached note is shown (tablename = "AttachedNoteText")
    'Otherwise, a different table name can be specified
    '
    'Modification History:
    '27Jun03 AE  Written
    '09Feb05 AE  Added Type parameter and associated code.
    '--------------------------------------------------------------------------------------------
%>

<head>


<%
    'Validate the session
    'Obtain the session ID from the querystring
    sessionId = CInt(Request.QueryString("SessionID"))
    'Build up the URL for the order form component.
    'First retrieve the tableID of the specified table:
    strTable = Request.QueryString("TableName")
    '09Feb05 AE  Added tablename as a parameter
    If strTable = "" Then 
        strTable = TABLE_DEFAULT
    End IF
    objTableRead = new ICWRTL10.TableRead()
    lngTableID = CInt(objTableRead.GetIDFromDescription(sessionId, CStr(strTable)))
    '08Sep04 AE  Restructured attached notes.
    objTableRead = Nothing
    'Check for a noteID
    lngRowID = Generic.CIntX(Request.QueryString("NoteID"))
    'Build the URL
    strOrderFormURL = "../OrderEntry/OrderForm.aspx" & "?SessionID=" & sessionId & "&TableID=" & lngTableID & "&Dataclass=Note" & "&DataRow=" & lngRowID
    'If viewing a note, make the form read only (it is not possible to edit attached notes)
    If lngRowID > 0 Then
        strOrderFormURL = strOrderFormURL & "&Display=True"
    End If
    '* DPA 2008.03.26 - passed to prevent 'cancel' btn being rendered below...
    If CStr(Request.QueryString("FormCallType")) = "AttachedNoteStatusList" Then
        FormCallType = "AttachedNoteStatusList"    
    End If
%>


<title>
<%
    If lngRowID > 0 Then
        Response.Write("Viewing Attached Note")
    Else
        Response.Write("New Note")
    End If
%>

</title>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/NotesEditor.css" />

</head>

<script language="javascript" src="../sharedscripts/icwFunctions.js" ></script>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "EditNote.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<script language="javascript">

//=============================================================================================
function IndicateOrderFormReady() {
//Fires once the order form has finished loading.	
	 
	void ResizePage();
	void document.frames['fraNote'].FocusFirstControl()
	
}

//=============================================================================================

function ResizePage() {
    
	//Resize the order form
	void document.frames['fraNote'].ResizeOrderForm(document.frames['fraNote'].document, false);
}

//=============================================================================================

function CloseWindow(blnCancel) {
    if (blnCancel == false) {
        //Return the notes data from the form
        var strNoteXML = document.frames['fraNote'].GetDataFromForm();
        if (strNoteXML.indexOf('<data filledin="true"') == -1) {
            var strMsg = 'Not all mandatory fields have been completed.\nYou must complete all coloured fields.'
            Popmessage(strMsg, 'Unable To Save');
        }
        else {
            window.returnValue = strNoteXML;
            window.close();
        }
    }
    else {
        window.returnValue = 'cancel';
        window.close();
    }

/* 	if (blnCancel) {
	//Just close without saving
		window.returnValue = 'cancel';
		window.close();
	}
	else {
	//Return the notes data from the form
		var strNoteXML = document.frames['fraNote'].GetDataFromForm();
		if (strNoteXML.indexOf('<data filledin="true"') == -1)
		{
			var strMsg = 'Not all mandatory fields have been completed.\nYou must complete all coloured fields.'
			Popmessage(strMsg, 'Unable To Save');
		}
		else
		{
			window.returnValue = strNoteXML;
			window.close();
		}
	}
	*/
}

//=============================================================================================
function SetChanged(blnChanged) {
	//Raised by the order form, not used here
}
//=============================================================================================

function FormFocus(formID) {
	//Raised by the order form, not used here
}

// F0079163 ST 01Mar10 When closing the window, either by button or the dialog control box then check what state to return so that an error doesnt occur
function QueryExit() {
    if (window.returnValue == 'cancel') {
        CloseWindow(true);
    }
    else {
        CloseWindow(false);
    }
}

// F0079177 ST 01Mar10 Added an onload event to the iframe which will fire this event when the page has loaded
function EnableOKButton() {
    cmdOK.disabled = false;
}

</script>
<body id="notesBody"
		oncontextmenu="return false;"
		onselectstart="return false;"
		sid="<%= Request.QueryString("SessionID") %>"
		onresize="ResizePage(false);"
		onload="window.returnValue='cancel';"
		onbeforeunload="QueryExit();"
		>

<table align="right" 
		 height="100%"
		 width="100%"
		 >
	<tr height="100%">
		<td colspan="3">
		
			<iframe id="fraNote"
					  width="100%"
					  height="100%"
					  src="<%= strOrderFormURL %>"
					  scrolling="no"
					  class="NotesContainer"
					  application="yes"
					  onload="EnableOKButton();"
					  >
			</iframe>            
		</td>
	</tr>

	<tr>
		<td width=100%>&nbsp;</td>
		<td>
			<button class= stdButton accesskey="o" disabled id="cmdOK" onclick="CloseWindow(false);"><u>O</u>K</button>
		</td>
		<%If (FormCallType <> "AttachedNoteStatusList") Then %>
		<td>
			<button class= stdButton accesskey="c" id="cmdCancel" onclick="CloseWindow(true);"><u>C</u>ancel</button>
		</td>
		<%End If%>
	</tr>
</table>		
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
