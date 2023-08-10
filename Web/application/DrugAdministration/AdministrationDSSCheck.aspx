<%@ Page language="vb" %>

<%
    Dim prescriptionDetailUrl As String = Request.RawUrl().Replace("AdministrationDSSCheck.aspx", "AdministrationPrescriptionDetail.aspx")
    Dim dssResultsUrl As String = Request.RawUrl().Replace("AdministrationDSSCheck.aspx", "AdministrationDSSResults.aspx")
%>

<html>
<head>
<title>Drug Administration DSS Checking</title>
<script language="javascript" type="text/javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script language="javascript" type="text/javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script language="javascript" type="text/javascript">

//----------------------------------------------------------------------------------------------
    function DssResultsButtonHandler(override)
    {
        if (override)
        {
            var dssData = document.frames["DSSResults"].GetDssResultsXml();
            if (dssData)
            {
                var dssXml = dssData.XMLDocument.selectSingleNode('//ascribe_dss_results');
                var dsslogresults = document.frames["DSSResults"].GetDssLogResultsXml();
                if (dssXml.getAttribute('reasonentryallowed') == 'true' && UsingV11(dssData.getAttribute('sid')))
                {
                    if (dsslogresults)
                    {
                        if (DssResults_ReasonEntry(dsslogresults.selectSingleNode('//LogEntry'), dssData))
                        {
                            void ShowPrescripton('fail_override');
                        }
                    }
                }
                else
                {
                    if (dsslogresults)
                    {
                        DssResults_SaveOverride(dsslogresults.selectSingleNode('//LogEntry'), dssData);
                    }
                    
                    void ShowPrescripton('fail_override');
                }
            }
        }
        else
        {
            void ShowPrescripton('fail_stop');
        }
    }

	function ShowPrescripton(dssResult)
	{
		var strUrl = '<%= prescriptionDetailUrl %>';
		strUrl += '&dssresult=' + dssResult;
		if (dssResult == 'fail_override')
		{
			var dssLogResults = document.frames['DSSResults'].document.all['dsslogresults'].xml;
			strUrl += '&dsslogresults=' + dssLogResults;
		}
		TouchNavigate(strUrl);
	}
	//----------------------------------------------------------------------------------------------

	function DssResults_ReasonEntry(dssXml, dssData)
	{
	    var v11Location = V11Location(dssData.getAttribute('sid'));
	    var ret = '';

	    if (v11Location != null && v11Location != '')
	    {
	        var strUrl = v11Location + '/DecisionSupport/Views/OverrideDssWarnings.aspx'
			  + '?SessionID=' + dssData.getAttribute('sid')
			  + '&logID=' + dssXml.getAttribute('LogID')
			  + '&Date=' + new Date().getTime().toString();

	        ret = window.showModalDialog(strUrl, '', 'dialogHeight:600px;dialogWidth:950px;resizable:no;maximize:yes;unadorned:no;status:no;help:no;');
            if (ret == 'logoutFromActivityTimeout') {
                ret = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }
}

	    return ret == 'ok';
	}
	//----------------------------------------------------------------------------------------------

	function DssResults_SaveOverride(dssXml, dssData)
	{
	    var sessionId = dssData.getAttribute('sid');
	    var logId = dssXml.getAttribute('LogID');
	    var strUrl = '../DSSWarningsLogViewer/OverrideWarningHelper.aspx/SaveWarningOverride';
	    var sendData = "{'sessionId': '" + sessionId + "', 'logId': '" + logId + "', 'resultsXml': '" + dssData.XMLDocument.xml + "' }";
	    PostServerMessage(strUrl, sendData);
	}

	//===========================================================================================
	function UsingV11(sessionId) {
	    var objHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
	    var strUrl = '../sharedscripts/SettingRead.aspx'
			  + '?SessionID=' + sessionId
			  + '&System=ICW'
			  + '&Section=OrderEntry'
			  + '&Key=UseV11';
	    var blnUseV11 = false;

	    objHttpRequest.open("POST", strUrl, false); //false = syncronous                              
	    objHttpRequest.send("");
	    if (objHttpRequest.responseText.toLowerCase() == "true") {
	        blnUseV11 = true;
	    }

	    return blnUseV11;
	}

	function V11Location(sessionId) {
	    var objHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
	    var strUrl = '../sharedscripts/AppSettingRead.aspx'
			  + '?SessionID=' + sessionId
			  + '&Setting=ICW_V11Location';
	    var v11Location;

	    objHttpRequest.open("POST", strUrl, false); //false = syncronous                              
	    objHttpRequest.send("");
	    v11Location = objHttpRequest.responseText;

	    return v11Location;
	}


	function PostServerMessage(url, data)
	{
	    var result;
	    $.ajax({
	        type: "POST",
	        url: url,
	        data: data,
	        contentType: "application/json; charset=utf-8",
	        dataType: "json",
	        async: false,
	        success: function(msg)
	        {
	            result = msg;
	        }
	    });
	    return result;
	}

	function ClearStatusMessage() 
	{
        document.getElementById("divStatus").style.display = "none";
    }

    window.onload = function () { document.body.style.cursor = 'default'; }
</script>
</head>

<body>
<div id="divStatus" align="center" style="position:absolute; top:50%; left:50%; margin-top: -50px; margin-left: -120px; border: black 1px double; background-color:#D6E3FF; padding: 15px; font-family: arial; font-size:16px;">
    <img src="../../images/Developer/spin_wait.gif" alt="In progress"/>
    <br/>
    Please Wait...
</div>
   
<iframe id="DSSResults" height="100%" width="100%" src="<%= dssResultsUrl %>" onload="ClearStatusMessage();" application="yes"></iframe>
</body>
<script language="javascript" type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
</html>
