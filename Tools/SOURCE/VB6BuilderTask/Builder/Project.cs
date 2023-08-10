using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.ComponentModel;
using Microsoft.Win32;
using System.Text;

namespace Ascribe.ICW.BuildTasks
{
  /// <summary>
  /// Summary description for Project.
  /// </summary>
  public class Project
  {
    public const string PROJECT_EXTENSION = "vbp";

    protected Target m_TargetParent = null;
    protected string m_strShortName = "";
    protected FileInfo m_fileInfoPrjFile;
    protected FileInfo m_fileInfoBinary;
    protected References m_references;
    protected string m_strPrjFileContent = "";
    protected string m_strGUID = "";

    public Project( Target targetParent, FileInfo fileInfoPrjFile )
    {
      m_TargetParent = targetParent;
      m_fileInfoPrjFile = fileInfoPrjFile;
      m_strShortName = this.m_fileInfoPrjFile.Name.Substring( 0, this.m_fileInfoPrjFile.Name.Length - this.m_fileInfoPrjFile.Extension.Length );
      LocateCompatibleBinary();
    }

    public FileInfo FileInfoPrjFile
    {
      get { return m_fileInfoPrjFile; }
    }

    public FileInfo BinaryFileInfo
    {
      get { return m_fileInfoBinary; }
    }

    public Target TargetParent
    {
      get { return m_TargetParent; }
    }

    public string GUID
    {
      get { return m_strGUID; }
      set { m_strGUID = value; }
    }

    public string ShortName
    {
      get { return m_strShortName; }
    }

    public string VersionedName
    {
      get
      {
        //if( this.m_fileInfoPrjFile.FullName.IndexOf( "\\COM\\" ) != -1 )
        //{
        //  return this.m_TargetParent.Name.ToString().Substring(0, 1) + m_TargetParent.BuildParent.VersionString() + this.ShortName.Substring(0, 4) + m_TargetParent.BuildParent.BuildString();
        //}
        //else
        //{
          return this.m_TargetParent.Name.ToString().Substring(0, 1) + m_TargetParent.BuildParent.VersionString() + this.ShortName + m_TargetParent.BuildParent.BuildString();
        //}
      }
    }

