using System;
using System.IO;
using System.Diagnostics;
using System.ComponentModel;
using Microsoft.Win32;
using System.Text.RegularExpressions;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for SourceSafe.
	/// </summary>
	public class SourceSafe
	{
		private string m_strUserName = "";
		private string m_strPassword = "";
		private string m_strProjectRoot = "";
		DirectoryInfo m_directoryInfoLocal = null;
		DirectoryInfo m_folderInfoSourceSafeIni = null;
		FileInfo m_fileInfoExecutable = null;
		Build m_buildParent = null;
		bool m_blnEnable = true;
		Process m_process = null;

		public SourceSafe(Build buildParent)
		{
			m_buildParent = buildParent;
		}

		public bool Enable
		{
			get { return m_blnEnable; }
			set { m_blnEnable = value; }
		}

		public string UserName
		{
			get { return m_strUserName; }
			set { m_strUserName = value; }
		}

		public string Password
		{
			get { return m_strPassword; }
			set { m_strPassword = value; }
		}

		public string ProjectRoot
		{
			get { return m_strProjectRoot; }
			set { m_strProjectRoot = value; }
		}

		public DirectoryInfo directoryInfoLocal
		{
			get { return m_directoryInfoLocal; }
			set { m_directoryInfoLocal = value; }
		}

		public FileInfo fileInfoExecutable
		{
			get { return m_fileInfoExecutable; }
			set { m_fileInfoExecutable = value; }
		}

		public DirectoryInfo SourceSafeIni
		{
			get { return m_folderInfoSourceSafeIni; }
			set { m_folderInfoSourceSafeIni = value; }
		}


		/// <summary>
		/// Set current project to root
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void SetCurrentProjectToRoot()
		{
            string strCommand = "Cp $/" + m_strProjectRoot + " -Y" + m_strUserName + "," + m_strPassword;
			this.ExecuteCommand(strCommand);
		}
		
		/// <summary>
		/// Set current project to root + a path
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void SetCurrentProject(string strPath)
		{
            string strCommand = "Cp $/" + m_strProjectRoot + "/" + strPath + " -Y" + m_strUserName + "," + m_strPassword;
			this.ExecuteCommand(strCommand);
		}
		
		/// <summary>
		/// Set loca working folder for the current project
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void SetWorkingFolderToRoot()
		{
			string strCommand = "Workfold $/" + m_strProjectRoot + " " + m_directoryInfoLocal.FullName + " -Y" + m_strUserName + "," + m_strPassword;
			this.ExecuteCommand(strCommand);
		}

		/// <summary>
		/// Get the latest version of the named SourceSafe project
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void GetLatestRecursive(string strPath)
		{
			m_buildParent.SendLogMessage("\r\nGetting latest version from SourceSafe " + m_strProjectRoot + "/" + strPath + " to " + m_directoryInfoLocal.FullName + "/" + strPath );

//			string strCommand = "Get $/" + m_strProjectRoot + " -R -I- -Y" + m_strUserName + "," + m_strPassword;
			string strCommand = "Get \"$/" + m_strProjectRoot + "/" + strPath + "\"" + " -R -I- -GCC -GWR -GTM -GF- -GL" + m_directoryInfoLocal.FullName + "/" + strPath + " -O- -Y" + m_strUserName + "," + m_strPassword;
			this.ExecuteCommand(strCommand);
		}

		/// <summary>
		/// Check file exists in SourceSafe
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public bool FileExists(string SSPath, string SSName)
		{
			string strCommand = "Directory $/" + m_strProjectRoot + "/" + SSPath+"/"+SSName + " -I- -Y" + m_strUserName + "," + m_strPassword;
			string strOutput = "";
			try
			{
				strOutput = this.ExecuteCommand(strCommand);
			}
			catch (ApplicationException) {}
			return (strOutput.ToLower().StartsWith(SSName.ToLower() + "\r\n" ) );
		}

		/// <summary>
		/// Verify CheckOut Status
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public bool VerifyCheckOutStatus(string SSPath, string SSName)
		{
			if (FileExists(SSPath, SSName))
			{
				string strCommand = "Status $/" + m_strProjectRoot + "/" + SSPath+"/"+SSName + " -I- -Y" + m_strUserName + "," + m_strPassword;
				string strOutput = this.ExecuteCommand(strCommand);
				if (strOutput.IndexOf("No checked out files found")!=-1)
				{
					// Isnt checked out, so go ahead and allow checkout
					return true;
				}
				else
				{
					MatchCollection matches = Regex.Matches(strOutput, @"\s\S+\s");
					if (matches.Count>0)
					{
						if ( matches[0].ToString().Trim().ToLower() != m_strUserName.Trim().ToLower() )
						{
							// Is checked out to a different user, so abort build
							throw new ApplicationException("ERROR: " + SSPath + "/" + SSName + " is checkout to user: " + matches[0].ToString() );
						}
					}
					// Is checked out to this user, so no need to check out again
					return false;
				}
			}
			else
			{
				return false;
			}
		}

		/// <summary>
		/// Checkout files matching search pattern to the root project's working folder
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void CheckOut(string SSPath, string SSName, string TargetFolder)
		{
			m_buildParent.SendLogMessage("\r\nChecking out files from SourceSafe " + @"$/" + m_strProjectRoot + @"/" + SSPath+"/"+SSName + " to " + m_directoryInfoLocal.FullName);

			if (VerifyCheckOutStatus(SSPath, SSName))
			{
				string strCommand = "Checkout $/" + m_strProjectRoot + "/" + SSPath+"/"+SSName + " -I- -Y" + m_strUserName + "," + m_strPassword + " -GF- -GL" + m_directoryInfoLocal.FullName + @"\" + TargetFolder + " -GCC -GWR -GTM";
				this.ExecuteCommand(strCommand);
			}
			// Make sure file is not left read-only
			FileInfo fileInfo = new FileInfo(m_directoryInfoLocal.FullName + @"\" + TargetFolder + @"\" + SSName );
			if ( (fileInfo.Attributes & FileAttributes.ReadOnly) == FileAttributes.ReadOnly )
			{
				fileInfo.Attributes -= FileAttributes.ReadOnly;
			}
		}

		/// <summary>
		/// Checkin files matching search pattern from the root project's working folder
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void CheckIn(string SSPath, string SSName, string TargetFolder)
		{
			m_buildParent.SendLogMessage("\r\nChecking in file to SourceSafe " + @"$/" + m_strProjectRoot + @"/" + SSPath+"/"+SSName + " from " + m_directoryInfoLocal.FullName);

			if (!this.FileExists(SSPath, SSName))
			{
				Add(SSPath, SSName, TargetFolder);
			}
			else
			{
				string strCommand = "Checkin $/" + m_strProjectRoot + "/" + SSPath+"/"+SSName + " -I- -Y" + m_strUserName + "," + m_strPassword + " -GL" + m_directoryInfoLocal.FullName + @"\" + TargetFolder;
				this.ExecuteCommand(strCommand);
			}
		}

		public void Add(string SSPath, string SSName, string TargetFolder)
		{
			m_buildParent.SendLogMessage("\r\nAdding file to SourceSafe " + @"$/" + m_strProjectRoot + @"/" + SSPath+"/"+SSName + " from " + m_directoryInfoLocal.FullName);

			SetCurrentProject(SSPath);

			string strCommand = "Add " + m_directoryInfoLocal.FullName + "/" + SSPath+"/"+SSName + " -I- -Y" + m_strUserName + "," + m_strPassword;
			this.ExecuteCommand(strCommand);

			SetCurrentProjectToRoot();
		}

		/// <summary>
		/// Execute a SourceSafe command using ss.exe command line
		/// </summary>
		/// <param name="strCommand"></param>
		private string ExecuteCommand(string strCommand)
		{
			m_buildParent.SendLogMessage("\t" + strCommand);

			string strOutput = "";
			m_process = new Process();
			try
			{
				m_process.StartInfo.UseShellExecute = false;
				m_process.StartInfo.EnvironmentVariables.Add("SSDIR", m_folderInfoSourceSafeIni.FullName);
				m_process.StartInfo.FileName = m_fileInfoExecutable.FullName;
				m_process.StartInfo.WorkingDirectory = m_directoryInfoLocal.FullName;
				m_process.StartInfo.Arguments = strCommand;
				m_process.StartInfo.RedirectStandardOutput = true; 
				m_process.StartInfo.CreateNoWindow = true;
				m_process.Start();
				while (!m_process.HasExited)
				{
					m_process.WaitForExit(500);
				}
				strOutput = m_process.StandardOutput.ReadToEnd();
				m_buildParent.SendLogMessage(strOutput);
				if (m_process.ExitCode>1)
				{
					throw new ApplicationException("SourceSafe returned error exit code: " + m_process.ExitCode);
				}
			}
			finally
			{
				m_process.Close();
			}
			m_process = null;
			return strOutput;
		}

		/// <summary>
		/// Kill the process
		/// </summary>
		/// <param name="strProjectRoot"></param>
		public void KillProcess()
		{
			if (m_process!=null)
			{
				m_process.Close();
				m_process = null;
			}
		}
		
	}
}
