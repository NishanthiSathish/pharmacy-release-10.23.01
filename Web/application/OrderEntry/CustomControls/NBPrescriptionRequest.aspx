<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common"%>
<%@ Import Namespace="Ascribe.Common.Generic"%>
<%@ Import Namespace="Ascribe.Common.Prescription" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '------------------------------------------------------------------------------------------------
    '
    'NBPrescriptionRequest.aspx
    '
    'Custom Control for Order Entry, used exclusively for entering North Birmingham
    'Prescription Requests
    '
    'Modification History:
    '10Dec03 PH Created by copying Prescription.aspx
    '
    'Feb03 TH Numerous additions for N Birmingham.
    'Note : have kept some dead code remmed during development process
    '( e.g. controls that may yet be required ), until this process is
    'complete, at which point it will be removed
    '
    '24Feb04 PH Removed frequency & repeat concept. General bug fixing/neatening up.
    '07Apr04 PH Added Start and End Date fields along with putting day labels on the 14 day dose boxes
    '13Apr04 AE A number of fixes to route selection and dose rounding.
    '25Apr04 AE Added support for ProductRoutes (tablet etc) as well as Units (mg etc).
    'Also fixed a number of bugs around the Populate region; previously was failing
    'silently and not populating parts of the form.
    '23Apr04 PH Added business logic for the EndDate, and some more enabling/disabling of controls
    '02Jan07 PH Here I am again. Major changes for Jan07 feature list.
    '11Jun09 ST Oooh loookie a new person to do changes to SMS
    '08Sep09 RAMS Removed unused variables
    '11Jul11 Rams TFS 7778/SW 103285 Titrating medication discrepancy - cannot view over 15 weeks
    '------------------------------------------------------------------------------------------------
    Dim SessionID As Integer
    Dim colTimeUnits As XmlNodeList
    Dim blnDisplay As Boolean
    Dim lngProductID As Integer
    Dim blnTemplate As Boolean
    Dim WeekNo As Integer = 0
    Dim DayNo As Integer = 0
%>

<html>

<head>
<title></title>
<%-- LM 10/01/2008 Code 162 Removed referenced to Prescription.vb.vb" --%>


<%
    'Validate the session
    'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
%>

<script language="javascript" type="text/javascript" src="../scripts/OrderFormResizing.js"></script>
<script language="javascript" type="text/javascript" src="../scripts/OrderFormControls.js"></script>
<script language="javascript" type="text/javascript" src="../../sharedscripts/Controls.js"></script>
<script language="javascript" type="text/javascript" src="../../sharedscripts/icwFunctions.js"></script>
<script language="javascript" type="text/javascript" src="../../sharedscripts/DateLibs.js"></script>
<script language="javascript" type="text/javascript" src="../../sharedscripts/PickList.js"></script>
<script language="javascript" type="text/javascript" src="CustomControlShared.js"></script>
<script language="javascript" type="text/javascript" src="NBPrescriptionRequest.js"></script>
<script language="javascript" type="text/javascript" src="SMS.js"></script>

<%
    'Check if we are in read-only mode.  If so we call SetReadOnly which lives
    'in OrderFormFunctions.js
    If String.IsNullOrEmpty(Request.QueryString("Display")) Then
        blnDisplay = false
    Else
        blnDisplay = Convert.ToBoolean(Request.QueryString("Display"))
    End IF

    If blnDisplay Then
        Response.Write("<script language=javascript defer>void SetReadOnly();</script>")
    End IF
    blnTemplate = (LCase(Request.QueryString("Template")) = "true")
    If Request.QueryString("ProductID") <> "null" And Request.QueryString("ProductID") <> "" Then
        lngProductID = CInt(Request.QueryString("ProductID"))
    Else
        lngProductID = 0
    End IF
    If blnTemplate Then
        lngProductID = 0
    End IF
    colTimeUnits = GetTimeUnits(SessionID)
%>


