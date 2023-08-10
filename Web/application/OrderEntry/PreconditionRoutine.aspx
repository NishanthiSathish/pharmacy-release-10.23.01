<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<%
    '-----------------------------------------------------------------------------------------
    'PrescriptionLoader.aspx
    '
    '
    'Asyncronous loader page for the status button precondition routine.
    '
    '
    'Modification History:
    '06Mar07 ST  Written
    '
    '-----------------------------------------------------------------------------------------
    Dim SessionID As Integer = Generic.CIntX(Request.QueryString("SessionID"))
    Dim Routine As String = Request.QueryString("Routine")
    Dim StatusChange As String = Request.QueryString("StatusChange")
    Dim NoteGroupIDToDisable As String = Request.QueryString("NoteGroupIDToDisable")
    Dim RoutineRead As New ICWRTL10.RoutineRead()
    Dim ItemIDList As String = Request.QueryString("ItemIDList")
    
    If Not String.IsNullOrEmpty(NoteGroupIDToDisable) Then
        StatusChange = "Disable"
        Dim SelectedStatusNote = New OCSRTL10.NoteGroupRead().GetSelectedRequestTypeStatusNote(SessionID, NoteGroupIDToDisable, ItemIDList)
        If String.IsNullOrEmpty(SelectedStatusNote) Then
            Routine = String.Empty
        Else
            Dim StatusNoteXML As System.Xml.Linq.XElement = System.Xml.Linq.XElement.Parse(SelectedStatusNote)
            '12Apr2013  Rams    Prescondition routine can be null. Found this when fixing 61331.
            If Not StatusNoteXML.Attribute("PreconditionRoutine") Is Nothing Then
                Routine = StatusNoteXML.Attribute("PreconditionRoutine").Value
            End If
        End If
    End If
    
    'we now need to execute the routine and return the data
    'first check to make sure this routine exists
    Dim routineId As Integer = 0
    
    If Not String.IsNullOrEmpty(Routine) Then
        routineId = RoutineRead.DescriptionToID(SessionID, Routine)
    End If
	
    If routineId = 0 Then
        Response.Write(String.Empty)
    Else
        ' comma delimited list of request ids that may or *may not* be passed in here.
        Dim BaseType As String = Request.QueryString("BaseType")
        Dim Params_XML As String = RoutineRead.CreateParameter("ItemIDList", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 1024, ItemIDList) & _
                                   RoutineRead.CreateParameter("BaseType", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 15, BaseType) & _
                                   RoutineRead.CreateParameter("StatusChange", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 15, StatusChange)
        Dim Return_XML As String = RoutineRead.ExecuteByID(SessionID, routineId, Params_XML)

        ' If we got nothing back or just some closing xml <root> tags then we dont want to display these. 
        ' F0029110
        ' ST 14Jan09 Strip out any returned <root></root> tags so that they're not displayed in the messasge box
        Return_XML = Return_XML.Replace("<root>", "")
        Return_XML = Return_XML.Replace("</root>", "")
        Response.Write(Return_XML)
    End If
%>

