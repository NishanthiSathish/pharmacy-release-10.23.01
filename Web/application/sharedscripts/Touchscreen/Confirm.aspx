<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../ASPHeader.aspx"-->
<html>

<head>
<script language="javascript" src='Touchscreenshared.js'></script>
<script language="javascript">
//-------------------------------------------------------------------------------------------
//									
//									Touch-screen Confirm Dialog
//
//	Useage:
//		Host in an iframe on the page where you wish to use the keyboard, using the following HTML:
//	<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
//
//		To show the dialog, call it's Show() method:
//			document.frames['fraConfirm'].Show(strPromptHTML, strButtons);
//
//			strPromptHTML - HTML or text to be shown as the prompt.
//			strButtons - One of:
//								"ok"												- Shows an ok button only
//								"cancel"											- Shows a cancel button only
//								"okcancel"										- shows an OK and cancel buttons
//								"yesno"											- Shows a yes and no button
//
//		When the user has pressed a button, the page will hide itself, and call
//		an event handler on the hosting page as follows:
//			function Confirmed(strReturn)
//
//		where strReturn is one of "yes", "no", "ok", "cancel"
//
//	Modification History:
//	02Jun05 AE  Written
//
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//									Public Methods
//-------------------------------------------------------------------------------------------

<%
    If LCase(Request.QueryString("Mode")) = "active" Then 
%>

	window.parent.document.all['fraConfirm'].style.display = 'block';
<%
    End IF
%>


function Show(strPromptHTML, strButtons) {

//Rescript the page with the info passed in
var blnButton1 = false;
var blnButton2 = false;
var strButton1 = '';
var strButton2 = '';

	var strURL = document.URL + '?';													//? added to ensure we have one for the next line, since the initial state has no querystring.  Won't interfere on subsequent calls.
	strURL = strURL.substring(0, strURL.indexOf('?'));
										  
	switch (strButtons.toLowerCase()){
		case 'ok':
			blnButton1 = true;
			strButton1 = 'OK';
			break;
		
		case 'cancel':
			blnButton1 = true;
			strButton1 = 'Cancel';
			break;
		
		case 'yesno':
			blnButton1 = true;
			strButton1 = 'No';
			blnButton2 = true;
			strButton2 = 'Yes';
			break;
		
		case 'okcancel':
			blnButton1 = true;
			strButton1 = 'Cancel';
			blnButton2 = true;
			strButton2 = 'OK';
			break;
		
		default:
			alert('Unknown value passed to Show method! strButtons must be one of {ok|cancel|okcancel|yesno} ');
			break;
	}
		
	if (blnButton1 || blnButton2){								  
		window.navigate(strURL + '?E1=' + blnButton1
									  + '&E2=' + blnButton2
									  + '&B1=' + strButton1
									  + '&B2=' + strButton2
									  + '&Prompt=' + strPromptHTML
									  + '&Mode=active'
							);
	}	
}

//-------------------------------------------------------------------------------------------
//									Public Events
//-------------------------------------------------------------------------------------------
function Confirm(strChosen){

	//Hide me
	window.parent.document.all['fraConfirm'].style.display = 'none';

	if (window.parent.Confirmed != undefined){
	//Call the event handler on the hosting page
		window.parent.Confirmed(strChosen.toLowerCase());
        
	}
	else {
	//Show a warning if the event handler isn't there, to help us poor developers!
		alert('Event Handler "Confirmed()" \n\n is missing from page "' + window.parent.document.URL + '"');
	}

}
</script>

<%
    '// AI 08/11/2007 Code 1
    If Not Request.QueryString("E1") Is Nothing Then '// AI 08/11/2007 Code 1
        Show1 = Boolean.Parse(Request.QueryString("E1").ToString)
    End If
    
    If Not Request.QueryString("E2") Is Nothing Then '// AI 08/11/2007 Code 1
        Show2 = Boolean.Parse(Request.QueryString("E2").ToString)
    End If
    
    If Not Request.QueryString("B1") Is Nothing Then '// AI 08/11/2007 Code 1
        Caption1 = Request.QueryString("B1").ToString
    End If
    
    If Not Request.QueryString("B2") Is Nothing Then '// AI 08/11/2007 Code 1
        Caption2 = Request.QueryString("B2").ToString
    End If
    
    Image1 = ImageByButtonType(Caption1)
    Image2 = ImageByButtonType(Caption2)
%>



<link rel='stylesheet' type='text/css' href='../../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../../style/Touchscreen.css' />
</head>
<body onselectstart='return false;' 
		class="Touchscreen Dialog" 
		scroll="no"	
		>

<!-- This first table is used for alignment, plus to allow a transparent background which blocks events
	  passing through to the page below.  Other elements (divs, etc) don't seem to do this -->
<table style='height:100%;width:100%'>
	<tr>
		<td align='center'>
			
			<!-- This is the start of the visible section -->
			<table class="Surround" id="tblMain" cellspacing="10px">
				<tr>
					<td colspan="2" class="Prompt" id="tdPrompt"><%= Request.QueryString("Prompt") %></td>
				</tr>
								
				<tr>
				<%If Show2 Then%>
					<td align="left">
				<%Else%>
					<td colspan="2" align="center" >
				<%End If%>
<%
    TouchscreenShared.NavButton(("../../../images/touchscreen/" & Image1), Caption1, "Confirm('" & Caption1 & "')", Show1)
%>
		
					</td>
				<%If Show2 Then%>
					<td align="right">
<%
    TouchscreenShared.NavButton(("../../../images/touchscreen/" & Image2), Caption2, "Confirm('" & Caption2 & "')", Show2)
%>
					</td>
				<%End If%>
				</tr>				
			</table>
			
		</td>
	</tr>
</table>

</body>

</html>
<script language="vb" runat="server">

    Dim Show1 As Boolean = False
    Dim Show2 As Boolean = False
    Dim Caption1 As String = String.Empty
    Dim Caption2 As String = String.Empty
    Dim Image1 As String
    Dim Image2 As String
    
    Function ImageByButtonType(ByVal ButtonType As String) As String

        Select Case LCase(ButtonType)
            Case "yes", "ok"
                Return "Tick.gif"
            Case "no", "cancel"
                Return "Cross.gif"
            Case Else
                Return "Blank.gif"
        End Select

    End Function

</script>