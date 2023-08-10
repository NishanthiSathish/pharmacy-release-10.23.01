//===========================================================================
//
//							       Prescription.cs
//
//  Provides access to Prescription table.
//  
//  When you iterate through prescriptions, you can cast them to either 
//  PrescriptionStandardRow, PrescriptionDoselessRow, or PrescriptionInfusionRow types.
//  
//  e.g. 
//  Prescription prescription = new Prescription();
//  prescription.LoadByRequestID(456);
//  if (prescription is PrescriptionStandardRow)
//      MessageBox.Show("Does is " + (prescription as PrescriptionStandardRow).Dose);
// 
//  SP for this object should return the following fields
//      [Request].[RequestID]
//      [Request].[RequestTypeID]
//      [Request].[Description]
//      [Request].[RequestDate]
//      [Request].[RequestID_Orignal]
//      [RequestStatus].[Request Cancellation]
//      [Prescription].[ProductID]  or Ingredient.ProductID for infusions
//      [Prescription].[ProductRouteID]
//      [Prescription].[ScheduleID_Administration]
//      [Prescription].[PRN]
//      [Prescription].[UnitID_Duration]
//      [Prescription].[Duration]
//      [Prescription].[StartDate]
//      [Prescription].[StopDate]
//      [Prescription].[ArbTextID_Direction]
//      [Prescription].[AdministrationStatusID]
//      [Product].ProductTypeID  (Ingredient.ProductID to Product.ProductTypeID for infusions)
//      [Ingredient].ProductFormID (for primary ingredient only)
//      [Ingredient].ProductID "Ingredient_ProductID" (for primary ingredient only)
// Left join [Ingredient] with fields (primary ingredient)
//      [Ingredient].ProductID      as Ingredient_ProductID
//      [Ingredient].Quantity       as Ingredient_Quantity
//      [Ingredient].QuantityMin    as Ingredient_QuantityMin
//      [Ingredient].QuantityMax    as Ingredient_QuantityMin
//      [Ingredient].UnitID         as Ingredient_UnitID
//      [Ingredient].UnitID_Time    as Ingredient_UnitID_Time
// Left join [PrescriptionStandard] with fields
//      [PrescriptionStandard].UnitID_Dose
//      [PrescriptionStandard].ProductFormID_Dose
//      [PrescriptionStandard].Dose
//      [PrescriptionStandard].DoseLow
//      [PrescriptionStandard].SupplimentaryText "SupplimentaryText_PrescriptionStandard"   
//      [PrescriptionStandard].ProductPackageID_Dose
// Left join [PrescriptionDoseless] with fields
//      [PrescriptionDoseless].DirectionText
//      [PrescriptionDoseless].NoDoseInfo
// Left join [PrescriptionInfusion] with fields
//      [PrescriptionInfusion].UnitID_InfusionDuration
//      [PrescriptionInfusion].UnitID_RateMass
//      [PrescriptionInfusion].UnitID_RateTime
//      [PrescriptionInfusion].Continuous
//      [PrescriptionInfusion].InfusionDuration
//      [PrescriptionInfusion].InfusionDurationLow
//      [PrescriptionInfusion].Rate
//      [PrescriptionInfusion].RateMin
//      [PrescriptionInfusion].RateMax
//      [PrescriptionInfusion].SupplimentaryText "SupplimentaryText_PrescriptionInfusion"   
//      [PrescriptionInfusion].InfusionLineID
//
//  Read only
//
//	Modification History:
//	30Jun09 AJK  Written
//  05Jul11 XN   Added PrescriptionStandard, PrescriptionDoseless, and 
//               PrescriptionInfusion prescription types
//  01Dec11 XN   Update Prescription due to change to ICWTypes
//  04May12 AJK  31212 Added LoadMergeItemsByRequestID
//  18Jun15 XN   39882 Got ProductID working correctly for infusions
//               Added Dose, DoseLow, DoseHigh, UnitID_Dose, UnitID_DoseTime, 
//               Removed LoadMergeItemsByRequestID, added GetByRequestID
//  15Sep15 XN   129200 Added PrescriptionRow.ProductFormId got infusions to 
//               return correct product and product type
//  24Sep15 TH   130101 Added PrescriptionRow.Ingredient_ProductID
//  01Dec15 XN   136911 Added IsWhenRequired, SingleDose, and SeeAccompanyingPaperwork 
//  13May16 XN   39882 PrescriptionInfusionRow updated dose to HighDose if no ingredient does
//  27May16 XN   154229 added RequestIDOriginal and IsCancelled
//===========================================================================
namespace ascribe.pharmacy.icwdatalayer
{
    using System;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.basedatalayer;

