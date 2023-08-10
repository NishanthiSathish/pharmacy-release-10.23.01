//===========================================================================
//
//							    WindowParameter.cs
//
//  Provides access to WindowParameter table.
//
//  Only supports reading, updating, inserting.
//  
//	Modification History:
//	03Mar14 XN  Written
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the WindowParameter table</summary>
    public class WindowParameterRow : BaseRow
    {
        public int WindowParameterID 
        { 
            get { return FieldToInt(RawRow["WindowParameterID"]).Value;  }  
        }

        public int WindowID 
        { 
            get { return FieldToInt(RawRow["WindowID"]).Value;  }  
            set { RawRow["WindowID"] = IntToField(value);       }  
        }

        public string Description 
        { 
            get { return FieldToStr(RawRow["Description"]);  }  
            set { RawRow["Description"] = StrToField(value); }  
        }

        public string Value 
        { 
            get { return FieldToStr(RawRow["Value"], false, string.Empty);  }  
            set { RawRow["Value"] = StrToField(value);                      }  
        }
    }
    
    /// <summary>Provides column information about the WindowParameter table</summary>
    public class WindowParameterColumnInfo : BaseColumnInfo
    {
        public WindowParameterColumnInfo() : base("WindowParameter") { }

        public int DescriptionLength    { get { return tableInfo.GetFieldLength("Description"); } } 
        public int ValueLength          { get { return tableInfo.GetFieldLength("Value");       } } 
    }

    /// <summary>Represent the WindowParameter table</summary>
    public class WindowParameter : BaseTable2<WindowParameterRow, WindowParameterColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WindowParameter() : base ("WindowParameter") { }

        public void LoadByWindowIDAndDescription(int windowID, string description)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WindowID",       windowID);
            parameters.Add("Description",    description);
            LoadBySQL("SELECT * FROM WindowParameter WHERE WindowID=@WindowID and Description=@Description", parameters);
        }
    }
}
