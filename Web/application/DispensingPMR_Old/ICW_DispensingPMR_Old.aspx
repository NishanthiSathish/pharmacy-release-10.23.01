<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<html>
<head>

<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_DispensingPMR.aspx
    '
    'Dispensing PMR grid. Is usually used in the same desktop as the Dispensing.aspx. Combined
    'these two pases are used to display a patient PMR, order prescriptions, and dispense drugs.
    '
    '  **********************************************************************************************
    '  *                                                                                            *
    '  * THIS IS THE OLD VERSION OF THE PMR AND YOU SHOULD NOT BE MAKING YOUR CHANGES HERE.         *
    '  * FOR THE NEW PMR ALL THIS CODE NOW EXISTS IN THE DispensingPMR.aspx PROJECT                 *
    '  *                                                                                            * 
    '  **********************************************************************************************
    '      
    'Modification History:
    '23Sep04 PH Created
    '04Mar11    Rams    F0041360 - Generic Prescription changes
    '10Mar11    Rams    F0111349 - F0041360 -- Generic Prescriptions on the dispensing desktop should be displayed in the Episode Summary
    '20Jun11 XN Added alternate row colouring, and highlighting of dispensed date F0086605
    '12Jul11 XN F0041502 have moved the main code to DispensingPMR.vb (DispensingPMR.RenderDispensings)
    '07Sep11 DJH TFS13018 Added RAISE_EpisodeCleared event.
    '15Aug12 TH  TFS 40790 PSO Support
    '16Sep11 AJK 14362 Added check to ensure focus is a valid function    
    '15Nov12 XN  Made obsolete as replaced by newer speedy version TFS47487
    '13Mar13 XN  59024 Memory Leak Fix
    '14Nov12 AJK 43495 Added check to see if new, ammend and cancel Rx buttons should be disabled for eMM wards if specified
    
    Dim lngSessionID As Long
    Dim lngEpisodeID As Long 
    Dim objStateRead As GENRTL10.StateRead
    Dim lngRequestID_Prescription As Long 
    Dim lngRequestID_Dispensing As Long 
    Dim strView As String 
    Dim blnCurrentOnly As Boolean 
    Dim strRoutineName As String 
    Dim strSelectEpisode As Object 
    Dim blnAutoDispense As Boolean 
    Dim strStatusNoteFilterAction As Object 
    Dim strStatusNoteFilterX As Object 
    Dim strStatusNoteFilter_XML As Object 
    Dim strRepeatDispensing  As Object  '11May09 TH Added
    Dim objDispensingRead As LEGRTL10.DispensingRead
    Dim xmldocRx As New System.Xml.XmlDocument  ' Dim xmldocRx As MSXML2.DOMDocument XN 13Mar13 59024 Memory Leak Fix
    Dim strPSO  As Object  '18Aug12 TH Added
    Dim strTypeInfo_XML As String
    Dim TreatmentPlanRequestTypeID As Integer
    Dim strEnableEMMRestrictions As Boolean '14Nov12 AJK 43495 Added
    Dim objEntityRead As ENTRTL10.EntityRead '14Nov12 AJK 43495 Added

    blnAutoDispense = False
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    'we now check state to see if there is a Prescription RequestID there
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = CLng(objStateRead.GetKey(CInt(lngSessionID), "Episode"))
    lngRequestID_Prescription = CLng(objStateRead.GetKey(CInt(lngSessionID), "Prescription"))
    If lngRequestID_Prescription > 0 Then 
        Generic.StateSet(lngSessionID, "Prescription", 0)
        'we need to auto dispense the selected item
        blnAutoDispense = true
    Else
        'Nothing there so get querystring parameter instead
        lngRequestID_Prescription = Generic.CLngX(Request.QueryString("RequestID_Prescription"))
    End If
    ' Get if using alternate row colouring
    Dim strWorklistAlternateRowColour As String = ICW.ICWParameter("WorkListAlternateRowColour", "Set this to True to alternate the row colours on a worklist.", "True,False")
    If String.IsNullOrEmpty(strWorklistAlternateRowColour) Then
        strWorklistAlternateRowColour = "True"
    End If
    objStateRead = Nothing
    lngRequestID_Dispensing = Generic.CLngX(Request.QueryString("RequestID_Dispensing"))
    strStatusNoteFilterAction = ICW.ICWParameter("StatusNoteFilterAction", "Determines whether the StatusNoteFilter is a list of note statuses to be included or excluded.", "exclude,include")
    strStatusNoteFilterX = ICW.ICWParameter("StatusNoteFilter", "Comma-separated list of Status Note Type buttons to include/excluded", "")
    strRoutineName = Trim(ICW.ICWParameter("PrescriptionRoutine", "Routine used to load prescriptions", ""))
    strSelectEpisode = ICW.ICWParameter("SelectEpisode", "Set this to True to use this application as a way of selecting an episode.  You should only have one application which can select an episode on each desktop.", "False,True")
    'strRepeatDispensing = Request.QueryString("RepeatDispensing")
    'if strRepeatDispensing = "" then
       strRepeatDispensing = ICW.ICWParameter("RepeatDispensing", "Used to identify whether the application is running in repeat dispensing mode", "False,True")
    'end if
    ' If any changes are made to the two routine below you will also need to 
    ' update the pPrescriptionListByMergedPrescription method
    if strRoutineName = "" then
	if strRepeatDispensing = "True" then
		strRoutineName = "PrescriptionByEpisodeForDispensingRptDispOld"
	else
		strRoutineName = "PrescriptionByEpisodeForDispensingOld"
	end if
    end if
    strView = Trim(ICW.ICWParameter("View", "List only current items or history items", "Current,History"))
    strPSO = ICW.ICWParameter("PSO", "Used to identify whether the application is running in PSO mode", "False,True")
    If (String.IsNullOrEmpty(strPSO))
        strPSO = "False"
    End If
    
    blnCurrentOnly = (strView = "Current")

    '14Nov12 AJK 43495 Added check for eMM restrictions
