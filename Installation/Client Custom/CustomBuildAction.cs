using System;
using System.Collections;
using System.ComponentModel;
using System.Configuration.Install;
using System.IO;
using System.Runtime.InteropServices;
using System.Security;
using IWshRuntimeLibrary;
using Client_Custom.Properties;
using System.Diagnostics;
using Microsoft.Win32;
using System.Collections.Generic;

[assembly: AllowPartiallyTrustedCallers]
namespace Ascribe.ICW.ClientInstaller
{
    /// <summary>
    /// Class to be used to provide any extra config for our client install.
    /// Currently just needs to create a local hta file if required
    /// Requiredness is determined by whether both the web server and web site boxes have been filled in
    /// </summary>
    /// 
    [RunInstaller(true)]
    public partial class CustomBuildAction : Installer
    {
        /// <summary>
        /// The configuration file.
        /// </summary>
        private string ConfigurationFile = "ClientInstallConfiguration.xml";	//configuration file
        private string ClientRegistryName = "ClientOCXRegistryNames.txt";
        //MM1192 - to install Microsoft C++ redistributary Package 2013 to support Tx text control dependency 
        private string RedistributaryPackage = "vcredist_x86.exe";
        private static bool is64BitProcess = (IntPtr.Size == 8);
        private static bool is64BitOperatingSystem = is64BitProcess || InternalCheckIsWow64();
        private static string classesRoot = is64BitOperatingSystem ? "HKEY_CLASSES_ROOT\\WOW6432Node\\CLSID\\" : "HKEY_CLASSES_ROOT\\CLSID\\";

        private string[] CommonRegFiles = {
                                              "WScript.Network",
                                              "Wscript.Shell",
                                              "Scripting.FileSystemObject",
                                              "Ascribe.ImagePrinting.DrugChartPrinter",
                                              "TextControlEditorWebClient.TextUserControlEditor",
                                            "TextControlEditorPharmacyClient.TxWrapper",
                                            "TextControlEditorPharmacyClient.HeEmulator",
                                            "TextControlEditorPharmacyClient.frmTextControlEditor",
                                            "TextControlEditorPharmacyClient.AcceleratorHelper"
                                          };

        /// <summary>
        /// The all users.
        /// </summary>
        enum AllUsers : int
        {
            /// <summary>
            /// The desktop.
            /// </summary>
            Desktop = 0,

            /// <summary>
            /// The startmenu.
            /// </summary>
            Startmenu
        }

        /// <summary>
        /// The client type.
        /// </summary>
        enum ClientType { Live, Testing, Training };

        /// <summary>
        /// Initializes a new instance of the <see cref="CustomBuildAction"/> class.
        /// </summary>
        public CustomBuildAction()
        {
            InitializeComponent();
        }

