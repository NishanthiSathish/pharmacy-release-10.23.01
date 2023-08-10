//===========================================================================
//
//							      BaseOrderRow.cs
//
//  Provides base BaseOrderRow and BaseOrderColumnInfo, classes that hold
//  the common fields between the WOrder, WReconcil, and WRequis tables.
//
//	Modification History:
//	21Jul09 XN  Written
//  22Jul09 XN  Made OrderNumber, NSVCode, and SupplierCode writable 
//              so can save data back to database.
//  24Jul09 XN  Added SiteID to the row
//  21Dec09 XN  Added number of missing fields, and got the supplier type
//              to come either from the order table, else if empty, then from
//              the supplier table.
//  30Jan10 XN  WORder.LocCode should not be used to read a products location
//              use ProductStock.LocCode instead
//  02Feb10 XN  F0042698 Added SupplierFullName
//  29Apr10 XN  Made more robust against DB nulls
//  09Sep10 XN  Added row property DeliveryNoteReference (F0054531)
//  26Feb13 XN  Fixed issue where WRequis.SupplierType can be single space string
//		so returns Unkown type rather than getting from WSupplier.SupplierType	
//  19Aug14 XN  Removed BaseOrder as now using BaseTable2
//===========================================================================
using System;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Collections.Generic;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class BaseOrderRow : BaseRow
    {
        /// <summary>DB string field Num</summary>
        public int OrderNumber 
        { 
            get { return FieldToInt(RawRow["Num"]).Value;  }
            set { RawRow["Num"] = IntToField(value);       }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value;  }
            set { RawRow["SiteID"] = IntToField(value);       }
        }

        /// <summary>DB string field Code</summary>
        public string NSVCode 
        { 
            get { return FieldToStr(RawRow["Code"], false, string.Empty); }
            set { RawRow["Code"] = StrToField(value);                     }
        }

        /// <summary>
        /// DB string field LocCode.
        /// DON'T use to get location as NOT valid, use ProductStock.LocCode instead.
        /// </summary>
        public string Location
        {
            get { return FieldToStr(RawRow["LocCode"], true, string.Empty); }
            set { RawRow["LocCode"] = StrToField(value);                    }
        }

        public string SupplierCode
        {
            get { return FieldToStr(RawRow["supcode"], false, string.Empty); }
            set { RawRow["supcode"] = StrToField(value);                     }
        }

        /// <summary>Linked in field from supplier table WSupplier.FullName</summary>
        public string SupplierFullName
        {
            get { return FieldToStr(RawRow["supfullname"], true, string.Empty); }
        }

        /// <summary>Linked in field from supplier table WSupplier.Name</summary>
        public string SupplierName
        {
            get { return FieldToStr(RawRow["supname"], true, string.Empty); }
        }

        /// <summary>Linked in field from supplier table WSupplier.SupplierType</summary>
        public SupplierType SupplierType
        {
            get 
            {
            	string supplierType = FieldToStr(RawRow["SupplierType"], true, string.Empty);
                if (string.IsNullOrEmpty(supplierType))
                    return FieldToEnumByDBCode<SupplierType>(RawRow["WSupplier_SupplierType"]); 
                else
                    return FieldToEnumByDBCode<SupplierType>(supplierType); 
            }
            set { RawRow["SupplierType"] = EnumToFieldByDBCode<SupplierType>(value); }
        }

        /// <summary>
        /// DB int string field [OrdDate], and string field [OrdTime] 
        /// </summary>
        public DateTime? DateTimeOrdered
        {
            get 
            {
                DateTime? dateOrdered = FieldStrDateToDateTime(RawRow["OrdDate"], DateType.DDMMYYYY);
                TimeSpan? timeOrdered = FieldStrTimeToTimeSpan(RawRow["OrdTime"]);

                if (dateOrdered.HasValue && timeOrdered.HasValue)
                    return dateOrdered.Value + timeOrdered.Value;
                else if (dateOrdered.HasValue)
                    return dateOrdered.Value;
                else
                    return null;
            }
            set 
            {
                RawRow["OrdDate"] = DateTimeToFieldStrDate(value, "", DateType.DDMMYYYY); 
                RawRow["OrdTime"] = DateTimeToFieldStrTime(value, true); 
            } 
        }

        /// <summary>
        /// DB int string field [RecDate], and string field [RecTime] 
        /// </summary>
        public DateTime? DateTimeReceived
        {
            get 
            {
                DateTime? dateReceived = FieldStrDateToDateTime(RawRow["RecDate"], DateType.DDMMYYYY);
                TimeSpan? timeReceived = FieldStrTimeToTimeSpan(RawRow["RecTime"]);

                if (dateReceived.HasValue && timeReceived.HasValue)
                    return dateReceived.Value + timeReceived.Value;
                else if (dateReceived.HasValue)
                    return dateReceived.Value;
                else
                    return null;
            }
            set 
            {
                RawRow["RecDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); 
                RawRow["RecTime"] = DateTimeToFieldStrTime(value, true); 
            } 
        }

        /// <summary>DB string field InvNum</summary>
        public string InvoiceNumber
        {
            get { return FieldToStr(RawRow["InvNum"], false, string.Empty); }
            set { RawRow["InvNum"] = StrToField(value);                     }
        }

        /// <summary>DB string field [PayDate]</summary>
        public DateTime? InvoiceDate
        {
            get { return FieldStrDateToDateTime(RawRow["PayDate"], DateType.DDMMYYYY); }
            set { RawRow["PayDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY); }
        }

        /// <summary>
        /// DB string field [QtyOrdered]
        /// Represents quantity originally ordered in packs
        /// </summary>
        public decimal? QuantityOrderedInPacks
        {
            get { return FieldStrToDecimal(RawRow["QtyOrdered"]);  }
            set { RawRow["QtyOrdered"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().QuantityOrderedInPacksLength, true); }
        }

        /// <summary>
        /// DB string field [Outstanding]
        /// Represents quantity left to receive
        /// Will always be in packs (issues with WRequis have been corrected)
        /// </summary>
        public virtual decimal? OutstandingInPacks
        { 
            get { return FieldStrToDecimal(RawRow["Outstanding"]);  }
            set { RawRow["Outstanding"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().OutstandingInPacksLength, true); }
        }

        /// <summary>
        /// DB string field [Received]
        /// Will always be in packs (issues with WRequis have been corrected)
        /// </summary>
        public virtual decimal? ReceivedInPacks
        { 
            get { return FieldStrToDecimal(RawRow["Received"]);  }
            set { RawRow["Received"] = DecimalToFieldStr(value, WOrder.GetColumnInfo().ReceivedInPacksLength, true);    }
        }

        public int PickNumber
        {
            get { return FieldToInt(RawRow["pickno"]) ?? 0; }
            set { RawRow["pickno"] = IntToField(value);     }
        }

        public OrderStatusType Status
        {

            get { return FieldToEnumByDBCode<OrderStatusType>(RawRow["Status"]); }
            set { RawRow["Status"] = EnumToFieldByDBCode<OrderStatusType>(value);  }
        }

        public OrderUrgencyType Urgency
        {
            get { return FieldToEnumByDBCode<OrderUrgencyType>(RawRow["Urgency"]); }
            set { RawRow["Urgency"] = EnumToFieldByDBCode<OrderUrgencyType>(value);  }
        }

        public OrderInternalMethodType InternalMethod
        {
            get { return FieldToEnumByDBCode<OrderInternalMethodType>(RawRow["InternalMethod"]); }
            set { RawRow["InternalMethod"] = EnumToFieldByDBCode<OrderInternalMethodType>(value);  }
        }

        public string PFlag
        {
            get { return FieldToStr(RawRow["PFlag"], false, string.Empty);  }
            set { RawRow["PFlag"] = StrToField(value);                      }
        }

        public int? VATCode 
        {
            get { return FieldToInt(RawRow["VATRateCode"]);  }
            set { RawRow["VATRateCode"] = IntToField(value, true); }
        }

        public string VATRatePct
        {
            get { return FieldToStr(RawRow["VATRatePct"], false, string.Empty);  }
            set { RawRow["VATRatePct"] = StrToField(value);                      }
        }

        public string VATInclusive
        {
            get { return FieldToStr(RawRow["VatInclusive"], false, string.Empty);  }
            set { RawRow["VatInclusive"] = StrToField(value);                      }
        }

        public string NumPrefix
        {
            get { return FieldToStr(RawRow["NumPrefix"], false, string.Empty);  }
            set { RawRow["NumPrefix"] = StrToField(value);                      }
        }

        public string ToFollow
        {
            get { return FieldToStr(RawRow["ToFollow"], false, string.Empty);  }
            set { RawRow["ToFollow"] = StrToField(value);                      }
        }

        public string IssueUnits
        {
            get { return FieldToStr(RawRow["IssueUnits"], false, string.Empty); }
            set { RawRow["IssueUnits"] = StrToField(value);                     }
        }

        public string Stocked
        {
            get { return FieldToStr(RawRow["Stocked"], false, string.Empty); }
            set { RawRow["Stocked"] = StrToField(value);                     }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], false, string.Empty); }
            set { RawRow["Description"] = StrToField(value);                     }
        }

        public string CustOrdNo
        {
            get { return FieldToStr(RawRow["CustOrdNo"], false, string.Empty);  }
            set { RawRow["CustOrdNo"] = StrToField(value);                      }
        }

        public string InternalSiteNo
        {
            get { return FieldToStr(RawRow["InternalSiteNo"], false, string.Empty); }
            set { RawRow["InternalSiteNo"] = StrToField(value);                     }
        }

        public string ShelfPrinted
        {
            get { return FieldToStr(RawRow["ShelfPrinted"], false, string.Empty);  }
            set { RawRow["ShelfPrinted"] = StrToField(value);                      }
        }

        public string CreatedUser
        {
            get { return FieldToStr(RawRow["CreatedUser"], false, string.Empty);  }
            set { RawRow["CreatedUser"] = StrToField(value);                      }
        }

        public bool? InDispute
        {
            get { return FieldToBoolean(RawRow["InDispute"], false);               }
            set { RawRow["InDispute"] = BooleanToField(value, true, string.Empty); }
        }

        public string InDisputeUser
        {
            get { return FieldToStr(RawRow["InDisputeUser"], false, string.Empty);  }
            set { RawRow["InDisputeUser"] = StrToField(value);                      }
        }

        public string CodingSlipDate
        {
            get { return FieldToStr(RawRow["CodingSlipDate"], false, string.Empty); }
            set { RawRow["CodingSlipDate"] = StrToField(value);                     }
        }
        
        public string DeliveryNoteReference  // 09Sep10 XN F0054531 Added row property DeliveryNoteReference
        {
            get { return FieldToStr(RawRow["DeliveryNoteReference"]);  }
            set { RawRow["DeliveryNoteReference"] = StrToField(value); }
        }

        public override string ToString()
        {
            return OrderNumber.ToString();
        }
    }

    public class BaseOrderColumnInfo : BaseColumnInfo
    {
        public BaseOrderColumnInfo(string tableName) : base(tableName) { }

        public int OutstandingInPacksLength     { get { return tableInfo.GetFieldLength("Outstanding"); } }  
        public int ReceivedInPacksLength        { get { return tableInfo.GetFieldLength("Received");    } }  
        public int QuantityOrderedInPacksLength { get { return tableInfo.GetFieldLength("QtyOrdered");  } }  
        public int VATAmountLength              { get { return tableInfo.GetFieldLength("VATAmount");   } }  
        public int ConversionFactorLength       { get { return tableInfo.GetFieldLength("ConvFact");    } }
        public int CreatedUserLength            { get { return tableInfo.GetFieldLength("CreatedUser"); } }
        public int DeliveryNoteReferenceLength  { get { return tableInfo.GetFieldLength("DeliveryNoteReference");   } } // 09Sep10 XN F0054531 Added row property DeliveryNoteReference
    }

    // 19Aug14 XN Removed as now using BaseTable2
    //public class BaseOrder<T,C> : BaseTable<T,C>
    //    where T : BaseRow, new()
    //    where C : BaseColumnInfo, new()
    //{
    //    public BaseOrder(string tableName, string pkcolumnName) : base(tableName, pkcolumnName)
    //    {
    //    }

    //    public BaseOrder(string tableName, string pkcolumnName, RowLocking rowLocking) : base(tableName, pkcolumnName, rowLocking)
    //    {
    //    }
    //}
}
