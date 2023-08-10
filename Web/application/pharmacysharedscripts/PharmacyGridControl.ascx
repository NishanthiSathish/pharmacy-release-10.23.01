<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PharmacyGridControl.ascx.cs" Inherits="PharmacyGridControl" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<% 
    string overflow;
    if (this.VerticalScrollBar && this.HorizontalScrollBar)
        overflow = "overflow: auto;";
    else if (this.HorizontalScrollBar)
        overflow = "overflow-x: scroll; overflow-y: hidden;";
    else if (this.VerticalScrollBar)
        overflow = "overflow-x: hidden; overflow-y: scroll;";
    else
        overflow = "overflow-x: hidden; overflow-y: hidden;";
        
%>
<div id="<%= this.ID %>" class="gridBody" style="height: 100%; width: 100%; <%= overflow %>" onkeydown="gridcontrol_onkeydown_internal(id, event)" 
        enableAlternateRowShading="<%= this.EnableAlternateRowShading %>"         
        sortcolumnindex=""
        sortdir=""
        enterAsDblClick="<%= this.EnterAsDblClick %>"
        allowMultiSelect="<%= this.AllowMultiSelect %>"
        JavaEventOnRowSelected="<%= this.JavaEventOnRowSelected %>"
        JavaEventOnRowUnselected="<%= this.JavaEventOnRowUnselected %>"
        OnClientGetChildRows="<%= this.OnClientGetChildRows %>"
>
<%
    if (this.QSAllowConfiguration)
    {
%>
        <asp:HiddenField ID="hfConfigurationFormParams" runat="server" />
<%        
    }
%>    
    <%--<table width="97%" class="gridTable" cellspacing="<%= this.CellSpacing %>" cellpadding="<%= this.CellPadding %>" > 15Sep14 XN 50736 removed anoying overlap with header and scrol bar --%>
    <table style="width: expression( this.offsetParent.clientWidth - 1 );" class="gridTable" cellspacing="<%= this.CellSpacing %>" cellpadding="<%= this.CellPadding %>" >
        <thead>
            <tr class="gridHeader" 
<% 
    if (this.VerticalScrollBar)  
    {
%>
            <%--style="top: expression(document.getElementById(&quot;<%= this.ID %>&quot;).scrollTop);position:relative;text-align:center;" 15Sep14 XN 50736 removed document.getElementById as parentNode.parentNode is faster --%>
            style="top: expression( this.parentNode.parentNode.parentNode.scrollTop );position:relative;text-align:center;"
<%
    }
