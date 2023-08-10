// -----------------------------------------------------------------------
// <copyright file="Utils.cs" company="Ascribe">
//      Copyright Ascribe Ltd    
// </copyright>
// <summary>
// Utils for the AMM module
//
// Contains a JSON converter for converting doubles to AMM formatted string
//
// Modification History:
// 18Jun15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System;

    using Newtonsoft.Json;

    /// <summary>JSON converter used to convert double to string for use in the display</summary>
    internal class aMMDoubleToStringConverter : JsonConverter
    {
        /// <summary>If data type can be converted</summary>
        /// <param name="objectType">type to convert</param>
        /// <returns>true of double</returns>
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(double);
        }

        /// <summary>Not implemented</summary>
        /// <param name="reader">reader object</param>
        /// <param name="objectType">object type</param>
        /// <param name="serializer">serialize object</param>
        /// <returns>read object</returns>
        public override object ReadJson(JsonReader reader, Type objectType, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }

        /// <summary>Write double value (in format 0.####) to writer</summary>
        /// <param name="writer">writer object</param>
        /// <param name="value">value to write</param>
        /// <param name="serializer">serialize object</param>
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            serializer.Serialize(writer, ((double)value).ToString("0.####"));
        }
    }
}
