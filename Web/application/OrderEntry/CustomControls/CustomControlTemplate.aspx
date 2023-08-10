<%@ Page language="vb" %>
<html>
<head>

<%
    Dim blnReadOnly As String  
%>
<%
    Dim SessionID As Integer
%>
<%
    'Validate the session
    'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
    'ValidateSession(SessionID)
    'Check if we are in read-only mode
    blnReadOnly = Request.QueryString("Display")
    If blnReadOnly = CStr(true) Then 
        Response.Write("<script language=javascript defer>void SetReadOnly();</script>")
    End IF
%>

<script language="javascript" src="scripts/OrderFormResizing.js" ></script>
<script language="javascript" src="../sharedscripts/InputMasking.js" ></script>
<script language="javascript" src="../sharedscripts/icwFunctions.js" ></script>

<script language="javascript">

//===========================================================================
//							Public Methods
//===========================================================================

function Resize() {

//Standard resize event
//This is fired from the hosting page when a resize event
//occurrs.
//This function is OPTIONAL

}

//===========================================================================

function Populate(strData_XML) {

//Standard Populate method, called from the hosting form
//This function is MANDATORY

}

//===========================================================================

function GetData() {

//Standard method to read data from this control.
//Called from the hosting form to retrieve data
//This function is MANDATORY

//MUST Return data in the following format:
//
//	"sToken=<sValue>"
//
//	sToken:  	String reserved word; one of {value|xml}
//	<sValue>:	String specifying the data.  

}


//===========================================================================

function FilledIn() {

//Return true if all of the mandatory fields on this 
//page are filled in.
//This function is MANDATORY

	return false;


}

//============================================================================
</script>
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
</head>

<body id="formBody">





</body>
</html>
