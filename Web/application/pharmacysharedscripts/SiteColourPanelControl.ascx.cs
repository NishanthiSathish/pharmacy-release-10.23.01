//===========================================================================
//
//					    SiteColourPanelControl.aspx.cs
//
//  Displays the pharmacy colour panel on a web page.
//
//  Reads the current sites colour from WConfiguration setting
//  Category: D|SiteInfo
//  Section:
//  Key: StoresMenuBarColour
//
//  Usage:
//  <%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl" tagprefix="uc" %>
//  :
//  <div style="width: 50px;">
//      <uc:SiteColourPanelControl ID="siteColourPanel" runat="server" />
//  </div>
//
//	Modification History:
//	09Aug13 XN  24653 Created
//  18Dec13	XN	78339 Added option for colour panel with just site number
//  20Dec13 XN  78339 Made contorl color only moved name part to SiteNamePanel
//===========================================================================
using System;
using System.Drawing;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class SiteColourPanelControl : System.Web.UI.UserControl
{
    /// <summary>Site ID position 18Dec13 XN 78339</summary>
    public int? SiteID { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Set site colour
        try
        {
            string colourStr = WConfiguration.Load<string>(this.SiteID ?? SessionInfo.SiteID, "D|SiteInfo", string.Empty, "StoresMenuBarColour", string.Empty, false); 
            Color  colour    = ColorExtensions.FromVB6(colourStr);
            if (!colour.IsEmpty)
                panel.Style.Add(HtmlTextWriterStyle.BackgroundColor, colour.ToWebColorString());
        }
        catch (Exception ) {}   // Ignore parsing errors as not worht worrying about jusy for a colour
    }
}
