<%@ Page language="vb" %>

<%@ Import Namespace="System.Web.Script.Serialization" %>

<%@ Import Namespace="System.Net" %>

<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ OutputCache Location="None" VaryByParam="None" %>
<%@ Import Namespace="Ascribe.Xml" %>


<html>

<head>
<script language="javascript" type="text/javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/json2.js"></script>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/dss.css" />
</head>


<body onunload="Local_CloseReferenceWindow()" onload="PopUpDSSWarning();if (document.all['cmdNo'] != undefined)document.all['cmdNo'].focus();" onkeydown="return body_onKeydown();">

<script language="javascript" type="text/javascript">

    function PublishToBus(overlordUrl) {
        if (window.parent.PublishToBus) {
            window.parent.PublishToBus(overlordUrl);
        }
    }

</script>

<%
    '-------------------------------------------------------------------------------------------------------
    'Saving Routines
    '-------------------------------------------------------------------------------------------------------
    'Save an Order Batch
    '
    '<save>
    '<item template="true|false" id="xxx" tableid="xxx" requesttypeid="123">
    '<data>
    '<attribute name="xxx" value="vValue" />
    ''
    '</data>
    '</item>
    '<item ......
    '</item>
    '</save>
    '
    Dim SessionID As Integer
    Dim episodeId As Integer
    Dim DrugAdministration As Boolean = True
    Dim DataXML As String = Request.Form("dataXML")
    Dim RaiseChange As Boolean = False
    Dim Saved As Boolean = False
    Dim WarnUser As Boolean = False
    Dim Mode As String = Request.QueryString("Mode")
    Dim Result_XML As String = String.Empty
    Dim IdleMode As Boolean = False
    Dim stateRead As New GENRTL10.StateRead()

    episodeId = 0
 
    If String.IsNullOrEmpty(Request.QueryString("SessionID")) Then
        IdleMode = True
    Else
        SessionID = Integer.Parse(Request.QueryString("SessionID"))
        episodeId = stateRead.GetKey(SessionID, "Episode")
    End If
 
    If Not IdleMode Then
        If String.IsNullOrEmpty(Mode) Then
            Mode = String.Empty
        End If
        Mode = Mode.ToLower()
        Select Case Mode
            Case "save"
                Saved = True
            Case "attach", "attachednotedisable", "attachednotedisablemultiple", "updategroupnote", "attachpost"
                RaiseChange = True
            Case "respond", "cancel", "createobservationnote", "xmlput", "xmlput_testrig", "dsscheckonreconcile", "dssoverrideonreconcile"
                ' do nothing here just need to catch the else below
            Case Else
                IdleMode = True
        End Select
    End If
    
    If Not IdleMode Then
        Dim OpenedScriptElement As Boolean = False
        Dim Counter As Integer = 0
        Dim Retry As Boolean = True
        Dim MaxRetry As Integer
        If Not Integer.TryParse(New GENRTL10.SettingRead().GetValue(SessionID, "Security", "Settings", "DeadlockRetry", "3"), MaxRetry) Then
            MaxRetry = 3
        End If
        If MaxRetry < 0 Then
            MaxRetry = 0
        End If
        While Retry
            Try
                'If Mode = "cancel" Then
                '    Result_XML = "Deadlock Occurred: The current transaction could not be completed due to a deadlock issue, please wait a short time and try again." & _
                '                   Environment.NewLine() & "If this problem continues to occur then please report it to your system administrator."
                'Else
                Result_XML = Save(SessionID, Mode, DataXML)
                'End If
                Retry = False
            Catch sqlex As Data.SqlClient.SqlException
                If sqlex.Message.ToLower.Contains("deadlock victim") Then
                    Counter += 1
                    If Counter > MaxRetry Then
                        Result_XML = "Deadlock Occurred: The current transaction could not be completed due to a deadlock issue, please wait a short time and try again." & _
                                        Environment.NewLine() & "If this problem continues to occur then please report it to your system administrator."
                        Retry = False
                    Else
                        Threading.Thread.Sleep(100)
                    End If
                Else
                    Result_XML = "Error Occurred:" & Environment.NewLine & sqlex.Message & Environment.NewLine & Environment.NewLine & sqlex.Source
                    Retry = False
                End If
            Catch ex As Exception
                Result_XML = "Error Occurred:" & Environment.NewLine & ex.Message & Environment.NewLine & Environment.NewLine & ex.Source
                Retry = False
            End Try
        End While
    
        'Check if anything failed
        'Sort out the returned XML if required.
        '<saveresults>
        '<item template="true|false" id="xxx" tableid="xxx">
        '<saveok />															'Each node will either have a saveok node
        '<BrokenRules ...>													'or a BrokenRules node
        '</BrokenRules>
        '<ascribe_dss_results>											'...or some checking results
        '</ascribe_dss_results>
        '</item>
        ''
        '</saveresults>
        '22Jul05 AE  Changed to use the standard ScriptSaveResults method for reporting
        '29Apr10    Rams    F0084522 - DSS Interaction warning appear in an embedded pane on the Clinical Screening -> Current PMR desktop, it is cluttered and does not look right (Added Additional Parameters)
        '19May10    Rams    Avoid calling ScriptSaveResults when the input is empty.
        If Not Result_XML.Trim() = "" Then
            WarnUser = SaveResults.ScriptSaveResults(SessionID, Result_XML, logViewerMode:=False, touchScreenMode:=False, scriptForm:=False, episodeId:=episodeId)
            'Store the DSSInputxml on to session Attribute , for processing from Modla Form
            If WarnUser Then Generic.SessionAttributeSet(SessionID, "DssInputXML", Result_XML)
        End If
        '
        Response.Write("<xml id='saveData'>" & Result_XML & "</xml>" & vbCr)
        

        
        ' Raise workflow event for attached note (or removal of)
        If Not WarnUser And (Mode = "attach" Or Mode = "attachednotedisable" Or Mode = "attachednotedisablemultiple" Or Mode = "attachpost") Then
            ' Set workflow event type
            Dim workflowEventType As String
            If Mode = "attach" Or Mode = "attachpost" Then
                workflowEventType = "AttachNote"
            Else
                workflowEventType = "RemoveNote"
            End If
            
            ' Get items from xml
            Dim resultXmlDoc As New XmlDocument()
            resultXmlDoc.TryLoadXml(Result_XML)
            Dim itemNodes As XmlNodeList = resultXmlDoc.DocumentElement.SelectNodes("//item")
            
            ' Build Json Dictionary
            Dim dictRoot As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
            dictRoot.Add("SessionId", SessionID.ToString())
            
            ' Build Entities for Json Dict to match class ApiPostWorkflowEventParams in ICW
            Dim listEntities As List(Of Dictionary(Of String, Object)) = New List(Of Dictionary(Of String, Object))
            Dim dictEntity As Dictionary(Of String, Object)
            Dim entityId As String
            For Each itemNode As XmlElement In itemNodes
                ' Get entity id
                entityId = itemNode.GetAttribute("id")
                If (Mode = "attach" Or Mode = "attachpost") And Not itemNode.FirstChild Is Nothing And itemNode.FirstChild.Name = "saveok" Then
                    entityId = itemNode.FirstChild.GetAttribute("id")
                End If
                
                ' Build Entity
                dictEntity = New Dictionary(Of String, Object)()
                dictEntity.Add("WorkflowEventType", workflowEventType)
                'dictEntity.Add("TableIdForEntityType", itemNode.GetAttribute("tableid"))
                dictEntity.Add("SubjectType", "AttachedNote") ' This is set in case tableid is zero (for instance when disabling attached note)
                dictEntity.Add("SubjectId", entityId)
                listEntities.Add(dictEntity)
            Next
            
            dictRoot.Add("Entities", listEntities.ToArray())
            
            ' Serialize to json
            Dim serializer As Script.Serialization.JavaScriptSerializer = New Script.Serialization.JavaScriptSerializer
            Dim json As String = serializer.Serialize(dictRoot)
            
            ' Call web api to create event
            Dim apiUrl As String = ConfigurationManager.AppSettings("ICW_V11Location") & "/webapi/WorkflowEvents/PostWorkflowEvent"
            Dim webRequest As Net.HttpWebRequest
            webRequest = Net.WebRequest.Create(apiUrl)
            webRequest.Method = "POST"
            webRequest.ContentType = "application/json"
            
            Try
                Dim streamOut As IO.StreamWriter = New IO.StreamWriter(webRequest.GetRequestStream(), System.Text.Encoding.ASCII)
                streamOut.Write(json)
                streamOut.Close()
                Dim streamIn As IO.StreamReader = New IO.StreamReader(webRequest.GetResponse().GetResponseStream())
                Dim strResponse As String = streamIn.ReadToEnd()
                streamIn.Close()
            Catch ex As Exception
                ' Swallow any potential error for now to minimize the effect on the upcoming release (10.11)
                ' Should add proper error handling following the release
            End Try
            
        End If
        
        ' Try publish to service bus via v11
        Dim strPublishToBus As String = Request.QueryString("PublishToBus")
        Dim strPublishToBusUrl As String = String.Empty
        If Not WarnUser And (Mode = "attach" Or Mode = "attachednotedisable" Or Mode = "attachednotedisablemultiple" Or Mode = "attachpost") And strPublishToBus = "true" Then
            'Get ids of new attachednotes
            Dim resultXmlDoc As New XmlDocument()
            resultXmlDoc.TryLoadXml(Result_XML)
            Dim saveOkNodes As XmlNodeList = resultXmlDoc.DocumentElement.SelectNodes("//saveok")
            Dim pipeSeparatedIds As String = String.Empty
            
            ' Add ids to pipe separated list, ready for adding to url
            For Each saveOkNode As XmlElement In saveOkNodes
                If String.IsNullOrEmpty(pipeSeparatedIds) Then
                    pipeSeparatedIds = saveOkNode.GetAttribute("id")
                Else
                    pipeSeparatedIds = pipeSeparatedIds & "|" & saveOkNode.GetAttribute("id")
                End If
            Next
            
            'Build overlord url
            strPublishToBusUrl = ConfigurationManager.AppSettings("ICW_V11Location") & "/ServiceBusPublisher/ServiceBusPublisher.aspx?sessionId=" & SessionID.ToString() & "&mode=AttachedNotes&ids=" & pipeSeparatedIds
            
            'Call overlord url
            'Dim webRequest As System.Net.WebRequest = System.Net.WebRequest.Create(strUrl)
            'webRequest.GetResponse.GetResponseStream()
            
        End If
        
        If DrugAdministration And Not WarnUser And Saved Then
            '02Feb07 CD Added immediate stat admin
            Dim XML_ImmediateAutocommitSTATItems As New XmlDocument()
            XML_ImmediateAutocommitSTATItems.TryLoadXml("<items></items>")
            Dim ScriptImmediateAdmin As Boolean
            'no warnings so is there any immediate stat doses requiring administration, match items on the id attribute
            Dim DataDoc As New XmlDocument()
            'order comms items
            Dim ResultDoc As New XmlDocument()
            'results of the commit
            DataDoc.TryLoadXml(DataXML)
            'load the order comms items
            ResultDoc.TryLoadXml(Result_XML)
            'load the result of commit
            Dim Items As XmlNodeList = DataDoc.DocumentElement.SelectNodes("//item[@autocommit='1' and data[attribute[@name='STAT_Immediate' and @value='1']]]")
            'select only the autocommit STAT_Immediate items
            For Each Item As XmlElement In Items
                ScriptImmediateAdmin = True
                Dim ItemID As String = Item.GetAttribute("id")
                'get the item id
                Dim XMLSaveItemResult As XmlElement = ResultDoc.SelectSingleNode("/saveresults/item[@id='" & ItemID & "']/saveok")
                'match order comms selected items to the results xml items to get the requestid
                Dim ItemPrescriptionID As String = XMLSaveItemResult.GetAttribute("id")
                'get the resquest id
                Dim NewItemNode As XmlElement = XML_ImmediateAutocommitSTATItems.CreateElement("item")
                Dim NewItemAttribute As XmlAttribute = XML_ImmediateAutocommitSTATItems.CreateAttribute("PrescriptionID")
                NewItemAttribute.Value = ItemPrescriptionID
                NewItemNode.Attributes.SetNamedItem(NewItemAttribute)
                XML_ImmediateAutocommitSTATItems.DocumentElement.AppendChild(NewItemNode)
            Next
            'are there are some items to immediately administer
            If ScriptImmediateAdmin Then
                Generic.SessionAttributeSet(SessionID, CStr(IA_ITEMS), XML_ImmediateAutocommitSTATItems.OuterXml)
                'can pick this up in DrugAdministration
                Response.Write("<xml id='immitemData'>" & XML_ImmediateAutocommitSTATItems.OuterXml & "</xml>" & vbCr)
                'write the items xml
                Response.Write("<script language=javascript>" & vbCr & "if(window.parent.document.body.getAttribute(""dispensarymode"") == ""false"")" & vbCr & "window.parent.CheckImmediateAdministrationOfSTAT();" & vbCr)
                OpenedScriptElement = True
            End If

            Dim OnCommitMessages As XmlNodeList = ResultDoc.SelectNodes("//saveresults/RoutineCommitMessages/Message")
            If Not OnCommitMessages Is Nothing Then
                If Not OpenedScriptElement Then
                    Response.Write("<script language=""javascript"">" & vbCr)
                    OpenedScriptElement = True
                End If
                For Each Message As XmlElement In OnCommitMessages
                    Response.Write("alert('" & Message.GetAttribute("Text") & "');" & vbCr)
                Next
            End If
        End If

        Dim injectedScript As String = String.Empty
        
        If Not OpenedScriptElement Then
            Response.Write("<script id=""injectedScript"" language=""javascript"">" & vbCr)
        End If
        'Response.Write("alert('Executing injected code...');")
        If Not String.IsNullOrEmpty(strPublishToBusUrl) Then
            Response.Write("void PublishToBus('" & strPublishToBusUrl & "');" & vbCr)
        End If
        If RaiseChange Then
            Response.Write("void window.parent.SaveComplete(" & LCase(CStr(Not WarnUser)) & ", null, null, true);" & vbCr)
        ElseIf LCase(Request.QueryString("NavigateAway")) = "true" Then
            'since we have two versions of savecomplete ( in this case the second para is used ) - call from icw_orderentry
            Response.Write("void window.parent.SaveComplete(" & LCase(CStr(Not WarnUser)) & ", true, null, false);" & vbCr)
        Else
            Response.Write("void window.parent.SaveComplete(" & LCase(CStr(Not WarnUser)) & ", null, null, false);" & vbCr)
        End If
        Response.Write("</script>" & vbCr)
        
    End If
