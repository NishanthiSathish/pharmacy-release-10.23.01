using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.ComponentModel;
using Microsoft.Win32;
using System.Globalization;
using TLI;

namespace Ascribe.ICW.BuildTasks
{
  /// <summary>
  /// Summary description for Webpage.
  /// </summary>
  public class Webpage
  {
    public const string WEBPAGE_EXTENSION = "asp";

    Target m_TargetParent = null;
    string m_strShortName = "";
    FileInfo m_fileInfoASP;
    string m_strASPContent = "";
    string m_strGUID = "";
    string m_strPrjFileContent = "";

    public Webpage( Target targetParent, FileInfo fileInfoASP )
    {
      m_TargetParent = targetParent;
      m_fileInfoASP = fileInfoASP;
      m_strShortName = this.m_fileInfoASP.Name.Substring( 0, this.m_fileInfoASP.Name.Length - this.m_fileInfoASP.Extension.Length );
    }

    public FileInfo ASPFileInfo
    {
      get { return m_fileInfoASP; }
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
        if( this.m_fileInfoASP.FullName.IndexOf( "\\COM\\" ) != -1 )
        {
//          return this.m_TargetParent.Name.ToString().Substring( 0, 1 ) + this.m_TargetParent.BuildParent.VersionBranch + this.ShortName.Substring( 0, 4 ) + this.m_TargetParent.BuildParent.VersionBuild;
          return this.m_TargetParent.Name.ToString().Substring(0, 1) + this.m_TargetParent.BuildParent.VersionString() + this.ShortName.Substring(0, 4) + this.m_TargetParent.BuildParent.BuildString();
          //          return this.m_TargetParent.Name.ToString().Substring( 0, 1 ) + this.m_TargetParent.BuildParent.VersionArchitecture + this.m_TargetParent.BuildParent.VersionMajor.ToString() + String.Format( "{0:00}", this.m_TargetParent.BuildParent.VersionMinor ) + this.ShortName.Substring( 0, 4 ) + String.Format( "{0:000}", this.m_TargetParent.BuildParent.VersionBuild );
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
    /// Updates the current webpage with the new CLSID tag
    /// </summary>
    public void UpdateWebpageCLSID()
    {
      string strContent;
      string strObjectContent;
      FileStream fileStream;
      byte[] abyteBuffer;
      int intPos = 0;
      int intStart = 0;
      string strGUID = "";
      string strPath = "";
      string strComponentName = "";
      string strVersionedComponentName = "";
      string strToLowerContent = "";
      string strFileToRead = "";

      RegistryKey registryKeyTypeLib = Registry.LocalMachine.OpenSubKey( @"Software\Classes\CLSID" );	// changed from TypeLib
      RegistryKey registryKeyGUID;
      RegistryKey registryKeyInprocServer32;

      string[] astrSubKeys = registryKeyTypeLib.GetSubKeyNames();
      bool blnFound = false;

      // Read the webpage file from disk
//      fileStream = this.m_fileInfoASP.OpenRead();
//      abyteBuffer = new byte[fileStream.Length];
//      fileStream.Read( abyteBuffer, 0, ( int ) fileStream.Length );
//      strContent = System.Text.Encoding.Default.GetString( abyteBuffer );
 //     fileStream.Close();

      strFileToRead = m_TargetParent.BuildParent.DirectoryInfoBuildRoot + @"\Web\" +
          this.ASPFileInfo.FullName.Substring(this.ASPFileInfo.FullName.IndexOf(@"\Web\") + 5);
      fileStream = new FileStream(strFileToRead, FileMode.Open, FileAccess.Read);
      abyteBuffer = new byte[fileStream.Length];
      fileStream.Read(abyteBuffer, 0, (int)fileStream.Length);
      strContent = System.Text.Encoding.Default.GetString(abyteBuffer);
      fileStream.Close();

      // copy a lower case version of the file content to a string buffer
      strToLowerContent = strContent.ToLower( CultureInfo.InvariantCulture );

      // find the position of the CLSID tag in the file
      intPos = strToLowerContent.IndexOf( "clsid:", 0 );
      if( intPos == -1 )
      {
        // cannot locate clsid tag so throw an exception
        throw new ApplicationException( this.m_fileInfoASP.FullName + " does not contain a CLSID tag" );
      }

      // check the webpage to see if the component tag exists if it does then read it in.
      intStart = strContent.IndexOf( "component", 0 );
      if( intStart != -1 )
      {
        intStart = intStart + "component=\"".Length;
        for( int i = intStart; i < strContent.Length; i++ )
        {
          if( strContent.Substring( i, 1 ) == "\"" )
          {
            strComponentName = strContent.Substring( intStart, i - intStart );
            blnFound = true;
            break;
          }
        }
        if( !blnFound )
        {
          throw new ApplicationException( "No closing quotes on the component tag in file :" + this.ASPFileInfo.FullName );
        }
      }
      //			else
      //			{
      //				this.m_TargetParent.BuildParent.SendLogMessage(this.ASPFileInfo.FullName + " does not contain a COMPONENT tag");
      //				//throw new ApplicationException(this.ASPFileInfo.FullName + " does not contain a COMPONENT tag");
      //			}

      if( strComponentName != "" )
      {
        // make our new component name

        //strVersionedComponentName = m_TargetParent.BuildParent.DirectoryInfoBuildRoot + @"\SmartClient\OCX\Bin\" + strComponentName;
        switch (m_TargetParent.Name)
        {
          case Target.enmName.L:
            strVersionedComponentName = m_TargetParent.BuildParent.DirectoryInfoBuildRoot + @"\SmartClient\OCX\Bin\" + strComponentName;
            break;

          case Target.enmName.R:
            strVersionedComponentName = m_TargetParent.BuildParent.DirectoryInfoBuildRoot.FullName + @"\SmartClient\OCX\Bin\" + strComponentName; 
            //"R" +
             //       m_TargetParent.BuildParent.VersionString() + System.IO.Path.GetFileNameWithoutExtension(strComponentName) +
              //      m_TargetParent.BuildParent.BuildString() + System.IO.Path.GetExtension(strComponentName);
                break;

            case Target.enmName.T:
                strVersionedComponentName = m_TargetParent.BuildParent.DirectoryInfoBuildRoot.FullName + @"\SmartClient\OCX\Bin\" + strComponentName;
                //"T" +
                 //   m_TargetParent.BuildParent.VersionString() + System.IO.Path.GetFileNameWithoutExtension(strComponentName) +
                  //  m_TargetParent.BuildParent.BuildString() + System.IO.Path.GetExtension(strComponentName);
                break;
        }
        //        strVersionedComponentName = m_TargetParent.DirectoryInfoTarget.FullName + @"\SmartClient\OCX\Bin\" + strComponentName;

        blnFound = false;
        if (File.Exists(strVersionedComponentName))
        {
            // Needs to be built in x86 to use 
            var tliiApp = new TLI.TLIApplication();
            var tlii = tliiApp.TypeLibInfoFromFile(strVersionedComponentName);
            for (short c = 1; c < tlii.TypeInfoCount; c++)
            {
                if (tlii.TypeInfos[c].TypeKind == TypeKinds.TKIND_COCLASS)
                {
                    blnFound = true;
                    this.m_strGUID = tlii.TypeInfos[c].GUID.TrimStart(new[] { '{' }).TrimEnd(new[] { '}' });
                    this.m_TargetParent.BuildParent.SendLogMessage("\t\t" + this.m_strGUID);
                    break;
                }
            }

            if (!blnFound)
            {
                this.m_strGUID = string.Empty;
                this.m_TargetParent.BuildParent.SendLogMessage("\t\tFailed to find a CoClass in file " + strVersionedComponentName);
            }
        }
        else
        {
            this.m_strGUID = string.Empty;
            this.m_TargetParent.BuildParent.SendLogMessage("\t\tFailed to find file " + strVersionedComponentName);
        } 

        if (blnFound)
        {
          // copy a lowercase version of the file content to a buffer
          strToLowerContent = strContent.ToLower( CultureInfo.InvariantCulture );

   //         strToLowerContent = File.ReadAllText(strFileToRead).ToLower(CultureInfo.InvariantCulture);

          // find the start position of the classid tag in the file
          intPos = strToLowerContent.IndexOf( "clsid:", 0 );
          if( intPos == -1 )
          {
            // cannot locate clsid tag so throw an exception
            throw new ApplicationException( this.m_fileInfoASP.FullName + " does not contain a CLSID tag" );
          }

          // skip past the clsid: tag in the file
          intPos = intPos + "clsid:".Length;
          strGUID = strContent.Substring( intPos, this.m_strGUID.Length );

          // replace the old GUID (strGUID) with the new one (this.m_strGUID)
          strObjectContent = strContent.Replace( strGUID, this.m_strGUID );

          // writes the modified webpage content back out
          File.SetAttributes(this.m_fileInfoASP.FullName, FileAttributes.Normal);
          this.m_fileInfoASP.Delete();
          FileStream fileStreamW = this.m_fileInfoASP.OpenWrite();
          byte[] buffer = System.Text.Encoding.Default.GetBytes( strObjectContent );
          fileStreamW.Write( buffer, 0, buffer.Length );
          fileStreamW.Close();

          this.m_TargetParent.BuildParent.SendLogMessage( strComponentName + " in " + this.ASPFileInfo.FullName + "\r\nGUID changed to " + this.m_strGUID + "\r\n" );
        }
      }
    }

    /// <summary>
    /// Locate all ASP files within a single folder
    /// </summary>
    /// <param name="directoryInfoThis"></param>
    private void LocateASPXFiles( DirectoryInfo directoryInfoThis )
    {
      // Create an array representing the files in this directory matching said extension
      FileInfo[] afileInfoContents = directoryInfoThis.GetFiles( "*.ASP" );

      // Check for object tag from the array of files found
      foreach( FileInfo fileInfo in afileInfoContents )
      {
        ContainsObjectTag( fileInfo );
      }

      // Create an array representing the directories in this directory.
      DirectoryInfo[] adirectoryInfoContents = directoryInfoThis.GetDirectories();
      foreach( DirectoryInfo directoryInfoSub in adirectoryInfoContents )
      {
        LocateASPXFiles( directoryInfoSub );
      }
    }



    /// <summary>
    /// Search ASP file for the OBJECT tag and if found add to our list of files
    /// </summary>
    /// <param name="fileInfo"></param>
    public bool ContainsObjectTag( FileInfo fileInfo )
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

      // object tag found in file? return true
      if( strContent.IndexOf( "<OBJECT", 0 ) != -1 )
      {
        return true;
      }

      return false;
    }

    /// <summary>
    /// Read and cache the contents of the ASP file into a class string
    /// </summary>
    private string ASPFileContents
    {
      get
      {
        if( m_strASPContent == "" )
        {
          FileStream fileStream = m_fileInfoASP.OpenRead();
          byte[] abyteFile = new byte[fileStream.Length];
          fileStream.Read( abyteFile, 0, ( int ) fileStream.Length );
          m_strASPContent = System.Text.Encoding.Default.GetString( abyteFile );
          fileStream.Close();
        }
        return m_strASPContent;
      }
    }
  }
}
