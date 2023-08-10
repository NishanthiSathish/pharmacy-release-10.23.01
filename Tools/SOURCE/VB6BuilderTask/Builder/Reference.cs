using System;
using System.IO;
using System.Text.RegularExpressions;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for Reference.
	/// </summary>
	public class Reference
	{
		Project m_projectParent;
		Project m_projectRefersTo;
		string m_strOriginalGUID;
		string m_strVersion;
		string m_strZero;
		string m_strPath;
		string m_strShortName;

		public Reference(Project Parent, string OriginalGUID, string Version, string Zero, string Path, string ShortName)
		{
			m_projectParent = Parent;
			m_strOriginalGUID = OriginalGUID;
			m_strVersion = Version;
			m_strZero = Zero;
			m_strPath = Path;
			m_strShortName = ShortName;

			string strAbsoluteDLLPath = new FileInfo( (m_strPath.StartsWith(@".") ? (Parent.FileInfoPrjFile.DirectoryName + @"\") : "") + m_strPath ).FullName;
			Project project = m_projectParent.TargetParent.FindProjectByBinaryPath( strAbsoluteDLLPath );
			if (project!=null)
			{
				m_projectRefersTo = project;
				Parent.ReferenceList.Add(this);

				m_projectParent.TargetParent.BuildParent.SendLogMessage("\t" + m_strPath);
			}
			else
			{
				m_projectParent.TargetParent.BuildParent.SendLogMessage("\tIgnoring: " + m_strPath);
			}
		}

		public Project ProjectReferTo
		{
			get { return m_projectRefersTo; }
			set { m_projectRefersTo = value; }
		}

		public Project ProjectParent
		{
			get { return m_projectParent; }
			set { m_projectParent = value; }
		}

		public string OriginalGUID
		{
			get { return m_strOriginalGUID; }
			set { m_strOriginalGUID = value; }
		}

		public string Version
		{
			get { return m_strVersion; }
			set { m_strVersion = value; }
		}

		public string Zero
		{
			get { return m_strZero; }
			set { m_strZero = value; }
		}

		public string Path
		{
			get { return m_strPath; }
			set { m_strPath = value; }
		}

		public string ShortName
		{
			get { return m_strShortName; }
			set { m_strShortName = value; }
		}

	}
}
