//===========================================================================
//
//							        WTranslog.cs
//
//  Provides access to WTranslog table.
//
//  SP for this object should return all fields from the WTranslog table, 
//  and a linked in 
//      SiteProductData.StoresDescription or SiteProductData.[LabelDescription] as ProductDescription
//
//  Only supports reading, inserting
//  There are also functions to return monthly totals.
//  Data bound on web page DisplayLogRows.ascx
//
//	Modification History:
//	22Jul09 XN  Written
//  03Sep10 XN  F0082255 Added properties to WTranslogRow, and method LoadPatientDispensingByEpisodeAndDateRange
//  30Sep10 XN  F0097623 add WTranslogRow.SiteID
//  05Oct10 XN  F0098140 Removed ConsultantName, and CommitBatch_SiteGeneratedCode 
//              as not really used anymore.
//  22Jun11 XN  F0118610  Item enquiry screen need to show EDI orders in the historical order list
//	23Apr13 XN  Added more properties to WTranslogRow, plus changed to use BaseTable2, 
//              add Add method (to set defaults) 53147
//  23May12 XN  Prevent saving LogDateTime as should be done by db (27038)
//  05Jul13 XN  Fixed CaseNumber, and ProductDescription added PatientID, KindRaw, DateTime, CostIncVat, 
//              CostExVat, BatchNumber, StockLevel, CustomerOrderNumber, NHNumber, NHNumberValid, StockValue, LogDateTime
//              and method LoadByCriteria 27252
//  18Aug14 XN  GetMonthlyTotalsExcludingTypes Update to WHERE clause in F4 summary view 86624 
//  14Apr16 XN  Updates for issuing 123082
//  16Aug16 XN  160324 In WTranslogColumnInfo fixed CaseNumberLength added
//              IssueUnitsLength, WardCodeLength, DirectionCodeLength, 
//              ConsultantCodeLength, ConsultantSpecialtyLength
//  28Nov16 XN  Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>Log entry type (there are other but only added two to start with)</summary>
    public enum WTranslogType
    {
        [EnumDBCode("")]
        Unknown,

        /// <summary>DB code 'C' 14Apr16 XN 123082</summary>
        [EnumDBCode("C")]
        Civas,

        /// <summary>DB code 'I'</summary>
        [EnumDBCode("I")]
        Inpatient,

        /// <summary>DB code 'O'</summary>
        [EnumDBCode("O")]
        Outpatient,

        /// <summary>DB code 'D'</summary>
        [EnumDBCode("D")]
        Discharge,

        /// <summary>DB code 'L'</summary>
        [EnumDBCode("L")]
        Leave,

        /// <summary>DB code 'S'</summary>
        [EnumDBCode("S")]
        Stock,

        /// <summary>DB code 'P'</summary>
        [EnumDBCode("P")]
        PickingTicket,

        /// <summary>DB code 'F'</summary>
        [EnumDBCode("F")]
        SelfMedication,

        /// <summary>DB code 'M'</summary>
        [EnumDBCode("M")]
        Manufacturing,

        /// <summary>DB code 'T'  14Apr16 XN 123082</summary>
        [EnumDBCode("T")]
        ParenteralNutrition,

        /// <summary>
        /// DB code 'W'
        /// When a Ward Stock is dispensed
        /// </summary>
        [EnumDBCode("W")]
        WardStock,
    }

    /// <summary>Represents a record in the WTranslog table</summary>
    public class WTranslogRow : BaseRow
    {
        public int WTranslogID { get { return FieldToInt(RawRow["WTranslogID"]).Value; } }

        /// <summary>
        /// DB string field [RevisionLevel] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string RevisionLevel
        {
            get { return FieldToStr(RawRow["RevisionLevel"]);  } 
            internal set { RawRow["RevisionLevel"] = StrToField(value); }
        }

        /// <summary>
        /// Patient hospital's case number
        /// DB string field [CaseNo]
        /// </summary>
        public string CaseNumber
        {
            //get { return FieldToStr(RawRow["CaseNumber"]);  } 05Jul13 XN  27252
            //set { RawRow["CaseNumber"] = StrToField(value); }
            get { return FieldToStr(RawRow["CaseNo"], true, string.Empty);  } 
            set { RawRow["CaseNo"] = StrToField(value);                     }
        }

        /// <summary>
        /// Patient ID transaction was issued to 
        /// DB Field [PatId]
        /// Can be null
        /// 05Jul13 XN  27252 Added
        /// </summary>
        public int? PatientID
        {
            get { return FieldToInt(RawRow["PatId"]);  } 
            set { RawRow["PatId"] = IntToField(value); }
        }

        /// <summary>
        /// DB string field [DispId] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string UserInitials
        {
            get { return FieldToStr(RawRow["DispId"]);  } 
            internal set { RawRow["DispId"] = StrToField(value); }
        }

        /// <summary>
        /// DB string field [Terminal] 
        /// (can't set as set by SetDefaults)
        /// </summary>
        public string Terminal
        {
            get { return FieldToStr(RawRow["Terminal"]);  } 
            internal set { RawRow["Terminal"] = StrToField(value); }
        }
        
        /// <summary>
        /// Provides access to the raw kind
        /// 05Jul13 XN added 27252
        /// </summary>
        public string KindRaw
        {
            get { return FieldToStr(RawRow["Kind"]); } 
        }

        public WTranslogType Kind
        {
            get { return FieldToEnumByDBCode<WTranslogType>(RawRow["Kind"]); } 
            set { RawRow["Kind"] = EnumToFieldByDBCode<WTranslogType>(value); }
        }

        /// <summary>Gets or sets provides access to the raw label type 14Apr16 XN 123082</summary>
        public string LabelTypeRaw
        {
            get { return FieldToStr(RawRow["LabelType"]);  } 
        }

        /// <summary>Gets or sets WTranslogType label type</summary>        
        public WTranslogType LabelType      //public string LabelType  14Apr16 XN 123082
        {
            get { return FieldToEnumByDBCode<WTranslogType>(RawRow["LabelType"]); } 
            set { RawRow["LabelType"] = EnumToFieldByDBCode<WTranslogType>(value); }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["SisCode"], true, string.Empty); }
            set { RawRow["SisCode"] = StrToField(value, false);             }
        }

        /// <summary>DB int field [Site]</summary>
        public int SiteNumber
        {
            get { return FieldToInt(RawRow["Site"]).Value;  } 
            set { RawRow["Site"] = IntToField(value);       } 
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value;  } 
            set { RawRow["SiteID"] = IntToField(value);       } 
        }

        /// <summary>Gets or sets ProductId field 14Apr16 XN 123082</summary>        
        public int ProductId
        {
            get { return FieldToInt(RawRow["ProductId"]) ?? 0;  } 
            set { RawRow["ProductId"] = IntToField(value);      } 
        }

        /// <summary>
        /// Date and time of issue
        /// DB int field [Date], and string field [Time]
        /// Added 05Jul13 XN  27252
        /// </summary>
        public DateTime? DateTime
        {
            get 
            { 
                DateTime? date = FieldIntDateToDateTime(RawRow["Date"], DateType.YYYYMMDD);
                TimeSpan? time = FieldStrTimeToTimeSpan(RawRow["Time"]);

                if (date.HasValue && time.HasValue)
                    return date.Value + time.Value;
                else if (date.HasValue)
                    return date.Value;
                else 
                    return null;
            } 
            set 
            { 
                RawRow["Date"] = DateTimeToFieldIntDate(value, 0, DateType.YYYYMMDD); 
                RawRow["Time"] = DateTimeToFieldStrTime(value, true);
            } 
        }

        /// <summary>Gets or sets EntityID field 14Apr16 XN 123082</summary>        
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]) ?? 0;  } 
            set { RawRow["EntityID"] = IntToField(value);      } 
        }

        /// <summary>
        /// DB string field [Cost]
        /// 05Jul13 XN  Added 27252
        /// </summary>
        public decimal CostIncVat
        {
            get { return FieldStrToDecimal(RawRow["Cost"]).Value;  } 
            set { RawRow["Cost"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().CostIncVatLength); } 
            // set { RawRow["Cost"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().CostIncVatLength); }  14Apr16 XN 123082
        }

        // 05Jul13 XN Added 27252
        public decimal CostExVat
        {
            get { return FieldStrToDecimal(RawRow["CostExTax"]).Value;  } 
            set { RawRow["CostExTax"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().CostExVatLength); } 
            // set { RawRow["CostExVat"] = DecimalToFieldStr(value, WOrderlog.GetColumnInfo().CostExVatLength); } 14Apr16 XN 123082
        } 

        /// <summary>Gets or sets TaxCost field 14Apr16 XN 123082</summary>
        public decimal VatCost
        {
            get { return FieldStrToDecimal(RawRow["TaxCost"]).Value;  } 
            set { RawRow["TaxCost"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().VatCost); } 
        }

        /// <summary>Gets or sets TaxCode field 14Apr16 XN 123082</summary>
        public int? VatCode
        {
            get { return FieldToInt(RawRow["TaxCode"]);  } 
            set { RawRow["TaxCode"] = IntToField(value); } 
        }

        /// <summary>Gets or sets TaxRate field 14Apr16 XN 123082</summary>
        public decimal? VatRate
        {
            get { return FieldStrToDecimal(RawRow["TaxRate"]);  } 
            set { RawRow["TaxRate"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().VatRateLength); } 
        }

        public int EpisodeID
        {
            get { return FieldToInt(RawRow["Episode"]) ?? 0; }
            set { RawRow["Episode"] = IntToField(value);     }
        }

        /// <summary>
        /// Returns the drug description for the products order with the ! replaced with space
        ///     WProduct.[Description]  as ProductDescription
        /// 05Jul13 XN Extended to handle StoresDescription and Description 27252
        /// </summary>
        public string ProductDescription
        {
            get 
            { 
                string result = string.Empty;
                if (this.RawRow.Table.Columns.Contains("ProductDescription"))
                {
                    result = FieldToStr(this.RawRow["ProductDescription"], trimString: true, nullVal: string.Empty);  
                }

                return result.Replace('!', ' ');
            }
        }

        /// <summary>DB int field convfact</summary>
        public int ConversionFactorPackToIssueUnits
        {
            get { return FieldToInt(RawRow["ConvFact"]).Value; }
            set { RawRow["ConvFact"] = IntToField(value);      }
        }

        /// <summary>DB string field Qty</summary>
        public decimal QuantityInIssueUnits
        {
            get { return FieldToDecimal(RawRow["Qty"]) ?? 0m;                                                 }
            set { RawRow["Qty"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().QuantityIssuedLength);   }
        }

        /// <summary>DB string field CostExTax</summary>
        public decimal TotalCostExVat
        {
            get { return FieldToDecimal(RawRow["CostExTax"]) ?? 0m;                                                 }
            set { RawRow["CostExTax"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().TotalCostExVatLength);   }
        }

        public string IssueUnits
        {
            get { return FieldToStr(RawRow["IssueUnits"], true, string.Empty); }
            set { RawRow["IssueUnits"] = StrToField(value, false);              }
        }

        /// <summary>DB string field Consultant</summary>
        public string ConsultantCode
        {
            get { return FieldToStr(RawRow["Consultant"], false, string.Empty);         }
            set { RawRow["Consultant"] = StrToField(value, emptyStrAsNullVal: false);   }
        }

        /// <summary>Gets or sets Specialty field 14Apr16 XN 123082</summary>
        public string ConsultantSpecialty
        {
            get { return FieldToStr(RawRow["Specialty"], trimString: false, nullVal: null ); }
            set { RawRow["Specialty"] = StrToField(value, emptyStrAsNullVal: false);         }
        }

        /// <summary>Gets or sets EntityID_Prescriber field 14Apr16 XN 123082</summary>
        public int EntityID_Prescriber
        {
            get { return FieldToInt(RawRow["EntityID_Prescriber"]) ?? 0;  }
            set { RawRow["EntityID_Prescriber"] = IntToField(value);      }
        }

        public string PrescriptionNum
        {
            get { return FieldToStr(RawRow["PrescriptionNum"], false, string.Empty); }
            set { RawRow["PrescriptionNum"] = StrToField(value, false);              }
        }

        /// <summary>
        /// DB code [BatchNum]
        /// 05Jul13 XN added 27252
        /// </summary>
        public string BatchNumber
        {
            get { return FieldToStr(RawRow["BatchNum"]);  }
            set { RawRow["BatchNum"] = StrToField(value); }
        }

        /// <summary>Gets or sets db field [ExpiryDate] 14Apr16 XN 123082</summary>
        public DateTime? BatchExpiryDate
        {
            get { return FieldStrDateToDateTime(RawRow["ExpiryDate"], DateType.DDMMYYYY);                }
            set { RawRow["ExpiryDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); }
        }

        /// <summary>Gets or sets CivasAmount field 14Apr16 XN 123082</summary>
        public decimal? CivasAmount
        {
            get { return FieldToDecimal(RawRow["CivasAmount"]);                                                                                   }
            set { RawRow["CivasAmount"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().CivasAmountLength, nullAsBlankString: true); }
        }

        /// <summary>DB string field Ward</summary>
        public string WardCode
        {
            get { return FieldToStr(RawRow["Ward"], false, string.Empty); }
            set { RawRow["Ward"] = StrToField(value, false);              }
        }

        public int RequestID_Prescription
        {
            get { return FieldToInt(RawRow["RequestID_Prescription"]) ?? 0; }
            set { RawRow["RequestID_Prescription"] = IntToField(value);     }
        }

        /// <summary>Gets or sets DirCode field 14Apr16 XN 123082</summary>
        public string DirectionCode
        {
            get { return FieldToStr(RawRow["DirCode"], trimString: true, nullVal: string.Empty); }
            set { RawRow["DirCode"] = StrToField(value, emptyStrAsNullVal: false);               }
        }

        /// <summary>Gets or sets WWardProductListItemID field 14Apr16 XN 123082</summary>
        public int WWardProductListLineID
        {
            get { return FieldToInt(RawRow["WWardProductListItemID"]) ?? 0; }
            set { RawRow["WWardProductListItemID"] = IntToField(value);     }
        }

        /// <summary>Gets or sets AmmSupplyRequestIngredientID field 14Apr16 XN 123082</summary>
        public int? AmmSupplyRequestIngredientId
        {
            get { return FieldToInt(RawRow["AmmSupplyRequestIngredientID"]);  }
            set { RawRow["AmmSupplyRequestIngredientID"] = IntToField(value); }
        }

        /// <summary>Gets or sets RequestId_AmmSupplyRequest field 14Apr16 XN 123082</summary>
        public int? RequestId_AmmSupplyRequest
        {
            get { return FieldToInt(RawRow["RequestId_AmmSupplyRequest"]);  }
            set { RawRow["RequestId_AmmSupplyRequest"] = IntToField(value); }
        }

        // 05Jul13 XN added 27252
        public decimal? StockLevel
        {
            get { return FieldStrToDecimal(RawRow["StockLvl"]);  } 
            set { RawRow["StockLvl"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().StockLevelLength, true); } 
        }

        // 05Jul13 XN added 27252
        public decimal? StockValue
        {
            get { return FieldStrToDecimal(RawRow["StockValue"]).Value;  } 
            set { RawRow["StockValue"] = DecimalToFieldStr(value, WTranslog.GetColumnInfo().StockValueLength, true); } 
        }

        /// <summary>
        /// DB code [CustOrdNo]
        /// 05Jul13 XN added 27252
        /// </summary>
        public string CustomerOrderNumber
        {
            get { return FieldToStr(RawRow["CustOrdNo"], true, string.Empty); }
            set { RawRow["CustOrdNo"] = StrToField(value, false);              }
        }

        /// <summary>Gets or sets InternalOrderNumber field 14Apr16 XN 123082</summary>
        public int? InternalOrderNumber
        {
            get { return FieldToInt(RawRow["InternalOrderNumber"]);     }
            set { RawRow["InternalOrderNumber"] = IntToField(value);    }
        }

        // 05Jul13 XN added 27252
        public string NHNumber
        {
            get { return FieldToStr(RawRow["NHNumber"], true, string.Empty); }
            set { RawRow["NHNumber"] = StrToField(value);                    }
        }

        // 05Jul13 XN added 27252
        public bool? NHNumberValid
        {
            get { return FieldToBoolean(RawRow["NHNumberValid"]);   }
            set { RawRow["NHNumberValid"] = BooleanToField(value);  }
        }

        /// <summary>
        /// Date and time the log entry was saved to the database
        /// Can't set as it should be automatically written when the log is inserted into the database.
        /// 05Jul13 XN added 27252
        /// </summary>
        public DateTime LogDateTime
        {
            get { return FieldToDateTime(RawRow["LogDateTime"]).Value; }
        }

        /// <summary>Gets or sets RepeatBatchId field 14Apr16 XN 123082</summary>
        public int RepeatBatchId
        {
            get { return FieldToInt(RawRow["RepeatBatchId"]) ?? 0;  }
            set { RawRow["RepeatBatchId"] = IntToField(value);      }
        }
         
        /// <summary>Gets or sets PPFlag field 14Apr16 XN 123082</summary>
        [Obsolete("Exist in DB but don't believe that it is used")]
        public string PPFlag 
        { 
            get { return FieldToStr(RawRow["PPFlag"], trimString: true, nullVal: string.Empty);  }
        }

        /// <summary>
        /// Creates an XML heap for a translog row 123082
        /// Replaces vb6 SupPatME.BAS method FillHeapTranslogInfo 
        /// </summary>
        public string ToXMLHeap()
        {
            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            int siteId = this.SiteID;
            string qtyInPacksMaskString = WConfiguration.LoadAndCache<string>(siteId, "D|GenInt", "TranslogInterface",  "QtyinPacksMask",                   "0.######",     true);
            string printHeapCostFormat  = WConfiguration.LoadAndCache<string>(siteId, "D|patmed", string.Empty,         "TransLogPrintHeapCost/100Format",  "0.00",         true);
            string formatedDateString   = WConfiguration.LoadAndCache<string>(siteId, "D|patmed", string.Empty,         "TransLogPrintHeapDateFormat",      @"dd/MM/yyyy",  true);
            
            // Convert date from vb6 format to .NET
            formatedDateString = formatedDateString.Replace("D", "d").Replace("m", "M").Replace("c", "y");

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");

                xmlWriter.WriteAttributeString("tWTranslogID",      this.WTranslogID.ToString());
                xmlWriter.WriteAttributeString("tTransactionID",    this.WTranslogID.ToString());
                xmlWriter.WriteAttributeString("tRevisionlevel",    this.RevisionLevel);
                xmlWriter.WriteAttributeString("tPatid",            this.PatientID == null ? string.Empty : this.PatientID.ToString());
                xmlWriter.WriteAttributeString("tCaseno",           this.CaseNumber);
                xmlWriter.WriteAttributeString("tCasenoXML",        this.CaseNumber.XMLEscape());
                xmlWriter.WriteAttributeString("tSisCode",          this.NSVCode);
                xmlWriter.WriteAttributeString("tConvfact",         this.ConversionFactorPackToIssueUnits.ToString());
                xmlWriter.WriteAttributeString("tIssueUnits",       this.IssueUnits);
                xmlWriter.WriteAttributeString("tDispid",           this.UserInitials);
                xmlWriter.WriteAttributeString("tTerminal",         this.Terminal);
                xmlWriter.WriteAttributeString("tTerminalXML",      this.Terminal.XMLEscape());
                xmlWriter.WriteAttributeString("tDate",             this.DateTime == null ? string.Empty : this.DateTime.Value.ToString("yyyyMMdd"));
                xmlWriter.WriteAttributeString("tDatexml",          this.DateTime == null ? string.Empty : this.DateTime.Value.ToString("yyyy-MM-dd"));
                xmlWriter.WriteAttributeString("tTime",             this.DateTime == null ? string.Empty : this.DateTime.Value.ToString("HHmmss"));
                xmlWriter.WriteAttributeString("tTimexml",          this.DateTime == null ? string.Empty : this.DateTime.Value.ToString("HH:mm"));
                xmlWriter.WriteAttributeString("tdd-mmm-yyyyDate",  this.DateTime == null ? string.Empty : this.DateTime.Value.ToString("dd-MMM-yyyy"));
                xmlWriter.WriteAttributeString("tDateFormatted",    this.DateTime == null ? string.Empty : formatedDateString);
                xmlWriter.WriteAttributeString("tTransChargeType",  this.QuantityInIssueUnits >= 0 ? WConfiguration.LoadAndCache<string>(siteId, "D|patmed", "", "TransLogPrintHeapChargeCode", "C", false) : WConfiguration.LoadAndCache<string>(siteId, "D|patmed", "", "TransLogPrintHeapCreditCode", "G", true));
                xmlWriter.WriteAttributeString("tAbsoluteQty",      Math.Abs(this.QuantityInIssueUnits).ToString());
                xmlWriter.WriteAttributeString("tQty",              this.QuantityInIssueUnits.ToString());
                xmlWriter.WriteAttributeString("tQtyPacks",         (this.QuantityInIssueUnits / this.ConversionFactorPackToIssueUnits).ToString(qtyInPacksMaskString));
                xmlWriter.WriteAttributeString("tCost",             this.CostIncVat.ToString());
                xmlWriter.WriteAttributeString("tCostExVAT",        this.CostExVat.ToString());
                xmlWriter.WriteAttributeString("tVATcost",          this.VatCost.ToString());
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("tCost/100"),         (this.CostIncVat / 100).ToString(printHeapCostFormat));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("tCostExVAT/100"),    (this.CostExVat / 100).ToString(printHeapCostFormat));
                xmlWriter.WriteAttributeString(XmlConvert.EncodeName("tVATcost/100"),      (this.VatCost / 100).ToString(printHeapCostFormat));
                xmlWriter.WriteAttributeString("tVatCode",          this.VatCode.ToString());
                xmlWriter.WriteAttributeString("tVatrate",          this.VatRate.ToString());
                xmlWriter.WriteAttributeString("tWard",             this.WardCode);
                xmlWriter.WriteAttributeString("tWardXML",          this.WardCode.XMLEscape());
                xmlWriter.WriteAttributeString("tConsultant",       this.ConsultantCode);
                xmlWriter.WriteAttributeString("tConsultantXML",    this.ConsultantCode.XMLEscape());
                xmlWriter.WriteAttributeString("tSpecialty",        this.ConsultantSpecialty);
                xmlWriter.WriteAttributeString("tSpecialtyXML",     this.ConsultantSpecialty.XMLEscape());
                xmlWriter.WriteAttributeString("tPrescriber",       this.RawRow["Prescriber"].ToString());
                xmlWriter.WriteAttributeString("tDircode",          this.DirectionCode);
                xmlWriter.WriteAttributeString("tDircodeXML",       this.DirectionCode.XMLEscape());
                xmlWriter.WriteAttributeString("tKind",             this.KindRaw);
                xmlWriter.WriteAttributeString("tSite",             this.SiteNumber.ToString());
                xmlWriter.WriteAttributeString("tLabeltype",        this.LabelTypeRaw);
                xmlWriter.WriteAttributeString("tContainers",       this.RawRow["Containers"].ToString());
                xmlWriter.WriteAttributeString("tEpisode",          this.EpisodeID.ToString());
                xmlWriter.WriteAttributeString("tEventNumber",      this.RawRow["EventNumber"].ToString());
                xmlWriter.WriteAttributeString("tPrescriptionNum",  this.PrescriptionNum);
                xmlWriter.WriteAttributeString("tBatchNum",         this.BatchNumber);
                xmlWriter.WriteAttributeString("tExpiryDate",       this.BatchExpiryDate == null ? string.Empty : this.BatchExpiryDate.Value.ToString("ddMMyyyy"));
                xmlWriter.WriteAttributeString("tPPflag",           this.PPFlag);
                xmlWriter.WriteAttributeString("tStocklvl",         this.StockLevel == null ? string.Empty : this.StockLevel.ToString());
                xmlWriter.WriteAttributeString("tCustordno",        this.CustomerOrderNumber);
                xmlWriter.WriteAttributeString("tCustordnoXML",     this.CustomerOrderNumber.XMLEscape());
                xmlWriter.WriteAttributeString("tCivastype",        this.RawRow["Civastype"].ToString());
                xmlWriter.WriteAttributeString("tCivasamount",      this.CivasAmount == null ? string.Empty : this.CivasAmount.ToString());

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }
    
    /// <summary>Provides column information about the WTranslog table</summary>
    public class WTranslogColumnInfo : BaseColumnInfo
    {
        public WTranslogColumnInfo () : base("WTranslog") { }

        public int QuantityIssuedLength { get { return base.tableInfo.GetFieldLength("Qty");        } }
        public int TotalCostExVatLength { get { return base.tableInfo.GetFieldLength("CostExVat");  } }
        public int VatCost              { get { return base.tableInfo.GetFieldLength("TaxCost");    } }
        public int CostIncVatLength     { get { return base.tableInfo.GetFieldLength("Cost");       } }
        public int CostExVatLength      { get { return base.tableInfo.GetFieldLength("CostExTax");  } }
        //public int CaseNumberLength     { get { return base.tableInfo.GetFieldLength("CaseNumber"); } }   16Aug16 XN  160324 Fixed
        public int CaseNumberLength     { get { return base.tableInfo.GetFieldLength("CaseNo");     } } 
        public int UserInitialsLength   { get { return base.tableInfo.GetFieldLength("DispId");     } }
        public int LabelTypeLength      { get { return base.tableInfo.GetFieldLength("LabelType");  } }
        public int StockLevelLength     { get { return base.tableInfo.GetFieldLength("StockLvl");   } }
        public int StockValueLength     { get { return base.tableInfo.GetFieldLength("StockValue"); } }
        public int TerminalLength       { get { return base.tableInfo.GetFieldLength("Terminal");   } }
        public int VatRateLength        { get { return base.tableInfo.GetFieldLength("TaxRate");    } }
        public int CivasAmountLength    { get { return base.tableInfo.GetFieldLength("CivasAmount");} }
        public int IssueUnitsLength         { get { return base.tableInfo.GetFieldLength("IssueUnits"); } } // 16Aug16 XN  160324 Added
        public int WardCodeLength           { get { return base.tableInfo.GetFieldLength("Ward");       } } // 16Aug16 XN  160324 Added
        public int DirectionCodeLength      { get { return base.tableInfo.GetFieldLength("DirCode");    } } // 16Aug16 XN  160324 Added 
        public int ConsultantCodeLength     { get { return base.tableInfo.GetFieldLength("Consultant"); } } // 16Aug16 XN  160324 Added
        public int ConsultantSpecialtyLength{ get { return base.tableInfo.GetFieldLength("Specialty");  } } // 16Aug16 XN  160324 Added
    }

    /// <summary>Represents monthly totals calculated from records in the WTranslog</summary>
    public class WTranslogMonthlyTotals
    {
        /// <summary>Month and year the total applies to</summary>
        public DateTime MonthYear       { get; internal set; }

        /// <summary>Qty total for the month</summary>
        public decimal? QuantityInPacks { get; internal set; }
    }

    /// <summary>Represent the WTranslog table</summary>
    public class WTranslog : BaseTable2<WTranslogRow, WTranslogColumnInfo>
    {
        public WTranslog() : base("WTranslog") 
        {
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
            this.WriteToAudtiLog = false;
            this.extraExcludedColumns.Add("LogDateTime");   // Prevent saving LogDateTime as should be done by db 23May12 XN 27038
        }

        /// <summary>
        /// Adds a new row, and sets default values for
        ///     RevisionLevel        
        ///     UserInitials         
        ///     Terminal             
        ///     Prescriber
        ///     Containers
        ///     Eventnumber
        ///     PPFlag
        ///     CustomerOrderNumber  
        ///     InternalOrderNumber  
        ///     CivasType
        ///     RepeatBatchId        
        /// </summary>
        /// <returns>New row</returns>
        public override WTranslogRow Add()
        {
            var columnInfo = WTranslog.GetColumnInfo();
            WTranslogRow newRow = base.Add();

            // Set common defaults
            newRow.RevisionLevel                = "10"; // Should be set to software version number.
            newRow.UserInitials                 = SessionInfo.UserInitials.SafeSubstring(0, columnInfo.UserInitialsLength);
            newRow.Terminal                     = SessionInfo.Terminal.SafeSubstring    (0, columnInfo.TerminalLength);
            newRow.RawRow["Prescriber"]         = string.Empty;
            newRow.RawRow["Containers"]         = string.Empty;
            newRow.RawRow["Eventnumber"]        = string.Empty;
            newRow.RawRow["PPFlag"]             = string.Empty;
            newRow.CustomerOrderNumber          = string.Empty;
            newRow.InternalOrderNumber          = 0;
            newRow.RawRow["CivasType"]          = string.Empty;
            newRow.RepeatBatchId                = 0;

            return newRow;
        }

        /// <summary>
        /// Returns the monthly qty totals, from the translog (excluding specific types)
        /// Will only set the MonthYear, and QuantityInPacks values in WTranslogMonthlyTotals
        /// The date is compared against db field [Date]
        /// </summary>
        /// <param name="siteID">Site id</param>
        /// <param name="NSVCode">NSV code</param>
        /// <param name="type">orderlog type</param>
        /// <param name="fromDate">earliest date to retrieve log rows from</param>
        /// <param name="excludedTypes">WTranslog types to exclude from the log</param>
        /// <returns>List of qty received for each month</returns>
        public static List<WTranslogMonthlyTotals> GetMonthlyTotalsExcludingTypes( int siteID, string NSVCode, DateTime fromDate, params WTranslogType[] excludedTypes )
        {
            List<WTranslogMonthlyTotals> list = new List<WTranslogMonthlyTotals>();

            // Setup Kinds parameters
            string typesStr = "'" + excludedTypes.Select(t => EnumDBCodeAttribute.EnumToDBCode<WTranslogType>(t)).ToCSVString("','") + "'";
            //18Aug14 XN 86624 Update to WHERE clause in F4 summary view
            //StringBuilder typesStr = new StringBuilder();
            //foreach (WTranslogType t in excludedTypes)
            //    typesStr.Append(EnumDBCodeAttribute.EnumToDBCode<WTranslogType>(t));

            // Load in the monthly totals
            GenericTable table = new GenericTable("WTranslog", "WTranslogID");
            table.LoadBySP("pWTranslogMonthlyTotalsBySiteIDNSVCodeFromAndExcludingKinds", "SiteID", siteID, "NSVCode", NSVCode, "fromDate", fromDate, "ExcludedKinds", typesStr);

            // Create a WTranslogMonthlyTotals for each monthly total.
            foreach(DataRow row in table.Table.Rows)
            {
                WTranslogMonthlyTotals monthlyTotals = new WTranslogMonthlyTotals();
                
                monthlyTotals.MonthYear       = new DateTime(Convert.ToInt32(row["Year"]), Convert.ToInt32(row["Month"]), 1);
                monthlyTotals.QuantityInPacks = (row["QtyTotal"] == DBNull.Value) ? null : (decimal?)row["QtyTotal"];

                list.Add ( monthlyTotals );
            }

            return list;
        }

        /// <summary>
        /// Loads all 'I', 'O', 'D', 'L' type logs for the patient in the specified time range.
        /// </summary>
        /// <param name="entityID">Matched on PatID</param>
        /// <param name="startDate">From date and time</param>
        /// <param name="endDate">End date and time</param>
        public void LoadByEpisodeAndDateRange(int entityID, DateTime startDate, DateTime endDate)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            parameters.Add(new SqlParameter("@EntityID",  entityID ));
            parameters.Add(new SqlParameter("@StartDate", startDate)); 
            parameters.Add(new SqlParameter("@EndDate",   endDate  )); 

            LoadBySP("pWTranslogByEntityAndDateRange", parameters);
        }

        /// <summary>
        /// Loads log items by criteria specified (limited to row count)
        /// Uses sp pWTranlogbyCriteriaNEW (note sp does not return all orderlog rows)
        /// 05Jul13 XN added 27252
        /// </summary>
        /// <param name="criteria">Criteria specified</param>
        /// <param name="maxRowCount">Max number of rows to returns</param>
        public void LoadByCriteria(string criteria, int maxRowCount)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();

            parameters.Add(new SqlParameter("@SessionID",   SessionInfo.SessionID   ));
            parameters.Add(new SqlParameter("@SQLWhere",    criteria                ));
            parameters.Add(new SqlParameter("@MaximumRows", maxRowCount             )); 

            LoadBySP("pWTranslogbyCriteriaNEW", parameters);
        }
    }
}
