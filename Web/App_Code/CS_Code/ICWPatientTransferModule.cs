using System;
using System.Xml;
using ERXRTL10;

// NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "ICWPatientTransferModule" in code, svc and config file together.
public class ICWPatientTransferModule : IICWPatientTransferModule
{
    /// <summary>
    /// Transfer the episode
    /// </summary>
    /// <param name="sessionId">The session id</param>
    /// <param name="episodeId">The episode ID</param>
    /// <param name="transferDestinationId">The transfer Destination ID</param>
    /// <param name="transferAddress">The transfer Address</param>
    /// <param name="transferCompleteRoutine">The transfer Complete Routine</param>
    /// <param name="convertPrescriptionToTranscription">The convert Prescription To Transcription</param>
    /// <param name="transferDate">The transfer Date</param>
    public PatientTransferResult Transfer(
        int sessionId, 
        int episodeId, 
        int transferDestinationId, 
        string transferAddress,
        string transferCompleteRoutine, 
        bool convertPrescriptionToTranscription, 
        DateTime? transferDate)
    {
        var patientTransfer = new PatientTransfer();
        var transferResult = patientTransfer.Transfer(
            sessionId,
            episodeId,
            transferDestinationId,
            transferAddress,
            transferCompleteRoutine,
            convertPrescriptionToTranscription,
            transferDate);

        var result = new PatientTransferResult();
        var xmlDoc = new XmlDocument();
        xmlDoc.LoadXml(transferResult);
        var brokenRule = xmlDoc.GetElementsByTagName("Rule").Item(0);
        if (brokenRule != null)
        {
            result.Success = false;
            if (brokenRule.Attributes != null)
            {
                result.ErrorDetails = brokenRule.Attributes["Text"].Value;
            }
            else
            {
                result.ErrorDetails = "Unknown error occurred whilst calling PatientTransfer.Transfer";
            }
        }
        else
        {
            result.Success = true;
        }

        return result;
    }
}
