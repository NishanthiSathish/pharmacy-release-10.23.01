// -----------------------------------------------------------------------
// <copyright file="Routine.cs" ccompany="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
//
//  This class represents the Routine table.  
//
//  Only supports reading from table.
//  
//  Usage:
//  RoutineRow report = Routine.GetByName("pENTITY_PANEL");
//      
//  Modification History:
//  12Jan15 XN  Written
//  08May15 XN  Update RoutineRow for changes in BaseRow (change field from static to instance for error handling improvements)
//  29May15 XN  Added methods GetByDescription and LoadByDescription
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.icwdatalayer
{
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Represents a record in the Routine table</summary>
    public class RoutineRow : BaseRow
    {
        /// <summary>Gets RoutineID Field</summary>
        public int RoutineID
        {
            get { return this.FieldToInt(this.RawRow["RoutineID"]).Value; }
        }

        /// <summary>Gets or sets Description Field</summary>
        public string Description
        {
            get { return this.FieldToStr(this.RawRow["Description"]);  }
            set { this.RawRow["Description"] = this.StrToField(value); }
        }

        /// <summary>Gets or sets Name Field</summary>
        public string Name
        {
            get { return this.FieldToStr(this.RawRow["Name"]);  }
            set { this.RawRow["Name"] = this.StrToField(value); }
        }
    }

    /// <summary>Provides column information about the Routine table</summary>
    public class RoutineColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="RoutineColumnInfo"/> class.</summary>
        public RoutineColumnInfo() : base ("Routine") {  }

        /// <summary>Gets description field length</summary>
        public int DescriptionLength { get { return FindColumnByName("Description").Length; } }

        /// <summary>Gets Name field length</summary>
        public int NameLength { get { return FindColumnByName("Name").Length; } }
    }

    /// <summary>Represent the Routine table</summary>
    public class Routine : BaseTable2<RoutineRow, RoutineColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="Routine"/> class.</summary>
        public Routine() : base ("Routine") { }

        /// <summary>Returns routine by Name this is the sp name not the description (or null if no match)</summary>
        /// <param name="name">Name of routine e.g. pENTITY_PANEL</param>
        /// <returns>routine or null</returns>
        public static RoutineRow GetByName(string name)
        {
            Routine report = new Routine();
            report.LoadByName(name);
            return report.FirstOrDefault();
        }

        /// <summary>Returns routine by Description (or null if no match)</summary>
        /// <param name="description">description of routine e.g. Entity Panel</param>
        /// <returns>routine or null</returns>
        public static RoutineRow GetByDescription(string description)
        {
            Routine report = new Routine();
            report.LoadByDescription(description);
            return report.FirstOrDefault();
        }

        /// <summary>Returns routine by ID</summary>
        /// <param name="id">Routine ID</param>
        /// <returns>routine row</returns>
        public static RoutineRow GetByID(int id)
        {
            Routine report = new Routine();
            report.LoadByID(id);
            return report.FirstOrDefault();
        }

        /// <summary>Load routine by name</summary>
        /// <param name="name)">Routine name</param>
        public void LoadByName(string name)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("Name", name);
            this.LoadBySP("pRoutineByName", parameters);
        }

        /// <summary>Load routine by description</summary>
        /// <param name="description">Routine description</param>
        public void LoadByDescription(string description)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("description", description);
            this.LoadBySP("pRoutineByDescription", parameters);            
        }

        /// <summary>Load routine by ID</summary>
        /// <param name="id)">Routine ID</param>
        public void LoadByID(int id)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("ID", id);
            this.LoadBySP("pRoutineByID", parameters);
        }
    }
}
