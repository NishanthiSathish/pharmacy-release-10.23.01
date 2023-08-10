using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;

namespace UT_Pharmacy_Data_Layer
{
    class Utils
    {
        private static Random rnd = new Random();

        public static void AssertAreEqual(BaseRow expected, BaseRow actual)
        {
            string[] excludedDBColumns = { "_TableVersion", "SessionLock" };
 
            foreach (DataColumn col in expected.RawRow.Table.Columns)
            {
                string colName = col.ColumnName;
                if (!excludedDBColumns.Contains(colName))
                    Assert.AreEqual(expected.RawRow[colName].ToString(), actual.RawRow[colName].ToString(), string.Format("DB Column [{0}]", colName));
            }
        }

        public static T RndNum<T>(double min, double max) where T: struct
        {
            string type = typeof(T).Name;

            switch (type.ToLower())
            {
            case "decimal":
            case "double":
            case "float":
            case "int64":
                return (T)Convert.ChangeType(Math.Round(((rnd.NextDouble() * (max - min)) + min), 5), typeof(T));
            case "int32":
            case "int16":
                return (T)(object)rnd.Next((int)min, (int)max);
            default:
                throw new ApplicationException("Unsupported type " + type);
            }
        }

        public static string RndStr(int length)
        {
            StringBuilder val = new StringBuilder();
            while (val.Length < length)
                val.Append((char)rnd.Next((int)'0', (int)'z'));
            return val.ToString();
        }

        public static DateTime RndDateTime()
        {
            int y = rnd.Next(1980, 2014);
            int m = rnd.Next(1, 12);
            int d = rnd.Next(1, 25);
            int h = rnd.Next(1, 24);
            int M = rnd.Next(1, 59);
            return new DateTime(y, m, d, h, M, 0);
        }

        public static bool RndBool()
        {
            return rnd.Next(0, 1) == 1;
        }

        public static T RndEnum<T>() where T: struct
        {
            if (!typeof(T).IsEnum)
                throw new ApplicationException("Type given must be an Enum");            
            var values = Enum.GetValues(typeof(T));
            return (T)(object)values.GetValue( rnd.Next(0, values.Length) );
        }
    }
}
