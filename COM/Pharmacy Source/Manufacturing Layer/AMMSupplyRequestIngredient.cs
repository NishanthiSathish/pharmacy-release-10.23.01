// -----------------------------------------------------------------------
// <copyright file="AMMSupplyRequestIngredient.cs" company="Emis Health">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// This class represents the aMMSupplyRequestIngredient table.  
//
// Only supports reading, updating, and inserting from table.
//
// Represents all ingredients for a supply request
//
// Modification History:
// 02Jul15 XN Created 39882
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
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>State of the ingredient</summary>
    public enum aMMSupplyRequestIngredientState
    {
        /// <summary>Ingredient not selected yet</summary>
        [EnumDBCode("")]
        NotSelected, 

        /// <summary>Gathered by not issued</summary>
        [EnumDBCode("G")]
        Gathered, 

        /// <summary>Returning ingredient</summary>
        [EnumDBCode("R")]
        Returning, 

        /// <summary>Committed</summary>
        [EnumDBCode("C")]
        Committed
    }

    /// <summary>Row in the AMMSupplyRequestIngredient table</summary>
    public class aMMSupplyRequestIngredientRow : BaseRow
    {
        /// <summary>Gets Primary key</summary>
        public int aMMSupplyRequestIngredientId
        {
            get { return FieldToInt(this.RawRow["AMMSupplyRequestIngredientID"]).Value; }
        }

        /// <summary>Gets or sets AMMSupply request ID</summary>
        public int RequestId
        {
            get { return FieldToInt(this.RawRow["RequestID"]).Value; }
            set { this.RawRow["RequestID"] = IntToField(value);      }
        }

        /// <summary>Gets or sets NSVCode for the ingredient (might be partial description)</summary>
        public string NSVCode
        {
            get { return FieldToStr(this.RawRow["NSVCode"], true, string.Empty);  }
            set { this.RawRow["NSVCode"] = StrToField(value);                     }
        }

        /// <summary>Gets or sets batch number used for the ingredient</summary>
        public string BatchNumber
        {
            get { return FieldToStr(this.RawRow["BatchNumber"], true, string.Empty);  }
            set { this.RawRow["BatchNumber"] = StrToField(value);                     }
        }

        /// <summary>Gets or sets expiry date of the ingredient</summary>
        public DateTime? ExpiryDate
        {
            get { return FieldToDateTime(this.RawRow["ExpiryDate"]);  }
            set { this.RawRow["ExpiryDate"] = DateTimeToField(value); }
        }

        /// <summary>Gets or sets current state in the process (waiting, assembled, second checked) for ingredient </summary>
        public aMMSupplyRequestIngredientState State
        {
            get { return FieldToEnumByDBCode<aMMSupplyRequestIngredientState>(this.RawRow["State"]);  }
            set { this.RawRow["State"] = EnumToFieldByDBCode(value);                                  }
        }

        /// <summary>Gets or sets date ingredient was assembled</summary>
        public DateTime? AssembledByDate
        {
            get { return FieldToDateTime(this.RawRow["AssembledBy_Date"]);  }
            set { this.RawRow["AssembledBy_Date"] = DateTimeToField(value); }
        }

        /// <summary>Gets or sets person who selected the ingredient</summary>
        public int? AssembledByEntityId
        {
            get { return FieldToInt(this.RawRow["AssembledBy_EntityID"]); }
            set { this.RawRow["AssembledBy_EntityID"] = IntToField(value);      }
        }

        /// <summary>Gets or sets date ingredient was checked</summary>
        public DateTime? CheckedByDate
        {
            get { return FieldToDateTime(this.RawRow["CheckedBy_Date"]);  }
            set { this.RawRow["CheckedBy_Date"] = DateTimeToField(value); }
        }

        /// <summary>Gets or sets person who second checked the ingredients</summary>
        public int? CheckedByEntityId
        {
            get { return FieldToInt(this.RawRow["CheckedBy_EntityID"]); }
            set { this.RawRow["CheckedBy_EntityID"] = IntToField(value);      }
        }

        /// <summary>Gets or sets quantity</summary>
        public double QtyInIssueUnits
        {
            get { return FieldToDouble(this.RawRow["QtyInIssueUnits"]).Value; }
            set { this.RawRow["QtyInIssueUnits"] = DoubleToField(value);      }
        }

        /// <summary>Gets or sets index of the original drug in the formula (zero baseD)</summary>
        public int FormulaIndex
        {
            get { return FieldToInt(this.RawRow["FormulaIndex"]).Value; }
            set { this.RawRow["FormulaIndex"] = IntToField(value);      }
        }

        /// <summary>Gets or sets the self check reason</summary>
        public string SelfCheckReason
        {
            get { return FieldToStr(this.RawRow["SelfCheckReason"]);  } 
            set { this.RawRow["SelfCheckReason"] = StrToField(value); }
        }

        /// <summary>Gets or sets the error message for the drug</summary>
        public string ErrorMessage
        {
            get { return FieldToStr(this.RawRow["ErrorMessage"]);  } 
            set { this.RawRow["ErrorMessage"] = StrToField(value); }
        }

        /// <summary>Gets a value indicating whether ingredient has error</summary>
        public bool HasError
        {
            get { return !string.IsNullOrEmpty(this.ErrorMessage); }
        }

        /// <summary>Gets a value indicating whether is drug</summary>
        public bool IsDrug
        {
            get { return true; }
        }

        /// <summary>Clear the checked stage</summary>
        public void ClearChecked()
        {
            this.CheckedByDate    = null;
            this.CheckedByEntityId= null;
            this.State            = aMMSupplyRequestIngredientState.Gathered;
        }
    }

    /// <summary>Column info abut the AMMSupplyRequestIngredient table</summary>
    public class aMMSupplyRequestIngredientColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="aMMSupplyRequestIngredientColumnInfo"/> class.</summary>
        public aMMSupplyRequestIngredientColumnInfo() : base("AMMSupplyRequestIngredient") { }

        /// <summary>Gets length of NSVCode field</summary>
        public int NSVCodeLength { get { return this.FindColumnByName("NSVCode").Length; } }

        /// <summary>Gets length of NSVCode field</summary>
        public int BatchNumberLength { get { return this.FindColumnByName("BatchNumber").Length; } }

        /// <summary>Gets error message field length</summary>
        public int ErrorMessageLength { get { return this.FindColumnByName("ErrorMessage").Length; } }
    }

    /// <summary>aMMSupplyRequestIngredient table</summary>
    public class aMMSupplyRequestIngredient : BaseTable2<aMMSupplyRequestIngredientRow, aMMSupplyRequestIngredientColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="aMMSupplyRequestIngredient"/> class.</summary>
        public aMMSupplyRequestIngredient() : base("aMMSupplyRequestIngredient")
        {
            this.ConflictOption = ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Load all ingredients for the supply request</summary>
        /// <param name="requestId">Supply request Id</param>
        public void LoadByRequestId(int requestId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("RequestID", requestId);
            this.LoadBySP("pAMMSupplyRequestIngredientByRequestID", parameters);
        }
    }

    /// <summary>aMMSupplyRequestIngredient enumeration extension methods</summary>
    public static class aMMSupplyRequestIngredientEnumerationExtension
    {
        /// <summary>Returns list of items that are drugs</summary>
        /// <param name="list">List to order</param>
        /// <returns>drug items</returns>
        public static IEnumerable<aMMSupplyRequestIngredientRow> FindDrugs(this IEnumerable<aMMSupplyRequestIngredientRow> list)
        {
            return list.Where(i => i.IsDrug);
        }

        /// <summary>
        /// Order the ingredients for display 
        /// Order by FormulaIndex, aMMSupplyRequestIngredientId
        /// </summary>
        /// <param name="list">List to order</param>
        /// <returns>Order list</returns>
        public static IEnumerable<aMMSupplyRequestIngredientRow> OrderByDisplay(this IEnumerable<aMMSupplyRequestIngredientRow> list)
        {
            return list.OrderBy(i => i.FormulaIndex).ThenBy(i => i.aMMSupplyRequestIngredientId);
        }
    }
}
