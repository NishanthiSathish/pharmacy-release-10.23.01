//===========================================================================
//
//							Cryptography.cs
//
//  This class holds all business logic for handling cryptography
//
//	Modification History:
//	31Aug12 AJK  Written
//  25Sep12 CKJ  Changed to Windows codepage 1252 to allow full ASCII charset (TFS44486)
//  04Oct12 CKJ  Brought comments up to date & removed the unused 'usings'    (TFS44486)
//===========================================================================

using System;
//using System.Collections.Generic;
//using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.IO;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Cryptography class for pharmacy encryption methods
    /// </summary>
    public class Cryptography
    {
        private string _key = string.Empty; // 31Aug12 AJK 36826 Encrypted key
        private string _token = string.Empty; // 31Aug12 AJK 36826 Single use token
        private int _sessionID = 0; // 31Aug12 AJK 36826 SessionID

        private const string CSPNAME = "Microsoft Base Cryptographic Provider v1.0";

        /// <summary>
        /// Gets a random 16 byte array of characters 
        /// </summary>
        /// <returns>A byte array of 16 random characters</returns>
        private byte[] GetRandom16ByteArray()
        {
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            byte[] data = new byte[16];
            rng.GetNonZeroBytes(data);
            return data;
        }

        /// <summary>
        /// Converts a byte array to a hexadecimal string
        /// </summary>
        /// <param name="data">Byte array of data to be converted</param>
        /// <returns>Hexadecimal string</returns>
        public string ByteArrayToHexString(byte[] data)
        {
            StringBuilder ret = new StringBuilder();
            foreach (byte letter in data)
            {
                string hexOutput = string.Format("{0:x2}", letter);
                ret.Append(hexOutput);
            }
            return ret.ToString();
        }

        /// <summary>
        /// Converts a hexadecimal string into a byte array
        /// </summary>
        /// <param name="data">Hexadecimal string to be converted</param>
        /// <returns>Converted byte array</returns>
        public byte[] HexStringToByteArray(string data)
        {
            byte[] ret = new byte[data.Length / 2];
            for (int i = 0; i < data.Length; i += 2)
            {
                int value = Convert.ToInt32(data.Substring(i, 2), 16);
                ret[i / 2] = Convert.ToByte(value);
            }
            return ret;
        }

        /// <summary>
        /// Converts a string into a byte array using codepage 1252 (Windows) encoding
        /// </summary>
        /// <param name="str">String to be converted</param>
        /// <returns>Converted byte array</returns>
        private byte[] GetBytes(string str)
        {
            byte[] ret = Encoding.GetEncoding(1252).GetBytes(str);    //25Sep12 CKJ changed UTF8 to iso-8859-1, then to Windows codepage 1252 (TFS44486)
            return ret;
        }

        /// <summary>
        /// Converts a byte array into a string using codepage 1252 (Windows) encoding
        /// </summary>
        /// <param name="bytes">Byte array to convert</param>
        /// <returns>Coonverted string</returns>
        private string GetString(byte[] bytes)
        {
            //byte[] buf = Encoding.Convert( Encoding.GetEncoding("iso-8859-1"),  Encoding.UTF8, bytes);    //25Sep12 CKJ changed UTF8 to iso-8859-1 (TFS44486)
            //string nret = Encoding.UTF8.GetString(buf);                                                   //   "        as all chars over 127 were failing
            string nret = Encoding.GetEncoding(1252).GetString(bytes);                                      //   "        Now changed to Windows codepage 1252

            string ret = string.Empty;
            int nullPos = nret.IndexOf("\0");
            if (nullPos == -1)
            {
                ret = nret;
            }
            else
            {
                ret = nret.Substring(0, nullPos);
            }
            return ret;
        }

        /// <summary>
        /// Encrypt a string into a hexadecimal string
        /// </summary>
        /// <param name="input">String data to convert and encrypt</param>
        /// <param name="hexSalt">Salt to be used for encryption</param>
        /// <returns>Encrypted hexadecimal string</returns>
        public string EncryptAndHex(string input, out string hexSalt)
        {
            byte[] toEncrypt;
            byte[] encrypted;
            CspParameters parms = new CspParameters(1, CSPNAME);
            RC2CryptoServiceProvider rc2CSP = new RC2CryptoServiceProvider();
            byte[] salt = GetRandom16ByteArray();
            byte[] x2 = GetBytes(_key);
            byte[] p = CombineByteArrays(x2, salt);
            PasswordDeriveBytes pdb = new PasswordDeriveBytes(p, null, "SHA-1", 1, parms);
            byte[] IV = new byte[8];
            byte[] key = pdb.CryptDeriveKey("RC2", "SHA1", 0, IV);
            ICryptoTransform encryptor = rc2CSP.CreateEncryptor(key, IV);
            MemoryStream msEncrypt = new MemoryStream();
            CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write);
            toEncrypt = GetBytes(input);
            csEncrypt.Write(toEncrypt, 0, toEncrypt.Length);
            csEncrypt.FlushFinalBlock();
            encrypted = msEncrypt.ToArray();
            hexSalt = ByteArrayToHexString(salt);
            return ByteArrayToHexString(encrypted);
        }

        /// <summary>
        /// Combines two byte arrays into a single array
        /// </summary>
        /// <param name="first">First byte array to combine</param>
        /// <param name="second">Second byte array to combine</param>
        /// <returns>Combined byte array</returns>
        private byte[] CombineByteArrays(byte[] first, byte[] second)
        {
            byte[] ret = new byte[first.Length + second.Length];
            System.Buffer.BlockCopy(first, 0, ret, 0, first.Length);
            System.Buffer.BlockCopy(second, 0, ret, first.Length, second.Length);
            return ret;
        }

        /// <summary>
        /// Converts an encrpyted hexadecimal string into it's unencrypted string. Null character string terminations may cause problems.
        /// </summary>
        /// <param name="input">Encrpyted hexadecimal string to convert</param>
        /// <param name="hexSalt">Salt to be used for decryption</param>
        /// <returns>Unencrypted data</returns>
        public string DehexAndDecrypt(string input, string hexSalt)
        {
            byte[] encrypted;
            byte[] fromEncrypt;
            RC2CryptoServiceProvider rc2CSP = new RC2CryptoServiceProvider();
            CspParameters parms = new CspParameters(1, CSPNAME);
            byte[] salt = HexStringToByteArray(hexSalt);
            byte[] x2 = GetBytes(_key.ToString());
            byte[] p = CombineByteArrays(x2, salt);
            PasswordDeriveBytes pdb = new PasswordDeriveBytes(p, null, "SHA-1", 1, parms);
            byte[] IV = new byte[8];
            byte[] key = pdb.CryptDeriveKey("RC2", "SHA1", 0, IV);
            ICryptoTransform decryptor = rc2CSP.CreateDecryptor(key, IV);
            encrypted = HexStringToByteArray(input);
            MemoryStream msDecrypt = new MemoryStream(encrypted);
            CryptoStream csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read);
            fromEncrypt = new byte[encrypted.Length];
            csDecrypt.Read(fromEncrypt, 0, fromEncrypt.Length);
            return GetString(fromEncrypt);
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="token">Single use token to be used to seed encryption</param>
        /// <param name="sessionID">SessionID for the encryption process</param>
        public Cryptography(string token, int sessionID)
        {
            _token = token;
            _sessionID = sessionID;
            DeriveKey();
        }

        /// <summary>
        /// Derives and stores the key for the session
        /// </summary>
        private void DeriveKey()
        {
            using (PharmacyActiveDataConnectionsProcessor proc = new PharmacyActiveDataConnectionsProcessor())
            {
                PharmacyActiveDataConnectionsLine conn = proc.LoadBySessionIDAndURLToken(_sessionID, _token);
                _key = conn.Key;
            }
        }
    }
}
