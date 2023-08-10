<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<%@Import Namespace="Ascribe.Common" %>
<%@Import Namespace="Ascribe.Common.Dss" %>
<%@Import namespace="Ascribe.Common.StopAndAmend" %>
<%@Import Namespace="Ascribe.Common.Generic"  %>
<%@Import Namespace="Ascribe.Common.OCSStatusMessage" %>

<html>

<%
    Dim SessionID As Integer
	Dim xmlDOM As XmlDocument
	Dim xmlDOMOrderSet As XmlDocument
	Dim xmlNode As XmlElement
	Dim xmlNodeOrderSet As XmlElement
	Dim xmlNodes As XmlNodeList
	Dim xmlNodesOrderSet As XmlNodeList
    Dim strData_XML As String = String.Empty
    Dim strOrderSet_XML As String 
    Dim RequestID As Integer 
    Dim strAction As String = String.Empty
	Dim objOrderCommsItemRead As OCSRTL10.OrderCommsItemRead
	Dim objNotesRead As OCSRTL10.NotesRead
    Dim lngParentID As Integer 
    Dim lngItemID As Integer 
    Dim lngTableID As Integer 
    Dim strReturn_XML As String 
    Dim strStatus_XML As String = String.Empty
    Dim strSortedData As String
    Dim blnIsComplete As Boolean
    Dim blnNoteIsCancelled As Boolean 
	Dim statusDOM As XmlDocument
    Dim strRequestType As String 
    Dim strNoteReturnXML As String
    Dim objSettingRead As GENRTL10.SettingRead
    Dim blnLimitSelection As Boolean
    Dim objRequestLock As OCSRTL10.RequestLock
    Dim strLockDetails As String = String.Empty
    Dim strLockMessage As String = String.Empty
    Dim xmldocLock As XmlDocument
    Dim xmleleLock As XmlElement

%>

<head>
<link rel="stylesheet" type="text/css" href="../../style/stopandamend.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<script language="javascript" src="scripts/PrescriptionCancellation.js"></script>
<script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
<script language="javascript" src="../sharedscripts/Locking.js"></script>


</head>

<%
    '-----------------------------------------------------------------------------------------
    'StopAndAmend.aspx
    '
    '
    'Allows handling of items for either STOPPING or AMENDING
    '
    '
    'Modification History:
    '03Oct07    ST     Written
    '12Aug09    RAMS   Added XMLReturn to unescape the XML literals (F0060966)
    '
    '-----------------------------------------------------------------------------------------
    SessionID = CInt(Request.QueryString("SessionID"))

    objSettingRead = New GENRTL10.SettingRead()
    If objSettingRead.GetValue(SessionID, "OCS", "StopAmend", "LimitSelection", "0") = "1" Then
        blnLimitSelection = True
    End If
	objSettingRead = Nothing

    
    Select Case LCase(Request.QueryString("Action"))
    Case "stop"
        'stopping/cancelling item(s) - get our data from session
        strData_XML = SessionAttribute(SessionID, "OrderEntry/StopOrders")
        strAction = "Stop"
    Case "amend"
        'amending items(s)
        strData_XML = SessionAttribute(SessionID, "OrderEntry/StopOrders")
        strAction = "Amend"
    End Select
    
    'F0086322 14May10 JMei check if any selected prescription is locked
    If strData_XML <> "" Then
        strStatus_XML = BuildMasterStatusNoteList(strData_XML, SessionID)
        statusDOM = New XmlDocument()
        statusDOM.TryLoadXml(strStatus_XML)
        lngParentID = 0
        'we have some data stored so load it up
        strSortedData = SortXMLByDescription(strData_XML)
        If CStr(strSortedData) <> "" Then
            xmlDOM = New XmlDocument()
            
            If xmlDOM.TryLoadXml(strSortedData) Then
                xmlNodes = xmlDOM.SelectNodes("//item")
                
                objRequestLock = New OCSRTL10.RequestLock()
                For Each xmlNode In xmlNodes
                    If xmlNode.GetAttribute("class").ToString().ToLower() = "request" Then
                        RequestID = CInt(xmlNode.GetAttribute("id"))
                        objRequestLock = New OCSRTL10.RequestLock()
                        strLockDetails = objRequestLock.LockRequest(SessionID, CInt(RequestID), False)
                        If strLockDetails <> "" Then
                            strLockMessage = "<table width=100% height=100% ><tr><td align=center ><table border=2><tr><td style='background-color:white; padding: 20px' align=center>" & "<b>Order is currently locked</b>"
                   
                            xmldocLock = New XmlDocument()
                            xmldocLock.TryLoadXml(strLockDetails)
                            xmleleLock = xmldocLock.SelectSingleNode("*")
                            strLockMessage = strLockMessage & "<br><br>by" & "<br><br>User: " & xmleleLock.GetAttribute("UserFullName") & "<br>Terminal: " & xmleleLock.GetAttribute("TerminalName") & "<br>Desktop: " & xmleleLock.GetAttribute("DesktopName") & "<br>Date: " & Generic.TDate2DateTime(xmleleLock.GetAttribute("CreationDate"))
                            strLockMessage = strLockMessage & "</td></tr></table></td></tr></table>"
                            xmldocLock = Nothing
                            Exit For
                        End If
                    End If
                Next
                xmlNodes = Nothing
            End If
            xmlDOM = Nothing
        End If
            statusDOM = Nothing
        End If

