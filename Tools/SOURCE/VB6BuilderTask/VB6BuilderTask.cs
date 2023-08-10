using System;
using System.IO;
using Microsoft.Build.Utilities;
using Microsoft.Build.Framework;

namespace Ascribe.ICW.BuildTasks
{
  // VB6BuilderTask
  // -----------------
  //
  // Custom MSBuild task to build the VB6 exes and OCXs that are required for use in ICW .NET
  // Parameters are supplied by MSBuild
  //
  public class VB6BuilderTask : Task
  {
      private int m_Stage = 1; // 1 - COpy Activex, 2 - Update web pages live, 3 - Update web pages testing, 4 - Update web pages training
    private string m_VB6Path = string.Empty;
    private string m_BuildBranch = string.Empty;
    private string m_BuildBuildNo = string.Empty;
    private string m_SourceFolder = string.Empty;
    private string m_TargetFolder = string.Empty;
    private string m_WebSourceFolder = string.Empty;
    private bool m_UseSourceSafe = true;
    private string m_SourceSafePath = string.Empty;
    private string m_SourceSafeIniPath = string.Empty;
    private string m_SourceSafeRoot = string.Empty;
    private string m_SourceSafeUser = "builder";
    private string m_SourceSafePassword = "bob";
    private bool m_BuildV8DataConv = true;

    public override bool Execute()
    {
      try
      {
        Build bld = new Build()
        {
          FileInfoVB6 = m_VB6Path == string.Empty ? null : new FileInfo( m_VB6Path ),
          FileInfoVS = string.IsNullOrEmpty(VSPath) ? null : new FileInfo(this.VSPath),
          DirectoryInfoSourceRoot = m_SourceFolder == string.Empty ? null : new DirectoryInfo(m_SourceFolder),
          DirectoryInfoBuildRoot = m_TargetFolder == string.Empty ? null : new DirectoryInfo(m_TargetFolder),
          DirectoryInfoSourceWeb = m_WebSourceFolder == string.Empty ? null : new DirectoryInfo(m_WebSourceFolder),
          VersionBranch = m_BuildBranch,
          VersionBuild = m_BuildBuildNo,
          BuildV8DataConv = m_BuildV8DataConv
        };

        bld.SourceSafe.Enable = m_UseSourceSafe;
        if (m_UseSourceSafe)
        {
            bld.SourceSafe.UserName = m_SourceSafeUser;
            bld.SourceSafe.Password = m_SourceSafePassword;
            bld.SourceSafe.ProjectRoot = m_SourceSafeRoot;
            bld.SourceSafe.SourceSafeIni = new DirectoryInfo(m_SourceSafeIniPath);
            bld.SourceSafe.fileInfoExecutable = new FileInfo(m_SourceSafePath);
        }

        bld.BuildEvent += new Build.delegatetypeBuildEvent(BuildEventListener);

        switch (m_Stage)
        {
			case 0:
				bld.Start(Build.ProcessStage.CreateICWBuildTempFiles);
        		break;

            case 1:
                bld.Start(Build.ProcessStage.GetLatestSource);
                bld.Start(Build.ProcessStage.UpdateActivexSource);
                break;

            case 2:
                bld.Start(Build.ProcessStage.UpdateWebPagesForLive);
                break;

            case 3:
                bld.Start(Build.ProcessStage.UpdateWebPagesForTest);
                break;

            case 4:
                bld.Start(Build.ProcessStage.UpdateWebPagesForTraining);
                break;
        }

        return true;
      }
      catch( Exception ex )
      {
        Log.LogMessage( "The VB6BuilderTask failed with the following error: " + ex.Message );

        return false;
      }
    }

    public void BuildEventListener(string Message)
    {
        try
        {
            Log.LogMessage(Message);
        }
        catch
        {
        }
    }

    public string VB6Path
    {
      get { return m_VB6Path; }
      set { m_VB6Path = value; }
    }

    public string VSPath { get; set; }

    public string BuildBranch
    {
      get { return m_BuildBranch; }
      set { m_BuildBranch = value; }
    }

    public string BuildBuildNo
    {
      get { return m_BuildBuildNo; }
      set { m_BuildBuildNo = value; }
    }

    public string SourceFolder
    {
      get { return m_SourceFolder; }
      set { m_SourceFolder = value; }
    }

    public string TargetFolder
    {
      get { return m_TargetFolder; }
      set { m_TargetFolder = value; }
    }

    public string WebSourceFolder
    {
        get { return m_WebSourceFolder; }
        set { m_WebSourceFolder = value; }
    }

    public int Stage
    {
        get { return m_Stage; }
        set { m_Stage = value; }
    }

    public bool UseSourceSafe
    {
        get { return m_UseSourceSafe; }
        set { m_UseSourceSafe = value; }
    }

    public string SourceSafeUser
    {
        get { return m_SourceSafeUser; }
        set { m_SourceSafeUser = value; }
    }

    public string SourceSafePassword
    {
        get { return m_SourceSafePassword; }
        set { m_SourceSafePassword = value; }
    }

    public string SourceSafePath
    {
        get { return m_SourceSafePath; }
        set { m_SourceSafePath = value; }
    }

    public string SourceSafeIniPath
    {
        get { return m_SourceSafeIniPath; }
        set { m_SourceSafeIniPath = value; }
    }

    public string SourceSafeProjectRoot
    {
        get { return m_SourceSafeRoot; }
        set { m_SourceSafeRoot = value; }
    }

    public bool BuildV8DataConv
    {
        get { return m_BuildV8DataConv; }        
        set { m_BuildV8DataConv = value; }
    }
  }
}
