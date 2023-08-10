using System;
using System.Collections;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for Projects.
	/// </summary>
	public class Ocxcontrols: IEnumerable
	{
		ArrayList m_arrayList = null;

		public Ocxcontrols()
		{
			m_arrayList = new ArrayList();
		}

		public IEnumerator GetEnumerator()
		{
			return m_arrayList.GetEnumerator();
		}

		public Ocxcontrol this [int intIndex]
		{
			get
			{
				return (Ocxcontrol)m_arrayList[intIndex];
			}
			set
			{
				m_arrayList[intIndex] = value;
			}
		}

		public void Add(Ocxcontrol ocxcontrol)
		{
			m_arrayList.Add(ocxcontrol);
		}

		public void Insert(int Ordinal, Ocxcontrol ocxcontrol)
		{
			m_arrayList.Insert(Ordinal, ocxcontrol);
		}

		public void Remove(Ocxcontrol ocxcontrol)
		{
			m_arrayList.Remove(ocxcontrol);
		}

		public void Clear()
		{
			m_arrayList.Clear();
		}

		public int IndexOf(Ocxcontrol ocxcontrol)
		{
			return m_arrayList.IndexOf(ocxcontrol);
		}

		public int Count
		{
			get { return m_arrayList.Count; }
		}

	}
}
