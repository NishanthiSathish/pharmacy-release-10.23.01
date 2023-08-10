<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<%
    Dim dtDate As Date 
    Dim dtNow As Date 
    Dim intDay As Double 
    Dim sessionId as Integer
    'Read the appropriate state variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    Const DAYS_IN_PAST As Integer = 3
    Const PICKER_HEIGHT As Integer = 250
    Const PICKER_WIDTH As Integer = 750

    dtNow = Now()
%>

<html>
<head>
<title></title>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript">
    //-------------------------------------------------------------------------------------------
    //									
    //									Touch-screen Date Picker for Admin
    //
    //	Shows the last n days as touch buttons
    //
    //	Useage:
    //		Host in an iframe on the page where you wish to use the keyboard, using the following HTML:
    //		<iframe id="fraDatePicker" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="AdministrationDatePicker.aspx"></iframe>
    //
    //		To show the picker, call its Show methods:
    //		void document.frames['fraDatePicker'].Show(strPromptHTML);
    //
    //		When the user selects a date, the picker calls the following function:
    //		function DatePicker_DateChosen(strDate, strDescription);
    //
    //		Where strDate contains a string in the format "ccyy-mm-dd"; strDescription contains a more
    //		english description of the date
    //
    //	Modification History:
    //	09Jun05 AE  Written
    //
    //-------------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------------
    //									Public Methods
    //-------------------------------------------------------------------------------------------
    function Show(strPromptHtml) {
        //Show it
        lblPrompt.innerHTML = strPromptHtml;
        window.parent.document.all['fraDatePicker'].style.display = 'block';
    }

    //-------------------------------------------------------------------------------------------
    function SetDate(objSrc) {
        //User has clicked on a date
        Close(objSrc.getAttribute('date'), (objSrc.innerText));
    }

    //-------------------------------------------------------------------------------------------
    function SetTime(objSrc) {
        //Not currently used
    }

    //-------------------------------------------------------------------------------------------
    function Close(strDate, strDescription) {
        //Close the window and call the event handler on the parent

        if (window.parent.DatePicker_DateChosen != undefined) {
            void window.parent.DatePicker_DateChosen(strDate, strDescription);
        }
        else {
            //Helpfull message for the developers who come along late
            alert('Event Handler "DatePicker_DateChosen()" \n\n is missing from page "' + window.parent.document.URL + '"');
        }

        //Close the dialog
        window.parent.document.all['fraDatePicker'].style.display = 'none';
   }

       window.onload = function () { document.body.style.cursor = 'default'; }
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body onselectstart='return false;' class="Touchscreen Dialog" scroll="no">
		
<!-- This first table is used for alignment, plus to allow a transparent background which blocks events
	  passing through to the page below.  Other elements (divs, etc) don't seem to do this -->
<table style='height:100%;width:100%'>
	<tr>
		<td align='center'>
			<div class="Surround" id="divPicker" style="width:<%= PICKER_WIDTH %>px;height:<%= PICKER_HEIGHT %>px">
				<div class="Prompt">
					<label id="lblPrompt" style="width:100%;"></label>
				</div>

			
			<!-- This is the start of the picker itself -->
				<table cellpadding='0' cellspacing='<%= BUTTON_SPACING %>'>
					<tr>	
<%
    'Write a button for each of the last DAYS_IN_PAST days
    For intDay = - DAYS_IN_PAST To 0
        dtDate = DateAdd("d", intDay, dtNow)
        Response.Write("<td>")
        ScriptButton_Date(sessionId, dtDate, false)
        Response.Write("</td>")
    Next
%>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>
</body>
</html>
