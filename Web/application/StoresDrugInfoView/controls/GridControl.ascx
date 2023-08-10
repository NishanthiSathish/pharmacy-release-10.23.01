<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GridControl.ascx.cs" Inherits="application_StoresDrugInfoView_controls_GridControl" %>
<div id="<%= uniqueContainerID %>" class="gridBody" style="height: 100%; width: 100%; overflow: scroll;">
    <table width="97%" class="gridTable">
        <thead>
            <tr class="gridHeader" style="top: expression(document.getElementById(&quot;<%= uniqueContainerID %>&quot;).scrollTop);position:relative;">
    <% 
            for (int c = 0; c < columns.Count; c++) 
            {
    %>   
            <th colindex="<%= c %>" width="<%= columns[c].width %>%" style="border-style: solid; border-width: 1px; border-right: #335a7b; border-top: #7ea9ce; border-left: #7ea9ce; border-bottom: #335a7b; padding-left: 1px;"><span><%= columns[c].text %></span></th>
    <%
            }
    %>  
            </ tr>
        </thead>
        <tbody>
    <%
            for (int r = 0; r < rows.Count; r++) 
            {
                RowInfo rowInfo = rows[r];
    %>  
            <tr class="GridRow" tag="<%= rowInfo.tag %>" ondblclick="<%= AllowDblClick ? "gridcontrol_ondblclick(" + r.ToString() + ")" : "" %>" style="<%= (r % 2 == 1) ? "background-color: lightyellow" : "" %>">    
    <% 
                StringBuilder cellText = new StringBuilder();
                System.Collections.Generic.List<string[]> items = rowInfo.items;
                for (int c = 0; c < items.Count; c++) 
                {
                    cellText.Length = 0;

                    string[] lines = items[c];
                    for (int l = 0; l < lines.Length; l++)
                    {
                        string str = lines[l];
                        
                        if ((str != null) && (str.Trim() != string.Empty))
                            cellText.Append(Ascribe.Common.Generic.XMLEscape(str));
                        else
                            cellText.Append("&nbsp;");
                        
                        if (l < lines.Length - 1)
                            cellText.Append("<br />");
                    }
                    
                    if (columns[c].keepWhiteSpaces)
                        cellText = cellText.Replace(" ", "&nbsp;");
    %>   
                <td class="GridRow" width="<%= columns[c].width %>%" style="white-space: nowrap;" align=<%= columns[c].alignment %>><span><%= cellText %></span></td>
    <%
                }
    %>
            </tr>
    <%
            }
    %>  
        </tbody>    
    </table>
    <%
        if (rows.Count == 0)
        {
    %>  
        <br />         
        <div style="white-space: nowrap; text-align: center;"><span><%= EmptyGridMessage %></span></div>
    <%      
        }
    %>  
</div>