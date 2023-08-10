//===========================================================================
//
//							  SimulatedHttpRequest.cs
//
//	Class used to create a HttpContext instance to allow the Pharamcy data 
//  cache to work during unit testing.
//
//  Usage:
//      SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", "C:\Temp");
//      
//	Modification History:
//	27Apr09 XN  Written
//===========================================================================
using System;
using System.IO;
using System.Web;
using System.Web.Hosting;

namespace Unit_Test_Base_Data_Layer
{
    public class SimulatedHttpRequest : SimpleWorkerRequest
    {
        private string _host;   // host addres passed into the constructor.

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="appVirtualDir">App virtual dir.</param>
        /// <param name="appPhysicalDir">App physical dir.</param>
        /// <param name="page">Page.</param>
        /// <param name="query">Query.</param>
        /// <param name="output">Output.</param>
        /// <param name="host">Host.</param>
        public SimulatedHttpRequest(string appVirtualDir, string appPhysicalDir, string page, string query, TextWriter output, string host) : base(appVirtualDir, appPhysicalDir, page, query, output)
        {
            if(host == null || host.Length == 0)
                throw new ArgumentNullException("host", "Host cannot be null nor empty.");

            _host = host;
        }

        /// <summary>
        /// Gets the name of the server.
        /// </summary>
        /// <returns>server name</returns>
        public override string GetServerName()
        {
            return _host;
        }
     
        /// <summary>
        /// Maps the path to a filesystem path.
        /// </summary>
        /// <param name="virtualPath">Virtual path.</param>
        /// <returns></returns>
        public override string MapPath(string virtualPath)
        {
            return Path.Combine(this.GetAppPath(), virtualPath);
        }

        /// <summary>
        /// Sets the HTTP context with a valid simulated request
        /// </summary>
        /// <param name="host">Host server</param>
        /// <param name="application">Application name</param>
        /// <param name="appPhysicalDir">Sets physical directory.</param>
        public static void SetHttpContextWithSimulatedRequest(string host, string application, string appPhysicalDir)
        {
            string appVirtualDir = "/";
            string page = application.Replace("/", string.Empty) + "/default.aspx";
            string query = string.Empty;

            TextWriter output = null;

            SimulatedHttpRequest workerRequest = new SimulatedHttpRequest(appVirtualDir, appPhysicalDir, page, query, output, host);
            HttpContext.Current = new HttpContext(workerRequest);
        }
    }
}
