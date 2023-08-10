// -----------------------------------------------------------------------
// <copyright file="aMMProcessor.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Main processor class for aMM module
//
// Note that you can not create the class directly instead either use static 
// methods, or to create instance of the object use aMMProcessor.Create, note
// that the object is cached in long term web cache and will need to be removed 
// by calling ClearCache.
//
// Includes methods to calculate the volume details (when creating new supplier)
// Used in aMMVolumeCalculation.ascx
// Method to determine syringe fill volumes
// Move supplier to the next stage (skipping stages that are not currently implemented)
//
// Usage
// Standard usage is
// processor = aMMProcessor.Create(requestId);
// processor.MoveToNextStage();
// :
// When form closes
// aMMProcessor.ClearCache(requestId);
//
// Modification History:
// 18Jun15 XN  Written
// 08Aug16 XN  159843 Added CalculateExpiryTimeInMintues, read expiry from DB
// 15Aug16 XN  Updated CalculateSyringeEvenSplit, and CalculateNumberOfSyringes to
//             factor in product type so can get IVContainer value 159843
// 19Aug6 XN   Changed CalculateExpiry to UpdateSupplyRequestExpiry
//             Added supply request locking 160567
// 22Aug16 XN  Added IfAnyStageUndone, extra print elements 160920
// 26Aug16 XN  Added ability to skip labelling stage on section
// 26Aug16 KR  Deleting Image when Undoing Compounding Stage. 161136
// 20Apr17 XN  182077 Added new printer fields for the manufacturing ingredients
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using _Shared;
    using ascribe.pharmacy.icwdatalayer;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;
    using ascribe.pharmacy.basedatalayer;
    using Newtonsoft.Json;
    using System.Collections.Generic;

    /// <summary>Results of the aMM volume calculation</summary>
    public struct aMMVolumeCalulcationResults
    {
        /// <summary>Gets equation used fro the dug concentration e.g. 500mg/(250mL + 0)</summary>
        public string InitialDrugConcenrationEqu { get; internal set; }

        /// <summary>Gets initial drug concentration normally mg/mL</summary>
        [JsonConverter(typeof(aMMDoubleToStringConverter))]
        public double InitialDrugConcenrationPermL { get; internal set; }

        /// <summary>Gets initial drug volume in mL</summary>
        [JsonConverter(typeof(aMMDoubleToStringConverter))]
        public double InitialVolumeInmL { get; internal set; }

        /// <summary>Gets drug plus nominal volume in mL</summary>
        [JsonConverter(typeof(aMMDoubleToStringConverter))]
        public double DrugPlusNominalVolumeInmL { get; internal set; }

        /// <summary>Gets the selected volume (either fixed or nominal)</summary>
        [JsonConverter(typeof(aMMDoubleToStringConverter))]
        public double SelectedVolumeInmL { get; internal set; }

        /// <summary>Gets the equation for the above or below rule</summary>
        public string RuleEquation { get; internal set; }

        /// <summary>Gets or sets any error with the equation</summary>
        public string Error { get; set; }
    }

    /// <summary>aMM module processor</summary>
    public class aMMProcessor
    {
        /// <summary>Minimum value user can enter for a dose value</summary>
        public const double MinDose = 0.0000001;

        /// <summary>Supply request that the processor is for</summary>
        private aMMSupplyRequest supplyRequest;

        /// <summary>People involved in second checking the AMM product</summary>
        private Person persons;

        /// <summary>Holds both the main product this formula relates to and the products for each ingredient</summary>
        private WProduct products;

        /// <summary>Gets the parent prescription for the supplier request</summary>
        public PrescriptionRow Prescription { get; private set; }

        /// <summary>Gets the supply request the processor is for</summary>
        public aMMSupplyRequestRow SupplyRequest { get { return supplyRequest[0]; } }

        /// <summary>Gets the supply request ingredients</summary>
        public aMMSupplyRequestIngredient SupplyRequestIngredients { get; private set; }

        /// <summary>Gets the products that the supply request ingredients use</summary>
        public WProductRow Product { get { return products.FindBySiteIDAndNSVCode(this.SupplyRequest.SiteID, this.SupplyRequest.NSVCode); } }

        /// <summary>Gets the formula that the supply request uses</summary>
        public WFormulaRow Formula { get; private set; }

        /// <summary>Gets the last state change note for the supply request</summary>
        public AMMStateChangeNoteRow LastAMMStateChangeNote { get; private set; }

        /// <summary>Last label printed with this processor 26Apr16 XN 123082</summary>
        public WLabelRow Label { get; set; }
        //public WLabelRow Label { get; private set; } Need to allow label printing at any stage 159413 XN

        /// <summary>
        /// If the manufacture item should go to bond store, depend on following
        ///     WFormula.Bond_Issue
        ///     D|aMM..IfBondStoreStage
        ///     D|PatMed.Manufacturing.BondCostCenter has value
        /// </summary>
        public bool IfBondStore 
        { 
            get { return this.Formula.IfBondStore && aMMSetting.IfBondStore && !string.IsNullOrWhiteSpace(PatMedSetting.Manufacturing.BondCostCenter()); }
        }

        /// <summary>If any stage has been undone 22Aug16 XN 160920</summary>
        public bool IfAnyStageUndone { get; private set; }

        /// <summary>Prevents a default instance of the <see cref="aMMProcessor"/> class from being created.</summary>
        private aMMProcessor() { }

        /// <summary>Updates the expiry date of the manufactured product (either manufacturer or compounding date + expiry or earliest expiry of ingredients)</summary>
        public void UpdateSupplyRequestExpiry(bool save = true)
        { 
            // Get the minimum expiry from the ingredients if any
            DateTime? minIngExpiry = this.SupplyRequestIngredients.FindDrugs().Min(dt => dt.ExpiryDate);

            // Get expiry time of formula either from Manufacture date or compound date
            this.SupplyRequest.ExpiryFromDate = aMMSetting.IsExpiryDateFromShiftStartDate ? this.SupplyRequest.ManufactureDate : this.SupplyRequest.CompoundingDate;
            DateTime? prodExpiry = (this.SupplyRequest.ExpiryFromDate == null) ? (DateTime?)null : this.SupplyRequest.ExpiryFromDate + TimeSpan.FromMinutes(this.Product.ExpiryTimeInMintues);
            
            // Determine the min and return
            this.SupplyRequest.ExpiryDate = DateTimeExtensions.Min(prodExpiry ?? DateTime.MaxValue, minIngExpiry ?? DateTime.MaxValue);
            if (this.SupplyRequest.ExpiryDate == DateTime.MaxValue || this.SupplyRequest.ExpiryFromDate == null) //05Aug16 KR Added. Bug 161758 : aMM - Expiry date being calculated incorrectly
                this.SupplyRequest.ExpiryDate = (DateTime?)null;
				
			if (save)
				this.supplyRequest.Save();
        }

        /// <summary>
        /// Uses the supply request expiry date and it's expiry from date to calculate the time to expiry in minutes
        /// XN 8Aug16 159843
        /// Place method here rather than on SupplyRequest as if change UpdateSupplyRequestExpiry easier to rem to change this
        /// </summary>
        /// <returns>time to expiry in minutes</returns>
        public int? CalculateExpiryTimeInMintues()
        {
            var fromDate = this.SupplyRequest.ExpiryFromDate;
            var toDate   = this.SupplyRequest.ExpiryDate;
            return (fromDate == null || toDate == null) ? (int?)null : (int)(toDate.Value - fromDate.Value).TotalMinutes;
        }

        /// <summary>
        /// Returns the person (normally second checker) by entity id 
        /// The users a loaded as required (and cached)
        /// </summary>
        /// <param name="entityId">entity id</param>
        /// <returns>Person row</returns>
        public PersonRow GetPerson(int? entityId)
        {
            if (entityId == null)
            {
                return null;
            }

            var person = this.persons.FindByID(entityId.Value);
            if (person == null)
            {
                this.persons.LoadByEntityID(entityId.Value);   
                person = this.persons.FindByID(entityId.Value);
            }

            return person;
        }

        /// <summary>Returns the product information for an ingredient</summary>
        /// <param name="NSVCode">ingredient NSVCode</param>
        /// <returns>Product for ingredient (loaded as required)</returns>
        public WProductRow GetIngredientProduct(string NSVCode)
        {
            var product = this.products.FindBySiteIDAndNSVCode(this.SupplyRequest.SiteID, NSVCode);
            if (product == null && NSVCode.Length == 7)
            {
                this.products.LoadByProductAndSiteID(NSVCode, this.SupplyRequest.SiteID, true);
                product = this.products.FindBySiteIDAndNSVCode(this.SupplyRequest.SiteID, NSVCode);
            }

            return product;
        }


        /// <summary>
        /// Either gets the processor from the cache (only stored in long term web cache), 
        /// or if not present creates a new processor and loads the data from the db.
        /// Once finished with aMMProcessor you will need to call ClearCache
        /// </summary>
        /// <param name="requestId">AMM supply request Id</param>
        /// <returns>New processor</returns>
        public static aMMProcessor Create(int requestId)
        {
            string cachName = string.Format("aMMProcessor.Create[{0}]", requestId);

            var processor = PharmacyDataCache.GetFromSession(cachName) as aMMProcessor;
            if (processor == null)
            {
                processor = new aMMProcessor();

                processor.supplyRequest = new aMMSupplyRequest();
                processor.supplyRequest.LoadByRequestID(requestId);

                processor.SupplyRequestIngredients = new aMMSupplyRequestIngredient();
                processor.SupplyRequestIngredients.LoadByRequestId(requestId);

                processor.products = new WProduct();
                processor.products.LoadByProductAndSiteID(processor.SupplyRequest.NSVCode, processor.SupplyRequest.SiteID);
                processor.products.LoadByProductAndSiteID(processor.SupplyRequestIngredients.Select(i => i.NSVCode).Distinct(), processor.SupplyRequest.SiteID, true);

                processor.Formula = WFormula.GetById(processor.SupplyRequest.WFormulaID);

                processor.persons = new Person();

                processor.Prescription               = icwdatalayer.Prescription.GetByRequestID(processor.SupplyRequest.RequestID_Parent);
                processor.LastAMMStateChangeNote     = AMMStateChangeNote.GetLatestByRequestId(requestId);
                processor.IfAnyStageUndone           = AMMStateChangeNote.IfAnyStageUndone(requestId);      // 22Aug16 XN 160920

                int? requestIdWLabel = processor.SupplyRequest.RequestIdWLabel;
                processor.Label = requestIdWLabel == null ? null : WLabel.GetByRequestID(requestIdWLabel.Value);
            
                PharmacyDataCache.SaveToSession(cachName, processor);
            }

            return processor;
        }

        /// <summary>Clears the aMMProcessor from the cache</summary>
        /// <param name="requestId">AMM supply request Id</param>
        public static void ClearCache(int requestId, bool unlockRows = false)
        {
            string cachName = string.Format("aMMProcessor.Create[{0}]", requestId);
            PharmacyDataCache.RemoveFromSession(cachName);
             
            // Load lock and unlock 19Aug16 XN 160567
            if (unlockRows)
                Database.ExecuteSQLNonQuery("UPDATE aMMSupplyRequest SET SessionLock=0 WHERE RequestID={0} AND SessionLock={1}", requestId, SessionInfo.SessionID);
        }

        ///// <summary>
        ///// Validate prescription
        ///// 1. Checks prescription has mass dose units 
        ///// </summary>
        ///// <param name="prescription">The prescription</param>
        ///// <returns>The <see cref="ErrorWarningList"/></returns>
        //public static ErrorWarningList ValidatePrescription(PrescriptionRow prescription)
        //{
        //    ErrorWarningList results = new ErrorWarningList();

        //    // Check units of prescription are in g or mg etc
        //    if (prescription.UnitID_Dose != null)
        //    {
        //        var unit    = Unit.GetByUnitID(prescription.UnitID_Dose.Value);
        //        var unitLcd = Unit.GetByUnitID(unit.UnitIdLcd);
        //        if (!unitLcd.Abbreviation.EqualsNoCaseTrimEnd("kg"))
        //        {
        //            results.AddError("Prescription units '{0}' are invalid for manufacturing", unit.Abbreviation);
        //        }
        //    }

        //    return results;
        //}

        /// <summary>
        /// Validates drug
        /// 1. Check drug has valid formula
        /// 2. Is suitable for batch manufacturing (IsDosingUnits = true)
        /// 3. Either DisplacementVolumeInml or ReconstitutionVolumeInml > 0
        /// 4. Drug dosing units has matching entry in unit table
        /// 5. Either prescription or drug has a dose
        /// 6. Drug and prescription have same base unit type
        /// </summary>
        /// <param name="prescription">Prescription to validate</param>
        /// <param name="drug">Drug to validate</param>
        /// <returns>Any errors</returns>
        public static ErrorWarningList ValidateDrug(PrescriptionRow prescription, WProductRow drug)
        {
            ErrorWarningList results = new ErrorWarningList();

            // Check formula
            WFormulaRow formula = WFormula.GetByNSVCodeSiteAndApproved(drug.NSVCode, SessionInfo.SiteID);
            var test = formula.IsDosingUnits;
            if (formula == null)
            {
                results.AddError("Drug {0} is not approved for manufacture.", drug.NSVCode);
            }
            else if (!formula.IsDosingUnits)
            {
                results.AddError("Formula {0} is only for batch manufacturing.", drug.NSVCode);
            }
            else if (((drug.DisplacementVolumeInml ?? 0) + (drug.ReconstitutionVolumeInml ?? 0)) < MinDose)
            {
                // test for the calculation screen
                results.AddError("Both displacement and reconstitution volumes are 0 for {0}", drug.NSVCode);
            }

            // Test Drug dosing units has matching entry in unit table
            Unit drugUnit = new Unit();
            drugUnit.LoadByAbbreviation(drug.DosingUnits);
            if (!drugUnit.Any())
            {
                results.AddError("Drug has invalid dosing units {0}", drug.DosingUnits);
            }

            // Test either prescription or drug has a dose
            if (prescription.Dose == null && drug.DosesPerIssueUnit == null)
            {
                results.AddError("Prescription is doseless and pharmacy drug does not have doses per issue unit");
            }

            // Test drug and prescription have same base unit type
            if (prescription.UnitID_Dose != null && drugUnit.Any() && drugUnit[0].UnitIdLcd != Unit.GetByUnitID(prescription.UnitID_Dose.Value).UnitIdLcd)
            {
                results.AddError("Prescription '{0}' and drug '{1}' units are different.", drugUnit[0], Unit.GetByUnitID(prescription.UnitID_Dose.Value));
            }

            // Check if stock is available 02Aug16 XN  159413
            WBatchStockLevel batchStockLevel = new WBatchStockLevel();
            batchStockLevel.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, drug.NSVCode); 
            if (batchStockLevel.Any())
            {
                results.AddWarning("Existing stock is available which can be issued from this patient's PMR");
            }

            return results;            
        }

        /// <summary>
        /// Calculate the volume details (when creating new supplier)
        /// Used in aMMVolumeCalculation.ascx
        /// </summary>
        /// <param name="dose">Dose from prescription or drug</param>
        /// <param name="volumeType">Volume type selected by user</param>
        /// <param name="fixedVolumeInmL">Fixed volume value (from drug but can be edit by user)</param>
        /// <param name="drug">drug for manufacture</param>
        /// <returns>calculation results</returns>
        public static aMMVolumeCalulcationResults CalculateVolume(double dose, aMMVolumeType volumeType, double fixedVolumeInmL, WProductRow drug)
        {
            aMMVolumeCalulcationResults results = new aMMVolumeCalulcationResults();

            UnitRow unit = Unit.GetByAbbreviation(drug.DosingUnits);

            // Calculate initial drug concentration = (Doses Per issue unit / (displacement volume + reconstitution volume)
            results.InitialDrugConcenrationEqu   = string.Format("{0:0.####}{1} / ({2:0.####}mL + {3:0.####}mL)", drug.DosesPerIssueUnit ?? 0, unit, drug.DisplacementVolumeInml ?? 0, drug.ReconstitutionVolumeInml ?? 0);
            results.InitialDrugConcenrationPermL = (drug.DosesPerIssueUnit ?? 0) / ((drug.DisplacementVolumeInml ?? 0) + (drug.ReconstitutionVolumeInml ?? 0));
            if (results.InitialDrugConcenrationPermL < aMMProcessor.MinDose)
            {
                results.Error = string.Format("Can't continue as initial drug concentration is 0 (possibly due to  doses per issue unit being 0) for {0}", drug.NSVCode);
                return results;
            }

            // Calculate initial volume for dose = dose / initial drug concentration
            results.InitialVolumeInmL = dose / results.InitialDrugConcenrationPermL;

            // Calculate drug + nominal volume
            results.DrugPlusNominalVolumeInmL = results.InitialVolumeInmL + fixedVolumeInmL;

            // Calculate the equation rule
            // e.g. % rule 250ml % rule Max % volume to add   10   275 mL - 5 mL + 30 mL
            double ruleVolumePlusPercentageInmL = fixedVolumeInmL * (1.0 + (aMMSetting.NewDrugWizard.MaxPercentageOfVolume / 100.0));
            double differnece = ruleVolumePlusPercentageInmL - results.DrugPlusNominalVolumeInmL;

            //if the drug+nominal volume is greater than the amount allowed by the rule then we should use the rule amount instead
            if (differnece < 0)
            {
                results.DrugPlusNominalVolumeInmL = ruleVolumePlusPercentageInmL;
            }

            if(volumeType == aMMVolumeType.Fixed)
            {
                results.SelectedVolumeInmL = fixedVolumeInmL;
            }
            else
            {
                //if the drug+nominal volume is greater than the amount allowed by the rule then we should use the rule amount instead
                if (differnece < 0)
                {
                    results.RuleEquation = string.Format("{0} mL - {1} mL + {2} mL", fixedVolumeInmL.To7Sf7Dp(), Math.Abs(differnece).To7Sf7Dp(), results.InitialVolumeInmL.To7Sf7Dp());
                }
                
                results.SelectedVolumeInmL = results.DrugPlusNominalVolumeInmL;
            }

            // round the results
            results.DrugPlusNominalVolumeInmL   = results.DrugPlusNominalVolumeInmL.To7Sf7Dp();
            results.InitialDrugConcenrationPermL= results.InitialDrugConcenrationPermL.To7Sf7Dp();
            results.InitialVolumeInmL           = results.InitialVolumeInmL.To7Sf7Dp();
            results.SelectedVolumeInmL          = results.SelectedVolumeInmL.To7Sf7Dp();

            // Check the final concentration
            double concentration = dose / results.SelectedVolumeInmL;
            if (concentration < drug.MinConcentrationInDoseUnitsPerml)
            {
                results.Error = "Below minimum concentration";
            }
            else if (concentration > drug.MaxConcentrationInDoseUnitsPerml)
            {
                results.Error = "Above maximum concentration";
            }
            else
            {
                results.Error = string.Empty;
            }

            return results;
        }

        /// <summary>Calculates syringe volume if volume is split evenly</summary>
        /// <param name="dose">Does being given</param>
        /// <param name="volumeInmL">Volume being given</param>
        /// <param name="splitDose">Dose in each syringe</param>
        /// <param name="splitVolumeInmL">Volume in each syringe</param>
        /// <param name="product">product being made 159843 15Aug16 XN</param>
        public static void CalculateSyringeEvenSplit(double dose, double volumeInmL, out double splitDose, out double splitVolumeInmL, WProductRow product)
        {
            int numberOfSyrninges = CalculateNumberOfContainers(volumeInmL, product);
            splitVolumeInmL   = volumeInmL / numberOfSyrninges;
            splitDose         = dose / numberOfSyrninges;
        }

        /// <summary>Calculates the syringe volume if fill syringes up as much as possible</summary>
        /// <param name="dose">Does being given</param>
        /// <param name="volumeInmL">Volume being given</param>
        /// <param name="mainDose">Dose in each syringe (full syringe dose)</param>
        /// <param name="mainVolumeInmL">Volume in each syringe (full syringe volume)</param>
        /// <param name="finalDose">Dose in last syringe</param>
        /// <param name="finalVolumeInmL">Volume in each syringe</param>
        public static void CalculateSyringeFullAndPart(double dose, double volumeInmL, out double mainDose, out double mainVolumeInmL, out double finalDose, out double finalVolumeInmL)
        {
            Container largestContainer = Container.Instance().FindLargest(ContainerType.Syringe);
            mainVolumeInmL = Math.Min(largestContainer.VolumeInmL, volumeInmL);
            mainDose       = dose * (mainVolumeInmL / volumeInmL);

            if (volumeInmL % mainVolumeInmL == 0)
            {
                finalVolumeInmL = Math.Min(mainVolumeInmL, volumeInmL);
                finalDose       = Math.Min(mainDose, dose);
            }
            else
            {
                finalVolumeInmL = volumeInmL % mainVolumeInmL;

                //double div    = dose / (dose * (largestContainer.VolumeInmL / volumeInmL));
                //double result = div - Math.Floor(div);
                //finalDose = result * (dose * (largestContainer.VolumeInmL / volumeInmL));
                finalDose       = dose % mainDose;
            }
        }

        /// <summary>Get largest container and determines number of containers required to hold the volume</summary>
        /// <param name="volumeInmL">Total volume</param>
        /// <param name="product">product being made 159843 15Aug16 XN</param>
        /// <returns>Number of containers</returns>
        public static int CalculateNumberOfContainers(double volumeInmL, WProductRow product)
        {
            // only currently support syringes 159843 15Aug16 XN
            if (product.IVContainer != "S")
                return 1;

            Container largestContainer = Container.Instance().FindLargest(ContainerType.Syringe);
            double numberOfSyrningesDbl = volumeInmL / largestContainer.VolumeInmL;
            int numberOfSyrninges = (int)Math.Ceiling(numberOfSyrningesDbl);
            if (Math.Ceiling(numberOfSyrninges - numberOfSyrningesDbl) < aMMProcessor.MinDose)
            {
                numberOfSyrninges = (int)Math.Floor(numberOfSyrningesDbl);
            }
            
            return numberOfSyrninges;
        }

        /// <summary>
        /// Moves the supply request to the next stage (skipping any stages that are not supported)
        /// Will also create the AMMStateChangeNote note for the new state
        /// Also saves the changes at the end
        /// Can throw ConcurencyException if another user has altered the supply request
        /// </summary>
        /// <param name="entityID_Alternate">For second check stage this is the entity that performed the check</param>
        public void MoveNextStage(int? entityID_Alternate = null)
        {
            var originalState = this.SupplyRequest.State;

            // Move to next stage
            this.SupplyRequest.State++;

            // Check if WaitingProductionTray stage
            if (this.SupplyRequest.State == aMMState.WaitingProductionTray && !aMMSetting.IfRequiresProductionTray)
            {
                this.SupplyRequest.State++;
            }

            // Check if any drugs for ReadyToCheck stage
            if (this.SupplyRequest.State == aMMState.ReadyToCheck && 
                (aMMSetting.SecondCheck == aMMSecondCheckType.None || !this.SupplyRequestIngredients.FindDrugs().Any()))
            {
                this.SupplyRequest.State++;
            }

			// Check it read to label stage
			if (this.SupplyRequest.State == aMMState.ReadyToLabel && !aMMSetting.IfReadyToLabel)
            {
                this.SupplyRequest.State++;   
            }

            // Check if FinalCheck stage
            if (this.SupplyRequest.State == aMMState.FinalCheck && aMMSetting.FinalCheck == aMMFinalCheckType.None)
            {
                this.SupplyRequest.State++;   
            }

            // Check if BondStore stage
            if (this.SupplyRequest.State == aMMState.BondStore && !this.IfBondStore)
            {
                this.SupplyRequest.State++;   
            }

            // Check if ReadyToRelease stage
            if (this.SupplyRequest.State == aMMState.ReadyToRelease && !aMMSetting.IfReadyToRelease)
            {
                this.SupplyRequest.State++;   
            }

            // Create stage change note
            AMMStateChangeNote note = new AMMStateChangeNote();
            note.Add(originalState, this.SupplyRequest.State);
            note[0].EntityID = entityID_Alternate ?? SessionInfo.EntityID;

            this.SupplyRequest.EntityID_LastStateUpdate = note[0].EntityID;
            this.SupplyRequest.DateTime_LastStateUpdate = note[0].CreatedDate;
                        
            // Save changes
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.InheritTransaction))
            {
                this.supplyRequest.Save();
                this.SupplyRequestIngredients.Save();
                note.Save();
                this.SupplyRequest.LinkNote(note[0].NoteID);

                // If complete stage the mark supply request as completed
                if (this.SupplyRequest.State == aMMState.Completed)
                {
                    this.SupplyRequest.Complete("AMM Supply Complete");
                }

                trans.Commit();
            }

            // Update the last state change note 
            this.LastAMMStateChangeNote = note[0];
            //this.LastAMMStateChangeNoteUser = this.LastAMMStateChangeNote.GetPerson().ToString();
        }

        /// <summary>Move back to previous stage</summary>
        public void MoveBackStage()
        {
            var originalState = this.SupplyRequest.State;
            
            // Move to back a stage
            this.SupplyRequest.State--;

            // Check if ReadyToRelease stage
            if (this.SupplyRequest.State == aMMState.ReadyToRelease && !aMMSetting.IfReadyToRelease)
            {
                this.SupplyRequest.State--;
            }

            // Check if BondStore stage
            if (this.SupplyRequest.State == aMMState.BondStore && !this.IfBondStore)
            {
                this.SupplyRequest.State--;   
            }

            // Check if FinalCheck stage
            if (this.SupplyRequest.State == aMMState.FinalCheck && aMMSetting.FinalCheck == aMMFinalCheckType.None)
            {
                this.SupplyRequest.State--;
            }

			// Check it read to label stage
			if (this.SupplyRequest.State == aMMState.ReadyToLabel && !aMMSetting.IfReadyToLabel)
            {
                this.SupplyRequest.State--;   
            }

            // 26Aug16 KR Added. Reset compounding image ID when going back. 161136
            int? imageIdToRemove = SupplyRequest.CompoundedImageID;
            if (this.SupplyRequest.State == aMMState.ReadyToCompound && aMMSetting.CaptureManufacturedImage && imageIdToRemove != null)
            {
                // reset the image ID
                this.SupplyRequest.CompoundedImageID = null;
            }

            // Check if any drugs for ReadyToCheck stage
            if (this.SupplyRequest.State == aMMState.ReadyToCheck && 
                (aMMSetting.SecondCheck == aMMSecondCheckType.None || !this.SupplyRequestIngredients.FindDrugs().Any()))
            {
                this.SupplyRequest.State--;
            }

            // Check if WaitingProductionTray stage
            if (this.SupplyRequest.State == aMMState.WaitingProductionTray && !aMMSetting.IfRequiresProductionTray)
            {
                this.SupplyRequest.State--;
            }

            // Create stage change note
            AMMStateChangeNote note = new AMMStateChangeNote();
            note.Add(originalState, this.SupplyRequest.State);
            note[0].EntityID = SessionInfo.EntityID;

            this.SupplyRequest.EntityID_LastStateUpdate = note[0].EntityID;
            this.SupplyRequest.DateTime_LastStateUpdate = note[0].CreatedDate;

            
            // Save changes
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.InheritTransaction))
            {
                 
                this.SupplyRequestIngredients.Save();
                this.supplyRequest.Save();
                note.Save();
                this.SupplyRequest.LinkNote(note[0].NoteID);

                //26Aug16 KR Added. 161136
                // If moving back from compounding stage delete image if appropriate.
                // Put this here so the delete is wrapped in the transaction as it is stored in seperate table.
                if (imageIdToRemove != null)
                {
                    this.SupplyRequest.DeleteCompoundedImage((int)imageIdToRemove);
                }

                trans.Commit();
            }

            // Update the last state change note 
            this.LastAMMStateChangeNote = note[0];
            this.IfAnyStageUndone       = true;
            //this.LastAMMStateChangeNoteUser = this.LastAMMStateChangeNote.GetPerson().ToString();
        }

        /// <summary>Returns WFormula index of next ingredient that has not been fully assembled</summary>
        /// <returns>index of next ingredient to display for assembly</returns>
        public int FindNextUnselectedIngredient()
        {
            for (int i = 0; i < this.Formula.GetIngredientNSVCodes().Count(); i++)
            {
                // If formula index is not currently in list of supply request ingredients then return
                var ingredientForThisIndex = this.SupplyRequestIngredients.Where(c => c.FormulaIndex == i);
                if (!ingredientForThisIndex.Any())
                {
                    return i;
                }

                // Check that the ingredient has been completely full filled
                var amountRequiredInIssueUnits = this.Formula.CalculateIngredientQty(i, this.SupplyRequest.Dose, (double)this.SupplyRequest.QuantityRequested, this.Product);
                var currentAmountInIssueUnits  = ingredientForThisIndex.Sum(c => c.QtyInIssueUnits * this.GetIngredientProduct(c.NSVCode).DosesPerIssueUnit);
                if (amountRequiredInIssueUnits - currentAmountInIssueUnits > aMMProcessor.MinDose)
                {
                    return i;
                }
            }

            return -1;
        }

        /// <summary>Updates the supply request issue state, and if needed will create an attached note (will save updates)</summary>
        /// <param name="nextIssueState">New state to set</param>
        /// <param name="manualIssue">If manual issue</param>
        public void UpdateIssueState(aMMIssueState nextIssueState, bool manualIssue)
        {
            if (this.SupplyRequest.IssueState == nextIssueState)
            {
                return;
            }

            // If manual issue, create attached note
            AttachedNote note = new AttachedNote();
            string prefix = manualIssue ? "Manually " : " ";
            if (this.SupplyRequest.IssueState < nextIssueState)
            {
                // Create issued attached note
                switch (nextIssueState)
                {
                case aMMIssueState.IssuedIngredients: note.Add(prefix + "issued ingredients");   break;
                case aMMIssueState.IssuedToBondStore: note.Add(prefix + "issued to bond store"); break;
                case aMMIssueState.IssuedToPatient:   note.Add(prefix + "issued to patient");    break;
                }
            }
            else
            {
                // Create return attached note
                switch (nextIssueState)
                {
                case aMMIssueState.None:              note.Add(prefix + "returned ingredients");    break;
                case aMMIssueState.IssuedIngredients: note.Add(prefix + "returned from bond store"); break;
                }
            }
			
            // Save and link to request
            if (note.Any())
            {
				note[0].Description = note[0].Description.ToUpperFirstLetter();
				note.Save();
                this.SupplyRequest.LinkNote(note[0].NoteID);
            }

            // Reload the main product as this ensure that ingredients are reloaded 153737 XN 18May16
            this.products.LoadByProductAndSiteID(this.SupplyRequest.NSVCode, this.SupplyRequest.SiteID);

            // Save issue state
            this.SupplyRequest.IssueState = nextIssueState;
            this.supplyRequest.Save();
        }

        /// <summary>
        /// Converts patient data to xml heap
        /// Replacement for vb6 function formula.bas StoreandTotal and ParseFormulaData
        /// 16Apr16 XN 123082
        /// </summary>
        /// <param name="layout">worksheet layout being used</param>
        /// <returns></returns>
        public string ToHeapWorksheetXml(string layout)
        {
            var prescriptionUnits = Unit.GetByUnitID(this.Prescription.UnitID_Dose.Value);
            int siteId = SessionInfo.SiteID;
            double tempDbl;
            decimal tempDec;
            string tempStr;

            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");

                xmlWriter.WriteAttributeString("pStatus", EnumDBCodeAttribute.EnumToDBCode(this.SupplyRequest.EpisodeType));  // Should override episode in-case episode has changed

                xmlWriter.WriteAttributeString("numdse", this.SupplyRequest.QuantityRequested.ToString());

                // Prep date
                var note = this.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.ReadyToLabel);
                xmlWriter.WriteAttributeString("preparationdate", note == null ? string.Empty : note.CreatedDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("preparationtime", note == null ? string.Empty : note.CreatedDate.ToPharmacyTimeString());

                xmlWriter.WriteAttributeString("drugdescription", this.Product.LabelDescription + "  ");

                //if (this.Formula.IsDosingUnits)
                    tempDbl = this.SupplyRequest.Dose / this.Product.ConversionFactorPackToIssueUnits;
                //else
                    //tempDbl = (double)this.SupplyRequest.Dose / this.Product.ConversionFactorPackToIssueUnits;
                xmlWriter.WriteAttributeString("dose", tempDbl.To7Sf7Dp().ToString("#######.###"));

                if (this.Formula.IsDosingUnits)
                    tempStr = string.Format("{0} {1:#######.###}{2} x {3} dose{4}", this.Product.LabelDescription.Replace('!', ' '), tempDbl, prescriptionUnits, this.SupplyRequest.QuantityRequested, this.SupplyRequest.QuantityRequested > 1 ? "s" : string.Empty);
                else
                    tempStr = string.Format("{0} {1:#######.###}{2} x {3} {4}", this.Product.LabelDescription.Replace('!', ' '), tempDbl, prescriptionUnits, this.Product.ConversionFactorPackToIssueUnits, this.Product.PrintformV);
                xmlWriter.WriteAttributeString("description", tempStr);

                xmlWriter.WriteAttributeString("ProductNSV", this.Product.NSVCode);

                //xmlWriter.WriteAttributeString("method", string.IsNullOrWhiteSpace(this.Formula.Method) ? string.Empty : "[#include\t" + this.Formula.GetMethodFilename() + "]");
                
                //string label = this.Formula.Label.Replace("{\r\n\\par}", @"{\par}").Replace("\r\n", @"\par"); 02Aug16 XN  159413 allow including label in worksheet at any stage
                string label = this.Label.Text.Replace("{\r\n\\par}", @"{\par}").Replace("\r\n", @"\par");
                xmlWriter.WriteAttributeString("label", label);

                double? ingVol = null;
                if (this.Product.DosesPerIssueUnit != null && this.Product.DisplacementVolumeInml != null && this.Product.ReconstitutionVolumeInml != null)
                    ingVol = (this.SupplyRequest.Dose / this.Product.DosesPerIssueUnit) * (this.Product.DisplacementVolumeInml + this.Product.ReconstitutionVolumeInml);
                xmlWriter.WriteAttributeString("ingvol", ingVol == null ? string.Empty : ingVol.ToString("###0.## mL"));

                // Worksheet
                StringBuilder worksheet = new StringBuilder();
                string reconstitutionAbbreviation = WConfiguration.Load(siteId, "D|patmed", string.Empty, this.Product.ReconstitutionAbbreviation, this.Product.ReconstitutionAbbreviation, false);
                string dilluentAbbreviation       = WConfiguration.Load(siteId, "D|patmed", string.Empty, this.Product.DiluentAbbreviation1,       this.Product.DiluentAbbreviation1,       false);

                if ((this.Product.ReconstitutionVolumeInml ?? 0) > 0)
                    worksheet.AppendFormat("Use {0} mL of to {1} reconstitute per unit. Then take ", this.Product.ReconstitutionVolumeInml, reconstitutionAbbreviation);
                else
                    worksheet.AppendFormat("Take ");
                worksheet.AppendFormat("{0:###0.##} mL ( = {1} {2})", ingVol, this.Product.MaxInfusionRateInmL, this.Product.DosingUnits);

                if (!string.IsNullOrWhiteSpace(dilluentAbbreviation))
                    worksheet.AppendFormat(" and dilute to {0} mL with {1}", this.Product.MaxInfusionRateInmL, dilluentAbbreviation);

                switch (WConfiguration.Load(siteId, "D|patmed", "Manufacturing", "WorksheetContainer", "SIZEANDTYPE", false).ToUpper())
                {
                case "SIZEANDTYPE":
                    double splitDose, splitVolumeInmL, finalDose, finalVolumeInmL;

                    int numberOfSyringes = aMMProcessor.CalculateNumberOfContainers(this.SupplyRequest.VolumeOfInfusionInmL.Value, this.Product);
                    worksheet.Append(" and send as ");
                    if (this.SupplyRequest.SyringeFillType == aMMSyringeFillType.FullAndPart)
                    {
                        aMMProcessor.CalculateSyringeFullAndPart((double)this.SupplyRequest.QuantityRequested.Value, this.SupplyRequest.VolumeOfInfusionInmL.Value, out splitDose, out splitVolumeInmL, out finalDose, out finalVolumeInmL);
                        worksheet.AppendFormat("{0} x {1:0.####} mL", numberOfSyringes - 1, splitVolumeInmL);
                        worksheet.AppendFormat("1 x {0:0.####} mL", finalDose);
                    }
                    else
                    {
                        aMMProcessor.CalculateSyringeEvenSplit((double)this.SupplyRequest.QuantityRequested.Value, this.SupplyRequest.VolumeOfInfusionInmL.Value, out splitDose, out splitVolumeInmL, this.Product);
                        worksheet.AppendFormat("{0} x {1:0.####} mL", numberOfSyringes, splitVolumeInmL);
                    }
                    break;
                case "TYPE":
                    worksheet.Append(" and send in a ");
                    var container = Container.Instance().FindLargest(EnumDBCodeAttribute.DBCodeToEnum<ContainerType>(this.Product.IVContainer));
                    if (container != null)
                        worksheet.Append(container);
                    break;
                }

                xmlWriter.WriteAttributeString("worksheet", worksheet.ToString());

                xmlWriter.WriteAttributeString("totalcostExVAT", "0.00");
                xmlWriter.WriteAttributeString("totalcost",      "0.00");

                var compoundNote = this.SupplyRequest.GetFirstChangeNoteAfterState(aMMState.ReadyToCheck);
                var createDate = compoundNote == null ? (DateTime?)null : compoundNote.CreatedDate;
                xmlWriter.WriteAttributeString("PrepDate",     createDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("PrepTime",     createDate.ToPharmacyTimeString());
                xmlWriter.WriteAttributeString("PrepDateTime", createDate.ToPharmacyDateTimeString());

                xmlWriter.WriteAttributeString("batchnumber", this.SupplyRequest.BatchNumber);

                //DateTime? expiryDate = this.CalculateExpiry(); 08Aug16 159843 read expiry from DB
                DateTime? expiryDate = this.SupplyRequest.ExpiryDate;
                xmlWriter.WriteAttributeString("expirydateonly", expiryDate.ToPharmacyDateString());
                xmlWriter.WriteAttributeString("expirytimeonly", expiryDate == null ? string.Empty : expiryDate.Value.ToString("HHmm"));
                xmlWriter.WriteAttributeString("expirydate",     expiryDate.ToPharmacyDateTimeString());

                label = PharmacyLabelReprint.GetLabelByAmmSupplyRequestAndType(this.SupplyRequest.RequestID, PharmacyLabelReprintType.RawLabel);
                if (string.IsNullOrEmpty(label))
                    label = this.Label.Text;        // 02Aug16 XN  159413 allow including label in worksheet at any stage
                string[] stdlbl= label.Split(new string[] { "\r\n" }, StringSplitOptions.None);
                for (int c = 0; c < 11; c++)
                    xmlWriter.WriteAttributeString(string.Format("StdLbl{0}a", c + 1), c < stdlbl.Length ? stdlbl[c].Replace("  ", " ") : string.Empty);

                //StringBuilder stdlbl = new StringBuilder();
                //if (expiryDate != null)
                //{
                //    stdlbl.Append(WConfiguration.Load(siteId, "D|PatMed", string.Empty, "DoNotUseAfter", "Text DoNotUseAfter missing from PATMED", false));
                //    stdlbl.Append(expiryDate.ToPharmacyDateString());
                //    if (!string.IsNullOrWhiteSpace(this.SupplyRequest.BatchNumber))
                //    {
                //        stdlbl.Append(" ");
                //        stdlbl.Append(WConfiguration.Load(siteId, "D|PatMed", string.Empty, "BNOnLabel", string.Empty, false).Trim());
                //        stdlbl.Append(this.SupplyRequest.BatchNumber);
                //    }
                //}

                //string labelType = EnumDBCodeAttribute.EnumToDBCode(this.SupplyRequest.EpisodeType);
                //if (WConfiguration.Load(siteId, "D|PatMed", string.Empty, "PrintBatchNumber",  string.Empty, false).Contains(labelType) ||
                //    WConfiguration.Load(siteId, "D|PatMed", string.Empty, "PrintRxNumOnLabel", string.Empty, false).Contains(labelType))
                //{
                //    if (stdlbl.Length + this.SupplyRequest.PrescriptionNumber.ToString().Length > 35)
                //        stdlbl.Append(" " + this.SupplyRequest.PrescriptionNumber);
                //    else
                //    {
                //        stdlbl.Append(" No.");
                //        stdlbl.Append(this.SupplyRequest.PrescriptionNumber);
                //        if (!string.IsNullOrWhiteSpace(this.SupplyRequest.BatchNumber) && 
                //            WConfiguration.Load(siteId, "D|PatMed", string.Empty, "PrintRxNumonLabel", string.Empty, false).Contains(labelType))
                //            stdlbl.Append("/" + this.SupplyRequest.BatchNumber);
                //        stdlbl.Append(label);
                //    }
                //}

                //xmlWriter.WriteAttributeString("stdlbl10A", stdlbl.ToString());

                // 19Aug16 XN 160567 Fix for only display the prescription text in the LblDescRaw (and not direction text)
                int linesOfText = this.Label == null || this.Label.IsExtraLabel ? 15 : 5;
                var splitLabel = this.Label.Text.Split('\n');
                string firstWordInProduct = this.Product.ToString().Split(' ')[0];
                var firstLineOfDesc = splitLabel.AsEnumerable<string>().ToList().FindIndex(s => s.IndexOf(firstWordInProduct, StringComparison.InvariantCultureIgnoreCase) >= 0);
                if (firstLineOfDesc == -1)
                    firstLineOfDesc = 0;
                xmlWriter.WriteAttributeString("LblDescRaw", this.Label == null ? string.Empty : splitLabel.Skip(firstLineOfDesc).Take(linesOfText).Select(s => s.TrimEnd()).ToCSVString(" "));
                
                var timeToExpire = expiryDate - createDate;
                xmlWriter.WriteAttributeString("ExpHrs",      timeToExpire == null ? string.Empty : string.Format("{0:0.##} hours", Math.Floor(timeToExpire.Value.TotalHours)));
                xmlWriter.WriteAttributeString("iexpirydays", timeToExpire == null ? string.Empty : ((int)timeToExpire.Value.TotalDays).ToString());
                xmlWriter.WriteAttributeString("ExpHrsPrep",  timeToExpire == null ? string.Empty : string.Format("{0:0.##} hours", Math.Floor(timeToExpire.Value.TotalHours)));

                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("vol/dse"), this.SupplyRequest.VolumeOfInfusionInmL.ToString());
                xmlWriter.WriteAttributeString("numdse1",  this.SupplyRequest.QuantityRequested.ToString("0.####"));

                // Ingredients
                var formualNsvCodes = this.Formula.GetIngredientNSVCodes().ToList();
                double totalVolIng = 0.0;
                for (int i = 1; i <= this.SupplyRequestIngredients.Count; i++)
                {
                    var ing = this.SupplyRequestIngredients[i - 1];
                    var prod= this.GetIngredientProduct(ing.NSVCode);

                    xmlWriter.WriteAttributeString("ItemCode" + i.ToString(), ing.NSVCode);
                    xmlWriter.WriteAttributeString("tradename"+ i.ToString(), prod.GetTradename());
                    xmlWriter.WriteAttributeString("ItemDesc" + i.ToString(), prod.LabelDescription.Replace("!", " "));
                    xmlWriter.WriteAttributeString("ibatchno" + i.ToString(), string.IsNullOrEmpty(ing.BatchNumber) ? "_____________" : ing.BatchNumber);
                    xmlWriter.WriteAttributeString("iexpiry"  + i.ToString(), ing.ExpiryDate == null                ? "__________"    : ing.ExpiryDate.ToPharmacyDateTimeString());
                    
                    var supplier = WSupplier2.GetBySiteIDAndCode(siteId, prod.SupplierCode);
                    xmlWriter.WriteAttributeString("supcode"  + i.ToString(), prod.SupplierCode);
                    xmlWriter.WriteAttributeString("supname"  + i.ToString(), supplier == null ? "** not found **" : supplier.Description);

                    if (this.Formula.IsDosingUnits && prod.mlsPerPack > 0)
                        xmlWriter.WriteAttributeString("dunits"  + i.ToString(), "mL");
                    else if (!this.Formula.IsDosingUnits)
                        xmlWriter.WriteAttributeString("dunits"  + i.ToString(), prod.PrintformV); // probably not called
                    else
                        xmlWriter.WriteAttributeString("dunits"  + i.ToString(), prod.DosingUnits);
                    xmlWriter.WriteAttributeString("iunits" + i.ToString(), prod.PrintformV);
                    
                    double ingQuantity = this.Formula.CalculateIngredientQty(ing.FormulaIndex, this.SupplyRequest.Dose, (double)this.SupplyRequest.QuantityRequested, this.Product).Value;
                    totalVolIng += ingQuantity;

                    xmlWriter.WriteAttributeString("ItemQty"  + i.ToString(), ingQuantity.To7Sf7Dp().ToString("0.##"));
                    xmlWriter.WriteAttributeString("Item4Qty" + i.ToString(), ingQuantity.ToSigFig(9).ToString("0.####"));

                    double totalPacks = ((ingQuantity  / (double)prod.mlsPerPack) / prod.ConversionFactorPackToIssueUnits);
                    xmlWriter.WriteAttributeString("TotalPacks"  + i.ToString(), ing.QtyInIssueUnits.ToString("0.####"));
                    xmlWriter.WriteAttributeString("rTotalPacks" + i.ToString(), Math.Ceiling(ing.QtyInIssueUnits).ToString("0.####"));
                    xmlWriter.WriteAttributeString("rtotalunits" + i.ToString(), Math.Ceiling(ing.QtyInIssueUnits).ToString());
                    xmlWriter.WriteAttributeString("totalunits"  + i.ToString(), (ing.QtyInIssueUnits / prod.ConversionFactorPackToIssueUnits).ToString());
                    xmlWriter.WriteAttributeString("issued"      + i.ToString(), ing.QtyInIssueUnits.ToString("0.####"));

                    // XN 20Apr17 182077 Added new printer fields for the manufacturing ingredients
                    xmlWriter.WriteAttributeString("Userfield1_" + i.ToString(), prod.UserField1);
                    xmlWriter.WriteAttributeString("Userfield2_" + i.ToString(), prod.UserField2);
                    xmlWriter.WriteAttributeString("Userfield3_" + i.ToString(), prod.UserField3);
                    xmlWriter.WriteAttributeString("Storesdesc"  + i.ToString(), prod.Description.Replace('!', ' '));
                    xmlWriter.WriteAttributeString("Gendesc"     + i.ToString(), prod.Description.Replace('!', ' '));
                    xmlWriter.WriteAttributeString("SupTradeName"+ i.ToString(), prod.SupplierTradename);
                    xmlWriter.WriteAttributeString("LabelDescriptionInPatient"  + i.ToString(), prod.LabelDescriptionInPatient);
                    xmlWriter.WriteAttributeString("LabelDescriptionOutPatient" + i.ToString(), prod.LabelDescriptionOutPatient);
                    xmlWriter.WriteAttributeString("LocalDescription" + i.ToString(), prod.LocalDescription);
                    // End of 182077
                }

                // Clear extra ingredients
                for (int i = this.SupplyRequestIngredients.Count + 1; i <= WFormula.MaxIngredientCount; i++)
                {
                    xmlWriter.WriteAttributeString("ItemCode"   + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("tradename"  + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("ItemDesc"   + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("ibatchno"   + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("iexpiry"    + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("supcode"    + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("supname"    + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("dunits"     + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("iunits"     + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("ItemQty"    + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("Item4Qty"   + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("TotalPacks" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("rTotalPacks"+ i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("rtotalunits"+ i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("totalunits" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("issued"     + i.ToString(), string.Empty);

                    // XN 20Apr17 182077 Added new printer fields for the manufacturing ingredients
                    xmlWriter.WriteAttributeString("Userfield1_" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("Userfield2_" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("Userfield3_" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("Storesdesc"  + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("Gendesc"     + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("SupTradeName"+ i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("LabelDescriptionInPatient"  + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("LabelDescriptionOutPatient" + i.ToString(), string.Empty);
                    xmlWriter.WriteAttributeString("LocalDescription" + i.ToString(), string.Empty);
                    // End of 182077
                }

                // Totals
                double? totalVol = this.SupplyRequest.VolumeOfInfusionInmL * (double)this.SupplyRequest.QuantityRequested;
                double? volDiff  = this.SupplyRequest.VolumeOfInfusionInmL - ingVol;
                xmlWriter.WriteAttributeString("rtotalvol",totalVol == null ? string.Empty : ((int)Math.Ceiling(totalVol.Value)).ToString("0.##"));
                xmlWriter.WriteAttributeString("totalvol", totalVol == null ? string.Empty : totalVol.ToString("0.##"));
                xmlWriter.WriteAttributeString("rvoldiff", volDiff  == null ? string.Empty : ((int)Math.Ceiling(volDiff.Value)).ToString("0.##"));
                xmlWriter.WriteAttributeString("voldiff",  volDiff  == null ? string.Empty : volDiff.ToString("0.##"));

                xmlWriter.WriteAttributeString("dose1", this.Prescription.Dose.ToString("0.##"));
                xmlWriter.WriteAttributeString("du", prescriptionUnits.ToString());

                // Get the prescription comment 22Aug16 XN 160920
                var comment = Database.ExecuteSQLScalar<string>("select amm.Comment from RequestStatus rs JOIN AMMForManufactureNote amm ON rs.AMMForManufacture__NoteID = amm.NoteID WHERE rs.RequestID={0}", this.Prescription.RequestID);  
                xmlWriter.WriteAttributeString("RxComment", comment ?? string.Empty);
                
                // Added time each state change occurred, and by who 22Aug16 XN 160920
                AMMStateChangeNote stateChangeNotes = new AMMStateChangeNote();
                stateChangeNotes.LoadByRequestID(this.SupplyRequest.RequestID);
                for (var state = aMMState.WaitingScheduling; state <= aMMState.Completed; state++)
                {
                    xmlWriter.WriteAttributeString("AMMState" + ((int)state).ToString(), aMMSetting.StateString(state));

                    string xmlPrefix = "ammState" + ((int)state).ToString();
                    AMMStateChangeNoteRow stateNoteRow = null;
                    if (state < this.SupplyRequest.State)
                        stateNoteRow =  stateChangeNotes.Where(s => s.FromState == state).OrderByDescending(s => s.CreatedDate).FirstOrDefault();
                    xmlWriter.WriteAttributeString(xmlPrefix + "Date",     stateNoteRow == null ? string.Empty : stateNoteRow.CreatedDate.ToPharmacyDateTimeString());
                    xmlWriter.WriteAttributeString(xmlPrefix + "Name",     stateNoteRow == null ? string.Empty : this.GetPerson(stateNoteRow.EntityID).ToString());
                    xmlWriter.WriteAttributeString(xmlPrefix + "Initials", stateNoteRow == null ? string.Empty : this.GetPerson(stateNoteRow.EntityID).Initials);
                }
                
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Resync's the data between the Label and the translog
        /// After label has been created
        /// </summary>
        /// <param name="requestIdWLabel">Label request Id</param>
        public void ResyncLabel(int requestIdWLabel)
        {
            // Get the label
            WLabel label = new WLabel();
            label.LoadByRequestID(requestIdWLabel);            
            this.Label = label[0];

            // Set the label prescription number
            this.Label.PrescriptionNumber = this.SupplyRequest.PrescriptionNumber;
            label.Save();

            // Update the wtranslog
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET DirCode='{0}', RequestID_Dispensing={1} WHERE RequestID_AmmSupplyRequest={2} AND DirCode IS NULL AND RequestID_Dispensing IS NULL", this.Label.Direction, requestIdWLabel, this.SupplyRequest.RequestID);

            // Update the PharmacyLabelReprint
            Database.ExecuteSQLNonQuery("UPDATE PharmacyLabelReprint SET RequestID_AmmSupplyRequest={0} WHERE WLabelID={1} AND RequestID_AmmSupplyRequest IS NULL",  this.SupplyRequest.RequestID, this.Label.RequestID);
            Database.ExecuteSQLNonQuery("UPDATE PharmacyLabelReprint SET WLabelID={0} WHERE RequestID_AmmSupplyRequest={1} AND WLabelID IS NULL",  					 this.Label.RequestID, this.SupplyRequest.RequestID);
        }

        /// <summary>
        /// Will return a label
        /// Sets the WLabel row as a return
        /// Clears the AmmSupplyRequest.RequestIdWLabel field
        /// </summary>
        public void ReturnLabel()
        {
            if (this.SupplyRequest.RequestIdWLabel != null)
            {
                DateTime now = DateTime.Now;

                var columnInfo = WLabel.GetColumnInfo();
                WLabel label = new WLabel();
                label.LoadByRequestID(this.SupplyRequest.RequestIdWLabel.Value);
                label[0].LastQty            = 0;
                label[0].LastDate           = now;
                //label[0].FinalVolume        = 0;
                label[0].InfusionTime       = 0;
                label[0].DispID             = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.DispIDLength);
                label[0].NodIssued          = 0;
                label[0].BatchNumber        = label[0].BatchNumber+1;
                label[0].RxNodIssued        = 0;
                label[0].LastSavedDateTime  = now;
                //this.SupplyRequest.RequestIdWLabel = null;
				this.SupplyRequest.IfHadLabelStage = false;

                label.Save();
                this.supplyRequest.Save();
            }
        }

        /// <summary>
        /// Calculate the number of labels that are required to be printed
        /// Depends on formula ExtraLabels, NumberOfLabels
        /// PatMed settings SpareCIVASlabelsBatch, SpareCIVASlabelsDose
        /// The supply request quantity, and the number of syringes
        /// 02Aug16 XN  159413
        /// </summary>
        /// <returns></returns>
        public int CalculateNumberOfLabels()
        {
            int extraLabelsBatch = (this.Formula.ExtraLabels    > 0) ? this.Formula.ExtraLabels        : WConfiguration.Load(SessionInfo.SiteID, "D|PATMED", string.Empty, "SpareCIVASlabelsBatch", 0, false);
            int extraLabelsDose  = (this.Formula.NumberOfLabels > 0) ? this.Formula.NumberOfLabels - 1 : WConfiguration.Load(SessionInfo.SiteID, "D|PATMED", string.Empty, "SpareCIVASlabelsDose",  0, false);
            int extraLabels      = ((int)Math.Ceiling(this.SupplyRequest.QuantityRequested.Value) * extraLabelsDose) + extraLabelsBatch;
            return ((int)Math.Ceiling(this.SupplyRequest.QuantityRequested.Value) + extraLabels) * this.SupplyRequest.NumberOfSyringes;
            //return aMMProcessor.CalculateNumberOfSyringes(supplyRequest.VolumeOfInfusionInmL.Value) * (((int)supplyRequest.QuantityRequested.Value * formula.NumberOfLabels) + formula.ExtraLabels);
        }

        /// <summary>Removes manufacture date (recal expiry) and saves</summary>
        public void ClearManufactureDate()
        {
            this.SupplyRequest.ManufactureDate              = null;
            this.SupplyRequest.ManufactureShiftID           = null;
            this.UpdateSupplyRequestExpiry(); 
            this.supplyRequest.Save();
        }

        /// <summary>Locks the supply request 19Aug16 XN 160567</summary>
        public void LockSupplyRequest()
        {
            int supplyRequestId = this.SupplyRequest.RequestID;

            try
            {
                this.supplyRequest.RowLockingOption = LockingOption.HardLock;
                this.supplyRequest.PreventUnlockOnDispose = true;
                this.supplyRequest.LoadByRequestID(supplyRequestId);
            }
            catch (HardLockException ex) 
            {
                // supply request is not loaded if lock fails so reload in non locked mode (else causes issues)
                this.supplyRequest.RowLockingOption = LockingOption.None;
                this.supplyRequest.LoadByRequestID(supplyRequestId);
                throw ex;
            }
        }

        /// <summary>
        /// Called when worksheet is printed
        /// Write to the history
        /// Will mark worksheet printed on supply request
        /// 19Aug16 XN 160567
        /// </summary>
        /// <param name="reprint">If reprint</param>
        /// <param name="layout">name of layout printed or empty string if reprint</param>
        public void PrintedWorksheet(bool reprint, string layout = "")
        {
            AttachedNote note = new AttachedNote();
            note.Add((reprint ? "Reprinted" : "Printed") + " worksheet " + layout);
            note.Save();
            this.SupplyRequest.LinkNote(note[0].NoteID);

            this.SupplyRequest.IfPrintedWorksheet = true;
            this.supplyRequest.Save();
        }

        /// <summary>
        /// Called when label is printed
        /// Write to the history
        /// Will mark label printed on supply request
        /// 19Aug16 XN 160567
        /// </summary>
        /// <param name="reprint">If reprint</param>
        public void PrintedLabel(bool reprint)
        {
            AttachedNote note = new AttachedNote();
            note.Add((reprint ? "Reprinted" : "Printed") + " label");
            note.Save();
            this.SupplyRequest.LinkNote(note[0].NoteID);

            this.SupplyRequest.IfPrintedLabel = true;
            this.supplyRequest.Save();
        }
    }
}
