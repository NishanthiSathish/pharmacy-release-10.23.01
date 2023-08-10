using System;
using System.Collections;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for Projects.
	/// </summary>
	public class Projects: IEnumerable
	{
		ArrayList m_arrayList = null;

		public Projects()
		{
			m_arrayList = new ArrayList();
		}

		public IEnumerator GetEnumerator()
		{
			return m_arrayList.GetEnumerator();
		}

		public Project this [int intIndex]
		{
			get
			{
				return (Project)m_arrayList[intIndex];
			}
			set
			{
				m_arrayList[intIndex] = value;
			}
		}

		public void Add(Project project)
		{
			m_arrayList.Add(project);
		}

		public void Insert(int Ordinal, Project project)
		{
			m_arrayList.Insert(Ordinal, project);
		}

		public void Remove(Project project)
		{
			m_arrayList.Remove(project);
		}

		public void Clear()
		{
			m_arrayList.Clear();
		}

		public int IndexOf(Project project)
		{
			return m_arrayList.IndexOf(project);
		}

		public int Count
		{
			get { return m_arrayList.Count; }
		}

	}
}