'    strEnableEMMRestrictions = ICW.ICWParameter("EnableEMMRestrictions", "Enables restrictions of the new amend and cancel buttons for eMM wards", "False,True") XN 22Mar13 59449 Fixed conversion error
    Dim strTemp As String = ICW.ICWParameter("EnableEMMRestrictions", "Enables restrictions of the new amend and cancel buttons for eMM wards", "False,True")
    If String.IsNullOrEmpty(strTemp) Then
        strTemp = "False"
    End If
    strEnableEMMRestrictions = BoolExtensions.PharmacyParse(strTemp)
    objEntityRead = New ENTRTL10.EntityRead()
    If Not objEntityRead.PatientIsOneMMWard(CInt(lngSessionID), CInt(lngEpisodeID)) Then
        strEnableEMMRestrictions = False
    End If
    '14Nov12 AJK 43495 End

    Dim requestTypeRead = New OCSRTL10.RequestTypeRead()
    Try
        TreatmentPlanRequestTypeID = requestTypeRead.RequestTypeByDescription(lngSessionID, "Treatment Plan")
    Catch ex As Exception
        TreatmentPlanRequestTypeID = -1
    End Try
%>

	<title>Dispensing PMR</title>


<script language="javascript" type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
<script language="javascript" src="../sharedscripts/ocs/OCSShared.js"></script>
<script language="javascript" src="../sharedscripts/ocs/OCSContextActions.js"></script>
<script language="javascript" src="../sharedscripts/StatusNoteToolbar.js"></script>
<script src="script/DispensingPMR.js?p=1"></script>
<script>
<!--

