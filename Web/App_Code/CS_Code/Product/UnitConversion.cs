using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml;

namespace Ascribe.OrderEntry
{
	/// <summary>
	/// Provide an *efficient* mechanism for Unit Conversions
	/// </summary>
	public class UnitConversion
	{
		/// <summary>
		/// Represents a row the Unit table of the database
		/// </summary>
		public struct UnitDefinition
		{
			public uint UnitID;
			public uint UnitID_LCD; // Pointer to the base unit for this unit type
			public uint UnitTypeID;
			public string Description;
			public string Abbreviation;
			public double Multiple; // Multiple of the base unit
		}

		public struct UnitConversionResult
		{
			public double ConvertedValue;
			public UnitDefinition UnitDefinition;
		}

		private int _SessionID = 0; // Hold's a valid sessionid for the lifetime of this class
		private Dictionary<uint, UnitDefinition> _UnitDefinitionCache = new Dictionary<uint, UnitDefinition>(); // Hold's the "cache" of UnitDefinitions

		// Constructor	
		public UnitConversion(int SessionID)
		{
			DSSRTL20.UnitsRead UnitsRead = new DSSRTL20.UnitsRead();
			XmlDocument xmldoc = new XmlDocument();
			XmlNodeList xmlnodelist;

			_SessionID = SessionID;

			// Build up a "cache" of all Unit rows in the database.
			// Note, Units are loaded in the order: UnitID, Multiple

			xmldoc.LoadXml(UnitsRead.GetUnitList(_SessionID));
			xmlnodelist = xmldoc.SelectNodes("//Unit");

			XmlElement xmlele = (XmlElement)xmlnodelist[xmlnodelist.Count - 1];

			while (xmlele != null)
			{
				_UnitDefinitionCache.Add(uint.Parse(xmlele.GetAttribute("UnitID")),
						new UnitDefinition
						{
							UnitID = uint.Parse(xmlele.GetAttribute("UnitID")),
							UnitID_LCD = uint.Parse(xmlele.GetAttribute("UnitID_LCD")),
							UnitTypeID = uint.Parse(xmlele.GetAttribute("UnitTypeID")),
							Description = xmlele.GetAttribute("Description"),
							Abbreviation = xmlele.GetAttribute("Abbreviation"),
							Multiple = double.Parse(xmlele.GetAttribute("Multiple"))
						}
				);
				xmlele = (XmlElement)xmlele.PreviousSibling;
			}
		}

		/// <summary>
		/// Converts a value into the base unit for its unit type.
		/// </summary>
		public UnitConversionResult ConvertToBaseUnit(double Value, uint UnitID)
		{
			// Find UnitDefinition for the supplied UnitID
			UnitDefinition Supplied = _UnitDefinitionCache[UnitID];

			// Find "base" unit for the unit's type.
			UnitDefinition Lcd = _UnitDefinitionCache[Supplied.UnitID_LCD];

			// Convert the supplied value into units of the base unit 
			return new UnitConversionResult
				{
					UnitDefinition = Lcd,
					ConvertedValue = (Value * Supplied.Multiple)
				};
		}

		/// <summary>
		///     Given a floating point number expressed in a given unit, returns it
		///		converted to the smallest unit in which it can be expressed as an integer.
		///
		///		e.g.
		///				1.56g -> 1560mg
		///				0.82mg -> 820mcg
		/// </summary>
		public UnitConversionResult ConvertToSmallestInteger(double Value, uint UnitID)
		{
			// First convert to base unit
			UnitConversionResult ucrBase = ConvertToBaseUnit(Value, UnitID);
			UnitConversionResult ucrAnswer = new UnitConversionResult();

			// Iterate through all the available units, from greatest to lowest magnitude,
			// stopping on the first unit that gives us an integer.
			foreach (KeyValuePair<uint, UnitDefinition> kvp in _UnitDefinitionCache)
			{
				// This "if" ensures that we only look at definitions that are of the same Unit Type as the Lcd
				if (kvp.Value.UnitTypeID == ucrBase.UnitDefinition.UnitTypeID)
				{
					ucrAnswer.ConvertedValue = ucrBase.ConvertedValue / kvp.Value.Multiple;
					ucrAnswer.UnitDefinition = kvp.Value;
					// Test if answer is an integer
					if (ucrAnswer.ConvertedValue == Math.Truncate(ucrAnswer.ConvertedValue))
					{
						// Add the Unit defininition into the result, and exit to return the answer!
						break;
					}
				}
			}

			return ucrAnswer; ;
		}

		/// <summary>
		/// Converts a value into the base unit for its unit type.
		/// </summary>
		public UnitConversionResult ConvertToSpecifiedUnit(double Value_From, uint UnitID_From, uint UnitID_To)
		{
			// Find UnitDefinition for the supplied UnitID
			UnitDefinition Unit_From = _UnitDefinitionCache[UnitID_From];

			// Find "base" unit for the unit's type.
			UnitDefinition Base = _UnitDefinitionCache[Unit_From.UnitID_LCD];

			// Find "base" unit for the unit's type.
			UnitDefinition Unit_To = _UnitDefinitionCache[UnitID_To];

			// Convert the supplied value into units of the base unit 
			return new UnitConversionResult
			{
				UnitDefinition = Unit_To,
				ConvertedValue = (Value_From * Unit_From.Multiple / Unit_To.Multiple)
			};
		}

		/// <summary>
		/// Return the Unit Definition of the given UnitID
		/// </summary>
		/// <returns></returns>
		public UnitDefinition GetUnitDefinitionByID(uint UnitID)
		{
			return _UnitDefinitionCache[UnitID];
		}
		
		/// <summary>
		/// Return the Unit Definition of the given UnitID
		/// </summary>
		/// <returns></returns>
		public UnitDefinition GetUnitDefinitionByAbbreviation(string Abbreviation)
		{
			foreach (KeyValuePair<uint, UnitDefinition> kvp in _UnitDefinitionCache)
			{
				if (kvp.Value.Abbreviation == Abbreviation)
				{
					return kvp.Value;
				}
			}
			return new UnitDefinition();
		}
	}
}