%>


<form id="frmSave" method="post">
	<input type="hidden" id="dataXML" name="dataXML" />
	<input type="hidden" id="PostconditionRoutinesXML" name="PostconditionRoutinesXML" />
	<input type="hidden" id="DiscontinuationReasonid" name ="DiscontinuationReasonid" />
	<input type="hidden" id="DiscontinuationReasonComment" name ="DiscontinuationReasonComment" />
</form>

<script language="javascript" type="text/javascript">
//================================================================================
//29Apr10    Rams    F0084522 - DSS Interaction warning appear in an embedded pane on the Clinical Screening -> Current PMR desktop, it is cluttered and does not look right
var mPopUp_DSSWarn = "<%= WarnUser.ToString().ToLower()%>";

function PopUpDSSWarning()
{
    if (mPopUp_DSSWarn == 'true')
    {
        mPopUp_DSSWarn = 'false';
	    //
	    //Moved saving of data to Session Attribute to the server call itself, instead of passing data to client and then back to server through Ajax
	    //var dialogwidth = screen.width * 0.75;
        //var dialogHeight = screen.height * 0.60;
        //F0097245 ST 27Sep10 Updated dimensions of popup dialog to take 95% of the screen size when displayed.
        var dialogwidth = screen.width - (screen.width / 100 * 5);     //* 0.75;
        var dialogHeight = screen.height - (screen.height / 100 * 5);   //* 0.60;

	    //24Sep2009 JMei F0040487 Passing the caller self to modal dialog so that modal dialog can access its opener
	    var objArgs = new Object();
	    objArgs.opener = self;
        if (window.dialogArguments == undefined)
        {
		    objArgs.icwwindow = window.parent.ICWWindow();
        }
        else
        {
    	    objArgs.icwwindow = window.dialogArguments.icwwindow;
        }
	    var strURL = '../DSSWarningsLogViewer/dssmodalupdateLog.aspx?SessionID=<%=SessionID%>&Mode=View';
	    var strFeatures = 'dialogWidth:'+ dialogwidth +'px;dialogHeight:' + dialogHeight + 'px;resizable:yes;scroll:yes';
        var oReturnValue = window.showModalDialog(strURL, objArgs, strFeatures)
        if (oReturnValue == 'logoutFromActivityTimeout') {
            oReturnValue = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }
        if (oReturnValue) {
            if (oReturnValue == true) {
                if (window.parent.DssResultsButtonHandler != null) {
                    window.parent.DssResultsButtonHandler(true);
                }
            }
            else {
                if (oReturnValue == false) {
                    if (window.parent.DssResultsButtonHandler != null) {
                        window.parent.DssResultsButtonHandler(false);
                    }
                }
                else {
                    //if user pressed the closes the window, without selecting out the given option  then make the user to select the appropriate decision.
                    mPopUp_DSSWarn = 'true';
                    PopUpDSSWarning();
                }
            }
        }
    }
}

