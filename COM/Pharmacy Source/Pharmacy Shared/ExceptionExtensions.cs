//===========================================================================
//
//							      ExceptionExtensions.cs
//
//  Provides extension methods for the Exception type
//
//  Usage:
//  To return the messages, and all inner messages
//  catch (Exception ex)
//  {
//      MessageBox.Show(ex.GetAllMessaages().ToCSVString("\n"));    
//  }
//
//	Modification History:
//  01Nov13 XN  Written 56701
//  25Aug15 XN  Added GetAllStackTrace
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.shared
{
    
    /// <summary>Extensions method for the exception class</summary>
    public static class ExceptionExtensions
    {
        /// <summary>Returns the exception message, and all inner exception messages</summary>
        public static IEnumerable<string> GetAllMessaages(this Exception ex)
        {
            while (ex != null)
            {
                yield return ex.Message;
                ex = ex.InnerException;
            }
        }

        /// <summary>Returns the stack trace, and all inner stack trace messages 25Aug15 XN</summary>
        /// <param name="ex">Exception</param>
        /// <returns>Stack trace and all inner stack traces</returns>
        public static IEnumerable<string> GetAllStackTrace(this Exception ex)
        {
            while (ex != null)
            {
                yield return ex.StackTrace;
                ex = ex.InnerException;
            }
        }
    }
}
