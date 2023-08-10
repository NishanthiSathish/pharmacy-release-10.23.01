//===========================================================================
//
//							Unit.cs
//
//  Provides access to Unit table.
//
//  Note that this uses BaseTable2 class 
//
//  Only supports reading.
//
//	Modification History:
//	15Nov11 XN  Written
//  22Aug14 XN  Converted LoadByDescription to non XML version as XML comes back different on some live servers
//  18Jun15 XN  Add UnitRow properties UnitIdLcd, Multiple and ToString
//              Add Unit LoadByID, LoadByAbbreviation, GetByUnitID, GetByAbbreviation, and Convert
//===========================================================================
namespace ascribe.pharmacy.icwdatalayer
{
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    /// <summary>Represents a record in the Unit table </summary>
    public class UnitRow : BaseRow
    {
        public int UnitID           { get { return FieldToInt(RawRow["UnitID"]).Value;          } }
        public string Description   { get { return FieldToStr(RawRow["Description"]);           } }
        public string Abbreviation  { get { return FieldToStr(RawRow["Abbreviation"]);          } }

        /// <summary>Base unit type for g, or mg will be kg 18Jun15 XN 39882</summary>
        public int UnitIdLcd { get { return FieldToInt(RawRow["UnitID_LCD"]).Value; } }

        /// <summary>Multiplier to base unit type 18Jun15 XN 39882</summary>
        public double Muliple { get { return FieldToDouble(RawRow["Multiple"]).Value; } }

        /// <summary>Returns the abbreviation 18Jun15 XN 39882</summary>
        /// <returns>abbreviation text</returns>
        public override string ToString()
        {
            return this.Abbreviation;
        }
    }

    /// <summary>Provides column information about the Unit tables</summary>
    public class UnitColumnInfo : BaseColumnInfo
    {
        public UnitColumnInfo() : base("Unit") {}
    }

    /// <summary>Represent the Unit table</summary>
    public class Unit : BaseTable2<UnitRow, UnitColumnInfo>
    {
        public Unit() : base("Unit") { }

        /// <summary>Load unit by ID 18Jun15 XN 39882</summary>
        /// <param name="unitId">Unit id</param>
        public void LoadByID(int unitId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("UnitID", unitId);
            this.LoadBySP("pUnitByUnitID", parameters);
        }

        /// <summary>Loads the unit by description</summary>
        /// <param name="descritpion">Unit descritpion name</param>
        public void LoadByDescription(string descritpion)
        {     
            LoadBySQL("Exec pUnitByDescription @CurrentSessionID={0}, @Description='{1}'", SessionInfo.SessionID, descritpion);            
        }

        /// <summary>Loads the unit by abbreviation 18Jun15 XN 39882</summary>
        /// <param name="abbreviation">Unit abbreviation name</param>
        public void LoadByAbbreviation(string abbreviation)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("Abbreviation", abbreviation);
            this.LoadBySP("pUnitByAbbreviation", parameters);
        }

        /// <summary>Gets unit by Unit ID or null 18Jun15 XN 39882</summary>
        /// <param name="unitId">Unit id</param>
        /// <returns>Unit or null</returns>
        public static UnitRow GetByUnitID(int unitId)
        {
            Unit unit = new Unit();
            unit.LoadByID(unitId);
            return unit.FirstOrDefault();
        }

        /// <summary>Gets unit by abbreviation or null 18Jun15 XN 39882</summary>
        /// <param name="abbreviation">Unit abbreviation name</param>
        /// <returns>Unit or null</returns>
        public static UnitRow GetByAbbreviation(string abbreviation)
        {
            Unit unit = new Unit();
            unit.LoadByAbbreviation(abbreviation);
            return unit.FirstOrDefault();
        }

        /// <summary>Converts unit 18Jun15 XN 39882</summary>
        /// <param name="value">Value to convert</param>
        /// <param name="from">unit value is in</param>
        /// <param name="to">convert value to</param>
        /// <returns>Converts value (or null if from and to not same UnitIdLcd type)</returns>
        public static double? Convert(double value, UnitRow from, UnitRow to)
        {
            if (from.UnitIdLcd != to.UnitIdLcd)
            {
                return null;
            }

            return (value * from.Muliple) / to.Muliple;
        }

        /// <summary>Convert unit 18Jun15 XN 39882</summary>
        /// <param name="value">Value to convert</param>
        /// <param name="fromUnitId">unit value is in</param>
        /// <param name="toUnitAbberviation">convert value to</param>
        /// <returns>Converts value (or null if from and to not same UnitIdLcd type)</returns>
        public static double? Convert(double value, int fromUnitId, string toUnitAbberviation)
        {
            UnitRow to = Unit.GetByAbbreviation(toUnitAbberviation);
            return fromUnitId == to.UnitID ? value : Unit.Convert(value, Unit.GetByUnitID(fromUnitId), to);
        }
    }
}
