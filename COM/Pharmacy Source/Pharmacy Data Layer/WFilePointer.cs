//===========================================================================
//
//							    WFilePointer.cs
//
//  Provides access and helper function to WFilePointer table.
//
//  Replacement for vb6 method GetPointerSQL (CoreLib.bas)
//
//  Class has number of static method to perform the counter operations
//      Increment
//      Read
//      Write
//      Decrement
//
//  Currrently only Increments have been tested
//  
//  Usage
//  int drugID = WFilePointer.Increment(SessionInfo.SiteID, "A|DrugID");
// 
//	Modification History:
//	19Dec13 XN  Written
//  04Nov14 XN  Fixed error in Decrement
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public static class WFilePointer
    {
        /// <summary>
        /// Increments the filepointer value and returns the new value
        /// If category starts with A| uses the DSSMasterSiteID for the site
        /// </summary>
        /// <param name="siteID">Site</param>
        /// <param name="category">File pointer category</param>
        public static int Increment(int siteID, string category)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            if (category.StartsWith("A|", StringComparison.InvariantCultureIgnoreCase))
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID           ));
                parameters.Add(new SqlParameter("DSSMasterSiteID",  Sites.GetDSSMasterSiteID(siteID)));
                parameters.Add(new SqlParameter("Category",         category                        ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerIncrementbyDSSMasterSiteID", parameters);
            }
            else
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
                parameters.Add(new SqlParameter("LocationID_Site",  siteID                  ));
                parameters.Add(new SqlParameter("Category",         category                ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerIncrement", parameters);
            }
        }

        /// <summary>
        /// Returns the current filepointer value
        /// If category starts with A| uses the DSSMasterSiteID for the site
        /// </summary>
        /// <param name="siteID">Site</param>
        /// <param name="category">File pointer category</param>
        public static int Read(int siteID, string category)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            if (category.StartsWith("A|", StringComparison.InvariantCultureIgnoreCase))
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID           ));
                parameters.Add(new SqlParameter("DSSMasterSiteID",  Sites.GetDSSMasterSiteID(siteID)));
                parameters.Add(new SqlParameter("Category",         category                        ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerReadbyDSSMasterSiteID", parameters);
            }
            else
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
                parameters.Add(new SqlParameter("LocationID_Site",  siteID                  ));
                parameters.Add(new SqlParameter("Category",         category                ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerRead", parameters);
            }
        }

        /// <summary>
        /// Write the filepointer value to the db
        /// If category starts with A| uses the DSSMasterSiteID for the site
        /// </summary>
        /// <param name="siteID">Site</param>
        /// <param name="category">File pointer category</param>
        /// <param name="value">value to write</param>
        public static void Write(int siteID, string category, int value)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            if (category.StartsWith("A|", StringComparison.InvariantCultureIgnoreCase))
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID           ));
                parameters.Add(new SqlParameter("LocationID_Site",  siteID                          ));
                parameters.Add(new SqlParameter("DSSMasterSiteID",  Sites.GetDSSMasterSiteID(siteID)));
                parameters.Add(new SqlParameter("Category",         category                        ));
                parameters.Add(new SqlParameter("PointerID",        value                           ));
                Database.ExecuteSPNonQuery("pWFilePointerWritebyDSSMasterSiteID", parameters);
            }
            else
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
                parameters.Add(new SqlParameter("LocationID_Site",  siteID                  ));
                parameters.Add(new SqlParameter("Category",         category                ));
                parameters.Add(new SqlParameter("PointerID",        value                   ));
                Database.ExecuteSPNonQuery("pWFilePointerWrite", parameters);
            }
        }

        /// <summary>
        /// Decrements the filepointer value and returns the new value
        /// If category starts with A| uses the DSSMasterSiteID for the site
        /// </summary>
        /// <param name="siteID">Site</param>
        /// <param name="category">File pointer category</param>
        public static int Decrement(int siteID, string category)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            if (category.StartsWith("A|", StringComparison.InvariantCultureIgnoreCase))
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID           ));
                parameters.Add(new SqlParameter("DSSMasterSiteID",  Sites.GetDSSMasterSiteID(siteID)));
                parameters.Add(new SqlParameter("Category",         category                        ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerDecrementbyDSSMasterSiteID", parameters);
            }
            else
            {
                parameters.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID   ));
                //parameters.Add(new SqlParameter("SiteID",         siteID                  )); XN 04Nov14 Fixed error
                parameters.Add(new SqlParameter("LocationID_Site",  siteID                  ));
                parameters.Add(new SqlParameter("Category",         category                ));
                return Database.ExecuteSPReturnValue<int>("pWFilePointerDecrement", parameters);
            }
        }
    }
}
