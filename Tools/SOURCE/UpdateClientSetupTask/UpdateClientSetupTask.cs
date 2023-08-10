using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using System.Text.RegularExpressions;

namespace Ascribe.ICW.BuildTasks
{
    // UpdateClientSetupTask
    // ---------------------
    //
    // More hackery into the build I'm afraid!  This time we're changing the client setup .vdproj files
    // to look in the place where the build has taken place for the 6 files
    //

    public class UpdateClientSetupTask : Task
    {

        private string m_BuildRootPath = string.Empty;
        private string m_SetupProjectPath = string.Empty;
        private int m_SetupType = 1; // 1 - Live, 2 - Testing, 3 - Training
        private string m_Branch = string.Empty;
        private string m_Build = string.Empty;
        private string m_ProjectName = string.Empty;
        private string m_ProductName = string.Empty; 

        public override bool Execute()
        {
            if (m_BuildRootPath == string.Empty)
            {
                Log.LogMessage("No build root path has been specified");
                return false;
            }

            if (m_SetupProjectPath == string.Empty)
            {
                Log.LogMessage("No path has been specified for the setup projects");
                return false;
            }

            if (m_Branch == string.Empty)
            {
                Log.LogMessage("No Branch has been specified for the build");
                return false;
            }

            if (m_Build == string.Empty)
            {
                Log.LogMessage("No Build No has been specified for the build");
                return false;
            }

            if (m_ProductName == string.Empty)
            {
                Log.LogMessage("No product name has been specified for the build");
                return false;
            }

            try
            {
                if (string.IsNullOrEmpty(m_ProjectName))
                {
                    GetProjectName();
                }

                UpdateProjectFile();
                UpdateClientRegistryNames();
                UpdateClientCustom();

                return true;
            }
            catch (Exception ex)
            {
                Log.LogMessage("UpdateClientSetupTask failed with the message: " + ex.Message);
                return false;
            }
        }

