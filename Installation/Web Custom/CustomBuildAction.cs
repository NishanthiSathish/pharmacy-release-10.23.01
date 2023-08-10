using System;
using System.Configuration;
using System.Configuration.Install;
using System.ComponentModel;
using System.Diagnostics;
using System.DirectoryServices;
using System.IO;
using System.Web.Configuration;
using System.Security.AccessControl;
using System.Collections.Generic;

namespace WebCustom
{
    [RunInstaller(true)]
    public class CustomBuildAction : Installer
    {
        private const string DATABASE_CONNECTION_KEY = "TRNRTL10.My.MySettings.ConnectionString";
        private const string V11_LOCATION = "ICW_V11Location";
        private string ProductName = string.Empty;
        private bool UseHTTPS = false;                                  //+ GB TFS 83989
        private string HTTPString = string.Empty;                       //+ GB TFS 83989
        private string WebServer = System.Environment.MachineName;      //+ GB TFS 83989

		private string LivePrintGuid = "LIVE00000000-0000-0000-0000-000000000000";
		private string TestPrintGuid = "TEST00000000-0000-0000-0000-000000000000";
		private string TrainingPrintGuid = "TRAIN00000000-0000-0000-0000-000000000000";

		/// <summary>
		/// The client type.
		/// </summary>
		enum ClientType { Live, Testing, Training };

        protected override void OnBeforeInstall(System.Collections.IDictionary savedState)
        {
            base.OnBeforeInstall(savedState);

            string targetDirectory = Context.Parameters["targetdir"];

            if (targetDirectory.Contains(" "))
            {
                targetDirectory.Replace(" ", "");
            }
        }

        public override void Install(System.Collections.IDictionary stateSaver)
        {
            string s = string.Empty;
            try
            {
                s = "inside install";
                base.Install(stateSaver);
                s = "Before Variable decl";
                string targetSite = Context.Parameters["targetsite"];
                string targetDirectory = Context.Parameters["targetdir"];
                string targetVDir = Context.Parameters["targetvdir"];
                string sourceDir = Context.Parameters["sourceDir"];
                ProductName = Context.Parameters["prodName"];
                string icwVDir = Context.Parameters["icwvdir"];
                string connectionString = string.Empty;

                //+ GB TFS 83989
                this.WebServer = Context.Parameters["icwwebserver"];
                this.UseHTTPS = (Context.Parameters["optusehttps"] == "1");

                this.HTTPString = this.GetHTTPString();
                //+ GB TFS 83989

                if (targetDirectory.Contains(" "))
                {
                    targetDirectory.Replace(" ", "");
                }

                if (null == targetSite)
                {
                    throw new InstallException("IIS Site name not specified");
                }

                if (targetSite.StartsWith("/LM/"))
                {
                    targetSite = targetSite.Substring(4);
                }

                RegisterScriptMaps(targetSite, targetVDir);

                string v11Location = string.Empty;
                ConfigureICWWebConfig(targetSite, targetVDir, icwVDir, out connectionString, out v11Location);
                ConfigurePharmacyWebConfig(targetSite, targetVDir, icwVDir, connectionString, v11Location);

                // Set write and delete permission on RadUploadTemp for IIS 12Aug13 XN 24653
                string radUploadDirectoryName = targetDirectory + "App_Data\\RadUploadTemp";
                RemoveDirectorySecurity(radUploadDirectoryName, @"Everyone", new [] { FileSystemRights.Delete                                                  }, AccessControlType.Deny);
                AddDirectorySecurity   (radUploadDirectoryName, @"Everyone", new [] { FileSystemRights.Modify, FileSystemRights.Write, FileSystemRights.Delete }, AccessControlType.Allow);
                
                // Set write and delete permission on RadUploadTemp for IIS 28Nov16 XN  147104
                string csvImportExportDirectoryName = targetDirectory + "App_Data\\CsvImportExportTemp";
                RemoveDirectorySecurity(csvImportExportDirectoryName, @"Everyone", new [] { FileSystemRights.Delete                                                  }, AccessControlType.Deny);
                AddDirectorySecurity   (csvImportExportDirectoryName, @"Everyone", new [] { FileSystemRights.Modify, FileSystemRights.Write, FileSystemRights.Delete }, AccessControlType.Allow);
                
                this.EncryptConfigFileSection("connectionStrings", targetSite, targetVDir, string.Empty, new List<string>());

                // Remove debugging information from the config file
                RemoveDebugging(targetSite, targetVDir);
                
                stateSaver.Add("webDirectory", targetDirectory);
                stateSaver.Add("productName", ProductName);
            }
            catch (Exception e)
            {
                System.Diagnostics.EventLog.WriteEntry("Ascribe Installer", "String s is :" + s + " \r\nException is :" + e.Message + "\r\n. Stack trace " + e.StackTrace);
                throw e;
            }
        }

