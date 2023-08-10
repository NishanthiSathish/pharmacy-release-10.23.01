//===========================================================================
//
//							      Validation.cs
//
//  Provides a set of validation methods to be used with web controls.
//
//  Currently only support validating asp .net TextBoxes, but this can 
//  be improved by adding to GetControlValue
//
//  Usage:
//  To validate an asp .net input control
//  string error;
//  Validation.ValidateText(tbInput, "Some input", typeof(string), 50, true, out error)
//
//  the method will return if input is a valid string off less than 50, and is required.
//
//	Modification History:
//  20Oct11 XN  Written
//  23Apr13 XN  Extended class to work with ICW Controls 53147
//  15May13 XN  added ValidateDateTime (27038)
//  19Dec13 XN  78339 Improved ValidateText so can have greater than or less than 
//              options instread of just range
//  12Mar14 XN  Added test for int64 (for DM&D validation)
//  15Jul14 XN  Updated ValidateText to test for white space
//  21Jan15 XN  Update ValidateText and ValidateDateTime so make 'Please enter'
//              consistent with other error messages 108312
//  11Feb15 XN  Got GetControlValue to return RawValue for ICW controls else a '&' will be '&amp;' etc
//  18Jul16 XN  126634 Added ValidateBarcode
//===========================================================================
using System;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

namespace ascribe.pharmacy.shared
{
    public class Validation
    {
        /// <summary>
        /// WebControl class does not have a Text method. 
        /// So need to cast control to relavent parent class to get their text content
        /// </summary>
        /// <param name="control">Contorl to get text content for</param>
        /// <returns>Text content</returns>
        private static string GetControlValue(Control control)
        {
            if (control is TextBox)
                return (control as TextBox).Text;
            else if (control is HiddenField)
                return (control as HiddenField).Value;
            else if (control is Ascribe.Core.Controls.ShortText)
                return (control as Ascribe.Core.Controls.ShortText).RawValue;
            else if (control is Ascribe.Core.Controls.MediumText)
                return (control as Ascribe.Core.Controls.MediumText).RawValue;
            else if (control is Ascribe.Core.Controls.LongText)
                return (control as Ascribe.Core.Controls.LongText).RawValue;
            else if (control is Ascribe.Core.Controls.Number)
                return (control as Ascribe.Core.Controls.Number).Value == null ? string.Empty : (control as Ascribe.Core.Controls.Number).Value.ToString();
            else
                throw new ApplicationException("Pharmacy validation does not support WebControl type " + control.GetType().FullName);
        }

        /// <summary>
        /// Validate text in the control for
        ///     1. Can text be parsed to specified type
        ///     2. Control text is not blank (or white space) if required
        /// </summary>
        /// <param name="control">Web control value</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="type">Expected data type (e.g. typeof(string), typeof(int))</param>
        /// <param name="required">If user must enter value, or can it be blank</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If text is valid</returns>
        public static bool ValidateText(WebControl control, string controlName, Type type, bool required, out string error)
        {
            string value = GetControlValue(control);

            error = string.Empty;

            // Error if required
            if (required && string.IsNullOrWhiteSpace(value))
            {
                control.Focus();
                error = "Please enter " + controlName;
                return false;
            }

            // Type to parse it
            switch (type.Name.ToLower())
            {
                case "string":
                    break;

                case "float":
                    float tempFloat;
                    if (!float.TryParse(value, out tempFloat))
                        error = controlName + " must be a decimal value.";
                    break;

                case "double":
                    double tempDouble;
                    if (!double.TryParse(value, out tempDouble))
                        error = controlName + " must be a decimal value.";
                    break;

                case "decimal":
                    decimal tempDecimal;
                    if (!decimal.TryParse(value, out tempDecimal))
                        error = controlName + " must be a decimal value.";
                    break;

                case "int32":
                    int tempInt;
                    if (!int.TryParse(value, out tempInt))
                        error = controlName + " must be an integer value.";
                    break;

                case "int64":
                    long tempLng;
                    if (!long.TryParse(value, out tempLng))
                        error = controlName + " must be an integer value.";
                    break;

                case "uint32":
                    uint tempUInt;
                    if (!uint.TryParse(value, out tempUInt))
                        error = controlName + " must be an unsigned integer value.";
                    break;

                case "datetime":
                    DateTime tempDateTime;
                    if (!DateTime.TryParse(value, out tempDateTime))
                    {
                        error = string.Format("{0} must be a date time value in format {1}\n{2:33: }\n{3:33: }", controlName
                                                                                                                 , DateTimeFormatInfo.CurrentInfo.FullDateTimePattern
                                                                                                                 , DateTimeFormatInfo.CurrentInfo.ShortDatePattern + " " + DateTimeFormatInfo.CurrentInfo.ShortTimePattern
                                                                                                                 , DateTimeFormatInfo.CurrentInfo.LongDatePattern  + " " + DateTimeFormatInfo.CurrentInfo.LongTimePattern);
                    }
                    break;

                case "boolean":
                    bool tempBool;
                    if (!BoolExtensions.TryPharmacyParse(value, out tempBool))
                        error = controlName + " must be Y or N";
                    break;

                default:
                    error = string.Format("Invalid type {0}", type.Name);
                    throw new ApplicationException(error);
            }

            if (!string.IsNullOrWhiteSpace(value) && !string.IsNullOrEmpty(error))
            {
                control.Focus();
                return false;
            }

            return true;
        }

