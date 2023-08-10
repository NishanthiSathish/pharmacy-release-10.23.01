<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PharmacyLabelPanelControl.ascx.cs" Inherits="PharmacyLabelPanelControl" EnableViewState="false" %>
<%
if (this.QSAllowConfiguration)
{
%>
    <asp:HiddenField ID="hfConfigurationFormParams" runat="server" />
<%        
}
%>    
<table id="<%= this.ID %>" width="100%" height="100%" >
    <tr height="100%" style="vertical-align: top;">
<% 
    for(int c = 0; c < table.Count; c++)
    {
%>
        <td class="PanelBackground" width="<%= columnWidths[c] %>%"  height="100%" >
            <div style="width: 100%; height: 100%; vertical-align: top;">
                <table style="vertical-align: top;">
<%      
                for (int r = 0 ; r < table[c].Count; r++)
                {
                    LabelValueInfo labelValue = table[c][r];
                    
                    // XML escape the value, if no value present the add space to prevent from being removed
                    string value = "&nbsp;";
                    if ((labelValue.value != null) && (labelValue.value.Trim() != string.Empty))
                        value = labelValue.xmlEscape ? Ascribe.Common.Generic.XMLEscape(labelValue.value) : labelValue.value;                                       
                    
                    // Get the style to apply to the value of the fields (if any)
                    string valueStyle = string.Empty;                    
                    string key = string.Format("{0}:{1}", c, r);
                    string id  = string.IsNullOrEmpty(labelValue.name) ? string.Empty : "name=\"" + labelValue.name + "\"";
                    valueStyles.TryGetValue(key, out valueStyle);                    
%>      
                    <tr>
                        <td style="white-space: nowrap;" class="Caption"><%= labelValue.label %></td>
		                <td class="Text" style="<%= valueStyle %>" <%= id %>><%= value %></td>          
                    </tr>
<% 
                }
%>
                </table>
            </div>
        </td>
<% 
    }
%>
    </tr>
</table>