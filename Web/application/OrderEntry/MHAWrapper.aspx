<%@ Page language="vb" %>
<%@ OutputCache Location="None" VaryByParam="None" %>
<%@ Import Namespace="Ascribe.Common" %>
<html>
<script type="text/javascript" src="../sharedscripts/icw.js"></script>
<script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
<script language="javascript" src="../sharedscripts/ocs/OCSShared.js"></script>

<head>
<title>Order Comms Data Entry</title>

<%  
    Dim SessionID As Integer = Generic.CIntX(Request.QueryString("SessionID"))
    Dim VID As String = Request.QueryString("VID")
%>


	<link rel="stylesheet" type="text/css" href="../../style/application.css" />

<script language="javascript" type ="text/javascript">

//------------------------------------------------------------------------------------------

var readConsentTimer;

function Initialise() {
    window.dialogWidth = '300px';
    window.dialogHeight = '100px';
    clearTimeout(readConsentTimer);
    readConsentTimer = setTimeout("ReadConsent()", 10000);    
}

function ReadConsent() {
    var vid = '<%=VID %>';
    vid = vid.replace(new RegExp("'", "g"), "\"");
    var consentVid = JSON.parse(vid);
    clearTimeout(readConsentTimer);
    var strURL = '../OrderEntry/MHAConsentReader.aspx'
        + '?SessionID=<%=SessionID %>'
            + '&GUID=' + consentVid.Identifier;
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send('');
    var orders = objHTTPRequest.responseText;
    if (orders == "0") {
        readConsentTimer = setTimeout("ReadConsent()", 1000);                
    }
    else {
        var DOM = new ActiveXObject("MSXML2.DOMDocument");
        DOM.loadXML(orders);
        var errors = DOM.selectNodes('//BrokenRules');
        if (errors.length > 0) {
            var errorMessage = errors[0].selectSingleNode('Rule').getAttribute('Text');
            Popmessage(errorMessage);
            window.returnValue = '';
            window.close();
        }
        else {
            window.returnValue = ShowMHAOrderEntry();
            window.close();
        }
    }
}

function ShowMHAOrderEntry() {
    var strURL = '../OrderEntry/OrderEntryModal.aspx'
	  	    + '?SessionID=<%=SessionID %>'
	  	    + '&Action=load'
			 + '&DispensaryMode=0' + 
			 + '&DefaultCreationType=';

    //26Sep2009 JMei F0040487 Passing the caller self to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;

    var retValue = window.showModalDialog(strURL, objArgs, OrderEntryFeaturesV11());
    if (retValue == 'logoutFromActivityTimeout') {
        retValue = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    return retValue;
}

</script>

</head>
<body onload="Initialise();">
						
    <div style='width: 300px; height: 100px; top: 0px; left: 0px; position: absolute;
        overflow: auto; display: inline;'>
        <div style='width: 50px; height: 50px; top: 20%; left: 40%; position: absolute; overflow: auto;
            display: inline;'>
            <img src='../../images/Developer/ajax-loader.gif'>
        </div>
        <div style='width: 250px; top: 35%; left: 10%; position: absolute; font-family: arial;
            font-size: 12px; color: #000000;'>
            Please wait, retreiving consent records...
        </div>
    </div>
</body>
</html>