    	//+ GB TFS 83989
        /// <summary>
        /// Gets the http string required for this installation.
        /// </summary>
        /// <returns>http:// or https://</returns>
        private string GetHTTPString()
        {
            if (this.UseHTTPS)
            {
                return "https://";
            }
            else
            {
                return "http://";
            }
        }
        //+ GB TFS 83989

        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            base.Uninstall(savedState);
        }

        protected override void OnAfterUninstall(System.Collections.IDictionary savedState)
        {
            base.OnAfterUninstall(savedState);
            string targetDirectory = string.Empty;
            if (savedState.Contains("webDirectory"))
            {
                targetDirectory = savedState["webDirectory"].ToString();
            }

            if (Directory.Exists(targetDirectory))
            {
                try
                {
                    Directory.Delete(targetDirectory, true);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.EventLog.WriteEntry("Ascribe Installer", string.Format("Error removing directory '{0}'\n{1}", targetDirectory, ex.Message));
                }
            }
        }

        void RegisterScriptMaps(string targetSite, string targetVDir)
        {
            string sysRoot = System.Environment.GetEnvironmentVariable("SystemRoot");
            ProcessStartInfo info = new ProcessStartInfo();
            //info.FileName = Path.Combine(sysRoot, @"Microsoft.Net\Framework\v2.0.50727\aspnet_regiis.exe");   87210 Pharmacy Installer resetting application pool back to .NET2
            info.FileName = Path.Combine(sysRoot, @"Microsoft.Net\Framework\v4.0.30319\aspnet_regiis.exe");
            info.Arguments = string.Format("-s {0}/ROOT/{1}", targetSite, targetVDir);
            info.CreateNoWindow = true;
            info.UseShellExecute = false;

            Process.Start(info);
        }

        /// <summary>
        /// Configures the Pharmacy web.config by setting the icw location and db connection string
        /// </summary>
        /// <param name="targetSite"></param>
        /// <param name="targetVDir"></param>
        /// <param name="icwVDir"></param>
        /// <param name="connectionString"></param>
        private void ConfigurePharmacyWebConfig(string targetSite, string targetVDir, string icwVDir, string connectionString, string v11Location)
        {
            DirectoryEntry entry = new DirectoryEntry("IIS://Localhost/" + targetSite);
            string friendlySiteName = entry.Properties["ServerComment"].Value.ToString();

            Configuration config = WebConfigurationManager.OpenWebConfiguration("/" + targetVDir, friendlySiteName);
            config.AppSettings.Settings.Remove("ICW_Location");
            config.AppSettings.Settings.Add("ICW_Location", this.HTTPString + this.WebServer + "/" + icwVDir);                              //+ GB TFS 83989
            config.AppSettings.Settings.Remove(V11_LOCATION);
            config.AppSettings.Settings.Add(V11_LOCATION, v11Location);
            config.AppSettings.Settings.Remove("ICW_PharmacyLocation");
            config.AppSettings.Settings.Add("ICW_PharmacyLocation", this.HTTPString + this.WebServer + "/" + targetVDir);                   //+ GB TFS 83989

            ConnectionStringSettings appDatabase = new ConnectionStringSettings();
            appDatabase.Name = DATABASE_CONNECTION_KEY;
            appDatabase.ConnectionString = connectionString;

            config.ConnectionStrings.ConnectionStrings.Clear();
            config.ConnectionStrings.ConnectionStrings.Add(appDatabase);

            config.Save();
        }

