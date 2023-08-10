<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<html>
<head>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript">
//----------------------------------------------------------------------------------------------------------------
//
//AdministrationSelectAction.aspx
//
//Select if want to remove, edit expiry date, or do nothing.
//
//Display in a simplar method as the confirm frame
//Frame should be called fraSelectAction
//Calling page requires a SelectedAction(sAction) method
//      - possible actions will be 'delete', 'enterdate', 'goback'
//
//Modification History:
//29Feb08 XN  Written
//
//----------------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------
function Show()    
{
    	window.parent.document.all['fraSelectAction'].style.display = 'block';
}    	

//-------------------------------------------------------------------------------------------
function SelectAction(strAction)
{
    // fired once an action has be performed, calls the parents SelectedAction method

	//Hide me
	window.parent.document.all['fraSelectAction'].style.display = 'none';

	if (window.parent.SelectedAction != undefined)
	{
	    //Call the event handler on the hosting page
		window.parent.SelectedAction(strAction.toLowerCase());
    }
	else 
	{
	    //Show a warning if the event handler isn't there, to help us poor developers!
		alert('Event Handler "SelectedAction()" \n\n is missing from page "' + window.parent.document.URL + '"');
    }
}

window.onload = function () { document.body.style.cursor = 'default'; }
</script>    

<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
</head>

<body onselectstart='return false;' 
		class="Touchscreen Dialog" 
		scroll="no"	
		>
		
    <table style='height:100%;width:100%'>
	<tr>
		<td align='center'>			
			<!-- This is the start of the visible section -->
			<table class="Surround" id="tblMain" cellspacing="10px">
				<tr>
					<td colspan='3' class='Prompt' id='tdPrompt'>Do you wish to...</td>
				</tr>
								
				<tr>
					<td align="left">
<%  
    TouchscreenShared.NavButton("../../images/touchscreen/cross.gif", "Delete this<br>Batch Number", "SelectAction('delete')", true)
%>
					</td>
					<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/BatchExpiryDateEntered.GIF", "Enter an<br>Expiry Date", "SelectAction('enterdate')", true)
%>
					</td>
					<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Go Back", "SelectAction('goback')", true)
%>
					</td>
				</tr>				
			</table>
			
		</td>
	</tr>
</table>

</body>
</html>