function SaveBatch(SessionID, strBatch_XML)
{
//Save the given data to the server.

	document.all['dataXML'].value = strBatch_XML;
	var strURL = 'OrderEntrySaver.aspx' 
				  + '?Mode=Save'
				  + '&SessionID=' + SessionID;
				  
	frmSave.action = strURL;
	void frmSave.submit();
}

function SaveAndNavigateAway(SessionID, strBatch_XML) {
    //Save the given data to the server.

    document.all['dataXML'].value = strBatch_XML;
    var strURL = 'OrderEntrySaver.aspx'
				  + '?Mode=Save&NavigateAway=true'
				  + '&SessionID=' + SessionID;

    frmSave.action = strURL;
    void frmSave.submit();
}

//================================================================================

function SaveCancellation(SessionID, strCancellation_XML)
{
	document.all['dataXML'].value = strCancellation_XML;
	var strURL = 'OrderEntrySaver.aspx'
				  + '?Mode=Cancel'
				  + '&SessionID=' + SessionID;
	frmSave.action = strURL;
	void frmSave.submit();
}

//================================================================================

function SaveResponse(SessionID, strResponse_XML)
{
	//Save the given data to the server.

	document.all['dataXML'].value = strResponse_XML
	var strURL = 'OrderEntrySaver.aspx'
				  + '?Mode=Respond'
				  + '&SessionID=' + SessionID

	frmSave.action = strURL;
	void frmSave.submit();
}

