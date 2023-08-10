

/***********************************************
 * Installer Configuration Utilities
 * *********************************************/

/**********************************************
 * Read custom configuration XML file for installation data
 **********************************************/

using System;
using System.Xml;
using System.Collections;
using System.Collections.Specialized;

namespace Ascribe.ICW.ClientInstaller
{
    //type
    public struct ClientData
    {
        public string WebServer;
        public string WebSite;
        public string useHTTPS;                         //+ GB TFS 83989
    }
    /// <summary>
    /// Summary description for Configuration.
    /// </summary>
    public class Configuration
    {
        private XmlDocument config = null;	//xml configuration file data
        private string ClientInstallConfigurationPath = null;
        private ClientData cfg_data = new ClientData();

        public Configuration(string ClientInstallConfigurationPath)	//load XML cfg file from path provided
        {
            this.ClientInstallConfigurationPath = ClientInstallConfigurationPath;
            config = new XmlDocument();
            config.Load(ClientInstallConfigurationPath);	//load the XML document
            ReadConfiguration();
        }
        //Read the configuration XML into internal struct
        private void ReadConfiguration()
        {
            cfg_data.WebServer = config.SelectSingleNode("ClientInstallConfiguration/WebServer").InnerText;
            cfg_data.WebSite = config.SelectSingleNode("ClientInstallConfiguration/WebSite").InnerText;
            cfg_data.useHTTPS = config.SelectSingleNode("ClientInstallConfiguration/UseHTTPS").InnerText;      //+ GB TFS 83989
        }
        public string WebServer
        {
            get
            {
                return cfg_data.WebServer;
            }
        }
        public string WebSite
        {
            get
            {
                return cfg_data.WebSite;
            }
        }
        public string UseHTTPS
        {
            get { return cfg_data.useHTTPS; }
        }
    }
}
