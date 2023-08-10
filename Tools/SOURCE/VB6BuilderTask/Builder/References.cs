using System;
using System.Collections;

namespace Ascribe.ICW.BuildTasks
{
	/// <summary>
	/// Summary description for References.
	/// </summary>
	public class References: IEnumerable
	{
		ArrayList m_arrayList = null;

		public References()
		{
			m_arrayList = new ArrayList();
		}

		public IEnumerator GetEnumerator()
		{
			return m_arrayList.GetEnumerator();
		}

		public Reference this [int intIndex]
		{
			get
			{
				return (Reference)m_arrayList[intIndex];
			}
			set
			{
				m_arrayList[intIndex] = value;
			}
		}

		public void Add(Reference Reference)
		{
			m_arrayList.Add(Reference);
		}

		public void Insert(int Ordinal, Reference Reference)
		{
			m_arrayList.Insert(Ordinal, Reference);
		}

		public void Remove(Reference Reference)
		{
			m_arrayList.Remove(Reference);
		}

	}
}