//07Mar07 CD Moved from DispensingPMR.js to allow asp processing
function RefreshGrid(RequestID_Prescription, RequestID_Dispensing)
{
//  var lngSessionID = document.body.getAttribute("SessionID");     XN 49632 31March12 fixed possible Norfolk script error by having these values subbed directly into code on server
//	var strView = document.body.getAttribute("View");
	var strURL='../DispensingPMR_old/ICW_DispensingPMR_old.aspx?SessionID=<%= lngSessionID %>'
	           + '&PrescriptionRoutine=<%= strRoutineName %>'
	           + '&SelectEpisode=<%= strSelectEpisode %>'
	           + '&View=<%= strView %>'
	           + '&StatusNoteFilterAction=<%= strStatusNoteFilterAction %>' 
	           + '&StatusNoteFilter=<%= strStatusNoteFilterX %>'
		   + '&RepeatDispensing=<%= strRepeatDispensing %>'
		   + '&PSO=<%= strPSO %>';

    if(RequestID_Prescription!=null)	           
        strURL += '&RequestID_Prescription=' + RequestID_Prescription;
    if(RequestID_Dispensing!=null)
	    strURL += '&RequestID_Dispensing=' + RequestID_Dispensing;

	window.navigate( ICWURL(strURL) );
}

//===============================================================================
//									ICW Toolbar EventListeners
//===============================================================================

function EVENT_DispensingList_PrescriptionNew()
{
//Views the currently selected item
// <ToolMenu PictureName="new.gif" Caption="New Prescription" ToolTip="New Prescription" ShortCut="N" HotKey="" />
	PrescriptionNew();
}

function EVENT_DispensingList_PrescriptionNewPSO()
{
//Views the currently selected item
// <ToolMenu PictureName="new.gif" Caption="New PSO Prescription" ToolTip="New PSO Prescription" ShortCut="" HotKey="" />
	PrescriptionNewPSO();
}


function EVENT_DispensingList_UMMCBilling()
{
// XN 11Jan11 F0100728 Displays UMMC billing screen 
// <ToolMenu PictureName="dollar.gif" Caption="Billing" ToolTip="Allows selection of dispensings to send to billing." ShortCut="B" HotKey="" />
    UMMCBilling();
}

function EVENT_DispensingList_RPTDispLink()
{
//links the currently selected dispensing to its prescription
// <ToolMenu PictureName="new.gif" Caption="Repeat Dispensing Link" ToolTip="Link for Repeat Dispensing" ShortCut="" HotKey="" />
	RPTDispensingLink();
}

function EVENT_DispensingList_PatientPrint()
{
//Views the currently selected item
// <ToolMenu PictureName="new.gif" Caption="Patient Printing" ToolTip="Patient Printing" ShortCut="P" HotKey="" />
	PatientPrint();
}

function EVENT_DispensingList_PatientBagLabel()
{
//Views the currently selected item
// <ToolMenu PictureName="new.gif" Caption="Bag Label" ToolTip="Patient Bag Label Printing" ShortCut="B" HotKey="" />
	PatientBagLabel();
}

function EVENT_DispensingList_Dispense()
{
    //Dispense an item
// <ToolMenu PictureName="syringe.gif" Caption="Dispense" ToolTip="Dispense" ShortCut="D" HotKey="" />
	Dispense();
}

function EVENT_DispensingList_DispenseNewDose()
{
//Dispense an item
// <ToolMenu PictureName="syringe.gif" Caption="Dispense" ToolTip="Dispense" ShortCut="D" HotKey="" />
	DispenseNewDose();
}


function EVENT_DispensingList_View() {
//Copies the selected item, then cancels the original
// <ToolMenu PictureName="view.gif" Caption="View" ToolTip="Displays the selected item." ShortCut="" HotKey="V" />
    void DoAction(OCS_VIEW);
}

function EVENT_DispensingList_CancelAndCopyItem() {
//Copies the selected item, then cancels the original
// <ToolMenu PictureName="action remove.gif" Caption="Copy and Cancel" ToolTip="Creates a copy of the selected item, then cancels the original." ShortCut="" HotKey="C" />	
	ClearControl();
	PrescriptionCancelCopy();
}

function EVENT_DispensingList_CancelItem() {
//Cancels the selected item, if applicable
// <ToolMenu PictureName="cross green.gif" Caption="Cancel" ToolTip="Cancels the selected request." ShortCut="" HotKey="X" />
	ClearControl();
	void DoAction(OCS_CANCEL);
}

