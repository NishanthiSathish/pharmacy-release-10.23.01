//===========================================================================
//
//					        AsymmetricProcessor.cs
//
//  Business processor class used to validate a prescription suitability for
//  prescription linking and splitting.
//
//  The class contains the following public methods:
//  IfSuitablePrescription - Will test a prescriptions suitability for prescription 
//                           matching and splitting
//  CanLink                - Tests if prescription can be prescription linking 
//                           All prescriptions passed to this method must of 
//                           passed to IfSuitablePrescription method first
//
//  DB Storage
//  Linked prescription are stored under WPrescriptionMerge as a 'Prescription Merge' request
//  type, with each lined item stored as WPrescriptionMergeItem (Active flag set to true)
//  When linked prescriptions are removed cancels the normal WPrescriptionMerge request, 
//  and sets the (Active flag to false) for all.
//
//  Usage:
//  For linking prescription linking
//
//  1. Create asymmetric candidate from prescriptions
//  AsymmetricCandidate ac1 = new AsymmetricCandidate()
//  ac1.RequestID     = dbPrescription.RequestID
//  ac1.RequestTypeID = dbPrescription.RequestTypeID
//  :
//  ac1.StopDate      = dbPrescription.EndDate
//  
//  AsymmetricCandidate ac2 = new AsymmetricCandidate()
//  ac2.RequestID     = dbPrescription.RequestID
//  ac2.RequestTypeID = dbPrescription.RequestTypeID
//  :
//  ac2.StopDate      = dbPrescription.EndDate
//  
//  2. Test candidates are a suitable prescription
//  AsymmetricProcessor processor = new AsymmetricProcessor();
//  string errorMsg;
//  if (!processor.IfSuitablePrescription(ac1, out errorMsg) || !processor.IfSuitablePrescription(ac2, out errorMsg))
//      throw new ApplicationException("Not suitable prescription: " + errorMsg);
//  
//  3. Test can link prescription
//  if (!processor.CanLink(ac2, new AsymmetricCandidate[]{ ac1 }, out errorMsg))
//      throw new ApplicationException("Not suitable prescription: " + errorMsg);
//
//  4. Save
//  processor.SaveLink(new AsymmetricCandidate[]{ ac1, ac2 });
//
//	Modification History:
//	24Jul11 XN  Written (F0041502)
//  15Jul11 XN  Added IndexOrder to WPrescriptMergeItem table
//  25Aug11 XN  11644 Order prescriptions are merged
//  04Nov11 XN  TFS 18576 Added filtering out repeat dispensing items
//  09Nov11 XN  TFS 18938 Only include start date in prescription sorting if it has a durration
//  20Apr12 XN  TFS 32370 Allow linking of prescriptions where start and end times are the same
//              Also fixed RemoveLink so gets cancellation NoteType rather than Request
//  20Apr12 XN  TFS 32378 Factored in checking for RxReason and RxPatientReason when doing linking
//  06Mar15 XN  Added AsymmetricCandidate.TimeSlotCount and AsymmetricCandidate.FirstTimeSlotInSecs
//              added check that suitable prescription have less than max number of time slots
//              Fixed TestNotReachedMaxAllowedScheduledSlot to check only items that don't have does range
//  16Jun15 XN  Replaced decimal with double for dose (due to changes in Prescription) 39882
//  10Sep15 TH  Added custom frequency check for potential links (TFS 128207)
//  15Sep15 TH  Mod to ensure complex description uses form in an unduplicated way (TFS 129200)
//  15Sep15 XN  Added product form check, and enable infusion dispensing (TFS 129200)
//  12Oct15/24Sep15/25Sep15 TH  Added checks on primary ingredient and number of ingredients (TFS 130104)
//  01Dec15 XN  Single does appears a start, if\when at end 136911
//===========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;

namespace ascribe.pharmacy.asymmetricdosing
{
    /// <summary>Info on possible asymmetric prescription</summary>
    public struct AsymmetricCandidate
    {
        private string rxReason;        // Used for caching the data
        private string rxPatientReason;

        public int RequestID;

        public int RequestTypeID;
        public int ProductID;
        public int ProductTypeID;
        public int ProductRouteID;

        public DateTime  StartDate;
        public DateTime? StopDate;

        public int ScheduleID;
        public int TimeSlotCount;
        public int FirstTimeSlotInSecs;

        public double Dose;
        public double DoseLow;

        public int?   ArbTextID_Direction;
        public string DirectionText;
		public int? ProductFormId;  // Added 15Sep15 XN 129200
        public int? Ingredient_ProductID;  // Added 24Sep15 TH 130104
        public bool IfWhenRequired;     // Added 01Dec15 XN  136911
        public bool SingleDose;         // Added 01Dec15 XN  136911

        public bool HasDoseRange { get { return (DoseLow > 0); } }

        public bool HasDateRange { get { return StopDate.HasValue; } }


        /// <summary>
        /// Converts AsymmetricCandidate to a string in form
        /// requestid: {RequestID}; ... stopdate: 21/05/2011
        /// </summary>
        /// <param name="includeDirectionText">If include direction text in output string (generally set to false)</param>
        /// <returns>Returns AsymmetricCandidate to a string</returns>
        public string Marshal(bool includeDirectionText)
        {
            StringBuilder str = new StringBuilder();

            str.AppendFormat("requestid: {0};",             RequestID                       );
            str.AppendFormat("requesttypeid: {0};",         RequestTypeID                   );
            str.AppendFormat("productid: {0};",             ProductID                       );
            str.AppendFormat("producttypeid: {0};",         ProductTypeID                   );
            str.AppendFormat("productrouteid: {0};",        ProductRouteID                  );
            str.AppendFormat("arbtextid_direction: {0};",   ArbTextID_Direction             );
            str.AppendFormat("dose: {0:0.######};",         Dose                            );
            str.AppendFormat("doselow: {0:0.######};",      DoseLow                         );
            str.AppendFormat("startdate: {0};",             StartDate.ToPharmacyDateString());
            str.AppendFormat("stopdate: {0};",              StopDate.ToPharmacyDateString() );
            str.AppendFormat("scheduleid: {0};",            ScheduleID                      );
            str.AppendFormat("timeslotcount: {0};",         TimeSlotCount                   );
            str.AppendFormat("firsttimeslotinsecs: {0};",   FirstTimeSlotInSecs             );
			str.AppendFormat("productformid: {0};", 		ProductFormId					);  // Added 15Sep15 XN 129200
            str.AppendFormat("ingredient_productid: {0};",  Ingredient_ProductID            );  // Added 24Sep15 TH 130104
            str.AppendFormat("ifwhenrequired: {0};",        IfWhenRequired                  );  // Added 01Dec15 XN  136911
            str.AppendFormat("singledose: {0};",            SingleDose                      );  // Added 01Dec15 XN  136911

            if (includeDirectionText)
                str.AppendFormat("directiontext: {0};", DirectionText);

            return str.ToString();
        }