%>
            >
    <% 
            for (int c = 0; c < columns.Count; c++) 
            {
                ColumnInfo columnInfo = columns[c];
                
                // Build up string of extra attributes
                StringBuilder attributes = new StringBuilder();
                
                // Build up string of extra attributes XN 18Aug15 126594
                foreach (var extraAttribute in columnInfo.attributes)
                    attributes.AppendFormat("{0}=\"{1}\" ", extraAttribute.Key, extraAttribute.Value);
                
                // Add index of column
                attributes.AppendFormat("colindex=\"{0}\" ", c);
                
                // Add column type
                attributes.AppendFormat("columntype=\"{0}\" ", columnInfo.type.ToString());
                
                // Add column alignment (used by printing)
                attributes.AppendFormat("colalignment=\"{0}\" ", columns[c].alignment);
                
                // add column header on click if sortable headers are sortable
                if (this.SortableColumns && columnInfo.sortable)
                    attributes.AppendFormat("onclick=\"columnheader_onclick('{0}', {1})\" ", this.ID, c);

                // Build up styles                
                StringBuilder style = new StringBuilder(" white-space: nowrap;");
                style.AppendFormat("text-align:{0};", columns[c].alignmentHeader);
                
                // setup sort image
                string sortImage = string.Empty;
                if (this.ShowSortImage)
                    sortImage = string.Format("<img id='imgSort' src='{0}{1}' height='10' width='10' />", Constants.IMAGE_DIR, Constants.IMAGE_EMPTY);                    
    %>   
            <th width="<%= columnInfo.width %>%" <%= attributes.ToString() %> style="<%= style.ToString() %>"><%= columns[c].text %><%= sortImage %></th>
    <%
            }
    %>  
            </ tr>
        </thead>
        <tbody onselectstart="return false;">
    <%
            bool hasChildRows = this.columns.Any(c => c.type == ColumnType.ChildRowButton);
            for (int r = 0; r < rows.Count; r++) 
            {
                RowInfo rowInfo = rows[r];

                StringBuilder attributes = new StringBuilder();
                StringBuilder style = new StringBuilder(rowInfo.style);
                
                // Build up string of extra attributes
                foreach (string extraAttribute in rowInfo.attributes)
                {
                    attributes.Append(extraAttribute);
                    attributes.Append(" ");
                }
                
                // If has child rows
                if (rowInfo.showChildRows != null)
                {
                    attributes.AppendFormat("showchildrows='{0}' ", rowInfo.showChildRows.ToOneZeorString());
                }
                
                // Child row level
                if (rowInfo.level != null)
                {
                    attributes.AppendFormat("level='{0}' ", rowInfo.level);
                }
                
                // Add click events
                //attributes.AppendFormat("onclick=\"gridcontrol_onclick_internal('{0}',this.rowIndex-1)", this.ID); Fixed potention bug XN 29May14 88922               
                attributes.AppendFormat("onclick=\"gridcontrol_onclick_internal('{0}',this.rowIndex-1);", this.ID);                
                if (!string.IsNullOrEmpty(JavaEventClick))
                    attributes.AppendFormat("{0}(this.rowIndex-1)", JavaEventClick);
                attributes.AppendFormat("\" ");
                
                if (!string.IsNullOrEmpty(JavaEventDblClick))
                    attributes.Append(string.Format("ondblclick=\"{0}({1})\" ", JavaEventDblClick, r));                
                
                // Added JavaEventOnMouseDown property XN 29May14 88922
                if (!string.IsNullOrEmpty(JavaEventOnMouseDown))
                    attributes.AppendFormat("onmousedown=\"{0}(this.rowIndex-1)\"", JavaEventOnMouseDown);
                
                // Set row background colour (also dependant on if row shading is enabled)
                if (!string.IsNullOrEmpty(rowInfo.backgroundColour))
                    style.Append(string.Format("background-color: {0}; ", rowInfo.backgroundColour));
                else if (this.EnableAlternateRowShading && (r % 2 == 0))    // alter shading sequence so works better with child rows else if (this.EnableAlternateRowShading && (r % 2 == 1))
                    style.Append("background-color: lightyellow; ");
                
                // Set text colour
                if (!string.IsNullOrEmpty(rowInfo.textColour))
                    style.Append(string.Format("color: {0};", rowInfo.textColour));
                
                // Set if row should be hidden
                if (!rowInfo.visible)
                {
                    style.Append("display:none;");
                    attributes.Append(" display=\"none\"");
                }
    %>  
            <tr class="GridRow" <%= attributes.ToString() %> style="<%= style.ToString() %>">
    <%                 
                List<string> items = rowInfo.items;
                for (int c = 0; c < items.Count; c++) 
                {
                    string cellText = string.Empty;
                    string cellStyle = rowInfo.styles[c];
                        
                    switch (columns[c].type)
                    {
                    case ColumnType.Checkbox: 
                        cellText = "<input type=\"checkbox\" "; 
                        if (!string.IsNullOrEmpty(JavaEventCheckBoxClick))
                            cellText += string.Format("onclick=\"{0}({1},{2})\" ", JavaEventCheckBoxClick, r, c);    // Add check box click event if requested
                        if (items[c] == "Y")
                            cellText += "checked=\"true\" ";                                                        
                        cellText += "/>";                            
                        break;
                            
                    case ColumnType.ChildRowButton:
                        string imgFile;
                            
                        switch (rowInfo.showChildRows)
                        {
                        case false: imgFile = "../../images/grid/imp_open.gif";   break;
                        case true:  imgFile = "../../images/grid/imp_closed.gif"; break; 
                        default:    imgFile = string.Empty; break; 
                        }                                
                        
                        cellText = string.Format("<img src='{0}' width='{1}' onclick='gridcontrol_onshowchildrows_internal(\"{2}\", this);' />", imgFile, string.IsNullOrEmpty(imgFile) ? "0" : "15", this.ID);
                        break;
                                                        
                    default:            
                        // Store everything else as a string                                            
                        cellText = items[c]; 
                        if (columns[c].xmlEscaped) 
                            cellText = Ascribe.Common.Generic.XMLEscape(cellText); 
                        if (columns[c].keepWhiteSpaces)
                            cellText = cellText.Replace(" ", "&thinsp;");   // pre and pre-wrap don't work as well  cellText = cellText.Replace(" ", "&nbsp;");
                        if (hasChildRows && rowInfo.level != null && c==1) 
                            cellText = string.Format("<div style='padding-left:{0}px'>{1}</div>", rowInfo.level.Value * 9, cellText);
                        break;
                    }
                                            
                    if ((cellText == null) || (cellText.Trim() == string.Empty))
                        cellText = "&nbsp;";                    
                    
                    if (!columns[c].allowTextWrap)
                        cellStyle += "white-space: nowrap;";
                    
                    cellStyle += string.Format("width:{0}%;",     columns[c].width.ToString());
                    cellStyle += string.Format("text-align:{0};", columns[c].alignment);
                    
                    // Set font size for grid (has to be done on every cell to override style sheet)
                    if (!this.FontSize_Cell.IsEmpty)
                        cellStyle += string.Format("font-size:{0};", this.FontSize_Cell.Unit.ToString());
                    
                    // Set col span (24Jul13 XN 24653)
                    string colSpan = string.Empty;
                    if (rowInfo.colSpan[c] > 1)
                        colSpan = string.Format("colspan='{0}'", rowInfo.colSpan[c]);
                        
    %>   
                <td <%= colSpan %> style="<%= cellStyle %> vertical-align: top;"><span><%= cellText %></span></td> 
    <%
                    c += rowInfo.colSpan[c] - 1;
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
        <div style="white-space: nowrap; text-align: center; top: 30%; position: relative;"><span><%= EmptyGridMessage %></span></div>
    <%      
        }
    %>  
</div>