%>

<body sid="<%=SessionID%>" limitselection="<%=blnLimitSelection%>" action="<%=strAction%>" bgcolor="#EEEEEE" onbeforeunload="void CloseDialog();" onload="page_onload();">
<%
    'F0086322 14May10 JMei Only display Lock Message if anything is locked
    If strLockDetails <> "" Then
        Response.Write(strLockMessage)
    Else
        
        %>

<br>
<div>
<%
    If strAction = "Stop" Then 
%>

		<img src="../../images/developer/stop_large.gif" width="32" height="32" align="middle">&nbsp;The following items will be stopped:
<%
    Else
%>

		<img src="../../images/developer/amend_large.gif" width="32" height="32" align="middle">&nbsp;The following items will be amended:
<%
    End IF
%>

</div>
<br>
<div style="overflow:scroll; height:550px; width:100%; border:1px solid; background-color:#FFFFFF; white-space: nowrap;">
				<table width="100%" style="font-family:Arial;font-size:14px;">	<!-- cellpadding="2" cellspacing="2" border="0" width="100%" ">-->
<%
	If strData_XML <> "" Then
        strStatus_XML = BuildMasterStatusNoteList(strData_XML, SessionID)
		statusDOM = New XmlDocument()
        statusDOM.TryLoadXml(strStatus_XML)
		lngParentID = 0
		'we have some data stored so load it up
		strSortedData = SortXMLByDescription(strData_XML)
		If CStr(strSortedData) <> "" Then
			xmlDOM = New XmlDocument()

            If xmlDOM.TryLoadXml(strSortedData) Then

                xmlNodes = xmlDOM.SelectNodes("//item")
                For Each xmlNode In xmlNodes
                    RequestID = CInt(xmlNode.GetAttribute("id"))
                    'Get any child nodes if this is an orderset
                    objOrderCommsItemRead = New OCSRTL10.OrderCommsItemRead()
                    strOrderSet_XML = objOrderCommsItemRead.RequestOrdersetChildren(SessionID, CInt(RequestID), False, False)
                    objOrderCommsItemRead = Nothing
                    If strOrderSet_XML <> "" Then
                        'An orderset with its children
                        xmlDOMOrderSet = New XmlDocument()

                        If xmlDOMOrderSet.TryLoadXml(strOrderSet_XML) Then
                            'Put the outer orderset info into the table
                            xmlNodeOrderSet = xmlDOMOrderSet.SelectSingleNode("/item")
                            xmlNodesOrderSet = xmlNodeOrderSet.SelectNodes("item")
                            Dim OrdersetPatiallyComplete As Boolean = False
                            For Each xmlNodeOrderSet In xmlNodesOrderSet
                                blnNoteIsCancelled = False
                                objOrderCommsItemRead = New OCSRTL10.OrderCommsItemRead()
                                strReturn_XML = objOrderCommsItemRead.GetXML(SessionID, CInt(xmlNodeOrderSet.GetAttribute("tableid")), CInt(xmlNodeOrderSet.GetAttribute("id")))
                                strRequestType = GetRequestType(xmlNodeOrderSet.GetAttribute("ocstypeid"), SessionID)
                                
                                'find out if this item is complete or not
                                Dim lItemRequestID As Integer = 0
                                If CStr(xmlNodeOrderSet.GetAttribute("ocstype")) = "note" Then
                                    lItemRequestID = CInt(RequestID)    ' the id for a note returned by RequestOrdersetChildren is the NoteID not the request id
                                Else
                                    lItemRequestID = CInt(xmlNodeOrderSet.GetAttribute("id"))
                                End If
                                blnIsComplete = objOrderCommsItemRead.IsRequestComplete(SessionID, lItemRequestID)
                                If blnIsComplete Then
                                    OrdersetPatiallyComplete = True
                                End If
                                
                                'if this is a note we need to see if it has already been stopped/cancelled
                                If CStr(xmlNodeOrderSet.GetAttribute("ocstype")) = "note" Then
                                    objNotesRead = New OCSRTL10.NotesRead()
                                    strNoteReturnXML = objNotesRead.NoteCancellationByNoteID(SessionID, CInt(xmlNodeOrderSet.GetAttribute("id")))
                                    objNotesRead = Nothing
                                    If CStr(strNoteReturnXML) <> "" Then
                                        blnNoteIsCancelled = True
                                    End If
                                End If
                                xmlNodeOrderSet.SetAttribute("iscomplete", blnIsComplete.ToString())
                                xmlNodeOrderSet.SetAttribute("iscancelled", blnNoteIsCancelled.ToString())
                            Next
                            xmlNodeOrderSet = xmlDOMOrderSet.SelectSingleNode("/item")
                            xmlNodesOrderSet = xmlNodeOrderSet.SelectNodes("item")
                            lngParentID = CIntX(xmlNodeOrderSet.GetAttribute("id"))
                            lngTableID = CIntX(xmlNodeOrderSet.GetAttribute("tableid"))
                            objOrderCommsItemRead = New OCSRTL10.OrderCommsItemRead()
                            strReturn_XML = objOrderCommsItemRead.GetXML(SessionID, CInt(lngTableID), CInt(lngParentID))
                            objOrderCommsItemRead = Nothing
                            strRequestType = GetRequestType(xmlNodeOrderSet.GetAttribute("ocstypeid"), SessionID)