    /// <summary>Prescription row</summary>
    public class PrescriptionRow : BaseRow
    {
        /// <summary>Minimum value user can enter for a dose value 18Jun15 XN 39882</summary>
        protected const double MinDose = 0.0000001;

        public int RequestID                { get { return FieldToInt(RawRow["RequestID"]).Value;                   } }
        public int RequestTypeID            { get { return FieldToInt(RawRow["RequestTypeID"]).Value;               } }
        public string Description           { get { return FieldToStr(RawRow["Description"]);                       } }
        public DateTime RequestDate         { get { return FieldToDateTime(RawRow["RequestDate"]).Value;            } }
        public int? RequestIDOriginal       { get { return FieldToInt(RawRow["RequestID_Original"]);                } }
        public bool IsCancelled             { get { return FieldToBoolean(RawRow["Request Cancellation"]).Value;    } }
        virtual public int ProductID        { get { return FieldToInt(RawRow["ProductID"]).Value;                   } }
        virtual public int ProductTypeID    { get { return FieldToInt(RawRow["ProductTypeID"]).Value;               } }
        public int ProductRouteID           { get { return FieldToInt(RawRow["ProductRouteID"]).Value;              } }
        public int ScheduleID_Administration{ get { return FieldToInt(RawRow["ScheduleID_Administration"]).Value;   } }
        public bool PRN                     { get { return FieldToBoolean(RawRow["PRN"]).Value;                     } }
        public int? UnitID_Duration         { get { return FieldToInt(RawRow["UnitID_Duration"]);                   } }
        public int? Duration                { get { return FieldToInt(RawRow["Duration"]);                          } }
        public DateTime StartDate           { get { return FieldToDateTime(RawRow["StartDate"]).Value;              } }
        public DateTime? StopDate           { get { return FieldToDateTime(RawRow["StopDate"]);                     } }
        public int? ArbTextID_Direction     { get { return FieldToInt(RawRow["ArbTextID_Direction"]);               } }
        public int? AdministrationStatusID  { get { return FieldToInt(RawRow["AdministrationStatusID"]);            } }
        public int? ProductFormId           { get { return FieldToInt(RawRow["ProductFormID"]);                     } } // 15Sept15 XN Added 129200
        public int? Ingredient_ProductID    { get { return FieldToInt(RawRow["Ingredient_ProductID"]);              } } // 24Sept15 TH Added 130101 

        virtual public bool NoDoseInfo { get { return false; } }    // 01Dec15 XN 136911 Added

        public bool IsWhenRequired          { get { return (FieldToBoolean(RawRow["IsWhenRequired"]) ?? false) || (FieldToBoolean(RawRow["IsIfRequired"]) ?? false) || (this.PRN && this.ScheduleID_Administration == 0); } } // 01Dec15 XN 136911 Added
        public bool SingleDose              { get { return !this.IsWhenRequired && (this.ScheduleID_Administration == 0) && !this.NoDoseInfo; } }   // 01Dec15 XN 136911 Added
        public bool SeeAccompanyingPaperwork{ get { return !this.PRN && (this.ScheduleID_Administration == 0) && this.NoDoseInfo;             } }   // 01Dec15 XN 136911 Added

        /// <summary>
        /// Gets the dose either from prescription, rate (infusion), or primary Ingredient (infusion), or null of doseless
        /// If prescription has a dose range this will be the high
        /// 18Jun15 XN 39882
        /// </summary>
        public virtual double? Dose { get { return null; } }

        /// <summary>
        /// Gets the dose low value either from prescription, min rate (infusion), or primary Ingredient (infusion), or null of doseless
        /// If prescription has a dose range this will be the low
        /// 18Jun15 XN 39882
        /// </summary>
        public virtual double? DoseLow { get { return null; } }

        /// <summary>Gets the dose high value (infusion only) either max rate, or primary Ingredient</summary>
        public virtual double? DoseHigh { get { return null; } }

        /// <summary>
        /// Gets unit id for dose either from prescription or ingredient
        /// For infusion this will be the mass part only
        /// 18Jun15 XN 39882
        /// </summary>
        public virtual int? UnitID_Dose { get { return null; } }

