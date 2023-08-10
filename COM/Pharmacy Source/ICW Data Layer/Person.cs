//===========================================================================
//
//							Person.cs
//
//  Provides access to Person table.
//
//  Class is derived from Entity
//
//  SP for this object should return all fields from the Entity table 
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  08Feb12 XN  Made Person non templatable.
//  24Nov11 AJK Added name
//  22Aug14 XN  Converted LoadByEntityID to non XML version as XML comes back different on some live servers
//  22Aug16 XN  160920 Added Initials
//===========================================================================
using System;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Person, and Entity tables</summary>
    public class PersonRow : EntityRow
    {
        public string Title    { get { return FieldToStr(RawRow["Title"],    true, string.Empty); } }
        public string Forename { get { return FieldToStr(RawRow["Forename"], true, string.Empty); } } 
        public string Surname  { get { return FieldToStr(RawRow["Surname"],  true, string.Empty); } }
        public string Initials { get { return FieldToStr(RawRow["Initials"], true, string.Empty); } }   //  22Aug16 XN Added 160920
    
        /// <summary>Returns full name of person {title} {forename} {surname}</summary>
        public override string ToString()
        {            
            StringBuilder name = new StringBuilder();

            if (!string.IsNullOrEmpty(Title))
            {
                name.Append(Title);
                name.Append(" ");
            }

            if (!string.IsNullOrEmpty(Forename))
            {
                name.Append(Forename);
                name.Append(" ");
            }

            if (!string.IsNullOrEmpty(Surname))
                name.Append(Surname);

            return name.ToString();
        }
    }

    /// <summary>Provides column information about the Person, and Entity tables</summary>
    public class PersonColumnInfo : EntityColumnInfo
    {
        public PersonColumnInfo(string tableName) : base(tableName) { }

        public PersonColumnInfo() : base("Person") { }
    }

    /// <summary>Represent the Person, and Entity table</summary>
    public class Person : BaseTable2<PersonRow, PersonColumnInfo>
    {
        public Person() : base("Person") { }

        public void LoadByEntityID(int entityID)
        {
            // LoadFromXMLString("Exec pPersonXML @CurrentSessionID={0}, @EntityID={1}", SessionInfo.SessionID, entityID); 22Aug14 XN
            LoadBySQL("Exec pPersonForPharmacy @CurrentSessionID={0}, @EntityID={1}", SessionInfo.SessionID, entityID);
        }

        public static PersonRow GetByEntityID(int entityID)
        {
            Person person = new Person();
            person.LoadByEntityID(entityID);
            return person.Any() ? person[0] : null;
        }
    }
}