        /// <summary>
        /// Validate text in the control for
        ///     1. Can text be parsed to specified type
        ///     2. Control text is not blank (or white space) if required
        ///     3. Control text does not exceed maximum length
        /// </summary>
        /// <param name="control">Web control value</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="type">Expected data type (e.g. typeof(string), typeof(int))</param>
        /// <param name="required">If user must enter value, or can it be blank</param>
        /// <param name="maxLength">Maximum text length</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If text is valid</returns>
        public static bool ValidateText(WebControl control, string controlName, Type type, bool required, int maxLength, out string error)
        {
            string value = GetControlValue(control);

            error = string.Empty;

            // Error if required
            if (required && string.IsNullOrWhiteSpace(value))
            {
                //error = "Please enter " + controlName + " value"; 21Jan15 108312 remove value to make consistent with other error messages
                error = "Please enter " + controlName; 
                control.Focus();
                return false;
            }

            // Test it is correct length
            if ((value != null) && (value.Length > maxLength))
            {
                error = string.Format(controlName + " must be less than {0} characters", maxLength + 1);
                control.Focus();
                return false;
            }

            return true;
        }

        /// <summary>
        /// Validate BatchNumber in the control for
        ///     1. Control text is not blank (or white space) if required
        ///     2. Control text does not exceed maximum length
        ///     3. control text should be Alphanumeric
        ///     4. control text should not be duplicated
        /// </summary>
        public static bool ValidateBatchNumber(WebControl control, string controlName, bool required, out string error)
        {
            string value = GetControlValue(control);
            error = string.Empty;

            // Error if required
            if (required && string.IsNullOrWhiteSpace(value))
            {
                error = "Please enter " + controlName;
                control.Focus();
                return false;
            }           

            //AlphaNumeric Check          
            Regex r = new Regex("^[a-zA-Z0-9]*$");
            if (!r.IsMatch(value))
            {
                error = string.Format(" Special character or WhiteSpace not allowed");
                control.Focus();
                return false;
            }

            // Test Duplicate BatchNumber
            int? QueryCnt = Database.ExecuteSQLScalar<int?>("SELECT Count(*) FROM AMMSupplyRequest WHERE BatchNumber='{0}'", value);
            if (QueryCnt > 0)
            {
                error = string.Format(controlName + " already exist");
                control.Focus();
                return false;
            }

            return true;
        }


        /// <summary>
        /// Validate text in the control for
        ///     1. Can text be parsed to specified type
        ///     2. Control text is not blank if required
        ///     3. Control text is a number within the specified range
        /// </summary>
        /// <param name="control">Web control value</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="type">Expected data type but should be number (e.g. typeof(int), typeof(double))</param>
        /// <param name="required">If user must enter value, or can it be blank</param>
        /// <param name="min">Minimum allowed value</param>
        /// <param name="max">Maximum allowed value</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If text is valid</returns>
        public static bool ValidateText(WebControl control, string controlName, Type type, bool required, double min, double max, out string error)
        {
            string value = GetControlValue(control);

            error = string.Empty;

            // Check the value is in range
            if (!string.IsNullOrEmpty(value))
            {
                double valueDouble;
                if (double.TryParse(value, out valueDouble) && ((valueDouble < min) || (valueDouble > max)))
                {
                    // 19Dec13 XN 78339 Add greater than and less than checks rather than just range
                    if (max == Double.MaxValue && valueDouble < min)
                        error = string.Format("{0} must be greater than {1}", controlName, min);
                    else if (min == Double.MinValue && valueDouble > max)
                        error = string.Format("{0} must be less than {1}", controlName, max);
                    else
                        error = string.Format("{0} must be in the range {1} to {2}", controlName, min, max);
                    control.Focus();
                    return false;
                }
            }

            // Do standard validation
            if (!ValidateText(control, controlName, type, required, out error))
                return false;

            return true;
        }