        /// <summary>Gets unit id for time for infusion 18Jun15 XN 39882</summary>
        public virtual int? UnitID_DoseTime { get { return null; } }
    }

    /// <summary>Represents a record in the PrescriptionStandard, Prescription tables</summary>
    public class PrescriptionStandardRow : PrescriptionRow 
    {
        public int?    ProductFormID_Dose       { get { return FieldToInt(RawRow["ProductFormID_Dose"]);    } }
        public string  DirectionText            { get { return  FieldToStr(RawRow["SupplimentaryText_PrescriptionStandard"]);    } }
        public int?    ProductPackageID_Dose    { get { return FieldToInt(RawRow["ProductPackageID_Dose"]); } }

        /// <summary>
        /// Gets the dose either from prescription standard
        /// If prescription has a dose range this will be the high
        /// 18Jun15 XN 39882
        /// </summary>
        public override double? Dose { get { return FieldToDouble(RawRow["Dose"]).Value; } }
        
        public override double? DoseLow
        {
            get
            {
                var dose = FieldToDouble(RawRow["DoseLow"]);
                return dose < PrescriptionRow.MinDose ? (double?)null : dose;
            }
        }

        public override double? DoseHigh        { get { return null;                                    } }
        public override int?    UnitID_Dose     { get { return FieldToInt(RawRow["UnitID_Dose"]).Value; } }
        public override int?    UnitID_DoseTime { get { return null;                                    } }

        public bool HasDoseRange { get { return this.Dose > PrescriptionRow.MinDose && this.DoseLow > PrescriptionRow.MinDose; } }
    }

    /// <summary>Represents a record in the PrescriptionDoseless, Prescription tables</summary>
    public class PrescriptionDoselessRow : PrescriptionRow 
    {
        public string        DirectionText   { get { return  FieldToStr(RawRow["DirectionText"]);        } }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
        public override bool NoDoseInfo      { get { return FieldToBoolean(RawRow["NoDoseInfo"]).Value;  } }

        /// <summary>Returns null 18Jun15 XN 39882</summary>
        public override double? Dose { get { return null; } }

        public override double? DoseLow         { get { return null; } }
        public override double? DoseHigh        { get { return null; } }
        public override int?    UnitID_Dose     { get { return null; } }
        public override int?    UnitID_DoseTime { get { return null; } }
    }

    /// <summary>Represents a record in the PrescriptionInfusion, Prescription tables</summary>
    public class PrescriptionInfusionRow : PrescriptionRow
    {
        /// <summary>Returns the prescription primary product ID. Overrides base class as for infusion product id comes from ingredient! 16Sep15 XN 129200</summary>
        override public int ProductID          { get { return FieldToInt(RawRow["Ingredient_ProductID"]) ?? 0;     } }

        /// <summary>Returns the prescription primary product type ID. Overrides base class as for infusion product type id comes from ingredient! 16Sep15 XN 129200</summary>
        override public int ProductTypeID   { get { return FieldToInt(RawRow["Ingredient_ProductTypeID"]).Value; } }

        public int?    UnitID_InfusionDuration  { get { return FieldToInt(RawRow["UnitID_InfusionDuration"]);                } }
        public int?    UnitID_RateMass          { get { return FieldToInt(RawRow["UnitID_RateMass"]);                        } }
        public int?    UnitID_RateTime          { get { return FieldToInt(RawRow["UnitID_RateTime"]);                        } }
        public bool    Continuous               { get { return FieldToBoolean(RawRow["Continuous"]) ?? Rate != null;         } }
        public double? InfusionDuration         { get { return FieldToDouble(RawRow["InfusionDuration"]);                    } }
        public double? InfusionDurationLow      { get { return FieldToDouble(RawRow["InfusionDurationLow"]);                 } }
        public double? Rate                     { get { return FieldToDouble(RawRow["Rate"]);                                } }
        public double? RateMin                  { get { return FieldToDouble(RawRow["RateMin"]);                             } }
        public double? RateMax                  { get { return FieldToDouble(RawRow["RateMax"]);                             } }
        public string  DirectionText            { get { return FieldToStr(RawRow["SupplimentaryText_PrescriptionInfusion"]); } }
        public int     InfusionLineID           { get { return FieldToInt(RawRow["InfusionLineID"]).Value;                   } }
        
