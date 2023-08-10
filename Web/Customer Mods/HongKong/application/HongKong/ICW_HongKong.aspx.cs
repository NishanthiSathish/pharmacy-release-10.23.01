// -----------------------------------------------------------------------
// <copyright file="ICW_HongKong.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Custom functions for Hong Kong
// Has two main function
// 1. Provide a custom button event handler, for the patient editor, so user can store 
//    Chinese name other parts 
// 2. Performs the flow control of creating prescription, regimens, and supply request 
//    from PMS
//
//  Has desktop parameters
//  AscribeSiteNumber - Optional only for the workflow
//
// Modification History:
// 18Nov15 XN  Created 133905
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;

public partial class application_HongKong_ICW_HongKong : System.Web.UI.Page
{
    /// <summary>Current patient episode id</summary>
    protected int episodeId;

    /// <summary>If the user can edit regimens</summary>
    public bool canEditRegimen;

    /// <summary>Current mode from PMS</summary>
    protected string mode;

    /// <summary>Called when page is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        // Ascribe site number is optional as might be used in patient editor (without site number)
        if (this.Request.QueryString.AllKeys.Contains("AscribeSiteNumber"))
            SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
        else
            SessionInfo.InitialiseSession(this.Request);

        // Most of the parameters come from state or SessionAttribute
        this.episodeId      = SessionInfo.GetStatePKByTable("Episode").Value;
        this.mode           = SessionInfo.GetAttribute<string>("RequestAlias/Mode", string.Empty);
        this.canEditRegimen = SessionInfo.HasAnyPolicies(PNUtils.Policy.Editor);