        /// <summary>Validate if item is selected in a icw list. 53147 XN 23Apr13</summary>
        /// <param name="control">Control to validate</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="required">If user must select an item</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If item selected</returns>
        public static bool ValidateList(Ascribe.Core.Controls.List control, string controlName, bool required, out string error)
        {
            error = string.Empty;

            // Error if required
            if (required && ((control.SelectedIndex == -1) || string.IsNullOrEmpty(control.SelectedValue)))
            {
                error = string.Format("Please select " + controlName + " item");
                control.Focus();
                return false;
            }

            return true;
        }

        /// <summary>
        /// Validate if item is selected in a drop down list.
        /// </summary>
        /// <param name="control">Control to validate</param>
        /// <param name="required">If user must select an item</param>
        /// <returns>If item selected</returns>
        public static bool ValidateDropDownList(DropDownList control, string controlName, bool required, out string error)
        {
            error = string.Empty;

            // Error if required
            if (required && ((control.SelectedIndex == -1) || string.IsNullOrEmpty(control.SelectedValue)))
            {
                error = "Please select " + controlName + " item";
                control.Focus();
                return false;
            }

            return true;
        }

        /// <summary>Validated ICW date time control</summary>
        /// <param name="control">Web control value</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="required">If user must enter value, or can it be blank</param>
        /// <param name="min">Minimum allowed value</param>
        /// <param name="max">Maximum allowed value</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If valid</returns>
        public static bool ValidateDateTime(Ascribe.Core.Controls.DateTime control, string controlName, bool required, DateTime? min, DateTime? max, out string error)
        {
            error = string.Empty;

            // Error if required
            if (required && control.Value == null)
            {
                //error = "Please enter " + controlName + " item";  21Jan15 108312 remove value to make consistent with other error messages
                error = "Please enter " + controlName;
                control.Focus();
                return false;
            }

            // Check the value is in range
            if (control.Value != null)
            {
                DateTime value = control.Value.Value;
                if ((min != null && value < min) || (max != null && value > max))
                {
                    string minStr, maxStr;
                    switch (control.Mode)
                    {
                    case Ascribe.Core.Controls.DateTimeMode.Date:
                        minStr = min.ToPharmacyDateString();
                        maxStr = max.ToPharmacyDateString();
                        break;
                    case Ascribe.Core.Controls.DateTimeMode.Time:
                        minStr = min.ToPharmacyTimeString();
                        maxStr = max.ToPharmacyTimeString();
                        break;
                    default:
                        minStr = min.ToPharmacyDateTimeString();
                        maxStr = max.ToPharmacyDateTimeString();
                        break;
                    }

                    error = string.Format("{0} must be in the range {1} to {2}", controlName, minStr, maxStr);
                    control.Focus();
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Validate text in the control for
        ///     1. Can check barcode is an EAN-13 EAN-8 or GTIN barcode
        ///     2. Control text is not blank (or white space) if required
        /// 15Jul16 126634
        /// </summary>
        /// <param name="control">Web control value</param>
        /// <param name="controlName">Control friendly name added to error message</param>
        /// <param name="required">If user must enter value, or can it be blank</param>
        /// <param name="error">Error message created by validation</param>
        /// <returns>If text is valid</returns>
        public static bool ValidateBarcode(WebControl control, string controlName, bool required, out string error)
        {
            string value = GetControlValue(control);

            error = string.Empty;

            // Error if required
            if (required && string.IsNullOrWhiteSpace(value))
            {
                //error = "Please enter " + controlName + " value"; 21Jan15 108312 remove value to make consistent with other error messages
                error = "Please enter " + controlName; 
                control.Focus();
                return false;
            }

            // Test it is correct length
            string gtin, batchNumber, tempError;
            DateTime? expiryDate;
            if (value != null && !Barcode.ReadBarcode(value, out gtin, out expiryDate, out batchNumber, out tempError))
            {
                error = controlName + " " + tempError;
                control.Focus();
                return false;
            }

            return true;
        }
    }
}
