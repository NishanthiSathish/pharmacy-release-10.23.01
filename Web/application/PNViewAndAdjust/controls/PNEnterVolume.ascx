<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PNEnterVolume.ascx.cs" Inherits="application_PNViewAndAdjust_controls_PNEnterVolume" %>
<asp:Label ID="lbCaption" runat="server" Text="Label"></asp:Label><br />
<br />
<asp:Label runat="server" Text="Enter value: " /><asp:TextBox ID="tbValue" runat="server" style="text-align: right;" Width="75px" ></asp:TextBox>&nbsp;&nbsp;<asp:Label ID="tbOriginal" runat="server" Text="" /><br />
<asp:Label ID="lbValueError" runat="server" Text="&nbsp;" CssClass="ErrorMessage"></asp:Label>
<asp:HiddenField ID="hfmmolEntryType"                           runat="server" />
<asp:HiddenField ID="hfDosingWeightInKg"                        runat="server" />
<asp:HiddenField ID="hfSelectedIngredient"                      runat="server" />
<asp:HiddenField ID="hfWizardType"                              runat="server" />

<asp:HiddenField ID="hfSelectedProductPNCode"                   runat="server" />
<asp:HiddenField ID="hfTotalNotProvidedByOtherProducts"         runat="server" />

<asp:HiddenField ID="hfTotalGlucose"                            runat="server" />
<asp:HiddenField ID="hfTotalGlucoseProductVolume"               runat="server" />
<asp:HiddenField ID="hfTotalForIngredient"                      runat="server" />
