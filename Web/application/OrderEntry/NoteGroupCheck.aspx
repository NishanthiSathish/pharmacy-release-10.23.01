<%@ Page Language="VB" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim NoteGroupSetDoc As New XmlDocument()
    Dim InvalidItems As New XmlDocument()
    Dim RequestReader As New System.IO.StreamReader(Page.Request.InputStream)
    Dim NoteGroupSetXML As String = RequestReader.ReadToEnd()

    RequestReader.Close()
    InvalidItems.AppendChild(InvalidItems.CreateElement("InvalidItems"))
    NoteGroupSetDoc.TryLoadXml(NoteGroupSetXML)
    Dim NoteGroup As String = NoteGroupSetDoc.DocumentElement.GetAttribute("notegroup").ToLower
    Dim NoteType As String = NoteGroupSetDoc.DocumentElement.GetAttribute("notetype").ToLower

    If NoteGroup = "administration" AndAlso (NoteType = "selfadmin" OrElse NoteType = "homeadmin") Then
        For Each SetItem As XmlElement In NoteGroupSetDoc.DocumentElement.ChildNodes()
            If SetItem.GetAttribute("AdministrationStatus") = "In Progress" And SetItem.GetAttribute("RequestType") = "Infusion Prescription" Then
                Dim RequestID As Integer = Integer.Parse(SetItem.GetAttribute("dbid"))
                Dim InfusionInProgress As Boolean = New OCSRTL10.PrescriptionRead().PrescriptionInfusionInProgress(SessionID, RequestID)
                If InfusionInProgress Then
                    Dim InvalidItem As XmlElement = InvalidItems.DocumentElement.AppendChild(InvalidItems.CreateElement("Item"))
                    Dim Message As String = Environment.NewLine & "The infusion """ & SetItem.GetAttribute("detail") & _
                                            """ is recorded as being ""In Progress"" and its status cannot be changed to Self Administration or Home Administration." & _
                                            Environment.NewLine & Environment.NewLine & _
                                            "If this is recorded in error, use the Drug Administration Module to record that the infusion has ended."
                    InvalidItem.SetAttribute("message", Message)
                End If
            End If
        Next
    End If

    
    'Ensure that Transcriptions are not changed from 'Home Administration'
    If NoteGroup = "administration" And NoteType <> "homeadmin" Then
        For Each setItem As XmlElement In NoteGroupSetDoc.DocumentElement.ChildNodes()
            If SetItem.GetAttribute("CreationType") = "Transcription" Then
                Dim InvalidItem As XmlElement = InvalidItems.DocumentElement.AppendChild(InvalidItems.CreateElement("Item"))
                Dim message As String = Environment.NewLine & "The transcription """ & SetItem.GetAttribute("detail") & _
                                        """ cannot be changed from Home Administration."


                InvalidItem.SetAttribute("message", Message)
            End If
        Next
    End If

    Response.Write(InvalidItems.OuterXml)
%>
