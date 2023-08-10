<%@ Page language="vb" %>

<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>


<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<html>
<head>

<%
    Dim sessionId As Integer
    Const ATTACHEDNOTE_TYPE_DEFAULT As String = "Attached Note"
    Dim lngID As Integer
    Dim lngNoteID As integer
    Dim objOCSItem As OCSRTL10.OrderCommsItem
    Dim objNotes As OCSRTL10.NotesRead
    Dim DOM As XmlDocument
    Dim strImage As String 
    Dim colNotes As XmlNodeList
    Dim objNote As XmlElement
    Dim strNotes_XML As String = String.Empty
    Dim strMode As String 
    Dim strClass As String 
    Dim blnShowAll As Boolean
    Dim strReturn As String 
    Dim blnEnable As Boolean 
    Dim blnError As Boolean 
%>
<%
    'NOTESEDITORCONTENTS.aspx
    '
    'This page is contained within NotesEditor.aspx and contains all
    'of the actual mechanics of listing, viewing, and adding attached notes.
    '
    'It should never be called directly, always through NotesEditor.aspx
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '21Nov03 TH  Written
    '13Jun03 AE  Finished, with mods to original code to bring it up to date
    '-----------------------------------------------------------------------
%>

<script language="javascript" src="../sharedscripts/ocs/OCSShared.js"></script>

<%
    'Validate the session
    'Obtain the session ID from the querystring
    sessionId = CInt(Request.QueryString("SessionID"))

    'Read the notes for the item specified
    'Currently, we only display notes of this type.
    ''In future, we may also show other types, in which case this
    ''would remain the default.
    colNotes = Nothing
    strReturn = ""
    blnError = false
    'Get the ID and other variables from the querystring
    lngID = Request.QueryString("ID")
    If CStr(lngID) = "" Then 
        lngID = 0
    End IF
    lngID = CInt(lngID)
    blnShowAll = Request.QueryString("ShowAll")
    blnShowAll = CBool(blnShowAll)
    strMode = UCase(Request.QueryString("Mode"))
    'First check if we have to save anything
    If LCase(Request.QueryString("AddNew")) = "true" Then 
        'A new note has been entered
        objOCSItem = new OCSRTL10.OrderCommsItem()
        strReturn = objOCSItem.CreateAttachedNote(sessionId, CStr(Request.Form("dataXML")), "Attached Note", CStr(Request.QueryString("Mode")), CInt(lngID))
        objOCSItem = Nothing
    End IF
    'Or if we have to upadate the status of anything...
    If (Request.QueryString("SetEnabled") <> "") Then 
        lngNoteID = Request.QueryString("NoteID")
        If CStr(lngNoteID) = "" Then 
            lngNoteID = 0
        End IF
        lngNoteID = CInt(lngNoteID)
        blnEnable = (LCase(Request.QueryString("SetEnabled")) = "true")
        objOCSItem = new OCSRTL10.OrderCommsItem()
        strReturn = objOCSItem.UpdateAttachedNote(sessionId, CInt(lngNoteID), blnEnable)
        objOCSItem = Nothing
    End IF
    'strReturn will contain some broken rules if anything went wrong:
    If Ascribe.Common.BrokenRules.RulesBroken(strReturn) Then 
        Response.Write("<table style=""border: 1 solid; font-size:large""><tr><td>Unable to save note!</td></tr>")
        Response.Write("<tr><td>")
        Response.Write(Ascribe.Common.BrokenRules.GetBrokenRulesTable_HTML(strReturn))
        Response.Write("</td></tr></table>")
        blnError = true
    End IF
    'Now retrieve a list of notes to display in the list:
    'Check for the correct mode and retrieve data
    objNotes = new OCSRTL10.NotesRead()
    Select Case strMode
    Case "PENDING"
        strNotes_XML = objNotes.AttachedNotesByPendingItemXML(sessionId, CInt(lngID), CBool((Not CDbl(blnShowAll))), ATTACHEDNOTE_TYPE_DEFAULT)
    Case "REQUEST"
        strNotes_XML = objNotes.AttachedNotesByRequestXML(sessionId, CInt(lngID), CBool((Not CDbl(blnShowAll))), ATTACHEDNOTE_TYPE_DEFAULT)
    Case "RESPONSE"
        strNotes_XML = objNotes.AttachedNotesByResponseXML(sessionId, CInt(lngID), CBool((Not CDbl(blnShowAll))), ATTACHEDNOTE_TYPE_DEFAULT)
    Case Else 
        'Unknown mode - shouldn't happen
        Response.Write("Unknown [mode] parameter specified!")
        Response.End()
    End Select
    objNotes = Nothing
    'Load into the DOM and return a collection of note elements
    'Response.write "<textarea rows=10>" & strNotes_XML & "</textarea>"
    DOM = new XmlDocument()
    If DOM.TryLoadXml(strNotes_XML) Then
        colNotes = DOM.SelectNodes("attachednotes/Note")
    End If
