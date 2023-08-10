//===========================================================================
//
//							        PNUtils.cs
//
//  General helper functions, and data types, used by PNUtils
//
//	Modification History:
//	15Nov11 XN Written
//  18Nov11 XN Added PNRegimenMode.ViewReadOnly
//  25Nov15 XN Allow adding a product from a DSS request 38321
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public struct PNViewAndAdjustInfo
    {
        public int          requestID_Prescription;
        public double       dosingWeightInKg;
        public AgeRangeType ageRange;
    }

    public enum PNRegimenStatus
    {
        Edited,
        Saved,
        Viewing,
        Authorised,
        Cancelled
    }

    public enum PNRegimenMode
    {
        Add,
        View,

        /// <summary>can view but not edit the regime 18Nov15 XN 133905</summary>
        ViewReadOnly,
        Copy
    }

    public enum PNBrokenRuleType
    {
        Critical,
        Warning,
        Info
    }

    public struct PNBrokenRule
    {
        public int?             RuleNumber;
        public PNBrokenRuleType Type;
        public string           Description;
        public string           Explanation;

        public PNBrokenRule(int? ruleNumber, PNBrokenRuleType type, string description, string explanation)
        {
            this.RuleNumber = ruleNumber;
            this.Type       = type;
            this.Description= description;
            this.Explanation= explanation;
        }
    }

    public struct WeightAgeInfo
    {
        public int age;
        public GenderType Gender;
        public double WeightHeight;
        public double WeightMidpoint;
        public double WeightLow;
    }

    /// <summary>General helper functions, and data types, used by PNUtils</summary>
    public static class PNUtils
    {
        /// <summary>ICW policies used by PN</summary>
        public static class Policy
        {
            public const string Viewer     = "Parenteral Nutrition - Viewer";
            public const string Authoriser = "Parenteral Nutrition - Authoriser";
            public const string Editor     = "Parenteral Nutrition - Editor";
        }

        /// <summary>PN wizard type</summary>
        public enum PNWizardType
        {
            /// <summary>Add product but user needs to select units to use</summary>
            byProduct,

            /// <summary>Add product using volume in ml</summary>
            bymlProduct,

            /// <summary>Add product by selecting an ingredient</summary>
            byIngredient,

            /// <summary>Replace product</summary>
            replace,

            /// <summary>Set calories or volume</summary>
            setCaloriesOrVolume,

            /// <summary>Adjust overage</summary>
            overage,

            /// <summary>Standard Regimen</summary>
            standardRegimen,
        }

        /// <summary>PN wizard data type entry mode</summary>
        public enum mmolEntryType
        {
            Total,
            PerKg,
        }

        /// <summary>
        /// Taken from V8 code (sub agecalc) to calculates different between dates to years (including fraction)
        /// 
        /// Starting from .day .month .year for d1 and d2  
        /// (these being the date in question and, usually but not necessarily, today) 
        /// then find the number of spare days. 
        /// This is the number of days to the end of the month (inc first day) plus number in last month (excluding last day). 
        /// If total exceeds number of days in first month then decrement accordingly & inc month total.
        /// The process continues for the months & years.
        /// </summary>
        public static double YearsDifference(DateTime d1, DateTime d2)
        {
            int actualDays  = 0, actualMonths = 0, actualYears = 0;

            // Swap if needed
            if (d1 > d2)
            {
                DateTime temp = d1;
                d2 = d1;
                d2 = temp;
            }

            if ((d1.Month != d2.Month) || (d1.Year != d2.Year))
            {
                // Different month
                int daysInMonth = DateTime.DaysInMonth(d1.Year, d1.Month);
                actualDays  = daysInMonth - d1.Day + d2.Day;

                if (actualDays >= daysInMonth)
                {
                    actualDays   = actualDays - daysInMonth;
                    actualMonths = 1;
                }
            }
            else 
                actualDays = d2.Day - d1.Day;                               // different months

            if (d1.Year != d2.Year)
                actualMonths += 11 - d1.Month + d2.Month;                   // different year
            else if (d1.Month != d2.Month)
                actualMonths += d2.Month - d1.Month - 1;                    // same year different year

            if (d1.Year + 1 < d2.Year)
                actualMonths += 12 * (d2.Year - d1.Year - 1);               // More than 1 year apart

           actualYears  = actualMonths / 12;    // Whole years
           actualMonths = actualMonths % 12;    // reamaining methods

           return actualYears + (actualMonths / 12.0) + (actualDays / 365.2425);
        }

        /// <summary>Returns all PN DSS customer form the DSS on the web customer and packages db.</summary>
        public static Dictionary<Guid, string> GetDSSCustomerList()
        {
            Dictionary<Guid, string> customers = new Dictionary<Guid,string>();
            DataSet data = new DataSet();
            string connectionString;

            // Get the CustomerAndPackagesDB setting
            try
            {
                ConnectionStringSettings setting = WebConfigurationManager.ConnectionStrings["CustomerAndPackagesDB"];
                connectionString = setting.ConnectionString;
                if (string.IsNullOrEmpty(connectionString))
                    throw new ApplicationException();
            }
            catch(Exception)
            {
                throw new ApplicationException("Missing web.config CustomerAndPackagesDB db connection.");
            }

            // Run the sp to get all the customers (and their ids) from the customer and packages db
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter.SelectCommand = new SqlCommand("pGetPNCustomers", connection);
                adapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0].Rows.Cast<DataRow>().ToDictionary(r => ConvertExtensions.ChangeType<Guid>(r[0]), r => ConvertExtensions.ChangeType<string>(r[1]));
        }

        /// <summary>Returns the details of the dug definition request from the customer and packages db</summary>
        /// <param name="drugDefRequestId">drug def request Id</param>
        /// <returns>PN drug request row data</returns>
        public static DataRow GetDSSDrugDefRequest(int drugDefRequestId)
        {
            DataSet data = new DataSet();
            string connectionString;

            // Get the CustomerAndPackagesDB setting
            try
            {
                ConnectionStringSettings setting = WebConfigurationManager.ConnectionStrings["CustomerAndPackagesDB"];
                connectionString = setting.ConnectionString;
                if (string.IsNullOrEmpty(connectionString))
                    throw new ApplicationException();
            }
            catch(Exception)
            {
                throw new ApplicationException("Missing web.config CustomerAndPackagesDB db connection.");
            }

            // Build parameter list
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("drugDefRequestID", drugDefRequestId);

            // Run the sp to get the pn drug request details from the customer and packages db
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlDataAdapter adapter = new SqlDataAdapter();
                adapter.SelectCommand = new SqlCommand("pGetPNDrugDefRequestById", connection);
                adapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                adapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                adapter.Fill(data);
                connection.Close();
            }

            return data.Tables[0].Rows.Cast<DataRow>().FirstOrDefault();
        }
    }
}
