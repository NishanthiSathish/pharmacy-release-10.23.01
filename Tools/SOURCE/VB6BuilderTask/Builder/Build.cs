using System;
using System.IO;
using System.Text.RegularExpressions;
using System.ComponentModel;
using System.Diagnostics;
using Microsoft.Win32;

namespace Ascribe.ICW.BuildTasks
{
  /// <summary>
  /// Summary description for Build.
  /// </summary>
  public class Build
  {
      public enum ProcessStage { CreateICWBuildTempFiles, UpdateActivexSource, UpdateWebPagesForLive, UpdateWebPagesForTest, UpdateWebPagesForTraining, GetLatestSource };

      public delegate void delegatetypeBuildEvent(string Message);

    public event delegatetypeBuildEvent BuildEvent;

    public string VersionBranch;
    public string VersionBuild;
    FileInfo m_fileInfoVB6 = null;
    DirectoryInfo m_directoryInfoSourceRoot = null;
    DirectoryInfo m_directoryInfoBuildRoot = null;
    DirectoryInfo m_directoryInfoSourceWeb = null;
    SourceSafe m_SourceSafe;
    Target m_targetLive = null;
    Target m_targetTraining = null;
    Target m_targetTesting = null;
    ProcessStage m_processStage;

    public Build()
    {
        m_SourceSafe = new SourceSafe(this);
    }

    public DirectoryInfo DirectoryInfoSourceRoot
    {
      get { return m_directoryInfoSourceRoot; }
      set { m_directoryInfoSourceRoot = value; }
    }

    public DirectoryInfo DirectoryInfoBuildRoot
    {
      get { return m_directoryInfoBuildRoot; }
      set { m_directoryInfoBuildRoot = value; }
    }

    public DirectoryInfo DirectoryInfoSourceWeb
    {
        get { return m_directoryInfoSourceWeb; }
        set { m_directoryInfoSourceWeb = value; }
    }

    public FileInfo FileInfoVB6
    {
      get { return m_fileInfoVB6; }
      set { m_fileInfoVB6 = value; }
    }

    public FileInfo FileInfoVS { get; set; }

    public SourceSafe SourceSafe
    {
        get { return m_SourceSafe; }
        set { m_SourceSafe = value; }
    }

    public bool BuildV8DataConv { get; set; }

