//===========================================================================
//
//							    PharmacyDataCache.cs
//
//  Provides a set of caching functions, for use with the pharmacy data, and
//  business, layers.
//
//  This will eventually allow the layers to be used in both web, and non web,
//  based applications.
//
//  Currently the class only supports cache for web application with the choice
//  of caching to the Cache, or Context, objects, or using the ICW session table cache
//
//  The Cache store is used for long term data storage, though objects in this
//  cache will be removed after 1 hour, to allow data to be continually refreshed.
//
//  There are two types of session store 
//      - DB session store (uses ICW database Session table)
//      - Web based session store (but actually uses the long term cache with sessionID prefixing the key)
//        Mainly as I still don't trust web based session cache.      
//
//  The Context store is used for short term storage for a single response 
//  storage.
//  
//	Modification History:
//	27Apr09 XN  Written
//  21Dec09 XN  Extended caching so works seamlessly with non web based 
//              applications (F0042698)
//  18Jan10 XN  Added methods GetFromSession, and SetFromSession (F0042698)
//  29Apr10 XN  Added method ClearCaches (used by unit tests)
//  21Oct11 XN  Added method RemoveFromCache
//  29Nov11 XN  Changes SaveToSession to SaveToDBSession, and GetFromSession tp GetFromDBSession
//  24Jan12 XN  Added web based session cache methods, and TryGetFromCache
//  11Jun14 XN  Removed need for GENRTL10.StateRead for saving to SessionAttribute 43318 
//===========================================================================
using System;
using System.Web;
using System.Web.Caching;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;

namespace ascribe.pharmacy.shared
{
    public static class PharmacyDataCache
    {
        /// <summary>1 hour in ms</summary>
        private const int CacheExipryTime = (1*60*60*1000);

        private static Dictionary<string, object> nonWebBasedAppCache    = new Dictionary<string,object>();
        private static Dictionary<string, object> nonWebBasedAppSessoion = new Dictionary<string,object>();
        private static Dictionary<string, object> nonWebBasedAppItems    = new Dictionary<string,object>();

        #region Long Term Cache Methods
        /// <summary>
        /// Tries to get the data from the web Cache (long term storage)
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// </summary>
        /// <typeparam name="T">Type to get</typeparam>
        /// <param name="key">Unique key used to store the object</param>
        /// <param name="value">Value to get (default if can't find value)</param>
        /// <returns>If stored item found</returns>
        public static bool TryGetFromCache<T>(string key, out T value)
        {
            object val = GetFromCache(key);
            value = (val == null) ? default(T) : (T)val;
            return (val != null);
        }

        /// <summary>
        /// Gets data from the web Cache object.
        /// Used for long term data storage.
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <returns>stored object (or null if object was not stored)</returns>
        public static object GetFromCache(string key)
        {
            object value = null;
            if (HttpContext.Current == null) 
                nonWebBasedAppCache.TryGetValue(key, out value);
            else
                value = HttpContext.Current.Cache[key];
            return value;
        }

        /// <summary>
        /// Save data to the web Cache object.
        /// Used for long term data storage.
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <param name="value">data to be stored</param>
        /// <param name="absoluteExpiration">Time after which cached items expire (Cache.NoAbsoluteExpiration or DateTime.MaxValue for never expire). Default 1 hour from now</param>
        public static void SaveToCache(string key, object value, DateTime absoluteExpiration)
        {            
            if (HttpContext.Current == null)
                nonWebBasedAppCache[key] = value;
            else
            {
                HttpContext.Current.Cache.Add(key,
                                              value,
                                              null,
                                              absoluteExpiration,
                                              Cache.NoSlidingExpiration,
                                              CacheItemPriority.Normal,
                                              null);
            }
        }
        public static void SaveToCache(string key, object value)
        {
            SaveToCache(key, value, DateTime.Now.AddMilliseconds(CacheExipryTime));
        }

        /// <summary>Remove the item form the long term cache</summary>
        public static void RemoveFromCache(string key)
        {
            if (HttpContext.Current == null) 
                nonWebBasedAppCache.Remove(key);
            else
                HttpContext.Current.Cache.Remove(key);
        }
        #endregion

        #region Short term (response) cahce methods
        /// <summary>
        /// Gets data from the web Context object.
        /// Used for short term single response storage.
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <returns>stored object (or null if object was not stored)</returns>
        public static object GetFromContext(string key)
        {
            object value = null;
            if (HttpContext.Current == null) 
                nonWebBasedAppItems.TryGetValue(key, out value);  
            else
                value = HttpContext.Current.Items[key];
            return value;
        }