        /// <summary>
        /// The install.
        /// </summary>
        /// <param name="stateSaver">
        /// The state saver.
        /// </param>
        public override void Install(IDictionary stateSaver)
        {
            base.Install(stateSaver);

            string webServer;
            string webSite;

            string fixedTargetDir = Context.Parameters["TARGETDIR"].Trim().TrimEnd('\\');
            addRedistributaryPackage(fixedTargetDir);                   //MM-1192
            bool useHTTPS = true;                                      //+ GB TFS 83989
            string http = "http";                                       //+ GB TFS 83989

            if (Context.Parameters.ContainsKey("INSTALLTYPE") && Context.Parameters["INSTALLTYPE"].ToUpper() == "ADMIN")
            {
                var cfg = new Configuration(fixedTargetDir + "\\Configuration\\Resources\\" + ConfigurationFile);	//create XML reader, read XML file

                webServer = cfg.WebServer;
                webSite = cfg.WebSite;

                Boolean.TryParse(cfg.UseHTTPS, out useHTTPS);           //+ GB TFS 83989
            }
            else
            {
                webServer = Context.Parameters["WEBSERVER"];
                webSite = Context.Parameters["WEBSITE"];
                useHTTPS = (Context.Parameters["OPTUSEHTTPS"] != "0");  //+ GB TFS 83989
            }

            //+ GB TFS 83989
            if (useHTTPS)
            {
                http = "https";
            }

            var linkNameNoExtension = GetHtaFileNameNoExtension(Context.Parameters["prodName"], GetClientType());
            var iconFilePath = MakeIconFileProductSpecific(fixedTargetDir, Context.Parameters["prodName"]);
            string vbsPath = Path.Combine(fixedTargetDir, linkNameNoExtension + ".vbs");

            if (string.IsNullOrEmpty(webServer) || string.IsNullOrEmpty(webSite))
                return;

            this.CreateLocalLinkFile(webServer, webSite, fixedTargetDir, linkNameNoExtension, http);

            createDesktopShortcut(linkNameNoExtension, vbsPath, iconFilePath);

            // Below is the vbs file association commands 

            #region Run Release scripts for 10.23

            var cmd = "assoc .vbs=VBSFile";
            Process p = new Process();
            ProcessStartInfo startInfo = new ProcessStartInfo("CMD");
            startInfo.Verb = "runas";
            startInfo.Arguments = "/user:Administrator /qb ALLUSERS=1 \"cmd /C " + cmd;
            startInfo.CreateNoWindow = true;
            startInfo.UseShellExecute = false;
            startInfo.WindowStyle = ProcessWindowStyle.Hidden;
            startInfo.RedirectStandardOutput = true;
            p.StartInfo = startInfo;
            p.Start();
            p.Close();


            #endregion Run Release scripts for 10.23
        }

        //MM1192
        private void addRedistributaryPackage(string fixedTargetDir)
        {
            Process process = new Process();
            ProcessStartInfo info = new ProcessStartInfo();
            try
            {
                info.UseShellExecute = false;
                info.CreateNoWindow = true;
                info.WindowStyle = ProcessWindowStyle.Hidden;
                info.Arguments = "/i /a /quiet";
                info.FileName = fixedTargetDir + "\\" + RedistributaryPackage;
                process.StartInfo = info;
                process.Start();
            }
            catch { }
            finally
            {
                process.Dispose();
            }
        }

        protected override void OnAfterInstall(IDictionary savedState)
        {
            base.OnAfterInstall(savedState);

            try
            {
                string fixedTargetDir = Context.Parameters["TARGETDIR"].Trim().TrimEnd('\\');
                string[] RegFileNamesPharm;

                using (StreamReader reader = new StreamReader(fixedTargetDir + "\\" + ClientRegistryName))
                {
                    RegFileNamesPharm = reader.ReadToEnd().Split(',');
                }

                List<string> PharmRegFilesCLSID = new List<string>();
                List<string> CommonRegFilesCLSID = new List<string>();

                foreach (string file in CommonRegFiles)
                {
                    var CLSID = SearchRegistryForCLSID(file.Trim());
                    if (CLSID != null)
                    {
                        CommonRegFilesCLSID.Add(CLSID);
                    }
                }

                foreach (string file in RegFileNamesPharm)
                {
                    var CLSID = SearchRegistryForCLSID(file.Trim());
                    if (CLSID != null)
                    {
                        PharmRegFilesCLSID.Add(CLSID);
                    }
                }

                AddingPermissionForCommonRegKeysUsingsubinacl(CommonRegFilesCLSID);
                checkForImplementedCategoriesSubKey(CommonRegFilesCLSID);
                AddingPermissionForCommonRegKeys(CommonRegFilesCLSID);

                MarkControlSafeForScriptingAndInitializing(PharmRegFilesCLSID);
                MarkControlSafeForScriptingAndInitializing(CommonRegFilesCLSID);

                AddingPermissionForRegGuids(CommonRegFilesCLSID);
            }
            catch (Exception e)
            {
                EventLog.WriteEntry("Emis Pharmacy Client Installer", "Exception is :" + e.Message + "\r\n. Stack trace " + e.StackTrace);
                throw e;
            }
        }