        if (!this.IsPostBack)
        {
            try
            {
                switch (this.mode.ToUpper())
                {
                case "N":   // New prescription
                    {
                    // Check if the PMS PN Id already exists in the DB in which case then error
                    string pmsPnId = ExternalPrescriptionID();
                    if (GetRegimenFromExternalPrescriptionID(pmsPnId) != null)
                    {
                        throw new ApplicationException("Regimen has already been created for this PMS PN Id");
                    }

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "StartNewPresciptionWizard", "NewPresciptionWizard();", true);
                    }
                    break;
                case "M":   // Modifying existing regimen
                    {
                    // Load the supply request from the PMS PN ID
                    string pmsPnId = ExternalPrescriptionID();
                    PNRegimenRow regimen = GetRegimenFromExternalPrescriptionID(pmsPnId);
                    if (regimen == null)
                    {
                        throw new ApplicationException("No PN regimen exists for PMS PN Id " + pmsPnId);
                    }
                    else if (regimen.EpisodeID != this.episodeId)
                    {
                        throw new ApplicationException("PN regimen with PMS PN Id " + pmsPnId + " is not valid for this patients episode");
                    }

                    string script = string.Format("ModifyRegimenWizard({0}, '{1}');", regimen.RequestID, regimen.PNAuthorised || regimen.IsCancelled() ? "C" : "E");
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "StartModifyRegimenWizard", script, true);
                    }
                    break;
                case "S":   // New supply request
                    {
                    // Check if the PMS PN Id already exists in the DB in which case then error
                    string pmsPnId = ExternalPrescriptionID();
                    if (GetRegimenFromExternalPrescriptionID(pmsPnId) != null)
                    {
                        throw new ApplicationException("Regimen has already been created for this PMS PN Id");
                    }

                    PNRegimenRow regimen = null;
                    string existingPmsPnId = ExistingPrescriptionID();
                    if (!string.IsNullOrEmpty(existingPmsPnId))
                    {
                        regimen = GetRegimenFromExternalPrescriptionID(existingPmsPnId);
                        if (regimen == null)
                        {
                            throw new ApplicationException("PN regimen with PMS PN Id " + pmsPnId + " does not exist");
                        }
                        else if (regimen.EpisodeID != this.episodeId)
                        {
                            throw new ApplicationException("PN regimen with PMS PN Id " + pmsPnId + " is not valid for this patients episode");
                        }
                    }

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "StartNewSupplyRequestWizard", string.Format("NewSupplyRequestWizard({0});", regimen == null ? "undefined" : regimen.RequestID.ToString()), true);
                    }
                    break;
                case "V":   // Viewing supply request
                    {
                    // Load the supply request from the PMS PN ID
                    string pmsPnId = ExternalPrescriptionID();
                    PNRegimenRow regimen = GetRegimenFromExternalPrescriptionID(pmsPnId);
                    if (regimen == null)
                    {
                        throw new ApplicationException("No PN regimen exists for PMS PN Id " + pmsPnId);
                    }
                    else if (regimen.EpisodeID != this.episodeId)
                    {
                        throw new ApplicationException("PN regimen with PMS PN Id " + pmsPnId + " is not valid for this patients episode");
                    }

                    ClearSessionAttributeRequestAliases(SessionInfo.SessionID);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "StartViewRegimenWizard", string.Format("ViewRegimenWizard({0});", regimen.RequestID), true);
                    }
                    break;
                }
            }
            catch (ApplicationException ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "errorMsg", string.Format("alert('{0}');", ex.Message.JavaStringEscape("'")), true);
                ClearSessionAttributeRequestAliases(SessionInfo.SessionID);
            }
        }
    }

    /// <summary>Returns the PMS PN ID from the SessionAttribute RequestAlias/ExternalPrescriptionID</summary>
    /// <returns>External Prescription ID</returns>
    private string ExternalPrescriptionID()
    {
        string externalPrescriptionID = SessionInfo.GetAttribute("RequestAlias/ExternalPrescriptionID", string.Empty);
        if (string.IsNullOrEmpty(externalPrescriptionID))
        {
            throw new ApplicationException("External Prescription ID has not been set");
        }

        return externalPrescriptionID;
    }

    /// <summary>Returns the PMS PN ID from the SessionAttribute RequestAlias/ExistingPrescriptionID</summary>
    /// <returns>Existing Prescription ID</returns>
    private string ExistingPrescriptionID()
    {
        return SessionInfo.GetAttribute("RequestAlias/ExistingExternalPrescriptionID", string.Empty);
    }

    /// <summary>Returns the regimen with the Pms Pn Id</summary>
    /// <returns>regiemn for this externial id</returns>
    private PNRegimenRow GetRegimenFromExternalPrescriptionID(string externalPrescriptionID)
    {
        PNRegimen regimen = new PNRegimen();
        int? requestId = regimen.GetPKByAlias("ExternalPrescriptionID", externalPrescriptionID);
        if (requestId != null)
        {
            regimen.LoadByRequestID(requestId.Value);
        }

        return regimen.FirstOrDefault();
    }

    /// <summary>Returns if the regimen has been authorised</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="requestId">request Id</param>
    /// <returns></returns>
    [WebMethod]
    public static bool IsRegimenAuthorised(int sessionId, int requestId)
    {
        SessionInfo.InitialiseSession(sessionId);

        PNRegimen regimen = new PNRegimen();
        regimen.LoadByRequestID(requestId);
        return regimen.Count == 1 && regimen[0].PNAuthorised;
    }

    /// <summary>
    /// Copies all session attributes that start with RequestAlias/ to the request alias (and removes the session attributes)
    /// if requestId_ToCopyFrom is set will remove the ExternalPrescriptionID
    /// </summary>
    /// <param name="sessionId">session id</param>
    /// <param name="requestId">request id to copy request alias to </param>
    /// <param name="requestId_ToCopyFrom">request id where ExternalPrescriptionID is to be removed</param>
    [WebMethod]
    public static void UpdateAttributeRequestAliases(int sessionId, int requestId, int? requestId_ToCopyFrom)
    {
        SessionInfo.InitialiseSession(sessionId);

        ascribe.pharmacy.icwdatalayer.Request request = new ascribe.pharmacy.icwdatalayer.Request();

        // Get all session attributes that start with RequestAlias/
        IDictionary<string,string> attributes = SessionInfo.GetAllAttributes().Where(a => a.Key.StartsWith("RequestAlias/")).ToDictionary(a => a.Key.Split('/')[1], a => a.Value);

        // Delete the SessionAttributes
        ClearSessionAttributeRequestAliases(sessionId);

        // Remove the old alias
        if (requestId_ToCopyFrom != null)
        {
            request.RemoveAlias("ExternalPrescriptionID", attributes["ExternalPrescriptionID"]);
        }

        // Add the request aliases
        foreach(var attr in attributes)
        {
            if (ICWTypes.GetTypeByDescription(ICWType.AliasGroup, attr.Key) != null)
            {
                request.RemoveAllAliasByAliasGroup(requestId, attr.Key);
                request.AddAlias(requestId, attr.Key, attr.Value, true);
            }
        }
    }

    [WebMethod]
    public static void CancelRegimenAndSupplyRequest(int sessionId, int requestId_Regimen)
    {
        SessionInfo.InitialiseSession(sessionId);

        int discontinuationReasonId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 DiscontinuationReasonID FROM DiscontinuationReason WHERE Code='pnedit'");
        
        PNRegimen regimen = new PNRegimen();
        regimen.LoadByRequestID(requestId_Regimen);
        regimen[0].Cancel(discontinuationReasonId, string.Empty, true);
    }

    /// <summary>Removes all SessionAttribute where key start with 'RequestAlias/'</summary>
    /// <param name="sessionId">Session Id</param>
    [WebMethod]
    public static void ClearSessionAttributeRequestAliases(int sessionId)
    {
        SessionInfo.InitialiseSession(sessionId);
        Database.ExecuteSQLNonQuery("DELETE FROM SessionAttribute WHERE SessionID={0} AND Attribute Like 'RequestAlias/%'", sessionId);
    }
}