    /// <summary>
    /// Begin the build process
    /// </summary>
    public void Start( ProcessStage stage )
    {
//      this.BuildEvent( "Build version " + this.VersionBranch + "." + this.VersionBuild + "." + this.VersionRelease + " commencing... " );

      try
      {
          m_processStage = stage;

        // Validate paths
		  if(m_processStage == ProcessStage.CreateICWBuildTempFiles)
		  {
			  if (!m_fileInfoVB6.Exists)
			  {
				  throw new ApplicationException("VB6 cannot be found at location: " + m_fileInfoVB6.FullName);
			  }
			  if (!m_directoryInfoSourceRoot.Exists)
			  {
				  throw new ApplicationException("The Source folder does not exist: " + m_directoryInfoSourceRoot.FullName);
			  }
			  if (!m_directoryInfoBuildRoot.Exists)
			  {
				  throw new ApplicationException("The Target folder does not exist: " + m_directoryInfoBuildRoot.FullName);
			  }

			  // if sourcesafe has been enabled then validate the sourcesafe parameters
			  if (m_SourceSafe.Enable == true)
			  {
				  if (!m_SourceSafe.fileInfoExecutable.Exists)
				  {
					  throw new ApplicationException("SourceSafe SS.EXE cannot be found at location: " + m_SourceSafe.fileInfoExecutable.FullName);
				  }
				  if (!m_SourceSafe.SourceSafeIni.Exists)
				  {
					  throw new ApplicationException("SourceSafe sourcesafe.ini cannot be found at location: " + m_SourceSafe.SourceSafeIni.FullName);
				  }
			  }

			  // Create Version folder within the Build folder
			  DirectoryInfo directoryInfoVersion = new DirectoryInfo(m_directoryInfoBuildRoot.FullName + @"\Build_" + this.VersionBranch + "-" + this.VersionBuild);
			  if (this.BuildEvent != null)
				  this.BuildEvent("\r\nCreating Version folder: " + directoryInfoVersion.FullName);
			  if (!directoryInfoVersion.Exists)
			  {
				  directoryInfoVersion.Create();
			  }
			  m_targetLive = new Target(Target.enmName.L, directoryInfoVersion, this, m_SourceSafe);
			  m_targetLive.EstablishTargetBuildFolder();
			  m_targetLive = null;

			  m_targetTraining = new Target(Target.enmName.R, directoryInfoVersion, this, m_SourceSafe);
			  m_targetTraining.EstablishTargetBuildFolder();
			  m_targetTraining = null;

			  m_targetTesting = new Target(Target.enmName.T, directoryInfoVersion, this, m_SourceSafe);
			  m_targetTesting.EstablishTargetBuildFolder();
			  m_targetTesting = null;
		  }
		  else if (m_processStage == ProcessStage.UpdateActivexSource)
          {
              if (!m_fileInfoVB6.Exists)
              {
                  throw new ApplicationException("VB6 cannot be found at location: " + m_fileInfoVB6.FullName);
              }
              if (!m_directoryInfoSourceRoot.Exists)
              {
                  throw new ApplicationException("The Source folder does not exist: " + m_directoryInfoSourceRoot.FullName);
              }
              if (!m_directoryInfoBuildRoot.Exists)
              {
                  throw new ApplicationException("The Target folder does not exist: " + m_directoryInfoBuildRoot.FullName);
              }

              // if sourcesafe has been enabled then validate the sourcesafe parameters
              if (m_SourceSafe.Enable == true)
              {
                  if (!m_SourceSafe.fileInfoExecutable.Exists)
                  {
                      throw new ApplicationException("SourceSafe SS.EXE cannot be found at location: " + m_SourceSafe.fileInfoExecutable.FullName);
                  }
                  if (!m_SourceSafe.SourceSafeIni.Exists)
                  {
                      throw new ApplicationException("SourceSafe sourcesafe.ini cannot be found at location: " + m_SourceSafe.SourceSafeIni.FullName);
                  }
              }

              // Create Version folder within the Build folder
              DirectoryInfo directoryInfoVersion = new DirectoryInfo(m_directoryInfoBuildRoot.FullName + @"\Build_" + this.VersionBranch + "-" + this.VersionBuild);

              // Create each target build Live, Training & Test

              m_targetLive = new Target(Target.enmName.L, directoryInfoVersion, this, m_SourceSafe);
              m_targetLive.Create();
              m_targetLive = null;

              m_targetTraining = new Target(Target.enmName.R, directoryInfoVersion, this, m_SourceSafe);
              m_targetTraining.Create();
              m_targetTraining = null;

              m_targetTesting = new Target(Target.enmName.T, directoryInfoVersion, this, m_SourceSafe);
              m_targetTesting.Create();
              m_targetTesting = null;
          }
          else if (m_processStage == ProcessStage.GetLatestSource)
          {
              m_SourceSafe.directoryInfoLocal = m_directoryInfoSourceRoot;// new DirectoryInfo(m_directoryInfoBuildRoot.FullName + @"\Build_" + this.VersionBranch + "-" + this.VersionBuild);
              var tgt = new Target(Target.enmName.Source, m_SourceSafe.directoryInfoLocal, this, m_SourceSafe);

              tgt.GetSourceLatest();
          }
          else
          {
            Target.enmName targetType = Target.enmName.Source;

            switch (m_processStage)
            {
              case ProcessStage.UpdateWebPagesForLive:
                targetType = Target.enmName.L;
                break;

              case ProcessStage.UpdateWebPagesForTest:
                targetType = Target.enmName.T;
                break;

              case ProcessStage.UpdateWebPagesForTraining:
                targetType = Target.enmName.R;
                break;
            }

              var tgt = new Target(targetType, m_directoryInfoSourceWeb, this, m_SourceSafe );

              m_directoryInfoBuildRoot = 
                  new DirectoryInfo(m_directoryInfoBuildRoot.FullName + @"\Build_" + this.VersionBranch + "-" + this.VersionBuild); 
              
              tgt.UpdateWebPages();
          }

//        this.BuildEvent( "\r\nBuild version " + this.VersionBranch + "." + this.VersionBuild + " completed." );
      }
      catch( Exception x )
      {
          if (this.BuildEvent != null)
          {
              this.BuildEvent("\r\n\r\n" + x.Source + " - " + x.Message + "\r\n" + x.StackTrace.ToString());
              this.BuildEvent("\r\n\r\nBUILD FAILED DUE TO ERROR.");
          }
          else
              throw;
      }
    }

    /// <summary>
    /// Send a log message to the GUI
    /// </summary>
    /// <param name="Message"></param>
    public void SendLogMessage( string Message )
    {
        if (this.BuildEvent != null)
            this.BuildEvent(Message);
    }

    /// <summary>
    /// Terminate all running processes
    /// </summary>
    public void KillProcesses()
    {
        this.m_SourceSafe.KillProcess();
    }

    public string VersionString()
    {
      string result = string.Empty;

      string[] version = VersionBuild.Split('.');

      for (int i = 0; i <= 2 && version.Length > i; i++)
      {
        result += version[i];
      }

      return result;
    }

    public string BuildString()
    {
      string result = string.Empty;

      string[] version = VersionBuild.Split('.');

      if (version.Length >= 4)
      {
        for (int i = 3 - version[3].Length; i >= 1; i--)
          result += "0";
        result += version[3];
      }
      else
      {
        result = "000";
      }

      return result;
    }
  }
}