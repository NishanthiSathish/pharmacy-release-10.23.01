//===========================================================================
//
//							   EncryptionAlgorithum.cs
//
//	Provides a number of pharmacy specific encryption\decryption algoritums.
//
//  Usage:
//  string encryptedString = EncryptionAlgorithms.EncodeHex("Hello");
//  EncryptionAlgorithms.DecodeHex(encryptedString);
//
//	Modification History:
//	21Jul09 XN  Written
//===========================================================================
using System;
using System.Globalization;
using System.Text;

namespace ascribe.pharmacy.shared
{
    public class EncryptionAlgorithms
    {
        private static Random rnd = new Random();   // Random numbder generator (used by encode hex)

        /// <summary>
        /// Decodes a string encoded using the EncodeHex or the vb6 CoreLib.decodehex.
        /// Blank or null string will be returned unchanged.
        /// 
        /// The decoded string will be a quarter the size of the encoded string.
        /// If the string passed in was not formatted using EncodeHex algorithum
        /// the returned string will contain gibberish, or be blank.
        /// 
        /// See EncodeHex for more information about the algorithum.
        /// </summary>
        /// <param name="stringToDecode">String to decode</param>
        /// <returns>Decoded string</returns>
        public static string DecodeHex (string stringToDecode)
        {
            if (string.IsNullOrEmpty(stringToDecode))
                return stringToDecode;

            StringBuilder decodedString = new StringBuilder();

            try
            {
                // the string represents the number in hex bytes
                // but with each decoded byte taking up 4 encoded character spaces
                for (int c = 0; c < stringToDecode.Length; c += 4)
                {
                    // extract 2 encoded bytes that make up a decoded byte
                    byte byte1 = byte.Parse(stringToDecode.Substring(c,     2), NumberStyles.HexNumber);
                    byte byte2 = byte.Parse(stringToDecode.Substring(c + 2, 2), NumberStyles.HexNumber);

                    byte1 = (byte)((byte1 << 1) & 0xAA);    // Extract even bits (00011010 << 1) AND 10101010 = 00100000
                    byte2 = (byte)(byte2 & 0x55);           // Extract odd  bits 01001011 AND 01010101 = 01000001

                    char letter = (char)(byte1 | byte2);    // or's even and odd bits together 00100000 | 01000001 = 01100001 ('a')

                    decodedString.Append(letter);   // Add decoded letter to the string
                }
            }
            catch (FormatException )
            {
            }

            return decodedString.ToString();
        }

        /// <summary>
        /// Encodes the string using the method from CoreLib.encodehex.
        /// The encryption method is as follow
        /// 1. Take each character in the string        (taking character 'a' Hex 61 01100001)
        /// 2. copy the character into two bytes        (becomes 00110000 and 01100001)
        ///    and shift one by right by a bit
        /// 3. extract odd bits from bytes effectivly   (becomes 00010000 and 01000001)
        ///    even and odd bits from orginal letter
        /// 4. Insert random values between the         (random bye values     00001010 and 00001010
        ///    even bits                                 or'ed to from step 2  00010000 and 01000001
        ///                                              produces              00011010     01001011)
        /// 5. These two bytes are then convert to      (00011010 and 01001011 becomes 1A4B)
        ///    hex and appended to the output string
        ///    
        /// Blank or null string will be returned unchanged.
        /// The encoded string will be four times the size of the original.
        /// </summary>
        /// <param name="stringToEncode">string to encode</param>
        /// <returns>decoded string</returns>
        public static string EncodeHex (string stringToEncode)
        {
            if (string.IsNullOrEmpty(stringToEncode))
                return stringToEncode;

            StringBuilder encodedString = new StringBuilder();

            // Stage 1 take each character from the string
            foreach(char letter in stringToEncode.ToCharArray())
            {
                // Stage 2 copy character to two bytes, and shift 1 right by 1 bit
                byte byte1 = (byte)(letter >> 1);
                byte byte2 = (byte)(letter &  0xFF);

                // Stage 3 and 4 extract the odd bits, insert random values in the even bits
                // Note 0x55 = 01010101 and 0xAA = 10101010
                byte1 = (byte)((byte1 & 0x55) | (rnd.Next(256) & 0xAA));
                byte2 = (byte)((byte2 & 0x55) | (rnd.Next(256) & 0xAA));

                // Stage 5 Convert to hex string and append.
                encodedString.AppendFormat("{0:X2}", byte1);
                encodedString.AppendFormat("{0:X2}", byte2);
            }

            return encodedString.ToString();
        }
    }
}