//================================================================================

function SaveObservation(SessionID, strObservation_XML)
{
	//Saves a single note directly to the Note tables (skipping
	//the pending item process).  Only used from the DoseCalculation page.
	//30Oct03 AE  

	document.all['dataXML'].value = strObservation_XML
	var strURL = 'OrderEntrySaver.aspx'
				  + '?Mode=CreateObservationNote'
				  + '&SessionID=' + SessionID;

	frmSave.action = strURL;

	void frmSave.submit();
}

//================================================================================


function AttachSystemNote(SessionID, RequestList, ResponseList, AttachNoteType, strData_XML, OverrideDSSWarning, DSSLogResults, PublishToBus, PostconditionRoutines_XML) {
    //AttachToType:			one of Request, Response
    //AttachToID:				CSV list of RequestIDs or ResponseIDs.  (Single ID needs no comma)
    //AttachNoteType:			String. The type of note to attached
    //strData_XML:				String. Data for the note in <data><attribute.../>...</data> format
    //PublishToBus              Boolean. Determines whether or not EpisodeOrders will be published to service bus

    var doPublish = (typeof(PublishToBus) !== "undefined") ? PublishToBus : false;
    var Override = (OverrideDSSWarning == 'true' || OverrideDSSWarning);
    var strURL = 'OrderEntrySaver.aspx'
						  + '?SessionID=' + SessionID
						  + '&Mode=Attach'
						  + '&RequestList=' + RequestList
						  + '&ResponseList=' + ResponseList
						  + '&AttachType=' + AttachNoteType
						  + '&OverrideDSSWarning=' + Override
						  + '&DSSLogResults=' + DSSLogResults
                          + '&PublishToBus=' + doPublish.toString();

    document.all['dataXML'].value = strData_XML;
    document.all['PostconditionRoutinesXML'].value = PostconditionRoutines_XML;
    frmSave.action = strURL;
    frmSave.submit();
}

