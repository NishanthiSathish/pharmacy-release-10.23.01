//===========================================================================
//
//							        BaseRow.cs
//
//	Base class for the rows in a table.
//
//  The class should be inherited from rather than being used directly, with 
//  the derived class providing properties for getting\setting field values.
//
//  To be able to use a derived instance of the class, the RawRow needs to be
//  set to a DataSet row (this is normally all handled by BaseTable).
//
//  The class also contain FieldTo<ValueType> and <ValueType>ToField conversions
//  functions, and a SetDefaults function that can be overwritten to assign 
//  default values
//
//  Usage:
//
//  public class WBatchStockLevelRow : BaseRow
//  {
//      public int WBatchStockLevelID
//      {
//          get { return FieldToInt(RawRow["WBatchStockLevelID"]).Value; }
//      }
//
//      public int SiteID
//      {
//          get { return FieldToInt(RawRow["SiteID"]).Value;  }
//          set { RawRow["SiteID"] = IntToField(value);       }
//      }
//  }
//      
//	Modification History:
//	30Mar09 XN  Written
//  28Apr09 XN  Added FieldToEnumViaDBLookup, and EnumToFieldViaDBLookup
//  21Jul09 XN  Added methods FieldToShort, ShortToField and support for 
//              DD/MM/YYYY string data type, pluse got FieldToBoolean to use 
//              BoolExtensions.PharmacyParse to convert strings to bools
//  21Dec09 XN  Extended IntToField method. Fixed FieldToEnum. 
//              Added FieldStrToEnum and EnumToFieldStr
//  27Oct11 XN  Allowed Copy function to copy readonly rows
//  04Jan12 AJK Added handling for epoch date handling
//  12Apr12 AJK 31015 Made FieldStrDateToDateTime and the DateType enum public
//  29May13 XN  Added method HasDataChanged 27038
//  05Jul13 XN  Made FieldStrTimeToTimeSpan public 27252
//  10Feb14 XN  Update CopyFrom, HasDataChanged, added HasFieldChanged, GetChangedColumns 56701
//  12Mar14 XN  Added field to long (bigint) for DM&D
//  20Jan15 XN  Update EnumToFieldViaDBLookup to have optional addIfNotExists parameter 26734 
//  08May15 XN  Added better error handling
//              New method CreateFriendlyException
//              All method that read\write fields moved from static to instance methods (so can create better error)
//              Wrapped all FieldTo methods in try catch
//  31Mar16 XN  FieldToEnumByDBCode added trim end
//  18Apr16 XN  Added AddColumnIfNotExists 123082
//===========================================================================
namespace ascribe.pharmacy.basedatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Diagnostics;
    using System.Linq;
    using System.Reflection;
    using System.Text;
    using ascribe.pharmacy.shared;
    using TRNRTL10;

    public class BaseRow
    {
        #region Types
        /// <summary>Represents the format of a pharmacy int or string date field</summary>
        public enum DateType
        {
            DDMMYYYY,

            /// <summary>Any DD/MM/YYYY, or DD-MM-YYYY format</summary>
            DD_MM_YYYY,

            YYYYMMDD
        };
        #endregion

        #region Constructor
        public BaseRow()
        {
            RawRow = null;
        }
        #endregion

        #region Properties
        /// <summary>Gets access to the raw data row</summary>
        public DataRow RawRow { get; set; }
        #endregion

        #region Public functions
        /// <summary>Copies the data from row to this item</summary>
        /// <param name="row">source to copy from</param>
        /// <param name="columnsToCopy">Columns to copy (null for all columns) 56701 XN 10Feb14 Added</param>
        /// <param name="dataRowVersionToCopyFrom">data row version to copy from (values will always be coppied to current version in this) 56701 XN 10Feb14 Added</param>
        public void CopyFrom(BaseRow row, IEnumerable<string> columnsToCopy = null, DataRowVersion dataRowVersionToCopyFrom = DataRowVersion.Default)
        {            
            // If no columns specified then get all
            if (columnsToCopy == null)
                columnsToCopy = row.RawRow.Table.Columns.Cast<DataColumn>().Select(s => s.ColumnName);

            foreach ( string columnName in columnsToCopy )            
            {
                if ( this.RawRow.Table.Columns.Contains(columnName) )
                {
                    DataColumn column = this.RawRow.Table.Columns[columnName];
                    bool isReadOnly = column.ReadOnly;
                    
                    column.ReadOnly = false;
                    this.RawRow[columnName] = row.RawRow[columnName, dataRowVersionToCopyFrom];
                    column.ReadOnly = isReadOnly;
                }
            }
        }

        /// <summary>
        /// Returns if a fields has actual changed (rather than if it has been set to it's origin value)
        /// Will also return true if the row has been added 9May15 XN
        /// e.g.
        /// If Description is equal to "Hello" then
        ///     BaseRow["Description"] = "Hello" 
        ///     HasFieldChanged("Description");     Will be false
        /// But    
        ///     BaseRow["Description"] = "Hi" 
        ///     HasFieldChanged("Description");     Will be true
        /// 56701 XN 10Feb14 Added
        /// </summary>
        public bool HasFieldChanged(string columnName)
        {
            return RawRow.RowState == DataRowState.Added || !RawRow[columnName, DataRowVersion.Original].Equals(RawRow[columnName, DataRowVersion.Current]);
        }

        /// <summary>
        /// Returns if data in the row has changed (since last save or load)
        /// This test if the data has actually changed rather than if it has been set to it's original value (see HasFieldChanged)
        /// Will also return true if the row has been added (09May15 XN)
        /// 29May13 XN 27038
        /// 56701 XN 10Feb14 moved part of code to HasFieldChanged so can be shared with GetChangedColumns
        /// </summary>
        public bool HasDataChanged()
        {
            // 09May15 XN simplified and also returns true if row has been added
            //foreach (var col in this.RawRow.Table.Columns.Cast<DataColumn>())
            //{
            //    if (HasFieldChanged(col.ColumnName))
            //        return true;
            //}
            //return false;

            return this.RawRow.Table.Columns.Cast<DataColumn>().Any(c => this.HasFieldChanged(c.ColumnName));
        }

        /// <summary>
        /// Returns if list of columns that have been altered (since last save or load)
        /// This test if the data has actually changed rather than if it has been set to it's original value (see HasFieldChanged)
        /// Will return all columns if row has been added
        /// 56701 XN 10Feb14 Added
        /// </summary>
        public IEnumerable<DataColumn> GetChangedColumns()
        {
            // 09May15 XN this.RawRow.RowState == DataRowState.Added is now done in HasFieldChanged so removed from here
            //foreach (var col in this.RawRow.Table.Columns.Cast<DataColumn>())
            //{
            //    if (this.RawRow.RowState == DataRowState.Added || HasFieldChanged(col.ColumnName))
            //        yield return col;
            //}
            
            return this.RawRow.Table.Columns.Cast<DataColumn>().Where(c => this.HasFieldChanged(c.ColumnName));
        }
        #endregion

        #region Field Helper Functions
        /// <summary>
        /// Converts a data set field to a string (or nullVal if string is null)
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <param name="trimString">If string is to be trimmed before returning (defaults to false)</param>
        /// <param name="nullVal">value to return is field is null (defaults to null)</param>
        /// <returns>string value</returns>
        protected internal string FieldToStr(object field)
        {
            return FieldToStr(field, false);
        }
        protected internal string FieldToStr(object field, bool trimString)
        {
            return FieldToStr(field, trimString, null);
        }
        protected internal string FieldToStr(object field, bool trimString, string nullVal)
        {
            try
            {
                if (field == DBNull.Value)
                    return nullVal;
                else if (trimString)
                    return ((string)field).Trim();
                else
                    return (string)field;

            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }
        
        /// <summary>
        /// Converts a string to a field
        /// </summary>
        /// <param name="val">Value to convert to field</param>
        /// <param name="emptyStrAsNullVal">if empty strings are to be converted to null values in db (default false)</param>
        /// <returns>field</returns>
        protected internal object StrToField(string val)
        {
            return StrToField(val, false);
        }
        protected internal object StrToField(string val, bool emptyStrAsNullVal)
        {
            if ((val == null) || (emptyStrAsNullVal && (val == string.Empty)))
                return DBNull.Value;
            else
                return val;
        }


        /// <summary>
        /// Converts a field to an int.
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <returns>int value, or null, if field is empty</returns>
        protected internal int? FieldToInt(object field)
        {
            try
            {
                if ((field != DBNull.Value) && (field.ToString().Trim() != string.Empty))
                    return Convert.ToInt32(field);
                else
                    return null;
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts an int to a field
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <param name="emptyStrAsNull">If empty value is represented as a string (default is false)</param>
        /// <returns>field value</returns>
        protected internal object IntToField(int? val)
        {
            return IntToField(val, false);
        }
        protected internal object IntToField(int? val, bool emptyStrAsNull)
        {
            if (val.HasValue)
                return val.Value;
            else if (emptyStrAsNull)
                return string.Empty;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a field to a long.
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <returns>long value, or null, if field is empty</returns>
        protected internal long? FieldToLong(object field)
        {
            try
            {
                if ((field != DBNull.Value) && (field.ToString().Trim() != string.Empty))
                    return Convert.ToInt64(field);
                else
                    return null;
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts an long to a field
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <param name="emptyStrAsNull">If empty value is represented as a string (default is false)</param>
        /// <returns>field value</returns>
        protected internal object LongToField(long? val, bool emptyStrAsNull = false)
        {
            if (val.HasValue)
                return val.Value;
            else if (emptyStrAsNull)
                return string.Empty;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a field to a short
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <returns>short value, or null if field is empty</returns>
        protected internal short? FieldToShort(object field)
        {
            try
            {
                if (field != DBNull.Value)
                    return Convert.ToInt16(field);
                else
                    return null;
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a short to a field
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <returns>field value</returns>
        protected internal object ShortToField(short? val)
        {
            if (val.HasValue)
                return val.Value;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a datetime field to a datatime
        /// Dates in the database which match the pharmacy fundamental epoch (30-12-1899)
        /// will be converted to null, which is what it is meant to represent
        /// </summary>
        /// <param name="field">field to convert</param>
        /// <returns>datetime value, or null, if field is empty</returns>
        protected internal DateTime? FieldToDateTime(object field)
        {
            try
            {
                if (field == DBNull.Value)
                    return null;
                else
                {
                    DateTime epoch = new DateTime(1899,12,30,0,0,0,0);
                    int result = DateTime.Compare(Convert.ToDateTime(field), epoch);
                    if (result == 0)
                        return null;
                    else
                        return Convert.ToDateTime(field);
                }
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a datetime to db field
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <returns>field value</returns>
        protected internal object DateTimeToField(DateTime? val)
        {
            if (val.HasValue)
                return val;
            else
                return DBNull.Value;
        }

        /// <summary>
        /// Converts a field to a Boolean
        /// The method will also work on string fields (case insensitive)
        ///     "Y", "YES", "1", "-1", or "TRUE" converted to true
        ///     "N", "NO", "0", or "FALSE" converted to false
        /// See BoolExtensions.PharmacyParse for full list    
        /// Any other string value returns null.
        /// </summary>
        /// <param name="field">field to convert</param>
        /// <param name="nullVal">value to return if field is null (default null)</param>
        /// <returns>bool value</returns>
        protected internal bool? FieldToBoolean(object field, bool? nullVal = null)
        {
            try
            {
                return BaseRow.FieldToBooleanStatic(field, nullVal);
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }
        protected internal static bool? FieldToBooleanStatic(object field, bool? nullVal = null)
        {
            if ((field == DBNull.Value) || (field == null))
                return nullVal;
            else if (field is string)
            {
                try
                {
                    string strField = ((string)field).ToUpper();
                    return BoolExtensions.PharmacyParse(strField);
                }
                catch (Exception)
                {
                    return nullVal;
                }
            }
            else
                return Convert.ToBoolean(field);
        }

        /// <summary>
        /// Converts a bool to a field value
        /// </summary>
        /// <param name="val">Value to convert</param>
        /// <param name="trueVal">Value to set the field if val is true (default true)</param>
        /// <param name="falseVal">Value to set the field if val is false (default false)</param>
        /// <param name="nullValue">Value to set the field if val is null (default null)</param>
        /// <returns>field value</returns>
        protected internal object BooleanToField(bool? val)
        {
            return BooleanToField(val, true, false, DBNull.Value);
        }
        protected internal object BooleanToField(bool? val, object trueVal, object falseVal)
        {
            return BooleanToField(val, trueVal, falseVal, DBNull.Value);
        }
        protected internal object BooleanToField(bool? val, object trueVal, object falseVal, object nullValue)
        {
            if (val.HasValue)
                return (val.Value) ? trueVal : falseVal;
            else
                return nullValue;
        }


        /// <summary>
        /// Converts a field to a double.
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <returns>double or null if field is empty</returns>
        protected internal double? FieldToDouble(object field)
        {
            try
            {
                if ((field == DBNull.Value) || (field == null))
                    return null;
                else
                    return Convert.ToDouble(field);
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Convert a double to a field
        /// </summary>
        /// <param name="val">Value to convert</param>
        /// <returns>field value</returns>
        protected internal object DoubleToField(double? val)
        {
            if (val.HasValue)
                return val;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a field to a decimal
        /// </summary>
        /// <param name="field">Value to convert</param>
        /// <returns>decimal or null if field is empty</returns>
        protected internal decimal? FieldToDecimal(object field)
        {
            try
            {
                if ((field == DBNull.Value) || (field == null) || (field.ToString().Trim() == string.Empty))
                    return null;
                else if (field is string)   // Should not go here as should use FieldStrToDecimal
                    return decimal.Parse((string)field, System.Globalization.NumberStyles.Number | System.Globalization.NumberStyles.AllowExponent);
                else
                    return Convert.ToDecimal(field);
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a decimal to a field.
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <returns>field value</returns>
        protected internal object DecimalToField(decimal? val)
        {
            if (val.HasValue)
                return val;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a string field to a decimal
        /// </summary>
        /// <param name="field">field to convert</param>
        /// <returns>decimal or null if field is empty</returns>
        protected internal decimal? FieldStrToDecimal(object field)
        {
            try
            {
                if ((field == DBNull.Value) || (field.ToString().Trim() == string.Empty))
                    return null;
                else if (field is string)
                    return decimal.Parse((string)field, System.Globalization.NumberStyles.Number | System.Globalization.NumberStyles.AllowExponent);
                else
                    return Convert.ToDecimal(field);
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a decimal to a string field
        /// e.g. convert to string field of 6 characters
        ///      456.3m      returns field string "456.30"
        ///      456.3443m   returns field string "456.34"
        ///      456.3453m   returns field string "456.35"
        ///      456.3463m   returns field string "456.35"
        ///      -456.3443m  returns field string "-456.3"
        ///      -456.3543m  returns field string "-456.4"
        ///      -456.3643m  returns field string "-456.4"
        ///      4563443m    returns field string "5E+006"
        ///      null        returns field string db null (if nullAsBlankString is false)
        ///      null        returns field string ""      (if nullAsBlankString is true)
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <param name="fieldLength">Max length of the string field</param>
        /// <param name="nullAsBlankString">if null val to be saved as blank string (default false)</param>
        /// <returns>string field</returns>
        protected internal object DecimalToFieldStr(decimal? oVal, int fieldLength)
        {
            return DecimalToFieldStr(oVal, fieldLength, false);
        }
        protected internal object DecimalToFieldStr(decimal? val, int fieldLength, bool nullAsBlankString)
        {
            if (val.HasValue)
                return val.ToString(fieldLength);
            else if (nullAsBlankString)
                return string.Empty;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a string field to an enumerated type, or default(T) if field is null.
        /// The enumerated type must support EnumDBCode.
        /// (see EnumByDBCode for details).
        /// </summary>
        /// <typeparam name="T">Enumerated type (that supports EnumDBCode)</typeparam>
        /// <param name="field">field to convert</param>
        /// <returns>Enumerated type></returns>
        protected internal T FieldToEnumByDBCode<T>(object field)
        {
            try
            {
                //return EnumDBCodeAttribute.DBCodeToEnum<T>(field.ToString()); XN 31Mar16 added trim end
                return EnumDBCodeAttribute.DBCodeToEnum<T>(field.ToString().TrimEnd());
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }
        
        /// <summary>
        /// Converts an enumerated type to a db code string field
        /// The enumerated type must support EnumDBCode.
        /// (see EnumByDBCode for details).
        /// </summary>
        /// <typeparam name="T">Enumerated type (that supports EnumDBCode)</typeparam>
        /// <param name="value">Enumerated vale to convert</param>
        /// <returns>db coded string</returns>
        protected internal object EnumToFieldByDBCode<T>(T value)
        {
            return EnumDBCodeAttribute.EnumToDBCode<T>((T)value);
        }


        /// <summary>
        /// Converts a integer field date to a datetime.
        /// The integer field must store the date in yyyymmdd, or ddmmyyyy
        /// Where yyyy - is the 4 digit year
        ///       mm   - is the 2 digit month
        ///       dd   - is the 2 digit day
        ///      
        /// e.g. 19940302   would represent 2 March 1994 in yyyymmdd   format
        /// e.g. 02031994   would represent 2 March 1994 in ddmmyyyy   format
        /// </summary>
        /// <param name="field">integer field to convert</param>
        /// <param name="type">Type of int date (e.g. DDMMYYYY, YYYYMMDD)</param>
        /// <returns>datetime or null if field is empty or 0</returns>
        protected internal DateTime? FieldIntDateToDateTime(object field, DateType type)
        {
            try
            {
                int year, month, day;

                // Return null if input null
                if (field == DBNull.Value)
                    return null;

                // now ready to convert int value to datetime
                if (type == DateType.YYYYMMDD)
                {
                    // Try to convert field to int (returns null if convert fails)
                    int value = 0;
                    try
                    {
                        value = Convert.ToInt32(field); 
                    }
                    catch(FormatException)
                    {
                        return null;
                    }
                
                    if (value == 0)
                        return null;    // Returns null if input was 0

                    year  = value / 10000;
                    month = (value - (year * 10000)) / 100;
                    day   = (value - (year * 10000) - (month * 100));
                }
                else if (type == DateType.DDMMYYYY)
                {
                    // Try to convert field to int (returns null if convert fails)
                    int value;
                    try
                    {
                        value = Convert.ToInt32(field); 
                    }
                    catch(FormatException)
                    {
                        return null;
                    }
                
                    if (value == 0) 
                        return null;    // Returns null if input was 0     

                    day   = value / 1000000;
                    month = (value - (day * 1000000)) / 10000;
                    year  = (value - (day * 1000000) - (month * 10000));
                }
                else if (type == DateType.DD_MM_YYYY)
                {
                    // extract day, month and year values (returns null if convert fails)
                    string value = field.ToString();
                    try
                    {
                        day  = Convert.ToInt32(value.Substring(0, 2));
                        month= Convert.ToInt32(value.Substring(3, 2));
                        year = Convert.ToInt32(value.Substring(6, 4));
                    }
                    catch(Exception)
                    {
                        return null;
                    }
                }
                else
                {
                    string msg = string.Format("Unsupported IntDateType.{0}", type);
                    throw new ApplicationException(msg);
                }

                return new DateTime(year, month, day);
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a datetime to a integer field date, to yyyymmdd, or ddmmyyyy
        /// Where yyyy - is the 4 digit year
        ///       mm   - is the 2 digit month
        ///       dd   - is the 2 digit day
        ///      
        /// e.g. 2 March 1994 would return 19940302   in yyyymmdd format
        ///                                02031994   in ddmmyyyy format
        /// 
        /// Note: Though this function supports the DD_MM_YYYY you should use
        /// the DateTimeToFieldStrDate function instead (included here for code reuse).
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <param name="nullValue">value to return if null, normally DBNull.Value, 0, or ""</param>
        /// <param name="type">Type of int date (e.g. DDMMYYYY, YYYYMMDD)</param>
        /// <returns>integer field value (except if type is DD_MM_YYYY then string)</returns>
        protected internal object DateTimeToFieldIntDate(DateTime? value, object nullValue, DateType type)
        {
            if (type == DateType.DD_MM_YYYY)
                throw new InvalidOperationException(string.Format("DateTimeToFieldIntDate does not support DataType type {0}", type.ToString()));

            return DateTimeToFieldIntDate(value, nullValue, type, '/');
        }
        private object DateTimeToFieldIntDate(DateTime? value, object nullValue, DateType type, char separator)
        {
            if (value.HasValue)
            {
                switch (type)
                {
                case DateType.YYYYMMDD:  return (value.Value.Year * 10000) + (value.Value.Month * 100) + (value.Value.Day);     
                case DateType.DDMMYYYY:  return (value.Value.Day * 1000000) + (value.Value.Month * 10000) + (value.Value.Year); 
                case DateType.DD_MM_YYYY:return string.Format("{0:00}{3}{1:00}{3}{2:0000}", value.Value.Day, value.Value.Month, value.Value.Year, separator); 
                default:
                    string msg = string.Format("Unsupported IntDateType.{0}", type);
                    throw new ApplicationException(msg);
                }
            }
            else
                return nullValue;
        }


        /// <summary>
        /// Converts a string field date to a datetime.
        /// The string field must store the date in yyyymmdd, dd_mm_yyyy, or ddmmyyyy
        /// Where yyyy - is the 4 digit year
        ///       mm   - is the 2 digit month
        ///       dd   - is the 2 digit day
        ///      
        /// e.g. 19940302   would represent 2 March 1994 in yyyymmdd   format
        /// e.g. 02031994   would represent 2 March 1994 in ddmmyyyy   format
        /// e.g. 02/03/1994 would represent 2 March 1994 in dd_mm_yyyy format
        /// </summary>
        /// <param name="field">integer field to convert</param>
        /// <param name="type">Type of int date (e.g. DDMMYYYY, DD_MM_YYYY, YYYYMMDD)</param>
        /// <returns>datetime or null if field is empty or 0</returns>
        public DateTime? FieldStrDateToDateTime(object field, DateType type)
        {
            return FieldIntDateToDateTime(field, type);
        }

        /// <summary>
        /// Converts a datetime to a string field date, to yyyymmdd, dd_mm_yyyy, or ddmmyyyy
        /// Where yyyy - is the 4 digit year
        ///       mm   - is the 2 digit month
        ///       dd   - is the 2 digit day
        ///      
        /// e.g. 2 March 1994 would return 19940302   in yyyymmdd   format
        ///                                02031994   in ddmmyyyy   format
        ///                                02/03/1994 in dd_mm_yyyy format with separator '/'
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <param name="nullValue">value to return if null, normally DBNull.Value, 0, or ""</param>
        /// <param name="type">Type of int date (e.g. DDMMYYYY, DD_MM_YYYY, YYYYMMDD)</param>
        /// <param name="separator">separator char for DD_MM_YYYY</param>
        /// <returns>string field value (except if type is DD_MM_YYYY then string)</returns>
        protected internal object DateTimeToFieldStrDate(DateTime? value, object nullValue, DateType type, char separator)
        {
            if (value.HasValue)                
            {
                string date = DateTimeToFieldIntDate(value, nullValue, type, separator).ToString();
                return date.PadLeft(8, '0'); // Returned string should always have 8 chars
            }
            else
                return nullValue;
        }
        protected internal object DateTimeToFieldStrDate(DateTime? value, object nullValue, DateType type)
        {
            return DateTimeToFieldStrDate(value, nullValue, type, '/');
        }

        /// <summary>
        /// Converts a string time field to a timespan (from midnight)
        /// The string time field must store the date in format hhmmss
        /// Where hh - is the 2 digit hours (24 hour clock)
        ///       mm - is the 2 digit minutes
        ///       ss - is the 2 digit seconds
        ///      
        /// e.g. 142304 would be a timespan of 14 hours 23 minutes and 4 seconds
        /// </summary>
        /// <param name="field">string field to convert</param>
        /// <returns>timespan (from midnight) or null if field is empty</returns>
        public TimeSpan? FieldStrTimeToTimeSpan(object field)
        {
            try
            {
                if ((field == DBNull.Value) || (field.ToString().Trim() == string.Empty))
                    return null;
                else
                {
                    string value = field.ToString();
                    int hours = int.Parse(value.Substring(0, 2));
                    int mins  = int.Parse(value.Substring(2, 2));
                    int secs  = int.Parse(value.Substring(4, 2));
                    return new TimeSpan(hours, mins, secs);
                }
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Converts a timespan (from midnight) to a string time field, in the form hhmmss
        /// Where hh - is the 2 digit hours (24 hour clock)
        ///       mm - is the 2 digit minutes
        ///       ss - is the 2 digit seconds
        ///      
        /// e.g. 14 hours 23 minutes and 4 seconds would return "142304"
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <returns>value as a string time field or null if value is empty</returns>
        protected internal object TimeSpanToFieldStrTime(TimeSpan? value)
        {
            if (value.HasValue)
                return string.Format("{0:00}{1:00}{2:00}", value.Value.Hours, value.Value.Minutes, value.Value.Seconds);
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts a datetime to a string time field, in the form hhmmss
        /// the date part of the datetime is ignored
        /// Where hh - is the 2 digit hours (24 hour clock)
        ///       mm - is the 2 digit minutes
        ///       ss - is the 2 digit seconds
        ///      
        /// e.g. 2 March 1994 14:23:04 would return "142304" 
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <param name="nullAsBlankString">If returns null or empty string when value is null</param>
        /// <returns>value as a string time field</returns
        protected internal object DateTimeToFieldStrTime(DateTime? value, bool nullAsBlankString)
        {
            if (value.HasValue)
                return TimeSpanToFieldStrTime(value.Value.TimeOfDay);
            else if (nullAsBlankString)
                return string.Empty;
            else
                return DBNull.Value;
        }


        /// <summary>
        /// Converts an ID field to an enumerated type via a lookup table.
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// (see EnumViaDBLookupAttribute for details).
        /// </summary>
        /// <typeparam name="T">Enumerated type (that supports EnumViaDBLookup)</typeparam>
        /// <param name="field">db lookup table id</param>
        /// <returns>Enumerated type (or null)</returns>
        protected internal System.Nullable<T> FieldToEnumViaDBLookup<T>(object field) where T: struct
        {
            try
            {
                if (field == DBNull.Value)
                    return null;
                else
                    return EnumViaDBLookupAttribute.ToEnum<T>(Convert.ToInt32(field));
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }
        
        /// <summary>
        /// Converts an enumerated type to an ID field
        /// The enumerated type must support EnumViaDBLookupAttribute.
        /// (see EnumViaDBLookupAttribute for details).
        /// </summary>
        /// <typeparam name="T">Enumerated type (that supports EnumViaDBLookup)</typeparam>
        /// <param name="value">Enumerated vale to convert</param>
        /// <param name="addIfNotExists">Add the enum description table if it does not exists already exist 20Jan15 XN 26734</param>
        /// <returns>db lookup table id (or db null)</returns>
        protected internal object EnumToFieldViaDBLookup<T>(System.Nullable<T> value, bool addIfNotExists = false) where T: struct
        {
            if (value.HasValue )
                return EnumViaDBLookupAttribute.ToLookupID<T>(value.Value, addIfNotExists);
            else
                return DBNull.Value;
        }

        /// <summary>
        /// Converts a int field to an enumerated type, or default(T) if field is null.
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="field">field to convert</param>
        /// <returns>Enumerated type</returns>
        protected internal System.Nullable<T> FieldIntToEnum<T>(object field) where T: struct
        {
            try
            {
                if (field == DBNull.Value)
                    return null;
                else
                {
                    int intField = Convert.ToInt32(field);
                    Array array = Enum.GetValues(typeof(T));
                    return array.OfType<T>().FirstOrDefault(i => Convert.ToInt32(i) == intField);
                }
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }
        
        /// <summary>
        /// Converts an enumerated type to a db code int field
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="value">Enumerated vale to convert</param>
        /// <returns>db coded string</returns>
        protected internal object EnumToFieldInt<T>(System.Nullable<T> value) where T: struct
        {
            if (value == null)
                return DBNull.Value;
            else
                return Convert.ToInt32(value.Value);
        }

        /// <summary>
        /// Converts a string field to an enumerated type, or default(T) if field is null.
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="field">field to convert</param>
        /// <param name="ignoreCase">Ignore the case of the field</param>
        /// <returns>Enumerated type</returns>
        protected internal System.Nullable<T> FieldStrToEnum<T>(object field, bool ignoreCase) where T: struct
        {
            if (field == DBNull.Value)
                return null;
            else
            {
                try
                {
                    return (T)Enum.Parse(typeof(T), field.ToString(), ignoreCase);
                }
                catch (Exception)
                {
                    return null;
                }
            }
        }
        
        /// <summary>
        /// Converts an enumerated type to a db code string field
        /// </summary>
        /// <typeparam name="T">Enumerated type</typeparam>
        /// <param name="value">Enumerated vale to convert</param>
        /// <returns>db coded string</returns>
        protected internal object EnumToFieldStr<T>(System.Nullable<T> value) where T: struct
        {
            if (value == null)
                return DBNull.Value;
            else
                return value.ToString();
        }

        /// <summary>
        /// Converts a int field, to a string via a lookup table e.g.
        /// If reading in EpisodeType.EpisodeTypeID would used
        ///     string EpisodeTypeString = FieldIntToLookupString(RawRow["EpisodeType"], "EpisodeType", "EpisodeTypeID", "Description");
        /// If int value does not exist in table or is null, method returns null (note lookup table is cached in long term cache)
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <param name="lookupTableName">Lookup table name</param>
        /// <param name="pkColumnName">PK column name in lookup table</param>
        /// <param name="descriptionColumn">Test field column name in lookup table</param>
        /// <returns>Converted lookup string (or null)</returns>
        protected internal string FieldIntToLookupString(object field, string lookupTableName, string pkColumnName, string descriptionColumn)
        {
            try
            {
                if ((field == DBNull.Value) || (field.ToString().Trim() == string.Empty))
                    return null;

                // Get the lookup table
                Dictionary<string, int> PKToDBName = BaseRow.GetLookupTable(lookupTableName, pkColumnName, descriptionColumn);;

                // Convert
                int pk = Convert.ToInt32(field);
                if (PKToDBName.Any(i => i.Value == pk))
                    return PKToDBName.First(i => i.Value == pk).Key;
                else
                    return null;
            }
            catch (Exception ex)
            {                
                throw this.CreateFriendlyException(ex);
            }
        }

        /// <summary>
        /// Convert string field, to int lookup value (not case sensitive) e.g.
        /// If setting EpisodeType.EpisodeTypeID would used
        ///     episodeTypeID = LookupStringToFieldInt("Person", "EpisodeType", "EpisodeTypeID", "Description");
        /// If value does not exist in table  or is null, method returns DBNull (note lookup table is cached in long term cache)
        /// </summary>
        /// <param name="value">value to convert</param>
        /// <param name="lookupTableName">Lookup table name</param>
        /// <param name="pkColumnName">PK column name in lookup table</param>
        /// <param name="descriptionColumn">Test field column name in lookup table</param>
        /// <returns>Convert lookup string to field (or null)</returns>
        protected internal object LookupStringToFieldInt(string value, string lookupTableName, string pkColumnName, string descriptionColumn)
        {
            if (value == null)
                return DBNull.Value;

            // Get the lookup table
            Dictionary<string, int> PKToDBName = BaseRow.GetLookupTable(lookupTableName, pkColumnName, descriptionColumn);;

            // Convert
            value = value.TrimEnd();
            if (PKToDBName.Any(i => i.Key.EqualsNoCase(value)))
                return PKToDBName.First(i => i.Key.EqualsNoCase(value)).Value;
            else
                return DBNull.Value;
        }

        /// <summary>
        /// Converts a field to an Guid.
        /// </summary>
        /// <param name="field">Field to convert</param>
        /// <returns>Guid value, or null, if field is empty</returns>
        protected internal Guid? FieldToGuid(object field)
        {
            if (field != DBNull.Value)
                return (field as Guid?);
            else
                return null;
        }

        /// <summary>
        /// Converts an Guid to a field
        /// </summary>
        /// <param name="val">value to convert</param>
        /// <returns>field value</returns>
        protected internal object GuidToField(Guid? val)
        {
            if (val.HasValue)
                return val.Value;
            else
                return DBNull.Value;
        }
        #endregion

        #region Protected Methods
        /// <summary>
        /// Adds column to the DataTable if it does not already exist (default value will be null) does not effect the db.
        /// 18Apr16 XN 123082
        /// </summary>
        /// <param name="columnName">Name of column</param>
        /// <param name="type">.NET type of column</param>
        protected void AddColumnIfNotExists(string columnName, Type type)
        {
            if (!this.RawRow.Table.Columns.Contains(columnName))
            {
                var caseNumberColumn = this.RawRow.Table.Columns.Add(columnName, type);
                caseNumberColumn.DefaultValue = null;
            }
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// read in the data from a db lookup table using sp pPharmacyLookupTable.
        /// Returns a map of description (lower case), to pk value.
        /// </summary>
        /// <param name="tableName">>Name of table to load</param>
        /// <param name="pkcolumnName">pk column of the table</param>
        /// <param name="descriptionColumn">Description or text column to load from the database.</param>
        /// <returns>map of db tables description (lower case), to pk value</returns>
        private static Dictionary<string, int> GetLookupTable(string tableName, string pkcolumnName, string descriptionColumn)
        {
            string cacheName = string.Format("{0}.GetLookupTable[{1}]", typeof(EnumViaDBLookupAttribute).FullName, tableName);

            Dictionary<string, int> PKToDBName = (Dictionary<string, int>)PharmacyDataCache.GetFromCache(cacheName);

            Transport dblayer = new Transport();

            // Read the information from the database
            // Done directly against the Transport layer as this is in the shared modules and so can't access BaseTable directly.
            // The sp pPharmacyLookupTable return dataset of table "ID", and "Description" fields
            string parameters = string.Empty;
            parameters += dblayer.CreateInputParameterXML("TableName",            Transport.trnDataTypeEnum.trnDataTypeVarChar, tableName.Length,         tableName);       
            parameters += dblayer.CreateInputParameterXML("PKColumn",             Transport.trnDataTypeEnum.trnDataTypeVarChar, pkcolumnName.Length,      pkcolumnName);
            parameters += dblayer.CreateInputParameterXML("DescriptionColumn",    Transport.trnDataTypeEnum.trnDataTypeVarChar, descriptionColumn.Length, descriptionColumn);

            DataSet ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pPharmacyLookupTable", parameters);

            // Move the data to a sorted list (description is set to lower case).
            Dictionary<string, int> lookup = new Dictionary<string,int>();
            foreach(DataRow row in ds.Tables[0].Rows)
            {
                object ID           = row["ID"];
                object description  = row["Description"];

                if ((ID != DBNull.Value) && (description != DBNull.Value))
                    lookup.Add(description.ToString().TrimEnd(), Convert.ToInt32(ID));
            }

            return lookup;
        }

        /// <summary>
        /// Creates a new friendly ApplicationException error in form
        ///     Failed reading table [{TableName}] property {Method called BaseRow} where PK={Value} failed in method BaseRow.{method} 
        ///     Original error is:
        ///     {Error message}
        /// If there are any issues creating the error message, then the will return original error
        /// </summary>
        /// <param name="ex">Original error</param>
        /// <returns>ApplicationException with friendly error</returns>
        private Exception CreateFriendlyException(Exception ex)
        {
            StringBuilder msg = new StringBuilder();

            try
            {
                // Get the table name (should be same as DataSet table name
                // If table name is a predefined default (then can't give a more meaningful error so return the original)
                string tableName = this.RawRow.Table.TableName;
                if (string.IsNullOrWhiteSpace(tableName) || tableName.EqualsNoCase("Table") || tableName == "DeletedItemsTable" || tableName == "BaseTable2" || tableName == "BaseTable2_DeletedItems")
                {
                    return ex;
                }

                msg.AppendFormat("Failed reading table [{0}] ", tableName);

                // Use the stack to get a rough field name (if not enough items in stack then return original error)
                List<StackFrame> st = (new StackTrace()).GetFrames().ToList();
                int lastBaseRowEntry = st.FindLastIndex(s => s.GetMethod().DeclaringType.Name == "BaseRow");
                if (st.Count > lastBaseRowEntry + 1 && lastBaseRowEntry >= 0 && st[lastBaseRowEntry + 1].GetMethod().MemberType == MemberTypes.Field)
                {
                    msg.AppendFormat("property {0} ", st[lastBaseRowEntry + 1].GetMethod().Name.Replace("get_", string.Empty));
                }

                // Try to get the pk for the table
                if (tableName == "WProduct")
                {
                    // Special handling of WProduct as such an important view (and has no pk)
                    msg.AppendFormat("where NSVCode={0} and SiteID={1} ", this.RawRow["siscode"], this.RawRow["LocationID_Site"]);
                }
                else
                {
                    // Get PK value
                    if (this.RawRow.Table.PrimaryKey.Count() == 1)
                    {
                        string pkname = this.RawRow.Table.PrimaryKey[0].ColumnName;
                        object objValue = this.RawRow[pkname];
                        if (objValue != DBNull.Value && !(objValue is int || objValue is long) && (((long)objValue) >= 0))
                        {
                            msg.AppendFormat("where {0}={1} ", pkname, objValue);
                        }
                    }
                }

                // get the method that failed
                if (lastBaseRowEntry >= 0)
                {
                    msg.AppendFormat("failed in method {0}", st[lastBaseRowEntry].GetMethod().Name);
                }

                // Set the original value
                msg.AppendFormat("\nOriginal error is: {0}", ex.GetAllMessaages().ToCSVString("\n"));
            }
            catch (Exception)
            {
                // Return the original exception
                return ex;
            }

            return new ApplicationException(msg.ToString(), ex);
        }
        #endregion
    }
}