function EVENT_DispensingList_AttachNotes() {
//View/edit attached notes for the selected item
// <ToolMenu PictureName="../ocs/classAttachedNote.gif" Caption="Attached Notes" ToolTip="Allows you to view and create notes which are attached to the selected item." ShortCut="A" HotKey="" />
	void DoAction(OCS_ANNOTATE);
}

function EVENT_DispensingList_PrescriptionNewPCT()
{
//Views the currently selected item
// <ToolMenu PictureName="new.gif" Caption="New PCT Prescription" ToolTip="New PCT Prescription" ShortCut="" HotKey="" />
	PrescriptionNewPCT();
}

function EVENT_DispensingList_PrintSpecifiedReport(ReportName)
{
    //Prints the selected item
    // <ToolMenu PictureName="Printer.gif" Caption="Print Report" ToolTip="Prints the report." ShortCut="" HotKey="" />
    if (!PrintSpecifiedReport(ReportName))
    {
        ICWToolMenuEnable('DispensingList_PrintSpecifiedReport', false);
    }
}

function EVENT_DispensingList_PrescriptionMerge()
{
    // XN 31May11 F0100728 Added button for PrescriptionLinking
    // <ToolMenu PictureName="prescription merge.gif" Caption="Prescription Merge" ToolTip="Allow selection of prescription to linking screen." ShortCut="A" HotKey="" />
    PrescriptionMerge();
}

function EVENT_DispensingList_DispensePSO()
{
//Create a PSO from a prescription
// <ToolMenu PictureName="supply request.png" Caption="Patient Specific Order" ToolTip="Creates a Patient Specific Order for the given item" ShortCut="" HotKey="" />
	DispensePSO();
}

function EVENT_DispensingList_DispenseNewDosePSO()
{
//Dispense an item
// <ToolMenu PictureName="supply request.png" Caption="Patient Specific Order" ToolTip="Creates a Patient Specific Order for the given item" ShortCut="D" HotKey="" />
	DispenseNewDosePSO();
}


//===============================================================================
//									ICW EventListeners
//===============================================================================

function EVENT_ReportNotFound(ReportName)
{
    if (document.all("txtPrintReport") != undefined)
    {
        if (ReportName == txtPrintReport.value)
        {
            var msg = 'The specified report ' + ReportName + ' cannot be found.\nPlease ensure that the name is specified correctly in the Desktop Editor.'
            var features = 'dialogHeight:200px;'
								 + 'dialogWidth:325px;'
								 + 'resizable:yes;'
								 + 'status:no;help:no;';
            Popmessage(msg, 'Report Not Found!', features);
        }
    }
}

function EVENT_EpisodeSelected(vid)
{
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(<%= CInt(Request.QueryString("SessionID")) %>, vid, EntityEpisodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
    	RefreshGrid();
    }
 }

 //DJH - TFS Bug 12880 - Add new Episode Cleared event.
 function EVENT_EpisodeCleared() {
     RefreshGrid();
 }

function EVENT_RequestSelected() //LM 16/01/2008 Code 162
{
    RefreshGrid();
}

// F0096556 ST 23Sep10 Added missing refresh event to prevent javascript error.
function Refresh() 
{
    RefreshGrid();
}

function EVENT_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
{
// Causes this list to be refreshed from the DB
	if (RequestID_Dispensing > 0)
	{
		RefreshGrid(RequestID_Prescription, RequestID_Dispensing);
	}
	else
	{
		try
		{
		    if (m_trSelected != null) // XN 10Apr13 Fixed issue of dispensing PMR not getting focus again  (original code did not work as m_trSelected.focus return an object)   && (typeof eval(m_trSelected.focus)== 'function')) // 14362 16Sep11 AJK Added check to ensure focus is a valid function
		    {
			    m_trSelected.focus();
		    }
		    else
		    {
				document.getElementById("tbdy").focus();
    		}		
		}
		catch (e)
		{}
	}
}

