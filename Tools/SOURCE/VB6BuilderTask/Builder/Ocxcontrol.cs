using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.ComponentModel;
using Microsoft.Win32;
using System.Reflection;

namespace Ascribe.ICW.BuildTasks
{
  /// <summary>
  /// Summary description for Webpage.
  /// </summary>
  public class Ocxcontrol
  {
    public const string OCXCONTROL_EXTENSION = "ocx";

    Target m_TargetParent = null;
    string m_strShortName = "";
    FileInfo m_fileInfoOCX;
    string m_strGUID = "";

    public Ocxcontrol( Target targetParent, FileInfo fileInfoOCX )
    {
      m_TargetParent = targetParent;
      m_fileInfoOCX = fileInfoOCX;
      m_strShortName = this.m_fileInfoOCX.Name.Substring( 0, this.m_fileInfoOCX.Name.Length - this.m_fileInfoOCX.Extension.Length );
    }

    public FileInfo OCXFileInfo
    {
      get { return m_fileInfoOCX; }
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
        if( this.m_fileInfoOCX.FullName.IndexOf( "\\COM\\" ) != -1 )
        {
          //return this.m_TargetParent.Name.ToString().Substring(0,1) + this.m_TargetParent.BuildParent.VersionArchitecture + this.m_TargetParent.BuildParent.VersionMajor.ToString() + String.Format("{0:00}", this.m_TargetParent.BuildParent.VersionMinor) + this.ShortName.Substring(0,4) + String.Format("{0:000}", this.m_TargetParent.BuildParent.VersionBuild);
//          return this.m_TargetParent.Name.ToString().Substring( 0, 1 ) + this.m_TargetParent.BuildParent.VersionBranch + this.ShortName.Substring( 0, 4 ) + this.m_TargetParent.BuildParent.VersionBuild;
          return this.m_TargetParent.Name.ToString().Substring(0, 1) + this.m_TargetParent.BuildParent.VersionString() + this.ShortName.Substring(0, 4) + this.m_TargetParent.BuildParent.BuildString();
        }
        else
        {
          //					return this.m_TargetParent.Name.ToString().Substring(0,1) + this.m_TargetParent.BuildParent.VersionArchitecture + this.m_TargetParent.BuildParent.VersionMajor.ToString() + String.Format("{0:00}", this.m_TargetParent.BuildParent.VersionMinor) + this.ShortName + String.Format("{0:000}", this.m_TargetParent.BuildParent.VersionBuild);
//          return this.m_TargetParent.Name.ToString().Substring( 0, 1 ) + this.m_TargetParent.BuildParent.VersionBranch + this.ShortName + this.m_TargetParent.BuildParent.VersionBuild;
          return this.m_TargetParent.Name.ToString().Substring(0, 1) + this.m_TargetParent.BuildParent.VersionString() + this.ShortName + this.m_TargetParent.BuildParent.BuildString();
        }
      }
    }

    /// <summary>
    /// Checks the current ocx control to see if it is registered on the system if it isn't then the control is registered.
    /// </summary>
    public void IsControlRegistered()
    {
      this.m_TargetParent.BuildParent.SendLogMessage( "\tGUID for " + this.m_fileInfoOCX.FullName );

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
      int intIndex = 0;


      foreach( string strSubKey in astrSubKeys )
      {
        registryKeyGUID = registryKeyTypeLib.OpenSubKey( strSubKey );
        intIndex++;

        if( registryKeyGUID.SubKeyCount > 0 )
        {
          RegistryKey registryKeyVersion = registryKeyGUID.OpenSubKey( ( registryKeyGUID.GetSubKeyNames() )[0] );
          if( registryKeyVersion != null )
          {
            RegistryKey registryKeyWin32 = registryKeyVersion.OpenSubKey( @"0\win32" );
            if( registryKeyWin32 != null )
            {
              object objValue = registryKeyWin32.GetValue( "" );
              if( objValue != null )
              {
                string strPath = objValue.ToString();
                if( strPath == this.m_fileInfoOCX.FullName )
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
        this.m_TargetParent.BuildParent.SendLogMessage( "Registering control " + this.m_fileInfoOCX.FullName );
        RegisterOCXControl( m_fileInfoOCX );
      }
    }

    /// <summary>
    /// Registers the OCX control on the system
    /// </summary>
    /// <param name="thisFileInfo"></param>
    private void RegisterOCXControl( FileInfo thisFileInfo )
    {
      Process process = new Process();

      process.StartInfo.FileName = "regsvr32.exe";
      process.StartInfo.UseShellExecute = false;

      //process.StartInfo.Arguments = " /s " + this.m_fileInfoBinary.FullName;
      process.StartInfo.Arguments = " /s " + thisFileInfo.FullName;
      process.StartInfo.CreateNoWindow = true;
      process.Start();
      process.WaitForExit();

      process.Close();
    }

    public void UnregisterOCXControl (bool force)
    {
        this.m_TargetParent.BuildParent.SendLogMessage( "Unregistering control " + this.m_fileInfoOCX.FullName );

        string path = Directory.GetCurrentDirectory();
        if (!Directory.GetCurrentDirectory().EndsWith("\\") || !Directory.GetCurrentDirectory().EndsWith("\\"))
            path += "\\";
        path += "EnhRegSvr.exe";

        this.m_TargetParent.BuildParent.SendLogMessage( path );

        Process process = new Process();
	    if (File.Exists(path))   // As custom control might not exists in directory but works better if it does exist   
        {   
        	process.StartInfo.FileName = "EnhRegSvr.exe";
            process.StartInfo.Arguments = "/u \"" + m_fileInfoOCX.FullName + "\"";
        }
        else
        {
        	process.StartInfo.FileName = "regsvr32.exe";
            process.StartInfo.Arguments = "/u /s \"" + m_fileInfoOCX.FullName + "\"";
        }
        process.StartInfo.UseShellExecute = false;
        process.StartInfo.CreateNoWindow = true;
        process.Start();
        process.WaitForExit();
        process.Close();
    }
  }
}