%>

												<tr>
													<td width="450" title="<%= XMLReturn(xmlNodeOrderSet.GetAttribute("description")) %>">
													<span style="white-space:nowrap; width:30em; overflow:hidden; text-overflow:ellipsis;">
													<input name="check" type="checkbox" 
														dbid="<%= xmlNodeOrderSet.GetAttribute("id") %>"
														dbid_parent="-1"
														itemclass="<%= xmlNodeOrderSet.GetAttribute("dataclass") %>"
														description="<%= xmlNodeOrderSet.GetAttribute("description") %>"
														detail="<%= xmlNodeOrderSet.GetAttribute("description") %>"
														tableid="<%= xmlNodeOrderSet.GetAttribute("tableid") %>"
														productid="<%= xmlNodeOrderSet.GetAttribute("productid") %>"
														ocstype="<%= xmlNodeOrderSet.GetAttribute("ocstype") %>"
														ocstypeid="<%= xmlNodeOrderSet.GetAttribute("ocstypeid") %>"
														autocommit="<%= xmlNodeOrderSet.GetAttribute("autocommit") %>"
														requesttype="<%= strRequestType %>"
														partialcomplete="<%= OrdersetPatiallyComplete.ToString() %>"
														<%
															If blnLimitSelection = False Then
														%>
														onclick="orderset_onclick(this)">&nbsp;<%=XMLReturn(xmlNodeOrderSet.GetAttribute("description"))%>
														<%
															Else
														%>
														onclick="orderset_onclick_limited(this)">&nbsp;<%=XMLReturn(xmlNodeOrderSet.GetAttribute("description"))%>
														<%
															End If
														%>
                                                    </span></td>
													<td width="100%"><%= GetItemDate(strReturn_XML, xmlNodeOrderSet.GetAttribute("ocstype")).ToString ( "dd/MM/yyyy" ) %></td>
													<td>&nbsp;</td>
												</tr>
<%
                            For Each xmlNodeOrderSet In xmlNodesOrderSet
                                blnNoteIsCancelled = (xmlNodeOrderSet.GetAttribute("iscancelled") = Boolean.TrueString)
                                blnIsComplete = (xmlNodeOrderSet.GetAttribute("iscomplete") = Boolean.TrueString)
        strRequestType = GetRequestType(xmlNodeOrderSet.GetAttribute("ocstypeid"), SessionID)
%>

												<tr>
													<td width="450" title="<%= xmlNodeOrderSet.GetAttribute("description") %>">
													<span style="white-space:nowrap; width:30em; overflow:hidden; text-overflow:ellipsis;">&nbsp;&nbsp;&nbsp;
													<input name="check" type="checkbox" 
<%
                                If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
disabled<%
                                End IF
