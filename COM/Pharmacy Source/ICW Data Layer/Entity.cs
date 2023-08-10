//===========================================================================
//
//							Entity.cs
//
//  Provides access to Entity table.
//
//  Classes are derived from BaseRow
//
//  Currently it is not easy to create an instance of this class, it is more to be 
//  used by derived classes that inherit from the Entity table.
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//===========================================================================
using System;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Entity table</summary>
    public class EntityRow : BaseRow
    {
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]); }
        }
    }

    /// <summary>Provides column information about the Entity table</summary>
    public class EntityColumnInfo : BaseColumnInfo
    {
        public EntityColumnInfo(string tableName) : base(tableName) { }
    }

    /// <summary>Represent the Entity table</summary>
    public class Entity<T, C> : BaseTable<T, C>
        where T : EntityRow, new()
        where C : EntityColumnInfo, new()
    {
        public Entity(string tableName, string pkcolumnname) : base(tableName, pkcolumnname) { }
    }
}