        protected override void OnBeforeUninstall(IDictionary savedState)
        {
            base.OnBeforeUninstall(savedState);

            try
            {
                List<string> CommonRegFilesCLSID = new List<string>();

                foreach (string file in CommonRegFiles)
                {
                    var CLSID = SearchRegistryForCLSID(file);
                    if (CLSID != null)
                    {
                        CommonRegFilesCLSID.Add(CLSID);
                    }
                }

                RemoveSafeForScriptingAndInitializing(CommonRegFilesCLSID);
            }
            catch (Exception e)
            {
                EventLog.WriteEntry("Emis Pharmacy Client Uninstaller", "Exception is :" + e.Message + "\r\n. Stack trace " + e.StackTrace);
                throw e;
            }
        }

        /// <summary>
        /// The uninstall.
        /// </summary>
        /// <param name="savedState">
        /// The saved state.
        /// </param>
        public override void Uninstall(IDictionary savedState)
        {
            base.Uninstall(savedState);

            ClientType clientType = ClientType.Live;
            if (Context.Parameters["CLIENTTYPE"].ToUpper() == "TESTING")
                clientType = ClientType.Testing;
            else if (Context.Parameters["CLIENTTYPE"].ToUpper() == "TRAINING")
                clientType = ClientType.Training;

            RemoveLocalLinkFile(Context.Parameters["TARGETDIR"].Trim().TrimEnd('\\'), Context.Parameters["TARGETDIR"], clientType);
            RemoveProductSpecificIconFile(Context.Parameters["TARGETDIR"].Trim().TrimEnd('\\'), Context.Parameters["prodName"]);
        }


        public static string SearchRegistryForCLSID(string OCXName)
        {
            RegistryKey t_clsidKey = Registry.ClassesRoot.OpenSubKey(OCXName);
            if (t_clsidKey != null)
            {
                foreach (var subKey_loopVariable in t_clsidKey.GetSubKeyNames())
                {
                    if (subKey_loopVariable.ToUpperInvariant() == "CLSID")
                    {
                        RegistryKey t_clsidSubKey = Registry.ClassesRoot.OpenSubKey(OCXName + "\\" + subKey_loopVariable);
                        return t_clsidSubKey.GetValue(null).ToString();
                    }
                }
            }
            return "";
        }

        private void AddingPermissionForCommonRegKeysUsingsubinacl(List<string> CommonRegFilesCLSID)
        {
            string command1 = "";
            string command2 = "";
            string path = "";


            path = Context.Parameters["TARGETDIR"].Trim().TrimEnd('\\') + @"\Configuration\Resources\";


            foreach (var CLSID in CommonRegFilesCLSID)
            {
                if (is64BitOperatingSystem)
                {
                    command1 = string.Format(@"subinacl.exe  /keyreg HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{0} /setowner=administrators", CLSID);
                    command2 = string.Format(@"subinacl.exe  /keyreg HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{0} /grant=administrators=f /setowner=administrators", CLSID);
                }
                else
                {
                    command1 = string.Format(@"subinacl.exe  /keyreg HKEY_CLASSES_ROOT\CLSID\{0} /setowner=administrators", CLSID);
                    command2 = string.Format(@"subinacl.exe  /keyreg HKEY_CLASSES_ROOT\CLSID\{0} /grant=administrators=f /setowner=administrators", CLSID);
                }

                ProcessStartInfo ProcessInfo;
                Process Process;
                ProcessInfo = new ProcessStartInfo("cmd.exe");
                ProcessInfo.RedirectStandardInput = true;
                ProcessInfo.CreateNoWindow = true;
                ProcessInfo.WindowStyle = ProcessWindowStyle.Normal;
                ProcessInfo.UseShellExecute = false;
                Process = Process.Start(ProcessInfo);


                using (StreamWriter sw = Process.StandardInput)
                {
                    if (sw.BaseStream.CanWrite)
                    {
                        sw.WriteLine(@"cd " + path);
                        sw.WriteLine(command1);
                        sw.WriteLine(command2);
                    }
                }
            }

        }

