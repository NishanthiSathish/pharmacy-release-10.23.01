<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Dss" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<html>
<head>

<script language="vb" runat="server">

    Structure OrderItemData
        Private m_OCSType As String
        Private m_OCSTypeID As Integer
        Private m_OCSID As Integer
        Private m_DataClass As String
        Private m_AttachToType As String
        Private m_InProgress As Boolean
        Private m_RequestComplete As Boolean

        Public ReadOnly Property OCSType() As String
            Get
                Return m_OCSType
            End Get
        End Property

        Public ReadOnly Property OCSTypeID() As Integer
            Get
                Return m_OCSTypeID
            End Get
        End Property

        Public ReadOnly Property OCSID() As Integer
            Get
                Return m_OCSID
            End Get
        End Property

        Public ReadOnly Property DataClass() As String
            Get
                Return m_DataClass
            End Get
        End Property

        Public ReadOnly Property AttachToType() As String
            Get
                Return m_AttachToType
            End Get
        End Property

        Public ReadOnly Property InProgress() As Boolean
            Get
                Return m_InProgress
            End Get
        End Property

        Public ReadOnly Property RequestComplete() As Boolean
            Get
                Return m_RequestComplete
            End Get
        End Property

        Public Sub New(ByVal SessionID As Integer, ByVal OrderItemElement As XmlElement, ByVal PendingMode As Boolean)

            m_DataClass = OrderItemElement.GetAttribute("dataclass")    ' PR 05-05-09 - F0052946 - Shared Information page does not have ocstype element
            If OrderItemElement.HasAttribute("ocstype") Then
                m_OCSType = OrderItemElement.GetAttribute("ocstype")
                If m_OCSType = "ordersetinstance" Then
                    m_OCSType = "request"
                End If
            Else
                m_OCSType = String.Empty
            End If
            '10Mar05 AE  Include ordersets.  Fixes bug where pending ordersets could not be edited
            'I imagine that we'll modify this in future to deal with different types of ordersets; so here we'll probably be looking up the ordertemplate id.
            If m_DataClass = "pending" Then
                m_AttachToType = "pending"
            Else
                m_AttachToType = OCSType
            End If
            If Not Integer.TryParse(OrderItemElement.GetAttribute("ocstypeid"), m_OCSTypeID) Then
                m_OCSTypeID = 0
            End If
            If Not Integer.TryParse(OrderItemElement.GetAttribute("id"), m_OCSID) Then
                m_OCSID = 0
            End If
            If PendingMode Or Not (m_DataClass = "request") Then
                m_InProgress = False
                m_RequestComplete = False
            Else
                Dim RequestID As Integer = Integer.Parse(OrderItemElement.GetAttribute("id").ToString)
                m_InProgress = New OCSRTL10.PrescriptionRead().PrescriptionInfusionInProgress(SessionID, RequestID)
                m_RequestComplete = New OCSRTL10.OrderCommsItemRead().IsRequestComplete(SessionID, RequestID)
            End If
            
        End Sub
        
    End Structure

    Structure ToolBarData
        Public ToolBarHTML As String
        Public AttachedNotesXML As String
    End Structure

    '---------------------------------------------------------------------------------------------------------------------------------------------
    Function ScriptToolBar(ByVal SessionID As Integer, ByVal StatusNoteFilterXML As String, ByVal FormCount As Integer, ByVal OrderItems As XmlNodeList, ByVal PendingMode As Boolean, ByVal CurrentFormNo As Integer) As ToolBarData

        Dim ReturnData As New ToolBarData()

        Dim ToolBar As New XmlDocument()

        ReturnData.AttachedNotesXML = String.Empty
        'Read StatusNote filter list, to see what status buttons (if any) should be included or excluded
        Dim Table As XmlElement = ToolBar.AppendChild(ScriptTable(SessionID, ToolBar, PendingMode))
        Dim TableRow As XmlElement = Table.SelectSingleNode("tr")
        '22Feb05 PH Render NoteType toggle buttons. Script a set of notetype-note buttons for each form.
        Dim FilterType As String = "all"
        Dim FilterRoot As XmlElement = Nothing
        Try
            Dim FilterDoc As New XmlDocument()
            FilterDoc.TryLoadXml(StatusNoteFilterXML)
            FilterRoot = FilterDoc.SelectSingleNode("//StatusNoteFilter")
            If Not (FilterRoot Is Nothing) AndAlso FilterRoot.HasAttribute("action") Then
                FilterType = FilterRoot.GetAttribute("action")
            End If
        Catch ex As Exception
            'do nothing as FilterType already set to all
        End Try
        For FormID As Integer = 0 To FormCount - 1
            Dim OrderItemElement As XmlElement = OrderItems(FormID)
            Dim OrderItemData As New OrderItemData(SessionID, OrderItemElement, PendingMode)
            If (OrderItemData.OCSType = "request" Or OrderItemData.OCSType = "response") And OrderItemData.OCSTypeID > 0 Then
                Dim StatusNoteDoc As New XmlDocument()
                If OrderItemData.OCSType = "request" Then
                    StatusNoteDoc = RequestTypeStatusNoteListForRequestXML(SessionID, ReturnData, PendingMode, OrderItemData.OCSTypeID, OrderItemData.OCSID, FormID, OrderItemData.DataClass)
                Else
                    StatusNoteDoc = ResponseTypeStatusNoteListForResponseXML(SessionID, ReturnData, PendingMode, OrderItemData.OCSTypeID, OrderItemData.OCSID, FormID, OrderItemData.DataClass)
                End If
                Dim GroupsDoc As New XmlDocument
                GroupsDoc.TryLoadXml("<root>" & QueryValidation.LoadNoteGroups(StatusNoteDoc.OuterXml, SessionID) & "</root>")
                TableRow.AppendChild(ScriptStatusNoteToolBar(ToolBar, CurrentFormNo, PendingMode, StatusNoteDoc, GroupsDoc, OrderItemData, FilterType, FilterRoot, FormID))
            End If
        Next
        ReturnData.ToolBarHTML = ToolBar.OuterXml.Replace("_nbsp_", "&nbsp;") & Environment.NewLine
        ReturnData.ToolBarHTML &= "<!-- Invisible frame which holds the page which saves data -->" & Environment.NewLine
        ReturnData.ToolBarHTML &= "<iframe id=""fraSave"" application=""yes"" style=""display:none; height:500px; width:100%"" src=""OrderEntrySaver.aspx"" style=""display:none"" ></iframe>" & Environment.NewLine

        Return ReturnData

    End Function

    '----------------------------------------------------------------------------------------------------------------------------------------------
    Function RequestTypeStatusNoteListForRequestXML(ByVal SessionID As Integer, ByRef ReturnData As ToolBarData, ByVal PendingMode As Boolean, ByVal RequestTypeID As Integer, ByVal RequestID As Integer, ByVal FormID As Integer, ByVal DataClass As String) As XmlDocument

        Dim StatusNoteDoc As New XmlDocument()

        'Read request type status actions for this request type
        If PendingMode Then
            'PendingItem
            StatusNoteDoc.TryLoadXml(New OCSRTL10.RequestTypeRead().RequestTypeStatusNoteListXML(SessionID, RequestTypeID))
            If DataClass = "pending" Then
                Try
                    Dim PendingItemDoc As New XmlDocument()
                    PendingItemDoc.TryLoadXml(New OCSRTL10.PendingItemRead().GetItemByID(SessionID, RequestID))
                    If Not PendingItemDoc.FirstChild.Attributes.GetNamedItem("ItemXML") Is Nothing Then '// AI 22/11/2007 Code 148
                        PendingItemDoc.TryLoadXml(PendingItemDoc.FirstChild.Attributes.GetNamedItem("ItemXML").Value()) '// AI 22/11/2007 Code 148
                    End If
                    Dim AttachedNotes As XmlNode = PendingItemDoc.SelectSingleNode("//attachednotes")
                    If Not AttachedNotes Is Nothing Then
                        'SC-07-0615  Add existing attached note data to the xml data island - this is later merged when saving 
                        ReturnData.AttachedNotesXML &= "<item formidx='" & FormID.ToString() & "'>" & AttachedNotes.OuterXml & "</item>"

                        Dim RequestTypeStatusNotes As XmlNodeList = StatusNoteDoc.SelectNodes("//RequestTypeStatusNote")
                        For Each RequestTypeStatusNote As XmlElement In RequestTypeStatusNotes
                            If Not (AttachedNotes.SelectSingleNode("attachednote[@type=""" & RequestTypeStatusNote.GetAttribute("NoteType") & """]") Is Nothing) Then
                                RequestTypeStatusNote.SetAttribute("NoteID_Attached", RequestID)
                                'Set StatusSet here when NoteID is attached 24-Feb-09 Rams F0046339
                                RequestTypeStatusNote.SetAttribute("StatusSet", "1")
                            End If
                        Next
                    End If
                Catch ex As Exception
                    ' Unable to load Pending Item XML
                End Try
            Else
                Dim DefaultStatusNotes As XmlNodeList = StatusNoteDoc.SelectNodes("//RequestTypeStatusNote[@NoteGroupDefault=""1""]")
                Dim AttachedNotesXML As String = String.Empty
                For Each DefaultStatusNote As XmlElement In DefaultStatusNotes
                    DefaultStatusNote.SetAttribute("NoteID_Attached", "9999")
                    DefaultStatusNote.SetAttribute("StatusSet", "1")
                    AttachedNotesXML &= "<attachednote type=""" & DefaultStatusNote.GetAttribute("NoteType") & """><data /></attachednote>"
                Next
                If AttachedNotesXML.Length > 0 Then
                    ReturnData.AttachedNotesXML = "<item formidx='" & FormID.ToString() & "'><attachednotes>" & AttachedNotesXML & "</attachednotes></item>"
                End If
            End If
        Else
            'Request
            StatusNoteDoc.TryLoadXml(New OCSRTL10.RequestTypeRead().RequestTypeStatusNoteListForRequestXML(SessionID, RequestTypeID, RequestID))
        End If

        Return StatusNoteDoc

    End Function

    '----------------------------------------------------------------------------------------------------------------------------------------------
    Function ResponseTypeStatusNoteListForResponseXML(ByVal SessionID As Integer, ByRef ReturnData As ToolBarData, ByVal PendingMode As Boolean, ByVal ResponseTypeID As Integer, ByVal ResponseID As Integer, ByVal FormID As Integer, ByVal DataClass As String) As XmlDocument

        Dim StatusNoteDoc As New XmlDocument()

        'Read Response type status actions for this Response type
        If PendingMode Then
            'PendingItem
            StatusNoteDoc.TryLoadXml(New OCSRTL10.ResponseTypeRead().ResponseTypeStatusNoteListXML(SessionID, ResponseTypeID))
            If DataClass = "template" Then
            Else
                Try
                    Dim PendingItemDoc As New XmlDocument()
                    PendingItemDoc.TryLoadXml(New OCSRTL10.PendingItemRead().GetItemByID(SessionID, ResponseID))
                    If Not PendingItemDoc.FirstChild.Attributes.GetNamedItem("ItemXML") Is Nothing Then '// AI 22/11/2007 Code 148
                        PendingItemDoc.TryLoadXml(PendingItemDoc.FirstChild.Attributes.GetNamedItem("ItemXML").Value()) '// AI 22/11/2007 Code 148
                    End If
                    Dim AttachedNotes As XmlNode = PendingItemDoc.SelectSingleNode("//attachednotes")
                    If Not AttachedNotes Is Nothing Then
                        'SC-07-0615  Add existing attached note data to the xml data island - this is later merged when saving 
                        ReturnData.AttachedNotesXML &= "<item formidx='" & FormID.ToString() & "'>" & AttachedNotes.OuterXml & "</item>"

                        Dim ResponseTypeStatusNotes As XmlNodeList = StatusNoteDoc.SelectNodes("//ResponseTypeStatusNote")
                        For Each ResponseTypeStatusNote As XmlElement In ResponseTypeStatusNotes
                            If Not (AttachedNotes.SelectSingleNode("attachednote[@type=""" & ResponseTypeStatusNote.GetAttribute("NoteType") & """]") Is Nothing) Then
                                ResponseTypeStatusNote.SetAttribute("NoteID_Attached", ResponseID)
                                'Set StatusSet here when NoteID is attached  24-Feb-09 Rams F0046339
                                ResponseTypeStatusNote.SetAttribute("StatusSet", "1")
                            End If
                        Next
                    End If
                Catch ex As Exception
                    ' Unable to load Pending Item XML
                End Try
            End If
        Else
            'Response
            StatusNoteDoc.TryLoadXml(New OCSRTL10.ResponseTypeRead().ResponseTypeStatusNoteListForResponseXML(SessionID, ResponseTypeID, ResponseID))
        End If

        Return StatusNoteDoc

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptTable(ByVal SessionID As Integer, ByVal ToolBar As XmlDocument, ByVal PendingMode As Boolean) As XmlElement

        Dim Table As XmlElement = ToolBar.CreateElement("table")
        Dim TableRow As XmlElement = Table.AppendChild(ToolBar.CreateElement("tr"))

        Table.SetAttribute("style", "position:absolute;top:-1")
        Table.SetAttribute("border", "0")
        Table.SetAttribute("cellpadding", "0")
        Table.SetAttribute("cellspacing", "0")
        Table.SetAttribute("width", "100%")
        Table.SetAttribute("height", "100%")

        TableRow.SetAttribute("id", "trOCSToolbar")
        TableRow.SetAttribute("class", "Toolbar")
        TableRow.SetAttribute("sessionid", SessionID.ToString())
        TableRow.SetAttribute("pendingmode", PendingMode.ToString().ToLower())

        Return Table

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptStatusNoteToolBar(ByVal ToolBar As XmlDocument, ByVal CurrentFormNo As Integer, ByVal PendingMode As Boolean, ByVal StatusNoteDoc As XmlDocument, ByVal GroupsDoc As XmlDocument, ByVal OrderItemData As OrderItemData, ByVal FilterType As String, ByVal FilterRoot As XmlElement, ByVal FormID As Integer) As XmlElement
      
        Dim TableData As XmlElement = ToolBar.CreateElement("td")

        TableData.SetAttribute("id", "tdToolBar")
        TableData.SetAttribute("name", "tdToolBar")
        TableData.SetAttribute("formno", FormID.ToString)
        TableData.SetAttribute("inprogress", OrderItemData.InProgress.ToString.ToLower)
        TableData.SetAttribute("requestcomplete", OrderItemData.RequestComplete.ToString.ToLower)
        TableData.SetAttribute("attachtotype", OrderItemData.AttachToType.ToLower)
        TableData.SetAttribute("ocsid", OrderItemData.OCSID.ToString)
        If Not (CurrentFormNo = FormID) Then
            TableData.SetAttribute("style", "display:none")
        End If

        Dim ActiveNoteList As XmlNodeList = StatusNoteDoc.SelectNodes("root//*")
        For Each StatusNote As XmlElement In ActiveNoteList
            Dim ShowNoteType As Boolean
            If PendingMode Then
                If StatusNote.HasAttribute("NoteGroupID") Then
                    Dim NoteTypeID As String = StatusNote.GetAttribute("NoteTypeID")
                    Dim NoteGroupID As String = StatusNote.GetAttribute("NoteGroupID")
                    Dim IsDefault As Boolean = (StatusNote.HasAttribute("NoteGroupDefault") AndAlso StatusNote.GetAttribute("NoteGroupDefault") = "1")
                    If IsDefault Then
                        Dim NoteGroupNotelist As XmlNodeList = StatusNoteDoc.SelectNodes("root//*[@NoteTypeID!=""" & NoteTypeID & """ and @NoteGroupID=""" & NoteGroupID & """ and @UseInPendingTray=""1""]")
                        ShowNoteType = NoteGroupNotelist.Count > 0
                    Else
                        ShowNoteType = StatusNote.HasAttribute("UseInPendingTray") AndAlso StatusNote.GetAttribute("UseInPendingTray") = "1"
                    End If
                Else
                    ShowNoteType = StatusNote.HasAttribute("UseInPendingTray") AndAlso StatusNote.GetAttribute("UseInPendingTray") = "1"
                End If
            Else
                Dim IsDefault As Boolean = (StatusNote.HasAttribute("NoteGroupDefault") AndAlso StatusNote.GetAttribute("NoteGroupDefault") = "1")
                If IsDefault Then
                    Dim NoteTypeID As String = StatusNote.GetAttribute("NoteTypeID")
                    Dim NoteGroupID As String = StatusNote.GetAttribute("NoteGroupID")
                    Dim NoteGroupStatusNoteList As XmlNodeList = StatusNoteDoc.SelectNodes("//*[@NoteTypeID!=""" & NoteTypeID & """ and @NoteGroupID=""" & NoteGroupID & """]")
                    Dim NoteGroupShowCount As Integer = 0
                    For Each NoteGroupStatusNote As XmlElement In NoteGroupStatusNoteList
                        Dim NoteGroupNoteType As String = NoteGroupStatusNote.GetAttribute("NoteType").ToLower()
                        Dim NoteGroupNoteTypeInFilter As Boolean = Not (FilterRoot.SelectSingleNode("//notetype[@description=""" & NoteGroupNoteType & """]") Is Nothing)
                        If (FilterType = "all" OrElse (FilterType = "include" And NoteGroupNoteTypeInFilter) OrElse (FilterType = "exclude" And Not NoteGroupNoteTypeInFilter)) Then
                            NoteGroupShowCount += 1
                        End If
                    Next
                    ShowNoteType = NoteGroupShowCount > 0
                Else
                    Dim NoteType As String = StatusNote.GetAttribute("NoteType").ToLower()
                    Dim ItemInFilter As Boolean = Not (FilterRoot.SelectSingleNode("//notetype[@description=""" & NoteType & """]") Is Nothing)
                    ShowNoteType = FilterType = "all" OrElse (ItemInFilter AndAlso FilterType = "include") OrElse (Not ItemInFilter AndAlso FilterType = "exclude")
                End If
            End If
            If ShowNoteType Then
                If StatusNote.HasAttribute("NoteGroupID") Then
                    Dim NoteTypeID As String = StatusNote.GetAttribute("NoteTypeID")
                    Dim NoteGroupID As String = StatusNote.GetAttribute("NoteGroupID")
                    Dim SelectGroup As XmlElement = TableData.SelectSingleNode("//select[@notegroupid=""" & NoteGroupID & """]")
                    If SelectGroup Is Nothing Then
                        TableData.AppendChild(ScriptSelect(ToolBar, StatusNoteDoc, GroupsDoc, NoteGroupID))
                        SelectGroup = TableData.SelectSingleNode("//select[@notegroupid=""" & NoteGroupID & """]")
                    End If
                    Dim IsDefault As Boolean = (SelectGroup.GetAttribute("defaultnotetype") = NoteTypeID)
                    Dim OptionSelect As XmlElement = ScriptOption(ToolBar, StatusNote, IsDefault)
                    If IsDefault AndAlso SelectGroup.HasChildNodes Then
                        SelectGroup.InsertBefore(OptionSelect, SelectGroup.FirstChild())
                    Else
                        SelectGroup.AppendChild(OptionSelect)
                    End If
                Else
                    TableData.InsertBefore(ScriptNoteButton(ToolBar, PendingMode, StatusNote, OrderItemData, FormID), TableData.SelectSingleNode("//span"))
                End If
            End If
        Next

        Return TableData

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptNoteButton(ByVal ToolBar As XmlDocument, ByVal PendingMode As Boolean, ByRef StatusNote As XmlElement, ByVal OrderItemData As OrderItemData, ByVal FormID As Integer) As XmlElement

        Dim Button As XmlElement = ToolBar.CreateElement("button")
        Dim Table As XmlElement = Button.AppendChild(ToolBar.CreateElement("table"))
        Dim Row As XmlElement = Table.AppendChild(ToolBar.CreateElement("tr"))
        Dim DataImg As XmlElement = Row.AppendChild(ToolBar.CreateElement("td"))
        Dim DataText As XmlElement = Row.AppendChild(ToolBar.CreateElement("td"))
        Dim Image As XmlElement = DataImg.AppendChild(ToolBar.CreateElement("img"))

        Button.SetAttribute("id", "cmdNoteTypeToggle")
        If OrderItemData.DataClass = "template" And Not PendingMode Then
            Button.SetAttribute("disabled", "true")
        End If
        Button.SetAttribute("class", "ToolButton")
        Button.SetAttribute("onclick", "NoteTypeToggle(this);")
        Button.SetAttribute("style", "border:none;width:0px;")
        Button.SetAttribute("applyverb", Generic.SpaceToNBSP(StatusNote.GetAttribute("ApplyVerb")).Replace("&nbsp;", "_nbsp_"))
        Button.SetAttribute("deactivateverb", Generic.SpaceToNBSP(StatusNote.GetAttribute("DeactivateVerb")).Replace("&nbsp;", "_nbsp_"))
        Button.SetAttribute("authenticate", StatusNote.GetAttribute("UserAuthentication"))
        Button.SetAttribute("precondition", StatusNote.GetAttribute("PreconditionRoutine"))
        Button.SetAttribute("allowDuplicates", StatusNote.GetAttribute("AllowDuplicates"))
        Button.SetAttribute("notetypeid", StatusNote.GetAttribute("NoteTypeID"))
        Button.SetAttribute("isapplied", StatusNote.GetAttribute("IsApplied"))
        Button.SetAttribute("tableid", StatusNote.GetAttribute("TableID"))
        Button.SetAttribute("tablename", StatusNote.GetAttribute("TableName"))
        Button.SetAttribute("hasform", (StatusNote.GetAttribute("TableName") <> "AttachedNote").ToString().ToLower())
        Button.SetAttribute("notetype", StatusNote.GetAttribute("NoteType"))
        Button.SetAttribute("noteid_attached", StatusNote.GetAttribute("NoteID_Attached"))
        Button.SetAttribute("statusset", StatusNote.GetAttribute("StatusSet"))
        ' 20Nov08 PH Disable status note buttons that have printout, because printing doesn't work from order entry
        If (Not StatusNote.GetAttribute("HasReport") Is System.DBNull.Value) AndAlso StatusNote.GetAttribute("HasReport") = "1" Then
            Button.SetAttribute("disabled", "true")
        End If
        Table.SetAttribute("cellpadding", "2")
        Table.SetAttribute("cellspacing", "1")
        Table.SetAttribute("class", "ToolButton")
        Table.SetAttribute("style", "width:100%")
        Image.SetAttribute("id", "imgNoteTypeToggle")
        Image.SetAttribute("src", "../../images/ocs/stamp.gif")
        Image.SetAttribute("style", "width:16px;height:16px")
        Image.SetAttribute("width", "16")
        Image.SetAttribute("height", "16")
        DataText.SetAttribute("id", "txtStatusNote")
        DataText.SetAttribute("style", "white-space:nowrap;")
        If StatusNote.HasAttribute("StatusSet") AndAlso StatusNote.GetAttribute("StatusSet") = 1 Then
            DataText.InnerText = ICW.ToolbarButtonText(StatusNote.GetAttribute("DeactivateVerb"), "").Replace("&nbsp;", "_nbsp_")
        Else
            DataText.InnerText = ICW.ToolbarButtonText(StatusNote.GetAttribute("ApplyVerb"), "").Replace("&nbsp;", "_nbsp_")
        End If

        Return Button

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptSelect(ByVal ToolBar As XmlDocument, ByVal StatusNoteDoc As XmlDocument, ByVal GroupsDoc As XmlDocument, ByVal NoteGroupID As String) As XmlElement

        Dim Span As XmlElement = ToolBar.CreateElement("span")
        Dim SpaceSpan As XmlElement = Span.AppendChild(ToolBar.CreateElement("span"))
        Dim SelectGroup As XmlElement = Span.AppendChild(ToolBar.CreateElement("select"))

        Dim NoteGroup As XmlElement = GroupsDoc.SelectSingleNode("//NoteGroup[@NoteGroupID=""" & NoteGroupID & """]")

        Span.SetAttribute("id", "spnNoteGroup")
        Span.SetAttribute("style", "border:1px solid white;height:30px")
        SpaceSpan.InnerText = "_nbsp_"
        SelectGroup.SetAttribute("id", "slcNoteGroup")
        SelectGroup.SetAttribute("notegroupid", NoteGroupID)
        SelectGroup.SetAttribute("notegroupname", NoteGroup.GetAttribute("GroupName"))
        SelectGroup.SetAttribute("defaultnotetype", NoteGroup.GetAttribute("NoteTypeID_Default"))
        SelectGroup.SetAttribute("onpropertychange", "if(window.event.propertyName == 'selectedIndex') slcNoteGroup_onpropertychange(this);")
        SpaceSpan = Span.AppendChild(ToolBar.CreateElement("span"))
        SpaceSpan.InnerText = "_nbsp__nbsp_"
        Span.AppendChild(ScriptGroupButton(ToolBar, NoteGroupID))
        SpaceSpan = Span.AppendChild(ToolBar.CreateElement("span"))
        SpaceSpan.InnerText = "_nbsp_"

        Return Span

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptGroupButton(ByVal ToolBar As XmlDocument, ByVal NoteGroupID As String) As XmlElement

        Dim Button As XmlElement = ToolBar.CreateElement("button")

        Button.SetAttribute("id", "cmdNoteGroup")
        Button.SetAttribute("onclick", "NoteGroupToggle(this);")
        Button.SetAttribute("notegroupid", NoteGroupID)
        Button.InnerText = "Set"

        Return Button

    End Function

    '---------------------------------------------------------------------------------------------------------
    Function ScriptOption(ByVal ToolBar As XmlDocument, ByVal StatusNote As XmlElement, ByVal IsDefault As Boolean) As XmlElement

        Dim OptionSelect As XmlElement = ToolBar.CreateElement("option")
        
        If IsDefault Then
            OptionSelect.SetAttribute("id", "optDefaultNote")
        Else
            OptionSelect.SetAttribute("id", "optStatusNote")
        End If
        OptionSelect.SetAttribute("authenticate", StatusNote.GetAttribute("UserAuthentication"))
        OptionSelect.SetAttribute("precondition", StatusNote.GetAttribute("PreconditionRoutine"))
        OptionSelect.SetAttribute("notetypeid", StatusNote.GetAttribute("NoteTypeID"))
        OptionSelect.SetAttribute("isapplied", StatusNote.GetAttribute("IsApplied"))
        OptionSelect.SetAttribute("tableid", StatusNote.GetAttribute("TableID"))
        OptionSelect.SetAttribute("tablename", StatusNote.GetAttribute("TableName"))
        OptionSelect.SetAttribute("hasform", (StatusNote.GetAttribute("TableName") <> "AttachedNote").ToString().ToLower())
        OptionSelect.SetAttribute("notetype", StatusNote.GetAttribute("NoteType"))
        OptionSelect.SetAttribute("noteid_attached", StatusNote.GetAttribute("NoteID_Attached"))
        OptionSelect.SetAttribute("statusset", StatusNote.GetAttribute("StatusSet"))
        OptionSelect.InnerText = Generic.SpaceToNBSP(StatusNote.GetAttribute("ApplyVerb")).Replace("&nbsp;", "_nbsp_")

        Return OptionSelect

    End Function

</script>

<script language="javascript" type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
<script language="javascript" src="../sharedscripts/ICWFunctions.js"></script>
<script language="javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" src="CustomControls/CustomControlShared.js"></script>
<script language="javascript" src="Scripts/OrderFormStatusToolbar.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ocs/SaveResults.js"></script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
</head>
<body scroll="no" onload="window_onload()" >
<%  
    Dim SessionID As Integer = CInt(Request.QueryString("SessionID"))
    Dim StatusNoteFilterXML As String = Request.Form("txtStatusFilterXML")
    Dim OrdersXML As String = Request.Form("txtOrdersXML")
    Dim PendingMode As Boolean = CBool(Request.QueryString("PendingMode"))
    Dim CurrentFormNo As Integer
    If Not Integer.TryParse(Request.Form("txtCurrentFormNo"), CurrentFormNo) Then
        CurrentFormNo = 0
    End If
    
    Dim AttachedNotesXML As String = "<attachednotes>"
    Dim FormCount As Integer = 0
    If Not String.IsNullOrEmpty(OrdersXML) Then
        Dim OrderDoc As New XmlDocument()
        Dim OrderItems As XmlNodeList
        OrderDoc.TryLoadXml(OrdersXML)
        OrderItems = OrderDoc.SelectNodes("root//item")
        FormCount = OrderItems.Count
        Dim ToolBarData As ToolBarData = ScriptToolBar(SessionID, StatusNoteFilterXML, FormCount, OrderItems, PendingMode, CurrentFormNo)
        AttachedNotesXML &= ToolBarData.AttachedNotesXML
        Response.Write(ToolBarData.ToolBarHTML)
    End If
    AttachedNotesXML &= "</attachednotes>"
%>
<form action="" method="post" id="frmXML" name="frmXML" style="display:none" formcount="<%= FormCount %>" >
	<input id="txtOrdersXML" name="txtOrdersXML" type="text" value="<%= OrdersXML %>" />
	<input id="txtStatusFilterXML" name="txtStatusFilterXML" type="text" value="<%= StatusNoteFilterXML %>" />
	<input id="txtCurrentFormNo" name="txtCurrentFormNo" type="text" value="<%= CurrentFormNo %>" />
</form>

<xml id="AttachedNotesXML"><%=AttachedNotesXML%></xml>

</body>
</html>
