<%@ Page Language="vb" %>

<%@ OutputCache Location="None" VaryByParam="None" %>
<%@ Import Namespace="Ascribe.Common" %>
<%  
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim LegalStatusVID As String = Request.QueryString("LegalStatusVID")
    Dim OrderTemplateGUID As String = Request.QueryString("OrderTemplateGUID")
    Dim CanEdit As Boolean = False
    
    Dim temp As String = Request.QueryString("CanEdit")
    If Not temp Is Nothing Then
        temp = temp.Replace("1", "True")
        temp = temp.Replace("0", "False")
        CanEdit = Boolean.Parse(temp)
    End If
%>
<html>
<head>
    <title>Order Comms Data Entry</title>
    <link rel="stylesheet" type="text/css" href="../../style/application.css" />
    <script type="text/javascript" src="../ICW/script/jquery-1.4.1.js"></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"></script>
    <script type="text/javascript" src="../sharedscripts/OrderEntryIntegrationLauncher.js"></script>
    <script language="javascript" type="text/javascript">
            
            var readTimer;
            var lsVid;
            var lsGuid;
            var useDialogArgs;
   
            function ErrorAlert(message) {
                alert(message);
                window.close();
            }

            function Initialise() {
                window.dialogWidth = '300px';
                window.dialogHeight = '100px';

                useDialogArgs = false;

                if (typeof dialogArguments != 'undefined') {
                    if (typeof dialogArguments.LoadOrderEntry_Create != 'undefined') {
                        useDialogArgs = true;
                    }    
                }

                try {
                    var vid = '<%=LegalStatusVID%>';
                    vid = vid.replace(new RegExp("'", "g"), "\"");
                    lsVid = $.parseJSON(vid);
                    lsGuid = lsVid.Identifier;

                } catch (ex) {
                    ErrorAlert("LegalStatusVID is missing or contains invalid JSON");
                    return;
                }

                if (lsGuid == undefined) {
                    ErrorAlert("Identifier is not defined in the JSON.");
                    return;
                }

                ReadSmartForm();
            }

            function ReadSmartForm() {
                clearTimeout(readTimer);

                var strUrl = '../OrderEntry/MHLegalStatusHelper.aspx'
                    + '?SessionID=<%=SessionID %>'
                    + '&Mode=GET'
                    + '&LegalStatusGUID=' + lsGuid.toString();

                var objHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
        
                objHttpRequest.open("POST", strUrl, false); //false = syncronous                              
                objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                objHttpRequest.send('');

                var orders = objHttpRequest.responseText;

                var xml = "";

                switch(orders) {
                    case "No legal status":
                        ErrorAlert("No legal status record found!");
                        break;

                    case "No form data":
                        try {
                            if ("<%=CanEdit%>" == "True") {
                                if (useDialogArgs == true) {
                                    xml = dialogArguments.LoadOrderEntry_Create(<%=SessionID %>, "<%=OrderTemplateGUID%>");
                                } else {
                                    //CA - 14/11/2014 -
                                    //      Added true so that the smart form loaded this way uses Order Entry Temp
                                    xml = LoadOrderEntry_Create(<%=SessionID %>, "<%=OrderTemplateGUID%>", true);
                                }
                            } else {
                                ErrorAlert("You do not have permission to create a new conditional discharge form.");
                            }
                        } catch (ex) {
                            ErrorAlert(ex.Message);
                        }
                        break;

                    default:
                        try {
                            if ("<%=CanEdit%>" == "True") {
                                if (useDialogArgs == true) {
                                    xml = dialogArguments.LoadOrderEntry_Amend(<%=SessionID %>, orders);
                                } else {
                                    xml = LoadOrderEntry_Amend(<%=SessionID %>, orders);
                                }
                            } else {
                                if (useDialogArgs == true) {
                                    xml = dialogArguments.LoadOrderEntry_View(<%=SessionID %>, orders);
                                } else {
                                    xml = LoadOrderEntry_View(<%=SessionID %>, orders);
                                }
                            }
                        } catch (ex) {
                            ErrorAlert(ex.Message);
                        }
                        break;
                }

                if (xml != "") {
                    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
                    xmlDoc.async=false;
                    xmlDoc.loadXML(xml);

                    try {
                        var root = xmlDoc.documentElement;
                        if (root != undefined) {
                            if (root.nodeName == "saveresults") {
                                for (var i = 0; i < root.childNodes.length; i++) {
                                    var element = root.childNodes[i];
                                    if (element.nodeName == "item") {
                                        for (var j = 0; j < element.childNodes.length; j++) {
                                            var itemElement = element.childNodes[i];
                                            if (itemElement.nodeName == "saveok") {
                                                if (itemElement.attributes[0] != undefined) {
                                                    var cdid = itemElement.attributes[0].nodeTypedValue;
                                                    LinkLegalStatusToConditionalDischarge(cdid);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch (ex) {
                        ErrorAlert(ex.message);
                    }
                }

                window.close();
            }

            function LinkLegalStatusToConditionalDischarge(cdid) {
                var strUrl = '../OrderEntry/MHLegalStatusHelper.aspx'
                    + '?SessionID=<%=SessionID %>'
                    + '&Mode=SET'
                    + '&LegalStatusGUID=' + lsGuid.toString()
                    + '&FormID=' + cdid.toString();

                var objHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
        
                objHttpRequest.open("POST", strUrl, false); //false = syncronous                              
                objHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                objHttpRequest.send('');
            }
    </script>
</head>
<body onload="Initialise()">
    <div style='width: 300px; height: 100px; top: 0px; left: 0px; position: absolute;
        overflow: auto; display: inline;'>
        <div style='width: 50px; height: 50px; top: 20%; left: 40%; position: absolute; overflow: auto;
            display: inline;'>
            <img src='../../images/Developer/ajax-loader.gif'>
        </div>
        <div style='width: 250px; top: 35%; left: 10%; position: absolute; font-family: arial;
            font-size: 12px; color: #000000;'>
            Please wait, retreiving conditional discharge records...
        </div>
    </div>
</body>
</html>
