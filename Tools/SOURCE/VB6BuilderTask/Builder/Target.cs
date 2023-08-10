using System;
using System.IO;
using System.Text.RegularExpressions;
using System.ComponentModel;
using System.Diagnostics;
using Microsoft.Win32;
using System.Collections.Generic;
using System.Linq;

namespace Ascribe.ICW.BuildTasks
{
  /// <summary>
  /// Summary description for Target.
  /// </summary>
  public class Target
  {
    /// <summary>File extensions for VB files that contain version numbers</summary>
    static readonly string[] versionSourceCodeExtensions = { "CLS", "BAS", "VBP", "BAT", "FRM", "ASPX", "VB", "JS", "CTL", "SLN", "CSPROJ" };


    public enum enmName
    {
      Source		//	Source 
    ,
      L			//	Live
        ,
      R			//	Training
        , T			//	Test
    }
    private enmName m_name;
    private DirectoryInfo m_directoryInfoParent = null;
    private DirectoryInfo m_directoryInfoTarget = null;
    Projects m_projects = null;
    List<string> netProjectFileNames = new List<string>();
    Build m_BuildParent = null;
    SourceSafe m_SourceSafe = null;
    Webpages m_webpages = null;
    Ocxcontrols m_ocxcontrols = null;

    public enmName Name
    {
      get { return m_name; }
      set { m_name = value; }
    }

    public DirectoryInfo DirectoryInfoTarget
    {
      get { return m_directoryInfoTarget; }
      set { m_directoryInfoTarget = value; }
    }

    public Build BuildParent
    {
      get { return m_BuildParent; }
      set { m_BuildParent = value; }
    }

    public Target( enmName Name, DirectoryInfo directoryInfoParent, Build buildParent, SourceSafe sourceSafe )
    {
      m_name = Name;
      m_BuildParent = buildParent;
      m_directoryInfoParent = directoryInfoParent;
      m_SourceSafe = sourceSafe;
    }

  	/// <summary>
    /// Create the target build
    /// </summary>
    public void Create()
    {
		switch (Name)
		{
			case enmName.Source:
				m_directoryInfoTarget = m_directoryInfoParent;
				break;

			case enmName.L:
				m_directoryInfoTarget = new DirectoryInfo(m_directoryInfoParent.FullName + @"\L");
				break;

			case enmName.R:
				m_directoryInfoTarget = new DirectoryInfo(m_directoryInfoParent.FullName + @"\R");
				break;

			case enmName.T:
				m_directoryInfoTarget = new DirectoryInfo(m_directoryInfoParent.FullName + @"\T");
				break;
		}


        // Search source folder tree for projects to include in the project build list
        LocateProjects();

        // Locate all ocx controls (.ocx) files in the directory structure and put into an array in the ocxcontrols class.
        LocateOCXFiles();

        // First unregister the OCX files
        // Incase already been built with this version
        foreach( Ocxcontrol ocxcontrol in m_ocxcontrols )
           ocxcontrol.UnregisterOCXControl(true);

        // Check each of the found ocx controls to see if they are registered on the system.
        CheckOCXRegistration();

          // Version all source code files within this target build
          VersionSouceCode();
          // Re-locate projects after DLL and VBP name change
          LocateProjects();

          // Locate all ocx controls (.ocx) files in the directory structure and put into an array in the ocxcontrols class.
          LocateOCXFiles();

          // Check each of the found ocx controls to see if they are registered on the system.
          CheckOCXRegistration();

        // Research dependancies
        ResearchProjectReferences();

        // Sort projects such that dependant projects are below the projects that they depend upon.
        this.SortProjectsByDependancy();

        // Make projects
        MakeProjects();

      // Update the webpage with the new guid from the registry
      //if( this.m_name != Target.enmName.L )
      //{
      //  UpdateWebpageControl();
      //}

      //switch( this.m_name )
      //{
      //  case Target.enmName.R:
      //  case Target.enmName.T:
      //    UpdateJSExecutableNames();
      //    break;
      //}

    }

  	public void UpdateWebPages()
    {
        if (this.m_name == enmName.Source) // If we're Source we aint doing nothing!
            return;

        switch (this.m_name)
        {
            case enmName.L:
                BuildParent.DirectoryInfoBuildRoot = new DirectoryInfo(BuildParent.DirectoryInfoBuildRoot.FullName + @"\L");
                break;

            case enmName.R :
                BuildParent.DirectoryInfoBuildRoot = new DirectoryInfo(BuildParent.DirectoryInfoBuildRoot.FullName + @"\R");
                break;

            case enmName.T :
                BuildParent.DirectoryInfoBuildRoot = new DirectoryInfo(BuildParent.DirectoryInfoBuildRoot.FullName + @"\T");
                break;
        }
        m_directoryInfoTarget = m_directoryInfoParent;

        // Locate all webpage (.aspx) files in the directory structure and put into an array in the webpages class.
        LocateWebpages();

        // Then update them
        UpdateWebpageControl();

        // And finally update the js files as well
        UpdateJSExecutableNames();

        // Finally unregister the OCX files (need to locate them first)
        LocateOCXFiles();
        foreach( Ocxcontrol ocxcontrol in m_ocxcontrols )
           ocxcontrol.UnregisterOCXControl(false);
    }

    public void GetSourceLatest()
    {
        // Set SourceSafe local folder to source folder

        if (this.m_SourceSafe.Enable)
        {
            
            if (m_SourceSafe.directoryInfoLocal.Exists)
                m_SourceSafe.directoryInfoLocal.Delete();
            m_SourceSafe.directoryInfoLocal.Create();

            // Set current SourceSafe project and working directory, for the purposes of checking out/in
            m_SourceSafe.SetCurrentProjectToRoot();
            m_SourceSafe.SetWorkingFolderToRoot();
            // Get latest versions of source code from SourceSafe
            m_SourceSafe.GetLatestRecursive("");
        }
    }

    /// <summary>
    /// Recursively search all folders in the target build, replacing source code occurances of DLL names, with 
    /// versioned DLL names
    /// </summary>
    private void VersionSouceCode()
    {
      m_BuildParent.SendLogMessage( "\r\nVersioning source code..." );

      VersionSouceCodeFolder(m_directoryInfoTarget, versionSourceCodeExtensions);

      VersionFileNames();
    }