function EVENT_RequestChanged() 
{
    RefreshGrid();
}

function EVENT_NoteChanged()
{
    RefreshGrid();
}


//===============================================================================
//									ICW Raised Events
//===============================================================================

function RAISE_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
// This event is listened to by the Dispensing page that hosts the ActiveX Dispensing control, 
// which is hosted in Dispensing web page.
// This event is raised when an item needs to be created or edited by the Dispensing control. 
// A RequestID of 0 means "create", a positive RequestID means edit the item with that RequestID
	window.parent.RAISE_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing);
}

function RAISE_EpisodeSelected(jsonEntityEpisodeVid)
{
// Occurs when episode is changed. Causes a patient to be selected.
	window.parent.RAISE_EpisodeSelected(jsonEntityEpisodeVid);
}

//DJH TFS13018
function RAISE_EpisodeCleared() {
    window.parent.RAISE_EpisodeCleared();
}

function RAISE_RequestSelected()
{
    window.parent.RAISE_RequestSelected();
}

function RAISE_RequestChanged()
{
    window.parent.RAISE_RequestChanged();
}
function RAISE_NoteChanged()
{
    window.parent.RAISE_NoteChanged();
}
function RAISE_Prescription_info(lngRequestID_Prescription)
{
	window.parent.RAISE_Prescription_info(lngRequestID_Prescription);
}
function RAISE_Dispensing_info(lngRequestID_Dispensing)
{
	window.parent.RAISE_Dispensing_info(lngRequestID_Dispensing);
}

//===============================================================================
function SaveComplete(blnSuccess) {
	
//Fires when the save page has finished saving.  It contains
//an XML Island which holds the details of the success / failiure
//of each item in the 

	if (blnSuccess) {
		window.returnValue = document.frames['fraSave'].saveData.XMLDocument.xml;
		RefreshGrid(m_trSelected.getAttribute("i"),0);				
					
	}
	else {
		//Something failed; ALWAYS show the error report
		void ShowSaveResults();
	}
}

function ShowSaveResults() {

var intCount = new Number();
var objRule = new Object();

	var DOM = document.frames['fraSave'].document.all['saveResultsXML'].XMLDocument;

	var strMsg = 'WARNING!  Save Failed!\n\n';
	var colErrors = DOM.selectNodes('//BrokenRules');
	if (colErrors.length > 0) {
		for (intCount=0; intCount < colErrors.length; intCount++) {
			objRule = colErrors[intCount].selectSingleNode('Rule');
			strMsg += objRule.getAttribute('Text') + '\n\n';
		}
		Popmessage(strMsg);		
	}

}

//-->
</script>
<link rel="stylesheet" type="text/css" href="../../style/application.css"/>
<link rel="stylesheet" type="text/css" href="../../style/DispensingPMR_Old.css"/>

</head>

<body 
		scroll="no" 
		onload="window_onload()" 
		SessionID="<%= lngSessionID %>" 
		sid="<%= lngSessionID %>" 
		RequestID_Prescription="<%= lngRequestID_Prescription %>" 
		RequestID_Dispensing="<%= lngRequestID_Dispensing %>" 
		View="<%= strView %>" 
		class="GridBody"
		SelectEpisode="<%= strSelectEpisode %>"
		AutoDispense="<%= blnAutoDispense %>"
		RepeatDispensing="<%= strRepeatDispensing %>"
		PSO="<%= strPSO %>"
		EpisodeID="<%= lngEpisodeID %>"
		WorkListAlternateRowColour="<%= strWorklistAlternateRowColour %>"
		treatmentplanrequesttype="<%=TreatmentPlanRequestTypeID %>"
		EnableEmmRestrictions="<%=strEnableEMMRestrictions %>"
>

<input type="hidden" id="txtPrintReport" name="txtPrintReport" value="" />

<table width="100%" height="100%" cellpadding="0" cellspacing="0">	
	<tr height="1%">
		<td class="Toolbar">
