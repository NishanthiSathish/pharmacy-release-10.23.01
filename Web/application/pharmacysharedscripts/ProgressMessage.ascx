<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ProgressMessage.ascx.cs" Inherits="application_pharmacysharedscripts_ProgressMessage" %>

<script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js" async></script>
<style type="text/css">
    .ICWStatusMessage 
    {
	    color: #0000CC;
        height: 92;
        width: 171px;
        vertical-align: middle;
        padding-top: 18px;
	    background-color: transparent;
	    background-image: url(../images/Developer/status-box.png);
        font-weight:bold;
    }
    .ICWStatusMessage span
    {
        display: block;
    }
    .ICWStatusMessage img
    {
        display: block;
        margin-top: 8px;
    }
</style>

<div id="divUpdateProgress" style="display:none;position:absolute;width:100%;z-index:9900;top:0px;left:0px;height:100%;">
<table width=100% height=100% style="display:none;">
<tr valign=center>
    <td align=center>
        <div class="ICWStatusMessage" style="vertical-align:middle;height:75px;"><img src="../../images/Developer/spin_wait.gif" /><span id="spanMsg">Processing...</span></div>
    </td>
</tr>     
</table>           
</div>  