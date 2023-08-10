//===========================================================================
//
//							  Barcode.cs
//
//  Provides barcode helper functions.
//
//  Replacement for vb6 methods in EAN.bas
//
//  Usage
//  Create 13 digit barcode from NSVCode
//  string newBarcode = Barcode.GenerateEANDrugBarcode("DUX497Q")
//
//  Given the first 7 of 8, 11 of 12, 12 of 13 or 13 of 14 digits of the barcode calculate the EAN/GTIN Check digit 
//  string CheckDigit = Barcode.CalcGTINCheckDigit(barcode.SubString(0, 12))
//  
//	Modification History:
//	19Dec13 XN  Written
//  01Jul15 XN  Added Barcode.ShortBarcodeLength 39882
//  15Jul15 XN  Added CalcGTINCheckDigit and Read2DBarcode 39882
//  18Jul16 XN  126634 Added EdiBarcode
//  22Jan18 DC  Amended Barcode length to 14
//  15Feb18 DC  Complete revamp
//===========================================================================
namespace ascribe.pharmacy.shared
{
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

    /// <summary>Provides barcode helper methods</summary>
    public static class Barcode
    {
        // See https://www.gs1.org/barcodes/ean-upc for details on EAN barcodes
        // See https://www.gtin.info/ for details on GTIN code (and their use as barcodes)

        // This class will validate  GTIN-8, GTIN-12, GTIN-13 and GTIN-14 classes of barcodes
        // which covers EAN-8/UCC-8, UPC-12/UPC-A/UPC-E, EAN-13/UCC-13 and GTIN-14 respectively
        // consequently all constant/variable/method names refer to GTIN 
        // Note GTIN-14 is often referred to simply as GTIN
        // A shorter (that 14) GTIN can be converted to a longer one by left padding with zeros

        // Its expected that every code passed to be validated includes the check digit therefore
        // consequently if we are given a 13 digit number we assume its a GTIN-13 rather than a GTIN-14 with a missing digit

        public enum BarcodeType {EAN, GTIN};

        public const int GTIN14BarcodeLength = 14;
        public const int GTIN13BarcodeLength = 13;
        public const int GTIN12BarcodeLength = 12;
        public const int GTIN8BarcodeLength = 8;

        public const int EAN13BarcodeLength = GTIN13BarcodeLength;
        public const int EAN12BarcodeLength = GTIN12BarcodeLength;
        public const int EAN8BarcodeLength = GTIN8BarcodeLength;

        // GTIN Code "startswith" constants aka AICode
        public const String GTIN14Prefix = "01";
        public const String GTINBatchNumberPrefix = "10";
        public const String GTINExpirationDataPrefix = "17";

        public static readonly int[] ValidEANLengths = 
        {
            EAN8BarcodeLength,
            EAN12BarcodeLength,
            EAN13BarcodeLength
        };

        public static readonly int[] ValidGTINLengths = 
        {
            GTIN8BarcodeLength,
            GTIN12BarcodeLength,
            GTIN13BarcodeLength,
            GTIN14BarcodeLength
        };

        #region Private Data Types
        /// <summary>GS1 field type (fixed or variable) length field</summary>
        private enum GS1FieldType
        {
            /// <summary>GS1 field is variable length field</summary>
            [EnumDBCode("V")]
            Variable,

            /// <summary>GS1 field is fixed length field</summary>
            [EnumDBCode("F")]
            Fixed,
        }

        /// <summary>Holds information need to decode GS1 data field</summary>
        private struct GS1DataField
        {
            /// <summary>Application Identifier code</summary>
            public string AICode;

            /// <summary>Data field length type (fixed or variable)</summary>
            public GS1FieldType FieldLengthType;

            /// <summary>Data field length (or max length for variable)</summary>
            public int FieldLength;
        }

        private const String _errorMsg = "Invalid GTIN code";
        private const String _barcodeLengthErrorMsg = _errorMsg + ": code must be 8, 12, 13 or 14 characters long";
        #endregion

        public const int NSVCodeLength = 7;

        /// <summary>
        /// Given an NSV Code will generate a barcode
        /// Converts NSVCode alphas to int, and numbers to in
        /// appends these to a long string padded right with 0 (up to 12 char)
        /// then adds the EAN/GTIN check digit to the end
        /// Returns empty string is NSVCode is not valid
        /// </summary>
        /// <returns>Barcode for NSV Code</returns>
        public static string GenerateEANDrugBarcode(string NSVCode)
        {
            // Check NSV Code is valid
            if (string.IsNullOrEmpty(NSVCode) || NSVCode.Length < NSVCodeLength)
                return string.Empty;

            // Conver to barcode
            StringBuilder barcode = new StringBuilder();
            foreach(char c in NSVCode)
            {
                if (Char.IsDigit(c))
                    barcode.Append(c);
                else 
                    barcode.Append((int)c);
            }

            // Pad with 0, and truncate to 12 chars
            string returnVal = barcode.ToString()
                .PadRight(EAN13BarcodeLength - 1, '0')
                .SafeSubstring(0, EAN13BarcodeLength - 1);

            // Check EAN check digit
            return returnVal + CalculateGTINCheckDigit(returnVal);
        }