        /// <summary>
        /// Save data to the web Context object.
        /// Used for short term single response storage.
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <param name="value">data to be stored</param>
        public static void SaveToContext(string key, object value)
        {
            if (HttpContext.Current == null)
                nonWebBasedAppItems[key] = value;
            else
                HttpContext.Current.Items[key] = value;
        }
        #endregion

        #region Web based session cahce methods
        /// <summary>
        /// Tries to get the data from session specific web cache
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// Note: Despite fact cache is for session, it actually uses long term storeage cache, 
        ///       but autoamtically adds session ID to key. Main as I don't trust the default session cache
        /// </summary>
        /// <typeparam name="T">Type to get</typeparam>
        /// <param name="key">Unique key used to store the object</param>
        /// <param name="value">Value to get (default if can't find value)</param>
        /// <returns>If stored item found</returns>
        public static bool TryGetFromSession<T>(string key, out T value)
        {
            return TryGetFromCache(key, out value);
        }

        /// <summary>
        /// Gets data from session specific web cache
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// Note: Despite fact cache is for session, it actually uses long term storeage cache, 
        ///       but autoamtically adds session ID to key. Main as I don't trust the default session cache
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <returns>stored object (or null if object was not stored)</returns>
        public static object GetFromSession(string key)
        {
            return GetFromCache(SessionInfo.SessionID.ToString() + "." + key);
        }

        /// <summary>
        /// Save data to the session specific web cache.
        /// Note: Objects will be removed from the cache after certain amount of time.
        /// Note: Despite fact cache is for session, it actually uses long term storeage cache, 
        ///       but autoamtically adds session ID to key. Main as I don't trust the default session cache
        /// </summary>
        /// <param name="key">Unique key used to store the object</param>
        /// <param name="value">data to be stored</param>
        /// <param name="absoluteExpiration">Time after which cached items expire (Cache.NoAbsoluteExpiration or DateTime.MaxValue for never expire). Default 1 hour from now</param>
        public static void SaveToSession(string key, object value, DateTime absoluteExpiration)
        {
            SaveToCache(SessionInfo.SessionID.ToString() + "." + key, value, absoluteExpiration);
        }
        public static void SaveToSession(string key, object value)
        {
            SaveToCache(SessionInfo.SessionID.ToString() + "." + key, value);
        }

        /// <summary>Remove the item form the session specific web cache.</summary>
        public static void RemoveFromSession(string key)
        {
            RemoveFromCache(SessionInfo.SessionID.ToString() + "." + key);
        }
        #endregion

        #region DB based session cahce methods
        /// <summary>Gets cached data from the ICW session table.</summary>
        /// <param name="key">Key used to cached the data</param>
        /// <returns>Cached data</returns>
        public static string GetFromDBSession(string key)
        {
            //GENRTL10.StateRead state = new GENRTL10.StateRead();
            //return state.SessionAttributeGet(SessionInfo.SessionID, key);   11Jun14 XN 43318
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SessionID", SessionInfo.SessionID);
            parameters.Add("@Attribute", key);
            return Database.ExecuteSQLScalar<string>("SELECT [Value] FROM SessionAttribute WHERE SessionID=@SessionID AND Attribute=@Attribute", parameters);
        }

        /// <summary>Saves cached data from the ICW session table.</summary>
        /// <param name="key">Key used to cached the data</param>
        /// <returns>Cached data</returns>
        public static void SaveToDBSession(string key, string value)
        {
            //GENRTL10.State state = new GENRTL10.State();
            //state.SessionAttributeSet(SessionInfo.SessionID, key, value);   11Jun14 XN 43318
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("@Attribute",        key                  );
            if (string.IsNullOrEmpty(value))
                Database.ExecuteSPNonQuery("pSessionAttributeDelete", parameters);
            else
            {
                parameters.Add("@Value", value);
                Database.ExecuteSPNonQuery("pSessionAttributeInsertOrUpdate", parameters);
            }
        }
        #endregion

        /// <summary>
        /// Clears all caches but only when used in non web based application (asserts if web application)
        /// Normaly used by unit tests
        /// </summary>
        private static void ClearCaches()
        {
            if (HttpContext.Current == null)
            {
                nonWebBasedAppCache.Clear();
                nonWebBasedAppSessoion.Clear();
                nonWebBasedAppItems.Clear();
            }
            else
                throw new ApplicationException("Can't clear web based caches.");
        }
    }
}
