//===========================================================================
//
//							    ProductStock.cs
//
//  Provides access to ProductStock table.
//
//  The ProductStock table cotains information about the pharmacy stock levels
//  for particular products. Also includes information about total stock value
//  via an average cost value. Stock is site dependant.
//
//  SP for this object should return all fields from the ProductStock table,  
//  and a linked in fields
//      SiteProductData.siscode
//      SiteProductData.convfact
//
//  Only supports reading, and updating.
//  Saving can write changes to the WPharmacyLog
//  
//	Modification History:
//	15Apr09 XN  Written
//  19Jun09 XN  Update LoadBySiteIDAndNSVCode to use new sp to prevent break 
//              UHB Sage interface if future changes are made to thie class
//  30Jan10 XN  Add LocCode field to row object
//  02Feb10 XN  F0042698 added LoadByOrderNumber
//  18Mar10 XN  F0080744 fixed problem with robot item not at top of order info screen
//              F0080745 add manual robot loading item
//  30Sep10 XN  F0097623 add an apend option to LoadBySiteIDAndNSVCode
//  01Nov13 XN  56701 Added lots of fields for product editor
//  24Nov13 XN  78339 Moved to BaseTable2, and other changes
//  10Feb14 XN  56701 Added ModifiedDate
//  18May15 XN  117528 Added UpdateModifiedDetails, and new Save for logging, and LoadByNSVCode
//  19May15 XN  98073 Added LabelDescriptionInPatient, LabelDescriptionOutPatient, StoresDescription
//  26Oct15 XN  106278 Added LoadByProductStockIDs
//===========================================================================


