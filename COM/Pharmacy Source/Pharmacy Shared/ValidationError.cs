//===========================================================================
//
//							     ValidationError.cs
//
// This is just a container for a single validation error. 
// The ClassName should be set the the name of the Obect that raised the 
// validation error. PropertyName should be set to the name of the Object
// property that failed validation.  The ErrorMessage should
// contain message that will be sent back to the application.
// Note that ErrorMessage should not include the property name.
// Instead it should contain [PropertyName] tags, which can then
// be replaced with the property name by the application.  This
// addresses the issue of UI's that use a different name for
// the property.
//
//      
//	Modification History:
//	05May09 AJK  Written
//===========================================================================

using System.Collections.Generic;

namespace ascribe.pharmacy.shared
{
    /// <summary>
    /// This is just a container for a single validation error. 
    /// The ClassName should be set the the name of the Obect that raised the 
    /// validation error. PropertyName should be set to the name of the Object
    /// property that failed validation.  The ErrorMessage should
    /// contain message that will be sent back to the application.
    /// Note that ErrorMessage should not include the property name.
    /// Instead it should contain [PropertyName] tags, which can then
    /// be replaced with the property name by the application.  This
    /// addresses the issue of UI's that use a different name for
    /// the property.
    /// </summary>
    public class ValidationError
    {
        #region "Contstants"
        public const string PropertyNameTag = "[PropertyName]";
        #endregion

        #region "Properties"

        /// <summary>
        /// ClassName is required. It tells us which entity triggered
        /// the validation error.
        /// </summary>
        public string ClassName { get; set; }

        /// <summary>
        /// PropertyName is required.  It tells us which entity field
        /// value triggered the validation error.
        /// </summary>
        public string PropertyName { get; set; }

        /// <summary>
        /// ErrorCode is optional. It allows us to set and read
        /// a numeric error code.
        /// </summary>
        public int ErrorCode { get; set; }

        /// <summary>
        /// Name of the key used to identify the object which triggered the validation error within a collection.
        /// </summary>
        public string KeyName { get; set; }

        /// <summary>
        /// Value of the key used to identify the object which triggered the validation error withn a collection.
        /// </summary>
        public string KeyValue { get; set; }

        /// <summary>
        /// Contains the [PropertyName] marker instead of field names. 
        /// This allows us to replace with a UI-friendly name.
        /// </summary>
        public string ErrorMessage { get; set ;}

        public bool Exception { get; set; }

        #endregion

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="sender">Full name of the object the error was raised from</param>
        /// <param name="propertyName">Name of the property the error relates to</param>
        /// <param name="keyName">Name of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="keyValue">Value of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="errorMessage">The error message to be displayed</param>
        public ValidationError(object sender, string propertyName, string keyName, string keyValue, string errorMessage, bool exception)
        {
            ClassName = sender.GetType().FullName;
            PropertyName = propertyName;
            KeyName = keyName;
            KeyValue = keyValue;
            ErrorMessage = errorMessage;
            Exception = exception;
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="sender">Full nnme of the object the error was raised from</param>
        /// <param name="propertyName">Name of the property the error relates to</param>
        /// <param name="keyName">Name of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="keyValue">Value of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="errorMessage">The error message to be displayed</param>
        /// <param name="errorCode">The error code</param>
        public ValidationError(object sender,  string propertyName, string keyName, string keyValue, string errorMessage, bool exception,  int errorCode)
        {
            ClassName = sender.GetType().FullName;
            PropertyName = propertyName;
            KeyName = keyName;
            KeyValue = keyValue;
            ErrorMessage = errorMessage;
            Exception = exception;
            ErrorCode = errorCode;
        }

        public ValidationError()
        {
        }


        /// <summary>
        /// Returns a string representation of the ValidationError.
        /// </summary>
        /// <returns>ValidationError message with replaced property name tags</returns>
        public override string ToString()
        {
 	        return ErrorMessage.Replace("[PropertyName]", PropertyName);
        }
    }

    /// <summary>
    /// Provides a list of ValidationError objects
    /// </summary>
    public class ValidationErrorList : List<ValidationError>
    {
        /// <summary>
        /// Adds a validation error to the list
        /// </summary>
        /// <param name="sender">Full name of the object the error was raised from</param>
        /// <param name="propertyName">Name of the property the error relates to</param>
        /// <param name="keyName">Name of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="keyValue">Value of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="errorMessage">The error message to be displayed</param>
        /// <param param name="exception">if error is an exception</param>
        public void Add(object sender, string propertyName, string keyName, string keyValue, string errorMessage, bool exception)
        {
            Add( new ValidationError(sender, propertyName, keyName, keyValue, errorMessage, exception) );
        }

        /// <summary>
        /// Adds a validation error to the list
        /// </summary>
        /// <param name="sender">Full name of the object the error was raised from</param>
        /// <param name="propertyName">Name of the property the error relates to</param>
        /// <param name="keyName">Name of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="keyValue">Value of the key used to identify the object in a collection which triggered the validation error</param>
        /// <param name="errorMessage">The error message to be displayed</param>
        /// <param name="exception">if error is an exception</param>
        /// <param param name="errorCode">error code</param>
        public void Add(object sender, string propertyName, string keyName, string keyValue, string errorMessage, bool exception, int errorCode)
        {
            Add( new ValidationError(sender, propertyName, keyName, keyValue, errorMessage, exception, errorCode) );
        }
    }
}
