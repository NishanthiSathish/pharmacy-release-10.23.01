//===========================================================================
//
//							    QSField.cs
//
//  This class represents the QSField table.
//
//  QuesScrol class that provides the accessors with information about the 
//  field in a data class (BaseRow dervived class).
//
//  Fields are grouped by AccessorTag (name of the accessor to use).
//  The data class field that the row relates to is determined by the PropertyName,
//  which can be the actual name of the propety or virutal property (e.g. "{cost}")
//  used to return extra information.
//  
//  How data is displayed is determined by DataType, and ExtraFormatOption fields 
//  (provides extra option above the standard determined by DataType)
//
//	Modification History:
//  08Sep14 XN  Written 98658
//  15Jul16 XN  126634 added GetIdByAccessorTagAndProperty
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    /// <summary>Data type for the field</summary>
    public enum QSDataType
    {
        /// <summary>Field is a int, decimal, or double</summary>
        Number,

        /// <summary>Field is a date only</summary>
        Date,

        /// <summary>Field is a date and time</summary>
        DateTime,

        /// <summary>Field is a time value only</summary>
        Time,

        /// <summary>Field represents a fincancial value</summary>
        Money,

        /// <summary>Field represetns text</summary>
        Text,

        /// <summary>Field is an enum</summary>
        Enum,

        /// <summary>Field is a bool</summary>
        Bool
    }

    /// <summary>represents a single row in QSField</summary>
    public class QSFieldRow : BaseRow
    {
        public int QSFieldID
        {
            get { return FieldToInt(RawRow["QSFieldID"]).Value; } 
        }

        public string AccessorTag
        {
            get { return FieldToStr(RawRow["AccessorTag"], true, string.Empty); } 
            set { RawRow["AccessorTag"] = StrToField(value);                     }
        }

        public int DataIndex
        {
            get { return FieldToInt(RawRow["DataIndex"]).Value; } 
            set { RawRow["DataIndex"] = IntToField(value);      }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); } 
            set { RawRow["Description"] = StrToField(value);                     }
        }

        public QSDataType DataType
        {
            get { return FieldStrToEnum<QSDataType>(RawRow["DataType"], true).Value; } 
            set { RawRow["DataType"] = EnumToFieldStr<QSDataType>(value);            }
        }

        public string ExtraFromatOptions
        {
            get { return FieldToStr(RawRow["ExtraFromatOptions"], true, string.Empty); } 
            set { RawRow["ExtraFromatOptions"] = StrToField(value);                    }
        }

        public string PropertyName
        {
            get { return FieldToStr(RawRow["PropertyName"], true, string.Empty); } 
            set { RawRow["PropertyName"] = StrToField(value);                    }
        }
    }

    /// <summary>Provides column information for QSField, such as maximum field lengths</summary>
    public class QSFieldColumnInfo : BaseColumnInfo
    {
        public QSFieldColumnInfo() : base ("QSField") {  }

        public int AccessorTagLength        { get { return base.FindColumnByName("AccessorTag"      ).Length; } }
        public int DescriptionLength        { get { return base.FindColumnByName("Description"      ).Length; } }
        public int DataTypeLength           { get { return base.FindColumnByName("DataType"         ).Length; } }
        public int ExraFromatOptionsLength  { get { return base.FindColumnByName("ExraFromatOptions").Length; } }
        public int PropertyNameLength       { get { return base.FindColumnByName("PropertyName"     ).Length; } }
    }

    /// <summary>Represents QSField table</summary>
    public class QSField : BaseTable2<QSFieldRow, QSFieldColumnInfo>
    {
        public QSField() : base ("QSField") {  }

        /// <summary>Loads QSFields by accessor tag</summary>
        public void LoadByAccessorTag(string accessorTag)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("AccessorTag", accessorTag);
            LoadBySP("pQSFieldByAccessorTag", parameters);
        }

        /// <summary>Returns the QSField 126643 XN 15Jul16</summary>
        /// <param name="accessorTag">Accessor tag</param>
        /// <param name="propertyName">Property name</param>
        /// <returns>field</returns>
        public static QSFieldRow GetByAccessorTagAndProperty(string accessorTag, string propertyName)
        {
            QSField fields = new QSField();
            fields.LoadByAccessorTag (accessorTag);
            return fields.FirstOrDefault(c => c.PropertyName.EqualsNoCaseTrimEnd(propertyName));
        }
    }
}
