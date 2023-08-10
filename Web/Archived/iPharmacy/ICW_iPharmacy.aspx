<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../../application/SharedScripts/ASPHeader.aspx"-->

<script language="vb" runat="server">

    '-----------------------------------------------------------------------------------------------
    'iPharmacy.aspx
    '
    'Shells v8, passing information about the patient and his/her allergies.
    '
    '16Jul03 PH Created
    '
    '04Aug03 DB Extra xml information added to take through to v8. Note program launches ASCShell in
    'Mode 4 (Dispensary) OCX mode.
    '06Aug03 DB Added code to handle Allergies in the v8 format. TH has added code to
    'accept the allergy with their reaction in v8 ascshell.
    '22Aug03 DB Changed to handle missing entries in the Setting table. Raises an error
    'and displays the error information in red on the screen.
    '23Sep03 DB Changed the output for Allergies to be as pAllergy and pNotes respectively as
    'per the v8 format (and agreed on specification version 1F).
    '30Oct03 PH Renamed to iPharmacy.aspx. Functionality added to call mode v8 modules.
    '05May04 AE Tidied. (dims at top of page etc).  Restructured to prevent auto-launching.
    'Added proper toolmenu button instead of a button on the page.
    'Error message now pops up rather than being hidden on a page which is usually only 20px high.
    'I need a shower now.
    '21Jul04 ATW Removed defer attribute from script block because there are functions in it that get called during
    'page loading.
    '17Sep04 PH Added standard section to display toolbars... Took out the HTML debug button.
    '20Aug13 XN Removed MSXML2
    '-----------------------------------------------------------------------------------------------
    'Constants
    Const BLOCK As String = "[160]"
    Const CRLFBRACKET As String = "[crlf]"
    Const CRBRACKET As String = "[cr]"
    Const NOTES_START As String = "Allergy/Reaction to[160]"
    Dim lngEpisodeID As Integer 
    Dim objStateRead As Object ' GENRTL10.StateRead
    Dim strSubModuleCode As String 
    Dim lngSessionID As String 
    Dim strModuleName As String 
    Dim strSiteNo As String 
    Dim strDriveLetter As String 
    Dim strAccessLevel As String 
    Dim strErrMsg As String 
    Dim strModuleCode As String 
    Dim blnPatientRequired As Boolean 
    Dim blnCanLaunch As Boolean 
    Dim strStart As String 
    Dim strPatient_XML As String 
    Dim xmldocSource As XmlDocument ' As Object MSXML2 removal
    Dim xmlnodeSource As XmlElement ' As Object MSXML2 removal
    Dim xmldocTarget As XmlDocument ' As Object MSXML2 removal
    Dim xmlnodeTarget As XmlElement ' As Object MSXML2 removal
    Dim objPatientRead As Object ' ENTRTL10.PatientRead
    Dim xmlSession As XmlDocument   ' As Object MSXML2 removal
    Dim objSessionRead As Object ' SECRTL10.SecurityRead
    Dim objSecRead As Object ' SECDTL10.SecurityAdminRead
    Dim lngUserEntityID As Object ' System.Object
    Dim xmlUser As XmlDocument      ' As Object MSXML2 removal
    Dim strAutoLaunch As String
    
    Sub AddAttribute(ByVal dom As Object, ByVal name As String, ByVal value As Object)
        'Create a new node and add the value and attribute pairs
        Dim newel As XmlElement     ' As Object MSXML2 removal
        Dim newatt As XmlAttribute  ' As Object MSXML2 removal
        newel = dom.createElement("Attribute")
        newatt = dom.createAttribute("name")
        newatt.Value = name
        newel.attributes.setNamedItem(newatt)
        newatt = dom.createAttribute("value")
        newatt.value = value
        newel.attributes.setNamedItem(newatt)
        dom.documentElement.insertBefore(newel, dom.documentElement.firstChild)
        newel = Nothing
        newatt = Nothing
    End Sub

    Sub encodehex(ByRef passw As String)
        ', Optional i_intSeed As Integer = 0)
        '-----------------------------------------------------------------------------
        '30Oct94 CKJ Written. Returns an decoded hex string
        '05Jul01 AE  Added Optional Seed parameter.
        'calls to this function with the same value of i_intSeed
        'will always produce the same encoded string
        '18Mar03 ATW Emasculated slightly for web page (removed type declarations and characters)
        '-----------------------------------------------------------------------------
        'Const cSubName = ".encodehex"
        Dim pasin As String 
        Dim plen As Integer 
        Dim ByteNo As Integer 
        Dim pasch As Integer 
        Dim intDummy As Object 
        'Use a different sequence each time
        Randomize(DateAndTime.Timer)
        plen = Len(passw)
        pasin = passw
        passw = ""
        If plen Then 
            For ByteNo = 1 To plen
                pasch = Asc(Mid(pasin, ByteNo))
                passw = passw & Right("0" & Hex(((pasch \ 2) And &H55) Or (CInt((Rnd() * 256)) And &HAA)), 2)
                passw = passw & Right("0" & Hex((pasch And &H55) Or (CInt((Rnd() * 256)) And &HAA)), 2)
            Next
            '14Feb95 CKJ removed byteno
        End IF
    End Sub

