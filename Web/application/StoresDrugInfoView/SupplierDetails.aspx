<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SupplierDetails.aspx.cs" Inherits="application_StoresDrugInfoView_SupplierDetails" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "SupplierDetails.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Supplier Details<%= ascribe.pharmacy.shared.StringExtensions.Repeat("&nbsp;", 99) /* Remove web dialog text in title 24Jan17 */ %></title>
    <base target=_self>

    <script type="text/javascript" src="scripts/SupplierDetails.js"></script>    
	
	<link rel="stylesheet" type="text/css" href="../../style/application.css" />
	<link rel="stylesheet" type="text/css" href="../../style/StoresDrugInfoView.css" />
</head>
<body id="bdy" onkeydown="form_onkeydown(event)">
    <form id="form1" runat="server">
    <div>
        <table cellspacing="1" cellpadding="1" class="Border" frame="border">
	        <tr>
		        <td class="Heading" bgcolor="#EEEEEE"><b>Supplier Information</b></td>
	        </tr>
	        <tr valign="top">
		        <td>
			        <table cellspacing="1" cellpadding="1">
				        <tr>
					        <td width="150">Supplier Code</td>
					        <td><asp:TextBox ID="txtSupplierCode" runat="server" CssClass="FieldText" 
                                    Width="80px" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td width="150">Supplier Name</td>
					        <td><asp:TextBox ID="txtSupplierName" runat="server" CssClass="FieldText" 
                                    Width="300px" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td width="150">Cost Centre</td>
					        <td><asp:TextBox ID="txtCostCentre" runat="server" CssClass="FieldText" 
                                    Width="300px" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td width="150">Order Method</td>
					        <td><asp:TextBox ID="txtOrderMethod" runat="server" CssClass="FieldText" 
                                    Width="80px" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
                    </table>
                </td>
            </tr> 
            <tr>
                <td class="Heading" bgcolor="#EEEEEE"><b>Supplier Addresses</b></td>
            </tr>
	        <tr valign="top">
		        <td>
			        <table cellspacing="1" cellpadding="1">
			            <!-- Supplier address info -->
			            <tr>
			                <td style="vertical-align: middle;" width="80px">Supplier Address</td>
			                <td>
			                    <asp:TextBox ID="txtSupplierAddress" CssClass="FieldText" runat="server" ReadOnly="True" Wrap="False" Width="350px"></asp:TextBox>
			                    <table>
			                        <tr>
			                            <td width="10%">Phone</td>
			                            <td width="40%"><asp:TextBox ID="txtSupplierPhone" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                            <td style="padding-left: 8px" width="10%">Fax</td>
			                            <td width="40%"><asp:TextBox ID="txtSupplierFax" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                        </tr>
			                    </table>
			                </td>
			            </tr>
			            
			            <!-- Contract address info -->
			            <tr>
			                <td style="vertical-align: middle;" width="80px">Contract Address</td>
			                <td>
			                    <asp:TextBox ID="txtContractAddress" CssClass="FieldText" runat="server" ReadOnly="True" Wrap="False" Width="350px"></asp:TextBox>
			                    <table>
			                        <tr>
			                            <td width="10%">Phone</td>
			                            <td width="40%"><asp:TextBox ID="txtContractPhone" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                            <td style="padding-left: 8px" width="10%">Fax</td>
			                            <td width="40%"><asp:TextBox ID="txtContractFax" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                        </tr>
			                    </table>
			                </td>
			            </tr>
			            
			            <!-- Invoice address info -->
			            <tr>
			                <td style="vertical-align: middle;" width="80px">Invoice Address</td>
			                <td>
			                    <asp:TextBox ID="txtInvoiceAddress" CssClass="FieldText" runat="server" ReadOnly="True" Wrap="False" Width="350px"></asp:TextBox>
			                    <table>
			                        <tr>
			                            <td width="10%">Phone</td>
			                            <td width="40%"><asp:TextBox ID="txtInvoicePhone" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                            <td style="padding-left: 8px" width="10%">Fax</td>
			                            <td width="40%"><asp:TextBox ID="txtInvoiceFax" runat="server" CssClass="FieldText" ReadOnly="True"></asp:TextBox></td>
			                        </tr>
			                    </table>
			                </td>
			            </tr>
			        </table>
                </td>                                
            </tr>                            
            <tr>
                <td class="Heading" bgcolor="#EEEEEE"><b>Supplier's Item Information</b></td>
            </tr>
	        <tr valign="top">
		        <td>
			        <table cellspacing="1" cellpadding="1">
                        <colgroup>
                            <col style="width:130px" />
                            <col style="width:100px" />
                            <col style="width:25px"  />
                            <col style="width:65px"  />
                            <col style="width:100px" />
                        </colgroup>
				        <tr>
					        <td>NSV Code</td>
					        <td><asp:TextBox ID="txtNSVCode" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Supplier Tradename</td>
					        <td colspan="4"><asp:TextBox ID="txtSupplierTradename" runat="server" CssClass="FieldText" Width="99%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Contract No.</td>
					        <td colspan="4"><asp:TextBox ID="txtContractNo" runat="server" CssClass="FieldText" Width="99%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Contract Price</td>
					        <td><asp:TextBox ID="txtContractPrice" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Contract Start Date</td>
					        <td><asp:TextBox ID="txtContactStartDate" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
                            <td />
					        <td>End Date</td>
					        <td><asp:TextBox ID="txtContactEndDate" runat="server" CssClass="FieldText" Width="98%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Outer Size</td>
					        <td><asp:TextBox ID="txtOuterSize" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
                            <td />
					        <td><asp:Label ID="lblTaxRate" runat="server" Text="{0} Rate"></asp:Label></td>
					        <td><asp:TextBox ID="txtTaxRate" runat="server" CssClass="FieldText" Width="98%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Last Invoiced</td>
					        <td><asp:TextBox ID="txtLastInvoiced" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
                            <td />
					        <td>Last Paid</td>
					        <td><asp:TextBox ID="txtLastPaid" runat="server" CssClass="FieldText" Width="98%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>GTIN Code</td>
					        <td><asp:TextBox ID="txtGTIN" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Lead Time (days)</td>
					        <td><asp:TextBox ID="txtLeadTime" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
				        <tr>
					        <td>Supplier Reference No.</td>
					        <td><asp:TextBox ID="txtSupplierReference" runat="server" CssClass="FieldText" Width="100%" Wrap="False" ReadOnly="True"></asp:TextBox></td>
				        </tr>
                    </table>
                </td>
            </tr>    
        </table>        		
    </div>		 
    </form>
	<iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