        private static void checkForImplementedCategoriesSubKey(List<string> CommonRegFilesCLSID)
        {
            var isFolderAvailable = false;
            foreach (var CLSID in CommonRegFilesCLSID)
            {
                RegistryKey t_clsidKey = Registry.ClassesRoot.OpenSubKey("");
                foreach (var subKey_loopVariable in t_clsidKey.GetSubKeyNames())
                {
                    if (subKey_loopVariable.ToUpperInvariant() == "IMPLEMENTED CATEGORIES")
                    {
                        isFolderAvailable = true;
                    }
                    if (isFolderAvailable)
                    {
                        break;
                    }
                }
                if (!isFolderAvailable)
                {
                    AllowPermissiontoAddSubKey(CLSID);
                    createSubKey(CLSID);
                }
            }
        }

        private static void createSubKey(string CLSID)
        {
            var st2 = CLSID;
            var st3 = "\\Implemented Categories";

            var Format = string.Format("{0}{1}{2}", classesRoot, st2, st3);
            ExecuteCommand(string.Format(@"reg add ""{0}"" /f", Format));
        }

        private static void AllowPermissiontoAddSubKey(string CommonRegFilesCLSID)
        {
            string fileName = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString() + ".txt";
            var st1 = is64BitOperatingSystem ? "HKEY_CLASSES_ROOT\\WOW6432Node\\CLSID\\" : "HKEY_CLASSES_ROOT\\CLSID\\";

            using (StreamWriter writetext = new StreamWriter(fileName))
            {
                writetext.WriteLine(string.Format("{0}{1} [1 5 7 11 17]", st1, CommonRegFilesCLSID));
            }
            ExecuteCommand("regini " + fileName);
        }

        private static void MarkControlSafeForScriptingAndInitializing(List<string> CLSIDs)
        {
            foreach (var CLSID in CLSIDs)
            {
                var st2 = CLSID;
                var st3 = "\\Implemented Categories\\{7DD95801-9882-11CF-9FA9-00AA006C42C4}"; //registry as safe for scripting
                var st4 = "\\Implemented Categories\\{7DD95802-9882-11CF-9FA9-00AA006C42C4}"; //safe for initializing from persistent data

                var commnadSafeForScripting = string.Format("{0}{1}{2}", classesRoot, st2, st3);
                ExecuteCommand(string.Format(@"reg add ""{0}"" /f", commnadSafeForScripting));

                var commnadSafeForinitializing = string.Format("{0}{1}{2}", classesRoot, st2, st4);
                ExecuteCommand(string.Format(@"reg add ""{0}"" /f", commnadSafeForinitializing));
            }
        }


        private static void RemoveSafeForScriptingAndInitializing(List<string> CLSIDs)
        {
            foreach (var CLSID in CLSIDs)
            {
                var st2 = CLSID;
                var st3 = "\\Implemented Categories\\{7DD95801-9882-11CF-9FA9-00AA006C42C4}"; //registry as safe for scripting
                var st4 = "\\Implemented Categories\\{7DD95802-9882-11CF-9FA9-00AA006C42C4}"; //safe for initializing from persistent data

                var Format = string.Format("{0}{1}{2}", classesRoot, st2, st3);
                ExecuteCommand(string.Format(@"reg delete ""{0}"" /f", Format));

                var format2 = string.Format("{0}{1}{2}", classesRoot, st2, st4);
                ExecuteCommand(string.Format(@"reg delete ""{0}"" /f", format2));
            }
        }


        //1 (to provide Administrators Full Access)
        //2 (to provide Administrators Read Access)
        //3 (to provide Administrators Read and Write Access )
        //4 (to provide Administrators Read, Write and Delete Access)
        //5 (to provide Creator/Owner Full Access)
        //6 (to provide Creator/Owner Read and Write Access)
        //7 (to provide Everyone Full Access)
        //8 (to provide Everyone Read Access)
        //9 (to provide Everyone Read and Write Access)
        //10 (to provide Everyone Read, Write and Delete Access)
        //17 (to provide System Full Access)
        //18 (to provide System Read and Write Access)
        //19 (to provide System Read Access)

