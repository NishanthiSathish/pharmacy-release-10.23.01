//===========================================================================
//
//							   BaseTableEnumerator.cs
//
//	Enumerator class for the BaseTable.
//
//  Should not be called directly only via BaseTable.GetEnumerator.
//
//  Usage:
//      
//	Modification History:
//	15Apr09 XN  Written
//===========================================================================
using System;
using System.Collections;
using System.Collections.Generic;

namespace ascribe.pharmacy.basedatalayer
{
    public class BaseTableEnumerator<T, C> : IEnumerator<T>
        where T : BaseRow, new()
        where C : BaseColumnInfo, new()
    {
        #region Member variables
        private BaseTable<T,C> table;   // Table the enumerator is for
        private int position = -1;      // Row position of the enumerator
        #endregion

        #region Constructor
        public BaseTableEnumerator(BaseTable<T,C> rows)
        {
            this.table = rows;
        }
        #endregion

        #region IEnumerator<T> Members
        /// <summary>
        /// Returns current position in the array
        /// </summary>
        public T Current
        {
            get
            {
                try
                {
                    return table[position];
                }
                catch (IndexOutOfRangeException )
                {
                    throw new InvalidOperationException();
                }
            }
        }
        #endregion

        #region IDisposable Members
        public void Dispose()
        {
        }
        #endregion

        #region IEnumerator Members
        /// <summary>
        /// Returns current position in the array
        /// </summary>
        object IEnumerator.Current
        {
            get
            {
                try
                {
                    return table[position];
                }
                catch (IndexOutOfRangeException )
                {
                    throw new InvalidOperationException();
                }
            }
        }
        
        /// <summary>
        /// Move to next position returns false if reached end of the array.
        /// </summary>
        /// <returns></returns>
        public bool MoveNext()
        {
            position++;
            return (position < table.Count);
        }

        /// <summary>
        /// Reset to start of array
        /// </summary>
        public void Reset()
        {
            position = -1;
        }
        #endregion
    }
}
