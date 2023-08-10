<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim referringUrl As String
    Dim mode As String

    sessionId = CIntX(Request.QueryString("SessionID"))
    episodeId = StateGet(sessionId, "Episode")
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
    End If
    
    entityId = StateGet(sessionId, "Entity")
    referringUrl = Request.QueryString(DA_REFERING_URL)
    
    mode = Request.QueryString("Mode")
    
    If mode = "Save" Then
        Dim phValue = CDblX(Request.QueryString("value"))
        ' save a note for recording the ph of the aspirate
        Dim observationNote = New OCSRTL10.OrderCommsItem()
        observationNote.RecordEnteralFeedPhValue(sessionId, phValue)
        
		Response.Redirect("../DrugAdministration/" & referringUrl & "?SessionID=" & sessionId.ToString() & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&dssresult=" & Request.QueryString("dssresult") & "&OverrideAdmin=" & IIf(SessionAttribute(sessionId, "OverrideAdmin") = True, "1", "0").ToString())
    End If
%>

<html>
<head>
<title>Drug Administration - Record Enteral Feed pH Value</title>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

<script language="javascript" type="text/javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script language="javascript" type="text/javascript">
    function SetButtonState()
    {
        setScrollButtonState();
        var cmdSave = document.getElementById("cmdSave");
        cmdSave.disabled = true;
        cmdSave.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';
    }

    function Navigate(strPage)
    {
		var strUrl = strPage + '?SessionID=<%= sessionId %>'
			+ '&dssresult=<%= Request.QueryString("dssresult") %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
		void TouchNavigate(strUrl);
    }

    function Cancel()
    {
		var strUrl = '<%= referringUrl %>?SessionID=<%= sessionId %>'
			+ '&dssresult=<%= Request.QueryString("dssresult") %>'
			+ '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			+ '&OverrideAdmin=<%=IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0")%>';
		void TouchNavigate(strUrl);
    }

    function Save()
    {
        if (!isNaN(document.getElementById("phValue").innerText))
        {
            var pHvalue = document.getElementById("phValue").innerText;
            var strUrl = 'AdministrationEnteralPHValue.aspx?SessionID=<%= sessionId %>&Mode=Save&Value=' + pHvalue + '&referer=<%= referringUrl %>';
            void TouchNavigate(strUrl);
        }
    }

    function EnterPHValue()
    {
        document.frames['fraKeyboard'].ShowNumpad('Enter the pH of the NG Aspirate', 4, false);
    }

    function Confirmed()
    {
        return true;
    }

    function Administer()
    {
        return true;
    }

    function ScreenKeyboard_EnterText(value)
    {
        if (value != '')
        {
            if (Number(value) < 0 || Number(value) > 14)
            {
                void document.frames['fraConfirm'].Show('Please enter a pH between 0 and 14', 'cancel');
            }
            else
            {
                document.getElementById("phValue").innerText = value;
                document.getElementById("phValue").style.fontSize = "32px";
                document.getElementById("phValue").setAttribute('phvalue', value);
                var cmdSave = document.getElementById("cmdSave");
                cmdSave.disabled = false;
                cmdSave.style.filter = '';
            }
        }
    }

    function scrollData(direction)
    {
        var objDiv = document.getElementById("dataDiv");
        var scrollPos = Number(objDiv.scrollTop);
        var rowHeight = 23;

        if (direction == "up")
        {
            scrollPos = scrollPos - rowHeight;
            if (scrollPos < 0)
            {
                scrollPos = 0;
            }
        }
        else if (direction == "down")
        {
            var maxScroll = objDiv.scrollHeight - objDiv.clientHeight;
            if (maxScroll < 0)
            {
                maxScroll = 0;
            }

            scrollPos = scrollPos + rowHeight;
            if (scrollPos > maxScroll)
            {
                scrollPos = maxScroll;
            }
        }

        objDiv.scrollTop = scrollPos;
        void setScrollButtonState();
    }

    function setScrollButtonState()
    {
        var scrollup = document.getElementById("ascScrollup");
        var scrolldown = document.getElementById("ascScrolldown");

        var objDiv = document.getElementById("dataDiv");
        var maxScroll = objDiv.scrollHeight - objDiv.clientHeight;
        var scrollPos = Number(objDiv.scrollTop);

        if (maxScroll < 0)
        {
            maxScroll = 0;
        }

        if (scrollPos == 0 && maxScroll == 0)
        {
            scrollup.disabled = true;
            scrolldown.disabled = true;
            scrollup.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';
            scrolldown.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';
        }
        else if (scrollPos == 0)
        {
            scrollup.disabled = true;
            scrolldown.disabled = false;
            scrollup.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';
            scrolldown.style.filter = '';
        }
        else if (scrollPos == maxScroll)
        {
            scrollup.disabled = false;
            scrolldown.disabled = true;
            scrollup.style.filter = '';
            scrolldown.style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';
        }
        else
        {
            scrollup.disabled = false;
            scrolldown.disabled = false;
            scrollup.style.filter = '';
            scrolldown.style.filter = '';
        }
    }
    
</script>

</head>
<body class="Touchscreen AdminDetails" onload=" document.body.style.cursor = 'default';SetButtonState();">
    <table width="100%" cellpadding="0" cellspacing="0">        
    <%
        'Selected Patient details
        PatientBannerByID(sessionId, entityId, episodeId)
    %>
    <tr>
        <td colspan="2">
            <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
        	    <tr>
		            <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">					
                    <%
                    'Script the "back to list" button.
                    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back", "Navigate('" & referringUrl & "')", True)
                    %>
        		    </td>		
		            <td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" align="center">
                    <%
                    ScriptBanner_AdminRequestCurrent(sessionId, False, entityId)
                    %>
        		    </td>
        	    </tr>
            </table>
	    </td>
    </tr>
    </table>    
    <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td colspan="2" class="Prompt" style="text-align:left;">
		        <%
	                DrugAdminEpisodeBannerByID(sessionId, episodeId)
                %>
		    </td>
	    </tr>
    </table>
    <br/>
    <br />
    <table style="border:0px;padding:0px;border-spacing:<%= BUTTON_SPACING %>px;text-align:center;width:100%;">
        <tr>
            <td>
                <table>
                    <tr>
                        <td colspan="2">
                            <table class="Touchbutton" style="height:220px;width:300px;" <%= TouchscreenShared.EVENTHANDLER_BUTTON %> onclick="EnterPHValue();">
                                <tr>
                                    <td class="Caption" style="text-align: center;font-size:16px;">Enter the pH of the NG Aspirate</td>
                                </tr>
                                <tr>
                                    <td id="phValue" class="Value">No Value Recorded</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td>
                <table>
                    <tr>
                        <td>
                            <table style="width:100%;background-color: #CCCCCC;border-spacing:2px;">
                                <tr style="vertical-align: middle;background-color: #EEEEEE;line-height: 18px;">
                                    <td style="width:100px;" class="Caption">Date</td>
                                    <td style="width:90px;" class="Caption">Time</td>
                                    <td style="width:90px;" class="Caption">pH Value</td>
                                </tr>
                            </table>
                            
                            <div id="dataDiv" class="Touchbutton" style="overflow:hidden;height:200px;width:300px;font-weight:normal;text-align:center">
                                <table id="dataTable" style="width:100%;">
                                    <%
                                        Dim readEnteralFeedObservations As New OCSRTL10.OrderCommsItemRead()
                                        Dim enteralFeedObservations As String
                                    
                                        enteralFeedObservations = readEnteralFeedObservations.GetAllEnteralFeedPhObservations(sessionId, episodeId)
                                        If enteralFeedObservations <> String.Empty Then
                                            Dim dataDom As New XmlDocument
                                            dataDom.TryLoadXml("<root>" & enteralFeedObservations & "</root>")
                                            Dim dataNodes As XmlNodeList
                                            
                                            dataNodes = dataDom.SelectNodes("root/Observation")
                                            If dataNodes.Count > 0 Then
                                                For Each dataNode As XmlNode In dataNodes
                                                    %>
                                                    <tr style="vertical-align: top;background-color: #DDDDDD;height:18px;">
                                                    <td style="width:100px;font-size:16px;font-weight:bold;vertical-align: middle;"><%=dataNode.Attributes("Date").Value%></td>
                                                    <td style="width:100px;font-size:16px;font-weight:bold;vertical-align: middle;"><%=dataNode.Attributes("Time").Value%></td>
                                                    <td style="width:100px;font-size:16px;font-weight:bold;vertical-align: middle;"><%=CDblX(dataNode.Attributes("Value").Value)%></td>
                                                    </tr>
                                                    <%
                                                Next
                                            End If
                                        End If
                                    %>
                                </table>
                            </div>
                        </td>
                        <td><% TouchscreenShared.ScrollButtonUp("scrollData('up')", True) %><br/><br/><% TouchscreenShared.ScrollButtonDown("scrollData('down')", True)%></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td><br/><br/></td>
        </tr>
        <tr>
            <td style="text-align: center;" colspan="2">
                <table>
                    <tr>
                        <td><% TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "Cancel()", True)%></td>
                        <td><% TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Save", "Save()", True) %></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <iframe id="fraKeyboard" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
    <iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>