        private static void AddingPermissionForCommonRegKeys(List<string> CommonRegFilesCLSID)
        {
            string fileName = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString() + ".txt";

            using (StreamWriter writetext = new StreamWriter(fileName))
            {
                foreach (var CLSID in CommonRegFilesCLSID)
                {
                    writetext.WriteLine(string.Format("{0}{1}\\Implemented Categories [1 5 7 11 17]", classesRoot, CLSID));
                }
            }
            ExecuteCommand("regini " + fileName);
        }

        private static void AddingPermissionForRegGuids(List<string> CommonRegFilesCLSID)
        {
            string fileName = System.IO.Path.GetTempPath() + Guid.NewGuid().ToString() + ".txt";

            using (StreamWriter writetext = new StreamWriter(fileName))
            {
                foreach (var CLSID in CommonRegFilesCLSID)
                {
                    writetext.WriteLine(string.Format("{0}{1}\\Implemented Categories\\{2} [1 5 7 11 17]", classesRoot, CLSID, "{7DD95801-9882-11CF-9FA9-00AA006C42C4}"));
                    writetext.WriteLine(string.Format("{0}{1}\\Implemented Categories\\{2} [1 5 7 11 17]", classesRoot, CLSID, "{7DD95802-9882-11CF-9FA9-00AA006C42C4}"));

                }
            }
            ExecuteCommand("regini " + fileName);
        }


        public static void ExecuteCommand(string Command)
        {
            ProcessStartInfo ProcessInfo;
            Process Process;
            ProcessInfo = new ProcessStartInfo("cmd.exe", "/c " + Command);
            ProcessInfo.CreateNoWindow = true;
            ProcessInfo.WindowStyle = ProcessWindowStyle.Hidden;
            ProcessInfo.UseShellExecute = true;
            Process = Process.Start(ProcessInfo);
        }



        /// <summary>
        /// The create local non hta file.
        /// </summary>
        /// <param name="webServer">
        /// The web server.
        /// </param>
        /// <param name="webSite">
        /// The web site.
        /// </param>
        /// <param name="path">
        /// The path.
        /// </param>
        /// <param name="fileName">
        /// The file name.
        /// </param>
        /// <exception cref="InstallException">
        /// </exception>
        private void CreateLocalLinkFile(string webServer, string webSite, string path, string fileName, string http)
        {
            string fullUrl = "[HTTP]://[WEBSERVER]/[WEBSITE]/LauncherController.aspx";

            fullUrl = fullUrl.Replace("[WEBSERVER]", webServer);
            fullUrl = fullUrl.Replace("[WEBSITE]", webSite);
            fullUrl = fullUrl.Replace("[HTTP]", http);                 //+ GB TFS 83989

            fullUrl = "\"C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe\"" + " --start-maximized --app=" + fullUrl + " -qn";

            string batchPath = Path.Combine(path, fileName + ".bat");
            if (System.IO.File.Exists(batchPath))
            {
                System.IO.File.Delete(batchPath);
            }
            using (StreamWriter w = new StreamWriter(batchPath))
            {
                w.WriteLine("@echo off");
                w.WriteLine(fullUrl);
                w.WriteLine("@echo on");
                w.Close();
            }

            string vbsPath = Path.Combine(path, fileName + ".vbs");
            if (System.IO.File.Exists(vbsPath))
            {
                System.IO.File.Delete(vbsPath);
            }

            try
            {
                using (StreamWriter w = new StreamWriter(vbsPath))
                {
                    w.WriteLine("Set WshShell = CreateObject(\"WScript.Shell\")");
                    w.WriteLine("WshShell.Run chr(34) & \"" + batchPath + "\" & Chr(34), 0");
                    w.WriteLine("Set WshShell = Nothing");
                    w.Close();
                }

            }
            catch
            {
                throw new InstallException("Unable to create link file");
            }

        }

