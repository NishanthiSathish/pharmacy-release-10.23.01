// -----------------------------------------------------------------------
// <copyright file="aMMSupplyRequest.cs" company="Emis Health">
//      Copyright Emis Health Plcs
// </copyright>
// <summary>
// This class represents the AMMSupplyRequest table.  
//
// Classes are derived from SupplyRequest, EpisodeOrder, and Request.
//
// Only supports reading, updating, and inserting from table.
//
// Whenever data is saved the class will automatically update the UpdateDate 
// on any modified rows
//
// Modification History:
// 29May15 XN Created 39882
// 08Aug16 XN Added ExpiryDate 159843
// 19Aug16 XN 160567 Added ExpiryFromDate, and ToXmlHeap
// 26Aug16 XN Added IfHadLabelStage	
//  XN 26Aug16 161288 GetCountforManufactureDate to include completed items
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.Linq;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.icwdatalayer;
    using ascribe.pharmacy.shared;
    using System.Xml;
    using System.Text;

    /// <summary>AMM supply request state</summary>
    public enum aMMState
    {
        /// <summary>Just after request has been created, and is waiting to be scheduled</summary>
        WaitingScheduling,

        /// <summary>Waiting for production tray</summary>
        WaitingProductionTray,

        /// <summary>Production tray scanned waiting for assembly</summary>
        ReadyToAssemble,

        /// <summary>Waiting to be checked</summary>
        ReadyToCheck,

        /// <summary>Items have been checked waiting for compounding image</summary>
        ReadyToCompound,

        /// <summary>Items are ready to be labeled</summary>
        ReadyToLabel,
        
        /// <summary>Final check</summary>
        FinalCheck,

        /// <summary>Currently in bond store</summary>
        BondStore,

        /// <summary>Ready for release</summary>
        ReadyToRelease,

        /// <summary>Supply request is complete</summary>
        Completed,
    }

    /// <summary>Volume to user has selected for the supply request</summary>
    public enum aMMVolumeType
    {
        /// <summary>Fixed volume</summary>
        [EnumDBCode("F")]
        Fixed,

        /// <summary>Volume is drug volume + nominal amount</summary>
        [EnumDBCode("N")]
        DrugAndNominal
    }

    /// <summary>If using a syringe the type fill method</summary>
    public enum aMMSyringeFillType
    {
        /// <summary>No syringe</summary>
        None,

        /// <summary>Single syringe</summary>
        [EnumDBCode("S")]
        Single,

        /// <summary>Split syringes evenly</summary>
        [EnumDBCode("E")]
        EvenSplit,

        /// <summary>Fill syringes with remainder in final one</summary>
        [EnumDBCode("F")]
        FullAndPart
    }

    /// <summary>Current issuing state</summary>
    public enum aMMIssueState
    {
        /// <summary>Not issued yet</summary>
        [EnumDBCode("")]
        None,

        /// <summary>Ingredient have been issued (manufactured item has been returned)</summary>
        [EnumDBCode("I")]
        IssuedIngredients,

        /// <summary>Manufactured item has returned to bond store</summary>
        [EnumDBCode("B")]
        IssuedToBondStore,

        /// <summary>Manufactured item has been issued from bond store</summary>
        [EnumDBCode("R")]
        ReleasedFromBondStore,

        /// <summary>Manufactured item has been issued to patient</summary>
        [EnumDBCode("P")]
        IssuedToPatient
    }

    /// <summary>A row in the supply request table</summary>
    public class aMMSupplyRequestRow : SupplyRequestRow
    {
        /// <summary>Gets or sets the site id</summary>
        public int SiteID
        {
            get { return FieldToInt(this.RawRow["SiteID"]).Value; }
            set { this.RawRow["SiteID"] = IntToField(value);      }
        }

        /// <summary>Gets or sets the WFormula</summary>
        public int WFormulaID
        {
            get { return FieldToInt(this.RawRow["WFormulaID"]).Value; }
            set { this.RawRow["WFormulaID"] = IntToField(value);      }
        }

        /// <summary>Gets or sets NSV Code of the formula</summary>
        public string NSVCode
        {
            get { return FieldToStr(this.RawRow["NSVCode"], true, string.Empty); }
            set { this.RawRow["NSVCode"] = StrToField(value);                    }
        }

        /// <summary>Gets or sets the batch number</summary>
        public string BatchNumber
        {
            get { return FieldToStr(this.RawRow["BatchNumber"], true, string.Empty); }
            set { this.RawRow["BatchNumber"] = StrToField(value);                    }
        }

        /// <summary>Gets or sets the production tray barcode</summary>
        public string ProductionTrayBarcode
        {
            get { return FieldToStr(this.RawRow["ProductionTrayBarcode"], true, string.Empty); }
            set { this.RawRow["ProductionTrayBarcode"] = StrToField(value);                    }
        }

        /// <summary>Gets or sets the date that the item is to be made</summary>
        public DateTime? ManufactureDate
        {
            get { return FieldToDateTime(this.RawRow["ManufactureDate"]);  }
            set { this.RawRow["ManufactureDate"] = DateTimeToField(value); }
        }

        /// <summary>Gets or sets ammShiftID</summary>
        public int? ManufactureShiftID
        {
            get { return FieldToInt(this.RawRow["ManufactureShiftID"]);  }
            set { this.RawRow["ManufactureShiftID"] = IntToField(value); }
        }

        /// <summary>Gets or sets the state</summary>
        public aMMState State
        {
            get { return FieldIntToEnum<aMMState>(this.RawRow["State"]).Value; }
            set { this.RawRow["State"] = EnumToFieldInt<aMMState>(value);      }
        }

        /// <summary>Gets or sets a value indicating whether supply request is a priority</summary>
        public bool Priority
        {
            get { return FieldToBoolean(this.RawRow["Priority"]).Value; }
            set { this.RawRow["Priority"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets the volume type</summary>
        public aMMVolumeType VolumeType
        {
            get { return FieldToEnumByDBCode<aMMVolumeType>(this.RawRow["VolumeType"]); }
            set { this.RawRow["VolumeType"] = EnumToFieldByDBCode(value);               }
        }

        /// <summary>Gets or sets the volume of infusion in mL</summary>
        public double? VolumeOfInfusionInmL
        {
            get { return FieldToDouble(this.RawRow["VolumeOfInfusion_mL"]);  }
            set { this.RawRow["VolumeOfInfusion_mL"] = DoubleToField(value); }
        }

        /// <summary>If using syringes then gets the syringe fill type</summary>
        public aMMSyringeFillType SyringeFillType
        {
            get { return FieldToEnumByDBCode<aMMSyringeFillType>(this.RawRow["SyringeFillType"]);  }
            set { this.RawRow["SyringeFillType"] = EnumToFieldByDBCode(value);                    }
        }

        /// <summary>Gets or sets the number of syringes</summary>
        public int NumberOfSyringes
        {
            get { return FieldToInt(this.RawRow["NumberOfSyringes"]).Value; }
            set { this.RawRow["NumberOfSyringes"] = IntToField(value);      }
        }

        /// <summary>Gets or sets volume of a syringe</summary>
        public double SyringeVolumemL
        {
            get { return FieldToDouble(this.RawRow["SyringeVolume_mL"]).Value;  }
            set { this.RawRow["SyringeVolume_mL"] = DoubleToField(value);       }
        }

        /// <summary>Gets or sets does of a syringe</summary>
        public double SyringeDosemg
        {
            get { return FieldToDouble(this.RawRow["SyringeDose_mg"]).Value;  }
            set { this.RawRow["SyringeDose_mg"] = DoubleToField(value);       }
        }

        /// <summary>Gets or sets final volume of a syringe</summary>
        public double SyringeFinalVolumemL
        {
            get { return FieldToDouble(this.RawRow["SyringeFinalVolume_mL"]).Value;  }
            set { this.RawRow["SyringeFinalVolume_mL"] = DoubleToField(value);       }
        }

        /// <summary>Gets or sets final does of a syringe</summary>
        public double SyringeFinalDosemg
        {
            get { return FieldToDouble(this.RawRow["SyringeFinalDose_mg"]).Value;  }
            set { this.RawRow["SyringeFinalDose_mg"] = DoubleToField(value);       }
        }

        /// <summary>Gets or sets the dose value</summary>
        public double Dose
        {
            get { return FieldToDouble(this.RawRow["Dose"]).Value; }
            set { this.RawRow["Dose"] = DoubleToField(value);      }
        }

        /// <summary>Gets or sets the dose unit id</summary>
        public int UnitIdDose
        {
            get { return FieldToInt(this.RawRow["UnitID_Dose"]).Value; }
            set { this.RawRow["UnitID_Dose"] = IntToField(value);      }
        }

        /// <summary>Gets or sets the compounding date</summary>
        public DateTime? CompoundingDate
        {
            get { return FieldToDateTime(this.RawRow["CompoundingDate"]);  }
            set { this.RawRow["CompoundingDate"] = DateTimeToField(value); }
        }

        /// <summary>Gets or sets the Second check type</summary>
        public aMMSecondCheckType SecondCheckType
        {
            get { return FieldToEnumByDBCode<aMMSecondCheckType>(this.RawRow["SecondCheckType"]); }
            set { this.RawRow["SecondCheckType"] = EnumToFieldByDBCode(value);                    }
        }

        /// <summary>Person who performed the last state update</summary>
        public int EntityID_LastStateUpdate
        {
            get { return FieldToInt(this.RawRow["EntityID_LastStateUpdate"]).Value; }
            set { this.RawRow["EntityID_LastStateUpdate"] = IntToField(value);      }
        }

        /// <summary>Date and time of the last state update</summary>
        public DateTime DateTime_LastStateUpdate
        {
            get { return FieldToDateTime(this.RawRow["DateTime_LastStateUpdate"]).Value; }
            set { this.RawRow["DateTime_LastStateUpdate"] = DateTimeToField(value);      }
        }

        /// <summary>The get compounded image (from the Image table)</summary>
        /// <returns>The image<see cref="byte[]"/></returns>
        public byte[] GetCompoundedImage()
        {
            int? imageIdCompounded = FieldToInt(this.RawRow["ImageID_Compounded"]);
            return imageIdCompounded == null ? null : ImageTable.GetImageByImageID(imageIdCompounded.Value);
        }

        /// 26Aug16 KR Added. 161136
        /// <summary>Get/Set compounded Image ID </summary>
        protected internal int? CompoundedImageID
        {
            get { return FieldToInt(this.RawRow["ImageID_Compounded"]);  }
            set { this.RawRow["ImageID_Compounded"] = IntToField(value); }
        }

        /// <summary>Gets or sets issue state</summary>
        public aMMIssueState IssueState
        {
            get { return FieldToEnumByDBCode<aMMIssueState>(this.RawRow["IssueState"]); }
            set { this.RawRow["IssueState"] = EnumToFieldByDBCode(value);               }
        }

        /// <summary>Gets or sets self check reason</summary>
        public string SelfCheckReason
        {
            get { return FieldToStr(RawRow["SelfCheckReason"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["SelfCheckReason"] = StrToField(value, emptyStrAsNullVal: false);            	  }
        }

        /// <summary>Saves the compounded image to the Image table</summary>
        /// <param name="image">The image</param>
        public void SetCompoundedImage(byte[] image)
        {
            int? imageIdCompounded = FieldToInt(this.RawRow["ImageID_Compounded"]);
            DateTime now = DateTime.Now;

            // Either update or create new
            ImageTable imageTable = new ImageTable();
            if (imageIdCompounded == null)
            {
                imageTable.Add();
                imageTable[0].CreatedDate = now;
            }
            else
            {
                imageTable.LoadByImageID(imageIdCompounded.Value);
            }

            // Set image
            ImageTableRow row = imageTable[0];
            row.ImageType = ImageTableType.Photograph;
            row.ImageData = image;
            row.ImageDate = now;
            row.EntityID  = SessionInfo.EntityID;
            row.Description = "Compounded Drug";
            row.Detail    = "aMM Compounded Drug";
            imageTable.Save();

            // Save image ID
            this.RawRow["ImageID_Compounded"] = IntToField(row.ImageID);
        }

        /// 26Aug16 KR Added. 161136
        public void DeleteCompoundedImage(int imageID)
        {
           ImageTable imageTable = new ImageTable();
           imageTable.DeleteImageByImageID(imageID);
        }

        /// <summary>Gets state change note that occurs after specified state</summary>
        /// <param name="afterState">change not that occurs after</param>
        /// <returns>state change note that occurs after specified state</returns>
        public AMMStateChangeNoteRow GetFirstChangeNoteAfterState(aMMState afterState)
        {
            AMMStateChangeNoteRow note = null;
            if (this.State > afterState)
            {
                AMMStateChangeNote notes = new AMMStateChangeNote();
                notes.LoadFirstAfterStateForRequestId(this.RequestID, afterState);
                note = notes.FirstOrDefault();
            }

            return note;
        }

        /// <summary>
        /// DB field EpisodeTypeID
        /// This is the selected EpisodeType (part of new supply request wizard if patient is lifetime episode)
        /// </summary>
        public EpisodeType EpisodeType 
        { 
            get { return FieldToEnumViaDBLookup<EpisodeType>(RawRow["EpisodeTypeID"]) ?? EpisodeType.Discharge; } 
            set { RawRow["EpisodeTypeID"] = this.EnumToFieldViaDBLookup<EpisodeType>(value);                    }
        }

        /// <summary>
        /// DB field PrescriptionId
        /// Prescription number that is used in the translog, allocated at start of the process
        /// </summary>
        public int PrescriptionNumber
        {
            get { return FieldToInt(RawRow["PrescriptionId"]).Value;  }
            set { RawRow["PrescriptionId"] = IntToField(value);       }
        }

        /// <summary>
        /// DB field RequestID_WLabel
        /// The last label printed with this prescription
        /// </summary>
        public int? RequestIdWLabel
        {
            get { return FieldToInt(RawRow["RequestID_WLabel"]);  }
            set { RawRow["RequestID_WLabel"] = IntToField(value); }
        }

        /// <summary>The last calculated expiry date</summary>
        public DateTime? ExpiryDate
        {
            get { return FieldToDateTime(RawRow["ExpiryDate"]);  }
            set { RawRow["ExpiryDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The date from which the expiry is calculated 
        /// Can be the shift start time or the compounding time depending on settings
        /// Done like this as the other setting could be changed so there is no fixed start point
        /// 19Aug16 XN 160567
        /// </summary>
        public DateTime? ExpiryFromDate
        {
            get { return FieldToDateTime(RawRow["ExpiryFromDate"]);  }
            set { RawRow["ExpiryFromDate"] = DateTimeToField(value); }
        }

        /// <summary>If worksheet has been printed yet 19Aug16 XN 160567</summary>
        public bool IfPrintedWorksheet
        {
            get { return FieldToBoolean(RawRow["IfPrintedWorksheet"]) ?? false;  }
            set { RawRow["IfPrintedWorksheet"] = BooleanToField(value);          }
        }

        /// <summary>If label has been printed yet 19Aug16 XN 160567</summary>
        public bool IfPrintedLabel
        {
            get { return FieldToBoolean(RawRow["IfPrintedLabel"]) ?? false;  }
            set { RawRow["IfPrintedLabel"] = BooleanToField(value);          }
        }
		
		/// <summary>If when was made goes to label stage 26Aug16 XN</summary>
		public bool IfHadLabelStage		
		{
            get { return FieldToBoolean(RawRow["IfHadLabelStage"]) ?? false;  }
            set { RawRow["IfHadLabelStage"] = BooleanToField(value);          }
		}

        /// <summary>Converts data to xml heap 19Aug16 XN 160567</summary>
        /// <returns>Xml heap string</returns>
        public string ToXmlHeap()
        {
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

                xmlWriter.WriteAttributeString("srBatchNumber",             this.BatchNumber                                                );
                xmlWriter.WriteAttributeString("srCompoundingDate",         this.CompoundingDate.ToPharmacyDateTimeString()                 );
                xmlWriter.WriteAttributeString("srCreatedDate",             this.CreatedDate.ToPharmacyDateTimeString()                     );
                xmlWriter.WriteAttributeString("srLastStateUpdateDate",     this.DateTime_LastStateUpdate.ToPharmacyDateTimeString()        );
                xmlWriter.WriteAttributeString("srDescription",             this.Description                                                );
                xmlWriter.WriteAttributeString("srLastStateUpdatePerson",   Person.GetByEntityID(this.EntityID_LastStateUpdate).ToString()  );
                xmlWriter.WriteAttributeString("srExpiryDate",              this.ExpiryDate.ToPharmacyDateTimeString()                      );
                xmlWriter.WriteAttributeString("srExpiryFromDate",          this.ExpiryFromDate.ToPharmacyDateTimeString()                  );
                xmlWriter.WriteAttributeString("srIssueState",              aMMSetting.IssueStateString(this.IssueState)                    );
                xmlWriter.WriteAttributeString("srShiftDate",               this.ManufactureDate.ToPharmacyDateString()                     );

                aMMShiftRow shift = (this.ManufactureShiftID == null ? null : aMMShift.GetById(this.ManufactureShiftID.Value));
                xmlWriter.WriteAttributeString("srShiftDescription", shift == null ? string.Empty : shift.ToString());

                xmlWriter.WriteAttributeString("srNSVCode",                 this.NSVCode                                );
                xmlWriter.WriteAttributeString("srNumberOfSyringes",        this.NumberOfSyringes.ToString()            );
                xmlWriter.WriteAttributeString("srPriorityYesNo",           this.Priority.ToYesNoString()               );
                xmlWriter.WriteAttributeString("srPriority",                this.Priority ? "Priority" : string.Empty   );
                xmlWriter.WriteAttributeString("srProductionTrayBarcode",   this.ProductionTrayBarcode                  );
                xmlWriter.WriteAttributeString("srSecondCheckType",         this.SecondCheckType.ToString()             );
                xmlWriter.WriteAttributeString("srSelfCheckReason",         this.SelfCheckReason                        );
                xmlWriter.WriteAttributeString("srState",                   aMMSetting.StateString(this.State)          );
                xmlWriter.WriteAttributeString("srSyringeFillType",         this.SyringeFillType.ToString()             );
                xmlWriter.WriteAttributeString("srVolumeType",              this.VolumeType.ToString()                  );

                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }

    /// <summary>AMM supply request column info</summary>
    public class aMMSupplyRequestColumnInfo : SupplyRequestColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="aMMSupplyRequestColumnInfo"/> class.</summary>
        public aMMSupplyRequestColumnInfo() : base("aMMSupplyRequest") { }

        /// <summary>Gets the batch number length</summary>
        public int BatchNumberLength { get { return this.FindColumnByName("BatchNumber").Length; } }

        /// <summary>Gets the NSV Code length</summary>
        public int NSVCodeLength { get { return  this.FindColumnByName("NSVCode").Length; } }

        /// <summary>Gets the production tray barcode length</summary>
        public int ProductionTrayBarcodeLength  { get { return this.FindColumnByName("ProductionTrayBarcode").Length; } }
    }

    /// <summary>AMM supply request table</summary>
    public class aMMSupplyRequest : BaseTable2<aMMSupplyRequestRow, aMMSupplyRequestColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="aMMSupplyRequest"/> class</summary>
        public aMMSupplyRequest() : base("aMMSupplyRequest", "SupplyRequest", "EpisodeOrder", "Request")
        {
            this.ConflictOption = ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Overrides base class to set defaults</summary>
        /// <returns>The new row <see cref="aMMSupplyRequestRow"/></returns>
        public override aMMSupplyRequestRow Add()
        {
            DateTime now = DateTime.Now;
            var newRow = base.Add();
            newRow.ProductionTrayBarcode    = string.Empty;
            newRow.State                    = aMMState.WaitingScheduling;
            newRow.Priority                 = false;
            newRow.VolumeType               = aMMVolumeType.Fixed;
            newRow.RequestTypeID            = ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.ID;    
            newRow.SupplyRequestTypeID      = ICWTypes.GetTypeByDescription(ICWType.SupplyRequest, "AsepticManufacture").Value.ID;
            newRow.TableID                  = this.GetTableID();
            newRow.EntityID                 = SessionInfo.EntityID;
            newRow.CreatedDate              = now;
            newRow.ScheduleID               = 0;
            newRow.SiteID                   = SessionInfo.SiteID;
            newRow.ProductID_Mapped         = 0;
            newRow.OrderTemplateID          = 0;
            newRow.EntityID_Owner           = SessionInfo.EntityID;
            newRow.IsVirtualProduct         = false;
            newRow.EntityID_LastStateUpdate = newRow.EntityID_Owner;
            newRow.DateTime_LastStateUpdate = now;
            newRow.SelfCheckReason          = string.Empty;
			newRow.IfHadLabelStage			= false;		//  26Aug16 XN Added
            return newRow;
        }

        /// <summary>Overrides the base class to set the last update time on save</summary>
        public override void Save()
        {
            // If update state and has not update DateTine_LastStateUpdate then do here
            DateTime now = DateTime.Now;
            foreach(var row in this.Where(r => r.HasFieldChanged("State") && !r.HasFieldChanged("DateTime_LastStateUpdate")))
            {
                row.EntityID_LastStateUpdate = SessionInfo.EntityID;
                row.DateTime_LastStateUpdate = now;
            }

            base.Save();
        }

        /// <summary>The load by request id</summary>
        /// <param name="requestId">Request id</param>
        public void LoadByRequestID(int requestId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("RequestID", requestId);
            this.LoadBySP("paMMSupplyRequestByRequestID", parameters);
        }

        /// <summary>
        /// Loads first active supply request below stage defined by setting
        /// Category: D|AMM
        /// Section:
        /// Key: ProductionTrayReleasedAfterStage
        /// using the specified production tray barcode
        /// </summary>
        /// <param name="barcode">production tray barcode</param>
        public void LoadByProductionTrayAndActive(string barcode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("Barcode", barcode);
            parameters.Add("@productionTrayReleasedAfterStage", aMMSetting.ProductionTrayReleasedAfterStage);
            this.LoadBySP("paMMSupplyRequestByProductionTrayAndActiveState", parameters);
        }

        /// <summary>The get by request id</summary>
        /// <param name="requestId">The request id</param>
        /// <returns>The supply request <see cref="aMMSupplyRequestRow"/></returns>
        public static aMMSupplyRequestRow GetByRequestID(int requestId)
        {
            aMMSupplyRequest supplyRequest = new aMMSupplyRequest();
            supplyRequest.LoadByRequestID(requestId);
            return supplyRequest.FirstOrDefault();
        }

        /// <summary>Returns number of active supply request that occur between these manufacture times group by ManufactureDate XN 26Aug16 161288</summary>
        /// <param name="manufactureStartDateTime">Start date</param>
        /// <param name="manufactureEndDateTime">End date</param>
        /// <returns>Number of supply request grouped by manufacture date</returns>
        public static Dictionary<DateTime,int> GetCountByManufactureDate(DateTime manufactureStartDateTime, DateTime manufactureEndDateTime)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("ManufactureStartDateTime", manufactureStartDateTime);
            parameters.Add("ManufactureEndDateTime",   manufactureEndDateTime);

            GenericTable2 counts = new GenericTable2();
            counts.LoadBySP("pAMMSupplyRequestFreqByManufactureDate", parameters);
            return counts.ToDictionary(k => (DateTime)k.RawRow["ManufactureDate"], v => (int)v.RawRow["Count"]);
        }

        /// <summary>
        /// Returns first active supply request below stage defined by setting
        /// Category: D|AMM
        /// Section:
        /// Key: ProductionTrayReleasedAfterStage
        /// using the specified production tray barcode
        /// </summary>
        /// <param name="barcode">production tray barcode</param>
        /// <returns>supply request</returns>
        public static aMMSupplyRequestRow GetByProductionTrayAndActive(string barcode)
        {
            aMMSupplyRequest supplyRequest = new aMMSupplyRequest();
            supplyRequest.LoadByProductionTrayAndActive(barcode);
            return supplyRequest.FirstOrDefault();
        }
    }
}