        /// <summary>Gets the dose if continuous then rate else ingredient 18Jun15 XN 39882</summary>
        public override double? Dose
        {
            get
            {
                var dose = this.Continuous ? this.Rate : FieldToDouble(RawRow["Ingredient_Quantity"]);
                //return dose < PrescriptionRow.MinDose ? (double?)null : dose;  13May16 XN  39882 uses high does if no dose
                return dose < PrescriptionRow.MinDose ? (double?)null : (dose ?? this.DoseHigh);
            }
        }

        public override double? DoseLow
        {
            get
            {
                var dose = this.Continuous ? this.RateMin : FieldToDouble(RawRow["Ingredient_QuantityMin"]);
                return dose < PrescriptionRow.MinDose ? (double?)null : dose;
            }
        }

        public override double? DoseHigh
        {
            get
            {
                var dose = this.Continuous ? this.RateMax : FieldToDouble(RawRow["Ingredient_QuantityMax"]);
                return dose < PrescriptionRow.MinDose ? (double?)null : dose;
            }
        }  

        public override int?    UnitID_Dose     { get { return this.Continuous ? this.UnitID_RateMass : FieldToInt   (RawRow["Ingredient_UnitID"]);         } }
        public override int?    UnitID_DoseTime { get { return this.Continuous ? this.UnitID_RateTime : FieldToInt   (RawRow["Ingredient_UnitID_Time"]);    } }
    }

    public class PrescriptionColumnInfo : BaseColumnInfo
    {
        public PrescriptionColumnInfo() : base("Prescription") { }
    }

    

    public class Prescription : BaseTable<PrescriptionRow, PrescriptionColumnInfo>
    {
        #region Private Members
        private int requestTypeID_PrescriptionStandard = -1;
        private int requestTypeID_PrescriptionDoseless = -1;
        private int requestTypeID_PrescriptionInfusion = -1;        
        #endregion

        public Prescription() : base("Prescription", "RequestID")
        {
            requestTypeID_PrescriptionStandard = ICWTypes.GetTypeByDescription(ICWType.Request, "Standard Prescription").Value.ID;
            requestTypeID_PrescriptionDoseless = ICWTypes.GetTypeByDescription(ICWType.Request, "Doseless Prescription").Value.ID;
            requestTypeID_PrescriptionInfusion = ICWTypes.GetTypeByDescription(ICWType.Request, "Infusion Prescription").Value.ID;
        }

        public void LoadByRequestID(int requestID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RequestID", requestID);
            LoadRecordSetStream("pPrescriptionRawSelect", parameters);
        }

        /// <summary>Loads all active prescriptions for a patient (from an any episode), whose product is in a specified chemical family</summary>
        /// <param name="episodeID">episode ID for patient (method always loads same row independent of which patient's episode is chosen)</param>
        /// <param name="productID_Chemical">chemical for the product family of interest</param>
        public void LoadByPatientProductFamilyAndActive(int episodeID, int productID_Chemical)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "EpisodeID", episodeID);
            AddInputParam(parameters, "ProductID_Chemical", productID_Chemical);
            LoadRecordSetStream("pPrescriptionByPatientProductFamilyAndActive", parameters);
        }

        /// <summary>Allows iteration through the rows</summary>
        /// <param name="index">Row index (of loaded data).</param>
        /// <returns>data row</returns>
        public override PrescriptionRow  this[int index]
        {
            get
            {
                PrescriptionRow row;
                int requestTypeID = (int)Table.Rows[index]["RequestTypeID"];

                if (requestTypeID == requestTypeID_PrescriptionStandard)
                    row = new PrescriptionStandardRow();
                else if (requestTypeID == requestTypeID_PrescriptionDoseless)
                    row = new PrescriptionDoselessRow();
                else if (requestTypeID == requestTypeID_PrescriptionInfusion)
                    row = new PrescriptionInfusionRow();
                else 
                    row = new PrescriptionRow();

                row.RawRow = Table.Rows[index];
                return row;
            }
        }

        /// <summary>Returns prescription by request ID or null</summary>
        /// <param name="requestId">Request Id</param>
        /// <returns>Prescription or null</returns>
        public static PrescriptionRow GetByRequestID(int requestId)
        {
            Prescription prescription = new Prescription();
            prescription.LoadByRequestID(requestId);
            return prescription.FirstOrDefault();
        }
    }
    
}