        /// <summary>
        /// Configures the ICW web.config by setting the pharmacy location and reading the db connection string
        /// </summary>
        /// <param name="targetSite">The application web site</param>
        /// <param name="targetVDir">The virtual directory for the pharmacy application</param>
        /// <param name="icwVDir">The virtual directory for the ICW application</param>
        /// <param name="connectionString">The database connection string from the ICW web.config</param>
        /// <param name="v11Location">The URL of the v11 web application</param>
        private void ConfigureICWWebConfig(string targetSite, string targetVDir, string icwVDir, out string connectionString, out string v11Location)
        {
            DirectoryEntry entry = new DirectoryEntry("IIS://Localhost/" + targetSite);
            string friendlySiteName = entry.Properties["ServerComment"].Value.ToString();

            Configuration config = WebConfigurationManager.OpenWebConfiguration("/" + icwVDir, friendlySiteName);
            config.AppSettings.Settings.Remove("ICW_PharmacyLocation");
            config.AppSettings.Settings.Add("ICW_PharmacyLocation", this.HTTPString + this.WebServer + "/" + targetVDir);               //+ GB TFS 83989

        	var clientType = GetClientType();

			config.AppSettings.Settings.Remove("PrintControlObjectId");

			switch(clientType)
			{
				case ClientType.Live:			
		        	config.AppSettings.Settings.Add("PrintControlObjectId", LivePrintGuid);
					break;
				case ClientType.Testing:			
		        	config.AppSettings.Settings.Add("PrintControlObjectId", TestPrintGuid);
					break;
				case ClientType.Training:			
		        	config.AppSettings.Settings.Add("PrintControlObjectId", TrainingPrintGuid);
					break;
			}

            connectionString = config.ConnectionStrings.ConnectionStrings[DATABASE_CONNECTION_KEY].ConnectionString;
            v11Location = config.AppSettings.Settings[V11_LOCATION].Value;

            config.Save();
        }

        /// <summary>
        /// Remove debugging symbols from compiled pages
        /// </summary>
        /// <param name="targetSite"></param>
        /// <param name="targetVDir"></param>
        private void RemoveDebugging(string targetSite, string targetVDir)
        {
            DirectoryEntry entry = new DirectoryEntry("IIS://Localhost/" + targetSite);
            string friendlySiteName = entry.Properties["ServerComment"].Value.ToString();

            Configuration config = WebConfigurationManager.OpenWebConfiguration("/" + targetVDir, friendlySiteName);

            System.Web.Configuration.CompilationSection compile = (System.Web.Configuration.CompilationSection)config.GetSection("system.web/compilation");
            compile.Debug = false;

            config.Save();
        }

       /// <summary>
        /// Adds an ACL entry on the specified directory for the specified account.
        /// </summary>
        /// <param name="dirName">Folder path to add the permissions to</param>
        /// <param name="Account"></param>
        /// <param name="Rights"></param>
        /// <param name="ControlType"></param>
        private static void AddDirectorySecurity(string folderName, string account, FileSystemRights[] rights, AccessControlType controlType)
        {
            // Create a new DirectoryInfo object.
            DirectoryInfo dInfo = new DirectoryInfo(folderName);

            // Get a DirectorySecurity object that represents the current security settings.
            DirectorySecurity dSecurity = dInfo.GetAccessControl();

            // XN 16Sep13 73427 the securtiy rules need to be ordered in certain format, else error
            if (!dSecurity.AreAccessRulesCanonical)
                CanonicalizeDacl(dSecurity);

            // Add the FileSystemAccessRule to the security settings.
            foreach (var right in rights)
                dSecurity.AddAccessRule(new FileSystemAccessRule(account, right, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, controlType));

            // Set the new access settings.
            dInfo.SetAccessControl(dSecurity);

        }

        /// <summary>
        /// Removes an ACL entry on the specified directory for the specified account.
        /// </summary>
        /// <param name="FileName"></param>
        /// <param name="Account"></param>
        /// <param name="Rights"></param>
        /// <param name="ControlType"></param>
        public static void RemoveDirectorySecurity(string folderName, string account, FileSystemRights[] rights, AccessControlType controlType)
        {
            // Create a new DirectoryInfo object.
            DirectoryInfo dInfo = new DirectoryInfo(folderName);

            // Get a DirectorySecurity object that represents the current security settings.
            DirectorySecurity dSecurity = dInfo.GetAccessControl();

            // XN 16Sep13 73427 the securtiy rules need to be ordered in certain format, else error
            if (!dSecurity.AreAccessRulesCanonical)
                CanonicalizeDacl(dSecurity);

            // Add the FileSystemAccessRule to the security settings. 
            foreach (var right in rights)
                dSecurity.RemoveAccessRule(new FileSystemAccessRule(account, right, controlType));

            // Set the new access settings.
            dInfo.SetAccessControl(dSecurity);
        }

