//===========================================================================
//
//						      PrescriptionMergeLoader.aspx.cs
//
//  On-demand loader that loads prescription table rows (TRs) for the parent DispensingPMR grid table.
//
//  Call the page with the follow parameters
//  SessionID                    - ICW session ID
//  RequestID_WPrescriptionMerge - Request ID of the merged item
//  RequestID_Dispensing         - request ID returned back to client
//  RepeatDispensing             - String to power the routine used, if rpt disp is enable
//  
//  Usage:
//  PrescriptionMergeLoader.aspx?SessionID=123&RequestID_WPrescriptionMerge=1325&RequestID_Dispensing=455
//
//  **********************************************************************************************
//  *                                                                                            *
//  * THIS IS THE OLD VERSION OF THE PMR AND YOU SHOULD NOT BE MAKING YOUR CHANGES HERE.         *
//  * FOR THE NEW PMR ALL THIS CODE NOW EXISTS IN THE DispensingPMR.aspx PROJECT                 *
//  *                                                                                            * 
//  **********************************************************************************************
//  
//	Modification History:
//	12Jul11 XN  Created
//  15Nov12 XN  Made obsolete as replaced by newer speedy version TFS47487
//  13Mar13 XN  59024 Memory Leak Fix
//===========================================================================
using System;
using LEGRTL10;
using ascribe.pharmacy.shared;

[Obsolete]
public partial class application_DispensingPMR_PrescriptionMergeLoader : System.Web.UI.Page
{
    #region Member variables
    /// <summary>Current session from request URL</summary>
    protected int sessionID;

    /// <summary>Selected prescription from request URL (normaly sent from Dispensing PMR)</summary>
    protected int requestID_WPrescriptionMerge;

    /// <summary>Selected prescription dispensing from request URL (normaly sent from Dispensing PMR)</summary>
    protected int requestID_Dispensing;

    /// <summary>Repeat Dispensing from request URL (normaly sent from Dispensing PMR)</summary>
    protected string RepeatDispensing;

    /// <summary>If pso enabled</summary>
    protected bool ifPSO = false;

    /// <summary>Holds the data read for the merged prescription</summary>
    protected System.Xml.XmlDocument xmldoc = new System.Xml.XmlDocument(); // protected DOMDocument xmldoc = new DOMDocument(); XN 13Mar13 59024 Memory Leak Fix
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionID                    = int.Parse(Request.QueryString["SessionID"]);
        requestID_WPrescriptionMerge = int.Parse(Request.QueryString["RequestID_WPrescriptionMerge"]);

        string temp = Request.QueryString["RequestID_Dispensing"];
        if (!string.IsNullOrEmpty(temp))
            requestID_Dispensing = int.Parse(temp);

        if (!string.IsNullOrEmpty(Request.QueryString["PSO"]))
            ifPSO = BoolExtensions.PharmacyParse(Request.QueryString["PSO"]);

        // Load data
        // If any changes are made to this sp you will also need to update sps
        //      pPrescriptionByEpisodeForDispensingRptDisp
        //      pPrescriptionByEpisodeForDispensing
        DispensingRead dispensingRead = new DispensingRead();
	string temp2 = Request.QueryString["RepeatDispensing"];
        if (temp2=="True")
        	xmldoc.LoadXml(dispensingRead.PrescriptionListByMergedPrescription(sessionID, requestID_WPrescriptionMerge, "PrescriptionListByMergedPrescriptionRptDisp_old"));
	else
            xmldoc.LoadXml(dispensingRead.PrescriptionListByMergedPrescription(sessionID, requestID_WPrescriptionMerge, "PrescriptionListByMergedPrescription_old"));
    }
}