<%
    strStatusNoteFilter_XML = StatusNoteToolbar.StatusNoteFilterXML(strStatusNoteFilterX, strStatusNoteFilterAction)
    objDispensingRead = New LEGRTL10.DispensingRead()
    xmldocRx.LoadXml(objDispensingRead.PrescriptionListByEpisode(CInt(lngSessionID), CInt(lngEpisodeID), blnCurrentOnly, strRoutineName))
    objDispensingRead = Nothing
    '<P P_ID="302511" P_RequestTypeID="28" PDesc="KETOPROFEN 100mg M/R CAPSULE when required" PStart="2004-11-05T14:28:12.883" PStop="2004-11-05T14:28:12.883" P_IsCurrent="1" HasNotes="1/0" HasDispensings="1/0" DispDate="2004-11-05T14:28:12" DispQty="123" DispUser="Bob the Bob" />
    strTypeInfo_XML = BuildTypeInfo(lngSessionID, xmldocRx)
    ICW.ICWHeader(lngSessionID)
    StatusNoteToolbar.ScriptStatusNoteToolbars(strTypeInfo_XML, strStatusNoteFilter_XML, strStatusNoteFilterAction)
%>
				
		</td>
	</tr>
	<tr>
		<td>


<div id="tbl-container" style="height:100%; width:100%; overflow:auto;" onactivate="grid_onactivate()" ondeactivate="grid_ondeactivate()">
	<table id="tbl" cellspacing="0" width="100%" >
		<thead>
			<tr class="GridHeading" style="top: expression(document.getElementById(&quot;tbl-container&quot;).scrollTop);position:relative;">
				<th style="width:1%" class="GridHeadingCell">&nbsp;</th>
				<th style="width:68%" class="GridHeadingCell">Description</th>
				<th style="width:1%" class="GridHeadingCell">&nbsp;</th>
				<th style="width:1%" class="GridHeadingCell">NSV</th>
				<th style="width:1%" class="GridHeadingCell">Ward</th>
				<th style="width:1%" class="GridHeadingCell">Cons</th>
				<th style="width:1%" class="GridHeadingCell">By</th>
				<th style="width:1%" class="GridHeadingCell">Site</th>
				<th style="width:1%" class="GridHeadingCell">Dispensed</th>
				<th style="width:10%" class="GridHeadingCell">Qty</th>
				<th style="width:1%" class="GridHeadingCell">Start</th>
				<th style="width:1%" class="GridHeadingCell">Stop</th>
				<th style="width:1%" class="GridHeadingCell">Id</th>
				<th style="width:1%" class="GridHeadingCell">&nbsp;</th>
				<%
				If strRepeatDispensing = "True" then
					response.write ("<th style='width:1%' class='GridHeadingCell'>POM</th>")
					response.write ("<th style='width:1%' class='GridHeadingCell'>Rpt</th>")
				ElseIf strPSO = "True" then
					response.write ("<th style='width:1%' class='GridHeadingCell'>POM</th>")
					response.write ("<th style='width:1%' class='GridHeadingCell'>PSO</th>")
				Else
					response.write ("<th style='width:2%' class='GridHeadingCell'>POM</th>")
				End if

				%>
			</tr>
		</thead>
		<colgroup>
			<col style="width:1%; padding:2px; border:none" />
			<col style="width:68%;padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:10px; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<col style="width:1%; padding:2px" />
			<%
			If strRepeatDispensing = "True" or strPSO = "True" then
				response.write ("<col style='width:2%; padding:1px' />")
				response.write ("<col style='width:2%; padding:1px' />")
			Else
				response.write ("<col style='width:2%; padding:2px' />")
			End if
			%>
			<col style="width:1%; padding:2px" />
		</colgroup>		

		<tbody id="tbdy" onclick="grid_onclick()" onkeydown="grid_onkeydown()">
<%
    DispensingPMR_old.RenderPrescriptions(Me, lngSessionID, xmldocRx, 0, BoolExtensions.PharmacyParse(strPSO))
%>
	
		</tbody>
	</table>
