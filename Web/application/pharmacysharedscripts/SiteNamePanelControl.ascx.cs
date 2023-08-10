//===========================================================================
//
//					    SiteNamePanelControl.aspx.cs
//
//  Displays the pharmacy name on a web page.
//
//  Can be either
//      full name               - Site ({SiteName} {AccountName}) - {SiteNumber}
//      Local hospital name     - {LocalHospitalAbbreviation} - {SiteNumber}
//      Site number             - Site {SiteNumber}
//
//  Usage:
//  <%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx" tagname="SiteNamePanelControl" tagprefix="uc" %>
//  :
//  <div style="width: 50px;">
//      <uc:SiteNamePanelControl ID="siteColourPanel" runat="server" TextFormat=LocalHospitalName />
//  </div>
//
//	Modification History:
//	20Dec13 XN  78339 Created
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.shared;

public partial class SiteNamePanelControl : System.Web.UI.UserControl
{
    /// <summary>Text to display for site name</summary>
    public enum TextFormatType
    {
        FullName            = 0,
        LocalHospitalName   = 1,
        SiteNumberOnly      = 2
    }

    /// <summary>Site ID position (if null will use SessionInfo Site)</summary>
    public int? SiteID { get; set; }

    /// <summary>Format for the site text</summary>
    public TextFormatType TextFormat { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            // Load site data
            SiteProcessor siteProcessor = new SiteProcessor();
            Site site = siteProcessor.LoadBySiteID(this.SiteID ?? SessionInfo.SiteID);
            string name              = string.IsNullOrEmpty(site.FullName)                  ? site.AbbreviatedName : site.FullName;
            string localHospitalName = string.IsNullOrEmpty(site.LocalHospitalAbbreviation) ? site.AbbreviatedName : site.LocalHospitalAbbreviation;

            // Site name
            switch (this.TextFormat)
            {
            case TextFormatType.FullName:           panel.InnerHtml = string.Format("Site ({0} {1}) - {2:000}", name, site.AccountName, site.Number ); break;
            case TextFormatType.LocalHospitalName:  panel.InnerHtml = string.Format("{0} - {1:000}",            localHospitalName, site.Number      ); break;
            case TextFormatType.SiteNumberOnly:     panel.InnerHtml = string.Format("Site {0:000}",             site.Number                         ); break;
            }
        }
        catch (Exception ) {}   // Ignore parsing errors as not worht worrying about jusy for a colour
    }
}