using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

/// <summary>
/// The result of the patient transfer
/// </summary>
public class PatientTransferResult
{
    /// <summary>
    /// Gets or sets a value indicating whether or not an error occurred.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Gets or sets the error details
    /// </summary>
    public string ErrorDetails { get; set; }
}

/// <summary>
/// Interface to the Patient Transfer Module
/// </summary>
[ServiceContract]
public interface IICWPatientTransferModule
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
	[OperationContract]
    PatientTransferResult Transfer(int sessionId, int episodeId, int transferDestinationId, string transferAddress, string transferCompleteRoutine, bool convertPrescriptionToTranscription, DateTime? transferDate);
}