        /// <summary>
        /// XN 16Sep13 73427
        /// A canonical ACL must have ACES sorted according to the following order:
        ///     1. Access-denied on the object
        ///     2. Access-denied on a child or property
        ///     3. Access-allowed on the object
        ///     4. Access-allowed on a child or property
        ///     5. All inherited ACEs
        /// This fixes error message "Error 1001. This access control list is not in canonical form and therfore cannont be modified."
        /// Was only seen on Core-DSS2
        /// </summary>
        private static void CanonicalizeDacl(DirectorySecurity dSecurity)
        {
            RawSecurityDescriptor descriptor = new RawSecurityDescriptor(dSecurity.GetSecurityDescriptorSddlForm(AccessControlSections.Access));
 
            List<CommonAce> implicitDenyDacl        = new List<CommonAce>();
            List<CommonAce> implicitDenyObjectDacl  = new List<CommonAce>();
            List<CommonAce> inheritedDacl           = new List<CommonAce>();
            List<CommonAce> implicitAllowDacl       = new List<CommonAce>();
            List<CommonAce> implicitAllowObjectDacl = new List<CommonAce>();
 
            foreach (CommonAce ace in descriptor.DiscretionaryAcl)
            {
                if ((ace.AceFlags & AceFlags.Inherited) == AceFlags.Inherited) 
                    inheritedDacl.Add(ace);
                else
                {
                    switch (ace.AceType)
                    {
                    case AceType.AccessAllowed:         implicitAllowDacl.Add       (ace);  break;
                    case AceType.AccessDenied:          implicitDenyDacl.Add        (ace);  break;
                    case AceType.AccessAllowedObject:   implicitAllowObjectDacl.Add (ace);  break;
                    case AceType.AccessDeniedObject:    implicitDenyObjectDacl.Add  (ace);  break;
                    }
                }
            }
 
            Int32 aceIndex = 0;
            RawAcl newDacl = new RawAcl(descriptor.DiscretionaryAcl.Revision, descriptor.DiscretionaryAcl.Count);
            implicitDenyDacl.ForEach        (x => newDacl.InsertAce(aceIndex++, x));
            implicitDenyObjectDacl.ForEach  (x => newDacl.InsertAce(aceIndex++, x));
            implicitAllowDacl.ForEach       (x => newDacl.InsertAce(aceIndex++, x));
            implicitAllowObjectDacl.ForEach (x => newDacl.InsertAce(aceIndex++, x));
            inheritedDacl.ForEach           (x => newDacl.InsertAce(aceIndex++, x));
 
            descriptor.DiscretionaryAcl = newDacl;
            dSecurity.SetSecurityDescriptorSddlForm(descriptor.GetSddlForm(AccessControlSections.Access), AccessControlSections.Access);
        }

        void EncryptConfigFileSection(string section, string site, string application, string folder, System.Collections.Generic.IEnumerable<string> files)
        {
            // Unfortunately aspnet_regiis won't encrypt a config section unless it's defnition is part of the framework so if we are encrypting
            // a custom section (encryptionSettings for instance) the assembly that defines the section and it's dependents must be in the framework
            // folder.  So in this method we copy the assemblies, run the encyption command and then delete the assemblies we copied over
            string frameworkDir = string.Format(@"{0}\Microsoft.Net\Framework\v4.0.30319\", System.Environment.GetEnvironmentVariable("SystemRoot"));

            // RK - Identity files to copy by ignoring files that already exist in the target location
            List<string> filesToCopy = new List<string>();
            foreach (var fileName in files)
            {
                if (!File.Exists(Path.Combine(frameworkDir, fileName)))
                {
                    filesToCopy.Add(fileName);
                }
            }

            foreach (var fileName in filesToCopy)
            {
                File.Copy(Path.Combine(folder, fileName), Path.Combine(frameworkDir, fileName));
            }

            var siteId = site.Substring(site.LastIndexOf("/") + 1);
            System.Diagnostics.EventLog.WriteEntry("EHSC Installer", "Command :" + Path.Combine(frameworkDir, "aspnet_regiis.exe") + string.Format(@" -pe ""{0}"" -app ""/{1}"" -site ""{2}""", section, application, siteId));

            var info = new ProcessStartInfo();
            info.FileName = Path.Combine(frameworkDir, "aspnet_regiis.exe");
            info.Arguments = string.Format(@"-pe ""{0}"" -app ""/{1}"" -site ""{2}""", section, application, siteId);
            info.CreateNoWindow = true;
            info.UseShellExecute = false;

            var p = Process.Start(info);
            p.WaitForExit(60000);
            if (!p.HasExited)
            {
                p.Kill();
            }

            foreach (var fileName in filesToCopy)
            {
                File.Delete(Path.Combine(frameworkDir, fileName));
            }
        }

		/// <summary>
		/// The get client type.
		/// </summary>
		/// <returns>
		/// The <see cref="ClientType"/>.
		/// </returns>
		private ClientType GetClientType()
		{
			ClientType clientType = ClientType.Live;
			if (Context.Parameters["CLIENTTYPE"].ToUpper() == "TESTING")
				clientType = ClientType.Testing;
			else if (Context.Parameters["CLIENTTYPE"].ToUpper() == "TRAINING")
				clientType = ClientType.Training;
			return clientType;
		}
    }
}
