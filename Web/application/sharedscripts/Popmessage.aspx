<%@ Page language="vb" %>
<!--#include file="ASPHeader.aspx"-->
<html>

<head>
<title><%= Request.QueryString("Title") %></title>
<!-- 	

										Popmessage.htm
										
	Simple message box replacement.  Deals with large amounts of text better
	than the standard alert() method.  Also deals with HTML, so use <br> or <p>
	for newlines rather than \n
	
	Do not use this page directly, call the Popmessage method in ICWFunctions.js
	instead.
	
	Modification History:
	03Apr03 AE  Written
	22Jun03 PH	Updated to auto-detect & display BrokenRules XML	

-->


<style>

Body
{
	overflow:hidden;
	padding:5px;
}

.TitleDiv
{
	font-size:12pt;
	font-weight:bold;
}

.TextDiv
{

	overflow-y:auto;
	overflow-x:hidden;
	border:1px solid;
	padding:10px;
	background-color:#ffffff;
	font-family:arial;
	font-size:9pt;
}


</style>

<script language="javascript" src="../sharedscripts/icwfunctions.js"></script>

<script language="javascript" >

function Initialise() {
	var strInput;
	var strHTML;

	//Insert the text as soon as we've loaded
	strInput = window.dialogArguments;

	// PH Check for BrokenRules
	if (strInput.indexOf("<BrokenRules")!=-1)
	{
		strHTML = BrokenRulesToHTML(strInput)
	}
	else
	{	
		//Replace control chars with HTML
		strHTML = ToHTML(strInput);
	}

	//Insert the text into the page
	document.all['txtDetail'].innerHTML = strHTML;
	
	void Resize()
}
	
//==============================================================

function BrokenRulesToHTML(strBrokenRules_XML)
{
//	Uses the XML page island (xmlMsg) to convert BrokenRules XML to HTML
	var nodelist;
	var intIndex;
	var strHTML = "";

	if (xmlDoc.loadXML(strBrokenRules_XML))
	{
	   nodelist = xmlDoc.selectNodes("BrokenRules/Rule")
	   for (intIndex=0; intIndex<nodelist.length; intIndex++)
	   {
			strHTML += ToHTML(nodelist(intIndex).getAttribute("Text")) + "<br>";
		}
	}
	return strHTML;
}


//==============================================================

function Resize() {

	var newHeight = popBody.offsetHeight - txtTitle.offsetHeight - cmdClose.offsetHeight - 25;
	txtDetail.style.height = newHeight;
	txtDetail.style.width = popBody.offsetWidth - 10;
	
}

function window_onkeyup()
{
	if (event.keyCode==27)
	{
		window.close();
	}
}

//==============================================================
	
</script>

<xml id=xmlDoc>
</xml>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
</head>
<body id="popBody" 
		onresize="Resize();"
		onload="Initialise();"
		onkeyup="window_onkeyup()"
		>

<div align="center" class="TitleDiv" id="txtTitle" style="width:100%;"></div>

<div id="txtDetail" 
			 class="TextDiv"
			 onkeypress="return false;"
			 tabindex="3"
			 >
</div>
<br>

<table align="center" style="width:100%">
	<tr>
		<td>
			<button id="cmdCopy" 
					  onclick="window.clipboardData.setData('Text', document.all['txtDetail'].innerText);"
					  accesskey="C"
					  tabindex="2"
					  >
					  <u>C</u>opy
			</button>
		</td>

		<td>
			<button id="cmdClose" 
					  onclick="window.close();"
					  accesskey="O"
					  tabindex="1"
					  >
					  <u>O</u>K
			</button>
		</td>
	</tr>
</table>	

</body>
</html>
