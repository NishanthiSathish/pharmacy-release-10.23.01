Attribute VB_Name = "modOrderCommsDefs"
Option Explicit

'Broken rule string keys.
Public Const SYSTEM_KEY = "OCS"
Public Const SUPPLIED_XML_INVALID = "XMLInvalid"
Public Const OCSITEM_NOT_FILLEDIN = "NotFilledIn"

'Broken rule codes
Public Const BR_DSS_ABORTED_SAVE = "DSS_SAVEABORTED"

'Order comms events
Public Enum OCSEventEnum
   ocsOnSelection = 10
   ocsOnCommit = 20
   ocsOnCommitPrescription = 30
   ocsOnDoseRangeCheck = 40
   ocsOnSaveResponse = 50
End Enum

'"special" Table names
Public Const TABLENAME_PRESCRIPTIONSTANDARD = "PrescriptionStandard"
Public Const TABLENAME_PRESCRIPTIONDOSELESS = "PrescriptionDoseless"
Public Const TABLENAME_PRESCRIPTIONINFUSION = "PrescriptionInfusion"

'Reason/Problem Capture functionality
Public Const XML_ELMT_REASON = "reasoncapture"
Public Const XML_ATTR_CAPTUREMODE = "mode"
Public Const XML_ATTR_REASONID = "reasonid"
Public Const XML_ATTR_REASONIDTEXT = "reasontext"
Public Const XML_ATTR_REASONTYPE = "type"
Public Const REASONTYPE_CLINICAL = "clinical"
Public Const REASONTYPE_NONCLINICAL = "nonclinical"

'Generic Attached Note functionality
Public Const XML_ELMT_ATTACHEDNOTES = "attachednotes"
Public Const XML_ELMT_ATTACHEDNOTE = "attachednote"
Public Const ATTACHEDNOTE_TYPE_DISPENSINGINSTRUCTION = "Dispensing Instruction"
Public Const ATTACHEDNOTE_TYPE_CHANGEREPORT = "Change Report"

'Date handling
Public Const XML_ATTR_DATEFORDISPLAY = "DisplayDate"

'Template Types
Public Const TEMPLATETYPE_OCS = "template"
Public Const TEMPLATETYPE_FORMULA_SIMPLE = "templateformula"

Public Const NOTE_TYPE_REASONCAPTURE = "Reason Note"

Public Function TableIsPrescription(ByRef SessionID As Long, _
                                    ByRef TableName As String) As Boolean

'Determine if the table represents a prescription.
'Currently this is a hard coded list.  Reading the table
'hierarchy is a more generic, but slower, solution.
'16Sep04 AE  Written

   Select Case UCase(TableName)
      Case UCase(TABLENAME_PRESCRIPTIONSTANDARD), UCase(TABLENAME_PRESCRIPTIONDOSELESS), UCase(TABLENAME_PRESCRIPTIONINFUSION)
         TableIsPrescription = True
         
      Case Else
         TableIsPrescription = False
   End Select

End Function

Public Function RequestTypeNameIsPrescription(ByRef SessionID As Long, _
                                              ByRef RequestTypeName As String) As Boolean

'Determine if the RequestTypeName represents a prescription.
'Currently this is a hard coded list.
'22Oct04 PH  Written

   Select Case UCase(RequestTypeName)
      Case "PRESCRIPTION", "DOSELESS PRESCRIPTION", "STANDARD PRESCRIPTION", "INFUSION PRESCRIPTION"
         RequestTypeNameIsPrescription = True
         
      Case Else
         RequestTypeNameIsPrescription = False
   End Select

End Function

 Public Function ResponseTypeNameIsAdministration(ByRef SessionID As Long, _
                                                   ByRef RequestTypeName As String) As Boolean
                                                   
'Determine if the RequestTypeName represents an Administration.
'Currently this is a hard coded list.
'22Oct04 PH  Written

   Select Case UCase(RequestTypeName)
      Case "PRESCRIPTION", "ADMINISTRATION DOSELESS", "ADMINISTRATION INFUSION", "ADMINISTRATION STANDARD", "ADMINISTRATION NONE"
         ResponseTypeNameIsAdministration = True
      
      Case Else
         ResponseTypeNameIsAdministration = False
   End Select

End Function
