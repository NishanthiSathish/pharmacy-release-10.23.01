

/***********************************************
 * Installer Configuration Utilities
 * *********************************************/

/**********************************************
 * Read/Write custom configuration XML file for installation data
 **********************************************/

using System;
using System.Xml;
using System.Collections;
using System.Collections.Specialized;
using System.Windows.Forms;

namespace ClientConfiguration
{
    //type
    public struct Client2Data
    {
        public string WebServer;
        public string WebSite;
        public string UseHTTPS;             //+ GB TFS 83989
    }
    /// <summary>
    /// Summary description for Configuration.
    /// </summary>
    public class Configuration
    {
        private XmlDocument config = null;	//xml configuration file data
        private string ClientInstallConfigurationPath = null;
        private Client2Data cfg_data = new Client2Data();

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
            cfg_data.UseHTTPS = config.SelectSingleNode("ClientInstallConfiguration/UseHTTPS").InnerText;       //+ GB TFS 83989
        }
        //Write the configuration XML from internal struct
        public void WriteConfiguration()
        {
            config.SelectSingleNode("ClientInstallConfiguration/WebServer").InnerText = cfg_data.WebServer;
            config.SelectSingleNode("ClientInstallConfiguration/WebSite").InnerText = cfg_data.WebSite;
            config.SelectSingleNode("ClientInstallConfiguration/UseHTTPS").InnerText = cfg_data.UseHTTPS;       //+ GB TFS 83989

            config.Save(ClientInstallConfigurationPath);
        }
        public string WebServer
        {
            get
            {
                return cfg_data.WebServer;
            }
            set
            {
                cfg_data.WebServer = value;
            }
        }
        public string WebSite
        {
            get
            {
                return cfg_data.WebSite;
            }
            set
            {
                cfg_data.WebSite = value;
            }
        }
        //+ GB TFS 83989
        public string UseHTTPS
        {
            get
            {
                return cfg_data.UseHTTPS;
            }
            set
            {
                cfg_data.UseHTTPS = value;
            }
        }
        //+ GB TFS 83989
    }
}

