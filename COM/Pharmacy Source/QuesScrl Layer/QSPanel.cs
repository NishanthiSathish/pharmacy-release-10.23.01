//===========================================================================
//
//							    QSPanel.cs
//
//  This class represents the QSPanel table.
//
//  Used by pharmacy panel class determines number and width of panel to display
//
//  Normaly there should be a default panel (where site ID is null) and 
//  where site specific data is required there shuold be a set of panel rows where
//  SiteID is not null.
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

    /// <summary>represents a single row in QSPanel</summary>
    public class QSPanelRow : BaseRow
    {
        public int QSPanelID
        {
            get { return FieldToInt(RawRow["QSPanelID"]).Value; } 
        }

        public int? SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]); } 
            set { RawRow["SiteID"] = IntToField(value);      }
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

        public int PanelIndex
        {
            get { return FieldToInt(RawRow["PanelIndex"]).Value; } 
            set { RawRow["PanelIndex"] = IntToField(value);      }
        }

        public int WidthAsPercentage
        {
            get { return FieldToInt(RawRow["WidthAsPercentage"]).Value; } 
            set { RawRow["WidthAsPercentage"] = IntToField(value);      }
        }

        public int HeightInRows
        {
            get { return FieldToInt(RawRow["HeightInRows"]).Value; } 
            set { RawRow["HeightInRows"] = IntToField(value);      }
        }
    }

    /// <summary>Provides column information for QSPanel, such as maximum field lengths</summary>
    public class QSPanelColumnInfo : BaseColumnInfo
    {
        public QSPanelColumnInfo() : base ("QSPanel") {  }

        public int CategoryLength { get { return base.FindColumnByName("Category").Length; } }
        public int SectionLength  { get { return base.FindColumnByName("Section" ).Length; } }
    }

    /// <summary>Represents QSPanel table</summary>
    public class QSPanel : BaseTable2<QSPanelRow, QSPanelColumnInfo>
    {
        public QSPanel() : base ("QSPanel") {  }

        /// <summary>
        /// Loads panel info by category, section and site ordered by PanelIndex
        /// If there are no site speicific results then will load in the defaults (siteID is null)
        /// </summary>
        public void LoadBySiteIDCategorySection(int? siteID, string category, string section)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID",    siteID  );
            parameters.Add("Category",  category);
            parameters.Add("Section",   section );
            LoadBySP("pQSPanelBySiteIDCategorySection", parameters);

            // If nothing is loaded the load defaults
            if (!this.Any())
                this.LoadBySiteIDCategorySection(null, category, section);
        }
    }
}