        private void UpdateClientRegistryNames()
        {
            string[] fileContent;
            StringBuilder UpdatedNames = new StringBuilder();
            try
            {
                using (StreamReader rdr = new StreamReader(m_SetupProjectPath + @"\Client Files\ClientOCXRegistryNames.txt"))
                {
                    fileContent = rdr.ReadToEnd().Split(',');
                    rdr.Close();
                }

                for (var i = 0; i < fileContent.Length; i++)
                {
                    if (i > 0)
                    {
                        UpdatedNames.Append(",");
                    }
                    var temp = fileContent[i];
                    UpdatedNames.Append(GetVersionedName(temp.Trim()));
                }
            }
            catch (Exception ex)
            {
                throw new Exception("read failed");
            }

            try
            {
                // Then write it back and hope for the best.........
                File.SetAttributes(m_SetupProjectPath + @"\Client Files\ClientOCXRegistryNames.txt", FileAttributes.Normal);
                File.Delete(m_SetupProjectPath + @"\Client Files\ClientOCXRegistryNames.txt");
            }
            catch (Exception ex)
            {
                throw new Exception("delete failed");
            }

            try
            {

                using (StreamWriter wrt = new StreamWriter(m_SetupProjectPath + @"\Client Files\ClientOCXRegistryNames.txt"))
                {
                    wrt.Write(UpdatedNames);
                    wrt.Flush();
                    wrt.Close();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("write failed");
            }
        }
        private void GetProjectName()
        {
            switch (m_SetupType)
            {
                case 1:
                    m_ProjectName = "Client Setup.vdproj";
                    break;

                case 2:
                    m_ProjectName = "Client Setup - Testing.vdproj";
                    break;

                case 3:
                    m_ProjectName = "Client Setup - Training.vdproj";
                    break;
            }
        }

        private void UpdateProjectFile()
        {
            // First read in the contents of the file
            string fileContent = string.Empty;

            using (StreamReader rdr = new StreamReader(m_SetupProjectPath + @"\" + m_ProjectName))
            {
                fileContent = rdr.ReadToEnd();
                rdr.Close();
            }

            // Then change the product version
            string version = ProjectVersion();

            string versionWithFinalPart = version + "." + GetFinalBuildPart();

            fileContent = fileContent.Replace("\"ProductVersion\" = \"8:1.0.0\"", "\"ProductVersion\" = \"8:" + version + "\"");

            fileContent = fileContent.Replace("Client Custom.dll", GetVersionedName("Client Custom.dll"));

            switch (m_SetupType)
            {
                case 1:
                    // Then change the product name and add the version info to the live client and live admin client
                    fileContent = fileContent.Replace("\"ProductName\" = \"8:ICW Client - LIVE\"", "\"ProductName\" = \"8:" + m_ProductName + " Client - LIVE - " + versionWithFinalPart + "\"");
                    fileContent = fileContent.Replace("\"Title\" = \"8:ICW Client\"", "\"Title\" = \"8:" + m_ProductName + " Client\"");
                    break;
                case 2:
                    // Then change the product name and add the version info to the Testing client and Testing admin client
                    fileContent = fileContent.Replace("\"ProductName\" = \"8:ICW Client - Testing\"", "\"ProductName\" = \"8:" + m_ProductName + " Client - Testing - " + versionWithFinalPart + "\"");
                    fileContent = fileContent.Replace("\"Title\" = \"8:ICW Client\"", "\"Title\" = \"8:" + m_ProductName + " Client - Testing\"");
                    break;
                case 3:
                    // Then change the product name and add the version info to the Training client and Training admin client
                    fileContent = fileContent.Replace("\"ProductName\" = \"8:ICW Client - Training\"", "\"ProductName\" = \"8:" + m_ProductName + " Client - Training - " + versionWithFinalPart + "\"");
                    fileContent = fileContent.Replace("\"Title\" = \"8:ICW Client\"", "\"Title\" = \"8:" + m_ProductName + " Client - Training\"");
                    break;

            }

            //Add version to msi filename.
            fileContent = fileContent.Replace(".msi", " - " + versionWithFinalPart + ".msi");
                        
            // Then change the Product Code GUID of the live client 
            //fileContent = fileContent.Replace("\"ProductCode\" = \"8:{3D124EAA-C78C-48B7-B96A-C32A14B7AFE3}\"", "\"ProductCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");
            fileContent = Regex.Replace(fileContent, "\"ProductCode\" = \"8:" + @"[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]" + "\"", "\"ProductCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");

            
            // Then change the Package Code GUID of the live client and live admin client
            //fileContent = fileContent.Replace("\"PackageCode\" = \"8:{9ABD35CB-6E21-4894-AED2-E3C61E917BD2}\"", "\"PackageCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");
            fileContent = Regex.Replace(fileContent, "\"PackageCode\" = \"8:" + @"[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]" + "\"", "\"PackageCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");

            // Then change the Upgrade Code GUID of the live client
            //fileContent = fileContent.Replace("\"UpgradeCode\" = \"8:{5AC8F548-87F8-42FC-AF2D-D66FCB15C168}\"", "\"UpgradeCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");
            fileContent = Regex.Replace(fileContent, "\"UpgradeCode\" = \"8:" + @"[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]" + "\"", "\"UpgradeCode\" = \"8:{" + Guid.NewGuid().ToString().ToUpper() + "}\"");

            // Then the location of the files
            UpdateClientFileLocations(ref fileContent);

            // Then write it back and hope for the best.........
            File.SetAttributes(m_SetupProjectPath + @"\" + m_ProjectName, FileAttributes.Normal);
            File.Delete(m_SetupProjectPath + @"\" + m_ProjectName);
            using (StreamWriter wrt = new StreamWriter(m_SetupProjectPath + @"\" + m_ProjectName))
            {
                wrt.Write(fileContent);
                wrt.Flush();
                wrt.Close();
            }
        }

        private string ProjectVersion()
        {
            string[] numbers = m_Build.Split('.');
            return (numbers.Length >= 3) ? numbers[0] + "." + numbers[1] + "." + numbers[2] : "00.00.00";
        }

        private string GetFinalBuildPart()
        {
            string[] version = m_Build.Split('.');
            return (version.Length >= 4) ? version[3] : "0";
        }

        private void UpdateClientFileLocations(ref string fileContent)
        {
            StringBuilder buildPath = new StringBuilder();

            buildPath.Append(m_BuildRootPath.Replace(@"\", @"\\"));
            buildPath.Append(@"\\");
            buildPath.Append("Build_");
            buildPath.Append(m_Branch);
            buildPath.Append("-");
            buildPath.Append(m_Build);


            StringBuilder setupPath = new StringBuilder();
            setupPath.Append(m_SetupProjectPath.Replace(@"\", @"\\"));

            switch (m_SetupType)
            {
                case 1:
                    buildPath.Append(@"\\L\\");
                    break;
                case 2:
                    buildPath.Append(@"\\T\\");
                    break;
                case 3:
                    buildPath.Append(@"\\R\\");
                    break;
            }

            // Right so we know where the files SHOULD be when they've built and we know where the file says they are so it's just a simple replace
            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\DispensingCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("DispensingCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\DispensingCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("DispensingCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:DispensingCtl.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("DispensingCtl.ocx") + "\"");



            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\RptDispCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("RptDispCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\RptDispCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("RptDispCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:RptDispCtl.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("RptDispCtl.ocx") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\PNCtl.ocx\"",
            "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("PNCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\PNCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("PNCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:PNCtl.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("PNCtl.ocx") + "\"");



            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\ICWManufact.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWManufact.exe") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\ICWManufact.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWManufact.exe") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:ICWManufact.exe\"",
              "\"TargetName\" = \"8:" + GetVersionedName("ICWManufact.exe") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\ICWStockTake.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWStockTake.exe") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\ICWStockTake.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWStockTake.exe") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:ICWStockTake.exe\"",
              "\"TargetName\" = \"8:" + GetVersionedName("ICWStockTake.exe") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\ICWStores.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWStores.exe") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\ICWStores.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("ICWStores.exe") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:ICWStores.exe\"",
              "\"TargetName\" = \"8:" + GetVersionedName("ICWStores.exe") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\AscribePrintJob.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("AscribePrintJob.exe") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\AscribePrintJob.exe\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\EXE\\\\bin\\\\" + GetVersionedName("AscribePrintJob.exe") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:AscribePrintJob.exe\"",
              "\"TargetName\" = \"8:" + GetVersionedName("AscribePrintJob.exe") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\Launcher.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("Launcher.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\Launcher.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("Launcher.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:Launcher.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("Launcher.ocx") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\PharmacyData.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\DLL\\\\bin\\\\" + GetVersionedName("PharmacyData.dll") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\PharmacyData.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\DLL\\\\bin\\\\" + GetVersionedName("PharmacyData.dll") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:PharmacyData.dll\"",
              "\"TargetName\" = \"8:" + GetVersionedName("PharmacyData.dll") + "\"");



            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\PharmacyWebData.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\DLL\\\\bin\\\\" + GetVersionedName("PharmacyWebData.dll") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\PharmacyWebData.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\DLL\\\\bin\\\\" + GetVersionedName("PharmacyWebData.dll") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:PharmacyWebData.dll\"",
              "\"TargetName\" = \"8:" + GetVersionedName("PharmacyWebData.dll") + "\"");



            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\ProductStockEditor.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("ProductStockEditor.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\ProductStockEditor.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("ProductStockEditor.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:ProductStockEditor.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("ProductStockEditor.ocx") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\StoresCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("StoresCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\StoresCtl.ocx\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + "SmartClient\\\\OCX\\\\bin\\\\" + GetVersionedName("StoresCtl.ocx") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:StoresCtl.ocx\"",
              "\"TargetName\" = \"8:" + GetVersionedName("StoresCtl.ocx") + "\"");


            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\..\\\\Pharmacy\\\\Printing-Web Client\\\\TxTextControl\\\\TextUserControl\\\\bin\\\\Release\\\\TextControlEditorWebClient.dll\"",
             "\"SourcePath\" = \"8:" + setupPath.ToString() + "\\\\..\\\\..\\\\..\\\\Binaries\\\\Install\\\\" + GetVersionedName("TextControlEditorWebClient.dll") + "\"");

			fileContent = fileContent.Replace("\"SourcePath\" = \"8:TextControlEditorWebClient.tlb\"",
			 "\"SourcePath\" = \"8:" + setupPath.ToString() + "\\\\..\\\\..\\\\..\\\\Binaries\\\\Install\\\\" + GetVersionedName("TextControlEditorWebClient.tlb") + "\"");

			fileContent = fileContent.Replace("\"TargetName\" = \"8:TextControlEditorWebClient.tlb\"",
			 "\"TargetName\" = \"8:" + GetVersionedName("TextControlEditorWebClient.tlb") + "\"");
                       
            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\..\\\\bin\\\\TextControlEditorPharmacyClient.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + @"bin\\" + GetVersionedName("TextControlEditorPharmacyClient.dll") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:Client Files\\\\WCFDataClient.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + @"COM\\Pharmacy Source\\Web Transport\\DataWCFClient\\bin\\Release\\" + GetVersionedName("WCFDataClient.dll") + "\"");

            fileContent = fileContent.Replace("\"SourcePath\" = \"8:..\\\\Client Setup\\\\Client Files\\\\WCFDataClient.dll\"",
              "\"SourcePath\" = \"8:" + buildPath.ToString() + @"COM\\Pharmacy Source\\Web Transport\\DataWCFClient\\bin\\Release\\" + GetVersionedName("WCFDataClient.dll") + "\"");

            fileContent = fileContent.Replace("\"TargetName\" = \"8:WCFDataClient.dll\"",
              "\"TargetName\" = \"8:" + GetVersionedName("WCFDataClient.dll") + "\"");

            fileContent = fileContent.Replace("\"Arguments\" = \"8:/register /codebase WCFDataClient.dll\"",
              "\"Arguments\" = \"8:/register /codebase " + GetVersionedName("WCFDataClient.dll") + "\"");
        }

        private string GetVersionedFolder()
        {
            StringBuilder versionedName = new StringBuilder();

            switch (m_SetupType)
            {
                case 1:
                    versionedName.Append("L");
                    break;
                case 2:
                    versionedName.Append("T");
                    break;
                case 3:
                    versionedName.Append("R");
                    break;
            }

            string derivedVersion = string.Empty;

            string[] version = m_Build.Split('.');

            for (int i = 0; i <= 2 && version.Length > i; i++)
            {
                derivedVersion += version[i];
            }

            versionedName.Append(derivedVersion);

            string derivedBuild = string.Empty;

            if (version.Length >= 4)
            {
                for (int i = 3 - version[3].Length; i >= 1; i--)
                    derivedBuild += "0";
                derivedBuild += version[3];
            }
            else
            {
                derivedBuild = "000";
            }

            versionedName.Append(derivedBuild);

            return versionedName.ToString();
        }

        private string GetVersionedName(string fileName)
        {
            StringBuilder versionedName = new StringBuilder();

            switch (m_SetupType)
            {
                case 1:
                    versionedName.Append("L");
                    break;
                case 2:
                    versionedName.Append("T");
                    break;
                case 3:
                    versionedName.Append("R");
                    break;
            }

            string derivedVersion = string.Empty;

            string[] version = m_Build.Split('.');

            for (int i = 0; i <= 2 && version.Length > i; i++)
            {
                derivedVersion += version[i];
            }

            versionedName.Append(derivedVersion);
            versionedName.Append(Path.GetFileNameWithoutExtension(fileName));

            string derivedBuild = string.Empty;

            if (version.Length >= 4)
            {
                for (int i = 3 - version[3].Length; i >= 1; i--)
                    derivedBuild += "0";
                derivedBuild += version[3];
            }
            else
            {
                derivedBuild = "000";
            }

            versionedName.Append(derivedBuild);
            versionedName.Append(Path.GetExtension(fileName));

            return versionedName.ToString();
        }

        private void UpdateClientCustom()
        {
            string fileContent = string.Empty;

            using (StreamReader rdr = new StreamReader(m_SetupProjectPath + @"..\..\Client Custom\Client Custom.csproj"))
            {
                fileContent = rdr.ReadToEnd();
                rdr.Close();
            }

            var start = fileContent.IndexOf("<AssemblyName>") + 14;
            var end = fileContent.IndexOf("</AssemblyName>");
            fileContent = fileContent.Remove(start, end - start);
            fileContent = fileContent.Insert(start, GetVersionedName("Client Custom"));

            File.SetAttributes(m_SetupProjectPath + @"..\..\Client Custom\Client Custom.csproj", FileAttributes.Normal);
            File.Delete(m_SetupProjectPath + @"..\..\Client Custom\Client Custom.csproj");
            using (StreamWriter wrt = new StreamWriter(m_SetupProjectPath + @"..\..\Client Custom\Client Custom.csproj"))
            {
                wrt.Write(fileContent);
                wrt.Flush();
                wrt.Close();
            }
        }

        #region Properties

        public string BuildRootPath
        {
            get { return m_BuildRootPath; }
            set { m_BuildRootPath = value; }
        }

        public string SetupProjectPath
        {
            get { return m_SetupProjectPath; }
            set { m_SetupProjectPath = value; }
        }

        public string BuildBranch
        {
            get { return m_Branch; }
            set { m_Branch = value; }
        }

        public string BuildNo
        {
            get { return m_Build; }
            set { m_Build = value; }
        }

        public int SetupType
        {
            get { return m_SetupType; }
            set { m_SetupType = value; }
        }

        public string ProjectName
        {
            get { return m_ProjectName; }
            set { m_ProjectName = value; }
        }

        public string ProductName
        {
            get { return m_ProductName; }
            set { m_ProductName = value; }
        }

        #endregion
    }
}