//================================================================================

function UpdateGroupNote(SessionID, RequestList, ResponseList, AttachNoteType, NoteGroupID, strData_XML, OverrideDSSWarning, DSSLogResults, PostconditionRoutines_XML) {
    //AttachToType:		    	one of Request, Response
    //AttachToID:				CSV list of RequestIDs or ResponseIDs.  (Single ID needs no comma)
    //AttachNoteType:			String. The type of note to attached
    //NoteGroupID:  			String. The note group the note belongs to
    //strData_XML:				String. Data for the note in <data><attribute.../>...</data> format
    var Override = (OverrideDSSWarning == 'true' || OverrideDSSWarning);
    var strURL = 'OrderEntrySaver.aspx'
						  + '?SessionID=' + SessionID
						  + '&Mode=UpdateGroupNote'
						  + '&RequestList=' + RequestList
						  + '&ResponseList=' + ResponseList
						  + '&AttachType=' + AttachNoteType
						  + '&NoteGroupID=' + NoteGroupID
						  + '&OverrideDSSWarning=' + Override
						  + '&DSSLogResults=' + DSSLogResults;

    document.all['dataXML'].value = strData_XML;
    document.all['PostconditionRoutinesXML'].value = PostconditionRoutines_XML;
    frmSave.action = strURL;
    frmSave.submit();
}

//================================================================================

function DisableAttachedNote(SessionID, AttachedNoteType, AttachToType, AttachToID, PublishToBus)
{
    // Switches off the "Enabled" bit of the specified note.
    // PublishToBus              Boolean. Determines whether or not EpisodeOrders will be published to service bus

    var doPublish = (typeof (PublishToBus) !== "undefined") ? PublishToBus : false;

	var strURL = 'OrderEntrySaver.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=AttachedNoteDisable'
				  + '&AttachedNoteType=' + AttachedNoteType
				  + '&AttachToType=' + AttachToType
				  + '&AttachToID=' + AttachToID
                  + '&PublishToBus=' + doPublish.toString();
	
	frmSave.action = strURL;
	frmSave.submit();
}

//================================================================================
function DisableAttachedNoteMultiple(SessionID, AttachedNoteType, RequestList, ResponseList, DiscontinuationReason, PublishToBus)
{
	//AttachToType:			one of Request, Response
	//AttachToID:				CSV list of RequestIDs or ResponseIDs.  (Single ID needs no comma)
	//AttachNoteType:			String. The type of note to attached
	//PublishToBus              Boolean. Determines whether or not EpisodeOrders will be published to service bus

	// Switches off the "Enabled" bit of the specified notes.

	var doPublish = (typeof (PublishToBus) !== "undefined") ? PublishToBus : false;
	var strURL = 'OrderEntrySaver.aspx'
		+ '?SessionID=' + SessionID
		+ '&Mode=AttachedNoteDisableMultiple'
		+ '&AttachedNoteType=' + AttachedNoteType
		+ '&RequestList=' + RequestList
		+ '&ResponseList=' + ResponseList
		+ '&PublishToBus=' + doPublish.toString();

	//15Aug11   Rams    10682 - F0121347 - Storing who has removed a status note
	if (DiscontinuationReason != null)
	{
		document.all['DiscontinuationReasonid'].value = DiscontinuationReason.id;
		document.all['DiscontinuationReasonComment'].value = DiscontinuationReason.comments;
	}
	else
	{
		document.all['DiscontinuationReasonid'].value = '';
		document.all['DiscontinuationReasonComment'].value = '';
	}
	frmSave.action = strURL;
	frmSave.submit();
}

//================================================================================

function DSSCheckOnReconcile(SessionID, RequestList)
{
	var strURL = 'OrderEntrySaver.aspx'
					+ '?SessionID=' + SessionID
					+ '&Mode=DSSCheckOnReconcile'
					+ '&RequestList=' + RequestList;

	frmSave.action = strURL;
	frmSave.submit();
}