        /// <summary>
        /// Caclulates the EAN/GTIN check digit, method is the same for both EAN and GTIN
        /// Barcode can be 7, 11, 12 or 13 characters corresponding to EAN/GTIN 8,12,13 or 14 respectively
        /// see http://www.gs1.org/how-calculate-check-digit-manually
        /// returns calculated checkdigit or EmptyStr if the data was blank or not all digits
        /// </summary>
        /// <returns>Check digit</returns>
        public static string CalculateGTINCheckDigit(string barcodeData)
        {
            string checkDigitStr = "";
            
            if (barcodeData.All(b => Char.IsDigit(b)))
            {
                int barcodeLength = barcodeData.Length;

                if (ValidGTINLengths.Any(len => len == barcodeLength + 1))
                {
                    // Multiply each digit by a weight according to its position in the number
                    // For some barcode backwards compatability reason the 1st digit in a 12 digit number is considered even!!!
                    int checkDigit = 0;
                    int oddWeight = (barcodeLength + 1 == EAN13BarcodeLength) ? 1 : 3;
                    int evenWeight = (barcodeLength + 1 == EAN13BarcodeLength) ? 3 : 1;

                    int[] values = Array.ConvertAll(barcodeData.ToCharArray(), c => (int)Char.GetNumericValue(c));

                    for (int i = 0; i < barcodeLength; i++)
                    {
                        checkDigit += (values[i] * (i % 2 == 0 ? oddWeight : evenWeight));
                    }

                    checkDigit = (10 - checkDigit % 10) % 10;

                    checkDigitStr = checkDigit.ToString().Trim();
                }
            }

            return checkDigitStr;
        }