        /// <summary>
        /// Parses the string returned from ToString. 
        /// Should be in the form
        /// requestid: {RequestID}; ... stopdate: 21/05/2011
        /// </summary>
        /// <param name="value">string to parse</param>
        /// <returns>AsymmetricCandidate value</returns>
        public static AsymmetricCandidate Parse(string value)
        {
            // split the string into a map of variable name to value (as string)
            string[] variables = value.Split(new char[]{';'}, StringSplitOptions.RemoveEmptyEntries);
            IDictionary<string,string> map = variables.Select(s => s.Split(':')).ToDictionary(s => s[0].ToLower().Trim(), s => s[1].Trim());

            // Parse into AsymmetricCandidate struct
            AsymmetricCandidate result = new AsymmetricCandidate();
            result.RequestID            = int.Parse(map["requestid"]);
            result.RequestTypeID        = int.Parse(map["requesttypeid"]);
            result.ProductID            = int.Parse(map["productid"]);
            result.ProductTypeID        = int.Parse(map["producttypeid"]);
            result.ProductRouteID       = int.Parse(map["productrouteid"]);
            result.ArbTextID_Direction  = string.IsNullOrEmpty(map["arbtextid_direction"]) ? (int?)null : int.Parse(map["arbtextid_direction"]);
            result.Dose                 = double.Parse(map["dose"]);
            result.DoseLow              = double.Parse(map["doselow"]);
            result.StartDate            = DateTimeExtensions.PharmacyParse(map["startdate"]).Value;
            result.StopDate             = DateTimeExtensions.PharmacyParse(map["stopdate"]);
            result.ScheduleID           = int.Parse(map["scheduleid"]);
            result.TimeSlotCount        = int.Parse(map["timeslotcount"]);
            result.FirstTimeSlotInSecs  = int.Parse(map["firsttimeslotinsecs"]);
			result.ProductFormId		= string.IsNullOrEmpty(map["productformid"]) ? (int?)null : int.Parse(map["productformid"]);    // Added 15Sep15 XN 129200
            result.Ingredient_ProductID = string.IsNullOrEmpty(map["ingredient_productid"]) ? (int?)null : int.Parse(map["ingredient_productid"]);    // Added 24Sep15 TH 130104
            result.IfWhenRequired       = BoolExtensions.PharmacyParse(map["ifwhenrequired"]);  // Added 01Dec15 XN  136911
            result.SingleDose           = BoolExtensions.PharmacyParse(map["singledose"]);      // Added 01Dec15 XN  136911

            if (map.ContainsKey("directiontext"))
                result.DirectionText = map["directiontext"];

            return result;
        }

        /// <summary>Returns the RxReason read from the db (TFS32378 20Apr12 XN)</summary>
        public string GetRXReason()
        {
            if (this.rxReason == null)
                this.rxReason = Database.ExecuteSQLScalar<string>("SELECT icwsys.fPharmacyGetRxReasonbyRequestID({0})", this.RequestID) ?? string.Empty;

            return this.rxReason;
        }

        /// <summary>Returns the RxPatientReason read from the db (TFS32378 20Apr12 XN)</summary>
        public string GetRXPatientReason()
        {
            if (this.rxPatientReason == null)
                this.rxPatientReason = Database.ExecuteSQLScalar<string>("SELECT icwsys.fPharmacyGetRxPatientReasonbyRequestID({0})", this.RequestID) ?? string.Empty;

            return this.rxPatientReason;
        }

        /// <summary>Returns the number of linked inredients</summary>
        /// <param name="PrescriptionID">ID of prescription record.</param>
        /// <returns>Number of ingredient rows associated with that Prescription</returns>
        public int GetNumberofIngredientsByPrescriptionID()
        {
            return Database.ExecuteSQLScalar<int>("SELECT count(IngredientID) FROM Ingredient WHERE RequestID={0}", this.RequestID);
        }
    }

    /// <summary>Used to process asymmetric prescriptions</summary>
    public class AsymmetricProcessor
    {
        #region Member Variables
        /// <summary>Request type of a standard prescription</summary>
        private int standardPrescriptionRequestTypeID;

        /// <summary>Request type of a doesless prescription</summary>
        private int doselessPrescriptionRequestTypeID;

        /// <summary>Request type of an infusion prescription 16Sep15 XN 129200</summary>
        private int infusionPrescriptionRequestTypeID;

        /// <summary>map of specific product to it's family</summary>
        private Dictionary<int, HashSet<int>> productFamilyMap = new Dictionary<int, HashSet<int>>();        
        #endregion

        public AsymmetricProcessor()
        {
            standardPrescriptionRequestTypeID = ICWTypes.GetTypeByDescription(ICWType.Request, "Standard Prescription").Value.ID;
            doselessPrescriptionRequestTypeID = ICWTypes.GetTypeByDescription(ICWType.Request, "Doseless Prescription").Value.ID;
            infusionPrescriptionRequestTypeID = ICWTypes.GetTypeByDescription(ICWType.Request, "Infusion Prescription").Value.ID;   //  16Sep15 XN 129200
        }

