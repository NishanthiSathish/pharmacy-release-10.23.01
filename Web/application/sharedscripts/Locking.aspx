<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<!--#include file="ASPHeader.aspx"-->

<%
    Dim lngSessionID As Integer 
    Dim strObjectType As String 
    Dim strAction As String 
    Dim lngID As Integer 
    Dim objEntityLock As ENTRTL10.EntityLock
    Dim objRequestLock As OCSRTL10.RequestLock
    Dim strResultXML As String  = ""
    Dim strOrderXML As String 
    Dim xmldoc As XmlDocument
    Dim strRequestString As String = ""
%>
<%
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strObjectType = CStr(Request.QueryString("ObjectType"))
    strAction = CStr(Request.QueryString("Action"))
    strOrderXML = CStr(Request.Form("txtOrderXML"))
    Select Case strObjectType
    Case "entity"
        objEntityLock = new ENTRTL10.EntityLock()
        lngID = Ascribe.Common.Generic.CIntX(Request.QueryString("ID"))
        Select Case strAction
        Case "unlock"
            On Error Resume Next
            strResultXML = objEntityLock.UnlockMyEntityLock(lngSessionID, lngID)
            If Err.Number <> 0 Then 
                strResultXML = "Error unlocking patient: " & Err.Number & " " & Err.Description
            End IF
            On Error Goto 0
        Case "lock"
            On Error Resume Next
            strResultXML = objEntityLock.LockEntity(lngSessionID, lngID, false)
            If Err.Number <> 0 Then 
                strResultXML = "Error locking patient: " & Err.Number & " " & Err.Description
            End IF
            On Error Goto 0
        End Select
    Case "request"
        objRequestLock = new OCSRTL10.RequestLock()
        Select Case strAction
        Case "unlock"
            On Error Resume Next
            strResultXML = objRequestLock.UnlockMyRequestLocks(lngSessionID)
            If Err.Number <> 0 Then 
                strResultXML = "Error unlocking orders: " & Err.Number & " " & Err.Description
            End IF
            On Error Goto 0
        Case "lock"
            If Request.ServerVariables("REQUEST_METHOD") = "POST" Then 
                xmldoc = new XmlDocument()
                ' xmldoc.async = false
                ' xmldoc.validateOnParse = false
                strRequestString = Request.Form("txtOrderXML")'JA/AI 31-10-07 code 38
                Dim xmlLoaded As Boolean = False

                If xmldoc.TryLoadXml(strRequestString) then 
                    strOrderXML = CStr(xmldoc.OuterXml)
                    strResultXML = objRequestLock.LockRequests(lngSessionID, strOrderXML, false)
                End IF
            End IF
        End Select
    End Select
    Response.Write(strResultXML)
%>
