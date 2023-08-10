// -----------------------------------------------------------------------
// <copyright file="Address.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to Address table.
//
// Modification History:
// 10Apr16 XN Created 123082
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.icwdatalayer
{
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Row in the Address table</summary>
    public class AddressRow : BaseRow
    {
        public int AddressID            { get { return FieldToInt(RawRow["AddressID"]).Value; }                                         }
        public string DoorNumber        { get { return FieldToStr(RawRow["DoorNumber"], trimString: true, nullVal: string.Empty ); }    }
        public string Building          { get { return FieldToStr(RawRow["Building"], trimString: true, nullVal: string.Empty ); }      }
        public string Street            { get { return FieldToStr(RawRow["Street"], trimString: true, nullVal: string.Empty ); }        }
        public string Town              { get { return FieldToStr(RawRow["Town"], trimString: true, nullVal: string.Empty ); }          }
        public string LocalAuthority    { get { return FieldToStr(RawRow["LocalAuthority"], trimString: true, nullVal: string.Empty ); }}
        public string District          { get { return FieldToStr(RawRow["District"], trimString: true, nullVal: string.Empty ); }      }
        public string PostCode          { get { return FieldToStr(RawRow["PostCode"], trimString: true, nullVal: string.Empty ); }      }
        public string Province          { get { return FieldToStr(RawRow["Province"], trimString: true, nullVal: string.Empty ); }      }
        public string Country           { get { return FieldToStr(RawRow["Country"], trimString: true, nullVal: string.Empty ); }       }
    }


    /// <summary>Table info for Address table</summary>
    public class AddressColumnInfo : BaseColumnInfo
    {
        public AddressColumnInfo() : base("Address") { }
    }

    /// <summary>Represent the Address table</summary>
    public class Address : BaseTable2<AddressRow, AddressColumnInfo>
    {
        public Address() : base("Address") { }

        /// <summary>Load address by entity and type</summary>
        /// <param name="entityId">entity id</param>
        /// <param name="addressType">address type</param>
        public void LoadByEntityAndType(int entityId, string addressType)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("EntityId",   entityId);
            parameters.Add("AddressType",addressType);
            this.LoadBySP("pAddessByEntityAndAddressType", parameters);
        }

        /// <summary>Gets address by entity and type</summary>
        /// <param name="entityId">entity id</param>
        /// <param name="addressType">address type</param>
        /// <returns>Returns address or null if not found</returns>
        public static AddressRow GetByEntityAndType(int entityId, string addressType)
        {
            Address address = new Address();
            address.LoadByEntityAndType(entityId, addressType);
            return address.FirstOrDefault();
        }
    }


    /// <summary>Address enumeration extension methods</summary>
    public static class AddressEnumerableExtension { }
}