        /// <summary>
        /// Returns if the candidate is suitable for prescription linking, or splitting
        /// 1. Is standard, doesless, or infusion prescription
        /// 2. Prescription does not have a dose range
        /// 3. If prescription is already in a linked prescription
        /// 4. If prescription is in a repeat dispensing
        /// 5. If prescription has RxReason and not allowing merging with RxReasons (if initialPrescription is true) (TFS32378 20Apr12 XN)
        /// 6. If prescription has less than max number of time slots
        /// 7. If infusion prescription check it has an allowed route
        /// </summary>
        /// <param name="candidate">candidate to test</param>
        /// <param name="error">Error message if not suitable</param>
        /// <param name="initialPrescription">If this is the orginal prescription</param>
        /// <returns>If suitable prescription</returns>
        public bool IfSuitablePrescription(AsymmetricCandidate candidate, bool initialPrescription, out string error)
        {
            error = string.Empty;

            if (!TestPrescriptionType(candidate, ref error))
                return false;
            if (!TestNotPrescriptionWithDoseRanges(candidate, ref error))
                return false;
            if (!TestInfusionSuitableMatchingRoute(candidate, ref error))   // 16Sep15 XN 129200
                return false;
            if (!TestIfCurrentlyPrescriptionLinkedItem(candidate, ref error))
                return false;
            if (!TestIfCurrentlyInRepeatDispensing(candidate, ref error))
                return false;
            if (initialPrescription && !TestIfAllowedRxReason(candidate, ref error))    // TFS32378 20Apr12 XN Added RxReason test
                return false;
            if (!TestIfAboveAllowedScheduledSlot(candidate, ref error))
                return false;
            return true;
        }

        /// <summary>
        /// Returns if newCandidate can be added to existing asymmetrically linked items, testing
        /// 1. If reached max number of items allowed in a link
        /// 2. Has matching routes to existing items
        /// 3. Dates do not overlap with existing items
        /// 4. If product is on same branch in the product family as existing candidates
        /// 5. has matching direction codes
        /// 6. has max allowed slot count (only if initialTest is false)
        /// 7. if has RxReason and not allowing merging with RxReasons (TFS32378 20Apr12 XN)
        /// 8. if allow merging with RxReason, and reason match        (TFS32378 20Apr12 XN)
        /// 9. if has custom frequency and candidate does not or vice-versa (TFS 128207 10Sep15 TH)
        /// 10. if primary ingredient does not match (TFS 130101 24Sep15 TH) 
        /// 11. test if product form matches (129200 15Sep15 XN)
        /// </summary>
        /// <param name="newCandidate">new item to test for linking</param>
        /// <param name="existingCandidates">existing asymmetrically linked items</param>
        /// <param name="initialTest">If this is the initial test of valid prescriptions rather than the actual link (removes some tests)</param>
        /// <param name="error">Error message if can't link</param>
        /// <returns>If can link</returns>
        public bool CanLink(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, bool initialTest, out string error)
        {
            error = string.Empty;

            if (!TestPrescriptionTypeMatch(newCandidate, existingCandidates.First(), ref error))
                return false;
            if (!TestDirectionCodesMatch(newCandidate, existingCandidates.First(), ref error))
                return false;
            if (!TestDatesDontOverlap(newCandidate, existingCandidates, ref error))
                return false;
            if (!TestHaveMatchingRoutes(newCandidate, existingCandidates.First(), ref error))
                return false;
            if (!TestSingleRequired(newCandidate, existingCandidates, ref error))   // Added 01Dec15 XN  136911
                return false;
            if (!TestSingleStatDose(newCandidate, existingCandidates, ref error))   // Added 01Dec15 XN  136911
                return false;
            if (!TestNotReachedMaxAllowedLinks(newCandidate, existingCandidates, ref error))
                return false;
			if (!TestProductForm(newCandidate, existingCandidates.First(), ref error))  // Added test 15Sep15 XN 129200
                return false;
            if (!TestProductFamily(newCandidate, existingCandidates, ref error))
                return false;
            if (!initialTest && !TestNotReachedMaxAllowedScheduledSlot(newCandidate, existingCandidates, ref error))
                return false;
            if (initialTest && !TestIfAllowedRxReason(newCandidate, ref error))    // This check only really needed first time but done here as slow, so do as last test TFS32378 20Apr12 XN
                return false;
            if (!TestIfRxReasonsMatch(newCandidate, existingCandidates, ref error)) // TFS32378 20Apr12 XN Added RxReason test
                return false;
            //10Sep15 TH Added custom frequency check (TFS 128207) 
            if (!TestIfCustomFrequencyMatch(newCandidate, existingCandidates.First(), ref error))
                return false;
            //24Sep15 TH Added primary ingredient check (TFS 130101) 
            if (!TestPrimaryIngredientsMatch(newCandidate, existingCandidates.First(), ref error))
                return false;
            //25Sep15 TH Added primary ingredient check (TFS 130101) 
            if (!TestNumberofIngredientsMatch(newCandidate, existingCandidates.First(), ref error))
                return false;
            

            TestDoseRange(newCandidate, existingCandidates, ref error);

            return true;
        }

        /// <summary>
        /// Saves the presciption linked items to the db
        ///     Creates a new 'Prescription Merge' request type
        ///     Add request to WPrescriptionMerge
        ///     Adds reach line of request to WPrescriptionMergeItem
        /// </summary>
        /// <param name="existingCandidates">items to link</param>
        /// <returns>ID of the </returns>
        public int SaveLink(int episodeID, IEnumerable<AsymmetricCandidate> existingCandidates)
        {
            int count = existingCandidates.Count();
            int requestID;

            // Get the WPrescriptionMerge request type, and table type
            ICWTypeData asymmetricLinkRequestType = ICWTypes.GetTypeByDescription(ICWType.Request, "Prescription Merge").Value;

            // Organize the prescriptions in schedule time order
            existingCandidates = OrderPrescriptions(existingCandidates);

            // Generate the prescription description
            string description = CreateLinkedPrescriptionDescription(existingCandidates);

            // Check that no prescription have been linked by anyone else
            if (existingCandidates.Any(c => WPrescriptionMergeItem.IsMergedPrescription(c.RequestID)))
                throw new ApplicationException("One of the prescriptions in the list has already been merged by another user.");
                
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Generate the request (using old vb xml code)
                string dataXML = "<data filledin='1'></data>";
                OCSRTL10.OrderCommsItem orderCommsItem = new OCSRTL10.OrderCommsItem();
                string requestIDStr = orderCommsItem.CreateEpisodeRequest(SessionInfo.SessionID, 0, SessionInfo.EntityID, SessionInfo.EntityID, asymmetricLinkRequestType.TableID.Value, asymmetricLinkRequestType.ID, 0, episodeID, description, 0, 0, 0, 0, 0, 0, false, dataXML, false, 0, new List<string>());
                if (!int.TryParse(requestIDStr, out requestID))
                    throw new ApplicationException(requestIDStr);

                // Save each prescription to the request type
                WPrescriptionMergeItem item = new WPrescriptionMergeItem();
                for (int c = 0; c < count; c++)
                {
                    WPrescriptionMergeItemRow newRow = item.Add();
                    newRow.RequestID_Prescription       = existingCandidates.ElementAt(c).RequestID;
                    newRow.RequestID_WPrescriptionMerge = requestID;
                    newRow.IndexOrder                   = c;
                    newRow.Active                       = true;
                }

                item.Save();
                trans.Commit();
            }

