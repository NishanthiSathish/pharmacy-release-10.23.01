//===========================================================================
//
//							  ReflectionExtensions.cs
//
//	Helper methods for the reflection class
//      
//	Modification History:
//	27Oct11 XN  Written
//===========================================================================using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Linq.Expressions;
using System;

namespace ascribe.pharmacy.shared
{
    public static class ReflectionExtensions
    {
        /// <summary>
        /// requires only object type 
        /// string propName = GetPropertyName{ObjectType}(c => c.Property1); 
        /// </summary>
        public static string GetPropertyName<T,R>(Expression<Func<T,R>> expression)  
        {  
            return (expression.Body as MemberExpression).Member.Name;  
        }  

        /// <summary>
        /// note that in this case we don't need to specify types of x and Property1
        /// ObjectType x = new ObjectType();  
        /// string propName1 = GetPropertyName(() => x.Property1)
        /// </summary>
        public static string GetPropertyName<T>(Expression<Func<T>> expression)  
        {  
            return (expression.Body as MemberExpression).Member.Name;  
        }  
    }
}