namespace ascribe.pharmacy.pharmacydatalayer
{
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    public class ProductStockRow : BaseRow
    {
        public int ProductStockID 
        { 
            get { return FieldToInt(RawRow["ProductStockID"]).Value; }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["siscode"]); }
        }

        public int DrugID
        {
            get { return FieldToInt(RawRow["DrugID"]).Value; }
        }

        public int SiteID 
        { 
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
        }

        /// <summary>Primary supplier code for drug. Db field (SupCode)</summary>
        public string PrimarySupplierCode
        {
            get { return FieldToStr(RawRow["supcode"]);  }
            set { RawRow["supcode"] = StrToField(value); }
        }

        /// <summary>DB int field convfact 24Nov13 XN 78339</summary>
        public int ConversionFactorPackToIssueUnits { get { return FieldToInt(RawRow["convfact"]).Value; } }

        /// <summary>
        /// DB string field [stocklvl].
        /// Represents the stock level in issues units.
        /// Defaults to 0 if field is null or empty
        /// </summary>
        public decimal StockLevelInIssueUnits
        { 
            get { return FieldStrToDecimal(RawRow["stocklvl"]) ?? 0m;  }
            set { RawRow["stocklvl"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().StockLevelLength, false); }
        }

        /// <summary>
        /// DB string field [cost].
        /// Represents the average cost (excluding vat) of a pack for the current stock (in pence).
        /// </summary>
        public decimal AverageCostExVatPerPack
        { 
            get { return FieldStrToDecimal(RawRow["cost"]) ?? 0m;  }
            set { RawRow["cost"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().AverageCostIncVatPerPackLength); }
        }

        /// <summary>
        /// DB float field [lossesgains].
        /// Represents the total losses and gains (excluding vat, in pence).
        /// This can be used to prevent the average cost value from going -ve, or going too high.
        /// </summary>
        public decimal LossesGainExVat
        { 
            get { return FieldToDecimal(RawRow["lossesgains"]) ?? 0m;  }
            set { RawRow["lossesgains"] = DecimalToField(value);       }
        }

        /// <summary>Drug expiry time in minutes</summary>
        public int ExpiryTimeInMintues
        {
            get { return FieldToInt(RawRow["expiryminutes"]) ?? 0;  }
            set { RawRow["expiryminutes"] = IntToField(value);      }
        }

        public decimal  MinIssueInIssueUnits 
        { 
            get { return FieldStrToDecimal(RawRow["minissue"]).Value; } 
            set { RawRow["minissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MinIssueInIssueUnitsLength, true); } 
            // set { RawRow["minissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MinIssueInIssueUnitsLength); } 24Nov13 XN  78339
        }
        
        public decimal  MaxIssueInIssueUnits   
        { 
            get { return FieldStrToDecimal(RawRow["maxissue"]).Value;      } 
            set { RawRow["maxissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MaxIssueInIssueUnitsLength, true); } 
            // set { RawRow["maxissue"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().MaxIssueInIssueUnitsLength); } 24Nov13 XN  78339
        }

        /// <summary>DB string field [ReorderLvl]</summary>
        public decimal? ReorderLevelInIssueUnits 
        { 
            get { return FieldStrToDecimal(RawRow["ReorderLvl"]); } 
            set { RawRow["ReorderLvl"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().ReorderLevelInIssueUnitsLength);} 
        }

        /// <summary>
        /// DB string field reorderqty
        /// suggested reorder quantity (calucated from a number of factors).
        /// </summary>
        public decimal ReOrderQuantityInPacks 
        { 
            get { return FieldStrToDecimal(RawRow["reorderqty"]) ?? 0m; } 
            set { RawRow["reorderqty"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().ReOrderQuantityInPacksLength);} 
            // set { RawRow["anuse"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().AnnualUsageInIssueUnitsLength); } //  24Nov13 XN  78339
        }  

        /// <summary>
        /// DB string field [anuse]
        /// Number of issue units in a year
        /// </summary>
        public decimal? AnnualUsageInIssueUnits 
        { 
            get { return FieldStrToDecimal(RawRow["anuse"]); } 
            set { RawRow["anuse"] = DecimalToFieldStr(value, ProductStock.GetColumnInfo().AnnualUsageInIssueUnitsLength, true); } 
        }
 
        /// <summary>
        /// DB string field [message].
        /// </summary>
        public string Notes
        {
            get { return FieldToStr(RawRow["message"], false, string.Empty);  }
            set { RawRow["message"] = StrToField(value); }
        }

        public string ExtraLabel
        {
            get { return FieldToStr(RawRow["extralabel"], false, string.Empty);  }
            set { RawRow["extralabel"] = StrToField(value); }
        }

        /// <summary>
        /// Supposed to be therapeutic code for an item,  
        /// but tends to be used by other things (as user editable field)
        /// </summary>
        public string TherapyCode 
        { 
            get { return FieldToStr(RawRow["Therapcode"], false, string.Empty); } 
            set { RawRow["Therapcode"] = FieldToStr(value); } 
        }

        public BatchTrackingType BatchTracking 
        {
            get { return FieldToEnumByDBCode<BatchTrackingType>(RawRow["BatchTracking"]);  }
            set { RawRow["BatchTracking"] = EnumToFieldByDBCode<BatchTrackingType>(value);       }
        }

        /// <summary>Returns the raw single char code from ProductStock.Formulary</summary>
        public string FormularyCode 
        { 
            get { return FieldToStr(RawRow["Formulary"]);   } 
            set { RawRow["Formulary"] = StrToField(value);  }
        }

        /// <summary>
        /// Returns enum conversion of ProductStock.Formulary
        /// This won't work on one or two sites (like Plymouth) as they incorrectly use there own set of codes
        /// </summary>
        public FormularyType FormularyType 
        { 
            get { return FieldToEnumByDBCode<FormularyType>(RawRow["Formulary"]);   } 
            set { RawRow["Formulary"] = EnumToFieldByDBCode<FormularyType>(value);  }
        }

        /// <summary>
        /// DB string field sisstock
        /// If false then normal order as needed.
        /// </summary>
        public bool? IsStocked 
        { 
            get { return FieldToBoolean(RawRow["SisStock"]);                           } 
            set { RawRow["SisStock"] = BooleanToField(value, "Y", "N", string.Empty);  }
            // set { RawRow["SisStock"] = BooleanToField(value);  }  24Nov13 XN  78339
        }

        /// <summary>DB string field [livestockctrl]</summary>
        public bool? IfLiveStockControl 
        { 
            get { return FieldToBoolean(RawRow["livestockctrl"]);  } 
            set { RawRow["livestockctrl"] = BooleanToField(value, "Y", "N"); } 
            // set { RawRow["livestockctrl"] = BooleanToField(value); } 24Nov13 XN  78339
        }

        /// <summary>DB string field LocCode</summary>
        public string Location
        {
            get { return FieldToStr(RawRow["LocCode"], true, string.Empty);  }
            set { RawRow["LocCode"] = StrToField(value); }
        }

        /// <summary>DB string field LocCode2</summary>
        public string Location2
        {
            get { return FieldToStr(RawRow["LocCode2"], true, string.Empty);  }
            set { RawRow["LocCode2"] = StrToField(value); }
        }

        /// <summary>DB code [ledcode]</summary>
        public string LedgerCode
        {
            get { return FieldToStr(RawRow["LedCode"], false, string.Empty); }
            set { RawRow["LedCode"] = StrToField(value);                     }
        }

        public string LabelFormat
        {
            get { return FieldToStr(RawRow["LabelFormat"], false, string.Empty); }
            set { RawRow["LabelFormat"] = StrToField(value);                     }
        }

        public DateTime? StartOfPeriod
        {
            get { return FieldStrDateToDateTime(RawRow["datelastperiodend"], DateType.DDMMYYYY); }
            set { RawRow["datelastperiodend"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); }
        }

        /// <summary>If the item is to be excluded from products suitable for PN</summary>
        public bool PNExclude 
        { 
            get { return FieldToBoolean(RawRow["PNExclude"], false).Value; }
            set { RawRow["PNExclude"] = BooleanToField(value); }
        }

        public double SafetyFactor
        {
            get { return FieldToDouble(RawRow["SafetyFactor"]).Value; }
            set { RawRow["SafetyFactor"] = DoubleToField(value); }
        }

        public double UsageDamping
        {
            get { return FieldToDouble(RawRow["usagedamping"]) ?? 0; }
            set { RawRow["usagedamping"] = DoubleToField(value);     }
        }

        public double UseThisPeriodInIssueUnits
        {
            get { return FieldToDouble(RawRow["UseThisPeriod"]) ?? 0; }
            set { RawRow["UseThisPeriod"] = DoubleToField(value);     }
        }

        /// <summary>
        /// If product is in use.
        /// Null's, and 'S' values are converted to true, as these are legacy issues with the data.
        /// </summary>
        public bool InUse 
        { 
            get { return FieldToBoolean(RawRow["InUse"], true).Value;               } 
            set { RawRow["InUse"] = BooleanToField(value, "Y", "N", string.Empty);  } 
            // set { RawRow["InUse"] = BooleanToField(value); }  24Nov13 XN  78339
        }

        public bool? ReCalculateAtPeriodEnd   
        { 
            get { return FieldToBoolean(RawRow["ReCalcatPeriodEnd"]);  } 
            set { RawRow["ReCalcatPeriodEnd"] = BooleanToField(value, "T", "F", string.Empty); } 
        }

        /// <summary>
        /// Flag used to group products in to particular order cycle (e.g. cycle A, B, C)
        /// Cycles are user definable
        /// </summary>
        public string OrderCycle 
        { 
            get { return FieldToStr(RawRow["ordercycle"], true, string.Empty); } 
            set { RawRow["ordercycle"] = StrToField(value);                    }
        }

        /// <summary>Order cycle length in days</summary>
        public int CycleLengthInDays 
        { 
            get { return FieldToInt(RawRow["cyclelength"]) ?? 0; } 
            set { RawRow["cyclelength"] = IntToField(value);     } 
        }

        public double OutstandingInIssueUnits
        {
            get { return FieldToDouble(RawRow["Outstanding"]) ?? 0; } 
            set { RawRow["Outstanding"] = DoubleToField(value);     } 
        }

        /// <summary>Db code [ReconVol]</summary>
        public double? ReconstitutionVolumeInml
        {
            get { return FieldToDouble(RawRow["ReconVol"]);  } 
            set { RawRow["ReconVol"] = DoubleToField(value); } 
        }

        /// <summary>Db code [ReconAbbr]</summary>
        public string ReconstitutionAbbreviation
        {
            get { return FieldToStr(RawRow["ReconAbbr"], false, string.Empty); } 
            set { RawRow["ReconAbbr"] = StrToField(value);                     }
        }
        
        /// <summary>Db code [mgPerml]</summary>
        public double? FinalConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["mgPerml"]);  } 
            set { RawRow["mgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [MaxmgPerml]</summary>
        public double? MaxConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["MaxmgPerml"]);  } 
            set { RawRow["MaxmgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [MinmgPerml]</summary>
        public double? MinConcentrationInDoseUnitsPerml
        {
            get { return FieldToDouble(RawRow["MinmgPerml"]);  } 
            set { RawRow["MinmgPerml"] = DoubleToField(value); } 
        }

        /// <summary>Db code [Diluent1]</summary>
        public string DiluentAbbreviation1 
        { 
            get { return FieldToStr(RawRow["Diluent1"], false, string.Empty); } 
            set { RawRow["Diluent1"] = StrToField(value);                     }
        }

        /// <summary>Db code [Diluent2]</summary>
        public string DiluentAbbreviation2
        { 
            get { return FieldToStr(RawRow["Diluent2"], false, string.Empty); } 
            set { RawRow["Diluent2"] = StrToField(value);                     }
        }

        public string IVContainer
        {
            get { return FieldToStr(RawRow["IVContainer"], false, string.Empty); } 
            set { RawRow["IVContainer"] = StrToField(value);                     }
        }

        /// <summary>Db code [DisplacementVolume]</summary>
        public double? DisplacementVolumeInml
        {
            get { return FieldToDouble(RawRow["DisplacementVolume"]);  } 
            set { RawRow["DisplacementVolume"] = DoubleToField(value); }
        }

        public int PILnumber
        {
            get { return FieldToInt(RawRow["PILnumber"]) ?? 0;} 
            set { RawRow["PILnumber"] = IntToField(value);    }
        }

        /// <summary>db field local</summary>
        public string LocalProductCode 
        { 
            get { return FieldToStr(RawRow["local"], false, string.Empty); } 
            set { RawRow["local"] = StrToField(value); } 
        }

        public DateTime? LastIssuedDate     
        { 
            get { return FieldStrDateToDateTime(RawRow["lastissued"],  DateType.DDMMYYYY);  } 
            set { RawRow["lastissued"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); } 
        }
        
        public DateTime? LastOrderedDate    
        { 
            get { return FieldStrDateToDateTime(RawRow["lastordered"], DateType.DDMMYYYY);  } 
            set { RawRow["lastordered"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); } 
        }

        public string CreatedByUserInitials
        {
            get { return FieldToStr(RawRow["CreatedUser"], false, string.Empty); } 
            set { RawRow["CreatedUser"] = StrToField(value); } 
        }

        public string CreatedOnTerminal
        {
            get { return FieldToStr(RawRow["createdterminal"], false, string.Empty); } 
            set { RawRow["createdterminal"] = StrToField(value); } 
        }

        public string ModifiedByUserInitials
        {
            get { return FieldToStr(RawRow["modifieduser"], false, string.Empty); } 
            set { RawRow["modifieduser"] = StrToField(value); } 
        }

        public string ModifiedOnTerminal
        {
            get { return FieldToStr(RawRow["modifiedterminal"], false, string.Empty); } 
            set { RawRow["modifiedterminal"] = StrToField(value); } 
        }

        // 10Feb14 XN 56701 Added
        public DateTime? ModifiedDate
        {
            get 
            { 
                DateTime? date = FieldStrDateToDateTime(RawRow["modifieddate"], DateType.DDMMYYYY);
                TimeSpan? time = FieldStrTimeToTimeSpan(RawRow["modifiedtime"]);

                if (date.HasValue && time.HasValue)
                    return date.Value + time.Value;
                else 
                    return null;
            }
            set 
            {
                RawRow["modifieddate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); 
                RawRow["modifiedtime"] = DateTimeToFieldStrTime(value, true); 
            }  
        }

        /// <summary>DB code [pflag]</summary>
        public bool IsReconcileIfZeroPrice
        {
            get { return FieldToBoolean(RawRow["pflag"], true).Value; } 
            set { RawRow["pflag"] = BooleanToField(value, "Y", "N");  } 
            // set { RawRow["pflag"] = BooleanToField(value);  } 24Nov13 XN  78339
        }

        public bool? IssueWholePack
        {
            get { return FieldToBoolean(RawRow["issueWholePack"]);                          } 
            set { RawRow["issueWholePack"] = BooleanToField(value, "Y", "N", string.Empty); } 
            // set { RawRow["issueWholePack"] = BooleanToField(value);  } 24Nov13 XN  78339
        }

        public string CMICode
        {
            get { return FieldToStr(RawRow["PIL2"], false, string.Empty); } 
            set { RawRow["PIL2"] = StrToField(value); } 
        }

        public string EDILinkCode
        {
            get { return FieldToStr(RawRow["EDILinkCode"], false, string.Empty); } 
            set { RawRow["EDILinkCode"] = StrToField(value);                     } 
        }

        public string PASANPCCode
        {
            get { return FieldToStr(RawRow["PASANPCCode"], false, string.Empty); } 
            set { RawRow["PASANPCCode"] = StrToField(value);                     } 
        }

        public bool EyeLabel
        {
            get { return FieldToBoolean(RawRow["EyeLabel"], false).Value; } 
            set { RawRow["EyeLabel"] = BooleanToField(value);            } 
        }

        public bool PSOLabel
        {
            get { return FieldToBoolean(RawRow["PSOLabel"], false).Value; } 
            set { RawRow["PSOLabel"] = BooleanToField(value);            } 
        }

        public int? ExpiryWarnDays
        {
            get { return FieldToInt(RawRow["ExpiryWarnDays"]);  } 
            set { RawRow["ExpiryWarnDays"] = IntToField(value); } 
        }

        /// <summary>DB code CIVAS</summary>
        public bool? IsCIVAS
        { 
            get { return FieldToBoolean(RawRow["CIVAS"]);                          } 
            //set { RawRow["CIVAS"] = BooleanToField(value); }  24Nov13 XN 78339
            set { RawRow["CIVAS"] = BooleanToField(value, "Y", "N", string.Empty); } 
        }

        /// <summary>DB Code [dircode] 24Nov13 XN 78339</summary>
        public string DirectionCode
        { 
            get { return FieldToStr(RawRow["dircode"], true, string.Empty); } 
            set { RawRow["dircode"] = StrToField(value);                    } 
        }

        // The following db fields are no longer used (here for use by WProduct)
        // bnf
        // contno
        // 24Nov13 XN 78339
        [Obsolete("Use field in SiteProductData")]  internal string BNF              { set { RawRow["bnf"]    = StrToField(value); } }
        [Obsolete("Use field in WSupplierProfile")] internal string ContractNumber   { set { RawRow["contno"] = StrToField(value); } }

        #region Local Descriptions
        /// <summary>Gets or sets the local site's label description for an in-patient 19May15 XN 98073</summary>
        public string LabelDescriptionInPatient
        {
            get { return this.FieldToStr(this.RawRow["LabelDescriptionInPatient"], trimString: true, nullVal: string.Empty); } 
            set { this.RawRow["LabelDescriptionInPatient"] = this.StrToField(value, emptyStrAsNullVal: true);                                         } 
        }

        /// <summary>Gets or sets the local site's label description for an out-patient 19May15 XN 98073</summary>
        public string LabelDescriptionOutPatient
        {
            get { return this.FieldToStr(this.RawRow["LabelDescriptionOutPatient"], trimString: true, nullVal: string.Empty);   } 
            set { this.RawRow["LabelDescriptionOutPatient"] = this.StrToField(value, emptyStrAsNullVal: true);                                           } 
        }

        /// <summary>Gets or sets the local site's stores description 19May15 XN 98073</summary>
        public string LocalDescription
        {
            get { return this.FieldToStr(this.RawRow["LocalDescription"], trimString: true, nullVal: string.Empty); } 
            set { this.RawRow["LocalDescription"] = this.StrToField(value, emptyStrAsNullVal: true);                                         } 
        }
        #endregion

        /// <summary>
        /// Returns if it is a robot item (given the robot location) and indicates if the item is to be automatically or manually loaded
        /// Automatic item can be loaded by the robot
        /// Manual items are for storage in the robot by must be manually loaded as require batch tracking.
        /// </summary>
        /// <param name="robotLocation">Loction code for the robot</param>
        /// <returns>If robot item</returns>
        public RobotItem IsRobotItem(string robotLocation)
        {
            if (Location == robotLocation)
                return (BatchTracking < BatchTrackingType.OnReceipt) ? RobotItem.Automatic : RobotItem.Manual;
            else
                return RobotItem.No;
        }

        /// <summary>
        /// Returns total stock value exc vat
        ///     (Stock level in Issue Units * Average Cost per pack) + losses and gains
        /// 24Nov13 XN 78339
        /// </summary>
        public decimal CalcStockValueExVat()
        {
            if (this.ConversionFactorPackToIssueUnits == 0)
                throw new ApplicationException(string.Format("Invalid conversion factor of zero for product {0} and site ID {1}", this.NSVCode, this.SiteID));

            return ((this.StockLevelInIssueUnits / this.ConversionFactorPackToIssueUnits) * this.AverageCostExVatPerPack) + this.LossesGainExVat;
        }

        /// <summary>
        /// Updates modified details for the product
        /// Will update fields
        ///     modifieduser    - Current user initials
        ///     modifiedterminal- Current user terminal
        ///     modifieddate    - date\time
        ///     modifiedtime
        /// 18May15 XN 117528
        /// </summary>
        /// <param name="now">mod date\time to set</param>
        public void UpdateModifiedDetails(DateTime now)
        {            
            this.ModifiedByUserInitials = SessionInfo.UserInitials.SafeSubstring(0, WProduct.GetColumnInfo().ModifiedByUserInitialsLength);
            this.ModifiedOnTerminal     = SessionInfo.Terminal.SafeSubstring    (0, WProduct.GetColumnInfo().ModifiedOnTerminalLength    );
            this.ModifiedDate           = now;
        }
    }

    public class ProductStockColumnInfo : BaseColumnInfo
    {
        public ProductStockColumnInfo() : base("ProductStock") { }

        public int AverageCostIncVatPerPackLength { get { return base.tableInfo.GetFieldLength("cost");       } }
        public int StockLevelLength               { get { return base.tableInfo.GetFieldLength("stocklvl");   } }
        public int NotesLength                    { get { return base.tableInfo.GetFieldLength("message");    } }
        public int MinIssueInIssueUnitsLength     { get { return base.tableInfo.GetFieldLength("minissue");   } }
        public int MaxIssueInIssueUnitsLength     { get { return base.tableInfo.GetFieldLength("maxissue");   } }
        public int ReorderLevelInIssueUnitsLength { get { return base.tableInfo.GetFieldLength("reorderlvl"); } }
        public int ReOrderQuantityInPacksLength   { get { return base.tableInfo.GetFieldLength("reorderqty"); } }
        public int AnnualUsageInIssueUnitsLength  { get { return base.tableInfo.GetFieldLength("anuse");      } }
    }

    //public class ProductStock : BaseTable<ProductStockRow, ProductStockColumnInfo> 24Nov13 XN 78339
    public class ProductStock : BaseTable2<ProductStockRow, ProductStockColumnInfo>
    {
        public ProductStock() : base("ProductStock") { }

        /// <summary>
        /// Overrides base method to initalise
        ///     DirectionCode = ""
        ///  24Nov13 XN 78339
        /// </summary>
        public override ProductStockRow Add()
        {
            ProductStockRow newRow = base.Add();
            newRow.DirectionCode = string.Empty;
            return newRow;
        }

        /// <summary>
        /// Loads product stock data by nsvcode, and site ID.
        /// </summary>
        /// <param name="nsvcode">product nsvcode</param>
        /// <param name="siteID">product site</param>
        /// <param name="append">if data should be appended to the existing set (default is false)</param>
        public void LoadBySiteIDAndNSVCode (string nsvcode, int siteID)
        {
            LoadBySiteIDAndNSVCode (nsvcode, siteID, false);
        }
        public void LoadBySiteIDAndNSVCode (string nsvcode, int siteID, bool append)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID ));
            parameters.Add(new SqlParameter("NSVCode",          nsvcode               ));
            parameters.Add(new SqlParameter("SiteID",           siteID                ));
            LoadBySP(append, "pProductStockBySiteIDAndNSVCode", parameters);
        }

        /// <summary>
        /// Loads product stock info related to an order number
        /// </summary>
        /// <param name="siteID">Site the order is related to</param>
        /// <param name="orderNumber">Order number</param>
        public void LoadByOrderNumber(int siteID, int orderNumber)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID ));
            parameters.Add(new SqlParameter("SiteID",           siteID));
            parameters.Add(new SqlParameter("OrderNumber",      orderNumber));
            LoadBySP("pProductStockBySiteIDAndOrderNumber", parameters);
        }

        /// <summary>
        /// Loads product stock by SiteID, and code
        /// </summary>
        /// <param name="siteID">Site the order is related to</param>
        /// <param name="code">Lookup code to search on</param>
        /// <param name="append">If other rows are to be append 18May15 XN 117528</param>
        public void LoadBySiteIDAndCode(int siteID, string code, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
            parameters.Add(new SqlParameter("SiteID",           siteID                  ));
            parameters.Add(new SqlParameter("Code",             code                    ));
            LoadBySP(append, "pProductStockBySiteIDAndCode", parameters);
        }

        /// <summary>Load by ProductStockID 24Nov13 XN 78339</summary>
        /// <param name="productStockID">ProductStockID value</param>
        /// <param name="append">If other rows are to be append 18May15 XN 117528</param>
        public void LoadByProductStockID(int productStockID, bool append = false)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
            parameters.Add(new SqlParameter("ProductStockID",   productStockID          ));
            LoadBySP(append, "pProductStockByProductStockID", parameters);
        }

        /// <summary>Load by ProductStockIDs 26Oct15 XN 106278</summary>
        /// <param name="productStockIDs">list of ids</param>
        public void LoadByProductStockIDs(IEnumerable<int> productStockIDs)
        {
            if (productStockIDs.Any())
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add(new SqlParameter("ProductStockIDs", productStockIDs.ToCSVString(",")));
                LoadBySP("pProductStockByProductStockIDs", parameters);
            }
        }

        /// <summary>
        /// Overrides base class to write to the WPharmacyLog 
        /// 18May15 XN 117528
        /// </summary>
        /// <param name="saveToPharmacyLog">If any updates are saved to the WPharmacyLog</param>
        public void Save(bool saveToPharmacyLog)
        {
            DateTime now = DateTime.Now;

            // Adds the updates to the log 18May15 XN 117528
            WPharmacyLog log = new WPharmacyLog();
            if (saveToPharmacyLog)
            {
                log.AddRange(   
                              this,
                              WPharmacyLogType.LabUtils,
                              r => r.NSVCode,
                              r => r.SiteID,
                              r => r.NSVCode,
                              null,
                              new string[0]);
            }

            // And Save
            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                base.Save();
                log.Save();
                trans.Commit();
            }
        }
    }

    /// <summary>IEnumerable{ProductStockRow} extension methods class to provide quick helper functions</summary>
    public static class ProductStockEnumerableExtensions
    {
        /// <summary>Returns the first ProductStockRow with the NSVCode or null if not present in list</summary>
        public static ProductStockRow FindByNSVCode(this IEnumerable<ProductStockRow> items, string NSVCode)
        {
            return items.FirstOrDefault(i => i.NSVCode == NSVCode);
        }

        /// <summary>Returns first ProductStockRow by NSVCode and siteID 18May15 XN 117528</summary>
        /// <param name="items">List of productStock rows</param>
        /// <param name="siteID">Site ID</param>
        /// <param name="NSVCode">NSV Code</param>
        /// <returns>First ProductStock row</returns>
        public static ProductStockRow FindBySiteIDAndNSVCode(this IEnumerable<ProductStockRow> items, int siteID, string NSVCode)
        {
            return items.FirstOrDefault(i => i.NSVCode == NSVCode && i.SiteID == siteID);
        }

        /// <summary>Returns first ProductStockRow by DrugID and siteID 18May15 XN 117528</summary>
        /// <param name="items">List of productStock rows</param>
        /// <param name="siteID">Site ID</param>
        /// <param name="DrugID">Drug ID</param>
        /// <returns>First ProductStock row</returns>
        public static  ProductStockRow FindBySiteIDAndDrugID(this IEnumerable<ProductStockRow> items, int siteID, int DrugID)
        {
            return items.FirstOrDefault(i => i.DrugID == DrugID && i.SiteID == siteID);    
        }
    }
}
