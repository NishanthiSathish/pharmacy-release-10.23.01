<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%
    Dim SessionID As Integer
    Dim strDoseUnit As String
    Dim strDose As String
    Dim strRoutine As String
    Dim strDoseDisplay As String
    
    Dim RoundToNearest As Double
    Dim ToMaximumOf As Double
    
    Dim blnAllowOverride As Boolean
    Dim blnReevaluate As Boolean
    
    blnAllowOverride = False
    blnReevaluate = False
    '
    SessionID = CInt(Request.QueryString("SessionID"))
    strDoseUnit = CStr(Request.QueryString("DoseUnit"))
    strDose = CStr(Request.QueryString("Dose"))
    strRoutine = CStr(Request.QueryString("Routine"))
    
    RoundToNearest = CDblX(Request.QueryString("RoundToNearest"))
    ToMaximumOf = CDblX(Request.QueryString("ToMaximumOf"))
    
    blnAllowOverride = CBoolX(Request.QueryString("AllowOverride"))
    blnReevaluate = CBoolX(Request.QueryString("Reevaluate"))
    
    strDoseDisplay = strDose & strDoseUnit & "/" & strRoutine
    
%>
<html>
<head>
    <title>Dose Options</title>
    
    <link rel='stylesheet' type='text/css' href='../../style/application.css' />
    <link rel='stylesheet' type='text/css' href='../../style/doseoptions.css' />
    <script language="javascript" src="../sharedscripts/icw.js"></script>
    <script language="javascript" src="../sharedscripts/icwFunctions.js"></script>
    <script language="javascript" src="../sharedscripts/controls.js"></script>    
    <script language="javascript" src="scripts/doseoptions.js"></script>    
</head>
<body sid="<%=SessionID%>">
<div align="center">
<table cellpadding="2" cellspacing="2" border="0" width="100%">
    <tr>
        <td>
            <table cellpadding="0" cellspacing="0" border="0" width="95%">
                <tr>
                    <td colspan="2"><p>&nbsp;</p></td>
                </tr>
                <tr>
                    <td align="left" style="font-family:Trebuchet MS; font-size:22px; font-weight:bold;">Dose: <%=strDoseDisplay%></td>
                    <td align="right"><img src="../../images/LightBulb.gif" width="16" height="16"><span class="LinkSpan" id="lnkTips" onclick="ShowDoseOptionsHints();" tabindex="4">Hints</span></td>
                </tr>
                <tr>
                    <td colspan="2"><p>&nbsp;</p><p>&nbsp;</p></td>
                </tr>
                <tr>
                    <td colspan="2" align="left">
                        <table cellpadding="0" cellspacing="0" border="0" width="100%" style="font-family:Trebuchet MS; font-size:16px;">
                            <tr>
                                <td>Round to nearest</td>
                                <td><input type=text id="txtRoundToNearest" name="txtRoundToNearest" tabindex="NextTabIndex()" class="StandardField" maxlength="10" size="6" validchars="NUMBERS" onKeyPress="MaskInput(this);" onPaste="MaskInput(this);" value="<%=RoundToNearest%>" />&nbsp;<%=strDoseUnit%></td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="4"><p>&nbsp;</p></td>
                            </tr>
                            <tr>
                                <td>To a maximum of</td>
                                <td><input type=text id="txtToMaximumOf" name="txtToMaximumOf" tabindex="NextTabIndex()" class="StandardField" maxlength="10" size="6" validchars="NUMBERS" onKeyPress="MaskInput(this);" onPaste="MaskInput(this);" value="<%=ToMaximumOf %>" />&nbsp;<%=strDoseUnit%></td>
                                <td><input type=checkbox id="chkAllowOverride" name="chkAllowOverride"
                                <%
                                    If blnAllowOverride = True Then
                                        Response.Write(" checked ")
                                    End If
                                %>
                                />&nbsp;Allow User to override this.</td>
                            </tr>
                            <tr>
                                <td colspan="3"><p>&nbsp;</p></td>
                            </tr>
                            <tr>
                                <td>Re-evaluate<br />Calculations on View</td>
                                <td><input type=checkbox id="chkReevaluateCalculations" name="chkReevaluateCalculations"
                                <%
                                    If blnReevaluate = True Then
                                        Response.Write(" checked ")
                                    End If
                                %>
                                /></td>
                                <td>&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p></td>
                </tr>
                <tr>
                    <td colspan="2" align="right"><button id="btnOK" accesskey="O" onclick="btnOK_onclick();" style="width:80px;"><u>O</u>K</button>&nbsp;&nbsp;<button id="btnCancel" accesskey="C" onclick="btnCancel_onclick();" style="width:80px;"><u>C</u>ancel</button></td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</div>
</body>
</html>