%>

														dbid="<%= xmlNodeOrderSet.GetAttribute("id") %>" 
														dbid_parent="<%= lngParentID %>"
														itemclass="<%= xmlNodeOrderSet.GetAttribute("dataclass") %>"
														description="<%= xmlNodeOrderSet.GetAttribute("description") %>"
														detail="<%= xmlNodeOrderSet.GetAttribute("description") %>"
														tableid="<%= xmlNodeOrderSet.GetAttribute("tableid") %>"
														productid="<%= xmlNodeOrderSet.GetAttribute("productid") %>"
														ocstype="<%= xmlNodeOrderSet.GetAttribute("ocstype") %>"
														ocstypeid="<%= xmlNodeOrderSet.GetAttribute("ocstypeid") %>"
														autocommit="<%= xmlNodeOrderSet.GetAttribute("autocommit") %>"
														requesttype="<%= strRequestType %>"
														complete="<%= blnIsComplete %>"
														onclick="ordersetitem_onclick(this)">
														&nbsp;
<%
                                If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
<font color="#999999"><%
                                End IF
%>

<%= xmlNodeOrderSet.GetAttribute("description") %>
<%
                                If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
</font><%
                                End IF
%>

														</span></td>
<% 
                                ' Display date if not a note
                                If CStr(xmlNodeOrderSet.GetAttribute("ocstype")) <> "note" Then
%>														
													<td width="100%"><%= GetItemDate(strReturn_XML, xmlNodeOrderSet.GetAttribute("ocstype")).ToString ( "dd/MM/yyyy" ) %>&nbsp;</td>
<%
                                Else
%>									
                                                    <td width="100%">&nbsp;</td>				
<%
                                End If
%>													

<%
                                If CStr(xmlNodeOrderSet.GetAttribute("ocstype")) = "note" And blnNoteIsCancelled Then 
%>

														<td>Cancelled</td>
<%
                                ElseIf CStr(xmlNodeOrderSet.GetAttribute("ocstype")) = "note" And blnNoteIsCancelled = false Then 
%>

														<td>&nbsp;</td>
<%
                                Else
    If IsPrescriptionAdministered(CInt(xmlNodeOrderSet.GetAttribute("id")), SessionID) Then
%>

														<td id="Td1" width="100" align="left"><a href="AdministrationRecord.aspx" onclick="AdministrationRecord(<%= SessionID %>,<%= CInt(xmlNodeOrderSet.GetAttribute("id")) %>); return false">Administration</a>&nbsp;|&nbsp;</td>																	
<%
                                    Else
%>

														<td id="Td2" width="100" align="left"></td>
<%
                                    End IF
If IsPrescriptionDispensed(CInt(xmlNodeOrderSet.GetAttribute("id")), SessionID) Then
%>

														<td id="Td3" width="100" align="left"><a href="DispensingRecord.aspx" onclick="DispensingRecord(<%= SessionID %>,<%= CInt(xmlNodeOrderSet.GetAttribute("id")) %>); return false">Dispensed</a>&nbsp;|&nbsp;</td>
<%
                                    Else
%>

														<td id="Td4" width="100" align="left"></td>
<%
                                    End IF
                                    If blnIsComplete Then 
                                        'completed item just show complete
%>

																<td>Complete</td>
<%
                                    Else
                                        If Not IsPrescription(strRequestType) Then 
        ScriptStatusNotes(CInt(xmlNodeOrderSet.GetAttribute("id")), statusDOM, SessionID)
                                        Else
                                            'with ordersets the orderset contents dont have their requeststatus set so we use the orderset ones instead
        ScriptStatusNotes(lngParentID, statusDOM, SessionID)
                                        End IF
                                    End IF
                                End IF
%>

												</tr>
<%
                            Next
                            xmlNodesOrderSet = Nothing
                        End IF
                        xmlDOMOrderSet = Nothing
                    Else
                        'Non orderset item
                        lngItemID = CIntX(xmlNode.GetAttribute("id"))
                        lngTableID = CIntX(xmlNode.GetAttribute("tableid"))
                        objOrderCommsItemRead = new OCSRTL10.OrderCommsItemRead()
strReturn_XML = objOrderCommsItemRead.GetXML(SessionID, CInt(lngTableID), CInt(lngItemID))
strRequestType = GetRequestType(xmlNode.GetAttribute("ocstypeid"), SessionID)
                        'find out if this item is complete or not
                        blnIsComplete = objOrderCommsItemRead.IsRequestComplete(SessionID, lngItemID)
                        'if this is a note we need to see if it has already been stopped/cancelled
                        If CStr(xmlNode.GetAttribute("ocstype")) = "note" Then 
                            objNotesRead = new OCSRTL10.NotesRead()
                            strNoteReturnXML = objNotesRead.NoteCancellationByNoteID(SessionID, CInt(xmlNode.GetAttribute("id")))
                            objNotesRead = Nothing
                            If CStr(strNoteReturnXML) <> "" Then 
                                blnNoteIsCancelled = true
                            End IF
                        End IF
                        objOrderCommsItemRead = Nothing