//================================================================================

function DSSOverrideOnReconcile(SessionID, DSSLogResults)
{
	var strURL = 'OrderEntrySaver.aspx'
					+ '?SessionID=' + SessionID
					+ '&Mode=DSSOverrideOnReconcile'
					+ '&DSSLogResults=' + DSSLogResults;

	frmSave.action = strURL;
	frmSave.submit();
}

//================================================================================

//18Aug06 AE  Added keyboard event handlers for yes/no buttons which are scripted when dss checks return
function body_onKeydown()
{
    // check if 'y' or 'n' keys are also being pressed
    switch (event.keyCode) 
    {
        case 89: // y
            // click the yes button and return false. Returning false will prevent I.E. from using the alt+y for another control that may use it.
            if (document.all['cmdYes'] != undefined) document.all['cmdYes'].click();
            return false;
            break;
        case 78: // n
            // click the no button and return false. Returning false will prevent I.E. from using the alt+n for another control that may use it.
            if (document.all['cmdNo'] != undefined) document.all['cmdNo'].click();
            return false;
            break;
    }

    return true;
}
//25Sep2009 JMei F0040487 Call printprocessor for printing DSS Warnings
function PrintDSSWarnings() {
    ICWWindow().document.frames['fraPrintProcessor'].PrintDSSWarnings(document.all.SessionID.value, document.all.episodeId.value, document.all.DSSWarningsXML.value);
}

</script>

    <%--    29Sep2009 JMei F0040487 because cannot call js function in this page from a navigated window, we call button onclick function instead
            the following 3 elements are for storing the information --%>
    <input id="printer" type="button" value="" onclick="PrintDSSWarnings();"/>
    <input type="hidden" id="DSSWarningsXML" name="DSSWarningsXML" />
    <input type="hidden" id="SessionID" name="SessionID" />
    <input type="hidden" id="episodeId" name="episodeId" value="<%=episodeId %>"/>

</body>
</html>