'    Function Buildv8AllergyStrings(xmlDOM As Object) As Boolean    MSXML2 removal
    Function Buildv8AllergyStrings(xmlDOM As XmlDocument) As Boolean
        'Takes a working XML dom containing v8 Attributes and returns two new nodes
        'containing Allergies and Allergy Reactions. The two new nodes are in the format:-
        '
        '<Attribute /Patient@pAllergy='AllergyA, AllergyB, etc'></Attribute>
        '<Attribute /Patient@pAllergyDescription='AllergyReactionToA, AllergyReactionToB, etc'></Attribute>
        '
        'For Allergies where there is more than one reaction, strings together the different live
        'reactions
        '
        '06Aug03 DB Created
        '23Sep03 DB Changed as per agreed functional specification 1F (TH/CKJ/DB).
        '--------------------------------------------------------------------------------------
        'Objects
        Dim objAllergyRead As Object ' OCSRTL10.AllergyRead
        Dim xmlAllergyDOM As XmlDocument                ' As Object MSXML2 removal
        Dim xmlAllergyList As XmlNodeList               ' As Object MSXML2 removal
        Dim xmlAllergyElement As XmlElement             ' As Object MSXML2 removal
        Dim xmlAllergyReactionList As XmlNodeList       ' As Object MSXML2 removal  
        Dim xmlAllergyReactionElement As XmlElement     ' As Object MSXML2 removal
        Const NOTE_SIZE_LIMIT As Integer = 16384
        'Maximum limit for note length
        'General
        Dim strAllergyXML As String 
        Dim blnFirstReaction As Boolean 
        Dim blnLimitOK As Boolean 
        Dim strAllergy As String 
        Dim strNotes As String 
        Dim CRLF As String 
        Dim strReaction As String 
        CRLF = Chr(13) & Chr(10)
        'Fetch the Allergies for this patient together with their Reaction(s)
        objAllergyRead = new OCSRTL10.AllergyRead()
        strAllergyXML = objAllergyRead.AllergyWithReactionByEpisodeXML(CInt(lngSessionID), lngEpisodeID, false)
        objAllergyRead = Nothing
        blnLimitOK = true
         If Trim(strAllergyXML) <> "" Then 
