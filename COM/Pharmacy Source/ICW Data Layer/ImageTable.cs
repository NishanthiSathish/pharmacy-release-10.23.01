// -----------------------------------------------------------------------
// <copyright file="ImageTable.cs" company="Ascribe">
//      Copyright Ascribe Ltd    
// </copyright>
// <summary>
// Provides access to the HAP Image table.
//
// Only supports reading, inserting.
//
// Modification History:
// 29May15 XN  Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.icwdatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>image type</summary>
    [EnumViaDBLookup(TableName = "ImageType", PKColumn = "ImageTypeID", DescriptionColumn = "Description")]
    public enum ImageTableType
    {
        /// <summary>No type</summary>
        None,

        /// <summary>Photograph image</summary>
        Photograph
    }

    /// <summary>Row in image table</summary>
    public class ImageTableRow : BaseRow
    {
        /// <summary>Gets row ID</summary>
        public int ImageID
        {
            get { return FieldToInt(this.RawRow["ImageID"]).Value; }
        }

        /// <summary>Gets or sets the image type.</summary>
        public ImageTableType ImageType
        {
            get { return FieldToEnumViaDBLookup<ImageTableType>(this.RawRow["ImageTypeID"]).Value;                    }
            set { this.RawRow["ImageTypeID"] = EnumToFieldViaDBLookup<ImageTableType>(value, addIfNotExists: false);  }
        }

        /// <summary>Gets or sets the description.</summary>
        public string Description
        {
            get { return FieldToStr(this.RawRow["Description"]);    }
            set { this.RawRow["Description"] = StrToField(value);   }
        }

        /// <summary>Gets or sets the detail.</summary>
        public string Detail
        {
            get { return FieldToStr(this.RawRow["Detail"]);    }
            set { this.RawRow["Detail"] = StrToField(value);   }
        }

        /// <summary>Gets or sets the image data</summary>
        public byte[] ImageData
        {
            get { return this.RawRow["ImageData"] == DBNull.Value ? null : (byte[])this.RawRow["ImageData"]; }
            set { this.RawRow["ImageData"] = value; }
        }

        /// <summary>Gets or sets the created date</summary>
        public DateTime CreatedDate
        {
            get { return FieldToDateTime(this.RawRow["CreatedDate"]).Value; }
            set { this.RawRow["CreatedDate"] = DateTimeToField(value);      }
        }

        /// <summary>Gets or sets the image date.</summary>
        public DateTime ImageDate
        {
            get { return FieldToDateTime(this.RawRow["ImageDate"]).Value; }
            set { this.RawRow["ImageDate"] = DateTimeToField(value);      }
        }

        /// <summary>Gets or sets the entity id of person who saved the image</summary>
        public int EntityID
        {
            get { return FieldToInt(this.RawRow["ImageID"]).Value; }
            set { this.RawRow["EntityID"] = IntToField(value);     }
        }
    }

    /// <summary>Image table column info</summary>
    public class ImageTableColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="ImageTableColumnInfo"/> class.</summary>
        public ImageTableColumnInfo () : base("Image") {}

        /// <summary>Gets the description length</summary>
        public int DescriptionLength { get { return this.FindColumnByName("Description").Length; } }

        /// <summary>Gets the detail length.</summary>
        public int DetailLength { get { return this.FindColumnByName("Detail").Length; } }
    }

    /// <summary>Image table</summary>
    public class ImageTable : BaseTable2<ImageTableRow, ImageTableColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="ImageTable"/> class.</summary>
        public ImageTable() : base("Image") { }

        /// <summary>Load by image id</summary>
        /// <param name="imageId">image id</param>
        public void LoadByImageID(int imageId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("ImageID", imageId);
            this.LoadBySQL("SELECT * FROM Image WHERE ImageID=@ImageID", parameters);
        }

        /// <summary>Get image by id</summary>
        /// <param name="imageId">image id</param>
        /// <returns>The image <see cref="byte[]"/></returns>
        public static byte[] GetImageByImageID(int imageId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@ImageID", imageId);
            return Database.ExecuteSQLScalar<byte[]>("SELECT ImageData FROM Image WHERE ImageID=@ImageID", parameters);            
        }

        /// 26Aug16 KR Added. 161136
        /// <summary>Deletes the specified image by id</summary>
        /// <param name="imageId">image id</param>
        public void DeleteImageByImageID(int imageId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@ImageID", imageId);
            Database.ExecuteSQLNonQuery("DELETE FROM Image WHERE ImageID=@ImageID", parameters);
        }

    }
}
