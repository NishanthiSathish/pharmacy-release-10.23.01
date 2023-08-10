<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<html>

<head>
<title>Stop Item(s)</title>
<script langauage="javascript">
//------------------------------------------------------------------------------------------
//
//								Wrapper to show OrderEntry.aspx in a modal dialog
//
//	Useage:
//				Now use the function OrderEntry() in OCSShared.js to call OrderEntry
//
//
//	Returns:
//			   String:  
//						a save results XML string if items were saved:
//      			 	<saveresults>
//           			<item template="true|false" id="xxx" tableid="xxx">
//             			<save success="true|false" result="*" />
//	         			</item>
//		           			'
//    				</saveresults>
//
//						"cancel" if the user cancels; 
//						"refresh" if the user cancelled but the calling page should refresh anyway

//------------------------------------------------------------------------------------------

//Pass the dialogArguments, which contains XML specifying which items
//to edit, to the appropriate method of the OrderEntry page.
//This is held in a frame since it is necessary to do submits and navigates
//for server access, which in modal dialogs has the unfortunate by product
//of opening new windows.

var m_blnLoaded = false;
var m_blnPrompt = true;
var m_blnForceRefresh = false;												//If true,the string 'refresh' is returned to the caller, even if cancel/close is pressed

//------------------------------------------------------------------------------------------

function CloseMe(blnCancel, blnSuppressPrompt, v11Call) {

    //Close this window.
    //
    //		blnCancel:				True if the user is cancelling, false otherwise
    //		blnSuppressPrompt:	If True, the user is not prompted "really cancel?".
    //									This is used in case they have already been prompted once.
    if (!v11Call) {

        if (!blnCancel) {
            //Not cancelling.  Return the SaveResults from the saver page on order entry, if any
            var objResults = document.frames['fraOnly'].document.frames['fraSave'].document.all['saveResultsXML'];
            if (objResults !== undefined) {
                window.returnValue = objResults.XMLDocument.xml;
            }
            else if (window.returnValue == undefined) {
                window.returnValue = '';
            }

            m_blnPrompt = false;
        }
        else {
            window.returnValue = 'cancel';
        }

        if (m_blnForceRefresh) {																														//13Sep03 AE
            if ((window.returnValue == 'cancel') || (window.returnValue = '')) {
                //Override cancel/close with 'refresh' to force the caller to refesh
                window.returnValue = 'refresh';
            }
        }

        if (blnSuppressPrompt) { m_blnPrompt = false; }
    }
    else {
        if (!blnCancel) {
            window.returnValue = 'refresh'
        }
        else {
            window.returnValue = 'cancel';
        }
    }

    void window.close();
}

//-------------------------------------------------------------------------------------------

function QueryUnload() {

//Ask if they REALLY want to leave.  The implementation of this in IE is
//not the best, but I can't find a different way of picking up clicks on
//the window 'x' button
	
	if (document.frames['fraOnly'].document.all['cmdOK'] != null) {
		if (m_blnPrompt) {
			event.returnValue='If you press OK, all of your edits will be lost!'
		}
	}
}

//---------------------------------------------------------------------------------------------

function SetForceRefresh(blnForceRefresh) {
	m_blnForceRefresh = blnForceRefresh;
}

</script>

</head>

<%  Dim strUrl As String
    Dim lngSessionID As Integer
    
    lngSessionID = CInt(Request.QueryString("SessionID"))
    
    If OrderEntry.UseVersion11(lngSessionID) = True Then
        strUrl = System.Configuration.ConfigurationManager.AppSettings("ICW_V11Location") & "/OrderComms/Views/OrderEntry/OrderEntry.aspx?"
    Else
        strUrl = "ICW_OrderEntry.aspx?"
    End If
    %>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PharmacySupplierWardSearch.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<frameset id=fstMain frameborder=0 cols="100%" onbeforeunload="void QueryUnload();" >
	<frame id="fraOnly" 
			 src="<%= strUrl %><%= Request.QueryString %>&Modal=1"
			 application="yes"
			 >
         <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>


</html>