    /// <summary>
    /// Read the "CompatibleEXE32" entry from the VBP tp determine where the binary for this project lives
    /// </summary>
    protected virtual void LocateCompatibleBinary()
    {
      MatchCollection matches = Regex.Matches( FileContents, @"CompatibleEXE32\=.+\r\n" );
      if( matches.Count > 0 )
      {
        // CompatibleEXE32="..\..\..\..\Bin\OCSRTL10.dll"
        string strPath = matches[0].ToString().Substring( 17, matches[0].ToString().Length - 20 );
        m_fileInfoBinary = new FileInfo( ( strPath.StartsWith( "." ) ? ( m_fileInfoPrjFile.DirectoryName + @"\" ) : "" ) + strPath );
      }
      else
      {
          m_fileInfoBinary = null;
      }
    }

    public References ReferenceList
    {
      get { return m_references; }
    }

    public bool IsDependantOn( Project projectDependant )
    {
      foreach( Reference reference in this.m_references )
      {
        if (reference.ProjectReferTo == projectDependant)
        {
          return true;
        }
        if( reference.ProjectReferTo.IsDependantOn( projectDependant ) )
        {
          return true;
        }
      }
      return false;
    }

    /// <summary>
    /// Scan this project's references in the VBP file to compile a list of reference of projects that also exist 
    /// in the build list i.e. ICW DLLs
    /// </summary>
    public virtual void ReseachReferences()
    {
      m_references = new References();
      // Find all reference lines that match the format:
      // Reference=*\G{F5078F18-C551-11D3-89B9-0000F81FE221}#2.6#0#..\..\..\..\..\..\WINNT\system32\msxml2.dll#Microsoft XML, v2.6
      MatchCollection matches = Regex.Matches( FileContents, @"Reference\=.+\r\n" );
      foreach( Match match in matches )
      {
        string[] astrFields = match.ToString().Split( '#' );
        Reference reference = new Reference( this, astrFields[0].Substring( 14, 36 ), astrFields[1], astrFields[2], astrFields[3], astrFields[4].Substring( 0, astrFields[4].Length - 2 ) );
      }
    }

    /// <summary>
    /// Commence the building of this project
    /// </summary>
    public virtual void Make()
    {
      this.m_TargetParent.BuildParent.SendLogMessage( "\r\n" + this.m_fileInfoBinary.FullName );

      this.UpdateReferencesinProjectFile();
      if( this.m_fileInfoBinary.FullName.ToLower().IndexOf( ".exe" ) == -1 )
      {
        this.Unregister();
        this.SetCompatiblity( false );
      }
      this.SetVersion(m_TargetParent.BuildParent.VersionBuild);
      this.SetCopyrightYear();

      this.Compile();

      if( this.m_fileInfoBinary.FullName.ToLower().IndexOf( ".exe" ) == -1 )
      {
        this.SetCompatiblity( true );
        this.RefreshGuidFromRegistry();
      }
    }

    /// <summary>
    /// Update reference in VBP files and rewrite VBP file to disk
    /// </summary>
    protected virtual void UpdateReferencesinProjectFile()
    {
      // Replace references in cached VBP text, with newly updated references

      this.m_TargetParent.BuildParent.SendLogMessage( "\tUpdating references." );

      foreach( Reference reference in this.m_references )
      {
        if( reference.ProjectReferTo.GUID != "" )
        {
          m_strPrjFileContent = this.m_strPrjFileContent.Replace( reference.OriginalGUID, reference.ProjectReferTo.GUID );
          this.m_TargetParent.BuildParent.SendLogMessage( "\t\t" + reference.Path + " " + reference.ProjectReferTo.GUID );
        }
        else
        {
          throw new ApplicationException( reference.Path + " ERROR: GUID not set." );
        }
      }
      this.Flush();
    }

    /// <summary>
    /// Unregister this projects from the windows registery
    /// </summary>
    private void Unregister()
    {
      this.m_TargetParent.BuildParent.SendLogMessage( "\tUnregistering." );

      Process process = new Process();

      process.StartInfo.FileName = "regsvr32.exe";

      process.StartInfo.Arguments = " /u /s " + this.m_fileInfoBinary.FullName;
      process.StartInfo.CreateNoWindow = true;
      process.Start();
      process.WaitForExit();

      process.Close();
    }

    /// <summary>
    /// Update the VBP file, ON DISK, and in cache, to set binary compatibility as either on or off
    /// </summary>
    /// <param name="On"></param>
    private void SetCompatiblity( bool On )
    {
      this.m_TargetParent.BuildParent.SendLogMessage( "\tSetting Compatibility: " + ( On ? "ON" : "OFF" ) );

      m_strPrjFileContent = Regex.Replace( m_strPrjFileContent, @"CompatibleMode=.\d.", "CompatibleMode=\"" + ( On ? "2" : "0" ) + "\"" );
      this.Flush();
    }

    /// <summary>Set version number in the VBP file</summary>
    private void SetVersion(string versionStr)
    {
        var version = versionStr.Split('.');
        int temp;

        // set Major Version
        if (version.Length > 0 && int.TryParse(version[0], out temp))
        {
            this.m_TargetParent.BuildParent.SendLogMessage( "\tSetting Major Version: " + version[0] );
            m_strPrjFileContent = Regex.Replace( m_strPrjFileContent, @"MajorVer=\d+", "MajorVer=" + version[0] );
        }

        // Set Minor Version
        if (version.Length > 1 && int.TryParse(version[1], out temp))
        {
            this.m_TargetParent.BuildParent.SendLogMessage( "\tSetting Minor Version: " + version[1] );
            m_strPrjFileContent = Regex.Replace( m_strPrjFileContent, @"MinorVer=\d+", "MinorVer=" + version[1] );
        }

        // No true Revision version in vb6

        // set Build
        if (version.Length > 3 && int.TryParse(version[3], out temp))
        {
            this.m_TargetParent.BuildParent.SendLogMessage( "\tSetting Revision Version (Build version): " + version[3] );
            m_strPrjFileContent = Regex.Replace( m_strPrjFileContent, @"RevisionVer=\d+", "RevisionVer=" + version[3] );
        }

        this.Flush();
    }

    private void SetCopyrightYear()
    {
        m_strPrjFileContent = m_strPrjFileContent.Replace("[CurrentYear]", DateTime.Now.Year.ToString());
        this.Flush();
    }

    /// <summary>
    /// Compiule this project using VB6
    /// </summary>
    public virtual void Compile()
    {
      string strMessage = "";

      this.m_TargetParent.BuildParent.SendLogMessage( "\tCompiling..." );

      Process process = new Process();

      // Locate report file
      FileInfo fileInfoCompileReport = new FileInfo( this.m_fileInfoBinary.DirectoryName + @"\CompilerReport.txt" );
      // Delete any old ones
      if( fileInfoCompileReport.Exists )
      {
        fileInfoCompileReport.Delete();
      }

      this.m_TargetParent.BuildParent.SendLogMessage("Removing original binary");
      if(File.Exists(this.BinaryFileInfo.FullName))
      {
          this.m_TargetParent.BuildParent.SendLogMessage("Binary exists");
          File.Delete(this.BinaryFileInfo.FullName);
      }

      this.m_TargetParent.BuildParent.SendLogMessage("Binary remove complete");

      // Spawn VB6 compiler
      process.StartInfo.FileName = this.m_TargetParent.BuildParent.FileInfoVB6.FullName;
      this.m_TargetParent.BuildParent.SendLogMessage("Beginning compile of '" + this.m_TargetParent.BuildParent.FileInfoVB6.FullName + "'");

      this.m_TargetParent.BuildParent.SendLogMessage("Binary dir '" + this.m_fileInfoBinary.DirectoryName);

      this.m_TargetParent.BuildParent.SendLogMessage("VBP file '" + this.m_fileInfoPrjFile.FullName);


      process.StartInfo.Arguments =
          " /make /outdir \"" + this.m_fileInfoBinary.DirectoryName + "\""
        + " /out \"" + this.m_fileInfoBinary.DirectoryName + @"\CompilerReport.txt" + "\""
        + " \"" + this.m_fileInfoPrjFile.FullName + "\"";
      process.StartInfo.CreateNoWindow = true;
      //  process.StartInfo.RedirectStandardError = true;
      //process.StartInfo.RedirectStandardOutput = true;
      //  var error = process.StandardError.ReadToEnd();
//      process.StandardOutput.ReadToEnd();
      process.Start();
      process.WaitForExit();

      // Read compiler report
      FileStream fileStream = fileInfoCompileReport.OpenRead();
      byte[] abyteFile = new byte[fileStream.Length];
      fileStream.Read( abyteFile, 0, ( int ) fileStream.Length );
      string strReportText = System.Text.Encoding.Default.GetString( abyteFile );
      fileStream.Close();

      // Delete the report file
      if( fileInfoCompileReport.Exists )
      {
        fileInfoCompileReport.Delete();
      }

      // Output report text
      this.m_TargetParent.BuildParent.SendLogMessage( strReportText );

      process.Close();

      if( strReportText.IndexOf( "succeeded" ) == -1 )
      {
        strMessage = "The following project has failed to build :- " + this.m_fileInfoPrjFile.FullName;


        throw new ApplicationException( strMessage );
      }
    }

    /// <summary>
    /// Reset the value of this project's by looking it up in the registry
    /// </summary>
    private void RefreshGuidFromRegistry()
    {
      this.m_TargetParent.BuildParent.SendLogMessage( "\tReading new GUID." );

      /*	
        HKEY_LOCAL_MACHINE
          SOFTWARE
            Classes
              TypeLib
                {34534-345345-345345-345345}
                  1.0	REG_SZ	PETRTL10
                    0
                      win32	REGSZ	c:\test\PETRTL10
                    FLAGS
                    HELPDIR		REGSZ	c:\test
      */
      RegistryKey registryKeyTypeLib = Registry.LocalMachine.OpenSubKey( @"Software\Classes\TypeLib" );
      RegistryKey registryKeyGUID;

      string[] astrSubKeys = registryKeyTypeLib.GetSubKeyNames();
      bool blnFound = false;
      foreach( string strSubKey in astrSubKeys )
      {
        registryKeyGUID = registryKeyTypeLib.OpenSubKey(strSubKey);
        if( registryKeyGUID.SubKeyCount > 0 )
        {
          RegistryKey registryKeyVersion = registryKeyGUID.OpenSubKey( ( registryKeyGUID.GetSubKeyNames() )[0] );

          if( registryKeyVersion != null )
          {
            RegistryKey registryKeyWin32 = registryKeyVersion.OpenSubKey( @"0\win32" );
            if( registryKeyWin32 != null )
            {
              object objValue = registryKeyWin32.GetValue("");
              if( objValue != null )
              {
                string strPath = objValue.ToString();
                if (strPath == this.m_fileInfoBinary.FullName)
                {
                  blnFound = true;
                  this.m_strGUID = strSubKey.Substring( 1, strSubKey.Length - 2 );
                  this.m_TargetParent.BuildParent.SendLogMessage( "\t\t" + this.m_strGUID );
                  break;
                }
              }
            }
          }
        }
      }
      if( !blnFound )
      {
        this.m_strGUID = "";
        //throw new ApplicationException( "GUID not found for DLL: " + this.m_fileInfoBinary.FullName );
      }
    }

    /// <summary>
    /// Read and cache the contents of the VBP file into a class string
    /// </summary>
    protected string FileContents
    {
      get
      {
        if( m_strPrjFileContent == "" )
        {
          FileStream fileStream = m_fileInfoPrjFile.OpenRead();
          byte[] abyteFile = new byte[fileStream.Length];
          fileStream.Read( abyteFile, 0, ( int ) fileStream.Length );
          m_strPrjFileContent = System.Text.Encoding.Default.GetString( abyteFile );
          fileStream.Close();
        }
        return m_strPrjFileContent;
      }
    }

    /// <summary>
    /// Flushes the contents of the VBP Content cache back to the VBP file on disk.
    /// </summary>
    protected void Flush()
    {
      // Write back VBP file
      this.m_fileInfoPrjFile.Delete();
      FileStream fileStream = this.m_fileInfoPrjFile.OpenWrite();
      byte[] buffer = System.Text.Encoding.Default.GetBytes( this.m_strPrjFileContent );
      fileStream.Write( buffer, 0, buffer.Length );
      fileStream.Close();
      this.m_TargetParent.BuildParent.SendLogMessage( "\t\tVBP File Updated." );
    }
  }
}