        /// <summary>
        /// The remove local hta file.
        /// </summary>
        /// <param name="path">
        /// The path.
        /// </param>
        /// <param name="targetPath">
        /// The target path.
        /// </param>
        /// <param name="clientType">
        /// The client type.
        /// </param>
        /// <exception cref="InstallException">
        /// </exception>
        private void RemoveLocalLinkFile(string path, string targetPath, ClientType clientType)
        {
            string htaFileNameNoExtension = GetHtaFileNameNoExtension(Context.Parameters["prodName"], clientType);

            var batFile = System.IO.File.Exists(path + @"\" + htaFileNameNoExtension + ".bat");
            var vbsFile = System.IO.File.Exists(path + @"\" + htaFileNameNoExtension + ".vbs");

            try
            {
                if (batFile)
                {
                    System.IO.File.Delete(path + @"\" + htaFileNameNoExtension + ".bat");
                }

                if (vbsFile)
                {
                    System.IO.File.Delete(path + @"\" + htaFileNameNoExtension + ".vbs");
                }

                removeDesktopShortcut(htaFileNameNoExtension);
            }
            catch (Exception ex)
            {
                throw new InstallException("Removal of local hta file failed: " + ex.Message);
            }
        }

        /// <summary>
        /// The remove product specific icon file.
        /// </summary>
        /// <param name="iconPath">
        /// The icon path.
        /// </param>
        /// <param name="productName">
        /// The product name.
        /// </param>
        private void RemoveProductSpecificIconFile(string iconPath, string productName)
        {
            if (string.IsNullOrEmpty(productName))
            {
                return;
            }

            try
            {
                System.IO.File.Delete(GetIconFilePath(iconPath, productName));
            }
            catch (Exception)
            {
            }
        }

        /// <summary>
        /// The get hta file name no extension.
        /// </summary>
        /// <param name="productName">
        /// The product name.
        /// </param>
        /// <param name="clientType">
        /// The client type.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        private string GetHtaFileNameNoExtension(string productName, ClientType clientType)
        {
            switch (clientType)
            {
                case ClientType.Testing:
                    return GetVersionStringFromProductName("EHSCICWTesting", productName);

                case ClientType.Training:
                    return GetVersionStringFromProductName("EHSCICWTraining", productName);

                default:
                    return GetVersionStringFromProductName("EHSCICWLive", productName);
            }
        }

        /// <summary>
        /// Get product version string name 
        /// </summary>
        /// <param name="type">The product version type -Live/Testing/Training.</param>
        /// <param name="productName">The product name.</param>
        /// <returns>Product Version string name</returns>
        private string GetVersionStringFromProductName(string type, string productName)
        {
            string fileName = type;

            if (productName.Length > 0)
            {
                fileName = type + '_' + FindVersionStringFromProductName(productName);
            }
            return fileName;
        }


        /// <summary>
        /// The get icon file path.
        /// </summary>
        /// <param name="iconPath">
        /// The icon path.
        /// </param>
        /// <param name="productName">
        /// The product name.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        private string GetIconFilePath(string iconPath, string productName)
        {
            return string.Format(@"{0}\ASCRIBE{1}_{2}.ICO", iconPath, GetClientType().ToString(), FindVersionStringFromProductName(productName));
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

        /// <summary>
        /// The get special environment path.
        /// </summary>
        /// <param name="location">
        /// The location.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        private string GetSpecialEnvironmentPath(AllUsers location)
        {
            string result = string.Empty;

            switch (location)
            {
                case AllUsers.Desktop:
                    if (Environment.OSVersion.Version.Major > 4 && Environment.OSVersion.Version.Minor > 1)
                        result = Path.Combine(Environment.GetEnvironmentVariable("PUBLIC"), "Desktop");
                    else
                        result = Path.Combine(Environment.GetEnvironmentVariable("ALLUSERSPROFILE"), "Desktop");
                    break;
                case AllUsers.Startmenu:
                    if (Environment.OSVersion.Version.Major > 4 && Environment.OSVersion.Version.Minor > 1)
                        result = Path.Combine(Environment.GetEnvironmentVariable("PROGRAMDATA"), @"Microsoft\Windows\Start Menu");
                    else
                        result = Path.Combine(Environment.GetEnvironmentVariable("ALLUSERSPROFILE"), "Startmenü");
                    break;
                default:
                    result = "";
                    break;
            }

            return result;

        }

        /// <summary>
        /// The make icon file product specific.
        /// </summary>
        /// <param name="iconPath">
        /// The icon path.
        /// </param>
        /// <param name="productName">
        /// The product name.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        private string MakeIconFileProductSpecific(string iconPath, string productName)
        {
            if (string.IsNullOrEmpty(productName))
            {
                return string.Format(@"{0}\ASCRIBE.ICO", iconPath);
            }

            var newFileName = GetIconFilePath(iconPath, productName);
            System.IO.File.Copy(string.Format(@"{0}\ASCRIBE.ICO", iconPath), newFileName);
            return newFileName;
        }

        /// <summary>
        /// The hta shortcut to desktop.
        /// </summary>
        /// <param name="shortcutName">
        /// The shortcut name.
        /// </param>
        /// <param name="TargetPathandName">
        /// The target pathand name.
        /// </param>
        /// <param name="IconPathandName">
        /// The icon pathand name.
        /// </param>
        private void createDesktopShortcut(string shortcutName, string TargetPathandName, string IconPathandName)
        {
            string DirectoryPath = GetSpecialEnvironmentPath(AllUsers.Desktop);
            DirectoryInfo SpecialDir = new DirectoryInfo(DirectoryPath);
            FileInfo OriginalFile = new FileInfo(shortcutName);
            string NewFileName = SpecialDir.FullName + "\\" + OriginalFile.Name + ".lnk";
            FileInfo LinkFile = new FileInfo(NewFileName);

            if (LinkFile.Exists)
            {
                return;
            }

            WshShell shell = new WshShell();
            IWshShortcut link = (IWshShortcut)shell.CreateShortcut(LinkFile.FullName);
            link.TargetPath = TargetPathandName;
            link.IconLocation = IconPathandName;
            link.Save();
        }

        /// <summary>
        /// The remove hta desktop shortcut.
        /// </summary>
        /// <param name="shortcutName">
        /// The shortcut name.
        /// </param>
        private void removeDesktopShortcut(string shortcutName)
        {
            string DirectoryPath = GetSpecialEnvironmentPath(AllUsers.Desktop);
            DirectoryInfo SpecialDir = new DirectoryInfo(DirectoryPath);
            FileInfo OriginalFile = new FileInfo(shortcutName);
            string NewFileName = SpecialDir.FullName + "\\" + OriginalFile.Name + ".lnk";
            FileInfo LinkFile = new FileInfo(NewFileName);

            if (LinkFile.Exists)
            {
                System.IO.File.Delete(LinkFile.ToString());
            }
        }

        /// <summary>
        /// The find version string from product name.
        /// </summary>
        /// <param name="productName">
        /// The product name.
        /// </param>
        /// <returns>
        /// The <see cref="string"/>.
        /// </returns>
        private string FindVersionStringFromProductName(string productName)
        {
            string res = "Live";
            string[] splitProdNameStr = productName.Split('-');
            if (splitProdNameStr.Length > 2)
            {
                res = splitProdNameStr[2].Trim();
            }
            return res;
        }

        [DllImport("kernel32.dll", SetLastError = true, CallingConvention = CallingConvention.Winapi)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool IsWow64Process(
            [In] IntPtr hProcess,
            [Out] out bool wow64Process
        );

        public static bool InternalCheckIsWow64()
        {
            if ((Environment.OSVersion.Version.Major == 5 && Environment.OSVersion.Version.Minor >= 1) ||
                Environment.OSVersion.Version.Major >= 6)
            {
                using (Process p = Process.GetCurrentProcess())
                {
                    bool retVal;
                    if (!IsWow64Process(p.Handle, out retVal))
                    {
                        return false;
                    }
                    return retVal;
                }
            }
            else
            {
                return false;
            }
        }
    }
}
