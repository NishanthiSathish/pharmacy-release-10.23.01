<%@ Page language="vb" %>
<% 
    Response.Buffer = true
    Response.Expires = -1
    Response.CacheControl = "No-cache"
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
 %>
<html>
<head>

<%
'--------------------------------------------------------------------------------
'
'LookupSearch.aspx
'
'Querystring Params:
'SessionID	(mandatory)					- Standard session token
'Mode			(mandatory)
'"typed"		- Shows a type selector and lookup selector controls.
'"lookup"		- Shows a set of search controls for finding a particular row
'ColumnID		(mandatory)					- The ID of the foreign column which points at our lookup table.
'For example, this would be a "UnitID" column
'
'
'Returns:
'String.  If a type id / value is selected, the string contains
'"TypeID|TypeDescription|ValueID|ValueDescription".
'If the user cancells, an empty string is returned.
'
'Modification History:
'02Apr04 AE  Written
'
'--------------------------------------------------------------------------------
%>



<title>
<%
    Select Case LCase(Request.QueryString("Mode"))
        Case "typed"
            Response.Write("Lookup Selection")
        Case "lookup"
            Response.Write("Lookup Search")
    End Select
%>

</title>

<script language="javascript">

	function CloseWindow(blnCancel)
	{

		var typeID = new Number(0);
		var typeDesc = new String();
		var valueID = new Number(0);
		var valueDesc = new String();
		var contentsDoc = new Object();
		var strReturn = new String();

		if (blnCancel)
		{
			strReturn = '';
		}
		else
		{
			//Return the selected TypeID and value from the contents page
			contentsDoc = document.frames['fraContents'].document.body
			if (contentsDoc.all['lstTypes'] != undefined)
			{
				if (contentsDoc.all['lstTypes'].selectedIndex > -1)
				{
					typeID = contentsDoc.all['lstTypes'].options[contentsDoc.all['lstTypes'].selectedIndex].getAttribute('dbid');
					typeDesc = contentsDoc.all['lstTypes'].options[contentsDoc.all['lstTypes'].selectedIndex].innerText;
				}
			}
			// F0048937 ST 24Mar09  Moved the following inside the check if..endif block so that we only execute it if the object is defined
			// F0049838 PR 02 04 09  Moved the following inside its own check if..endif block so that we only execute it if the object is defined
			if (contentsDoc.all['lstValues'] != undefined)
			{
				if (contentsDoc.all['lstValues'].selectedIndex > -1)
				{
					valueID = contentsDoc.all['lstValues'].options[contentsDoc.all['lstValues'].selectedIndex].getAttribute('dbid');
					valueDesc = contentsDoc.all['lstValues'].options[contentsDoc.all['lstValues'].selectedIndex].innerText;
				}
			}

			//Build a return string
			strReturn = typeID + "|" + typeDesc + "|" + valueID + "|" + valueDesc
		}

		window.returnValue = strReturn;
		void window.close();
	}

</script>
	<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "LookupSearch.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>


<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
</head>
<body scroll="no">

<table style="height:100%;width:100%" cellpadding="0" cellspacing="0">
	<tr>
		<td style="height:100%">
			<iframe id="fraContents"
					  frameborder="0"
					  style="height:100%;width:100%" 
					  application="yes"
					  src="LookupSearchContents.aspx?<%= Request.QueryString %>"
					  >
			</iframe>
		</td>
	</tr>
	
	<tr>
		<td>
		
			<table align="right">
				<tr>
					<td>
						<button id="cmdOK"
								  onclick="CloseWindow(false)"
								  acceskey="o"
								  >
								  <u>O</u>K
						</button>
					</td>
					<td>
						<button id="cmdCancel"
								  onclick="CloseWindow(true)"
								  acceskey="c"
								  >
								  <u>C</u>ancel
						</button>
					</td>
				</tr>
			</table>
		
		</td>
	</tr>
</table>
	<iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
