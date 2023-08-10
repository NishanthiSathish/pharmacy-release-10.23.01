//===========================================================================
//
//							QSDisplayItem.cs
//
//  This class represents the QSDisplayItem table.
//
//  QuesScrol class used to determine what is displayed in any particular grid, or panel.
//
//  Each gid or panel that uses the class will require it's own unique Category, 
//  and Section values (user to load all the relavent QSDisplayItem rows)
//  The order that items apear on display is determied by DisplayIndex (zero based lowest first)
//
//  Normaly there should be a default seting of display items (where site ID is null) and 
//  where site specific data is required there shuold be a set of panel rows where
//  SiteID is not null.
//
//  Each row is linked to a QSField to determine accessor class, and property to display 
//  
//  When a set of QSDisplayItem rows are used by a grid they will have following fields 
//      WidthAsPercentage
//      Alignment
//      AllowWrap
//  When a rows are used by a panel they will have the following field set
//      QSPanelID
//
//	Modification History:
//  08Sep14 XN  Written 98658
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.quesscrllayer
{
    using System.Linq;

    /// <summary>represents a single row in QSDisplayItem</summary>
    public class QSDisplayItemRow : BaseRow
    {
        public int QSDisplayItemID
        {
            get { return FieldToInt(RawRow["QSDisplayItemID"]).Value; } 
        }

        public int? SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]);  } 
            set { RawRow["SiteID"] = IntToField(value); }
        }

        public string Category
        {
            get { return FieldToStr(RawRow["Category"], true, string.Empty); } 
            set { RawRow["Category"] = StrToField(value);                     }
        }

        public string Section
        {
            get { return FieldToStr(RawRow["Section"], true, string.Empty); } 
            set { RawRow["Section"] = StrToField(value);                     }
        }

        public int QSFieldID
        {
            get { return FieldToInt(RawRow["QSFieldID"]).Value; } 
            set { RawRow["QSFieldID"] = IntToField(value);      }
        }

        public int DisplayIndex
        {
            get { return FieldToInt(RawRow["DisplayIndex"]).Value; } 
            set { RawRow["DisplayIndex"] = IntToField(value);      }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty);} 
            set { RawRow["DisplayIndex"] = StrToField(value);                   }
        }

        public string FormatOption
        {
            get { return FieldToStr(RawRow["FormatOption"], true, string.Empty); } 
            set { RawRow["FormatOption"] = StrToField(value);                     }
        }

        public int WidthAsPercentage
        {
            get { return FieldToInt(RawRow["WidthAsPercentage"]).Value; } 
            set { RawRow["WidthAsPercentage"] = IntToField(value);      }
        }

        public string Alignment
        {
            get { return FieldToStr(RawRow["Alignment"], false, string.Empty); } 
            set { RawRow["Alignment"] = StrToField(value);                     }
        }

        public bool AllowWrap
        {
            get { return FieldToBoolean(RawRow["AllowWrap"], false).Value; } 
            set { RawRow["AllowWrap"] = BooleanToField(value);             }
        }

        public int? QSPanelID
        {
            get { return FieldToInt(RawRow["QSPanelID"]);  } 
            set { RawRow["QSPanelID"] = IntToField(value); }
        }

        public string AccessorTag
        {
            get { return FieldToStr(RawRow["AccessorTag"], true, string.Empty); } 
        }

        public int DataIndex
        {
            get { return FieldToInt(RawRow["DataIndex"]).Value; } 
        }

        public QSDataType DataType
        {
            get { return FieldStrToEnum<QSDataType>(RawRow["DataType"], true).Value; } 
        }

        public string PropertyName
        {
            get { return FieldToStr(RawRow["PropertyName"], true, string.Empty); } 
        }
    }

    /// <summary>Provides column information for QSDisplayItem, such as maximum field lengths</summary>
    public class QSDisplayItemColumnInfo : BaseColumnInfo
    {
        public QSDisplayItemColumnInfo() : base ("QSDisplayItem") {  }

        public int CategoryLength    { get { return base.FindColumnByName("Category"     ).Length; } }
        public int SectionLength     { get { return base.FindColumnByName("Section"      ).Length; } }
        public int DescriptionLength { get { return base.FindColumnByName("Description"  ).Length; } }
        public int FormatOptionLength{ get { return base.FindColumnByName("FormatOption" ).Length; } }
        public int AlignmentLength   { get { return base.FindColumnByName("Alignment"    ).Length; } }
    }


    /// <summary>Represents QSDisplayItem table</summary>
    public class QSDisplayItem : BaseTable2<QSDisplayItemRow, QSDisplayItemColumnInfo>
    {
        public QSDisplayItem() : base ("QSDisplayItem") {  }

        /// <summary>
        /// Loads by site, category, and section order by DisplayIndex asc
        /// If there are no site speicific results then will load in the defaults (siteID is null)
        /// </summary>
        public void LoadBySiteIDCategorySection(int? siteID, string category, string section)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",    siteID  );
            parameters.Add("Category",  category);
            parameters.Add("Section",   section );
            LoadBySP("pQSDisplayItemBySiteIDCategorySection", parameters);

            // If nothing is loaded the load defaults
            if (!this.Any() && siteID != null)
                this.LoadBySiteIDCategorySection(null, category, section);
        }
    }
}
