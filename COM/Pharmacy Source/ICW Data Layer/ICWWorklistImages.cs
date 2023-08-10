//===========================================================================
//
//					        ICWWorklistImages.cs
//
//  Used to determine icons to use in a worklist
//
//  This is a direct copy of Ascribe.Common.Constatns.GetImageByClass and GetTitleByClass
//  (which exists in overloard and ICW). At some point in the future this 
//  needs to use the standard ICW methods (after Merging has been done).
//
//	Modification History:
//	17Dec12 XN  Written (51136)
//===========================================================================
namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Used to determine icons to use in a worklist</summary>
    public static class ICWWorklistImages
    {
        public const string IMAGE_FOLDERCLOSED             = "classFolderClosed.gif";
        public const string IMAGE_SET                      = "classOrderSet.gif";
        public const string IMAGE_TEMPLATE                 = "classTemplate.gif";
        public const string IMAGE_REQUEST                  = "classRequest.gif";
        public const string IMAGE_RESPONSE                 = "classResponse.gif";
        public const string IMAGE_NOTE                     = "classNote.gif";
        public const string IMAGE_ATTACHEDNOTE             = "classAttachedNote.gif";
        public const string IMAGE_PATIENT                  = "classPatient.gif";
        public const string IMAGE_EPISODE                  = "classEpisode.gif";
        public const string IMAGE_PRESCRIPTION             = "classPrescription.gif";
        public const string IMAGE_INFUSION                 = "classPrescription_Infusion.gif";
        public const string IMAGE_ALLERGY                  = "classAllergy.gif";
        public const string IMAGE_INFO                     = "classInfo.gif";
        public const string IMAGE_PENDING                  = "classPending.gif";
        public const string IMAGE_UNKNOWN                  = "classUnknown.gif";
        public const string IMAGE_ADMINISTRATION           = "classAdmin.gif";
        public const string IMAGE_PRODUCT                  = "classProduct.gif";
        public const string IMAGE_GENERICORDER             = "classGenericOrder.gif";
        public const string IMAGE_GENERICPRESCRIPTION      = "classGenericPrescription.gif";
        public const string IMAGE_TRANSCRIPTION            = "classTranscription.gif";
        public const string IMAGE_VERBALORDER              = "classVerbalOrder.gif";
        public const string IMAGE_ONBEHALFOF               = "classOnBehalfOf.gif";
        public const string IMAGE_PGDHOMELY                = "classPGDHomely.gif";
        public const string IMAGE_PGDPREPACK               = "classPGDPrePack.gif";
        public const string IMAGE_SUPPLEMENTARYPRESCRIPTION= "classSupplementaryPrescription.gif";
        public const string IMAGE_SUPPLYREQUEST            = "classSupplyRequest.png";
        public const string IMAGE_PRESCRIPTIONMERGE        = "classPrescriptionMerge.gif";

        // Changes for the Free text prescriptions
		public const string TITLE_GENERICORDER          = "FreeText Order";
        public const string TITLE_GENERICPRESCRIPTION   = "FreeText Prescription";
        public const string TITLE_PRESCRIPTIONMERGE     = "This is a merged prescription.";

        /// <summary>
        /// Given an item type, returns the correct image name to use.
        /// This is a direct copy of Ascribe.Common.Constatns.GetImageByClass (which exists in overloard and ICW)
        /// At some point in the future this needs to use the standard ICW methods (after Merging has been done)
        /// </summary>
        /// <param name="className">String containing one of "Request", "Response", "Note", "Patient"</param>
        /// <param name="requestType">Optional; string containing the request, response or note type description.</param>
        /// <param name="noteType">Optional; string containing the note type</param>
        /// <param name="creationType">Request creation type</param>
        /// <returns>string containing the image name</returns>
        public static string GetImageByClass(string className, string requestType, string noteType, string creationType)
        {
            string Image = null;

            // Determine special items which we wish to give separate icons to
            switch (className.ToLower())
            {
            case "request":
            case "planneditem":
                if (!string.IsNullOrEmpty(requestType))
                {
                    switch (requestType.ToLower())
                    {
                    case "standard prescription":
                    case "doseless prescription":
                    case "product order":
                        switch (creationType.ToLower())
                        {
                        case "transcription":               Image = IMAGE_TRANSCRIPTION;             break;
                        case "verbal order":                Image = IMAGE_VERBALORDER;               break;
                        case "on behalf of":                Image = IMAGE_ONBEHALFOF;                break;
                        case "homely remedy":               Image = IMAGE_PGDHOMELY;                 break;
                        case "pre pack":                    Image = IMAGE_PGDPREPACK;                break;
                        case "supplementary prescription":  Image = IMAGE_SUPPLEMENTARYPRESCRIPTION; break;
                        default:                            Image = IMAGE_PRESCRIPTION;              break;
                        }
                        break;
                    case "infusion prescription":
                        switch (creationType.ToLower())
                        {
                        case "transcription":               Image = IMAGE_TRANSCRIPTION;                break;
                        case "verbal order":                Image = IMAGE_VERBALORDER;                  break;
                        case "on behalf of":                Image = IMAGE_ONBEHALFOF;                   break;
                        case "homely remedy":               Image = IMAGE_PGDHOMELY;                    break;
                        case "pre pack":                    Image = IMAGE_PGDPREPACK;                   break;
                        case "supplementary prescription":  Image = IMAGE_SUPPLEMENTARYPRESCRIPTION;    break;
                        default:                            Image = IMAGE_INFUSION;                     break;
                        }
                        break;
                    case "drug administration": 
                    case "infusion administration": 
                    case "doseless administration":
                        Image = IMAGE_ADMINISTRATION;
                        break;
                    case "order set": 
                    case "administration session order set": 
                    case "cycled order set":
                        Image = IMAGE_SET;
                        break;
                    case "generic order":
                        Image = IMAGE_GENERICORDER;
                        break;
                    case "generic prescription":
                        Image = IMAGE_GENERICPRESCRIPTION;
                        break;
                    case "prescription merge":
                        Image = IMAGE_PRESCRIPTIONMERGE;
                        break;
                    default:
                        Image = IMAGE_REQUEST;
                        break;
                    }
                }
                else if (!string.IsNullOrEmpty(noteType))
                    Image = IMAGE_NOTE;
                break;                    
            case "response"         : Image = IMAGE_RESPONSE;       break;
            case "note"             : Image = IMAGE_NOTE;           break;
            case "orderset"         : Image = IMAGE_SET;            break;
            case "ordersetinstance" : Image = IMAGE_SET;            break;
            case "folder"           : Image = IMAGE_FOLDERCLOSED;   break;    
            case "patient"          : Image = IMAGE_PATIENT;        break;
            case "episode"          : Image = IMAGE_EPISODE;        break;
            case "template"         : Image = IMAGE_TEMPLATE;       break;
            case "prescription"     : Image = IMAGE_PRESCRIPTION;   break;
            case "attached note"    : Image = IMAGE_ATTACHEDNOTE;   break;
            case "allergy"          : Image = IMAGE_ALLERGY;        break;
            case "entity"           : Image = IMAGE_PATIENT;        break;
            case "pending"          : Image = IMAGE_PENDING;        break;
            case "product"          : Image = IMAGE_PRODUCT;        break;
            case "supplyrequest"    : Image = IMAGE_SUPPLYREQUEST;  break;
            default                 : Image = IMAGE_UNKNOWN;        break;
            }

            return Image;
        }

        /// <summary>
        /// Given an item type, returns the correct title to use (for the image).
        /// This is a direct copy of Ascribe.Common.Constatns.GetTitleByClass (which exists in overloard and ICW)
        /// At some point in the future this needs to use the standard ICW methods (after Merging has been done)
        /// </summary>
        /// <param name="className">String containing one of "Request", "Response", "Note", "Patient"</param>
        /// <param name="requestType">Optional; string containing the request, response or note type description.</param>
        /// <returns>string containing the title</returns>
		public static string GetImageTitleByClass(string className, string requestType)
        {
			string title = string.Empty;

			switch (className.ToLower())
            {
			case "request":
                switch (requestType.ToLower())
                {
                case "generic prescription": title = TITLE_GENERICPRESCRIPTION; break;
				case "generic order":        title = TITLE_GENERICORDER;        break;
                case "prescription merge":   title = TITLE_PRESCRIPTIONMERGE;   break;
			    }
            break;
            }

			return title;
        }
    }
}