%>


<script language="javascript" src="scripts/NotesEditor.js"></script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/NotesEditor.css" />
<link rel="stylesheet" type="text/css" href="../OrderEntry/style/OrderEntry.css" />
</head>

<body id="notesBody"
		oncontextmenu="return false;"
		onselectstart="return false;"
		onload="Initialise();"
		sid="<%= sessionId %>"
		showall="<%= blnShowAll %>"
		itemid="<%= lngID %>"
		ascmode="<%= strMode %>"
<%
    If blnError Then 
        Response.Write("scroll=""yes"" ")
    End IF
%>

		>
	<table id="notesTable" 
			 class="NotesContainer" 
			 cellpadding="1" cellspacing="0"
			 >
			 
			<tr class="ControlBar">
				<td colspan="4">Attached Notes (
<%
    If blnShowAll Then 
        Response.Write("showing ALL notes")
    Else
        Response.Write("showing ACTIVE notes")
    End IF
%>

				)			
				</td>
			</tr>
			<tr class="ControlBar">
				<td style="width:50%" colspan="2">Note</td>
				<td>Entered By</td>
				<td>On</td>
			</tr>
<%
    'Script a row for each note
    strImage = Ascribe.Common.Constants.IMAGE_DIR & Ascribe.Common.Constants.GetImageByClass("attached note")
    If Not colNotes Is Nothing Then 
        For Each objNote In colNotes
            'determine the class; this depends on whether the item is
            'enabled or disabled
            strClass = "NoteRow"
            If  objNote.GetAttribute("Enabled") <> "1" Then 
                strClass = strClass & " Disabled"
            End IF
            Response.Write("<tr class=""" & strClass & """ " & "onclick=""HighlightRow(this)"" " & "ondblclick=""ViewNote(this)"" " & "dbid=""" & objNote.GetAttribute("NoteID") & """ " & "enabled=""" & objNote.GetAttribute("Enabled") & """ " & "title=""Double-click to view this note"" " & ">" & "<td class=""" & strClass & """ style=""width:20px;""><img src=""" & strImage & """></img></td>" & "<td class=""" & strClass & """ style=""width:50%; word-break:break-all; word-wrap:break-word"" noteid=""" & objNote.GetAttribute("NoteID") & """ " & ">" & objNote.GetAttribute("Description") & "</td>" & "<td class=""" & strClass & """ style=""width:25%"" >" & objNote.GetAttribute("CreatedUser") & "</td>" & "<td class=""" & strClass & """ style=""width:25%"" >" & objNote.GetAttribute("CreatedDate") & "</td>" & "</tr>")
        Next
    End IF
%>
		

			<tr ispadding="1" style="height:100%;width:100%" ><td>&nbsp;</td></tr>
			<tr style="background-color:#D6E3FF">
				<td colspan="4">								
					<table align="right">
						<tr>
							<td>
								<button accesskey="v" id="cmdShow" onclick="ViewNote(m_objCurrentRow);"
								 		  title="Click here to view the selected note"
								 		  disabled
								 		  >
										  <u>V</u>iew
								</button>
							</td>							
							<td width=100%>&nbsp;</td>
							<td>
								<button accesskey="d" id="cmdToggleActive" onclick="ToggleNoteActive();"
										  title="Click here to deactivate this note."
										  disabled
		   							  >
		   							  <u>D</u>eactivate
		   					</button>
							</td>
							<td>
								<button accesskey="a" id="cmdAdd" onclick="AddNote();"
										  title="Click here to attach a new note."
		   							  >
		   							  <u>A</u>dd
		   					</button>
							</td>
							<td>
							<!-- F0048971 ST 24Mar09    Updated shortcut keys so that we dont have duplicates. -->
								<button accesskey="w" id="cmdView" 
										  onclick="ToggleView();"
										  title="Click here to toggle between showing only active notes, and showing all notes, including those which have been disabled"
										  >
<%
    If blnShowAll Then 
        Response.Write("Sho<u>w</u> Active")
    Else
        Response.Write("Sho<u>w</u> All")
    End IF
%>
							
								</button>
							</td>
							<td>
								<button accesskey="c" id="cmdClose" onclick="javascript:window.close();"
										  title="Click here to close the window"
										  ><u>C</u>lose</button>
							</td>			
						</tr>
					</table>		
				</td>
			</tr>
</table>

<xml id="parsingIsland"></xml>

<form id="frmSave" method="post" >
	<input type="hidden" id="dataXML" name="dataXML" />
</form>

	
</body>
</html>
