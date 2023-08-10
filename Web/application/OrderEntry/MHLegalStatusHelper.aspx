<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="OCSRTL10" %>
<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim Mode As String = Request.QueryString("Mode")
    Dim LegalStatusGUID As String = Request.QueryString("LegalStatusGUID")
    Dim FormID As Integer           
                  
    Dim Result As String = "Bad Mode or null GUID"
    Dim mhaForm As MHAForm = New MHAForm()
    
    Try
        If Not String.IsNullOrEmpty(LegalStatusGUID) Then
            Select Case Mode
                Case "GET"
                    Result = mhaForm.GetLinkedSmartFormGUIDForLegalStatusByGUID(SessionID, LegalStatusGUID)
                Case "SET"
                    FormID = Integer.Parse(Request.QueryString("FormID"))
                    Result = mhaForm.SetLinkedSmartFormIDForLegalStatusByGUID(SessionID, LegalStatusGUID, FormID)
            End Select
            Response.Write(Result)
        End If
    Catch ex As Exception
        Response.Write(ex)
    End Try
%>