%>

											<tr>
												<td width="450" title="<%= xmlNode.GetAttribute("description") %>">
												<span style="white-space: nowrap; width: 30em; overflow: hidden; text-overflow: ellipsis;">
												<input name="check" type="checkbox" 
<%
                        If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
disabled<%
                        End IF
%>

													dbid="<%= xmlNode.GetAttribute("id") %>"
													dbid_parent="-1"
													itemclass="<%= xmlNode.GetAttribute("class") %>"
													description="<%= xmlNode.GetAttribute("description") %>"
													detail="<%= xmlNode.GetAttribute("detail") %>"
													tableid="<%= xmlNode.GetAttribute("tableid") %>"
													productid="<%= xmlNode.GetAttribute("productid") %>"
													ocstype="<%= xmlNode.GetAttribute("ocstype") %>"
													ocstypeid="<%= xmlNode.GetAttribute("ocstypeid") %>"
													autocommit="<%= xmlNode.GetAttribute("autocommit") %>"
													requesttype="<%= strRequestType %>"
													complete="<%= blnIsComplete %>"
													onclick="item_onclick(this)">
<%
                        If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
<font color="#999999"><%
                        End IF
%>

<%= xmlNode.GetAttribute("description") %>
<%
                        If CBool(blnIsComplete) Or blnNoteIsCancelled Then 
%>
</font><%
                        End IF
%>

													</span></td>
<% 
                                ' Display date if not a note
                                If CStr(xmlNode.GetAttribute("ocstype")) <> "note" Then
%>														
													<td width="100%"><%= GetItemDate(strReturn_XML, xmlNode.GetAttribute("ocstype")).ToString ( "dd/MM/yyyy" ) %>&nbsp;</td>
<%
                                Else
%>									
                                                    <td width="100%">&nbsp;</td>				
<%
                                End If
%>													

<%
                        If CStr(xmlNode.GetAttribute("ocstype")) = "note" And blnNoteIsCancelled Then 
%>

													<td>Cancelled</td>
<%
                        ElseIf CStr(xmlNode.GetAttribute("ocstype")) = "note" And blnNoteIsCancelled = false Then 
%>

													<td>&nbsp;</td>
<%
                        Else
    If IsPrescriptionAdministered(CInt(xmlNode.GetAttribute("id")), SessionID) Then
%>

													<td id="Administration" width="100" align="left"><a href="AdministrationRecord.aspx" onclick="AdministrationRecord(<%= SessionID %>,<%= CInt(xmlNode.GetAttribute("id")) %>); return false">Administration</a>&nbsp;|&nbsp;</td>																	
<%
                            Else
%>

													<td id="Administration" width="100" align="left"></td>
<%
                            End IF
If IsPrescriptionDispensed(CInt(xmlNode.GetAttribute("id")), SessionID) Then
%>

													<td id="Dispensing" width="100" align="left"><a href="DispensingRecord.aspx" onclick="DispensingRecord(<%= SessionID %>,<%= CInt(xmlNode.GetAttribute("id")) %>); return false">Dispensed</a>&nbsp;|&nbsp;</td>
<%
                            Else
%>

													<td id="Dispensing" width="100" align="left"></td>
<%
                            End IF
                            If blnIsComplete Then 
                                'completed item just show complete
%>

															<td>Complete</td>
<%
                            Else
                                If Not IsPrescription(strRequestType) Then 
        ScriptStatusNotes(CInt(xmlNode.GetAttribute("id")), statusDOM, SessionID)
                                Else
                                End IF
    ScriptStatusNotes(CInt(xmlNode.GetAttribute("id")), statusDOM, SessionID)
                            End IF
                        End IF
%>

											</tr>
<%
                    End IF
                Next
                xmlNodes = Nothing
            End IF
            xmlDOM = Nothing
        End IF
        statusDOM = Nothing
    End IF
%>

				</table>
</div>
<br>
<div align="right">
    <input type="button" id="btnOK" value="OK" style="width:75px;" onclick="btnOK_onclick()">&nbsp;<input type="button" id="btnCancel" value="Cancel" style="width:75px;" onclick="btnCancel_onclick()">
    <!-- XML Island for status notes types-->
</div>
<%
    End If
%>
<xml id="statusnotesXML"><%= strStatus_XML %></xml>
</body>

</html>

