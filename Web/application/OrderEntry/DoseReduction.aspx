<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DoseReduction.aspx.cs" Inherits="application_OrderEntry_DoseReduction" %>

<%--09Mar10   Rams      F0079880 -  focus goes to header check box after tabbing out of individual dose adjust box
                        Lot of changes to hold the state of the request.Used __LastFocus, on the onfocus property to get it working correctly

--%>

<html>
<head>
	<title>Dose Adjustment</title>
	<link href="../../Style/application.css" rel="stylesheet" type="text/css" />
	<link href="../../Style/DoseReduction.css" rel="stylesheet" type="text/css" />
	<script language="javascript" src="../sharedscripts/Controls.js"></script>

    <script type="text/javascript">
        //09Mar10   Rams    F0079880 -  focus goes to header check box after tabbing out of individual dose adjust box
        function ChangeFocus(RepeaterID,Name_)
        {
            if (Name_ <10)
            {
                document.getElementById(RepeaterID +'_ctl0' + Name_ +'_chkTick' ).focus();
            }
            else
            {
                document.getElementById(RepeaterID +'_ctl' + Name_ +'_chkTick' ).focus(); 
            }
        }        
    </script>
    
</head>
<body scroll="no">
	<table id="tblContainer" width="100%" height="100%">
		<tr>
			<td>
				<form id="frmMain" runat="server" style="height: 99%">
				<asp:ScriptManager ID="ScriptManager1" runat="server" />
				<asp:UpdateProgress ID="UpdateProgress1" runat="server">
					<ProgressTemplate>
						<div class="progress">
							<img src="../../images/Developer/ajax-loader.gif" />
							Processing, please wait...
						</div>
					</ProgressTemplate>
				</asp:UpdateProgress>
				<asp:UpdatePanel ID="UpdatePanel1" runat="server">
					<ContentTemplate>
						<asp:TextBox ID="txtXML" Style="display: none" runat="server"></asp:TextBox>
						<table id="tblLayout" width="100%" height="100%">
							<tr valign="top">
								<td>
									<div id="tbl-container" style="border: solid 1px #000000; background-color: #ffffff;
										height: 100%; width: 100%; overflow: auto;">
										<table id="tblGrid" width="100%" cellpadding="0" cellspacing="0">
											<thead>
												<tr>
													<td>
														<input id='btnchkAll' type="button" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id;document.getElementById('chkAll').focus();} catch(e){}" style="width:1px" />
														<asp:CheckBox ID="chkAll" runat="server" OnCheckedChanged="chkAll_CheckedChanged" onclick="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e){}" AutoPostBack="True" />
													</td>
													<td>
														Drug
													</td>
													<td>
														Dose
													</td>
													<td>
														Calculated Dose
													</td>
													<td width="10%">
														Adjustment
													</td>
													<td width="16%" align="center">
														Prescribed Dose
													</td>
												</tr>
											</thead>
											<tbody>
												<asp:Repeater ID="rpt" runat="server" DataSourceID="XmlSource" OnItemCommand="rpt_ItemCommand">
													<ItemTemplate>
														<asp:UpdatePanel runat="server">
															<ContentTemplate>
																<tr>
																	<td>
																		<asp:Label ID="lblFormOrdinal" runat="server" style="display:none" Text='<%# DataBinder.Eval(Container, "DataItem.FormOrdinal")%>'></asp:Label>
																		<asp:Label ID="lblProductID" runat="server" style="display:none" Text='<%# DataBinder.Eval(Container, "DataItem.ProductID")%>'></asp:Label>
																		<input id='btnTick<%=RepeaterCount+=1 %>' type="button" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id;ChangeFocus('rpt','<%=RepeaterCount%>');} catch(e){}" style="width:1px" />
																		<asp:CheckBox ID="chkTick" runat="server"  Checked='<%# ((String)(DataBinder.Eval(Container, "DataItem.Checked"))=="1") %>'  
																			OnCheckedChanged="chk_CheckedChanged" AutoPostBack="True" onclick="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e){}"/>
																	</td>
																	<td>
																		<div>
																			<asp:Label runat="server"><b><%# DataBinder.Eval(Container, "DataItem.Description")%></b></asp:Label>
																		</div>
																		<asp:Label runat="server"><%# DataBinder.Eval(Container, "DataItem.Route")%></asp:Label>
																		&nbsp
																		<asp:Label runat="server"><%# DataBinder.Eval(Container, "DataItem.StartDate")%></asp:Label>
																	</td>
																	<td>
																		<asp:Label runat="server">
																<%# (
										DataBinder.Eval(Container, "DataItem.Dose_Low").ToString()!="0"
										? 
										DataBinder.Eval(Container, "DataItem.Dose_Low").ToString() + " to "
										:
										"" 
									)
									+
									DataBinder.Eval(Container, "DataItem.Dose").ToString()
									+
									DataBinder.Eval(Container, "DataItem.Unit").ToString()
									+
									"/"
									+
									DataBinder.Eval(Container, "DataItem.RoutineName").ToString()
                                %>
																		</asp:Label>
																	</td>
																	<td>
																		<asp:Label runat="server">
																<%# (
										DataBinder.Eval(Container, "DataItem.Dose_Low_Calc").ToString()!="0"
										? 
										double.Parse(DataBinder.Eval(Container, "DataItem.Dose_Low_Calc").ToString()).ToString("0.##") + " to "
										:
										"" 
									)
									+
									double.Parse(DataBinder.Eval(Container, "DataItem.Dose_Calc").ToString()).ToString("0.##")
									+
									DataBinder.Eval(Container, "DataItem.Unit_Calc").ToString()
                                %>
																		</asp:Label>
																	</td>
																	<td>
																		<asp:TextBox runat="server" ID="txtAdjustment" AutoPostBack="True" CausesValidation="True"
																			Text='<%#DataBinder.Eval(Container, "DataItem.Adjustment", "{0:+###;-###;0}")%>' Width="50px" MaxLength="4"
																			OnTextChanged="txtAdjustment_TextChanged" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e) {}"
																			onkeypress="MaskInput(this);" onpaste="MaskInput(this);" validchars="SignedInteger" ></asp:TextBox>
																		%
																	</td>
																	<td align="center">
																		<asp:Label runat="server">
																<%# (
										DataBinder.Eval(Container, "DataItem.Dose_Low_Prescribed").ToString()!="0"
										?
                                        double.Parse(DataBinder.Eval(Container, "DataItem.Dose_Low_Prescribed").ToString()).ToString("0.##") + " to "
										:
										"" 
									)
									+
                                    double.Parse(DataBinder.Eval(Container, "DataItem.Dose_Prescribed").ToString()).ToString("0.##")
									+
									DataBinder.Eval(Container, "DataItem.Unit_Prescribed").ToString()
                                %>
																		</asp:Label>
																		<asp:Label Style="color: red"><%# DataBinder.Eval(Container, "DataItem.Cap_Warning").ToString()%></asp:Label>
																	</td>
																</tr>
																<td align="center" colspan="6">
																	<asp:Label id="lblValid" runat="server" CssClass="ValidationMsg"></asp:Label>
																</td>
																<tr>
																</tr>
															</ContentTemplate>
														</asp:UpdatePanel>
													</ItemTemplate>
												</asp:Repeater>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
							<tr valign="top" height="80px">
								<td id="tdBottomPanel">
									<table width="100%">
										<tr valign="middle">
											<td width="50%">
												ALL MARKED Doses by
												<asp:TextBox runat="server" ID="txtGroupAdjustment" CausesValidation="True"
													Text='0' Width="50px" MaxLength="4" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e) {}" validchars="SignedInteger"></asp:TextBox>
												%
												<asp:Button ID="btnGroupAdjust" runat="server" Text="Apply" CssClass="ICWButton"
													Style="width: 46px" OnClick="btnGroupAdjust_Click" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e) {}" />
												<asp:RangeValidator runat="server" ErrorMessage="<br/>The group adjustment percentage should be between -100 and 999."
													ControlToValidate="txtGroupAdjustment" MaximumValue="999" MinimumValue="-100"
													Type="Double"></asp:RangeValidator>
											</td>
											<td align="right">
												Note: The value displayed under "Calculated Dose" may be rounded
												and / or Capped.
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr valign="top" height="34px">
								<td align="right">
									<div style="padding: 5px">
										<asp:Button ID="btnOk" CssClass="ICWButton" runat="server" Text="Ok" OnClick="btnOk_Click" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e) {}" />
										&nbsp;
										<asp:Button ID="btnCancel" CssClass="ICWButton" runat="server" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="False" onfocus="try{document.getElementById('__LASTFOCUS').value=this.id} catch(e) {}" />
									</div>
								</td>
							</tr>
						</table>
						<asp:XmlDataSource ID="XmlSource" runat="server" XPath="//rx" EnableCaching="False"
							EnableViewState="False"></asp:XmlDataSource>
					</ContentTemplate>
				</asp:UpdatePanel>
				</form>
			</td>
		</tr>
	</table>
</body>
</html>
