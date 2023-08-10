// -----------------------------------------------------------------------
// <copyright file="AmmLabel.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Display a label control in a popup for AMM
//
// page will return true if the print or reprint was performed
//
// The page expects the following URL parameters
// SessionID           - ICW session ID
// AscribeSiteNumber   - Site number
// SiteId          
// RequestID           - AMM Supply Request ID
// PrintMode           - Empty just displays the form P to print, R to reprint, T return label text
//
// Modification History:
// 04May16 XN  Created
// 08Aug16 XN  Fixed issue with reprints
// 19Aug16 XN  160567 got it to return true if labels were printed
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Web.UI;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.shared;
using System.Text;

public partial class application_aMMWorkflow_AmmLabel : System.Web.UI.Page
{
    /// <summary>Request id</summary>
    protected int RequestId;

    /// <summary>Request id prescription</summary>
    protected int requestId_Prescription;

    /// <summary>Request id dispensing</summary>
    protected int requestId_Dispensing;

    /// <summary>print mode</summary>
    protected string printMode;

    /// <summary>Number of labels</summary>
    protected int numberOfLabels;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        this.RequestId  = int.Parse(Request["RequestId"]);
        this.printMode  = this.Request["PrintMode"] ?? string.Empty;

        var processor = aMMProcessor.Create(this.RequestId);
        
        var supplyRequest           = processor.SupplyRequest;
        this.requestId_Prescription = supplyRequest.RequestID_Parent;
        this.requestId_Dispensing   = supplyRequest.RequestIdWLabel ?? 0;
        //this.numberOfLabels         = aMMProcessor.CalculateNumberOfSyringes(supplyRequest.VolumeOfInfusionInmL.Value) * (((int)supplyRequest.QuantityRequested.Value * formula.NumberOfLabels) + formula.ExtraLabels);
        this.numberOfLabels         = processor.CalculateNumberOfLabels();

        string script;
        switch (this.printMode.ToUpper())
        {
        case "R": 
            script = string.Format("setTimeout(function() {{ try {{ ReprintLabel({0}, {1}); }} finally {{ window.close(); }} }}, 1500);", this.RequestId, this.requestId_Dispensing);
            break;
        case "T":
            script = string.Format("setTimeout(function() {{ GetLabelText({0}, {1}, {2}); }}, 1500);", this.requestId_Prescription, this.RequestId, this.requestId_Dispensing);
            break;
        default:
            script = string.Format("setTimeout(function() {{ connectToDispensingCtrl({0}, {1}, {2}); }}, 1500);", this.requestId_Prescription, this.RequestId, this.requestId_Dispensing);
            break;
        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "connectLabelCtrl", script.ToString(), true);
    }
}