'           xmlAllergyDOM = new MSXML2.DOMDocument()       MSXML2 Removal
'           If xmlAllergyDOM.loadXML(strAllergyXML) Then 
            xmlAllergyDOM = new XmlDocument()
            Dim xmlLoaded As Boolean = False

            Try
                xmlAllergyDOM.LoadXml(strAllergyXML)
                xmlLoaded = True
            Catch ex As Exception
            End Try

            If xmlLoaded Then 
                xmlAllergyList = xmlAllergyDOM.selectNodes("root/Allergy[@Active='1']")
                'Get all Active Allergies
                'If xmlAllergyList.length > 0 Then  MSXML2 Removal
               If xmlAllergyList.Count > 0 Then 
                    strAllergy = ","
                End IF
                For Each xmlAllergyElement In xmlAllergyList
                    'Build up the Allergy (chemical) string converting to uppercase
                    strAllergy = strAllergy & UCase(xmlAllergyElement.getAttribute("AllergyDescription")) & ","
                    'Now string together the reaction(s) in turn for this Allergy (Live only)
                    xmlAllergyReactionList = xmlAllergyElement.selectNodes("AllergyReaction[@ReactionActive='1']")
                    blnFirstReaction = true
                    For Each xmlAllergyReactionElement In xmlAllergyReactionList
                        strReaction = SplitLine(Trim(xmlAllergyReactionElement.getAttribute("ReactionDescription")))
                        strNotes = strNotes & CRBRACKET & CRBRACKET & NOTES_START & Trim(UCase(xmlAllergyElement.getAttribute("AllergyDescription"))) & BLOCK & Trim(FormatDate(xmlAllergyReactionElement.getAttribute("ReactionCreatedDate"))) & " " & Trim(xmlAllergyReactionElement.getAttribute("ReactionCreatedUser")) & CRBRACKET & xmlAllergyReactionElement.getAttribute("SeverityDescription") & _
                            " - " & strReaction & BLOCK
                        blnFirstReaction = false
                    Next
                    xmlAllergyReactionElement = Nothing
                    xmlAllergyReactionList = Nothing
                Next
                If Trim(strNotes) <> "" Then 
                    strNotes = strNotes & CRBRACKET
                    'Add a final [cr]
                End IF
                'Construct the Allergy Element
                AddAttribute(xmlDOM, "/Patient@pAllergy", strAllergy)
                'Construct the Allergy Description Element
                AddAttribute(xmlDOM, "/Patient@pNotes", strNotes)
                xmlAllergyElement = Nothing
                xmlAllergyList = Nothing
                xmlAllergyDOM = Nothing
                If Len(strNotes) > NOTE_SIZE_LIMIT Then 
                    blnLimitOK = false
                End IF
            End IF
        End IF
        objAllergyRead = Nothing
        Buildv8AllergyStrings = blnLimitOK
    End Function

    Function FormatDate(strDate As Object) As String
        'Puts date into DD-MM-YYYY HH:MM format
        FormatDate = Mid(strDate, 9, 2) & "-" & Mid(strDate, 6, 2) & "-" & Left(strDate, 4) & _
            " " & Mid(strDate, 12, 5)
    End Function

    Function SplitLine(strOriginalText As String) As String
        'Splits the text so that each 80 characters an xml carriage return [cr] is inserted
        'Also replaces any CHR(13) characters with the xml carriage return [cr]
        '24Sep03 DB Written
        Const LINELEN As Integer = 80
        Dim lngLoop As Integer 
        Dim strNewText As String 
        For lngLoop = 1 To Len(strOriginalText)
            If Mid(strOriginalText, lngLoop, 1) = CStr(Chr(13)) Then 
                strNewText = strNewText & CRBRACKET
            ElseIf Mid(strOriginalText, lngLoop, 1) = CStr(Chr(10)) Then 
                'Do Nothing with LF
            Else
                strNewText = strNewText & Mid(strOriginalText, lngLoop, 1)
            End IF
            If lngLoop Mod LINELEN = 0 Then 
                strNewText = strNewText & CRBRACKET
            End IF
        Next
        SplitLine = strNewText
    End Function

</script>

<%
    lngSessionID = Request.QueryString("SessionID")
    strModuleName = Trim(ICW.ICWParameter("Module", "Module to be used", "Patient Medication Records,Purchase Ordering,System Maintenance,EIS Reporter,Over Night Job Editor,Product Enquiry"))
    strSiteNo = Trim(ICW.ICWParameter("SiteNo", "3 Digit Site Number e.g. 427", ""))
    strDriveLetter = UCase(Trim(ICW.ICWParameter("DriveLetter", "Data Drive. Drive that the data is stored on.", "")))
    strAccessLevel = Trim(ICW.ICWParameter("AccessLevel", "10-Digit access level code e.g. 9500142073", ""))
    strAutoLaunch = Trim(ICW.ICWParameter("AutoLaunch", "Auto-launch web-based pharmacy", "Yes,No"))
    objStateRead = new GENRTL10.StateRead()
    lngEpisodeID = objStateRead.GetKey(CInt(lngSessionID), "Episode")
    objStateRead = Nothing
    strErrMsg = ""
    If Trim(strDriveLetter) = "" Then 
        strErrMsg = strErrMsg & "Missing drive letter. Must contain a single letter (A-Z)" & vbCr
    End IF
    If Generic.CLngX(strSiteNo) = 0 Then
        strErrMsg = strErrMsg & "Site number must be a number greater than zero" & vbCr
    End If
    If Len(strAccessLevel) < 10 Then 
        strErrMsg = strErrMsg & "AccessLevel must contain ten digits e.g. 9500142073" & vbCr
    End IF
    Select Case strModuleName
    Case "Patient Medication Records"
        strModuleCode = "XS"
        strSubModuleCode = "PMR"
    Case "Purchase Ordering"
        strModuleCode = "XO"
    Case "System Maintenance"
        strModuleCode = "XM"
    Case "EIS Reporter"
        strModuleCode = "XR"
    Case "Over Night Job Editor"
        strModuleCode = "XN"
    Case "Product Enquiry"
        strModuleCode = "XE"
    End Select
    blnPatientRequired = (strModuleCode = "XS")
    blnCanLaunch = (strErrMsg = "" And ((blnPatientRequired And lngEpisodeID > 0) Or (Not blnPatientRequired)))
