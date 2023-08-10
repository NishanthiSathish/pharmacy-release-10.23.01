using System;
using System.Collections;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for Projects.
	/// </summary>
	public class Webpages: IEnumerable
	{
		ArrayList m_arrayList = null;

		public Webpages()
		{
			m_arrayList = new ArrayList();
		}

		public IEnumerator GetEnumerator()
		{
			return m_arrayList.GetEnumerator();

		}

		public Webpage this [int intIndex]
		{
			get
			{
				return (Webpage)m_arrayList[intIndex];
			}
			set
			{
				m_arrayList[intIndex] = value;
			}
		}

		public void Add(Webpage webpage)
		{
			m_arrayList.Add(webpage);
		}

		public void Insert(int Ordinal, Webpage webpage)
		{
			m_arrayList.Insert(Ordinal, webpage);
		}

		public void Remove(Webpage webpage)
		{
			m_arrayList.Remove(webpage);
		}

		public void Clear()
		{
			m_arrayList.Clear();
		}

		public int IndexOf(Webpage webpage)
		{
			return m_arrayList.IndexOf(webpage);
		}

		public int Count
		{
			get { return m_arrayList.Count; }
		}

	}
}
