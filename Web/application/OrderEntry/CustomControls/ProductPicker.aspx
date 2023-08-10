<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Xml" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<html>
<head>

<%
    Dim SessionID As Integer
    Dim objProductRead As DSSRTL20.ProductRead
    Dim DOM As XmlDocument
    Dim colProducts As XmlNodeList
    Dim objProduct As XmlElement
    Dim strProduct_XML As String 
    Dim lngProductID As Integer 
    Dim lngRouteID As Integer 
    Dim strTitle As String 
%>
<%
    '------------------------------------------------------------------------------
    '
    'ProductPicker.aspx
    '
    'Simple Modal Product Picker page.
    '
    'Querystring Parameters:
    'SessionID:	(Mandatory)
    'Mode:			(Mandatory)
    'Diluent 			  - Displays a list of TherapeuticMoieties which can be used as diluents
    'Administerable	  - Displays a list of Administerable Products (AMPs & AMPPs) which inherit
    'from the product specified in ProductID
    '
    'ProductID	(Only for "Administerable" Mode)
    'Title			(Optional)					- Title for display on the page.
    '
    'Returns:
    'The return parameter is blank if the user canceled,
    'or contains a string as follows:
    '"ProductID|ProductDescription"
    '
    '
    'Modification History:
    '25Feb03 AE  Written
    '06Jan04 AE  Renamed to ProductPicker.aspx, added Diluent Mode.
    '-------------------------------------------------------------------------------
    'Validate the session
    'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
%>


<script language="javascript">

function Initialise() {

	if (lstProducts.options.length > 0 ) {
		lstProducts.selectedIndex = 0;
	}
 	window.returnValue = '';
}

//===========================================================================================

function CloseWindow(blnCancel) {

var strReturn = new String()

	if (!blnCancel) {
		if (lstProducts.selectedIndex > -1) {
			strReturn = lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid')
							  + '|' + lstProducts.options[lstProducts.selectedIndex].text;
		}
	}
	else {
		strReturn = '';
	}
	
	window.returnValue = strReturn;
	window.close();

}

</script>

<%
    colProducts = Nothing
    lngProductID = 0
    lngRouteID = 0
    strTitle = Request.QueryString("Title")
    If strTitle = "" Then 
        strTitle = "Select a Product"
    End IF
    Select Case UCase(Request.QueryString("Mode"))
    Case "DILUENT"
        'Pick a product marked as a diluent.
        objProductRead = new DSSRTL20.ProductRead()
        strProduct_XML = objProductRead.GetDiluentsTherapeuticMoeityXML(SessionID)
        objProductRead = Nothing
        '<root>
        '<TherapeuticMoiety ProductID="193" Description="Lactulose solution"/>
        '</root>
        DOM = new XmlDocument()
        Dim xmlLoaded As Boolean = False

        Try
            DOM.LoadXml(strProduct_XML)
            xmlLoaded = True
        Catch ex As Exception
        End Try

        If xmlLoaded Then 
            colProducts = DOM.SelectNodes("root/TherapeuticMoiety")
        End IF
    Case "ADMINISTERABLE"
        'Standard mode, pick an AMP or AMPP which inherits from the specified product,
        'and which match the given route
        lngProductID = CInt(Request.QueryString("ProductID"))
        lngRouteID = CInt(Request.QueryString("RouteID"))
            objProductRead = New DSSRTL20.ProductRead()
            ' The call to this function has insufficient parameters, so has been excluded pending.
            'strProduct_XML = objProductRead.GetAdministerableProductsXML(SessionID, CInt(lngProductID), CInt(lngRouteID))
        objProductRead = Nothing
        '<root>
        '<AMP ProductID="10" ProductLicenseID="2" EntityID_Manufacturer="0" Divisible="0" Description="Atenolol Tablet 100mg"/>
        '<AMPP ProductID="10" Barcode="10020010" Description="Atenolol Tablet 100mg"/>
        '</root>
        DOM = new XmlDocument()
        Dim xmlLoaded As Boolean = False

        Try
            DOM.LoadXml(strProduct_XML)
            xmlLoaded = True
        Catch ex As Exception
        End Try

        If xmlLoaded Then 
            colProducts = DOM.SelectNodes("root/*")
        End IF
    Case Else 
        strTitle = "Unknown mode: '" & Request.QueryString("Mode") & "'"
    End Select
%>


<title><%= strTitle %></title>

<link rel="stylesheet" type="text/css" href= "../../../Style/application.css" />

</head>
<body onload="Initialise();" 
		scroll="no"
		>

<table style="height:100%;width:100%">
	<tr>
		<td style="height:100%">

			<select id="lstProducts"
					  ondblclick="CloseWindow(false)"
					  onkeydown="if (event.keyCode == 13){CloseWindow(false)};"
					  style="width:100%;height:100%" 
					  size=20
					  >
					  	<option dbid="0">&lt;NONE&gt;</option>
<%
    If Not colProducts Is Nothing Then 
        For Each objProduct In colProducts
            Response.Write("<option " & "dbid=""" & objProduct.GetAttribute("ProductID") & """ " & ">" & objProduct.GetAttribute("Description") & "</option>")
        Next
    End IF
%>


			</select>
		</td>
	</tr>
	
	<tr>
		<td>		
			<!-- buttons -->
			<table align="right" border=0 >
				<tr>
					<td><span id="spnMessage" class="StatusMessage">&nbsp;</span></td>	
					<td><button id="cmdCancel" 
									title="Click to exit without selecting a product."
									onclick="CloseWindow(true)"
									accesskey="c"
									><u>C</u>ancel</button>
					</td>
					
					<td><button id="cmdOK" 
									title="Click to select the highlighted product"
									onclick="CloseWindow(false)"
									accesskey="o"
									><u>O</u>K</button>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>		

</body>
</html>
