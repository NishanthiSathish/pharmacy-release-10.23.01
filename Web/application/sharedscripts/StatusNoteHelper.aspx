<%@ Page language="vb" %>

<%
    Dim Mode As String = String.Empty
    Dim returnXML As String = String.Empty
    Dim SessionID As Integer
    Dim NoteTypeID As Integer
    Dim RequestTypeID As Integer
    Dim ResponseTypeID As Integer

    Dim RequestTypeRead As OCSRTL10.RequestTypeRead
    Dim ResponseTypeRead As OCSRTL10.ResponseTypeRead
    Dim objUnitsRead As DSSRTL20.UnitsRead = New DSSRTL20.UnitsRead()

    Mode = Request.QueryString("Mode")
    SessionID = CInt(Request.QueryString("SessionID"))
    RequestTypeID = Request.QueryString("RequestTypeID")
    ResponseTypeID = Request.QueryString("ResponseTypeID")
    NoteTypeID = Request.QueryString("NoteTypeID")
    

    Select Case (Mode)
        Case "RequestType"
            RequestTypeRead = New OCSRTL10.RequestTypeRead()
            returnXML = RequestTypeRead.RequestTypeStatusNoteByRequestTypeAndNoteTypeXML(SessionID, RequestTypeID, NoteTypeID)
            
        Case "ResponseType"
            ResponseTypeRead = New OCSRTL10.ResponseTypeRead()
            returnXML = ResponseTypeRead.ResponseTypeStatusNoteByResponseTypeAndNoteTypeXML(SessionID, ResponseTypeID, NoteTypeID)
            
    End Select
	
    Response.Write(returnXML)
	
%>


