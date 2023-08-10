// -----------------------------------------------------------------------
// <copyright file=".cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Used by report.js to return printer context information used by the 
// Ascribe vb6 print job (old school vb6 print method) 
// 
// Modification History:
// 03May16 XN  Created
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;
using System.Text;

/// <summary>
/// Summary description for WebService
/// </summary>
[WebService(Namespace = "http://ascribe.com/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[System.Web.Script.Services.ScriptService]
public class AscribeVB6PrintJobHelper : System.Web.Services.WebService 
{
    /// <summary>Printer info (used to pass data to the ascribe printer job)</summary>
    public struct PrintInfo
    {
        /// <summary>printer to use</summary>
        public string printer;

        /// <summary>Printer override settings</summary>
        public string overideSettings;
    }
    
    public AscribeVB6PrintJobHelper () 
    {
        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }


    /// <summary>
    /// Called to get the printer info 
    /// Will read the terminal specific printer settings for WConfiguration D|Terminal.{terminal} or D|Terminal.Default
    /// </summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="siteId">Site Id</param>
    /// <param name="context">Printer context to use from WConfiguration e.g. ManWkSheet</param>
    /// <returns>Printer info</returns>
    [WebMethod]
    public AscribeVB6PrintJobHelper.PrintInfo GetPrinter(int sessionId, int siteId, string context)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        // Get the printer
        string printer = WConfiguration.Load(siteId, "D|Terminal", SessionInfo.Terminal, context, string.Empty, false);
        if (string.IsNullOrWhiteSpace(printer))
            printer = WConfiguration.Load(siteId, "D|Terminal", "Default", context, string.Empty, false);

        // Get the section for the context
        string section = WConfiguration.Load(siteId, "D|Terminal", SessionInfo.Terminal, "Context" + context, string.Empty, false);
        if (string.IsNullOrWhiteSpace(printer))
            section = WConfiguration.Load(siteId, "D|Terminal", "Default", "Context" + context, context, false);
        section = "Context:" + section;

        StringBuilder overrideOptions = new StringBuilder();

        bool ciritrixOverride = WConfiguration.Load(siteId, "D|Terminal", SessionInfo.Terminal, "CitrixOverridePrinterPort", (bool?)null, false) ?? WConfiguration.Load(siteId, "D|Terminal", "Default", "CitrixOverridePrinterPort", false, false);
        if (ciritrixOverride)
            overrideOptions.Append("C|");

        // Get the orientation
        var orientation = WConfiguration.Load(siteId, "D|Terminal", section, "Orientation", string.Empty, false).SafeSubstring(0, 1).ToUpper();
        if ("LP".Contains(orientation))
            overrideOptions.Append(orientation);

        // Get the margin to use
        foreach (var attr in new[] { "Top", "Left", "Right", "Bottom" })
        {
            overrideOptions.Append("|");
            double margin;
            var value = WConfiguration.Load(siteId, "D|Terminal", section, "Margin" + attr, string.Empty, false);
            if (string.IsNullOrWhiteSpace(value))
                ;
            else if (value.EqualsNoCaseTrimEnd("physical") && (attr == "Top" || attr == "Left"))
                overrideOptions.Append("P");
            else if (double.TryParse(value, out margin))
                overrideOptions.Append(value);
        }

        // Returns the printer info
        return new PrintInfo() { printer         = printer,
                                 overideSettings = overrideOptions.ToString() };
    }
    
    /// <summary>Saves the printer back to  D|Terminal.{terminal}.{context}</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="siteId">Site Id</param>
    /// <param name="context">Printer context to use from WConfiguration e.g. ManWkSheet</param>
    /// <param name="printer">Printer name</param>
    [WebMethod]
    public void SetPrinter(int sessionId, int siteId, string context, string printer)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);
        WConfiguration.Save(siteId, "D|Terminal", SessionInfo.Terminal, context, printer, false);
    }    
}