        public static bool ValidateGTINBarcode(String barcodeData, bool checkCheckdigit, out String errorMsg)
        {
            bool result = true;
            int barcodeLength = barcodeData.Length;

            errorMsg = string.Empty;

            if (ValidGTINLengths.Any(len => len == barcodeLength))
            {
                String checkdigit = CalculateGTINCheckDigit(barcodeData.Substring(0, barcodeLength - 1));

                // if result is null/empty then the barcodeData was blank or not all digits
                // otherwise compare check digits but only if required - users may want ability to enter dummy data :-(
                if (string.IsNullOrEmpty(checkdigit) || (checkCheckdigit && !barcodeData.EndsWith(checkdigit)))
                {
                    if (checkCheckdigit && !barcodeData.EndsWith(checkdigit))
                    {
                        errorMsg = _errorMsg + ": Check digit invalid";
                    }
                    else
                        errorMsg = _errorMsg;
                    result = false;
                }
            }
            else if (barcodeLength > 0 && barcodeLength < GTIN14BarcodeLength)
            {
                errorMsg = _barcodeLengthErrorMsg;
                result = false;
            }

            return result;
        }
        /// <summary>
        /// Reads and validates a GS1 2D barcode
        /// If the barcode happens to be a EAN-13 or EAN-8 will just set the gtin value and return true
        /// The method uses settings
        /// Character returned by scanner for the FNC1 control char (used to indicate end of variable length fields)
        /// Category: D|Barcode
        /// Section: 2D
        /// Keys: FNC1Character
        ///  
        /// Category: D|Barcode
        /// Section: 2D
        /// Keys: AICodes
        /// This setting stores the GS1 application identifier codes with data length info in format
        ///     {AI code 1}:{length type V-variable, F-fixed}:length,{AI code 2}:{length type V-variable, F-fixed}:length...
        /// e.g. gtin field is 01:F:14
        ///      expiry date is 17:F:6
        ///      batch number is 10:V:20
        /// 15Jul15 XN 39882
        /// </summary>
        /// <param name="barcode">Barcode to read</param>
        /// <param name="gtin">gtin read from barcode</param>
        /// <param name="expiryDate">Expiry date from barcode (null if not present)</param>
        /// <param name="batchNumber">Batch number from barcode (null if not present)</param>
        /// <param name="error">Error message if return value is false</param>
        /// <returns>if barcode is valid</returns>
        public static bool ReadBarcode(string barcodeData, out string gtinCode, out DateTime? expiryDate, out string batchNumber, out string errorMsg)
        {
            bool result = true;

            int barcodeLength = String.IsNullOrWhiteSpace(barcodeData) ? 0 : barcodeData.Length;

            gtinCode    = null;
            expiryDate  = null;
            batchNumber = null;
            errorMsg    = string.Empty;

            bool checkGTINCheckDigit = Database.GetWConfigurationValue(null, "D|Barcode", "2D", "TestGTINCheckDigit", true);

            if (barcodeLength <= GTIN14BarcodeLength)
            {
                result = ValidateGTINBarcode(barcodeData, checkGTINCheckDigit, out errorMsg);
                if (result)
                    gtinCode = barcodeData;
            }
            else
            {
                List<GS1DataField> GS1Codes = new List<GS1DataField>();

                // Get a list of GTIN barcode formats from Config
                // see Page 133 of GS1 Barcode specification for more info
                string[] aicodes =
                    Database.GetWConfigurationValue(null, "D|Barcode", "2D", "AICodes", string.Empty).Split(',');
                // eg aicodestr = "00:F:18,01:F:14,02:F:14,10:V:20,.....410:F:13,420:V:20,422:F:3,91:F:20"

                string separator = 
                    Database.GetWConfigurationValue(null, "D|Barcode", "2D", "FNC1Character", string.Empty);
                // eg separator = "]1d"
                int separatorLength = separator.Length;

                bool stripLeadingZeros = 
                    Database.GetWConfigurationValue(null, "D|Barcode", "2D", "CollapseBarcodesWithLeadingZeros", true);

                foreach (var code in aicodes)
                {
                    try
                    {
                        string[] info = code.Split(':');
                        GS1Codes.Add(
                            new GS1DataField()
                                {
                                    AICode = info[0],
                                    FieldLengthType = EnumDBCodeAttribute.DBCodeToEnum<GS1FieldType>(info[1]),
                                    FieldLength = int.Parse(info[2])
                                });
                    }
                    catch (Exception)
                    {
                    } // Dont like this, we should really report it
                }

                int startPos = 0;
                int endPos = barcodeData.Length;

                while (startPos < endPos)
                {
                    String part = barcodeData.Substring(startPos);

                    GS1DataField GS1Code = GS1Codes.FirstOrDefault(gs => part.StartsWith(gs.AICode));

                    if (GS1Code.AICode == null)
                    {
                        errorMsg = _errorMsg;
                        result = false;
                        break;
                    }

                    String data = string.Empty;

                    if (GS1Code.FieldLengthType == GS1FieldType.Fixed)
                    {
                        data = barcodeData.SafeSubstring(startPos + GS1Code.AICode.Length, GS1Code.FieldLength);
                        startPos += GS1Code.AICode.Length + GS1Code.FieldLength;
                    }
                    else
                    {
                        // GS1FieldType.Variable
                        int sepPos = barcodeData.IndexOf(separator, startPos);
                        int datalength = sepPos > 0 ? sepPos - startPos - GS1Code.AICode.Length : GS1Code.FieldLength;

                        data = barcodeData.SafeSubstring(startPos + GS1Code.AICode.Length, datalength);
                        startPos += GS1Code.AICode.Length + datalength + (sepPos > 0 ? separatorLength : 0);

                        if (data.Length > GS1Code.FieldLength)
                        {
                            errorMsg = _errorMsg;
                            result = false;
                            break;
                        }
                    }

                    // Get important barcode data
                    switch (GS1Code.AICode)
                    {
                        case GTIN14Prefix: // GTIN14
                            {
                                result = ValidateGTINBarcode(data, checkGTINCheckDigit, out errorMsg);
                                if (result)
                                {
                                    gtinCode = stripLeadingZeros ? data.TrimStart('0') : data;
                                }
                                else
                                    errorMsg = _errorMsg;
                                break;
                            }

                        case GTINBatchNumberPrefix: // Batch number
                            batchNumber = data;
                            break;

                        case GTINExpirationDataPrefix: // Expiry date
                            try
                            {
                                // Extract parts of date
                                int yy = int.Parse(data.Substring(0, 2));
                                int mm = int.Parse(data.Substring(2, 2));
                                int dd = data.Length > 4 ? int.Parse(data.Substring(4, 2)) : 0;

                                // year wraps around on 50 year sliding window
                                yy = ((yy + 2000) > (DateTime.Now.Year + 50)) ? yy + 1900 : yy + 2000;

                                // if day is 0 then it is last day of month
                                if (dd == 0)
                                {
                                    dd = DateTime.DaysInMonth(yy, mm);
                                }

                                expiryDate = new DateTime(yy, mm, dd);
                            }
                            catch (Exception)
                            {
                                expiryDate = null;
                                errorMsg = "Invalid expiry date";
                                result = false;
                            }
                            break;
                    }

                    if (!result) break;
                }
            }

            return result;
        }

        /// <summary>
        /// Returns the barcode from the input parameter
        /// If input parameter is a 1D EAN-13, EAN-12, EAN-8 or GTIN-14 it will just return the input parameter
        /// If input parameter is a GS1 2D barcode will return the GTIN part of the barcode
        /// </summary>
        /// <param name="barcode">Barcode to read</param>
        /// <returns>returns the barcode or empty string</returns>
        public static string ReadBarcode(string barcodeData)
        {
            String barcode;
            DateTime? expiryDate;
            String batchNumber;
            String error;

            ReadBarcode(barcodeData, out barcode, out expiryDate, out batchNumber, out error);

            return barcode;
        }
    }
}