</div>

<iframe application=yes 
		  style='display:none;' 
		  id='fraSave'     
		  src="../OrderEntry/OrderEntrySaver.aspx" 
		  >
</iframe>

<iframe style="display:none" id="fraLoader" application="yes" width="100%" src=""></iframe>


		</td>
	</tr>
</table>

<xml id="basketData"></xml>

<xml id="xmlItem"></xml>
<xml id="xmlType"></xml>

<xml id="xmlStatusNoteFilter"><%= strStatusNoteFilter_XML %></xml>

</body>
</html>


<script language="vb" runat="server">

    '    Function BuildTypeInfo(ByVal SessionID As Integer, ByVal xmldocRx As MSXML2.DOMDocument) As String XN 13Mar13 59024 Memory Leak Fix
    Function BuildTypeInfo(ByVal SessionID As Integer, ByVal xmldocRx As System.Xml.XmlDocument) As String

        Dim xmlnodelistRxs As System.Xml.XmlNodeList    ' Dim xmlnodeRx As MSXML2.IXMLDOMElement        XN 13Mar13 59024 Memory Leak Fix
        Dim objType As OCSRTL10.RequestTypeRead         ' Dim xmlnodelistRxs As MSXML2.IXMLDOMNodeList  XN 13Mar13 59024 Memory Leak Fix
        Dim strTypeXML As String
        Dim strXML As String = String.Empty
        Dim xmldocType As System.Xml.XmlDocument        ' Dim xmldocType As MSXML2.DOMDocument          XN 13Mar13 59024 Memory Leak Fix
        Dim xmlnodeTypeRoot As System.Xml.XmlNode       ' Dim xmlnodeTypeRoot As MSXML2.IXMLDOMNode     XN 13Mar13 59024 Memory Leak Fix
        xmldocType = New System.Xml.XmlDocument         ' xmldocType = New MSXML2.DOMDocument()         XN 13Mar13 59024 Memory Leak Fix
        xmldocType.loadXML("<root/>")
        xmlnodeTypeRoot = xmldocType.selectSingleNode("//root")
        objType = New OCSRTL10.RequestTypeRead()
        xmlnodelistRxs = xmldocRx.selectNodes("//P")
        '<P P_ID="302511" P_RequestTypeID="28" PDesc="KETOPROFEN 100mg M/R CAPSULE when required" PStart="2004-11-05T14:28:12.883" PStop="2004-11-05T14:28:12.883" P_IsCurrent="1" HasNotes="1/0" HasDispensings="1/0" DispDate="2004-11-05T14:28:12" DispQty="123" DispUser="Bob the Bob" />
        ' For Each xmlnodeRx In xmlnodelistRxs  XN 13Mar13 59024 Memory Leak Fix
        For c As Int32 = 0 to xmlnodelistRxs.Count - 1
            Dim xmlnodeRx As System.Xml.XmlElement = xmlnodelistRxs.Item(c)
            If xmldocType.selectSingleNode("//r" & xmlnodeRx.getAttribute("P_RequestTypeID")) Is Nothing Then
                xmlnodeTypeRoot.appendChild(xmldocType.createElement("r" & xmlnodeRx.getAttribute("P_RequestTypeID")))
                strTypeXML = objType.RequestTypeStatusNoteListXML(SessionID, CInt(Generic.CLngX(xmlnodeRx.getAttribute("P_RequestTypeID"))))
                strTypeXML = Mid(strTypeXML, 7, Len(strTypeXML) - 13)
                If InStr(strXML, strTypeXML) = 0 Then
                    strXML = strXML & strTypeXML
                End If
            End If
        Next
        objType = Nothing
        BuildTypeInfo = "<typeinfo>" & strXML & "</typeinfo>"
        
    End Function


    Function FormatTime(ByRef strTime As String) As String
        
        strTime = Trim(strTime)
        If Len(strTime) = 4 And Right(strTime, 2) = "00" Then
            strTime = Left(strTime, 2)
        End If
        Return strTime
        
    End Function

</script>