<script language="vbscript" type="text/vbscript">
function VBDateDiff(p_interval, p_date1, p_date2, p_firstdayofweek, p_firstweekofyear)
' 04Jan07 PH Function that lets us use the VB DateDiff function from JScript. It's more reliable than JScript is!	
	VBDateDiff = dateDiff(p_interval, p_date1, p_date2, p_firstdayofweek, p_firstweekofyear)
end function
</script>

<link rel="stylesheet" type="text/css" href="../../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../../style/application.css" />

</head>

<body id="formBody" sms="true" displaymode="<%= blnDisplay %>" class="OrderFormBody" sid="<%= SessionID %>" controlid="<%= Request.QueryString("ControlID") %>" onload="OptTitration_onclick();">
<div style="overflow:auto;">
    <%--Product --%>
    <span style="top:5;left:50;" class="ControlSpan">
        <label class="LabelField" id="asccontrol1" >Product</label>
        <span style="left:100;" class="ControlSpan">

	    <select class="MandatoryField" id="lstProducts" name="lstProducts" onchange="lstProducts_onchange(this.options[this.selectedIndex].getAttribute('dbid'),''); GenerateDescription();" > 
            <option dbid="0"></option>
            <%
                Dim xmlProducts As XmlNodeList = GetProducts(SessionID, blnDisplay)
                For Each xmlProduct As XmlNode In xmlProducts
                    Response.Write("<option " & "ismda=""" & xmlProduct.Attributes("MDA").Value & """ dbid=""" & xmlProduct.Attributes("ProductID").Value & """ " & ">" & xmlProduct.Attributes("Description").Value & "</option>" & vbCr)
                Next
             %>
	    </select>
	    </span>
    </span>

    <%--Product Form --%>
    <span style="top:35;left:50;" class="ControlSpan">
        <label class="LabelField" id="lblProductForm">Form</label>
        <span style="left:100;" class="ControlSpan" id="spnProductForm">
            <select id="lstProductForm" name="lstProductForm" <% if blnDisplay then %>disabled <% end if %> class="MandatoryField" onchange="lstProductForm_onchange(lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid'));GenerateDescription();"><option></option></select>
        </span>
        <span id="spnWaitForm" style="left:0;visibility:hidden;" class="ControlSpan"><img src="../../../images/Developer/ajax-loader.gif" alt="Please Wait..." /></span>
    </span>

    <%--Product Strength --%>
    <span style="top:65;left:50;" class="ControlSpan">
        <label class="LabelField" id="lblProductStrength">Strength</label>
        <span style="left:100;" class="ControlSpan" id="spnProductStrength">
            <select id="lstProductStrength" name="lstProductStrength" <% if blnDisplay then %>disabled <% end if %> class="MandatoryField" onchange="lstProductStrength_onchange(lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid'));GenerateDescription();"><option></option></select>
        </span>
        <span id="spnWaitStrength" style="left:0;visibility:hidden;" class="ControlSpan"><img src="../../../images/Developer/ajax-loader.gif" alt="Please Wait..." /></span>
    </span>
    
    
    <%--Product Pack --%>
    <span style="top:95;left:50;" class="ControlSpan">
        <label class="LabelField" id="lblProductPack">Pack</label>
        <span style="left:100;" class="ControlSpan" id="spnProductPack">
            <select id="lstProductPack" name="lstProductPack" <% if blnDisplay then %>disabled <% end if %> onchange="lstProductPack_onchange(lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid'));GenerateDescription();"><option></option></select>
        </span>
        <span id="spnWaitPack" style="left:0;visibility:hidden;" class="ControlSpan"><img src="../../../images/Developer/ajax-loader.gif" alt="Please Wait..." /></span>
    </span>

    <%--Product Brand --%>
    <span style="top:125;left:50;" class="ControlSpan">
        <label class="LabelField" id="lblProductBrand">Brand</label>
        <span style="left:100;" class="ControlSpan" id="spnProductBrand">
            <select id="lstProductBrand" name="lstProductBrand" <% if blnDisplay then %>disabled <% end if %> onchange="lstProductBrand_onchange(lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid'));GenerateDescription();"><option></option></select>
        </span>
        <span id="spnWaitBrand" style="left:0;visibility:hidden;" class="ControlSpan"><img src="../../../images/Developer/ajax-loader.gif" alt="Please Wait..." /></span>
    </span>

    <%--Product Route --%>
    <span style="top:155;left:50;" class="ControlSpan" id="spnRoute">
        <label class="LabelField" id="lblProductRoute">Route</label>
        <span style="left:100;" class="ControlSpan">
            <select id="lstProductRoute" name="lstProductRoute" <% if blnDisplay then %>disabled <% end if %> class="MandatoryField" onchange="ProductRouteChange(lstProducts.options[lstProducts.selectedIndex].getAttribute('dbid'))"></select>
        </span>
        <span id="spnWaitRoute" style="left:0;visibility:hidden;" class="ControlSpan"><img src="../../../images/Developer/ajax-loader.gif" alt="Please Wait..." /></span>
    </span>

     <%--Start Date --%>
    <span style="top:185;left:50;" class="ControlSpan" id="spnStartDate">
        <label class="LabelField" id="Label1">Start</label>
        <span style="left:100;" class="ControlSpan">
	        <input class="MandatoryField" id="txtStartDate" <% if blnDisplay then %>disabled <% end if %> type="text" validchars="DATE:dd/mm/yyyy" size="10" onchange="txtStartDate_LostFocus(this)" onkeydown="txtStartDate_onkeydown();" onkeypress="MaskInput(this);" onkeyup="FillWeeklyBoxes();RenderDayNames(txtStartDate)" onPaste="MaskInput(this)" value="<%=Now.ToShortDateString()%>" LastValue="<%=Now.ToShortDateString()%>" />
        </span>
        <span style="left:170;" class="ControlSpan">
            <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
            <% If blnDisplay Then%>
                <img src="..\..\..\images\ocs\show-calendar.gif" width="24" height="22" border="0" alt="Show Calendar" />
            <% Else%>
                <img src="..\..\..\images\ocs\show-calendar.gif" onclick="ctlStartDate_onclick(txtStartDate);" width="24" height="22" border="0" alt="Show Calendar" />
            <% End If %>        
        </span>
    </span>


    <%--End Date --%>
    <span style="top:185;left:280" class="ControlSpan" id="spnEndDate">
	    <label class="LabelField" >Last Dose On</label>
	    <span style="left:100;" class="ControlSpan">
	        <input type="checkbox" id="chkEndDate" <% if blnDisplay then %>disabled <% end if %> onclick="chkEndDate_onclick(this)"/>
	    </span>
	    <span style="left:120;" class="ControlSpan" >
	        <input class="DisabledField" id="txtEndDate" disabled="disabled" type="text" validchars="DATE:dd/mm/yyyy" size="10" onchange="txtEndDate_LostFocus(this);" onkeypress="MaskInput(this);" onkeyup="FillWeeklyBoxes()" onPaste="MaskInput(this)" value="" LastValue="" />
	        <%--<input class="DisabledField" id="txtEndDate" disabled="disabled" type="text" size="10" onchange="txtEndDate_LostFocus(this);" onkeypress="MaskInput(this);" onkeyup="FillWeeklyBoxes()" value=""/>--%>
	    </span>
	    <span style="left:272;" class="ControlSpan">
            <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
	        <% If blnDisplay Then %>
	            <img id="imgEndDate" src="..\..\..\images\ocs\show-calendar.gif" width="24" height="22" border="0" alt="Show Calendar"/>
	        <% Else %>
	            <img id="imgEndDate" src="..\..\..\images\ocs\show-calendar.gif" onclick="ctlEndDate_onclick(txtEndDate);" width="24" height="22" border="0" alt="Show Calendar"/>
	        <% End If %>
	        <%--<img id="imgEndDate" src="..\..\..\images\ocs\show-calendar.gif" onclick="chkEndDate.checked=true;SetFormState();ShowMonthViewWithDate(txtEndDate, txtEndDate ,txtEndDate.value);" width="24" height="22" border="0" alt="Show Calendar"/>--%>
	    </span>
    </span>


    <%--Dose Quantity and Unit boxes --%>
    <span style="top:215;left:50;" class="ControlSpan" id="Span1">
        <label class="LabelField" id="lblDose">Daily Dose</label>
        <span style="left:100; white-space:nowrap;" class="ControlSpan">
	        <input class="MandatoryField" type="text" id="txtDoseQty" <% if blnDisplay then %>disabled <% end if %> maxlength="10" size="5" validchars="NUMBERS" onKeyPress="MaskInput(this);" onPaste="MaskInput(this);" onchange="FillWeeklyBoxes();" previous="" /><button id="cmdDecDose" style="width:20;height:20" tabindex="-1" class="SpinButton" onclick="RoundDose(txtDoseQty, 'down');FillWeeklyBoxes();" title="Click here to round the dose down to the next available size">-</button><button id="cmdIncDose" style="width:20;height:20" tabindex="-1" class="SpinButton" onclick="RoundDose(txtDoseQty, 'up');FillWeeklyBoxes();" title="Click here to round the dose up to the next available size">+</button>
    	    <select class="MandatoryField" id="lstUnits" <% if blnDisplay then %>disabled <% end if %>></select>
        </span>
        <span style="left:350;" class="ControlSpan">
            <label class="LabelField" id="Label3">Profile Length</label>
        </span>
        <span style="left:450;" class="ControlSpan">
    	    <select class="MandatoryField" id="lstProfileLength" name="lstProfileLength" <% if blnDisplay then %>disabled <% end if %> onchange="lstProfileLength_onchange(this);"><option dbid="1">1 Week</option><option dbid="2" selected>2 Weeks</option><option dbid="4">4 Weeks</option></select>
        </span>
    </span>
    
    <div id="divDispensingSchedule" style="display:block">
        <span style="top:270;left:50; white-space:nowrap;" class="ControlSpan">
            <label class="LabelField" id="Label4">Titration</label>
            <span style="left:100;" class="ControlSpan" id="Span5">
                <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
                <select <% if blnDisplay then %>disabled <% end if %> id="lstTitration" name="lstTitration" class="MandatoryField" onchange="OptTitration_onclick();">
                    <option id="1">Standard</option>
                    <option id="2">Reducing</option>
                    <option id="3">Increasing</option>
                </select>
                
                <label class="LabelField" id="lblTitrate"></label>
                
                 <%--Titrate By --%>
                <span style="left:160;" class="ControlSpan" id="spnTitrateBy">
                <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
	                <input <% if blnDisplay then %>disabled <% end if %> class="DisabledField" id="txtTitrateBy" width="30"type="text" value="0" size="3" maxlength="10" onchange="FillWeeklyBoxes();" />
                </span>

                <%--Titrate Interval --%>
                <span style="left:220;" class="ControlSpan" id="spnTitrateInterval">
	                <label class="LabelField" id="asccontrol68">every&nbsp</label>
                    <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>	                
	                <input <% if blnDisplay then %>disabled <% end if %> class="DisabledField" id="txtTitrateInterval" width="30" type="text" value="0" size="3" maxlength="10" onchange="FillWeeklyBoxes();" />
                </span>

                 <%--Titrate Threshold --%>
                <span style="left:320;" class="ControlSpan" id="spnTitrateThreshold">
	                <label class="LabelField" id="asccontrol69">days until dose is&nbsp</label>
	                <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
	                <input <% if blnDisplay then %>disabled <% end if %> class="DisabledField" id="txtTitrateThreshold" width="30" type="text" value="0" size=3 maxlength="10" onchange="FillWeeklyBoxes();" />
                </span>

                <%--Titrate Action --%>
                <span style="left:485;" class="ControlSpan" id="spnTitrateAction">
	                <label class="LabelField" id="asccontrol84">then&nbsp</label>
	                <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
	                <select <% if blnDisplay then %>disabled <% end if %> class="MandatoryField" id="lstTitrateAction" onchange="lstTitrateAction_onchange(this)">
		                <option id ="lstTitration1">Maintain</option>
		                <option id ="lstTitration2">Stop</option>
	                </select> 
                </span>
                
            </span>
        </span>
        
    </div>


    <div id="divTakeOnProfile" style="display:block">
        <%--Take on start --%>
        <span style="top:320;left:140;" class="ControlSpan" id="Span2">
            <label class="LabelField" id="Label2">Take on</label>
        </span>

        <div style="position:absolute;top:300;left:210;width:375px;height:50px;border:1px solid #000000;"></div>
        
        <span style="top:305;left:150;" class="ControlSpan" id="Span4">
                <%
                    For DayNo = 0 To 6
                %>
                    <label id="TakeOnDayName<%= WeekNo * 7 + DayNo %>" style="position:absolute;left:<%= 80 + DayNo * 50 %>" class="LabelField" ><%=WeekNo * 7 + DayNo%></label>
                <%            
                    Next
                %>

        </span>        
        
            
        <% 
            For DayNo = 0 To 6
        %>
            <span style="top:320;left:<%= 232 + DayNo * 50 %>" class="ControlSpan">
                <input type="checkbox" id="chkTakeOn<%=DayNo%>" <% if blnDisplay then %>disabled <% end if %> onclick="chkTakeOn_onclick(this)" checked="checked" name="<%= DayNo%>" />
            </span>
        <%
            Next
        %>
        
        <span style="top:300;left:600;" class="ControlSpan" id="spnTakeonWarn">
            <label class="LabelField" id="lblWarn" style="color:Red;font-size:10px;height:50px;">Modifying Takeons will reset the Pick Up Pattern</label>
        </span>
        
        <%--Take on stop --%>
    </div>
    <div id="divPickupProfile" style="display:block">
        <label style="position:absolute;top:355;left:665;font-size:12px;"><em>Pickup Profile</em></label>
        <div style="top:370;left:50;width:700px;height:300px;overflow:auto;background-color:#BBCFFF;" class="ControlSpan">
            <%
                
                For DayNo = 1 To 6
            %>
                <span style="top:<%=50 * WeekNo %>;left:<%= 182 + DayNo * 50 %>" class="ControlSpan" >
                    <%--<input type="checkbox" id="chkPickup<%=WeekNo * 7 + DayNo%>" onclick="chkPickUp_onclick(this)" name=<%=DayNo %> />--%>
                    <input type="checkbox" id="chkPickup<%= DayNo%>" <% if blnDisplay then %>disabled <% end if %> onclick="chkPickUp_onclick(this)" name="<%=DayNo %>" checked="checked" />
                </span>
            <%            
                Next
            %>
                <span style="top:4;left:560;" class="ControlSpan">
                    <% ' 10Jan11 ST Merge in of code from 10.4 branch F0102751 %>
                    <button <% if blnDisplay then %>disabled <% end if %> style="width:120;height:22; background-color: #FFFFDF;" id="btnRecalculate" name="btnRecalculate" onclick="btnRecalculate_onclick();">Reset to Take Ons</button>
                </span>
                
            <%--Titrating PickUp--%>
               <label id = "lblTitratePickUp" style="position:absolute;top:20;left:10;font-weight:bold;" class="LabelField">Reducing Pickups</label>
            <%
                For DayNo = 0 To 6
            %>
                <label id="DayName<%= WeekNo * 7 + DayNo %>" style="position:absolute;top:<%= 20 + 50 * WeekNo %>;left:<%= 180 + DayNo * 50 %>" class="LabelField" ><%=WeekNo * 7 + DayNo%></label>
            <%            
                Next
            %>
            
            <div id = "divTitrate" style="position:relative; top:45; left:100; height:84px; width:75%; overflow:auto; border:1px solid black">
            <%
                For WeekNo = 0 To 14
            %>
	                <span style="top:<%= 5 + 26 * WeekNo %>;left:5;width:60;height:40" class="ControlSpan" id="spnWeekName<%= WeekNo %>">
		                <label class="LabelField" >Week <%=WeekNo + 1%>&nbsp;&nbsp;</label>
	                </span>
            <%
                For DayNo = 0 To 6
            %>
	                    <span style="top:<%= 5 + 26 * WeekNo %>;left:<%= 75 + DayNo * 50 %>;width:40;height:40" class="ControlSpan" id="spnDay<%= DayNo + (WeekNo * 7) %>">
		                    <%--26Oct09 Rams    F0066960 - added few custom attributes--%>
		                    <input disabled="disabled" style="width:40px" class="StandardField" id="txtDay<%= DayNo + (WeekNo * 7) %>" type="text" value="0" size="3" maxlength="10" onchange="txtDoseDays_change(this);" name="<%=DayNo %>" DayNo="<%=DayNo + (WeekNo * 7) %>" lastvalue ="" validchars="NUMBERS" onKeyPress="MaskInput(this);" onfocus="this.lastvalue=value;" onPaste="MaskInput(this);"/>
	                    </span>
            <%
                    Next
                Next
            %>
            </div>

            <%--Maintained Pickups --%>
            <label id ="lblMaintain" style="position:absolute;top:150;left:10;font-weight:bold;" class="LabelField">Maintained Pickups</label>
            <div id = "divMaintain" style="position:relative; top:90; left:100; height:84px; width:75%; overflow:auto; border:1px solid black">

            <%
                For WeekNo = 0 To 1
            %>
	                <span style="top:<%= 5 + 26 * WeekNo %>;left:5;width:60;height:40" class="ControlSpan" id="spnMnWeekName<%= WeekNo  %>">
		                <label class="LabelField" >Week <%=WeekNo + 1%>&nbsp;&nbsp;</label>
	                </span>
            <%
                    For DayNo = 0 To 6
            %>
	                    <span style="top:<%= 5 + 26 * WeekNo %>;left:<%= 75 + DayNo * 50 %>;width:40px;height:40px" class="ControlSpan" id="spnMnDay<%= DayNo + (WeekNo * 7) %>">
		                    <input disabled="disabled" style="width:40px" class="StandardField" id="txtMnDay<%= DayNo + (WeekNo * 7) %>" type="text" value="0" size="3" maxlength="10" />
	                    </span>
            <%
                    Next
                Next
            %>
            </div>
        </div>
    </div>


    <%--Distribution style="top:730;left:50" class="ControlSpan" id="spnDistribution" --%>
    <span style="top:730px;left:50px" class="ControlSpan" id="spnDistribution">
        <label class="LabelField" id="lblDistribution">Distribution</label>
        <span style="left:100px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    	    <select class="MandatoryField" id="lstDistribution" <% if blnDisplay then %>disabled <% end if %>> 
            <%
                Dim xmlDistributionList As XmlNodeList = GetDistributionMethod(SessionID)
                For Each xmlDistribution As XmlNode In xmlDistributionList
                    Response.Write("<option " & "dbid=""" & xmlDistribution.Attributes("DistributionMethodID").Value & """ " & ">" & xmlDistribution.Attributes("Description").Value & "</option>" & vbCr)
                Next
            %>
	        </select> 
        </span>
        &nbsp;&nbsp;&nbsp;<label class="LabelField">Installments</label>
        &nbsp;&nbsp;&nbsp;<input class="StandardField" id="txtInstallments" <% if blnDisplay then %>disabled <% end if %> type="text" value="0" size=3 maxlength="2" disabled />
        &nbsp;&nbsp;&nbsp;<label class="LabelField">Total</label>
        &nbsp;&nbsp;&nbsp;<input class="StandardField" id="txtTotal" <% if blnDisplay then %>disabled <% end if %> type="text" value="0" size=3 maxlength="8" disabled />
    </span>


    <%--Supplementary text directions field --%>
    <span style="top:760px;left:50px" class="ControlSpan" id="spnSupplementary">
	    <label class="LabelField">Supplementary</label>
	    <span style="left:100px;">
	        <button id="cmdPickText" <% if blnDisplay then %>disabled <% end if %> style="width:20px;height:20px" onclick="SelectText();" title="Click here to show the text picker.">...</button>
	    </span>
	    <span style="left:200px;">
	        <textarea id="txtExtra" <% if blnDisplay then %>disabled <% end if %> style="width:400px;height:40px" maxlength="1024" validchars="ANY" onKeyPress="MaskInput(this);" onPaste="MaskInput(this);" rows="3" class="StandardField"></textarea>
	    </span>
    </span>

     <%--XML Island to hold units --%>
    <%--<xml id="unitsData" onreadystatechange="UnitsDataLoaded()">
	    <Units/>
    </xml>--%>
    <%--01Dec09   Rams    F0070698 - Script Error when clicking on the button next to Dose Field--%>
    <xml id="unitsData">
    </xml>
    
    <%--XML Island to hold routes; we load ONLY approved routes as the page is scripted. --%>
    <%--<xml id="routesData" onreadystatechange="NBCheckRoutesLoaded();"> 
    </xml>--%>
    
    <xml id="routesData">
    
    </xml>
    
    <%--XML Island for Arbitrary text --%>
    <xml id="arbtextData" onreadystatechange="CheckArbTextLoaded();">
    </xml>

    <%--XML Island to hold the layout information (size, id etc) --%>
    <xml id="layoutData">
	    <xmldata>
		    <layout description="Prescription Layout" tableid="168" width="600" height="641" />
	    </xmldata>
    </xml>

    <%--XML Island used for parsing incomming data --%>
    <xml id="instanceData">
    </xml>



    <%--Frame for the monthview --%>
    <iframe style="display:none;width:0;height:0" application="yes" id="idDataLoader"></iframe>
   
</div>
</body>
</html>


<script language="vb" runat="server">

    
    'Get a list of prescribable units
    'Set xmldocUnits = GetPrescribableUnits(SessionID, ProductID)
    '-----------------------------------------------------------------------------------------------------------------------------------------
    '06Jan10    Rams    F0066752 - Removing an item from the SMS drug list makes prescriptions based on this unviewable
    Function GetProducts(ByVal SessionID As Integer, ByVal bDisplayDeleted As Boolean) As XmlNodeList
        'Fills a DOM with a list of all products
        Dim objRoutineRead As ERXRTL10.PrescriptionRequestRead = New ERXRTL10.PrescriptionRequestRead()
        Dim xmlDoc As XmlDocument = New XmlDocument()
        
        xmlDoc.TryLoadXml(objRoutineRead.ProductList(SessionID, bDisplayDeleted))
        '<Product ProductID="2" Description="Albumin"/>
        objRoutineRead = Nothing
        GetProducts = xmlDoc.SelectNodes("//Product")
    End Function

    '-----------------------------------------------------------------------------------------------------------------------------------------
    Function GetDistributionMethod(ByVal SessionID As Integer) As XmlNodeList
        'Fills a DOM with a list of all distribution methods
        Dim objDistributionMethodRead As OCSRTL10.DistributionMethodRead = New OCSRTL10.DistributionMethodRead()
        Dim xmlDoc As XmlDocument = New XmlDocument()

        xmlDoc.TryLoadXml(objDistributionMethodRead.List(SessionID))
        '<root>
        '<DistributionMethod DistributionMethodID="2" Description="Postal"/>
        '<DistributionMethod DistributionMethodID="2" Description="Collection"/>
        '</root>
        objDistributionMethodRead = Nothing
        GetDistributionMethod = xmlDoc.SelectNodes("//DistributionMethod")
    End Function

</script>