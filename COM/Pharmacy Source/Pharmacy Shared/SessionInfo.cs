//===========================================================================
//
//							     SessionInfo.cs
//
//	Holds information about the current ICW session, and site.
//  This allows the code base can have easy access to the info.
//
//  SessionInfo.InitialiseSession should be called every time a page is loaded,
//  there are 4 version of this method 
//      one for just session info
//      one for just session info via HTTP request
//      one for sesssion and site
//      one for just sesssion and site info via HTTP request (if site number does not exist can call error page)
//  Call the appropriate version depending on if your code is site specific.
// 
//  Class stores it's data in the pharmacy data context cache.
//
//  Usage:
//      SessionInfo.InitialiseSession(sessionID, siteID)
//      SessionInfo.SessionID   - Gets session ID
//      SessionInfo.Username    - Gets current username (e.g. garym)
//      SessionInfo.Fullname    - Gets current users full name (e.g. Gary Mooney)
//      SessionInfo.UserInitials- Gets current user initials (e.g GAM);
//      SessionInfo.Terminal    - Gets user terminal
//      SessionInfo.SiteID      - Gets current site ID
//  Or
//      SessionInfo.InitialiseSessionAndSite(this.Request, null)
//      
//	Modification History:
//	15Apr09 XN  Written
//  24Apr09 XN  Got the class to work in a web application, by saving the 
//              static data in the HttpContext object. 
//  27Apr09 XN  Store data in pharmacy data cache
//  21Jul09 XN  Added storing site specific information.
//  18Jan10 XN  Added support for getting users full name (F0042698).
//  03Sep10 XN  Added property LocationID, and renamed LoadEntityInfo to 
//              LoadSessionInfo. (F0082255)
//  15Nov11 XN  Added method HasAnyPolicies
//  12Aug13 XN  Added initialisation by HTTP request, and property SiteNumber 24653
//  19Dec13 XN  78339 Added HasSite property
//  09Jul14 XN  38034 Added SaveAttribute
//  19Aug14 XN  Added testing if session is still valid
//  02Oct15 XN  Added GetStatePKByTable 77780
//  15Oct15 XN  Added methods GetAttribute and SetStatePKByTable 77977
//  19Oct15 XN  Added method GetAllAttributes 77976
//  18May16 XN  Added GetUserFullname 123082
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using TRNRTL10;

namespace ascribe.pharmacy.shared
{
    public static class SessionInfo
    {
        #region Public Properties
        /// <summary>Get session ID passed into LoadSessionInfo</summary>
        public static int SessionID 
        { 
            get 
            {
                object sessionID = PharmacyDataCache.GetFromContext("Pharmacy.SessionID");
                if (sessionID == null)
                    throw new ApplicationException("Failed to initialise SessionInfo class, before using the pharmacy data layer.");
                return (int)sessionID;
            }
            private set 
            { 
                PharmacyDataCache.SaveToContext("Pharmacy.SessionID", value); 
            }
        }

