<%@ Page language="vb" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<html>
<head>
<%
    Const DESCRIPTION_LENGTH As Integer = 256
    Dim Title As String 
    Dim Prompt As String 
    Dim Text As String 
    Dim TextFixed As String 
    Dim MaxChars As Integer 
%>
<%
    '--------------------------------------------------------------------------------------------------------------------
    '
    'DescriptionPrompt.aspx
    '
    'Specialist Prompt box for OrderEntry, used to enter descriptions.
    'Allows a two-part description, part of which is fixed, the other part the user can enter.
    'This is a prescription-spececific measure.
    '
    'Useage:
    'The following Querystring parameters are used:
    'Title:							dialog title
    'Prompt:							instruction text, eg "enter description"
    'TextFixed:						fixed text for display as the first part of the description
    'Text:								Default for the user-editable text
    '
    'Modification History:
    '07Nov05 AE  Written
    '15Dec05 AE  Cosmetic improvements to deal with very long fixed text, also implemented maxlength attribute
    'on the editable text.
    '
    '--------------------------------------------------------------------------------------------------------------------
    Title = Request.QueryString("Title")
    Prompt = Request.QueryString("Prompt")
    Text = Request.QueryString("Text")
    TextFixed = Request.QueryString("TextFixed")
    MaxChars = DESCRIPTION_LENGTH - Len(Text)
%>

<title><%= Title %></title>

<script language="javascript" defer="true">

//Size the dialog as we load
	window.returnValue = null;


	function CloseWindow(blnCancel) {
	if (blnCancel){
		window.returnValue = null;
	}
	else {
		var strReturn = "";
		// 18Nov05 PH Put fix here to make it so that txtFixed doesnt get read if it doesnt exist 
		if ( document.getElementById("txtFixed") != null )
		{
			strReturn = txtFixed.value;
			if (txtFixed.value != '') {
			    strReturn += ' ';
			}
			else {
			    //F0095890 08Sep10 ST Added a check to ensure mandatory text is completed
			    alert("Not all details have been entered.");
			    document.getElementById("txtFixed").focus();
			    return;
			}
		}
		strReturn += txtInput.value;
		window.returnValue = strReturn;
	}
	void window.close();
}

function SetSize() {
    //Size the dialog as we load
	window.dialogHeight = '150px';
	window.dialogWidth = '600px';   

    if (document.getElementById('txtFixed') != null) {
        document.getElementById('txtFixed').width = document.body.clientWidth - 15;
        //F0101253 Set the width of the dialog box to something sensible based upon the length of the string of text
        window.dialogWidth = document.getElementById('txtFixed').value.length * 7 + 'px';

        //F0101253 Check for a minimum width and set it here if we have reached it.
        var width = window.dialogWidth.replace("px", "");
        if (width < 600)
            window.dialogWidth = '600px';
	}

	document.getElementById('txtInput').width = document.body.clientWidth - 15;
	
	//F0101253 ST 12Nov10 Move buttons in according to width of window.
	document.getElementById('tblButtons').width = document.body.clientWidth - 20;
}


</script>

<link rel='stylesheet' type='text/css' href='../../style/application.css' />
</head>
<body onload="SetSize()" scroll="no" style="margin:5px">

<table style="width:100%;height:100%;" cellspacing="0" cellpadding="1" border=0>
	<tr>
	    <td width="100%" colspan="2">
	        <table id="tblButtons">
	            <tr>
		            <td align="left"><%= Prompt %></td>
		            <td align="right">	
			            <table>
				            <tr>
					            <td align="right"><button id="cmdOK" onclick="CloseWindow(false)" accesskey="o" tabindex="2" ><u>O</u>K</button></td>
				            </tr>
            				
				            <tr>
					            <td align="right"><button id="cmdCancel" onclick="CloseWindow(true)" accesskey="c" tabindex="3"><u>C</u>ancel</button></td>
				            </tr>
			            </table>
		            </td>
	            </tr>
	        </table>
	        
	    </td>
	</tr>
	
	<tr>
		
<%
    If TextFixed <> "" Then 
        'We have some fixed text to append to the bit the user can enter
        '24Aug10 ST F0094916 Updated so that fixed text is displayed in the correct size input box
%>

			<td colspan="2">
				<input type="text"
						 id="txtFixed"
						 tabindex="-1" 
						 style="width:100%;"
						 maxlength="<%= DESCRIPTION_LENGTH - Len(TextFixed) %>"
						 value="<%= TextFixed %>"						 
						 class="MandatoryField"  
						 
						 />	
					 
			</td>
		</tr>
		<tr>

<%
    End IF
%>

			<td colspan="2">
				<input type="text"
						 id="txtInput"
						 class="StandardField"
						 tabindex="1"
						 style="width:100%;"
						 maxlength="<%= MaxChars %>"
						 onkeydown="if (window.event.keyCode==13) CloseWindow(false);"
						 value="<%= Text %>"
						 />
			</td>
	</tr>
</table>	


</body>
</html>