    /// <summary>
    /// Version all source code files with a single folder
    /// </summary>
    /// <param name="directoryInfoThis"></param>
    /// <param name="astrExtensions"></param>
    private void VersionSouceCodeFolder( DirectoryInfo directoryInfoThis, string[] astrExtensions )
    {
      // Work through each file extension we're interested in
      foreach( string strExtension in astrExtensions )
      {
        // Create an array representing the files in this directory matching said extension
        FileInfo[] afileInfoContents = directoryInfoThis.GetFiles( "*." + strExtension );

        // Add projects into this build's project list, from the array of files found
        foreach( FileInfo fileInfo in afileInfoContents )
        {
            VersionSourceCodeFile(fileInfo);
        }
      }

      // Create an array representing the directories in this directory.
      DirectoryInfo[] adirectoryInfoContents = directoryInfoThis.GetDirectories();
      foreach( DirectoryInfo directoryInfoSub in adirectoryInfoContents )
      {
        VersionSouceCodeFolder( directoryInfoSub, astrExtensions );
      }
    }

    /// <summary>
    /// Search and replace DLL names in a single source file
    /// </summary>
    /// <param name="fileInfo"></param>
    private void VersionSourceCodeFile(FileInfo fileInfo)
    {
      string strContent;
      FileStream fileStream;
      byte[] abyteBuffer;

      // Read file from disk
      fileStream = fileInfo.OpenRead();
      abyteBuffer = new byte[fileStream.Length];
      fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
      strContent = System.Text.Encoding.Default.GetString( abyteBuffer );

      fileStream.Close();

      // Replace DLL names
      foreach (Project project in this.m_projects)
      {
          strContent = Regex.Replace(strContent, project.ShortName, project.VersionedName, RegexOptions.IgnoreCase);
      }

      File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
      // Write file back to disk
      fileInfo.Delete();
      fileStream = fileInfo.OpenWrite();
      abyteBuffer = System.Text.Encoding.Default.GetBytes( strContent );
      fileStream.Write( abyteBuffer, 0, abyteBuffer.Length );
      fileStream.Close();
    }

    /// <summary>
    /// Locates the V2 DrugConversion project and replaces the existing output filename 
    /// with one that contains the version number e.g. L1005DrugConversion001.exe
    /// This method is a cut down version of the VersionSourceCodeFile, and is only 
    /// used when building the live version, as this precess is normally done with 
    /// VersionSourceCodeFile just pharamacy live files don't use this nameing convention.
    /// </summary>
    //private void VersionPharmacyConversionTool()
    //{
    //    m_BuildParent.SendLogMessage("\r\nVersioning pharmacy conversion tool source code...");

    //    // Find the drug conversion project
    //    Project projectPharmacyConversion = null;
    //    foreach (Project project in this.m_projects)
    //    {
    //        if (project.FileInfoPrjFile.FullName.Contains("DrugConversion"))
    //        {
    //            projectPharmacyConversion = project;
    //            break;
    //        }
    //    }

    //    if (projectPharmacyConversion != null)
    //    {
    //        string strContent;
    //        FileStream fileStream;
    //        byte[] abyteBuffer;

    //        // Read file from disk
    //        fileStream = projectPharmacyConversion.FileInfoPrjFile.OpenRead();
    //        abyteBuffer = new byte[fileStream.Length];
    //        fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //        strContent = System.Text.Encoding.Default.GetString(abyteBuffer);

    //        fileStream.Close();

    //        // Replace names
    //        strContent = Regex.Replace(strContent, projectPharmacyConversion.ShortName, projectPharmacyConversion.VersionedName, RegexOptions.IgnoreCase);

    //        File.SetAttributes(projectPharmacyConversion.FileInfoPrjFile.FullName, FileAttributes.Normal);
    //        // Write file back to disk
    //        projectPharmacyConversion.FileInfoPrjFile.Delete();
    //        fileStream = projectPharmacyConversion.FileInfoPrjFile.OpenWrite();
    //        abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
    //        fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
    //        fileStream.Close();

    //        // Rename the binary file   
    //        projectPharmacyConversion.BinaryFileInfo.MoveTo(projectPharmacyConversion.BinaryFileInfo.DirectoryName + @"\" + projectPharmacyConversion.VersionedName + projectPharmacyConversion.BinaryFileInfo.Extension);
    //    }
    //    else
    //    {
    //        m_BuildParent.SendLogMessage("\r\nError: Failed to find DrugConversion tool...");
    //    }
    //}

    /// <summary>
    /// Locates the V2 DrugConversion project and replaces the existing output filename 
    /// with one that contains the version number e.g. L1005DrugConversion001.exe
    /// This method is a cut down version of the VersionSourceCodeFile, and is only 
    /// used when building the live version, as this precess is normally done with 
    /// VersionSourceCodeFile just pharamacy live files don't use this nameing convention.
    /// </summary>
    //private void VersionV8PharmacyConversionTool()
    //{
    //    m_BuildParent.SendLogMessage("\r\nVersioning V8 pharmacy conversion tool source code...");

    //    // Find the drug conversion project
    //    Project projectPharmacyConversion = null;
    //    foreach (Project project in this.m_projects)
    //    {
    //        if (project.FileInfoPrjFile.FullName.Contains("v8dataconv"))
    //        {
    //            projectPharmacyConversion = project;
    //            break;
    //        }
    //    }

    //    if (projectPharmacyConversion != null)
    //    {
    //        string strContent;
    //        FileStream fileStream;
    //        byte[] abyteBuffer;

    //        // Read file from disk
    //        fileStream = projectPharmacyConversion.FileInfoPrjFile.OpenRead();
    //        abyteBuffer = new byte[fileStream.Length];
    //        fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //        strContent = System.Text.Encoding.Default.GetString(abyteBuffer);

    //        fileStream.Close();

    //        // Replace names
    //        strContent = Regex.Replace(strContent, projectPharmacyConversion.ShortName, projectPharmacyConversion.VersionedName, RegexOptions.IgnoreCase);

    //        File.SetAttributes(projectPharmacyConversion.FileInfoPrjFile.FullName, FileAttributes.Normal);
    //        // Write file back to disk
    //        projectPharmacyConversion.FileInfoPrjFile.Delete();
    //        fileStream = projectPharmacyConversion.FileInfoPrjFile.OpenWrite();
    //        abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
    //        fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
    //        fileStream.Close();

    //        // Rename the binary file   
    //        projectPharmacyConversion.BinaryFileInfo.MoveTo(projectPharmacyConversion.BinaryFileInfo.DirectoryName + @"\" + projectPharmacyConversion.VersionedName + projectPharmacyConversion.BinaryFileInfo.Extension);
    //    }
    //    else
    //    {
    //        m_BuildParent.SendLogMessage("\r\nError: Failed to find v8 Pharmacy Conversion tool...");
    //    }
    //}