            return requestID;
        }

        /// <summary>Remove and existing prescription link</summary>
        /// <param name="requestID">Requet id of the prescription link</param>
        public void RemoveLink(int requestID)
        {
            // Get table and request id for canceled noted type
            ICWTypeData noteTypeData = ICWTypes.GetTypeByDescription(ICWType.Note, "Request Cancellation").Value;

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                // Cancel the request
                string dataXML = string.Format("<save><item tableid='{0}' ocstypeid='{1}'><data><attribute name='cancelrequestid' value='{2}'/><attribute name='DiscontinuationReasonID' value='0'/></data></item></save>", noteTypeData.TableID, noteTypeData.ID, requestID);
                OCSRTL10.OrderCommsItem orderCommsItem = new OCSRTL10.OrderCommsItem();
                orderCommsItem.CancelBatch(SessionInfo.SessionID, dataXML);

                // Cancel the prescription merge
                WPrescriptionMergeItem.Deativate(requestID);
                trans.Commit();
            }
        }

        /// <summary>check if valid prescription type (standard, doesless or infusion)</summary>
        /// <param name="test">item to test</param>
        /// <param name="error">error message (set if test failed)</param>
        /// <returns>If test passed</returns>
        private bool TestPrescriptionType(AsymmetricCandidate test, ref string error)
        {
            bool ok = true;

            if (test.RequestTypeID != standardPrescriptionRequestTypeID && test.RequestTypeID != doselessPrescriptionRequestTypeID && test.RequestTypeID != infusionPrescriptionRequestTypeID)  // Added doseless 16Sep15 XN 129200
            {
                error = "Incorrect prescription type, only valid for Standard, Doseless, and Infusion prescriptions";
                ok = false;            
            }

            return ok;
        }


        /// <summary>check if valid prescription type matches existing ones</summary>
        private bool TestPrescriptionTypeMatch(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;

            if (test.RequestTypeID != requestedPrescription.RequestTypeID)
            {
                error = "Prescription type does not match selected prescription.";
                ok = false;            
            }

            return ok;
        }

        /// <summary>check prescription does not have a dose range</summary>
        private bool TestNotPrescriptionWithDoseRanges(AsymmetricCandidate test, ref string error)
        {
            bool ok = true;

            if (test.HasDoseRange)
            {
                error = "Not allowed for prescriptions with range of doses.";
                ok = false;            
            }

            return ok;
        }

        /// <summary>Test if the prescription is currently in a prescription merge</summary>
        private bool TestIfCurrentlyPrescriptionLinkedItem(AsymmetricCandidate test, ref string error)
        {
            bool ok = true;

            if (WPrescriptionMergeItem.IsMergedPrescription(test.RequestID))
            {
                error = "Prescription is already in a link.";
                ok = false;
            }

            return ok;
        }

        /// <summary>Test if the prescription is currently in a repeat dispensing</summary>
        private bool TestIfCurrentlyInRepeatDispensing(AsymmetricCandidate test, ref string error)
        {
            bool ok = true;

            if (RDRxLinkDispensing.IsPrescriptionInLinkedDispensing(test.RequestID, false))
            {
                error = "Prescription is part of a repeat dispensing.";
                ok = false;
            }

            return ok;
        }

        /// <summary>check if routes match existing items</summary>
        private bool TestHaveMatchingRoutes(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;

            if (test.ProductRouteID != requestedPrescription.ProductRouteID)
            {
                error = "Does not match selected prescription's route.";
                ok = false;
            }

            return ok;
        }

        /// <summary>Test that there is only one single does item 01Dec15 XN 136911</summary>
        /// <param name="newCandidate">New candidate to add to the list</param>
        /// <param name="existingCandidates">List of existing items</param>
        /// <param name="error">If returns false the error message</param>
        /// <returns>If candidate is okay to add</returns>
        private bool TestSingleStatDose(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            bool ok = true;
            if (newCandidate.SingleDose && existingCandidates.Any(c => c.SingleDose))
            {
                error = "Only allowed one single dose item.";
                ok = false; 
            }
            return ok;
        }

        /// <summary>Test that there is only one If\when required item 01Dec15 XN 136911</summary>
        /// <param name="newCandidate">New candidate to add to the list</param>
        /// <param name="existingCandidates">List of existing items</param>
        /// <param name="error">If returns false the error message</param>
        /// <returns>If candidate is okay to add</returns>
        private bool TestSingleRequired(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            bool ok = true;
            if (newCandidate.IfWhenRequired && existingCandidates.Any(c => c.IfWhenRequired))
            {
                error = "Only allowed one If\\When required item.";
                ok = false; 
            }
            return ok;
        }

        /// <summary>If item is an infusion prescription the check that route is in the allowed list of routes 16Sep15 XN 129200</summary>
        /// <param name="test">item to test</param>
        /// <param name="error">error message (set if test failed)</param>
        /// <returns>If test passed</returns>
        private bool TestInfusionSuitableMatchingRoute(AsymmetricCandidate test, ref string error)
        {
            bool ok = true;

            if (test.RequestTypeID == this.infusionPrescriptionRequestTypeID && !AsymmetricSettings.AllowedInfusionRoutes.Contains(test.ProductRouteID))
            {
                error = "Not a suitable infusion route.";
                ok = false;
            }

            return ok;
        }

        /// <summary>check if match direction codes and text</summary>
        private bool TestDirectionCodesMatch(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;

            string testDirectionText                  = test.DirectionText                  ?? string.Empty;    // Treat nulls and empty direction text as same
            string requestedPrescriptionDirectionText = requestedPrescription.DirectionText ?? string.Empty;

            if ((test.ArbTextID_Direction != requestedPrescription.ArbTextID_Direction) || !testDirectionText.EqualsNoCaseTrimEnd(requestedPrescriptionDirectionText))
            {
                error = "Direction text does not match.";
                ok = false;
            }

            return ok;
        }

        //10Sep15 TH Added custom frequency check (TFS 128207)
        /// <summary>check if All custom frequency or all none custom frequency</summary>
        private bool TestIfCustomFrequencyMatch(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;

            //here we are going to have to load the schedule so we can interrogate the template of it (Custom freq have schedule with no template
            if (test.ScheduleID != 0 && requestedPrescription.ScheduleID != 0) //Should all have a schedule ?? Else caught by other rules ?
            {
                ScheduleTemplateBody testscheduleTemplateBody = new ScheduleTemplateBody();
                testscheduleTemplateBody.LoadByScheduleID(test.ScheduleID);
                ScheduleTemplateBody requestedPrescriptionscheduleTemplateBody = new ScheduleTemplateBody();
                requestedPrescriptionscheduleTemplateBody.LoadByScheduleID(requestedPrescription.ScheduleID);
                if ((testscheduleTemplateBody.Any() && !requestedPrescriptionscheduleTemplateBody.Any()) ||(!testscheduleTemplateBody.Any() && requestedPrescriptionscheduleTemplateBody.Any()))
                {    
                    error = "Cannot match custom and none custom frequencies.";
                       ok = false;
                }
            }
            return ok;
        }

        /// <summary>
        /// Test have not reached max number of linked prescriptions
        /// Defined by setting 
        ///     System: Pharmacy
        ///     Section:PrescriptionMerge
        ///     Key:    MaxLinkedItems
        /// </summary>
        private bool TestNotReachedMaxAllowedLinks(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            bool ok = true;

            if (existingCandidates.Count() >= AsymmetricSettings.MaxLinkedItems)
            {
                error = "Maximum number of linked items is " + AsymmetricSettings.MaxLinkedItems.ToString();
                ok = false;
            }

            return ok;
        }
		
        /// <summary>
        /// Test if the product forms match
        /// Defined by setting 
        ///     System: Pharmacy
        ///     Section:PrescriptionMerge
        ///     Key:    AllowLinkingIfProductFormDoesNotMatch
		///	Also following setting determines if allowed to link product forms that are null to ones that are set
        ///     System: Pharmacy
        ///     Section:PrescriptionMerge
        ///     Key:    AllowLinkingEmptyAndNonEmptyProductForm
        /// 15Sep15 XN 129200
        /// </summary>		
		private bool TestProductForm(AsymmetricCandidate newCandidate, AsymmetricCandidate requestedPrescription, ref string error)
		{
            bool ok = true;

			if (!AsymmetricSettings.AllowLinkingIfProductFormDoesNotMatch)
			{
				if (AsymmetricSettings.AllowLinkingEmptyAndNonEmptyProductForm)
				{
					ok = newCandidate.ProductFormId == requestedPrescription.ProductFormId || newCandidate.ProductFormId == null || requestedPrescription.ProductFormId == null;
				}
				else
				{
					ok = newCandidate.ProductFormId == requestedPrescription.ProductFormId;
				}
			}
			
			if (!ok)
			{
				error = "Does not match selected prescription's form.";;
			}
			
            return ok;
		}

        /// <summary>check that dates don't overlap</summary>
        private bool TestDatesDontOverlap(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            bool ok = true;

            if (newCandidate.HasDateRange && AsymmetricSettings.TestPrescriptionConsecutaiveStartStopDates &&
                //existingCandidates.Any(c => c.HasDateRange && DateTimeExtensions.Overlap(c.StartDate.ToStartOfDay(), c.StopDate.Value.ToStartOfDay(), newCandidate.StartDate.ToStartOfDay(), newCandidate.StopDate.Value.ToStartOfDay(), true)))  TFS32370 20Apr12 XN Allow linking of prescriptions where start and end times are the same 
                existingCandidates.Any(c => c.HasDateRange && DateTimeExtensions.Overlap(c.StartDate.ToStartOfDay(), c.StopDate.Value.ToStartOfDay(), newCandidate.StartDate.ToStartOfDay(), newCandidate.StopDate.Value.ToStartOfDay(), AsymmetricSettings.PreventLinkIfStartAndEndTimesOverlap)))
            {
                error = "Time range overlaps with existing prescription.";
                ok = false;
            }

            return ok;
        }

        //24Sep15 TH Added primary ingredient check (TFS 130101)
        /// <summary>check that primary ingredients match</summary>
        private bool TestPrimaryIngredientsMatch(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;
            
            ok = (test.Ingredient_ProductID == requestedPrescription.Ingredient_ProductID);
            if (!ok)
            {
                error = "Primary ingredients do not match.";
            }
            
            return ok;
        }

        //24Sep15 TH Added primary ingredient check (TFS 130101)
        /// <summary>check that number ingredients match</summary>
        private bool TestNumberofIngredientsMatch(AsymmetricCandidate test, AsymmetricCandidate requestedPrescription, ref string error)
        {
            bool ok = true;
            
            if (test.GetNumberofIngredientsByPrescriptionID() != requestedPrescription.GetNumberofIngredientsByPrescriptionID())
            {
                error = "Ingredients do not match.";
                ok = false;
            }

            return ok;
        }

        /// <summary>Warns if new item is not 10 greater than any existing item (should not preven the link from occuring)</summary>
        private void TestDoseRange(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            int rangeWarningMulti = AsymmetricSettings.RangeWarningMultiplier;
            if (rangeWarningMulti <= 0)
                return;
            
            if (newCandidate.RequestTypeID != standardPrescriptionRequestTypeID)
                return;

            IEnumerable<AsymmetricCandidate> standardPrescriptions = existingCandidates.Where(c => c.RequestTypeID == standardPrescriptionRequestTypeID);

            double smallestDoes = standardPrescriptions.Min(c => c.Dose);
            if ((newCandidate.Dose * rangeWarningMulti) < smallestDoes)
                error = string.Format("Does is x{0} smaller than existing prescriptions.", rangeWarningMulti);

            double largestDoes = standardPrescriptions.Max(c => c.Dose);
            if (newCandidate.Dose > (largestDoes * rangeWarningMulti))
                error = string.Format("Does is x{0} larger than existing prescriptions.", rangeWarningMulti);
        }

        /// <summary>
        /// Test have not reached max number of dosing slots 
        /// Defined by setting 
        ///     System: Pharmacy
        ///     Section:PrescriptionMerge
        ///     Key:    MaxScheduledSlots
        /// Only tests items that do not have a time range, as item in time range that do overlap can't be linked
        /// How we do have to check where a NON time range prescription occurs in a prescription that does have a time range
        /// </summary>
        private bool TestNotReachedMaxAllowedScheduledSlot(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            int maxScheduledSlots = AsymmetricSettings.MaxScheduledSlots;
            
            // Get all items that have a time range
            List<AsymmetricCandidate> dateRangeItems = existingCandidates.Where(c => c.HasDateRange).ToList();
            if (newCandidate.HasDateRange)
            {
                dateRangeItems.Add(newCandidate);
            }

            // Get items that do not have a time range
            // Get dictionary of date prescription occurs on, and the total time slot count for that data
            IDictionary<DateTime, int> singleDateItemWithTimeSlots = existingCandidates.Where(c => !c.HasDateRange)
                                                                                       .GroupBy(c => c.StartDate.ToStartOfDay())
                                                                                       .ToDictionary(gc => gc.Key, gc => gc.Sum(c => c.TimeSlotCount));
            if (!newCandidate.HasDateRange)
            {
                // Add new candidate to list if does not have time range
                DateTime startDate = newCandidate.StartDate.ToStartOfDay();
                int slots = newCandidate.TimeSlotCount;
                if (singleDateItemWithTimeSlots.ContainsKey(startDate))
                {
                    slots += singleDateItemWithTimeSlots[startDate];
                }

                singleDateItemWithTimeSlots[startDate] = slots;
            }

            // To the single items time slot counts, add time slots of all items that have a date range
            foreach (var sdi in singleDateItemWithTimeSlots.ToList())   // Use ToList as may modify list during iteration
            {                
                foreach (var dri in dateRangeItems)
                {
                    if (DateTimeExtensions.Overlap(sdi.Key, sdi.Key, dri.StartDate.ToStartOfDay(), dri.StopDate.Value.ToEndOfDay(), true))
                    {
                        singleDateItemWithTimeSlots[sdi.Key] += dri.TimeSlotCount;
                    }
                }
            }

            // now look for any items that are over the 6 slot max
            if (singleDateItemWithTimeSlots.Any(s => s.Value > maxScheduledSlots)) 
            {
                error = "Maximum number of scheduled slots is " + maxScheduledSlots;
                return false;
            }

            return true;
        }

        /// <summary>
        /// Test if new candidate is on same product family as all existing items
        /// e.g.
        ///                     PC1                 - Chemical
        ///                      |
        ///                     PT1*                - TM
        ///                     / \
        ///                    /   \
        ///                   /     \ 
        ///              PAMP1       PAMP2*         - AMP
        ///               /  \        /  \
        ///              /    \      /    \
        ///          PAMPP1 PAMPP2 PAMPP3 PAMPP4    - AMPP
        ///          
        /// If list of existing items includes PT1, and PAMP2, then if new candidate is
        /// PC1    - method returns true
        /// PT1    - method returns true
        /// PAMP1  - method returns false
        /// PAMPP1 - method returns false
        /// PAMPP3 - method returns true
        /// </summary>
        private bool TestProductFamily(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            // Returns the product type that is lowest in the family tree.
            int maxProductTypeID = existingCandidates.Max(p => p.ProductTypeID);
            if (maxProductTypeID == -1)
                throw new ApplicationException("Invalid list of existing asymmetric candidates");

            // Iterate through the product types, and test the new candidate aginst the product tree
            // Only need to process the ones at the bottom of the tree as this filters out all others (prevents too many calls to db)
            foreach (AsymmetricCandidate existingItem in existingCandidates.Where(p => p.ProductTypeID == maxProductTypeID))
            {
                HashSet<int> productFamily = GetProductFamily(existingItem.ProductID);
                if (!productFamily.Contains(newCandidate.ProductID))
                {
                    error = "Not in same product family branch.";
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Test if candidate has an RxReason then depending on setting 
        /// System:  Pharmacy
        /// Section: PrescriptionMerge
        /// Key:     AllowMatchingRxReasons
        /// Will either allow or disallow the prescription
        /// 
        /// Will also apply this rule to RxPatientReason, based on following setting
        /// System:  Pharmacy
        /// Section: PrescriptionMerge
        /// Key:     IncludeRxPatientReasonCheck
        /// 
        /// TFS32378 20Apr12 XN
        /// </summary>
        private bool TestIfAllowedRxReason(AsymmetricCandidate test, ref string error)
        {
            if (!AsymmetricSettings.AllowMatchingRxReasons && !string.IsNullOrEmpty(test.GetRXReason()))
            {
                error = "Has a prescription reason";
                return false;
            }

            if (AsymmetricSettings.IncludeRxPatientReasonCheck && !AsymmetricSettings.AllowMatchingRxReasons && !string.IsNullOrEmpty(test.GetRXPatientReason()))
            {
                error = "Has a prescription reason";
                return false;
            }

            return true;
        }

        /// <summary>
        /// Test the candidate does not exceeded maximum number of time slots
        /// Defined by setting 
        ///     System: Pharmacy
        ///     Section:PrescriptionMerge
        ///     Key:    MaxScheduledSlots
        ///     Value:  default 6
        /// At this stage the application assumes that the number of TimeSlotCount field is not filled in (so will load from DB)
        /// </summary>
        /// <param name="candidate">candidate for asymmetric dosing</param>
        /// <param name="error">error</param>
        /// <returns>If suitable</returns>
        private bool TestIfAboveAllowedScheduledSlot(AsymmetricCandidate candidate, ref string error)
        {
            ScheduleTemplateBody scheduleTemplateBody = new ScheduleTemplateBody();
            scheduleTemplateBody.LoadByScheduleID(candidate.ScheduleID);

            if (scheduleTemplateBody.Any() && 
                scheduleTemplateBody.CalculateDailyTimeSlots(scheduleTemplateBody[0].ScheduleTemplateID) > AsymmetricSettings.MaxScheduledSlots)
            {
                error = "Maximum number of scheduled slots is " + AsymmetricSettings.MaxScheduledSlots;
                return false;                
            }

            return true;
        }


        /// <summary>
        /// Test if Rx reasons match, also depends on settings
        /// System:  Pharmacy
        /// Section: PrescriptionMerge
        /// Key:     AllowLinkingEmptyAndNonEmptyRxReasons
        /// If true then can match prescriptions if 1 is empty and the other is not empty
        /// 
        /// and tests RxPatientReason on setting
        /// System:  Pharmacy
        /// Section: PrescriptionMerge
        /// Key:     IncludeRxPatientReasonCheck
        /// 
        /// TFS32378 20Apr12 XN
        /// </summary>
        private bool TestIfRxReasonsMatch(AsymmetricCandidate newCandidate, IEnumerable<AsymmetricCandidate> existingCandidates, ref string error)
        {
            // If not merging then skip test (RxReason are checked by TestIfAllowedRxReason)
            if (!AsymmetricSettings.AllowMatchingRxReasons)
                return true;

            bool ok = true;

            // Get the eixsting RxReason (if any existing candidate has one)
            IEnumerable<AsymmetricCandidate> existringCandidatesWithRxReasons = existingCandidates.Where(c => c.GetRXReason() != string.Empty);
            string existingRxReason = existringCandidatesWithRxReasons.Any() ? existringCandidatesWithRxReasons.First().GetRXReason() : string.Empty;
            string newRxReason      = newCandidate.GetRXReason();

            // Text if prescription reasons match
            if (AsymmetricSettings.AllowLinkingEmptyAndNonEmptyRxReasons)
                ok = string.IsNullOrEmpty(newRxReason) || string.IsNullOrEmpty(existingRxReason) || existingRxReason.EqualsNoCaseTrimEnd(newRxReason);
            else
                ok = existingRxReason.EqualsNoCaseTrimEnd(newRxReason);

            // Repeat test of RxPatientReason
            if (ok && AsymmetricSettings.IncludeRxPatientReasonCheck)
            {
                // Get the eixsting RxPatientReason (if any existing candidate has one)
                IEnumerable<AsymmetricCandidate> existringCandidatesWithRxPatientReasons = existingCandidates.Where(c => c.GetRXPatientReason() != string.Empty);
                string existingRxPatientReason = existringCandidatesWithRxPatientReasons.Any() ? existringCandidatesWithRxPatientReasons.First().GetRXPatientReason() : string.Empty;
                string newRxPatientReason      = newCandidate.GetRXPatientReason();

                // Text if prescription reasons match
                if (AsymmetricSettings.AllowLinkingEmptyAndNonEmptyRxReasons)
                    ok = string.IsNullOrEmpty(newRxPatientReason) || string.IsNullOrEmpty(existingRxPatientReason) || existingRxPatientReason.EqualsNoCaseTrimEnd(newRxPatientReason);
                else
                    ok = existingRxPatientReason.EqualsNoCaseTrimEnd(newRxPatientReason);
            }

            if (!ok)
            {
                error = "Prescription reason don't match";
                return false;
            }

            return true;
        }

        /// <summary>
        /// Loads the return the product family (parents, and all children)
        ///                     PC1                 - Chemical
        ///                      |
        ///                     PT1                 - TM
        ///                     / \
        ///                    /   \
        ///                   /     \ 
        ///              PAMP1       PAMP2          - AMP
        ///               /  \        /  \
        ///              /    \      /    \
        ///          PAMPP1 PAMPP2 PAMPP3 PAMPP4    - AMPP
        ///          
        /// So if pass in ID for PAMP2 will return PC1, PT1, PAMP2, PAMPP3, PAMPP4
        /// </summary>
        /// <param name="productID">Product ID</param>
        /// <returns>List of product family ids</returns>
        private HashSet<int> GetProductFamily(int productID)
        {
            // Load product family from db if not already done so
            if (!productFamilyMap.ContainsKey(productID))
            {
                List<int> productFamily = new List<int>();

                // Load all parents
                ProductFamily productFamilyParent = new ProductFamily();
                productFamilyParent.LoadByRelatedProduct(productID);
                productFamily.AddRange(productFamilyParent.Select(pf => pf.ProductID));

                // Load all children
                ProductFamily productFamilyChild = new ProductFamily();
                productFamilyChild.LoadByProduct(productID);
                productFamily.AddRange(productFamilyChild.Select(pf => pf.RelatedProductID));

                // Save to map
                this.productFamilyMap.Add(productID, new HashSet<int>(productFamily.Distinct()));
            }

            // Return value
            return productFamilyMap[productID];
        }

        /// <summary>
        /// Creates the new linked prescription description this is roughly in the form
        /// for standard prescriptions
        ///     {Product description lowest of AMP or AMPP}: {route} {does1} {frequ1}, {does2} {frequ2}, ..., {direction text}
        /// for doesless prescriptions    
        ///     {Product description lowest of AMP or AMPP}: : {direction} {route} {frequ1}, {frequ2}, ..
        /// </summary>
        /// <param name="prescriptions">Prescription to link</param>
        /// <returns>linked prescription description</returns>
        private string CreateLinkedPrescriptionDescription(IEnumerable<AsymmetricCandidate> prescriptions)
        {
            Request requests = new Request();
            Dictionary<int,string> productNameMap         = new Dictionary<int,string>();
            List<string>           requestDescriptionList = new List<string>();

            DSSDTL10.ProductRead productDTL = new DSSDTL10.ProductRead();
            DSSRTL20.ProductRead productRTL = new DSSRTL20.ProductRead();
            ProductForm ProductForm = new ProductForm();

            // Get the lowest (AMP, or AMPP)
            AsymmetricCandidate basePrescription = prescriptions.OrderByDescending(p => p.ProductTypeID).First();

            // Load the product route text
            if (basePrescription.ProductRouteID == 0)
                throw new ApplicationException("Invalid product route ProductRouteID=0");
            string xml = productRTL.ProductRouteByID(SessionInfo.SessionID, basePrescription.ProductRouteID);
            string productRouteName = XDocument.Parse(xml).Descendants("ProductRoute").First().Attribute("Description").Value;

            // Get the direction text
            string directionText = string.Empty;
            if (basePrescription.ArbTextID_Direction.HasValue && (basePrescription.ArbTextID_Direction.Value > 0))
            {
                OCSRTL10.ArbitraryTextRead arbTextReader = new OCSRTL10.ArbitraryTextRead();
                xml = arbTextReader.GetTextByID(SessionInfo.SessionID, basePrescription.ArbTextID_Direction.Value);
                directionText = XDocument.Parse(xml).Descendants("ArbText").First().Attribute("Detail").Value;
            }

            // Get the form description
            string FormText = string.Empty;
            if (standardPrescriptionRequestTypeID == basePrescription.RequestTypeID)
            {
                FormText = ProductForm.GetDescriptionByRequestID(basePrescription.RequestID);
            }

            // Go through each prescription an remove the common items
            //  product name
            //  route
            //  direction text
            foreach (AsymmetricCandidate prescription in prescriptions)
            {
                // Get request description
                requests.LoadByRequestID(prescription.RequestID);
                StringBuilder description = new StringBuilder(requests[0].Description);

                // Get the prescriptions product name (from the DB)
                // caches to map (in-case there are duplicates in list of prescriptions saves reloading it)
                if (!productNameMap.ContainsKey(prescription.ProductID))
                    productNameMap[prescription.ProductID] = productDTL.ProductDefaultName(SessionInfo.SessionID, prescription.ProductID);

                // Remove the first occurrence of the product description from the string
                description.Replace(productNameMap[prescription.ProductID], string.Empty, 1);

                //Standard then possibly remove Form (updated after code review 129700)
                if (!string.IsNullOrEmpty(FormText))
                {
                    description.Replace(FormText, string.Empty, 1);
                }

                // Remove any space or ':' chars
                while (description[0] == ' ')
                    description.Remove(0, 1);
                if (description[0] == ':')
                    description.Remove(0, 1);
                while (description[0] == ' ')
                    description.Remove(0, 1);
                
                // Replace the first occurrence of the product route name
                if (!string.IsNullOrEmpty(productRouteName))
                    description.Replace(productRouteName, string.Empty, 1);

                // Replace the last occurrence of the product direction text
                if (!string.IsNullOrEmpty(directionText))
                    description.ReplaceLast(directionText, string.Empty, 1);

                // Replace double spaces
                while (description.ToString().Contains("  "))
                    description.Replace("  ", " ");

                // Store the single request description (but only if it does not already exist)
                string str = description.ToString().Trim();
                if (!requestDescriptionList.Contains(str))
                    requestDescriptionList.Add(str);
            }

            // Rebuild new description 
            StringBuilder newDescription = new StringBuilder();

            if (doselessPrescriptionRequestTypeID == basePrescription.RequestTypeID)
            {
                // doesloess prescription is in form {Product}: {direction} {route} {frequency1}, {frequency2}, ..
                newDescription.AppendFormat("{0}:", productNameMap[basePrescription.ProductID]);
                if (!string.IsNullOrEmpty(directionText))
                    newDescription.Append(" " + directionText);
                newDescription.AppendFormat(" {0} {1}", productRouteName, requestDescriptionList.ToCSVString(", "));
            }
            else
            {
                // standard prescription is in form {Product} {Form}: {route} {dose1}{unit1} {frequency1}, {dose2}{unit2} {frequency2}, .. {direction}
                if (FormText.Length > 0)
                    FormText = (" " + FormText);
                newDescription.AppendFormat("{0}{1}: {2} {3}", productNameMap[basePrescription.ProductID],FormText, productRouteName, requestDescriptionList.ToCSVString(", "));
                if (!string.IsNullOrEmpty(directionText))
                    newDescription.Append(", " + directionText);
            }

            return newDescription.ToString();
        }

        /// <summary>
        /// Orders the prescriptions 
        /// If prescription has schedule range
        ///     Single dose items 
        ///     start time of prescription
        ///     time of first schedule (e.g. morning, or evening)
        ///     dose
        ///     when required
        ///     
        /// else just by
        ///     Single dose items 
        ///     time of first schedule (e.g. morning, or evening)
        ///     dose
        ///     when required
        ///     
        /// so will return prescriptions in the order
        ///     1.25mg Once a day in the morning
        ///     10mg   Once a day in the morning
        ///     2.5mg  Once a day in the evening
        ///     7.5mg  Once a day at bedtime
        ///     10mg   Once a day at bedtime
        /// 1Dec15 XN 136911 added single does items a start, and when required at end
        /// </summary>
        private IEnumerable<AsymmetricCandidate> OrderPrescriptions(IEnumerable<AsymmetricCandidate> prescriptions)
        {
            List<KeyValuePair<TimeSpan,AsymmetricCandidate>> scheduleTimeToPrescription = new List<KeyValuePair<TimeSpan,AsymmetricCandidate>>();
            ScheduleTemplateBody scheduleTemplateBody = new ScheduleTemplateBody();

            // Create list of first daily schedule time of a prescription (e.g. morning, evening) (filter out if\when required and single dose)
            foreach (AsymmetricCandidate p in prescriptions)
            {
                // Get the start time load
                TimeSpan startTime = new TimeSpan(24, 0, 0);
                if (p.ScheduleID != 0)
                {
                    scheduleTemplateBody.LoadByScheduleID(p.ScheduleID);
                    if (scheduleTemplateBody.Any())
                        startTime = scheduleTemplateBody.OrderBy(t => t.DailyFrequencyStartTime).First().DailyFrequencyStartTime;
                }

                // Add item to list with start time
                scheduleTimeToPrescription.Add(new KeyValuePair<TimeSpan,AsymmetricCandidate>(startTime, p));
            }

            // Order items 1Dec15 XN 136911 added Single does goes at beginning 
            if (scheduleTimeToPrescription.Any(p => p.Value.StopDate.HasValue))
                return (from p in scheduleTimeToPrescription
                       orderby !p.Value.SingleDose, p.Value.IfWhenRequired, p.Value.StartDate, p.Key, p.Value.DoseLow
                       select p.Value).ToList();
            else
                return (from p in scheduleTimeToPrescription
                       orderby !p.Value.SingleDose, p.Value.IfWhenRequired, p.Key, p.Value.DoseLow
                       select p.Value).ToList();
        }
    }
}