%>


<html>
<head>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<title>Pharmacy</title>
<script src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script src="../sharedscripts/icwfunctions.js"></script>

<script>
//------------------------------------------------------------------------------------------
//										Inline Code
//------------------------------------------------------------------------------------------
<%
    If strErrMsg <> "" Then 
        Response.Write("alert(txtError.value)" & vbCr)
    End IF
    If lngEpisodeID > 0 Then 
        Response.Write("void EnableButton();")
    End IF
%>


//------------------------------------------------------------------------------------------
//										ICW Event Handlers
//------------------------------------------------------------------------------------------
function EVENT_EpisodeSelected(vid)
{
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(<%= CInt(Request.QueryString("SessionID")) %>, vid, EntityEpisodeSyncSuccess);

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
	        void EnableButton();
        <%
            If strAutoLaunch = "Yes" Then 
        %>

		        LaunchPharmacy();
        <%
            End IF
        %>
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
function EVENT_EpisodeCleared()
{
    void DisableButton();
}

//------------------------------------------------------------------------------------------
//										Toolbar Event Handlers
//------------------------------------------------------------------------------------------

function PHARMACY_iPharmacy_Launch() {
// <ToolMenu PictureName="pharmacy.gif" Caption="Launch" ToolTip="Launch pharamcy" ShortCut="L" HotKey="L" />
	void LaunchPharmacy();
<%
    If strAutoLaunch = "Yes" Then 
%>

		LaunchPharmacy();
<%
    End IF
%>

}

//------------------------------------------------------------------------------------------
//										Internal Methods
//------------------------------------------------------------------------------------------

function EnableButton() {
	void ICWToolMenuEnable('iPharmacy_Launch', true);
}
//------------------------------------------------------------------------------------------

function DisableButton() {
	void ICWToolMenuEnable('iPharmacy_Launch', false);
}
//------------------------------------------------------------------------------------------

function LaunchPharmacy()
{
//Navigates the page again, when it loads it will shell the pharmacy.
	var strURL = "../iPharmacy/ICW_iPharmacy.aspx?SessionID=<%= lngSessionID %>&Module=<%= strModuleName %>&SiteNo=<%= strSiteNo %>&DriveLetter=<%= strDriveLetter %>&AccessLevel=<%= strAccessLevel %>&AutoLaunch=<%= strAutoLaunch %>";

	window.navigate(ICWURL(strURL));
}
//------------------------------------------------------------------------------------------
function ShellPharmacy()
{
//Actually loads the pharmacy OCX
	if (DispOCX.readyState == 4) {
		DispOCX.SessionXML = SessionExtend.documentElement.text;
		DispOCX.OpenDispensary(StartProperties.documentElement.text);		
	}
}

</script>
<script>
<!--

function window_onload()
{
<%
    If blnCanLaunch Then 
        Response.Write("EnableButton();")
    End IF
%>

}

//-->
</script>
</head>
<body style="overflow-y:none;" onload="window_onload()">

<table width="100%" height=100% cellpadding="0" cellspacing="0">
	<tr valign=top>
		<td width=50%>
<%
    'ICW.ICWHeader()
%>

		<td>
	</tr>
</table>

<%
        'Write error message to a hidden control;
    If strErrMsg <> "" Then 
        Response.Write("<textarea id=""txtError"" " & "style=""display:none"" " & ">" & "Missing Start Parameters:" & vbCr & vbCr & strErrMsg & "</textarea>" & vbCr)
    End IF
%>



<!-- Startup properties for OCX -->
<XML id=StartProperties >
<Text>
<%
    'Write the shell startup information here. (as encodehexed semicolon (';') delimited text)
    'e.g.
    strStart = "ModuleType=" & strModuleCode & ";ASCribeCommand=" & strDriveLetter & ":;ASCribePath=C:\ASCRIBE;ASCribeSiteNumber=" & (Right("000" & strSiteNo, 3)) & ";AccessLevels=" & strAccessLevel & ";ForceAuthentication=0"
    encodehex(strStart)
    Response.Write(strStart)
%>

</Text>
</XML>

<xml id=SessionExtend>
<Data>
<%
        'Note : For Allergies with their reactions these need to go into the following format;
        '
        '/Patient@PAllergy="AllergyA, AllergyB, AllergyC"
        '/Patient@PAllergyDescription="AllergyReactionA, AllergyReactionB, AllergyReactionC"
        '
        'Where AllergyReactionA is the reaction of AllergyA, B is B, in that order
    If blnCanLaunch Then 
        'Create AttributeCollection node, which we will be appending all our nodes to
        xmldocTarget = new XmlDocument()    ' = new MSXML2.DOMDocument() as MSXML2 Removal
        xmlnodeTarget = xmldocTarget.createElement("AttributeCollection")
        xmldocTarget.appendChild(xmlnodeTarget)
        'Open the source XML, to start reading source values
        xmldocSource = new XmlDocument()    ' = new MSXML2.DOMDocument() as MSXML2 Removal
        'General '31Oct03 ATW ; requires sub-module code (at least for dispensary)
        AddAttribute(xmldocTarget, "/General@Module", strSubModuleCode)
        'Mode
        'Fixed this line to use the thoughtfully provided User node instead of just hardcoding it.
        'fetch the session info
        xmlSession = new XmlDocument()      ' = new MSXML2.DOMDocument() as MSXML2 Removal
        objSessionRead = new SECRTL10.SecurityRead()
        xmlSession.loadXML(objSessionRead.GetSession(CInt(lngSessionID), CInt(lngSessionID)))
        objSessionRead = Nothing
        lngUserEntityID = xmlSession.documentElement.getAttribute("EntityID")
        xmlSession = Nothing
        xmlUser = new XmlDocument()         ' = new MSXML2.DOMDocument() as MSXML2 Removal
        objSecRead = new SECDTL10.SecurityAdminRead()
        xmlUser.loadXML(objSecRead.GetUser(CInt(lngSessionID), CInt(lngUserEntityID)))
        objSecRead = Nothing
        AddAttribute(xmldocTarget, "/General@UserID", UCase(Trim(xmlUser.documentElement.getAttribute("Initials"))))
        '"V92"
        AddAttribute(xmldocTarget, "/General@AccessLevel", strAccessLevel)
            '"8402290333"
        If lngEpisodeID > 0 Then 
            'Get Patient & Allegies data
            objPatientRead = new ENTRTL10.PatientRead()
            xmldocSource.loadXML(objPatientRead.V8InterfaceReadXML(CInt(lngSessionID), lngEpisodeID))
            objPatientRead = Nothing
            'Patient fields
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Patient")
            AddAttribute(xmldocTarget, "/Patient@pForename", xmlnodeSource.getAttribute("Forename"))
            AddAttribute(xmldocTarget, "/Patient@pSurname", xmlnodeSource.getAttribute("Surname"))
            Select Case UCase(xmlnodeSource.getAttribute("Gender"))
            Case "MALE"
                AddAttribute(xmldocTarget, "/Patient@pSEX", "M")
            Case "FEMALE"
                AddAttribute(xmldocTarget, "/Patient@pSEX", "F")
            Case Else 
                AddAttribute(xmldocTarget, "/Patient@pSEX", "U")
            End Select
            Select Case UCase(xmlnodeSource.getAttribute("PatientStatus"))
            Case "INPATIENT"
                AddAttribute(xmldocTarget, "/Episode@pStatus", "I")
            Case "OUTPATIENT"
                AddAttribute(xmldocTarget, "/Episode@pStatus", "O")
            End Select
            AddAttribute(xmldocTarget, "/Patient@DateOfBirth", xmlnodeSource.getAttribute("DOB"))
            If Not IsDBNull(xmlnodeSource.getAttribute("NHSNumber")) Then 
                AddAttribute(xmldocTarget, "/Patient@pNHnumber", xmlnodeSource.getAttribute("NHSNumber"))
            Else
                AddAttribute(xmldocTarget, "/Patient@pNHnumber", "")
            End IF
            If Not IsDBNull(xmlnodeSource.getAttribute("NHSNumberValid")) Then 
                AddAttribute(xmldocTarget, "/Patient@pNHnumValid", xmlnodeSource.getAttribute("NHSNumberValid"))
            Else
                AddAttribute(xmldocTarget, "/Patient@pNHnumValid", "")
            End IF
            'Patient fields continued ... from Episode field get Case number
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Episode")
            AddAttribute(xmldocTarget, "/Patient@pCaseNo", xmlnodeSource.getAttribute("CaseNo"))
            'Address fields
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Address")
            If Not xmlnodeSource Is Nothing Then 
                AddAttribute(xmldocTarget, "/Episode@pAddress1", xmlnodeSource.getAttribute("DoorNumber") & _
                    " " & xmlnodeSource.getAttribute("Building") & " " & xmlnodeSource.getAttribute("Street"))
                AddAttribute(xmldocTarget, "/Episode@pAddress2", xmlnodeSource.getAttribute("Town"))
                AddAttribute(xmldocTarget, "/Episode@pAddress3", xmlnodeSource.getAttribute("District"))
                AddAttribute(xmldocTarget, "/Episode@pAddress4", "")
                AddAttribute(xmldocTarget, "/Episode@pPostcode", Left(xmlnodeSource.getAttribute("PostCode"), 8))
            End IF
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Ward")
                'Do mapping of ward codes and consultant codes
            If Not xmlnodeSource Is Nothing Then 
                If Not IsDBNull(xmlnodeSource.getAttribute("Alias")) Then 
                    AddAttribute(xmldocTarget, "/Episode@pWard", xmlnodeSource.getAttribute("Alias"))
                Else
                    AddAttribute(xmldocTarget, "/Episode@pWard", "")
                End IF
            Else
                AddAttribute(xmldocTarget, "/Episode@pWard", "")
            End IF
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/ResponsibleEpisodeEntity")
            If Not xmlnodeSource Is Nothing Then 
                If Not IsDBNull(xmlnodeSource.getAttribute("Alias")) Then 
                    AddAttribute(xmldocTarget, "/Episode@pCons", xmlnodeSource.getAttribute("Alias"))
                Else
                    AddAttribute(xmldocTarget, "/Episode@pCons", "")
                End IF
            Else
                AddAttribute(xmldocTarget, "/Episode@pCons", "")
            End IF
            '------------------------------------------------------------------------------------------
            'Not bothered for v8
            AddAttribute(xmldocTarget, "/Episode@pGP", "")
            AddAttribute(xmldocTarget, "/Episode@pSpeciality", "")
            AddAttribute(xmldocTarget, "/Episode@pPrescriberID", "")
            '------------------------------------------------------------------------------------------
            'Get Height and weight
            'Original XPath query = Height observation
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Observation[@Description='Measured patient height']")
            If Not xmlnodeSource Is Nothing Then 
                AddAttribute(xmldocTarget, "/Episode@pHeightcm", xmlnodeSource.getAttribute("Value"))
            Else
                AddAttribute(xmldocTarget, "/Episode@pHeightcm", "")
            End IF
            'Original XPath query = Weight observation
            xmlnodeSource = xmldocSource.selectSingleNode("ROOT/Observation[@Description='Weighed patient']")
            If Not xmlnodeSource Is Nothing Then 
                AddAttribute(xmldocTarget, "/Episode@pWeightkg", xmlnodeSource.getAttribute("Value"))
            Else
                AddAttribute(xmldocTarget, "/Episode@pWeightkg", "")
            End IF
            xmlnodeSource = Nothing
                'Construct Allergy / notes string. If the function returns false then this indicates
                'that the notes exceeded the limit set
            If Buildv8AllergyStrings(xmldocTarget) Then 
                '10Nov03 ATW Moved block outside conditional
            Else
                'Write an error out
                Response.Write("<BR>")
                Response.Write("<H2 style=" & """color:red""" & ">Dispensary Error: Notes size exceed set limit of 16k</H2>")
                Response.Write("<BR>")
                Response.End()
            'Halt processing
            End IF
        End IF
        '10Nov03 ATW Moved block here ; now data gets wrriten even when a patient is not involved.
        'strPatient_XML = xmldocTarget.xml      MSXML2 Removal
        strPatient_XML = xmldocTarget.InnerXml
        encodehex(strPatient_XML)
        Response.Write(strPatient_XML)
        xmldocTarget = Nothing
    End IF
%>

</Data>
</xml>



<object id="DispOCX" classid="clsid:2B759A54-024D-41B0-B05F-7B761593CB42"
						CODEBASE="../../cab/ASCSecureDispensing.CAB#version=2,1,0,2"
<%
    If blnCanLaunch And strAutoLaunch = "Yes" Then 
        Response.Write("onreadystatechange=""ShellPharmacy();"" ")
    End IF
%>

						 VIEWASTEXT>
	<param NAME="_ExtentX" VALUE="2011">
	<param NAME="_ExtentY" VALUE="873">
</object>
<button style="display:none" onclick="Popmessage(document.body.innerHTML);">HTML</button>
</body>
</html>