        /// <summary>
        /// Gets the site ID passed into LoadSessionInfo
        /// Unlike other properties the site id is not read from the db, 
        /// but must be passed in on SessionInfo initialisation.
        /// </summary>
        public static int SiteID
        {
            get
            {
                object siteID = PharmacyDataCache.GetFromContext("Pharmacy.SiteID");
                if (siteID == null)
                    throw new ApplicationException("Failed to initialise SessionInfo class with site info, before using SessionInfo.SiteID.");
                return (int)siteID;
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.SiteID", value); }
        }

        /// <summary>
        /// Gets the site number, must of passed the site ID or number to the initialise method
        /// 12Aug13 XN  24653
        /// </summary>
        public static int SiteNumber
        {
            get
            {
                object siteNumber = PharmacyDataCache.GetFromContext("Pharmacy.SiteNumber");
                if (siteNumber == null)
                {
                    Transport dblayer = new Transport();    // ICW transport layer
                    string parameters = dblayer.CreateInputParameterXML("SiteID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, SessionInfo.SiteID);
                    siteNumber = dblayer.ExecuteSelectReturnSP(SessionID, "pLocationID_SiteNumberbySite", parameters);
                    SiteNumber = (int)siteNumber;
                }
                return (int)siteNumber;
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.SiteNumber", value); }
        }

        /// <summary>Get entityID for the current user (from table [Session].[EntityID]).</summary>
        public static int EntityID 
        { 
            get 
            { 
                object value = PharmacyDataCache.GetFromContext("Pharmacy.EntityID");
                if ( value == null )
                {
                    LoadSessionInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.EntityID");
                }

                return (int)value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.EntityID", value); }
        }

        /// <summary>Get username for current user (from table [User].[Username])</summary>
        public static string Username 
        { 
            get 
            { 
                string value = PharmacyDataCache.GetFromContext("Pharmacy.Username") as string;
                if ( value == null )
                {
                    LoadUserInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.Username") as string;
                }

                return value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.Username", value); }
        }

        /// <summary>Get fullname for current user (from table [entity].[Description])</summary>
        public static string Fullname
        {
            get 
            { 
                string value = PharmacyDataCache.GetFromContext("Pharmacy.Fullname") as string;
                if ( value == null )
                {
                    LoadUserInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.Fullname") as string;
                }

                return value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.Fullname", value); }
        }

        /// <summary>Get users initials for current user (from table [Person].[Initials])</summary>
        public static string UserInitials
        { 
            get 
            { 
                string value = PharmacyDataCache.GetFromContext("Pharmacy.Userinitials") as string;
                if ( value == null )
                {
                    LoadUserInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.Userinitials") as string;
                }

                return value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.Userinitials", value); }
        }

        /// <summary>Get terminal name for current session (from table [Location].[Description]</summary>
        public static string Terminal
        { 
            get 
            { 
                string value = PharmacyDataCache.GetFromContext("Pharmacy.Terminal") as string;
                if ( value == null )
                {
                    LoadTerminalInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.Terminal") as string;
                }

                return value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.Terminal", value); }
        }

        /// <summary>Get locationID for the current user (from table [Session].[LocationID]).</summary>
        public static int LocationID
        {
            get 
            { 
                object value = PharmacyDataCache.GetFromContext("Pharmacy.LocationID");
                if ( value == null )
                {
                    LoadSessionInfo(); 
                    value = PharmacyDataCache.GetFromContext("Pharmacy.LocationID");
                }

                return (int)value; 
            }
            private set { PharmacyDataCache.SaveToContext("Pharmacy.LocationID", value); }
        }
        
        /// <summary>Returns if the site has been initalised 19Dec13 XN 78339</summary>
        public static bool HasSite { get { return PharmacyDataCache.GetFromContext("Pharmacy.SiteID") != null; } }
        #endregion

        #region Public Methods
        /// <summary>
        /// Set session info
        /// </summary>
        /// <param name="sessionID">Session ID</param>
        public static void InitialiseSession(int sessionID)
        {
            ValidateSessionID(sessionID);
            SessionID = sessionID;
        }        

        /// <summary>Set the session info from the request url SessionID parameter 12Aug13 XN  24653</summary>
        public static void InitialiseSession(HttpRequest request)
        {
            SessionID = int.Parse(request["SessionID"]);
            ValidateSessionID(SessionID);
        }

        /// <summary>
        /// Set session info, and session's active site
        /// </summary>
        /// <param name="sessionID">Session ID</param>
        /// <param name="siteID">site ID</param>
        public static void InitialiseSessionAndSiteID(int sessionID, int siteID)
        {
            ValidateSessionID(sessionID);

            SessionID = sessionID;
            SiteID    = siteID;
        }

        /// <summary>
        /// Set session info, and session's active site
        /// </summary>
        /// <param name="sessionID">Session ID</param>
        /// <param name="siteNumber">site number</param>
        public static void InitialiseSessionAndSiteNumber(int sessionID, int siteNumber)
        {
            ValidateSessionID(sessionID);

            SessionID = sessionID;
            LoadSiteIDByNumner(siteNumber);
        }

        /// <summary>
        /// Set the session and site info from the request url SessionID, and either AscribeSiteNumber or SiteID.
        /// If AscribeSiteNumber or SiteID not presense and response is set will redirect page to DesktopError.aspx
        /// 12Aug13 XN  24653
        /// </summary>
        public static bool InitialiseSessionAndSite(HttpRequest request, HttpResponse response)
        {
            SessionID = int.Parse(request["SessionID"]);
                        
            // Validate the session
            try
            {
                ValidateSessionID(SessionID);
            }
            catch (ApplicationException ex)
            {
                if (response != null)
                    response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=" + ex.Message);
                else
                    throw ex;
            }

            // Setup site
            string ascribeSiteNumber = request["AscribeSiteNumber"];
            string siteID            = request["SiteID"];
            bool OK = false;

            if (!string.IsNullOrEmpty(siteID))
            {
                SiteID = int.Parse(siteID);
                OK = false;
            }
            else if (!string.IsNullOrEmpty(ascribeSiteNumber))
            {
                LoadSiteIDByNumner(int.Parse(ascribeSiteNumber));
                OK = false;
            }
            else if (response != null)
                response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Missing site number in desktop configuration.");

            return OK;
        }

        /// <summary>Returns if user has any of the ICW policies enabled</summary>
        /// <param name="policyDescription">Policy descritpion</param>
        /// <returns>If user has any of the policies enabled</returns>
        public static bool HasAnyPolicies(params string[] policyDescription)
        {
            Transport dblayer = new Transport();    // ICW transport layer
            string parameters;                      // sp parameters

            foreach (string policy in policyDescription)
            {
                parameters = dblayer.CreateInputParameterXML("Description", Transport.trnDataTypeEnum.trnDataTypeText, policy.Length, policy);
                if (dblayer.ExecuteSelectReturnSP(SessionID, "pPolicyValidate", parameters) == 1)
                    return true;
            }

            return false;
        }

        /// <summary>Save attribute to db table SessionAttribute 38034 XN 9Jul14</summary>
        /// <param name="key">Session attribute key</param>
        /// <param name="value">Session attribute value</param>
        public static void SaveAttribute(string key, string value)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("@Attribute",        key                  );
            parameters.Add("@Value",            value                );
            Database.ExecuteSPNonQuery("pSessionAttributeInsertOrUpdate", parameters);
        }
        
        /// <summary>Get the SessionAttribute XN 15Oct15 77977</summary>
        /// <typeparam name="T">Convert to value to this type</typeparam>
        /// <param name="key">Session attribute key</param>
        /// <param name="defaultVal">default value is does not exist</param>
        /// <returns>attribute value (else default)</returns>
        public static T GetAttribute<T>(string key, T defaultVal)
        {
            try
            {
                List<SqlParameter> parameters = new List<SqlParameter>();
                parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
                parameters.Add("@Attribute",        key                  );
                string xml = Database.ExecuteScalar<string>("pSessionAttributeGet", parameters);
                return ConvertExtensions.ChangeType<T>(XElement.Parse(xml).Attribute("Value").Value);
            }
            catch (Exception)
            {
                return defaultVal;
            }
        }

        /// <summary>
        /// Returns all attributes for this session where Key=Attribute name, and Value= attribute values
        /// 19Oct15 XN 77976
        /// </summary>
        /// <returns>All attributes for this session</returns>
        public static IDictionary<string,string> GetAllAttributes()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionId", SessionInfo.SessionID);
            var rs =  Database.ExecuteSPDataTable("pSessionAttributeGetAll", parameters);
            return rs.Rows.Cast<DataRow>().ToDictionary(r => r["Attribute"] as string, r => r["Value"] == DBNull.Value ? null : r["Value"] as string);
        }
    
        /// <summary>
        /// Returns the PrimaryKey value from the State table (for the current session)
        /// 2Oct15 XN 77780
        /// </summary>
        /// <param name="tableName">State's table of interest</param>
        /// <returns>Primary key or null if not present</returns>
        public static int? GetStatePKByTable(string tableName)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionID);
            parameters.Add("TableName", tableName);

            // Primary key is an output parameter
            parameters.Add(new SqlParameter("PrimaryKey", SqlDbType.Int));
            parameters[2].Direction = ParameterDirection.Output;
            parameters[2].IsNullable= true;

            Database.ExecuteSPNonQuery("pStateGet", parameters);
            return (parameters[2].Value == null || parameters[2].Value == DBNull.Value) ? null : parameters[2].Value as int?;
        }

        /// <summary>Save the pk value to the State table (for the current session) XN 15Oct15 77977</summary>
        /// <param name="tableName">State table of interest</param>
        /// <param name="pk">PK value</param>
        public static void SetStatePKByTable(string tableName, int pk)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionID);
            parameters.Add("TableName",  tableName);
            parameters.Add("PrimaryKey", pk);
            Database.ExecuteSPNonQuery("pStateSet", parameters);
        }
        
        /// <summary>
        /// Returns the user's full name [Title] [Forename] [Surname]
        /// 18May16 XN 123082
        /// </summary>
        /// <returns>user's full name</returns>
        public static string GetUserFullname()
        {
            return Database.ExecuteSQLScalar<string>("SELECT [Title] + ' ' + [Forename] + ' ' + [Surname] FROM Person WHERE EntityID={0}", SessionInfo.EntityID);
        }
        #endregion

        #region Private Methods
		/// <summary>
        /// Loads in the entity, and location, info from call to sp pSessionXML
        /// </summary>
        private static void LoadSessionInfo()
        {
            Transport dblayer = new Transport();    // ICW transport layer
            string parameters;                      // sp parameters
            XElement xml;                           // xml returns from sp

            // Get the entity ID for the session
            parameters = dblayer.CreateInputParameterXML("SessionID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, SessionID);
            xml        = XElement.Parse(dblayer.ExecuteSelectStreamSP(SessionID, "pSessionXML", parameters));
            EntityID   = int.Parse((from p in xml.Attributes() where (p.Name.LocalName == "EntityID")   select p.Value).First());
            LocationID = int.Parse((from p in xml.Attributes() where (p.Name.LocalName == "LocationID") select p.Value).First());
        }

        /// <summary>
        /// Loads in the user info (username, intials), from call to sp pUserXML.
        /// </summary>
        private static void LoadUserInfo()
        {
            Transport dblayer = new Transport();    // ICW transport layer
            string parameters;                      // sp parameters
            XElement xml;                           // xml returns from sp

            // Get the entity ID for the session
            parameters  = dblayer.CreateInputParameterXML("EntityID", Transport.trnDataTypeEnum.trnDataTypeInt, 4, EntityID);
            xml         = XElement.Parse(dblayer.ExecuteSelectStreamSP(SessionID, "pUserXML", parameters));
            Username    = (from p in xml.Attributes() where (p.Name.LocalName == "Username")    select p.Value).First();
            Fullname    = (from p in xml.Attributes() where (p.Name.LocalName == "Description") select p.Value).First();
            UserInitials= (from p in xml.Attributes() where (p.Name.LocalName == "Initials")    select p.Value).First();
        }

        /// <summary>
        /// Loads in the terminal info, from call to sp pTerminalIdentifyForPharmacy
        /// </summary>
        private static void LoadTerminalInfo()
        {
            Transport dblayer = new Transport();    // ICW transport layer
            DataTable ds = dblayer.ExecuteSelectSP(SessionID, "pTerminalIdentifyForPharmacy", "").Tables[0];
            Terminal = (ds.Rows.Count == 0) ? string.Empty : ds.Rows[0]["Description"].ToString();
        } 

        /// <summary>
        /// Loads in the siteID, from call to sp pLocationID_SitebySiteNumber
        /// </summary>
        private static void LoadSiteIDByNumner(int siteNumber)
        {
            Transport dblayer = new Transport();    // ICW transport layer
            string parameters;                      // sp parameters

            // Get the site number
            parameters  = dblayer.CreateInputParameterXML("SiteNumber", Transport.trnDataTypeEnum.trnDataTypeInt, 4, siteNumber);
            SiteID     = dblayer.ExecuteSelectReturnSP(SessionID, "pLocationID_SitebySiteNumber", parameters);
            SiteNumber = SiteNumber;
        }

        /// <summary>Validate the session ID</summary>
        private static void ValidateSessionID(int sessionID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", sessionID);
            var result = Database.ExecuteScalar<int?>("pSessionExists", parameters) ?? 0;
            if (result <= 0)
                throw new ApplicationException("Invalid Session ID " + sessionID.ToString());
        }
	    #endregion        
    }
}
