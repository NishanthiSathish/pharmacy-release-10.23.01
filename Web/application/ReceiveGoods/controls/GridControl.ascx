<%@ Control Language="C#" AutoEventWireup="true" CodeFile="GridControl.ascx.cs" Inherits="application_ReceiveGoods_controls_GridControl" %>
<div id="<%= controlID %>" class="gridBody" style="height: 100%; width: 100%; overflow: scroll;">
    <table width="97%" class="gridTable" >
        <thead>
            <tr class="gridHeader" style="top: expression(document.getElementById(&quot;<%= controlID %>&quot;).scrollTop);position:relative;">
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

                StringBuilder attributes = new StringBuilder();
                StringBuilder style = new StringBuilder();
                
                // Build up string of extra attributes
                foreach (string extraAttribute in rowInfo.extraAttributes)
                {
                    attributes.Append(extraAttribute);
                    attributes.Append(" ");
                }
                
                // Add index of row
                attributes.AppendFormat("rowindex=\"{0}\" ", r);
                
                // Add click events
                if (AllowClick)
                    attributes.Append(string.Format("onclick=\"gridcontrol_onclick({0})\" ", r));
                if (AllowDblClick)
                    attributes.Append(string.Format("ondblclick=\"gridcontrol_ondblclick({0})\" ", r));
                
                // Add alternating colours
                if (r % 2 == 1)
                    style.Append("background-color: lightyellow; ");
                
                // Set if row is to be visible
                if (!rowInfo.visible)
                    style.Append("visibility: hidden; ");                                    
    %>  
            <tr class="GridRow" <%= attributes.ToString() %> style="<%= style.ToString() %>">
    <% 
                System.Collections.Generic.List<string> items = rowInfo.items;
                for (int c = 0; c < items.Count; c++) 
                {
                    string cellText = string.Empty;
                        
                    switch (columns[c].type)
                    {
                    case ColumnType.Text: 
                        cellText = Ascribe.Common.Generic.XMLEscape(items[c]); 
                        if (columns[c].keepWhiteSpaces)
                            cellText = cellText.Replace(" ", "&nbsp;");
                        break;
                            
                    case ColumnType.Checkbox: 
                        cellText = "<input type=\"checkbox\" "; 
                        if (AllowCheckBoxClick)
                            cellText += "onclick=\"gridcontrol_checkboxclick(" + r + "," + c + ")\" ";    // Add check box click event if requested
                        cellText += "/>";                            
                        break;
                    }
                                            
                    if ((cellText == null) || (cellText.Trim() == string.Empty))
                        cellText = "&nbsp;";                    
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