<script language="vb" runat="server">
    '--------------------------------------------------------------------------------------------------------
    Function Save(ByVal SessionID As Integer, ByVal Mode As String, ByVal DataXML As String) As String
        
        Dim ResultXML As String = String.Empty

        Select Case Mode
            Case "save"
                Dim strDoseUnitRow As String = GetDosesRow(SessionID)
                Dim XMLDosesRow As New XmlDocument()
                XMLDosesRow.TryLoadXml(strDoseUnitRow)
                Dim XMLDosesNode As XmlElement = XMLDosesRow.SelectSingleNode("//root/Unit")
                If Not XMLDosesNode Is Nothing Then
                    Dim strDoseUnitID As String = XMLDosesNode.GetAttribute("UnitID")
                    Dim DataDoc As New XmlDocument()
                    DataDoc.TryLoadXml(DataXML)
                    Dim Items As XmlNodeList = DataDoc.SelectNodes("//save/item[data[attribute[@name='UnitID_Duration' and @value='" & strDoseUnitID & "']]]")
                    'select items with 'doses' unit attribute
                    For Each Item As XmlElement In Items
                        Dim Item2 As XmlNode = Item.SelectSingleNode("//item/data/attribute[@name='StopDate']")
                        If Not Item2 Is Nothing Then  '16Oct07 EAC SC-07-0658 check if StopDate attribute is in the XML - prevented templates from saving
                            Item2.Attributes.GetNamedItem("value").Value = ""    'null out the end date
                        End If
                    Next
                    DataXML = DataDoc.OuterXml
                End If
                ResultXML = SaveData(SessionID, DataXML)
            Case "respond"
                ResultXML = SaveResponse(SessionID, DataXML)
            Case "cancel"
                ResultXML = SaveCancellation(SessionID, DataXML)
            Case "createobservationnote"
                ResultXML = CreateObservationNote(SessionID, DataXML)
            Case "attach"
                ResultXML = AttachNote(SessionID, DataXML)
            Case "attachpost"
                Dim RequestReader As New System.IO.StreamReader(Page.Request.InputStream)
                DataXML = RequestReader.ReadToEnd()
                ResultXML = AttachNote(SessionID, DataXML)
            Case "attachednotedisable"
                ResultXML = DisableAttachedNote(SessionID)
            Case "attachednotedisablemultiple"
                ResultXML = DisableAttachedNoteMultiple(SessionID, Request.QueryString("AttachedNoteType"))
            Case "updategroupnote"
				ResultXML = UpdateGroupNote(SessionID, DataXML)
			Case "dsscheckonreconcile"
				ResultXML = DSSCheckOnReconcile(SessionID)
			Case "dssoverrideonreconcile"
				ResultXML = DSSOverrideOnReconcile(SessionID)
            Case "xmlput"
                Dim RequestReader As New System.IO.StreamReader(Page.Request.InputStream)
                DataXML = RequestReader.ReadToEnd()
                Generic.SessionAttributeSet(SessionID, "OrderEntry/OrdersXML", DataXML)
            Case "xmlput_testrig"
                DataXML = Request.Form("dataXML")
                Generic.SessionAttributeSet(SessionID, "OrderEntry/OrdersXML", DataXML)
        End Select
        
        Return ResultXML
        
    End Function
    '--------------------------------------------------------------------------------------------------------
    Function SaveData(ByVal SessionID As Integer, ByVal DataXML As String) As String
        '
        'Attempt to save the xml provided.
        Return New OCSRTL10.OrderCommsItem().SaveBatch(SessionID, DataXML)

    End Function

    '---------------------------------------------------------------------------------------------------------------
    Function SaveResponse(ByVal SessionID As Integer, ByVal DataXML As String) As String
        '
        'Attempt to save the xml provided as response data.
        '
        'strDataXML_IN:			XML containing all the data to save
        Return New OCSRTL10.OrderCommsItem().SaveResponseBatch(SessionID, DataXML)

    End Function

    '---------------------------------------------------------------------------------------------------------------
    Function SaveCancellation(ByVal SessionID As Integer, ByVal DataXML As String) As String
        '
        'Attempt to save the xml provided as Request Cancellation Notes.
        'This does not go through the pending item process and so
        'must be complete.
        '
        'strDataXML_IN:			XML containing all the data to save
        Return New OCSRTL10.OrderCommsItem().CancelBatch(SessionID, DataXML)

    End Function

    '---------------------------------------------------------------------------------------------------------------
    Function CreateObservationNote(ByVal SessionID As Integer, ByVal DataXML As String) As String
        '
        ''Attempt to create a a single observation note from the given data.  This does not go through
        'the pending item process and so must be complete.
        'strDataXML_IN:			XML containing all the data to save
        Return New OCSRTL10.OrderCommsItem().CreateNote_Observation(SessionID, DataXML)

    End Function

    '--------------------------------------------------------------------------------------------------
    Function AttachNote(ByVal SessionID As Integer, ByVal DataXML As String) As String
        'Attaches a note to the specified request or response.
        '01Mar06 AE  Modified to attach notes to mutliple items, if specified.
        Dim NoteType As String = Request.QueryString("AttachType")
        Dim RequestList As String = GetRequestIDsXML()
        Dim ResponseList As String = GetResponseIDsXML()
        Dim OverrideDSSWarning As Boolean = (Request.QueryString("OverrideDSSWarning").ToLower() = "true")
        Dim DSSLogResults As String = Request.QueryString("DSSLogResults")

        '09Feb05 AE  Corrected
        If DataXML = Nothing OrElse DataXML = "" Then
            DataXML = "<data />"
        End If
        Dim ReturnValue As String = New OCSRTL10.OrderCommsItem().CreateAttachedNoteMultipleItems(SessionID, DataXML, NoteType, RequestList, ResponseList, OverrideDSSWarning, DSSLogResults, System.Configuration.ConfigurationManager.AppSettings("ICW_V11Location"))
        
        if ReturnValue.Contains("dss") = False Then
            RunPostconditionRoutines(SessionID)
        End if
        
        Return ReturnValue

    End Function
    
    Sub RunPostconditionRoutines(ByVal SessionID As Integer)

        Dim PostconditionRoutinesXML As String = Request.Form("PostconditionRoutinesXML")
        
        if PostconditionRoutinesXML <> String.Empty Then

            Dim xmldoc As XmlDocument = New XmlDocument()
            
            xmldoc.TryLoadXml(PostconditionRoutinesXML)
            
            For Each RoutineNode As XmlNode In xmldoc.DocumentElement.SelectNodes("//Routine")

                Dim Routines As String = RoutineNode.Attributes("PostconditionRoutine").value
                Dim NoteType As String = RoutineNode.Attributes("NoteType").value
                Dim RoutineRead As New ICWRTL10.RoutineRead()
                Dim ItemIDList As String = RoutineNode.Attributes("ItemIDList").value

                Dim routineId As Integer
            
                For Each Routine As String In Routines.Split(New Char(){","c}, StringSplitOptions.RemoveEmptyEntries)
                
                    routineId = 0

                    If Not String.IsNullOrEmpty(Routine.Trim()) Then
                        routineId = RoutineRead.DescriptionToID(SessionID, Routine.Trim())
                    End If
	
                    If routineId = 0 Then
                        Response.Write(String.Empty)
                    Else
                        Dim Params_XML As String = RoutineRead.CreateParameter("ItemIDList", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 1024, ItemIDList) & _
                                                    RoutineRead.CreateParameter("NoteType", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar, 128, NoteType)
        
                        RoutineRead.ExecuteByID(SessionID, routineId, Params_XML)
                    End If
    
                Next
            Next
        End if
    End Sub 

    '--------------------------------------------------------------------------------------------------
    Function DisableAttachedNote(ByVal SessionID As Integer) As String
        'Switches off the "Enabled" bit of the specified attached note.
        Dim AttachedNoteType As String = Request.QueryString("AttachedNoteType")
        Dim AttachToType As String = Request.QueryString("AttachToType")
        Dim AttachToID As Integer = Integer.Parse(Request.QueryString("AttachToID"))
        Dim oDiscontinuationReason As New OCSRTL10.OrderCommsItem.DiscontinuationReason                
        oDiscontinuationReason.Id = Request.Form("DiscontinuationReasonid")
        oDiscontinuationReason.Comments = Request.Form("DiscontinuationReasonComment")

		Return New OCSRTL10.OrderCommsItem().DisableAttachedNote(SessionID, AttachedNoteType, AttachToType, AttachToID, oDiscontinuationReason)

    End Function

    '--------------------------------------------------------------------------------------------------
    Function DisableAttachedNoteMultiple(ByVal SessionID As Integer, ByVal AttachedNoteType As String) As String

        Dim RequestList As String = GetRequestIDsXML()
        Dim ResponseList As String = GetResponseIDsXML()
        Dim oDiscontinuationReason As New OCSRTL10.OrderCommsItem.DiscontinuationReason                
        oDiscontinuationReason.Id = IIf(String.IsNullOrEmpty(Request.Form("DiscontinuationReasonid")),-1,Request.Form("DiscontinuationReasonid"))
        oDiscontinuationReason.Comments = IIf(String.IsNullOrEmpty(Request.Form("DiscontinuationReasonComment")),String.Empty,Request.Form("DiscontinuationReasonComment"))
        Return New OCSRTL10.OrderCommsItem().DisableAttachedNoteByRequestMultiple(SessionID, AttachedNoteType, RequestList, ResponseList, oDiscontinuationReason)

    End Function

    '--------------------------------------------------------------------------------------------------
    Function UpdateGroupNote(ByVal SessionID As Integer, ByVal DataXML As String) As String

        Dim NoteGroupID As Integer = Integer.Parse(Request.QueryString("NoteGroupID"))
        Dim NoteType As String = Request.QueryString("AttachType")
        Dim RequestList As String = GetRequestIDsXML()
        Dim ResponseList As String = GetResponseIDsXML()
        Dim OverrideDSSWarning As Boolean = (Request.QueryString("OverrideDSSWarning").ToLower() = "true")
        Dim DSSLogResults As String = Request.QueryString("DSSLogResults")
		
        If DataXML = Nothing OrElse DataXML = "" Then
            DataXML = "<data />"
        End If
        Dim ReturnValue As String =  New OCSRTL10.OrderCommsItem().UpdateAttachedNoteGroup(SessionID, DataXML, NoteGroupID, NoteType, RequestList, ResponseList, OverrideDSSWarning, DSSLogResults, System.Configuration.ConfigurationManager.AppSettings("ICW_V11Location"))
        
        if ReturnValue.Contains("dss") = False Then
            RunPostconditionRoutines(SessionID)
        End if

        Return ReturnValue

	End Function

	'--------------------------------------------------------------------------------------------------
	Function DSSCheckOnReconcile(ByVal SessionID As Integer) As String

		Dim RequestList As String = GetRequestIDsXML()

		Return New OCSRTL10.OrderCommsItem().DSSCheckOnReconcile(SessionID, RequestList, System.Configuration.ConfigurationManager.AppSettings("ICW_V11Location"))

	End Function

	'--------------------------------------------------------------------------------------------------
	Function DSSOverrideOnReconcile(ByVal SessionID As Integer) As String

		Dim DSSLogResults As String = Request.QueryString("DSSLogResults")
		Dim OrderCommsItem As New OCSRTL10.OrderCommsItem()
		
		OrderCommsItem.DSSOverrideOnReconcile(SessionID, DSSLogResults)

		Return String.Empty
		
	End Function
	
	'--------------------------------------------------------------------------------------------------
    Function GetRequestIDsXML() As String

        Dim RequestList As String = Request.QueryString("RequestList")
        If String.IsNullOrEmpty(RequestList) = True Then
            Return String.Empty
        Else
            Dim strID_XML As String = "<root>"

            For Each ID As String In Request.QueryString("RequestList").Split(",")
                strID_XML &= "<ID>" & ID & "</ID>"
            Next
            strID_XML &= "</root>"
            Return strID_XML
        End If

    End Function

    '--------------------------------------------------------------------------------------------------
    Function GetResponseIDsXML() As String

        Dim ResponseList As String = Request.QueryString("ResponseList")
        If String.IsNullOrEmpty(ResponseList) = True Then
            Return String.Empty
        Else
            Dim strID_XML As String = "<root>"

            For Each ID As String In Request.QueryString("ResponseList").Split(",")
                strID_XML &= "<ID>" & ID & "</ID>"
            Next
            strID_XML &= "</root>"
            Return strID_XML
        End If

    End Function

    '----------------------------------------------------------------------------------------------------------------------------------------
    'return the 'dose' unit row for duration by number of doses option
    Function GetDosesRow(ByVal SessionID As Integer) As String

        Return New DSSRTL20.UnitsRead().UnitByDescription(SessionID, "dose")

    End Function

</script>