    /// <summary>
    /// Rename DLL and VBP to versioned files names
    /// </summary>
    private void VersionFileNames()
    {
      foreach( Project project in this.m_projects )
      {
          if (project.BinaryFileInfo != null)
          {
            project.FileInfoPrjFile.MoveTo(project.FileInfoPrjFile.DirectoryName + @"\" + project.VersionedName + project.FileInfoPrjFile.Extension);
            try
            {
              project.BinaryFileInfo.MoveTo(project.BinaryFileInfo.DirectoryName + @"\" + project.VersionedName + project.BinaryFileInfo.Extension);
            }
            catch // If we can't find the binary no great shakes
            {
            }
          }
      }
    }

    /// <summary>
    /// Set/create/copy target build folder
    /// </summary>
    public void EstablishTargetBuildFolder()
    {
      m_BuildParent.SendLogMessage( "\r\nEstablishing target build folder:" );

      switch( Name )
      {
        case enmName.Source:
          m_directoryInfoTarget = m_directoryInfoParent;
          break;

        case enmName.L:
          m_directoryInfoTarget = new DirectoryInfo( m_directoryInfoParent.FullName + @"\L" );
          break;

        case enmName.R:
          m_directoryInfoTarget = new DirectoryInfo( m_directoryInfoParent.FullName + @"\R" );
          break;

        case enmName.T:
          m_directoryInfoTarget = new DirectoryInfo( m_directoryInfoParent.FullName + @"\T" );
          break;
      }

      // Copy files from source to build folder
      switch( Name )
      {
        case enmName.L:
        case enmName.R:
        case enmName.T:
          if (m_directoryInfoTarget.Exists)
            m_directoryInfoTarget.Delete( true );
          m_directoryInfoTarget.Create();

          m_BuildParent.SendLogMessage( "\r\n\t" + m_directoryInfoTarget.FullName );

          m_BuildParent.SendLogMessage( "\r\nCopying build files to: " + Name.ToString() );
          //XCopy(" /e /r /y /o /q \"" + m_BuildParent.DirectoryInfoSourceRoot.FullName + "\" \"" + m_directoryInfoTarget.FullName +"\"" );

          RecursiveCopy( m_BuildParent.DirectoryInfoSourceRoot, m_directoryInfoTarget, null, "*.*", true, true );
          //CopyDirectory(m_BuildParent.DirectoryInfoSourceRoot.FullName + "\\", m_directoryInfoTarget.FullName + "\\", true);
          break;
      }
    }

    /// <summary>
    /// Recursively traverse all folders, in the source directory, searching for VBPs to compile.
    /// </summary>
    private void LocateProjects()
    {
      // Create master list of projects to compile
      m_projects = new Projects();

      // Start at the "root" source folder and recursively search all sub-folders for projects
      DirectoryInfo directoryInfoCOM = new DirectoryInfo( m_directoryInfoTarget.FullName + @"\COM" );
      m_BuildParent.SendLogMessage("\r\nSearching for VBP projects in " + directoryInfoCOM.FullName);
      LocateProjectsDirectory(directoryInfoCOM);

      DirectoryInfo directoryInfoSmartClientDLL = new DirectoryInfo( m_directoryInfoTarget.FullName + @"\SmartClient\DLL" );
      m_BuildParent.SendLogMessage( "\r\nSearching for VBP projects in " + directoryInfoSmartClientDLL.FullName );
      LocateProjectsDirectory( directoryInfoSmartClientDLL );

      DirectoryInfo directoryInfoSmartClientOCX = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\SmartClient\OCX");
      m_BuildParent.SendLogMessage( "\r\nSearching for VBP projects in " + directoryInfoSmartClientOCX.FullName );
      LocateProjectsDirectory( directoryInfoSmartClientOCX );

      DirectoryInfo directoryInfoSmartClientEXE = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\SmartClient\EXE");
      m_BuildParent.SendLogMessage( "\r\nSearching for VBP projects in " + directoryInfoSmartClientEXE.FullName );
      LocateProjectsDirectory( directoryInfoSmartClientEXE );

      DirectoryInfo directoryInfoSmartClientTools = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\SmartClient\TOOLS\Source\DrugConversionV2");
      m_BuildParent.SendLogMessage("\r\nSearching for VBP projects in " + directoryInfoSmartClientTools.FullName);
      LocateProjectsDirectory(directoryInfoSmartClientTools);

      if (m_BuildParent.BuildV8DataConv)
      {
          DirectoryInfo directoryInfoTools = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\TOOLS\Source\V8 Data Conversion");
          m_BuildParent.SendLogMessage("\r\nSearching for VBP projects in " + directoryInfoTools.FullName);
          LocateProjectsDirectory(directoryInfoTools);
      }

      DirectoryInfo directoryInfoNet = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\COM\Pharmacy Source\Web Transport\DataWCFClient");
      m_BuildParent.SendLogMessage("\r\nSearch for .NET projects in " + directoryInfoNet.FullName);
      FileInfo csProj = directoryInfoNet.GetFiles().First(f => f.Extension.ToLower() == ".csproj");
      m_BuildParent.SendLogMessage(csProj.FullName);
      FileInfo sln = directoryInfoNet.GetFiles().First(f => f.Extension.ToLower() == ".sln");
      this.m_projects.Add(new NetProject(this, csProj, sln));

      DirectoryInfo directoryInfoNetCSproj = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\Pharmacy\Printing\TextControlEditor");
      DirectoryInfo directoryInfoNetSln = new DirectoryInfo(m_directoryInfoTarget.FullName + @"\Pharmacy\Printing");

      m_BuildParent.SendLogMessage("\r\nSearch for .NET projects in " + directoryInfoNetCSproj.FullName);

      FileInfo csProjTestBed = directoryInfoNetCSproj.GetFiles().First(f => f.Extension.ToLower() == ".csproj");
      m_BuildParent.SendLogMessage(csProjTestBed.FullName);

      FileInfo slnTestBed = directoryInfoNetSln.GetFiles().First(f => f.Extension.ToLower() == ".sln");

      this.m_projects.Add(new NetProject(this, csProjTestBed, slnTestBed));

      string strContent;
      FileStream fileStream;
      byte[] abyteBuffer;
      FileInfo fileInfo = new FileInfo(m_directoryInfoTarget.FullName + @"\Pharmacy\Printing\TextControlEditor\Properties\Resources.Designer.cs");
      if (fileInfo.Exists)
      {
          fileStream = fileInfo.OpenRead();
          abyteBuffer = new byte[fileStream.Length];
          fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
          strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
          fileStream.Close();
          var strVersioned ="";
          if (this.m_name == Target.enmName.T)
          {
              strVersioned = "T" + m_BuildParent.VersionString() + "TextControlEditorPharmacyClient" + m_BuildParent.BuildString() + ".Properties.Resources";
          }
          else if (this.m_name == Target.enmName.R)
          {
              strVersioned = "R" + m_BuildParent.VersionString() + "TextControlEditorPharmacyClient" + m_BuildParent.BuildString() + ".Properties.Resources";
              //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstocktake" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
          }
          else if (this.m_name == Target.enmName.L)
          {
              strVersioned = "L" + m_BuildParent.VersionString() + "TextControlEditorPharmacyClient" + m_BuildParent.BuildString() + ".Properties.Resources";
          }
          strContent = Regex.Replace(strContent, "TextControlEditorPharmacyClient.Properties.Resources", strVersioned, RegexOptions.IgnoreCase);

          File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
          fileInfo.Delete();
          fileStream = fileInfo.OpenWrite();
          abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
          fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
          fileStream.Close();
      }

    }

    /// <summary>
    /// Recursive method of LocateProjects() method
    /// </summary>
    /// <param name="directoryInfo">Directory to search</param>
    private void LocateProjectsDirectory( DirectoryInfo directoryInfo )
    {
      string strContent;
      FileStream fileStream;
      byte[] abyteBuffer;

      if( directoryInfo.Exists )
      {
        // Create an array representing the files in the current directory.
        FileInfo[] afileInfoContents = directoryInfo.GetFiles( "*." + Project.PROJECT_EXTENSION );

        // Add projects into this build's project list, from the array of files found
        foreach( FileInfo fileInfo in afileInfoContents )
        {
          // These files must be ignored at all costs!
          if (!fileInfo.Name.Contains("SYMRTL10.vbp") && !fileInfo.Name.Contains("PRVRTL10.vbp"))
          {
            // Read our vbp file and check to see if it has the ReadyToBuild=True flag in it
            fileStream = fileInfo.OpenRead();
            abyteBuffer = new byte[fileStream.Length];
            fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
            strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
            fileStream.Close();

            if (strContent.IndexOf("ReadyToBuild=True") > 0)
            {
              if (fileInfo.FullName.ToLower().IndexOf("test") != -1)
              {
                m_BuildParent.SendLogMessage(fileInfo.FullName + " (SKIPPED - contains the word 'test')");
              }
              else if (fileInfo.FullName.ToLower().IndexOf("!template") != -1)
              {
                m_BuildParent.SendLogMessage(fileInfo.FullName + " (SKIPPED - contains '!template' in path)");
              }
              else if (fileInfo.Name.ToLower().IndexOf("power") != -1)
              {
                m_BuildParent.SendLogMessage(fileInfo.FullName + " (SKIPPED - name is 'power')");
              }
              else
              {
                m_BuildParent.SendLogMessage(fileInfo.FullName);

                Project project = new Project(this, fileInfo);
                m_projects.Add(project);
              }
            }
          }
        }

        // Now recurse into the sub-directories
        DirectoryInfo[] adirectoryInfoSubFolders = directoryInfo.GetDirectories();
        foreach( DirectoryInfo directoryInfoSub in adirectoryInfoSubFolders )
        {
          LocateProjectsDirectory( directoryInfoSub );
        }
      }
      else
      {
        m_BuildParent.SendLogMessage( "\r\n\tDirectory not found: " + directoryInfo.FullName );
      }
    }


    /// <summary>
    /// Recursively traverse all folders, in the source directory, searching for ASPX files
    /// </summary>
    private void LocateWebpages()
    {
      m_webpages = new Webpages();

      DirectoryInfo directoryInfoASPX = new DirectoryInfo( m_directoryInfoTarget.FullName );
      m_BuildParent.SendLogMessage( "\r\nSearching for ASPX files in " + directoryInfoASPX.FullName );
      LocateWebpagesDirectory( directoryInfoASPX );
    }


    /// <summary>
    /// Recursive method of LocateWebpages() method
    /// </summary>
    /// <param name="directoryInfo">Directory to search</param>
    private void LocateWebpagesDirectory( DirectoryInfo directoryInfo )
    {
      if( directoryInfo.Exists )
      {
        // Create an array representing the files in the current directory.
        FileInfo[] afileInfoContents = directoryInfo.GetFiles( "*.aspx" );

        // Add Webpages into this build's project list, from the array of files found
        foreach( FileInfo fileInfo in afileInfoContents )
        {
          if( fileInfo.FullName.ToLower().IndexOf( "test" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - contains the word 'test')" );
          }
          else if( fileInfo.FullName.ToLower().IndexOf( "!template" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - contains '!template' in path)" );
          }
          else if( fileInfo.Name.ToLower().IndexOf( "power" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - name is 'power')" );
          }
          else
          {
            Webpage webpage = new Webpage( this, fileInfo );

            // scan the webpage for the object tag
            if( webpage.ContainsObjectTag( fileInfo ) )
            {
              // if the webpage has an object tag in it then it's added to our array of files
              m_BuildParent.SendLogMessage( fileInfo.FullName );
              m_webpages.Add( webpage );
            }
          }
        }

        // Now recurse into the sub-directories
        DirectoryInfo[] adirectoryInfoSubFolders = directoryInfo.GetDirectories();
        foreach( DirectoryInfo directoryInfoSub in adirectoryInfoSubFolders )
        {
          LocateWebpagesDirectory( directoryInfoSub );
        }
      }
      else
      {
        m_BuildParent.SendLogMessage( "\r\n\tDirectory not found: " + directoryInfo.FullName );
      }
    }


    /// <summary>
    /// Recursively traverse all folders, in the source directory, searching for OCXs to edit
    /// </summary>
    private void LocateOCXFiles()
    {
      m_ocxcontrols = new Ocxcontrols();

      string path = m_directoryInfoTarget.FullName;
      if (path.EndsWith(@"\Web"))
          path += @"\..";
      path += @"\SmartClient\OCX";

      DirectoryInfo directoryInfoOCX = new DirectoryInfo( path );
      m_BuildParent.SendLogMessage( "\r\nSearching for OCX files in " + directoryInfoOCX.FullName );
      LocateOCXDirectory( directoryInfoOCX );
    }


    /// <summary>
    /// Recursive method of LocateOCXFiles() method
    /// </summary>
    /// <param name="directoryInfo">Directory to search</param>
    private void LocateOCXDirectory( DirectoryInfo directoryInfo )
    {
      if( directoryInfo.Exists )
      {
        // Create an array representing the files in the current directory.
        FileInfo[] afileInfoContents = directoryInfo.GetFiles( "*.ocx" );

        // Add projects into this build's project list, from the array of files found
        foreach( FileInfo fileInfo in afileInfoContents )
        {
          if( fileInfo.FullName.ToLower().IndexOf( "test" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - contains the word 'test')" );
          }
          else if( fileInfo.FullName.ToLower().IndexOf( "!template" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - contains '!template' in path)" );
          }
          else if( fileInfo.Name.ToLower().IndexOf( "power" ) != -1 )
          {
            m_BuildParent.SendLogMessage( fileInfo.FullName + " (SKIPPED - name is 'power')" );
          }
          else
          {
            Ocxcontrol ocxcontrol = new Ocxcontrol( this, fileInfo );
            m_BuildParent.SendLogMessage( fileInfo.FullName );
            m_ocxcontrols.Add( ocxcontrol );
          }
        }

        // Now recurse into the sub-directories
        DirectoryInfo[] adirectoryInfoSubFolders = directoryInfo.GetDirectories();
        foreach( DirectoryInfo directoryInfoSub in adirectoryInfoSubFolders )
        {
          LocateOCXDirectory( directoryInfoSub );
        }
      }
      else
      {
        m_BuildParent.SendLogMessage( "\r\n\tDirectory not found: " + directoryInfo.FullName );
      }
    }


    /// <summary>
    /// For each project in the build list, determine the projects that must be compiled before it
    /// </summary>
    private void ResearchProjectReferences()
    {
      m_BuildParent.SendLogMessage( "\r\nResearching references..." );

      foreach( Project project in m_projects )
      {
        m_BuildParent.SendLogMessage( project.FileInfoPrjFile.FullName );

        project.ReseachReferences();
      }
    }

    /// <summary>
    /// Find a project by searching for it's binary path
    /// </summary>
    /// <param name="strBinaryPath"></param>
    /// <returns></returns>
    public Project FindProjectByBinaryPath( string strBinaryPath )
    {
      foreach( Project project in m_projects )
      {
          if( project.BinaryFileInfo != null )
              if (project.BinaryFileInfo.FullName.ToLower() == strBinaryPath.ToLower())
              {
                  return project;
              }
      }
      return null;
    }

    /// <summary>
    /// Sort projects so that all dependant projects are below the project that they depend on.
    /// </summary>
    public void SortProjectsByDependancy()
    {
      m_BuildParent.SendLogMessage( "\r\nSorting projects into dependancy order..." );

      // Create a Master copy of the projects list, that wont get sorted while we're Master on it
      Projects projectsMaster = new Projects();
      foreach( Project project in m_projects )
      {
        projectsMaster.Add( project );
      }
      // Create a Working copy of the projects list that we will sort, in reverse order
      Projects projectsWorking = new Projects();
      foreach( Project project in m_projects )
      {
        projectsWorking.Add( project );
      }

      for( int intMaster = projectsMaster.Count - 1; intMaster >= 0; intMaster-- )
      {
        Project projectMaster = projectsMaster[intMaster];

        foreach (Project projectCompare in projectsWorking)
        {
          if (projectMaster.IsDependantOn(projectCompare))
          {
            Project projectToMove = projectsWorking[projectsWorking.IndexOf( projectMaster )];
            projectsWorking.Remove( projectToMove );
            projectsWorking.Insert( projectsWorking.IndexOf( projectCompare ), projectToMove );
            break;
          }
        }

      }

      // Finally copy the reverse-sorted working list, back into the projects list, in the correct order
      m_projects.Clear();
      for( int intIndex = projectsWorking.Count - 1; intIndex >= 0; intIndex-- )
      {
        m_projects.Add( projectsWorking[intIndex] );
      }

      // Output dependancy list
      foreach( Project project in m_projects )
      {
        m_BuildParent.SendLogMessage( project.FileInfoPrjFile.Name );

        string strMsg = "";
        foreach( Reference reference in project.ReferenceList )
        {
          strMsg += " " + reference.ProjectReferTo.FileInfoPrjFile.Name;
        }

        m_BuildParent.SendLogMessage( "\t" + strMsg + "\r\n" );
      }

    }

    /// <summary>
    /// Compile all projects
    /// </summary>
    private void MakeProjects()
    {
      m_BuildParent.SendLogMessage( "\r\nBuilding Projects..." );

      foreach( Project project in m_projects )
      {
        project.Make();
      }
    }

    /// <summary>
    /// Update the webpage component tag
    /// </summary>
    private void UpdateWebpageControl()
    {
      m_BuildParent.SendLogMessage( "\r\nUpdating Webpage GUID" );

      foreach( Webpage webpage in m_webpages )
      {
        webpage.UpdateWebpageCLSID();
      }
    }


    /// <summary>
    /// Checks all ocx controls to see if they are registered
    /// </summary>
    private void CheckOCXRegistration()
    {
      m_BuildParent.SendLogMessage( "\r\n" );
      m_BuildParent.SendLogMessage( "Checking OCX Control Registration..." );

      foreach( Ocxcontrol ocxcontrol in m_ocxcontrols )
      {
        ocxcontrol.IsControlRegistered();
      }
    }

    /// <summary>
    /// Updates the executable filenames in the .js files that are associated
    /// </summary>
    private void UpdateJSExecutableNames()
    {
      m_BuildParent.SendLogMessage( "\r\nUpdating .js executable references" );

      string strContent;
      FileInfo fileInfo;
      FileStream fileStream;
      byte[] abyteBuffer;
      //string strVersionedExe = null;
      string strVersionedExe = string.Empty;    //11Nov09   Rams    Default string set to String.Empty from null.

      // Read stocktake script file
      fileInfo = new FileInfo( m_directoryInfoTarget.FullName + @"\application\StockTake\script\StockTake.js" );
      if( fileInfo.Exists )
      {
        fileStream = fileInfo.OpenRead();
        abyteBuffer = new byte[fileStream.Length];
        fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
        strContent = System.Text.Encoding.Default.GetString( abyteBuffer );
        fileStream.Close();

        if( this.m_name == Target.enmName.T )
        {
          strVersionedExe = "T" + m_BuildParent.VersionString() + "icwstocktake" + m_BuildParent.BuildString() + ".exe";
        }
        else if( this.m_name == Target.enmName.R )
        {
          strVersionedExe = "R" + m_BuildParent.VersionString() + "icwstocktake" + m_BuildParent.BuildString() + ".exe";
          //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstocktake" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }
        else if (this.m_name == Target.enmName.L)
        {
            strVersionedExe = "L" + m_BuildParent.VersionString() + "icwstocktake" + m_BuildParent.BuildString() + ".exe";
            //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstocktake" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }

        // 25Nov09  ChrisD  Only do the replace if the strVersionedExe variable has a value
        // Needed as the change above - Rams 11Nov09 - initializes strVersionedExe to String.Empty rather than null which is ignored in the Regex.Replace
        if (!string.IsNullOrEmpty(strVersionedExe))
        {
            strContent = Regex.Replace(strContent, "icwstocktake.exe", strVersionedExe, RegexOptions.IgnoreCase);
        }

        // Write file back to disk
        File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
        fileInfo.Delete();
        fileStream = fileInfo.OpenWrite();
        abyteBuffer = System.Text.Encoding.Default.GetBytes( strContent );
        fileStream.Write( abyteBuffer, 0, abyteBuffer.Length );
        fileStream.Close();
      }

      //
      // Read stores script file
      //
      fileInfo = new FileInfo( m_directoryInfoTarget.FullName + @"\application\Stores\script\Stores.js" );
      if( fileInfo.Exists )
      {
        fileStream = fileInfo.OpenRead();
        abyteBuffer = new byte[fileStream.Length];
        fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
        strContent = System.Text.Encoding.Default.GetString( abyteBuffer );
        fileStream.Close();

        if( this.m_name == Target.enmName.T )
        {
          strVersionedExe = "T" + m_BuildParent.VersionString() + "icwstores" + m_BuildParent.BuildString() + ".exe";
          //                    strVersionedExe = "T" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }
        else if( this.m_name == Target.enmName.R )
        {
          strVersionedExe = "R" + m_BuildParent.VersionString() + "icwstores" + m_BuildParent.BuildString() + ".exe";
          //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }
        else if (this.m_name == Target.enmName.L)
        {
            strVersionedExe = "L" + m_BuildParent.VersionString() + "icwstores" + m_BuildParent.BuildString() + ".exe";
            //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }

        // 25Nov09  ChrisD  Only do the replace if the strVersionedExe variable has a value
        // Needed as the change above - Rams 11Nov09 - initializes strVersionedExe to String.Empty rather than null which is ignored in the Regex.Replace
        if (!string.IsNullOrEmpty(strVersionedExe))
        {
            strContent = Regex.Replace(strContent, "icwstores.exe", strVersionedExe, RegexOptions.IgnoreCase);
        }

        // Write file back to disk
        File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
        fileInfo.Delete();
        fileStream = fileInfo.OpenWrite();
        abyteBuffer = System.Text.Encoding.Default.GetBytes( strContent );
        fileStream.Write( abyteBuffer, 0, abyteBuffer.Length );
        fileStream.Close();
      }


      //
      // Read report script file
      //
      fileInfo = new FileInfo( m_directoryInfoTarget.FullName + @"\application\pharmacysharedscripts\reports.js" );
      if( fileInfo.Exists )
      {
        fileStream = fileInfo.OpenRead();
        abyteBuffer = new byte[fileStream.Length];
        fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
        strContent = System.Text.Encoding.Default.GetString( abyteBuffer );
        fileStream.Close();

        if( this.m_name == Target.enmName.T )
        {
          strVersionedExe = "T" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
          //                    strVersionedExe = "T" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }
        else if( this.m_name == Target.enmName.R )
        {
          strVersionedExe = "R" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
          //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }
        else if (this.m_name == Target.enmName.L)
        {
            strVersionedExe = "L" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
            //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", m_BuildParent.VersionMinor ) + "icwstores" + String.Format( "{0:000}", m_BuildParent.VersionBuild ) + ".exe";
        }

        // 25Nov09  ChrisD  Only do the replace if the strVersionedExe variable has a value
        // Needed as the change above - Rams 11Nov09 - initializes strVersionedExe to String.Empty rather than null which is ignored in the Regex.Replace
        if (!string.IsNullOrEmpty(strVersionedExe))
        {
            strContent = Regex.Replace(strContent, "AscribePrintJob.exe", strVersionedExe, RegexOptions.IgnoreCase);
        }

        // Write file back to disk
        File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
        fileInfo.Delete();
        fileStream = fileInfo.OpenWrite();
        abyteBuffer = System.Text.Encoding.Default.GetBytes( strContent );
        fileStream.Write( abyteBuffer, 0, abyteBuffer.Length );
        fileStream.Close();
      }


      //
      // Read stocktake script file
      //
      fileInfo = new FileInfo( m_directoryInfoTarget.FullName + @"\application\Manufacturing\script\Manufacturing.js" );
      if( fileInfo.Exists )
      {
        fileStream = fileInfo.OpenRead();
        abyteBuffer = new byte[fileStream.Length];
        fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
        strContent = System.Text.Encoding.Default.GetString( abyteBuffer );
        fileStream.Close();

        if( this.m_name == Target.enmName.T )
        {
          //                    strVersionedExe = "T" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format("{0:00}", m_BuildParent.VersionMinor) + "icwmanufact" + String.Format("{0:000}", m_BuildParent.VersionBuild) + ".exe";
          strVersionedExe = "T" + m_BuildParent.VersionString() + "icwmanufact" + m_BuildParent.BuildString() + ".exe";
        }
        else if( this.m_name == Target.enmName.R )
        {
          //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format("{0:00}", m_BuildParent.VersionMinor) + "icwmanufact" + String.Format("{0:000}", m_BuildParent.VersionBuild) + ".exe";
          strVersionedExe = "R" + m_BuildParent.VersionString() + "icwmanufact" + m_BuildParent.BuildString() + ".exe";
        }
        else if (this.m_name == Target.enmName.L)
        {
            //                    strVersionedExe = "R" + m_BuildParent.VersionArchitecture + m_BuildParent.VersionMajor.ToString() + String.Format("{0:00}", m_BuildParent.VersionMinor) + "icwmanufact" + String.Format("{0:000}", m_BuildParent.VersionBuild) + ".exe";
            strVersionedExe = "L" + m_BuildParent.VersionString() + "icwmanufact" + m_BuildParent.BuildString() + ".exe";
        }

        // 25Nov09  ChrisD  Only do the replace if the strVersionedExe variable has a value
        // Needed as the change above - Rams 11Nov09 - initializes strVersionedExe to String.Empty rather than null which is ignored in the Regex.Replace
        if (!string.IsNullOrEmpty(strVersionedExe))
        {
            strContent = Regex.Replace(strContent, "icwmanufact.exe", strVersionedExe, RegexOptions.IgnoreCase);
        }

        // Write file back to disk
        File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
        fileInfo.Delete();
        fileStream = fileInfo.OpenWrite();
        abyteBuffer = System.Text.Encoding.Default.GetBytes( strContent );
        fileStream.Write( abyteBuffer, 0, abyteBuffer.Length );
        fileStream.Close();
      }

      // Would love to have done this for all of the files above but have not got time to test for all of them

        if( this.m_name == Target.enmName.T )
        {
          strVersionedExe = "T" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
        }
        else if( this.m_name == Target.enmName.R )
        {
            strVersionedExe = "R" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
        }
        else if (this.m_name == Target.enmName.L)
        {
            strVersionedExe = "L" + m_BuildParent.VersionString() + "AscribePrintJob" + m_BuildParent.BuildString() + ".exe";
        }

        if (!string.IsNullOrEmpty(strVersionedExe))
        {
            this.ReplaceInAllFiles(m_directoryInfoTarget.FullName, "AscribePrintJob.exe", strVersionedExe);
        }
    }

    private void ReplaceInAllFiles(string path, string originalValue, string newValue)
    {
        foreach (var file in Directory.GetFiles(path, "*.js"))
        {
            this.DoReplace(file, originalValue, newValue);
        }

        foreach (var dir in Directory.GetDirectories(path))
        {
            this.ReplaceInAllFiles(dir, originalValue, newValue);
        }
    }

    private void DoReplace(string fileName, string originalValue, string newValue)
    {
        FileInfo fileInfo = new FileInfo(fileName);
        FileStream fileStream = fileInfo.OpenRead();
        byte[] buffer = new byte[fileStream.Length];
        fileStream.Read(buffer, 0, (int)fileStream.Length);
        string fileContent = System.Text.Encoding.Default.GetString(buffer);
        fileStream.Close();

        if (Regex.IsMatch(fileContent, originalValue))
        {
            fileContent = Regex.Replace(fileContent, originalValue, newValue, RegexOptions.IgnoreCase);

            File.SetAttributes(fileInfo.FullName, FileAttributes.Normal);
            fileInfo.Delete();
            fileStream = fileInfo.OpenWrite();
            buffer = System.Text.Encoding.Default.GetBytes(fileContent);
            fileStream.Write(buffer, 0, buffer.Length);
            fileStream.Close();
        }
    }

    ///// <summary>
    ///// Update the version numbers contained in file modVersion.bas
    ///// </summary>
    //private void UpdateFileModVersionBas()
    //{
    //  m_BuildParent.SendLogMessage("\r\nUpdating Version file modVersion.bas");

    //  string strContent;
    //  FileInfo fileInfo;
    //  FileStream fileStream;
    //  byte[] abyteBuffer;

    //  // Read file from disk
    //  fileInfo = new FileInfo(m_directoryInfoTarget.FullName + @"\COM\Source\modVersion.bas" );
    //        if (fileInfo.Exists)
    //        {
    //            fileStream = fileInfo.OpenRead();
    //            abyteBuffer = new byte[fileStream.Length];
    //            fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //            strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
    //            fileStream.Close();

    //            strContent = Regex.Replace(strContent, @"VER_Architecture\s+As\s+Integer\s*=\s*\d+\s*\r\n", "VER_Architecture As Integer = " + m_BuildParent.VersionArchitecture.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Major\s+As\s+Integer\s*=\s*\d+\s*\r\n", "VER_Major As Integer = " + m_BuildParent.VersionMajor.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Minor\s+As\s+Integer\s*=\s*\d+\s*\r\n", "VER_Minor As Integer = " + m_BuildParent.VersionMinor.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Release\s+As\s+Integer\s*=\s*\d+\s*\r\n", "VER_Release As Integer = " + m_BuildParent.VersionRelease.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Build\s+As\s+Integer\s*=\s*\d+\s*\r\n", "VER_Build As Integer = " + m_BuildParent.VersionBuild.ToString() + "\r\n");

    //            // Write file back to disk
    //            fileInfo.Delete();
    //            fileStream = fileInfo.OpenWrite();
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
    //            fileStream.Close();
    //        }
    //}

    //    /// <summary>
    //    /// Update the version numbers contained in file winver.bas
    //    /// </summary>
    //    private void UpdateFileWinVer()
    //    {
    //        m_BuildParent.SendLogMessage("\r\nUpdating Version file winver.bas");

    //        string strContent;
    //        FileInfo fileInfo;
    //        FileStream fileStream;
    //        byte[] abyteBuffer;

    //        // Read file from disk
    //        fileInfo = new FileInfo(m_directoryInfoTarget.FullName + @"\SmartClient\Shared\Source\Libraries\WinVer.bas");
    //        if (fileInfo.Exists)
    //        {
    //            fileStream = fileInfo.OpenRead();
    //            abyteBuffer = new byte[fileStream.Length];
    //            fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //            strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
    //            fileStream.Close();

    //            strContent = Regex.Replace(strContent, @"VER_Architecture\s*=\s*\x22\d+\x22\s*\r\n", "VER_Architecture = \x22" + m_BuildParent.VersionArchitecture.ToString() + "\x22\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Major\s*=\s*\x22\d+\x22\s*\r\n", "VER_Major = \x22" + m_BuildParent.VersionMajor.ToString() + "\x22\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Minor\s*=\s*\x22\d+\x22\s*\r\n", "VER_Minor = \x22" + m_BuildParent.VersionMinor.ToString() + "\x22\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Build\s*=\s*\x22\d+\x22\s*\r\n", "VER_Build = \x22" + m_BuildParent.VersionBuild.ToString() + "\x22\r\n");

    //            // Write file back to disk
    //            fileInfo.Delete();
    //            fileStream = fileInfo.OpenWrite();
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
    //            fileStream.Close();
    //        }
    //    }

    //    /// <summary>
    //    /// Update the version numbers contained in sql patch file for this version.
    //    /// </summary>
    //    private void UpdateFileSqlScript()
    //    {
    //        m_BuildParent.SendLogMessage("\r\nUpdating SQL script version");

    //        string strContent;
    //        FileInfo fileInfo;
    //        FileStream fileStream;
    //        byte[] abyteBuffer;
    //        string strSQLVersion;
    //        string strSQLTagLine;

    //        //strSQLVersion = "GO\r\n\r\n";
    //        strSQLVersion = "\r\n\r\n";
    //        strSQLVersion += "exec pVersionSet " + "'System', " +
    //                        m_BuildParent.VersionArchitecture.ToString() + ", " +
    //                        m_BuildParent.VersionMajor.ToString() + ", " +
    //                        m_BuildParent.VersionMinor.ToString() + ", " +
    //                        m_BuildParent.VersionBuild.ToString() + "\r\n";

    //        strSQLTagLine = "GO\r\n";
    //        strSQLTagLine += "print '------------------------------------------------------------------'\r\n";
    //        strSQLTagLine += "print 'Patching process complete, please review above output for errors,'\r\n";
    //        strSQLTagLine += "print 'if errors are found please save the patch installation log to'\r\n";
    //        strSQLTagLine += "print 'a text file and send it to the ascribe development team.'\r\n";
    //        strSQLTagLine += "print '------------------------------------------------------------------'\r\n";


    //        // Read file from disk
    //        fileInfo = new FileInfo(m_directoryInfoTarget.FullName + @"\Database\Patches\v" + m_BuildParent.VersionArchitecture.ToString() + "." + m_BuildParent.VersionMajor.ToString() + ".sql");
    //        if (fileInfo.Exists)
    //        {
    //            fileStream = fileInfo.OpenRead();
    //            abyteBuffer = new byte[fileStream.Length];
    //            fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //            strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
    //            fileStream.Close();


    //            // Write file back to disk
    //            fileInfo.Delete();
    //            fileStream = fileInfo.OpenWrite();
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);

    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);

    //            // Add on our version details for this script
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strSQLVersion);
    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);

    //            // Add on the script complete tag lines
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strSQLTagLine);
    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);

    //            fileStream.Close();
    //        }
    //    }

    ///// <summary>
    ///// Update the version numbers contained in file Version.vb
    ///// </summary>
    //private void UpdateFileVersionVB()
    //{
    //  m_BuildParent.SendLogMessage("\r\nUpdating Version file Version.vb");

    //  string strContent;
    //  FileInfo fileInfo;
    //  FileStream fileStream;
    //  byte[] abyteBuffer;

    //  // Read file from disk
    //  fileInfo = new FileInfo(m_directoryInfoTarget.FullName + @"\Web\ASCICW\Version.vb" );
    //        if (fileInfo.Exists)
    //        {
    //            fileStream = fileInfo.OpenRead();
    //            abyteBuffer = new byte[fileStream.Length];
    //            fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
    //            strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
    //            fileStream.Close();

    //            strContent = Regex.Replace(strContent, @"VER_Architecture\s*=\s*\d+\s*\r\n", "VER_Architecture = " + m_BuildParent.VersionArchitecture.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Major\s*=\s*\d+\s*\r\n", "VER_Major = " + m_BuildParent.VersionMajor.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Minor\s*=\s*\d+\s*\r\n", "VER_Minor = " + m_BuildParent.VersionMinor.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Release\s*=\s*\d+\s*\r\n", "VER_Release = " + m_BuildParent.VersionRelease.ToString() + "\r\n");
    //            strContent = Regex.Replace(strContent, @"VER_Build\s*=\s*\d+\s*\r\n", "VER_Build = " + m_BuildParent.VersionBuild.ToString() + "\r\n");

    //            // Write file back to disk
    //            fileInfo.Delete();
    //            fileStream = fileInfo.OpenWrite();
    //            abyteBuffer = System.Text.Encoding.Default.GetBytes(strContent);
    //            fileStream.Write(abyteBuffer, 0, abyteBuffer.Length);
    //            fileStream.Close();
    //        }
    //}

    /// <summary>
    /// Check in all updated files back into SourceSafe
    /// </summary>
    /// <SUMMARY>
    /// Copy a Directory, SubDirectories and Files Given a Source and  
    /// Destination DirectoryInfo Object, Given a SubDirectory Filter
    /// and a File Filter.
    /// IMPORTANT: The search strings for SubDirectories and Files applies 
    /// to every Folder and File within the Source Directory.
    /// </SUMMARY>
    /// <PARAM name="SourceDirectory">A DirectoryInfo Object Pointing 
    /// to the Source Directory</PARAM>
    /// <PARAM name="DestinationDirectory">A DirectoryInfo Object Pointing 
    /// to the Destination Directory</PARAM>
    /// <PARAM name="SourceDirectoryFilter">Search String on  
    ///   SubDirectories (Example: "System*" will return all subdirectories
    ///   starting with "System") or null if no filter</PARAM>
    /// <PARAM name="SourceFileFilter">File Filter: Standard DOS-Style Format 
    ///    (Examples: "*.txt" or "*.exe")</PARAM>
    /// <PARAM name="Overwrite">Whether or not to Overwrite Copied Files in the
    ///     Destination Directory</PARAM>
    public static void RecursiveCopy( DirectoryInfo SourceDirectory, DirectoryInfo DestinationDirectory, string SourceDirectoryFilter, string SourceFileFilter, bool Overwrite, bool MakeWritable )
    {
      DirectoryInfo[] SourceSubDirectories;
      FileInfo[] SourceFiles;

      //Check for File Filter
      if( SourceFileFilter != null )
      {
        SourceFiles = SourceDirectory.GetFiles( SourceFileFilter.Trim() );
      }
      else
      {
        SourceFiles = SourceDirectory.GetFiles();
      }

      //Check for Folder Filter
      if( SourceDirectoryFilter != null )
      {
        SourceSubDirectories = SourceDirectory.GetDirectories( SourceDirectoryFilter.Trim() );
      }
      else
      {
        SourceSubDirectories = SourceDirectory.GetDirectories();
      }

      //Create the Destination Directory
      if( !DestinationDirectory.Exists )
      {
        DestinationDirectory.Create();
      }

      //Recursively Copy Every SubDirectory and it's 
      //Contents (according to folder filter)
      foreach( DirectoryInfo SourceSubDirectory in SourceSubDirectories )
      {
        RecursiveCopy( SourceSubDirectory, new DirectoryInfo( DestinationDirectory.FullName + @"\" + SourceSubDirectory.Name ), SourceDirectoryFilter, SourceFileFilter, Overwrite, MakeWritable );
      }

      //Copy Every File to Destination Directory (according to file filter)
      foreach( FileInfo SourceFile in SourceFiles )
      {
        if (!SourceFile.Name.Contains("Install.txt"))
        {
          SourceFile.CopyTo(DestinationDirectory.FullName + @"\" + SourceFile.Name, Overwrite);
          FileInfo fileInfoTarget = new FileInfo(DestinationDirectory.FullName + @"\" + SourceFile.Name);
          if (MakeWritable)
          {
            fileInfoTarget.Attributes &= ~System.IO.FileAttributes.ReadOnly;
          }
        }
      }
    }

  }
}
